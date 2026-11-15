#if os(macOS)
import SwiftUI

// Migliorie d'uso 62 «Il documento si apre in grande» (Design/uso/gruppo-11.md §62, template righe 4914-4949).
// Sul Mac il documento toccato nella scheda Documenti del dossier si apre in grande: un dettaglio del tema che nasce dalla
// sua riga (`.origineDettaglio(id: "documento:<id>")`) e si apre con il presentatore che Clienti ha già
// (`PresentatoreDettaglioDossier`, DossierObiettivi.swift), con il suo velo, il ✕, Esc e il clic sul velo.
// A sinistra la pagina (l'anteprima di sempre, carta sempre chiara): passando su un dato a destra la sua riga si accende in
// giallo. A destra i tre passi in fila al posto delle schede «Dati», «Confronto», «Testo»:
//   1. «I dati letti»: prima quelli da controllare (le regole di `MotoreDocumenti.incerti`, con il perché), correggibili sul
//      posto e confermati con «Va bene»; poi i certi in una riga sola («Mostra» li apre);
//   2. «A cosa è collegato»: la posizione o la scheda, con «Cambia»;
//   3. «Cosa non torna»: per ogni differenza i due valori da toccare, applicati solo con il pulsante finale.
// In fondo un pulsante solo (`PulsanteChiusuraConferma` della 68) che dice cosa manca e diventa «Fatto: salva nel dossier».
// Niente campi nuovi: conferme e correzioni scrivono i campi di oggi, le scelte delle differenze la posizione o la scheda
// con lo storico di oggi; ciò che si decide prima del pulsante resta in memoria finché il lettore è aperto.
// iPhone e iPad tengono `DettaglioDocumento`.

/// Le richieste delle istantanee al lettore (Prisma --istantanee): i certi già aperti, il puntatore su un dato, tutto deciso.
/// Vale solo per lo stato della scena (riferimento debole).
final class RichiestaIstantaneaLettore {
    nonisolated(unsafe) private static var attuale: RichiestaIstantaneaLettore?

    private weak var stato: StatoShell?
    let certiAperti: Bool
    let sopra: CampoDocumento?
    /// Mancanti visti e differenze scelte («Nel documento»): il pulsante è pronto.
    let tuttoDeciso: Bool

    private init(stato: StatoShell, certiAperti: Bool, sopra: CampoDocumento?, tuttoDeciso: Bool) {
        self.stato = stato
        self.certiAperti = certiAperti
        self.sopra = sopra
        self.tuttoDeciso = tuttoDeciso
    }

    static func chiedi(_ s: StatoShell, certiAperti: Bool = false, sopra: CampoDocumento? = nil, tuttoDeciso: Bool = false) {
        attuale = RichiestaIstantaneaLettore(stato: s, certiAperti: certiAperti, sopra: sopra, tuttoDeciso: tuttoDeciso)
    }

    static func per(_ s: StatoShell) -> RichiestaIstantaneaLettore? {
        guard let r = attuale, r.stato === s else { return nil }
        return r
    }
}

/// Ciò che il lettore ricava da un documento (in cache con `stato.ricavato`, valida finché il documento non cambia):
/// i dati incerti con il perché, gli attesi che mancano e le differenze per bersaglio.
struct LetturaLettore {
    /// Il gruppo di differenze di un bersaglio (il tipo puro di `DecisioniLettore`, MotoreDocumenti.swift).
    typealias Gruppo = GruppoDifferenzeDocumento

    let incerti: [CampoDocumento: String]
    let mancanti: [CampoDocumento]
    let gruppi: [Gruppo]
    /// Identità e questionari: il confronto con il dossier ha righe da aggiornare.
    let differenzeCliente: Bool

    /// Il confronto si fa sul documento come sarà dopo «Fatto»: i dati certi contano già come confermati, quelli incerti
    /// solo se confermati. Così il passo 3 mostra subito tutte le differenze da decidere.
    static func calcola(_ d: Documento, stato: StatoShell) -> LetturaLettore {
        // Con le pagine vale anche la regola dei due valori diversi nel testo (§62.3 punto 1)
        let incerti = MotoreDocumenti.incerti(d, pagine: d.genere == .prisma ? [] : stato.testoDocumento(d))
        var gruppi: [Gruppo] = []
        var cliente = false
        if MotoreDocumenti.delCliente(d) {
            cliente = (stato.confrontoCliente(d, canale: MotoreDocumenti.canaleQuestionario(d)) ?? [])
                .contains { $0.aggiornabile && $0.esito != .uguale }
        } else if d.genere != .prisma, MotoreConfrontoDossier.confrontabile(d) {
            var visto = d
            for i in visto.campi.indices where incerti[visto.campi[i].chiave] == nil {
                visto.campi[i].confermato = true
            }
            for b in stato.bersagli(d) {
                guard let c = stato.confronto(visto, b), let n = stato.nomeBersaglio(b) else { continue }
                let righe = c.righe.filter(\.aggiornabile)
                guard !righe.isEmpty else { continue }
                gruppi.append(Gruppo(bersaglio: b, chiave: chiave(b), nome: n.nome, scheda: scheda(b), righe: righe))
            }
        }
        return LetturaLettore(incerti: incerti, mancanti: d.genere == .prisma ? [] : MotoreDocumenti.mancanti(d),
                              gruppi: gruppi, differenzeCliente: cliente)
    }

    static func chiave(_ b: BersaglioConfronto) -> String {
        switch b {
        case .posizione(let id): return "posizione|\(id)"
        case .prodotto(let id): return "prodotto|\(id)"
        }
    }

    static func scheda(_ b: BersaglioConfronto) -> Bool {
        if case .prodotto = b { return true }
        return false
    }

    /// La chiave di una scelta del passo 3.
    static func chiaveScelta(_ g: Gruppo, _ r: RigaDossier) -> String { DecisioniLettore.chiaveScelta(g, r) }
}

/// Il contenuto del dettaglio «documento:<id>»: il documento di oggi dall'archivio e il lettore, che riparte da capo a
/// ogni documento. Se il documento non c'è più non mostra niente.
struct LettoreDocumentoContenitore: View {
    @Environment(StatoShell.self) var stato
    let documentoId: String

    var body: some View {
        let _ = ContaCorpi.segna()
        if let d = stato.documento(documentoId) {
            LettoreDocumento(documento: d, iniziale: iniziale(d))
                .id(documentoId)
        }
    }

    /// Ciò che il lettore ha già aperto o deciso alla nascita: il testo se la richiesta veniva dalla scheda «Testo» di
    /// prima, e le richieste delle istantanee.
    private func iniziale(_ d: Documento) -> LettoreDocumento.Iniziale {
        var i = LettoreDocumento.Iniziale()
        i.testo = stato.vistaDocumenti.scheda == .testo
        guard let r = RichiestaIstantaneaLettore.per(stato) else { return i }
        i.certiAperti = r.certiAperti
        i.sopra = r.sopra
        if r.tuttoDeciso {
            let l = LetturaLettore.calcola(d, stato: stato)
            i.mancantiVisti = Set(l.mancanti)
            for g in l.gruppi {
                for riga in g.righe { i.scelte[LetturaLettore.chiaveScelta(g, riga)] = true }
            }
        }
        return i
    }
}

/// Il lettore del documento (il contenuto del dettaglio): la pagina a sinistra, i tre passi e il piede a destra.
struct LettoreDocumento: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.statoDettaglioApple) private var dettaglio
    let documento: Documento

    /// Lo stato di partenza (scheda «Testo» di prima, istantanee).
    struct Iniziale {
        var testo = false
        var certiAperti = false
        var sopra: CampoDocumento?
        var mancantiVisti: Set<CampoDocumento> = []
        var scelte: [String: Bool] = [:]
    }

    /// Il dato sotto il puntatore: accende la sua riga sulla pagina (mai scritto in `vistaDocumenti`).
    @State private var sopra: CampoDocumento?
    @State private var certiAperti: Bool
    @State private var mostraTesto: Bool
    /// Le correzioni scritte sul posto, finché non si preme «Va bene».
    @State private var bozze: [CampoDocumento: String] = [:]
    /// I dati incerti confermati in questa apertura: restano al loro posto, in verde.
    @State private var decisi: Set<CampoDocumento> = []
    /// Gli attesi che mancano, lasciati vuoti con «Va bene».
    @State private var mancantiVisti: Set<CampoDocumento>
    /// Le scelte del passo 3: true = «Nel documento», false = «Nella posizione» / «Nella scheda».
    @State private var scelte: [String: Bool]
    @State private var confrontoCompleto = false
    @State private var scosse: CGFloat = 0
    @State private var scosso: String?
    @State private var eliminare = false
    @State private var moduloCrea = false
    @State private var cosaCrea: CreaDaDocumento = .scheda

    private typealias L = Tema.Apple.Lettore

    init(documento: Documento, iniziale: Iniziale = Iniziale()) {
        self.documento = documento
        _sopra = State(initialValue: iniziale.sopra)
        _certiAperti = State(initialValue: iniziale.certiAperti)
        _mostraTesto = State(initialValue: iniziale.testo)
        _mancantiVisti = State(initialValue: iniziale.mancantiVisti)
        _scelte = State(initialValue: iniziale.scelte)
    }

    // MARK: Identità del dettaglio

    private static let prefisso = "documento:"

    /// L'id del dettaglio nato dalla riga del documento.
    static func idDettaglio(_ documentoId: String) -> String { prefisso + documentoId }

    /// Il documento di un id di dettaglio («documento:<id>»), nil per gli altri dettagli.
    static func documentoDi(_ id: String) -> String? {
        guard id.hasPrefix(prefisso) else { return nil }
        return String(id.dropFirst(prefisso.count))
    }

    // MARK: Ricavati

    private var d: Documento { documento }
    private var inLettura: Bool { stato.documentiInLettura.contains(d.id) }
    private var nomeCliente: String { stato.cliente(d.clienteId)?.nome ?? "" }

    private var lettura: LetturaLettore {
        let doc = d
        let s = stato
        return stato.ricavato("documento-lettore|\(doc.id)|\(inLettura)") { LetturaLettore.calcola(doc, stato: s) }
    }

    /// Un dubbio aperto: incerto e non ancora confermato.
    // Il conto sta nel tipo puro `DecisioniLettore` (MotoreDocumenti.swift), provato in --prova-calcoli.
    private func dubbioAperto(_ c: CampoEstratto, _ l: LetturaLettore) -> Bool {
        DecisioniLettore.dubbioAperto(c, incerti: l.incerti)
    }

    private var conNonConfermati: Bool { DecisioniLettore.conNonConfermati(d) }

    /// I mancanti contano come dubbi solo finché il documento ha dati da confermare.
    private func mancantiAperti(_ l: LetturaLettore) -> [CampoDocumento] {
        DecisioniLettore.mancantiAperti(d, mancanti: l.mancanti, visti: mancantiVisti)
    }

    private func datiDubbi(_ l: LetturaLettore) -> Int {
        DecisioniLettore.datiDubbi(d, incerti: l.incerti, mancanti: l.mancanti, visti: mancantiVisti)
    }

    private func differenzeAperte(_ l: LetturaLettore) -> Int {
        DecisioniLettore.differenzeAperte(l.gruppi, scelte: scelte)
    }

    /// Già salvato: nessun dato da confermare e nessuna differenza aperta (si ricava, nessun campo nuovo).
    private func salvato(_ l: LetturaLettore) -> Bool { DecisioniLettore.salvato(d, gruppi: l.gruppi) }

    // MARK: Corpo

    var body: some View {
        let _ = ContaCorpi.segna()
        let l = lettura
        GeometryReader { geo in
            if d.genere == .prisma {
                impaginato(geo.size)
            } else {
                HStack(alignment: .top, spacing: L.spazioColonne) {
                    pagina
                        .frame(width: larghezzaPagina(geo.size.width))
                        .frame(maxHeight: .infinity)
                    colonnaPassi(l)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
        }
        .alert("Eliminare il documento?", isPresented: $eliminare) {
            Button("Annulla", role: .cancel) {}
            Button("Elimina", role: .destructive) { elimina() }
        } message: {
            Text("Il file viene tolto dall'archivio di Prisma. Schede, posizioni e lo storico dei dati portati in Prisma restano. Se serve, lo recuperi da un backup.")
        }
    }

    /// La pagina: 470 al minimo, cresce con la finestra.
    private func larghezzaPagina(_ totale: CGFloat) -> CGFloat {
        min(max(totale * L.quotaPagina, L.colonnaPagina), L.colonnaPaginaMassima)
    }

    /// Un documento impaginato da Prisma: niente passi, la pagina a tutta larghezza con la nota.
    private func impaginato(_ misura: CGSize) -> some View {
        VStack(alignment: .leading, spacing: L.sottoTestata) {
            testata
            pagina
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(TestiDocumenti.notaImpaginato)
                .carattereApple(L.notaPiede)
                .foregroundColor(L.coloreNotaPiede)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: misura.width, height: misura.height, alignment: .topLeading)
    }

    // MARK: La pagina

    private var pagina: some View {
        let forma = RoundedRectangle(cornerRadius: L.raggioPagina, style: .continuous)
        return AnteprimaDocumento(documento: d, evidenziaSopra: sopra, coloreEvidenza: L.rigaAccesa, seguiRiga: false)
            .background(forma.fill(L.fondoPagina))
            .clipShape(forma)
            .overlay(alignment: .bottom) {
                Text(TestiDocumenti.capsulaPagina(max(stato.vistaDocumenti.pagina, 1), data: dataDocumento))
                    .carattereApple(L.capsulaPagina)
                    .foregroundColor(L.coloreCapsulaPagina)
                    .padding(L.paddingCapsulaPagina)
                    .background(Capsule(style: .continuous).fill(L.fondoCapsulaPagina))
                    .padding(.bottom, L.sottoCapsulaPagina)
                    .allowsHitTesting(false)
            }
    }

    /// La data del documento (quella letta, altrimenti l'importazione).
    private var dataDocumento: String {
        let letta = d.campo(.dataDocumento).flatMap { EstrattoreDocumento.data($0.valore) }
        return Formati.dataEstesa.string(from: letta ?? d.importatoIl)
    }

    // MARK: La colonna dei passi

    @ViewBuilder private func colonnaPassi(_ l: LetturaLettore) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            testata
                .padding(.bottom, L.sottoTestata)
            if mostraTesto {
                testoLetto
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: L.spazioPassi) {
                            passoDati(l)
                            passoCollegamento(l)
                            if !l.gruppi.isEmpty || l.differenzeCliente {
                                passoDifferenze(l)
                            }
                            if confrontoCompleto {
                                ConfrontoDossierVista(documento: d)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, L.spazioPassi)
                    }
                    piede(l, proxy: proxy)
                }
            }
        }
    }

    // MARK: Testata

    private var testata: some View {
        HStack(alignment: .top, spacing: L.spazioDato) {
            VStack(alignment: .leading, spacing: L.spazioTestata) {
                Text(TestiDocumenti.occhiello(nome: nomeCliente, gruppo: d.genere.nome))
                    .carattereApple(L.occhiello)
                    .foregroundColor(L.coloreOcchiello)
                    .lineLimit(1)
                titolo
                HStack(spacing: L.spazioDato) {
                    Text(dataDocumento)
                        .carattereApple(L.data)
                        .foregroundColor(L.coloreData)
                    canale
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            MenuAzioni(voci: { vociMenu() }, margine: Tema.Misura.Documenti.pulsanteIcona, taglia: .normale) {
                Image(systemName: "ellipsis")
            }
            .help(TestiDocumenti.altreAzioni)
            .accessibilityLabel("Altre azioni")
            .popover(isPresented: $moduloCrea, arrowEdge: .bottom) {
                ModuloCreaDaDocumento(documento: d, cosa: cosaCrea) { moduloCrea = false }
                    .environment(stato)
            }
        }
        // Il ✕ del dettaglio sta in alto a destra
        .padding(.trailing, L.spazioChiudi)
    }

    /// Il titolo si corregge sul posto con il doppio clic, come oggi.
    private var titolo: some View {
        let id = d.id
        let tipo = d.tipo
        return TestoRinviato(testo: Binding(get: { stato.documento(id)?.titolo ?? "" },
                                            set: { stato.rinominaDocumento(id, titolo: $0, tipo: stato.documento(id)?.tipo ?? tipo) }),
                             salvaOra: { stato.salvaOra() }) { bozza in
            TextField("Titolo", text: bozza)
                .textFieldStyle(.plain)
                .carattereApple(L.titolo)
                .foregroundColor(L.coloreTitolo)
                .lineLimit(1)
        }
        .id(id)
        .disabled(stato.solaLettura)
    }

    @ViewBuilder private var canale: some View {
        if let b = stato.collegamentoMostrato(d), let n = stato.nomeBersaglio(b) {
            EtichettaCanaleApple(canale: n.canale, compatta: true)
        } else if !MotoreDocumenti.delCliente(d) {
            Pillola(testo: TestiDocumenti.canaleDaIndicare, tono: .neutro)
                .help("Collega il documento a una posizione o a una scheda prodotto: il canale viene da lì")
        }
    }

    // MARK: Il testo letto (dal menu «⋯»)

    private var testoLetto: some View {
        VStack(alignment: .leading, spacing: L.spazioTesto) {
            Button(TestiDocumenti.tornaAiPassi) { mostraTesto = false }
                .buttonStyle(.appleSobrio)
            ScrollView {
                SchedaTestoDocumento(documento: d)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: Il titolo di un passo

    private func titoloPasso(_ numero: Int, _ testo: String, capsula: (String, Pillola.Tono)?) -> some View {
        HStack(spacing: L.spazioTitoloPasso) {
            Text("\(numero)")
                .carattereApple(L.carattereNumeroPasso)
                .foregroundColor(L.coloreNumeroPasso)
                .frame(width: L.numeroPasso, height: L.numeroPasso)
                .background(Circle().fill(L.fondoNumeroPasso))
                .accessibilityHidden(true)
            Text(testo)
                .carattereApple(L.titoloPasso)
                .foregroundColor(L.coloreTitoloPasso)
            Spacer(minLength: 0)
            if let capsula {
                Pillola(testo: capsula.0, tono: capsula.1)
            }
        }
        .padding(.bottom, L.sottoTitoloPasso)
    }

    // MARK: Passo 1 · I dati letti

    @ViewBuilder private func passoDati(_ l: LetturaLettore) -> some View {
        let dubbi = datiDubbi(l)
        let incerte = d.campi.filter { dubbioAperto($0, l) || decisi.contains($0.chiave) }
        let certi = d.campi.filter { !(dubbioAperto($0, l) || decisi.contains($0.chiave)) }
        let mancanti = mancantiAperti(l)
        let capsula: (String, Pillola.Tono)? = capsulaDati(dubbi: dubbi, vuoto: d.campi.isEmpty && mancanti.isEmpty)
        VStack(alignment: .leading, spacing: L.spazioRighe) {
            titoloPasso(1, TestiDocumenti.titoloDati, capsula: capsula)
            if inLettura {
                HStack(spacing: L.spazioDato) {
                    ProgressView().controlSize(.small)
                    notaPasso(TestiDocumenti.inLettura)
                }
            } else if d.lettura == .illeggibile {
                HStack(spacing: L.spazioDato) {
                    notaPasso(TestiDocumenti.illeggibile)
                    Button(TestiDocumenti.rileggi) { rileggi() }
                        .buttonStyle(.apple)
                        .disabled(stato.solaLettura || stato.urlDocumento(d) == nil)
                }
            }
            ForEach(incerte) { c in rigaIncerta(c, perche: l.incerti[c.chiave] ?? "") }
            ForEach(mancanti, id: \.self) { k in rigaMancante(k) }
            if certi.count > 3 && !certiAperti {
                RigaConfermaApple(.fatta, contenuto: {
                    Text(TestiDocumenti.certi(certi.count))
                        .carattereApple(L.rigaDato)
                        .foregroundColor(L.coloreDato)
                }, azioni: {
                    CollegamentoConfermaApple(testo: TestiDocumenti.mostra) { certiAperti = true }
                })
            } else {
                ForEach(certi) { c in rigaCerta(c) }
                if certi.count > 3 {
                    CollegamentoConfermaApple(testo: TestiDocumenti.nascondi) { certiAperti = false }
                }
            }
            // A documento salvato i mancanti restano come righe grigie, da aggiungere a mano
            if !conNonConfermati {
                ForEach(l.mancanti, id: \.self) { k in rigaNonTrovato(k) }
            }
            if d.campi.isEmpty && l.mancanti.isEmpty && !inLettura && d.lettura != .illeggibile {
                notaPasso(TestiDocumenti.nessunDato)
            }
        }
    }

    private func capsulaDati(dubbi: Int, vuoto: Bool) -> (String, Pillola.Tono)? {
        if vuoto { return nil }
        if dubbi > 0 { return (TestiDocumenti.daControllare(dubbi), Pillola.Tono.attenzione) }
        return (TestiDocumenti.aPosto, Pillola.Tono.ok)
    }

    private func idDato(_ k: CampoDocumento) -> String { "dato-\(k.rawValue)" }

    /// Un dato incerto: «?» arancio, il valore correggibile sul posto, il perché sotto, «Va bene». Confermato in questa
    /// apertura resta al suo posto, in verde, con il valore di quel momento.
    private func rigaIncerta(_ c: CampoEstratto, perche: String) -> some View {
        let k = c.chiave
        let aperto = !c.confermato
        return RigaConfermaApple(aperto ? .daDecidere : .fatta, contenuto: {
            HStack(alignment: .firstTextBaseline, spacing: L.spazioDato) {
                nomeCampo(k)
                if aperto {
                    campoValore(k, iniziale: c.valore)
                } else {
                    Text(MotoreDocumenti.testo(c))
                        .carattereApple(L.rigaDato)
                        .foregroundColor(L.coloreDato)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                fonte(c)
            }
            if aperto {
                Text(perche)
                    .carattereApple(L.perche)
                    .foregroundColor(L.colorePerche)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, L.larghezzaNome + L.spazioDato)
            }
        }, azioni: {
            if aperto {
                Button(TestiDocumenti.vaBene) { vaBene(k, mancante: false) }
                    .buttonStyle(.apple)
                    .help(TestiDocumenti.aiutoVaBene)
                    .disabled(stato.solaLettura)
            }
        })
        .id(idDato(k))
        .modifier(ScuotiConferma(scosse: scosse, attiva: scosso == idDato(k)))
        .onHover { dentro in passa(k, dentro) }
    }

    /// Un dato che il tipo di documento dovrebbe avere e non c'è: da scrivere o da lasciare vuoto con «Va bene».
    private func rigaMancante(_ k: CampoDocumento) -> some View {
        RigaConfermaApple(.daDecidere, contenuto: {
            HStack(alignment: .firstTextBaseline, spacing: L.spazioDato) {
                nomeCampo(k)
                campoValore(k, iniziale: "", mancante: true)
            }
            Text(TestiDocumenti.mancante(k))
                .carattereApple(L.perche)
                .foregroundColor(L.colorePerche)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, L.larghezzaNome + L.spazioDato)
        }, azioni: {
            Button(TestiDocumenti.vaBene) { vaBene(k, mancante: true) }
                .buttonStyle(.apple)
                .disabled(stato.solaLettura)
        })
        .id(idDato(k))
        .modifier(ScuotiConferma(scosse: scosse, attiva: scosso == idDato(k)))
    }

    /// Un dato certo (o già confermato), con la sua fonte.
    private func rigaCerta(_ c: CampoEstratto) -> some View {
        RigaConfermaApple(.fatta) {
            HStack(alignment: .firstTextBaseline, spacing: L.spazioDato) {
                nomeCampo(c.chiave)
                Text(MotoreDocumenti.testo(c))
                    .carattereApple(L.rigaDato)
                    .foregroundColor(L.coloreDato)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                fonte(c)
            }
        }
        .onHover { dentro in passa(c.chiave, dentro) }
    }

    /// A documento salvato: «Non trovato: <campo>», con il campo per aggiungerlo a mano.
    private func rigaNonTrovato(_ k: CampoDocumento) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: L.spazioDato) {
            Text(TestiDocumenti.nonTrovato(k))
                .carattereApple(L.rigaGrigia)
                .foregroundColor(L.coloreRigaGrigia)
                .frame(maxWidth: .infinity, alignment: .leading)
            campoValore(k, iniziale: "", mancante: true)
                .frame(maxWidth: L.larghezzaNome)
            Button(TestiDocumenti.aggiungi) { vaBene(k, mancante: true) }
                .buttonStyle(.apple)
                .disabled(stato.solaLettura || (bozze[k] ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(Tema.Apple.Conferme.paddingRiga)
    }

    private func nomeCampo(_ k: CampoDocumento) -> some View {
        Text(k.nome)
            .carattereApple(L.nome)
            .foregroundColor(L.coloreNome)
            .lineLimit(2)
            .frame(width: L.larghezzaNome, alignment: .leading)
    }

    /// Il valore correggibile sul posto: Invio vale «Va bene».
    private func campoValore(_ k: CampoDocumento, iniziale: String, mancante: Bool = false) -> some View {
        TextField(TestiDocumenti.scriviQui, text: Binding(get: { bozze[k] ?? iniziale }, set: { bozze[k] = $0 }))
            .textFieldStyle(.plain)
            .carattereApple(L.rigaDato)
            .foregroundColor(L.coloreDato)
            .padding(L.paddingCampo)
            .background(RoundedRectangle(cornerRadius: L.raggioCampo, style: .continuous).fill(L.fondoCampo))
            .overlay(RoundedRectangle(cornerRadius: L.raggioCampo, style: .continuous)
                .strokeBorder(L.bordoCampo, lineWidth: Tema.Apple.Misura.bordo))
            .frame(maxWidth: .infinity, alignment: .leading)
            .onSubmit { vaBene(k, mancante: mancante) }
            .disabled(stato.solaLettura)
    }

    /// «p. N»: la pagina e la riga del dato, accesa sul foglio.
    @ViewBuilder private func fonte(_ c: CampoEstratto) -> some View {
        if c.pagina > 0 {
            Button("p. \(c.pagina)") {
                stato.vistaDocumenti.pagina = c.pagina
                stato.vistaDocumenti.evidenzia = c.chiave
            }
            .buttonStyle(StileSemplice())
            .carattereApple(L.fonte)
            .foregroundColor(L.coloreFonte)
            .help(c.estratto.isEmpty ? "Pagina \(c.pagina)" : "«\(c.estratto)»")
        }
    }

    private func notaPasso(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(L.notaPasso)
            .foregroundColor(L.coloreNotaPasso)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Il puntatore su un dato: la riga si accende sulla pagina; uscendo si spegne (se era quella).
    private func passa(_ k: CampoDocumento, _ dentro: Bool) {
        if dentro {
            sopra = k
        } else if sopra == k {
            sopra = nil
        }
    }

    // MARK: Passo 2 · A cosa è collegato

    @ViewBuilder private func passoCollegamento(_ l: LetturaLettore) -> some View {
        let collegato = stato.collegamentoMostrato(d)
        let nome = collegato.flatMap { stato.nomeBersaglio($0) }
        let delCliente = MotoreDocumenti.delCliente(d)
        let aPosto: Bool = delCliente || nome != nil
        let capsula: (String, Pillola.Tono) = aPosto ? (TestiDocumenti.aPosto, Pillola.Tono.ok)
                                                     : (TestiDocumenti.nonCollegato, Pillola.Tono.attenzione)
        VStack(alignment: .leading, spacing: L.spazioRighe) {
            titoloPasso(2, TestiDocumenti.titoloCollegamento, capsula: capsula)
            if delCliente {
                RigaConfermaApple(.fatta) {
                    Text(TestiDocumenti.alDossier(nomeCliente))
                        .carattereApple(L.rigaDato)
                        .foregroundColor(L.coloreDato)
                }
            } else if let b = collegato, let n = nome {
                RigaConfermaApple(.fatta, contenuto: {
                    HStack(spacing: L.spazioDato) {
                        Text(LetturaLettore.scheda(b) ? TestiDocumenti.allaScheda(n.nome)
                                                      : TestiDocumenti.allaPosizione(n.nome, cliente: nomeCliente))
                            .carattereApple(L.rigaDato)
                            .foregroundColor(L.coloreDato)
                            .lineLimit(2)
                        EtichettaCanaleApple(canale: n.canale, compatta: true)
                    }
                }, azioni: {
                    if !stato.solaLettura {
                        MenuAzioni(voci: { vociCollega() }) { Text(TestiDocumenti.cambia) }
                            .help(TestiDocumenti.aiutoCambia)
                    }
                })
            } else {
                rigaNonCollegato
            }
            if MotoreConfrontoDossier.confrontabile(d), collegato != nil {
                CollegamentoConfermaApple(testo: confrontoCompleto ? TestiDocumenti.chiudiConfronto : TestiDocumenti.confrontoCompleto) {
                    confrontoCompleto.toggle()
                }
                .help(TestiDocumenti.aiutoConfronto)
            }
        }
    }

    /// Senza collegamento: il suggerimento di oggi («Sembra «…»» e «Collega») e il menu delle candidate.
    private var rigaNonCollegato: some View {
        let suggerimento = stato.suggerimentoCollegamento(d)
        let suggerito = suggerimento.flatMap { stato.nomeBersaglio($0.0) }
        let candidate = !stato.candidateCollegamento(d).isEmpty
        return RigaConfermaApple(.daDecidere, contenuto: {
            Text(TestiDocumenti.nonCollegato)
                .carattereApple(L.rigaDato)
                .foregroundColor(L.coloreDato)
            if let s = suggerimento, let n = suggerito {
                Text("\(TestiConfrontoDossier.sembra(n.nome)) · \(TestiConfrontoDossier.motivo(s.1))")
                    .carattereApple(L.perche)
                    .foregroundColor(L.colorePerche)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }, azioni: {
            if let s = suggerimento, !stato.solaLettura {
                Button(TestiDocumenti.collega) { stato.collegaDocumento(d.id, a: s.0) }
                    .buttonStyle(.apple)
            }
            if candidate && !stato.solaLettura {
                MenuAzioni(voci: { vociCollega() }) { Text(TestiDocumenti.cambia) }
                    .help(TestiDocumenti.aiutoCambia)
            }
        })
    }

    // MARK: Passo 3 · Cosa non torna

    @ViewBuilder private func passoDifferenze(_ l: LetturaLettore) -> some View {
        let aperte = differenzeAperte(l)
        let capsula: (String, Pillola.Tono)? = capsulaDifferenze(aperte: aperte, nessuna: l.gruppi.isEmpty)
        VStack(alignment: .leading, spacing: L.spazioRighe) {
            titoloPasso(3, TestiDocumenti.titoloDifferenze, capsula: capsula)
            if MotoreDocumenti.delCliente(d) {
                // Identità e questionari: il confronto con il dossier di oggi («Nel documento / Nel dossier»)
                ConfrontoClienteVista(documento: d) { pagina, campo in
                    stato.vistaDocumenti.pagina = pagina
                    stato.vistaDocumenti.evidenzia = campo
                }
            } else {
                ForEach(l.gruppi, id: \.chiave) { g in
                    if l.gruppi.count > 1 {
                        Text(g.nome)
                            .carattereApple(L.nomeDifferenza)
                            .foregroundColor(L.coloreSpiegazione)
                    }
                    ForEach(g.righe) { r in riquadroDifferenza(g, r) }
                }
                notaPasso(TestiDocumenti.toccaIlGiusto)
            }
        }
    }

    private func capsulaDifferenze(aperte: Int, nessuna: Bool) -> (String, Pillola.Tono)? {
        if nessuna { return nil }
        if aperte > 0 { return (TestiDocumenti.daDecidere(aperte), Pillola.Tono.attenzione) }
        return (TestiDocumenti.deciso, Pillola.Tono.ok)
    }

    private func idDifferenza(_ g: LetturaLettore.Gruppo, _ r: RigaDossier) -> String {
        "differenza-\(LetturaLettore.chiaveScelta(g, r))"
    }

    /// Una differenza: il nome, la spiegazione e i due valori da toccare.
    private func riquadroDifferenza(_ g: LetturaLettore.Gruppo, _ r: RigaDossier) -> some View {
        let chiave = LetturaLettore.chiaveScelta(g, r)
        let scelta = scelte[chiave]
        let forma = RoundedRectangle(cornerRadius: L.raggioDifferenza, style: .continuous)
        let id = idDifferenza(g, r)
        return VStack(alignment: .leading, spacing: L.spazioRighe) {
            Text(TestiConfrontoDossier.nome(r.voce))
                .carattereApple(L.nomeDifferenza)
                .foregroundColor(L.coloreDato)
            Text(r.nota ?? TestiConfrontoDossier.esito(r))
                .carattereApple(L.spiegazione)
                .foregroundColor(L.coloreSpiegazione)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: L.spazioScelte) {
                riquadroScelta(TestiDocumenti.nelDocumento, TestiConfrontoDossier.valore(r.documento, r.voce),
                               acceso: scelta == true) { scelte[chiave] = true }
                riquadroScelta(g.scheda ? TestiDocumenti.nellaScheda : TestiDocumenti.nellaPosizione,
                               TestiConfrontoDossier.valore(r.prisma, r.voce),
                               acceso: scelta == false) { scelte[chiave] = false }
            }
        }
        .padding(L.paddingDifferenza)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(forma.fill(scelta == nil ? L.fondoDifferenza : L.fondoDifferenzaDecisa))
        .overlay(forma.strokeBorder(scelta == nil ? L.bordoDifferenza : Color.clear, lineWidth: Tema.Apple.Misura.bordo))
        .id(id)
        .modifier(ScuotiConferma(scosse: scosse, attiva: scosso == id))
        .onHover { dentro in passa(r.voce.campo, dentro) }
    }

    private func riquadroScelta(_ etichetta: String, _ valore: String, acceso: Bool, azione: @escaping () -> Void) -> some View {
        let forma = RoundedRectangle(cornerRadius: L.raggioScelta, style: .continuous)
        return Button(action: azione) {
            VStack(alignment: .leading, spacing: 2) {
                Text(etichetta)
                    .carattereApple(L.etichettaScelta)
                    .foregroundColor(L.coloreEtichettaScelta)
                Text(valore)
                    .carattereApple(L.valoreScelta)
                    .foregroundColor(L.coloreValoreScelta)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(L.paddingScelta)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(forma.fill(acceso ? L.fondoSceltaAccesa : L.fondoScelta))
            .overlay(forma.strokeBorder(acceso ? L.bordoSceltaAccesa : L.bordoSceltaSpenta, lineWidth: L.bordoScelta))
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .disabled(stato.solaLettura)
        .accessibilityAddTraits(acceso ? .isSelected : [])
    }

    // MARK: Il piede

    private func piede(_ l: LetturaLettore, proxy: ScrollViewProxy) -> some View {
        let dati = datiDubbi(l)
        let differenze = differenzeAperte(l)
        let giaSalvato = salvato(l)
        return HStack(spacing: L.spazioPiede) {
            PulsanteChiusuraConferma(dubbi: dati + differenze,
                                     testoDubbi: dati > 0 ? TestiDocumenti.controlla(dati) : TestiDocumenti.decidi(differenze),
                                     testoPronto: giaSalvato ? TestiDocumenti.chiudi : TestiDocumenti.fatto,
                                     azione: { fatto(l, giaSalvato: giaSalvato) },
                                     primoDubbio: { primoDubbio(l, proxy: proxy) })
                .disabled(stato.solaLettura && !giaSalvato)
            Button(TestiDocumenti.chiediAVera) {
                TestiRinviati.scriviOra()
                stato.spiegaDocumentoConVera(d.id)
            }
            .buttonStyle(.appleGrande)
            .help(TestiDocumenti.aiutoVera)
            .disabled(stato.veraInCorso || inLettura)
            Spacer(minLength: 0)
            Text(giaSalvato ? TestiDocumenti.giaSalvato : TestiDocumenti.soloQuandoLoDici)
                .carattereApple(L.notaPiede)
                .foregroundColor(L.coloreNotaPiede)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, L.sopraPiede)
        .bordoAlto(Tema.Apple.Colore.separatore)
    }

    // MARK: Azioni

    /// «Va bene» su un dato incerto (con la correzione scritta, un gesto solo) o su un mancante (vuoto: resta mancante,
    /// la scelta vale finché il lettore è aperto; scritto: entra «A mano», confermato).
    private func vaBene(_ k: CampoDocumento, mancante: Bool) {
        guard !stato.solaLettura else { return }
        let bozza = (bozze[k] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if mancante {
            if bozza.isEmpty {
                mancantiVisti.insert(k)
            } else {
                stato.aggiungiCampo(d.id, k, valore: bozza)
            }
        } else {
            if let c = d.campo(k), !bozza.isEmpty, bozza != c.valore {
                stato.modificaCampo(d.id, k, valore: bozza)
            } else {
                stato.confermaCampo(d.id, k, true)
            }
            decisi.insert(k)
        }
        bozze[k] = nil
        if scosso == idDato(k) { scosso = nil }
    }

    /// Il pulsante premuto con dell'arancione: il primo dato o la prima differenza scorre in vista e trema.
    private func primoDubbio(_ l: LetturaLettore, proxy: ScrollViewProxy) {
        let primoDato: String? = d.campi.first { dubbioAperto($0, l) }.map { idDato($0.chiave) }
            ?? mancantiAperti(l).first.map { idDato($0) }
        var primaDifferenza: String?
        for g in l.gruppi where primaDifferenza == nil {
            if let r = g.righe.first(where: { scelte[LetturaLettore.chiaveScelta(g, $0)] == nil }) {
                primaDifferenza = idDifferenza(g, r)
            }
        }
        guard let primo = primoDato ?? primaDifferenza else { return }
        scosso = primo
        withAnimation(Tema.Moto.pannello) { proxy.scrollTo(primo, anchor: .center) }
        withAnimation(Tema.Apple.Conferme.animazioneScossa) { scosse += 1 }
        stato.mostraAvviso(primoDato != nil ? TestiDocumenti.primaControlla : TestiDocumenti.primaScegli)
    }

    /// «Fatto: salva nel dossier»: conferma i dati certi (visti nella riga riassunto), applica le scelte del passo 3 con
    /// lo storico di oggi e chiude. «Chiudi» se era già salvato.
    private func fatto(_ l: LetturaLettore, giaSalvato: Bool) {
        guard !giaSalvato else {
            dettaglio?.chiudi()
            return
        }
        guard !stato.solaLettura,
              let piano = DecisioniLettore.piano(d, incerti: l.incerti, mancanti: l.mancanti, visti: mancantiVisti,
                                                 gruppi: l.gruppi, scelte: scelte) else { return }
        TestiRinviati.scriviOra()
        let titolo = d.titolo
        let cliente = nomeCliente
        stato.applicaFattoLettore(d.id, piano: piano)
        stato.mostraAvviso(TestiDocumenti.salvato(titolo, cliente: cliente))
        dettaglio?.chiudi()
    }

    private func rileggi() {
        TestiRinviati.scriviOra()
        stato.leggiDocumento(d.id)
    }

    private func elimina() {
        let id = d.id
        dettaglio?.chiudi(subito: true)
        stato.eliminaDocumento(id)
    }

    // MARK: Il menu «⋯»: testo, Vera, collega, crea, tipo e il resto (niente sparisce dal dettaglio di prima)

    private func vociMenu() -> [VoceMenuAzioni] {
        let id = d.id
        let documento = d
        let file = stato.urlDocumento(d).flatMap { FileManager.default.fileExists(atPath: $0.path) ? $0 : nil }
        let collegati = stato.bersagli(d)
        var voci: [VoceMenuAzioni] = [
            VoceMenuAzioni.azione(TestiDocumenti.mostraIlTesto, spuntata: mostraTesto) { mostraTesto.toggle() },
            VoceMenuAzioni.azione("Apri con Vera", attiva: !stato.veraInCorso && !inLettura) {
                TestiRinviati.scriviOra()
                stato.spiegaDocumentoConVera(id)
            },
        ]
        if !stato.solaLettura {
            if !MotoreDocumenti.delCliente(d) {
                voci.append(VoceMenuAzioni.separatore)
                voci.append(VoceMenuAzioni.sezione("Collega a…"))
                voci.append(contentsOf: vociCollega())
            }
            if !inLettura {
                voci.append(VoceMenuAzioni.separatore)
                voci.append(VoceMenuAzioni.sezione("Crea…"))
                voci.append(VoceMenuAzioni.azione("Scheda prodotto…") { apriModulo(.scheda) })
                voci.append(VoceMenuAzioni.azione("Posizione in essere…") { apriModulo(.posizione) })
                voci.append(VoceMenuAzioni.azione("Proposta…") { apriModulo(.proposta) })
            }
            if stato.valoreEstrattoDaRegistrare(d) != nil {
                voci.append(VoceMenuAzioni.separatore)
                voci.append(VoceMenuAzioni.azione("Aggiorna il valore") {
                    TestiRinviati.scriviOra()
                    stato.aggiornaValoreDaDocumento(id)
                })
            }
            voci.append(VoceMenuAzioni.separatore)
            voci.append(VoceMenuAzioni.sezione("Tipo di documento"))
            let attuale = d.genere
            for c in CategoriaDocumento.allCases where c.selezionabile {
                voci.append(VoceMenuAzioni.azione(c.breve, spuntata: c == attuale) {
                    TestiRinviati.scriviOra()
                    stato.impostaCategoria(id, c)
                })
            }
        }
        voci.append(VoceMenuAzioni.separatore)
        voci.append(VoceMenuAzioni.azione("Apri in Anteprima", attiva: file != nil) {
            if let file { ApriFile.apri(file) }
        })
        voci.append(VoceMenuAzioni.azione("Mostra nel Finder", attiva: file != nil) { stato.mostraNelFinder(documento) })
        voci.append(VoceMenuAzioni.azione("Rileggi il documento", attiva: file != nil && !inLettura && !stato.solaLettura) {
            rileggi()
        })
        voci.append(VoceMenuAzioni.separatore)
        if !collegati.isEmpty {
            voci.append(VoceMenuAzioni.azione("Scollega", attiva: !stato.solaLettura) {
                for b in collegati { stato.scollegaDocumento(id, da: b) }
            })
        }
        voci.append(VoceMenuAzioni.azione("Elimina…", attiva: !stato.solaLettura) { eliminare = true })
        return voci
    }

    private func apriModulo(_ cosa: CreaDaDocumento) {
        cosaCrea = cosa
        moduloCrea = true
    }

    /// Le posizioni del cliente e le schede da collegare (le stesse del dettaglio di prima), con la spunta sui collegati.
    private func vociCollega() -> [VoceMenuAzioni] {
        let id = d.id
        let candidate = stato.candidateCollegamento(d)
        let collegati = stato.bersagli(d)
        let posizioni = candidate.filter { !LetturaLettore.scheda($0.0) }
        let schede = candidate.filter { LetturaLettore.scheda($0.0) }
        var voci: [VoceMenuAzioni] = []
        if !posizioni.isEmpty {
            voci.append(VoceMenuAzioni.sezione("Posizioni di \(nomeCliente.isEmpty ? "questo cliente" : nomeCliente)"))
            for (b, etichetta) in posizioni {
                voci.append(VoceMenuAzioni.azione(etichetta, spuntata: collegati.contains(b)) { stato.collegaDocumento(id, a: b) })
            }
        }
        if !schede.isEmpty {
            voci.append(VoceMenuAzioni.sezione("Schede prodotto"))
            for (b, etichetta) in schede {
                voci.append(VoceMenuAzioni.azione(etichetta, spuntata: collegati.contains(b)) { stato.collegaDocumento(id, a: b) })
            }
        }
        if candidate.isEmpty { voci.append(VoceMenuAzioni.sezione("Nessuna posizione o scheda da collegare")) }
        voci.append(VoceMenuAzioni.separatore)
        voci.append(VoceMenuAzioni.azione("Non collegato", spuntata: collegati.isEmpty) {
            for b in collegati { stato.scollegaDocumento(id, da: b) }
        })
        return voci
    }
}

/// Segna la riga di un documento come origine del lettore (solo dove il tocco apre il lettore).
struct OrigineLettore: ViewModifier {
    let attiva: Bool
    let id: String

    @ViewBuilder func body(content: Content) -> some View {
        if attiva {
            content.origineDettaglio(id: id)
        } else {
            content
        }
    }
}
/// «Fatto: salva nel dossier» sui dati: conferma i certi e applica le scelte del passo 3 con lo storico di oggi
/// (`aggiornaDalDocumento`, `alternaVociTenute`). Il piano viene da `DecisioniLettore.piano`: mai un dato incerto.
extension StatoShell {
    func applicaFattoLettore(_ id: String, piano: DecisioniLettore.Piano) {
        guard !solaLettura else { return }
        for k in piano.conferma {
            confermaCampo(id, k, true)
        }
        for a in piano.applica {
            if !a.dalDocumento.isEmpty {
                aggiornaDalDocumento(id, bersaglio: a.bersaglio, voci: a.dalDocumento, ancheProposte: a.scheda)
            }
            if !a.comeInPrisma.isEmpty {
                alternaVociTenute(id, bersaglio: a.bersaglio, voci: a.comeInPrisma)
            }
        }
    }
}
#endif
