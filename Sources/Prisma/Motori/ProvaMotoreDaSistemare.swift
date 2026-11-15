import Foundation

/// Migliorie d'uso 31 «Si vede cosa resta da sistemare»: il motore di «Da sistemare» (ordine di gravità, etichetta
/// della colonna per pagina, «A posto» solo per ciò che è attivo, fatture solo con parcelle o clienti indipendenti,
/// Vera solo dopo la prima verifica, «protetta da password» solo se lo è). Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaMotoreDaSistemare {
    static func esegui(_ verifica: VerificaCalcoli) {
        let ids: (EsitoDaSistemare) -> [String] = { $0.daSistemare.map(\.id) }
        let idsOk: (EsitoDaSistemare) -> [String] = { $0.aPosto.map(\.id) }

        // Il caso del template: backup mai fatto, promemoria spenti, dati per le fatture incompleti, Vera pronta
        var t = FattiDaSistemare()
        t.veraVerificata = true
        t.veraPronta = true
        t.fattureServono = true
        t.fattureMancanti = 9
        let template = MotoreDaSistemare.calcola(t)
        verifica.vero("Da sistemare: il caso del template ha tre cose in ordine",
                      ids(template) == ["backup-mai", "promemoria-spenti", "fatture-mancanti"])
        verifica.vero("Da sistemare: «Vera è pronta» in «A posto», niente backup né promemoria",
                      idsOk(template) == ["vera-pronta"])
        verifica.vero("Da sistemare: etichette della colonna per pagina",
                      template.etichetta(per: .archivio)?.etichettaColonna == "mai fatto"
                      && template.etichetta(per: .promemoria)?.etichettaColonna == "spenti"
                      && template.etichetta(per: .studio)?.etichettaColonna == "da completare"
                      && template.etichetta(per: .vera) == nil && template.etichetta(per: .aspetto) == nil)
        verifica.vero("Da sistemare: «Sistema» dei dati per le fatture porta alla loro riga",
                      template.etichetta(per: .studio)?.ancora == TestiParcelle.ancoraImpostazioni)
        verifica.vero("Da sistemare: «Tre cose, poi Prisma è a posto.»",
                      TestiDaSistemare.conteggio(template.conteggio) == "Tre cose, poi Prisma è a posto.")
        verifica.vero("Da sistemare: «ne mancano 9», senza un totale inventato",
                      template.daSistemare.last?.spiegazione == "Servono per il file della fattura elettronica: ne mancano 9.")

        // Tutto a posto
        var ok = FattiDaSistemare()
        ok.backupUltimo = Date()
        ok.veraVerificata = true
        ok.veraPronta = true
        ok.promemoriaAccesi = true
        ok.fattureServono = true
        let tutto = MotoreDaSistemare.calcola(ok)
        verifica.vero("Da sistemare: a zero niente da sistemare", tutto.conteggio == 0)
        verifica.vero("Da sistemare: a zero «Non c’è niente da sistemare.»", TestiDaSistemare.conteggio(0) == TestiDaSistemare.niente)
        verifica.vero("Da sistemare: «A posto» con backup, Vera, promemoria e fatture",
                      Set(idsOk(tutto)) == ["backup-fatto", "vera-pronta", "promemoria-accesi", "fatture-complete"])
        verifica.vero("Da sistemare: il backup non protetto non si dice protetto",
                      tutto.aPosto.first { $0.id == "backup-fatto" }?.spiegazione.contains("password") == false)
        var protetto = ok
        protetto.backupProtetto = true
        verifica.vero("Da sistemare: il backup protetto lo dice",
                      MotoreDaSistemare.calcola(protetto).aPosto.first { $0.id == "backup-fatto" }?.spiegazione
                      == "L’ultima copia è di oggi, protetta da password.")

        // Le fatture contano solo con parcelle o clienti indipendenti
        var senzaFatture = t
        senzaFatture.fattureServono = false
        let sf = MotoreDaSistemare.calcola(senzaFatture)
        verifica.vero("Da sistemare: senza parcelle né clienti indipendenti le fatture non contano",
                      !ids(sf).contains("fatture-mancanti") && !idsOk(sf).contains("fatture-complete"))

        // Vera: solo dopo la prima verifica
        var nonVerificata = FattiDaSistemare()
        nonVerificata.veraMotivo = StatoShell.veraNonVerificata
        verifica.vero("Da sistemare: Vera non ancora verificata non conta",
                      !ids(MotoreDaSistemare.calcola(nonVerificata)).contains("vera-non-pronta"))
        var nonPronta = nonVerificata
        nonPronta.veraVerificata = true
        nonPronta.veraMotivo = "Ollama non è aperto."
        let np = MotoreDaSistemare.calcola(nonPronta)
        verifica.vero("Da sistemare: Vera non pronta dopo la verifica, con il motivo",
                      np.etichetta(per: .vera)?.etichettaColonna == "non pronta"
                      && np.etichetta(per: .vera)?.spiegazione == "Ollama non è aperto.")

        // Ordine di gravità e una sola voce per il backup
        var grave = FattiDaSistemare()
        grave.solaLettura = true
        grave.copieNonLeggibili = 2
        grave.backupErrore = "Disco pieno"
        grave.backupInRitardo = true
        grave.backupStessoMac = true
        grave.promemoriaAccesi = true
        grave.promemoriaNegati = true
        let g = MotoreDaSistemare.calcola(grave)
        verifica.vero("Da sistemare: ordine di gravità",
                      ids(g) == ["sola-lettura", "copie-non-leggibili", "backup-non-riuscito", "backup-stesso-mac", "promemoria-negati"])
        verifica.vero("Da sistemare: la colonna prende la voce più grave della pagina",
                      g.etichetta(per: .archivio)?.etichettaColonna == "sola lettura" && g.etichetta(per: .archivio)?.tono == .errore)
        var ritardo = FattiDaSistemare()
        ritardo.backupInRitardo = true
        verifica.vero("Da sistemare: in ritardo senza alcun backup vale «Nessun backup ancora»",
                      ids(MotoreDaSistemare.calcola(ritardo)).filter { $0.hasPrefix("backup") } == ["backup-mai"])
        ritardo.backupUltimo = Date().addingTimeInterval(-10 * 86_400)
        verifica.vero("Da sistemare: con un backup vecchio vale «in ritardo»",
                      ids(MotoreDaSistemare.calcola(ritardo)).filter { $0.hasPrefix("backup") } == ["backup-ritardo"])

        // Prisma ovunque e Mercato: solo accesi (come i pallini di prima)
        var spenti = FattiDaSistemare()
        spenti.ovunqueProblema = "iCloud Drive non è raggiungibile."
        spenti.ovunqueConflitti = 3
        spenti.mercatoErrore = true
        let sp = MotoreDaSistemare.calcola(spenti)
        verifica.vero("Da sistemare: «Prisma ovunque» e Mercato spenti non contano",
                      sp.etichetta(per: .ovunque) == nil && sp.etichetta(per: .mercato) == nil
                      && !idsOk(sp).contains("ovunque-allineati"))
        var accesi = spenti
        accesi.ovunqueAcceso = true
        accesi.mercatoAcceso = true
        let ac = MotoreDaSistemare.calcola(accesi)
        verifica.vero("Da sistemare: «Prisma ovunque» con un problema è un errore, Mercato non aggiornato",
                      ac.etichetta(per: .ovunque)?.tono == .errore && ac.etichetta(per: .mercato)?.etichettaColonna == "non aggiornato")
        accesi.ovunqueProblema = nil
        verifica.vero("Da sistemare: le modifiche da decidere di «Prisma ovunque»",
                      MotoreDaSistemare.calcola(accesi).etichetta(per: .ovunque)?.titolo == "Ci sono 3 modifiche da decidere")
        accesi.ovunqueConflitti = 0
        verifica.vero("Da sistemare: «iPhone e iPad allineati» solo acceso e senza problemi",
                      idsOk(MotoreDaSistemare.calcola(accesi)).contains("ovunque-allineati"))

        // Ogni voce ha la sua etichetta e nessun id doppio
        let tutte = g.daSistemare + ac.daSistemare + template.daSistemare + np.daSistemare
        verifica.vero("Da sistemare: ogni voce da sistemare ha l'etichetta della colonna",
                      tutte.allSatisfy { !$0.etichettaColonna.isEmpty && !$0.titolo.isEmpty && !$0.spiegazione.isEmpty })
        verifica.vero("Da sistemare: nessuna voce doppia", Set(ids(g)).count == ids(g).count)
    }
}
