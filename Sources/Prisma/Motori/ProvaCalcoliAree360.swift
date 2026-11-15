import Foundation

/// Prove della griglia delle aree di Analisi 360 nel tema Apple (§4.3.1, §4.3.4, §4.3.5): l'anello della previdenza è
/// la quota del divario coperta dal motore dell'area, i mesi di spese da parte si contano dalla liquidità e dal
/// fabbisogno delle ipotesi (con la virgola, per difetto al decimo), la composizione somma al patrimonio finanziario e
/// la coerenza con il profilo usa l'SRI massimo della propensione. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliAree360 {
    static func esegui(_ verifica: VerificaCalcoli) {
        testi(verifica)
        previdenza(verifica)
        liquidita(verifica)
        composizione(verifica)
    }

    private static func testi(_ verifica: VerificaCalcoli) {
        verifica.vero("Aree 360: mesi con la virgola", TestiAree360.mesi(3.5) == "3,5")
        verifica.vero("Aree 360: mesi interi senza decimali", TestiAree360.mesi(6) == "6")
        verifica.vero("Aree 360: un mese al singolare", TestiAree360.mesiConNome(1) == "1 mese")
        verifica("Aree 360: percentuale per difetto", MotoreAree360.percentuale(0.996), 99)
        verifica("Aree 360: percentuale piena", MotoreAree360.percentuale(1.2), 100)
        var c = Cliente.nuovo(tinta: .blu)
        c.codiceFiscale = "RSSGLI85M52H501X"
        verifica.vero("Aree 360: genere femminile dal codice fiscale", TestiAree360.femminile(c) == true)
        c.codiceFiscale = "RSSMRC80A12H501X"
        verifica.vero("Aree 360: genere maschile dal codice fiscale", TestiAree360.femminile(c) == false)
        c.codiceFiscale = ""
        verifica.vero("Aree 360: senza codice fiscale nessun genere", TestiAree360.femminile(c) == nil)
        passo(verifica)
    }

    /// Migliorie d'uso 45: il passo di Investimenti e Liquidità verso Posizioni.
    private static func passo(_ verifica: VerificaCalcoli) {
        verifica.vero("Passo investimenti: senza profilo nessun passo", TestiAree360.passoInvestimenti(entroProfilo: nil) == nil)
        verifica.vero("Passo investimenti: tutto entro il profilo, in linea",
                      TestiAree360.passoInvestimenti(entroProfilo: 100) == "Il portafoglio è in linea con il profilo: niente da sistemare.")
        verifica.vero("Passo investimenti: nessuna soglia dell'80% (al 90% entro, il 10% fuori)",
                      TestiAree360.passoInvestimenti(entroProfilo: 90)
                        == "Il 10% del capitale rischia più del profilo scelto: si vede posizione per posizione.")
        verifica.vero("Passo investimenti: l'articolo si accorda («L'8%»)",
                      TestiAree360.passoInvestimenti(entroProfilo: 92)?.hasPrefix("L'8% del capitale") == true)
        func liquidita(mesi: Double?, soglia: Int, spese: Double, conti: Double) -> Liquidita360 {
            Liquidita360(liquidita: conti, perCanale: [:], speseMensili: spese, mesi: mesi, soglia: soglia, inScadenza: 0,
                         mesiFinestraScadenze: 6, riservaNecessaria: spese * Double(soglia),
                         eccedenza: max(0, conti - spese * Double(soglia)))
        }
        verifica.vero("Passo liquidità: senza spese nessun passo",
                      TestiAree360.passoLiquidita(liquidita(mesi: nil, soglia: 6, spese: 0, conti: 5_000)) == nil)
        verifica.vero("Passo liquidità: la riserva c'è, con la soglia delle ipotesi",
                      TestiAree360.passoLiquidita(liquidita(mesi: 7.2, soglia: 6, spese: 2_000, conti: 14_400))
                        == "La riserva c'è: oltre i 6 mesi di spese.")
        // 12 mesi × 1.800 € = 21.600 €, sui conti 9.250 €: mancano 12.350 €, circa 12.400 €
        verifica.vero("Passo liquidità: quanto manca, alle centinaia",
                      TestiAree360.passoLiquidita(liquidita(mesi: 5.1, soglia: 12, spese: 1_800, conti: 9_250))
                        == "Per arrivare a 12 mesi servono ancora circa \(Formati.euro(12_400)).")
    }

    private static func previdenza(_ verifica: VerificaCalcoli) {
        var i = IpotesiPrevidenza()
        i.eta = 40; i.etaPensione = 67; i.redditoDesiderato = 2_200; i.pensionePubblica = 1_400
        i.capitale = 12_000; i.versamentoMensile = 150; i.rendimentoReale = 1.5; i.anniIntegrazione = 25
        let e = MotoreAnalisi.previdenza(i)
        let s = MotoreAree360.previdenza(i)
        verifica("Aree 360: anello della previdenza = rendita / divario", s.frazione ?? -1, e.integrazione / e.divario,
                 tolleranza: 1e-9)
        var senza = i
        senza.pensionePubblica = 2_500
        verifica("Aree 360: senza divario anello pieno", MotoreAree360.previdenza(senza).frazione ?? -1, 1)
    }

    private static func liquidita(_ verifica: VerificaCalcoli) {
        var a = Analisi360()
        a.protezione.fabbisognoMensile = 2_300
        a.protezione.mesiRiserva = 6
        let conto = AiutiProva.posizione("Conto", .liquidita, 8_050, canale: .alleanza)
        let l = MotoreAree360.liquidita([conto], analisi: a, obiettivi: [], prodotti: [], data: Date())
        verifica("Aree 360: mesi di spese da parte", l.mesi ?? -1, 3.5)
        verifica("Aree 360: soglia dalle ipotesi", Double(l.soglia), 6)
        verifica("Aree 360: liquidità del canale", l.perCanale[.alleanza] ?? -1, 8_050)
        let s = MotoreAree360.risparmio(a.risparmio, liquidita: l)
        verifica("Aree 360: anello della liquidità = mesi / soglia", s.frazione ?? -1, 3.5 / 6, tolleranza: 1e-9)
        // Per difetto al decimo: 5,99 mesi restano sotto la soglia
        let quasi = AiutiProva.posizione("Conto", .liquidita, 2_300 * 5.99)
        verifica("Aree 360: mesi per difetto",
                 MotoreAree360.liquidita([quasi], analisi: a, obiettivi: [], prodotti: [], data: Date()).mesi ?? -1, 5.9)
        a.protezione.fabbisognoMensile = 0
        verifica.vero("Aree 360: senza spese nessun mese",
                      MotoreAree360.liquidita([conto], analisi: a, obiettivi: [], prodotti: [], data: Date()).mesi == nil)
    }

    private static func composizione(_ verifica: VerificaCalcoli) {
        let conto = AiutiProva.posizione("Conto", .liquidita, 5_000, canale: .alleanza)
        let fondo = AiutiProva.posizione("Fondo", .investimento, 15_000) { $0.sri = 4 }
        let k = MotoreAree360.composizione([conto, fondo], cliente: nil)
        verifica("Aree 360: composizione sul patrimonio finanziario", k.totale, 20_000)
        verifica("Aree 360: quote che sommano a 100", k.pezzi.reduce(0) { $0 + $1.quota }, 100, tolleranza: 1e-6)
        verifica.vero("Aree 360: la liquidità del conto nel suo pezzo",
                      (k.pezzi.first { $0.classe == .liquidita }?.perCanale[.alleanza] ?? 0) >= 5_000 - 0.01)
        verifica.vero("Aree 360: senza profilo nessuna coerenza", k.entroProfilo == nil)
        var c = Cliente.nuovo(tinta: .blu)
        c.profilo.propensione = .moderata
        verifica("Aree 360: SRI 4 oltre il profilo moderato", MotoreAree360.composizione([conto, fondo], cliente: c).entroProfilo ?? -1, 0)
        c.profilo.propensione = .dinamica
        verifica("Aree 360: SRI 4 entro il profilo dinamico", MotoreAree360.composizione([conto, fondo], cliente: c).entroProfilo ?? -1, 100)
    }
}
