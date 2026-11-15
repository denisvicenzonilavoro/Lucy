#if os(macOS)
import Foundation

/// Le istantanee di «Barre più corte» (migliorie d'uso 6, Design/uso/gruppo-01.md §6.5): la guida della scrivania,
/// aperta dal «?» della barra senza un'app davanti (chiara e scura). Il menu «Aggiungi» di Posizioni è un menu del Mac
/// e nelle istantanee non si vede: per quello serve uno screenshot.
extension Istantanee {
    nonisolated static var sceneBarreCorte: [(nome: String, prepara: (StatoShell) -> Void)] {
        let chiare: [(String, (StatoShell) -> Void)] = [
            ("1060-guida-scrivania", { s in
                s.mostraScrivania()
                s.apriGuida(s.paginaGuidaDavanti)
            }),
        ]
        return chiare.flatMap { nome, prepara in
            [(nome: nome, prepara: prepara), (nome: nome + "-scuro", prepara: prepara)]
        }
    }
}
#endif
