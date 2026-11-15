import Foundation

/// Migliorie d'uso 34 «Le esperienze della Sala, al momento giusto»: i testi delle indicazioni di lavoro sulla griglia
/// della Sala (momento e durata di ogni esperienza, il filtro in testa, le due consigliate). Non compaiono mai davanti
/// al cliente (modalità cliente, vista pulita, presentazione, tavolo).
enum TestiSala {
    /// La voce del filtro che mostra tutte le esperienze.
    static let tutte = "Tutte"

    /// L'etichetta in alto a destra della scheda: «Per aprire · 2 min»; senza durata solo il momento
    /// («Dopo l’incontro»).
    static func momento(_ e: EsperienzaSala) -> String {
        guard let m = e.minuti, m > 0 else { return e.momento.titolo }
        return "\(e.momento.titolo) · \(m) min"
    }

    /// L'etichetta verde delle esperienze consigliate dalle priorità del cliente.
    static func consigliata(_ nome: String) -> String { "Consigliata per \(nome)" }

    /// Ciò che VoiceOver aggiunge al nome della scheda.
    static func accessibilita(_ e: EsperienzaSala, consigliata nome: String?) -> String {
        var testo = momento(e)
        if let m = e.minuti, m > 0 { testo = "\(e.momento.titolo), circa \(m) minuti" }
        if let nome { testo += ". \(consigliata(nome))" }
        return testo
    }

    /// L'aiuto del filtro nella testata.
    static let aiutoFiltro = "Attenua le esperienze che non servono in questo momento dell'incontro"
}
