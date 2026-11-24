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
        stimato ? "In Lucy dal \(anno)" : "Cliente dal \(anno)"
    }

    /// La riga sotto il nome nel riquadro del cliente: «Bologna · cliente dal 2019».
    static func zonaEAnno(_ zona: String, anno: Int, stimato: Bool) -> String {
        "\(zona) · " + (stimato ? "in Lucy dal \(anno)" : "cliente dal \(anno)")
    }

    static let haQualcosaDaFare = " · ha qualcosa da fare"
    static let apriDossier = "Apri il dossier"
    static let apriDaFare = "Apri «Da fare» ›"
    static func nonSullaMappa(_ nome: String) -> String { "\(nome) non è sulla mappa: manca l’indirizzo." }
    static let mettiAMano = "Metti la posizione a mano"

    // MARK: Migliorie d'uso 51 · il giro si porta in tasca, la crescita dice chi è arrivato

    static let preparaIncontro = "Prepara l'incontro"
    static let confermaInAgenda = "✓ Conferma in Agenda"
    static let togli = "Togli"
    static let apriInAgenda = "Apri in Agenda"
    /// «Sofia tolto dal giro»: Prisma non conosce il genere (come per «Aggiungi … al giro»).
    static func toltoDalGiro(_ nome: String) -> String { "\(nome) tolto dal giro" }
    static let mandaGiro = "Manda il giro all'iPhone"
    static let giroSulliPhone = "✓ Il giro è sull'iPhone"
    /// Niente Mappe (privacy del Territorio): il giro arriva con «Prisma ovunque» e sull'iPhone sta in Agenda.
    static let notaGiroIPhone = "Sull'iPhone lo trovi in Agenda. Tocca una tappa per prepararla."
    static let accendiOvunque = "Per averlo sull'iPhone accendi «Lucy ovunque» in Impostazioni."
    static let apriOvunque = "Impostazioni › iPhone e iPad"
    static let giroInDimostrazione = "Durante la dimostrazione il giro non va all'iPhone."

    /// «Hanno cominciato nel 2021»; il primo anno comprende anche quelli di prima: «… nel 2016 o prima».
    static func cominciatoNel(_ anno: Int, primo: Bool) -> String {
        "Hanno cominciato nel \(anno)" + (primo ? " o prima" : "")
    }

    /// Chi ha cominciato nell'anno: la parte in neretto («3 famiglie», «Nessuna famiglia nuova») e il resto
    /// («: Giulia Bianchi, Marco Rossi e un'altra»). Al più `massimo` nomi, poi « e un'altra» / « e altre n».
    static func famiglieNuove(_ nomi: [String], massimo: Int) -> (forte: String, resto: String) {
        guard !nomi.isEmpty else { return ("Nessuna famiglia nuova", "") }
        let forte = nomi.count == 1 ? "1 famiglia" : "\(nomi.count) famiglie"
        let visti = Array(nomi.prefix(max(1, massimo)))
        let altri = nomi.count - visti.count
        var resto = ": " + visti.joined(separator: ", ")
        if altri == 1 { resto += " e un'altra" } else if altri > 1 { resto += " e altre \(altri)" }
        return (forte, resto)
    }
}
