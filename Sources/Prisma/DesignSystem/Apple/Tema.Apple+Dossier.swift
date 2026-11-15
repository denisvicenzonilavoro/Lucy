import SwiftUI

// Le schede Panoramica e Obiettivi del dossier nel tema Apple (Design/template-apple-specifica.md §4.2.2, §4.2.3,
// riferimenti PC C06-C16, C22-C23; MO 01, 06, 06b, 15, 16). Le viste stanno in Shell/DossierPanoramica.swift e
// Shell/DossierObiettivi.swift; qui solo i valori. Le cifre vengono tutte dai motori (completezza, obiettivi).

extension Tema.Apple.Clienti {
    // MARK: Panoramica (§4.2.2)

    enum Panoramica {
        /// Griglia `1,25fr 1fr` con spazio 14; sotto questa larghezza le due colonne vanno una sotto l'altra. Sul Mac
        /// `1,32fr 1fr` (migliorie d'uso 5: a sinistra il quadro del cliente).
        #if os(macOS)
        static let proporzione: CGFloat = 1.32
        #else
        static let proporzione: CGFloat = 1.25
        #endif
        static let spazio: CGFloat = Tema.Apple.Misura.Spazio.griglia
        #if os(iOS)
        /// Sull'iPad in verticale una colonna sola: «Dati per l'analisi» non sta in 1,25fr di 700 pt.
        static let larghezzaDueColonne: CGFloat = 760
        #else
        static let larghezzaDueColonne: CGFloat = 620
        #endif
        /// Le card della scheda: senza ombra come le app.
        static let superficie = Tema.Apple.Superficie.cardPiatta
        static let raggio: CGFloat = Tema.Apple.Raggio.card

        // «Dati per l'analisi» (padding 20×22)
        static let paddingDati = Tema.Apple.Misura.Padding.cardMedia
        static let titolo = Tema.Apple.Carattere.etichetta
        static let coloreTitolo = Tema.Apple.Colore.inchiostro2
        /// Spazio fra il titolo e la percentuale, e fra le voci del piede.
        static let spazioTitolo: CGFloat = 8
        /// Percentuale 22 bold: verde da 85 in su, altrimenti arancio (anche l'anello).
        static let percentuale = Tema.Apple.Carattere(dimensione: 22, peso: .bold, tabellare: true)
        static let sogliaVerde = 85
        static let testoCompleto = Tema.Apple.Colore.verde
        static let testoParziale = Tema.Apple.Colore.arancioTesto
        static let anelloCompleto = Tema.Apple.Colore.anello1
        static let anelloParziale = Tema.Apple.Colore.arancio
        /// Anello 120/13 con «completi» 11,5 al centro, a 12 sotto il titolo e a 22 dall'elenco.
        static let anello: CGFloat = 120
        static let spessoreAnello: CGFloat = 13
        static let centroAnello = Tema.Apple.Carattere(dimensione: 11.5, peso: .regular)
        static let coloreCentro = Tema.Apple.Colore.inchiostro2
        static let sopraCorpo: CGFloat = 12
        static let spazioAnello: CGFloat = 22
        /// Le voci da completare come `.prep`: pallino 20 con il bordo 2 `binario`, 13,5, padding 10, filo sotto.
        static let voce = Tema.Apple.Carattere.voceLista
        static let coloreVoce = Tema.Apple.Colore.inchiostro
        static let paddingVoce: CGFloat = 10
        static let spazioVoce: CGFloat = 10
        /// Il canale della posizione sta sotto il titolo della voce (4 sotto): il titolo ha tutta la larghezza
        /// per le sue due righe intere, senza finire in «…».
        static let sottoTitoloVoce: CGFloat = 4
        static let pallino: CGFloat = 20
        static let bordoPallino: CGFloat = 2
        static let colorePallino = Tema.Apple.Colore.binario
        static let filo = Tema.Apple.Colore.separatore
        /// La croce «non pertinente» (Prisma), discreta accanto a «Completa».
        static let croce = Tema.Apple.Carattere(dimensione: 10, peso: .bold)
        static let coloreCroce = Tema.Apple.Colore.inchiostro3
        static let latoCroce: CGFloat = 22
        /// Piede: «Mostra tutte», le voci non pertinenti con «Ripristina» (`.k`).
        static let piede = Tema.Apple.Carattere.secondario
        static let colorePiede = Tema.Apple.Colore.inchiostro2
        static let sopraPiede: CGFloat = 10
        static let tuttoCompleto = Tema.Apple.Carattere.voceLista

        // «Da ricordare» e «Prossimo incontro» (padding 18×20)
        static let paddingLaterali = Tema.Apple.Misura.Padding.cardPiccola
        /// Nota 15 con interlinea 1,5, a 8 sotto il titolo.
        static let nota = Tema.Apple.Carattere(dimensione: 15, peso: .regular, interlinea: 1.5)
        static let coloreNota = Tema.Apple.Colore.inchiostro
        static let notaVuota = Tema.Apple.Colore.inchiostro2
        static let sottoTitolo: CGFloat = 8
        /// Data 21 bold a 6 sotto il titolo, titolo dell'incontro 14 `inchiostro2`, «Apri in Agenda ›» 13 a 8.
        static let dataIncontro = Tema.Apple.Carattere.h2
        static let coloreData = Tema.Apple.Colore.inchiostro
        static let sopraData: CGFloat = 6
        static let titoloIncontro = Tema.Apple.Carattere(dimensione: 14, peso: .regular)
        static let coloreTitoloIncontro = Tema.Apple.Colore.inchiostro2
        static let collegamento = Tema.Apple.Carattere(dimensione: 13, peso: .semibold)
        static let coloreCollegamento = Tema.Apple.Colore.accento
        static let sopraCollegamento: CGFloat = 8
        /// La card del prossimo incontro si inclina di 5°.
        static let inclinazioneIncontro = Tema.Apple.Moto.Inclinazione.massimoAree

        /// Sotto la griglia, il resto della panoramica di Prisma (riesame, In regola, il dossier collegato).
        static let sopraSeguito: CGFloat = Tema.Apple.Misura.Spazio.griglia

        #if os(macOS)
        // MARK: Il quadro del cliente (migliorie d'uso 5, `#quadroC` del template)

        enum Quadro {
            /// Card: padding 18/22/14/22, testata «Il quadro di <Nome>» con «Apri Analisi 360 ›» a destra.
            static let padding = EdgeInsets(top: 18, leading: 22, bottom: 14, trailing: 22)
            static let collegamento = Tema.Apple.Carattere(dimensione: 13, peso: .semibold)
            static let coloreCollegamento = Tema.Apple.Colore.accento
            static let spazioTestata: CGFloat = 12
            /// La griglia 2×2 dei riquadri delle aree: spazio 10, a 12 sotto la testata.
            static let spazioGriglia: CGFloat = 10
            static let sopraGriglia: CGFloat = 12
            /// Un riquadro (`.tile` senza ombra): padding 10×14, anello e testi a 14, inclinazione massima 4.
            static let superficieTessera = Tema.Apple.Superficie.tile
            static let raggioTessera: CGFloat = Tema.Apple.Raggio.tile
            static let paddingTessera = EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
            static let spazioTessera: CGFloat = 14
            static let inclinazioneTessera: Double = 4
            /// Anello 76/9 con la cifra 17 bold al centro (i mesi 12,5, su due righe «3,5» / «mesi»).
            static let anello: CGFloat = 76
            static let spessoreAnello: CGFloat = 9
            static let cifra = Tema.Apple.Carattere(dimensione: 17, peso: .bold, interlinea: 1.05, tabellare: true)
            static let cifraMesi = Tema.Apple.Carattere(dimensione: 12.5, peso: .bold, interlinea: 1.05, tabellare: true)
            static let coloreCifra = Tema.Apple.Colore.inchiostro
            static let coloreTrattino = Tema.Apple.Colore.inchiostro3
            /// Occhiello dell'area 10,5 nel suo colore; la riga 15,5 bold a 2 sopra e 3 sotto; il testo 12,5 (1,35).
            static let occhiello = Tema.Apple.Carattere(dimensione: 10.5, peso: .semibold, tracking: 0.6, maiuscolo: true)
            static let riga = Tema.Apple.Carattere(dimensione: 15.5, peso: .bold, tracking: -0.2, interlinea: 1.2)
            static let coloreRiga = Tema.Apple.Colore.inchiostro
            static let sopraRiga: CGFloat = 2
            static let sottoRiga: CGFloat = 3
            static let testo = Tema.Apple.Carattere(dimensione: 12.5, peso: .regular, interlinea: 1.35)
            static let coloreTesto = Tema.Apple.Colore.inchiostro2
            static let righeTesto = 2

            /// La riga «Dati per l'analisi» in fondo (`#datiC`): filo sopra, 12 sopra e sotto il filo, spazio 12,
            /// barra larga al più 200, percentuale 13,5 bold che si conta.
            static let sopraDati: CGFloat = 12
            static let spazioDati: CGFloat = 12
            static let barraMassima: CGFloat = 200
            static let percentuale = Tema.Apple.Carattere(dimensione: 13.5, peso: .bold, tabellare: true)
            static let coloreDatiCompleti = Tema.Apple.Colore.verde

            /// L'elenco nato dalla riga: 680 di larghezza, 196 + 62 per voce, fra 320 e 640 di altezza.
            static let larghezzaDettaglio: CGFloat = 680
            static let altezzaBaseDettaglio: CGFloat = 196
            static let altezzaVoceDettaglio: CGFloat = 62
            static let altezzaMinimaDettaglio: CGFloat = 320
            static let altezzaMassimaDettaglio: CGFloat = 640
            /// «Completi al N%» 28 bold, la frase 14,5 a 6 (al più 540 di larghezza), 10 sopra l'elenco.
            static let titoloDettaglio = Tema.Apple.Carattere(dimensione: 28, peso: .bold, tracking: -0.6, tabellare: true)
            static let fraseDettaglio = Tema.Apple.Carattere(dimensione: 14.5, peso: .regular)
            static let larghezzaFrase: CGFloat = 540
            static let sopraFrase: CGFloat = 6
            static let sottoFrase: CGFloat = 10
            static let sopraTitoloDettaglio: CGFloat = 2
            /// «Tutti i dati ci sono»: 15 semibold verde, 22 sopra e sotto.
            static let tuttiCi = Tema.Apple.Carattere(dimensione: 15, peso: .semibold)
            static let paddingTuttiCi: CGFloat = 22

            /// «Da fare per <Nome>»: padding 14/18/6/18, al più tre righe.
            static let paddingDaFare = EdgeInsets(top: 14, leading: 18, bottom: 6, trailing: 18)
            static let righeDaFare = 3
            static let spazioTitoloDaFare: CGFloat = 6
            static let sottoTitoloDaFare: CGFloat = 2
        }
        #endif
    }

    // MARK: Obiettivi (§4.2.3)

    enum Obiettivi {
        /// Tre colonne con spazio 14 (strette, meno colonne): la larghezza minima di una card.
        static let colonnaMinima: CGFloat = 280
        static let spazio: CGFloat = Tema.Apple.Misura.Spazio.griglia
        /// Card: padding 22, contenuto centrato, inclinazione 10, tutte alte uguali.
        static let padding: CGFloat = 22
        static let altezzaMinima: CGFloat = 318
        static let superficie = Tema.Apple.Superficie.cardPiatta
        static let raggio: CGFloat = Tema.Apple.Raggio.card
        static let inclinazione = Tema.Apple.Moto.Inclinazione.massimoPredefinito
        /// Anello 150/15 nel colore dell'obiettivo con la percentuale 32 bold.
        static let anello: CGFloat = 150
        static let spessoreAnello: CGFloat = 15
        static let centroAnello = Tema.Apple.Carattere.centroAnello(32)
        static let coloreCentro = Tema.Apple.Colore.inchiostro
        /// Sotto la percentuale «oggi» (come «alla scadenza» nel dettaglio): dice quale copertura è.
        static let sottoCentro = Tema.Apple.Carattere.secondario
        static let coloreSottoCentro = Tema.Apple.Colore.inchiostro2
        /// Gli anelli delle card partono uno dopo l'altro.
        static let passoAnelli = Tema.Apple.Moto.Anello.passo
        /// Nome 20 bold a 14; «20.800 € di 40.000 €» e «550 € al mese · arriva a …» 13,5 `inchiostro2` a 4.
        static let nome = Tema.Apple.Carattere(dimensione: 20, peso: .bold, tracking: -0.3)
        static let coloreNome = Tema.Apple.Colore.inchiostro
        static let sopraNome: CGFloat = 14
        static let testo = Tema.Apple.Carattere(dimensione: 13.5, peso: .regular)
        static let coloreTesto = Tema.Apple.Colore.inchiostro2
        static let sopraTesto: CGFloat = 4
        /// I canali delle posizioni collegate, compatti, a 10.
        static let sopraCanali: CGFloat = 10
        static let spazioCanali: CGFloat = Tema.Apple.Misura.Spazio.etichettaCanale
        /// «Prova un altro versamento ›» 13 semibold blu, in fondo alla card.
        static let collegamento = Tema.Apple.Carattere(dimensione: 13, peso: .semibold)
        static let coloreCollegamento = Tema.Apple.Colore.accento
        static let sopraCollegamento: CGFloat = 12

        /// Migliorie d'uso 13 «Obiettivi: si vede se ci arriva»: sotto la riga grigia («550 € al mese · scadenza …»)
        /// lo stato scritto e colorato (`.st2` del template: capsula 12,5 bold, padding 4×11, a 10). Solo sul Mac:
        /// iPhone e iPad tengono la riga di prima fino al loro aggiornamento.
        #if os(macOS)
        static let mostraStato = true
        #else
        static let mostraStato = false
        #endif
        static let statoArrivo = Tema.Apple.Carattere(dimensione: 12.5, peso: .bold)
        static let paddingStato = Tema.Apple.Misura.padding(4, 11)
        static let sopraStato: CGFloat = 10
        /// I toni dello stato: verde «In tempo» e «Già raggiunto», arancio delle scritte «In ritardo», rosso «Non ci
        /// arriva», sui fondi tenui del template (`.st2.ok`, `.avv`, `.ko`).
        static let testoStatoOk = Color.dinamico(chiaro: Color(hex: "#1F7A41"), scuro: Color(hex: "#6FD08E"))
        static let fondoStatoOk = Color(r: 47, g: 163, b: 90, a: 0.15)
        static let testoStatoAttenzione = Tema.Apple.Colore.arancioTesto
        static let fondoStatoAttenzione = Color(r: 224, g: 138, b: 0, a: 0.16)
        static let testoStatoErrore = Color.dinamico(chiaro: Color(hex: "#C2333A"), scuro: Color(hex: "#FF8A8F"))
        static let fondoStatoErrore = Color(r: 229, g: 72, b: 77, a: 0.13)

        /// Il posto libero: card trasparente tratteggiata, «＋» 30 e il testo 14 `inchiostro2`.
        static let segnoPostoLibero = Tema.Apple.Carattere(dimensione: 30, peso: .regular)
        static let testoPostoLibero = Tema.Apple.Carattere.corpo
        static let colorePostoLibero = Tema.Apple.Colore.inchiostro2
        static let bordoPostoLibero = Tema.Apple.Colore.inchiostro3
        static let spessorePostoLibero: CGFloat = 1.2
        static let tratteggioPostoLibero: [CGFloat] = [6, 5]
        static let spazioPostoLibero: CGFloat = 4
        /// Con meno di questi obiettivi compare il posto libero.
        static let postiDelTemplate = 3

        /// Sotto la griglia: il «Nuovo obiettivo» (con tre o più obiettivi), gli obiettivi del profilo e i
        /// suggerimenti dagli eventi di vita.
        static let sopraSeguito: CGFloat = Tema.Apple.Misura.Spazio.griglia
        static let sintesi = Tema.Apple.Carattere.secondario
        static let coloreSintesi = Tema.Apple.Colore.inchiostro2
        static let spazioSintesi: CGFloat = 8

        /// Il colore dell'obiettivo secondo l'area: i tre del template (blu, viola, verde) e, per le aree che il
        /// template non ha, i colori delle aree di Analisi 360.
        static func colore(_ area: AreaBisogno) -> Color {
            switch area {
            case .casa: return Tema.Apple.Colore.anello2
            case .pensione: return Tema.Apple.Colore.anello3
            case .famiglia: return Tema.Apple.Colore.anello1
            case .salute: return Tema.Apple.Colore.Area.protezione
            case .lavoro: return Tema.Apple.Colore.arancio
            case .patrimonio: return Tema.Apple.Colore.Composizione.gestioneSeparata
            }
        }
    }

    // MARK: Dettaglio dell'obiettivo (920×520)

    enum DettaglioObiettivo {
        static let misura = Tema.Apple.Misura.DettaglioAperto.obiettivo
        /// `.lbl` nel colore e nome 30 bold.
        static let etichetta = Tema.Apple.Carattere.etichetta
        static let titolo = Tema.Apple.Carattere.titoloDettaglio(30)
        static let coloreTitolo = Tema.Apple.Colore.inchiostro
        /// Fra l'etichetta e il nome, e fra l'etichetta e il valore delle cifre.
        static let spazioTestata: CGFloat = 2
        /// Fra il titolo del dettaglio completo e le sue azioni.
        static let spazioTitoloCompleto: CGFloat = 8
        /// Corpo a 22 sotto il titolo; anello e colonna a 34.
        static let sopraCorpo: CGFloat = 22
        static let spazioAnello: CGFloat = 34
        /// Anello 220/22 con la percentuale 44 e «alla scadenza» sotto: segue il cursore.
        static let anello: CGFloat = 220
        static let spessoreAnello: CGFloat = 22
        static let centroAnello = Tema.Apple.Carattere.centroAnello(44)
        static let coloreCentro = Tema.Apple.Colore.inchiostro
        static let sottoCentro = Tema.Apple.Carattere.secondario
        static let coloreSottoCentro = Tema.Apple.Colore.inchiostro2
        /// «Già messi da parte» e «Obiettivo»: `.k` e `.v` che contano, a 40 l'una dall'altra.
        static let spazioCifre: CGFloat = 40
        static let etichettaCifra = Tema.Apple.Carattere.secondario
        static let coloreEtichetta = Tema.Apple.Colore.inchiostro2
        static let valoreCifra = Tema.Apple.Carattere.valore
        static let coloreValore = Tema.Apple.Colore.inchiostro
        /// «Versamento mensile» 14 a 22; il valore 46 bold nel colore (lo scrive il cursore).
        static let etichettaVersamento = Tema.Apple.Carattere(dimensione: 14, peso: .regular)
        static let sopraVersamento: CGFloat = 22
        static let valoreVersamento = Tema.Apple.Carattere.valoreCursore
        /// Il cursore: da 0 a max(v·2,4; fabbisogno·1,2 arrotondato a 50; 300), passo 10 (§4.9.9).
        static let larghezzaCursore: CGFloat = 440
        static let sopraCursore: CGFloat = 4
        static let passoCursore: Double = 10
        static let minimoCursore: Double = 300
        static let moltiplicatoreCursore: Double = 2.4
        static let margineFabbisogno: Double = 1.2
        static let arrotondamentoFabbisogno: Double = 50
        /// «oltre ai premi delle posizioni collegate» `.k` a 6.
        static let sopraNotaCollegate: CGFloat = 6
        /// «Arriva a <mese anno>» 17 con la data in grassetto, a 12; lo scarto `.k` a 4.
        static let arrivo = Tema.Apple.Carattere(dimensione: 17, peso: .regular)
        static let arrivoForte = Tema.Apple.Carattere(dimensione: 17, peso: .bold)
        static let coloreArrivo = Tema.Apple.Colore.inchiostro
        static let sopraArrivo: CGFloat = 12
        static let scarto = Tema.Apple.Carattere.secondario
        static let coloreScarto = Tema.Apple.Colore.inchiostro2
        static let sopraScarto: CGFloat = 4
        /// «Il dettaglio completo» sotto il cursore: probabilità, traiettoria, posizioni e azioni di Prisma.
        static let sopraCompleto: CGFloat = 30
        static let spazioCompleto: CGFloat = 18
        static let titoloCompleto = Tema.Apple.Carattere.etichetta
        static let coloreTitoloCompleto = Tema.Apple.Colore.inchiostro2
        static let filo = Tema.Apple.Colore.separatore
        /// Piede: «Salva nel dossier» (primario grande), «Annulla» e la nota sul rendimento a 14.
        static let sopraPiede: CGFloat = 14
        /// Il contenuto scorre fino sopra il piede e sfuma per 24 prima dei pulsanti.
        static let sfumaturaPiede: CGFloat = 24
        static let spazioPiede: CGFloat = 8
        static let spazioNota: CGFloat = 14
        static let nota = Tema.Apple.Carattere.secondario
        static let coloreNota = Tema.Apple.Colore.inchiostro2
        /// Migliorie d'uso 13: lo stato che segue il cursore a 12 sotto lo scarto, poi la nota sulla scadenza a 8
        /// (12,5 `inchiostro2`). Sul Mac l'anello mostra la quota di oggi, come la card.
        static let sopraStato: CGFloat = 12
        static let sopraNotaScadenza: CGFloat = 8
        static let notaScadenza = Tema.Apple.Carattere(dimensione: 12.5, peso: .regular)
    }
}

// MARK: - Migliorie d'uso 65: la sezione Note del dossier (Mac)

extension Tema.Apple.Clienti {
    /// La sezione Note del dossier sul Mac (Shell/DossierNote.swift): testata, elenco a sinistra (300) e la nota a destra,
    /// in due card piatte alte quanto la sezione (minimo 420).
    enum NoteDossier {
        typealias K = Tema.Apple.Carattere
        typealias C = Tema.Apple.Colore

        // Testata della sezione
        static let titoloSezione = K.h2
        static let sottotitolo = K.secondario
        static let spazioTestata: CGFloat = 2
        static let spazioBlocchi: CGFloat = 14

        // Griglia `300px 1fr`
        static let larghezzaElenco: CGFloat = 300
        static let altezzaMinima: CGFloat = 420
        static let spazioColonne: CGFloat = Tema.Apple.Misura.Spazio.griglia
        static let superficie = Tema.Apple.Superficie.cardPiatta

        // L'elenco
        static let paddingElenco = Tema.Apple.Misura.padding(8, 8)
        static let spazioRighe: CGFloat = 2
        static let paddingRiga = Tema.Apple.Misura.padding(9, 12)
        static let spazioInRiga: CGFloat = 3
        static let titoloRiga = K(dimensione: 14, peso: .semibold)
        static let anteprimaRiga = K(dimensione: 12.5, peso: .regular)
        static let dataRiga = K(dimensione: 12, peso: .regular, tabellare: true)
        static let stella = K(dimensione: 11, peso: .semibold)
        static let fondoRigaAccesa = C.selezioneVoce
        static let raggioRiga = Tema.Apple.Raggio.voce
        static let paddingVuoto = Tema.Apple.Misura.padding(18, 14)

        // La nota (padding 18×22)
        static let paddingNota = Tema.Apple.Misura.padding(18, 22)
        static let spazioNota: CGFloat = 10
        static let titoloNota = K(dimensione: 22, peso: .bold, tracking: -0.4)
        static let testoNota = K(dimensione: 15, peso: .regular, interlinea: 1.5)
        static let spazioFila: CGFloat = 8
        static let rigaGrigia = K.secondario
        static let filo = C.separatore
        static let spessoreFilo: CGFloat = 1

        // Colori
        static let testo = C.inchiostro
        static let secondario = C.inchiostro2
        static let segnaposto = C.inchiostro3
        /// La stella della nota in evidenza: l'arancio del tema.
        static let coloreStella = C.arancio

        // Lo spazio fra la griglia e i messaggi del dossier
        static let sopraMessaggi: CGFloat = 14
    }
}
