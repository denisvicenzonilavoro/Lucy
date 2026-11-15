import Foundation

/// Migliorie d'uso 13 «Obiettivi: si vede se ci arriva»: lo stato `ArrivoObiettivo` dai mesi (in tempo, in ritardo
/// con «1 anno e 2 mesi», senza versamenti, già raggiunto anche senza versamenti, non ci arriva con un versamento) e la
/// durata scritta (`TestiObiettivoApple.durata`). Con una curva vera: senza nulla da parte né versamenti non ci arriva,
/// con il versamento necessario ci arriva in tempo. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliArrivoObiettivo {
    static func esegui(_ verifica: VerificaCalcoli) {
        let mese: (Int) -> String = { "mese \($0)" }

        // Durata: singolare, plurale, anni e mesi
        verifica.vero("Arrivo obiettivo: durata 1 mese", TestiObiettivoApple.durata(mesi: 1) == "1 mese")
        verifica.vero("Arrivo obiettivo: durata 5 mesi", TestiObiettivoApple.durata(mesi: 5) == "5 mesi")
        verifica.vero("Arrivo obiettivo: durata 1 anno", TestiObiettivoApple.durata(mesi: 12) == "1 anno")
        verifica.vero("Arrivo obiettivo: durata 1 anno e 2 mesi", TestiObiettivoApple.durata(mesi: 14) == "1 anno e 2 mesi")
        verifica.vero("Arrivo obiettivo: durata 2 anni e 3 mesi", TestiObiettivoApple.durata(mesi: 27) == "2 anni e 3 mesi")
        verifica.vero("Arrivo obiettivo: durata 3 anni e 1 mese", TestiObiettivoApple.durata(mesi: 37) == "3 anni e 1 mese")

        // In tempo (anche proprio alla scadenza)
        let inTempo = ArrivoObiettivo(arrivo: 30, scadenza: 36, totale: 500, mese: mese)
        verifica.vero("Arrivo obiettivo: in tempo", inTempo == .inTempo(mese: "mese 30") && inTempo.arrivaInTempo && inTempo.tono == .ok)
        verifica.vero("Arrivo obiettivo: testo in tempo", inTempo.testo == "In tempo: ci arriva a mese 30")
        verifica.vero("Arrivo obiettivo: alla scadenza è in tempo",
                      ArrivoObiettivo(arrivo: 36, scadenza: 36, totale: 500, mese: mese).arrivaInTempo)

        // In ritardo di 1 anno e 2 mesi
        let ritardo = ArrivoObiettivo(arrivo: 50, scadenza: 36, totale: 300, mese: mese)
        verifica.vero("Arrivo obiettivo: in ritardo di 14 mesi", ritardo == .inRitardo(mesi: 14) && !ritardo.arrivaInTempo)
        verifica.vero("Arrivo obiettivo: testo in ritardo",
                      ritardo.testo == "In ritardo: ci arriva 1 anno e 2 mesi dopo" && ritardo.tono == .attenzione)

        // Senza versamenti
        let senza = ArrivoObiettivo(arrivo: nil, scadenza: 36, totale: 0, mese: mese)
        verifica.vero("Arrivo obiettivo: senza versamenti",
                      senza == .senzaVersamenti && senza.testo == "Senza versamenti non ci arriva" && senza.tono == .errore)

        // Già raggiunto, anche senza versamenti (prima conta l'arrivo)
        let raggiunto = ArrivoObiettivo(arrivo: 0, scadenza: 36, totale: 0, mese: mese)
        verifica.vero("Arrivo obiettivo: già raggiunto senza versamenti resta verde",
                      raggiunto == .giaRaggiunto && raggiunto.arrivaInTempo && raggiunto.tono == .ok)

        // Con versamenti ma oltre trent'anni dopo la scadenza
        let mai = ArrivoObiettivo(arrivo: nil, scadenza: 36, totale: 50, mese: mese)
        verifica.vero("Arrivo obiettivo: con un versamento non ci arriva",
                      mai == .nonCiArriva && mai.testo == "Con questo versamento non ci arriva" && !mai.arrivaInTempo)

        // Con una curva vera (MotoreObiettivo): nulla da parte e nessun versamento → senza versamenti; con il
        // versamento necessario (più un margine) → in tempo
        let oggi = AiutiProva.data(2026, 1, 15)
        let scadenza = Calendar.current.date(byAdding: .year, value: 5, to: oggi) ?? oggi
        let o = Obiettivo(clienteId: "prova", titolo: "Prova", area: .casa, importo: 30_000, scadenza: scadenza)
        let curva = CurvaObiettivo(o, posizioni: [], data: oggi)
        verifica.vero("Arrivo obiettivo: curva senza versamenti",
                      ArrivoObiettivo(curva: curva, versamento: 0, attivi: 0) == .senzaVersamenti)
        let necessario = curva.versamentoNecessario ?? 0
        verifica.vero("Arrivo obiettivo: curva con il versamento necessario in tempo",
                      necessario > 0 && ArrivoObiettivo(curva: curva, versamento: necessario * 1.05, attivi: 0).arrivaInTempo)
        if case .inRitardo(let mesi) = ArrivoObiettivo(curva: curva, versamento: necessario * 0.7, attivi: 0) {
            verifica.vero("Arrivo obiettivo: curva con meno del necessario in ritardo", mesi > 0)
        } else {
            verifica.vero("Arrivo obiettivo: curva con meno del necessario in ritardo", false)
        }
    }
}
