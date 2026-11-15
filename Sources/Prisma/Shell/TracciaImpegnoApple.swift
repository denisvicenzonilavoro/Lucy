import SwiftUI

// La traccia dell'impegno nel tema Apple (Design/template-apple-specifica.md §4.4.2, riferimenti analisi-agenda/
// G08-G14): nasce dall'impegno toccato nella giornata (PresentatoreDettaglio, 860×500).
//
//   ◯  REVISIONE PERIODICA · MARTEDÌ 3 NOVEMBRE                         [Alleanza]   ✕
//      Il punto sul progetto casa
//      Giulia Rossi · 09:30 – 10:15 · In studio
//   PUNTI DA TOCCARE                                   ┌ Patrimonio netto ┐
//   ○ Temi scelti: Previdenza, Risparmio               │ 184.300 €        │
//   ○ Dal riesame del 12 ottobre: …                    ├ Dati per l'analisi┤
//   ○ …                                                │ 92%  ▬▬▬▬▬▬▬▬▬   │
//   [Preparami l'incontro] [Apri il dossier] [Mostra al cliente]          Tutti i dettagli
//
// - I punti vengono dalla preparazione che Prisma ha già: i temi dell'incontro preparato (AppIncontri), la
//   proposta o la posizione di cui si parla, le priorità del cliente (MotoreBisogni), cosa è cambiato dal riesame
//   precedente (memoria del riesame) e l'ordine del giorno del riesame (MotoreRiesame), le priorità alte prima.
//   Nessuna cifra scritta a mano (§4.9 n. 8): patrimonio e completezza vengono dai motori.
// - «Preparami l'incontro»: i punti si spuntano uno alla volta (ListaTiPreparo); alla fine il fascicolo
//   dell'appuntamento (preparaFascicolo(per:)) si apre in Prospetti, già composto.
// - «Apri il dossier» apre il cliente dell'impegno; «Mostra al cliente» presenta il fascicolo dell'impegno,
//   di quel cliente (§4.9 n. 10), nella vista pulita sul Mac (su iPhone e iPad «Presenta al cliente»); «Tutti i dettagli» porta al dettaglio di sempre
//   (modifica, concluso, esito della proposta, attività collegate) nella vista Giorno.
// - Sul Mac (Migliorie d'uso 19) dopo l'ora o già chiuso la scheda chiede com'è andato: «Incontro concluso», «Com'è
//   andata?», «Punti toccati», «Il verbale», «Cosa succede adesso», «Scrivi il verbale» e «Altro ⌄»
//   (ImpegnoConcluso.swift).

extension StatoShell {
    /// I punti da toccare nell'incontro, dalla preparazione esistente (al massimo `Traccia.massimoPunti`).
    func puntiDaToccare(_ e: Appuntamento) -> [String] {
        var punti: [String] = []
        // I temi scelti nella preparazione dell'incontro, se l'incontro è già stato preparato
        if let i = dati.incontri.first(where: { $0.appuntamentoId == e.id }), !i.temi.isEmpty,
           i.temi.count < AreaAnalisi.allCases.count {
            punti.append("Temi scelti: " + i.temi.map(\.nome).joined(separator: ", "))
        }
        // La proposta o la posizione di cui si parla
        if let pid = e.posizioneId, let p = posizioni.first(where: { $0.id == pid }) {
            punti.append(p.stato == .proposta ? "La proposta: \(p.nome)" : "La posizione: \(p.nome)")
        }
        guard cliente(e.clienteId) != nil else { return Self.puntiOppureNote(punti, e) }
        // Le priorità del cliente
        let profilo = cliente(e.clienteId)?.bisogni ?? ProfiloBisogni()
        let priorita = Array(MotoreBisogni.priorita(bisogniRilevati(e.clienteId), profilo: profilo).prefix(3))
        if !priorita.isEmpty {
            punti.append("Priorità del cliente: " + priorita.map(\.nome).joined(separator: ", "))
        }
        // Cosa è cambiato dal riesame precedente (senza fotografie la memoria non si calcola)
        if dati.fotografie.contains(where: { $0.clienteId == e.clienteId }),
           let memoria = memoriaRiesame(e.clienteId), let precedente = memoria.precedente {
            let data = Formati.giornoMese.string(from: precedente.data)
            for v in memoria.variazioni.prefix(2) {
                punti.append("Dal riesame del \(data): \(v.testo)")
            }
        }
        // L'ordine del giorno del riesame: prima le priorità alte
        if let r = riesameCliente(e.clienteId) {
            let alte = r.punti.filter { $0.priorita == .alta }
            let altre = r.punti.filter { $0.priorita != .alta }
            for p in alte + altre where !punti.contains(p.titolo) {
                punti.append(p.titolo)
            }
        }
        return Self.puntiOppureNote(punti, e)
    }

    /// I punti trovati (al massimo quelli che stanno nella traccia) oppure, se non ce ne sono, le note dell'impegno.
    private static func puntiOppureNote(_ punti: [String], _ e: Appuntamento) -> [String] {
        let massimo = Tema.Apple.Agenda.Traccia.massimoPunti
        if !punti.isEmpty { return Array(punti.prefix(massimo)) }
        let note = e.note.trimmingCharacters(in: .whitespacesAndNewlines)
        return note.isEmpty ? ["Ascoltare il cliente: cosa è cambiato e cosa vuole fare"] : [note]
    }

    /// «Mostra al cliente»: il fascicolo dell'impegno, con i report adatti al tipo d'incontro, a tutto schermo
    /// in modalità cliente (le annotazioni vanno all'appuntamento).
    func presentaImpegno(_ e: Appuntamento) {
        clienteAttivoId = e.clienteId
        let posizione = e.posizioneId.flatMap { id in posizioni.first { $0.id == id } }
        sceltaFascicolo = TipoProspetto.perIncontro(e, posizione: posizione)
        fascicoloAppuntamento = e.id
        prospetto = .fascicolo
        guard let d = documentoFascicolo() else {
            mostraAvviso("Il fascicolo dell'incontro non ha ancora report da mostrare")
            return
        }
        #if os(macOS)
        // Rifinitura 18-24 (migliorie d'uso 1 e 10): «Mostra al cliente» entra nella vista pulita, poi presenta
        mostraProspetto(d)
        #else
        presenta(d)
        #endif
    }

    /// «Tutti i dettagli»: il dettaglio di sempre dell'appuntamento, nella vista Giorno.
    func mostraDettaglioImpegno(_ e: Appuntamento) {
        giornoAgenda = Calendar.current.startOfDay(for: e.inizio)
        vistaAgenda = .giorno
        occasioneSelezionata = nil
        attivitaSelezionata = nil
        appuntamentoSelezionato = e.id
    }
}

/// La traccia di un impegno, dentro il dettaglio aperto (già a misura piena).
struct TracciaImpegnoApple: View {
    let idDettaglio: String
    @Environment(StatoShell.self) var stato
    @Environment(\.statoDettaglioApple) private var dettaglio
    @Environment(\.modoIstantanea) private var istantanea
    @State private var preparando = false

    private static let prefisso = "impegno-"

    /// Il pulsante che presenta il fascicolo dell'impegno: sul Mac «Mostra al cliente» (migliorie d'uso 10), nella vista
    /// pulita; su iPhone e iPad come prima.
    #if os(macOS)
    static let titoloMostra = Parole.mostraAlCliente
    static let aiutoMostra = "Il fascicolo dell'incontro a tutto schermo, nella vista pulita per il cliente"
    #else
    static let titoloMostra = "Presenta al cliente"
    static let aiutoMostra = "Il fascicolo dell'incontro a tutto schermo, in modalità cliente"
    #endif

    /// L'id del dettaglio nato dall'impegno `eventoId`.
    static func id(per eventoId: String) -> String { prefisso + eventoId }

    private var eventoId: String { String(idDettaglio.dropFirst(Self.prefisso.count)) }

    var body: some View {
        let _ = ContaCorpi.segna()
        if let e = stato.appuntamento(eventoId) {
            corpo(e)
                #if os(macOS)
                .onAppear { preparazioneRichiesta() }
                #endif
        }
    }

    #if os(macOS)
    /// Rifinitura 18-24: aperta da «Preparami l'incontro» del dettaglio di «Giorno», la traccia parte già a spuntare i punti.
    private func preparazioneRichiesta() {
        guard stato.tracciaDaPreparare == eventoId else { return }
        stato.tracciaDaPreparare = nil
        preparando = true
    }
    #endif

    private func corpo(_ e: Appuntamento) -> some View {
        let t = Tema.Apple.Agenda.Traccia.self
        let cliente = stato.cliente(e.clienteId)
        let punti = stato.puntiDaToccare(e)
        let concluso = mostraConcluso(e, cliente: cliente)
        return VStack(alignment: .leading, spacing: 0) {
            testata(e, cliente: cliente, concluso: concluso)
            centro(e, cliente: cliente, punti: punti, concluso: concluso)
                .padding(.top, t.corpoSopra)
                .frame(maxHeight: .infinity, alignment: .top)
            piede(e, cliente: cliente, concluso: concluso)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// Migliorie d'uso 19, solo sul Mac: dopo l'ora o già chiuso (MomentoImpegno, con l'ora ferma delle istantanee)
    /// la scheda chiede com'è andato. Un impegno senza cliente resta com'è (decisione 18-d); l'iPad pure.
    private func mostraConcluso(_ e: Appuntamento, cliente: Cliente?) -> Bool {
        #if os(macOS)
        guard cliente != nil else { return false }
        let adesso = istantanea ? OraIstantanee.data() : Date()
        return MomentoImpegno.di(e, adesso: adesso) != .prima
        #else
        return false
        #endif
    }

    @ViewBuilder private func centro(_ e: Appuntamento, cliente: Cliente?, punti: [String], concluso: Bool) -> some View {
        #if os(macOS)
        if concluso {
            CorpoImpegnoConcluso(evento: e, punti: punti)
        } else {
            centroPrima(e, cliente: cliente, punti: punti)
        }
        #else
        centroPrima(e, cliente: cliente, punti: punti)
        #endif
    }

    /// Prima dell'ora: i punti da toccare e le cifre del cliente.
    private func centroPrima(_ e: Appuntamento, cliente: Cliente?, punti: [String]) -> some View {
        let t = Tema.Apple.Agenda.Traccia.self
        return HStack(alignment: .top, spacing: t.spazioColonne) {
            ScrollView(.vertical, showsIndicators: false) {
                ListaTiPreparo(titolo: TestiAgendaApple.puntiDaToccare, voci: punti, avviata: preparando,
                               poi: { fascicoloPronto(e, cliente: cliente) })
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            if let c = cliente {
                tile(c)
                    .frame(width: t.larghezzaTile)
            }
        }
    }

    // MARK: Testata

    private func testata(_ e: Appuntamento, cliente: Cliente?, concluso: Bool) -> some View {
        let t = Tema.Apple.Agenda.Traccia.self
        let colore = Tema.Apple.Agenda.colore(cliente)
        let margine = max(0, t.margineChiudi - Tema.Apple.Misura.Padding.dettaglio.trailing)
        let canale = stato.canaleAppuntamento(e)
        return HStack(alignment: .center, spacing: t.spazioTestata) {
            avatar(cliente, colore: colore)
            VStack(alignment: .leading, spacing: t.spazioTesti) {
                Text(concluso ? TestiAgendaApple.etichettaConcluso(e.inizio) : etichetta(e))
                    .carattereApple(t.etichetta)
                    .foregroundColor(concluso ? t.coloreConcluso : colore)
                    .lineLimit(1)
                Text(e.titolo)
                    .carattereApple(t.titolo)
                    .foregroundColor(t.coloreTitolo)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(sotto(e, cliente: cliente))
                    .carattereApple(t.sotto)
                    .foregroundColor(t.coloreSotto)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if let canale {
                EtichettaCanaleApple(canale: canale)
            }
        }
        .padding(.trailing, margine)
    }

    @ViewBuilder private func avatar(_ cliente: Cliente?, colore: Color) -> some View {
        let t = Tema.Apple.Agenda.Traccia.self
        if let c = cliente {
            AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: t.avatar)
        } else {
            Image(systemName: "checkmark")
                .carattereApple(t.spuntaSenzaCliente)
                .foregroundColor(t.coloreSpunta)
                .frame(width: t.avatar, height: t.avatar)
                .background { Circle().fill(colore) }
                .accessibilityHidden(true)
        }
    }

    /// «REVISIONE PERIODICA · MARTEDÌ 3 NOVEMBRE» (il maiuscolo lo fa il carattere).
    private func etichetta(_ e: Appuntamento) -> String {
        let base = "\(e.tipo.nome) · \(TestiAgendaApple.titoloGiorno(e.inizio))"
        return e.stato == .concluso ? base + " · concluso" : base
    }

    /// «Giulia Rossi · 09:30 – 10:15 · In studio».
    private func sotto(_ e: Appuntamento, cliente: Cliente?) -> String {
        let quando = TestiAgendaApple.quando(e)
        guard let c = cliente else { return quando }
        return "\(c.nome) · \(quando)"
    }

    // MARK: Tile del cliente

    private func tile(_ c: Cliente) -> some View {
        let t = Tema.Apple.Agenda.Traccia.self
        return VStack(alignment: .leading, spacing: t.spazioTile) {
            CifreClienteTraccia(clienteId: c.id)
            Text(TestiPortafoglioApple.cifreDaiMotori)
                .carattereApple(t.nota)
                .foregroundColor(t.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Piede

    @ViewBuilder private func piede(_ e: Appuntamento, cliente: Cliente?, concluso: Bool) -> some View {
        #if os(macOS)
        if concluso {
            piedeConcluso(e)
        } else {
            piedePrima(e, cliente: cliente)
        }
        #else
        piedePrima(e, cliente: cliente)
        #endif
    }

    #if os(macOS)
    /// Dopo l'ora: un solo pulsante blu, «Scrivi il verbale» (Incontri, momento «Dopo»), poi «Apri il dossier» e
    /// «Altro ⌄». «Tutti i dettagli» non c'è più: «Modifica» porta al dettaglio di sempre con il modulo.
    private func piedeConcluso(_ e: Appuntamento) -> some View {
        let t = Tema.Apple.Agenda.Traccia.self
        return HStack(spacing: t.spazioPulsanti) {
            Button {
                dettaglio?.chiudi(subito: true)
                stato.apriIncontro(per: e, scheda: .passi)
            } label: { Text(TestiAgendaApple.scriviIlVerbale) }
                .buttonStyle(.applePrimarioGrande)
            Button {
                dettaglio?.chiudi(subito: true)
                stato.apriCliente(e.clienteId)
            } label: { Text(TestiAgendaApple.apriIlDossier) }
                .buttonStyle(.appleGrande)
            MenuAltroImpegno(evento: e,
                             modifica: { richiedi(.modifica(e.id), e) },
                             attivita: { richiedi(.attivita(e.id), e) },
                             prima: { dettaglio?.chiudi(subito: true) })
            Spacer(minLength: 0)
        }
    }

    /// «Modifica» e «Attività collegata»: la scheda si chiude, l'Agenda passa al dettaglio di sempre e apre il modulo.
    private func richiedi(_ r: RichiestaModuloImpegno, _ e: Appuntamento) {
        dettaglio?.chiudi(subito: true)
        stato.mostraDettaglioImpegno(e)
        stato.richiestaModuloImpegno = r
    }
    #endif

    private func piedePrima(_ e: Appuntamento, cliente: Cliente?) -> some View {
        let t = Tema.Apple.Agenda.Traccia.self
        return HStack(spacing: t.spazioPulsanti) {
            Button { preparando = true } label: { Text(Parole.preparamiIncontro) }
                .buttonStyle(.applePrimarioGrande)
                .disabled(preparando)
            if cliente != nil {
                Button {
                    dettaglio?.chiudi(subito: true)
                    stato.apriCliente(e.clienteId)
                } label: { Text("Apri il dossier") }
                    .buttonStyle(.appleGrande)
                Button {
                    dettaglio?.chiudi(subito: true)
                    stato.presentaImpegno(e)
                } label: { Text(TracciaImpegnoApple.titoloMostra) }
                    .buttonStyle(.appleGrande)
                    .help(TracciaImpegnoApple.aiutoMostra)
            }
            Spacer(minLength: 0)
            Button {
                dettaglio?.chiudi(subito: true)
                stato.mostraDettaglioImpegno(e)
            } label: { Text("Tutti i dettagli") }
                .buttonStyle(.appleSobrio)
                .help("Modifica, segna concluso, esito della proposta e attività collegate")
        }
    }

    /// I punti sono spuntati: la traccia si chiude e il fascicolo dell'appuntamento si apre in Prospetti.
    private func fascicoloPronto(_ e: Appuntamento, cliente: Cliente?) {
        guard preparando else { return }
        preparando = false
        dettaglio?.chiudi(subito: true)
        stato.preparaFascicolo(per: e)
        stato.mostraAvviso("Fascicolo per \(cliente?.nome ?? e.titolo) pronto in Prospetti")
    }
}

// MARK: - Riquadri condivisi (traccia dell'impegno e Incontri › Prima)

/// Un riquadro della traccia: il nome `.k` e sotto il contenuto (la cifra), su tile. Lo usano la traccia dell'impegno e,
/// con le Migliorie d'uso 20, il momento «Prima» di Incontri.
struct RiquadroTracciaApple<Contenuto: View>: View {
    let nome: String
    @ViewBuilder let contenuto: () -> Contenuto

    var body: some View {
        let t = Tema.Apple.Agenda.Traccia.self
        VStack(alignment: .leading, spacing: t.spazioTesti) {
            Text(nome)
                .carattereApple(t.nomeTile)
                .foregroundColor(t.coloreNomeTile)
                .lineLimit(1)
            contenuto()
        }
        .padding(t.paddingTile)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(t.superficieTile, raggio: t.raggioTile)
    }
}

/// «Patrimonio netto» e «Dati per l'analisi» (con la barra verde da `sogliaVerde`, arancio sotto), dai motori: la
/// traccia dell'impegno e Incontri › Prima mostrano gli stessi riquadri.
struct CifreClienteTraccia: View {
    @Environment(StatoShell.self) var stato
    let clienteId: String

    var body: some View {
        let t = Tema.Apple.Agenda.Traccia.self
        let r = stato.riepilogoPosizioniCliente(clienteId)
        let completezza = stato.completezzaCliente(clienteId)
        RiquadroTracciaApple(nome: "Patrimonio netto") {
            NumeroCheConta(r.patrimonioNetto, formato: .euro, indice: 0)
                .carattereApple(t.cifraTile)
                .foregroundColor(t.coloreCifraTile)
                .lineLimit(1)
                .minimumScaleFactor(t.scalaMinimaCifra)
        }
        if let comp = completezza {
            RiquadroTracciaApple(nome: "Dati per l'analisi") {
                NumeroCheConta(Double(comp.percentuale), formato: .percentuale, indice: 1)
                    .carattereApple(t.cifraTile)
                    .foregroundColor(t.coloreCifraTile)
                    .lineLimit(1)
                BarraPiena(frazione: Double(comp.percentuale) / 100,
                           colore: comp.percentuale >= t.sogliaVerde ? t.barraCompleta : t.barraParziale)
                    .frame(height: Tema.Apple.Grafico.Barra.altezza)
                    .padding(.top, t.barraSopra)
            }
        }
    }
}
