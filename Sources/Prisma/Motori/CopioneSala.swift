import Foundation

/// Migliorie d'uso 59 «Ogni esperienza ha il suo copione» (Design/uso/gruppo-10.md §59): «Cosa dire», una traccia di
/// lavoro per il consulente — come si apre, tre cose da fare mentre si vive l'esperienza, la domanda con cui si chiude.
/// Testi fissi dell'app (nessuna cifra del cliente, mai scritti da Vera), che non compaiono mai davanti al cliente.
/// Puro: le viste stanno in Shell/SalaAzioniPalco.swift (solo Mac).
struct CopioneSala: Equatable {
    /// «Apri così»: la frase d'apertura, da dire al cliente.
    let apertura: String
    /// «Mentre la fate»: tre cose da fare.
    let passi: [String]
    /// «Chiudi con una domanda».
    let domanda: String
}

extension EsperienzaSala {
    /// Il copione dell'esperienza (`COPIONE` del template, con le correzioni della decisione 59-a: il film dura venti
    /// secondi, la password del Prisma del cliente si sceglie insieme). Lo `switch` completo: un'esperienza nuova senza
    /// copione non compila.
    var copione: CopioneSala {
        switch self {
        case .prismaCliente:
            return CopioneSala(apertura: "«Tutto quello che abbiamo visto oggi le resta in tasca.»",
                               passi: ["Scegliete insieme la password, davanti a lui",
                                       "Mostra come si apre sul telefono",
                                       "Di’ che non passa da nessun server: glielo mandi tu"],
                               domanda: "«A chi vorrebbe farlo vedere?»")
        case .prismaLuce:
            return CopioneSala(apertura: "«Questo è tutto quello che ha, in una luce sola.»",
                               passi: ["Lascia che sia lui a passare sui raggi",
                                       "Passa a «Per obiettivo»: i soldi prendono un nome",
                                       "Sposta il cursore a vent’anni"],
                               domanda: "«Quale raggio vorrebbe più largo?»")
        case .lettera:
            return CopioneSala(apertura: "«Le leggo una lettera. L’ha scritta lei, a 67 anni.»",
                               passi: ["Leggi piano, senza commentare",
                                       "Mostra «Senza il piano»: cambiano poche righe",
                                       "Lascia un momento di silenzio"],
                               domanda: "«Cosa vorrebbe che ci fosse scritto?»")
        case .film:
            return CopioneSala(apertura: "«In venti secondi, quello che ci siamo detti oggi.»",
                               passi: ["Guardatelo insieme una volta",
                                       "Mandalo subito, finché è fresco",
                                       "Serve a chi a casa non c’era"],
                               domanda: "«A chi lo fa vedere stasera?»")
        case .disegna:
            return CopioneSala(apertura: "«Mi disegni come vorrebbe che crescessero i suoi risparmi.»",
                               passi: ["Non correggere il disegno",
                                       "Lascia che Prisma lo trasformi nel piano possibile",
                                       "Fai notare dove disegno e piano si staccano"],
                               domanda: "«Cosa dovrebbe succedere in quel punto?»")
        case .giocoRischio:
            return CopioneSala(apertura: "«Non le chiedo quanto rischio sopporta: glielo faccio provare.»",
                               passi: ["Non suggerire la risposta",
                                       "Guarda quanto ci mette a decidere",
                                       "Alla fine confronta con il profilo dichiarato"],
                               domanda: "«Se fosse successo davvero, cosa avrebbe fatto?»")
        case .giornataPensione:
            return CopioneSala(apertura: "«Questa è una sua giornata, il primo anno di pensione.»",
                               passi: ["Parti da «Senza piano»",
                                       "Fai contare a lui cosa non ci sta",
                                       "Passa a «Con il piano» solo dopo"],
                               domanda: "«A cosa non rinuncerebbe?»")
        case .lanciaAnno:
            return CopioneSala(apertura: "«Lanciamo un anno: può andare bene o male, come nella vita.»",
                               passi: ["Fai lanciare a lui",
                                       "Dopo un anno storto, guarda la colonna «Con il piano»",
                                       "Dieci anni in una volta mostrano la differenza"],
                               domanda: "«Quale delle due vite preferisce?»")
        case .valoreConsulente:
            return CopioneSala(apertura: "«Una volta l’anno le dico quanto è valso il nostro lavoro.»",
                               passi: ["Leggi le quattro cifre, una per volta",
                                       "Spiega da dove viene ogni cifra",
                                       "Confronta con la parcella, senza scusarti"],
                               domanda: "«C’è qualcosa che si aspettava e non ha trovato?»")
        case .capsula:
            return CopioneSala(apertura: "«Scriva due righe a sé stesso, per il giorno in cui ce l’avrà fatta.»",
                               passi: ["Lascialo scrivere da solo",
                                       "Scegliete insieme quando si apre",
                                       "Sigilla davanti a lui: non la legge nessuno"],
                               domanda: "«Che giorno sarà, quello?»")
        case .realtaAumentata:
            return CopioneSala(apertura: "«Mettiamo il suo patrimonio qui, sul tavolo.»",
                               passi: ["Usa l’iPad o l’iPhone",
                                       "Fagli girare intorno al cristallo",
                                       "«Esploso» separa gli strati"],
                               domanda: "«Quale strato vorrebbe più alto tra dieci anni?»")
        }
    }
}

/// I testi fissi del riquadro «Cosa dire».
enum TestiCopione {
    /// Il pulsante nella testata del palco.
    static let pulsante = "Cosa dire"
    static let aiutoPulsante = "Come aprire, cosa fare e con che domanda chiudere. Lo vedi solo tu"
    static let apriCosi = "Apri così"
    static let mentre = "Mentre la fate"
    static let chiudi = "Chiudi con una domanda"
    static let soloTu = "Lo vedi solo tu: nella vista del cliente non compare."
    static let aiutoChiudi = "Chiudi il copione (esc)"

    /// L'occhiello: «Cosa dire · per spiegare · 3 minuti» (momento della miglioria 34 in minuscolo, «minuto» al
    /// singolare); senza durata solo il momento («Cosa dire · dopo l’incontro»).
    static func titolo(_ e: EsperienzaSala) -> String {
        let base = "\(pulsante) · \(e.momento.titolo.lowercased())"
        guard let m = e.minuti, m > 0 else { return base }
        return "\(base) · \(m) \(m == 1 ? "minuto" : "minuti")"
    }
}
