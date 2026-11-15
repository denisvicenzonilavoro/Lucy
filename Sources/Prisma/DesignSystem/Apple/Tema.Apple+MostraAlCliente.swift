#if os(macOS)
import SwiftUI

// Migliorie d'uso 1 «Mostra al cliente» (Design/uso/gruppo-01.md §1.3, template righe 499-532, 853, 3278-3349): la
// pillola della barra, il pannello di scelta, la vista pulita con i capitoli, le schede delle parole e delle ipotesi, il
// menu dell'avatar e la schermata neutra. Solo valori: le viste stanno in Shell/MostraAlCliente.swift,
// Shell/PannelloMostraAlCliente.swift e Shell/VistaCliente.swift. Solo sul Mac.

extension Tema.Apple {
    enum MostraAlCliente {
        // MARK: La pillola della barra (#bMostra)

        enum Pillola {
            static let glifo = Carattere(dimensione: 12, peso: .semibold)
            static let spazio: CGFloat = 6
        }

        // MARK: Il pannello di scelta (apriMostra)

        enum Pannello {
            /// Scheda di vetro larga 640 al centro, raggio 28, padding 26; entra dal basso (18 pt, scala 0,97).
            static let larghezza: CGFloat = 640
            static let raggio: CGFloat = Raggio.dettaglioAperto
            static let padding: CGFloat = 26
            static let bordo: CGFloat = 40
            static let superficie = Superficie.vetroSopra
            static let velo = Colore.velo
            static let entrataY: CGFloat = 18
            static let entrataScala: CGFloat = 0.97
            static var animazione: Animation { Moto.Curva.uscita.animazione(0.48) }
            /// Testata: avatar 46, occhiello azzurro, titolo 26.
            static let avatar: CGFloat = 46
            static let occhiello = Carattere(dimensione: 12, peso: .semibold, tracking: 0.6, maiuscolo: true)
            static let coloreOcchiello = Colore.accento
            static let titolo = Carattere(dimensione: 26, peso: .bold, tracking: -0.6)
            static let testo = Carattere(dimensione: 14, peso: .regular)
            static let coloreTitolo = Colore.inchiostro
            static let coloreTesto = Colore.inchiostro2
            static let spazioTestata: CGFloat = 14
            static let sottoTestata: CGFloat = 18
            /// La chiusura ✕ in alto a destra: cerchio 28 su `chip`.
            static let chiudi: CGFloat = 28
            static let glifoChiudi = Carattere(dimensione: 12, peso: .bold)
            static let fondoChiudi = Colore.chip
            /// Le quattro righe (`.scl`): fondo `card`, filo, raggio 20, padding 14×16; quadrato 48 raggio 16, fondo
            /// accento al 12%; titolo 16, testo 13,5 secondario; al passaggio sale di 2.
            static let fondoRiga = Colore.card
            static let filoRiga = Colore.separatore
            static let raggioRiga: CGFloat = Raggio.pannello
            static let paddingRiga = EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            static let spazioRighe: CGFloat = 10
            static let spazioRiga: CGFloat = 14
            static let quadrato: CGFloat = 48
            static let raggioQuadrato: CGFloat = 16
            static let fondoQuadrato = Colore.accento.opacity(0.12)
            static let glifoRiga = Carattere(dimensione: 20, peso: .semibold)
            static let coloreGlifo = Colore.accento
            static let titoloRiga = Carattere(dimensione: 16, peso: .semibold)
            static let testoRiga = Carattere(dimensione: 13.5, peso: .regular)
            static let freccia = Carattere(dimensione: 14, peso: .semibold)
            static let coloreFreccia = Colore.inchiostro3
            static let salitaPassaggio: CGFloat = 2
            /// La riga leggera della schermata neutra.
            static let neutra = Carattere(dimensione: 13.5, peso: .medium)
            static let coloreNeutra = Colore.inchiostro2
            static let sopraNeutra: CGFloat = 14
            /// L'elenco dei clienti (senza cliente scelto): avatar 38, nome 15 semibold, motto 12,5.
            static let avatarElenco: CGFloat = 38
            static let nomeElenco = Carattere(dimensione: 15, peso: .semibold)
            static let mottoElenco = Carattere(dimensione: 12.5, peso: .regular)
            static let paddingElenco = EdgeInsets(top: 7, leading: 8, bottom: 7, trailing: 8)
            static let raggioElenco: CGFloat = Raggio.voce
            static let sopraElenco = Colore.chip
            static let altezzaMassimaElenco: CGFloat = 420
        }

        // MARK: La vista pulita (#pul)

        enum Vista {
            /// Il contenuto fra la barra (34 sotto) e la barra dei capitoli (82 sopra il fondo), padding 26×64.
            static let dallAlto: CGFloat = 34
            static let dalBasso: CGFloat = 82
            static let margini = EdgeInsets(top: 26, leading: 64, bottom: 26, trailing: 64)
            static let larghezzaMassima: CGFloat = 1240
            /// Testo almeno «Grande» delle Impostazioni.
            static let scalaMinima: CGFloat = 1.12
            static let coloreAcqua = Colore.inchiostroAcqua
            static let coloreAcqua2 = Colore.inchiostroAcqua2
            /// Titolo 46 bold tracking −1,5, sottotitolo 19.
            static let titolo = Carattere(dimensione: 46, peso: .bold, tracking: -1.5)
            static let sottotitolo = Carattere(dimensione: 19, peso: .regular)
            static let sottoTitolo: CGFloat = 6
            static let sottoTestata: CGFloat = 26
            /// I riquadri di vetro: raggio 30, padding 26×30, spazio 16.
            static let superficie = Superficie.vetro
            static let raggio: CGFloat = 30
            static let padding = EdgeInsets(top: 26, leading: 30, bottom: 26, trailing: 30)
            static let spazio: CGFloat = 16
            static let colore = Colore.inchiostro
            static let colore2 = Colore.inchiostro2
            /// Il quadro: griglia 2×2 alta 548, anello 156/16, occhiello 13, frase 29 bold, seconda 17,5.
            static let altezzaQuadro: CGFloat = 548
            static let anelloQuadro: CGFloat = 156
            static let spessoreQuadro: CGFloat = 16
            static let cifraQuadro = Carattere(dimensione: 34, peso: .bold, tracking: -1, tabellare: true)
            static let cifraMesi = Carattere(dimensione: 24, peso: .bold, tracking: -0.6, tabellare: true)
            static let occhiello = Carattere(dimensione: 13, peso: .semibold, tracking: 1, maiuscolo: true)
            static let frase = Carattere(dimensione: 29, peso: .bold, tracking: -0.7, interlinea: 1.18)
            static let testo = Carattere(dimensione: 17.5, peso: .regular, interlinea: 1.4)
            static let spazioArea: CGFloat = 26
            static let sopraFrase: CGFloat = 8
            static let sopraTesto: CGFloat = 10
            /// Le posizioni: cifra grande 78, righe alte almeno 60 (18 pt), quadratino dell'area 12.
            static let cifraGrande = Carattere(dimensione: 78, peso: .bold, tracking: -3, tabellare: true)
            static let etichetta = Carattere(dimensione: 15, peso: .semibold, tracking: 0.8, maiuscolo: true)
            static let rigaPosizione: CGFloat = 60
            static let nomePosizione = Carattere(dimensione: 18, peso: .semibold)
            static let areaPosizione = Carattere(dimensione: 14, peso: .regular)
            static let importo = Carattere(dimensione: 18, peso: .semibold, tabellare: true)
            static let quadratino: CGFloat = 12
            static let raggioQuadratino: CGFloat = 4
            static let legenda = Carattere(dimensione: 15, peso: .regular, tabellare: true)
            static let larghezzaSinistra: CGFloat = 440
            static let spazioRighe: CGFloat = 4
            static let spazioLegenda: CGFloat = 8
            static let debito = Colore.rosso
            static func area(_ a: AreaPosizione) -> Color { Colori.Analisi.area(a) }
            /// Gli obiettivi: anello 200/20, nome 22 bold, testi 16.
            static let anelloObiettivo: CGFloat = 200
            static let spessoreObiettivo: CGFloat = 20
            static let cifraObiettivo = Carattere(dimensione: 40, peso: .bold, tracking: -1.2, tabellare: true)
            static let nomeObiettivo = Carattere(dimensione: 22, peso: .bold, tracking: -0.4)
            static let testoObiettivo = Carattere(dimensione: 16, peso: .regular, tabellare: true)
            static let coloreObiettivo = Colore.anello1
            static let larghezzaObiettivo: CGFloat = 300
            /// Nel tempo: cifre 44 (tracking −1,6), grafico alto 250, linea del totale 3,4 con l'area dal 18%, le
            /// proposte viola tratteggiate (3, trattini 7/8), asse 14, etichette 15.
            static let cifraTempo = Carattere(dimensione: 44, peso: .bold, tracking: -1.6, tabellare: true)
            static let altezzaGrafico: CGFloat = 250
            static let coloreTotale = Colore.totale
            static let spessoreTotale: CGFloat = 3.4
            static let opacitaArea: Double = 0.18
            static let coloreProposte = Colore.stima
            static let spessoreProposte: CGFloat = 3
            static let tratteggioProposte: [CGFloat] = [7, 8]
            static let asse = Carattere(dimensione: 14, peso: .regular, tabellare: true)
            static let etichettaAsse = Carattere(dimensione: 15, peso: .regular)
            static let larghezzaAsse: CGFloat = 70
            /// Il piede: «ⓘ Come sono calcolate queste cifre» e le parole, 15 semibold `wallInk2`.
            static let piede = Carattere(dimensione: 15, peso: .semibold)
            static let sopraPiede: CGFloat = 22
            static let spazioPiede: CGFloat = 18
        }

        // MARK: La barra dei capitoli (#capitoli)

        enum Capitoli {
            /// Capsula di vetro, padding 5, spazio 2; voce alta 46, padding 0×24, 15,5 semibold; la scelta su `cardE`.
            static let padding: CGFloat = 5
            static let spazio: CGFloat = 2
            static let altezza: CGFloat = 46
            static let paddingVoce: CGFloat = 24
            static let voce = Carattere(dimensione: 15.5, peso: .semibold)
            static let colore = Colore.inchiostroAcqua2
            static let coloreScelta = Colore.inchiostro
            static let fondoScelta = Colore.cardPiena
            static let ombraScelta = Color.black.opacity(0.10)
            static let raggioOmbra: CGFloat = 6
            static let yOmbra: CGFloat = 2
            static let dalBasso: CGFloat = 18
            static let superficie = Superficie.vetro
        }

        // MARK: L'uscita (avatar e menu)

        enum Uscita {
            /// L'anello bianco al 55% da 3 attorno all'avatar «DV».
            static let anello = Color.white.opacity(0.55)
            static let spessore: CGFloat = 3
            /// Il menu sotto l'avatar: largo 260, raggio 18, righe 14 con il glifo.
            static let larghezza: CGFloat = 260
            static let raggio: CGFloat = Raggio.tile
            static let padding: CGFloat = 6
            static let paddingRiga = EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12)
            static let raggioRiga: CGFloat = 12
            static let riga = Carattere(dimensione: 14, peso: .medium)
            static let tasto = Carattere(dimensione: 12.5, peso: .medium, tabellare: true)
            static let coloreRiga = Colore.inchiostro
            static let coloreTasto = Colore.inchiostro3
            static let sopra = Colore.chip
            static let superficie = Superficie.vetroSopra
            static let dallAlto: CGFloat = 6
        }

        // MARK: Le schede «Le parole» e «Le ipotesi»

        enum Scheda {
            /// Larga 560, raggio 28, padding 32; occhiello azzurro, titolo 30, spiegazione 19, «Ho capito».
            static let larghezza: CGFloat = 560
            static let raggio: CGFloat = Raggio.dettaglioAperto
            static let padding: CGFloat = 32
            static let superficie = Superficie.vetroSopra
            static let titolo = Carattere(dimensione: 30, peso: .bold, tracking: -0.8)
            static let testo = Carattere(dimensione: 19, peso: .regular, interlinea: 1.45)
            static let spazio: CGFloat = 14
            static let sopraPulsante: CGFloat = 10
        }

        // MARK: Le parole toccabili

        enum Parola {
            /// Sottolineatura a puntini da 2, a 5 dal testo.
            static let spessore: CGFloat = 2
            static let trattino: [CGFloat] = [2, 3]
            static let distanza: CGFloat = 5
        }

        // MARK: L'etichetta del luogo (migliorie d'uso 58, `#bTav`)

        enum Luogo {
            /// Pillola di vetro come le altre della barra: glifo 14, testo 13 semibold, freccina 11 al 60%.
            static let carattere = Carattere(dimensione: 13, peso: .semibold)
            static let glifo = Carattere(dimensione: 14, peso: .regular)
            static let freccia = Carattere(dimensione: 11, peso: .semibold)
            static let opacitaFreccia: Double = 0.6
            static let spazio: CGFloat = 6
            /// Il menu sotto la pillola, 8 più in basso, allineato al suo bordo destro (la pillola sta subito prima
            /// dell'avatar): largo 300, come il menu dell'avatar.
            static let dallAlto: CGFloat = 8
            static let larghezza: CGFloat = 300
            static var rientroMenu: CGFloat { BarraAlta.margineDestro + BarraAlta.tasto + BarraAlta.spazio }
            static let filo = Colore.separatore
            static let paddingFilo = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
            static let opacitaSpenta: Double = 0.5
            /// La riga di conferma delle cifre dei capitoli: sotto la barra, al centro.
            static let sottoBarraConferma: CGFloat = 14
            /// L'iPad segue la vista dopo che il capitolo si è fermato (le entrate a cascata), mai durante.
            static let attesaSegui: Double = 0.6
        }

        // MARK: La schermata neutra

        enum Neutra {
            /// Logo 104 (#0F2433 in chiaro, bianco in scuro) e «Tocca per riprendere» 15 semibold.
            static let logo: CGFloat = 104
            static let coloreLogo = Colore.logo
            static let testo = Carattere(dimensione: 15, peso: .semibold)
            static let coloreTesto = Colore.inchiostroAcqua2
            static let spazio: CGFloat = 22
        }
    }
}
#endif
