import Foundation

// Migliorie d'uso 60 «Ogni esperienza lascia qualcosa» (Design/uso/gruppo-10.md §60): la traccia di un'esperienza della
// Sala fatta con il cliente. Solo chi, cosa e quando: nessuna risposta, nessun testo, nessuna cifra. Nella cartella a
// pezzi sta nel file del cliente (`ArchivioPezzi.pezzo`: `.cliente`), nei backup; mai in «Prisma ovunque» (decisione
// 60-e: è una nota di lavoro del Mac). Letta con tolleranza: un'esperienza sconosciuta (da un Prisma più nuovo) fa
// fallire la decodifica dell'elemento, e `ElencoTollerante` lo scarta.

/// L'esperienza si codifica con il suo rawValue: un valore sconosciuto non si legge.
extension EsperienzaSala: Codable {}

/// Un'esperienza della Sala fatta con il cliente, in un giorno. Una seconda volta in un altro giorno lascia una seconda
/// riga (decisione 60-c).
struct EsperienzaFatta: Identifiable, Codable, Hashable {
    /// "fatta-xxxxxxxx".
    var id: String
    var clienteId: String
    var esperienza: EsperienzaSala
    var quando: Date

    init(id: String = "fatta-\(UUID().uuidString.prefix(8).lowercased())", clienteId: String,
         esperienza: EsperienzaSala, quando: Date) {
        self.id = id
        self.clienteId = clienteId
        self.esperienza = esperienza
        self.quando = quando
    }

    /// Fatta nel giorno di `giorno`.
    func fatta(il giorno: Date, calendario: Calendar = .current) -> Bool {
        calendario.isDate(quando, inSameDayAs: giorno)
    }

    /// Le esperienze fatte dal cliente nel giorno dato (funzione pura, per le prove e per il dato ricavato).
    static func fatte(_ elenco: [EsperienzaFatta], cliente: String, il giorno: Date,
                      calendario: Calendar = .current) -> Set<EsperienzaSala> {
        Set(elenco.lazy.filter { $0.clienteId == cliente && $0.fatta(il: giorno, calendario: calendario) }.map(\.esperienza))
    }

    /// Le ultime esperienze fatte dal cliente, dalla più recente, al più `quante`.
    static func ultime(_ elenco: [EsperienzaFatta], cliente: String, quante: Int) -> [EsperienzaFatta] {
        Array(elenco.filter { $0.clienteId == cliente }.sorted { $0.quando > $1.quando }.prefix(quante))
    }
}

extension EsperienzaSala {
    /// L'ordine delle esperienze dentro i momenti, come `SALA_M` del template: prisma di luce, disegna, realtà
    /// aumentata · rischio, giornata, Lancia l'anno · lettera, quanto vale, capsula · film, poi il Prisma del cliente
    /// (diverso da `allCases`, che mette prima il Prisma del cliente).
    static let ordineMomenti: [EsperienzaSala] = [
        .prismaLuce, .disegna, .realtaAumentata,
        .giocoRischio, .giornataPensione, .lanciaAnno,
        .lettera, .valoreConsulente, .capsula,
        .film, .prismaCliente,
    ]

    /// «Prossima: … ›» (`salaProssima` del template): fra le esperienze non ancora fatte oggi (esclusa quella aperta), il
    /// primo momento dopo quello dell'esperienza aperta che ne ha almeno una libera; dentro il momento la prima
    /// consigliata, altrimenti la prima nell'ordine. Se nei momenti dopo non ce n'è, la prima libera dello stesso
    /// momento; i momenti prima non si propongono mai. nil se non resta nulla.
    static func prossima(dopo aperta: EsperienzaSala, fatte: Set<EsperienzaSala>,
                         consigliate: [EsperienzaSala]) -> EsperienzaSala? {
        let momenti = MomentoSala.allCases
        guard let i = momenti.firstIndex(of: aperta.momento) else { return nil }
        let libere = ordineMomenti.filter { $0 != aperta && !fatte.contains($0) }
        func scegli(_ l: [EsperienzaSala]) -> EsperienzaSala? { l.first(where: { consigliate.contains($0) }) ?? l.first }
        for m in momenti[(i + 1)...] {
            if let e = scegli(libere.filter { $0.momento == m }) { return e }
        }
        return scegli(libere.filter { $0.momento == aperta.momento })
    }
}
