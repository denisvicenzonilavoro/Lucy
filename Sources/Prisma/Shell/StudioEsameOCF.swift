#if os(macOS)
import AppKit
#endif
import SwiftUI
import UniformTypeIdentifiers

// Studio › Esame OCF (Orizzonte giro 6, Design/template-novita-specifica.md §11, template `quizHTML()`):
//
//   ┌ LA TUA PREPARAZIONE ─────────────┐ ┌ MERCATO FINANZIARIO              domanda 1 di 16 ┐
//   │ (◯ 70%)  Esame OCF               │ │ Che cos'è il KID?                                 │
//   │          9 domande da ripassare  │ │ (A) …  (B) …  (C) …  (D) …                        │
//   │          Il punto più debole: …  │ │ ┌ Giusto. … ◎ Apri il KID di Giulia ┐             │
//   │          [Imposta la data …]     │ │                                                   │
//   │ materia ............... 80% ▬▬▬ │ │ Ripasso a intervalli …  Importa…  Prossima ›      │
//   └──────────────────────────────────┘ └───────────────────────────────────────────────────┘
//
// - Le percentuali, il ripasso e il caso vero vengono da MotoreOCF sull'archivio (`DatiPrisma.ocf`); le domande le
//   importa il consulente (CSV o JSON, Design/ocf-formato.md). Prisma ne ha solo sette di esempio, scritte apposta:
//   quando ci sono la card lo dice («dati di prova» e la nota «scritte per prova, non dal manuale»).
// - La sessione di oggi (coda, domanda mostrata, risposta scelta) è uno stato della vista (`SessioneEsameOCF`):
//   le risposte vanno subito nell'archivio (`StatoShell.rispondiOCF`), la coda si ricalcola solo quando serve.
// - La vista osserva lo stato da sé: una risposta non cambia la `ChiaveVista` (l'OCF non entra nei calcoli in cache).
// - Movimento: cascata delle card, anello e barre che si riempiono, numeri che si contano, colori delle opzioni in
//   0,30 s, tremolio della sbagliata, spiegazione da y +10, domanda nuova da destra. «Riduci movimento»: niente
//   cascata, tremolio né spostamenti, dissolvenza di 0,15 s; istantanee: tutto fermo nello stato finale.
// - Tastiera (Mac, solo con Studio davanti): A-D o 1-4 rispondono, Invio o → fanno ciò che dice il pulsante del piede.
// - Migliorie d'uso 55 (solo Mac): il piede dice «Salta» finché non si risponde, poi «Prossima domanda ›» o, all'ultima,
//   «Vedi com’è andata ›»; la saltata non torna più nella coda di oggi; il giro (solo in memoria, `SessioneEsameOCF.esiti`)
//   chiude con il bilancio (`BilancioOCFVista`); dopo «Salva» della data l'avviso del ritmo (`MotoreOCF.domandeAlGiorno`).
// Valori in DesignSystem/Apple/Tema.Apple+OCF.swift.

// MARK: - Testi

enum TestiEsameOCF {
    static let preparazione = "La tua preparazione"
    static let titolo = "Esame OCF"
    static let datiDiProva = "dati di prova"
    static let nessunaDomanda = "Nessuna domanda ancora"
    static let impostaData = "Imposta la data dell’esame"
    /// Migliorie d'uso 55: la nota dice che le materie si toccano.
    static let notaManuale = "Le domande vengono dal tuo manuale. Tocca una materia per ripassare quella."
    static let notaEsempio = "Tra le domande ci sono quelle di esempio, scritte per prova da Prisma: non vengono dal "
        + "manuale né da quiz ufficiali. Importa le tue per allenarti davvero."
    static let giusto = "Giusto."
    static let sbagliato = "Non proprio: torna tra un giorno."
    static let prossima = "Prossima domanda ›"
    /// Migliorie d'uso 55: il pulsante del piede prima di rispondere e all'ultima domanda del giro.
    static let salta = "Salta"
    static let vediComeEAndata = "Vedi com’è andata ›"
    /// Il bilancio del giro.
    static let ripassoDiOggi = "Il ripasso di oggi"
    static let nessunaRisposta = "Nessuna risposta, per ora."
    static let ripassaDebole = "Ripassa il punto debole"
    static let ricomincia = "Ricomincia"
    static let fatta = "Fatta"
    static let tornaDomani = "Torna domani"
    static let saltataTornaDomani = "Saltata: torna domani"
    static let importa = "Importa domande…"
    static let provaEsempio = "Prova con le domande di esempio"
    static let modello = "Scarica il modello CSV"
    static let nomeModello = "domande-ocf-modello.csv"
    static let vuotoTitolo = "Importa le domande del tuo manuale"
    static let vuotoTesto = "Un file CSV o JSON: una domanda per riga, con le quattro risposte, quella corretta e, se "
        + "vuoi, la spiegazione. Le domande restano solo su questo Mac, nel tuo archivio e nei tuoi backup."
    static let vuotoNota = "Le domande di esempio sono sette, scritte per prova da Prisma: non vengono dal manuale."
    static let finitoTitolo = "Per oggi il ripasso è finito."
    static let altreNuove = "Altre domande nuove ›"
    static let nessunaNuova = "Hai già visto tutte le domande: importane altre per continuare."
    static let riepilogoTitolo = "Prima di importare"
    static let nienteDaImportare = "Niente di nuovo da importare"
    static let conferma = "Importa"
    static let annulla = "Annulla"
    static let chiudi = "Chiudi"
    static let nuove = "domande nuove"
    static let aggiornate = "aggiornate"
    static let scartate = "scartate"
    static let erroreTitolo = TestiOCF.fileIlleggibile
    static let titoloData = "La data dell’esame"
    static let salva = "Salva"
    static let togliData = "Togli la data"
    static let tutteLeMaterie = "Torna a tutte le materie"
    static let soloMateriaAiuto = "Allenati solo su questa materia"
    static let materiaSenzaDomande = "Nessuna domanda di questa materia"
    static let pannelloPulsante = "Leggi il file"
    static let pannelloMessaggio = "Scegli un file di domande (CSV o JSON): prima di importare vedrai il riepilogo."

    private static let formatoData = Formati.formato("d MMMM yyyy")

    /// «9 domande da ripassare oggi».
    static func daRipassare(_ n: Int) -> String {
        switch n {
        case 0: return "Nessuna domanda da ripassare oggi"
        case 1: return "1 domanda da ripassare oggi"
        default: return "\(n) domande da ripassare oggi"
        }
    }

    /// «240 domande pronte».
    static func pronte(_ n: Int) -> String { n == 1 ? "1 domanda pronta" : "\(n) domande pronte" }

    /// «Il punto più debole: diritto privato e commerciale» (iniziale minuscola, come il template).
    static func puntoDebole(_ nome: String) -> String {
        guard let primo = nome.first else { return "" }
        return "Il punto più debole: " + primo.lowercased() + String(nome.dropFirst())
    }

    /// Il pulsante della data: «Esame il 18 febbraio 2027 · mancano 107 giorni».
    static func esame(_ data: Date, giorni: Int?) -> String {
        let il = formatoData.string(from: data)
        guard let g = giorni else { return "Esame il \(il)" }
        switch g {
        case 0: return "L’esame è oggi"
        case 1: return "Esame il \(il) · manca 1 giorno"
        case ..<0: return "Esame del \(il) · già passato"
        default: return "Esame il \(il) · mancano \(g) giorni"
        }
    }

    /// «Ancora poche risposte (3 di 5)».
    static func pocheRisposte(_ r: Int) -> String { "Ancora poche risposte (\(r) di \(MotoreOCF.minimoRisposte))" }

    /// «Solo: Diritto tributario».
    static func soloMateria(_ nome: String) -> String { "Solo: \(nome)" }

    /// «domanda 1 di 16».
    static func contatore(_ n: Int, di m: Int) -> String { "domanda \(n) di \(m)" }

    /// Gli intervalli delle giuste, dal motore: «3, 7, 14 e 30».
    private static var intervalliGiuste: String {
        let giuste = MotoreOCF.intervalli.dropFirst().map { String($0) }
        return giuste.count > 1 ? giuste.dropLast().joined(separator: ", ") + " e " + (giuste.last ?? "") : giuste.joined()
    }

    /// La nota del piede, con gli intervalli veri del motore.
    static var piede: String {
        "Ripasso a intervalli: le sbagliate tornano domani, le giuste tra \(intervalliGiuste) giorni"
    }

    /// La regola del bilancio, con gli intervalli veri del motore (mai scritti a mano).
    static var tornano: String {
        "Le sbagliate tornano domani, le saltate restano da fare; le giuste tornano tra \(intervalliGiuste) giorni."
    }

    /// Il titolo del bilancio: «Tutte giuste.», «1 giusta su 6.», «4 giuste su 6.»; senza risposte (tutte saltate)
    /// «Nessuna risposta, per ora.».
    static func bilancio(giuste: Int, di totale: Int, risposte: Int) -> String {
        if risposte == 0 { return nessunaRisposta }
        if giuste == totale { return "Tutte giuste." }
        return giuste == 1 ? "1 giusta su \(totale)." : "\(giuste) giuste su \(totale)."
    }

    /// «Punto debole: diritto tributario» (iniziale minuscola).
    static func puntoDeboleBreve(_ nome: String) -> String {
        guard let primo = nome.first else { return "" }
        return "Punto debole: " + primo.lowercased() + String(nome.dropFirst())
    }

    /// L'avviso dopo aver salvato la data dell'esame: «Mancano 90 giorni: 3 domande al giorno per arrivare pronto».
    static func ritmo(giorni: Int, domande: Int) -> String {
        let mancano = giorni == 1 ? "Manca 1 giorno" : "Mancano \(giorni) giorni"
        let quante = domande == 1 ? "1 domanda" : "\(domande) domande"
        return "\(mancano): \(quante) al giorno per arrivare pronto"
    }

    /// «Le prossime tornano domani: 6 domande.»
    static func domani(_ n: Int) -> String {
        switch n {
        case 0: return "Domani non torna nessuna domanda da ripassare."
        case 1: return "Le prossime tornano domani: 1 domanda."
        default: return "Le prossime tornano domani: \(n) domande."
        }
    }

    /// «Riga 12: manca la risposta corretta».
    static func scartata(_ r: RigaScartataOCF, daCSV: Bool) -> String {
        (daCSV ? "Riga" : "Domanda") + " \(r.riga): \(r.motivo)"
    }

    static func fonte(_ f: String) -> String { "Da: \(f)" }

    /// Il modello CSV da scaricare: l'intestazione e le domande di esempio di Prisma (scritte per prova).
    static func modelloCSV(_ i: ImportazioneOCF?) -> String {
        let intestazione = "id;materia;domanda;a;b;c;d;corretta;spiegazione;fonte;caso"
        let lettere = Tema.Apple.Studio.OCF.Opzione.lettere
        func campo(_ s: String?) -> String {
            let t = s ?? ""
            guard t.contains(";") || t.contains("\"") || t.contains("\n") else { return t }
            return "\"" + t.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        let nomi = Dictionary((i?.materieNuove ?? []).map { ($0.id, $0.nome) }, uniquingKeysWith: { a, _ in a })
        let righe = (i?.nuove ?? []).map { d -> String in
            let corretta = d.corretta < lettere.count ? lettere[d.corretta] : ""
            let campi: [String] = [d.id, nomi[d.materia] ?? d.materia, d.testo] + d.risposte
                + [corretta, d.spiegazione ?? "", d.fonte ?? "", d.caso?.rawValue ?? ""]
            return campi.map(campo).joined(separator: ";")
        }
        return "\u{FEFF}" + ([intestazione] + righe).joined(separator: "\r\n") + "\r\n"
    }
}

// MARK: - La sessione di oggi

/// L'esito di una domanda nel giro di oggi (migliorie d'uso 55): vive solo nella sessione, mai nell'archivio (le
/// risposte ci vanno già una per una con `rispondiOCF`; le saltate non scrivono nulla).
struct EsitoGiroOCF: Equatable {
    enum Tipo: Equatable { case giusta, sbagliata, saltata }
    let domandaId: String
    let esito: Tipo
}

/// La sessione di allenamento in corso: la coda delle domande di oggi, quella mostrata e la risposta scelta.
/// Vive con la scheda; l'archivio (risposte, data dell'esame) resta in `StatoShell.dati.ocf`.
final class SessioneEsameOCF: ObservableObject {
    /// Gli id delle domande di oggi, nell'ordine (prima il ripasso, poi le nuove).
    @Published var coda: [String] = []
    @Published var indice = 0
    /// La risposta scelta per la domanda mostrata (nil = ancora aperta).
    @Published var scelta: Int?
    /// La materia su cui ci si allena (nil = tutte).
    @Published var materia: String?
    /// Cambia a ogni domanda mostrata: la chiave della transizione (anche quando torna una domanda saltata).
    @Published var giro = 0
    /// Fase del tremolio della risposta sbagliata (0 → 1).
    @Published var tremolio: CGFloat = 0
    /// Il riepilogo di un file letto, da confermare.
    @Published var importazione: ImportazioneOCF?
    /// L'errore dell'ultimo file letto.
    @Published var errore: String?
    /// Il riquadro della data dell'esame è aperto.
    @Published var riquadroData = false
    @Published var bozzaData = Date()
    /// Migliorie d'uso 55 (Mac): gli esiti del giro, nell'ordine in cui si è risposto o saltato; li azzera `avvia`.
    /// A coda finita, se non è vuoto, la card mostra il bilancio.
    @Published var esiti: [EsitoGiroOCF] = []

    /// Sul Mac il giro chiude con il bilancio e «Salta» non rimette la domanda in coda; iPhone e iPad restano come
    /// prima (la saltata torna in fondo alla coda, a fine coda «Per oggi il ripasso è finito.»).
    #if os(macOS)
    static let conBilancio = true
    #else
    static let conBilancio = false
    #endif

    /// La domanda mostrata è l'ultima della coda di oggi.
    var ultimaDelGiro: Bool { !coda.isEmpty && indice == coda.count - 1 }

    /// La domanda mostrata (nil = coda finita).
    var idAttuale: String? { indice < coda.count ? coda[indice] : nil }

    /// La preparazione e le domande che tornano domani dell'ultimo archivio visto, con il giorno: un passo della sessione
    /// (domanda dopo, tremolio, filtro, data nel calendario) ridisegna la scheda ma non le rifà. Non pubblicate: scriverle
    /// dal body non ridisegna niente. Confrontare l'archivio costa poco quando non cambia (gli array condividono la memoria).
    private var preparazioneFatta: (archivio: ArchivioOCF, giorno: Date, valore: PreparazioneOCF)?
    private var domaniFatto: (archivio: ArchivioOCF, giorno: Date, valore: Int)?

    /// `MotoreOCF.preparazione` per questo archivio e per oggi (dipende solo dal giorno, non dall'ora).
    func preparazione(_ a: ArchivioOCF, oggi: Date, cal: Calendar) -> PreparazioneOCF {
        let giorno = cal.startOfDay(for: oggi)
        if let f = preparazioneFatta, f.giorno == giorno, f.archivio == a { return f.valore }
        let p = MotoreOCF.preparazione(a, oggi: oggi, cal: cal)
        preparazioneFatta = (a, giorno, p)
        return p
    }

    /// Quante domande (ancora nell'archivio) tornano domani nel ripasso, per la coda finita. Le domande si cercano in un
    /// insieme, non una per una nell'elenco.
    func tornanoDomani(_ a: ArchivioOCF, oggi: Date = Date(), cal: Calendar) -> Int {
        let giorno = cal.startOfDay(for: oggi)
        if let f = domaniFatto, f.giorno == giorno, f.archivio == a { return f.valore }
        let domani = cal.date(byAdding: .day, value: 1, to: giorno) ?? oggi
        let presenti = Set(a.domande.map(\.id))
        let n = MotoreOCF.ripassi(a.risposte, cal: cal).values
            .filter { cal.isDate($0.prossima, inSameDayAs: domani) && presenti.contains($0.domandaId) }.count
        domaniFatto = (a, giorno, n)
        return n
    }

    /// La sessione iniziale (e quella chiesta da una scena delle istantanee).
    static func iniziale(_ s: StatoShell) -> SessioneEsameOCF {
        let x = SessioneEsameOCF()
        x.avvia(s.dati.ocf)
        guard let r = RichiestaIstantaneaOCF.per(s) else { return x }
        if let p = r.domanda {
            x.coda.removeAll { $0 == p }
            x.coda.insert(p, at: 0)
        }
        x.scelta = r.scelta
        x.riquadroData = r.riquadroData
        x.bozzaData = s.dati.ocf.dataEsame ?? x.bozzaData
        x.importazione = r.importazione
        // Migliorie d'uso 55: un giro già fatto (solo nella memoria della scena, l'archivio non cambia). Con la domanda
        // chiesta, il giro la precede e lei è l'ultima della coda; senza, la coda è finita e si vede il bilancio.
        if !r.esiti.isEmpty {
            let fatte = r.esiti.map(\.domandaId)
            if let p = r.domanda {
                x.coda = fatte.filter { $0 != p } + [p]
                x.indice = x.coda.count - 1
            } else {
                x.coda = fatte
                x.indice = fatte.count
            }
            x.esiti = r.esiti
        }
        return x
    }

    /// Ricalcola la coda di oggi: il ripasso scaduto e le nuove (`nuove` nil = quelle del giorno). Con una materia
    /// scelta, il suo ripasso e tutte le sue domande mai viste.
    func avvia(_ a: ArchivioOCF, nuove: Int? = nil, oggi: Date = Date(), cal: Calendar = .current) {
        let elenco: [DomandaOCF]
        if let m = materia {
            elenco = MotoreOCF.domandeDiOggi(a, oggi: oggi, cal: cal, nuove: a.domande.count).filter { $0.materia == m }
        } else {
            elenco = MotoreOCF.domandeDiOggi(a, oggi: oggi, cal: cal, nuove: nuove)
        }
        coda = elenco.map(\.id)
        indice = 0
        scelta = nil
        tremolio = 0
        esiti = []
        giro += 1
    }

    /// Annota l'esito di una risposta data alla domanda mostrata (la risposta va nell'archivio da `rispondiOCF`).
    func annota(_ domandaId: String, giusta: Bool) {
        guard !esiti.contains(where: { $0.domandaId == domandaId }) else { return }
        esiti.append(EsitoGiroOCF(domandaId: domandaId, esito: giusta ? .giusta : .sbagliata))
    }

    /// Passa alla domanda seguente. Sul Mac (migliorie d'uso 55) una domanda saltata, senza risposta, si segna come
    /// saltata nel giro e non torna più nella coda di oggi: non scrive nulla nell'archivio, quindi torna da sé (un
    /// ripasso scaduto resta scaduto, una nuova resta fra le nuove del giorno) con «Ricomincia» o domani. Su iPhone e
    /// iPad la saltata torna in fondo alla coda di oggi, come prima.
    func avanti() {
        if Self.conBilancio {
            if scelta == nil, let id = idAttuale, !esiti.contains(where: { $0.domandaId == id }) {
                esiti.append(EsitoGiroOCF(domandaId: id, esito: .saltata))
            }
        } else if scelta == nil, let id = idAttuale, coda.count > 1 {
            coda.append(id)
        }
        indice += 1
        scelta = nil
        tremolio = 0
        giro += 1
    }
}

// MARK: - Richiesta delle istantanee

/// Lo stato della scheda che una scena delle istantanee chiede (Prisma --istantanee): la prima domanda, la risposta
/// già scelta, il riquadro della data aperto, un riepilogo d'importazione. Vale solo per lo stato della scena
/// (riferimento debole), come `RichiestaIstantaneaTrack`. Non registra nessuna risposta nell'archivio.
final class RichiestaIstantaneaOCF {
    nonisolated(unsafe) private static var attuale: RichiestaIstantaneaOCF?

    private weak var stato: StatoShell?
    let domanda: String?
    let scelta: Int?
    let riquadroData: Bool
    let importazione: ImportazioneOCF?
    /// Migliorie d'uso 55: gli esiti di un giro già fatto (vuoto = nessun giro).
    let esiti: [EsitoGiroOCF]

    private init(stato: StatoShell, domanda: String?, scelta: Int?, riquadroData: Bool, importazione: ImportazioneOCF?,
                 esiti: [EsitoGiroOCF]) {
        self.stato = stato
        self.domanda = domanda
        self.scelta = scelta
        self.riquadroData = riquadroData
        self.importazione = importazione
        self.esiti = esiti
    }

    static func chiedi(_ s: StatoShell, domanda: String? = nil, scelta: Int? = nil, riquadroData: Bool = false,
                       importazione: ImportazioneOCF? = nil, esiti: [EsitoGiroOCF] = []) {
        attuale = RichiestaIstantaneaOCF(stato: s, domanda: domanda, scelta: scelta, riquadroData: riquadroData,
                                         importazione: importazione, esiti: esiti)
    }

    static func per(_ s: StatoShell) -> RichiestaIstantaneaOCF? {
        guard let r = attuale, r.stato === s else { return nil }
        return r
    }
}

// MARK: - La scheda

struct EsameOCFStudioVista: View {
    private let stato: StatoShell
    /// La base della cascata (0,14 all'apertura, 0 dopo un cambio di scheda) e il ritardo dell'anello.
    let base: Double
    let ritardoAnelli: Double
    @StateObject private var sessione: SessioneEsameOCF

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    private typealias D = Tema.Apple.Studio.OCF.Disposizione
    private typealias M = Tema.Apple.Studio.OCF.Moto

    init(stato: StatoShell, base: Double, ritardoAnelli: Double) {
        self.stato = stato
        self.base = base
        self.ritardoAnelli = ritardoAnelli
        _sessione = StateObject(wrappedValue: SessioneEsameOCF.iniziale(stato))
    }

    var body: some View {
        let a = stato.dati.ocf
        let cal = Calendar.current
        let oggi = Date()
        // Dalla sessione: si rifà solo con un archivio nuovo (una risposta, un'importazione) o un giorno nuovo
        let prep = sessione.preparazione(a, oggi: oggi, cal: cal)
        let prova = a.domande.contains { $0.origine == .esempio }
        return GeometryReader { geo in
            if geo.size.width < D.larghezzaColonna {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: D.spazio) {
                        preparazione(a, prep: prep, prova: prova, scorre: false)
                        domanda(a, prep: prep, scorre: false)
                            .frame(minHeight: D.altezzaMinimaDomanda, alignment: .top)
                    }
                    .frame(width: geo.size.width, alignment: .topLeading)
                }
            } else {
                HStack(alignment: .top, spacing: D.spazio) {
                    preparazione(a, prep: prep, prova: prova, scorre: true)
                        .frame(width: D.larghezzaPreparazione)
                        .frame(maxHeight: .infinity)
                    domanda(a, prep: prep, scorre: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            }
        }
        // Un archivio che cambia da fuori (backup ripristinato, esempi aggiunti) con la coda finita: si riparte
        .onChange(of: a.domande.count) { _ in
            if sessione.idAttuale == nil && sessione.importazione == nil { sessione.avvia(stato.dati.ocf) }
        }
    }

    private func preparazione(_ a: ArchivioOCF, prep: PreparazioneOCF, prova: Bool, scorre: Bool) -> some View {
        CardPreparazioneOCF(stato: stato, sessione: sessione, archivio: a, prep: prep, prova: prova, scorre: scorre,
                            ritardoAnelli: ritardoAnelli, scegliMateria: scegliMateria)
            .entrataCascata(0, base: base)
    }

    private func domanda(_ a: ArchivioOCF, prep: PreparazioneOCF, scorre: Bool) -> some View {
        CardDomandaOCFVista(stato: stato, sessione: sessione, archivio: a, prep: prep, scorre: scorre)
            .entrataCascata(1, base: base)
    }

    /// Un clic sulla materia: ci si allena solo su quella; un secondo clic torna a tutte.
    private func scegliMateria(_ id: String) {
        let cambia = {
            sessione.materia = sessione.materia == id ? nil : id
            sessione.avvia(stato.dati.ocf)
        }
        if istantanea {
            cambia()
        } else {
            withAnimation(calmo ? M.calma : M.entrataDomanda, cambia)
        }
    }
}

// MARK: - Card 1 · La tua preparazione

private struct CardPreparazioneOCF: View {
    let stato: StatoShell
    @ObservedObject var sessione: SessioneEsameOCF
    let archivio: ArchivioOCF
    let prep: PreparazioneOCF
    let prova: Bool
    let scorre: Bool
    let ritardoAnelli: Double
    let scegliMateria: (String) -> Void

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    private typealias C = Tema.Apple.Studio.OCF.Card
    private typealias P = Tema.Apple.Studio.OCF.Preparazione
    private typealias K = Tema.Apple.Studio.OCF.Colore

    var body: some View {
        Group {
            if scorre {
                ScrollView(.vertical, showsIndicators: false) { contenuto }
            } else {
                contenuto
            }
        }
        .frame(maxWidth: .infinity, maxHeight: scorre ? .infinity : nil, alignment: .topLeading)
        .superficieApple(C.superficie, raggio: C.raggio)
    }

    private var contenuto: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: C.spazioProva) {
                Text(TestiEsameOCF.preparazione)
                    .carattereApple(C.etichetta)
                    .foregroundColor(C.coloreEtichetta)
                if prova {
                    Text(TestiEsameOCF.datiDiProva)
                        .carattereApple(C.prova)
                        .foregroundColor(C.coloreProva)
                }
            }
            HStack(alignment: .center, spacing: P.spazioAnello) {
                Anello(frazione: (prep.complessiva ?? 0) / 100, colore: K.anello, misura: P.anello,
                       spessore: P.spessoreAnello, ritardo: ritardoAnelli) {
                    centro
                }
                riepilogo
            }
            .padding(.top, P.anelloSopra)
            materie
                .padding(.top, P.materieSopra)
            if sessione.riquadroData {
                RiquadroDataEsameOCF(stato: stato, sessione: sessione, archivio: archivio)
                    .padding(.top, P.riquadroSopra)
                    .transition(calmo ? .opacity : AnyTransition.offset(y: Tema.Apple.Studio.OCF.Moto.spostamentoSpiegazione)
                        .combined(with: .opacity))
            }
            Text(prova ? TestiEsameOCF.notaEsempio : TestiEsameOCF.notaManuale)
                .carattereApple(C.nota)
                .foregroundColor(C.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, P.notaSopra)
        }
        .padding(C.paddingPreparazione)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    @ViewBuilder private var centro: some View {
        if let c = prep.complessiva {
            NumeroCheConta(c, formato: .percentuale)
                .carattereApple(P.centro)
                .foregroundColor(P.coloreCentro)
        } else {
            Text("—")
                .carattereApple(P.centro)
                .foregroundColor(P.coloreCentro)
        }
    }

    private var riepilogo: some View {
        let riga: String
        if prep.domandeDisponibili == 0 {
            riga = TestiEsameOCF.nessunaDomanda
        } else if archivio.risposte.isEmpty {
            riga = TestiEsameOCF.pronte(prep.domandeDisponibili)
        } else {
            riga = TestiEsameOCF.daRipassare(prep.daRipassareOggi)
        }
        return VStack(alignment: .leading, spacing: P.spazioRighe) {
            Text(TestiEsameOCF.titolo)
                .carattereApple(P.titolo)
                .foregroundColor(P.coloreTitolo)
            Text(riga)
                .carattereApple(P.riga)
                .foregroundColor(P.coloreRiga)
                .fixedSize(horizontal: false, vertical: true)
            if let d = prep.puntoDebole {
                Text(TestiEsameOCF.puntoDebole(d.nome))
                    .carattereApple(P.riga)
                    .foregroundColor(P.coloreRiga)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button(action: apriData) {
                Text(archivio.dataEsame.map { TestiEsameOCF.esame($0, giorni: prep.giorniAllEsame) } ?? TestiEsameOCF.impostaData)
                    .lineLimit(1)
            }
            .buttonStyle(.apple)
            .padding(.top, P.pulsanteSopra)
        }
    }

    private var materie: some View {
        let m = P.paddingMateria
        return VStack(alignment: .leading, spacing: max(0, P.spazioMaterie - m.top - m.bottom)) {
            ForEach(Array(prep.materie.enumerated()), id: \.element.id) { i, voce in
                RigaMateriaOCF(voce: voce, indice: i, scelta: sessione.materia == voce.materia.id) {
                    scegliMateria(voce.materia.id)
                }
            }
        }
        .padding(.horizontal, -m.leading)
        .padding(.vertical, -m.top)
    }

    private func apriData() {
        let cal = Calendar.current
        let domani = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date())) ?? Date()
        let cambia = {
            if !sessione.riquadroData { sessione.bozzaData = max(archivio.dataEsame ?? domani, domani) }
            sessione.riquadroData.toggle()
        }
        if istantanea {
            cambia()
        } else {
            withAnimation(calmo ? Tema.Apple.Studio.OCF.Moto.calma : Tema.Apple.Studio.OCF.Moto.riquadro, cambia)
        }
    }
}

/// Una materia: nome, percentuale e barra nel colore della fascia. Un clic allena solo su quella.
private struct RigaMateriaOCF: View {
    let voce: PreparazioneMateriaOCF
    let indice: Int
    let scelta: Bool
    let azione: () -> Void

    /// Migliorie d'uso 55 (Mac): il puntatore è sulla riga (fondo tenue e cursore a mano).
    @State private var sopra = false

    private typealias P = Tema.Apple.Studio.OCF.Preparazione
    private typealias K = Tema.Apple.Studio.OCF.Colore

    var body: some View {
        let fascia = MotoreOCF.fascia(voce.percentuale)
        let aiuto: String
        if voce.domande == 0 {
            aiuto = TestiEsameOCF.materiaSenzaDomande
        } else if voce.percentuale == nil {
            aiuto = TestiEsameOCF.pocheRisposte(voce.risposte)
        } else {
            aiuto = scelta ? TestiEsameOCF.tutteLeMaterie : TestiEsameOCF.soloMateriaAiuto
        }
        return Button(action: azione) {
            VStack(alignment: .leading, spacing: P.barraSopra) {
                HStack(alignment: .firstTextBaseline, spacing: P.spazioRiquadro) {
                    Text(voce.materia.nome)
                        .carattereApple(P.materia)
                        .foregroundColor(P.coloreMateria)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    percentuale
                        .carattereApple(P.percentuale)
                        .foregroundColor(P.coloreMateria)
                }
                BarraPiena(frazione: (voce.percentuale ?? 0) / 100, colore: Tema.Apple.Studio.OCF.colore(fascia),
                           indice: indice, altezza: P.barra, raggio: P.raggioBarra)
            }
            .padding(P.paddingMateria)
            .background(
                RoundedRectangle(cornerRadius: P.raggioMateria, style: .continuous)
                    .fill(scelta ? K.materiaScelta : (sopra ? P.fondoSopra : Color.clear))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(voce.domande == 0)
        #if os(macOS)
        .onHover { dentro in
            let attivo = dentro && voce.domande > 0
            guard attivo != sopra else { return }
            sopra = attivo
            if attivo { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
        .onDisappear {
            if sopra {
                NSCursor.pop()
                sopra = false
            }
        }
        #endif
        .help(aiuto)
        .accessibilityHint(Text(aiuto))
    }

    @ViewBuilder private var percentuale: some View {
        if let p = voce.percentuale {
            NumeroCheConta(p, formato: .percentuale, indice: indice + 1)
        } else {
            Text("—")
        }
    }
}

/// Il riquadro della data dell'esame: il calendario (da domani in poi), «Salva», «Togli la data», «Annulla».
private struct RiquadroDataEsameOCF: View {
    let stato: StatoShell
    @ObservedObject var sessione: SessioneEsameOCF
    let archivio: ArchivioOCF

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    private typealias P = Tema.Apple.Studio.OCF.Preparazione

    var body: some View {
        let cal = Calendar.current
        let domani = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date())) ?? Date()
        VStack(alignment: .leading, spacing: P.spazioRiquadro) {
            Text(TestiEsameOCF.titoloData)
                .carattereApple(P.titoloRiquadro)
                .foregroundColor(P.coloreTitoloRiquadro)
            DatePicker("", selection: $sessione.bozzaData, in: domani..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
            HStack(spacing: P.spazioPulsanti) {
                Button(TestiEsameOCF.salva) {
                    let giorno = cal.startOfDay(for: sessione.bozzaData)
                    stato.impostaDataEsameOCF(giorno)
                    chiudi()
                    avvisaRitmo(giorno, cal: cal)
                }
                .buttonStyle(.applePrimario)
                if archivio.dataEsame != nil {
                    Button(TestiEsameOCF.togliData) {
                        stato.impostaDataEsameOCF(nil)
                        chiudi()
                    }
                    .buttonStyle(.apple)
                }
                Button(TestiEsameOCF.annulla) { chiudi() }
                    .buttonStyle(.appleSobrio)
            }
        }
        .padding(P.paddingRiquadro)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(P.riquadro, raggio: P.raggioRiquadro)
    }

    /// Migliorie d'uso 55 (Mac): dopo «Salva» l'avviso «Mancano 90 giorni: 3 domande al giorno per arrivare pronto»,
    /// con il conto di `MotoreOCF.domandeAlGiorno`. Con le domande di esempio l'avviso non c'è.
    private func avvisaRitmo(_ giorno: Date, cal: Calendar) {
        guard SessioneEsameOCF.conBilancio, !istantanea else { return }
        let a = stato.dati.ocf
        guard !a.domande.contains(where: { $0.origine == .esempio }),
              let giorni = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: giorno).day,
              let k = MotoreOCF.domandeAlGiorno(archivio: a, giorni: giorni, cal: cal) else { return }
        stato.mostraAvviso(TestiEsameOCF.ritmo(giorni: giorni, domande: k))
    }

    private func chiudi() {
        if istantanea {
            sessione.riquadroData = false
        } else {
            withAnimation(calmo ? Tema.Apple.Studio.OCF.Moto.calma : Tema.Apple.Studio.OCF.Moto.riquadro) {
                sessione.riquadroData = false
            }
        }
    }
}

// MARK: - Card 2 · La domanda

private struct CardDomandaOCFVista: View {
    let stato: StatoShell
    @ObservedObject var sessione: SessioneEsameOCF
    let archivio: ArchivioOCF
    let prep: PreparazioneOCF
    let scorre: Bool

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    private typealias C = Tema.Apple.Studio.OCF.Card
    private typealias Dm = Tema.Apple.Studio.OCF.Domanda
    private typealias St = Tema.Apple.Studio.OCF.Stato
    private typealias M = Tema.Apple.Studio.OCF.Moto

    /// La domanda mostrata (nil = coda finita o domanda tolta dall'archivio).
    private var attuale: DomandaOCF? { sessione.idAttuale.flatMap { archivio.domanda($0) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let e = sessione.errore {
                erroreFile(e)
                    .padding(.bottom, Dm.piedeSopra)
            }
            if let i = sessione.importazione {
                bloccoScorrevole { riepilogo(i) }
            } else if archivio.domande.isEmpty {
                bloccoScorrevole { vuoto }
            } else if let d = attuale {
                corpoDomanda(d)
                piede(aperta: sessione.scelta == nil)
            } else if SessioneEsameOCF.conBilancio && !sessione.esiti.isEmpty {
                // Migliorie d'uso 55: a fine giro il bilancio, al posto della domanda
                BilancioOCFVista(esiti: sessione.esiti, archivio: archivio, puntoDebole: prep.puntoDebole,
                                 scorre: scorre, ripassaDebole: ripassaDebole, ricomincia: ricomincia)
                    .transition(transizioneDomanda)
            } else {
                bloccoScorrevole { finito }
            }
        }
        .padding(C.paddingDomanda)
        .frame(maxWidth: .infinity, maxHeight: scorre ? .infinity : nil, alignment: .topLeading)
        .superficieApple(C.superficie, raggio: C.raggio)
        #if os(macOS)
        .background {
            if !istantanea, sessione.importazione == nil, !sessione.riquadroData, let d = attuale {
                ScorciatoieEsameOCF(sistema: stato.sistema, aperta: sessione.scelta == nil,
                                    scegli: { rispondi(d, $0) }, avanti: avanti)
            }
        }
        #endif
    }

    @ViewBuilder private func bloccoScorrevole<V: View>(@ViewBuilder _ c: () -> V) -> some View {
        if scorre {
            ScrollView(.vertical, showsIndicators: false) {
                c().frame(maxWidth: .infinity, alignment: .topLeading)
            }
        } else {
            c()
        }
    }

    // MARK: La domanda

    private var transizioneDomanda: AnyTransition {
        if calmo || istantanea { return AnyTransition.opacity.animation(M.calma) }
        return .asymmetric(
            insertion: AnyTransition.offset(x: M.spostamentoEntrataDomanda).combined(with: .opacity).animation(M.entrataDomanda),
            removal: AnyTransition.offset(x: M.spostamentoUscitaDomanda).combined(with: .opacity).animation(M.uscitaDomanda))
    }

    private func corpoDomanda(_ d: DomandaOCF) -> some View {
        ZStack(alignment: .topLeading) {
            bloccoScorrevole { contenutoDomanda(d) }
                .id(sessione.giro)
                .transition(transizioneDomanda)
        }
        .frame(maxWidth: .infinity, maxHeight: scorre ? .infinity : nil, alignment: .topLeading)
        .clipped()
    }

    /// L'archivio per il caso vero di una domanda: i dati dei calcoli (senza iscrivere la vista a tutto l'archivio) e
    /// l'allenamento OCF, letto vivo.
    private var datiCasoVero: DatiPrisma {
        var x = stato.datiDeiCalcoli()
        x.ocf = stato.dati.ocf
        return x
    }

    private func contenutoDomanda(_ d: DomandaOCF) -> some View {
        let O = Tema.Apple.Studio.OCF.Opzione.self
        let scelta = sessione.scelta
        let nomeMateria = archivio.materia(d.materia)?.nome ?? d.materia
        let caso = scelta == nil ? nil
            : MotoreOCF.casoVero(per: d, dati: datiCasoVero, clienteAttivo: stato.clienteAttivoId)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: Dm.spazioRigaAlta) {
                Text(nomeMateria)
                    .carattereApple(C.etichetta)
                    .foregroundColor(Tema.Apple.Studio.OCF.Colore.materia)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(TestiEsameOCF.contatore(min(sessione.indice + 1, sessione.coda.count), di: sessione.coda.count))
                    .carattereApple(Dm.contatore)
                    .foregroundColor(Dm.coloreContatore)
            }
            if let m = sessione.materia {
                filtro(archivio.materia(m)?.nome ?? m)
                    .padding(.top, Dm.filtroSopra)
            }
            Text(d.testo)
                .carattereApple(Dm.testo)
                .foregroundColor(Dm.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: Dm.larghezzaTesto, alignment: .leading)
                .padding(.top, Dm.testoSopra)
                .padding(.bottom, Dm.testoSotto)
            VStack(alignment: .leading, spacing: O.fraOpzioni) {
                ForEach(Array(d.risposte.enumerated()), id: \.offset) { i, testo in
                    OpzioneLettera(lettera: i < O.lettere.count ? O.lettere[i] : String(i + 1), testo: testo,
                                    esito: esito(i, d: d, scelta: scelta),
                                    tremolio: (scelta == i && i != d.corretta) ? sessione.tremolio : 0) {
                        rispondi(d, i)
                    }
                }
            }
            if let s = scelta {
                SpiegazioneOCFVista(giusta: s == d.corretta, testo: d.spiegazione, fonte: d.fonte,
                                    caso: caso, apriCaso: apriCaso)
                    .padding(.top, Tema.Apple.Studio.OCF.Spiegazione.sopra)
                    .transition(calmo || istantanea ? .opacity
                        : AnyTransition.offset(y: M.spostamentoSpiegazione).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func esito(_ i: Int, d: DomandaOCF, scelta: Int?) -> OpzioneLettera.Esito {
        guard let s = scelta else { return .aperta }
        if i == d.corretta { return .giusta }
        if i == s { return .sbagliata }
        return .attenuata
    }

    /// «Solo: <materia> ✕»: si torna a tutte le materie.
    private func filtro(_ nome: String) -> some View {
        Button {
            let cambia = {
                sessione.materia = nil
                sessione.avvia(stato.dati.ocf)
            }
            if istantanea { cambia() } else { withAnimation(calmo ? M.calma : M.entrataDomanda, cambia) }
        } label: {
            HStack(spacing: Tema.Apple.Controlli.Pulsante.spazio) {
                Text(TestiEsameOCF.soloMateria(nome))
                Image(systemName: "xmark")
            }
        }
        .buttonStyle(.apple)
        .help(TestiEsameOCF.tutteLeMaterie)
    }

    private func piede(aperta: Bool) -> some View {
        HStack(alignment: .center, spacing: Dm.spazioPiede) {
            Text(TestiEsameOCF.piede)
                .carattereApple(C.nota)
                .foregroundColor(C.coloreNota)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(TestiEsameOCF.importa) { importa() }
                .buttonStyle(.appleSobrio)
            if SessioneEsameOCF.conBilancio {
                // Migliorie d'uso 55: «Salta» finché non si risponde; poi «Prossima domanda ›» o, all'ultima del giro,
                // «Vedi com’è andata ›». Invio e → fanno la stessa cosa del pulsante.
                if aperta {
                    Button(TestiEsameOCF.salta) { avanti() }
                        .buttonStyle(.appleGrande)
                } else {
                    Button(sessione.ultimaDelGiro ? TestiEsameOCF.vediComeEAndata : TestiEsameOCF.prossima) { avanti() }
                        .buttonStyle(.applePrimarioGrande)
                }
            } else {
                Button(TestiEsameOCF.prossima) { avanti() }
                    .buttonStyle(.applePrimarioGrande)
            }
        }
        .padding(.top, Dm.piedeSopra)
    }

    // MARK: Risposta e avanti

    private func rispondi(_ d: DomandaOCF, _ i: Int) {
        guard sessione.scelta == nil, sessione.idAttuale == d.id, (0..<d.risposte.count).contains(i) else { return }
        // Il giro di oggi ricorda l'esito (solo in memoria, per il bilancio)
        sessione.annota(d.id, giusta: i == d.corretta)
        // Nelle istantanee non si registra niente: lo stato della scena è solo da guardare
        if !istantanea { stato.rispondiOCF(d.id, scelta: i) }
        if istantanea {
            sessione.scelta = i
            return
        }
        if calmo {
            withAnimation(M.calma) { sessione.scelta = i }
            return
        }
        withAnimation(M.spiegazione) { sessione.scelta = i }
        if i != d.corretta {
            sessione.tremolio = 0
            withAnimation(M.animazioneTremolio) { sessione.tremolio = 1 }
        }
    }

    private func avanti() {
        if istantanea {
            sessione.avanti()
        } else {
            withAnimation(calmo ? M.calma : M.entrataDomanda) { sessione.avanti() }
        }
    }

    /// «Ripassa il punto debole»: la coda di oggi della sola materia più debole.
    private func ripassaDebole(_ materia: String) {
        let cambia = {
            sessione.materia = materia
            sessione.avvia(stato.dati.ocf)
        }
        if istantanea { cambia() } else { withAnimation(calmo ? M.calma : M.entrataDomanda, cambia) }
    }

    /// «Ricomincia»: rifà la coda di oggi. Tornano le saltate (le nuove non risposte restano nella quota del giorno, i
    /// ripassi saltati restano scaduti), non quelle già risposte oggi; se è vuota si vede «Per oggi il ripasso è finito.».
    private func ricomincia() {
        let cambia = { sessione.avvia(stato.dati.ocf) }
        if istantanea { cambia() } else { withAnimation(calmo ? M.calma : M.entrataDomanda, cambia) }
    }

    private func apriCaso(_ c: CasoVeroOCF) {
        if let doc = c.documentoId {
            stato.clienteAttivoId = c.clienteId
            stato.documentoSelezionato = doc
            stato.apri(.documenti)
        } else if let id = c.posizioneId, let p = stato.dati.posizioni.first(where: { $0.id == id }) {
            stato.apriPosizione(p)
        } else {
            stato.apriCliente(c.clienteId)
        }
    }

    // MARK: Stati senza domanda

    private var vuoto: some View {
        VStack(alignment: .leading, spacing: St.spazio) {
            Text(TestiEsameOCF.vuotoTitolo)
                .carattereApple(St.titolo)
                .foregroundColor(St.coloreTitolo)
            Text(TestiEsameOCF.vuotoTesto)
                .carattereApple(St.testo)
                .foregroundColor(St.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: St.spazioPulsanti) {
                Button(TestiEsameOCF.importa) { importa() }
                    .buttonStyle(.applePrimario)
                Button(TestiEsameOCF.provaEsempio) { aggiungiEsempi() }
                    .buttonStyle(.apple)
                Button(TestiEsameOCF.modello) { scaricaModello() }
                    .buttonStyle(.appleSobrio)
            }
            .padding(.top, St.pulsantiSopra)
            Text(TestiEsameOCF.vuotoNota)
                .carattereApple(C.nota)
                .foregroundColor(C.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: St.larghezza, alignment: .leading)
    }

    private var finito: some View {
        let tornano = sessione.tornanoDomani(archivio, cal: Calendar.current)
        return VStack(alignment: .leading, spacing: St.spazio) {
            if let m = sessione.materia {
                filtro(archivio.materia(m)?.nome ?? m)
            }
            Text(TestiEsameOCF.finitoTitolo)
                .carattereApple(St.titolo)
                .foregroundColor(St.coloreTitolo)
            Text(TestiEsameOCF.domani(tornano))
                .carattereApple(St.testo)
                .foregroundColor(St.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
            if prep.nuoveDisponibili > 0 {
                Button(TestiEsameOCF.altreNuove) { altreNuove() }
                    .buttonStyle(.applePrimarioGrande)
                    .padding(.top, St.pulsantiSopra)
            } else {
                Text(TestiEsameOCF.nessunaNuova)
                    .carattereApple(St.testo)
                    .foregroundColor(St.coloreTesto)
                    .fixedSize(horizontal: false, vertical: true)
                Button(TestiEsameOCF.importa) { importa() }
                    .buttonStyle(.applePrimario)
                    .padding(.top, St.pulsantiSopra)
            }
        }
        .frame(maxWidth: St.larghezza, alignment: .leading)
    }

    private func riepilogo(_ i: ImportazioneOCF) -> some View {
        VStack(alignment: .leading, spacing: St.spazio) {
            Text(i.vuota ? TestiEsameOCF.nienteDaImportare : TestiEsameOCF.riepilogoTitolo)
                .carattereApple(St.titolo)
                .foregroundColor(St.coloreTitolo)
            HStack(alignment: .top, spacing: St.spazioCifre) {
                cifra(i.nuove.count, TestiEsameOCF.nuove, colore: St.coloreCifra)
                cifra(i.aggiornate.count, TestiEsameOCF.aggiornate, colore: St.coloreCifra)
                cifra(i.scartate.count, TestiEsameOCF.scartate,
                      colore: i.scartate.isEmpty ? St.coloreCifra : St.coloreScartate)
            }
            .padding(St.paddingRiepilogo)
            .frame(maxWidth: .infinity, alignment: .leading)
            .superficieApple(St.riepilogo, raggio: St.raggioRiepilogo)
            Text(i.riepilogo)
                .carattereApple(St.testo)
                .foregroundColor(St.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
            if !i.scartate.isEmpty {
                VStack(alignment: .leading, spacing: Tema.Apple.Studio.OCF.Preparazione.spazioRighe) {
                    ForEach(Array(i.scartate.prefix(St.massimoScartateMostrate).enumerated()), id: \.offset) { _, r in
                        Text(TestiEsameOCF.scartata(r, daCSV: i.daCSV))
                            .carattereApple(St.righeScartate)
                            .foregroundColor(St.coloreRigheScartate)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            if let f = i.fonte {
                Text(TestiEsameOCF.fonte(f))
                    .carattereApple(C.nota)
                    .foregroundColor(C.coloreNota)
            }
            HStack(spacing: St.spazioPulsanti) {
                if !i.vuota {
                    Button(TestiEsameOCF.conferma) { conferma(i) }
                        .buttonStyle(.applePrimario)
                }
                Button(i.vuota ? TestiEsameOCF.chiudi : TestiEsameOCF.annulla) { sessione.importazione = nil }
                    .buttonStyle(.apple)
            }
            .padding(.top, St.pulsantiSopra)
        }
        .frame(maxWidth: St.larghezza, alignment: .leading)
    }

    private func cifra(_ n: Int, _ etichetta: String, colore: Color) -> some View {
        VStack(alignment: .leading, spacing: Tema.Apple.Studio.OCF.Preparazione.spazioRighe) {
            Text(FormatoCifra.migliaia(Double(n)))
                .carattereApple(St.cifra)
                .foregroundColor(colore)
            Text(etichetta)
                .carattereApple(C.nota)
                .foregroundColor(C.coloreNota)
        }
    }

    private func erroreFile(_ messaggio: String) -> some View {
        HStack(alignment: .top, spacing: St.spazioPulsanti) {
            VStack(alignment: .leading, spacing: Tema.Apple.Studio.OCF.Preparazione.spazioRighe) {
                Text(TestiEsameOCF.erroreTitolo)
                    .carattereApple(St.titoloErrore)
                    .foregroundColor(St.coloreTitolo)
                if messaggio != TestiOCF.fileIlleggibile {
                    Text(messaggio)
                        .carattereApple(St.testo)
                        .foregroundColor(St.coloreTesto)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            Button(TestiEsameOCF.chiudi) { sessione.errore = nil }
                .buttonStyle(.appleSobrio)
        }
        .padding(St.paddingErrore)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: St.raggioErrore, style: .continuous).fill(St.fondoErrore))
        .overlay(RoundedRectangle(cornerRadius: St.raggioErrore, style: .continuous)
            .strokeBorder(St.bordoErrore, lineWidth: Tema.Apple.Misura.bordo))
    }

    // MARK: File

    private func importa() {
        #if os(macOS)
        let pannello = NSOpenPanel()
        pannello.canChooseDirectories = false
        pannello.canChooseFiles = true
        pannello.allowsMultipleSelection = false
        pannello.allowedContentTypes = [.json, .commaSeparatedText, .tabSeparatedText, .plainText]
        pannello.prompt = TestiEsameOCF.pannelloPulsante
        pannello.message = TestiEsameOCF.pannelloMessaggio
        if pannello.runModal() == .OK, let url = pannello.url { leggi(url) }
        #else
        stato.mostraAvviso(StatoShell.soloSulMacPerOra)
        #endif
    }

    /// Legge il file e prepara il riepilogo: l'archivio cambia solo confermando.
    private func leggi(_ url: URL) {
        let accesso = url.startAccessingSecurityScopedResource()
        defer { if accesso { url.stopAccessingSecurityScopedResource() } }
        guard let dati = try? Data(contentsOf: url) else {
            sessione.errore = TestiOCF.fileIlleggibile
            return
        }
        do {
            let i = try ImportaOCF.leggi(dati, nomeFile: url.lastPathComponent, archivio: stato.dati.ocf)
            sessione.errore = nil
            sessione.importazione = i
        } catch let e as ErroreImportaOCF {
            sessione.errore = e.messaggio
        } catch {
            sessione.errore = TestiOCF.fileIlleggibile
        }
    }

    private func conferma(_ i: ImportazioneOCF) {
        stato.applicaImportazioneOCF(i)
        sessione.importazione = nil
        sessione.avvia(stato.dati.ocf)
    }

    private func aggiungiEsempi() {
        guard stato.aggiungiDomandeEsempioOCF() != nil else {
            sessione.errore = TestiOCF.fileIlleggibile
            return
        }
        sessione.errore = nil
        sessione.avvia(stato.dati.ocf)
    }

    private func altreNuove() {
        let cambia = { sessione.avvia(stato.dati.ocf, nuove: stato.dati.ocf.nuovePerGiorno) }
        if istantanea { cambia() } else { withAnimation(calmo ? M.calma : M.entrataDomanda, cambia) }
    }

    /// Il modello CSV: l'intestazione e le domande di esempio di Prisma, da aprire con Excel o Numbers.
    private func scaricaModello() {
        #if os(macOS)
        let testo = TestiEsameOCF.modelloCSV(ImportaOCF.esempio(archivio: ArchivioOCF()))
        let pannello = NSSavePanel()
        pannello.nameFieldStringValue = TestiEsameOCF.nomeModello
        pannello.allowedContentTypes = [.commaSeparatedText]
        pannello.canCreateDirectories = true
        guard pannello.runModal() == .OK, let url = pannello.url else { return }
        do {
            try Data(testo.utf8).write(to: url, options: .atomic)
        } catch {
            sessione.errore = error.localizedDescription
        }
        #else
        stato.mostraAvviso(StatoShell.soloSulMacPerOra)
        #endif
    }
}

// MARK: - Il bilancio del giro

/// Il bilancio a fine giro (migliorie d'uso 55, template `ocfBilancio`): «Il ripasso di oggi», il titolo («4 giuste
/// su 6.»), la regola vera del ripasso (dagli intervalli del motore), l'elenco del giro con segno, domanda, materia e
/// pillola di stato, e in fondo «Ripassa il punto debole», «Ricomincia» e «Punto debole: <materia>». Gli esiti vivono
/// nella sessione: niente si scrive nell'archivio.
private struct BilancioOCFVista: View {
    let esiti: [EsitoGiroOCF]
    let archivio: ArchivioOCF
    let puntoDebole: MateriaOCF?
    let scorre: Bool
    let ripassaDebole: (String) -> Void
    let ricomincia: () -> Void

    private typealias B = Tema.Apple.Studio.OCF.Bilancio

    /// Una riga dell'elenco: l'esito con la sua domanda (quelle tolte dall'archivio nel frattempo non ci sono).
    private struct Riga: Identifiable {
        let esito: EsitoGiroOCF.Tipo
        let domanda: DomandaOCF
        let materia: String
        var id: String { domanda.id }
    }

    private var righe: [Riga] {
        esiti.compactMap { e in
            guard let d = archivio.domanda(e.domandaId) else { return nil }
            return Riga(esito: e.esito, domanda: d, materia: archivio.materia(d.materia)?.nome ?? d.materia)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if scorre {
                ScrollView(.vertical, showsIndicators: false) {
                    contenuto.frame(maxWidth: .infinity, alignment: .topLeading)
                }
            } else {
                contenuto
            }
            piede
        }
        .frame(maxWidth: .infinity, maxHeight: scorre ? .infinity : nil, alignment: .topLeading)
    }

    private var contenuto: some View {
        let giuste = esiti.filter { $0.esito == .giusta }.count
        let risposte = esiti.filter { $0.esito != .saltata }.count
        return VStack(alignment: .leading, spacing: 0) {
            Text(TestiEsameOCF.ripassoDiOggi)
                .carattereApple(B.etichetta)
                .foregroundColor(B.coloreEtichetta)
            Text(TestiEsameOCF.bilancio(giuste: giuste, di: esiti.count, risposte: risposte))
                .carattereApple(B.titolo)
                .foregroundColor(B.coloreTitolo)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, B.titoloSopra)
            Text(TestiEsameOCF.tornano)
                .carattereApple(B.testo)
                .foregroundColor(B.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, B.testoSopra)
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(righe) { r in
                    riga(r)
                }
            }
            .padding(.top, B.elencoSopra)
        }
    }

    private func riga(_ r: Riga) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(B.filo)
                .frame(height: B.spessoreFilo)
            HStack(alignment: .center, spacing: B.spazio) {
                Text(segno(r.esito))
                    .carattereApple(B.segno)
                    .foregroundColor(coloreSegno(r.esito))
                    .frame(width: B.larghezzaSegno, alignment: .center)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: B.spazioRighe) {
                    Text(r.domanda.testo)
                        .carattereApple(B.domanda)
                        .foregroundColor(B.coloreDomanda)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(r.materia)
                        .carattereApple(B.materia)
                        .foregroundColor(B.coloreMateria)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                pillola(r.esito)
            }
            .padding(.vertical, B.rigaVerticale)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private func pillola(_ e: EsitoGiroOCF.Tipo) -> some View {
        switch e {
        case .giusta: PillolaStatoApple(testo: TestiEsameOCF.fatta, tono: .ok)
        case .sbagliata: PillolaStatoApple(testo: TestiEsameOCF.tornaDomani, tono: .errore)
        case .saltata: PillolaStatoApple(testo: TestiEsameOCF.saltataTornaDomani, tono: .neutro)
        }
    }

    private func segno(_ e: EsitoGiroOCF.Tipo) -> String {
        switch e {
        case .giusta: return B.segnoGiusta
        case .sbagliata: return B.segnoSbagliata
        case .saltata: return B.segnoSaltata
        }
    }

    private func coloreSegno(_ e: EsitoGiroOCF.Tipo) -> Color {
        switch e {
        case .giusta: return B.coloreGiusta
        case .sbagliata: return B.coloreSbagliata
        case .saltata: return B.coloreSaltata
        }
    }

    private var piede: some View {
        HStack(alignment: .center, spacing: B.spazioPulsanti) {
            if let d = puntoDebole {
                Button(TestiEsameOCF.ripassaDebole) { ripassaDebole(d.id) }
                    .buttonStyle(.applePrimarioGrande)
            }
            Button(TestiEsameOCF.ricomincia) { ricomincia() }
                .buttonStyle(.appleGrande)
            Spacer(minLength: 0)
            if let d = puntoDebole {
                Text(TestiEsameOCF.puntoDeboleBreve(d.nome))
                    .carattereApple(B.puntoDebole)
                    .foregroundColor(B.colorePuntoDebole)
                    .lineLimit(1)
            }
        }
        .padding(.top, B.piedeSopra)
    }
}

// MARK: - Spiegazione

/// La spiegazione dopo la risposta: «Giusto.» (con la spunta che si disegna) o «Non proprio: torna tra un giorno.»,
/// il testo, la fonte e il pulsante del caso vero (solo se l'archivio ne ha uno: mai nomi finti).
private struct SpiegazioneOCFVista: View {
    let giusta: Bool
    let testo: String?
    let fonte: String?
    let caso: CasoVeroOCF?
    let apriCaso: (CasoVeroOCF) -> Void

    @Environment(\.prismaStatoFinale) private var fermo
    @State private var spunta: Double = 0

    private typealias S = Tema.Apple.Studio.OCF.Spiegazione
    private typealias K = Tema.Apple.Studio.OCF.Colore

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: S.raggio, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: S.spazioTitolo) {
                if giusta {
                    SpuntaDisegnata(progresso: fermo ? 1 : spunta, lato: S.spunta)
                }
                Text(giusta ? TestiEsameOCF.giusto : TestiEsameOCF.sbagliato)
                    .carattereApple(S.titolo)
                    .foregroundColor(giusta ? K.titoloGiusto : K.titoloSbagliato)
            }
            if let t = testo, !t.isEmpty {
                Text(t)
                    .carattereApple(S.testo)
                    .foregroundColor(S.coloreTesto)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, S.testoSopra)
            }
            if let f = fonte, !f.isEmpty {
                Text(TestiEsameOCF.fonte(f))
                    .carattereApple(S.fonte)
                    .foregroundColor(S.coloreFonte)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, S.fonteSopra)
            }
            if let c = caso {
                Button { apriCaso(c) } label: {
                    Text("\(S.segnoCaso) \(c.testo)")
                }
                .buttonStyle(.apple)
                .padding(.top, S.casoSopra)
            }
        }
        .padding(S.padding)
        .frame(maxWidth: Tema.Apple.Studio.OCF.Opzione.larghezza, alignment: .leading)
        .superficieApple(S.superficie, raggio: S.raggio)
        .overlay(forma.strokeBorder(giusta ? K.bordoSpiegazioneGiusta : K.bordoSpiegazioneSbagliata, lineWidth: S.bordo))
        .onAppear {
            guard giusta, !fermo else { return }
            withAnimation(Tema.Apple.Moto.Spunta.tracciato) { spunta = 1 }
        }
    }
}

// MARK: - Tastiera (Mac)

#if os(macOS)
/// Pulsanti invisibili, solo per i tasti: A-D e 1-4 rispondono, Invio e → vanno avanti. Ci sono solo con Studio in
/// primo piano e senza la ricerca aperta, così le lettere non si rubano a un campo di testo di un'altra finestra.
private struct ScorciatoieEsameOCF: View {
    let sistema: StatoFinestre
    let aperta: Bool
    let scegli: (Int) -> Void
    let avanti: () -> Void

    /// I tasti delle quattro risposte.
    private static let lettere: [Character] = ["a", "b", "c", "d"]
    private static let cifre: [Character] = ["1", "2", "3", "4"]

    var body: some View {
        if sistema.appAttiva == .studio && !sistema.pannelloRicerca {
            HStack(spacing: 0) {
                if aperta {
                    ForEach(0..<Self.lettere.count, id: \.self) { i in
                        Button("") { scegli(i) }
                            .keyboardShortcut(KeyEquivalent(Self.lettere[i]), modifiers: [])
                        Button("") { scegli(i) }
                            .keyboardShortcut(KeyEquivalent(Self.cifre[i]), modifiers: [])
                    }
                }
                Button("") { avanti() }
                    .keyboardShortcut(.return, modifiers: [])
                Button("") { avanti() }
                    .keyboardShortcut(.rightArrow, modifiers: [])
            }
            .frame(width: 0, height: 0)
            .opacity(0)
            .accessibilityHidden(true)
        }
    }
}
#endif
