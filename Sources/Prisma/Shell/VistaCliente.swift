#if os(macOS)
import SwiftUI

// Migliorie d'uso 1 «Mostra al cliente»: la vista pulita (template `entraPulita()`, `pulHTML()`, CSS righe 499-532).
//
//   ◭ Prisma  (◉ Giulia Rossi)            sab 14 nov 10:24                                   (DV)
//
//   Giulia, ecco il tuo quadro.
//   Quattro aree, una frase per ciascuna.
//   ┌ ◎ 72%  PREVIDENZA ───────────────┐ ┌ ◎ 64%  PROTEZIONE ───────────────┐
//   │ Per la pensione che desideri…    │ │ Se venisse a mancare il tuo…     │
//   └──────────────────────────────────┘ └──────────────────────────────────┘
//   ⓘ Come sono calcolate queste cifre   divario previdenziale · capitale caso morte …
//
//                ( Il quadro | Le posizioni | Gli obiettivi | Nel tempo | La Sala )
//
// - Spariscono dock, scrivania, finestre (tranne la Sala nel suo capitolo), pillola dell'app, strumenti della barra;
//   restano il logo, il nome del cliente, data e ora e l'avatar con l'anello, unica uscita.
// - Il contenuto sta fra la barra e i capitoli, sull'acqua, con il testo almeno «Grande»; prima la frase, poi il numero.
// - Le cifre: «Il quadro» dalle stesse fonti di Analisi 360 (FrasiCliente), «Le posizioni» dalle posizioni in essere,
//   «Gli obiettivi» dall'avanzamento degli obiettivi, «Nel tempo» da MotorePatrimonio (analisiDossier, in cache).
// Valori in Tema.Apple.MostraAlCliente.

private typealias V = Tema.Apple.MostraAlCliente.Vista

// MARK: - Lo strato della vista

/// Il contenuto del capitolo scelto e la barra dei capitoli, sopra la scrivania nascosta e sotto la barra superiore.
struct StratoVistaCliente: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaScalaTesto) private var scala
    let capitolo: CapitoloCliente

    var body: some View {
        let _ = ContaCorpi.segna()
        ZStack(alignment: .bottom) {
            if capitolo != .sala, let c = stato.clienteAttivo {
                ScrollView(.vertical, showsIndicators: false) {
                    contenuto(c)
                        .frame(maxWidth: V.larghezzaMassima, alignment: .topLeading)
                        .padding(V.margini)
                        .frame(maxWidth: .infinity)
                }
                // Cambiare capitolo rifà le entrate a cascata
                .id(capitolo)
                .padding(.top, V.dallAlto)
                .padding(.bottom, V.dalBasso)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            BarraCapitoli(scelto: capitolo)
                .padding(.bottom, Tema.Apple.MostraAlCliente.Capitoli.dalBasso)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .prismaScalaTesto(max(scala, V.scalaMinima))
    }

    @ViewBuilder private func contenuto(_ c: Cliente) -> some View {
        switch capitolo {
        case .quadro: CapitoloQuadro(cliente: c)
        case .posizioni: CapitoloPosizioni(cliente: c)
        case .obiettivi: CapitoloObiettivi(cliente: c)
        case .tempo: CapitoloNelTempo(cliente: c)
        case .sala: EmptyView()
        }
    }
}

/// Sopra la barra superiore: il menu dell'avatar e le schede delle parole e delle ipotesi (con il loro velo).
struct StratoSopraVistaCliente: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaScalaTesto) private var scala

    var body: some View {
        let _ = ContaCorpi.segna()
        ZStack(alignment: .topTrailing) {
            #if os(macOS)
            if stato.inVistaCliente {
                // Migliorie d'uso 58: l'iPad segue la vista del cliente; la riga di conferma delle cifre dei capitoli
                OsservatoreLuogo(tavolo: stato.tavolo)
                ConfermaCifreLuogo()
                    .padding(.top, Tema.Apple.Misura.Barra.altezza + Tema.Apple.MostraAlCliente.Luogo.sottoBarraConferma)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            if stato.inVistaCliente && stato.menuLuogo {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { stato.menuLuogo = false }
                MenuLuogo(tavolo: stato.tavolo)
                    .padding(.top, Tema.Apple.Misura.Barra.altezza + Tema.Apple.MostraAlCliente.Luogo.dallAlto)
                    .padding(.trailing, Tema.Apple.MostraAlCliente.Luogo.rientroMenu)
            }
            #endif
            if stato.inVistaCliente && stato.menuUscitaMostra {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { stato.menuUscitaMostra = false }
                MenuUscitaMostra()
                    .padding(.top, Tema.Apple.Misura.Barra.altezza + Tema.Apple.MostraAlCliente.Uscita.dallAlto)
                    .padding(.trailing, Tema.Apple.BarraAlta.margineDestro)
            }
            if stato.inVistaCliente, let s = stato.schedaMostra {
                SchedaVistaCliente(scheda: s)
                    .prismaScalaTesto(max(scala, V.scalaMinima))
            }
            #if os(macOS)
            // Migliorie d'uso 58: la presa visione di ciò che si vede (PresaVisioneMac.swift)
            if stato.inVistaCliente && stato.presaVisioneAperta, let c = stato.clienteAttivo {
                SchedaPresaVisione(tavolo: stato.tavolo, cliente: c)
            }
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

/// La schermata neutra: sopra tutto tranne l'acqua (che continua a muoversi), il logo e «Tocca per riprendere».
/// Un clic o Esc la chiude.
struct SchermataNeutraMac: View {
    @Environment(StatoShell.self) var stato

    private typealias N = Tema.Apple.MostraAlCliente.Neutra

    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: N.spazio) {
                LogoPrisma(colore: N.coloreLogo)
                    .frame(height: N.logo)
                    .accessibilityHidden(true)
                Text(TestiMostra.tocca)
                    .carattereApple(N.testo)
                    .foregroundColor(N.coloreTesto)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { stato.chiudiNeutra() }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { stato.chiudiNeutra() }
    }
}

// MARK: - La barra dei capitoli

private struct BarraCapitoli: View {
    @Environment(StatoShell.self) var stato
    let scelto: CapitoloCliente

    private typealias C = Tema.Apple.MostraAlCliente.Capitoli

    var body: some View {
        HStack(spacing: C.spazio) {
            ForEach(CapitoloCliente.allCases) { c in
                Button { stato.cambiaCapitolo(c) } label: {
                    Text(c.titolo)
                        .carattereApple(C.voce)
                        .foregroundColor(c == scelto ? C.coloreScelta : C.colore)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, C.paddingVoce)
                        .frame(height: C.altezza)
                        .background {
                            if c == scelto {
                                Capsule(style: .continuous)
                                    .fill(C.fondoScelta)
                                    .shadow(color: C.ombraScelta, radius: C.raggioOmbra, y: C.yOmbra)
                            }
                        }
                        .contentShape(Capsule(style: .continuous))
                }
                .buttonStyle(StileSemplice())
                .accessibilityAddTraits(c == scelto ? .isSelected : [])
            }
        }
        .padding(C.padding)
        .superficieApple(C.superficie, raggio: Tema.Apple.Raggio.pillola)
    }
}

// MARK: - Il menu dell'avatar

private struct MenuUscitaMostra: View {
    @Environment(StatoShell.self) var stato

    private typealias U = Tema.Apple.MostraAlCliente.Uscita

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            RigaMenuUscita(glifo: "lock", testo: TestiMostra.fine, tasto: TestiMostra.tastoFine) { stato.fineMostra() }
            RigaMenuUscita(glifo: "water.waves", testo: TestiMostra.schermataNeutra, tasto: nil) { stato.mostraNeutra() }
        }
        .padding(U.padding)
        .frame(width: U.larghezza)
        .superficieApple(U.superficie, raggio: U.raggio)
    }
}

private struct RigaMenuUscita: View {
    let glifo: String
    let testo: String
    let tasto: String?
    let azione: () -> Void
    @State private var sopra = false

    private typealias U = Tema.Apple.MostraAlCliente.Uscita

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: U.raggioRiga, style: .continuous)
        return Button(action: azione) {
            HStack(spacing: 10) {
                Image(systemName: glifo)
                    .carattereApple(U.riga)
                    .frame(width: 18)
                Text(testo)
                    .carattereApple(U.riga)
                Spacer(minLength: 0)
                if let tasto {
                    Text(tasto)
                        .carattereApple(U.tasto)
                        .foregroundColor(U.coloreTasto)
                }
            }
            .foregroundColor(U.coloreRiga)
            .padding(U.paddingRiga)
            .background(forma.fill(sopra ? U.sopra : Color.clear))
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .onHover { s in withAnimation(Tema.Moto.passaggio) { sopra = s } }
    }
}

// MARK: - Il menu dell'etichetta del luogo (migliorie d'uso 58)

/// Il menu sotto «Su questo schermo» / «iPad sul tavolo», con le voci del template nell'ordine. Osserva il tavolo per la
/// voce spenta «iPad non collegato».
private struct MenuLuogo: View {
    @Environment(StatoShell.self) var stato
    @ObservedObject var tavolo: TavoloMac

    private typealias U = Tema.Apple.MostraAlCliente.Uscita
    private typealias L = Tema.Apple.MostraAlCliente.Luogo

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if stato.luogoCliente == .tavolo {
                RigaMenuUscita(glifo: TestiLuogo.glifoSchermo, testo: TestiLuogo.torna, tasto: nil) { stato.tornaSulloSchermo() }
                Rectangle()
                    .fill(L.filo)
                    .frame(height: 1)
                    .padding(L.paddingFilo)
                RigaMenuUscita(glifo: "hand.tap", testo: TestiLuogo.tocca(stato.tavoloTocca), tasto: nil) { stato.cambiaTocco() }
            } else {
                // Decisione 58-d: con il tavolo aperto e l'iPad non ancora collegato la voce resta, spenta
                let spenta = tavolo.acceso && !tavolo.collegato
                RigaMenuUscita(glifo: TestiLuogo.glifoTavolo, testo: TestiLuogo.manda,
                               tasto: tavolo.collegato ? nil : TestiLuogo.nonCollegato) { stato.mandaAlTavolo() }
                    .disabled(spenta)
                    .opacity(spenta ? L.opacitaSpenta : 1)
            }
            RigaMenuUscita(glifo: "hand.draw", testo: TestiLuogo.presa, tasto: nil) { stato.apriPresaVisione() }
        }
        .padding(U.padding)
        .frame(width: L.larghezza)
        .superficieApple(U.superficie, raggio: U.raggio)
    }
}

// MARK: - La vista ferma di un capitolo (migliorie d'uso 58)

/// Il contenuto di un capitolo nello stato finale, per l'immagine mandata all'iPad sul tavolo e per la pagina della presa
/// visione. Il capitolo «La Sala» è la griglia ferma.
struct CapitoloClienteFermo: View {
    let capitolo: CapitoloCliente
    let cliente: Cliente

    var body: some View {
        Group {
            switch capitolo {
            case .quadro: CapitoloQuadro(cliente: cliente)
            case .posizioni: CapitoloPosizioni(cliente: cliente)
            case .obiettivi: CapitoloObiettivi(cliente: cliente)
            case .tempo: CapitoloNelTempo(cliente: cliente)
            case .sala: GrigliaSalaFerma(cliente: cliente)
            }
        }
        .frame(maxWidth: V.larghezzaMassima, alignment: .topLeading)
        .padding(V.margini)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .prismaScalaTesto(V.scalaMinima)
    }
}

// MARK: - Le schede «Le parole» e «Le ipotesi»

private struct SchedaVistaCliente: View {
    @Environment(StatoShell.self) var stato
    let scheda: SchedaMostra

    private typealias S = Tema.Apple.MostraAlCliente.Scheda
    private typealias P = Tema.Apple.MostraAlCliente.Pannello

    var body: some View {
        ZStack {
            P.velo
                .contentShape(Rectangle())
                .onTapGesture { stato.schedaMostra = nil }
            VStack(alignment: .leading, spacing: S.spazio) {
                Text(occhiello)
                    .carattereApple(P.occhiello)
                    .foregroundColor(P.coloreOcchiello)
                Text(titolo)
                    .carattereApple(S.titolo)
                    .foregroundColor(Tema.Apple.Colore.inchiostro)
                    .fixedSize(horizontal: false, vertical: true)
                Text(testo)
                    .carattereApple(S.testo)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Spacer(minLength: 0)
                    Button(TestiMostra.hoCapito) { stato.schedaMostra = nil }
                        .buttonStyle(.applePrimario)
                        .fixedSize()
                }
                .padding(.top, S.sopraPulsante)
            }
            .padding(S.padding)
            .frame(width: S.larghezza)
            .superficieApple(S.superficie, raggio: S.raggio)
        }
    }

    private var occhiello: String {
        switch scheda {
        case .parola: return TestiMostra.parole
        case .ipotesi: return TestiMostra.ipotesi
        }
    }

    private var titolo: String {
        switch scheda {
        case .parola(let k): return Glossario.voce(k)?.termine ?? ""
        case .ipotesi: return TestiMostra.comeCalcolate
        }
    }

    /// La spiegazione del glossario (la stessa fonte della «i»), senza l'esempio con le cifre di prova.
    private var testo: String {
        switch scheda {
        case .parola(let k): return Glossario.voce(k)?.spiegazione ?? ""
        case .ipotesi: return TestiMostra.testoIpotesi
        }
    }
}

// MARK: - Pezzi comuni dei capitoli

/// Titolo 46 e sottotitolo 19 sull'acqua.
private struct TestataCapitolo: View {
    let titolo: String
    let sotto: String

    var body: some View {
        VStack(alignment: .leading, spacing: V.sottoTitolo) {
            Text(titolo)
                .carattereApple(V.titolo)
                .foregroundColor(V.coloreAcqua)
                .fixedSize(horizontal: false, vertical: true)
            Text(sotto)
                .carattereApple(V.sottotitolo)
                .foregroundColor(V.coloreAcqua2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, V.sottoTestata)
    }
}

/// Una parola tecnica che si tocca: sottolineatura a puntini, apre la scheda «Le parole» con la voce del glossario.
private struct ParolaSpiegata: View {
    @Environment(StatoShell.self) var stato
    let testo: String
    let chiave: VoceGlossario.Chiave
    var carattere: Tema.Apple.Carattere = V.piede
    var colore: Color = V.coloreAcqua2

    private typealias Pa = Tema.Apple.MostraAlCliente.Parola

    var body: some View {
        Button { stato.schedaMostra = .parola(chiave) } label: {
            Text(testo)
                .carattereApple(carattere)
                .foregroundColor(colore)
                .padding(.bottom, Pa.distanza)
                .overlay(alignment: .bottom) {
                    LineaPuntini()
                        .stroke(colore, style: StrokeStyle(lineWidth: Pa.spessore, lineCap: .round, dash: Pa.trattino))
                        .frame(height: Pa.spessore)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(StileSemplice())
        .help(Glossario.voce(chiave)?.breve ?? testo)
    }
}

private struct LineaPuntini: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.midY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        return p
    }
}

/// In fondo a ogni capitolo: «ⓘ Come sono calcolate queste cifre» e le parole da toccare.
private struct PiedeCapitolo: View {
    @Environment(StatoShell.self) var stato
    var parole: [(String, VoceGlossario.Chiave)] = []

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: V.spazioPiede) {
            Button { stato.schedaMostra = .ipotesi } label: {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                    Text(TestiMostra.comeCalcolate)
                }
                .carattereApple(V.piede)
                .foregroundColor(V.coloreAcqua2)
                .contentShape(Rectangle())
            }
            .buttonStyle(StileSemplice())
            ForEach(parole, id: \.1) { parola in
                ParolaSpiegata(testo: parola.0, chiave: parola.1)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, V.sopraPiede)
    }
}

extension View {
    /// Un riquadro di vetro della vista pulita: raggio 30, padding 26×30.
    fileprivate func riquadroVistaCliente() -> some View {
        self
            .padding(V.padding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .superficieApple(V.superficie, raggio: V.raggio)
    }
}

// MARK: - Il quadro

private struct CapitoloQuadro: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    var body: some View {
        let id = cliente.id
        let famiglia = !cliente.famiglia.isEmpty
        // In cache (DerivatiDati): cambiare capitolo non rifà i motori
        let frasi: [FraseArea] = stato.ricavato("mostra-quadro|\(id)") {
            FrasiCliente.quadro(analisi: stato.analisi360(id), posizioni: stato.posizioniCliente(id),
                                aree: stato.aree360(id), famiglia: famiglia)
        }
        let righe: [[FraseArea]] = [Array(frasi.prefix(2)), Array(frasi.dropFirst(2).prefix(2))]
        return VStack(alignment: .leading, spacing: 0) {
            TestataCapitolo(titolo: TestiMostra.titoloQuadro(TestiTraguardi.primoNome(cliente.nome)),
                            sotto: TestiMostra.sottoQuadro)
            VStack(spacing: V.spazio) {
                ForEach(0..<righe.count, id: \.self) { r in
                    HStack(spacing: V.spazio) {
                        ForEach(Array(righe[r].enumerated()), id: \.element.id) { k, f in
                            RiquadroAreaCliente(frase: f, indice: r * 2 + k)
                        }
                    }
                }
            }
            .frame(height: V.altezzaQuadro)
            PiedeCapitolo(parole: [("divario previdenziale", .divarioPrevidenziale),
                                   ("capitale caso morte", .capitaleMorte),
                                   ("indicatore di rischio (SRI)", .sri)])
        }
    }
}

private struct RiquadroAreaCliente: View {
    let frase: FraseArea
    let indice: Int

    var body: some View {
        let colore = Tema.Apple.Aree360.colore(frase.area)
        return HStack(alignment: .center, spacing: V.spazioArea) {
            Anello(frazione: frase.frazione ?? 0, colore: colore, misura: V.anelloQuadro, spessore: V.spessoreQuadro) {
                centro
                    .frame(maxWidth: max(0, V.anelloQuadro - 2 * V.spessoreQuadro))
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(TestiAree360.nomeArea(frase.area))
                    .carattereApple(V.occhiello)
                    .foregroundColor(colore)
                    .lineLimit(1)
                Text(frase.frase)
                    .carattereApple(V.frase)
                    .foregroundColor(V.colore)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, V.sopraFrase)
                Text(frase.seconda)
                    .carattereApple(V.testo)
                    .foregroundColor(V.colore2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, V.sopraTesto)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .riquadroVistaCliente()
        .entrataCascata(indice, sfocatura: false)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var centro: some View {
        if let v = frase.valore, frase.unita == .percentuale {
            NumeroCheConta(v, formato: .percentuale, indice: indice)
                .carattereApple(V.cifraQuadro)
                .foregroundColor(V.colore)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        } else if let v = frase.valore {
            VStack(spacing: 0) {
                NumeroCheConta(v, formato: .mesi, indice: indice)
                    .carattereApple(V.cifraQuadro)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(TestiAree360.mesi(v) == "1" ? TestiQuadroDossier.mese : TestiQuadroDossier.mesi)
                    .carattereApple(V.cifraMesi)
                    .lineLimit(1)
            }
            .foregroundColor(V.colore)
        } else {
            Text("—")
                .carattereApple(V.cifraQuadro)
                .foregroundColor(V.colore2)
        }
    }
}

// MARK: - Le posizioni

/// Le posizioni in essere del cliente com'è giusto mostrarle a lui: attività, debiti, patrimonio netto e la ripartizione
/// per area (in cache con `ricavato`).
struct RiepilogoPosizioniCliente {
    let righe: [Posizione]
    let attivita: Double
    let debiti: Double
    /// Le attività per area (senza protezioni e debiti), dalla più grande.
    let perArea: [(area: AreaPosizione, valore: Double)]

    var netto: Double { attivita - debiti }

    static func calcola(_ posizioni: [Posizione]) -> RiepilogoPosizioniCliente {
        let inEssere = posizioni.filter { $0.stato == .inEssere }
        let attive = inEssere.filter { $0.area != .protezione && $0.area != .debiti }
        let debiti = inEssere.filter { $0.area == .debiti }.reduce(0) { $0 + max(0, $1.valore) }
        var somme: [AreaPosizione: Double] = [:]
        for p in attive { somme[p.area, default: 0] += max(0, p.valore) }
        let perArea = AreaPosizione.allCases.compactMap { a -> (area: AreaPosizione, valore: Double)? in
            guard let v = somme[a], v > 0.5 else { return nil }
            return (a, v)
        }.sorted { $0.valore > $1.valore }
        let righe = inEssere.sorted { a, b in
            a.area == b.area ? a.nome.localizedCaseInsensitiveCompare(b.nome) == .orderedAscending
                : (AreaPosizione.allCases.firstIndex(of: a.area) ?? 0) < (AreaPosizione.allCases.firstIndex(of: b.area) ?? 0)
        }
        return RiepilogoPosizioniCliente(righe: righe, attivita: perArea.reduce(0) { $0 + $1.valore }, debiti: debiti,
                                         perArea: perArea)
    }
}

private struct CapitoloPosizioni: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    var body: some View {
        let id = cliente.id
        let r: RiepilogoPosizioniCliente = stato.ricavato("mostra-posizioni|\(id)") {
            RiepilogoPosizioniCliente.calcola(stato.posizioniCliente(id))
        }
        return VStack(alignment: .leading, spacing: 0) {
            TestataCapitolo(titolo: TestiMostra.titoloPosizioni, sotto: TestiMostra.sottoPosizioni)
            HStack(alignment: .top, spacing: V.spazio) {
                sinistra(r)
                    .frame(width: V.larghezzaSinistra)
                    .riquadroVistaCliente()
                    .frame(width: V.larghezzaSinistra)
                    .entrataCascata(0, sfocatura: false)
                destra(r)
                    .riquadroVistaCliente()
                    .entrataCascata(1, sfocatura: false)
            }
            .fixedSize(horizontal: false, vertical: true)
            PiedeCapitolo(parole: [("in essere", .inEssere), ("patrimonio netto", .patrimonioNetto)])
        }
    }

    private func sinistra(_ r: RiepilogoPosizioniCliente) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ParolaSpiegata(testo: TestiMostra.patrimonioNetto, chiave: .patrimonioNetto, carattere: V.etichetta,
                           colore: V.colore2)
            NumeroCheConta(r.netto)
                .carattereApple(V.cifraGrande)
                .foregroundColor(r.netto < 0 ? V.debito : V.colore)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(TestiMostra.possiedi(Formati.euro(r.attivita), Formati.euro(r.debiti)))
                .carattereApple(V.testo)
                .foregroundColor(V.colore2)
                .fixedSize(horizontal: false, vertical: true)
            if !r.perArea.isEmpty {
                Text(TestiMostra.doveSono)
                    .carattereApple(V.etichetta)
                    .foregroundColor(V.colore2)
                    .padding(.top, V.spazio * 1.5)
                    .padding(.bottom, V.spazioLegenda)
                BarraPienaSegmenti.composizione(r.perArea.map {
                    PezzoBarraPiena(id: $0.area.rawValue, peso: $0.valore, colore: V.area($0.area))
                })
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)],
                          alignment: .leading, spacing: V.spazioLegenda) {
                    ForEach(r.perArea, id: \.area) { voce in
                        HStack(spacing: V.spazioLegenda) {
                            RoundedRectangle(cornerRadius: V.raggioQuadratino, style: .continuous)
                                .fill(V.area(voce.area))
                                .frame(width: V.quadratino, height: V.quadratino)
                            Text("\(voce.area.nome) \(Int((voce.valore / max(r.attivita, 1) * 100).rounded()))%")
                                .carattereApple(V.legenda)
                                .foregroundColor(V.colore)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.top, V.spazio)
            }
        }
    }

    private func destra(_ r: RiepilogoPosizioniCliente) -> some View {
        VStack(alignment: .leading, spacing: V.spazioRighe) {
            if r.righe.isEmpty {
                Text(TestiMostra.nessunaPosizione)
                    .carattereApple(V.testo)
                    .foregroundColor(V.colore2)
            }
            ForEach(r.righe) { p in
                RigaPosizioneCliente(posizione: p)
                if p.id != r.righe.last?.id {
                    Divider()
                }
            }
        }
    }
}

private struct RigaPosizioneCliente: View {
    let posizione: Posizione

    var body: some View {
        let p = posizione
        let protezione = p.area == .protezione
        let debito = p.area == .debiti
        let importo = protezione ? (p.capitaleAssicurato ?? 0) : max(0, p.valore)
        let conCanale = p.area != .immobili && p.area != .debiti && p.area != .liquidita
        return HStack(alignment: .center, spacing: V.spazioArea / 2) {
            RoundedRectangle(cornerRadius: V.raggioQuadratino, style: .continuous)
                .fill(V.area(p.area))
                .frame(width: V.quadratino, height: V.quadratino)
            VStack(alignment: .leading, spacing: 2) {
                Text(p.nome)
                    .carattereApple(V.nomePosizione)
                    .foregroundColor(V.colore)
                    .lineLimit(1)
                Text(protezione ? "\(p.area.nome) · \(TestiMostra.capitaleAssicurato)" : p.area.nome)
                    .carattereApple(V.areaPosizione)
                    .foregroundColor(V.colore2)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if conCanale {
                EtichettaCanaleApple(canale: p.canale, compatta: true)
            }
            Text((debito ? Formati.meno : "") + Formati.euro(importo))
                .carattereApple(V.importo)
                .foregroundColor(debito ? V.debito : V.colore)
                .lineLimit(1)
                .fixedSize()
        }
        .frame(minHeight: V.rigaPosizione)
    }
}

// MARK: - Gli obiettivi

private struct CapitoloObiettivi: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    var body: some View {
        let obiettivi = stato.obiettiviCliente(cliente.id)
        return VStack(alignment: .leading, spacing: 0) {
            TestataCapitolo(titolo: TestiMostra.titoloObiettivi(obiettivi.count),
                            sotto: TestiMostra.sottoObiettivi(obiettivi.count))
            if obiettivi.isEmpty {
                Text(TestiMostra.nessunObiettivo)
                    .carattereApple(V.testo)
                    .foregroundColor(V.colore2)
                    .riquadroVistaCliente()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: V.larghezzaObiettivo), spacing: V.spazio)],
                          alignment: .leading, spacing: V.spazio) {
                    ForEach(Array(obiettivi.enumerated()), id: \.element.id) { k, o in
                        RiquadroObiettivoCliente(obiettivo: o, avanzamento: stato.avanzamento(o), indice: k)
                    }
                }
            }
            PiedeCapitolo()
        }
    }
}

private struct RiquadroObiettivoCliente: View {
    let obiettivo: Obiettivo
    let avanzamento: AvanzamentoObiettivo
    let indice: Int

    var body: some View {
        let o = obiettivo
        let a = avanzamento
        let percento = MotoreAree360.percentuale(a.quota)
        let mensile = a.versamentiAttivi + o.versamentoMensile
        return VStack(spacing: V.sopraTesto) {
            Anello(frazione: a.quota, colore: V.coloreObiettivo, misura: V.anelloObiettivo, spessore: V.spessoreObiettivo) {
                NumeroCheConta(percento, formato: .percentuale, indice: indice)
                    .carattereApple(V.cifraObiettivo)
                    .foregroundColor(V.colore)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(.bottom, V.sopraFrase)
            Text(o.titolo)
                .carattereApple(V.nomeObiettivo)
                .foregroundColor(V.colore)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(TestiMostra.messoDaParte(Formati.euro(a.accantonato), Formati.euro(o.importo)))
                .carattereApple(V.testoObiettivo)
                .foregroundColor(V.colore)
            Text(TestiMostra.alMese(mensile >= 0.5 ? Formati.euro(mensile) : nil, Formati.meseAnno.string(from: o.scadenza)))
                .carattereApple(V.testoObiettivo)
                .foregroundColor(V.colore2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .riquadroVistaCliente()
        .entrataCascata(indice, sfocatura: false)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Nel tempo

private struct CapitoloNelTempo: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    var body: some View {
        // In cache per cliente (analisiDossier): MotorePatrimonio, oggi, a 10 e a 20 anni, con e senza le proposte
        let p = stato.analisiDossier(cliente.id).patrimonio
        let meta = p.anni / 2
        return VStack(alignment: .leading, spacing: 0) {
            TestataCapitolo(titolo: TestiMostra.titoloTempo, sotto: TestiMostra.sottoTempo)
            HStack(spacing: V.spazio) {
                cifra(TestiMostra.oggi, p.nettoOggi, indice: 0, colore: V.colore)
                cifra(TestiMostra.traAnni(meta), p.valore(meta), indice: 1, colore: V.colore)
                cifra(TestiMostra.traAnni(p.anni), p.valore(p.anni), indice: 2, colore: V.colore)
                if p.conProposte != nil {
                    cifra(TestiMostra.conProposte, p.valore(p.anni, conProposte: true), indice: 3, colore: V.coloreProposte)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            GraficoNelTempoCliente(patrimonio: p)
                .riquadroVistaCliente()
                .padding(.top, V.spazio)
                .entrataCascata(4, sfocatura: false)
            PiedeCapitolo(parole: [("patrimonio netto", .patrimonioNetto)])
        }
    }

    private func cifra(_ titolo: String, _ valore: Double, indice: Int, colore: Color) -> some View {
        VStack(alignment: .leading, spacing: V.sopraFrase) {
            Text(titolo)
                .carattereApple(V.etichetta)
                .foregroundColor(V.colore2)
            NumeroCheConta(valore, indice: indice)
                .carattereApple(V.cifraTempo)
                .foregroundColor(colore)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .riquadroVistaCliente()
        .entrataCascata(indice, sfocatura: false)
    }
}

/// Il grafico largo del patrimonio: la linea del totale sopra la sua area sfumata e, solo se ci sono proposte, la linea
/// viola tratteggiata; a destra le cifre dell'asse, sotto «oggi», «tra 10 anni», «tra 20 anni». Nessuna fascia.
private struct GraficoNelTempoCliente: View {
    let patrimonio: PatrimonioNelTempo

    var body: some View {
        let p = patrimonio
        let valori = p.oggi.map(\.valore) + (p.conProposte?.map(\.valore) ?? [])
        let minimo = min(0, valori.min() ?? 0)
        let massimo = max(minimo + 1, valori.max() ?? 1)
        let anni = Double(max(1, p.anni))
        func punti(_ serie: [PuntoProiezione]) -> [CGPoint] {
            serie.map { CGPoint(x: Double($0.anno) / anni, y: ($0.valore - minimo) / (massimo - minimo)) }
        }
        return VStack(alignment: .leading, spacing: V.sopraTesto) {
            HStack(alignment: .top, spacing: V.spazio) {
                ZStack {
                    TracciatoGrafico(punti: punti(p.oggi), colore: V.coloreTotale, spessore: V.spessoreTotale,
                                     area: true, opacitaArea: V.opacitaArea, puntoFinale: true)
                    if let proposte = p.conProposte {
                        TracciatoGrafico(punti: punti(proposte), colore: V.coloreProposte, spessore: V.spessoreProposte,
                                         tratteggio: V.tratteggioProposte, indice: 1)
                    }
                }
                .frame(height: V.altezzaGrafico)
                .frame(maxWidth: .infinity)
                VStack(alignment: .leading) {
                    Text(Formati.euroBreve(massimo))
                    Spacer(minLength: 0)
                    Text(Formati.euroBreve((massimo + minimo) / 2))
                    Spacer(minLength: 0)
                    Text(Formati.euroBreve(minimo))
                }
                .carattereApple(V.asse)
                .foregroundColor(V.colore2)
                .lineLimit(1)
                .frame(width: V.larghezzaAsse, height: V.altezzaGrafico, alignment: .leading)
            }
            HStack {
                Text(TestiMostra.asseOggi)
                Spacer(minLength: 0)
                Text(TestiMostra.asseAnni(p.anni / 2))
                Spacer(minLength: 0)
                Text(TestiMostra.asseAnni(p.anni))
            }
            .carattereApple(V.etichettaAsse)
            .foregroundColor(V.colore2)
            .padding(.trailing, V.larghezzaAsse + V.spazio)
        }
    }
}
#endif
