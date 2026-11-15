import Foundation

// Migliorie d'uso 15 «La scheda di una posizione si legge dall'alto» (solo Mac): la frase in cima, le quattro cifre, le
// schede e i dati da completare. Qui solo testi e conti già fatti dai motori (nessuna cifra nuova, mai cifre inventate:
// se manca un dato la frase si accorcia e la tessera non c'è). Le viste stanno in Shell/SchedeDettaglioPosizione.swift.

/// Le schede del dettaglio di una posizione (segmentato sotto le cifre): solo quelle con un contenuto.
enum SchedaPosizione: String, CaseIterable, Hashable {
    case inBreve, andamento, costiRischio, adeguatezza, contratto

    /// Il nome nel segmentato; per una copertura «Costi e rischio» si chiama «La copertura» (decisione 15.6).
    func titolo(protezione: Bool) -> String {
        switch self {
        case .inBreve: return "In breve"
        case .andamento: return "Andamento"
        case .costiRischio: return protezione ? "La copertura" : "Costi e rischio"
        case .adeguatezza: return "Adeguatezza"
        case .contratto: return "Contratto"
        }
    }

    /// Le schede che hanno contenuto, nell'ordine del template (In breve, Andamento, Costi e rischio, Adeguatezza,
    /// Contratto). Un conto corrente ha solo In breve e Contratto.
    static func disponibili(_ p: Posizione, andamento: Bool, proiezione: Bool, riscatto: Bool,
                            adeguatezza: Bool) -> [SchedaPosizione] {
        var s: [SchedaPosizione] = [.inBreve]
        if andamento || proiezione { s.append(.andamento) }
        if p.area.proiettabile || p.area == .protezione || riscatto { s.append(.costiRischio) }
        if adeguatezza { s.append(.adeguatezza) }
        s.append(.contratto)
        return s
    }

    /// La scheda in cui sta una parte del dettaglio chiesta con l'ancora «dettaglio-…» (istantanee, completezza).
    init?(ancora: String) {
        switch ancora {
        case "dettaglio-andamento", "dettaglio-riferimento": self = .andamento
        case "dettaglio-costi", "dettaglio-composizione", "dettaglio-gestione", "dettaglio-riscatto": self = .costiRischio
        case "dettaglio-adeguatezza": self = .adeguatezza
        case "dettaglio-contratto": self = .contratto
        default: return nil
        }
    }

    /// Le ancore che aprono la scheda dalla prima riga: basta sceglierla, senza scorrere (la frase e le cifre restano
    /// in vista).
    static func inCima(_ ancora: String) -> Bool {
        ["dettaglio-andamento", "dettaglio-costi", "dettaglio-adeguatezza", "dettaglio-contratto"].contains(ancora)
    }
}

/// Una delle quattro cifre in cima al dettaglio.
struct CifraPosizione: Equatable {
    enum Tono: Equatable { case normale, verde, rosso, arancio, viola }
    let titolo: String
    let valore: String
    let nota: String
    var tono: Tono = .normale
}

/// L'esito della scheda di adeguatezza per la tessera di una proposta.
struct AdeguatezzaInBreve: Equatable {
    let complessivo: Semaforo
    let inOrdine: Int
    let controlli: Int
}

enum TestiDettaglioPosizione {
    // MARK: - Testi fissi

    static let indietro = "Le posizioni"
    static let aiutoIndietro = "Torna alle posizioni (esc)"
    static let altro = "Altro"
    static let elimina = "Elimina la posizione…"
    static let completaIDati = "Completa i dati"
    static let siCompletano = "Si completano in una volta, da «Modifica»."
    static let vedi = "Vedi ›"
    static let andamentoLink = "Andamento ›"
    static let costiLink = "Costi e rischio ›"
    static let coperturaLink = "La copertura ›"
    static let analisi360Link = "Apri Analisi 360 ›"
    static let daFareLink = "Apri «Da fare» ›"
    static let datiDelContratto = "Dati del contratto"
    static let nessunVuoto = "I dati del contratto ci sono tutti."

    static func daCompletare(_ n: Int) -> String { "Da completare · \(n)" }

    /// «3 dati da completare», «1 dato da completare».
    static func datiDaCompletare(_ n: Int) -> String { "\(n) \(n == 1 ? "dato" : "dati") da completare" }

    /// «in 4 anni», «in 1 anno».
    static func inAnni(_ n: Int) -> String { "in \(n) \(n == 1 ? "anno" : "anni")" }

    /// Gli anni dalla decorrenza alla data del valore, all'anno intero (come «in {N} anni» del template); nil sotto
    /// il mezzo anno.
    static func anniInteri(_ anni: Double?) -> Int? {
        guard let a = anni else { return nil }
        let n = Int(a.rounded())
        return n >= 1 ? n : nil
    }

    /// I giorni da oggi a una data (0 se è oggi, negativi se è passata).
    static func giorni(a data: Date, da adesso: Date) -> Int {
        let cal = Calendar.current
        return cal.dateComponents([.day], from: cal.startOfDay(for: adesso), to: cal.startOfDay(for: data)).day ?? 0
    }

    /// «Scade tra 12 giorni», «Scade tra 1 giorno», «Scade oggi».
    static func scadeTra(_ giorni: Int) -> String {
        if giorni <= 0 { return "Scade oggi" }
        return "Scade tra \(giorni) \(giorni == 1 ? "giorno" : "giorni")"
    }

    private static func anno(_ d: Date) -> String { String(Calendar.current.component(.year, from: d)) }
    private static func data(_ d: Date) -> String { Formati.dataEstesa.string(from: d) }

    // MARK: - La frase

    /// La frase in cima (`#pdFrase` del template). `nome` è il nome di battesimo del cliente; `mesiSpese` i mesi di
    /// spese della liquidità di Analisi 360 (nil se le spese non sono indicate).
    static func frase(_ p: Posizione, voce: VoceResoconto?, nome: String, mesiSpese: Double?, adesso: Date = Date()) -> String {
        if p.stato == .proposta { return fraseProposta(p) }
        if p.stato == .chiusa { return "La posizione è chiusa: non entra più nei conti del patrimonio." }
        switch p.area {
        case .investimento, .risparmio, .previdenza:
            return fraseFinanziaria(nome: nome, valore: voce?.valore ?? p.valore, dataValore: p.dataValore,
                                    versato: voce?.versato, risultato: voce?.risultato, anni: anniInteri(voce?.anni))
        case .protezione:
            return fraseProtezione(p)
        case .liquidita:
            let base = "Qui ci sono \(Formati.euro(p.valore))"
            guard let m = mesiSpese else { return base + "." }
            return base + ": è la riserva per gli imprevisti, \(TestiAree360.mesi(m)) \(m == 1 ? "mese" : "mesi") di spese."
        case .immobili:
            guard p.valore > 0 else { return "Il valore dell'immobile non è ancora indicato." }
            return "Vale circa \(Formati.euro(p.valore)): è una stima di oggi, non una perizia."
        case .debiti:
            return "Restano da pagare \(Formati.euro(p.controvalore ?? p.valore))."
        }
    }

    /// «Vale 18.400 €: Giulia ha versato 15.000 € e ne ha guadagnati 3.400 € in 4 anni.»; senza il versato la frase si
    /// accorcia («Vale 18.400 € al 31 ottobre 2026.»), senza gli anni perde «in N anni».
    static func fraseFinanziaria(nome: String, valore: Double, dataValore: Date?, versato: Double?, risultato: Double?,
                                 anni: Int?) -> String {
        let vale = "Vale \(Formati.euro(valore))"
        guard let v = versato, v > 0, let r = risultato else {
            return vale + (dataValore.map { " al \(data($0))" } ?? "") + "."
        }
        let verbo = r < 0 ? "ne ha persi" : "ne ha guadagnati"
        return "\(vale): \(nome) ha versato \(Formati.euro(v)) e \(verbo) \(Formati.euro(abs(r)))"
            + (anni.map { " \(inAnni($0))" } ?? "") + "."
    }

    /// «Copre 200.000 € in caso di morte: costa 420 € l'anno e dura fino al 2041.»
    static func fraseProtezione(_ p: Posizione) -> String {
        let premio = p.premioAnnuo > 0 ? p.premioAnnuo : nil
        var testa: String
        if let c = p.capitaleAssicurato, c > 0 {
            let cifra = Formati.euro(c)
            switch p.rischio {
            case .vita?: testa = "Copre \(cifra) in caso di morte"
            case .infortuni?: testa = "Copre gli infortuni fino a \(cifra)"
            case .invalidita?: testa = "Copre \(cifra) in caso di invalidità"
            case .ltc?: testa = "Copre \(cifra) in caso di non autosufficienza"
            case .salute?: testa = "Copre le spese per la salute fino a \(cifra)"
            case .casa?: testa = "Copre i danni alla casa fino a \(cifra)"
            case .rc?: testa = "Copre la responsabilità civile fino a \(cifra)"
            case .altro?, nil: testa = "Copre fino a \(cifra)"
            }
        } else {
            testa = "Una copertura" + (p.rischio.map { " · \($0.nome.lowercased())" } ?? "")
        }
        var coda: [String] = []
        if let pr = premio { coda.append("costa \(Formati.euro(pr)) l'anno") }
        if let s = p.scadenza {
            coda.append(p.rischio == .vita ? "dura fino al \(anno(s))" : "scade il \(data(s))")
        }
        guard !coda.isEmpty else { return testa + "." }
        return testa + ": " + coda.joined(separator: " e ") + "."
    }

    /// «Una proposta da 1.800 € l'anno, presentata il 12 ottobre 2026: aspetta una risposta.»; senza data di
    /// presentazione «Una proposta da 1.800 € l'anno: è bozza.»
    static func fraseProposta(_ p: Posizione) -> String {
        var testa = "Una proposta"
        if p.premioAnnuo > 0 {
            testa += " da \(Formati.euro(p.premioAnnuo)) l'anno"
        } else if p.versamentoIniziale > 0 {
            testa += " da \(Formati.euro(p.versamentoIniziale))"
        }
        let esito = p.esito ?? .bozza
        if esito == .presentata, let d = p.seguito?.presentataIl {
            return testa + ", presentata il \(data(d)): aspetta una risposta."
        }
        return testa + ": è \(esito.nome.lowercased())."
    }

    // MARK: - Le quattro cifre

    /// Le cifre in cima: una tessera senza dato non c'è (tre vanno bene). `attesoNetto` è il rendimento atteso al netto
    /// dei costi (per «Rende all'anno» quando manca il rendimento dei versamenti); `attivita` e `debiti` quelli del
    /// cliente (`RiepilogoPosizioni`).
    static func cifre(_ p: Posizione, voce: VoceResoconto?, attesoNetto: Double?, mesiSpese: Double?, sogliaMesi: Int?,
                      attivita: Double?, debiti: Double?, adeguatezza: AdeguatezzaInBreve?,
                      adesso: Date = Date()) -> [CifraPosizione] {
        var c: [CifraPosizione] = []
        if p.stato == .proposta {
            if p.premioAnnuo > 0 {
                c.append(.init(titolo: "Versamento proposto", valore: Formati.euro(p.premioAnnuo), nota: "all'anno", tono: .viola))
            } else if p.versamentoIniziale > 0 {
                c.append(.init(titolo: "Versamento proposto", valore: Formati.euro(p.versamentoIniziale), nota: "versamento unico", tono: .viola))
            }
            let esito = p.esito ?? .bozza
            let presentata = p.seguito?.presentataIl
            c.append(.init(titolo: "Stato", valore: esito == .presentata ? "In attesa" : esito.nome,
                           nota: presentata.map { "presentata il \(data($0))" } ?? "non ancora presentata"))
            if let a = adeguatezza, a.controlli > 0 {
                let (valore, tono): (String, CifraPosizione.Tono) = {
                    switch a.complessivo {
                    case .verde: return ("Coerente", .verde)
                    case .giallo: return ("Da motivare", .arancio)
                    case .rosso: return ("Non coerente", .rosso)
                    case .grigio: return ("Da completare", .normale)
                    }
                }()
                c.append(.init(titolo: "Adeguatezza", valore: valore, nota: "\(a.inOrdine) controlli su \(a.controlli)", tono: tono))
            }
            c.append(.init(titolo: "Area", valore: p.area.nome, nota: "a cosa risponde"))
            return c
        }
        switch p.area {
        case .investimento, .risparmio, .previdenza:
            let valore = voce?.valore ?? p.valore
            c.append(.init(titolo: "Vale oggi", valore: Formati.euro(valore),
                           nota: p.dataValore.map { "al \(data($0))" } ?? "valore indicato"))
            let anni = anniInteri(voce?.anni)
            if let v = voce?.versato, v > 0 {
                var nota = anni.map(inAnni) ?? "in tutto"
                if p.premioAnnuo > 0 { nota += ", \(Formati.euro(p.premioAnnuo)) l'anno" }
                c.append(.init(titolo: "Versato", valore: Formati.euro(v), nota: nota))
                if let r = voce?.risultato {
                    c.append(.init(titolo: r < 0 ? "Perdita" : "Guadagno", valore: CifreDoc.euroSegno(r),
                                   nota: voce?.risultatoPercento.map { "\(CifreDoc.variazione($0)) in tutto" } ?? "valore meno versato",
                                   tono: r < 0 ? .rosso : .verde))
                }
            }
            if let x = voce?.rendimentoAnnuo {
                c.append(.init(titolo: "Rende all'anno", valore: CifreDoc.variazione(x), nota: "i tuoi versamenti",
                               tono: x < 0 ? .rosso : .normale))
            } else if let a = attesoNetto {
                c.append(.init(titolo: "Rende all'anno", valore: CifreDoc.variazione(a), nota: "atteso, al netto dei costi"))
            }
        case .protezione:
            let capitale = p.capitaleAssicurato ?? 0
            if capitale > 0 {
                c.append(.init(titolo: "Capitale assicurato", valore: Formati.euro(capitale),
                               nota: p.rischio?.nome.lowercased() ?? "rischio non indicato"))
            }
            let premio = p.premioAnnuo > 0 ? p.premioAnnuo : p.versamentoIniziale
            if premio > 0 {
                c.append(.init(titolo: "Premio", valore: Formati.euro(premio), nota: p.premioAnnuo > 0 ? "all'anno" : "premio unico"))
            }
            if capitale > 0, p.premioAnnuo > 0 {
                c.append(.init(titolo: "Costo per 1.000 € assicurati", valore: Formati.euroDecimali(p.premioAnnuo / capitale * 1000),
                               nota: "all'anno"))
            }
            if let s = p.scadenza { c.append(cifraScadenza(s, soloAnno: p.rischio == .vita, adesso: adesso)) }
        case .liquidita:
            c.append(.init(titolo: "Saldo", valore: Formati.euro(p.valore), nota: p.dataValore.map { "al \(data($0))" } ?? "saldo indicato"))
            if let m = mesiSpese {
                let soglia = sogliaMesi ?? 6
                c.append(.init(titolo: "Mesi di spese", valore: TestiAree360.mesi(m), nota: "la soglia è \(soglia)",
                               tono: m < Double(soglia) ? .arancio : .normale))
            }
            if let r = p.rendimentoAtteso {
                c.append(.init(titolo: "Rende", valore: Formati.percentuale(r), nota: "all'anno"))
            }
            if let q = quota(p.valore, di: attivita) { c.append(q) }
        case .immobili:
            if p.valore > 0 {
                c.append(.init(titolo: "Valore stimato", valore: Formati.euro(p.valore), nota: "stima di oggi"))
            }
            if let d = debiti {
                c.append(.init(titolo: "Debiti residui", valore: Formati.euro(d), nota: d > 0 ? "ancora da pagare" : "nessun debito"))
                if p.valore > 0 {
                    c.append(.init(titolo: "Al netto dei debiti", valore: Formati.euro(p.valore - d), nota: "valore meno debiti"))
                }
            }
            if p.valore > 0, let q = quota(p.valore, di: attivita) { c.append(q) }
        case .debiti:
            c.append(.init(titolo: "Debito residuo", valore: Formati.euro(p.controvalore ?? p.valore),
                           nota: p.dataValore.map { "al \(data($0))" } ?? "da pagare", tono: .rosso))
            if p.premio > 0, p.frequenza != .unica {
                c.append(.init(titolo: "Rata", valore: Formati.euro(p.premio), nota: p.frequenza.nome.lowercased()))
            }
            if let s = p.scadenza {
                let anni = max(0, Calendar.current.dateComponents([.year], from: adesso, to: s).year ?? 0)
                c.append(.init(titolo: "Finisce", valore: "nel \(anno(s))", nota: anni >= 1 ? "tra \(anni) \(anni == 1 ? "anno" : "anni")" : "quest'anno"))
            }
            if let t = p.tassoDebito {
                c.append(.init(titolo: "Tasso", valore: Formati.percentuale(t), nota: "annuo"))
            }
        }
        return c
    }

    /// «Scadenza»: arancio entro i giorni della scadenza vicina di Posizioni (90), rossa se è passata.
    static func cifraScadenza(_ s: Date, soloAnno: Bool, adesso: Date) -> CifraPosizione {
        let g = giorni(a: s, da: adesso)
        let valore = soloAnno ? anno(s) : data(s)
        if g < 0 { return .init(titolo: "Scadenza", valore: valore, nota: "scaduta", tono: .rosso) }
        if g <= RiepilogoPosizioni.giorniScadenza {
            return .init(titolo: "Scadenza", valore: valore, nota: g == 0 ? "oggi" : "tra \(g) \(g == 1 ? "giorno" : "giorni")", tono: .arancio)
        }
        let anni = Calendar.current.dateComponents([.year], from: adesso, to: s).year ?? 0
        return .init(titolo: "Scadenza", valore: valore,
                     nota: anni >= 1 ? "tra \(anni) \(anni == 1 ? "anno" : "anni")" : "tra \(g) giorni")
    }

    private static func quota(_ valore: Double, di attivita: Double?) -> CifraPosizione? {
        guard let a = attivita, a > 0 else { return nil }
        return .init(titolo: "Quota del patrimonio", valore: Formati.percentuale((valore / a * 100).rounded()), nota: "delle attività")
    }

    // MARK: - Contratto e dati da completare

    /// Che contratto è, per i nomi dei campi: polizza (protezione, previdenza, rivalutabili, multiramo), deposito titoli
    /// (fondi, ETF, titoli, conti deposito d'investimento) o altro (conti, immobili, debiti).
    enum Contratto: Equatable { case polizza, deposito, altro }

    static func contratto(_ p: Posizione) -> Contratto {
        switch p.area {
        case .protezione, .previdenza: return .polizza
        case .liquidita, .immobili, .debiti: return .altro
        case .investimento, .risparmio: return p.regime == .polizza ? .polizza : .deposito
        }
    }

    private static func vuoto(_ s: String) -> Bool { s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// I campi del contratto pertinenti al tipo che sono vuoti (template `vuotiDi`): per le polizze Numero, Contraente,
    /// Assicurato, Beneficiari, Decorrenza e Scadenza (le proposte senza Scadenza); per fondi ed ETF «Numero del deposito»
    /// e «Intestatario»; per conti, immobili e debiti «Intestatario». Note e garanzie vuote non contano.
    static func campiVuoti(_ p: Posizione) -> [String] {
        var v: [String] = []
        switch contratto(p) {
        case .polizza:
            if vuoto(p.numeroContratto) { v.append("Numero") }
            if vuoto(p.contraente) { v.append("Contraente") }
            if vuoto(p.assicurato) { v.append("Assicurato") }
            if vuoto(p.beneficiari) { v.append("Beneficiari") }
            if p.decorrenza == nil { v.append("Decorrenza") }
            if p.scadenza == nil && p.stato != .proposta { v.append("Scadenza") }
        case .deposito:
            if vuoto(p.numeroContratto) { v.append("Numero del deposito") }
            if vuoto(p.contraente) { v.append("Intestatario") }
        case .altro:
            if vuoto(p.contraente) { v.append("Intestatario") }
        }
        return v
    }

    /// L'etichetta del campo di `ModuloPosizione` per un nome di `campiVuoti` (rifinitura 11-17): il modulo dice «Numero
    /// di contratto» e «Contraente» anche per depositi e conti, gli altri nomi sono gli stessi.
    static func etichettaModulo(_ campo: String) -> String {
        switch campo {
        case "Numero", "Numero del deposito": return "Numero di contratto"
        case "Intestatario": return "Contraente"
        default: return campo
        }
    }

    /// Il campo del modulo su cui apre «Completa i dati»: il primo dei campi vuoti (nil: nessuno).
    static func primoCampoModulo(_ p: Posizione) -> String? {
        campiVuoti(p).first.map(etichettaModulo)
    }

    /// Le righe di «Dati del contratto» con un valore (le vuote non si mostrano: sono in «Da completare»).
    static func righeContratto(_ p: Posizione, adesso: Date = Date()) -> [(etichetta: String, valore: String)] {
        let tipo = contratto(p)
        var r: [(etichetta: String, valore: String)] = []
        func aggiungi(_ e: String, _ v: String) { if !vuoto(v) { r.append((e, v)) } }
        aggiungi(tipo == .deposito ? "Numero del deposito" : "Numero", p.numeroContratto)
        aggiungi(tipo == .polizza ? "Contraente" : "Intestatario", p.contraente)
        aggiungi("Assicurato", p.assicurato)
        aggiungi("Beneficiari", p.beneficiari)
        if let d = p.decorrenza { aggiungi("Decorrenza", data(d)) }
        if let s = p.scadenza { aggiungi("Scadenza", data(s)) }
        if p.versamentoIniziale > 0 {
            aggiungi(p.area == .protezione ? "Premio unico" : "Versamento iniziale", Formati.euro(p.versamentoIniziale))
        }
        if p.frequenza != .unica {
            aggiungi(p.area == .debiti ? "Rata" : "Premio / versamento",
                     "\(Formati.euro(p.premio)) · \(p.frequenza.nome.lowercased()) (\(Formati.euro(p.premioAnnuo)) all'anno)")
        }
        if let v = p.totaleVersato { aggiungi("Totale versato", Formati.euro(v)) }
        if let v = p.controvalore, p.area != .protezione {
            aggiungi(p.area == .debiti ? "Debito residuo" : "Controvalore",
                     Formati.euro(v) + (p.dataValore.map { " al \(Formati.dataBreve.string(from: $0))" } ?? ""))
        }
        if let c = p.capitaleAssicurato {
            aggiungi("Capitale assicurato", Formati.euro(c) + (p.rischio.map { " · \($0.nome)" } ?? ""))
        }
        if p.stato == .proposta || p.esito == .accettata {
            aggiungi("Esito della proposta", TestiSeguito.esito(p, adesso: adesso))
        }
        if let n = p.seguito?.nota { aggiungi("Nota sull'esito", n) }
        aggiungi("Garanzie", p.garanzie)
        aggiungi("Note", p.note)
        return r
    }

    // MARK: - In breve

    /// «Come sta andando» senza il grafico: perché l'andamento non c'è ancora.
    static func andamentoCorto(conDecorrenza: Bool) -> String {
        conDecorrenza
            ? "Lo storico dei valori è ancora corto: l'andamento si vede dal secondo valore rilevato."
            : "Manca la decorrenza: l'andamento si vede quando ci sono la data d'inizio e un secondo valore."
    }

    /// «Se succede» di una copertura.
    static func seSuccede(_ p: Posizione) -> String {
        switch p.rischio {
        case .vita?: return "Il capitale va ai beneficiari, fuori dalla successione."
        case .infortuni?: return "Paga un capitale se l'assicurato subisce un infortunio."
        case .invalidita?: return "Paga un capitale o una rendita se l'assicurato perde la capacità di lavorare."
        case .ltc?: return "Paga una rendita se l'assicurato non è più autosufficiente."
        case .salute?: return "Rimborsa le spese mediche previste dalle condizioni."
        case .casa?: return "Ripaga i danni alla casa previsti dalle condizioni."
        case .rc?: return "Paga i danni causati ad altri, fino al massimale."
        case .altro?, nil: return "Paga quanto previsto dalle condizioni del contratto."
        }
    }

    /// «Da fare» di una copertura che scade presto.
    static func daFareScadenza(_ s: Date, nome: String, adesso: Date) -> String {
        giorni(a: s, da: adesso) < 0
            ? "È scaduta il \(data(s)): è tra le cose da fare per \(nome)."
            : "Scade il \(data(s)): è tra le cose da fare per \(nome)."
    }

    /// La card unica di conti, immobili e debiti.
    static func inBreveAltro(_ p: Posizione, mesiSpese: Double?, sogliaMesi: Int?) -> String {
        switch p.area {
        case .liquidita:
            let soglia = sogliaMesi ?? 6
            guard let m = mesiSpese else {
                return "Le spese della famiglia non sono indicate: Prisma non può dire quanti mesi copre la riserva."
            }
            return m >= Double(soglia)
                ? "La riserva supera i \(soglia) mesi di spese: il resto può lavorare."
                : "La riserva è sotto i \(soglia) mesi di spese: prima di investire conviene ricostruirla."
        case .immobili:
            return "Gli immobili non entrano nel patrimonio finanziario: contano nel patrimonio netto e nel passaggio generazionale."
        case .debiti:
            return "Il debito si sottrae dal patrimonio netto e, nel passaggio generazionale, dall'asse ereditario."
        default:
            return "La posizione è chiusa: non entra più nei conti del patrimonio."
        }
    }

    /// «A cosa risponde» di una proposta: l'obiettivo collegato nella scheda di adeguatezza o l'area.
    static func aCosaRisponde(_ p: Posizione, obiettivo: String?) -> String {
        if let o = obiettivo, !vuoto(o) { return "All'obiettivo «\(o)»." }
        return "All'area «\(p.area.nome)»."
    }

    /// «Cosa manca per chiuderla»: la risposta del cliente (finché non c'è un esito) e la firma dei moduli.
    static func cosaManca(_ p: Posizione, nome: String) -> [String] {
        var v: [String] = []
        let esito = p.esito ?? .bozza
        if esito == .bozza { v.append("Presentarla a \(nome)") }
        if esito == .bozza || esito == .presentata || esito == .rimandata { v.append("La risposta di \(nome)") }
        if esito != .rifiutata { v.append("La firma dei moduli") }
        return v
    }
}
