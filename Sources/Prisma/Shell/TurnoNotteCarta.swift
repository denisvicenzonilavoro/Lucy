import SwiftUI

// Il resoconto del turno di notte sulla scrivania (NOVITÀ 3 dello stile Carta, template `.nightw`): quanto ha lavorato
// Vera stanotte e cosa ha preparato. Toccandolo si apre Vera, dove ci sono le carte da approvare. Solo se c'è una notte.

extension StatoShell {
    /// Il resoconto dell'ultima notte di lavoro (MotoreResocontoNotte), in cache.
    var resocontoNotte: ResocontoNotte? {
        ricavato("resoconto-notte|\(dati.notti.count)|\(dati.notti.last?.fine?.timeIntervalSinceReferenceDate ?? 0)") {
            MotoreResocontoNotte.ultimo(dati.notti)
        }
    }
}

struct TurnoNotteWidget: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        if let r = stato.resocontoNotte, !stato.inModoCliente {
            Button { stato.apri(.vera) } label: { contenuto(r) }
                .buttonStyle(.plain)
                .help("Apri Vera: le carte della notte da approvare")
        }
    }

    private func contenuto(_ r: ResocontoNotte) -> some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Label("IL TURNO DI NOTTE DI VERA", systemImage: "moon")
                    .font(.system(size: 10, design: .monospaced)).tracking(2)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                Text(r.durata ?? (r.interrotta ? "Interrotto" : "In corso"))
                    .font(.system(size: 42, weight: .medium, design: .serif)).tracking(-1.2)
                if let i = r.inizio, let f = r.fine {
                    Text("dalle \(Formati.ora.string(from: i)) alle \(Formati.ora.string(from: f))")
                        .font(.system(size: 14, design: .serif).italic())
                        .foregroundColor(TemaCarta.Colore.inchiostro2D)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                ForEach(r.righe, id: \.self) { riga in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("✓").font(.system(size: 11, design: .monospaced)).foregroundColor(TemaCarta.Colore.verdeD)
                        Text(riga).font(.system(size: 12.5)).foregroundColor(TemaCarta.Colore.inchiostro2D)
                    }
                }
                if r.daDecidere > 0 {
                    Text(r.daDecidere == 1 ? "1 carta da approvare" : "\(r.daDecidere) carte da approvare")
                        .font(TemaCarta.Penna.testo)
                        .foregroundColor(TemaCarta.Colore.pennaD)
                        .padding(.top, 4)
                }
            }
        }
        .foregroundColor(TemaCarta.Colore.inchiostroD)
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
        .frame(maxWidth: 500, alignment: .leading)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
        .accessibilityElement(children: .combine)
    }
}
