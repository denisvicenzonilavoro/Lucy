import Foundation

// MARK: - Catalogo dei prodotti delle compagnie (fase 2: i tipi, il caricamento, la ricerca)
//
// La risorsa `Risorse/Catalogo/catalogo.json` nasce da `Supporto/catalogo/converti_catalogo.py` (fase 1), che legge
// `catalogo_lucy.xlsx`: tre fogli di voci (investimento, protezione, previdenza), ognuna con il testo originale di ogni
// cella (`testo`) e i soli valori che il testo dice in modo certo (`valori`, percentuali come frazioni: 0.045 = 4,5%).
// REGOLA FERREA: un campo che manca resta nil, MAI zero (cella vuota = dato non pubblicato, non costo zero; vedi il
// foglio Leggimi). Per aggiornare il catalogo basta sostituire l'xlsx e rilanciare lo script: questo codice non cambia.
// Niente interfaccia qui: le viste leggono `CatalogoProdotti.condiviso` e i calcoli stanno in `MotoreCatalogo`.

/// I tre fogli del catalogo con le voci dei prodotti.
enum FoglioCatalogo: String, Codable, CaseIterable, Sendable {
    case investimento, protezione, previdenza

    var nome: String {
        switch self {
        case .investimento: return "Investimento e risparmio"
        case .protezione: return "Protezione"
        case .previdenza: return "Previdenza"
        }
    }

    /// Il foglio ricavato dall'id della voce («investimento-2» → .investimento).
    init?(daId id: String) {
        guard let prefisso = id.split(separator: "-").first, let f = FoglioCatalogo(rawValue: String(prefisso)) else { return nil }
        self = f
    }
}

/// I valori strutturati di una voce: numeri (euro, frazioni, anni), scelte sì/no (`bollo`) e la tabella delle penali
/// di riscatto per anno di polizza. Un campo assente non c'è nel dizionario: si legge come nil.
struct ValoriCatalogo: Codable, Equatable, Sendable {
    var numeri: [String: Double]
    var scelte: [String: Bool]
    /// nil = il catalogo non dice le penali; vuota = nessuna penale (scritto così nel documento).
    var penaliPerAnno: [Int: Double]?

    static let chiavePenali = "penali_per_anno"

    init(numeri: [String: Double] = [:], scelte: [String: Bool] = [:], penaliPerAnno: [Int: Double]? = nil) {
        self.numeri = numeri
        self.scelte = scelte
        self.penaliPerAnno = penaliPerAnno
    }

    private struct Chiave: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }

    /// Lettura tollerante a chiavi libere: un valore di forma sconosciuta si salta (resta nil), mai zero.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Chiave.self)
        var numeri: [String: Double] = [:]
        var scelte: [String: Bool] = [:]
        var penali: [Int: Double]?
        for chiave in c.allKeys {
            if chiave.stringValue == Self.chiavePenali {
                if let tabella = try? c.decode([String: Double].self, forKey: chiave) {
                    var anni: [Int: Double] = [:]
                    for (anno, quota) in tabella { if let n = Int(anno) { anni[n] = quota } }
                    penali = anni
                }
            } else if let n = try? c.decode(Double.self, forKey: chiave) {
                numeri[chiave.stringValue] = n
            } else if let b = try? c.decode(Bool.self, forKey: chiave) {
                scelte[chiave.stringValue] = b
            }
        }
        self.numeri = numeri
        self.scelte = scelte
        self.penaliPerAnno = penali
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: Chiave.self)
        for (k, v) in numeri { if let chiave = Chiave(stringValue: k) { try c.encode(v, forKey: chiave) } }
        for (k, v) in scelte { if let chiave = Chiave(stringValue: k) { try c.encode(v, forKey: chiave) } }
        if let penali = penaliPerAnno, let chiave = Chiave(stringValue: Self.chiavePenali) {
            var tabella: [String: Double] = [:]
            for (anno, quota) in penali { tabella[String(anno)] = quota }
            try c.encode(tabella, forKey: chiave)
        }
    }

    func numero(_ campo: String) -> Double? { numeri[campo] }
    func scelta(_ campo: String) -> Bool? { scelte[campo] }

    /// Un intervallo `<base>_min` / `<base>_max` del catalogo; nil se manca anche uno solo dei due estremi.
    func intervallo(_ base: String) -> (min: Double, max: Double)? {
        guard let a = numeri[base + "_min"], let b = numeri[base + "_max"] else { return nil }
        return (Swift.min(a, b), Swift.max(a, b))
    }
}

/// Una riga del catalogo: il testo originale delle celle (per mostrarlo così com'è) e i valori certi.
struct VoceCatalogo: Codable, Identifiable, Equatable, Sendable {
    var id: String
    /// La riga nel foglio dell'xlsx (per ritrovarla e per la fonte).
    var riga: Int
    /// Una riga «Tutte (categoria)»: condizioni tipiche di una categoria, non un prodotto da scegliere.
    var schedaCategoria: Bool
    /// Colonna → testo originale (solo le celle piene).
    var testo: [String: String]
    var valori: ValoriCatalogo
    /// Protezione: il livello di dettaglio («Completo», «Medio», «Parziale», «Base», «Categoria», «Non trovato»).
    var livello: String?
    var foglio: FoglioCatalogo

    private enum CodingKeys: String, CodingKey {
        case id, riga, testo, valori, livello, foglio
        case schedaCategoria = "scheda_categoria"
    }

    init(id: String, riga: Int, schedaCategoria: Bool = false, testo: [String: String], valori: ValoriCatalogo = ValoriCatalogo(),
         livello: String? = nil, foglio: FoglioCatalogo) {
        self.id = id
        self.riga = riga
        self.schedaCategoria = schedaCategoria
        self.testo = testo
        self.valori = valori
        self.livello = livello
        self.foglio = foglio
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        riga = ((try? c.decodeIfPresent(Int.self, forKey: .riga)) ?? nil) ?? 0
        schedaCategoria = ((try? c.decodeIfPresent(Bool.self, forKey: .schedaCategoria)) ?? nil) ?? false
        let celle = ((try? c.decodeIfPresent([String: String?].self, forKey: .testo)) ?? nil) ?? [:]
        testo = celle.compactMapValues { $0 }
        valori = ((try? c.decodeIfPresent(ValoriCatalogo.self, forKey: .valori)) ?? nil) ?? ValoriCatalogo()
        livello = (try? c.decodeIfPresent(String.self, forKey: .livello)) ?? nil
        foglio = ((try? c.decodeIfPresent(FoglioCatalogo.self, forKey: .foglio)) ?? nil)
            ?? FoglioCatalogo(daId: id) ?? .protezione
    }

    var compagnia: String { testo["compagnia"] ?? "" }
    var prodotto: String { testo["prodotto"] ?? "" }
    /// Previdenza: il comparto (un comparto per riga).
    var comparto: String? { testo["comparto"] }
    /// Protezione: la categoria; investimento e previdenza: il tipo.
    var categoria: String? { testo["categoria"] ?? testo["tipo"] }
    /// Il nome da mostrare: il prodotto, con il comparto per la previdenza.
    var nomeCompleto: String {
        if let c = comparto, !c.isEmpty { return "\(prodotto) · \(c)" }
        return prodotto
    }
    /// «Da sapere»: costi nascosti, penali, condizioni. Va sempre mostrata al cliente (Leggimi).
    var daSapere: String? { testo["da_sapere"] }
    var fonte: String? { testo["fonte"] }
}

/// Un abbinamento proposto da `abbina(nome:)`: il consulente lo conferma, Lucy non sceglie da sola.
struct AbbinamentoCatalogo: Equatable, Sendable {
    var voce: VoceCatalogo
    /// Da 0 a 1 (più alto = più simile).
    var somiglianza: Double
}

/// Il catalogo intero, come sta nella risorsa.
struct CatalogoProdotti: Codable, Equatable, Sendable {
    var versione: Int
    /// Data del catalogo (AAAA-MM-GG), dal foglio Leggimi.
    var data: String
    var fonte: String?
    var avvertenza: String
    /// Il testo da mostrare al posto di un dato che manca («dato non disponibile nel catalogo»).
    var datoMancante: String
    var investimento: [VoceCatalogo]
    var protezione: [VoceCatalogo]
    var previdenza: [VoceCatalogo]
    /// Foglio «Esclusioni tipiche»: intestazione → testo, una riga per categoria.
    var esclusioniTipiche: [[String: String]]
    /// Foglio «Fiscalità»: le regole fiscali con la fonte (le costanti per i calcoli stanno in `FiscoCatalogo`).
    var fiscalita: [[String: String]]
    var leggimi: [String]

    static let testoMancanteDiBase = "dato non disponibile nel catalogo"

    private enum CodingKeys: String, CodingKey {
        case versione, data, fonte, avvertenza, investimento, protezione, previdenza, fiscalita, leggimi
        case datoMancante = "dato_mancante"
        case esclusioniTipiche = "esclusioni_tipiche"
    }

    init(versione: Int, data: String, fonte: String? = nil, avvertenza: String = "", datoMancante: String = testoMancanteDiBase,
         investimento: [VoceCatalogo] = [], protezione: [VoceCatalogo] = [], previdenza: [VoceCatalogo] = [],
         esclusioniTipiche: [[String: String]] = [], fiscalita: [[String: String]] = [], leggimi: [String] = []) {
        self.versione = versione
        self.data = data
        self.fonte = fonte
        self.avvertenza = avvertenza
        self.datoMancante = datoMancante
        self.investimento = investimento
        self.protezione = protezione
        self.previdenza = previdenza
        self.esclusioniTipiche = esclusioniTipiche
        self.fiscalita = fiscalita
        self.leggimi = leggimi
    }

    /// Lettura tollerante: una voce scritta male si scarta, le altre restano.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        versione = try c.decode(Int.self, forKey: .versione)
        data = try c.decode(String.self, forKey: .data)
        fonte = (try? c.decodeIfPresent(String.self, forKey: .fonte)) ?? nil
        avvertenza = ((try? c.decodeIfPresent(String.self, forKey: .avvertenza)) ?? nil) ?? ""
        datoMancante = ((try? c.decodeIfPresent(String.self, forKey: .datoMancante)) ?? nil) ?? Self.testoMancanteDiBase
        func voci(_ chiave: CodingKeys, _ foglio: FoglioCatalogo) -> [VoceCatalogo] {
            let elenco = ((try? c.decodeIfPresent(ElencoTollerante<VoceCatalogo>.self, forKey: chiave)) ?? nil)?.elementi ?? []
            return elenco.map { v in var v = v; v.foglio = foglio; return v }
        }
        investimento = voci(.investimento, .investimento)
        protezione = voci(.protezione, .protezione)
        previdenza = voci(.previdenza, .previdenza)
        func tabella(_ chiave: CodingKeys) -> [[String: String]] {
            let righe = ((try? c.decodeIfPresent([[String: String?]].self, forKey: chiave)) ?? nil) ?? []
            return righe.map { $0.compactMapValues { $0 } }
        }
        esclusioniTipiche = tabella(.esclusioniTipiche)
        fiscalita = tabella(.fiscalita)
        leggimi = ((try? c.decodeIfPresent([String?].self, forKey: .leggimi)) ?? nil)?.compactMap { $0 } ?? []
    }

    // MARK: Caricamento

    /// Il percorso della risorsa nel pacchetto dell'app.
    static let percorsoRisorsa = "Catalogo/catalogo.json"

    /// Legge un catalogo da dati JSON (nil se il file non si legge).
    static func leggi(_ dati: Data) -> CatalogoProdotti? {
        try? JSONDecoder().decode(CatalogoProdotti.self, from: dati)
    }

    /// Il catalogo del pacchetto, letto una volta sola (al primo uso; `static let` è pigro e sicuro tra i thread).
    /// nil se la risorsa manca o non si legge: chi lo usa dice «catalogo non disponibile», mai valori di ripiego.
    static let condiviso: CatalogoProdotti? = {
        guard let url = Risorse.cartella?.appendingPathComponent(percorsoRisorsa),
              let dati = try? Data(contentsOf: url) else { return nil }
        return leggi(dati)
    }()

    /// Legge il catalogo fuori dal thread principale (circa 600 KB), così il primo uso dall'interfaccia non attende.
    static func precarica() {
        Task.detached(priority: .utility) { _ = CatalogoProdotti.condiviso }
    }

    // MARK: Voci

    /// Tutte le voci, nell'ordine dei fogli.
    var tutte: [VoceCatalogo] { investimento + protezione + previdenza }

    func voci(_ foglio: FoglioCatalogo) -> [VoceCatalogo] {
        switch foglio {
        case .investimento: return investimento
        case .protezione: return protezione
        case .previdenza: return previdenza
        }
    }

    func voce(id: String) -> VoceCatalogo? { tutte.first { $0.id == id } }

    /// I prodotti selezionabili (senza le schede di categoria).
    func prodotti(_ foglio: FoglioCatalogo? = nil) -> [VoceCatalogo] {
        (foglio.map { voci($0) } ?? tutte).filter { !$0.schedaCategoria }
    }

    /// Le schede di categoria: guida alle condizioni tipiche, mai un prodotto da scegliere.
    var schedeCategoria: [VoceCatalogo] { tutte.filter(\.schedaCategoria) }

    /// Le compagnie dei prodotti, in ordine alfabetico (senza «Tutte (categoria)»).
    var compagnie: [String] {
        Array(Set(prodotti().map(\.compagnia).filter { !$0.isEmpty }))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    // MARK: Ricerca

    /// Minuscole, senza accenti, solo lettere e cifre separate da uno spazio («GenerAzióne-INVESTIMENTO» →
    /// «generazione investimento»).
    static func normalizza(_ s: String) -> String {
        let piegato = s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "it_IT")).lowercased()
        let pulito = String(piegato.map { $0.isLetter || $0.isNumber ? $0 : " " })
        return pulito.split(separator: " ").joined(separator: " ")
    }

    static func parole(_ s: String) -> [String] {
        normalizza(s).split(separator: " ").map(String.init)
    }

    /// Il testo su cui si cerca una voce: compagnia, prodotto, comparto, categoria o tipo.
    private static func testoRicerca(_ v: VoceCatalogo) -> String {
        normalizza([v.compagnia, v.prodotto, v.comparto ?? "", v.testo["categoria"] ?? "", v.testo["tipo"] ?? "",
                    v.testo["area"] ?? ""].joined(separator: " "))
    }

    /// I prodotti (mai le schede di categoria) di una compagnia e che contengono tutte le parole del testo, senza
    /// badare a maiuscole e accenti. Testo vuoto = tutti i prodotti della compagnia. Ordine del catalogo: nessuna
    /// classifica tra prodotti.
    func cerca(_ testo: String = "", compagnia: String? = nil, foglio: FoglioCatalogo? = nil) -> [VoceCatalogo] {
        let cercate = Self.parole(testo)
        let filtroCompagnia = compagnia.map(Self.normalizza).flatMap { $0.isEmpty ? nil : $0 }
        return prodotti(foglio).filter { v in
            if let f = filtroCompagnia, !Self.normalizza(v.compagnia).contains(f) { return false }
            guard !cercate.isEmpty else { return true }
            let dove = Self.testoRicerca(v)
            return cercate.allSatisfy { dove.contains($0) }
        }
    }

    /// Le schede di categoria che fanno da guida per una categoria («Viaggio», «Animali», «Tutela legale»…): una
    /// parola significativa in comune con la categoria o il nome della scheda.
    func guida(categoria: String) -> [VoceCatalogo] {
        let cercate = Set(Self.parole(categoria).filter { $0.count >= 3 })
        guard !cercate.isEmpty else { return [] }
        return schedeCategoria.filter { s in
            let sue = Set(Self.parole((s.testo["categoria"] ?? "") + " " + s.prodotto).filter { $0.count >= 3 })
            return !cercate.isDisjoint(with: sue)
        }
    }

    /// La guida per la categoria di un prodotto.
    func guida(per voce: VoceCatalogo) -> [VoceCatalogo] {
        guard let c = voce.testo["categoria"] else { return [] }
        return guida(categoria: c)
    }

    /// Dal nome letto in un documento (fotocamera, PDF) propone le righe più simili, la più simile per prima: il
    /// consulente sceglie e conferma. Somiglianza di Dice sulle parole del prodotto (e del comparto), più un aiuto se
    /// il nome intero del prodotto compare nel testo e se compare la compagnia. Mai le schede di categoria.
    func abbina(nome: String, limite: Int = 5, sogliaMinima: Double = 0.34) -> [AbbinamentoCatalogo] {
        let testoLetto = Self.normalizza(nome)
        let lette = Set(Self.parole(nome))
        guard !lette.isEmpty else { return [] }
        var trovati: [AbbinamentoCatalogo] = []
        for v in prodotti() {
            let nomeProdotto = Self.normalizza(v.prodotto)
            let suParole = Set(Self.parole(v.prodotto + " " + (v.comparto ?? "")))
            guard !suParole.isEmpty else { continue }
            let comuni = Double(suParole.intersection(lette).count)
            var punti = 2 * comuni / Double(suParole.count + lette.count)
            if !nomeProdotto.isEmpty, (" " + testoLetto + " ").contains(" " + nomeProdotto + " ") { punti += 0.5 }
            let compagnia = Set(Self.parole(v.compagnia).filter { $0.count >= 3 })
            if !compagnia.isEmpty, !compagnia.isDisjoint(with: lette) { punti += 0.1 }
            if punti >= sogliaMinima { trovati.append(AbbinamentoCatalogo(voce: v, somiglianza: Swift.min(1, punti / 1.6))) }
        }
        return Array(trovati.sorted { a, b in
            a.somiglianza != b.somiglianza ? a.somiglianza > b.somiglianza : a.voce.riga < b.voce.riga
        }.prefix(Swift.max(0, limite)))
    }
}
