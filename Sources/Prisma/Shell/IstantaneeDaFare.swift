#if os(macOS)
import Foundation

/// Le istantanee del «Da fare» unico (migliorie d'uso 3, Design/uso/gruppo-01.md §3.5), chiare e scure: il pannello della
/// pillola su «Tutti i clienti», «Solo <Nome>», il campo «+ Aggiungi», «Fatte oggi · Annulla l’ultima» dopo una spunta,
/// il dettaglio di una voce al centro della scrivania e la scheda semplice di una cosa scritta a mano.
extension Istantanee {
    nonisolated static var sceneDaFare: [(nome: String, prepara: (StatoShell) -> Void)] {
        let chiare: [(String, (StatoShell) -> Void)] = [
            ("1030-da-fare-pannello", { s in
                s.scegliCliente(nil)
                s.apriDaFare()
            }),
            ("1031-da-fare-solo-cliente", { s in
                if s.tuttiIClienti, let c = s.clienti.first { s.scegliCliente(c.id) }
                s.apriDaFare(soloCliente: true)
            }),
            ("1032-da-fare-aggiungi", { s in
                s.scegliCliente(nil)
                s.apriDaFare()
                s.daFareScrivo = true
            }),
            ("1033-da-fare-annulla", { s in
                s.scegliCliente(nil)
                if let v = s.nastroDaFareCompleto(cliente: nil).voci.first(where: { $0.fatto == .segna }) {
                    s.fattoDaFare(v)
                }
                s.apriDaFare()
            }),
            ("1034-da-fare-dettaglio", { s in
                s.scegliCliente(nil)
                if let v = s.nastroDaFareCompleto(cliente: nil).voci.first(where: { $0.tipo != .attivita }) {
                    s.apriVoceDaFare(v)
                }
            }),
            ("1035-da-fare-scritta-da-te", { s in
                s.scegliCliente(nil)
                s.aggiungiDaFare("Rinnovare l’iscrizione all’albo")
                if let v = s.nastroDaFareCompleto(cliente: nil).voci.first(where: { $0.tipo == .attivita && $0.cliente.id.isEmpty }) {
                    s.apriVoceDaFare(v)
                }
            }),
        ]
        return chiare.flatMap { nome, prepara in
            [(nome: nome, prepara: prepara), (nome: nome + "-scuro", prepara: prepara)]
        }
    }
}
#endif
