import SwiftUI

private typealias T = Tipo.Report

/// Il fascicolo dell'incontro: i report scelti per il cliente in un solo PDF, con una copertina,
/// un indice e la password del cliente come per ogni documento.
extension TipoProspetto {
    /// I report che possono entrare nel fascicolo, nell'ordine in cui si leggono.
    static let inFascicolo: [TipoProspetto] = [.checkUp, .annoInsieme, .resoconto, .patrimonio, .resistenza, .costi, .successione, .previdenza, .protezione, .liquidita]
    /// Quelli spuntati all'inizio: il quadro e le tre analisi nuove.
    static let fascicoloPredefinito: Set<TipoProspetto> = [.resoconto, .patrimonio, .resistenza, .costi, .successione]
    /// L'ordine di partenza del fascicolo: sul Mac (migliorie d'uso 70) quello dei gruppi dell'elenco dei Prospetti
    /// (miglioria 23: «Primo incontro», «Le analisi», «Fine anno»), altrove quello di `inFascicolo`.
    static let ordineFascicolo: [TipoProspetto] = {
        #if os(macOS)
        let perGruppi = ElencoProspetti.ordine.filter { TipoProspetto.inFascicolo.contains($0) }
        return perGruppi + TipoProspetto.inFascicolo.filter { !perGruppi.contains($0) }
        #else
        return TipoProspetto.inFascicolo
        #endif
    }()

    /// I report adatti a un appuntamento: dal tipo d'incontro e dalla posizione di cui si parla.
    static func perIncontro(_ a: Appuntamento, posizione: Posizione?, oggi: Date = Date()) -> Set<TipoProspetto> {
        var scelti: Set<TipoProspetto>
        switch a.tipo {
        case .primoIncontro: scelti = [.checkUp, .patrimonio]
        case .analisi: scelti = [.resoconto, .patrimonio, .resistenza, .costi]
        // La revisione periodica è il riesame di fine anno: si apre con «Un anno insieme»
        case .revisione: scelti = [.annoInsieme, .resoconto, .patrimonio, .resistenza, .costi, .successione]
        case .proposta: scelti = [.resoconto, .patrimonio, .costi]
        case .firma: scelti = [.resoconto]
        case .telefonata, .altro, .nonDisponibile: scelti = fascicoloPredefinito
        }
        if let p = posizione {
            // Una scadenza vicina: il capitale da destinare e chi lo riceverebbe
            let fraUnAnno = Calendar.current.date(byAdding: .month, value: 12, to: oggi) ?? oggi
            if let s = p.scadenza, s <= fraUnAnno { scelti.formUnion([.liquidita, .successione]) }
            if p.area == .previdenza { scelti.insert(.previdenza) }
            if p.area == .protezione { scelti.insert(.protezione) }
        }
        return scelti
    }

    /// La scelta del report per il cliente di questo tipo (nil se non ha un report).
    var report: SceltaProspetto? {
        switch self {
        case .checkUp: return .checkUp(report: true)
        case .resoconto: return .resoconto(report: true)
        case .patrimonio: return .patrimonio(report: true)
        case .resistenza: return .resistenza(report: true)
        case .costi: return .costi(report: true)
        case .successione: return .successione(report: true)
        case .previdenza: return .previdenza(report: true)
        case .protezione: return .protezione(report: true)
        case .liquidita: return .liquidita(report: true)
        case .annoInsieme: return .annoInsieme
        default: return nil
        }
    }
}

extension DocumentoStampabile {
    /// Un documento già impaginato in A4 orizzontale (il fascicolo).
    init(report titolo: String, cliente: String, pagine: [AnyView]) {
        self.titolo = titolo
        self.cliente = cliente
        genere = "Report"
        formato = Misure.Documento.report
        self.pagine = pagine
        tipo = .report
    }
}

/// Un report del fascicolo già impaginato (nil se il cliente non ce l'ha), tenuto da parte con `StatoShell.ricavato`.
private struct ParteFascicolo {
    let documento: DocumentoStampabile?
}

/// La scelta del fascicolo di un cliente (migliorie d'uso 70): i report spuntati, il loro ordine e l'appuntamento per
/// cui si prepara. Resta in memoria fino alla chiusura di Prisma (decisione 70-a); la copertina c'è sempre.
struct SceltaFascicolo: Equatable {
    var ordine: [TipoProspetto]
    var scelti: Set<TipoProspetto>
    var appuntamento: String?

    /// Quella di partenza: l'ordine dei gruppi e i report predefiniti, senza appuntamento.
    static var nuova: SceltaFascicolo {
        SceltaFascicolo(ordine: TipoProspetto.ordineFascicolo, scelti: TipoProspetto.fascicoloPredefinito, appuntamento: nil)
    }

    /// I report spuntati, nell'ordine scelto.
    var inOrdine: [TipoProspetto] { ordine.filter { scelti.contains($0) } }

    /// Sposta un report di un posto (−1 su, +1 giù) fra quelli dell'elenco `visibili` (i report che il cliente ha):
    /// lo scambio avviene con il vicino visibile, gli altri restano dove sono.
    mutating func sposta(_ t: TipoProspetto, di passo: Int, visibili: [TipoProspetto]) {
        let elenco = ordine.filter { visibili.contains($0) }
        guard let i = elenco.firstIndex(of: t), elenco.indices.contains(i + passo),
              let a = ordine.firstIndex(of: t), let b = ordine.firstIndex(of: elenco[i + passo]) else { return }
        ordine.swapAt(a, b)
    }

    /// Mette o toglie un report.
    mutating func alterna(_ t: TipoProspetto) {
        if scelti.contains(t) { scelti.remove(t) } else { scelti.insert(t) }
    }
}

extension StatoShell {
    /// Quante volte un report del fascicolo è stato impaginato (`parteFascicolo`): lo legge `--prova-carico` per
    /// verificare che spuntare una riga rifaccia solo la copertina. Solo un contatore, nessun dato.
    nonisolated(unsafe) private(set) static var partiFascicoloImpaginate = 0

    /// Di chi è il fascicolo: sul Mac del cliente attivo, altrove uno solo per tutti.
    private var chiaveFascicolo: String {
        #if os(macOS)
        return clienteAttivoId
        #else
        return ""
        #endif
    }

    /// La scelta del fascicolo del cliente attivo (o quella di partenza).
    var sceltaFascicoloCompleta: SceltaFascicolo {
        get { fascicoli[chiaveFascicolo] ?? .nuova }
        set { fascicoli[chiaveFascicolo] = newValue }
    }

    /// I report spuntati per il fascicolo dell'incontro (per la sessione).
    var sceltaFascicolo: Set<TipoProspetto> {
        get { sceltaFascicoloCompleta.scelti }
        set { sceltaFascicoloCompleta.scelti = newValue }
    }

    /// L'appuntamento per cui si prepara il fascicolo (dà la data e il tipo d'incontro alla copertina).
    var fascicoloAppuntamento: String? {
        get { sceltaFascicoloCompleta.appuntamento }
        set { sceltaFascicoloCompleta.appuntamento = newValue }
    }

    /// L'ordine dei report del fascicolo (tutti, spuntati e no).
    var ordineFascicolo: [TipoProspetto] {
        get { sceltaFascicoloCompleta.ordine }
        set { sceltaFascicoloCompleta.ordine = newValue }
    }

    /// I report spuntati nell'ordine scelto: quelli che entrano nel fascicolo (se il cliente li ha).
    var reportFascicolo: [TipoProspetto] { sceltaFascicoloCompleta.inOrdine }

    /// Il report `t` del cliente attivo già impaginato (nil se non ce l'ha). Ogni report si impagina una volta per dati
    /// dei calcoli (commenti compresi), cliente e ora, come il documento di Prospetti: spuntare una casella rifà solo
    /// la copertina. I report del fascicolo non leggono le note né lo stato delle viste.
    private func parteFascicolo(_ t: TipoProspetto, cliente idCliente: String, ora: Int) -> DocumentoStampabile? {
        guard let scelta = t.report else { return nil }
        let parte: ParteFascicolo = ricavato("fascicolo|\(t.rawValue)|\(idCliente)|\(ora)") { () -> ParteFascicolo in
            StatoShell.partiFascicoloImpaginate += 1
            return ParteFascicolo(documento: documentoProspetto(scelta))
        }
        return parte.documento
    }

    /// Migliorie d'uso 70: le pagine del report `t` del cliente attivo (nil se il cliente non ha quel report). Usa la
    /// stessa impaginazione tenuta da parte per la composizione.
    func pagineFascicolo(_ t: TipoProspetto) -> Int? {
        parteFascicolo(t, cliente: clienteAttivoId, ora: DerivatiDati.ora())?.pagine.count
    }

    /// L'indice va sulla copertina (niente pagina dell'indice) sul Mac, fino a `vociIndiceCopertina` report
    /// (decisione 70-b); altrove e oltre resta la pagina «Cosa trovi in questo fascicolo».
    static func indiceInCopertina(_ voci: Int) -> Bool {
        #if os(macOS)
        return voci <= Misure.Documento.vociIndiceCopertina
        #else
        return false
        #endif
    }

    /// Le pagine prima del primo report: la copertina e, se serve, la pagina dell'indice.
    static func pagineAperturaFascicolo(_ voci: Int) -> Int {
        indiceInCopertina(voci) ? 1 : 2
    }

    /// Il fascicolo del cliente attivo con i report spuntati, nell'ordine scelto (con il commento di ciascuno, se c'è).
    func documentoFascicolo() -> DocumentoStampabile? {
        let idCliente = clienteAttivoId
        let ora = DerivatiDati.ora()
        let parti = reportFascicolo.compactMap { t -> (String, DocumentoStampabile)? in
            guard let d = parteFascicolo(t, cliente: idCliente, ora: ora) else { return nil }
            return (d.titolo, d)
        }
        guard !parti.isEmpty, let c = clienteAttivo else { return nil }
        let inCopertina = Self.indiceInCopertina(parti.count)
        var voci: [(String, Int)] = []
        var pagina = Self.pagineAperturaFascicolo(parti.count) + 1
        for (titolo, d) in parti {
            voci.append((titolo, pagina))
            pagina += d.pagine.count
        }
        let incontro = incontroDelFascicolo(c)
        let data = incontro?.inizio ?? Date()
        let copertina = copertinaFascicolo(c, voci: voci, pagine: pagina - 1, indiceInCopertina: inCopertina)
        let apertura = ImpaginaReport.pagine(copertina: AnyView(copertina),
                                             interne: inCopertina ? [] : [AnyView(IndiceFascicolo(voci: voci))],
                                             intestazione: "Fascicolo dell'incontro · \(c.nome)")
        // Il piede di ogni pagina conta dall'inizio del fascicolo, come l'indice
        let totalePagine = pagina - 1
        var tutte: [AnyView] = apertura.map {
            AnyView($0.environment(\.numerazioneFascicolo, NumerazioneFascicolo(scostamento: 0, totale: totalePagine)))
        }
        for (i, parte) in parti.enumerated() {
            let numerazione = NumerazioneFascicolo(scostamento: voci[i].1 - 1, totale: totalePagine)
            tutte += parte.1.pagine.map { AnyView($0.environment(\.numerazioneFascicolo, numerazione)) }
        }
        return DocumentoStampabile(report: Self.titoloFascicolo(data, conOra: incontro != nil), cliente: c.nome, pagine: tutte)
    }

    /// L'appuntamento del fascicolo, se è proprio di questo cliente.
    private func incontroDelFascicolo(_ c: Cliente) -> Appuntamento? {
        fascicoloAppuntamento.flatMap { id in appuntamenti.first { $0.id == id && $0.clienteId == c.id } }
    }

    /// La copertina del fascicolo: il ruolo e le etichette dai canali delle posizioni del cliente, la data e il tipo
    /// d'incontro dall'appuntamento; con `indiceInCopertina` il riquadro «Dentro» al posto dei cartellini.
    func copertinaFascicolo(_ c: Cliente, voci: [(String, Int)], pagine: Int, indiceInCopertina: Bool) -> CopertinaReport {
        let canali = Canale.allCases.filter { k in posizioniCliente(c.id).contains { $0.canale == k && $0.stato != .chiusa } }
        // Dal 25 novembre 2026 (decisione dell'utente) un solo canale, quello di Lucy: lo stesso ruolo per tutti
        let ruolo = "Consulenza finanziaria"
        // Per un appuntamento: la data e il tipo d'incontro
        let incontro = incontroDelFascicolo(c)
        let data = incontro?.inizio ?? Date()
        return CopertinaReport(occhiello: "Fascicolo dell'incontro", titolo: "Il punto insieme",
                               sottotitolo: incontro.map { "\($0.tipo.nome) del \(CifreDoc.data($0.inizio)): i documenti che abbiamo visto insieme" }
                                   ?? "I documenti che abbiamo visto oggi, in un solo fascicolo",
                               nomi: c.nome, ruolo: ruolo, data: data, canali: canali.isEmpty ? [.indipendente] : canali,
                               cartellini: [("Documenti", ["\(voci.count)"]), ("Pagine", ["\(pagine)"])],
                               indice: indiceInCopertina ? voci : nil)
    }

    #if os(macOS)
    /// Migliorie d'uso 70: i report spuntati che il cliente ha davvero, nell'ordine scelto (quelli del fascicolo).
    var reportPresentiFascicolo: [TipoProspetto] {
        reportFascicolo.filter { pagineFascicolo($0) != nil }
    }

    /// Migliorie d'uso 70: l'incontro scritto nell'occhiello della scheda («incontro di oggi, 2 novembre» o «Revisione
    /// del 20 novembre»), e se il fascicolo è legato a un appuntamento.
    func incontroScheda(oggi: Date = Date()) -> (testo: String?, legato: Bool) {
        let cal = Calendar.current
        if let c = clienteAttivo, let a = incontroDelFascicolo(c) {
            let giorno = Formati.giornoMese.string(from: a.inizio)
            return (cal.isDate(a.inizio, inSameDayAs: oggi) ? TestiFascicolo.incontroDiOggi(giorno)
                                                            : TestiFascicolo.incontroDel(a.tipo.nome, giorno), true)
        }
        let diOggi = appuntamentiCliente(clienteAttivoId).contains {
            cal.isDate($0.inizio, inSameDayAs: oggi) && $0.stato != .concluso && $0.tipo != .nonDisponibile
        }
        return (diOggi ? TestiFascicolo.incontroDiOggi(Formati.giornoMese.string(from: oggi)) : nil, false)
    }

    /// Migliorie d'uso 70: «Mostra al cliente» dalla scheda: il fascicolo dalla copertina (decisione 70-c), nella vista
    /// pulita, con il contatore «1 di 3 · fascicolo» e le annotazioni all'appuntamento del fascicolo.
    func mostraFascicolo() {
        guard let d = documentoFascicolo(), let c = clienteAttivo else { return }
        let appuntamento = incontroDelFascicolo(c)?.id
        mostraProspetto(d, daPagina: 0)
        guard presentazione != nil else { return }
        presentazione?.etichettaContatore = TestiFascicolo.etichettaContatore
        if let id = appuntamento, presentazione?.clienteId == c.id { presentazione?.appuntamentoId = id }
    }
    #endif

    /// «Fascicolo dell'incontro del 28/10/2026 ore 10:00»: con data e ora dell'appuntamento l'archivio in Documenti
    /// tiene un fascicolo per incontro, anche con due incontri nello stesso giorno.
    static func titoloFascicolo(_ data: Date, conOra: Bool = true) -> String {
        "Fascicolo dell'incontro del \(CifreDoc.dataBreve(data))" + (conOra ? " ore \(Formati.ora.string(from: data))" : "")
    }

    /// Dall'Agenda: i report adatti all'appuntamento, già spuntati, nel fascicolo del cliente.
    func preparaFascicolo(per a: Appuntamento) {
        clienteAttivoId = a.clienteId
        sceltaFascicolo = TipoProspetto.perIncontro(a, posizione: a.posizioneId.flatMap { id in posizioni.first { $0.id == id } })
        fascicoloAppuntamento = a.id
        apriProspetto(.fascicolo)
    }

    /// Il fascicolo già archiviato nei Documenti del cliente per questo appuntamento.
    func fascicoloArchiviato(per a: Appuntamento) -> Documento? {
        let titolo = "Report · " + Self.titoloFascicolo(a.inizio)
        return dati.documenti.first { $0.clienteId == a.clienteId && $0.titolo == titolo }
    }
}

/// L'indice del fascicolo: ogni documento con la pagina da cui comincia.
struct IndiceFascicolo: View {
    @Environment(\.paletteDocumento) private var C
    let voci: [(String, Int)]

    /// Con molti documenti le righe si stringono, per restare nella pagina.
    private var fitto: Bool { voci.count > Misure.Documento.schedeReport + 2 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TestaReport(occhiello: "Indice", titolo: "Cosa trovi in questo fascicolo",
                        sottotitolo: "Ogni documento ha la sua copertina e le sue pagine; i numeri qui sotto contano dall'inizio del fascicolo.")
            VStack(spacing: 0) {
                ForEach(Array(voci.enumerated()), id: \.offset) { i, v in
                    HStack(alignment: .firstTextBaseline, spacing: 14) {
                        Text(verbatim: String(format: "%02d", i + 1)).font(fitto ? T.titoloRiquadro : T.sintesiNumero).foregroundColor(C.occhiello).frame(width: 40, alignment: .leading)
                        Text(verbatim: v.0).font(T.titoloRiquadro).foregroundColor(C.titolo)
                        Spacer(minLength: 10)
                        Text(verbatim: "pagina \(v.1)").font(T.piccolo).foregroundColor(C.tenue)
                    }
                    .padding(.vertical, fitto ? 4 : 9)
                    Rectangle().fill(C.filetto).frame(height: 0.6)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .riquadroDoc()
            Spacer(minLength: 0)
        }
    }
}
