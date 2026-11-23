import Foundation

// La Prima Pagina (NOVITÀ 1 dello stile Carta): il giornale della giornata che Vera «stampa» alle 6 del mattino, con
// l'edizione della sera alle 18 (che guarda a domani). Agenda, chi chiamare, scadenze, il numero del giorno, i mercati
// (solo se l'utente ha acceso i dati di mercato) e una nota di Vera. Ogni frase la scrive il codice con i dati di Prisma.
// Puro: riceve gli ingressi già scelti dallo stato, restituisce la pagina.

struct IncontroPrimaPagina: Hashable {
    let ora: Date
    let chi: String
    let cosa: String
}

struct ScadenzaPrimaPagina: Hashable {
    let cliente: String
    let posizione: String
    let data: Date
    let valore: Double
}

struct ChiamataPrimaPagina: Hashable {
    let chi: String
    let perche: String
}

struct MercatoPrimaPagina: Hashable {
    let nome: String
    let valore: String
    let variazione: String
}

struct IngressiPrimaPagina {
    var data: Date
    /// Mattino: gli incontri di oggi; sera: quelli di domani.
    var incontri: [IncontroPrimaPagina] = []
    var scadenze: [ScadenzaPrimaPagina] = []
    var daChiamare: [ChiamataPrimaPagina] = []
    /// Il numero del giorno: il patrimonio seguito e quanti clienti.
    var patrimonio: Double = 0
    var clienti: Int = 0
    var mercati: [MercatoPrimaPagina] = []
    var notaVera: String?
}

struct PrimaPagina: Hashable {
    enum Edizione: String {
        case mattino, sera
        var nome: String { self == .mattino ? "Edizione delle 06:00" : "Edizione delle 18:00" }
    }

    let edizione: Edizione
    /// Il numero del giornale: il giorno dell'anno.
    let numero: Int
    let data: Date
    let titolo: String
    let incontri: [IncontroPrimaPagina]
    let scadenze: [ScadenzaPrimaPagina]
    let daChiamare: [ChiamataPrimaPagina]
    let numeroDelGiorno: String
    let didascaliaNumero: String
    let mercati: [MercatoPrimaPagina]
    let notaVera: String?
}

enum MotorePrimaPagina {
    /// L'edizione della sera esce alle 18.
    static let oraSera = 18
    /// Le scadenze che fanno notizia: entro 45 giorni.
    static let giorniScadenze = 45

    static func edizione(_ data: Date, calendario cal: Calendar = .current) -> PrimaPagina.Edizione {
        cal.component(.hour, from: data) >= oraSera ? .sera : .mattino
    }

    static func componi(_ i: IngressiPrimaPagina, calendario cal: Calendar = .current) -> PrimaPagina {
        let ed = edizione(i.data, calendario: cal)
        let limite = cal.date(byAdding: .day, value: giorniScadenze, to: i.data) ?? i.data
        let scadenze = i.scadenze.filter { $0.data >= cal.startOfDay(for: i.data) && $0.data <= limite }
            .sorted { $0.data < $1.data }
        let incontri = i.incontri.sorted { $0.ora < $1.ora }
        return PrimaPagina(edizione: ed, numero: cal.ordinality(of: .day, in: .year, for: i.data) ?? 1, data: i.data,
                           titolo: titolo(incontri: incontri, scadenze: scadenze, edizione: ed),
                           incontri: incontri, scadenze: Array(scadenze.prefix(4)), daChiamare: Array(i.daChiamare.prefix(3)),
                           numeroDelGiorno: FormatoCifra.euro.testo(i.patrimonio),
                           didascaliaNumero: i.clienti == 1 ? "seguiti per 1 cliente" : "seguiti per \(i.clienti) clienti",
                           mercati: Array(i.mercati.prefix(5)), notaVera: i.notaVera)
    }

    /// Il titolo: le scadenze se ce ne sono, poi gli incontri, poi la giornata libera.
    static func titolo(incontri: [IncontroPrimaPagina], scadenze: [ScadenzaPrimaPagina], edizione: PrimaPagina.Edizione) -> String {
        if scadenze.count >= 2, let piu = scadenze.max(by: { $0.valore < $1.valore }) {
            return "\(parola(scadenze.count)) posizioni scadono entro \(giorniScadenze) giorni: la più importante è di \(piu.cliente)"
        }
        if let s = scadenze.first {
            return "\(s.posizione) di \(s.cliente) scade il \(Formati.dataBreve.string(from: s.data))"
        }
        let quando = edizione == .mattino ? "Oggi" : "Domani"
        if let primo = incontri.first {
            let n = incontri.count
            return "\(quando) \(n == 1 ? "un incontro" : "\(parola(n).lowercased()) incontri"): il primo alle \(Formati.ora.string(from: primo.ora)) con \(primo.chi)"
        }
        return "\(quando) nessun incontro: il momento giusto per chiamare chi aspetta"
    }

    /// «Due», «Tre» … fino a dieci; oltre, la cifra.
    static func parola(_ n: Int) -> String {
        let p = ["Zero", "Una", "Due", "Tre", "Quattro", "Cinque", "Sei", "Sette", "Otto", "Nove", "Dieci"]
        return n >= 0 && n < p.count ? p[n] : "\(n)"
    }
}
