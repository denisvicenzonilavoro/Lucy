#if os(macOS)
import Foundation

/// Le istantanee delle schede Panoramica e Obiettivi del dossier nel tema Apple (§4.2.2, §4.2.3): la Panoramica di
/// Marco (dati per l'analisi con l'anello e le voci da completare, «Da ricordare», il prossimo incontro), gli
/// obiettivi di Giulia (due card e il posto libero) e il dettaglio dell'anticipo casa aperto con il cursore. Le cifre
/// vengono dai motori di Prisma sui dati di prova.
extension Istantanee {
    nonisolated static var sceneDossierApple: [(nome: String, prepara: (StatoShell) -> Void)] {
        var tutte: [(nome: String, prepara: (StatoShell) -> Void)] = [
            ("431-clienti-panoramica-apple", { s in
                s.clienteAttivoId = "marco"
                s.schedaCliente = .panoramica
                s.apri(.clienti)
            }),
            ("432-clienti-obiettivi-apple", { s in
                s.clienteAttivoId = "giulia"
                s.schedaCliente = .obiettivi
                s.apri(.clienti)
            }),
            ("433-clienti-obiettivo-dettaglio", { s in
                s.clienteAttivoId = "giulia"
                s.schedaCliente = .obiettivi
                RichiestaIstantaneaDossier.chiedi(s, dettaglio: "obiettivo-giulia-casa")
                s.apri(.clienti)
            }),
        ]
        tutte += sceneQuadroDossier
        return tutte
    }

    /// Migliorie d'uso 5 «Il dossier parte dal quadro» (DossierQuadro.swift), chiare e scure: l'elenco dei dati da
    /// completare nato dalla riga del quadro, la riga con i dati completi (le voci mancanti segnate non pertinenti) e la
    /// Panoramica in modalità cliente (il quadro sì, la riga dei dati e «Da fare» no).
    nonisolated private static var sceneQuadroDossier: [(nome: String, prepara: (StatoShell) -> Void)] {
        let chiare: [(String, (StatoShell) -> Void)] = [
            ("1050-clienti-panoramica-dati-aperti", { s in
                s.clienteAttivoId = "marco"
                s.schedaCliente = .panoramica
                RichiestaIstantaneaDossier.chiedi(s, dettaglio: QuadroDossier.idDati)
                s.apri(.clienti)
            }),
            ("1051-clienti-panoramica-dati-completi", { s in
                s.clienteAttivoId = "giulia"
                s.schedaCliente = .panoramica
                for v in s.completezzaCliente("giulia")?.daCompletare ?? [] {
                    s.segnaDatoNonPertinente(v.id, cliente: "giulia")
                }
                s.apri(.clienti)
            }),
            ("1052-clienti-panoramica-modo-cliente", { s in
                s.clienteAttivoId = "giulia"
                s.schedaCliente = .panoramica
                s.apri(.clienti)
                s.entraModoCliente(avviso: false)
            }),
        ]
        return chiare.flatMap { nome, prepara in
            [(nome: nome, prepara: prepara), (nome: nome + "-scuro", prepara: prepara)]
        }
    }
}
#endif
