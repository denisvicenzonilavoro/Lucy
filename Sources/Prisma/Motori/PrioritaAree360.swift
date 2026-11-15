import Foundation

/// Migliorie d'uso 17 «Le priorità in ordine: 1, 2, 3»: da quale area di Analisi 360 partire con il cliente.
/// - Dalla ruota dei bisogni (la fonte di sempre, che orienta anche la traccia di Vera): si prendono i primi tre bisogni
///   di `MotoreBisogni.priorita` (gli stessi tre che la scheda Bisogni numera) e si tiene la prima volta che compare ogni
///   area di analisi. Con un doppione (famiglia e salute → Protezione; casa e lavoro → Risparmio) le priorità sono due:
///   non si va a pescare il quarto bisogno, così ogni «Priorità n» ha la sua riga nella scheda Bisogni.
/// - Senza ruota (nessun bisogno che conta) l'ordine del template: dall'area più scoperta (copertura dell'anello più
///   bassa), escluse quelle coperte del tutto, gli investimenti dall'80% in su e le aree che non si misurano.
/// Al massimo tre, mai due uguali. Nessuna formula nuova: le coperture sono quelle delle card (`MotoreAree360`).
struct PrioritaAree360: Equatable {
    enum Fonte: Equatable { case ruota, copertura, nessuna }

    /// Le aree in ordine: la prima è «Priorità 1».
    let aree: [AreaAnalisi]
    let fonte: Fonte

    static let massimo = 3
    /// Investimenti da questa quota in su non sono una priorità (come nel template, `p >= 80`).
    static let sogliaInvestimenti = 0.8

    static let vuota = PrioritaAree360(aree: [], fonte: .nessuna)

    /// Il numero della priorità dell'area (1, 2, 3) o nil.
    func numero(_ area: AreaAnalisi) -> Int? {
        aree.firstIndex(of: area).map { $0 + 1 }
    }

    /// I primi tre bisogni portati sulle aree di analisi, senza doppioni.
    static func dallaRuota(_ bisogni: [AreaBisogno]) -> [AreaAnalisi] {
        var esito: [AreaAnalisi] = []
        for b in bisogni.prefix(massimo) where !esito.contains(b.areaAnalisi) {
            esito.append(b.areaAnalisi)
        }
        return esito
    }

    /// Dall'area più scoperta, a parità nell'ordine delle card.
    static func dallaCopertura(_ aree: [SintesiArea360]) -> [AreaAnalisi] {
        var scoperte: [(area: AreaAnalisi, frazione: Double, ordine: Int)] = []
        for (i, s) in aree.enumerated() {
            guard let f = s.frazione, f < 1 else { continue }
            if s.area == .investimenti && f >= sogliaInvestimenti { continue }
            scoperte.append((area: s.area, frazione: f, ordine: i))
        }
        let ordinate = scoperte.sorted { a, b in
            a.frazione != b.frazione ? a.frazione < b.frazione : a.ordine < b.ordine
        }
        var esito: [AreaAnalisi] = []
        for s in ordinate where !esito.contains(s.area) && esito.count < massimo {
            esito.append(s.area)
        }
        return esito
    }

    /// L'ordine per la griglia: dalla ruota se c'è, altrimenti (solo con `ripiego`) dall'area più scoperta.
    static func calcola(bisogni: [AreaBisogno], aree: [SintesiArea360], ripiego: Bool) -> PrioritaAree360 {
        let ruota = dallaRuota(bisogni)
        if !ruota.isEmpty { return PrioritaAree360(aree: ruota, fonte: .ruota) }
        guard ripiego else { return .vuota }
        let scoperte = dallaCopertura(aree)
        return scoperte.isEmpty ? .vuota : PrioritaAree360(aree: scoperte, fonte: .copertura)
    }

    /// Bisogni e card contano allo stesso modo: nessun doppione fra i primi tre bisogni, quindi il numero di ogni riga
    /// della scheda Bisogni è quello della sua capsula sulle card. Falso con la ruota vuota.
    static func stessaNumerazione(_ bisogni: [AreaBisogno]) -> Bool {
        let primi = min(bisogni.count, massimo)
        return primi > 0 && dallaRuota(bisogni).count == primi
    }
}
