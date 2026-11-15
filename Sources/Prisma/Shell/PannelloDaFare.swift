#if os(macOS)
import SwiftUI

// Migliorie d'uso 3 «Un solo Da fare» (Design/uso/gruppo-01.md §3, template righe 3193-3257), solo sul Mac:
// - `RigaDaFare`: la riga comune (cerchio da spuntare, pallino del momento, titolo, «<Cliente> · <quando>», etichette dei
//   canali) del pannello e della scrivania; spuntata scivola via (opacità 0, 16 a destra) e la voce sparisce da tutta Prisma;
// - `PannelloDaFare`: il pannello della pillola «Da fare» della barra (al posto del centro notifiche): «Da fare» con il
//   numero, «Tutti | Solo <Nome>» con un cliente scelto, gli arrivi e gli avvisi che non si spuntano, i gruppi Oggi /
//   Questa settimana / Questo mese / Più avanti con tutte le voci, in fondo «+ Aggiungi» e «Fatte oggi · Annulla l’ultima»;
// - `StratoDettaglioDaFare`: il dettaglio di una voce al centro della scena fuori da Posizioni (lo stesso delle schede di
//   Posizioni › Portafoglio), o la scheda semplice delle voci scritte a mano.
// Con «Riduci movimento» e nelle istantanee tutto è già al suo posto (lo fanno i componenti del tema).

// MARK: - La riga

struct RigaDaFare: View {
    let voce: VoceDaFare
    /// Il nome del cliente sotto il titolo (no quando l'elenco è già di un cliente).
    var conNome = true
    /// Le etichette dei canali a destra (no nel dossier e nell'Agenda).
    var conCanali = true
    /// Il titolo va a capo (nel pannello); altrove si taglia con i puntini.
    var titoloACapo = false
    /// Il filo arancio dell'Agenda.
    var filoAgenda = false
    let fatto: () -> Void
    let apri: () -> Void

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @State private var uscendo = false
    @State private var sopra = false
    @State private var sopraCerchio = false

    private typealias F = Tema.Apple.ElencoDaFare

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: F.raggioRiga, style: .continuous)
        HStack(spacing: F.spazioRiga) {
            cerchio
            Circle()
                .fill(F.colorePallino(voce.tono))
                .frame(width: F.pallino, height: F.pallino)
            VStack(alignment: .leading, spacing: 0) {
                Text(voce.perche)
                    .carattereApple(F.titoloRiga)
                    .foregroundColor(Tema.Apple.Colore.inchiostro)
                    .lineLimit(titoloACapo ? nil : 1)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: titoloACapo)
                Text(TestiDaFare.sotto(voce, conNome: conNome))
                    .carattereApple(F.sottoRiga)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if conCanali, !voce.canali.isEmpty {
                HStack(spacing: F.spazioCanali) {
                    ForEach(voce.canali, id: \.self) { c in
                        EtichettaCanaleApple(canale: c, compatta: true)
                    }
                }
                .fixedSize()
            }
        }
        .padding(F.paddingRiga)
        .frame(minHeight: F.altezzaRiga)
        .background { if sopra && !istantanea { forma.fill(F.fondoRigaSopra) } }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(filoAgenda ? F.filoAgenda : F.filo)
                .frame(height: Tema.Apple.Misura.bordo)
        }
        .contentShape(forma)
        .onTapGesture(perform: apri)
        .onHover { s in sopra = s }
        .opacity(uscendo ? 0 : 1)
        .offset(x: uscendo ? F.uscita : 0)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: Text(TestiDaFare.segnaFatto)) { spunta() }
    }

    private var cerchio: some View {
        Button(action: spunta) {
            Circle()
                .fill(sopraCerchio ? F.fondoCerchioSopra : Color.clear)
                .overlay {
                    Circle().strokeBorder(sopraCerchio ? F.coloreCerchioSopra : F.coloreCerchio, lineWidth: F.trattoCerchio)
                }
                .frame(width: F.cerchio, height: F.cerchio)
                .scaleEffect(sopraCerchio ? F.scalaCerchioSopra : 1)
                // Il bersaglio è più largo del cerchio (`inset: -8` del template)
                .padding(F.paddingRiga.leading)
                .contentShape(Rectangle())
                .padding(-F.paddingRiga.leading)
        }
        .buttonStyle(StileSemplice())
        .onHover { s in
            withAnimation(Tema.Apple.Moto.animazione(Tema.Moto.passaggio, calmo: calmo)) { sopraCerchio = s }
        }
        .help(TestiDaFare.aiutoCerchio)
    }

    /// La riga scivola via, poi la voce si segna come fatta. L'esito di una proposta e «In regola» aprono un modulo:
    /// lì la riga resta finché il modulo non decide.
    private func spunta() {
        let conModulo: Bool
        switch voce.fatto {
        case .esitoProposta, .apriInRegola: conModulo = true
        default: conModulo = false
        }
        guard !conModulo, !calmo, !istantanea else {
            fatto()
            return
        }
        withAnimation(F.animazioneUscita) { uscendo = true }
        Movimenti.dopo(Tema.Apple.Moto.tempo(F.durataUscita)) {
            fatto()
            // Se la voce resta (archivio in sola lettura), la riga torna
            uscendo = false
        }
    }
}

// MARK: - Il numero

/// Il numero delle voci aperte: rosso, verde quando è zero.
struct NumeroDaFare: View {
    let numero: Int

    private typealias F = Tema.Apple.ElencoDaFare

    var body: some View {
        Text("\(numero)")
            .carattereApple(F.numero)
            .foregroundColor(F.testoNumero)
            .padding(F.paddingNumero)
            .background { Capsule(style: .continuous).fill(numero > 0 ? F.fondoNumero : F.fondoNumeroZero) }
            .fixedSize()
    }
}

/// L'etichetta della pillola della barra: ◎ «Da fare» e il numero. Osserva solo il nastro (in cache), così il resto
/// della barra non si ridisegna con i dati.
struct EtichettaPillolaDaFare: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        HStack(spacing: Tema.Apple.ElencoDaFare.spazioPillola) {
            Image(systemName: Tema.Apple.ElencoDaFare.glifoPillola)
                .carattereApple(Tema.Apple.BarraAlta.simbolo)
            Text(TestiDaFare.titolo)
                .carattereApple(Tema.Apple.Carattere.barra)
                .lineLimit(1)
            NumeroDaFare(numero: stato.numeroDaFare)
        }
        .fixedSize()
    }
}

// MARK: - Il pannello

struct PannelloDaFare: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    private typealias F = Tema.Apple.ElencoDaFare

    var body: some View {
        let _ = ContaCorpi.segna()
        ZStack(alignment: .topTrailing) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { stato.pannelloNotifiche = false }
            pannello
                .frame(width: F.larghezza)
                .entrataScheda(Tema.Apple.Moto.animazione(Tema.Apple.Moto.PannelloNotifiche.animazione, calmo: calmo),
                               scala: Tema.Apple.Moto.PannelloNotifiche.scala, ancora: .topTrailing,
                               y: Tema.Apple.Moto.PannelloNotifiche.spostamento)
                .padding(.top, Misure.Notifiche.alto)
                .padding(.trailing, F.destra)
                .padding(.bottom, F.basso)
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var pannello: some View {
        let solo = stato.clienteSoloDaFare
        let nastro = stato.nastroDaFareCompleto(cliente: solo?.id)
        // Gli arrivi portano anche altri nomi: con «Solo <Nome>» no
        let arrivi = solo == nil ? stato.arriviDaFare : []
        return VStack(alignment: .leading, spacing: 0) {
            testa(numero: nastro.totale)
            // Con poche righe l'elenco prende solo l'altezza che serve (ViewThatFits misura l'elenco intero, poi quello
            // che scorre). Con molte righe (con 200 clienti sono centinaia) le due misure creavano due volte ogni riga
            // del pannello, decine di secondi all'apertura e alla chiusura: se le righe non possono stare nell'altezza
            // dell'elenco (ognuna è alta almeno `altezzaRiga`), si scorre subito e le righe nascono solo quando si vedono.
            if arrivi.count + nastro.blocchi.reduce(0, { $0 + $1.voci.count }) > F.righeSenzaScorrere {
                ScrollView { elenco(nastro, arrivi: arrivi, conNome: solo == nil, pigro: !istantanea) }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: F.altezzaElenco)
            } else {
                ViewThatFits(in: .vertical) {
                    elenco(nastro, arrivi: arrivi, conNome: solo == nil)
                    ScrollView { elenco(nastro, arrivi: arrivi, conNome: solo == nil) }
                        .scrollIndicators(.hidden)
                }
                .frame(maxHeight: F.altezzaElenco)
            }
            PiedeDaFare()
        }
        .padding(F.padding)
        .superficieApple(.vetroSopra, raggio: F.raggio)
    }

    /// «Da fare» con il numero; con un cliente scelto «Tutti | Solo <Nome>», altrimenti «in ordine di tempo».
    private func testa(numero: Int) -> some View {
        HStack(spacing: F.spazioTitolo) {
            Text(TestiDaFare.titolo)
                .carattereApple(F.titolo)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
            NumeroDaFare(numero: numero)
            Spacer(minLength: F.spazioTitolo)
            if !stato.tuttiIClienti, let c = stato.cliente(stato.clienteAttivoId) {
                SegmentatoPillola(selezione: Bindable(stato).daFareSoloCliente,
                                  voci: [(false, TestiDaFare.tutti), (true, TestiDaFare.solo(TestiTraguardi.primoNome(c.nome)))])
                    .fixedSize()
            } else {
                Text(TestiDaFare.inOrdine)
                    .carattereApple(F.nota)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
            }
        }
        .padding(F.paddingTesta)
    }

    /// Le righe del pannello; `pigro` (dentro lo ScrollView, con molte righe) le crea solo quando entrano in vista
    /// (nelle istantanee no: la schermata ferma le disegna tutte subito).
    @ViewBuilder
    private func elenco(_ nastro: NastroDaFare, arrivi: [Notifica], conNome: Bool, pigro: Bool = false) -> some View {
        if pigro {
            LazyVStack(alignment: .leading, spacing: 0) { righe(nastro, arrivi: arrivi, conNome: conNome) }
                .padding(.horizontal, F.paddingElenco)
        } else {
            VStack(alignment: .leading, spacing: 0) { righe(nastro, arrivi: arrivi, conNome: conNome) }
                .padding(.horizontal, F.paddingElenco)
        }
    }

    @ViewBuilder
    private func righe(_ nastro: NastroDaFare, arrivi: [Notifica], conNome: Bool) -> some View {
            if !arrivi.isEmpty {
                titoloGruppo("\(TestiDaFare.arrivati) · \(arrivi.count)", primo: true)
                ForEach(arrivi) { n in
                    RigaArrivoDaFare(notifica: n)
                }
            }
            if nastro.vuoto {
                Text(TestiDaFare.tuttoFatto)
                    .carattereApple(F.nota)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, F.vuotoPadding)
            }
            ForEach(nastro.blocchi) { b in
                titoloGruppo("\(b.gruppo.titolo) · \(b.totale)", primo: arrivi.isEmpty && b.id == nastro.blocchi.first?.id)
                ForEach(b.voci) { v in
                    RigaDaFare(voce: v, conNome: conNome, conCanali: true, titoloACapo: true,
                               fatto: { stato.fattoDaFare(v) }, apri: { stato.apriVoceDaFare(v) })
                }
            }
    }

    private func titoloGruppo(_ testo: String, primo: Bool) -> some View {
        Text(testo)
            .carattereApple(F.gruppo)
            .foregroundColor(Tema.Apple.Colore.inchiostro2)
            .padding(.top, primo ? F.gruppoPrimoSopra : F.gruppoSopra)
            .padding(.bottom, F.gruppoSotto)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Un arrivo o un avviso (carta e note dall'iPhone, carte della notte, appuntamenti di oggi, cose da sistemare…): non si
/// spunta, un clic porta dove si risolve (come la notifica di sempre).
private struct RigaArrivoDaFare: View {
    @Environment(StatoShell.self) var stato
    let notifica: Notifica
    @State private var sopra = false

    private typealias F = Tema.Apple.ElencoDaFare

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: F.raggioRiga, style: .continuous)
        Button { stato.apriNotifica(notifica) } label: {
            HStack(spacing: F.spazioRiga) {
                Circle()
                    .fill(colore)
                    .frame(width: F.pallino, height: F.pallino)
                    .frame(width: F.cerchio)
                VStack(alignment: .leading, spacing: 0) {
                    Text(notifica.titolo)
                        .carattereApple(F.titoloRiga)
                        .foregroundColor(Tema.Apple.Colore.inchiostro)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(notifica.dettaglio)
                        .carattereApple(F.sottoRiga)
                        .foregroundColor(Tema.Apple.Colore.inchiostro2)
                        .lineLimit(1)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                if let c = notifica.canale {
                    EtichettaCanaleApple(canale: c, compatta: true)
                        .fixedSize()
                }
            }
            .padding(F.paddingRiga)
            .frame(minHeight: F.altezzaRiga)
            .background { if sopra { forma.fill(F.fondoRigaSopra) } }
            .overlay(alignment: .bottom) {
                Rectangle().fill(F.filo).frame(height: Tema.Apple.Misura.bordo)
            }
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .onHover { s in sopra = s }
    }

    private var colore: Color {
        switch notifica.gruppo {
        case .daFare: return F.pallinoArrivoUrgente
        case .oggi: return F.pallinoArrivoInformazione
        case .prossimi, .daSistemare: return F.pallinoArrivoAvviso
        }
    }
}

/// Il piede del pannello: «+ Aggiungi» (che apre il campo) e, se ce ne sono, «Fatte oggi: N · Annulla l’ultima».
private struct PiedeDaFare: View {
    @Environment(StatoShell.self) var stato

    private typealias F = Tema.Apple.ElencoDaFare

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(F.filo)
                .frame(height: Tema.Apple.Misura.bordo)
            Group {
                if stato.daFareScrivo {
                    CampoAggiungiDaFare(segnaposto: TestiDaFare.segnaposto(nomeScelto),
                                        aggiungi: { stato.aggiungiDaFare($0) },
                                        annulla: { stato.daFareScrivo = false })
                } else {
                    riga
                }
            }
            .padding(F.piedePadding)
        }
        .padding(.top, F.piedeSopra)
    }

    private var nomeScelto: String? {
        guard !stato.tuttiIClienti, let c = stato.cliente(stato.clienteAttivoId) else { return nil }
        return TestiTraguardi.primoNome(c.nome)
    }

    private var riga: some View {
        let fatte = stato.fatteDaFareOggi.count
        return HStack(spacing: 0) {
            Button { stato.daFareScrivo = true } label: {
                Label(TestiDaFare.aggiungi, systemImage: "plus")
                    .carattereApple(F.collegamento)
                    .foregroundColor(F.coloreCollegamento)
            }
            .buttonStyle(StileSemplice())
            .disabled(stato.solaLettura)
            Spacer(minLength: F.spazioTitolo)
            if fatte > 0 {
                Text(TestiDaFare.fatteOggi(fatte))
                    .carattereApple(F.piede)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                Button(TestiDaFare.annullaUltima) { stato.annullaUltimoFattoDaFare() }
                    .buttonStyle(StileSemplice())
                    .carattereApple(F.collegamento)
                    .foregroundColor(F.coloreCollegamento)
            }
        }
        .lineLimit(1)
    }
}

/// Il campo di «+ Aggiungi»: al più 70 caratteri, Invio o «Aggiungi» aggiungono, Esc chiude.
private struct CampoAggiungiDaFare: View {
    let segnaposto: String
    let aggiungi: (String) -> Void
    let annulla: () -> Void
    @State private var testo = ""
    @FocusState private var fuoco: Bool

    private typealias F = Tema.Apple.ElencoDaFare

    var body: some View {
        HStack(spacing: F.spazioTitolo) {
            TextField(segnaposto, text: $testo)
                .textFieldStyle(.plain)
                .carattereApple(F.campo)
                .focused($fuoco)
                .onSubmit { aggiungi(testo) }
                .onExitCommand(perform: annulla)
                .onChange(of: testo) { t in
                    if t.count > F.caratteriCampo { testo = String(t.prefix(F.caratteriCampo)) }
                }
            Button(TestiDaFare.aggiungi) { aggiungi(testo) }
                .buttonStyle(.applePrimario)
        }
        .padding(F.paddingCampo)
        .background { Capsule(style: .continuous).fill(F.fondoCampo) }
        .onAppear { fuoco = true }
    }
}

// MARK: - Il dettaglio al centro

/// Il dettaglio di una voce del «Da fare» aperto fuori da Posizioni (pannello, scrivania): nasce al centro della scena
/// con il presentatore del tema (senza un'origine il contenitore nasce e torna al centro), sopra il velo.
struct StratoDettaglioDaFare: View {
    let stato: StatoShell
    @StateObject private var dettaglio: StatoDettaglio
    @StateObject private var nastro = StatoNastroDaFare()

    private typealias F = Tema.Apple.ElencoDaFare

    init(stato: StatoShell) {
        self.stato = stato
        // Nelle istantanee la voce può essere già aperta al primo disegno
        if let v = stato.voceDaFareAperta {
            _dettaglio = StateObject(wrappedValue: StatoDettaglio(aperto: v.id, misura: Self.misura(v)))
        } else {
            _dettaglio = StateObject(wrappedValue: StatoDettaglio())
        }
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        Color.clear
            .allowsHitTesting(false)
            .presentatoreDettaglio(dettaglio) { id in
                contenuto(id)
            }
            .onChange(of: stato.voceDaFareAperta?.id) { id in
                if let id, let v = stato.voceDaFareAperta {
                    if dettaglio.idAperto != id {
                        dettaglio.chiudi(subito: true)
                        nastro.preparando = nil
                        dettaglio.apri(id, misura: Self.misura(v))
                    }
                } else if dettaglio.aperto {
                    dettaglio.chiudi(subito: true)
                }
            }
            .onChange(of: dettaglio.idAperto) { id in
                // Chiuso dal ✕, da Esc o dal velo: la voce non è più aperta
                if id == nil { stato.chiudiVoceDaFare() }
            }
    }

    private static func misura(_ v: VoceDaFare) -> CGSize {
        v.tipo == .attivita ? F.misuraSemplice : F.misuraDettaglio
    }

    @ViewBuilder private func contenuto(_ id: String) -> some View {
        if let v = stato.voceDaFareAperta, v.id == id {
            if v.tipo == .attivita {
                SchedaDaFareSemplice(voce: v, fatto: { segna(v) }, chiudi: { dettaglio.chiudi() })
            } else {
                DettaglioDaFareApple(voce: v, nastro: nastro,
                                     prepara: { nastro.preparando = v.id },
                                     fatto: { segna(v) },
                                     dossier: {
                                         dettaglio.chiudi(subito: true)
                                         stato.apriDossierDaFare(v)
                                     })
            }
        }
    }

    /// «Segna come fatto»: il modulo dell'esito e «In regola» si aprono subito; il resto dopo la chiusura del dettaglio.
    private func segna(_ v: VoceDaFare) {
        switch v.fatto {
        case .esitoProposta, .apriInRegola:
            dettaglio.chiudi(subito: true)
            stato.fattoDaFare(v)
        default:
            let s = stato
            dettaglio.chiudi(poi: { s.fattoDaFare(v) })
        }
    }
}

/// La scheda semplice di una voce scritta a mano: «<quando> · scritta da te», il testo, «Segna come fatto», «Chiudi».
private struct SchedaDaFareSemplice: View {
    let voce: VoceDaFare
    let fatto: () -> Void
    let chiudi: () -> Void
    @Environment(StatoShell.self) var stato

    private typealias F = Tema.Apple.ElencoDaFare

    var body: some View {
        VStack(alignment: .leading, spacing: F.spazioSemplice) {
            Text(quando)
                .carattereApple(F.quandoSemplice)
                .foregroundColor(Tema.Apple.Posizioni.Scheda.colore(voce.tono))
                .lineLimit(1)
            Text(voce.perche)
                .carattereApple(F.testoSemplice)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
                .fixedSize(horizontal: false, vertical: true)
            if voce.spiegazione != voce.perche {
                Text(voce.spiegazione)
                    .carattereApple(F.notaSemplice)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
            HStack(spacing: F.spazioSemplice) {
                Button(TestiDaFare.segnaFatto, action: fatto)
                    .buttonStyle(.applePrimarioGrande)
                    .disabled(stato.solaLettura)
                Button(TestiDaFare.chiudi, action: chiudi)
                    .buttonStyle(.appleGrande)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// «Oggi · scritta da te» (con il cliente: «Oggi · Giulia Rossi · scritta da te»).
    private var quando: String {
        let chi = voce.cliente.id.isEmpty ? "" : " · \(voce.cliente.nome)"
        return "\(voce.quando)\(chi) · \(TestiDaFare.scrittaDaTe)"
    }
}
#endif
