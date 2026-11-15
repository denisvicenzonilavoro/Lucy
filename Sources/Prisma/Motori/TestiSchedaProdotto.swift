import Foundation

/// Migliorie d'uso 63 «I prodotti parlano chiaro»: i testi del catalogo nella Biblioteca (sul Mac).
enum TestiCatalogo {
    static let documenti = "Documenti"
    static let prodotti = "Prodotti"
    static let iProdotti = "I prodotti"
    static func perCliente(_ nome: String) -> String { "Per \(nome), dal più adatto" }

    static let fonteDaVerificareBreve = "fonte da verificare"
    static let rispondePriorita = "risponde a una priorità"
    static let rischiaPiu = "rischia più del profilo"

    static func esito(_ e: EsitoProdottoCliente, nome: String) -> String {
        switch e {
        case .priorita: return "Risponde a una priorità di \(nome)"
        case .inLinea: return "In linea con il profilo di \(nome)"
        case .oltreProfilo: return "Rischia più del profilo di \(nome)"
        }
    }

    static func fonteVerificata(_ data: Date) -> String { "Fonte verificata il \(Formati.dataEstesa.string(from: data))" }
    static let fonteKIDNuovo = "Fonte da verificare: c’è un KID nuovo"
    static let fonteDaVerificare = "Fonte da verificare"
    static let fonteMaiVerificata = "Fonte mai verificata"
    static let segnaVerificata = "Segna verificata oggi"
    static let segnataOggi = "Fonte segnata come verificata oggi"

    static let inUnaFrase = "In una frase"
    static let ePer = "È per"
    static let nonEPer = "Non è per"
    static let scritteDaPrisma = "Scritte da Prisma dai dati della scheda: correggi i dati in «Modifica» se non tornano."

    static let suDiecimila = "Su 10.000 € in dieci anni"
    static let allaFine = "alla fine, tolti i costi"
    static func rigaCosti(versato: Double, guadagno: Double, costi: Double) -> (prima: String, costi: String) {
        ("versati \(Formati.euro(versato)) · guadagno \(Formati.euro(guadagno)) · ", "costi \(Formati.euro(costi))")
    }
    static func quotaGuadagno(_ quota: String) -> String { "\(quota) del guadagno possibile" }

    static let quantoRischia = "Quanto rischia"
    static func rischio(_ sri: Int?) -> String {
        guard let sri else { return "non indicato" }
        return "\(sri) su 7: \(TesseraRischio.descrizione(sri))"
    }
    static let perQuantoTempo = "Per quanto tempo"
    static let almeno = "almeno, per dare il meglio"
    static let nonIndicato = "non indicato"
    /// 63-d: il premio indicativo della protezione, solo con una stima dalle coperture in archivio.
    static let quantoCosta = "Quanto costa, per dare un’idea"
    static func circaAllAnno(_ premio: Double) -> String { "circa \(Formati.euro(premio)) l’anno" }
    static func perCapitale(_ capitale: Double) -> String {
        "per \(Formati.euro(capitale)) di capitale: stima dalle polizze in archivio"
    }

    static let garanzia = "Garanzia"
    static let uscitaPrima = "Uscita prima"
    static let tasse = "Tasse"
    static func tasseSulRendimento(_ x: Double) -> String { "\(Formati.percentuale(x)) sul rendimento" }

    static func proponiA(_ nome: String) -> String { "Proponi a \(nome)" }
    static func propostaCreata(_ prodotto: String, cliente: String) -> String {
        "«\(prodotto)» è tra le proposte di \(cliente): la completi in Posizioni"
    }
    static let apri = "Apri"
    static let confronta = "Confronta con quello che ha"
    static let apriDocumento = "Apri il suo documento"
    static let mettiSuCliente = "Metti su un cliente…"
    static let tuttiDettagli = "Tutti i dettagli"
    static let notaPiede = "Scheda compilata dal consulente: costi e condizioni veri sono nel KID in vigore."

    static let cerca = "Cerca prodotto o compagnia"
    static let filtra = "Filtra"
    static let altro = "Altro"
    static let nessunaScheda = "Nessuna scheda con questi filtri."

    /// «1 anno», «5 anni».
    static func anni(_ n: Int) -> String { n == 1 ? "1 anno" : "\(n) anni" }
}
