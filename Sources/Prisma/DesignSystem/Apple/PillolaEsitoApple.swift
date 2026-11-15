import SwiftUI

/// La pillola dell'esito di una raccomandazione nel tema Apple (Studio › Track record, §4.2.1): «Accettata» verde,
/// «Rifiutata» rossa, «Rimandata» arancio, «In attesa» neutra. Dalle migliorie d'uso 55 è un involucro di
/// `PillolaStatoApple` (stessa capsula, stessi colori, ora in `Tema.Apple.PillolaStato`).
struct PillolaEsitoApple: View {
    let esito: PresentazioneTrackRecord.Esito

    var body: some View {
        PillolaStatoApple(testo: esito.nome, tono: tono, etichettaAccessibile: "Esito: \(esito.nome)")
    }

    private var tono: TonoPillola {
        switch esito {
        case .accettata: return .ok
        case .rifiutata: return .errore
        case .rimandata: return .avviso
        case .inAttesa: return .neutro
        }
    }
}
