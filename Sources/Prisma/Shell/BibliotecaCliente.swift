import Foundation

// Migliorie d'uso 35 «Biblioteca: prima i documenti del cliente, e si aprono con un clic» (Design/uso/gruppo-05.md §35):
// la Biblioteca segue il cliente della barra. Con un cliente scelto la colonna mette in cima i documenti dei suoi
// prodotti (il legame passa da `TestoNorma.prodottoId` e dalle posizioni del cliente: nessun campo nuovo); cambiando
// cliente si chiudono la risposta e il documento aperto. Il nome del cliente compare solo nell'intestazione della
// colonna: a Qwen vanno come prima la domanda e i passi, mai dati dei clienti. La Biblioteca c'è solo sul Mac.

extension StatoShell {
    /// Il cliente di cui parla la Biblioteca: quello della barra, nil con «Tutti i clienti» (e su iPhone e iPad, dove
    /// la Biblioteca non c'è).
    var clienteBiblioteca: Cliente? {
        #if os(macOS)
        return tuttiIClienti ? nil : clienteAttivo
        #else
        return nil
        #endif
    }

    /// Gli id dei documenti dei prodotti del cliente (posizioni in essere e proposte non rifiutate), nell'ordine
    /// dell'elenco. In cache con `ricavato`: la chiave porta la firma dei documenti (quali ci sono e a quale prodotto
    /// sono collegati), che non stanno nei dati dei calcoli e cambiano solo a lettura finita.
    func documentiBibliotecaCliente(_ id: String) -> [String] {
        let documenti = biblioteca.tutti
        var firma = Hasher()
        for d in documenti {
            firma.combine(d.id)
            firma.combine(d.prodottoId)
        }
        let chiave = "biblioteca-cliente|\(id)|\(documenti.count)|\(firma.finalize())"
        return ricavato(chiave) {
            MotoreBiblioteca.documentiDelCliente(prodotti: MotoreBiblioteca.prodottiDelCliente(posizioniCliente(id)),
                                                 tra: documenti)
        }
    }

    /// Cambiando cliente nella barra si chiudono la risposta e il documento aperto (come `qaI=-1` del template); la
    /// domanda in corso si ferma.
    func chiudiBibliotecaPerCliente() {
        let t = trovaPagina
        guard t.risultato != nil || t.aperta != nil || t.compito != nil else { return }
        t.compito?.cancel()
        t.compito = nil
        t.domanda = ""
        t.risultato = nil
        t.aperta = nil
    }
}
