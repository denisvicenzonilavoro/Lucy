#if os(macOS)
import Foundation
import CoreGraphics

/// Le istantanee dell'Agenda nel tema Apple (§4.4): la settimana a sette colonne (Migliorie d'uso 18: barra laterale
/// con il mese a puntini, «Questa settimana» e «Da non dimenticare», la testata dei giorni, gli impegni al loro posto
/// con «da chiudere» e «✓ concluso», la riga dell'ora ferma alle 10:24), in chiaro e in scuro; la vista Giorno con la
/// colonna del giorno; la traccia dell'impegno di Giulia già aperta; la settimana di un cliente scelto e la finestra
/// stretta senza barra laterale. Le cifre vengono dai motori di Prisma sui dati di prova (date relative a oggi).
/// Il menu del pulsante «Occasioni» è un popover (una finestra a sé): le istantanee non lo vedono, serve uno screenshot.
extension Istantanee {
    nonisolated static var sceneAgendaApple: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("450-agenda-apple", { s in preparaAgendaApple(s, vista: .settimana) }),
            ("450-agenda-apple-scuro", { s in preparaAgendaApple(s, vista: .settimana) }),
            ("451-agenda-giornata", { s in preparaAgendaApple(s, vista: .giorno) }),
            ("452-agenda-traccia-impegno", { s in
                RichiestaIstantaneaAgenda.chiedi(s, impegno: "event-giulia")
                preparaAgendaApple(s, vista: .settimana)
            }),
            ("453-agenda-settimana-cliente", { s in preparaAgendaApple(s, vista: .settimana, cliente: "giulia") }),
            ("455-agenda-settimana-stretta", { s in
                preparaAgendaApple(s, vista: .settimana)
                s.alternaIngrandimento(.agenda)
                s.ridimensiona(.agenda, dimensione: CGSize(width: 860, height: 640))
            }),
        ]
    }

    /// L'Agenda aperta su oggi, con una cosa rimasta indietro (Marco) nella fascia della giornata. Alle 10:24 l'incontro
    /// di Giulia (9:30-10:15) è passato e senza esito («da chiudere»); in più una telefonata con Sofia alle 8:15 già
    /// chiusa («✓ concluso»). `cliente`: la settimana di un cliente scelto nella barra.
    nonisolated static func preparaAgendaApple(_ s: StatoShell, vista: VistaAgenda, cliente: String? = nil) {
        attivitaRimastaIndietro(s)
        let cal = Calendar.current
        let oggi = cal.startOfDay(for: Date())
        if !s.dati.appuntamenti.contains(where: { $0.id == "event-istantanea-chiuso" }),
           let inizio = cal.date(bySettingHour: 8, minute: 15, second: 0, of: oggi) {
            s.dati.appuntamenti.append(Appuntamento(id: "event-istantanea-chiuso", clienteId: "sofia",
                                                    titolo: "Aggiornamento sulle priorità", inizio: inizio,
                                                    durataMinuti: 30, luogo: "Telefonata", note: "",
                                                    stato: .concluso, tipo: .telefonata))
        }
        s.giornoAgenda = oggi
        s.vistaAgenda = vista
        s.filtroClienteAgenda = nil
        s.appuntamentoSelezionato = nil
        s.occasioneSelezionata = nil
        s.attivitaSelezionata = nil
        if let cliente {
            // Il cliente della barra (se era già quello, `scegliCliente` non tocca il filtro: lo si mette qui)
            s.scegliCliente(cliente)
            s.filtroClienteAgenda = cliente
        }
        s.apri(.agenda)
    }
}
#endif
