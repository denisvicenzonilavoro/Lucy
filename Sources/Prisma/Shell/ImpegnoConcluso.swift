import SwiftUI

// Migliorie d'uso 19 (Design/uso/gruppo-03.md §19): un impegno passato chiede com'è andato.
//
// Sul Mac la traccia dell'impegno (TracciaImpegnoApple, 860×500) cambia con il momento (MomentoImpegno, miglioria 18):
// prima dell'ora resta com'è; dopo l'ora o già chiuso diventa la scheda dell'incontro concluso:
//
//   ◯  INCONTRO CONCLUSO · MARTEDÌ 3 NOVEMBRE                           [Alleanza]   ✕
//      Il punto sul progetto casa
//      Giulia Rossi · 09:30 – 10:15 · In studio
//   COM'È ANDATA?                                       ┌ Il verbale ─────────────┐
//   (✓ Accettata) (Rimandata) (Rifiutata) (Ci deve…)    │ Non ancora scritto       │
//   PUNTI TOCCATI                                       ├ Cosa succede adesso ────┤
//   ○ La proposta: …                                    │ …                        │
//   [Scrivi il verbale] [Apri il dossier] [Altro ⌄]
//
// - «Com'è andata?»: con una proposta collegata ancora aperta le quattro scelte della proposta (decisione 19-a), che
//   passano dal modulo di sempre (FormEsitoProposta a capsule: l'accettazione chiede decorrenza e valori, il rinvio la
//   data); un impegno ancora pianificato si segna concluso prima dell'esito, così la proposta risulta presentata. A
//   esito dato la capsula dell'esito resta accesa, senza tocco. Senza proposta una capsula sola, «Concluso».
// - «Punti toccati»: i punti da toccare, che si spuntano a mano; le spunte restano in memoria (decisione 19-b).
// - «Il verbale» e «Cosa succede adesso» a destra; nel piede un solo pulsante blu, «Scrivi il verbale» (Incontri,
//   momento «Dopo»), «Apri il dossier» e «Altro ⌄» (Riapri l'incontro, Modifica, Attività collegata, fascicolo).
// Nessun campo nuovo nell'archivio: gli esiti sono quelli della proposta, lo stato concluso è dell'appuntamento.

// MARK: - Testi

extension TestiAgendaApple {
    static let incontroConcluso = "Incontro concluso"
    static let comeEAndata = "Com'è andata?"
    static let puntiToccati = "Punti toccati"
    static let ilVerbale = "Il verbale"
    static let verbalePronto = "Pronto, da confermare"
    static let verbaleNonScritto = "Non ancora scritto"
    static let verbaleConfermato = "Confermato"
    static let verbaleDove = "sta in Incontri, nel momento «Dopo»"
    static let cosaSuccedeAdesso = "Cosa succede adesso"
    static let scriviIlVerbale = "Scrivi il verbale"
    static let altro = "Altro"
    static let riapriLIncontro = "Riapri l'incontro"
    static let sceltaConcluso = "Concluso"
    static let segnatoConcluso = "Segnato: concluso"
    /// Decisione 19-c: «Cosa succede adesso» senza una proposta.
    static let prossimoPassoNelVerbale = "Il prossimo passo si decide nel verbale."
    // Le voci del menu «Altro» con le parole del dettaglio di sempre (DettaglioAppuntamento)
    static let modifica = "Modifica"
    static let attivitaCollegata = "Attività collegata"
    static let preparaIlFascicolo = "Prepara il fascicolo"
    static let apriIlFascicolo = "Apri il fascicolo"
    static let apriIlDossier = "Apri il dossier"

    /// «Incontro concluso · Martedì 3 novembre» (il maiuscolo lo fa il carattere dell'etichetta).
    static func etichettaConcluso(_ g: Date) -> String { "\(incontroConcluso) · \(titoloGiorno(g))" }
}

// MARK: - Regole

/// Il verbale dell'incontro di un impegno, per il riquadro «Il verbale».
enum StatoVerbaleImpegno: Equatable {
    case nonScritto, pronto, confermato

    var testo: String {
        switch self {
        case .nonScritto: return TestiAgendaApple.verbaleNonScritto
        case .pronto: return TestiAgendaApple.verbalePronto
        case .confermato: return TestiAgendaApple.verbaleConfermato
        }
    }
}

/// Le regole pure della scheda dell'impegno concluso (le prove le chiamano senza viste).
enum RegoleImpegnoConcluso {
    /// «Confermato» se l'incontro è concluso (o il resoconto è firmato); «Pronto, da confermare» se il copilota di
    /// quell'incontro ha schede ancora da confermare o un verbale non confermato, o c'è un resoconto da firmare;
    /// altrimenti «Non ancora scritto». Solo le sessioni dell'incontro (mai quelle di un altro incontro del cliente).
    static func verbale(incontro: Incontro?, sessioni: [SessioneCopilota]) -> StatoVerbaleImpegno {
        guard let i = incontro else { return .nonScritto }
        if i.stato == .concluso || i.resoconto?.firmatoIl != nil { return .confermato }
        if i.resoconto != nil { return .pronto }
        for s in sessioni where s.incontroId == i.id {
            if s.schede.contains(where: { $0.stato == .proposta }) { return .pronto }
            if let v = s.verbale, v.confermatoIl == nil { return .pronto }
        }
        return .nonScritto
    }

    /// La scelta da tenere accesa quando l'esito della proposta è stato dato in questo impegno (nil altrimenti):
    /// le stesse parole delle capsule (`TestiSeguito`). «Ci deve pensare» lascia la proposta presentata.
    static func sceltaAccesa(_ a: Appuntamento, proposta p: Posizione?) -> String? {
        guard let p, p.id == a.posizioneId, p.seguito?.appuntamentoEsitoId == a.id else { return nil }
        switch p.esito {
        case .accettata?: return TestiSeguito.sceltaAccettata
        case .rimandata?: return TestiSeguito.sceltaRimandata
        case .rifiutata?: return TestiSeguito.sceltaRifiutata
        case .presentata?: return TestiSeguito.sceltaInAttesa
        case .bozza?, nil: return nil
        }
    }
}

/// Ciò che la traccia di un impegno chiede all'Agenda dal menu «Altro» (il modulo vive nell'Agenda).
enum RichiestaModuloImpegno: Equatable {
    case modifica(String)
    case attivita(String)
}

extension StatoShell {
    /// Il verbale dell'incontro dell'impegno (letto al momento, non in cache: una sola scheda aperta alla volta).
    func statoVerbale(_ e: Appuntamento) -> StatoVerbaleImpegno {
        guard let i = dati.incontri.first(where: { $0.appuntamentoId == e.id }) else { return .nonScritto }
        return RegoleImpegnoConcluso.verbale(incontro: i, sessioni: dati.sessioniCopilota.filter { $0.incontroId == i.id })
    }

    /// Prima di un esito dalla scheda: un impegno ancora pianificato si segna concluso (parte `segnaConclusione`, la
    /// proposta diventa «presentata», come con «Segna concluso»). Un impegno già concluso non cambia.
    func preparaEsitoImpegno(_ id: String) {
        guard let a = appuntamento(id), a.stato == .pianificato else { return }
        alternaConcluso(id)
    }

    /// La capsula «Concluso» (impegno senza proposta): segna concluso e lo dice. Riaprire passa da «Altro».
    func segnaConclusoImpegno(_ id: String) {
        guard let a = appuntamento(id), a.stato == .pianificato else { return }
        alternaConcluso(id)
        mostraAvviso(TestiAgendaApple.segnatoConcluso)
    }

    /// «Prepara il fascicolo» / «Apri il fascicolo»: le due strade del dettaglio di sempre.
    func fascicoloImpegno(_ e: Appuntamento) {
        if let d = fascicoloArchiviato(per: e) {
            if !e.clienteId.isEmpty { clienteAttivoId = e.clienteId }
            documentoSelezionato = d.id
            apri(.documenti)
        } else {
            preparaFascicolo(per: e)
        }
    }
}

// MARK: - Scelte a capsula

/// Le scelte a capsula di «Com'è andata?» (`.fch` alte 36): in una riga se ci stanno, altrimenti due per riga. Con
/// `azione` nil si leggono soltanto (l'esito è già scritto e non si annulla da qui).
struct ScelteCapsulaApple: View {
    let voci: [String]
    let accesa: String?
    let azione: ((String) -> Void)?

    init(voci: [String], accesa: String?, azione: ((String) -> Void)?) {
        self.voci = voci
        self.accesa = accesa
        self.azione = azione
    }

    var body: some View {
        let t = Tema.Apple.Agenda.Traccia.self
        ViewThatFits(in: .horizontal) {
            HStack(spacing: t.spazioScelte) {
                ForEach(voci, id: \.self) { v in capsula(v) }
            }
            VStack(alignment: .leading, spacing: t.spazioScelte) {
                HStack(spacing: t.spazioScelte) {
                    ForEach(Array(voci.prefix(2)), id: \.self) { v in capsula(v) }
                }
                HStack(spacing: t.spazioScelte) {
                    ForEach(Array(voci.dropFirst(2)), id: \.self) { v in capsula(v) }
                }
            }
        }
    }

    private func capsula(_ v: String) -> some View {
        var chiama: (() -> Void)? = nil
        if let azione = self.azione { chiama = { azione(v) } }
        return CapsulaSceltaApple(titolo: v, accesa: v == accesa, azione: chiama)
    }
}

private struct CapsulaSceltaApple: View {
    let titolo: String
    let accesa: Bool
    let azione: (() -> Void)?

    var body: some View {
        if let azione {
            Button(action: azione) { forma }
                .buttonStyle(StileSemplice())
                .accessibilityAddTraits(accesa ? AccessibilityTraits.isSelected : AccessibilityTraits())
        } else {
            forma
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(titolo))
                .accessibilityAddTraits(accesa ? AccessibilityTraits.isSelected : AccessibilityTraits())
        }
    }

    private var forma: some View {
        let t = Tema.Apple.Agenda.Traccia.self
        let capsula = Capsule(style: .continuous)
        return Text(titolo)
            .carattereApple(t.carattereScelta)
            .foregroundColor(accesa ? t.testoSceltaAccesa : t.testoScelta)
            .lineLimit(1)
            .fixedSize()
            .padding(t.paddingScelta)
            .frame(height: t.altezzaScelta)
            .background {
                if accesa {
                    capsula.fill(t.fondoSceltaAccesa).ombraApple(t.ombraSceltaAccesa)
                } else {
                    capsula.fill(t.fondoScelta)
                }
            }
            .contentShape(capsula)
    }
}

#if os(macOS)

// MARK: - Corpo della scheda concluso

/// Le due colonne della scheda di un impegno passato o chiuso: «Com'è andata?» e «Punti toccati» a sinistra (dentro
/// uno ScrollView: i passi dell'accettazione allungano la colonna), «Il verbale» e «Cosa succede adesso» a destra.
struct CorpoImpegnoConcluso: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    let evento: Appuntamento
    let punti: [String]
    /// Decisione 19-b: le spunte dei punti toccati restano in memoria.
    @State private var toccati: Set<Int> = []

    var body: some View {
        let t = Tema.Apple.Agenda.Traccia.self
        let proposta = evento.posizioneId.flatMap { id in stato.posizioni.first { $0.id == id } }
        let collegata = stato.propostaCollegata(evento)
        let accesa = RegoleImpegnoConcluso.sceltaAccesa(evento, proposta: proposta)
        HStack(alignment: .top, spacing: t.spazioColonne) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    occhiello(TestiAgendaApple.comeEAndata)
                        .padding(.bottom, t.sottoOcchiello)
                    comeEAndata(collegata: collegata, accesa: accesa)
                    occhiello(TestiAgendaApple.puntiToccati)
                        .padding(.top, t.sopraPuntiToccati)
                        .padding(.bottom, t.sottoPuntiToccati)
                    ForEach(Array(punti.enumerated()), id: \.offset) { i, p in
                        Button { alterna(i) } label: {
                            VoceTiPreparoApple(testo: p, fatta: toccati.contains(i), animazione: animazione)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(StileSemplice())
                    }
                }
                .padding(.bottom, t.sfumaturaColonna)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .sfumaturaBordiScorrimento(sotto: t.sfumaturaColonna)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            VStack(alignment: .leading, spacing: t.spazioTile) {
                RiquadroTracciaApple(nome: TestiAgendaApple.ilVerbale) {
                    Text(stato.statoVerbale(evento).testo)
                        .carattereApple(t.statoVerbale)
                        .foregroundColor(t.coloreStatoVerbale)
                        .lineLimit(1)
                    Text(TestiAgendaApple.verbaleDove)
                        .carattereApple(t.nota)
                        .foregroundColor(t.coloreNota)
                        .fixedSize(horizontal: false, vertical: true)
                }
                RiquadroTracciaApple(nome: TestiAgendaApple.cosaSuccedeAdesso) {
                    Text(collegata != nil || accesa != nil
                         ? TestiSeguito.notaInAttesa(giorni: stato.dati.impostazioni.giorniSeguitoProposte)
                         : TestiAgendaApple.prossimoPassoNelVerbale)
                        .carattereApple(t.testoAdesso)
                        .foregroundColor(t.coloreTestoAdesso)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, t.sopraTestoAdesso)
                }
            }
            .frame(width: t.larghezzaTile)
        }
    }

    private func occhiello(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(Tema.Apple.Agenda.Traccia.etichetta)
            .foregroundColor(Tema.Apple.Agenda.Traccia.coloreNota)
            .lineLimit(1)
    }

    /// Con una proposta aperta il modulo di sempre a capsule; a esito dato la sua capsula accesa; altrimenti
    /// «Concluso».
    @ViewBuilder private func comeEAndata(collegata: Posizione?, accesa: String?) -> some View {
        let id = evento.id
        if let p = collegata {
            FormEsitoProposta(posizione: p, appuntamento: evento, passoIniziale: .scelta, compatto: true,
                              datiProposti: stato.datiAccettazione(p, appuntamento: evento),
                              giorniSeguito: stato.dati.impostazioni.giorniSeguitoProposte,
                              conferma: { esito in
                                  // Mai `chiudiProposta` su un impegno ancora pianificato: prima si segna concluso
                                  stato.preparaEsitoImpegno(id)
                                  stato.chiudiProposta(p.id, esito, appuntamentoId: id)
                              },
                              capsule: true,
                              primaDellaScelta: { stato.preparaEsitoImpegno(id) })
                .id(p.id + "·" + id)
        } else if let accesa {
            ScelteCapsulaApple(voci: FormEsitoProposta.vociCapsule, accesa: accesa, azione: nil)
        } else {
            let concluso = evento.stato == .concluso
            let tocca: ((String) -> Void)? = concluso ? nil : { _ in stato.segnaConclusoImpegno(id) }
            ScelteCapsulaApple(voci: [TestiAgendaApple.sceltaConcluso],
                               accesa: concluso ? TestiAgendaApple.sceltaConcluso : nil,
                               azione: tocca)
        }
    }

    private var animazione: Animation? {
        if istantanea { return nil }
        if calmo { return Tema.Moto.dissolvenzaCalma }
        return Tema.Apple.Moto.TiPreparo.ripiego.animazione
    }

    private func alterna(_ i: Int) {
        if toccati.contains(i) { toccati.remove(i) } else { toccati.insert(i) }
    }
}

// MARK: - Menu «Altro»

/// «Altro ⌄» della scheda concluso e del dettaglio di «Giorno»: Riapri l'incontro (se è concluso), Modifica, Attività
/// collegata, Prepara o Apri il fascicolo. `prima` chiude la scheda prima di lasciare l'Agenda.
struct MenuAltroImpegno: View {
    @Environment(StatoShell.self) var stato
    let evento: Appuntamento
    let modifica: () -> Void
    let attivita: () -> Void
    var prima: () -> Void = {}

    var body: some View {
        let t = Tema.Apple.Agenda.Traccia.self
        let archiviato = stato.fascicoloArchiviato(per: evento) != nil
        Menu {
            if evento.stato == .concluso {
                Button(TestiAgendaApple.riapriLIncontro) { stato.alternaConcluso(evento.id) }
            }
            Button(TestiAgendaApple.modifica) { modifica() }
            Button(TestiAgendaApple.attivitaCollegata) { attivita() }
            Button(archiviato ? TestiAgendaApple.apriIlFascicolo : TestiAgendaApple.preparaIlFascicolo) {
                prima()
                stato.fascicoloImpegno(evento)
            }
        } label: {
            HStack(spacing: t.spazioFrecciaAltro) {
                Text(TestiAgendaApple.altro)
                Image(systemName: "chevron.down")
                    .carattereApple(t.frecciaAltro)
                    .opacity(t.opacitaFrecciaAltro)
            }
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .buttonStyle(.appleGrande)
        .fixedSize()
        .disabled(stato.solaLettura)
    }
}

#endif
