import SwiftUI

#if os(macOS)
// La scrivania dello stile Carta sul Mac, come il template (Design/template-carta.html; richiesta dell'utente del
// 25 novembre 2026: «più simile al template che ti avevo dato»):
// - a sinistra la data, «Buongiorno.» con la sottolineatura dorata, la frase del giorno, quanto patrimonio segui in
//   tutto, il Foglio di Lucy (che si apre a tutta pagina) e sotto la striscia dei mercati;
// - a destra «Oggi»: gli incontri e le cose da fare insieme (Agenda e attività unite), con la mossa del giorno in testa;
//   poi il turno di notte, le lettere da Lucy AI e la barra «Chiedi a Lucy».
// Niente canali (un solo canale, Lucy) e niente riquadro dello Studio sulla scrivania. Mai in modalità cliente: lì resta
// la scrivania di prima (porta nomi e cifre di tutti i clienti).

struct ScrivaniaCarta: View {
    @Environment(StatoShell.self) private var stato
    @State private var foglioAperto = false

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .top, spacing: 28) {
                ColonnaSinistraCarta(apriFoglio: { foglioAperto = true })
                    .frame(width: max(420, geo.size.width * 0.46), alignment: .topLeading)
                ColonnaDestraCarta()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 44)
            .padding(.top, 52)
            .padding(.bottom, 120)
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
        let riepilogo = stato.riepilogoTuttePosizioni
        let clienti = stato.clienti.count
        VStack(alignment: .leading, spacing: 0) {
            Text(Self.dataMaiuscola(oggi))
                .fontCarta(11, design: .monospaced)
                .tracking(2.2)
                .foregroundColor(TemaCarta.Colore.matitaD)
            TimelineView(.everyMinute) { contesto in
                Text(Self.saluto(contesto.date))
                    .fontCarta(64, weight: .semibold, design: .serif)
                    .tracking(-1.5)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .segnoCarta(.sottolinea, chiave: "scrivania.carta.saluto")
            }
            .padding(.top, 6)
            Text(Self.frase(incontri, stato: stato))
                .fontCarta(19, design: .serif, corsivo: true)
                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
            if clienti > 0 {
                Text("In tutto segui \(Formati.euro(riepilogo.attivita)) di patrimonio, per \(clienti) \(clienti == 1 ? "cliente" : "clienti").")
                    .fontCarta(14, weight: .medium)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .padding(.top, 10)
            }
            if !stato.inModoCliente {
                PrimaPaginaWidget()
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
                    .padding(.top, 22)
            }
            MercatiCarta()
                .padding(.top, 14)
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
private struct MercatiCarta: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        let serie = Array(stato.dati.mercato.serie.filter { $0.punti.count >= 1 }.prefix(5))
        Group {
            if serie.isEmpty {
                HStack(spacing: 10) {
                    Text("MERCATI")
                        .fontCarta(11, design: .monospaced).tracking(1.8)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                    Text("Nessun dato di mercato: accendili in Impostazioni › Mercato o importa un file.")
                        .fontCarta(12)
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    Spacer(minLength: 0)
                    Button("Apri Mercato") { stato.apri(.mercato) }
                        .buttonStyle(.plain)
                        .fontCarta(12, weight: .medium)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(serie.enumerated()), id: \.element.id) { i, s in
                        if i > 0 { Rectangle().fill(TemaCarta.Colore.filoD).frame(width: 1).padding(.vertical, 2) }
                        cella(s)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { stato.apri(.mercato) }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
    }

    private func cella(_ s: SerieMercato) -> some View {
        let ultimo = s.punti.last?.valore ?? 0
        let prima = s.punti.count >= 2 ? s.punti[s.punti.count - 2].valore : nil
        let variazione: Double? = prima.map { p in
            s.unita.variazioneInPercentuale ? (p == 0 ? 0 : (ultimo - p) / p * 100) : ultimo - p
        }
        return VStack(alignment: .leading, spacing: 3) {
            Text(s.nome.uppercased())
                .fontCarta(10, design: .monospaced).tracking(1.2)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .lineLimit(1)
            Text(Self.valore(ultimo, unita: s.unita))
                .fontCarta(20, weight: .medium, design: .serif)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let v = variazione {
                Text((v >= 0 ? "+" : "") + Formati.percentuale((v * 100).rounded() / 100) .replacingOccurrences(of: "%", with: s.unita.variazioneInPercentuale ? "%" : ""))
                    .fontCarta(11, design: .monospaced)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            OggiCarta()
            if !stato.inModoCliente {
                TurnoNotteWidget()
                LetteraPrismaAIWidget()
            }
            ChiediLucyCarta()
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
        let daFare = stato.attivitaAperte.filter { $0.scadenza < domani }.prefix(6)
        let mossa = stato.inModoCliente ? nil : stato.ricavato("scrivania.carta.mossa") { stato.mossaDelGiorno() }.mossa
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 11))
                Text(Self.titolo(incontri: incontri.count, daFare: daFare.count))
                    .fontCarta(11, design: .monospaced).tracking(1.8)
                Spacer(minLength: 0)
                Button("Apri l'agenda") { stato.apri(.agenda) }
                    .buttonStyle(.plain)
                    .fontCarta(12, weight: .medium)
                    .foregroundColor(TemaCarta.Colore.pennaD)
            }
            .foregroundColor(TemaCarta.Colore.matitaD)
            .padding(.bottom, 10)

            if let m = mossa {
                Button {
                    stato.clienteAttivoId = m.cliente.id
                    stato.posizioneInDettaglio = nil
                    stato.portafoglio = false
                    stato.apri(.posizioni)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("MOSSA")
                            .fontCarta(10, design: .monospaced).tracking(1.4)
                            .foregroundColor(TemaCarta.Colore.oroTestoD)
                            .frame(width: 48, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Chiama \(m.cliente.nome)")
                                .fontCarta(14, weight: .semibold)
                                .foregroundColor(TemaCarta.Colore.inchiostroD)
                            Text(m.motivo)
                                .fontCarta(12)
                                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 8)
                riga()
            }

            if incontri.isEmpty && daFare.isEmpty && mossa == nil {
                Text("Niente in agenda per oggi.")
                    .fontCarta(13)
                    .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    .padding(.vertical, 8)
            }

            ForEach(incontri) { a in
                Button {
                    if !a.clienteId.isEmpty { stato.clienteAttivoId = a.clienteId }
                    stato.apri(.agenda)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(Formati.ora.string(from: a.inizio))
                            .fontCarta(12, design: .monospaced)
                            .foregroundColor(TemaCarta.Colore.oroTestoD)
                            .frame(width: 48, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stato.cliente(a.clienteId)?.nome ?? a.titolo)
                                .fontCarta(14, weight: .medium)
                                .foregroundColor(TemaCarta.Colore.inchiostroD)
                                .lineLimit(1)
                            Text(a.luogo.isEmpty ? a.titolo : "\(a.titolo) · \(a.luogo)")
                                .fontCarta(12)
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
                    .frame(width: 48, alignment: .leading)
                    .accessibilityLabel(t.completata ? "Fatta" : "Da fare")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(t.titolo)
                            .fontCarta(14)
                            .foregroundColor(TemaCarta.Colore.inchiostroD)
                            .lineLimit(1)
                        if let nome = stato.cliente(t.clienteId)?.nome {
                            Text(nome)
                                .fontCarta(12)
                                .foregroundColor(TemaCarta.Colore.inchiostro2D)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 7)
                riga()
            }
        }
        .padding(20)
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

/// «Chiedi a Lucy»: la barra veloce del template (apre l'assistente).
private struct ChiediLucyCarta: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        Button { stato.apri(.vera) } label: {
            HStack(spacing: 14) {
                LogoLucy(colore: Color.dinamico(chiaro: Tema.Marca.avorio, scuro: Tema.Marca.inchiostro), oro: Tema.Marca.oro)
                    .frame(width: 18, height: 18)
                    .padding(9)
                    .background(Circle().fill(TemaCarta.Colore.inchiostroD))
                Text("Chiedi a Lucy: «chi ha liquidità ferma da più di sei mesi?»")
                    .fontCarta(16, design: .serif, corsivo: true)
                    .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("⌘K")
                    .fontCarta(11, design: .monospaced)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(TemaCarta.Colore.filo2D, lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
        .accessibilityLabel("Chiedi a Lucy")
    }
}

/// Il Foglio di Lucy a tutta pagina, sopra la scrivania: si chiude con la crocetta o con Esc.
private struct FoglioTuttaPagina: View {
    let chiudi: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SfondoCarta()
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    PrimaPaginaWidget()
                        .frame(maxWidth: 760)
                    TurnoNotteWidget()
                        .frame(maxWidth: 760)
                    LetteraPrismaAIWidget()
                        .frame(maxWidth: 760)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .padding(.horizontal, 40)
            }
            Button(action: chiudi) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(TemaCarta.Colore.schedaD))
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            .help("Chiudi il Foglio")
            .padding(24)
        }
    }
}
#endif
