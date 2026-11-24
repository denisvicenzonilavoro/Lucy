import SwiftUI
import CoreGraphics

// La scrivania dello stile Carta (template, `#desk` e `#stage:after`): due gradienti radiali, la filigrana del logo
// in basso a destra e la grana della carta. È ferma: gli sfondi animati (Luce del pomeriggio, Inchiostro, Cristallo,
// Carta marmorizzata) arrivano con la novità 12. Niente Metal, niente CVDisplayLink, niente sfocature: meno memoria e
// meno lavoro della scheda grafica rispetto all'acqua.

/// La scrivania di carta, giorno e notte.
struct SfondoCarta: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                // radial-gradient(1600px 1000px at 50% 30%, --desk1, --desk2)
                RadialGradient(colors: [TemaCarta.Colore.scrivania1D, TemaCarta.Colore.scrivania2D],
                               center: UnitPoint(x: 0.5, y: 0.3), startRadius: 0, endRadius: max(w, h) * 0.75)
                // radial-gradient(900px 600px at 16% 10%, luce, transparent 62%)
                RadialGradient(colors: [TemaCarta.Colore.luceScrivaniaD, .clear],
                               center: UnitPoint(x: 0.16, y: 0.1), startRadius: 0, endRadius: max(w, h) * 0.39)
                FiligranaLogo()
                    .frame(width: 560, height: 560)
                    .position(x: w + 60 - 280, y: h - 40 - 280)
                GranaCarta()
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// La filigrana: il prisma «Cristallo» a tratto sottile, al 6-7% dell'inchiostro.
private struct FiligranaLogo: View {
    var body: some View {
        FormaLogoInchiostro()
            .stroke(TemaCarta.Colore.filigranaD, style: StrokeStyle(lineWidth: 1.2, lineJoin: .round))
    }
}

/// La grana della carta: una tessera di rumore generata una volta (sempre uguale, nessun numero casuale del sistema),
/// ripetuta sulla scrivania. Di giorno in moltiplicazione al 22%, di notte in schermo al 6%, come il template.
struct GranaCarta: View {
    @Environment(\.colorScheme) private var schema
    /// La tessera si disegna a un pixel per pixel dello schermo: la grana resta fine anche sul Retina.
    @Environment(\.displayScale) private var scalaSchermo

    var body: some View {
        let notte = schema == .dark
        Image(decorative: Self.tessera, scale: max(1, scalaSchermo))
            .resizable(resizingMode: .tile)
            .opacity(notte ? TemaCarta.Grana.opacitaNotte : TemaCarta.Grana.opacitaGiorno)
            .blendMode(notte ? .screen : .multiply)
            .allowsHitTesting(false)
    }

    /// La tessera, generata alla prima richiesta e tenuta in memoria (200 × 200, circa 160 KB).
    nonisolated(unsafe) static let tessera: CGImage = generaTessera(lato: TemaCarta.Grana.lato)

    /// Rumore grigio caldo come il `feTurbulence` del template (0,5 · 0,45 · 0,35, alfa fino a 0,55), con un
    /// generatore congruenziale fisso: la stessa grana a ogni avvio e nelle istantanee.
    static func generaTessera(lato: Int) -> CGImage {
        var pixel = [UInt8](repeating: 0, count: lato * lato * 4)
        var seme: UInt32 = 0x9E37_79B9
        for i in 0..<(lato * lato) {
            seme = seme &* 1_664_525 &+ 1_013_904_223
            let fine = Double(seme >> 8) / Double(1 << 24)
            let a = min(1, max(0, 0.15 + 0.85 * fine * fine)) * 0.55
            let alfa = Double(UInt8(a * 255))
            // Colori premoltiplicati per l'alfa
            pixel[i * 4 + 0] = UInt8(alfa * 0.50)
            pixel[i * 4 + 1] = UInt8(alfa * 0.45)
            pixel[i * 4 + 2] = UInt8(alfa * 0.35)
            pixel[i * 4 + 3] = UInt8(alfa)
        }
        let spazio = CGColorSpaceCreateDeviceRGB()
        let dati = Data(pixel) as CFData
        let fornitore = CGDataProvider(data: dati)!
        return CGImage(width: lato, height: lato, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: lato * 4,
                       space: spazio, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: fornitore, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
    }
}
