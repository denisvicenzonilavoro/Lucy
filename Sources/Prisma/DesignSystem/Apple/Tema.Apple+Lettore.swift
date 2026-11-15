import SwiftUI

// Migliorie d'uso 62 «Il documento si apre in grande» (Design/uso/gruppo-11.md §62.3 punto 11, template righe 768-781 e
// 4914-4949): misure, caratteri e colori del lettore dei documenti del Mac. A sinistra la pagina (carta, sempre chiara),
// a destra i tre passi («I dati letti», «A cosa è collegato», «Cosa non torna») e il piede con il pulsante solo. Le righe
// da confermare usano i componenti comuni delle conferme (`Tema.Apple.Conferme`). Solo valori: la vista sta in
// Shell/LettoreDocumento.swift.

extension Tema.Apple {
    enum Lettore {
        typealias C = Tema.Apple.Carattere
        typealias K = Tema.Apple.Colore

        // MARK: La scheda

        /// 1220×790 al più, ristretta all'area della finestra dal presentatore del dettaglio.
        static let misura = CGSize(width: 1220, height: 790)
        /// Spazio fra la pagina e i passi.
        static let spazioColonne: CGFloat = 22
        /// Spazio lasciato in alto a destra per il ✕ del dettaglio.
        static let spazioChiudi: CGFloat = 44

        // MARK: La pagina (`.leCarta`)

        /// La colonna della pagina: 470 al minimo, cresce con la finestra fino a `colonnaPaginaMassima`.
        static let colonnaPagina: CGFloat = 470
        static let colonnaPaginaMassima: CGFloat = 560
        /// La quota della larghezza che va alla pagina quando la scheda è larga.
        static let quotaPagina: CGFloat = 0.42
        static let raggioPagina: CGFloat = 20
        static let fondoPagina = K.chip
        /// La riga del dato sotto il puntatore, accesa sul foglio: il giallo del template al 40% (fisso: è sulla carta).
        static let rigaAccesa = Color(hex: "#FFD60A").opacity(0.4)
        /// La capsula «pagina N · data» in basso al centro.
        static let capsulaPagina = C(dimensione: 12, peso: .medium, tabellare: true)
        static let coloreCapsulaPagina = K.inchiostro2
        static let fondoCapsulaPagina = K.cardPiena
        static let paddingCapsulaPagina = Misura.padding(5, 12)
        /// La capsula sta sopra la barra delle pagine dell'anteprima.
        static let sottoCapsulaPagina: CGFloat = 64

        // MARK: La testata dei passi

        static let occhiello = C(dimensione: 12, peso: .semibold, tracking: 0.6, maiuscolo: true)
        static let coloreOcchiello = K.accento
        /// Il nome del documento (24, come il titolo dei dettagli più piccoli).
        static let titolo = C(dimensione: 24, peso: .bold, tracking: -0.5)
        static let coloreTitolo = K.inchiostro
        static let data = C.secondario
        static let coloreData = K.inchiostro2
        static let spazioTestata: CGFloat = 6
        static let sottoTestata: CGFloat = 18

        // MARK: I passi

        /// Il numero tondo del passo: 20, nell'accento.
        static let numeroPasso: CGFloat = 20
        static let carattereNumeroPasso = C(dimensione: 11.5, peso: .bold, tabellare: true)
        static let coloreNumeroPasso = Color.white
        static let fondoNumeroPasso = K.accento
        static let titoloPasso = C(dimensione: 15, peso: .bold)
        static let coloreTitoloPasso = K.inchiostro
        static let spazioTitoloPasso: CGFloat = 10
        static let sottoTitoloPasso: CGFloat = 10
        static let spazioPassi: CGFloat = 22
        static let spazioRighe: CGFloat = 8

        // MARK: Le righe dei dati

        /// Il nome del campo, largo 150.
        static let larghezzaNome: CGFloat = 150
        static let nome = C(dimensione: 13, peso: .medium)
        static let coloreNome = K.inchiostro2
        static let rigaDato = C(dimensione: 14, peso: .regular)
        static let coloreDato = K.inchiostro
        /// Il perché sotto il valore incerto: 12,5 nell'arancio del testo.
        static let perche = C(dimensione: 12.5, peso: .regular)
        static let colorePerche = K.arancioTesto
        static let fonte = C(dimensione: 12, peso: .medium, tabellare: true)
        static let coloreFonte = K.accento
        static let spazioDato: CGFloat = 10
        /// Il campo di testo del valore correggibile sul posto.
        static let paddingCampo = Misura.padding(4, 8)
        static let raggioCampo: CGFloat = 8
        static let fondoCampo = K.cardPiena
        static let bordoCampo = K.separatore
        static let rigaGrigia = C(dimensione: 13, peso: .regular)
        static let coloreRigaGrigia = K.inchiostro3

        // MARK: Cosa non torna

        /// Il riquadro di una differenza (`.leD`): arancio al 10%, bordo arancio al 25%, raggio 14.
        static let fondoDifferenza = K.arancio.opacity(0.10)
        static let bordoDifferenza = K.arancio.opacity(0.25)
        static let fondoDifferenzaDecisa = K.chip
        static let raggioDifferenza: CGFloat = 14
        static let paddingDifferenza = Misura.padding(12, 14)
        static let nomeDifferenza = C(dimensione: 13.5, peso: .semibold)
        static let spiegazione = C(dimensione: 12.5, peso: .regular)
        static let coloreSpiegazione = K.inchiostro2
        /// I due riquadri da toccare: raggio 12, bordo 1,5, padding 8×12.
        static let raggioScelta: CGFloat = 12
        static let bordoScelta: CGFloat = 1.5
        static let paddingScelta = Misura.padding(8, 12)
        static let fondoScelta = K.cardPiena
        static let bordoSceltaSpenta = K.separatore
        /// Quello scelto: bordo verde, fondo verde al 10%.
        static let bordoSceltaAccesa = K.verde
        static let fondoSceltaAccesa = K.verde.opacity(0.10)
        static let etichettaScelta = C(dimensione: 11, peso: .semibold, tracking: 0.4, maiuscolo: true)
        static let coloreEtichettaScelta = K.inchiostro2
        static let valoreScelta = C(dimensione: 14, peso: .semibold, tabellare: true)
        static let coloreValoreScelta = K.inchiostro
        static let spazioScelte: CGFloat = 10
        static let notaPasso = C(dimensione: 12, peso: .regular)
        static let coloreNotaPasso = K.inchiostro3

        // MARK: Il piede

        static let sopraPiede: CGFloat = 14
        static let spazioPiede: CGFloat = 12
        static let notaPiede = C.secondario
        static let coloreNotaPiede = K.inchiostro2

        // MARK: Il testo letto

        static let spazioTesto: CGFloat = 12
    }
}
