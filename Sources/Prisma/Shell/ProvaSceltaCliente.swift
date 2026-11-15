import Foundation

/// Migliorie d'uso 2 «Un solo posto per scegliere il cliente» (solo sul Mac): «Tutti i clienti» è il cliente attivo vuoto,
/// `portafoglio` e `veraPortafoglio` lo seguono; scrivere true sceglie «Tutti», false torna al cliente di prima; i recenti
/// sono al più tre (anche le scelte silenziose); la modalità cliente mostra il cliente scelto per ultimo e la pillola non
/// lo cambia; scegliere il cliente già scelto non fa niente.
enum ProvaSceltaCliente {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        #if os(macOS)
        let s = StatoShell(persistente: false)
        s.clienteAttivoId = "marco"
        controlla(!s.tuttiIClienti && !s.portafoglio && !s.veraPortafoglio && s.clientiRecenti.first == "marco",
                  "Scelta del cliente: un cliente scelto, niente portafoglio, e il cliente nei recenti")
        s.portafoglio = true
        controlla(s.tuttiIClienti && s.clienteAttivoId.isEmpty && s.veraPortafoglio,
                  "Scelta del cliente: il portafoglio di Posizioni è «Tutti i clienti», e Vera lo segue")
        s.portafoglio = false
        controlla(s.clienteAttivoId == "marco" && !s.veraPortafoglio,
                  "Scelta del cliente: lasciato il portafoglio si torna al cliente di prima")
        s.veraPortafoglio = true
        s.veraPortafoglio = false
        controlla(s.clienteAttivoId == "marco", "Scelta del cliente: Vera torna al cliente di prima")
        s.scegliCliente("laura")
        s.scegliCliente("giulia")
        s.clienteAttivoId = "sofia"
        s.scegliCliente("andrea")
        controlla(s.clientiRecenti == ["andrea", "sofia", "giulia"],
                  "Scelta del cliente: al più tre recenti, anche le scelte silenziose (\(s.clientiRecenti))")
        s.filtroClienteAgenda = nil
        s.scegliCliente("andrea", avviso: true)
        controlla(s.filtroClienteAgenda == nil, "Scelta del cliente: il cliente già scelto non cambia niente")
        s.scegliCliente("marco")
        controlla(s.filtroClienteAgenda == "marco" && s.filtroClienteAttivita == "marco",
                  "Scelta del cliente: l'Agenda segue il cliente scelto (la pillola «Solo Marco ✕»)")
        s.vistaClienti = .potenziali
        s.scegliCliente(nil, avviso: true)
        controlla(s.tuttiIClienti && s.filtroClienteAgenda == nil && s.vistaClienti == .rubrica,
                  "Scelta del cliente: «Tutti i clienti» riporta l'Agenda a tutti e Clienti alla Rubrica")
        s.entraModoCliente(avviso: false)
        controlla(s.inModoCliente && s.clienteAttivoId == "marco",
                  "Scelta del cliente: da «Tutti i clienti» la modalità cliente mostra il cliente scelto per ultimo")
        s.scegliCliente("giulia")
        s.portafoglio = true
        controlla(s.clienteAttivoId == "marco" && !s.portafoglio && !s.tuttiIClienti,
                  "Scelta del cliente: in modalità cliente né la scelta né il portafoglio cambiano il cliente mostrato")
        s.apriSceltaCliente()
        controlla(!s.pannelloCliente, "Scelta del cliente: in modalità cliente il pannello non si apre")
        s.esciModoCliente()
        s.apriSceltaCliente()
        controlla(s.pannelloCliente, "Scelta del cliente: fuori dalla modalità cliente il pannello si apre")
        s.pannelloCliente = false
        // L'unione di «Prisma ovunque» tiene «Tutti i clienti» del dispositivo
        var locale = DatiPrisma.demo()
        locale.clienteAttivoId = ""
        let mac = DatiPrisma.demo()
        let ist = IstantaneaOvunque(generazione: 1, mac: "mac-prova", nomeMac: "Mac", scrittaIl: Date(), vistoFinoA: [:], lamport: 0,
                                    modificheAmmesse: true, dati: SpazioOvunque.datiIstantanea(mac))
        let unito = SincroniaOvunque.accogli(ist, in: locale).dati
        controlla(unito.clienteAttivoId.isEmpty, "Scelta del cliente: l'unione di Prisma ovunque tiene «Tutti i clienti»")
        #endif
    }
}
