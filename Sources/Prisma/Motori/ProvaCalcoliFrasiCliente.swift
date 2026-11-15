import Foundation

/// Prove delle frasi del quadro della vista pulita (Migliorie d'uso 1, «Mostra al cliente»): l'articolo davanti alla
/// percentuale, le soglie dei motori (tutto il capitale entro il profilo, i mesi di riserva delle ipotesi), la famiglia sì
/// e no, le coperture a zero. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliFrasiCliente {
    static func esegui(_ verifica: VerificaCalcoli) {
        articolo(verifica)
        protezione(verifica)
        investimenti(verifica)
        risparmio(verifica)
        previdenza(verifica)
    }

    private static func articolo(_ verifica: VerificaCalcoli) {
        verifica.vero("Frasi del cliente: lo 0%", FrasiCliente.articolo(0) == "lo ")
        verifica.vero("Frasi del cliente: l’1%", FrasiCliente.articolo(1) == "l’")
        verifica.vero("Frasi del cliente: l’8%", FrasiCliente.articolo(8) == "l’")
        verifica.vero("Frasi del cliente: l’11%", FrasiCliente.articolo(11) == "l’")
        verifica.vero("Frasi del cliente: l’85%", FrasiCliente.articolo(85) == "l’")
        verifica.vero("Frasi del cliente: il 45%", FrasiCliente.articolo(45) == "il ")
        verifica.vero("Frasi del cliente: il 18%", FrasiCliente.articolo(18) == "il ")
        verifica.vero("Frasi del cliente: Il 92% a inizio frase", FrasiCliente.articolo(92, maiuscolo: true) == "Il ")
        verifica.vero("Frasi del cliente: L’80% a inizio frase", FrasiCliente.articolo(80, maiuscolo: true) == "L’")
        verifica.vero("Frasi del cliente: Lo 0% a inizio frase", FrasiCliente.articolo(0, maiuscolo: true) == "Lo ")
    }

    private static func protezione(_ verifica: VerificaCalcoli) {
        let i = IpotesiProtezione()
        let tcm = AiutiProva.posizione("TCM", .protezione, 0) {
            $0.rischio = .vita
            $0.capitaleAssicurato = 100_000
        }
        let e = MotoreAnalisi.protezione(i, posizioni: [tcm])
        let conFamiglia = FrasiCliente.protezione(i, posizioni: [tcm], sintesi: nil, famiglia: true)
        verifica.vero("Frasi del cliente: protezione con la famiglia",
                      conFamiglia.frase == "Se venisse a mancare il tuo reddito, alla tua famiglia servirebbero altri \(Formati.euro(e.divario)).")
        let p = Int(MotoreAree360.percentuale(e.capitaleVita / e.fabbisogno))
        verifica.vero("Frasi del cliente: quota del capitale caso morte con l’articolo",
                      conFamiglia.seconda == "Oggi il capitale caso morte copre \(FrasiCliente.articolo(p))\(p)% di quello che serve.")
        let senzaFamiglia = FrasiCliente.protezione(i, posizioni: [tcm], sintesi: nil, famiglia: false)
        verifica.vero("Frasi del cliente: protezione senza famiglia", senzaFamiglia.frase.contains("a chi conta su di te"))
        let scoperta = FrasiCliente.protezione(i, posizioni: [], sintesi: nil, famiglia: true)
        verifica.vero("Frasi del cliente: nessun capitale caso morte",
                      scoperta.seconda == "Oggi non c’è ancora un capitale caso morte.")
        let grande = AiutiProva.posizione("TCM", .protezione, 0) {
            $0.rischio = .vita
            $0.capitaleAssicurato = 1_000_000
        }
        verifica.vero("Frasi del cliente: famiglia protetta",
                      FrasiCliente.protezione(i, posizioni: [grande], sintesi: nil, famiglia: true).frase == "La tua famiglia è protetta.")
        verifica.vero("Frasi del cliente: chi conta su di te è protetto",
                      FrasiCliente.protezione(i, posizioni: [grande], sintesi: nil, famiglia: false).frase == "Chi conta su di te è protetto.")
    }

    private static func investimenti(_ verifica: VerificaCalcoli) {
        let fondo = AiutiProva.posizione("Fondo", .investimento, 15_000) { $0.sri = 4 }
        var c = Cliente.nuovo(tinta: .blu)
        c.profilo.propensione = .dinamica
        let tutto = FrasiCliente.investimenti(MotoreAree360.composizione([fondo], cliente: c), sintesi: nil)
        verifica.vero("Frasi del cliente: investimenti in linea con tutto entro il profilo",
                      tutto.frase == "I tuoi investimenti rispettano il rischio che hai scelto.")
        verifica.vero("Frasi del cliente: Il 100% del capitale", tutto.seconda.hasPrefix("Il 100% del capitale"))
        c.profilo.propensione = .moderata
        let fuori = FrasiCliente.investimenti(MotoreAree360.composizione([fondo], cliente: c), sintesi: nil)
        verifica.vero("Frasi del cliente: una parte rischia di più",
                      fuori.frase == "Una parte dei tuoi investimenti rischia più di quanto hai scelto.")
        verifica.vero("Frasi del cliente: Lo 0% del capitale", fuori.seconda.hasPrefix("Lo 0% del capitale"))
        let nessuno = FrasiCliente.investimenti(MotoreAree360.composizione([], cliente: c), sintesi: nil)
        verifica.vero("Frasi del cliente: senza investimenti nessuna cifra", nessuno.valore == nil && nessuno.frazione == nil)
    }

    private static func risparmio(_ verifica: VerificaCalcoli) {
        var a = Analisi360()
        a.protezione.fabbisognoMensile = 2_300
        a.protezione.mesiRiserva = 6
        let corto = AiutiProva.posizione("Conto", .liquidita, 8_050)
        let l = MotoreAree360.liquidita([corto], analisi: a, obiettivi: [], prodotti: [], data: Date())
        let f = FrasiCliente.risparmio(l, sintesi: nil)
        verifica.vero("Frasi del cliente: riserva corta", f.frase == "Hai da parte 3,5 mesi di spese: la riserva è corta.")
        verifica.vero("Frasi del cliente: mesi di riserva dalle ipotesi",
                      f.seconda == "Per gli imprevisti contiamo almeno 6 mesi di spese.")
        let pieno = AiutiProva.posizione("Conto", .liquidita, 2_300 * 7)
        let lp = MotoreAree360.liquidita([pieno], analisi: a, obiettivi: [], prodotti: [], data: Date())
        verifica.vero("Frasi del cliente: la riserva c’è",
                      FrasiCliente.risparmio(lp, sintesi: nil).frase == "Hai da parte 7 mesi di spese: la riserva c’è.")
    }

    private static func previdenza(_ verifica: VerificaCalcoli) {
        var i = IpotesiPrevidenza()
        i.eta = 40; i.etaPensione = 67; i.redditoDesiderato = 2_200; i.pensionePubblica = 1_400
        i.capitale = 0; i.versamentoMensile = 0; i.rendimentoReale = 1.5; i.anniIntegrazione = 25
        let e = MotoreAnalisi.previdenza(i)
        let f = FrasiCliente.previdenza(i, sintesi: nil)
        verifica.vero("Frasi del cliente: quanto manca alla pensione",
                      f.frase == "Per la pensione che desideri mancano circa \(Formati.euro(e.divarioResiduo)) al mese.")
        if e.integrazione < 0.5 {
            verifica.vero("Frasi del cliente: nessun piano per il divario",
                          f.seconda == "Oggi non hai ancora un piano che copra questo divario.")
        }
        var coperta = i
        coperta.pensionePubblica = 2_500
        verifica.vero("Frasi del cliente: pensione coperta",
                      FrasiCliente.previdenza(coperta, sintesi: nil).frase == "La pensione che desideri è coperta.")
    }
}
