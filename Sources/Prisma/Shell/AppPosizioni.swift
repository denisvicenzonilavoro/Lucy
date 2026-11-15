import SwiftUI

/// App Posizioni, il cuore di Prisma: le posizioni del cliente in essere e in proposta,
/// sempre divise per canale, con riepilogo, ripartizioni e dettaglio con proiezione.
struct AppPosizioni: View {
    enum FiltroStato: Hashable { case inEssere, proposte, tutte }

    @Environment(StatoShell.self) var stato
    @Environment(\.modoIstantanea) private var modoIstantanea
    @State var filtroStato: FiltroStato = .inEssere
    @State var filtroCanale: Canale?
    @State var area: AreaPosizione?
    @State var modulo: Posizione?
    /// «Dal catalogo»: il prodotto sul cliente in due passi (ModuloProdottoSulCliente).
    @State var dalCatalogo: RichiestaProdottoCliente?
    /// La posizione da aprire nel modulo intero appena si chiude «Dal catalogo» («Tutti i campi…»).
    @State var dopoCatalogo: Posizione?
    /// L'appuntamento da fissare per un cliente da ricontattare (dal Portafoglio).
    @State var moduloAppuntamento: Appuntamento?
    /// Il campo su cui si apre il modulo della posizione (completezza dei dati); si toglie alla chiusura.
    @State var fuocoPosizione: FuocoModulo?
    #if os(macOS)
    /// Migliorie d'uso 14: la schermata scelta nell'indice (`vistaScelta`, accesa subito) e quella mostrata, che cambia
    /// dopo l'uscita del contenuto (`esceVista`). Stato in memoria: da fuori si chiede con l'ancora di sempre.
    @State var vistaScelta: VistaPosizioniCliente = .quadro
    @State var vistaMostrata: VistaPosizioniCliente = .quadro
    @State var esceVista = false
    /// Rifinitura 11-17: la posizione aperta da una schermata delle analisi («Peso dei costi», «Passaggio
    /// generazionale»…), per ritrovare lo scorrimento al ritorno. Solo in memoria; si dimentica cambiando schermata.
    @State var rientroPosizione: String?
    @Environment(\.prismaCalmo) private var calmo
    #endif

    /// Il filtro dello stato con etichette brevi: nella colonna laterale non si troncano.
    static let opzioniStato: [(FiltroStato, String)] = [(.inEssere, "Attive"), (.proposte, "Proposte"), (.tutte, "Tutte")]

    /// L'aiuto di una voce del canale: il secondo clic sulla voce scelta toglie il filtro.
    static func aiutoCanale(_ c: Canale, attivo: Bool) -> String {
        if attivo { return "Clic di nuovo per vedere tutti i canali" }
        return c == .alleanza ? "Solo le posizioni \(c.nomeBreve)" : "Solo le posizioni \(c.nomeInFrase == "indipendente" ? "indipendenti" : c.nomeInFrase)"
    }

    /// Le posizioni del cliente attivo, o di tutti i clienti nella vista Portafoglio.
    private var delCliente: [Posizione] {
        (stato.portafoglio ? stato.posizioni : stato.posizioniCliente(stato.clienteAttivoId))
            .filter { filtroCanale == nil || $0.canale == filtroCanale }
    }

    private var perStato: [Posizione] {
        delCliente.filter {
            switch filtroStato {
            case .inEssere: return $0.stato == .inEssere
            case .proposte: return $0.stato == .proposta
            case .tutte: return true
            }
        }
    }

    private var elenco: [Posizione] {
        let ordine = AreaPosizione.allCases
        return perStato
            .filter { area == nil || $0.area == area }
            .sorted {
                let a = ordine.firstIndex(of: $0.area) ?? 0
                let b = ordine.firstIndex(of: $1.area) ?? 0
                return a != b ? a < b : $0.valore > $1.valore
            }
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        let forma = FormaVetro.arrotondata(Tema.Raggio.scheda)
        VStack(spacing: 0) {
            #if os(iOS)
            // iPad: con poco spazio l'elenco laterale si chiude in una striscia e si apre sopra il contenuto
            ColonnaLateraleAdattiva(larghezzaLaterale: Misure.Analisi.rail, titolo: "i filtri delle posizioni") {
                rail
                    .frame(width: Misure.Analisi.rail)
                    .bordoDestro(Colori.Analisi.railFilo)
            } contenuto: {
                corpo
            }
            #elseif os(macOS)
            HStack(spacing: 0) {
                if !stato.portafoglio, let c = stato.clienteAttivo {
                    // Migliorie d'uso 14: con un cliente scelto la colonna è l'indice delle sue posizioni (i filtri
                    // stanno nella card «Le posizioni» del quadro); nel portafoglio resta la colonna di sempre
                    IndicePosizioniApple(cliente: c,
                                         scelta: stato.posizioneInDettaglio == nil ? vistaScelta : nil,
                                         scegli: scegliVista)
                        .frame(width: Tema.Apple.Posizioni.Indice.larghezza)
                        .background(Colori.Analisi.railAlto)
                        .bordoDestro(Colori.Analisi.railFilo)
                } else {
                    rail
                        .frame(width: Misure.Analisi.rail)
                        .bordoDestro(Colori.Analisi.railFilo)
                }
                corpo
            }
            #endif
            barraStato
        }
        // La scheda del tema: angoli tondi e filo da 0,5 pt (il contenuto si taglia prima del contorno)
        .clipShape(forma)
        .overlay { forma.strokeBorder(Colori.Analisi.kpiBordo, lineWidth: Tema.Misura.filo).allowsHitTesting(false) }
        // Dalla storia dell'anno («Apri ›» delle famiglie protette): l'area da filtrare, consumata subito
        .onChange(of: stato.areaPosizioniDaAprire, initial: true) { _, nuova in
            guard let nuova else { return }
            area = nuova
            filtroStato = .inEssere
            filtroCanale = nil
            #if os(macOS)
            // Il filtro si vede nel quadro. Consumata al giro dopo: se cambia anche il cliente, il suo azzeramento
            // la trova ancora
            mostraVista(.quadro)
            DispatchQueue.main.async {
                if stato.areaPosizioniDaAprire == nuova { stato.areaPosizioniDaAprire = nil }
            }
            #else
            stato.areaPosizioniDaAprire = nil
            #endif
        }
        #if os(macOS)
        // Le ancore delle analisi (dossier, notifiche, istantanee) aprono la loro schermata; consumate al giro dopo,
        // così l'azzeramento al cambio di cliente le trova ancora. «attenzioni» e «seguito» restano del portafoglio
        .onChange(of: stato.ancoraPosizioni, initial: true) { _, ancora in
            guard let ancora, let v = VistaPosizioniCliente(ancora: ancora) else { return }
            stato.posizioneInDettaglio = nil
            mostraVista(v)
            DispatchQueue.main.async {
                if stato.ancoraPosizioni == ancora { stato.ancoraPosizioni = nil }
            }
        }
        // Cambiando cliente si torna sempre a «Quadro e posizioni», filtri azzerati (o alla schermata chiesta)
        .onChange(of: stato.clienteAttivoId) { _ in
            mostraVista(stato.ancoraPosizioni.flatMap { VistaPosizioniCliente(ancora: $0) } ?? .quadro)
            filtroStato = .inEssere
            filtroCanale = nil
            area = stato.areaPosizioniDaAprire
        }
        // Una posizione aperta dalla schermata di un'analisi: al ritorno la riga torna in vista
        .onChange(of: stato.posizioneInDettaglio) { _, id in
            if let id { rientroPosizione = id }
        }
        #endif
        // «Tutti i campi…»: a modulo chiuso la stessa posizione si apre nel modulo intero
        .sheet(item: $dalCatalogo, onDismiss: {
            if let p = dopoCatalogo { dopoCatalogo = nil; modulo = p }
        }) { r in
            ModuloProdottoSulCliente(prodotto: r.prodottoId.flatMap { stato.prodotto($0) }, statoIniziale: r.stato,
                                     clienteId: stato.clienteAttivoId, clienteScelto: r.clienteScelto,
                                     tuttiICampi: { p in dopoCatalogo = p })
                .environment(stato)
        }
        .sheet(item: $modulo, onDismiss: { fuocoPosizione = nil }) { p in
            ModuloPosizione(bozza: p, nuova: !stato.posizioni.contains { $0.id == p.id }) { stato.salvaPosizione($0) }
                .environment(\.fuocoModulo, fuocoPosizione)
        }
        // L'esito di una proposta (dettaglio e Portafoglio): solo le richieste di Posizioni, così Incontri aperto
        // insieme non lo presenta una seconda volta
        .sheet(item: richiestaEsitoPosizioni) { r in
            ModuloEsitoProposta(richiesta: r)
                .environment(stato)
        }
        .sheet(item: Bindable(stato).importazionePosizioni) { i in
            ModuloImportaPosizioni(importazione: i)
                .environment(stato)
        }
        .sheet(item: $moduloAppuntamento) { a in
            ModuloAppuntamento(bozza: a, nuovo: true, salva: { nuovo in
                stato.salvaAppuntamento(nuovo)
                stato.mostraAvviso("Appuntamento fissato con \(stato.cliente(nuovo.clienteId)?.nome ?? "il cliente"): \(Formati.dataOra.string(from: nuovo.inizio)).")
            }, elimina: {})
            .environment(stato)
        }
        .onAppear {
            controllaRichiesta(stato.richiestaNuovaPosizione)
            controllaCompletamento(stato.richiestaCompletamento)
            #if os(macOS)
            // Istantanee: il filtro di canale già acceso (le tessere non cambiano)
            if let c = RichiestaIstantaneaPosizioni.per(stato)?.canale { filtroCanale = c }
            #endif
        }
        .onChange(of: stato.richiestaNuovaPosizione) { controllaRichiesta($0) }
        .onChange(of: stato.richiestaDalCatalogo, initial: true) { _, r in
            guard let r else { return }
            stato.richiestaDalCatalogo = nil
            stato.portafoglio = false
            dalCatalogo = RichiestaProdottoCliente(prodottoId: nil, stato: r)
        }
        .onChange(of: stato.richiestaCompletamento) { controllaCompletamento($0) }
        .onChange(of: stato.clienteAttivoId) { _ in stato.posizioneInDettaglio = nil }
        // Entrando nel portafoglio si chiude il dettaglio; uscendo no (apriPosizione lo sta aprendo)
        .onChange(of: stato.portafoglio) { if $0 { stato.posizioneInDettaglio = nil } }
    }

    /// Il contenuto accanto all'elenco laterale: dettaglio, aggiornamento dei valori, portafoglio o dossier.
    private var corpo: some View {
        Group {
            if let id = stato.posizioneInDettaglio, let p = stato.posizioni.first(where: { $0.id == id }) {
                DettaglioPosizione(posizione: p, modifica: { modulo = p }, modificaSuCampo: { campo in
                    fuocoPosizione = FuocoModulo(campo: campo)
                    modulo = p
                })
            } else if let s = stato.aggiornaValori {
                // Il pannello «Aggiorna i valori»: sopra portafoglio e dossier, sotto il dettaglio («Apri ↗»)
                #if os(macOS)
                // Migliorie d'uso 44: sul Mac prima i dubbi, poi i pronti, con l'annullamento
                PannelloAggiornaValoriMac(sessione: s).id(s.id)
                #else
                PannelloAggiornaValori(sessione: s).id(s.id)
                #endif
            } else if stato.portafoglio {
                // Come nel dossier: gli indicatori contano in essere e proposte, lo stato filtra solo l'elenco.
                // La testata sceglie fra il Portafoglio e la Prova del fuoco (ProvaDelFuocoApple.swift)
                VistePortafoglioApple(stato: stato) { portafoglio }
            } else if senzaPosizioni, let c = stato.clienteAttivo {
                // Il cliente non ha niente (e nessun filtro è attivo): il vuoto spiega che cosa fare
                vuotoPosizioni(c)
            } else {
                #if os(macOS)
                if let c = stato.clienteAttivo {
                    schermataCliente(c)
                } else {
                    principale
                }
                #else
                principale
                #endif
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colori.Analisi.principale)
        // Tema Apple: pannelli e indicatori come card del tema, etichette del canale `.chA` / `.chI`
        // (vista Cliente, dettagli delle posizioni e pannelli del Portafoglio, senza perdere contenuti)
        .superficiApple()
    }

    #if os(macOS)
    // MARK: - Le schermate del cliente (migliorie d'uso 14)

    /// «Quadro e posizioni» o una delle cinque analisi; al cambio esce (y +6) e la nuova entra a cascata, in cima.
    private func schermataCliente(_ c: Cliente) -> some View {
        Group {
            if vistaMostrata == .quadro {
                QuadroPosizioniApple(cliente: c, filtroStato: $filtroStato, filtroCanale: $filtroCanale, area: $area,
                                     elenco: elenco, apri: { stato.posizioneInDettaglio = $0.id })
            } else if vistaMostrata == .smontaggio {
                // Migliorie d'uso 42: lo smontaggio dei documenti del cliente, senza passare dal portafoglio
                SmontaggioMac(stato: stato, clienteScelto: c.id)
            } else {
                AnalisiPosizioniApple(vista: vistaMostrata, cliente: c, rientro: rientroPosizione)
            }
        }
        .id(vistaMostrata)
        .opacity(esceVista ? 0 : 1)
        .offset(y: esceVista ? Tema.Apple.Moto.CambioScheda.spostamento : 0)
    }

    /// Un clic su una voce dell'indice: la scheda di una posizione aperta si chiude; la voce già scelta non fa altro.
    private func scegliVista(_ nuova: VistaPosizioniCliente) {
        stato.posizioneInDettaglio = nil
        // Un'altra schermata riparte dall'alto; la stessa (ritorno dalla scheda) ritrova la riga
        if nuova != vistaMostrata { rientroPosizione = nil }
        guard nuova != vistaScelta || nuova != vistaMostrata else { return }
        vistaScelta = nuova
        if modoIstantanea || calmo {
            if modoIstantanea {
                mostraVista(nuova)
            } else {
                withAnimation(Tema.Moto.dissolvenzaCalma) { mostraVista(nuova) }
            }
            return
        }
        withAnimation(Tema.Apple.Moto.CambioScheda.uscita) { esceVista = true }
        Movimenti.dopo(Tema.Apple.Moto.tempo(Tema.Apple.Moto.CambioScheda.durataUscita)) {
            // Un altro clic nel frattempo: entra quella
            guard vistaScelta == nuova else { return }
            vistaMostrata = nuova
            esceVista = false
        }
    }

    /// La schermata subito, senza uscita (ancore, cambio di cliente, istantanee).
    private func mostraVista(_ v: VistaPosizioniCliente) {
        rientroPosizione = nil
        vistaScelta = v
        vistaMostrata = v
        esceVista = false
    }
    #endif

    private func controllaRichiesta(_ richiesta: StatoPosizione?) {
        guard let richiesta else { return }
        stato.richiestaNuovaPosizione = nil
        // Una posizione nuova è sempre di un cliente: si torna al suo dossier
        stato.portafoglio = false
        let canale = filtroCanale ?? stato.clienteAttivo?.canali.first ?? .alleanza
        var p = Posizione(clienteId: stato.clienteAttivoId, canale: canale, stato: richiesta, area: area ?? .investimento, nome: "")
        if richiesta == .proposta { p.esito = .bozza }
        modulo = p
    }

    /// La richiesta dell'esito solo se viene da Posizioni (quelle di Incontri le presenta Incontri).
    private var richiestaEsitoPosizioni: Binding<RichiestaEsito?> {
        Binding<RichiestaEsito?>(
            get: {
                guard let r = stato.richiestaEsito, r.origine == .posizioni else { return nil }
                return r
            },
            set: { stato.richiestaEsito = $0 }
        )
    }

    /// Completezza dei dati: apre il modulo della posizione sul campo che manca (le altre richieste sono di Clienti).
    private func controllaCompletamento(_ richiesta: RichiestaCompletamento?) {
        guard let richiesta, case .posizione(let id, let campo) = richiesta.destinazione else { return }
        stato.richiestaCompletamento = nil
        stato.portafoglio = false
        fuocoPosizione = FuocoModulo(campo: campo)
        modulo = stato.posizioni.first { $0.id == id }
    }

    // MARK: - Elenco laterale

    private var rail: some View {
        // I conteggi per area, in cache per dati, cliente e filtri (con 200 clienti le posizioni sono migliaia: prima si
        // filtravano e si contavano a ogni disegno della colonna)
        let statoScelto: StatoPosizione? = filtroStato == .inEssere ? .inEssere : filtroStato == .proposte ? .proposta : nil
        let conti = stato.contiAreePosizioni(portafoglio: stato.portafoglio, canale: filtroCanale, stato: statoScelto)
        let conteggi = conti.perArea
        return VStack(alignment: .leading, spacing: 6) {
            // L'elenco scorre dentro la scheda: con tante voci o schermo basso la finestra non si allunga
            // sotto il bordo (le due colonne finiscono con lo stesso margine di Clienti)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    #if os(macOS)
                    // Migliorie d'uso 2: il cliente si sceglie nella barra; con un cliente scelto, in cima
                    // «‹ Tutto il portafoglio» riporta a «Tutti i clienti»
                    if stato.portafoglio {
                        TestataPortafoglioRail(clienti: stato.clienti.count)
                    } else if !stato.inModoCliente {
                        Button { stato.scegliCliente(nil, avviso: true) } label: {
                            Text("‹ " + TestiSceltaCliente.tuttoIlPortafoglio)
                        }
                        .buttonStyle(.appleSobrio)
                        .help(TestiSceltaCliente.aiutoTuttoIlPortafoglio)
                        .padding(.top, 2)
                    }
                    #else
                    if !stato.inModoCliente {
                        SegmentiAnalisi(opzioni: [(false, "Cliente"), (true, "Portafoglio")], selezione: Bindable(stato).portafoglio)
                            .padding(.top, 2)
                    }
                    // Le stesse testate delle altre app di analisi (ComponentiStrumenti)
                    if stato.portafoglio {
                        TestataPortafoglioRail(clienti: stato.clienti.count)
                    } else {
                        DossierRail()
                    }
                    #endif

                    EtichettaRail(testo: "Stato")
                    SegmentiAnalisi(opzioni: Self.opzioniStato, selezione: $filtroStato)
                    // Il canale come in Documenti: una voce per canale con il suo colore, un secondo clic toglie il filtro
                    EtichettaRail(testo: "Canale")
                    VStack(spacing: 0) {
                        ForEach(Canale.allCases) { c in
                            VoceNavigazione(titolo: c.nomeBreve, colore: Tema.Colore.canale(c), attiva: filtroCanale == c) {
                                filtroCanale = filtroCanale == c ? nil : c
                            }
                            .help(Self.aiutoCanale(c, attivo: filtroCanale == c))
                        }
                    }
                    EtichettaRail(testo: "Aree")
                    VStack(spacing: 0) {
                        VoceNavigazione(titolo: "Tutte le aree", conteggio: conti.totale, attiva: area == nil) { area = nil }
                        ForEach(AreaPosizione.allCases) { a in
                            VoceNavigazione(titolo: a.nome, colore: Colori.Analisi.area(a),
                                            conteggio: conteggi[a] ?? 0, attiva: area == a) {
                                area = a
                                stato.posizioneInDettaglio = nil
                            }
                        }
                    }
                    if !stato.portafoglio {
                        EtichettaRail(testo: "Analisi")
                        VStack(spacing: 0) {
                            ForEach([("Il patrimonio nel tempo", "patrimonio"), ("Prova di resistenza", "resistenza"), ("Coerenza con il profilo", "coerenza"),
                                     ("Peso dei costi", "costi"), ("Passaggio generazionale", "successione")], id: \.1) { voce in
                                // Chiusa la scheda di una posizione, il dossier è visibile e l'ancora si consuma
                                VoceNavigazione(titolo: voce.0, attiva: false) {
                                    stato.posizioneInDettaglio = nil
                                    stato.ancoraPosizioni = voce.1
                                }
                            }
                        }
                    }
                    EtichettaRail(testo: "Collegati")
                    VStack(spacing: 0) {
                        ForEach([AppPrisma.analisi360, .prodotti]) { app in
                            VoceNavigazione(titolo: app.titolo, attiva: false) { stato.apri(app) }
                        }
                        // Simulatore e Confronto: strumenti di Analisi 360 (sul Mac si aprono lì)
                        ForEach([StrumentoAnalisi.simulatore, .confronto]) { s in
                            VoceNavigazione(titolo: s.titolo, simbolo: s.simbolo, attiva: false) { stato.apriStrumentoAnalisi(s) }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Tema.Misura.Dossier.sfumaturaRail)
            }
            // L'ultima voce sfuma prima del piede invece di finire tagliata sul filo
            .mask {
                VStack(spacing: 0) {
                    Color.black
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: Tema.Misura.Dossier.sfumaturaRail)
                }
            }
            ArchivioLocaleRail()
        }
        .padding(Misure.Analisi.margineRail)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Colori.Analisi.railAlto)
    }

    // MARK: - Portafoglio

    /// Il portafoglio di tutti i clienti nel tema Apple (PortafoglioApple: card del portafoglio, stato del lavoro e
    /// nastro «Da fare»), con sotto i pannelli di sempre (CorpoPortafoglio, che non osserva lo stato e si rifà solo
    /// quando cambia la sua chiave); lo scorrimento alle ancore resta qui, dove lo stato si osserva.
    private var portafoglio: some View {
        ScrollViewReader { lettore in
            PortafoglioApple(stato: stato) {
                CorpoPortafoglio(stato: stato,
                                 chiave: CorpoPortafoglio.Chiave(vista: stato.chiaveVista, canale: filtroCanale, area: area,
                                                                 solaLettura: stato.solaLettura, prospetto: stato.prospetto,
                                                                 orizzonte: stato.orizzonteSostituzione),
                                 moduloAppuntamento: $moduloAppuntamento)
                    .equatable()
            }
            // Solo le ancore del portafoglio: quelle del dossier le consuma la vista del cliente
            .onAppear {
                if AppPosizioni.ancorePortafoglio.contains(stato.ancoraPosizioni ?? "") { scorri(lettore) }
                // Le voci del radar che mancano si preparano fuori dal thread principale (fuori dal body): il primo
                // passaggio a Radar le trova pronte. Non fa niente nelle istantanee, nelle prove e con pochi clienti
                stato.preparaRadarInSottofondo()
            }
            .onChange(of: stato.ancoraPosizioni) { a in if AppPosizioni.ancorePortafoglio.contains(a ?? "") { scorri(lettore) } }
        }
    }

    // MARK: - Vuoto guidato

    /// Il cliente attivo non ha nessuna posizione, né in essere né in proposta, e non c'è un filtro attivo.
    private var senzaPosizioni: Bool {
        filtroCanale == nil && area == nil && stato.posizioniCliente(stato.clienteAttivoId).isEmpty
    }

    private func vuotoPosizioni(_ c: Cliente) -> some View {
        VuotoGuidato(
            icona: "chart.pie",
            titolo: "\(c.nome) non ha ancora posizioni",
            perche: "Le posizioni sono ciò che il cliente ha già (polizze, fondi, piani pensione) e ciò che gli proponi. Da qui nascono tutte le analisi.",
            passi: [
                ("Aggiungi ciò che ha", "Con «Posizione», in alto a destra."),
                ("Oppure leggilo da un documento", "Trascina il KID o la polizza in Documenti."),
                ("Proponi", "Con «Proposta», sempre con il suo canale."),
            ],
            pulsante: "Posizione",
            azione: { stato.richiestaNuovaPosizione = .inEssere },
            secondario: ("Importa da Excel…", { stato.importaPosizioniDaFile() })
        )
        .disabled(stato.solaLettura)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Pannello principale

    private var principale: some View {
        // Senza filtro di canale il riepilogo è quello del cliente, già calcolato (DerivatiDati)
        let r = filtroCanale == nil ? stato.riepilogoPosizioniCliente(stato.clienteAttivoId) : RiepilogoPosizioni(delCliente)
        return ScrollViewReader { lettore in
            ScrollView {
                // Pigra (giro 0, tappa 4): i pannelli sotto la piega si costruiscono quando si scorre (stesso aspetto)
                LazyVStack(alignment: .leading, spacing: 18) {
                    FasciaKPI {
                        KPI(titolo: "Patrimonio netto", valore: Formati.euro(r.patrimonioNetto)) {
                            Chip(testo: "Attività \(Formati.euroBreve(r.attivita))")
                            Chip(testo: "Debiti \(Formati.euroBreve(r.debiti))")
                        }
                        KPI(titolo: "Premi e versamenti", valore: Formati.euro(r.premiAnnui)) {
                            Text("all'anno")
                            Chip(testo: "\(r.contrattiConPremi) \(r.contrattiConPremi == 1 ? "contratto" : "contratti")")
                        }
                        KPI(titolo: "Capitale assicurato", valore: Formati.euro(r.capitaleAssicurato)) {
                            Chip(testo: "\(r.coperture) \(r.coperture == 1 ? "copertura" : "coperture")")
                        }
                        KPI(titolo: "Proposte aperte", valore: "\(r.proposteAperte)", ultimo: true) {
                            Text("per \(Formati.euro(r.valoreProposte))")
                        }
                    }

                    // Sull'iPad stretto i due pannelli vanno uno sotto l'altro (sul Mac sempre affiancati)
                    Affiancati(soglia: SoglieAffiancati.posizioni, spazio: 24) {
                        PannelloAnalisi(titolo: "Ripartizione per area", nota: "Posizioni in essere, debiti a parte") { EmptyView() } contenuto: {
                            Self.ripartizione(r)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        PannelloAnalisi(titolo: "Per canale", nota: "Attività in essere") { EmptyView() } contenuto: {
                            Self.canali(r, apri: { stato.posizioneInDettaglio = $0.id })
                        }
                        .larghezzaAffiancata(330, alignment: .leading)
                    }

                    // Calcolate una volta e riusate finché i dati non cambiano (DerivatiDati)
                    let analisi = stato.analisiDossier(stato.clienteAttivoId)
                    if !analisi.patrimonio.vuoto {
                        PannelloPatrimonio(p: analisi.patrimonio).id("patrimonio")
                    }
                    if !analisi.prova.vuota {
                        PannelloResistenza(prova: analisi.prova).id("resistenza")
                    }
                    // Coerenza con il profilo: rischio oltre la propensione e concentrazione su emittente o canale
                    if let c = stato.clienteAttivo {
                        let coerenza = stato.coerenzaCliente(c)
                        if coerenza.oggi.patrimonioFinanziario > 0 || coerenza.conProposte != nil {
                            PannelloCoerenza(esito: coerenza).id("coerenza")
                        }
                    }
                    if !analisi.costi.vuota {
                        PannelloCosti(analisi: analisi.costi).id("costi")
                    }
                    if let successione = analisi.successione, !successione.vuota {
                        PannelloSuccessione(s: successione).id("successione")
                    }

                    PannelloAnalisi(titolo: titoloTabella, nota: "Tocca una riga per il dettaglio e la proiezione") {
                        if let area { Chip(testo: area.nome) }
                    } contenuto: {
                        TabellaPosizioni(posizioni: elenco) { stato.posizioneInDettaglio = $0.id }
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 16, trailing: 12))
            }
            .onAppear { scorri(lettore) }
            .onChange(of: stato.ancoraPosizioni) { _ in scorri(lettore) }
        }
    }

    /// Le ancore del Portafoglio: le cose da sistemare nei dossier e le proposte da riprendere.
    static let ancorePortafoglio: Set<String> = ["attenzioni", "seguito"]

    /// Porta in vista il pannello chiesto (dalla colonna o da un'istantanea), poi dimentica l'ancora.
    func scorri(_ lettore: ScrollViewProxy) {
        guard let ancora = stato.ancoraPosizioni else { return }
        let istantanea = modoIstantanea
        DispatchQueue.main.async {
            // Nell'istantanea si scorre di colpo: con il movimento la foto arriverebbe a metà strada
            if istantanea {
                lettore.scrollTo(ancora, anchor: .top)
            } else {
                withAnimation(Animazioni.apertura) { lettore.scrollTo(ancora, anchor: .top) }
            }
            stato.ancoraPosizioni = nil
        }
    }

    private var titoloTabella: String {
        switch filtroStato {
        case .inEssere: return "Posizioni in essere"
        case .proposte: return "Proposte"
        case .tutte: return "Tutte le posizioni"
        }
    }

    /// L'anello delle aree con le righe dei valori (dossier e Portafoglio). Con `scegli` (il quadro del cliente sul Mac,
    /// migliorie d'uso 14) la legenda è il filtro per area: un clic sceglie l'area, `areaScelta` ha il fondo accento.
    static func ripartizione(_ r: RiepilogoPosizioni, areaScelta: AreaPosizione? = nil,
                             scegli: ((AreaPosizione) -> Void)? = nil) -> some View {
        let aree = AreaPosizione.allCases.filter { !$0.passivo && (r.perArea[$0] ?? 0) > 0 }
        return HStack(alignment: .center, spacing: 22) {
            GraficoAnello(
                fette: aree.map { .init(id: $0.rawValue, valore: r.perArea[$0] ?? 0, colore: Colori.Analisi.area($0)) },
                etichettaCentro: "Attività",
                valoreCentro: Formati.euroBreve(r.attivita)
            )
            VStack(spacing: 0) {
                if aree.isEmpty {
                    Text("Nessuna posizione in essere.").font(Tipo.kpiNota).foregroundColor(Colori.Analisi.kpiNota)
                }
                ForEach(aree) { a in
                    let v = r.perArea[a] ?? 0
                    let riga = HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: Tema.Raggio.Dossier.quadratinoArea).fill(Colori.Analisi.area(a)).frame(width: 10, height: 10)
                        Text(a.nome).font(Tipo.tabellaCella).foregroundColor(Colori.Analisi.tabellaTesto).lineLimit(1)
                        Spacer()
                        Text(Formati.euro(v)).font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.tabellaTesto)
                            .lineLimit(1).fixedSize()
                        Text(Formati.percentuale(r.attivita > 0 ? (v / r.attivita * 100).rounded() : 0))
                            .font(Tipo.chip)
                            .foregroundColor(Colori.Analisi.kpiNota)
                            .frame(width: 34, alignment: .trailing)
                    }
                    .padding(.vertical, 6)
                    if let scegli {
                        VoceAreaRipartizione(area: a, scelta: areaScelta == a, scegli: scegli) { riga }
                            .bordoBasso(Colori.Analisi.tabellaRiga)
                    } else {
                        riga.bordoBasso(Colori.Analisi.tabellaRiga)
                    }
                }
                if r.debiti > 0 {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: Tema.Raggio.Dossier.quadratinoArea).fill(Colori.Analisi.area(.debiti)).frame(width: 10, height: 10)
                        Text("Debiti").font(Tipo.tabellaCella).foregroundColor(Colori.Analisi.tabellaTesto).lineLimit(1)
                        Spacer()
                        Text("−\(Formati.euro(r.debiti))").font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.erroreTesto)
                            .lineLimit(1).fixedSize()
                        Spacer().frame(width: 34)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    /// Le attività per canale e le posizioni in scadenza entro 90 giorni (dossier e Portafoglio).
    /// `massimo`: le righe in scadenza al massimo, poi «…e altre N» (nil = tutte); `apri`: il tocco su una riga.
    /// `scadenze: false`: niente righe in scadenza (il quadro del cliente sul Mac le mostra già nell'elenco).
    static func canali(_ r: RiepilogoPosizioni, massimo: Int? = nil, scadenze mostraScadenze: Bool = true,
                       apri: @escaping (Posizione) -> Void) -> some View {
        let scadenze = massimo.map { Array(r.inScadenza.prefix($0)) } ?? r.inScadenza
        let nascoste = r.inScadenza.count - scadenze.count
        return VStack(alignment: .leading, spacing: 10) {
            BarraCanali(quotaAlleanza: r.quota(.alleanza))
            ForEach(Canale.allCases) { c in
                HStack {
                    EtichettaCanale(canale: c, compatta: true)
                    Spacer()
                    Text(Formati.euro(r.perCanale[c] ?? 0)).font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.tabellaTesto)
                    Text(Formati.percentuale((r.quota(c) * 100).rounded()))
                        .font(Tipo.chip).foregroundColor(Colori.Analisi.kpiNota).frame(width: 34, alignment: .trailing)
                }
            }
            if mostraScadenze, !r.inScadenza.isEmpty {
                Text("IN SCADENZA ENTRO \(RiepilogoPosizioni.giorniScadenza) GIORNI")
                    .font(Tipo.railEtichetta)
                    .foregroundColor(Colori.Analisi.attenzioneTesto)
                    .padding(.top, 6)
                ForEach(scadenze) { p in
                    Button { apri(p) } label: {
                        HStack {
                            Text(p.nome).font(Tipo.tabellaCella).foregroundColor(Colori.Analisi.tabellaTesto).lineLimit(1)
                            Spacer()
                            PillolaStato(posizione: p)
                        }
                    }
                    .buttonStyle(StileSemplice())
                }
                if nascoste > 0 {
                    Text("…e altre \(nascoste) in scadenza.").font(Tipo.kpiNota).foregroundColor(Colori.Analisi.kpiNota)
                }
            }
        }
    }

    // MARK: - Barra di stato

    private var barraStato: some View {
        HStack(spacing: 10) {
            Circle().fill(Colori.Analisi.statoLuce).frame(width: 8, height: 8)
            Text("Calcoli eseguiti in locale · ipotesi: inflazione \(Formati.percentuale(IpotesiCalcolo.inflazione)), rendimenti dichiarati per ogni posizione")
                .font(Tipo.kpiNota)
                .foregroundColor(Colori.Analisi.kpiNota)
            Spacer()
            Text(stato.portafoglio ? "\(stato.posizioni.count) posizioni di \(stato.clienti.count) clienti"
                                   : "\(stato.posizioniCliente(stato.clienteAttivoId).count) posizioni del cliente")
                .font(Tipo.kpiNota)
                .foregroundColor(Colori.Analisi.kpiNota)
        }
        .padding(.horizontal, 12)
        .frame(height: Misure.Analisi.barraStato)
        .bordoAlto(Colori.Analisi.statoBordo)
    }
}

// MARK: - Tabella

struct TabellaPosizioni: View {
    let posizioni: [Posizione]
    let apri: (Posizione) -> Void

    var body: some View {
        VStack(spacing: 0) {
            riga(testa: true) {
                cella("Posizione", larghezza: nil)
                cella("Canale", larghezza: 130)
                cella("Area", larghezza: 116)
                cella("Stato", larghezza: 130)
                cella("Valore", larghezza: 110, destra: true)
                cella("Premi / rate annui", larghezza: 120, destra: true)
                cella("Scadenza", larghezza: 96, destra: true)
            }
            if posizioni.isEmpty {
                Text("Nessuna posizione con questi filtri.")
                    .font(Tipo.tabellaCella)
                    .foregroundColor(Colori.Analisi.kpiNota)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Misure.Analisi.cellaMargine)
            }
            ForEach(Array(posizioni.enumerated()), id: \.element.id) { i, p in
                Button { apri(p) } label: {
                    riga(testa: false, alternata: i % 2 == 1) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(p.nome.isEmpty ? "Senza nome" : p.nome)
                                .font(Tipo.tabellaCellaForte).foregroundColor(Colori.Analisi.tabellaTesto)
                            Text([p.tipologia, p.emittente].filter { !$0.isEmpty }.joined(separator: " · "))
                                .font(Tipo.chip).foregroundColor(Colori.Analisi.kpiNota)
                        }
                        .lineLimit(1)
                        .padding(Misure.Analisi.cellaMargine)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        EtichettaCanale(canale: p.canale, compatta: true)
                            .padding(Misure.Analisi.cellaMargine)
                            .frame(width: 130, alignment: .leading)
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: Tema.Raggio.Dossier.quadratinoArea).fill(Colori.Analisi.area(p.area)).frame(width: 8, height: 8)
                            Text(p.area.nome).font(Tipo.tabellaCella).foregroundColor(Colori.Analisi.tabellaTesto)
                                .lineLimit(1)
                                .fixedSize()
                        }
                        .padding(Misure.Analisi.cellaMargine)
                        .frame(width: 116, alignment: .leading)
                        PillolaStato(posizione: p)
                            .padding(Misure.Analisi.cellaMargine)
                            .frame(width: 130, alignment: .leading)
                        valore(p)
                            .padding(Misure.Analisi.cellaMargine)
                            .frame(width: 110, alignment: .trailing)
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(p.premioAnnuo > 0 ? Formati.euro(p.premioAnnuo) : "—")
                                .font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.tabellaTesto)
                            if p.area.passivo, p.premioAnnuo > 0 {
                                Text("rate").font(Tipo.chip).foregroundColor(Colori.Analisi.kpiNota)
                            }
                        }
                        .padding(Misure.Analisi.cellaMargine)
                        .frame(width: 120, alignment: .trailing)
                        Text(p.scadenza.map { Formati.dataBreve.string(from: $0) } ?? "—")
                            .font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.tabellaTesto)
                            .padding(Misure.Analisi.cellaMargine)
                            .frame(width: 96, alignment: .trailing)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(StileSemplice())
            }
        }
        .contornoTabella()
        // Sull'iPad stretto la tabella scorre in orizzontale invece di uscire dalla scheda
        .scorreSeStretto()
    }

    @ViewBuilder private func valore(_ p: Posizione) -> some View {
        switch p.area {
        case .protezione:
            VStack(alignment: .trailing, spacing: 1) {
                Text(Formati.euro(p.capitaleAssicurato ?? 0)).font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.tabellaTesto)
                Text("capitale").font(Tipo.chip).foregroundColor(Colori.Analisi.kpiNota)
            }
        case .debiti:
            Text("−\(Formati.euro(p.valore))").font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.erroreTesto)
        default:
            Text(p.stato == .proposta ? Formati.euro(p.versamentoIniziale) : Formati.euro(p.valore))
                .font(Tipo.numeroTabella).foregroundColor(Colori.Analisi.tabellaTesto)
        }
    }

    private func riga<C: View>(testa: Bool, alternata: Bool = false, @ViewBuilder _ contenuto: () -> C) -> some View {
        HStack(spacing: 0) { contenuto() }
            .frame(maxWidth: .infinity)
            .background(testa ? Colori.Analisi.tabellaTestaAlto
                        : (alternata ? Colori.Analisi.tabellaAlternata : Colori.Analisi.principale))
            .bordoBasso(testa ? Colori.Analisi.tabellaTestaBordo : Colori.Analisi.tabellaRiga)
    }

    private func cella(_ t: String, larghezza: CGFloat?, destra: Bool = false) -> some View {
        Text(t)
            .font(Tipo.tabellaTesta)
            .foregroundColor(Colori.Analisi.tabellaTesta)
            .padding(Misure.Analisi.testaMargine)
            .frame(width: larghezza, alignment: destra ? .trailing : .leading)
            .frame(maxWidth: larghezza == nil ? .infinity : larghezza, alignment: destra ? .trailing : .leading)
    }
}

/// Una voce della legenda della ripartizione che filtra per area (il quadro del cliente sul Mac, migliorie d'uso 14):
/// un clic sceglie l'area, un secondo clic la toglie; la scelta sul fondo accento al 13%.
struct VoceAreaRipartizione<Riga: View>: View {
    let area: AreaPosizione
    let scelta: Bool
    let scegli: (AreaPosizione) -> Void
    @ViewBuilder let riga: () -> Riga

    var body: some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        let forma = RoundedRectangle(cornerRadius: k.raggioAreaScelta, style: .continuous)
        return Button { scegli(area) } label: {
            riga()
                .padding(.horizontal, k.paddingAreaScelta)
                .background { if scelta { forma.fill(k.fondoAreaScelta) } }
                .contentShape(Rectangle())
        }
        .buttonStyle(StileSemplice())
        .help(scelta ? "Clic di nuovo per vedere tutte le aree" : "Solo le posizioni di \(area.nome)")
        .accessibilityAddTraits(scelta ? AccessibilityTraits.isSelected : AccessibilityTraits())
    }
}

/// Pillola di stato di una posizione.
struct PillolaStato: View {
    let posizione: Posizione

    /// Rifiutata in rosso, rimandata in ambra, le altre neutre.
    private var tonoProposta: Pillola.Tono {
        switch posizione.esito {
        case .rifiutata?: return .errore
        case .rimandata?: return .attenzione
        default: return .neutro
        }
    }

    var body: some View {
        let p = posizione
        switch p.stato {
        case .proposta:
            Pillola(testo: "Proposta · \(p.esito?.nome ?? "Bozza")", tono: tonoProposta)
        case .chiusa:
            Pillola(testo: "Chiusa", tono: .neutro)
        case .inEssere:
            if p.scaduta {
                Pillola(testo: "Scaduta", tono: .errore)
            } else if p.scadeEntro(RiepilogoPosizioni.giorniScadenza), let s = p.scadenza {
                let giorni = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: s).day ?? 0
                #if os(macOS)
                // Migliorie d'uso 15: «Scade tra {n} giorni» per intero (stessa soglia di 90 giorni)
                Pillola(testo: TestiDettaglioPosizione.scadeTra(giorni), tono: .attenzione)
                #else
                Pillola(testo: "Scade tra \(giorni) gg", tono: .attenzione)
                #endif
            } else {
                #if os(macOS)
                // Migliorie d'uso 15: un debito in essere è «Debito», neutro
                if p.area == .debiti {
                    Pillola(testo: "Debito", tono: .neutro)
                } else {
                    Pillola(testo: "In essere", tono: .ok)
                }
                #else
                Pillola(testo: "In essere", tono: .ok)
                #endif
            }
        }
    }
}

/// «Il tuo portafoglio» in cima all'elenco laterale di Posizioni: come «Dossier di» (DossierRail), stesso
/// corpo e stessi margini, con la sola iniziale maiuscola.
private struct TestataPortafoglioRail: View {
    let clienti: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Il tuo portafoglio").font(Tema.Testo.occhiello).foregroundColor(Tema.Colore.inchiostroTerziario)
            Text("Tutti i clienti").font(Tema.Testo.titolo).foregroundColor(Tema.Colore.inchiostro)
            Text("\(clienti) \(clienti == 1 ? "cliente" : "clienti") in rubrica")
                .font(Tema.Testo.didascalia)
                .foregroundColor(Tema.Colore.inchiostroSecondario)
                .lineLimit(1)
        }
        .padding(Tema.Misura.Dossier.testataRail)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tema.Colore.separatore).frame(height: Tema.Misura.filo)
        }
    }
}

extension View {
    /// Bordo destro di un solo lato: di norma il filo da 0,5 pt del tema.
    func bordoDestro(_ colore: Color, spessore: CGFloat = Tema.Misura.filo) -> some View {
        overlay(alignment: .trailing) {
            Rectangle().fill(colore).frame(width: spessore).allowsHitTesting(false)
        }
    }
}
