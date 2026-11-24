import Foundation

// I tempi dello stile Carta. Il vecchio logo a inchiostro (il prisma «Cristallo») è stato sostituito dal marchio di Lucy
// il 24 novembre 2026 (MarchioLucy.swift).

extension TemaCarta {
    /// I tempi dello stile Carta (secondi del template; si percorrono al ritmo `Tema.Apple.Moto.ritmo`).
    enum Moto {
        /// Il logo che si disegna nel blocco: triangolo 1,1 s, spigoli 0,8 s, oro 0,7 s, in tutto circa 2,1 s.
        static let logo: Double = 2.1
        /// La sottolineatura dorata (`.ann.line`).
        static let sottolineatura: Double = 0.9
        /// Il cerchio rosso (`.ann.circ`).
        static let cerchio: Double = 1.1
        /// L'evidenziatore (`[data-a=mk]`).
        static let evidenziatore: Double = 0.75
        /// Il contachilometri dei totali.
        static let contachilometri: Double = 1.4
    }
}
