#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

// Carta stampata dei prospetti di dettaglio, nello stile Lucy: carta bianca, testata con il marchio Lucy e il filo
// d'inchiostro, titoli in New York con la sottolineatura d'oro, etichette in SF Mono, testi in SF. Su carta i colori
// sono asciutti: niente trame, poco inchiostro. Colori sempre fissi e opachi: la carta resta chiara.

extension Colori {
    enum Carta {
        static let foglio = Color(hex: "#FFFFFF")
        /// Il marchio Lucy nella testata: sempre a inchiostro su carta.
        static let logo = Tema.Colore.logoStampa
        // Stile Lucy (Design/template-carta.html, `.a4`): inchiostro, matita, oro; colori fissi e opachi
        static let intestazione = Color(hex: "#4E5462")
        static let filettoForte = Color(hex: "#15181F")
        static let filetto = Color(hex: "#E4E0D6")
        static let filettoRiga = Color(hex: "#EEEAE1")
        static let titolo = Color(hex: "#15181F")
        static let testo = Color(hex: "#2E323B")
        static let testoTenue = Color(hex: "#6F685B")
        static let piede = Color(hex: "#8C8578")
        /// Il numero della sezione e l'occhiello: l'oro scuro, leggibile sulla carta bianca.
        static let numeroSezione = Color(hex: "#9A760C")
        static let zebra = Color(hex: "#FAF8F2")
        static let evidenza = Color(hex: "#FBF4DA")
        static let riquadro = Color(hex: "#FAF7EF")
        static let riquadroBordo = Color(hex: "#E4DFD2")
        static let avvisoFondo = Color(hex: "#FBF3DF")
        static let avvisoBordo = Color(hex: "#E2C98F")
        static let avvisoTesto = Color(hex: "#6B5426")
        static let griglia = Color(hex: "#ECE8DF")
        static let versato = Color(hex: "#9C978C")
        static let atteso = Color(hex: "#2B4C7E")
        static let prudente = Color(hex: "#B07B4F")
        static let favorevole = Color(hex: "#2C6A4D")
        /// Fondo dell'anteprima a schermo (.docs-reading-room).
        static let tavoloAlto = Color(hex: "#d8dcda")
        static let tavoloBasso = Color(hex: "#e7e6df")
        static let ombraFoglio = Color(hex: "#2634352e")
        /// Migliorie d'uso 22: il timbro «SOLO PER TE» delle pagine del consulente (arancio bruciato, opaco e fisso).
        static let timbro = Color(hex: "#B4530B")
        /// Sotto il timbro: la carta, perché resti leggibile anche sopra la data della testata.
        static let fondoTimbro = Color(hex: "#ffffff")
    }
}

extension Tipo {
    /// Caratteri della carta: SF del sistema, alle dimensioni fisse della pagina (non seguono la Dimensione
    /// del testo). Ogni carattere ha il suo gemello AppKit, usato dall'impaginazione per misurare i testi.
    enum Carta {
        static func font(_ dimensione: CGFloat, grassetto: Bool = false) -> Font {
            Font.system(size: dimensione, weight: grassetto ? .bold : .regular)
        }

        /// New York per i titoli e le cifre grandi, SF Mono per occhielli ed etichette (stile Lucy).
        static func serif(_ dimensione: CGFloat, _ peso: Font.Weight = .medium) -> Font {
            Font.system(size: dimensione, weight: peso, design: .serif)
        }

        static func mono(_ dimensione: CGFloat, _ peso: Font.Weight = .medium) -> Font {
            Font.system(size: dimensione, weight: peso, design: .monospaced)
        }

        static func nsFont(_ dimensione: CGFloat, grassetto: Bool = false) -> FontPiattaforma {
            FontPiattaforma.systemFont(ofSize: dimensione, weight: grassetto ? .bold : .regular)
        }

        static let testataPiccola = mono(5.6)
        static let data = mono(7.4)
        static let occhiello = mono(7)
        static let titolo = serif(24)
        static let sottotitolo = font(9.5)
        static let firma = font(8.5)
        static let corrente = font(9)
        static let numeroSezione = mono(10)
        static let sezione = serif(14.5)
        static let indicatoreEtichetta = mono(6.1)
        static let indicatoreValore = serif(17)
        static let indicatoreNota = font(7)
        static let voceEtichetta = mono(6.1)
        static let voceValore = font(9)
        static let tabellaTesta = font(6.5, grassetto: true)
        static let tabella = font(8)
        static let tabellaForte = font(8, grassetto: true)
        static let testo = font(9)
        static let nota = font(7)
        static let assi = font(6.5)
        static let piede = mono(6, .regular)
        /// Migliorie d'uso 22: il timbro «SOLO PER TE» e la frase in fondo all'ultima pagina.
        static let timbro = font(9.5, grassetto: true)
        static let notaPerTe = font(6.5, grassetto: true)

        // Gemelli per le misure
        static let nsVoceValore = nsFont(9)
        static let nsTesto = nsFont(9)
        static let nsNota = nsFont(7)
    }
}

extension Misure {
    enum Carta {
        /// A4 verticale in punti tipografici.
        static let pagina = CGSize(width: 595, height: 842)
        static let margineLato: CGFloat = 42
        static let margineAlto: CGFloat = 34
        static let margineBasso: CGFloat = 28
        static var larghezzaUtile: CGFloat { pagina.width - margineLato * 2 }

        /// Intestazione della prima pagina (carta intestata, titolo, cliente e canale).
        static let testataPrima: CGFloat = 156
        /// Intestazione corrente delle pagine successive.
        static let testataCorrente: CGFloat = 30
        /// Altezza del simbolo del logo nella testata della prima pagina e in quella corrente.
        static let logoTestata: CGFloat = 14
        static let logoCorrente: CGFloat = 8.5
        static let piede: CGFloat = 24
        static let spazioBlocchi: CGFloat = 8

        static let sezione: CGFloat = 34
        static let indicatori: CGFloat = 60
        static let testaTabella: CGFloat = 20
        static let rigaTabella: CGFloat = 15.5
        static let rigaTotale: CGFloat = 18
        static let grafico: CGFloat = 176
        static let legenda: CGFloat = 16
        static let voceEtichetta: CGFloat = 10
        static let voceMargine: CGFloat = 7
        static let interlinea: CGFloat = 2.5
        static let riquadroMargine: CGFloat = 8
        static let raggio: CGFloat = 3
        static let colonnaVoci: CGFloat = 14
        /// Righe minime di una tabella prima di andare a capo pagina.
        static let righeMinime = 3
        /// Scala dell'etichetta del canale dentro le tabelle.
        static let scalaEtichetta: CGFloat = 0.82

        // Migliorie d'uso 22: il timbro «SOLO PER TE», misurato dal bordo della pagina (anche in A4 orizzontale)
        static let timbroSpaziatura: CGFloat = 1
        static let timbroBordo: CGFloat = 1.5
        static let timbroRaggio: CGFloat = 6
        static let timbroPadding = EdgeInsets(top: 3, leading: 7, bottom: 3, trailing: 7)
        static let timbroDestra: CGFloat = 46
        static let timbroAlto: CGFloat = 40
        /// Sulle pagine di `PaginaCarta` (posizione, confronto, riesame) a 40 dall'alto c'è la data della testata:
        /// lì il timbro sta nel margine alto, sopra la testata, senza coprire nulla.
        static let timbroAltoCarta: CGFloat = 8
        /// La frase dell'ultima pagina, nel margine basso sotto il piede (non tocca l'area del contenuto).
        static let notaPerTeBasso: CGFloat = 9
    }
}
