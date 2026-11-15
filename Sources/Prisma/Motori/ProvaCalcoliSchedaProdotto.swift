import Foundation

/// Migliorie d'uso 63 «I prodotti parlano chiaro»: `MotoreSchedaProdotto`. L'esito per il cliente (oltre il profilo con la
/// soglia di `MotoreCoerenza.sriMassimo`, priorità dalle prime tre aree, in linea; senza propensione o senza SRI mai
/// «oltre»), l'ordine dell'elenco (priorità, in linea, oltre; a parità l'ordine ricevuto) e le frasi «È per» / «Non è
/// per» proposte dai dati della scheda (protezione, previdenza, SRI alto e basso, periodo mancante).
/// Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliSchedaProdotto {
    static func esegui(_ verifica: VerificaCalcoli) {
        var etf = Prodotto(nome: "ETF", canale: .indipendente, area: .investimento)
        etf.id = "etf"; etf.sri = 4; etf.periodoRaccomandato = 5
        var pip = Prodotto(nome: "PIP", canale: .alleanza, area: .previdenza)
        pip.id = "pip"; pip.sri = 2
        var tcm = Prodotto(nome: "TCM", canale: .alleanza, area: .protezione)
        tcm.id = "tcm"
        var risparmio = Prodotto(nome: "Risparmio", canale: .alleanza, area: .risparmio)
        risparmio.id = "risparmio"; risparmio.sri = 2; risparmio.periodoRaccomandato = 10
        risparmio.garanzie = "Capitale garantito a scadenza"

        // Esito
        verifica.vero("Scheda 63: SRI 4 con un profilo prudente rischia più del profilo",
                      MotoreSchedaProdotto.esito(etf, propensione: .prudente, priorita: [.investimenti]) == .oltreProfilo)
        verifica.vero("Scheda 63: SRI 4 con un profilo dinamico e l'area fra le priorità risponde a una priorità",
                      MotoreSchedaProdotto.esito(etf, propensione: .dinamica, priorita: [.previdenza, .investimenti]) == .priorita)
        verifica.vero("Scheda 63: nessuna tolleranza, SRI 3 con un profilo prudente (fino a 2) è oltre",
                      MotoreSchedaProdotto.esito({ var x = etf; x.sri = 3; return x }(), propensione: .prudente, priorita: []) == .oltreProfilo)
        verifica.vero("Scheda 63: area fuori dalle priorità e rischio nel profilo è in linea",
                      MotoreSchedaProdotto.esito(pip, propensione: .moderata, priorita: [.investimenti]) == .inLinea)
        verifica.vero("Scheda 63: senza propensione mai oltre il profilo",
                      MotoreSchedaProdotto.esito(etf, propensione: nil, priorita: []) == .inLinea)
        verifica.vero("Scheda 63: senza SRI mai oltre il profilo (la protezione fra le priorità)",
                      MotoreSchedaProdotto.esito(tcm, propensione: .prudente, priorita: [.protezione]) == .priorita)
        verifica.vero("Scheda 63: la quarta area non è una priorità",
                      MotoreSchedaProdotto.esito(pip, propensione: .moderata,
                                                 priorita: [.investimenti, .protezione, .risparmio, .previdenza]) == .inLinea)

        // Ordine
        let esiti: [String: EsitoProdottoCliente] = ["etf": .oltreProfilo, "pip": .inLinea, "tcm": .priorita, "risparmio": .inLinea]
        let ordinate = MotoreSchedaProdotto.ordina([etf, pip, tcm, risparmio], esiti: esiti).map(\.id)
        verifica.vero("Scheda 63: priorità, in linea (nell'ordine ricevuto), oltre il profilo",
                      ordinate == ["tcm", "pip", "risparmio", "etf"])
        verifica.vero("Scheda 63: senza esiti l'ordine resta",
                      MotoreSchedaProdotto.ordina([etf, pip, tcm], esiti: [:]).map(\.id) == ["etf", "pip", "tcm"])

        // Frasi proposte
        let fTcm = MotoreSchedaProdotto.proposta(tcm)
        verifica.vero("Scheda 63: protezione «molta protezione con poca spesa» e «Chi cerca un rendimento»",
                      fTcm.perChi == ["Chi vuole molta protezione con poca spesa"] && fTcm.nonPerChi == ["Chi cerca un rendimento"])
        let fPip = MotoreSchedaProdotto.proposta(pip)
        verifica.vero("Scheda 63: previdenza «Chi vuole una pensione più alta», SRI 2 «Chi cerca la crescita dei mercati»",
                      fPip.perChi.contains("Chi vuole una pensione più alta")
                        && fPip.nonPerChi.contains("Chi cerca la crescita dei mercati"))
        verifica.vero("Scheda 63: senza periodo nessuna frase sugli anni",
                      !(fPip.perChi + fPip.nonPerChi).contains { $0.contains("anni") || $0.contains("anno") })
        let fEtf = MotoreSchedaProdotto.proposta(etf)
        verifica.vero("Scheda 63: SRI 4 «Chi non sopporta di vedere il valore scendere» e i 5 anni",
                      fEtf.nonPerChi.contains("Chi non sopporta di vedere il valore scendere")
                        && fEtf.perChi.contains("Chi ha almeno 5 anni davanti")
                        && fEtf.nonPerChi.contains("Chi può avere bisogno di quei soldi prima di 5 anni"))
        verifica.vero("Scheda 63: «Nessuna garanzia» non è un capitale protetto",
                      !MotoreSchedaProdotto.garantito({ var x = etf; x.garanzie = "Nessuna garanzia di capitale."; return x }()))
        let fRisparmio = MotoreSchedaProdotto.proposta(risparmio)
        verifica.vero("Scheda 63: una garanzia sul capitale dà «Chi vuole il capitale protetto»",
                      fRisparmio.perChi.contains("Chi vuole il capitale protetto"))
        verifica.vero("Scheda 63: al più tre righe per parte",
                      [fTcm, fPip, fEtf, fRisparmio].allSatisfy {
                          $0.perChi.count <= MotoreSchedaProdotto.righeMassime && $0.nonPerChi.count <= MotoreSchedaProdotto.righeMassime
                      })
    }
}
