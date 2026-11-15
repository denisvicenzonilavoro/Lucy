import Foundation

/// I testi del lettore dei documenti (migliorie d'uso 62 «Il documento si apre in grande», Design/uso/gruppo-11.md §62):
/// il perché dei dati da controllare, i tre passi e il pulsante solo. Le frasi del template, con i nomi e le cifre di
/// Prisma.
enum TestiDocumenti {
    /// L'origine dei dati scritti a mano (`StatoShell.aggiungiCampo`): mai incerti.
    static let origineAMano = "A mano"

    // MARK: Il perché dei dati da controllare

    static let lettoConQwen = "L’ho letto con Qwen: controlla."
    static let senzaRiga = "Nel testo non trovo la riga da cui viene: controlla."
    static let importoIlleggibile = "Il numero non ha la forma di un importo."
    static let percentualeIlleggibile = "Il numero non ha la forma di una percentuale."
    static let anniIlleggibili = "Il numero di anni non si legge bene: controlla."
    static let dataIlleggibile = "La data non si legge bene: controlla."
    static let dataNelFuturo = "La data è nel futuro: controlla."
    static let sriFuoriScala = "L’indicatore di rischio va da 1 a 7: controlla."
    static let isinNonValido = "Il codice ISIN non torna con la sua cifra di controllo."
    static let codiceFiscaleNonValido = "Il codice fiscale non ha la forma giusta."

    /// Un dato che il tipo di documento dovrebbe avere e che non c'è.
    static func mancante(_ c: CampoDocumento) -> String {
        switch c {
        case .beneficiari: return "In queste pagine non c’è la parte sui beneficiari."
        default: return "In queste pagine non trovo «\(c.nome)»."
        }
    }

    // MARK: Testata

    /// «Documento di Marco · Contratti e polizze».
    static func occhiello(nome: String, gruppo: String) -> String { "Documento di \(nome) · \(gruppo)" }
    static let canaleDaIndicare = "Canale da indicare"
    /// La capsula sotto la pagina: «pagina 1 · 3 marzo 2025».
    static func capsulaPagina(_ pagina: Int, data: String) -> String { "pagina \(pagina) · \(data)" }

    // MARK: Passo 1 «I dati letti»

    static let titoloDati = "I dati letti"
    static func daControllare(_ n: Int) -> String { "\(n) da controllare" }
    static let aPosto = "a posto"
    static let vaBene = "Va bene"
    static let mostra = "Mostra"
    static let nascondi = "Nascondi"
    static let aggiungi = "Aggiungi"
    static let scriviQui = "Scrivi il valore"
    static func certi(_ n: Int) -> String {
        n == 1 ? "1 dato letto con certezza" : "\(n) dati letti con certezza"
    }
    static func nonTrovato(_ c: CampoDocumento) -> String { "Non trovato: \(c.nome)" }
    static let nessunDato = "Nessun dato letto in questo documento."
    static let inLettura = "Prisma sta leggendo il documento sul Mac…"
    static let illeggibile = "Il documento non si legge: rileggilo o scrivi i dati a mano."
    static let rileggi = "Rileggi"
    static let aiutoVaBene = "Il valore è giusto (Invio): entra così"

    // MARK: Passo 2 «A cosa è collegato»

    static let titoloCollegamento = "A cosa è collegato"
    static func allaPosizione(_ posizione: String, cliente: String) -> String { "Alla posizione «\(posizione)» di \(cliente)" }
    static func allaScheda(_ scheda: String) -> String { "Alla scheda prodotto «\(scheda)»" }
    static func alDossier(_ cliente: String) -> String { "Al dossier di \(cliente)" }
    static let nonCollegato = "Non è collegato"
    static let cambia = "Cambia"
    static let aiutoCambia = "Si sceglie un’altra posizione dello stesso cliente"
    static let collega = "Collega"

    // MARK: Passo 3 «Cosa non torna»

    static let titoloDifferenze = "Cosa non torna"
    static func daDecidere(_ n: Int) -> String { "\(n) da decidere" }
    static let deciso = "deciso"
    static let nelDocumento = "Nel documento"
    static let nellaPosizione = "Nella posizione"
    static let nellaScheda = "Nella scheda"
    static let toccaIlGiusto = "Tocca il valore giusto: l’altro viene corretto."
    static let confrontoCompleto = "Apri il confronto completo"
    static let chiudiConfronto = "Chiudi il confronto completo"
    static let aiutoConfronto = "La tabella «Nel documento / In Prisma» con lo storico, il ripristino e i clienti toccati dal KID"

    // MARK: Il piede

    /// «Controlla il dato in arancione» / «Controlla i 2 dati in arancione».
    static func controlla(_ n: Int) -> String {
        n <= 1 ? "Controlla il dato in arancione" : "Controlla i \(n) dati in arancione"
    }
    /// «Decidi la differenza» / «Decidi le 2 differenze».
    static func decidi(_ n: Int) -> String {
        n <= 1 ? "Decidi la differenza" : "Decidi le \(n) differenze"
    }
    static let fatto = "Fatto: salva nel dossier"
    static let chiudi = "Chiudi"
    static let chiediAVera = "Chiedi a Vera"
    static let aiutoVera = "Vera risponde solo con il testo di questo documento, citando la pagina"
    static let soloQuandoLoDici = "I dati entrano nel dossier solo quando lo dici tu"
    static let giaSalvato = "Già salvato nel dossier"
    static let primaControlla = "Prima controlla i dati in arancione"
    static let primaScegli = "Prima scegli il valore giusto per ogni differenza"
    /// ««Polizza vita» salvato nel dossier di Marco».
    static func salvato(_ documento: String, cliente: String) -> String { "«\(documento)» salvato nel dossier di \(cliente)" }

    // MARK: Il testo

    static let mostraIlTesto = "Mostra il testo"
    static let notaImpaginato = "Impaginato da Prisma con i dati del dossier: da consultare, stampare o consegnare. Con «Apri in Anteprima» lo apri sul Mac."
    static let altreAzioni = "Tipo, collegamento, crea e altre azioni"
    static let tornaAiPassi = "‹ Torna ai passi"
}
