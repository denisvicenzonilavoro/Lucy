import SwiftUI

// Le richieste da Prisma AI (NOVITÀ 11 dello stile Carta): le richieste di consulenza dell'app gratuita per i clienti
// arrivano come lettere, con il conto che il cliente ha scelto di condividere; «Richiamala oggi» crea l'attività in
// agenda. Per ora c'è solo l'interfaccia: il collegamento è SPENTO nel codice e non esiste nessuna chiamata di rete.
// Si accenderà solo quando esisterà il server di Prisma AI, con connessione cifrata e accesso protetto, e solo con la
// decisione dell'utente. Da Prisma non parte nessun dato: il collegamento, quando ci sarà, riceverà soltanto.
// Nella modalità dimostrazione si vede una lettera di esempio (dati inventati, dichiarati).

enum CollegamentoPrismaAI {
    /// Spento: nessuna lettera arriva. Non si cambia senza la decisione dell'utente.
    static let collegamentoAmmesso = false
    static let statoSpento = "Il collegamento con Prisma AI è spento: si accenderà quando esisterà il suo server, con connessione cifrata e accesso protetto. Da Prisma non parte nessun dato."
}

/// Una richiesta di consulenza arrivata da Prisma AI, solo in memoria.
struct LetteraPrismaAI: Identifiable, Hashable {
    let id: String
    let nome: String
    let eta: Int?
    let arrivata: Date
    /// Quanti prodotti il cliente ha caricato nell'app.
    let prodotti: Int
    /// La frase del cliente («la polizza vita le costa 288 € l'anno»).
    let frase: String
    /// Il conto che il cliente ha scelto di condividere (le stesse righe dello scontrino).
    let conto: [RigaScontrino]
    let totale: Double

    /// La lettera di esempio della modalità dimostrazione (dati inventati).
    static func esempio(_ adesso: Date) -> LetteraPrismaAI {
        LetteraPrismaAI(id: "lettera-esempio", nome: "Giulia R.", eta: 34, arrivata: adesso.addingTimeInterval(-7_200),
                        prodotti: 5, frase: "La polizza vita le costa 288 € l'anno: vorrebbe capire se è giusta per lei.",
                        conto: [RigaScontrino(etichetta: "Polizza vita", importo: -288),
                                RigaScontrino(etichetta: "Fondo pensione", importo: -164),
                                RigaScontrino(etichetta: "Conto deposito", importo: 0)],
                        totale: 452)
    }
}

extension StatoShell {
    /// Le lettere da mostrare: nessuna finché il collegamento è spento; nella dimostrazione quella di esempio.
    var letterePrismaAI: [LetteraPrismaAI] {
        guard Tema.Stile.usaCarta, !inModoCliente else { return [] }
        return inDimostrazione ? [LetteraPrismaAI.esempio(Date())] : []
    }

    /// «Richiamala oggi»: un'attività per oggi in agenda (senza cliente: non è ancora un cliente).
    func richiamaOggi(_ l: LetteraPrismaAI) {
        guard !solaLettura else { return }
        let oggi = Calendar.current.startOfDay(for: Date())
        let id = "prisma-ai-\(l.id)-\(Int(oggi.timeIntervalSinceReferenceDate))"
        guard !dati.attivita.contains(where: { $0.id == id }) else { return }
        salvaAttivita(Attivita(id: id, clienteId: "", titolo: "Richiamare \(l.nome) (richiesta da Prisma AI)",
                               scadenza: oggi, priorita: .alta, completata: false, note: l.frase))
        mostraAvviso("In agenda per oggi: richiamare \(l.nome).")
    }
}

/// La lettera sulla scrivania: la busta con la ceralacca, chi scrive, «Apri la lettera».
struct LetteraPrismaAIWidget: View {
    @Environment(StatoShell.self) private var stato
    @State private var aperta: LetteraPrismaAI?

    var body: some View {
        if let l = stato.letterePrismaAI.first {
            Button { aperta = l } label: {
                HStack(spacing: 18) {
                    BustaCeralacca()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DA PRISMA AI · \(Formati.ora.string(from: l.arrivata))")
                            .fontCarta(11, design: .monospaced).tracking(2)
                            .foregroundColor(TemaCarta.Colore.matitaD)
                        Text("\(l.nome) chiede una consulenza")
                            .fontCarta(21, weight: .medium, design: .serif)
                        Text("\(l.eta.map { "\($0) anni · " } ?? "")ha caricato \(l.prodotti) prodotti")
                            .fontCarta(13).foregroundColor(TemaCarta.Colore.inchiostro2D)
                    }
                    Spacer()
                    Text("Apri la lettera →").fontCarta(13, weight: .medium)
                }
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .padding(EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20))
                .frame(maxWidth: 500, alignment: .leading)
                .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
            }
            .buttonStyle(.plain)
            .sheet(item: $aperta) { l in
                LetteraPrismaAIVista(lettera: l) { aperta = nil }
                    .environment(stato)
            }
        }
    }
}

/// La busta con la ceralacca rossa.
struct BustaCeralacca: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3).fill(TemaCarta.Colore.cartaD)
                .overlay { RoundedRectangle(cornerRadius: 3).strokeBorder(TemaCarta.Colore.filo2D, lineWidth: 1) }
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: 31, y: 22)); p.addLine(to: CGPoint(x: 62, y: 0))
            }
            .stroke(TemaCarta.Colore.filo2D, lineWidth: 1)
            Circle()
                .fill(RadialGradient(colors: [Color(r: 200, g: 87, b: 74), Color(r: 142, g: 42, b: 31), Color(r: 106, g: 30, b: 22)],
                                     center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 12))
                .frame(width: 20, height: 20)
                .offset(y: 4)
        }
        .frame(width: 62, height: 44)
        .accessibilityHidden(true)
    }
}

/// La lettera aperta: la frase del cliente, il suo conto condiviso come scontrino e «Richiamala oggi».
struct LetteraPrismaAIVista: View {
    @Environment(StatoShell.self) private var stato
    let lettera: LetteraPrismaAI
    let chiudi: () -> Void

    var body: some View {
        let f = FormatoCifra.euro
        VStack(alignment: .leading, spacing: 16) {
            Text("Ciao \(stato.nomeUtente),").fontCarta(15, design: .serif, corsivo: true).foregroundColor(TemaCarta.Colore.inchiostro2D)
            Text("\(lettera.nome) chiede una consulenza")
                .fontCarta(28, weight: .medium, design: .serif)
            Text(lettera.frase).fontCarta(15, design: .serif).fixedSize(horizontal: false, vertical: true)
            ScontrinoCarta(data: lettera.arrivata, titolo: "Il conto che ha condiviso", totale: f.testo(lettera.totale),
                           sottoTotale: "di costi all'anno", coloreSottoTotale: TemaCarta.Colore.matitaD) {
                ForEach(lettera.conto, id: \.etichetta) { r in
                    RigaScontrinoVista(etichetta: r.etichetta, importo: ScontrinoContoCliente.importo(r),
                                       colore: ScontrinoContoCliente.colore(r))
                }
            }
            if stato.inDimostrazione {
                Text("Lettera di esempio della dimostrazione: dati inventati.")
                    .fontCarta(11.5).foregroundColor(TemaCarta.Colore.matitaD)
            }
            HStack {
                Button("Richiamala oggi") { stato.richiamaOggi(lettera); chiudi() }
                    .keyboardShortcut(.defaultAction)
                Spacer()
                Button("Chiudi", action: chiudi).keyboardShortcut(.cancelAction)
            }
        }
        .foregroundColor(TemaCarta.Colore.inchiostroD)
        .padding(28)
        .frame(width: 440)
        .background(TemaCarta.Colore.foglioD)
    }
}
