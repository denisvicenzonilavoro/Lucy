import Foundation

// Migliorie d'uso 35 «Biblioteca: prima i documenti del cliente, e si aprono con un clic» (Design/uso/gruppo-05.md §35):
// le parti pure. Il legame documento → cliente passa dal prodotto (`TestoNorma.prodottoId`) e dalle posizioni del
// cliente: nessun campo nuovo. Le domande d'esempio dei fac-simile dicono di quale documento parlano e quale cliente di
// prova nominano: con un altro cliente scelto non si mostrano (come il template), in modalità cliente restano senza nome.

/// Una domanda d'esempio dei sei fac-simile (le tre del template).
struct DomandaEsempioBiblioteca: Equatable {
    let testo: String
    /// La stessa domanda senza nome (modalità cliente, decisione 5 di «Luce»); nil se non nomina nessuno.
    let senzaNome: String?
    /// Il titolo del fac-simile di cui parla (`EsempiBiblioteca.elenco`).
    let documento: String
    /// Il cliente di prova che nomina (id dei dati di prova), nil se non ne nomina.
    let cliente: String?
}

extension EsempiBiblioteca {
    /// Le domande d'esempio dei fac-simile, con il documento di cui parlano e il cliente di prova che nominano.
    static let domande: [DomandaEsempioBiblioteca] = [
        DomandaEsempioBiblioteca(testo: "Il riscatto nei primi anni ha penali?", senzaNome: nil,
                                 documento: "Piano rivalutabile · Condizioni di assicurazione", cliente: nil),
        DomandaEsempioBiblioteca(testo: "Quanto si deduce del fondo pensione?", senzaNome: nil,
                                 documento: "Circolare · Previdenza complementare", cliente: nil),
        DomandaEsempioBiblioteca(testo: "Se Marco non paga la temporanea?", senzaNome: "Se il cliente non paga la temporanea?",
                                 documento: "Temporanea caso morte · Condizioni di assicurazione", cliente: "marco"),
    ]
}

/// I testi della Biblioteca nuovi delle migliorie d'uso 35.
enum TestiBiblioteca {
    static let documenti = "I documenti"
    static func deiProdotti(_ nome: String) -> String { "Dei prodotti di \(nome)" }
    static let altriDocumenti = "Gli altri documenti"
    static let segnaposto = "Chiedi qualcosa ai tuoi documenti…"
    static func segnapostoDocumento(_ titoloBreve: String) -> String { "Chiedi qualcosa su «\(titoloBreve)»…" }
    static let lettoSulMac = "Vera l’ha letto sul Mac."
    static let illeggibile = "Non posso leggerlo: le domande non trovano niente qui."
    static let domandeDocumento = "Domande su questo documento"
    static let chiediTu = "Chiedi tu"
    static let chiediTuTesto = "Scrivi una domanda in alto: Vera risponde solo con il testo di questo documento, citando la pagina."
    static let tornaAllaRisposta = "Torna alla risposta"
    static let chiudiDocumento = "Cerca in tutti i documenti"
    static func rubrica(_ r: String) -> String { "Cosa dice «\(r)»?" }

    /// «38 pagine · canale Alleanza», «… · canale indipendente», «… · vale per tutti i canali».
    static func pagineECanale(pagine n: Int, canale: Canale?) -> String {
        let pagine = n == 1 ? "1 pagina" : "\(n) pagine"
        switch canale {
        case .alleanza?: return "\(pagine) · canale \(Canale.alleanza.nomeInFrase)"
        case .indipendente?: return "\(pagine) · canale \(Canale.indipendente.nomeInFrase)"
        case nil: return "\(pagine) · vale per tutti i canali"
        }
    }
}

extension MotoreBiblioteca {
    /// I prodotti del cliente che contano per la Biblioteca: quelli delle posizioni in essere e delle proposte non
    /// rifiutate (le chiuse no).
    static func prodottiDelCliente(_ posizioni: [Posizione]) -> Set<String> {
        var r = Set<String>()
        for p in posizioni {
            guard let id = p.prodottoId else { continue }
            switch p.stato {
            case .inEssere: r.insert(id)
            case .proposta: if p.esito != .rifiutata { r.insert(id) }
            case .chiusa: break
            }
        }
        return r
    }

    /// I documenti dei prodotti del cliente, nell'ordine dell'elenco: anche gli illeggibili (la colonna li mostra già
    /// tutti, qui si raggruppano soltanto; la ricerca continua a saltarli).
    static func documentiDelCliente(prodotti: Set<String>, tra documenti: [DocumentoBiblioteca]) -> [String] {
        guard !prodotti.isEmpty else { return [] }
        return documenti.filter { d in d.prodottoId.map { prodotti.contains($0) } ?? false }.map(\.id)
    }

    /// Le domande d'esempio dei fac-simile: tutte (`documento` nil) o solo quelle di un documento (il suo titolo). Con un
    /// cliente scelto diverso da quello che una domanda nomina, la domanda non si mostra; in modalità cliente resta la
    /// versione senza nome.
    static func domandeEsempio(documento: String?, cliente: String?, modoCliente: Bool,
                               tra elenco: [DomandaEsempioBiblioteca] = EsempiBiblioteca.domande) -> [String] {
        elenco.compactMap { q in
            if let documento, q.documento != documento { return nil }
            guard let nominato = q.cliente else { return q.testo }
            if modoCliente { return q.senzaNome ?? q.testo }
            if let cliente, cliente != nominato { return nil }
            return q.testo
        }
    }

    /// Le rubriche dalle intestazioni dei passi («Art. 9 · Riscatto» → «Riscatto»), senza doppioni, al più `quante`.
    static func rubriche(_ passi: [PassoBiblioteca], quante: Int = 3) -> [String] {
        var visti = Set<String>()
        var r: [String] = []
        for p in passi where !p.intestazione.isEmpty {
            let rubrica = p.intestazioneVista.components(separatedBy: " · ").dropFirst().joined(separator: " · ")
            guard !rubrica.isEmpty, rubrica.count <= 40, visti.insert(rubrica.lowercased()).inserted else { continue }
            r.append(rubrica)
            if r.count == quante { break }
        }
        return r
    }
}
