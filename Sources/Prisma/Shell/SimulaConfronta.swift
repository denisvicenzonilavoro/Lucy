#if os(macOS)
import SwiftUI

// Migliorie d'uso 64 «Simula e confronta: prima la frase» (Design/uso/gruppo-12.md §64, template righe 5024-5064).
// Sul Mac simulatore, scenari e confronto di Analisi 360 sono una vista sola: a sinistra «Una strada | Due a confronto»,
// la strada (o le due strade) come righe che si toccano, tre cursori per i soldi (uguali per tutte e due) e le ipotesi in
// una riga; a destra prima la frase, poi «Se va diversamente», «Anno per anno, al netto» e la fila dei pulsanti. Le
// cifre sono di `MotoreProiezione` (attraverso `MotoreSimulaConfronta`), solo per le strade scelte e in `ricavato`.
// Lo stato della vista (modo, strade, soldi, ipotesi, ipotesi mia) sta in StatoShell, in memoria; le ipotesi salvate
// sono `Simulazione` come prima. iPhone e iPad tengono SimulatoreIpotesi, ScenariSalvati e ConfrontoIpotesi.

// MARK: - Lo stato

extension StatoShell {
    /// I soldi di partenza di un cliente: le ipotesi dell'area investimenti dell'Analisi 360 (come «Apri nel simulatore»).
    func soldiInizialiSimula(_ cliente: String) -> SoldiSimula {
        let i = analisi360(cliente).investimenti
        return SoldiSimula(capitale: i.capitale, mensile: i.versamentoMensile, anni: max(1, i.anni))
    }

    /// Vero se strade, soldi e ipotesi in memoria valgono per il cliente attivo.
    var simulaDelCliente: Bool { clienteSimula == clienteAttivoId }

    func soldiSimulaCorrenti() -> SoldiSimula {
        simulaDelCliente ? soldiSimula : soldiInizialiSimula(clienteAttivoId)
    }

    func ipotesiSimulaCorrenti() -> IpotesiSimula { simulaDelCliente ? ipotesiSimula : IpotesiSimula() }

    func liberaSimulaCorrente() -> IpotesiLibera? { simulaDelCliente ? stradaLibera : nil }

    /// Prima di scrivere: se lo stato valeva per un altro cliente, si riparte da capo per quello attivo.
    func adottaSimula() {
        let id = clienteAttivoId
        guard clienteSimula != id else { return }
        soldiSimula = soldiInizialiSimula(id)
        ipotesiSimula = IpotesiSimula()
        stradaA = nil
        stradaB = nil
        stradaLibera = nil
        clienteSimula = id
    }

    /// Le strade del cliente attivo (una volta per dati dei calcoli e ipotesi mia: nessuna proiezione qui).
    func opzioniSimula() -> [OpzioneStrada] {
        let id = clienteAttivoId
        let libera = liberaSimulaCorrente()
        return ricavato("simula-opzioni|\(id)|\(String(describing: libera))") {
            MotoreSimulaConfronta.opzioni(posizioni: posizioniCliente(id).filter { $0.stato != .chiusa },
                                          prodotti: dati.prodotti, simulazioni: simulazioniCliente(id),
                                          libera: libera, orizzonteCliente: cliente(id)?.profilo.orizzonteAnni)
        }
    }

    /// Le due strade in vista: quelle scelte se ci sono ancora, altrimenti quelle di partenza (A e B mai uguali).
    func stradeSimula(_ opzioni: [OpzioneStrada]) -> (a: StradaSimula, b: StradaSimula) {
        func valida(_ s: StradaSimula?) -> StradaSimula? {
            guard simulaDelCliente, let s, opzioni.contains(where: { $0.strada == s }) else { return nil }
            return s
        }
        let a = valida(stradaA) ?? MotoreSimulaConfronta.predefinitaA(opzioni)
        var b = valida(stradaB) ?? MotoreSimulaConfronta.predefinitaB(opzioni, a: a)
        if b == a { b = MotoreSimulaConfronta.predefinitaB(opzioni, a: a) }
        return (a, b)
    }

    /// L'opzione di una strada (il conto se non c'è più).
    func opzioneSimula(_ s: StradaSimula, in opzioni: [OpzioneStrada]) -> OpzioneStrada {
        opzioni.first { $0.strada == s } ?? MotoreSimulaConfronta.conto
    }

    /// Le cifre di una strada con i soldi e le ipotesi di adesso (soldi e ipotesi nella chiave: non sono dati dei calcoli).
    func esitoSimula(_ o: OpzioneStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> EsitoStrada {
        ricavato("simula-esito|\(clienteAttivoId)|\(o.strada)|\(o.rendimento)|\(o.costoIngresso)|\(o.costoAnnuo)|\(soldi)|\(ipotesi)") {
            MotoreSimulaConfronta.esito(o, soldi: soldi, ipotesi: ipotesi)
        }
    }

    /// Sceglie una strada per A (o per B): se l'altra è proprio quella, le due si scambiano.
    func scegliStradaSimula(_ nuova: StradaSimula, perA: Bool) {
        let attuali = stradeSimula(opzioniSimula())
        adottaSimula()
        let r = MotoreSimulaConfronta.scegli(nuova, perA: perA, a: attuali.a, b: attuali.b)
        if stradaA != r.a { stradaA = r.a }
        if stradaB != r.b { stradaB = r.b }
    }

    /// Cambia i soldi comuni (partendo da quelli in vista).
    func cambiaSoldiSimula(_ cambia: (inout SoldiSimula) -> Void) {
        var s = soldiSimulaCorrenti()
        adottaSimula()
        cambia(&s)
        if soldiSimula != s { soldiSimula = s }
    }

    /// Cambia tasse e inflazione comuni.
    func cambiaIpotesiSimula(_ cambia: (inout IpotesiSimula) -> Void) {
        var i = ipotesiSimulaCorrenti()
        adottaSimula()
        cambia(&i)
        if ipotesiSimula != i { ipotesiSimula = i }
    }

    /// «Un'ipotesi mia…»: parte da rendimento, costi e canale della strada di adesso, se non c'è già.
    func preparaLiberaSimula(da o: OpzioneStrada, perA: Bool) {
        adottaSimula()
        if stradaLibera == nil {
            stradaLibera = IpotesiLibera(nome: TestiSimulaConfronta.ipotesiMia, rendimento: o.rendimento,
                                         costoIngresso: o.costoIngresso, costoAnnuo: o.costoAnnuo, canale: o.canale)
        }
        scegliStradaSimula(.libera, perA: perA)
    }

    /// Riapre un'ipotesi salvata: la sua strada in A, i suoi soldi e le sue ipotesi.
    func riapriSimulazioneSalvata(_ s: Simulazione) {
        adottaSimula()
        soldiSimula = SoldiSimula(capitale: s.capitale, mensile: s.versamentoMensile, anni: max(1, s.anni))
        ipotesiSimula = IpotesiSimula(tasse: s.aliquota, inflazione: s.inflazione)
        scegliStradaSimula(.simulazione(s.id), perA: true)
    }

    /// Una bozza del simulatore di prima (da una posizione, una scheda, un obiettivo, un'area, Vera) entra come strada
    /// A di «Una strada»: la posizione, l'ipotesi salvata, la scheda del catalogo o un'ipotesi mia con i suoi numeri;
    /// capitale, versamento e anni vanno nei cursori, tasse e inflazione nelle ipotesi. Poi la bozza si consuma.
    func consumaBozzaSimulazione() {
        guard let b = bozzaSimulazione else { return }
        bozzaSimulazione = nil
        clienteSimula = b.clienteId
        soldiSimula = SoldiSimula(capitale: b.capitale, mensile: b.versamentoMensile, anni: max(1, b.anni))
        ipotesiSimula = IpotesiSimula(tasse: b.aliquota, inflazione: b.inflazione)
        stradaB = nil
        stradaLibera = nil
        if let pid = b.posizioneId, posizioniCliente(b.clienteId).contains(where: { $0.id == pid }) {
            stradaA = .posizione(pid)
        } else if dati.simulazioni.contains(where: { $0.id == b.id }) {
            stradaA = .simulazione(b.id)
        } else if let p = dati.prodotti.first(where: { $0.nome == b.titolo && $0.canale == b.canale }) {
            stradaA = .prodotto(p.id)
        } else {
            stradaLibera = IpotesiLibera(nome: b.titolo, rendimento: b.rendimento, costoIngresso: b.costoIngresso,
                                         costoAnnuo: b.costoAnnuo, canale: b.canale)
            stradaA = .libera
        }
    }

    /// «Confronta» da una posizione (o da uno scenario): le voci del confronto di prima diventano le due strade.
    func importaConfrontoInSimula() {
        func strada(_ v: VoceConfronto?) -> StradaSimula? {
            switch v {
            case .posizione(let id)?: return .posizione(id)
            case .simulazione(let id)?: return .simulazione(id)
            case nil: return nil
            }
        }
        guard confrontoA != nil || confrontoB != nil else { return }
        adottaSimula()
        if let a = strada(confrontoA) { stradaA = a }
        if let b = strada(confrontoB) { stradaB = b }
    }

    /// L'id di un'ipotesi salvata con i parametri di questa strada (per il prospetto): quella già salvata con le
    /// stesse ipotesi, se c'è, altrimenti una nuova nel dossier.
    func simulazioneSalvataPer(_ e: EsitoStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> String {
        let id = clienteAttivoId
        let candidata = MotoreSimulaConfronta.simulazione(e, soldi: soldi, ipotesi: ipotesi, cliente: id,
                                                          adesso: Appuntamento.alMinuto(Date()))
        let salvate = simulazioniCliente(id)
        if case .simulazione(let sid) = e.opzione.strada,
           let s = salvate.first(where: { $0.id == sid }), s.stesseIpotesi(candidata) {
            return s.id
        }
        if let s = salvate.first(where: { $0.titolo == candidata.titolo && $0.posizioneId == candidata.posizioneId
                                          && $0.stesseIpotesi(candidata) }) {
            return s.id
        }
        salvaSimulazione(candidata)
        return candidata.id
    }

    /// «Confronta con quello che ha» dalla scheda del catalogo (miglioria 63): «Due a confronto» con la scheda in A e in B
    /// la prima posizione in essere della stessa area (altrimenti «Lasciare i soldi sul conto»).
    func confrontaProdottoInSimula(_ p: Prodotto) {
        adottaSimula()
        let opzioni = opzioniSimula()
        let strade = Set(opzioni.map(\.strada))
        if strade.contains(.prodotto(p.id)) { stradaA = .prodotto(p.id) }
        let stessa = opzioni.first { o in
            guard o.gruppo == .haGia, case .posizione(let id) = o.strada else { return false }
            return posizioniCliente(clienteAttivoId).contains { $0.id == id && $0.area == p.area }
        }
        stradaB = stessa?.strada ?? .conto
        if stradaB == stradaA { stradaB = .conto }
        if modoSimula != .due { modoSimula = .due }
        scegliStrumentoAnalisi(.simulaConfronta)
        apri(.analisi360)
    }

    /// Il nome breve del cliente attivo (frasi e pulsanti).
    var nomeClienteSimula: String { clienteAttivo.map { StatoShell.nomeBreve($0) } ?? "" }
}

// MARK: - La vista

/// «Simula e confronta» sul Mac: la riga delle viste di Analisi 360 in testa, poi le due colonne.
struct SimulaConfrontaMac: View {
    @Environment(StatoShell.self) var stato
    private typealias S = Tema.Apple.SimulaConfronta

    var body: some View {
        let _ = ContaCorpi.segna()
        VStack(spacing: 0) {
            // La terza voce del segmentato delle viste è accesa: le due porte (barra laterale e segmentato) sono lo stesso stato
            RigaVisteAnalisi360(vista: Bindable(stato).vistaAnalisi360, diProva: false, modoCliente: stato.inModoCliente,
                                apriImpostazioni: {})
                .testataColonna()
            ColonneAffiancate(larghezza: S.larghezzaColonna) {
                ColonnaSinistraSimula()
            } flessibile: {
                ColonnaDestraSimula()
            }
        }
    }
}

/// La colonna di sinistra: modalità, strade, soldi, ipotesi.
private struct ColonnaSinistraSimula: View {
    @Environment(StatoShell.self) var stato
    @State private var ipotesiAperte = false
    private typealias S = Tema.Apple.SimulaConfronta
    private typealias T = TestiSimulaConfronta

    var body: some View {
        let _ = ContaCorpi.segna()
        let opzioni = stato.opzioniSimula()
        let strade = stato.stradeSimula(opzioni)
        let due = stato.modoSimula == .due
        ScrollView {
            VStack(alignment: .leading, spacing: S.spazioBlocchi) {
                SegmentatoPillola(selezione: Bindable(stato).modoSimula,
                                  voci: [(ModoSimula.una, T.unaStrada), (ModoSimula.due, T.dueAConfronto)])
                    .fixedSize()
                occhiello(due ? T.leDueStrade : T.laStrada)
                RigaStradaSimula(lettera: due ? "A" : nil, colore: S.serieA,
                                 opzione: stato.opzioneSimula(strade.a, in: opzioni), opzioni: opzioni, perA: true)
                if due {
                    RigaStradaSimula(lettera: "B", colore: S.serieB,
                                     opzione: stato.opzioneSimula(strade.b, in: opzioni), opzioni: opzioni, perA: false)
                }
                occhiello(due ? T.iSoldiUguali : T.iSoldi)
                    .padding(.top, S.spazioOcchiello)
                soldi
                Rectangle().fill(S.filo).frame(height: Tema.Misura.filo)
                ipotesi
            }
            .padding(S.paddingColonna)
        }
    }

    private func occhiello(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(S.occhiello)
            .foregroundColor(S.coloreOcchiello)
    }

    /// I tre cursori (decisione 64-c: intervalli e fine del cursore di prima, passi del template). Comandi «fermi»:
    /// trascinandone uno si ridisegna solo lui.
    @ViewBuilder private var soldi: some View {
        let s = stato.soldiSimulaCorrenti()
        ComandoSimulatoreFermo(etichetta: T.quantoOggi,
                               valore: Binding(get: { s.capitale }, set: { v in stato.cambiaSoldiSimula { $0.capitale = max(0, v) } }),
                               unita: "€", intervallo: 0...10_000_000, passo: 1_000, fineCursore: 500_000)
            .equatable()
        ComandoSimulatoreFermo(etichetta: T.quantoMese,
                               valore: Binding(get: { s.mensile }, set: { v in stato.cambiaSoldiSimula { $0.mensile = max(0, v) } }),
                               unita: "€", intervallo: 0...100_000, passo: 50, fineCursore: 3_000)
            .equatable()
        ComandoSimulatoreFermo(etichetta: T.quantiAnni,
                               valore: Binding(get: { Double(s.anni) },
                                               set: { v in stato.cambiaSoldiSimula { $0.anni = max(1, Int(v.rounded())) } }),
                               unita: "anni", intervallo: 1...40, passo: 1)
            .equatable()
    }

    /// Le ipotesi in una riga, con «Cambia» per tasse e inflazione.
    private var ipotesi: some View {
        let i = stato.ipotesiSimulaCorrenti()
        return VStack(alignment: .leading, spacing: S.spazioOcchiello) {
            Text(T.ipotesi(i))
                .carattereApple(S.rigaIpotesi)
                .foregroundColor(S.coloreRigaIpotesi)
                .fixedSize(horizontal: false, vertical: true)
            Button(T.cambia) { ipotesiAperte = true }
                .buttonStyle(.appleSobrio)
                .popover(isPresented: $ipotesiAperte, arrowEdge: .trailing) {
                    EditorIpotesiSimula()
                        .environment(stato)
                        .strumentiApple()
                }
        }
    }
}

/// Il popover di «Cambia»: tasse e inflazione comuni (i comandi del simulatore di prima).
private struct EditorIpotesiSimula: View {
    @Environment(StatoShell.self) var stato
    private typealias S = Tema.Apple.SimulaConfronta
    private typealias T = TestiSimulaConfronta

    var body: some View {
        let i = stato.ipotesiSimulaCorrenti()
        VStack(alignment: .leading, spacing: S.spazioBlocchi) {
            Text(T.ipotesiComuni)
                .carattereApple(S.occhiello)
                .foregroundColor(S.coloreOcchiello)
            ComandoSimulatoreFermo(etichetta: T.tasse,
                                   valore: Binding(get: { i.tasse }, set: { v in stato.cambiaIpotesiSimula { $0.tasse = v } }),
                                   unita: "%", intervallo: 0...43, passo: 0.5, decimali: 1)
                .equatable()
            ComandoSimulatoreFermo(etichetta: T.inflazione,
                                   valore: Binding(get: { i.inflazione }, set: { v in stato.cambiaIpotesiSimula { $0.inflazione = v } }),
                                   unita: "%", intervallo: 0...10, passo: 0.1, decimali: 1)
                .equatable()
        }
        .padding(S.paddingColonna)
        .frame(width: S.larghezzaEditor)
    }
}

/// Una strada come riga che si tocca: tondino col colore (e la lettera con due strade), nome, provenienza, rendimento e
/// costo, etichetta compatta del canale, freccia. Il tocco apre il menu delle strade.
private struct RigaStradaSimula: View {
    @Environment(StatoShell.self) var stato
    let lettera: String?
    let colore: Color
    let opzione: OpzioneStrada
    let opzioni: [OpzioneStrada]
    let perA: Bool
    @State private var aperto = false
    @State private var modificaMia = false
    private typealias S = Tema.Apple.SimulaConfronta
    private typealias T = TestiSimulaConfronta

    var body: some View {
        Button {
            modificaMia = false
            aperto = true
        } label: {
            riga
        }
        .buttonStyle(.plain)
        .help(T.aiutoStrada)
        .popover(isPresented: $aperto, arrowEdge: .trailing) {
            Group {
                if modificaMia { EditorIpotesiMia() } else { menu }
            }
            .environment(stato)
            .strumentiApple()
        }
    }

    private var riga: some View {
        HStack(spacing: S.spazioStrada) {
            ZStack {
                Circle().fill(colore)
                if let lettera {
                    Text(lettera)
                        .carattereApple(S.letteraStrada)
                        .foregroundColor(S.coloreLettera)
                }
            }
            .frame(width: S.tondinoStrada, height: S.tondinoStrada)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Tema.Apple.Misura.Spazio.etichettaCanale) {
                    Text(opzione.nome)
                        .carattereApple(S.nomeStrada)
                        .foregroundColor(S.coloreNomeStrada)
                        .lineLimit(1)
                    // Canale sempre riconoscibile
                    if let c = opzione.canale { EtichettaCanale(canale: c, compatta: true) }
                }
                Text(T.riga(opzione))
                    .carattereApple(S.rigaStrada)
                    .foregroundColor(S.coloreRigaStrada)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.down")
                .font(S.frecciaStrada.font)
                .foregroundColor(S.coloreRigaStrada)
        }
        .padding(S.paddingStrada)
        .background(RoundedRectangle(cornerRadius: S.raggioStrada, style: .continuous).fill(S.fondoStrada))
        .contentShape(RoundedRectangle(cornerRadius: S.raggioStrada, style: .continuous))
    }

    /// Il menu: le strade raggruppate (Ce l'ha già, Proposte, Dal catalogo, Ipotesi salvate, Ipotesi mia, Non fare
    /// niente) e, in fondo, «Un'ipotesi mia…».
    private var menu: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(GruppoStrada.allCases, id: \.self) { g in
                    let voci = opzioni.filter { $0.gruppo == g }
                    if !voci.isEmpty {
                        Text(g.titolo)
                            .carattereApple(S.gruppoMenu)
                            .foregroundColor(S.coloreOcchiello)
                            .padding(.top, S.spazioOcchiello)
                            .padding(.horizontal, S.paddingVoceMenu.leading)
                        ForEach(voci) { o in voce(o) }
                    }
                }
                Rectangle().fill(S.filo).frame(height: Tema.Misura.filo)
                    .padding(.vertical, S.spazioOcchiello)
                Button {
                    stato.preparaLiberaSimula(da: opzione, perA: perA)
                    modificaMia = true
                } label: {
                    Text(T.ipotesiMiaMenu)
                        .carattereApple(S.voceMenu)
                        .foregroundColor(S.coloreNomeStrada)
                        .padding(S.paddingVoceMenu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(S.paddingMenu)
        }
        .frame(width: S.larghezzaMenu)
        .frame(maxHeight: S.altezzaMenu)
    }

    private func voce(_ o: OpzioneStrada) -> some View {
        let scelta = o.strada == opzione.strada
        return Button {
            stato.scegliStradaSimula(o.strada, perA: perA)
            aperto = false
        } label: {
            HStack(spacing: S.spazioStrada) {
                Text(o.nome)
                    .carattereApple(S.voceMenu)
                    .foregroundColor(S.coloreNomeStrada)
                    .lineLimit(1)
                Spacer(minLength: S.spazioStrada)
                Text(o.provenienza)
                    .carattereApple(S.provenienzaMenu)
                    .foregroundColor(S.coloreRigaStrada)
                    .lineLimit(1)
            }
            .padding(S.paddingVoceMenu)
            .background(RoundedRectangle(cornerRadius: S.raggioStrada, style: .continuous)
                .fill(scelta ? S.fondoVoceScelta : Color.clear))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// «Un'ipotesi mia» (decisioni 64-d e 64-f): rendimento, costo d'ingresso, costo annuo e canale, solo in memoria.
private struct EditorIpotesiMia: View {
    @Environment(StatoShell.self) var stato
    private typealias S = Tema.Apple.SimulaConfronta
    private typealias T = TestiSimulaConfronta

    var body: some View {
        let l = stato.stradaLibera ?? IpotesiLibera()
        VStack(alignment: .leading, spacing: S.spazioBlocchi) {
            Text(T.ipotesiMia)
                .carattereApple(S.occhiello)
                .foregroundColor(S.coloreOcchiello)
            ComandoSimulatoreFermo(etichetta: T.rendimentoMia,
                                   valore: Binding(get: { l.rendimento }, set: { v in stato.stradaLibera?.rendimento = v }),
                                   unita: "%", intervallo: -10...20, passo: 0.1, decimali: 1)
                .equatable()
            ComandoSimulatoreFermo(etichetta: T.costoIngressoMia,
                                   valore: Binding(get: { l.costoIngresso }, set: { v in stato.stradaLibera?.costoIngresso = v }),
                                   unita: "%", intervallo: 0...10, passo: 0.5, decimali: 1)
                .equatable()
            ComandoSimulatoreFermo(etichetta: T.costoAnnuoMia,
                                   valore: Binding(get: { l.costoAnnuo }, set: { v in stato.stradaLibera?.costoAnnuo = v }),
                                   unita: "%", intervallo: 0...5, passo: 0.05, decimali: 2)
                .equatable()
            VStack(alignment: .leading, spacing: S.spazioOcchiello) {
                Text(T.canaleMia)
                    .carattereApple(S.rigaIpotesi)
                    .foregroundColor(S.coloreRigaIpotesi)
                SegmentiAnalisiFermi(opzioni: [(Canale?.none, T.canaleNessuno), (Canale?.some(.alleanza), T.canaleAlleanza),
                                               (Canale?.some(.indipendente), T.canaleIndipendente)],
                                     selezione: Binding(get: { l.canale }, set: { v in stato.stradaLibera?.canale = v }))
                    .equatable()
            }
        }
        .padding(S.paddingColonna)
        .frame(width: S.larghezzaEditor)
    }
}

/// La colonna di destra: prima la frase, poi le cifre.
private struct ColonnaDestraSimula: View {
    @Environment(StatoShell.self) var stato
    @State private var mostraMetodo = false
    @State private var daRinominare: Simulazione?
    @State private var nuovoNome = ""
    private typealias S = Tema.Apple.SimulaConfronta
    private typealias T = TestiSimulaConfronta

    var body: some View {
        let _ = ContaCorpi.segna()
        let opzioni = stato.opzioniSimula()
        let strade = stato.stradeSimula(opzioni)
        let soldi = stato.soldiSimulaCorrenti()
        let ipotesi = stato.ipotesiSimulaCorrenti()
        let a = stato.esitoSimula(stato.opzioneSimula(strade.a, in: opzioni), soldi: soldi, ipotesi: ipotesi)
        ScrollView {
            VStack(alignment: .leading, spacing: S.spazioBlocchi) {
                if stato.modoSimula == .due {
                    let b = stato.esitoSimula(stato.opzioneSimula(strade.b, in: opzioni), soldi: soldi, ipotesi: ipotesi)
                    due(a, b, soldi: soldi, ipotesi: ipotesi)
                } else {
                    una(a, soldi: soldi, ipotesi: ipotesi)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(S.paddingColonna)
        }
        .alert(T.rinominaTitolo, isPresented: Binding(get: { daRinominare != nil }, set: { if !$0 { daRinominare = nil } })) {
            TextField(T.nome, text: $nuovoNome)
            Button(T.annulla, role: .cancel) { daRinominare = nil }
            Button(T.conferma) {
                let nome = nuovoNome.trimmingCharacters(in: .whitespacesAndNewlines)
                if var s = daRinominare, !nome.isEmpty {
                    s.titolo = nome
                    stato.salvaSimulazione(s)
                }
                daRinominare = nil
            }
        }
    }

    // MARK: Una strada

    @ViewBuilder private func una(_ e: EsitoStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> some View {
        VStack(alignment: .leading, spacing: S.spazioFrase) {
            occhiello(T.occhielloUna(e.opzione.nome))
            (Text(T.fraseUnaPrima(anni: soldi.anni))
                + Text(T.circa(e.esito.netto)).foregroundColor(S.cifraFrase)
                + Text(T.fraseUnaDopo))
                .carattereApple(S.fraseUna)
                .foregroundColor(S.coloreFrase)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(T.fraseUna(e, anni: soldi.anni))
            Text(T.sottoFraseUna(e))
                .carattereApple(S.sottoFrase)
                .foregroundColor(S.coloreSottoFrase)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(S.paddingFrase)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(S.superficie)
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: S.spazioBlocchi) {
                seVaDiversamente(e).frame(width: S.larghezzaSeVa)
                graficoUna(e, anni: soldi.anni).frame(minWidth: S.larghezzaSeVa)
            }
            VStack(alignment: .leading, spacing: S.spazioBlocchi) {
                seVaDiversamente(e)
                graficoUna(e, anni: soldi.anni)
            }
        }
        if mostraMetodo {
            NotaMetodo(testo: T.metodo, titolo: T.titoloMetodo)
        }
        filaUna(e, soldi: soldi, ipotesi: ipotesi)
        salvate
    }

    private func seVaDiversamente(_ e: EsitoStrada) -> some View {
        let massimo = max(1, e.scenari.map { max(0, $0.esito.netto) }.max() ?? 1)
        let kid = e.parametri.scartiKID != nil
        let colori = [S.male, S.previsto, S.bene]
        return VStack(alignment: .leading, spacing: S.spazioSeVa) {
            occhiello(T.seVaDiversamente)
            ForEach(Array(e.scenari.enumerated()), id: \.offset) { i, sc in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        (Text(T.nomeScenario(i)).font(S.nomeSeVa.font)
                            + Text(" · " + T.notaScenario(i, rendimento: sc.rendimento, kid: kid)).font(S.notaSeVa.font))
                            .foregroundColor(S.coloreCella)
                            .lineLimit(2)
                        Spacer(minLength: 6)
                        Text(Formati.euro(sc.esito.netto))
                            .carattereApple(S.cifraSeVa)
                            .foregroundColor(S.coloreCella)
                    }
                    BarraSimula(frazione: max(0, sc.esito.netto) / massimo, colore: colori[min(i, colori.count - 1)])
                }
            }
        }
        .padding(S.paddingRiquadro)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(S.riquadro)
    }

    private func graficoUna(_ e: EsitoStrada, anni: Int) -> some View {
        VStack(alignment: .leading, spacing: S.spazioSeVa) {
            occhiello(T.annoPerAnno)
            GraficoProiezione(serie: [.init(id: "a", punti: e.esito.punti, colore: S.serieA, principale: true)])
            HStack {
                Text(T.oggi)
                Spacer()
                Text(T.traAnni(anni))
            }
            .carattereApple(S.assi)
            .foregroundColor(S.coloreAssi)
            HStack(spacing: S.spazioBlocchi) {
                LegendaLinea(colore: S.serieA, testo: e.opzione.nome)
                LegendaLinea(colore: S.versato, testo: T.versato, tratteggio: true)
                Spacer(minLength: 0)
                Button { mostraMetodo.toggle() } label: {
                    Label(mostraMetodo ? T.nascondiMetodo : T.comeCalcolato,
                          systemImage: mostraMetodo ? "chevron.up" : "questionmark.circle")
                }
                .buttonStyle(.appleSobrio)
            }
        }
        .padding(S.paddingRiquadro)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(S.riquadro)
    }

    private func filaUna(_ e: EsitoStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> some View {
        HStack(spacing: S.spazioStrada) {
            Button(T.salva) {
                let s = MotoreSimulaConfronta.simulazione(e, soldi: soldi, ipotesi: ipotesi, cliente: stato.clienteAttivoId,
                                                          adesso: Appuntamento.alMinuto(Date()))
                stato.salvaSimulazione(s)
                stato.mostraAvviso(T.salvataNelDossier(stato.nomeClienteSimula))
            }
            .buttonStyle(.applePrimario)
            Button(T.confrontala) { stato.modoSimula = .due }
                .buttonStyle(.apple)
            // Il prospetto della posizione (una strada che non è una posizione non ha un prospetto singolo: vedi resta-da-fare)
            if case .posizione(let id) = e.opzione.strada {
                Button(T.prospetto) { stato.apriProspetto(.posizione(id)) }
                    .buttonStyle(.apple)
            }
            Spacer(minLength: 0)
        }
    }

    /// Le ipotesi salvate del cliente: al più sei chip, le altre in «Tutte ⌄»; un tocco la riapre.
    @ViewBuilder private var salvate: some View {
        let id = stato.clienteAttivoId
        let elenco = stato.ricavato("simula-salvate|\(id)") { stato.simulazioniCliente(id) }
        if !elenco.isEmpty {
            HStack(spacing: S.spazioOcchiello) {
                Text(T.salvate)
                    .carattereApple(S.notaFila)
                    .foregroundColor(S.coloreNotaFila)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: S.spazioOcchiello) {
                        ForEach(elenco.prefix(S.massimoChip)) { s in chip(s) }
                        if elenco.count > S.massimoChip {
                            Menu(T.tutte) {
                                ForEach(elenco.dropFirst(S.massimoChip)) { s in
                                    Button(s.titolo) { stato.riapriSimulazioneSalvata(s) }
                                }
                            }
                            .fixedSize()
                        }
                    }
                }
            }
        }
    }

    private func chip(_ s: Simulazione) -> some View {
        Button { stato.riapriSimulazioneSalvata(s) } label: {
            Text(s.titolo)
                .carattereApple(S.chip)
                .foregroundColor(S.coloreChip)
                .lineLimit(1)
                .padding(S.paddingChip)
                .background(Capsule(style: .continuous).fill(S.fondoChip))
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(T.rinomina) {
                nuovoNome = s.titolo
                daRinominare = s
            }
            Button(T.elimina, role: .destructive) { stato.eliminaSimulazione(s.id) }
        }
    }

    // MARK: Due strade

    @ViewBuilder private func due(_ a: EsitoStrada, _ b: EsitoStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> some View {
        VStack(alignment: .leading, spacing: S.spazioFrase) {
            occhiello(T.occhielloDue)
            T.fraseDueParti(a, b, anni: soldi.anni)
                .reduce(Text("")) { t, p in t + (p.evidenza ? Text(p.testo).foregroundColor(S.differenzaFrase) : Text(p.testo)) }
                .carattereApple(S.fraseDue)
                .foregroundColor(S.coloreFrase)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(T.fraseDue(a, b, anni: soldi.anni))
        }
        .padding(S.paddingFrase)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(S.superficie)
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: S.spazioBlocchi) {
                tabella(a, b, anni: soldi.anni)
                graficoDue(a, b).frame(minWidth: S.larghezzaSeVa)
            }
            VStack(alignment: .leading, spacing: S.spazioBlocchi) {
                tabella(a, b, anni: soldi.anni)
                graficoDue(a, b)
            }
        }
        filaDue(a, b, soldi: soldi, ipotesi: ipotesi)
    }

    private func tabella(_ a: EsitoStrada, _ b: EsitoStrada, anni: Int) -> some View {
        let ra: Double? = a.opzione.sri.map { Double($0) }
        let rb: Double? = b.opzione.sri.map { Double($0) }
        let rischio = migliore(ra, rb, piuAlto: false)
        return Grid(alignment: .leading, horizontalSpacing: S.spazioBlocchi, verticalSpacing: S.spazioTabella) {
            GridRow {
                Text("")
                testa("A · \(a.opzione.nome)", colore: S.serieA)
                testa("B · \(b.opzione.nome)", colore: S.serieB)
            }
            riga(T.allaFine, a.esito.netto, b.esito.netto, piuAlto: true)
            riga(T.seVaMale, a.seVaMale, b.seVaMale, piuAlto: true)
            riga(T.costiIn(anni), a.esito.costi, b.esito.costi, piuAlto: false)
            GridRow {
                etichettaRiga(T.rischio)
                cella(a.opzione.sri.map { "\($0)" } ?? "—", spunta: rischio == true)
                cella(b.opzione.sri.map { "\($0)" } ?? "—", spunta: rischio == false)
            }
        }
        .padding(S.paddingRiquadro)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(S.riquadro)
    }

    private func riga(_ etichetta: String, _ va: Double, _ vb: Double, piuAlto: Bool) -> some View {
        let m = migliore(va, vb, piuAlto: piuAlto)
        return GridRow {
            etichettaRiga(etichetta)
            cella(Formati.euro(va), spunta: m == true)
            cella(Formati.euro(vb), spunta: m == false)
        }
    }

    /// true = vince A, false = vince B, nil = pari o dato mancante.
    private func migliore(_ va: Double?, _ vb: Double?, piuAlto: Bool) -> Bool? {
        guard let va, let vb, abs(va - vb) >= 0.5 else { return nil }
        return piuAlto ? va > vb : va < vb
    }

    private func testa(_ testo: String, colore: Color) -> some View {
        Text(testo)
            .carattereApple(S.testaTabella)
            .foregroundColor(colore)
            .lineLimit(1)
            .frame(width: S.colonnaTabella, alignment: .leading)
    }

    private func etichettaRiga(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(S.cellaTabella)
            .foregroundColor(S.coloreCellaNota)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func cella(_ testo: String, spunta: Bool) -> some View {
        HStack(spacing: 4) {
            Text(testo)
                .carattereApple(S.cifraTabella)
                .foregroundColor(S.coloreCella)
                .lineLimit(1)
            if spunta {
                Image(systemName: "checkmark")
                    .font(S.cifraTabella.font)
                    .foregroundColor(S.spunta)
            }
        }
        .frame(width: S.colonnaTabella, alignment: .leading)
    }

    private func graficoDue(_ a: EsitoStrada, _ b: EsitoStrada) -> some View {
        VStack(alignment: .leading, spacing: S.spazioSeVa) {
            occhiello(T.annoPerAnno)
            GraficoProiezione(serie: [.init(id: "a", punti: a.esito.punti, colore: S.serieA, principale: true),
                                      .init(id: "b", punti: b.esito.punti, colore: S.serieB)])
            HStack(spacing: S.spazioBlocchi) {
                LegendaLinea(colore: S.serieA, testo: "A")
                LegendaLinea(colore: S.serieB, testo: "B")
                LegendaLinea(colore: S.versato, testo: T.versato, tratteggio: true)
                Spacer(minLength: 0)
            }
        }
        .padding(S.paddingRiquadro)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(S.riquadro)
    }

    private func filaDue(_ a: EsitoStrada, _ b: EsitoStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> some View {
        let nome = stato.nomeClienteSimula
        return HStack(spacing: S.spazioStrada) {
            Button(nome.isEmpty ? T.prospettoDue : T.prospettoPer(nome)) {
                // Le due strade come ipotesi salvate (riusate se ci sono già con le stesse ipotesi): il prospetto del
                // confronto di sempre, con gli stessi soldi
                let ia = stato.simulazioneSalvataPer(a, soldi: soldi, ipotesi: ipotesi)
                let ib = stato.simulazioneSalvataPer(b, soldi: soldi, ipotesi: ipotesi)
                stato.apriProspetto(.confronto(.simulazione(ia), .simulazione(ib)))
            }
            .buttonStyle(.applePrimario)
            Button(T.tornaAUna) { stato.modoSimula = .una }
                .buttonStyle(.apple)
            if case .posizione(let ia) = a.opzione.strada, case .posizione(let ib) = b.opzione.strada {
                Button(T.restareOCambiare) { stato.apriProspetto(.sostituzione(ia, ib, report: false)) }
                    .buttonStyle(.apple)
            }
            Spacer(minLength: S.spazioStrada)
            Text(T.nonPromesse)
                .carattereApple(S.notaFila)
                .foregroundColor(S.coloreNotaFila)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
    }

    private func occhiello(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(S.occhiello)
            .foregroundColor(S.coloreOcchiello)
            .lineLimit(1)
    }
}

/// La barra di «Se va diversamente»: binario e riempimento alla frazione del migliore.
private struct BarraSimula: View {
    let frazione: Double
    let colore: Color
    private typealias S = Tema.Apple.SimulaConfronta

    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous).fill(S.binario)
                Capsule(style: .continuous).fill(colore)
                    .frame(width: g.size.width * CGFloat(min(max(frazione, 0), 1)))
            }
        }
        .frame(height: S.barraSeVa)
    }
}
#endif
