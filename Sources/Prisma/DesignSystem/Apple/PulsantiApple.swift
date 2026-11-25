import SwiftUI

// Pulsanti ed etichetta del canale del tema Apple (Design/template-apple-specifica.md §2.16, §2.17).
// - StilePulsanteApple: `.buttonStyle(.apple)`, `.applePrimario`, `.appleVetro`, `.appleSobrio`,
//   oppure `StilePulsanteApple(.principale, grande: true)`.
// - EtichettaCanaleApple: la capsula del canale nei colori di Prisma (Alleanza blu con il logo Alleanza,
//   indipendente cuoio con «Denis Vicenzoni · Consulenza finanziaria»).
// Premuto: scala 0,95 con la molla di 0,25 s; sopra (hover): luminosità 0,97. Con «Riduci movimento» la
// scala segue la dissolvenza di 0,15 s; nelle istantanee né pressione né hover.

// MARK: - Pulsante (§2.16)

/// Le varianti del pulsante.
enum VariantePulsanteApple {
    /// `.btn.pri`: blu `accento` con il testo bianco (l'azione principale).
    case principale
    /// `.btn`: `cardPiena` con il bordo `separatore` (le altre azioni).
    case secondaria
    /// `.btn.glass`: sul vetro della scrivania (Nuovo cliente, Cerca ovunque).
    case vetro
    /// Solo il testo blu, con il fondo `chip` sotto il puntatore (azioni minori dentro le card).
    case sobria
}

/// Pulsante a capsula del tema Apple: 12,5 semibold con padding 7×14 (grande: 13,5 con 10×18),
/// spazio 6 fra icona e testo.
///
///     Button("Analisi 360") { … }.buttonStyle(.apple)
///     Button("Salva nel dossier") { … }.buttonStyle(StilePulsanteApple(.principale, grande: true))
///     Button { … } label: { Label("Nuovo cliente", systemImage: "person.badge.plus") }.buttonStyle(.appleVetro)
struct StilePulsanteApple: ButtonStyle {
    var variante: VariantePulsanteApple
    var grande: Bool

    init(_ variante: VariantePulsanteApple = .secondaria, grande: Bool = false) {
        self.variante = variante
        self.grande = grande
    }

    func makeBody(configuration: Configuration) -> some View {
        CorpoPulsanteApple(etichetta: configuration.label, premuto: configuration.isPressed,
                           variante: variante, grande: grande)
    }
}

extension ButtonStyle where Self == StilePulsanteApple {
    /// Pulsante secondario (`.btn`).
    static var apple: StilePulsanteApple { StilePulsanteApple(.secondaria) }
    /// Pulsante principale blu (`.btn.pri`).
    static var applePrimario: StilePulsanteApple { StilePulsanteApple(.principale) }
    /// Pulsante sul vetro della scrivania (`.btn.glass`).
    static var appleVetro: StilePulsanteApple { StilePulsanteApple(.vetro) }
    /// Pulsante sobrio: solo il testo blu.
    static var appleSobrio: StilePulsanteApple { StilePulsanteApple(.sobria) }
    /// Pulsante secondario grande (`.btn.big`).
    static var appleGrande: StilePulsanteApple { StilePulsanteApple(.secondaria, grande: true) }
    /// Pulsante principale grande (`.btn.pri.big`).
    static var applePrimarioGrande: StilePulsanteApple { StilePulsanteApple(.principale, grande: true) }
}

private struct CorpoPulsanteApple: View {
    let etichetta: ButtonStyleConfiguration.Label
    let premuto: Bool
    let variante: VariantePulsanteApple
    let grande: Bool

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @Environment(\.isEnabled) private var abilitato
    @State private var sopra = false

    private var forma: Capsule { Capsule(style: .continuous) }

    var body: some View {
        let m = Tema.Apple.Moto.PulsantePremuto.self
        HStack(spacing: Tema.Apple.Controlli.Pulsante.spazio) {
            etichetta
        }
        .carattereApple(grande ? Tema.Apple.Carattere.pulsanteGrande : Tema.Apple.Carattere.pulsante)
        .foregroundColor(coloreTesto)
        .lineLimit(1)
        .colorMultiply(moltiplica)
        .padding(grande ? Tema.Apple.Misura.Padding.pulsanteGrande : Tema.Apple.Misura.Padding.pulsante)
        .background { fondo }
        .contentShape(forma)
        .scaleEffect(premuto && abilitato && !istantanea ? m.scala : 1)
        .animation(Tema.Apple.Moto.animazione(m.animazione, calmo: calmo, istantanea: istantanea), value: premuto)
        .animation(Tema.Apple.Moto.animazione(m.animazioneSopra, calmo: calmo, istantanea: istantanea), value: sopra)
        .opacity(abilitato ? 1 : Tema.Apple.Controlli.opacitaDisattivato)
        .onHover { dentro in sopra = dentro && abilitato && !istantanea }
    }

    /// `filter: brightness(.97)` sotto il puntatore: moltiplica i colori (bianco = invariato).
    private var moltiplica: Color {
        sopra ? Color(white: Tema.Apple.Moto.PulsantePremuto.luminositaSopra) : Color.white
    }

    private var coloreTesto: Color {
        switch variante {
        case .principale: return Tema.Apple.Controlli.Pulsante.testoPrincipale
        case .secondaria, .vetro: return Tema.Apple.Colore.inchiostro
        case .sobria: return Tema.Apple.Colore.accento
        }
    }

    @ViewBuilder private var fondo: some View {
        switch variante {
        case .principale:
            forma.fill(Tema.Apple.Colore.accento)
                .colorMultiply(moltiplica)
        case .secondaria:
            forma.fill(Tema.Apple.Colore.cardPiena)
                .overlay { forma.strokeBorder(Tema.Apple.Colore.separatore, lineWidth: Tema.Apple.Misura.bordo) }
                .colorMultiply(moltiplica)
        case .vetro:
            // Il vetro non si moltiplica (il campionamento dello sfondo resta nativo): basta il testo.
            GeometryReader { g in
                Color.clear
                    .superficieApple(Tema.Apple.Superficie.pulsanteVetro, raggio: g.size.height / 2)
            }
        case .sobria:
            forma.fill(sopra ? Tema.Apple.Colore.chip : Color.clear)
        }
    }
}

// MARK: - Etichetta del canale (§2.17)

/// L'etichetta del canale nello stile del template. Dal 25 novembre 2026 (decisione dell'utente: un solo canale,
/// quello di Lucy) non disegna nulla; la firma resta (anche `nomeScelto`) perché i richiami compilino.
struct EtichettaCanaleApple: View {
    let canale: Canale
    var compatta = false
    var nomeScelto: String? = nil

    // Dal 25 novembre 2026 (decisione dell'utente) c'è un solo canale, quello di Lucy: il canale non si mostra
    // più. Il campo `canale` resta nei dati solo per compatibilità; la firma resta perché i richiami compilino.
    var body: some View { EmptyView() }
}
