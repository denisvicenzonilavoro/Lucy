import SwiftUI

// I caratteri delle viste dello stile Carta che seguono «Dimensione del testo» di Prisma (`\.prismaScalaTesto`, come
// `carattereApple`): ogni dimensione del template si moltiplica per la scala scelta in Impostazioni › Aspetto.
// Restano fisse solo le icone disegnate a misura (IconeCarta) e il logo.

/// Un carattere dello stile Carta: dimensione del template, peso, disegno (New York, SF Pro, SF Mono), corsivo, cifre tabellari.
struct TestoCarta {
    var dimensione: CGFloat
    var peso: Font.Weight = .regular
    var disegno: Font.Design = .default
    var corsivo = false
    var cifre = false

    /// Il carattere alla scala data.
    func font(_ scala: CGFloat) -> Font {
        var f = Font.system(size: dimensione * scala, weight: peso, design: disegno)
        if corsivo { f = f.italic() }
        if cifre { f = f.monospacedDigit() }
        return f
    }

    /// Lo stesso carattere con un altro peso.
    func conPeso(_ p: Font.Weight) -> TestoCarta { var t = self; t.peso = p; return t }
}

private struct ModificatoreTestoCarta: ViewModifier {
    let testo: TestoCarta
    @Environment(\.prismaScalaTesto) private var scala

    func body(content: Content) -> some View {
        content.font(testo.font(scala))
    }
}

extension View {
    /// Un carattere Carta alla «Dimensione del testo» di Prisma.
    func fontCarta(_ t: TestoCarta) -> some View {
        modifier(ModificatoreTestoCarta(testo: t))
    }

    /// Un carattere Carta alla «Dimensione del testo» di Prisma, scritto per esteso.
    func fontCarta(_ dimensione: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default,
                   corsivo: Bool = false, cifre: Bool = false) -> some View {
        modifier(ModificatoreTestoCarta(testo: TestoCarta(dimensione: dimensione, peso: weight, disegno: design,
                                                          corsivo: corsivo, cifre: cifre)))
    }
}
