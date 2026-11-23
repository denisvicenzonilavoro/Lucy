import SwiftUI

// Il fascicolo in un tocco (NOVITÀ 5 dello stile Carta, template `#fasc`): la cartella dell'incontro si compone a vista,
// una parte dopo l'altra, con le tre cose da dire scritte da Prisma. «Apri in grande» mostra il fascicolo PDF di sempre
// (Fascicolo.swift) nella vista del cliente, «Manda all'iPad» lo porta sul tavolo, «Stampa» lo stampa. Sul Mac.

#if os(macOS)
/// Il pulsante nero «Fascicolo in un tocco» (dossier del cliente).
struct PulsanteFascicoloInUnTocco: View {
    @Environment(StatoShell.self) private var stato
    let cliente: Cliente
    @State private var aperto = false

    var body: some View {
        if Tema.Stile.usaCarta && !stato.inModoCliente {
            Button {
                aperto = true
            } label: {
                Label("Fascicolo in un tocco", systemImage: "folder")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(TemaCarta.Colore.suInchiostroD)
                    .padding(.horizontal, 16)
                    .frame(height: 36)
                    .background { Capsule().fill(TemaCarta.Colore.inchiostroD) }
            }
            .buttonStyle(.plain)
            .help("La cartella dell'incontro con \(cliente.nome), composta a vista")
            .sheet(isPresented: $aperto) {
                FascicoloInUnTocco(cliente: cliente) { aperto = false }
                    .environment(stato)
            }
        }
    }
}

/// La cartella che si compone.
struct FascicoloInUnTocco: View {
    @Environment(StatoShell.self) private var stato
    @Environment(\.prismaStatoFinale) private var statoFinale
    let cliente: Cliente
    let chiudi: () -> Void
    @State private var mostrate = 0

    var body: some View {
        let f = stato.fascicoloCarta(cliente)
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("IL FASCICOLO IN UN TOCCO")
                    .font(TemaCarta.Scontrino.titolo).tracking(2)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                Text(cliente.nome)
                    .font(.system(size: 30, weight: .medium, design: .serif))
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .segnoCarta(.sottolinea, chiave: "fascicolo.\(cliente.id)")
            }
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(f.parti.enumerated()), id: \.element.id) { i, parte in
                    rigaParte(i + 1, parte)
                        .opacity(statoFinale || i < mostrate ? 1 : 0)
                        .offset(y: statoFinale || i < mostrate ? 0 : 8)
                }
            }
            if !f.treCose.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TRE COSE DA DIRE")
                        .font(TemaCarta.Scontrino.titolo).tracking(2)
                        .foregroundColor(TemaCarta.Colore.matitaD)
                    ForEach(Array(f.treCose.enumerated()), id: \.offset) { i, cosa in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(i + 1).").font(.system(size: 14, weight: .medium, design: .serif))
                            Text(cosa).font(.system(size: 14)).fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundColor(TemaCarta.Colore.inchiostroD)
                    }
                }
            }
            HStack(spacing: 10) {
                Button("Apri in grande") { apri(mandaAlTavolo: false) }
                    .keyboardShortcut(.defaultAction)
                Button("Manda all'iPad") { apri(mandaAlTavolo: true) }
                Button("Stampa") { stampa() }
                Spacer()
                Button("Chiudi", action: chiudi).keyboardShortcut(.cancelAction)
            }
            if stato.documentoFascicolo() == nil {
                Text("Per il PDF scegli i report in Prospetti › Il fascicolo dell'incontro.")
                    .font(.system(size: 11.5)).foregroundColor(TemaCarta.Colore.matitaD)
            }
        }
        .padding(28)
        .frame(width: 560)
        .background(TemaCarta.Colore.foglioD)
        .onAppear {
            guard !statoFinale else { return }
            for i in 0..<f.parti.count {
                withAnimation(Tema.Apple.Moto.Curva.uscita.animazione(0.5).ritardoPrisma(0.15 + Double(i) * 0.18)) {
                    mostrate = i + 1
                }
            }
        }
    }

    private func rigaParte(_ n: Int, _ p: ParteFascicolo) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(String(format: "%02d", n))
                .font(TemaCarta.Scontrino.riga)
                .foregroundColor(TemaCarta.Colore.oroTestoD)
            VStack(alignment: .leading, spacing: 2) {
                Text(p.tipo.titolo).font(.system(size: 17, weight: .medium, design: .serif))
                Text(p.sotto).font(.system(size: 12.5)).foregroundColor(TemaCarta.Colore.inchiostro2D)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(TemaCarta.Colore.inchiostroD)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { RoundedRectangle(cornerRadius: 10, style: .continuous).fill(TemaCarta.Colore.schedaD) }
        .overlay { RoundedRectangle(cornerRadius: 10, style: .continuous).strokeBorder(TemaCarta.Colore.filoD, lineWidth: 1) }
    }

    /// Il fascicolo PDF di sempre nella vista del cliente; con il tavolo anche sull'iPad.
    private func apri(mandaAlTavolo: Bool) {
        stato.scegliCliente(cliente.id)
        chiudi()
        stato.mostraFascicolo()
        if mandaAlTavolo { stato.mandaAlTavolo() }
    }

    private func stampa() {
        stato.scegliCliente(cliente.id)
        guard let d = stato.documentoFascicolo(), let dati = StampaCarta.pdf(d) else {
            stato.mostraAvviso("Per stampare scegli prima i report del fascicolo in Prospetti.")
            return
        }
        StampaCarta.stampa(dati, formato: d.formato)
    }
}
#endif
