import SwiftUI

// Il timbro dello stile Carta (NOVITÀ 7, template `.stamp`): un timbro tondo a inchiostro, un po' storto, che si posa
// sulla proposta con un piccolo colpo (scala da 1,4 a 1). Verde se coerente, rosso se da rivedere; sotto i cinque
// controlli e sempre l'avvertenza «non sostituisce la valutazione di adeguatezza». Le cifre vengono da MotoreTimbro.

extension TemaCarta {
    enum Timbro {
        static let lato: CGFloat = 132
        static let inclinazione: Double = -12
        static let scritta = Font.system(size: 12, weight: .semibold, design: .monospaced)
        static let piccolo = Font.system(size: 11, weight: .regular, design: .monospaced)
        static let voce = Font.system(size: 13, weight: .regular)
        static let nota = Font.system(size: 11.5, weight: .regular, design: .serif).italic()
        static let durata: Double = 0.45
    }
}

/// Il timbro tondo con la scritta.
struct TimbroTondo: View {
    let coerente: Bool
    let scritta: String
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var posato = false

    var body: some View {
        let k = TemaCarta.Timbro.self
        let colore = coerente ? TemaCarta.Colore.verdeD : TemaCarta.Colore.rossoD
        let fatto = statoFinale || posato
        ZStack {
            Circle().strokeBorder(colore, lineWidth: 3)
            Circle().strokeBorder(colore, lineWidth: 1).padding(7)
            VStack(spacing: 4) {
                Text("VERA · PRISMA").font(k.piccolo).tracking(1.5)
                Text(scritta.uppercased())
                    .font(k.scritta)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(Formati.dataBreve.string(from: Date())).font(k.piccolo)
            }
            .padding(18)
        }
        .foregroundColor(colore)
        .frame(width: k.lato, height: k.lato)
        .opacity(fatto ? 0.88 : 0)
        .scaleEffect(fatto ? 1 : 1.4)
        .rotationEffect(.degrees(k.inclinazione))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Timbro di Vera: \(scritta)")
        .onAppear {
            guard !statoFinale else { return }
            withAnimation(Tema.Apple.Moto.Curva.molla.animazione(k.durata).ritardoPrisma(0.3)) { posato = true }
        }
    }
}

/// Il riquadro del timbro: il timbro, i cinque controlli e l'avvertenza.
struct RiquadroTimbro: View {
    let esito: EsitoTimbro

    var body: some View {
        let k = TemaCarta.Timbro.self
        HStack(alignment: .top, spacing: 22) {
            TimbroTondo(coerente: esito.coerente, scritta: esito.scritta)
            VStack(alignment: .leading, spacing: 8) {
                Text("IL TIMBRO DI VERA")
                    .font(TemaCarta.Scontrino.titolo)
                    .tracking(2)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                ForEach(esito.controlli) { c in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: c.passa ? "checkmark" : "exclamationmark.circle")
                            .foregroundColor(c.passa ? TemaCarta.Colore.verdeD : TemaCarta.Colore.rossoD)
                            .accessibilityHidden(true)
                        Text("\(c.voce.nome): ").font(k.voce.weight(.medium)) + Text(c.testo).font(k.voce)
                    }
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityElement(children: .combine)
                    .accessibilityValue(c.passa ? "superato" : "da rivedere")
                }
                Text(MotoreTimbro.avvertenza)
                    .font(k.nota)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(.dettaglio, raggio: TemaCarta.Raggio.riquadro)
    }
}
