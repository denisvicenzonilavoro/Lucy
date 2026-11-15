import SwiftUI

// Migliorie d'uso 66 «Le parole si spiegano dove sono» (Design/uso/gruppo-11.md §66.3 punti 2-3, template righe
// 4836-4849): le parole del mestiere hanno un filo a puntini sotto, la prima volta che compaiono in una schermata; un
// tocco apre la scheda della parola (`SchedaParola`, ComponentiGuida.swift). Le forme delle parole e la regola «una volta
// per schermata» sono funzioni pure in Shell/Glossario.swift (`Glossario.forme`, `ParoleSchermata.segna`).
//
// Il collegamento della parola è interno (`prisma-parola://<chiave>`): lo gestisce l'`OpenURLAction` del testo, che
// restituisce `.handled`; ogni altro indirizzo è `.discarded`. Nulla arriva al sistema, nulla esce da Prisma.
//
// Sui documenti (`\.etichetteStampa`) e in modalità cliente (sotto la vista pulita della miglioria 1 c'è sempre la
// modalità cliente) il testo è semplice. Solo sul Mac: su iPhone e iPad è un `Text` come prima.

/// Un testo di spiegazione con le parole del mestiere segnate dal filo tratteggiato.
///
///     TestoConParole(frase, parole: insiemi[1], colore: Tema.Apple.Colore.inchiostro2)
///         .carattereApple(Tema.Apple.Carattere.secondario)
///
/// `parole` dice quali parole segnare (di solito l'insieme che `stato.paroleSchermata` ha dato a questo testo); nil le
/// segna tutte, ciascuna alla prima occorrenza. Il carattere si dà da fuori (`.font` o `.carattereApple`).
struct TestoConParole: View {
    let testo: String
    var parole: Set<VoceGlossario.Chiave>? = nil
    /// Un'etichetta che è tutta una parola del glossario (`EtichettaConTermine`): il filo va sotto l'intero testo.
    var intera: VoceGlossario.Chiave? = nil
    let colore: Color
    var righe: Int? = nil
    /// Nella vista pulita di «Mostra al cliente» (migliorie d'uso 1): le parole restano segnate anche se sotto c'è la
    /// modalità cliente, e il tocco apre la scheda «Le parole» della vista (`schedaMostra`) al posto del popover.
    var vistaCliente = false

    init(_ testo: String, parole: Set<VoceGlossario.Chiave>? = nil, colore: Color, righe: Int? = nil) {
        self.testo = testo
        self.parole = parole
        self.colore = colore
        self.righe = righe
    }

    /// Una frase della vista pulita di «Mostra al cliente», con le parole che si toccano dentro il testo.
    init(vistaCliente testo: String, parole: Set<VoceGlossario.Chiave>? = nil, colore: Color, righe: Int? = nil) {
        self.testo = testo
        self.parole = parole
        self.colore = colore
        self.righe = righe
        self.vistaCliente = true
    }

    /// L'etichetta intera segnata come la parola `chiave`.
    init(etichetta testo: String, chiave: VoceGlossario.Chiave, colore: Color, righe: Int? = nil) {
        self.testo = testo
        self.intera = chiave
        self.colore = colore
        self.righe = righe
    }

    #if os(macOS)
    @Environment(StatoShell.self) private var stato
    @Environment(\.etichetteStampa) private var stampa
    @State private var aperta: VoceGlossario.Chiave? = nil

    var body: some View {
        let _ = ContaCorpi.segna()
        let semplice = stampa || (stato.modoCliente != nil && !(vistaCliente && stato.inVistaCliente))
        let segnato = semplice ? nil : TestoParole.attribuito(testo, parole: parole, intera: intera)
        if let segnato {
            Text(segnato)
                .foregroundColor(colore)
                // I collegamenti prendono la tinta: la parola resta del colore del paragrafo, il filo dice che si tocca
                .tint(colore)
                .lineLimit(righe)
                .environment(\.openURL, OpenURLAction { url in apri(url) })
                .popover(isPresented: Binding(get: { aperta != nil }, set: { if !$0 { aperta = nil } }),
                         arrowEdge: .bottom) {
                    if let c = aperta, let v = Glossario.voce(c) {
                        SchedaParola(voce: v) {
                            aperta = nil
                            stato.apriGuida(.glossario(c))
                        }
                    }
                }
        } else {
            Text(testo)
                .foregroundColor(colore)
                .lineLimit(righe)
        }
    }

    /// Solo i collegamenti interni delle parole: aprono la scheda. Lo stato si legge qui, nell'azione.
    private func apri(_ url: URL) -> OpenURLAction.Result {
        guard let c = TestoParole.chiave(di: url) else { return .discarded }
        if vistaCliente && stato.inVistaCliente {
            stato.schedaMostra = .parola(c)
        } else if stato.modoCliente == nil {
            aperta = c
        }
        return .handled
    }
    #else
    var body: some View {
        Text(testo)
            .foregroundColor(colore)
            .lineLimit(righe)
    }
    #endif
}

#if os(macOS)
/// Il testo segnato di `TestoConParole`, fuori dalla vista (funzioni pure, provate da `--prova-calcoli`).
enum TestoParole {
    /// Lo schema dei collegamenti interni delle parole: non è un indirizzo, non arriva mai al sistema.
    static let schema = "prisma-parola"

    /// Il collegamento interno di una parola.
    static func collegamento(_ c: VoceGlossario.Chiave) -> URL? { URL(string: "\(schema)://\(c.rawValue)") }

    /// La parola di un collegamento interno (nil per ogni altro indirizzo).
    static func chiave(di url: URL) -> VoceGlossario.Chiave? {
        let prefisso = "\(schema)://"
        let testo = url.absoluteString
        guard url.scheme == schema, testo.hasPrefix(prefisso) else { return nil }
        return VoceGlossario.Chiave(rawValue: String(testo.dropFirst(prefisso.count)))
    }

    /// I testi già segnati, per testo e parole: l'`AttributedString` non si ricostruisce a ogni disegno.
    private nonisolated(unsafe) static var cache: [String: AttributedString?] = [:]
    private static let vociMassime = 400

    /// Il testo con il filo e il collegamento sulla prima occorrenza di ogni parola (nil: nessuna parola da segnare,
    /// basta un `Text` semplice).
    static func attribuito(_ testo: String, parole: Set<VoceGlossario.Chiave>?,
                           intera: VoceGlossario.Chiave?) -> AttributedString? {
        let elenco = parole.map { $0.map(\.rawValue).sorted().joined(separator: ",") } ?? "*"
        let chiave = "\(intera?.rawValue ?? "")|\(elenco)|\(testo)"
        if let fatto = cache[chiave] { return fatto }
        let esito = costruisci(testo, parole: parole, intera: intera)
        if cache.count >= vociMassime { cache.removeAll(keepingCapacity: true) }
        cache[chiave] = esito
        return esito
    }

    /// Funzione pura (la prova dei calcoli la usa per controllare i collegamenti).
    static func costruisci(_ testo: String, parole: Set<VoceGlossario.Chiave>?,
                           intera: VoceGlossario.Chiave?) -> AttributedString? {
        if parole?.isEmpty == true, intera == nil { return nil }
        let segni: [(VoceGlossario.Chiave, NSRange)]
        if let intera {
            segni = testo.isEmpty ? [] : [(intera, NSRange(location: 0, length: (testo as NSString).length))]
        } else {
            segni = Glossario.occorrenze(in: testo, solo: parole)
        }
        guard !segni.isEmpty else { return nil }
        var a = AttributedString(testo)
        for (c, r) in segni {
            guard let intervallo = Range<String.Index>(r, in: testo),
                  let tratto = Range<AttributedString.Index>(intervallo, in: a),
                  let url = collegamento(c) else { continue }
            a[tratto][AttributeScopes.SwiftUIAttributes.UnderlineStyleAttribute.self] = Tema.Apple.Parole.filo
            a[tratto].link = url
        }
        return a
    }

    /// I collegamenti di un testo segnato (per la prova: solo lo schema interno).
    static func collegamenti(_ a: AttributedString) -> [URL] {
        a.runs.compactMap { $0.link }
    }
}
#endif

extension StatoShell {
    /// Le parole da segnare in ogni testo di una schermata (migliorie d'uso 66): `testi` nell'ordine in cui si leggono,
    /// `schermata` il suo nome (il contenuto della finestra e il dettaglio aperto sopra sono due schermate). Calcolato una
    /// volta e tenuto fra i dati ricavati: il risultato non dipende dall'ordine in cui SwiftUI disegna.
    func paroleSchermata(_ schermata: String, _ testi: [String]) -> [Set<VoceGlossario.Chiave>] {
        #if os(macOS)
        return ricavato("parole|\(schermata)|\(testi.joined(separator: "\u{1}"))") { ParoleSchermata.segna(testi) }
        #else
        return Array(repeating: [], count: testi.count)
        #endif
    }
}
