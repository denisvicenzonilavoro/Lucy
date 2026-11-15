import SwiftUI

// Clienti del tema Apple: rubrica e dossier (Design/template-apple-specifica.md §4.2.1, riferimenti PC C01-C05).
// Le viste stanno in Shell/DossierApple.swift (rubrica, testata, tessere, schede, cambio cliente e scheda) e nei
// file Shell/Dossier<Nome>.swift (contenuto delle schede del template); qui solo i valori.
// Rubrica: barra laterale 250 con padding 14×12; dossier: card senza ombra a 266 da sinistra, padding 22×24.

extension Tema.Apple {
    enum Clienti {
        // MARK: Disposizione

        /// Larghezza della rubrica (`.side` 250).
        static let larghezzaRubrica: CGFloat = Misura.Laterale.clienti
        /// Spazio fra la rubrica e il dossier: il dossier comincia a 266 da sinistra.
        static let spazioRubrica: CGFloat = 16
        /// Sotto questa larghezza del dossier la rubrica si nasconde (finestre a metà negli spazi): il cliente si
        /// sceglie dal selettore nella barra della finestra.
        static let larghezzaMinimaDossier: CGFloat = 560

        // MARK: Rubrica

        enum Rubrica {
            /// Padding della barra laterale 14×12.
            static let padding = Misura.Padding.barraLaterale
            /// `.lbl` «Rubrica» con il numero dei clienti a destra.
            static let titolo = Carattere.etichetta
            static let coloreTitolo = Colore.inchiostro2
            /// Ricerca a capsula `chip`: padding 8×14, 13, margini 8 sopra e 10 sotto.
            static let paddingRicerca = Misura.padding(8, 14)
            static let carattereRicerca = Carattere(dimensione: 13, peso: .regular)
            static let fondoRicerca = Colore.chip
            static let coloreRicerca = Colore.inchiostro
            static let segnoRicerca = Colore.inchiostro3
            static let spazioSegnoRicerca: CGFloat = 6
            static let sopraRicerca: CGFloat = 8
            static let sottoRicerca: CGFloat = 10
            /// Filtro «Tutti · ★ Preferiti» di Prisma (il template non l'ha): sotto la ricerca, spazio 10.
            static let sottoFiltro: CGFloat = 10
            /// Voce: padding 9×8, raggio 14, spazio 10, 2 fra una voce e l'altra.
            static let paddingVoce = Misura.padding(9, 8)
            static let raggioVoce: CGFloat = Raggio.voce
            static let spazioVoce: CGFloat = 10
            static let fraVoci: CGFloat = 2
            /// Avatar 38, nome 14 bold, motto 12 `inchiostro2` troncato.
            static let avatar: CGFloat = Misura.Avatar.medio
            static let nome = Carattere(dimensione: 14, peso: .bold)
            static let motto = Carattere(dimensione: 12, peso: .regular)
            static let coloreNome = Colore.inchiostro
            static let coloreMotto = Colore.inchiostro2
            static let spazioNomeMotto: CGFloat = 1
            /// La stella dei preferiti (Prisma), nel cuoio del canale indipendente.
            static let stella = Carattere(dimensione: 13, peso: .bold)
            static let coloreStella = Colore.canaleIndipendente
            /// Sotto il puntatore `chip`; scelta `rgba(0,122,255,.13)`; il fondo cambia in 0,25 s.
            static let fondoSopra = Colore.chip
            static let fondoScelta = Colore.selezioneVoce
            static let durataFondo = 0.25
            static var animazioneFondo: Animation { .easeInOut(duration: durataFondo * Tema.Apple.Moto.ritmo) }
            /// Riga vuota dell'elenco e piede («5 contatti», «+ 30 clienti di prova»): `.k`.
            static let piede = Carattere.secondario
            static let colorePiede = Colore.inchiostro2
            static let sopraPiede: CGFloat = 10
            /// Spazio fra «Rubrica» e il numero dei clienti, e fra le due righe del piede.
            static let spazioTitolo: CGFloat = 4
            static let fraRighePiede: CGFloat = 2
        }

        // MARK: «La tua rubrica» con «Tutti i clienti» (migliorie d'uso 2, 3 e 11)

        /// Senza un cliente scelto, al posto del dossier (`rubricaTuttiHTML` del template): la testa con l'icona, le
        /// quattro cifre in tessere e il «Da fare» di tutti con cinque voci. Solo sul Mac.
        enum TuttiIClienti {
            /// Padding della pagina 22×24 (come il dossier); al massimo largo 860.
            static let padding = Misura.padding(22, 24)
            static let larghezzaMassima: CGFloat = 860
            /// La testa: quadrato 60 raggio 20 con fondo accento al 10%, simbolo 30; 16 fra icona e testi.
            static let icona: CGFloat = 60
            static let raggioIcona: CGFloat = 20
            static let fondoIcona = Colore.accento.opacity(0.10)
            static let coloreIcona = Colore.accento
            static let simbolo = Carattere(dimensione: 30, peso: .regular)
            static let spazioTesta: CGFloat = 16
            /// «Tutti i clienti» 11 maiuscolo, «La tua rubrica» 27 bold (tracking −0,6), la frase 13,5 `inchiostro2`.
            static let occhiello = Carattere(dimensione: 11, peso: .semibold, tracking: 0.6, maiuscolo: true)
            static let coloreOcchiello = Colore.inchiostro2
            static let titolo = Carattere(dimensione: 27, peso: .bold, tracking: -0.6)
            static let coloreTitolo = Colore.inchiostro
            static let frase = Carattere(dimensione: 13.5, peso: .regular)
            static let coloreFrase = Colore.inchiostro2
            /// Le quattro tessere: 18 sotto la testa, 12 fra l'una e l'altra, padding 14×16, raggio `tile`.
            static let tessereSopra: CGFloat = 18
            static let spazioTessere: CGFloat = 12
            static let paddingTessera = Misura.padding(14, 16)
            static let superficieTessera = Superficie.tile
            static let raggioTessera: CGFloat = Raggio.tile
            static let nomeTessera = Carattere.secondario
            static let coloreNomeTessera = Colore.inchiostro2
            static let cifra = Carattere.valore
            static let coloreCifra = Colore.inchiostro
            /// « su 35» dopo la cifra: 15 semibold `inchiostro2`.
            static let suffisso = Carattere(dimensione: 15, peso: .semibold)
            static let coloreSuffisso = Colore.inchiostro2
            /// La card «Da fare»: 14 sotto le tessere, padding 16/20/8, senza ombra; cinque voci; «Apri tutto ›» 13 in
            /// accento; 4 sotto la testata.
            static let daFareSopra: CGFloat = 14
            static let paddingDaFare = EdgeInsets(top: 16, leading: 20, bottom: 8, trailing: 20)
            static let superficieDaFare = Superficie.cardPiatta
            static let raggioDaFare: CGFloat = Raggio.card
            static let righeDaFare = 5
            static let etichettaDaFare = Carattere.etichetta
            static let coloreEtichettaDaFare = Colore.inchiostro2
            static let spazioTestataDaFare: CGFloat = 8
            static let sottoTestataDaFare: CGFloat = 4
            static let collegamento = Carattere(dimensione: 13, peso: .regular)
            static let coloreCollegamento = Colore.accento
            static let paddingAltre = EdgeInsets(top: 8, leading: 2, bottom: 4, trailing: 2)
            static let paddingVuoto = Misura.padding(12, 2)
        }

        // MARK: Indice del dossier (migliorie d'uso 11)

        /// Con un cliente scelto la colonna di sinistra è l'indice del suo dossier (`#dosIdx` del template, `.side`
        /// largo 216, il dossier a 16 di distanza): «‹ Rubrica», la testa del cliente e le sezioni in tre gruppi, con il
        /// numero piccolo dove c'è qualcosa da guardare. Solo sul Mac.
        enum Indice {
            static let larghezza: CGFloat = 216
            static let spazio: CGFloat = 16
            /// Padding della colonna 14×12, come la rubrica.
            static let padding = Misura.Padding.barraLaterale
            /// Voce `.side .vo`: alta 32, padding orizzontale 10, raggio 12, spazio 10, 13,5 medio.
            static let altezzaVoce: CGFloat = 32
            static let paddingVoce: CGFloat = 10
            static let raggioVoce: CGFloat = 12
            static let spazioVoce: CGFloat = 10
            static let voce = Carattere(dimensione: 13.5, peso: .medium)
            static let coloreVoce = Colore.inchiostro
            /// La voce scelta: fondo accento al 13%; sotto il puntatore `chip` (in 0,2 s).
            static let voceScelta = Colore.selezioneVoce
            static let voceSopra = Colore.chip
            static let durataFondo = 0.2
            static var animazioneFondo: Animation { .easeInOut(duration: durataFondo * Tema.Apple.Moto.ritmo) }
            /// «‹ Rubrica»: 13,5 semibold accento, simbolo 14.
            static let ritorno = Carattere(dimensione: 13.5, peso: .semibold)
            static let simboloRitorno = Carattere(dimensione: 14, peso: .semibold)
            static let coloreRitorno = Colore.accento
            /// La testa del cliente: avatar 40, nome 14,5 bold, motto 12 `inchiostro2`, padding 10/8/8, spazio 10.
            static let avatar: CGFloat = 40
            static let nome = Carattere(dimensione: 14.5, peso: .bold)
            static let motto = Carattere(dimensione: 12, peso: .regular)
            static let coloreNome = Colore.inchiostro
            static let coloreMotto = Colore.inchiostro2
            static let paddingTesta = EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8)
            static let spazioTesta: CGFloat = 10
            static let spazioNomeMotto: CGFloat = 1
            /// L'etichetta del gruppo (`.lbl.ig`): 11 maiuscolo, margine 13 sopra, 8 ai lati, 4 sotto.
            static let etichettaGruppo = Carattere(dimensione: 11, peso: .semibold, tracking: 0.6, maiuscolo: true)
            static let coloreEtichettaGruppo = Colore.inchiostro2
            static let paddingEtichettaGruppo = EdgeInsets(top: 13, leading: 8, bottom: 4, trailing: 8)
            /// Il numero accanto alla voce (`.vo small`): 11,5 tabellare, padding 1×7, a capsula.
            static let numero = Carattere(dimensione: 11.5, peso: .semibold, tabellare: true)
            static let paddingNumero = Misura.padding(1, 7)
            /// I quattro toni del numero: le cose da fare (rosso pieno, testo bianco), gli obiettivi che non ci arrivano
            /// (arancio tenue, testo arancio), le voci scadute di In regola (rosso tenue, testo rosso), i documenti (neutro).
            static let fondoUrgente = Colore.rossoBadge
            static let testoUrgente = Color.white
            static let fondoAttenzione = Color(r: 224, g: 138, b: 0, a: 0.16)
            static let testoAttenzione = Colore.arancioTesto
            static let fondoErrore = Color(r: 229, g: 72, b: 77, a: 0.14)
            static let testoErrore = Colore.rosso
            static let fondoNeutro = Colore.chip
            static let testoNeutro = Colore.inchiostro2
            /// Finestra stretta (solo il dossier): l'indice diventa la capsula «Sezione: Panoramica ⌄» al posto del
            /// segmentato.
            static let prefissoMenu = "Sezione: "
        }

        // MARK: Testata del dossier

        enum Testata {
            /// Padding del dossier 22×24.
            static let paddingDossier = Misura.Padding.cardGrande
            /// Avatar 56 e spazio 14 fra avatar e nome.
            static let avatar: CGFloat = Misura.Avatar.dossier
            static let spazioAvatar: CGFloat = 14
            /// «Dossier personale»: `.lbl` a 11.
            static let occhiello = Carattere(dimensione: 11, peso: .semibold, tracking: 0.6, maiuscolo: true)
            static let coloreOcchiello = Colore.inchiostro2
            /// Nome 27 bold.
            static let nome = Carattere.nomeDossier
            static let coloreNome = Colore.inchiostro
            /// «motto · età · professione»: `.k` a 13,5.
            static let motto = Carattere(dimensione: 13.5, peso: .regular)
            static let coloreMotto = Colore.inchiostro2
            /// A destra: canali, preferito, «Modifica», «Analisi 360» e «Prospetti» (spazio 6).
            static let spazioComandi: CGFloat = 6
            /// La stella dei preferiti nella testata (Prisma).
            static let stella = Carattere(dimensione: 19, peso: .regular)
            static let coloreStellaPiena = Colore.canaleIndipendente
            static let coloreStellaVuota = Colore.inchiostro3
            /// iPad stretto: i comandi scendono sotto il nome, staccati di 10.
            static let spazioDueRighe: CGFloat = 10
            /// Fra occhiello, nome e motto.
            static let spazioRighe: CGFloat = 1
        }

        // MARK: Tessere

        enum Tessere {
            /// Quattro tessere 258×76 con spazio 12, a 18 sotto la testata. Sul Mac (migliorie d'uso 12) le tessere stanno
            /// solo in Panoramica, in cima, e `sopra` è lo spazio fra le tessere e la Panoramica (la sezione parte a 116).
            static let altezza: CGFloat = 76
            static let spazio: CGFloat = 12
            static let sopra: CGFloat = 18
            /// Sotto questa larghezza le tessere vanno su due colonne (iPad stretto).
            static let larghezzaMinima: CGFloat = 180
            static let padding = Misura.Padding.tile
            /// `.k` e `.v` che conta; «· 3.100 €» 15 semibold `inchiostro2` dopo il numero delle proposte.
            static let etichetta = Carattere.secondario
            static let coloreEtichetta = Colore.inchiostro2
            static let valore = Carattere.valore
            static let coloreValore = Colore.inchiostro
            static let importoProposte = Carattere.delta
            static let coloreImportoProposte = Colore.inchiostro2
            static let spazioEtichetta: CGFloat = 2
            static let spazioImporto: CGFloat = 6
        }

        // MARK: Schede

        enum Schede {
            /// Il segmentato a 18 sotto le tessere e 14 sopra il contenuto della scheda.
            static let sopra: CGFloat = 18
            static let sotto: CGFloat = 14
            /// «Altro ▾» accanto al segmentato: spazio 8; la freccia 9 bold.
            static let spazioAltro: CGFloat = 8
            static let spazioFreccia: CGFloat = 5
            static let freccia = Carattere(dimensione: 9, peso: .bold)
            /// Cornice delle schede di Prisma (Bisogni, Documenti, In regola, Riesami, Anagrafica, Profilo, Note):
            /// card senza ombra con padding 20×22 e il corpo 14 `inchiostro`.
            static let cornice = Superficie.cardPiatta
            static let paddingCornice = Misura.Padding.cardMedia
            static let corpo = Carattere.corpo
            static let coloreCorpo = Colore.inchiostro
            /// Vuoto del segnaposto di «Nel tempo» (finché la scheda non c'è).
            static let titoloVuoto = Carattere.etichetta
            static let testoVuoto = Carattere.corpoGrande
            static let coloreVuoto = Colore.inchiostro2
            static let spazioVuoto: CGFloat = 8
        }

        // MARK: Movimento (§4.2.1)

        enum Moto {
            // Cambio cliente (x +14 in 0,14 s ease-in) e cambio scheda (y +6 in 0,13 s lineare):
            // `Tema.Apple.Moto.CambioCliente` e `Tema.Apple.Moto.CambioScheda`.
            /// Base della cascata dopo un cambio (dentro l'app).
            static let baseCambio = Tema.Apple.Moto.Cascata.baseDentroApp
            /// Base della cascata quando la finestra si apre.
            static let baseApertura = Tema.Apple.Moto.Cascata.baseFinestra
            /// Gli anelli delle schede partono a 0,15 s dopo un cambio di cliente o di scheda.
            static let ritardoAnelli = 0.15
            /// Indici della cascata del dossier: testata 0, tessere 1-4, segmentato 5; il contenuto della scheda
            /// comincia da 6 quando entra con il cliente, da 0 quando cambia solo la scheda.
            static let indiceTessere = 1
            static let indiceSchede = 5
            static let primoIndiceScheda = 6
            /// Migliorie d'uso 12 (Mac): niente testata nella pagina. Con l'indice accanto il contenuto parte da 0; con la
            /// capsula «Sezione: … ⌄» (finestra stretta) la capsula è 0 e il contenuto parte da 1. In Panoramica le
            /// quattro tessere vengono prima del contenuto e lo spostano di `blocchiTessere`.
            static let primoIndiceSenzaTestata = 0
            static let indiceSezioneSenzaTestata = 0
            static let primoIndiceSenzaTestataConSezione = 1
            static let blocchiTessere = 4
        }

        // MARK: Riga in testa del dossier (migliorie d'uso 12, Mac)

        /// Con un cliente scelto la riga in testa alla finestra dice «Il dossier di Marco.» con «45 anni · Libero
        /// professionista» e, a destra, `dossierAzioni` del template: i canali, «☆ Preferito» (arancio delle scritte
        /// quando è preferito, 6 dopo i canali), «Modifica», «Altro ⌄» e «Prospetti» (primario). Titolo e sottotitolo
        /// sono quelli della riga (`Tema.Apple.RigaTesta`). I pulsanti tengono sempre il nome: quando non ci stanno,
        /// gli ultimi passano nel menu «Altro ⌄».
        enum RigaDossier {
            static let spazioAzioni: CGFloat = 6
            static let margineDopoCanali: CGFloat = 6
            static let colorePreferito = Colore.arancioTesto
            /// «Altro ⌄»: la freccia come quella del vecchio «Altro ▾» del segmentato.
            static let spazioFreccia: CGFloat = Schede.spazioFreccia
            static let freccia = Schede.freccia
        }
    }
}
