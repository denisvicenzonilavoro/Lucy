import SwiftUI
#if os(macOS)
import AppKit
#endif

// MARK: - «Dal catalogo delle compagnie» (catalogo dei prodotti, fase 3: le schermate, solo sul Mac)
//
// Il foglio si apre da Posizioni («Aggiungi ⌄» › «Dal catalogo delle compagnie») e dal dettaglio di una posizione
// («Abbina al catalogo» o la riga «Dal catalogo: <prodotto>»). Due pagine: l'elenco (compagnia, ricerca, le righe
// proposte da un documento con `abbina(nome:)`, in fondo la «Guida per categoria») e la scheda del prodotto in stile
// Carta (al massimo tre numeri, il costo vero in euro, i pezzi come righe di scontrino con «tocca e capisci», le penali
// anno per anno, il testo originale delle celle, il livello di dettaglio, la fonte e l'avvertenza).
// Solo trasparenza: nessun consiglio, nessun confronto con un vincitore, nessuna classifica; i prodotti restano
// nell'ordine del catalogo. Nessun numero inventato: le cifre sono tutte di `MotoreCatalogo`, una cella vuota si dice
// «dato non disponibile nel catalogo». Il catalogo è una risorsa pubblica: niente dati dei clienti escono, la fonte si
// apre nel browser solo al clic del consulente. iPhone e iPad restano come sono (il foglio non c'è).
// Questo nome (non «Dal catalogo») perché «Dal catalogo» è già il catalogo dei prodotti del consulente
// (ModuloProdottoSulCliente).

/// Una richiesta di aprire il foglio del catalogo delle compagnie (per `.sheet(item:)`).
struct RichiestaCatalogoCompagnie: Identifiable, Equatable {
    let id = UUID()
    /// La voce da mostrare subito (nil: si parte dall'elenco).
    var voceId: String?
    /// La posizione del cliente da abbinare (nil: si guarda solo il catalogo).
    var posizioneId: String?
    /// Il nome letto in un documento o scritto nella posizione: le righe simili si propongono da confermare.
    var nomeLetto: String?
    /// Il versamento unico (investimento) e il premio o versamento annuo (protezione, previdenza), dalla posizione.
    var importoUnico: Double?
    var importoAnnuo: Double?
    var annoInizio: Int?
    /// La durata in anni (dalla decorrenza alla scadenza della posizione).
    var anni: Int?
    /// Le righe dello scontrino già aperte (le istantanee mostrano i passi del totale).
    var aperti: Set<String> = []

    /// La richiesta con gli importi presi da una posizione del cliente.
    static func perPosizione(_ p: Posizione, voceId: String? = nil) -> RichiestaCatalogoCompagnie {
        let cal = Calendar(identifier: .gregorian)
        let unico: Double? = p.versamentoIniziale > 0 ? p.versamentoIniziale : p.totaleVersato
        let annuo: Double? = p.premioAnnuo > 0 ? p.premioAnnuo : nil
        let anno: Int? = p.decorrenza.map { cal.component(.year, from: $0) }
        var anni: Int?
        if let inizio = p.decorrenza, let fine = p.scadenza {
            let n = cal.dateComponents([.year], from: inizio, to: fine).year ?? 0
            if n > 0 { anni = n }
        }
        let nome = [p.nome, p.emittente].filter { !$0.isEmpty }.joined(separator: " ")
        return RichiestaCatalogoCompagnie(voceId: voceId, posizioneId: p.id, nomeLetto: nome.isEmpty ? nil : nome,
                                          importoUnico: unico, importoAnnuo: annuo, annoInizio: anno, anni: anni)
    }
}

/// I testi del foglio: poche parole, nessun consiglio.
enum TestiCatalogoCompagnie {
    static let titolo = "Dal catalogo delle compagnie"
    static let aiutoIngresso = "I costi e le condizioni dei prodotti delle compagnie, dai documenti pubblici: solo trasparenza, nessuna classifica"
    static let soloTrasparenza = "Solo trasparenza: nessun consiglio, nessuna classifica. L'ordine è quello del catalogo."
    static let guidaCategoria = "Guida per categoria"
    static let notaGuida = "Condizioni tipiche di una categoria di mercato: una guida, non un prodotto da scegliere."
    static let dalDocumento = "Dal documento"
    static let tocca = "Tocca una riga per vedere i passi del calcolo."
    static let scriviImporto = "Scrivi il premio o il versamento per vedere il costo vero."
    static let nonDisponibile = "Il catalogo dei prodotti non è disponibile in questa versione di Lucy."

    /// «AAAA-MM-GG» → «25 novembre 2026» (il testo com'è, se non è una data).
    static func dataCatalogo(_ s: String) -> String {
        let f = DateFormatter()
        f.locale = Formati.italiano
        f.dateFormat = "yyyy-MM-dd"
        guard let d = f.date(from: s) else { return s }
        return Formati.dataEstesa.string(from: d)
    }

    /// «Versione 1 del 25 novembre 2026 · 391 prodotti» (le schede di categoria non contano come prodotti).
    static func versione(_ c: CatalogoProdotti) -> String {
        "Versione \(c.versione) del \(dataCatalogo(c.data)) · \(c.prodotti().count) prodotti"
    }

    /// La riga di Impostazioni › Archivio.
    static var versioneInstallata: String {
        guard let c = CatalogoProdotti.condiviso else { return nonDisponibile }
        return versione(c)
    }

    static func notaDocumento(_ nome: String) -> String {
        "Righe simili a «\(nome)»: scegli tu quella giusta, Lucy non sceglie da sola."
    }

    static func nonTrovato(_ v: VoceCatalogo) -> String {
        let cosa = [v.compagnia, v.categoria ?? ""].filter { !$0.isEmpty }.joined(separator: ", ")
        let noto = cosa.isEmpty ? "ciò che è scritto qui sotto" : cosa + " e ciò che è scritto qui sotto"
        return "I documenti di questo prodotto non sono stati trovati: si sa solo " + noto
            + ". Carica il set informativo nei Documenti del cliente per leggerlo con Lucy."
    }

    /// Il livello di dettaglio da mostrare sul badge.
    static func livello(_ v: VoceCatalogo) -> String {
        if v.schedaCategoria { return "Categoria" }
        return v.livello ?? "Non indicato"
    }

    /// Una riga che spiega il livello.
    static func spiegazione(_ livello: String) -> String {
        switch livello {
        case "Completo": return "Tutte le voci principali trovate nei documenti pubblici."
        case "Medio": return "Quasi tutte le voci trovate: alcune celle sono vuote."
        case "Parziale": return "Solo una parte delle voci è nei documenti pubblici."
        case "Base": return "Solo le informazioni essenziali del prodotto."
        case "Non trovato": return "I documenti del prodotto non sono stati trovati."
        case "Categoria": return "Condizioni tipiche della categoria, non di un singolo prodotto."
        default: return "Il catalogo non indica il livello per questo foglio: una cella vuota è un dato non pubblicato."
        }
    }

    /// Il nome dell'importo per il foglio.
    static func importo(_ f: FoglioCatalogo) -> String {
        switch f {
        case .protezione: return "Premio annuo (€)"
        case .investimento: return "Versamento (€)"
        case .previdenza: return "Versamento annuo (€)"
        }
    }

    /// Le sezioni della scheda con le colonne del catalogo, per foglio (testo originale delle celle).
    static func sezioni(_ f: FoglioCatalogo) -> [SezioneCatalogo] {
        switch f {
        case .protezione:
            return [
                SezioneCatalogo(titolo: "Cosa copre", righe: [
                    RigaSezioneCatalogo("Garanzie base", "garanzie_base"),
                    RigaSezioneCatalogo("Garanzie opzionali", "garanzie_opzionali"),
                    RigaSezioneCatalogo("Capitali", "capitali"),
                ]),
                SezioneCatalogo(titolo: "Cosa NON copre", righe: [
                    RigaSezioneCatalogo("Esclusioni", "esclusioni"),
                    RigaSezioneCatalogo("Non assicurabili", "non_assicurabili"),
                ]),
                SezioneCatalogo(titolo: "Attenzione a", righe: [
                    RigaSezioneCatalogo("Carenze", "carenze"),
                    RigaSezioneCatalogo("Franchigie e scoperti", "franchigie"),
                    RigaSezioneCatalogo("Da sapere", "da_sapere"),
                ]),
                SezioneCatalogo(titolo: "Le regole del contratto", righe: [
                    RigaSezioneCatalogo("Durata e rinnovo", "durata"),
                    RigaSezioneCatalogo("Recesso e disdetta", "recesso"),
                    RigaSezioneCatalogo("Età d'ingresso", "eta_ingresso"),
                    RigaSezioneCatalogo("Età massima", "eta_massima"),
                    RigaSezioneCatalogo("Visita medica", "visita_medica"),
                    RigaSezioneCatalogo("Detraibilità", "detraibilita"),
                ]),
            ]
        case .investimento:
            return [
                SezioneCatalogo(titolo: "Cosa copre", righe: [
                    RigaSezioneCatalogo("Garanzie", "garanzie"),
                    RigaSezioneCatalogo("Caso morte", "caso_morte"),
                ]),
                SezioneCatalogo(titolo: "Cosa NON copre", righe: [
                    RigaSezioneCatalogo("Esclusioni", "esclusioni"),
                ]),
                SezioneCatalogo(titolo: "Attenzione a", righe: [
                    RigaSezioneCatalogo("Penali", "penali"),
                    RigaSezioneCatalogo("Riscatto possibile da", "riscattabile_da"),
                    RigaSezioneCatalogo("Da sapere", "da_sapere"),
                ]),
                SezioneCatalogo(titolo: "Le regole del contratto", righe: [
                    RigaSezioneCatalogo("Periodo raccomandato", "periodo_raccomandato"),
                    RigaSezioneCatalogo("Premio minimo", "premio_minimo"),
                    RigaSezioneCatalogo("Versamenti", "versamenti"),
                    RigaSezioneCatalogo("Età", "eta"),
                    RigaSezioneCatalogo("Cambio di linea", "switch"),
                    RigaSezioneCatalogo("Indicatore di rischio", "sri"),
                ]),
            ]
        case .previdenza:
            return [
                SezioneCatalogo(titolo: "Cosa copre", righe: [
                    RigaSezioneCatalogo("Garanzia", "garanzia"),
                    RigaSezioneCatalogo("Prestazioni accessorie", "prestazioni_accessorie"),
                ]),
                SezioneCatalogo(titolo: "Cosa NON copre", righe: [
                    RigaSezioneCatalogo("Esclusioni", "esclusioni"),
                ]),
                SezioneCatalogo(titolo: "Attenzione a", righe: [
                    RigaSezioneCatalogo("Costi della rendita", "costi_rendita"),
                    RigaSezioneCatalogo("Riscatto", "riscatto"),
                    RigaSezioneCatalogo("Anticipazione", "anticipazione"),
                    RigaSezioneCatalogo("Da sapere", "da_sapere"),
                ]),
                SezioneCatalogo(titolo: "Le regole del contratto", righe: [
                    RigaSezioneCatalogo("RITA", "rita"),
                    RigaSezioneCatalogo("Trasferimento", "trasferimento"),
                    RigaSezioneCatalogo("Cambio di comparto", "switch"),
                    RigaSezioneCatalogo("Scheda dei costi dal", "scheda_costi_dal"),
                ]),
            ]
        }
    }

    /// Un numero scritto all'italiana («10.000», «2,5», «300 €»); nil se vuoto, negativo o non è un numero.
    static func leggiNumero(_ s: String) -> Double? {
        let pulito = s.replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard !pulito.isEmpty, let v = Double(pulito), v.isFinite, v >= 0, v < 1_000_000_000 else { return nil }
        return v
    }

    /// Un intero scritto (anni, età, anno di inizio), entro limiti ragionevoli.
    static func leggiIntero(_ s: String, da minimo: Int, a massimo: Int) -> Int? {
        guard let v = leggiNumero(s), v >= Double(minimo), v <= Double(massimo) else { return nil }
        return Int(v.rounded())
    }

    /// Le guide per categoria da mostrare in fondo all'elenco: tutte senza filtri, altrimenti quelle delle categorie
    /// cercate o dei prodotti trovati (senza ripetizioni, nell'ordine del catalogo).
    static func guide(_ c: CatalogoProdotti, ricerca: String, compagnia: String, trovati: [VoceCatalogo]) -> [VoceCatalogo] {
        let testo = ricerca.trimmingCharacters(in: .whitespacesAndNewlines)
        if testo.isEmpty && compagnia.isEmpty { return c.schedeCategoria }
        var ids = Set<String>()
        for g in c.guida(categoria: testo) { ids.insert(g.id) }
        for v in trovati { for g in c.guida(per: v) { ids.insert(g.id) } }
        return c.schedeCategoria.filter { ids.contains($0.id) }
    }
}

/// Una sezione della scheda («Cosa copre»…) con le sue colonne.
struct SezioneCatalogo: Hashable {
    var titolo: String
    var righe: [RigaSezioneCatalogo]
}

struct RigaSezioneCatalogo: Hashable {
    var etichetta: String
    var colonna: String

    init(_ etichetta: String, _ colonna: String) {
        self.etichetta = etichetta
        self.colonna = colonna
    }
}

/// La chiave del calcolo in cache: la voce e i numeri scritti.
struct ChiaveCalcoloCatalogo: Equatable {
    var voceId: String
    var ingresso: IngressoCatalogo
}

#if os(macOS)

/// Il terzo numero della scheda di protezione.
enum TerzoCatalogo: String, CaseIterable, Hashable {
    case anni, eta, capitale

    var etichetta: String {
        switch self {
        case .anni: return "Durata (anni)"
        case .eta: return "Età"
        case .capitale: return "Capitale (€)"
        }
    }
}

// MARK: - Il foglio

struct FoglioCatalogoCompagnie: View {
    @Environment(\.dismiss) private var chiudi
    @Environment(StatoShell.self) private var stato
    let richiesta: RichiestaCatalogoCompagnie

    @State private var voceId: String?
    @State private var compagnia = ""
    @State private var ricerca = ""
    @State private var testoImporto = ""
    @State private var testoAnno = ""
    @State private var testoTerzo = ""
    @State private var terzo: TerzoCatalogo = .anni
    @State private var aperti: Set<String>

    private typealias M = TemaCarta.Modulo
    private typealias K = TemaCarta.Catalogo
    private typealias T = TestiCatalogoCompagnie

    /// Tutto dallo stato iniziale (le istantanee non aspettano `onAppear`).
    init(richiesta: RichiestaCatalogoCompagnie) {
        self.richiesta = richiesta
        _aperti = State(initialValue: richiesta.aperti)
        _voceId = State(initialValue: richiesta.voceId)
        if let id = richiesta.voceId, let v = CatalogoProdotti.condiviso?.voce(id: id) {
            let numeri = Self.numeriIniziali(richiesta, foglio: v.foglio)
            _testoImporto = State(initialValue: numeri.importo)
            _testoAnno = State(initialValue: numeri.anno)
            _testoTerzo = State(initialValue: numeri.terzo)
        }
    }

    /// I numeri di partenza dalla richiesta (dalla posizione), per il foglio della voce.
    static func numeriIniziali(_ r: RichiestaCatalogoCompagnie, foglio: FoglioCatalogo) -> (importo: String, anno: String, terzo: String) {
        let importo: Double?
        switch foglio {
        case .investimento: importo = r.importoUnico ?? r.importoAnnuo
        case .protezione, .previdenza: importo = r.importoAnnuo ?? r.importoUnico
        }
        let testoImporto = importo.map { MotoreCatalogo.numero($0.rounded()) } ?? ""
        let testoAnno = r.annoInizio.map { String($0) } ?? ""
        let testoTerzo = foglio == .protezione ? (r.anni.map { String($0) } ?? "") : ""
        return (testoImporto, testoAnno, testoTerzo)
    }

    private var catalogo: CatalogoProdotti? { CatalogoProdotti.condiviso }
    private var datoMancante: String { catalogo?.datoMancante ?? MotoreCatalogo.datoMancante }
    private var posizione: Posizione? {
        richiesta.posizioneId.flatMap { id in stato.posizioni.first { $0.id == id } }
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        VStack(spacing: 0) {
            if let c = catalogo {
                if let id = voceId, let v = c.voce(id: id) {
                    testata(occhiello: v.compagnia.isEmpty ? T.guidaCategoria : v.compagnia,
                            titolo: v.nomeCompleto.isEmpty ? "Senza nome" : v.nomeCompleto,
                            sotto: [v.foglio.nome, v.categoria ?? ""].filter { !$0.isEmpty }.joined(separator: " · "))
                    ScrollView {
                        SchedaProdottoCatalogo(voce: v, catalogo: c, testoImporto: $testoImporto, testoAnno: $testoAnno,
                                               testoTerzo: $testoTerzo, terzo: $terzo, aperti: $aperti,
                                               apri: { scegli($0) })
                            .padding(.horizontal, M.margine)
                            .padding(.bottom, M.margine)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    testata(occhiello: "Posizioni · catalogo", titolo: T.titolo,
                            sotto: T.versione(c))
                    ScrollView {
                        ElencoCatalogo(catalogo: c, compagnia: $compagnia, ricerca: $ricerca,
                                       nomeLetto: richiesta.nomeLetto, scegli: { scegli($0) })
                            .padding(.horizontal, M.margine)
                            .padding(.bottom, M.margine)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                testata(occhiello: "Posizioni · catalogo", titolo: T.titolo, sotto: T.nonDisponibile)
                Spacer(minLength: 0)
            }
            piede
        }
        .frame(width: K.misura.width, height: K.misura.height)
        .background(TemaCarta.Colore.cartaD)
    }

    /// Sceglie una voce: i numeri ripartono da quelli della posizione (o vuoti).
    private func scegli(_ id: String) {
        guard let v = catalogo?.voce(id: id) else { return }
        let numeri = Self.numeriIniziali(richiesta, foglio: v.foglio)
        testoImporto = numeri.importo
        testoAnno = numeri.anno
        testoTerzo = numeri.terzo
        terzo = .anni
        aperti = []
        voceId = id
    }

    // MARK: Testata e piede

    private func testata(occhiello: String, titolo: String, sotto: String) -> some View {
        VStack(alignment: .leading, spacing: M.spazioTestata) {
            Text(occhiello.uppercased())
                .fontCarta(M.occhiello)
                .tracking(M.tracciaOcchiello)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .lineLimit(1)
            Text(titolo)
                .fontCarta(M.titolo)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Capsule()
                .fill(TemaCarta.Colore.oroD)
                .frame(width: M.sottolineatura.width, height: M.sottolineatura.height)
                .padding(.top, M.sopraSottolineatura)
            if !sotto.isEmpty {
                Text(sotto)
                    .fontCarta(M.sottotitolo)
                    .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    .padding(.top, M.sopraSottolineatura)
            }
        }
        .padding(.horizontal, M.margine)
        .padding(.top, M.sopraTestata)
        .padding(.bottom, M.sottoTestata)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var piede: some View {
        HStack(spacing: M.spazioPulsanti) {
            if voceId != nil {
                Button { voceId = nil } label: { Label("Tutti i prodotti", systemImage: "chevron.left") }
                    .buttonStyle(PulsanteModuloCarta(tipo: .secondario))
            }
            Spacer(minLength: 0)
            if let p = posizione, let id = voceId, let v = catalogo?.voce(id: id), !v.schedaCategoria {
                if p.catalogoId == id {
                    Button("Togli l'abbinamento") { abbina(nil) }
                        .buttonStyle(PulsanteModuloCarta(tipo: .secondario))
                        .disabled(stato.solaLettura)
                        .help("La posizione non è più collegata a questa riga del catalogo")
                } else {
                    Button("Abbina a questa posizione") { abbina(v) }
                        .buttonStyle(PulsanteModuloCarta(tipo: .primario))
                        .disabled(stato.solaLettura)
                        .opacity(stato.solaLettura ? M.opacitaSpento : 1)
                        .help("Collega «\(p.nome)» a questa riga del catalogo: lo confermi tu")
                }
            }
            Button("Chiudi") { chiudi() }
                .buttonStyle(PulsanteModuloCarta(tipo: .secondario))
                .keyboardShortcut(.cancelAction)
        }
        .padding(.horizontal, M.margine)
        .frame(height: M.piede)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(TemaCarta.Colore.filo2D)
                .frame(height: Tema.Misura.filo)
                .allowsHitTesting(false)
        }
    }

    /// Collega (o scollega, con nil) la posizione alla voce: solo con il clic del consulente.
    private func abbina(_ voce: VoceCatalogo?) {
        guard !stato.solaLettura, var p = posizione else { return }
        p.catalogoId = voce?.id
        stato.salvaPosizione(p)
        if let voce {
            stato.mostraAvviso("«\(p.nome)» abbinata a \(voce.nomeCompleto) del catalogo.")
        } else {
            stato.mostraAvviso("«\(p.nome)» non è più abbinata al catalogo.")
        }
        chiudi()
    }
}

// MARK: - L'elenco

/// La compagnia, la ricerca, le righe proposte dal documento, i prodotti per foglio e in fondo la guida per categoria.
private struct ElencoCatalogo: View {
    @Environment(StatoShell.self) private var stato
    let catalogo: CatalogoProdotti
    @Binding var compagnia: String
    @Binding var ricerca: String
    let nomeLetto: String?
    let scegli: (String) -> Void

    private typealias M = TemaCarta.Modulo
    private typealias K = TemaCarta.Catalogo
    private typealias T = TestiCatalogoCompagnie

    var body: some View {
        let c = catalogo
        let filtro = [ricerca, compagnia]
        let compagnie: [String] = stato.ricavato("catalogo-compagnie.compagnie") { c.compagnie }
        let trovati: [VoceCatalogo] = stato.ricavato("catalogo-compagnie.elenco", ingresso: filtro) {
            c.cerca(ricerca, compagnia: compagnia.isEmpty ? nil : compagnia)
        }
        let guide: [VoceCatalogo] = stato.ricavato("catalogo-compagnie.guide", ingresso: filtro) {
            T.guide(c, ricerca: ricerca, compagnia: compagnia, trovati: trovati)
        }
        let nome = nomeLetto ?? ""
        let simili: [AbbinamentoCatalogo] = stato.ricavato("catalogo-compagnie.abbina", ingresso: nome) {
            nome.isEmpty ? [] : c.abbina(nome: nome)
        }
        return VStack(alignment: .leading, spacing: M.spazioGruppi) {
            Text(T.soloTrasparenza)
                .fontCarta(M.notaGruppo)
                .foregroundColor(TemaCarta.Colore.pennaD)
            if !simili.isEmpty {
                GruppoCatalogo(titolo: T.dalDocumento, nota: T.notaDocumento(nome)) {
                    ForEach(simili, id: \.voce.id) { a in
                        RigaVoceCatalogo(voce: a.voce, conferma: true) { scegli(a.voce.id) }
                    }
                }
            }
            filtri(compagnie)
            if trovati.isEmpty {
                Text("Nessun prodotto con questi filtri.")
                    .fontCarta(M.avviso)
                    .foregroundColor(TemaCarta.Colore.matitaD)
            }
            ForEach(FoglioCatalogo.allCases, id: \.self) { f in
                let voci = trovati.filter { $0.foglio == f }
                if !voci.isEmpty {
                    GruppoCatalogo(titolo: f.nome, nota: "\(voci.count) \(voci.count == 1 ? "prodotto" : "prodotti")") {
                        LazyVStack(alignment: .leading, spacing: K.spazioRighe) {
                            ForEach(voci) { v in
                                RigaVoceCatalogo(voce: v) { scegli(v.id) }
                            }
                        }
                    }
                }
            }
            if !guide.isEmpty {
                GruppoCatalogo(titolo: T.guidaCategoria, nota: T.notaGuida) {
                    ForEach(guide) { g in
                        RigaVoceCatalogo(voce: g) { scegli(g.id) }
                    }
                }
            }
        }
    }

    private func filtri(_ compagnie: [String]) -> some View {
        HStack(spacing: M.spazioColonne) {
            Picker("Compagnia", selection: $compagnia) {
                Text("Tutte le compagnie").tag("")
                ForEach(compagnie, id: \.self) { nome in
                    Text(nome).tag(nome)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(width: K.sceltaCompagnia)
            TextField("Cerca un prodotto, una categoria…", text: $ricerca)
                .textFieldStyle(.plain)
                .fontCarta(M.valore)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .padding(.horizontal, M.paddingCampo)
                .frame(height: M.altezzaCampo)
                .background(CasellaCatalogo())
        }
    }
}

/// Una riga dell'elenco: nome, compagnia e foglio; con `conferma` il pulsante «È questa».
private struct RigaVoceCatalogo: View {
    let voce: VoceCatalogo
    var conferma = false
    let apri: () -> Void

    private typealias K = TemaCarta.Catalogo

    var body: some View {
        Button(action: apri) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(voce.nomeCompleto.isEmpty ? "Senza nome" : voce.nomeCompleto)
                        .fontCarta(K.nomeRiga)
                        .foregroundColor(TemaCarta.Colore.inchiostroD)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(sotto)
                        .fontCarta(K.notaRiga)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                if conferma {
                    Text("È questa")
                        .fontCarta(K.notaRiga)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                }
                Image(systemName: "chevron.right")
                    .fontCarta(K.notaRiga)
                    .foregroundColor(TemaCarta.Colore.matitaD)
            }
            .padding(K.paddingRiga)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CasellaCatalogo())
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(conferma ? "Apri la scheda: l'abbinamento lo confermi tu" : "Apri la scheda del prodotto")
    }

    private var sotto: String {
        [voce.compagnia, voce.categoria ?? ""].filter { !$0.isEmpty }.joined(separator: " · ")
    }
}

// MARK: - La scheda del prodotto

private struct SchedaProdottoCatalogo: View {
    @Environment(StatoShell.self) private var stato
    let voce: VoceCatalogo
    let catalogo: CatalogoProdotti
    @Binding var testoImporto: String
    @Binding var testoAnno: String
    @Binding var testoTerzo: String
    @Binding var terzo: TerzoCatalogo
    @Binding var aperti: Set<String>
    let apri: (String) -> Void

    private typealias M = TemaCarta.Modulo
    private typealias K = TemaCarta.Catalogo
    private typealias T = TestiCatalogoCompagnie

    private var datoMancante: String { catalogo.datoMancante }
    private var avvertenza: String { catalogo.avvertenza.isEmpty ? MotoreCatalogo.avvertenzaDiBase : catalogo.avvertenza }

    var body: some View {
        VStack(alignment: .leading, spacing: M.spazioGruppi) {
            BadgeLivelloCatalogo(livello: T.livello(voce))
            if voce.schedaCategoria {
                Text(T.notaGuida)
                    .fontCarta(M.notaGruppo)
                    .foregroundColor(TemaCarta.Colore.pennaD)
            }
            if voce.livello == "Non trovato" {
                RiquadroNonTrovato(testo: T.nonTrovato(voce))
            }
            if !voce.schedaCategoria {
                numeri
                costi
            }
            ForEach(T.sezioni(voce.foglio), id: \.titolo) { s in
                sezione(s)
            }
            guidaDellaCategoria
            fonte
        }
    }

    // MARK: I numeri (al massimo tre)

    private var numeri: some View {
        GruppoCatalogo(titolo: "I numeri", nota: nil) {
            HStack(alignment: .top, spacing: M.spazioColonne) {
                CampoNumeroCatalogo(etichetta: T.importo(voce.foglio), testo: $testoImporto, segnaposto: "10.000")
                CampoNumeroCatalogo(etichetta: "Anno di inizio", testo: $testoAnno, segnaposto: String(MotoreCatalogo.annoDiOggi))
                terzoCampo
                Spacer(minLength: 0)
            }
        }
    }

    @ViewBuilder private var terzoCampo: some View {
        switch voce.foglio {
        case .protezione:
            VStack(alignment: .leading, spacing: M.sottoEtichetta) {
                Picker("Terzo numero", selection: $terzo) {
                    ForEach(TerzoCatalogo.allCases, id: \.self) { t in
                        Text(t.etichetta).tag(t)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: K.campoNumero)
                CasellaNumeroCatalogo(testo: $testoTerzo, segnaposto: "facoltativo")
            }
        case .investimento:
            CampoNumeroCatalogo(etichetta: "Età (facoltativa)", testo: $testoTerzo, segnaposto: "facoltativa")
        case .previdenza:
            CampoNumeroCatalogo(etichetta: "Anni all'uscita", testo: $testoTerzo, segnaposto: "facoltativi")
        }
    }

    /// I numeri scritti; nil senza l'importo.
    private var ingresso: IngressoCatalogo? {
        guard let importo = T.leggiNumero(testoImporto) else { return nil }
        let anno = T.leggiIntero(testoAnno, da: 1950, a: 2200)
        var altro: IngressoCatalogo.Terzo?
        switch voce.foglio {
        case .protezione:
            switch terzo {
            case .anni: altro = T.leggiIntero(testoTerzo, da: 1, a: 100).map { IngressoCatalogo.Terzo.anni($0) }
            case .eta: altro = T.leggiIntero(testoTerzo, da: 0, a: 120).map { IngressoCatalogo.Terzo.eta($0) }
            case .capitale: altro = T.leggiNumero(testoTerzo).map { IngressoCatalogo.Terzo.capitale($0) }
            }
        case .investimento:
            altro = T.leggiIntero(testoTerzo, da: 0, a: 120).map { IngressoCatalogo.Terzo.eta($0) }
        case .previdenza:
            altro = T.leggiIntero(testoTerzo, da: 1, a: 60).map { IngressoCatalogo.Terzo.anni($0) }
        }
        return IngressoCatalogo(importo: importo, annoInizio: anno, terzo: altro)
    }

    // MARK: Il costo vero e lo scontrino

    @ViewBuilder private var costi: some View {
        if let i = ingresso {
            let v = voce
            let avv = avvertenza
            let r: RisultatoCatalogo = stato.ricavato("catalogo-compagnie.calcolo",
                                                      ingresso: ChiaveCalcoloCatalogo(voceId: v.id, ingresso: i)) {
                MotoreCatalogo.calcola(v, i, avvertenza: avv)
            }
            CostoVeroCatalogo(risultato: r, datoMancante: datoMancante)
            ScontrinoPezziCatalogo(risultato: r, aperti: $aperti)
            if !r.note.isEmpty {
                VStack(alignment: .leading, spacing: K.spazioPassi) {
                    ForEach(r.note, id: \.self) { n in
                        Text(n)
                            .fontCarta(K.passo)
                            .foregroundColor(TemaCarta.Colore.rossoD)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            if !r.penali.isEmpty {
                PenaliCatalogo(penali: r.penali, datoMancante: datoMancante)
            }
        } else {
            Text(T.scriviImporto)
                .fontCarta(M.avviso)
                .foregroundColor(TemaCarta.Colore.matitaD)
        }
    }

    // MARK: Le sezioni con il testo originale

    private func sezione(_ s: SezioneCatalogo) -> some View {
        GruppoCatalogo(titolo: s.titolo, nota: nil) {
            ForEach(s.righe, id: \.self) { riga in
                RigaTestoCatalogo(etichetta: riga.etichetta, testo: testoCella(riga.colonna), manca: testoCella(riga.colonna) == nil,
                                  datoMancante: datoMancante)
            }
        }
    }

    private func testoCella(_ colonna: String) -> String? {
        guard let t = voce.testo[colonna]?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }

    // MARK: La guida della categoria, la fonte, l'avvertenza

    @ViewBuilder private var guidaDellaCategoria: some View {
        let guide = voce.schedaCategoria ? [] : catalogo.guida(per: voce)
        if !guide.isEmpty {
            GruppoCatalogo(titolo: T.guidaCategoria, nota: T.notaGuida) {
                ForEach(guide) { g in
                    RigaVoceCatalogo(voce: g) { apri(g.id) }
                }
            }
        }
    }

    private var fonte: some View {
        VStack(alignment: .leading, spacing: K.spazioPassi) {
            if let f = voce.fonte?.trimmingCharacters(in: .whitespacesAndNewlines), !f.isEmpty {
                if let url = URL(string: f), url.scheme == "https" || url.scheme == "http" {
                    Button {
                        // Solo al clic del consulente: si apre nel browser, Lucy non scarica niente
                        NSWorkspace.shared.open(url)
                    } label: {
                        Label("Fonte: \(url.host ?? f)", systemImage: "arrow.up.right.square")
                            .fontCarta(K.notaRiga)
                            .foregroundColor(TemaCarta.Colore.pennaD)
                    }
                    .buttonStyle(.plain)
                    .help("Apre il documento della compagnia nel browser: \(f)")
                } else {
                    Text("Fonte: \(f)")
                        .fontCarta(K.notaRiga)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text("Fonte: \(datoMancante)")
                    .fontCarta(K.notaRiga)
                    .foregroundColor(TemaCarta.Colore.matitaD)
            }
            Text(avvertenza)
                .fontCarta(M.notaGruppo)
                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// Il costo vero in euro, in grande, con la sottolineatura dorata: il valore, l'intervallo, «almeno» (quando manca un
/// pezzo) o «dato non disponibile nel catalogo».
private struct CostoVeroCatalogo: View {
    let risultato: RisultatoCatalogo
    let datoMancante: String

    private typealias K = TemaCarta.Catalogo

    var body: some View {
        let totale = risultato.totale
        VStack(alignment: .leading, spacing: TemaCarta.Modulo.spazioTestata) {
            Text(totale.titolo.uppercased())
                .fontCarta(K.titoloCosto)
                .tracking(TemaCarta.Modulo.tracciaEtichetta)
                .foregroundColor(TemaCarta.Colore.matitaD)
            if let testo = testoCifra {
                ContachilometriCarta(testo: testo)
                    .fontCarta(K.costo)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .segnoCarta(.sottolinea, chiave: "catalogo.costo.\(risultato.voceId)")
            } else {
                Text(datoMancante)
                    .fontCarta(K.costoMancante)
                    .foregroundColor(TemaCarta.Colore.inchiostro2D)
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// nil = dato non disponibile.
    private var testoCifra: String? {
        let cifra = risultato.totale.cifra
        if cifra.disponibile { return cifra.testoEuro }
        if let p = risultato.parzialeNoto, let minimo = p.minimo { return "almeno " + MotoreCatalogo.euro(minimo) }
        return nil
    }
}

/// I pezzi del costo come righe di scontrino; toccando una riga si aprono i passi del calcolo («tocca e capisci»).
private struct ScontrinoPezziCatalogo: View {
    let risultato: RisultatoCatalogo
    @Binding var aperti: Set<String>

    private typealias K = TemaCarta.Catalogo

    var body: some View {
        VStack(alignment: .leading, spacing: TemaCarta.Scontrino.spazioRighe) {
            Text(TestiCatalogoCompagnie.tocca.uppercased())
                .fontCarta(TemaCarta.Scontrino.testata)
                .tracking(TemaCarta.Modulo.tracciaEtichetta)
                .foregroundColor(TemaCarta.Colore.matitaD)
            LineaTratteggiata()
            ForEach(risultato.pezzi) { p in
                RigaPezzoCatalogo(pezzo: p, forte: false, aperto: aperti.contains(p.id)) { cambia(p.id) }
            }
            LineaTratteggiata()
            RigaPezzoCatalogo(pezzo: risultato.totale, forte: true, aperto: aperti.contains(risultato.totale.id)) {
                cambia(risultato.totale.id)
            }
        }
        .padding(TemaCarta.Scontrino.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { FormaScontrino().fill(TemaCarta.Colore.schedaD) }
        .overlay { FormaScontrino().stroke(TemaCarta.Colore.filoD, lineWidth: 1) }
    }

    private func cambia(_ id: String) {
        if aperti.contains(id) { aperti.remove(id) } else { aperti.insert(id) }
    }
}

private struct RigaPezzoCatalogo: View {
    let pezzo: PezzoCalcolo
    let forte: Bool
    let aperto: Bool
    let tocca: () -> Void

    private typealias K = TemaCarta.Catalogo

    var body: some View {
        VStack(alignment: .leading, spacing: K.spazioPassi) {
            Button(action: tocca) {
                HStack(alignment: .firstTextBaseline, spacing: K.spazioPassi) {
                    Image(systemName: aperto ? "chevron.down" : "chevron.right")
                        .fontCarta(TemaCarta.Scontrino.piccolo)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                    RigaScontrinoVista(etichetta: pezzo.titolo, importo: pezzo.cifra.testoEuro, forte: forte,
                                       colore: pezzo.cifra.disponibile ? TemaCarta.Colore.inchiostroD : TemaCarta.Colore.matitaD)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Tocca e capisci: i passi del calcolo")
            if aperto {
                passi
            }
        }
    }

    private var passi: some View {
        VStack(alignment: .leading, spacing: K.spazioPassi) {
            ForEach(Array(pezzo.passi.enumerated()), id: \.offset) { _, passo in
                Text(passo)
                    .fontCarta(K.passo)
                    .foregroundColor(TemaCarta.Colore.pennaD)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let nota = pezzo.nota, !nota.isEmpty {
                Text("Nel catalogo: «\(nota)»")
                    .fontCarta(K.originale)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.leading, K.rientroPassi)
        .textSelection(.enabled)
    }
}

/// Le penali di riscatto anno per anno (investimento).
private struct PenaliCatalogo: View {
    let penali: [PenaleAnno]
    let datoMancante: String

    private typealias K = TemaCarta.Catalogo

    var body: some View {
        GruppoCatalogo(titolo: "Penali di riscatto, anno per anno", nota: nil) {
            ForEach(penali, id: \.anno) { p in
                HStack(alignment: .firstTextBaseline) {
                    Text("\(p.anno)° anno")
                        .fontCarta(TemaCarta.Scontrino.riga)
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                        .frame(width: K.colonnaEtichetta, alignment: .leading)
                    Text(testo(p))
                        .fontCarta(TemaCarta.Scontrino.riga)
                        .monospacedDigit()
                        .foregroundColor(p.stato == .nonDisponibile ? TemaCarta.Colore.matitaD : TemaCarta.Colore.inchiostroD)
                    Spacer(minLength: 0)
                }
                .help(p.passo)
            }
        }
    }

    private func testo(_ p: PenaleAnno) -> String {
        switch p.stato {
        case .quota(let q):
            return q == 0 ? "nessuna penale" : "\(MotoreCatalogo.percento(q)) · \(p.importo.testoEuro)"
        case .riscattoNonPossibile:
            return "riscatto non ancora possibile"
        case .nonDisponibile:
            return datoMancante
        }
    }
}

// MARK: - I pezzi piccoli

/// Un gruppo su carta: titolo in New York (con la nota in corsivo sotto) e il contenuto, su una scheda con il filo.
private struct GruppoCatalogo<Contenuto: View>: View {
    let titolo: String
    let nota: String?
    @ViewBuilder let contenuto: () -> Contenuto

    private typealias M = TemaCarta.Modulo

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: M.raggioGruppo, style: .continuous)
        VStack(alignment: .leading, spacing: M.spazioCampi) {
            VStack(alignment: .leading, spacing: M.spazioTestata) {
                Text(titolo)
                    .fontCarta(M.titoloGruppo)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                if let nota {
                    Text(nota)
                        .fontCarta(M.notaGruppo)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            contenuto()
        }
        .padding(M.paddingGruppo)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(forma.fill(TemaCarta.Colore.schedaD))
        .overlay(forma.strokeBorder(TemaCarta.Colore.filoD, lineWidth: Tema.Misura.filo).allowsHitTesting(false))
    }
}

/// Una riga di testo originale: l'etichetta in SF Mono e il testo della cella, o «dato non disponibile nel catalogo».
private struct RigaTestoCatalogo: View {
    let etichetta: String
    let testo: String?
    let manca: Bool
    let datoMancante: String

    private typealias K = TemaCarta.Catalogo
    private typealias M = TemaCarta.Modulo

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: M.spazioColonne) {
            Text(etichetta.uppercased())
                .fontCarta(M.etichetta)
                .tracking(M.tracciaEtichetta)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .frame(width: K.colonnaEtichetta, alignment: .leading)
            Text(testo ?? datoMancante)
                .fontCarta(manca ? K.originale : K.testoSezione)
                .foregroundColor(manca ? TemaCarta.Colore.matitaD : TemaCarta.Colore.inchiostroD)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}

/// Il badge «Livello di dettaglio» con la spiegazione di una riga.
private struct BadgeLivelloCatalogo: View {
    let livello: String

    private typealias K = TemaCarta.Catalogo

    var body: some View {
        HStack(alignment: .center, spacing: TemaCarta.Modulo.spazioColonne / 2) {
            Text("Livello di dettaglio: \(livello)".uppercased())
                .fontCarta(K.badge)
                .tracking(TemaCarta.Modulo.tracciaEtichetta)
                .foregroundColor(colore)
                .padding(K.paddingBadge)
                .overlay(Capsule().strokeBorder(colore, lineWidth: Tema.Misura.filo * 2))
            Text(TestiCatalogoCompagnie.spiegazione(livello))
                .fontCarta(K.notaRiga)
                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var colore: Color {
        switch livello {
        case "Completo": return TemaCarta.Colore.verdeD
        case "Medio": return TemaCarta.Colore.oroTestoD
        case "Parziale", "Base": return TemaCarta.Colore.d(TemaCarta.Colore.arancioTesto)
        case "Non trovato": return TemaCarta.Colore.rossoD
        case "Categoria": return TemaCarta.Colore.pennaD
        default: return TemaCarta.Colore.matitaD
        }
    }
}

/// Il riquadro del livello «Non trovato»: cosa si sa e l'invito a caricare il set informativo.
private struct RiquadroNonTrovato: View {
    let testo: String

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: TemaCarta.Modulo.raggioGruppo, style: .continuous)
        HStack(alignment: .top, spacing: TemaCarta.Modulo.spazioColonne / 2) {
            Image(systemName: "doc.badge.plus")
                .fontCarta(TemaCarta.Catalogo.nomeRiga)
                .foregroundColor(TemaCarta.Colore.rossoD)
            Text(testo)
                .fontCarta(TemaCarta.Catalogo.testoSezione)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TemaCarta.Modulo.paddingGruppo)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(forma.fill(TemaCarta.Colore.foglioD))
        .overlay(forma.strokeBorder(TemaCarta.Colore.rossoD, lineWidth: Tema.Misura.filo * 2).allowsHitTesting(false))
    }
}

/// Un campo numerico con l'etichetta in SF Mono sopra.
private struct CampoNumeroCatalogo: View {
    let etichetta: String
    @Binding var testo: String
    let segnaposto: String

    private typealias M = TemaCarta.Modulo

    var body: some View {
        VStack(alignment: .leading, spacing: M.sottoEtichetta) {
            Text(etichetta.uppercased())
                .fontCarta(M.etichetta)
                .tracking(M.tracciaEtichetta)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .lineLimit(1)
            CasellaNumeroCatalogo(testo: $testo, segnaposto: segnaposto)
        }
    }
}

private struct CasellaNumeroCatalogo: View {
    @Binding var testo: String
    let segnaposto: String

    private typealias M = TemaCarta.Modulo

    var body: some View {
        TextField(segnaposto, text: $testo)
            .textFieldStyle(.plain)
            .fontCarta(M.valore)
            .monospacedDigit()
            .foregroundColor(TemaCarta.Colore.inchiostroD)
            .padding(.horizontal, M.paddingCampo)
            .frame(width: TemaCarta.Catalogo.campoNumero, height: M.altezzaCampo)
            .background(CasellaCatalogo())
    }
}

/// Il fondo delle caselle e delle righe: foglio chiaro con il filo.
private struct CasellaCatalogo: View {
    var body: some View {
        let forma = RoundedRectangle(cornerRadius: TemaCarta.Modulo.raggioCampo, style: .continuous)
        forma
            .fill(TemaCarta.Colore.foglioD)
            .overlay(forma.strokeBorder(TemaCarta.Colore.filo2D, lineWidth: Tema.Misura.filo))
    }
}

// MARK: - Nella posizione del cliente

/// La riga del dettaglio di una posizione: «Dal catalogo: <prodotto>» con «Apri la scheda», o «Abbina al catalogo».
struct RigaCatalogoPosizione: View {
    @Environment(StatoShell.self) private var stato
    let posizione: Posizione

    private typealias K = TemaCarta.Catalogo
    private typealias M = TemaCarta.Modulo

    var body: some View {
        let voce = posizione.catalogoId.flatMap { CatalogoProdotti.condiviso?.voce(id: $0) }
        HStack(alignment: .center, spacing: M.spazioColonne / 2) {
            Image(systemName: "books.vertical")
                .fontCarta(K.notaRiga)
                .foregroundColor(TemaCarta.Colore.matitaD)
            if let voce {
                Text("Dal catalogo: \(voce.nomeCompleto)")
                    .fontCarta(K.notaRiga)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .lineLimit(1)
                Spacer(minLength: M.spazioColonne)
                Button("Apri la scheda") {
                    stato.richiestaCatalogoCompagnie = RichiestaCatalogoCompagnie.perPosizione(posizione, voceId: voce.id)
                }
                .buttonStyle(StileVetro())
                .help("La scheda del catalogo con gli importi di questa posizione")
                Button("Cambia") {
                    stato.richiestaCatalogoCompagnie = RichiestaCatalogoCompagnie.perPosizione(posizione)
                }
                .buttonStyle(StileVetro())
                .disabled(stato.solaLettura)
                .help("Abbina la posizione a un'altra riga del catalogo")
            } else {
                Text("Non abbinata al catalogo delle compagnie")
                    .fontCarta(K.notaRiga)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                    .lineLimit(1)
                Spacer(minLength: M.spazioColonne)
                Button("Abbina al catalogo") {
                    stato.richiestaCatalogoCompagnie = RichiestaCatalogoCompagnie.perPosizione(posizione)
                }
                .buttonStyle(StileVetro())
                .disabled(stato.solaLettura)
                .help("Cerca il prodotto nel catalogo delle compagnie: Lucy propone le righe simili, confermi tu")
            }
        }
    }
}

#endif
