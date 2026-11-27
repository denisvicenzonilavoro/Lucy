#if os(macOS)
import SwiftUI
import AppKit

// Le scene del video di presentazione (`Prisma --video`), sullo stile del video di Lucy Exchange. Ogni scena è una vista
// piena 1920 × 1080 che dipende solo dal suo tempo `locale` (secondi dalla sua entrata): lo stesso istante dà sempre lo
// stesso fotogramma. Movimento continuo in ogni istante: la finestra entra salendo, cresce piano e scorre verso il basso
// come una pagina; i titoli entrano dal basso riga per riga; dentro la scena la pagina cambia (in dissolvenza, o a
// tendina dall'alto per la risposta di Lucy), la domanda si scrive lettera per lettera, una finestra esce di lato mentre
// l'altra entra. Tempi e testi nel copione (CopioneVideo.swift), valori in DesignSystem/Carta/TemaVideo.swift.

/// La scena `scena` al tempo `locale`, 1920 × 1080. `schermate`: le pagine già ritagliate, per nome d'istantanea.
struct SceneVideo: View {
    let scena: ScenaVideo
    let locale: Double
    let durata: Double
    let schermate: [String: CGImage]

    var body: some View {
        Group {
            switch scena {
            case .apertura: ScenaApertura(t: locale)
            case .perche: ScenaPerche(t: locale)
            case .lucy: ScenaLucy(t: locale, durata: durata, schermate: schermate)
            case .prospetti: ScenaProspetti(t: locale, durata: durata, schermate: schermate)
            case .chiusura: ScenaChiusura(t: locale)
            default: ScenaFinestra(scena: scena, t: locale, durata: durata, schermate: schermate)
            }
        }
        .frame(width: TemaVideo.larghezza, height: TemaVideo.altezza)
        .clipped()
    }
}

private typealias C = TemaVideo.Curva
private typealias M = TemaVideo.Misura
private let W = TemaVideo.larghezza
private let H = TemaVideo.altezza

extension View {
    /// Sposta la vista anche di frazioni di pixel, come trasformazione del disegno (`offset` si aggancia ai pixel e un
    /// movimento che rallenta finirebbe a piccoli scatti).
    fileprivate func spostato(x: CGFloat = 0, y: CGFloat = 0) -> some View {
        transformEffect(CGAffineTransform(translationX: x, y: y))
    }
}

// MARK: - Arredo

/// Il fondo pieno: carta o scuro, con una luce morbida al centro.
private struct FondoVideo: View {
    let scuro: Bool

    var body: some View {
        let bordo = scuro ? TemaVideo.Colore.notte : TemaVideo.Colore.carta
        let luce = scuro ? TemaVideo.Colore.notteLuce : TemaVideo.Colore.cartaLuce
        ZStack {
            bordo
            RadialGradient(colors: [luce, luce.opacity(0)], center: UnitPoint(x: 0.5, y: 0.38),
                           startRadius: 0, endRadius: 1150)
        }
        .frame(width: W, height: H)
    }
}

/// Una riga che entra dal basso di 24 punti con la dissolvenza, da `inizio`.
private struct RigaVideo: View {
    let testo: Text
    let tempo: Double
    let inizio: Double
    var durata: Double = 0.9

    var body: some View {
        let p = C.p(tempo, inizio, inizio + durata, C.posa)
        testo
            .opacity(C.p(tempo, inizio, inizio + durata * 0.8))
            .spostato(y: C.da(24, 0, p))
    }
}

/// Il titolo della scena sopra la finestra: una o due righe che entrano una dopo l'altra, la seconda in oro (una riga
/// sola ha in oro la parte dopo l'ultima virgola). Da `uscita` sfuma salendo appena, per lasciare il posto a un altro.
private struct TitoloVideo: View {
    let righe: [String]
    let tempo: Double
    let scuro: Bool
    var inizio: Double = 0.25
    var uscita: Double? = nil

    static let durataUscita = 0.45

    var body: some View {
        let corpo = M.corpoTitolo
        let inchiostro = scuro ? TemaVideo.Colore.inchiostroNotte : TemaVideo.Colore.inchiostro
        let oro = scuro ? TemaVideo.Colore.oroNotte : TemaVideo.Colore.oro
        let esce = uscita.map { C.p(tempo, $0, $0 + Self.durataUscita) } ?? 0
        VStack(spacing: corpo * 0.16) {
            if righe.count >= 2 {
                RigaVideo(testo: Text(righe[0]).foregroundColor(inchiostro), tempo: tempo, inizio: inizio)
                RigaVideo(testo: Text(righe[1]).foregroundColor(oro), tempo: tempo, inizio: inizio + 0.3)
            } else {
                let (testa, coda) = Self.virgola(righe.first ?? "")
                RigaVideo(testo: Text(testa).foregroundColor(inchiostro) + Text(coda).foregroundColor(oro),
                          tempo: tempo, inizio: inizio)
            }
        }
        .font(TemaVideo.Carattere.titolo(corpo))
        .tracking(TemaVideo.Carattere.spaziatura(corpo))
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .fixedSize()
        .opacity(1 - esce)
        .spostato(y: -18 * esce)
        .frame(width: W, height: M.fasciaTitolo)
        .offset(y: M.cimaTitolo)
        .frame(width: W, height: H, alignment: .top)
    }

    /// Una frase divisa all'ultima virgola: la testa (con la virgola e lo spazio) e la coda.
    static func virgola(_ testo: String) -> (String, String) {
        guard let r = testo.range(of: ", ", options: .backwards) else { return (testo, "") }
        return (String(testo[..<r.upperBound]), String(testo[r.upperBound...]))
    }
}

/// La pagina che sta arrivando sopra quella di adesso: in dissolvenza, o a tendina dall'alto con il bordo sfumato.
private struct CambioPagina {
    let immagine: CGImage
    let avanti: Double
    let tendina: Bool
}

/// La finestra dell'app con la sua pagina (un'istantanea vera ritagliata), larga `larghezzaFinestra`: angoli tondi,
/// filo sottile e ombra morbida; la pagina che arriva si disegna sopra.
private struct FinestraVideo: View {
    let immagine: CGImage?
    var cambio: CambioPagina? = nil
    let scura: Bool
    /// Quanto la pagina è scesa (in pixel del video): scorre sotto la testata, che resta ferma.
    var scorrimento: CGFloat = 0
    /// La testata ferma della finestra, in punti dell'istantanea (zero per le istantanee intere).
    var testata: CGFloat = M.testataFinestra

    static func altezza(_ immagine: CGImage?) -> CGFloat {
        guard let immagine, immagine.width > 0 else { return M.larghezzaFinestra * 10 / 16 }
        return M.larghezzaFinestra * CGFloat(immagine.height) / CGFloat(immagine.width)
    }

    var body: some View {
        let w = M.larghezzaFinestra, h = Self.altezza(immagine)
        let forma = RoundedRectangle(cornerRadius: M.raggioFinestra, style: .continuous)
        ZStack(alignment: .top) {
            pagina(immagine).spostato(y: -scorrimento)
            if let cambio, cambio.avanti > 0 {
                if cambio.tendina {
                    // Il bordo sfumato, alto 70 punti, scende dalla cima fino a scoprire tutta la pagina nuova
                    let bordo: CGFloat = 70
                    let fondo = CGFloat(cambio.avanti) * (h + bordo)
                    pagina(cambio.immagine)
                        .spostato(y: -scorrimento)
                        .mask(alignment: .top) {
                            VStack(spacing: 0) {
                                Rectangle().frame(height: max(0, fondo - bordo))
                                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                    .frame(height: bordo)
                            }
                            .frame(width: w, height: h, alignment: .top)
                        }
                } else {
                    pagina(cambio.immagine).spostato(y: -scorrimento).opacity(cambio.avanti)
                }
            }
            // La testata della finestra resta ferma mentre la pagina scorre sotto (anche quella della pagina che arriva)
            if testata > 0 {
                fascia(immagine)
                if let cambio, cambio.avanti > 0 { fascia(cambio.immagine).opacity(cambio.avanti) }
            }
        }
        .frame(width: w, height: h, alignment: .top)
        .clipShape(forma)
        .overlay(forma.strokeBorder(scura ? TemaVideo.Colore.filoNotte : TemaVideo.Colore.filoCarta, lineWidth: 1))
        .background(
            forma.fill(Color.black)
                .shadow(color: scura ? TemaVideo.Colore.ombraNotte : TemaVideo.Colore.ombraCarta, radius: 60, y: 34)
        )
    }

    /// La testata ferma: la striscia alta `testata` punti in cima all'istantanea.
    @ViewBuilder private func fascia(_ immagine: CGImage?) -> some View {
        let k = CGFloat(immagine?.width ?? 1) / M.ritaglioFinestra.width
        if let immagine, let striscia = immagine.cropping(to: CGRect(x: 0, y: 0, width: CGFloat(immagine.width),
                                                                     height: (testata * k).rounded())) {
            Image(decorative: striscia, scale: 1).resizable().interpolation(.high)
                .frame(width: M.larghezzaFinestra, height: M.larghezzaFinestra * CGFloat(striscia.height) / CGFloat(striscia.width))
        }
    }

    @ViewBuilder private func pagina(_ immagine: CGImage?) -> some View {
        if let immagine {
            Image(decorative: immagine, scale: 1).resizable().interpolation(.high)
                .frame(width: M.larghezzaFinestra, height: Self.altezza(immagine))
        } else {
            (scura ? TemaVideo.Colore.notteLuce : TemaVideo.Colore.cartaLuce)
        }
    }
}

/// La finestra al suo posto sotto il titolo, con l'entrata (sale, cresce appena e compare), la crescita lenta per tutta
/// la scena e lo scorrimento verso il basso, come una pagina che si legge.
private struct FinestraInMoto: View {
    let finestra: FinestraVideo
    let t: Double
    let durata: Double

    var body: some View {
        let entra = C.p(t, 0.05, 1.35, C.posa)
        let alta = FinestraVideo.altezza(finestra.immagine)
        // La finestra resta sotto il titolo; dentro, la pagina scende fin dove la finestra esce dal fondo del video
        let corsa = max(0, M.cimaFinestra + alta - H)
        var f = finestra
        f.scorrimento = C.da(0, corsa, C.p(t, 1.5, durata))
        return f
            .scaleEffect(C.da(0.94, 1, entra), anchor: .top)
            .spostato(y: C.da(70, 0, entra))
            .opacity(C.p(t, 0.05, 0.85))
            .scaleEffect(C.da(1, 1.03, C.p(t, 0, durata, { $0 })), anchor: .top)
            .frame(width: W, height: H, alignment: .top)
            .spostato(y: M.cimaFinestra)
    }
}

/// La pagina della scena a `t`: quella del passo in corso e, nei 0,35 s dopo un cambio (0,9 s per la tendina), quella
/// che arriva.
@MainActor private func finestraAPassi(_ scena: ScenaVideo, t: Double, schermate: [String: CGImage]) -> FinestraVideo {
    let passi = scena.passi
    let i = passi.lastIndex { t >= $0.inizio } ?? 0
    let durataCambio = passi[i].tendina ? 0.9 : 0.35
    if i > 0, t < passi[i].inizio + durataCambio {
        let p = C.p(t, passi[i].inizio, passi[i].inizio + durataCambio, passi[i].tendina ? C.posa : C.morbida)
        return FinestraVideo(immagine: schermate[passi[i - 1].istantanea],
                             cambio: schermate[passi[i].istantanea].map { CambioPagina(immagine: $0, avanti: p,
                                                                                        tendina: passi[i].tendina) },
                             scura: scena.scura,
                             testata: ScenaVideo.intere.contains(passi[i].istantanea) ? 0 : M.testataFinestra)
    }
    let nome = passi.isEmpty ? "" : passi[i].istantanea
    return FinestraVideo(immagine: schermate[nome], scura: scena.scura,
                         testata: ScenaVideo.intere.contains(nome) ? 0 : M.testataFinestra)
}

// MARK: - Il marchio che si compone

/// Il simbolo (asta, base, disco) con i tre avanzamenti 0…1: l'asta cresce dal basso, la base verso destra, il disco
/// si posa.
private struct SimboloVideo: View {
    let asta: Double
    let base: Double
    let disco: Double

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                ElleLucy().fill(TemaVideo.Colore.inchiostro)
                    .mask {
                        ZStack(alignment: .bottomLeading) {
                            Color.clear
                            Rectangle().frame(width: s * 0.5, height: s * asta)
                            Rectangle().frame(width: s * base, height: s * 0.5)
                        }
                    }
                DiscoLucy().fill(TemaVideo.Colore.oroMarchio)
                    .scaleEffect(0.35 + 0.65 * disco)
                    .opacity(disco)
            }
            .frame(width: s, height: s)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// Il marchio completo «Lucy by LOGIC» che si scrive: il simbolo si disegna (0–1,6 s del suo tempo), poi «Lucy»
/// (1,4–2,4 s) e la firma (2,3–3,2 s); il cursore d'oro resta acceso.
private struct MarchioVideo: View {
    /// Il tempo del disegno.
    let tempo: Double
    /// L'altezza del simbolo.
    let altezza: CGFloat

    var body: some View {
        let vb = CGRect(x: 30, y: 82, width: 717, height: 302.72)
        let scala = altezza / 160
        let nome = C.p(tempo, 1.4, 2.4, C.posa)
        let firma = C.p(tempo, 2.3, 3.2, C.posa)
        ZStack(alignment: .topLeading) {
            TracciatoMarchio(dati: TracciatiMarchio.nome, viewBox: vb).fill(TemaVideo.Colore.inchiostro)
                .opacity(nome)
                .spostato(x: C.da(16, 0, nome))
            Group {
                TracciatoMarchio(dati: TracciatiMarchio.by, viewBox: vb).fill(TemaVideo.Colore.by)
                TracciatoMarchio(dati: TracciatiMarchio.logicPiccolo, viewBox: vb).fill(TemaVideo.Colore.inchiostro)
                RettangoloMarchio(riquadro: TracciatiMarchio.cursorePiccolo, viewBox: vb).fill(TemaVideo.Colore.oroMarchio)
            }
            .opacity(firma)
            .spostato(y: C.da(10, 0, firma))
            SimboloVideo(asta: C.p(tempo, 0.1, 0.75), base: C.p(tempo, 0.65, 1.2), disco: C.p(tempo, 1.1, 1.7, C.posa))
                .frame(width: 160 * scala, height: 160 * scala)
                .position(x: (120 - vb.minX) * scala, y: (172 - vb.minY) * scala)
        }
        .frame(width: vb.width * scala, height: vb.height * scala)
    }
}

// MARK: - 1. Apertura

/// Carta chiara: il marchio completo si scrive e resta, con un leggero avvicinamento per tutta la scena.
private struct ScenaApertura: View {
    let t: Double

    var body: some View {
        ZStack {
            FondoVideo(scuro: false)
            MarchioVideo(tempo: t - 0.3, altezza: M.marchioApertura)
                .scaleEffect(C.da(1, 1.05, C.p(t, 0, 6.6, { $0 })))
        }
    }
}

// MARK: - 2. Il perché

/// Su scuro, tre righe grandi una dopo l'altra; quelle già dette si spengono un poco, l'ultima è in oro.
private struct ScenaPerche: View {
    let t: Double
    private let inizi = [0.35, 2.2, 4.05]

    var body: some View {
        let corpo = M.corpoGrande
        let righe = TestiVideo.perche
        ZStack {
            FondoVideo(scuro: true)
            VStack(spacing: corpo * 0.3) {
                ForEach(Array(righe.enumerated()), id: \.offset) { i, riga in
                    let dopo = i + 1 < inizi.count ? C.p(t, inizi[i + 1], inizi[i + 1] + 0.8) : 0
                    RigaVideo(testo: Text(riga).foregroundColor(i == righe.count - 1 ? TemaVideo.Colore.oroNotte
                                                                                     : TemaVideo.Colore.inchiostroNotte),
                              tempo: t, inizio: inizi[i], durata: 1.0)
                        .opacity(1 - 0.6 * dopo)
                }
            }
            .font(TemaVideo.Carattere.titolo(corpo))
            .tracking(TemaVideo.Carattere.spaziatura(corpo))
            .lineLimit(1)
            .fixedSize()
            .scaleEffect(C.da(1, 1.035, C.p(t, 0, 7.6, { $0 })))
        }
    }
}

// MARK: - Le scene con la finestra

/// Una finestra con il suo titolo; al cambio di pagina (se c'è) il titolo lascia il posto al secondo.
private struct ScenaFinestra: View {
    let scena: ScenaVideo
    let t: Double
    let durata: Double
    let schermate: [String: CGImage]

    var body: some View {
        let cambio = scena.passi.count > 1 ? scena.passi[1].inizio : nil
        ZStack {
            FondoVideo(scuro: scena.scura)
            FinestraInMoto(finestra: finestraAPassi(scena, t: t, schermate: schermate), t: t, durata: durata)
            let secondo = TestiVideo.secondoTitolo(scena)
            if let titolo = TestiVideo.titolo(scena), t < (secondo != nil ? (cambio ?? .infinity) + TitoloVideo.durataUscita : .infinity) {
                TitoloVideo(righe: titolo, tempo: t, scuro: scena.scura, uscita: secondo != nil ? cambio : nil)
            }
            if let secondo, let cambio, t >= cambio {
                TitoloVideo(righe: secondo, tempo: t, scuro: scena.scura, inizio: cambio + 0.3)
            }
        }
    }
}

// MARK: - Chiedi a Lucy

/// La domanda si scrive lettera per lettera nel campo grande, parte, e la risposta di Lucy scende a tendina nella
/// finestra; il titolo passa da «Chiedi quello che ti serve.» a «Le cifre sono di Lucy. / La scelta è tua.».
private struct ScenaLucy: View {
    let t: Double
    let durata: Double
    let schermate: [String: CGImage]

    var body: some View {
        let q = CopioneVideo.domandaLucy
        let risposta = CopioneVideo.rispostaLucy
        ZStack {
            FondoVideo(scuro: false)
            FinestraInMoto(finestra: finestraAPassi(.lucy, t: t, schermate: schermate), t: t, durata: durata)
            campo(q)
            if t < risposta + TitoloVideo.durataUscita {
                TitoloVideo(righe: TestiVideo.titolo(.lucy) ?? [], tempo: t, scuro: false, uscita: risposta)
            }
            if t >= risposta {
                TitoloVideo(righe: TestiVideo.secondoTitolo(.lucy) ?? [], tempo: t, scuro: false, inizio: risposta + 0.3)
            }
        }
    }

    /// Il campo grande in basso: compare, la domanda si scrive, all'invio scende via.
    @ViewBuilder private func campo(_ q: (compare: Double, scrive: Double, lettera: Double, invio: Double)) -> some View {
        if t >= q.compare, t < q.invio + 0.6 {
            let testo = TestiVideo.domandaLucy
            let lettere = max(0, min(testo.count, Int(((t - q.scrive) / q.lettera).rounded(.down)) + 1))
            let scritto = t < q.scrive ? "" : String(testo.prefix(lettere))
            let entra = C.p(t, q.compare, q.compare + 0.45, C.posa)
            let esce = C.p(t, q.invio, q.invio + 0.5)
            CampoDomandaVideo(scritto: scritto, cursore: esce == 0)
                .opacity(entra * (1 - esce))
                .spostato(y: C.da(40, 0, entra) + C.da(0, 30, esce))
                .frame(width: W, height: H, alignment: .bottom)
                .offset(y: -84)
        }
    }
}

/// Il campo della domanda, grande sopra la finestra: la domanda con il cursore d'oro e il pulsante «Chiedi».
private struct CampoDomandaVideo: View {
    let scritto: String
    let cursore: Bool

    var body: some View {
        let corpo: CGFloat = 34
        let k = TemaVideo.Colore.self
        HStack(spacing: 18) {
            HStack(spacing: 2) {
                if scritto.isEmpty {
                    Rectangle().fill(k.oroMarchio).frame(width: 3, height: corpo * 1.15).opacity(cursore ? 1 : 0)
                    Text(TestiVideo.invitoLucy).foregroundColor(k.matita)
                } else {
                    Text(scritto).foregroundColor(k.inchiostro)
                    Rectangle().fill(k.oroMarchio).frame(width: 3, height: corpo * 1.15).opacity(cursore ? 1 : 0)
                }
                Spacer(minLength: 0)
            }
            .font(TemaVideo.Carattere.campo)
            .lineLimit(1)
            .padding(.horizontal, 30)
            .frame(height: 92)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(k.foglio))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(k.filoCarta, lineWidth: 1.5))
            Text("Chiedi")
                .font(TemaVideo.Carattere.pulsante)
                .foregroundColor(k.carta)
                .padding(.horizontal, 38)
                .frame(height: 92)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(k.inchiostro))
        }
        .frame(width: 1080)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(k.carta)
                .shadow(color: .black.opacity(0.28), radius: 50, y: 24)
        )
    }
}

// MARK: - Prospetti e sala

/// Il prospetto su carta, poi la finestra esce a sinistra mentre la sala opaca entra da destra, su scuro: «E davanti al
/// cliente, / a tutto schermo.».
private struct ScenaProspetti: View {
    let t: Double
    let durata: Double
    let schermate: [String: CGImage]

    var body: some View {
        let s = CopioneVideo.passaggioSala
        let q = C.p(t, s.inizio, s.fine, C.scivola)
        ZStack {
            FondoVideo(scuro: false)
            FondoVideo(scuro: true).opacity(C.p(t, s.inizio, s.fine))
            if q < 1 {
                FinestraInMoto(finestra: finestraAPassi(.prospetti, t: t, schermate: schermate), t: t, durata: durata)
                    .spostato(x: C.da(0, -W, q))
                TitoloVideo(righe: TestiVideo.titolo(.prospetti) ?? [], tempo: t, scuro: false, uscita: s.inizio - 0.1)
            }
            if q > 0 {
                FinestraVideo(immagine: schermate["461-prospetti-sala"], scura: true,
                              scorrimento: C.da(0, 150, C.p(t, s.fine + 0.4, durata)), testata: 0)
                    .scaleEffect(C.da(1, 1.03, C.p(t, s.inizio, durata, { $0 })), anchor: .top)
                    .frame(width: W, height: H, alignment: .top)
                    .spostato(x: C.da(W, 0, q), y: M.cimaFinestra)
                TitoloVideo(righe: TestiVideo.secondoTitolo(.prospetti) ?? [], tempo: t, scuro: true,
                            inizio: s.fine - 0.35)
            }
        }
    }
}

// MARK: - Chiusura

/// Su carta: «Prima l'analisi.» e «Poi la consulenza.», che poi salgono e lasciano il posto al marchio completo, che
/// si scrive; il cursore resta acceso.
private struct ScenaChiusura: View {
    let t: Double
    private static let marchio = 3.4

    var body: some View {
        let corpo = M.corpoChiusura
        let righe = TestiVideo.chiusura
        let sale = C.p(t, Self.marchio - 0.3, Self.marchio + 1.0)
        ZStack {
            FondoVideo(scuro: false)
            VStack(spacing: corpo * 0.2) {
                RigaVideo(testo: Text(righe[0]).foregroundColor(TemaVideo.Colore.inchiostro), tempo: t, inizio: 0.35,
                          durata: 1.0)
                RigaVideo(testo: Text(righe[1]).foregroundColor(TemaVideo.Colore.oro), tempo: t, inizio: 1.1,
                          durata: 1.0)
            }
            .font(TemaVideo.Carattere.titolo(corpo))
            .tracking(TemaVideo.Carattere.spaziatura(corpo))
            .lineLimit(1)
            .fixedSize()
            .scaleEffect(C.da(1, 0.66, sale))
            .spostato(y: C.da(0, -190, sale))
            .scaleEffect(C.da(1, 1.03, C.p(t, 0, Self.marchio, { $0 })))
            if t >= Self.marchio {
                MarchioVideo(tempo: t - Self.marchio, altezza: M.marchioChiusura)
                    .scaleEffect(C.da(0.97, 1.0, C.p(t, Self.marchio, 9.3, C.posa)))
                    .offset(y: 150)
            }
        }
    }
}
#endif
