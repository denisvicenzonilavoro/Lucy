#if os(macOS)
import Foundation

/// Migliorie d'uso 65 «Le note stanno con il cliente»: la nota del taccuino in evidenza che Panoramica mostra (Giulia),
/// una nota diventata un «Da fare» (Marco) e la sezione Note senza note (Laura). In chiaro e in scuro.
extension Istantanee {
    nonisolated static var sceneNoteDossier: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("1405-uso-clienti-note-in-evidenza", { s in preparaNoteInEvidenza(s) }),
            ("1405-uso-clienti-note-in-evidenza-scuro", { s in preparaNoteInEvidenza(s) }),
            ("1406-uso-clienti-note-da-fare", { s in preparaNoteDaFare(s) }),
            ("1406-uso-clienti-note-da-fare-scuro", { s in preparaNoteDaFare(s) }),
            ("1407-uso-clienti-note-vuote", { s in preparaNoteVuote(s) }),
            ("1407-uso-clienti-note-vuote-scuro", { s in preparaNoteVuote(s) }),
        ]
    }

    /// Giulia: la sua nota del taccuino fissata è quella in evidenza, e Panoramica la mostra in «Da ricordare».
    nonisolated static func preparaNoteInEvidenza(_ s: StatoShell) {
        s.clienteAttivoId = "giulia"
        s.schedaCliente = .panoramica
        s.apri(.clienti)
    }

    /// Marco: la sua nota è diventata un «Da fare» per oggi (la riga dice «Nel Da fare»), aperta nella sezione Note.
    nonisolated static func preparaNoteDaFare(_ s: StatoShell) {
        var a = Attivita.nuova(clienteId: "marco")
        a.titolo = s.nota("nota-marco")?.titolo ?? "Le priorità della famiglia"
        a.note = "Dalla nota «\(a.titolo)»."
        a.daNota = "nota-marco"
        s.dati.attivita.append(a)
        s.scegliNota("nota-marco")
        s.apri(.note)
    }

    /// Laura senza note e senza «Da ricordare»: «Nessuna nota, per ora.».
    nonisolated static func preparaNoteVuote(_ s: StatoShell) {
        s.dati.note.removeAll { $0.clienteId == "laura" }
        s.aggiornaNota("laura", "")
        s.clienteAttivoId = "laura"
        s.schedaCliente = .note
        s.apri(.clienti)
    }
}
#endif
