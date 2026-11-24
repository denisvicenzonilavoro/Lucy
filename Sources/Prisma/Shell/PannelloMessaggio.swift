import SwiftUI

// Il pannello del messaggio di Messaggi (Design/template-novita-specifica.md §5.1.4, §5.1.6, §5.2.2), lo stesso sul
// Mac, sull'iPad e sull'iPhone:
//
//   ◉  A: Giulia Rossi · giulia.rossi@example.com              [Perché adesso: Incontro di ieri alle 17:30]
//      Il riepilogo dell'incontro di ieri
//   [Cordiale · Formale · Breve] [Mail · Messaggi]                       ◎ Vera scrive con i dati del dossier
//   (sul Mac: Tono [Cordiale · Formale · Breve]  Invia con [Mail · Messaggi]      Vera ha usato 5 dati del dossier ›)
//   Oggetto: Il riepilogo del nostro incontro
//   ──────────────────────────────────────────────────────────────────────────────────────────────
//   Ciao Giulia, …   (parola per parola mentre Vera scrive, poi modificabile; con Messaggi nella nuvoletta blu)
//   [Decisioni · …] [Prossimo incontro · 3 dicembre 2026]
//   Le cifre vengono da Prisma · Scritto da Vera con qwen3.5:4b          (queste due righe non sul Mac)
//   [Apri in Mail] [Salva nel dossier] [↻ Riscrivi]                                  Lo controlli e lo spedisci tu
//
// - Il testo lo scrive Qwen sul Mac (SessioneMessaggi, MessaggiVera): mentre arriva compare parola per parola
//   (TestoProgressivo, 22 ms a parola) e, finito, diventa un campo di testo da correggere. Se Qwen non è pronto, o se
//   il suo testo cambia una cifra, resta il testo di Prisma con la riga che lo spiega (sfera ferma).
// - Senza email o telefono nel dossier la testata lo dice e il pulsante principale porta all'anagrafica.
// - Un messaggio che propone qualcosa a un cliente senza consenso commerciale valido: pillola arancio e conferma.
// - Prisma non spedisce mai: «Apri in Mail» apre Mail già compilato, la spedizione la fa il consulente.
// - `compatto` (iPhone, iPad in verticale): controlli e pulsanti uno sotto l'altro; `incorniciato` (Mac e iPad): la
//   barra dei pulsanti resta in fondo e scorre solo il testo.
// - «Riduci movimento»: niente cascata né comparsa parola per parola (tutto subito); istantanee: stato finale, il
//   testo come testo (senza il campo), nessun puntino.
// - Il testo in arrivo da Vera e le correzioni li leggono solo il testo (TestoMessaggioSessione, CampoTestoMessaggio) e
//   gli avvisi dello stile (AvvisiStileSessione): un pezzo del flusso o un tasto rifanno loro, non tutto il pannello.
// - Migliorie d'uso 26 (solo Mac): i selettori hanno un nome, «Tono» e «Invia con»; a destra «Vera ha usato N dati del
//   dossier ›» apre la scheda «Da dove vengono le cifre» (FoglioDatiMessaggio). Sotto il testo non ci sono più le
//   etichette delle cifre né la riga dell'autore, e nella fila non c'è più la sfera con «Vera scrive con i dati del
//   dossier»: Vera che scrive si vede dai puntini e dalle parole, il testo di Prisma dall'avviso che resta. iPhone e
//   iPad tengono la fila e le cifre di prima.
// - Migliorie d'uso 25 (solo Mac, pannello incorniciato e non compatto): la barra ha tre stati. Dopo un'apertura riuscita
//   in Mail o in Messaggi chiede «Aperto in Mail. L’hai spedito?» con «Sì, spedito» e «Non ancora»; segnato come
//   spedito mostra la pillola verde «Spedito oggi alle … con Mail», «È nel dossier di …» e «Non è partito», e il testo
//   si rilegge com'era (niente nuova scrittura, niente «↻ Riscrivi», tono e canale fermi). Il segno lo mette solo il
//   consulente: Prisma non legge Mail né Messaggi. I traguardi (PannelloTraguardo) non hanno questa barra.
// Valori in DesignSystem/Apple/Tema.Apple+Messaggi.swift.

/// Lo stato della barra dei pulsanti (migliorie d'uso 25, solo Mac): normale, la domanda «L'hai spedito?», spedito.
enum StatoBarraMessaggio: Hashable {
    case normale, daConfermare, spedito
}

@MainActor
struct PannelloMessaggio: View {
    @Environment(StatoShell.self) var stato
    /// La sessione (`@Observable`): il pannello segue solo ciò che legge (tono, canale, testo pronto, chi scrive).
    let sessione: SessioneMessaggi
    let occasione: OccasioneMessaggio
    let cliente: Cliente
    @Binding var tono: TonoMessaggio
    @Binding var canale: CanaleMessaggio
    var compatto = false
    var incorniciato = true
    /// La cascata: base (0,14 all'apertura, 0 a un cambio di occasione) e il primo indice (dopo le voci dell'elenco).
    var base: Double = Tema.Apple.Messaggi.Moto.baseApertura
    var primoIndice = 0
    /// Solo nelle istantanee: il testo già pronto (nessuna scrittura parte).
    var scrittoIstantanea: TestoScrittoMessaggio? = nil
    /// Solo nelle istantanee del Mac (migliorie d'uso 26): la scheda «Da dove vengono le cifre» già aperta.
    var datiIstantanea = false
    /// Migliorie d'uso 25 (Mac): dopo «Sì, spedito» l'app passa al prossimo messaggio da mandare.
    var dopoSpedito: (() -> Void)? = nil

    @Environment(\.prismaScatto) private var scatto
    @Environment(\.prismaCalmo) private var calmo
    @State private var chiediConsenso = false
    /// «La seconda lettura» (fase 3 di Vera): gli avvisi prima di aprire Mail o Messaggi; decide il consulente.
    @State private var lettura: EsitoSecondaLettura?
    /// Migliorie d'uso 26 (Mac): la scheda «Da dove vengono le cifre».
    @State private var datiAperti = false

    private typealias P = Tema.Apple.Messaggi.Pannello
    private typealias T = Tema.Apple.Messaggi.Testo

    private var chiave: ChiaveTestoMessaggio {
        ChiaveTestoMessaggio(occasione: occasione.id, tono: tono, canale: canale)
    }

    /// «Scrive come te» (fase 4 di Vera, funzione 15): le regole dello stile che il testo pronto non rispetta.
    @ViewBuilder
    private var avvisiStile: some View {
        if pronto != nil && spedito == nil {
            AvvisiStileSessione(sessione: sessione, chiave: chiave, scrittoIstantanea: scrittoIstantanea,
                                clienteId: cliente.id)
                .padding(.top, Tema.Apple.Messaggi.Barra.sopra)
        }
    }

    /// Il testo pronto com'è arrivato, senza le correzioni: basta al pannello (chi ha scritto, l'oggetto, l'avviso, i
    /// pulsanti), che così non si rifà a ogni tasto nel messaggio. Il testo corretto lo leggono il testo del messaggio,
    /// gli avvisi dello stile e le azioni (`corretto`).
    private var pronto: TestoScrittoMessaggio? {
        scrittoIstantanea ?? sessione.arrivato(chiave)
    }

    /// Il testo pronto con le correzioni, come si apre e si salva (letto solo nelle azioni, fuori dal body).
    private var corretto: TestoScrittoMessaggio? {
        scrittoIstantanea ?? sessione.scritto(chiave)
    }

    private var scrive: Bool {
        scrittoIstantanea == nil && sessione.inScrittura == chiave
    }

    /// Migliorie d'uso 25: lo stato della barra. Solo sul Mac, nel pannello incorniciato e non compatto, per un messaggio
    /// aperto oggi in Mail o in Messaggi (la copertura dell'occasione): spedito se il consulente l'ha segnato, altrimenti
    /// la domanda, finché non la chiude con «Non ancora» in questa sessione. iPad e iPhone: sempre normale.
    private var statoBarra: StatoBarraMessaggio {
        #if os(macOS)
        guard incorniciato, !compatto, occasione.tipo != .traguardo, let c = occasione.copertura, c.aperto else { return .normale }
        if c.speditoIl != nil { return .spedito }
        return sessione.domandeChiuse.contains(occasione.id) ? .normale : .daConfermare
        #else
        return .normale
        #endif
    }

    /// Il messaggio spedito da rileggere (nil se la barra non è nello stato «spedito»).
    private var spedito: CoperturaMessaggio? {
        statoBarra == .spedito ? occasione.copertura : nil
    }

    /// Il canale mostrato: quello del messaggio spedito, altrimenti quello scelto nel segmentato.
    private var canaleMostrato: CanaleMessaggio { spedito?.canale ?? canale }

    var body: some View {
        let _ = ContaCorpi.segna()
        let k = chiave
        let contenuto = VStack(alignment: .leading, spacing: 0) {
            testata
                .entrataCascata(primoIndice, base: base)
            controlli
                .disabled(spedito != nil)
                .opacity(spedito != nil ? Tema.Apple.Messaggi.Barra.opacitaControlliSpento : 1)
                .padding(.top, P.controlliSopra)
                .padding(.bottom, P.controlliSotto)
                .entrataCascata(primoIndice + 1, base: base)
            if canaleMostrato == .mail {
                rigaOggetto
                    .entrataCascata(primoIndice + 2, base: base)
            }
            if incorniciato {
                ScrollView(.vertical, showsIndicators: true) {
                    corpo
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .entrataCascata(primoIndice + 3, base: base)
                avvisiStile
                barra
                    .padding(.top, Tema.Apple.Messaggi.Barra.sopra)
            } else {
                corpo
                    .entrataCascata(primoIndice + 3, base: base)
                avvisiStile
                barra
                    .padding(.top, Tema.Apple.Messaggi.Barra.sopra)
            }
        }
        .padding(compatto ? P.paddingCompatto : P.padding)
        .frame(maxWidth: .infinity, maxHeight: incorniciato ? .infinity : nil, alignment: .topLeading)
        .superficieApple(P.superficie, raggio: P.raggio)
        return conDatiUsati(contenuto)
            .task(id: k) {
                // Nelle istantanee il testo è già pronto: nessuna scrittura, nessuna verifica di Qwen; un messaggio
                // spedito si rilegge, non si riscrive (migliorie d'uso 25)
                guard scrittoIstantanea == nil, !scatto, spedito == nil else { return }
                sessione.prepara(occasione, stato: stato)
            }
            .sheet(item: $lettura) { e in
                FoglioSecondaLettura(esito: e, avanti: "Apri lo stesso", correggi: { e in
                    if let s = corretto { sessione.correggi(chiave, e.corretto(s.testo)) }
                }, continua: { apri(riletto: true) })
            }
            .alert(TestiMessaggi.confermaConsensoTitolo, isPresented: $chiediConsenso) {
                Button(TestiMessaggi.confermaConsensoApri) { apri() }
                Button(TestiMessaggi.confermaConsensoNo, role: .cancel) {}
            } message: {
                Text(TestiMessaggi.confermaConsenso(cliente.nome))
            }
    }

    // MARK: La scheda dei dati usati (migliorie d'uso 26, Mac)

    /// Sul Mac: la scheda «Da dove vengono le cifre» come foglio; nelle istantanee disegnata sopra il pannello, sul velo
    /// (i fogli di sistema non entrano nell'immagine). iPhone e iPad: il pannello com'è.
    @ViewBuilder private func conDatiUsati<V: View>(_ v: V) -> some View {
        #if os(macOS)
        v
            .sheet(isPresented: $datiAperti) {
                foglioDati(chiudi: nil)
            }
            .overlay {
                if datiIstantanea && !occasione.cifre.isEmpty {
                    ZStack {
                        Tema.Apple.Messaggi.FoglioDati.velo
                        foglioDati(chiudi: {})
                            .superficieApple(Tema.Apple.Messaggi.FoglioDati.superficie,
                                             raggio: Tema.Apple.Messaggi.FoglioDati.raggio)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: P.raggio, style: .continuous))
                }
            }
        #else
        v
        #endif
    }

    #if os(macOS)
    private func foglioDati(chiudi: (() -> Void)?) -> some View {
        FoglioDatiMessaggio(titolo: occasione.titolo, nomeCliente: cliente.nome, cifre: occasione.cifre,
                            autore: pronto.map { TestiMessaggi.scrittoDa($0) }, chiudi: chiudi)
    }
    #endif

    // MARK: Testata

    private var testata: some View {
        let d = TestiMessaggi.destinatario(cliente, canale: canaleMostrato)
        let titoli = VStack(alignment: .leading, spacing: P.spazioTitolo) {
            Text(d.testo)
                .carattereApple(P.destinatario)
                .foregroundColor(d.manca ? P.coloreRecapitoMancante : P.coloreDestinatario)
                .lineLimit(compatto ? 2 : 1)
                .truncationMode(.middle)
            Text(occasione.titolo)
                .carattereApple(P.titolo)
                .foregroundColor(P.coloreTitolo)
                .fixedSize(horizontal: false, vertical: true)
        }
        return Group {
            if compatto {
                VStack(alignment: .leading, spacing: P.spazioTestata) {
                    HStack(alignment: .center, spacing: P.spazioTestata) {
                        avatar
                        titoli
                    }
                    pillole
                }
            } else {
                HStack(alignment: .center, spacing: P.spazioTestata) {
                    avatar
                    titoli
                    Spacer(minLength: P.spazioTestata)
                    pillole
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var avatar: some View {
        AvatarCliente(iniziali: cliente.iniziali, tinta: cliente.tinta.colori, lato: P.avatar)
            .accessibilityHidden(true)
    }

    private var pillole: some View {
        let senzaConsenso = occasione.commerciale && !stato.consensoCommercialeValido(cliente)
        return Group {
            if compatto {
                VStack(alignment: .leading, spacing: P.spazioPillole) { contenutoPillole(senzaConsenso) }
            } else {
                VStack(alignment: .trailing, spacing: P.spazioPillole) { contenutoPillole(senzaConsenso) }
            }
        }
    }

    @ViewBuilder private func contenutoPillole(_ senzaConsenso: Bool) -> some View {
        pillola(TestiMessaggi.perche(occasione), fondo: P.fondoPerche, testo: P.testoPerche)
        if senzaConsenso {
            pillola(TestiMessaggi.senzaConsenso, fondo: P.fondoConsenso, testo: P.testoConsenso)
        }
        if let c = occasione.canale {
            EtichettaCanaleApple(canale: c, compatta: compatto)
        }
    }

    private func pillola(_ testo: String, fondo: Color, testo colore: Color) -> some View {
        Text(testo)
            .carattereApple(P.pillola)
            .foregroundColor(colore)
            .lineLimit(1)
            .padding(P.paddingPillola)
            .background { Capsule(style: .continuous).fill(fondo) }
            .fixedSize()
    }

    // MARK: Controlli

    private var segmentatoTono: some View {
        SegmentatoPillola(selezione: $tono, valori: TonoMessaggio.allCases, titolo: { $0.nome }, larghezzaPiena: compatto)
    }

    private var segmentatoCanale: some View {
        SegmentatoPillola(selezione: $canale, valori: CanaleMessaggio.allCases, titolo: { $0.nome }, larghezzaPiena: compatto)
    }

    @ViewBuilder private var controlli: some View {
        #if os(macOS)
        controlliMac
        #else
        controlliComuni
        #endif
    }

    #if os(macOS)
    /// Migliorie d'uso 26: «Tono» e «Invia con» davanti ai segmentati, a destra i dati usati (se ce ne sono). Se la
    /// fila non sta, le etichette restano e il collegamento va a capo sotto.
    @ViewBuilder private var controlliMac: some View {
        if compatto {
            VStack(alignment: .leading, spacing: P.spazioControlli) {
                gruppoControllo(TestiMessaggi.tono) { segmentatoTono }
                gruppoControllo(TestiMessaggi.inviaCon) { segmentatoCanale }
                pulsanteDatiUsati
            }
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 0) {
                    gruppiControlli
                    Spacer(minLength: P.spazioControlli)
                    pulsanteDatiUsati
                }
                VStack(alignment: .leading, spacing: P.spazioControlli) {
                    gruppiControlli
                    pulsanteDatiUsati
                }
            }
        }
    }

    private var gruppiControlli: some View {
        HStack(alignment: .center, spacing: P.fraGruppiControlli) {
            gruppoControllo(TestiMessaggi.tono) { segmentatoTono.fixedSize() }
            gruppoControllo(TestiMessaggi.inviaCon) { segmentatoCanale.fixedSize() }
        }
        .fixedSize()
    }

    /// L'etichetta `.k` davanti al segmentato; il segmentato prende l'etichetta per VoiceOver.
    private func gruppoControllo<C: View>(_ etichetta: String, @ViewBuilder _ controllo: () -> C) -> some View {
        HStack(alignment: .center, spacing: P.spazioEtichetta) {
            Text(etichetta)
                .carattereApple(P.etichettaControllo)
                .foregroundColor(P.coloreEtichettaControllo)
                .lineLimit(1)
                .fixedSize()
                .accessibilityHidden(true)
            controllo()
                .accessibilityLabel(Text(etichetta))
        }
    }

    /// «Vera ha usato N dati del dossier ›»: apre la scheda «Da dove vengono le cifre». Nessun collegamento se il
    /// messaggio non usa cifre (un augurio).
    @ViewBuilder private var pulsanteDatiUsati: some View {
        if !occasione.cifre.isEmpty {
            Button { datiAperti = true } label: {
                Text(TestiMessaggi.datiUsati(occasione.cifre.count))
                    .carattereApple(P.datiUsati)
                    .foregroundColor(P.coloreDatiUsati)
                    .lineLimit(1)
                    .fixedSize()
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(TestiMessaggi.daDoveCifre)
        }
    }
    #endif

    @ViewBuilder private var controlliComuni: some View {
        if compatto {
            VStack(alignment: .leading, spacing: P.spazioControlli) {
                segmentatoTono
                segmentatoCanale
                notaVera
            }
        } else {
            HStack(alignment: .center, spacing: P.spazioControlli) {
                segmentatoTono.fixedSize()
                segmentatoCanale.fixedSize()
                Spacer(minLength: P.spazioControlli)
                notaVera
            }
        }
    }

    /// La sfera di Vera con chi scrive: viva quando scrive Vera, ferma sul testo di Prisma.
    private var notaVera: some View {
        let vera = scrive || pronto?.autore == .vera
        let testo = scrive ? TestiMessaggi.veraStaScrivendo : (pronto == nil || vera ? TestiMessaggi.veraScrive : TestiMessaggi.testoPrisma)
        return HStack(spacing: P.spazioSfera) {
            SferaVera(misura: P.sfera, viva: vera || pronto == nil, pensa: scrive)
            Text(testo)
                .carattereApple(P.notaVera)
                .foregroundColor(P.coloreNotaVera)
                .lineLimit(1)
        }
        .fixedSize()
    }

    // MARK: Oggetto

    private var rigaOggetto: some View {
        let oggetto = spedito?.oggetto ?? pronto?.oggetto ?? ModelliMessaggi.oggetto(occasione, canale: .mail) ?? occasione.oggetto
        return HStack(alignment: .firstTextBaseline, spacing: P.spazioOggetto) {
            Text("Oggetto:")
                .carattereApple(P.oggetto)
                .foregroundColor(P.coloreEtichettaOggetto)
            Text(oggetto)
                .carattereApple(P.oggettoForte)
                .foregroundColor(P.coloreOggetto)
        }
            .lineLimit(compatto ? 2 : 1)
            .padding(.vertical, P.paddingOggetto)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle().fill(P.filetto).frame(height: P.spessoreFiletto).allowsHitTesting(false)
            }
    }

    // MARK: Il testo

    @ViewBuilder private var corpo: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !scrive, let a = pronto?.avviso {
                HStack(alignment: .top, spacing: P.spazioSfera) {
                    SferaVera(misura: P.sfera, viva: false)
                    Text(a)
                        .carattereApple(P.avviso)
                        .foregroundColor(P.coloreAvviso)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, P.sopraAvviso)
            }
            if stato.scritteProva, StatoShell.clientiDiProva.contains(cliente.id) {
                Text(TestiMessaggi.datiDiProva)
                    .carattereApple(P.prova)
                    .foregroundColor(P.coloreProva)
                    .padding(.top, P.sopraProva)
            }
            if let m = spedito {
                // Migliorie d'uso 25: il testo spedito com'era, subito (niente puntini né parola per parola)
                Text(m.testo)
                    .carattereApple(T.carattere)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .contenitoreTestoMessaggio(nuvoletta: m.canale == .messaggi, compatto: compatto)
                    .padding(.top, T.sopra)
            } else {
                TestoMessaggioSessione(sessione: sessione, chiave: chiave, scrittoIstantanea: scrittoIstantanea, scrive: scrive,
                                       compatto: compatto)
                    .padding(.top, T.sopra)
            }
            #if !os(macOS)
            // Sul Mac (migliorie d'uso 26) le cifre stanno nella scheda «Da dove vengono le cifre»
            cifre
            nota
            #endif
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Le cifre della scheda come piccole etichette: le sole che il testo può citare.
    @ViewBuilder private var cifre: some View {
        let C = Tema.Apple.Messaggi.Cifre.self
        if !occasione.cifre.isEmpty {
            DisposizioneAcapoRicerca(spazio: C.spazio) {
                ForEach(Array(occasione.cifre.enumerated()), id: \.offset) { _, cifra in
                    HStack(spacing: C.spazioInterno) {
                        Text(cifra.etichetta)
                            .carattereApple(C.etichetta)
                            .foregroundColor(C.coloreEtichetta)
                        Text(cifra.valore)
                            .carattereApple(C.valore)
                            .foregroundColor(C.coloreValore)
                            .truncationMode(.tail)
                    }
                    .lineLimit(1)
                    .padding(C.padding)
                    .background { Capsule(style: .continuous).fill(C.fondo) }
                    .frame(maxWidth: C.larghezzaMassima, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .help("\(cifra.etichetta): \(cifra.valore)")
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.top, C.sopra)
        }
    }

    private var nota: some View {
        let C = Tema.Apple.Messaggi.Cifre.self
        let autore = pronto.map { TestiMessaggi.autore($0) }
        return Text([TestiMessaggi.cifreDaPrisma, autore].compactMap { $0 }.joined(separator: " · "))
            .carattereApple(C.nota)
            .foregroundColor(C.coloreNota)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, C.sopraNota)
    }

    // MARK: Pulsanti

    @ViewBuilder private var barra: some View {
        #if os(macOS)
        if incorniciato && !compatto {
            barraMac
        } else {
            barraComune
        }
        #else
        barraComune
        #endif
    }

    #if os(macOS)
    /// Migliorie d'uso 25: la barra a tre stati; cambia stato con un'entrata breve (opacità e 6 in alto), calma con
    /// «Riduci movimento», ferma nelle istantanee.
    private var barraMac: some View {
        let s = statoBarra
        let M = Tema.Apple.Messaggi.Moto.self
        return ZStack(alignment: .leading) {
            contenutoBarraMac(s)
                .id(s)
                .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: M.spostamentoCambioBarra)),
                                        removal: .identity))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(Tema.Apple.Moto.animazione(M.cambioBarra, calmo: calmo, istantanea: scatto), value: s)
    }

    @ViewBuilder private func contenutoBarraMac(_ s: StatoBarraMessaggio) -> some View {
        let B = Tema.Apple.Messaggi.Barra.self
        switch s {
        case .normale:
            barraComune
        case .daConfermare:
            HStack(alignment: .center, spacing: B.spazio) {
                Text(TestiMessaggi.haiSpedito(occasione.copertura?.canale ?? canale))
                    .carattereApple(B.domanda)
                    .foregroundColor(B.coloreDomanda)
                    .lineLimit(1)
                    .padding(.trailing, B.spazioDomanda)
                Button { siSpedito() } label: { Text(TestiMessaggi.siSpedito) }
                    .buttonStyle(.applePrimarioGrande)
                    .disabled(stato.solaLettura)
                    .help("Lo segni tu: Lucy non sa se Mail o Messaggi l'hanno spedito")
                Button { sessione.domandeChiuse.insert(occasione.id) } label: { Text(TestiMessaggi.nonAncora) }
                    .buttonStyle(.appleGrande)
                Spacer(minLength: B.spazio)
            }
        case .spedito:
            HStack(alignment: .center, spacing: B.spazio) {
                if let c = occasione.copertura, let quando = c.speditoIl {
                    HStack(spacing: B.spazioPillolaSpedito) {
                        Image(systemName: B.simboloPillolaSpedito)
                            .accessibilityHidden(true)
                        Text(TestiMessaggi.speditoAlle(ora: quando, canale: c.canale))
                            .lineLimit(1)
                    }
                    .carattereApple(B.pillolaSpedito)
                    .foregroundColor(B.testoPillolaSpedito)
                    .padding(B.paddingPillolaSpedito)
                    .background { Capsule(style: .continuous).fill(B.fondoPillolaSpedito) }
                    .fixedSize()
                    .accessibilityElement(children: .combine)
                }
                Text(TestiMessaggi.nelDossier(cliente.nome))
                    .carattereApple(B.nota)
                    .foregroundColor(B.coloreNota)
                    .lineLimit(1)
                Spacer(minLength: B.spazio)
                Button { nonPartito() } label: { Text(TestiMessaggi.nonPartito) }
                    .buttonStyle(.appleGrande)
                    .disabled(stato.solaLettura)
                    .help("Toglie il segno: il messaggio torna fra quelli da mandare")
            }
        }
    }
    #endif

    @ViewBuilder private var barraComune: some View {
        let B = Tema.Apple.Messaggi.Barra.self
        if compatto {
            VStack(alignment: .leading, spacing: B.spazio) {
                pulsantePrincipale.frame(maxWidth: .infinity)
                HStack(spacing: B.spazio) {
                    pulsanteSalva.frame(maxWidth: .infinity)
                    pulsanteRiscrivi.frame(maxWidth: .infinity)
                }
                notaSpedisci
            }
        } else {
            HStack(alignment: .center, spacing: B.spazio) {
                pulsantePrincipale
                pulsanteSalva
                pulsanteRiscrivi
                Spacer(minLength: B.spazio)
                notaSpedisci
            }
        }
    }

    private var notaSpedisci: some View {
        let B = Tema.Apple.Messaggi.Barra.self
        return Text(TestiMessaggi.spedisciTu)
            .carattereApple(B.nota)
            .foregroundColor(B.coloreNota)
            .lineLimit(1)
    }

    private var manca: Bool { AperturaMessaggi.recapito(cliente, canale: canale) == nil }

    @ViewBuilder private var pulsantePrincipale: some View {
        if manca {
            Button { stato.apriAnagraficaMessaggio(cliente.id) } label: {
                Text(TestiMessaggi.aggiungiNelDossier).frame(maxWidth: compatto ? .infinity : nil)
            }
            .buttonStyle(.applePrimarioGrande)
            .disabled(stato.inModoCliente)
            .help(AperturaMessaggi.mancante(canale))
        } else {
            Button { primario() } label: {
                Text(TestiMessaggi.apri(canale)).frame(maxWidth: compatto ? .infinity : nil)
            }
            .buttonStyle(.applePrimarioGrande)
            .disabled(pronto == nil || scrive)
            .help("Apre \(canale.nome) già compilato: niente parte da solo")
        }
    }

    private var pulsanteSalva: some View {
        Button { salva() } label: {
            Text(TestiMessaggi.salva).frame(maxWidth: compatto ? .infinity : nil)
        }
        .buttonStyle(.appleGrande)
        .disabled(pronto == nil || scrive || stato.solaLettura)
        .help("Il messaggio resta nel dossier di \(cliente.nome), con la data, il canale e il tono")
    }

    private var pulsanteRiscrivi: some View {
        Button { sessione.riscrivi(occasione, stato: stato) } label: {
            Text(TestiMessaggi.riscrivi).frame(maxWidth: compatto ? .infinity : nil)
        }
        .buttonStyle(.appleGrande)
        .disabled(scrive || scrittoIstantanea != nil)
        .help("Vera scrive di nuovo lo stesso messaggio, con le stesse cifre")
    }

    // MARK: Fare

    private func primario() {
        if occasione.commerciale && !stato.consensoCommercialeValido(cliente) {
            chiediConsenso = true
        } else {
            apri()
        }
    }

    /// Apre Mail o Messaggi già compilati (mai un invio) e ricorda il messaggio segnato nel dossier.
    private func apri(riletto: Bool = false) {
        let k = chiave
        guard let s = corretto else { return }
        // La seconda lettura: parole a rischio e cifre senza fonte (anche nel testo corretto a mano)
        if !riletto {
            let e = stato.secondaLetturaMessaggio(occasione, testo: s.testo)
            if !e.pulito {
                lettura = e
                return
            }
        }
        let prima = sessione.idSalvato(k)
        let esito = stato.apriMessaggio(occasione, tono: s.tono ?? k.tono, canale: k.canale, scritto: s, id: prima)
        stato.mostraAvviso(esito.messaggio)
        if esito.aperto {
            sessione.ricordaSalvato(k, id: prima ?? stato.dati.messaggi.last(where: { $0.occasioneId == occasione.id })?.id)
            // Migliorie d'uso 25: una nuova apertura riapre la domanda «L'hai spedito?»
            sessione.domandeChiuse.remove(occasione.id)
        }
    }

    /// Migliorie d'uso 25 (Mac): «Sì, spedito» segna l'ora e il canale nel dossier, poi l'app passa al prossimo messaggio.
    private func siSpedito() {
        guard let c = occasione.copertura, stato.segnaSpedito(messaggioId: c.messaggioId) else { return }
        stato.mostraAvviso(TestiMessaggi.segnatoSpedito(cliente.nome))
        dopoSpedito?()
    }

    /// «Non è partito»: toglie il segno; il messaggio resta aperto, la barra torna normale (la domanda resta chiusa).
    private func nonPartito() {
        guard let c = occasione.copertura else { return }
        sessione.domandeChiuse.insert(occasione.id)
        stato.togliSpedito(messaggioId: c.messaggioId)
    }

    /// Salva nel dossier (o aggiorna il messaggio già salvato o aperto, che resta aperto).
    private func salva() {
        let k = chiave
        guard let s = corretto else { return }
        let prima = sessione.idSalvato(k)
        let statoPrima = prima.flatMap { id in stato.dati.messaggi.first(where: { $0.id == id })?.stato }
        let nuovo: StatoMessaggio = (statoPrima == .apertoInMail || statoPrima == .apertoInMessaggi) ? (statoPrima ?? .salvato) : .salvato
        guard let m = stato.salvaMessaggio(occasione, tono: s.tono ?? k.tono, canale: k.canale, scritto: s, stato: nuovo, id: prima) else {
            return
        }
        sessione.ricordaSalvato(k, id: m.id)
        stato.mostraAvviso(TestiMessaggi.salvato(cliente.nome))
    }
}

// MARK: - Il testo del messaggio

/// Il testo: i puntini finché non arriva niente, poi parola per parola, poi il campo da correggere. Una vista a sé,
/// l'unica che legge il testo in arrivo da Vera: un pezzo del flusso rifà lei, non testata, controlli, cifre e
/// pulsanti del pannello. Le correzioni le legge solo il campo (dentro il suo Binding), così un tasto rifà il campo.
@MainActor
private struct TestoMessaggioSessione: View {
    let sessione: SessioneMessaggi
    let chiave: ChiaveTestoMessaggio
    /// Solo nelle istantanee: il testo già pronto.
    let scrittoIstantanea: TestoScrittoMessaggio?
    let scrive: Bool
    let compatto: Bool

    @Environment(\.prismaScatto) private var scatto

    private typealias T = Tema.Apple.Messaggi.Testo

    var body: some View {
        let k = chiave
        let nuvoletta = k.canale == .messaggi
        let pronto = scrittoIstantanea ?? sessione.arrivato(k)
        let correggibile = !scatto && pronto != nil && !scrive && sessione.comparsi.contains(k)
        if correggibile {
            CampoTestoMessaggio(testo: Binding(get: { sessione.testo(k) ?? "" }, set: { sessione.correggi(k, $0) }))
                .contenitoreTestoMessaggio(nuvoletta: nuvoletta, compatto: compatto)
        } else if pronto == nil && sessione.parziale.isEmpty {
            PuntiniScrittura()
                .padding(.top, T.sopraPuntini)
                .frame(maxWidth: .infinity, minHeight: nuvoletta ? nil : (compatto ? T.altezzaMinimaCompatta : T.altezzaMinima),
                       alignment: nuvoletta ? .topTrailing : .topLeading)
        } else {
            // Con le correzioni: la seconda lettura può correggere il testo prima che la comparsa finisca
            let testo: String = pronto == nil ? sessione.parziale : (scrittoIstantanea?.testo ?? sessione.testo(k) ?? "")
            TestoProgressivo(testo: testo, passo: Tema.Apple.Messaggi.Moto.parola,
                             anima: !scatto, finito: { sessione.comparso(k) })
                .carattereApple(T.carattere)
                .id("\(k.occasione)-\(k.tono.rawValue)-\(k.canale.rawValue)-\(sessione.giri[k] ?? 0)")
                .contenitoreTestoMessaggio(nuvoletta: nuvoletta, compatto: compatto)
        }
    }
}

// MARK: - Gli avvisi dello stile

/// Gli avvisi dello stile sul testo corretto: una vista a sé, così un tasto nel messaggio rifà lei (e il campo), non
/// il pannello. Il pannello la mostra solo quando il testo è pronto.
@MainActor
private struct AvvisiStileSessione: View {
    let sessione: SessioneMessaggi
    let chiave: ChiaveTestoMessaggio
    /// Solo nelle istantanee: il testo già pronto.
    let scrittoIstantanea: TestoScrittoMessaggio?
    let clienteId: String

    var body: some View {
        let k = chiave
        AvvisiStileMessaggioVista(testo: scrittoIstantanea?.testo ?? sessione.testo(k) ?? "", clienteId: clienteId,
                                  messaggio: "\(k.occasione)-\(k.tono.rawValue)-\(k.canale.rawValue)")
    }
}

// MARK: - Il campo di testo

/// Il campo di testo del messaggio (TextEditor del sistema) alto quanto il testo: un testo invisibile uguale dà
/// l'altezza, il campo ci sta sopra senza fondo proprio. Il margine interno del campo si toglie, così il testo non
/// si sposta quando la comparsa parola per parola finisce e il campo prende il suo posto.
private struct CampoTestoMessaggio: View {
    @Binding var testo: String

    private typealias T = Tema.Apple.Messaggi.Testo

    var body: some View {
        Text(testo + "\n")
            .carattereApple(T.carattere)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .opacity(0)
            .accessibilityHidden(true)
            .overlay {
                TextEditor(text: $testo)
                    .carattereApple(T.carattere)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .padding(.horizontal, -T.rientroCampo)
                    .accessibilityLabel(Text("Testo del messaggio"))
            }
    }
}

// MARK: - Mail o nuvoletta

private struct ContenitoreTestoMessaggio: ViewModifier {
    let nuvoletta: Bool
    let compatto: Bool

    private typealias T = Tema.Apple.Messaggi.Testo

    @ViewBuilder func body(content: Content) -> some View {
        if nuvoletta {
            content
                .foregroundColor(T.testoNuvoletta)
                .tint(T.testoNuvoletta)
                .padding(T.paddingNuvoletta)
                .background {
                    RettangoloAngoli(altoSinistra: T.raggioNuvoletta, altoDestra: T.raggioNuvoletta,
                                     bassoDestra: T.raggioNuvolettaStretto, bassoSinistra: T.raggioNuvoletta)
                        .fill(T.fondoNuvoletta)
                }
                .frame(maxWidth: T.larghezzaNuvoletta, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            content
                .foregroundColor(T.colore)
                .frame(maxWidth: .infinity, minHeight: compatto ? T.altezzaMinimaCompatta : T.altezzaMinima, alignment: .topLeading)
        }
    }
}

private extension View {
    func contenitoreTestoMessaggio(nuvoletta: Bool, compatto: Bool) -> some View {
        modifier(ContenitoreTestoMessaggio(nuvoletta: nuvoletta, compatto: compatto))
    }
}
