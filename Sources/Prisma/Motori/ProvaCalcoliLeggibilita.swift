#if os(macOS)
import AppKit
import SwiftUI

/// Migliorie d'uso 7 («Testi piccoli più leggibili»): il rapporto di contrasto WCAG di `inchiostro2`, `inchiostro3` e
/// `arancioTesto` sul fondo della finestra e della card, in chiaro e in scuro, è almeno 4,5 (il minimo per un testo
/// piccolo). Chiamata da `ProvaCalcoli.esegui()` sul thread principale; solo Mac (iPhone e iPad tengono i toni di
/// prima fino al loro aggiornamento).
enum ProvaCalcoliLeggibilita {
    /// Il minimo WCAG AA per un testo piccolo.
    static let minimo = 4.5

    private typealias RGBA = (r: Double, g: Double, b: Double, a: Double)

    @MainActor static func esegui(_ verifica: VerificaCalcoli) {
        let A = Tema.Apple.Colore.self
        let testi: [(String, Color)] = [("inchiostro2", A.inchiostro2), ("inchiostro3", A.inchiostro3),
                                        ("arancioTesto", A.arancioTesto)]
        for scuro in [false, true] {
            // La finestra si legge come fondo pieno (sotto c'è il vetro); la card le sta sopra.
            let finestra = componenti(A.finestra, scuro: scuro)
            let fondoFinestra: RGBA = (finestra.r, finestra.g, finestra.b, 1)
            let fondoCard = sopra(componenti(A.card, scuro: scuro), fondoFinestra)
            for (nome, colore) in testi {
                let testo = componenti(colore, scuro: scuro)
                for (nomeFondo, fondo) in [("finestra", fondoFinestra), ("card", fondoCard)] {
                    let rapporto = contrasto(sopra(testo, fondo), fondo)
                    verifica.vero("Leggibilità: \(nome) sulla \(nomeFondo) \(scuro ? "in scuro" : "in chiaro") almeno 4,5 "
                                  + "(\(String(format: "%.2f", rapporto)))", rapporto >= minimo)
                }
            }
        }
        // L'arancione pieno dei segni resta quello del template.
        let pieno = componenti(A.arancio, scuro: false)
        verifica.vero("Leggibilità: l'arancione dei segni resta #E08A00",
                      abs(pieno.r - 224.0 / 255) < 0.01 && abs(pieno.g - 138.0 / 255) < 0.01 && abs(pieno.b) < 0.01)
    }

    /// Le componenti sRGB di un colore del tema nell'aspetto chiesto (i colori dinamici si risolvono qui).
    @MainActor private static func componenti(_ colore: Color, scuro: Bool) -> RGBA {
        var esito: RGBA = (0, 0, 0, 1)
        guard let aspetto = NSAppearance(named: scuro ? .darkAqua : .aqua) else { return esito }
        aspetto.performAsCurrentDrawingAppearance {
            let c = NSColor(colore).usingColorSpace(.sRGB) ?? NSColor.black
            esito = (Double(c.redComponent), Double(c.greenComponent), Double(c.blueComponent), Double(c.alphaComponent))
        }
        return esito
    }

    /// Un colore con la sua trasparenza steso sopra un fondo pieno.
    private static func sopra(_ c: RGBA, _ fondo: RGBA) -> RGBA {
        (c.r * c.a + fondo.r * (1 - c.a), c.g * c.a + fondo.g * (1 - c.a), c.b * c.a + fondo.b * (1 - c.a), 1)
    }

    /// Luminanza relativa WCAG 2.1.
    private static func luminanza(_ c: RGBA) -> Double {
        func lineare(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * lineare(c.r) + 0.7152 * lineare(c.g) + 0.0722 * lineare(c.b)
    }

    static func contrasto(_ a: (r: Double, g: Double, b: Double, a: Double),
                          _ b: (r: Double, g: Double, b: Double, a: Double)) -> Double {
        let la = luminanza(a), lb = luminanza(b)
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }
}
#endif
