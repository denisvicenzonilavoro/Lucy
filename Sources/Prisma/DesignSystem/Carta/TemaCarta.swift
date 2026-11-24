#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

// Lo stile «Carta» (Design/template-carta.html, 20 novembre 2026): carta e inchiostro, sottolineature dorate, cerchi
// rossi, evidenziatore, note in blu stilografica. È lo stile di Prisma sul Mac e sull'iPad; l'iPhone resta sul tema
// Apple finché non lo si ripensa (scelta dell'utente del 23 novembre 2026).
// I valori sono le variabili in testa al CSS del template (`:root` per il giorno, `body.night` per la notte).
// Unità: 1 px CSS del template = 1 pt SwiftUI.

extension Tema {
    /// Lo stile di disegno dell'app: «carta» (Mac e iPad) o il tema Apple di prima (iPhone).
    /// Si sceglie una volta all'avvio, prima di disegnare (`PrismaApp.init`, `PrismaAppMobile.init`), come
    /// `Vetro.semplificato`. Con la variabile d'ambiente `PRISMA_TEMA=apple` il Mac torna al tema di prima
    /// (confronto ed emergenza).
    enum Stile: Equatable {
        case apple, carta

        nonisolated(unsafe) static var attivo: Stile = predefinito

        /// true con lo stile Carta (un nome diverso dal caso `.carta`).
        static var usaCarta: Bool { attivo == .carta }

        /// Il Mac parte in Carta; iPhone e iPad partono dal tema Apple e l'iPad passa a Carta in `PrismaAppMobile.init`.
        private static var predefinito: Stile {
            if ProcessInfo.processInfo.environment["PRISMA_TEMA"] == "apple" { return .apple }
            #if os(macOS)
            return .carta
            #else
            return .apple
            #endif
        }

        /// Lo stile per un dispositivo iOS: Carta sull'iPad, Apple sull'iPhone (che per ora resta com'è).
        static func perDispositivo(iPad: Bool) -> Stile {
            if ProcessInfo.processInfo.environment["PRISMA_TEMA"] == "apple" { return .apple }
            return iPad ? .carta : .apple
        }
    }
}

extension Color {
    /// Colore che segue l'aspetto (giorno o notte) e lo stile attivo (Apple o Carta), scelto quando si disegna.
    static func tema(apple chiaro: Color, _ scuro: Color, carta cartaChiaro: Color, _ cartaScuro: Color) -> Color {
        #if os(macOS)
        let a = NSColor(chiaro), s = NSColor(scuro)
        let c = NSColor(cartaChiaro), cs = NSColor(cartaScuro)
        return Color(nsColor: NSColor(name: nil) { aspetto in
            let notte = aspetto.prismaScuro
            if Tema.Stile.attivo == .carta { return notte ? cs : c }
            return notte ? s : a
        })
        #elseif os(iOS)
        let a = UIColor(chiaro), s = UIColor(scuro)
        let c = UIColor(cartaChiaro), cs = UIColor(cartaScuro)
        return Color(uiColor: UIColor { tratti in
            let notte = tratti.userInterfaceStyle == .dark
            if Tema.Stile.usaCarta { return notte ? cs : c }
            return notte ? s : a
        })
        #endif
    }
}

/// I gettoni dello stile Carta. Le schermate li usano attraverso i gettoni di sempre (`Tema.Apple.Colore`,
/// `Tema.Colore`), che con lo stile Carta prendono questi valori; qui stanno anche quelli nuovi (oro, penna,
/// evidenziatore, scrivania, grana).
enum TemaCarta {

    // MARK: - Colori (variabili CSS del template)

    enum Colore {
        /// Inchiostro con alfa: `rgba(var(--ir), a)` (21,24,31 di giorno, 237,230,216 di notte).
        static func inchiostro(_ a: Double) -> (Color, Color) {
            (Color(r: 21, g: 24, b: 31, a: a), Color(r: 237, g: 230, b: 216, a: a))
        }

        // Giorno · notte
        static let pagina1 = (Color(hex: "#E9E3D7"), Color(hex: "#1F2024"))
        static let pagina2 = (Color(hex: "#CBC2B0"), Color(hex: "#09090B"))
        static let scrivania1 = (Color(hex: "#ECE6DA"), Color(hex: "#1D1E22"))
        static let scrivania2 = (Color(hex: "#D3C9B6"), Color(hex: "#0C0C0E"))
        static let carta = (Color(hex: "#F3EEE4"), Color(hex: "#111215"))
        static let carta2 = (Color(hex: "#EAE3D5"), Color(hex: "#17181C"))
        static let scheda = (Color(hex: "#FBF8F2"), Color(hex: "#1A1B20"))
        static let foglio = (Color(hex: "#F6F2EA"), Color(hex: "#141519"))
        static let ink = (Color(hex: "#15181F"), Color(hex: "#EDE6D8"))
        static let ink2 = (Color(hex: "#4E5462"), Color(hex: "#B3AC9D"))
        static let matita = (Color(hex: "#6F685B"), Color(hex: "#8C8679"))
        /// Il colore del testo sopra l'inchiostro (`--onink`).
        static let suInchiostro = (Color(hex: "#F3EEE4"), Color(hex: "#111215"))
        static let filo = inchiostro(0.09)
        static let filo2 = (Color(r: 21, g: 24, b: 31, a: 0.16), Color(r: 237, g: 230, b: 216, a: 0.15))
        static let evidenziatore = (Color(r: 244, g: 205, b: 72, a: 0.78), Color(r: 233, g: 185, b: 58, a: 0.30))
        static let oro = (Color(hex: "#DDA918"), Color(hex: "#E9B93A"))
        /// L'oro delle scritte (`--goldT`), più scuro di giorno per essere leggibile (#856300 al posto di #8E6A06 del template:
        /// contrasto almeno 4,5 anche sul foglio, verifica di accessibilità del 23 novembre 2026).
        static let oroTesto = (Color(hex: "#856300"), Color(hex: "#E9B93A"))
        /// L'arancione delle scritte sulla carta: un poco più scuro di #B4530B, che sul foglio avorio dava 4,496
        /// (contrasto almeno 4,5 anche sul foglio e sulla carta2; in scuro resta #F5A94A).
        static let arancioTesto = (Color(hex: "#A84C09"), Color(hex: "#F5A94A"))
        static let rosso = (Color(hex: "#AE3D2B"), Color(hex: "#E4826B"))
        static let verde = (Color(hex: "#2C6A4D"), Color(hex: "#7CC6A0"))
        /// Il blu stilografica della penna di Vera (`--pen`).
        static let penna = (Color(hex: "#2A4A80"), Color(hex: "#9FB8EA"))
        /// Il «vetro» del dock e dei pannelli che galleggiano: carta quasi coprente (`--glass`).
        static let velina = (Color(r: 251, g: 248, b: 242, a: 0.8), Color(r: 26, g: 27, b: 32, a: 0.8))
        static let area = (Color(r: 221, g: 169, b: 24, a: 0.16), Color(r: 233, g: 185, b: 58, a: 0.13))
        static let chip = inchiostro(0.05)
        /// Nessun colore: i riflessi e i fili di luce del vetro, che sulla carta non ci sono.
        static let trasparente = (Color.clear, Color.clear)
        static let sopra = inchiostro(0.08)
        /// Il velo sotto un pannello o un dettaglio aperto.
        static let velo = (Color(r: 70, g: 54, b: 26, a: 0.18), Color(r: 0, g: 0, b: 0, a: 0.45))
        /// Le fasce di luce sulla scrivania (primo gradiente radiale del `#desk`).
        static let luceScrivania = (Color(r: 255, g: 255, b: 255, a: 0.4), Color(r: 233, g: 185, b: 58, a: 0.05))

        /// Un colore Carta che segue l'aspetto.
        static func d(_ coppia: (Color, Color)) -> Color { .dinamico(chiaro: coppia.0, scuro: coppia.1) }

        static let inchiostroD = d(ink)
        static let inchiostro2D = d(ink2)
        static let matitaD = d(matita)
        static let cartaD = d(carta)
        static let carta2D = d(carta2)
        static let schedaD = d(scheda)
        static let foglioD = d(foglio)
        static let filoD = d(filo)
        static let filo2D = d(filo2)
        static let oroD = d(oro)
        static let oroTestoD = d(oroTesto)
        static let rossoD = d(rosso)
        static let verdeD = d(verde)
        static let pennaD = d(penna)
        static let evidenziatoreD = d(evidenziatore)
        static let velinaD = d(velina)
        static let chipD = d(chip)
        static let suInchiostroD = d(suInchiostro)
        static let scrivania1D = d(scrivania1)
        static let scrivania2D = d(scrivania2)
        static let luceScrivaniaD = d(luceScrivania)
        /// Fondo delle icone del dock (`--iconbg`, dall'alto in basso).
        static let iconaAltoD = d((Color(hex: "#FDFBF6"), Color(hex: "#2A2B31")))
        static let iconaBassoD = d((Color(hex: "#EAE3D4"), Color(hex: "#17181C")))
        /// La tessera di Vera nel dock: inchiostro di giorno, carta di notte.
        static let veraAltoD = d((Color(hex: "#22252E"), Color(hex: "#F3EEE4")))
        static let veraBassoD = d((Color(hex: "#121419"), Color(hex: "#DCD4C4")))
        static let veraLetteraD = d((Color(hex: "#F3EEE4"), Color(hex: "#15181F")))
        /// La filigrana del logo sulla scrivania (`.wmark`: 6% di giorno, 7% di notte).
        static let filigranaD = d((Color(r: 21, g: 24, b: 31, a: 0.06), Color(r: 237, g: 230, b: 216, a: 0.07)))
    }

    // MARK: - Ombre (box-shadow del template, rgba(var(--sr), a): 70,54,26 di giorno, nero di notte)

    enum Ombra {
        private static func sr(_ a: Double, scuro: Bool) -> Color {
            scuro ? Color(r: 0, g: 0, b: 0, a: a) : Color(r: 70, g: 54, b: 26, a: a)
        }

        /// `.w`: 0 20 44 −26 al 50%.
        static func riquadro(scuro: Bool) -> [StratoOmbra] {
            [StratoOmbra(colore: sr(0.5, scuro: scuro), y: 20, sfocatura: 44, espansione: -26)]
        }

        /// `#win`: 0 46 100 −34 al 62% e 0 10 30 −12 al 25%.
        static func finestra(scuro: Bool) -> [StratoOmbra] {
            [StratoOmbra(colore: sr(0.62, scuro: scuro), y: 46, sfocatura: 100, espansione: -34),
             StratoOmbra(colore: sr(0.25, scuro: scuro), y: 10, sfocatura: 30, espansione: -12)]
        }

        /// `#dock`: 0 22 44 −22 al 55%.
        static func dock(scuro: Bool) -> [StratoOmbra] {
            [StratoOmbra(colore: sr(0.55, scuro: scuro), y: 22, sfocatura: 44, espansione: -22)]
        }

        /// `.dk` e `.tbtn`: 0 5 12 −5 al 40%.
        static func tessera(scuro: Bool) -> [StratoOmbra] {
            [StratoOmbra(colore: sr(0.4, scuro: scuro), y: 5, sfocatura: 12, espansione: -5)]
        }
    }

    // MARK: - Raggi

    enum Raggio {
        /// `.w`: i riquadri della scrivania.
        static let riquadro: CGFloat = 22
        /// `#win`: la finestra.
        static let finestra: CGFloat = 14
        /// `#dock`.
        static let dock: CGFloat = 26
        /// `.dk`: le icone del dock.
        static let icona: CGFloat = 15
    }

    // MARK: - Grana (`#stage:after`: 0,22 in moltiplicazione di giorno, 0,06 in schermo di notte)

    enum Grana {
        static let opacitaGiorno: Double = 0.22
        static let opacitaNotte: Double = 0.06
        /// Lato della tessera ripetuta, in punti.
        static let lato = 200
    }

    // MARK: - Caratteri

    /// Il disegno dei caratteri con lo stile Carta: New York (serif di sistema) per titoli e numeri grandi, SF Mono
    /// per le etichette in maiuscolo, SF Pro per il resto. `dimensione` è quella del tema, prima della scala del testo.
    /// `sogliaSerif`: da che dimensione un testo è un titolo. 17 per i gradini del tema Apple (che sono titoli da 17 in
    /// su), 20 per i caratteri generici (`Tema.Testo.sf`), così corpi, campi e pulsanti grandi restano in SF.
    static func disegno(dimensione: CGFloat, peso: Font.Weight, maiuscolo: Bool, disegno: Font.Design,
                        sogliaSerif: CGFloat = 17) -> (Font.Design, Font.Weight) {
        guard Tema.Stile.usaCarta, disegno == .default else { return (disegno, peso) }
        if dimensione >= sogliaSerif {
            // Il serif del template è a peso 500: i grassetti diventano medi, i leggeri restano leggeri
            let p: Font.Weight = (peso == .light || peso == .thin || peso == .ultraLight) ? .regular : .medium
            return (.serif, p)
        }
        if maiuscolo { return (.monospaced, .regular) }
        return (disegno, peso)
    }
}
