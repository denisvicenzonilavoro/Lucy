#if os(macOS)
import SwiftUI

// Migliorie d'uso 44 (solo Mac, Design/uso/gruppo-07.md §44): «Aggiorna valori: prima i dubbi».
// - In alto le righe che chiedono una decisione, ognuna con la sua domanda scritta in chiaro: il valore molto più basso
//   (o più alto) di quello di prima, la polizza che non c'è («È nuova»), la posizione da scegliere. Decisa, la riga
//   diventa una riga sola con la spunta verde e «Cambia».
// - Sotto i «Pronti», riconosciuti dal numero di polizza o dal nome, in quattro colonne con la spunta per toglierne uno;
//   i valori più vecchi vanno solo nello storico. In fondo, chiuse, le righe che non si registrano.
// - Il pulsante dice quanti valori registra e diventa blu solo a dubbi risolti; prima fa tremare il primo dubbio.
// - Dopo: prima, dopo e variazione, «Fatto» e «Annulla la registrazione» (il ricordo resta in memoria, il backup fatto
//   prima di registrare resta comunque).
// - Con un cliente scelto l'elenco mostra solo le sue righe, con «Mostra tutto l'elenco».
// L'iPad tiene `PannelloAggiornaValori` (AggiornaValoriVista.swift) finché non arriva il suo giro.

struct PannelloAggiornaValoriMac: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.modoIstantanea) private var modoIstantanea
    @Environment(\.prismaCalmo) private var calmo
    let sessione: AggiornaValori.Sessione

    @State private var scheda: AggiornaValori.Scheda
    @State private var dataComune: Date
    @State private var avviato = false
    // Elenco della compagnia
    @State private var scelte: [Int: String]
    @State private var esclusi: Set<Int> = []
    @State private var decisioni: [Int: AggiornaValori.DecisioneValore]
    @State private var clientiNuove: [Int: String]
    @State private var esitiElenco: [AggiornaValori.Esito] = []
    /// Le righe del cliente scelto (tutte con «Tutti i clienti»).
    @State private var visibili: [AggiornaValori.Esito] = []
    /// Le righe di altri clienti, fuori dalla vista e dalla registrazione.
    @State private var fuori: Set<Int> = []
    @State private var anteprimaElenco = AggiornaValori.Riepilogo()
    @State private var perId: [String: Posizione] = [:]
    /// Il cliente riconosciuto di ogni riga: dalla posizione, dalle candidate o dal nome scritto nel file.
    @State private var clienteRiga: [Int: String] = [:]
    /// Il canale che avrebbe la posizione nuova delle righe non trovate.
    @State private var canaliNuove: [Int: Canale] = [:]
    @State private var nonSiRegistranoAperto = false
    @State private var scosse: CGFloat = 0
    // Griglia dei valori fermi
    @State private var bozze: [String: AggiornaValori.Bozza]
    @State private var ambito: String?
    @State private var canale: Canale?
    @State private var elencoGriglia: [Posizione] = []
    @State private var esitiGriglia: [AggiornaValori.Esito] = []
    @FocusState private var fuoco: CampoGrigliaValori?

    private typealias T = Tema.Apple.Posizioni.AggiornaValori
    private typealias Testi = TestiAggiornaValori

    init(sessione: AggiornaValori.Sessione) {
        self.sessione = sessione
        _scheda = State(initialValue: sessione.scheda)
        _dataComune = State(initialValue: sessione.dataComune)
        _bozze = State(initialValue: sessione.bozze)
        _ambito = State(initialValue: sessione.soloCliente)
        // Dal 25 novembre 2026 (decisione dell'utente) un solo canale, quello di Lucy: nessun filtro di canale
        _canale = State(initialValue: nil)
        _scelte = State(initialValue: sessione.scelte)
        _decisioni = State(initialValue: sessione.decisioni)
        _clientiNuove = State(initialValue: sessione.clientiNuove)
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        VStack(alignment: .leading, spacing: 0) {
            testata
                .padding(EdgeInsets(top: T.margine, leading: T.margine, bottom: T.spazioSezioni, trailing: T.margine))
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: T.spazioSezioni) {
                        if let r = sessione.riepilogo {
                            riepilogo(r)
                        } else if scheda == .elenco {
                            corpoElenco
                        } else {
                            corpoGriglia(proxy)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: T.margine, bottom: T.margine, trailing: T.margine))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            piede
                .padding(T.paddingPiede)
                .overlay(alignment: .top) {
                    Rectangle().fill(T.filo).frame(height: Tema.Apple.Misura.bordo)
                }
        }
        .onAppear(perform: avvia)
        .onDisappear(perform: conserva)
        .onChange(of: sessione.scheda) { scheda = $0 }
        .onChange(of: scheda) { nuova in
            if stato.aggiornaValori?.id == sessione.id, stato.aggiornaValori?.scheda != nuova {
                stato.aggiornaValori?.scheda = nuova
            }
        }
        .onChange(of: scelte) { _ in ricalcolaElenco() }
        .onChange(of: esclusi) { _ in ricalcolaElenco() }
        .onChange(of: decisioni) { _ in ricalcolaElenco() }
        .onChange(of: dataComune) { _ in
            ricalcolaElenco()
            ricalcolaGriglia()
        }
        .onChange(of: ambito) { _ in
            aggiornaVisibili()
            aggiornaElencoGriglia()
        }
        .onChange(of: canale) { _ in aggiornaElencoGriglia() }
    }

    // MARK: - Calcoli (solo quando cambia qualcosa)

    private func avvia() {
        guard !avviato else { return }
        avviato = true
        let iniziali = AggiornaValori.esiti(sessione.righe, posizioni: stato.posizioni, clienti: stato.clienti,
                                            dataComune: dataComune, oggi: Date(), scelte: scelte)
        esclusi = sessione.esclusi ?? AggiornaValori.esclusiIniziali(iniziali)
        ricalcolaElenco()
        aggiornaElencoGriglia()
        if !modoIstantanea, scheda == .griglia, sessione.riepilogo == nil, let primo = elencoGriglia.first {
            DispatchQueue.main.async { fuoco = .valore(primo.id) }
        }
    }

    /// Scelte, decisioni e caselle restano nella sessione quando il dettaglio di una posizione copre il pannello.
    private func conserva() {
        let s = stato
        let id = sessione.id
        let fatte = self.scelte, tolte = self.esclusi, caselle = self.bozze, cliente = self.ambito, scelto = self.canale
        let data = self.dataComune, dette = self.decisioni, nuove = self.clientiNuove
        DispatchQueue.main.async {
            guard s.aggiornaValori?.id == id else { return }
            s.aggiornaValori?.scelte = fatte
            s.aggiornaValori?.esclusi = tolte
            s.aggiornaValori?.bozze = caselle
            s.aggiornaValori?.soloCliente = cliente
            s.aggiornaValori?.canale = scelto
            s.aggiornaValori?.dataComune = data
            s.aggiornaValori?.decisioni = dette
            s.aggiornaValori?.clientiNuove = nuove
        }
    }

    /// Le righe saltate non spostano le altre nella catena della loro posizione, come quelle tolte.
    private var saltate: Set<Int> {
        Set(decisioni.filter { $0.value == .salta }.map(\.key))
    }

    private func ricalcolaElenco() {
        guard !sessione.righe.isEmpty else {
            esitiElenco = []
            visibili = []
            fuori = []
            anteprimaElenco = AggiornaValori.Riepilogo()
            return
        }
        let posizioni = stato.posizioni
        let clienti = stato.clienti
        let esiti = AggiornaValori.esiti(sessione.righe, posizioni: posizioni, clienti: clienti, dataComune: dataComune,
                                         oggi: Date(), scelte: scelte, esclusi: esclusi.union(saltate))
        esitiElenco = esiti
        let servono = Set(esiti.compactMap { $0.posizioneId } + esiti.flatMap { $0.candidate })
        var indice: [String: Posizione] = [:]
        for p in posizioni where servono.contains(p.id) && indice[p.id] == nil { indice[p.id] = p }
        perId = indice
        var diChi: [Int: String] = [:]
        var canaliLetti: [Int: Canale] = [:]
        for e in esiti {
            if let id = e.posizioneId, let p = indice[id] {
                diChi[e.id] = p.clienteId
            } else if let id = e.candidate.first, let p = indice[id] {
                diChi[e.id] = p.clienteId
            } else if let c = ImportaPosizioni.abbina(nome: e.riga.cliente, codiceFiscale: e.riga.codiceFiscale, clienti: clienti) {
                diChi[e.id] = c.id
            }
            if e.stato == .nonTrovata {
                canaliLetti[e.id] = AggiornaValori.canaleNuova(tabella: sessione.tabella, riga: e.id, prodotti: stato.dati.prodotti)
            }
        }
        clienteRiga = diChi
        canaliNuove = canaliLetti
        aggiornaVisibili(esiti: esiti, diChi: diChi, posizioni: posizioni)
    }

    /// Le righe del cliente scelto e l'anteprima di quello che si registra (con i valori appena calcolati, non con
    /// quelli dello stato della vista, che si aggiornano dopo).
    private func aggiornaVisibili(esiti: [AggiornaValori.Esito]? = nil, diChi: [Int: String]? = nil,
                                  posizioni: [Posizione]? = nil) {
        let tutte = esiti ?? esitiElenco
        let chi = diChi ?? clienteRiga
        let mostrate: [AggiornaValori.Esito]
        if let c = ambito {
            mostrate = tutte.filter { chi[$0.id] == c }
        } else {
            mostrate = tutte
        }
        let altri = Set(tutte.map(\.id)).subtracting(mostrate.map(\.id))
        visibili = mostrate
        fuori = altri
        let tolte = AggiornaValori.esclusiPerRegistrare(tutte, decisioni: decisioni, esclusi: esclusi.union(altri))
        anteprimaElenco = AggiornaValori.anteprima(tutte, esclusi: tolte, posizioni: posizioni ?? stato.posizioni)
    }

    /// Le righe che non entrano nella registrazione: tolte, saltate, insolite non dette giuste, a zero, di altri clienti.
    private var escluseOra: Set<Int> {
        AggiornaValori.esclusiPerRegistrare(esitiElenco, decisioni: decisioni, esclusi: esclusi.union(fuori))
    }

    private var aperti: [Int] {
        AggiornaValori.daDecidere(visibili, decisioni: decisioni, scelte: scelte)
    }

    private var nuoveDaAggiungere: [Int: String] {
        AggiornaValori.nuove(visibili, decisioni: decisioni, clienti: clientiNuove)
    }

    private func aggiornaElencoGriglia() {
        elencoGriglia = AggiornaValori.valoriFermi(posizioni: stato.posizioni, clienti: stato.clienti, oggi: Date(),
                                                   clienteId: ambito, canale: canale)
        ricalcolaGriglia()
    }

    private func ricalcolaGriglia() {
        let righe = AggiornaValori.righe(bozze: bozze, elenco: elencoGriglia)
        esitiGriglia = righe.isEmpty ? [] : AggiornaValori.esiti(righe, posizioni: stato.posizioni, clienti: stato.clienti,
                                                                 dataComune: dataComune, oggi: Date())
    }

    /// Una battuta in una casella: la casella e l'esito della sua sola riga (come nel pannello dell'iPad).
    private func scriviBozza(_ b: AggiornaValori.Bozza, per p: Posizione) {
        bozze[p.id] = b
        let sola: [String: AggiornaValori.Bozza] = [p.id: b]
        let righe = AggiornaValori.righe(bozze: sola, elenco: elencoGriglia)
        let attuale = stato.posizioni.filter { $0.id == p.id }
        let nuovi: [AggiornaValori.Esito] = righe.isEmpty ? []
            : AggiornaValori.esiti(righe, posizioni: attuale, clienti: [], dataComune: dataComune, oggi: Date())
        var esiti = esitiGriglia
        esiti.removeAll { $0.riga.posizioneId == p.id }
        for e in nuovi {
            let posto = esiti.firstIndex { $0.riga.id > e.riga.id } ?? esiti.count
            esiti.insert(e, at: posto)
        }
        esitiGriglia = esiti
    }

    private var esclusiGriglia: Set<Int> { AggiornaValori.esclusiIniziali(esitiGriglia) }

    private var nomiClienti: [String: String] {
        stato.ricavato("aggiorna-valori-nomi") { () -> [String: String] in
            var nomi: [String: String] = [:]
            for c in stato.clienti where nomi[c.id] == nil { nomi[c.id] = c.nome }
            return nomi
        }
    }

    private var clientiPerId: [String: Cliente] {
        stato.ricavato("aggiorna-valori-clienti") { () -> [String: Cliente] in
            var elenco: [String: Cliente] = [:]
            for c in stato.clienti where elenco[c.id] == nil { elenco[c.id] = c }
            return elenco
        }
    }

    /// I valori attuali che si registrano adesso (il numero del pulsante e dei «Pronti»).
    private var valoriPronti: Int {
        AggiornaValori.pronte(esitiElenco, decisioni: decisioni, esclusi: esclusi.union(fuori)).count
    }

    private var daRegistrareGriglia: Int { AggiornaValori.daRegistrare(esitiGriglia, esclusi: esclusiGriglia) }

    private func registra() {
        guard !stato.solaLettura else { return }
        if scheda == .elenco {
            guard aperti.isEmpty else {
                scuoti()
                return
            }
            let nuove = nuoveDaAggiungere
            let tolte = escluseOra
            guard AggiornaValori.daRegistrare(esitiElenco, esclusi: tolte) > 0 || !nuove.isEmpty else { return }
            stato.registraValoriInBlocco(esitiElenco, esclusi: tolte, nuove: nuove)
        } else {
            guard daRegistrareGriglia > 0 else { return }
            stato.registraValoriInBlocco(esitiGriglia, esclusi: esclusiGriglia)
        }
    }

    /// Con dubbi aperti il primo trema (niente con «Riduci movimento») e l'avviso dice che cosa fare.
    private func scuoti() {
        if !calmo && !modoIstantanea {
            withAnimation(T.scossa) { scosse += 1 }
        }
        stato.mostraAvviso(Testi.avvisoDecidi)
    }

    private func chiudi() {
        stato.annullaValori = nil
        stato.aggiornaValori = nil
    }

    /// Dopo «Annulla la registrazione»: di nuovo l'elenco, con i conti rifatti sulle posizioni di prima.
    private func annulla() {
        guard stato.annullaRegistrazioneValori() else { return }
        bozze = [:]
        aggiornaElencoGriglia()
        ricalcolaElenco()
    }

    // MARK: - Testata e piede

    private var titoloTestata: String {
        if let r = sessione.riepilogo { return Testi.registrati(r.attuali) }
        return scheda == .elenco ? Testi.titoloElenco : Testi.titoloGriglia
    }

    private var testata: some View {
        HStack(alignment: .center, spacing: T.spazioComandi) {
            VStack(alignment: .leading, spacing: T.spazioTitolo) {
                Text(Testi.occhielloMac(cliente: ambito.flatMap { nomiClienti[$0] }))
                    .carattereApple(T.occhiello)
                    .foregroundColor(T.coloreOcchiello)
                    .lineLimit(1)
                Text(titoloTestata)
                    .carattereApple(T.titolo)
                    .foregroundColor(T.coloreTitolo)
                    .lineLimit(1)
            }
            Spacer(minLength: T.spazioComandi)
            if sessione.riepilogo == nil {
                SegmentatoPillola(selezione: $scheda,
                                  voci: AggiornaValori.Scheda.allCases.map { ($0, Testi.nomeScheda($0)) })
                    .fixedSize()
            }
            Button(action: chiudi) { Label(Testi.chiudi, systemImage: "xmark") }
                .buttonStyle(.apple)
                .keyboardShortcut(.cancelAction)
        }
    }

    @ViewBuilder private var piede: some View {
        if sessione.riepilogo != nil {
            HStack(spacing: T.spazioComandi) {
                Button(Testi.fatto, action: chiudi)
                    .buttonStyle(.applePrimarioGrande)
                    .keyboardShortcut(.defaultAction)
                Button(Testi.annulla, action: annulla)
                    .buttonStyle(.appleGrande)
                    .disabled(!stato.puoAnnullareValori || stato.solaLettura)
                    .help(stato.puoAnnullareValori ? "" : Testi.annullaNonPiu)
                Spacer(minLength: T.spazioComandi)
                Text(Testi.notaCopiaFatta)
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
                    .lineLimit(1)
            }
        } else if scheda == .elenco && sessione.righe.isEmpty {
            HStack { Spacer(minLength: 0) }
        } else {
            HStack(spacing: T.spazioComandi) {
                pulsantePrincipale
                Text(Testi.notaCopia)
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
    }

    /// Con dubbi aperti il pulsante non è blu e dice quante righe decidere; poi «Registra N valori», blu.
    @ViewBuilder private var pulsantePrincipale: some View {
        if scheda == .elenco {
            let dubbi = aperti.count
            let n = valoriPronti
            if dubbi > 0 {
                Button(Testi.pulsanteRegistra(daDecidere: dubbi, valori: n), action: registra)
                    .buttonStyle(.appleGrande)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(stato.solaLettura)
            } else {
                Button(Testi.pulsanteRegistra(daDecidere: 0, valori: n), action: registra)
                    .buttonStyle(.applePrimarioGrande)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled((n == 0 && nuoveDaAggiungere.isEmpty) || stato.solaLettura)
            }
        } else {
            let n = daRegistrareGriglia
            Button(Testi.registra(n), action: registra)
                .buttonStyle(.applePrimarioGrande)
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(n == 0 || stato.solaLettura)
        }
    }

    // MARK: - Elenco della compagnia

    @ViewBuilder private var corpoElenco: some View {
        if sessione.righe.isEmpty {
            elencoVuoto
        } else {
            intestazioneFile
            if visibili.contains(where: { AggiornaValori.dubbio($0) != nil }) {
                sezioneDubbi
            }
            sezionePronti
            let escluse = AggiornaValori.nonSiRegistrano(visibili)
            if !escluse.isEmpty {
                sezioneNonSiRegistrano(escluse)
            }
        }
    }

    private var elencoVuoto: some View {
        VStack(alignment: .leading, spacing: T.spazioSezioni) {
            Text(Testi.vuota)
                .carattereApple(Tema.Apple.Carattere.corpo)
                .foregroundColor(T.coloreTitolo)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: T.spazioComandi) {
                Button { stato.scegliFileValori() } label: { Label(Testi.scegliFile, systemImage: "doc.badge.plus") }
                    .buttonStyle(.applePrimario)
                Button { stato.incollaValoriDaExcel() } label: { Label(Testi.incolla, systemImage: "doc.on.clipboard") }
                    .buttonStyle(.apple)
            }
        }
        .padding(T.paddingCard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(T.superficie, raggio: T.raggioCard)
    }

    /// ««file»: N righe lette», «Scegli un altro file», le righe di altri clienti e la data comune se serve.
    private var intestazioneFile: some View {
        let nome = ambito.flatMap { nomiClienti[$0] }
        return VStack(alignment: .leading, spacing: T.spazioTesta) {
            HStack(alignment: .firstTextBaseline, spacing: T.spazioDubbi) {
                Text(Testi.righeLette(file: sessione.file, n: visibili.count, cliente: nome))
                    .carattereApple(T.sotto)
                    .foregroundColor(T.coloreSotto)
                    .lineLimit(1)
                Button(Testi.scegliAltroFile) { stato.scegliFileValori() }
                    .buttonStyle(.appleSobrio)
                    .fixedSize()
            }
            if !fuori.isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: T.spazioDubbi) {
                    Text(Testi.fuoriCliente(fuori.count))
                        .carattereApple(T.nota)
                        .foregroundColor(T.coloreNota)
                        .lineLimit(1)
                    Button(Testi.mostraTutto) { ambito = nil }
                        .buttonStyle(.appleSobrio)
                        .fixedSize()
                }
            }
            if sessione.righe.contains(where: { $0.data == nil }) {
                HStack(spacing: T.spazioComandi) {
                    Text(Testi.etichettaData)
                        .carattereApple(T.nota)
                        .foregroundColor(T.coloreNota)
                    DatePicker("", selection: $dataComune, displayedComponents: .date)
                        .labelsHidden()
                        .stileDataCampo()
                        .environment(\.locale, Formati.italiano)
                        .fixedSize()
                }
            }
            if sessione.proposta {
                HStack(alignment: .center, spacing: T.spazioComandi) {
                    Text(Testi.proposta)
                        .carattereApple(T.nota)
                        .foregroundColor(T.coloreNota)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: T.spazioComandi)
                    Button(Testi.importaComeNuove) { stato.importaComeNuove() }
                        .buttonStyle(.apple)
                        .disabled(stato.solaLettura)
                        .fixedSize()
                }
            }
        }
    }

    // MARK: Da decidere

    private var sezioneDubbi: some View {
        let dubbi = visibili.filter { AggiornaValori.dubbio($0) != nil }
        let daFare = aperti
        let primo = daFare.first
        return VStack(alignment: .leading, spacing: T.spazioDubbi) {
            HStack(alignment: .center, spacing: T.spazioDubbi) {
                CapsulaStatoApple(testo: daFare.isEmpty ? Testi.deciso : Testi.daDecidere(daFare.count),
                                  tono: daFare.isEmpty ? .ok : .attenzione)
                Text(daFare.isEmpty ? Testi.puoiRegistrare : Testi.primaQueste)
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
                    .lineLimit(1)
            }
            ForEach(dubbi) { e in
                if daFare.contains(e.id) {
                    rigaDubbio(e)
                        .modifier(ScuotiEffetto(ampiezza: e.id == primo && !calmo ? T.ampiezzaScossa : 0,
                                                volte: T.volteScossa, animatableData: scosse))
                } else {
                    rigaDecisa(e)
                }
            }
        }
    }

    /// Il cliente della riga (nil: la persona scritta nel file non è fra i clienti).
    private func cliente(_ e: AggiornaValori.Esito) -> Cliente? {
        clienteRiga[e.id].flatMap { clientiPerId[$0] }
    }

    private func titoloDubbio(_ e: AggiornaValori.Esito) -> String {
        switch AggiornaValori.dubbio(e) {
        case .calo?, .aumento?:
            let nome = e.posizioneId.flatMap { perId[$0] }?.nome ?? e.riga.prodotto
            let chi = cliente(e)?.nome ?? e.riga.cliente
            return [nome, chi].filter { !$0.isEmpty }.joined(separator: " · ")
        case .nuova?:
            return Testi.titoloNonTrovata(e.riga)
        case .scegli?, nil:
            let chi = e.riga.cliente
            return [Testi.titoloNonTrovata(e.riga), chi].filter { !$0.isEmpty }.joined(separator: " · ")
        }
    }

    @ViewBuilder private func avatar(_ e: AggiornaValori.Esito) -> some View {
        if let c = cliente(e) {
            AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: T.avatar)
        } else {
            Image(systemName: "questionmark")
                .carattereApple(T.simboloAvatarVuoto)
                .foregroundColor(T.coloreAvatarVuoto)
                .frame(width: T.avatar, height: T.avatar)
                .background { Circle().fill(T.fondoAvatarVuoto) }
                .accessibilityHidden(true)
        }
    }

    private func rigaDubbio(_ e: AggiornaValori.Esito) -> some View {
        let domanda = Testi.domanda(e, nomeCliente: cliente(e)?.nome, posizioni: perId, clienti: nomiClienti)
        return HStack(alignment: .center, spacing: T.spazioDubbio) {
            avatar(e)
            VStack(alignment: .leading, spacing: T.spazioTitolo) {
                Text(titoloDubbio(e))
                    .carattereApple(T.titoloDubbio)
                    .foregroundColor(T.coloreTitolo)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(domanda)
                    .carattereApple(T.domanda)
                    .foregroundColor(T.coloreDomanda)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            pulsantiDubbio(e)
        }
        .padding(T.paddingDubbio)
        .background {
            RoundedRectangle(cornerRadius: T.raggioDubbio, style: .continuous)
                .fill(T.fondoDubbio)
        }
        .overlay {
            RoundedRectangle(cornerRadius: T.raggioDubbio, style: .continuous)
                .strokeBorder(T.bordoDubbio, lineWidth: Tema.Apple.Misura.bordo)
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private func pulsantiDubbio(_ e: AggiornaValori.Esito) -> some View {
        HStack(spacing: T.spazioDubbi) {
            switch AggiornaValori.dubbio(e) {
            case .calo?, .aumento?:
                Button(Testi.eGiusto) { decisioni[e.id] = .giusto }
                    .buttonStyle(.apple)
            case .nuova?:
                if let c = cliente(e) {
                    Button(Testi.eNuova) {
                        clientiNuove[e.id] = c.id
                        decisioni[e.id] = .nuova
                    }
                    .buttonStyle(.apple)
                } else {
                    Button(Testi.eNuovaMenu) { apriMenuAzioni(vociClienti(per: e.id)) }
                        .buttonStyle(.apple)
                }
            case .scegli?, nil:
                Button(Testi.scegliPosizione) { apriMenuAzioni(vociCandidate(e)) }
                    .buttonStyle(.apple)
            }
            Button(Testi.salta) { decisioni[e.id] = .salta }
                .buttonStyle(.apple)
        }
        .fixedSize()
        .disabled(stato.solaLettura)
    }

    /// «È nuova» di una persona che non è fra i clienti: prima si sceglie di chi è.
    private func vociClienti(per id: Int) -> [VoceMenuAzioni] {
        let elenco = stato.clienti.sorted { $0.nome.localizedStandardCompare($1.nome) == .orderedAscending }
        return elenco.map { c in
            VoceMenuAzioni.azione(c.nome) {
                clientiNuove[id] = c.id
                decisioni[id] = .nuova
            }
        }
    }

    /// Le posizioni fra cui scegliere: nome, cliente e canale.
    private func vociCandidate(_ e: AggiornaValori.Esito) -> [VoceMenuAzioni] {
        let nomi = nomiClienti
        return e.candidate.compactMap { id -> VoceMenuAzioni? in
            guard let p = perId[id] else { return nil }
            let titolo = "\(p.nome) · \(nomi[p.clienteId] ?? "")"
            return VoceMenuAzioni.azione(titolo, spuntata: scelte[e.id] == id) {
                scelte[e.id] = id
                decisioni[e.id] = nil
            }
        }
    }

    /// La frase della decisione presa.
    private func fraseDecisa(_ e: AggiornaValori.Esito) -> String {
        if decisioni[e.id] == .salta { return Testi.decisoSalta }
        switch AggiornaValori.dubbio(e) {
        case .nuova?:
            if let id = clientiNuove[e.id], cliente(e)?.id != id, let nome = nomiClienti[id] {
                return Testi.decisoNuovaDi(cliente: nome)
            }
            return Testi.decisoNuova
        case .scegli?:
            let nome = scelte[e.id].flatMap { perId[$0] }?.nome ?? ""
            return Testi.decisoScelta(nome)
        case .calo?, .aumento?, nil:
            return Testi.decisoGiusto
        }
    }

    private func rigaDecisa(_ e: AggiornaValori.Esito) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: T.spazioDeciso) {
            Image(systemName: "checkmark.circle.fill")
                .carattereApple(T.spunta)
                .foregroundColor(T.coloreSpunta)
                .accessibilityHidden(true)
            (Text(titoloDubbio(e)).font(T.decisoForte.font).foregroundColor(T.coloreTitolo)
                + Text(": " + fraseDecisa(e)))
                .carattereApple(T.deciso)
                .foregroundColor(T.coloreNota)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: T.spazioDeciso)
            Button(Testi.cambia) {
                decisioni[e.id] = nil
                scelte[e.id] = nil
                clientiNuove[e.id] = nil
            }
            .buttonStyle(.appleSobrio)
            .fixedSize()
            .disabled(stato.solaLettura)
        }
        .padding(T.paddingDeciso)
        .overlay(alignment: .bottom) {
            Rectangle().fill(T.filo).frame(height: Tema.Apple.Misura.bordo)
        }
    }

    // MARK: Pronti

    private var sezionePronti: some View {
        // Tutte le righe che si possono registrare, anche quelle tolte con la spunta (per rimetterle)
        let candidate = Set(AggiornaValori.pronte(visibili, decisioni: decisioni, esclusi: []))
        let righe = visibili.filter { candidate.contains($0.id) }
        let tolte = escluseOra
        let storiche = AggiornaValori.soloStorico(visibili, esclusi: esclusi)
        let righeStoriche = visibili.filter { storiche.contains($0.id) }
        let variazione = anteprimaElenco.totale.variazione
        return VStack(alignment: .leading, spacing: T.spazioTesta) {
            HStack(alignment: .center, spacing: T.spazioDubbi) {
                CapsulaStatoApple(testo: Testi.pronti(valoriPronti), tono: .ok)
                Text(Testi.riconosciuti)
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
                    .lineLimit(1)
                Spacer(minLength: T.spazioDubbi)
                Text(Testi.euroSegno(variazione))
                    .carattereApple(T.totale)
                    .foregroundColor(T.segno(variazione))
                    .lineLimit(1)
            }
            if righe.isEmpty {
                Text(Testi.nessunoPronto)
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
                    .padding(T.paddingRiga)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(righe) { e in
                        rigaPronta(e, tolta: tolte.contains(e.id), ultima: e.id == righe.last?.id)
                    }
                }
            }
            ForEach(righeStoriche) { e in
                rigaStorica(e)
            }
        }
    }

    private func rigaPronta(_ e: AggiornaValori.Esito, tolta: Bool, ultima: Bool) -> some View {
        let p = e.posizioneId.flatMap { perId[$0] }
        let v = e.variazione ?? 0
        let prima = e.precedente.map(Formati.euro) ?? "—"
        let dopo = e.riga.valore.map(Formati.euro) ?? "—"
        return HStack(alignment: .center, spacing: T.spazioColonne) {
            HStack(spacing: T.spazioDubbi) {
                Text(p?.nome ?? e.riga.prodotto)
                    .carattereApple(T.rigaForte)
                    .foregroundColor(T.coloreTitolo)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if let p {
                    EtichettaCanaleApple(canale: p.canale, compatta: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(p.flatMap { nomiClienti[$0.clienteId] } ?? e.riga.cliente)
                .carattereApple(T.nota)
                .foregroundColor(T.coloreNota)
                .lineLimit(1)
                .frame(width: T.colonnaCliente, alignment: .leading)
            (Text(prima + " → ") + Text(dopo).font(T.rigaForte.font))
                .carattereApple(T.riga)
                .foregroundColor(T.coloreTitolo)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: T.colonnaPrimaDopo, alignment: .trailing)
                .help(e.data.map(Testi.al) ?? "")
            Text(Testi.euroSegno(v))
                .carattereApple(T.variazione)
                .foregroundColor(T.segno(v))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(width: T.colonnaVariazione, alignment: .trailing)
            Button {
                if esclusi.contains(e.id) { esclusi.remove(e.id) } else { esclusi.insert(e.id) }
            } label: {
                Image(systemName: tolta ? "square" : "checkmark.square.fill")
                    .carattereApple(T.spunta)
                    .foregroundColor(tolta ? T.coloreNota : Tema.Apple.Colore.accento)
            }
            .buttonStyle(.plain)
            .frame(width: T.colonnaSpunta)
            .help(Testi.aiutoSpunta)
            .disabled(stato.solaLettura)
        }
        .padding(T.paddingRiga)
        .opacity(tolta ? T.opacitaTolta : 1)
        .overlay(alignment: .bottom) {
            if !ultima {
                Rectangle().fill(T.filo).frame(height: Tema.Apple.Misura.bordo)
            }
        }
    }

    /// «ⓘ Polizza multiramo · Marco Bianchi: valore del 19 aprile 2026: più vecchio … Va solo nello storico.»
    private func rigaStorica(_ e: AggiornaValori.Esito) -> some View {
        let p = e.posizioneId.flatMap { perId[$0] }
        let titolo = [p?.nome ?? e.riga.prodotto, p.flatMap { nomiClienti[$0.clienteId] } ?? e.riga.cliente]
            .filter { !$0.isEmpty }.joined(separator: " · ")
        return HStack(alignment: .firstTextBaseline, spacing: T.spazioTesta) {
            Image(systemName: "info.circle")
                .carattereApple(T.nota)
                .foregroundColor(T.coloreNota)
                .accessibilityHidden(true)
            (Text(titolo).font(T.decisoForte.font).foregroundColor(T.coloreTitolo)
                + Text(": " + Testi.soloStorico(data: e.data)))
                .carattereApple(T.nota)
                .foregroundColor(T.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, T.spazioDubbi)
    }

    // MARK: Non si registrano

    private func sezioneNonSiRegistrano(_ ids: [Int]) -> some View {
        let insieme = Set(ids)
        let righe = visibili.filter { insieme.contains($0.id) }
        return VStack(alignment: .leading, spacing: T.spazioTesta) {
            Button {
                nonSiRegistranoAperto.toggle()
            } label: {
                HStack(spacing: T.spazioTesta) {
                    Image(systemName: nonSiRegistranoAperto ? "chevron.down" : "chevron.right")
                        .carattereApple(T.freccia)
                        .foregroundColor(T.coloreFreccia)
                    CapsulaStatoApple(testo: Testi.nonSiRegistrano(righe.count), tono: .neutro)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if nonSiRegistranoAperto {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(righe) { e in
                        rigaEsclusa(e)
                    }
                }
            }
        }
    }

    private func rigaEsclusa(_ e: AggiornaValori.Esito) -> some View {
        let p = e.posizioneId.flatMap { perId[$0] }
        let pillola = Testi.pillola(e)
        let titolo = [p?.nome ?? Testi.titoloNonTrovata(e.riga), p.flatMap { nomiClienti[$0.clienteId] } ?? e.riga.cliente]
            .filter { !$0.isEmpty }.joined(separator: " · ")
        let zero = AggiornaValori.zero(e)
        return HStack(alignment: .firstTextBaseline, spacing: T.spazioColonne) {
            VStack(alignment: .leading, spacing: T.spazioTitolo) {
                Text(titolo)
                    .carattereApple(T.rigaForte)
                    .foregroundColor(T.coloreTitolo)
                    .lineLimit(1)
                Text(Testi.spiegazione(e, posizioni: perId, clienti: nomiClienti))
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            CapsulaStatoApple(testo: zero ? Testi.pillolaZero : pillola.testo, tono: zero ? .neutro : pillola.tono)
        }
        .padding(T.paddingRiga)
        .overlay(alignment: .bottom) {
            Rectangle().fill(T.filo).frame(height: Tema.Apple.Misura.bordo)
        }
    }

    // MARK: - Griglia dei valori fermi (cambia solo di stile)

    private func corpoGriglia(_ proxy: ScrollViewProxy) -> some View {
        let nomi = nomiClienti
        var indiceEsiti: [String: AggiornaValori.Esito] = [:]
        for e in esitiGriglia {
            if let id = e.posizioneId, indiceEsiti[id] == nil { indiceEsiti[id] = e }
        }
        let esitiPerPosizione = indiceEsiti
        let oggi = Date()
        return VStack(alignment: .leading, spacing: T.spazioSezioni) {
            HStack(spacing: T.spazioComandi) {
                if let attivo = stato.clienteAttivo {
                    let opzioni: [(String?, String)] = [(nil, Testi.tuttiIClienti), (attivo.id, attivo.nome)]
                    SegmentatoPillola(selezione: $ambito, voci: opzioni)
                        .fixedSize()
                }
                Spacer(minLength: T.spazioComandi)
                Text(Testi.dataComune)
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
                DatePicker("", selection: $dataComune, displayedComponents: .date)
                    .labelsHidden()
                    .stileDataCampo()
                    .environment(\.locale, Formati.italiano)
                    .fixedSize()
            }
            if elencoGriglia.isEmpty {
                HStack(spacing: T.spazioComandi) {
                    Image(systemName: "checkmark.circle.fill")
                        .carattereApple(T.spunta)
                        .foregroundColor(T.coloreSpunta)
                    Text(Testi.grigliaVuota)
                        .carattereApple(Tema.Apple.Carattere.corpo)
                        .foregroundColor(T.coloreTitolo)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(T.paddingCard)
                .frame(maxWidth: .infinity, alignment: .leading)
                .superficieApple(T.superficie, raggio: T.raggioCard)
            } else {
                VStack(alignment: .leading, spacing: T.spazioTitolo) {
                    Text(Testi.conteggioFermi(elencoGriglia.count))
                        .carattereApple(Tema.Apple.Carattere.corpo)
                        .foregroundColor(T.coloreTitolo)
                    Text(Testi.aiutoTastiera)
                        .carattereApple(T.nota)
                        .foregroundColor(T.coloreNota)
                        .fixedSize(horizontal: false, vertical: true)
                }
                tabellaGriglia(nomi: nomi, esiti: esitiPerPosizione, oggi: oggi, proxy: proxy)
                    .strumentiApple()
            }
        }
    }

    private func tabellaGriglia(nomi: [String: String], esiti: [String: AggiornaValori.Esito], oggi: Date,
                                proxy: ScrollViewProxy) -> some View {
        let m = Tema.Misura.AggiornaValori.self
        return TabellaStrumento {
            CellaTesta(testo: Testi.colonnaCliente, larghezza: m.colonnaCliente)
            CellaTesta(testo: Testi.colonnaPosizione)
                .frame(minWidth: m.colonnaPosizioneMinima)
            CellaTesta(testo: Testi.colonnaAttuale, larghezza: m.colonnaAttuale, destra: true)
            CellaTesta(testo: Testi.colonnaNuovo, larghezza: m.campoValore + 2 * m.margineCella, destra: true)
            CellaTesta(testo: Testi.colonnaData, larghezza: m.campoDataGriglia + 2 * m.margineCella)
            CellaTesta(testo: Testi.colonnaVersato, larghezza: m.campoVersato + 2 * m.margineCella)
            CellaTesta(testo: Testi.colonnaVariazione, larghezza: m.colonnaVariazioneGriglia, destra: true)
        } righe: {
            LazyVStack(spacing: 0) {
                ForEach(Array(elencoGriglia.enumerated()), id: \.element.id) { i, p in
                    RigaGriglia(posizione: p,
                                cliente: nomi[p.clienteId] ?? "",
                                fermo: AggiornaValori.fermoDa(p, oggi: oggi),
                                bozza: bozze[p.id] ?? AggiornaValori.Bozza(),
                                esito: esiti[p.id],
                                attiva: fuocoSu(p.id),
                                fuoco: $fuoco,
                                scrivi: { b in scriviBozza(b, per: p) },
                                invio: { avanza(dopo: i, proxy: proxy) })
                        .equatable()
                        .id(p.id)
                }
            }
        }
    }

    private func fuocoSu(_ id: String) -> Bool {
        switch fuoco {
        case .valore(let x)?, .data(let x)?, .versato(let x)?: return x == id
        case nil: return false
        }
    }

    private func avanza(dopo i: Int, proxy: ScrollViewProxy) {
        let prossima = i + 1
        guard prossima < elencoGriglia.count else {
            fuoco = nil
            return
        }
        let id = elencoGriglia[prossima].id
        proxy.scrollTo(id, anchor: .center)
        DispatchQueue.main.async { fuoco = .valore(id) }
    }

    // MARK: - Dopo la registrazione

    private func riepilogo(_ r: AggiornaValori.Riepilogo) -> some View {
        let nomi = nomiClienti
        let toccate = Set(r.posizioni)
        var indice: [String: Posizione] = [:]
        for p in stato.posizioni where toccate.contains(p.id) && indice[p.id] == nil { indice[p.id] = p }
        let elenco = r.posizioni.compactMap { indice[$0] }
        let mostrate = Array(elenco.prefix(Tema.Misura.AggiornaValori.riepilogoMassimo))
        return VStack(alignment: .leading, spacing: T.spazioSezioni) {
            Text(Testi.frasiDopo(storico: r.storico, nuove: r.nuove))
                .carattereApple(Tema.Apple.Carattere.corpoGrande)
                .foregroundColor(T.coloreSotto)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: T.spazioRiquadri) {
                RiquadroValoriMac(titolo: Testi.prima, valore: r.totale.prima, formato: .euro,
                                  nota: Testi.contoPosizioni(r.totale.posizioni), colore: T.coloreTitolo, indice: 0)
                RiquadroValoriMac(titolo: Testi.dopo, valore: r.totale.dopo, formato: .euro,
                                  nota: "", colore: T.coloreTitolo, indice: 1)
                RiquadroValoriMac(titolo: Testi.variazione, valore: r.totale.variazione,
                                  formato: .personalizzato(TestiAggiornaValori.euroSegno),
                                  nota: r.totale.variazionePct.map(Testi.percentualeSegno) ?? "",
                                  colore: T.segno(r.totale.variazione), indice: 2)
            }
            if !mostrate.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(mostrate.enumerated()), id: \.element.id) { i, p in
                        rigaRegistrata(p, cliente: nomi[p.clienteId] ?? "", ultima: i == mostrate.count - 1)
                    }
                }
                .padding(T.paddingCard)
                .superficieApple(T.superficie, raggio: T.raggioCard)
                if elenco.count > mostrate.count {
                    Text(Testi.altre(elenco.count - mostrate.count))
                        .carattereApple(T.nota)
                        .foregroundColor(T.coloreNota)
                }
            }
        }
    }

    private func rigaRegistrata(_ p: Posizione, cliente: String, ultima: Bool) -> some View {
        HStack(alignment: .center, spacing: T.spazioColonne) {
            HStack(spacing: T.spazioDubbi) {
                Text(p.nome)
                    .carattereApple(T.rigaForte)
                    .foregroundColor(T.coloreTitolo)
                    .lineLimit(1)
                EtichettaCanaleApple(canale: p.canale, compatta: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(cliente)
                .carattereApple(T.nota)
                .foregroundColor(T.coloreNota)
                .lineLimit(1)
                .frame(width: T.colonnaCliente, alignment: .leading)
            VStack(alignment: .trailing, spacing: T.spazioTitolo) {
                Text(p.controvalore.map(Formati.euro) ?? "—")
                    .carattereApple(T.rigaForte)
                    .foregroundColor(T.coloreTitolo)
                Text(p.dataValore.map(Testi.al) ?? "")
                    .carattereApple(T.nota)
                    .foregroundColor(T.coloreNota)
            }
            .frame(width: T.colonnaPrimaDopo, alignment: .trailing)
            Button(Testi.apri) { stato.apriPosizione(p) }
                .buttonStyle(.appleSobrio)
                .fixedSize()
                .frame(width: T.colonnaVariazione, alignment: .trailing)
        }
        .padding(T.paddingRiga)
        .overlay(alignment: .bottom) {
            if !ultima {
                Rectangle().fill(T.filo).frame(height: Tema.Apple.Misura.bordo)
            }
        }
    }
}

// MARK: - Un riquadro del riepilogo

/// «Prima», «Dopo», «Variazione»: l'etichetta, la cifra che conta fino al valore e la nota.
private struct RiquadroValoriMac: View {
    let titolo: String
    let valore: Double
    let formato: FormatoCifra
    let nota: String
    let colore: Color
    let indice: Int

    private typealias T = Tema.Apple.Posizioni.AggiornaValori

    var body: some View {
        VStack(alignment: .leading, spacing: T.spazioTesta) {
            Text(titolo)
                .carattereApple(T.etichettaRiquadro)
                .foregroundColor(T.coloreNota)
                .lineLimit(1)
            NumeroCheConta(valore, formato: formato, indice: indice)
                .carattereApple(T.cifraRiquadro)
                .foregroundColor(colore)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(nota.isEmpty ? " " : nota)
                .carattereApple(T.nota)
                .foregroundColor(nota.isEmpty ? Color.clear : T.coloreNota)
                .lineLimit(1)
        }
        .padding(T.paddingRiquadro)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(T.superficie, raggio: T.raggioCard)
    }
}
#endif
