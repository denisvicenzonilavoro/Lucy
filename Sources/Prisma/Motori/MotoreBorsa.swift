import Foundation

// «La borsa»: le cose da portare a un incontro (Migliorie d'uso 51, estratta dal lavoro della notte, «Luce» giro 14).
// Le stesse regole servono alla carta «La borsa di oggi» della notte e alle tappe del giro del Territorio: il fascicolo,
// i moduli da firmare delle proposte aperte con un incontro entro 7 giorni (con un modello compilabile e la mappa
// confermata) e il documento d'identità da rinnovare (scadenza scritta entro i giorni della notte, o già scaduto, senza una
// richiesta già in Messaggi). Puro: niente `Date()`, niente SwiftUI, niente rete; nessun dato nuovo, tutto si ricava.

enum MotoreBorsa {
    /// I giorni entro cui un incontro con una proposta aperta porta i moduli da firmare.
    static let giorniModuli = 7

    /// Un documento d'identità da rinnovare: il cliente, la scadenza scritta e il riferimento stabile della richiesta.
    struct DocumentoDaRinnovare {
        let cliente: Cliente
        let scadenza: Date
        let riferimento: String
    }

    /// Gli incontri del giorno con un cliente vero, confermati (non quelli solo proposti dal Territorio), in ordine d'ora.
    static func incontriDelGiorno(_ appuntamenti: [Appuntamento], clienti: [String: Cliente], giorno g: Date,
                                  cal: Calendar = .current) -> [Appuntamento] {
        let giorno = cal.startOfDay(for: g)
        let domani = cal.date(byAdding: .day, value: 1, to: giorno) ?? giorno
        return appuntamenti.filter {
            $0.stato == .pianificato && $0.tipo != .nonDisponibile && $0.daConfermare != true
                && $0.inizio >= giorno && $0.inizio < domani && clienti[$0.clienteId] != nil
        }.sorted { ($0.inizio, $0.id) < ($1.inizio, $1.id) }
    }

    /// Il titolo del fascicolo di un incontro nei Documenti del cliente.
    static func titoloFascicolo(_ a: Appuntamento) -> String {
        "Report · " + StatoShell.titoloFascicolo(a.inizio)
    }

    /// Il fascicolo dell'incontro è già nei Documenti del cliente (preparato di notte e approvato, o da Prospetti).
    static func fascicoloNeiDocumenti(_ a: Appuntamento, documenti: [Documento]) -> Bool {
        let titolo = titoloFascicolo(a)
        return documenti.contains { $0.clienteId == a.clienteId && $0.titolo == titolo }
    }

    /// I modelli di modulo compatibili con una proposta: compilabili, con la mappa confermata, del canale e del prodotto.
    static func modelliCompatibili(_ p: Posizione, modelli: [ModelloModulo]) -> [ModelloModulo] {
        modelli.filter { m in
            m.compilabile && m.mappaConfermata && (m.canale == nil || m.canale == p.canale)
                && (m.prodottoIds.isEmpty || p.prodottoId.map { m.prodottoIds.contains($0) } == true)
        }
    }

    /// Le proposte aperte (non rifiutate) dei clienti dati che hanno un incontro pianificato entro `giorniModuli`.
    static func proposteConIncontro(dati: DatiPrisma, clienti: [String: Cliente], giorno g: Date,
                                    cal: Calendar = .current) -> [Posizione] {
        let giorno = cal.startOfDay(for: g)
        let entro = cal.date(byAdding: .day, value: giorniModuli, to: giorno) ?? giorno
        return dati.posizioni.filter { $0.stato == .proposta && $0.esito != .rifiutata && clienti[$0.clienteId] != nil }
            .sorted { ($0.clienteId, $0.creataIl) < ($1.clienteId, $1.creataIl) }
            .filter { p in
                dati.appuntamenti.contains { $0.clienteId == p.clienteId && $0.stato == .pianificato && $0.inizio >= giorno && $0.inizio < entro }
            }
    }

    /// Quanti moduli da firmare per cliente (la somma dei modelli compatibili con le sue proposte con un incontro vicino).
    static func moduliPerCliente(dati: DatiPrisma, clienti: [String: Cliente], modelli: [ModelloModulo], giorno: Date,
                                 cal: Calendar = .current) -> [String: Int] {
        guard !modelli.isEmpty else { return [:] }
        var conto: [String: Int] = [:]
        for p in proposteConIncontro(dati: dati, clienti: clienti, giorno: giorno, cal: cal) {
            let n = modelliCompatibili(p, modelli: modelli).count
            if n > 0 { conto[p.clienteId, default: 0] += n }
        }
        return conto
    }

    /// I documenti d'identità da rinnovare: vale solo la scadenza scritta, entro `giorni` (o già scaduta), senza una
    /// richiesta già salvata in Messaggi.
    static func documentiDaRinnovare(dati: DatiPrisma, giorno g: Date, giorni: Int, cal: Calendar = .current) -> [DocumentoDaRinnovare] {
        let giorno = cal.startOfDay(for: g)
        let limite = cal.date(byAdding: .day, value: giorni, to: giorno) ?? giorno
        let esiti = MotoreConformita.calcola(clienti: dati.clienti, posizioni: dati.posizioni, regole: dati.impostazioni.conformita,
                                             oggi: giorno, calendario: cal)
        var elenco: [DocumentoDaRinnovare] = []
        for e in esiti {
            guard let v = e.voci.first(where: { $0.tipo == .documento }), v.stato != .nonRichiesta,
                  let s = v.scadenza, s <= limite else { continue }
            let riferimento = "\(e.cliente.id)·\(NotteDiLavoro.chiave(s, cal: cal))"
            let occasione = OccasioneMessaggio.id(tipo: .documentoIdentita, clienteId: e.cliente.id, riferimento: riferimento)
            // Una richiesta già salvata in Messaggi (anche da una notte prima): non si conta di nuovo
            guard !dati.messaggi.contains(where: { $0.occasioneId == occasione }) else { continue }
            elenco.append(DocumentoDaRinnovare(cliente: e.cliente, scadenza: s, riferimento: riferimento))
        }
        return elenco
    }

    /// Le cose da portare a un incontro, nell'ordine fisso: fascicolo, moduli da firmare, documento da rinnovare.
    static func cose(_ a: Appuntamento, conFascicolo: Set<String>, moduliPerCliente: [String: Int],
                     conDocumento: Set<String>) -> [String] {
        var cose: [String] = []
        if conFascicolo.contains(a.id) { cose.append(TestiNotte.borsaFascicolo) }
        if let n = moduliPerCliente[a.clienteId], n > 0 { cose.append(TestiNotte.borsaModuli(n)) }
        if conDocumento.contains(a.clienteId) { cose.append(TestiNotte.borsaDocumento) }
        return cose
    }

    /// Il giro del Territorio: per ogni appuntamento con un cliente le cose da portare (id appuntamento → cose; senza cose
    /// l'appuntamento non c'è). Il fascicolo conta se è già nei Documenti; moduli e documento con le regole della notte,
    /// dal giorno del giro. `modelli`: i modelli di modulo letti (si filtrano qui).
    static func cose(per appuntamenti: [Appuntamento], dati: DatiPrisma, modelli: [ModelloModulo], oggi: Date,
                     cal: Calendar = .current) -> [String: [String]] {
        let conCliente = appuntamenti.filter { !$0.clienteId.isEmpty }
        guard !conCliente.isEmpty else { return [:] }
        var clienti: [String: Cliente] = [:]
        for c in dati.clienti where clienti[c.id] == nil { clienti[c.id] = c }
        let giorno = cal.startOfDay(for: oggi)
        let conFascicolo = Set(conCliente.filter { fascicoloNeiDocumenti($0, documenti: dati.documenti) }.map(\.id))
        let moduli = moduliPerCliente(dati: dati, clienti: clienti, modelli: modelli, giorno: giorno, cal: cal)
        let conDocumento = Set(documentiDaRinnovare(dati: dati, giorno: giorno, giorni: dati.impostazioni.notte.giorniDocumenti, cal: cal)
            .map(\.cliente.id))
        var esito: [String: [String]] = [:]
        for a in conCliente where clienti[a.clienteId] != nil {
            let c = cose(a, conFascicolo: conFascicolo, moduliPerCliente: moduli, conDocumento: conDocumento)
            if !c.isEmpty { esito[a.id] = c }
        }
        return esito
    }
}
