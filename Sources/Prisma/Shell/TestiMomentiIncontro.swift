import Foundation

/// I testi dei tre momenti dell'incontro (Migliorie d'uso 20, Design/uso/gruppo-03.md §20.3 punto 9). Quelli che c'erano
/// già restano in `TestiCopilota` («Pronto ad ascoltare», «Quello che vi state dicendo», «Le schede compaiono qui…»);
/// «Preparami l'incontro» è di `Parole`.
enum TestiMomentiIncontro {
    static let prima = "Prima"
    static let preparazione = "Preparazione"
    static let durante = "Durante"
    static let ascolto = "Ascolto"
    static let dopo = "Dopo"
    static let prossimiPassi = "Prossimi passi"

    /// Sotto il titolo della testata: «Giulia Rossi · oggi, 09:30 · In studio · Revisione periodica · 45 min».
    static func sottoTestata(nome: String, data: Date, luogo: String?, tipo: String?, durata: Int?) -> String {
        let cal = Calendar.current
        let giorno: String
        if cal.isDateInToday(data) || cal.isDateInTomorrow(data) || cal.isDateInYesterday(data) {
            giorno = Formati.giornoRelativo(data)
        } else if cal.component(.year, from: data) == cal.component(.year, from: Date()) {
            giorno = Formati.giornoMese.string(from: data)
        } else {
            giorno = Formati.dataEstesa.string(from: data)
        }
        var parti = [nome, "\(giorno), \(Formati.ora.string(from: data))"]
        if let luogo, !luogo.trimmingCharacters(in: .whitespaces).isEmpty { parti.append(luogo) }
        if let tipo { parti.append(tipo) }
        if let durata, durata > 0 { parti.append("\(durata) min") }
        return parti.joined(separator: " · ")
    }

    // Prima
    static let puntiDaToccare = "Punti da toccare"
    static let iniziaIncontro = "Inizia l’incontro"
    static let apriDossier = "Apri il dossier"
    static let chiediVera = "Chiedi a Lucy"
    static let preparazioneDaRileggere = "Incontro concluso: la preparazione resta da rileggere."
    static func ultimaVolta(_ data: Date) -> String { "L’ultima volta · \(Formati.giornoMese.string(from: data))" }
    static func daFarePer(_ nome: String) -> String { "Da fare per \(nome)" }
    static let nienteInSospeso = "niente in sospeso"
    static let proposteAperte = "Proposte aperte"
    static let nessuna = "nessuna"
    static func perLAnno(_ importo: String) -> String { "per \(importo) l’anno" }
    static let patrimonioNetto = "Patrimonio netto"
    static let datiAnalisi = "Dati per l’analisi"
    static let temiDiSempre = "Temi, priorità e cosa è cambiato"

    // Durante
    static let copilota = "Copilota"
    static let appuntiAMano = "Appunti a mano"
    static let fraseAppunti = "Le domande e gli appunti scritti da te: finiscono nel verbale."
    static let hoFinito = "Ho finito"
    static let incontroConcluso = "Incontro concluso"
    static let trascrizioneNonConservata = "La trascrizione non è stata conservata: resta il verbale, in «Dopo»."
    static func consensoDato(_ nome: String) -> String {
        "\(TestiCopilota.primoNome(nome)) ha dato il consenso · l’audio non lascia il Mac"
    }
    static let mancaConsenso = "Manca il consenso all’ascolto"
    static let registraConsenso = "Registra il consenso…"
    static let aiutoConsenso = "Il consenso nel dossier: data, modo e revoca"
    static let aiutoSelettore = "Termina l’ascolto per passare agli appunti a mano."

    // Dopo
    static let verbaleNonCe = "Il verbale non c’è ancora."
    static let fraseVerbaleNonCe = "Si scrive da solo quando termini l’ascolto. Da qui confermi cosa entra nel dossier, crei le attività e fissi il prossimo incontro."
    static let vaiAllAscolto = "Vai all’ascolto"
    static let scriviloAMano = "Scrivilo a mano"
    static let fissaIlProssimo = "Fissa il prossimo"
    static let giaNelDossier = "Già nel dossier: l’incontro è archiviato, in sola lettura."
    static let riapri = "Riapri"
    static let verbalePronto = "Incontro concluso · il verbale è pronto: conferma cosa entra nel dossier"
    static let incontroRiaperto = "Incontro riaperto: attività e appuntamenti già creati restano."

    // Fermare l'ascolto (decisione 20-c)
    static let fermareAscolto = "Fermare l’ascolto?"
    static let ferma = "Ferma"
    static let fraseFermare = "Il copilota smette di ascoltare: quello che ha già capito resta nelle schede."
}
