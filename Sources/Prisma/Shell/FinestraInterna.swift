import SwiftUI

/// Finestra interna di un'app (.win del tema): vetro chiaro o scuro con raggio 24 (18 se ingrandita),
/// semafori piatti, titolo con l'icona, contesto della finestra e ridimensionamento. Sul Mac (migliorie d'uso 4) una
/// riga sola in testa: chiusura, icona, titolo e azioni dell'app (`rigaTesta`); semafori e contesto restano per iOS.
/// Esce dall'icona del dock e vi rientra (VoloDallIcona, messo da ShellView sopra la sua cornice).
/// Trascinare e ridimensionare non toccano lo stato finché non si rilascia: si muove (o si reimpagina)
/// solo questa finestra, come sul Mac, e lo stato si scrive una volta sola.
struct FinestraInterna: View {
    @Environment(StatoShell.self) var stato
    let finestra: StatoShell.Finestra
    let attiva: Bool
    /// L'area delle finestre (coordinate `ShellView.spazioFinestre`): spostamento e misura restano dentro.
    let area: CGRect

    /// Il trascinamento in corso (si azzera da solo anche se il gesto viene interrotto).
    @GestureState private var spostamento: CGSize = .zero
    /// Il ridimensionamento in corso.
    @GestureState private var allungamento: CGSize = .zero

    var body: some View {
        let _ = ContaCorpi.segna()
        let forma = FormaVetro.arrotondata(finestra.ingrandita ? Tema.Raggio.finestraIngrandita : Tema.Raggio.finestra)
        let dimensione = allungamento == .zero ? cornice.size : misuraAllungata(allungamento)
        VStack(spacing: 0) {
            #if os(macOS)
            // Migliorie d'uso 4: una riga sola con chiusura, icona, titolo, sottotitolo e azioni dell'app
            rigaTesta
            #else
            barraTitolo
            #endif
            // In una finestra più piccola del suo contenuto l'app parte dall'angolo in alto a sinistra
            // e si taglia in basso e a destra:
            // la barra del titolo resta sempre al suo posto
            ContenutoApp(app: finestra.app)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .clipped()
                // Appena aperta il contenuto entra in dissolvenza (0,2 s lineare) mentre la finestra esce dall'icona
                .modifier(DissolvenzaContenutoFinestra())
        }
        // La finestra si dà da sola la misura: ridimensionando si rifà l'impaginazione solo di lei
        .frame(width: dimensione.width, height: dimensione.height, alignment: .topLeading)
        // Il contenuto si taglia prima del vetro: dopo taglierebbe anche le ombre
        .clipShape(forma)
        .vetro(.finestra(attiva: attiva), forma: forma)
        #if os(macOS)
        // La finestra in primo piano è quella che Vera legge mentre pensa e che si illumina quando risponde
        .overlay {
            if attiva { LetturaVeraFinestra(mini: stato.miniVera, forma: forma) }
        }
        #endif
        .overlay(alignment: .bottomTrailing) {
            if !finestra.ingrandita { maniglia }
        }
        // Una trasformazione, non un cambio di stato: niente si ricalcola mentre si trascina
        .offset(spostamento == .zero ? .zero : limitato(spostamento))
        // Davanti appena si preme, come sul Mac (non al rilascio): insieme ai gesti dell'app, mai al loro posto
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !attiva { stato.primoPiano(finestra.app) }
                }
        )
    }

    /// La cornice nello stato, nell'area in cui ShellView disegna la finestra.
    private var cornice: CGRect { stato.cornice(di: finestra, in: area) }

    /// Lo spostamento dentro l'area (come `limita` dello stato): la barra del titolo resta raggiungibile.
    private func limitato(_ t: CGSize) -> CGSize {
        let c = cornice
        let x = min(max(c.minX + t.width, 0), max(0, area.width - c.width))
        let y = min(max(c.minY + t.height, 0), max(0, area.height - c.height))
        return CGSize(width: x - c.minX, height: y - c.minY)
    }

    /// La misura allungata: non sotto la minima e non oltre il bordo dell'area.
    private func misuraAllungata(_ t: CGSize) -> CGSize {
        let c = cornice
        let minima = Misure.Finestra.minima
        return CGSize(width: min(max(minima.width, c.width + t.width), max(minima.width, area.width - c.minX)),
                      height: min(max(minima.height, c.height + t.height), max(minima.height, area.height - c.minY)))
    }

    /// Scrive lo stato una volta sola, al rilascio, senza animazione.
    private func alRilascio(_ cambia: () -> Void) {
        withTransaction(Transaction(animation: nil), cambia)
    }

    private var barraTitolo: some View {
        let m = Tema.Misura.Shell.self
        return ZStack(alignment: .leading) {
            SemaforiFinestra(
                attiva: attiva,
                chiudi: { stato.chiudi(finestra.app) },
                riduci: { stato.riduci(finestra.app) },
                ingrandisci: { stato.alternaIngrandimento(finestra.app) }
            )
            .padding(.leading, Tema.Misura.origineSemafori.x)

            HStack(spacing: m.titoloFinestraSpazio) {
                IconaApp(app: finestra.app, lato: Tema.Misura.iconaFinestra)
                Text(finestra.app.titolo)
                    .font(Tema.Testo.titolo)
                    .foregroundColor(attiva ? Tema.Colore.inchiostro : Tema.Colore.inchiostroSecondario)
                    .lineLimit(1)
                Spacer(minLength: m.titoloFinestraSpazio)
                strumenti
            }
            .padding(.leading, m.titoloFinestraSinistra)
            .padding(.trailing, m.titoloFinestraDestra)
        }
        .frame(height: Misure.Finestra.barraTitolo)
        .frame(maxWidth: .infinity)
        .background(
            // Piena fino a poco oltre metà, poi sfuma nel contenuto
            LinearGradient(stops: [
                .init(color: Tema.Colore.finestraPiena, location: 0),
                .init(color: Tema.Colore.finestraPiena, location: m.titoloPieno),
                .init(color: Tema.Colore.finestraPiena.opacity(0), location: 1),
            ], startPoint: .top, endPoint: .bottom)
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { stato.alternaIngrandimento(finestra.app) }
        .gesture(trascinamento)
    }

    /// Trascinare la parte vuota della barra (o della riga in testa) sposta la finestra: lo stato si scrive al rilascio.
    private var trascinamento: some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .named(ShellView.spazioFinestre))
            .updating($spostamento) { g, s, _ in
                if !finestra.ingrandita { s = g.translation }
            }
            // Davanti al primo movimento (poi primoPiano non cambia più niente)
            .onChanged { _ in
                if !finestra.ingrandita { stato.primoPiano(finestra.app) }
            }
            .onEnded { g in
                guard !finestra.ingrandita else { return }
                let c = cornice
                let d = limitato(g.translation)
                alRilascio { stato.sposta(finestra.app, origine: CGPoint(x: c.minX + d.width, y: c.minY + d.height)) }
            }
    }

    #if os(macOS)
    /// La riga unica in testa alla finestra (migliorie d'uso 4, `#win .hd` del template): una chiusura sola al posto dei
    /// tre pallini, l'icona, poi titolo, sottotitolo, testo a destra e azioni dell'app in `TestaFinestra`, una vista a sé
    /// che non legge lo stato dei gesti (trascinare o ridimensionare non rifà le azioni). Come la barra di prima:
    /// trascinare la parte vuota sposta, doppio clic ingrandisce o rimette, il clic porta davanti. Ridurre, ingrandire e
    /// affiancare stanno nel menu contestuale della riga (e ridurre anche nel dock).
    private var rigaTesta: some View {
        HStack(spacing: RigaTestaTema.spazio) {
            // Nella vista pulita di «Mostra al cliente» la Sala non si chiude (migliorie d'uso 1, riga 500 del
            // template): chiuderla lascerebbe la vista vuota; si esce con «Fine» della vista.
            if !stato.inVistaCliente {
                ChiusuraFinestra { stato.chiudi(finestra.app) }
            }
            IconaApp(app: finestra.app, lato: RigaTestaTema.icona)
                .padding(.leading, RigaTestaTema.margineIcona)
            TestaFinestra(app: finestra.app, attiva: attiva)
        }
        .padding(RigaTestaTema.padding)
        .frame(height: RigaTestaTema.altezza)
        .frame(maxWidth: .infinity)
        .background(Gradienti.intestazioneApp)
        .bordoBasso(Colori.IntestazioneApp.bordo)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { stato.alternaIngrandimento(finestra.app) }
        .gesture(trascinamento)
        .contextMenu {
            Button("Riduci nel dock") { stato.riduci(finestra.app) }
            Button(finestra.ingrandita ? "Rimetti a posto" : "Ingrandisci") { stato.alternaIngrandimento(finestra.app) }
            Button("Affianca a sinistra") { stato.affianca(finestra.app) }
            if !stato.inVistaCliente {
                Divider()
                Button("Chiudi") { stato.chiudi(finestra.app) }
            }
        }
    }
    #endif

    /// A destra: di chi parla la finestra (il suo cliente o il suo contesto) e il pulsante per affiancarla.
    private var strumenti: some View {
        HStack(spacing: Tema.Misura.Shell.strumentiFinestraSpazio) {
            ContestoFinestra(app: finestra.app)
            Button {
                stato.affianca(finestra.app)
            } label: {
                Image(systemName: "rectangle.split.2x1")
                    .font(Tema.Testo.Shell.simboloPulsante)
            }
            .buttonStyle(StileVetro(margine: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)))
            .help("Affianca questa app, a sinistra, a quella sotto")
        }
    }

    /// Maniglia di ridimensionamento in basso a destra (solo con finestra non ingrandita).
    private var maniglia: some View {
        let lato = Tema.Misura.Shell.maniglia
        return Path { p in
            for i in 0..<3 {
                let d = CGFloat(i) * 4 + 3
                p.move(to: CGPoint(x: lato - 3, y: d))
                p.addLine(to: CGPoint(x: d, y: lato - 3))
            }
        }
        .stroke(Tema.Colore.inchiostroTerziario, lineWidth: 1)
        .frame(width: lato, height: lato)
        .contentShape(Rectangle())
        .padding(Tema.Misura.Shell.manigliaMargine)
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .named(ShellView.spazioFinestre))
                .updating($allungamento) { g, s, _ in s = g.translation }
                .onChanged { _ in stato.primoPiano(finestra.app) }
                .onEnded { g in
                    let m = misuraAllungata(g.translation)
                    alRilascio { stato.ridimensiona(finestra.app, dimensione: m) }
                }
        )
        .help("Ridimensiona")
    }
}

// MARK: - La riga in testa (migliorie d'uso 4, solo Mac)

#if os(macOS)
private typealias RigaTestaTema = Tema.Apple.RigaTesta

/// Titolo, sottotitolo, testo a destra e azioni dell'app nella riga in testa. Se lo spazio manca la riga cede come
/// l'intestazione di prima: prima l'occhiello, poi il testo a destra, poi i pulsanti di vetro restano con la sola
/// icona (mai una parola tagliata dentro un pulsante). Titolo e sottotitolo non vanno a capo.
private struct TestaFinestra: View {
    let app: AppPrisma
    let attiva: Bool

    var body: some View {
        if app == .clienti {
            // Migliorie d'uso 12: con un cliente scelto la riga è quella del suo dossier (RigaTestaDossier.swift)
            RigaTestaClienti(attiva: attiva) { righeApp }
        } else {
            righeApp
        }
    }

    private var righeApp: some View {
        ViewThatFits(in: .horizontal) {
            riga(occhiello: true, destro: true, soloIcona: false)
            riga(occhiello: false, destro: true, soloIcona: false)
            riga(occhiello: false, destro: false, soloIcona: false)
            riga(occhiello: false, destro: false, soloIcona: true)
        }
    }

    /// Una delle versioni della riga. Le azioni si costruiscono più volte: non hanno stato proprio (né fogli né
    /// importazioni: li apre `stato`), quindi si può, come nell'intestazione di prima.
    private func riga(occhiello: Bool, destro: Bool, soloIcona: Bool) -> some View {
        HStack(alignment: .center, spacing: RigaTestaTema.spazio) {
            if app == .posizioni {
                // Migliorie d'uso 14: con un cliente scelto «Le posizioni di Marco.» e i conti delle sue posizioni
                // (IndicePosizioniApple.swift)
                TitoloRigaPosizioni(attiva: attiva, occhiello: occhiello)
            } else {
                Text(app.titoloIntestazione)
                    .carattereApple(RigaTestaTema.titolo)
                    .foregroundColor(attiva ? RigaTestaTema.coloreTitolo : RigaTestaTema.coloreTitoloSpento)
                    .lineLimit(1)
            }
            if occhiello, app != .posizioni {
                if app == .mercato {
                    // L'occhiello lo scrive il motore del mercato: «Aggiornato oggi alle 18:00» (AppMercato.swift)
                    OcchielloMercato()
                } else if app == .sala {
                    // Migliorie d'uso 60: «2 esperienze fatte oggi con Giulia» (StatoEsperienzeFatte.swift)
                    OcchielloSala { testo in
                        Text(testo)
                            .carattereApple(RigaTestaTema.sottotitolo)
                            .foregroundColor(RigaTestaTema.coloreSottotitolo)
                            .lineLimit(1)
                    }
                } else {
                    Text(app.occhiello)
                        .carattereApple(RigaTestaTema.sottotitolo)
                        .foregroundColor(RigaTestaTema.coloreSottotitolo)
                        .lineLimit(1)
                }
            }
            if destro, let testo = app.testoDestro {
                HStack(spacing: RigaTestaTema.spazioTestoDestro) {
                    Rectangle()
                        .fill(RigaTestaTema.filoTestoDestro)
                        .frame(width: RigaTestaTema.spessoreFilo, height: RigaTestaTema.altezzaFilo)
                    Text(testo)
                        .carattereApple(RigaTestaTema.testoDestro)
                        .foregroundColor(RigaTestaTema.coloreTestoDestro)
                        .lineLimit(1)
                }
                .padding(.leading, RigaTestaTema.margineTestoDestro)
            }
            Spacer(minLength: RigaTestaTema.spazio)
            // Stile Carta: «Note di Vera» accende e spegne la penna (NOVITÀ 4)
            PulsanteNoteVera()
            // «Come si usa» non sta più in ogni riga: è il «?» della barra, per l'app davanti (migliorie d'uso 6)
            AzioniApp(app: app)
                .environment(\.pulsantiSoloIcona, soloIcona)
        }
    }
}

/// La chiusura della finestra (`.wx`): cerchio da 28 con il ✕ da 12; al passaggio del puntatore rosso con il segno
/// bianco, premuta si stringe a 0,9. I pulsanti veri della finestra del Mac (in alto a sinistra di Prisma) restano.
struct ChiusuraFinestra: View {
    let chiudi: () -> Void
    @Environment(\.prismaCalmo) private var calmo
    @State private var sopra = false

    var body: some View {
        Button(action: chiudi) {
            ZStack {
                Circle()
                    .fill(sopra ? RigaTestaTema.fondoChiusuraSopra : RigaTestaTema.fondoChiusura)
                CroceChiusura()
                    .stroke(sopra ? RigaTestaTema.segnoChiusuraSopra : RigaTestaTema.segnoChiusura,
                            style: StrokeStyle(lineWidth: RigaTestaTema.trattoChiusura, lineCap: .round))
                    .frame(width: RigaTestaTema.glifoChiusura, height: RigaTestaTema.glifoChiusura)
            }
            .frame(width: RigaTestaTema.chiusura, height: RigaTestaTema.chiusura)
            .contentShape(Circle())
        }
        .buttonStyle(StileChiusuraFinestra(calmo: calmo))
        .onHover { dentro in sopra = dentro }
        .animation(Tema.Apple.Moto.animazione(Tema.Apple.Moto.Curva.ease.animazione(RigaTestaTema.durataPassaggio),
                                              calmo: calmo), value: sopra)
        .help("Chiudi (esc)")
        .accessibilityLabel(Text("Chiudi"))
    }
}

/// Premuta, la chiusura si stringe con la molla del tema (`transform .25s var(--spring)`); con calma niente scala.
private struct StileChiusuraFinestra: ButtonStyle {
    let calmo: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !calmo ? RigaTestaTema.scalaPremuta : 1)
            .animation(Tema.Apple.Moto.Curva.molla.animazione(RigaTestaTema.durataPressione), value: configuration.isPressed)
    }
}

/// Il ✕ della chiusura (`M5 5l14 14M19 5L5 19` su 24), centrato nel riquadro.
private struct CroceChiusura: Shape {
    func path(in rect: CGRect) -> Path {
        let e = RigaTestaTema.estremoChiusura
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + rect.width * e, y: rect.minY + rect.height * e))
        p.addLine(to: CGPoint(x: rect.maxX - rect.width * e, y: rect.maxY - rect.height * e))
        p.move(to: CGPoint(x: rect.maxX - rect.width * e, y: rect.minY + rect.height * e))
        p.addLine(to: CGPoint(x: rect.minX + rect.width * e, y: rect.maxY - rect.height * e))
        return p
    }
}
#endif

// MARK: - Contesto

/// Di chi parla la finestra, in una vista a sé: trascinare o ridimensionare la finestra (lo stato dei gesti rifà
/// il body della cornice a ogni movimento) non rifà il giro dei clienti, e una modifica ai clienti ridisegna solo
/// questa scritta, non la cornice di ogni finestra aperta.
private struct ContestoFinestra: View {
    @Environment(StatoShell.self) var stato
    let app: AppPrisma

    var body: some View {
        if let contesto = stato.contesto(di: app) {
            Text(contesto)
                .font(Tema.Testo.Shell.contestoFinestra)
                .foregroundColor(Tema.Colore.inchiostroSecondario)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

// MARK: - Semafori

/// I tre pallini della finestra interna, come quelli del Mac: cerchi da 12 pt a 20 pt l'uno dall'altro, grigi
/// se la finestra non è in primo piano; i segni ✕ − + (vettoriali, centrati nel cerchio) compaiono solo con
/// il puntatore sopra il gruppo, tutti e tre insieme.
private struct SemaforiFinestra: View {
    let attiva: Bool
    let chiudi: () -> Void
    let riduci: () -> Void
    let ingrandisci: () -> Void
    @State private var sopra = false

    var body: some View {
        let m = Tema.Misura.Shell.self
        HStack(spacing: m.semaforoPasso - m.semaforoLato) {
            pallino(Tema.Colore.semaforoChiudi, .chiudi, chiudi)
            pallino(Tema.Colore.semaforoRiduci, .riduci, riduci)
            pallino(Tema.Colore.semaforoIngrandisci, .ingrandisci, ingrandisci)
        }
        .contentShape(Rectangle())
        .onHover { dentro in sopra = dentro }
    }

    private func pallino(_ colore: Color, _ segno: SegnoSemaforo.Tipo, _ azione: @escaping () -> Void) -> some View {
        let m = Tema.Misura.Shell.self
        return Button(action: azione) {
            ZStack {
                Circle().fill(attiva || sopra ? colore : Tema.Colore.Shell.semaforoSpento)
                Circle().strokeBorder(Tema.Colore.bordoSemaforo, lineWidth: Tema.Misura.filo)
                if sopra {
                    SegnoSemaforo(tipo: segno)
                        .stroke(Tema.Colore.Shell.segnoSemaforo,
                                style: StrokeStyle(lineWidth: m.semaforoTratto, lineCap: .round))
                }
            }
            .frame(width: m.semaforoLato, height: m.semaforoLato)
            .contentShape(Circle())
        }
        .buttonStyle(StileSemplice())
        .help(SemaforiFinestra.aiuto(segno))
    }

    /// Il suggerimento al passaggio del mouse: a chi non conosce il Mac dice che cosa fa ogni pallino.
    private static func aiuto(_ segno: SegnoSemaforo.Tipo) -> String {
        switch segno {
        case .chiudi: return "Chiudi"
        case .riduci: return "Riduci nel dock"
        case .ingrandisci: return "Ingrandisci (o doppio clic sulla barra)"
        }
    }
}

/// ✕, − e + disegnati attorno al centro esatto del riquadro (il testo e i simboli SF non si centrano).
private struct SegnoSemaforo: Shape {
    enum Tipo { case chiudi, riduci, ingrandisci }
    let tipo: Tipo

    func path(in rect: CGRect) -> Path {
        let m = Tema.Misura.Shell.self
        let x = rect.midX
        let y = rect.midY
        var p = Path()
        switch tipo {
        case .chiudi:
            let d = m.semaforoCroce
            p.move(to: CGPoint(x: x - d, y: y - d))
            p.addLine(to: CGPoint(x: x + d, y: y + d))
            p.move(to: CGPoint(x: x + d, y: y - d))
            p.addLine(to: CGPoint(x: x - d, y: y + d))
        case .riduci:
            let d = m.semaforoLinea
            p.move(to: CGPoint(x: x - d, y: y))
            p.addLine(to: CGPoint(x: x + d, y: y))
        case .ingrandisci:
            let d = m.semaforoLinea
            p.move(to: CGPoint(x: x - d, y: y))
            p.addLine(to: CGPoint(x: x + d, y: y))
            p.move(to: CGPoint(x: x, y: y - d))
            p.addLine(to: CGPoint(x: x, y: y + d))
        }
        return p
    }
}
