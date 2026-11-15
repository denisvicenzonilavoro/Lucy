import SwiftUI

// MARK: - Agenda a vista mensile (con le attività accorpate)
// La griglia del mese riempie lo spazio: in ogni cella il numero, i segni del giorno (attività da fare in arancio,
// scadenze delle posizioni in ambra, anelli delle occasioni) e fino a tre pillole degli appuntamenti con il colore
// del canale. A destra la colonna del giorno scelto: appuntamenti, cose da fare, scadenze, occasioni.

extension Misure {
    enum AgendaMese {
        /// Spazio tra le celle della griglia (in orizzontale e in verticale).
        static let spazioCelle: CGFloat = 3
        /// Riga con i nomi dei giorni sopra la griglia.
        static let testaGiorni: CGFloat = 18
        static let tracciaGiorni: CGFloat = 0.4
        /// Altezza minima di una cella: sotto, la cella mostra solo numero e segni.
        static let cellaMinima: CGFloat = 40
        /// Margini interni della cella.
        static let margineCella = EdgeInsets(top: 4, leading: 5, bottom: 4, trailing: 5)
        /// Raggio della cella (come il giorno del mese di prima).
        static let raggioCella: CGFloat = Tema.Raggio.Dossier.giornoMese
        /// Spessore del bordo del giorno scelto e di oggi.
        static let bordoSelezione: CGFloat = 1.5
        /// I giorni fuori dal mese si attenuano.
        static let opacitaFuoriMese: Double = 0.42
        /// Il numero del giorno di oggi sta in un cerchio rosso, come nel Calendario del Mac.
        static let cerchioOggi: CGFloat = 20
        /// Spazio tra il numero e i segni, e tra i segni.
        static let spazioSegni: CGFloat = 3
        /// Lato dei segni pieni (attività, scadenze).
        static let segno: CGFloat = 6
        /// Fra il segno e il suo numero («● 2»).
        static let spazioConteggio: CGFloat = 1
        /// Pillole degli appuntamenti: altezza (sulla Dimensione del testo), spazio, massimo per cella.
        static var pillola: CGFloat { 16 * Tipo.fattore }
        static let spazioPillole: CGFloat = 2
        static let massimoPillole = 3
        static let marginePillola = EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 3)
        static let raggioPillola: CGFloat = 4
        /// La barretta del canale davanti alla pillola.
        static let segnoPillola: CGFloat = 2.5
        static let rientroSegnoPillola: CGFloat = 3
        static let spazioPillola: CGFloat = 3
        /// Sotto questo spazio per il titolo la pillola mostra solo l'ora; se non sta nemmeno l'ora, un puntino
        /// nel colore del canale (mai testo tagliato a metà).
        static let titoloMinimoPillola: CGFloat = 34
        static let puntinoPillola: CGFloat = 6
        /// Altezza della riga del numero (sulla Dimensione del testo).
        static var testaCella: CGFloat { 20 * Tipo.fattore }

        /// Quante pillole stanno in una cella alta `altezza` (0 se la cella è troppo bassa).
        static func pillole(altezza: CGFloat) -> Int {
            let libero = altezza - margineCella.top - margineCella.bottom - testaCella - spazioPillole
            guard libero > 0 else { return 0 }
            return min(massimoPillole, Int((libero + spazioPillole) / (pillola + spazioPillole)))
        }

        // Colonna del giorno
        /// Testa della colonna: tessera della data, giorno e conteggi.
        static let testaGiorno = EdgeInsets(top: 12, leading: 16, bottom: 10, trailing: 16)
        static let spazioTesta: CGFloat = 12
        static let spazioTestaRighe: CGFloat = 3
        /// Occhielli delle sezioni («APPUNTAMENTI», «DA FARE», «IN SCADENZA»).
        static let occhiello = EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16)
        static let tracciaOcchiello: CGFloat = 1.2
        /// Riga «‹ giorno» sopra il dettaglio aperto nella colonna.
        static let ritorno = EdgeInsets(top: 9, leading: 14, bottom: 5, trailing: 14)
        /// Margini del dettaglio aperto nella colonna del mese (sotto la riga del ritorno).
        static let margineDettaglio = EdgeInsets(top: 4, leading: 15, bottom: 10, trailing: 15)
        /// Il pulsante «Attività» accanto ad «Incontro» nella pagina vuota.
        static let spazioPulsantiVuoto: CGFloat = 8

        // Riepilogo delle attività nella fascia in testa
        static let spazioRiepilogo: CGFloat = 8
        static let puntoRiepilogo: CGFloat = 6

        // MARK: Migliorie d'uso 50 (solo Mac): il mese a tutta larghezza
        // La griglia prende tutta la larghezza meno la colonna del giorno (304, a 14 dalla griglia); sotto la pagina
        // minima la colonna si stringe fino a 260 prima di comprimere la griglia.

        /// La colonna del giorno a destra della griglia e lo spazio fra le due.
        static let colonnaGiorno: CGFloat = 304
        static let colonnaGiornoMinima: CGFloat = 260
        static let spazioColonna: CGFloat = 14
        /// Al più due impegni per cella (uno solo se nel giorno c'è una scadenza).
        static let pilloleMassime = RegoleMeseAgenda.pilloleMassime
        /// L'anello d'accento del giorno scelto.
        static let anelloScelto: CGFloat = 2
        /// Testata dei giorni («LUN … DOM»), alta 26, con i nomi a 10 dal bordo della colonna.
        static let testaGiorniUso: CGFloat = 26
        static let rientroNomeGiorno: CGFloat = 10
        /// Le celle: 6 di spazio, raggio 14, padding 7 × 8, 3 fra le righe.
        static let spazioCelleUso: CGFloat = 6
        static let raggioCellaUso: CGFloat = 14
        static let margineCellaUso = EdgeInsets(top: 7, leading: 8, bottom: 7, trailing: 8)
        static let spazioRigheCella: CGFloat = 3
        /// Il numero del giorno in un tondo di 22 (oggi rosso pieno).
        static let cerchioNumero: CGFloat = 22
        /// Una riga della cella (pillola, scadenza, «+N altri»), sulla Dimensione del testo.
        static var rigaCella: CGFloat { 18 * Tipo.fattore }
        /// La pillola: filo sinistro di 3 nel colore del canale, raggio 5, padding 2 × 6, 5 fra l'ora e il nome.
        static let filoPillola: CGFloat = 3
        static let raggioPillolaUso: CGFloat = 5
        static let marginePillolaUso = EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
        static let spazioOraPillola: CGFloat = 5
        /// La scadenza: pallino di 6 a 2 dal bordo, il testo a 6 dal pallino.
        static let pallinoScadenza: CGFloat = 6
        static let rientroScadenza: CGFloat = 2
        static let spazioScadenza: CGFloat = 4

        /// Quante righe (pillole, scadenze, «+N») stanno in una cella alta `altezza` (0: solo numero e segni).
        static func righeCella(altezza: CGFloat) -> Int {
            let libero = altezza - margineCellaUso.top - margineCellaUso.bottom - cerchioNumero
            guard libero > rigaCella else { return 0 }
            return Int(libero / (rigaCella + spazioRigheCella))
        }

        /// La larghezza della colonna del giorno per la larghezza disponibile: 304 finché la griglia resta larga almeno
        /// la pagina minima, poi si stringe fino a 260.
        static func larghezzaColonna(_ totale: CGFloat) -> CGFloat {
            let minima = Misure.AgendaImpaginazione.paginaMinima
            guard totale - colonnaGiorno - spazioColonna < minima else { return colonnaGiorno }
            return min(colonnaGiorno, max(colonnaGiornoMinima, totale - spazioColonna - minima))
        }

        // La colonna del giorno (card piatta, padding 18 × 20)
        static let paddingColonna = EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20)
        static let spazioTitoloColonna: CGFloat = 2
        static let sopraRighe: CGFloat = 12
        static let spazioRigheColonna: CGFloat = 6
        /// Una riga: padding 9 8 9 10, 10 fra l'ora (larga 44) e il titolo, raggio 4 a sinistra e 10 a destra.
        static let paddingRiga = EdgeInsets(top: 9, leading: 10, bottom: 9, trailing: 8)
        static let spazioRiga: CGFloat = 10
        static let colonnaOraRiga: CGFloat = 44
        static let raggioRigaSinistra: CGFloat = 4
        static let raggioRigaDestra: CGFloat = 10
        static let spazioTitoloRiga: CGFloat = 1
        /// «Giornata libera»: 26 sopra e sotto.
        static let vuotoVerticale: CGFloat = 26
        static let spazioVuoto: CGFloat = 2
        /// Le attività del giorno sotto gli impegni (decisione 50-b): l'occhiello a 10 sopra.
        static let sopraAttivita: CGFloat = 10
        /// I pulsanti a 10 sotto le righe, 8 fra l'uno e l'altro.
        static let sopraPulsanti: CGFloat = 10
        static let spazioPulsanti: CGFloat = 8
        /// La legenda a 12 sotto i pulsanti, sopra un filo con 10 di respiro; quadratini di 9 (raggio 3).
        static let sopraLegenda: CGFloat = 12
        static let paddingLegenda: CGFloat = 10
        static let spazioLegenda: CGFloat = 12
        static let spazioVoceLegenda: CGFloat = 5
        static let spazioQuadratini: CGFloat = 2
        static let quadratinoLegenda: CGFloat = 9
        static let raggioQuadratino: CGFloat = 3
        /// Il cambio di giorno: la colonna entra da destra di 8 con l'opacità da 0,4.
        static let entrataGiorno: CGFloat = 8
        static let opacitaEntrataGiorno: Double = 0.4
    }
}

extension Colori.Agenda {
    #if os(macOS)
    /// Migliorie d'uso 50: sabato e domenica nel mese con il fondo dei pannelli (--panel).
    static let festivo = Tema.Apple.Agenda.MeseUso.fondoFestivo
    #endif
    /// Celle del mese: passaggio del puntatore, giorno scelto (accento), bordo.
    static let cellaPassaggio = Tema.Colore.rigaSopra
    static let cellaSelezione = Tema.Colore.selezione
    static let cellaSelezioneBordo = Tema.Colore.accento
    static let cellaBordo = Tema.Colore.separatore
    static let numeroCella = Tema.Colore.inchiostro
    static let numeroOggi = Tema.Colore.Componenti.testoSuColore
    static let cerchioOggi = Tema.Colore.rosso
    /// Segni del giorno: arancio per le attività da fare, ambra per le scadenze delle posizioni.
    static let segnoAttivita = Tema.Colore.arancio
    static let segnoAttivitaScaduta = Tema.Colore.scadenzaOra
    static let segnoScadenza = Colori.Agenda.scadenzaTesto
    static let conteggioSegno = Tema.Colore.inchiostroSecondario
    /// Pillole degli appuntamenti: colore del canale (Alleanza blu, indipendente cuoio), neutro se manca.
    static let pillolaNeutra = Tema.Colore.inchiostroSecondario
    static func pillola(_ c: Canale?) -> Color { c.map { Tema.Colore.canale($0) } ?? pillolaNeutra }
    static func pillolaFondo(_ c: Canale?) -> Color { c.map { Tema.Colore.fondoCanale($0) } ?? Tema.Colore.rigaSopra }
    static let pillolaTesto = Tema.Colore.inchiostro
    static let pillolaOra = Tema.Colore.inchiostroSecondario
    static let pillolaConclusa = Tema.Colore.inchiostroTerziario
    static let altriAppuntamenti = Tema.Colore.inchiostroSecondario
    /// Occhielli della colonna del giorno.
    static let occhielloAppuntamenti = Colori.Agenda.paginaOcchiello
    static let occhielloDaFare = Tema.Colore.scadenzaVicina
    static let occhielloIndietro = Tema.Colore.scadenzaOra
    static let testaGiornoTitolo = Tema.Colore.inchiostro
    static let testaGiornoNota = Tema.Colore.inchiostroSecondario
    /// Riepilogo delle attività nella fascia.
    static let riepilogo = Tema.Colore.inchiostroSecondario
    static let riepilogoForte = Tema.Colore.inchiostro
    static let riepilogoScadute = Tema.Colore.scadenzaOra
}

extension Tipo {
    /// Numero del giorno nella cella del mese (oggi più marcato, nel cerchio rosso).
    static let cellaMeseOggi = contenuto(13, .semibold)
    /// Pillole degli appuntamenti nelle celle.
    static let pillolaOra = contenuto(10, .semibold)
    static let pillolaTitolo = contenuto(10)
    /// «+2» sotto le pillole e il numero accanto ai segni.
    static let altriAppuntamenti = contenuto(10, .medium)
    static let conteggioSegno = fisso(9, .semibold)
    /// Testa della colonna del giorno.
    static let testaGiornoTitolo = serif(18)
    static let testaGiornoNota = contenuto(11)
    /// Riepilogo delle attività nella fascia.
    static let riepilogoAttivita = contenuto(11)
    static let riepilogoAttivitaForte = contenuto(11, .semibold)
}
