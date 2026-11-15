import SwiftUI

// Messaggi, «Prisma scrive per te» (versione «Orizzonte», giro 3, Design/template-novita-specifica.md §5.2 e §5.3):
// misure, caratteri, colori e tempi della colonna delle occasioni, del pannello del messaggio (testata, toni e canali
// a pillola, oggetto, testo o nuvoletta, cifre, pulsanti) e della versione dell'iPhone. Le viste stanno in
// Shell/AppMessaggi.swift, Shell/PannelloMessaggio.swift e iOS/MessaggiTelefono.swift; qui solo i valori, tutti
// ricavati dal tema Apple.

extension Tema.Apple {
    enum Messaggi {
        // MARK: Disposizione (§2, #wc)

        enum Disposizione {
            /// La colonna `.side` larga 380 e 16 di gioco prima del pannello (`left:396px`).
            static let larghezzaColonna: CGFloat = 380
            /// Nelle finestre strette (iPad in verticale) la colonna scende fino a 280.
            static let larghezzaColonnaMinima: CGFloat = 280
            static let quotaColonna: CGFloat = 0.32
            static let gioco: CGFloat = 16
            /// Sotto questa larghezza il pannello mette i controlli e i pulsanti uno sotto l'altro.
            static let pannelloCompatto: CGFloat = 620
        }

        // MARK: Colonna delle occasioni (§2.1)

        enum Colonna {
            static let superficie = Superficie.pannello
            static let raggio = Raggio.pannello
            /// `padding:14px 12px`.
            static let padding = Misura.Padding.barraLaterale
            /// Occhiello `.lbl`: il primo `2px 4px 8px`, i successivi `14px 4px 8px`.
            static let occhiello = Carattere.etichetta
            static let coloreOcchiello = Colore.inchiostro2
            static let occhielloPrimo = EdgeInsets(top: 2, leading: 4, bottom: 8, trailing: 4)
            static let occhielloAltri = EdgeInsets(top: 14, leading: 4, bottom: 8, trailing: 4)
            /// «Niente da mandare oggi»: riga secondaria sotto il primo occhiello.
            static let vuoto = Carattere.secondario
            static let coloreVuoto = Colore.inchiostro2
            static let rientroVuoto: CGFloat = 4
            /// La scheda piatta in fondo: raggio 22, `padding:12px 14px`, 12 dai bordi, testo `.k` interlinea 1,45.
            static let superficieNota = Superficie.cardPiatta
            static let raggioNota = Raggio.card
            static let paddingNota = Misura.padding(12, 14)
            static let sopraNota: CGFloat = 12
            static let testoNota = Carattere(dimensione: 12.5, peso: .regular, interlinea: 1.45)
            static let coloreTestoNota = Colore.inchiostro2
            /// Migliorie d'uso 25 (Mac): il numerino accanto all'occhiello (`.bN2`: 11 bold, fondo `chip`, testo
            /// `inchiostro2`, a capsula, `padding:1px 7px`), 6 dal titolo. Lo usa `NumeroOcchielloApple`.
            static let numeroOcchiello = Carattere(dimensione: 11, peso: .bold, tabellare: true)
            static let fondoNumeroOcchiello = Colore.chip
            static let coloreNumeroOcchiello = Colore.inchiostro2
            static let paddingNumeroOcchiello = Misura.padding(1, 7)
            static let spazioNumeroOcchiello: CGFloat = 6
        }

        // MARK: Voce dell'elenco (§2.1 `.rub`)

        enum Voce {
            /// Padding 10 (il template sovrascrive i 9×8 della base), raggio 14, 2 fra le voci.
            static let padding = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            static let raggio = Raggio.voce
            static let fraVoci: CGFloat = 2
            /// Avatar 38, 10 dal testo.
            static let avatar = Misura.Avatar.medio
            static let spazioAvatar: CGFloat = 10
            /// Nome 14 bold; titolo 12 `inchiostro2` su una riga, largo al massimo 260; il perché 11,5 `inchiostro3`.
            static let nome = Carattere(dimensione: 14, peso: .bold)
            static let coloreNome = Colore.inchiostro
            static let titolo = Carattere(dimensione: 12, peso: .regular)
            static let coloreTitolo = Colore.inchiostro2
            static let larghezzaTitolo: CGFloat = 260
            static let perche = Carattere(dimensione: 11.5, peso: .regular)
            static let colorePerche = Colore.inchiostro3
            static let spazioTitoli: CGFloat = 1
            static let spazioNome: CGFloat = 6
            /// «✓ Preparato alle 10:42»: verde, semibold.
            static let preparato = Carattere(dimensione: 11.5, peso: .semibold)
            static let colorePreparato = Colore.verde
            /// Migliorie d'uso 25 (Mac): la spunta verde a destra di un messaggio spedito (`gu('fatto',17)`), 8 dal testo;
            /// sotto il titolo «Aperto in Mail alle …» (aperto, non ancora confermato) in `inchiostro2`.
            static let spuntaSpedito = Carattere(dimensione: 17, peso: .semibold)
            static let simboloSpedito = "checkmark.circle.fill"
            static let coloreSpedito = Colore.verde
            static let spazioSpunta: CGFloat = 8
            static let coloreAperto = Colore.inchiostro2
            /// Sotto il puntatore `chip`, scelta `selezioneVoce`, il fondo cambia in 0,25 s.
            static let fondoSopra = Colore.chip
            static let fondoScelta = Colore.selezioneVoce
            static let durataFondo = 0.25
            static var animazioneFondo: Animation { .easeInOut(duration: durataFondo * Tema.Apple.Moto.ritmo) }
        }

        // MARK: Pannello del messaggio (§2.2)

        enum Pannello {
            /// `.main.card` senza ombra: raggio 22, `padding:22px 26px`; nella versione compatta 18 per lato.
            static let superficie = Superficie.cardPiatta
            static let raggio = Raggio.card
            static let padding = Misura.Padding.cardPortafoglio
            static let paddingCompatto = Misura.padding(18, 18)
            /// Testata: avatar 46, 12 di gioco; «A: …» `.k`; titolo display 23 bold, tracking −0,4.
            static let avatar: CGFloat = 46
            static let spazioTestata: CGFloat = 12
            static let destinatario = Carattere.secondario
            static let coloreDestinatario = Colore.inchiostro2
            /// «manca l'indirizzo email nel dossier»: arancio come gli avvisi.
            static let coloreRecapitoMancante = Colore.arancioTesto
            static let titolo = Carattere(dimensione: 23, peso: .bold, tracking: -0.4)
            static let coloreTitolo = Colore.inchiostro
            static let spazioTitolo: CGFloat = 2
            /// Le pillole della testata: 12 semibold, `padding:5px 11px`, a capsula.
            static let pillola = Carattere(dimensione: 12, peso: .semibold)
            static let paddingPillola = Misura.padding(5, 11)
            static let spazioPillole: CGFloat = 6
            /// «Perché adesso: …»: fondo accento al 10%, testo accento (uguale in chiaro e in scuro).
            static let fondoPerche = Color(r: 0, g: 122, b: 255, a: 0.10)
            static let testoPerche = Colore.accento
            /// «Senza consenso commerciale»: fondo e testo arancio degli avvisi.
            static let fondoConsenso = Colore.avvisoFondo
            static let testoConsenso = Colore.arancioTesto
            /// Riga dei controlli: gap 10, `margin:18px 0 14px`.
            static let controlliSopra: CGFloat = 18
            static let controlliSotto: CGFloat = 14
            static let spazioControlli: CGFloat = 10
            /// La nota di Vera a destra: sfera 20 e `.k`.
            static let sfera: CGFloat = 20
            static let spazioSfera: CGFloat = 6
            static let notaVera = Carattere.secondario
            static let coloreNotaVera = Colore.inchiostro2
            /// Migliorie d'uso 26 (solo Mac): le etichette «Tono» e «Invia con» (`.k` 12,5 `inchiostro2`), 8 dal
            /// segmentato, 14 fra i due gruppi; a destra «Vera ha usato N dati del dossier ›» (`.lnk` 13 semibold accento).
            static let etichettaControllo = Carattere.secondario
            static let coloreEtichettaControllo = Colore.inchiostro2
            static let spazioEtichetta: CGFloat = 8
            static let fraGruppiControlli: CGFloat = 14
            static let datiUsati = Carattere(dimensione: 13, peso: .semibold)
            static let coloreDatiUsati = Colore.accento
            /// Riga dell'oggetto: 14, `padding:10px 0`, filetto basso `separatore`.
            static let oggetto = Carattere(dimensione: 14, peso: .regular)
            static let oggettoForte = Carattere(dimensione: 14, peso: .bold)
            static let coloreEtichettaOggetto = Colore.inchiostro2
            static let coloreOggetto = Colore.inchiostro
            static let paddingOggetto: CGFloat = 10
            static let spazioOggetto: CGFloat = 4
            static let filetto = Colore.separatore
            static let spessoreFiletto = Misura.bordo
            /// L'avviso sopra il testo (Vera non è pronta, una cifra cambiata): sfera ferma e `.k`, 14 sopra.
            static let avviso = Carattere(dimensione: 12.5, peso: .regular, interlinea: 1.4)
            static let coloreAvviso = Colore.inchiostro2
            static let sopraAvviso: CGFloat = 14
            /// «Dati di prova: …»: arancio, 11,5.
            static let prova = Carattere(dimensione: 11.5, peso: .semibold)
            static let coloreProva = Colore.arancioTesto
            static let sopraProva: CGFloat = 6
        }

        // MARK: Il testo (§2.2 `#testoM`)

        enum Testo {
            /// 15,5 regular, interlinea 1,6, a capo conservati; 14 sopra; con Mail alto almeno 300.
            static let carattere = Carattere(dimensione: 15.5, peso: .regular, interlinea: 1.6)
            static let colore = Colore.inchiostro
            static let sopra: CGFloat = 14
            static let altezzaMinima: CGFloat = 300
            static let altezzaMinimaCompatta: CGFloat = 180
            /// Il margine interno della riga del campo di testo del sistema (si toglie per allineare testo e campo).
            static let rientroCampo: CGFloat = 5
            /// Nuvoletta di Messaggi: fondo accento, testo bianco, `padding:14px 18px`, raggi 22/22/6/22 (l'angolo
            /// stretto in basso a destra, come la bolla dell'utente nella chat di Vera), larga al massimo 620, a destra.
            static let fondoNuvoletta = Colore.accento
            static let testoNuvoletta = Color.white
            static let paddingNuvoletta = Misura.padding(14, 18)
            static let raggioNuvoletta: CGFloat = 22
            static let raggioNuvolettaStretto: CGFloat = 6
            static let larghezzaNuvoletta: CGFloat = 620
            /// Mentre Vera comincia: i tre puntini, 4 sopra.
            static let sopraPuntini: CGFloat = 4
        }

        // MARK: Cifre usate e nota (aggiunte dell'app, non nel template)

        enum Cifre {
            /// Le cifre della scheda come piccole etichette a capsula: etichetta 11,5 regular, valore 11,5 semibold,
            /// fondo `chip`, `padding:3px 9px`, 6 fra loro; 14 sopra.
            static let etichetta = Carattere(dimensione: 11.5, peso: .regular)
            static let valore = Carattere(dimensione: 11.5, peso: .semibold, tabellare: true)
            static let coloreEtichetta = Colore.inchiostro2
            static let coloreValore = Colore.inchiostro
            static let fondo = Colore.chip
            static let padding = Misura.Padding.etichettaCanale
            static let spazio: CGFloat = 6
            static let spazioInterno: CGFloat = 4
            static let sopra: CGFloat = 14
            /// Un valore lungo (le decisioni dell'incontro) si tronca: il testo intero è nell'aiuto.
            static let larghezzaMassima: CGFloat = 300
            /// «Le cifre vengono da Prisma»: `.k` `inchiostro3`, 8 sopra.
            static let nota = Carattere.secondario
            static let coloreNota = Colore.inchiostro3
            static let sopraNota: CGFloat = 8
        }

        // MARK: La scheda «Da dove vengono le cifre» (migliorie d'uso 26, solo Mac)

        enum FoglioDati {
            /// Larga 440, `padding:22px 24px`; occhiello `.lbl`; titolo 23 bold tracking −0,4 (`margin:4px 0 6px`);
            /// frase 13,5 `inchiostro2`; righe chiave/valore 14 (`.kvr`: `padding:9px 0`, alte almeno 40, filo
            /// `separatore` fra le righe, chiave `inchiostro2` larga al massimo 210, valore in grassetto tabellare).
            static let larghezza: CGFloat = 440
            static let padding = Misura.padding(22, 24)
            static let occhiello = Carattere.etichetta
            static let coloreOcchiello = Colore.inchiostro2
            static let titolo = Carattere(dimensione: 23, peso: .bold, tracking: -0.4)
            static let coloreTitolo = Colore.inchiostro
            static let sopraTitolo: CGFloat = 4
            static let frase = Carattere(dimensione: 13.5, peso: .regular, interlinea: 1.4)
            static let coloreFrase = Colore.inchiostro2
            static let sopraFrase: CGFloat = 6
            static let sopraRighe: CGFloat = 8
            static let chiave = Carattere(dimensione: 14, peso: .regular)
            static let coloreChiave = Colore.inchiostro2
            static let larghezzaChiave: CGFloat = 210
            static let valore = Carattere(dimensione: 14, peso: .bold, tabellare: true)
            static let coloreValore = Colore.inchiostro
            static let spazioRiga: CGFloat = 16
            static let paddingRiga: CGFloat = 9
            static let altezzaRiga: CGFloat = 40
            static let filo = Colore.separatore
            static let spessoreFilo = Misura.bordo
            /// «Scritto da Vera» / «Testo di Prisma» in fondo, `.k` `inchiostro3`, 12 sopra; «Chiudi» 16 sopra.
            static let nota = Carattere.secondario
            static let coloreNota = Colore.inchiostro3
            static let sopraNota: CGFloat = 12
            static let sopraPulsanti: CGFloat = 16
            /// Nelle istantanee la scheda si disegna sopra il pannello, sul velo, come il dettaglio.
            static let velo = Colore.velo
            static let superficie = Superficie.dettaglio
            static let raggio = Raggio.dettaglioAperto
        }

        // MARK: Barra dei pulsanti (§2.2)

        enum Barra {
            /// Gap 8, 16 sopra (la barra resta in fondo al pannello); nota a destra `.k`.
            static let spazio: CGFloat = 8
            static let sopra: CGFloat = 16
            static let nota = Carattere.secondario
            static let coloreNota = Colore.inchiostro2
            /// Migliorie d'uso 25 (Mac): la barra a tre stati. «Aperto in Mail. L’hai spedito?» 14,5 bold, 8 prima dei
            /// pulsanti; la pillola verde «✓ Spedito oggi alle …» (13 semibold, fondo verde al 12%, `padding:6px 12px`)
            /// con accanto «È nel dossier di …» `.k`.
            static let domanda = Carattere(dimensione: 14.5, peso: .bold)
            static let coloreDomanda = Colore.inchiostro
            static let spazioDomanda: CGFloat = 8
            static let pillolaSpedito = Carattere(dimensione: 13, peso: .semibold)
            static let testoPillolaSpedito = Colore.verde
            static let fondoPillolaSpedito = Colore.verde.opacity(0.12)
            static let paddingPillolaSpedito = Misura.padding(6, 12)
            static let simboloPillolaSpedito = "checkmark"
            static let spazioPillolaSpedito: CGFloat = 5
            /// Un messaggio spedito si rilegge: il testo com'era, senza campo né comparsa.
            static let opacitaControlliSpento = 0.5
        }

        // MARK: Stato vuoto (§1.6)

        enum Vuoto {
            static let simbolo = "envelope"
            static let carattereSimbolo = Tema.Apple.AltreApp.simboloVuoto
            static let coloreSimbolo = Colore.inchiostro3
            static let testo = Carattere(dimensione: 14, peso: .regular, interlinea: 1.45)
            static let coloreTesto = Colore.inchiostro2
            static let spazio: CGFloat = 12
            static let larghezza: CGFloat = 420
        }

        // MARK: iPhone (Design/iphone.html: una cosa principale grande in alto)

        enum Telefono {
            /// Il pannello sull'iPhone è una sola colonna che scorre; 12 dai bordi della finestra.
            static let margine = Tema.Apple.Telefono.Elenco.margine
            static let spazio: CGFloat = 12
            /// Il menu «Occasioni» a destra nella barra: 14 semibold accento.
            static let menu = Carattere(dimensione: 14, peso: .semibold)
            static let coloreMenu = Colore.accento
        }

        // MARK: Movimento (§3)

        enum Moto {
            /// Il testo già pronto compare parola per parola: 2 pezzi (una parola e uno spazio) ogni 22 ms.
            static let parola = 0.022
            /// Cambio di occasione: il pannello esce in 0,13 s (lineare) spostandosi di 10 a destra, poi rientra a
            /// cascata da 0.
            static let durataCambio = 0.13
            static let spostamentoCambio: CGFloat = 10
            static var uscitaCambio: Animation { .linear(duration: durataCambio * Tema.Apple.Moto.ritmo) }
            /// Cascata: 0,14 all'apertura della finestra, 0 dopo un cambio di occasione.
            static let baseApertura = Tema.Apple.Moto.Cascata.baseFinestra
            static let baseCambio = Tema.Apple.Moto.Cascata.baseDentroApp
            /// Al più tante voci entrano a cascata, le altre con l'ultima.
            static let voceMassima = 8
            /// Migliorie d'uso 25 (Mac): la barra cambia stato con un'entrata breve (opacità 0→1, y 6→0, 0,26 s);
            /// calmo: dissolvenza 0,15 s; istantanee: ferma.
            static let durataCambioBarra = 0.26
            static let spostamentoCambioBarra: CGFloat = 6
            static var cambioBarra: Animation { .easeOut(duration: durataCambioBarra * Tema.Apple.Moto.ritmo) }
        }
    }
}
