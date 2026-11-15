import Foundation

/// I testi del Territorio nati con le Migliorie d'uso (32, «La mappa risponde»): la scheda di una luce, il riquadro del
/// cliente scelto e il collegamento al «Da fare». Le distanze sono stime in linea d'aria, come tutte quelle del Territorio.
enum TestiTerritorio {
    /// «4 clienti a meno di dieci minuti da Giulia: sono le luci rimaste accese.»; per zero una frase propria (proposta).
    static func vicini(_ n: Int, nome: String) -> String {
        switch n {
        case 0: return "Nessun cliente a meno di dieci minuti da \(nome)."
        case 1: return "1 cliente a meno di dieci minuti da \(nome): è la luce rimasta accesa."
        default: return "\(n) clienti a meno di dieci minuti da \(nome): sono le luci rimaste accese."
        }
    }

    /// «Cliente dal 2019»; se l'anno viene solo dalla data della scheda, «In Prisma dal 2019» (proposta §32.3).
    static func clienteDal(_ anno: Int, stimato: Bool) -> String {
        stimato ? "In Prisma dal \(anno)" : "Cliente dal \(anno)"
    }

    /// La riga sotto il nome nel riquadro del cliente: «Bologna · cliente dal 2019».
    static func zonaEAnno(_ zona: String, anno: Int, stimato: Bool) -> String {
        "\(zona) · " + (stimato ? "in Prisma dal \(anno)" : "cliente dal \(anno)")
    }

    static let haQualcosaDaFare = " · ha qualcosa da fare"
    static let apriDossier = "Apri il dossier"
    static let apriDaFare = "Apri «Da fare» ›"
    static func nonSullaMappa(_ nome: String) -> String { "\(nome) non è sulla mappa: manca l’indirizzo." }
    static let mettiAMano = "Metti la posizione a mano"
}
