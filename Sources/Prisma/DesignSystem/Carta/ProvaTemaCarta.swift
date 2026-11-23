#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

/// Prova dello stile Carta dentro `Prisma --prova-calcoli` (chiamata da `ProvaCalcoli.esegui()`): i colori sono quelli
/// del template (giorno e notte), i testi si leggono sulla carta (contrasto almeno 4,5), lo stile giusto per ogni
/// dispositivo (Carta su Mac e iPad, Apple sull'iPhone), i caratteri (New York, SF Mono), la memoria dei segni a mano
/// (la prima volta del giorno si disegna, poi no, il giorno dopo di nuovo) e la grana della carta sempre uguale.
enum ProvaTemaCarta {
    private typealias C = TemaCarta.Colore

    static func esegui(_ verifica: VerificaCalcoli) {
        colori(verifica)
        contrasti(verifica)
        stile(verifica)
        memoriaSegni(verifica)
        grana(verifica)
    }

    // MARK: Colori del template

    private static func colori(_ verifica: VerificaCalcoli) {
        let attesi: [(String, (Color, Color), String, String)] = [
            ("inchiostro", C.ink, "#15181F", "#EDE6D8"),
            ("inchiostro 2", C.ink2, "#4E5462", "#B3AC9D"),
            ("matita", C.matita, "#6F685B", "#8C8679"),
            ("carta", C.carta, "#F3EEE4", "#111215"),
            ("scheda", C.scheda, "#FBF8F2", "#1A1B20"),
            ("foglio", C.foglio, "#F6F2EA", "#141519"),
            ("oro", C.oro, "#DDA918", "#E9B93A"),
            ("rosso", C.rosso, "#AE3D2B", "#E4826B"),
            ("verde", C.verde, "#2C6A4D", "#7CC6A0"),
            ("penna", C.penna, "#2A4A80", "#9FB8EA"),
        ]
        for (nome, coppia, giorno, notte) in attesi {
            verifica.vero("Carta: \(nome) di giorno come il template (\(giorno))", esadecimale(coppia.0) == giorno)
            verifica.vero("Carta: \(nome) di notte come il template (\(notte))", esadecimale(coppia.1) == notte)
        }
    }

    // MARK: Contrasti (WCAG, almeno 4,5 per il testo)

    private static func contrasti(_ verifica: VerificaCalcoli) {
        let coppie: [(String, (Color, Color), (Color, Color))] = [
            ("inchiostro sulla carta", C.ink, C.carta),
            ("inchiostro sulla scheda", C.ink, C.scheda),
            ("inchiostro 2 sulla scheda", C.ink2, C.scheda),
            ("inchiostro 2 sul foglio", C.ink2, C.foglio),
            ("matita sulla scheda", C.matita, C.scheda),
            ("matita sul foglio", C.matita, C.foglio),
            ("rosso sulla scheda", C.rosso, C.scheda),
            ("verde sulla scheda", C.verde, C.scheda),
            ("oro delle scritte sulla scheda", C.oroTesto, C.scheda),
        ]
        for (nome, testo, fondo) in coppie {
            let g = contrasto(testo.0, fondo.0), n = contrasto(testo.1, fondo.1)
            verifica.vero("Carta: \(nome) leggibile di giorno (\(String(format: "%.2f", g)))", g >= 4.5)
            verifica.vero("Carta: \(nome) leggibile di notte (\(String(format: "%.2f", n)))", n >= 4.5)
        }
    }

    // MARK: Stile per dispositivo e caratteri

    private static func stile(_ verifica: VerificaCalcoli) {
        let senzaForzatura = ProcessInfo.processInfo.environment["PRISMA_TEMA"] == nil
        if senzaForzatura {
            verifica.vero("Carta: l'iPhone resta sul tema Apple", Tema.Stile.perDispositivo(iPad: false) == .apple)
            verifica.vero("Carta: l'iPad passa allo stile Carta", Tema.Stile.perDispositivo(iPad: true) == .carta)
            #if os(macOS)
            verifica.vero("Carta: il Mac è in stile Carta", Tema.Stile.attivo == .carta)
            #endif
        }
        let prima = Tema.Stile.attivo
        defer { Tema.Stile.attivo = prima }

        Tema.Stile.attivo = .carta
        let titolo = TemaCarta.disegno(dimensione: 21, peso: .bold, maiuscolo: false, disegno: .default)
        verifica.vero("Carta: i titoli in New York a peso medio", titolo.0 == .serif && titolo.1 == .medium)
        let etichetta = TemaCarta.disegno(dimensione: 12, peso: .semibold, maiuscolo: true, disegno: .default)
        verifica.vero("Carta: le etichette in maiuscolo in SF Mono", etichetta.0 == .monospaced)
        let corpo = TemaCarta.disegno(dimensione: 14, peso: .regular, maiuscolo: false, disegno: .default)
        verifica.vero("Carta: il testo in SF Pro", corpo.0 == .default && corpo.1 == .regular)
        let arrotondato = TemaCarta.disegno(dimensione: 26, peso: .bold, maiuscolo: false, disegno: .rounded)
        verifica.vero("Carta: un disegno scelto apposta non cambia", arrotondato.0 == .rounded)
        verifica("Carta: raggio della finestra", Double(Tema.Apple.Raggio.finestra), 14, tolleranza: 0)
        verifica("Carta: raggio dei riquadri", Double(Tema.Apple.Raggio.riquadro), 22, tolleranza: 0)

        Tema.Stile.attivo = .apple
        let titoloApple = TemaCarta.disegno(dimensione: 21, peso: .bold, maiuscolo: false, disegno: .default)
        verifica.vero("Carta: con il tema Apple i titoli restano in SF", titoloApple.0 == .default && titoloApple.1 == .bold)
        verifica("Carta: con il tema Apple il raggio della finestra resta 24", Double(Tema.Apple.Raggio.finestra), 24, tolleranza: 0)
    }

    // MARK: Memoria dei segni a mano

    private static func memoriaSegni(_ verifica: VerificaCalcoli) {
        let memoria = MemoriaSegni()
        let oggi = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 815_000_000))
        let domani = Calendar.current.date(byAdding: .day, value: 1, to: oggi)!
        verifica.vero("Carta: il segno si disegna alla prima apertura", memoria.daDisegnare("scrivania.saluto", giorno: oggi))
        verifica.vero("Carta: alla seconda apertura il segno è già al suo posto", !memoria.daDisegnare("scrivania.saluto", giorno: oggi))
        verifica.vero("Carta: un altro segno si disegna per conto suo", memoria.daDisegnare("scrivania.totale", giorno: oggi))
        verifica.vero("Carta: il giorno dopo il segno si disegna di nuovo", memoria.daDisegnare("scrivania.saluto", giorno: domani))
        memoria.svuota()
        verifica.vero("Carta: dopo «svuota» il segno si disegna di nuovo", memoria.daDisegnare("scrivania.saluto", giorno: oggi))
    }

    // MARK: Grana

    private static func grana(_ verifica: VerificaCalcoli) {
        let a = GranaCarta.generaTessera(lato: 32), b = GranaCarta.generaTessera(lato: 32)
        verifica.vero("Carta: la tessera della grana ha la misura chiesta", a.width == 32 && a.height == 32)
        verifica.vero("Carta: la grana è sempre la stessa", pixel(a) == pixel(b) && !pixel(a).isEmpty)
        verifica.vero("Carta: la tessera della scrivania è da 200", GranaCarta.tessera.width == TemaCarta.Grana.lato)
    }

    // MARK: Aiuti

    private static func pixel(_ immagine: CGImage) -> [UInt8] {
        guard let dati = immagine.dataProvider?.data as Data? else { return [] }
        return [UInt8](dati)
    }

    /// Le componenti sRGB (0-1) di un colore fisso.
    private static func rgb(_ colore: Color) -> (Double, Double, Double) {
        #if os(macOS)
        let c = NSColor(colore).usingColorSpace(.sRGB) ?? .black
        return (Double(c.redComponent), Double(c.greenComponent), Double(c.blueComponent))
        #else
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(colore).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
        #endif
    }

    private static func esadecimale(_ colore: Color) -> String {
        let (r, g, b) = rgb(colore)
        func h(_ v: Double) -> String { String(format: "%02X", Int((v * 255).rounded())) }
        return "#" + h(r) + h(g) + h(b)
    }

    private static func luminanza(_ colore: Color) -> Double {
        let (r, g, b) = rgb(colore)
        func l(_ v: Double) -> Double { v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        return 0.2126 * l(r) + 0.7152 * l(g) + 0.0722 * l(b)
    }

    private static func contrasto(_ a: Color, _ b: Color) -> Double {
        let la = luminanza(a), lb = luminanza(b)
        return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
    }
}
