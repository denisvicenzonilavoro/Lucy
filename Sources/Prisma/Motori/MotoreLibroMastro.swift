import Foundation

// Il libro mastro (NOVITÀ 9 dello stile Carta): per ogni mese le entrate (provvigioni dai cedolini e parcelle incassate),
// la quota da mettere da parte (la percentuale la sceglie l'utente: nessuna regola fiscale nel codice), le spese dello
// studio e quanto resta da spendere. Puro: niente SwiftUI, niente rete, le date le passa chi chiede.

struct MeseLibroMastro: Hashable, Identifiable {
    /// Il primo giorno del mese.
    let mese: Date
    let provvigioni: Double
    let parcelle: Double
    let spese: Double
    /// La quota da mettere da parte in % (nil = non ancora scelta).
    let quota: Double?

    var id: Date { mese }
    var entrate: Double { provvigioni + parcelle }
    /// Da mettere da parte: le entrate per la quota scelta (nil senza quota).
    var accantonamento: Double? { quota.map { entrate * $0 / 100 } }
    /// Quanto si può spendere: entrate meno accantonamento meno spese (nil senza quota).
    var disponibile: Double? { accantonamento.map { entrate - $0 - spese } }
}

enum MotoreLibroMastro {
    /// Il mese che contiene `data`.
    static func mese(_ data: Date, cedolini: [CedolinoProvvigioni], parcelle: [Parcella], spese: [SpesaStudio],
                     quota: Double?, calendario cal: Calendar = Calendar(identifier: .gregorian)) -> MeseLibroMastro {
        let inizio = cal.date(from: cal.dateComponents([.year, .month], from: data)) ?? data
        let fine = cal.date(byAdding: .month, value: 1, to: inizio) ?? data
        func dentro(_ d: Date) -> Bool { d >= inizio && d < fine }
        let provvigioni = cedolini.filter { dentro($0.mese) }.reduce(0) { $0 + $1.lordo }
        let incassate = parcelle.filter { $0.stato == .pagata && $0.incassataIl.map(dentro) == true }
        let parcelleMese = incassate.reduce(0) { somma, p in somma + p.righe.reduce(0) { $0 + $1.importo } }
        let speseMese = spese.filter { dentro($0.data) }.reduce(0) { $0 + $1.importo }
        return MeseLibroMastro(mese: inizio, provvigioni: provvigioni, parcelle: parcelleMese, spese: speseMese,
                               quota: quota.map(ImpostazioniCarta.limitaQuota))
    }

    /// Gli ultimi `mesi` mesi fino a quello di `data`, dal più recente.
    static func ultimi(_ mesi: Int, al data: Date, cedolini: [CedolinoProvvigioni], parcelle: [Parcella],
                       spese: [SpesaStudio], quota: Double?, calendario cal: Calendar = Calendar(identifier: .gregorian)) -> [MeseLibroMastro] {
        (0..<max(0, mesi)).compactMap { k in
            cal.date(byAdding: .month, value: -k, to: data).map {
                mese($0, cedolini: cedolini, parcelle: parcelle, spese: spese, quota: quota, calendario: cal)
            }
        }
    }
}
