import SwiftUI

// Posizioni › Radar (Design/template-luce-specifica.md §8.3, «Luce» giro 2):
//
//   ┌ radar scuro ──────────────────────────────┐ ┌ I TUOI PORTAFOGLI MODELLO ─────────┐
//   │            PRUDENTE                        │ │ Prudente       20 · 55 · 20 · 5    │
//   │     15 punti ·  ·  ·                       │ │ ▬▬▬▬▬▬▬▬▬▬▬▬▬                      │
//   │   ( 10 punti ( 5 · tolleranza ) ) ◉ LM     │ └────────────────────────────────────┘
//   │ DINAMICO     fascio che gira               │ ┌ 9  clienti fuori tolleranza   18 ──┐
//   │            EQUILIBRATO                     │ │ [ Riequilibra i 9 clienti ]        │
//   └────────────────────────────────────────────┘ └────────────────────────────────────┘
//                                                  ┌ I PIÙ LONTANI DAL MODELLO ─────────┐
//
// - Le cifre vengono da MotoreRadar (composizione di Analisi 360, senza la previdenza; distanza ½ Σ |quota − peso|;
//   spostamenti dentro i canali; costi dai motori). Le frasi da TestiRadar.
// - I punti sono in un solo Canvas (200 clienti con --prova-carico); avatar, nomi e anelli che pulsano solo per i
//   clienti fuori tolleranza (fino a `massimoAvatar`) e per quello sotto il puntatore. Clic: il dettaglio nasce dal
//   punto (un'ancora invisibile sotto il punto scelto) e richiuso il punto resta al suo posto.
// - «Riequilibra» prepara le bozze (decisione 2): i punti restano dove sono, con l'anello tratteggiato verde e un
//   trattino verso il centro; il contatore resta, con «N bozze pronte». Niente si esegue da solo.
// - Movimento: fascio che gira in 4,5 s, anelli che pulsano, punti che compaiono a cascata, card a cascata.
//   «Riduci movimento» e istantanee: tutto fermo, fascio a −30°, anelli fermi, numeri completi.
// - Il radar è scuro anche nell'aspetto chiaro (decisione 129). In modalità cliente il Portafoglio non si apre.

struct RadarPortafoglioApple: View, Equatable {
    let stato: StatoShell
    let chiave: ChiaveVista
    let solaLettura: Bool

    @StateObject private var dettaglio: StatoDettaglio

    init(stato: StatoShell, chiave: ChiaveVista, solaLettura: Bool, dettaglioAperto: String? = nil) {
        self.stato = stato
        self.chiave = chiave
        self.solaLettura = solaLettura
        _dettaglio = StateObject(wrappedValue: dettaglioAperto.map {
            StatoDettaglio(aperto: $0, misura: Tema.Apple.Posizioni.Radar.Dettaglio.misura)
        } ?? StatoDettaglio())
    }

    nonisolated static func == (a: RadarPortafoglioApple, b: RadarPortafoglioApple) -> Bool {
        a.chiave == b.chiave && a.solaLettura == b.solaLettura
    }

    var body: some View {
        let r = stato.radarPortafoglio()
        let d = dettaglio
        return CorpoRadar(stato: stato, radar: r, solaLettura: solaLettura) { id in
            d.apri(id, misura: Tema.Apple.Posizioni.Radar.Dettaglio.misura)
        }
        .presentatoreDettaglio(dettaglio) { id in
            if let v = r.voci.first(where: { $0.id == id }) {
                DettaglioRadar(voce: v, solaLettura: solaLettura) {
                    // La bozza di riequilibrio si apre: nel dossier del cliente su Posizioni, tra le sue proposte
                    d.chiudi {
                        if let b = stato.preparaBozzeRiequilibrio([v]).first { stato.apriPosizione(b) }
                    }
                } dossier: {
                    d.chiudi(subito: true)
                    #if os(macOS)
                    // Migliorie d'uso 40: le Posizioni del cliente sulla coerenza con il profilo (il dossier resta
                    // con il doppio clic sul punto)
                    stato.apriPosizioniDalRadar(v.clienteId)
                    #else
                    stato.apriClienteDalRadar(v.clienteId)
                    #endif
                }
            }
        }
        .onDisappear { dettaglio.chiudi(subito: true) }
    }
}

// MARK: - Corpo: radar e colonna

private struct CorpoRadar: View {
    let stato: StatoShell
    let radar: RadarPortafoglio
    let solaLettura: Bool
    let apri: (String) -> Void

    @State private var aperto: String?
    /// Il punto sotto il puntatore, condiviso fra la tela e le righe della card «chi» (migliorie d'uso 40). Lo legge
    /// solo il fumetto del radar: passare sulla tela o sulle righe non rifà né la tela né la colonna.
    @State private var puntatore: PuntatoreRadar
    @Environment(\.modoIstantanea) private var istantanea

    private typealias R = Tema.Apple.Posizioni.Radar
    private typealias K = Tema.Apple.Posizioni.Radar.Colonna

    init(stato: StatoShell, radar: RadarPortafoglio, solaLettura: Bool, apri: @escaping (String) -> Void) {
        self.stato = stato
        self.radar = radar
        self.solaLettura = solaLettura
        self.apri = apri
        // Nelle istantanee («898-posizioni-radar-riga-accesa») il punto acceso da una riga è già scritto
        let acceso = stato.radarPuntatoreIstantanea
        _puntatore = State(initialValue: PuntatoreRadar(sopra: acceso, daRiga: acceso != nil))
    }

    var body: some View {
        GeometryReader { g in
            let m = Tema.Apple.Posizioni.Disposizione.margine
            let larghezza = g.size.width - 2 * m
            let altezza = g.size.height - 2 * m
            let colonna = max(K.larghezzaMinima, larghezza * K.quotaColonna / (K.quotaRadar + K.quotaColonna))
            let affiancati = larghezza - colonna - K.spazio >= R.latoMinimo
            Group {
                if affiancati {
                    HStack(alignment: .top, spacing: K.spazio) {
                        radarVista
                            .frame(width: larghezza - colonna - K.spazio, height: altezza)
                            .entrataCascata(0, base: R.Moto.baseCascata)
                        #if os(macOS)
                        // La card «chi» occupa l'altezza che resta e il suo elenco scorre dentro
                        colonnaUso(riempie: true)
                            .frame(width: colonna, height: altezza, alignment: .top)
                        #else
                        ScrollView(.vertical, showsIndicators: false) {
                            colonnaVista
                        }
                        .frame(width: colonna, height: altezza)
                        #endif
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: K.spazio) {
                            radarVista
                                .frame(width: larghezza, height: max(R.latoMinimo, min(larghezza, altezza)))
                                .entrataCascata(0, base: R.Moto.baseCascata)
                            #if os(macOS)
                            colonnaUso(riempie: false)
                            #else
                            colonnaVista
                            #endif
                        }
                    }
                }
            }
            .padding(m)
        }
    }

    private var radarVista: some View {
        RadarModelli(radar: radar, aperto: aperto, puntatore: puntatore, sistema: stato.sistema) { id in
            aperto = id
            apri(id)
        } modello: { _ in
            stato.apriImpostazioniModelli()
        } dossier: { id in
            if let v = radar.voci.first(where: { $0.id == id }) { stato.apriClienteDalRadar(v.clienteId) }
        }
        .overlay { avvisoVuoto }
    }

    /// Senza modelli o senza clienti assegnati: l'invito sopra il radar vuoto.
    @ViewBuilder private var avvisoVuoto: some View {
        if radar.modelli.isEmpty || radar.voci.isEmpty {
            VStack(spacing: 14) {
                Text(radar.modelli.isEmpty ? TestiRadar.senzaModelli : TestiRadar.senzaAssegnati)
                    .carattereApple(Tema.Apple.Carattere.corpoGrande)
                    .foregroundColor(R.coloreNomePunto)
                    .multilineTextAlignment(.center)
                Button(radar.modelli.isEmpty ? "Imposta i modelli" : "Assegna i modelli") { stato.apriImpostazioniModelli() }
                    .buttonStyle(.applePrimario)
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: 420)
        }
    }

    #if os(macOS)
    /// La colonna delle migliorie d'uso 40: i modelli con la legenda a colori e la card «chi».
    private func colonnaUso(riempie: Bool) -> some View {
        VStack(alignment: .leading, spacing: K.spazio) {
            CardModelliRadar(modelli: radar.modelli) { _ in stato.apriImpostazioniModelli() }
                .entrataCascata(1, base: R.Moto.baseCascata)
            CardChiRadar(radar: radar, puntatore: puntatore, solaLettura: solaLettura, riempie: riempie) {
                stato.preparaBozzeRiequilibrio(radar.daRiequilibrare)
            } assegna: {
                stato.apriImpostazioniModelli()
            } apri: { id in
                aperto = id
                apri(id)
            }
            .frame(maxHeight: riempie ? .infinity : nil, alignment: .top)
            .entrataCascata(2, base: R.Moto.baseCascata)
        }
    }
    #endif

    #if !os(macOS)
    private var colonnaVista: some View {
        VStack(alignment: .leading, spacing: K.spazio) {
            CardModelliRadar(modelli: radar.modelli) { _ in stato.apriImpostazioniModelli() }
                .entrataCascata(1, base: R.Moto.baseCascata)
            CardConteggioRadar(radar: radar, solaLettura: solaLettura) {
                stato.preparaBozzeRiequilibrio(radar.daRiequilibrare)
            } assegna: {
                stato.apriImpostazioniModelli()
            }
            .entrataCascata(2, base: R.Moto.baseCascata)
            if !radar.voci.isEmpty {
                CardLontaniRadar(voci: radar.piuLontani) { id in
                    aperto = id
                    apri(id)
                }
                .entrataCascata(3, base: R.Moto.baseCascata)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(TestiRadar.piede)
                if radar.tolleranzaGenerale == nil, !radar.modelli.isEmpty { Text(TestiRadar.senzaTolleranza) }
                Text(TestiRadar.previdenzaEsclusa)
            }
            .carattereApple(Tema.Apple.Carattere.secondario)
            .foregroundColor(Tema.Apple.Colore.inchiostro2)
            .fixedSize(horizontal: false, vertical: true)
            .entrataCascata(4, base: R.Moto.baseCascata)
        }
    }
    #endif
}

// MARK: - Il radar

/// Il radar scuro: cerchi, settori dei modelli, fascio che gira, punti dei clienti.
struct RadarModelli: View {
    let radar: RadarPortafoglio
    /// Il punto da cui è nato il dettaglio aperto: sotto di lui c'è l'ancora del dettaglio.
    let aperto: String?
    /// Il punto sotto il puntatore, di chi contiene il radar (le righe della card «chi» lo scrivono anche loro). Lo
    /// legge solo il fumetto (FumettoRadar).
    let puntatore: PuntatoreRadar
    /// Le finestre di Prisma: il movimento si ferma quando Posizioni non si vede (MovimentoRadar).
    var sistema: StatoFinestre? = nil
    let apri: (String) -> Void
    let modello: (String) -> Void
    /// Doppio clic su un punto: il dossier del cliente.
    var dossier: (String) -> Void = { _ in }

    /// L'ultima geometria calcolata, per misura e radar.
    @State private var memoria = MemoriaGeometriaRadar()
    @State private var visibile = false
    /// Il punto scelto con la tastiera (Tab scorre i fuori tolleranza dal più lontano, Invio apre il dettaglio).
    @State private var tastiera: String?
    @FocusState private var conFuoco: Bool
    @Environment(\.prismaStatoFinale) private var fermo
    @Environment(\.prismaScatto) private var scatto
    @Environment(\.modoIstantanea) private var istantanea

    private typealias R = Tema.Apple.Posizioni.Radar

    var body: some View {
        GeometryReader { g in
            // La stessa misura e gli stessi punti (un dettaglio che si apre, Tab, la comparsa): la geometria di prima,
            // senza rifare la ricerca dei posti liberi per tutti i punti
            let geo = memoria.geometria(g.size, radar)
            ZStack(alignment: .topLeading) {
                fondo
                Canvas { ctx, _ in disegnaGriglia(ctx, geo) }
                MovimentoRadar(sistema: sistema) { vivo in
                    FascioRadar(centro: geo.centro, raggio: geo.raggio, vivo: vivo)
                        .allowsHitTesting(false)
                }
                Canvas { ctx, _ in disegnaPunti(ctx, geo) }
                    .opacity(visibile || fermo ? 1 : 0)
                    .animation(Tema.Apple.Moto.Curva.uscita.animazione(R.Moto.durataPunti).ritardoPrisma(R.Moto.ritardoPunti), value: visibile)
                MovimentoRadar(sistema: sistema) { vivo in anelliVivi(geo, vivo: vivo) }
                anelloTastiera(geo)
                nomiModelli(geo)
                ancora(geo)
                FumettoRadar(puntatore: puntatore, radar: radar, geo: geo)
            }
            .contentShape(Rectangle())
            // Il doppio clic prima del clic singolo: SwiftUI aspetta il secondo tocco solo dove c'è il doppio
            .onTapGesture(count: 2, coordinateSpace: .local) { p in
                if let v = geo.punto(vicinoA: p) { dossier(v.id) }
            }
            .onTapGesture(coordinateSpace: .local) { p in
                if let v = geo.punto(vicinoA: p) { apri(v.id) }
            }
            // Tastiera (§8.3.4): Tab scorre i punti fuori tolleranza dal più lontano, Invio apre il dettaglio, Esc lo
            // chiude (la ✕ del dettaglio ha `.cancelAction`)
            .focusable()
            .focused($conFuoco)
            .focusEffectDisabled()
            .onKeyPress(.tab) {
                scorriTastiera()
                return .handled
            }
            .onKeyPress(.return) {
                guard let id = tastiera else { return .ignored }
                apri(id)
                return .handled
            }
            .onChange(of: conFuoco) { _, fuoco in
                if !fuoco { tastiera = nil }
            }
            .onContinuousHover(coordinateSpace: .local) { fase in
                // Solo il fumetto si ridisegna, e solo quando cambia il punto sotto il puntatore
                let nuovo: String?
                switch fase {
                case .active(let p): nuovo = geo.punto(vicinoA: p)?.id
                case .ended: nuovo = nil
                }
                if puntatore.sopra != nuovo {
                    puntatore.daRiga = false
                    puntatore.sopra = nuovo
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Radar del portafoglio")
        }
        .clipShape(RoundedRectangle(cornerRadius: R.raggioCard, style: .continuous))
        // Nelle istantanee i punti sono già in vista (`fermo`): scriverlo rifarebbe il radar una seconda volta
        .onAppear { if !scatto { visibile = true } }
    }

    private var fondo: some View {
        RoundedRectangle(cornerRadius: R.raggioCard, style: .continuous)
            .fill(RadialGradient(colors: [R.fondoCentro, R.fondoBordo], center: R.centroFondo,
                                 startRadius: 0, endRadius: R.raggioFondo))
            .overlay(RoundedRectangle(cornerRadius: R.raggioCard, style: .continuous).stroke(R.bordo, lineWidth: 1))
    }

    // MARK: Griglia: cerchi, tolleranza, settori

    private func disegnaGriglia(_ ctx: GraphicsContext, _ geo: GeometriaRadar) {
        for a in R.anelli {
            let r = geo.raggio(punti: a)
            ctx.stroke(Path(ellipseIn: geo.cerchio(r)), with: .color(R.filo), lineWidth: R.spessoreFilo)
            ctx.draw(Text("\(TestiRadar.punti(a)) punti").font(R.scrittaCerchio.font).foregroundColor(R.coloreScrittaCerchio),
                     at: CGPoint(x: geo.centro.x + 6, y: geo.centro.y - r - 8), anchor: .leading)
        }
        if let t = radar.tolleranzaGenerale, t > 0 {
            let r = geo.raggio(punti: t)
            let c = Path(ellipseIn: geo.cerchio(r))
            ctx.fill(c, with: .color(R.riempimentoTolleranza))
            ctx.stroke(c, with: .color(R.bordoTolleranza), style: StrokeStyle(lineWidth: 1, dash: R.tratteggioTolleranza))
            ctx.draw(Text("\(TestiRadar.punti(t)) · tolleranza").font(R.scrittaCerchio.font).foregroundColor(R.scrittaTolleranza),
                     at: CGPoint(x: geo.centro.x + 6, y: geo.centro.y - r - 8), anchor: .leading)
        }
        if geo.settori > 1 {
            for i in 0..<geo.settori {
                var p = Path()
                p.move(to: geo.centro)
                p.addLine(to: geo.posizione(angolo: geo.inizioSettore(i), raggio: geo.raggio))
                ctx.stroke(p, with: .color(R.filo), lineWidth: R.spessoreFilo)
            }
        }
    }

    // MARK: Punti

    private func disegnaPunti(_ ctx: GraphicsContext, _ geo: GeometriaRadar) {
        let avatar = geo.conAvatar
        for v in radar.voci {
            let p = geo.posizione(v)
            // «Proposta pronta»: trattino verso dove andrebbe il punto (il modello, al centro) e anello tratteggiato
            if v.bozzaPronta {
                var t = Path()
                t.move(to: p)
                t.addLine(to: geo.destinazione(v))
                ctx.stroke(t, with: .color(R.trattinoProposta), style: StrokeStyle(lineWidth: 1.2, dash: R.tratteggioTrattino))
                ctx.stroke(Path(ellipseIn: geo.cerchio(R.puntoProposta, attorno: geo.destinazione(v))),
                           with: .color(R.trattinoProposta), lineWidth: 1)
            }
            let grande = avatar.contains(v.id)
            let raggio = grande ? R.puntoGrande : R.puntoPiccolo
            let cerchio = Path(ellipseIn: geo.cerchio(raggio, attorno: p))
            if v.stimata && !grande {
                ctx.stroke(cerchio, with: .color(R.puntoPiccoloAlto), lineWidth: R.spessoreBordoStimato)
            } else if grande {
                let tinta = v.tinta.colori.coloriTema
                ctx.fill(cerchio, with: .radialGradient(Gradient(colors: [tinta.alto, tinta.basso]),
                                                         center: CGPoint(x: p.x - raggio * 0.4, y: p.y - raggio * 0.64),
                                                         startRadius: 0, endRadius: raggio * 2.4))
                ctx.stroke(cerchio, with: .color(R.bordoPuntoGrande), lineWidth: R.spessoreBordoGrande)
                ctx.draw(Text(v.iniziali).font(R.iniziali.font).foregroundColor(.white), at: p)
                ctx.draw(Text(v.nome.split(separator: " ").first.map(String.init) ?? v.nome)
                            .font(R.nomePunto.font).foregroundColor(R.coloreNomePunto),
                         at: CGPoint(x: p.x, y: p.y + R.sottoNome - raggio), anchor: .top)
            } else {
                ctx.fill(cerchio, with: .linearGradient(Gradient(colors: [R.puntoPiccoloAlto, R.puntoPiccoloBasso]),
                                                         startPoint: CGPoint(x: p.x, y: p.y - raggio),
                                                         endPoint: CGPoint(x: p.x, y: p.y + raggio)))
                ctx.stroke(cerchio, with: .color(R.bordoPuntoPiccolo), lineWidth: 1)
            }
            if v.bozzaPronta {
                ctx.stroke(Path(ellipseIn: geo.cerchio(raggio + 5, attorno: p)), with: .color(R.anelloProposta),
                           style: StrokeStyle(lineWidth: 1.5, dash: R.tratteggioProposta))
            } else if v.fuori && (!grande || fermo) {
                // Anello fermo: per i pallini sempre, per gli avatar quando il movimento è fermo
                ctx.stroke(Path(ellipseIn: geo.cerchio(grande ? R.anelloGrande : R.anelloPiccolo, attorno: p)),
                           with: .color(R.arancioRadar), lineWidth: R.spessoreAnello)
            }
        }
    }

    /// Gli anelli che pulsano attorno agli avatar fuori tolleranza (solo con il movimento e con il radar in vista).
    @ViewBuilder private func anelliVivi(_ geo: GeometriaRadar, vivo: Bool) -> some View {
        if !fermo && vivo {
            ForEach(radar.voci.filter { $0.fuori && !$0.bozzaPronta && geo.conAvatar.contains($0.id) }) { v in
                AnelloPulsante()
                    .frame(width: 2 * R.anelloGrande, height: 2 * R.anelloGrande)
                    .position(geo.posizione(v))
                    .allowsHitTesting(false)
            }
        }
    }

    /// Il prossimo punto fuori tolleranza (dal più lontano), in giro.
    private func scorriTastiera() {
        let ordine = radar.voci.filter(\.fuori).sorted { $0.distanza > $1.distanza }.map(\.id)
        guard !ordine.isEmpty else { return }
        if let attuale = tastiera, let i = ordine.firstIndex(of: attuale) {
            tastiera = ordine[(i + 1) % ordine.count]
        } else {
            tastiera = ordine[0]
        }
        puntatore.daRiga = false
        puntatore.sopra = tastiera
    }

    /// L'anello bianco attorno al punto scelto con Tab.
    @ViewBuilder private func anelloTastiera(_ geo: GeometriaRadar) -> some View {
        if let id = tastiera, let v = radar.voci.first(where: { $0.id == id }) {
            Circle()
                .stroke(R.coloreAnelloTastiera, lineWidth: R.spessoreAnelloTastiera)
                .frame(width: 2 * R.anelloTastiera, height: 2 * R.anelloTastiera)
                .position(geo.posizione(v))
                .allowsHitTesting(false)
        }
    }

    /// I nomi dei modelli fuori dal cerchio grande, a metà del loro settore: un clic apre le Impostazioni.
    private func nomiModelli(_ geo: GeometriaRadar) -> some View {
        ForEach(Array(radar.modelli.enumerated()), id: \.element.id) { i, m in
            Text(m.nome)
                .carattereApple(R.nomeModello)
                .foregroundColor(R.colore(m.colore))
                .fixedSize()
                .position(geo.posizione(angolo: geo.metaSettore(i), raggio: geo.raggio + R.distanzaNome))
                .onTapGesture { modello(m.id) }
                .help("Apri il modello \(m.nome) in Impostazioni")
        }
    }

    /// L'ancora del dettaglio sotto il punto scelto, e un elemento VoiceOver per ogni punto.
    private func ancora(_ geo: GeometriaRadar) -> some View {
        ForEach(radar.voci) { v in
            let r = geo.conAvatar.contains(v.id) ? R.puntoGrande : R.puntoPiccolo
            Color.clear
                .frame(width: 2 * r, height: 2 * r)
                .modifier(AncoraPunto(attiva: v.id == aperto, id: v.id))
                .position(geo.posizione(v))
                .accessibilityElement()
                .accessibilityLabel(TestiRadar.accessibilita(v))
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { apri(v.id) }
                .allowsHitTesting(false)
        }
    }
}

/// Il punto sotto il puntatore (o scelto con Tab). Un oggetto e non uno stato del radar: cambia a ogni punto che si
/// sfiora e lo legge solo il fumetto, così passare sul radar non rifà geometria, le due tele e le 200 ancore.
@Observable final class PuntatoreRadar {
    var sopra: String?
    /// Il punto è acceso da una riga della card «chi» (migliorie d'uso 40): il fumetto aggiunge l'alone bianco.
    var daRiga = false

    init(sopra: String? = nil, daRiga: Bool = false) {
        self.sopra = sopra
        self.daRiga = daRiga
    }
}

/// Il fumetto del punto sotto il puntatore: nome, modello e distanza. È l'unica vista che legge il puntatore.
private struct FumettoRadar: View {
    let puntatore: PuntatoreRadar
    let radar: RadarPortafoglio
    let geo: GeometriaRadar

    private typealias R = Tema.Apple.Posizioni.Radar

    var body: some View {
        if let id = puntatore.sopra, let v = radar.voci.first(where: { $0.id == id }) {
            let p = geo.posizione(v)
            if puntatore.daRiga {
                // L'alone bianco del punto acceso da una riga (`drop-shadow(0 0 7px)` del template)
                let k = Tema.Apple.Posizioni.Radar.Colonna.self
                let r = (geo.conAvatar.contains(v.id) ? R.puntoGrande : R.puntoPiccolo) + k.margineAlone
                Circle()
                    .stroke(Color.white, lineWidth: R.spessoreAnelloTastiera)
                    .frame(width: 2 * r, height: 2 * r)
                    .shadow(color: Color.white.opacity(k.opacitaAlone), radius: k.aloneSopra)
                    .position(p)
                    .allowsHitTesting(false)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(v.nome).carattereApple(Tema.Apple.Carattere.barra)
                Text("\(v.modello.nome) · \(TestiRadar.puntiConNome(v.distanza))" + (v.bozzaPronta ? " · proposta pronta" : ""))
                    .carattereApple(Tema.Apple.Carattere.secondario)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
            }
            .padding(Tema.Apple.Misura.Padding.pulsante)
            .superficieApple(Tema.Apple.Superficie.dettaglio, raggio: Tema.Apple.Raggio.voce)
            .fixedSize()
            .position(x: p.x, y: max(30, p.y - R.puntoGrande - 26))
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }
}

/// L'ultima geometria del radar con la sua misura e il suo radar: una classe, così ricordarla non è un cambio di
/// stato della vista. Le passate del corpo con la stessa misura e gli stessi punti la riusano.
final class MemoriaGeometriaRadar {
    private var ultima: (dimensione: CGSize, radar: RadarPortafoglio, geo: GeometriaRadar)?

    func geometria(_ dimensione: CGSize, _ radar: RadarPortafoglio) -> GeometriaRadar {
        if let u = ultima, u.dimensione == dimensione, u.radar == radar { return u.geo }
        let geo = GeometriaRadar(dimensione: dimensione, radar: radar)
        ultima = (dimensione, radar, geo)
        return geo
    }
}

/// Il movimento infinito del radar (fascio e anelli che pulsano) solo quando si può vedere. Le finestre coperte da
/// una finestra ingrandita o ridotte nel dock restano montate (ShellView), come tutto con Prisma nascosto o a riposo:
/// prima il fascio e fino a `massimoAvatar` anelli si animavano a ogni fotogramma anche lì. Solo questa vista osserva
/// le finestre (come `SchemaConPausaOvunque`): il radar non si ridisegna quando si spostano.
private struct MovimentoRadar<Contenuto: View>: View {
    let sistema: StatoFinestre?
    @ViewBuilder let contenuto: (Bool) -> Contenuto
    @ObservedObject private var visibilita = VisibilitaPrisma.condivisa

    var body: some View {
        contenuto(inVista)
    }

    private var inVista: Bool {
        guard visibilita.visibile else { return false }
        #if os(macOS)
        if let s = sistema {
            // Il blocco conta a transizione finita, sotto la schermata; allo sblocco il movimento riparte subito
            if s.bloccato && s.bloccatoStabile { return false }
            if s.coperte.contains(.posizioni) || s.spente.contains(.posizioni) { return false }
        }
        #endif
        return true
    }
}

/// L'ancora del dettaglio sta solo sotto il punto aperto (un'ancora per punto costerebbe con 200 clienti).
private struct AncoraPunto: ViewModifier {
    let attiva: Bool
    let id: String
    @ViewBuilder func body(content: Content) -> some View {
        if attiva { content.origineDettaglio(id: id) } else { content }
    }
}

/// Il fascio che gira (4,5 s, lineare, all'infinito); fermo a −30° con «Riduci movimento» e nelle istantanee.
private struct FascioRadar: View {
    let centro: CGPoint
    let raggio: CGFloat
    /// false quando il radar non si può vedere (MovimentoRadar): il fascio sta fermo, senza l'animazione infinita.
    var vivo = true
    @Environment(\.prismaStatoFinale) private var fermo

    private typealias R = Tema.Apple.Posizioni.Radar

    var body: some View {
        let ampiezza = R.ampiezzaFascio
        let tela = Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            var spicchio = Path()
            spicchio.move(to: c)
            spicchio.addArc(center: c, radius: raggio, startAngle: .radians(-ampiezza), endAngle: .zero, clockwise: false)
            spicchio.closeSubpath()
            // Il gradiente va da trasparente al bordo di partenza a pieno sul bordo del fascio (solo nello spicchio)
            let quota = ampiezza / (2 * .pi)
            ctx.fill(spicchio, with: .conicGradient(Gradient(stops: [.init(color: R.verdeRadar.opacity(0), location: 0),
                                                                     .init(color: R.fascioFine, location: quota),
                                                                     .init(color: R.verdeRadar.opacity(0), location: min(1, quota + 0.001))]),
                                                    center: c, angle: .radians(-ampiezza)))
            var bordo = Path()
            bordo.move(to: c)
            bordo.addLine(to: CGPoint(x: c.x + raggio, y: c.y))
            ctx.stroke(bordo, with: .color(R.bordoFascio), lineWidth: R.spessoreBordoFascio)
        }
        .frame(width: 2 * raggio, height: 2 * raggio)
        Group {
            if fermo || !vivo {
                tela.rotationEffect(.degrees(R.angoloFermo))
            } else {
                tela.modifier(GiroFascio())
            }
        }
        .position(centro)
    }
}

/// Il giro infinito del fascio: parte alla comparsa e finisce con il modificatore, così fermare il fascio (radar che
/// non si vede) toglie davvero l'animazione infinita, e rivederlo la fa ripartire.
private struct GiroFascio: ViewModifier {
    @State private var gira = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(gira ? 270 : -90))
            .onAppear { withAnimation(Tema.Apple.Posizioni.Radar.Moto.animazioneFascio) { gira = true } }
    }
}

/// L'anello arancio che pulsa (1,9 s): da scala 0,75 opacità 0,95 a scala 1,7 opacità 0, all'infinito.
private struct AnelloPulsante: View {
    @State private var fuori = false
    private typealias M = Tema.Apple.Posizioni.Radar.Moto
    private typealias R = Tema.Apple.Posizioni.Radar

    var body: some View {
        ZStack {
            Circle().stroke(R.arancioRadar, lineWidth: R.spessoreAnello)
            Circle().stroke(R.arancioRadar, lineWidth: R.spessoreAnello)
                .scaleEffect(fuori ? M.scalaPulsoA : M.scalaPulsoDa)
                .opacity(fuori ? 0 : M.opacitaPulso)
        }
        .onAppear { withAnimation(M.animazionePulso) { fuori = true } }
    }
}

/// Dove sta ogni cosa sul radar, per una misura data.
struct GeometriaRadar {
    let centro: CGPoint
    let raggio: CGFloat
    let settori: Int
    let indiceModello: [String: Int]
    /// Le posizioni già calcolate (con il passo che allontana i punti sovrapposti).
    let posizioni: [String: CGPoint]
    let destinazioni: [String: CGPoint]
    /// I clienti disegnati come avatar con le iniziali (fuori tolleranza, fino a `massimoAvatar`).
    let conAvatar: Set<String>
    private let scala: Double
    private let voci: [VoceRadar]

    private typealias R = Tema.Apple.Posizioni.Radar

    init(dimensione: CGSize, radar: RadarPortafoglio) {
        let lato = min(dimensione.width, dimensione.height)
        centro = CGPoint(x: dimensione.width / 2, y: dimensione.height / 2)
        raggio = lato * R.quotaRaggio
        scala = R.scalaPunti
        settori = max(1, radar.modelli.count)
        indiceModello = Dictionary(radar.modelli.enumerated().map { ($1.id, $0) }, uniquingKeysWith: { a, _ in a })
        voci = radar.voci
        let fuori = radar.voci.filter(\.fuori)
        conAvatar = fuori.count <= R.massimoAvatar ? Set(fuori.map(\.id)) : []
        var pos: [String: CGPoint] = [:]
        var dest: [String: CGPoint] = [:]
        let ampiezza = 2 * Double.pi / Double(max(1, radar.modelli.count))
        let margine = min(0.25, ampiezza * 0.15)
        var occupati: [CGPoint] = []
        // I punti più lontani prima: sono quelli con il nome
        for v in radar.voci.sorted(by: { $0.distanza > $1.distanza }) {
            let i = indiceModello[v.modello.id] ?? 0
            let inizio = -Double.pi / 2 + Double(i) * ampiezza
            let r = CGFloat(min(v.distanza, scala) / scala) * raggio
            var frazione = v.angoloNelSettore
            var p = CGPoint.zero
            // Un passo fisso lungo il settore se il punto cade su uno già messo (al massimo 8 tentativi)
            for tentativo in 0..<8 {
                let a = inizio + margine + frazione * max(0, ampiezza - 2 * margine)
                p = CGPoint(x: centro.x + r * CGFloat(cos(a)), y: centro.y + r * CGFloat(sin(a)))
                let minimo = conAvatar.contains(v.id) ? 2 * R.puntoGrande : 2 * R.puntoPiccolo + 2
                if r < 1 || !occupati.contains(where: { hypot($0.x - p.x, $0.y - p.y) < minimo }) || tentativo == 7 { break }
                frazione = (frazione + 0.37).truncatingRemainder(dividingBy: 1)
            }
            occupati.append(p)
            pos[v.id] = p
            // Con la proposta il punto andrebbe verso il modello: 1,5 punti dal centro, sulla stessa direzione
            let rd = CGFloat(1.5 / scala) * raggio
            let a = atan2(Double(p.y - centro.y), Double(p.x - centro.x))
            dest[v.id] = CGPoint(x: centro.x + rd * CGFloat(cos(a)), y: centro.y + rd * CGFloat(sin(a)))
        }
        posizioni = pos
        destinazioni = dest
    }

    func raggio(punti: Double) -> CGFloat { CGFloat(min(punti, scala) / scala) * raggio }
    func cerchio(_ r: CGFloat) -> CGRect { cerchio(r, attorno: centro) }
    func cerchio(_ r: CGFloat, attorno p: CGPoint) -> CGRect { CGRect(x: p.x - r, y: p.y - r, width: 2 * r, height: 2 * r) }
    func posizione(_ v: VoceRadar) -> CGPoint { posizioni[v.id] ?? centro }
    func destinazione(_ v: VoceRadar) -> CGPoint { destinazioni[v.id] ?? centro }
    func inizioSettore(_ i: Int) -> Double { -Double.pi / 2 + Double(i) * 2 * .pi / Double(settori) }
    func metaSettore(_ i: Int) -> Double { inizioSettore(i) + .pi / Double(settori) }
    func posizione(angolo a: Double, raggio r: CGFloat) -> CGPoint {
        CGPoint(x: centro.x + r * CGFloat(cos(a)), y: centro.y + r * CGFloat(sin(a)))
    }

    /// Il punto più vicino entro la distanza del clic (avatar o pallino).
    func punto(vicinoA p: CGPoint) -> VoceRadar? {
        var migliore: (VoceRadar, CGFloat)?
        for v in voci {
            let q = posizione(v)
            let d = hypot(q.x - p.x, q.y - p.y)
            let limite = (conAvatar.contains(v.id) ? R.puntoGrande : R.puntoPiccolo) + R.tolleranzaClic / 2
            if d <= limite, d < (migliore?.1 ?? .infinity) { migliore = (v, d) }
        }
        return migliore?.0
    }
}

// MARK: - Le card della colonna

private struct CardModelliRadar: View {
    let modelli: [PortafoglioModello]
    let apri: (String) -> Void
    private typealias K = Tema.Apple.Posizioni.Radar.Colonna

    var body: some View {
        VStack(alignment: .leading, spacing: K.fraModelli) {
            Text("I tuoi portafogli modello")
                .carattereApple(Tema.Apple.Carattere.etichetta)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
            if modelli.isEmpty {
                Text("Nessun modello: li scrivi tu, con i pesi delle quattro classi.")
                    .carattereApple(Tema.Apple.Carattere.secondario)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
            }
            ForEach(Array(modelli.enumerated()), id: \.element.id) { i, m in
                #if os(macOS)
                // Migliorie d'uso 40: una riga sola, il nome nel colore del modello e la barra; i pesi nell'aiuto
                HStack(spacing: K.spazioNomeBarra) {
                    Text(m.nome)
                        .carattereApple(K.nomeModello)
                        .foregroundColor(Tema.Apple.Posizioni.Radar.colore(m.colore))
                        .lineLimit(1)
                        .frame(width: K.larghezzaNomeModello, alignment: .leading)
                    barra(m, indice: i)
                }
                .contentShape(Rectangle())
                .onTapGesture { apri(m.id) }
                .help(TestiRadar.aiutoModello(m))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(m.nome): \(TestiRadar.pesi(m.pesi))"))
                .accessibilityAddTraits(.isButton)
                #else
                VStack(alignment: .leading, spacing: K.sottoNome) {
                    HStack {
                        Text(m.nome)
                            .carattereApple(K.nomeModello)
                            .foregroundColor(Tema.Apple.Posizioni.Radar.colore(m.colore))
                        Spacer(minLength: 8)
                        Text(TestiRadar.pesi(m.pesi))
                            .carattereApple(K.pesi)
                            .foregroundColor(Tema.Apple.Colore.inchiostro2)
                            .monospacedDigit()
                    }
                    barra(m, indice: i)
                }
                .contentShape(Rectangle())
                .onTapGesture { apri(m.id) }
                .help("Apri il modello in Impostazioni › Portafogli modello")
                #endif
            }
            if !modelli.isEmpty {
                #if os(macOS)
                LeggendaClassiRadar()
                    .padding(.top, K.sopraLeggenda)
                #else
                Text(TestiRadar.leggendaClassi)
                    .carattereApple(Tema.Apple.Carattere.secondario)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                #endif
            }
        }
        #if os(macOS)
        .padding(K.paddingModelli)
        #else
        .padding(K.padding)
        #endif
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
    }

    private func barra(_ m: PortafoglioModello, indice i: Int) -> some View {
        BarraPienaSegmenti(pezzi: ComposizioneInvestimenti360.Classe.allCases.map {
            PezzoBarraPiena(id: $0.rawValue, peso: m.pesi[$0], colore: Tema.Apple.Posizioni.Radar.colore($0))
        }, indice: i * 4, altezza: K.altezzaBarra, spazio: K.spazioBarra, raggioPezzo: K.raggioBarra,
           raggioContenitore: K.raggioBarra)
    }
}

#if os(macOS)
/// La legenda a colori delle quattro classi (migliorie d'uso 40): quadratino 9×9 nel colore della classe e il nome,
/// a capo se la colonna è stretta.
private struct LeggendaClassiRadar: View {
    private typealias K = Tema.Apple.Posizioni.Radar.Colonna

    var body: some View {
        FlussoEtichette(spazio: K.spazioVociLeggenda) {
            ForEach(ComposizioneInvestimenti360.Classe.allCases, id: \.self) { c in
                HStack(spacing: K.spazioQuadratino) {
                    RoundedRectangle(cornerRadius: K.raggioLeggenda, style: .continuous)
                        .fill(Tema.Apple.Posizioni.Radar.colore(c))
                        .frame(width: K.quadratinoLeggenda, height: K.quadratinoLeggenda)
                    Text(TestiRadar.nomeClasse(c))
                        .carattereApple(K.leggenda)
                        .foregroundColor(K.coloreLeggenda)
                        .lineLimit(1)
                        .fixedSize()
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// La card «chi» (migliorie d'uso 40, `#radChi` del template): quanti sono fuori tolleranza su quanti, che cosa vuol
/// dire «punti», l'elenco di tutti i fuori dal più lontano (la riga accende il suo punto sulla tela, il clic apre il
/// dettaglio dal punto) e il pulsante che prepara le proposte. Dopo il pulsante il numero dice quanti resterebbero
/// fuori accettando le proposte; i punti restano al loro posto con il trattino (decisione 2 di «Luce»).
private struct CardChiRadar: View {
    let radar: RadarPortafoglio
    let puntatore: PuntatoreRadar
    let solaLettura: Bool
    /// Con la colonna accanto alla tela la card occupa l'altezza che resta e l'elenco scorre dentro.
    let riempie: Bool
    let riequilibra: () -> Void
    let assegna: () -> Void
    let apri: (String) -> Void

    private typealias K = Tema.Apple.Posizioni.Radar.Colonna

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if radar.modelli.isEmpty {
                // Senza modelli l'invito sta sopra la tela: qui solo il pulsante
                Button("Imposta i modelli", action: assegna)
                    .buttonStyle(StilePulsanteApple(.principale, grande: true))
                    .frame(maxWidth: .infinity)
            } else {
                testa
                elencoContenitore
                piede
            }
        }
        .padding(K.paddingChi)
        .frame(maxWidth: .infinity, maxHeight: riempie ? .infinity : nil, alignment: .topLeading)
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
    }

    private var conProposte: Bool { radar.fuori.contains(where: \.bozzaPronta) }

    @ViewBuilder private var testa: some View {
        let numero = conProposte ? radar.daRiequilibrare.count : radar.fuori.count
        HStack(alignment: .firstTextBaseline, spacing: K.spazioTestaChi) {
            NumeroCheConta(Double(numero), formato: .intero)
                .carattereApple(K.numeroChi)
                .foregroundColor(numero == 0 ? K.coloreTutti : K.coloreFuori)
            Text(TestiRadar.etichettaFuori(conProposte: conProposte))
                .carattereApple(K.etichettaChi)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 6)
            Text(TestiRadar.suSeguiti(radar.voci.count))
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
                .lineLimit(1)
                .help(TestiRadar.previdenzaEsclusa)
        }
        Text(spiegazione)
            .carattereApple(K.spiegazioneChi)
            .foregroundColor(Tema.Apple.Colore.inchiostro2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, K.sottoSpiegazioneChi)
    }

    private var spiegazione: String {
        if conProposte && radar.daRiequilibrare.isEmpty { return TestiRadar.dopoLeProposte }
        return TestiRadar.cosaSonoIPunti(radar.tolleranzaGenerale) ?? TestiRadar.senzaTolleranza
    }

    @ViewBuilder private var elencoContenitore: some View {
        if riempie {
            ScrollView(.vertical, showsIndicators: false) { elenco }
                .frame(maxHeight: .infinity, alignment: .top)
        } else {
            elenco
        }
    }

    /// Tutti i fuori tolleranza dal più lontano: pigro, per i 200 clienti di `--prova-carico`.
    private var elenco: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(radar.fuori) { v in
                RigaChiRadar(voce: v, puntatore: puntatore) { apri(v.id) }
            }
        }
    }

    @ViewBuilder private var piede: some View {
        let fuori = radar.fuori.count
        let daFare = radar.daRiequilibrare.count
        Button(action: riequilibra) {
            Text(fuori == 0 ? TestiRadar.tuttiDentro
                 : daFare == 0 ? TestiRadar.proposteFatte
                 : TestiRadar.pulsanteRiequilibra(daFare))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(StilePulsanteApple(.principale, grande: true))
        .disabled(daFare == 0 || solaLettura)
        .padding(.top, K.spazioPulsanteChi)
        Text(TestiRadar.spiegaRiequilibra)
            .carattereApple(Tema.Apple.Carattere.secondario)
            .foregroundColor(Tema.Apple.Colore.inchiostro2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, K.spazioSottoPulsante)
        if !radar.senzaModello.isEmpty {
            Button(TestiRadar.senzaModello(radar.senzaModello.count) + " ›", action: assegna)
                .buttonStyle(.plain)
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(Tema.Apple.Colore.accento)
                .padding(.top, K.spazioSottoPulsante)
        }
    }
}

/// Una riga della card «chi»: avatar, nome e modello, capsula dei punti (o «Proposta pronta»), «›». Passandoci sopra
/// il suo punto si accende sulla tela: la riga scrive il puntatore ma non lo legge, così non si ridisegna altro.
private struct RigaChiRadar: View {
    let voce: VoceRadar
    let puntatore: PuntatoreRadar
    let apri: () -> Void

    @State private var sopra = false
    private typealias K = Tema.Apple.Posizioni.Radar.Colonna

    var body: some View {
        let v = voce
        HStack(spacing: K.spazioRigaChi) {
            AvatarCliente(iniziali: v.iniziali, tinta: v.tinta.colori, lato: K.avatarChi)
            (Text(v.nome).bold().foregroundColor(Tema.Apple.Colore.inchiostro)
                + Text(" · \(v.modello.nome)").foregroundColor(Tema.Apple.Colore.inchiostro2))
                .carattereApple(Tema.Apple.Carattere.voceLista)
                .lineLimit(1)
            Spacer(minLength: 6)
            if v.bozzaPronta {
                CapsulaStatoApple(testo: TestiRadar.propostaPronta, tono: .ok)
            } else {
                CapsulaStatoApple(testo: TestiRadar.puntiConNome(v.distanza), tono: .attenzione)
            }
            Text("›")
                .carattereApple(Tema.Apple.Carattere.voceLista)
                .foregroundColor(K.freccia)
        }
        .padding(K.rigaChi)
        .background {
            RoundedRectangle(cornerRadius: K.raggioRiga, style: .continuous)
                .fill(sopra ? K.fondoRigaSopra : Color.clear)
        }
        .overlay(alignment: .bottom) { Rectangle().fill(Tema.Apple.Colore.separatore).frame(height: 1) }
        .contentShape(Rectangle())
        .onTapGesture(perform: apri)
        .onHover { dentro in
            sopra = dentro
            if dentro {
                puntatore.daRiga = true
                puntatore.sopra = v.id
            } else if puntatore.sopra == v.id {
                puntatore.sopra = nil
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(TestiRadar.accessibilita(v))
        .accessibilityAddTraits(.isButton)
    }
}
#endif

#if !os(macOS)
private struct CardConteggioRadar: View {
    let radar: RadarPortafoglio
    let solaLettura: Bool
    let riequilibra: () -> Void
    let assegna: () -> Void
    private typealias K = Tema.Apple.Posizioni.Radar.Colonna

    var body: some View {
        let fuori = radar.fuori.count
        let pronte = radar.fuori.filter(\.bozzaPronta).count
        let daFare = radar.daRiequilibrare.count
        VStack(alignment: .leading, spacing: K.spazioPulsante) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    NumeroCheConta(Double(fuori), formato: .intero)
                        .carattereApple(K.fuori)
                        .foregroundColor(fuori == 0 ? K.coloreTutti : K.coloreFuori)
                    Text(pronte > 0 ? TestiRadar.bozzePronte(pronte) : TestiRadar.fuoriTolleranza(radar.tolleranzaGenerale))
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(pronte > 0 ? Tema.Apple.Posizioni.Radar.verdeRadar : Tema.Apple.Colore.inchiostro2)
                }
                Spacer(minLength: 8)
                VStack(alignment: .trailing, spacing: 2) {
                    NumeroCheConta(Double(radar.voci.count), formato: .intero, indice: 1)
                        .carattereApple(K.totale)
                        .foregroundColor(Tema.Apple.Colore.inchiostro)
                    Text("sul radar")
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(Tema.Apple.Colore.inchiostro2)
                }
            }
            Button(action: riequilibra) {
                Text(titolo(fuori: fuori, daFare: daFare, pronte: pronte))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(StilePulsanteApple(.principale, grande: true))
            .disabled(daFare == 0 || solaLettura)
            Text(TestiRadar.spiegaRiequilibraClienti)
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
                .fixedSize(horizontal: false, vertical: true)
            if !radar.senzaModello.isEmpty {
                Button(TestiRadar.senzaModello(radar.senzaModello.count) + " ›", action: assegna)
                    .buttonStyle(.plain)
                    .carattereApple(Tema.Apple.Carattere.secondario)
                    .foregroundColor(Tema.Apple.Colore.accento)
            }
        }
        .padding(K.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
    }

    private func titolo(fuori: Int, daFare: Int, pronte: Int) -> String {
        if fuori == 0 { return "Tutti entro la tolleranza" }
        if daFare == 0 { return "✓ " + TestiRadar.bozzePronte(pronte) }
        return TestiRadar.riequilibraClienti(daFare)
    }
}

private struct CardLontaniRadar: View {
    let voci: [VoceRadar]
    let apri: (String) -> Void
    private typealias K = Tema.Apple.Posizioni.Radar.Colonna

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("I più lontani dal modello")
                .carattereApple(Tema.Apple.Carattere.etichetta)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
                .padding(.bottom, 6)
            ForEach(Array(voci.enumerated()), id: \.element.id) { i, v in
                HStack(spacing: 10) {
                    AvatarCliente(iniziali: v.iniziali, tinta: v.tinta.colori, lato: K.avatarLontani)
                    (Text(v.nome).foregroundColor(Tema.Apple.Colore.inchiostro)
                        + Text(" · \(v.modello.nome)").foregroundColor(Tema.Apple.Colore.inchiostro2))
                        .carattereApple(Tema.Apple.Carattere.voceLista)
                        .lineLimit(1)
                    Spacer(minLength: 6)
                    BarraPiena(frazione: v.distanza / Tema.Apple.Posizioni.Radar.scalaPunti, colore: Tema.Apple.Colore.arancio,
                               indice: i, altezza: K.barraLontani.height)
                        .frame(width: K.barraLontani.width)
                    Text(TestiRadar.punti(v.distanza))
                        .carattereApple(K.distanzaLontani)
                        .foregroundColor(Tema.Apple.Colore.inchiostro)
                        .frame(width: K.colonnaDistanza, alignment: .trailing)
                }
                .padding(K.rigaLontani)
                .overlay(alignment: .top) { if i > 0 { Rectangle().fill(Tema.Apple.Colore.separatore).frame(height: 1) } }
                .contentShape(Rectangle())
                .onTapGesture { apri(v.id) }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(TestiRadar.accessibilita(v))
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding(K.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
    }
}

#endif

// MARK: - Il dettaglio di un cliente

struct DettaglioRadar: View {
    let voce: VoceRadar
    let solaLettura: Bool
    let prepara: () -> Void
    let dossier: () -> Void

    private typealias D = Tema.Apple.Posizioni.Radar.Dettaglio
    private typealias R = Tema.Apple.Posizioni.Radar

    var body: some View {
        let v = voce
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                AvatarCliente(iniziali: v.iniziali, tinta: v.tinta.colori, lato: D.avatar)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Modello \(v.modello.nome)" + (v.stimata ? " · composizione stimata" : ""))
                        .carattereApple(Tema.Apple.Carattere.etichetta)
                        .foregroundColor(R.colore(v.modello.colore))
                    Text(v.nome)
                        .carattereApple(D.nome)
                        .foregroundColor(Tema.Apple.Colore.inchiostro)
                        .lineLimit(1)
                }
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(TestiRadar.puntiConNome(v.distanza))
                        .carattereApple(D.distanza)
                        .foregroundColor(v.fuori ? Tema.Apple.Colore.arancioTesto : Tema.Apple.Colore.verde)
                    Text("di distanza dal modello")
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(Tema.Apple.Colore.inchiostro2)
                }
                .padding(.trailing, D.margineChiudi - Tema.Apple.Misura.Padding.dettaglio.trailing)
            }
            VStack(alignment: .leading, spacing: D.spazioRighe) {
                ForEach(Array(ComposizioneInvestimenti360.Classe.allCases.enumerated()), id: \.element) { i, c in
                    RigaClasseRadar(classe: c, oggi: v.quote[c], modello: v.modello.pesi[c],
                                    canali: v.perCanale[c] ?? [:], indice: i)
                }
                Text(TestiRadar.barraLinea)
                    .carattereApple(Tema.Apple.Carattere.secondario)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
            }
            .padding(.top, D.sopraRighe)
            VStack(alignment: .leading, spacing: 6) {
                Text("Il riequilibrio proposto")
                    .carattereApple(Tema.Apple.Carattere.etichetta)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                Text(TestiRadar.riequilibrio(v))
                    .carattereApple(Tema.Apple.Carattere.corpo)
                    .foregroundColor(Tema.Apple.Colore.inchiostro)
                    .fixedSize(horizontal: false, vertical: true)
                if v.oltreProfilo {
                    Text(TestiRadar.oltreProfilo(v))
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(Tema.Apple.Colore.scadenza)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(Tema.Apple.Misura.Padding.tile)
            .frame(maxWidth: .infinity, alignment: .leading)
            .superficieApple(Tema.Apple.Superficie.tile)
            .padding(.top, 18)
            Spacer(minLength: 12)
            HStack(spacing: 10) {
                Button(v.bozzaPronta ? "✓ Proposta pronta" : "Prepara la proposta", action: prepara)
                    .buttonStyle(StilePulsanteApple(.principale, grande: true))
                    .disabled(v.bozzaPronta || v.spostamenti.isEmpty || solaLettura)
                #if os(macOS)
                // Migliorie d'uso 40: le Posizioni del cliente sulla coerenza con il profilo
                Button(TestiRadar.apriPosizioni(v.nome), action: dossier)
                    .buttonStyle(StilePulsanteApple(.secondaria, grande: true))
                #else
                Button("Apri il dossier", action: dossier)
                    .buttonStyle(StilePulsanteApple(.secondaria, grande: true))
                #endif
            }
        }
        .padding(Tema.Apple.Misura.Padding.dettaglio)
        .frame(width: D.misura.width, height: D.misura.height, alignment: .topLeading)
    }
}

/// Una classe nel dettaglio: nome, binario con la barra di oggi divisa per canale e la linea del modello, valori.
private struct RigaClasseRadar: View {
    let classe: ComposizioneInvestimenti360.Classe
    let oggi: Double
    let modello: Double
    let canali: [Canale: Double]
    let indice: Int

    private typealias D = Tema.Apple.Posizioni.Radar.Dettaglio

    var body: some View {
        HStack(spacing: 12) {
            Text(TestiRadar.nomeClasse(classe))
                .carattereApple(Tema.Apple.Carattere.corpo)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
                .frame(width: D.colonnaClasse, alignment: .leading)
            GeometryReader { g in
                let w = g.size.width
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: D.raggioBinario, style: .continuous)
                        .fill(Tema.Apple.Colore.binario)
                        .frame(height: D.binario)
                    BarraPiena(frazione: oggi / 100, colore: Tema.Apple.Posizioni.Radar.colore(classe), indice: indice,
                               altezza: D.binario, raggio: D.raggioBinario, binario: nil)
                        .frame(width: w)
                    Rectangle()
                        .fill(D.coloreLinea)
                        .frame(width: D.lineaModello, height: D.binario + 2 * D.sporgenza)
                        .offset(x: max(0, min(w - D.lineaModello, w * modello / 100 - D.lineaModello / 2)))
                }
                .frame(height: D.binario + 2 * D.sporgenza)
            }
            .frame(height: D.binario + 2 * D.sporgenza)
            (Text("\(TestiRadar.punti(oggi))%").bold().foregroundColor(Tema.Apple.Colore.inchiostro)
                + Text(" / \(TestiRadar.punti(modello))%").foregroundColor(Tema.Apple.Colore.inchiostro2))
                .carattereApple(Tema.Apple.Carattere.corpo)
                .monospacedDigit()
                .frame(width: D.colonnaValori, alignment: .trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(TestiRadar.nomeClasse(classe)): oggi \(TestiRadar.punti(oggi)) per cento, modello \(TestiRadar.punti(modello)) per cento")
    }
}

// MARK: - Azioni

extension StatoShell {
    /// Prepara le bozze di riequilibrio per i clienti dati (decisione 2): proposte in bozza, una per canale, con gli
    /// spostamenti nelle note. Niente si esegue: l'avviso dice dove sono.
    /// Restituisce le bozze create (per «Prepara la proposta», che apre la prima).
    @discardableResult
    func preparaBozzeRiequilibrio(_ voci: [VoceRadar]) -> [Posizione] {
        guard !solaLettura, !voci.isEmpty else { return [] }
        let oggi = Date()
        var n = 0
        var create: [Posizione] = []
        for v in voci where !v.bozzaPronta {
            for b in MotoreRadar.bozze(v, oggi: oggi) {
                salvaPosizione(b)
                create.append(b)
            }
            n += 1
        }
        guard n > 0 else { return create }
        mostraAvviso(TestiRadar.avvisoBozze(n))
        return create
    }

    /// Impostazioni › Portafogli modello.
    func apriImpostazioniModelli() {
        schedaImpostazioni = .portafogliModello
        apri(.impostazioni)
    }

    /// Posizioni › Radar (dal pannello Novità e dalle istantanee). In modalità cliente non si apre: mostra tutti i
    /// clienti con i nomi.
    func apriRadar() {
        guard !inModoCliente else {
            mostraAvviso("In modalità cliente il radar non si apre: mostra tutti i clienti.")
            return
        }
        posizioneInDettaglio = nil
        portafoglio = true
        provaFuoco.vista = .radar
        apriApp(.posizioni)
    }

    #if os(macOS)
    /// «Apri le posizioni di …» dal dettaglio del radar (migliorie d'uso 40): le Posizioni del cliente sulla vista
    /// «Coerenza con il profilo».
    func apriPosizioniDalRadar(_ id: String) {
        // Scegliere il cliente lascia «Tutti i clienti» (sul Mac `portafoglio` è la stessa scelta della barra)
        scegliCliente(id)
        posizioneInDettaglio = nil
        ancoraPosizioni = "coerenza"
        apri(.posizioni)
    }
    #endif

    /// Il dossier del cliente, dal doppio clic su un punto del radar.
    func apriClienteDalRadar(_ id: String) {
        clienteAttivoId = id
        schedaCliente = .panoramica
        apri(.clienti)
    }
}
