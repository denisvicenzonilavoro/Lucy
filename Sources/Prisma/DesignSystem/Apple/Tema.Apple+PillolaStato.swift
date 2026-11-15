import SwiftUI

// La pillola di stato del tema Apple (migliorie d'uso 55): una capsula con un testo qualsiasi in quattro toni, ok,
// errore, avviso e neutro. I colori sono quelli della pillola dell'esito del track record (Orizzonte giro 2, §4.2.1),
// spostati qui perché li usino anche il bilancio del quiz OCF e, con la 56, la palestra. Uguali in chiaro e in scuro.
// La vista sta in DesignSystem/Apple/PillolaStatoApple.swift.

extension Tema.Apple {
    enum PillolaStato {
        /// Capsula, 12 bold, padding 4×10.
        static let carattere = Tema.Apple.Carattere(dimensione: 12, peso: .bold)
        static let padding = Tema.Apple.Misura.padding(4, 10)
        /// Ok: verde su verde al 13%; errore: rosso su rosso al 12%; avviso: arancio su arancio al 13%;
        /// neutro: `inchiostro2` su `inchiostro3` al 14%.
        static let testoOk = Tema.Apple.Colore.verde
        static let fondoOk = Color(r: 47, g: 163, b: 90, a: 0.13)
        static let testoErrore = Tema.Apple.Colore.rosso
        static let fondoErrore = Color(r: 229, g: 72, b: 77, a: 0.12)
        static let testoAvviso = Tema.Apple.Colore.arancioTesto
        static let fondoAvviso = Color(r: 224, g: 138, b: 0, a: 0.13)
        static let testoNeutro = Tema.Apple.Colore.inchiostro2
        static let fondoNeutro = Tema.Apple.Colore.inchiostro3.opacity(0.14)
    }
}
