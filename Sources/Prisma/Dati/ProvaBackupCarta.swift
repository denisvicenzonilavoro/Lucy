import Foundation

// Le impostazioni dello stile Carta dentro `Prisma --prova-backup`: `Impostazioni.carta` cambiata va e torna dall'archivio
// (codifica e decodifica dell'archivio), un archivio di prima senza la chiave si apre con i valori di base, i valori
// fuori misura tornano nei limiti e un valore illeggibile non ferma la lettura delle altre impostazioni.

extension ProvaBackup {
    /// Restituisce il motivo dell'errore (nil = tutto bene).
    static func provaCarta() throws -> String? {
        var imp = Impostazioni()
        imp.carta.sogliaPesoTimbro = 25
        imp.carta.quotaAccantonamento = 32
        imp.carta.sfondo = .marmo
        imp.carta.sigilloAutomatico = false
        let dati = try Archivio.codificatore.encode(imp)
        let letta = try Archivio.decodificatore.decode(Impostazioni.self, from: dati)
        guard letta.carta == imp.carta else { return "carta: le impostazioni non tornano uguali dall'archivio" }

        // Un archivio di prima: niente chiave «carta»
        var oggetto = try JSONSerialization.jsonObject(with: dati) as? [String: Any] ?? [:]
        oggetto.removeValue(forKey: "carta")
        let primaDati = try JSONSerialization.data(withJSONObject: oggetto)
        let prima = try Archivio.decodificatore.decode(Impostazioni.self, from: primaDati)
        guard prima.carta == ImpostazioniCarta() else { return "carta: senza la chiave non si aprono i valori di base" }
        guard prima.carta.quotaAccantonamento == nil else { return "carta: la quota da mettere da parte non deve avere un valore di base" }

        // Valori fuori misura e illeggibili
        oggetto["carta"] = ["sogliaPesoTimbro": 400, "quotaAccantonamento": -5, "sfondo": "sconosciuto", "sigilloAutomatico": "sì"]
        let strani = try Archivio.decodificatore.decode(Impostazioni.self,
                                                       from: try JSONSerialization.data(withJSONObject: oggetto))
        guard strani.carta.sogliaPesoTimbro == 100, strani.carta.quotaAccantonamento == 0,
              strani.carta.sfondo == .luce, strani.carta.sigilloAutomatico else {
            return "carta: i valori fuori misura o illeggibili non tornano nei limiti"
        }
        guard strani.nomeUtente == imp.nomeUtente else { return "carta: un valore illeggibile ha fermato le altre impostazioni" }
        return nil
    }
}
