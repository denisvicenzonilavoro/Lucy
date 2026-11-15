import Foundation

/// Il momento di un impegno rispetto ad adesso (Migliorie d'uso 18, lo usano anche 19 e 21): ancora da venire (o un
/// blocco senza esito da chiedere), passato e senza esito («da chiudere»), oppure chiuso. La regola di «da chiudere» è la
/// stessa delle notifiche (`fine <= adesso` e ancora pianificato), senza i blocchi «Non disponibile» e senza gli impegni
/// che non hanno un cliente: di quelli non c'è niente da chiedere, sono solo attenuati quando sono passati.
enum MomentoImpegno: Equatable {
    case prima, daChiudere, chiuso

    static func di(_ a: Appuntamento, adesso: Date) -> MomentoImpegno {
        if a.stato == .concluso { return .chiuso }
        if a.stato == .pianificato && a.fine <= adesso && a.tipo != .nonDisponibile && !a.clienteId.isEmpty {
            return .daChiudere
        }
        return .prima
    }

    /// Finito (qualunque tipo, anche un blocco «Non disponibile»).
    static func passato(_ a: Appuntamento, adesso: Date) -> Bool { a.fine <= adesso }

    /// Attenuato nella giornata e nella settimana: passato oppure chiuso (`.pas` del template).
    static func attenuato(_ a: Appuntamento, adesso: Date) -> Bool {
        a.stato == .concluso || passato(a, adesso: adesso)
    }

    /// L'esito breve di un impegno chiuso, in minuscolo, senza la spunta (la mette la vista): l'esito della proposta
    /// collegata se è stato chiesto in questo impegno («accettata», «rimandata», «rifiutata», «ci deve pensare»),
    /// altrimenti «concluso». Nil se l'impegno non è chiuso. La proposta la passa chi chiama (letta una volta sola).
    static func esitoBreve(_ a: Appuntamento, proposta: Posizione?) -> String? {
        guard a.stato == .concluso else { return nil }
        guard let p = proposta, p.id == a.posizioneId, p.seguito?.appuntamentoEsitoId == a.id else { return concluso }
        switch p.esito {
        case .accettata?:
            return TestiSeguito.sceltaAccettata.replacingOccurrences(of: "✓", with: "")
                .trimmingCharacters(in: .whitespaces).lowercased()
        case .rimandata?: return TestiSeguito.sceltaRimandata.lowercased()
        case .rifiutata?: return TestiSeguito.sceltaRifiutata.lowercased()
        case .presentata?: return TestiSeguito.sceltaInAttesa.lowercased()
        case .bozza?, nil: return concluso
        }
    }

    static let concluso = "concluso"

    /// Gli istanti in cui un impegno di questi finisce dopo `adesso` (un secondo dopo la fine, ordinati): le righe di
    /// oggi si rifanno solo lì (`TimelineView(.explicit(...))`), così «da chiudere» compare quando l'impegno finisce,
    /// senza un temporizzatore e senza rifare la vista a ogni minuto.
    static func fini(_ eventi: [Appuntamento], dopo adesso: Date) -> [Date] {
        eventi.map(\.fine).filter { $0 > adesso }.sorted().map { $0.addingTimeInterval(1) }
    }

    /// «libero», «1 impegno», «N impegni»: la nota sotto il giorno nella testata della settimana.
    static func notaGiorno(_ impegni: Int) -> String {
        if impegni <= 0 { return TestiAgendaApple.libero }
        return impegni == 1 ? TestiAgendaApple.unImpegno : TestiAgendaApple.impegni(impegni)
    }
}
