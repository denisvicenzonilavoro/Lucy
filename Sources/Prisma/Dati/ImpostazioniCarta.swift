import Foundation

// Le impostazioni dello stile Carta (Impostazioni.carta, dal 23 novembre 2026): le sceglie l'utente, mai una regola
// nascosta nel codice. Stanno nell'indice dell'archivio con le altre impostazioni e vanno nei backup; lette con
// tolleranza (senza la chiave, o con un valore illeggibile, i valori di base), senza alzare la versione dell'archivio.

/// Lo sfondo della scrivania e dello sblocco (NOVITÀ 12): quattro sfondi animati o la carta ferma.
enum SfondoScrivaniaCarta: String, Codable, CaseIterable, Identifiable {
    case luce, inchiostro, cristallo, marmo, fermo

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .luce: return "Luce del pomeriggio"
        case .inchiostro: return "Inchiostro"
        case .cristallo: return "Cristallo"
        case .marmo: return "Carta marmorizzata"
        case .fermo: return "Carta ferma"
        }
    }
}

struct ImpostazioniCarta: Codable, Equatable {
    /// Il timbro (NOVITÀ 7): oltre questa quota del patrimonio del cliente una proposta pesa troppo (in %).
    var sogliaPesoTimbro: Double = 30
    /// Il libro mastro (NOVITÀ 9): la quota delle entrate da mettere da parte, in %. nil = non ancora scelta: il codice
    /// non conosce regole fiscali e non ne inventa.
    var quotaAccantonamento: Double?
    /// Lo sfondo della scrivania (NOVITÀ 12): di base la Luce del pomeriggio.
    var sfondo: SfondoScrivaniaCarta = .luce
    /// Il sigillo (NOVITÀ 10): la copia di sicurezza cifrata ogni domenica alle 03:00, se Prisma è aperto.
    var sigilloAutomatico = true

    init() {}

    private enum CodingKeys: String, CodingKey {
        case sogliaPesoTimbro, quotaAccantonamento, sfondo, sigilloAutomatico
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let soglia = (try? c.decodeIfPresent(Double.self, forKey: .sogliaPesoTimbro)) ?? nil
        sogliaPesoTimbro = Self.limitaSoglia(soglia ?? 30)
        let quota = (try? c.decodeIfPresent(Double.self, forKey: .quotaAccantonamento)) ?? nil
        quotaAccantonamento = quota.map(Self.limitaQuota)
        sfondo = ((try? c.decodeIfPresent(SfondoScrivaniaCarta.self, forKey: .sfondo)) ?? nil) ?? .luce
        sigilloAutomatico = ((try? c.decodeIfPresent(Bool.self, forKey: .sigilloAutomatico)) ?? nil) ?? true
    }

    /// La soglia del timbro fra 5% e 100%.
    static func limitaSoglia(_ v: Double) -> Double { v.isFinite ? min(100, max(5, v)) : 30 }
    /// La quota da mettere da parte fra 0% e 90%.
    static func limitaQuota(_ v: Double) -> Double { v.isFinite ? min(90, max(0, v)) : 0 }
}
