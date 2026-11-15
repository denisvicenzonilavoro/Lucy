import SwiftUI

// Posizioni › Portafoglio del tema Apple (Design/template-apple-specifica.md §4.1, riferimenti posizioni-clienti/
// P01-P14 e movimento/02-12): misure, caratteri, colori e tempi della card del portafoglio, dello stato del lavoro,
// del nastro «Da fare» e del dettaglio di una scheda. Le viste stanno in Shell/PortafoglioApple.swift; qui solo
// i valori. Area del contenuto del template 1384×654: in Prisma le larghezze sono quote dello spazio che c'è.

extension Tema.Apple {
    enum Posizioni {
        // MARK: Disposizione

        enum Disposizione {
            /// Spazio fra le card e fra le righe (16 nel template).
            static let spazio: CGFloat = Misura.Spazio.colonneScrivania
            /// Larghezze della prima riga: card del portafoglio 870, stato del lavoro 498 (in proporzione).
            static let quoteRiga: [CGFloat] = [870, 498]
            /// Lo stato del lavoro non scende sotto questa larghezza (anelli e legenda leggibili).
            static let larghezzaMinimaLavoro: CGFloat = 380
            /// Altezza della prima riga: 296 nel template; qui 310, perché il totale di SF a 62 pt occupa la sua
            /// riga intera e il grafico (in fondo alla card) non deve coprire le cifre dei canali.
            static let altezzaRiga: CGFloat = 310
            /// Margine del contenuto (12, come nel resto della finestra).
            static let margine: CGFloat = Misura.Finestra.margineContenuto
            /// Spazio fra il nastro e i pannelli di Prisma che seguono sotto.
            static let spazioPannelli: CGFloat = 22
            /// Fondo del portafoglio: la carta chiara della finestra del tema.
            static let fondo = Colore.finestra
        }

        // MARK: Card del portafoglio

        enum Card {
            static let padding = Misura.Padding.cardPortafoglio
            static let raggio = Raggio.card
            static let superficie = Superficie.card
            static let etichetta = Carattere.etichetta
            static let coloreEtichetta = Colore.inchiostro2
            /// Il totale che si conta: 62 bold.
            static let totale = Carattere.numeroGrande
            static let riduzioneTotale: CGFloat = 0.55
            static let totaleSopra: CGFloat = 12
            /// Spazio fra il totale e il delta, che resta 7 sopra la linea di base del totale.
            static let spazioDelta: CGFloat = 18
            static let deltaSotto: CGFloat = 7
            static let delta = Carattere.delta
            static let coloreDelta = Colore.verde
            static let coloreDeltaNegativo = Colore.rosso
            static let coloreDeltaProposte = Colore.stima
            static let sottoDelta = Carattere.secondario
            static let coloreSottoDelta = Colore.inchiostro2
            /// Barra dei canali: 16 sopra, 8 sotto, larga 520 (o meno sulle card strette).
            static let barraSopra: CGFloat = 16
            static let barraSotto: CGFloat = 8
            static let larghezzaBarra: CGFloat = Grafico.Barra.larghezzaCanali
            /// Riga dei canali: 16 fra etichetta e cifra, 8 in più fra i due canali; cifre 13 bold.
            static let spazioCanale: CGFloat = 16
            static let spazioFraCanali: CGFloat = 8
            static let cifraCanale = Carattere(dimensione: 13, peso: .bold, tabellare: true)
            /// Il grafico: 26 dai lati della card, 30 dal fondo (i mesi stanno nei 20 sotto il grafico).
            static let graficoSotto: CGFloat = 10
            /// Indici dei numeri che contano (totale, Alleanza, indipendente): partono insieme.
            static let indiceTotale = 0
            static let indiceCanali = 1
            /// Indice della barra dei canali (ritardi 0,15 e 0,24).
            static let indiceBarra = 0
        }

        // MARK: Lo stato del tuo lavoro

        enum Lavoro {
            static let padding = Misura.Padding.cardGrande
            static let raggio = Raggio.card
            static let superficie = Superficie.card
            /// Anelli 190/16 (più piccoli se la card è stretta, mai sotto 120).
            static let anelli: CGFloat = 190
            static let anelliMinimi: CGFloat = 120
            static let spessoreAnelli: CGFloat = 16
            /// Spazio fra anelli e legenda.
            static let spazioAnelli: CGFloat = 22
            static let anelliSopra: CGFloat = 12
            /// Spazio minimo che resta alla legenda accanto agli anelli: 200, perché «Clienti in regola» col
            /// pallino e «1 su 5» stiano su una riga (a 170 i nomi uscivano tagliati con «…»).
            static let larghezzaLegenda: CGFloat = 200
            static let coloreInRegola = Colore.anello1
            static let coloreRiesami = Colore.anello2
            static let coloreProposte = Colore.anello3
            /// Legenda: righe con padding 10 e filetto, pallino 10, nome 14, numero 20 bold, «su 35» 13.
            static let rigaLegenda: CGFloat = 10
            static let spazioLegenda: CGFloat = 12
            static let pallino: CGFloat = 10
            static let nome = Carattere(dimensione: 14, peso: .regular)
            static let numero = Carattere(dimensione: 20, peso: .bold, tabellare: true)
            static let su = Carattere(dimensione: 13, peso: .medium)
            static let coloreSu = Colore.inchiostro2
            static let filetto = Colore.separatore
            /// L'invito sotto la legenda («Chiudi le cose da fare qui sotto…»), 10 sopra.
            static let invito = Carattere(dimensione: 12.5, peso: .regular, interlinea: 1.45)
            static let invitoSopra: CGFloat = 10
            static let coloreInvito = Colore.inchiostro2
        }

        // MARK: Nastro «Da fare»

        enum Nastro {
            /// Testata: titolo `.h2`, conteggio 13,5 `inchiostro2` a 6, frecce da 32 a destra; 18 sopra il nastro.
            static let titolo = Carattere.h2
            static let conteggio = Carattere(dimensione: 13.5, peso: .regular)
            static let coloreConteggio = Colore.inchiostro2
            static let spazioConteggio: CGFloat = 6
            static let spazioFrecce: CGFloat = 6
            static let freccia: CGFloat = Misura.Controllo.freccia
            static let testataSopra: CGFloat = 18
            /// Fra la testata e le schede.
            static let testataSotto: CGFloat = 2
            /// Padding interno del nastro (10×28: le ombre delle schede non vengono tagliate), spazio 14.
            static let padding = Misura.Padding.nastro
            static let spazio: CGFloat = Misura.Spazio.nastro
            /// Il nastro esce di 12 dai lati del contenuto, come nel template (left/right −12).
            static let sbordo: CGFloat = 12
            /// Maschera: 30 sfumati a sinistra, 60 a destra.
            static let sfumaturaSinistra: CGFloat = 30
            static let sfumaturaDestra: CGFloat = 60
            /// Una freccia sposta di due schede (2 × (232 + 14) = 492, il ±500 del template).
            static let schedePerFreccia = 2
            /// Gruppo: largo 112, 8 sopra, titolo 22 bold e conteggio 12,5.
            static let larghezzaGruppo: CGFloat = 112
            static let gruppoSopra: CGFloat = 8
            static let titoloGruppo = Carattere.titoloGruppo
            static let conteggioGruppo = Carattere.secondario
            static let coloreConteggioGruppo = Colore.inchiostro2
            static let vuoto = Carattere.corpo
            static let coloreVuoto = Colore.inchiostro2
        }

        // MARK: Scheda «Da fare»

        enum Scheda {
            static let misura = CGSize(width: 232, height: 270)
            static let raggio = Raggio.card
            static let superficie = Superficie.card
            /// Padding 16, fascia superiore di 4 nel tono.
            static let padding: CGFloat = 16
            static let fascia: CGFloat = 4
            static let quando = Carattere.quando
            static let perche = Carattere.perche
            static let percheSopra: CGFloat = 12
            static let righePerche = 5
            static let spazioCanali: CGFloat = 5
            static let canaliSopra: CGFloat = 10
            /// Il cliente: avatar 34, nome 13,5 bold, patrimonio 12 `inchiostro2`, 12 sopra.
            static let avatar: CGFloat = Misura.Avatar.voce
            static let spazioCliente: CGFloat = 9
            static let clienteSopra: CGFloat = 12
            /// Fra il nome del cliente e il suo patrimonio.
            static let spazioNomePatrimonio: CGFloat = 1
            static let nome = Carattere(dimensione: 13.5, peso: .bold)
            static let patrimonio = Carattere(dimensione: 12, peso: .regular, tabellare: true)
            static let colorePatrimonio = Colore.inchiostro2
            static let inclinazione = Moto.Inclinazione.massimoPredefinito

            /// Il colore del tono: rosso oggi, arancio in settimana, verde dopo.
            static func colore(_ t: VoceDaFare.Tono) -> Color {
                switch t {
                case .urgente: return Colore.rosso
                case .presto: return Colore.arancio
                case .sereno: return Colore.verde
                }
            }
        }

        // MARK: Dettaglio di una scheda (880×520)

        enum Dettaglio {
            static let misura = Misura.DettaglioAperto.daFare
            static let avatar: CGFloat = Misura.Avatar.grande
            static let spazioTestata: CGFloat = 14
            static let quando = Carattere.etichetta
            static let nome = Carattere.titoloDettaglio(26)
            /// Le etichette dei canali lasciano 56 a destra per la ✕.
            static let margineChiudi: CGFloat = 56
            static let spazioCanali: CGFloat = 5
            static let perche = Carattere(dimensione: 22, peso: .bold, tracking: -0.4, interlinea: 1.25)
            static let percheSopra: CGFloat = 20
            static let percheSotto: CGFloat = 6
            static let larghezzaTesto: CGFloat = 760
            static let spiegazione = Carattere.corpoGrande
            static let coloreSpiegazione = Colore.inchiostro2
            /// Le due colonne (1,1 e 1), 26 fra l'una e l'altra, 22 sotto il testo.
            static let spazioColonne: CGFloat = 26
            static let colonneSopra: CGFloat = 22
            static let quotaSinistra: CGFloat = 1.1
            /// Le tre cifre: etichetta `.k`, valore 26 bold, 34 fra l'una e l'altra.
            static let etichettaCifra = Carattere.secondario
            static let coloreEtichettaCifra = Colore.inchiostro2
            static let cifra = Carattere.valore
            static let spazioCifre: CGFloat = 34
            /// Il grafico del cliente: 440×110 (linea 2,5, area al 12%), 16 sopra; etichette 11 `inchiostro3`.
            static let grafico = CGSize(width: 440, height: 110)
            static let graficoSopra: CGFloat = 16
            static let spessoreGrafico: CGFloat = 2.5
            static let opacitaAreaGrafico: Double = 0.12
            static let asse = Carattere.asse
            static let coloreAsse = Colore.inchiostro3
            static let asseSopra: CGFloat = 6
            /// Piede: pulsanti grandi a 8 l'uno dall'altro, 30 dai lati e 24 dal fondo; nota `.k` a destra.
            static let spazioPulsanti: CGFloat = 8
            static let nota = Carattere.secondario
            static let coloreNota = Colore.inchiostro2
        }

        // MARK: Le posizioni prima di tutto (migliorie d'uso 14, solo Mac)

        /// L'indice delle posizioni del cliente (`#posIdx`): largo 236, il contenuto parte a 252. Voci, testa del
        /// cliente, etichette dei gruppi e numeri sono quelli dell'indice del dossier (`Clienti.Indice`).
        enum Indice {
            static let larghezza: CGFloat = 236
        }

        /// «Quadro e posizioni» (`posQuadroHTML`): le quattro tessere, la card «Le posizioni» a sinistra e, larghe
        /// 392, «Ripartizione per area» e «Per canale» a destra.
        enum Quadro {
            static let larghezzaDestra: CGFloat = 392
            static let spazio: CGFloat = 12
            /// Margine del contenuto: come la pagina di prima (10 sopra, 12 ai lati, 16 sotto).
            static let margine = EdgeInsets(top: 10, leading: 12, bottom: 16, trailing: 12)
            /// Card «Le posizioni»: titolo 18 bold, «{n} voci» `.k`, filtri sulla stessa riga.
            static let titoloCard = Carattere(dimensione: 18, peso: .bold, tracking: -0.3)
            static let coloreTitolo = Colore.inchiostro
            static let conto = Carattere.secondario
            static let coloreConto = Colore.inchiostro2
            static let spazioTesta: CGFloat = 10
            static let spazioFiltri: CGFloat = 6
            /// Piede sopra un filo: 12,5 `inchiostro2`.
            static let piede = Carattere.secondario
            static let colorePiede = Colore.inchiostro2
            static let filo = Colore.separatore
            static let paddingPiede: CGFloat = 10
            /// Una riga dell'elenco: alta 52, segno dell'area 10 (attenuato per le proposte), nome 13,5 semibold,
            /// sotto 12 `inchiostro2`; a destra l'importo largo almeno 104 e «›».
            static let altezzaRiga: CGFloat = 52
            static let paddingRiga: CGFloat = 10
            static let raggioRiga: CGFloat = 10
            static let spazioRiga: CGFloat = 10
            static let segno: CGFloat = 10
            static let raggioSegno: CGFloat = 3
            static let opacitaSegnoProposta: Double = 0.45
            static let nomeRiga = Carattere(dimensione: 13.5, peso: .semibold)
            static let coloreNomeRiga = Colore.inchiostro
            static let sottoRiga = Carattere(dimensione: 12, peso: .regular)
            static let coloreSottoRiga = Colore.inchiostro2
            static let spazioNomeSotto: CGFloat = 2
            static let importo = Carattere(dimensione: 13.5, peso: .semibold, tabellare: true)
            static let coloreImporto = Colore.inchiostro
            static let unitaImporto = Carattere(dimensione: 11.5, peso: .regular)
            static let larghezzaImporto: CGFloat = 104
            static let avviso = Carattere(dimensione: 12, peso: .semibold)
            static let coloreScadenza = Colore.arancioTesto
            static let coloreScaduta = Colore.rosso
            static let coloreDebito = Colore.rosso
            /// Le proposte nel viola delle stime (lo stesso del delta «Con le proposte»).
            static let coloreProposta = Colore.stima
            static let fondoProposta = Color(r: 139, g: 92, b: 246, a: 0.13)
            static let capsulaProposta = Carattere(dimensione: 11, peso: .bold)
            static let paddingCapsula = Misura.padding(2, 8)
            static let rigaSopra = Colore.chip
            static let freccia = Carattere(dimensione: 12, peso: .semibold)
            static let coloreFreccia = Colore.inchiostro3
            /// I filtri: capsule dei canali (pallino e nome) e dell'area con «✕», su `chip`; scelta nel fondo del canale.
            static let fondoFiltro = Colore.chip
            static let testoFiltro = Colore.inchiostro2
            static let filtro = Carattere(dimensione: 12, peso: .semibold)
            static let paddingFiltro = Misura.padding(4, 10)
            static let spazioFiltro: CGFloat = 5
            static let segnoAreaFiltro: CGFloat = 8
            static let simboloChiudi = Carattere(dimensione: 9, peso: .bold)
            /// La legenda della ripartizione è il filtro per area: la voce scelta sul fondo accento al 13%.
            static let fondoAreaScelta = Colore.selezioneVoce
            static let raggioAreaScelta: CGFloat = 8
            static let paddingAreaScelta: CGFloat = 6
            /// A ogni cambio di filtro l'elenco rientra: opacità e y +6 in 0,24 s.
            static let durataRientro = 0.24
            static let spostamentoRientro: CGFloat = 6
            static var rientro: Animation { .easeOut(duration: durataRientro * Tema.Apple.Moto.ritmo) }
            /// «{n} da fare per {nome} ›» sopra un filo, in fondo a «Per canale».
            static let daFare = Carattere(dimensione: 13, peso: .semibold)
            static let coloreDaFare = Colore.accento
            static let nienteDaFare = Carattere.secondario
            static let coloreNienteDaFare = Colore.inchiostro2
            static let sopraDaFare: CGFloat = 4
            /// Le cinque analisi: il pannello di oggi da solo, in cima; spazio fra il pannello e il vuoto.
            static let spazioAnalisi: CGFloat = 18
        }

        // MARK: La scheda di una posizione (migliorie d'uso 15, solo Mac)

        /// Il dettaglio di una posizione (`posDettaglioHTML`): barra alta 34 con «‹ Le posizioni» e al più quattro azioni
        /// più «Altro ⌄», la frase 19 semibold, le quattro cifre, il segmentato delle schede e la scheda scelta. Il nome è
        /// diverso da `Scheda` (la scheda del nastro «Da fare») e dal tipo `SchedaPosizione` (le schede del dettaglio).
        enum SchedaDettaglio {
            static let altezzaBarra: CGFloat = 34
            /// Sopra e sotto la barra: con i pulsanti da 32 la barra resta alta 40, come prima, sopra il filo.
            static let paddingBarra: CGFloat = 4
            static let spazioAzioni: CGFloat = 8
            static let margineBarra: CGFloat = 12
            static let freccia = Carattere(dimensione: 11, peso: .semibold)
            static let spazioFreccia: CGFloat = 5
            /// Margini del contenuto: come la pagina di prima (14 sopra, 16 ai lati, 18 sotto).
            static let margine = EdgeInsets(top: 14, leading: 16, bottom: 18, trailing: 16)
            /// La frase: 19 semibold, interlinea 1,3, 14 sopra e 12 sotto.
            static let frase = Carattere(dimensione: 19, peso: .semibold, tracking: -0.3, interlinea: 1.3)
            static let coloreFrase = Colore.inchiostro
            static let fraseSopra: CGFloat = 14
            static let fraseSotto: CGFloat = 12
            /// Il segmentato delle schede: 14 sopra, 12 sotto.
            static let schedeSopra: CGFloat = 14
            static let schedeSotto: CGFloat = 12
            /// Le card delle schede: 12 fra l'una e l'altra; a sinistra 1,25 della destra (In breve e Contratto).
            static let spazio: CGFloat = 12
            static let spazioPannelli: CGFloat = 22
            /// Il testo delle card di In breve: 15, interlinea 1,5.
            static let testoCard = Carattere(dimensione: 15, peso: .regular, interlinea: 1.5)
            static let coloreTestoCard = Colore.inchiostro
            static let etichettaDaFare = Colore.arancioTesto
            /// «Cosa manca per chiuderla»: pallino 7 e righe 13,5.
            static let pallino: CGFloat = 7
            static let colorePallino = Colore.arancio
            static let riga = Carattere(dimensione: 13.5, peso: .regular)
            static let spazioRighe: CGFloat = 8
            /// La striscia dei dati da completare (in fondo a In breve): «{n} dati da completare» arancio grassetto, i nomi
            /// `.k`, «Vedi ›» a destra; card piatta con padding 12×16.
            static let striscia = Carattere(dimensione: 13, peso: .bold)
            static let coloreStriscia = Colore.arancioTesto
            static let nomiStriscia = Carattere.secondario
            static let coloreNomiStriscia = Colore.inchiostro2
            static let paddingStriscia = Misura.padding(12, 16)
            static let raggioStriscia = Raggio.card
            static let fondoStriscia = Colore.chip
            static let spazioStriscia: CGFloat = 10
            /// «Da completare · {n}»: le capsule dei nomi 12,5 con margini 4×11 su `chip`.
            static let capsula = Carattere(dimensione: 12.5, peso: .medium)
            static let coloreCapsula = Colore.inchiostro2
            static let fondoCapsula = Colore.chip
            static let paddingCapsula = Misura.padding(4, 11)
            static let spazioCapsule: CGFloat = 8
            static let nota = Carattere.secondario
            static let coloreNota = Colore.inchiostro2
            /// I colori delle cifre: guadagno verde, debito e perdita rossi, scadenza vicina arancio, proposta viola.
            static let verde = Colore.verde
            static let rosso = Colore.rosso
            static let arancio = Colore.arancioTesto
            static let viola = Colore.stima
        }

        // MARK: Il colore del cliente (avatar e grafico del dettaglio)

        /// Il colore del cliente nel tema: la tinta dell'avatar, con i toni degli impegni dell'Agenda.
        static func coloreCliente(_ t: TintaAvatar) -> Color {
            switch t {
            case .blu: return Colore.Impegno.marco
            case .rosa: return Colore.Impegno.giulia
            case .viola: return Colore.Impegno.laura
            case .verde: return Colore.Impegno.andrea
            case .oro: return Colore.Impegno.sofia
            }
        }
    }
}

// MARK: - Aggiorna i valori: prima i dubbi (migliorie d'uso 44, solo Mac)
// Il pannello «Aggiorna i valori» del Mac (Shell/AggiornaValoriMac.swift, CSS `.aggD`, `.aggOk`, `.aggT` del template
// delle migliorie d'uso): in alto le righe in dubbio in riquadri arancio tenue, sotto i «Pronti» in quattro colonne, in
// fondo le righe che non si registrano. I token di `Tema.Misura.AggiornaValori` e `Tema.Colore.AggiornaValori` restano
// per l'iPad, che tiene il pannello di prima finché non arriva il suo giro.

extension Tema.Apple.Posizioni {
    enum AggiornaValori {
        typealias K = Tema.Apple.Carattere
        typealias C = Tema.Apple.Colore

        // MARK: Disposizione
        static let margine: CGFloat = 22
        /// Spazio fra i blocchi (16), fra i riquadri dei dubbi (8), fra la capsula e le righe (6).
        static let spazioSezioni: CGFloat = 16
        static let spazioDubbi: CGFloat = 8
        static let spazioTesta: CGFloat = 6
        static let spazioComandi: CGFloat = 10
        static let larghezzaMassima: CGFloat = 980
        static let superficie = Tema.Apple.Superficie.cardPiatta
        static let raggioCard = Tema.Apple.Raggio.card
        static let paddingCard = Tema.Apple.Misura.Padding.cardMedia

        // MARK: Testata
        static let occhiello = K.etichetta
        static let coloreOcchiello = C.accento
        static let titolo = K.h2
        static let coloreTitolo = C.inchiostro
        static let sotto = K.corpo
        static let coloreSotto = C.inchiostro2
        static let link = K(dimensione: 14, peso: .semibold)
        static let coloreLink = C.accento
        static let spazioTitolo: CGFloat = 2
        static let segmenti: CGFloat = 380

        // MARK: Riquadro del dubbio (`.aggD`)
        static let raggioDubbio: CGFloat = 16
        static let paddingDubbio = Tema.Apple.Misura.padding(12, 14)
        static let fondoDubbio = C.arancio.opacity(0.10)
        static let bordoDubbio = C.arancio.opacity(0.25)
        static let avatar: CGFloat = 34
        static let spazioDubbio: CGFloat = 12
        static let titoloDubbio = K(dimensione: 14, peso: .semibold)
        static let domanda = K(dimensione: 13.5, peso: .regular, interlinea: 1.45)
        static let coloreDomanda = C.inchiostro2
        static let canaleDubbio = K(dimensione: 12, peso: .medium)
        /// L'avatar della riga intestata a chi non è fra i clienti: cerchio grigio con il punto di domanda.
        static let fondoAvatarVuoto = C.chip
        static let simboloAvatarVuoto = K(dimensione: 14, peso: .semibold)
        static let coloreAvatarVuoto = C.inchiostro2
        /// La scossa del primo dubbio (0 → −6 → 6 → 0 in 0,3 s); niente con «Riduci movimento».
        static let ampiezzaScossa: CGFloat = 6
        static let volteScossa: CGFloat = 1
        static var scossa: Animation { .linear(duration: 0.30 * Tema.Apple.Moto.ritmo) }

        // MARK: Dubbio deciso (`.aggOk`)
        static let paddingDeciso = Tema.Apple.Misura.padding(8, 4)
        static let spazioDeciso: CGFloat = 8
        static let deciso = K(dimensione: 13.5, peso: .regular)
        static let decisoForte = K(dimensione: 13.5, peso: .semibold)
        static let spunta = K(dimensione: 16, peso: .semibold)
        static let coloreSpunta = C.verde

        // MARK: Pronti (`.aggT`: 1fr · 130 · 200 · 86)
        static let colonnaCliente: CGFloat = 130
        static let colonnaPrimaDopo: CGFloat = 200
        static let colonnaVariazione: CGFloat = 86
        static let colonnaSpunta: CGFloat = 26
        static let spazioColonne: CGFloat = 12
        static let paddingRiga = Tema.Apple.Misura.padding(8, 4)
        static let riga = K(dimensione: 13.5, peso: .regular, tabellare: true)
        static let rigaForte = K(dimensione: 13.5, peso: .semibold, tabellare: true)
        static let variazione = K(dimensione: 13.5, peso: .semibold, tabellare: true)
        static let totale = K(dimensione: 14, peso: .bold, tabellare: true)
        static let nota = K.secondario
        static let coloreNota = C.inchiostro2
        static let coloreSalita = C.verde
        static let coloreDiscesa = C.rosso
        static let opacitaTolta = 0.45
        static let filo = C.separatore
        /// «Non si registrano · n»: la testata che apre e chiude l'elenco.
        static let testaSezione = K(dimensione: 13.5, peso: .semibold)
        static let freccia = K(dimensione: 11, peso: .bold)
        static let coloreFreccia = C.inchiostro3

        // MARK: Piede e riepilogo
        static let paddingPiede = Tema.Apple.Misura.padding(14, 22)
        static let cifraRiquadro = K.valore
        static let etichettaRiquadro = K.etichetta
        static let paddingRiquadro = Tema.Apple.Misura.padding(16, 18)
        static let spazioRiquadri: CGFloat = 12

        /// Verde se sale, rosso se scende, il colore del testo se è zero.
        static func segno(_ v: Double) -> Color {
            abs(v) < 0.5 ? C.inchiostro : (v > 0 ? coloreSalita : coloreDiscesa)
        }
    }
}
