#if os(macOS)
import Foundation

/// Le istantanee di «Un solo posto per scegliere il cliente» (migliorie d'uso 2, Design/uso/gruppo-01.md §2.5): la
/// pillola della barra con un cliente e con «Tutti i clienti», il pannello «Di chi parliamo?» con i recenti (chiare e
/// scure), i vuoti di Analisi 360, Sala e Prospetti senza cliente e l'Agenda con «Solo <Nome> ✕».
extension Istantanee {
    nonisolated static var sceneSceltaCliente: [(nome: String, prepara: (StatoShell) -> Void)] {
        let chiare: [(String, (StatoShell) -> Void)] = [
            ("1020-barra-cliente", { s in
                s.scegliCliente("giulia")
            }),
            ("1021-barra-tutti-i-clienti", { s in
                s.scegliCliente(nil)
            }),
            ("1022-pannello-cliente", { s in
                // Tre scelte di fila: i recenti sono Giulia, Laura e Marco
                s.scegliCliente("marco")
                s.scegliCliente("laura")
                s.scegliCliente("giulia")
                s.pannelloCliente = true
            }),
        ]
        let soloChiare: [(String, (StatoShell) -> Void)] = [
            ("1024-analisi-senza-cliente", { s in
                s.scegliCliente(nil)
                s.apri(.analisi360)
            }),
            ("1025-sala-senza-cliente", { s in
                s.scegliCliente(nil)
                s.apri(.sala)
            }),
            ("1026-prospetti-senza-cliente", { s in
                s.scegliCliente(nil)
                s.prospetto = nil
                s.apri(.presentazioni)
            }),
            ("1027-agenda-solo-cliente", { s in
                s.scegliCliente("marco")
                s.apri(.agenda)
            }),
        ]
        let conScuro: [(nome: String, prepara: (StatoShell) -> Void)] = chiare.flatMap { nome, prepara in
            [(nome: nome, prepara: prepara), (nome: nome + "-scuro", prepara: prepara)]
        }
        let altre: [(nome: String, prepara: (StatoShell) -> Void)] = soloChiare.map { (nome: $0.0, prepara: $0.1) }
        return conScuro + altre
    }
}
#endif
