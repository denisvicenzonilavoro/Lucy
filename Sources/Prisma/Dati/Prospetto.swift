import Foundation

/// Cosa si vuole stampare. I prospetti sono per il consulente (dettagliati, un tema alla volta);
/// la valutazione di un investimento ha anche il report da lasciare al cliente.
enum SceltaProspetto: Hashable {
    /// Resoconto delle posizioni in essere: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case resoconto(report: Bool)
    /// Sostituzione di una posizione in essere con un'alternativa (o confronto tra due proposte):
    /// prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case sostituzione(String, String, report: Bool)
    /// Piano previdenziale: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case previdenza(report: Bool)
    /// Protezione della famiglia: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case protezione(report: Bool)
    /// Piano per un obiettivo del cliente: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case obiettivo(String, report: Bool)
    /// Capitale in scadenza e liquidità: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case liquidita(report: Bool)
    /// Check-up del primo incontro: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case checkUp(report: Bool)
    /// Prova di resistenza del patrimonio: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case resistenza(report: Bool)
    /// Il costo degli investimenti: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case costi(report: Bool)
    /// Il passaggio generazionale: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case successione(report: Bool)
    /// Il patrimonio nei prossimi anni: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case patrimonio(report: Bool)
    /// Il fascicolo dell'incontro: i report scelti in un solo PDF, con copertina e indice.
    case fascicolo
    /// Una posizione o una proposta, in ogni dettaglio.
    case posizione(String)
    /// Due voci del dossier fianco a fianco.
    case confronto(VoceConfronto, VoceConfronto)
    /// Valutazione di un investimento: prospetto (A4 verticale) o report per il cliente (A4 orizzontale).
    case valutazione(String, report: Bool)
    /// Il portafoglio del consulente: tutti i clienti insieme (solo prospetto, per te).
    case portafoglio
    /// Il riesame annuale del cliente: preparazione dell'incontro di revisione (solo prospetto, per te).
    case riesame
    /// «Un anno insieme»: il racconto dell'anno del cliente (solo report, A4 orizzontale su carta bianca).
    case annoInsieme

    var tipo: TipoProspetto {
        switch self {
        case .resoconto: return .resoconto
        case .sostituzione: return .sostituzione
        case .previdenza: return .previdenza
        case .protezione: return .protezione
        case .obiettivo: return .obiettivo
        case .liquidita: return .liquidita
        case .checkUp: return .checkUp
        case .resistenza: return .resistenza
        case .costi: return .costi
        case .successione: return .successione
        case .patrimonio: return .patrimonio
        case .fascicolo: return .fascicolo
        case .posizione: return .posizione
        case .confronto: return .confronto
        case .valutazione: return .valutazione
        case .portafoglio: return .portafoglio
        case .riesame: return .riesame
        case .annoInsieme: return .annoInsieme
        }
    }
}

enum TipoProspetto: String, CaseIterable, Identifiable {
    case valutazione, resoconto, sostituzione, previdenza, protezione, obiettivo, liquidita, checkUp, resistenza, costi, successione, patrimonio, fascicolo, posizione, confronto, portafoglio, riesame, annoInsieme

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .resoconto: return "Resoconto delle posizioni in essere"
        case .sostituzione: return "Sostituzione o confronto"
        case .previdenza: return "Piano previdenziale"
        case .protezione: return "Protezione della famiglia"
        case .obiettivo: return "Piano obiettivo"
        case .liquidita: return "Capitale in scadenza e liquidità"
        case .checkUp: return "Check-up primo incontro"
        case .resistenza: return "Prova di resistenza"
        case .costi: return "Il costo degli investimenti"
        case .successione: return "Passaggio generazionale"
        case .patrimonio: return "Il patrimonio nel tempo"
        case .fascicolo: return "Fascicolo dell'incontro"
        case .posizione: return "Posizione o proposta"
        case .confronto: return "Confronto"
        case .valutazione: return "Valutazione di un investimento"
        case .portafoglio: return "Il tuo portafoglio"
        case .riesame: return "Riesame annuale"
        case .annoInsieme: return TestiAnnoInsieme.titolo
        }
    }

    var descrizione: String {
        switch self {
        case .sostituzione: return "Restare o cambiare: l'uscita di oggi con penali e imposte, il netto anno per anno delle due strade, il pareggio, tre scenari, costi e caratteristiche. Anche tra due proposte. Prospetto per te, report per il cliente."
        case .previdenza: return "Divario tra reddito desiderato e pensione pubblica, piani portati alla pensione con l'aliquota di allora, risparmio IRPEF dei versamenti, uscite anticipate, versamento che manca. Prospetto per te, report per il cliente."
        case .protezione: return "Fabbisogno caso morte e divario, invalidità e riserva, mappa dei rischi coperti e scoperti, coperture per canale, premi e detrazione del 19%. Prospetto per te, report per il cliente."
        case .obiettivo: return "Un obiettivo del cliente: importo rivalutato alla scadenza, posizioni collegate portate a quella data, quota raggiunta, quattro strade per arrivarci, scenari, quadro di tutti gli obiettivi. Prospetto per te, report per il cliente."
        case .liquidita: return "Capitali in scadenza nei prossimi 12 mesi al netto delle imposte, liquidità, riserva di emergenza, quattro salvadanai per orizzonte legati agli obiettivi, costo di lasciare fermi i soldi. Prospetto per te, report per il cliente."
        case .checkUp: return "Chi è il cliente, la fotografia del patrimonio, il semaforo di sette aree (riserva, famiglia, invalidità, pensione, risparmi, debiti, obiettivi), i bisogni rilevati e da dove partire. Prospetto per te, report per il cliente."
        case .fascicolo: return "I report da consegnare al cliente in un solo PDF: copertina, indice e i documenti scelti, ciascuno con il suo commento. Con la password del cliente, se attiva."
        case .patrimonio: return "Tutte le posizioni insieme per 20 anni: il percorso di oggi e con le proposte, anno per anno e per area, gli obiettivi lungo la strada. Prospetto per te, report per il cliente."
        case .successione: return "Se mancasse oggi, senza testamento: cosa va ai beneficiari (polizze, coperture, previdenza) e cosa agli eredi, con quali tempi, le quote, le imposte e cosa sistemare (beneficiari, convivente, minorenni). Prospetto per te, report per il cliente."
        case .costi: return "Quanto costano le posizioni finanziarie: costo annuo e d'ingresso, costi di quest'anno, quanto tolgono in 10 e 20 anni con il grafico con e senza costi, cosa offrono in cambio, alternative a parità di rischio. Prospetto per te, report per il cliente."
        case .resistenza: return "Il patrimonio in tre anni difficili: mercati in forte calo secondo l'indicatore di rischio, inflazione alta per tre anni, immobili in calo; la perdita confrontata con quella che il profilo sopporta e la parte al riparo. Prospetto per te, report per il cliente."
        case .resoconto: return "Cosa ha il cliente e come sta andando: versato, valore, risultato e rendimento di ogni posizione, ultimi 12 mesi, tutele, debiti, scadenze e costi. Prospetto per te, report per il cliente."
        case .posizione: return "Contratto, costi, proiezione anno per anno nei tre scenari, fonti e pagine dei documenti."
        case .confronto: return "Ipotesi ed esiti a fronte, differenze anno per anno, peso dei costi."
        case .valutazione: return "Il cliente valuta un investimento: incassi netti anno per anno in tre scenari, penali, costi, imposte, confronto con il KID. Prospetto per te, report per il cliente."
        case .portafoglio: return "Tutti i clienti insieme: patrimonio seguito per canale e per area, clienti dal più seguito, scadenze dei prossimi 12 mesi, concentrazione per emittente, proposte per esito. Solo per te."
        case .riesame: return "Per preparare l'incontro di revisione: ordine del giorno, com'è andata ogni posizione rispetto all'atteso, scadenze, obiettivi, aree del check-up, proposte aperte e domande da fare. Per te, con l'incontro da fissare."
        case .annoInsieme: return "Il racconto dell'anno per il cliente: cosa è successo (versamenti, valori di inizio e fine anno, scelte, incontri), gli obiettivi avvicinati, la protezione, i mercati attraversati e cosa ci aspetta. Report per il cliente, su carta bianca."
        }
    }
}

/// Il contenuto di un prospetto, già calcolato: l'impaginazione lo divide in pagine A4.
struct ContenutoProspetto {
    var occhiello: String
    var titolo: String
    var sottotitolo: String
    var cliente: String
    var data = Date()
    /// Canale in evidenza nell'intestazione (nil se il prospetto riguarda entrambi).
    var canale: Canale?
    /// Secondo canale, per i confronti tra Alleanza e indipendente.
    var canaleSecondo: Canale?
    var blocchi: [BloccoProspetto]

    var genere: String { "Prospetto di dettaglio" }
}

/// Una cella di tabella. Il canale si stampa come etichetta (blu Alleanza, cuoio indipendente).
struct CellaProspetto: Hashable {
    var testo: String
    var canale: Canale?
    var forte = false
    var tenue = false

    static func t(_ s: String) -> CellaProspetto { CellaProspetto(testo: s) }
    static func f(_ s: String) -> CellaProspetto { CellaProspetto(testo: s, forte: true) }
    static func n(_ s: String) -> CellaProspetto { CellaProspetto(testo: s, tenue: true) }
    static func c(_ canale: Canale) -> CellaProspetto { CellaProspetto(testo: canale.nomeBreve, canale: canale) }
}

struct ColonnaProspetto: Hashable {
    var titolo: String
    /// Peso relativo della larghezza.
    var peso: Double = 1
    var destra = false
}

struct TabellaProspetto: Hashable {
    var colonne: [ColonnaProspetto]
    var righe: [[CellaProspetto]]
    /// Riga finale in grassetto (totali), ripetuta solo nell'ultima parte.
    var totale: [CellaProspetto]?
    /// Righe da evidenziare (per esempio l'anno della scadenza).
    var evidenzia: Set<Int> = []
}

struct IndicatoreProspetto: Hashable {
    var etichetta: String
    var valore: String
    var nota = ""
}

struct SerieGraficoProspetto: Hashable {
    enum Tono: String { case prudente, atteso, favorevole, primo, secondo }
    var nome: String
    var tono: Tono
    var punti: [PuntoProiezione]
}

extension PuntoProiezione: Hashable {
    func hash(into h: inout Hasher) {
        h.combine(anno)
        h.combine(versato)
        h.combine(valore)
    }
}

enum BloccoProspetto: Hashable {
    /// Titolo di sezione numerato ("01 · Dati del contratto").
    case sezione(numero: String, titolo: String)
    case indicatori([IndicatoreProspetto])
    /// Coppie etichetta e valore, su due colonne.
    case voci([CampoVoce])
    case tabella(TabellaProspetto)
    case grafico([SerieGraficoProspetto])
    case testo(String)
    /// Riquadro di avvertenza (ipotesi predefinite, dati mancanti).
    case avviso(String)
    /// Metodo di calcolo e avvertenze finali, in corpo piccolo.
    case nota(String)
}

struct CampoVoce: Hashable {
    var etichetta: String
    var valore: String
    var canale: Canale? = nil
}

extension BloccoProspetto {
    /// I titoli di sezione non devono restare soli in fondo alla pagina.
    var eTitolo: Bool {
        switch self {
        case .sezione: return true
        default: return false
        }
    }
}

/// Il commento del consulente in un report per il cliente: Vera scrive la bozza dalle cifre del
/// documento, il consulente la rilegge e la modifica. Compare nella pagina dopo la copertina.
struct CommentoReport: Codable, Equatable, Identifiable {
    /// Chiave del documento (vedi `SceltaProspetto.chiaveCommento`).
    var id: String
    var clienteId: String
    var testo: String
    /// Chi ha scritto la prima stesura ("Qwen sul Mac", "Calcoli di Prisma"); nil se scritto a mano.
    var bozzaDi: String?
    var aggiornatoIl = Date()
}

extension SceltaProspetto {
    /// true per i report dei documenti di analisi, che possono avere il commento del consulente.
    var conCommento: Bool {
        switch self {
        case .resoconto(let r), .previdenza(let r), .protezione(let r), .liquidita(let r), .checkUp(let r), .resistenza(let r), .costi(let r), .successione(let r), .patrimonio(let r): return r
        case .sostituzione(_, _, let r), .obiettivo(_, let r): return r
        case .posizione, .confronto, .valutazione, .portafoglio, .riesame, .fascicolo, .annoInsieme: return false
        }
    }

    /// Dove si conserva il commento: lo stesso documento, per lo stesso cliente, ritrova il suo testo.
    func chiaveCommento(cliente: String) -> String? {
        switch self {
        case .resoconto: return "resoconto·\(cliente)"
        case .previdenza: return "previdenza·\(cliente)"
        case .protezione: return "protezione·\(cliente)"
        case .liquidita: return "liquidita·\(cliente)"
        case .checkUp: return "checkUp·\(cliente)"
        case .resistenza: return "resistenza·\(cliente)"
        case .costi: return "costi·\(cliente)"
        case .successione: return "successione·\(cliente)"
        case .patrimonio: return "patrimonio·\(cliente)"
        case .sostituzione(let a, let b, _): return a.isEmpty || b.isEmpty ? nil : "sostituzione·\(a)·\(b)"
        case .obiettivo(let id, _): return id.isEmpty ? nil : "obiettivo·\(id)"
        case .posizione, .confronto, .valutazione, .portafoglio, .riesame, .fascicolo, .annoInsieme: return nil
        }
    }
}

/// Migliorie d'uso 22: le due versioni di un documento, separate dalla scelta. «Per il cliente» è il report
/// (da mostrare e da consegnare), «Per te» il prospetto di dettaglio. Nell'archivio e nelle chiavi dei commenti
/// la scelta resta quella di sempre (`report: Bool` nei casi): qui solo la lettura e il cambio.
enum VersioneProspetto: Hashable {
    case perIlCliente, perTe
}

extension SceltaProspetto {
    /// La versione scelta, nil per i documenti che ne hanno una sola (vedi `soloPer`).
    var versione: VersioneProspetto? {
        switch self {
        case .resoconto(let r), .previdenza(let r), .protezione(let r), .liquidita(let r), .checkUp(let r),
             .resistenza(let r), .costi(let r), .successione(let r), .patrimonio(let r):
            return r ? .perIlCliente : .perTe
        case .sostituzione(_, _, let r), .obiettivo(_, let r), .valutazione(_, let r):
            return r ? .perIlCliente : .perTe
        case .fascicolo, .posizione, .confronto, .portafoglio, .riesame, .annoInsieme:
            return nil
        }
    }

    /// La stessa scelta nell'altra versione (o in questa): i documenti senza la scelta restano come sono.
    func conVersione(_ v: VersioneProspetto) -> SceltaProspetto {
        let r = v == .perIlCliente
        switch self {
        case .resoconto: return .resoconto(report: r)
        case .sostituzione(let a, let b, _): return .sostituzione(a, b, report: r)
        case .previdenza: return .previdenza(report: r)
        case .protezione: return .protezione(report: r)
        case .obiettivo(let id, _): return .obiettivo(id, report: r)
        case .liquidita: return .liquidita(report: r)
        case .checkUp: return .checkUp(report: r)
        case .resistenza: return .resistenza(report: r)
        case .costi: return .costi(report: r)
        case .successione: return .successione(report: r)
        case .patrimonio: return .patrimonio(report: r)
        case .valutazione(let id, _): return .valutazione(id, report: r)
        case .fascicolo, .posizione, .confronto, .portafoglio, .riesame, .annoInsieme: return self
        }
    }

    /// Per i documenti con una versione sola: per chi sono (nil per quelli con la scelta).
    var soloPer: VersioneProspetto? {
        switch self {
        case .posizione, .confronto, .riesame, .portafoglio: return .perTe
        case .annoInsieme, .fascicolo: return .perIlCliente
        case .resoconto, .sostituzione, .previdenza, .protezione, .obiettivo, .liquidita, .checkUp, .resistenza,
             .costi, .successione, .patrimonio, .valutazione:
            return nil
        }
    }

    /// true per le pagine del consulente che portano il timbro «SOLO PER TE» (decisione 22-c: non il portafoglio,
    /// che non si archivia né si mostra mai).
    var conTimbroPerTe: Bool {
        if case .portafoglio = self { return false }
        return versione == .perTe || soloPer == .perTe
    }
}

/// Migliorie d'uso 23: l'elenco dei documenti si legge a colpo d'occhio. Una riga per tipo che dice a cosa serve,
/// le versioni che ha (le etichette «per il cliente» e «per te» sotto la riga) e da dove vengono le cifre (nella
/// scheda «A cosa serve» sopra la pagina). Sono solo testi: valgono ovunque, li mostra il Mac.
extension TipoProspetto {
    /// La riga sotto il nome nell'elenco (decisione 23-b: i quattro del template come sono, gli altri nuovi).
    var inBreve: String {
        switch self {
        case .checkUp: return "La fotografia: cosa c'è e cosa manca"
        case .obiettivo: return "Quanto versare e quando ci arriva"
        case .protezione: return "Quanto servirebbe alla famiglia"
        case .annoInsieme: return "Il riepilogo dell'anno, da consegnare"
        case .resoconto: return "Cosa ha e come sta andando"
        case .patrimonio: return "Tutte le posizioni nei prossimi 20 anni"
        case .resistenza: return "Se arrivassero tre anni difficili"
        case .costi: return "Quanto costano gli investimenti"
        case .successione: return "Cosa succede se venisse a mancare"
        case .liquidita: return "I capitali in scadenza e la riserva"
        case .previdenza: return "Quanto manca alla pensione che vuole"
        case .valutazione: return "Un investimento da valutare, anno per anno"
        case .sostituzione: return "Restare o cambiare"
        case .posizione: return "Una posizione o una proposta in ogni dettaglio"
        case .confronto: return "Due voci a fronte"
        case .riesame: return "Per preparare il riesame"
        case .portafoglio: return "Tutti i clienti insieme"
        case .fascicolo: return "I report scelti in un solo PDF"
        }
    }

    /// Le versioni del documento, nell'ordine delle etichette: per il cliente, poi per te (come `SceltaProspetto.versione`
    /// e `soloPer`, migliorie d'uso 22).
    var versioni: [VersioneProspetto] {
        switch self {
        case .resoconto, .sostituzione, .previdenza, .protezione, .obiettivo, .liquidita, .checkUp, .resistenza, .costi,
             .successione, .patrimonio, .valutazione:
            return [.perIlCliente, .perTe]
        case .fascicolo, .annoInsieme:
            return [.perIlCliente]
        case .posizione, .confronto, .portafoglio, .riesame:
            return [.perTe]
        }
    }

    /// Da dove vengono le cifre: le note che prima stavano sotto la voce scelta, ora nella scheda «A cosa serve».
    var fonti: String {
        switch self {
        case .resoconto:
            return "Tutte le cifre vengono dalle Posizioni del cliente: aggiornale lì e il resoconto si ricompone. Ogni volta che cambi un controvalore, il valore precedente resta nello storico."
        case .sostituzione:
            return "Se la prima voce è in essere, cambiare vuol dire chiuderla oggi (penale, bollo, imposte) e reinvestire il netto. Le due strade ricevono gli stessi versamenti futuri. Tra due fondi pensione è un trasferimento senza imposte."
        case .previdenza:
            return "Età di pensione, reddito desiderato, pensione pubblica e anni di integrazione vengono dall'Analisi 360 (area Previdenza); il reddito lordo annuo dal profilo del cliente; i piani dalle Posizioni."
        case .protezione:
            return "Fabbisogno, anni di sostegno, entrate sostitutive e riserva vengono dall'Analisi 360 (area Protezione); la famiglia dal dossier del cliente; le coperture dalle Posizioni."
        case .obiettivo:
            return TestiProspettiObiettivo.dove
        case .liquidita:
            return "Capitali in scadenza e conti dalle Posizioni; fabbisogno mensile e mesi di riserva dall'Analisi 360 (area Protezione); i salvadanai seguono gli Obiettivi del cliente."
        case .checkUp:
            return "Anagrafica e famiglia dal dossier, patrimonio dalle Posizioni, ipotesi dall'Analisi 360, bisogni dal profilo dei bisogni. Più dati si raccolgono, meno semafori restano grigi."
        case .resistenza:
            return "Posizioni in essere e loro indicatore di rischio (SRI) dalle Posizioni; propensione al rischio dal profilo del cliente. Lo stesso calcolo del pannello in Posizioni."
        case .costi:
            return "Costi dalle Posizioni (e dai KID letti in Documenti); alternative dal catalogo Prodotti, con la stessa area e lo stesso indicatore di rischio. Lo stesso calcolo del pannello in Posizioni."
        case .successione:
            return "Posizioni e beneficiari dalle Posizioni; famiglia e stato civile dal dossier del cliente. Lo stesso calcolo del pannello in Posizioni."
        case .patrimonio:
            return "Posizioni e proposte dalle Posizioni, obiettivi con una data dagli Obiettivi del cliente. Lo stesso calcolo del pannello in Posizioni."
        case .fascicolo:
            return "Ogni report porta il suo commento, se l'hai scritto. Salvando il PDF vale la password del cliente, come per ogni documento."
        case .posizione:
            return "Contratto e costi dalla posizione; proiezioni con le ipotesi di calcolo di Lucy; fonti e pagine dai documenti letti."
        case .confronto:
            return "Le stesse scelte valgono nel Confronto: il prospetto riporta ciò che vedi lì, con il dettaglio anno per anno."
        case .valutazione:
            return "Condizioni del contratto dalla scheda prodotto (parti, penali, costi, KID); ipotesi e testi si modificano nella valutazione."
        case .portafoglio:
            return "Le cifre della vista Portafoglio di Posizioni. Non si archivia nei Documenti di un cliente: salvalo in PDF dove preferisci."
        case .riesame:
            return "Incontri dall'Agenda, posizioni con l'atteso, obiettivi, aree del check-up e proposte aperte del cliente."
        case .annoInsieme:
            return "Valori di inizio anno dallo storico delle Posizioni (ogni controvalore aggiornato resta nello storico), incontri dall'Agenda, obiettivi dal dossier, protezione dall'Analisi 360. Nessuna cifra scritta a mano."
        }
    }
}

/// Migliorie d'uso 23: i documenti raggruppati per momento (decisione 23-a), nell'ordine dell'elenco. «Per te» (il
/// portafoglio) non si mostra in modalità cliente. Il fascicolo ha la sua card sotto i gruppi.
enum ElencoProspetti {
    static let gruppi: [(titolo: String, tipi: [TipoProspetto])] = [
        (TestiElencoProspetti.primoIncontro, [.checkUp, .resoconto, .patrimonio]),
        (TestiElencoProspetti.analisi, [.resistenza, .costi, .successione, .liquidita, .previdenza, .protezione, .obiettivo]),
        (TestiElencoProspetti.proposta, [.valutazione, .sostituzione, .posizione, .confronto]),
        (TestiElencoProspetti.fineAnno, [.annoInsieme, .riesame]),
        (TestiElencoProspetti.perTe, [.portafoglio]),
    ]

    /// Il gruppo che resta fuori in modalità cliente.
    static let gruppoPerTe = TestiElencoProspetti.perTe

    /// L'ordine di tutte le voci, dall'alto in basso (con il fascicolo in fondo): dice da che parte gira la pagina.
    static let ordine: [TipoProspetto] = gruppi.flatMap { $0.tipi } + [.fascicolo]
}

/// I testi dell'elenco dei documenti (migliorie d'uso 23).
enum TestiElencoProspetti {
    static let primoIncontro = "Primo incontro"
    static let analisi = "Le analisi"
    static let proposta = "Per una proposta"
    static let fineAnno = "Fine anno"
    static let perTe = "Per te"
    static let etichettaCliente = "per il cliente"
    static let etichettaPerTe = "per te"
    static let incontroOggi = "per l'incontro di oggi"
    static let aCosaServe = "A cosa serve"
    static let daDove = "Da dove vengono le cifre"

    static func etichetta(_ v: VersioneProspetto) -> String {
        v == .perIlCliente ? etichettaCliente : etichettaPerTe
    }
}
