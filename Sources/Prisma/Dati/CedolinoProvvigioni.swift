import Foundation

// I cedolini delle provvigioni (NOVITÀ 9 dello stile Carta, il libro mastro): il consulente trascina il PDF del
// cedolino, Prisma ne legge il testo sul Mac (LettoreCedolino) e il consulente conferma le cifre. Si tengono solo mese,
// canale, lordo e netto delle provvigioni e il nome del file: il PDF non si conserva. Stanno nell'archivio delle spese di
// Studio (sezione «studio» della cartella a pezzi), nei backup, mai in «Prisma ovunque».

struct CedolinoProvvigioni: Codable, Equatable, Identifiable {
    var id = UUID().uuidString
    /// Il primo giorno del mese a cui si riferisce il cedolino.
    var mese: Date
    var canale: Canale = .alleanza
    /// Provvigioni lorde del mese.
    var lordo: Double
    /// Netto pagato, se il cedolino lo dice.
    var netto: Double?
    /// Il nome del file da cui è stato letto (solo il nome, mai il percorso).
    var fonte: String = ""
    /// Quando è stato registrato.
    var registratoIl: Date = Date()
}
