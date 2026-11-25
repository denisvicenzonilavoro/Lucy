import Foundation
import Observation
import SwiftUI
#if canImport(MapKit)
import MapKit
#endif

// Territorio · «Il giro di domani» con Apple Mappe (decisione dell'utente del 25 novembre 2026).
//
// Eccezione scritta in CLAUDE.md alla regola «niente servizi di mappe o percorsi» del Territorio: con l'interruttore
// «Usa Apple Mappe per il giro» (Impostazioni › Territorio, `ImpostazioniTerritorio.usaMappeApple`, spento di base) il giro
// si vede su una mappa vera di Apple (MapKit, framework di sistema) con il percorso in auto calcolato da Apple, i tempi e
// i km reali di ogni tratto e in totale.
//
// Privacy (vincolante, controllo statico nel workflow): questo è l'UNICO file di Sources che può usare MapKit e il
// calcolo dei percorsi. Ad Apple vanno solo i punti delle tappe (coordinate, da `Cliente.luogo` o dalle tabelle dei
// comuni): ogni richiesta nasce da `PercorsiApple.richiesta(da:a:)`, che riceve due `Coordinata` e niente altro (mai
// nomi, indirizzi, note o altri dati dei clienti; niente geocodifica né ricerca di luoghi). I nomi dei clienti non
// compaiono nemmeno sulla mappa: ogni segnaposto porta solo l'ora e l'iniziale. Il percorso calcolato vive solo in
// memoria (mai nell'archivio né nei backup) e si svuota alla chiusura del Territorio. Senza rete, se Apple non risponde,
// con l'interruttore spento o nelle istantanee resta la mappa disegnata di sempre con le stime in linea d'aria.

/// Un tratto del percorso di Apple Mappe fra due tappe consecutive.
struct TrattoApple: Equatable {
    let km: Double
    let minuti: Int
    /// I punti della linea (al più `Tema.Apple.Territorio.Giro.puntiMassimiTratto`), per disegnarla.
    let punti: [Coordinata]
}

/// Il percorso di tutto il giro: un tratto per ogni coppia di tappe consecutive, nello stesso ordine di `GiroGiorno.tappe`.
struct PercorsoApple: Equatable {
    let tratti: [TrattoApple]
    var km: Double { tratti.reduce(0) { $0 + $1.km } }
    var minuti: Int { tratti.reduce(0) { $0 + $1.minuti } }
}

/// A che punto è il calcolo del percorso di un giro.
enum EsitoPercorsoApple: Equatable {
    case inCalcolo
    case pronto(PercorsoApple)
    /// La rete non c'è o Apple non ha risposto: si torna alla mappa disegnata e alle stime.
    case nonDisponibile
}

/// I percorsi calcolati, per elenco di coordinate delle tappe. Solo in memoria, al più pochi giri alla volta.
@Observable final class PercorsiApple {
    static let condiviso = PercorsiApple()

    private(set) var esiti: [String: EsitoPercorsoApple] = [:]
    @ObservationIgnored private var ordine: [String] = []
    @ObservationIgnored private var lavori: [String: Task<Void, Never>] = [:]

    /// Quanti giri tenere in memoria (Mac da 8 GB).
    private static let giriMassimi = 6

    /// La chiave di un elenco di tappe: solo le coordinate, arrotondate (nessun altro dato).
    static func chiave(_ punti: [Coordinata]) -> String {
        punti.map { String(format: "%.5f,%.5f", $0.lat, $0.lon) }.joined(separator: ";")
    }

    func esito(_ punti: [Coordinata]) -> EsitoPercorsoApple? {
        esiti[Self.chiave(punti)]
    }

    /// Libera tutto (alla chiusura del Territorio) e ferma i calcoli in corso.
    func svuota() {
        for (_, t) in lavori { t.cancel() }
        lavori = [:]
        ordine = []
        if !esiti.isEmpty { esiti = [:] }
    }

    /// Fa partire il calcolo se il giro non è già noto. Un giro «non disponibile» si riprova solo dopo `svuota()`
    /// (alla prossima apertura del Territorio).
    @MainActor func calcola(_ punti: [Coordinata]) {
        let k = Self.chiave(punti)
        guard esiti[k] == nil, punti.count >= 2, punti.allSatisfy(\.valida) else { return }
        esiti[k] = .inCalcolo
        ordine.append(k)
        while ordine.count > Self.giriMassimi {
            let vecchia = ordine.removeFirst()
            lavori[vecchia]?.cancel()
            lavori[vecchia] = nil
            esiti[vecchia] = nil
        }
        #if canImport(MapKit)
        lavori[k] = Task { @MainActor [weak self] in
            var tratti: [TrattoApple] = []
            for i in 0..<(punti.count - 1) {
                if Task.isCancelled { return }
                guard let tratto = await PercorsiApple.tratto(da: punti[i], a: punti[i + 1]) else {
                    self?.concludi(k, .nonDisponibile)
                    return
                }
                tratti.append(tratto)
            }
            if Task.isCancelled { return }
            self?.concludi(k, .pronto(PercorsoApple(tratti: tratti)))
        }
        #else
        esiti[k] = .nonDisponibile
        #endif
    }

    @MainActor private func concludi(_ k: String, _ esito: EsitoPercorsoApple) {
        lavori[k] = nil
        guard esiti[k] != nil else { return }
        esiti[k] = esito
    }

    #if canImport(MapKit)
    /// L'UNICA richiesta che esce verso Apple: due punti, nient'altro. Niente nome sui luoghi, niente indirizzo.
    static func richiesta(da a: Coordinata, a b: Coordinata) -> MKDirections.Request {
        let r = MKDirections.Request()
        r.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: a.lat, longitude: a.lon)))
        r.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: b.lat, longitude: b.lon)))
        r.transportType = .automobile
        r.requestsAlternateRoutes = false
        return r
    }

    /// Un tratto: due punti quasi uguali (sotto i 30 m) non chiedono nulla ad Apple.
    @MainActor private static func tratto(da a: Coordinata, a b: Coordinata) async -> TrattoApple? {
        if MotoreTerritorio.distanzaKm(a, b) < 0.03 { return TrattoApple(km: 0, minuti: 0, punti: [a, b]) }
        do {
            let risposta = try await MKDirections(request: richiesta(da: a, a: b)).calculate()
            guard let route = risposta.routes.first else { return nil }
            return TrattoApple(km: route.distance / 1000,
                               minuti: max(0, Int((route.expectedTravelTime / 60).rounded())),
                               punti: puntiLinea(route.polyline))
        } catch {
            return nil
        }
    }

    /// I punti della linea del percorso, diradati per la memoria.
    private static func puntiLinea(_ linea: MKPolyline) -> [Coordinata] {
        let n = linea.pointCount
        guard n > 0 else { return [] }
        var c = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(latitude: 0, longitude: 0), count: n)
        linea.getCoordinates(&c, range: NSRange(location: 0, length: n))
        let massimo = max(2, Tema.Apple.Territorio.Giro.puntiMassimiTratto)
        let passo = max(1, Int((Double(n) / Double(massimo)).rounded(.up)))
        var risultato: [Coordinata] = []
        risultato.reserveCapacity(n / passo + 2)
        var i = 0
        while i < n {
            risultato.append(Coordinata(lat: c[i].latitude, lon: c[i].longitude))
            i += passo
        }
        if (n - 1) % passo != 0 { risultato.append(Coordinata(lat: c[n - 1].latitude, lon: c[n - 1].longitude)) }
        return risultato
    }
    #endif
}

extension GiroGiorno {
    /// Le coordinate delle tappe, nell'ordine del giro: l'unica cosa che va ad Apple.
    var puntiPercorso: [Coordinata] { tappe.map(\.coordinata) }
}

#if canImport(MapKit)
/// La mappa vera del giro: segnaposto con l'ora e l'iniziale, il percorso in auto di Apple Mappe disegnato sopra.
/// La fa vedere `AppTerritorio` solo con l'interruttore acceso, fuori dalle istantanee e finché il percorso non risulta
/// «non disponibile».
struct MappaGiroApple: View {
    let giro: GiroGiorno
    /// Margine a sinistra coperto dal pannello (0 se il pannello sta sotto la mappa).
    let coperto: CGFloat

    @State private var posizione: MapCameraPosition = .automatic

    private typealias G = Tema.Apple.Territorio.Giro

    private struct Segnaposto: Identifiable {
        let id: String
        let titolo: String
        let casa: Bool
        let coordinata: CLLocationCoordinate2D
    }

    private struct Linea: Identifiable {
        let id: Int
        let punti: [CLLocationCoordinate2D]
    }

    var body: some View {
        let punti = giro.puntiPercorso
        let chiave = PercorsiApple.chiave(punti)
        let esito = PercorsiApple.condiviso.esito(punti)
        let linee = Self.lineeDi(esito)
        let segnaposti = segnapostiDelGiro()
        Map(position: $posizione) {
            ForEach(linee) { l in
                MapPolyline(coordinates: l.punti)
                    .stroke(G.percorso, lineWidth: G.spessorePercorsoApple)
            }
            ForEach(segnaposti) { s in
                if s.casa {
                    Marker(s.titolo, systemImage: G.simboloCasaApple, coordinate: s.coordinata)
                        .tint(G.tintaCasaApple)
                } else {
                    Marker(s.titolo, coordinate: s.coordinata)
                        .tint(G.percorso)
                }
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .safeAreaPadding(.leading, coperto)
        .task(id: chiave) {
            posizione = .automatic
            await PercorsiApple.condiviso.calcola(punti)
        }
        .onChange(of: linee.count) { posizione = .automatic }
    }

    /// Partenza (se c'è) e visite: solo l'ora e l'iniziale del cliente, mai il nome.
    private func segnapostiDelGiro() -> [Segnaposto] {
        var s: [Segnaposto] = []
        for t in giro.tappe {
            let c = CLLocationCoordinate2D(latitude: t.coordinata.lat, longitude: t.coordinata.lon)
            switch t.genere {
            case .partenza:
                s.append(Segnaposto(id: "partenza", titolo: TestiTerritorio.partenzaMappeApple, casa: true, coordinata: c))
            case .rientro:
                // Il rientro torna di solito alla partenza: un segnaposto solo se è altrove
                if let p = giro.tappe.first, p.genere == .partenza, MotoreTerritorio.distanzaKm(p.coordinata, t.coordinata) < 0.03 { continue }
                s.append(Segnaposto(id: "rientro", titolo: TestiTerritorio.rientroMappeApple, casa: true, coordinata: c))
            case .visita:
                let ora = t.appuntamento.map { Formati.ora.string(from: $0.inizio) } ?? ""
                let iniziale = t.cliente?.nome.trimmingCharacters(in: .whitespaces).first.map { String($0).uppercased() } ?? ""
                let titolo = [ora, iniziale].filter { !$0.isEmpty }.joined(separator: " · ")
                s.append(Segnaposto(id: t.id, titolo: titolo, casa: false, coordinata: c))
            }
        }
        return s
    }

    private static func lineeDi(_ esito: EsitoPercorsoApple?) -> [Linea] {
        guard case .pronto(let p)? = esito else { return [] }
        return p.tratti.enumerated().compactMap { i, t in
            t.punti.count >= 2 ? Linea(id: i, punti: t.punti.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }) : nil
        }
    }
}
#endif
