import SwiftUI

// I valori del video di presentazione (`Prisma --video`, Shell/Video): colori fissi del giorno e della notte (dal marchio,
// Tema.Marca, e dallo stile Carta, TemaCarta), caratteri, misure e curve, sullo stile del video di Lucy Exchange. Mai
// valori sparsi nelle scene.

enum TemaVideo {
    /// La tela del video: 1920 × 1080 punti, disegnata a scala 2 e ridotta dallo scrittore.
    static let larghezza: CGFloat = 1920
    static let altezza: CGFloat = 1080

    enum Colore {
        /// La carta: il bordo e la luce al centro.
        static let carta = Color(hex: "#F3EEE4")
        static let cartaLuce = Color(hex: "#FBF8F2")
        /// Lo scuro: il bordo e la luce al centro.
        static let notte = Color(hex: "#0B0C0F")
        static let notteLuce = Color(hex: "#1B1C22")
        /// Inchiostro dei titoli su carta e su scuro.
        static let inchiostro = Color(hex: "#15181F")
        static let inchiostroNotte = Color(hex: "#EDE6D8")
        /// L'oro dei testi su carta (contrasto 4,5:1) e su scuro.
        static let oro = Color(hex: "#856300")
        static let oroNotte = Color(hex: "#E9B93A")
        /// L'oro del marchio (disco e cursore) e il «by».
        static let oroMarchio = Tema.Marca.oroChiaro
        static let by = Tema.Marca.byChiaro
        /// Il campo della domanda: foglio, matita e il fondo del pulsante.
        static let foglio = Color(hex: "#FBF8F2")
        static let matita = Color(hex: "#6F685B")
        /// Ombre e fili delle finestre su carta e su scuro.
        static let ombraCarta = Color.black.opacity(0.22)
        static let ombraNotte = Color.black.opacity(0.55)
        static let filoCarta = Color.black.opacity(0.10)
        static let filoNotte = Color.white.opacity(0.12)
    }

    enum Misura {
        /// La finestra sotto il titolo: dove comincia (dall'alto) e quanto è larga; esce dal bordo in basso.
        static let cimaFinestra: CGFloat = 300
        static let larghezzaFinestra: CGFloat = 1560
        static let raggioFinestra: CGFloat = 18
        /// Il titolo: corpo, spazio dall'alto e altezza della sua fascia.
        static let corpoTitolo: CGFloat = 66
        static let cimaTitolo: CGFloat = 64
        static let fasciaTitolo: CGFloat = 200
        /// Il corpo delle righe grandi del perché e della chiusura.
        static let corpoGrande: CGFloat = 92
        static let corpoChiusura: CGFloat = 88
        /// La finestra interna dentro un'istantanea di 1440 × 900 punti (senza la barra di Lucy e i bordi).
        static let ritaglioFinestra = CGRect(x: 10, y: 43, width: 1420, height: 846)
        /// Il logo che si disegna (DisegnoLogoVideo), in unità del logo SVG come in Lucy Exchange: guide e braccio del
        /// compasso 1,1, contorno della L e cerchio 2,2, perno di raggio 2,6; 210 unità sopra e sotto il riquadro, dove
        /// passano le guide e il simbolo grande. Larghezza del marchio nell'apertura e nella chiusura.
        static let trattoGuide: CGFloat = 1.1
        static let trattoElle: CGFloat = 2.2
        static let perno: CGFloat = 2.6
        static let margineDisegno: CGFloat = 210
        static let disegnoApertura: CGFloat = 980
        static let disegnoChiusura: CGFloat = 640
        /// La testata della finestra interna (titolo e pulsanti), che resta ferma mentre la pagina scorre: in punti.
        static let testataFinestra: CGFloat = 54
    }

    enum Carattere {
        /// Il serif dei titoli (New York medio) con la spaziatura un poco stretta.
        static func titolo(_ corpo: CGFloat) -> Font { .system(size: corpo, weight: .medium, design: .serif) }
        static func spaziatura(_ corpo: CGFloat) -> CGFloat { -corpo * 0.018 }
        /// Il campo della domanda di Lucy.
        static let campo = Font.system(size: 34)
        static let pulsante = Font.system(size: 30, weight: .semibold)
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

        /// Parte veloce e si posa (cubica d'uscita).
        static func posa(_ x: Double) -> Double {
            1 - pow(1 - x, 3)
        }

        /// Scivola: entra piano, esce piano, più deciso a metà (quintica), per le finestre che passano di lato.
        static func scivola(_ x: Double) -> Double {
            x < 0.5 ? 16 * pow(x, 5) : 1 - pow(-2 * x + 2, 5) / 2
        }

        /// Quanto è avanti un tratto da `a` a `b` secondi, con la curva data.
        static func p(_ t: Double, _ a: Double, _ b: Double, _ curva: (Double) -> Double = morbida) -> Double {
            curva(tratto(t, a, b))
        }

        /// Da `a` a `b` mentre il tratto avanza.
        static func da(_ a: CGFloat, _ b: CGFloat, _ p: Double) -> CGFloat {
            a + (b - a) * CGFloat(p)
        }
    }
}
