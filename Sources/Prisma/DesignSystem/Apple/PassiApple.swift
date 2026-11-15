import SwiftUI

/// Una fila di passi (Migliorie d'uso 28, `.passiF` del template): un cerchio per passo, uniti da un filo, con il nome
/// sotto. I passi prima di `attuale` sono fatti (spunta verde), `attuale` è pieno blu con il numero, quelli dopo sono da
/// fare. Ogni passo prende la stessa larghezza; il filo unisce i cerchi vicini. Niente
/// movimento: la fila cambia con la scheda che la contiene. Valori in `Tema.Apple.Passi`.
struct PassiApple: View {
    let passi: [String]
    let attuale: Int

    private typealias P = Tema.Apple.Passi

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(passi.enumerated()), id: \.offset) { i, nome in
                VStack(spacing: P.spazioNome) {
                    cerchio(i)
                    Text(nome)
                        .carattereApple(P.nome)
                        .foregroundColor(coloreNome(i))
                        .lineLimit(1)
                        .minimumScaleFactor(P.riduzioneNome)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(alignment: .top) { filo }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(descrizione)
    }

    /// Il filo fra i cerchi: un tratto per ogni coppia di passi vicini, dal bordo di un cerchio al bordo del successivo.
    private var filo: some View {
        GeometryReader { geo in
            let colonna = geo.size.width / CGFloat(max(passi.count, 1))
            let tratto = max(0, colonna - P.cerchio)
            ForEach(0..<max(passi.count - 1, 0), id: \.self) { i in
                Rectangle()
                    .fill(P.coloreFilo)
                    .frame(width: tratto, height: P.filo)
                    .offset(x: colonna * (CGFloat(i) + 0.5) + P.cerchio / 2, y: (P.cerchio - P.filo) / 2)
            }
        }
        .frame(height: P.cerchio)
        .allowsHitTesting(false)
    }

    @ViewBuilder private func cerchio(_ i: Int) -> some View {
        if i < attuale {
            Circle()
                .strokeBorder(P.fatto, lineWidth: P.bordo)
                .overlay {
                    Image(systemName: "checkmark")
                        .carattereApple(P.spunta)
                        .foregroundColor(P.fatto)
                }
                .frame(width: P.cerchio, height: P.cerchio)
        } else if i == attuale {
            Circle()
                .fill(P.fondoAttuale)
                .overlay {
                    Text("\(i + 1)")
                        .carattereApple(P.numero)
                        .foregroundColor(P.numeroAttuale)
                }
                .frame(width: P.cerchio, height: P.cerchio)
        } else {
            Circle()
                .strokeBorder(P.bordoFuturo, lineWidth: P.bordo)
                .overlay {
                    Text("\(i + 1)")
                        .carattereApple(P.numero)
                        .foregroundColor(P.numeroFuturo)
                }
                .frame(width: P.cerchio, height: P.cerchio)
        }
    }

    private func coloreNome(_ i: Int) -> Color {
        if i < attuale { return P.nomeFatto }
        return i == attuale ? P.nomeAttuale : P.nomeFuturo
    }

    /// «Passo 2 di 3: Emessa».
    private var descrizione: String {
        guard passi.indices.contains(attuale) else { return passi.joined(separator: ", ") }
        return "Passo \(attuale + 1) di \(passi.count): \(passi[attuale])"
    }
}
