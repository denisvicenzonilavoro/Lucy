import Foundation

// Migliorie d'uso 10 (Design/uso/gruppo-01.md §10, Design/template-uso.html `PAROLE`): una parola sola per ogni cosa.
// Le parole che restano stanno qui, una volta sola; pulsanti, titoli, avvisi e documenti del Mac le prendono da qui.
// A destra di ogni costante, nel commento, le parole che spariscono. Valgono per il Mac: iPhone e iPad le prendono con
// il loro aggiornamento. Non cambiano nomi di tipi e di file, valori salvati e chiavi («eve», `impostazioni.eve`…),
// i PDF già scritti nei documenti del cliente né la pagina «Promemoria e occasioni» delle Impostazioni.

/// Le parole di Prisma: una sola per ogni cosa, uguale in tutte le schermate.
enum Parole {
    /// Tutto ciò che Prisma sa di un cliente (spariscono: «Scheda», «Fascicolo del cliente»).
    static let dossier = "Dossier"
    /// L'unico elenco delle cose da fare (spariscono: «Notifiche», «Attività», «Promemoria» come nome dell'elenco,
    /// «Da non dimenticare», «Richiede attenzione»). I promemoria di sistema del Mac restano «promemoria».
    static let daFare = "Da fare"
    /// Le cose scritte a mano nel «Da fare» (sparisce «attività» come nome dell'elenco).
    static let coseDaFare = "cose da fare"
    /// Il solo pulsante per presentare (spariscono: «Modalità cliente», «Presenta al cliente», «Presenta all'incontro»).
    static let mostraAlCliente = "Mostra al cliente"
    /// L'assistente (spariscono in vista: «Eve», «Ruby», «Qwen»; l'etichetta del motore sotto le risposte resta).
    static let vera = "Vera"
    /// Il pulsante che prepara un incontro (spariscono: «Prepara con Eve», «Prepara l'incontro»).
    static let preparamiIncontro = "Preparami l'incontro"
    /// La scelta di nessun cliente in particolare (sparisce «Portafoglio» come scelta del cliente).
    static let tuttiIClienti = "Tutti i clienti"
    /// Le quattro aree lette insieme (spariscono: «Panoramica delle aree», «Check-up» a schermo).
    static let ilQuadro = "Il quadro"
    /// Il posto di Posizioni: nessun'altra app si dice «il centro della consulenza».
    static let posizioniCuore = "Posizioni: il cuore di Prisma"
    /// Ciò che il cliente ha già (spariscono: «Attive», «In corso» come stato di una posizione).
    static let inEssere = "In essere"
    /// Ciò che gli si consiglia (spariscono: «Ipotesi», «Preventivo» come stato di una posizione).
    static let proposta = "Proposta"
    /// Il controllo periodico (spariscono: «Revisione periodica», «Check annuale»).
    static let riesame = "Riesame"
    /// La ricerca (sparisce «Cerca ovunque»).
    static let cerca = "Cerca"
    /// Le due versioni di un documento (spariscono «Report» e «Prospetto» come nomi delle versioni).
    static let perIlCliente = "Per il cliente"
    static let perTe = "Per te"
    /// I due selettori dei messaggi (sparisce «Canale» per dire Mail o Messaggi).
    static let tono = "Tono"
    static let inviaCon = "Invia con"
    /// I clienti fittizi (spariscono: «Dati di prova», «Strumenti › Clienti di prova»).
    static let dimostrazione = "Dimostrazione"
    /// Ciò che va sistemato (spariscono: «Panoramica» nelle Impostazioni, il pallino arancione senza nome).
    static let daSistemare = "Da sistemare"

    /// L'occhiello di Analisi 360: il suo lavoro, non «il centro della consulenza».
    static let occhielloAnalisi360 = "Previdenza, protezione, investimenti e risparmio di una persona"
}
