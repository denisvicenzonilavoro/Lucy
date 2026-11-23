import SwiftUI

// La penna di Vera nello stile Carta (NOVITÀ 4, template `.pen-note` e `.tbtn.pentg`): note in blu stilografica,
// New York corsivo, con il pennino davanti, che compaiono a margine con una piccola dissolvenza. Il pulsante «Note di
// Vera» nella testa della finestra le accende e le spegne; davanti al cliente non ci sono mai (`StatoShell.notePenna`).

extension TemaCarta {
    enum Penna {
        static let testo = Font.system(size: 14, weight: .regular, design: .serif).italic()
        static let pennino: CGFloat = 13
        static let spazio: CGFloat = 6
        static let pulsante = Font.system(size: 12.5, weight: .medium)
        static let altezzaPulsante: CGFloat = 30
    }
}

/// Le note della penna: si vedono solo se la penna è accesa e non si è davanti al cliente.
struct NotePennaVista: View {
    @Environment(StatoShell.self) private var stato
    let note: [NotaPenna]

    var body: some View {
        if stato.notePenna && !note.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(note) { NotaPennaVista(nota: $0) }
            }
            .transition(.opacity)
        }
    }
}

/// Una nota della penna, in blu stilografica con il pennino.
struct NotaPennaVista: View {
    let nota: NotaPenna
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var visibile = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: TemaCarta.Penna.spazio) {
            Image(systemName: "pencil.tip")
                .font(.system(size: TemaCarta.Penna.pennino, weight: .regular))
            Text(nota.testo)
                .font(TemaCarta.Penna.testo)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundColor(TemaCarta.Colore.pennaD)
        .opacity(statoFinale || visibile ? 1 : 0)
        .offset(y: statoFinale || visibile ? 0 : 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Nota di Vera: \(nota.testo)")
        .onAppear {
            guard !statoFinale else { return }
            withAnimation(Tema.Apple.Moto.Curva.uscita.animazione(0.6).ritardoPrisma(0.4)) { visibile = true }
        }
    }
}

/// Il pulsante «Note di Vera» della testa della finestra: pieno di blu penna quando le note sono accese.
/// Non c'è in modalità cliente (le note lì non si vedono comunque).
struct PulsanteNoteVera: View {
    @Environment(StatoShell.self) private var stato

    var body: some View {
        if Tema.Stile.usaCarta && !stato.inModoCliente {
            let acceso = stato.noteVeraAccese
            Button {
                stato.noteVeraAccese.toggle()
            } label: {
                Label("Note di Vera", systemImage: "pencil")
                    .font(TemaCarta.Penna.pulsante)
                    .padding(.horizontal, 13)
                    .frame(height: TemaCarta.Penna.altezzaPulsante)
                    .foregroundColor(acceso ? TemaCarta.Colore.schedaD : TemaCarta.Colore.inchiostroD)
                    .background {
                        Capsule().fill(acceso ? TemaCarta.Colore.pennaD : TemaCarta.Colore.schedaD)
                    }
                    .overlay { Capsule().strokeBorder(acceso ? Color.clear : TemaCarta.Colore.filo2D, lineWidth: 1) }
            }
            .buttonStyle(.plain)
            .help(acceso ? "Spegni le note di Vera a margine" : "Accendi le note di Vera a margine")
            .accessibilityValue(acceso ? "accese" : "spente")
        }
    }
}
