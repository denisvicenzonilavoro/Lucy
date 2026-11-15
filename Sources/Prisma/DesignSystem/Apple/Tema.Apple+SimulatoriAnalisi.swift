import SwiftUI

// Gettoni dei simulatori dal vivo di Previdenza e Protezione di Analisi 360 (Design/template-apple-specifica.md
// §4.3.2, §4.3.3; riferimenti analisi-agenda A06-A16): il dettaglio 940×540 nato dall'area, con `.lbl` nel colore
// dell'area e il titolo 28, l'anello 210/20 con la percentuale 42, le cifre `.k`/`.v`, il versamento (o il
// capitale) 44 bold nel colore con il cursore, i risultati, le ipotesi scritte sotto e il piede. Le viste stanno in
// Shell/SimulatorePrevidenzaApple.swift e Shell/SimulatoreProtezioneApple.swift; i calcoli in
// Motori/MotoreSimulatoriAnalisi.swift.

extension Tema.Apple {
    enum SimulatoriAnalisi {
        /// Previdenza 940×560 sul Mac (940×540 su iPhone e iPad), Protezione 940×540.
        static let misuraPrevidenza = Tema.Apple.Misura.DettaglioAperto.previdenza
        static let misuraProtezione = Tema.Apple.Misura.DettaglioAperto.protezione

        // MARK: Testata: `.lbl` nel colore e titolo 28 bold (−0,6)

        static let etichetta = Tema.Apple.Carattere.etichetta
        static let titolo = Tema.Apple.Carattere.titoloDettaglio(28)
        static let coloreTitolo = Tema.Apple.Colore.inchiostro
        static let spazioTestata: CGFloat = 2
        /// Lo spazio del ✕ del dettaglio, in alto a destra.
        static let margineChiudi: CGFloat = Tema.Apple.Misura.Padding.chiudiDettaglio * 2

        // MARK: Corpo: anello e colonna a 34, a 20 sotto il titolo

        // Sul Mac (migliorie d'uso 45) il corpo sale a 14 e l'anello scende a 190/19 con la percentuale 40, per fare
        // posto alla frase prima e dopo e alle ipotesi da scegliere; iPhone e iPad restano come prima.
        #if os(macOS)
        static let sopraCorpo: CGFloat = 14
        static let anello: CGFloat = 190
        static let spessoreAnello: CGFloat = 19
        static let centroAnello = Tema.Apple.Carattere.centroAnello(40)
        #else
        static let sopraCorpo: CGFloat = 20
        static let anello: CGFloat = 210
        static let spessoreAnello: CGFloat = 20
        static let centroAnello = Tema.Apple.Carattere.centroAnello(42)
        #endif
        static let spazioAnello: CGFloat = 34
        static let coloreCentro = Tema.Apple.Colore.inchiostro
        /// «del divario», «protetto» sotto la percentuale (`.k`).
        static let sottoCentro = Tema.Apple.Carattere.secondario
        static let coloreSottoCentro = Tema.Apple.Colore.inchiostro2

        // MARK: Cifre (`.k` 12,5 e `.v` 26 bold) a 30 l'una dall'altra

        static let spazioCifre: CGFloat = 30
        static let spazioEtichettaValore: CGFloat = 2
        static let etichettaCifra = Tema.Apple.Carattere.secondario
        static let coloreEtichetta = Tema.Apple.Colore.inchiostro2
        static let valoreCifra = Tema.Apple.Carattere.valore
        static let coloreValore = Tema.Apple.Colore.inchiostro
        /// Il risparmio fiscale (verde).
        static let colorePositivo = Tema.Apple.Colore.verde
        /// Una cifra che non si può calcolare dai dati.
        static let senzaValore = "—"

        /// «stima» accanto a un'etichetta: capsula viola chiara (il colore delle stime del tema).
        static let testoStima = Tema.Apple.Carattere(dimensione: 10.5, peso: .semibold)
        static let coloreStima = Tema.Apple.Colore.stima
        static let fondoStima = Tema.Apple.Colore.stima.opacity(0.12)
        static let paddingStima = Tema.Apple.Misura.padding(1, 7)
        static let spazioStima: CGFloat = 6

        // MARK: Cursore: etichetta 14 a 20, valore 44 bold nel colore, binario a 8

        static let etichettaCursore = Tema.Apple.Carattere(dimensione: 14, peso: .regular)
        #if os(macOS)
        static let sopraCursore: CGFloat = 14
        /// Il valore del cursore 40 bold (−1,4): un carattere proprio, quello da 44 serve anche alla Sala dei giochi.
        static let valoreCursore = Tema.Apple.Carattere(dimensione: 40, peso: .bold, tracking: -1.4, tabellare: true)
        #else
        static let sopraCursore: CGFloat = 20
        static let valoreCursore = Tema.Apple.Carattere.valoreCursoreAnalisi
        #endif
        static let larghezzaCursore: CGFloat = 460
        static let spazioEtichettaCursore: CGFloat = 2
        static let margineCursore: CGFloat = 8
        /// I risultati a 8 sotto il cursore.
        static let sopraRisultati: CGFloat = 8

        // MARK: Migliorie d'uso 45 (solo Mac): lo scarto, il segno «oggi», la frase, le ipotesi da scegliere, l'avviso

        /// «+150 € al mese rispetto a oggi» a destra del valore (`#pDelta`: 13,5, `inchiostro2`, 6 sopra il fondo).
        static let scarto = Tema.Apple.Carattere(dimensione: 13.5, peso: .regular)
        static let coloreScarto = Tema.Apple.Colore.inchiostro2
        static let scartoSopraFondo: CGFloat = 6
        static let spazioScarto: CGFloat = 12
        /// Fra il valore scritto e il binario.
        static let sottoValoreCursore: CGFloat = 4
        /// Il segno «oggi» sotto il binario (`.simOggi`): tacca 2×6 `inchiostro3`, la parola 11 semibold `inchiostro2`,
        /// nella posizione del valore di partenza corretta per metà manopola.
        static let segnoOggiTacca = CGSize(width: 2, height: 6)
        static let segnoOggiRaggioTacca: CGFloat = 1
        static let segnoOggiSotto: CGFloat = 22
        static let segnoOggiSpazio: CGFloat = 1
        static let segnoOggiCarattere = Tema.Apple.Carattere(dimensione: 11, peso: .semibold)
        static let coloreSegnoOggi = Tema.Apple.Colore.inchiostro2
        static let coloreTaccaOggi = Tema.Apple.Colore.inchiostro3
        static let manopolaCursore = Tema.Apple.Misura.Controllo.manopolaCursore
        /// La frase prima e dopo (`.simFr`): tile a tutta larghezza, 14,5 con interlinea 1,5, margini 12×16.
        static let frase = Tema.Apple.Carattere.corpoGrande
        static let coloreFrase = Tema.Apple.Colore.inchiostro
        static let paddingFrase = Tema.Apple.Misura.padding(12, 16)
        static let superficieFrase = Tema.Apple.Superficie.tile
        static let righeFrase = 3
        static let sopraFrase: CGFloat = 14
        /// «LE IPOTESI» e i segmentati piccoli, a 10 sotto la frase e 10 fra le voci.
        static let sopraScelte: CGFloat = 10
        static let spazioScelte: CGFloat = 10
        static let spazioGruppoScelte: CGFloat = 6
        static let etichettaScelte = Tema.Apple.Carattere.etichetta
        static let testoScelte = Tema.Apple.Carattere.secondario
        static let coloreScelte = Tema.Apple.Colore.inchiostro2
        static let riduzioneScelte: CGFloat = 0.8
        /// «Sono stime, non garanzie.» accanto ai pulsanti, a 10 dopo «Chiedi a Vera».
        static let avviso = Tema.Apple.Carattere.secondario
        static let coloreAvviso = Tema.Apple.Colore.inchiostro2
        static let spazioAvviso: CGFloat = 2

        // MARK: Ipotesi (sempre scritte sotto i risultati) e piede

        static let ipotesi = Tema.Apple.Carattere.secondario
        static let coloreIpotesi = Tema.Apple.Colore.inchiostro2
        static let righeIpotesi = 4
        static let sopraIpotesi: CGFloat = 16
        static let sopraPiede: CGFloat = 12
        static let spazioPiede: CGFloat = 8
        /// Fra i pulsanti e la scelta del canale della proposta.
        static let spazioCanale: CGFloat = 8
        /// «Chiedi a Vera di spiegarlo»: la domanda parte 0,7 s dopo l'apertura di Vera.
        static let ritardoDomandaVera = Tema.Apple.Moto.DomandaDaScrivania.ritardo

        // MARK: Le due aree

        enum Previdenza {
            static let colore = Tema.Apple.Colore.Area.previdenza
            /// Il cursore del versamento: da 0 a max(900; versamento per tutto il divario·1,2 arrotondato a 50;
            /// versamento di oggi), passo 10 (§4.9.9).
            static let passo: Double = 10
            static let massimoMinimo: Double = 900
            static let margineFabbisogno: Double = 1.2
            static let arrotondamento: Double = 50
        }

        enum Protezione {
            static let colore = Tema.Apple.Colore.Area.protezione
            /// Il cursore del capitale: da 0 a max(100.000; fabbisogno·1,1 arrotondato a 10.000), passo 10.000.
            static let passo: Double = 10_000
            static let massimoMinimo: Double = 100_000
            static let margineFabbisogno: Double = 1.1
        }
    }
}
