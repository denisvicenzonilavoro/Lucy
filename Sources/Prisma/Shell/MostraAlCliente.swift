#if os(macOS)
import SwiftUI

// Migliorie d'uso 1 «Mostra al cliente» (Design/uso/gruppo-01.md §1): un pulsante solo nella barra e una vista pulita con il
// quadro del cliente. Sotto resta la modalità cliente di sempre (filtro dei dati e cliente bloccato: la garanzia di
// privacy); sopra ci sono il pannello di scelta, i capitoli («Il quadro», «Le posizioni», «Gli obiettivi», «Nel tempo»,
// «La Sala»), le schede delle parole e delle ipotesi, il menu dell'avatar e la schermata neutra. Tutto in memoria.
//
// - Nella vista pulita non si apre nessun'altra app (solo la Sala), il marchio non porta alla scrivania, Vera, la mini
//   Vera, la ricerca ⌘K, la guida e il «Da fare» non ci sono. ⌥⌘M entra (senza cliente apre il pannello) ed esce.
// - Esc chiude solo ciò che c'è sopra: schermata neutra, scheda, menu dell'avatar (MonitorEscFinestra).
// Le viste sono in PannelloMostraAlCliente.swift e VistaCliente.swift; i valori in Tema.Apple+MostraAlCliente.swift.

/// I capitoli della vista pulita, nell'ordine della barra in basso.
enum CapitoloCliente: String, CaseIterable, Identifiable {
    case quadro, posizioni, obiettivi, tempo, sala

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .quadro: return "Il quadro"
        case .posizioni: return "Le posizioni"
        case .obiettivi: return "Gli obiettivi"
        case .tempo: return "Nel tempo"
        case .sala: return "La Sala"
        }
    }
}

/// La scheda aperta sopra la vista pulita: una parola spiegata o le ipotesi dei calcoli.
enum SchedaMostra: Equatable {
    case parola(VoceGlossario.Chiave)
    case ipotesi
}

/// I testi di «Mostra al cliente» (dal template, righe 853, 3285-3349).
enum TestiMostra {
    static let titolo = Parole.mostraAlCliente
    /// Dopo «Fine», con più avvisi trattenuti mentre si mostrava: l'ultimo e quanti altri c'erano.
    static func altriAvvisi(_ altri: Int, _ ultimo: String) -> String {
        "\(ultimo) (e \(altri == 1 ? "un altro avviso" : "altri \(altri) avvisi") arrivati mentre mostravi)"
    }
    static let aiutoPillola = "Mostra al cliente: una vista pulita con il suo quadro, per girare lo schermo (⌥⌘M)"
    static func cosaMostri(_ nome: String) -> String { "Cosa mostri a \(nome)?" }
    static let aChi = "A chi vuoi mostrare Prisma?"
    static let aChiTesto = "Scegli la persona: vedrà solo le sue cose."
    static let chiudi = "Chiudi"
    static let quadro = "Il suo quadro"
    static let quadroTesto = "Le quattro aree, le posizioni, gli obiettivi e il futuro. Testo grande, niente strumenti di lavoro."
    static let sala = "La Sala"
    static let salaTesto = "Le esperienze da vivere insieme, senza dock, senza «Da fare», senza altri clienti."
    static let prospetto = "Un prospetto"
    static let prospettoTesto = "Le pagine del report, una alla volta, a tutto schermo."
    static let tavolo = "Sull’iPad sul tavolo"
    static let tavoloTesto = "Tu guidi dal Mac, il cliente guarda e tocca l’iPad."
    static let neutra = "Schermata neutra: copre tutto con l’acqua e il logo"
    static func avvisoUscita(_ iniziali: String) -> String {
        "Per tornare al lavoro: «\(iniziali)» in alto a destra, oppure ⌥⌘M"
    }
    static let chiusa = "Vista del cliente chiusa"
    static let senzaProspetto = "Il report del cliente non è pronto: aprilo da Prospetti."
    static let fine = "Fine: torna al lavoro"
    static let tastoFine = "⌥⌘M"
    static let schermataNeutra = "Schermata neutra"
    static let aiutoUscita = "Fine: torna al lavoro, oppure la schermata neutra"
    static let tocca = "Tocca per riprendere"
    static let comeCalcolate = "Come sono calcolate queste cifre"
    static let ipotesi = "Le ipotesi"
    static let parole = "Le parole"
    static let hoCapito = "Ho capito"

    /// «I calcoli li fa Prisma su questo Mac…», composto dalle costanti di `IpotesiCalcolo`: se un giorno le ipotesi
    /// diventano impostazioni, il testo segue da solo.
    static var testoIpotesi: String {
        "I calcoli li fa Prisma su questo Mac, con i dati delle tue posizioni. Le ipotesi: inflazione al "
            + "\(percento(IpotesiCalcolo.inflazione))% l’anno e i rendimenti dichiarati per ogni posizione "
            + "(\(percento(IpotesiCalcolo.rendimentoPredefinito))% quando non è indicato). Sono stime, non garanzie."
    }

    /// «2» o «2,5»: una cifra decimale con la virgola, nessuna se è intera.
    static func percento(_ v: Double) -> String {
        let decimi = Int((v * 10).rounded())
        return decimi % 10 == 0 ? String(decimi / 10) : "\(decimi / 10),\(abs(decimi % 10))"
    }

    // MARK: I capitoli

    static func titoloQuadro(_ nome: String) -> String { "\(nome), ecco il tuo quadro." }
    static let sottoQuadro = "Quattro aree, una frase per ciascuna."
    static let titoloPosizioni = "Quello che hai oggi."
    static let sottoPosizioni = "Le tue posizioni in essere, una per una."
    static let patrimonioNetto = "Patrimonio netto"
    static func possiedi(_ attivita: String, _ debiti: String) -> String {
        "Quello che possiedi, \(attivita), meno i debiti, \(debiti)."
    }
    static let doveSono = "Dove sono"
    static let nessunaPosizione = "Non ci sono ancora posizioni in essere."
    static let capitaleAssicurato = "capitale assicurato"
    static func titoloObiettivi(_ n: Int) -> String { n == 1 ? "Il tuo obiettivo." : "I tuoi obiettivi." }
    static func sottoObiettivi(_ n: Int) -> String { n == 1 ? "A che punto sei." : "A che punto sei, uno per uno." }
    static let nessunObiettivo = "Non ci sono ancora obiettivi scritti insieme."
    static func messoDaParte(_ da: String, _ traguardo: String) -> String { "\(da) di \(traguardo)" }
    static func alMese(_ mensile: String?, _ quando: String) -> String {
        if let mensile { return "\(mensile) al mese · traguardo a \(quando)" }
        return "Traguardo a \(quando)"
    }
    static let titoloTempo = "Il tuo patrimonio nei prossimi anni."
    static let sottoTempo = "Se continui come oggi, con i versamenti che fai già."
    static let oggi = "Oggi"
    static func traAnni(_ n: Int) -> String { "Tra \(n) anni" }
    static let conProposte = "Con le proposte"
    static let asseOggi = "oggi"
    static func asseAnni(_ n: Int) -> String { "tra \(n) anni" }
}

extension StatoShell {
    // MARK: Il pannello di scelta

    /// La pillola della barra: apre il pannello di scelta (con il cliente le quattro scelte, senza l'elenco dei clienti).
    /// Solo fuori dalla vista pulita, prima di girare lo schermo.
    func apriMostraAlCliente() {
        guard !inVistaCliente, !inModoCliente, !bloccato, presentazione == nil else { return }
        if pannelloNotifiche { pannelloNotifiche = false }
        if pannelloSpazi { pannelloSpazi = false }
        if menuApp { menuApp = false }
        if pannelloCliente { pannelloCliente = false }
        if pannelloAppAperte { pannelloAppAperte = false }
        chiudiRicerca()
        if sistema.guida != nil { sistema.guida = nil }
        sceltaMostra = true
    }

    func chiudiSceltaMostra() {
        if sceltaMostra { sceltaMostra = false }
    }

    /// Un clic sull'elenco «A chi vuoi mostrare Prisma?»: sceglie il cliente per tutta Prisma e il pannello passa alle
    /// quattro scelte.
    func scegliPerMostra(_ id: String) {
        scegliCliente(id, avviso: false)
    }

    // MARK: Entrare, cambiare capitolo, uscire

    /// Entra nella vista pulita sul capitolo dato (o, già dentro, cambia capitolo). Senza cliente scelto apre il pannello.
    /// `zitto`: senza l'avviso «Per tornare al lavoro…» (l'ingresso da un prospetto).
    func mostra(_ capitolo: CapitoloCliente, zitto: Bool = false) {
        if inVistaCliente {
            cambiaCapitolo(capitolo)
            return
        }
        guard !bloccato, presentazione == nil else { return }
        guard clienteAttivo != nil else {
            apriMostraAlCliente()
            return
        }
        let prima = sistema.appAttiva
        entraModoCliente(avviso: false)
        guard inModoCliente else { return }
        appPrimaDellaVista = prima
        sceltaMostra = false
        chiudiRicerca()
        chiudiMiniVera()
        if sistema.guida != nil { sistema.guida = nil }
        if voceDaFareAperta != nil { voceDaFareAperta = nil }
        schedaMostra = nil
        menuUscitaMostra = false
        schermataNeutraMac = false
        // Migliorie d'uso 58: si entra sempre con il cliente davanti a questo schermo
        azzeraLuogo()
        vistaCliente = capitolo
        if capitolo == .sala { apri(.sala) }
        if !zitto && !avvisoVistaVisto {
            avvisoVistaVisto = true
            mostraAvviso(TestiMostra.avvisoUscita(inizialiUtente))
        }
    }

    /// Un capitolo della barra in basso: chiude ciò che è aperto sopra; il capitolo già scelto non fa niente. Dagli altri
    /// capitoli la Sala riparte dalla griglia.
    func cambiaCapitolo(_ capitolo: CapitoloCliente) {
        guard let attuale = vistaCliente, attuale != capitolo else { return }
        schedaMostra = nil
        menuUscitaMostra = false
        if capitolo == .sala {
            if sala.esperienza != nil { sala.esperienza = nil }
            vistaCliente = capitolo
            apri(.sala)
        } else {
            vistaCliente = capitolo
        }
    }

    /// «Un prospetto» del pannello: il report del check-up del cliente, a tutto schermo dentro la vista pulita.
    func mostraProspettoDalPannello() {
        guard let d = documentoProspetto(.checkUp(report: true)) else {
            sceltaMostra = false
            mostraAvviso(TestiMostra.senzaProspetto)
            return
        }
        mostraProspetto(d)
    }

    /// «Mostra al cliente» dei Prospetti (al posto di «Presenta all'incontro»): entra nella vista pulita, senza l'avviso,
    /// e apre la presentazione di sempre. All'uscita dalla presentazione si resta nella vista pulita.
    func mostraProspetto(_ d: DocumentoStampabile, daPagina: Int = 0) {
        if !inVistaCliente { mostra(.quadro, zitto: true) }
        guard inVistaCliente else { return }
        presenta(d, daPagina: daPagina)
    }

    /// «Sull’iPad sul tavolo»: entra nella vista del cliente su «Il quadro» con il cliente sull'iPad (migliorie d'uso 58).
    /// Il pannello è prima della vista: con «Al tavolo» spento porta a Impostazioni › iPhone e iPad (miglioria 39); con
    /// l'iPad non collegato apre il tavolo e manda appena l'iPad arriva.
    func tavoloDalPannello() {
        sceltaMostra = false
        // Migliorie d'uso 39: con «Al tavolo» spento si va a Impostazioni › iPhone e iPad
        guard dati.impostazioni.vera.ponte.tavolo else {
            apriCollegamenti()
            return
        }
        guard clienteAttivo != nil else { return }
        mostra(.quadro, zitto: true)
        guard inVistaCliente else { return }
        mandaAlTavolo(avviso: TestiLuogo.avvisoQuadro)
    }

    /// «Fine: torna al lavoro» (e ⌥⌘M): esce dalla modalità cliente, torna l'app di prima (o la scrivania).
    func fineMostra() {
        guard inVistaCliente else { return }
        // Migliorie d'uso 58: l'iPad torna alla schermata neutra, il tavolo resta in ascolto (decisione 58-c)
        azzeraLuogo()
        let prima = appPrimaDellaVista
        if presentazione != nil { chiudiPresentazione() }
        chiudiVistaClienteSenzaRitorno()
        if modoCliente != nil { modoCliente = nil }
        if let prima {
            apri(prima)
        } else {
            mostraScrivania()
        }
        // Migliorie d'uso 1 (§1.3 punto 12): gli avvisi trattenuti mentre si mostrava escono ora (l'avviso è uno alla
        // volta: si vede l'ultimo arrivato, con il numero degli altri)
        let trattenuti = avvisiTrattenuti
        avvisiTrattenuti = []
        if let ultimo = trattenuti.last {
            let testo = trattenuti.count == 1 ? ultimo.testo : TestiMostra.altriAvvisi(trattenuti.count - 1, ultimo.testo)
            mostraAvviso(testo, daVera: ultimo.daVera, azione: ultimo.azione)
        } else {
            mostraAvviso(TestiMostra.chiusa)
        }
    }

    /// Spegne la vista pulita e ciò che le sta sopra, senza riportare l'app di prima (lo chiama anche lo spegnersi della
    /// modalità cliente: blocco, cliente eliminato).
    func chiudiVistaClienteSenzaRitorno() {
        appPrimaDellaVista = nil
        azzeraLuogo()
        if schermataNeutraMac { schermataNeutraMac = false }
        if schedaMostra != nil { schedaMostra = nil }
        if menuUscitaMostra { menuUscitaMostra = false }
        if vistaCliente != nil { vistaCliente = nil }
    }

    /// ⌥⌘M: dentro la vista esce; con il cliente scelto entra subito su «Il quadro»; senza apre il pannello.
    func alternaMostraAlCliente() {
        if inVistaCliente {
            fineMostra()
        } else if inModoCliente {
            esciModoCliente()
        } else if clienteAttivo != nil {
            mostra(.quadro)
        } else {
            apriMostraAlCliente()
        }
    }

    // MARK: La schermata neutra

    func mostraNeutra() {
        sceltaMostra = false
        menuUscitaMostra = false
        menuLuogo = false
        presaVisioneAperta = false
        schedaMostra = nil
        schermataNeutraMac = true
    }

    func chiudiNeutra() {
        if schermataNeutraMac { schermataNeutraMac = false }
    }

    /// Esc nella vista pulita (o con il pannello o la schermata neutra): chiude ciò che c'è sopra, in quest'ordine.
    /// true se ha chiuso qualcosa o se Esc va tenuto (nella vista pulita non chiude mai la finestra sotto).
    func escMostra() -> Bool {
        if schermataNeutraMac { schermataNeutraMac = false; return true }
        if sceltaMostra { sceltaMostra = false; return true }
        guard inVistaCliente else { return false }
        // Come «Annulla»: con il cliente sull'iPad la richiesta del segno si ritira e l'iPad torna a ciò che si vede
        if presaVisioneAperta { MainActor.assumeIsolated { annullaPresaVisione() }; return true }
        if schedaMostra != nil { schedaMostra = nil; return true }
        if menuLuogo { menuLuogo = false; return true }
        if menuUscitaMostra { menuUscitaMostra = false; return true }
        return true
    }
}

/// La prova di «Mostra al cliente» (in `--prova-vera`, solo sul Mac): il pannello senza cliente, l'ingresso sopra la
/// modalità cliente, nessun'altra app né Vera, ricerca e guida nella vista pulita, Esc che chiude solo ciò che c'è sopra,
/// «Fine» che torna all'app di prima, ⌥⌘M con il cliente e il blocco che chiude tutto.
enum ProvaMostraAlCliente {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        let s = StatoShell(persistente: false)
        s.scegliCliente(nil)
        s.alternaMostraAlCliente()
        controlla(s.sceltaMostra && !s.inVistaCliente && !s.inModoCliente,
                  "Mostra al cliente: senza cliente ⌥⌘M apre «A chi vuoi mostrare Prisma?»")
        guard let primo = s.rubricaOrdinata.first else {
            controlla(false, "Mostra al cliente: la rubrica di prova ha dei clienti")
            return
        }
        s.scegliPerMostra(primo.id)
        controlla(s.clienteAttivoId == primo.id && s.sceltaMostra && !s.inVistaCliente,
                  "Mostra al cliente: scelto il cliente, il pannello passa alle quattro scelte")
        s.chiudiSceltaMostra()
        s.apri(.agenda)
        // Migliorie d'uso 59: il copione «Cosa dire» si vede solo al consulente e si chiude davanti al cliente
        controlla(s.consulenteVede, "Mostra al cliente: fuori dalla vista pulita il consulente vede il copione")
        s.sala.copioneAperto = true
        s.mostra(.quadro)
        controlla(s.inVistaCliente && s.inModoCliente && s.vistaCliente == .quadro && !s.sceltaMostra,
                  "Mostra al cliente: «Il suo quadro» entra nella vista pulita sopra la modalità cliente")
        controlla(!s.consulenteVede && !s.sala.copioneAperto,
                  "Mostra al cliente: nella vista pulita il copione non si vede e si chiude")
        controlla(s.clienti.map(\.id) == [primo.id], "Mostra al cliente: si vede solo il cliente mostrato")
        let posizioniAperte = s.sistema.aperta(.posizioni)
        s.apri(.posizioni)
        controlla(s.sistema.aperta(.posizioni) == posizioniAperte, "Mostra al cliente: nella vista pulita le altre app non si aprono")
        s.apriMiniVera(.scrivi)
        controlla(!s.miniVera.visibile, "Mostra al cliente: la mini Vera non si apre")
        s.cercaOvunque()
        controlla(!s.pannelloRicerca, "Mostra al cliente: la ricerca ⌘K non si apre")
        s.apriGuida()
        controlla(s.guida == nil, "Mostra al cliente: la guida non si apre")
        s.cambiaCapitolo(.sala)
        controlla(s.vistaCliente == .sala && s.sistema.aperta(.sala), "Mostra al cliente: il capitolo «La Sala» apre la Sala")
        s.cambiaCapitolo(.posizioni)
        s.schedaMostra = .ipotesi
        s.menuUscitaMostra = true
        controlla(s.escMostra() && s.schedaMostra == nil && s.menuUscitaMostra, "Mostra al cliente: Esc chiude prima la scheda")
        controlla(s.escMostra() && !s.menuUscitaMostra, "Mostra al cliente: poi il menu dell'avatar")
        controlla(s.escMostra() && s.inVistaCliente, "Mostra al cliente: Esc non esce dalla vista pulita")
        s.mostraNeutra()
        controlla(s.schermataNeutraMac && s.escMostra() && !s.schermataNeutraMac && s.inVistaCliente,
                  "Mostra al cliente: Esc chiude la schermata neutra e si resta nella vista")
        // Migliorie d'uso 58: con il cliente sull'iPad il consulente rivede i suoi pulsanti; «Fine» lo rimette sullo schermo
        controlla(s.luogoCliente == .schermo, "Mostra al cliente: si entra con il cliente davanti a questo schermo")
        s.luogoCliente = .tavolo
        controlla(s.consulenteVede, "Mostra al cliente: con il cliente sull'iPad il consulente vede i suoi pulsanti")
        s.menuLuogo = true
        controlla(s.escMostra() && !s.menuLuogo && s.inVistaCliente, "Mostra al cliente: Esc chiude il menu del luogo")
        s.fineMostra()
        controlla(s.luogoCliente == .schermo && !s.tavoloTocca, "Mostra al cliente: «Fine» rimette il cliente su questo schermo")
        controlla(!s.inVistaCliente && !s.inModoCliente && s.sistema.appAttiva == .agenda,
                  "Mostra al cliente: «Fine: torna al lavoro» esce e riporta l'app di prima")
        s.alternaMostraAlCliente()
        controlla(s.vistaCliente == .quadro && !s.sceltaMostra, "Mostra al cliente: con il cliente ⌥⌘M va dritto a «Il quadro»")
        // §1.3 punto 12: l'avviso con il nome di un altro cliente resta in coda e si vede dopo «Fine»
        let riservato = "Una nota dall'iPhone su un altro cliente"
        s.mostraAvviso(riservato, riservato: true)
        controlla(s.avviso != riservato && s.avvisiTrattenuti.count == 1,
                  "Mostra al cliente: nella vista pulita l'avviso con il nome di un altro cliente resta in coda")
        s.fineMostra()
        controlla(s.avviso == riservato && s.avvisiTrattenuti.isEmpty,
                  "Mostra al cliente: dopo «Fine» l'avviso trattenuto si vede")
        s.alternaMostraAlCliente()
        s.mostraAvviso(riservato, riservato: true)
        s.blocca(animato: false)
        controlla(!s.inVistaCliente && !s.inModoCliente, "Mostra al cliente: il blocco chiude la vista pulita con la modalità cliente")
        controlla(s.avvisiTrattenuti.isEmpty, "Mostra al cliente: il blocco scarta gli avvisi trattenuti")
    }
}
#endif
