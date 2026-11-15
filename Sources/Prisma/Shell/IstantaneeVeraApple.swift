#if os(macOS)
import Foundation

/// Le istantanee di Vera nel tema Apple (§4.7, PIE e01…e10): la colonna con la sfera grande, «Ciao, sono Vera.», lo
/// stato di Vera, «Parliamo di» e «Per rispondere uso» (migliorie d'uso 27); la chat che comincia con il saluto di
/// Vera e, a conversazione vuota, i riquadri degli esempi, poi il campo a capsula; la testata con «Lavoro / Conversazione». Poi una risposta con la scheda dei calcoli (le cifre dai
/// motori di Prisma sui dati di prova), i puntini «sta scrivendo» e Qwen non pronto. Tutto nello stato finale.
extension Istantanee {
    nonisolated static var sceneVeraApple: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("480-vera-apple", { s in preparaVeraApple(s) }),
            ("480-vera-apple-scuro", { s in preparaVeraApple(s) }),
            ("481-vera-risposta-calcoli", { s in
                preparaVeraApple(s)
                conversazioneDiProva(s, chiave: "giulia",
                                     domanda: "Come è diviso il patrimonio di Giulia?",
                                     risposta: "Il patrimonio di Giulia poggia soprattutto sulla casa; investimenti, liquidità e risparmio vengono dopo. Qui sotto le cifre di Prisma, area per area: la liquidità è il punto da cui partire per l'anticipo della casa.")
            }),
            ("481-vera-risposta-calcoli-scuro", { s in
                preparaVeraApple(s)
                conversazioneDiProva(s, chiave: "giulia",
                                     domanda: "Come è diviso il patrimonio di Giulia?",
                                     risposta: "Il patrimonio di Giulia poggia soprattutto sulla casa; investimenti, liquidità e risparmio vengono dopo. Qui sotto le cifre di Prisma, area per area: la liquidità è il punto da cui partire per l'anticipo della casa.")
            }),
            // La domanda appena partita: la bolla dell'utente, i puntini e la sfera che pulsa (ferma, in istantanea)
            ("482-vera-sta-scrivendo", { s in
                preparaVeraApple(s)
                s.aggiungiMessaggio(MessaggioVera(autore: .utente, testo: "Spiegami la previdenza di Giulia"), cliente: "giulia", parla: false)
                s.veraInCorso = true
                s.flussoVera.inizia(SceltaVera(modalita: .lavoro, pensa: false), motore: s.qwen.nome)
            }),
            // Qwen non è pronto: la card lo dice, con «Verifica»; Vera non risponde
            ("483-vera-qwen-non-pronto", { s in
                preparaVeraApple(s)
                s.disponibilitaLocale = .nonDisponibile("Ollama non risponde: aprilo sul Mac e premi «Verifica».")
            }),
            // Migliorie d'uso 27: «Tutti i clienti» nella colonna e i riquadri degli esempi del portafoglio
            ("1045-uso-vera-tutti-i-clienti", { s in
                preparaVeraApple(s)
                s.veraPortafoglio = true
            }),
            ("1045-uso-vera-tutti-i-clienti-scuro", { s in
                preparaVeraApple(s)
                s.veraPortafoglio = true
            }),
            // Migliorie d'uso 27: in modalità Conversazione la colonna dice che i dati dei clienti non entrano
            ("1046-uso-vera-conversazione", { s in
                preparaVeraApple(s)
                s.modalitaVeraScelta = .conversazione
            }),
            ("1046-uso-vera-conversazione-scuro", { s in
                preparaVeraApple(s)
                s.modalitaVeraScelta = .conversazione
            }),
        ]
    }

    /// L'app Vera su Giulia Rossi, con Qwen pronto e la conversazione vuota.
    nonisolated static func preparaVeraApple(_ s: StatoShell) {
        s.disponibilitaLocale = .pronto
        s.clienteAttivoId = "giulia"
        s.veraPortafoglio = false
        s.apri(.vera)
    }
}
#endif
