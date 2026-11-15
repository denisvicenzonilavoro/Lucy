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
        tutte += sceneArrivoObiettivi
        // Migliorie d'uso 17 «Le priorità in ordine: 1, 2, 3»: la scheda Bisogni di Marco, con la capsula della card di
        // Analisi 360 su ogni riga e la nota sull'ordine (vera per lui), chiara e scura
        let bisogni: (StatoShell) -> Void = { s in
            s.clienteAttivoId = "marco"
            s.schedaCliente = .bisogni
            s.apri(.clienti)
        }
        tutte += [(nome: "1032-uso-dossier-bisogni", prepara: bisogni),
                  (nome: "1032-uso-dossier-bisogni-scuro", prepara: bisogni)]
        return tutte
    }

    /// Migliorie d'uso 13 «Obiettivi: si vede se ci arriva», chiara e scura: gli obiettivi di Giulia con uno stato per
    /// tono. Il margine di serenità con un versamento sopra il necessario (in tempo), l'anticipo casa con meno del
    /// necessario (in ritardo) e un obiettivo nuovo senza nulla da parte né versamenti (senza versamenti). I versamenti
    /// li ricava la scena dalla curva di ogni obiettivo (`CurvaObiettivo.versamentoNecessario`), non scritti a mano.
    nonisolated private static var sceneArrivoObiettivi: [(nome: String, prepara: (StatoShell) -> Void)] {
        let prepara: (StatoShell) -> Void = { s in
            let posizioni = s.posizioniCliente("giulia")
            let passo = Tema.Apple.Clienti.DettaglioObiettivo.passoCursore
            var elenco = s.dati.obiettivi.map { o -> Obiettivo in
                guard o.clienteId == "giulia" else { return o }
                var nuovo = o
                let necessario = CurvaObiettivo(o, posizioni: posizioni).versamentoNecessario ?? 0
                if o.id == "obiettivo-giulia-casa" {
                    nuovo.versamentoMensile = (necessario * 0.75 / passo).rounded(.down) * passo
                } else if o.id == "obiettivo-giulia-riserva" {
                    nuovo.versamentoMensile = (necessario * 1.15 / passo).rounded(.up) * passo
                }
                return nuovo
            }
            if !elenco.contains(where: { $0.id == "obiettivo-giulia-uso-13" }) {
                let tra = Calendar.current.date(byAdding: .year, value: 6, to: Date()) ?? Date()
                var pensione = Obiettivo(clienteId: "giulia", titolo: "Una pensione più serena", area: .pensione,
                                         importo: 25_000, scadenza: tra)
                pensione.id = "obiettivo-giulia-uso-13"
                elenco.append(pensione)
            }
            s.dati.obiettivi = elenco
            s.clienteAttivoId = "giulia"
            s.schedaCliente = .obiettivi
            s.apri(.clienti)
        }
        return [(nome: "1023-uso-obiettivi-stato", prepara: prepara),
                (nome: "1023-uso-obiettivi-stato-scuro", prepara: prepara)]
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
