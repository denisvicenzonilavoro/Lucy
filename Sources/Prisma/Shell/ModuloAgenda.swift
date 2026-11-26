import SwiftUI

/// Modulo per creare o modificare un appuntamento.
struct ModuloAppuntamento: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.dismiss) var chiudi
    @State var bozza: Appuntamento
    let nuovo: Bool
    let salva: (Appuntamento) -> Void
    let elimina: () -> Void
    /// La riga in testa a «Quando e dove» (dopo «Pianifica» della striscia dei riesami); nil = nessuna.
    var spiegazione: String? = nil
    @State var confermaEliminazione = false

    private var valido: Bool {
        !bozza.titolo.trimmingCharacters(in: .whitespaces).isEmpty
            && (bozza.tipo == .nonDisponibile || stato.cliente(bozza.clienteId) != nil)
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        // Con lo stile Carta (Mac e iPad) il foglio del nuovo impegno ridisegnato (25 novembre 2026, scelta
        // dell'utente); sull'iPhone, che resta sul tema Apple, il modulo di prima. Stessi campi, stesse funzioni.
        Group {
            if Tema.Stile.usaCarta {
                moduloCarta
            } else {
                moduloClassico
            }
        }
        .alert("Eliminare questo appuntamento?", isPresented: $confermaEliminazione) {
            Button("Annulla", role: .cancel) {}
            Button("Elimina", role: .destructive) {
                elimina()
                chiudi()
            }
        } message: {
            Text("Le attività collegate restano nel tuo elenco. Se serve, potrai recuperarlo da un backup.")
        }
    }

    /// Salva la bozza (minuti interi: l'archivio JSON non conserva le frazioni di secondo) e chiude.
    private func conferma() {
        var a = bozza
        a.inizio = Appuntamento.alMinuto(a.inizio)
        salva(a)
        chiudi()
    }

    // MARK: - I controlli (gli stessi nei due moduli)

    private var sceltaCliente: some View {
        Picker("", selection: $bozza.clienteId) {
            ForEach(stato.clienti) { c in Text(c.nome).tag(c.id) }
        }
        .labelsHidden()
        .onChange(of: bozza.clienteId) { _ in bozza.posizioneId = nil }
    }

    private var sceltaTipo: some View {
        Picker("", selection: $bozza.tipo) {
            ForEach(TipoAppuntamento.allCases) { Text($0.nome).tag($0) }
        }
        .labelsHidden()
    }

    private var dataEOra: some View {
        VStack(alignment: .leading, spacing: Misure.RiesamiAgenda.spazioRighe) {
            DatePicker("", selection: $bozza.inizio, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .stileDataCampo()
                .environment(\.locale, Formati.italiano)
            avvisiOrario
        }
    }

    private var durata: some View {
        Stepper(value: $bozza.durataMinuti, in: 5...720, step: 5) {
            Text("\(bozza.durataMinuti) minuti").font(Tipo.campoValore).foregroundColor(Colori.Rubrica.testo)
        }
    }

    /// Dove si è svolto, per i chilometri di Studio › Spese («Luce» giro 9, decisione 100): lo dice l'utente.
    private var sceltaPresso: some View {
        Picker("", selection: $bozza.presso) {
            Text("Non indicato").tag(LuogoIncontro?.none)
            ForEach(LuogoIncontro.allCases) { Text($0.nome).tag(Optional($0)) }
        }
        .labelsHidden()
    }

    /// Proposto dal Territorio con «＋ Aggiungi … al giro» («Luce» giro 11): si conferma qui.
    private var daConfermare: some View {
        HStack(spacing: Tema.Apple.Territorio.Pannello.spazio) {
            Text("Proposto dal Territorio: da confermare")
                .font(Tipo.campoValore)
                .foregroundColor(Colori.Rubrica.testo)
            Button("Conferma") { bozza.daConfermare = nil }
                .buttonStyle(.apple)
        }
    }

    private var concluso: some View {
        Toggle("Incontro concluso", isOn: Binding(get: { bozza.stato == .concluso },
                                                  set: { bozza.stato = $0 ? .concluso : .pianificato }))
            .stileCasella()
    }

    private var sceltaPosizione: some View {
        Picker("", selection: $bozza.posizioneId) {
            Text("Nessuna").tag(String?.none)
            ForEach(stato.posizioniCliente(bozza.clienteId)) { p in
                Text("\(p.stato == .proposta ? "Proposta · " : "")\(p.nome) (\(p.canale.nomeBreve))").tag(Optional(p.id))
            }
        }
        .labelsHidden()
    }

    // MARK: - Lo stile Carta

    /// Il foglio del nuovo impegno: testata con l'occhiello, il titolo in New York e la sottolineatura dorata; quattro
    /// gruppi (Cosa, Quando, Dove, Con chi) con l'etichetta sopra ogni campo; il piede con i pulsanti a capsula.
    private var moduloCarta: some View {
        let m = TemaCarta.Modulo.self
        return VStack(spacing: 0) {
            testataCarta
            ScrollView {
                VStack(alignment: .leading, spacing: m.spazioGruppi) {
                    gruppoCarta("Cosa") {
                        campoCarta("Titolo") {
                            TextField("Per esempio Revisione del piano annuale", text: $bozza.titolo)
                                .textFieldStyle(.plain)
                                .fontCarta(m.valore)
                                .foregroundColor(TemaCarta.Colore.inchiostroD)
                                .padding(.horizontal, m.paddingCampo)
                                .frame(height: m.altezzaCampo)
                                .background(casella)
                        }
                        campoCarta("Tipo") {
                            sceltaTipo
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        campoCarta("Note per l'incontro") {
                            TextEditor(text: $bozza.note)
                                .font(Tipo.campoValore)
                                .scrollContentBackground(.hidden)
                                .padding(m.paddingCampo / 2)
                                .frame(height: m.altezzaNote)
                                .background(casella)
                        }
                    }
                    gruppoCarta("Quando", nota: spiegazione) {
                        HStack(alignment: .top, spacing: m.spazioColonne) {
                            campoCarta("Data e ora") { dataEOra }
                            campoCarta("Durata") { durata }
                        }
                        if bozza.daConfermare == true {
                            campoCarta("Da confermare") { daConfermare }
                        }
                        if !nuovo {
                            campoCarta("Stato") { concluso }
                        }
                    }
                    gruppoCarta("Dove") {
                        campoCarta("Luogo o collegamento") {
                            TextField("In studio, telefono, videochiamata…", text: $bozza.luogo)
                                .textFieldStyle(.plain)
                                .fontCarta(m.valore)
                                .foregroundColor(TemaCarta.Colore.inchiostroD)
                                .padding(.horizontal, m.paddingCampo)
                                .frame(height: m.altezzaCampo)
                                .background(casella)
                        }
                        campoCarta("Dove si svolge") {
                            sceltaPresso
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    gruppoCarta("Con chi") {
                        campoCarta("Cliente") {
                            sceltaCliente
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        campoCarta("Posizione collegata") {
                            sceltaPosizione
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, m.margine)
                .padding(.bottom, m.margine)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            piedeCarta
        }
        .frame(width: m.misura.width, height: m.misura.height)
        .background(TemaCarta.Colore.cartaD)
    }

    private var testataCarta: some View {
        let m = TemaCarta.Modulo.self
        return VStack(alignment: .leading, spacing: m.spazioTestata) {
            Text((nuovo ? "Agenda · nuovo" : "Agenda · modifica").uppercased())
                .fontCarta(m.occhiello)
                .tracking(m.tracciaOcchiello)
                .foregroundColor(TemaCarta.Colore.matitaD)
            Text(nuovo ? "Nuovo impegno" : "Modifica impegno")
                .fontCarta(m.titolo)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
            Capsule()
                .fill(TemaCarta.Colore.oroD)
                .frame(width: m.sottolineatura.width, height: m.sottolineatura.height)
                .padding(.top, m.sopraSottolineatura)
            Text("Cosa, quando, dove e con chi")
                .fontCarta(m.sottotitolo)
                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                .padding(.top, m.sopraSottolineatura)
        }
        .padding(.horizontal, m.margine)
        .padding(.top, m.sopraTestata)
        .padding(.bottom, m.sottoTestata)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var piedeCarta: some View {
        let m = TemaCarta.Modulo.self
        return HStack(spacing: m.spazioPulsanti) {
            if !nuovo {
                Button { confermaEliminazione = true } label: {
                    Label("Elimina…", systemImage: "trash")
                }
                .buttonStyle(PulsanteModuloCarta(tipo: .pericolo))
            }
            Spacer(minLength: 0)
            Button("Annulla") { chiudi() }
                .buttonStyle(PulsanteModuloCarta(tipo: .secondario))
                .keyboardShortcut(.cancelAction)
            Button(nuovo ? "Crea impegno" : "Salva modifiche") { conferma() }
                .buttonStyle(PulsanteModuloCarta(tipo: .primario))
                .disabled(!valido)
                .opacity(valido ? 1 : m.opacitaSpento)
                .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, m.margine)
        .frame(height: m.piede)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(TemaCarta.Colore.filo2D)
                .frame(height: Tema.Misura.filo)
                .allowsHitTesting(false)
        }
    }

    /// Il fondo delle caselle di testo: foglio chiaro con il filo.
    private var casella: some View {
        let forma = RoundedRectangle(cornerRadius: TemaCarta.Modulo.raggioCampo, style: .continuous)
        return forma
            .fill(TemaCarta.Colore.foglioD)
            .overlay(forma.strokeBorder(TemaCarta.Colore.filo2D, lineWidth: Tema.Misura.filo))
    }

    /// Un gruppo: titolo in New York (con la nota in corsivo sotto, se c'è) e i campi, su una scheda con il filo.
    private func gruppoCarta<C: View>(_ titolo: String, nota: String? = nil,
                                      @ViewBuilder _ contenuto: () -> C) -> some View {
        let m = TemaCarta.Modulo.self
        let forma = RoundedRectangle(cornerRadius: m.raggioGruppo, style: .continuous)
        return VStack(alignment: .leading, spacing: m.spazioCampi) {
            VStack(alignment: .leading, spacing: m.spazioTestata) {
                Text(titolo)
                    .fontCarta(m.titoloGruppo)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                if let nota {
                    Text(nota)
                        .fontCarta(m.notaGruppo)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            contenuto()
        }
        .padding(m.paddingGruppo)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(forma.fill(TemaCarta.Colore.schedaD))
        .overlay(forma.strokeBorder(TemaCarta.Colore.filoD, lineWidth: Tema.Misura.filo).allowsHitTesting(false))
    }

    /// Un campo: l'etichetta in SF Mono maiuscola sopra e il controllo a tutta larghezza sotto.
    private func campoCarta<C: View>(_ etichetta: String, @ViewBuilder _ controllo: () -> C) -> some View {
        let m = TemaCarta.Modulo.self
        return VStack(alignment: .leading, spacing: m.sottoEtichetta) {
            Text(etichetta.uppercased())
                .fontCarta(m.etichetta)
                .tracking(m.tracciaEtichetta)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .lineLimit(1)
            controllo()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Il modulo di prima (tema Apple, iPhone)

    private var moduloClassico: some View {
        CorniceModulo(titolo: nuovo ? "Nuovo appuntamento" : "Modifica appuntamento") {
            VStack(alignment: .leading, spacing: 20) {
                sezione("L'incontro") {
                    CampoModulo(etichetta: "Titolo") {
                        TextField("Per esempio Revisione del piano annuale", text: $bozza.titolo).textFieldStyle(.roundedBorder)
                    }
                    CampoModulo(etichetta: "Cliente") {
                        sceltaCliente
                            .frame(width: 240)
                    }
                    CampoModulo(etichetta: "Tipo") {
                        sceltaTipo
                            .frame(width: 240)
                    }
                    // Dal 25 novembre 2026 (decisione dell'utente) un solo canale, quello di Lucy: la scelta del canale non si mostra (il valore salvato resta)
                }
                sezione("Quando e dove") {
                    if let spiegazione {
                        Text(spiegazione)
                            .font(Tipo.kpiNota)
                            .foregroundColor(Colori.Analisi.kpiNota)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    CampoModulo(etichetta: "Data e ora") {
                        dataEOra
                    }
                    CampoModulo(etichetta: "Durata") {
                        durata
                    }
                    CampoModulo(etichetta: "Luogo o collegamento") {
                        TextField("In studio, telefono, videochiamata…", text: $bozza.luogo).textFieldStyle(.roundedBorder)
                    }
                    CampoModulo(etichetta: "Dove") {
                        sceltaPresso
                            .frame(width: Tema.Apple.Studio.Spese.Moduli.sceltaPresso)
                    }
                    if bozza.daConfermare == true {
                        CampoModulo(etichetta: "Da confermare") {
                            daConfermare
                        }
                    }
                    if !nuovo {
                        CampoModulo(etichetta: "Stato") {
                            concluso
                        }
                    }
                }
                sezione("Di cosa si parla") {
                    CampoModulo(etichetta: "Posizione collegata") {
                        sceltaPosizione
                            .frame(width: 320)
                    }
                    CampoModulo(etichetta: "Note per l'incontro") {
                        CampoTestoLungo(testo: $bozza.note)
                    }
                }
            }
        } piede: {
            if !nuovo {
                Button { confermaEliminazione = true } label: {
                    Label("Elimina…", systemImage: "trash").foregroundColor(Colori.Rubrica.pericolo)
                }
                .buttonStyle(StileVetro())
            }
            Spacer()
            Button("Annulla") { chiudi() }
                .buttonStyle(StileVetro())
                .keyboardShortcut(.cancelAction)
            Button(nuovo ? "Crea appuntamento" : "Salva modifiche") { conferma() }
                .buttonStyle(StileBlu())
                .disabled(!valido)
                .opacity(valido ? 1 : 0.5)
                .keyboardShortcut(.defaultAction)
        }
        .frame(width: Misure.Agenda.modulo.width, height: Misure.Agenda.modulo.height)
    }

    /// Avvisi calcolati dal vivo a ogni cambio della bozza, per qualunque appuntamento: si sovrappone a un altro
    /// (di qualunque cliente) o cade fuori dagli orari di lavoro. Avvisano soltanto: si può salvare lo stesso.
    @ViewBuilder private var avvisiOrario: some View {
        let accavallati = MotorePianificazione.sovrapposti(bozza, in: stato.dati.appuntamenti)
        let orari = stato.dati.impostazioni.orari
        if let primo = accavallati.first {
            // In modalità cliente il nome di un altro cliente non compare
            let nome = stato.cliente(primo.clienteId)?.nome ?? "un altro cliente"
            let altri = accavallati.count - 1
            let orario = "\(Formati.ora.string(from: primo.inizio))–\(Formati.ora.string(from: primo.fine))"
            let seguito: String = altri > 0 ? " e ad altri \(altri)" : ""
            let avviso: String = "⚠︎ Si sovrappone a «\(primo.titolo)» con \(nome) (\(orario))" + seguito
            Text(avviso)
                .font(Tipo.kpiNota)
                .foregroundColor(Colori.Analisi.attenzioneTesto)
                .fixedSize(horizontal: false, vertical: true)
        }
        if MotorePianificazione.fuoriOrario(bozza, orari: orari) {
            Text("Fuori dagli orari di lavoro (\(orari.descrizione))")
                .font(Tipo.kpiNota)
                .foregroundColor(Colori.Analisi.kpiNota)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func sezione<C: View>(_ titolo: String, @ViewBuilder _ contenuto: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            OcchielloSezione(titolo: titolo)
            contenuto()
        }
    }
}

/// Modulo per creare o modificare un'attività.
struct ModuloAttivita: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.dismiss) var chiudi
    @State var bozza: Attivita
    let nuova: Bool
    let salva: (Attivita) -> Void
    let elimina: () -> Void
    @State var confermaEliminazione = false

    private var valida: Bool {
        !bozza.titolo.trimmingCharacters(in: .whitespaces).isEmpty && stato.cliente(bozza.clienteId) != nil
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        CorniceModulo(titolo: nuova ? "Nuova attività" : "Modifica attività") {
            VStack(alignment: .leading, spacing: 14) {
                CampoModulo(etichetta: "Cosa c'è da fare?") {
                    TextField("Per esempio Preparare il riepilogo per il cliente", text: $bozza.titolo).textFieldStyle(.roundedBorder)
                }
                CampoModulo(etichetta: "Cliente") {
                    Picker("", selection: $bozza.clienteId) {
                        ForEach(stato.clienti) { c in Text(c.nome).tag(c.id) }
                    }
                    .labelsHidden()
                    .frame(width: 240)
                }
                CampoModulo(etichetta: "Scadenza") {
                    DatePicker("", selection: $bozza.scadenza, displayedComponents: .date)
                        .labelsHidden()
                        .stileDataCampo()
                        .environment(\.locale, Formati.italiano)
                }
                CampoModulo(etichetta: "Priorità") {
                    Picker("", selection: $bozza.priorita) {
                        ForEach(Attivita.Priorita.allCases) { Text($0.nome).tag($0) }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                }
                CampoModulo(etichetta: "Note") {
                    CampoTestoLungo(testo: $bozza.note)
                }
                if let e = stato.appuntamento(bozza.appuntamentoId) {
                    CampoModulo(etichetta: "Appuntamento") {
                        Text("\(e.titolo) · \(Formati.giornoMese.string(from: e.inizio)), \(Formati.ora.string(from: e.inizio))")
                            .font(Tipo.campoValore)
                            .foregroundColor(Colori.Rubrica.secondario)
                    }
                }
            }
        } piede: {
            if !nuova {
                Button { confermaEliminazione = true } label: {
                    Label("Elimina…", systemImage: "trash").foregroundColor(Colori.Rubrica.pericolo)
                }
                .buttonStyle(StileVetro())
            }
            Spacer()
            Button("Annulla") { chiudi() }
                .buttonStyle(StileVetro())
                .keyboardShortcut(.cancelAction)
            Button(nuova ? "Crea attività" : "Salva modifiche") {
                var t = bozza
                t.scadenza = Calendar.current.startOfDay(for: t.scadenza)
                salva(t)
                chiudi()
            }
            .buttonStyle(StileBlu())
            .disabled(!valida)
            .opacity(valida ? 1 : 0.5)
            .keyboardShortcut(.defaultAction)
        }
        .frame(width: Misure.Attivita.modulo.width, height: Misure.Attivita.modulo.height)
        .alert("Eliminare questa attività?", isPresented: $confermaEliminazione) {
            Button("Annulla", role: .cancel) {}
            Button("Elimina", role: .destructive) {
                elimina()
                chiudi()
            }
        } message: {
            Text("Se serve, potrai recuperarla da un backup.")
        }
    }
}

/// Testo su più righe con la cornice dei campi.
struct CampoTestoLungo: View {
    @Binding var testo: String

    var body: some View {
        TextEditor(text: $testo)
            .font(Tipo.campoValore)
            .frame(height: 84)
            .overlay {
                FormaVetro.arrotondata(Tema.Raggio.Dossier.campoLungo)
                    .strokeBorder(Tema.Colore.separatore, lineWidth: Tema.Misura.filo)
                    .allowsHitTesting(false)
            }
    }
}

/// I pulsanti a capsula del piede dei moduli su carta: il primario pieno d'inchiostro, il secondario con il filo,
/// «Elimina…» in rosso con il filo. Premuti si fanno appena più chiari.
struct PulsanteModuloCarta: ButtonStyle {
    enum Genere { case primario, secondario, pericolo }
    let tipo: Genere

    func makeBody(configuration: Configuration) -> some View {
        let m = TemaCarta.Modulo.self
        let forma = Capsule()
        return configuration.label
            .fontCarta(m.pulsante)
            .foregroundColor(colorePrimo)
            .lineLimit(1)
            .padding(.horizontal, m.paddingPulsante)
            .frame(height: m.altezzaPulsante)
            .background(forma.fill(tipo == .primario ? TemaCarta.Colore.inchiostroD : TemaCarta.Colore.schedaD))
            .overlay(forma.strokeBorder(tipo == .primario ? Color.clear : coloreFilo, lineWidth: Tema.Misura.filo))
            .contentShape(forma)
            .opacity(configuration.isPressed ? m.opacitaPremuto : 1)
    }

    private var colorePrimo: Color {
        switch tipo {
        case .primario: return TemaCarta.Colore.suInchiostroD
        case .secondario: return TemaCarta.Colore.inchiostroD
        case .pericolo: return TemaCarta.Colore.rossoD
        }
    }

    private var coloreFilo: Color {
        tipo == .pericolo ? TemaCarta.Colore.rossoD : TemaCarta.Colore.filo2D
    }
}
