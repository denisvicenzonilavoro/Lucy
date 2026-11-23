import SwiftUI

// Il logo dello stile Carta: il prisma «Cristallo» a tratto d'inchiostro, con la sottolineatura dorata disegnata a
// mano (template, `.logo` nel blocco e `#menubar .lg` nella barra). Il triangolo e i tre spicchi sono quelli del logo
// di Prisma (Design/Logo/); `LogoPrisma` resta per i PDF e l'iPhone. Si chiama «inchiostro» per non confondersi con
// `CristalloFermo` della realtà aumentata.

/// Il triangolo esterno (viewBox 96 × 96 del template: M48 10 L84 74 L12 74 Z).
struct FormaLogoInchiostro: Shape {
    func path(in r: CGRect) -> Path {
        let s = min(r.width, r.height) / 96
        let o = CGPoint(x: r.midX - 48 * s, y: r.midY - 48 * s)
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: o.x + x * s, y: o.y + y * s) }
        var path = Path()
        path.move(to: p(48, 10))
        path.addLine(to: p(84, 74))
        path.addLine(to: p(12, 74))
        path.closeSubpath()
        return path
    }
}

/// I tre spigoli interni che dividono gli spicchi (M48 10 L48 52.7 M48 52.7 L84 74 M48 52.7 L12 74).
struct FormaLogoSpigoli: Shape {
    func path(in r: CGRect) -> Path {
        let s = min(r.width, r.height) / 96
        let o = CGPoint(x: r.midX - 48 * s, y: r.midY - 48 * s)
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: o.x + x * s, y: o.y + y * s) }
        var path = Path()
        path.move(to: p(48, 10)); path.addLine(to: p(48, 52.7))
        path.move(to: p(48, 52.7)); path.addLine(to: p(84, 74))
        path.move(to: p(48, 52.7)); path.addLine(to: p(12, 74))
        return path
    }
}

/// La sottolineatura dorata sotto il prisma (M18 88 C 38 84, 58 90, 80 85).
struct FormaLogoOro: Shape {
    func path(in r: CGRect) -> Path {
        let s = min(r.width, r.height) / 96
        let o = CGPoint(x: r.midX - 48 * s, y: r.midY - 48 * s)
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: o.x + x * s, y: o.y + y * s) }
        var path = Path()
        path.move(to: p(18, 88))
        path.addCurve(to: p(80, 85), control1: p(38, 84), control2: p(58, 90))
        return path
    }
}

/// Il logo a inchiostro. Con `disegna` il tratto si traccia alla comparsa (triangolo, spigoli, poi l'oro), come nel
/// blocco del template; nelle istantanee e con «Riduci movimento» è già tutto al suo posto.
struct LogoInchiostro: View {
    var lato: CGFloat
    var disegna = false
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var tratto: CGFloat = 0

    /// Spessori del template in proporzione al viewBox da 96: 2,2 il triangolo, 1,2 gli spigoli, 3,4 l'oro.
    /// Sotto i 24 pt (la barra) si usano quelli dell'icona da 40 (2,6 · 1,3 · 2,6), più pieni.
    private var piccolo: Bool { lato < 24 }
    private var scala: CGFloat { lato / (piccolo ? 40 : 96) }

    var body: some View {
        let fatto: CGFloat = (statoFinale || !disegna) ? 1 : tratto
        ZStack {
            FormaLogoInchiostro()
                .trim(from: 0, to: min(1, fatto * 1.6))
                .stroke(TemaCarta.Colore.inchiostroD,
                        style: StrokeStyle(lineWidth: (piccolo ? 2.6 : 2.2) * scala, lineCap: .round, lineJoin: .round))
            FormaLogoSpigoli()
                .trim(from: 0, to: max(0, min(1, fatto * 2 - 0.6)))
                .stroke(TemaCarta.Colore.inchiostroD,
                        style: StrokeStyle(lineWidth: (piccolo ? 1.3 : 1.2) * scala, lineCap: .round, lineJoin: .round))
                .opacity(0.5)
            FormaLogoOro()
                .trim(from: 0, to: max(0, min(1, fatto * 2.5 - 1.5)))
                .stroke(TemaCarta.Colore.oroD,
                        style: StrokeStyle(lineWidth: (piccolo ? 2.6 : 3.4) * scala, lineCap: .round))
        }
        .frame(width: lato, height: lato)
        .accessibilityHidden(true)
        .onAppear {
            guard disegna, !statoFinale else { return }
            withAnimation(Tema.Apple.Moto.Curva.ease.animazione(TemaCarta.Moto.logo)) { tratto = 1 }
        }
    }
}

extension TemaCarta {
    /// I tempi dello stile Carta (secondi del template; si percorrono al ritmo `Tema.Apple.Moto.ritmo`).
    enum Moto {
        /// Il logo che si disegna nel blocco: triangolo 1,1 s, spigoli 0,8 s, oro 0,7 s, in tutto circa 2,1 s.
        static let logo: Double = 2.1
        /// La sottolineatura dorata (`.ann.line`).
        static let sottolineatura: Double = 0.9
        /// Il cerchio rosso (`.ann.circ`).
        static let cerchio: Double = 1.1
        /// L'evidenziatore (`[data-a=mk]`).
        static let evidenziatore: Double = 0.75
        /// Il contachilometri dei totali.
        static let contachilometri: Double = 1.4
    }
}
