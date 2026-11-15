import Foundation

// Migliorie d'uso 1 «Mostra al cliente» (Design/uso/gruppo-01.md §1.3 punto 6): le frasi del capitolo «Il quadro» della
// vista pulita, dette al cliente («Per la pensione che desideri mancano circa 420 € al mese.»). Nessuna cifra nuova: ogni
// numero viene dagli stessi motori delle card di Analisi 360 (MotoreAnalisi.previdenza e .protezione, la composizione e
// la liquidità di MotoreAree360). Le soglie sono quelle dei motori: gli investimenti «rispettano il rischio» solo con
// tutto il capitale entro il profilo (come il giudizio di MotoreAree360.investimenti), la riserva c'è dai mesi di riserva
// delle ipotesi (non un 6 scritto qui). Le formule del template (`frasi()`, righe 3285-3289) non si usano.

/// Un'area del quadro detta al cliente: l'anello con la cifra, la frase e la seconda frase.
struct FraseArea: Equatable, Identifiable {
    let area: AreaAnalisi
    /// Riempimento dell'anello (0…1); nil se l'area non si misura (anello vuoto e trattino).
    let frazione: Double?
    /// La cifra al centro (percentuale intera o mesi); nil insieme a `frazione`.
    let valore: Double?
    let unita: SintesiArea360.Unita
    let frase: String
    let seconda: String

    var id: String { area.rawValue }
}

enum FrasiCliente {
    /// Le quattro aree nell'ordine di Analisi 360. `famiglia`: il cliente ha qualcuno in famiglia (cambia «alla tua
    /// famiglia» in «a chi conta su di te»).
    static func quadro(analisi a: Analisi360, posizioni: [Posizione], aree: AreeAnalisi360, famiglia: Bool) -> [FraseArea] {
        [previdenza(a.previdenza, sintesi: aree.sintesi(.previdenza)),
         protezione(a.protezione, posizioni: posizioni, sintesi: aree.sintesi(.protezione), famiglia: famiglia),
         investimenti(aree.composizione, sintesi: aree.sintesi(.investimenti)),
         risparmio(aree.liquidita, sintesi: aree.sintesi(.risparmio))]
    }

    // MARK: - Le quattro aree

    static func previdenza(_ i: IpotesiPrevidenza, sintesi s: SintesiArea360?) -> FraseArea {
        let e = MotoreAnalisi.previdenza(i)
        let p = Int(MotoreAree360.percentuale(e.divario > 0 ? e.integrazione / e.divario : 1))
        let frase = e.divarioResiduo >= 0.5
            ? "Per la pensione che desideri mancano circa \(Formati.euro(e.divarioResiduo)) al mese."
            : "La pensione che desideri è coperta."
        let seconda: String
        if e.divario <= 0 {
            seconda = "La pensione pubblica prevista arriva già al reddito che desideri."
        } else if e.integrazione >= 0.5 {
            seconda = "Oggi i tuoi piani coprono \(articolo(p))\(p)% del divario."
        } else {
            seconda = "Oggi non hai ancora un piano che copra questo divario."
        }
        return FraseArea(area: .previdenza, frazione: s?.frazione, valore: s?.valore, unita: .percentuale,
                         frase: frase, seconda: seconda)
    }

    static func protezione(_ i: IpotesiProtezione, posizioni: [Posizione], sintesi s: SintesiArea360?,
                           famiglia: Bool) -> FraseArea {
        let e = MotoreAnalisi.protezione(i, posizioni: posizioni)
        let p = Int(MotoreAree360.percentuale(e.fabbisogno > 0 ? e.capitaleVita / e.fabbisogno : 1))
        let frase: String
        if e.divario >= 0.5 {
            frase = "Se venisse a mancare il tuo reddito, \(famiglia ? "alla tua famiglia" : "a chi conta su di te") "
                + "servirebbero altri \(Formati.euro(e.divario))."
        } else {
            frase = famiglia ? "La tua famiglia è protetta." : "Chi conta su di te è protetto."
        }
        let seconda: String
        if e.capitaleVita < 0.5 {
            seconda = e.fabbisogno > 0 ? "Oggi non c’è ancora un capitale caso morte."
                : "Con queste ipotesi non serve un capitale caso morte."
        } else if e.fabbisogno > 0 {
            seconda = "Oggi il capitale caso morte copre \(articolo(p))\(p)% di quello che serve."
        } else {
            seconda = "Il capitale caso morte che hai va oltre quello che serve."
        }
        return FraseArea(area: .protezione, frazione: s?.frazione, valore: s?.valore, unita: .percentuale,
                         frase: frase, seconda: seconda)
    }

    static func investimenti(_ c: ComposizioneInvestimenti360, sintesi s: SintesiArea360?) -> FraseArea {
        guard c.investito > 0 else {
            return FraseArea(area: .investimenti, frazione: nil, valore: nil, unita: .percentuale,
                             frase: "Non hai ancora investimenti da confrontare con il rischio che hai scelto.",
                             seconda: "Quando ci saranno, li misureremo con l’indicatore di rischio.")
        }
        guard let entro = c.entroProfilo, c.propensione != nil else {
            return FraseArea(area: .investimenti, frazione: nil, valore: nil, unita: .percentuale,
                             frase: "Il rischio che vuoi correre è ancora da decidere insieme.",
                             seconda: "Poi confronteremo i tuoi investimenti con l’indicatore di rischio.")
        }
        let p = Int(MotoreAree360.quotaEntroProfilo(entro))
        let frase = p >= sogliaInLinea
            ? "I tuoi investimenti rispettano il rischio che hai scelto."
            : "Una parte dei tuoi investimenti rischia più di quanto hai scelto."
        let seconda = "\(articolo(p, maiuscolo: true))\(p)% del capitale è in linea con il tuo profilo, "
            + "misurato con l’indicatore di rischio."
        return FraseArea(area: .investimenti, frazione: s?.frazione, valore: s?.valore, unita: .percentuale,
                         frase: frase, seconda: seconda)
    }

    static func risparmio(_ l: Liquidita360, sintesi s: SintesiArea360?) -> FraseArea {
        let riserva = "Per gli imprevisti contiamo almeno \(l.soglia) \(l.soglia == 1 ? "mese" : "mesi") di spese."
        guard let mesi = l.mesi else {
            return FraseArea(area: .risparmio, frazione: nil, valore: nil, unita: .mesi,
                             frase: "Le tue spese di ogni mese sono ancora da scrivere insieme.", seconda: riserva)
        }
        let quanti = TestiAree360.mesiConNome(mesi)
        let frase = mesi >= Double(l.soglia)
            ? "Hai da parte \(quanti) di spese: la riserva c’è."
            : "Hai da parte \(quanti) di spese: la riserva è corta."
        return FraseArea(area: .risparmio, frazione: s?.frazione, valore: s?.valore, unita: .mesi,
                         frase: frase, seconda: riserva)
    }

    /// La quota entro il profilo da cui gli investimenti «rispettano il rischio»: tutta, come il giudizio della card di
    /// Analisi 360 (MotoreAree360.investimenti).
    static let sogliaInLinea = 100

    // MARK: - L'articolo davanti alla percentuale

    /// «lo 0%», «l’1%», «l’8%», «l’11%», «l’80%»…«l’89%», altrimenti «il» (con lo spazio, tranne dopo l’apostrofo).
    static func articolo(_ n: Int, maiuscolo: Bool = false) -> String {
        let a: String
        if n == 0 {
            a = "lo "
        } else if n == 1 || n == 8 || n == 11 || (80...89).contains(n) {
            a = "l’"
        } else {
            a = "il "
        }
        return maiuscolo ? a.prefix(1).uppercased() + a.dropFirst() : a
    }
}
