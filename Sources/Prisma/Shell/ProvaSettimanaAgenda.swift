import Foundation

/// Migliorie d'uso 18 «La settimana si vede tutta» (solo sul Mac, dentro `--prova-vera`): l'Agenda apre sulla settimana;
/// un appuntamento aperto da notifiche, ricerca o «Da fare» con la settimana passa a «Giorno», dove c'è il dettaglio; le
/// occasioni del pulsante seguono il cliente scelto e aprirne una non lo azzera.
enum ProvaSettimanaAgenda {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        #if os(macOS)
        let s = StatoShell(persistente: false)
        controlla(s.vistaAgenda == .settimana, "Settimana: sul Mac l'Agenda apre sulla settimana")
        if let a = s.appuntamenti.first {
            s.vistaAgenda = .settimana
            s.vai(a: .appuntamento(a.id))
            controlla(s.vistaAgenda == .giorno && s.appuntamentoSelezionato == a.id
                      && s.giornoAgenda == Calendar.current.startOfDay(for: a.inizio),
                      "Settimana: un appuntamento aperto dalla ricerca passa a «Giorno» e si sceglie")
            s.vistaAgenda = .mese
            s.vai(a: .appuntamento(a.id))
            controlla(s.vistaAgenda == .mese, "Settimana: dal mese l'appuntamento resta nel mese (ha la colonna del dettaglio)")
            s.vistaAgenda = .settimana
            s.mostraInAgenda(a)
            controlla(s.vistaAgenda == .giorno && s.appuntamentoSelezionato == a.id,
                      "Settimana: «Apri in Agenda» dalla settimana mostra l'appuntamento in «Giorno»")
        } else {
            controlla(false, "Settimana: nei dati di prova manca un appuntamento")
        }
        s.scegliCliente("marco")
        s.filtroClienteAgenda = "marco"
        let prossime = s.occasioniProssimeAgenda
        controlla(prossime.allSatisfy { $0.clienteId == "marco" },
                  "Settimana: il pulsante «Occasioni» conta solo le occasioni del cliente scelto")
        s.apriOccasioneDaPulsante(prossime.first)
        controlla(s.vistaAgenda == .occasioni && s.filtroClienteAgenda == "marco"
                  && s.occasioneSelezionata?.id == prossime.first?.id,
                  "Settimana: un'occasione del pulsante apre la vista «Occasioni» senza azzerare il cliente")
        #endif
    }
}
