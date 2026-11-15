import SwiftUI

// Il tavolo con l'iPad, lato Mac (Tavolo/TavoloMac.swift, viste in Shell/AlTavolo.swift): il pulsante «Al tavolo» con
// lo stato in Prospetti e nella sala della presentazione, il pannello dei comandi e la pagina finale della presa
// visione nel PDF. Il template non ha il tavolo: i valori vengono dai token del tema Apple (capsule, puntini di stato,
// sala sempre scura) e dalla carta dei documenti (sempre chiara, colori opachi e fissi).

extension Tema.Apple {
    enum Tavolo {
        typealias Colore = Tema.Apple.Colore
        typealias Carattere = Tema.Apple.Carattere

        /// Pixel per punto delle pagine mandate all'iPad: un A4 diventa 1190×1684, nitido sullo schermo dell'iPad.
        static let scalaPagina: CGFloat = 2

        // MARK: Lo stato (puntino nel pulsante «Al tavolo»)

        static let puntino: CGFloat = 7
        static let spazioPuntino: CGFloat = 6
        /// iPad collegato: verde; in attesa dell'iPad: arancio; tavolo chiuso: inchiostro tenue.
        static let coloreCollegato = Colore.verde
        static let coloreInAttesa = Colore.arancio
        static let coloreSpento = Colore.inchiostro3

        // MARK: Il pannello in Prospetti (popover)

        static let larghezzaPannello: CGFloat = 320
        static let paddingPannello = Tema.Apple.Misura.padding(16, 18)
        static let spazioPannello: CGFloat = 10
        static let spazioAzioni: CGFloat = 6
        static let titoloPannello = Carattere.titoloRiga
        static let coloreTitoloPannello = Colore.inchiostro
        static let statoPannello = Carattere.secondario
        static let coloreStatoPannello = Colore.inchiostro2
        static let avviso = Carattere.secondario
        static let coloreAvviso = Colore.arancioTesto
        static let codice = Carattere(dimensione: 13, peso: .semibold, tabellare: true)
        static let coloreCodice = Colore.inchiostro
        /// I limiti del cursore lasciato al cliente («da 50 a 1.000 € al mese»).
        static let larghezzaCampo: CGFloat = 72

        // MARK: Nella sala (colori fissi: la sala è sempre scura)

        /// La striscia dei comandi sopra quelli della sala, a 12 da loro.
        static let fondoStriscia = Color(r: 255, g: 255, b: 255, a: 0.08)
        static let raggioStriscia = Tema.Apple.Raggio.tile
        static let paddingStriscia = Tema.Apple.Misura.padding(10, 14)
        static let spazioStriscia: CGFloat = 8
        static let sopraComandiSala: CGFloat = 12
        static let testoStriscia = Color(r: 255, g: 255, b: 255, a: 0.70)
        static let carattereStriscia = Carattere(dimensione: 12, peso: .medium)
        /// La striscia compare dal basso con la curva `uscita` (con «Riduci movimento»: dissolvenza di 0,15 s).
        static let comparsa = Tema.Apple.Moto.uscita(0.30)
        static let spostamentoComparsa: CGFloat = 8

        // MARK: La pagina della presa visione (carta, sempre chiara)

        enum PresaVisione {
            static let margine: CGFloat = 40
            static let alto: CGFloat = 34
            static let spazio: CGFloat = 12
            static let spazioPiccolo: CGFloat = 4
            /// Il riquadro del tratto: 300×120 con il bordo `linea` della carta.
            static let tratto = CGSize(width: 300, height: 120)
            static let raggioTratto: CGFloat = 6
            static let bordoTratto: CGFloat = 0.8
            static let paddingTratto: CGFloat = 10
            static let coloreBordo = Tema.Apple.Carta.linea
            static let filetto: CGFloat = 0.6
            /// Il tratto di prova (istantanee e prove): blu scuro su trasparente, 3 pt.
            static let coloreTrattoProva = CGColor(red: 0.08, green: 0.13, blue: 0.17, alpha: 1)
            static let spessoreTrattoProva: CGFloat = 3

            /// Migliorie d'uso 58: la scheda «Presa visione» sul Mac (`.presaF` del template, CSS riga 748): il riquadro
            /// tratteggiato del tratto (bordo 1,5, trattini 6/5, inchiostro3, raggio 18, padding 10×16×12, alto 120),
            /// tratto 2,6 color inchiostro, testo sotto 13 secondario. Il tratto si fa con il mouse o il trackpad.
            enum Scheda {
                static let larghezza: CGFloat = 560
                static let raggio: CGFloat = Tema.Apple.Raggio.dettaglioAperto
                static let padding: CGFloat = 28
                static let superficie = Tema.Apple.Superficie.vetroSopra
                static let spazio: CGFloat = 12
                static let occhiello = Carattere(dimensione: 12, peso: .semibold, tracking: 0.6, maiuscolo: true)
                static let coloreOcchiello = Colore.accento
                static let titolo = Carattere(dimensione: 26, peso: .bold, tracking: -0.6)
                static let testo = Carattere(dimensione: 15, peso: .regular, interlinea: 1.4)
                static let coloreTitolo = Colore.inchiostro
                static let coloreTesto = Colore.inchiostro2
                static let bordoArea: CGFloat = 1.5
                static let trattini: [CGFloat] = [6, 5]
                static let coloreArea = Colore.inchiostro3
                static let raggioArea: CGFloat = 18
                static let paddingArea = EdgeInsets(top: 10, leading: 16, bottom: 12, trailing: 16)
                static let altezzaArea: CGFloat = 120
                static let tratto: CGFloat = 2.6
                static let coloreTratto = Colore.inchiostro
                static let sottoArea = Carattere(dimensione: 13, peso: .regular)
                static let coloreSottoArea = Colore.inchiostro2
                static let piccolo = Carattere(dimensione: 12.5, peso: .regular)
                static let sopraPulsanti: CGFloat = 8
                /// Il tratto disegnato sul Mac diventa un'immagine 2× per la pagina del PDF (inchiostro della carta).
                static let scalaTratto: CGFloat = 2
                static let inchiostroCarta = CGColor(red: 0.08, green: 0.13, blue: 0.17, alpha: 1)
            }

            /// La pagina con ciò che si vedeva (un capitolo o un palco), su carta bianca come le pagine del PDF.
            enum Pagina {
                static let formato = CGSize(width: 595, height: 842)
                static let margine: CGFloat = 48
                static let spazio: CGFloat = 16
                static let titolo = Carattere(dimensione: 20, peso: .bold, tracking: -0.3)
                static let nota = Carattere(dimensione: 9.5, peso: .regular)
                static let inchiostro = Color(hex: "#14202B")
                static let inchiostro2 = Color(hex: "#5A6873")
                static let raggioImmagine: CGFloat = 6
            }
        }
    }
}
