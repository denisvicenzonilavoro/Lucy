import SwiftUI

// I valori del video di presentazione (`Prisma --video`, Shell/Video): colori fissi (il video è sempre «di giorno», salvo
// le scene scure), caratteri, misure e curve. Ricavati dal marchio (Tema.Marca) e dallo stile Carta (TemaCarta), mai
// valori sparsi nelle scene.

enum TemaVideo {
    /// La tela del video: 1920 × 1080 punti, disegnata a scala 2 e ridotta dallo scrittore.
    static let larghezza: CGFloat = 1920
    static let altezza: CGFloat = 1080

    enum Colore {
        /// La carta chiara delle scene con le schermate (`TemaCarta` › carta, giorno).
        static let carta = Color(hex: "#F3EEE4")
        /// La luce più chiara al centro della carta.
        static let cartaLuce = Color(hex: "#FBF8F2")
        /// Il fondo scuro del manifesto (marchio › fondo scuro).
        static let notte = Tema.Marca.fondoScuro
        /// Inchiostro dei titoli su carta.
        static let inchiostro = Color(hex: "#15181F")
        /// Il secondo inchiostro (sottotitoli).
        static let inchiostro2 = Color(hex: "#4E5462")
        /// Le etichette in maiuscolo (oro scuro leggibile su carta).
        static let occhiello = Color(hex: "#856300")
        /// L'avorio del testo su fondo scuro.
        static let avorio = Tema.Marca.avorio
        /// Il «by» del marchio su chiaro.
        static let by = Tema.Marca.byChiaro
        /// L'oro del marchio su chiaro e su scuro.
        static let oro = Tema.Marca.oroChiaro
        static let oroNotte = Tema.Marca.oroScuro
        /// La sottolineatura dorata dei titoli (Carta › oro).
        static let sottolineatura = Color(hex: "#DDA918")
        /// L'ombra calda delle schermate.
        static let ombra = Color(red: 70 / 255, green: 54 / 255, blue: 26 / 255).opacity(0.24)
        /// Il filo intorno alle schermate.
        static let filo = Color(hex: "#15181F").opacity(0.10)
    }

    enum Misura {
        /// Larghezza della schermata nelle scene (16:10): esce un poco dal bordo in basso, come un Mac appoggiato.
        static let schermata: CGFloat = 1480
        /// Raggio degli angoli della schermata.
        static let raggio: CGFloat = 22
        /// Dove comincia la schermata (dall'alto).
        static let sopraSchermata: CGFloat = 262
        /// Il centro dei titoli delle scene, dall'alto.
        static let sopraTitolo: CGFloat = 132
        /// Lato del simbolo nell'apertura.
        static let simbolo: CGFloat = 220
        /// Altezza del simbolo nel marchio completo della chiusura.
        static let marchio: CGFloat = 132
    }

    enum Carattere {
        static let occhiello = TestoCarta(dimensione: 15, peso: .medium, disegno: .monospaced)
        static let titolo = TestoCarta(dimensione: 62, peso: .medium, disegno: .serif)
        static let manifesto = TestoCarta(dimensione: 86, peso: .medium, disegno: .serif)
        static let chiusura = TestoCarta(dimensione: 46, peso: .regular, disegno: .serif, corsivo: true)
        static let firma = TestoCarta(dimensione: 15, peso: .regular, disegno: .monospaced)
        /// Spaziatura delle etichette in maiuscolo.
        static let spaziaturaOcchiello: CGFloat = 4.5
        /// Spaziatura stretta dei titoli grandi.
        static let spaziaturaTitolo: CGFloat = -1.4
    }

    /// Le curve del movimento (morbide, senza rimbalzi).
    enum Curva {
        /// 0…1 di `t` tra `da` e `a`.
        static func tratto(_ t: Double, _ da: Double, _ a: Double) -> Double {
            guard a > da else { return t >= a ? 1 : 0 }
            return min(max((t - da) / (a - da), 0), 1)
        }

        /// Entra e esce piano (cubica).
        static func morbida(_ x: Double) -> Double {
            x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
        }

        /// Parte veloce e si posa (quintica).
        static func posa(_ x: Double) -> Double {
            1 - pow(1 - x, 5)
        }
    }
}
