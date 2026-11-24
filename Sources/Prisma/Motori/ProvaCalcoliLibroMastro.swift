import Foundation

/// Prova del libro mastro (NOVITÀ 9 dello stile Carta) dentro `Prisma --prova-calcoli`: il lettore del cedolino (mese,
/// totale delle provvigioni, netto) su testi di prova dichiarati, e i conti del mese (entrate da cedolini e parcelle
/// incassate, quota scelta dall'utente, spese, quanto resta da spendere). Nessuna regola fiscale: senza quota, niente
/// accantonamento inventato.
enum ProvaCalcoliLibroMastro {
    static func esegui(_ verifica: VerificaCalcoli) {
        let cal = Calendar(identifier: .gregorian)
        func d(_ a: Int, _ m: Int, _ g: Int) -> Date { AiutiProva.data(a, m, g) }
        /// Il primo del mese a mezzanotte (il mese del cedolino e del libro mastro).
        func primo(_ a: Int, _ m: Int) -> Date { cal.date(from: DateComponents(year: a, month: m, day: 1)) ?? Date() }

        // Il lettore del cedolino (testo di prova dichiarato)
        let testo = """
        ALLEANZA ASSICURAZIONI · Estratto conto provvigioni
        Competenza: novembre 2026
        Provvigioni di acquisto        1.820,00
        Provvigioni di incasso           640,50
        Totale provvigioni             2.460,50
        Ritenuta d'acconto              -566,00
        Netto a pagare                 1.894,50
        """
        let letto = LettoreCedolino.leggi(testo, calendario: cal)
        verifica("Libro mastro: il cedolino dice il totale delle provvigioni", letto.lordo ?? 0, 2_460.50)
        verifica("Libro mastro: il cedolino dice il netto a pagare", letto.netto ?? 0, 1_894.50)
        verifica.vero("Libro mastro: il cedolino dice il mese", letto.mese == primo(2026, 11))
        let numerico = LettoreCedolino.leggi("Periodo 03/2026\nProvvigioni maturate 980,00", calendario: cal)
        verifica.vero("Libro mastro: il mese anche in cifre", numerico.mese == primo(2026, 3))
        verifica("Libro mastro: le provvigioni maturate", numerico.lordo ?? 0, 980)
        let vuoto = LettoreCedolino.leggi("Un documento che non è un cedolino", calendario: cal)
        verifica.vero("Libro mastro: niente cifre inventate da un testo qualsiasi",
                      vuoto.lordo == nil && vuoto.netto == nil && vuoto.mese == nil)
        verifica("Libro mastro: importo all'italiana", LettoreCedolino.importo("12.345,67") ?? 0, 12_345.67)

        // I conti del mese
        let cedolini = [CedolinoProvvigioni(mese: d(2026, 11, 1), lordo: 2_460.50, netto: 1_894.50),
                        CedolinoProvvigioni(mese: d(2026, 10, 1), lordo: 3_000)]
        var pagata = Parcella(id: "mastro-1", clienteId: "anna", data: d(2026, 11, 2),
                              righe: [RigaParcella(id: "mastro-1-1", descrizione: "Consulenza", importo: 600)], anno: 2026, cal: cal)
        pagata.stato = .pagata
        pagata.incassataIl = d(2026, 11, 10)
        var daIncassare = pagata
        daIncassare.id = "mastro-2"
        daIncassare.stato = .emessa
        daIncassare.incassataIl = nil
        let spese = [SpesaStudio(data: d(2026, 11, 5), descrizione: "Carburante", importo: 160.50, categoria: .carburante),
                     SpesaStudio(data: d(2026, 10, 5), descrizione: "Carburante", importo: 99, categoria: .carburante)]

        let novembre = MotoreLibroMastro.mese(d(2026, 11, 20), cedolini: cedolini, parcelle: [pagata, daIncassare],
                                              spese: spese, quota: 30, calendario: cal)
        verifica("Libro mastro: provvigioni del mese", novembre.provvigioni, 2_460.50)
        verifica("Libro mastro: solo le parcelle incassate nel mese", novembre.parcelle, 600)
        verifica("Libro mastro: entrate", novembre.entrate, 3_060.50)
        verifica("Libro mastro: da mettere da parte con la quota scelta (30%)", novembre.accantonamento ?? 0, 918.15)
        verifica("Libro mastro: spese del mese", novembre.spese, 160.50)
        verifica("Libro mastro: quanto si può spendere", novembre.disponibile ?? 0, 3_060.50 - 918.15 - 160.50)

        let senzaQuota = MotoreLibroMastro.mese(d(2026, 11, 20), cedolini: cedolini, parcelle: [pagata], spese: spese,
                                                quota: nil, calendario: cal)
        verifica.vero("Libro mastro: senza quota scelta niente accantonamento inventato",
                      senzaQuota.accantonamento == nil && senzaQuota.disponibile == nil)

        let anno = MotoreLibroMastro.ultimi(3, al: d(2026, 11, 20), cedolini: cedolini, parcelle: [pagata], spese: spese,
                                            quota: 30, calendario: cal)
        verifica.vero("Libro mastro: gli ultimi tre mesi dal più recente",
                      anno.map(\.mese) == [primo(2026, 11), primo(2026, 10), primo(2026, 9)])
        verifica("Libro mastro: ottobre con il suo cedolino", anno[1].provvigioni, 3_000)
    }
}
