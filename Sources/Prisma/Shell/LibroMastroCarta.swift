#if os(macOS)
import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// Il libro mastro in Studio (NOVITÀ 9 dello stile Carta, template «STUDIO · il libro mastro»): le entrate del mese
// (provvigioni dai cedolini e parcelle incassate), la quota da mettere da parte scelta dall'utente, le spese e quanto si
// può spendere, in cifre a contachilometri. Il cedolino si trascina dentro: Prisma ne legge il testo sul Mac (PDFKit,
// LettoreCedolino), il consulente conferma le cifre e si registra solo mese, canale, lordo, netto e nome del file; il
// PDF non si conserva. Solo sul Mac, mai in modalità cliente (Studio è del consulente).

extension StatoShell {
    /// Il mese di adesso del libro mastro, in cache.
    func libroMastro() -> MeseLibroMastro {
        let quota = dati.impostazioni.carta.quotaAccantonamento
        // Spese e cedolini sono dati «neutri» (non cambiano la versione dei calcoli): vanno nell'ingresso della cache
        return ricavato("libro-mastro|\(quota ?? -1)|\(dati.parcelle.count)", ingresso: dati.speseStudio) {
            MotoreLibroMastro.mese(Date(), cedolini: dati.speseStudio.cedolini, parcelle: dati.parcelle,
                                   spese: dati.speseStudio.spese, quota: quota, calendario: Calendar.current)
        }
    }

    /// Registra un cedolino confermato dal consulente.
    func registraCedolino(_ c: CedolinoProvvigioni) {
        guard !solaLettura else { return }
        // Lo stesso cedolino trascinato due volte non raddoppia: quello dello stesso mese e canale si sostituisce
        let cal = Calendar.current
        dati.speseStudio.cedolini.removeAll { $0.canale == c.canale && cal.isDate($0.mese, equalTo: c.mese, toGranularity: .month) }
        dati.speseStudio.cedolini.append(c)
        mostraAvviso("Cedolino di \(Formati.meseAnno.string(from: c.mese)) registrato nel libro mastro.")
    }
}

struct LibroMastroCarta: View {
    @Environment(StatoShell.self) private var stato
    @State private var letto: CedolinoDaConfermare?
    @State private var sopra = false
    @State private var scegli = false

    var body: some View {
        let m = stato.libroMastro()
        let f = FormatoCifra.euro
        HStack(alignment: .top, spacing: 26) {
            VStack(alignment: .leading, spacing: 6) {
                Text("IL LIBRO MASTRO · \(Formati.meseAnno.string(from: m.mese).uppercased())")
                    .fontCarta(11, design: .monospaced).tracking(2)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                if let disponibile = m.disponibile {
                    Text("Quanto puoi spendere").fontCarta(14, design: .serif, corsivo: true)
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                    ContachilometriCarta(testo: f.testo(disponibile))
                        .fontCarta(42, weight: .medium, design: .serif, cifre: true)
                        .segnoCarta(.sottolinea, chiave: "libro-mastro")
                } else {
                    Text("Scegli quanto mettere da parte").fontCarta(22, weight: .medium, design: .serif)
                    Text("La percentuale la decidi tu: Prisma non conosce regole fiscali e non ne inventa.")
                        .fontCarta(12.5).foregroundColor(TemaCarta.Colore.inchiostro2D)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 8) {
                    Text("Da mettere da parte").fontCarta(12.5)
                    TextField("%", value: quota, format: .number.precision(.fractionLength(0...1)))
                        .frame(width: 54)
                        .accessibilityLabel("Percentuale da mettere da parte")
                        .multilineTextAlignment(.trailing)
                    Text("%").fontCarta(12.5)
                }
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .padding(.top, 6)
            }
            .frame(maxWidth: 300, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                RigaScontrinoVista(etichetta: "Provvigioni (cedolini)", importo: f.testo(m.provvigioni))
                RigaScontrinoVista(etichetta: "Parcelle incassate", importo: f.testo(m.parcelle))
                RigaScontrinoVista(etichetta: "Entrate", importo: f.testo(m.entrate), forte: true)
                LineaTratteggiata()
                if let a = m.accantonamento {
                    RigaScontrinoVista(etichetta: "Da mettere da parte", importo: "−" + f.testo(a), colore: TemaCarta.Colore.oroTestoD)
                }
                RigaScontrinoVista(etichetta: "Spese dello studio", importo: "−" + f.testo(m.spese), colore: TemaCarta.Colore.rossoD)
            }
            .frame(maxWidth: 340)

            zonaCedolino
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
        .sheet(item: $letto) { c in
            ConfermaCedolino(cedolino: c) { confermato in
                if let confermato { stato.registraCedolino(confermato) }
                letto = nil
            }
        }
    }

    /// La quota scelta (nil = non ancora scelta), nei limiti di ImpostazioniCarta.
    private var quota: Binding<Double?> {
        Binding(get: { stato.dati.impostazioni.carta.quotaAccantonamento },
                set: { stato.dati.impostazioni.carta.quotaAccantonamento = $0.map(ImpostazioniCarta.limitaQuota) })
    }

    /// Il riquadro del cedolino: si clicca (tastiera e VoiceOver compresi) o ci si trascina sopra il PDF.
    private var zonaCedolino: some View {
        Button { scegli = true } label: { riquadroCedolino }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .accessibilityLabel("Scegli il PDF del cedolino, oppure trascinalo qui")
            .fileImporter(isPresented: $scegli, allowedContentTypes: [.pdf]) { esito in
                guard case .success(let url) = esito else { return }
                let accesso = url.startAccessingSecurityScopedResource()
                defer { if accesso { url.stopAccessingSecurityScopedResource() } }
                leggi(url)
            }
            .onDrop(of: [UTType.fileURL], isTargeted: $sopra) { fornitori in
                guard let f = fornitori.first else { return false }
                _ = f.loadObject(ofClass: URL.self) { url, _ in
                    guard let url, url.pathExtension.lowercased() == "pdf" else { return }
                    leggi(url)
                }
                return true
            }
    }

    /// Legge il testo del PDF sul Mac e prepara le cifre da confermare.
    private func leggi(_ url: URL) {
        let testo = PDFDocument(url: url)?.string ?? ""
        let l = LettoreCedolino.leggi(testo)
        let nome = url.lastPathComponent
        DispatchQueue.main.async {
            letto = CedolinoDaConfermare(fonte: nome, mese: l.mese, lordo: l.lordo, netto: l.netto)
        }
    }

    private var riquadroCedolino: some View {
        VStack(spacing: 6) {
            Image(systemName: "doc.text.viewfinder").fontCarta(22, weight: .light)
            Text("Scegli o trascina qui il cedolino").fontCarta(12.5, weight: .medium)
            Text("Vera lo legge sul Mac: tu confermi le cifre").fontCarta(11).multilineTextAlignment(.center)
        }
        .foregroundColor(sopra ? TemaCarta.Colore.pennaD : TemaCarta.Colore.inchiostro2D)
        .padding(14)
        .frame(minWidth: 170, minHeight: 120)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(sopra ? TemaCarta.Colore.pennaD : TemaCarta.Colore.inchiostro2D, style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
        }
    }
}

/// Le cifre lette dal cedolino, da confermare.
struct CedolinoDaConfermare: Identifiable {
    let id = UUID()
    let fonte: String
    var mese: Date?
    var lordo: Double?
    var netto: Double?
}

/// La conferma delle cifre lette: il consulente le corregge se serve, poi «Registra».
struct ConfermaCedolino: View {
    @State var cedolino: CedolinoDaConfermare
    @State private var canale: Canale = .alleanza
    let fine: (CedolinoProvvigioni?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Il cedolino").fontCarta(24, weight: .medium, design: .serif)
            Text(cedolino.fonte).fontCarta(11.5, design: .monospaced).foregroundColor(TemaCarta.Colore.matitaD)
            if cedolino.lordo == nil {
                Text("Non ho trovato il totale delle provvigioni: scrivilo tu.")
                    .fontCarta(TemaCarta.Penna.testo).foregroundColor(TemaCarta.Colore.pennaD)
            }
            Form {
                DatePicker("Mese", selection: Binding(get: { cedolino.mese ?? Date() }, set: { cedolino.mese = $0 }),
                           displayedComponents: .date)
                TextField("Provvigioni lorde", value: $cedolino.lordo, format: .number.precision(.fractionLength(2)))
                TextField("Netto pagato", value: $cedolino.netto, format: .number.precision(.fractionLength(2)))
                Picker("Canale", selection: $canale) {
                    ForEach(Canale.allCases, id: \.self) { Text($0.nome).tag($0) }
                }
            }
            HStack {
                Spacer()
                Button("Annulla") { fine(nil) }.keyboardShortcut(.cancelAction)
                Button("Registra") {
                    let cal = Calendar.current
                    let m = cedolino.mese.flatMap { cal.date(from: cal.dateComponents([.year, .month], from: $0)) } ?? Date()
                    fine(CedolinoProvvigioni(mese: m, canale: canale, lordo: cedolino.lordo ?? 0, netto: cedolino.netto,
                                             fonte: cedolino.fonte))
                }
                .keyboardShortcut(.defaultAction)
                .disabled((cedolino.lordo ?? 0) <= 0)
                .accessibilityHint("Serve l'importo lordo delle provvigioni")
            }
        }
        .padding(26)
        .frame(width: 420)
        .background(TemaCarta.Colore.foglioD)
    }
}
#endif
