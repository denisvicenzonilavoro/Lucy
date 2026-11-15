import SwiftUI

/// Modalità cliente: quando giri lo schermo verso il cliente, Prisma mostra solo il suo dossier.
/// Gli altri clienti spariscono da rubrica, agenda, attività, posizioni, scrivania e portafoglio;
/// Note, Ricerca e Impostazioni (che parlano di tutti) non si aprono; notifiche nascoste.
extension StatoShell {
    /// Le app che in modalità cliente non si aprono: leggono i dati di tutti i clienti. Con «Luce» anche Territorio
    /// (tutti i clienti sulla mappa) e Pratiche (bisogni e pratiche di più clienti); Sala e Biblioteca restano
    /// consentite (decisione 50). Dal giro 12 anche Messaggi: le campagne mostrano tutti i clienti (decisione 50).
    static let appRiservate: Set<AppPrisma> = [.note, .ricerca, .impostazioni, .territorio, .pratiche, .messaggi]

    func appConsentita(_ app: AppPrisma) -> Bool {
        modoCliente == nil || !Self.appRiservate.contains(app)
    }

    var inModoCliente: Bool { modoCliente != nil }

    /// Migliorie d'uso 1: la vista pulita di «Mostra al cliente» è aperta (solo sul Mac; su iPhone e iPad mai).
    var inVistaCliente: Bool {
        #if os(macOS)
        return vistaCliente != nil
        #else
        return false
        #endif
    }

    /// Migliorie d'uso 1: la vista pulita è sul capitolo «La Sala» (la finestra della Sala resta visibile).
    var salaNellaVistaCliente: Bool {
        #if os(macOS)
        return vistaCliente == .sala
        #else
        return false
        #endif
    }

    /// `avviso`: falso quando la accende la presentazione, per non coprire la pagina davanti al cliente.
    func entraModoCliente(avviso: Bool = true) {
        #if os(macOS)
        // Il menu delle app (migliorie d'uso 67) si chiude comunque, anche se manca il cliente da mostrare
        if menuApp { menuApp = false }
        // Con «Tutti i clienti» si mostra il cliente scelto per ultimo (migliorie d'uso 2)
        if tuttiIClienti, modoCliente == nil, let id = clientiRecenti.first(where: { cliente($0) != nil }) {
            clienteAttivoId = id
        }
        #endif
        guard let c = dati.clienti.first(where: { $0.id == clienteAttivoId }) else {
            mostraAvviso("Scegli prima il cliente in Clienti: la modalità cliente mostra solo il suo dossier.")
            return
        }
        modoCliente = c.id
        Self.appRiservate.forEach(chiudi)
        // Il prospetto del portafoglio parla di tutti i clienti
        if case .portafoglio? = prospetto { prospetto = nil }
        pannelloNotifiche = false
        pannelloCliente = false
        if sistema.pannelloNovita { sistema.pannelloNovita = false }
        pannelloSpazi = false
        menuApp = false
        pannelloAppAperte = false
        portafoglio = false
        veraPortafoglio = false
        // La scena «Per i tuoi clienti» elenca tutto il portafoglio
        scenaMercatoClientiVera = nil
        filtroClienteAgenda = nil
        filtroClienteAttivita = nil
        // Studio › Spese non si vede in modalità cliente (§6.3.1 punto 1.7): niente foglio aperto, e il segmentato torna al
        // Cruscotto (che mostra «Studio resta tuo»)
        studioSpese.foglio = nil
        // La nota dall'iPhone porta il testo dettato e il nome di un altro cliente: la scheda si chiude («Luce» giro 13)
        notaVocale.mostrata = nil
        if schedaStudio == .spese { schedaStudio = .cruscotto }
        // Potenziali e Passaparola mostrano persone che non sono il cliente («Luce» giro 12): Clienti torna alla Rubrica
        if vistaClienti != .rubrica { vistaClienti = .rubrica }
        potenziali.modulo = nil
        potenziali.evidenziato = nil
        if avviso { mostraAvviso("Modalità cliente: si vede solo il dossier di \(c.nome).") }
    }

    func esciModoCliente() {
        guard modoCliente != nil else { return }
        modoCliente = nil
        mostraAvviso("Modalità cliente terminata.")
    }

    func alternaModoCliente() {
        if modoCliente == nil { entraModoCliente() } else { esciModoCliente() }
    }
}

/// Il contrassegno nella barra superiore: chi stai mostrando e come uscire. Una capsula piena
/// dell'accento (come il pulsante principale del tema), alta quanto i pulsanti della barra.
struct ContrassegnoModoCliente: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        let m = Tema.Misura.PannelliShell.self
        Button { stato.esciModoCliente() } label: {
            HStack(spacing: m.modoClienteSpazio) {
                Text("MODALITÀ CLIENTE")
                    .font(Tema.Testo.PannelliShell.occhielloModoCliente)
                    .tracking(Tema.Testo.PannelliShell.spaziaturaModoCliente)
                Text(stato.clienteAttivo?.nome ?? "")
                    .font(Tema.Testo.PannelliShell.nomeModoCliente)
                Text("Esci  ⌥⌘M")
                    .font(Tema.Testo.PannelliShell.tastoModoCliente)
                    .opacity(0.8)
            }
            .lineLimit(1)
            .foregroundColor(Tema.Colore.Componenti.testoSuColore)
            .padding(.horizontal, m.modoClienteMargine)
            .frame(height: Tema.Misura.pulsanteBarra)
            .background {
                FormaVetro.capsula
                    .fill(Colori.Barra.modoCliente)
                    .overlay {
                        FiloInterno(forma: .capsula)
                            .fill(Tema.Colore.Componenti.luceSuColore, style: FillStyle(eoFill: true))
                            .clipShape(FormaVetro.capsula)
                    }
            }
        }
        .buttonStyle(StileSemplice())
        .help("Esci dalla modalità cliente e torna a vedere tutti i clienti")
    }
}
