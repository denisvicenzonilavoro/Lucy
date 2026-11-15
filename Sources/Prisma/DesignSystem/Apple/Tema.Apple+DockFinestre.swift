import SwiftUI

// Gettoni del dock che si ingrandisce e della finestra che esce dall'icona e vi rientra
// (Design/template-apple-specifica.md §3.4, §3.5, §1.8). Le viste stanno in Shell/Dock.swift e Shell/VoloFinestra.swift.
// Le curve e le durate di base sono già in TemaAppleMoto.swift (`FinestraApre`, `FinestraChiude`,
// `IngrandimentoDock`, `RimbalzoIcona`): qui solo ciò che serve in più.

extension Tema.Apple.Moto {
    /// La finestra che vola fra l'icona del dock e la sua cornice (apertura, chiusura, riduzione, ripristino).
    enum VoloFinestra {
        /// La finestra è del tutto opaca quando è uscita dall'icona per questa parte del volo (in chiusura è il punto
        /// che la curva raggiunge al 60% del tempo: lì comincia a svanire). Una sola regola per i due versi.
        static let valoreOpaco: Double = 0.18
        /// Senza un'icona da cui partire (app fuori dal dock): appena più piccola, al suo posto.
        static let scalaSulPosto: CGFloat = 0.94
        /// Passi di bisezione per ritrovare il tempo dal valore della curva (2^-24: ben sotto un fotogramma).
        static let passiCurva = 24
        /// Apertura: 0,6 s con `(0.3,1.12,0.5,1)`.
        static func apertura(durata: Double = FinestraApre.durata) -> Animation {
            Curva.finestraApre.animazione(durata)
        }
        /// Chiusura e riduzione: 0,48 s con `(0.5,0,0.3,1)`.
        static func chiusura(durata: Double = FinestraChiude.durata) -> Animation {
            Curva.finestraChiude.animazione(durata)
        }
    }

    /// Il pallino sotto le app aperte: compare e scompare in 0,3 s.
    enum PuntinoDock {
        static let durata = 0.30
        static var animazione: Animation { .easeInOut(duration: durata * Tema.Apple.Moto.ritmo) }
    }
}

extension Tema.Apple.Moto.Curva {
    /// Il punto della bézier al parametro `s` (0…1): `x` è il tempo, `y` il valore.
    func punto(alParametro s: Double) -> (x: Double, y: Double) {
        let u = 1 - s
        let a = 3 * u * u * s
        let b = 3 * u * s * s
        let c = s * s * s
        return (a * x1 + b * x2 + c, a * y1 + b * y2 + c)
    }

    /// Il valore della curva al tempo `t` (0…1): dove si trova un movimento a quel punto della sua durata.
    func valore(alTempo t: Double) -> Double {
        if t <= 0 { return 0 }
        if t >= 1 { return 1 }
        var basso = 0.0
        var alto = 1.0
        for _ in 0..<Tema.Apple.Moto.VoloFinestra.passiCurva {
            let medio = (basso + alto) / 2
            if punto(alParametro: medio).x >= t { alto = medio } else { basso = medio }
        }
        return punto(alParametro: alto).y
    }

    /// Il tempo (0…1) in cui la curva arriva per la prima volta al valore `v`. Vale anche per le curve che
    /// superano 1 (apertura della finestra): la salita fino al picco è monotona e si cerca lì.
    func tempo(alValore v: Double) -> Double {
        if v <= 0 { return 0 }
        // Oltre il valore finale si cerca il primo istante in cui ci arriva
        let obiettivo = min(v, 1)
        var basso = 0.0
        var alto = 1.0
        for _ in 0..<Tema.Apple.Moto.VoloFinestra.passiCurva {
            let medio = (basso + alto) / 2
            if punto(alParametro: medio).y >= obiettivo { alto = medio } else { basso = medio }
        }
        return min(max(punto(alParametro: alto).x, 0), 1)
    }
}

// MARK: - La riga in testa alla finestra (migliorie d'uso 4, solo sul Mac)

extension Tema.Apple {
    /// La riga unica in testa alla finestra interna (`#win .hd` del template delle migliorie d'uso, righe 170-171 e
    /// 409-417): chiusura, icona, titolo, sottotitolo, testo a destra e azioni dell'app, alta 60. Al posto della barra
    /// con i tre pallini e dell'intestazione dell'app sotto (38 + 54 nel template di prima): il contenuto guadagna 32
    /// punti. `Misure.Finestra.barraTitolo` e `Misure.IntestazioneApp` restano per iPhone e iPad.
    enum RigaTesta {
        static let altezza: CGFloat = 60
        /// `padding: 0 18px 0 16px`.
        static let padding = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 18)
        /// `gap: 10px` fra gli elementi della riga.
        static let spazio: CGFloat = 10

        // La chiusura (`.wx`): un cerchio solo al posto dei tre pallini («quelli veri sono del Mac»)
        static let chiusura: CGFloat = 28
        /// Il glifo ✕ da 12 (viewBox 24).
        static let glifoChiusura: CGFloat = 12
        /// `stroke-width: 3` su un viewBox di 24, disegnato a 12: 1,5 punti.
        static let trattoChiusura: CGFloat = 1.5
        /// Gli estremi del ✕ nel viewBox di 24 (`M5 5l14 14M19 5L5 19`): da 5 a 19.
        static let estremoChiusura: CGFloat = 5.0 / 24.0
        static let fondoChiusura = Colore.chip
        static let segnoChiusura = Colore.inchiostro2
        /// Al passaggio del puntatore: il rosso della chiusura del Mac e il segno bianco.
        static let fondoChiusuraSopra = Color(hex: "#FF5F57")
        static let segnoChiusuraSopra = Color.white
        /// Premuta: `transform: scale(.9)`.
        static let scalaPremuta: CGFloat = 0.9
        /// `transition: background .2s, color .2s`.
        static let durataPassaggio = 0.2
        /// `transform .25s var(--spring)`.
        static let durataPressione = 0.25

        /// L'icona dell'app (`.wi`: 26, con 2 di margine a sinistra).
        static let icona: CGFloat = 26
        static let margineIcona: CGFloat = 2

        /// Titolo 17 bold (`#win .hd h1`), sottotitolo 12 maiuscolo con tracking 0,6 (`.sub`).
        static let titolo = Carattere.titoloFinestra
        static let sottotitolo = Carattere.sottotitolo
        static let coloreTitolo = Colore.inchiostro
        static let coloreTitoloSpento = Colore.inchiostro2
        static let coloreSottotitolo = Colore.inchiostro2

        /// Il testo a destra (`#wRight`): 13 medium, `ink2`, con un filo a sinistra e 12 di spazio (più 2 di margine).
        static let testoDestro = Carattere(dimensione: 13, peso: .medium)
        static let coloreTestoDestro = Colore.inchiostro2
        static let filoTestoDestro = Colore.separatore
        static let spessoreFilo: CGFloat = Misura.bordo
        static let spazioTestoDestro: CGFloat = 12
        static let margineTestoDestro: CGFloat = 2
        /// L'altezza del filo a sinistra del testo destro (quella della riga del testo).
        static let altezzaFilo: CGFloat = 16
    }
}
