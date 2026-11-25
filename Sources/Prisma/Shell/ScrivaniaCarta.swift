import SwiftUI

#if os(macOS)
// La scrivania dello stile Carta sul Mac, come il template (Design/template-carta.html; richiesta dell'utente del
// 25 novembre 2026: «più simile al template che ti avevo dato»):
// - a sinistra la data, «Buongiorno.» con la sottolineatura dorata, la frase del giorno, quanto patrimonio segui in
//   tutto, il Foglio di Lucy (che si apre a tutta pagina) e sotto la striscia dei mercati;
// - a destra, come la griglia del template: «Oggi» (incontri e cose da fare insieme) e accanto il patrimonio, la mossa
//   del giorno e il turno di notte;
//   poi il turno di notte, le lettere da Lucy AI e la barra «Chiedi a Lucy».
// Niente canali (un solo canale, Lucy) e niente riquadro dello Studio sulla scrivania. Mai in modalità cliente: lì resta
// la scrivania di prima (porta nomi e cifre di tutti i clienti).

struct ScrivaniaCarta: View {
    @Environment(StatoShell.self) private var stato
    @State private var foglioAperto = false

    /// Le misure di #deskc del template: colonna sinistra di 520 punti, 40 tra le colonne, 60 ai lati.
    private enum M {
        static let sinistra: CGFloat = 520
        static let traColonne: CGFloat = 40
        static let lati: CGFloat = 60
        static let alto: CGFloat = 78
    }

    var body: some View {
        GeometryReader { geo in
            // Su schermi stretti la colonna sinistra si restringe, mai sotto 420
            let sinistra = min(M.sinistra, max(420, geo.size.width * 0.38))
            HStack(alignment: .top, spacing: M.traColonne) {
                ColonnaSinistraCarta(apriFoglio: { foglioAperto = true })
                    .frame(width: sinistra, alignment: .topLeading)
                ColonnaDestraCarta()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, M.lati)
            .padding(.top, min(M.alto, max(24, geo.size.height * 0.07)))
            // La scrivania non scorre: tutto sta sopra il dock
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .clipped()
        }
        .overlay {
            if foglioAperto {
                FoglioTuttaPagina { foglioAperto = false }
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: foglioAperto)
    }
}

// MARK: - Colonna sinistra

private struct ColonnaSinistraCarta: View {
    @Environment(StatoShell.self) private var stato
    let apriFoglio: () -> Void

    var body: some View {
        let oggi = Date()
        let incontri = stato.appuntamentiDiOggi
        VStack(alignment: .leading, spacing: 0) {
            Text(Self.dataMaiuscola(oggi))
                .fontCarta(11, design: .monospaced)
                .tracking(2.2)
                .foregroundColor(TemaCarta.Colore.matitaD)
            TimelineView(.everyMinute) { contesto in
                Text(Self.saluto(contesto.date))
                    .fontCarta(74, weight: .medium, design: .serif)
                    .tracking(-2.4)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .segnoCarta(.sottolinea, chiave: "scrivania.carta.saluto")
            }
            .padding(.top, 6)
            Text(Self.frase(incontri, stato: stato))
                .fontCarta(20, design: .serif, corsivo: true)
                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
            RigaPatrimonioCarta()
                .padding(.top, 10)
            if !stato.inModoCliente {
                PrimaPaginaWidget()
                    // Un clic sul giornale lo apre a tutta pagina, come nel template
                    .contentShape(Rectangle())
                    .onTapGesture(perform: apriFoglio)
                    .overlay(alignment: .topTrailing) {
                        Button(action: apriFoglio) {
                            Label("A tutta pagina", systemImage: "arrow.up.left.and.arrow.down.right")
                                .labelStyle(.iconOnly)
                                .fontCarta(12, weight: .medium)
                                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                                .padding(8)
                        }
                        .buttonStyle(.plain)
                        .help("Apri il Foglio di Lucy a tutta pagina")
                        .padding(6)
                    }
                    .padding(.top, 26)
            }
            MercatiCarta()
                .padding(.top, 18)
        }
    }

    /// «MERCOLEDÌ 25 NOVEMBRE 2026»
    static func dataMaiuscola(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f.string(from: d).uppercased()
    }

    static func saluto(_ d: Date) -> String {
        let ora = Calendar.current.component(.hour, from: d)
        return ora < 13 ? "Buongiorno." : ora < 18 ? "Buon pomeriggio." : "Buonasera."
    }

    /// «Oggi due incontri. Il primo, alle 9:30, è con Giulia Rossi.»
    @MainActor static func frase(_ incontri: [Appuntamento], stato: StatoShell) -> String {
        guard let primo = incontri.first else { return "Oggi nessun incontro in agenda: è una giornata per il lavoro di fondo." }
        let numeri = ["", "un", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove", "dieci"]
        let quanti = incontri.count < numeri.count ? numeri[incontri.count] : "\(incontri.count)"
        let testa = incontri.count == 1 ? "Oggi un incontro." : "Oggi \(quanti) incontri."
        let ora = Formati.ora.string(from: primo.inizio)
        let chi = stato.cliente(primo.clienteId)?.nome
        let primoTesto = incontri.count == 1 ? "Alle \(ora)" : "Il primo, alle \(ora)"
        return chi.map { "\(testa) \(primoTesto), con \($0)." } ?? "\(testa) \(primoTesto): \(primo.titolo)."
    }
}

// MARK: - Mercati

/// La striscia dei mercati sotto il Foglio: gli ultimi valori delle serie scaricate (BCE, Eurostat) o importate, con la
/// variazione sul valore di prima. Senza dati di mercato, l'invito ad accenderli (nessuna cifra inventata).
struct MercatiCarta: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        let serie = Self.scelte(stato.dati.mercato.serie)
        Group {
            if serie.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("I MERCATI")
                        .fontCarta(10, design: .monospaced).tracking(2)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("Nessun dato di mercato: accendili in Impostazioni › Mercato o importa un file.")
                            .fontCarta(12.5)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Button("Apri Mercato") { stato.apri(.mercato) }
                            .buttonStyle(.plain)
                            .fontCarta(12, weight: .medium)
                            .foregroundColor(TemaCarta.Colore.pennaD)
                    }
                }
                .padding(.horizontal, 10)
            } else {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(serie.enumerated()), id: \.element.id) { i, s in
                        cella(s)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .overlay(alignment: .leading) {
                                if i > 0 { Rectangle().fill(TemaCarta.Colore.filoD).frame(width: 1) }
                            }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .onTapGesture { stato.apri(.mercato) }
                .help("I mercati: apri Mercato")
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
    }

    /// Al più cinque serie con dati, una per nome breve (le due inflazioni IPCA sono la stessa cosa).
    static func scelte(_ tutte: [SerieMercato]) -> [SerieMercato] {
        var viste = Set<String>()
        var esito: [SerieMercato] = []
        for s in tutte.filter({ !$0.punti.isEmpty }).sorted(by: { $0.aggiornataIl > $1.aggiornataIl }) {
            let n = nomeBreve(s.nome)
            guard !viste.contains(n) else { continue }
            viste.insert(n)
            esito.append(s)
        }
        // L'ordine del file delle serie, non quello dell'aggiornamento
        let ordine = Dictionary(uniqueKeysWithValues: tutte.enumerated().map { ($0.element.id, $0.offset) })
        return Array(esito.sorted { (ordine[$0.id] ?? 0) < (ordine[$1.id] ?? 0) }.prefix(5))
    }

    /// Il nome corto, come nel template («BTP 10 anni», «Euribor 3 mesi»).
    static func nomeBreve(_ nome: String) -> String {
        let n = nome.lowercased()
        if n.contains("italiani") && n.contains("rendimento") { return "BTP 10 anni" }
        if n.contains("tedeschi") && n.contains("rendimento") { return "Bund 10 anni" }
        if n.contains("inflazione") { return "Inflazione" }
        if n.contains("spread") { return "Spread BTP-Bund" }
        if n.contains("bce") && n.contains("depositi") { return "Tasso BCE" }
        return nome
    }

    private func cella(_ s: SerieMercato) -> some View {
        let ultimo = s.punti.last?.valore ?? 0
        let prima = s.punti.count >= 2 ? s.punti[s.punti.count - 2].valore : nil
        let variazione: Double? = prima.map { p in
            s.unita.variazioneInPercentuale ? (p == 0 ? 0 : (ultimo - p) / p * 100) : ultimo - p
        }
        return VStack(alignment: .leading, spacing: 3) {
            Text(Self.nomeBreve(s.nome).uppercased())
                .fontCarta(9, design: .monospaced).tracking(1.2)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .lineLimit(1)
            Text(Self.valore(ultimo, unita: s.unita))
                .fontCarta(19, weight: .medium, design: .serif, cifre: true)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let v = variazione {
                Text((v >= 0 ? "+" : "") + Formati.percentuale((v * 100).rounded() / 100) .replacingOccurrences(of: "%", with: s.unita.variazioneInPercentuale ? "%" : ""))
                    .fontCarta(10.5, design: .monospaced)
                    .foregroundColor(v >= 0 ? TemaCarta.Colore.verdeD : TemaCarta.Colore.rossoD)
            }
        }
    }

    static func valore(_ v: Double, unita: UnitaMercato) -> String {
        switch unita {
        case .percentuale: return Formati.percentuale((v * 100).rounded() / 100)
        case .euro: return Formati.euro(v)
        case .punti:
            let f = NumberFormatter()
            f.locale = Locale(identifier: "it_IT")
            f.numberStyle = .decimal
            f.maximumFractionDigits = v >= 1000 ? 0 : 2
            return f.string(from: NSNumber(value: v)) ?? "\(v)"
        }
    }
}

// MARK: - Colonna destra

private struct ColonnaDestraCarta: View {
    @Environment(StatoShell.self) private var stato
    /// L'altezza della riga di «Oggi», del portafoglio e della mossa.
    static let altezzaRiga: CGFloat = 400

    var body: some View {
        // .wgrid del template: tre colonne, 18 tra una scheda e l'altra; «Oggi» occupa la prima colonna in altezza
        VStack(alignment: .leading, spacing: 18) {
            // «Oggi» alto quanto la colonna accanto: niente buchi
            HStack(alignment: .top, spacing: 18) {
                OggiCarta()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                VStack(alignment: .leading, spacing: 14) {
                    PortafoglioScontrino()
                    if !stato.inModoCliente {
                        MossaCarta()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            // Una riga di altezza fissa: «Oggi» e la colonna accanto finiscono alla stessa linea, con tante o poche
            // cose da fare (quelle in più restano a un tocco, in Agenda)
            .frame(height: Self.altezzaRiga)
            ParlaConLucyCarta()
            // La lettera da Lucy AI sta nel Foglio: sulla scrivania finiva sotto il dock
        }
    }
}

/// Il portafoglio che segui, come uno scontrino di Lucy: il totale a contachilometri, le aree, i clienti.
private struct PortafoglioScontrino: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        let k = TemaCarta.Scontrino.self
        let clienti = stato.clienti.count
        let r = stato.riepilogoTuttePosizioni
        let aree = AreaPosizione.allCases.filter { $0 != .debiti }
            .compactMap { a -> (AreaPosizione, Double)? in
                let v = r.perArea[a] ?? 0
                return v > 0 ? (a, v) : nil
            }
            .sorted { $0.1 > $1.1 }
        Button {
            stato.posizioneInDettaglio = nil
            stato.portafoglio = true
            stato.apri(.posizioni)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("LUCY")
                    Spacer()
                    Text(Formati.dataBreve.string(from: Date()))
                }
                .fontCarta(k.testata)
                .foregroundColor(TemaCarta.Colore.matitaD)
                VStack(spacing: 4) {
                    Text("IL PORTAFOGLIO CHE SEGUI")
                        .fontCarta(k.titolo).tracking(2)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                    ContachilometriCarta(testo: Formati.euro(clienti == 0 ? 0 : r.attivita))
                        .fontCarta(TestoCarta(dimensione: 34, peso: .medium, disegno: .serif, cifre: true))
                        .foregroundColor(TemaCarta.Colore.inchiostroD)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .segnoCarta(.sottolinea, chiave: "scrivania.carta.portafoglio")
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 10)
                LineaTratteggiata()
                VStack(alignment: .leading, spacing: 6) {
                    if aree.isEmpty {
                        RigaScontrinoVista(etichetta: "Nessuna posizione in essere", importo: "—")
                    }
                    ForEach(Array(aree.prefix(4)), id: \.0) { a, v in
                        RigaScontrinoVista(etichetta: a.nome, importo: Formati.euro(v))
                    }
                }
                .padding(.vertical, 10)
                LineaTratteggiata()
                RigaScontrinoVista(etichetta: clienti == 1 ? "1 cliente" : "\(clienti) clienti",
                                   importo: r.proposteAperte == 1 ? "1 proposta aperta" : "\(r.proposteAperte) proposte aperte",
                                   forte: true)
                    .padding(.top, 10)
            }
            .padding(EdgeInsets(top: 14, leading: 18, bottom: 20, trailing: 18))
            .frame(maxWidth: .infinity)
            .background { FormaScontrino().fill(TemaCarta.Colore.schedaD) }
            .overlay { FormaScontrino().stroke(TemaCarta.Colore.filoD, lineWidth: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Apri il portafoglio in Posizioni")
    }
}

/// «In tutto segui … di patrimonio, per N clienti.» sotto la frase del giorno.
private struct RigaPatrimonioCarta: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        let clienti = stato.clienti.count
        Text(clienti == 0 ? "Ancora nessun cliente: il primo si aggiunge da Clienti."
             : "In tutto stai seguendo \(Formati.euro(stato.riepilogoTuttePosizioni.attivita)) di patrimonio, per \(clienti) \(clienti == 1 ? "cliente" : "clienti").")
            .fontCarta(14, weight: .medium)
            .foregroundColor(TemaCarta.Colore.inchiostroD)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// Etichetta delle schede del template (.wl): mono, maiuscola, matita, con l'icona.
private struct EtichettaScheda: View {
    let icona: String
    let testo: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icona)
                .fontCarta(11)
            Text(testo.uppercased())
                .fontCarta(10, design: .monospaced).tracking(2)
                .lineLimit(1)
        }
        .foregroundColor(TemaCarta.Colore.matitaD)
    }
}

/// La mossa del giorno, una sola, senza canale.
private struct MossaCarta: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        if let m = stato.ricavato("scrivania.carta.mossa", { stato.mossaDelGiorno() }).mossa {
            Button {
                stato.clienteAttivoId = m.cliente.id
                stato.posizioneInDettaglio = nil
                stato.portafoglio = false
                stato.apri(.posizioni)
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    EtichettaScheda(icona: "sparkle", testo: "La mossa del giorno")
                    Text("Chiama \(m.cliente.nome)")
                        .fontCarta(16, weight: .medium, design: .serif)
                        .foregroundColor(TemaCarta.Colore.inchiostroD)
                        .lineLimit(1)
                        .padding(.top, 8)
                    Text(m.motivo)
                        .fontCarta(11.5)
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 3)
                    Spacer(minLength: 6)
                    Text("Apri le sue posizioni →")
                        .fontCarta(12, weight: .medium)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                // Riempie lo spazio sotto il portafoglio, fino alla linea di «Oggi»
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
        }
    }
}

/// «Oggi»: la mossa del giorno, gli incontri e le cose da fare insieme (Agenda e attività unite, come nel template).
private struct OggiCarta: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        let incontri = stato.appuntamentiDiOggi
        let oggi = Calendar.current.startOfDay(for: Date())
        let domani = Calendar.current.date(byAdding: .day, value: 1, to: oggi) ?? oggi
        let tutteDaFare = stato.attivitaAperte.filter { $0.scadenza < domani }
        // Al più sei righe in tutto, così la scheda non si allunga: le altre a un tocco in Agenda
        let righeMassime = 6
        let incontriVisti = Array(incontri.prefix(righeMassime))
        let daFare = tutteDaFare.prefix(max(0, righeMassime - incontriVisti.count))
        let nascoste = (incontri.count - incontriVisti.count) + (tutteDaFare.count - daFare.count)
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                EtichettaScheda(icona: "calendar", testo: Self.titolo(incontri: incontri.count, daFare: tutteDaFare.count))
                Spacer(minLength: 0)
            }
            .foregroundColor(TemaCarta.Colore.matitaD)
            .padding(.bottom, 10)

            if incontri.isEmpty && tutteDaFare.isEmpty {
                Text("Niente in agenda per oggi: un buon giorno per chiamare chi aspetta.")
                    .fontCarta(13, design: .serif, corsivo: true)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    .padding(.vertical, 8)
            }

            ForEach(incontriVisti) { a in
                Button {
                    if !a.clienteId.isEmpty { stato.clienteAttivoId = a.clienteId }
                    stato.apri(.agenda)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(Formati.ora.string(from: a.inizio))
                            .fontCarta(11.5, design: .monospaced)
                            .foregroundColor(TemaCarta.Colore.oroTestoD)
                            .frame(width: 40, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stato.cliente(a.clienteId)?.nome ?? a.titolo)
                                .fontCarta(13, weight: .medium)
                                .foregroundColor(TemaCarta.Colore.inchiostroD)
                                .lineLimit(1)
                            Text(a.luogo.isEmpty ? a.titolo : "\(a.titolo) · \(a.luogo)")
                                .fontCarta(11.5)
                                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 7)
                riga()
            }

            ForEach(Array(daFare)) { t in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Button { stato.alternaCompletata(t.id) } label: {
                        Image(systemName: t.completata ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 40, alignment: .leading)
                    .accessibilityLabel(t.completata ? "Fatta" : "Da fare")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(t.titolo)
                            .fontCarta(13)
                            .strikethrough(t.completata)
                            .foregroundColor(TemaCarta.Colore.inchiostroD)
                            .lineLimit(1)
                        if let nome = stato.cliente(t.clienteId)?.nome {
                            Text(nome)
                                .fontCarta(11.5)
                                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 7)
                riga()
            }
            Spacer(minLength: 8)
            HStack {
                if nascoste > 0 {
                    Text(nascoste == 1 ? "e un'altra cosa" : "e altre \(nascoste) cose")
                        .fontCarta(12, design: .serif, corsivo: true)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                }
                Spacer(minLength: 0)
                Button("Apri l'agenda →") { stato.apri(.agenda) }
                    .buttonStyle(.plain)
                    .fontCarta(12, weight: .medium)
                    .foregroundColor(TemaCarta.Colore.pennaD)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
    }

    private func riga() -> some View {
        Rectangle().fill(TemaCarta.Colore.filoD).frame(height: 1)
    }

    static func titolo(incontri: Int, daFare: Int) -> String {
        var parti = ["OGGI"]
        parti.append(incontri == 1 ? "1 INCONTRO" : "\(incontri) INCONTRI")
        if daFare > 0 { parti.append("\(daFare) DA FARE") }
        return parti.joined(separator: " · ")
    }
}

/// «Parla con Lucy»: la barra del template per chattare con l'assistente, con tre domande pronte.
private struct ParlaConLucyCarta: View {
    @Environment(StatoShell.self) private var stato

    static let domande = ["Chi ha liquidità ferma da più di sei mesi?",
                          "Quali polizze scadono entro Natale?",
                          "Prepara il riepilogo per il prossimo incontro"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button { stato.apri(.vera) } label: {
                HStack(spacing: 14) {
                    LogoLucy(colore: Color.dinamico(chiaro: Tema.Marca.avorio, scuro: Tema.Marca.inchiostro), oro: Tema.Marca.oro)
                        .frame(width: 18, height: 18)
                        .padding(10)
                        .background(Circle().fill(TemaCarta.Colore.inchiostroD))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Parla con Lucy")
                            .fontCarta(17, weight: .medium, design: .serif)
                            .foregroundColor(TemaCarta.Colore.inchiostroD)
                        Text("Chiedile dei tuoi clienti, dei prodotti, dei documenti: risponde con le cifre di Lucy.")
                            .fontCarta(12)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Text("⌘K")
                        .fontCarta(11, design: .monospaced)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(TemaCarta.Colore.filo2D, lineWidth: 1))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Parla con Lucy")
            HStack(spacing: 8) {
                ForEach(Self.domande, id: \.self) { d in
                    Button {
                        stato.apri(.vera)
                        stato.chiediVeraPortafoglio(d)
                    } label: {
                        Text("«\(d)»")
                            .fontCarta(12.5, design: .serif, corsivo: true)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                            .lineLimit(1)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(TemaCarta.Colore.chipD))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
    }
}

/// Il Foglio di Lucy aperto: una finestra come quelle delle app (la chiusura a sinistra, l'icona e il titolo nella riga in
/// testa), grande quanto la scrivania, con il giornale intero dentro. Si chiude con la chiusura o con Esc.
private struct FoglioTuttaPagina: View {
    @Environment(StatoShell.self) private var stato
    let chiudi: () -> Void

    var body: some View {
        let riga = Tema.Apple.RigaTesta.self
        let forma = FormaVetro.arrotondata(Tema.Raggio.finestraIngrandita)
        VStack(spacing: 0) {
            HStack(spacing: riga.spazio) {
                ChiusuraFinestra(chiudi: chiudi)
                LogoLucy(colore: Tema.Marca.tratto, oro: Tema.Marca.oro)
                    .frame(width: 18, height: 18)
                    .padding(.leading, riga.margineIcona)
                Text("Il Foglio di Lucy")
                    .fontCarta(15, weight: .semibold)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                Text(MotorePrimaPagina.edizione(Date()).nome)
                    .fontCarta(12)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                Spacer(minLength: 0)
                Button { stato.ascoltaPrimaPagina(stato.primaPagina()) } label: {
                    Label("Ascolta", systemImage: "speaker.wave.2")
                }
                .buttonStyle(StilePulsanteRigaImpostazioni())
            }
            .padding(riga.padding)
            .frame(height: riga.altezza)
            .frame(maxWidth: .infinity)
            .background(Gradienti.intestazioneApp)
            .overlay(alignment: .bottom) { Rectangle().fill(TemaCarta.Colore.filoD).frame(height: 1) }
            ScrollView {
                VStack(spacing: 22) {
                    FoglioIntero(chiudi: chiudi)
                    HStack(alignment: .top, spacing: 18) {
                        TurnoNotteWidget()
                        LetteraPrismaAIWidget()
                    }
                    .frame(maxWidth: FoglioIntero.larghezza)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .padding(.horizontal, 32)
            }
            .background(SfondoCarta())
        }
        .clipShape(forma)
        .vetro(.finestra(attiva: true), forma: forma)
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 96)
        .background {
            Button("", action: chiudi)
                .keyboardShortcut(.cancelAction)
                .opacity(0)
                .accessibilityHidden(true)
        }
    }
}

/// La pagina di giornale intera, come nel template: testata, «In prima» con il titolo grande e l'articolo, l'agenda,
/// chi chiamare, il numero del giorno, i mercati, la nota di Lucy, le ricorrenze e le scadenze. Ogni frase la scrive il
/// codice con le cifre di Lucy (nessuna cifra inventata).
struct FoglioIntero: View {
    @Environment(StatoShell.self) private var stato
    var chiudi: () -> Void = {}

    static let larghezza: CGFloat = 1120

    var body: some View {
        let p = stato.primaPagina()
        let mono = TestoCarta(dimensione: 10, disegno: .monospaced)
        VStack(alignment: .leading, spacing: 0) {
            // Testata
            HStack {
                Text("Anno I · N. \(p.numero)")
                Spacer()
                Text("\(p.edizione.nome) · stampata da Lucy, sul tuo Mac")
                Spacer()
                Text(Self.dataLunga(p.data))
            }
            .fontCarta(mono).tracking(1.6)
            .foregroundColor(TemaCarta.Colore.matitaD)
            .textCase(.uppercase)
            .lineLimit(1)
            .padding(.bottom, 8)
            .overlay(alignment: .bottom) { filo2 }

            HStack(spacing: 0) {
                Text("Il Foglio di ")
                    .fontCarta(76, weight: .medium, design: .serif)
                Text("Lucy")
                    .fontCarta(76, design: .serif, corsivo: true)
                    .segnoCarta(.sottolinea, chiave: "foglio-intero.titolo")
            }
            .tracking(-2.6)
            .foregroundColor(TemaCarta.Colore.inchiostroD)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.bottom, 6)
            .accessibilityAddTraits(.isHeader)

            VStack(spacing: 2) {
                Rectangle().frame(height: 1)
                Rectangle().frame(height: 1)
            }
            .foregroundColor(TemaCarta.Colore.inchiostroD.opacity(0.6))
            .padding(.top, 8)

            HStack(spacing: 26) {
                ForEach(["I tuoi clienti", "L'agenda", "I mercati", "Le scadenze"], id: \.self) { t in
                    Text(t.uppercased())
                }
            }
            .fontCarta(10, design: .monospaced).tracking(2)
            .foregroundColor(TemaCarta.Colore.inchiostro2D)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .overlay(alignment: .bottom) { filo2 }

            // Prima riga: «In prima» (8 colonne su 12) e l'agenda (4)
            HStack(alignment: .top, spacing: 26) {
                VStack(alignment: .leading, spacing: 0) {
                    chiave("In prima", rossa: true)
                    Text(p.titolo)
                        .fontCarta(42, weight: .medium, design: .serif)
                        .tracking(-1.2)
                        .foregroundColor(TemaCarta.Colore.inchiostroD)
                        .fixedSize(horizontal: false, vertical: true)
                        .segnoCarta(.evidenzia, chiave: "foglio-intero.\(p.numero).\(p.edizione.rawValue)")
                    Text(Self.occhiello(p))
                        .fontCarta(18, design: .serif, corsivo: true)
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 12)
                        .padding(.bottom, 14)
                    let articolo = Self.articolo(p)
                    HStack(alignment: .top, spacing: 26) {
                        paragrafo(articolo.0)
                        paragrafo(articolo.1)
                    }
                    if let primo = p.incontri.first {
                        Button { stato.apri(.agenda) } label: {
                            Text("Apri l'agenda delle \(Formati.ora.string(from: primo.ora)) →")
                        }
                        .buttonStyle(.plain)
                        .fontCarta(13, weight: .medium)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                        .padding(.top, 16)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .layoutPriority(2)
                .padding(.trailing, 26)
                .overlay(alignment: .trailing) { filo }

                VStack(alignment: .leading, spacing: 0) {
                    chiave(p.edizione == .sera ? "L'agenda di domani" : "L'agenda di oggi")
                    if p.incontri.isEmpty {
                        Text("Nessun incontro in agenda.")
                            .fontCarta(14, design: .serif, corsivo: true)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    }
                    ForEach(Array(p.incontri.prefix(6).enumerated()), id: \.offset) { i, a in
                        rigaAgenda(Formati.ora.string(from: a.ora), a.chi, a.cosa == a.chi ? "" : a.cosa,
                                   ultima: i == min(p.incontri.count, 6) - 1)
                    }
                    if let libero = Self.tempoLibero(p) {
                        Text("\(libero) — L.")
                            .fontCarta(TemaCarta.Penna.testo)
                            .foregroundColor(TemaCarta.Colore.pennaD)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                    }
                }
                .frame(width: 300, alignment: .topLeading)
            }
            .padding(.top, 20)

            separatore

            // Seconda riga: da chiamare, il numero del giorno, i mercati
            HStack(alignment: .top, spacing: 26) {
                VStack(alignment: .leading, spacing: 0) {
                    chiave("Da chiamare oggi")
                    if p.daChiamare.isEmpty {
                        Text("Nessuna telefonata in sospeso.")
                            .fontCarta(14, design: .serif, corsivo: true)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    }
                    ForEach(Array(p.daChiamare.enumerated()), id: \.offset) { i, c in
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "phone")
                                .fontCarta(12)
                                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(TemaCarta.Colore.chipD))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(c.chi.isEmpty ? "Senza cliente" : c.chi)
                                    .fontCarta(13.5, weight: .medium)
                                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                                Text(c.perche)
                                    .fontCarta(12)
                                    .foregroundColor(TemaCarta.Colore.inchiostro2D)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 8)
                        .overlay(alignment: .bottom) { if i < p.daChiamare.count - 1 { filo } }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.trailing, 26)
                .overlay(alignment: .trailing) { filo }

                VStack(alignment: .leading, spacing: 0) {
                    chiave("Il numero del giorno")
                    Text(p.numeroDelGiorno)
                        .fontCarta(64, weight: .medium, design: .serif, cifre: true)
                        .tracking(-2)
                        .foregroundColor(TemaCarta.Colore.inchiostroD)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("di patrimonio \(p.didascaliaNumero). È il lavoro che Lucy tiene in ordine con te.")
                        .fontCarta(16, design: .serif, corsivo: true)
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 10)
                    Button {
                        chiudi()
                        stato.apri(.vera)
                    } label: { Text("Chiedi a Lucy che cosa c'è dentro →") }
                        .buttonStyle(.plain)
                        .fontCarta(13, weight: .medium)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                        .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.trailing, 26)
                .overlay(alignment: .trailing) { filo }

                VStack(alignment: .leading, spacing: 0) {
                    chiave("I mercati stanotte")
                    let serie = MercatiCarta.scelte(stato.dati.mercato.serie)
                    if serie.isEmpty {
                        Text("Nessun dato di mercato: si accendono in Impostazioni › Mercato.")
                            .fontCarta(14, design: .serif, corsivo: true)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(Array(serie.enumerated()), id: \.element.id) { i, s in
                        HStack(spacing: 10) {
                            Text(MercatiCarta.nomeBreve(s.nome))
                                .fontCarta(13)
                                .foregroundColor(TemaCarta.Colore.inchiostroD)
                            Spacer(minLength: 6)
                            Text(MercatiCarta.valore(s.punti.last?.valore ?? 0, unita: s.unita))
                                .fontCarta(12.5, design: .monospaced)
                                .foregroundColor(TemaCarta.Colore.inchiostroD)
                        }
                        .padding(.vertical, 7)
                        .overlay(alignment: .bottom) { if i < serie.count - 1 { filo } }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            separatore

            // Terza riga: la nota di Lucy, le ricorrenze, le scadenze
            HStack(alignment: .top, spacing: 26) {
                VStack(alignment: .leading, spacing: 0) {
                    chiave("La nota di Lucy")
                    Text(p.notaVera ?? Self.notaDaScadenze(p))
                        .fontCarta(19, design: .serif, corsivo: true)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("— L.")
                        .fontCarta(17, design: .serif, corsivo: true)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .layoutPriority(2)
                .padding(.trailing, 26)
                .overlay(alignment: .trailing) { filo }

                VStack(alignment: .leading, spacing: 0) {
                    chiave("Ricorrenze")
                    let ricorrenze = Self.ricorrenze(stato.dati.clienti, da: p.data)
                    if ricorrenze.isEmpty {
                        Text("Nessun compleanno nelle prossime settimane.")
                            .fontCarta(14, design: .serif, corsivo: true)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(Array(ricorrenze.enumerated()), id: \.offset) { i, r in
                        rigaAgenda(r.0, r.1, r.2, ultima: i == ricorrenze.count - 1)
                    }
                }
                .frame(width: 250, alignment: .topLeading)
                .padding(.trailing, 26)
                .overlay(alignment: .trailing) { filo }

                VStack(alignment: .leading, spacing: 0) {
                    chiave("Scadenze")
                    if p.scadenze.isEmpty {
                        Text("Niente in scadenza nei prossimi 45 giorni.")
                            .fontCarta(14, design: .serif, corsivo: true)
                            .foregroundColor(TemaCarta.Colore.inchiostro2D)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(Array(p.scadenze.enumerated()), id: \.offset) { i, sc in
                        rigaAgenda(Self.giornoMese(sc.data), sc.posizione,
                                   sc.valore > 0 ? "\(sc.cliente) · circa \(Formati.euro(sc.valore))" : sc.cliente,
                                   ultima: i == p.scadenze.count - 1)
                    }
                }
                .frame(width: 250, alignment: .topLeading)
            }

            // Piede
            HStack {
                Text(p.edizione == .mattino ? "Prossima edizione alle 18:00" : "Prossima edizione domani alle 06:00")
                Spacer()
                Text("Scritta e stampata in locale sul tuo Mac")
                Spacer()
                Text("Cifre di Lucy")
            }
            .fontCarta(TestoCarta(dimensione: 9.5, disegno: .monospaced)).tracking(1.5)
            .textCase(.uppercase)
            .foregroundColor(TemaCarta.Colore.matitaD)
            .lineLimit(1)
            .padding(.top, 9)
            .overlay(alignment: .top) { filo2 }
            .padding(.top, 22)
        }
        .padding(EdgeInsets(top: 26, leading: 40, bottom: 30, trailing: 40))
        .frame(maxWidth: Self.larghezza)
        .background(TemaCarta.Colore.schedaD)
        .shadow(color: .black.opacity(0.06), radius: 1, y: 1)
        .shadow(color: .black.opacity(0.18), radius: 30, y: 24)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Il Foglio di Lucy")
    }

    // MARK: Pezzi

    private var filo: some View { Rectangle().fill(TemaCarta.Colore.filoD).frame(width: 1) }
    private var filo2: some View { Rectangle().fill(TemaCarta.Colore.filo2D).frame(height: 1) }
    private var separatore: some View {
        Rectangle().fill(TemaCarta.Colore.filo2D).frame(height: 1)
            .padding(.top, 22).padding(.bottom, 18)
    }

    private func chiave(_ t: String, rossa: Bool = false) -> some View {
        Text(t.uppercased())
            .fontCarta(10, design: .monospaced).tracking(2)
            .foregroundColor(rossa ? TemaCarta.Colore.rossoD : TemaCarta.Colore.matitaD)
            .padding(.bottom, 8)
    }

    private func paragrafo(_ t: String) -> some View {
        Text(t)
            .fontCarta(13.5)
            .lineSpacing(4)
            .foregroundColor(TemaCarta.Colore.inchiostro2D)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func rigaAgenda(_ t: String, _ titolo: String, _ sotto: String, ultima: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(t)
                .fontCarta(12, design: .monospaced)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .frame(width: 42, alignment: .leading)
            VStack(alignment: .leading, spacing: 1) {
                Text(titolo)
                    .fontCarta(16, weight: .medium, design: .serif)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .lineLimit(1)
                if !sotto.isEmpty {
                    Text(sotto)
                        .fontCarta(11.5)
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) { if !ultima { Rectangle().fill(TemaCarta.Colore.filoD).frame(height: 1) } }
    }

    // MARK: Testi (scritti dal codice con le cifre di Lucy)

    static func dataLunga(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "EEEE d MMMM yyyy"
        return f.string(from: d)
    }

    static func giornoMese(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.dateFormat = "dd.MM"
        return f.string(from: d)
    }

    static func occhiello(_ p: PrimaPagina) -> String {
        if let s = p.scadenze.first {
            return "La più vicina è «\(s.posizione)» di \(s.cliente), il \(Formati.dataBreve.string(from: s.data)): Lucy ha messo in fila tutte quelle dei prossimi 45 giorni."
        }
        if let a = p.incontri.first {
            return "Il primo incontro è alle \(Formati.ora.string(from: a.ora)) con \(a.chi). Il resto della giornata è qui sotto."
        }
        return "Una giornata senza appuntamenti né scadenze vicine: il momento giusto per il lavoro di fondo."
    }

    /// I due paragrafi dell'articolo in prima.
    static func articolo(_ p: PrimaPagina) -> (String, String) {
        let primo: String
        if p.scadenze.isEmpty {
            primo = "Nei prossimi 45 giorni nessuna posizione dei tuoi clienti arriva a scadenza. È il momento per rivedere i portafogli con calma, senza l'urgenza di un rinnovo."
        } else {
            let totale = p.scadenze.reduce(0) { $0 + $1.valore }
            let quante = p.scadenze.count == 1 ? "scade una posizione" : "scadono \(p.scadenze.count) posizioni"
            let valore = totale > 0 ? ", per circa \(Formati.euro(totale)) in tutto" : ""
            let elenco = p.scadenze.dropFirst().prefix(3)
                .map { "\($0.cliente) (\(Formati.dataBreve.string(from: $0.data)))" }.joined(separator: ", ")
            primo = "Nei prossimi 45 giorni \(quante)\(valore)." + (elenco.isEmpty ? "" : " Le altre sono di \(elenco).")
        }
        let secondo: String
        if p.incontri.isEmpty {
            secondo = "In agenda non ci sono incontri. Segui \(p.numeroDelGiorno) di patrimonio \(p.didascaliaNumero): chiama chi aspetta una risposta o prepara le prossime revisioni."
        } else {
            let n = p.incontri.count
            let chi = p.incontri.prefix(3).map(\.chi).joined(separator: ", ")
            secondo = "\(n == 1 ? "Un incontro" : "\(n) incontri") in agenda: \(chi)\(n > 3 ? " e altri" : ""). Per ognuno trovi nel dossier le posizioni, gli obiettivi e le cifre già calcolate da Lucy."
        }
        return (primo, secondo)
    }

    /// Il tempo libero tra il primo e l'ultimo incontro, se c'è uno spazio di almeno due ore.
    static func tempoLibero(_ p: PrimaPagina) -> String? {
        let ore = p.incontri.map(\.ora).sorted()
        guard ore.count >= 2 else { return nil }
        for (a, b) in zip(ore, ore.dropFirst()) where b.timeIntervalSince(a) >= 3 * 3600 {
            let da = Formati.ora.string(from: a.addingTimeInterval(3600))
            return "Tra le \(da) e le \(Formati.ora.string(from: b)) sei libero: un buon momento per le telefonate."
        }
        return nil
    }

    static func notaDaScadenze(_ p: PrimaPagina) -> String {
        guard let s = p.scadenze.first else {
            return "Oggi nessuna scadenza vicina. Se vuoi, chiedimi chi ha liquidità ferma da più di sei mesi: è il primo posto da cui partire."
        }
        return "«\(s.posizione)» di \(s.cliente) scade il \(Formati.dataBreve.string(from: s.data)). Prima di quella data conviene sentirsi: ho già le cifre pronte nel dossier."
    }

    /// I compleanni dei clienti nei prossimi 21 giorni (giorno, nome, «compie N anni»).
    static func ricorrenze(_ clienti: [Cliente], da oggi: Date) -> [(String, String, String)] {
        let cal = Calendar.current
        let inizio = cal.startOfDay(for: oggi)
        var esito: [(Date, String, String)] = []
        for c in clienti {
            guard let n = c.dataNascita else { continue }
            let mg = cal.dateComponents([.month, .day], from: n)
            guard let prossimo = cal.nextDate(after: inizio.addingTimeInterval(-1), matching: mg, matchingPolicy: .nextTime),
                  prossimo.timeIntervalSince(inizio) <= 21 * 86_400 else { continue }
            let anni = cal.dateComponents([.year], from: n, to: prossimo).year ?? 0
            esito.append((prossimo, c.nome, "compie \(anni) anni"))
        }
        return esito.sorted { $0.0 < $1.0 }.prefix(3).map { (giornoMese($0.0), $0.1, $0.2) }
    }
}
#endif
