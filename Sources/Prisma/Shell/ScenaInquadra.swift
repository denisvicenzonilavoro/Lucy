#if os(macOS)
import AppKit
import SwiftUI
import UniformTypeIdentifiers

// Inquadra e capisci sul Mac (Design/template-novita-specifica.md §9.1, §9.2, §9.3, §9.4):
//
//   ┌ velo scuro sfocato sopra barra, finestre e dock ─────────────────────────────────────────────┐
//   │      ┌──────────┐                                                                            │
//   │      │ ▬▬ tacca │        ┌ ● PRISMA SUL MAC ─────────────────────── ✕ ┐                     │
//   │      │ ┌──────┐ │        │ Letta: un dato da controllare                │                     │
//   │      │ │foglio│ │        │ ✓ Contraente          Giulia Rossi           │                     │
//   │      │ │ ──── │ │        │ ✓ Premio              90 € al mese           │                     │
//   │      │ └──────┘ │        │ …                                             │                     │
//   │      │ ✓ Fatto  │        │ [Controlla il dato in arancione] [Confronta] │                     │
//   │      └──────────┘        └──────────────────────────────────────────────┘                     │
//   └──────────────────────────────────────────────────────────────────────────────────────────────┘
//
// - Il testo arriva dall'iPhone sul ponte cifrato (attesa) oppure da una foto o un PDF trascinati sulla scena (o scelti
//   con «Scegli un file…»), letti sul Mac con LetturaDocumenti. Niente fotocamera sul Mac.
// - Il telefono disegnato mostra il foglio letto: la foto con i riquadri, o il foglio ricostruito dalle righe.
// - Movimento: velo in 0,3 s; iPhone da y +60 e −4° con la molla leggera in 0,7 s; linea della scansione giù e su in
//   2 × 1,1 s (si ferma in alto); righe a cascata (StatoInquadra); tabella da y +10 in 0,45 s; chiusura in 0,22 s.
//   «Riduci movimento»: tutto fermo con la dissolvenza di 0,15 s, niente linea. Istantanee: stato finale, linea in alto.
// - Esc chiude la scena (prima di tutto il resto; mentre si corregge una riga annulla la modifica); Invio è il pulsante
//   principale. Un clic sul velo non fa nulla.
// - Migliorie d'uso 43 («Prima di aggiungere, si controlla»): «Di chi è» in testa alle righe, ogni valore si corregge con
//   un clic, i dati incerti (regole di `MotoreInquadra.daControllare`) sono in arancione con «Va bene», e finché ce n'è
//   uno il pulsante principale è «Controlla il dato in arancione»; poi la conferma di sempre. In fondo «Senza iPhone?».

/// Lo strato della scena nella shell (sopra barra, finestre e dock): vuoto quando la scena è chiusa.
struct StratoInquadra: View {
    let inquadra: StatoInquadra
    @Environment(\.modoIstantanea) private var istantanea
    @Environment(\.prismaCalmo) private var calmo

    var body: some View {
        ZStack {
            if inquadra.aperto {
                ScenaInquadra(inquadra: inquadra)
                    .transition(transizione)
            }
        }
    }

    private var transizione: AnyTransition {
        guard !istantanea else { return .identity }
        let m = Tema.Apple.Moto.Inquadra.self
        return .asymmetric(insertion: AnyTransition.opacity.animation(calmo ? Tema.Moto.dissolvenzaCalma : m.velo),
                           removal: AnyTransition.opacity.animation(calmo ? Tema.Moto.dissolvenzaCalma : m.chiusura))
    }
}

/// Il velo, l'iPhone disegnato e la scheda «Prisma sul Mac», centrati; la scena si rimpicciolisce nelle finestre basse.
struct ScenaInquadra: View {
    @Environment(StatoShell.self) var stato
    let inquadra: StatoInquadra

    private typealias D = Tema.Apple.Inquadra.Disposizione
    private typealias A = Tema.Apple.Inquadra.Apparecchio

    var body: some View {
        let _ = ContaCorpi.segna()
        GeometryReader { geo in
            ZStack {
                // Il velo comune della scena del telefono (DesignSystem/Apple/ScenaTelefono.swift)
                VeloScena()
                HStack(alignment: .top, spacing: D.spazio) {
                    TelefonoInquadra(inquadra: inquadra)
                    SchedaInquadraMac(inquadra: inquadra)
                        .padding(.top, D.scartoScheda)
                }
                .scaleEffect(scala(geo.size))
                // Esc chiude la scena, prima di Novità, dettaglio, notifiche e finestra (non mentre si corregge una
                // riga: lì Esc annulla la modifica, migliorie d'uso 43)
                Button("Chiudi Inquadra e capisci") { stato.chiudiInquadra() }
                    .keyboardShortcut(.cancelAction)
                    .buttonStyle(StileSemplice())
                    .opacity(0)
                    .frame(width: 0, height: 0)
                    .disabled(inquadra.inModifica != nil)
                    .accessibilityHidden(true)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        // Una foto o un PDF lasciati ovunque sulla scena vanno letti qui (non importati in Documenti)
        .onDrop(of: [.fileURL], isTargeted: Binding(get: { inquadra.fileSopra },
                                                     set: { inquadra.fileSopra = $0 && accetta })) { fornitori in
            guard accetta, let f = fornitori.first else { return false }
            _ = f.loadObject(ofClass: URL.self) { url, _ in
                guard let url else { return }
                DispatchQueue.main.async { stato.leggiFileInquadra(url) }
            }
            return true
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Inquadra e capisci"))
    }

    /// Mentre il Mac legge un file non se ne accetta un altro.
    private var accetta: Bool { inquadra.fase != .lettura && !stato.solaLettura }

    private func scala(_ misura: CGSize) -> CGFloat {
        let larghezza = A.larghezza + D.spazio + Tema.Apple.Inquadra.Scheda.larghezza
        let altezza = A.altezza + D.scartoScheda
        let s = min(1, (misura.width - 2 * D.margine) / larghezza, (misura.height - 2 * D.margine) / altezza)
        return max(D.scalaMinima, s)
    }
}

// MARK: - L'iPhone disegnato

/// L'iPhone con la tacca: nello schermo l'inquadratura, il foglio letto, la linea della scansione e la scritta.
private struct TelefonoInquadra: View {
    let inquadra: StatoInquadra
    @Environment(\.prismaStatoFinale) private var fermo
    @Environment(\.prismaScatto) private var scatto
    @State private var entrato = false

    private typealias A = Tema.Apple.Inquadra.Apparecchio
    private typealias F = Tema.Apple.Inquadra.Foglio

    var body: some View {
        let m = Tema.Apple.Moto.Inquadra.self
        let dentro = entrato || fermo
        // Il telefono disegnato comune (DesignSystem/Apple/ScenaTelefono.swift), con lo schermo di Inquadra
        return TelefonoDisegnato { schermo }
        .rotationEffect(.degrees(dentro ? 0 : m.rotazioneTelefono))
        .offset(y: dentro ? 0 : m.spostamentoTelefono)
        .opacity(dentro ? 1 : 0)
        .onAppear {
            guard !entrato, !scatto else { return }
            if fermo {
                entrato = true
            } else {
                withAnimation(m.telefono) { entrato = true }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("iPhone: \(scritta)"))
    }

    private var schermo: some View {
        let forma = RoundedRectangle(cornerRadius: A.raggioSchermo, style: .continuous)
        return ZStack(alignment: .top) {
            forma.fill(A.schermo)
            forma.fill(RadialGradient(colors: A.fotocamera, center: A.centroFotocamera, startRadius: 0, endRadius: A.raggioFotocamera))
            foglio
            if inquadra.dati != nil {
                LineaScansione(chiave: inquadra.dati?.testo ?? "")
            }
            VStack {
                Spacer(minLength: 0)
                Text(scritta)
                    .carattereApple(A.scritta)
                    .foregroundColor(A.coloreScritta)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, A.scrittaDalFondo)
            }
        }
        .clipShape(forma)
    }

    @ViewBuilder private var foglio: some View {
        if let d = inquadra.dati, !d.campi.isEmpty {
            if let img = inquadra.immagine {
                FoglioInquadra(righe: inquadra.righe, campi: d.campi, accesi: inquadra.campiAccesi, immagine: img)
                    .padding(.horizontal, A.margineImmagine)
                    .padding(.top, A.immagineDallAlto)
                    .padding(.bottom, A.immagineDalFondo)
                    .frame(maxHeight: .infinity, alignment: .top)
            } else {
                FoglioInquadra(righe: inquadra.righe, campi: d.campi, accesi: inquadra.campiAccesi)
                    .rotationEffect(.degrees(F.rotazione))
                    .padding(.horizontal, F.lati)
                    .padding(.top, F.dallAlto)
            }
        }
    }

    /// La scritta in basso: «Inquadra il documento», «Riconosco i dati…», «✓ Fatto».
    private var scritta: String {
        switch inquadra.fase {
        case .attesa: return inquadra.perSmontaggio ? "Inquadra l'estratto conto o il rendiconto" : "Inquadra il documento"
        case .trascina: return "Trascina la foto sul Mac"
        case .lettura: return "Riconosco i dati…"
        case .illeggibile: return "Riprova con più luce"
        case .letto:
            if inquadra.finito { return "✓ Fatto" }
            return inquadra.mostrate > 0 ? "Riconosco i dati…" : "Inquadra il documento"
        }
    }
}

/// La linea verde che scorre sul foglio: giù fino a 420 in 1,1 s e su in altri 1,1 s, poi resta in alto. Ferma in
/// alto nelle istantanee; con «Riduci movimento» non c'è. `chiave`: un foglio nuovo la fa ripartire.
private struct LineaScansione: View {
    let chiave: String
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.prismaStatoFinale) private var fermo
    @State private var giu = false
    @State private var giro = 0

    private typealias L = Tema.Apple.Inquadra.Linea

    var body: some View {
        if !calmo {
            LinearGradient(colors: [L.colore.opacity(0), L.colore, L.colore.opacity(0)], startPoint: .leading, endPoint: .trailing)
                .frame(height: L.altezza)
                .shadow(color: L.colore, radius: L.alone)
                .padding(.horizontal, L.lati)
                .offset(y: giu ? L.finoA : L.dallAlto)
                .frame(maxHeight: .infinity, alignment: .top)
                .allowsHitTesting(false)
                .onAppear(perform: scorri)
                .onChange(of: chiave) { _ in scorri() }
        }
    }

    private func scorri() {
        guard !fermo else { return }
        giro += 1
        let g = giro
        let m = Tema.Apple.Moto.Inquadra.self
        withAnimation(m.linea) { giu = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + m.durataLinea) {
            guard giro == g else { return }
            withAnimation(m.linea) { giu = false }
        }
    }
}

// MARK: - La scheda «Prisma sul Mac»

private struct SchedaInquadraMac: View {
    @Environment(StatoShell.self) var stato
    let inquadra: StatoInquadra

    private typealias S = Tema.Apple.Inquadra.Scheda

    var body: some View {
        let _ = ContaCorpi.segna()
        VStack(alignment: .leading, spacing: 0) {
            testa
            Text(titolo)
                .carattereApple(S.titolo)
                .foregroundColor(S.coloreTitolo)
                .padding(.top, S.titoloSopra)
                .accessibilityAddTraits(.isHeader)
            if let frase {
                Text(frase)
                    .carattereApple(S.frase)
                    .foregroundColor(S.coloreFrase)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, S.fraseSopra)
            }
            contenuto
        }
        .padding(S.padding)
        .frame(width: S.larghezza, alignment: .leading)
        .superficieApple(S.superficie)
    }

    private var testa: some View {
        HStack(spacing: S.spazioTesta) {
            SferaVera(misura: S.sfera, viva: true, pensa: inquadra.fase == .lettura)
            Text("Prisma sul Mac")
                .carattereApple(S.etichetta)
                .foregroundColor(S.coloreEtichetta)
            Spacer(minLength: 0)
            Button { stato.chiudiInquadra() } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.apple)
            .help("Chiudi (Esc)")
            .accessibilityLabel(Text("Chiudi"))
        }
    }

    // MARK: Testi

    private var titolo: String {
        switch inquadra.fase {
        case .attesa: return inquadra.perSmontaggio ? "Aspetto l'estratto conto…" : "Aspetto il documento…"
        case .trascina: return inquadra.perSmontaggio ? "Trascina l'estratto conto o il rendiconto" : "Trascina la polizza"
        case .lettura: return "Sto leggendo…"
        case .illeggibile: return "Non riesco a leggere il documento"
        case .letto:
            guard inquadra.finito, inquadra.dati != nil else { return "Sto leggendo…" }
            // Migliorie d'uso 43: il titolo dice se c'è ancora un dato da controllare
            let n = inquadra.dubbi(canale: stato.canaleEAreaInquadra.canale).count
            if n == 1 { return "Letta: un dato da controllare" }
            if n > 1 { return "Letta: \(n) dati da controllare" }
            return inquadra.pochiDati ? "Ho letto solo una parte" : "Letta e controllata"
        }
    }

    private var frase: String? {
        switch inquadra.fase {
        case .attesa:
            if inquadra.perSmontaggio {
                return "Inquadra l'estratto conto o il rendiconto con l'iPhone (Prisma › Posizioni › Inquadra): le righe arrivano allo Smontaggio, cifrate in rete locale. Oppure trascina qui una foto o un PDF."
            }
            return "Sull’iPhone apri Prisma › Posizioni › Inquadra: il testo letto arriva qui, cifrato in rete locale. Oppure trascina qui una foto o un PDF."
        case .trascina:
            return "L’iPhone non è collegato: collegalo in Impostazioni › iPhone e iPad, oppure trascina qui una foto o un PDF. Prisma lo legge sul Mac e non lo salva."
        case .lettura:
            return "Leggo «\(inquadra.origine)» sul Mac, senza mandarlo fuori."
        case .illeggibile:
            return inquadra.origine.isEmpty ? "Riprova con più luce, con il foglio intero e dritto."
                : "In «\(inquadra.origine)» non trovo i dati di una polizza: riprova con più luce, con il foglio intero e dritto."
        case .letto:
            guard inquadra.finito else { return nil }
            if inquadra.pochiDati { return "Le righe in grigio non sono sul foglio: toccale per scriverle, o completale nella posizione." }
            return inquadra.origine.isEmpty ? "Tocca un valore per correggerlo." : "Letto da \(inquadra.origine). Tocca un valore per correggerlo."
        }
    }

    // MARK: Contenuto

    @ViewBuilder private var contenuto: some View {
        switch inquadra.fase {
        case .attesa:
            ZonaInquadra(inquadra: inquadra)
                .padding(.top, Tema.Apple.Inquadra.Zona.sopra)
        case .trascina:
            ZonaInquadra(inquadra: inquadra)
                .padding(.top, Tema.Apple.Inquadra.Zona.sopra)
            // Migliorie d'uso 39: il trascinamento resta, e c'è il rimando a Impostazioni › iPhone e iPad
            RimandoCollegaDispositivo { stato.chiudiInquadra() }
                .padding(.top, S.pulsantiSopra)
        case .lettura:
            EmptyView()
        case .illeggibile:
            HStack(spacing: S.spazioPulsanti) {
                Button("Riprova") { stato.riprovaInquadra() }
                    .buttonStyle(.applePrimarioGrande)
                    .keyboardShortcut(.defaultAction)
                Button("Chiudi") { stato.chiudiInquadra() }
                    .buttonStyle(.appleGrande)
            }
            .padding(.top, S.pulsantiSopra)
        case .letto:
            letto
        }
    }

    @ViewBuilder private var letto: some View {
        let canale = stato.canaleEAreaInquadra.canale
        let righe = inquadra.righeCorrette(canale: canale)
        let dubbi: Set<String> = inquadra.finito ? inquadra.dubbi(canale: canale) : []
        VStack(alignment: .leading, spacing: 0) {
            // Migliorie d'uso 43: «Di chi è» in testa alle righe, con l'avviso se il documento è di un altro cliente
            if inquadra.finito {
                diChi(canale: canale)
                if let avviso = stato.avvisoClienteInquadra {
                    Text(avviso)
                        .carattereApple(S.avvisoAltroCliente)
                        .foregroundColor(S.coloreAvvisoAltroCliente)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, S.paddingAvvisoAltroCliente)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(alignment: .bottom) { Rectangle().fill(S.filo).frame(height: Tema.Apple.Misura.bordo) }
                }
            }
            ForEach(Array(righe.prefix(inquadra.mostrate).enumerated()), id: \.element.id) { _, r in
                RigaSchedaInquadraMac(inquadra: inquadra, riga: r, dubbio: dubbi.contains(r.id),
                                      correggibile: inquadra.finito && !stato.solaLettura && !inquadra.conferma)
                    .entrataStile(.rigaInquadra)
            }
        }
        .padding(.top, S.righeSopra)
        if inquadra.finito {
            if let c = inquadra.confronto {
                TabellaConfrontoInquadra(confronto: c, tipo: inquadra.datiCorretti?.tipo)
                    .entrataStile(.tabellaInquadra)
            }
            if inquadra.conferma && dubbi.isEmpty {
                conferma(canale: canale)
            } else {
                pulsanti(dubbi: dubbi.count)
            }
            senzaIPhone
        }
    }

    /// «Di chi è · letto dal documento»: l'avatar, il nome, il canale proposto e «Cambia» (il menu dei clienti).
    private func diChi(canale: Canale) -> some View {
        let c = stato.clienteInquadra
        let etichetta: String
        switch stato.origineClienteInquadra {
        case .scelto: etichetta = "Di chi è · scelto da te"
        case .letto: etichetta = "Di chi è · letto dal documento"
        case .attivo: etichetta = "Di chi è · il cliente su cui lavori · il documento non dice di chi è"
        case .daScegliere: etichetta = "Di chi è · da scegliere"
        }
        return HStack(spacing: S.spazioDiChi) {
            if let c {
                AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: S.avatarDiChi)
            } else {
                Circle().fill(S.fondoAvatarVuoto).frame(width: S.avatarDiChi, height: S.avatarDiChi)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(etichetta)
                    .carattereApple(S.etichettaDiChi)
                    .foregroundColor(S.coloreEtichettaDiChi)
                    .fixedSize(horizontal: false, vertical: true)
                Text(c?.nome ?? "Scegli il cliente")
                    .carattereApple(S.nomeDiChi)
                    .foregroundColor(c == nil ? S.coloreMancante : S.coloreNomeDiChi)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            EtichettaCanaleApple(canale: canale, compatta: true)
            Menu {
                ForEach(stato.clienti) { x in
                    Button(x.nome) { inquadra.clienteScelto = x.id }
                }
            } label: {
                Text("Cambia")
                    .carattereApple(S.cambia)
                    .foregroundColor(S.coloreCambia)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .disabled(stato.solaLettura)
            .help("Scegli un altro cliente per questo documento")
        }
        .padding(S.paddingDiChi)
        .overlay(alignment: .bottom) { Rectangle().fill(S.filo).frame(height: Tema.Apple.Misura.bordo) }
        .accessibilityElement(children: .contain)
    }

    /// Con un dato in dubbio il pulsante principale dice «Controlla il dato in arancione» (non blu): premuto, le righe
    /// in dubbio tremano. Senza dubbi «Aggiungi alle posizioni di …» (o «Aggiorna la posizione»), poi la conferma.
    private func pulsanti(dubbi: Int) -> some View {
        let c = stato.clienteInquadra
        let giaPresente = stato.posizioneGiaInquadrata != nil
        let nome = c.map { StatoShell.nomeBreveInquadra($0) } ?? "…"
        return HStack(spacing: S.spazioPulsanti) {
            if dubbi > 0 {
                Button(dubbi == 1 ? "Controlla il dato in arancione" : "Controlla i dati in arancione") { stato.scuotiDubbiInquadra() }
                    .buttonStyle(.appleGrande)
                    .keyboardShortcut(.defaultAction)
                    .help("Conferma con «Va bene» o correggi il dato in arancione prima di aggiungere")
                    .disabled(inquadra.inModifica != nil)
            } else if giaPresente {
                Button("Aggiorna la posizione") { stato.confrontaInquadrataConPosizione() }
                    .buttonStyle(.applePrimarioGrande)
                    .keyboardShortcut(.defaultAction)
                    .help("La polizza è già nelle posizioni del cliente: confronta i dati letti con quelli in Prisma")
                    .disabled(stato.solaLettura || inquadra.inModifica != nil)
            } else {
                Button("Aggiungi alle posizioni di \(nome)") { inquadra.conferma = true }
                    .buttonStyle(.applePrimarioGrande)
                    .keyboardShortcut(.defaultAction)
                    .disabled(c == nil || stato.solaLettura || inquadra.inModifica != nil)
                    .help(stato.solaLettura ? "Archivio in sola lettura: aggiorna Prisma per creare posizioni." : "Aggiungi la polizza alle posizioni del cliente, dopo la conferma")
            }
            if inquadra.confronto == nil && !giaPresente {
                Button("Confronta") { withAnimation(nil) { stato.confrontaInquadrata() } }
                    .buttonStyle(.appleGrande)
                    .help("La polizza letta a confronto con una temporanea caso morte")
            } else {
                Button("Chiudi") { stato.chiudiInquadra() }
                    .buttonStyle(.appleGrande)
            }
        }
        .padding(.top, S.pulsantiSopra)
    }

    /// «Senza iPhone? Scegli un file dal Mac» in fondo alla scheda, sopra un filo: ricomincia con il file scelto.
    private var senzaIPhone: some View {
        HStack(spacing: S.spazioSenzaIPhone) {
            Text("Senza iPhone?")
                .carattereApple(S.senzaIPhone)
                .foregroundColor(S.coloreSenzaIPhone)
            Button("Scegli un file dal Mac") { stato.scegliFileInquadra() }
                .buttonStyle(StileSemplice())
                .carattereApple(S.linkSenzaIPhone)
                .foregroundColor(S.coloreLinkSenzaIPhone)
                .disabled(stato.solaLettura)
                .help("Si sceglie un PDF o una foto dal Mac, come con «Importa»")
            Spacer(minLength: 0)
        }
        .padding(.top, S.senzaIPhoneDalFilo)
        .overlay(alignment: .top) { Rectangle().fill(S.filo).frame(height: Tema.Apple.Misura.bordo) }
        .padding(.top, S.filoSenzaIPhoneSopra)
    }

    /// Niente entra nel dossier senza conferma: la frase dice cosa succede, poi «Conferma e aggiungi».
    private func conferma(canale: Canale) -> some View {
        let c = stato.clienteInquadra
        let area = stato.canaleEAreaInquadra.area
        let nome = c.map { StatoShell.nomeBreveInquadra($0) } ?? "cliente"
        let frase = "Aggiungo a Posizioni di \(nome) una polizza in essere, canale \(canale.nomeBreve.lowercased()), area \(area.nome.lowercased()), con i dati qui sopra: entrano nel dossier come confermati. Il documento resta in Documenti, senza la foto."
        return VStack(alignment: .leading, spacing: S.spazioPulsanti) {
            Text(frase)
                .carattereApple(S.fraseConferma)
                .foregroundColor(S.coloreFrase)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: S.spazioPulsanti) {
                Button("Conferma e aggiungi") { stato.aggiungiInquadrata() }
                    .buttonStyle(.applePrimarioGrande)
                    .keyboardShortcut(.defaultAction)
                Button("Annulla") { inquadra.conferma = false }
                    .buttonStyle(.appleGrande)
            }
        }
        .padding(S.paddingConferma)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(S.superficieConferma)
        .padding(.top, S.confermaSopra)
    }
}

// MARK: - Una riga della scheda, correggibile (solo Mac)

/// Migliorie d'uso 43: la riga della scheda del Mac (la `RigaSchedaInquadra` comune resta all'iPhone). Stessa grafica,
/// in più: il valore si corregge con un clic (aiuto «Tocca per correggere», fondo `chip` al passaggio; Invio conferma,
/// Esc annulla), la matita «scritto da te» dopo una correzione e, per il dato in dubbio, il fondo arancio tenue, il «?»
/// arancio e «Va bene». Le righe in dubbio tremano con `scosse` (niente con «Riduci movimento»).
private struct RigaSchedaInquadraMac: View {
    let inquadra: StatoInquadra
    let riga: RigaInquadra
    let dubbio: Bool
    let correggibile: Bool
    @Environment(\.prismaCalmo) private var calmo
    @State private var testo = ""
    @State private var sopra = false
    @FocusState private var fuoco: Bool

    private typealias S = Tema.Apple.Inquadra.Scheda
    private typealias M = Tema.Apple.Moto.Inquadra

    private var inModifica: Bool { inquadra.inModifica == riga.id }
    private var corretta: Bool { inquadra.corretta(riga.id) }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            segno
                .frame(width: S.larghezzaSpunta, alignment: .leading)
            Text(riga.etichetta)
                .carattereApple(S.etichettaRiga)
                .foregroundColor(riga.trovata ? S.coloreEtichettaRiga : S.coloreMancante)
                .frame(width: S.larghezzaEtichetta, alignment: .leading)
            if inModifica {
                TextField(riga.etichetta, text: $testo)
                    .textFieldStyle(.roundedBorder)
                    .font(S.campoCorrezione.font)
                    .focused($fuoco)
                    .onSubmit(conferma)
                    .onExitCommand(perform: annulla)
                    .onAppear {
                        if testo.isEmpty { testo = inquadra.correzioni[riga.id] ?? riga.valore ?? "" }
                        fuoco = true
                    }
            } else {
                valore
                Spacer(minLength: 0)
                if dubbio {
                    Button("Va bene") { _ = inquadra.confermate.insert(riga.id) }
                        .buttonStyle(.apple)
                        .disabled(!correggibile)
                        .help("Il dato è giusto così")
                }
            }
        }
        .padding(.vertical, S.paddingRiga)
        .padding(.horizontal, dubbio ? S.paddingDubbio : 0)
        .background {
            if dubbio {
                RoundedRectangle(cornerRadius: S.raggioDubbio, style: .continuous).fill(S.fondoDubbio)
            }
        }
        .overlay(alignment: .bottom) {
            if !dubbio { Rectangle().fill(S.filo).frame(height: Tema.Apple.Misura.bordo) }
        }
        .modifier(ScuotiEffetto(ampiezza: dubbio && !calmo ? M.ampiezzaScossa : 0, volte: M.volteScossa,
                                animatableData: inquadra.scosse))
        .accessibilityElement(children: inModifica ? .contain : .combine)
        .accessibilityHint(correggibile && !inModifica ? Text("Tocca per correggere") : Text(""))
    }

    /// Il valore (o «non letto»): un clic apre il campo sul posto.
    private var valore: some View {
        Text(riga.valore ?? "non letto")
            .carattereApple(riga.trovata ? S.valore : S.etichettaRiga)
            .foregroundColor(riga.trovata ? S.coloreValore : S.coloreMancante)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(S.paddingValore)
            .background {
                RoundedRectangle(cornerRadius: S.raggioValore, style: .continuous)
                    .fill(sopra && correggibile ? S.fondoValoreSopra : Color.clear)
            }
            .padding(.horizontal, -S.paddingValore.leading)
            .contentShape(Rectangle())
            .onHover { sopra = $0 }
            .onTapGesture { if correggibile { apri() } }
            .help(correggibile ? "Tocca per correggere" : "")
            .accessibilityAddTraits(correggibile ? .isButton : [])
            .accessibilityAction { if correggibile { apri() } }
    }

    @ViewBuilder private var segno: some View {
        if dubbio {
            Text("?").carattereApple(S.spunta).foregroundColor(S.coloreDubbio)
        } else if corretta {
            Image(systemName: S.segnoScrittoDaTe).foregroundColor(S.coloreScrittoDaTe)
                .accessibilityLabel(Text("scritto da te"))
        } else {
            Text(riga.trovata ? "✓" : "").carattereApple(S.spunta).foregroundColor(S.coloreSpunta)
        }
    }

    private func apri() {
        testo = inquadra.correzioni[riga.id] ?? riga.valore ?? ""
        inquadra.inModifica = riga.id
    }

    /// Invio: la correzione entra (uguale al valore di prima non è una correzione) ed esce da «Va bene».
    private func conferma() {
        let t = testo.trimmingCharacters(in: .whitespacesAndNewlines)
        if t == riga.valore || (t.isEmpty && inquadra.correzioni[riga.id] == nil) {
            // niente di cambiato
        } else if t.isEmpty {
            inquadra.correzioni[riga.id] = nil
        } else {
            inquadra.correzioni[riga.id] = t
            inquadra.confermate.remove(riga.id)
        }
        inquadra.inModifica = nil
    }

    private func annulla() {
        inquadra.inModifica = nil
    }
}

/// La tabella «La sua vita intera / Una temporanea» (§9.1.7) e la nota.
struct TabellaConfrontoInquadra: View {
    let confronto: ConfrontoTemporanea
    let tipo: String?

    private typealias T = Tema.Apple.Inquadra.Tabella
    private typealias S = Tema.Apple.Inquadra.Scheda

    var body: some View {
        let larghezza = S.larghezza - S.padding.leading - S.padding.trailing
        let somma = T.pesi.reduce(0, +)
        let colonne = T.pesi.map { larghezza * $0 / somma }
        let p = confronto.polizza, t = confronto.temporanea
        let vitaIntera = MotoreConfrontoDossier.normaleTesto(tipo ?? "").contains("vita intera")
        let righe: [[String]] = [
            ["Spesa l’anno", p.spesaAnnua.map { MotoreInquadra.importo($0) } ?? "—", t.spesaAnnua.map { "circa " + Formati.euro($0) } ?? "—"],
            ["Capitale caso morte", p.capitaleCasoMorte.map { Formati.euro($0) } ?? "—", t.capitaleCasoMorte.map { Formati.euro($0) } ?? "—"],
            ["Valore di riscatto", MotoreInquadra.testoRiscatto(p.riscatto), MotoreInquadra.testoRiscatto(t.riscatto)],
        ]
        return VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                riga(["", vitaIntera ? "La sua vita intera" : "La sua polizza", "Una temporanea"], colonne: colonne, testa: true)
                ForEach(Array(righe.enumerated()), id: \.offset) { _, r in
                    riga(r, colonne: colonne, testa: false)
                        .overlay(alignment: .top) {
                            Rectangle().fill(T.filo).frame(height: Tema.Apple.Misura.bordo)
                        }
                }
            }
            .frame(width: larghezza)
            .clipShape(RoundedRectangle(cornerRadius: T.raggio, style: .continuous))
            .superficieApple(T.superficie, raggio: T.raggio)
            Text(MotoreInquadra.notaConfronto(confronto))
                .carattereApple(T.nota)
                .foregroundColor(T.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, T.notaSopra)
        }
        .padding(.top, T.sopra)
    }

    private func riga(_ celle: [String], colonne: [CGFloat], testa: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(celle.enumerated()), id: \.offset) { i, testo in
                Text(testo)
                    .carattereApple(testa ? T.carattereTesta : (i == 2 ? T.carattereForte : T.carattere))
                    .foregroundColor(i == 0 ? T.colorePrima : (i == 2 ? T.coloreTerza : T.coloreSeconda))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(T.padding)
                    .frame(width: colonne.indices.contains(i) ? colonne[i] : 0, alignment: .leading)
            }
        }
        .background(testa ? T.fondoTesta : Color.clear)
    }
}

/// La zona dove trascinare la foto o il PDF della polizza, con «Scegli un file…».
private struct ZonaInquadra: View {
    @Environment(StatoShell.self) var stato
    let inquadra: StatoInquadra

    private typealias Z = Tema.Apple.Inquadra.Zona

    var body: some View {
        let _ = ContaCorpi.segna()
        let sopra = inquadra.fileSopra
        let forma = RoundedRectangle(cornerRadius: Z.raggio, style: .continuous)
        return VStack(spacing: Z.spazio) {
            Image(systemName: "doc.viewfinder")
                .font(.system(size: Z.icona, weight: .regular))
                .foregroundColor(sopra ? Z.coloreTrattoSopra : Z.coloreIcona)
            Text(sopra ? "Rilascia per leggere" : "Trascina qui una foto o un PDF")
                .carattereApple(Z.testo)
                .foregroundColor(Z.coloreTesto)
            Button("Scegli un file…") { stato.scegliFileInquadra() }
                .buttonStyle(.appleSobrio)
                .disabled(stato.solaLettura)
        }
        .frame(maxWidth: .infinity, minHeight: Z.altezza)
        .background(forma.fill(sopra ? Z.fondoSopra : Z.fondo))
        .overlay(forma.strokeBorder(sopra ? Z.coloreTrattoSopra : Z.coloreTratto,
                                    style: StrokeStyle(lineWidth: Z.tratto, dash: Z.trattino)))
    }
}

// MARK: - Il pulsante della testata di Posizioni

/// «◎ Inquadra con l’iPhone»: nello Smontaggio vuoto. In Posizioni è una voce del menu «Aggiungi» (migliorie d'uso 6).
struct PulsanteInquadra: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        let _ = ContaCorpi.segna()
        Button { stato.apriInquadra() } label: {
            Label("Inquadra con l’iPhone", systemImage: "viewfinder")
        }
        .buttonStyle(.apple)
        .help("Leggi una polizza con la fotocamera dell’iPhone, oppure da una foto o un PDF trascinati sul Mac")
    }
}
#endif
