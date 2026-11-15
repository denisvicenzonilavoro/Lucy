import Foundation

/// I testi del fascicolo dell'incontro che si compone a vista (migliorie d'uso 70, Design/uso/gruppo-12.md §70.3 punto 9).
enum TestiFascicolo {
    static let componi = "Componi il fascicolo"
    static let scegliCliente = "Scegli prima un cliente"
    static let aiutoComponi = "Il fascicolo dell'incontro: scegli i report, mettili in ordine e salvali in un solo PDF"
    static let titolo = "Il fascicolo dell\u{2019}incontro"
    static let cosaCeDentro = "Cosa c\u{2019}è dentro"
    static let copertina = "Copertina"
    static let copertinaSotto = "con la data, il nome e l\u{2019}indice"
    static let incontroOggi = "per l\u{2019}incontro di oggi"
    static let istruzioni = "Tocca una riga per metterla o toglierla; le frecce cambiano l\u{2019}ordine. La scelta resta per il prossimo incontro."
    static let dentro = "Dentro"
    static let nessunReport = "Nessun report scelto"
    static let conCopertina = "con la copertina"
    static let tante = "Tante da leggere a casa"
    static let tanteSotto = "Lascia quello di cui avete parlato oggi."
    static let scegliAlmenoUno = "Scegli almeno un report"
    static let mostra = "Mostra al cliente"
    static let altro = "Altro"
    static let salvaAltrove = "Salva in un\u{2019}altra cartella…"
    static let stampa = "Stampa…"
    static let su = "Sposta su"
    static let giu = "Sposta giù"
    static let etichettaContatore = "fascicolo"
    static let senzaReport = "Per questo cliente non c\u{2019}è ancora un report pronto."

    /// «1 pagina», «3 pagine».
    static func pagine(_ n: Int) -> String { n == 1 ? "1 pagina" : "\(n) pagine" }

    /// L'occhiello della scheda: «Per Marco · incontro di oggi, 2 novembre», «Per Marco · Revisione del 20 novembre»
    /// o solo «Per Marco».
    static func occhiello(nome: String, incontro: String?) -> String {
        incontro.map { "Per \(nome) · \($0)" } ?? "Per \(nome)"
    }

    static func incontroDiOggi(_ data: String) -> String { "incontro di oggi, \(data)" }
    static func incontroDel(_ tipo: String, _ data: String) -> String { "\(tipo) del \(data)" }

    /// Con un solo report pronto il fascicolo non serve.
    static func unSoloReport(_ nome: String) -> String {
        "Per \(nome) c\u{2019}è un solo report pronto. Il fascicolo serve quando ne lasci più di uno: qui basta il suo PDF."
    }

    /// «3 report · 9 pagine».
    static func somma(report n: Int, pagine p: Int) -> String { "\(n) report · \(pagine(p))" }

    static func salva(pagine p: Int) -> String { "Salva il PDF · \(pagine(p))" }

    static func ritrovi(_ nome: String, conIncontro: Bool) -> String {
        conIncontro ? "Lo ritrovi nei Documenti di \(nome), con la data dell\u{2019}incontro."
                    : "Lo ritrovi nei Documenti di \(nome), con la data di oggi."
    }

    static func salvato(_ nome: String, report n: Int, pagine p: Int) -> String {
        "Fascicolo salvato nei Documenti di \(nome): \(n) report, \(pagine(p))"
    }

    /// Il contatore della presentazione del fascicolo: «1 di 3 · fascicolo».
    static func contatore(_ i: Int, di n: Int, etichetta: String) -> String { "\(i) di \(n) · \(etichetta)" }
}
