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

// MARK: - Il menu della pillola dell'app (migliorie d'uso 67, solo sul Mac)

extension Tema.Apple {
    /// Il menu sotto il nome dell'app nella barra (`#menuP` del template delle migliorie d'uso, righe 465-477 e 3098-3103):
    /// le app aperte, gli spazi di lavoro con il loro nome, «Salva le finestre aperte come spazio…» e «Torna alla
    /// scrivania». La vista sta in Shell/MenuAppBarra.swift.
    enum MenuApp {
        /// `min-width: 236px; padding: 8px`, 8 punti sotto la pillola.
        static let larghezzaMinima: CGFloat = 236
        static let larghezzaMassima: CGFloat = 340
        static let margine: CGFloat = 8
        static let distanzaPillola: CGFloat = 8
        /// Non scende sul dock e non tocca i bordi della shell.
        static let bordo: CGFloat = 12
        static let raggio: CGFloat = Raggio.tile
        static let superficie = Superficie.vetroSopra
        /// Le voci (`#menuP .vo`): alte 36, `padding: 0 10px`, `gap: 10px`, raggio 12, 13,5 semibold.
        static let altezzaRiga: CGFloat = 36
        static let rigaPadding = EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10)
        static let spazioRiga: CGFloat = 10
        static let raggioRiga: CGFloat = 12
        static let voce = Carattere(dimensione: 13.5, peso: .semibold)
        static let coloreVoce = Colore.inchiostro
        static let coloreVoceSpenta = Colore.inchiostro2
        static let sopra = Colore.chip
        /// L'icona dell'app 20 con raggio 5; il glifo dello schermo degli spazi 16.
        static let icona: CGFloat = 20
        static let raggioIcona: CGFloat = 5
        static let glifo = Carattere(dimensione: 14, peso: .medium)
        static let latoGlifo: CGFloat = 20
        static let coloreGlifo = Colore.inchiostro2
        /// A destra, in piccolo: il nome del cliente o le app dello spazio (`.vo small`: 11,5 secondario su `chip`).
        static let notaCliente = Carattere(dimensione: 11.5, peso: .medium)
        static let coloreNota = Colore.inchiostro2
        static let fondoNota = Colore.chip
        static let paddingNota = EdgeInsets(top: 1, leading: 7, bottom: 1, trailing: 7)
        /// Il filetto fra i gruppi: 1 punto, `margin: 5px 8px`.
        static let filetto = Colore.separatore
        static let spessoreFiletto: CGFloat = 1
        static let paddingFiletto = EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8)
        /// Il modulo per salvare lo spazio: titolo 15 bold, campo alto 32 su `chip`, raggio 10.
        static let larghezzaModulo: CGFloat = 300
        static let titoloModulo = Carattere(dimensione: 15, peso: .bold)
        static let testoModulo = Carattere(dimensione: 12.5, peso: .regular)
        static let campo = Carattere(dimensione: 13, peso: .regular)
        static let altezzaCampo: CGFloat = 32
        static let raggioCampo: CGFloat = 10
        static let fondoCampo = Colore.chip
        static let paddingCampo: CGFloat = 10
        static let spazioModulo: CGFloat = 10
        static let paddingModulo: CGFloat = 8
        /// Le voci spente («Nessun’altra app aperta, per ora», «Salva…» senza finestre).
        static let opacitaSpenta: Double = 0.5
    }
}

extension Tema.Apple.Moto {
    /// Il menu della pillola dell'app entra in 320 ms da 8 punti più su, con la scala 0,97 e la molla (riga 3101).
    enum MenuApp {
        static let durata = 0.32
        static let spostamento: CGFloat = -8
        static let scala: CGFloat = 0.97
        static var animazione: Animation { Curva.molla.animazione(durata) }
    }
}
