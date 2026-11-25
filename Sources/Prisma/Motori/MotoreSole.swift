import Foundation
import simd

// Il sole del piano (decisione dell'utente del 25 novembre 2026): nella Sala e nella realtà aumentata il disco d'oro di
// Lucy prende il posto del vecchio prisma di luce. Il disco si riempie di luce man mano che gli obiettivi del cliente
// sono coperti; ogni obiettivo è un raggio sottile, lungo quanto è coperto. Puro, senza SwiftUI né RealityKit: le cifre
// sono quelle di `MotoreObiettivo` (la copertura alla scadenza), mai inventate. Lo usano `SoleDelPiano` (SwiftUI), il
// disco d'oro di `CristalloRealta` (RealityKit), il fermo-immagine e lo scatto (`CristalloFermo`), il palco della Sala
// (`PalcoLuce`), il tavolo (solo le coperture, senza nomi) e `ProvaCalcoliSole`.

/// Un raggio del sole: un obiettivo del cliente e quanto è coperto.
struct RaggioSole: Equatable, Identifiable {
    let id: String
    /// Il titolo dell'obiettivo (vuoto per i raggi arrivati dal tavolo, che non portano nomi).
    let nome: String
    /// 0…1: `EsitoObiettivo.copertura`.
    let copertura: Double
}

/// Tutte le cifre del sole del piano.
struct SolePiano: Equatable {
    /// Un raggio per obiettivo, nell'ordine del dossier (al più `MotoreSole.raggiMassimi`).
    var raggi: [RaggioSole] = []
    /// 0…1: quanto del piano è coperto, Σ min(proiezione, importo alla scadenza) / Σ importo alla scadenza.
    var luce: Double = 0

    /// Nessun obiettivo: il disco resta d'oro, spento, senza raggi.
    var senzaObiettivi: Bool { raggi.isEmpty }

    static let spento = SolePiano()
}

enum MotoreSole {
    /// Oltre dodici raggi il disco non si legge più: gli altri obiettivi contano nella luce ma non hanno un raggio.
    static let raggiMassimi = 12

    /// Il sole del piano per gli obiettivi di un cliente (`obiettivi` nell'ordine del dossier: si tengono solo quelli
    /// del cliente delle posizioni, se le posizioni dicono di chi sono).
    static func calcola(obiettivi: [Obiettivo], posizioni: [Posizione], oggi: Date = Date()) -> SolePiano {
        let esiti = obiettivi.map { MotoreObiettivo.calcola($0, posizioni: posizioni, data: oggi) }
        let voci: [(id: String, nome: String, copertura: Double, dovuto: Double, proiezione: Double)] = esiti.map {
            (id: $0.obiettivo.id, nome: $0.obiettivo.titolo, copertura: $0.copertura, dovuto: $0.importoScadenza,
             proiezione: $0.proiezione)
        }
        return sole(voci)
    }

    /// Dalle cifre di ogni obiettivo (già calcolate): i raggi e la luce del disco.
    static func sole(_ voci: [(id: String, nome: String, copertura: Double, dovuto: Double, proiezione: Double)]) -> SolePiano {
        guard !voci.isEmpty else { return .spento }
        let raggi = voci.prefix(raggiMassimi).map {
            RaggioSole(id: "raggio-\($0.id)", nome: $0.nome, copertura: limita($0.copertura))
        }
        var dovuto = 0.0, coperto = 0.0
        for v in voci where v.dovuto.isFinite && v.dovuto > 0 {
            dovuto += v.dovuto
            coperto += min(v.dovuto, max(0, v.proiezione.isFinite ? v.proiezione : 0))
        }
        let luce: Double
        if dovuto > 0 {
            luce = coperto / dovuto
        } else {
            // Nessun importo alla scadenza: la media delle coperture (che allora sono piene)
            luce = voci.reduce(0) { $0 + limita($1.copertura) } / Double(voci.count)
        }
        return SolePiano(raggi: Array(raggi), luce: limita(luce))
    }

    /// Le coperture che vanno al tavolo (solo cifre, mai nomi né identificativi).
    static func coperture(_ s: SolePiano) -> [Double] { s.raggi.map { limita($0.copertura) } }

    /// Il sole arrivato dal tavolo: raggi senza nome.
    static func daCoperture(_ coperture: [Double], luce: Double) -> SolePiano {
        SolePiano(raggi: coperture.prefix(raggiMassimi).enumerated().map {
            RaggioSole(id: "raggio-\($0.offset)", nome: "", copertura: limita($0.element))
        }, luce: limita(luce))
    }

    /// Il sole di una giornata della pensione: un raggio per scena con l'importo, pieno se ci sta, spento se no; la luce
    /// è la parte delle scene che ci stanno (gli esiti di `MotoreGiornataPensione`, nessuna cifra nuova).
    static func giornata(_ e: EsitoGiornata) -> SolePiano {
        let scene = e.scene.filter { !$0.senzaImporto }
        guard !scene.isEmpty else { return .spento }
        let raggi = scene.prefix(raggiMassimi).map {
            RaggioSole(id: "scena-\($0.voce.id)", nome: $0.voce.titolo, copertura: $0.ciSta ? 1 : 0)
        }
        return SolePiano(raggi: Array(raggi), luce: Double(scene.filter(\.ciSta).count) / Double(scene.count))
    }

    /// 0…1, e 0 per ciò che non è un numero.
    static func limita(_ x: Double) -> Double { x.isFinite ? min(1, max(0, x)) : 0 }

    // MARK: - La geometria (comune a SwiftUI e RealityKit)

    /// L'angolo del raggio `i` di `n` (radianti): il primo in alto, poi in senso orario (y in giù sullo schermo).
    static func angolo(_ i: Int, di n: Int) -> Double {
        guard n > 0 else { return -Double.pi / 2 }
        return -Double.pi / 2 + 2 * Double.pi * Double(i) / Double(n)
    }

    /// La lunghezza di un raggio come quota della lunghezza massima: un filo anche a copertura zero, pieno a copertura 1.
    static func lunghezza(_ copertura: Double) -> Double { quotaMinima + (1 - quotaMinima) * limita(copertura) }
    static let quotaMinima = 0.12

    /// L'intensità di un raggio (0…1): mai del tutto spento, pieno a copertura 1.
    static func intensita(_ copertura: Double) -> Double { 0.32 + 0.68 * limita(copertura) }
}

// MARK: - Il disco d'oro in RealityKit (maglia pura)

extension MotoreRealtaAumentata {
    /// Il raggio del disco d'oro della realtà aumentata (unità).
    static let raggioDisco: Float = 0.5
    /// Gli spicchi del cerchio del disco.
    static let segmentiDisco = 64
    /// Il disco è sottile: lo spessore degli strati è l'altezza del patrimonio per questa quota.
    static let quotaSpessoreDisco = 0.16

    /// Lo spessore della pila di dischi per l'anno (unità): l'altezza del patrimonio, resa sottile.
    static func spessoreDisco(_ e: EsitoRealta, anno: Int?) -> Double { e.altezza(anno: anno) * quotaSpessoreDisco }

    /// La pianta del disco: `segmenti` punti (x, z) sul cerchio, con la normale orizzontale di ciascuno.
    static func piantaDisco(raggio: Float = raggioDisco, segmenti: Int = segmentiDisco) -> [(punto: SIMD2<Float>, normale: SIMD2<Float>)] {
        let s = max(8, segmenti)
        return (0..<s).map { k in
            let a = Float(k) * 2 * Float.pi / Float(s)
            let n = SIMD2<Float>(sin(a), -cos(a))
            return (punto: n * raggio, normale: n)
        }
    }

    /// Il disco (un cilindro basso) fra `basso` e `alto`: facce laterali con normali orizzontali, coperchi sopra e sotto,
    /// triangoli in senso antiorario visti da fuori. Stessa costruzione di `maglia`, con il cerchio come pianta.
    static func magliaDisco(basso: Float, alto: Float, raggio: Float = raggioDisco, segmenti: Int = segmentiDisco) -> MagliaPrisma {
        let anello = piantaDisco(raggio: raggio, segmenti: segmenti)
        let y0 = min(basso, alto)
        let y1 = max(alto, basso + 0.001)
        var posizioni: [SIMD3<Float>] = []
        var normali: [SIMD3<Float>] = []
        var indici: [UInt32] = []

        func triangolo(_ a: Int, _ b: Int, _ c: Int, verso: SIMD3<Float>) {
            let pa = posizioni[a], pb = posizioni[b], pc = posizioni[c]
            let n = simd_cross(pb - pa, pc - pa)
            if simd_dot(n, verso) >= 0 {
                indici.append(contentsOf: [UInt32(a), UInt32(b), UInt32(c)])
            } else {
                indici.append(contentsOf: [UInt32(a), UInt32(c), UInt32(b)])
            }
        }

        let m = anello.count
        for p in anello {
            let n = SIMD3<Float>(p.normale.x, 0, p.normale.y)
            posizioni.append(SIMD3(p.punto.x, y0, p.punto.y)); normali.append(n)
            posizioni.append(SIMD3(p.punto.x, y1, p.punto.y)); normali.append(n)
        }
        for i in 0..<m {
            let j = (i + 1) % m
            let a = 2 * i, b = 2 * i + 1, c = 2 * j, d = 2 * j + 1
            let meta = simd_normalize(SIMD3<Float>(anello[i].normale.x + anello[j].normale.x, 0,
                                                   anello[i].normale.y + anello[j].normale.y))
            triangolo(a, c, d, verso: meta)
            triangolo(a, d, b, verso: meta)
        }
        for (y, verso) in [(y1, SIMD3<Float>(0, 1, 0)), (y0, SIMD3<Float>(0, -1, 0))] {
            let centro = posizioni.count
            posizioni.append(SIMD3(0, y, 0)); normali.append(verso)
            let primo = posizioni.count
            for p in anello {
                posizioni.append(SIMD3(p.punto.x, y, p.punto.y)); normali.append(verso)
            }
            for i in 0..<m {
                triangolo(centro, primo + i, primo + (i + 1) % m, verso: verso)
            }
        }
        return MagliaPrisma(posizioni: posizioni, normali: normali, indici: indici)
    }
}
