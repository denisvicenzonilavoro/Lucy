import SwiftUI

/// Il numerino in pillola accanto all'occhiello di un gruppo (migliorie d'uso 25, `.bN2` del template): 11 bold, fondo
/// `chip`, testo `inchiostro2`, a capsula. Lo usa la colonna di Messaggi («Da mandare oggi 3») ed è pensato anche per
/// gli altri elenchi a gruppi (le «Occasioni» dell'Agenda). Valori in `Tema.Apple.Messaggi.Colonna`.
struct NumeroOcchielloApple: View {
    let numero: Int

    private typealias C = Tema.Apple.Messaggi.Colonna

    var body: some View {
        Text("\(numero)")
            .carattereApple(C.numeroOcchiello)
            .foregroundColor(C.coloreNumeroOcchiello)
            .lineLimit(1)
            .fixedSize()
            .padding(C.paddingNumeroOcchiello)
            .background { Capsule(style: .continuous).fill(C.fondoNumeroOcchiello) }
    }
}
