import Foundation

/// Migliorie d'uso 17 «Le priorità in ordine: 1, 2, 3»: `PrioritaAree360`. Con famiglia e salute in testa alla ruota
/// (stessa area) «Priorità 1» è Protezione, «Priorità 2» l'area del terzo bisogno e non c'è «Priorità 3» (il quarto
/// bisogno non si pesca); mai due capsule uguali, mai più di tre. Senza ruota l'ordine dall'area più scoperta, escluse
/// le aree coperte del tutto, gli investimenti dall'80% e le aree che non si misurano. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliPrioritaAree360 {
    static func esegui(_ verifica: VerificaCalcoli) {
        let aree = [
            sintesi(.previdenza, 0.72),
            sintesi(.protezione, 0.64),
            sintesi(.investimenti, 0.92),
            sintesi(.risparmio, 0.58),
        ]

        // Due bisogni della stessa area in testa: famiglia e salute → Protezione, poi la pensione
        let doppione: [AreaBisogno] = [.famiglia, .salute, .pensione, .casa]
        let p = PrioritaAree360.calcola(bisogni: doppione, aree: aree, ripiego: true)
        verifica.vero("Priorità 360: con un doppione Priorità 1 è Protezione", p.numero(.protezione) == 1)
        verifica.vero("Priorità 360: con un doppione Priorità 2 è l'area del terzo bisogno", p.numero(.previdenza) == 2)
        verifica.vero("Priorità 360: con un doppione nessuna Priorità 3 (il quarto bisogno non si pesca)",
                      p.aree.count == 2 && p.numero(.risparmio) == nil && p.fonte == .ruota)
        verifica.vero("Priorità 360: mai due capsule uguali", Set(p.aree).count == p.aree.count)
        verifica.vero("Priorità 360: con un doppione le numerazioni di Bisogni e card divergono",
                      !PrioritaAree360.stessaNumerazione(doppione))

        // Tre bisogni su tre aree diverse: tre priorità nello stesso ordine della scheda Bisogni
        let diversi: [AreaBisogno] = [.casa, .pensione, .famiglia, .patrimonio]
        let d = PrioritaAree360.calcola(bisogni: diversi, aree: aree, ripiego: true)
        verifica.vero("Priorità 360: tre bisogni diversi danno 1, 2, 3",
                      d.aree == [.risparmio, .previdenza, .protezione] && PrioritaAree360.stessaNumerazione(diversi))
        verifica.vero("Priorità 360: mai più di tre", d.aree.count <= PrioritaAree360.massimo)

        // Senza ruota: dall'area più scoperta (Risparmio 58%, Protezione 64%, Previdenza 72%; Investimenti al 92% no)
        let senza = PrioritaAree360.calcola(bisogni: [], aree: aree, ripiego: true)
        verifica.vero("Priorità 360: senza ruota dall'area più scoperta",
                      senza.aree == [.risparmio, .protezione, .previdenza] && senza.fonte == .copertura)
        verifica.vero("Priorità 360: senza ruota la nota di Bisogni non dice che l'ordine è lo stesso",
                      !PrioritaAree360.stessaNumerazione([]))
        verifica.vero("Priorità 360: senza ruota e senza ripiego nessuna priorità",
                      PrioritaAree360.calcola(bisogni: [], aree: aree, ripiego: false) == .vuota)

        // Esclusioni: coperta del tutto, investimenti all'80%, area che non si misura
        let coperte = [
            sintesi(.previdenza, 1),
            sintesi(.protezione, 0.3),
            sintesi(.investimenti, 0.8),
            sintesi(.risparmio, nil),
        ]
        verifica.vero("Priorità 360: escluse le aree al 100%, gli investimenti dall'80% e quelle senza misura",
                      PrioritaAree360.dallaCopertura(coperte) == [.protezione])
        let investimentiBassi = [sintesi(.investimenti, 0.79), sintesi(.protezione, 0.9)]
        verifica.vero("Priorità 360: investimenti sotto l'80% sono una priorità",
                      PrioritaAree360.dallaCopertura(investimentiBassi) == [.investimenti, .protezione])
        verifica.vero("Priorità 360: tutto coperto, nessuna priorità",
                      PrioritaAree360.calcola(bisogni: [], aree: [sintesi(.previdenza, 1)], ripiego: true) == .vuota)
    }

    private static func sintesi(_ area: AreaAnalisi, _ frazione: Double?) -> SintesiArea360 {
        SintesiArea360(area: area, frazione: frazione, valore: frazione.map { $0 * 100 }, unita: .percentuale,
                       titolo: "", testo: "")
    }
}
