import SwiftUI
import simd

// La realtà aumentata disegnata in SwiftUI («Luce» giro 16, §2.3.3 e decisione 27): il fermo-immagine delle istantanee,
// il ripiego quando RealityKit non c'è (o Metal manca) e **lo scatto su fondo neutro**, che è sempre questo disegno e mai
// un'immagine della fotocamera (stesso risultato su Mac, iPad e iPhone). Dal 25 novembre 2026 (decisione dell'utente) il
// disegno è il sole del piano: gli strati del patrimonio come dischi d'oro sottili (`MotoreRealtaAumentata.raggioDisco`)
// in assonometria e sopra il disco del sole con i raggi degli obiettivi (`SoleDelPiano`), con l'ombra calda sotto. Niente
// Canvas né filtri: solo forme e gradienti (le istantanee li disegnano sempre).
// Più il foglio dello scatto per i Documenti del cliente (`FoglioScattoRealta`, A4 su carta bianca).

/// Il fondo dietro il sole del piano fermo.
enum FondoCristallo: Equatable {
    /// Il fondo chiaro del palco del Mac.
    case palco
    /// La stanza calda sfocata con il tavolo di legno (schermo dell'iPad del palco, ripiego dell'iPhone e dell'iPad).
    case tavoloLegno
    /// Bianco: lo scatto per il dossier.
    case neutro
}

/// La proiezione della scena: punti (x, y, z in unità) sullo schermo.
struct ProiezioneCristallo {
    let centro: CGPoint
    let scala: CGFloat
    let rotazione: Double
    let schiacciamento: CGFloat

    func punto(_ x: Float, _ y: Float, _ z: Float) -> CGPoint {
        let c = cos(rotazione), s = sin(rotazione)
        let xr = Double(x) * c - Double(z) * s
        let zr = Double(x) * s + Double(z) * c
        return CGPoint(x: centro.x + scala * CGFloat(xr), y: centro.y - scala * CGFloat(y) + scala * schiacciamento * CGFloat(zr))
    }

    /// La profondità di una normale orizzontale dopo la rotazione (> 0: guarda verso chi osserva).
    func versoOsservatore(_ n: SIMD2<Float>) -> Double {
        Double(n.x) * sin(rotazione) + Double(n.y) * cos(rotazione)
    }
}

/// Un poligono chiuso da punti già proiettati.
struct PoligonoCristallo: Shape {
    let punti: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard let primo = punti.first else { return p }
        p.move(to: primo)
        for q in punti.dropFirst() { p.addLine(to: q) }
        p.closeSubpath()
        return p
    }
}

/// Il sole del piano fermo (25 novembre 2026, al posto del cristallo): gli strati del patrimonio come dischi d'oro
/// sottili impilati, velati appena dal colore della loro classe, e sopra il disco del sole con un raggio per obiettivo,
/// disteso sul tavolo in assonometria. Il nome del tipo resta per non cambiare le chiamate (fermo-immagine, ripiego,
/// scatto).
struct CristalloFermo: View {
    let esito: EsitoRealta
    var anno: Int?
    var esploso = false
    var scelto: String?
    var fondo: FondoCristallo = .palco
    /// false: lo scatto e le immagini ferme, sempre nello stato finale.
    var animato = true

    private typealias F = Tema.Apple.RealtaAumentata.Fermo
    private typealias R = Tema.Apple.RealtaAumentata
    private typealias S = Tema.Sole

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let proiezione = Self.proiezione(geo.size)
            ZStack {
                sfondo(w: w, h: h)
                if !esito.vuota {
                    ombra(proiezione)
                    ForEach(Array(esito.strati.enumerated()), id: \.element.id) { i, s in
                        strato(i, s, proiezione)
                    }
                    sole(proiezione)
                }
            }
            .frame(width: w, height: h)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Il sole del piano sul tavolo"))
    }

    @ViewBuilder
    private func sfondo(w: CGFloat, h: CGFloat) -> some View {
        switch fondo {
        case .palco:
            RadialGradient(colors: [R.Fondo.centro, R.Fondo.bordo], center: R.Fondo.punto, startRadius: 0,
                           endRadius: max(w, h) * 0.75)
        case .neutro:
            F.neutro
        case .tavoloLegno:
            ZStack(alignment: .top) {
                LinearGradient(colors: [F.stanzaAlto, F.stanzaBasso], startPoint: .top, endPoint: .bottom)
                ForEach(0..<F.quanteBolle, id: \.self) { i in
                    let x = w * (F.bollaX + F.bollaPassoX * CGFloat(i))
                    let y = h * (F.bollaY + F.bollaPassoY * CGFloat(i % 3))
                    let d = min(w, h) * (F.bollaLato + F.bollaPassoLato * CGFloat(i % 2))
                    Circle()
                        .fill(RadialGradient(colors: [F.bolle[i % F.bolle.count], .clear], center: .center,
                                             startRadius: 0, endRadius: d / 2))
                        .frame(width: d, height: d)
                        .position(x: x, y: y)
                }
                LinearGradient(colors: [R.Tavolo.legnoChiaro, R.Tavolo.legnoScuro], startPoint: .top, endPoint: .bottom)
                    .frame(height: h * (1 - F.orizzonte))
                    .offset(y: h * F.orizzonte)
            }
            .frame(width: w, height: h, alignment: .top)
            .clipped()
        }
    }

    private func opacita(_ s: StratoRealta) -> Double {
        guard let scelto, scelto != s.id else { return 1 }
        return R.Strato.opacitaAltri
    }

    private func estremi(_ i: Int) -> (basso: Float, alto: Float) {
        MotoreRealtaAumentata.estremi(strato: i, bordi: esito.bordi,
                                      altezza: MotoreRealtaAumentata.spessoreDisco(esito, anno: anno),
                                      esploso: esploso ? 1 : 0, crescita: 1)
    }

    /// Uno strato: un disco d'oro sottile (fianco più scuro, faccia alta più chiara) velato dal colore della sua classe.
    private func strato(_ i: Int, _ s: StratoRealta, _ p: ProiezioneCristallo) -> some View {
        let e = estremi(i)
        let rx = p.scala * CGFloat(MotoreRealtaAumentata.raggioDisco)
        let ry = rx * p.schiacciamento
        let alto = p.punto(0, e.alto, 0)
        let basso = p.punto(0, e.basso, 0)
        let fianco = FiancoDisco(alto: alto, basso: basso, rx: rx, ry: ry)
        let faccia = Ellipse().path(in: CGRect(x: alto.x - rx, y: alto.y - ry, width: rx * 2, height: ry * 2))
        let tinta = R.Strati.colore(s.classe)
        return ZStack {
            fianco.fill(S.oroFisso)
            fianco.fill(tinta.opacity(S.velaturaClasse))
            fianco.fill(Color.black.opacity(S.scuroFianco))
            faccia.fill(S.oroFisso)
            faccia.fill(tinta.opacity(S.velaturaClasse))
            faccia.fill(LinearGradient(colors: [Color.white.opacity(F.chiaroAlto), .clear], startPoint: .top, endPoint: .bottom))
            faccia.stroke(F.bordo, lineWidth: F.spessoreBordo)
        }
        .opacity(opacita(s))
    }

    /// Il sole sulla faccia alta dell'ultimo strato: il disco che si riempie di luce e i raggi distesi sul tavolo.
    /// L'alone si accende con il cursore degli anni (il patrimonio dell'anno rispetto al più alto).
    @ViewBuilder
    private func sole(_ p: ProiezioneCristallo) -> some View {
        let n = esito.strati.count
        if n > 0 {
            let e = estremi(n - 1)
            let centro = p.punto(0, e.alto, 0)
            let lato = p.scala * CGFloat(MotoreRealtaAumentata.raggioDisco) / S.quotaDisco
            SoleDelPiano(sole: esito.sole, accensione: esito.massimo > 0 ? esito.totale(anno: anno) / esito.massimo : 1,
                         oro: S.oroFisso, animato: animato)
                .frame(width: lato, height: lato)
                .scaleEffect(x: 1, y: p.schiacciamento)
                .position(centro)
        }
    }

    /// L'ombra calda ovale sul tavolo, spostata verso la luce.
    private func ombra(_ p: ProiezioneCristallo) -> some View {
        let s = Tema.Apple.RealtaAumentata.Ombra.spostamento
        let centro = p.punto(s.x, 0, s.y)
        let larghezza = p.scala * CGFloat(MotoreRealtaAumentata.raggioDisco) * 2 * F.quotaOmbra
        return Ellipse()
            .fill(RadialGradient(colors: [S.oroFisso.opacity(Tema.Apple.RealtaAumentata.Ombra.opacita), F.ombra, .clear],
                                 center: .center, startRadius: 0, endRadius: larghezza / 2))
            .frame(width: larghezza, height: larghezza * p.schiacciamento)
            .position(centro)
    }

    /// Il punto dello schermo sopra il sole (per la targhetta), in una vista di misura `misura`.
    static func puntoTarghetta(_ esito: EsitoRealta, anno: Int?, esploso: Bool, misura: CGSize) -> CGPoint {
        let p = proiezione(misura)
        let n = esito.strati.count
        guard n > 0 else { return p.centro }
        let e = MotoreRealtaAumentata.estremi(strato: n - 1, bordi: esito.bordi,
                                              altezza: MotoreRealtaAumentata.spessoreDisco(esito, anno: anno),
                                              esploso: esploso ? 1 : 0, crescita: 1)
        return p.punto(0, e.alto, -MotoreRealtaAumentata.raggioDisco * F.quotaTarghetta)
    }

    /// Il punto accanto a ogni strato (per le pillole con «Esploso»).
    static func puntiStrati(_ esito: EsitoRealta, anno: Int?, esploso: Bool, misura: CGSize) -> [String: CGPoint] {
        let p = proiezione(misura)
        var punti: [String: CGPoint] = [:]
        for (i, s) in esito.strati.enumerated() {
            let e = MotoreRealtaAumentata.estremi(strato: i, bordi: esito.bordi,
                                                  altezza: MotoreRealtaAumentata.spessoreDisco(esito, anno: anno),
                                                  esploso: esploso ? 1 : 0, crescita: 1)
            punti[s.id] = p.punto(MotoreRealtaAumentata.raggioDisco * F.quotaPillole, (e.basso + e.alto) / 2, 0)
        }
        return punti
    }

    private static func proiezione(_ misura: CGSize) -> ProiezioneCristallo {
        ProiezioneCristallo(centro: CGPoint(x: misura.width * S.centroFermo.x, y: misura.height * S.centroFermo.y),
                            scala: min(misura.width, misura.height) * S.quotaScalaFermo, rotazione: F.rotazione,
                            schiacciamento: F.schiacciamento)
    }

    /// Lo scatto su fondo neutro (decisione 27): il sole del piano in un'immagine quadrata, mai la fotocamera.
    @MainActor
    static func scatto(_ esito: EsitoRealta, anno: Int?, esploso: Bool, lato: CGFloat = Tema.Apple.RealtaAumentata.Foglio.lato) -> CGImage? {
        let r = ImageRenderer(content: CristalloFermo(esito: esito, anno: anno, esploso: esploso, fondo: .neutro, animato: false)
            .frame(width: lato, height: lato)
            .environment(\.colorScheme, .light)
            .environment(\.prismaCalmo, true))
        r.proposedSize = ProposedViewSize(width: lato, height: lato)
        r.scale = 1
        return r.immaginePrisma
    }
}

/// Il fianco di un disco in assonometria: il rettangolo fra i centri della faccia alta e di quella bassa, chiuso sotto
/// dalla metà davanti dell'ellisse bassa.
struct FiancoDisco: Shape {
    let alto: CGPoint
    let basso: CGPoint
    let rx: CGFloat
    let ry: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: alto.x - rx, y: alto.y))
        p.addLine(to: CGPoint(x: basso.x - rx, y: basso.y))
        // La metà davanti dell'ellisse bassa, da sinistra a destra passando sotto
        let passi = 24
        for k in 1...passi {
            let a = Double.pi - Double.pi * Double(k) / Double(passi)
            p.addLine(to: CGPoint(x: basso.x + rx * CGFloat(cos(a)), y: basso.y + ry * CGFloat(sin(a))))
        }
        p.addLine(to: CGPoint(x: alto.x + rx, y: alto.y))
        p.closeSubpath()
        return p
    }
}

/// Il foglio dello scatto nei Documenti del cliente: A4 su carta bianca, il titolo, l'immagine, le classi con quota e
/// valore dell'anno, la nota (e la riga della stanza quando la foto la comprende).
struct FoglioScattoRealta: View {
    let cliente: String
    let anno: Int
    let immagine: CGImage
    let esito: EsitoRealta
    let annoEsito: Int?
    let conStanza: Bool

    private typealias G = Tema.Apple.RealtaAumentata.Foglio

    var body: some View {
        VStack(alignment: .leading, spacing: G.spazio) {
            Text(TestiRealta.titoloFoglio(cliente, anno: anno))
                .carattereApple(G.titolo)
                .foregroundStyle(G.inchiostro)
            Image(decorative: immagine, scale: 1)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: G.altezzaImmagine)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(esito.strati) { s in
                    HStack(spacing: G.spazioRiga) {
                        RoundedRectangle(cornerRadius: G.raggioQuadratino).fill(Tema.Apple.RealtaAumentata.Strati.colore(s.classe))
                            .frame(width: G.quadratino, height: G.quadratino)
                        Text(s.nome)
                        Spacer(minLength: G.spazioRiga)
                        Text(Formati.percentuale((s.quota * 100).rounded()))
                        Text(Formati.euro(esito.valore(s, anno: annoEsito)))
                            .frame(minWidth: G.larghezzaValore, alignment: .trailing)
                    }
                    .carattereApple(G.riga)
                    .foregroundStyle(G.inchiostro)
                    .padding(.vertical, G.paddingRiga)
                    .overlay(alignment: .bottom) { Rectangle().fill(G.filo).frame(height: 1) }
                }
            }
            if esito.stimata {
                Text(TestiRealta.stimata).carattereApple(G.nota).foregroundStyle(G.inchiostro2)
            }
            Spacer(minLength: 0)
            if conStanza {
                Text(TestiRealta.rigaStanza).carattereApple(G.nota).foregroundStyle(G.inchiostro2)
            }
            Text(TestiRealta.notaFoglio).carattereApple(G.nota).foregroundStyle(G.inchiostro2)
        }
        .padding(G.margine)
        .frame(width: G.formato.width, height: G.formato.height, alignment: .topLeading)
        .background(Tema.Apple.Carta.fondo)
        .environment(\.colorScheme, .light)
    }
}
