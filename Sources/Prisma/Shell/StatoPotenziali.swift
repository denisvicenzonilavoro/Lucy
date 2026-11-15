import Foundation

// Ciò che Clienti › Potenziali e Passaparola chiedono allo stato («Luce» giro 12, §9.2.4): aggiungere, modificare,
// spostare ed eliminare un potenziale; l'arrivo in «Cliente» passa dalla scena del nuovo cliente (mai da solo); il primo
// incontro sul primo spazio libero vero dell'Agenda; «Scrivigli» solo con informativa e consenso (decisione 39); la
// richiesta di presentazione preparata in Messaggi (decisione 17). Ogni scrittura è vietata in sola lettura (iPad, copia
// di «Prisma ovunque» di sola lettura, archivio più recente).

extension StatoShell {
    /// Potenziali e Passaparola si guardano soltanto (§9.2.4): sull'iPad e sull'iPhone, che sono una copia (i passaggi di
    /// fase si fanno sul Mac), e con l'archivio in sola lettura.
    var potenzialiInSolaLettura: Bool {
        #if os(iOS)
        return true
        #else
        return solaLettura
        #endif
    }

    /// Migliorie d'uso 47: il prossimo passo di ogni potenziale (id → passo), calcolato una volta per tutti finché non
    /// cambiano i dati dei calcoli (potenziali, clienti, agenda), il giorno o l'ora (il primo incontro è «futuro»).
    /// Migliorie d'uso 48: i potenziali sono neutri per i calcoli (`DatiVivi.potenziali`), quindi la loro impronta va
    /// nella chiave (prima uno spostamento lasciava il passo di prima finché non cambiava un dato dei calcoli).
    func passiPotenziali() -> [String: PassoPotenziale] {
        let potenziali = dati.potenziali
        return ricavato("potenziali-passi|\(DerivatiDati.ora())|\(potenziali.hashValue)") {
            MotorePassaparola.passi(potenziali, clienti: dati.clienti, appuntamenti: dati.appuntamenti, oggi: Date())
        }
    }

    /// Migliorie d'uso 48 (punto 6): albero, ambasciatori, quota, nuovi per anno e i patrimoni netti, calcolati una volta
    /// finché non cambiano i dati dei calcoli (clienti, potenziali, posizioni) o il giorno: il body del passaparola non
    /// rifà più i motori su tutto l'archivio a ogni ridisegno.
    /// I potenziali non entrano nei dati dei calcoli (`DatiVivi.potenziali` è neutro): la loro impronta va nella chiave,
    /// e leggerli qui iscrive la vista ai loro cambi.
    func datiPassaparola() -> DatiPassaparola {
        let potenziali = dati.potenziali
        return ricavato("passaparola|\(potenziali.hashValue)") {
            let oggi = Date()
            let clienti = dati.clienti
            let posizioni = dati.posizioni
            let netti = MotorePassaparola.patrimoni(posizioni)
            return DatiPassaparola(
                albero: MotorePassaparola.albero(clienti: clienti, potenziali: potenziali, posizioni: posizioni, netti: netti),
                ambasciatori: MotorePassaparola.ambasciatori(clienti: clienti, potenziali: potenziali, posizioni: posizioni, netti: netti),
                quota: MotorePassaparola.quotaPassaparola(clienti: clienti, posizioni: posizioni, oggi: oggi, netti: netti),
                anni: MotorePassaparola.nuoviPerAnno(clienti: clienti, oggi: oggi),
                netti: netti)
        }
    }

    /// Il momento giusto per chiedere (decisione 17), in cache come il resto: le pratiche non entrano nei dati dei calcoli
    /// (`stessiCalcoli`), quindi la chiave porta l'impronta di ciò che il motore ne legge (posizione e data d'apertura).
    /// Vuoto sull'iPad e in sola lettura (si guarda soltanto).
    func momentiPassaparola() -> [MomentoPerChiedere] {
        guard !potenzialiInSolaLettura else { return [] }
        let pratiche = dati.pratiche
        var impronta = Hasher()
        for p in pratiche {
            impronta.combine(p.posizioneId)
            impronta.combine(p.apertaIl)
        }
        return ricavato("passaparola-momenti|\(pratiche.count)|\(impronta.finalize())") {
            var x = datiDeiCalcoli()
            x.pratiche = pratiche
            return MotorePassaparola.momentoGiusto(dati: x, oggi: Date())
        }
    }

    /// Migliorie d'uso 48: il ramo della persona scelta (tutte le persone che ha presentato), in cache per persona.
    func ramoPassaparola(_ clienteId: String) -> RamoPassaparola? {
        let netti = datiPassaparola().netti
        let potenziali = dati.potenziali
        return ricavato("passaparola-ramo|\(clienteId)|\(potenziali.hashValue)") {
            MotorePassaparola.ramo(di: clienteId, clienti: dati.clienti, potenziali: potenziali, netti: netti)
        }
    }

    /// Le tinte degli avatar dei clienti nuovi, a giro.
    private static let tinteNuovi: [TintaAvatar] = [.blu, .rosa, .verde, .viola, .oro]

    /// Un potenziale nuovo (con la storia che comincia da «Da contattare»).
    func aggiungiPotenziale(_ p: PotenzialeCliente) {
        guard !solaLettura, !p.nome.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var q = p
        q.nome = q.nome.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.storia.isEmpty { q.storia = [CambioFase(fase: q.fase, il: MessaggioCliente.adesso)] }
        dati.potenziali.append(q)
        mostraAvviso("\(TestiTraguardi.primoNome(q.nome)) è fra i potenziali clienti")
    }

    /// Salva le modifiche di un potenziale (dal modulo o dal dettaglio).
    func salvaPotenziale(_ p: PotenzialeCliente) {
        guard !solaLettura else { return }
        potenziali.ultimoSpostamento = nil
        if let i = dati.potenziali.firstIndex(where: { $0.id == p.id }) {
            guard dati.potenziali[i] != p else { return }
            dati.potenziali[i] = p
        } else {
            aggiungiPotenziale(p)
        }
    }

    /// Sposta un potenziale in una fase. In «Cliente» non va da solo: si apre il modulo del nuovo cliente.
    /// Ogni spostamento chiude l'annullamento di quello prima (Migliorie d'uso 47).
    func spostaPotenziale(_ id: String, a fase: FasePotenziale) {
        potenziali.ultimoSpostamento = nil
        guard !solaLettura, let i = dati.potenziali.firstIndex(where: { $0.id == id }) else { return }
        if fase == .cliente {
            proponiCliente(id)
            return
        }
        let nuovo = MotorePassaparola.sposta(dati.potenziali[i], a: fase, il: MessaggioCliente.adesso)
        guard nuovo != dati.potenziali[i] else { return }
        dati.potenziali[i] = nuovo
    }

    /// Migliorie d'uso 47: lo spostamento che si può annullare («Passa a…», trascinamento, ⌘→). Si ricorda la copia di
    /// prima (in memoria); non vale per «Cliente» (scena del nuovo cliente) né per «Non interessato» (si ripristina dal
    /// piede).
    func spostaPotenzialeAnnullabile(_ id: String, a fase: FasePotenziale) {
        guard fase != .cliente, fase != .nonInteressato,
              let prima = dati.potenziali.first(where: { $0.id == id }) else {
            spostaPotenziale(id, a: fase)
            return
        }
        spostaPotenziale(id, a: fase)
        if let dopo = dati.potenziali.first(where: { $0.id == id }), dopo.fase == fase, dopo != prima {
            potenziali.ultimoSpostamento = SpostamentoPotenziale(prima: prima, a: fase)
        }
    }

    /// «Annulla»: rimette il potenziale com'era prima dell'ultimo spostamento (storia compresa: nessun cambio in più),
    /// solo se è ancora nella fase dove era arrivato.
    func annullaSpostamentoPotenziale() {
        guard let u = potenziali.ultimoSpostamento else { return }
        potenziali.ultimoSpostamento = nil
        guard !solaLettura, let i = dati.potenziali.firstIndex(where: { $0.id == u.prima.id }),
              dati.potenziali[i].fase == u.a else { return }
        dati.potenziali[i] = u.prima
    }

    /// Un passo avanti (il clic sulla scheda).
    func avanzaPotenziale(_ id: String) {
        guard let p = dati.potenziali.first(where: { $0.id == id }), let s = p.fase.successiva else { return }
        spostaPotenziale(id, a: s)
    }

    /// Un passo indietro.
    func arretraPotenziale(_ id: String) {
        guard let p = dati.potenziali.first(where: { $0.id == id }), p.fase != .cliente, let s = p.fase.precedente else { return }
        spostaPotenziale(id, a: s)
    }

    /// L'arrivo in «Cliente» (§9.2.4): apre la scena del nuovo cliente con il nome già scritto e «presentato da …»;
    /// da lì la carta letta o «Scrivi a mano» creano il dossier, e solo allora la scheda resta in «Cliente». Se la scena
    /// non si apre (presentazione in corso), il modulo del nuovo cliente già compilato (AppClienti lo legge da
    /// `richiestaClienteDaPotenziale`). Già cliente: apre il suo dossier.
    func proponiCliente(_ id: String) {
        guard !potenzialiInSolaLettura, let p = dati.potenziali.first(where: { $0.id == id }) else { return }
        if let cid = p.clienteId, dati.clienti.contains(where: { $0.id == cid }) {
            clienteAttivoId = cid
            schedaCliente = .panoramica
            vistaClienti = .rubrica
            return
        }
        apriNuovoCliente(potenziale: id)
        guard !nuovoClienteAperto, !inModoCliente else { return }
        richiestaClienteDaPotenziale = id
    }

    /// Il cliente nuovo dal potenziale, da precompilare nel modulo.
    func clienteDaPotenziale(_ id: String) -> Cliente? {
        guard let p = dati.potenziali.first(where: { $0.id == id }) else { return nil }
        let tinta = Self.tinteNuovi[dati.clienti.count % Self.tinteNuovi.count]
        return MotorePassaparola.clienteDa(p, tinta: tinta, oggi: Date())
    }

    /// Il dossier è stato creato: il cliente si salva e la scheda resta in «Cliente», collegata, e compare nell'albero.
    func confermaClienteDaPotenziale(potenziale id: String, cliente: Cliente) {
        guard !solaLettura else { return }
        salvaCliente(cliente)
        if let i = dati.potenziali.firstIndex(where: { $0.id == id }) {
            dati.potenziali[i] = MotorePassaparola.diventato(dati.potenziali[i], cliente: cliente.id, il: MessaggioCliente.adesso)
        }
        richiestaClienteDaPotenziale = nil
        mostraAvviso(TestiPassaparola.benvenuto(cliente.nome))
    }

    /// Il modulo annullato: il potenziale resta (o torna) in «Proposta».
    func annullaClienteDaPotenziale(_ id: String) {
        richiestaClienteDaPotenziale = nil
        guard !solaLettura, let i = dati.potenziali.firstIndex(where: { $0.id == id }),
              dati.potenziali[i].fase != .cliente, dati.potenziali[i].fase != .proposta else { return }
        dati.potenziali[i] = MotorePassaparola.sposta(dati.potenziali[i], a: .proposta, il: MessaggioCliente.adesso)
    }

    /// Elimina un potenziale (dopo la conferma). I clienti e le campagne non cambiano.
    func eliminaPotenziale(_ id: String) {
        guard !solaLettura, dati.potenziali.contains(where: { $0.id == id }) else { return }
        potenziali.ultimoSpostamento = nil
        dati.potenziali.removeAll { $0.id == id }
    }

    /// «Fissa il primo incontro»: un appuntamento «Primo incontro» di mezz'ora sul primo spazio libero vero dell'Agenda.
    /// Tocca solo l'agenda.
    @discardableResult
    func fissaPrimoIncontro(_ id: String) -> Appuntamento? {
        guard !solaLettura, let p = dati.potenziali.first(where: { $0.id == id }) else { return nil }
        let domani = Calendar.current.date(byAdding: .day, value: MotorePianificazione.preavvisoGiorni,
                                           to: Calendar.current.startOfDay(for: Date())) ?? Date()
        guard let s = MotorePianificazione.primoSpazio(durata: 30, da: domani, appuntamenti: dati.appuntamenti,
                                                        orari: dati.impostazioni.orari) else {
            mostraAvviso(TestiPassaparola.agendaPiena)
            return nil
        }
        let a = Appuntamento(id: "event-\(UUID().uuidString.prefix(8).lowercased())", clienteId: "",
                             titolo: TestiPassaparola.titoloPrimoIncontro(p.nome), inizio: s.inizio, durataMinuti: 30, luogo: "", note: "",
                             stato: .pianificato, tipo: .primoIncontro)
        dati.appuntamenti.append(a)
        mostraAvviso(TestiPassaparola.primoIncontroFissato + " · " + Formati.giornoBreve.string(from: a.inizio)
                     + " alle " + Formati.ora.string(from: a.inizio))
        return a
    }

    /// «Scrivigli»: solo con l'informativa data e il consenso al contatto. Apre Mail o Messaggi con il solo saluto
    /// (un cliente temporaneo, mai salvato): Prisma non spedisce.
    @MainActor
    func scriviAPotenziale(_ id: String, canale: CanaleMessaggio) {
        guard let p = dati.potenziali.first(where: { $0.id == id }) else { return }
        guard p.contattabile else {
            mostraAvviso(TestiPassaparola.scrivigliNonPronto)
            return
        }
        let temporaneo = Cliente(id: "potenziale-\(p.id)", nome: p.nome, iniziali: Cliente.iniziali(di: p.nome), tinta: .blu,
                                 tema: "", email: p.email, telefono: p.telefono, preferito: false, nota: "", creatoIl: Date())
        let firma = firmaMessaggio(nil, tono: .cordiale)
        let testo = ModelliMessaggi.saluto(temporaneo, tono: .cordiale) + "\n\n" + ModelliMessaggi.chiusura(tono: .cordiale, firma: firma)
            .trimmingCharacters(in: .newlines)
        let esito = AperturaMessaggi.apri(testo: testo, oggetto: canale == .mail ? "Piacere di conoscerti" : nil, canale: canale,
                                          cliente: temporaneo)
        mostraAvviso(esito.messaggio)
    }

    /// «Prepara la richiesta»: apre Messaggi sull'occasione della richiesta di presentazione (commerciale). La spunta
    /// «✓ Messaggio pronto» compare solo quando il messaggio esiste (`richiestaPreparata`).
    func preparaRichiestaPresentazione(_ m: MomentoPerChiedere) {
        guard let c = dati.clienti.first(where: { $0.id == m.clienteId }) else { return }
        let o = MotorePassaparola.occasioneRichiesta(m, cliente: c, posizioni: dati.posizioni)
        potenziali.occasioniRichieste[m.id] = o.id
        vistaMessaggi = .messaggi
        preparaMessaggio(occasione: o)
    }

    /// Migliorie d'uso 48: «Ringrazia …». La bozza del grazie (modello fisso, tono cordiale, nessun nome delle persone
    /// presentate, nessuna cifra) entra nel dossier del cliente e la si trova in Messaggi; il passaparola resta aperto e
    /// lo dice l'avviso. Prisma non spedisce. Non fa nulla in sola lettura o in modalità cliente; un secondo tocco nello
    /// stesso giorno non crea un'altra bozza.
    func preparaRingraziamento(clienteId: String) {
        guard !potenzialiInSolaLettura, !inModoCliente,
              let c = dati.clienti.first(where: { $0.id == clienteId }) else { return }
        guard !ringraziamentoPreparato(clienteId: clienteId) else {
            let giorno = Calendar.current.startOfDay(for: Date())
            let gia = dati.messaggi.last { m in
                m.clienteId == clienteId && m.origine.tipo == .ringraziamentoPresentazione && m.creatoIl >= giorno
            }
            mostraAvviso(TestiPassaparola.ringraziamentoPronto(c.nome), azione: azioneApriGrazie(gia))
            return
        }
        let o = MotorePassaparola.occasioneRingraziamento(cliente: c, posizioni: dati.posizioni, oggi: Date())
        let tono = TonoMessaggio.cordiale
        // Messaggi con un cellulare, altrimenti Mail (come le bozze di «Il mercato per i tuoi clienti»)
        let canale: CanaleMessaggio = c.telefono.filter(\.isNumber).count >= 6 ? .messaggi : .mail
        let t = ModelliMessaggi.testo(o, tono: tono, canale: canale, cliente: c, firma: firmaMessaggio(o.canale, tono: tono))
        let bozza = MessaggioCliente(clienteId: c.id, occasioneId: o.id, origine: o.origine, canaleLavoro: o.canale, tono: tono,
                                     canale: canale, oggetto: canale == .mail ? t.oggetto : nil, testo: t.completo, cifre: o.cifre,
                                     autore: .modelloFisso, modello: nil, creatoIl: MessaggioCliente.adesso)
        dati.messaggi = dati.messaggi + [bozza]
        mostraAvviso(TestiPassaparola.ringraziamentoPronto(c.nome), azione: azioneApriGrazie(bozza))
    }

    /// Rifinitura 48 (solo Mac): «Apri in Messaggi» nell'avviso del grazie porta Messaggi sulla bozza. nil senza bozza
    /// (e su iPhone e iPad, dove l'avviso resta com'era).
    private func azioneApriGrazie(_ bozza: MessaggioCliente?) -> AzioneAvviso? {
        #if os(macOS)
        guard let bozza else { return nil }
        let clienteId = bozza.clienteId, occasioneId = bozza.occasioneId, messaggioId = bozza.id
        return AzioneAvviso(titolo: TestiPassaparola.apriGrazieInMessaggi) { [weak self] in
            self?.preparaMessaggio(clienteId: clienteId, occasioneId: occasioneId, messaggioId: messaggioId)
        }
        #else
        return nil
        #endif
    }

    /// Il grazie di oggi esiste già (bozza, aperto o salvato): il pulsante diventa «✓ Messaggio pronto».
    func ringraziamentoPreparato(clienteId: String) -> Bool {
        let giorno = Calendar.current.startOfDay(for: Date())
        return ricavato("passaparola-grazie|\(clienteId)") {
            dati.messaggi.contains { m in
                m.clienteId == clienteId && m.origine.tipo == .ringraziamentoPresentazione && m.creatoIl >= giorno
            }
        }
    }

    /// Il messaggio della richiesta esiste (preparato, aperto o salvato) da quando il momento è nato.
    func richiestaPreparata(_ m: MomentoPerChiedere) -> Bool {
        let id = potenziali.occasioniRichieste[m.id]
            ?? OccasioneMessaggio.id(tipo: .richiestaPresentazione, clienteId: m.clienteId, riferimento: m.riferimento)
        return dati.messaggi.contains { $0.occasioneId == id && $0.creatoIl >= Calendar.current.startOfDay(for: m.data) }
    }
}

/// Ciò che la vista Passaparola mostra, calcolato una volta (Migliorie d'uso 48, punto 6).
struct DatiPassaparola {
    let albero: AlberoPassaparola
    let ambasciatori: [Ambasciatore]
    let quota: QuotaPassaparola?
    let anni: [(anno: Int, dalPassaparola: Int, totali: Int)]
    /// I patrimoni netti per cliente (per il ramo della persona scelta).
    let netti: [String: Double]
}
