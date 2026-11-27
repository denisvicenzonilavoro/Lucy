#if os(macOS)
import SwiftUI
import AppKit

// Le scene del video di presentazione (`Prisma --video`): ogni scena è una vista piena 1920 × 1080 che dipende solo dal
// suo tempo (`locale`, in secondi dall'entrata), così ogni fotogramma si disegna da solo con `ImageRenderer`. Niente
// animazioni di SwiftUI né timer: il movimento è il conto delle curve di `TemaVideo.Curva`.
// La regia:
// - apertura: su carta la L di luce si disegna (prima l'asta, poi la base), il disco d'oro si posa, il simbolo si sposta
//   al suo posto nel marchio e «Lucy» compare accanto; sotto, l'occhiello;
// - manifesto: su fondo scuro tre righe una dopo l'altra, l'ultima in oro;
// - le schermate (istantanee vere dell'app con i clienti di prova): la schermata sale e si posa sotto il titolo, poi la
//   camera si avvicina piano al dettaglio della scena mentre il titolo si ritira;
// - sera: la scrivania di giorno e una tendina con il filo d'oro che la porta alla sera;
// - chiusura: la frase in corsivo e il marchio completo «Lucy by Logic».

/// Una scena del video all'istante `locale` della sua scena.
struct SceneVideo: View {
    let scena: ScenaVideo
    let locale: Double
    let durata: Double
    let schermate: [String: NSImage]

    var body: some View {
        Group {
            switch scena {
            case .apertura: AperturaVideo(t: locale)
            case .manifesto: ManifestoVideo(t: locale)
            case .chiusura: ChiusuraVideo(t: locale)
            case .sera:
                SeraVideo(t: locale, giorno: schermate[ScenaVideo.scrivania.istantanea ?? ""],
                          notte: schermate[scena.istantanea ?? ""])
            default:
                SchermataVideo(scena: scena, t: locale, durata: durata, immagine: schermate[scena.istantanea ?? ""])
            }
        }
        .frame(width: TemaVideo.larghezza, height: TemaVideo.altezza)
        .clipped()
    }
}

private typealias C = TemaVideo.Curva

// MARK: - Fondi

/// La carta chiara con una luce morbida in alto.
private struct FondoCartaVideo: View {
    var body: some View {
        ZStack {
            TemaVideo.Colore.carta
            RadialGradient(colors: [TemaVideo.Colore.cartaLuce, TemaVideo.Colore.carta.opacity(0)],
                           center: UnitPoint(x: 0.5, y: 0.18), startRadius: 0, endRadius: 1100)
        }
    }
}

/// Il fondo scuro con un alone caldo appena accennato.
private struct FondoNotteVideo: View {
    var body: some View {
        ZStack {
            TemaVideo.Colore.notte
            RadialGradient(colors: [TemaVideo.Colore.oroNotte.opacity(0.10), .clear],
                           center: UnitPoint(x: 0.5, y: 0.55), startRadius: 0, endRadius: 900)
        }
    }
}

// MARK: - Il marchio che si compone

/// Il simbolo (asta, base, disco) con i tre avanzamenti 0…1, nel quadrato dato.
private struct SimboloVideo: View {
    let asta: Double
    let base: Double
    let disco: Double
    var colore: Color = TemaVideo.Colore.inchiostro
    var oro: Color = TemaVideo.Colore.oro

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                // L'asta cresce dal basso, poi la base verso destra (la geometria è quella di GeometriaLucy)
                ElleLucy().fill(colore)
                    .mask {
                        ZStack(alignment: .bottomLeading) {
                            Color.clear
                            Rectangle().frame(width: s * 0.5, height: s * asta)
                            Rectangle().frame(width: s * base, height: s * 0.5)
                        }
                    }
                DiscoLucy().fill(oro)
                    .scaleEffect(0.35 + 0.65 * disco)
                    .opacity(disco)
            }
            .frame(width: s, height: s)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// «Lucy» (e, con `completo`, «by Logic») senza il simbolo, nello spazio del marchio: il simbolo lo disegna la scena.
private struct NomeMarchioVideo: View {
    let altezza: CGFloat
    var completo = false
    var opacitaNome: Double = 1
    var opacitaFirma: Double = 1

    static func viewBox(completo: Bool) -> CGRect {
        CGRect(x: 30, y: 82, width: 717, height: completo ? 302.72 : 228)
    }

    var body: some View {
        let vb = Self.viewBox(completo: completo)
        let scala = altezza / 160
        ZStack {
            TracciatoMarchio(dati: TracciatiMarchio.nome, viewBox: vb).fill(TemaVideo.Colore.inchiostro)
                .opacity(opacitaNome)
            if completo {
                Group {
                    TracciatoMarchio(dati: TracciatiMarchio.by, viewBox: vb).fill(TemaVideo.Colore.by)
                    TracciatoMarchio(dati: TracciatiMarchio.logicPiccolo, viewBox: vb).fill(TemaVideo.Colore.inchiostro)
                    RettangoloMarchio(riquadro: TracciatiMarchio.cursorePiccolo, viewBox: vb).fill(TemaVideo.Colore.oro)
                }
                .opacity(opacitaFirma)
            }
        }
        .frame(width: vb.width * scala, height: vb.height * scala)
    }

    /// Dove sta il simbolo dentro il marchio (centro e lato), con il marchio centrato in `centro`.
    static func simbolo(altezza: CGFloat, completo: Bool, centro: CGPoint) -> (centro: CGPoint, lato: CGFloat) {
        let vb = viewBox(completo: completo)
        let scala = altezza / 160
        let origine = CGPoint(x: centro.x - vb.width * scala / 2, y: centro.y - vb.height * scala / 2)
        return (CGPoint(x: origine.x + (120 - vb.minX) * scala, y: origine.y + (172 - vb.minY) * scala), 160 * scala)
    }
}

// MARK: - Apertura

private struct AperturaVideo: View {
    let t: Double

    var body: some View {
        let W = TemaVideo.larghezza, H = TemaVideo.altezza
        let altezzaMarchio: CGFloat = 150
        let centroMarchio = CGPoint(x: W / 2, y: H / 2 - 30)
        let arrivo = NomeMarchioVideo.simbolo(altezza: altezzaMarchio, completo: false, centro: centroMarchio)
        let partenza = (centro: CGPoint(x: W / 2, y: H / 2 - 30), lato: TemaVideo.Misura.simbolo)
        // Il simbolo si disegna (0,3–2,2 s), poi va al suo posto nel marchio (2,6–3,6 s) mentre «Lucy» compare
        let viaggio = C.morbida(C.tratto(t, 2.6, 3.6))
        let centro = CGPoint(x: partenza.centro.x + (arrivo.centro.x - partenza.centro.x) * viaggio,
                             y: partenza.centro.y + (arrivo.centro.y - partenza.centro.y) * viaggio)
        let lato = partenza.lato + (arrivo.lato - partenza.lato) * viaggio
        let nome = C.posa(C.tratto(t, 3.0, 4.0))
        let occhiello = C.posa(C.tratto(t, 4.1, 5.0))
        ZStack {
            FondoCartaVideo()
            NomeMarchioVideo(altezza: altezzaMarchio, opacitaNome: nome)
                .offset(x: CGFloat(1 - nome) * 18)
                .position(centroMarchio)
            SimboloVideo(asta: C.morbida(C.tratto(t, 0.3, 1.05)),
                         base: C.morbida(C.tratto(t, 0.95, 1.55)),
                         disco: C.posa(C.tratto(t, 1.45, 2.2)))
                .frame(width: lato, height: lato)
                .position(centro)
            Text(TestiVideo.apertura)
                .font(TemaVideo.Carattere.occhiello.font(1))
                .tracking(TemaVideo.Carattere.spaziaturaOcchiello)
                .foregroundColor(TemaVideo.Colore.occhiello)
                .opacity(occhiello)
                .offset(y: CGFloat(1 - occhiello) * 14)
                .position(x: W / 2, y: centroMarchio.y + 150)
        }
    }
}

// MARK: - Manifesto

private struct ManifestoVideo: View {
    let t: Double

    var body: some View {
        let righe = TestiVideo.manifesto
        ZStack {
            FondoNotteVideo()
            VStack(spacing: 26) {
                ForEach(Array(righe.enumerated()), id: \.offset) { i, riga in
                    let e = C.posa(C.tratto(t, 0.6 + Double(i) * 1.9, 1.7 + Double(i) * 1.9))
                    let ultima = i == righe.count - 1
                    Text(riga)
                        .font(TemaVideo.Carattere.manifesto.font(1))
                        .tracking(TemaVideo.Carattere.spaziaturaTitolo)
                        .foregroundColor(ultima ? TemaVideo.Colore.oroNotte : TemaVideo.Colore.avorio)
                        .opacity(e)
                        .offset(y: CGFloat(1 - e) * 34)
                }
                // Il filo d'oro che si allunga sotto l'ultima riga
                let filo = C.morbida(C.tratto(t, 5.0, 6.2))
                Rectangle()
                    .fill(TemaVideo.Colore.oroNotte)
                    .frame(width: 220 * filo, height: 2)
                    .padding(.top, 18)
            }
        }
    }
}

// MARK: - Le schermate

/// La schermata nella sua cornice: angoli tondi, filo sottile e ombra calda.
private struct CorniceSchermata: View {
    let immagine: NSImage?

    var body: some View {
        let M = TemaVideo.Misura.self
        let forma = RoundedRectangle(cornerRadius: M.raggio, style: .continuous)
        Group {
            if let immagine {
                Image(nsImage: immagine).resizable().interpolation(.high)
            } else {
                TemaVideo.Colore.cartaLuce
            }
        }
        .frame(width: M.schermata, height: M.schermata * 10 / 16)
        .clipShape(forma)
        .overlay(forma.stroke(TemaVideo.Colore.filo, lineWidth: 1))
        .shadow(color: TemaVideo.Colore.ombra, radius: 46, x: 0, y: 28)
    }
}

/// Occhiello, titolo e la sottolineatura d'oro che si allunga.
private struct TitoloScena: View {
    let occhiello: String
    let titolo: String
    let t: Double
    var notte: Double = 0

    var body: some View {
        let e = C.posa(C.tratto(t, 0.35, 1.25))
        let linea = C.morbida(C.tratto(t, 0.9, 1.8))
        VStack(spacing: 14) {
            Text(occhiello)
                .font(TemaVideo.Carattere.occhiello.font(1))
                .tracking(TemaVideo.Carattere.spaziaturaOcchiello)
                .foregroundColor(TemaVideo.Colore.occhiello)
                .overlay(Text(occhiello)
                    .font(TemaVideo.Carattere.occhiello.font(1))
                    .tracking(TemaVideo.Carattere.spaziaturaOcchiello)
                    .foregroundColor(TemaVideo.Colore.oroNotte)
                    .opacity(notte))
            Text(titolo)
                .font(TemaVideo.Carattere.titolo.font(1))
                .tracking(TemaVideo.Carattere.spaziaturaTitolo)
                .foregroundColor(TemaVideo.Colore.inchiostro)
                .overlay(Text(titolo)
                    .font(TemaVideo.Carattere.titolo.font(1))
                    .tracking(TemaVideo.Carattere.spaziaturaTitolo)
                    .foregroundColor(TemaVideo.Colore.avorio)
                    .opacity(notte))
                .overlay(alignment: .bottomLeading) {
                    Capsule()
                        .fill(TemaVideo.Colore.sottolineatura)
                        .frame(height: 4)
                        .scaleEffect(x: linea, y: 1, anchor: .leading)
                        .offset(y: 10)
                }
        }
        .opacity(e)
        .offset(y: CGFloat(1 - e) * 24)
        .fixedSize()
    }
}

private struct SchermataVideo: View {
    let scena: ScenaVideo
    let t: Double
    let durata: Double
    let immagine: NSImage?

    var body: some View {
        let W = TemaVideo.larghezza, H = TemaVideo.altezza
        let M = TemaVideo.Misura.self
        let alta = M.schermata * 10 / 16
        // L'entrata: la schermata sale e si posa
        let e = C.posa(C.tratto(t, 0, 1.2))
        // La camera: dopo un respiro si avvicina piano al dettaglio fino alla fine della scena
        let cam = scena.camera
        let z = C.morbida(C.tratto(t, 1.9, max(2.0, durata - 0.1)))
        let zoom = 1 + (cam.zoom - 1) * z
        let centroBase = CGPoint(x: W / 2, y: M.sopraSchermata + alta / 2)
        let fuoco = CGPoint(x: centroBase.x + (CGFloat(cam.x) - 0.5) * M.schermata,
                            y: centroBase.y + (CGFloat(cam.y) - 0.5) * alta)
        let verso = CGPoint(x: W / 2 - fuoco.x, y: H * 0.52 - fuoco.y)
        // Il titolo si ritira mentre la camera entra
        let ritiro = C.morbida(C.tratto(z, 0.08, 0.45))
        ZStack {
            FondoCartaVideo()
            if let titolo = TestiVideo.titolo(scena) {
                TitoloScena(occhiello: titolo.occhiello, titolo: titolo.titolo, t: t)
                    .opacity(1 - ritiro)
                    .offset(y: -CGFloat(ritiro) * 30)
                    .position(x: W / 2, y: M.sopraTitolo)
            }
            CorniceSchermata(immagine: immagine)
                .scaleEffect(0.955 + 0.045 * e)
                .offset(y: CGFloat(1 - e) * 110)
                .opacity(0.2 + 0.8 * e)
                .scaleEffect(zoom, anchor: UnitPoint(x: cam.x, y: cam.y))
                .offset(x: verso.x * CGFloat(z), y: verso.y * CGFloat(z))
                .position(centroBase)
        }
    }
}

// MARK: - Sera

private struct SeraVideo: View {
    let t: Double
    let giorno: NSImage?
    let notte: NSImage?

    var body: some View {
        let W = TemaVideo.larghezza
        let M = TemaVideo.Misura.self
        let alta = M.schermata * 10 / 16
        // La tendina della sera passa da sinistra a destra (1,2–3,4 s) con il filo d'oro sul bordo
        let w = C.morbida(C.tratto(t, 1.2, 3.4))
        let titolo = TestiVideo.titolo(.sera)
        ZStack {
            FondoCartaVideo()
            FondoNotteVideo().opacity(w)
            if let titolo {
                TitoloScena(occhiello: titolo.occhiello, titolo: titolo.titolo, t: t, notte: w)
                    .position(x: W / 2, y: M.sopraTitolo)
            }
            ZStack(alignment: .leading) {
                CorniceSchermata(immagine: giorno)
                CorniceSchermata(immagine: notte)
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: M.schermata * CGFloat(w))
                    }
                Rectangle()
                    .fill(TemaVideo.Colore.oroNotte)
                    .frame(width: 3, height: alta + 40)
                    .shadow(color: TemaVideo.Colore.oroNotte.opacity(0.8), radius: 12)
                    .offset(x: M.schermata * CGFloat(w) - 1.5)
                    .opacity(w > 0.001 && w < 0.999 ? 1 : 0)
            }
            .frame(width: M.schermata, height: alta)
            .position(x: W / 2, y: M.sopraSchermata + alta / 2)
        }
    }
}

// MARK: - Chiusura

private struct ChiusuraVideo: View {
    let t: Double

    var body: some View {
        let W = TemaVideo.larghezza, H = TemaVideo.altezza
        let altezzaMarchio = TemaVideo.Misura.marchio
        let centroMarchio = CGPoint(x: W / 2, y: H / 2 + 40)
        let simbolo = NomeMarchioVideo.simbolo(altezza: altezzaMarchio, completo: true, centro: centroMarchio)
        let frase = C.posa(C.tratto(t, 0.5, 1.6))
        let marchio = C.posa(C.tratto(t, 1.7, 2.7))
        let firma = C.posa(C.tratto(t, 3.0, 3.9))
        let piede = C.posa(C.tratto(t, 3.8, 4.7))
        ZStack {
            FondoCartaVideo()
            Text(TestiVideo.chiusura)
                .font(TemaVideo.Carattere.chiusura.font(1))
                .foregroundColor(TemaVideo.Colore.inchiostro2)
                .opacity(frase)
                .offset(y: CGFloat(1 - frase) * 20)
                .position(x: W / 2, y: H / 2 - 170)
            NomeMarchioVideo(altezza: altezzaMarchio, completo: true, opacitaNome: marchio, opacitaFirma: firma)
                .position(centroMarchio)
            SimboloVideo(asta: marchio, base: marchio, disco: C.posa(C.tratto(t, 2.0, 2.9)))
                .opacity(marchio)
                .frame(width: simbolo.lato, height: simbolo.lato)
                .position(simbolo.centro)
            Text(TestiVideo.firmaChiusura)
                .font(TemaVideo.Carattere.firma.font(1))
                .tracking(TemaVideo.Carattere.spaziaturaOcchiello)
                .foregroundColor(TemaVideo.Colore.occhiello)
                .opacity(piede)
                .position(x: W / 2, y: H - 110)
        }
    }
}
#endif
