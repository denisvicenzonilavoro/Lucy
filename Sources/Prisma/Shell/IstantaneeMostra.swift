#if os(macOS)
import Foundation

/// Le istantanee di «Mostra al cliente» (migliorie d'uso 1, Design/uso/gruppo-01.md §1.5), chiare e scure: il pannello di
/// scelta con e senza cliente, i quattro capitoli della vista pulita, la scheda di una parola, le ipotesi, il menu
/// dell'avatar e la schermata neutra. L'avviso «Per tornare al lavoro…» non compare (già visto).
extension Istantanee {
    nonisolated static var sceneMostra: [(nome: String, prepara: (StatoShell) -> Void)] {
        let chiare: [(String, (StatoShell) -> Void)] = [
            ("1010-mostra-scelta", { s in
                s.scegliCliente("giulia")
                s.apriMostraAlCliente()
            }),
            ("1011-mostra-scelta-senza-cliente", { s in
                s.scegliCliente(nil)
                s.apriMostraAlCliente()
            }),
            ("1012-mostra-quadro", { s in
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.quadro)
            }),
            ("1013-mostra-posizioni", { s in
                s.scegliCliente("marco")
                s.avvisoVistaVisto = true
                s.mostra(.posizioni)
            }),
            ("1014-mostra-obiettivi", { s in
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.obiettivi)
            }),
            ("1015-mostra-nel-tempo", { s in
                s.scegliCliente("marco")
                s.avvisoVistaVisto = true
                s.mostra(.tempo)
            }),
            ("1016-mostra-parola", { s in
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.quadro)
                s.schedaMostra = .parola(.divarioPrevidenziale)
            }),
            ("1017-mostra-ipotesi", { s in
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.quadro)
                s.schedaMostra = .ipotesi
            }),
            ("1018-mostra-uscita", { s in
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.quadro)
                s.menuUscitaMostra = true
            }),
            ("1019-mostra-neutra", { s in
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.quadro)
                s.mostraNeutra()
            }),
        ]
        return chiare.flatMap { nome, prepara in
            [(nome: nome, prepara: prepara), (nome: nome + "-scuro", prepara: prepara)]
        }
    }
}
#endif
