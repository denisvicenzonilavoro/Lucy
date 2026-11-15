import SwiftUI

// Migliorie d'uso 2 «Un solo posto per scegliere il cliente» (Design/uso/gruppo-01.md §2.3, template righe 420-462,
// 847, 3082-3115): la pillola del cliente nella barra, il pannello «Di chi parliamo?» e il vuoto delle app che lavorano
// su una persona. Solo valori: le viste stanno in Shell/PannelloSceltaCliente.swift, Shell/BarraSuperiore.swift e
// DesignSystem/Apple/VuotoClienteApple.swift.

extension Tema.Apple {
    enum SceltaCliente {
        // MARK: La pillola della barra (#bCli)

        enum Pillola {
            /// Avatar 20 (o il glifo delle persone), freccia in giù da 11 al 55%, larga al massimo 230.
            static let avatar: CGFloat = 20
            static let glifo = Carattere(dimensione: 12, peso: .semibold)
            static let freccia = Carattere(dimensione: 11, peso: .semibold)
            static let opacitaFreccia: Double = 0.55
            static let larghezzaMassima: CGFloat = 230
            /// Il nome si taglia con i puntini perché la pillola resti entro 230 (padding, avatar, freccia e spazi).
            static let larghezzaMassimaNome: CGFloat = 164
            static let spazio: CGFloat = 6
        }

        // MARK: Il pannello (#cliP)

        enum Pannello {
            /// Vetro largo 348, a 40 dall'alto (sotto la barra), raggio 22, padding 12; non scende sul dock.
            static let larghezza: CGFloat = 348
            static let alto: CGFloat = 40
            static let raggio: CGFloat = Raggio.card
            static let padding: CGFloat = 12
            static let basso: CGFloat = 98
            /// L'elenco non va oltre 610.
            static let altezzaMassimaElenco: CGFloat = 610
            /// Titolo 16 bold.
            static let titolo = Carattere(dimensione: 16, peso: .bold)
            static let spazioTitolo: CGFloat = 10
            /// Il campo «⌕  Cerca per nome»: alto 32, raggio 10, fondo `chip`.
            static let campo = Carattere(dimensione: 13, peso: .regular)
            static let altezzaCampo: CGFloat = 32
            static let raggioCampo: CGFloat = 10
            static let fondoCampo = Colore.chip
            static let paddingCampo: CGFloat = 10
            /// Le righe: avatar (o cerchio del glifo) 36, nome 14 semibold, motto 12 secondario.
            static let avatar: CGFloat = 36
            static let glifoTutti = Carattere(dimensione: 15, peso: .semibold)
            static let fondoGlifo = Colore.selezioneVoce
            static let nome = Carattere(dimensione: 14, peso: .semibold)
            static let motto = Carattere(dimensione: 12, peso: .regular)
            static let coloreNome = Colore.inchiostro
            static let coloreMotto = Colore.inchiostro2
            static let paddingRiga = EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
            static let raggioRiga: CGFloat = Raggio.voce
            static let spazioRiga: CGFloat = 10
            static let rigaScelta = Colore.selezioneVoce
            static let rigaSopra = Colore.chip
            /// La spunta azzurra della scelta e i pallini 7 dei canali.
            static let spunta = Carattere(dimensione: 13, peso: .bold)
            static let coloreSpunta = Colore.accento
            static let pallino: CGFloat = 7
            static let spazioPallini: CGFloat = 4
            static let alleanza = Colore.canaleAlleanza
            static let indipendente = Colore.canaleIndipendente
            /// I titoli dei gruppi («Recenti», «Tutti · N»).
            static let gruppo = Carattere.etichetta
            static let coloreGruppo = Colore.inchiostro2
            static let sopraGruppo: CGFloat = 10
            static let sottoGruppo: CGFloat = 4
            /// «Nessun cliente con questo nome.»
            static let vuoto = Carattere(dimensione: 13, peso: .regular)
        }

        // MARK: Il vuoto delle app che lavorano su una persona (vuotoCli)

        enum Vuoto {
            /// Quadrato 84, raggio 28, fondo accento al 10%, glifo 42.
            static let quadrato: CGFloat = 84
            static let raggioQuadrato: CGFloat = 28
            static let fondoQuadrato = Colore.accento.opacity(0.10)
            static let glifo = Carattere(dimensione: 42, peso: .regular)
            static let coloreGlifo = Colore.accento
            /// Titolo 27 bold con tracking −0,6, testo 15 secondario.
            static let titolo = Carattere(dimensione: 27, peso: .bold, tracking: -0.6)
            static let testo = Carattere(dimensione: 15, peso: .regular, interlinea: 1.45)
            static let coloreTitolo = Colore.inchiostro
            static let coloreTesto = Colore.inchiostro2
            static let larghezzaTesto: CGFloat = 460
            static let spazio: CGFloat = 14
            static let sopraPulsante: CGFloat = 8
            /// «oppure» e le pillole dei primi cinque (avatar 24).
            static let oppure = Carattere(dimensione: 12.5, peso: .regular)
            static let avatarPillola: CGFloat = 24
            static let nomePillola = Carattere(dimensione: 13, peso: .semibold)
            static let paddingPillola = EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 12)
            static let fondoPillola = Colore.chip
            static let spazioPillole: CGFloat = 8
            static let margine: CGFloat = 32
        }

        // MARK: Con un cliente scelto

        enum Solo {
            /// «Solo <Nome> ✕» dell'Agenda: pillola sobria con l'accento.
            static let testo = Carattere(dimensione: 13, peso: .semibold)
            static let colore = Colore.accento
            static let fondo = Colore.selezioneVoce
            static let padding = EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 9)
            static let spazio: CGFloat = 6
            static let larghezzaMassima: CGFloat = 200
        }
    }
}
