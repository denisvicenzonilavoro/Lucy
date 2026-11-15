import SwiftUI

// La capsula di stato comune (`.st2` del template delle migliorie d'uso, Design/uso/gruppo-07.md §40.3): una parola o
// due su un fondo tenue nel tono dello stato. Qui solo i valori; la vista è DesignSystem/Apple/CapsulaStatoApple.swift.
// (Tema.Apple+Capsula.swift è della capsula del tempo della Sala: nome diverso per non confonderle.)

extension Tema.Apple {
    enum CapsulaStato {
        /// 11,5 bold, padding 3×9.
        static let carattere = Carattere(dimensione: 11.5, peso: .bold)
        static let padding = Misura.padding(3, 9)

        /// Verde «ok»: testo #1F7A41 (scuro #6FD08E) su verde 0,15.
        static let testoOk = Color.dinamico(chiaro: Color(hex: "#1F7A41"), scuro: Color(hex: "#6FD08E"))
        static let fondoOk = Colore.verde.opacity(0.15)
        /// Arancio «attenzione»: il testo arancio del tema su arancio 0,16.
        static let testoAttenzione = Colore.arancioTesto
        static let fondoAttenzione = Colore.arancio.opacity(0.16)
        /// Rosso «errore»: testo #C2333A (scuro #FF8A8F) su rosso 0,13.
        static let testoErrore = Color.dinamico(chiaro: Color(hex: "#C2333A"), scuro: Color(hex: "#FF8A8F"))
        static let fondoErrore = Colore.rosso.opacity(0.13)
        /// Neutra: `inchiostro2` su `chip`.
        static let testoNeutro = Colore.inchiostro2
        static let fondoNeutro = Colore.chip
    }
}
