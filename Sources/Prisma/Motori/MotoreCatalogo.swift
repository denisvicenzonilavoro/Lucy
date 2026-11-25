import Foundation

// MARK: - Motore dei calcoli sul catalogo dei prodotti (fase 2)
//
// Puro: riceve una voce del catalogo (`VoceCatalogo`) e al massimo tre numeri (premio annuo o versamento, anno di
// inizio e, se serve, età, capitale o anni) e restituisce i pezzi del calcolo con i passi, uno per riga, in italiano
// («tocca e capisci»). Nessuna dipendenza dall'interfaccia, nessun consiglio, nessuna classifica tra prodotti.
//
// REGOLA FERREA: nessun numero inventato. Se un dato serve e manca, quel pezzo è `.nonDisponibile` («dato non
// disponibile nel catalogo»), mai zero, e il totale lo dice. Con un intervallo min-max nel catalogo il risultato è un
// intervallo. Le regole fiscali stanno in `FiscoCatalogo`; le formule sono quelle del foglio Leggimi del catalogo.

/// Una cifra del calcolo: un valore, un intervallo (quando il catalogo dà un minimo e un massimo) o un dato che manca.
enum CifraCatalogo: Equatable, Sendable {
    case valore(Double)
    case intervallo(min: Double, max: Double)
    case nonDisponibile

    /// Un intervallo con gli estremi uguali diventa un valore.
    static func da(_ a: Double, _ b: Double) -> CifraCatalogo {
        let lo = Swift.min(a, b), hi = Swift.max(a, b)
        return abs(hi - lo) < 1e-9 ? .valore(lo) : .intervallo(min: lo, max: hi)
    }

    var disponibile: Bool { self != .nonDisponibile }

    var minimo: Double? {
        switch self {
        case .valore(let v): return v
        case .intervallo(let a, _): return a
        case .nonDisponibile: return nil
        }
    }

    var massimo: Double? {
        switch self {
        case .valore(let v): return v
        case .intervallo(_, let b): return b
        case .nonDisponibile: return nil
        }
    }

    /// La cifra per un numero (non negativo).
    func per(_ k: Double) -> CifraCatalogo {
        switch self {
        case .valore(let v): return .valore(v * k)
        case .intervallo(let a, let b): return .da(a * k, b * k)
        case .nonDisponibile: return .nonDisponibile
        }
    }

    /// La somma: basta un dato mancante perché manchi la somma.
    static func + (a: CifraCatalogo, b: CifraCatalogo) -> CifraCatalogo {
        guard let a0 = a.minimo, let a1 = a.massimo, let b0 = b.minimo, let b1 = b.massimo else { return .nonDisponibile }
        return .da(a0 + b0, a1 + b1)
    }

    static func somma(_ cifre: [CifraCatalogo]) -> CifraCatalogo {
        cifre.reduce(CifraCatalogo.valore(0)) { $0 + $1 }
    }

    /// Il testo in euro («7,32 €», «da 250 € a 632 €» o «dato non disponibile nel catalogo»).
    var testoEuro: String {
        switch self {
        case .valore(let v): return MotoreCatalogo.euro(v)
        case .intervallo(let a, let b): return "da \(MotoreCatalogo.euro(a)) a \(MotoreCatalogo.euro(b))"
        case .nonDisponibile: return MotoreCatalogo.datoMancante
        }
    }
}

/// Un pezzo del risultato: il titolo, la cifra e i passi che la spiegano.
struct PezzoCalcolo: Identifiable, Equatable, Sendable {
    /// Chiave stabile del pezzo («imposte», «detrazione», «penale_oggi»…).
    var id: String
    var titolo: String
    var cifra: CifraCatalogo
    /// La percentuale usata, quando serve mostrarla (frazione: 0.0235 = 2,35%).
    var quota: Double?
    /// I passi del calcolo, uno per riga.
    var passi: [String]
    /// Il testo originale della cella, quando aiuta a capire il dato (mai una cifra calcolata).
    var nota: String?

    init(id: String, titolo: String, cifra: CifraCatalogo, quota: Double? = nil, passi: [String], nota: String? = nil) {
        self.id = id
        self.titolo = titolo
        self.cifra = cifra
        self.quota = quota
        self.passi = passi
        self.nota = nota
    }
}

/// La penale di riscatto in un anno di polizza.
struct PenaleAnno: Equatable, Sendable {
    enum Stato: Equatable, Sendable {
        /// La penale (frazione del versamento; 0 = nessuna penale).
        case quota(Double)
        /// In quell'anno il riscatto non è ancora possibile.
        case riscattoNonPossibile
        /// Il catalogo non dice la penale di quell'anno.
        case nonDisponibile
    }

    var anno: Int
    var stato: Stato
    /// La penale in euro sul versamento (`.nonDisponibile` se il riscatto non è possibile o la penale manca).
    var importo: CifraCatalogo
    var passo: String

    /// La penale come frazione, se il catalogo la dice.
    var quota: Double? {
        if case .quota(let q) = stato { return q }
        return nil
    }
}

/// I numeri che il consulente scrive: al massimo tre.
struct IngressoCatalogo: Equatable, Sendable {
    /// Il terzo numero, solo se serve.
    enum Terzo: Equatable, Sendable {
        /// Età dell'assicurato o dell'aderente.
        case eta(Int)
        /// Capitale assicurato (protezione) o saldo medio della posizione (previdenza).
        case capitale(Double)
        /// Anni di durata (protezione) o anni che mancano all'uscita (previdenza).
        case anni(Int)
    }

    /// Premio annuo (protezione) o versamento (investimento: unico; previdenza: annuo).
    var importo: Double
    var annoInizio: Int?
    var terzo: Terzo?

    init(importo: Double, annoInizio: Int? = nil, terzo: Terzo? = nil) {
        self.importo = importo
        self.annoInizio = annoInizio
        self.terzo = terzo
    }

    var eta: Int? { if case .eta(let e) = terzo { return e }; return nil }
    var capitale: Double? { if case .capitale(let c) = terzo { return c }; return nil }
    var anni: Int? { if case .anni(let n) = terzo { return n }; return nil }
}

/// Il risultato del calcolo su una voce.
struct RisultatoCatalogo: Equatable, Sendable {
    var voceId: String
    var foglio: FoglioCatalogo
    var nome: String
    var compagnia: String
    var pezzi: [PezzoCalcolo]
    /// Il totale: `.nonDisponibile` se manca un dato che gli serve (i passi dicono quale).
    var totale: PezzoCalcolo
    /// La somma dei soli pezzi del totale che ci sono, quando ne manca qualcuno: «almeno», mai il totale.
    var parzialeNoto: CifraCatalogo?
    /// Investimento: le penali di riscatto anno per anno.
    var penali: [PenaleAnno]
    /// Avvisi sui limiti del prodotto (età, capitale, premio minimo), detti con il testo del catalogo.
    var note: [String]
    var avvertenza: String
    var daSapere: String?
    var fonte: String?

    func pezzo(_ id: String) -> PezzoCalcolo? { pezzi.first { $0.id == id } ?? (totale.id == id ? totale : nil) }

    /// I titoli dei pezzi che mancano nel catalogo.
    var mancano: [String] { pezzi.filter { !$0.cifra.disponibile }.map(\.titolo) }

    /// Tutti i passi, pezzo per pezzo, poi il totale.
    var passi: [String] {
        pezzi.flatMap { [$0.titolo + ":"] + $0.passi } + [totale.titolo + ":"] + totale.passi
    }
}

enum MotoreCatalogo {
    static let datoMancante = CatalogoProdotti.testoMancanteDiBase
    static let avvertenzaDiBase = "Dati indicativi ricavati dai documenti pubblici della compagnia. Fanno fede i documenti contrattuali."

    static var annoDiOggi: Int { Calendar(identifier: .gregorian).component(.year, from: Date()) }

    // MARK: Ingresso

    /// Il calcolo giusto per il foglio della voce.
    static func calcola(_ voce: VoceCatalogo, _ ingresso: IngressoCatalogo, annoCorrente: Int = MotoreCatalogo.annoDiOggi,
                        beneficiarioDisabile: Bool = false, avvertenza: String = MotoreCatalogo.avvertenzaDiBase) -> RisultatoCatalogo {
        switch voce.foglio {
        case .protezione:
            return protezione(voce, ingresso, annoCorrente: annoCorrente, beneficiarioDisabile: beneficiarioDisabile, avvertenza: avvertenza)
        case .investimento:
            return investimento(voce, ingresso, annoCorrente: annoCorrente, avvertenza: avvertenza)
        case .previdenza:
            return previdenza(voce, ingresso, avvertenza: avvertenza)
        }
    }

    // MARK: Protezione

    static func protezione(_ voce: VoceCatalogo, _ ingresso: IngressoCatalogo, annoCorrente: Int = MotoreCatalogo.annoDiOggi,
                           beneficiarioDisabile: Bool = false, avvertenza: String = MotoreCatalogo.avvertenzaDiBase) -> RisultatoCatalogo {
        let p = Swift.max(0, ingresso.importo)
        let v = voce.valori
        let categoria = voce.testo["categoria"] ?? ""
        var pezzi: [PezzoCalcolo] = []

        // Imposte contenute nel premio: premio × aliquota / (1 + aliquota). Vince l'aliquota della riga.
        let imposte: PezzoCalcolo
        if let aliquota = v.numero("imposta_premio") {
            let ssn = v.numero("contributo_ssn")
            imposte = impostaContenuta(premio: p, aliquota: aliquota, contributoSSN: ssn,
                                       origine: "aliquota scritta nella riga del catalogo")
        } else if let ramo = FiscoCatalogo.Ramo(categoria: categoria) {
            imposte = impostaContenuta(premio: p, aliquota: ramo.imposta, contributoSSN: ramo.contributoSSN,
                                       origine: "aliquota di legge per \(ramo.nome) (indicativa, da verificare in polizza)")
        } else {
            imposte = PezzoCalcolo(id: "imposte", titolo: "Imposte nel premio", cifra: .nonDisponibile,
                                   passi: ["Il catalogo non indica l'aliquota e la categoria «\(categoria)» non ha un'aliquota di legge sicura: \(datoMancante)."],
                                   nota: voce.testo["imposta"])
        }
        pezzi.append(imposte)

        // Il premio senza imposte (base della quota all'intermediario).
        let imponibile: Double? = imposte.cifra.minimo.map { p - $0 }

        // Quanto del premio va in costi: caricamento, costi fissi, diritti.
        let notaCosti = voce.testo["premio_esempio"]
        if let c = v.numero("caricamento") {
            pezzi.append(PezzoCalcolo(id: "caricamento", titolo: "Caricamento", cifra: .valore(p * c), quota: c,
                                      passi: ["Premio annuo \(euro(p)) × caricamento \(percento(c)) = \(euro(p * c))"],
                                      nota: notaCosti))
        } else {
            pezzi.append(PezzoCalcolo(id: "caricamento", titolo: "Caricamento", cifra: .nonDisponibile,
                                      passi: ["Caricamento: \(datoMancante)."], nota: notaCosti))
        }
        if let f = v.numero("costi_fissi_euro") {
            pezzi.append(PezzoCalcolo(id: "costi_fissi", titolo: "Costi fissi", cifra: .valore(f),
                                      passi: ["Costi fissi indicati nel catalogo: \(euro(f))"], nota: notaCosti))
        }
        if let d = v.numero("diritti_euro") {
            pezzi.append(PezzoCalcolo(id: "diritti", titolo: "Diritti", cifra: .valore(d),
                                      passi: ["Diritti indicati nel catalogo: \(euro(d))"], nota: notaCosti))
        }

        // All'intermediario: quota × premio senza imposte.
        if let q = v.numero("quota_intermediario") {
            if let base = imponibile {
                pezzi.append(PezzoCalcolo(id: "intermediario", titolo: "All'intermediario", cifra: .valore(base * q), quota: q,
                                          passi: ["Premio senza imposte \(euro(base)) × quota all'intermediario \(percento(q)) = \(euro(base * q))"],
                                          nota: notaCosti))
            } else {
                pezzi.append(PezzoCalcolo(id: "intermediario", titolo: "All'intermediario", cifra: .nonDisponibile, quota: q,
                                          passi: ["Quota all'intermediario \(percento(q)) del premio senza imposte, ma l'imposta non è nel catalogo: \(datoMancante)."],
                                          nota: notaCosti))
            }
        } else {
            pezzi.append(PezzoCalcolo(id: "intermediario", titolo: "All'intermediario", cifra: .nonDisponibile,
                                      passi: ["Quota all'intermediario: \(datoMancante)."], nota: notaCosti))
        }

        // Detrazione possibile.
        pezzi.append(detrazioneVoce(voce, premio: p, beneficiarioDisabile: beneficiarioDisabile))

        // Maggiorazione di frazionamento, se il catalogo la indica.
        if let f = v.intervallo("frazionamento") {
            pezzi.append(premioFrazionato(premio: p, maggiorazioneMin: f.min, maggiorazioneMax: f.max))
        }

        // Premi già pagati, dall'anno di inizio.
        if let inizio = ingresso.annoInizio, inizio <= annoCorrente {
            let anni = annoCorrente - inizio + 1
            pezzi.append(PezzoCalcolo(id: "gia_pagati", titolo: "Premi già pagati", cifra: .valore(p * Double(anni)),
                                      passi: ["Dal \(inizio) al \(annoCorrente): \(anni) \(anni == 1 ? "anno" : "anni"), contando l'anno in corso",
                                              "Premio annuo \(euro(p)) × \(anni) = \(euro(p * Double(anni)))"]))
        }

        // Costo totale sulla durata.
        let totale: PezzoCalcolo
        var anniDurata: Int?
        var passiDurata: [String] = []
        if let n = ingresso.anni, n > 0 {
            anniDurata = n
            passiDurata.append("Durata indicata: \(n) \(n == 1 ? "anno" : "anni")")
        } else if let eta = ingresso.eta, let massima = v.numero("eta_massima") {
            let n = Int(massima.rounded(.down)) - eta
            if n > 0 {
                anniDurata = n
                passiDurata.append("Età massima del catalogo \(numero(massima)) anni − età \(eta) = \(n) anni (se la tieni fino alla fine)")
            }
        }
        if let n = anniDurata {
            totale = PezzoCalcolo(id: "totale", titolo: "Costo totale sulla durata", cifra: .valore(p * Double(n)),
                                  passi: passiDurata + ["Premio annuo \(euro(p)) × \(n) = \(euro(p * Double(n)))",
                                                        "Premi costanti: se il premio cresce con l'età, il costo vero è diverso."])
        } else {
            totale = PezzoCalcolo(id: "totale", titolo: "Costo totale sulla durata", cifra: .nonDisponibile,
                                  passi: ["Serve la durata: indica gli anni o l'età (con l'età massima nel catalogo). Ora: \(datoMancante)."],
                                  nota: voce.testo["durata"])
        }

        var note: [String] = []
        if let eta = ingresso.eta {
            let ingressoTesto = voce.testo["eta_ingresso"]
            if let lo = v.numero("eta_ingresso_min").map({ Int($0) }), eta < lo {
                let limite = ingressoTesto ?? "\(lo) anni"
                note.append("Età \(eta): sotto l'età d'ingresso del catalogo (\(limite))")
            }
            if let hi = v.numero("eta_ingresso_max").map({ Int($0) }), hi > (v.numero("eta_ingresso_min").map({ Int($0) }) ?? 0), eta > hi {
                let limite = ingressoTesto ?? "\(hi) anni"
                note.append("Età \(eta): sopra l'età d'ingresso del catalogo (\(limite))")
            }
        }
        if let c = ingresso.capitale, let massimo = v.numero("capitale_massimo_euro"), c > massimo {
            note.append("Capitale \(euro(c)): sopra il massimo del catalogo (\(voce.testo["capitali"] ?? euro(massimo)))")
        }
        if let minimo = v.numero("premio_minimo_euro"), p < minimo {
            note.append("Premio \(euro(p)): sotto il premio minimo del catalogo (\(euro(minimo)))")
        }

        return RisultatoCatalogo(voceId: voce.id, foglio: voce.foglio, nome: voce.nomeCompleto, compagnia: voce.compagnia,
                                 pezzi: pezzi, totale: totale, parzialeNoto: nil, penali: [], note: note,
                                 avvertenza: avvertenza, daSapere: voce.daSapere, fonte: voce.fonte)
    }

    /// Imposta contenuta in un premio lordo: premio × aliquota / (1 + aliquota). Con l'RC auto l'aliquota è l'imposta più
    /// il contributo SSN.
    static func impostaContenuta(premio: Double, aliquota: Double, contributoSSN: Double? = nil,
                                 origine: String? = nil) -> PezzoCalcolo {
        let totale = aliquota + (contributoSSN ?? 0)
        let importo = premio * totale / (1 + totale)
        var passi: [String] = []
        if totale == 0 {
            passi.append("Imposta sul premio: esente (0%) secondo il catalogo")
        } else if let ssn = contributoSSN {
            passi.append("Premio annuo \(euro(premio)) × (imposta \(percento(aliquota)) + SSN \(percento(ssn))) / \(numero(1 + totale)) = \(euro(importo))")
        } else {
            passi.append("Premio annuo \(euro(premio)) × imposta \(percento(aliquota)) / \(numero(1 + totale)) = \(euro(importo))")
        }
        if let o = origine { passi.append("Fonte dell'aliquota: \(o)") }
        return PezzoCalcolo(id: "imposte", titolo: "Imposte nel premio", cifra: .valore(importo), quota: totale, passi: passi)
    }

    /// Detrazione IRPEF possibile: min(premio, massimale) × aliquota.
    static func detrazione(premio: Double, aliquota: Double = FiscoCatalogo.aliquotaDetrazione, massimale: Double) -> PezzoCalcolo {
        let base = Swift.min(premio, massimale)
        let importo = base * aliquota
        return PezzoCalcolo(id: "detrazione", titolo: "Detrazione possibile", cifra: .valore(importo), quota: aliquota,
                            passi: ["min(premio \(euro(premio)); massimale \(euro(massimale))) = \(euro(base))",
                                    "\(euro(base)) × \(percento(aliquota)) = \(euro(importo))",
                                    "Si riduce fino ad azzerarsi per redditi oltre \(euro(FiscoCatalogo.redditoRiduzioneDetrazione))."])
    }

    /// La detrazione di una voce: aliquota e massimale della riga, o il massimale di legge per la sua categoria.
    static func detrazioneVoce(_ voce: VoceCatalogo, premio: Double, beneficiarioDisabile: Bool = false) -> PezzoCalcolo {
        let v = voce.valori
        let nota = voce.testo["detraibilita"]
        guard let aliquota = v.numero("detrazione") else {
            return PezzoCalcolo(id: "detrazione", titolo: "Detrazione possibile", cifra: .nonDisponibile,
                                passi: ["Il catalogo non dice se il premio è detraibile: \(datoMancante)."], nota: nota)
        }
        if aliquota == 0 {
            return PezzoCalcolo(id: "detrazione", titolo: "Detrazione possibile", cifra: .valore(0), quota: 0,
                                passi: ["Premio non detraibile secondo il catalogo"], nota: nota)
        }
        let regola = FiscoCatalogo.Detrazione(categoria: voce.testo["categoria"] ?? "")
        var massimale = v.numero("detrazione_massimale_euro") ?? regola?.massimale()
        // 750 € al posto di 530 € se il beneficiario è un familiare con disabilità grave (solo TCM e infortuni).
        if beneficiarioDisabile, let m = massimale, m == FiscoCatalogo.massimaleTCMInfortuni, regola != .ltc {
            massimale = FiscoCatalogo.massimaleTCMDisabilitaGrave
        }
        guard let m = massimale else {
            return PezzoCalcolo(id: "detrazione", titolo: "Detrazione possibile", cifra: .nonDisponibile, quota: aliquota,
                                passi: ["Detraibile al \(percento(aliquota)), ma il massimale non è nel catalogo: \(datoMancante)."], nota: nota)
        }
        var pezzo = detrazione(premio: premio, aliquota: aliquota, massimale: m)
        pezzo.nota = nota
        if beneficiarioDisabile, m == FiscoCatalogo.massimaleTCMDisabilitaGrave {
            pezzo.passi.insert("Beneficiario con disabilità grave: massimale \(euro(m))", at: 0)
        }
        return pezzo
    }

    /// Premio annuo con il frazionamento: premio × (1 + maggiorazione). Un intervallo se la maggiorazione lo è.
    static func premioFrazionato(premio: Double, maggiorazioneMin: Double, maggiorazioneMax: Double) -> PezzoCalcolo {
        let cifra = CifraCatalogo.da(premio * (1 + maggiorazioneMin), premio * (1 + maggiorazioneMax))
        let passi: [String]
        if abs(maggiorazioneMax - maggiorazioneMin) < 1e-9 {
            passi = ["Premio annuo \(euro(premio)) × \(numero(1 + maggiorazioneMin)) = \(euro(premio * (1 + maggiorazioneMin)))"]
        } else {
            passi = ["Premio annuo \(euro(premio)) × da \(numero(1 + maggiorazioneMin)) a \(numero(1 + maggiorazioneMax)) = \(cifra.testoEuro)"]
        }
        return PezzoCalcolo(id: "frazionamento", titolo: "Premio pagato a rate", cifra: cifra, quota: maggiorazioneMax,
                            passi: passi + ["Maggiorazione: \(euro(cifra.massimo.map { $0 - premio } ?? 0)) in più l'anno al massimo"])
    }

    /// Quanto paga un'invalidità con franchigia: capitale × (invalidità − franchigia); zero sotto la franchigia.
    static func indennizzoInvalidita(capitale: Double, invalidita: Double, franchigia: Double) -> PezzoCalcolo {
        let quota = Swift.max(0, invalidita - franchigia)
        let importo = capitale * quota
        var passi = ["Capitale \(euro(capitale)) × (invalidità \(percento(invalidita)) − franchigia \(percento(franchigia))) = \(euro(importo))"]
        if invalidita <= franchigia { passi.append("Invalidità non oltre la franchigia: non è pagata") }
        return PezzoCalcolo(id: "indennizzo", titolo: "Indennizzo per invalidità", cifra: .valore(importo), quota: quota, passi: passi)
    }

    // MARK: Investimento

    static func investimento(_ voce: VoceCatalogo, _ ingresso: IngressoCatalogo, annoCorrente: Int = MotoreCatalogo.annoDiOggi,
                             avvertenza: String = MotoreCatalogo.avvertenzaDiBase) -> RisultatoCatalogo {
        let versamento = Swift.max(0, ingresso.importo)
        let v = voce.valori
        var pezzi: [PezzoCalcolo] = []

        func intervallo(_ id: String, _ titolo: String, _ base: String, _ cosa: String, nota: String?) -> PezzoCalcolo {
            guard let r = v.intervallo(base) else {
                return PezzoCalcolo(id: id, titolo: titolo, cifra: .nonDisponibile, passi: ["\(cosa): \(datoMancante)."], nota: nota)
            }
            let cifra = CifraCatalogo.da(versamento * r.min, versamento * r.max)
            let quota = abs(r.max - r.min) < 1e-9 ? percento(r.min) : "da \(percento(r.min)) a \(percento(r.max))"
            return PezzoCalcolo(id: id, titolo: titolo, cifra: cifra, quota: r.max,
                                passi: ["Versamento \(euro(versamento)) × \(cosa.lowercased()) \(quota) = \(cifra.testoEuro)"], nota: nota)
        }

        pezzi.append(intervallo("ingresso", "Costi di ingresso", "costo_ingresso", "Costo di ingresso", nota: voce.testo["costo_ingresso"]))
        if let f = v.numero("costi_fissi_euro") {
            pezzi.append(PezzoCalcolo(id: "costi_fissi", titolo: "Costi fissi", cifra: .valore(f),
                                      passi: ["Costi fissi indicati nel catalogo: \(euro(f))"], nota: voce.testo["costi_fissi"]))
        } else {
            pezzi.append(PezzoCalcolo(id: "costi_fissi", titolo: "Costi fissi", cifra: .nonDisponibile,
                                      passi: ["Costi fissi: \(datoMancante)."], nota: voce.testo["costi_fissi"]))
        }
        let haGestione = v.intervallo("costo_gestione_separata") != nil
        let haFondi = v.intervallo("costo_fondi") != nil
        if haGestione {
            pezzi.append(intervallo("gestione_separata", "Gestione separata, ogni anno", "costo_gestione_separata",
                                    "Costo della gestione separata", nota: voce.testo["costo_gestione_separata"]))
        }
        if haFondi {
            pezzi.append(intervallo("gestione_fondi", "Fondi, ogni anno", "costo_fondi", "Costo dei fondi", nota: voce.testo["costo_fondi"]))
        }
        if !haGestione && !haFondi {
            pezzi.append(PezzoCalcolo(id: "gestione", titolo: "Costi di gestione, ogni anno", cifra: .nonDisponibile,
                                      passi: ["Costi di gestione: \(datoMancante)."]))
        }
        if haGestione && haFondi {
            pezzi[pezzi.count - 1].passi.append("Multiramo: ogni costo vale sulla sua parte del versamento; qui è calcolato sul versamento intero.")
        }

        // Incidenza dei costi dal KID: 1° anno (K) e al periodo raccomandato (L).
        pezzi.append(intervallo("primo_anno", "Costi del 1° anno (KID)", "incidenza_primo_anno", "Incidenza dei costi al 1° anno",
                                nota: voce.testo["incidenza_primo_anno"]))
        let annuo = intervallo("periodo_annuo", "Costi annui al periodo raccomandato (KID)", "incidenza_periodo",
                               "Incidenza dei costi al periodo raccomandato", nota: voce.testo["incidenza_periodo_raccomandato"])
        pezzi.append(annuo)

        // Bollo.
        switch v.scelta("bollo") {
        case .some(true):
            let b = versamento * FiscoCatalogo.bollo
            pezzi.append(PezzoCalcolo(id: "bollo", titolo: "Imposta di bollo, ogni anno", cifra: .valore(b), quota: FiscoCatalogo.bollo,
                                      passi: ["Versamento \(euro(versamento)) × bollo \(percento(FiscoCatalogo.bollo)) = \(euro(b))",
                                              "Sul controvalore della parte in fondi (la gestione separata è esente): con una multiramo è il massimo."],
                                      nota: voce.testo["bollo"]))
        case .some(false):
            pezzi.append(PezzoCalcolo(id: "bollo", titolo: "Imposta di bollo, ogni anno", cifra: .valore(0), quota: 0,
                                      passi: ["Bollo non dovuto secondo il catalogo"], nota: voce.testo["bollo"]))
        case .none:
            pezzi.append(PezzoCalcolo(id: "bollo", titolo: "Imposta di bollo, ogni anno", cifra: .nonDisponibile,
                                      passi: ["Bollo: \(datoMancante)."], nota: voce.testo["bollo"]))
        }

        // Penali di riscatto anno per anno e quella di oggi.
        let tabella = penali(voce, versamento: versamento)
        if v.penaliPerAnno == nil {
            pezzi.append(PezzoCalcolo(id: "penali", titolo: "Penali di riscatto", cifra: .nonDisponibile,
                                      passi: ["Penali di riscatto: \(datoMancante)."], nota: voce.testo["penali"]))
        }
        if let inizio = ingresso.annoInizio, inizio <= annoCorrente {
            let annoPolizza = annoCorrente - inizio + 1
            let passoAnno = "Dal \(inizio) al \(annoCorrente): \(annoPolizza)° anno di polizza"
            if let p = tabella.first(where: { $0.anno == annoPolizza }) {
                pezzi.append(PezzoCalcolo(id: "penale_oggi", titolo: "Penale se riscatti quest'anno", cifra: p.importo,
                                          quota: p.quota,
                                          passi: [passoAnno, p.passo], nota: voce.testo["penali"]))
            } else if v.penaliPerAnno != nil {
                pezzi.append(PezzoCalcolo(id: "penale_oggi", titolo: "Penale se riscatti quest'anno", cifra: .nonDisponibile,
                                          passi: [passoAnno, "Penale di quell'anno: \(datoMancante)."], nota: voce.testo["penali"]))
            }
        }

        // Totale: costi al periodo raccomandato = versamento × incidenza annua × anni del periodo.
        let totale: PezzoCalcolo
        if let n = v.numero("periodo_anni").map({ Int($0) }), n > 0, annuo.cifra.disponibile {
            let cifra = annuo.cifra.per(Double(n))
            totale = PezzoCalcolo(id: "totale", titolo: "Costi sul periodo raccomandato (\(n) anni)", cifra: cifra,
                                  passi: ["Costi annui \(annuo.cifra.testoEuro) × \(n) anni = \(cifra.testoEuro)",
                                          "L'incidenza del KID è già una media annua di tutti i costi (ingresso, gestione, uscita)."],
                                  nota: voce.testo["periodo_raccomandato"])
        } else {
            var mancante: [String] = []
            if !annuo.cifra.disponibile { mancante.append("incidenza dei costi al periodo raccomandato") }
            if v.numero("periodo_anni") == nil { mancante.append("periodo raccomandato") }
            totale = PezzoCalcolo(id: "totale", titolo: "Costi sul periodo raccomandato", cifra: .nonDisponibile,
                                  passi: ["Manca: \(mancante.joined(separator: ", ")). Il totale è \(datoMancante)."],
                                  nota: voce.testo["periodo_raccomandato"])
        }

        var note: [String] = []
        if let minimo = v.numero("premio_minimo_euro"), versamento < minimo {
            note.append("Versamento \(euro(versamento)): sotto il premio minimo del catalogo (\(euro(minimo)))")
        }
        if let eta = ingresso.eta, let lo = v.numero("eta_min"), let hi = v.numero("eta_max"), Double(eta) < lo || Double(eta) > hi {
            let limite = voce.testo["eta"] ?? "\(Int(lo)) - \(Int(hi)) anni"
            note.append("Età \(eta): fuori dalle età del catalogo (\(limite))")
        }

        return RisultatoCatalogo(voceId: voce.id, foglio: voce.foglio, nome: voce.nomeCompleto, compagnia: voce.compagnia,
                                 pezzi: pezzi, totale: totale, parzialeNoto: nil, penali: tabella, note: note,
                                 avvertenza: avvertenza, daSapere: voce.daSapere, fonte: voce.fonte)
    }

    /// Le penali di riscatto anno per anno, dal campo `penali_per_anno`; vuoto se il catalogo non le dice. Dopo l'ultimo
    /// anno della tabella la penale è zero solo se il documento lo scrive («poi 0», «dal 6° nessuna»), altrimenti manca.
    static func penali(_ voce: VoceCatalogo, versamento: Double) -> [PenaleAnno] {
        let v = voce.valori
        guard let tabella = v.penaliPerAnno else { return [] }
        let ultimoDellaTabella = tabella.keys.max() ?? 0
        let periodo = v.numero("periodo_anni").map({ Int($0) }) ?? 0
        let ultimo = Swift.min(30, Swift.max(1, periodo, ultimoDellaTabella + 1))
        let testoPenali = CatalogoProdotti.normalizza(voce.testo["penali"] ?? "")
        let zeroDopo = testoPenali.contains("poi 0") || testoPenali.contains("nessuna")
        let mesi = v.numero("riscatto_dopo_mesi").map({ Int($0) })
        let dalAnno = v.numero("riscatto_dal_anno").map({ Int($0) })
        let giorni = v.numero("riscatto_dopo_giorni").map({ Int($0) })

        return (1...ultimo).map { anno in
            let etichetta = "\(anno)° anno"
            let bloccato = (mesi.map { $0 >= 12 * anno } ?? false) || (dalAnno.map { anno < $0 } ?? false)
                || (giorni.map { $0 >= 365 * anno } ?? false)
            if bloccato {
                return PenaleAnno(anno: anno, stato: .riscattoNonPossibile, importo: .nonDisponibile,
                                  passo: "\(etichetta): riscatto non ancora possibile (\(voce.testo["riscattabile_da"] ?? "vedi il catalogo"))")
            }
            let quota: Double?
            if let q = tabella[anno] {
                quota = q
            } else if tabella.isEmpty {
                quota = 0
            } else if anno > ultimoDellaTabella {
                quota = zeroDopo ? 0 : nil
            } else {
                quota = nil
            }
            guard let q = quota else {
                return PenaleAnno(anno: anno, stato: .nonDisponibile, importo: .nonDisponibile,
                                  passo: "\(etichetta): penale \(datoMancante)")
            }
            let importo = versamento * q
            let passo = q == 0 ? "\(etichetta): nessuna penale"
                : "\(etichetta): versamento \(euro(versamento)) × penale \(percento(q)) = \(euro(importo))"
            return PenaleAnno(anno: anno, stato: .quota(q), importo: .valore(importo), passo: passo)
        }
    }

    // MARK: Previdenza

    /// Gli orizzonti dell'ISC nel catalogo (anni).
    static let orizzontiISC = [2, 5, 10, 35]

    /// L'ISC all'orizzonte più vicino tra quelli che il catalogo ha (a pari distanza il più corto).
    static func iscPiuVicino(_ voce: VoceCatalogo, orizzonte: Int) -> (anni: Int, isc: Double)? {
        let presenti = orizzontiISC.compactMap { n in voce.valori.numero("isc_\(n)").map { (anni: n, isc: $0) } }
        return presenti.min { a, b in
            let da = abs(a.anni - orizzonte), db = abs(b.anni - orizzonte)
            return da != db ? da < db : a.anni < b.anni
        }
    }

    static func previdenza(_ voce: VoceCatalogo, _ ingresso: IngressoCatalogo, avvertenza: String = MotoreCatalogo.avvertenzaDiBase) -> RisultatoCatalogo {
        let versamento = Swift.max(0, ingresso.importo)
        let v = voce.valori
        var parti: [PezzoCalcolo] = []

        func fisso(_ id: String, _ titolo: String, _ campo: String, _ colonna: String) -> PezzoCalcolo {
            guard let e = v.numero(campo) else {
                return PezzoCalcolo(id: id, titolo: titolo, cifra: .nonDisponibile, passi: ["\(titolo): \(datoMancante)."], nota: voce.testo[colonna])
            }
            return PezzoCalcolo(id: id, titolo: titolo, cifra: .valore(e), passi: ["\(titolo): \(euro(e))"], nota: voce.testo[colonna])
        }

        parti.append(fisso("adesione", "Spese di adesione", "spese_adesione_euro", "spese_adesione"))
        parti.append(fisso("spese_annue", "Spese annue fisse", "spese_annue_euro", "spese_annue"))
        if let c = v.numero("caricamento_versamenti") {
            parti.append(PezzoCalcolo(id: "caricamento", titolo: "Caricamento sui versamenti", cifra: .valore(versamento * c), quota: c,
                                      passi: ["Versamento \(euro(versamento)) × caricamento \(percento(c)) = \(euro(versamento * c))"],
                                      nota: voce.testo["caricamento_versamenti"]))
        } else {
            parti.append(PezzoCalcolo(id: "caricamento", titolo: "Caricamento sui versamenti", cifra: .nonDisponibile,
                                      passi: ["Caricamento sui versamenti: \(datoMancante)."], nota: voce.testo["caricamento_versamenti"]))
        }
        // Saldo medio: quello scritto dal consulente, o metà del versamento (versamenti distribuiti nell'anno, detto).
        let saldo: Double
        let passoSaldo: String
        if let s = ingresso.capitale {
            saldo = s
            passoSaldo = "Saldo medio indicato: \(euro(s))"
        } else {
            saldo = versamento / 2
            passoSaldo = "Saldo medio del 1° anno: versamento \(euro(versamento)) / 2 = \(euro(saldo)) (versamenti distribuiti nell'anno)"
        }
        if let g = v.numero("costo_gestione") {
            parti.append(PezzoCalcolo(id: "gestione", titolo: "Costo di gestione", cifra: .valore(saldo * g), quota: g,
                                      passi: [passoSaldo, "Saldo medio \(euro(saldo)) × gestione \(percento(g)) = \(euro(saldo * g))"],
                                      nota: voce.testo["costo_gestione"]))
        } else {
            parti.append(PezzoCalcolo(id: "gestione", titolo: "Costo di gestione", cifra: .nonDisponibile,
                                      passi: ["Costo di gestione: \(datoMancante)."], nota: voce.testo["costo_gestione"]))
        }

        // Totale del 1° anno = adesione + spese annue + versamento × caricamento + saldo medio × gestione.
        let somma = CifraCatalogo.somma(parti.map(\.cifra))
        let manca = parti.filter { !$0.cifra.disponibile }
        let totale: PezzoCalcolo
        var parziale: CifraCatalogo?
        if manca.isEmpty {
            totale = PezzoCalcolo(id: "totale", titolo: "Costo del 1° anno", cifra: somma,
                                  passi: [parti.map { $0.cifra.testoEuro }.joined(separator: " + ") + " = \(somma.testoEuro)"])
        } else {
            let noti = CifraCatalogo.somma(parti.filter(\.cifra.disponibile).map(\.cifra))
            parziale = noti
            totale = PezzoCalcolo(id: "totale", titolo: "Costo del 1° anno", cifra: .nonDisponibile,
                                  passi: ["Manca: \(manca.map { $0.titolo.lowercased() }.joined(separator: ", ")). Il totale è \(datoMancante).",
                                          "Le parti che ci sono fanno almeno \(noti.testoEuro)."])
        }

        var pezzi = parti
        // Lungo periodo: l'ISC all'orizzonte più vicino.
        if let anni = ingresso.anni, anni > 0 {
            if let scelto = iscPiuVicino(voce, orizzonte: anni) {
                let versato = versamento * Double(anni)
                let costo = versato * scelto.isc
                let vicino = scelto.anni == anni ? "" : " (l'orizzonte più vicino a \(anni))"
                var passi = ["ISC a \(scelto.anni) anni\(vicino): \(percento(scelto.isc)) l'anno"]
                passi.append("Versato in \(anni) anni: \(euro(versamento)) × \(anni) = \(euro(versato))")
                passi.append("\(euro(versato)) × \(percento(scelto.isc)) = \(euro(costo)) nell'ultimo anno (sui soli versamenti, senza rendimenti: indicativo)")
                pezzi.append(PezzoCalcolo(id: "lungo_periodo", titolo: "Costi nel lungo periodo (ISC)", cifra: .valore(costo),
                                          quota: scelto.isc, passi: passi, nota: voce.testo["isc_\(scelto.anni)"]))
            } else {
                pezzi.append(PezzoCalcolo(id: "lungo_periodo", titolo: "Costi nel lungo periodo (ISC)", cifra: .nonDisponibile,
                                          passi: ["ISC: \(datoMancante)."]))
            }
        } else {
            pezzi.append(PezzoCalcolo(id: "lungo_periodo", titolo: "Costi nel lungo periodo (ISC)", cifra: .nonDisponibile,
                                      passi: ["Indica gli anni che mancano all'uscita per scegliere l'ISC (2, 5, 10 o 35 anni)."]))
        }

        return RisultatoCatalogo(voceId: voce.id, foglio: voce.foglio, nome: voce.nomeCompleto, compagnia: voce.compagnia,
                                 pezzi: pezzi, totale: totale, parzialeNoto: parziale, penali: [], note: [],
                                 avvertenza: avvertenza, daSapere: voce.daSapere, fonte: voce.fonte)
    }

    // MARK: Testi delle cifre

    private static let formatoNumero: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Formati.localeImporti
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 4
        f.minusSign = Formati.meno
        return f
    }()

    /// «300 €» per le cifre tonde, «7,32 €» con i centesimi.
    static func euro(_ v: Double) -> String {
        abs(v - v.rounded()) < 0.005 ? Formati.euro(v) : Formati.euroDecimali(v)
    }

    /// Una frazione come percentuale: 0.025 → «2,5%».
    static func percento(_ frazione: Double) -> String {
        Formati.percentuale((frazione * 10_000).rounded() / 100)
    }

    /// Un numero con fino a quattro decimali: 1.025 → «1,025».
    static func numero(_ v: Double) -> String {
        formatoNumero.string(from: NSNumber(value: v)) ?? "\(v)"
    }
}
