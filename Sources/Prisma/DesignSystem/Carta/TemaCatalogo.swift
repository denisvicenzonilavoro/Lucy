import SwiftUI

// Le misure e i caratteri del foglio «Dal catalogo delle compagnie» (Posizioni, 25 novembre 2026): la testata, i campi
// e il piede sono quelli dei moduli su carta (`TemaCarta.Modulo`); qui solo ciò che il foglio aggiunge (il costo vero in
// grande, le righe dello scontrino che si aprono, il badge del livello, le penali anno per anno).

extension TemaCarta {
    enum Catalogo {
        /// La misura del foglio: più largo di un modulo, la scheda ha lo scontrino accanto ai campi.
        static let misura = CGSize(width: 760, height: 760)
        /// Il costo vero: New York 40 a contachilometri; «dato non disponibile» più piccolo, in corsivo.
        static let costo = TestoCarta(dimensione: 40, peso: .medium, disegno: .serif, cifre: true)
        static let costoMancante = TestoCarta(dimensione: 18, corsivo: true)
        static let titoloCosto = TestoCarta(dimensione: 10.5, peso: .medium, disegno: .monospaced)
        /// Il nome del prodotto nella testata e nelle righe dell'elenco.
        static let nomeRiga = TestoCarta(dimensione: 14, peso: .medium)
        static let notaRiga = TestoCarta(dimensione: 11.5)
        /// I passi di «tocca e capisci» in blu stilografica, il testo originale delle celle in corsivo.
        static let passo = TestoCarta(dimensione: 12.5)
        static let originale = TestoCarta(dimensione: 12, corsivo: true)
        /// Il testo delle sezioni (garanzie, esclusioni…), così com'è nel catalogo.
        static let testoSezione = TestoCarta(dimensione: 13)
        /// Il badge del livello di dettaglio.
        static let badge = TestoCarta(dimensione: 10.5, peso: .semibold, disegno: .monospaced)
        static let paddingBadge = EdgeInsets(top: 4, leading: 9, bottom: 4, trailing: 9)
        /// Le righe dell'elenco dei prodotti e le righe dei passi.
        static let paddingRiga = EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12)
        static let rientroPassi: CGFloat = 14
        static let spazioPassi: CGFloat = 4
        static let spazioRighe: CGFloat = 6
        /// I campi d'ingresso: larghezza di una casella numerica.
        static let campoNumero: CGFloat = 150
        /// La colonna delle etichette nelle sezioni di testo e nelle penali.
        static let colonnaEtichetta: CGFloat = 170
        /// La larghezza della scelta della compagnia.
        static let sceltaCompagnia: CGFloat = 230
    }
}
