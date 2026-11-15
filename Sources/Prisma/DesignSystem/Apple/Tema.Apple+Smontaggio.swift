import SwiftUI

// Posizioni › Smontaggio (Design/template-luce-specifica.md §8.2.2-§8.2.3, «Luce» giro 2): misure, colori, caratteri e
// tempi del documento con i costi cerchiati e delle due card. Le viste stanno in Shell/SmontaggioApple.swift.
// Il foglio e le ellissi stanno sulla carta: colori fissi in chiaro e in scuro; la nota sta fuori dal foglio, sul
// vassoio, e nello scuro si schiarisce.

extension Tema.Apple.Posizioni {
    enum Smontaggio {
        typealias K = Tema.Apple.Carattere
        typealias C = Tema.Apple.Colore

        // MARK: Vassoio e foglio

        static let fondoVassoio = C.chip
        static let raggioVassoio = Tema.Apple.Raggio.pannello
        static let sopraVassoio: CGFloat = 14
        /// Il foglio `.paper` 600 di larghezza, scalato a 0,8.
        static let larghezzaFoglio: CGFloat = 600
        static let scalaFoglio: CGFloat = 0.8
        static let paddingFoglio = EdgeInsets(top: 44, leading: 46, bottom: 40, trailing: 46)
        static let occhiello = K(dimensione: 11, peso: .semibold, tracking: 1.4, maiuscolo: true)
        static let coloreOcchiello = Tema.Apple.Carta.piede
        static let titolo = K(dimensione: 24, peso: .bold, tracking: -0.4)
        static let sottotitolo = K(dimensione: 13, peso: .regular)
        static let etichettaValore = K(dimensione: 11, peso: .regular)
        static let valoreFoglio = K(dimensione: 20, peso: .bold, tabellare: true)
        static let riga = K(dimensione: 13, peso: .regular)
        static let valoreRiga = K(dimensione: 13, peso: .bold, tabellare: true)
        static let paddingRiga = EdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0)
        static let filoTabella: CGFloat = 2
        static let sopraTabella: CGFloat = 22
        /// Le righe finte sotto la tabella (#EEF1F4).
        static let rigaFinta = Color(hex: "#EEF1F4")
        static let righeFinte = 6
        static let altezzaRigaFinta: CGFloat = 9

        // MARK: Ellissi e note

        static let coloreCerchio = Tema.Apple.Carta.rosso
        static let spessoreCerchio: CGFloat = 2.4
        static let margineCerchio: CGFloat = 16
        static let altezzaCerchio: CGFloat = 34
        static let rotazioneCerchio: Double = -2
        static let tratteggioMancante: [CGFloat] = [5, 4]
        static let nota = K(dimensione: 12.5, peso: .medium, interlinea: 1.4)
        static let coloreNota = Color.dinamico(chiaro: Color(hex: "#D93036"), scuro: Color(hex: "#FF7A7A"))
        static let larghezzaNota: CGFloat = 190
        static let distanzaNota: CGFloat = 18
        static let tratteggioRichiamo: [CGFloat] = [3, 4]
        static let spessoreRichiamo: CGFloat = 1.4

        // MARK: Numeri e voci (migliorie d'uso 42, solo Mac)
        // Sul Mac le note ai margini non ci sono più: accanto a ogni ellisse il numero della voce, e a destra l'elenco
        // delle voci. I token delle note (`nota`, `larghezzaNota`, `distanzaNota`, richiamo) restano per l'iPad, che
        // tiene il foglio di prima finché non arriva il suo giro.

        /// Il cerchio pieno accanto all'ellisse: raggio 11, numero 12 bold bianco.
        static let raggioNumeroFoglio: CGFloat = 11
        static let numeroFoglio = K(dimensione: 12, peso: .bold, tabellare: true)
        static let coloreNumero = Tema.Apple.Carta.rosso
        static let testoNumero = Color.white
        /// Lo spazio fra l'ellisse e il suo numero, e quello lasciato a destra del foglio per i numeri.
        static let spazioNumero: CGFloat = 6
        static let margineNumeri: CGFloat = 34
        /// Il numero nell'elenco: cerchio 22.
        static let numeroElenco: CGFloat = 22
        static let carattereNumeroElenco = K(dimensione: 11.5, peso: .bold, tabellare: true)
        /// Le righe dell'elenco partono attenuate e si accendono con la loro ellisse.
        static let opacitaSpenta = 0.4
        /// Voce accesa (puntatore sulla riga o sull'ellisse): riga con il fondo rosso 0,09 e raggio 10, ellisse con il
        /// tratto 3,6 e il fondo rosso 0,10.
        static let fondoVoceAccesa = C.rosso.opacity(0.09)
        static let raggioVoce: CGFloat = 10
        static let fondoEllisseAccesa = Tema.Apple.Carta.rosso.opacity(0.10)
        static let tratteggioAcceso: CGFloat = 3.6
        static let paddingVoce = EdgeInsets(top: 9, leading: 10, bottom: 9, trailing: 10)
        static let spazioVoce: CGFloat = 12
        static let nomeVoce = K(dimensione: 13.5, peso: .semibold)
        static let cifraVoce = K(dimensione: 13.5, peso: .bold, tabellare: true)
        static let dettaglioVoce = K(dimensione: 12, peso: .regular, interlinea: 1.35)
        /// La card del documento: padding 16×20, avatar 38, cifre da 28 su una riga.
        static let paddingDocumento = EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        static let avatarDocumento: CGFloat = 38
        static let cifraRiga = K(dimensione: 28, peso: .bold, tracking: -0.6, tabellare: true)
        static let cifraDieciAnni = K(dimensione: 22, peso: .bold, tracking: -0.4, tabellare: true)
        static let titoloDocumento = K(dimensione: 15.5, peso: .bold)
        /// Il grafico piccolo della card in basso.
        static let graficoPiccolo = CGSize(width: 186, height: 60)
        /// Il vuoto del cliente senza documenti smontati: avatar 58, titolo 23 bold.
        static let avatarVuoto: CGFloat = 58
        static let titoloVuoto = K(dimensione: 23, peso: .bold, tracking: -0.4)
        static let larghezzaVuoto: CGFloat = 440

        // MARK: Card

        static let larghezzaColonna: CGFloat = 520
        static let colonnaMinima: CGFloat = 360
        static let spazio: CGFloat = 18
        static let padding = Tema.Apple.Misura.Padding.cardMedia
        static let titoloCard = K(dimensione: 16, peso: .bold)
        static let cifra = Tema.Apple.Carattere.valore
        static let spazioCifre: CGFloat = 24
        static let guadagno = Tema.Apple.Carattere.valoreCursoreAnalisi
        static let grafico = CGSize(width: 470, height: 170)
        static let lineaOggi = C.rosso
        static let lineaConTe = C.Area.liquidita
        static let spessoreOggi: CGFloat = 2.6
        static let spessoreConTe: CGFloat = 2.8
        static let opacitaArea = 0.14
        static let etichettaLinea = K(dimensione: 11.5, peso: .bold)
        /// Sotto questa larghezza la colonna va sotto il documento.
        static let sogliaAffiancati: CGFloat = 900

        // MARK: Movimento (§8.2.3)

        enum Moto {
            /// Le ellissi una alla volta: partenza 0,50 + i·0,65 s, il tratto in 0,70 s con (.4, 0, .2, 1); oltre 6 voci
            /// il passo si accorcia perché tutto finisca entro 4 s.
            static let durata = 0.70
            static let ritardo = 0.50
            static let passo = 0.65
            static let passoCorto = 0.15
            static let curva = Tema.Apple.Moto.Curva(x1: 0.4, y1: 0, x2: 0.2, y2: 1)
            static func partenza(_ i: Int) -> Double { ritardo + passo * Double(min(i, 5)) + passoCorto * Double(max(0, i - 5)) }
            static var animazione: Animation { curva.animazione(durata) }
            /// La nota 0,40 s dopo la sua ellisse, da 6 più in basso, in 0,50 s.
            static let ritardoNota = 0.40
            static let durataNota = 0.50
            static let spostamentoNota: CGFloat = 6
            static let baseCascata = Tema.Apple.Moto.Cascata.baseDentroApp
            /// La riga dell'elenco passa da 0,4 a 1 in 0,5 s quando la sua ellisse comincia a disegnarsi.
            static let durataAccensione = 0.50
        }
    }
}
