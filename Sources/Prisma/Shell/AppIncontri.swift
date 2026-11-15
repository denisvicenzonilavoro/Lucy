import SwiftUI

/// App Incontri (.os-app-meetings): il quaderno di lavoro della relazione, con la gerarchia di Design/iphone.html.
/// In alto, grande, il cliente e l'incontro (quando, tipo, canale) con il percorso a passi e l'azione del passo;
/// sotto, le poche cose che servono per decidere (priorità, cifre del dossier, cosa è cambiato) e il lavoro del passo:
/// 1 Preparazione: i temi da affrontare e l'ultima volta.
/// 2 Ascolto: sul Mac e sull'iPad il copilota dell'incontro (CopilotaIncontro.swift: ascolto con il consenso del
///   cliente, schede da confermare, verbale); a un tocco le tre domande aperte, gli appunti e le decisioni.
/// 3 Prossimi passi: dagli appunti nascono bisogni, eventi di vita e attività da confermare;
///   la chiusura aggiorna il profilo dei bisogni, le attività e l'agenda.
struct AppIncontri: View {
    @Environment(StatoShell.self) var stato
    @State var confermaEliminazione = false
    /// «L'ultima volta»: le decisioni intere invece delle prime righe.
    @State private var ultimaVoltaIntera = false
    #if os(macOS)
    /// Migliorie d'uso 20: il momento toccato mentre il copilota ascolta, in attesa di «Fermare l'ascolto?».
    @State private var momentoDaFermare: SchedaIncontro?
    /// «✦ Preparami l'incontro» avviato (l'id dell'incontro: cambiando incontro la lista riparte vuota) e finito.
    @State private var preparandoId: String?
    @State private var preparatoId: String?
    /// «Fissa il prossimo»: il modulo dell'appuntamento con il cliente già scelto.
    @State private var moduloProssimo: Appuntamento?
    #endif

    private var cliente: String { stato.clienteAttivoId }
    /// Gli incontri del cliente (dal più recente): filtrati e ordinati su tutto l'archivio, quindi il body li chiede una
    /// volta sola e li passa alle parti che li usano.
    private var elenco: [Incontro] { stato.incontriCliente(cliente) }

    /// L'incontro aperto: quello scelto, altrimenti il primo da preparare, altrimenti il più recente.
    private func scegliCorrente(_ elenco: [Incontro]) -> Incontro? {
        if let i = stato.incontro(stato.incontroAperto), i.clienteId == cliente { return i }
        return elenco.first { $0.stato == .preparazione } ?? elenco.first
    }

    /// L'incontro aperto adesso, per le azioni (al tocco, non nel body).
    private var corrente: Incontro? { scegliCorrente(elenco) }

    var body: some View {
        let _ = ContaCorpi.segna()
        contenuto
        // Tema Apple: card piatte, scala tipografica, pulsanti e tendine del template; le cascate ripartono
        // cambiando cliente
        .altreAppApple()
        .riavviaCascata(cliente)
        .alert("Eliminare questo incontro?", isPresented: $confermaEliminazione) {
            Button("Annulla", role: .cancel) {}
            Button("Elimina", role: .destructive) {
                // Prima gli appunti in attesa: scritti dopo, rimetterebbero l'incontro nell'archivio
                TestiRinviati.scriviOra()
                if let i = correnteDaEliminare { stato.eliminaIncontro(i.id) }
            }
        } message: {
            Text("Appunti e decisioni verranno tolti dal dossier. Attività e appuntamenti già creati restano. Se serve, potrai recuperarlo da un backup.")
        }
        // L'esito della proposta dopo «Archivia l'incontro»: solo le richieste di Incontri, così Posizioni aperto
        // insieme non lo presenta una seconda volta
        .sheet(item: richiestaEsitoIncontri) { r in
            ModuloEsitoProposta(richiesta: r)
                .environment(stato)
        }
    }

    /// L'incontro da eliminare (solo uno già nell'archivio: una bozza da un appuntamento non ha niente da togliere).
    private var correnteDaEliminare: Incontro? {
        #if os(macOS)
        return correnteMac(stato.elencoIncontri(cliente: clienteElenco)).flatMap { stato.incontro($0.id) }
        #else
        return corrente
        #endif
    }

    @ViewBuilder private var contenuto: some View {
        #if os(macOS)
        // Migliorie d'uso 21: a sinistra l'elenco «Oggi», «Prossimi», «Fatti» del cliente della barra (o di tutti),
        // a destra l'incontro scelto; nel passo «Ascolto» il copilota prende la parte destra
        let gruppi = stato.elencoIncontri(cliente: clienteElenco)
        let aperto = correnteMac(gruppi)
        let elenco = aperto.map { stato.incontriClienteRicavati($0.clienteId) } ?? []
        HStack(alignment: .top, spacing: Tema.Apple.Copilota.Disposizione.gioco) {
            ElencoIncontriApple(gruppi: gruppi, aperto: aperto,
                                nomeCliente: stato.tuttiIClienti ? nil : stato.cliente(cliente)?.nome,
                                spento: stato.copilota.ascolta) { v in scegli(v, gruppi: gruppi) }
                .frame(width: Tema.Apple.Copilota.Elenco.larghezzaElenco)
                .frame(maxHeight: .infinity, alignment: .top)
            // Migliorie d'uso 20: la testata con i tre momenti resta sempre sopra; il copilota è il contenuto di «Durante»
            quadernoMac(elenco: elenco, corrente: aperto)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        // Cambiando cliente nella barra si riparte dal suo primo incontro, sul momento giusto
        .onChange(of: cliente) {
            guard stato.incontroAperto == nil, stato.appuntamentoIncontro == nil,
                  let v = stato.elencoIncontri(cliente: clienteElenco).tutte.first else { return }
            stato.schedaIncontro = RegoleElencoIncontri.momento(v, verbale: verbale(v))
        }
        #else
        let elenco = self.elenco
        let aperto = scegliCorrente(elenco)
        // Nel passo «Ascolto» il copilota dell'incontro (giro 5, CopilotaIncontro.swift) prende tutta la finestra;
        // le tre domande scritte e gli appunti restano a un tocco («Domande e appunti»)
        SceltaAscoltoIncontri(copilota: stato.copilota, ascolto: stato.schedaIncontro == .ascolto,
                              clienteId: cliente, incontro: aperto) {
            quaderno(elenco: elenco, corrente: aperto)
        }
        #endif
    }

    #if os(macOS)
    /// Il cliente dell'elenco: nil con «Tutti i clienti».
    private var clienteElenco: String? { stato.tuttiIClienti ? nil : cliente }

    /// L'incontro mostrato: quello aperto (se è del cliente della barra), altrimenti l'appuntamento scelto senza
    /// incontro (la sua bozza), altrimenti la prima riga dell'elenco.
    private func correnteMac(_ gruppi: GruppiIncontri) -> Incontro? {
        let tutti = stato.tuttiIClienti
        if let i = stato.incontro(stato.incontroAperto), tutti || i.clienteId == cliente { return i }
        if let a = stato.appuntamento(stato.appuntamentoIncontro), tutti || a.clienteId == cliente {
            return incontroDi(a)
        }
        guard let v = gruppi.tutte.first else { return nil }
        if let i = stato.incontro(v.incontroId) { return i }
        if let a = stato.appuntamento(v.appuntamentoId) { return incontroDi(a) }
        return nil
    }

    /// L'incontro di un appuntamento, o la sua bozza (non salvata).
    private func incontroDi(_ a: Appuntamento) -> Incontro {
        if let i = stato.dati.incontri.first(where: { $0.appuntamentoId == a.id }) { return i }
        return stato.bozzaIncontroElenco(per: a)
    }

    /// Il verbale del copilota pronto per la riga (letto al tocco, non nel body).
    private func verbale(_ v: VoceIncontri) -> Bool {
        guard let id = v.incontroId else { return false }
        return stato.dati.sessioniCopilota.contains { $0.incontroId == id && $0.verbale != nil }
    }

    /// Una riga dell'elenco: si apre l'incontro (o la bozza dell'appuntamento, senza scrivere niente) sul momento
    /// giusto. Mentre il copilota ascolta non si cambia incontro; prima di cambiare gli appunti in attesa vanno
    /// nell'incontro giusto e il copilota riparte da capo.
    private func scegli(_ v: VoceIncontri, gruppi: GruppiIncontri) {
        guard !stato.copilota.ascolta else { return }
        if let attuale = correnteMac(gruppi),
           (v.incontroId != nil && v.incontroId == attuale.id) || (v.appuntamentoId != nil && v.appuntamentoId == attuale.appuntamentoId) {
            return
        }
        TestiRinviati.scriviOra()
        stato.copilota.azzera()
        if let id = v.incontroId {
            stato.incontroAperto = id
            stato.appuntamentoIncontro = nil
        } else {
            stato.incontroAperto = nil
            stato.appuntamentoIncontro = v.appuntamentoId
        }
        stato.schedaIncontro = RegoleElencoIncontri.momento(v, verbale: verbale(v))
    }
    #endif

    /// Il quaderno dell'incontro: barra, testata con il percorso, il passo aperto e il piede.
    private func quaderno(elenco: [Incontro], corrente: Incontro?) -> some View {
        VStack(alignment: .leading, spacing: Misure.IncontriImpaginazione.spazio) {
            barra(elenco: elenco, corrente: corrente)
                .entrataCascata(0, base: Tema.Apple.Moto.Cascata.baseDentroApp)
            if let i = corrente {
                testata(i)
                    .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp)
                // Ogni fase si impagina sullo spazio che resta: le schede riempiono la larghezza
                // e la barra in basso resta sempre dentro la finestra
                GeometryReader { geo in
                    fase(i, elenco: elenco, area: geo.size)
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .entrataCascata(2, base: Tema.Apple.Moto.Cascata.baseDentroApp)
                piede(i)
            } else {
                vuoto
                    .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp)
            }
        }
    }

    /// La richiesta dell'esito solo se viene da Incontri (le altre le presenta Posizioni).
    private var richiestaEsitoIncontri: Binding<RichiestaEsito?> {
        Binding<RichiestaEsito?>(
            get: {
                guard let r = stato.richiestaEsito, r.origine == .incontri else { return nil }
                return r
            },
            set: { stato.richiestaEsito = $0 }
        )
    }

    @ViewBuilder private func fase(_ i: Incontro, elenco: [Incontro], area: CGSize) -> some View {
        switch stato.schedaIncontro {
        case .preparazione: preparazione(i, elenco: elenco, area: area)
        case .ascolto: ascolto(i, area: area)
        case .passi:
            if i.stato == .concluso { concluso(i, area: area) } else { passi(i, area: area) }
        }
    }

    private func legame(_ i: Incontro) -> Binding<Incontro> {
        Binding(get: { stato.incontro(i.id) ?? i }, set: { stato.salvaIncontro($0) })
    }

    /// Occhiello in maiuscolo delle sezioni.
    private func occhiello(_ testo: String) -> some View {
        Text(testo)
            .font(Tema.Testo.Incontri.occhiello)
            .tracking(Tema.Misura.Incontri.trackingOcchiello)
            .foregroundColor(Tema.Colore.Incontri.secondario)
            .lineLimit(1)
    }

    /// Etichetta di un collegamento che apre un'altra scheda o app: il testo, poi la freccia.
    private func collegamento(_ testo: String) -> some View {
        HStack(spacing: Tema.Misura.Componenti.spazioSimboloPulsante) {
            Text(testo)
            Image(systemName: "arrow.up.right")
        }
    }

    // MARK: - Barra

    /// Solo la scelta del cliente e dell'incontro, e il nuovo incontro: tutto il resto è nella testata.
    private func barra(elenco: [Incontro], corrente: Incontro?) -> some View {
        let m = Tema.Misura.Incontri.self
        let scelto = corrente?.id ?? ""
        #if os(macOS)
        // Migliorie d'uso 21: le due tendine non ci sono più (l'elenco a sinistra segue il cliente della barra)
        let _ = (m, scelto)
        let perChi = corrente?.clienteId ?? cliente
        return HStack(spacing: Misure.IncontriImpaginazione.spazio) {
            Spacer()
            // Migliorie d'uso 20 (decisione 20-d): resta, per gli incontri senza appuntamento, ma non più blu
            Button { stato.nuovoIncontroSenzaAppuntamento(cliente: perChi) } label: { Label("Nuovo incontro", systemImage: "plus") }
                .buttonStyle(StileVetro())
                .fixedSize()
                .disabled(stato.cliente(perChi) == nil)
        }
        #else
        return HStack(spacing: Misure.IncontriImpaginazione.spazio) {
            MenuTendina(selezione: Bindable(stato).clienteAttivoId,
                        opzioni: stato.clienti.map { ($0.id, $0.nome) },
                        larghezza: m.menuCliente)
            if !elenco.isEmpty {
                MenuTendina(selezione: Binding(get: { scelto }, set: { stato.incontroAperto = $0 }),
                            opzioni: elenco.map { i in
                                (i.id, "\(Formati.dataBreve.string(from: i.data)) · \(i.titolo)\(i.stato == .concluso ? " ✓" : "")")
                            },
                            larghezza: m.menuIncontro)
            }
            Spacer()
            // Il blu della finestra
            Button { stato.nuovoIncontro(cliente: cliente) } label: { Label("Nuovo incontro", systemImage: "plus") }
                .buttonStyle(StileBlu())
                .fixedSize()
        }
        #endif
    }

    #if os(macOS)
    /// Nessun incontro nell'elenco: «Nessun incontro, per ora.» con «Apri l'Agenda» (gli incontri si fissano lì).
    private var vuoto: some View {
        let e = Tema.Apple.Copilota.Elenco.self
        return VStack(spacing: e.sottoTitoloVuoto) {
            Text(TestiIncontri.nessunIncontro)
                .carattereApple(e.titoloVuoto)
                .foregroundColor(e.coloreTitoloVuoto)
                .multilineTextAlignment(.center)
            Button { stato.apri(.agenda) } label: { Label(TestiIncontri.apriAgenda, systemImage: "calendar") }
                .buttonStyle(StileVetro(taglia: .grande, accento: true))
                .fixedSize()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modifier(CartaIncontro())
    }
    #else
    private var vuoto: some View {
        VStack(spacing: Misure.IncontriImpaginazione.spazio) {
            Image(systemName: "person.2.wave.2")
                .font(Tema.Apple.AltreApp.simboloVuoto.fontLeggibile)
                .foregroundColor(Tema.Colore.Incontri.terziario)
            Text("Nessun incontro con questo cliente.")
                .font(Tema.Apple.AltreApp.titoloVuoto.fontLeggibile)
                .foregroundColor(Tema.Colore.Incontri.testo)
            // L'azione unica del vuoto, grande; il blu resta «Nuovo incontro» in alto
            Button { stato.nuovoIncontro(cliente: cliente) } label: {
                Label("Prepara il primo incontro", systemImage: "list.bullet.rectangle")
            }
            .buttonStyle(StileVetro(taglia: .grande, accento: true))
            .fixedSize()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    #endif

    // MARK: - Testata

    /// La cosa principale, grande: chi, quando, che incontro, a che punto è il percorso e l'azione del passo.
    private func testata(_ i: Incontro) -> some View {
        let m = Tema.Misura.Incontri.self
        return ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: m.spazioTestata) {
                identita(i)
                Spacer(minLength: m.spazioTestata)
                VStack(alignment: .trailing, spacing: m.spazioTestata) {
                    percorso(i)
                    azioneFase(i)
                }
            }
            VStack(alignment: .leading, spacing: m.spazioTestata) {
                identita(i)
                percorso(i)
                azioneFase(i)
            }
        }
        .padding(m.margineTestata)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(CartaIncontro())
        // La cosa principale: la scheda si inclina appena verso il puntatore
        .inclinazione(massimo: Tema.Apple.AltreApp.inclinazioneGrande, raggio: Tema.Apple.AltreApp.raggioScheda)
    }

    private func identita(_ i: Incontro) -> some View {
        let m = Tema.Misura.Incontri.self
        let c = stato.cliente(i.clienteId)
        return HStack(alignment: .center, spacing: m.spazioTestata) {
            if let c {
                AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: m.avatar)
            }
            VStack(alignment: .leading, spacing: m.spazioRigheTestata) {
                Text(c?.nome ?? "Cliente")
                    .font(Tema.Testo.Incontri.cliente)
                    .foregroundColor(Tema.Colore.Incontri.testo)
                    .lineLimit(1)
                Text(i.titolo)
                    .font(Tema.Testo.Incontri.titolo)
                    .foregroundColor(Tema.Colore.Incontri.secondario)
                    .lineLimit(1)
                gettoniTestata(i, cliente: c)
                    .padding(.top, m.spazioRigheTestata)
            }
        }
    }

    /// Quando, tipo e durata in capsula, poi il canale (dell'appuntamento, altrimenti quelli del cliente).
    private func gettoniTestata(_ i: Incontro, cliente c: Cliente?) -> some View {
        let a = stato.appuntamento(i.appuntamentoId)
        return HStack(spacing: Tema.Misura.Incontri.spazioGettoni) {
            GettoneIncontro(testo: quando(i.data), simbolo: "calendar", colore: Tema.Colore.Incontri.passoCorrente)
            if let a, a.tipo != .altro {
                GettoneIncontro(testo: a.tipo.nome, simbolo: "person.2")
            }
            if let a {
                GettoneIncontro(testo: "\(a.durataMinuti) min", simbolo: "clock")
            }
            if let canale = a?.canale {
                EtichettaCanale(canale: canale)
            } else if let c {
                ForEach(c.canali) { canale in EtichettaCanale(canale: canale, compatta: true) }
            }
            if i.stato == .concluso {
                GettoneIncontro(testo: "Concluso", simbolo: "checkmark.circle.fill", colore: Tema.Colore.Incontri.passoFatto)
            }
        }
    }

    /// «Oggi · 09:30», «Domani · 15:00», «26 ottobre · 17:00» (con l'anno se non è quello in corso).
    private func quando(_ d: Date) -> String {
        let cal = Calendar.current
        let giorno: String
        if cal.isDateInToday(d) || cal.isDateInTomorrow(d) || cal.isDateInYesterday(d) {
            giorno = Formati.giornoRelativo(d).capitalized
        } else if cal.component(.year, from: d) == cal.component(.year, from: Date()) {
            giorno = Formati.giornoMese.string(from: d)
        } else {
            giorno = Formati.dataEstesa.string(from: d)
        }
        return "\(giorno) · \(Formati.ora.string(from: d))"
    }

    /// Il percorso a passi: si tocca un passo per aprirlo.
    private func percorso(_ i: Incontro) -> some View {
        let finito = i.stato == .concluso
        let ascoltato = finito || !i.vuoto
        let passi = [
            PassoPercorso(scheda: .preparazione, titolo: "Preparazione", fatto: ascoltato),
            PassoPercorso(scheda: .ascolto, titolo: "Ascolto", fatto: ascoltato),
            PassoPercorso(scheda: .passi, titolo: "Prossimi passi", fatto: finito),
        ]
        return IndicatorePercorso(passi: passi, selezione: Bindable(stato).schedaIncontro)
    }

    /// L'azione che porta avanti il passo aperto (la chiusura resta accanto alle sue scelte, nei prossimi passi).
    @ViewBuilder private func azioneFase(_ i: Incontro) -> some View {
        if i.stato != .concluso {
            switch stato.schedaIncontro {
            case .preparazione:
                HStack(spacing: Tema.Misura.Incontri.spazioGettoni) {
                    Button {
                        // Migliorie d'uso 21: un gesto che scrive, l'incontro di una bozza nasce qui
                        stato.assicuraIncontro(i)
                        stato.apri(.vera)
                        stato.chiediVera(SpuntoVera.incontro.domanda, spunto: .incontro)
                    } label: {
                        Label("Prepara con Vera", systemImage: "sparkles")
                    }
                    .buttonStyle(StileVetro())
                    .fixedSize()
                    Button {
                        stato.assicuraIncontro(i)
                        stato.schedaIncontro = .ascolto
                    } label: {
                        Label("Inizia l'ascolto", systemImage: Tema.Icona.Incontri.fase(.ascolto))
                    }
                    .buttonStyle(StileVetro(accento: true))
                    .fixedSize()
                }
            case .ascolto:
                HStack(spacing: Tema.Misura.Incontri.spazioGettoni) {
                    if CopilotaIncontro.disponibile {
                        // Torna al copilota dell'incontro (l'ascolto con il consenso del cliente)
                        Button { stato.copilota.modo = .copilota } label: {
                            Label("Il copilota", systemImage: "waveform")
                        }
                        .buttonStyle(StileVetro())
                        .fixedSize()
                    }
                    Button {
                        // Gli appunti appena scritti entrano nell'archivio prima di ricavarne le proposte
                        TestiRinviati.scriviOra()
                        stato.schedaIncontro = .passi
                        if let x = stato.incontro(i.id) { stato.estraiProposte(x) }
                    } label: {
                        Label("Ai prossimi passi", systemImage: Tema.Icona.Incontri.fase(.passi))
                    }
                    // Il blu resta «Nuovo incontro»: qui l'azione consigliata in vetro dell'accento
                    .buttonStyle(StileVetro(accento: true))
                    .fixedSize()
                }
            case .passi:
                EmptyView()
            }
        }
    }

    #if os(macOS)
    // MARK: - I tre momenti (Migliorie d'uso 20, solo sul Mac)

    /// Il quaderno sul Mac: la barra, la testata bassa con i tre momenti (sempre in vista, anche durante il copilota), il
    /// contenuto del momento aperto e il piede.
    private func quadernoMac(elenco: [Incontro], corrente: Incontro?) -> some View {
        VStack(alignment: .leading, spacing: Tema.Apple.Copilota.TestataIncontro.sottoTestata) {
            barra(elenco: elenco, corrente: corrente)
                .entrataCascata(0, base: Tema.Apple.Moto.Cascata.baseDentroApp)
            if let i = corrente {
                TestataMomentiIncontro(incontro: i, momento: stato.schedaIncontro) { mo in cambiaMomento(mo) }
                    .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp)
                // Il contenuto del momento si rifà a ogni cambio ed entra a cascata
                GeometryReader { geo in
                    momentoMac(i, elenco: elenco, area: geo.size)
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .entrataCascata(2, base: Tema.Apple.Moto.Cascata.baseDentroApp)
                .id(stato.schedaIncontro)
                piede(i)
            } else {
                vuoto
                    .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert(TestiMomentiIncontro.fermareAscolto, isPresented: Binding(get: { momentoDaFermare != nil },
                                                                          set: { if !$0 { momentoDaFermare = nil } })) {
            Button("Annulla", role: .cancel) { momentoDaFermare = nil }
            Button(TestiMomentiIncontro.ferma, role: .destructive) {
                let nuovo = momentoDaFermare
                momentoDaFermare = nil
                stato.copilota.interrompi()
                if let nuovo { stato.schedaIncontro = nuovo }
            }
        } message: {
            Text(TestiMomentiIncontro.fraseFermare)
        }
        .sheet(item: $moduloProssimo) { a in
            ModuloAppuntamento(bozza: a, nuovo: true, salva: { nuovo in
                stato.salvaAppuntamento(nuovo)
                stato.mostraAvviso("Prossimo incontro fissato con \(stato.cliente(nuovo.clienteId)?.nome ?? "il cliente"): \(Formati.dataOra.string(from: nuovo.inizio)).")
            }, elimina: {})
            .environment(stato)
        }
    }

    /// Un momento toccato: mentre il copilota ascolta, prima «Fermare l'ascolto?» (decisione 20-c: niente ascolto fuori
    /// vista); altrimenti si cambia subito.
    private func cambiaMomento(_ m: SchedaIncontro) {
        guard m != stato.schedaIncontro else { return }
        if stato.copilota.ascolta && m != .ascolto {
            momentoDaFermare = m
            return
        }
        TestiRinviati.scriviOra()
        stato.schedaIncontro = m
    }

    @ViewBuilder private func momentoMac(_ i: Incontro, elenco: [Incontro], area: CGSize) -> some View {
        switch stato.schedaIncontro {
        case .preparazione: primaMac(i, elenco: elenco, area: area)
        case .ascolto: duranteMac(i, area: area)
        case .passi: dopoMac(i, area: area)
        }
    }

    // MARK: Prima

    /// A sinistra i punti da toccare, «L'ultima volta» e i pulsanti; a destra quattro riquadri dai motori. Sotto, nello
    /// scorrimento, le cose di sempre: priorità, cosa è cambiato e i quattro temi dell'Analisi 360 (decisione 20-a).
    private func primaMac(_ i: Incontro, elenco: [Incontro], area: CGSize) -> some View {
        let p = Tema.Apple.Copilota.Prima.self
        let m = Misure.IncontriImpaginazione.self
        let destra = max(0, (area.width - p.spazio) * p.quotaDestra / (p.quotaSinistra + p.quotaDestra))
        let confermate = stato.analisi360(i.clienteId).confermate
        return ScrollView {
            VStack(alignment: .leading, spacing: m.spazio) {
                HStack(alignment: .top, spacing: p.spazio) {
                    cartaPrima(i, elenco: elenco)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    riquadriPrima(i)
                        .frame(width: destra)
                }
                .fixedSize(horizontal: false, vertical: true)
                perDecidereMac(i, larghezza: area.width)
                    .padding(.top, p.sopraDiSempre)
                HStack(spacing: Tema.Misura.Incontri.spazioGettoni) {
                    occhiello("TEMI DELL'INCONTRO")
                    Text("\(i.temi.count) di \(Self.temi.count)")
                        .font(Tema.Testo.Incontri.nota)
                        .foregroundColor(Tema.Colore.Incontri.terziario)
                }
                .padding(.top, m.staccoNota)
                grigliaTemi(i, colonne: m.colonneTemi(area.width), confermate: confermate)
            }
        }
    }

    /// I punti da toccare: quelli della traccia dell'impegno (una volta sola per dati dei calcoli), oppure, senza
    /// appuntamento, i temi dell'incontro con la loro domanda.
    private func puntiPrima(_ i: Incontro) -> [String] {
        if let a = stato.appuntamento(i.appuntamentoId) {
            return stato.ricavato("incontro-punti|\(a.id)") { () -> [String] in stato.puntiDaToccare(a) }
        }
        let punti = Self.temi.filter { i.temi.contains($0.0) }.map { "\($0.0.nome): \($0.1)" }
        return punti.isEmpty ? ["Ascoltare il cliente: cosa è cambiato e cosa vuole fare"] : punti
    }

    /// L'incontro concluso più recente del cliente prima di questo.
    private func ultimoConcluso(_ i: Incontro, elenco: [Incontro]) -> Incontro? {
        elenco.first { $0.stato == .concluso && $0.id != i.id && $0.data < i.data }
            ?? elenco.first { $0.stato == .concluso && $0.id != i.id }
    }

    /// Le prime due frasi di allora: le decisioni, o gli appunti se le decisioni mancano.
    private func primeFrasi(_ p: Incontro) -> String {
        let testo = (p.decisioni.isEmpty ? p.appunti : p.decisioni).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !testo.isEmpty else { return "Nessuna decisione registrata." }
        let frasi = testo.components(separatedBy: ". ")
        let prime = frasi.prefix(2).joined(separator: ". ")
        return frasi.count > 2 && !prime.hasSuffix(".") ? prime + "." : prime
    }

    private func cartaPrima(_ i: Incontro, elenco: [Incontro]) -> some View {
        let p = Tema.Apple.Copilota.Prima.self
        let concluso = i.stato == .concluso
        let a = stato.appuntamento(i.appuntamentoId)
        return VStack(alignment: .leading, spacing: 0) {
            ListaTiPreparo(titolo: TestiMomentiIncontro.puntiDaToccare, voci: puntiPrima(i),
                           avviata: preparandoId == i.id, poi: { preparato(i, appuntamento: a) })
            // «L'ultima volta» solo per un incontro non concluso (template riga 3770)
            if !concluso, let u = ultimoConcluso(i, elenco: elenco) {
                Text(TestiMomentiIncontro.ultimaVolta(u.data))
                    .carattereApple(p.occhiello)
                    .foregroundColor(p.coloreOcchiello)
                    .padding(.top, p.sopraUltimaVolta)
                Text(primeFrasi(u))
                    .carattereApple(p.ultimaVolta)
                    .foregroundColor(p.coloreUltimaVolta)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, p.sottoOcchiello)
            }
            Spacer(minLength: p.sopraPulsanti)
            pulsantiPrima(i, appuntamento: a)
        }
        .padding(p.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(p.superficie, raggio: p.raggio)
    }

    @ViewBuilder private func pulsantiPrima(_ i: Incontro, appuntamento a: Appuntamento?) -> some View {
        let p = Tema.Apple.Copilota.Prima.self
        if i.stato == .concluso {
            Text(TestiMomentiIncontro.preparazioneDaRileggere)
                .carattereApple(p.nota)
                .foregroundColor(p.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            let prepara = Button { preparandoId = i.id } label: { Text("✦ " + Parole.preparamiIncontro) }
                .buttonStyle(.applePrimarioGrande)
                .disabled(preparandoId == i.id)
            let dossier = Button { stato.apriCliente(i.clienteId) } label: { Text(TestiMomentiIncontro.apriDossier) }
                .buttonStyle(.appleGrande)
            let inizia = Button {
                // Un gesto che scrive (Migliorie d'uso 21): l'incontro di una bozza nasce qui
                stato.assicuraIncontro(i)
                stato.copilota.modo = .copilota
                stato.schedaIncontro = .ascolto
            } label: {
                HStack(spacing: Tema.Misura.Componenti.spazioSimboloPulsante) {
                    Text(TestiMomentiIncontro.iniziaIncontro)
                    Image(systemName: "chevron.right")
                }
            }
            .buttonStyle(.appleGrande)
            VStack(alignment: .leading, spacing: p.spazioPulsanti) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: p.spazioPulsanti) { prepara; dossier; inizia }
                    VStack(alignment: .leading, spacing: p.spazioPulsanti) {
                        prepara
                        HStack(spacing: p.spazioPulsanti) { dossier; inizia }
                    }
                }
                // Decisione 20-e: finiti i punti, la domanda di sempre a Vera come collegamento sobrio
                if preparatoId == i.id {
                    Button {
                        stato.assicuraIncontro(i)
                        stato.apri(.vera)
                        stato.chiediVera(SpuntoVera.incontro.domanda, spunto: .incontro)
                    } label: {
                        Label(TestiMomentiIncontro.chiediVera, systemImage: "sparkles")
                    }
                    .buttonStyle(.appleSobrio)
                    .fixedSize()
                }
            }
        }
    }

    /// I punti sono spuntati: il fascicolo dell'appuntamento si apre in Prospetti (come dalla traccia dell'impegno).
    private func preparato(_ i: Incontro, appuntamento a: Appuntamento?) {
        guard preparandoId == i.id else { return }
        preparandoId = nil
        preparatoId = i.id
        let nome = stato.cliente(i.clienteId)?.nome ?? i.titolo
        if let a {
            stato.preparaFascicolo(per: a)
            stato.mostraAvviso("Fascicolo per \(nome) pronto in Prospetti")
        } else {
            stato.mostraAvviso("Incontro con \(nome) preparato: i punti da toccare sono pronti")
        }
    }

    /// Patrimonio netto, dati per l'analisi (gli stessi riquadri della traccia), «Da fare per <nome>» (il «Da fare»
    /// unico del cliente) e «Proposte aperte» con i premi dell'anno.
    private func riquadriPrima(_ i: Incontro) -> some View {
        let p = Tema.Apple.Copilota.Prima.self
        let nome = TestiCopilota.primoNome(stato.cliente(i.clienteId)?.nome ?? "")
        let nastro = stato.nastroDaFareCompleto(cliente: i.clienteId)
        let proposte = stato.posizioniCliente(i.clienteId)
            .filter { $0.stato == .proposta && $0.esito != .accettata && $0.esito != .rifiutata }
        let premi = proposte.reduce(0) { $0 + $1.premioAnnuo }
        return VStack(alignment: .leading, spacing: p.spazioRiquadri) {
            CifreClienteTraccia(clienteId: i.clienteId)
            RiquadroTracciaApple(nome: TestiMomentiIncontro.daFarePer(nome)) {
                NumeroCheConta(Double(nastro.totale), formato: .intero, indice: 2)
                    .carattereApple(p.cifraRiquadro)
                    .foregroundColor(p.coloreCifra)
                    .lineLimit(1)
                Text(nastro.voci.first?.perche ?? TestiMomentiIncontro.nienteInSospeso)
                    .carattereApple(p.notaRiquadro)
                    .foregroundColor(p.coloreNotaRiquadro)
                    .lineLimit(2)
            }
            RiquadroTracciaApple(nome: TestiMomentiIncontro.proposteAperte) {
                NumeroCheConta(Double(proposte.count), formato: .intero, indice: 3)
                    .carattereApple(p.cifraRiquadro)
                    .foregroundColor(p.coloreCifra)
                    .lineLimit(1)
                Text(proposte.isEmpty ? TestiMomentiIncontro.nessuna
                     : (premi > 0 ? TestiMomentiIncontro.perLAnno(Formati.euro(premi)) : proposte.map(\.nome).joined(separator: ", ")))
                    .carattereApple(p.notaRiquadro)
                    .foregroundColor(p.coloreNotaRiquadro)
                    .lineLimit(2)
            }
        }
    }

    /// Le tessere di sempre che non sono già nei riquadri: priorità e cosa è cambiato.
    private func perDecidereMac(_ i: Incontro, larghezza: CGFloat) -> some View {
        let m = Misure.IncontriImpaginazione.self
        let fila = larghezza >= Tema.Misura.Incontri.sogliaFila
            ? AnyLayout(HStackLayout(alignment: .top, spacing: m.spazio))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: m.spazio))
        return fila {
            tesseraPriorita(i)
            tesseraCambiato(i)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Durante

    /// Il copilota (la sua barra alta 66 ha il selettore) oppure gli appunti a mano con la loro barra.
    @ViewBuilder private func duranteMac(_ i: Incontro, area: CGSize) -> some View {
        if stato.copilota.modo == .copilota {
            CopilotaIncontro(copilota: stato.copilota, clienteId: i.clienteId, incontro: i)
        } else {
            VStack(alignment: .leading, spacing: Tema.Apple.Copilota.Durante.sotto) {
                barraAppunti(i)
                GeometryReader { g in
                    ascolto(i, area: g.size)
                        .frame(width: g.size.width, height: g.size.height, alignment: .topLeading)
                }
            }
        }
    }

    /// «Copilota | Appunti a mano», la frase e «Ho finito ›» (→ «Dopo», con le proposte ricavate dagli appunti).
    private func barraAppunti(_ i: Incontro) -> some View {
        let b = Tema.Apple.Copilota.Durante.self
        return HStack(spacing: b.spazio) {
            SegmentatoPillola(selezione: Bindable(stato.copilota).modo,
                              voci: [(ModoAscoltoIncontro.copilota, TestiMomentiIncontro.copilota),
                                     (ModoAscoltoIncontro.appunti, TestiMomentiIncontro.appuntiAMano)])
                .fixedSize()
            Text(TestiMomentiIncontro.fraseAppunti)
                .carattereApple(b.frase)
                .foregroundColor(b.coloreFrase)
                .lineLimit(2)
            Spacer(minLength: 0)
            if i.stato != .concluso {
                Button { hoFinito(i) } label: {
                    HStack(spacing: Tema.Misura.Componenti.spazioSimboloPulsante) {
                        Text(TestiMomentiIncontro.hoFinito)
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.appleGrande)
                .fixedSize()
            }
        }
        .padding(.horizontal, b.paddingOrizzontale)
        .padding(.vertical, b.paddingVerticale)
        .frame(maxWidth: .infinity, minHeight: b.altezza, alignment: .leading)
        .superficieApple(b.superficie, raggio: b.raggio)
    }

    private func hoFinito(_ i: Incontro) {
        // Gli appunti appena scritti entrano nell'archivio prima di ricavarne le proposte
        TestiRinviati.scriviOra()
        stato.schedaIncontro = .passi
        if let x = stato.incontro(i.id) { stato.estraiProposte(x) }
    }

    // MARK: Dopo

    /// Il verbale del copilota dentro la pagina; senza copilota i prossimi passi dagli appunti; senza niente il vuoto;
    /// per un incontro concluso l'archivio in sola lettura con «Riapri».
    @ViewBuilder private func dopoMac(_ i: Incontro, area: CGSize) -> some View {
        let sessione = stato.copilota.sessione(incontro: i.id, cliente: i.clienteId, in: stato)
        let conVerbale = sessione.map { !($0.schede.isEmpty && $0.trascrizione.isEmpty) || $0.verbale != nil } ?? false
        let d = Tema.Apple.Copilota.Dopo.self
        if i.stato == .concluso {
            VStack(alignment: .leading, spacing: d.spazioNota) {
                HStack(spacing: d.spazioNota) {
                    Text(TestiMomentiIncontro.giaNelDossier)
                        .carattereApple(d.nota)
                        .foregroundColor(d.coloreNota)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    Button(TestiMomentiIncontro.riapri) { riapri(i) }
                        .buttonStyle(.appleGrande)
                        .fixedSize()
                        .disabled(stato.solaLettura)
                }
                concluso(i, area: area)
            }
        } else if conVerbale {
            VStack(alignment: .leading, spacing: d.spazioNota) {
                CorpoVerbaleCopilota(copilota: stato.copilota, clienteId: i.clienteId, incontro: i, sessione: sessione,
                                     nelDettaglio: false, fissaProssimo: { fissaProssimo(i) })
                    .padding(d.padding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .superficieApple(d.superficie, raggio: d.raggio)
                // Il verbale confermato non archivia l'incontro: la chiusura di sempre resta a un tocco
                HStack(spacing: d.spazioNota) {
                    Text("Bisogni, attività e Agenda si aggiornano alla chiusura.")
                        .carattereApple(d.nota)
                        .foregroundColor(d.coloreNota)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Button("Chiudi e archivia l'incontro") {
                        stato.assicuraIncontro(i)
                        stato.chiudiIncontro(i.id)
                    }
                    .buttonStyle(.appleGrande)
                    .fixedSize()
                    .disabled(stato.solaLettura)
                }
            }
        } else if !i.vuoto {
            passi(i, area: area)
        } else {
            vuotoDopo
        }
    }

    /// «Il verbale non c'è ancora.» con «Vai all'ascolto» e «Scrivilo a mano».
    private var vuotoDopo: some View {
        let d = Tema.Apple.Copilota.Dopo.self
        return VStack(spacing: 0) {
            Text(TestiMomentiIncontro.verbaleNonCe)
                .carattereApple(d.titoloVuoto)
                .foregroundColor(d.coloreTitoloVuoto)
                .multilineTextAlignment(.center)
            Text(TestiMomentiIncontro.fraseVerbaleNonCe)
                .carattereApple(d.fraseVuoto)
                .foregroundColor(d.coloreFraseVuoto)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: d.larghezzaVuoto)
                .padding(.top, d.sopraFrase)
                .padding(.bottom, d.sottoFrase)
            HStack(spacing: d.spazioPulsanti) {
                Button(TestiMomentiIncontro.vaiAllAscolto) {
                    stato.copilota.modo = .copilota
                    stato.schedaIncontro = .ascolto
                }
                .buttonStyle(.applePrimarioGrande)
                Button(TestiMomentiIncontro.scriviloAMano) {
                    stato.copilota.modo = .appunti
                    stato.schedaIncontro = .ascolto
                }
                .buttonStyle(.appleGrande)
            }
        }
        .padding(d.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .superficieApple(d.superficie, raggio: d.raggio)
    }

    /// «Riapri» (decisione 20-b): l'incontro torna in preparazione, il resto resta com'è.
    private func riapri(_ i: Incontro) {
        stato.riapriIncontro(i.id)
        stato.incontroAperto = i.id
        stato.schedaIncontro = .preparazione
        stato.mostraAvviso(TestiMomentiIncontro.incontroRiaperto)
    }

    /// «Fissa il prossimo»: il modulo dell'appuntamento con il cliente già scelto, fra 30 giorni alle 10.
    private func fissaProssimo(_ i: Incontro) {
        let quando = Self.trentaGiorni
        var a = Appuntamento.nuovo(clienteId: i.clienteId, giorno: quando)
        a.inizio = Appuntamento.alMinuto(quando)
        a.titolo = "Seguito · \(i.titolo)"
        a.tipo = .revisione
        moduloProssimo = a
    }
    #endif

    // MARK: - 1 Preparazione

    private static let temi: [(AreaAnalisi, String, String)] = [
        (.previdenza, "Quale reddito mantenere dopo il lavoro?", "Pensione stimata, età di uscita, contributi e piani già attivi."),
        (.protezione, "Chi dipende da questo reddito?", "Debiti, sostegno della famiglia, riserve e condizioni delle polizze."),
        (.investimenti, "Qual è lo scopo del capitale?", "Orizzonte, costi, liquidità necessaria e capacità di reggere le perdite."),
        (.risparmio, "Quanto dedicare ogni mese al progetto?", "Importo, scadenza e impegni già presenti."),
    ]

    private func preparazione(_ i: Incontro, elenco: [Incontro], area: CGSize) -> some View {
        let m = Misure.IncontriImpaginazione.self
        let colonne = m.colonneTemi(area.width)
        let confermate = stato.analisi360(i.clienteId).confermate
        return ScrollView {
            VStack(alignment: .leading, spacing: m.spazio) {
                perDecidere(i, larghezza: area.width)
                HStack(spacing: Tema.Misura.Incontri.spazioGettoni) {
                    occhiello("TEMI DELL'INCONTRO")
                    Text("\(i.temi.count) di \(Self.temi.count)")
                        .font(Tema.Testo.Incontri.nota)
                        .foregroundColor(Tema.Colore.Incontri.terziario)
                }
                .padding(.top, m.staccoNota)
                grigliaTemi(i, colonne: colonne, confermate: confermate)
                ultimaVolta(i, elenco: elenco)
            }
        }
    }

    /// Le poche cose che servono per decidere, in tessere alte uguali: priorità, cifre del dossier, cosa è cambiato.
    private func perDecidere(_ i: Incontro, larghezza: CGFloat) -> some View {
        let m = Misure.IncontriImpaginazione.self
        let fila = larghezza >= Tema.Misura.Incontri.sogliaFila
            ? AnyLayout(HStackLayout(alignment: .top, spacing: m.spazio))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: m.spazio))
        return fila {
            tesseraPriorita(i)
            tesseraDossier(i)
            tesseraCambiato(i)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Tessera di vetro con l'occhiello in testa.
    private func tessera<Contenuto: View>(_ titolo: String, @ViewBuilder contenuto: () -> Contenuto) -> some View {
        let m = Tema.Misura.Incontri.self
        return VStack(alignment: .leading, spacing: m.spazioTessera) {
            occhiello(titolo)
            contenuto()
            Spacer(minLength: 0)
        }
        .padding(m.margineTessera)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(CartaIncontro())
        .inclinazione(massimo: Tema.Apple.AltreApp.inclinazioneScheda, raggio: Tema.Apple.AltreApp.raggioScheda)
    }

    private func tesseraPriorita(_ i: Incontro) -> some View {
        let rilevati = stato.bisogniRilevati(i.clienteId)
        let profilo = stato.cliente(i.clienteId)?.bisogni ?? ProfiloBisogni()
        let ruota = MotoreBisogni.ruota(rilevati, profilo: profilo)
        let priorita = Array(MotoreBisogni.priorita(rilevati, profilo: profilo).prefix(3))
        return tessera("PRIORITÀ DEL CLIENTE") {
            if priorita.isEmpty {
                Text("Da costruire con l'ascolto di oggi.")
                    .font(Tema.Testo.Incontri.riga)
                    .foregroundColor(Tema.Colore.Incontri.secondario)
            } else {
                DisposizioneAcapoRicerca(spazio: Tema.Misura.Incontri.spazioGettoni) {
                    ForEach(priorita) { a in
                        let importanza = ruota[a] ?? .nessuna
                        GettoneIncontro(testo: a.nome, simbolo: a.simbolo, colore: Colori.Bisogni.area(a),
                                        font: Tema.Testo.Incontri.priorita, pallino: Colori.Bisogni.importanza(importanza))
                            .help("Importanza \(importanza.nome.lowercased())")
                    }
                }
            }
        }
    }

    private func tesseraDossier(_ i: Incontro) -> some View {
        let mi = Tema.Misura.Incontri.self
        let ci = Tema.Colore.Incontri.self
        let posizioni = stato.posizioniCliente(i.clienteId)
        // Dalla cache del cliente (lo stesso quadro di `RiepilogoPosizioni(posizioni)`, non rifatto a ogni body)
        let riepilogo = stato.riepilogoPosizioniCliente(i.clienteId)
        let scadenze = posizioni.filter { $0.scadeEntro(RiepilogoPosizioni.giorniScadenza) }
        let proposte = posizioni.filter { $0.stato == .proposta && $0.esito != .accettata && $0.esito != .rifiutata }
        return tessera("DAL DOSSIER") {
            HStack(alignment: .top, spacing: mi.spazioCifre) {
                // Le cifre si contano fino al valore del motore (RiepilogoPosizioni)
                CifraIncontro(valore: Formati.euroBreve(riepilogo.patrimonioNetto), etichetta: "Patrimonio netto",
                              numero: riepilogo.patrimonioNetto, formato: .personalizzato(Formati.euroBreve), indice: 0)
                CifraIncontro(valore: "\(proposte.count)", etichetta: proposte.count == 1 ? "Proposta aperta" : "Proposte aperte",
                              colore: proposte.isEmpty ? ci.testo : ci.cifraProposte,
                              numero: Double(proposte.count), indice: 1)
                CifraIncontro(valore: "\(scadenze.count)", etichetta: "In scadenza",
                              colore: scadenze.isEmpty ? ci.testo : ci.cifraScadenze,
                              numero: Double(scadenze.count), indice: 2)
            }
            ForEach(Array(proposte.prefix(mi.righeDossier))) { p in
                HStack(spacing: mi.spazioGettoni) {
                    EtichettaCanale(canale: p.canale, compatta: true)
                    Text(p.nome)
                        .font(Tema.Testo.Incontri.riga)
                        .foregroundColor(ci.testo)
                        .lineLimit(1)
                }
            }
            ForEach(Array(scadenze.prefix(mi.righeDossier))) { p in
                Label("\(p.nome) · \(Formati.giornoMeseBreve.string(from: p.scadenza ?? Date()))", systemImage: "clock")
                    .font(Tema.Testo.Incontri.riga)
                    .foregroundColor(ci.testo)
                    .lineLimit(1)
            }
        }
    }

    /// Cosa è cambiato dal riesame precedente, in capsule: solo se c'è un riesame precedente con variazioni.
    @ViewBuilder private func tesseraCambiato(_ i: Incontro) -> some View {
        // Senza fotografie del cliente non c'è un riesame precedente: la memoria non si calcola
        if stato.dati.fotografie.contains(where: { $0.clienteId == i.clienteId }),
           let memoria = stato.memoriaRiesame(i.clienteId), let p = memoria.precedente, !memoria.variazioni.isEmpty {
            let massimo = MotoreMemoria.massimoBreve
            tessera(TestiMemoria.occhielloDalRiesame(data: p.data)) {
                DisposizioneAcapoRicerca(spazio: Tema.Misura.Incontri.spazioGettoni) {
                    ForEach(Array(memoria.variazioni.prefix(massimo))) { v in GettoneVariazione(variazione: v) }
                }
                if memoria.variazioni.count > massimo {
                    Button {
                        stato.schedaCliente = .riesami
                        stato.apri(.clienti)
                    } label: {
                        collegamento("Altre \(memoria.variazioni.count - massimo) nel riesame")
                    }
                    .buttonStyle(StileCollegamento())
                    .fixedSize()
                }
            }
        }
    }

    /// Le quattro schede dei temi in file da 4, 2 o 1: compatte, nella stessa fila alte uguali.
    private func grigliaTemi(_ i: Incontro, colonne: Int, confermate: [AreaAnalisi]) -> some View {
        let m = Misure.IncontriImpaginazione.self
        let passo = max(1, colonne)
        let file = stride(from: 0, to: Self.temi.count, by: passo).map { Array(Self.temi[$0..<min($0 + passo, Self.temi.count)]) }
        return VStack(alignment: .leading, spacing: m.spazio) {
            ForEach(file.indices, id: \.self) { r in
                HStack(alignment: .top, spacing: m.spazio) {
                    ForEach(file[r], id: \.0) { tema in
                        schedaTema(i, tema, confermata: confermate.contains(tema.0))
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Un tema: l'area con il suo simbolo e la spunta (si tocca per sceglierlo), la domanda, lo stato dei dati
    /// e l'analisi a un tocco. Cosa guardare resta nel suggerimento.
    private func schedaTema(_ i: Incontro, _ tema: (AreaAnalisi, String, String), confermata: Bool) -> some View {
        let mi = Tema.Misura.Incontri.self
        let ci = Tema.Colore.Incontri.self
        let scelto = i.temi.contains(tema.0)
        return VStack(alignment: .leading, spacing: mi.spazioTessera) {
            testaTema(i, tema.0, scelto: scelto)
            Text(tema.1)
                .font(Tema.Testo.Incontri.temaDomanda)
                .foregroundColor(scelto ? ci.testo : ci.terziario)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            HStack(spacing: mi.spazioSimboloGettone) {
                Circle()
                    .fill(confermata ? ci.datiConfermati : ci.datiDaVerificare)
                    .frame(width: mi.pallino, height: mi.pallino)
                Text(confermata ? "Dati confermati" : "Da verificare")
                    .font(Tema.Testo.Incontri.nota)
                    .foregroundColor(ci.secondario)
                    .lineLimit(1)
                Spacer(minLength: mi.spazioGettoni)
                Button {
                    stato.areaAnalisi = tema.0
                    stato.apri(.analisi360)
                } label: {
                    collegamento("Analisi")
                }
                .buttonStyle(StileCollegamento())
                .fixedSize()
                .help("Apri l'analisi \(tema.0.nome)")
            }
        }
        .padding(mi.margineTema)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(CartaIncontro())
        .inclinazione(massimo: Tema.Apple.AltreApp.inclinazioneScheda, raggio: Tema.Apple.AltreApp.raggioScheda)
        .help(tema.2)
    }

    private func testaTema(_ i: Incontro, _ area: AreaAnalisi, scelto: Bool) -> some View {
        let mi = Tema.Misura.Incontri.self
        let ci = Tema.Colore.Incontri.self
        let b = legame(i)
        return Button {
            var x = b.wrappedValue
            if x.temi.contains(area) { x.temi.removeAll { $0 == area } } else { x.temi.append(area) }
            b.wrappedValue = x
        } label: {
            HStack(spacing: mi.spazioGettoni) {
                Image(systemName: Tema.Icona.Incontri.tema(area))
                    .font(Tema.Testo.Incontri.tema)
                    .foregroundColor(scelto ? Tema.Apple.Aree360.colore(area) : ci.terziario)
                    .frame(width: mi.simboloTema, height: mi.simboloTema)
                Text(area.nome)
                    .font(Tema.Testo.Incontri.tema)
                    .foregroundColor(scelto ? ci.testo : ci.secondario)
                    .lineLimit(1)
                Spacer(minLength: mi.spazioGettoni)
                Image(systemName: scelto ? "checkmark.circle.fill" : "circle")
                    .font(Tema.Testo.Incontri.tema)
                    .foregroundColor(scelto ? ci.spunta : ci.terziario)
            }
        }
        .buttonStyle(StileSemplice())
        .disabled(i.stato == .concluso)
    }

    /// L'ultima volta: data, titolo e le decisioni in due righe; il resto a un tocco. `elenco`: gli incontri del cliente
    /// della finestra, già letti dal body (l'incontro aperto è sempre suo).
    @ViewBuilder private func ultimaVolta(_ i: Incontro, elenco: [Incontro]) -> some View {
        #if os(macOS)
        // Sul Mac `elenco` è già quello del cliente dell'incontro mostrato (anche con «Tutti i clienti»)
        let suoi = elenco
        #else
        let suoi = i.clienteId == cliente ? elenco : stato.incontriCliente(i.clienteId)
        #endif
        if let p = suoi.first(where: { $0.stato == .concluso && $0.id != i.id }) {
            let mi = Tema.Misura.Incontri.self
            let decisioni = p.decisioni.isEmpty ? "Nessuna decisione registrata." : p.decisioni
            let lunghe = decisioni.count > mi.caratteriBreve
            VStack(alignment: .leading, spacing: mi.spazioGettoni) {
                HStack(spacing: mi.spazioGettoni) {
                    occhiello("L'ULTIMA VOLTA")
                    Text("\(Formati.dataEstesa.string(from: p.data)) · \(p.titolo)")
                        .font(Tema.Testo.Incontri.riga)
                        .foregroundColor(Tema.Colore.Incontri.secondario)
                        .lineLimit(1)
                    Spacer(minLength: mi.spazioGettoni)
                    Button {
                        stato.incontroAperto = p.id
                        stato.schedaIncontro = .passi
                    } label: {
                        collegamento("Apri")
                    }
                    .buttonStyle(StileCollegamento())
                    .fixedSize()
                }
                Text(decisioni)
                    .font(Tipo.incontroScrittura)
                    .foregroundColor(Tema.Colore.Incontri.testo)
                    .lineLimit(ultimaVoltaIntera ? nil : mi.righeUltimaVolta)
                    .fixedSize(horizontal: false, vertical: true)
                if lunghe {
                    Button(ultimaVoltaIntera ? "Mostra meno" : "Mostra tutto") { ultimaVoltaIntera.toggle() }
                        .buttonStyle(StileCollegamento())
                        .fixedSize()
                }
            }
            .padding(mi.margineTessera)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .modifier(CartaIncontro())
        }
    }

    // MARK: - 2 Ascolto

    private func ascolto(_ i: Incontro, area: CGSize) -> some View {
        let m = Misure.IncontriImpaginazione.self
        let b = legame(i)
        let solaLettura = i.stato == .concluso
        // Le tre domande in fila se c'è posto, altrimenti una sotto l'altra; così appunti e decisioni
        let inFila = area.width >= m.domandaMinima * 3 + m.spazio * 2
        let affiancati = area.width >= m.appuntiMinimi * 2 + m.spazio
        let domande = inFila ? AnyLayout(HStackLayout(alignment: .top, spacing: m.spazio))
                             : AnyLayout(VStackLayout(alignment: .leading, spacing: m.spazio))
        let appunti = affiancati ? AnyLayout(HStackLayout(alignment: .top, spacing: m.spazio))
                                 : AnyLayout(VStackLayout(alignment: .leading, spacing: m.spazio))
        // I campi crescono con la finestra: le domande con una quota dell'altezza, appunti e decisioni con il resto
        let altezzaDomanda = m.limita(area.height * m.quotaDomanda, m.domandaAltezza)
        let altezzaAppunti = m.limita(area.height - altezzaDomanda - m.riservaAscolto, m.appuntiAltezza)
        return ScrollView {
            VStack(alignment: .leading, spacing: m.spazio) {
                domande {
                    ForEach(Array(DomandaAscolto.allCases.enumerated()), id: \.element.id) { n, d in
                        schedaDomanda(i, d, numero: n + 1, testo: campo(b, d), solaLettura: solaLettura, altezza: altezzaDomanda)
                    }
                }
                // Nella stessa fila le schede sono alte uguali
                .fixedSize(horizontal: false, vertical: true)
                appunti {
                    schedaScrittura(occhiello: "APPUNTI", nota: nil, segnaposto: "Cosa è emerso, documenti raccolti, impressioni.",
                                    testo: b.appunti, id: "\(i.id)-appunti", solaLettura: solaLettura, altezza: altezzaAppunti)
                    schedaScrittura(occhiello: "DECISIONI", nota: "diventano attività",
                                    segnaposto: "Una per riga, con il verbo all'inizio: «Preparare…», «Inviare…».",
                                    testo: b.decisioni, id: "\(i.id)-decisioni", solaLettura: solaLettura, altezza: altezzaAppunti)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Una domanda aperta: numero e domanda in testa, il suggerimento dentro il campo finché è vuoto.
    private func schedaDomanda(_ i: Incontro, _ d: DomandaAscolto, numero: Int, testo: Binding<String>,
                               solaLettura: Bool, altezza: CGFloat) -> some View {
        let mi = Tema.Misura.Incontri.self
        let ci = Tema.Colore.Incontri.self
        return VStack(alignment: .leading, spacing: mi.spazioTessera) {
            HStack(alignment: .top, spacing: mi.spazioGettoni) {
                Text("\(numero)")
                    .font(Tema.Testo.Incontri.passoNumero)
                    .foregroundColor(ci.testoSuPasso)
                    .frame(width: mi.numeroDomanda, height: mi.numeroDomanda)
                    .background { Circle().fill(ci.passoCorrente) }
                Text(d.domanda)
                    .font(Tema.Testo.Incontri.domanda)
                    .foregroundColor(ci.testo)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            // Un campo per incontro e domanda: cambiando incontro la bozza riparte da quello nuovo
            FoglioRighe(testo: testo, solaLettura: solaLettura, segnaposto: d.suggerimento, salvaOra: { stato.salvaOra() })
                .id("\(i.id)-\(d.id)")
                .frame(height: solaLettura ? nil : altezza)
        }
        .padding(mi.margineTema)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(CartaIncontro())
    }

    /// Appunti o decisioni: occhiello (con la nota breve accanto) e il campo.
    private func schedaScrittura(occhiello titolo: String, nota: String?, segnaposto: String, testo: Binding<String>,
                                 id: String, solaLettura: Bool, altezza: CGFloat) -> some View {
        let mi = Tema.Misura.Incontri.self
        return VStack(alignment: .leading, spacing: mi.spazioTessera) {
            HStack(spacing: mi.spazioGettoni) {
                occhiello(titolo)
                if let nota {
                    Label(nota, systemImage: "arrow.right")
                        .font(Tema.Testo.Incontri.nota)
                        .foregroundColor(Tema.Colore.Incontri.terziario)
                        .lineLimit(1)
                }
            }
            FoglioRighe(testo: testo, solaLettura: solaLettura, segnaposto: segnaposto, salvaOra: { stato.salvaOra() })
                .id(id)
                .frame(height: solaLettura ? nil : altezza)
            Spacer(minLength: 0)
        }
        .padding(mi.margineTema)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(CartaIncontro())
    }

    private func campo(_ b: Binding<Incontro>, _ d: DomandaAscolto) -> Binding<String> {
        switch d {
        case .preoccupazioni: return b.preoccupazioni
        case .progetti: return b.progetti
        case .esperienza: return b.esperienza
        }
    }

    // MARK: - 3 Prossimi passi

    @ViewBuilder private func passi(_ i: Incontro, area: CGSize) -> some View {
        let m = Misure.IncontriImpaginazione.self
        if area.width < m.sogliaColonnaSotto {
            // Stretta: le proposte e, sotto, il prossimo passo scorrono insieme
            ScrollView {
                VStack(alignment: .leading, spacing: m.spazio) {
                    ParteIncontri { contenutoProposte(i) }
                        .padding(m.margine)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .modifier(CartaIncontro())
                    pannelloPasso(i)
                }
            }
        } else {
            HStack(alignment: .top, spacing: m.spazio) {
                // Poche proposte: la scheda è alta quanto il contenuto; tante: scorre dentro la finestra
                ViewThatFits(in: .vertical) {
                    ParteIncontri { contenutoProposte(i) }
                        .padding(m.margine)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .modifier(CartaIncontro())
                    ScrollView {
                        ParteIncontri { contenutoProposte(i) }
                            .padding(m.margine)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .modifier(CartaIncontro())
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                // Su uno schermo molto basso anche il prossimo passo scorre, invece di finire sotto il bordo
                ViewThatFits(in: .vertical) {
                    pannelloPasso(i)
                    ScrollView(.vertical, showsIndicators: false) { pannelloPasso(i) }
                }
                .frame(width: m.colonna(area.width))
            }
        }
    }

    /// Le proposte con la loro testa. Sta dentro `ParteIncontri`: le spunte (`proposteScelte`) e la lettura in corso si
    /// leggono lì, così una spunta rifà solo l'elenco delle proposte e non tutto il quaderno.
    private func contenutoProposte(_ i: Incontro) -> some View {
        let mi = Tema.Misura.Incontri.self
        let proposte = stato.proposteIncontro[i.id]
        return VStack(alignment: .leading, spacing: mi.spazioTessera) {
            testaProposte(i, proposte: proposte)
            if i.vuoto {
                Text("Gli appunti sono ancora vuoti: scrivili nell'ascolto.")
                    .font(Tema.Testo.Incontri.riga)
                    .foregroundColor(Tema.Colore.Incontri.secondario)
            } else if let proposte {
                if proposte.isEmpty {
                    Text("Nessun bisogno, evento o decisione riconoscibile negli appunti.")
                        .font(Tema.Testo.Incontri.riga)
                        .foregroundColor(Tema.Colore.Incontri.secondario)
                }
                VStack(alignment: .leading, spacing: mi.spazioProposte) {
                    ForEach(proposte) { p in rigaProposta(p) }
                }
            }
        }
    }

    /// Titolo, quante proposte sono spuntate e «Rileggi»: la spiegazione resta nel suggerimento.
    private func testaProposte(_ i: Incontro, proposte: [PropostaIncontro]?) -> some View {
        let mi = Tema.Misura.Incontri.self
        let scelte = (proposte ?? []).filter { stato.proposteScelte.contains($0.id) }.count
        return HStack(spacing: mi.spazioGettoni) {
            Text("Cosa ho capito")
                .font(Tema.Testo.Incontri.sezione)
                .foregroundColor(Tema.Colore.Incontri.testo)
                .help("Proposte ricavate dalle risposte e dagli appunti. Spunta quelle giuste: alla chiusura entrano nel profilo dei bisogni e nelle attività.")
            if let proposte, !proposte.isEmpty {
                GettoneIncontro(testo: "\(scelte) di \(proposte.count) da confermare", simbolo: "checkmark.square.fill",
                                colore: Tema.Colore.Incontri.spunta)
            }
            Spacer(minLength: mi.spazioGettoni)
            if stato.estrazioneInCorso {
                ProgressView().controlSize(.small)
                    .help(TestiStatoVera.inVista(mac: "Anche Vera sta leggendo gli appunti", altrove: "Anche Qwen sta leggendo gli appunti"))
            }
            Button { stato.estraiProposte(i) } label: {
                Label(proposte == nil ? "Leggi gli appunti" : "Rileggi", systemImage: "text.magnifyingglass")
            }
            .buttonStyle(StileVetro())
            .fixedSize()
            .disabled(i.vuoto || stato.estrazioneInCorso)
        }
    }

    /// Il prossimo passo e la chiusura: alta quanto il suo contenuto, il pulsante subito sotto le scelte.
    private func pannelloPasso(_ i: Incontro) -> some View {
        let b = legame(i)
        let mi = Tema.Misura.Incontri.self
        return VStack(alignment: .leading, spacing: mi.spazioTessera) {
            occhiello("IL PROSSIMO PASSO")
            TextField("Attività concordata (facoltativa)", text: b.prossimaAttivita).textFieldStyle(.plain)
                .padding(Misure.IncontriImpaginazione.margineFoglio)
                .pozzettoTestoLungo()
            CampoDataFacoltativa(data: b.scadenzaAttivita,
                                 predefinita: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                                 etichetta: "Entro una data", font: Tipo.incontroNota)
            occhiello("PROSSIMO INCONTRO")
                .padding(.top, Misure.IncontriImpaginazione.staccoNota)
            HStack(spacing: mi.spazioGettoni) {
                Toggle("Da fissare", isOn: Binding(get: { i.prossimoIncontro != nil }, set: { si in
                    var x = b.wrappedValue
                    x.prossimoIncontro = si ? (x.prossimoIncontro ?? Self.trentaGiorni) : nil
                    b.wrappedValue = x
                }))
                .toggleStyle(.apple)
                .fixedSize()
                .font(Tipo.incontroNota)
                if i.prossimoIncontro != nil {
                    DatePicker("", selection: Binding(get: { i.prossimoIncontro ?? Self.trentaGiorni },
                                                      set: { b.wrappedValue.prossimoIncontro = $0 }),
                               displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .stileDataCampo()
                        .environment(\.locale, Formati.italiano)
                }
            }
            Label("Bisogni, attività e Agenda si aggiornano alla chiusura.", systemImage: "info.circle")
                .font(Tema.Testo.Incontri.nota)
                .foregroundColor(Tema.Colore.Incontri.secondario)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Misure.IncontriImpaginazione.staccoNota)
                .bordoAlto(Colori.Incontri.filo)
                .help("Alla chiusura: le proposte spuntate entrano nel profilo dei bisogni, l'attività e il seguito in Agenda; l'appuntamento di oggi risulta concluso. Nessun messaggio viene inviato.")
            PulsanteAzione(titolo: "Chiudi e archivia l'incontro", principale: true, simbolo: "archivebox") {
                stato.assicuraIncontro(i)
                stato.chiudiIncontro(i.id)
            }
        }
        .padding(Misure.IncontriImpaginazione.margine)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .modifier(CartaIncontro())
    }

    private static var trentaGiorni: Date {
        let giorno = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: giorno) ?? giorno
    }

    /// Una proposta in una riga: spunta, tipo in capsula, titolo; la frase degli appunti sotto, in una riga.
    private func rigaProposta(_ p: PropostaIncontro) -> some View {
        let mi = Tema.Misura.Incontri.self
        let ci = Tema.Colore.Incontri.self
        let scelta = stato.proposteScelte.contains(p.id)
        return Button {
            if scelta { stato.proposteScelte.remove(p.id) } else { stato.proposteScelte.insert(p.id) }
        } label: {
            HStack(alignment: .center, spacing: mi.spazioTessera) {
                Image(systemName: scelta ? "checkmark.square.fill" : "square")
                    .foregroundColor(scelta ? ci.spunta : ci.terziario)
                    .font(Tema.Testo.Strumenti.spunta)
                VStack(alignment: .leading, spacing: mi.spazioRigaProposta) {
                    HStack(spacing: mi.spazioGettoni) {
                        GettoneIncontro(testo: etichetta(p), simbolo: "circle.fill", colore: colore(p),
                                        font: Tema.Testo.Incontri.tipoProposta)
                        Text(p.titolo)
                            .font(Tema.Testo.Incontri.proposta)
                            .foregroundColor(ci.testo)
                            .lineLimit(2)
                    }
                    if !p.fonte.isEmpty {
                        Text("«\(p.fonte)»")
                            .font(Tema.Testo.Incontri.fonte)
                            .italic()
                            .foregroundColor(ci.secondario)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                Spacer(minLength: 0)
                if p.origine == "Qwen" {
                    Image(systemName: "sparkles")
                        .foregroundColor(ci.secondario)
                        .help(TestiStatoVera.inVista(mac: "Proposta letta da Vera", altrove: "Proposta letta da Qwen"))
                }
            }
            .padding(EdgeInsets(top: mi.marginePropostaV, leading: mi.marginePropostaO,
                                bottom: mi.marginePropostaV, trailing: mi.marginePropostaO))
            .background {
                RoundedRectangle(cornerRadius: Tema.Apple.AltreApp.raggioVoce, style: .continuous)
                    .fill(scelta ? ci.propostaScelta : Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Tema.Apple.AltreApp.raggioVoce, style: .continuous)
                    .strokeBorder(ci.filo, lineWidth: Tema.Apple.Misura.bordo)
            }
        }
        .buttonStyle(StileSemplice())
        .help(p.fonte.isEmpty ? p.origine : "«\(p.fonte)» · \(p.origine)")
    }

    private func etichetta(_ p: PropostaIncontro) -> String {
        switch p.tipo {
        case .bisogno: return "BISOGNO"
        case .evento: return "EVENTO"
        case .attivita: return "ATTIVITÀ"
        }
    }

    private func colore(_ p: PropostaIncontro) -> Color {
        switch p.tipo {
        case .bisogno(let a, _): return Colori.Bisogni.area(a)
        case .evento: return Colori.Bisogni.importanza(.media)
        case .attivita: return Colori.Analisi.navBasso
        }
    }

    // MARK: - Incontro concluso

    /// Esito della proposta, attività, prossimo incontro e profilo dei bisogni dopo la chiusura.
    @ViewBuilder private func seguiti(_ i: Incontro) -> some View {
        // La proposta presentata all'incontro aspetta ancora l'esito
        if let a = stato.appuntamento(i.appuntamentoId), let p = stato.propostaDaChiudere(a) {
            Button {
                stato.apriEsito(p, passo: MotoreSeguitoProposte.passoIniziale(a), origine: .incontri, appuntamentoId: a.id)
            } label: {
                Label("Esito della proposta «\(p.nome)»", systemImage: "checkmark.seal")
            }
            .buttonStyle(StileVetro(accento: true))
            .lineLimit(1)
        }
        if let t = i.attivitaCreataId, stato.attivita.contains(where: { $0.id == t }) {
            Button {
                stato.attivitaSelezionata = t
                stato.apri(.attivita)
            } label: {
                Label("Attività concordata", systemImage: "checklist")
            }
            .buttonStyle(StileVetro())
            .fixedSize()
        }
        if let a = stato.appuntamento(i.appuntamentoCreatoId) {
            Button { stato.mostraInAgenda(a) } label: { Label("Prossimo incontro", systemImage: "calendar") }
                .buttonStyle(StileVetro())
                .fixedSize()
        }
        // Il riepilogo da mandare al cliente, finché Messaggi lo propone (CollegamentiMessaggi.swift): Prisma lo
        // prepara, lo spedisci tu
        if let o = stato.occasioneRiepilogo(i) {
            Button { stato.preparaMessaggio(clienteId: o.clienteId, occasioneId: o.id) } label: {
                Label(o.preparatoIl == nil ? "Manda il riepilogo" : "Riepilogo preparato", systemImage: "envelope")
            }
            .buttonStyle(StileVetro())
            .fixedSize()
            .help("Apre Messaggi con il riepilogo dell'incontro già scritto: lo controlli e lo spedisci tu")
        }
        Button {
            stato.schedaCliente = .bisogni
            stato.apri(.clienti)
        } label: {
            Label("Profilo dei bisogni", systemImage: "person.crop.rectangle")
        }
        .buttonStyle(StileVetro())
        .fixedSize()
    }

    /// Concluso: i seguiti in fila, poi quanto è stato scritto, in schede affiancate.
    private func concluso(_ i: Incontro, area: CGSize) -> some View {
        let mi = Tema.Misura.Incontri.self
        let m = Misure.IncontriImpaginazione.self
        let voci = [("COSA LA PREOCCUPA", i.preoccupazioni), ("I SUOI PROGETTI", i.progetti), ("LA SUA ESPERIENZA", i.esperienza),
                    ("APPUNTI", i.appunti), ("DECISIONI", i.decisioni)].filter { !$0.1.isEmpty }
        let colonne = [GridItem(.adaptive(minimum: mi.colonnaArchivio), spacing: m.spazio, alignment: .top)]
        return ScrollView {
            VStack(alignment: .leading, spacing: m.spazio) {
                // I seguiti dell'incontro: in fila se c'è posto, altrimenti uno sotto l'altro (mai tagliati)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: mi.spazioGettoni) { seguiti(i) }
                    VStack(alignment: .leading, spacing: mi.spazioGettoni) { seguiti(i) }
                }
                LazyVGrid(columns: colonne, alignment: .leading, spacing: m.spazio) {
                    ForEach(voci, id: \.0) { voce in
                        VStack(alignment: .leading, spacing: mi.spazioGettoni) {
                            occhiello(voce.0)
                            Text(voce.1)
                                .font(Tipo.incontroScrittura)
                                .foregroundColor(Tema.Colore.Incontri.testo)
                                .fixedSize(horizontal: false, vertical: true)
                                .textSelection(.enabled)
                        }
                        .padding(mi.margineTessera)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .modifier(CartaIncontro())
                    }
                }
            }
        }
    }

    // MARK: - Piede

    private func piede(_ i: Incontro) -> some View {
        HStack {
            Text(i.stato == .concluso ? "Archiviato · sola lettura" : "Si salva da solo")
                .font(Tema.Testo.Incontri.nota)
                .foregroundColor(Tema.Colore.Incontri.secondario)
            Spacer()
            // Una bozza da un appuntamento non è nell'archivio: niente da eliminare
            if stato.incontro(i.id) != nil {
                Button("Elimina l'incontro…") { confermaEliminazione = true }
                    .buttonStyle(StileSemplice())
                    .font(Tema.Testo.Incontri.nota)
                    .foregroundColor(Tema.Apple.Colore.rosso)
            }
        }
    }
}

/// Una parte del quaderno costruita nel body di questa vista e non in quello dell'app: ciò che legge di StatoShell (le
/// proposte spuntate) iscrive solo lei. Stessa impaginazione del contenuto.
private struct ParteIncontri<Contenuto: View>: View {
    let contenuto: () -> Contenuto

    var body: some View { contenuto() }
}

/// Scheda del quaderno degli incontri: la card piatta del tema Apple (raggio 22, bordo `separatore`).
/// Il contenuto (anche quello che scorre) si taglia alla forma prima del fondo.
struct CartaIncontro: ViewModifier {
    func body(content: Content) -> some View {
        content.schedaAltreAppApple()
    }
}

/// Il campo in cui si scrivono domande, appunti e decisioni: pozzetto arrotondato del tema. Il testo passa
/// all'incontro poco dopo l'ultimo tasto (TestoRinviato): chi lo usa gli dà un `.id` per incontro e campo.
struct FoglioRighe: View {
    @Binding var testo: String
    var solaLettura = false
    /// Suggerimento dentro il campo vuoto (sparisce al primo tasto).
    var segnaposto = ""
    /// Chiamata alla chiusura di Prisma dopo aver scritto il testo in attesa (di solito `stato.salvaOra`).
    var salvaOra: () -> Void = {}

    var body: some View {
        ZStack(alignment: .topLeading) {
            if solaLettura {
                // In sola lettura il pozzetto è alto quanto il testo (scorre la pagina, non il campo)
                Text(testo.isEmpty ? "—" : testo)
                    .font(Tipo.incontroScrittura)
                    .foregroundColor(Colori.Incontri.testo)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            } else {
                TestoRinviato(testo: $testo, salvaOra: salvaOra) { bozza in
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: bozza)
                            .font(Tipo.incontroScrittura)
                            .foregroundColor(Colori.Incontri.testo)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                        if bozza.wrappedValue.isEmpty && !segnaposto.isEmpty {
                            Text(segnaposto)
                                .font(Tema.Testo.Incontri.segnaposto)
                                .foregroundColor(Tema.Colore.Incontri.terziario)
                                .padding(Tema.Misura.Incontri.rientroSegnaposto)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
        }
        .padding(Misure.IncontriImpaginazione.margineFoglio)
        .pozzettoTestoLungo()
    }
}

#if os(macOS)
/// Migliorie d'uso 20: la testata bassa dell'incontro (card alta 74): avatar 44, il titolo su una riga, sotto «<nome> ·
/// <quando> · <luogo>» con tipo, durata e l'etichetta del canale; a destra i tre momenti. Resta sopra anche durante il
/// copilota. A parte, perché la spunta di «Durante» legge le sessioni del copilota: solo quando non ascolta, così le
/// frasi dell'ascolto non la rifanno (né rifanno Incontri).
private struct TestataMomentiIncontro: View {
    @Environment(StatoShell.self) var stato
    let incontro: Incontro
    let momento: SchedaIncontro
    let scegli: (SchedaIncontro) -> Void

    private typealias T = Tema.Apple.Copilota.TestataIncontro

    var body: some View {
        let _ = ContaCorpi.segna()
        let i = incontro
        let c = stato.cliente(i.clienteId)
        let a = stato.appuntamento(i.appuntamentoId)
        let verbale = stato.copilota.ascolta
            ? false
            : stato.copilota.verbalePronto(incontro: i.id, cliente: i.clienteId, in: stato)
        let sotto = TestiMomentiIncontro.sottoTestata(nome: c?.nome ?? "Cliente", data: a?.inizio ?? i.data, luogo: a?.luogo,
                                                     tipo: a.flatMap { x -> String? in x.tipo == .altro ? nil : x.tipo.nome },
                                                     durata: a?.durataMinuti)
        return HStack(alignment: .center, spacing: T.spazio) {
            if let c {
                AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: T.avatar)
            }
            VStack(alignment: .leading, spacing: T.spazioTitoli) {
                Text(i.titolo)
                    .carattereApple(T.titolo)
                    .foregroundColor(T.coloreTitolo)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack(spacing: T.spazioCanale) {
                    Text(sotto)
                        .carattereApple(T.sotto)
                        .foregroundColor(T.coloreSotto)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    // Il canale resta sempre riconoscibile: quello dell'appuntamento, altrimenti quelli del cliente
                    if let canale = a?.canale {
                        EtichettaCanale(canale: canale, compatta: true)
                    } else if let c {
                        ForEach(c.canali) { canale in EtichettaCanale(canale: canale, compatta: true) }
                    }
                }
            }
            .layoutPriority(1)
            Spacer(minLength: T.spazio)
            MomentiIncontroApple(aperto: momento, concluso: i.stato == .concluso, verbale: verbale, scegli: scegli)
        }
        .padding(.horizontal, T.paddingOrizzontale)
        .frame(maxWidth: .infinity, minHeight: T.altezza, alignment: .leading)
        .superficieApple(T.superficie, raggio: T.raggio)
    }
}
#endif
