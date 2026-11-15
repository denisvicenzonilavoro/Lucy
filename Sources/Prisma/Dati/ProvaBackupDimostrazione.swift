import Foundation

// Migliorie d'uso 37 · «La dimostrazione è un interruttore» dentro `Prisma --prova-backup` (Design/uso/gruppo-06.md §37.5).
// Con la dimostrazione accesa in memoria ci sono solo i clienti di prova: un cliente vero non si trova con la ricerca,
// nessuna pulizia toglie file, salvataggi e scritture accanto all'archivio sono fermi, le scritte «dati di prova» sparse
// tacciono (basta l'etichetta nella barra) e la guida non si mostra. Spenta, i dati di prima tornano identici, con le sole
// scelte di aspetto, nomi dei canali e Vera fatte in dimostrazione (decisione 7). Lo stato è non persistente (come in
// tutte le prove): i dati di prima stanno in memoria al posto dell'archivio sul disco; le guardie su disco sono le stesse.

extension ProvaBackup {
    /// Restituisce il motivo dell'errore (nil = tutto bene).
    static func provaDimostrazione() -> String? {
        #if os(macOS)
        let stato = StatoShell(persistente: false)
        guard !stato.inDimostrazione, stato.scritteProva else {
            return "dimostrazione: all'inizio è spenta e i clienti di prova dell'archivio si dichiarano"
        }
        // Un cliente «vero» riconoscibile e una scelta di aspetto
        guard let i = stato.dati.clienti.indices.first else { return "dimostrazione: nessun cliente nei dati di prova" }
        let nomeVero = "Zelinda Quaglierini"
        stato.dati.clienti[i].nome = nomeVero
        let idVero = stato.dati.clienti[i].id
        stato.dati.impostazioni.nomeUtente = "Consulente di prova"
        let prima = stato.dati.istantanea

        stato.accendiDimostrazione(.cinque, avviso: false)
        guard stato.inDimostrazione, stato.gruppoProva == .cinque else { return "dimostrazione: non si accende" }
        guard !stato.dati.clienti.contains(where: { $0.nome == nomeVero }) else {
            return "dimostrazione: il cliente vero è ancora nei dati in memoria"
        }
        let trovati = MotoreRicerca.cerca("Quaglierini", in: stato).flatMap(\.risultati)
        guard trovati.isEmpty else { return "dimostrazione: la ricerca trova ancora il cliente vero (\(trovati.count) risultati)" }
        guard stato.dati.clienti.allSatisfy({ StatoShell.clientiDiProva.contains($0.id) }) else {
            return "dimostrazione: in memoria c'è un cliente che non è di prova"
        }
        guard stato.dati.impostazioni.nomeUtente == "Consulente di prova" else {
            return "dimostrazione: il nome nel profilo non è quello dell'utente"
        }
        guard stato.pulisciDocumentiOrfani() == 0 else { return "dimostrazione: la pulizia dei documenti ha tolto dei file" }
        guard stato.memoriaVera.ferma, stato.biblioteca.ferma, stato.moduli.ferma else {
            return "dimostrazione: memoria di Vera, Biblioteca o Moduli scrivono ancora"
        }
        guard !stato.scritteProva, !stato.guidaVisibile, !stato.passiGuida.contains(where: { $0.azione == .togliProva }) else {
            return "dimostrazione: le scritte «dati di prova», la guida o «Togli i clienti di prova» compaiono ancora"
        }
        // Il gruppo si cambia anche con la dimostrazione accesa
        stato.accendiDimostrazione(.trentacinque, avviso: false)
        guard stato.inDimostrazione, stato.gruppoProva == .trentacinque,
              stato.dati.clienti.count == ClientiFittizi.completi().clienti.count else {
            return "dimostrazione: «Usa questi» non carica i trentacinque clienti"
        }
        // Le modifiche fatte in dimostrazione si perdono, tranne l'aspetto (decisione 7)
        stato.dati.clienti.removeAll()
        stato.dati.impostazioni.riduciMovimento.toggle()
        let movimento = stato.dati.impostazioni.riduciMovimento

        stato.spegniDimostrazione(avviso: nil)
        guard !stato.inDimostrazione, !stato.memoriaVera.ferma, !stato.biblioteca.ferma, !stato.moduli.ferma else {
            return "dimostrazione: non si spegne del tutto"
        }
        var attesi = prima
        attesi.impostazioni.riduciMovimento = movimento
        guard stato.dati.istantanea == attesi else { return "dimostrazione: spenta, i dati non sono quelli di prima" }
        guard stato.cliente(idVero)?.nome == nomeVero, stato.scritteProva else {
            return "dimostrazione: spenta, il cliente vero o le scritte di prova non tornano"
        }
        print("OK    dimostrazione: accesa solo i clienti di prova (ricerca, pulizie e scritture ferme), spenta tutto torna com'era")
        #endif
        return nil
    }
}
