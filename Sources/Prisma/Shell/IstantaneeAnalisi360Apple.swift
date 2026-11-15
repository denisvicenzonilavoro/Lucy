#if os(macOS)
import Foundation

/// Le istantanee della griglia delle aree di Analisi 360 nel tema Apple (§4.3.1, §4.3.4, §4.3.5): le quattro card
/// con l'anello per Giulia, in chiaro e in scuro, e i dettagli Investimenti (barra di composizione, tile con i canali,
/// coerenza, profilo e costo medio) e Risparmio e liquidità (blocchi dei mesi e soglia delle ipotesi) già aperti
/// con `RichiestaIstantaneaAnalisi360`. Le cifre vengono dai motori di Prisma sui dati di prova. Sul Mac la griglia ha
/// una sola capsula delle stime (migliorie d'uso 16), aperta in 1038 e verde in 1039.
extension Istantanee {
    nonisolated static var sceneAnalisi360Apple: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("440-analisi360-apple", { s in preparaAree360Apple(s) }),
            ("440-analisi360-apple-scuro", { s in preparaAree360Apple(s) }),
            ("443-analisi360-investimenti-dettaglio", { s in
                RichiestaIstantaneaAnalisi360.chiedi(s, area: .investimenti)
                preparaAree360Apple(s)
            }),
            ("444-analisi360-liquidita-dettaglio", { s in
                RichiestaIstantaneaAnalisi360.chiedi(s, area: .risparmio)
                preparaAree360Apple(s)
            }),
            // Migliorie d'uso 16 «Un solo avviso sulle stime»: l'elenco dei dati aperto dalla capsula (Giulia) e la
            // capsula verde di un cliente senza stime (le voci da completare segnate non pertinenti).
            // (1038-1039: 1030-1031 sono già del pannello «Da fare», migliorie d'uso 3)
            ("1038-uso-analisi360-stime-aperte", { s in
                RichiestaIstantaneaAnalisi360.chiediStime(s)
                preparaAree360Apple(s)
            }),
            ("1039-uso-analisi360-nessuna-stima", { s in
                for v in s.completezzaCliente("giulia")?.daCompletare ?? [] {
                    s.segnaDatoNonPertinente(v.id, cliente: "giulia")
                }
                preparaAree360Apple(s)
            }),
        ]
    }

    /// Analisi 360 aperta sulla griglia delle aree di Giulia (nessuna area né strumento scelti).
    nonisolated static func preparaAree360Apple(_ s: StatoShell) {
        s.clienteAttivoId = "giulia"
        s.areaAnalisi = nil
        s.scegliStrumentoAnalisi(nil)
        s.apri(.analisi360)
    }
}
#endif
