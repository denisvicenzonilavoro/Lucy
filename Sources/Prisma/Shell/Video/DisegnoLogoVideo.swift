#if os(macOS)
import SwiftUI

// Il logo che si disegna nel video, come in tutti i video di Lucy (Lucy Exchange e Lucy AI; richiesta dell'utente del
// 27 novembre 2026: «il logo iniziale e finale vorrei che si disegnasse come su tutti gli altri video»): guide da
// disegnatore, la L tracciata e riempita, il compasso che tira il cerchio d'oro, il disco che cresce con il rimbalzo, il
// simbolo che si posa accanto a «Lucy» e «by LOGIC» scritto lettera per lettera con il cursore d'oro. Conto preso da
// `LogoDisegnato` di Lucy Exchange, con le coordinate del logo SVG di Lucy (viewBox 30, 82, 717 × 302,72). Tempi:
//   0–0,87     guide sottili (una ogni 0,09 s)          0,25–1,05  la L tracciata con un tratto solo
//   0,95–1,5   la L si riempie (asta, poi base)         0,85–1,65  il compasso tira il cerchio d'oro
//   1,55–2,25  il disco cresce con il rimbalzo          2,3–2,95   il simbolo si posa nel logo
//   2,75–3,35  «Lucy» entra da sinistra                 3,45–4,25  «by LOGIC» si scrive con il cursore

enum LogoDisegnatoVideo {
    static let fine = 4.3

    /// Il riquadro del logo completo di Lucy (coordinate SVG).
    static let riquadro = CGRect(x: 30, y: 82, width: 717, height: 302.72)
    static let disco: (x: Double, y: Double, raggio: Double) = (137.92, 154.08, 48.8)
    static let guide = ["M40 92H200V252H40Z", "M-14 154.08H262", "M137.92 36V270", "M24 268 216 76"]
    static let contornoElle = "M40 252V92H80.8V211.2H200V252Z"
    static let asta = CGRect(x: 40, y: 92, width: 40.8, height: 160)
    static let base = CGRect(x: 40, y: 211.2, width: 160, height: 40.8)
    static let angoloInizio = Double.pi * 0.75
    static let finestraLucy = CGRect(x: 236, y: 82, width: 520, height: 230)
    static let finestraFirma: (x: Double, y: Double, altezza: Double) = (246, 330, 50)
    static let entrataLucy = 30.0
    /// I bordi delle lettere scritte una per volta: b, y, L, O, G, (cursore), C.
    static let bordiFirma: [Double] = [248, 267.6, 287.6, 313.6, 339, 365.2, 365.2, 403]
    /// Il simbolo all'inizio è grande (2,3 volte) e al centro del riquadro, poi si posa al suo posto (120, 172).
    static let posa: (scalaInizio: Double, xInizio: Double, yInizio: Double, xFine: Double, yFine: Double) =
        (2.3, 30 + 717 / 2, 205, 120, 172)

    /// Dove sta ogni pezzo in un istante.
    struct Fotogramma {
        var guide: [Double]
        var opacitaGuide: Double
        var tratto: Double
        var opacitaTratto: Double
        var asta: Double
        var base: Double
        var cerchio: Double
        var opacitaCerchio: Double
        var angoloBraccio: Double
        var opacitaBraccio: Double
        var raggioDisco: Double
        var scala: Double
        var centroX: Double
        var centroY: Double
        var lucy: Double
        var spostamentoLucy: Double
        var bordoFirma: Double
        var cursoreX: Double
        var opacitaCursore: Double
    }

    static func fotogramma(_ t: Double, cursoreAcceso: Bool) -> Fotogramma {
        let tr = TemaVideo.Curva.tratto
        let inOut = TemaVideo.Curva.morbida
        let guide = (0..<4).map { i in inOut(tr(t, Double(i) * 0.09, 0.6 + Double(i) * 0.09)) }
        let compasso = inOut(tr(t, 0.85, 1.65))
        let p = bezier(tr(t, 2.3, 2.95), 0.65, 0, 0.35, 1)
        let lucy = TemaVideo.Curva.posa(tr(t, 2.75, 3.35))
        let passo = Int((tr(t, 3.45, 4.25) * Double(bordiFirma.count - 1) + 1e-6).rounded(.down))
        let bordo = t < 3.45 ? bordiFirma[0] : bordiFirma[min(passo, bordiFirma.count - 1)]
        let cursore = TracciatiMarchio.cursorePiccolo
        let cursoreX: Double
        var opacitaCursore: Double
        if t < 3.4 {
            cursoreX = cursore.minX
            opacitaCursore = 0
        } else if passo < 5 {
            // Mentre scrive, il cursore va avanti con le lettere e batte veloce
            cursoreX = bordo + 3
            opacitaCursore = Int(((t - 3.4) / 0.18).rounded(.down)) % 2 == 1 ? 0.35 : 1
        } else {
            // Al posto della I: acceso fino alla fine del disegno, poi lampeggia
            cursoreX = cursore.minX
            opacitaCursore = t < fine ? 1 : (Int(((t - fine) / 0.55).rounded(.down)) % 2 == 1 ? 0 : 1)
        }
        // Nella chiusura il cursore resta acceso: spento, su un fotogramma fermo, sembrerebbe «LOG C»
        if cursoreAcceso && (opacitaCursore > 0 || t >= fine) { opacitaCursore = 1 }
        return Fotogramma(
            guide: guide,
            opacitaGuide: 0.55 * (1 - tr(t, 2.0, 2.4)),
            tratto: inOut(tr(t, 0.25, 1.05)),
            opacitaTratto: 1 - tr(t, 1.5, 1.85),
            asta: inOut(tr(t, 0.95, 1.25)),
            base: inOut(tr(t, 1.2, 1.5)),
            cerchio: compasso,
            opacitaCerchio: 1 - tr(t, 2.0, 2.25),
            angoloBraccio: angoloInizio + compasso * 2 * .pi,
            opacitaBraccio: min(tr(t, 0.8, 0.9), 1 - tr(t, 1.6, 1.8)),
            raggioDisco: max(0, disco.raggio * bezier(tr(t, 1.55, 2.25), 0.3, 1.45, 0.5, 1)),
            scala: posa.scalaInizio + (1 - posa.scalaInizio) * p,
            centroX: posa.xInizio + (posa.xFine - posa.xInizio) * p,
            centroY: posa.yInizio + (posa.yFine - posa.yInizio) * p,
            lucy: lucy,
            spostamentoLucy: -entrataLucy * (1 - lucy),
            bordoFirma: bordo,
            cursoreX: cursoreX,
            opacitaCursore: opacitaCursore)
    }

    /// Una curva cubic-bezier come quelle del CSS: `x` è il tempo (0–1), il risultato l'avanzamento.
    static func bezier(_ x: Double, _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Double {
        if x <= 0 { return 0 }
        if x >= 1 { return 1 }
        var basso = 0.0, alto = 1.0, s = x
        for _ in 0..<30 {
            s = (basso + alto) / 2
            let u = 1 - s
            let xx = 3 * u * u * s * x1 + 3 * u * s * s * x2 + s * s * s
            if xx < x { basso = s } else { alto = s }
        }
        let u = 1 - s
        return 3 * u * u * s * y1 + 3 * u * s * s * y2 + s * s * s
    }
}

/// Il marchio completo «Lucy by LOGIC» che si disegna, largo `larghezza`; guide e simbolo grande escono sopra e sotto.
struct DisegnoLogoVideo: View {
    let tempo: Double
    let larghezza: CGFloat
    var cursoreAcceso = false

    private static let guide = LogoDisegnatoVideo.guide.map(TracciatoMarchio.interpreta)
    private static let contorno = TracciatoMarchio.interpreta(LogoDisegnatoVideo.contornoElle)

    var body: some View {
        let r = LogoDisegnatoVideo.riquadro
        let k = larghezza / r.width
        let alto = r.height * k
        let extra = TemaVideo.Misura.margineDisegno * k
        let f = LogoDisegnatoVideo.fotogramma(tempo, cursoreAcceso: cursoreAcceso)
        Canvas { ctx, size in
            ctx.concatenate(CGAffineTransform(translationX: (size.width - larghezza) / 2, y: (size.height - alto) / 2)
                .scaledBy(x: k, y: k)
                .translatedBy(x: -r.minX, y: -r.minY))
            Self.simbolo(in: ctx, f)
            Self.nome(in: ctx, f)
        }
        .frame(width: larghezza, height: alto + 2 * extra)
        .padding(.vertical, -extra)
    }

    private static func simbolo(in base: GraphicsContext, _ f: LogoDisegnatoVideo.Fotogramma) {
        let m = TemaVideo.Misura.self
        let c = TemaVideo.Colore.self
        let L = LogoDisegnatoVideo.self
        var ctx = base
        ctx.concatenate(CGAffineTransform(translationX: f.centroX, y: f.centroY)
            .scaledBy(x: f.scala, y: f.scala)
            .translatedBy(x: -L.posa.xFine, y: -L.posa.yFine))
        if f.opacitaGuide > 0 {
            var g = ctx
            g.opacity = f.opacitaGuide
            for (i, p) in guide.enumerated() where f.guide[i] > 0 {
                g.stroke(p.trimmedPath(from: 0, to: f.guide[i]), with: .color(c.by),
                         style: StrokeStyle(lineWidth: m.trattoGuide, lineCap: .round))
            }
        }
        ctx.fill(Path(CGRect(x: L.asta.minX, y: L.asta.minY, width: L.asta.width, height: L.asta.height * f.asta)),
                 with: .color(c.inchiostro))
        ctx.fill(Path(CGRect(x: L.base.minX, y: L.base.minY, width: L.base.width * f.base, height: L.base.height)),
                 with: .color(c.inchiostro))
        if f.tratto > 0 && f.opacitaTratto > 0 {
            var t = ctx
            t.opacity = f.opacitaTratto
            t.stroke(contorno.trimmedPath(from: 0, to: f.tratto), with: .color(c.inchiostro),
                     style: StrokeStyle(lineWidth: m.trattoElle, lineJoin: .miter))
        }
        let d = L.disco
        let centro = CGPoint(x: d.x, y: d.y)
        if f.cerchio > 0 && f.opacitaCerchio > 0 {
            var cerchio = ctx
            cerchio.opacity = f.opacitaCerchio
            let giro = Path { p in
                p.addArc(center: centro, radius: d.raggio, startAngle: .radians(L.angoloInizio),
                         endAngle: .radians(L.angoloInizio + 2 * .pi), clockwise: false)
            }
            cerchio.stroke(giro.trimmedPath(from: 0, to: f.cerchio), with: .color(c.oroMarchio),
                           style: StrokeStyle(lineWidth: m.trattoElle, lineCap: .round))
        }
        if f.opacitaBraccio > 0 {
            var braccio = ctx
            braccio.opacity = f.opacitaBraccio
            let punta = CGPoint(x: d.x + d.raggio * cos(f.angoloBraccio), y: d.y + d.raggio * sin(f.angoloBraccio))
            braccio.stroke(Path { p in p.move(to: centro); p.addLine(to: punta) }, with: .color(c.oroMarchio),
                           style: StrokeStyle(lineWidth: m.trattoGuide, lineCap: .round))
            braccio.fill(Path(ellipseIn: CGRect(x: d.x - m.perno, y: d.y - m.perno, width: 2 * m.perno, height: 2 * m.perno)),
                         with: .color(c.oroMarchio))
        }
        if f.raggioDisco > 0 {
            let rd = f.raggioDisco
            ctx.fill(Path(ellipseIn: CGRect(x: d.x - rd, y: d.y - rd, width: 2 * rd, height: 2 * rd)),
                     with: .color(c.oroMarchio))
        }
    }

    private static func nome(in base: GraphicsContext, _ f: LogoDisegnatoVideo.Fotogramma) {
        let c = TemaVideo.Colore.self
        let L = LogoDisegnatoVideo.self
        if f.lucy > 0 {
            var lucy = base
            lucy.opacity = f.lucy
            lucy.translateBy(x: f.spostamentoLucy, y: 0)
            let w = L.finestraLucy
            lucy.clip(to: Path(CGRect(x: w.minX, y: w.minY, width: w.width * f.lucy, height: w.height)))
            lucy.fill(TracciatoMarchio.leggi(TracciatiMarchio.nome), with: .color(c.inchiostro))
        }
        let w = L.finestraFirma
        if f.bordoFirma > w.x {
            var firma = base
            firma.clip(to: Path(CGRect(x: w.x, y: w.y, width: f.bordoFirma - w.x, height: w.altezza)))
            firma.fill(TracciatoMarchio.leggi(TracciatiMarchio.by), with: .color(c.by))
            firma.fill(TracciatoMarchio.leggi(TracciatiMarchio.logicPiccolo), with: .color(c.inchiostro))
        }
        if f.opacitaCursore > 0 {
            var cursore = base
            cursore.opacity = f.opacitaCursore
            let r = TracciatiMarchio.cursorePiccolo
            cursore.fill(Path(roundedRect: CGRect(x: f.cursoreX, y: r.minY, width: r.width, height: r.height),
                              cornerRadius: 0.67),
                         with: .color(c.oroMarchio))
        }
    }
}
#endif
