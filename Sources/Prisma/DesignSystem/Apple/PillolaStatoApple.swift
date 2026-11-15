import SwiftUI

/// Il tono di una pillola di stato: verde (ok), rosso (errore), arancio (avviso) o grigio (neutro).
enum TonoPillola: Equatable {
    case ok, errore, avviso, neutro
}

/// La pillola di stato del tema Apple (migliorie d'uso 55): capsula 12 bold con padding 4×10 e un testo qualsiasi,
/// nei colori di `Tema.Apple.PillolaStato`. La usano la pillola dell'esito del track record (`PillolaEsitoApple`) e il
/// bilancio del quiz OCF («Fatta», «Torna domani», «Saltata: torna domani»).
struct PillolaStatoApple: View {
    let testo: String
    let tono: TonoPillola
    /// Il testo per VoiceOver, se diverso da quello mostrato.
    var etichettaAccessibile: String? = nil

    var body: some View {
        let t = Tema.Apple.PillolaStato.self
        Text(testo)
            .carattereApple(t.carattere)
            .foregroundColor(colori.testo)
            .lineLimit(1)
            .fixedSize()
            .padding(t.padding)
            .background { Capsule(style: .continuous).fill(colori.fondo) }
            .accessibilityLabel(Text(etichettaAccessibile ?? testo))
    }

    private var colori: (testo: Color, fondo: Color) {
        let t = Tema.Apple.PillolaStato.self
        switch tono {
        case .ok: return (t.testoOk, t.fondoOk)
        case .errore: return (t.testoErrore, t.fondoErrore)
        case .avviso: return (t.testoAvviso, t.fondoAvviso)
        case .neutro: return (t.testoNeutro, t.fondoNeutro)
        }
    }
}
