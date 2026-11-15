#if os(macOS)
import Foundation

/// Le istantanee di «App aperte e spazi dal nome dell'app» (migliorie d'uso 67, Design/uso/gruppo-11.md §67.5):
/// - 1310: Clienti con Giulia e Agenda aperte, il menu sotto «Agenda» (Clienti con «Giulia», i tre spazi, le due voci in
///   fondo), chiara e scura;
/// - 1311: dalla scrivania, «Nessun’altra app aperta, per ora»;
/// - 1312: il modulo per salvare le finestre aperte come spazio.
extension Istantanee {
    nonisolated static var sceneMenuApp: [(nome: String, prepara: (StatoShell) -> Void)] {
        let dueApp: (StatoShell) -> Void = { s in
            s.scegliCliente("giulia")
            s.apri(.clienti)
            s.apri(.agenda)
            s.menuApp = true
        }
        return [
            (nome: "1310-uso-menu-app", prepara: dueApp),
            (nome: "1310-uso-menu-app-scuro", prepara: dueApp),
            (nome: "1311-uso-menu-app-vuoto", prepara: { s in
                s.menuApp = true
            }),
            (nome: "1312-uso-salva-spazio", prepara: { s in
                dueApp(s)
                s.sistema.menuAppSalva = true
            }),
        ]
    }
}
#endif
