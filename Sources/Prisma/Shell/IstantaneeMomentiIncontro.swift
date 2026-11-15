#if os(macOS)
import Foundation

/// Migliorie d'uso 20 «L'incontro ha tre momenti: Prima, Durante, Dopo»: la testata bassa con i tre momenti resta sempre
/// in vista. 472: il verbale del copilota dentro «Dopo» (chiara e scura); 473: «Il verbale non c'è ancora.»; 474: «Durante»
/// con gli appunti a mano; 475: «Durante» senza consenso (la riga arancione «Manca il consenso all'ascolto»).
/// DATI DI PROVA DICHIARATI: il dialogo e le schede del copilota sono quelli del template (DialogoProvaCopilota.swift).
extension Istantanee {
    nonisolated static var sceneMomentiIncontro: [(nome: String, prepara: (StatoShell) -> Void)] {
        let verbale: (StatoShell) -> Void = { s in
            let sid = DialogoProvaCopilota.prepara(s, righe: 7)
            s.copilota.mostraPerIstantanea(fase: .concluso, sessione: sid, secondi: 18 * 60, qwenPronto: true)
            s.schedaIncontro = .passi
            s.apri(.incontri)
        }
        return [
            ("472-incontri-dopo-verbale", verbale),
            ("472-incontri-dopo-verbale-scuro", verbale),
            ("473-incontri-dopo-vuoto", { s in
                DialogoProvaCopilota.prepara(s, righe: 0)
                s.copilota.mostraPerIstantanea(fase: .pronto, sessione: nil, secondi: 0, qwenPronto: true)
                s.schedaIncontro = .passi
                s.apri(.incontri)
            }),
            ("474-incontri-durante-appunti", { s in
                DialogoProvaCopilota.prepara(s, righe: 0)
                s.copilota.modo = .appunti
                s.apri(.incontri)
            }),
            ("475-incontri-senza-consenso", { s in
                DialogoProvaCopilota.prepara(s, righe: 0, consenso: false)
                s.copilota.mostraPerIstantanea(fase: .pronto, sessione: nil, secondi: 0, qwenPronto: true)
                s.apri(.incontri)
            }),
        ]
    }
}
#endif
