import SwiftUI

// Migliorie d'uso 37 · «La dimostrazione è un interruttore» (Design/uso/gruppo-06.md §37, template righe 651-652 e
// 4202-4227): l'etichetta «Dimostrazione» nella barra (`#bDemo`) e la scheda che si apre al clic (`apriDemo`). Le viste
// stanno in DesignSystem/Apple/ChipBarraApple.swift (EtichettaDimostrazione) e in Shell/StatoDimostrazione.swift
// (SchedaDimostrazione, la pagina di Impostazioni). Qui solo i valori, ricavati dal tema Apple.

extension Tema.Apple {
    enum Dimostrazione {
        // MARK: Etichetta nella barra

        /// Testo arancione del testo (`--orangeT`), grassetto 700, come le pillole della barra (13).
        static let testo = Colore.arancioTesto
        static let carattere = Carattere(dimensione: 13, peso: .bold)
        /// Il filo arancione al 40% (`rgba(224,138,0,.4)`), sottile come i fili del vetro.
        static let filo = Colore.arancio.opacity(0.4)
        static let spessoreFilo: CGFloat = 1
        static let padding = Tema.Apple.BarraAlta.paddingPillola
        /// L'entrata e l'uscita dell'etichetta (dissolvenza del tema).
        static var animazione: Animation { Tema.Apple.Moto.Curva.uscita.animazione(0.3) }

        // MARK: Scheda

        enum Scheda {
            static let larghezza: CGFloat = 640
            static let padding = Misura.padding(28, 32)
            static let raggio: CGFloat = Raggio.dettaglioAperto
            static let bordo: CGFloat = 40
            static let superficie = Superficie.vetroSopra
            static let velo = Colore.velo
            static let entrataY: CGFloat = 18
            static let entrataScala: CGFloat = 0.97
            static var animazione: Animation { Tema.Apple.Moto.Curva.uscita.animazione(0.48) }
            /// L'occhiello «Dimostrazione» in arancione del testo.
            static let occhiello = Carattere.etichetta
            static let coloreOcchiello = Colore.arancioTesto
            /// «Stai mostrando Prisma con i clienti di prova.» (24 grassetto).
            static let titolo = Carattere(dimensione: 24, peso: .bold, tracking: -0.4)
            static let coloreTitolo = Colore.inchiostro
            static let sopraTitolo: CGFloat = 4
            static let sottoTitolo: CGFloat = 18
            /// Le tre righe: la spunta verde (`fatto`, 18) a sinistra, titolo 14,5 grassetto e testo 13,5.
            static let spunta = Carattere(dimensione: 18, peso: .regular)
            static let coloreSpunta = Colore.verde
            static let simboloSpunta = "checkmark.circle.fill"
            static let titoloRiga = Carattere(dimensione: 14.5, peso: .bold)
            static let coloreTitoloRiga = Colore.inchiostro
            static let testoRiga = Carattere(dimensione: 13.5, peso: .regular, interlinea: 1.45)
            static let coloreTestoRiga = Colore.inchiostro2
            static let spazioSpunta: CGFloat = 12
            static let fraRighe: CGFloat = 14
            static let sottoTitoloRiga: CGFloat = 2
            /// Il ✕ in alto a destra (22 dal bordo) e i pulsanti in fondo (22 sopra, 8 fra l'uno e l'altro).
            static let chiudi: CGFloat = 22
            static let sopraPulsanti: CGFloat = 22
            static let spazioPulsanti: CGFloat = 8
        }
    }
}
