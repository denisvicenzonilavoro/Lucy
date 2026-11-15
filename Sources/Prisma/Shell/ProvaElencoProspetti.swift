import Foundation

/// Prova dell'elenco dei documenti (migliorie d'uso 23), dentro `Prisma --prova-prospetti`: ogni tipo ha la sua riga
/// «a cosa serve», le fonti e almeno una versione, e sta in esattamente un gruppo; sul Mac il documento «per l'incontro
/// di oggi» è il primo dell'elenco tra i report adatti, solo per un appuntamento di oggi ancora da concludere.
/// La chiama `ProvaProspetti.esegui` con la sua funzione di verifica.
@MainActor
enum ProvaElencoProspetti {
    static func esegui(_ verifica: (String, Bool, String) -> Void) {
        let tutti = TipoProspetto.allCases
        let senzaRiga = tutti.filter { $0.inBreve.trimmingCharacters(in: .whitespaces).isEmpty }
        verifica("Elenco: ogni documento ha la riga «a cosa serve»", senzaRiga.isEmpty, senzaRiga.map(\.rawValue).joined(separator: ", "))
        let senzaFonti = tutti.filter { $0.fonti.trimmingCharacters(in: .whitespaces).isEmpty }
        verifica("Elenco: ogni documento dice da dove vengono le cifre", senzaFonti.isEmpty, senzaFonti.map(\.rawValue).joined(separator: ", "))
        verifica("Elenco: ogni documento ha almeno una versione", tutti.allSatisfy { !$0.versioni.isEmpty }, "")
        // Ogni tipo (il fascicolo ha la sua card) sta in esattamente un gruppo
        let nei = ElencoProspetti.gruppi.flatMap { $0.tipi }
        let fuori = tutti.filter { t in t != .fascicolo && nei.filter { $0 == t }.count != 1 }
        verifica("Elenco: ogni documento sta in esattamente un gruppo", fuori.isEmpty && !nei.contains(.fascicolo),
                 fuori.map(\.rawValue).joined(separator: ", "))
        verifica("Elenco: l'ordine delle voci le ha tutte, una volta", Set(ElencoProspetti.ordine) == Set(tutti)
                 && ElencoProspetti.ordine.count == tutti.count, "")
        verifica("Elenco: il portafoglio è nel gruppo «Per te»",
                 (ElencoProspetti.gruppi.first { $0.titolo == ElencoProspetti.gruppoPerTe }?.tipi ?? []) == [.portafoglio], "")

        #if os(macOS)
        let cal = Calendar.current
        let adesso = cal.date(bySettingHour: 10, minute: 24, second: 0, of: Date()) ?? Date()
        func appuntamento(_ tipo: TipoAppuntamento, giorni: Int = 0, stato: Appuntamento.Stato = .pianificato) -> Appuntamento {
            let giorno = cal.date(byAdding: .day, value: giorni, to: adesso) ?? adesso
            let inizio = cal.date(bySettingHour: 9, minute: 30, second: 0, of: giorno) ?? giorno
            return Appuntamento(id: "prova-elenco", clienteId: "giulia", titolo: "Prova", inizio: inizio,
                                durataMinuti: 45, luogo: "In studio", note: "", stato: stato, tipo: tipo)
        }
        func segnato(_ a: Appuntamento) -> TipoProspetto? {
            StatoShell.prospettoPerIncontro(appuntamenti: [a], posizioni: [], adesso: adesso)
        }
        verifica("Incontro di oggi: per un primo incontro il check-up", segnato(appuntamento(.primoIncontro)) == .checkUp, "")
        verifica("Incontro di oggi: per una revisione il primo dell'elenco tra i report adatti (il resoconto)",
                 segnato(appuntamento(.revisione)) == .resoconto, "\(segnato(appuntamento(.revisione))?.rawValue ?? "nessuno")")
        verifica("Incontro di oggi: niente per un appuntamento di domani", segnato(appuntamento(.revisione, giorni: 1)) == nil, "")
        verifica("Incontro di oggi: niente per un appuntamento concluso", segnato(appuntamento(.revisione, stato: .concluso)) == nil, "")
        verifica("Incontro di oggi: niente per un blocco «Non disponibile»", segnato(appuntamento(.nonDisponibile)) == nil, "")
        #endif
    }
}
