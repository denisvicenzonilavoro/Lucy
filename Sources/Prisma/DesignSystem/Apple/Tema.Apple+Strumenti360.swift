import SwiftUI

// Gettoni degli strumenti di Analisi 360 nel tema Apple: Simulatore, Scenari, Confronto e TFR
// (Design/template-apple-specifica.md §4.3: «Nel template mancano TFR, scenari e confronto… vanno resi nello
// stesso linguaggio»). Contenuti e calcoli restano quelli di sempre (MotoreProiezione, MotoreTFR): qui solo
// caratteri, colori e superfici del tema Apple. I componenti condivisi (comandi della console, tabelle, note,
// titoli, legende, segmenti) li chiedono con `.strumentiApple()` (StrumentiApple.swift).
// Nessun colore nuovo: alias del tema Apple; i colori delle serie dei grafici restano quelli di oggi.

extension Tema.Apple {
    enum Strumenti360 {
        // MARK: Testata del contenuto (spia, titolo, nota)
        static let titoloTestata = Carattere.barraTitolo
        static let coloreTitoloTestata = Colore.inchiostro
        static let notaTestata = Carattere(dimensione: 11.5, peso: .regular)
        static let coloreNotaTestata = Colore.inchiostro2
        static let spia = Colore.verde
        /// Il segmentato a pillola «Ognuno il suo | Comune» dell'orizzonte del confronto (le due voci intere).
        static let segmentiOrizzonte: CGFloat = 250
        /// Il testo dell'orizzonte del confronto accanto allo Stepper.
        static let testoStepper = Carattere(dimensione: 13, peso: .semibold, tabellare: true)

        // MARK: La cifra principale (simulatore, confronto, TFR)
        static let occhiello = Carattere.etichetta
        static let coloreOcchiello = Colore.inchiostro2
        /// 44 bold come il valore del cursore dei dettagli di Analisi 360 (§4.3.2).
        static let cifra = Carattere.valoreCursoreAnalisi
        static let coloreCifra = Colore.inchiostro
        static let nota = Carattere.secondario
        static let coloreNota = Colore.inchiostro2
        static let positivo = Colore.verde
        static let negativo = Colore.rosso
        /// Il simbolo del confronto vuoto («⇄»).
        static let simboloVuoto = Carattere.valoreCursoreAnalisi
        static let coloreSimboloVuoto = Colore.inchiostro3
        static let titoloVuoto = Carattere.titoloFinestra
        static let testoVuoto = Carattere.corpo
        static let larghezzaTestoVuoto: CGFloat = 460
        static let spazioVuoto: CGFloat = 10

        // MARK: I dettagli sotto la cifra del simulatore
        static let riquadroDettagli = Superficie.tile
        static let etichettaDettaglio = Carattere.secondario
        static let coloreEtichettaDettaglio = Colore.inchiostro2
        static let valoreDettaglio = Carattere(dimensione: 17, peso: .semibold, tracking: -0.2, tabellare: true)
        static let coloreValoreDettaglio = Colore.inchiostro
        static let notaDettaglio = Carattere(dimensione: 11.5, peso: .regular)
        static let filoDettagli = Colore.separatore
        static let spazioRisultato: CGFloat = 14
        static let spazioCifra: CGFloat = 4
        static let spazioDettaglio: CGFloat = 3
        static let margineDettaglio: CGFloat = 10
        static let margineFiloDettaglio: CGFloat = 8
        /// La riga delle ipotesi sotto i risultati (sempre scritta).
        static let ipotesi = Carattere.secondario
        static let coloreIpotesi = Colore.inchiostro2

        // MARK: I comandi della console (etichetta, valore, cursore)
        static let etichettaComando = Carattere.corpo
        static let coloreEtichettaComando = Colore.inchiostro
        static let valoreComando = Carattere(dimensione: 15, peso: .semibold, tabellare: true)
        static let coloreValoreComando = Colore.inchiostro
        static let unitaComando = Carattere(dimensione: 12, peso: .regular)
        static let coloreUnitaComando = Colore.inchiostro2
        static let fondoValore = Colore.chip
        static let raggioValore = Raggio.barra
        static let spazioComando: CGFloat = 4
        static let spazioEtichettaComando: CGFloat = 6
        static let spazioUnita: CGFloat = 4
        static let margineValore: CGFloat = 10
        /// Titolo dei gruppi della console (Lavoratore, Fondo, Fisco) e delle scelte.
        static let gruppo = Carattere.etichetta
        static let coloreGruppo = Colore.inchiostro2
        static let etichettaScelta = Carattere.secondario
        static let coloreEtichettaScelta = Colore.inchiostro2
        static let filo = Colore.separatore

        // MARK: Tabelle
        static let tabella = Superficie.cardPiatta
        static let raggioTabella = Raggio.tile
        static let testaTabella = Carattere(dimensione: 11.5, peso: .semibold)
        static let coloreTesta = Colore.inchiostro2
        static let cella = Carattere(dimensione: 13, peso: .regular)
        static let cellaForte = Carattere(dimensione: 13, peso: .semibold)
        static let cellaNumero = Carattere(dimensione: 13, peso: .regular, tabellare: true)
        static let cellaNumeroForte = Carattere(dimensione: 13, peso: .semibold, tabellare: true)
        static let cellaNota = Carattere(dimensione: 11, peso: .regular)
        static let coloreCella = Colore.inchiostro
        static let coloreCellaNota = Colore.inchiostro2
        static let filoTabella = Colore.separatore
        static let rigaSopra = Colore.chip
        static let raggioRiga = Raggio.bollaPiccola
        /// La casella «metti a confronto» degli scenari.
        static let coloreScelto = Colore.accento
        static let coloreNonScelto = Colore.inchiostro3
        /// La colonna di «Carica» ed «Elimina» negli scenari (due pulsanti del tema Apple, 12,5 con padding 7×14).
        static let colonnaAzioniScenari: CGFloat = 176

        // MARK: Titoli di pagina, note sul metodo, legende
        static let occhielloPagina = Carattere.sottotitolo
        static let coloreOcchielloPagina = Colore.inchiostro2
        static let titoloPagina = Carattere.h2
        static let coloreTitoloPagina = Colore.inchiostro
        static let testoPagina = Carattere.corpo
        static let coloreTestoPagina = Colore.inchiostro2
        static let spazioTitoloPagina: CGFloat = 3
        static let titoloNota = Carattere(dimensione: 12.5, peso: .semibold)
        static let coloreTitoloNota = Colore.inchiostro
        static let testoNota = Carattere(dimensione: 12.5, peso: .regular, interlinea: 1.45)
        static let coloreTestoNota = Colore.inchiostro2
        static let fondoNota = Colore.chip
        static let raggioNota = Raggio.voce
        static let paddingNota = Misura.padding(12, 14)
        static let spazioNota: CGFloat = 5
        static let legenda = Carattere(dimensione: 12, peso: .regular)
        static let coloreLegenda = Colore.inchiostro2

        // MARK: Le schede A e B del confronto e il riquadro della differenza
        static let schedaVoce = Superficie.tile
        static let riquadroVerdetto = Superficie.cardPiatta
        static let lettera = Carattere(dimensione: 12, peso: .bold)
        static let coloreLettera = Color.white
        static let latoLettera: CGFloat = 22
        static let titoloVoce = Carattere(dimensione: 15, peso: .bold, tracking: -0.2)
        static let coloreTitoloVoce = Colore.inchiostro
        static let sottotitoloVoce = Carattere.secondario
        static let coloreSottotitoloVoce = Colore.inchiostro2
        static let costo = Carattere.delta
        static let coloreCosto = Colore.inchiostro
        /// La barretta del colore della voce dentro il bordo sinistro della scheda.
        static let barretta: CGFloat = 4
        static let margineBarretta: CGFloat = 12
        static let staccoBarretta: CGFloat = 6
        static let paddingScheda = EdgeInsets(top: 12, leading: 18, bottom: 12, trailing: 12)
        static let spazioScheda: CGFloat = 8
        static let spazioTitoloScheda: CGFloat = 1
    }

    /// Migliorie d'uso 64 «Simula e confronta: prima la frase» (Shell/SimulaConfronta.swift): misure e caratteri del
    /// template (righe 5024-5064); colori quelli che il tema ha già (serie dei confronti, accento, verde, arancio).
    enum SimulaConfronta {
        // MARK: Colonna di sinistra
        static let larghezzaColonna: CGFloat = 372
        static let paddingColonna = Misura.padding(18, 20)
        static let spazioBlocchi: CGFloat = 12
        static let spazioOcchiello: CGFloat = 6
        static let occhiello = Carattere.etichetta
        static let coloreOcchiello = Colore.inchiostro2
        static let filo = Colore.separatore
        /// La riga della strada: tondino col colore e la lettera, nome, provenienza, freccia.
        static let tondinoStrada: CGFloat = 22
        static let letteraStrada = Carattere(dimensione: 11, peso: .bold)
        static let coloreLettera = Color.white
        static let nomeStrada = Carattere(dimensione: 14, peso: .semibold)
        static let rigaStrada = Carattere(dimensione: 12, peso: .regular)
        static let coloreNomeStrada = Colore.inchiostro
        static let coloreRigaStrada = Colore.inchiostro2
        static let frecciaStrada = Carattere(dimensione: 11, peso: .semibold)
        static let fondoStrada = Colore.chip
        static let raggioStrada = Raggio.voce
        static let paddingStrada = Misura.padding(9, 12)
        static let spazioStrada: CGFloat = 10
        /// Il menu delle strade (popover).
        static let larghezzaMenu: CGFloat = 380
        static let altezzaMenu: CGFloat = 420
        static let paddingMenu = Misura.padding(10, 12)
        static let gruppoMenu = Carattere.sottotitolo
        static let voceMenu = Carattere(dimensione: 13, peso: .medium)
        static let provenienzaMenu = Carattere(dimensione: 12, peso: .regular)
        static let paddingVoceMenu = Misura.padding(6, 8)
        static let fondoVoceScelta = Colore.chip
        static let larghezzaEditor: CGFloat = 320
        /// La riga delle ipotesi in grigio sotto i cursori.
        static let rigaIpotesi = Carattere.secondario
        static let coloreRigaIpotesi = Colore.inchiostro2

        // MARK: La frase
        static let superficie = Superficie.cardPiatta
        static let riquadro = Superficie.tile
        static let paddingFrase = Misura.padding(18, 22)
        static let paddingRiquadro = Misura.Padding.tile
        static let fraseUna = Carattere(dimensione: 23, peso: .bold, tracking: -0.4, interlinea: 1.3)
        static let fraseDue = Carattere(dimensione: 21, peso: .bold, interlinea: 1.35)
        static let sottoFrase = Carattere(dimensione: 14.5, peso: .regular, interlinea: 1.5)
        static let coloreFrase = Colore.inchiostro
        static let coloreSottoFrase = Colore.inchiostro2
        static let cifraFrase = Colore.accento
        static let differenzaFrase = Colore.verde
        static let spazioFrase: CGFloat = 6

        // MARK: Se va diversamente, grafico, tabella
        static let larghezzaSeVa: CGFloat = 300
        static let barraSeVa: CGFloat = 8
        static let spazioSeVa: CGFloat = 10
        static let nomeSeVa = Carattere(dimensione: 13, peso: .semibold)
        static let notaSeVa = Carattere(dimensione: 12, peso: .regular)
        static let cifraSeVa = Carattere(dimensione: 13, peso: .semibold, tabellare: true)
        static let binario = Colore.binario
        static let male = Colore.arancio
        static let previsto = Colore.accento
        static let bene = Colore.verde
        static let assi = Carattere(dimensione: 11.5, peso: .regular)
        static let coloreAssi = Colore.inchiostro2
        /// Le tre colonne della tabella: etichetta (resto), A e B.
        static let colonnaTabella: CGFloat = 130
        static let testaTabella = Carattere(dimensione: 11.5, peso: .semibold)
        static let cellaTabella = Carattere(dimensione: 13, peso: .regular)
        static let cifraTabella = Carattere(dimensione: 13, peso: .semibold, tabellare: true)
        static let coloreCella = Colore.inchiostro
        static let coloreCellaNota = Colore.inchiostro2
        static let spunta = Colore.verde
        static let spazioTabella: CGFloat = 9

        // MARK: Fila e ipotesi salvate
        static let chip = Carattere(dimensione: 12, peso: .medium)
        static let coloreChip = Colore.inchiostro
        static let fondoChip = Colore.chip
        static let paddingChip = Misura.padding(5, 10)
        static let massimoChip = 6
        static let notaFila = Carattere.secondario
        static let coloreNotaFila = Colore.inchiostro2

        /// I colori delle due strade: quelli delle serie dei confronti (A accento, B viola).
        static var serieA: Color { Colori.Strumenti.serie[0] }
        static var serieB: Color { Colori.Strumenti.serie[1] }
        static var versato: Color { Colori.Analisi.lineaTratteggiata }
    }

    /// Gettoni del TFR (Analisi 360 › TFR) nel tema Apple: solo superfici e caratteri, il resto com'è.
    enum ConfrontoTFR {
        static let occhiello = Carattere.etichetta
        static let coloreOcchiello = Colore.inchiostro2
        static let cifra = Carattere.valoreCursoreAnalisi
        static let notaCifra = Carattere.secondario
        static let testo = Carattere.corpo
        static let nota = Carattere.secondario
        static let fondo = Carattere.secondario
        static let pareggio = Carattere.corpo
        static let notaComando = Carattere(dimensione: 11.5, peso: .regular)
        static let etichettaSezione = Carattere.secondario
        static let coloreTesto = Colore.inchiostro
        static let coloreNota = Colore.inchiostro2
        static let avviso = Colore.arancioTesto
        static let positivo = Colore.verde
        static let negativo = Colore.rosso
        // Barre affiancate delle strade
        static let etichettaBarra = Carattere(dimensione: 13, peso: .regular)
        static let cifraBarra = Carattere(dimensione: 13, peso: .semibold, tabellare: true)
        static let differenzaBarra = Carattere(dimensione: 11.5, peso: .semibold, tabellare: true)
        static let legendaBarre = Carattere(dimensione: 12, peso: .regular)
        static let zero = Colore.separatore
        static let binario = Colore.binario
        // Tessere sotto le barre
        static let tessera = Superficie.tile
        static let raggioTessera = Raggio.tile
        static let paddingTessera = Misura.Padding.tile
        static let titoloTessera = Carattere.secondario
        static let valoreTessera = SuperficiAnalisi.valoreTessera
        static let notaTessera = Carattere(dimensione: 12, peso: .regular)
        static let etichettaAliquota = Carattere(dimensione: 11, peso: .regular)

        /// Il colore di una differenza: verde se il fondo è avanti, rosso se è indietro, inchiostro se pari.
        static func segno(_ v: Double) -> Color {
            if v > TestiTFR.sogliaEquivalenza { return positivo }
            if v < -TestiTFR.sogliaEquivalenza { return negativo }
            return coloreTesto
        }

        /// Il fondo della capsula della differenza e la tinta della tessera del vantaggio.
        static func fondoDifferenza(_ v: Double) -> Color { segno(v).opacity(Tema.Misura.TFR.opacitaDifferenza) }
        static func tintaVantaggio(_ v: Double) -> Color { segno(v).opacity(Tema.Misura.TFR.opacitaVantaggio) }
    }
}
