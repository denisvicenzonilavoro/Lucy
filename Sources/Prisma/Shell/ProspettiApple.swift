#if os(macOS)
import AppKit
#endif
import SwiftUI

// Prospetti e report nel tema Apple, sul Mac e sull'iPad (Design/template-apple-specifica.md §4.5.1, riferimenti PIE p01-p08):
//
//   ┌─ ◉ Giulia Rossi ⌄ ───────────┐  Il check-up di Giulia Rossi        [Chiedi a Vera] [▶︎ Presenta all'incontro]
//   │ PER L'INCONTRO               │  Report · Giulia Rossi · A4 …      [Stampa…] [Archivia nei Documenti] [Salva PDF…]
//   │ ▌Check-up         (scelto)   │  ┌──────────────────────────────────────────────┐
//   │   Prospetto | Report …       │  │              ┌────────────┐                   │
//   │  Valutazione                 │  │              │   carta    │  la pagina cambia │
//   │  …                           │  │              │  bianca    │  scorrendo        │
//   │ PROSPETTI DI DETTAGLIO · …   │  │              └────────────┘                   │
//   │ ┌ FASCICOLO DELL'INCONTRO ┐  │  │                ‹  2 di 5  ›                   │
//   │ └ [Componi il fascicolo]  ┘  │  └──────────────────────────────────────────────┘
//   └──────────────────────────────┘
//
// - La barra laterale (290) tiene il cliente scelto (avatar 30, si cambia dalla tendina), «Per l'incontro» con le
//   voci di sempre (titolo e sottotitolo come `.rub`) e la card «Fascicolo dell'incontro». Sotto la voce scelta si
//   aprono le scelte del documento di oggi (prospetto o report, posizioni, valutazioni, commento): restano tutte.
// - L'anteprima è la carta vera (le stesse pagine del PDF, sempre bianche) su fondo `chip` con raggio 20, una pagina
//   alla volta, grande quanto lo spazio permette. Cambia con `.cambioPagina` (§2.23): scegliendo un'altra voce (giù
//   = la pagina vecchia sale), con le frecce sotto la carta o scorrendo con la rotella o il trackpad sull'anteprima.
// - Le azioni di oggi restano tutte: Chiedi a Vera, Presenta all'incontro (dalla pagina mostrata), Stampa, Archivia
//   nei Documenti, Salva PDF (il blu, l'azione principale).
// - «Riduci movimento»: dissolvenze di 0,15 s; istantanee: tutto fermo nello stato finale.
// - Sull'iPad la stessa app: niente passaggio del puntatore, la carta si sfoglia col dito (`SfogliaAnteprimaApple`).
// - Sul Mac (migliorie d'uso 23) la colonna ha i documenti per momento (`ElencoProspetti`), con la riga «a cosa serve»,
//   le etichette delle versioni e «per l'incontro di oggi»; la riga scelta non si allarga (solo le scelte per impaginare)
//   e la descrizione lunga sta dietro la «i» sopra la pagina (Shell/ElencoProspettiApple.swift). Niente piede.
// Valori in DesignSystem/Apple/Tema.Apple+Prospetti.swift. L'iPhone non ha Prospetti.

// MARK: - Stili delle scelte del documento (comuni)

/// I caratteri e i colori delle scelte del documento: quelli del tema Apple (le scelte stanno nella barra laterale),
/// sul Mac e sull'iPad.
enum StileScelteProspetto {
    private typealias S = Tema.Apple.Prospetti.Scelte
    static var nota: Font { S.nota.font }
    static var coloreNota: Color { S.coloreNota }
    static var testo: Font { S.testo.font }
    static var coloreTesto: Color { S.coloreTesto }
    static var etichetta: Font { S.etichetta.font }
    static var coloreEtichetta: Color { S.coloreEtichetta }
    static var forte: Font { S.forte.font }
    static var piccolo: Font { S.piccolo.font }
    static var punto: Color { S.punto }
    static var errore: Color { S.errore }
    static var titolo: Font { Tema.Apple.Prospetti.Anteprima.vuotoTitolo.font }
    static var coloreTitolo: Color { Tema.Apple.Colore.inchiostro }
    static var collegamento: Color { Tema.Apple.Colore.accento }
}

/// I pulsanti delle scelte del documento: i pulsanti a capsula del tema Apple (l'accento è il testo blu: il blu pieno
/// resta a «Salva PDF…»), sul Mac e sull'iPad. `taglia` resta per chi la passa.
struct StileAzioneSceltaProspetto: ButtonStyle {
    var taglia: TagliaPulsante = .normale
    var accento = false

    init(taglia: TagliaPulsante = .normale, accento: Bool = false) {
        self.taglia = taglia
        self.accento = accento
    }

    func makeBody(configuration: Configuration) -> some View {
        StilePulsanteApple(accento ? .sobria : .secondaria).makeBody(configuration: configuration)
    }
}

extension View {
    /// Una riga scelta negli elenchi delle scelte (obiettivi, valutazioni, posizioni): la selezione del tema Apple
    /// (`rgba(0,122,255,.13)`, raggio 14), sul Mac e sull'iPad.
    func voceSceltaProspetto(attiva: Bool) -> some View {
        let forma = RoundedRectangle(cornerRadius: Tema.Apple.Prospetti.Laterale.raggioVoce, style: .continuous)
        return self
            .background { forma.fill(attiva ? Tema.Apple.Prospetti.Laterale.fondoScelta : Color.clear) }
            .contentShape(forma)
    }
}

// MARK: - La pagina dell'anteprima

/// La pagina mostrata nell'anteprima: vale per la scelta e il cliente con cui è stata girata (con un'altra scelta
/// si riparte dalla prima pagina).
struct PaginaAnteprimaProspetto: Equatable {
    var scelta: SceltaProspetto?
    var cliente = ""
    var indice = 0
}

/// L'identità della pagina nell'anteprima: cambia con la scelta, il cliente e il numero di pagina (e così parte
/// `.cambioPagina`), non con una nuova impaginazione dello stesso documento.
struct IdAnteprimaProspetto: Hashable {
    let scelta: SceltaProspetto
    let cliente: String
    let indice: Int
}

// MARK: - L'app sul Mac e sull'iPad

extension AppProspetti {
    /// «Per l'incontro»: le voci di prospetto e report, nell'ordine di sempre.
    var tipiPerIncontro: [TipoProspetto] {
        [.annoInsieme, .checkUp, .valutazione, .resoconto, .patrimonio, .resistenza, .costi, .successione, .sostituzione,
         .previdenza, .protezione, .obiettivo, .liquidita]
    }

    /// I prospetti di dettaglio, per te.
    static let tipiDiDettaglio: [TipoProspetto] = [.riesame, .posizione, .confronto]

    /// L'ordine di tutte le voci, dall'alto in basso: dice da che parte gira la pagina.
    private var ordineVoci: [TipoProspetto] {
        #if os(macOS)
        // Migliorie d'uso 23: l'ordine dei gruppi per momento
        ElencoProspetti.ordine
        #else
        tipiPerIncontro + Self.tipiDiDettaglio + [.portafoglio, .fascicolo]
        #endif
    }

    var corpoProspettiApple: some View {
        // Impaginato una volta sola finché non cambia qualcosa che conta (DerivatiDati), non a ogni disegno
        let documento = stato.documentoProspettoInCache(scelta)
        // Il numero di questa impaginazione: preso subito, è quello del documento qui sopra
        let generazione = stato.generazioneDocumento
        let d = Tema.Apple.Prospetti.Disposizione.self
        return HStack(alignment: .top, spacing: d.spazioLaterale) {
            barraLateraleApple
                .frame(width: d.larghezzaLaterale)
                .frame(maxHeight: .infinity, alignment: .top)
            VStack(alignment: .leading, spacing: d.spazioBarra) {
                if let documento {
                    barraAzioniApple(documento)
                }
                anteprimaApple(documento, generazione: generazione)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Barra laterale

    private var barraLateraleApple: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        let forma = RoundedRectangle(cornerRadius: l.raggio, style: .continuous)
        #if !os(macOS)
        let perIncontro = tipiPerIncontro
        #endif
        // La voce scelta, letta una volta per tutte le voci (non una per voce)
        let scelto = scelta.tipo
        return VStack(alignment: .leading, spacing: 0) {
            RigaClienteProspettiApple()
                .padding(.bottom, l.sottoCliente)
            ScrollViewReader { lettore in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        #if os(macOS)
                        gruppiPerMomentoApple(scelto: scelto)
                        // Migliorie d'uso 23 (decisione 23-e): niente piede con i collegamenti e la nota «Impaginati sul Mac…»
                        cardFascicoloApple
                            .padding(.top, l.sopraFascicolo)
                            .id(TipoProspetto.fascicolo.id)
                            .entrataCascata(ElencoProspetti.ordine.count + ElencoProspetti.gruppi.count)
                        #else
                        gruppoApple("Per l'incontro", tipi: perIncontro, primo: 0, scelto: scelto)
                        gruppoApple("Prospetti di dettaglio", tipi: Self.tipiDiDettaglio, primo: perIncontro.count + 1, scelto: scelto)
                        if !stato.inModoCliente {
                            gruppoApple("Per te", tipi: [.portafoglio], primo: perIncontro.count + Self.tipiDiDettaglio.count + 2, scelto: scelto)
                        }
                        cardFascicoloApple
                            .padding(.top, l.sopraFascicolo)
                            .id(TipoProspetto.fascicolo.id)
                            .entrataCascata(perIncontro.count + Self.tipiDiDettaglio.count + 4)
                        piedeLateraleApple
                            .padding(.top, l.sopraPiede)
                        #endif
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                // All'apertura la voce scelta si vede anche se è in fondo all'elenco
                .onAppear { if !modoIstantanea { lettore.scrollTo(scelto.id) } }
            }
        }
        .padding(l.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .clipShape(forma)
        .superficieApple(l.superficie, raggio: l.raggio)
        // Le scelte del documento (segmentato, pannelli, etichette del canale) nello stile del tema Apple
        .strumentiApple()
    }

    private func gruppoApple(_ titolo: String, tipi: [TipoProspetto], primo: Int, scelto: TipoProspetto) -> some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        return VStack(alignment: .leading, spacing: l.fraVoci) {
            Text(titolo)
                .carattereApple(l.etichetta)
                .foregroundColor(l.coloreEtichetta)
                .lineLimit(1)
                .padding(.top, primo == 0 ? 0 : l.sopraGruppo)
                .padding(.bottom, max(0, l.sottoEtichetta - l.fraVoci))
                .entrataCascata(primo)
            ForEach(Array(tipi.enumerated()), id: \.element) { i, t in
                voceApple(t, scelto: scelto)
                    .entrataCascata(primo + i + 1, sfocatura: false)
            }
        }
    }

    #if os(macOS)
    /// Migliorie d'uso 23: i gruppi per momento («Primo incontro», «Le analisi», «Per una proposta», «Fine anno»,
    /// «Per te» fuori dalla modalità cliente), con il documento adatto all'incontro di oggi segnato in verde.
    @ViewBuilder private func gruppiPerMomentoApple(scelto: TipoProspetto) -> some View {
        let gruppi = ElencoProspetti.gruppi.filter { !(stato.inModoCliente && $0.titolo == ElencoProspetti.gruppoPerTe) }
        let primi = Self.primiIndici(gruppi.map { $0.tipi.count })
        let oggi = stato.prospettoPerIncontroOggi(cliente)
        ForEach(Array(gruppi.enumerated()), id: \.offset) { i, g in
            gruppoMomentoApple(g.titolo, tipi: g.tipi, primo: primi[i], scelto: scelto, perIncontroOggi: oggi)
        }
    }

    /// L'indice di cascata della prima riga di ogni gruppo (l'etichetta del gruppo conta una riga).
    private static func primiIndici(_ conteggi: [Int]) -> [Int] {
        var primi: [Int] = []
        var n = 0
        for c in conteggi {
            primi.append(n)
            n += c + 1
        }
        return primi
    }

    private func gruppoMomentoApple(_ titolo: String, tipi: [TipoProspetto], primo: Int, scelto: TipoProspetto,
                                    perIncontroOggi: TipoProspetto?) -> some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        return VStack(alignment: .leading, spacing: l.fraVoci) {
            Text(titolo)
                .carattereApple(l.etichetta)
                .foregroundColor(l.coloreEtichetta)
                .lineLimit(1)
                .padding(.top, primo == 0 ? 0 : l.sopraGruppo)
                .padding(.bottom, max(0, l.sottoEtichetta - l.fraVoci))
                .entrataCascata(primo)
            ForEach(Array(tipi.enumerated()), id: \.element) { i, t in
                voceMomentoApple(t, scelto: scelto, perIncontroOggi: perIncontroOggi == t)
                    .entrataCascata(primo + i + 1, sfocatura: false)
            }
        }
    }

    /// Una riga: il nome, la riga «a cosa serve» (al più due righe) e le etichette. La riga scelta non si allarga: sotto
    /// restano solo le scelte che servono a impaginare (e il commento del report), se ce ne sono (decisione 23-d).
    private func voceMomentoApple(_ t: TipoProspetto, scelto: TipoProspetto, perIncontroOggi: Bool) -> some View {
        let scelta = scelto == t
        return VStack(alignment: .leading, spacing: 0) {
            VoceProspettoApple(titolo: nomeBreve(t), sottotitolo: t.inBreve, nuovo: voceNuova(t), scelta: scelta,
                               righeSottotitolo: Tema.Apple.Prospetti.Laterale.righeInBreve,
                               conEtichette: true, versioni: t.versioni, incontroOggi: perIncontroOggi) {
                scegliApple(t)
            }
            if scelta && sceltaSiAllarga {
                contenutoScelta
                    .padding(Tema.Apple.Prospetti.Laterale.paddingScelte)
                    .transition(.opacity)
            }
        }
        .id(t.id)
    }
    #endif

    private func voceApple(_ t: TipoProspetto, scelto: TipoProspetto) -> some View {
        let scelta = scelto == t
        return VStack(alignment: .leading, spacing: 0) {
            VoceProspettoApple(titolo: nomeBreve(t), sottotitolo: sottotitoloVoce(t), nuovo: voceNuova(t), scelta: scelta) {
                scegliApple(t)
            }
            if scelta {
                contenutoScelta
                    .padding(Tema.Apple.Prospetti.Laterale.paddingScelte)
                    .transition(.opacity)
            }
        }
        .id(t.id)
    }

    /// Il sottotitolo della voce (`.rub small`): che cosa si impagina.
    private func sottotitoloVoce(_ t: TipoProspetto) -> String {
        switch t {
        case .riesame: return "Prospetto per te, prima dell'incontro"
        case .posizione: return "Una posizione o una proposta"
        case .confronto: return "Due voci a fronte"
        case .portafoglio: return "Tutti i clienti, solo per te"
        case .fascicolo: return "I report scelti in un solo PDF"
        case .annoInsieme: return "Report per il cliente"
        default: return "Prospetto e report"
        }
    }

    /// «nuovo» accanto al sottotitolo (in accento): per i report appena arrivati in Prisma.
    private func voceNuova(_ t: TipoProspetto) -> Bool {
        t == .annoInsieme
    }

    /// Sceglie la voce: la pagina vecchia esce verso l'alto se si scende nell'elenco, verso il basso se si risale.
    func scegliApple(_ t: TipoProspetto) {
        guard t != scelta.tipo else { return }
        let da = ordineVoci.firstIndex(of: scelta.tipo) ?? 0
        let a = ordineVoci.firstIndex(of: t) ?? 0
        cambiaAnteprima(direzione: a >= da ? 1 : -1) { scegli(t) }
    }

    /// Il verso va deciso prima del cambio: la pagina che esce porta la transizione con cui è stata disegnata.
    private func cambiaAnteprima(direzione: Int, _ cambia: @escaping () -> Void) {
        let animazione = Tema.Apple.Moto.animazione(Tema.Apple.Moto.Pagina.entrata, calmo: calmo, istantanea: modoIstantanea)
        let esegui = {
            if let animazione {
                withAnimation(animazione) { cambia() }
            } else {
                cambia()
            }
        }
        if direzione == direzioneAnteprima {
            esegui()
        } else {
            direzioneAnteprima = direzione
            DispatchQueue.main.async { esegui() }
        }
    }

    private var cardFascicoloApple: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        #if os(macOS)
        // Migliorie d'uso 70: il fascicolo non è più una voce dell'elenco; la card apre la scheda che nasce da lei
        let scelto = false
        #else
        let scelto = scelta.tipo == .fascicolo
        #endif
        let forma = RoundedRectangle(cornerRadius: l.raggioFascicolo, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            Text("Fascicolo dell'incontro")
                .carattereApple(l.etichetta)
                .foregroundColor(l.coloreEtichetta)
                .lineLimit(1)
            Text("I report scelti in un solo PDF, con la data dell'incontro.")
                .carattereApple(l.testoFascicolo)
                .foregroundColor(l.coloreTestoFascicolo)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, l.sottoTitoloFascicolo)
            if scelto {
                // Le scelte hanno già il loro margine: qui si allineano al testo della card
                contenutoScelta
                    .padding(.horizontal, -l.rientroScelte)
                    .transition(.opacity)
            } else {
                #if os(macOS)
                let senzaCliente = stato.clienteAttivo == nil
                Button(senzaCliente ? TestiFascicolo.scegliCliente : TestiFascicolo.componi) { stato.fascicoloDaAprire = true }
                    .buttonStyle(.apple)
                    .padding(.top, l.sopraPulsanteFascicolo)
                    .disabled(senzaCliente || stato.inModoCliente)
                    .help(TestiFascicolo.aiutoComponi)
                #else
                Button("Componi il fascicolo") { scegliApple(.fascicolo) }
                    .buttonStyle(.apple)
                    .padding(.top, l.sopraPulsanteFascicolo)
                    .help("Il fascicolo dell'incontro: spunta i report da consegnare e salvali in un solo PDF")
                #endif
            }
        }
        .padding(l.paddingFascicolo)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(l.superficieFascicolo, raggio: l.raggioFascicolo)
        .overlay {
            if scelto {
                forma.strokeBorder(l.bordoFascicoloScelto, lineWidth: Tema.Apple.Misura.bordo)
            }
        }
        #if os(macOS)
        .origineDettaglio(id: ComponiFascicoloMac.idDettaglio)
        #endif
    }

    #if os(macOS)
    // MARK: Il fascicolo che si compone a vista (migliorie d'uso 70)

    /// Prospetti con sopra la scheda «Il fascicolo dell'incontro» che nasce dalla card.
    var corpoProspettiConFascicolo: some View {
        let apertoSubito = stato.fascicoloDaAprire && !stato.inModoCliente && stato.clienteAttivo != nil
        return PresentatoreFascicoloMac(apertoSubito: apertoSubito) {
            corpoProspettiApple
        } scheda: { d in
            ComponiFascicoloMac(nome: { nomeBreve($0) },
                                salva: { salvaFascicolo() },
                                salvaAltrove: { salvaFascicoloAltrove() },
                                stampa: { stampaFascicolo() },
                                mostra: {
                                    d.chiudi(subito: true)
                                    stato.mostraFascicolo()
                                })
        }
    }

    /// Il PDF del fascicolo (mai nelle istantanee).
    private func pdfFascicolo(_ d: DocumentoStampabile) -> Data? {
        guard !modoIstantanea else { return nil }
        let dati = StampaCarta.pdf(d)
        if dati == nil { stato.mostraAvviso("Non sono riuscito a creare il PDF.") }
        return dati
    }

    /// «Salva il PDF»: la seconda lettura, poi nei Documenti del cliente con il titolo del fascicolo e l'avviso.
    private func salvaFascicolo() {
        guard let d = stato.documentoFascicolo(), let dati = pdfFascicolo(d) else { return }
        let n = stato.reportPresentiFascicolo.count
        let nome = stato.clienteAttivo.map { $0.nome.split(separator: " ").first.map(String.init) ?? $0.nome } ?? ""
        rileggiPoi(d, dati: dati) {
            let id = stato.archiviaProspetto(dati, documento: d)
            archiviato = id
            if id != nil { stato.mostraAvviso(TestiFascicolo.salvato(nome, report: n, pagine: d.pagine.count)) }
        }
    }

    /// «Altro › Salva in un'altra cartella…»: la seconda lettura, poi il foglio con la password del cliente.
    private func salvaFascicoloAltrove() {
        guard let d = stato.documentoFascicolo(), let dati = pdfFascicolo(d) else { return }
        rileggiPoi(d, dati: dati) {
            daSalvare = PDFDaSalvare(dati: dati, nome: StampaCarta.nomeFile(d), cliente: stato.clienteAttivo)
        }
    }

    /// «Altro › Stampa…».
    private func stampaFascicolo() {
        guard let d = stato.documentoFascicolo(), let dati = pdfFascicolo(d) else { return }
        StampaCarta.stampa(dati, formato: d.formato)
    }
    #endif

    /// In fondo: dove si impagina, e le app collegate.
    private var piedeLateraleApple: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        return VStack(alignment: .leading, spacing: l.spazioCollegati) {
            HStack(spacing: l.spazioCollegati) {
                collegamento("Posizioni") {
                    stato.portafoglio = false
                    stato.apri(.posizioni)
                }
                collegamento(AppPrisma.prodotti.titolo) { stato.apri(.prodotti) }
            }
            HStack(spacing: l.spazioCollegati) {
                collegamento(AppPrisma.documenti.titolo) {
                    stato.apri(.documenti)
                    // Migliorie d'uso 62: qui si chiede l'elenco, non il documento scelto l'ultima volta
                    stato.vistaDocumenti.lettore = nil
                }
                collegamento(StrumentoAnalisi.confronto.titolo) { stato.apriStrumentoAnalisi(.confronto) }
            }
            Text(Self.notaStato)
                .carattereApple(l.piede)
                .foregroundColor(l.colorePiede)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, l.spazioCollegati)
        }
    }

    private func collegamento(_ titolo: String, _ azione: @escaping () -> Void) -> some View {
        Button(action: azione) {
            HStack(spacing: Tema.Apple.Controlli.Pulsante.spazio) {
                Text(titolo)
                Image(systemName: "arrow.up.right")
            }
        }
        .buttonStyle(.appleSobrio)
    }

    // MARK: Barra delle azioni

    private func barraAzioniApple(_ d: DocumentoStampabile) -> some View {
        let b = Tema.Apple.Prospetti.Barra.self
        let n = d.pagine.count
        let formato = d.formato.width > d.formato.height ? "A4 orizzontale" : "A4 verticale"
        return HStack(spacing: b.spazioAzioni) {
            VStack(alignment: .leading, spacing: b.spazioTitoli) {
                // Nelle finestre strette il titolo si accorcia nel mezzo: restano l'inizio e la fine («… 2030»)
                Text(d.titolo)
                    .carattereApple(b.titolo)
                    .foregroundColor(b.coloreTitolo)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .help(d.titolo)
                Text(sottotitoloBarra(d, formato: formato, pagine: n))
                    .carattereApple(b.sottotitolo)
                    .foregroundColor(b.coloreSottotitolo)
                    .lineLimit(1)
            }
            // Il titolo tiene sempre un minimo: se non basta, sul Mac «Mostra al cliente» passa in «Altro», altrove le
            // azioni passano alle sole icone
            .frame(minWidth: b.larghezzaMinimaTitolo, alignment: .leading)
            #if os(macOS)
            // Migliorie d'uso 22: «Per il cliente | Per te», o l'etichetta grigia per chi ha una versione sola
            selettoreVersione
                .fixedSize()
            // Migliorie d'uso 23: la «i» con la scheda «A cosa serve»
            PulsanteInfoProspetto(tipo: scelta.tipo)
            #endif
            Spacer(minLength: b.spazioAzioni)
            #if os(macOS)
            // Migliorie d'uso 24: tre pulsanti sempre con il nome, «Mostra al cliente», «Salva PDF…» e «Altro ⌄»; se
            // non c'è posto «Mostra al cliente» entra in «Altro» (mai le sole icone)
            ViewThatFits(in: .horizontal) {
                treAzioniApple(d, mostraInAltro: false)
                treAzioniApple(d, mostraInAltro: true)
            }
            .layoutPriority(1)
            // «Al tavolo…» di «Altro»: i comandi del tavolo con l'iPad, come il pulsante di prima
            .popover(isPresented: $tavoloAperto, arrowEdge: .bottom) {
                PannelloAlTavolo(tavolo: stato.tavolo, contesto: contestoTavolo(d))
                    .environment(stato)
            }
            #else
            // Con le etichette se c'è posto, altrimenti le sole icone (con il suggerimento): il blu tiene la scritta
            ViewThatFits(in: .horizontal) {
                azioniApple(d, soloIcona: false)
                azioniApple(d, soloIcona: true)
            }
            .layoutPriority(1)
            #endif
        }
        .padding(b.padding)
        #if os(macOS)
        .frame(minHeight: b.altezzaVersione)
        #endif
    }

    /// Sotto il titolo: sul Mac (migliorie d'uso 22) che cosa si guarda, «Report · da mostrare e da consegnare» o
    /// «Prospetto di dettaglio · solo per te»; altrove il genere, il cliente e il formato di sempre.
    private func sottotitoloBarra(_ d: DocumentoStampabile, formato: String, pagine n: Int) -> String {
        let quante = "\(n) \(n == 1 ? "pagina" : "pagine")"
        #if os(macOS)
        if let v = scelta.versione ?? scelta.soloPer {
            return "\(TestiVersioneProspetto.sottotitolo(v)) · \(quante)"
        }
        #endif
        return "\(d.genere) · \(d.cliente) · \(formato) · \(quante)"
    }

    #if os(macOS)
    /// Il selettore a pillola delle due versioni, o «Solo per il cliente» / «Solo per te» (neutra).
    @ViewBuilder private var selettoreVersione: some View {
        let b = Tema.Apple.Prospetti.Barra.self
        if let v = scelta.versione {
            SegmentatoPillola(selezione: Binding(get: { v }, set: { cambiaVersione($0) }),
                              voci: [(VersioneProspetto.perIlCliente, TestiVersioneProspetto.perIlCliente),
                                     (VersioneProspetto.perTe, TestiVersioneProspetto.perTe)])
        } else if let solo = scelta.soloPer {
            Text(TestiVersioneProspetto.solo(solo))
                .carattereApple(b.etichettaSolo)
                .foregroundColor(b.coloreEtichettaSolo)
                .lineLimit(1)
                .padding(b.paddingEtichettaSolo)
                .background { Capsule().fill(b.fondoEtichettaSolo) }
        }
    }

    /// Cambia la versione con la pagina che esce e la nuova che entra dal lato opposto: «Per te» viene dopo (sale).
    /// La scelta si ricorda finché Prisma resta aperto.
    private func cambiaVersione(_ nuova: VersioneProspetto) {
        guard scelta.versione != nil, nuova != scelta.versione else { return }
        let attuale = scelta
        stato.versioneProspetti = nuova
        archiviato = nil
        cambiaAnteprima(direzione: nuova == .perTe ? 1 : -1) { stato.prospetto = attuale.conVersione(nuova) }
    }

    /// Il tavolo con l'iPad riceve sempre la versione per il cliente, dalla prima pagina se sullo schermo c'è quella per te.
    private func contestoTavolo(_ d: DocumentoStampabile) -> ContestoTavolo {
        if scelta.versione == .perTe {
            return ContestoTavolo(documento: stato.documentoProspettoInCache(scelta.conVersione(.perIlCliente)),
                                  pagina: 0, clienteId: stato.clienteAttivoId)
        }
        return ContestoTavolo(documento: d, pagina: indiceAnteprima(d), clienteId: stato.clienteAttivoId)
    }
    #endif

    /// La seconda lettura del PDF (parole a rischio): se è pulito si va avanti, altrimenti il foglio con gli avvisi.
    private func rileggiPoi(_ d: DocumentoStampabile, dati: Data, _ poi: @escaping () -> Void) {
        let testo = StampaCarta.testo(dati).joined(separator: "\n")
        let e = stato.secondaLetturaProspetto(testo, titolo: "\(d.genere) «\(d.titolo)»", cliente: scelta.tipo == .portafoglio ? nil : stato.clienteAttivoId)
        if e.pulito { poi() } else { letturaProspetto = LetturaInAttesa(esito: e, continua: poi) }
    }

    #if !os(macOS)
    /// iPhone e iPad: la fila delle azioni di sempre (sul Mac i tre pulsanti delle migliorie d'uso 24).
    private func azioniApple(_ d: DocumentoStampabile, soloIcona: Bool) -> some View {
        let b = Tema.Apple.Prospetti.Barra.self
        return HStack(spacing: b.spazioAzioni) {
            if let id = archiviato {
                Button {
                    stato.documentoSelezionato = id
                    stato.apri(.documenti)
                } label: {
                    HStack(spacing: Tema.Apple.Controlli.Pulsante.spazio) {
                        Text("Archiviato in Documenti")
                        Image(systemName: "arrow.up.right")
                    }
                }
                .buttonStyle(.appleSobrio)
                .fixedSize()
            }
            if scelta.spuntoVera != nil {
                Button { stato.chiediVeraDelDocumento(scelta) } label: {
                    etichettaAzione("Chiedi a Lucy", simbolo: "sparkles", soloIcona: soloIcona)
                }
                .buttonStyle(.apple)
                .fixedSize()
                .disabled(stato.veraInCorso)
                .help("Chiedi a Lucy: spiega le cifre di questo documento, per te")
            }
            // Il portafoglio parla di tutti i clienti: non si mostra a un cliente
            if scelta.tipo != .portafoglio {
                Button { presentaApple(d) } label: {
                    etichettaAzione("Presenta all'incontro", simbolo: "play.fill", soloIcona: soloIcona)
                }
                .buttonStyle(.apple)
                .fixedSize()
                .help("Presenta all'incontro: il documento a tutto schermo dalla pagina mostrata (← → per sfogliare, esc per uscire), in modalità cliente")
            }
            Button { if let dati = pdf(d) { StampaCarta.stampa(dati, formato: d.formato) } } label: {
                etichettaAzione("Stampa…", simbolo: "printer", soloIcona: soloIcona)
            }
            .buttonStyle(.apple)
            .fixedSize()
            .help("Stampa…")
            // Il portafoglio riguarda tutti i clienti: non va nei documenti di uno di loro
            if scelta.tipo != .portafoglio {
                Button {
                    if let dati = pdf(d) { rileggiPoi(d, dati: dati) { archiviato = stato.archiviaProspetto(dati, documento: d) } }
                } label: {
                    etichettaAzione("Archivia nei Documenti", simbolo: "archivebox", soloIcona: soloIcona)
                }
                .buttonStyle(.apple)
                .fixedSize()
                .help("Archivia nei Documenti del cliente")
            }
            // Il blu: l'azione principale, tiene sempre la scritta
            Button {
                // Il portafoglio è per te: il foglio della password resta, senza proposta dai dati di un cliente
                if let dati = pdf(d) {
                    rileggiPoi(d, dati: dati) {
                        daSalvare = PDFDaSalvare(dati: dati, nome: StampaCarta.nomeFile(d), cliente: scelta.tipo == .portafoglio ? nil : stato.clienteAttivo,
                                                 avvisoSalvato: nil)
                    }
                }
            } label: {
                Label("Salva PDF…", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.applePrimario)
            .fixedSize()
        }
    }

    @ViewBuilder private func etichettaAzione(_ testo: String, simbolo: String, soloIcona: Bool) -> some View {
        if soloIcona {
            Image(systemName: simbolo)
                .accessibilityLabel(Text(testo))
        } else {
            Label(testo, systemImage: simbolo)
        }
    }
    #endif

    #if os(macOS)
    // MARK: Tre pulsanti (migliorie d'uso 24)

    /// Senza cliente scelto i tre pulsanti aprono la scelta del cliente (il portafoglio è di tutti: non serve).
    private var senzaClienteAzioni: Bool {
        stato.clienteAttivo == nil && scelta.tipo != .portafoglio
    }

    /// «Mostra al cliente» si può solo per i documenti da mostrare: mai il portafoglio né quelli solo per te.
    private var mostraSpento: Bool {
        scelta.tipo == .portafoglio || scelta.soloPer == .perTe
    }

    private var aiutoMostra: String {
        if scelta.tipo == .portafoglio { return TestiAzioniProspetto.aiutoPortafoglio }
        if scelta.soloPer == .perTe { return TestiVersioneProspetto.aiutoSoloPerTe }
        return scelta.versione == .perTe ? TestiAzioniProspetto.aiutoMostraPerTe : TestiAzioniProspetto.aiutoMostra
    }

    /// Il tavolo con l'iPad: mai il portafoglio (parla di tutti i clienti) né i documenti solo per te.
    private var tavoloAmmesso: Bool {
        scelta.tipo != .portafoglio && scelta.soloPer != .perTe
    }

    /// «Mostra al cliente» (se c'è posto), «Salva PDF…» (blu, sempre con la scritta) e «Altro ⌄»; accanto, finché non si
    /// cambia documento, il collegamento sobrio «Archiviato in Documenti ↗» (decisione 24-a).
    private func treAzioniApple(_ d: DocumentoStampabile, mostraInAltro: Bool) -> some View {
        let b = Tema.Apple.Prospetti.Barra.self
        return HStack(spacing: b.spazioAzioni) {
            if let id = archiviato {
                Button {
                    stato.documentoSelezionato = id
                    stato.apri(.documenti)
                } label: {
                    HStack(spacing: Tema.Apple.Controlli.Pulsante.spazio) {
                        Text(TestiAzioniProspetto.archiviato)
                        Image(systemName: "arrow.up.right")
                    }
                }
                .buttonStyle(.appleSobrio)
                .fixedSize()
            }
            if !mostraInAltro {
                Button {
                    if senzaClienteAzioni { stato.apriSceltaCliente() } else { presentaApple(d) }
                } label: {
                    Label(TestiMostra.titolo, systemImage: TestiAzioniProspetto.simboloMostra)
                }
                .buttonStyle(.apple)
                .fixedSize()
                .disabled(mostraSpento && !senzaClienteAzioni)
                .help(aiutoMostra)
            }
            Button {
                if senzaClienteAzioni { stato.apriSceltaCliente() } else { salvaPDFApple(d) }
            } label: {
                Label(TestiAzioniProspetto.salvaPDF, systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.applePrimario)
            .fixedSize()
            menuAltroApple(d, conMostra: mostraInAltro)
        }
    }

    /// «Altro ⌄»: Stampa…, Archivia nei Documenti, Chiedi a Vera di commentarlo, e «Al tavolo…» (con «Mostra al
    /// cliente» in testa se nella riga non c'è posto). Senza cliente scelto apre la scelta del cliente.
    @ViewBuilder private func menuAltroApple(_ d: DocumentoStampabile, conMostra: Bool) -> some View {
        if senzaClienteAzioni {
            Button { stato.apriSceltaCliente() } label: { etichettaAltroApple }
                .buttonStyle(.apple)
                .fixedSize()
                .help(TestiAzioniProspetto.aiutoAltro)
        } else {
            Menu {
                if conMostra {
                    Button { presentaApple(d) } label: {
                        Label(TestiMostra.titolo, systemImage: TestiAzioniProspetto.simboloMostra)
                    }
                    .disabled(mostraSpento)
                }
                if tavoloAmmesso {
                    Button { tavoloAperto = true } label: {
                        Label(TestiAzioniProspetto.alTavolo, systemImage: "ipad.landscape")
                    }
                }
                if conMostra || tavoloAmmesso { Divider() }
                Button { if let dati = pdf(d) { StampaCarta.stampa(dati, formato: d.formato) } } label: {
                    Label(TestiAzioniProspetto.stampa, systemImage: "printer")
                }
                // Il portafoglio riguarda tutti i clienti: non va nei documenti di uno di loro
                if scelta.tipo != .portafoglio {
                    Button {
                        if let dati = pdf(d) { rileggiPoi(d, dati: dati) { archiviato = stato.archiviaProspetto(dati, documento: d) } }
                    } label: {
                        Label(TestiAzioniProspetto.archivia, systemImage: "archivebox")
                    }
                }
                if scelta.spuntoVera != nil {
                    Button { stato.chiediVeraDelDocumento(scelta) } label: {
                        Label(TestiAzioniProspetto.chiediVera, systemImage: "sparkles")
                    }
                    .disabled(stato.veraInCorso)
                }
            } label: {
                etichettaAltroApple
            }
            .menuStyle(.button)
            .menuIndicator(.hidden)
            .buttonStyle(.apple)
            .fixedSize()
            .help(TestiAzioniProspetto.aiutoAltro)
        }
    }

    private var etichettaAltroApple: some View {
        let b = Tema.Apple.Prospetti.Barra.self
        return HStack(spacing: b.spazioFrecciaAltro) {
            Text(TestiAzioniProspetto.altro)
            Image(systemName: "chevron.down")
                .carattereApple(b.frecciaAltro)
                .opacity(b.opacitaFrecciaAltro)
        }
    }

    /// «Salva PDF…»: la seconda lettura, poi il foglio della password; dopo il salvataggio l'avviso con la versione.
    private func salvaPDFApple(_ d: DocumentoStampabile) {
        guard let dati = pdf(d) else { return }
        rileggiPoi(d, dati: dati) {
            let avviso: String? = TestiVersioneProspetto.pdfSalvato(d.titolo, versione: scelta.versione)
            daSalvare = PDFDaSalvare(dati: dati, nome: StampaCarta.nomeFile(d),
                                     cliente: scelta.tipo == .portafoglio ? nil : stato.clienteAttivo,
                                     avvisoSalvato: avviso)
        }
    }
    #endif

    /// La presentazione parte dalla pagina mostrata nell'anteprima.
    private func presentaApple(_ d: DocumentoStampabile) {
        // Presentare il prospetto del riesame salva la fotografia di oggi (memoria del riesame)
        if case .riesame = scelta { stato.fotografaRiesame(stato.clienteAttivoId, origine: .prospetto) }
        #if os(macOS)
        // Migliorie d'uso 22: al cliente si mostra sempre la versione per lui, dalla prima pagina (la pagina girata
        // è della versione per te, che ha altre pagine)
        if scelta.versione == .perTe {
            guard let perIlCliente = stato.documentoProspetto(scelta.conVersione(.perIlCliente)) else { return }
            stato.mostraAvviso(TestiVersioneProspetto.avvisoMostra)
            stato.mostraProspetto(perIlCliente, daPagina: 0)
            return
        }
        stato.mostraProspetto(d, daPagina: indiceAnteprima(d))
        #else
        stato.presenta(d, daPagina: indiceAnteprima(d))
        #endif
    }

    // MARK: Anteprima

    /// La pagina mostrata: quella girata per questa scelta e questo cliente, altrimenti la prima.
    func indiceAnteprima(_ d: DocumentoStampabile) -> Int {
        let n = d.pagine.count
        guard n > 0 else { return 0 }
        let p = paginaAnteprima
        let i = (p.scelta == scelta && p.cliente == cliente) ? p.indice : 0
        return min(max(i, 0), n - 1)
    }

    /// Va alla pagina data (se c'è), con la pagina che cambia nel verso giusto.
    func vaiAPagina(_ nuova: Int, di d: DocumentoStampabile) {
        let attuale = indiceAnteprima(d)
        guard nuova >= 0, nuova < d.pagine.count, nuova != attuale else { return }
        let pagina = PaginaAnteprimaProspetto(scelta: scelta, cliente: cliente, indice: nuova)
        cambiaAnteprima(direzione: nuova > attuale ? 1 : -1) { paginaAnteprima = pagina }
    }

    private func anteprimaApple(_ documento: DocumentoStampabile?, generazione: Int) -> some View {
        let a = Tema.Apple.Prospetti.Anteprima.self
        let forma = RoundedRectangle(cornerRadius: a.raggio, style: .continuous)
        return GeometryReader { geo in
            ZStack(alignment: .top) {
                if let documento, !documento.pagine.isEmpty {
                    paginaAnteprimaApple(documento, generazione: generazione, misura: geo.size)
                } else {
                    vuoto
                        .frame(maxWidth: a.vuotoLarghezza)
                        .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .background { forma.fill(a.fondo) }
        // La pagina che entra o esce non va fuori dal fondo
        .clipShape(forma)
    }

    private func paginaAnteprimaApple(_ d: DocumentoStampabile, generazione: Int, misura: CGSize) -> some View {
        let a = Tema.Apple.Prospetti.Anteprima.self
        let indice = indiceAnteprima(d)
        let largo = max(1, misura.width - a.margineLati * 2)
        let alto = max(1, misura.height - a.margineAlto - a.margineBasso)
        let adatta = min(largo / d.formato.width, alto / d.formato.height)
        let scala = min(a.scalaMassima, max(a.scalaMinima, adatta))
        let id = IdAnteprimaProspetto(scelta: scelta, cliente: cliente, indice: indice)
        return ZStack(alignment: .top) {
            #if os(macOS)
            // Lo scorrimento (rotella o trackpad) sull'anteprima gira la pagina; non riceve clic
            if !modoIstantanea {
                AreaScorrimentoAnteprima(
                    attiva: { [stato] in stato.appAttiva == .presentazioni && stato.presentazione == nil && !stato.bloccato },
                    scorri: { passo in vaiAPagina(indice + passo, di: d) }
                )
            }
            #endif
            // La scala sta fuori dalla pagina `Equatable`: ingrandendo o affiancando la finestra cambia solo la
            // trasformazione, non si rifà il body della pagina a ogni fotogramma
            FoglioAnteprimaApple(documento: d, indice: indice, generazione: generazione)
                .equatable()
                .scaleEffect(scala, anchor: .top)
                .frame(width: d.formato.width * scala, height: d.formato.height * scala, alignment: .top)
                .superficieApple(a.carta)
                .padding(.top, a.margineAlto)
                .modifier(SfogliaAnteprimaApple { passo in vaiAPagina(indice + passo, di: d) })
                .id(id)
                .transition(AnyTransition.cambioPagina(direzione: direzioneAnteprima, calmo: calmo))
            comandiPagineApple(indice, documento: d)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, a.comandiFondo)
        }
        .frame(width: misura.width, height: misura.height, alignment: .top)
    }

    /// Sotto la carta: le frecce da 32 e «2 di 5».
    private func comandiPagineApple(_ indice: Int, documento d: DocumentoStampabile) -> some View {
        let a = Tema.Apple.Prospetti.Anteprima.self
        let n = d.pagine.count
        return HStack(spacing: a.spazioComandi) {
            if n > 1 {
                FrecciaAnteprimaApple(simbolo: "chevron.left", aiuto: "Pagina precedente") { vaiAPagina(indice - 1, di: d) }
                    .disabled(indice == 0)
            }
            Text(n == 1 ? "1 pagina" : "\(indice + 1) di \(n)")
                .carattereApple(a.contatore)
                .foregroundColor(a.coloreContatore)
                .frame(minWidth: a.larghezzaContatore)
            if n > 1 {
                FrecciaAnteprimaApple(simbolo: "chevron.right", aiuto: "Pagina seguente") { vaiAPagina(indice + 1, di: d) }
                    .disabled(indice >= n - 1)
            }
        }
    }
}

// MARK: - Componenti

/// Il cliente dei prospetti: avatar 30, nome 14 bold e la tendina con tutti i clienti.
private struct RigaClienteProspettiApple: View {
    @Environment(StatoShell.self) var stato
    @State private var aperto = false

    var body: some View {
        let _ = ContaCorpi.segna()
        let l = Tema.Apple.Prospetti.Laterale.self
        let cliente = stato.clienteAttivo
        #if os(macOS)
        // Migliorie d'uso 2: il cliente si sceglie nella barra in alto; qui resta chi è, senza tendina
        return HStack(spacing: l.spazioCliente) {
            if let c = cliente {
                AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: l.avatar)
            }
            Text(cliente?.nome ?? TestiSceltaCliente.tuttiIClienti)
                .carattereApple(l.nomeCliente)
                .foregroundColor(l.coloreNome)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        #else
        return Button { aperto = true } label: {
            HStack(spacing: l.spazioCliente) {
                if let c = cliente {
                    AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: l.avatar)
                }
                Text(cliente?.nome ?? "Nessun cliente")
                    .carattereApple(l.nomeCliente)
                    .foregroundColor(l.coloreNome)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .carattereApple(l.frecciaCliente)
                    .foregroundColor(l.coloreFreccia)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(StileSemplice())
        .popover(isPresented: $aperto, arrowEdge: .trailing) { ElencoClienti(aperto: $aperto) }
        .help("Scegli il cliente: prospetti e report valgono per lui")
        #endif
    }
}

/// Una voce della barra laterale (`.rub`): titolo 14 bold e sottotitolo 12 `inchiostro2` («· nuovo» in accento);
/// sotto il puntatore `chip`, scelta `rgba(0,122,255,.13)`, il fondo cambia in 0,25 s.
private struct VoceProspettoApple: View {
    let titolo: String
    let sottotitolo: String
    let nuovo: Bool
    let scelta: Bool
    /// Migliorie d'uso 23 (sul Mac): la riga sotto il nome su più righe e le etichette delle versioni.
    var righeSottotitolo = 1
    var conEtichette = false
    var versioni: [VersioneProspetto] = []
    var incontroOggi = false
    let azione: () -> Void

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @State private var sopra = false

    var body: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        let forma = RoundedRectangle(cornerRadius: l.raggioVoce, style: .continuous)
        return Button(action: azione) {
            VStack(alignment: .leading, spacing: l.spazioTitoli) {
                Text(titolo)
                    .carattereApple(l.titoloVoce)
                    .foregroundColor(l.coloreTitoloVoce)
                    .lineLimit(1)
                testoSotto
                    .carattereApple(l.sottotitoloVoce)
                    .lineLimit(righeSottotitolo)
                    .fixedSize(horizontal: false, vertical: righeSottotitolo > 1)
                #if os(macOS)
                if conEtichette {
                    EtichetteVoceProspetto(versioni: versioni, perIncontroOggi: incontroOggi)
                }
                #endif
            }
            .padding(l.paddingVoce)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { fondo }
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        #if os(macOS)
        .onHover { dentro in sopra = dentro && !istantanea }
        #endif
        .animation(animazione, value: scelta)
        .animation(animazione, value: sopra)
        .accessibilityAddTraits(scelta ? AccessibilityTraits.isSelected : AccessibilityTraits())
    }

    private var testoSotto: Text {
        let l = Tema.Apple.Prospetti.Laterale.self
        let base = Text(sottotitolo).foregroundColor(l.coloreSottotitoloVoce)
        guard nuovo else { return base }
        return base + Text(" · ").foregroundColor(l.coloreSottotitoloVoce) + Text("nuovo").foregroundColor(l.coloreNuovo)
    }

    @ViewBuilder private var fondo: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        let forma = RoundedRectangle(cornerRadius: l.raggioVoce, style: .continuous)
        if scelta {
            forma.fill(l.fondoScelta)
        } else if sopra {
            forma.fill(l.fondoSopra)
        }
    }

    private var animazione: Animation? {
        Tema.Apple.Moto.animazione(Tema.Apple.Prospetti.Laterale.animazioneFondo, calmo: calmo, istantanea: istantanea)
    }
}

/// La pagina dell'anteprima a grandezza vera: solo quella mostrata, non tutto il documento. La scala e la carta
/// bianca con la sua ombra (§1.2) le mette `paginaAnteprimaApple`, fuori da qui. Le pagine sono `AnyView`, che
/// SwiftUI non sa confrontare: si rifà solo con un'impaginazione nuova o un'altra pagina, non a ogni cambiamento
/// dello stato né a ogni fotogramma di un ridimensionamento della finestra.
private struct FoglioAnteprimaApple: View, Equatable {
    let documento: DocumentoStampabile
    let indice: Int
    /// Il numero dell'impaginazione (StatoShell.generazioneDocumento): lo stesso numero è lo stesso documento.
    let generazione: Int

    nonisolated static func == (a: FoglioAnteprimaApple, b: FoglioAnteprimaApple) -> Bool {
        a.generazione == b.generazione && a.indice == b.indice
    }

    var body: some View {
        documento.pagine[min(max(indice, 0), documento.pagine.count - 1)]
            // La carta resta come sulla carta: «Dimensione del testo» non la ingrandisce
            .prismaScalaTesto(1)
            .frame(width: documento.formato.width, height: documento.formato.height)
    }
}

/// La freccia tonda sotto la carta (`.arr`: `cardPiena` con il filo `separatore`).
private struct FrecciaAnteprimaApple: View {
    let simbolo: String
    let aiuto: String
    let azione: () -> Void
    @Environment(\.isEnabled) private var abilitata

    var body: some View {
        let a = Tema.Apple.Prospetti.Anteprima.self
        Button(action: azione) {
            Image(systemName: simbolo)
                .carattereApple(a.carattereFreccia)
                .foregroundColor(a.coloreFreccia)
                .frame(width: a.freccia, height: a.freccia)
                .background { Circle().fill(a.fondoFreccia) }
                .overlay { Circle().strokeBorder(a.bordoFreccia, lineWidth: Tema.Apple.Misura.bordo) }
                .contentShape(Circle())
        }
        .buttonStyle(StileSemplice())
        .opacity(abilitata ? 1 : a.opacitaFrecciaSpenta)
        .help(aiuto)
        .accessibilityLabel(Text(aiuto))
    }
}

// MARK: - Sfogliare sull'iPad

/// Sull'iPad la carta si sfoglia col dito: un colpo verso sinistra (o verso l'alto) porta alla pagina seguente,
/// verso destra (o verso il basso) alla precedente. Sul Mac non fa niente: lì gira la pagina lo scorrimento.
private struct SfogliaAnteprimaApple: ViewModifier {
    let scorri: (Int) -> Void

    func body(content: Content) -> some View {
        #if os(iOS)
        content.gesture(
            DragGesture(minimumDistance: Tema.Apple.Prospetti.Anteprima.distanzaSfoglia)
                .onEnded { g in
                    let dx = g.translation.width
                    let dy = g.translation.height
                    let soglia = Tema.Apple.Prospetti.Anteprima.sogliaSfoglia
                    let lungo = abs(dx) >= abs(dy) ? dx : dy
                    guard abs(lungo) >= soglia else { return }
                    scorri(lungo < 0 ? 1 : -1)
                }
        )
        #else
        content
        #endif
    }
}

#if os(macOS)

// MARK: - Scorrimento sull'anteprima

/// Lo scorrimento con la rotella o con il trackpad sopra l'anteprima gira la pagina (giù = la seguente).
/// Un `DragGesture` non risponde allo scorrimento a due dita: serve un monitor locale degli eventi `.scrollWheel`,
/// che prende solo quelli dentro l'anteprima, nella finestra di Prisma, con Prospetti in primo piano. La vista non
/// riceve clic (`hitTest` nil): pulsanti e carta sotto restano come sono.
private struct AreaScorrimentoAnteprima: NSViewRepresentable {
    let attiva: () -> Bool
    let scorri: (Int) -> Void

    func makeNSView(context: Context) -> VistaScorrimentoAnteprima {
        let vista = VistaScorrimentoAnteprima()
        vista.attiva = attiva
        vista.scorri = scorri
        return vista
    }

    func updateNSView(_ vista: VistaScorrimentoAnteprima, context: Context) {
        vista.attiva = attiva
        vista.scorri = scorri
    }

    static func dismantleNSView(_ vista: VistaScorrimentoAnteprima, coordinator: ()) {
        vista.fermaMonitor()
    }
}

private final class VistaScorrimentoAnteprima: NSView {
    var attiva: () -> Bool = { false }
    var scorri: (Int) -> Void = { _ in }
    private var monitor: Any?
    /// Gli spostamenti del gesto del trackpad in corso (negativo = verso la pagina seguente).
    private var accumulo: CGFloat = 0
    /// Un gesto gira una pagina sola: il resto del gesto e la sua inerzia passano a vuoto.
    private var giratoNelGesto = false
    /// L'ultimo giro con la rotella del mouse (o con un trackpad senza fasi).
    private var ultimoGiro: TimeInterval = 0

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window == nil { fermaMonitor() } else { avviaMonitor() }
    }

    deinit {
        if let m = monitor { NSEvent.removeMonitor(m) }
    }

    func fermaMonitor() {
        if let m = monitor { NSEvent.removeMonitor(m) }
        monitor = nil
    }

    private func avviaMonitor() {
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] e in
            guard let self else { return e }
            return self.gestisci(e) ? nil : e
        }
    }

    /// true se l'evento è dell'anteprima (e allora non va oltre).
    private func gestisci(_ e: NSEvent) -> Bool {
        guard let finestra = window, e.window === finestra, !isHiddenOrHasHiddenAncestor, attiva() else { return false }
        let punto = convert(e.locationInWindow, from: nil)
        guard bounds.contains(punto) else { return false }
        let a = Tema.Apple.Prospetti.Anteprima.self
        // L'inerzia dopo il rilascio non gira altre pagine
        if !e.momentumPhase.isEmpty { return true }
        let dy = e.scrollingDeltaY
        if e.hasPreciseScrollingDeltas && !e.phase.isEmpty {
            if e.phase.contains(.began) {
                accumulo = 0
                giratoNelGesto = false
            }
            if !giratoNelGesto {
                accumulo += dy
                if abs(accumulo) >= a.sogliaScorrimento {
                    giratoNelGesto = true
                    scorri(accumulo < 0 ? 1 : -1)
                }
            }
            if e.phase.contains(.ended) || e.phase.contains(.cancelled) {
                accumulo = 0
                giratoNelGesto = false
            }
            return true
        }
        // Rotella del mouse: un giro per pagina, poi una breve pausa
        guard dy != 0 else { return false }
        if e.hasPreciseScrollingDeltas {
            accumulo += dy
            guard abs(accumulo) >= a.sogliaScorrimento else { return true }
        }
        let passo = (e.hasPreciseScrollingDeltas ? accumulo : dy) < 0 ? 1 : -1
        accumulo = 0
        guard e.timestamp - ultimoGiro >= a.pausaRotella else { return true }
        ultimoGiro = e.timestamp
        scorri(passo)
        return true
    }
}

#endif

#if os(macOS)
/// I testi dei tre pulsanti dei Prospetti (migliorie d'uso 24, template righe 3817-3868).
enum TestiAzioniProspetto {
    static let simboloMostra = "person.crop.rectangle"
    static let salvaPDF = "Salva PDF…"
    static let altro = "Altro"
    static let stampa = "Stampa…"
    static let archivia = "Archivia nei Documenti"
    static let chiediVera = "Chiedi a Lucy di commentarlo"
    static let alTavolo = "Al tavolo…"
    static let archiviato = "Archiviato in Documenti"
    static let aiutoAltro = "Stampa, archivia nei Documenti, chiedi a Lucy, il tavolo con l'iPad"
    static let aiutoPortafoglio = "Il portafoglio parla di tutti i clienti: non si mostra a un cliente"
    static let aiutoMostra = "Mostra al cliente: il documento a tutto schermo dalla pagina mostrata (← → per sfogliare, esc per uscire), nella vista pulita"
    static let aiutoMostraPerTe = "Mostra al cliente: la versione per il cliente a tutto schermo, dalla prima pagina, nella vista pulita"
}
#endif
