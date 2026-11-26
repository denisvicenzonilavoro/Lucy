import Foundation
import Security

// Mistral in cloud (decisione dell'utente del 25 novembre 2026: «mistral in cloud con api che sto già usando come su
// Lucy AI»). È l'unica eccezione alla regola «solo indirizzi del Mac» per l'assistente: con il fornitore «Mistral» le
// domande, con i dati dei clienti che contengono, vanno all'API di Mistral AI (api.mistral.ai, server nell'Unione
// Europea) con la chiave dell'utente. La chiave sta solo nel Portachiavi del Mac (`PortachiaviMistral`), mai
// nell'archivio, nelle impostazioni, nei backup o nel repository. Si sceglie in Impostazioni › Lucy; con Ollama o un
// server compatibile OpenAI tutto resta sul Mac come prima.

/// L'API chat di Mistral AI: /v1/chat/completions in streaming (formato compatibile OpenAI), con la chiave dell'utente.
struct FornitoreMistral: FornitoreModello {
    /// L'unico indirizzo ammesso per Mistral in cloud.
    static let indirizzoUfficiale = "https://api.mistral.ai"
    /// Il modello di base: Mistral Small (veloce, buono per il lavoro di tutti i giorni).
    static let modelloPredefinito = "mistral-small-latest"
    /// I modelli proposti nel menu.
    static let modelliProposti = ["mistral-small-latest", "mistral-medium-latest", "mistral-large-latest", "ministral-8b-latest"]

    let modello: String
    var sessione: URLSession = .shared
    /// La chiave (letta dal Portachiavi); nil = non c'è.
    var chiave: String? = PortachiaviMistral.leggi()

    var nome: String { "Mistral" }
    var indirizzo: String { Self.indirizzoUfficiale }

    /// L'indirizzo di un percorso dell'API (sempre e solo api.mistral.ai).
    private func urlMistral(_ percorso: String) throws -> URL {
        guard let base = URL(string: Self.indirizzoUfficiale) else { throw ErroreVera(messaggio: "Indirizzo di Mistral non valido.") }
        return base.appendingPathComponent(percorso)
    }

    private func conChiave(_ r: inout URLRequest) throws {
        guard let k = chiave, !k.isEmpty else {
            throw ErroreVera(messaggio: "Manca la chiave di Mistral: scrivila in Impostazioni › Lucy › Mistral in cloud.")
        }
        r.setValue("Bearer \(k)", forHTTPHeaderField: "Authorization")
    }

    func richiesta(_ messaggi: [MessaggioModello], opzioni: OpzioniModello) throws -> URLRequest {
        var r = URLRequest(url: try urlMistral("v1/chat/completions"), timeoutInterval: MotoreLocale.attesaMassima)
        r.httpMethod = "POST"
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        try conChiave(&r)
        r.httpBody = try JSONSerialization.data(withJSONObject: Self.corpo(modello: modello, messaggi: messaggi, opzioni: opzioni))
        return r
    }

    /// Il corpo per Mistral: solo i campi che l'API accetta (niente chat_template_kwargs né stream_options).
    static func corpo(modello: String, messaggi: [MessaggioModello], opzioni: OpzioniModello) -> [String: Any] {
        var c: [String: Any] = [
            "model": modello,
            "messages": messaggi.map(\.jsonOpenAI),
            "stream": true,
            "temperature": opzioni.temperatura,
        ]
        if let n = opzioni.massimoToken { c["max_tokens"] = n }
        if !opzioni.strumenti.isEmpty { c["tools"] = opzioni.strumenti.map(\.json) }
        if let f = opzioni.formato {
            let schema: [String: Any] = ["name": "risposta", "schema": f]
            c["response_format"] = ["type": "json_schema", "json_schema": schema] as [String: Any]
        }
        return c
    }

    /// Le righe SSE di Mistral hanno lo stesso formato di quelle compatibili OpenAI.
    func lettore() -> LettoreFlusso { FornitoreCompatibileOpenAI.Lettore() }

    func verifica() async -> DisponibilitaVera {
        guard let k = chiave, !k.isEmpty else {
            return .nonDisponibile("Manca la chiave di Mistral: scrivila in Impostazioni › Lucy › Mistral in cloud.")
        }
        guard let elenco = try? await modelli() else {
            return .nonDisponibile("Mistral non risponde: controlla la connessione a internet e la chiave in Impostazioni › Lucy.")
        }
        let voluto = modello.trimmingCharacters(in: .whitespaces)
        guard !voluto.isEmpty else { return .nonDisponibile("Scegli il modello di Mistral in Impostazioni › Lucy.") }
        // Gli alias «-latest» non sempre sono nell'elenco: basta che la chiave funzioni
        if voluto.hasSuffix("-latest") || elenco.contains(voluto) { return .pronto }
        return .nonDisponibile("La tua chiave di Mistral non ha il modello \(voluto): scegline un altro in Impostazioni › Lucy.")
    }

    func modelli() async throws -> [String] {
        var r = URLRequest(url: try urlMistral("v1/models"), timeoutInterval: 8)
        r.httpMethod = "GET"
        try conChiave(&r)
        let (dati, risposta) = try await sessione.data(for: r)
        guard (risposta as? HTTPURLResponse)?.statusCode == 200 else {
            throw ErroreVera(messaggio: "Mistral ha rifiutato la chiave.")
        }
        let j = try JSONSerialization.jsonObject(with: dati) as? [String: Any]
        return ((j?["data"] as? [[String: Any]]) ?? []).compactMap { $0["id"] as? String }
    }

    func raggiungibile() async -> Bool { (try? await modelli()) != nil }
    func precarica(restaInMemoria: String) async -> Bool { true }
    func libera() async {}
}

/// La chiave di Mistral nel Portachiavi di login del Mac (in Lucy Demo un servizio a parte).
/// Mai nell'archivio, nelle preferenze, nei backup o nel repository.
enum PortachiaviMistral {
    static var servizio: String { "Prisma Mistral" + EdizioneLucy.suffissoPortachiavi }
    static let conto = "chiave API"
    static let etichetta = "Lucy – chiave di Mistral"

    private static var ricerca: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: servizio,
         kSecAttrAccount as String: conto]
    }

    /// Salva (o sostituisce) la chiave; una chiave vuota la toglie. false se il Portachiavi non l'ha accettata.
    @discardableResult
    static func salva(_ chiave: String) -> Bool {
        let pulita = chiave.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pulita.isEmpty else {
            elimina()
            return true
        }
        let valore = Data(pulita.utf8)
        let modifica: [String: Any] = [kSecValueData as String: valore]
        let aggiornata = SecItemUpdate(ricerca as CFDictionary, modifica as CFDictionary)
        if aggiornata == errSecSuccess { return true }
        if aggiornata != errSecItemNotFound { _ = SecItemDelete(ricerca as CFDictionary) }
        var nuova = ricerca
        nuova[kSecValueData as String] = valore
        nuova[kSecAttrLabel as String] = etichetta
        return SecItemAdd(nuova as CFDictionary, nil) == errSecSuccess
    }

    static func leggi() -> String? {
        var domanda = ricerca
        domanda[kSecReturnData as String] = true
        domanda[kSecMatchLimit as String] = kSecMatchLimitOne
        var risultato: CFTypeRef?
        guard SecItemCopyMatching(domanda as CFDictionary, &risultato) == errSecSuccess,
              let dati = risultato as? Data,
              let chiave = String(data: dati, encoding: .utf8), !chiave.isEmpty else { return nil }
        return chiave
    }

    static var presente: Bool { leggi() != nil }

    static func elimina() {
        _ = SecItemDelete(ricerca as CFDictionary)
    }
}
