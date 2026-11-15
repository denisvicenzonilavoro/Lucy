import SwiftUI

// L'app Mercato, «Prisma conosce il mercato» (versione «Orizzonte», giro 7, Design/template-novita-specifica.md §12):
//
//   ┌ 🔒 Dal Mac escono solo le richieste di dati pubblici (BCE, Eurostat): nessun dato dei clienti lascia Prisma. ┐
//   ┌ Euro Stoxx 50 ┐┌ Rendimento IT ┐┌ Spread ┐┌ Euribor 3 mesi ┐┌ Inflazione ┐┌ Tasso BCE ┐   ← tessere con la mini linea,
//   │ 3.712  −1,8%  ││ 3,42%  +0,15  ││  …     ││ 2,08%  −0,02   ││ 1,6% −0,2  ││ 2,00% inv.│     la data e la fonte
//   └───────────────┘└───────────────┘└────────┘└────────────────┘└────────────┘└───────────┘
//   ┌─ CHI È TOCCATO OGGI ──────────────────────────┐ ┌─ AVVISI ─────────────────────────────┐
//   │ ▌«Euro Stoxx 50» è sceso dell'1,8% a ottobre   │ │ [risultato della ricerca per ISIN]   │
//   │ ▌6 clienti…: il portafoglio di Marco perde…   │ │ ● ◉ Marco Bianchi  «Fondo…» −6% (●  ) │
//   │ ▌◉◉◉ +3                [Prepara un messaggio] │ │ ● ◉ Sofia Romano   La cedola…   (●  ) │
//   └───────────────────────────────────────────────┘ └──────────────────────────────────────┘
//
// - Le cifre vengono da MotoreMercato (TessereMercato.swift): valore, variazione, tono buono o cattivo per i clienti,
//   mini linea, data e fonte. Le frasi da TestiAppMercato e TestiMercato, mai dalla vista.
// - Con «Dati di mercato» spento la fascia dice che nulla esce dal Mac e come accenderlo; si può sempre importare un
//   CSV o scrivere un valore a mano. Mai aggiornato: una tessera larga con l'invito.
// - Le tessere si inclinano verso il puntatore (6 gradi) e il dettaglio nasce dalla tessera, con la serie di 12 mesi.
// - Movimento: cascata (fascia 0, tessere 1…6, riquadri 7 e 8), linee che si disegnano, numeri che si contano, pallino
//   rosso che pulsa. «Riduci movimento» e istantanee: tutto fermo nello stato finale, senza alone.
// - iPad: la stessa vista; nelle finestre strette le tessere vanno a capo e i riquadri uno sotto l'altro. Su iPhone e
//   iPad Mercato si legge soltanto (MercatoTelefono.swift per l'iPhone).
// - Migliorie d'uso 29 (Design/uso/gruppo-04.md §29, solo Mac): la fascia verde lascia il posto all'etichetta
//   «Escono solo dati pubblici» / «Niente esce dal Mac» nella riga in testa; con un cliente scelto nella barra i
//   riquadri diventano «Cosa tocca <Nome> oggi» e «Avvisi per <Nome>»; ogni avviso ha la sua azione e «Silenzia»;
//   «Soglie…» sta nel riquadro degli avvisi. Su iPad fascia e interruttore restano come prima.
// Valori in DesignSystem/Apple/Tema.Apple+Mercato.swift.

@MainActor
struct AppMercato: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        CorpoMercato(sessione: stato.sessioneMercato, dettaglioAperto: stato.sessioneMercato.dettaglioIstantanea)
    }
}

@MainActor
private struct CorpoMercato: View {
    @Environment(StatoShell.self) var stato
    @Bindable var sessione: SessioneMercato
    @StateObject private var dettaglio: StatoDettaglio
    @Environment(\.prismaScatto) private var scatto

    private typealias D = Tema.Apple.Mercato.Disposizione
    private typealias M = Tema.Apple.Mercato.Moto

    init(sessione: SessioneMercato, dettaglioAperto: String?) {
        self.sessione = sessione
        _dettaglio = StateObject(wrappedValue: dettaglioAperto.map {
            StatoDettaglio(aperto: $0, misura: Tema.Apple.Mercato.Dettaglio.misura)
        } ?? StatoDettaglio())
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        let oggi = Date()
        // Tessere e «Chi è toccato» una volta per dati dei calcoli (mercato, soglie, posizioni, clienti, obiettivi), giorno
        // e ora, non a ogni passaggio del body: MotoreMercato.toccati scorre tutte le posizioni. La configurazione delle
        // serie si legge una volta per sessione.
        let ora = DerivatiDati.ora(oggi)
        let tessere: [TesseraMercato] = stato.ricavato("mercato-tessere|\(ora)") { stato.tessereMercato(oggi: oggi) }
        let eventi: [EventoMercato] = stato.ricavato("mercato-eventi|\(ora)") { stato.eventiMercato(oggi: oggi) }
        let d = dettaglio
        return GeometryReader { geo in
            let largo = geo.size.width >= D.larghezzaAffiancati
            Group {
                if largo {
                    contenuto(tessere: tessere, eventi: eventi, larghezza: geo.size.width, largo: true) { id in
                        d.apri(id, misura: Tema.Apple.Mercato.Dettaglio.misura)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        contenuto(tessere: tessere, eventi: eventi, larghezza: geo.size.width, largo: false) { id in
                            d.apri(id, misura: Tema.Apple.Mercato.Dettaglio.misura)
                        }
                    }
                }
            }
        }
        .presentatoreDettaglio(dettaglio) { id in
            DettaglioSerieMercato(id: id)
        }
        .overlay { if scatto { foglioIstantanea } }
        // «Il mercato per i tuoi clienti» (fase 4 di Vera, funzione 14): la scena sopra Mercato (VisteMercatoClientiVera.swift)
        .scenaMercatoClientiVera()
        .sheet(item: scatto ? Binding<FoglioMercato?>.constant(nil) : $sessione.foglio) { f in
            FoglioMercatoVista(foglio: f)
                .environment(stato)
        }
        .onAppear {
            guard !scatto else { return }
            stato.aperturaMercato()
        }
        .onDisappear { dettaglio.chiudi(subito: true) }
    }

    /// Nelle istantanee il foglio si disegna sopra la finestra (i fogli di sistema non entrano nell'immagine).
    @ViewBuilder private var foglioIstantanea: some View {
        if let f = sessione.foglio {
            ZStack {
                Tema.Apple.Colore.velo
                FoglioMercatoVista(foglio: f)
                    .frame(width: Tema.Apple.Mercato.Foglio.larghezza)
                    .superficieApple(Tema.Apple.Superficie.dettaglio)
            }
        }
    }

    private func contenuto(tessere: [TesseraMercato], eventi: [EventoMercato], larghezza: CGFloat, largo: Bool,
                           apri: @escaping (String) -> Void) -> some View {
        let attivo = stato.dati.impostazioni.mercato.attivo
        let vecchi = MotoreMercato.datiVecchi(tessere)
        let maiAggiornato = tessere.isEmpty && stato.dati.mercato.quote.isEmpty
        let sinistra = max(0, (larghezza - D.spazioRiquadri) * D.proporzioneRiquadri / (D.proporzioneRiquadri + 1))
        // Migliorie d'uso 29 (sul Mac): con un cliente scelto nella barra i riquadri parlano solo di lui. Filtri su
        // elenchi già in cache e piccoli; la fascia verde lascia il posto all'etichetta nella riga in testa.
        #if os(macOS)
        let scelto: Cliente? = stato.tuttiIClienti ? nil : stato.clienteAttivo
        let conFascia = false
        #else
        let scelto: Cliente? = nil
        let conFascia = true
        #endif
        let mostrati: [EventoMercato] = scelto.map { c in
            eventi.filter { e in e.toccati.contains { $0.clienteId == c.id } }
        } ?? eventi
        return VStack(alignment: .leading, spacing: 0) {
            if conFascia {
                FasciaRiservatezzaMercato(attivo: attivo)
                    .entrataCascata(0, base: M.base)
                    .padding(.bottom, D.spazioStriscia)
            }
            Group {
                if maiAggiornato {
                    VuotoMercato(attivo: attivo)
                        .entrataCascata(1, base: M.base)
                } else {
                    StrisciaMercato(tessere: tessere, larghezza: larghezza, apri: apri)
                }
            }
            Group {
                if largo {
                    HStack(alignment: .top, spacing: D.spazioRiquadri) {
                        // Affiancati i riquadri hanno l'altezza della finestra: le righe si costruiscono mentre entrano
                        // in vista (`pigro`)
                        RiquadroToccati(eventi: mostrati, vecchi: vecchi, senzaDati: maiAggiornato, cliente: scelto, pigro: true)
                            .frame(width: sinistra)
                            .frame(maxHeight: .infinity)
                            .entrataCascata(M.indiceMassimoTessere + 1, base: M.base)
                        RiquadroAvvisi(sessione: sessione, cliente: scelto, pigro: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .entrataCascata(M.indiceMassimoTessere + 2, base: M.base)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                } else {
                    VStack(alignment: .leading, spacing: D.spazioRiquadri) {
                        RiquadroToccati(eventi: mostrati, vecchi: vecchi, senzaDati: maiAggiornato, cliente: scelto)
                            .frame(minHeight: D.altezzaRiquadroImpilato)
                            .entrataCascata(M.indiceMassimoTessere + 1, base: M.base)
                        RiquadroAvvisi(sessione: sessione, cliente: scelto)
                            .frame(minHeight: D.altezzaRiquadroImpilato)
                            .entrataCascata(M.indiceMassimoTessere + 2, base: M.base)
                    }
                }
            }
            .padding(.top, D.sopraRiquadri)
        }
    }
}

// MARK: - Occhiello e azioni della testata

/// L'occhiello di Mercato nella testata, scritto dal motore: «Aggiornato oggi alle 18:00 · valori di prova».
struct OcchielloMercato: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        OcchielloMercatoCorpo(sessione: stato.sessioneMercato)
    }
}

private struct OcchielloMercatoCorpo: View {
    @Environment(StatoShell.self) var stato
    @Bindable var sessione: SessioneMercato

    var body: some View {
        let _ = ContaCorpi.segna()
        Text(stato.occhielloMercato().uppercased())
            .font(Tipo.appOcchiello)
            .foregroundColor(Colori.IntestazioneApp.occhiello)
            .lineLimit(1)
    }
}

/// A destra nella testata: sul Mac l'etichetta della riservatezza, poi la ricerca per ISIN a pillola con «Cerca»
/// dentro; su iPad anche il pulsante blu delle soglie degli avvisi (sul Mac «Soglie…» sta nel riquadro degli avvisi).
struct AzioniMercato: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        AzioniMercatoCorpo(sessione: stato.sessioneMercato)
    }
}

private struct AzioniMercatoCorpo: View {
    @Environment(StatoShell.self) var stato
    @Bindable var sessione: SessioneMercato

    private typealias I = Tema.Apple.Mercato.ISIN

    var body: some View {
        let _ = ContaCorpi.segna()
        HStack(spacing: I.spazio) {
            #if os(macOS)
            // Migliorie d'uso 29: prima di tutto l'etichetta della riservatezza (al posto della fascia verde)
            EtichettaRiservatezzaMercato(attivo: stato.dati.impostazioni.mercato.attivo) { sessione.foglio = .riservatezza }
            #endif
            CampoISINMercato(sessione: sessione)
            // «Per i tuoi clienti» (fase 4 di Vera): si nasconde da solo in modalità cliente
            PulsanteMercatoClientiVera()
            #if !os(macOS)
            // Sul Mac le soglie si aprono da «Soglie…» nel riquadro degli avvisi (migliorie d'uso 29)
            if !stato.inModoCliente {
                Button { sessione.foglio = .soglie } label: {
                    Label(TestiAppMercato.soglie, systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.applePrimario)
                .help(TestiAppMercato.soglieNota)
            }
            #endif
        }
    }
}

#if os(macOS)
/// Migliorie d'uso 29 (template `.chipC`, riga 4019): la capsula con il lucchetto nella riga in testa. Dice solo il
/// vero: «Escono solo dati pubblici» con «Dati di mercato» acceso, «Niente esce dal Mac» da spento. Sotto il puntatore
/// si solleva di 2 (fermo con «Riduci movimento» e nelle istantanee); un clic apre la scheda «Riservatezza».
struct EtichettaRiservatezzaMercato: View {
    let attivo: Bool
    let azione: () -> Void

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @State private var sopra = false

    private typealias R = Tema.Apple.Mercato.Riservatezza

    var body: some View {
        let forma = Capsule(style: .continuous)
        let testo = TestiAppMercato.etichettaRiservatezza(attivo: attivo)
        return Button(action: azione) {
            HStack(spacing: R.spazio) {
                Image(systemName: R.simbolo)
                    .carattereApple(R.carattereSimbolo)
                    .foregroundColor(attivo ? R.coloreSimboloAcceso : R.coloreSimboloSpento)
                    .accessibilityHidden(true)
                Text(testo)
                    .carattereApple(R.testo)
                    .foregroundColor(R.coloreTesto)
                    .lineLimit(1)
            }
            .padding(R.padding)
            .background {
                forma.fill(R.fondo)
                    .overlay { forma.strokeBorder(R.bordo, lineWidth: R.spessoreBordo) }
            }
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .fixedSize()
        .offset(y: sollevata ? R.sollevamento : 0)
        .animation(Tema.Apple.Moto.animazione(Tema.Apple.Moto.ChipScelta.animazione, calmo: calmo, istantanea: istantanea),
                   value: sollevata)
        .onHover { dentro in sopra = dentro && !istantanea }
        .help(TestiAppMercato.aiutoRiservatezza)
        .accessibilityLabel(Text(testo))
    }

    private var sollevata: Bool { sopra && !calmo && !istantanea }
}
#endif

/// Il campo ISIN a pillola (`chip`, raggio 99) con «Cerca» dentro: Invio cerca, Esc svuota (sul Mac).
struct CampoISINMercato: View {
    @Environment(StatoShell.self) var stato
    @Bindable var sessione: SessioneMercato

    private typealias I = Tema.Apple.Mercato.ISIN

    var body: some View {
        let _ = ContaCorpi.segna()
        HStack(spacing: I.spazio) {
            TextField("", text: $sessione.testoISIN, prompt: Text(TestiAppMercato.cercaISIN))
                .textFieldStyle(.plain)
                .font(I.campo.font)
                .foregroundColor(I.coloreCampo)
                .frame(width: I.larghezzaCampo)
                .onSubmit { stato.cercaISINMercato() }
                #if os(macOS)
                .onExitCommand { stato.chiudiRicercaISIN() }
                #endif
                .accessibilityLabel(TestiAppMercato.cercaISIN)
            Button(TestiAppMercato.cerca) { stato.cercaISINMercato() }
                .buttonStyle(.apple)
                .disabled(sessione.testoISIN.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(I.paddingPillola)
        .background { Capsule(style: .continuous).fill(I.fondo) }
        .fixedSize()
    }
}

// MARK: - Fascia della riservatezza

/// La fascia verde in cima (§12.1.3): con l'interruttore acceso escono solo richieste di dati pubblici; spento nulla
/// esce dal Mac, con il rimando a Impostazioni › Mercato.
struct FasciaRiservatezzaMercato: View {
    @Environment(StatoShell.self) var stato
    let attivo: Bool

    private typealias F = Tema.Apple.Mercato.Fascia

    var body: some View {
        let _ = ContaCorpi.segna()
        let testi = TestiAppMercato.fascia(attivo: attivo)
        HStack(alignment: .center, spacing: F.spazio) {
            Image(systemName: F.simbolo)
                .carattereApple(F.carattereSimbolo)
                .foregroundColor(F.coloreSimbolo)
                .accessibilityHidden(true)
            (Text(testi.testo).font(F.testo.font) + Text(testi.forte).font(F.forte.font))
                .foregroundColor(F.coloreTesto)
                .lineSpacing(F.testo.spazioRighe)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            #if os(macOS)
            if !attivo, stato.appConsentita(.impostazioni) {
                Button(TestiAppMercato.apriImpostazioni) { stato.apriImpostazioniMercato() }
                    .buttonStyle(.appleSobrio)
            }
            #endif
        }
        .padding(F.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: F.raggio, style: .continuous).fill(F.fondo)
        }
        .overlay {
            RoundedRectangle(cornerRadius: F.raggio, style: .continuous).strokeBorder(F.bordo, lineWidth: Tema.Apple.Misura.bordo)
        }
        .accessibilityElement(children: .combine)
    }
}

extension StatoShell {
    /// Impostazioni sulla pagina Mercato.
    func apriImpostazioniMercato() {
        schedaImpostazioni = .mercato
        apri(.impostazioni)
    }
}

// MARK: - Mai aggiornato

/// Nessuna serie e nessuna quota: la tessera larga con l'invito a scaricare (se permesso) o a importare.
struct VuotoMercato: View {
    @Environment(StatoShell.self) var stato
    let attivo: Bool

    private typealias V = Tema.Apple.Mercato.Vuoto

    var body: some View {
        let _ = ContaCorpi.segna()
        VStack(alignment: .leading, spacing: V.spazio) {
            Text(TestiAppMercato.vuotoTitolo)
                .carattereApple(V.titolo)
                .foregroundColor(V.coloreTitolo)
            Text(TestiAppMercato.vuotoTesto(attivo: attivo))
                .carattereApple(V.testo)
                .foregroundColor(V.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
            #if os(macOS)
            HStack(spacing: V.spazioPulsanti) {
                if attivo {
                    Button(TestiAppMercato.scaricaDatiPubblici) { stato.aggiornaMercato(forza: true) }
                        .buttonStyle(.applePrimario)
                } else if stato.appConsentita(.impostazioni) {
                    Button(TestiAppMercato.apriImpostazioni) { stato.apriImpostazioniMercato() }
                        .buttonStyle(.apple)
                }
                Button(TestiAppMercato.importaFile) { stato.scegliFileMercato() }
                    .buttonStyle(StilePulsanteApple(attivo ? .secondaria : .principale))
                Button(TestiAppMercato.aMano) { stato.sessioneMercato.foglio = .aMano }
                    .buttonStyle(.apple)
            }
            .disabled(stato.solaLettura)
            .padding(.top, V.sopraPulsanti)
            #else
            Text(TestiAppMercato.soloDalMac)
                .carattereApple(V.testo)
                .foregroundColor(V.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
            #endif
        }
        .padding(V.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(V.superficie, raggio: V.raggio)
    }
}

// MARK: - La striscia

/// Le tessere in una griglia di 6 colonne uguali (meno nelle finestre strette, a capo).
struct StrisciaMercato: View {
    let tessere: [TesseraMercato]
    let larghezza: CGFloat
    let apri: (String) -> Void

    private typealias D = Tema.Apple.Mercato.Disposizione

    var body: some View {
        let possibili = Int((larghezza + D.spazioStriscia) / (D.larghezzaMinimaTessera + D.spazioStriscia))
        let colonne = max(2, min(D.colonne, possibili))
        let griglia = Array(repeating: GridItem(.flexible(), spacing: D.spazioStriscia, alignment: .top), count: colonne)
        return LazyVGrid(columns: griglia, alignment: .leading, spacing: D.spazioStriscia) {
            ForEach(Array(tessere.enumerated()), id: \.element.id) { i, t in
                TesseraStrisciaMercato(tessera: t, indice: i) { apri(t.id) }
                    .entrataCascata(1 + min(i, Tema.Apple.Mercato.Moto.indiceMassimoTessere - 1), base: Tema.Apple.Mercato.Moto.base)
            }
        }
    }
}

/// Una tessera (§12.1.4): nome, valore che si conta, variazione nel colore del tono (o la data se il dato è vecchio,
/// o «Da importare»), la mini linea che si disegna nel colore del tono e in fondo la data e la fonte.
struct TesseraStrisciaMercato: View {
    @Environment(StatoShell.self) var stato
    let tessera: TesseraMercato
    let indice: Int
    let apri: () -> Void

    private typealias T = Tema.Apple.Mercato.Tessera

    var body: some View {
        let _ = ContaCorpi.segna()
        let t = tessera
        let forma = RoundedRectangle(cornerRadius: T.raggio, style: .continuous)
        return VStack(alignment: .leading, spacing: T.spazioRighe) {
            Text(t.nome)
                .carattereApple(T.nome)
                .foregroundColor(T.coloreNome)
                .lineLimit(1)
                .truncationMode(.tail)
            valore(t)
            variazione(t)
            linea(t)
                .frame(height: T.altezzaLinea)
                .padding(.top, T.sopraLinea)
                .accessibilityHidden(true)
            Text(([t.dataTesto].compactMap { $0 } + [t.citazione]).joined(separator: " · "))
                .carattereApple(T.fonte)
                .foregroundColor(T.coloreFonte)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.top, T.sopraFonte)
        }
        .padding(T.padding)
        .frame(maxWidth: .infinity, minHeight: Tema.Apple.Mercato.Disposizione.altezzaTessera, alignment: .topLeading)
        .contentShape(forma)
        .onTapGesture { if !t.senzaValore { apri() } }
        .superficieApple(T.superficie, raggio: T.raggio)
        .inclinazione(massimo: T.inclinazione, raggio: T.raggio, attiva: !t.senzaValore)
        .origineDettaglio(id: t.id)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(TestiAppMercato.voceTessera(t))
        .accessibilityAddTraits(t.senzaValore ? AccessibilityTraits() : .isButton)
        .help(t.citazione)
    }

    @ViewBuilder private func valore(_ t: TesseraMercato) -> some View {
        if let v = t.valore {
            let unita = t.unita
            let decimali = t.decimali
            NumeroCheConta(v, formato: .personalizzato({ MotoreMercato.testoValore($0, unita: unita, decimali: decimali) }),
                           indice: indice)
                .carattereApple(T.valore)
                .foregroundColor(T.coloreValore)
                .lineLimit(1)
                .minimumScaleFactor(T.riduzioneValore)
        } else {
            Text(t.valoreTesto)
                .carattereApple(T.valore)
                .foregroundColor(T.coloreSenzaValore)
        }
    }

    @ViewBuilder private func variazione(_ t: TesseraMercato) -> some View {
        if t.senzaValore {
            Text(stato.dati.impostazioni.mercato.attivo && stato.sessioneMercato.configurazione?.serie(t.id) != nil
                 ? TestiAppMercato.inArrivo : TestiAppMercato.daImportare)
                .carattereApple(T.nota)
                .foregroundColor(T.coloreNota)
                .lineLimit(1)
        } else if t.freschezza == .vecchia, let d = t.dataTesto {
            Text(TestiAppMercato.alDato(d))
                .carattereApple(T.nota)
                .foregroundColor(T.coloreNota)
                .lineLimit(1)
        } else {
            Text(t.variazioneTesto ?? TestiAppMercato.senzaValore)
                .carattereApple(T.variazione)
                .foregroundColor(ColoriMercato.cifra(t.tono))
                .lineLimit(1)
        }
    }

    @ViewBuilder private func linea(_ t: TesseraMercato) -> some View {
        if t.linea.count >= 2 {
            let n = Double(t.linea.count - 1)
            let punti = t.linea.enumerated().map { CGPoint(x: Double($0.offset) / n, y: $0.element) }
            TracciatoGrafico(punti: punti, colore: ColoriMercato.linea(t.tono), spessore: T.spessoreLinea,
                             indice: min(indice, Tema.Apple.Mercato.Moto.indiceMassimoTessere - 1))
        } else {
            // Il binario della linea mentre il valore non c'è ancora
            VStack {
                Spacer(minLength: 0)
                Capsule().fill(T.binario).frame(height: T.spessoreBinario)
            }
        }
    }
}

/// I colori dei toni (Tema.Apple.Mercato.Toni).
enum ColoriMercato {
    static func cifra(_ t: TonoMercato) -> Color {
        let k = Tema.Apple.Mercato.Toni.self
        switch t {
        case .buono: return k.cifraBuona
        case .cattivo: return k.cifraCattiva
        case .neutro: return k.cifraNeutra
        }
    }

    static func linea(_ t: TonoMercato) -> Color {
        let k = Tema.Apple.Mercato.Toni.self
        switch t {
        case .buono: return k.lineaBuona
        case .cattivo: return k.lineaCattiva
        case .neutro: return k.lineaNeutra
        }
    }

    static func avviso(_ t: TonoAvvisoMercato) -> Color {
        let k = Tema.Apple.Mercato.Toni.self
        switch t {
        case .rosso: return k.rosso
        case .arancio: return k.arancio
        case .verde: return k.verde
        case .spento: return k.spento
        }
    }
}
