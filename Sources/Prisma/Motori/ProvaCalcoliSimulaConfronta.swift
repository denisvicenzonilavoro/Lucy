import Foundation

/// Migliorie d'uso 64 «Simula e confronta: prima la frase»: `MotoreSimulaConfronta` e `TestiSimulaConfronta`. Le
/// opzioni (posizioni in essere, proposte aperte, catalogo senza doppioni, conto in fondo), i parametri con gli stessi
/// soldi (versato uguale per A e B), i netti uguali a quelli di `MotoreProiezione.calcola` (nessun calcolo nuovo), la
/// frase (quasi pari, vince con più rischio, vince con meno rischio, costi oltre la soglia), lo scambio A/B e il titolo
/// dell'ipotesi salvata. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliSimulaConfronta {
    static func esegui(_ verifica: VerificaCalcoli) {
        var etf = Posizione(clienteId: "c", canale: .indipendente, stato: .inEssere, area: .investimento, nome: "ETF azionario globale")
        etf.id = "etf"; etf.controvalore = 20_000; etf.totaleVersato = 18_000; etf.rendimentoAtteso = 5; etf.costoAnnuo = 0.3; etf.sri = 4
        var proposta = Posizione(clienteId: "c", canale: .alleanza, stato: .proposta, area: .risparmio, nome: "Piano di risparmio")
        proposta.id = "proposta"; proposta.esito = .presentata; proposta.rendimentoAtteso = 2.5; proposta.costoAnnuo = 1.2
        proposta.prodottoId = "piano"
        var rifiutata = Posizione(clienteId: "c", canale: .alleanza, stato: .proposta, area: .investimento, nome: "Rifiutata")
        rifiutata.id = "rifiutata"; rifiutata.esito = .rifiutata
        var tcm = Posizione(clienteId: "c", canale: .alleanza, stato: .inEssere, area: .protezione, nome: "TCM")
        tcm.id = "tcm"
        var piano = Prodotto(nome: "Piano di risparmio", canale: .alleanza, area: .risparmio)
        piano.id = "piano"
        var fondo = Prodotto(nome: "Fondo bilanciato", canale: .indipendente, area: .investimento)
        fondo.id = "fondo"; fondo.rendimentoAtteso = 3.5; fondo.costoAnnuo = 1.8; fondo.costoIngresso = 1; fondo.sri = 3
        let polizza = Prodotto(nome: "Polizza casa", canale: .alleanza, area: .protezione)

        // Le opzioni
        let opzioni = MotoreSimulaConfronta.opzioni(posizioni: [etf, proposta, rifiutata, tcm], prodotti: [piano, fondo, polizza],
                                                    simulazioni: [], libera: nil, orizzonteCliente: 10)
        verifica.vero("Simula 64: le strade sono la posizione, la proposta aperta, la scheda nuova del catalogo e il conto",
                      opzioni.map(\.strada) == [.posizione("etf"), .posizione("proposta"), .prodotto("fondo"), .conto])
        verifica.vero("Simula 64: provenienze «ce l’ha già», «proposta», «dal catalogo», «non fare niente»",
                      opzioni.map(\.provenienza) == [TestiSimulaConfronta.haGia, TestiSimulaConfronta.proposta,
                                                     TestiSimulaConfronta.dalCatalogo, TestiSimulaConfronta.nonFareNiente])
        verifica.vero("Simula 64: il conto rende 0% e costa 0% (decisione 64-b)",
                      MotoreSimulaConfronta.conto.rendimento == 0 && MotoreSimulaConfronta.conto.costoAnnuo == 0
                        && MotoreSimulaConfronta.conto.canale == nil)
        verifica.vero("Simula 64: A di partenza la posizione, B di partenza la scheda del catalogo",
                      MotoreSimulaConfronta.predefinitaA(opzioni) == .posizione("etf")
                        && MotoreSimulaConfronta.predefinitaB(opzioni, a: .posizione("etf")) == .prodotto("fondo"))

        // Gli stessi soldi
        let soldi = SoldiSimula(capitale: 10_000, mensile: 200, anni: 12)
        let ipotesi = IpotesiSimula()
        let a = MotoreSimulaConfronta.esito(opzioni[0], soldi: soldi, ipotesi: ipotesi)
        let b = MotoreSimulaConfronta.esito(opzioni[2], soldi: soldi, ipotesi: ipotesi)
        let c = MotoreSimulaConfronta.esito(MotoreSimulaConfronta.conto, soldi: soldi, ipotesi: ipotesi)
        verifica.vero("Simula 64: le due strade hanno lo stesso versato",
                      abs(a.esito.versato - b.esito.versato) < 0.01 && abs(a.esito.versato - c.esito.versato) < 0.01)
        let diretto = MotoreProiezione.calcola(MotoreSimulaConfronta.parametri(opzioni[2], soldi: soldi, ipotesi: ipotesi))
        verifica.vero("Simula 64: il netto è quello di MotoreProiezione.calcola (nessun calcolo nuovo)",
                      abs(diretto.netto - b.esito.netto) < 0.01)
        verifica.vero("Simula 64: il conto non cresce e non paga costi né tasse",
                      abs(c.esito.netto - c.esito.versato) < 0.01 && c.esito.costi == 0 && c.esito.imposte == 0)
        verifica.vero("Simula 64: tre scenari per «Se va diversamente», dal peggiore al migliore",
                      a.scenari.count == 3 && a.scenari[0].esito.netto < a.scenari[2].esito.netto)

        // La frase
        let fraseUna = TestiSimulaConfronta.fraseUna(a, anni: 12)
        verifica.vero("Simula 64: la frase di una strada dice gli anni e la cifra", fraseUna.hasPrefix("Tra 12 anni avrà circa "))
        verifica.vero("Simula 64: «1 anno» al singolare", TestiSimulaConfronta.fraseUnaPrima(anni: 1) == "Tra 1 anno avrà circa ")
        let vinceRischioso = TestiSimulaConfronta.fraseDue(a, c, anni: 12)
        verifica.vero("Simula 64: vince con più rischio («Ma rischia di più»)",
                      MotoreSimulaConfronta.vincitore(a, c) == true && vinceRischioso.contains("più in alto di «\(TestiSimulaConfronta.conto)»")
                        && vinceRischioso.contains("Ma rischia di più: 4 contro 1 su 7."))
        let fondoContoFrase = TestiSimulaConfronta.fraseDue(c, b, anni: 12)
        verifica.vero("Simula 64: con l'ordine invertito vince sempre la strada più alta",
                      MotoreSimulaConfronta.vincitore(c, b) == false && fondoContoFrase.hasPrefix("Tra 12 anni «Fondo bilanciato» arriva "))
        // Una strada che rende di più e rischia meno
        let sicura = OpzioneStrada(strada: .libera, nome: "Sicura", provenienza: "ipotesi mia", gruppo: .mia, canale: nil,
                                   rendimento: 6, costoIngresso: 0, costoAnnuo: 0, sri: 2, scarti: nil)
        let es = MotoreSimulaConfronta.esito(sicura, soldi: soldi, ipotesi: ipotesi)
        let menoRischio = TestiSimulaConfronta.fraseDue(es, a, anni: 12)
        verifica.vero("Simula 64: vince con meno rischio («E rischia anche meno»)", menoRischio.contains("E rischia anche meno."))
        verifica.vero("Simula 64: costi oltre i 200 € nella frase",
                      abs(es.esito.costi - a.esito.costi) <= TestiSimulaConfronta.sogliaCostiInFrase
                        || menoRischio.contains("In costi lascia"))
        // Quasi pari
        let gemella = OpzioneStrada(strada: .libera, nome: "Gemella", provenienza: "ipotesi mia", gruppo: .mia, canale: nil,
                                    rendimento: opzioni[0].rendimento + 0.01, costoIngresso: opzioni[0].costoIngresso,
                                    costoAnnuo: opzioni[0].costoAnnuo, sri: 6, scarti: nil)
        let eg = MotoreSimulaConfronta.esito(gemella, soldi: soldi, ipotesi: ipotesi)
        let pari = TestiSimulaConfronta.fraseDue(a, eg, anni: 12)
        verifica.vero("Simula 64: quasi pari (sotto l'1%) parla del rischio",
                      MotoreSimulaConfronta.vincitore(a, eg) == nil && pari.contains("quasi allo stesso punto")
                        && pari.contains("La differenza la fa il rischio: 4 contro 6 su 7."))

        // Lo scambio
        let s1 = MotoreSimulaConfronta.scegli(.conto, perA: true, a: .posizione("etf"), b: .conto)
        verifica.vero("Simula 64: scegliendo in A la strada di B le due si scambiano", s1.a == .conto && s1.b == .posizione("etf"))
        let s2 = MotoreSimulaConfronta.scegli(.prodotto("fondo"), perA: false, a: .posizione("etf"), b: .conto)
        verifica.vero("Simula 64: una strada nuova in B lascia A com'è", s2.a == .posizione("etf") && s2.b == .prodotto("fondo"))

        // L'ipotesi salvata
        let salvata = MotoreSimulaConfronta.simulazione(a, soldi: soldi, ipotesi: ipotesi, cliente: "c")
        verifica.vero("Simula 64: l'ipotesi salvata ha i soldi comuni, la posizione e il titolo breve",
                      salvata.capitale == 10_000 && salvata.versamentoMensile == 200 && salvata.anni == 12
                        && salvata.posizioneId == "etf" && salvata.titolo.hasPrefix("ETF azionario globale · ")
                        && salvata.titolo.hasSuffix(" anni"))
        verifica.vero("Simula 64: riaperta, l'ipotesi salvata dà le stesse cifre",
                      abs(MotoreProiezione.calcola(salvata.parametri).netto - a.esito.netto) < 1)
    }
}
