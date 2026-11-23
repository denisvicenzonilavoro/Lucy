import SwiftUI

/// Superfici di fondo. Nel tema «Liquid Glass» le vecchie trame (grana, lino, righe, pelle) non si
/// disegnano più: i nomi restano per i chiamanti, e lo sfondo della scrivania è l'acqua.
enum Materiale {
    /// Ex trama ripetuta (grana, lino, righe): sotto resta il vetro della finestra.
    struct Trama: View {
        let nome: String

        var body: some View {
            Color.clear
        }
    }

    /// Ex pelle: niente superficie propria. Sullo schermo resta il vetro del widget;
    /// nella copertina del report (PDF) si vede il colore pieno della carta, che è fisso.
    struct Pelle: View {
        var body: some View {
            Color.clear
        }
    }

    /// Ex lino grafite: il riempimento dei pannelli di vetro del tema (senza materiali di sistema).
    struct Lino: View {
        var body: some View {
            LinearGradient.verticale(Colori.Lino.alto, Colori.Lino.basso)
        }
    }

    /// Sfondo della scrivania e del benvenuto: l'acqua con la pioggia (SfondoAcqua).
    /// I valori arrivano da chi la disegna (ShellView, dalle impostazioni), chiaro o scuro dall'aspetto:
    /// niente StatoShell osservato, così l'acqua non si riconfigura a ogni cambiamento dello stato.
    /// `animato` dice se in questo punto lo sfondo può muoversi («Sfondo animato» acceso e sfondo non coperto
    /// dalla sala della presentazione; false = fermo); `intensita` è la forza della pioggia (gocce al secondo).
    /// Lo sfondo è sempre attivo: l'acqua va sempre allo stesso ritmo, anche con finestre aperte (ingrandite
    /// comprese) e durante le animazioni; niente stato delle finestre osservato qui. Finestra del Mac nascosta,
    /// «Riduci movimento» e riposo del Mac la fermano, il risparmio energetico ne abbassa solo il ritmo: li
    /// gestisce già SfondoAcqua. Nelle istantanee SfondoAcqua mostra da sé il fermo-immagine.
    struct SfondoScrivania: View {
        var animato: Bool
        var intensita: Double
        /// Stile Carta (NOVITÀ 12): lo sfondo vivo scelto in Impostazioni › Aspetto.
        var sfondoCarta: SfondoScrivaniaCarta
        @Environment(\.colorScheme) private var schema

        init(animato: Bool = false, intensita: Double, sfondoCarta: SfondoScrivaniaCarta = .fermo) {
            self.animato = animato
            self.intensita = intensita
            self.sfondoCarta = sfondoCarta
        }

        var body: some View {
            // Stile Carta (Mac e iPad): la scrivania di carta, ferma; l'acqua non nasce (niente Metal).
            // Gli sfondi animati dello stile Carta arrivano con la novità 12.
            if Tema.Stile.usaCarta {
                // Fermo con l'interruttore, sotto le finestre ingrandite e la sala, e con il risparmio energetico
                SfondoVivoCarta(sfondo: sfondoCarta,
                                animato: animato && !ProcessInfo.processInfo.isLowPowerModeEnabled)
            } else {
                SfondoAcqua(animato: animato, intensita: intensita, scuro: schema == .dark)
                    .ignoresSafeArea()
            }
        }
    }

    /// `box-shadow: inset 0 0 170px colore` reso con quattro sfumature sui bordi.
    struct Vignettatura: View {
        let colore: Color
        let ampiezza: CGFloat

        var body: some View {
            ZStack {
                VStack(spacing: 0) {
                    LinearGradient(colors: [colore, .clear], startPoint: .top, endPoint: .bottom).frame(height: ampiezza)
                    Spacer(minLength: 0)
                    LinearGradient(colors: [.clear, colore], startPoint: .top, endPoint: .bottom).frame(height: ampiezza)
                }
                HStack(spacing: 0) {
                    LinearGradient(colors: [colore, .clear], startPoint: .leading, endPoint: .trailing).frame(width: ampiezza)
                    Spacer(minLength: 0)
                    LinearGradient(colors: [.clear, colore], startPoint: .leading, endPoint: .trailing).frame(width: ampiezza)
                }
            }
            .allowsHitTesting(false)
        }
    }
}
