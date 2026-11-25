#if os(macOS)
import SwiftUI

/// Le istantanee del catalogo delle compagnie (25 novembre 2026), il foglio messo sopra la shell con il velo (i fogli
/// non si disegnano fuori schermo), con il dossier di Giulia in Posizioni:
/// - 904: l'elenco, con la scelta della compagnia, la ricerca e in fondo la guida per categoria;
/// - 905: la scheda di GenerAzione Investimento con un versamento di 10.000 € dal 2025, i passi del totale aperti
///   («tocca e capisci»), chiara e scura.
extension Istantanee {
    nonisolated static var sceneCatalogoCompagnie: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("904-catalogo-compagnie-elenco", { s in giuliaInPosizioni(s) }),
            ("905-catalogo-compagnie-scheda", { s in giuliaInPosizioni(s) }),
            ("905-catalogo-compagnie-scheda-scuro", { s in giuliaInPosizioni(s) }),
        ]
    }

    nonisolated private static func giuliaInPosizioni(_ s: StatoShell) {
        s.clienteAttivoId = "giulia"
        s.apri(.posizioni)
    }

    /// La shell con sopra il foglio; nil per le altre scene.
    static func catalogoCompagnieIstantanea(_ nome: String, _ s: StatoShell) -> AnyView? {
        guard nome.hasPrefix("90"), sceneCatalogoCompagnie.contains(where: { $0.nome == nome }) else { return nil }
        var richiesta = RichiestaCatalogoCompagnie()
        if nome.hasPrefix("905") {
            let voce = CatalogoProdotti.condiviso?.cerca("GenerAzione Investimento", foglio: .investimento).first
            richiesta.voceId = voce?.id
            richiesta.importoUnico = 10_000
            richiesta.annoInizio = 2025
            richiesta.aperti = ["totale"]
        }
        return AnyView(
            ZStack {
                ShellView()
                Tema.Colore.velo
                FoglioCatalogoCompagnie(richiesta: richiesta)
                    // Il foglio vero ha il fondo del sistema: qui serve pieno, o la shell passerebbe attraverso
                    .clipShape(RoundedRectangle(cornerRadius: Tema.Apple.Raggio.finestra, style: .continuous))
                    .ombraApple(.finestra)
            }
        )
    }
}
#endif
