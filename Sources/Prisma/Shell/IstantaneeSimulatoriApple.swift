#if os(macOS)
import Foundation

/// Le istantanee dei simulatori dal vivo di Analisi 360 nel tema Apple (§4.3.2, §4.3.3): l'area Previdenza e l'area
/// Protezione di Marco espanse nel simulatore, con il cursore spostato dal valore di partenza (il versamento di oggi
/// più 150 € al mese; 100.000 € di capitale caso morte in più). Le cifre vengono dai motori di Prisma sui dati di
/// prova; il dettaglio si apre già aperto con `RichiestaIstantaneaSimulatore` (lo legge
/// `SimulatoriAnalisiApple.dettaglioIniziale`, nel presentatore della griglia delle aree).
extension Istantanee {
    nonisolated static var sceneSimulatoriApple: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("441-analisi360-previdenza-simulatore", { s in
                s.clienteAttivoId = "marco"
                s.areaAnalisi = nil
                let oggi = s.analisi360("marco").previdenza.versamentoMensile
                let passo = Tema.Apple.SimulatoriAnalisi.Previdenza.passo
                RichiestaIstantaneaSimulatore.chiedi(s, area: .previdenza, valore: ((oggi + 150) / passo).rounded() * passo)
                s.apri(.analisi360)
            }),
            ("442-analisi360-protezione-simulatore", { s in
                s.clienteAttivoId = "marco"
                s.areaAnalisi = nil
                RichiestaIstantaneaSimulatore.chiedi(s, area: .protezione, valore: 100_000)
                s.apri(.analisi360)
            }),
            // Migliorie d'uso 45 «Il simulatore mostra prima e dopo»: Marco con il cursore sul versamento di oggi (la frase
            // con «Sposta il cursore…» e il segno «oggi» sotto la manopola), in chiaro e in scuro; un cliente senza reddito
            // lordo nella scheda (il segmentato dell'aliquota). Il passo di Investimenti e Liquidità: 1142-1143 in
            // IstantaneeAnalisi360Apple.swift.
            ("1140-uso-simulatore-previdenza-oggi", { s in prepara1140(s) }),
            ("1140-uso-simulatore-previdenza-oggi-scuro", { s in prepara1140(s) }),
            ("1141-uso-simulatore-previdenza-senza-reddito", { s in
                if var c = s.cliente("marco") {
                    c.profilo.redditoLordoAnnuo = nil
                    s.salvaCliente(c)
                }
                s.clienteAttivoId = "marco"
                s.areaAnalisi = nil
                let oggi = s.analisi360("marco").previdenza.versamentoMensile
                let passo = Tema.Apple.SimulatoriAnalisi.Previdenza.passo
                RichiestaIstantaneaSimulatore.chiedi(s, area: .previdenza, valore: ((oggi + 100) / passo).rounded() * passo)
                s.apri(.analisi360)
            }),
        ]
    }

    /// Il simulatore della previdenza di Marco aperto con il cursore sul versamento di oggi.
    nonisolated static func prepara1140(_ s: StatoShell) {
        s.clienteAttivoId = "marco"
        s.areaAnalisi = nil
        RichiestaIstantaneaSimulatore.chiedi(s, area: .previdenza, valore: s.analisi360("marco").previdenza.versamentoMensile)
        s.apri(.analisi360)
    }
}
#endif
