import Foundation

/// Una nota del taccuino: appunti, dettagli e prossimi passi, sempre legati a un cliente.
struct Nota: Identifiable, Codable, Hashable {
    var id = "nota-\(UUID().uuidString.prefix(8).lowercased())"
    var clienteId: String
    var titolo: String
    var testo: String
    /// In evidenza: resta in cima all'elenco.
    var fissata = false
    var creataIl = Nota.adesso
    var aggiornataIl = Nota.adesso

    /// L'archivio salva le date al secondo: le note nascono già così, e si rileggono identiche.
    static var adesso: Date { Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate.rounded(.down)) }

    /// Limite del titolo (come nel template).
    static let limiteTitolo = 180
    /// Caratteri di ogni nota passati a Vera nella scheda del cliente.
    static let limiteVera = 300

    var titoloMostrato: String {
        let t = titolo.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "Nota senza titolo" : t
    }

    /// Le prime parole del testo, su una riga.
    var anteprima: String {
        let compatto = testo.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
        guard !compatto.isEmpty else { return "Una pagina pronta per le tue idee." }
        guard compatto.count > Nota.limiteAnteprima else { return compatto }
        // Si taglia all'ultimo spazio, mai a metà parola
        let inizio = compatto.prefix(Nota.limiteAnteprima)
        let taglio = inizio.lastIndex(of: " ").map { String(inizio[..<$0]) } ?? String(inizio)
        return taglio.trimmingCharacters(in: CharacterSet(charactersIn: " ,;:.")) + "…"
    }

    /// Caratteri dell'anteprima su una riga.
    static let limiteAnteprima = 95

    /// Il testo su una riga, fino a `n` caratteri (per Vera).
    func estratto(_ n: Int) -> String {
        String(testo.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ").prefix(n))
    }

    var vuota: Bool {
        titolo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && testo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Le note fissate prima, poi dalla più recente.
    static func ordina(_ a: Nota, _ b: Nota) -> Bool {
        a.fissata != b.fissata ? a.fissata : a.aggiornataIl > b.aggiornataIl
    }
}

/// Migliorie d'uso 65: la nota in evidenza di un cliente, quella che si ritrova in Panoramica, in «Prima
/// dell'incontro» e nella scheda di Vera. È una nota del taccuino fissata (`id`) oppure «Da ricordare» (`Cliente.nota`,
/// `id` nil): mai una copia dell'una nell'altra (decisione 65-a).
struct NotaInEvidenza: Equatable {
    /// L'id della nota del taccuino; nil per «Da ricordare».
    let id: String?
    let titolo: String
    let testo: String

    var daRicordare: Bool { id == nil }
}

extension Nota {
    /// La nota in evidenza del cliente: la nota fissata più recente (non vuota) fra `note`, altrimenti «Da ricordare»
    /// se non è vuota; nil se non c'è nulla. Negli archivi di prima un cliente può avere più note fissate: vale la più
    /// recente, le altre si mostrano come note normali.
    static func inEvidenza(_ note: [Nota], cliente: Cliente, titoloDaRicordare: String = "Da ricordare") -> NotaInEvidenza? {
        let fissata = note.filter { $0.clienteId == cliente.id && $0.fissata && !$0.vuota }
            .max { $0.aggiornataIl < $1.aggiornataIl }
        if let n = fissata {
            return NotaInEvidenza(id: n.id, titolo: n.titolo.trimmingCharacters(in: .whitespacesAndNewlines),
                                  testo: n.testo.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        let t = cliente.nota.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : NotaInEvidenza(id: nil, titolo: titoloDaRicordare, testo: t)
    }
}
