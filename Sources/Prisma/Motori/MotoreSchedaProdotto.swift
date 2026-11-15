import Foundation

/// Migliorie d'uso 63 «I prodotti parlano chiaro»: l'esito di una scheda per il cliente scelto e le frasi «È per» /
/// «Non è per» proposte dai dati della scheda. Motore puro, senza stato: le viste lo chiamano dentro `stato.ricavato`.
///
/// Decisione presa (Design/template-uso-specifica.md): nessun campo nuovo in `Prodotto`; le frasi le propone il codice
/// con regole fisse dai dati della scheda (periodo raccomandato, garanzie, minimo garantito, SRI, area), mai cifre
/// inventate e mai testi di Vera. La frase «In una frase» non si scrive da sola: senza un testo del consulente il
/// riquadro non c'è.
enum EsitoProdottoCliente: Equatable {
    /// L'area della scheda è fra le prime tre priorità del cliente (le stesse della miglioria 17).
    case priorita
    /// Né priorità né oltre il profilo.
    case inLinea
    /// L'SRI della scheda supera quello massimo della propensione del cliente (`MotoreCoerenza.sriMassimo`).
    case oltreProfilo

    /// Ordine nell'elenco: prima le priorità, poi in linea, poi oltre il profilo.
    var ordine: Int {
        switch self {
        case .priorita: return 0
        case .inLinea: return 1
        case .oltreProfilo: return 2
        }
    }
}

enum MotoreSchedaProdotto {
    /// L'esito della scheda per un cliente. Decisione 63-c: la soglia di sempre (`MotoreCoerenza.sriMassimo`, la
    /// stessa delle incoerenze in Posizioni), senza il punto di tolleranza del template. Senza propensione nel profilo
    /// niente «oltre il profilo»; senza SRI nella scheda nemmeno.
    static func esito(_ p: Prodotto, propensione: ProfiloInvestitore.Propensione?, priorita: [AreaAnalisi]) -> EsitoProdottoCliente {
        if let sri = p.sri, let propensione, sri > MotoreCoerenza.sriMassimo(propensione) {
            return .oltreProfilo
        }
        if priorita.prefix(PrioritaAree360.massimo).contains(where: { $0.areaPosizioni == p.area }) {
            return .priorita
        }
        return .inLinea
    }

    /// Le schede in ordine per il cliente: priorità, in linea, oltre il profilo; a parità l'ordine ricevuto (per nome).
    /// Una scheda senza esito conta come «in linea».
    static func ordina(_ schede: [Prodotto], esiti: [String: EsitoProdottoCliente]) -> [Prodotto] {
        schede.enumerated().sorted { a, b in
            let oa = (esiti[a.element.id] ?? .inLinea).ordine
            let ob = (esiti[b.element.id] ?? .inLinea).ordine
            return oa != ob ? oa < ob : a.offset < b.offset
        }.map(\.element)
    }

    /// «È per» e «Non è per» scritte da Prisma dai dati della scheda (regole fisse, al più tre righe ciascuna).
    struct Proposta: Equatable {
        var perChi: [String]
        var nonPerChi: [String]

        var vuota: Bool { perChi.isEmpty && nonPerChi.isEmpty }
    }

    static let righeMassime = 3

    /// Le frasi proposte per la scheda.
    static func proposta(_ p: Prodotto) -> Proposta {
        var per: [String] = []
        var non: [String] = []
        let anni = p.periodoConsigliato.flatMap { $0 > 0 ? $0 : nil }
        if p.area.proiettabile, let anni {
            per.append("Chi ha almeno \(TestiCatalogo.anni(anni)) davanti")
        }
        if garantito(p) {
            per.append("Chi vuole il capitale protetto")
        }
        switch p.area {
        case .protezione: per.append("Chi vuole molta protezione con poca spesa")
        case .previdenza: per.append("Chi vuole una pensione più alta")
        default: break
        }
        if p.area.proiettabile, let anni {
            non.append("Chi può avere bisogno di quei soldi prima di \(TestiCatalogo.anni(anni))")
        }
        if p.area.proiettabile, let sri = p.sri {
            if sri >= 4 { non.append("Chi non sopporta di vedere il valore scendere") }
            if sri <= 2 { non.append("Chi cerca la crescita dei mercati") }
        }
        if p.area == .protezione {
            non.append("Chi cerca un rendimento")
        }
        return Proposta(perChi: Array(per.prefix(righeMassime)), nonPerChi: Array(non.prefix(righeMassime)))
    }

    /// La scheda dice una garanzia sul capitale: un minimo garantito o il campo «Garanzie» che ne parla (e non la nega).
    static func garantito(_ p: Prodotto) -> Bool {
        if p.minimoGarantito != nil { return true }
        let g = p.garanzie.lowercased()
        guard !g.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if g.contains("nessuna") || g.contains("non garantit") || g.contains("senza garanzi") { return false }
        return g.contains("garanti") || g.contains("garanzia") || g.contains("protett")
    }

    // MARK: - 63-d «Quanto costa, per dare un'idea» (protezione)

    /// Il capitale del premio indicativo della protezione.
    static let capitaleIndicativo: Double = 100_000

    /// Il premio annuo indicativo di una scheda di protezione per `capitaleIndicativo` di capitale, dalla tariffa delle
    /// coperture caso morte in archivio (`MotoreSimulatoriAnalisi.tariffaCasoMorte`), arrotondato a 10 €. nil se la scheda
    /// non è di protezione o non c'è una stima: allora il riquadro non c'è (decisione 63-d, niente premio fisso).
    static func premioIndicativo(_ p: Prodotto, tariffa: MotoreSimulatoriAnalisi.TariffaCasoMorte?) -> Double? {
        guard p.area == .protezione, let t = tariffa, t.perMille > 0 else { return nil }
        let premio = t.perMille * capitaleIndicativo / 1_000
        return max(10, (premio / 10).rounded() * 10)
    }
}
