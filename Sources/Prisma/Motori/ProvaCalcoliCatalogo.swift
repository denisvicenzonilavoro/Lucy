import Foundation

/// Prove del catalogo dei prodotti (fase 2, «motore di calcolo»): la risorsa che si carica con versione e data, gli
/// esempi del foglio Leggimi (imposta infortuni su 300 €, invalidità con franchigia, ULTRA Salute mensile, detrazione
/// TCM), una riga vera per ciascun foglio (GenerAzione Investimento, una protezione, GenerAzione Previdente Gesav), il
/// dato che manca detto «non disponibile» e mai zero, le schede di categoria fuori dai prodotti ma nella guida, e
/// `abbina` che trova il prodotto da un nome scritto in un altro modo. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliCatalogo {
    static func esegui(_ verifica: VerificaCalcoli) {
        guard let catalogo = CatalogoProdotti.condiviso else {
            verifica.vero("Catalogo: la risorsa Catalogo/catalogo.json si carica", false)
            return
        }
        risorsa(verifica, catalogo)
        leggimi(verifica, catalogo)
        investimento(verifica, catalogo)
        protezione(verifica, catalogo)
        previdenza(verifica, catalogo)
        mancanti(verifica, catalogo)
        ricerca(verifica, catalogo)
    }

    private static func risorsa(_ verifica: VerificaCalcoli, _ c: CatalogoProdotti) {
        let data = c.data.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil
        verifica.vero("Catalogo: versione \(c.versione) e data \(c.data)", c.versione >= 1 && data)
        verifica.vero("Catalogo: i tre fogli pieni (\(c.investimento.count), \(c.protezione.count), \(c.previdenza.count))",
                      !c.investimento.isEmpty && !c.protezione.isEmpty && !c.previdenza.isEmpty)
        verifica.vero("Catalogo: il foglio di ogni voce è giusto",
                      c.investimento.allSatisfy { $0.foglio == .investimento } && c.protezione.allSatisfy { $0.foglio == .protezione }
                      && c.previdenza.allSatisfy { $0.foglio == .previdenza })
        verifica.vero("Catalogo: avvertenza, Leggimi e Fiscalità letti",
                      !c.avvertenza.isEmpty && !c.leggimi.isEmpty && !c.fiscalita.isEmpty && c.datoMancante == MotoreCatalogo.datoMancante)
        verifica.vero("Catalogo: la stessa risorsa letta due volte è lo stesso catalogo",
                      CatalogoProdotti.condiviso?.versione == c.versione)
    }

    /// Gli esempi del foglio Leggimi.
    private static func leggimi(_ verifica: VerificaCalcoli, _ c: CatalogoProdotti) {
        let imposta = MotoreCatalogo.impostaContenuta(premio: 300, aliquota: FiscoCatalogo.impostaInfortuniMalattia)
        verifica("Catalogo: imposta infortuni 2,5% contenuta in 300 €", imposta.cifra.minimo ?? -1, 7.32)
        let passo = imposta.passi.first ?? ""
        verifica.vero("Catalogo: il passo dell'imposta dice premio, aliquota e divisore («\(passo)»)",
                      passo.hasPrefix("Premio annuo 300") && passo.contains("× imposta 2,5% / 1,025 = 7,32"))

        let invalidita = MotoreCatalogo.indennizzoInvalidita(capitale: 100_000, invalidita: 0.07, franchigia: 0.03)
        verifica("Catalogo: invalidità 7% con franchigia 3% su 100.000 €", invalidita.cifra.minimo ?? -1, 4000)
        let sotto = MotoreCatalogo.indennizzoInvalidita(capitale: 100_000, invalidita: 0.20, franchigia: 0.25)
        verifica("Catalogo: invalidità 20% con franchigia 25%: non pagata", sotto.cifra.minimo ?? -1, 0)

        if let ultra = c.prodotti(.protezione).first(where: { $0.prodotto.hasPrefix("Allianz ULTRA Salute") && $0.valori.intervallo("frazionamento") != nil }) {
            let r = MotoreCatalogo.protezione(ultra, IngressoCatalogo(importo: 1000))
            verifica("Catalogo: Allianz ULTRA Salute mensile = premio × 1,056", r.pezzo("frazionamento")?.cifra.minimo ?? -1, 1056)
        } else {
            verifica.vero("Catalogo: Allianz ULTRA Salute con il frazionamento nel catalogo", false)
        }

        let tcm = MotoreCatalogo.detrazione(premio: 800, massimale: FiscoCatalogo.massimaleTCMInfortuni)
        verifica("Catalogo: detrazione TCM min(800; 530) × 19%", tcm.cifra.minimo ?? -1, 100.70)
        let piccola = MotoreCatalogo.detrazione(premio: 300, massimale: FiscoCatalogo.massimaleTCMInfortuni)
        verifica("Catalogo: detrazione TCM min(300; 530) × 19%", piccola.cifra.minimo ?? -1, 57)
        let ltc = MotoreCatalogo.detrazione(premio: 2000, massimale: FiscoCatalogo.massimaleLTC)
        verifica("Catalogo: detrazione LTC min(2.000; 1.291,14) × 19%", ltc.cifra.minimo ?? -1, 245.32)
    }

    /// GenerAzione Investimento: penali, incidenze del KID come intervallo, bollo.
    private static func investimento(_ verifica: VerificaCalcoli, _ c: CatalogoProdotti) {
        guard let voce = c.cerca("GenerAzione Investimento", compagnia: "Generali", foglio: .investimento).first else {
            verifica.vero("Catalogo: GenerAzione Investimento nel catalogo", false)
            return
        }
        let r = MotoreCatalogo.investimento(voce, IngressoCatalogo(importo: 10_000, annoInizio: 2025), annoCorrente: 2026)
        let secondo = r.penali.first { $0.anno == 2 }
        verifica.vero("Catalogo: GenerAzione Investimento, penale 2,5% al 2° anno", secondo?.stato == .quota(0.025))
        verifica("Catalogo: penale al 2° anno su 10.000 €", secondo?.importo.minimo ?? -1, 250)
        verifica.vero("Catalogo: al 1° anno il riscatto non è possibile", r.penali.first?.stato == .riscattoNonPossibile)
        verifica.vero("Catalogo: dopo il 6° anno nessuna penale («poi 0»)", r.penali.first { $0.anno == 7 }?.stato == .quota(0))
        verifica("Catalogo: la penale di quest'anno (2° anno di polizza)", r.pezzo("penale_oggi")?.cifra.minimo ?? -1, 250)
        let primo = r.pezzo("primo_anno")?.cifra
        verifica.vero("Catalogo: costi del 1° anno dal KID come intervallo (\(primo?.testoEuro ?? "-"))",
                      primo?.disponibile == true && primo?.minimo != primo?.massimo)
        verifica("Catalogo: costi del 1° anno, minimo (10.000 × 4,84%)", primo?.minimo ?? -1, 484)
        verifica("Catalogo: costi del 1° anno, massimo (10.000 × 6,32%)", primo?.massimo ?? -1, 632)
        if case .intervallo(let a, let b) = r.totale.cifra {
            verifica("Catalogo: costi sul periodo raccomandato, minimo (10.000 × 1,96% × 6)", a, 1176)
            verifica("Catalogo: costi sul periodo raccomandato, massimo (10.000 × 4,11% × 6)", b, 2466)
        } else {
            verifica.vero("Catalogo: il totale con l'intervallo del KID è un intervallo", false)
        }
        verifica("Catalogo: bollo 0,2% sul versamento", r.pezzo("bollo")?.cifra.minimo ?? -1, 20)
        verifica.vero("Catalogo: ogni pezzo ha i suoi passi", r.pezzi.allSatisfy { !$0.passi.isEmpty } && !r.totale.passi.isEmpty)

        // Stesse penali senza «poi 0» nel testo: dopo l'ultimo anno la penale manca, non è zero.
        var senzaFine = voce
        senzaFine.testo["penali"] = "2° anno 2,5%; 3° 2%; 4° 1,5%; 5° 1%; 6° 0,5%"
        let p7 = MotoreCatalogo.penali(senzaFine, versamento: 10_000).first { $0.anno == 7 }
        verifica.vero("Catalogo: senza «poi 0» la penale del 7° anno è non disponibile", p7?.stato == .nonDisponibile && p7?.importo == .nonDisponibile)
    }

    private static func protezione(_ verifica: VerificaCalcoli, _ c: CatalogoProdotti) {
        // Una TCM vera con detrazione 19% su 530 €.
        guard let tcm = c.prodotti(.protezione).first(where: {
            $0.testo["categoria"] == "TCM" && $0.valori.numero("detrazione") == 0.19 && $0.valori.numero("detrazione_massimale_euro") == 530
        }) else {
            verifica.vero("Catalogo: una TCM con la detrazione nel catalogo", false)
            return
        }
        let r = MotoreCatalogo.protezione(tcm, IngressoCatalogo(importo: 800, annoInizio: 2024, terzo: .anni(10)), annoCorrente: 2026)
        verifica("Catalogo: \(tcm.prodotto), detrazione min(800; 530) × 19%", r.pezzo("detrazione")?.cifra.minimo ?? -1, 100.70)
        let disabile = MotoreCatalogo.protezione(tcm, IngressoCatalogo(importo: 800), beneficiarioDisabile: true)
        verifica("Catalogo: con beneficiario disabile grave il massimale è 750 €", disabile.pezzo("detrazione")?.cifra.minimo ?? -1, 142.50)
        verifica("Catalogo: costo sulla durata 800 € × 10 anni", r.totale.cifra.minimo ?? -1, 8000)
        verifica("Catalogo: premi già pagati dal 2024 al 2026", r.pezzo("gia_pagati")?.cifra.minimo ?? -1, 2400)

        // Un infortuni con l'aliquota nella riga.
        if let inf = c.prodotti(.protezione).first(where: { $0.testo["categoria"] == "Infortuni" && $0.valori.numero("imposta_premio") == 0.025 }) {
            let ri = MotoreCatalogo.protezione(inf, IngressoCatalogo(importo: 300))
            verifica("Catalogo: \(inf.prodotto), imposta contenuta in 300 €", ri.pezzo("imposte")?.cifra.minimo ?? -1, 7.32)
        }
        // L'aliquota della riga vince su quella di legge (RC sci 22,25% scritta nella riga).
        let casa = VoceCatalogo(id: "protezione-prova", riga: 0, testo: ["prodotto": "Casa di prova", "categoria": "Casa"],
                                valori: ValoriCatalogo(numeri: ["imposta_premio": 0.21]), foglio: .protezione)
        verifica.vero("Catalogo: l'aliquota della riga vince su quella del ramo",
                      MotoreCatalogo.protezione(casa, IngressoCatalogo(importo: 121)).pezzo("imposte")?.quota == 0.21)
        var casaSenza = casa
        casaSenza.valori = ValoriCatalogo()
        verifica.vero("Catalogo: senza aliquota nella riga, casa e RC 22,25% di legge",
                      MotoreCatalogo.protezione(casaSenza, IngressoCatalogo(importo: 100)).pezzo("imposte")?.quota == FiscoCatalogo.impostaCasaRC)
        // RC auto: imposta + SSN.
        let rca = MotoreCatalogo.impostaContenuta(premio: 1230, aliquota: FiscoCatalogo.impostaRCAuto, contributoSSN: FiscoCatalogo.contributoSSNRCAuto)
        verifica("Catalogo: RC auto 12,5% + 10,5% SSN contenuti in 1.230 €", rca.cifra.minimo ?? -1, 230)
    }

    /// GenerAzione Previdente, comparto Gesav: caricamento 4,5%, ISC a 10 anni 2,35%.
    private static func previdenza(_ verifica: VerificaCalcoli, _ c: CatalogoProdotti) {
        guard let gesav = c.cerca("GenerAzione Previdente Gesav", foglio: .previdenza).first else {
            verifica.vero("Catalogo: GenerAzione Previdente Gesav nel catalogo", false)
            return
        }
        verifica("Catalogo: Gesav, caricamento sui versamenti 4,5%", gesav.valori.numero("caricamento_versamenti") ?? -1, 0.045, tolleranza: 1e-6)
        let r = MotoreCatalogo.previdenza(gesav, IngressoCatalogo(importo: 2000, annoInizio: 2026, terzo: .anni(10)))
        verifica("Catalogo: Gesav, ISC a 10 anni 2,35%", r.pezzo("lungo_periodo")?.quota ?? -1, 0.0235, tolleranza: 1e-6)
        verifica("Catalogo: Gesav, caricamento su 2.000 €", r.pezzo("caricamento")?.cifra.minimo ?? -1, 90)
        verifica("Catalogo: Gesav, costo del 1° anno (0 + 0 + 90 + 1.000 × 1,3%)", r.totale.cifra.minimo ?? -1, 103)
        let otto = MotoreCatalogo.previdenza(gesav, IngressoCatalogo(importo: 2000, terzo: .anni(8)))
        verifica.vero("Catalogo: a 8 anni l'ISC più vicino è quello a 10", MotoreCatalogo.iscPiuVicino(gesav, orizzonte: 8)?.anni == 10
                      && otto.pezzo("lungo_periodo")?.quota == gesav.valori.numero("isc_10"))
        verifica.vero("Catalogo: a 3 anni l'ISC più vicino è quello a 2", MotoreCatalogo.iscPiuVicino(gesav, orizzonte: 3)?.anni == 2)
    }

    /// Un dato che manca è «non disponibile», mai zero, e il totale lo dice.
    private static func mancanti(_ verifica: VerificaCalcoli, _ c: CatalogoProdotti) {
        let fondo = VoceCatalogo(id: "previdenza-prova", riga: 0, testo: ["prodotto": "Fondo di prova"],
                                 valori: ValoriCatalogo(numeri: ["spese_adesione_euro": 0, "spese_annue_euro": 20, "costo_gestione": 0.01]),
                                 foglio: .previdenza)
        let r = MotoreCatalogo.previdenza(fondo, IngressoCatalogo(importo: 1000))
        verifica.vero("Catalogo: caricamento che manca = non disponibile, non zero",
                      r.pezzo("caricamento")?.cifra == .nonDisponibile && r.mancano.contains("Caricamento sui versamenti"))
        verifica.vero("Catalogo: il totale con un dato mancante è non disponibile e lo dice",
                      r.totale.cifra == .nonDisponibile && r.totale.passi.contains { $0.contains(MotoreCatalogo.datoMancante) })
        verifica("Catalogo: le parti che ci sono fanno «almeno» (0 + 20 + 500 × 1%)", r.parzialeNoto?.minimo ?? -1, 25)
        verifica.vero("Catalogo: senza anni all'uscita l'ISC è non disponibile", r.pezzo("lungo_periodo")?.cifra == .nonDisponibile)
        verifica.vero("Catalogo: CifraCatalogo, la somma con un dato mancante manca",
                      (CifraCatalogo.valore(10) + .nonDisponibile) == .nonDisponibile && CifraCatalogo.da(3, 3) == .valore(3))
        if let risparmio = c.cerca("GenerAzione Risparmio", foglio: .investimento).first {
            let ri = MotoreCatalogo.investimento(risparmio, IngressoCatalogo(importo: 10_000))
            verifica.vero("Catalogo: GenerAzione Risparmio, costi fissi e penali non nel catalogo: non disponibili",
                          ri.pezzo("costi_fissi")?.cifra == .nonDisponibile && ri.pezzo("penali")?.cifra == .nonDisponibile)
        }
        let senzaNiente = VoceCatalogo(id: "protezione-vuota", riga: 0, testo: ["prodotto": "Animali di prova", "categoria": "Animali"],
                                       foglio: .protezione)
        let rp = MotoreCatalogo.protezione(senzaNiente, IngressoCatalogo(importo: 200))
        verifica.vero("Catalogo: protezione senza dati: imposte, detrazione e durata non disponibili",
                      rp.pezzo("imposte")?.cifra == .nonDisponibile && rp.pezzo("detrazione")?.cifra == .nonDisponibile
                      && rp.totale.cifra == .nonDisponibile)
    }

    private static func ricerca(_ verifica: VerificaCalcoli, _ c: CatalogoProdotti) {
        verifica.vero("Catalogo: ci sono schede di categoria (\(c.schedeCategoria.count))", !c.schedeCategoria.isEmpty)
        verifica.vero("Catalogo: le schede di categoria non sono prodotti selezionabili", c.prodotti().allSatisfy { !$0.schedaCategoria })
        verifica.vero("Catalogo: la ricerca non dà schede di categoria",
                      c.cerca("viaggio").allSatisfy { !$0.schedaCategoria } && c.cerca("").allSatisfy { !$0.schedaCategoria })
        verifica.vero("Catalogo: la guida della categoria Viaggio è la sua scheda",
                      c.guida(categoria: "Viaggio").contains { $0.schedaCategoria && $0.prodotto == "Viaggio" })
        verifica.vero("Catalogo: ricerca senza accenti e maiuscole («generazione investimento»)",
                      c.cerca("generazione INVESTIMENTO").contains { $0.prodotto == "GenerAzione Investimento" })
        verifica.vero("Catalogo: ricerca per compagnia", !c.cerca(compagnia: "Generali").isEmpty
                      && c.cerca(compagnia: "Generali").allSatisfy { CatalogoProdotti.normalizza($0.compagnia).contains("generali") })
        verifica.vero("Catalogo: le compagnie senza «Tutte (categoria)»", !c.compagnie.isEmpty && !c.compagnie.contains { $0.hasPrefix("Tutte") })

        let a = c.abbina(nome: "GenerAzióne INVESTIMÉNTO")
        verifica.vero("Catalogo: abbina trova «GenerAzione Investimento» da maiuscole e accenti diversi (\(a.first?.voce.prodotto ?? "-"))",
                      a.first?.voce.prodotto == "GenerAzione Investimento")
        let b = c.abbina(nome: "Polizza GENERAZIONE investimento di Generali S.p.A.")
        verifica.vero("Catalogo: abbina dal testo di un documento", b.first?.voce.prodotto == "GenerAzione Investimento")
        verifica.vero("Catalogo: abbina non propone schede di categoria", c.abbina(nome: "Viaggio").allSatisfy { !$0.voce.schedaCategoria })
        verifica.vero("Catalogo: abbina su un testo vuoto non propone nulla", c.abbina(nome: "  ").isEmpty)
    }
}
