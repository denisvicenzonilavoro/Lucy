import SwiftUI

/// Lo stato di un obiettivo scritto e colorato (Migliorie d'uso 13, `.st2` del template): «In tempo: ci arriva a
/// ottobre 2029» verde, «In ritardo: ci arriva 1 anno e 2 mesi dopo» arancio, «Senza versamenti non ci arriva» rosso.
/// Capsula 12,5 bold con padding 4×11 sul fondo tenue del tono (`Tema.Apple.Clienti.Obiettivi`). Lo usano la card e
/// il dettaglio dell'obiettivo, con lo stesso testo.
struct StatoArrivoObiettivo: View {
    let arrivo: ArrivoObiettivo

    var body: some View {
        let s = Tema.Apple.Clienti.Obiettivi.self
        let colori = Self.colori(arrivo.tono)
        Text(arrivo.testo)
            .carattereApple(s.statoArrivo)
            .foregroundColor(colori.testo)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(s.paddingStato)
            .background { Capsule(style: .continuous).fill(colori.fondo) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(arrivo.testo))
    }

    /// Testo e fondo del tono.
    static func colori(_ tono: ArrivoObiettivo.Tono) -> (testo: Color, fondo: Color) {
        let s = Tema.Apple.Clienti.Obiettivi.self
        switch tono {
        case .ok: return (s.testoStatoOk, s.fondoStatoOk)
        case .attenzione: return (s.testoStatoAttenzione, s.fondoStatoAttenzione)
        case .errore: return (s.testoStatoErrore, s.fondoStatoErrore)
        }
    }
}
