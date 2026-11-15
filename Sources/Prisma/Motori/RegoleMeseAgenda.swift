import Foundation

/// Migliorie d'uso 50 (Design/uso/gruppo-08.md §50): le regole del mese a tutta larghezza, pure e senza viste, così le
/// prove le controllano. Quante righe stanno in una cella (al più due impegni, uno solo se nel giorno c'è una scadenza,
/// poi le scadenze scritte e «+N altri»), e i testi della colonna del giorno («nessun impegno», «solo Marco»,
/// «Giornata libera per Marco.»). La vista sta in Shell/AgendaMeseUso.swift (solo Mac).
enum RegoleMeseAgenda {
    /// Le righe di una cella: quante pillole degli impegni, quante scadenze scritte, quante cose restano in «+N».
    struct Righe: Equatable {
        let pillole: Int
        let scadenze: Int
        let altri: Int
    }

    /// Al più due impegni per cella (`.mEv` del template).
    static let pilloleMassime = 2

    /// Le righe di una cella con `appuntamenti` impegni e `scadenze` scadenze, se ci stanno `posto` righe.
    /// Con una scadenza nel giorno un impegno solo; se le righe non bastano si tolgono prima le scadenze oltre la
    /// prima, poi gli impegni, e ciò che manca va in «+N altri» (che occupa una riga anche lui).
    static func righe(appuntamenti: Int, scadenze: Int, posto: Int) -> Righe {
        let a = max(0, appuntamenti)
        let s = max(0, scadenze)
        let spazio = max(0, posto)
        var p = min(a, s > 0 ? 1 : pilloleMassime)
        var sc = s
        func servono() -> Int { p + sc + ((a - p) + (s - sc) > 0 ? 1 : 0) }
        while servono() > spazio && (p > 0 || sc > 0) {
            if sc > 1 || (sc == 1 && p == 0) {
                sc -= 1
            } else {
                p -= 1
            }
        }
        return Righe(pillole: p, scadenze: sc, altri: (a - p) + (s - sc))
    }

    /// «+1 altro», «+3 altri».
    static func altri(_ n: Int) -> String { "+\(n) \(n == 1 ? "altro" : "altri")" }

    /// La scadenza scritta nella cella: «Scade Infortuni famiglia».
    static func scadenza(_ nome: String) -> String { "Scade \(nome)" }

    /// Il nome nella pillola: il nome breve del cliente, il titolo dell'impegno solo se non c'è un cliente.
    static func nomePillola(cliente: String?, titolo: String) -> String {
        if let cliente, !cliente.isEmpty { return cliente }
        return titolo
    }

    /// L'occhiello della colonna del giorno: «OGGI» o il mese e l'anno («NOVEMBRE 2026»).
    static func occhiello(_ giorno: Date, oggi: Bool) -> String {
        oggi ? "OGGI" : Formati.meseAnno.string(from: giorno).uppercased()
    }

    /// Il titolo della colonna: «lunedì 2 novembre».
    static func titolo(_ giorno: Date) -> String { Formati.dataLunga.string(from: giorno) }

    /// «2 impegni · 1 scadenza · solo Marco», «nessun impegno».
    static func conteggio(impegni: Int, scadenze: Int, solo nome: String?) -> String {
        var testo = impegni == 0 ? "nessun impegno" : "\(impegni) \(impegni == 1 ? "impegno" : "impegni")"
        if scadenze > 0 { testo += " · \(scadenze) \(scadenze == 1 ? "scadenza" : "scadenze")" }
        if let nome, !nome.isEmpty { testo += " · solo \(nome)" }
        return testo
    }

    /// Il giorno senza impegni né scadenze: «Giornata libera.» o «Giornata libera per Marco.».
    static func giornataLibera(per nome: String?) -> String {
        if let nome, !nome.isEmpty { return "Giornata libera per \(nome)." }
        return "Giornata libera."
    }

    /// Sotto «Giornata libera».
    static let notaGiornataLibera = "È un buon posto per un impegno nuovo."

    /// Il nome sotto il titolo di una riga della colonna: il cliente o «Per te».
    static func sottoRiga(cliente: String?) -> String {
        if let cliente, !cliente.isEmpty { return cliente }
        return "Per te"
    }
}
