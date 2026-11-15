import SwiftUI

// Migliorie d'uso 20 «L'incontro ha tre momenti: Prima, Durante, Dopo» (Design/uso/gruppo-03.md §20, solo sul Mac): la
// testata bassa dell'incontro con i tre momenti a capsula, «Prima» (punti da toccare e quattro riquadri), la barra di
// «Durante» con il selettore «Copilota | Appunti a mano» e «Dopo» (il verbale dentro la pagina, o il vuoto). Le viste
// stanno in Shell/AppIncontri.swift, Shell/CopilotaIncontro.swift, Shell/VerbaleCopilota.swift e
// DesignSystem/Apple/MomentiIncontroApple.swift. Qui solo i valori, ricavati dal tema Apple (template righe 602-612 e
// 3742-3806).

extension Tema.Apple.Copilota {
    // MARK: La testata dell'incontro

    /// La card alta 74 senza ombra: padding 0×20, avatar 44 a 14 dal titolo 16 bold (una riga), sotto «<nome> · <quando>
    /// · <luogo>» (`.k`); i tre momenti spinti a destra.
    enum TestataIncontro {
        static let altezza: CGFloat = 74
        static let superficie = Tema.Apple.Superficie.cardPiatta
        static let raggio = Tema.Apple.Raggio.card
        static let paddingOrizzontale: CGFloat = 20
        static let spazio: CGFloat = 14
        static let avatar: CGFloat = 44
        static let titolo = Tema.Apple.Carattere(dimensione: 16, peso: .bold)
        static let coloreTitolo = Tema.Apple.Colore.inchiostro
        static let sotto = Tema.Apple.Carattere.secondario
        static let coloreSotto = Tema.Apple.Colore.inchiostro2
        static let spazioTitoli: CGFloat = 2
        static let spazioCanale: CGFloat = 6
        /// Fra la testata e il contenuto del momento (il template mette il contenuto a 86 dall'alto: 74 + 12).
        static let sottoTestata: CGFloat = 12
    }

    // MARK: I tre momenti (`.passi`, `.pz`)

    enum Momenti {
        /// Fra un momento e il filo: 6; il filo 26×2 raggio 2 color binario.
        static let spazio: CGFloat = 6
        static let filo = CGSize(width: 26, height: 2)
        static let coloreFilo = Tema.Apple.Colore.binario
        /// Capsula: padding 6 / 14 / 6 / 7, 9 fra il tondo e i nomi.
        static let padding = EdgeInsets(top: 6, leading: 7, bottom: 6, trailing: 14)
        static let spazioTondo: CGFloat = 9
        /// Tondo 26 col numero 12,5 bold (o la spunta 13).
        static let tondo: CGFloat = 26
        static let numero = Tema.Apple.Carattere(dimensione: 12.5, peso: .bold, tabellare: true)
        static let spunta = Tema.Apple.Carattere(dimensione: 11, peso: .heavy)
        static let fondoTondo = Tema.Apple.Colore.chip
        static let coloreNumero = Tema.Apple.Colore.inchiostro2
        /// Acceso: capsula in accento al 12%, tondo pieno d'accento col numero bianco.
        static let fondoAcceso = Tema.Apple.Colore.accento.opacity(0.12)
        static let fondoTondoAcceso = Tema.Apple.Colore.accento
        static let numeroAcceso = Color.white
        /// Fatto: tondo verde al 18% con la spunta verde.
        static let fondoTondoFatto = Tema.Apple.Colore.verde.opacity(0.18)
        static let coloreSpunta = Tema.Apple.Colore.verde
        /// Sotto il puntatore: `chip`.
        static let fondoSopra = Tema.Apple.Colore.chip
        /// Nome 13,5 bold, sottonome 11 `inchiostro2`.
        static let nome = Tema.Apple.Carattere(dimensione: 13.5, peso: .bold)
        static let coloreNome = Tema.Apple.Colore.inchiostro
        static let sottonome = Tema.Apple.Carattere(dimensione: 11, peso: .regular)
        static let coloreSottonome = Tema.Apple.Colore.inchiostro2
        static let durataFondo = 0.25
        static var animazioneFondo: Animation { .easeInOut(duration: durataFondo * Tema.Apple.Moto.ritmo) }
    }

    // MARK: Prima

    /// A sinistra la card (flex 1,35, padding 18×22) con i punti, «L'ultima volta» e i pulsanti in basso; a destra
    /// (flex 1) i quattro riquadri a 12 l'uno dall'altro.
    enum Prima {
        static let quotaSinistra: CGFloat = 1.35
        static let quotaDestra: CGFloat = 1
        static let spazio: CGFloat = 14
        static let superficie = Tema.Apple.Superficie.cardPiatta
        static let raggio = Tema.Apple.Raggio.card
        static let padding = Tema.Apple.Misura.padding(18, 22)
        /// «L'ultima volta · <data>» a 22 dai punti, il testo 14 (interlinea 1,55) `inchiostro2` a 6.
        static let sopraUltimaVolta: CGFloat = 22
        static let sottoOcchiello: CGFloat = 6
        static let ultimaVolta = Tema.Apple.Carattere(dimensione: 14, peso: .regular, interlinea: 1.55)
        static let coloreUltimaVolta = Tema.Apple.Colore.inchiostro2
        static let occhiello = Tema.Apple.Carattere.etichetta
        static let coloreOcchiello = Tema.Apple.Colore.inchiostro2
        /// I pulsanti in fondo, a 8; sopra i pulsanti 16.
        static let spazioPulsanti: CGFloat = 8
        static let sopraPulsanti: CGFloat = 16
        static let nota = Tema.Apple.Carattere.secondario
        static let coloreNota = Tema.Apple.Colore.inchiostro2
        /// Le cose di sempre (temi dell'Analisi 360, priorità, cosa è cambiato) sotto, nello scorrimento.
        static let sopraDiSempre: CGFloat = 14
        /// I riquadri (quelli della traccia dell'impegno, `RiquadroTracciaApple`): 12 fra loro; sotto la cifra `.k`.
        static let spazioRiquadri: CGFloat = 12
        static let cifraRiquadro = Tema.Apple.Agenda.Traccia.cifraTile
        static let coloreCifra = Tema.Apple.Agenda.Traccia.coloreCifraTile
        static let notaRiquadro = Tema.Apple.Carattere.secondario
        static let coloreNotaRiquadro = Tema.Apple.Colore.inchiostro2
    }

    // MARK: Durante

    /// La card alta 66 senza ombra: padding 0×20, 14 fra le parti; selettore, stato con la riga del consenso, onda,
    /// «● Avvia il copilota». 12 sotto, poi il contenuto.
    enum Durante {
        static let altezza: CGFloat = 66
        static let superficie = Tema.Apple.Superficie.cardPiatta
        static let raggio = Tema.Apple.Raggio.card
        static let paddingOrizzontale: CGFloat = 20
        static let paddingVerticale: CGFloat = 8
        static let spazio: CGFloat = 14
        static let sotto: CGFloat = 12
        /// Sotto questa larghezza trascrizione e schede vanno una sotto l'altra (sul Mac l'elenco a sinistra prende 316).
        static let sogliaStretta: CGFloat = 620
        /// Sotto questa larghezza la barra lascia l'onda (selettore, stato e pulsante restano).
        static let larghezzaMinimaConOnda: CGFloat = 860
        /// Lo stato 13,5 semibold; sotto la riga del consenso (verde col lucchetto, o arancio senza consenso).
        static let stato = Tema.Apple.Carattere(dimensione: 13.5, peso: .semibold, tabellare: true)
        static let coloreStato = Tema.Apple.Colore.inchiostro
        static let consenso = Tema.Apple.Copilota.Testata.indicatore
        static let coloreConsenso = Tema.Apple.Copilota.Testata.coloreIndicatore
        static let coloreSenzaConsenso = Tema.Apple.Colore.arancioTesto
        static let spazioConsenso: CGFloat = 5
        /// «Appunti a mano»: la frase `.k` e «Ho finito ›».
        static let frase = Tema.Apple.Carattere.secondario
        static let coloreFrase = Tema.Apple.Colore.inchiostro2
        /// Il tondo col numero della domanda (`.pzN`): 22, 12 bold bianco su accento.
        static let numeroDomanda: CGFloat = 22
        static let carattereNumeroDomanda = Tema.Apple.Carattere(dimensione: 12, peso: .bold, tabellare: true)
        static let fondoNumeroDomanda = Tema.Apple.Colore.accento
        static let testoNumeroDomanda = Color.white
        /// Il foglio del consenso (il modulo di sempre), largo 460.
        static let larghezzaFoglioConsenso: CGFloat = 460
        static let paddingFoglioConsenso: CGFloat = 20
    }

    // MARK: Dopo

    /// Il vuoto: card centrata, titolo display 22 bold, frase 14 (interlinea 1,5) `inchiostro2` larga al più 470, 8 sopra
    /// e 18 sotto, pulsanti a 8.
    enum Dopo {
        static let superficie = Tema.Apple.Superficie.cardPiatta
        static let raggio = Tema.Apple.Raggio.card
        static let padding = Tema.Apple.Misura.padding(18, 22)
        static let titoloVuoto = Tema.Apple.Carattere.titoloDettaglio(22)
        static let coloreTitoloVuoto = Tema.Apple.Colore.inchiostro
        static let fraseVuoto = Tema.Apple.Carattere(dimensione: 14, peso: .regular, interlinea: 1.5)
        static let coloreFraseVuoto = Tema.Apple.Colore.inchiostro2
        static let larghezzaVuoto: CGFloat = 470
        static let sopraFrase: CGFloat = 8
        static let sottoFrase: CGFloat = 18
        static let spazioPulsanti: CGFloat = 8
        /// «Già nel dossier: l'incontro è archiviato, in sola lettura.» con «Riapri», sopra l'archivio.
        static let nota = Tema.Apple.Carattere.secondario
        static let coloreNota = Tema.Apple.Colore.inchiostro2
        static let spazioNota: CGFloat = 10
    }
}

extension ParametriOnda {
    /// L'onda della barra di «Durante» (Migliorie d'uso 20): larga 225 (30 barre al passo del copilota), come il canvas
    /// largo 230 del template; per il resto quella del copilota.
    static let barraDurante = ParametriOnda(larghezza: 225, altezza: Tema.Apple.Copilota.Onda.altezza, barre: 30,
                                            passo: Tema.Apple.Copilota.Onda.passo,
                                            larghezzaBarra: Tema.Apple.Copilota.Onda.larghezzaBarra,
                                            raggioBarra: Tema.Apple.Copilota.Onda.raggioBarra,
                                            minima: Tema.Apple.Copilota.Onda.minima, scala: Tema.Apple.Copilota.Onda.scala,
                                            coloreAscolto: Tema.Apple.Copilota.Onda.coloreAscolto,
                                            coloreFermo: Tema.Apple.Copilota.Onda.coloreFermo,
                                            tempoIstantanea: Tema.Apple.Copilota.Onda.tempoIstantanea)
}
