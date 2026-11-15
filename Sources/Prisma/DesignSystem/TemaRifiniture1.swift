import SwiftUI

// MARK: - Gettoni delle rifiniture grafiche (gruppo 1: design system, shell, scrivania, Clienti, Impostazioni)
// Valori nuovi per le correzioni d'impaginazione, ricavati dal tema Liquid Glass: nessun valore sparso nelle viste.

extension Tema.Misura.Completezza {
    /// Il testo di una voce da completare: larghezza minima e ideale. L'ideale decide se chip, canale e
    /// azioni stanno sulla stessa riga del testo o scendono sotto (`ViewThatFits`).
    static let testoVoceMinimo: CGFloat = 120
    static let testoVoceIdeale: CGFloat = 240
}

extension Tema.Misura {
    /// Misure delle rifiniture della shell.
    enum RifinitureScrivania {
        /// Widget della scrivania: altezza della sfumatura in fondo agli elenchi che scorrono.
        static let sfumaturaElenco: CGFloat = 28
        /// Impostazioni: saturazione dei controlli figli quando il genitore è spento (grigi, non verdi).
        static let saturazioneSpento: Double = 0
    }
}

extension View {
    /// Impostazioni (migliorie d'uso 31, §31.3 punto 6): le righe che dipendono da un interruttore spento si
    /// disattivano, si attenuano e perdono il colore, così non sembrano più attive. L'interruttore resta fuori.
    /// Lo stesso schema dei promemoria (ImpostazioniPagine), raccolto qui perché resti uguale ovunque.
    func attenuatoSeSpento(_ spento: Bool) -> some View {
        self
            .disabled(spento)
            .opacity(spento ? Tema.Misura.Shell.opacitaDisabilitato : 1)
            .saturation(spento ? Tema.Misura.RifinitureScrivania.saturazioneSpento : 1)
    }
}
