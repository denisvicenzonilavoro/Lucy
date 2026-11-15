import SwiftUI

// La Sala della versione «Luce» (Design/template-luce-specifica.md §1.3.2, §1.3.3): griglia delle 11 esperienze, palco
// e presentazione sulla sala opaca. Il nome non è `Tema.Apple.Sala` perché `Tema.Apple.Prospetti.Sala` e
// `Tema.Apple.Moto.Sala` esistono già (la sala della presentazione dei Prospetti). Misure in pt del palco 1440×900.

extension Tema.Apple {
    enum SalaEsperienze {
        typealias C = Tema.Apple.Carattere

        /// Griglia `1.35fr repeat(5,1fr)`, due righe uguali, spazio 12.
        enum Griglia {
            static let quotaPrima: CGFloat = 1.35
            static let colonne = 5
            static let righe = 2
            static let spazio: CGFloat = 12
        }

        /// Le schede: `.card` raggio 22, padding 24 (grande) e 16 (piccole), contenuto ritagliato.
        enum Scheda {
            static let superficie = Tema.Apple.Superficie.card
            static let raggio = Tema.Apple.Raggio.card
            static let paddingGrande: CGFloat = 24
            static let paddingPiccola: CGFloat = 16
            /// Tasselli: 60 (grande) e 44 (piccole), raggio 14 fisso.
            static let tasselloGrande = Tema.Apple.Tassello.latoSalaGrande
            static let tassello = Tema.Apple.Tassello.latoSala
            static let raggioTassello = Tema.Apple.Raggio.voce
            /// «Ciao Giulia.» 38 bold, 26 sotto il tassello; sotto «Il tuo piano, sempre con te.» 14 grigio.
            static let saluto = C.saluto
            static let sottoTassello: CGFloat = 26
            static let sottotitolo = C.corpo
            /// Gli anelli dei primi tre obiettivi: 70, tratto 8, 10 fra uno e l'altro; etichetta 11 larga al più 76.
            static let anello: CGFloat = 70
            static let trattoAnello: CGFloat = 8
            static let spazioAnelli: CGFloat = 10
            static let sopraAnelli: CGFloat = 18
            static let etichettaAnello = C(dimensione: 11, peso: .regular)
            static let larghezzaEtichetta: CGFloat = 76
            static let sopraEtichetta: CGFloat = 4
            static let centroAnello = C(dimensione: 15, peso: .bold, tabellare: true)
            static let massimoAnelli = 3
            /// I colori degli anelli, nell'ordine degli obiettivi.
            static let coloriAnelli = [Tema.Apple.Colore.anello1, Tema.Apple.Colore.anello2, Tema.Apple.Colore.anello3]
            /// Titolo 26 (grande) / 17 (piccole) bold, −0,3, interlinea 1,2; frase 14 / 12,5 grigia a 4.
            static let titoloGrande = C(dimensione: 26, peso: .bold, tracking: -0.3, interlinea: 1.2)
            static let titolo = C(dimensione: 17, peso: .bold, tracking: -0.3, interlinea: 1.2)
            static let fraseGrande = C.corpo
            static let frase = C.secondario
            static let sopraFrase: CGFloat = 4
            static let righeFrase = 2
            /// Le schede spente (nessun cliente in archivio).
            static let opacitaSpenta: Double = 0.55
        }

        /// Migliorie d'uso 34 «Le esperienze della Sala, al momento giusto»: in alto a destra di ogni scheda il momento
        /// e la durata (`.saMom`: 11 semibold `inchiostro2` su `chip`, capsula, padding 3×9, a 16 dall'alto e 14 da
        /// destra); sotto il tassello delle consigliate l'etichetta verde «Consigliata per …» (`.st2.ok`: 11,5 bold,
        /// padding 3×9, a 72 dall'alto e 16 da sinistra); il filtro attenua le altre schede a 0,26 in 0,35 s.
        /// Solo sul Mac: iPhone e iPad tengono la griglia di prima fino al loro aggiornamento.
        enum Momento {
            #if os(macOS)
            static let ammesso = true
            #else
            static let ammesso = false
            #endif
            static let carattere = C(dimensione: 11, peso: .semibold)
            static let colore = Tema.Apple.Colore.inchiostro2
            static let fondo = Tema.Apple.Colore.chip
            static let padding = Tema.Apple.Misura.padding(3, 9)
            static let dallAlto: CGFloat = 16
            static let daDestra: CGFloat = 14
            /// Lo spazio minimo fra il tassello e l'etichetta del momento: se non c'è, l'etichetta perde la durata.
            static let accantoTassello: CGFloat = 8
            /// L'etichetta delle consigliate: i toni dello stato positivo dei dossier (`.st2.ok`).
            static let consiglio = C(dimensione: 11.5, peso: .bold)
            static let paddingConsiglio = Tema.Apple.Misura.padding(3, 9)
            static let testoConsiglio = Tema.Apple.Clienti.Obiettivi.testoStatoOk
            static let fondoConsiglio = Tema.Apple.Clienti.Obiettivi.fondoStatoOk
            /// L'etichetta sta a 72 dall'alto della scheda piccola: subito sotto il tassello (16 + 44), dentro la
            /// colonna, così non copre mai il titolo e la frase.
            static let sopraConsiglio: CGFloat = 72
            static var sottoTasselloConsiglio: CGFloat {
                max(0, sopraConsiglio - Scheda.paddingPiccola - Scheda.tassello)
            }
            /// Le schede di un altro momento: attenuate, non nascoste (restano cliccabili).
            static let opacitaAttenuata: Double = 0.26
            static let durataCambio = 0.35
            static var cambio: Animation { Tema.Apple.Moto.Curva.ease.animazione(durataCambio) }
        }

        /// Il palco: testata alta 40 («‹ Sala», tassello 32 raggio 10, nome 21 bold, cliente 14 grigio, pulsanti a
        /// destra a 6), la card a 52 dall'alto fino in fondo.
        enum Palco {
            static let altezzaTestata: CGFloat = 40
            static let spazioTestata: CGFloat = 12
            static let spazioPulsanti: CGFloat = 6
            static let tassello = Tema.Apple.Tassello.latoPalco
            static let raggioTassello: CGFloat = 10
            static let nome = C.h2
            static let cliente = C.corpo
            static let dallAlto: CGFloat = 52
            /// Lo stato «in arrivo» dentro la card.
            static let tasselloInArrivo = Tema.Apple.Tassello.latoSalaGrande
            static let spazioInArrivo: CGFloat = 14
            static let titoloInArrivo = C.titoloGruppo
            static let testoInArrivo = C.corpoGrande
            static let larghezzaInArrivo: CGFloat = 460
        }

        /// Migliorie d'uso 59 «Ogni esperienza ha il suo copione»: il riquadro «Cosa dire» (`#saCopP`), ancorato in alto a
        /// destra del palco, 48 sotto la testata, largo 372, padding 16×18, superficie dei pannelli sospesi (l'ombra
        /// `vetro` è quella del tema più vicina a 0 24 50 −18 blu notte al 50%); la frase d'apertura e la domanda con il
        /// carattere del titolo 17 semibold (`.copA`), le etichette `.k`, i tre passi con il numerino tondo blu 20.
        enum Copione {
            static let larghezza: CGFloat = 372
            static let dallAlto: CGFloat = 48
            static let padding = Tema.Apple.Misura.padding(16, 18)
            static let superficie = Tema.Apple.Superficie.vetroSopra
            static let raggio = Tema.Apple.Raggio.card
            /// L'occhiello «Cosa dire · per spiegare · 3 minuti» (`.lbl`).
            static let occhiello = C.etichetta
            static let coloreOcchiello = Tema.Apple.Colore.inchiostro2
            /// La ✕ che chiude.
            static let glifoChiudi = C(dimensione: 11, peso: .bold)
            /// «Apri così», «Mentre la fate», «Chiudi con una domanda» e «Lo vedi solo tu» (`.k`).
            static let etichetta = C.secondario
            static let coloreEtichetta = Tema.Apple.Colore.inchiostro2
            static let sottoOcchiello: CGFloat = 10
            static let spazioSezione: CGFloat = 12
            static let sottoEtichetta: CGFloat = 2
            /// `.copA`: 17 semibold, interlinea 1,35, tracking −0,2.
            static let frase = C(dimensione: 17, peso: .semibold, tracking: -0.2, interlinea: 1.35)
            static let coloreFrase = Tema.Apple.Colore.inchiostro
            /// I passi: testo 14, spazio 10, padding verticale 5.
            static let passo = C.corpo
            static let colorePasso = Tema.Apple.Colore.inchiostro
            static let spazioPasso: CGFloat = 10
            static let paddingPasso: CGFloat = 5
            /// Il numerino: lato 20, cifra 11,5 bold bianca su accento.
            static let numerino: CGFloat = 20
            static let cifra = C(dimensione: 11.5, peso: .bold, tabellare: true)
            static let fondoNumerino = Tema.Apple.Colore.accento
            static let coloreCifra = Color.white
            /// Il filetto sopra «Lo vedi solo tu».
            static let filetto = Tema.Apple.Colore.separatore
            static let spessoreFiletto: CGFloat = 1
            static let sottoFiletto: CGFloat = 10
            /// Il glifo «info» del pulsante, lato 14.
            static let glifoPulsante = C(dimensione: 14, peso: .regular)
            static let spazioPulsante: CGFloat = 5
        }

        /// Migliorie d'uso 60 «Ogni esperienza lascia qualcosa»: «✓ Fatta oggi» è la capsula di stato «ok» del tema
        /// (`CapsulaStatoApple`, `.st2.ok`: 11,5 bold, padding 3×9, #1F7A41 / #6FD08E su verde 0,15); sulla griglia sta
        /// in alto a destra della scheda, 44 dall'alto e 14 da destra (`.saOk`), sotto l'etichetta del momento. Nel
        /// dossier il riquadro «In Sala» con le ultime cinque esperienze fatte (data breve e titolo).
        enum Fatte {
            static let dallAlto: CGFloat = 44
            static let daDestra: CGFloat = 14
            /// Le righe del riquadro «In Sala» nel dossier.
            static let quante = 5
            static let spazioRighe: CGFloat = 6
            static let spazioRiga: CGFloat = 10
            static let data = C(dimensione: 13, peso: .regular, tabellare: true)
            static let coloreData = Tema.Apple.Colore.inchiostro2
            static let larghezzaData: CGFloat = 56
            static let riga = C(dimensione: 13, peso: .semibold)
            static let coloreRiga = Tema.Apple.Colore.inchiostro
            static let tassello: CGFloat = 20
            static let raggioTassello: CGFloat = 6
        }

        /// La presentazione sulla sala opaca (velo dei Prospetti, sempre scuro): il palco grande al centro, «Chiudi»
        /// bianco in basso.
        enum Presenta {
            static let velo = Tema.Apple.Colore.sala
            static let margine: CGFloat = 40
            static let comandiFondo: CGFloat = 24
            static let altezzaComandi: CGFloat = 32
            static let sopraComandi: CGFloat = 20
            static let tassello: CGFloat = 96
            static let raggioTassello: CGFloat = 26
            static let spazio: CGFloat = 18
            static let titolo = C(dimensione: 34, peso: .bold, tracking: -0.8)
            static let testo = C(dimensione: 17, peso: .regular, interlinea: 1.4)
            static let coloreTitolo = Color.white
            static let coloreTesto = Color(r: 255, g: 255, b: 255, a: 0.72)
            static let cliente = C.sottotitolo
            static let coloreCliente = Color(r: 255, g: 255, b: 255, a: 0.55)
            static let larghezzaTesto: CGFloat = 560
        }
    }
}

extension Tema.Apple.Moto.Inclinazione {
    /// La Sala: massimo 4° per la scheda grande, 7° per le piccole.
    static let massimoSalaGrande: Double = 4
    static let massimoSala: Double = 7
}

extension Tema.Apple.Moto {
    /// La Sala: la scheda scelta (scala 1,05 e opacità 0,4 in 0,18 s), la rimonta che parte 0,12 s dopo il clic e la
    /// card del palco che entra da scala 0,98 in 0,52 s con `uscita`; il palco nasce dalla scheda
    /// (`matchedGeometryEffect`, decisione 124) e ci torna con «‹ Sala».
    enum SalaEsperienze {
        static let durataScelta = 0.18
        static let scalaScelta: CGFloat = 1.05
        static let opacitaScelta: Double = 0.4
        static let ritardoRimonta = 0.12
        static let durataPalco = 0.52
        static let scalaPalco: CGFloat = 0.98
        static var palco: Animation { Curva.uscita.animazione(durataPalco) }
        /// Il passaggio griglia ↔ palco (la card nasce dalla scheda toccata).
        static var passaggio: Animation { Curva.dettaglioApre.animazione(durataPalco) }
        static var ritorno: Animation { Curva.dettaglioChiude.animazione(durataPalco) }
        /// Migliorie d'uso 59: il riquadro «Cosa dire» scende di 8 e cresce da 0,98 con una molla in 0,32 s.
        static let durataCopione = 0.32
        static let scalaCopione: CGFloat = 0.98
        static let discesaCopione: CGFloat = -8
        static var copione: Animation { Curva.molla.animazione(durataCopione) }
    }
}
