#if os(macOS)
import SwiftUI

// Migliorie d'uso 21 «Incontri segue il cliente e non si ferma a oggi» (solo sul Mac; Design/uso/gruppo-03.md §21):
// la colonna a sinistra di Incontri con tre gruppi, «Oggi», «Prossimi», «Fatti», che segue il cliente scelto nella
// barra (con «Tutti i clienti» mostra tutti). Sostituisce le due tendine (cliente e incontro) e la colonna «Oggi» del
// copilota, che resta sull'iPad. Una riga che è solo un appuntamento mostra «Prima» costruito dall'appuntamento senza
// scrivere niente: l'incontro nasce al primo gesto che scrive (`StatoShell.assicuraIncontro`).

/// Una riga dell'elenco: un appuntamento con un cliente (unito al suo incontro, se c'è) o un incontro senza
/// appuntamento.
struct VoceIncontri: Identifiable, Equatable {
    enum Gruppo: Equatable { case oggi, prossimi, fatti }

    let id: String
    let clienteId: String
    let titolo: String
    let quando: Date
    let gruppo: Gruppo
    let incontroId: String?
    let appuntamentoId: String?
    /// Incontro concluso (la spunta del verbale pronto si legge fuori dalla cache: le sessioni del copilota non
    /// cambiano `versioneCalcoli`).
    let fatto: Bool
    /// Appuntamento passato e senza esito (`MomentoImpegno.daChiudere`): «da chiudere», senza spunta.
    let daChiudere: Bool
}

/// I tre gruppi dell'elenco (un gruppo vuoto non si mostra).
struct GruppiIncontri: Equatable {
    var oggi: [VoceIncontri] = []
    var prossimi: [VoceIncontri] = []
    var fatti: [VoceIncontri] = []

    /// Nell'ordine dell'elenco: oggi, poi prossimi, poi fatti.
    var tutte: [VoceIncontri] { oggi + prossimi + fatti }
    var vuoto: Bool { oggi.isEmpty && prossimi.isEmpty && fatti.isEmpty }
}

/// Le regole dell'elenco (decisione 21-a): «Prossimi» da domani per 14 giorni (al più 20), «Fatti» gli incontri
/// conclusi degli ultimi 12 mesi (al più 30), in testa gli appuntamenti degli ultimi 7 giorni ancora da chiudere.
enum RegoleElencoIncontri {
    static let giorniProssimi = 14
    static let massimoProssimi = 20
    static let mesiFatti = 12
    static let massimoFatti = 30
    static let giorniDaChiudere = 7

    /// I tre gruppi da appuntamenti e incontri. `cliente` nil = tutti i clienti; `visibile` dice se un cliente c'è
    /// (e si vede: in modalità cliente solo il suo). I blocchi «Non disponibile» e gli impegni senza cliente non entrano.
    /// La chiave per non avere doppioni è `Incontro.appuntamentoId`.
    static func calcola(appuntamenti: [Appuntamento], incontri: [Incontro], cliente: String?,
                        visibile: (String) -> Bool, adesso: Date, calendario cal: Calendar = .current) -> GruppiIncontri {
        let inizioOggi = cal.startOfDay(for: adesso)
        let fineOggi = cal.date(byAdding: .day, value: 1, to: inizioOggi) ?? inizioOggi
        let fineProssimi = cal.date(byAdding: .day, value: giorniProssimi, to: fineOggi) ?? fineOggi
        let inizioFatti = cal.date(byAdding: .month, value: -mesiFatti, to: inizioOggi) ?? inizioOggi
        let inizioDaChiudere = cal.date(byAdding: .day, value: -giorniDaChiudere, to: inizioOggi) ?? inizioOggi

        func suo(_ id: String) -> Bool { !id.isEmpty && (cliente == nil || id == cliente) && visibile(id) }

        var perAppuntamento: [String: Incontro] = [:]
        for i in incontri {
            if let a = i.appuntamentoId, perAppuntamento[a] == nil { perAppuntamento[a] = i }
        }
        let idAppuntamenti = Set(appuntamenti.map(\.id))
        let utili = appuntamenti.filter { $0.tipo != .nonDisponibile && suo($0.clienteId) }
        // Gli incontri senza appuntamento (o con un appuntamento che non c'è più)
        let sciolti = incontri.filter { i in
            suo(i.clienteId) && (i.appuntamentoId.map { !idAppuntamenti.contains($0) } ?? true)
        }

        func voce(_ a: Appuntamento, _ g: VoceIncontri.Gruppo) -> VoceIncontri {
            let i = perAppuntamento[a.id]
            let concluso = i?.stato == .concluso
            return VoceIncontri(id: i?.id ?? "appuntamento:\(a.id)", clienteId: a.clienteId, titolo: i?.titolo ?? a.titolo,
                                quando: a.inizio, gruppo: g, incontroId: i?.id, appuntamentoId: a.id, fatto: concluso,
                                daChiudere: !concluso && MomentoImpegno.di(a, adesso: adesso) == .daChiudere)
        }
        func voce(_ i: Incontro, _ g: VoceIncontri.Gruppo) -> VoceIncontri {
            VoceIncontri(id: i.id, clienteId: i.clienteId, titolo: i.titolo, quando: i.data, gruppo: g, incontroId: i.id,
                         appuntamentoId: i.appuntamentoId, fatto: i.stato == .concluso, daChiudere: false)
        }

        var g = GruppiIncontri()
        // Oggi: gli appuntamenti di oggi con un cliente e gli incontri di oggi senza appuntamento, per ora
        g.oggi = (utili.filter { $0.inizio >= inizioOggi && $0.inizio < fineOggi }.map { voce($0, .oggi) }
                  + sciolti.filter { $0.data >= inizioOggi && $0.data < fineOggi }.map { voce($0, .oggi) })
            .sorted { $0.quando < $1.quando }
        // Prossimi: da domani per 14 giorni, al più 20
        g.prossimi = Array((utili.filter { $0.inizio >= fineOggi && $0.inizio < fineProssimi }.map { voce($0, .prossimi) }
                            + sciolti.filter { $0.stato != .concluso && $0.data >= fineOggi && $0.data < fineProssimi }
                                .map { voce($0, .prossimi) })
            .sorted { $0.quando < $1.quando }
            .prefix(massimoProssimi))
        // Fatti: in testa gli appuntamenti passati degli ultimi 7 giorni ancora da chiudere, poi gli incontri conclusi
        let giaInElenco = Set((g.oggi + g.prossimi).map(\.id))
        let daChiudere = utili
            .filter { $0.inizio >= inizioDaChiudere && $0.inizio < inizioOggi }
            .map { voce($0, .fatti) }
            .filter { $0.daChiudere && !giaInElenco.contains($0.id) }
            .sorted { $0.quando > $1.quando }
        let idDaChiudere = Set(daChiudere.map(\.id))
        let conclusi = incontri
            .filter { $0.stato == .concluso && suo($0.clienteId) && $0.data >= inizioFatti && $0.data < inizioOggi }
            .filter { !giaInElenco.contains($0.id) && !idDaChiudere.contains($0.id) }
            .sorted { $0.data > $1.data }
            .prefix(massimoFatti)
            .map { voce($0, .fatti) }
        g.fatti = daChiudere + conclusi
        return g
    }

    /// Il momento su cui si apre una riga: oggi «Ascolto» («Prossimi passi» se il verbale è pronto o l'incontro è
    /// concluso), prossimo «Preparazione», fatto «Prossimi passi».
    static func momento(_ v: VoceIncontri, verbale: Bool) -> SchedaIncontro {
        switch v.gruppo {
        case .oggi: return (verbale || v.fatto) ? .passi : .ascolto
        case .prossimi: return .preparazione
        case .fatti: return .passi
        }
    }

    /// «09:30» oggi, «gio 5 · 15:00» nei prossimi, «30 ottobre» nei fatti (con l'anno se non è quello in corso).
    static func quando(_ v: VoceIncontri, adesso: Date = Date(), calendario cal: Calendar = .current) -> String {
        switch v.gruppo {
        case .oggi: return Formati.ora.string(from: v.quando)
        case .prossimi: return "\(Formati.giornoBreve.string(from: v.quando)) · \(Formati.ora.string(from: v.quando))"
        case .fatti:
            return cal.component(.year, from: v.quando) == cal.component(.year, from: adesso)
                ? Formati.giornoMese.string(from: v.quando) : Formati.dataEstesa.string(from: v.quando)
        }
    }
}

/// I testi dell'elenco di Incontri.
enum TestiIncontri {
    static let oggi = "Oggi"
    static let prossimi = "Prossimi"
    static let fatti = "Fatti"
    static let daChiudere = "da chiudere"
    static func nessunIncontroCon(_ nome: String) -> String { "Nessun incontro con \(nome). Si fissa in Agenda." }
    static let nessunIncontro = "Nessun incontro, per ora."
    static let apriAgenda = "Apri l’Agenda"
    static let aiutoSpento = "Termina l’ascolto per passare a un altro incontro."
}

extension StatoShell {
    /// I tre gruppi dell'elenco di Incontri (nil = tutti i clienti), una volta sola per dati dei calcoli, giorno,
    /// modalità cliente e ora (l'ora perché «da chiudere» e il passaggio da «Prossimi» a «Oggi» dipendono da adesso).
    func elencoIncontri(cliente: String?) -> GruppiIncontri {
        ricavato("incontri-elenco|\(cliente ?? "tutti")|\(DerivatiDati.ora())") { () -> GruppiIncontri in
            RegoleElencoIncontri.calcola(appuntamenti: dati.appuntamenti, incontri: dati.incontri, cliente: cliente,
                                         visibile: { self.cliente($0) != nil }, adesso: Date())
        }
    }

    /// Gli incontri di un cliente dal più recente (per «L'ultima volta»), senza rifiltrare l'archivio a ogni body.
    func incontriClienteRicavati(_ id: String) -> [Incontro] {
        ricavato("incontri-cliente|\(id)") { () -> [Incontro] in incontriCliente(id) }
    }

    /// L'incontro che nascerebbe da un appuntamento senza incontro, con un id fisso (così il primo gesto che scrive lo
    /// salva con quell'id e la scelta non cambia).
    func bozzaIncontroElenco(per a: Appuntamento) -> Incontro {
        ricavato("incontri-bozza|\(a.id)") { () -> Incontro in
            var i = bozzaIncontro(cliente: a.clienteId, appuntamento: a)
            i.id = "incontro-\(a.id)"
            return i
        }
    }

    /// Gli incontri con il verbale del copilota pronto. Si legge nel body dell'elenco, fuori dalla cache (le sessioni
    /// del copilota non cambiano `versioneCalcoli`).
    var incontriConVerbale: Set<String> {
        Set(dati.sessioniCopilota.compactMap { $0.verbale != nil ? $0.incontroId : nil })
    }
}

// MARK: - La colonna

/// La colonna a sinistra di Incontri: le note dall'iPhone da guardare, poi «Oggi», «Prossimi», «Fatti». Mentre il
/// copilota ascolta le righe sono spente (un solo ascolto alla volta) e le spunte del verbale non si rileggono, così
/// la colonna non si rifà a ogni frase.
@MainActor
struct ElencoIncontriApple: View {
    @Environment(StatoShell.self) var stato
    let gruppi: GruppiIncontri
    /// L'incontro mostrato a destra (anche una bozza da un appuntamento).
    let aperto: Incontro?
    /// Il nome del cliente scelto nella barra (nil con «Tutti i clienti»).
    let nomeCliente: String?
    let spento: Bool
    let scegli: (VoceIncontri) -> Void

    private typealias E = Tema.Apple.Copilota.Elenco

    var body: some View {
        let _ = ContaCorpi.segna()
        let note = stato.noteDaGuardare
        let verbali: Set<String> = spento ? [] : stato.incontriConVerbale
        let blocchi: [(String, [VoceIncontri])] = [(TestiIncontri.oggi, gruppi.oggi), (TestiIncontri.prossimi, gruppi.prossimi),
                                                   (TestiIncontri.fatti, gruppi.fatti)].filter { !$0.1.isEmpty }
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // «Luce» giro 13: le note dettate sull'iPhone ancora da guardare, prima degli incontri
                if !note.isEmpty {
                    VStack(alignment: .leading, spacing: E.fraRighe) {
                        ForEach(note) { n in VoceOggiNotaVocale(nota: n) }
                    }
                    .padding(.bottom, E.spazioGruppi)
                }
                ForEach(Array(blocchi.enumerated()), id: \.offset) { k, blocco in
                    VStack(alignment: .leading, spacing: E.fraRighe) {
                        Text(blocco.0)
                            .carattereApple(E.occhielloGruppo)
                            .foregroundColor(E.coloreOcchiello)
                            .padding(.leading, E.rientroOcchiello)
                            .padding(.bottom, E.sottoOcchiello)
                            .accessibilityAddTraits(.isHeader)
                        ForEach(blocco.1) { v in
                            RigaElencoIncontri(voce: v, cliente: stato.cliente(v.clienteId),
                                               scelta: scelta(v), spunta: v.fatto || (v.incontroId.map { verbali.contains($0) } ?? false),
                                               spenta: spento && !scelta(v)) {
                                scegli(v)
                            }
                        }
                    }
                    .padding(.top, k == 0 ? 0 : E.spazioGruppi)
                    .entrataCascata(k, base: Tema.Apple.Moto.Cascata.baseDentroApp, sfocatura: false)
                }
                if gruppi.vuoto, let nomeCliente {
                    Text(TestiIncontri.nessunIncontroCon(nomeCliente))
                        .carattereApple(E.vuoto)
                        .foregroundColor(E.coloreVuoto)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(E.paddingVuoto)
                        .entrataCascata(0, base: Tema.Apple.Moto.Cascata.baseDentroApp, sfocatura: false)
                }
            }
            .padding(.top, E.sopraElenco)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(E.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(E.superficie, raggio: E.raggio)
        .help(spento ? TestiIncontri.aiutoSpento : "")
    }

    /// La riga accesa: quella dell'incontro mostrato, o del suo appuntamento.
    private func scelta(_ v: VoceIncontri) -> Bool {
        guard let aperto else { return false }
        if let id = v.incontroId, id == aperto.id { return true }
        if let a = v.appuntamentoId, a == aperto.appuntamentoId { return true }
        return false
    }
}

/// Una riga dell'elenco (`.rub` del template): avatar 36, nome, «quando · titolo», la spunta verde a destra.
@MainActor
struct RigaElencoIncontri: View {
    let voce: VoceIncontri
    let cliente: Cliente?
    let scelta: Bool
    let spunta: Bool
    let spenta: Bool
    let azione: () -> Void

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @State private var sopra = false

    private typealias E = Tema.Apple.Copilota.Elenco

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: E.raggioRiga, style: .continuous)
        return Button(action: azione) {
            HStack(spacing: E.spazioAvatar) {
                if let c = cliente {
                    AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: E.avatarRiga)
                }
                VStack(alignment: .leading, spacing: E.spazioTitoli) {
                    Text(cliente?.nome ?? "Cliente")
                        .carattereApple(E.nome)
                        .foregroundColor(E.coloreNome)
                        .lineLimit(1)
                    sottoRiga
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer(minLength: 0)
                if spunta {
                    Image(systemName: "checkmark.circle.fill")
                        .carattereApple(E.spunta)
                        .foregroundColor(E.coloreSpunta)
                        .accessibilityLabel("Fatto")
                }
            }
            .padding(E.paddingRiga)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                if scelta {
                    forma.fill(E.fondoScelta)
                } else if sopra {
                    forma.fill(E.fondoSopra)
                }
            }
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .disabled(spenta)
        .opacity(spenta ? E.opacitaSpenta : 1)
        .onHover { dentro in sopra = dentro && !istantanea }
        .animation(Tema.Apple.Moto.animazione(E.animazioneFondo, calmo: calmo, istantanea: istantanea), value: scelta)
        .animation(Tema.Apple.Moto.animazione(E.animazioneFondo, calmo: calmo, istantanea: istantanea), value: sopra)
        .accessibilityAddTraits(scelta ? AccessibilityTraits.isSelected : AccessibilityTraits())
    }

    /// «09:30 · Il punto sul progetto casa», con « · da chiudere» in arancio se l'impegno aspetta l'esito.
    private var sottoRiga: Text {
        let base = Text("\(RegoleElencoIncontri.quando(voce)) · \(voce.titolo)")
            .foregroundColor(E.coloreSottoRiga)
        let testo = voce.daChiudere
            ? base + Text(" · \(TestiIncontri.daChiudere)").foregroundColor(E.coloreDaChiudere)
            : base
        return testo.font(E.sottoRiga.font)
    }
}
#endif
