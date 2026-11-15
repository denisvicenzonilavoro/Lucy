import SwiftUI

// Migliorie d'uso 2 «Un solo posto per scegliere il cliente» (Design/uso/gruppo-01.md §2): sul Mac il cliente si sceglie
// nella barra in alto e vale per tutta Prisma. `clienteAttivoId == ""` vuol dire «Tutti i clienti»: Posizioni mostra il
// portafoglio, Vera parla del portafoglio, Analisi 360, Sala e Prospetti chiedono di scegliere una persona.

/// I testi della scelta del cliente (pillola della barra, pannello, vuoti delle app che lavorano su una persona).
enum TestiSceltaCliente {
    static let tuttiIClienti = Parole.tuttiIClienti
    static let aiutoPillola = "Di chi parliamo?"
    static let titoloPannello = "Di chi parliamo?"
    static let cerca = "Cerca per nome"
    static let tuttiSottotitolo = "Le viste d’insieme: portafoglio, agenda, rubrica"
    static let recenti = "Recenti"
    static func tutti(_ n: Int) -> String { "Tutti · \(n)" }
    static let nessuno = "Nessun cliente con questo nome."
    static func avvisoCliente(_ nome: String) -> String { "Tutta Prisma ora parla di \(nome)" }
    static let avvisoTutti = "Tutti i clienti: tornano le viste d’insieme"
    // Il vuoto delle app che lavorano su una persona
    static let scegli = "Scegli il cliente"
    static let oppure = "oppure"
    static let nuovoCliente = "Nuovo cliente"
    static let analisiTitolo = "Analisi 360 lavora su una persona alla volta."
    static let analisiTesto = "Scegli il cliente nella barra in alto: tutta Prisma lo segue, senza doverlo riscegliere in ogni app."
    static let salaTitolo = "La Sala si apre per una persona."
    static let salaTesto = "Scegli il cliente in alto: le esperienze parlano di lui."
    static let prospettiTitolo = "I prospetti si preparano per una persona."
    static let prospettiTesto = "Scegli il cliente in alto: trovi i suoi report per l’incontro."
    static let tuaRubrica = "La tua rubrica"
    static let tuaRubricaTesto = "Scegli una persona a sinistra, oppure nella barra in alto: vale per tutta Prisma."
    // Le app con un cliente scelto
    static func solo(_ nome: String) -> String { "Solo \(nome)" }
    static let aiutoSolo = "Mostra gli impegni di tutti"
    static let tuttoIlPortafoglio = "Tutto il portafoglio"
    static let aiutoTuttoIlPortafoglio = "Torna a «Tutti i clienti»: il portafoglio di tutte le persone che segui"
}

#if os(macOS)
extension StatoShell {
    /// «Tutti i clienti» della barra: nessun cliente scelto (in modalità cliente mai: c'è il cliente mostrato).
    var tuttiIClienti: Bool { clienteAttivoId.isEmpty }

    /// Sceglie il cliente per tutta Prisma (nil = «Tutti i clienti»). Scegliere quello già scelto non fa niente. Clienti
    /// torna alla Rubrica (Potenziali e Passaparola mostrano altre persone), l'Agenda e le Attività seguono la scelta.
    /// `avviso`: solo per le scelte fatte apposta (pannello, pillole del vuoto, «Solo <Nome> ✕», «‹ Tutto il
    /// portafoglio»); le strade che portano a un cliente lo scelgono in silenzio, ma entra lo stesso nei recenti.
    func scegliCliente(_ id: String?, avviso: Bool = false) {
        guard modoCliente == nil else { return }
        let nuovo = id ?? ""
        guard nuovo != clienteAttivoId else { return }
        if !nuovo.isEmpty, cliente(nuovo) == nil { return }
        clienteAttivoId = nuovo
        let filtro: String? = nuovo.isEmpty ? nil : nuovo
        if filtroClienteAgenda != filtro { filtroClienteAgenda = filtro }
        if filtroClienteAttivita != filtro { filtroClienteAttivita = filtro }
        if vistaClienti != .rubrica { vistaClienti = .rubrica }
        // Migliorie d'uso 21: Incontri riparte dal primo incontro del cliente nuovo (o di tutti)
        if incontroAperto != nil { incontroAperto = nil }
        if appuntamentoIncontro != nil { appuntamentoIncontro = nil }
        // Migliorie d'uso 35: la Biblioteca chiude la risposta e il documento aperto del cliente di prima
        chiudiBibliotecaPerCliente()
        guard avviso else { return }
        if let c = cliente(nuovo) {
            mostraAvviso(TestiSceltaCliente.avvisoCliente(c.nome))
        } else {
            mostraAvviso(TestiSceltaCliente.avvisoTutti)
        }
    }

    /// Le scritture di `portafoglio` e `veraPortafoglio` sul Mac: true sceglie «Tutti i clienti»; false, se si era su
    /// «Tutti», torna al cliente scelto per ultimo (o al primo della rubrica, perché chi lo scrive vuole un cliente).
    func impostaTuttiIClienti(_ tutti: Bool) {
        guard modoCliente == nil else { return }
        if tutti {
            scegliCliente(nil)
        } else if tuttiIClienti, let id = clienteDiPrima {
            clienteAttivoId = id
        }
    }

    /// Il cliente a cui tornare lasciando «Tutti i clienti»: il più recente che c'è ancora, altrimenti il primo.
    var clienteDiPrima: String? {
        clientiRecenti.first { cliente($0) != nil } ?? clientiAttivi.first?.id
    }

    /// Mette il cliente in cima ai recenti (al più tre); «Tutti i clienti» non ci entra.
    func ricordaRecente(_ id: String) {
        guard !id.isEmpty, clientiRecenti.first != id else { return }
        var elenco = clientiRecenti.filter { $0 != id }
        elenco.insert(id, at: 0)
        clientiRecenti = Array(elenco.prefix(3))
    }

    /// La rubrica in ordine alfabetico (pannello della barra e pillole del vuoto), una volta per dati e giorno.
    var rubricaOrdinata: [Cliente] {
        ricavato("rubrica-ordinata") {
            clienti.sorted { $0.nome.localizedCaseInsensitiveCompare($1.nome) == .orderedAscending }
        }
    }

    /// I clienti recenti che ci sono ancora, nell'ordine in cui sono stati scelti.
    var recentiVisibili: [Cliente] { clientiRecenti.compactMap { cliente($0) } }

    /// Le pillole del vuoto: i primi cinque, prima i recenti e poi in ordine alfabetico.
    var primiPerIlVuoto: [Cliente] {
        var elenco = recentiVisibili
        for c in rubricaOrdinata where elenco.count < 5 && !elenco.contains(where: { $0.id == c.id }) {
            elenco.append(c)
        }
        return Array(elenco.prefix(5))
    }

    /// Apre il pannello «Di chi parliamo?» (non in modalità cliente: elenca tutti i clienti).
    func apriSceltaCliente() {
        guard !inModoCliente else { return }
        if pannelloNotifiche { pannelloNotifiche = false }
        if pannelloSpazi { pannelloSpazi = false }
        if menuApp { menuApp = false }
        pannelloCliente = true
    }
}
#endif
