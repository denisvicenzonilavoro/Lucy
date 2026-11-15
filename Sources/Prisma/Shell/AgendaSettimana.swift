#if os(macOS)
import SwiftUI

// Migliorie d'uso 18, «La settimana si vede tutta» (Design/uso/gruppo-03.md §18, template righe 3694-3720):
//
//         Oggi · lun 2   mar 3     mer 4     gio 5     ven 6    sab 7  dom 8
//         2 impegni      libero    1 impegno …                libero libero
//   ┌──────────────────────────────────────────────────────────────────────┐
//   │ 08:00 ─┬─────────┬─────────┬─────────┬─────────┬─────────┬──────┬──── │
//   │ 09:00  │▌Giulia  │         │▌Marco   │         │         │      │     │
//   │ 10:00 ●━━━━━━━━━━│         │         │         │         │      │     │  ← la riga dell'ora, solo oggi
//   │ 11:00  │▌Marco   │         │         │         │         │      │     │
//   └──────────────────────────────────────────────────────────────────────┘
//
// - La testata con i sette giorni («Oggi · lun 2» in rosso), sotto «libero», «1 impegno», «N impegni»: toccando un
//   giorno si apre in «Giorno».
// - Una card senza ombra con le ore a sinistra e sette colonne in un solo scorrimento verticale (le ore restano
//   allineate); sabato e domenica larghe 0,62 di una feriale; oggi su rosso al 5%, il fine settimana grigio leggero.
// - Ogni impegno al suo posto e alla sua altezza (min 38): nome in neretto, sotto «09:30 · In studio», «09:30 · da
//   chiudere» o «09:30 · ✓ concluso»; passato o chiuso, attenuato. Entrano dal basso a cascata; il tocco apre la
//   traccia dell'impegno come nella giornata.
// - Le righe di oggi si rifanno solo quando un impegno finisce (`TimelineView(.explicit)`), la riga dell'ora a ogni
//   minuto; nelle istantanee tutto alle 10:24 (`OraIstantanee`).
// - Il pulsante «Occasioni» della barra con il numero e il suo menu (le occasioni della finestra delle notifiche).

private typealias S = Tema.Apple.Agenda.SettimanaSette

// MARK: - La settimana

struct SettimanaAgendaApple: View {
    /// I sette giorni, da lunedì.
    let giorni: [Date]
    /// Gli impegni dei giorni (già filtrati per il cliente scelto).
    let indice: GiorniAgenda
    /// Toccando l'intestazione di un giorno: quel giorno in «Giorno».
    let apriGiorno: (Date) -> Void

    var body: some View {
        let _ = ContaCorpi.segna()
        let eventi = giorni.map { indice.appuntamenti($0) }
        // Le ore su tutta la settimana: un impegno alle 20 allarga tutte le colonne insieme
        let ore = OreAgendaApple.intervallo(eventi.flatMap { $0 })
        return GeometryReader { geo in
            let larghezze = Self.larghezze(giorni, totale: geo.size.width - S.rientroOre - S.margineDestro)
            VStack(spacing: 0) {
                testata(eventi, larghezze: larghezze)
                    .frame(height: S.altezzaTesta)
                    .entrataCascata(0, base: 0, sfocatura: false)
                griglia(eventi, ore: ore, larghezze: larghezze, larghezza: geo.size.width)
                    .padding(.top, S.spazioTesta)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
    }

    /// Le larghezze delle sette colonne: feriali uguali, sabato e domenica a 0,62 di una feriale.
    static func larghezze(_ giorni: [Date], totale: CGFloat) -> [CGFloat] {
        let cal = CalendarioAgenda.cal
        let festivi = giorni.filter { cal.isDateInWeekend($0) }.count
        let quote = CGFloat(giorni.count - festivi) + CGFloat(festivi) * S.quotaFestivo
        let feriale = quote > 0 ? max(0, totale) / quote : 0
        return giorni.map { cal.isDateInWeekend($0) ? feriale * S.quotaFestivo : feriale }
    }

    private func testata(_ eventi: [[Appuntamento]], larghezze: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: S.rientroOre)
            ForEach(Array(giorni.enumerated()), id: \.element) { i, g in
                IntestazioneGiornoSettimana(giorno: g, impegni: eventi[i].count) { apriGiorno(g) }
                    .frame(width: larghezze[i])
            }
            Color.clear.frame(width: S.margineDestro)
        }
    }

    private func griglia(_ eventi: [[Appuntamento]], ore: (prima: Int, ultima: Int), larghezze: [CGFloat],
                         larghezza: CGFloat) -> some View {
        let righe = CGFloat(ore.ultima - ore.prima) * S.altezzaOra
        let altezza = S.lineaSopra + righe + S.sottoUltima
        // Il primo indice della cascata di ogni colonna: gli impegni entrano in fila, da lunedì a domenica
        var primi: [Int] = []
        var conto = 0
        for e in eventi {
            primi.append(conto)
            conto += e.count
        }
        let primoIndice = primi
        let forma = RoundedRectangle(cornerRadius: S.raggio, style: .continuous)
        return ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                lineeOre(ore, larghezza: larghezza)
                HStack(spacing: 0) {
                    ForEach(Array(giorni.enumerated()), id: \.element) { i, g in
                        ColonnaGiornoSettimana(giorno: g, eventi: eventi[i], prima: ore.prima, ultima: ore.ultima,
                                               larghezza: larghezze[i], altezza: righe + S.sottoUltima,
                                               primoIndice: primoIndice[i])
                    }
                }
                .padding(.leading, S.rientroOre)
                .padding(.top, S.lineaSopra)
            }
            .frame(width: larghezza, height: altezza, alignment: .topLeading)
        }
        .clipShape(forma)
        .superficieApple(S.superficie, raggio: S.raggio)
    }

    /// Le righe delle ore, dalla colonna delle ore al bordo destro delle colonne.
    private func lineeOre(_ ore: (prima: Int, ultima: Int), larghezza: CGFloat) -> some View {
        ForEach(Array(ore.prima...ore.ultima), id: \.self) { o in
            let y = S.lineaSopra + CGFloat(o - ore.prima) * S.altezzaOra
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(S.linea)
                    .frame(width: max(0, larghezza - S.rientroOre - S.margineDestro), height: Tema.Apple.Misura.bordo)
                    .padding(.leading, S.rientroOre)
                    .padding(.top, y)
                Text(String(format: "%02d:00", o))
                    .carattereApple(S.ora)
                    .foregroundColor(S.coloreOra)
                    .padding(.leading, S.oraDalBordo)
                    .padding(.top, max(0, y - S.oraSopraLinea))
            }
            .frame(width: larghezza, alignment: .topLeading)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Intestazione di un giorno

/// «Oggi · lun 2» (oggi in rosso) o «mar 3», sotto «libero», «1 impegno», «N impegni». È un pulsante: apre il giorno.
struct IntestazioneGiornoSettimana: View {
    let giorno: Date
    let impegni: Int
    let azione: () -> Void
    @State private var sopra = false
    @Environment(\.modoIstantanea) private var istantanea
    @Environment(\.prismaCalmo) private var calmo

    var body: some View {
        let oggi = CalendarioAgenda.cal.isDateInToday(giorno)
        let forma = RoundedRectangle(cornerRadius: S.raggioIntestazione, style: .continuous)
        return Button(action: azione) {
            VStack(spacing: 0) {
                Text(TestiAgendaApple.intestazioneGiorno(giorno))
                    .carattereApple(S.intestazioneGiorno)
                    .foregroundColor(oggi ? S.coloreOggi : S.coloreGiorno)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(MomentoImpegno.notaGiorno(impegni))
                    .carattereApple(S.notaGiorno)
                    .foregroundColor(S.coloreNotaGiorno)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, S.paddingIntestazione)
            .frame(maxWidth: .infinity)
            .background { forma.fill(sopra ? S.fondoPassaggio : Color.clear) }
            .contentShape(forma)
            .padding(.horizontal, S.margineIntestazione)
        }
        .buttonStyle(.plain)
        .onHover { dentro in
            guard !istantanea else { return }
            withAnimation(calmo ? nil : S.animazionePassaggio) { sopra = dentro }
        }
        .help("Apri \(Formati.dataLunga.string(from: giorno)) in Giorno")
        .accessibilityLabel("\(Formati.dataLunga.string(from: giorno)), \(MomentoImpegno.notaGiorno(impegni))")
    }
}

// MARK: - Colonna di un giorno

/// Una colonna: il fondo (oggi, fine settimana), il filo a sinistra, gli impegni affiancati se si sovrappongono e,
/// oggi, la riga dell'ora.
struct ColonnaGiornoSettimana: View {
    let giorno: Date
    let eventi: [Appuntamento]
    let prima: Int
    let ultima: Int
    let larghezza: CGFloat
    let altezza: CGFloat
    let primoIndice: Int
    @Environment(\.modoIstantanea) private var istantanea

    var body: some View {
        let cal = CalendarioAgenda.cal
        let oggi = cal.isDateInToday(giorno)
        let festivo = cal.isDateInWeekend(giorno)
        return ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(oggi ? S.fondoOggi : (festivo ? S.fondoFestivo : Color.clear))
            Rectangle()
                .fill(S.filoColonna)
                .frame(width: Tema.Apple.Misura.bordo)
            impegniVivi(oggi: oggi)
            if oggi {
                if istantanea {
                    lineaOra(OreAgendaApple.ora(OraIstantanee.data(giorno)))
                } else {
                    TimelineView(.everyMinute) { contesto in
                        lineaOra(OreAgendaApple.ora(contesto.date))
                    }
                }
            }
        }
        .frame(width: larghezza, height: altezza, alignment: .topLeading)
    }

    /// Oggi gli impegni si rifanno solo quando uno di loro finisce («da chiudere» compare alla fine); negli altri
    /// giorni l'ora si legge una volta. Nelle istantanee l'ora ferma di oggi.
    @ViewBuilder private func impegniVivi(oggi: Bool) -> some View {
        if istantanea {
            impegni(adesso: OraIstantanee.data())
        } else if oggi {
            TimelineView(.explicit(MomentoImpegno.fini(eventi, dopo: Date()))) { _ in
                impegni(adesso: Date())
            }
        } else {
            impegni(adesso: Date())
        }
    }

    private func y(_ ora: Double) -> CGFloat { CGFloat(ora - Double(prima)) * S.altezzaOra }

    private func impegni(adesso: Date) -> some View {
        let posti = CorsieImpegni.disponi(eventi)
        let libera = max(0, larghezza - S.margineSinistro - S.margineDestroImpegno)
        return ZStack(alignment: .topLeading) {
            ForEach(Array(posti.enumerated()), id: \.element.evento.id) { i, p in
                let n = CGFloat(max(1, p.corsie))
                let w = max(0, (libera - S.spazioCorsie * (n - 1)) / n)
                let x = S.margineSinistro + CGFloat(p.corsia) * (w + S.spazioCorsie)
                let alto = max(0, y(OreAgendaApple.ora(p.evento.inizio))) + S.impegnoSopra
                let h = max(S.impegnoMinimo, CGFloat(p.evento.durataMinuti) / 60 * S.altezzaOra - S.impegnoStacco)
                ImpegnoSettimanaApple(evento: p.evento, larghezza: w, altezza: h, adesso: adesso)
                    .entrataStile(S.entrataImpegno, ritardo: S.ritardoImpegno(primoIndice + i))
                    .padding(.leading, x)
                    .padding(.top, alto)
            }
        }
        .frame(width: larghezza, alignment: .topLeading)
    }

    @ViewBuilder private func lineaOra(_ ora: Double) -> some View {
        if ora >= Double(prima) && ora <= Double(ultima) {
            LineaOraAgendaApple(larghezza: larghezza, pallino: S.pallinoOraSettimana)
                .padding(.top, max(0, y(ora) - S.pallinoOraSettimana / 2))
        }
    }
}

// MARK: - Impegno della settimana

/// La versione stretta dell'impegno della giornata: filo di 3 e fondo al 13% nel colore del cliente, il nome in
/// neretto su una riga, sotto l'ora d'inizio e il luogo, «da chiudere» o «✓ <esito>». Passato o chiuso, attenuato.
/// Si inclina come nella giornata e il tocco apre la traccia.
struct ImpegnoSettimanaApple: View {
    let evento: Appuntamento
    let larghezza: CGFloat
    let altezza: CGFloat
    let adesso: Date
    @Environment(StatoShell.self) var stato
    @Environment(\.statoDettaglioApple) private var dettaglio

    var body: some View {
        let _ = ContaCorpi.segna()
        let cliente = stato.cliente(evento.clienteId)
        let colore = Tema.Apple.Agenda.colore(cliente)
        let momento = MomentoImpegno.di(evento, adesso: adesso)
        let esito = momento == .chiuso ? MomentoImpegno.esitoBreve(evento, proposta: proposta) : nil
        let ora = Formati.ora.string(from: evento.inizio)
        let sotto = TestiAgendaApple.dopoOrario(momento, esito: esito, luogo: evento.luogo).map { "\(ora) · \($0)" } ?? ora
        let attenuato = MomentoImpegno.attenuato(evento, adesso: adesso)
        let canale = stato.canaleAppuntamento(evento)
        let forma = RoundedRectangle(cornerRadius: S.raggioImpegno, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(cliente?.nome ?? evento.titolo)
                    .carattereApple(S.nomeImpegno)
                    .foregroundColor(S.coloreNome)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if let canale, larghezza >= S.larghezzaConCanale {
                    EtichettaCanaleApple(canale: canale, compatta: true)
                }
            }
            Text(sotto)
                .carattereApple(S.sottoImpegno)
                .foregroundColor(S.coloreSotto)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(S.paddingImpegno)
        .padding(.leading, S.filoImpegno)
        .frame(width: larghezza, height: altezza, alignment: .topLeading)
        .background {
            ZStack(alignment: .leading) {
                forma.fill(colore.opacity(S.opacitaFondo))
                Rectangle()
                    .fill(colore)
                    .frame(width: S.filoImpegno)
            }
            .clipShape(forma)
        }
        .opacity(attenuato ? S.opacitaPassato : 1)
        .contentShape(forma)
        .onTapGesture(perform: apri)
        .inclinazione(massimo: S.inclinazione, raggio: S.raggioImpegno)
        .origineDettaglio(id: TracciaImpegnoApple.id(per: evento.id))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { apri() }
    }

    /// La proposta collegata, dalle posizioni del cliente (già tenute da parte): solo per un impegno chiuso.
    private var proposta: Posizione? {
        guard evento.stato == .concluso, let pid = evento.posizioneId else { return nil }
        return stato.posizioniCliente(evento.clienteId).first { $0.id == pid }
    }

    private func apri() {
        // Come nella giornata: i punti da toccare si preparano prima che la traccia si monti
        if let dettaglio, !dettaglio.aperto { _ = stato.puntiDaToccare(evento) }
        dettaglio?.apri(TracciaImpegnoApple.id(per: evento.id), misura: Tema.Apple.Agenda.Traccia.misura)
    }
}

// MARK: - Il pulsante «Occasioni»

extension StatoShell {
    /// Le occasioni prossime per il pulsante «Occasioni» dell'Agenda: da oggi a oggi + l'anticipo delle notifiche
    /// (Impostazioni › Promemoria e occasioni, 30 giorni di base), del cliente scelto. Il giorno sta già nella validità
    /// della cache comune; nella chiave il cliente e l'anticipo.
    var occasioniProssimeAgenda: [Occasione] {
        let anticipo = dati.impostazioniDeiCalcoli.occasioni.anticipoGiorni
        let filtro = filtroClienteAgenda
        return ricavato("agenda-occasioni-prossime|\(filtro ?? "-")|\(anticipo)") { () -> [Occasione] in
            let cal = Calendar.current
            let oggi = cal.startOfDay(for: Date())
            let fine = cal.date(byAdding: .day, value: anticipo + 1, to: oggi) ?? oggi
            return occasioni(da: oggi, a: fine).filter { filtro == nil || $0.clienteId == filtro }
        }
    }

    /// Da una riga del menu: l'occasione nella vista «Occasioni» su oggi, senza toccare il cliente scelto (non passa
    /// da `mostraOccasione`, che lo azzera). Lì si fissa l'impegno o l'attività come sempre.
    func apriOccasioneDaPulsante(_ o: Occasione?) {
        giornoAgenda = Calendar.current.startOfDay(for: Date())
        gruppoOccasioniAgenda = nil
        vistaAgenda = .occasioni
        appuntamentoSelezionato = nil
        attivitaSelezionata = nil
        occasioneSelezionata = o
    }
}

/// «Occasioni» nella barra dell'Agenda, con il numero nel piccolo tondo quando ce ne sono; al tocco il menu con una riga
/// per occasione («<nome> · <occasione>») e in fondo «Tutte le occasioni ›».
struct PulsanteOccasioniAgenda: View {
    @Environment(StatoShell.self) var stato
    /// Solo l'icona (barra compatta).
    var compatto = false
    @State private var aperto = false

    init(compatto: Bool = false) {
        self.compatto = compatto
    }

    var body: some View {
        let elenco = stato.occasioniProssimeAgenda
        return Button { aperto.toggle() } label: {
            HStack(spacing: S.spazioNumeroOccasioni) {
                if compatto {
                    Image(systemName: "sparkles")
                } else {
                    Text(TestiAgendaApple.occasioni)
                }
                if !elenco.isEmpty {
                    Text("\(elenco.count)")
                        .carattereApple(S.numeroOccasioni)
                        .foregroundColor(S.coloreNumeroOccasioni)
                        .padding(S.paddingNumeroOccasioni)
                        .background { Capsule(style: .continuous).fill(S.fondoNumeroOccasioni) }
                }
            }
        }
        .buttonStyle(.apple)
        .fixedSize()
        .help("Le occasioni dei prossimi giorni")
        .accessibilityLabel(elenco.isEmpty ? TestiAgendaApple.occasioni : "\(TestiAgendaApple.occasioni), \(elenco.count)")
        .popover(isPresented: $aperto, arrowEdge: .bottom) { menu(elenco) }
    }

    private func menu(_ elenco: [Occasione]) -> some View {
        let mostrate = Array(elenco.prefix(S.massimoMenu))
        return VStack(alignment: .leading, spacing: S.spazioMenu) {
            if mostrate.isEmpty {
                Text(TestiAgendaApple.nessunaOccasione)
                    .carattereApple(S.rigaMenu)
                    .foregroundColor(S.coloreVuotoMenu)
            }
            ForEach(mostrate) { o in
                Button {
                    aperto = false
                    stato.apriOccasioneDaPulsante(o)
                } label: {
                    (Text(stato.cliente(o.clienteId)?.nome ?? "").font(S.nomeMenu.font)
                        + Text(" · " + o.titolo).font(S.rigaMenu.font))
                        .foregroundColor(S.coloreRigaMenu)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(StileSemplice())
            }
            Button {
                aperto = false
                stato.apriOccasioneDaPulsante(nil)
            } label: {
                Text(TestiAgendaApple.tutteLeOccasioni + " ›")
                    .carattereApple(S.rigaMenu)
                    .foregroundColor(S.coloreTutte)
            }
            .buttonStyle(StileSemplice())
            .padding(.top, mostrate.isEmpty ? 0 : S.spazioMenu / 2)
        }
        .padding(S.paddingMenu)
        .frame(width: S.larghezzaMenu, alignment: .leading)
    }
}
#endif
