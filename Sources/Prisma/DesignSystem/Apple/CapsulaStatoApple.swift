import SwiftUI

/// La capsula di stato del tema Apple (`.st2` del template delle migliorie d'uso): testo 11,5 bold su un fondo tenue
/// nel tono dello stato (`.ok` verde, `.attenzione` arancio, `.errore` rosso, `.neutro` grigio). Riusa i toni di
/// `Pillola.Tono`, come `StatoRigaApple`. Valori in `Tema.Apple.CapsulaStato`.
struct CapsulaStatoApple: View {
    let testo: String
    let tono: Pillola.Tono

    private typealias S = Tema.Apple.CapsulaStato

    var body: some View {
        Text(testo)
            .carattereApple(S.carattere)
            .foregroundColor(colori.testo)
            .lineLimit(1)
            .fixedSize()
            .padding(S.padding)
            .background { Capsule(style: .continuous).fill(colori.fondo) }
    }

    private var colori: (testo: Color, fondo: Color) {
        switch tono {
        case .ok: return (S.testoOk, S.fondoOk)
        case .attenzione: return (S.testoAttenzione, S.fondoAttenzione)
        case .errore: return (S.testoErrore, S.fondoErrore)
        case .neutro: return (S.testoNeutro, S.fondoNeutro)
        }
    }
}
