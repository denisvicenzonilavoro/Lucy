import Foundation

// L'esportazione dei dati di un cliente (GDPR, art. 15 diritto di accesso e art. 20 portabilità; piano «App sicure» del
// 23 novembre 2026, Design/piano-app-sicure.md): tutto ciò che Prisma conserva di quella persona in un solo file JSON
// leggibile, da consegnare al cliente che lo chiede. È lo stesso contenuto del suo file nella cartella a pezzi (anagrafica
// e tutto ciò che ha il suo clienteId: posizioni, obiettivi, documenti, note, analisi, messaggi, parcelle…) più i suoi
// appuntamenti e le sue attività, che stanno nelle sezioni comuni. Nessun dato di altri clienti. Il file nasce solo
// quando il consulente lo chiede e lo salva dove sceglie lui: Prisma non lo spedisce.

private struct DossierEsportato: Encodable {
    let dati: DatiPrisma
    func encode(to encoder: Encoder) throws {
        try dati.codifica(in: encoder, solo: ArchivioPezzi.chiaviCliente)
    }
}

private struct EsportazioneDati: Encodable {
    let formato = "Prisma · esportazione dei dati di un cliente (GDPR art. 15 e 20)"
    let esportatoIl: Date
    let dossier: DossierEsportato
    let appuntamenti: [Appuntamento]
    let attivita: [Attivita]
}

enum EsportazioneCliente {
    /// I dati di un solo cliente, presi come li divide l'archivio a pezzi (il gruppo del cliente; tutto il resto altrove).
    static func dati(di id: String, da d: DatiPrisma) -> DatiPrisma {
        var pezzi: [String: DatiPrisma] = [:]
        let gruppo: (String) -> String = { $0 == id ? id : ArchivioPezzi.gruppoAltri }
        for campo in ArchivioPezzi.campiCliente {
            _ = campo.distribuisci(d, gruppo, &pezzi)
        }
        return pezzi[id] ?? DatiPrisma()
    }

    /// Il file JSON dell'esportazione (date ISO 8601, chiavi in ordine).
    static func json(di id: String, da d: DatiPrisma, il data: Date = Date()) throws -> Data {
        let e = EsportazioneDati(esportatoIl: data, dossier: DossierEsportato(dati: dati(di: id, da: d)),
                                 appuntamenti: d.appuntamenti.filter { $0.clienteId == id },
                                 attivita: d.attivita.filter { $0.clienteId == id })
        let c = JSONEncoder()
        c.outputFormatting = [.prettyPrinted, .sortedKeys]
        c.dateEncodingStrategy = .iso8601
        return try c.encode(e)
    }
}
