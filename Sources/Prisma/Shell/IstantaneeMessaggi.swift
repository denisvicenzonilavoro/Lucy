import SwiftUI

/// I dati di prova delle istantanee di Messaggi (Mac, iPhone e iPad), tutti relativi a oggi così le scene sono uguali
/// in ogni giorno. DATI DI PROVA DICHIARATI, solo dentro le scene (lo stato dell'istantanea non si salva):
/// - Giulia Rossi: l'incontro «Il punto sul progetto casa» concluso ieri alle 17:30, con decisioni, prossimo passo e
///   prossimo incontro di prova (le cifre del template, dimostrative: 550 € al mese);
/// - Marco Bianchi: la polizza di prova «Infortuni famiglia» che scade fra 45 giorni (il primo giorno della soglia);
/// - Sofia Romano: un consenso commerciale di prova firmato 25 mesi fa (vale 24 mesi: scaduto).
/// Il testo dei messaggi è il modello fisso di Prisma compilato con le cifre dei motori; nelle scene «con Vera» si mostra
/// come scritto da Vera (lo stato finale di Vera: Qwen nelle istantanee non c'è).
enum MessaggiDiProva {
    static let incontroGiulia = "incontro-giulia-casa"
    static let infortuniMarco = "pos-marco-infortuni-famiglia"
    /// Il motivo di prova per «Vera non è pronta».
    static let motivoNonPronta = "Ollama non è aperto: avvialo sul Mac e scegli il modello \(MotoreLocale.modelloPredefinito)."

    static func prepara(_ s: StatoShell, cal: Calendar = .current) {
        let oggi = cal.startOfDay(for: Date())
        if let i = s.dati.incontri.firstIndex(where: { $0.id == incontroGiulia }) {
            let ieri = cal.date(byAdding: .day, value: -1, to: oggi) ?? oggi
            s.dati.incontri[i].data = cal.date(bySettingHour: 17, minute: 30, second: 0, of: ieri) ?? ieri
            s.dati.incontri[i].stato = .concluso
            s.dati.incontri[i].decisioni = "Portare il versamento per la casa a 550 € al mese e preparare il confronto per il fondo pensione"
            s.dati.incontri[i].prossimaAttivita = "Mandare i prospetti della casa e della pensione"
            s.dati.incontri[i].prossimoIncontro = cal.date(byAdding: .day, value: 30, to: oggi)
        }
        if let p = s.dati.posizioni.firstIndex(where: { $0.id == infortuniMarco }) {
            s.dati.posizioni[p].stato = .inEssere
            s.dati.posizioni[p].scadenza = cal.date(byAdding: .day, value: RegoleMessaggi.giorniScadenzaPredefiniti, to: oggi)
        }
        if let c = s.dati.clienti.firstIndex(where: { $0.id == "sofia" }) {
            s.dati.clienti[c].consensi.marketing = true
            s.dati.clienti[c].consensi.dataMarketing = cal.date(byAdding: .month, value: -25, to: oggi)
        }
    }

    /// Prepara i dati, chiede l'occasione, il tono, il canale e chi scrive, e apre Messaggi.
    /// Migliorie d'uso 25 (Mac): Messaggi segue il cliente della barra; le scene di prima restano su «Tutti i clienti»,
    /// con `soloCliente` la barra sceglie il cliente della scena. `barra` aggiunge il messaggio di prova del riepilogo di
    /// Giulia aperto in Mail oggi alle 10:30 (la domanda «L'hai spedito?») e, con `.spedito`, segnato alle 10:42.
    static func apri(_ s: StatoShell, tipo: TipoOccasioneMessaggio?, cliente: String, tono: TonoMessaggio = .cordiale,
                     canale: CanaleMessaggio = .mail, vera: Bool = true, datiAperti: Bool = false, soloCliente: Bool = false,
                     barra: StatoBarraMessaggio = .normale) {
        prepara(s)
        if !vera { s.disponibilitaLocale = .nonDisponibile(motivoNonPronta) }
        #if os(macOS)
        s.scegliCliente(soloCliente ? cliente : nil)
        #endif
        if barra != .normale { apertoInMail(s, spedito: barra == .spedito) }
        RichiestaIstantaneaMessaggi.chiedi(s, tipo: tipo, cliente: cliente, tono: tono, canale: canale, vera: vera,
                                           motivoNonPronta: vera ? nil : motivoNonPronta, datiAperti: datiAperti, barra: barra)
        s.apri(.messaggi)
    }

    /// Il riepilogo dell'incontro di Giulia aperto in Mail oggi alle 10:30 (testo del modello fisso, come scritto da Vera)
    /// e, con `spedito`, segnato come spedito alle 10:42. Solo nella scena.
    static func apertoInMail(_ s: StatoShell, spedito: Bool, cal: Calendar = .current) {
        let id = OccasioneMessaggio.id(tipo: .riepilogoIncontro, clienteId: "giulia", riferimento: incontroGiulia)
        guard let o = s.occasioniMessaggi().occasione(id), let c = s.cliente("giulia") else { return }
        let scritto = RichiestaIstantaneaMessaggi.testo(o, cliente: c, stato: s, tono: .cordiale, canale: .mail, vera: true, motivo: nil)
        guard let m = s.salvaMessaggio(o, tono: .cordiale, canale: .mail, scritto: scritto, stato: .apertoInMail),
              let i = s.dati.messaggi.firstIndex(where: { $0.id == m.id }) else { return }
        let oggi = cal.startOfDay(for: Date())
        s.dati.messaggi[i].apertoIl = cal.date(bySettingHour: 10, minute: 30, second: 0, of: oggi)
        if spedito { s.dati.messaggi[i].speditoIl = cal.date(bySettingHour: 10, minute: 42, second: 0, of: oggi) }
    }

    /// Un cliente di prova senza nessuna occasione, scelto nella barra (migliorie d'uso 25, Mac): il vuoto per cliente.
    static func vuotoCliente(_ s: StatoShell) {
        prepara(s)
        let nuovo = Cliente(id: "elena-prova", nome: "Elena Fabbri", iniziali: "EF", tinta: .blu, tema: "", email: "",
                            telefono: "", preferito: false, nota: "", creatoIl: Calendar.current.startOfDay(for: Date()))
        s.dati.clienti.append(nuovo)
        #if os(macOS)
        s.scegliCliente(nuovo.id)
        #endif
        s.apri(.messaggi)
    }

    /// Nessuna occasione: Prisma senza clienti (lo stato vero appena installato).
    static func vuoto(_ s: StatoShell) {
        s.dati.clienti.removeAll()
        s.apri(.messaggi)
    }
}

#if os(macOS)
/// Le istantanee di Messaggi (Design/template-novita-specifica.md §5.7), 490-496 in chiaro e in scuro, tutte nello
/// stato finale (`\.modoIstantanea`): testo completo, nessun puntino, pillole al loro posto. iPhone (497) e iPad (498)
/// sono in iOS/IstantaneeMobile.swift. Dati di prova in `MessaggiDiProva`.
/// - 490: il riepilogo dell'incontro di Giulia, Cordiale, Mail, scritto da Vera;
/// - 491: lo stesso con Messaggi e Breve: la nuvoletta blu e «Apri in Messaggi»;
/// - 492: la scadenza di Marco, Formale, Mail con l'oggetto;
/// - 493: il consenso commerciale di Sofia, scelto in «Questa settimana»;
/// - 494: Vera non è pronta: il testo di Prisma con la riga che lo spiega;
/// - 495: Marco senza indirizzo email: la testata lo dice e il pulsante porta al dossier;
/// - 496: nessuna occasione.
/// Migliorie d'uso 26: nelle scene del Mac la fila ha «Tono», «Invia con» e «Vera ha usato N dati del dossier ›», e
/// sotto il testo non ci sono più le cifre né la riga dell'autore; 1044 apre la scheda «Da dove vengono le cifre».
/// Migliorie d'uso 25: gli occhielli hanno il numero delle voci da mandare (490-496 restano su «Tutti i clienti»);
/// 1040 Giulia scelta nella barra, con il riepilogo spedito in «Mandati oggi»; 1041 la barra «Aperto in Mail. L’hai
/// spedito?»; 1042 la pillola verde «Spedito oggi alle 10:42 con Mail» e «Non è partito»; 1043 un cliente senza
/// messaggi da preparare.
extension Istantanee {
    nonisolated static var sceneMessaggi: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("490-messaggi-apple", { s in MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia") }),
            ("490-messaggi-apple-scuro", { s in MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia") }),
            ("491-messaggi-sms", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", tono: .breve, canale: .messaggi)
            }),
            ("491-messaggi-sms-scuro", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", tono: .breve, canale: .messaggi)
            }),
            ("492-messaggi-formale", { s in MessaggiDiProva.apri(s, tipo: .scadenzaPosizione, cliente: "marco", tono: .formale) }),
            ("492-messaggi-formale-scuro", { s in MessaggiDiProva.apri(s, tipo: .scadenzaPosizione, cliente: "marco", tono: .formale) }),
            ("493-messaggi-consenso", { s in MessaggiDiProva.apri(s, tipo: .consenso, cliente: "sofia") }),
            ("493-messaggi-consenso-scuro", { s in MessaggiDiProva.apri(s, tipo: .consenso, cliente: "sofia") }),
            ("494-messaggi-vera-non-pronta", { s in
                MessaggiDiProva.apri(s, tipo: .scadenzaPosizione, cliente: "marco", vera: false)
            }),
            ("494-messaggi-vera-non-pronta-scuro", { s in
                MessaggiDiProva.apri(s, tipo: .scadenzaPosizione, cliente: "marco", vera: false)
            }),
            ("495-messaggi-recapito-mancante", { s in senzaEmailMarco(s) }),
            ("495-messaggi-recapito-mancante-scuro", { s in senzaEmailMarco(s) }),
            ("496-messaggi-vuoto", { s in MessaggiDiProva.vuoto(s) }),
            ("496-messaggi-vuoto-scuro", { s in MessaggiDiProva.vuoto(s) }),
            ("1044-uso-messaggi-dati-usati", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", datiAperti: true)
            }),
            ("1044-uso-messaggi-dati-usati-scuro", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", datiAperti: true)
            }),
            ("1040-uso-messaggi-cliente", { s in
                MessaggiDiProva.apri(s, tipo: nil, cliente: "giulia", soloCliente: true, barra: .spedito)
            }),
            ("1040-uso-messaggi-cliente-scuro", { s in
                MessaggiDiProva.apri(s, tipo: nil, cliente: "giulia", soloCliente: true, barra: .spedito)
            }),
            ("1041-uso-messaggi-hai-spedito", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", soloCliente: true, barra: .daConfermare)
            }),
            ("1041-uso-messaggi-hai-spedito-scuro", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", soloCliente: true, barra: .daConfermare)
            }),
            ("1042-uso-messaggi-spedito", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", soloCliente: true, barra: .spedito)
            }),
            ("1042-uso-messaggi-spedito-scuro", { s in
                MessaggiDiProva.apri(s, tipo: .riepilogoIncontro, cliente: "giulia", soloCliente: true, barra: .spedito)
            }),
            ("1043-uso-messaggi-vuoto-cliente", { s in MessaggiDiProva.vuotoCliente(s) }),
        ]
    }

    /// Marco senza indirizzo email nel dossier (solo nella scena).
    nonisolated static func senzaEmailMarco(_ s: StatoShell) {
        if let i = s.dati.clienti.firstIndex(where: { $0.id == "marco" }) { s.dati.clienti[i].email = "" }
        MessaggiDiProva.apri(s, tipo: .scadenzaPosizione, cliente: "marco")
    }
}
#endif
