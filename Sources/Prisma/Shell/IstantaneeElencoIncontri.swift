#if os(macOS)
import Foundation

/// Migliorie d'uso 21 «Incontri segue il cliente e non si ferma a oggi»: l'elenco «Oggi», «Prossimi», «Fatti» con
/// «Tutti i clienti» e i due vuoti di un cliente senza incontri (la colonna e la parte destra con «Apri l'Agenda»).
/// Le scene di sempre (21, 22, 105, 215, 580-589) mostrano la colonna con un cliente scelto (Giulia: oggi, prossimi e
/// fatti dai dati di prova).
extension Istantanee {
    nonisolated static var sceneElencoIncontri: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("476-incontri-tutti-i-clienti", { s in
                s.scegliCliente(nil)
                s.schedaIncontro = .preparazione
                s.apri(.incontri)
            }),
            ("477-incontri-cliente-senza-incontri", { s in
                // Sofia senza appuntamenti né incontri: i due vuoti
                s.dati.appuntamenti.removeAll { $0.clienteId == "sofia" }
                s.dati.incontri.removeAll { $0.clienteId == "sofia" }
                s.scegliCliente("sofia")
                s.apri(.incontri)
            }),
        ]
    }
}
#endif
