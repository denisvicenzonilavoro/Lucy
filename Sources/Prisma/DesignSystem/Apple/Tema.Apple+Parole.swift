#if os(macOS)
import SwiftUI

// Migliorie d'uso 66 «Le parole si spiegano dove sono» (Design/uso/gruppo-11.md §66.3 punto 8, template righe 753-755 e
// 4846-4849): il filo tratteggiato sotto le parole del mestiere e la scheda della parola. Solo valori, tutti dal tema:
// le viste stanno in DesignSystem/Apple/TestoConParoleApple.swift e DesignSystem/ComponentiGuida.swift. Solo sul Mac.

extension Tema.Apple {
    enum Parole {
        // MARK: Il filo (`.gl`)

        /// Sottolineatura a puntini color accento (il template: 1,5 punti, 3 sotto la riga; SwiftUI disegna la
        /// sottolineatura con lo spessore del carattere).
        static let filo = Text.LineStyle(pattern: .dot, color: Colore.accento)
        static let coloreFilo = Colore.accento

        // MARK: La scheda della parola (`#glP`)

        /// Larga 340, padding 14×16.
        static let schedaLarghezza: CGFloat = 340
        static let schedaMargine = EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        /// Occhiello azzurro «Le parole».
        static let occhiello = Carattere.etichetta
        static let coloreOcchiello = Colore.accento
        /// Termine 16 bold, 3 sotto l'occhiello.
        static let termine = Carattere(dimensione: 16, peso: .bold)
        static let coloreTermine = Colore.inchiostro
        static let sottoOcchiello: CGFloat = 3
        /// Definizione 14 con interlinea 1,5, 4 sotto il termine; la seconda riga (la spiegazione) in secondario.
        static let definizione = Carattere(dimensione: 14, peso: .regular, interlinea: 1.5)
        static let coloreDefinizione = Colore.inchiostro
        static let coloreSpiegazione = Colore.inchiostro2
        static let sottoTermine: CGFloat = 4
        /// «Tutte le parole ›», 10 sotto la definizione.
        static let sopraCollegamento: CGFloat = 10
        static let collegamento = Carattere(dimensione: 13, peso: .semibold)
        static let coloreCollegamento = Colore.accento
    }
}
#endif
