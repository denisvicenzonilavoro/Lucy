import Foundation

/// Migliorie d'uso 65 «Le note stanno con il cliente»: i testi della sezione Note del dossier sul Mac
/// (Shell/DossierNote.swift), come nel template (Design/uso/gruppo-12.md, §65.1).
enum TestiNoteDossier {
    static let titolo = "Note"
    static let sottotitolo = "un elenco solo · si salvano da sole"
    static let nuova = "Nuova nota"
    static let senzaTitolo = "Senza titolo"
    static let notaVuota = "Nota vuota"
    static let nessuna = "Nessuna nota, per ora."
    static let nelDaFare = "Nel Da fare"
    static let segnapostoTitolo = "Titolo"
    static let segnapostoTesto = "Scrivi qui…"
    static let mettiInEvidenza = "Metti in evidenza"
    static let inEvidenza = "In evidenza"
    static let fanneUnDaFare = "Fanne un «Da fare»"
    static let eNelDaFare = "È nel Da fare"
    static let elimina = "Elimina"
    static let svuota = "Svuota"
    static let esporta = "Esporta .txt…"
    static let rigaInEvidenza = "È la nota che ritrovi in Panoramica e in «Prima dell’incontro»."
    static let modificataOggi = "Modificata oggi"
    static func modificataIl(_ data: String) -> String { "Modificata il \(data)" }
    static let codaQuellaInEvidenza = ". Quella in evidenza si vede anche in Panoramica."
    static let quellaInEvidenza = "Quella in evidenza si vede anche in Panoramica."
    static let scegli = "Scegli una nota, o scrivine una nuova."
    static let avvisoInEvidenza = "In evidenza: la ritrovi in Panoramica e prima dell’incontro"
    static let avvisoTolta = "Tolta dall’evidenza"
    static func avvisoDaFare(_ titolo: String, nome: String) -> String { "«\(titolo)» è nel Da fare di \(nome), per oggi" }
    static let avvisoEliminata = "Nota eliminata"
    static let avvisoSvuotata = "«Da ricordare» svuotata"
    static let annulla = "Annulla"
    static let daRicordare = "Da ricordare"
    static let nienteDaRicordare = "Niente da ricordare, per ora."
    /// Il titolo dell'attività nata da una nota senza titolo.
    static func titoloAttivita(_ data: String) -> String { "La nota del \(data)" }
    /// La data breve nell'elenco: «oggi» o «5 nov».
    static func data(_ d: Date, oggi: Date = Date()) -> String {
        Calendar.current.isDate(d, inSameDayAs: oggi) ? "oggi" : Formati.giornoMeseBreve.string(from: d)
    }
}
