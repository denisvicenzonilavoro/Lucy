import Foundation

/// Uno spazio di lavoro: un gruppo di app con la loro disposizione, da riaprire con un clic
/// (per esempio «Incontro con il cliente»: Clienti, Posizioni e Vera affiancate).
struct SpazioLavoro: Identifiable, Codable, Hashable {
    var id = "spazio-\(UUID().uuidString.prefix(8).lowercased())"
    var nome: String
    var finestre: [FinestraSpazio]
    /// Gli spazi pronti di Prisma non si eliminano e non si salvano nell'archivio.
    var predefinito = false

    private enum CodingKeys: String, CodingKey { case id, nome, finestre }
}

extension SpazioLavoro {
    /// Lettura tollerante (versione 27, «Luce», decisione 104): una finestra di un'app che questo Prisma non conosce
    /// (per esempio un iPhone non ancora aggiornato che legge uno spazio con la Sala) si salta e lo spazio resta con le
    /// altre; uno spazio senza nessuna finestra leggibile non si apre.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let nome = try c.decode(String.self, forKey: .nome)
        let finestre = try c.decode(ElencoTollerante<FinestraSpazio>.self, forKey: .finestre).elementi
        guard !finestre.isEmpty else {
            throw DecodingError.dataCorruptedError(forKey: .finestre, in: c, debugDescription: "Spazio senza finestre leggibili")
        }
        self.init(nome: nome, finestre: finestre)
        if let id = try c.decodeIfPresent(String.self, forKey: .id) { self.id = id }
    }
}

/// Una finestra dello spazio, in frazioni dell'area delle finestre (0…1): così la disposizione
/// si adatta a qualsiasi schermo.
struct FinestraSpazio: Codable, Hashable {
    var app: AppPrisma
    var x: Double
    var y: Double
    var larghezza: Double
    var altezza: Double
    var ingrandita = false

    var frazione: CGRect { CGRect(x: x, y: y, width: larghezza, height: altezza) }

    static func intera(_ app: AppPrisma) -> FinestraSpazio {
        FinestraSpazio(app: app, x: 0, y: 0, larghezza: 1, altezza: 1, ingrandita: true)
    }
    /// Quota dell'app principale quando due app sono affiancate (l'altra prende il resto).
    static let quotaPrincipale = 0.58

    static func sinistra(_ app: AppPrisma, quota: Double = quotaPrincipale) -> FinestraSpazio {
        FinestraSpazio(app: app, x: 0, y: 0, larghezza: quota, altezza: 1)
    }
    static func destra(_ app: AppPrisma, quota: Double = 1 - quotaPrincipale) -> FinestraSpazio {
        FinestraSpazio(app: app, x: 1 - quota, y: 0, larghezza: quota, altezza: 1)
    }
}

extension SpazioLavoro {
    /// Le disposizioni pronte (migliorie d'uso 67, i nomi del template): due app affiancate, la principale (la prima del
    /// nome) a sinistra al 58% e in primo piano, l'altra a destra. Non di più: le app hanno bisogno di spazio e le
    /// finestre una misura minima. Prospetti non si affianca; Posizioni sì, nella colonna di destra di «Faccio
    /// un’analisi» (decisione 67.6: al 42% di uno schermo da 13″ resta sopra la misura minima della finestra; se non si
    /// legge, diventa lei la principale). Gli `id` restano quelli di prima: nell'archivio non cambia nulla.
    static let predefiniti: [SpazioLavoro] = [
        SpazioLavoro(id: "pronto-incontro", nome: "Preparo un incontro",
                     finestre: [.destra(.vera), .sinistra(.incontri)], predefinito: true),
        SpazioLavoro(id: "pronto-analisi", nome: "Faccio un’analisi",
                     finestre: [.destra(.posizioni), .sinistra(.analisi360)], predefinito: true),
        // Le attività vivono nell'Agenda (vista mese, con la colonna del giorno): accanto i messaggi da mandare
        SpazioLavoro(id: "pronto-giornata", nome: "Comincio la giornata",
                     finestre: [.destra(.messaggi), .sinistra(.agenda)], predefinito: true),
    ]

    /// Le app, dalla principale (l'ultima, in primo piano) alle altre.
    var app: [AppPrisma] { finestre.reversed().map(\.app) }
}
