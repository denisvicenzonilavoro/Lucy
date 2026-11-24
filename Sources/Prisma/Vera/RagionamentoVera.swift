import Foundation
import Observation

// Il ragionamento da aprire e chiudere (motori Mistral, tappa 3). Ministral 3 e Mistral Small 4 sanno «pensare prima di
// rispondere»: quel testo arriva a parte (Ollama: message.thinking, o tra <think> e </think>) e non entra mai nella
// risposta. Vera lo mostra piegato sotto la risposta, da aprire con un tocco. Resta solo in memoria: non va
// nell'archivio, nei backup né in «Prisma ovunque», e si cancella al blocco di Prisma.

/// I ragionamenti delle ultime risposte di Vera, per l'interfaccia. Oggetto a parte (`StatoShell.ragionamentiVera`),
/// osservato solo da chi lo mostra.
@Observable final class RagionamentiVera {
    /// Quanti ragionamenti si tengono (i più vecchi escono): poca memoria sul Mac da 8 GB.
    static let massimo = 30
    /// Un ragionamento più lungo di così si tronca (resta l'inizio).
    static let lunghezzaMassima = 20_000

    /// Il ragionamento di ogni risposta, con l'id del messaggio di Vera.
    private(set) var testi: [String: String] = [:]
    /// Le risposte con il ragionamento aperto.
    private(set) var aperti: Set<String> = []
    /// L'ordine di arrivo, per far uscire i più vecchi.
    @ObservationIgnored private var ordine: [String] = []

    /// Tiene il ragionamento di una risposta (niente se è vuoto).
    func conserva(_ testo: String, per id: String) {
        let t = testo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        testi[id] = String(t.prefix(Self.lunghezzaMassima))
        ordine.removeAll { $0 == id }
        ordine.append(id)
        while ordine.count > Self.massimo {
            let via = ordine.removeFirst()
            testi[via] = nil
            aperti.remove(via)
        }
    }

    func testo(_ id: String) -> String? { testi[id] }
    func ha(_ id: String) -> Bool { testi[id] != nil }
    func aperto(_ id: String) -> Bool { aperti.contains(id) }

    /// Apre o chiude il ragionamento sotto una risposta.
    func apriChiudi(_ id: String) {
        guard testi[id] != nil else { return }
        if aperti.contains(id) { aperti.remove(id) } else { aperti.insert(id) }
    }

    /// Al blocco di Prisma (e con una nuova conversazione): non resta nulla.
    func svuota() {
        if !testi.isEmpty { testi = [:] }
        if !aperti.isEmpty { aperti = [] }
        ordine = []
    }
}

/// Il ragionamento mentre arriva, raccolto fuori dal thread principale: dopo `scrivi` c'è quello completo.
final class RaccoltaRagionamento: @unchecked Sendable {
    private let blocco = NSLock()
    private var _testo = ""

    var testo: String {
        get { blocco.lock(); defer { blocco.unlock() }; return _testo }
        set { blocco.lock(); _testo = newValue; blocco.unlock() }
    }
}
