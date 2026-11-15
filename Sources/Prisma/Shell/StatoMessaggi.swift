import Foundation

// Ciò che Messaggi chiede allo stato (fondamenta del giro 3 di Orizzonte): le occasioni di oggi e della settimana
// (MotoreOccasioniMessaggi, tenute da parte in DerivatiDati finché non cambiano i dati dei calcoli, messaggi compresi,
// o il giorno), i messaggi di un cliente per il dossier, la firma, la scrittura con Vera e il salvataggio nel dossier.
// Prisma non spedisce mai: `apriMessaggio` apre Mail o Messaggi già compilati e segna il messaggio come aperto.

extension StatoShell {
    /// Le occasioni dei messaggi dei clienti visibili (in modalità cliente solo le sue). Per oggi vengono dalla cache
    /// (DerivatiDati); per un altro giorno si calcolano.
    /// Migliorie d'uso 25: con `cliente` (Messaggi sul Mac segue il cliente della barra) solo le occasioni di quel cliente,
    /// filtrate dal motore prima del limite per gruppo, tenute con `ricavato` per cliente; la modalità cliente passa dalla
    /// stessa via (prima filtrava dopo il limite e perdeva le occasioni del cliente fuori dalle prime 8 di tutti).
    func occasioniMessaggi(oggi: Date = Date(), cliente: String? = nil) -> OccasioniMessaggi {
        #if os(macOS)
        let solo = modoCliente ?? cliente
        let calcola = { () -> OccasioniMessaggi in
            MotoreOccasioniMessaggi.calcola(dati: self.datiDeiCalcoli(), oggi: oggi, soloCliente: solo)
        }
        #else
        // iPhone e iPad come prima: tutto il portafoglio, poi in modalità cliente solo le sue (dopo il limite per gruppo)
        let calcola = { () -> OccasioniMessaggi in
            let tutte = MotoreOccasioniMessaggi.calcola(dati: self.datiDeiCalcoli(), oggi: oggi)
            return self.modoCliente.map { tutte.soloCliente($0) } ?? tutte
        }
        #endif
        guard Calendar.current.isDateInToday(oggi) else { return calcola() }
        if modoCliente == nil, let c = cliente {
            return ricavato("messaggi-occasioni|\(c)") { calcola() }
        }
        let d = derivatiValidi()
        if let o = d.occasioniMessaggi { return o }
        let v = calcola()
        d.occasioniMessaggi = v
        return v
    }

    /// Migliorie d'uso 25 (Mac): «Sì, spedito». Il consulente dice che il messaggio aperto in Mail o in Messaggi è
    /// partito: si segna l'ora (solo per un messaggio aperto, mai in sola lettura). Prisma non lo indovina e non legge
    /// Mail né Messaggi. Restituisce se l'ha segnato.
    @discardableResult
    func segnaSpedito(messaggioId: String) -> Bool {
        guard !solaLettura, let i = dati.messaggi.firstIndex(where: { $0.id == messaggioId }) else { return false }
        let s = dati.messaggi[i].stato
        guard s == .apertoInMail || s == .apertoInMessaggi else { return false }
        dati.messaggi[i].speditoIl = MessaggioCliente.adesso
        return true
    }

    /// «Non è partito»: toglie il segno; il messaggio resta aperto nel dossier e l'occasione coperta.
    @discardableResult
    func togliSpedito(messaggioId: String) -> Bool {
        guard !solaLettura, let i = dati.messaggi.firstIndex(where: { $0.id == messaggioId }),
              dati.messaggi[i].speditoIl != nil else { return false }
        dati.messaggi[i].speditoIl = nil
        return true
    }

    /// I messaggi preparati per un cliente, dal più recente (il dossier li mostra con la data).
    func messaggiCliente(_ id: String) -> [MessaggioCliente] {
        dati.messaggi.filter { $0.clienteId == id }.sorted(by: MessaggioCliente.ordina)
    }

    /// La firma per il canale di lavoro e il tono, dai dati del consulente (nil se Prisma non la conosce).
    func firmaMessaggio(_ canale: Canale?, tono: TonoMessaggio) -> String? {
        ModelliMessaggi.firma(canale, tono: tono, impostazioni: dati.impostazioni)
    }

    /// Il testo di un messaggio: Qwen se è pronto (in streaming su `aggiorna`, dal thread del modello), altrimenti o se
    /// il testo non passa la verifica delle cifre il modello fisso di Prisma con l'avviso. Sul thread principale: legge
    /// `dati` e `disponibilitaLocale` senza gare con il salvataggio; la scrittura di Qwen gira fuori (MessaggiVera.scrivi).
    @MainActor
    func scriviMessaggio(_ o: OccasioneMessaggio, tono: TonoMessaggio, canale: CanaleMessaggio,
                         aggiorna: ((String) -> Void)? = nil) async -> TestoScrittoMessaggio? {
        // «Scrive come te» (fase 4 di Vera, funzione 15): senza regole di stile è identico a prima (MessaggiVera.scrivi con
        // la firma di sempre, CollegaStileShell.swift)
        return await scriviMessaggioInStile(o, tono: tono, canale: canale, aggiorna: aggiorna)
    }

    /// Salva nel dossier il messaggio di un'occasione (o aggiorna quello con lo stesso id). Restituisce il messaggio
    /// salvato; nil in sola lettura o se il cliente non c'è più.
    @discardableResult
    func salvaMessaggio(_ o: OccasioneMessaggio, tono: TonoMessaggio, canale: CanaleMessaggio, scritto: TestoScrittoMessaggio,
                        stato: StatoMessaggio = .salvato, id: String? = nil) -> MessaggioCliente? {
        guard !solaLettura, dati.clienti.contains(where: { $0.id == o.clienteId }) else { return nil }
        var m = MessaggioCliente(clienteId: o.clienteId, occasioneId: o.id, origine: o.origine, canaleLavoro: o.canale, tono: tono,
                                 canale: canale, oggetto: canale == .mail ? scritto.oggetto : nil, testo: scritto.testo,
                                 cifre: o.cifre, autore: scritto.autore, modello: scritto.modello)
        m.stato = stato
        if stato == .apertoInMail || stato == .apertoInMessaggi { m.apertoIl = MessaggioCliente.adesso }
        if let id, let i = dati.messaggi.firstIndex(where: { $0.id == id }) {
            m.id = id
            m.creatoIl = dati.messaggi[i].creatoIl
            dati.messaggi[i] = m
        } else {
            dati.messaggi.append(m)
        }
        return m
    }

    /// Apre il messaggio già compilato in Mail o in Messaggi (mai un invio) e, se si è aperto, lo segna nel dossier.
    @MainActor
    @discardableResult
    func apriMessaggio(_ o: OccasioneMessaggio, tono: TonoMessaggio, canale: CanaleMessaggio, scritto: TestoScrittoMessaggio,
                       id: String? = nil) -> EsitoApertura {
        guard let c = dati.clienti.first(where: { $0.id == o.clienteId }) else {
            return .nonRiuscito("Il cliente non è più in Prisma")
        }
        // Con i file dell'occasione (il PDF della fattura da Studio): CollegamentiMessaggi.swift
        let esito = AperturaMessaggi.apri(testo: scritto.testo, oggetto: canale == .mail ? scritto.oggetto : nil, canale: canale,
                                          cliente: c, allegati: allegatiMessaggi[o.id] ?? [])
        if esito.aperto {
            salvaMessaggio(o, tono: tono, canale: canale, scritto: scritto,
                           stato: canale == .mail ? .apertoInMail : .apertoInMessaggi, id: id)
            // «Le promesse» (fase 3 di Vera): gli impegni scritti nel messaggio aperto entrano nell'elenco
            raccogliPromesse(cliente: o.clienteId)
            // «Scrive come te» (funzione 15 di Vera): il messaggio uscito entra nell'apprendimento dello stile
            aggiornaStileVera()
            // «Luce» giro 15: l'aggiornamento del sinistro segna il giorno nel sinistro e la traccia nel dossier
            if o.tipo == .sinistro { segnaAggiornamentoSinistro(o, canale: canale) }
        }
        return esito
    }
}
