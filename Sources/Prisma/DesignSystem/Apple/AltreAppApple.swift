import SwiftUI

// Le app che il template non disegna (Incontri, Prodotti, Note, Ricerca, Documenti, Attività) nel tema Apple
// (Design/template-apple-specifica.md §5.1: «vanno restilizzate con i token Apple senza perderle»).
// `.altreAppApple()` accende `.superficiApple()` (pannelli, indicatori, etichetta del canale `.chA` / `.chI`) e
// chiede ai componenti condivisi di sempre lo stile del tema Apple: i pulsanti `StileVetro` e `StileBlu`
// diventano `StilePulsanteApple` (secondario e principale), `StileCollegamento` è il testo blu del tema,
// `MenuTendina` è la capsula del pulsante secondario. Le altre app che usano gli stessi componenti restano com'erano.
// Gettoni qui sotto, in `Tema.Apple.AltreApp`.

private struct ChiaveAltreAppApple: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// true: i componenti condivisi di sempre (pulsanti, collegamenti, menu a tendina) nel tema Apple.
    var altreAppApple: Bool {
        get { self[ChiaveAltreAppApple.self] }
        set { self[ChiaveAltreAppApple.self] = newValue }
    }
}

extension View {
    /// Questa app nel tema Apple: pannelli, indicatori ed etichette del canale, pulsanti, collegamenti e tendine.
    func altreAppApple(_ attive: Bool = true) -> some View {
        environment(\.altreAppApple, attive)
            .superficiApple(attive)
    }

    /// Una scheda delle altre app: card piatta del tema (raggio 22 o quello dato), contenuto tagliato alla forma.
    func schedaAltreAppApple(raggio: CGFloat = Tema.Apple.Raggio.card) -> some View {
        clipShape(RoundedRectangle(cornerRadius: raggio, style: .continuous))
            .superficieApple(Tema.Apple.AltreApp.scheda, raggio: raggio)
    }

    /// Una barra laterale delle altre app (`.side`): pannello del tema, raggio 20.
    func pannelloAltreAppApple() -> some View {
        clipShape(RoundedRectangle(cornerRadius: Tema.Apple.Raggio.pannello, style: .continuous))
            .superficieApple(Tema.Apple.Superficie.pannello)
    }

    /// Un pozzetto (campi, gettoni, righe evidenziate) nel colore `chip` del tema, con il raggio dato.
    func pozzettoAltreAppApple(raggio: CGFloat = Tema.Apple.Raggio.giorno) -> some View {
        background {
            RoundedRectangle(cornerRadius: raggio, style: .continuous)
                .fill(Tema.Apple.Colore.chip)
        }
    }
}

extension Tema.Apple.Carattere {
    /// Il gradino come `Font` che segue la «Dimensione del testo» dei caratteri di sempre (`Tema.Testo.sf`):
    /// per i gettoni `Font` delle altre app, che non passano da `.carattereApple(_:)`.
    var fontLeggibile: Font {
        let f = Tema.Testo.sf(dimensione, peso)
        return tabellare ? f.monospacedDigit() : f
    }
}

extension Tema.Apple {
    /// Gettoni delle app che il template non disegna. Tutti ricavati dal tema Apple.
    enum AltreApp {
        /// Le schede: card piatta (le app non hanno ombre sulle card, §1.3).
        static let scheda = Superficie.cardPiatta
        static let raggioScheda = Raggio.card
        static let raggioTile = Raggio.tile
        static let raggioVoce = Raggio.voce
        static let raggioPozzetto = Raggio.giorno
        /// Inclinazione delle schede principali (§2.6): le grandi (testate larghe) 3°, le altre 5°.
        static let inclinazioneGrande = Moto.Inclinazione.massimoImpegni
        static let inclinazioneScheda = Moto.Inclinazione.massimoAree
        /// Voce scelta negli elenchi (rubrica, note, prodotti, risultati della ricerca).
        static let selezione = Colore.selezioneVoce
        /// Passaggio del puntatore su una voce.
        static let sopra = Colore.chip

        // Caratteri: i gradini della scala del tema Apple per i ruoli di queste app
        /// Il nome grande in testa (cliente di un incontro, prodotto, nota): come il nome del dossier.
        static let titoloGrande = Carattere.nomeDossier
        /// Titolo di una scheda o di una sezione.
        static let titoloScheda = Carattere(dimensione: 17, peso: .bold, tracking: -0.3)
        /// Titolo di una voce d'elenco.
        static let titoloVoce = Carattere(dimensione: 14, peso: .semibold)
        /// Testo corrente.
        static let corpo = Carattere.corpo
        /// Testo corrente compatto (elenchi, tabelle, pannelli dei dati).
        static let corpoPiccolo = Carattere(dimensione: 13, peso: .regular)
        /// Titolo di una riga d'elenco compatta.
        static let titoloRiga = Carattere(dimensione: 13.5, peso: .semibold)
        /// Etichetta breve in grassetto (non in maiuscolo).
        static let etichettaPiccola = Carattere(dimensione: 12, peso: .semibold)
        /// Testo secondario (`.k`).
        static let secondario = Carattere.secondario
        /// Occhielli in maiuscolo (`.lbl`).
        static let occhiello = Carattere.etichetta
        /// Cifre chiave.
        static let cifra = Carattere.valore
        /// Cifre piccole nelle tessere.
        static let cifraPiccola = Carattere(dimensione: 22, peso: .bold, tracking: -0.4, tabellare: true)
        /// Note di contorno (piedi, conteggi).
        static let nota = Carattere(dimensione: 12, peso: .regular)
        /// Stati vuoti: il simbolo grande e la frase (come «Ciao, sono Vera.»).
        static let simboloVuoto = Carattere(dimensione: 34, peso: .light)
        static let titoloVuoto = Carattere.titoloGruppo
        /// Collegamenti («Apri ↗», «Mostra tutto»).
        static let collegamento = Carattere.pulsante

        /// Il colore del canale (testo e pallino delle versioni compatte): blu Alleanza, cuoio indipendente.
        static func canale(_ c: Canale) -> Color {
            c == .alleanza ? Colore.canaleAlleanza : Colore.canaleIndipendente
        }

        // Colori
        static let testo = Colore.inchiostro
        static let testoSecondario = Colore.inchiostro2
        static let testoTerziario = Colore.inchiostro3
        static let accento = Colore.accento
        static let separatore = Colore.separatore
        /// Fondo verde chiaro (passo fatto, dati confermati): il verde al 14%, come i fondi dei canali.
        static let alfaFondoVerde: Double = 0.14

        /// Attività (app su iPad, dettaglio nell'Agenda del Mac): caratteri dei ruoli.
        enum Attivita {
            static let titoloApp = Carattere.h2
            static let numero = AltreApp.cifraPiccola
            static let etichettaNumero = Carattere.secondario
            static let titoloRiga = Carattere(dimensione: 14, peso: .semibold)
            static let sottoRiga = Carattere(dimensione: 12, peso: .regular)
            static let occhiello = Carattere.etichetta
            static let titoloDettaglio = Carattere.titoloDettaglio(26)
            static let valore = Carattere.corpo
            static let etichettaVoce = Carattere.secondario
            /// Spessore del cerchio vuoto della spunta.
            static let trattoSpunta: CGFloat = 1.5
            /// Spaziatura delle lettere degli occhielli.
            static let trackingOcchiello = Carattere.etichetta.tracking
        }

        /// Barre laterali (`.side`): voci, sezioni e contatori.
        enum Laterale {
            static let voce = Carattere(dimensione: 13.5, peso: .medium)
            static let voceScelta = Carattere(dimensione: 13.5, peso: .semibold)
            static let testo = Colore.inchiostro
            static let raggioVoce = Raggio.voce
            static let selezione = Colore.selezioneVoce
            static let sopra = Colore.chip
            static let conteggio = Carattere(dimensione: 11, peso: .semibold, tabellare: true)
            static let testoConteggio = Colore.inchiostro2
            static let fondoConteggio = Colore.chip
            static let sezione = Carattere.etichetta
            static let testoSezione = Colore.inchiostro2
            /// Titolo («Dossier di», nome del cliente) e piede («Archivio locale»).
            static let occhielloDossier = Carattere.sottotitolo
            static let nomeDossier = Carattere(dimensione: 15, peso: .bold)
            static let notaDossier = Carattere.secondario
            /// Spazio fra la barra laterale e il contenuto (come la rubrica di Clienti).
            static let spazio: CGFloat = 16
        }

        /// Barra di stato in fondo alle app con la cornice: spia verde, testo `.k`.
        enum BarraStato {
            static let spia = Colore.verde
            static let carattere = Carattere(dimensione: 12, peso: .regular)
            static let testo = Colore.inchiostro2
        }

        /// Menu a tendina: capsula del pulsante secondario (`cardPiena` con il bordo), freccia `inchiostro2`.
        enum Tendina {
            static let fondo = Colore.cardPiena
            static let bordo = Colore.separatore
            static let testo = Colore.inchiostro
            static let freccia = Colore.inchiostro2
            static let carattere = Carattere.pulsante
            static let carattereFreccia = Carattere(dimensione: 9, peso: .semibold)
        }

        /// Pannello della ricerca (§4.8): vetro con raggio 22. Il vetro è quello della finestra (`#win`, più
        /// coprente di `.glass`): sopra la scrivania e le finestre i risultati restano leggibili, come prima.
        /// Larghezza e distanza dall'alto restano quelle di Prisma (Misure.Spotlight): il pannello ha anche la
        /// colonna dell'anteprima, che il template non ha.
        enum Ricerca {
            /// Senza sfocatura (istantanee) coprente: sotto non si legge la scrivania.
            static let superficie = Superficie.finestraSopra
            static let raggio: CGFloat = 22
            static let selezione = Colore.selezioneVoce
            static let carattereCampo = Carattere(dimensione: 20, peso: .regular, tracking: -0.3)
            static let carattereGruppo = Carattere.etichetta
            static let carattereVoce = Carattere(dimensione: 13.5, peso: .semibold)
            static let carattereSotto = Carattere(dimensione: 12, peso: .regular)

            #if os(macOS)
            /// Migliorie d'uso 61 «Cerca ovunque, e fa» (Design/uso/gruppo-11.md §61.3 punto 9, template righe 756-767 e
            /// 4861-4912): la scatola del template sul Mac. Il pannello stretto di iPhone e iPad resta con `Misure.Spotlight`
            /// e il raggio 22.
            enum Mac {
                // La scatola
                static let larghezza: CGFloat = 900
                static let colonnaElenco: CGFloat = 420
                static let raggio: CGFloat = 26
                static let distanzaAlto: CGFloat = 84
                static let altezzaCorpo: CGFloat = 392
                /// Padding 14×16×10.
                static let margine = EdgeInsets(top: 14, leading: 16, bottom: 10, trailing: 16)
                /// Il velo sotto la scatola (scrim; la sfocatura 8 del template non c'è ancora: resta-da-fare.md §61).
                static let velo = Colore.velo
                // Il campo
                static let carattereLente = Carattere(dimensione: 22, peso: .medium)
                static let carattereCampo = Carattere(dimensione: 19, peso: .regular, tracking: -0.2)
                static let campoMargine = EdgeInsets(top: 2, leading: 4, bottom: 10, trailing: 2)
                static let carattereEsc = Carattere(dimensione: 11, peso: .semibold)
                static let testoEsc = Colore.inchiostro2
                static let fondoEsc = Colore.chip
                static let raggioEsc: CGFloat = 6
                static let escMargine = EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8)
                // I filtri da toccare
                static let etichettaFiltro = EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 11)
                static let carattereFiltro = Carattere(dimensione: 12.5, peso: .semibold)
                static let fondoFiltroAcceso = Colore.accento.opacity(0.14)
                static let testoFiltroAcceso = Colore.accento
                static let fondoFiltro = Colore.chip
                static let testoFiltro = Colore.inchiostro
                static let filettoFiltri = CGSize(width: 1, height: 18)
                static let coloreFiletto = Colore.separatore
                static let spazioFiltri: CGFloat = 6
                static let spazioPallino: CGFloat = 6
                static let pallinoCanale: CGFloat = 7
                static let filtriMargine = EdgeInsets(top: 0, leading: 2, bottom: 10, trailing: 2)
                static let carattereSalva = Carattere(dimensione: 12.5, peso: .semibold)
                // Righe e anteprima
                static let avatarRecente: CGFloat = 30
                static let avatarAnteprima: CGFloat = 48
                static let occhiello = Carattere.etichetta
                static let coloreOcchiello = Colore.inchiostro2
                static let coloreOcchielloParola = Colore.accento
                // Il pannello vuoto e nessun risultato
                static let frase = Carattere(dimensione: 12.5, peso: .regular, interlinea: 1.45)
                static let coloreFrase = Colore.inchiostro2
                static let fraseMargine = EdgeInsets(top: 12, leading: 10, bottom: 8, trailing: 10)
                static let nessunTitolo = Carattere(dimensione: 15, peso: .semibold)
                static let nessunSotto = Carattere(dimensione: 13, peso: .regular)
                static let nessunSpazio: CGFloat = 6
                // Il piede
                static let pieMargine = EdgeInsets(top: 8, leading: 6, bottom: 0, trailing: 6)
            }
            #endif
        }
    }
}
