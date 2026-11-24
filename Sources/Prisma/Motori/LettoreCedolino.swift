import Foundation

// Il lettore del cedolino delle provvigioni (NOVITÀ 9, il libro mastro): dal testo del PDF, letto sul Mac, trova il mese,
// il totale delle provvigioni e il netto pagato. Solo regole, nessun modello e nessuna rete: il consulente conferma
// sempre le cifre prima di registrarle. Puro: riceve il testo, restituisce ciò che ha trovato (nil = non trovato).

struct CedolinoLetto: Equatable {
    var mese: Date?
    var lordo: Double?
    var netto: Double?
}

enum LettoreCedolino {
    private static let mesi = ["gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto",
                               "settembre", "ottobre", "novembre", "dicembre"]
    /// Un importo all'italiana: 1.234,56 oppure 234,56.
    private static let numero = #"(\d{1,3}(?:\.\d{3})*,\d{2})"#

    /// Un cedolino sta in poche pagine: oltre si legge solo l'inizio.
    static let caratteriMassimi = 200_000

    static func leggi(_ intero: String, calendario: Calendar = Calendar(identifier: .gregorian)) -> CedolinoLetto {
        let testo = String(intero.prefix(caratteriMassimi))
        return CedolinoLetto(mese: mese(testo, calendario: calendario),
                      lordo: primo([#"(?i)totale\s+provvigioni[^\d\n]*"# + numero,
                                    #"(?i)provvigioni\s+(?:lorde|maturate|del\s+mese)[^\d\n]*"# + numero,
                                    #"(?i)provvigioni[^\d\n]*"# + numero], in: testo),
                      netto: primo([#"(?i)netto\s+(?:a\s+pagare|da\s+pagare|in\s+pagamento|liquidato|pagato)[^\d\n]*"# + numero,
                                    #"(?i)totale\s+netto[^\d\n]*"# + numero], in: testo))
    }

    /// Il primo importo trovato con il primo schema che funziona.
    static func primo(_ schemi: [String], in testo: String) -> Double? {
        for schema in schemi {
            guard let r = try? NSRegularExpression(pattern: schema),
                  let m = r.firstMatch(in: testo, range: NSRange(testo.startIndex..., in: testo)),
                  m.numberOfRanges > 1, let g = Range(m.range(at: m.numberOfRanges - 1), in: testo) else { continue }
            if let v = importo(String(testo[g])) { return v }
        }
        return nil
    }

    /// «1.234,56» → 1234.56.
    static func importo(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "."))
    }

    /// Il mese del cedolino: «novembre 2026» o «11/2026» (il primo che compare), al primo del mese.
    static func mese(_ testo: String, calendario cal: Calendar) -> Date? {
        let basso = testo.lowercased()
        let nomi = mesi.joined(separator: "|")
        if let r = try? NSRegularExpression(pattern: "(\(nomi))\\s+(\\d{4})"),
           let m = r.firstMatch(in: basso, range: NSRange(basso.startIndex..., in: basso)),
           let gm = Range(m.range(at: 1), in: basso), let ga = Range(m.range(at: 2), in: basso),
           let indice = mesi.firstIndex(of: String(basso[gm])), let anno = Int(basso[ga]) {
            return cal.date(from: DateComponents(year: anno, month: indice + 1, day: 1))
        }
        if let r = try? NSRegularExpression(pattern: #"\b(0?[1-9]|1[0-2])/(20\d{2})\b"#),
           let m = r.firstMatch(in: basso, range: NSRange(basso.startIndex..., in: basso)),
           let gm = Range(m.range(at: 1), in: basso), let ga = Range(m.range(at: 2), in: basso),
           let mese = Int(basso[gm]), let anno = Int(basso[ga]) {
            return cal.date(from: DateComponents(year: anno, month: mese, day: 1))
        }
        return nil
    }
}
