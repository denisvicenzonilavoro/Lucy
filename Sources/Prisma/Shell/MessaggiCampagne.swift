import SwiftUI

// Messaggi › Campagne (Design/template-luce-specifica.md §9.4, «Luce» giro 12):
//
//   ┌ 32 CLIENTI · 4 GRUPPI CON LO STESSO BISOGNO ──────────────┐ ┌ CAMPAGNA ─────────────────────────┐
//   │      ( ·· · )        ( · ··· )                             │ │ Fondo pensione fermo da un anno   │
//   │   Famiglia senza     Titoli di Stato in                    │ │ 7 clienti · Marco, Giulia e altri │
//   │   protezione         scadenza a marzo                      │ │ [Cordiale|Formale|Breve] [Mail|…] │
//   │      ( ·· )          ( ·· )                                │ │ anteprima del messaggio           │
//   └────────────────────────────────────────────────────────────┘ │ APPUNTAMENTI DA PROPORRE (chip)   │
//   Campagne avviate · 2 ottobre · …                               │ ☑ Marco … ☐ Giulia (senza consenso)│
//                                                                  │ [Avvia la campagna]               │
//                                                                  └───────────────────────────────────┘
//
// - Gruppi, membri, cifre e testi vengono da MotoreCampagne (solo bisogni dei motori, decisione 97) e da ModelliMessaggi
//   (il modello fisso, con le cifre di quel cliente); qui solo la disposizione.
// - Mappa: un solo `Canvas` per pallini e cerchi; i pallini partono da posizioni stabili (seme dall'id) e si radunano
//   (attesa 0,7 s, raduno 1,6 s); clic in un punto del gruppo lo sceglie; ⌘-clic su un avatar apre il dossier; passaggio
//   su un pallino (Mac): il nome e «anche in: …»; frecce ↑↓ fra i gruppi.
// - «Avvia la campagna» crea le bozze (decisione 15): niente si apre da solo; «Apri la prossima», «Apri tutte» con
//   conferma oltre 5, «Annulla la campagna» finché nessuna bozza è aperta, «Fai riscrivere a Vera» uno alla volta.
// - iPad (`solaLettura`): mappa e gruppi da guardare, niente avvio.
// - Migliorie d'uso 49 (solo Mac, Design/uso/gruppo-08.md §49): il pannello in tre passi numerati, «1 · Chi» (la
//   casella quadrata, tutta la riga include o esclude, le prime otto righe e «Mostra tutti»), «2 · Cosa scrivi» (Tono,
//   Invia con, «Anteprima per …»), «3 · Quando» (capsule accese o spente); sotto, fermo, il pulsante a tutta larghezza
//   che dice quanti messaggi prepara o perché è spento, e «Niente parte da solo…». Dopo: «✓ pronto in Messaggi» riga
//   per riga e «Apri i messaggi preparati» (Messaggi sulla prima bozza). Con un cliente nella barra si apre il suo gruppo.

/// Il segmentato «Messaggi · Campagne» nella testata di Messaggi.
struct AzioniMessaggi: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        SegmentatoPillola(selezione: Bindable(stato).vistaMessaggi, valori: VistaMessaggi.allCases, titolo: { $0.titolo })
            .fixedSize()
    }
}

struct VistaCampagne: View {
    @Environment(StatoShell.self) var stato

    private typealias C = Tema.Apple.Campagne

    var body: some View {
        let _ = ContaCorpi.segna()
        let gruppi = stato.gruppiCampagne()
        let scelto = gruppi.first { $0.id == stato.campagne.gruppo } ?? gruppi.first
        let nonValutate = MotoreCampagne.previdenzeNonValutate(dati: stato.datiDeiCalcoli())
        return Group {
            if gruppi.isEmpty {
                VuotoCampagne(nonValutate: nonValutate)
            } else {
                GeometryReader { g in
                    let larghezzaMappa = min(C.larghezzaMappa, g.size.width * C.quotaMappa)
                    HStack(alignment: .top, spacing: C.spazio) {
                        VStack(alignment: .leading, spacing: C.spazio) {
                            MappaCampagne(gruppi: gruppi, scelto: scelto?.id, clienti: stato.dati.clienti) { id in
                                stato.campagne.scegli(id)
                            } apriDossier: { id in
                                stato.clienteAttivoId = id
                                stato.schedaCliente = .panoramica
                                stato.vistaClienti = .rubrica
                                stato.apri(.clienti)
                            }
                            .frame(width: larghezzaMappa)
                            .frame(maxHeight: .infinity)
                            piede(gruppi: gruppi, nonValutate: nonValutate)
                                .frame(width: larghezzaMappa, alignment: .leading)
                        }
                        if let gruppoScelto = scelto {
                            PannelloCampagna(gruppo: gruppoScelto)
                                .id(gruppoScelto.id)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                }
            }
        }
        .padding(C.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        #if os(macOS)
        .onAppear { scegliGruppoDelCliente() }
        #endif
    }

    #if os(macOS)
    /// Migliorie d'uso 49: con un cliente scelto nella barra e nessun gruppo ancora scelto, la campagna che si apre è
    /// quella del primo gruppo che lo contiene. La mappa continua a mostrare tutti i clienti (decisione 50 di «Luce»).
    private func scegliGruppoDelCliente() {
        guard stato.campagne.gruppo == nil, !stato.tuttiIClienti else { return }
        let id = stato.clienteAttivoId
        if let g = stato.gruppiCampagne().first(where: { g in g.membri.contains { $0.clienteId == id } }) {
            stato.campagne.scegli(g.id)
        }
    }
    #endif

    @ViewBuilder private func piede(gruppi: [GruppoCampagna], nonValutate: Int) -> some View {
        let altri = MotoreCampagne.disposizione(gruppi).altri
        VStack(alignment: .leading, spacing: C.spazio / 2) {
            if !altri.isEmpty {
                HStack(spacing: C.spazio / 2) {
                    Text(TestiCampagne.altriBisogni + ":")
                        .carattereApple(C.nota).foregroundColor(C.coloreNota)
                    ForEach(altri) { g in
                        Button(g.titolo + " · " + TestiCampagne.contoGruppo(g.membri.count)) { stato.campagne.scegli(g.id) }
                            .buttonStyle(.appleSobrio)
                    }
                }
            }
            if nonValutate > 0 {
                Text(TestiCampagne.nonValutati(nonValutate)).carattereApple(C.nota).foregroundColor(C.coloreNota)
            }
            Text(TestiCampagne.regoleDaApprovare).carattereApple(C.nota).foregroundColor(Tema.Apple.Colore.inchiostro3)
                .fixedSize(horizontal: false, vertical: true)
            StoricoCampagne()
        }
    }
}

// MARK: - Mappa

struct MappaCampagne: View {
    let gruppi: [GruppoCampagna]
    let scelto: String?
    let clienti: [Cliente]
    let scegli: (String) -> Void
    let apriDossier: (String) -> Void

    @Environment(\.prismaStatoFinale) private var statoFinale
    @Environment(\.prismaCalmo) private var calmo
    @State private var radunati = false
    @State private var sotto: String?

    private typealias C = Tema.Apple.Campagne

    var body: some View {
        let disposti = MotoreCampagne.disposizione(gruppi).inMappa
        let nelleMappe = Set(gruppi.flatMap { $0.membri.map(\.clienteId) })
        let liberi = clienti.filter { !nelleMappe.contains($0.id) }.map(\.id)
        GeometryReader { g in
            let misura = g.size
            let scala = min(1, min(misura.width / C.larghezzaMappa, misura.height / C.altezzaMappa))
            ZStack(alignment: .topLeading) {
                PalliniCampagne(disposti: disposti, liberi: liberi, scelto: scelto, scala: scala,
                                progresso: (radunati || statoFinale) ? 1 : 0)
                ForEach(disposti.indices, id: \.self) { i in
                    let voce = disposti[i]
                    etichetta(voce.0, centro: punto(voce.1, misura), raggio: CGFloat(MotoreCampagne.raggio(membri: voce.0.membri.count)) * scala)
                }
                Text(TestiCampagne.etichettaMappa(clienti: clienti.count, gruppi: gruppi.count))
                    .carattereApple(C.etichetta)
                    .foregroundColor(C.coloreEtichetta)
                    .padding(C.etichettaMargine)
            }
            .contentShape(Rectangle())
            .onTapGesture(coordinateSpace: .local) { p in
                if let id = gruppo(in: p, disposti: disposti, misura: misura, scala: scala) { scegli(id) }
            }
            #if os(macOS)
            .onContinuousHover(coordinateSpace: .local) { fase in
                switch fase {
                case .active(let p): sotto = pallino(in: p, disposti: disposti, misura: misura, scala: scala)
                case .ended: sotto = nil
                }
            }
            .help(sotto ?? "")
            #endif
        }
        .background(RadialGradient(colors: [Tema.Apple.Colore.chip, .clear], center: UnitPoint(x: 0.5, y: 0.45),
                                   startRadius: 0, endRadius: C.raggioFondo))
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
        .clipShape(RoundedRectangle(cornerRadius: Tema.Apple.Superficie.cardPiatta.raggio, style: .continuous))
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(.downArrow) { passa(1, disposti: disposti) }
        .onKeyPress(.upArrow) { passa(-1, disposti: disposti) }
        .onAppear {
            guard !statoFinale, !radunati else { return }
            withAnimation(Tema.Apple.Moto.animazione(Tema.Apple.Moto.Campagne.raduno, calmo: calmo)
                .ritardoPrisma(calmo ? 0 : Tema.Apple.Moto.Campagne.attesa)) {
                radunati = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(TestiCampagne.etichettaMappa(clienti: clienti.count, gruppi: gruppi.count))
    }

    private func punto(_ p: CGPoint, _ misura: CGSize) -> CGPoint {
        CGPoint(x: p.x * misura.width, y: p.y * misura.height)
    }

    /// Il nome, il conto e gli avatar sotto il cerchio (clic = sceglie il gruppo; ⌘-clic su un avatar = il dossier).
    private func etichetta(_ g: GruppoCampagna, centro: CGPoint, raggio: CGFloat) -> some View {
        VStack(spacing: C.spazio / 3) {
            HStack(spacing: -C.bordoAvatar * 2) {
                ForEach(g.membri.prefix(C.avatarMassimi)) { m in
                    if let c = clienti.first(where: { $0.id == m.clienteId }) {
                        AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: C.avatar)
                            .overlay(Circle().strokeBorder(Tema.Apple.Colore.card, lineWidth: C.bordoAvatar))
                            #if os(macOS)
                            // ⌘-clic sull'avatar: il dossier (sul Mac; l'iPad è in sola lettura)
                            .simultaneousGesture(TapGesture().modifiers(.command).onEnded { apriDossier(c.id) })
                            #endif
                            .help(c.nome + (m.anchein.isEmpty ? "" : " · " + TestiCampagne.ancheIn(m.anchein)))
                    }
                }
            }
            Text(g.titolo).carattereApple(C.nomeGruppo).foregroundColor(Tema.Apple.Colore.inchiostro).lineLimit(1)
            Text(TestiCampagne.contoGruppo(g.membri.count)).carattereApple(C.contoGruppo).foregroundColor(Tema.Apple.Colore.inchiostro2)
            if g.membri.count > RegoleCampagne.massimoPallini {
                Text("+ \(g.membri.count - RegoleCampagne.massimoPallini)").carattereApple(C.contoGruppo)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
            }
        }
        .fixedSize()
        .position(x: centro.x, y: centro.y + raggio + C.sottoCerchio + C.avatar)
        .opacity(scelto == nil || scelto == g.id ? 1 : C.opacitaGruppoAltro)
        .onTapGesture { scegli(g.id) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(scelto == g.id ? [.isButton, .isSelected] : .isButton)
    }

    private func gruppo(in p: CGPoint, disposti: [(GruppoCampagna, CGPoint)], misura: CGSize, scala: CGFloat) -> String? {
        disposti.first { voce in
            let c = punto(voce.1, misura)
            let r = CGFloat(MotoreCampagne.raggio(membri: voce.0.membri.count)) * scala + C.sottoCerchio + C.avatar * 2
            return hypot(p.x - c.x, p.y - c.y) <= r
        }?.0.id
    }

    /// Il pallino sotto il puntatore: il nome del cliente e «anche in: …».
    private func pallino(in p: CGPoint, disposti: [(GruppoCampagna, CGPoint)], misura: CGSize, scala: CGFloat) -> String? {
        for (g, centro) in disposti {
            let c = punto(centro, misura)
            for (i, m) in g.membri.prefix(RegoleCampagne.massimoPallini).enumerated() {
                let q = PalliniCampagne.arrivo(i, di: g.membri.count, centro: c,
                                               raggio: CGFloat(MotoreCampagne.raggio(membri: g.membri.count)) * scala)
                if hypot(p.x - q.x, p.y - q.y) <= C.pallino * 1.5 {
                    let nome = clienti.first { $0.id == m.clienteId }?.nome ?? ""
                    return m.anchein.isEmpty ? nome : nome + " · " + TestiCampagne.ancheIn(m.anchein)
                }
            }
        }
        return nil
    }

    private func passa(_ verso: Int, disposti: [(GruppoCampagna, CGPoint)]) -> KeyPress.Result {
        let ids = disposti.map { $0.0.id }
        guard !ids.isEmpty else { return .ignored }
        let i = scelto.flatMap { ids.firstIndex(of: $0) } ?? -verso
        scegli(ids[(i + verso + ids.count) % ids.count])
        return .handled
    }
}

/// I pallini e i cerchi dei gruppi in un solo `Canvas`: `progresso` va da 0 (posizioni di partenza stabili) a 1
/// (radunati nei gruppi) e SwiftUI lo anima (`Animatable`).
private struct PalliniCampagne: View, Animatable {
    let disposti: [(GruppoCampagna, CGPoint)]
    let liberi: [String]
    let scelto: String?
    let scala: CGFloat
    var progresso: Double

    var animatableData: Double {
        get { progresso }
        set { progresso = newValue }
    }

    private typealias C = Tema.Apple.Campagne

    /// Il punto d'arrivo dell'i-esimo pallino di un gruppo: a spirale (angolo aureo) dentro il cerchio.
    static func arrivo(_ i: Int, di n: Int, centro: CGPoint, raggio: CGFloat) -> CGPoint {
        let quanti = max(1, min(n, RegoleCampagne.massimoPallini))
        let r = raggio * C.riempimentoCerchio * CGFloat((Double(i) + 0.5) / Double(quanti)).squareRoot()
        let angolo = Double(i) * C.angoloAureo
        return CGPoint(x: centro.x + r * CGFloat(cos(angolo)), y: centro.y + r * CGFloat(sin(angolo)))
    }

    var body: some View {
        Canvas { ctx, misura in
            let t = CGFloat(Tema.Apple.Moto.Curva.quartica(progresso))
            func partenza(_ chiave: String) -> CGPoint {
                let s = MotoreCampagne.seme(chiave)
                return CGPoint(x: CGFloat(MotoreCampagne.casuale(s, 0)) * misura.width,
                               y: CGFloat(MotoreCampagne.casuale(s, 1)) * misura.height)
            }
            for (g, posizione) in disposti {
                let centro = CGPoint(x: posizione.x * misura.width, y: posizione.y * misura.height)
                let raggio = CGFloat(MotoreCampagne.raggio(membri: g.membri.count)) * scala
                let tinta = C.tinta(g.tipo)
                let cerchio = Path(ellipseIn: CGRect(x: centro.x - raggio, y: centro.y - raggio, width: raggio * 2, height: raggio * 2))
                let tratto = scelto == nil ? C.tratto : (scelto == g.id ? C.trattoScelto : C.trattoAltri)
                ctx.fill(cerchio, with: .color(tinta.opacity(C.fondoGruppo * Double(t))))
                ctx.stroke(cerchio, with: .color(tinta.opacity(tratto * Double(t))),
                           style: StrokeStyle(lineWidth: C.spessoreTratto, dash: C.tratteggio))
                for (i, m) in g.membri.prefix(RegoleCampagne.massimoPallini).enumerated() {
                    let da = partenza(g.id + "|" + m.clienteId)
                    let a = Self.arrivo(i, di: g.membri.count, centro: centro, raggio: raggio)
                    let p = CGPoint(x: da.x + (a.x - da.x) * t, y: da.y + (a.y - da.y) * t)
                    let lato = C.pallino
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - lato / 2, y: p.y - lato / 2, width: lato, height: lato)),
                             with: .color(tinta.opacity(m.consenso ? C.opacitaPallino : C.opacitaPallino * 0.5)))
                }
            }
            for id in liberi.prefix(RegoleCampagne.massimoPallini) {
                let p = partenza("libero|" + id)
                let lato = C.pallinoLibero
                ctx.fill(Path(ellipseIn: CGRect(x: p.x - lato / 2, y: p.y - lato / 2, width: lato, height: lato)),
                         with: .color(C.coloreLibero.opacity(C.opacitaLibero)))
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Pannello della campagna

struct PannelloCampagna: View {
    let gruppo: GruppoCampagna
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaStatoFinale) private var statoFinale

    private typealias C = Tema.Apple.Campagne

    private var modificabile: Bool { !stato.solaLettura }

    #if os(macOS)
    /// «Mostra tutti» nel passo «Chi», oltre le prime `C.righeVisibili` righe (si azzera cambiando gruppo: la vista ha
    /// l'id del gruppo).
    @State private var tutti = false
    #endif

    var body: some View {
        let c = stato.campagne
        let g = gruppo
        let canale = c.canale
        let campagnaAvviata = c.avviata.flatMap { id in stato.dati.campagne.first { $0.id == id } }
        let bozze = campagnaAvviata.map { stato.messaggiCampagna($0.id) } ?? []
        let inclusi = g.membri.filter { incluso($0, canale: canale) }
        let spazi = stato.spaziCampagna()
        let orari = spazi.map(\.inizio).filter { !c.chipTolti.contains($0) }
        let misti = inclusi.contains { $0.canaleLavoro == nil }
        let fittizi = g.membri.contains { $0.clienteId.hasPrefix(ClientiFittizi.prefisso) || StatoShell.clientiDiProva.contains($0.clienteId) }
        #if os(macOS)
        // Migliorie d'uso 49: la campagna in tre passi, con il pulsante sempre in vista sotto
        // L'anteprima è del cliente scelto con «Vedi il messaggio» o del primo incluso; senza inclusi lo dice il passo 2
        // (dopo l'avvio quello della prima bozza)
        let primaBozza = bozze.first.flatMap { b in g.membri.first { $0.clienteId == b.clienteId } }
        let anteprimaMac = g.membri.first { $0.clienteId == c.anteprima } ?? inclusi.first ?? primaBozza
        return cornice(corpoMac(g, inclusi: inclusi, spazi: spazi, orari: orari, misti: misti, anteprimaMembro: anteprimaMac,
                                avviata: campagnaAvviata, bozze: bozze, fittizi: fittizi))
        #else
        let anteprimaMembro = g.membri.first { $0.clienteId == c.anteprima } ?? inclusi.first ?? g.membri.first
        let nomi = g.membri.compactMap { m in stato.cliente(m.clienteId)?.nome }
        return cornice(ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: C.spazio) {
                VStack(alignment: .leading, spacing: C.spazio / 3) {
                    Text(TestiCampagne.campagna).carattereApple(C.etichetta).foregroundColor(C.coloreEtichetta)
                    Text(g.titolo).carattereApple(C.titolo).foregroundColor(Tema.Apple.Colore.inchiostro)
                    Text(TestiCampagne.sottotitolo(nomi: nomi) + (fittizi ? " " + TestiCampagne.tra : ""))
                        .carattereApple(C.sottotitolo).foregroundColor(Tema.Apple.Colore.inchiostro2)
                    if let nota = g.notaNonValutati {
                        Text(nota).carattereApple(C.nota).foregroundColor(C.coloreNota)
                    }
                }
                if modificabile && campagnaAvviata == nil {
                    HStack(spacing: C.spazio) {
                        SegmentatoPillola(selezione: Bindable(c).tono, valori: TonoMessaggio.allCases, titolo: { $0.nome })
                            .fixedSize()
                        SegmentatoPillola(selezione: Bindable(c).canale, valori: CanaleMessaggio.allCases, titolo: { $0.nome })
                            .fixedSize()
                    }
                }
                if let m = anteprimaMembro,
                   let pronto = stato.testoCampagna(g, membro: m, campagnaId: "anteprima", appuntamenti: orari, tono: c.tono,
                                                    canale: canale, firmaCanale: c.firmaCanale) {
                    anteprima(pronto.1, membro: m)
                }
                chip(spazi: spazi)
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(g.membri.enumerated()), id: \.element.id) { i, m in
                        RigaMembroCampagna(membro: m, cliente: stato.cliente(m.clienteId), incluso: incluso(m, canale: canale),
                                           canale: canale, bozza: bozze.first { $0.clienteId == m.clienteId },
                                           indice: i, modificabile: modificabile && campagnaAvviata == nil,
                                           inScrittura: bozze.first { $0.clienteId == m.clienteId }.map { c.inScrittura.contains($0.id) } ?? false,
                                           veraPronta: stato.disponibilitaLocale.pronto,
                                           cambia: { cambia(m, canale: canale) },
                                           vedi: { c.anteprima = m.clienteId },
                                           apri: { id in _ = stato.apriBozzaCampagna(id) },
                                           riscrivi: { id in stato.riscriviConVera(id) },
                                           ferma: { stato.fermaVeraCampagna() })
                    }
                }
                if modificabile { piede(g, inclusi: inclusi, orari: orari, misti: misti, avviata: campagnaAvviata, bozze: bozze) }
                if !stato.disponibilitaLocale.pronto {
                    Text(TestiCampagne.veraNonPronta).carattereApple(C.nota).foregroundColor(C.coloreNota)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(C.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        })
        #endif
    }

    /// La superficie del pannello e la richiesta di conferma (uguali sul Mac e sull'iPad).
    private func cornice<V: View>(_ contenuto: V) -> some View {
        let c = stato.campagne
        return contenuto
            .superficieApple(Tema.Apple.Superficie.cardPiatta)
            .confirmationDialog(testoConferma(c.conferma), isPresented: Binding(get: { c.conferma != nil }, set: { if !$0 { c.conferma = nil } }),
                                titleVisibility: .visible) {
                Button("Conferma") { conferma(c.conferma) }
                Button("Annulla", role: .cancel) { c.conferma = nil }
            }
    }

    // MARK: Parti

    private func anteprima(_ t: TestoMessaggio, membro m: MembroCampagna) -> some View {
        VStack(alignment: .leading, spacing: C.spazio / 2) {
            if let o = t.oggetto, stato.campagne.canale == .mail {
                Text(o).carattereApple(C.nomeRiga).foregroundColor(Tema.Apple.Colore.inchiostro)
            }
            Text(t.completo)
                .carattereApple(C.anteprima)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .padding(C.paddingAnteprima)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: C.raggioAnteprima, style: .continuous).fill(C.fondoAnteprima))
        .accessibilityLabel("Anteprima del messaggio a " + (stato.cliente(m.clienteId)?.nome ?? ""))
    }

    @ViewBuilder private func chip(spazi: [SpazioLibero]) -> some View {
        VStack(alignment: .leading, spacing: C.spazio / 2) {
            Text(TestiCampagne.appuntamenti).carattereApple(C.etichetta).foregroundColor(C.coloreEtichetta)
            if spazi.isEmpty {
                Text(TestiCampagne.agendaPiena).carattereApple(C.nota).foregroundColor(C.coloreNota)
            } else {
                HStack(spacing: C.spazio / 2) {
                    ForEach(spazi, id: \.inizio) { s in
                        let tolto = stato.campagne.chipTolti.contains(s.inizio)
                        Button {
                            if tolto { stato.campagne.chipTolti.remove(s.inizio) } else { stato.campagne.chipTolti.insert(s.inizio) }
                        } label: {
                            Text(TestiCampagne.chip(s.inizio))
                                .carattereApple(C.chip)
                                .strikethrough(tolto)
                                .foregroundColor(tolto ? Tema.Apple.Colore.inchiostro3 : Tema.Apple.Colore.inchiostro)
                                .padding(C.paddingChip)
                                .background(Capsule().fill(C.fondoChip))
                        }
                        .buttonStyle(.plain)
                        .disabled(!modificabile || stato.campagne.avviata != nil)
                        .help(tolto ? "Rimettilo fra gli orari proposti" : "Toglilo dagli orari proposti (l'Agenda non si blocca)")
                    }
                }
            }
        }
    }

    @ViewBuilder private func piede(_ g: GruppoCampagna, inclusi: [MembroCampagna], orari: [Date], misti: Bool,
                                    avviata: Campagna?, bozze: [MessaggioCliente]) -> some View {
        let c = stato.campagne
        VStack(alignment: .leading, spacing: C.spazio / 2) {
            if let a = avviata {
                let daAprire = bozze.filter { $0.stato == .bozza }
                Text(TestiCampagne.pronti(bozze.count)).carattereApple(C.nomeRiga).foregroundColor(C.pronta)
                HStack(spacing: C.spazio / 2) {
                    Button(TestiCampagne.apriProssima) { _ = stato.apriProssimaBozza(a.id) }
                        .buttonStyle(.applePrimario)
                        .disabled(daAprire.isEmpty)
                    Button(TestiCampagne.apriTutte) {
                        if daAprire.count > RegoleCampagne.aperturaSenzaConferma {
                            c.conferma = .apriTutte(campagna: a.id, quante: daAprire.count)
                        } else {
                            stato.apriTutteLeBozze(a.id)
                        }
                    }
                    .buttonStyle(.apple)
                    .disabled(daAprire.isEmpty)
                    if daAprire.count == bozze.count {
                        Button(TestiCampagne.annulla) { _ = stato.annullaCampagna(a.id) }
                            .buttonStyle(.appleSobrio)
                    }
                }
            } else {
                let senzaConsenso = g.membri.filter { !$0.consenso && !incluso($0, canale: c.canale) }.count
                let senzaRecapito = g.membri.filter { !$0.recapito(c.canale) }.count
                if misti {
                    HStack(spacing: C.spazio / 2) {
                        Text(TestiCampagne.sceltaFirma).carattereApple(C.nota).foregroundColor(C.coloreNota)
                        MenuTendina(selezione: Bindable(c).firmaCanale,
                                    opzioni: [(Canale?.none, "Da scegliere")] + Canale.allCases.map { (Optional($0), "Firma " + $0.nomeBreve) },
                                    larghezza: C.larghezzaPannello / 2)
                    }
                }
                Text(TestiCampagne.notaPulsante(inclusi: inclusi.count, senzaConsenso: senzaConsenso, senzaRecapito: senzaRecapito))
                    .carattereApple(C.nota).foregroundColor(C.coloreNota)
                Button(TestiCampagne.avvia) {
                    if let nuova = stato.avviaCampagna(g, inclusi: inclusi.map(\.clienteId), appuntamenti: orari, tono: c.tono,
                                                       canale: c.canale, firmaCanale: c.firmaCanale) {
                        c.avviata = nuova.id
                        stato.mostraAvviso(TestiCampagne.toastPronte(nuova.messaggi.count))
                    }
                }
                .buttonStyle(.applePrimarioGrande)
                .disabled(inclusi.isEmpty || (misti && c.firmaCanale == nil))
            }
        }
        .padding(.top, C.marginePulsante.top / 2)
    }

    #if os(macOS)
    // MARK: Migliorie d'uso 49 (solo Mac): la campagna in tre passi

    /// Testata, «1 · Chi», «2 · Cosa scrivi», «3 · Quando» che scorrono; sotto, fermo, il pulsante a tutta larghezza.
    private func corpoMac(_ g: GruppoCampagna, inclusi: [MembroCampagna], spazi: [SpazioLibero], orari: [Date], misti: Bool,
                          anteprimaMembro: MembroCampagna?, avviata: Campagna?, bozze: [MessaggioCliente], fittizi: Bool) -> some View {
        let tinta = C.tinta(g.tipo)
        let aperto = modificabile && avviata == nil
        return VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: C.spazio / 3) {
                        Text(TestiCampagne.campagna).carattereApple(C.etichetta).foregroundColor(tinta)
                        Text(g.titolo).carattereApple(C.titolo).foregroundColor(Tema.Apple.Colore.inchiostro)
                            .fixedSize(horizontal: false, vertical: true)
                        if let nota = g.notaNonValutati {
                            Text(nota).carattereApple(C.nota).foregroundColor(C.coloreNota)
                        }
                    }
                    PassoCampagna(numero: 1, titolo: TestiCampagne.passoChi,
                                  sottotitolo: TestiCampagne.contoChi(q: bozze.isEmpty ? inclusi.count : bozze.count, n: g.membri.count)
                                    + (fittizi ? " " + TestiCampagne.tra : ""),
                                  tinta: tinta)
                        .padding(.top, C.spazioPassi)
                    righeChi(g, avviata: avviata, bozze: bozze)
                        .padding(.top, C.sottoPasso)
                    PassoCampagna(numero: 2, titolo: TestiCampagne.passoCosa, sottotitolo: TestiCampagne.sottoCosa, tinta: tinta)
                        .padding(.top, C.spazioPassi)
                    cosaScrivi(g, anteprimaMembro: anteprimaMembro, orari: orari, aperto: aperto)
                        .padding(.top, C.sottoPasso)
                    PassoCampagna(numero: 3, titolo: TestiCampagne.passoQuando, sottotitolo: TestiCampagne.sottoQuando, tinta: tinta)
                        .padding(.top, C.spazioPassi)
                    quando(spazi: spazi, aperto: aperto)
                        .padding(.top, C.sottoPasso)
                    if !stato.disponibilitaLocale.pronto {
                        Text(TestiCampagne.veraNonPronta).carattereApple(C.nota).foregroundColor(C.coloreNota)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, C.spazioPassi)
                    }
                }
                .padding(C.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if modificabile {
                piedeMac(g, inclusi: inclusi, spazi: spazi, orari: orari, misti: misti, avviata: avviata, bozze: bozze)
            }
        }
    }

    /// Le righe dei clienti del gruppo: le prime otto, poi «e altri N clienti» con «Mostra tutti».
    @ViewBuilder private func righeChi(_ g: GruppoCampagna, avviata: Campagna?, bozze: [MessaggioCliente]) -> some View {
        let c = stato.campagne
        let canale = c.canale
        let visibili = tutti ? g.membri : Array(g.membri.prefix(C.righeVisibili))
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(visibili.enumerated()), id: \.element.id) { i, m in
                let bozza = bozze.first { $0.clienteId == m.clienteId }
                // Il lampo segue l'ordine delle bozze: una riga dopo l'altra, solo fra quelle preparate
                let ordine = bozze.firstIndex { $0.clienteId == m.clienteId } ?? i
                RigaMembroCampagna(membro: m, cliente: stato.cliente(m.clienteId), incluso: incluso(m, canale: canale),
                                   canale: canale, bozza: bozza,
                                   indice: ordine, modificabile: modificabile && avviata == nil,
                                   inScrittura: bozza.map { c.inScrittura.contains($0.id) } ?? false,
                                   veraPronta: stato.disponibilitaLocale.pronto,
                                   cambia: { cambia(m, canale: canale) },
                                   vedi: { c.anteprima = m.clienteId },
                                   apri: { id in _ = stato.apriBozzaCampagna(id) },
                                   riscrivi: { id in stato.riscriviConVera(id) },
                                   ferma: { stato.fermaVeraCampagna() })
            }
            if g.membri.count > visibili.count {
                HStack(spacing: C.spazioRigaPasso) {
                    Text(TestiCampagne.altriClienti(g.membri.count - visibili.count))
                        .carattereApple(C.nomeRigaPasso)
                        .foregroundColor(Tema.Apple.Colore.inchiostro2)
                    Spacer(minLength: C.spazio / 2)
                    Button(TestiCampagne.mostraTutti) { tutti = true }
                        .buttonStyle(.appleSobrio)
                }
                .padding(C.paddingRigaPasso)
            }
        }
    }

    /// Tono e canale con il loro nome (migliorie d'uso 26), poi l'anteprima del primo cliente scelto.
    @ViewBuilder private func cosaScrivi(_ g: GruppoCampagna, anteprimaMembro: MembroCampagna?, orari: [Date], aperto: Bool) -> some View {
        let c = stato.campagne
        VStack(alignment: .leading, spacing: C.spazio) {
            if aperto {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: Tema.Apple.Messaggi.Pannello.fraGruppiControlli) {
                        controlloCampagna(Parole.tono) {
                            SegmentatoPillola(selezione: Bindable(c).tono, valori: TonoMessaggio.allCases, titolo: { $0.nome })
                                .fixedSize()
                        }
                        controlloCampagna(Parole.inviaCon) {
                            SegmentatoPillola(selezione: Bindable(c).canale, valori: CanaleMessaggio.allCases, titolo: { $0.nome })
                                .fixedSize()
                        }
                    }
                    .fixedSize()
                    VStack(alignment: .leading, spacing: C.spazio / 2) {
                        controlloCampagna(Parole.tono) {
                            SegmentatoPillola(selezione: Bindable(c).tono, valori: TonoMessaggio.allCases, titolo: { $0.nome })
                                .fixedSize()
                        }
                        controlloCampagna(Parole.inviaCon) {
                            SegmentatoPillola(selezione: Bindable(c).canale, valori: CanaleMessaggio.allCases, titolo: { $0.nome })
                                .fixedSize()
                        }
                    }
                }
            }
            if let m = anteprimaMembro,
               let pronto = stato.testoCampagna(g, membro: m, campagnaId: "anteprima", appuntamenti: orari, tono: c.tono,
                                                canale: c.canale, firmaCanale: c.firmaCanale) {
                VStack(alignment: .leading, spacing: C.spazioRiga) {
                    Text(TestiCampagne.anteprimaPer(stato.cliente(m.clienteId)?.nome ?? ""))
                        .carattereApple(C.passoSottotitolo)
                        .foregroundColor(C.coloreSottotitoloPasso)
                    if let o = pronto.1.oggetto, c.canale == .mail {
                        Text(o).carattereApple(C.nomeRiga).foregroundColor(Tema.Apple.Colore.inchiostro)
                    }
                    Text(pronto.1.completo)
                        .carattereApple(C.anteprima)
                        .foregroundColor(Tema.Apple.Colore.inchiostro)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                }
                .padding(C.paddingAnteprimaPasso)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: C.raggioAnteprima, style: .continuous).fill(C.fondoAnteprima))
                .accessibilityElement(children: .combine)
            } else {
                Text(TestiCampagne.anteprimaVuota)
                    .carattereApple(C.passoSottotitolo)
                    .foregroundColor(C.coloreSottotitoloPasso)
                    .padding(C.paddingAnteprimaPasso)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: C.raggioAnteprima, style: .continuous).fill(C.fondoAnteprima))
            }
        }
    }

    /// L'etichetta davanti al segmentato, come nel pannello del messaggio.
    private func controlloCampagna<V: View>(_ etichetta: String, @ViewBuilder _ controllo: () -> V) -> some View {
        HStack(alignment: .center, spacing: Tema.Apple.Messaggi.Pannello.spazioEtichetta) {
            Text(etichetta)
                .carattereApple(Tema.Apple.Messaggi.Pannello.etichettaControllo)
                .foregroundColor(Tema.Apple.Messaggi.Pannello.coloreEtichettaControllo)
                .lineLimit(1)
                .fixedSize()
                .accessibilityHidden(true)
            controllo()
                .accessibilityLabel(Text(etichetta))
        }
    }

    /// Le capsule degli orari: accese (accento, testo bianco) o spente; con l'agenda piena la frase di oggi.
    @ViewBuilder private func quando(spazi: [SpazioLibero], aperto: Bool) -> some View {
        if spazi.isEmpty {
            Text(TestiCampagne.agendaPiena).carattereApple(C.nota).foregroundColor(C.coloreNota)
        } else {
            FlussoEtichette(spazio: C.spazioChip) {
                ForEach(spazi, id: \.inizio) { s in
                    let acceso = !stato.campagne.chipTolti.contains(s.inizio)
                    Button {
                        if acceso { stato.campagne.chipTolti.insert(s.inizio) } else { stato.campagne.chipTolti.remove(s.inizio) }
                    } label: {
                        Text(TestiCampagne.chip(s.inizio))
                            .carattereApple(C.chipPasso)
                            .foregroundColor(acceso ? C.testoChipScelto : C.testoChip)
                            .padding(C.paddingChipPasso)
                            .background(Capsule().fill(acceso ? C.fondoChipScelto : C.fondoChip))
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!aperto)
                    .help(acceso ? "Toglilo dagli orari proposti (l'Agenda non si blocca)" : "Rimettilo fra gli orari proposti")
                    .accessibilityAddTraits(acceso ? .isSelected : [])
                }
            }
        }
    }

    /// Il piede fermo sotto i passi: la firma per i canali misti, chi resta fuori, il pulsante a tutta larghezza e
    /// «Niente parte da solo…». Dopo l'avvio: «Apri i messaggi preparati» e, sobri, le aperture di sempre.
    private func piedeMac(_ g: GruppoCampagna, inclusi: [MembroCampagna], spazi: [SpazioLibero], orari: [Date], misti: Bool,
                          avviata: Campagna?, bozze: [MessaggioCliente]) -> some View {
        let c = stato.campagne
        return VStack(alignment: .center, spacing: C.sottoPulsante) {
            if let a = avviata {
                let daAprire = bozze.filter { $0.stato == .bozza }
                Button {
                    if let prima = daAprire.first ?? bozze.first {
                        stato.preparaMessaggio(clienteId: prima.clienteId, messaggioId: prima.id)
                    }
                } label: {
                    Text(TestiCampagne.apriPreparati).frame(maxWidth: .infinity)
                }
                .buttonStyle(.applePrimarioGrande)
                .disabled(bozze.isEmpty)
                HStack(spacing: C.spazio / 2) {
                    Button(TestiCampagne.apriProssimaIn(a.canale.nome)) { _ = stato.apriProssimaBozza(a.id) }
                        .buttonStyle(.appleSobrio)
                        .disabled(daAprire.isEmpty)
                    Button(TestiCampagne.apriTutte) {
                        if daAprire.count > RegoleCampagne.aperturaSenzaConferma {
                            c.conferma = .apriTutte(campagna: a.id, quante: daAprire.count)
                        } else {
                            stato.apriTutteLeBozze(a.id)
                        }
                    }
                    .buttonStyle(.appleSobrio)
                    .disabled(daAprire.isEmpty)
                    if daAprire.count == bozze.count {
                        Button(TestiCampagne.annulla) { _ = stato.annullaCampagna(a.id) }
                            .buttonStyle(.appleSobrio)
                    }
                }
            } else {
                let senzaConsenso = g.membri.filter { !$0.consenso && !incluso($0, canale: c.canale) }.count
                let senzaRecapito = g.membri.filter { !$0.recapito(c.canale) }.count
                let p = TestiCampagne.pulsante(inclusi: inclusi.count, orariDisponibili: spazi.count, orariScelti: orari.count,
                                               firmaMancante: misti && c.firmaCanale == nil)
                if misti {
                    HStack(spacing: C.spazio / 2) {
                        Text(TestiCampagne.sceltaFirma).carattereApple(C.nota).foregroundColor(C.coloreNota)
                        MenuTendina(selezione: Bindable(c).firmaCanale,
                                    opzioni: [(Canale?.none, "Da scegliere")] + Canale.allCases.map { (Optional($0), "Firma " + $0.nomeBreve) },
                                    larghezza: C.larghezzaPannello / 2)
                    }
                }
                if let nota = TestiCampagne.notaFuori(senzaConsenso: senzaConsenso, senzaRecapito: senzaRecapito) {
                    Text(nota).carattereApple(C.nota).foregroundColor(C.coloreNota)
                        .multilineTextAlignment(.center)
                }
                Button {
                    if let nuova = stato.avviaCampagna(g, inclusi: inclusi.map(\.clienteId), appuntamenti: orari, tono: c.tono,
                                                       canale: c.canale, firmaCanale: c.firmaCanale) {
                        c.avviata = nuova.id
                        stato.mostraAvviso(TestiCampagne.toastPronte(nuova.messaggi.count))
                    }
                } label: {
                    Text(p.testo).frame(maxWidth: .infinity)
                }
                .buttonStyle(StilePulsanteApple(p.attivo ? .principale : .secondaria, grande: true))
                .disabled(!p.attivo)
            }
            Text(TestiCampagne.nienteParte)
                .carattereApple(C.nota)
                .foregroundColor(C.coloreNota)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(C.paddingPiede)
        .frame(maxWidth: .infinity)
    }
    #endif

    // MARK: Scelte

    /// Incluso nell'invio: con il recapito del canale, non tolto a mano, e incluso di base o a mano.
    private func incluso(_ m: MembroCampagna, canale: CanaleMessaggio) -> Bool {
        let k = StatoCampagne.chiave(gruppo.id, m.clienteId)
        guard m.recapito(canale), !stato.campagne.esclusi.contains(k) else { return false }
        let base = m.consenso && m.giaContattato == nil && m.ultimaCampagna == nil
        return base || stato.campagne.inclusiAMano.contains(k)
    }

    private func cambia(_ m: MembroCampagna, canale: CanaleMessaggio) {
        let c = stato.campagne
        let k = StatoCampagne.chiave(gruppo.id, m.clienteId)
        if incluso(m, canale: canale) {
            c.esclusi.insert(k)
            c.inclusiAMano.remove(k)
        } else if !m.recapito(canale) {
            stato.mostraAvviso(AperturaMessaggi.mancante(canale))
        } else if !m.consenso {
            c.conferma = .includi(cliente: m.clienteId)
        } else {
            c.esclusi.remove(k)
            c.inclusiAMano.insert(k)
        }
    }

    private func testoConferma(_ x: ConfermaCampagna?) -> String {
        switch x {
        case .includi(let id)?: return TestiCampagne.confermaSenzaConsenso(stato.cliente(id)?.nome ?? "")
        case .apriTutte(_, let n)?: return TestiCampagne.confermaApriTutte(n)
        case nil: return ""
        }
    }

    private func conferma(_ x: ConfermaCampagna?) {
        let c = stato.campagne
        switch x {
        case .includi(let id)?:
            let k = StatoCampagne.chiave(gruppo.id, id)
            c.esclusi.remove(k)
            c.inclusiAMano.insert(k)
        case .apriTutte(let campagna, _)?:
            stato.apriTutteLeBozze(campagna)
        case nil:
            break
        }
        c.conferma = nil
    }
}

#if os(macOS)
// MARK: - Passo numerato (migliorie d'uso 49)

/// La testa di un passo della campagna: tondino numerato 20 nel colore del gruppo con la cifra bianca, il titolo in
/// neretto e, accanto, il sottotitolo grigio («1 · Chi  5 di 7 clienti con questo bisogno»).
struct PassoCampagna: View {
    let numero: Int
    let titolo: String
    let sottotitolo: String
    let tinta: Color

    private typealias C = Tema.Apple.Campagne

    var body: some View {
        HStack(alignment: .center, spacing: C.spazioPasso) {
            Text("\(numero)")
                .carattereApple(C.passoCifra)
                .foregroundColor(C.coloreCifraPasso)
                .frame(width: C.passoTondino, height: C.passoTondino)
                .background(Circle().fill(tinta))
                .accessibilityHidden(true)
            Text(titolo).carattereApple(C.passoTitolo).foregroundColor(Tema.Apple.Colore.inchiostro)
            Text(sottotitolo)
                .carattereApple(C.passoSottotitolo)
                .foregroundColor(C.coloreSottotitoloPasso)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Passo \(numero), \(titolo): \(sottotitolo)")
    }
}
#endif

// MARK: - Riga di un membro

private struct RigaMembroCampagna: View {
    let membro: MembroCampagna
    let cliente: Cliente?
    let incluso: Bool
    let canale: CanaleMessaggio
    let bozza: MessaggioCliente?
    let indice: Int
    let modificabile: Bool
    let inScrittura: Bool
    let veraPronta: Bool
    let cambia: () -> Void
    let vedi: () -> Void
    let apri: (String) -> Void
    let riscrivi: (String) -> Void
    let ferma: () -> Void

    @Environment(\.prismaStatoFinale) private var statoFinale
    @Environment(\.prismaCalmo) private var calmo
    @State private var mostrata = false

    private typealias C = Tema.Apple.Campagne

    var body: some View {
        #if os(macOS)
        rigaMac
        #else
        rigaComune
        #endif
    }

    #if os(macOS)
    /// Migliorie d'uso 49: la casella quadrata in testa e tutta la riga che include o esclude; dopo l'avvio «✓ pronto in
    /// Messaggi» in verde con il lampo, una riga dopo l'altra ogni 320 ms (al ritmo; con «Riduci movimento» e nelle
    /// istantanee tutte subito). Consenso, recapito, stato e azioni di Vera restano come prima.
    private var rigaMac: some View {
        let m = membro
        let pronta = bozza?.stato == .bozza
        return HStack(alignment: .center, spacing: C.spazioRigaPasso) {
            Button(action: cambia) {
                CasellaSceltaApple(scelta: bozza != nil || incluso)
            }
            .buttonStyle(.plain)
            .disabled(!modificabile)
            .accessibilityLabel(cliente?.nome ?? "")
            .accessibilityValue(incluso ? "Incluso" : "Escluso")
            AvatarCliente(iniziali: cliente?.iniziali ?? "", tinta: (cliente?.tinta ?? .blu).colori, lato: C.avatar)
            VStack(alignment: .leading, spacing: C.spazioRiga) {
                HStack(spacing: C.spazio / 2) {
                    Text(cliente?.nome ?? "").carattereApple(C.nomeRigaPasso).foregroundColor(Tema.Apple.Colore.inchiostro).lineLimit(1)
                    if !m.consenso {
                        Text(TestiCampagne.senzaConsenso)
                            .carattereApple(C.pillola)
                            .foregroundColor(C.pillolaConsenso)
                            .padding(C.paddingPillola)
                            .background(Capsule().fill(C.fondoPillola))
                    }
                }
                Text(statoMac(m))
                    .carattereApple(C.statoRiga)
                    .foregroundColor(pronta && (mostrata || statoFinale) ? C.pronta : C.coloreStato)
                    .lineLimit(1)
            }
            Spacer(minLength: C.spazio / 2)
            if let b = bozza {
                if b.stato == .bozza {
                    if inScrittura {
                        Button(TestiCampagne.fermaVera, action: ferma).buttonStyle(.appleSobrio)
                    } else if veraPronta {
                        Button(TestiCampagne.riscriviVera) { riscrivi(b.id) }.buttonStyle(.appleSobrio)
                    }
                    Button("Apri in " + b.canale.nome) { apri(b.id) }.buttonStyle(.apple)
                }
            } else {
                Button(TestiCampagne.vediMessaggio, action: vedi).buttonStyle(.appleSobrio)
            }
        }
        .padding(C.paddingRigaPasso)
        .background {
            if bozza != nil && !(mostrata || statoFinale) {
                RoundedRectangle(cornerRadius: Tema.Apple.Raggio.voce, style: .continuous).fill(C.lampo)
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(C.filoRiga).frame(height: Tema.Apple.Misura.bordo)
        }
        .opacity(bozza == nil && !incluso ? C.opacitaEscluso : 1)
        .contentShape(Rectangle())
        .onTapGesture { if modificabile { cambia() } }
        .onAppear {
            // Una campagna già avviata (dallo storico): le righe sono già pronte, senza lampo
            if bozza != nil { mostrata = true }
        }
        .onChange(of: bozza?.id) { _ in
            mostrata = false
            guard bozza != nil else { return }
            // Niente Timer: animazione con ritardo, una riga dopo l'altra come le prepara Prisma
            withAnimation(Tema.Apple.Moto.animazione(Tema.Apple.Moto.Curva.easeOut.animazione(Tema.Apple.Moto.Campagne.lampo), calmo: calmo)
                .ritardoPrisma(calmo ? 0 : Double(indice) * Tema.Apple.Moto.Campagne.pronta)) {
                mostrata = true
            }
        }
        .help(m.motivo + (m.anchein.isEmpty ? "" : " · " + TestiCampagne.ancheIn(m.anchein)))
    }

    /// Lo stato sotto il nome: «✓ pronto in Messaggi» quando la sua riga si è accesa; prima, il motivo.
    private func statoMac(_ m: MembroCampagna) -> String {
        if let b = bozza {
            switch b.stato {
            case .bozza: return mostrata || statoFinale ? TestiCampagne.prontoInMessaggi : m.motivo
            case .apertoInMail, .apertoInMessaggi, .salvato: return b.nomeStato
            }
        }
        return stato(m)
    }
    #endif

    private var rigaComune: some View {
        let m = membro
        return HStack(alignment: .center, spacing: C.spazio / 1.5) {
            if modificabile {
                Button(action: cambia) {
                    Image(systemName: incluso ? "checkmark.square.fill" : "square")
                        .foregroundColor(incluso ? Tema.Apple.Colore.accento : Tema.Apple.Colore.inchiostro3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(incluso ? "Incluso" : "Escluso")
            }
            AvatarCliente(iniziali: cliente?.iniziali ?? "", tinta: (cliente?.tinta ?? .blu).colori, lato: C.avatarRiga)
            VStack(alignment: .leading, spacing: C.spazioRiga) {
                HStack(spacing: C.spazio / 2) {
                    Text(cliente?.nome ?? "").carattereApple(C.nomeRiga).foregroundColor(Tema.Apple.Colore.inchiostro).lineLimit(1)
                    if !m.consenso {
                        Text(TestiCampagne.senzaConsenso)
                            .carattereApple(C.pillola)
                            .foregroundColor(C.pillolaConsenso)
                            .padding(C.paddingPillola)
                            .background(Capsule().fill(C.fondoPillola))
                    }
                }
                Text(stato(m)).carattereApple(C.statoRiga).foregroundColor(bozza?.stato == .bozza ? C.pronta : C.coloreStato).lineLimit(1)
            }
            Spacer(minLength: C.spazio / 2)
            if let b = bozza {
                if b.stato == .bozza {
                    if inScrittura {
                        Button(TestiCampagne.fermaVera, action: ferma).buttonStyle(.appleSobrio)
                    } else if veraPronta {
                        Button(TestiCampagne.riscriviVera) { riscrivi(b.id) }.buttonStyle(.appleSobrio)
                    }
                    Button("Apri in " + b.canale.nome) { apri(b.id) }.buttonStyle(.apple)
                }
            } else {
                Button(TestiCampagne.vediMessaggio, action: vedi).buttonStyle(.appleSobrio)
            }
        }
        .padding(.vertical, C.paddingRiga)
        .background {
            if bozza != nil && !(mostrata || statoFinale) {
                RoundedRectangle(cornerRadius: Tema.Apple.Raggio.voce, style: .continuous).fill(C.lampo)
            }
        }
        .opacity(bozza == nil && !incluso ? C.opacitaEscluso : 1)
        .onChange(of: bozza?.id) { _ in
            mostrata = false
            guard bozza != nil else { return }
            // «✓ bozza pronta» una riga dopo l'altra, come le prepara Prisma (niente Timer: animazione con ritardo)
            withAnimation(Tema.Apple.Moto.animazione(Tema.Apple.Moto.Curva.easeOut.animazione(Tema.Apple.Moto.Campagne.lampo), calmo: calmo)
                .ritardoPrisma(calmo ? 0 : Double(indice) * Tema.Apple.Moto.Campagne.passoBozze)) {
                mostrata = true
            }
        }
        .help(m.motivo + (m.anchein.isEmpty ? "" : " · " + TestiCampagne.ancheIn(m.anchein)))
    }

    private func stato(_ m: MembroCampagna) -> String {
        if let b = bozza {
            switch b.stato {
            case .bozza: return TestiCampagne.bozzaPronta
            case .apertoInMail, .apertoInMessaggi, .salvato: return b.nomeStato
            }
        }
        if !m.recapito(canale) { return AperturaMessaggi.mancante(canale) }
        if let d = m.giaContattato ?? m.ultimaCampagna { return TestiCampagne.giaScritto(d) }
        return m.motivo
    }
}

// MARK: - Storico e vuoto

private struct StoricoCampagne: View {
    @Environment(StatoShell.self) var stato

    private typealias C = Tema.Apple.Campagne

    var body: some View {
        let campagne = stato.dati.campagne.sorted { $0.avviataIl > $1.avviataIl }
        if !campagne.isEmpty {
            VStack(alignment: .leading, spacing: C.spazio / 3) {
                Text(TestiCampagne.storico.uppercased()).carattereApple(C.etichetta).foregroundColor(C.coloreEtichetta)
                ForEach(campagne.prefix(6)) { c in
                    let suoi = Set(c.messaggi)
                    let messaggi = stato.dati.messaggi.filter { suoi.contains($0.id) }
                    let aperti = messaggi.filter { $0.stato != .bozza }.count
                    Button(TestiCampagne.rigaStorico(c, aperti: aperti, daAprire: messaggi.count - aperti)) {
                        if let g = stato.gruppiCampagne().first(where: { $0.id == c.gruppoId }) {
                            stato.campagne.scegli(g.id)
                            stato.campagne.avviata = c.id
                        }
                    }
                    .buttonStyle(.plain)
                    .carattereApple(C.nota)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                }
            }
        }
    }
}

private struct VuotoCampagne: View {
    let nonValutate: Int

    private typealias C = Tema.Apple.Campagne

    var body: some View {
        VStack(spacing: C.spazio) {
            Text(TestiCampagne.vuoto)
                .carattereApple(Tema.Apple.Carattere.corpo)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: C.larghezzaPannello)
            if nonValutate > 0 {
                Text(TestiCampagne.nonValutati(nonValutate)).carattereApple(C.nota).foregroundColor(C.coloreNota)
            }
            StoricoCampagne()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp)
    }
}
