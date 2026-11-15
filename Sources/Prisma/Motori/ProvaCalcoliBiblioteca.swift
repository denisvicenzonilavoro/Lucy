import Foundation

/// Prove della Biblioteca · «Trova la pagina» (Design/template-luce-specifica.md §8.1.5.2 punto 9, «Luce» giro 6): la
/// divisione in passi con le intestazioni (anche dalla pagina prima), le finestre per le pagine senza paragrafi, la
/// normalizzazione delle parole, BM25 sui sei fac-simile (le tre domande del template trovano la pagina giusta al primo
/// posto, e la pagina contiene davvero la frase), «non trovata» per una domanda fuori dai documenti, la frase cercata
/// parola per parola (a capo e sillabazioni), il tetto dell'indice e l'avviso sui parametri di Prisma superati.
/// Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliBiblioteca {
    static func esegui(_ verifica: VerificaCalcoli) {
        parole(verifica)
        passi(verifica)
        ricerca(verifica)
        frase(verifica)
        parametri(verifica)
        edizioni(verifica)
        delCliente(verifica)
    }

    private static func parole(_ verifica: VerificaCalcoli) {
        verifica.vero("Biblioteca: «riscatto» e «riscattare» hanno la stessa radice",
                      MotoreBiblioteca.radice("riscatto") == MotoreBiblioteca.radice("riscattare"))
        verifica.vero("Biblioteca: «deduce» e «deducibilità» hanno la stessa radice",
                      MotoreBiblioteca.parole("deduce") == MotoreBiblioteca.parole("deducibilità"))
        verifica.vero("Biblioteca: «paga» e «pagamento» hanno la stessa radice",
                      MotoreBiblioteca.parole("paga") == MotoreBiblioteca.parole("pagamento"))
        verifica.vero("Biblioteca: minuscole, senza accenti e senza parole vuote",
                      MotoreBiblioteca.parole("Il RISCATTO è possibile nei primi anni?") == MotoreBiblioteca.parole("riscatto possibile primi anni"))
    }

    private static func passi(_ verifica: VerificaCalcoli) {
        let pagine = ["Art. 9 – Riscatto\n\nPrimo paragrafo del riscatto, abbastanza lungo.\n\nSecondo paragrafo del riscatto, anche lui lungo.",
                      "Il seguito dell'articolo 9 sulla pagina dopo, senza titolo."]
        let p = MotoreBiblioteca.passi(pagine: pagine, documentoId: "d")
        verifica.vero("Biblioteca: un passo per paragrafo, con la pagina", p.count == 3 && p.map(\.pagina) == [1, 1, 2])
        verifica.vero("Biblioteca: l'intestazione resta anche sulla pagina dopo",
                      p.allSatisfy { $0.intestazione == "Art. 9 – Riscatto" } && p.first?.intestazioneVista == "Art. 9 · Riscatto")
        verifica.vero("Biblioteca: «Paragrafo», «Sezione» e i numeri romani sono intestazioni",
                      MotoreBiblioteca.eIntestazione("Paragrafo 2 – Limiti") && MotoreBiblioteca.eIntestazione("Sezione 5 – Anticipazioni")
                      && MotoreBiblioteca.eIntestazione("IV. Disposizioni finali") && !MotoreBiblioteca.eIntestazione("Il contraente paga il premio."))
        let lunga = (1...300).map { "parola\($0)" }.joined(separator: " ")
        let finestre = MotoreBiblioteca.passi(pagine: [lunga], documentoId: "l")
        verifica.vero("Biblioteca: una pagina senza paragrafi in finestre di 120 parole sovrapposte di 20 (\(finestre.count))",
                      finestre.count == 3 && finestre[1].testo.hasPrefix("parola101 "))
    }

    /// I sei fac-simile, come li carica Prisma con i clienti di prova.
    static func fonti() -> [MotoreBiblioteca.Fonte] {
        EsempiBiblioteca.elenco.compactMap { e in
            EsempiBiblioteca.pagine(e.risorsa).map { MotoreBiblioteca.Fonte(id: e.risorsa, titolo: e.titolo, pagine: $0) }
        }
    }

    private static func ricerca(_ verifica: VerificaCalcoli) {
        let f = fonti()
        verifica.vero("Biblioteca: i sei fac-simile nel pacchetto (\(f.count)), con le pagine del template",
                      f.count == 6 && f.map(\.pagine.count) == [38, 24, 52, 3, 12, 64])
        let indice = MotoreBiblioteca.indice(f)
        verifica.vero("Biblioteca: l'indice conta tutte le pagine (\(indice.pagine))", indice.pagine == 193 && indice.esclusi == 0)
        let casi: [(String, String, Int, String)] = [
            ("Il riscatto nei primi anni ha penali?", "piano-rivalutabile", 14, "penale dell'1% per ogni anno che manca al quinto"),
            ("Quanto si deduce del fondo pensione?", "circolare-previdenza", 3, "deducibili dal reddito complessivo fino a 5.164,57 euro"),
            ("Se Marco non paga la temporanea?", "temporanea-caso-morte", 9, "la copertura resta sospesa"),
        ]
        for (domanda, documento, pagina, frase) in casi {
            let t = MotoreBiblioteca.cerca(domanda, in: indice)
            let primo = t.first?.passo
            verifica.vero("Biblioteca: «\(domanda)» trova \(documento) a pagina \(pagina) al primo posto (\(primo?.documentoId ?? "niente") p. \(primo?.pagina ?? 0))",
                          primo?.documentoId == documento && primo?.pagina == pagina && t.count <= MotoreBiblioteca.quanti)
            // La pagina trovata contiene davvero la frase della risposta
            let testo = f.first { $0.id == documento }.map { $0.pagine[pagina - 1] } ?? ""
            verifica.vero("Biblioteca: la pagina \(pagina) di \(documento) contiene la frase", MotoreBiblioteca.intervallo(frase, in: testo) != nil
                          && t.contains { MotoreBiblioteca.fraseNelPasso(frase, $0.passo) })
        }
        verifica.vero("Biblioteca: una domanda fuori dai documenti non trova niente (stato «non trovata»)",
                      MotoreBiblioteca.cerca("Qual è la ricetta della torta di mele?", in: indice).isEmpty)
        verifica.vero("Biblioteca: senza parole utili nessun passo", MotoreBiblioteca.cerca("e se di", in: indice).isEmpty)
        let vicine = MotoreBiblioteca.pagineVicine(MotoreBiblioteca.cerca("Riscatto e penali del fondo pensione", in: indice))
        verifica.vero("Biblioteca: le pagine vicine sono al più tre, una per pagina",
                      vicine.count <= 3 && Set(vicine.map { "\($0.documentoId)#\($0.pagina)" }).count == vicine.count)
        // Il tetto della memoria: si indicizzano i documenti più recenti e si dice quanti sono rimasti fuori
        let datate = f.enumerated().map { i, x in
            MotoreBiblioteca.Fonte(id: x.id, titolo: x.titolo, pagine: x.pagine, importatoIl: Date(timeIntervalSince1970: Double(i) * 1_000))
        }
        let parziale = MotoreBiblioteca.indice(datate, tetto: 6_000)
        verifica.vero("Biblioteca: oltre il tetto entrano i documenti più recenti (\(parziale.documenti) dentro, \(parziale.esclusi) fuori)",
                      parziale.esclusi > 0 && parziale.documenti + parziale.esclusi == 6
                      && parziale.passi.contains { $0.documentoId == "normativa-riferimento" })
    }

    private static func frase(_ verifica: VerificaCalcoli) {
        let testo = "Fino al quinto anno si applica una pe-\nnale dell’1% per ogni anno\n   che manca al quinto."
        verifica.vero("Biblioteca: la frase si trova anche con a capo, sillabazione e apostrofo tipografico",
                      MotoreBiblioteca.intervallo("«si applica una penale dell'1% per ogni anno che manca al quinto»", in: testo) != nil)
        verifica.vero("Biblioteca: una frase che il testo non dice non si trova",
                      MotoreBiblioteca.intervallo("si applica una penale del 2% per ogni anno", in: testo) == nil)
        verifica.vero("Biblioteca: una frase troppo corta non vale come citazione", MotoreBiblioteca.intervallo("quinto", in: testo) == nil)
        if let r = MotoreBiblioteca.intervallo("una penale dell'1%", in: testo) {
            verifica.vero("Biblioteca: l'intervallo trovato è quello del testo originale", testo[r].hasPrefix("una pe") && testo[r].hasSuffix("1%"))
        } else {
            verifica.vero("Biblioteca: l'intervallo trovato è quello del testo originale", false)
        }
    }

    private static func parametri(_ verifica: VerificaCalcoli) {
        let superato = MotoreBiblioteca.avvisoParametri("I contributi sono deducibili fino a 5.164,57 euro l'anno.")
        verifica.vero("Biblioteca: una deducibilità diversa da quella di Prisma fa comparire l'avviso",
                      superato?.contains(Formati.euro(RegoleFiscali.limiteDeducibilita)) == true && superato?.contains("superato") == true)
        verifica.vero("Biblioteca: con la cifra di Prisma nessun avviso",
                      MotoreBiblioteca.avvisoParametri("I contributi sono deducibili fino a 5.300 euro l'anno.") == nil)
        verifica.vero("Biblioteca: senza parlare di deducibilità nessun avviso",
                      MotoreBiblioteca.avvisoParametri("Il capitale minimo è di 2.000 euro.") == nil)
    }

    // MARK: - Edizioni e prodotti (§8.1.6 punto 3, §8.1.5.2 punto 6)

    /// Un documento di prova collegato (o no) a un prodotto, con la sua edizione.
    private static func documento(_ id: String, edizione: String, prodotto: String?, genere: GenereBiblioteca = .condizioni,
                                  importato: Date = AiutiProva.data(2026, 3, 2)) -> DocumentoBiblioteca {
        var d = DocumentoBiblioteca(titolo: "Prodotto di prova \(id) · Condizioni", sigla: "", edizione: edizione, file: "\(id).txt")
        d.id = id
        d.prodottoId = prodotto
        d.genere = genere
        d.pagine = 3
        d.testo = "\(id).txt"
        d.importatoIl = importato
        return d
    }

    private static func edizioni(_ verifica: VerificaCalcoli) {
        verifica.vero("Biblioteca: le edizioni si leggono come date da confrontare (mese/anno, giorno/mese/anno, a parole, anno)",
                      MotoreBiblioteca.chiaveEdizione("fac-simile, ed. 03/2026") == 20260300
                        && MotoreBiblioteca.chiaveEdizione("Edizione 12/05/2025") == 20250512
                        && MotoreBiblioteca.chiaveEdizione("aggiornato al 1° ottobre 2026") == 20261001
                        && MotoreBiblioteca.chiaveEdizione("importato il 9 novembre 2026") == 20261109
                        && MotoreBiblioteca.chiaveEdizione("Raccolta 2024") == 20240000)
        verifica.vero("Biblioteca: un'edizione senza data non si confronta (mai indovinata)",
                      MotoreBiblioteca.chiaveEdizione("ultima versione") == nil && MotoreBiblioteca.chiaveEdizione("") == nil
                        && MotoreBiblioteca.chiaveEdizione("ed. 13/2026") == nil)

        let nuova = documento("nuova", edizione: "ed. 03/2026", prodotto: "prod-prova")
        let vecchia = documento("vecchia", edizione: "ed. 07/2024", prodotto: "prod-prova")
        let altroProdotto = documento("altro", edizione: "ed. 01/2020", prodotto: "prod-altro")
        let senzaProdotto = documento("libero", edizione: "ed. 01/2019", prodotto: nil)
        let stessa = documento("kid", edizione: "ed. 03/2026", prodotto: "prod-prova", genere: .kid)
        let tutti = [nuova, vecchia, altroProdotto, senzaProdotto, stessa]
        let dallaNuova = MotoreBiblioteca.avvisoEdizione(nuova, tra: tutti)
        verifica.vero("Biblioteca: la risposta dalla nuova edizione avvisa «c'è anche un'edizione più vecchia» (con quale)",
                      dallaNuova?.hasPrefix("C'è anche un'edizione più vecchia") == true && dallaNuova?.contains("ed. 07/2024") == true
                        && dallaNuova?.contains("01/2020") == false)
        let dallaVecchia = MotoreBiblioteca.avvisoEdizione(vecchia, tra: tutti)
        verifica.vero("Biblioteca: la risposta dalla vecchia edizione dice che ce n'è una più recente",
                      dallaVecchia?.hasPrefix("C'è un'edizione più recente") == true && dallaVecchia?.contains("ed. 03/2026") == true)
        verifica.vero("Biblioteca: senza prodotto collegato, o con la stessa edizione, nessun avviso",
                      MotoreBiblioteca.avvisoEdizione(senzaProdotto, tra: tutti) == nil
                        && MotoreBiblioteca.avvisoEdizione(altroProdotto, tra: tutti) == nil
                        && MotoreBiblioteca.altreEdizioni(stessa, tra: tutti).map(\.id) == ["vecchia"])
        let senzaData = documento("senza-data", edizione: "versione del cliente", prodotto: "prod-prova")
        verifica.vero("Biblioteca: edizioni che non si confrontano: «c'è anche un'altra edizione»",
                      MotoreBiblioteca.avvisoEdizione(senzaData, tra: [senzaData, nuova])?.hasPrefix("C'è anche un'altra edizione") == true)

        verifica.vero("Prodotti: «Condizioni nella Biblioteca» apre le condizioni dell'edizione più recente, non il KID",
                      MotoreBiblioteca.condizioniDelProdotto("prod-prova", tra: tutti)?.id == "nuova"
                        && MotoreBiblioteca.condizioniDelProdotto("prod-nessuno", tra: tutti) == nil)
        var illeggibile = documento("scansione", edizione: "ed. 01/2027", prodotto: "prod-prova")
        illeggibile.testo = nil
        verifica.vero("Prodotti: un documento illeggibile non si apre da «Condizioni nella Biblioteca»",
                      MotoreBiblioteca.condizioniDelProdotto("prod-prova", tra: tutti + [illeggibile])?.id == "nuova")
    }

    // MARK: - Migliorie d'uso 35: i documenti del cliente, le domande d'esempio, la ricerca in un documento

    private static func delCliente(_ verifica: VerificaCalcoli) {
        func posizione(_ stato: StatoPosizione, prodotto: String?, esito: EsitoProposta? = nil) -> Posizione {
            var p = Posizione(clienteId: "prova", canale: .alleanza, stato: stato, area: .risparmio, nome: "Prova")
            p.prodottoId = prodotto
            p.esito = esito
            return p
        }
        let posizioni = [posizione(.inEssere, prodotto: "p-essere"),
                         posizione(.proposta, prodotto: "p-proposta", esito: .presentata),
                         posizione(.proposta, prodotto: "p-rifiutata", esito: .rifiutata),
                         posizione(.chiusa, prodotto: "p-chiusa"),
                         posizione(.inEssere, prodotto: nil)]
        let prodotti = MotoreBiblioteca.prodottiDelCliente(posizioni)
        verifica.vero("Biblioteca: i prodotti del cliente sono quelli in essere e delle proposte non rifiutate (\(prodotti.sorted()))",
                      prodotti == ["p-essere", "p-proposta"])
        var illeggibile = documento("scansione", edizione: "ed. 01/2026", prodotto: "p-proposta")
        illeggibile.testo = nil
        let documenti = [documento("libero", edizione: "", prodotto: nil),
                         documento("essere", edizione: "", prodotto: "p-essere"),
                         documento("rifiutata", edizione: "", prodotto: "p-rifiutata"),
                         illeggibile,
                         documento("chiusa", edizione: "", prodotto: "p-chiusa")]
        verifica.vero("Biblioteca: i documenti del cliente nell'ordine dell'elenco, anche l'illeggibile, non quelli delle proposte rifiutate né delle chiuse",
                      MotoreBiblioteca.documentiDelCliente(prodotti: prodotti, tra: documenti) == ["essere", "scansione"])
        verifica.vero("Biblioteca: senza prodotti nessun documento del cliente",
                      MotoreBiblioteca.documentiDelCliente(prodotti: [], tra: documenti).isEmpty)

        // Le domande d'esempio: la domanda su Marco solo con Marco o con «Tutti i clienti», senza nome in modalità cliente
        let tutte = MotoreBiblioteca.domandeEsempio(documento: nil, cliente: nil, modoCliente: false)
        verifica.vero("Biblioteca: con «Tutti i clienti» le tre domande del template", tutte.count == 3 && tutte.last == "Se Marco non paga la temporanea?")
        let giulia = MotoreBiblioteca.domandeEsempio(documento: nil, cliente: "giulia", modoCliente: false)
        verifica.vero("Biblioteca: con un altro cliente la domanda che nomina Marco non c'è",
                      giulia.count == 2 && !giulia.contains { $0.contains("Marco") })
        verifica.vero("Biblioteca: con Marco la domanda su Marco resta",
                      MotoreBiblioteca.domandeEsempio(documento: nil, cliente: "marco", modoCliente: false).contains("Se Marco non paga la temporanea?"))
        verifica.vero("Biblioteca: in modalità cliente la domanda è senza nome",
                      MotoreBiblioteca.domandeEsempio(documento: nil, cliente: "giulia", modoCliente: true).last == "Se il cliente non paga la temporanea?")
        verifica.vero("Biblioteca: le domande di un documento (il piano rivalutabile: una; il KID: nessuna)",
                      MotoreBiblioteca.domandeEsempio(documento: "Piano rivalutabile · Condizioni di assicurazione", cliente: "giulia", modoCliente: false)
                        == ["Il riscatto nei primi anni ha penali?"]
                        && MotoreBiblioteca.domandeEsempio(documento: "Fondo azionario globale · KID", cliente: nil, modoCliente: false).isEmpty)
        verifica.vero("Biblioteca: ogni domanda d'esempio parla di un fac-simile che c'è",
                      EsempiBiblioteca.domande.allSatisfy { q in EsempiBiblioteca.elenco.contains { $0.titolo == q.documento } })
        let passi = MotoreBiblioteca.passi(pagine: ["Art. 1 – Oggetto\n\nIl testo del primo articolo, abbastanza lungo.\n\nArt. 2 – Recesso\n\nIl testo del secondo articolo, abbastanza lungo.\n\nArt. 3 – Oggetto\n\nIl testo del terzo articolo, abbastanza lungo."],
                                           documentoId: "r")
        verifica.vero("Biblioteca: le rubriche dalle intestazioni, senza doppioni (\(MotoreBiblioteca.rubriche(passi)))",
                      MotoreBiblioteca.rubriche(passi) == ["Oggetto", "Recesso"])
        verifica.vero("Biblioteca: «38 pagine · canale …» e «vale per tutti i canali»",
                      TestiBiblioteca.pagineECanale(pagine: 38, canale: nil) == "38 pagine · vale per tutti i canali"
                        && TestiBiblioteca.pagineECanale(pagine: 1, canale: .alleanza).hasPrefix("1 pagina · canale "))

        // La ricerca dentro un documento: solo i suoi passi
        let indice = MotoreBiblioteca.indice(fonti())
        let dentro = MotoreBiblioteca.cerca("Il riscatto nei primi anni ha penali?", in: indice, solo: "piano-rivalutabile")
        verifica.vero("Biblioteca: con il documento aperto la domanda cerca solo lì (pagina 14 del piano rivalutabile)",
                      !dentro.isEmpty && dentro.allSatisfy { $0.passo.documentoId == "piano-rivalutabile" } && dentro.first?.passo.pagina == 14)
        let altrove = MotoreBiblioteca.cerca("Il riscatto nei primi anni ha penali?", in: indice, solo: "fondo-azionario-globale")
        verifica.vero("Biblioteca: in un altro documento la stessa domanda trova solo i passi di quel documento",
                      altrove.allSatisfy { $0.passo.documentoId == "fondo-azionario-globale" })
        verifica.vero("Biblioteca: senza documento aperto la ricerca resta quella di sempre",
                      MotoreBiblioteca.cerca("Il riscatto nei primi anni ha penali?", in: indice, solo: nil)
                        == MotoreBiblioteca.cerca("Il riscatto nei primi anni ha penali?", in: indice))
    }
}
