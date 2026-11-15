import SwiftUI

// Migliorie d'uso 49 (Design/uso/gruppo-08.md §49, `.cmCk` del template): la casella quadrata da spuntare del tema
// Apple, 18 × 18 con raggio 6. Vuota: bordo 1,6 `inchiostro3`. Scelta: piena d'accento con la spunta bianca.
// La usa il passo «Chi» della campagna (Messaggi › Campagne); è un disegno, l'azione la mette chi la usa.

extension Tema.Apple.Controlli {
    enum CasellaScelta {
        static let lato: CGFloat = 18
        static let raggio: CGFloat = 6
        static let bordo: CGFloat = 1.6
        static let coloreBordo = Tema.Apple.Colore.inchiostro3
        static let fondoScelta = Tema.Apple.Colore.accento
        static let spunta = Tema.Apple.Carattere(dimensione: 10, peso: .bold)
        static let coloreSpunta = Tema.Apple.Controlli.Pulsante.testoPrincipale
    }
}

/// La casella quadrata da spuntare: vuota col bordo, o piena d'accento con la spunta.
///
///     CasellaSceltaApple(scelta: incluso)
struct CasellaSceltaApple: View {
    let scelta: Bool

    private typealias K = Tema.Apple.Controlli.CasellaScelta

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: K.raggio, style: .continuous)
        ZStack {
            if scelta {
                forma.fill(K.fondoScelta)
                Image(systemName: "checkmark")
                    .carattereApple(K.spunta)
                    .foregroundColor(K.coloreSpunta)
            } else {
                forma.strokeBorder(K.coloreBordo, lineWidth: K.bordo)
            }
        }
        .frame(width: K.lato, height: K.lato)
        .contentShape(forma)
        .accessibilityHidden(true)
    }
}
