import SwiftUI

// L'app Studio (versione «Orizzonte», Design/template-novita-specifica.md §1.6 e §2): il lavoro del consulente visto
// come un portafoglio. Testata «Il tuo studio. · Il tuo lavoro, come un portafoglio» (`AppPrisma.titoloIntestazione` e
// `occhiello`) con il segmentato a pillola a destra, in tre gruppi separati da un filo (Migliorie d'uso 52, «Lo Studio
// in ordine»): i conti Cruscotto · Parcelle · Spese | i risultati Track record | l'allenamento Esame OCF · Palestra.
// Cruscotto (StudioCruscotto.swift), Parcelle e fatture (StudioParcelle.swift), Track record (StudioTrackRecord.swift) ed
// Esame OCF (StudioEsameOCF.swift); una scheda che non c'è ancora direbbe con una nota sobria cosa arriverà.
//
// - Le cifre vengono da MotoreStudio, tenute in cache da StatoShell (`cruscottoStudio()`, DerivatiDati): il corpo è una
//   vista `Equatable` che si rifà solo con una `ChiaveVista` nuova (dati dei calcoli, giorno, ora, modalità cliente).
// - Cambio di scheda (`rimonta`): il contenuto svanisce in 0,13 s fino a scala 0,99, poi rientra a cascata da 0.
// - Modalità cliente: Studio è il lavoro del consulente (provvigioni, parcelle, obiettivi), non si mostra al cliente.
// - «Riduci movimento» e istantanee: tutto subito fermo nello stato finale.
// Valori in DesignSystem/Apple/Tema.Apple+Studio.swift.

/// Le schede di Studio, nell'ordine del segmentato (Migliorie d'uso 52: le Spese salgono accanto alle Parcelle; i
/// `rawValue` restano gli stessi).
enum SchedaStudio: String, CaseIterable, Identifiable, Hashable {
    case cruscotto, fatture, spese, track, ocf, palestra

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .cruscotto: return "Cruscotto"
        // Con «Luce» «Parcelle e fatture» si accorcia in «Parcelle»; con le migliorie d'uso 52 sul Mac «OCF» torna
        // «Esame OCF» (su iPhone e iPad resta corto, perché il segmentato ci stia)
        case .fatture: return "Parcelle"
        case .track: return "Track record"
        case .ocf:
            #if os(macOS)
            return "Esame OCF"
            #else
            return "OCF"
            #endif
        case .palestra: return "Palestra"
        case .spese: return "Spese"
        }
    }

    /// Il gruppo della scheda nel segmentato (Migliorie d'uso 52): 0 i conti, 1 i risultati, 2 l'allenamento. Fra due
    /// gruppi c'è un filo.
    var gruppo: Int {
        switch self {
        case .cruscotto, .fatture, .spese: return 0
        case .track: return 1
        case .ocf, .palestra: return 2
        }
    }

    /// Gli indici delle schede davanti alle quali va il filo: dove il gruppo cambia rispetto alla scheda prima (così,
    /// senza le Spese, i fili restano giusti).
    static func separatoriPrima(_ schede: [SchedaStudio]) -> Set<Int> {
        Set(schede.indices.filter { $0 > 0 && schede[$0].gruppo != schede[$0 - 1].gruppo })
    }

    /// Studio › Spese c'è solo sul Mac: iPhone e iPad non la hanno (decisione 34), e le spese restano fuori da «Prisma
    /// ovunque».
    static var speseSulDispositivo: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    /// Le schede del segmentato: Spese solo sul Mac e mai in modalità cliente (§6.3.1 punto 1.7: «la scheda Spese non si
    /// vede»; le altre schede in modalità cliente mostrano «Studio resta tuo»).
    static func visibili(modoCliente: Bool) -> [SchedaStudio] {
        allCases.filter { $0 != .spese || (speseSulDispositivo && !modoCliente) }
    }

    /// La scheda da mostrare al posto di una che qui non si vede: il Cruscotto.
    static func mostrabile(_ s: SchedaStudio, modoCliente: Bool) -> SchedaStudio {
        visibili(modoCliente: modoCliente).contains(s) ? s : .cruscotto
    }

    /// Cosa arriverà nelle schede che in questo giro non ci sono ancora (nil per il Cruscotto).
    var prossima: String? {
        switch self {
        case .cruscotto:
            return nil
        case .fatture:
            // C'è dal giro 2 (StudioParcelle.swift)
            return nil
        case .track:
            // C'è dal giro 2 (StudioTrackRecord.swift)
            return nil
        case .ocf:
            // C'è dal giro 6 (StudioEsameOCF.swift)
            return nil
        case .palestra:
            // C'è dal giro 5 di Luce (StudioPalestra.swift)
            return nil
        case .spese:
            // C'è dal giro 9 di Luce (StudioSpese.swift)
            return nil
        }
    }
}

// MARK: - Testi

/// I testi di Studio che servono in più viste (cruscotto, scrivania, impostazioni).
enum TestiStudio {
    static let titoloRiservato = "Studio resta tuo"
    static let testoRiservato = "In modalità cliente le cifre del tuo lavoro (provvigioni, parcelle e obiettivi) non si "
        + "mostrano. Esci dalla modalità cliente per rivederle."
    static let parcelleInArrivo = "Le parcelle arrivano con Parcelle e fatture"
    static let provvigioniStimate = "provvigioni stimate dalle tue aliquote"
    static let parcelleConsulenza = "parcelle della consulenza"
    static let primoAnno = "primo anno in Prisma"
    static let datiDiProva = "dati di prova"
    static let obiettiviScrivania = "Dai a Studio gli obiettivi dell’anno"
    static let senzaAliquoteScrivania = "stima senza le tue aliquote"
    static let inserisciAliquote = "Inserisci le tue aliquote"
    static let imposta = "Imposta gli obiettivi"
    #if os(macOS)
    /// Migliorie d'uso 53: la frase di riposo della dispersione (prima che il grafico dica cosa si vede).
    static let didascaliaValore = "Ogni punto è un cliente: più a destra, più ore; più in alto, più ricavi."
    #else
    static let didascaliaValore = "Ogni punto è un cliente: ore che gli dedichi nell’anno e ricavi che genera."
    #endif
    static let senzaOre = "Servono appuntamenti con una durata per contare le ore."
    static let zona = "molto tempo, poco valore"

    /// «novembre»: il mese in minuscolo, per la testata del riquadro della scrivania.
    private static let formatoMese = Formati.formato("MMMM")
    /// «dic»: il mese abbreviato sotto le colonne degli incassi.
    private static let formatoMeseBreve = Formati.formato("MMM")

    static func mese(_ d: Date) -> String { formatoMese.string(from: d).lowercased() }
    static func meseBreve(_ d: Date) -> String {
        formatoMeseBreve.string(from: d).lowercased().replacingOccurrences(of: ".", with: "")
    }

    /// «410.000 €» con il punto delle migliaia (come i numeri che si contano).
    static func euro(_ v: Double) -> String { FormatoCifra.euro.testo(v) }

    /// «+18% sul 2025» (meno tipografico se scende).
    static func variazione(_ v: Double, annoPrima: Int) -> String {
        let percento = (v * 100).rounded()
        return (percento > 0 ? "+" : "") + FormatoCifra.migliaia(percento) + "% sul \(annoPrima)"
    }

    /// «12 proposte», «1 proposta».
    static func proposte(_ n: Int) -> String { n == 1 ? "1 proposta" : "\(n) proposte" }

    /// «stima · 2 posizioni senza aliquota».
    static func senzaAliquota(_ n: Int) -> String {
        n == 1 ? "1 posizione senza aliquota" : "\(n) posizioni senza aliquota"
    }

    /// Il fumetto di un punto della dispersione: «Giulia Rossi · 14 ore · 2.900 €».
    static func punto(_ p: CruscottoStudio.PuntoCliente) -> String {
        "\(p.cliente.nome) · \(FormatoCifra.mesi.testo(p.ore)) ore · \(euro(p.ricavi))"
    }

    /// Il fumetto di una colonna degli incassi: «dicembre · Alleanza 1.200 € · Indipendente 0 €».
    static func mese(_ m: CruscottoStudio.MeseIncasso) -> String {
        let alleanza = m.alleanza.map(euro) ?? "senza aliquote"
        return "\(mese(m.inizio)) · \(Canale.alleanza.nomeBreve) \(alleanza) · \(Canale.indipendente.nomeBreve) \(euro(m.indipendente))"
    }

    // MARK: Migliorie d'uso 53 · Il cruscotto risponde a domande

    // I titoli delle card diventano le domande a cui rispondono (solo sul Mac: iPhone e iPad li prendono con il loro
    // aggiornamento).
    static func domandaRicavi(anno: Int) -> String {
        #if os(macOS)
        return "Quanto ho guadagnato nel \(String(anno))?"
        #else
        return "I tuoi ricavi \(String(anno))"
        #endif
    }

    static var domandaObiettivi: String {
        #if os(macOS)
        return "A che punto sono con gli obiettivi?"
        #else
        return "Gli obiettivi dell’anno"
        #endif
    }

    static var domandaImbuto: String {
        #if os(macOS)
        return "Dove si fermano le proposte?"
        #else
        return "L’imbuto delle proposte"
        #endif
    }

    static var domandaIncassi: String {
        #if os(macOS)
        return "Cosa incasso nei prossimi 12 mesi?"
        #else
        return "Gli incassi dei prossimi 12 mesi"
        #endif
    }

    static var domandaValore: String {
        #if os(macOS)
        return "A chi dedico più tempo di quanto rende?"
        #else
        return "Il valore e il tempo"
        #endif
    }

    /// L'etichetta dell'asse verticale della dispersione.
    static let asseRicavi = "ricavi dell’anno ↑"

    /// Un numero intero in lettere fino a dieci («tre»), poi in cifre («12»).
    static func inLettere(_ n: Int) -> String {
        let lettere = ["zero", "uno", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"]
        guard n >= 0, n < lettere.count else { return FormatoCifra.migliaia(Double(n)) }
        return lettere[n]
    }

    /// «in due mesi», «in un mese»; con un mese solo (dicembre: manca meno di un mese) «entro fine anno».
    static func inMesi(_ mesi: Int) -> String {
        if mesi <= 1 { return "entro fine anno" }
        let lettere = ["", "un", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci", "undici", "dodici"]
        return "in " + (mesi < lettere.count ? lettere[mesi] : FormatoCifra.migliaia(Double(mesi))) + " mesi"
    }

    /// «Il mese più ricco: novembre, 7.400 €».
    static func piuRicco(_ m: CruscottoStudio.MeseIncasso) -> String {
        "Il mese più ricco: \(mese(m.inizio)), \(euro(m.totale))"
    }

    /// La riga degli incassi con il puntatore su una colonna: «**novembre**: Alleanza 5.200 € + Indipendente 2.200 € =
    /// **7.400 €**». Senza aliquote la parte del primo canale dice «senza aliquote» e il totale è solo il secondo.
    static func meseIncasso(_ m: CruscottoStudio.MeseIncasso, nomeAlleanza: String, nomeIndipendente: String,
                            forte: Color) -> Text {
        let alleanza = m.alleanza.map(euro) ?? "senza aliquote"
        return Text(mese(m.inizio)).bold().foregroundColor(forte)
            + Text(verbatim: ": \(nomeAlleanza) \(alleanza) + \(nomeIndipendente) \(euro(m.indipendente)) = ")
            + Text(euro(m.totale)).bold().foregroundColor(forte)
    }

    /// La parte della frase degli obiettivi dopo l'etichetta: «nuovi clienti, 7 su 10. Ne mancano tre in due mesi.»
    /// (la voce con la prima lettera minuscola; nil senza traguardo).
    static func piuIndietro(_ o: CruscottoStudio.Obiettivo, mesi: Int) -> String? {
        guard let t = o.traguardo, t > 0 else { return nil }
        let nome = o.voce.nome
        let voce = (nome.first.map { $0.lowercased() } ?? "") + String(nome.dropFirst())
        let clienti = o.voce == .nuoviClienti
        let fatto = clienti ? FormatoCifra.migliaia(o.fatto.rounded()) : euro(o.fatto)
        let traguardo = clienti ? FormatoCifra.migliaia(t.rounded()) : euro(t)
        let manca = max(0, t - o.fatto)
        let resto: String
        if clienti {
            let n = Int(manca.rounded(.up))
            resto = (n == 1 ? "Ne manca uno " : "Ne mancano \(inLettere(n)) ") + inMesi(mesi) + "."
        } else {
            resto = "Ne mancano \(euro(manca)) " + inMesi(mesi) + "."
        }
        return "\(voce), \(fatto) su \(traguardo). " + resto
    }

    /// L'etichetta in grassetto della frase degli obiettivi.
    static let piuIndietroEtichetta = "Il più indietro:"

    /// Cosa si vede nella dispersione, senza nomi: «**2 clienti** prendono molte ore e rendono poco: il più pesante,
    /// 14 ore per 900 € l’anno. Tocca un punto con il nome per aprirlo.» Se la zona non si calcola, la frase di riposo.
    static func valoreDice(_ v: CruscottoStudio.ValoreTempo, forte: Color) -> Text {
        guard v.sogliaOre != nil else { return Text(didascaliaValore) }
        let zona = v.inZona
        guard let p = v.piuPesante, !zona.isEmpty else {
            return Text("Nessun cliente prende molte ore rendendo poco.")
        }
        let quanti = zona.count == 1 ? "1 cliente" : "\(zona.count) clienti"
        let verbo = zona.count == 1 ? " prende molte ore e rende poco" : " prendono molte ore e rendono poco"
        return Text(quanti).bold().foregroundColor(forte)
            + Text(verbatim: verbo + ": il più pesante, \(FormatoCifra.migliaia(p.ore.rounded())) ore per \(euro(p.ricavi)) l’anno. "
                   + "Tocca un punto con il nome per aprirlo.")
    }
}

// MARK: - Azioni dello stato

extension StatoShell {
    /// Apre Studio sulla scheda data (dalla scrivania, dalle novità, dal dock con la scheda di prima).
    func apriStudio(_ scheda: SchedaStudio = .cruscotto) {
        schedaStudio = SchedaStudio.mostrabile(scheda, modoCliente: inModoCliente)
        apri(.studio)
    }

    /// Apre Impostazioni › Studio (aliquote e obiettivi).
    func apriImpostazioniStudio() {
        ancoraImpostazioni = nil
        schedaImpostazioni = .studio
        apri(.impostazioni)
    }

    /// Scrive (o toglie, con nil) un'aliquota provvigionale Alleanza di un tipo di prodotto, in percentuale.
    /// Un valore negativo o non finito non si scrive; oltre 100 si ferma a 100.
    func impostaAliquotaStudio(_ area: AreaPosizione, _ tipo: MotoreStudio.TipoProvvigione, _ valore: Double?) {
        let pulito: Double? = valore.flatMap { v in (v.isFinite && v >= 0) ? min(v, 100) : nil }
        var studio = dati.impostazioni.studio
        var a = studio.aliquote[area] ?? AliquoteProvvigione()
        switch tipo {
        case .nuovaProduzione: a.nuovaProduzione = pulito
        case .ricorrente: a.ricorrenti = pulito
        case .rinnovo: a.rinnovi = pulito
        }
        studio.aliquote[area] = a.vuota ? nil : a
        guard studio != dati.impostazioni.studio else { return }
        dati.impostazioni.studio = studio
    }

    /// Scrive (o toglie, con nil) un obiettivo dell'anno. Un valore negativo o non finito non si scrive.
    func impostaObiettivoStudio(anno: Int, _ voce: VoceObiettivoStudio, _ valore: Double?) {
        // Oltre mille miliardi è un errore di battitura: non si scrive (le cifre si formattano come interi)
        let pulito: Double? = valore.flatMap { v in (v.isFinite && v >= 0 && v <= 1e12) ? v : nil }
        var studio = dati.impostazioni.studio
        var o = studio.obiettivi[anno] ?? ObiettiviStudio()
        switch voce {
        case .produzioneAlleanza: o.produzioneAlleanza = pulito
        // Un numero enorme (incollato per sbaglio) non si scrive: Int(_:) fermerebbe l'app oltre Int.max
        case .nuoviClienti: o.nuoviClienti = pulito.flatMap { $0 < Double(Int32.max) ? Int($0.rounded()) : nil }
        case .ricaviConsulenza: o.ricaviConsulenza = pulito
        }
        studio.obiettivi[anno] = o.vuoto ? nil : o
        guard studio != dati.impostazioni.studio else { return }
        dati.impostazioni.studio = studio
    }
}

// MARK: - Il segmentato della testata

/// «▶︎ Il tuo anno» e il segmentato a pillola delle quattro schede, a destra nella testata della finestra.
struct AzioniStudio: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        HStack(spacing: Tema.Apple.Scrivania.Saluto.spazioPulsanti) {
            // «▶︎ Il tuo anno» in tutte le schede (Luce giro 5, StoriaLuce.swift); non in modalità cliente
            if !stato.inModoCliente {
                Button {
                    stato.apriStoria(.anno)
                } label: {
                    Label("Il tuo anno", systemImage: "play.fill")
                }
                .buttonStyle(.appleVetro)
                .fixedSize()
                .help("Il tuo anno da consulente, in un minuto")
            }
            // Migliorie d'uso 52: sul Mac tre gruppi separati da un filo (su iPhone e iPad niente fili)
            let schede = SchedaStudio.visibili(modoCliente: stato.inModoCliente)
            #if os(macOS)
            let separatori: Set<Int> = SchedaStudio.separatoriPrima(schede)
            #else
            let separatori: Set<Int> = []
            #endif
            SegmentatoPillola(selezione: Bindable(stato).schedaStudio,
                              valori: schede, titolo: { $0.titolo },
                              separatoriPrima: separatori)
                .fixedSize()
            #if os(macOS)
            // Migliorie d'uso 28: «＋ Nuova parcella» sta qui, dopo le schede, solo in Parcelle (come «Nuovo cliente»);
            // il modulo lo apre la scheda (StudioParcelle.swift), che osserva la richiesta
            if stato.schedaStudio == .fatture && !stato.inModoCliente {
                Button(TestiParcelle.nuova) { stato.richiestaNuovaParcella += 1 }
                    .buttonStyle(.applePrimario)
                    .fixedSize()
                    .disabled(stato.solaLettura || stato.clienti.isEmpty)
                    .help("Una parcella della consulenza indipendente: il cliente, la consulenza e l’importo")
            }
            #endif
        }
    }
}

// MARK: - L'app

/// Il contenuto della finestra di Studio.
struct AppStudio: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        CorpoStudio(stato: stato, chiave: stato.chiaveVista, scheda: stato.schedaStudio)
            .equatable()
    }
}

/// Il corpo di Studio: si rifà solo quando cambiano i dati dei calcoli (chiave) o la scheda.
private struct CorpoStudio: View, Equatable {
    let stato: StatoShell
    let chiave: ChiaveVista
    let scheda: SchedaStudio

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    /// La scheda mostrata: resta quella di prima finché il contenuto non è uscito.
    @State private var mostrata: SchedaStudio?
    @State private var esce = false
    /// Dopo il primo cambio di scheda la cascata parte da 0 e gli anelli a 0,15 s.
    @State private var cambiato = false

    nonisolated static func == (a: CorpoStudio, b: CorpoStudio) -> Bool {
        a.stato === b.stato && a.chiave == b.chiave && a.scheda == b.scheda
    }

    private var base: Double {
        let m = Tema.Apple.Studio.Moto.self
        return cambiato ? m.baseCambio : m.baseApertura
    }

    private var ritardoAnelli: Double {
        let m = Tema.Apple.Studio.Moto.self
        return cambiato ? m.anelliCambio : m.anelliApertura
    }

    var body: some View {
        let s = SchedaStudio.mostrabile(mostrata ?? scheda, modoCliente: chiave.modo != nil)
        let m = Tema.Apple.Studio.Moto.self
        return contenuto(s)
            .id(s)
            .opacity(esce ? 0 : 1)
            .scaleEffect(esce ? m.scalaRimonta : 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            // Nelle istantanee la scheda non cambia mai: niente da scrivere alla comparsa
            .onAppear { if mostrata == nil && !istantanea { mostrata = scheda } }
            .onChange(of: scheda) { nuova in cambia(nuova) }
    }

    @ViewBuilder private func contenuto(_ s: SchedaStudio) -> some View {
        if chiave.modo != nil {
            RiservatoStudio()
                .entrataCascata(0, base: base)
        } else if s == .cruscotto {
            CruscottoStudioVista(stato: stato, base: base, ritardoAnelli: ritardoAnelli)
        } else if s == .fatture {
            // Studio › Parcelle e fatture (giro 2): StudioParcelle.swift; osserva lo stato da sé
            ParcelleStudioVista(base: base)
        } else if s == .track {
            // Studio › Track record (giro 2): StudioTrackRecord.swift
            TrackRecordStudioVista(stato: stato, base: base)
        } else if s == .ocf {
            // Studio › Esame OCF (giro 6): StudioEsameOCF.swift; osserva lo stato da sé (le risposte non cambiano la chiave)
            EsameOCFStudioVista(stato: stato, base: base, ritardoAnelli: ritardoAnelli)
        } else if s == .palestra {
            // Studio › Palestra («Luce» giro 5): StudioPalestra.swift; osserva da sé lo stato della palestra
            PalestraStudioVista(stato: stato, palestra: stato.palestra, base: base)
        } else if s == .spese {
            // Studio › Spese («Luce» giro 9): StudioSpese.swift; osserva da sé spese, scadenze, agenda e impostazioni
            SpeseStudioVista(stato: stato, base: base, ritardoAnelli: ritardoAnelli)
        } else {
            ProssimaSchedaStudio(scheda: s)
                .entrataCascata(0, base: base)
        }
    }

    private func cambia(_ nuova: SchedaStudio) {
        guard nuova != mostrata else {
            esce = false
            return
        }
        if istantanea || calmo {
            let mostra: () -> Void = {
                cambiato = true
                mostrata = nuova
                esce = false
            }
            if istantanea {
                mostra()
            } else {
                withAnimation(Tema.Moto.dissolvenzaCalma) { mostra() }
            }
            return
        }
        let m = Tema.Apple.Studio.Moto.self
        withAnimation(m.uscitaRimonta) { esce = true }
        Movimenti.dopo(Tema.Apple.Moto.tempo(m.durataRimonta)) {
            // Un clic su un'altra scheda nel frattempo: entra quella, con il suo giro
            guard stato.schedaStudio == nuova else { return }
            cambiato = true
            mostrata = nuova
            esce = false
        }
    }
}

// MARK: - Schede che arrivano e modalità cliente

/// Una scheda di Studio che in questo giro non c'è ancora: il suo nome e cosa arriverà, senza cifre finte.
private struct ProssimaSchedaStudio: View {
    let scheda: SchedaStudio

    var body: some View {
        let p = Tema.Apple.Studio.Prossime.self
        VStack(alignment: .leading, spacing: p.spazio) {
            Text(scheda.titolo)
                .carattereApple(p.titolo)
                .foregroundColor(p.coloreTitolo)
            Text(scheda.prossima ?? "")
                .carattereApple(p.testo)
                .foregroundColor(p.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(p.padding)
        .frame(maxWidth: p.larghezza, alignment: .leading)
        .superficieApple(p.superficie, raggio: p.raggio)
        .padding(.top, p.sopra)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// In modalità cliente: Studio non mostra le cifre del consulente.
private struct RiservatoStudio: View {
    var body: some View {
        let p = Tema.Apple.Studio.Prossime.self
        let r = Tema.Apple.Studio.Riservato.self
        VStack(alignment: .leading, spacing: p.spazio) {
            Text(TestiStudio.titoloRiservato)
                .carattereApple(r.titolo)
                .foregroundColor(r.coloreTitolo)
            Text(TestiStudio.testoRiservato)
                .carattereApple(r.testo)
                .foregroundColor(r.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(p.padding)
        .frame(maxWidth: p.larghezza, alignment: .leading)
        .superficieApple(p.superficie, raggio: p.raggio)
        .padding(.top, p.sopra)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
