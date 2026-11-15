import SwiftUI

// Impostazioni del tema Apple (Design/template-apple-specifica.md §4.6, riferimenti PIE i01-i09).
// Le viste stanno in Shell/AppImpostazioni.swift (barra laterale e pagina), Shell/ImpostazioniPagine.swift,
// Shell/ImpostazioniArchivio.swift e DesignSystem/Apple/ImpostazioniApple.swift (righe a card, voci della barra,
// anello del backup); le righe di sempre (ComponentiImpostazioni.swift) si disegnano così con `.impostazioniApple()`.
// Qui solo i valori.

extension Tema.Apple {
    enum Impostazioni {
        // MARK: Disposizione

        enum Disposizione {
            /// Barra laterale 260 (`.side`), la pagina comincia a 276 da sinistra.
            static let larghezzaLaterale: CGFloat = Misura.Laterale.impostazioni
            static let spazioLaterale: CGFloat = 16
        }

        // MARK: Barra laterale

        enum Laterale {
            static let superficie = Superficie.pannello
            static let raggio = Raggio.pannello
            static let padding = Misura.Padding.barraLaterale
            /// Voce `.rub` con padding 11×12, raggio 14, 2 fra le voci, titolo 14 bold.
            static let paddingVoce = Misura.padding(11, 12)
            static let raggioVoce: CGFloat = Raggio.voce
            static let fraVoci: CGFloat = 2
            static let titoloVoce = Carattere(dimensione: 14, peso: .bold)
            static let coloreVoce = Colore.inchiostro
            /// Sotto il puntatore `chip`, scelta `rgba(0,122,255,.13)`, il fondo cambia in 0,25 s.
            static let fondoSopra = Colore.chip
            static let fondoScelta = Colore.selezioneVoce
            static let durataFondo = 0.25
            static var animazioneFondo: Animation { .easeInOut(duration: durataFondo * Tema.Apple.Moto.ritmo) }
            /// Prisma ha più sezioni del template: sono raccolte sotto etichette `.lbl` (la prima senza).
            static let etichetta = Carattere.etichetta
            static let coloreEtichetta = Colore.inchiostro2
            #if os(macOS)
            /// Migliorie d'uso 30: occhiello dei gruppi come nel template (`.lbl.ig`: 13 sopra, 4 sotto).
            static let sottoEtichetta: CGFloat = 4
            static let sopraGruppo: CGFloat = 13
            #else
            static let sottoEtichetta: CGFloat = 8
            static let sopraGruppo: CGFloat = 16
            #endif
            static let rientroEtichetta: CGFloat = 12
            /// Piede: archivio locale e versione, `.k` piccolo, 12 sopra.
            static let piede = Carattere(dimensione: 11.5, peso: .regular)
            static let colorePiede = Colore.inchiostro3
            static let sopraPiede: CGFloat = 12
            static let spazioPiede: CGFloat = 2
            /// Pallino verde dell'archivio locale nel piede.
            static let pallinoPiede: CGFloat = 6
            static let colorePallinoPiede = Colore.verde

            /// Migliorie d'uso 30: il campo «Cerca nelle impostazioni» in cima alla colonna (`.impQ`): alto 34, raggio 10,
            /// fondo `chip`, lente 15 `ink3`, testo 13,5; 2 sopra e 10 sotto (solo Mac).
            enum Cerca {
                static let altezza: CGFloat = 34
                static let raggio: CGFloat = 10
                static let fondo = Colore.chip
                static let paddingOrizzontale: CGFloat = 11
                static let spazio: CGFloat = 8
                static let lente = Carattere(dimensione: 15, peso: .regular)
                static let coloreLente = Colore.inchiostro3
                static let testo = Carattere(dimensione: 13.5, peso: .regular)
                static let coloreTesto = Colore.inchiostro
                static let sopra: CGFloat = 2
                static let sotto: CGFloat = 10
                static let simbolo = "magnifyingglass"
            }

            /// Migliorie d'uso 31: l'etichetta accanto alla voce (`.impSt`): 11 semibold, padding 2×7, capsula; attenzione
            /// arancio al 16% con il testo `arancioTesto`, errore rosso al 13% con il testo rosso. Il numero di «Da
            /// sistemare» sta nella stessa pillola; a zero la spunta verde 16.
            enum EtichettaStato {
                static let carattere = Carattere(dimensione: 11, peso: .semibold, tabellare: true)
                static let padding = Misura.padding(2, 7)
                static let fondoAttenzione = Colore.arancio.opacity(0.16)
                static let testoAttenzione = Colore.arancioTesto
                static let fondoErrore = Colore.rosso.opacity(0.13)
                static let testoErrore = Colore.rosso
            }
            static let spunta = Carattere(dimensione: 16, peso: .regular)
            static let coloreSpunta = Colore.verde
            static let simboloSpunta = "checkmark.circle.fill"
        }

        // MARK: Da sistemare

        /// Migliorie d'uso 31: la pagina «Da sistemare» (titolo `.h2`, 4 sotto; la frase 13,5 `inchiostro2`, 14 sotto;
        /// l'occhiello «A posto» 18 sopra e 8 sotto; la spunta verde 20 nelle righe a posto).
        enum DaSistemare {
            static let sottoTitolo: CGFloat = 4
            static let frase = Carattere(dimensione: 13.5, peso: .regular)
            static let coloreFrase = Colore.inchiostro2
            static let sottoFrase: CGFloat = 14
            static let sopraOcchiello: CGFloat = 18
            static let spunta = Carattere(dimensione: 20, peso: .regular)
            static let coloreSpunta = Colore.verde
        }

        // MARK: Risultati della ricerca

        /// Migliorie d'uso 30: le righe dei risultati hanno a destra la pillola con il nome della pagina (12 semibold,
        /// padding 4×10, fondo `chip`) e «Apri», 8 fra l'una e l'altro.
        enum Risultati {
            static let pillola = Carattere(dimensione: 12, peso: .semibold)
            static let colorePillola = Colore.inchiostro2
            static let fondoPillola = Colore.chip
            static let paddingPillola = Misura.padding(4, 10)
            static let spazio: CGFloat = 8
        }

        // MARK: Pagina

        enum Pagina {
            /// Titolo della sezione `.h2` (21 bold), 4 sopra e 14 sotto.
            static let titolo = Carattere.h2
            static let coloreTitolo = Colore.inchiostro
            static let sopraTitolo: CGFloat = 4
            static let sottoTitolo: CGFloat = 14
            /// Fra i gruppi di righe (il template ha un solo gruppo per sezione).
            static let spazioGruppi: CGFloat = 22
            /// Colonna leggibile (i rendimenti di confronto prendono tutta la larghezza).
            static let larghezzaMassima: CGFloat = 760
            /// La pagina scorre: un filo d'aria a destra per non toccare il bordo e in fondo sopra il dock.
            static let margine = EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 6)
        }

        // MARK: Righe

        enum Riga {
            /// Card senza ombra, padding 16×20, 10 fra una riga e l'altra; titolo 15 bold e `.k`; il controllo a destra.
            static let superficie = Superficie.cardPiatta
            static let raggio = Raggio.card
            static let padding = Misura.Padding.rigaImpostazione
            static let fraRighe: CGFloat = 10
            static let spazioControllo: CGFloat = 16
            static let titolo = Carattere.titoloRiga
            static let coloreTitolo = Colore.inchiostro
            static let spiegazione = Carattere.secondario
            static let coloreSpiegazione = Colore.inchiostro2
            static let sottoTitolo: CGFloat = 2
            /// Avvertenza sotto la spiegazione (backup non riusciti, permessi negati).
            static let avvertenza = Carattere.secondario
            static let coloreAvvertenza = Colore.scadenza
            /// Icona di vetro accanto al titolo (Scorciatoie, Strumenti).
            static let spazioIcona: CGFloat = 12
            /// Un controllo che non c'è più posto per affiancare va sotto il testo.
            static let spazioControlliAffiancati: CGFloat = 8
        }

        // MARK: Gruppi e note

        enum Gruppo {
            /// Titolo di un gruppo di righe: `.lbl` 12 semibold maiuscolo, 8 sotto.
            static let etichetta = Carattere.etichetta
            static let coloreEtichetta = Colore.inchiostro2
            static let sottoEtichetta: CGFloat = 8
            static let rientroEtichetta: CGFloat = 4
        }

        enum Nota {
            static let carattere = Carattere.secondario
            static let colore = Colore.inchiostro2
            static let rientro: CGFloat = 4
            /// Una riga di avviso dell'archivio (sola lettura, copie non leggibili).
            static let coloreErrore = Colore.rosso
        }

        // MARK: Stato a destra della riga

        enum Stato {
            /// Pallino 8 e testo 13 semibold («● Pronto»).
            static let pallino: CGFloat = 8
            static let spazio: CGFloat = 6
            static let carattere = Carattere(dimensione: 13, peso: .semibold)
            static let coloreTesto = Colore.inchiostro
            static let ok = Colore.verde
            static let attenzione = Colore.arancio
            static let errore = Colore.rosso
            static let neutro = Colore.inchiostro3
        }

        // MARK: Panoramica

        enum Tessera {
            static let superficie = Superficie.tile
            static let raggio = Raggio.tile
            static let padding = Misura.Padding.tile
            static let etichetta = Carattere.secondario
            static let coloreEtichetta = Colore.inchiostro2
            static let valore = Carattere(dimensione: 22, peso: .bold, tracking: -0.4, tabellare: true)
            static let coloreValore = Colore.inchiostro
            static let nota = Carattere(dimensione: 12, peso: .regular)
            static let coloreNota = Colore.inchiostro2
            static let spazio: CGFloat = 4
            static let sottoTesta: CGFloat = 6
            static let larghezzaMinima: CGFloat = 200
            static let fraTessere: CGFloat = 12
            static let fondoSopra = Colore.chip
        }

        // MARK: Archivio e backup

        enum Backup {
            /// Card del backup: padding 22×24, senza ombra, 24 fra l'anello e il testo, 12 sotto.
            static let superficie = Superficie.cardPiatta
            static let raggio = Raggio.card
            static let padding = Misura.padding(22, 24)
            static let spazio: CGFloat = 24
            static let sottoCard: CGFloat = 12
            /// Anello 110/12 verde (`anello1`).
            static let anello: CGFloat = 110
            static let spessore: CGFloat = 12
            static let colore = Colore.anello1
            static let opacitaBinario = Grafico.Anello.opacitaBinario
            /// Il backup non dice quanto manca: l'anello sale fino a qui in 1,6 s e aspetta la fine.
            static let frazioneAttesa: Double = 0.92
            /// Dall'attesa al pieno, a backup finito.
            static let durataChiusura = 0.35
            static var animazioneChiusura: Animation { Moto.Curva.backup.animazione(durataChiusura) }
            /// ✓ al centro (26) nel verde dell'anello; a riposo senza backup il simbolo del giro in `inchiostro2`.
            static let spunta = Carattere(dimensione: 26, peso: .bold)
            static let coloreSpunta = Colore.anello1
            static let attesa = Carattere(dimensione: 24, peso: .regular)
            static let coloreAttesa = Colore.inchiostro2
            /// Errore: il punto esclamativo arancio.
            static let coloreErrore = Colore.arancioTesto
            /// Titolo 17 bold e `.k` 4 sotto.
            static let titolo = Carattere(dimensione: 17, peso: .bold, tracking: -0.2)
            static let coloreTitolo = Colore.inchiostro
            static let spiegazione = Carattere.secondario
            static let coloreSpiegazione = Colore.inchiostro2
            static let sottoTitolo: CGFloat = 4
            /// I numeri dell'archivio (clienti, appuntamenti, attività) sotto la card dell'archivio.
            static let numero = Carattere(dimensione: 22, peso: .bold, tracking: -0.4, tabellare: true)
            static let coloreNumero = Colore.inchiostro
            static let etichettaNumero = Carattere.secondario
            static let coloreEtichettaNumero = Colore.inchiostro2
            static let fraNumeri: CGFloat = 28
        }

        // MARK: Profilo

        enum Profilo {
            /// Card padding 22×24, avatar 64 «DV» 22 semibold bianco sul gradiente, 18 fra avatar e nome.
            static let superficie = Superficie.cardPiatta
            static let raggio = Raggio.card
            static let padding = Misura.padding(22, 24)
            static let spazio: CGFloat = 18
            static let sottoCard: CGFloat = 12
            static let avatar: CGFloat = Misura.Avatar.molto
            static let iniziali = Carattere(dimensione: 22, peso: .semibold)
            static let coloreIniziali = Color.white
            static let avatarAlto = Colore.avatarDVAlto
            static let avatarBasso = Colore.avatarDVBasso
            /// Nome 19 bold, sotto `.k`.
            static let nome = Carattere(dimensione: 19, peso: .bold, tracking: -0.3)
            static let coloreNome = Colore.inchiostro
            static let ruolo = Carattere.secondario
            static let coloreRuolo = Colore.inchiostro2
            /// Il campo del nome nel popover.
            static let larghezzaCampo: CGFloat = 220
            static let paddingPopover = Misura.padding(14, 16)
        }

        // MARK: Sala («Luce» giro 8)

        /// Impostazioni › Sala: i campi degli imprevisti in riga (mesi o importo, probabilità, fonte) e i testi.
        enum Sala {
            static let spazioCampi: CGFloat = 6
            static let campoMesi: CGFloat = 56
            static let campoImporto: CGFloat = 90
            static let campoProbabilita: CGFloat = 56
            static let campoFonte: CGFloat = 160
            static let campoTesto: CGFloat = 380
            static let carattereCampi = Carattere.secondario
        }

        // MARK: Il nome dei canali (migliorie d'uso 38)

        /// Il campo del nome di un canale (`.impIn` e `campoCh` del template): pallino 12 del colore del canale, campo
        /// largo 150 e alto 32, raggio 9, filo, fondo della carta, testo 13,5 semibold; al fuoco l'anello blu al 35%.
        /// A destra l'etichetta del canale com'è adesso.
        enum CampoCanale {
            static let larghezza: CGFloat = 150
            static let altezza: CGFloat = 32
            static let raggio: CGFloat = 9
            static let pallino: CGFloat = 12
            static let carattere = Carattere(dimensione: 13.5, peso: .semibold)
            static let coloreTesto = Colore.inchiostro
            static let fondo = Colore.cardPiena
            static let filo = Colore.separatore
            static let spessoreFilo: CGFloat = 1
            static let anelloFuoco = Colore.accento.opacity(0.35)
            static let spessoreAnello: CGFloat = 2
            static let paddingOrizzontale: CGFloat = 10
            static let spazio: CGFloat = 10
        }

        /// Gli occhielli della pagina Profilo (`.lbl` 16 sopra, 4 sotto; la nota dei canali 13,5, 10 sotto).
        enum ProfiloCanali {
            static let sopraOcchiello: CGFloat = 16
            static let sottoOcchiello: CGFloat = 4
            static let sottoOcchielloAvvio: CGFloat = 8
            static let nota = Carattere(dimensione: 13.5, peso: .regular)
            static let coloreNota = Colore.inchiostro2
            static let sottoNota: CGFloat = 10
            static let rientro: CGFloat = 4
        }
    }

    // MARK: Le tre domande del primo avvio (migliorie d'uso 38)

    /// La scheda del primo avvio (`apriAvvio` del template): larga 640, contenuto alto almeno 300, sul vetro sopra la
    /// scrivania con il velo; il contenuto di ogni pagina entra da destra di 14 pt in 320 ms (curva `--out`).
    enum PrimoAvvio {
        static let larghezza: CGFloat = 640
        static let altezzaMinima: CGFloat = 300
        static let raggio: CGFloat = Raggio.dettaglioAperto
        static let padding: CGFloat = 28
        static let bordo: CGFloat = 40
        static let superficie = Superficie.vetroSopra
        static let velo = Colore.velo
        static let entrataY: CGFloat = 18
        static let entrataScala: CGFloat = 0.97
        static var animazione: Animation { Moto.Curva.uscita.animazione(0.48) }
        /// Il cambio di pagina: da destra di 14 pt, 0,32 s.
        static let spostamentoPagina: CGFloat = 14
        static var animazionePagina: Animation { Moto.Curva.uscita.animazione(0.32) }
        /// Pagina 1: il logo 54 a sinistra, 20 dal testo.
        static let logo: CGFloat = 54
        static let coloreLogo = Colore.logo
        static let spazioLogo: CGFloat = 20
        static let occhiello = Carattere.etichetta
        static let coloreOcchiello = Colore.inchiostro2
        /// `.avT`: titolo 28 bold, 4 sopra e 8 sotto.
        static let titolo = Carattere(dimensione: 28, peso: .bold, tracking: -0.6)
        static let coloreTitolo = Colore.inchiostro
        static let sopraTitolo: CGFloat = 4
        static let sottoTitolo: CGFloat = 8
        /// `.avS`: testo 15, interlinea 1,55, al più 520 di larghezza, 10 sotto.
        static let testo = Carattere(dimensione: 15, peso: .regular, interlinea: 6)
        static let coloreTesto = Colore.inchiostro2
        static let larghezzaTesto: CGFloat = 520
        static let sottoTesto: CGFloat = 10
        /// I tre punti della pagina 1: pallino blu 7, testo 14,5, 5 sopra e sotto.
        static let pallinoPunto: CGFloat = 7
        static let colorePallino = Colore.accento
        static let punto = Carattere(dimensione: 14.5, peso: .regular)
        static let colorePunto = Colore.inchiostro
        static let spazioPunto: CGFloat = 10
        static let paddingPunto: CGFloat = 5
        /// Pagina 2: la scheda dei due canali (padding 6×18, senza ombra, 14 sopra) e la nota 10 sotto.
        static let paddingSchedaCanali = Misura.padding(6, 18)
        static let sopraScheda: CGFloat = 14
        static let rigaCanale = Carattere(dimensione: 14, peso: .regular)
        static let paddingRigaCanale: CGFloat = 8
        static let nota = Carattere.secondario
        static let coloreNota = Colore.inchiostro2
        static let sopraNota: CGFloat = 10
        /// Pagina 3: le tre opzioni (`.avO`): padding 13×16, raggio 16, filo, fondo della carta, 8 fra l'una e l'altra;
        /// cerchio 20 con il filo di 2 del binario, la scelta con il filo blu (anello 1) e il cerchio pieno a 6.
        static let paddingOpzione = Misura.padding(13, 16)
        static let raggioOpzione: CGFloat = 16
        static let fondoOpzione = Colore.cardPiena
        static let filoOpzione = Colore.separatore
        static let filoScelta = Colore.accento
        static let spessoreFiloOpzione: CGFloat = 1
        static let spessoreFiloScelta: CGFloat = 2
        static let sottoTitoloOpzione: CGFloat = 2
        static let spazioOpzioni: CGFloat = 8
        static let spazioOpzione: CGFloat = 14
        static let sopraOpzioni: CGFloat = 12
        static let cerchio: CGFloat = 20
        static let filoCerchio: CGFloat = 2
        static let filoCerchioScelto: CGFloat = 6
        static let coloreCerchio = Colore.binario
        static let titoloOpzione = Carattere(dimensione: 15, peso: .bold)
        static let testoOpzione = Carattere.secondario
        static let coloreTestoOpzione = Colore.inchiostro2
        static var animazioneScelta: Animation { Moto.Curva.molla.animazione(0.25) }
        /// Il piede: i punti delle pagine (`PuntiPagine`, come l'introduzione), 18 sopra; i pulsanti a destra.
        static let sopraPiede: CGFloat = 18
        static let spazioPulsanti: CGFloat = 8
    }
}
