import SwiftUI

#if os(macOS)
// Migliorie d'uso 67 «App aperte e spazi dal nome dell'app» (Design/uso/gruppo-11.md §67, template righe 4951-4959 e
// 3098-3103): il nome dell'app nella barra apre un menu con le app aperte (per tornarci), gli spazi di lavoro con il loro
// nome, «Salva le finestre aperte come spazio…» e «Torna alla scrivania». Mai in modalità cliente né nella vista pulita.
// Aperto e chiuso in `StatoFinestre.menuApp` (solo in memoria): la shell non si ridisegna. Valori in
// Tema.Apple+DockFinestre (`Tema.Apple.MenuApp`).

/// I testi del menu della pillola dell'app.
enum TestiMenuApp {
    static let aiutoPillola = "App aperte e spazi di lavoro"
    static let nessunaApp = "Nessun’altra app aperta, per ora"
    static let salva = "Salva le finestre aperte come spazio…"
    static let aiutoSalvaSpento = "Apri e disponi le app che ti servono, poi salvale qui come spazio."
    static let scrivania = "Torna alla scrivania"
    static let elimina = "Elimina lo spazio"
    static func aiutoSpazio(_ nome: String) -> String { "Apri lo spazio «\(nome)»" }
    static func aiutoApp(_ titolo: String) -> String { "Torna a \(titolo)" }
    /// «Incontri + Vera»: le app dello spazio, dalla principale.
    static func appDelloSpazio(_ s: SpazioLavoro) -> String { s.app.map(\.titolo).joined(separator: " + ") }
    // Il modulo per salvare lo spazio
    static let titoloModulo = "Salva come spazio"
    static func finestre(_ titoli: [String]) -> String { "Le finestre aperte: \(titoli.joined(separator: ", "))." }
    static let nome = "Nome dello spazio"
    static let salvaPulsante = "Salva"
    static let annulla = "Annulla"
}

/// Dove sta la pillola dell'app nella barra: il menu si apre 8 punti sotto, allineato al suo bordo sinistro.
struct AncoraPillolaApp: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

extension StatoShell {
    /// Le app che lavorano sul cliente scelto (`APPCLI` del template): nel menu portano a destra il suo nome.
    static let appConCliente: Set<AppPrisma> = [
        .clienti, .posizioni, .analisi360, .agenda, .presentazioni, .sala, .vera, .incontri, .messaggi, .mercato,
    ]

    /// Le app aperte da elencare nel menu: tutte le finestre tranne quella davanti, comprese le ridotte nel dock, dalla
    /// più vicina (l'ordine di sovrapposizione fa da «usate da poco»), al più quattro come il template.
    var appRecentiMenu: [AppPrisma] {
        let davanti = sistema.appAttiva
        let elenco = sistema.elenco.reversed().map(\.app).filter { $0 != davanti && !sistema.rientrano.contains($0) }
        return Array(elenco.prefix(4))
    }

    /// Il nome breve del cliente scelto da mostrare accanto a un'app che lo segue (nil con «Tutti i clienti»).
    func clienteNelMenu(per app: AppPrisma) -> String? {
        guard Self.appConCliente.contains(app), let c = clienteAttivo else { return nil }
        return Self.primoNome(c.nome)
    }

    /// Il nome dell'app nella barra: apre o chiude il menu. Un pannello alla volta, come in macOS.
    func alternaMenuApp() {
        if menuApp {
            menuApp = false
            return
        }
        guard !inModoCliente, !inVistaCliente, !bloccato, presentazione == nil else { return }
        if pannelloNotifiche { pannelloNotifiche = false }
        if pannelloSpazi { pannelloSpazi = false }
        if pannelloCliente { pannelloCliente = false }
        if pannelloAppAperte { pannelloAppAperte = false }
        if sistema.pannelloNovita { sistema.pannelloNovita = false }
        chiudiRicerca()
        menuApp = true
    }

    /// Una voce del menu: si chiude e poi fa la sua azione.
    func dalMenuApp(_ azione: () -> Void) {
        menuApp = false
        azione()
    }
}

/// Il menu sotto la pillola dell'app, con il velo trasparente che lo chiude a un clic fuori.
struct MenuAppBarra: View {
    @Environment(StatoShell.self) var stato
    @Environment(StatoFinestre.self) var sistema
    @Environment(\.prismaCalmo) private var calmo
    /// La pillola dell'app nella barra (coordinate della shell); nil se non si legge.
    let pillola: CGRect?

    private typealias M = Tema.Apple.MenuApp

    var body: some View {
        let _ = ContaCorpi.segna()
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { stato.menuApp = false }
            Group {
                if sistema.menuAppSalva {
                    ModuloSalvaSpazio()
                } else {
                    voci
                }
            }
            .entrataScheda(Tema.Apple.Moto.animazione(Tema.Apple.Moto.MenuApp.animazione, calmo: calmo),
                           scala: Tema.Apple.Moto.MenuApp.scala, ancora: .topLeading,
                           y: Tema.Apple.Moto.MenuApp.spostamento)
            .padding(.top, (pillola?.maxY ?? Tema.Apple.Misura.Barra.altezza) + M.distanzaPillola)
            .padding(.leading, max(M.bordo, pillola?.minX ?? M.bordo))
            .padding(.bottom, M.bordo)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    // MARK: Le voci

    private var voci: some View {
        let recenti = stato.appRecentiMenu
        let suoi = stato.dati.spazi
        let senzaFinestre = sistema.visibili.isEmpty
        return VStack(alignment: .leading, spacing: 0) {
            if recenti.isEmpty {
                RigaMenuApp(testo: TestiMenuApp.nessunaApp, nota: nil, spenta: true, azione: {}) { EmptyView() }
            } else {
                ForEach(recenti, id: \.self) { app in
                    RigaMenuApp(testo: app.titolo, nota: stato.clienteNelMenu(per: app), spenta: false,
                                azione: { stato.dalMenuApp { stato.apri(app) } }) {
                        IconaApp(app: app, lato: M.icona)
                            .clipShape(RoundedRectangle(cornerRadius: M.raggioIcona, style: .continuous))
                    }
                    .help(TestiMenuApp.aiutoApp(app.titolo))
                }
            }
            filetto
            ForEach(SpazioLavoro.predefiniti) { s in rigaSpazio(s) }
            ForEach(suoi) { s in
                rigaSpazio(s)
                    .contextMenu {
                        Button(TestiMenuApp.elimina, role: .destructive) { stato.eliminaSpazio(s.id) }
                    }
            }
            filetto
            RigaMenuApp(testo: TestiMenuApp.salva, nota: nil, spenta: senzaFinestre,
                        azione: { sistema.menuAppSalva = true }) { EmptyView() }
                .help(senzaFinestre ? TestiMenuApp.aiutoSalvaSpento : "")
            RigaMenuApp(testo: TestiMenuApp.scrivania, nota: nil, spenta: false,
                        azione: { stato.dalMenuApp { stato.mostraScrivania() } }) { EmptyView() }
        }
        .padding(M.margine)
        .frame(minWidth: M.larghezzaMinima, maxWidth: M.larghezzaMassima, alignment: .leading)
        .fixedSize(horizontal: true, vertical: false)
        .superficieApple(M.superficie, raggio: M.raggio)
    }

    private func rigaSpazio(_ s: SpazioLavoro) -> some View {
        RigaMenuApp(testo: s.nome, nota: TestiMenuApp.appDelloSpazio(s), spenta: false,
                    azione: { stato.dalMenuApp { stato.apriSpazio(s) } }) {
            Image(systemName: "rectangle.split.2x1")
                .carattereApple(M.glifo)
                .foregroundColor(M.coloreGlifo)
        }
        .help(TestiMenuApp.aiutoSpazio(s.nome))
    }

    private var filetto: some View {
        Rectangle()
            .fill(M.filetto)
            .frame(height: M.spessoreFiletto)
            .padding(M.paddingFiletto)
    }
}

/// Una voce del menu: il segno a sinistra (icona dell'app o glifo dello schermo), il testo e, a destra in piccolo, il
/// nome del cliente o le app dello spazio. Spenta: grigia e non toccabile.
private struct RigaMenuApp<Segno: View>: View {
    let testo: String
    let nota: String?
    let spenta: Bool
    let azione: () -> Void
    @ViewBuilder let segno: () -> Segno
    @State private var sopra = false

    private typealias M = Tema.Apple.MenuApp

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: M.raggioRiga, style: .continuous)
        return Button(action: azione) {
            HStack(spacing: M.spazioRiga) {
                segno()
                    .frame(width: M.latoGlifo, height: M.latoGlifo)
                Text(testo)
                    .carattereApple(M.voce)
                    .foregroundColor(spenta ? M.coloreVoceSpenta : M.coloreVoce)
                    .lineLimit(1)
                Spacer(minLength: M.spazioRiga)
                if let nota {
                    Text(nota)
                        .carattereApple(M.notaCliente)
                        .foregroundColor(M.coloreNota)
                        .lineLimit(1)
                        .padding(M.paddingNota)
                        .background(Capsule(style: .continuous).fill(M.fondoNota))
                }
            }
            .padding(M.rigaPadding)
            .frame(minHeight: M.altezzaRiga)
            .background(forma.fill(sopra && !spenta ? M.sopra : Color.clear))
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .disabled(spenta)
        .opacity(spenta ? M.opacitaSpenta : 1)
        .onHover { s in withAnimation(Tema.Moto.passaggio) { sopra = s } }
    }
}

/// «Salva le finestre aperte come spazio…»: il nome dello spazio e «Salva» (spento senza nome), al posto delle voci del
/// menu. Lo spazio si salva come prima (`salvaSpazio(nome:)`), con il suo avviso.
struct ModuloSalvaSpazio: View {
    @Environment(StatoShell.self) var stato
    @Environment(StatoFinestre.self) var sistema
    @Environment(\.modoIstantanea) private var modoIstantanea
    @State private var nome = ""
    @FocusState private var fuoco: Bool

    private typealias M = Tema.Apple.MenuApp

    var body: some View {
        let vuoto = nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return VStack(alignment: .leading, spacing: M.spazioModulo) {
            Text(TestiMenuApp.titoloModulo)
                .carattereApple(M.titoloModulo)
                .foregroundColor(M.coloreVoce)
            Text(TestiMenuApp.finestre(sistema.visibili.map(\.app.titolo)))
                .carattereApple(M.testoModulo)
                .foregroundColor(M.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
            TextField(TestiMenuApp.nome, text: $nome)
                .textFieldStyle(.plain)
                .carattereApple(M.campo)
                .focused($fuoco)
                .onSubmit(salva)
                .onExitCommand { stato.menuApp = false }
                .padding(.horizontal, M.paddingCampo)
                .frame(height: M.altezzaCampo)
                .background(RoundedRectangle(cornerRadius: M.raggioCampo, style: .continuous).fill(M.fondoCampo))
            HStack(spacing: M.spazioModulo) {
                Spacer(minLength: 0)
                Button(TestiMenuApp.annulla) { sistema.menuAppSalva = false }
                    .buttonStyle(.apple)
                Button(TestiMenuApp.salvaPulsante, action: salva)
                    .buttonStyle(.applePrimario)
                    .disabled(vuoto)
            }
        }
        .padding(M.paddingModulo + M.margine)
        .frame(width: M.larghezzaModulo, alignment: .leading)
        .superficieApple(M.superficie, raggio: M.raggio)
        .onAppear { if !modoIstantanea { DispatchQueue.main.async { fuoco = true } } }
    }

    private func salva() {
        guard stato.salvaSpazio(nome: nome) != nil else { return }
        nome = ""
        stato.menuApp = false
    }
}
#endif
