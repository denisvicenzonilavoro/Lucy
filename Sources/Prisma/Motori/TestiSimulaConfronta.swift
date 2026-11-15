import Foundation

/// Migliorie d'uso 64 «Simula e confronta: prima la frase»: i testi della vista (Design/uso/gruppo-12.md §64.3 punto 8),
/// le frasi in cima alla colonna di destra e le righe della tabella. Le cifre arrivano già calcolate da
/// `MotoreSimulaConfronta` (cioè da `MotoreProiezione`).
enum TestiSimulaConfronta {
    // MARK: Voci e titoli
    static let titolo = "Simula e confronta"
    static let unaStrada = "Una strada"
    static let dueAConfronto = "Due a confronto"
    /// Migliorie d'uso 69: la terza voce del segmentato.
    static let ilTFR = "Il TFR"
    static let laStrada = "La strada"
    static let leDueStrade = "Le due strade"
    static let iSoldi = "I soldi"
    static let iSoldiUguali = "I soldi, uguali per tutte e due"
    static let quantoOggi = "Quanto mette oggi"
    static let quantoMese = "Quanto mette al mese"
    static let quantiAnni = "Per quanti anni"
    static let cambia = "Cambia"
    static let tasse = "Tasse sul guadagno"
    static let inflazione = "Inflazione"
    static let ipotesiComuni = "Le ipotesi di tutte le strade"
    static let aiutoStrada = "Scegli la strada: una posizione, una proposta, una scheda del catalogo o il conto"

    // MARK: Provenienze e gruppi del menu
    static let haGia = "ce l’ha già"
    static let proposta = "proposta"
    static let dalCatalogo = "dal catalogo"
    static let nonFareNiente = "non fare niente"
    static let conto = "Lasciare i soldi sul conto"
    static let ipotesiMia = "Un’ipotesi mia"
    static let ipotesiMiaMenu = "Un’ipotesi mia…"
    static let ipotesiMiaProvenienza = "ipotesi mia"
    static let gruppoHaGia = "Ce l’ha già"
    static let gruppoProposte = "Proposte"
    static let gruppoCatalogo = "Dal catalogo"
    static let gruppoSalvate = "Ipotesi salvate"
    static let gruppoMia = "Ipotesi mia"
    static let gruppoConto = "Non fare niente"
    static let rendimentoMia = "Rendimento annuo"
    static let costoIngressoMia = "Costo d’ingresso"
    static let costoAnnuoMia = "Costo annuo"
    static let canaleMia = "Canale"
    static let canaleNessuno = "Nessuno"
    static let canaleAlleanza = "Alleanza"
    static let canaleIndipendente = "Indip."

    static func salvata(_ data: Date) -> String { "salvata il \(Formati.giornoMese.string(from: data))" }

    /// «ce l’ha già · rende 3,5%, costa 1,2% l’anno»
    static func riga(_ o: OpzioneStrada) -> String {
        "\(o.provenienza) · rende \(Formati.percentuale(arrotonda(o.rendimento))), costa \(Formati.percentuale(arrotonda(o.costoAnnuo))) l’anno"
    }

    /// La riga delle ipotesi in grigio, sotto i cursori.
    static func ipotesi(_ i: IpotesiSimula) -> String {
        "Le ipotesi: rendimento e costi di ogni strada come scritto sopra; tasse al \(Formati.percentuale(i.tasse)) sul guadagno; inflazione al \(Formati.percentuale(i.inflazione)) per «in soldi di oggi»."
    }

    static func anni(_ n: Int) -> String { n == 1 ? "1 anno" : "\(n) anni" }

    // MARK: Una strada

    static func occhielloUna(_ nome: String) -> String { "Con «\(nome)»" }

    /// «Tra 10 anni avrà circa »: la cifra (in accento) la aggiunge la vista, poi il punto.
    static func fraseUnaPrima(anni n: Int) -> String { "Tra \(anni(n)) avrà circa " }
    static let fraseUnaDopo = "."

    /// La cifra «circa»: arrotondata alle centinaia.
    static func circa(_ v: Double) -> String { Formati.euro((v / 100).rounded() * 100) }

    /// La frase intera (per la prova e per l'accessibilità).
    static func fraseUna(_ e: EsitoStrada, anni n: Int) -> String {
        fraseUnaPrima(anni: n) + circa(e.esito.netto) + fraseUnaDopo
    }

    /// «Ne avrà versati …: il resto, …, è crescita, già tolti … di costi e … di tasse. In soldi di oggi sono ….»
    static func sottoFraseUna(_ e: EsitoStrada) -> String {
        let x = e.esito
        let tolti = "già tolti \(Formati.euro(x.costi)) di costi e \(Formati.euro(x.imposte)) di tasse"
        let crescita = x.guadagnoNetto >= 0
            ? "il resto, \(Formati.euro(x.guadagnoNetto)), è crescita, \(tolti)."
            : "ne restano \(Formati.euro(-x.guadagnoNetto)) in meno, \(tolti)."
        return "Ne avrà versati \(Formati.euro(x.versato)): \(crescita) In soldi di oggi sono \(Formati.euro(x.reale))."
    }

    // MARK: Se va diversamente

    static let seVaDiversamente = "Se va diversamente"
    static let male = "Male"
    static let comePrevisto = "Come previsto"
    static let bene = "Bene"

    /// La nota di ogni riga: lo scarto vero (due punti, o lo scenario del KID).
    static func notaScenario(_ indice: Int, rendimento: Double, kid: Bool) -> String {
        let punti = IpotesiCalcolo.ampiezzaScenari == 2 ? "due punti" : "\(Formati.percentuale(IpotesiCalcolo.ampiezzaScenari).dropLast()) punti"
        switch indice {
        case 0: return kid ? "come nello scenario sfavorevole del KID" : "\(punti) in meno l’anno"
        case 2: return kid ? "come nello scenario favorevole del KID" : "\(punti) in più l’anno"
        default: return "\(Formati.percentuale(arrotonda(rendimento))) l’anno"
        }
    }

    static func nomeScenario(_ indice: Int) -> String {
        switch indice {
        case 0: return male
        case 2: return bene
        default: return comePrevisto
        }
    }

    static let annoPerAnno = "Anno per anno, al netto"
    static let versato = "versato"
    static let oggi = "oggi"
    static func traAnni(_ n: Int) -> String { "tra \(anni(n))" }
    static let comeCalcolato = "Come viene calcolato?"
    static let nascondiMetodo = "Nascondi il metodo"
    static let metodo = "Il rendimento è annuo effettivo e diventa mensile equivalente: (1 + r)^(1/12) − 1. I versamenti entrano a inizio mese al netto del costo d'ingresso, che si applica anche al capitale iniziale; ogni mese si paga la quota del costo annuo. Alla fine le tasse si applicano alla sola parte che supera il versato, e il valore in soldi di oggi divide il netto per l'inflazione cumulata. Rendimento costante: niente volatilità né probabilità. È lo stesso motore delle Posizioni. Le ipotesi non sono previsioni."
    static let titoloMetodo = "La formula, senza scorciatoie"

    // MARK: Fila e ipotesi salvate

    static let salva = "Salva questa ipotesi"
    static let confrontala = "Confrontala con un’altra strada"
    static let prospetto = "Prospetto in PDF"
    static let salvate = "Salvate:"
    static let tutte = "Tutte"
    static let rinomina = "Rinomina…"
    static let elimina = "Elimina"
    static let rinominaTitolo = "Rinomina l’ipotesi"
    static let nome = "Nome"
    static let annulla = "Annulla"
    static let conferma = "Rinomina"
    static func salvataNelDossier(_ nome: String) -> String { "Ipotesi salvata nel dossier di \(nome)" }

    /// «<prime tre parole> · <mensile> €/mese · <anni> anni»
    static func titoloSalvata(nome: String, soldi: SoldiSimula) -> String {
        let parole = nome.split(whereSeparator: { $0 == " " }).prefix(3).joined(separator: " ")
        return "\(parole) · \(Formati.euro(soldi.mensile))/mese · \(anni(max(1, soldi.anni)))"
    }

    // MARK: Due strade

    static let occhielloDue = "Gli stessi soldi, due strade"
    /// Sotto questa differenza di costi la frase non li nomina.
    static let sogliaCostiInFrase = 200.0

    /// La frase delle due strade (testo intero; la vista colora la differenza con `fraseDueParti`).
    static func fraseDue(_ a: EsitoStrada, _ b: EsitoStrada, anni n: Int) -> String {
        fraseDueParti(a, b, anni: n).map { $0.testo }.joined()
    }

    /// La frase in pezzi: `evidenza` = la differenza (in verde nella vista).
    static func fraseDueParti(_ a: EsitoStrada, _ b: EsitoStrada, anni n: Int) -> [(testo: String, evidenza: Bool)] {
        guard let vinceA = MotoreSimulaConfronta.vincitore(a, b) else {
            var t = "Tra \(anni(n)) arrivano quasi allo stesso punto: circa \(circa(max(a.esito.netto, b.esito.netto)))."
            if let ra = a.opzione.sri, let rb = b.opzione.sri {
                t += " La differenza la fa il rischio: \(ra) contro \(rb) su 7."
            }
            return [(t, false)]
        }
        let v = vinceA ? a : b
        let p = vinceA ? b : a
        var parti: [(testo: String, evidenza: Bool)] = [
            ("Tra \(anni(n)) «\(v.opzione.nome)» arriva ", false),
            (Formati.euro(v.esito.netto - p.esito.netto), true),
            (" più in alto di «\(p.opzione.nome)», tolti costi e tasse.", false),
        ]
        if let rv = v.opzione.sri, let rp = p.opzione.sri {
            if rv > rp { parti.append((" Ma rischia di più: \(rv) contro \(rp) su 7.", false)) }
            else if rv < rp { parti.append((" E rischia anche meno.", false)) }
        }
        if abs(v.esito.costi - p.esito.costi) > sogliaCostiInFrase {
            parti.append((" In costi lascia \(Formati.euro(v.esito.costi)), l’altra \(Formati.euro(p.esito.costi)).", false))
        }
        return parti
    }

    static let allaFine = "Alla fine, al netto"
    static let seVaMale = "Se va male"
    static func costiIn(_ n: Int) -> String { "Costi in \(anni(n))" }
    static let rischio = "Rischio, da 1 a 7"
    static func prospettoPer(_ nome: String) -> String { "Fanne un prospetto per \(nome)" }
    static let prospettoDue = "Fanne un prospetto"
    static let tornaAUna = "Torna a una strada sola"
    static let restareOCambiare = "Restare o cambiare…"
    static let nonPromesse = "Stime con le ipotesi qui a sinistra: non sono promesse."

    /// Al più due decimali per rendimenti e costi nelle righe (2,345 → 2,35).
    static func arrotonda(_ v: Double) -> Double { (v * 100).rounded() / 100 }
}
