#if os(macOS)
import SwiftUI

/// Le istantanee di «Le parole si spiegano dove sono» (migliorie d'uso 66, Design/uso/gruppo-11.md §66.5):
/// - 1308: Marco, Posizioni › Costi, come nel template: le parole del mestiere segnate una volta (chiara e scura);
/// - 1309: la scheda di «gestione separata» sopra la stessa schermata. Il popover non si fotografa: la scena disegna
///   `SchedaParola` dentro una vetrina, come le altre schede a comparsa.
extension Istantanee {
    nonisolated static var sceneParole: [(nome: String, prepara: (StatoShell) -> Void)] {
        let costiMarco: (StatoShell) -> Void = { s in s.apriPosizioniCliente("marco", vista: .costi) }
        return [
            (nome: "1308-uso-parole-filo", prepara: costiMarco),
            (nome: "1308-uso-parole-filo-scuro", prepara: costiMarco),
            (nome: "1309-uso-parole-scheda", prepara: costiMarco),
            (nome: "1309-uso-parole-scheda-scuro", prepara: costiMarco),
        ]
    }

    /// La vetrina della scheda della parola (1309), sopra la shell velata.
    static func tavolaParola(_ nome: String) -> AnyView? {
        guard nome.hasPrefix("1309-uso-parole-scheda"), let voce = Glossario.voce(.gestioneSeparata) else { return nil }
        return AnyView(
            ZStack {
                ShellView()
                Tema.Apple.Colore.velo
                SchedaParola(voce: voce) {}
                    .background(Tema.Apple.Colore.vetroSopra)
                    .clipShape(RoundedRectangle(cornerRadius: Tema.Apple.Raggio.finestra, style: .continuous))
                    .ombraApple(.finestra)
            }
        )
    }
}
#endif
