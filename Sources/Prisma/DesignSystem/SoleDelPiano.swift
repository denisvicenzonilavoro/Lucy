import SwiftUI

// Il sole del piano (decisione dell'utente del 25 novembre 2026): nella Sala e nella realtà aumentata il disco d'oro di
// Lucy (`GeometriaLucy`, `Tema.Marca.oro`) prende il posto del prisma di luce, che rimandava al vecchio Prisma.
// - Il disco si riempie di luce dal centro: l'area illuminata è la parte del piano coperta (`SolePiano.luce`).
// - Un raggio sottile per obiettivo, dal bordo verso fuori: lungo e intenso quanto l'obiettivo è coperto
//   (`MotoreSole.lunghezza`, `MotoreSole.intensita`); sotto ogni raggio la traccia tenue di ciò che manca.
// - L'alone intorno si accende con le leve del cliente (`accensione`, per esempio il patrimonio dell'anno del cursore).
// Le cifre sono di `MotoreSole` (copertura degli obiettivi di `MotoreObiettivo`), mai inventate. Movimento: i raggi si
// disegnano e il disco si riempie con le animazioni di SwiftUI (niente Timer); con «Riduci movimento», nelle istantanee
// e nei fermo-immagine (`animato: false`) tutto compare subito nello stato finale. Solo forme e gradienti: niente
// Canvas né filtri, così esce uguale nelle istantanee, nei PDF e nello scatto della realtà aumentata.

extension Tema {
    /// I gettoni del sole del piano e delle esperienze della Sala nello stesso stile (titoli serif, carta, oro).
    enum Sole {
        /// L'oro del marchio (segue l'aspetto), e quello fisso per i fogli chiari.
        static let oro = Tema.Marca.oro
        static let oroFisso = Tema.Marca.oroChiaro
        /// Il centro caldo della luce nel disco.
        static let nucleo = Color(hex: "#FFF1C9")
        /// Raggio del disco rispetto al lato della vista.
        static let quotaDisco: CGFloat = 0.2
        /// Distanza fra il bordo del disco e l'inizio dei raggi, e lunghezza massima dei raggi (rispetto al lato).
        static let staccoRaggi: CGFloat = 0.04
        static let quotaRaggi: CGFloat = 0.21
        /// Spessore dei raggi e del bordo del disco (rispetto al lato), con un minimo in punti.
        static let spessoreRaggio: CGFloat = 0.011
        static let spessoreBordo: CGFloat = 0.007
        static let spessoreMinimo: CGFloat = 1
        /// La traccia di ciò che manca sotto ogni raggio.
        static let opacitaTraccia: Double = 0.13
        /// Il disco spento (nessuna luce) e la parte non ancora illuminata.
        static let opacitaDisco: Double = 0.16
        /// L'alone: raggio rispetto al disco, opacità piena.
        static let alone: CGFloat = 2.1
        static let opacitaAlone: Double = 0.36
        /// Quanto conta l'accensione (le leve del cliente) sull'alone: 1 − peso con le leve a zero.
        static let pesoAccensione: Double = 0.5
        /// Gli altri raggi quando uno è scelto.
        static let opacitaAltri: Double = 0.3
        /// Il tempo dell'accensione (secondi del tema, al ritmo dell'app) e del cambio.
        static let durata: Double = 1.3
        static let durataCambio: Double = 0.6

        /// Sul palco della Sala: il raggio del disco rispetto al raggio della scena (`GeometriaLuce.raggio`).
        static let quotaDiscoPalco: CGFloat = 0.62

        // MARK: Il sole sul tavolo (fermo-immagine e scatto della realtà aumentata)

        /// Punti per unità rispetto al lato corto, e il centro del disco nello schermo (frazioni).
        static let quotaScalaFermo: CGFloat = 0.34
        static let centroFermo = CGPoint(x: 0.5, y: 0.6)
        /// Quanto il colore della classe vela l'oro di uno strato, e quanto è più scuro il fianco.
        static let velaturaClasse: Double = 0.38
        static let scuroFianco: Double = 0.16

        /// Il sole in RealityKit (unità della scena; il raggio della pila è `MotoreRealtaAumentata.raggioDisco`).
        enum Realta {
            /// Il disco del sole appena più largo della pila, spesso 0,02 unità.
            static let quotaDisco: Float = 1.02
            static let spessore: Float = 0.02
            /// Il bagliore: un piano appena sopra il disco, largo 2,2 volte il disco.
            static let sopra: Float = 0.002
            static let bagliore: Float = 2.2
            static let opacitaBagliore: Float = 0.6
            /// I raggi: staccati dal bordo, lunghi al più 0,9 raggi della pila, sottili.
            static let stacco: Float = 0.08
            static let quotaRaggi: Float = 0.9
            static let spessoreRaggio: Float = 0.006
            static let larghezzaRaggio: Float = 0.018
            /// L'oro: metallico, poco ruvido, con una luce propria che cresce con gli obiettivi coperti.
            static let metallico: Float = 0.85
            static let ruvidita: Float = 0.3
            static let lucePropriaMinima: Float = 0.15
            static let lucePropria: Float = 1.1
        }

        static var accensioneAnimazione: Animation { .easeOut(duration: Tema.Apple.Moto.tempo(durata)) }
        static var cambioAnimazione: Animation { .easeInOut(duration: Tema.Apple.Moto.tempo(durataCambio)) }

        // MARK: Le esperienze nello stile del sole (Disegna il tuo futuro, Una giornata della pensione)

        /// Occhiello in SF Mono maiuscolo, titolo e cifre in New York, testo in SF Pro, note in corsivo.
        static let occhiello = TestoCarta(dimensione: 11, peso: .medium, disegno: .monospaced)
        static let tracciaOcchiello: CGFloat = 1.2
        static let titolo = TestoCarta(dimensione: 30, peso: .medium, disegno: .serif)
        static let titoloMedio = TestoCarta(dimensione: 24, peso: .medium, disegno: .serif)
        static let cifra = TestoCarta(dimensione: 46, peso: .medium, disegno: .serif, cifre: true)
        static let cifraMedia = TestoCarta(dimensione: 28, peso: .medium, disegno: .serif, cifre: true)
        static let testo = TestoCarta(dimensione: 14)
        static let frase = TestoCarta(dimensione: 20, peso: .medium, disegno: .serif)
        static let etichetta = TestoCarta(dimensione: 10.5, peso: .medium, disegno: .monospaced)
        static let nota = TestoCarta(dimensione: 12, corsivo: true)
        /// La sottolineatura dorata sotto il titolo.
        static let sottolineatura = CGSize(width: 46, height: 2.5)
        static let sopraSottolineatura: CGFloat = 8
        /// Margini generosi e spazi della testata.
        static let margine: CGFloat = 36
        static let spazioTestata: CGFloat = 6
        static let spazioBlocchi: CGFloat = 22
        /// Il sole nelle testate delle esperienze.
        static let latoTestata: CGFloat = 150
        static let latoColonna: CGFloat = 132
        /// Lo spazio in più ai lati della giornata della pensione, e la larghezza della frase accanto al sole.
        static let margineLato: CGFloat = 14
        static let larghezzaFrase: CGFloat = 220
        /// I colori di carta (seguono l'aspetto).
        static var inchiostro: Color { TemaCarta.Colore.inchiostroD }
        static var inchiostro2: Color { TemaCarta.Colore.inchiostro2D }
        static var matita: Color { TemaCarta.Colore.matitaD }
        static var oroTesto: Color { TemaCarta.Colore.oroTestoD }
        static var filo: Color { TemaCarta.Colore.filoD }
        static var foglio: Color { TemaCarta.Colore.foglioD }
    }
}

/// Il sole del piano: il disco d'oro che si riempie di luce e un raggio per obiettivo. Quadrato al centro dello spazio.
struct SoleDelPiano: View {
    let sole: SolePiano
    /// 0…1: quanto si accende l'alone con le leve del cliente (1 = pieno; per esempio il patrimonio dell'anno sul massimo).
    var accensione: Double = 1
    /// Il raggio evidenziato (id): gli altri si attenuano.
    var scelto: String? = nil
    var oro: Color = Tema.Sole.oro
    /// false: fermo-immagine (scatto, PDF, immagini date al cliente), sempre nello stato finale.
    var animato = true

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var acceso = false

    private typealias S = Tema.Sole

    private var fermo: Bool { !animato || calmo || istantanea || statoFinale }
    /// 0 prima dell'accensione, 1 dopo (subito 1 se fermo).
    private var avanzamento: Double { fermo || acceso ? 1 : 0 }

    var body: some View {
        let luce = MotoreSole.limita(sole.luce) * avanzamento
        let accesa = 1 - S.pesoAccensione + S.pesoAccensione * MotoreSole.limita(accensione)
        let n = sole.raggi.count
        GeometryReader { g in
            let lato = min(g.size.width, g.size.height)
            let disco = S.quotaDisco * lato
            let inizio = S.quotaDisco + S.staccoRaggi
            ZStack {
                // L'alone che si accende con la luce del piano e con le leve
                DiscoSole(quota: S.quotaDisco * S.alone)
                    .fill(RadialGradient(colors: [oro.opacity(S.opacitaAlone * (0.25 + 0.75 * luce) * accesa), oro.opacity(0)],
                                         center: .center, startRadius: disco * 0.9, endRadius: disco * S.alone))
                // Le tracce di ciò che manca, poi i raggi
                ForEach(Array(sole.raggi.enumerated()), id: \.element.id) { i, r in
                    let angolo = MotoreSole.angolo(i, di: n)
                    RaggioSoleForma(angolo: angolo, da: inizio, a: inizio + S.quotaRaggi)
                        .stroke(oro.opacity(S.opacitaTraccia), style: tratto(S.spessoreRaggio * 0.6, lato))
                    RaggioSoleForma(angolo: angolo, da: inizio,
                                    a: inizio + S.quotaRaggi * CGFloat(MotoreSole.lunghezza(r.copertura)))
                        .trim(from: 0, to: CGFloat(avanzamento))
                        .stroke(oro.opacity(MotoreSole.intensita(r.copertura) * (scelto == nil || scelto == r.id ? 1 : S.opacitaAltri)),
                                style: tratto(S.spessoreRaggio, lato))
                }
                // Il disco: d'oro tenue, con la luce che lo riempie dal centro (area = parte coperta)
                DiscoSole(quota: S.quotaDisco)
                    .fill(oro.opacity(S.opacitaDisco))
                DiscoSole(quota: S.quotaDisco * CGFloat(luce.squareRoot()))
                    .fill(RadialGradient(colors: [S.nucleo, oro], center: .center, startRadius: 0, endRadius: disco))
                DiscoSole(quota: S.quotaDisco)
                    .stroke(oro, style: tratto(S.spessoreBordo, lato))
            }
            .frame(width: g.size.width, height: g.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .animation(fermo ? (calmo ? Tema.Moto.dissolvenzaCalma : nil) : S.cambioAnimazione, value: sole)
        .animation(fermo ? nil : S.cambioAnimazione, value: accensione)
        .onAppear {
            guard !fermo, !acceso else { return }
            withAnimation(S.accensioneAnimazione) { acceso = true }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(etichetta))
    }

    private func tratto(_ quota: CGFloat, _ lato: CGFloat) -> StrokeStyle {
        StrokeStyle(lineWidth: max(S.spessoreMinimo, quota * lato), lineCap: .round)
    }

    private var etichetta: String {
        if sole.senzaObiettivi { return "Il sole del piano: nessun obiettivo nel dossier" }
        let p = Int((MotoreSole.limita(sole.luce) * 100).rounded())
        return "Il sole del piano: obiettivi coperti al \(p)%, \(sole.raggi.count) raggi"
    }
}

/// Il disco centrato nel riquadro, di raggio `quota` × lato.
struct DiscoSole: Shape {
    var quota: CGFloat

    var animatableData: CGFloat {
        get { quota }
        set { quota = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let lato = min(rect.width, rect.height)
        let r = max(0, quota * lato)
        return Path(ellipseIn: CGRect(x: rect.midX - r, y: rect.midY - r, width: r * 2, height: r * 2))
    }
}

/// Un raggio: il segmento dal centro del riquadro nella direzione `angolo`, da `da` a `a` × lato.
struct RaggioSoleForma: Shape {
    let angolo: Double
    var da: CGFloat
    var a: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(da, a) }
        set { da = newValue.first; a = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        let lato = min(rect.width, rect.height)
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let dx = CGFloat(cos(angolo)), dy = CGFloat(sin(angolo))
        var p = Path()
        p.move(to: CGPoint(x: c.x + dx * da * lato, y: c.y + dy * da * lato))
        p.addLine(to: CGPoint(x: c.x + dx * a * lato, y: c.y + dy * a * lato))
        return p
    }
}

// MARK: - La testata delle esperienze nello stile del sole

/// L'occhiello in SF Mono, il titolo in New York e la sottolineatura dorata (Disegna il tuo futuro, Una giornata della
/// pensione).
struct TestataSole: View {
    let occhiello: String
    let titolo: String
    var titoloGrande = true

    private typealias S = Tema.Sole

    var body: some View {
        VStack(alignment: .leading, spacing: S.spazioTestata) {
            Text(occhiello.uppercased())
                .fontCarta(S.occhiello)
                .tracking(S.tracciaOcchiello)
                .foregroundColor(S.matita)
                .lineLimit(1)
            Text(titolo)
                .fontCarta(titoloGrande ? S.titolo : S.titoloMedio)
                .foregroundColor(S.inchiostro)
                .fixedSize(horizontal: false, vertical: true)
            Capsule()
                .fill(S.oro)
                .frame(width: S.sottolineatura.width, height: S.sottolineatura.height)
                .padding(.top, S.sopraSottolineatura - S.spazioTestata)
        }
        .accessibilityElement(children: .combine)
    }
}
