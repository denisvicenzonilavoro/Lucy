import Foundation

// Il resoconto del turno di notte (NOVITÀ 3 dello stile Carta): al mattino, sulla scrivania e dentro Vera, quanto ha
// lavorato Vera stanotte e cosa ha preparato, contato per tipo di carta. Legge le notti di lavoro di sempre
// (LavoroNotte.swift): niente di nuovo nell'archivio. Puro.

struct ResocontoNotte: Hashable {
    /// I minuti di lavoro (fine meno inizio), nil se la notte non è finita.
    let minuti: Int?
    let inizio: Date?
    let fine: Date?
    /// «6 fascicoli dei prossimi incontri», «3 bozze dei messaggi»… in ordine di lavoro.
    let righe: [String]
    let interrotta: Bool
    let daDecidere: Int

    /// «3 h 12 min».
    var durata: String? {
        guard let m = minuti else { return nil }
        let h = m / 60, r = m % 60
        if h == 0 { return "\(r) min" }
        return r == 0 ? "\(h) h" : "\(h) h \(r) min"
    }
}

enum MotoreResocontoNotte {
    /// Il resoconto della notte più recente fra quelle date (nil se non ce n'è).
    static func ultimo(_ notti: [NotteDiLavoro]) -> ResocontoNotte? {
        guard let n = notti.max(by: { $0.giorno < $1.giorno }) else { return nil }
        return resoconto(n)
    }

    static func resoconto(_ n: NotteDiLavoro) -> ResocontoNotte {
        let minuti: Int? = {
            guard let i = n.inizio, let f = n.fine, f >= i else { return nil }
            return Int((f.timeIntervalSince(i) / 60).rounded())
        }()
        var righe: [String] = []
        for tipo in TipoCartaNotte.allCases {
            let k = n.carte.filter { $0.tipo == tipo }.count
            guard k > 0 else { continue }
            righe.append("\(k) · \(tipo.nome.lowercased())")
        }
        return ResocontoNotte(minuti: minuti, inizio: n.inizio, fine: n.fine, righe: righe,
                              interrotta: n.esito == .interrotta,
                              daDecidere: n.carte.filter { $0.stato == .daDecidere }.count)
    }
}
