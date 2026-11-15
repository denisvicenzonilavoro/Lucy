import SwiftUI

// Impostazioni nel tema Apple (Design/template-apple-specifica.md §4.6, riferimenti PIE i01-i09).
// - `.impostazioniApple()` chiede alle righe di sempre (`GruppoImpostazioni`, `RigaImpostazione`, `ValoreRiga`,
//   `NotaImpostazioni`, `TesseraImpostazioni`, `StileInterruttore`) lo stile del template: ogni riga è una card
//   senza ombra con il titolo 15 bold, la spiegazione `.k` e il controllo a destra; accende anche
//   `.superficiApple()` (etichette del canale `.chA` / `.chI`). Le altre app restano com'erano.
// - `VoceLateraleImpostazioniApple`: la voce `.rub` della barra laterale.
// - `StatoRigaApple`: lo stato a destra di una riga («● Pronto»).
// - `AnelloBackupApple`: l'anello del backup (§2.24) che si riempie mentre il backup lavora.
// - `StilePulsanteRigaImpostazioni`: i pulsanti dentro le righe (la capsula `.btn`, sul Mac e sull'iPad).
// «Riduci movimento» e istantanee: tutto è subito nello stato finale. Valori in Tema.Apple+Impostazioni.swift.

private struct ChiaveImpostazioniApple: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// true: le righe delle Impostazioni si disegnano come card del tema Apple.
    var impostazioniApple: Bool {
        get { self[ChiaveImpostazioniApple.self] }
        set { self[ChiaveImpostazioniApple.self] = newValue }
    }
}

extension View {
    /// Le righe, i gruppi, le note e gli interruttori delle Impostazioni nello stile del tema Apple.
    func impostazioniApple(_ attive: Bool = true) -> some View {
        environment(\.impostazioniApple, attive)
            .superficiApple(attive)
    }

    /// Un blocco dentro un gruppo che non è una riga (la griglia dei rendimenti): nel tema Apple sta su una card
    /// come le righe; altrimenti resta com'è.
    func cardImpostazioni() -> some View {
        modifier(CardImpostazioniApple())
    }

    /// Nel tema Apple la riga entra a cascata (base 0, dentro l'app) quando si apre la sezione; altrimenti niente.
    func cascataImpostazioni(_ indice: Int) -> some View {
        modifier(CascataImpostazioniApple(indice: indice))
    }
}

private struct CascataImpostazioniApple: ViewModifier {
    let indice: Int
    @Environment(\.impostazioniApple) private var apple

    @ViewBuilder func body(content: Content) -> some View {
        if apple {
            content.entrataCascata(indice, base: Tema.Apple.Moto.Cascata.baseDentroApp, sfocatura: false)
        } else {
            content
        }
    }
}

private struct CardImpostazioniApple: ViewModifier {
    @Environment(\.impostazioniApple) private var apple

    @ViewBuilder func body(content: Content) -> some View {
        if apple {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .superficieApple(Tema.Apple.Impostazioni.Riga.superficie, raggio: Tema.Apple.Impostazioni.Riga.raggio)
        } else {
            content
        }
    }
}

// MARK: - Voce della barra laterale

/// Voce `.rub` della barra laterale: titolo 14 bold con padding 11×12 e raggio 14; sotto il puntatore il fondo
/// `chip`, scelta `rgba(0,122,255,.13)` (0,25 s). Un segno facoltativo a destra: il pallino (iPad), oppure sul Mac
/// (migliorie d'uso 31) l'etichetta di cosa manca, il numero di «Da sistemare» o la spunta verde.
struct VoceLateraleImpostazioniApple: View {
    let titolo: String
    let attiva: Bool
    var segno: SegnoVoceImpostazioni? = nil
    let azione: () -> Void

    @Environment(\.modoIstantanea) private var istantanea
    @Environment(\.prismaCalmo) private var calmo
    @State private var sopra = false

    private typealias L = Tema.Apple.Impostazioni.Laterale

    init(titolo: String, attiva: Bool, segno: SegnoVoceImpostazioni? = nil, azione: @escaping () -> Void) {
        self.titolo = titolo
        self.attiva = attiva
        self.segno = segno
        self.azione = azione
    }

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: L.raggioVoce, style: .continuous)
        Button(action: azione) {
            HStack(spacing: Tema.Apple.Impostazioni.Stato.spazio) {
                Text(titolo)
                    .carattereApple(L.titoloVoce)
                    .foregroundColor(L.coloreVoce)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 0)
                if let segno {
                    switch segno {
                    case .pallino(let tono):
                        Circle()
                            .fill(StatoRigaApple.colore(tono))
                            .frame(width: Tema.Apple.Impostazioni.Stato.pallino, height: Tema.Apple.Impostazioni.Stato.pallino)
                            .accessibilityHidden(true)
                    case .etichetta(let testo, let errore):
                        PillolaColonnaImpostazioni(testo: testo, errore: errore)
                    case .spunta:
                        Image(systemName: L.simboloSpunta)
                            .carattereApple(L.spunta)
                            .foregroundColor(L.coloreSpunta)
                            .accessibilityHidden(true)
                    }
                }
            }
            .padding(L.paddingVoce)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { forma.fill(fondo) }
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .onHover { dentro in
            guard !istantanea else { return }
            withAnimation(Tema.Apple.Moto.animazione(L.animazioneFondo, calmo: calmo)) { sopra = dentro }
        }
        .animation(Tema.Apple.Moto.animazione(L.animazioneFondo, calmo: calmo, istantanea: istantanea), value: attiva)
        .accessibilityLabel(Text(etichettaAccessibile))
        .accessibilityAddTraits(attiva ? Self.trattiAttiva : Self.trattiVoce)
    }

    /// Il titolo e, se c'è, cosa manca («Archivio e backup, mai fatto»).
    private var etichettaAccessibile: String {
        switch segno {
        case .etichetta(let testo, _)?: return "\(titolo), \(testo)"
        case .spunta?: return "\(titolo), tutto a posto"
        default: return titolo
        }
    }

    private var fondo: Color {
        if attiva { return L.fondoScelta }
        return sopra ? L.fondoSopra : Color.clear
    }

    private static var trattiVoce: AccessibilityTraits { .isButton }
    private static var trattiAttiva: AccessibilityTraits { [.isButton, .isSelected] }
}

/// Il segno a destra di una voce della colonna delle Impostazioni.
enum SegnoVoceImpostazioni: Equatable {
    /// Il pallino nel colore del tono (iPad).
    case pallino(Pillola.Tono)
    /// Migliorie d'uso 31: l'etichetta breve di cosa manca («mai fatto», «spenti») o il numero di «Da sistemare».
    case etichetta(String, errore: Bool)
    /// Migliorie d'uso 31: «Da sistemare» a zero.
    case spunta
}

/// Migliorie d'uso 31: la pillola della colonna (`.impSt`): 11 semibold in capsula, arancio al 16% con il testo
/// `arancioTesto`, o rosso al 13% con il testo rosso per gli errori.
struct PillolaColonnaImpostazioni: View {
    let testo: String
    var errore = false

    private typealias E = Tema.Apple.Impostazioni.Laterale.EtichettaStato

    init(testo: String, errore: Bool = false) {
        self.testo = testo
        self.errore = errore
    }

    var body: some View {
        Text(testo)
            .carattereApple(E.carattere)
            .foregroundColor(errore ? E.testoErrore : E.testoAttenzione)
            .lineLimit(1)
            .padding(E.padding)
            .background { Capsule(style: .continuous).fill(errore ? E.fondoErrore : E.fondoAttenzione) }
            .fixedSize()
    }
}

// MARK: - Ricerca (Migliorie d'uso 30, solo Mac)

#if os(macOS)
/// Il campo «Cerca nelle impostazioni» in cima alla colonna (`.impQ`): alto 34, raggio 10, fondo `chip`, lente 15 e
/// testo 13,5, senza il bordo di fuoco di sistema. Esc nel campo pieno lo svuota (e non chiude la finestra); nel campo
/// vuoto fa quello che fa sempre (`escVuoto`: chiude Impostazioni).
struct CampoCercaImpostazioni: View {
    @Binding var testo: String
    var fuoco: FocusState<Bool>.Binding
    let escVuoto: () -> Void

    private typealias C = Tema.Apple.Impostazioni.Laterale.Cerca

    init(testo: Binding<String>, fuoco: FocusState<Bool>.Binding, escVuoto: @escaping () -> Void) {
        self._testo = testo
        self.fuoco = fuoco
        self.escVuoto = escVuoto
    }

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: C.raggio, style: .continuous)
        HStack(spacing: C.spazio) {
            Image(systemName: C.simbolo)
                .carattereApple(C.lente)
                .foregroundColor(C.coloreLente)
                .accessibilityHidden(true)
            TextField("", text: $testo, prompt: Text(TestiImpostazioni.cerca))
                .textFieldStyle(.plain)
                .carattereApple(C.testo)
                .foregroundColor(C.coloreTesto)
                .lineLimit(1)
                .focused(fuoco)
                .focusEffectDisabled()
                .onExitCommand {
                    if testo.isEmpty { escVuoto() } else { testo = "" }
                }
                .accessibilityLabel(TestiImpostazioni.cerca)
        }
        .padding(.horizontal, C.paddingOrizzontale)
        .frame(height: C.altezza)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { forma.fill(C.fondo) }
    }
}

/// La pillola con il nome della pagina accanto a «Apri» nei risultati della ricerca (12 semibold, padding 4×10).
struct EtichettaPaginaImpostazioni: View {
    let testo: String

    private typealias R = Tema.Apple.Impostazioni.Risultati

    var body: some View {
        Text(testo)
            .carattereApple(R.pillola)
            .foregroundColor(R.colorePillola)
            .lineLimit(1)
            .padding(R.paddingPillola)
            .background { Capsule(style: .continuous).fill(R.fondoPillola) }
            .fixedSize()
    }
}
#endif

// MARK: - Stato della riga

/// Lo stato a destra di una riga nel tema Apple: pallino 8 nel colore del tono e testo 13 semibold («● Pronto»).
struct StatoRigaApple: View {
    let testo: String
    let tono: Pillola.Tono

    private typealias S = Tema.Apple.Impostazioni.Stato

    static func colore(_ tono: Pillola.Tono) -> Color {
        switch tono {
        case .ok: return S.ok
        case .attenzione: return S.attenzione
        case .errore: return S.errore
        case .neutro: return S.neutro
        }
    }

    var body: some View {
        HStack(spacing: S.spazio) {
            Circle()
                .fill(Self.colore(tono))
                .frame(width: S.pallino, height: S.pallino)
            Text(testo)
                .carattereApple(S.carattere)
                .foregroundColor(S.coloreTesto)
                .lineLimit(1)
        }
        .fixedSize()
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Pulsanti nelle righe

/// I pulsanti dentro le righe delle Impostazioni: la capsula del tema Apple (`.btn`, o il blu `.btn.pri` per l'azione
/// principale), sul Mac e sull'iPad.
struct StilePulsanteRigaImpostazioni: ButtonStyle {
    var principale = false
    var grande = false

    init(principale: Bool = false, grande: Bool = false) {
        self.principale = principale
        self.grande = grande
    }

    func makeBody(configuration: Configuration) -> some View {
        StilePulsanteApple(principale ? .principale : .secondaria, grande: grande).makeBody(configuration: configuration)
    }
}

// MARK: - Anello del backup (§2.24)

/// L'anello del backup 110/12 verde. A riposo è pieno con la ✓ se l'ultimo backup è in regola, vuoto con il simbolo
/// del giro se non ce n'è ancora uno (o con «!» arancio se l'ultimo non è riuscito). Durante il backup riparte da 0
/// e sale in 1,6 s con la curva `(0.4,0,0.2,1)` fino a `frazioneAttesa` (il backup non dice quanto manca); a backup
/// finito si chiude e a 1,7 s dall'inizio compare la ✓ con la molla. 1,6 s è la durata minima mostrata.
/// «Riduci movimento» e istantanee: subito lo stato finale (pieno con la ✓, o fermo a metà durante il backup).
struct AnelloBackupApple: View {
    /// Il backup sta lavorando.
    let inCorso: Bool
    /// A riposo: pieno (ultimo backup in regola) o vuoto.
    let pieno: Bool
    /// L'ultimo backup non è riuscito: «!» al centro.
    var errore = false

    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var mostrata: Double = 0
    @State private var spunta = false
    @State private var inizio: Date?
    /// Cresce a ogni giro: un'attesa vecchia (asyncAfter) non tocca un backup nuovo.
    @State private var giro = 0

    private typealias B = Tema.Apple.Impostazioni.Backup
    private typealias Moto = Tema.Apple.Moto.Backup

    init(inCorso: Bool, pieno: Bool, errore: Bool = false) {
        self.inCorso = inCorso
        self.pieno = pieno
        self.errore = errore
    }

    /// Lo stato finale, senza animazioni.
    private var frazioneFinale: Double { inCorso ? B.frazioneAttesa : (pieno ? 1 : 0) }
    private var spuntaFinale: Bool { !inCorso && pieno }

    var body: some View {
        let frazione = statoFinale ? frazioneFinale : mostrata
        let conSpunta = statoFinale ? spuntaFinale : spunta
        let diametro = B.anello - B.spessore
        ZStack {
            Circle()
                .stroke(B.colore.opacity(B.opacitaBinario), lineWidth: B.spessore)
                .frame(width: diametro, height: diametro)
            Circle()
                .trim(from: 0, to: CGFloat(frazione))
                .stroke(B.colore, style: StrokeStyle(lineWidth: B.spessore, lineCap: .round))
                .rotationEffect(Tema.Apple.Grafico.Anello.inizio)
                .frame(width: diametro, height: diametro)
            centro(spunta: conSpunta)
        }
        .frame(width: B.anello, height: B.anello)
        .onAppear {
            mostrata = frazioneFinale
            spunta = spuntaFinale
        }
        .onChange(of: inCorso) { lavora in
            if lavora { parti() } else { chiudi() }
        }
        .onChange(of: pieno) { _ in
            guard !inCorso, inizio == nil else { return }
            mostrata = frazioneFinale
            spunta = spuntaFinale
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(inCorso ? "Backup in corso" : (pieno ? "Backup in regola" : "Nessun backup recente")))
    }

    @ViewBuilder private func centro(spunta conSpunta: Bool) -> some View {
        if conSpunta {
            Image(systemName: "checkmark")
                .font(B.spunta.font)
                .foregroundColor(B.coloreSpunta)
                .transition(.scale(scale: Moto.scalaSpunta).combined(with: .opacity))
        } else if !inCorso {
            Image(systemName: errore ? "exclamationmark" : "arrow.triangle.2.circlepath")
                .font(B.attesa.font)
                .foregroundColor(errore ? B.coloreErrore : B.coloreAttesa)
                .transition(.opacity)
        }
    }

    /// Il backup comincia: l'anello si svuota e sale fino all'attesa in 1,6 s.
    private func parti() {
        giro += 1
        inizio = Date()
        var t = Transaction()
        t.disablesAnimations = true
        withTransaction(t) {
            spunta = false
            mostrata = 0
        }
        guard !statoFinale else { return }
        // Al giro dopo: lo 0 è già disegnato e la salita parte da lì
        DispatchQueue.main.async {
            withAnimation(Moto.animazione) { mostrata = B.frazioneAttesa }
        }
    }

    /// Il backup è finito: dopo almeno 1,6 s dall'inizio l'anello si chiude (o torna vuoto se non è riuscito) e
    /// poco dopo compare la ✓.
    private func chiudi() {
        let questo = giro
        let trascorso = inizio.map { Date().timeIntervalSince($0) } ?? Moto.durata
        let attesa = statoFinale ? 0 : max(0, Moto.durata - trascorso)
        let riuscito = pieno
        DispatchQueue.main.asyncAfter(deadline: .now() + attesa) {
            guard questo == giro else { return }
            inizio = nil
            guard !statoFinale else {
                mostrata = riuscito ? 1 : 0
                spunta = riuscito
                return
            }
            withAnimation(B.animazioneChiusura) { mostrata = riuscito ? 1 : 0 }
            guard riuscito else { return }
            let dopo = B.durataChiusura + max(0, Moto.ritardoSpunta - Moto.durata)
            DispatchQueue.main.asyncAfter(deadline: .now() + dopo) {
                guard questo == giro else { return }
                withAnimation(Moto.spunta) { spunta = true }
            }
        }
    }
}

// MARK: - Il nome dei canali e le tre domande del primo avvio (migliorie d'uso 38)

/// Il campo del nome di un canale (`campoCh` del template): pallino del colore del canale, campo largo 150 e alto 32 e,
/// a destra, l'etichetta del canale che cambia mentre si scrive. Il nome entra nei calcoli in cache e nei documenti:
/// passa all'archivio solo a fine scrittura (Invio, fuoco perso, campo che sparisce), con `salva`.
///
///     CampoNomeCanale(canale: .alleanza, nome: Canale.alleanza.nomeBreve) { stato.impostaNomeCanale(.alleanza, $0) }
struct CampoNomeCanale: View {
    let canale: Canale
    /// Il nome in uso adesso (dall'archivio).
    let nome: String
    let salva: (String) -> Void
    @State private var bozza: String
    @FocusState private var fuoco: Bool

    private typealias F = Tema.Apple.Impostazioni.CampoCanale

    init(canale: Canale, nome: String, salva: @escaping (String) -> Void) {
        self.canale = canale
        self.nome = nome
        self.salva = salva
        _bozza = State(initialValue: nome)
    }

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: F.raggio, style: .continuous)
        HStack(spacing: F.spazio) {
            Circle()
                .fill(canale == .alleanza ? Tema.Apple.Colore.canaleAlleanza : Tema.Apple.Colore.canaleIndipendente)
                .frame(width: F.pallino, height: F.pallino)
                .accessibilityHidden(true)
            TextField("", text: $bozza, prompt: Text(NomiCanali.base.nome(canale)))
                .textFieldStyle(.plain)
                .carattereApple(F.carattere)
                .foregroundColor(F.coloreTesto)
                .autocorrectionDisabled()
                .focused($fuoco)
                .padding(.horizontal, F.paddingOrizzontale)
                .frame(width: F.larghezza, height: F.altezza)
                .background { forma.fill(F.fondo) }
                .overlay { forma.strokeBorder(F.filo, lineWidth: F.spessoreFilo) }
                .overlay {
                    if fuoco {
                        forma.inset(by: -F.spessoreAnello).strokeBorder(F.anelloFuoco, lineWidth: F.spessoreAnello)
                    }
                }
                .onSubmit { scrivi() }
                .onChange(of: bozza) { nuovo in
                    // Come `maxlength` 18 del template, senza i caratteri che non vanno su un'etichetta
                    let ripulito = NomiCanali.ripulisciScrittura(nuovo)
                    if ripulito != nuovo { bozza = ripulito }
                }
                .onChange(of: fuoco) { attivo in
                    if !attivo { scrivi() }
                }
                // Cambiato da fuori (il primo avvio, un ripristino) mentre non si scrive: vale l'archivio
                .onChange(of: nome) { esterno in
                    if !fuoco && esterno != bozza { bozza = esterno }
                }
                .onDisappear { scrivi() }
                .accessibilityLabel(Text(canale == .alleanza ? "Il primo canale" : "Il secondo canale"))
            EtichettaCanaleApple(canale: canale, compatta: canale == .indipendente, nomeScelto: bozza)
        }
    }

    /// Fine della scrittura: il nome ripulito passa all'archivio (vuoto = quello di base) e il campo lo mostra.
    private func scrivi() {
        let pulito = NomiCanali.pulisci(bozza)
        let mostrato = pulito.isEmpty ? NomiCanali.base.nome(canale) : pulito
        if mostrato != nome { salva(pulito) }
        if bozza != mostrato { bozza = mostrato }
    }
}

/// Un'opzione della terza domanda del primo avvio (`.avO` del template): riquadro raggio 16 con il cerchio di scelta 20
/// a sinistra, titolo e spiegazione; la scelta ha il filo blu e il cerchio pieno.
struct OpzioneInizio: View {
    let titolo: String
    let testo: String
    let scelta: Bool
    let azione: () -> Void

    private typealias P = Tema.Apple.PrimoAvvio
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var modoIstantanea

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: P.raggioOpzione, style: .continuous)
        Button(action: azione) {
            HStack(spacing: P.spazioOpzione) {
                Circle()
                    .strokeBorder(scelta ? P.filoScelta : P.coloreCerchio, lineWidth: scelta ? P.filoCerchioScelto : P.filoCerchio)
                    .frame(width: P.cerchio, height: P.cerchio)
                VStack(alignment: .leading, spacing: P.sottoTitoloOpzione) {
                    Text(titolo)
                        .carattereApple(P.titoloOpzione)
                        .foregroundColor(P.coloreTitolo)
                    Text(testo)
                        .carattereApple(P.testoOpzione)
                        .foregroundColor(P.coloreTestoOpzione)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(P.paddingOpzione)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { forma.fill(P.fondoOpzione) }
            .overlay {
                forma.strokeBorder(scelta ? P.filoScelta : P.filoOpzione, lineWidth: scelta ? P.spessoreFiloScelta : P.spessoreFiloOpzione)
            }
            .contentShape(forma)
        }
        .buttonStyle(.plain)
        .animation(Tema.Apple.Moto.animazione(P.animazioneScelta, calmo: calmo, istantanea: modoIstantanea), value: scelta)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(scelta ? .isSelected : [])
    }
}
