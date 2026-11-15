import SwiftUI

// Migliorie d'uso 68 «Quello che Prisma prepara da solo si conferma allo stesso modo» (Design/uso/gruppo-11.md §68.3
// punto 2, template righe 782-784 e 4961-4975): la regola delle conferme. Il verde è pronto, l'arancione chiede una
// risposta, ogni cosa si annulla, un pulsante solo chiude e non è blu finché resta dell'arancione. Solo valori, tutti dal
// tema: le viste stanno in DesignSystem/Apple/ConfermeApple.swift. Le didascalie di Stanotte stanno accanto ai comandi
// della notte (`Tema.Apple.Notte.Comandi`).

extension Tema.Apple {
    enum Conferme {
        // MARK: La riga

        /// La riga da decidere (`.vnDub`): arancio del tema al 12%, raggio 10.
        static let fondoDubbio = Colore.arancio.opacity(0.12)
        /// Le righe fatte, decise o annullate: il fondo chip, come le voci della nota.
        static let fondoRiga = Colore.chip
        static let raggioRiga: CGFloat = 10
        static let paddingRiga = Misura.padding(10, 14)
        /// Spazio fra le righe di un elenco di conferme.
        static let spazioRighe: CGFloat = 8
        /// Spazio fra segno, contenuto e azioni (il template: gap 10).
        static let spazio: CGFloat = 10
        static let spazioAzioni: CGFloat = 6
        /// Il segno a sinistra: 14 bold, largo 14.
        static let segno = Carattere(dimensione: 14, peso: .bold)
        static let larghezzaSegno: CGFloat = 14
        static let coloreFatta = Colore.verde
        static let coloreDubbio = Colore.arancioTesto
        static let coloreAnnullata = Colore.inchiostro3
        /// Una riga annullata resta, sbiadita.
        static let opacitaAnnullata: Double = 0.45

        // MARK: Il collegamento «Annulla» / «Rimetti»

        static let collegamento = Carattere(dimensione: 12.5, peso: .semibold)
        static let coloreCollegamento = Colore.accento

        // MARK: Il piede (pulsante solo e frase che conta)

        static let spazioPiede: CGFloat = 10
        static let sopraPiede: CGFloat = 14
        static let frasePiede = Carattere.secondario
        static let coloreFrasePiede = Colore.inchiostro2

        // MARK: La scossa della riga in arancione

        /// 0 → −6 → +6 → 0 in 0,3 s, al ritmo del tema (come il tremolio dell'OCF); niente con «Riduci movimento» e
        /// nelle istantanee.
        static let scossa: CGFloat = 6
        static let durataScossa = 0.3
        /// Un'oscillazione intera per ogni scossa.
        static let volteScossa: CGFloat = 1
        static var animazioneScossa: Animation { .linear(duration: durataScossa * Tema.Apple.Moto.ritmo) }
    }
}
