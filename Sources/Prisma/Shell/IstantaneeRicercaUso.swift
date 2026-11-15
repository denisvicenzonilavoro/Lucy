#if os(macOS)
import Foundation

/// Le istantanee di «Cerca ovunque, e fa» (migliorie d'uso 61, Design/uso/gruppo-11.md §61.5):
/// - 1300: il campo vuoto, con «Clienti recenti», le cinque «Azioni» e le «Ricerche salvate» (chiara e scura);
/// - 1301: «mar» come nel template (clienti, posizioni, documenti, parole);
/// - 1302: nessun risultato, con «Chiedilo a Vera»;
/// - 1303: l'anteprima di una parola del glossario.
extension Istantanee {
    nonisolated static var sceneRicercaUso: [(nome: String, prepara: (StatoShell) -> Void)] {
        let vuota: (StatoShell) -> Void = { s in
            s.dati.impostazioni.ricercheSalvate = [RicercaSalvata(nome: "Proposte aperte", testo: "stato:proposta"),
                                                   RicercaSalvata(nome: "Clienti Alleanza", testo: "tipo:clienti canale:alleanza")]
            s.scegliCliente("marco")
            s.scegliCliente("giulia")
            s.testoRicerca = ""
            s.cercaOvunque()
        }
        let cerca: (String) -> (StatoShell) -> Void = { testo in
            { s in
                s.testoRicerca = testo
                s.cercaOvunque()
            }
        }
        return [
            (nome: "1300-uso-ricerca-vuota", prepara: vuota),
            (nome: "1300-uso-ricerca-vuota-scuro", prepara: vuota),
            (nome: "1301-uso-ricerca-mar", prepara: cerca("mar")),
            (nome: "1302-uso-ricerca-nessun-risultato", prepara: cerca("polizza sul gatto")),
            (nome: "1303-uso-ricerca-parola", prepara: cerca("interesse composto")),
        ]
    }
}
#endif
