import SwiftUI

// I passi in fila (Migliorie d'uso 28, `.passiF` del template, righe 627-632): cerchi da 22 con il bordo 2 uniti da un
// filo 2 `track`, il nome sotto. Fatto = bordo e spunta verdi; attuale = pieno blu con il numero bianco; futuro = bordo
// `track` con il numero. Li usa la scheda «A che punto è» delle parcelle (StudioParcelle.swift); pensati anche per le
// pratiche dopo la firma. Il componente sta in PassiApple.swift.

extension Tema.Apple {
    enum Passi {
        /// Il cerchio da 22 con il bordo 2, il filo 2 che unisce i centri.
        static let cerchio: CGFloat = 22
        static let bordo: CGFloat = 2
        static let filo: CGFloat = 2
        static let coloreFilo = Colore.binario
        /// Il numero 11 bold e la spunta 11.
        static let numero = Carattere(dimensione: 11, peso: .bold, tabellare: true)
        static let spunta = Carattere(dimensione: 11, peso: .bold)
        /// Il nome 12 semibold, 5 sotto il cerchio; la fila 12 sotto l'occhiello.
        static let nome = Carattere(dimensione: 12, peso: .semibold)
        static let spazioNome: CGFloat = 5
        static let sopra: CGFloat = 12
        /// Attuale: pieno `accento`, numero bianco, nome `inchiostro`.
        static let fondoAttuale = Colore.accento
        static let numeroAttuale = Color.white
        static let nomeAttuale = Colore.inchiostro
        /// Fatto: bordo e spunta `verde`, nome `inchiostro2`.
        static let fatto = Colore.verde
        static let nomeFatto = Colore.inchiostro2
        /// Futuro: bordo `track`, numero e nome `inchiostro3`.
        static let bordoFuturo = Colore.binario
        static let numeroFuturo = Colore.inchiostro3
        static let nomeFuturo = Colore.inchiostro3
        /// Il nome lungo si stringe fino all'80% per stare sotto il suo cerchio.
        static let riduzioneNome: CGFloat = 0.8
    }
}
