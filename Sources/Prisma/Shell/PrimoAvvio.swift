#if os(macOS)
import SwiftUI

// Migliorie d'uso 38 «I canali hanno il nome che scegli» (Design/uso/gruppo-06.md §38), solo sul Mac: le tre domande del
// primo avvio (`apriAvvio` del template) al posto dell'introduzione a cinque pagine, e il nome dei canali.
//
//   ┌─ Il primo avvio · 1 di 3 ──────────────────────────────┐
//   │ ▲  Benvenuto in Prisma                                  │  1. benvenuto, tre punti
//   │    Prisma è lo studio di lavoro…                        │  2. i tuoi canali (due campi)
//   │    • I calcoli li fa Prisma: tu scegli e spieghi.       │  3. da dove parti (tre opzioni)
//   │ ━ • •                              [Indietro] [Avanti]   │
//   └─────────────────────────────────────────────────────────┘
//
// «Comincia» segna `introduzioneVista` (la stessa chiave di prima: chi l'ha già vista non rivede le domande). La scelta
// della terza pagina non si conserva. Valori in Tema.Apple.PrimoAvvio (Tema.Apple+Impostazioni.swift).

/// Le tre risposte a «Da dove parti».
enum SceltaInizio: String, CaseIterable, Identifiable {
    case prova, miei, zero

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .prova: return "Guardo Prisma con i clienti di prova"
        case .miei: return "Porto i miei clienti"
        case .zero: return "Parto da zero"
        }
    }

    var testo: String {
        switch self {
        case .prova: return "È la dimostrazione: niente di tuo, niente che esce dal Mac."
        case .miei: return "Importo un elenco o incollo da Excel."
        case .zero: return "Aggiungo il primo cliente a mano."
        }
    }
}

/// I testi delle tre domande (come nel template).
enum TestiPrimoAvvio {
    static let pagine = 3
    static func occhiello(_ pagina: Int) -> String { "Il primo avvio · \(pagina + 1) di \(pagine)" }

    static let benvenuto = "Benvenuto in Prisma"
    static let benvenutoTesto = "Prisma è lo studio di lavoro di un consulente finanziario. Raccoglie le persone che segui e quello che hanno, e ti aiuta a capire che cosa manca e che cosa conviene."
    /// I primi due punti sono quelli della prima pagina dell'introduzione, poi «Tre domande, e poi si comincia.».
    static var punti: [String] {
        Array((PaginaIntroduzione.pagine.first?.punti ?? []).prefix(2)) + ["Tre domande, e poi si comincia."]
    }

    static let canali = "I tuoi canali"
    static let canaliTesto = "Con quali etichette lavori? Prisma le tiene sempre distinte, una blu e una cuoio. Scrivi i nomi come li dici tu."
    static let primoCanale = "Il primo canale"
    static let secondoCanale = "Il secondo canale"
    static let canaliNota = "Li cambi quando vuoi, in Impostazioni › Profilo."

    static let daDove = "Da dove parti"
    static let daDoveTesto = "Puoi cambiare idea dopo: niente di questo è definitivo."

    static let avvisoProva = "Si comincia con la dimostrazione"
    static let avvisoMiei = "Puoi anche incollare da Excel: menu … della Rubrica"

    /// Impostazioni › Profilo.
    static let profiloCanaliNota = "Li hai scelti al primo avvio. Ogni posizione e ogni proposta porta l’etichetta del suo canale: qui cambi il nome, i colori restano questi."
    static let primoCanaleSotto = "Blu, sempre."
    static let secondoCanaleSotto = "Cuoio, sempre."
    static let gruppoAvvio = "Il primo avvio"
    static let rigaAvvio = "Le tre domande della prima volta"
    static let rigaAvvioSotto = "Benvenuto, i tuoi canali, da dove parti."
    static let rivedi = "Rivedi"
}

extension StatoShell {
    /// Apre le tre domande sulla pagina data e chiude gli altri pannelli (come `apriGuida`). Con la schermata di
    /// benvenuto davanti prima si entra, poi le domande compaiono a sblocco finito. Mai in modalità cliente, nella vista
    /// pulita o durante la presentazione.
    func apriPrimoAvvio(pagina: Int = 0) {
        guard presentazione == nil, !inVistaCliente, !inModoCliente else { return }
        if bloccato {
            sblocca()
            // Nelle istantanee e nelle prove lo sblocco è di colpo: si prosegue subito
            if persistente {
                Movimenti.dopo(Tema.Moto.Sblocco.durataEntrata) { [weak self] in
                    guard let self, !self.bloccato else { return }
                    self.apriPrimoAvvio(pagina: pagina)
                }
                return
            }
        }
        // Senza animazione nello stato: il contenitore di ShellView anima l'entrata (come la guida)
        withTransaction(Transaction(animation: nil)) {
            if pannelloNotifiche { pannelloNotifiche = false }
            if pannelloSpazi { pannelloSpazi = false }
            if pannelloAppAperte { pannelloAppAperte = false }
            if pannelloCliente { pannelloCliente = false }
            if sistema.pannelloNovita { sistema.pannelloNovita = false }
            if sceltaMostra { sceltaMostra = false }
            chiudiRicerca()
            if sistema.guida != nil { sistema.guida = nil }
            primoAvvio = min(max(0, pagina), TestiPrimoAvvio.pagine - 1)
        }
    }

    /// Chiude le tre domande (velo, Esc o «Comincia») e le segna come fatte: non ripartono da sole.
    func chiudiPrimoAvvio() {
        guard primoAvvio != nil else { return }
        if !dati.impostazioni.introduzioneVista && !solaLettura { dati.impostazioni.introduzioneVista = true }
        withTransaction(Transaction(animation: nil)) { primoAvvio = nil }
    }

    /// «Comincia»: chiude le domande e parte da dove ha scelto l'utente.
    func cominciaPrimoAvvio(_ scelta: SceltaInizio) {
        chiudiPrimoAvvio()
        switch scelta {
        case .prova:
            mostraAvviso(TestiPrimoAvvio.avvisoProva)
        case .miei:
            // Clienti e il pannello «Importa…» (vCard, Excel o CSV); incollare da Excel resta nel menu … della Rubrica
            apriApp(.clienti)
            mostraAvviso(TestiPrimoAvvio.avvisoMiei)
            Task { @MainActor [weak self] in self?.importaClientiDaFile() }
        case .zero:
            apriNuovoClienteDaNovita()
        }
    }

    /// Scrive il nome di un canale (a fine scrittura del campo): ripulito, vuoto = quello di base; con i due nomi di
    /// base l'archivio torna a nil. Cambiare nome alza `versioneCalcoli` una volta (i nomi entrano nei testi in cache).
    func impostaNomeCanale(_ canale: Canale, _ testo: String) {
        guard !solaLettura else { return }
        let attuali = dati.impostazioni.nomiCanali ?? .base
        let nuovi = NomiCanali.scelti(primo: canale == .alleanza ? testo : attuali.primo,
                                      secondo: canale == .indipendente ? testo : attuali.secondo)
        let valore: NomiCanali? = nuovi.personalizzati ? nuovi : nil
        if dati.impostazioni.nomiCanali != valore { dati.impostazioni.nomiCanali = valore }
    }
}

/// La scheda delle tre domande: velo e vetro al centro, larga 640, contenuto alto almeno 300.
struct PrimoAvvio: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var modoIstantanea
    @State private var scelta: SceltaInizio = .prova

    private typealias P = Tema.Apple.PrimoAvvio

    private var pagina: Int { min(max(0, stato.primoAvvio ?? 0), TestiPrimoAvvio.pagine - 1) }
    private var ultima: Bool { pagina == TestiPrimoAvvio.pagine - 1 }

    var body: some View {
        let _ = ContaCorpi.segna()
        GeometryReader { geo in
            ZStack {
                P.velo
                    .contentShape(Rectangle())
                    .onTapGesture { stato.chiudiPrimoAvvio() }
                scheda
                    .frame(width: max(0, min(P.larghezza, geo.size.width - 2 * P.bordo)))
                    .frame(maxHeight: max(0, geo.size.height - 2 * P.bordo))
                    .entrataScheda(Tema.Apple.Moto.animazione(P.animazione, calmo: calmo), scala: P.entrataScala,
                                   ancora: .center, y: P.entrataY)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var scheda: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                contenuto
                    .id(pagina)
                    .transition(transizionePagina)
            }
            .frame(maxWidth: .infinity, minHeight: P.altezzaMinima, alignment: .topLeading)
            piede
                .padding(.top, P.sopraPiede)
        }
        .padding(P.padding)
        .superficieApple(P.superficie, raggio: P.raggio)
        .background { tasti }
    }

    /// Il contenuto entra da destra di 14 pt (con «Riduci movimento» solo la dissolvenza; nelle istantanee è già fermo).
    private var transizionePagina: AnyTransition {
        if modoIstantanea { return .identity }
        if calmo { return .asymmetric(insertion: .opacity, removal: .identity) }
        return .asymmetric(insertion: AnyTransition.opacity.combined(with: .offset(x: P.spostamentoPagina)), removal: .identity)
    }

    @ViewBuilder private var contenuto: some View {
        switch pagina {
        case 0: benvenuto
        case 1: canali
        default: daDove
        }
    }

    // MARK: Pagine

    private var benvenuto: some View {
        HStack(alignment: .top, spacing: P.spazioLogo) {
            LogoPrisma(colore: P.coloreLogo)
                .frame(width: P.logo, height: P.logo)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                testata(TestiPrimoAvvio.benvenuto, TestiPrimoAvvio.benvenutoTesto)
                ForEach(TestiPrimoAvvio.punti, id: \.self) { punto in
                    HStack(spacing: P.spazioPunto) {
                        Circle()
                            .fill(P.colorePallino)
                            .frame(width: P.pallinoPunto, height: P.pallinoPunto)
                            .accessibilityHidden(true)
                        Text(punto)
                            .carattereApple(P.punto)
                            .foregroundColor(P.colorePunto)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, P.paddingPunto)
                }
            }
        }
    }

    private var canali: some View {
        let nomi = stato.dati.impostazioni.nomiCanali ?? .base
        return VStack(alignment: .leading, spacing: 0) {
            testata(TestiPrimoAvvio.canali, TestiPrimoAvvio.canaliTesto)
            VStack(spacing: 0) {
                rigaCanale(TestiPrimoAvvio.primoCanale, .alleanza, nome: nomi.primo)
                Rectangle()
                    .fill(Tema.Apple.Colore.separatore)
                    .frame(height: Tema.Apple.Impostazioni.CampoCanale.spessoreFilo)
                rigaCanale(TestiPrimoAvvio.secondoCanale, .indipendente, nome: nomi.secondo)
            }
            .padding(P.paddingSchedaCanali)
            .superficieApple(Tema.Apple.Impostazioni.Riga.superficie, raggio: Tema.Apple.Impostazioni.Riga.raggio)
            .padding(.top, P.sopraScheda)
            Text(TestiPrimoAvvio.canaliNota)
                .carattereApple(P.nota)
                .foregroundColor(P.coloreNota)
                .padding(.top, P.sopraNota)
        }
    }

    private func rigaCanale(_ titolo: String, _ canale: Canale, nome: String) -> some View {
        HStack(spacing: P.spazioPulsanti) {
            Text(titolo)
                .carattereApple(P.rigaCanale)
                .foregroundColor(P.coloreTitolo)
                .lineLimit(1)
            Spacer(minLength: P.spazioPulsanti)
            CampoNomeCanale(canale: canale, nome: nome) { stato.impostaNomeCanale(canale, $0) }
        }
        .padding(.vertical, P.paddingRigaCanale)
    }

    private var daDove: some View {
        VStack(alignment: .leading, spacing: 0) {
            testata(TestiPrimoAvvio.daDove, TestiPrimoAvvio.daDoveTesto)
            VStack(spacing: P.spazioOpzioni) {
                ForEach(SceltaInizio.allCases) { s in
                    OpzioneInizio(titolo: s.titolo, testo: s.testo, scelta: s == scelta) { scelta = s }
                }
            }
            .padding(.top, P.sopraOpzioni)
        }
    }

    /// Occhiello «Il primo avvio · n di 3», titolo (`.avT`) e testo (`.avS`).
    private func testata(_ titolo: String, _ testo: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(TestiPrimoAvvio.occhiello(pagina))
                .carattereApple(P.occhiello)
                .foregroundColor(P.coloreOcchiello)
            Text(titolo)
                .carattereApple(P.titolo)
                .foregroundColor(P.coloreTitolo)
                .padding(.top, P.sopraTitolo)
                .padding(.bottom, P.sottoTitolo)
                .accessibilityAddTraits(.isHeader)
            Text(testo)
                .carattereApple(P.testo)
                .foregroundColor(P.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: P.larghezzaTesto, alignment: .leading)
                .padding(.bottom, P.sottoTesto)
        }
    }

    // MARK: Piede

    private var piede: some View {
        HStack(spacing: P.spazioPulsanti) {
            PuntiPagine(numero: TestiPrimoAvvio.pagine, attuale: pagina)
            Spacer(minLength: P.spazioPulsanti)
            if pagina > 0 {
                Button("Indietro") { vai(pagina - 1) }
                    .buttonStyle(.appleGrande)
            }
            Button { avanti() } label: {
                if ultima {
                    Label("Comincia", systemImage: "checkmark")
                } else {
                    Text("Avanti")
                }
            }
            .buttonStyle(.applePrimarioGrande)
            .keyboardShortcut(.defaultAction)
        }
    }

    /// Esc chiude; le frecce ← → sfogliano le pagine, tranne sulla pagina dei nomi (le frecce servono al campo).
    private var tasti: some View {
        Group {
            Button("") { stato.chiudiPrimoAvvio() }
                .keyboardShortcut(.cancelAction)
            if pagina != 1 {
                Button("") { vai(pagina + 1) }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                Button("") { vai(pagina - 1) }
                    .keyboardShortcut(.leftArrow, modifiers: [])
            }
        }
        .opacity(0)
        .frame(width: 0, height: 0)
        .accessibilityHidden(true)
    }

    private func avanti() {
        guard ultima else { vai(pagina + 1); return }
        stato.cominciaPrimoAvvio(scelta)
    }

    private func vai(_ nuova: Int) {
        guard nuova >= 0, nuova < TestiPrimoAvvio.pagine, nuova != pagina else { return }
        withAnimation(Tema.Apple.Moto.animazione(P.animazionePagina, calmo: calmo, istantanea: modoIstantanea)) {
            stato.primoAvvio = nuova
        }
    }
}
#endif
