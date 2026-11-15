import SwiftUI

// Migliorie d'uso 34 «Le esperienze della Sala, al momento giusto» (Design/uso/gruppo-05.md §34): le esperienze
// consigliate per il cliente, dalle stesse priorità di Analisi 360 (miglioria 17, `PrioritaAree360`), tenute in cache.

extension StatoShell {
    /// Le priorità di Analisi 360 del cliente, in ordine (la stessa definizione delle capsule «Priorità 1, 2, 3» delle
    /// card: i primi tre bisogni della ruota, senza ruota l'area più scoperta), in cache finché non cambiano i dati.
    func prioritaAree360(_ id: String) -> [AreaAnalisi] {
        ricavato("priorita-aree360|\(id)") { () -> [AreaAnalisi] in
            guard let c = cliente(id) else { return [] }
            let bisogni = MotoreBisogni.priorita(bisogniRilevati(c.id), profilo: c.bisogni)
            return PrioritaAree360.calcola(bisogni: bisogni, aree: aree360(id).aree,
                                           ripiego: Tema.Apple.Aree360.Area.numeraPriorita).aree
        }
    }

    /// Le due esperienze consigliate per il cliente (al più), mai inventate: senza priorità nessuna.
    func esperienzeConsigliate(_ id: String) -> [EsperienzaSala] {
        if sala.senzaPrioritaIstantanea { return [] }
        return ricavato("sala-consigliate|\(id)") { () -> [EsperienzaSala] in
            EsperienzaSala.consigliate(priorita: prioritaAree360(id))
        }
    }

    /// Le indicazioni di lavoro della griglia (momenti, filtro, consigli): solo sul Mac, con un cliente scelto, fuori
    /// dalla modalità cliente e dalla vista pulita di «Mostra al cliente».
    var indicazioniSala: Bool {
        Tema.Apple.SalaEsperienze.Momento.ammesso && clienteAttivo != nil && !inModoCliente && !inVistaCliente
    }
}
