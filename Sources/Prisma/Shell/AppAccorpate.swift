import Foundation

/// Le app accorpate (`AppPrisma.ospite`): sul Mac non hanno più una finestra propria. `apri(_:)` le porta
/// nell'app che le ospita, sulla scheda giusta: Obiettivi e Documenti in Clienti, Simulazioni e Confronti
/// negli strumenti di Analisi 360, Attività nell'Agenda (vista mese), Prodotti nella Biblioteca (migliorie d'uso 63), Note nella sezione Note del
/// dossier (migliorie d'uso 65).
/// iPhone e iPad restano come prima.
extension StatoShell {
    /// Prepara l'ospite a mostrare l'app accorpata (non apre nulla: lo fa `apri`).
    func preparaOspite(per app: AppPrisma) {
        switch app {
        case .obiettivi: if schedaCliente != .obiettivi { schedaCliente = .obiettivi }
        case .documenti:
            if schedaCliente != .documenti { schedaCliente = .documenti }
            #if os(macOS)
            // Migliorie d'uso 62: il documento scelto da fuori si apre nel lettore grande, solo se è del cliente attivo
            // (`documentoSelezionato` non si azzera cambiando cliente: mai il lettore su un documento di un altro)
            if let id = documentoSelezionato, documento(id)?.clienteId == clienteAttivoId { vistaDocumenti.lettore = id }
            #endif
        case .simulazioni: scegliStrumentoAnalisi(StatoShell.strumento(per: schedaSimulazioni))
        case .confronti: scegliStrumentoAnalisi(.confronto)
        case .attivita: selezionaAttivitaInAgenda(attivitaSelezionata)
        #if os(macOS)
        // Migliorie d'uso 63: il catalogo dei prodotti è la sezione «Prodotti» della Biblioteca
        case .prodotti: if sezioneBiblioteca != .prodotti { sezioneBiblioteca = .prodotti }
        // Migliorie d'uso 65: le note sono la sezione Note del dossier, sul cliente della nota scelta
        case .note:
            if let n = nota(notaSelezionata), cliente(n.clienteId) != nil, clienteAttivoId != n.clienteId {
                clienteAttivoId = n.clienteId
            }
            if schedaCliente != .note { schedaCliente = .note }
        #endif
        default: break
        }
    }

    /// L'app accorpata che l'ospite sta mostrando (nil se l'app non ospita nulla o mostra il suo contenuto).
    /// Serve dove prima si chiedeva `appAttiva == .documenti` e simili.
    func accorpataMostrata(in ospite: AppPrisma) -> AppPrisma? {
        switch ospite {
        case .clienti:
            switch schedaCliente {
            case .obiettivi: return .obiettivi
            case .documenti: return .documenti
            #if os(macOS)
            case .note: return .note
            #endif
            default: return nil
            }
        case .analisi360:
            switch strumentoAnalisi {
            case .confronto: return .confronti
            case .simulatore, .scenari, .tfr: return .simulazioni
            case .simulaConfronta:
                #if os(macOS)
                // Migliorie d'uso 64: «Due a confronto» è l'ex Confronti, «Una strada» l'ex Simulazioni
                return modoSimula == .due ? .confronti : .simulazioni
                #else
                return .simulazioni
                #endif
            case nil: return nil
            }
        #if os(macOS)
        case .biblioteca:
            return sezioneBiblioteca == .prodotti ? .prodotti : nil
        #endif
        default:
            return nil
        }
    }

    /// Vero se davanti c'è l'app (con icona propria o accorpata nel suo ospite).
    func inPrimoPiano(_ app: AppPrisma) -> Bool {
        #if os(macOS)
        if let ospite = app.ospite {
            // L'Attività non ha una scheda: vale l'Agenda davanti con l'attività scelta
            if app == .attivita { return appAttiva == .agenda }
            return appAttiva == ospite && accorpataMostrata(in: ospite) == app
        }
        #endif
        return appAttiva == app
    }

    /// Mostra le attività nell'Agenda (vista mese) e, se c'è, l'attività scelta nel giorno della sua scadenza.
    func mostraAttivitaInAgenda(_ id: String? = nil) {
        selezionaAttivitaInAgenda(id ?? attivitaSelezionata)
        apri(.agenda)
    }

    /// Lo stato dell'Agenda per un'attività (senza aprire nulla): vista mese, giorno della scadenza, selezione.
    func selezionaAttivitaInAgenda(_ id: String?) {
        if vistaAgenda != .mese { vistaAgenda = .mese }
        guard let id, let a = attivita.first(where: { $0.id == id }) else { return }
        if attivitaSelezionata != id { attivitaSelezionata = id }
        giornoAgenda = Calendar.current.startOfDay(for: a.scadenza)
        // Il dettaglio dell'agenda resta libero per l'attività
        appuntamentoSelezionato = nil
        occasioneSelezionata = nil
        if filtroClienteAgenda != nil && filtroClienteAgenda != a.clienteId { filtroClienteAgenda = nil }
    }
}
