#if os(macOS)
import SwiftUI

// Migliorie d'uso 14 «Le posizioni prima di tutto» (Design/uso/gruppo-02.md §14.3, template `posQuadroHTML`): la
// prima schermata della vista del cliente in Posizioni.
//
//   [Patrimonio netto] [Premi e versamenti] [Capitale assicurato] [Proposte aperte]
//   ┌ Le posizioni  6 voci   (In essere|Proposte|Tutte) ┐                            ┌ Ripartizione per area ┐
//   │ (■ Protezione ✕)                                                                 │  │ anello · legenda = filtro│
//   │ ■ Nome                                     Scade tra 20 giorni  Alleanza  12.000 € › │  └───────────────────────┘
//   │   Area · Tipologia                                                                │  ┌ Da fare ──────────────┐
//   │ ─────────────────────────────────────────────────────────────────────────────── │  │                        │
//   │ Tocca una riga per la scheda della posizione.                                    │  │ 3 da fare per Marco ›  │
//   └────────────────────────────────────────────────────────────────────────────────┘  └───────────────────────┘
//
// - Le cifre (tessere, ripartizione, canali) sono sempre del cliente intero (`riepilogoPosizioniCliente`, in cache):
//   i filtri (stato, canale, area) filtrano solo l'elenco, che arriva già filtrato e ordinato da `AppPosizioni`.
// - A ogni cambio di filtro l'elenco rientra (opacità e y +6, 0,24 s); con «Riduci movimento» la dissolvenza calma,
//   nelle istantanee di colpo.
// - L'elenco scorre dentro la card, pigro (`LazyVStack`): con molte posizioni la pagina non si allunga. Le analisi
//   non si costruiscono qui (stanno nelle loro schermate, AnalisiPosizioniApple.swift).
// Valori in DesignSystem/Apple/Tema.Apple+Posizioni.swift (`Posizioni.Quadro`).

struct QuadroPosizioniApple: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    let cliente: Cliente
    @Binding var filtroStato: AppPosizioni.FiltroStato
    @Binding var filtroCanale: Canale?
    @Binding var area: AreaPosizione?
    /// Le posizioni filtrate e ordinate per area (poi per valore), come le prepara `AppPosizioni`.
    let elenco: [Posizione]
    let apri: (Posizione) -> Void

    /// «In essere» al posto di «Attive» (le stesse parole ovunque, migliorie d'uso 10).
    static let opzioniStato: [(AppPosizioni.FiltroStato, String)] = [(.inEssere, "In essere"), (.proposte, "Proposte"),
                                                                      (.tutte, "Tutte")]

    /// Cambia a ogni filtro: l'elenco rientra.
    private struct ChiaveFiltri: Hashable {
        let stato: AppPosizioni.FiltroStato
        let canale: Canale?
        let area: AreaPosizione?
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        let k = Tema.Apple.Posizioni.Quadro.self
        let r = stato.riepilogoPosizioniCliente(cliente.id)
        return VStack(alignment: .leading, spacing: k.spazio) {
            tessere(r)
                .entrataCascata(0, base: 0)
            HStack(alignment: .top, spacing: k.spazio) {
                cardPosizioni
                    .entrataCascata(1, base: 0)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: k.spazio) {
                        PannelloAnalisi(titolo: "Ripartizione per area",
                                        nota: "Tocca un'area per vedere solo quelle posizioni") { EmptyView() } contenuto: {
                            AppPosizioni.ripartizione(r, areaScelta: area, scegli: { a in
                                area = area == a ? nil : a
                            })
                        }
                        // Dal 25 novembre 2026 (decisione dell'utente) un solo canale, quello di Lucy: al posto della
                        // card «Per canale» resta solo il «Da fare» del cliente
                        if !stato.inModoCliente {
                            PannelloAnalisi(titolo: "Da fare", nota: "Per questo cliente") { EmptyView() } contenuto: {
                                daFare
                            }
                        }
                    }
                }
                .frame(width: k.larghezzaDestra)
                .entrataCascata(2, base: 0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(k.margine)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Le tessere

    /// Le quattro cifre del cliente intero, con le note del template.
    private func tessere(_ r: RiepilogoPosizioni) -> some View {
        FasciaKPI {
            KPI(titolo: "Patrimonio netto", valore: Formati.euro(r.patrimonioNetto)) {
                Chip(testo: "Attività \(Formati.euroBreve(r.attivita))")
                if r.debiti > 0 {
                    Chip(testo: "Debiti \(Formati.euroBreve(r.debiti))")
                }
            }
            KPI(titolo: "Premi e versamenti", valore: Formati.euro(r.premiAnnui)) {
                if r.contrattiConPremi > 0 {
                    Text("all'anno · \(r.contrattiConPremi) \(r.contrattiConPremi == 1 ? "contratto" : "contratti")")
                } else {
                    Text("nessun versamento a rate")
                }
            }
            KPI(titolo: "Capitale assicurato", valore: Formati.euro(r.capitaleAssicurato)) {
                Text(Self.notaCapitale(r))
            }
            // «per x €» senza «l'anno»: `valoreProposte` è il versamento iniziale più un anno di premi, non un valore
            // annuo (come nella quarta tessera del dossier, migliorie d'uso 12)
            KPI(titolo: "Proposte aperte", valore: "\(r.proposteAperte)", ultimo: true) {
                Text(r.proposteAperte > 0 ? "per \(Formati.euro(r.valoreProposte))" : "nessuna")
            }
        }
    }

    /// «caso morte» quando le coperture sono tutte sulla vita (come nel template), altrimenti il loro numero:
    /// la tessera somma il capitale di tutte le coperture e non deve dire più di quello che conta.
    static func notaCapitale(_ r: RiepilogoPosizioni) -> String {
        guard r.coperture > 0 else { return "nessuna copertura" }
        let rischi = r.perRischio.filter { $0.value > 0 }.map(\.key)
        if !rischi.isEmpty, rischi.allSatisfy({ $0 == .vita }) { return "caso morte" }
        return "\(r.coperture) \(r.coperture == 1 ? "copertura" : "coperture")"
    }

    // MARK: - La card «Le posizioni»

    private var cardPosizioni: some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        let a = Tema.Apple.SuperficiAnalisi.self
        let chiave = ChiaveFiltri(stato: filtroStato, canale: filtroCanale, area: area)
        return VStack(alignment: .leading, spacing: k.spazioTesta) {
            // Titolo, conto e filtri su una riga; se non ci stanno, i filtri vanno sotto il titolo
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: k.spazioTesta) {
                    titoloCard
                    Spacer(minLength: k.spazioTesta)
                    filtri
                }
                VStack(alignment: .leading, spacing: k.spazioFiltri) {
                    titoloCard
                    filtri
                }
            }
            if let area {
                capsulaArea(area)
            }
            ScrollView(.vertical, showsIndicators: true) {
                elencoRighe
                    .id(chiave)
                    .transition(.opacity.combined(with: .offset(y: k.spostamentoRientro)))
            }
            .animation(Tema.Apple.Moto.animazione(k.rientro, calmo: calmo, istantanea: istantanea), value: chiave)
            .frame(maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: 0) {
                Rectangle().fill(k.filo).frame(height: Tema.Misura.filo)
                Text("Tocca una riga per la scheda della posizione.")
                    .carattereApple(k.piede)
                    .foregroundColor(k.colorePiede)
                    .padding(.top, k.paddingPiede)
            }
        }
        .padding(a.paddingPannello)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(a.pannello, raggio: a.raggioPannello)
    }

    private var titoloCard: some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        return HStack(alignment: .firstTextBaseline, spacing: k.spazioTesta) {
            Text("Le posizioni")
                .carattereApple(k.titoloCard)
                .foregroundColor(k.coloreTitolo)
                .lineLimit(1)
            // «{n} voci» sparisce con zero risultati
            if !elenco.isEmpty {
                Text("\(elenco.count) \(elenco.count == 1 ? "voce" : "voci")")
                    .carattereApple(k.conto)
                    .foregroundColor(k.coloreConto)
                    .lineLimit(1)
            }
        }
        .fixedSize()
    }

    /// Il segmentato dello stato. Dal 25 novembre 2026 (decisione dell'utente: un solo canale, quello di Lucy)
    /// niente più capsule dei canali.
    private var filtri: some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        return HStack(spacing: k.spazioFiltri) {
            SegmentatoPillola(selezione: $filtroStato, voci: Self.opzioniStato)
                .fixedSize()
        }
    }

    /// Il filtro di area scelto dalla legenda, con «✕» per toglierlo.
    private func capsulaArea(_ a: AreaPosizione) -> some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        return Button {
            area = nil
        } label: {
            HStack(spacing: k.spazioFiltro) {
                RoundedRectangle(cornerRadius: k.raggioSegno, style: .continuous)
                    .fill(Colori.Analisi.area(a))
                    .frame(width: k.segnoAreaFiltro, height: k.segnoAreaFiltro)
                Text(a.nome)
                    .carattereApple(k.filtro)
                    .foregroundColor(k.coloreNomeRiga)
                Image(systemName: "xmark")
                    .font(k.simboloChiudi.font)
                    .foregroundColor(k.testoFiltro)
            }
            .padding(k.paddingFiltro)
            .background { Capsule(style: .continuous).fill(k.fondoFiltro) }
            .contentShape(Capsule(style: .continuous))
            .fixedSize()
        }
        .buttonStyle(StileSemplice())
        .help("Togli il filtro: tutte le aree")
        .accessibilityLabel("\(a.nome), togli il filtro")
    }

    @ViewBuilder private var elencoRighe: some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        if elenco.isEmpty {
            Text("Niente con questi filtri.")
                .carattereApple(k.sottoRiga)
                .foregroundColor(k.coloreSottoRiga)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, k.paddingRiga)
        } else {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(elenco) { p in
                    RigaPosizioneApple(posizione: p) { apri(p) }
                }
            }
        }
    }

    // MARK: - Da fare

    /// «{n} da fare per {nome} ›» (apre il «Da fare» sul cliente) o «Niente da fare per {nome}.»; non in modalità
    /// cliente, come il «Da fare» del dossier.
    @ViewBuilder private var daFare: some View {
        if !stato.inModoCliente {
            let k = Tema.Apple.Posizioni.Quadro.self
            let nome = StatoShell.nomeDiBattesimo(cliente)
            let n = stato.nastroDaFareCompleto(cliente: cliente.id).totale
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if n > 0 {
                        Button { stato.apriDaFare(soloCliente: true) } label: {
                            Text("\(n) da fare per \(nome) ›")
                                .carattereApple(k.daFare)
                                .foregroundColor(k.coloreDaFare)
                        }
                        .buttonStyle(StileSemplice())
                        .help("Apri il «Da fare» di \(nome)")
                    } else {
                        Text("Niente da fare per \(nome).")
                            .carattereApple(k.nienteDaFare)
                            .foregroundColor(k.coloreNienteDaFare)
                    }
                }
            }
        }
    }
}

// MARK: - Una riga dell'elenco

/// Una posizione nell'elenco del quadro: segno dell'area, nome e «{area} · {tipologia}» (per le proposte «Proposta ·
/// {esito}»); a destra la scadenza vicina, la capsula «Proposta», il canale, l'importo e «›».
struct RigaPosizioneApple: View {
    let posizione: Posizione
    let apri: () -> Void

    @Environment(\.modoIstantanea) private var istantanea
    @State private var sopra = false

    private var proposta: Bool { posizione.stato == .proposta }

    var body: some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        let p = posizione
        let forma = RoundedRectangle(cornerRadius: k.raggioRiga, style: .continuous)
        return Button(action: apri) {
            HStack(spacing: k.spazioRiga) {
                RoundedRectangle(cornerRadius: k.raggioSegno, style: .continuous)
                    .fill(Colori.Analisi.area(p.area))
                    .opacity(proposta ? k.opacitaSegnoProposta : 1)
                    .frame(width: k.segno, height: k.segno)
                VStack(alignment: .leading, spacing: k.spazioNomeSotto) {
                    Text(p.nome.isEmpty ? "Senza nome" : p.nome)
                        .carattereApple(k.nomeRiga)
                        .foregroundColor(k.coloreNomeRiga)
                    Text(sotto)
                        .carattereApple(k.sottoRiga)
                        .foregroundColor(k.coloreSottoRiga)
                }
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
                if let avviso {
                    Text(avviso.testo)
                        .carattereApple(k.avviso)
                        .foregroundColor(avviso.colore)
                        .lineLimit(1)
                        .fixedSize()
                }
                if proposta {
                    Text("Proposta")
                        .carattereApple(k.capsulaProposta)
                        .foregroundColor(k.coloreProposta)
                        .padding(k.paddingCapsula)
                        .background { Capsule(style: .continuous).fill(k.fondoProposta) }
                        .fixedSize()
                }
                EtichettaCanaleApple(canale: p.canale, compatta: true)
                importo
                    .frame(minWidth: k.larghezzaImporto, alignment: .trailing)
                Image(systemName: "chevron.right")
                    .font(k.freccia.font)
                    .foregroundColor(k.coloreFreccia)
            }
            .padding(.horizontal, k.paddingRiga)
            .frame(maxWidth: .infinity, minHeight: k.altezzaRiga, alignment: .leading)
            .background { if sopra { forma.fill(k.rigaSopra) } }
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .onHover { dentro in sopra = dentro && !istantanea }
        .help("Apri la scheda della posizione")
    }

    /// «{area} · {tipologia}», o «Proposta · {esito}» per le proposte.
    private var sotto: String {
        let p = posizione
        if proposta { return "Proposta · \(p.esito?.nome ?? "Bozza")" }
        return [p.area.nome, p.tipologia].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    /// «Scade tra {n} giorni» (arancio) o «Scaduta» (rosso), solo per le posizioni in essere.
    private var avviso: (testo: String, colore: Color)? {
        let k = Tema.Apple.Posizioni.Quadro.self
        let p = posizione
        if p.scaduta { return ("Scaduta", k.coloreScaduta) }
        guard p.scadeEntro(RiepilogoPosizioni.giorniScadenza), let s = p.scadenza else { return nil }
        let cal = Calendar.current
        let giorni = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: s)).day ?? 0
        if giorni <= 0 { return ("Scade oggi", k.coloreScadenza) }
        return ("Scade tra \(giorni) \(giorni == 1 ? "giorno" : "giorni")", k.coloreScadenza)
    }

    /// Proposta: il versamento («l'anno» se a rate) in viola; protezione: il capitale con «assicurati»; debito in rosso.
    @ViewBuilder private var importo: some View {
        let k = Tema.Apple.Posizioni.Quadro.self
        let p = posizione
        if proposta {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(Formati.euro(p.premioAnnuo > 0 ? p.premioAnnuo : p.versamentoIniziale))
                    .carattereApple(k.importo)
                if p.premioAnnuo > 0 {
                    Text("l'anno").carattereApple(k.unitaImporto)
                }
            }
            .foregroundColor(k.coloreProposta)
            .lineLimit(1)
            .fixedSize()
        } else if p.area == .protezione {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(Formati.euro(p.capitaleAssicurato ?? 0))
                    .carattereApple(k.importo)
                    .foregroundColor(k.coloreImporto)
                Text("assicurati")
                    .carattereApple(k.unitaImporto)
                    .foregroundColor(k.coloreSottoRiga)
            }
            .lineLimit(1)
            .fixedSize()
        } else if p.area.passivo {
            Text("−\(Formati.euro(p.valore))")
                .carattereApple(k.importo)
                .foregroundColor(k.coloreDebito)
                .lineLimit(1)
                .fixedSize()
        } else {
            Text(Formati.euro(p.valore))
                .carattereApple(k.importo)
                .foregroundColor(k.coloreImporto)
                .lineLimit(1)
                .fixedSize()
        }
    }
}
#endif
