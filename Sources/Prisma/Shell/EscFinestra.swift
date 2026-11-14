#if os(macOS)
import AppKit
#endif
import SwiftUI

// Migliorie d'uso 4: Esc chiude la finestra interna in primo piano, come dice l'aiuto della chiusura («Chiudi (esc)»).
// Esc però ha già tanti padroni: pannelli, ricerca, dettagli, palco della Sala, schede, presentazione, campi di testo.
// Un altro `.keyboardShortcut(.cancelAction)` si contenderebbe il tasto con loro (vedi NotaVocaleArrivo.swift), quindi
// la finestra passa per ultima: un monitor locale dei tasti prova prima i pulsanti con Esc della finestra di Prisma
// (`performKeyEquivalent`, dove SwiftUI cerca le scorciatoie) e chiude la finestra solo se nessuno lo ha preso e se
// sopra non c'è niente che usi Esc a modo suo (pannelli della shell, sovrapposizioni, testo in scrittura, Territorio,
// la palestra mentre Vera scrive). Mai nelle istantanee e nelle prove (stato non persistente).

extension View {
    /// Esc chiude la finestra interna davanti, quando non c'è niente sopra (solo Mac).
    func escChiudeFinestra() -> some View {
        modifier(ModificatoreEscFinestra())
    }
}

private struct ModificatoreEscFinestra: ViewModifier {
    @Environment(StatoShell.self) var stato
    @Environment(\.modoIstantanea) private var modoIstantanea
    #if os(macOS)
    @State private var monitor = MonitorEscFinestra()
    #endif

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .onAppear { if !modoIstantanea && stato.persistente { monitor.avvia(stato) } }
            .onDisappear { monitor.ferma() }
        #else
        content
        #endif
    }
}

#if os(macOS)
/// Il monitor di Esc per la finestra davanti. Vive con la shell.
final class MonitorEscFinestra {
    private weak var stato: StatoShell?
    private var monitor: Any?

    /// Il codice del tasto Esc.
    private static let tastoEsc: UInt16 = 53

    func avvia(_ s: StatoShell) {
        stato = s
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
            self?.tasto(e) ?? e
        }
    }

    func ferma() {
        if let m = monitor { NSEvent.removeMonitor(m) }
        monitor = nil
    }

    deinit { ferma() }

    private func tasto(_ e: NSEvent) -> NSEvent? {
        guard e.keyCode == Self.tastoEsc, !e.isARepeat,
              e.modifierFlags.intersection([.command, .option, .control, .shift]).isEmpty,
              let s = stato, let app = s.appAttiva,
              let finestra = e.window, !(finestra is NSPanel), finestra.isKeyWindow,
              finestra === NSApp.mainWindow, finestra.attachedSheet == nil, finestra.sheetParent == nil
        else { return e }
        // Un campo di testo in scrittura: Esc è suo (annulla, chiude il completamento, `onExitCommand` dei campi)
        if finestra.firstResponder is NSText { return e }
        // Qualcosa sopra la finestra che usa Esc a modo suo
        guard nienteSopra(s, app: app) else { return e }
        // Prima i pulsanti con Esc della finestra (dettagli, schede, palco…): se uno lo prende, la finestra resta
        if finestra.performKeyEquivalent(with: e) { return nil }
        s.chiudi(app)
        return nil
    }

    /// Nessun pannello, sovrapposizione o scena sopra la finestra davanti, e l'app davanti non usa Esc da sé.
    private func nienteSopra(_ s: StatoShell, app: AppPrisma) -> Bool {
        let sistema = s.sistema
        guard !s.bloccato, s.presentazione == nil, sistema.sovrapposizione == nil, sistema.guida == nil,
              !s.pannelloRicerca, !s.pannelloSpazi, !s.pannelloNotifiche, !s.pannelloAppAperte, !s.pannelloCliente,
              !sistema.pannelloNovita, s.notaVocale.mostrata == nil, s.notaVocale.inModifica == nil,
              // Migliorie d'uso 3: il dettaglio di una voce del «Da fare» al centro chiude da sé (✕, velo, Esc)
              s.voceDaFareAperta == nil
        else { return false }
        switch app {
        // Territorio chiude da sé una cosa alla volta (`onExitCommand`, AppTerritorio.swift)
        case .territorio: return false
        // La palestra della trattativa: Esc interrompe Vera mentre scrive (StudioPalestra.swift)
        case .studio: return s.palestra.fase != .veraScrive
        default: return true
        }
    }
}
#endif
