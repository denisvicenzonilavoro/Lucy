import SwiftUI

// Blocco, barra superiore e notifiche della shell nel tema Apple
// (Design/template-apple-specifica.md §3.2, §3.3, §3.8). Misure in pt, durate in secondi.
// I tempi di blocco, sblocco, luce del pulsante e pannello delle notifiche stanno in `Tema.Apple.Moto`
// (TemaAppleMoto.swift); qui solo ciò che manca.

// MARK: - Blocco (§3.2)

extension Tema.Apple {
    /// La schermata di blocco: velo, logo, ora grande e sottile, data, «Tocca per entrare in Prisma».
    enum Lucchetto {
        /// Il logo vettoriale: alto 40, a 70 dal bordo in alto.
        static let logo: CGFloat = 40
        static let logoDallAlto: CGFloat = 70
        /// L'ora (`Carattere.oraBlocco`) comincia 150 sotto il logo; la data sta 10 sotto l'ora.
        static let oraSottoLogo: CGFloat = 150
        static let dataSottoOra: CGFloat = 10
        /// Data: 22 medium all'80%.
        static let data = Carattere(dimensione: 22, peso: .medium)
        static let opacitaData: Double = 0.8
        /// Il pulsante di vetro: a 70 dal fondo, padding 12×22, 14 semibold.
        static let pulsanteDalFondo: CGFloat = 70
        static let paddingPulsante = Misura.padding(12, 22)
        static let pulsante = Carattere(dimensione: 14, peso: .semibold)
        /// Il vetro del pulsante senza sfocatura propria: allo sblocco la schermata intera si sfoca
        /// (`Moto.Sblocco.sfocatura`) e le sfocature non si annidano. Sopra l'acqua ferma non si nota la differenza.
        static let superficiePulsante = Superficie(riempimento: Colore.vetro, sfocatura: 0, saturazione: 1,
                                                   bordo: Colore.bordoVetro, spessoreBordo: 1, ombra: .vetro,
                                                   raggio: Raggio.pillola, filoInterno: true)
        /// La luce che attraversa il pulsante: gradiente a 100° largo quanto la casella (25 novembre 2026, richiesta
        /// dell'utente: prima un fascio stretto al centro), trasparente ai bordi e bianco al 60% di opacità al centro.
        static let fermateLuce: [Gradient.Stop] = [
            Gradient.Stop(color: Color(r: 255, g: 255, b: 255, a: 0), location: 0.10),
            Gradient.Stop(color: Color(r: 255, g: 255, b: 255, a: 0.60), location: 0.50),
            Gradient.Stop(color: Color(r: 255, g: 255, b: 255, a: 0), location: 0.90),
        ]
        /// I due capi del gradiente a 100° (appena inclinato rispetto all'orizzontale).
        static let inizioLuce = UnitPoint(x: 0, y: 0.41)
        static let fineLuce = UnitPoint(x: 1, y: 0.59)

        // Il trascinamento (resta valido come prima del tema Apple: oltre al clic, si entra anche trascinando)
        /// Quanto la schermata segue il dito (0,35 della strada fatta).
        static let seguito: CGFloat = 0.35
        /// Oltre questa distanza (pt del gesto) il rilascio fa entrare.
        static let sogliaTrascinamento: CGFloat = 90
        /// Oppure se la previsione del gesto va oltre questo multiplo della soglia (colpo rapido).
        static let quotaPrevista: CGFloat = 2
    }
}

extension Tema.Apple.Moto.LuceBlocco {
    /// Al massimo 30 fotogrammi al secondo per la luce del pulsante (TimelineView, niente Timer).
    static let intervallo: Double = 1.0 / 30
}

extension Tema.Apple.Moto.Sblocco {
    /// La barra superiore compare (e svanisce al blocco) in 0,6 s con `ease`, come `transition: opacity .6s`.
    static var animazioneBarra: Animation { Tema.Apple.Moto.Curva.ease.animazione(durataBarra) }
}

// MARK: - Barra superiore (§3.3)

extension Tema.Apple {
    /// La barra in alto: senza fondo proprio, ogni gruppo nella sua capsula di vetro.
    enum BarraAlta {
        /// Pillole del marchio e dell'app: padding 5×11, spazio 7 fra logo e nome, logo 15.
        static let paddingPillola = Misura.padding(5, 11)
        static let spazioMarchio: CGFloat = 7
        static let logo: CGFloat = 15
        /// Fra una pillola e l'altra a sinistra (`margin-right: 6`) e fra gli strumenti a destra (`gap: 6`).
        static let spazio: CGFloat = 6
        /// Margine a destra (padding 0×12 della barra).
        static let margineDestro: CGFloat = 12
        /// Fra il pulsante verde vero della finestra del Mac e il bordo della pillola del marchio.
        static let dopoSemafori: CGFloat = 14
        /// Cerca: spazio fra lente, parola e scorciatoia; la scorciatoia al 50%.
        static let spazioCerca: CGFloat = 5
        static let opacitaScorciatoia: Double = 0.5
        static let scorciatoia = Carattere(dimensione: 11, peso: .medium)
        /// Data e ora al centro: «lun 2 nov 23:09».
        static let spazioOrologio: CGFloat = 4
        /// Gli strumenti: tasti tondi da 28; la sfera di Vera dentro è da 24.
        static let tasto: CGFloat = 28
        static let sferaVera: CGFloat = 24
        /// I simboli dentro i tasti (campanella, lucchetto, guida, modalità cliente).
        static let simbolo = Carattere(dimensione: 13, peso: .medium)
        /// Badge della campanella: `#FF3B30`, 9 bold, padding 1×4, a −3 dall'alto e −4 da destra.
        static let paddingBadge = EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4)
        static let spostamentoBadge = CGSize(width: 4, height: -3)
        /// Avatar «DV»: cerchio da 28 con il gradiente verticale, iniziali 11.
        static let avatar: CGFloat = 28
        static let iniziali = Carattere(dimensione: 11, peso: .semibold)
        /// Testo bianco del badge e dell'avatar.
        static let testoSuColore = Color(r: 255, g: 255, b: 255)
        /// Tinta del vetro sotto il puntatore.
        static let passaggio = Color(r: 255, g: 255, b: 255, a: 0.14)
    }
}

// MARK: - Notifiche (§3.8)

extension Tema.Apple {
    /// Il pannello delle notifiche: scende dalla campanella, le voci entrano una dopo l'altra.
    enum CentroNotifiche {
        /// Di vetro, largo 360, raggio 22, padding 14, a 12 dal bordo destro e 40 dall'alto.
        static let larghezza: CGFloat = 360
        static let raggio: CGFloat = Raggio.card
        static let padding: CGFloat = 14
        static let destra: CGFloat = 12
        static let alto: CGFloat = 40
        /// Sotto, lo spazio del dock: il pannello non ci arriva.
        static let basso: CGFloat = 98
        /// Intestazione: «Notifiche» 15 bold e il conteggio a destra (`.k`).
        static let titolo = Carattere(dimensione: 15, peso: .bold)
        static let conteggio = Carattere.secondario
        /// Voci: padding 10, raggio 14, fondo `card`, 8 fra una voce e l'altra, testo 13 con interlinea 1,4.
        static let paddingVoce: CGFloat = 10
        static let raggioVoce: CGFloat = Raggio.voce
        static let spazioVoci: CGFloat = 8
        static let spazioVoce: CGFloat = 10
        static let nome = Carattere(dimensione: 13, peso: .bold, interlinea: 1.4)
        static let testo = Carattere(dimensione: 13, peso: .regular, interlinea: 1.4)
        /// Il pallino colorato: 8, a 6 dall'alto della voce.
        static let pallino: CGFloat = 8
        static let pallinoAlto: CGFloat = 6
        static let pallinoUrgente = Colore.rosso
        static let pallinoAvviso = Colore.arancio
        static let pallinoInformazione = Colore.accento
        /// Fondo della voce sotto il puntatore (sopra `card`).
        static let voceSopra = Colore.chip
        /// Titoli dei gruppi (`.lbl`): sopra il primo 4, sopra gli altri 12.
        static let gruppo = Carattere.etichetta
        static let gruppoPrimo: CGFloat = 4
        static let gruppoAltri: CGFloat = 12
        /// Fino a quante voci il pannello è alto quanto il contenuto; oltre, scorre ed è alto quanto può.
        static let vociSenzaScorrere = 12
        /// Le voci oltre questa entrano senza cascata (sono fuori vista all'apertura).
        static let vociInCascata = 8
    }
}

// MARK: - Il «Da fare» unico (migliorie d'uso 3, solo sul Mac)

extension Tema.Apple {
    /// La pillola «Da fare» della barra, il suo pannello e la riga comune (`RigaDaFare`): Design/uso/gruppo-01.md §3,
    /// CSS del template righe 423-424 e 479-498.
    enum ElencoDaFare {
        // La pillola della barra: glifo del cerchio con la spunta, «Da fare» e il numero
        static let glifoPillola = "checkmark.circle"
        static let spazioPillola: CGFloat = 5
        /// Il numero (`.bN`): 10 bold bianco su rosso `#FF3B30`, verde quando è zero, padding 1×6.
        static let numero = Carattere(dimensione: 10, peso: .bold, tabellare: true)
        static let paddingNumero = EdgeInsets(top: 1, leading: 6, bottom: 1, trailing: 6)
        static let fondoNumero = Colore.rossoBadge
        static let fondoNumeroZero = Colore.verde
        static let testoNumero = Color(r: 255, g: 255, b: 255)

        // Il pannello (`#notif`): largo 450, padding 12×10, fondo `pop` (vetro coprente), raggio delle card
        static let larghezza: CGFloat = 450
        static let padding = Misura.padding(12, 10)
        static let raggio: CGFloat = Raggio.card
        static let destra: CGFloat = 12
        static let basso: CGFloat = 98
        /// L'elenco scorre oltre 650.
        static let altezzaElenco: CGFloat = 650
        /// Oltre queste righe (alte almeno `altezzaRiga`) l'elenco non può stare in `altezzaElenco`: scorre subito, con le
        /// righe create solo quando si vedono.
        static let righeSenzaScorrere = Int((altezzaElenco / altezzaRiga).rounded(.up))
        /// Righe al più per gruppo nel pannello; le altre con «e altre N · Mostra tutte».
        static let righePerGruppo = 12
        /// La testata: «Da fare» 16 bold, il numero, a destra il segmentato o «in ordine di tempo».
        static let titolo = Carattere(dimensione: 16, peso: .bold)
        static let spazioTitolo: CGFloat = 6
        static let paddingTesta = EdgeInsets(top: 2, leading: 6, bottom: 6, trailing: 6)
        static let nota = Carattere(dimensione: 12, peso: .regular)
        /// Il titolo dei gruppi (`.dfG`): 11 bold maiuscolo, tracking 0,6, 12 sopra (4 il primo), 2 sotto.
        static let gruppo = Carattere(dimensione: 11, peso: .bold, tracking: 0.6, maiuscolo: true)
        static let gruppoSopra: CGFloat = 12
        static let gruppoPrimoSopra: CGFloat = 4
        static let gruppoSotto: CGFloat = 2
        static let paddingElenco: CGFloat = 4
        /// «Tutto fatto.» al centro, 28 sopra e sotto.
        static let vuotoPadding: CGFloat = 28
        /// Il piede: filo sopra, 6 sopra il filo, 8 sotto; «+ Aggiungi» e «Fatte oggi» 13.
        static let piedeSopra: CGFloat = 6
        static let piedePadding = EdgeInsets(top: 8, leading: 4, bottom: 0, trailing: 4)
        static let piede = Carattere(dimensione: 13, peso: .regular)
        static let collegamento = Carattere(dimensione: 13, peso: .semibold)
        static let coloreCollegamento = Colore.accento
        /// Il campo «Aggiungi»: capsula `chip`, padding 4/4/4/14, testo 13,5, al più 70 caratteri.
        static let paddingCampo = EdgeInsets(top: 4, leading: 14, bottom: 4, trailing: 4)
        static let campo = Carattere(dimensione: 13.5, peso: .regular)
        static let fondoCampo = Colore.chip
        static let caratteriCampo = 70

        // La riga (`.dfR`)
        static let altezzaRiga: CGFloat = 38
        static let paddingRiga = Misura.padding(5, 4)
        static let spazioRiga: CGFloat = 10
        static let raggioRiga: CGFloat = 10
        static let fondoRigaSopra = Colore.chip
        static let filo = Colore.separatore
        /// Nell'Agenda il filo fra le righe è arancio al 22%.
        static let filoAgenda = Colore.arancio.opacity(0.22)
        /// Il cerchio da spuntare: 20, filo 2 `ink3`; al passaggio verde al 18% e scala 1,12.
        static let cerchio: CGFloat = 20
        static let trattoCerchio: CGFloat = 2
        static let coloreCerchio = Colore.inchiostro3
        static let coloreCerchioSopra = Colore.verde
        static let fondoCerchioSopra = Colore.verde.opacity(0.18)
        static let scalaCerchioSopra: CGFloat = 1.12
        /// Il pallino del momento: 8 (rosso oggi, arancio in settimana, verde dopo).
        static let pallino: CGFloat = 8
        static func colorePallino(_ t: VoceDaFare.Tono) -> Color { Posizioni.Scheda.colore(t) }
        /// Titolo 13,5 semibold, sotto 12 secondario.
        static let titoloRiga = Carattere(dimensione: 13.5, peso: .semibold, interlinea: 1.3)
        static let sottoRiga = Carattere(dimensione: 12, peso: .regular)
        static let spazioCanali: CGFloat = 4
        /// L'uscita della riga spuntata: opacità 0 e 16 a destra in 0,32 s.
        static let uscita: CGFloat = 16
        static let durataUscita: Double = 0.32
        static var animazioneUscita: Animation { Moto.Curva.ease.animazione(durataUscita) }

        // Il dettaglio fuori da Posizioni (al centro) e la scheda semplice delle voci scritte a mano
        static let misuraSemplice = CGSize(width: 440, height: 250)
        static let misuraDettaglio = Posizioni.Dettaglio.misura
        static let quandoSemplice = Carattere(dimensione: 12, peso: .semibold, maiuscolo: true)
        static let testoSemplice = Carattere(dimensione: 19, peso: .bold)
        static let notaSemplice = Carattere(dimensione: 13, peso: .regular, interlinea: 1.4)
        static let spazioSemplice: CGFloat = 10
        /// Il riquadro «Da fare» della scrivania (al posto di «In scadenza entro 90 giorni»): al più tre righe sotto la
        /// testata, 6 fra il titolo e il numero, 8 sopra l'elenco.
        static let righeScrivania = 3
        static let elencoSopraScrivania: CGFloat = 8
        /// Le righe degli arrivi: pallino del gruppo delle notifiche.
        static let pallinoArrivoUrgente = Colore.rosso
        static let pallinoArrivoAvviso = Colore.arancio
        static let pallinoArrivoInformazione = Colore.accento
    }
}
