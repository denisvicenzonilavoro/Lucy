# Migliorie d'uso · Mac — cosa resta da fare

Una sezione per miglioria: ciò che il giro non ha potuto fare (o ha fatto solo in parte) e va ripreso.

## 7. Testi piccoli più leggibili

Fatto: `inchiostro2`, `inchiostro3` e il nuovo `arancioTesto` (#B4530B / #F5A94A) nel tema Apple, `scadenza` che diventa
`arancioTesto`, il tema di prima allineato (`inchiostroSecondario`, `inchiostroTerziario`), una sessantina di token di
testo arancione passati ad `arancioTesto` (più tre usi diretti nelle viste: nota del backup, contatore del sinistro,
«fuori» del radar), la prova del contrasto (`ProvaCalcoliLeggibilita` in `--prova-calcoli`). Tutto solo sul Mac
(`#if os(macOS)`): su iPhone e iPad `arancioTesto` vale l'arancione pieno e i grigi restano quelli di prima.

Resta:
- **Istantanee**: rigenerarle tutte sul Mac (chiare e scure) e aggiornare la pagina delle anteprime; guardare per prime
  «400-vetrina-apple», «410-scrivania-apple», Agenda, Studio › Parcelle e le scadenze.
- **Token rimasti all'arancione pieno** perché colorano insieme un pallino e il suo testo, o sono timbri e glifi grandi
  (da rivedere guardando le istantanee): `Tema.Apple.Impostazioni…Stato.attenzione` («● Pronto»),
  `Tema.Apple.Tavolo.coloreInAttesa`, `Tema.Apple.Vera…nonPronto` (testo e pallino in `VeraScrivania`),
  `Tema.Apple.FaseCinqueVera.avviso`, i timbri della notte (`piuTardi`, `rimandata`), `Tema.Apple.Ovunque…coloreConflitto`,
  `Colori.Note.fissata` (il ◆). Se uno di questi è un testo piccolo, dividerlo in due token (segno e testo).
- **Tema di prima**: `Tema.Colore.arancio` (#FF9500) e i suoi token non sono toccati (la specifica parla solo del tema
  Apple); `scadenzaVicina` e simili restano com'erano.
- **Segni con `inchiostro3`** (assi, tratteggi, maniglia di ridimensionamento): diventano più scuri come nel template; se
  qualche tratteggio pesa troppo nelle istantanee, un token a parte per i segni.
- I file `Tema.Apple+Telefono.swift`, `Tema.Apple+TavoloiPad.swift` e `Tema.Apple+Luce.swift` (iPhone, iPad e glifi)
  non sono passati in rassegna: arriveranno con l'aggiornamento di iPhone e iPad.

## 8. Il totale non è più blu Alleanza

Fatto: il token `Tema.Apple.Colore.totale` (#0F2433 / #E3ECF2, solo sul Mac; su iPhone e iPad vale `anello2`), la linea,
l'area e il punto di oggi del grafico del portafoglio in Posizioni (`Grafico.Portafoglio.coloreStoria`), Clienti › Nel
tempo (`Clienti.NelTempo.colorePassato` e la stima senza proposte, con il «━» della legenda) e «Il patrimonio nel tempo»
di Posizioni (`Colori.Analisi.lineaPatrimonio`, linea «Com'è oggi» e legenda, prima color sabbia). Spessori invariati
(2,6 e più). Anelli, aree, Studio, Mercato, Radar e la carta dei PDF non cambiano.

Resta:
- **Istantanee**: rigenerare sul Mac «420-posizioni-portafoglio» (chiara e scura), «421-posizioni-con-proposte»,
  «434-clienti-nel-tempo», «435-clienti-nel-tempo-passato» e guardare «298-scrivania-vera-portafoglio-canali»; aggiornare
  la pagina delle anteprime. In chiaro controllare che la linea del totale non si confonda con il testo.
- Il capitolo «Nel tempo» della vista del cliente del template (righe 3300-3302) non ha oggi una vista corrispondente
  nell'app: quando nascerà, userà `Colore.totale`.
- iPhone e iPad (anche il tavolo dell'iPad, che legge `Clienti.NelTempo`) prendono il colore con il loro aggiornamento.

## 10. Le stesse parole ovunque

Fatto: l'elenco unico `enum Parole` (Shell/ParolePrisma.swift) con le parole che restano e, nel commento, quelle che
spariscono; nel glossario, sezione «Le parole di Prisma», le voci «Da fare», «Mostra al cliente», «Tutti i clienti» e «Il
quadro» (solo sul Mac, chiavi sotto `#if os(macOS)`), e il dossier spiegato senza «scheda» né «attività»; l'occhiello di
Analisi 360 non dice più «Il centro della consulenza» ma «Previdenza, protezione, investimenti e risparmio di una persona»
(solo sul Mac); «Preparami l'incontro» nel pulsante di Analisi 360, e la scrivania e la scheda dell'impegno lo prendono da
`Parole`. Prova in `--prova-calcoli`: le quattro voci nel glossario e nessun'altra app «centro della consulenza».

Resta (con le migliorie che rifanno quelle schermate, come dice la specifica, usando le costanti di `Parole`):
- «Mostra al cliente» al posto di «Modalità cliente» (pulsanti e menu di PrismaApp.swift) → miglioria 1.
- «Tutti i clienti» → 2; «Da fare» al posto di Notifiche, Promemoria come nome dell'elenco, «Da non dimenticare» → 3;
  «Il quadro» al posto di «Check-up» e «Panoramica» nel dossier → 5; «Cerca» al posto di «Cerca ovunque» (scrivania,
  menu «Vai», guida) → 6; «Vera» al posto dei nomi tecnici e gli spunti di Vera «Prepara l'incontro» (VeraScrivania,
  MiniVera, domanda della scrivania in StatoScrivania) e «Check-up completo» → 9.
- «Per il cliente · Per te» → 22 (con la voce «Prospetto e report» del glossario); «Tono · Invia con» → 26; «Da sistemare»
  → 31; «Dimostrazione» al posto di «Dati di prova» (anche nella guida) → 37; «In essere», «Proposta», «Riesame» dove
  compaiono «Attive», «In corso», «Ipotesi», «Preventivo» come stato di una posizione.
- Non toccati, da decidere guardando le istantanee: il titolo della mossa del giorno «Prepara l'incontro con …»
  (`MossaDelGiorno.titolo`, con la sua prova), il pulsante «Prepara l'incontro» del dettaglio dell'Agenda (miglioria 18)
  e la routine di Vera «Prepara l'incontro» (nome della routine, con le sue prove).
- Il controllo statico nel workflow (grep sulle stringhe tra virgolette in Sources/Prisma/Shell contro le parole che
  spariscono, con eccezioni) ha senso quando le migliorie 1-9 avranno cambiato i testi: oggi fallirebbe.
- **Istantanee**: rigenerare sul Mac Analisi 360 (occhiello e pulsante) e la guida col glossario; controllare che
  l'occhiello più lungo non si tronchi nella testata della finestra.

## 9. Niente nomi tecnici in vista (e l'assistente si chiama Vera)

Fatto (solo sul Mac, `#if os(macOS)`): i testi dello stato in `TestiStatoVera` (Vera/TestiStatoVera.swift); riquadro
di Vera sulla scrivania con pallino di 7 (verde / arancio) e «Pronta» / «Non pronta» (token in
`Tema.Apple.Scrivania.Vera`); colonna dell'app Vera e testata della Vera della scrivania «Vera · pronta» / «Vera · non
pronta» con la spiegazione senza nomi tecnici, «Verifica» e «Apri Impostazioni › Vera»; tolta dalla colonna la riga
«Smista: regole e Qwen · Apple spento» con «Motori» (in Impostazioni › Vera c'erano già «Due velocità» e «Motore
esterno», con il nome e il motivo del motore nella riga «Motore»); titolo «Vera non è pronta» per il messaggio di Vera
senza motore, con i confronti tutti su `TestiStatoVera.eTitoloNonPronta` (riconosce anche «Qwen non è pronto» delle
conversazioni salvate prima); palestra, routine, piano a passi, firma del verbale del copilota, mini Vera («Vera si
avvia sul Mac…») e Messaggi («Scritto da Vera», senza il modello) senza «Qwen»; lo spunto «Preparami l'incontro»
(`Parole.spuntoIncontro`) nella mini Vera e nella Vera della scrivania. Prove aggiornate in ProvaNucleoVera e
ProvaScenariVera.

Resta:
- **L'etichetta del motore sotto le risposte** («Sul Mac · Qwen…», `EtichettaMotore.per`): resta com'è per decisione
  (regola bloccata del cervello grande), finché l'utente non dà il via alla proposta di 9.6.
- Altri testi con «Qwen» in vista, meno frequenti: VistePassiVera («Piano proposto da Qwen…»), VisteFaseTreVera
  («spiegati da Qwen», «Scritta da Qwen…»), VisteTreLivelliVera («Parole di Qwen»), VisteStileVera, VisteMotoriVera
  (pagina dei motori: lì il nome ha senso), CollegaStileShell, VerbaleCopilota («riscrivendo con Qwen»), NotaVocaleArrivo
  («Capito con Qwen»), AppIncontri («Proposta letta da Qwen»), ComponentiAppDocumenti («p. N · Qwen»), MotoreSintesi
  («serve Qwen sul Mac»), gli avvisi di StatoShell con il motivo di Ollama (commento del mercato) e il motivo tecnico
  nella mini Vera (`motivoNonPronta`). Da passare a «Vera» guardando le istantanee.
- «Check-up completo» negli spunti → miglioria 5 («Il quadro»).
- La riga «Due velocità» di Impostazioni › Vera dice ancora «Qwen sul Mac»: in Impostazioni il nome resta (9.2).
- **Istantanee**: rigenerare sul Mac «410-scrivania-apple», «296-scrivania-vera», «297-scrivania-vera-risposta»,
  «244-vera-mini-nonpronta», «251-impostazioni-vera», le scene dell'app Vera (colonna senza «Smista») e dei Messaggi;
  controllare che «Apri Impostazioni › Vera» accanto a «Verifica» stia nella colonna stretta di Vera.
- iPhone e iPad tengono i testi di prima (anche il titolo «Qwen non è pronto») fino al loro aggiornamento.

## 2. Un solo posto per scegliere il cliente

Fatto (solo sul Mac, `#if os(macOS)`):
- **Il modello**: `clienteAttivoId == ""` vale «Tutti i clienti» (`StatoShell.tuttiIClienti`). Il valore vuoto resta
  com'è nella ricostruzione dell'indice (ArchivioPezzi) e nell'unione di «Prisma ovunque». `DatiPrisma.init(from:)` mette
  il primo cliente solo se la chiave manca. In SceltaClienteShell.swift ci sono `scegliCliente(_:avviso:)` e i recenti in
  memoria (`clientiRecenti`, al più tre). Il setter di `clienteAttivoId` aggiorna i recenti, così ci entrano anche le
  scelte silenziose. Ci sono anche `rubricaOrdinata` (in `ricavato`) e `apriSceltaCliente()`.
- **`portafoglio` e `veraPortafoglio`** sono proprietà calcolate che leggono `tuttiIClienti`. Scriverle a true sceglie
  «Tutti»; scriverle a false torna al cliente più recente (o al primo della rubrica, perché chi scrive false vuole un
  cliente; la specifica diceva «resta Tutti»). Su iPhone e iPad restano campi veri (`portafoglioProprio`,
  `veraPortafoglioProprio`). Con «Tutti i clienti», `entraModoCliente` mostra il cliente scelto per ultimo.
- **La barra**: la pillola del cliente e il pannello «Di chi parliamo?» (Shell/PannelloSceltaCliente.swift), con il
  campo che prende il fuoco, «Tutti i clienti», «Recenti» e «Tutti · N». Invio sceglie il primo trovato; Esc o un clic
  fuori chiudono. L'avviso compare solo per le scelte fatte apposta. Token in Tema.Apple+SceltaCliente.swift, testi in
  `TestiSceltaCliente`.
- **Selettori tolti**: il segmentato «Cliente | Portafoglio» di Posizioni (al suo posto «‹ Tutto il portafoglio») e
  quello di Vera, la tendina di Vera, dei Prospetti e di `DossierRail` (resta il nome), le pillole di Analisi 360 e della
  Sala (nella Sala restano in modalità cliente), il menu dei clienti dell'Agenda (al suo posto «Solo <Nome> ✕»). La
  rubrica di Clienti sceglie con `scegliCliente`.
- **Vuoti**: `VuotoCliente` (DesignSystem/Apple/VuotoClienteApple.swift) per Analisi 360 (non quando è aperto uno
  strumento), Sala e Prospetti (non per il prospetto del portafoglio). In Clienti con «Tutti i clienti» compaiono «La tua
  rubrica» e la frase del template.
- **Prove**: `ProvaSceltaCliente` (in `--prova-vera`) controlla i setter, i recenti, il ritorno al cliente di prima, la
  modalità cliente, il pannello e l'unione di «Prisma ovunque». In `ProvaBackupArchivioPezzi` c'è il caso «Tutti i
  clienti» riletto e ricostruito.
- **Istantanee nuove**: 1020 barra-cliente, 1021 barra-tutti-i-clienti e 1022 pannello-cliente (queste tre chiare e
  scure); 1024 analisi-, 1025 sala- e 1026 prospetti-senza-cliente; 1027 agenda-solo-cliente.

Resta:
- **CI da guardare con attenzione**: ora una scelta vale per tutte le app. Le prove che scrivono `portafoglio = true` o
  `veraPortafoglio = true` cambiano il cliente attivo; prima Vera poteva stare sul portafoglio con Posizioni su un
  cliente, e i passaggi automatici di Vera al portafoglio (tagliando, mercato, routine, «Fallo tu», agenda in blocco)
  portano tutta Prisma su «Tutti i clienti». Se una prova cade su questo, va riletta la scrittura (vedi 2.3 punto 2).
  Da guardare anche `--prova-fluidita` (`stato.portafoglio = …` ora cambia il cliente) e `--prova-carico` (pannello con
  200 clienti).
- **Agenda, Attività e Note** non sono diventate letture del cliente, perché le prove di oggi contano tutti gli impegni
  e tutte le note con un cliente attivo. L'Agenda e le Attività seguono solo le scelte fatte con `scegliCliente` (barra,
  vuoto, rubrica, «‹ Tutto il portafoglio», portafoglio a true); una scelta silenziosa (`clienteAttivoId = …`) non le
  filtra. Il filtro delle Note resta a sé (miglioria 65).
- **Prospetti**: il tipo `.portafoglio` non è diventato una lettura di `tuttiIClienti`. Con «Tutti i clienti» si apre il
  vuoto: il prospetto del portafoglio si raggiunge dalla scrivania o da Posizioni.
- **Ancora da fare**:
  - «La tua rubrica» con le quattro cifre e il «Da fare» (con la miglioria 11).
  - Vera che parla del cliente della barra, con domande d'esempio e «Parliamo di» (miglioria 27).
  - `ContestoFinestra` senza il nome (miglioria 4).
  - La pillola che non si apre nella vista pulita (miglioria 1).
  - La tendina di Incontri (`AppIncontri`, `MenuTendina` sul cliente attivo) e le schede Obiettivi e Documenti ospitate
    con il vuoto proprio.
  - «Mostra al cliente» e «Salva PDF» dei Prospetti che aprono il pannello (oggi il vuoto copre l'app).
  - La chiusura del dettaglio aperto dell'app davanti alla scelta: Posizioni lo fa già; Analisi 360 (area aperta) e gli
    altri no.
- **Istantanee**:
  - La scena «pannello-cliente-ricerca» non c'è: il testo della ricerca è uno `@State` del pannello.
  - Da rigenerare sul Mac le scene con `s.portafoglio = true` («65-portafoglio», «64-app-aperte», ora con l'Agenda su
    tutti, «420-posizioni-portafoglio», «116-portafoglio-seguito»…) e quelle di Analisi 360 e della Sala senza pillole.
  - Da guardare: che il pannello stia allineato alla pillola e che il nome lungo si tagli entro 230.
- iPhone e iPad restano com'erano.

## 4. Una riga sola in testa alla finestra

Fatto (solo sul Mac, `#if os(macOS)`): `FinestraInterna.rigaTesta` è la riga unica alta 60 con `ChiusuraFinestra` (cerchio
28 `chip`, ✕ 12, rosso #FF5F57 e segno bianco al passaggio, scala 0,9 premuta, aiuto «Chiudi (esc)»), `IconaApp` 26,
titolo `titoloIntestazione` 17 bold, sottotitolo 12 maiuscolo, testo a destra (`AppPrisma.testoDestro`, oggi solo Vera:
«Tutto resta su questo Mac») e le azioni dell'app (`PulsanteComeSiUsa` e la nuova vista `AzioniApp`, in `TestaFinestra`,
che non legge lo stato dei gesti). La riga cede spazio con `ViewThatFits`: occhiello, testo a destra, poi pulsanti con la
sola icona. Trascinare sposta, doppio clic ingrandisce o rimette, menu contestuale con «Riduci nel dock», «Ingrandisci» /
«Rimetti a posto», «Affianca a sinistra» e «Chiudi». `ContenutoApp` sul Mac non disegna più `IntestazioneApp` (iPhone e
iPad sì). Token in `Tema.Apple.RigaTesta` (Tema.Apple+DockFinestre.swift). Esc chiude la finestra davanti
(`MonitorEscFinestra`, Shell/EscFinestra.swift): prima prova i pulsanti con Esc della finestra (`performKeyEquivalent`),
e non chiude con testo in scrittura, pannelli della shell, sovrapposizioni, nota dall'iPhone, Territorio e palestra
mentre Vera scrive.

Resta:
- **Esc da verificare sul Mac vero**: che `NSWindow.performKeyEquivalent` faccia scattare i `.keyboardShortcut(.cancelAction)`
  di SwiftUI dentro le finestre (dettagli, schede, palco della Sala, presentazione) prima della chiusura. Se non lo fa,
  Esc chiuderebbe la finestra con un dettaglio aperto: allora aggiungere le condizioni a `nienteSopra` o togliere «(esc)»
  dall'aiuto e il monitor (vedi 4.6). Da guardare anche gli `onExitCommand` che non sono nei campi di testo (Territorio e
  palestra esclusi apposta; `PannelloSpazi` e il pannello del cliente sono coperti dalle loro bandierine).
- **Istantanee**: rigenerare tutte le scene con una finestra aperta (chiare e scure) e aggiornare la pagina delle
  anteprime; per prime «413-scrivania-apple-finestra», «430-clienti-dossier», «420-posizioni-portafoglio» e le
  «finestra-stretta» (234, 235, 236, 238), dove la riga cede spazio. Il passaggio sulla chiusura richiede uno screenshot.
- **Tele fisse** (Territorio, Radar, Campagne, Passaparola): guadagnano circa 26 punti in altezza; controllare nelle
  istantanee che si adattino.
- **Dettaglio**: `Tema.Apple.Misura.DettaglioAperto.areaFinestra` si centra ancora a 92 dall'alto della finestra (38 + 54
  del template di prima): se nelle istantanee il dettaglio sembra basso, passarlo a 60 + 12.
- `--prova-fluidita`: guardare che trascinare e ridimensionare non facciano crescere i corpi contati (le azioni sono in
  `TestaFinestra`, che riceve solo app e «attiva»).
- Le azioni senza nome quando lo spazio manca sono materia della miglioria 12.

## 6. Barre più corte: «Aggiungi» raccoglie cinque pulsanti, un solo «Cerca»

Fatto (solo sul Mac, `#if os(macOS)`; iPhone e iPad restano come prima):
- Posizioni: nella riga in testa solo «Aggiorna valori» (fuori dalla modalità cliente, come prima) e il blu «Aggiungi ⌄»,
  che apre il menu del Mac (`apriMenuAzioni`, ComponentiAppDocumenti.swift) con Posizione, Proposta, Dal catalogo, filo,
  Importa…, Incolla da Excel e Inquadra con l’iPhone (non in modalità cliente). Ogni voce tiene il suo aiuto (suggerimento
  della voce) e il blocco in sola lettura di prima. Il pulsante «◎ Inquadra» accanto ai segmenti del Portafoglio è tolto
  (`PulsanteInquadra` resta nello Smontaggio vuoto).
- Clienti: pulsante diviso «Nuovo cliente | ⌄», la freccia apre Importa… e Incolla da Excel (al posto del menu «…»).
- «Come si usa» non sta più nella riga in testa: il «?» della barra (e il menu Aiuto › Guida di Prisma) apre la guida
  dell'app davanti (`StatoShell.paginaGuidaDavanti`) o, con la scrivania, la pagina nuova `PaginaGuida.scrivania` («La
  scrivania» in cima all'elenco delle app, con il logo). La scheda in grande ha in fondo la riga del template e «Le parole
  di Prisma». Testi aggiornati: passo 2 di Posizioni («Aggiungi»), passo 1 della ricerca (la lente), il punto dell'introduzione
  su «Come si usa».
- Scrivania senza «Cerca ovunque»; nella barra «Cerca» è un tasto tondo con la lente (aiuto «Cerca in Prisma (⌘K)»).
- Istantanea nuova «1060-guida-scrivania» (chiara e scura, IstantaneeBarreCorte.swift).

Resta:
- **Istantanee**: rigenerare sul Mac «420-posizioni-portafoglio», «600…» (Inquadra), «225-guida-posizioni»,
  «226-guida-clienti», «410-scrivania-apple», «616-scrivania-luce», le scene «-finestra-stretta» e guardare la nuova
  «1060-guida-scrivania»; aggiornare la pagina delle anteprime.
- **Il menu «Aggiungi» aperto** non si vede nelle istantanee (è un `NSMenu`, sotto il puntatore e non sotto il pulsante
  come nel template: larghezza almeno 236, voci alte 36 semibold): chiedere uno screenshot all'utente; se serve la
  posizione esatta del template, un menu disegnato in SwiftUI sotto il pulsante.
- **Pulsante diviso**: oggi sono due capsule blu accostate (1 pt); il template le unisce (metà sinistra arrotondata a
  sinistra, filo bianco al 40% fra le due). Serve una forma del tema per le due metà.
- **Inquadra senza iPhone collegato**: la voce apre la scena di oggi (con il ponte spento si trascina una foto o un PDF);
  il rimando a Impostazioni › iPhone e iPad arriva con la miglioria 39.
- **Testi della guida delle altre app** (`GUIDA` del template, righe 3014-3029): non riscritti in questo giro; vanno
  aggiornati app per app solo dove descrivono ciò che l'app fa già (indice del dossier, settimana a sette giorni, «Da
  fare» unico… arrivano con le loro migliorie). Il passo 2 della scrivania del template («Spunta le cose da fare:
  spariscono da tutta Prisma») è stato scritto senza la seconda parte: va ripreso con la miglioria 3.

## 3. Un solo «Da fare» al posto di notifiche, scadenze e promemoria

Fatto (solo sul Mac, `#if os(macOS)`; iPhone e iPad tengono campanella, notifiche e scadenze):
- **Una fonte sola**: `MotoreDaFare` con due ingressi nuovi, accesi solo sul Mac in `ingressiDaFare`: `conScadenze`
  (posizioni in essere in scadenza entro 90 giorni o scadute da meno, `Tipo.scadenza`; compleanni dei prossimi 7 giorni in
  «Questa settimana», `Tipo.ricorrenza`; tutti con `Fatto.segna`) e `perTe` (le attività senza cliente diventano voci «Per
  te» con le iniziali dell'utente; in modalità cliente no). `nastro(_:massimo:)` per il nastro intero. Prove in
  `ProvaDaFare` (`--prova-calcoli`).
- **Stato** (Shell/StatoDaFare.swift): `numeroDaFare` (= totale del nastro in cache), `nastroDaFareCompleto(cliente:)`
  (in `ricavato`, chiave con l'ora), `fattoDaFare` con la traccia `FattoDaFare` in memoria e `annullaUltimoFattoDaFare`
  (attività riaperta, segno tolto, incontro di riesame tolto e fotografie rimesse, conformità e consensi di prima),
  `aggiungiDaFare` (attività di oggi del cliente della barra o «Per te», 70 caratteri), `apriDaFare(soloCliente:)`,
  `apriVoceDaFare`. Anche «Segna come fatto» delle schede di Posizioni passa da `fattoDaFare` (si annulla dal pannello).
  Prova `ProvaDaFareShell` in `--prova-vera`.
- **Barra**: la pillola «◎ Da fare» con il numero (rosso, verde a zero) al posto della campanella; la goccia dell'acqua va
  sulla pillola. **Pannello** `PannelloDaFare` (al posto di `PannelloNotifiche`, stesso `pannelloNotifiche`): «Da fare» con il
  numero, «Tutti | Solo <Nome>» con un cliente scelto (o «in ordine di tempo»), i gruppi con tutte le voci («OGGI · 3»),
  «Tutto fatto.», in fondo «+ Aggiungi» (campo con Invio/Esc) e «Fatte oggi: N · Annulla l’ultima».
- **Riga comune** `RigaDaFare` (cerchio da spuntare con il passaggio verde, pallino del tono, titolo, «<Cliente> · <quando>»,
  canali; esce scivolando di 16 in 0,32 s), parametri `conNome`, `conCanali`, `titoloACapo`, `filoAgenda`. Token in
  `Tema.Apple.ElencoDaFare` (Tema.Apple+BloccoBarraNotifiche.swift), testi in `TestiDaFare`.
- **Dettaglio al centro** fuori da Posizioni (`StratoDettaglioDaFare` nella shell, con il presentatore del tema):
  `DettaglioDaFareApple` di Posizioni (reso interno) o, per le attività, la scheda semplice «<quando> · scritta da te». Esc
  non chiude la finestra sotto mentre è aperto.
- **Scrivania**: «In scadenza entro 90 giorni» diventa `RiquadroDaFareScrivania` («Da fare» con il numero, «[altre N · ]Apri
  tutto ›», tre voci con la riga comune). Guida della scrivania: «Spunta le cose da fare: spariscono da tutta Prisma.»
- **Istantanee nuove** (chiare e scure, IstantaneeDaFare.swift): 1030 da-fare-pannello, 1031 da-fare-solo-cliente, 1032
  da-fare-aggiungi, 1033 da-fare-annulla, 1034 da-fare-dettaglio, 1035 da-fare-scritta-da-te.

Resta:
- **Gli arrivi e gli avvisi**: le notifiche che il nastro non ha ancora (appuntamenti di oggi, impegni passati senza esito,
  dati da confermare nei documenti, valori da registrare, schede prodotto, clienti da ricontattare, beneficiari, proposte
  fuori esperienza, adeguatezza incompleta, pratiche e sinistri fermi, carta e note dall'iPhone, carte della notte, capsule,
  traguardi, fine anno, mercato, backup) stanno in testa al pannello come «Arrivati e avvisi» (si aprono come prima, non si
  spuntano). La tabella di 3.3 punto 1 va completata: impegni senza esito → miglioria 19; pratiche e sinistri fermi → 33;
  backup e impostazioni → Impostazioni › Da sistemare (31); le voci per cliente (ricontattare, beneficiari, esperienza,
  adeguatezza) e le voci «Per te» dei documenti come voci del nastro; poi «Arrivati» solo per carta, note, notte e capsule.
- **La mossa del giorno** resta di `MotoreMossaDelGiorno` e il riquadro «Da fare» parte dalla prima voce del nastro (senza
  «dopo la mossa del giorno»): da fare l'allineamento proposto in 3.6 (la voce della mossa prima, il riquadro dalla seconda,
  «✓ Fatto» nella mossa).
- **Rubrica** con «Tutti i clienti» (cinque voci, miglioria 11), **dossier** «Da fare per <Nome>» con «Apri tutto ›» su «Solo
  <Nome>» (miglioria 5), **Agenda** «Da fare oggi» al posto di «Da fare e da ricordare» e via «Da non dimenticare» (miglioria
  18, `RigaDaFare(filoAgenda: true, conCanali: false)` è pronta), **Vera** senza «Da non dimenticare» (miglioria 27), il
  collegamento «<N> da fare per <Nome> ›» di Posizioni.
- **Notifiche viste**: `notificheViste` e il numero delle «nuove» restano nel codice comune (le usano iPhone, iPad e le
  prove); sul Mac non si vedono più. I promemoria del Mac (notifiche di sistema) leggono ancora `MotoreNotifiche.promemoria`:
  da far leggere al nastro.
- Annullare un riesame non toglie le promesse raccolte alla chiusura dell'incontro (di solito nessuna: l'incontro nasce vuoto).
- **Prove da guardare in CI**: `--prova-fluidita` («apri il centro notifiche» ora apre il pannello «Da fare») e
  `--prova-carico` (nastro intero con 200 clienti nel pannello); il Territorio ora conta anche scadenze e compleanni fra le
  cose da fare dei clienti.
- **Istantanee**: rigenerare sul Mac «412-scrivania-apple-notifiche» (ora il pannello «Da fare»), «410-scrivania-apple»,
  «616-scrivania-luce», «118-scrivania-seguito», «117-notifiche-seguito», «133-notifiche-occasioni», «153-notifiche-conformita»,
  «738-notifiche-traguardo» e le nuove 1030-1035; aggiornare la pagina delle anteprime. Il passaggio sul cerchio e l'uscita
  della riga chiedono uno screenshot.

## 5. Il dossier parte dal quadro del cliente

Fatto (solo sul Mac, `#if os(macOS)`): `QuadroDossierApple` in Shell/DossierQuadro.swift con «Il quadro di <Nome>»,
«Il cliente in 30 secondi ›» (non in modalità cliente) e «Apri Analisi 360 ›» nella testata, i quattro riquadri delle
aree da `stato.aree360` (anello 76/9, cifra al centro, i mesi su due righe, inclinazione 4°; un clic apre Analisi 360
con il dettaglio dell'area già aperto, `StatoShell.dettaglioArea360DaAprire` consumato da `PresentatoreAree360`), la riga
`RigaDatiAnalisi` (barra al più 200, percentuale che si conta, «N da completare ›» o «Dati completi») che apre l'elenco
`DettaglioDatiAnalisiApple` nel presentatore del dossier (con «Completa», la croce e «Ripristina»); a destra il sussurro,
«Da fare per <Nome>» (righe `RigaDaFare`, «Apri tutto ›» su «Solo <Nome>»), «Prossimo incontro», «Da ricordare», poi
«Da festeggiare» e i sinistri. In modalità cliente niente riga dei dati né «Da fare». Token in
`Tema.Apple.Clienti.Panoramica.Quadro`, `proporzione` 1,32 sul Mac. Istantanee nuove 1050-1052 (chiare e scure).

Resta:
- **Istantanee**: rigenerare sul Mac 430, 431, 152 e le nuove 1050-1052; controllare che la colonna di destra non
  allunghi troppo la griglia (nel template «Da ricordare» si taglia con `overflow:hidden`; qui va a capo per intero).
- **Il dettaglio dell'area in Analisi 360** nasce al centro e non dalla card: all'apertura della finestra la griglia
  non è ancora montata. Se si vuole l'origine sulla card, aprirlo dopo la prima comparsa della griglia.
- **La guida del template** (il giro guidato «Il dossier parte dal quadro» con `indica('#quadroC')`) non è riportata.
- `DatiAnalisiApple` e la card «Il cliente in 30 secondi» restano per iPhone e iPad; sul Mac non si usano più.

## 1. «Mostra al cliente»: un pulsante solo e una vista pulita con il suo quadro

Fatto (solo sul Mac, `#if os(macOS)`): lo stato in memoria in `StatoShell` (`vistaCliente`, `sceltaMostra`,
`schermataNeutraMac`, `schedaMostra`, `menuUscitaMostra`, `appPrimaDellaVista`, `avvisoVistaVisto`) e le funzioni in
Shell/MostraAlCliente.swift (`apriMostraAlCliente`, `mostra(_:)`, `cambiaCapitolo`, `mostraProspetto`, `fineMostra`,
`alternaMostraAlCliente`, `mostraNeutra`, `escMostra`), sempre sopra la modalità cliente di oggi (se questa si spegne, la
vista si chiude). Nella barra la pillola «Mostra al cliente» dopo «Da fare»; nella vista pulita restano marchio (che non
porta alla scrivania), pillola del cliente (non si apre) e l'avatar con l'anello, che apre il menu «Fine: torna al lavoro
⌥⌘M» / «Schermata neutra». Il pannello di scelta (Shell/PannelloMostraAlCliente.swift) con le quattro righe e la schermata
neutra, o l'elenco «A chi vuoi mostrare Prisma?». La vista (Shell/VistaCliente.swift): dock, scrivania e finestre nascosti
(tranne la Sala nel suo capitolo), la barra dei capitoli, «Il quadro» (frasi del motore puro `FrasiCliente`, in cache con
`ricavato`), «Le posizioni» (patrimonio netto, «Dove sono», righe con il canale), «Gli obiettivi» (anello 200 e
avanzamento), «Nel tempo» (oggi, a 10 e 20 anni e con le proposte da `analisiDossier(id).patrimonio`, grafico con la
linea del totale e le proposte tratteggiate), il piede «Come sono calcolate queste cifre» (testo dalle costanti di
`IpotesiCalcolo`) e le parole toccabili (scheda «Le parole» dal glossario, voce nuova `divarioPrevidenziale`). Testo almeno
«Grande». La schermata neutra copre tutto tranne l'acqua. Nella vista pulita non si aprono altre app (solo la Sala), né
mini Vera, ricerca, guida e voce; Esc chiude solo neutra, scheda e menu. Il menu «Vai»: «Mostra al cliente» / «Fine: torna
al lavoro» ⌥⌘M, le altre voci e la guida spente nella vista. Prospetti: «Mostra al cliente» al posto di «Presenta
all'incontro» (la presentazione dentro la vista pulita); Sala: il blu «Mostra al cliente» nella testata. Prove:
`ProvaCalcoliFrasiCliente` (`--prova-calcoli`) e `ProvaMostraAlCliente` (`--prova-vera`). Istantanee nuove 1010-1019
(chiare e scure), «70-modo-cliente» e «693-sala-modo-cliente» ora nella vista pulita.

Resta:
- **Il blocco chiude la vista pulita** (come oggi chiude la modalità cliente, e la prova di Vera lo vuole): la specifica
  dice «allo sblocco si torna dov'eri». Per farlo il blocco dovrebbe tenere la modalità cliente quando la vista è aperta.
- **Gli avvisi interni con il nome di altri clienti** (note e carta dall'iPhone, carte della notte, «Prisma ovunque»,
  routine) non sono ancora trattenuti mentre si mostra: vanno messi in coda e mostrati dopo «Fine» (§1.3 punto 12).
- **«Sull’iPad sul tavolo»** fa come il template (apre Prospetti con l'avviso), non avvia ancora il tavolo; se l'iPad non è
  collegato dovrebbe portare a Impostazioni › iPhone e iPad (miglioria 39).
- **«Un prospetto»** mostra il report del check-up del cliente: la scelta del prospetto (e la versione «Per il cliente»
  della miglioria 22) resta da fare.
- **Le parole** stanno nel piede di ogni capitolo, non dentro le frasi (il template le sottolinea nel testo); da unire con
  il componente della miglioria 66. «Gli obiettivi» dice «traguardo a <mese anno>» (la data dell'obiettivo), non una data
  d'arrivo stimata, che Prisma oggi non calcola.
- **Nel capitolo «La Sala»** la barra dei capitoli si sovrappone al fondo della finestra della Sala; la chiusura della
  finestra non è nascosta; la Sala aperta su un'esperienza resta aperta solo entrando da lì (`tieni` non è distinto).
- **Movimento**: il pannello entra con `entrataScheda` (dal basso, 0,97); l'ombra al passaggio delle righe non c'è (solo
  la salita di 2). Il menu dell'avatar è una scheda disegnata, non un menu del Mac.
- `ContrassegnoModoCliente` resta come ripiego quando la modalità cliente è accesa senza la vista (presentazione della
  Sala); la guida (testi «Modalità cliente» di iPhone e iPad) non è stata toccata. Il «Presenta» del palco della Sala e il
  «Mostra al cliente» della Biblioteca si allineano con le migliorie 58 e 35.
- `--prova-fluidita`: non c'è ancora una misura del cambio di capitolo (i ricavati sono in cache).
- **Istantanee**: generarle sul Mac (1010-1019, 70, 693) e guardare in particolare il quadro con il testo «Grande»
  (altezza 548 dei riquadri con frasi lunghe), la colonna delle posizioni e il grafico «Nel tempo»; aggiornare la pagina
  delle anteprime.

## 13. Obiettivi: si vede se ci arriva

Fatto: `ArrivoObiettivo` (già raggiunto, in tempo, in ritardo, senza versamenti, «Con questo versamento non ci arriva»)
dai mesi di `CurvaObiettivo`, i testi in `TestiObiettivoApple` (`rigaScadenza`, `durata(mesi:)`, `notaScadenza`), la
capsula `StatoArrivoObiettivo` (DesignSystem/Apple, token in `Tema.Apple.Clienti.Obiettivi`), la card con «… al mese ·
scadenza …» e lo stato, il dettaglio con l'anello «oggi» (la quota della card, fermo col cursore), lo stato che segue il
cursore e la nota sulla scadenza; lo scarto non ripete più la scadenza. Tutto solo sul Mac (`Obiettivi.mostraStato`):
iPhone e iPad tengono la riga e l'anello di prima. Il conteggio per l'indice `StatoShell.obiettiviNonInTempo(_:)`,
ricordato nella voce del cliente di `CacheClienti`. Prova in `--prova-calcoli` (`ProvaCalcoliArrivoObiettivo`),
istantanea nuova `1023-uso-obiettivi-stato` (chiara e scura).

Resta:
- **Indice del dossier (miglioria 11)**: il numero arancio accanto a «Obiettivi» va messo in `ContiIndiceDossier` leggendo
  `stato.obiettiviNonInTempo(id)` (non c'era ancora l'indice in questo giro).
- **Istantanee**: rigenerare sul Mac 432, 433, 282, 283, 98 e la nuova 1023 (chiara e scura) e aggiornare la pagina
  delle anteprime; nella 1023 controllare che l'anticipo casa risulti davvero «In ritardo» (il versamento lo ricava la
  scena dal 75% del necessario: se il conto collegato basta già, resta verde).
- **Carico**: controllare con `--prova-carico` che le curve dei molti obiettivi non svuotino di continuo la memoria di 24
  curve (il conteggio è ricordato per cliente, quindi le curve si chiedono una volta per cambio).
- La riga facoltativa «Alla scadenza copre il 78%» nel dettaglio (13.6) non è stata aggiunta: solo se l'utente la vuole.

## 17. Le priorità in ordine: 1, 2, 3

Fatto: `PrioritaAree360` (Motori) con l'ordine senza doppioni dai primi tre bisogni della ruota (gli stessi della scheda
Bisogni; con un doppione le capsule sono due, il quarto bisogno non si pesca) e, solo sul Mac e senza ruota, l'ordine del
template dall'area più scoperta (escluse le aree al 100%, gli investimenti dall'80% e quelle che non si misurano). Le card
di Analisi 360 mostrano la capsula `CapsulaPriorita` «Priorità {n}» (token in `Tema.Apple.Aree360.Area`: 11 bold con
tracking 0,2, padding 2×9, la prima arancio tenue, le altre neutre) con l'aiuto «Da dove partire con {nome}…» o «Dall'area
più scoperta: la ruota dei bisogni è vuota». La scheda Bisogni mette su ogni riga la capsula della card («Priorità 1 ·
Protezione», la stessa per due bisogni della stessa area) e sotto la nota del template solo quando le numerazioni
coincidono, altrimenti «Sulle schede di Analisi 360 due bisogni della stessa area contano una volta.»; con la ruota vuota
nessuna nota. Tutto solo sul Mac (`Area.numeraPriorita`): iPhone e iPad tengono «★ Priorità» (stesse aree, senza
ripiego). Prova in `--prova-calcoli` (`ProvaCalcoliPrioritaAree360`), istantanea nuova `1075-uso-dossier-bisogni` (chiara
e scura).

Resta:
- **Istantanee**: rigenerare sul Mac 440 (chiara e scura), 99, 300, 301 e la nuova 1032 e aggiornare la pagina delle
  anteprime; nella 1032 controllare che le capsule stiano accanto al collegamento senza andare a capo nella colonna
  accanto alla ruota.
- **Indice del dossier (miglioria 11)**: quando la sezione Bisogni passa nel tema Apple, la capsula e la nota vanno
  riprese da `BisogniCliente.prioritaVista` (oggi la scheda usa ancora i caratteri di Rubrica).

## 11. Il dossier ha un indice

Fatto (solo sul Mac, `#if os(macOS)`): con un cliente scelto la colonna di sinistra di Clienti è `IndiceDossierApple`
(Shell/IndiceDossierApple.swift, larga 216 sul `pannello`, il dossier a 16): «‹ Rubrica» (`scegliCliente(nil)`, non in
modalità cliente), la testa del cliente (avatar 40, nome e motto), i tre gruppi di `SchedaCliente.indice` (La persona, Il
piano, Le carte) con le voci alte 32 e la scelta sul fondo accento al 13%. I numeri (`ContiIndiceDossier`, letti in un
colpo con `stato.contiIndiceDossier` in `ricavato`, chiave con l'ora): Panoramica le cose da fare (rosso pieno, non in
modalità cliente), Obiettivi quelli non in tempo della 13 (arancio tenue), Documenti da leggere o con differenze (neutro),
In regola le scadute (rosso tenue). Sul Mac il dossier non ha più segmentato né «Altro» (`DossierApple(schede: .nessuna)`,
cascata da `primoIndiceSenzaSchede`); in finestra stretta resta solo il dossier con la capsula «Sezione: … ⌄»
(`MenuSezioneDossier`, menu del Mac con i tre gruppi). «L'azienda» nell'indice per chi ha un'azienda o fa l'imprenditore
o il titolare (`SchedaCliente.mostraAzienda`), e per gli altri finché è la sezione aperta; `cambiaCliente` usa la stessa
regola. Token in `Tema.Apple.Clienti.Indice`. Prova `ProvaCalcoliIndiceDossier` in `--prova-calcoli`. Istantanee nuove
1028-uso-dossier-indice (chiara e scura) e 1029-uso-dossier-documenti (1020-1022 erano già della barra del cliente);
«431-clienti-dossier-altro» rinominata «431-clienti-dossier-in-regola». iPhone e iPad restano con segmentato e «Altro».

Resta:
- ~~«Aggiungi un'azienda…»~~ e ~~«Nuovo cliente» solo nella rubrica~~: fatti con la miglioria 12 (menu «Altro ⌄» e azioni
  del dossier nella riga in testa).
- **La testata `sezT`** («Anagrafica · i dati della persona» con «Modifica», «Note · … si salvano da sole»…) non è stata
  portata sulle sezioni senza titolo proprio: da fare guardando le istantanee, sezione per sezione.
- **La sfumatura in fondo all'indice** (come le altre colonne): il tema non ha ancora un modificatore comune; l'indice
  scorre senza indicatori e senza sfumatura.
- **«La tua rubrica» con le quattro cifre e il «Da fare»** (Tutti i clienti, miglioria 2 §2.3 punto 7) non è in questo giro.
- **Istantanee**: rigenerare sul Mac 430 e -scuro, 431-clienti-panoramica-apple, 431-clienti-dossier-in-regola, 432, 433,
  434, 1023, 1075, 1050-1052 e le nuove 1028-1029; controllare che il nome lungo si tagli nella testa dell'indice e che
  con la finestra stretta compaia «Sezione: … ⌄». `--prova-fluidita`: guardare i corpi di `IndiceDossierApple` nel passo di
  Clienti (i conti sono in `ricavato`).

## 12. Più spazio al dossier

Fatto (solo sul Mac; l'iPad tiene testata, tessere e segmentato): con un cliente scelto nella Rubrica (o in modalità
cliente) la riga in testa alla finestra di Clienti è `RigaTestaDossier` (Shell/RigaTestaDossier.swift, da
`RigaTestaClienti` dentro `TestaFinestra`): «Il dossier di {nome di battesimo}.» (`StatoShell.nomeDiBattesimo`), «{età}
anni · {professione}» e a destra i canali (o «Canale da scegliere»), «☆ Preferito» / «★ Preferito» (arancio delle scritte
quando è preferito, avviso con il nome intero), «Modifica» (apre il modulo di oggi con `stato.richiestaModificaCliente`,
che AppClienti consuma), «Altro ⌄» e «Prospetti» (primario). «Altro ⌄» c'è sempre (decisione 12.6): «Analisi 360», «Un
anno insieme» e, per chi non ha «L'azienda» nell'indice, «Aggiungi un'azienda…» (tolto dall'Anagrafica). Le azioni non
diventano mai icone: `ViewThatFits` toglie prima il sottotitolo, poi passa «Modifica» e infine «Preferito» in «Altro ⌄»
(con le etichette dei canali compatte). ⌘N resta anche nel dossier (pulsante nascosto). La testata nella pagina non c'è
più (`SchedeDossier.conRigaInTesta`); le quattro tessere stanno solo in Panoramica, in cima e ferme sopra la sezione che
scorre (sotto 18, la sezione parte a 116); nelle altre sezioni il contenuto parte subito a 22. Cascata: tessere 0-3 e
contenuto da 4 in Panoramica, da 0 altrove; con la capsula «Sezione: … ⌄» la capsula è 0 (token in
`Tema.Apple.Clienti.Moto`, `primoIndiceSenzaSchede` tolto). Token della riga in `Tema.Apple.Clienti.RigaDossier`.
Istantanee nuove 1036-uso-dossier-riga-in-testa (chiara e scura) e 1037-uso-dossier-riga-in-testa-stretta (1022 era già
del pannello del cliente). Nessun campo d'archivio nuovo.

Resta:
- **«· x € l'anno» nella quarta tessera**: il template scrive «l'anno», ma `RiepilogoPosizioni.valoreProposte` è il
  versamento iniziale più un anno di premi, non un valore annuo; la tessera resta «· x €» finché non c'è un motore che
  dia il premio annuo delle proposte (o l'utente sceglie la parola).
- **`TestataDossierApple`**: le varianti `compatti` con le icone restano, perché la testata ora serve solo all'iPad; si
  tolgono con il giro dell'iPad.
- **Le altre app**: le azioni della riga in testa delle altre app passano ancora alla sola icona quando lo spazio manca
  (`TestaFinestra`, miglioria 4); «sempre con il nome» qui vale solo per il dossier.
- **Istantanee**: rigenerare sul Mac tutte le scene del dossier (430-434, 1023, 1028-1029, 1075, 1050-1052) e le nuove
  1036-1037; controllare che nella stretta compaia «Altro ⌄» con le azioni intere e che il titolo lungo non spinga fuori
  «Prospetti»; la scena del report di fine anno (`IstantaneeAnnoInsieme`) parte da Prospetti e non tocca la testata.
  `--prova-fluidita`: guardare i corpi di `RigaTestaDossier` (legge solo il cliente attivo e la vista di Clienti).

## 16. Un solo avviso sulle stime in Analisi 360

Fatto (solo sul Mac, interruttore `Tema.Apple.Aree360.Stime.unAvvisoSolo`; iPhone e iPad come prima): nella riga del
segmentato «Le quattro aree | Rispetto alle famiglie come la sua» c'è a destra la capsula `AvvisoStimeAnalisi360`
(Analisi360Apple.swift), «Stime in uso · {n} dati da completare ›» in arancio con il bordo arancio al 35%, o «✓ Nessuna
stima: i dati ci sono tutti» in verde; il numero è `daCompletare.count`, lo stesso dell'elenco che apre. Non in modalità
cliente. Il clic apre, nato dalla capsula (id `DettagliAree360.idStime`, misura `QuadroDossier.misuraDati`), lo stesso
`DettaglioDatiAnalisiApple` della riga del quadro del dossier (una vista sola, senza stato proprio, due porte):
«Dati per l'analisi · {nome}», «Completi al {n}%», «Un elenco solo, lo stesso in Clienti e in Analisi 360…» e sotto ogni
voce l'ipotesi che Prisma usa (o «Finché manca, Prisma usa una stima») con « · pesa su {aree}» (`TestiCompletezza.rigaStima`).
«Completa» porta dove il dato si completa, come prima. Tolti: la riga della completezza nella testata, lo stato delle
ipotesi sulle card (resta la riga dei canali), la frase sulle ipotesi nel piede (resta l'avvertenza sulle somme dei
piani), «da verificare con il cliente e sui contratti» nella nota della cornice e il blocco «Le ipotesi» della colonna
sulla griglia delle aree (resta «Riparti dalle posizioni»). Restano, come da proposta 16.6, le pillole «stimato» e il
piede «Ipotesi da verificare con il cliente» dentro un'area aperta. Token in `Tema.Apple.Aree360.Stime`. Istantanee nuove
1038-uso-analisi360-stime-aperte e 1039-uso-analisi360-nessuna-stima (1030-1031 sono già del pannello «Da fare»).
Nessun campo d'archivio nuovo.

Resta:
- **«Dato completato: una stima in meno»**: il template completa al volo e mostra l'avviso; nell'app «Completa» apre il
  modulo del dato (16.3 punto 4), quindi l'avviso non c'è. Si può aggiungere quando il dato salvato toglie la voce.
- **Istantanee**: rigenerare sul Mac 440 e -scuro, 443, 444, 17-analisi360, 111-analisi360-ipotesi-stimate (che ora sul
  Mac mostra la capsula al posto degli stati delle card), 1050 (l'elenco del dossier ha la frase nuova e la riga sotto
  ogni voce) e le nuove 1038-1039; controllare che la capsula non vada a capo accanto all'etichetta «di prova» delle
  famiglie in una finestra stretta.

## 14. Le posizioni prima di tutto

Fatto (solo sul Mac; l'iPad tiene la colonna con i filtri e la pagina lunga): con un cliente scelto la colonna di
Posizioni è `IndicePosizioniApple` (Shell/IndicePosizioniApple.swift, larga 236, voci e testa dell'indice del dossier,
`VoceIndiceCornice` ora non più privata): «‹ Tutto il portafoglio» (non in modalità cliente), la testa del cliente, «Le
posizioni › Quadro e posizioni» con il numero delle sole posizioni in essere, «Le analisi» (cinque voci, una schermata
ciascuna), «Collegati» (Il dossier, Analisi 360, Prodotti, Simulatore, Confronto, proposta 14.6) e «Archivio locale». Nel
portafoglio resta la colonna di prima. La schermata è `@State` di `AppPosizioni` (`VistaPosizioniCliente`, decisione
14.6): le ancore «patrimonio», «resistenza», «coerenza», «costi», «successione» la aprono e si consumano al giro dopo
(dossier, notifiche, «Da sistemare» del portafoglio e istantanee funzionano senza toccarli); cambiando cliente si torna
a «Quadro e posizioni» con i filtri azzerati; `areaPosizioniDaAprire` porta al quadro. Cambio di schermata come nel
dossier (uscita y +6 in 0,13 s, poi cascata; calma e istantanee come lì). «Quadro e posizioni» è `QuadroPosizioniApple`
(Shell/QuadroPosizioniApple.swift): le quattro tessere sempre del cliente intero (niente più riepilogo rifatto sul
canale), con «all'anno · n contratti» / «nessun versamento a rate», «caso morte» (solo se le coperture sono tutte sulla
vita, altrimenti «n coperture») / «nessuna copertura», «per x €» / «nessuna», «Debiti» solo se ci sono; la card «Le
posizioni» con «{n} voci», segmentato «In essere | Proposte | Tutte», capsule dei canali (secondo clic toglie), capsula
dell'area con «✕», l'elenco a righe (`RigaPosizioneApple`, pigro, che scorre nella card e rientra a ogni filtro) e il
piede; a destra, larghe 392, «Ripartizione per area» con la legenda che filtra (`AppPosizioni.ripartizione(_:areaScelta:
scegli:)`, `VoceAreaRipartizione`) e «Per canale» senza le righe in scadenza (sono nell'elenco) con «{n} da fare per
{nome} ›» o «Niente da fare per {nome}.». Le cinque analisi sono `AnalisiPosizioniApple` (il pannello di oggi da solo, in
cima; senza dati una riga che dice perché e «Aggiungi una posizione»). Nella riga in testa «Le posizioni di {nome}.» e
«{n} in essere · {n} proposte · aggiornate adesso» (`TitoloRigaPosizioni`). Token in `Tema.Apple.Posizioni.Indice` e
`Tema.Apple.Posizioni.Quadro`. Istantanee nuove 1040-uso-posizioni-quadro (chiara e scura), 1041-uso-posizioni-filtro-area,
1042-uso-posizioni-coerenza, 1043-uso-posizioni-filtro-canale (1024-1027 erano già della scelta del cliente); 71 ora
apre la schermata della resistenza. Nessun campo d'archivio nuovo.

Resta:
- **Vuoto delle analisi con «Completa»**: la proposta 14.6 vuole anche il pulsante che apre il dato mancante
  (`stato.apriCompletamento` con la prima voce di `completezzaCliente(id)` che tocca quell'analisi); oggi c'è solo
  «Aggiungi una posizione». Serve una mappa voce di completezza → analisi.
- **Titolo grande delle analisi** (`PannelloAnalisi.titoloGrande`, 21 bold): non fatto, il pannello tiene il titolo 17
  della card; da decidere guardando le istantanee.
- **Altezza 92 delle tessere e 304 della ripartizione**: le tessere tengono l'altezza del loro contenuto e la colonna
  destra scorre da sola; i due token non ci sono.
- **«· x € l'anno» nella quarta tessera**: come nella miglioria 12, resta «per x €» (il valore non è annuo).
- **Dopo la scheda di una posizione** aperta da «Peso dei costi» o «Passaggio generazionale» si torna alla stessa
  schermata, ma lo scorrimento riparte dall'alto.
- **Gruppi 07 e 08**: chi vuole aprire una schermata delle posizioni (radar, smontaggio, «Apri le posizioni di …») scrive
  l'ancora di oggi (`stato.ancoraPosizioni = "coerenza"`), non una proprietà nuova.
- **Istantanee e prove sul Mac**: rigenerare 2, 9, 10, 71, 74, 76, 79, 95-97 e le nuove 1040-1043; misurare un cliente
  con 40 posizioni (l'elenco nella card) e `--prova-fluidita` con 200 clienti (il quadro non costruisce le analisi);
  `ProvaDelFuocoApple` e `ProvaSeguito` leggono «seguito», che resta del portafoglio.

## 15. La scheda di una posizione si legge dall'alto

Fatto (solo sul Mac; iPhone e iPad tengono la pagina lunga, `DettaglioPosizione.paginaLunga`): la scheda di una posizione
è `paginaMac` (Shell/SchedeDettaglioPosizione.swift). In cima la barra alta 34 con «‹ Le posizioni» (torna alla schermata
della miglioria 14 con i filtri di prima) e al più quattro azioni con il nome, il resto in «Altro ⌄» (proposta: «Segna
come in essere», «Esito…», «Altro ⌄» con Simula, Confronta, Adeguatezza, Valutazione, Prospetto, Modifica; in essere:
Simula, Confronta, Prospetto, Modifica, o «Apri un sinistro», Prospetto, Modifica per la protezione); «Elimina la
posizione…» è in «Altro ⌄» con la conferma di sempre; con poco spazio le secondarie passano in «Altro ⌄», mai icone sole.
Sotto la testata di oggi la frase (19 semibold) e le cifre (`TestiDettaglioPosizione.frase` e `.cifre`, Motori/
TestiDettaglioPosizione.swift: solo cifre dei motori, frase corta e tessera assente se manca un dato; «Rende all'anno» è il
rendimento dei versamenti o, senza, l'atteso netto con «atteso, al netto dei costi»; guadagno verde e perdita rossa con il
nuovo `KPI.coloreValore`), poi il segmentato delle schede che hanno contenuto (`SchedaPosizione.disponibili`: In breve,
Andamento, Costi e rischio o «La copertura», Adeguatezza, Contratto) e la sola scheda scelta. Tutte le sezioni di prima
ci sono ancora, ognuna nella sua scheda. Contratto: le sole righe piene e «Da completare · {n}» con i nomi in capsule e
«Completa i dati» (`campiVuoti`: solo i campi pertinenti al tipo). In fondo a In breve la striscia «{n} dati da
completare · … · Vedi ›». Le ancore «dettaglio-…» scelgono la scheda e poi scorrono al giro dopo (nuove «dettaglio-costi»
e «dettaglio-contratto»). `PillolaStato` sul Mac dice «Scade tra {n} giorni» e «Debito». Esc nella scheda fa un passo
indietro (EscFinestra.swift, dopo i pulsanti con Esc della finestra). Token in `Tema.Apple.Posizioni.SchedaDettaglio`.
Prova `ProvaCalcoliDettaglioPosizione` in `--prova-calcoli`. Istantanee nuove 1072-uso-posizione-in-breve (chiara e
scura), 1073-uso-posizione-contratto, 1074-uso-proposta (1027-1029 della specifica e 1050-1058 erano già presi o previsti); 10, 92,
94, 119 e 121 aprono ora la scheda giusta. Nessun campo d'archivio nuovo.

Resta:
- **«Completa i dati» sul primo campo vuoto**: apre «Modifica», ma `ModuloPosizione` non legge `\.fuocoModulo` (lo imposta
  solo `AppPosizioni` per la completezza): il fuoco sul primo campo vuoto va aggiunto nel modulo.
- **Rientro al cambio di scheda** (opacità e y +6 in 0,24 s del template): la scheda nuova compare subito.
- **Grafico piccolo di «Come sta andando»**: è `GraficoAndamento` intero (altezza fissa `Misure.Analisi.grafico`), senza
  una misura ridotta.
- **Testata**: resta `rigaIntestazione` di oggi (barretta 8×46, titolo `Tipo.profiloNome`); la barretta 5 e il titolo 24
  bold del template non sono passati.
- **Immobili**: «Debiti residui» e «Al netto dei debiti» al posto di «Mutuo residuo» (Posizione non distingue il mutuo).
- **iPad**: la pillola «Scade tra {n} gg» e «In essere» per i debiti restano com'erano (regola generale: iPhone e iPad con
  il loro aggiornamento; la specifica di gruppo voleva il ritocco anche lì).
- **Esc da verificare sul Mac vero**: che il passo indietro scatti con il fuoco fuori dalla scheda e non con un foglio
  aperto (alert di «Elimina», modulo).
- **Istantanee e prove sul Mac**: rigenerare 8, 10, 91-94, 106, 119, 121, 235 e le scene con le ancore «dettaglio-…»,
  più le nuove 1072-1074; aggiornare la pagina delle anteprime.

## 36. Il dock è in gruppi

Fatto: `AppPrisma.gruppiDockMac` e `dockMac` (sul Mac; `allCases` e `delDock` non cambiano, iPhone e iPad come prima),
il dock con un filo (`DivisoreDock`, tutti uguali) fra un gruppo e l'altro e i gruppi vuoti tolti in modalità cliente,
`DisposizioneDock.disposizione(gruppi:)` e `centroIcona(_:tra:gruppi…)` con i fili (le finestre escono e rientrano
dall'icona giusta), ⌥1…⌥9 sulle prime nove del dock in gruppi (fino a Messaggi; Territorio senza scorciatoia), il menu
Vai con un divisore fra i gruppi, la pagina Scorciatoie, le prove in `--prova-vera` (gruppi, scorciatoie, centri con e
senza modalità cliente), le scene «1125-uso-dock-gruppi» (chiara e scura) e «1126-uso-dock-gruppi-modo-cliente».

Resta:
- **Istantanee**: rigenerare sul Mac le scene con il dock in vista (410-415, 616, 617, scrivania di «Prisma istantaneo»)
  e la pagina Scorciatoie; controllare a 1440 e in «415-scrivania-apple-schermo-basso» che il dock con le icone
  ingrandite stia nella finestra (i quattro fili in più valgono circa 28 pt; se non sta, il token
  `Tema.Misura.Shell.divisoreGruppiMargine`). Guardare una finestra ridotta per verificare il genio verso l'icona.
- **CLAUDE.md**: aggiornare la frase sull'ordine del dock («Nel dock dopo Agenda, Messaggi e Prospetti…») con i gruppi
  nuovi quando la miglioria entra in main.
- `ProvaFluidita` apre ancora le app nell'ordine di `delDock` (lì l'ordine non conta).

## 30. Le impostazioni si cercano, in gruppi con un nome

Fatto (solo Mac; l'iPad resta com'era): la colonna con la Panoramica da sola e i gruppi «Prisma», «Il lavoro» (con
Moduli, Pratiche, Portafogli modello, Sala e Territorio accanto alle pagine del template) e «Aiuto» (Scorciatoie,
Strumenti) in `IndiceImpostazioni.gruppi`; «Per le prove» non c'è più; «Agenda e lavoro» si chiama «Agenda e orari»
sul Mac; il campo «Cerca nelle impostazioni» (`CampoCercaImpostazioni`, `stato.cercaImpostazioni` in memoria, svuotato
chiudendo Impostazioni; Esc svuota il campo pieno, nel campo vuoto chiude Impostazioni; ⌘F ci porta il cursore solo con
Impostazioni in primo piano); l'indice delle voci (`IndiceImpostazioni.voci`, circa 150 righe delle pagine del Mac) e la
pagina dei risultati con la pillola della pagina e «Apri» (svuota la ricerca, apre la pagina e scorre all'ancora); le
ancore «imp-<pagina>-<voce>» risolte da `paginaDellAncora`; i token `Laterale.Cerca` e `Risultati`, l'occhiello dei gruppi
13/4 come nel template; la prova `ProvaIndiceImpostazioni` in `--prova-calcoli`; le scene 1054 (chiara e scura) e 1055.

Resta:
- **Istantanee**: rigenerare sul Mac 470 (e scura), 471, 3, 90, 126, 134, 144, 85, 251, 516, 548 e guardare le nuove
  1054-1055; controllare che l'occhiello a 13/4 non stringa troppo la colonna (altrimenti tornare a 16/8 nei token).
- **L'indice è scritto a mano**: alcune righe che dipendono dai dati (l'elenco dei backup, le serie e le quote di
  Mercato, le zone, i modelli, i documenti delle proposte, le compagnie dei sinistri) sono una voce sola per gruppo, con
  la spiegazione nella forma fissa più utile; le righe di Ovunque solo del Mac acceso. Le migliorie 31, 37, 38 e 39, che
  cambiano Panoramica («Da sistemare»), Strumenti («Dimostrazione») e altre pagine, aggiornano l'indice con loro.
- **Ancore**: solo per gruppo (non per singola riga); nelle pagine senza ancora «Apri» porta in cima alla pagina.
- **Da provare sul Mac vero**: che il campo non prenda il fuoco da solo all'apertura (se lo prende, Esc nel campo vuoto
  chiude comunque Impostazioni, come sempre) e che ⌘F non disturbi la Biblioteca aperta dietro.

## 31. Si vede cosa resta da sistemare

Fatto (solo sul Mac): il motore puro `MotoreDaSistemare` (Motori/MotoreDaSistemare.swift, con `FattiDaSistemare`,
`VoceDaSistemare`, `EsitoDaSistemare` e i testi `TestiDaSistemare`), i fatti letti in `StatoShell.fattiDaSistemare()`
(Shell/StatoDaSistemare.swift: solo letture; i mancanti delle fatture con `ricavato("impostazioni-da-sistemare-fatture")`),
la pagina `PaginaDaSistemare` al posto delle quattro tessere della Panoramica («Da sistemare» / «Tutto a posto», «Tre cose,
poi Prisma è a posto.», «Sistema» blu che apre la pagina e la riga, occhiello «A posto» con la spunta verde), il titolo
della voce sul Mac «Da sistemare», nella colonna il numero in pillola arancio (o la spunta verde a zero) e accanto alle
pagine l'etichetta della cosa più grave al posto del pallino («mai fatto», «spenti», «da completare», «non pronta»…; in
rosso gli errori). Le condizioni dei pallini di prima (archivio, Vera, iPhone e iPad, Mercato) sono voci del motore. Vera
conta solo dopo la prima verifica (`StatoShell.veraNonVerificata`). In più, come proposto in §31.6: la riga del tagliando
dei dati quando l'elenco di oggi ha trovato qualcosa, e i backup «sullo stesso Mac» come cosa da sistemare. Voce «Da
sistemare» nell'indice della ricerca. Prove: `ProvaMotoreDaSistemare` in `--prova-calcoli`, e in `--prova-backup` la voce
«Nessun backup ancora» che sparisce dopo il backup. Istantanee nuove 1056 (chiara e scura), 1057, 1058 (per la sola
lettura `StatoShell.segnaSolaLetturaPerIstantanea()`, che nell'app non fa nulla). L'iPad tiene la Panoramica di prima.

Resta:
- **Istantanee**: rigenerare sul Mac 470/471, 1054/1055, «250-impostazioni-panoramica» (ora «Da sistemare») e le nuove
  1056-1058; guardare che l'etichetta più lunga («sullo stesso Mac», «non aggiornato») non stringa troppo il titolo delle
  voci della colonna (il titolo si riduce fino all'85%), e aggiornare la pagina delle anteprime.
- **§31.3 punto 6**, da controllare guardando le istantanee: le righe sotto un interruttore spento in Mercato («Dati di
  mercato»), «Prisma ovunque» e Notte devono essere attenuate, non nascoste (i promemoria lo fanno già).
- **«Lasciali spenti»** per i promemoria (§31.6): non fatto, servirebbe un campo in `Impostazioni`; i promemoria spenti
  contano come nel template.
- **La card del tagliando** resta anche nella pagina di Vera (l'uscita dalla colonna di Vera è della miglioria 27).
- **«N su M» dei dati per le fatture**: la frase dice «ne mancano N»; il totale richiederebbe un conteggio dei dati
  richiesti in `MotoreFattura`.
- I token vecchi della Panoramica (`Tema.Misura.Impostazioni`, `Tema.Apple.Impostazioni.Tessera`) restano per l'iPad.

## 38. I canali hanno il nome che scegli

Fatto (solo sul Mac): `NomiCanali` (Dati/NomiCanali.swift: `pulisci` toglie `< > & "` e i caratteri di controllo, gli
spazi ai lati, al più 18 caratteri; `scelti` riporta un nome vuoto a quello di base) e il campo
`Impostazioni.nomiCanali` (nil = «Alleanza» e «Indipendente»; letto con tolleranza, nell'indice dell'archivio con le
impostazioni, nei backup, nell'istantanea di «Prisma ovunque» come le altre impostazioni del Mac; entra nei calcoli in
cache). Il nome in uso sta in `NomiCanaliCorrenti` (protetto da un lucchetto: lo leggono motori e Vera) e in
`SegnaleNomiCanali` (osservato dalle etichette); li aggiorna `StatoShell.applicaNomiCanali()` al caricamento, a ogni
cambio delle impostazioni e al ripristino, prima di `versioneCalcoli`, solo sul Mac. `Canale.nomeBreve` legge il nome in
uso; `Canale.nome` con i nomi di base resta «Alleanza Assicurazioni» / «Denis Vicenzoni · Consulenza finanziaria», con un
nome scelto è il nome scelto (anche nei PDF, proposta §38.6.2); il logo Alleanza (vetro, stampa, capsula) solo con il
primo nome di base (`Canale.conLogo`), altrimenti il pallino blu. Impostazioni › Profilo sul Mac: «I tuoi canali» con la
nota, «Il primo canale» · «Blu, sempre.» e «Il secondo canale» · «Cuoio, sempre.» con `CampoNomeCanale` (l'etichetta
accanto cambia mentre si scrive, l'archivio a fine scrittura: Invio, fuoco perso, campo che sparisce), «Il primo avvio»
con «Rivedi». Le tre domande `PrimoAvvio` (Shell/PrimoAvvio.swift) al posto dell'introduzione dopo il primo sblocco, con
`PuntiPagine`, «Indietro», «Avanti» / «Comincia», frecce (non sulla pagina dei nomi), Invio ed Esc; la scelta
`OpzioneInizio`. Sostituite le scritte fisse più evidenti (legenda del Territorio, filtri di Posizioni e Prodotti,
segmenti del canale in importazione e documenti, Biblioteca, sinistri, Studio: «Produzione …», «Le tue aliquote …», il
fumetto degli incassi, la storia della settimana, le colonne del riesame, la Sala). Istruzioni della chat di Vera: il
canale si chiama come nella scheda. Prove `ProvaNomiCanali` in `--prova-calcoli` e i nomi nel backup in `--prova-backup`;
istantanee nuove 1064 (chiara e scura), 1065, 1066, 1067 (chiara e scura), 1068.

Resta:
- **CLAUDE.md**: la regola del canale («Alleanza = etichetta in vetro blu con il logo Alleanza; indipendente = …») va
  aggiornata dall'utente come in §38.6.1 (con un nome scelto l'etichetta perde il logo e mostra il nome, sempre nel suo
  colore). Non l'ho toccata.
- **Miglioria 37**: «Guardo Prisma con i clienti di prova» oggi mostra solo l'avviso «Si comincia con la dimostrazione»
  (i dati di prova ci sono già al primo avvio); con la 37 deve chiamare `accendiDimostrazione(.trentacinque)`, e «Porto i
  miei clienti» / «Parto da zero» devono spegnere la dimostrazione accesa (`spegniDimostrazione()`) prima di proseguire
  (`StatoShell.cominciaPrimoAvvio`, PrimoAvvio.swift).
- **«Come funziona» della guida** (§38.6.3): per ora resta nel «?» come scheda in più (alternativa della specifica), con
  la riga «Come funziona Prisma» di Impostazioni › Aspetto e la voce del menu Aiuto; le istantanee 222-224 e 229 restano
  quelle dell'introduzione. Se l'utente sceglie la proposta: togliere la scheda sul Mac e far aprire `PrimoAvvio` dal menu.
- **Scritte fisse rimaste**: testi in prosa che nominano la compagnia o il canale («Le percentuali che Alleanza ti
  riconosce…», le note di Studio sulle posizioni Alleanza senza decorrenza, coerenza e adeguatezza «nel canale
  Alleanza», le firme dei documenti «Consulente Alleanza Assicurazioni» nei Testi* dei PDF, il glossario, la guida, il
  copilota). Molti parlano davvero della compagnia; vanno decisi uno per uno guardando le istantanee.
- **Etichette che non osservano il nome**: le capsule dei canali si ridisegnano da sole (`SegnaleNomiCanali`); gli altri
  testi con `nomeBreve` cambiano al primo ridisegno della loro vista (di solito subito, perché il nome alza
  `versioneCalcoli`).
- **iPhone e iPad**: il campo arriva con «Prisma ovunque» ma i nomi restano quelli di base finché non si fa il loro giro.
- **Istantanee**: rigenerare sul Mac 252 e le scene con le etichette dei canali, guardare 1064-1068 chiare e scure (la
  pagina dei nomi deve stare in 640 con l'etichetta accanto al campo) e aggiornare la pagina delle anteprime.
- **Da provare sul Mac vero**: che Invio nel campo dei nomi non faccia anche «Avanti» (se lo fa, il nome si salva
  comunque quando la pagina cambia) e che il fuoco perso salvi il nome anche cliccando fuori dal campo.

## 39. iPhone e iPad: un collegamento solo

Fatto (solo Mac): Impostazioni › iPhone e iPad sotto lo schema ha «I tuoi dispositivi» (una card con una riga per
dispositivo, «visto …» e «Collegato» se visto da quando Prisma è aperta; in fondo «Un altro iPhone o iPad» con «Collega
con un codice» e, a collegamento acceso, «Scollega»), «Cosa fanno insieme al Mac» con le cinque righe del template («I
dati» = «Prisma ovunque», con sotto, rientrate e solo a copia accesa, «Lavora anche con il Mac spento», «Porta anche i
potenziali clienti», «Cartella» e «Passphrase»; «Vera», «Inquadra un documento», «Nota a voce», «Al tavolo» con i
quattro filtri nuovi), «Modifiche in attesa» con «Da decidere» e la nota dei due segreti (decisione 3). La scheda del
codice (`SchedaCollegaDispositivo`, sopra barra e dock come le tre domande) mostra il codice del ponte di oggi in grande,
senza scadenza (decisione 2), con «Nuovo codice». Campi nuovi `ImpostazioniPonte.modello/inquadra/nota/tavolo` (accesi
di base, letti con tolleranza, in `impostazioni.eve.ponte`, nei backup): `condividi` resta il collegamento generale e
l'ascolto si accende solo con lui e un codice, come prima; il server rifiuta i messaggi delle righe spente
(`ImpostazioniPonte.rifiuto`). Il registro dei dispositivi (`RegistroDispositivi`, solo in memoria) prende i nomi dagli
arrivi del ponte, l'iPad del tavolo dal saluto e i giornali di «Prisma ovunque» con la loro data. Impostazioni › Vera:
la riga «iPhone e iPad» rimanda qui con «Apri». «Inquadra con l'iPhone» (fase trascina), «Come funziona» della nota,
«Apri il tavolo» e «Sull’iPad sul tavolo» portano qui quando il collegamento o la funzione è spenta. Voci della ricerca
del template. Prove: filtri e server in `--prova-vera` (ProvaCopilota), tavolo spento in `--prova-tavolo`, i quattro
campi nel backup e un archivio senza in `--prova-backup`. Istantanee nuove 1069 (chiara e scura), 1070, 1071.

Resta:
- **iPhone e iPad** (con il loro giro): il nome vero del dispositivo nelle chiamate al modello (campo facoltativo
  `dispositivo` in `BustaPonte`, compatibile con il protocollo 3): oggi quelle righe dicono «iPhone o iPad»; i testi del
  telefono che dicono ancora «Impostazioni › Vera sul Mac» (PonteVera.swift, AppLetturaTelefono, TavoloiPad,
  NotaVocaleTelefono, AperturaBackup); con «Nota a voce» spenta sul Mac l'iPhone riceve «rifiutata»: va verificato che la
  nota resti nella coda cifrata come quando il Mac non risponde (oggi la coda scatta solo senza collegamento).
- **Il codice breve che scade** (decisione 2): richiede un abbinamento nuovo su Mac, iPhone e iPad.
- **La scheda del codice** resta aperta se si blocca Prisma o si chiudono le Impostazioni (sotto la schermata di
  benvenuto non si vede); se serve, chiuderla in `blocca()` e alla chiusura di Impostazioni.
- **Istantanee**: rigenerare sul Mac 560-566 (la pagina ha il nuovo ordine), 251 (riga che rimanda), le scene di
  Inquadra senza ponte e «Come funziona» della nota (compare «Collega l’iPhone»), guardare 1069-1071 chiare e scure e
  aggiornare la pagina delle anteprime.

## 37. La dimostrazione è un interruttore

Fatto (solo Mac): `StatoShell.inDimostrazione` e `gruppoProva` (cinque o trentacinque), `accendiDimostrazione` e
`spegniDimostrazione` in StatoShell.swift, il resto in Shell/StatoDimostrazione.swift. Accesa: prima `salvaOra()`, poi in
memoria solo i dati di prova rifatti ogni volta (decisione 1), con delle impostazioni dell'utente solo aspetto, nomi dei
canali, motore e ponte di Vera, nome nel profilo, guida e backup; spenta: l'archivio vero si rilegge dal disco con
`Archivio.carica()` fuori dal thread principale e `salvataggio.prepara`, e tornano solo aspetto, canali e Vera scelti
intanto (decisione 7). Lo stato acceso e il gruppo stanno nelle preferenze del Mac (`Prisma.dimostrazione`,
`Prisma.dimostrazioneGruppo`), fuori da archivio, backup e «Prisma ovunque»; riaprendo Prisma la dimostrazione riparte
(decisione 2). Ferme durante la dimostrazione: `salvaOra`/`scrivi`, backup manuale e automatico («Crea backup»
disattivato con la nota), ripristino, importazioni, `dopoUnBackup`, `ripristinaDatiDiProva`, `togliDatiDiProva`,
`sincronizzaOvunque` (istantanea e unione dei giornali), Stanotte, routine programmate, tagliando, ripianificazione dei
promemoria del Mac, `rimuoviFile` e le due pulizie dei documenti orfani, le cancellazioni di scontrini e attestati (e
l'aggiunta di file, con l'avviso «Non durante la dimostrazione»), la Biblioteca e i Moduli dell'utente in sola lettura
(decisione 3, `fermaPerDimostrazione`), i testi di «Trova la pagina», la memoria di Vera (né letta né scritta) e la cache
dei vettori; le note dettate si rifiutano e restano nella coda dell'iPhone (decisione 4). Etichetta «Dimostrazione» nella
barra dopo la pillola del cliente (`EtichettaDimostrazione`, mai in modalità cliente né nella vista pulita) e la scheda
«Stai mostrando Prisma con i clienti di prova.» con «Esci dalla dimostrazione» e «Resta». Impostazioni › Dimostrazione
(la pagina `.strumenti`, il valore grezzo resta «strumenti») con l'interruttore, «I clienti di prova» («In uso» / «Usa
questi») e «accesa» nella colonna; «Confronta i modelli», le misure della velocità e «Voce e ascolto» in Vera, «Prova un
promemoria» in Promemoria e occasioni, «Togli i clienti di prova» in Archivio e backup (solo se ce ne sono e la
dimostrazione è spenta); spariscono «I 5 clienti di prova · Ripristina», «35 clienti di prova completi · Carica» e il
«+ 30 clienti di prova» della rubrica. Guida: il passo «Togli i clienti di prova» porta ad Archivio e backup e c'è solo se
servono; con la dimostrazione accesa la guida non si mostra. Le scritte «dati di prova» che leggevano `haDatiDiProva`
leggono `scritteProva` (spenta in dimostrazione, tenuta fra i dati ricavati); anche Mercato, Pratiche › Dopo la firma e
Territorio tacciono in dimostrazione. «Guardo Prisma con i clienti di prova» del primo avvio accende la dimostrazione.
Prova `ProvaBackupDimostrazione` in `--prova-backup`. Istantanee nuove 1060 (chiara e scura), 1061, 1062 (chiara e
scura), 1063; 85 mostra la pagina nuova, 86 le misure in Impostazioni › Vera.

Resta:
- **Primo avvio senza dati di prova** (37.3 D, decisione 5): `Archivio.carica` scrive ancora `DatiPrisma.demo()` in una
  cartella vuota (Archivio.swift, ramo finale e `caricaVecchio`). Va cambiato in un archivio vuoto controllando le prove
  che partono da una cartella vuota; per l'utente non cambia nulla.
- **Altre scritte «di prova»** che guardano la nota o il prefisso del dato e non sono ancora spente in dimostrazione:
  PraticheComuniApple (`dati di prova`), SalaGiornataPensione, PaginePrismaCliente (`c.diProva`), SmontaggioApple,
  DettaglioDocumento («documento di prova»), FamiglieComeLaSua, `TestiStudio.datiDiProva`, StudioSpese, StudioEsameOCF,
  TestiPassaparola, MotoreTraguardi, TestiSinistri (chiudere con `grep -rn "di prova" Sources/Prisma/Shell
  Sources/Prisma/Motori`). `scritteProva` non guarda la modalità cliente (la specifica lo propone): aggiungerlo cambierebbe
  le istantanee della Sala in modalità cliente, da decidere guardandole.
- **Pulsanti disattivati** con l'aiuto «Non durante la dimostrazione» (documenti, scontrini, attestati, Biblioteca,
  moduli): oggi la guardia è nello stato (avviso), non nei pulsanti. Un documento aggiunto ai Documenti di un cliente di
  prova copia comunque il file nella cartella Documenti: non entra nell'archivio vero e la pulizia dei file orfani lo
  sposta nel Cestino al primo avvio dopo la dimostrazione. Da guardare anche le scritture di capsule e sinistri
  (StatoCapsule, StatoSinistri).
- **Prove**: `--prova-ovunque` (con la dimostrazione accesa `sincronizzaOvunque` non scrive e non unisce) e `--prova-vera`
  (la guida e il contesto di Vera senza id di clienti veri) non sono estese: la prova del backup lavora su uno stato non
  persistente e controlla dati, ricerca, guida, pulizie e scritture ferme; la lettura dal disco allo spegnimento non è
  provata (servirebbe uno StatoShell persistente su una cartella di prova).
- **«Riapri ora»** (dimensione del testo) durante la dimostrazione: la misura scelta non si salva e Prisma riparte con
  quella dell'archivio vero (in dimostrazione).
- **Istantanee**: rigenerare sul Mac 85, 86 (chiara e scura), le pagine di Vera, Promemoria e Archivio (righe nuove in
  fondo), la rubrica vuota e il piede della rubrica (senza «+ 30 clienti di prova»), guardare 1060-1063 e aggiornare la
  pagina delle anteprime; controllare che le scene dello Studio, di Messaggi e della Sala con «dati di prova» non cambino.

## 18. La settimana si vede tutta

Fatto (solo sul Mac, `#if os(macOS)`; l'iPad tiene le quattro viste, la striscia e la settimana a pillola):
- **Il momento di un impegno** (Motori/MomentoImpegno.swift): `prima`, `daChiudere` (pianificato, `fine <= adesso`, non
  «Non disponibile», con un cliente), `chiuso`; `attenuato` (passato o chiuso), `esitoBreve` (l'esito della proposta chiesto
  in quell'impegno, altrimenti «concluso»), `fini` (gli istanti in cui la vista di oggi si rifà) e `notaGiorno`.
  Le notifiche non chiedono più l'esito di un blocco «Non disponibile».
- **La barra**: «Giorno | Settimana | Mese», poi il pulsante «Occasioni» con il numero (le occasioni da oggi a oggi +
  `anticipoGiorni` del cliente scelto, in `ricavato`) e il menu in un popover («<nome> · <occasione>», «Nessuna occasione,
  per ora», «Tutte le occasioni ›»); una riga apre la vista «Occasioni» senza azzerare il cliente
  (`apriOccasioneDaPulsante`). La vista di partenza è «Settimana». La striscia «Riesami del mese» non c'è più.
- **La settimana** (Shell/AgendaSettimana.swift): testata dei sette giorni («Oggi · lun 2» in rosso, «libero / 1 impegno /
  N impegni», tocco → «Giorno»), card delle ore 08-19 (allargate su tutta la settimana) con sette colonne in un solo
  scorrimento, sabato e domenica a 0,62, fondo di oggi e del fine settimana, riga dell'ora nella colonna di oggi, impegni
  con le corsie, «09:30 · da chiudere» / «09:30 · ✓ concluso», attenuati a 0,62, cascata dal basso (14, 45 ms), traccia
  dell'impegno al tocco. Senza barra laterale sotto i 1040 punti. Il mese piccolo apre il giorno in «Giorno».
- **La giornata**: « · da chiudere» o « · ✓ <esito>» dopo l'orario, opacità del passato 0,62 (`Giornata.opacitaConcluso`).
  Le righe di oggi si rifanno solo alla fine di un impegno (`TimelineView(.explicit)`), non ogni minuto.
- **Apertura di un appuntamento** (ricerca, notifiche, «Da fare», «Apri in Agenda») con la settimana: passa a «Giorno».
- Token in `Tema.Apple.Agenda.SettimanaSette`, testi in `TestiAgendaApple`. Prove: A-M1…A-M9 in `ProvaCalcoliAgenda`
  (`--prova-calcoli`), `ProvaSettimanaAgenda` in `--prova-vera`. Istantanee: 450 (chiara e scura) e 452 ora sulla settimana
  (con un impegno chiuso di Sofia alle 8:15; quello di Giulia alle 9:30 è «da chiudere» alle 10:24), nuove
  453-agenda-settimana-cliente e 455-agenda-settimana-stretta; le scene pensate sul mese (11a, 11c, 114, 115, 125, 213,
  238) chiedono ora il mese.

Resta:
- **454-agenda-occasioni-pulsante**: il menu è un popover (finestra a sé), le istantanee non lo vedono: chiedere uno
  screenshot all'utente.
- **Colonna a sinistra**: «Da non dimenticare» resta; il template mette lì il «Da fare» (con `RigaDaFare(filoAgenda: true,
  conCanali: false)`). Nella giornata la fascia «Da fare e da ricordare» non è ancora «Da fare oggi» (miglioria 3).
- **Scala al passaggio** (1,03) non messa: basta l'inclinazione (come chiede 18.3 punto 3).
- **`--prova-fluidita`**: guardare in CI che la settimana con 30 clienti non faccia crescere i corpi rifatti (ogni colonna
  di oggi ha una `TimelineView` della riga dell'ora e una degli impegni); `ProvaRiesamiAgenda` non tocca la vista e resta.
- **Istantanee da rigenerare sul Mac**: 450 (chiara e scura), 451, 452, 453, 455, 11-agenda, 11b-agenda-giorno (« · da
  chiudere»), 130/131 (si arriva dal pulsante), 1027-agenda-solo-cliente (ora la settimana); aggiornare la pagina delle
  anteprime. Il passaggio sull'intestazione e la cascata chiedono uno screenshot.
- Le corsie nella settimana usano ancora l'altezza minima della giornata per le sovrapposizioni (`CorsieImpegni`):
  con tre corsie strette l'impegno mostra solo il nome; da guardare con i clienti fittizi.

## 21. Incontri segue il cliente e non si ferma a oggi

Fatto (solo sul Mac, `#if os(macOS)`; iPhone e iPad restano con le tendine e la colonna «Oggi» del copilota):
- **I dati** (Shell/ElencoIncontri.swift): `VoceIncontri`, `GruppiIncontri` e `RegoleElencoIncontri.calcola`, la regola
  pura dei tre gruppi. «Oggi» comprende gli appuntamenti di oggi con un cliente, uniti al loro incontro, e gli incontri di
  oggi senza appuntamento. «Prossimi» va da domani per 14 giorni, al più 20. «Fatti» mette in testa gli appuntamenti
  degli ultimi 7 giorni ancora da chiudere, poi gli incontri conclusi degli ultimi 12 mesi, al più 30. I blocchi «Non
  disponibile» e gli impegni senza cliente restano fuori, e non ci sono doppioni (la chiave è `Incontro.appuntamentoId`).
  `stato.elencoIncontri(cliente:)` sta in `ricavato`, con l'ora nella chiave. La spunta del verbale si legge fuori dalla
  cache (`incontriConVerbale`).
- **La colonna** `ElencoIncontriApple` (300, token in `Tema.Apple.Copilota.Elenco`): in testa le note dall'iPhone, poi gli
  occhielli «Oggi», «Prossimi», «Fatti». Ogni riga ha avatar 36, nome, «09:30 · titolo» (oppure «gio 5 · 15:00», «30
  ottobre»), « · da chiudere» in arancio e la spunta verde. La riga scelta è accesa e i gruppi entrano a cascata. Mentre il
  copilota ascolta le righe sono spente. Il vuoto della colonna dice «Nessun incontro con <nome>. Si fissa in Agenda.»; a
  destra compare «Nessun incontro, per ora.» con «Apri l’Agenda».
- **La scelta**: una riga apre l'incontro sul momento giusto. Oggi si apre su «Ascolto», o su «Prossimi passi» se c'è il
  verbale o l'incontro è concluso. Un prossimo si apre su «Preparazione», un fatto su «Prossimi passi». Prima di cambiare
  riga gli appunti in attesa vengono scritti e il copilota riparte da capo. Una riga che è solo un appuntamento mostra la
  bozza (`bozzaIncontroElenco`, id fisso «incontro-<appuntamento>»), che non va nell'archivio: l'incontro nasce
  (`assicuraIncontro`) al primo gesto che scrive. Questi gesti sono un campo scritto, un tema scelto, «Inizia l’ascolto»,
  «Prepara con Vera», l'ascolto del copilota e «Chiudi e archivia». `apriIncontro(per:)` dall'Agenda sul Mac non crea più
  l'incontro (`appuntamentoIncontro`). Cambiando cliente nella barra (`scegliCliente`) si riparte dal primo incontro della
  lista.
- **Via** le due tendine della barra (resta «Nuovo incontro», spento senza cliente). Sul Mac la colonna «Oggi» del copilota
  non c'è più: il consenso va in riga in testa e «Domande e appunti · Prossimi passi» in fondo.
- **Prove**: `ProvaElencoIncontri` in `--prova-vera` controlla i gruppi, i limiti, il filtro per cliente, «Non
  disponibile», i doppioni, il momento, la bozza che non scrive, la nascita al primo gesto e il cambio di cliente.
  **Istantanee nuove**: 476-incontri-tutti-i-clienti e 477-incontri-cliente-senza-incontri.

Resta:
- **«Tutti i clienti»**: toccare la riga di un altro cliente **non** cambia il cliente della barra, come nel template.
  La specifica (21.3 punto 3) diceva di metterlo, ma allora l'elenco si stringerebbe a quel cliente a ogni tocco. Il
  quaderno usa il cliente dell'incontro mostrato. Il collegamento «Analisi» delle schede dei temi apre però Analisi 360
  sul cliente della barra, che con «Tutti» mostra il vuoto: da sistemare con la miglioria 20 o scegliendo il cliente al
  tocco di «Analisi».
- **«Prima» dall'appuntamento**: oggi la bozza usa la «Preparazione» di sempre (priorità, dossier, temi, l'ultima volta).
  I «punti da toccare» e le cifre del template arrivano con la miglioria 20 (Prima, Durante, Dopo), e così anche
  «Riapri» per i fatti in sola lettura e «Fermare l'ascolto?» (20-c). Oggi, mentre si ascolta, le righe sono solo spente.
- Un incontro in preparazione con una data passata e senza appuntamento da chiudere non compare in nessun gruppo:
  guardare con i dati veri se serve un quarto caso.
- Sul Mac non c'è più «Ascolta un incontro senza appuntamento» (era nella colonna «Oggi»): si passa da «Nuovo incontro» e
  poi «Inizia l’ascolto».
- **`--prova-fluidita`**: manca il caso «l'elenco non si rifà a ogni frase del copilota». Mentre ascolta, l'elenco non
  legge le sessioni del copilota, quindi non dovrebbe rifarsi; `AppIncontri` legge `copilota.ascolta` solo al cambio di
  fase. Da guardare in CI.
- **Istantanee da rigenerare sul Mac**: 21, 22, 105, 215 e 580-589 (il copilota senza la colonna «Oggi», con il consenso
  in testa), più le nuove 476 e 477; aggiornare la pagina delle anteprime.

## 20. L'incontro ha tre momenti: Prima, Durante, Dopo

Fatto (solo sul Mac, `#if os(macOS)`; l'iPad tiene `IndicatorePercorso`, il copilota a tutta finestra e il verbale nel
dettaglio):
- **La testata bassa** (`TestataMomentiIncontro` in AppIncontri.swift, card alta 74): avatar 44, il titolo su una riga,
  sotto «<nome> · oggi, 09:30 · <luogo> · <tipo> · <durata>» con l'etichetta del canale; a destra i tre momenti
  (`MomentiIncontroApple`, DesignSystem/Apple/MomentiIncontroApple.swift) con la regola pura delle spunte
  (`RegoleMomentiIncontro.fatto`: mai l'aperto; gli altri se concluso, se vengono prima, o «Durante» con il verbale).
  Resta sopra anche durante il copilota: `SceltaAscoltoIncontri` sul Mac non si usa più. La spunta di «Durante» legge le
  sessioni solo quando il copilota non ascolta. Il contenuto del momento si rifà a ogni cambio (`.id`) ed entra a cascata.
- **Prima**: a sinistra «Punti da toccare» (`puntiDaToccare` dell'appuntamento in `ricavato`, o i temi con la loro
  domanda), «L'ultima volta · <data>» (prime due frasi delle decisioni, solo per un incontro non concluso), «✦ Preparami
  l'incontro» (`ListaTiPreparo`, poi il fascicolo in Prospetti come dalla traccia), «Apri il dossier», «Inizia
  l'incontro ›»; finiti i punti «Chiedi a Vera» sobrio (decisione 20-e). A destra i riquadri condivisi con la traccia
  (`CifreClienteTraccia`, `RiquadroTracciaApple` in TracciaImpegnoApple.swift), «Da fare per <nome>» (il «Da fare» unico
  del cliente) e «Proposte aperte» con i premi dell'anno. Sotto, nello scorrimento, priorità, cosa è cambiato e i quattro
  temi (decisione 20-a). Per un incontro concluso: «Incontro concluso: la preparazione resta da rileggere.»
- **Durante**: il copilota senza avatar e titolo; la sua testata è la barra alta 66 (`TestataCopilota(barraDurante:)`)
  con il selettore «Copilota | Appunti a mano» (spento mentre ascolta), lo stato, la riga del consenso («<Nome> ha dato il
  consenso · l'audio non lascia il Mac» in verde, o in arancio «Manca il consenso all'ascolto · Registra il consenso…»:
  il tocco apre il modulo di sempre in un foglio, anche per revocare), l'onda stretta (`ParametriOnda.barraDurante`) e
  «● Avvia il copilota». Per un incontro concluso «Incontro concluso», niente pulsante, e la trascrizione vuota dice «La
  trascrizione non è stata conservata: resta il verbale, in «Dopo».». «Appunti a mano»: barra con la frase e «Ho
  finito ›» (→ «Dopo» con le proposte dagli appunti), sotto le domande, appunti e decisioni di sempre. La sessione
  mostrata è quella dell'incontro (`StatoCopilotaIncontro.sessione(incontro:cliente:in:)`).
- **Dopo**: con una sessione del copilota per l'incontro, `CorpoVerbaleCopilota` (VerbaleCopilota.swift, rifattorizzato
  da `VerbaleCopilotaVista`, che resta il dettaglio dell'iPad) dentro la pagina, con «Fissa il prossimo» al posto di «Più
  tardi» e sotto «Chiudi e archivia l'incontro» (il verbale confermato non archivia da solo); senza copilota ma con
  appunti i «Prossimi passi» di sempre; senza niente «Il verbale non c'è ancora.» con «Vai all'ascolto» e «Scrivilo a
  mano». Incontro concluso: «Già nel dossier: l'incontro è archiviato, in sola lettura.» con «Riapri» e l'archivio.
- **«Riapri»** (`StatoShell.riapriIncontro`, decisione 20-b): torna in preparazione e riapre l'appuntamento;
  `chiudiIncontro` non crea due volte attività concordata e seguito se ci sono già.
- **«■ Termina»** (`terminaNelDopo`) porta a «Dopo» con l'avviso «Incontro concluso · il verbale è pronto: conferma cosa
  entra nel dossier». **«Fermare l'ascolto?»** (decisione 20-c) prima di passare a «Prima» o «Dopo» mentre il copilota
  ascolta. «Nuovo incontro» resta nella barra, in vetro e non più blu (decisione 20-d).
- Token in Tema.Apple+Incontri.swift (`Tema.Apple.Copilota.TestataIncontro`, `Momenti`, `Prima`, `Durante`, `Dopo`),
  testi in `TestiMomentiIncontro`. Prove in `ProvaVistaCopilota` (`--prova-vera`): spunte dei momenti, «■ Termina» →
  «Dopo», sessione ristretta all'incontro, verbale pronto dopo la conferma, «Riapri» che non duplica. Istantanee nuove
  472-incontri-dopo-verbale (chiara e scura), 473-incontri-dopo-vuoto, 474-incontri-durante-appunti,
  475-incontri-senza-consenso; 584 e 585 ora mostrano il verbale in «Dopo».

Resta:
- **L'uscita del contenuto in 120 ms** (opacità e 6 punti in giù) prima della cascata al cambio di momento: oggi il
  contenuto nuovo entra a cascata senza l'uscita del vecchio (si può fare come `DossierApple` con `CambioScheda`).
- **Incontro concluso con il solo verbale del copilota**: in «Dopo» si vede l'archivio degli appunti scritti, non i
  punti del verbale confermato (da aggiungere in sola lettura, come «Il verbale» del template).
- **«Fissa il prossimo»** apre il modulo dell'appuntamento fra 30 giorni alle 10 (titolo «Seguito · …», revisione), non
  l'Agenda: da guardare se l'utente preferisce aprire l'Agenda con il cliente scelto.
- **Il numero delle domande** degli appunti a mano usa ancora il tondo del tema di prima (`Tema.Misura.Incontri`); il
  token `Durante.numeroDomanda` (22, `.pzN`) è pronto.
- La testata con titoli lunghi e finestra stretta: i momenti hanno la precedenza e il titolo si tronca; sotto i 900 punti
  della parte destra potrebbe non starci tutto (guardare l'istantanea a finestra stretta).
- Il «?» con «Come funziona» del copilota (miglioria 6): sul Mac il riquadro non si vede più.
- `CollegamentiCopilota` e la scheda del consenso a riquadro non si usano più sul Mac (restano per l'iPad).
- **Istantanee da rigenerare sul Mac**: 21, 22, 105, 215, 476, 477, 580-589 (testata con i momenti, barra di «Durante»)
  e le nuove 472-475; aggiornare la pagina delle anteprime. Il foglio del consenso, l'avviso «Fermare l'ascolto?» e la
  spunta al passaggio chiedono uno screenshot.
- Le modifiche a `chiudiIncontro` e `riapriIncontro` (StatoShell.swift) sono finite nel commit della miglioria 37, fatto
  in parallelo sullo stesso albero.

## 19. Un impegno passato chiede com'è andato

Fatto (solo sul Mac, `#if os(macOS)`; sull'iPad la traccia e il dettaglio restano quelli di sempre), con le proposte di
19-a (gli esiti della proposta, senza proposta la capsula «Concluso»), 19-b (punti toccati in memoria), 19-c («Il
prossimo passo si decide nel verbale.») e 19-d (la voce del «Da fare» resta e apre «Giorno»):
- **La traccia** (TracciaImpegnoApple, corpo in Shell/ImpegnoConcluso.swift): con `MomentoImpegno` `daChiudere` o
  `chiuso` (e un cliente) l'etichetta diventa «Incontro concluso · <giorno>» in verde, a sinistra «Com'è andata?» e «Punti
  toccati» (dentro uno ScrollView con la sfumatura), a destra «Il verbale» e «Cosa succede adesso», nel piede «Scrivi il
  verbale» (Incontri, momento «Dopo»: `apriIncontro(per:scheda:)`), «Apri il dossier» e «Altro ⌄» (Riapri l'incontro se è
  concluso, Modifica, Attività collegata, Prepara/Apri il fascicolo). Il momento usa l'ora ferma nelle istantanee.
- **«Com'è andata?»**: con una proposta aperta (`propostaCollegata`, come `propostaDaChiudere` ma anche per un impegno
  ancora pianificato) il modulo di sempre a capsule (`FormEsitoProposta(capsule: true)`): ogni scelta prima segna concluso
  l'impegno pianificato (`preparaEsitoImpegno`: la proposta diventa presentata), poi il passo (accettazione con decorrenza
  e valori, rinvio con la data; «Ci deve pensare» subito). A esito dato la capsula dell'esito resta accesa, senza tocco
  (`RegoleImpegnoConcluso.sceltaAccesa`). Senza proposta la capsula «Concluso» (`segnaConclusoImpegno`, «Segnato:
  concluso»).
- **«Il verbale»** (`RegoleImpegnoConcluso.verbale`): «Confermato» se l'incontro è concluso o il resoconto firmato,
  «Pronto, da confermare» con schede o verbale del copilota di quell'incontro da confermare (o un resoconto da firmare),
  altrimenti «Non ancora scritto».
- **«Modifica» e «Attività collegata»** dalla traccia passano dall'Agenda (`StatoShell.richiestaModuloImpegno`, solo in
  memoria): la scheda si chiude, l'Agenda va in «Giorno» sull'appuntamento e apre il modulo.
- **Il dettaglio di «Giorno»** (`DettaglioAppuntamento`): per un impegno passato o chiuso le due file di pulsanti diventano
  «Scrivi il verbale» + «Altro ⌄» (lo stesso menu); prima dell'ora restano quelle di sempre.
- Token in `Tema.Apple.Agenda.Traccia` (scelte a capsula, colore del concluso, riquadri), testi in `TestiAgendaApple`.
  Prove in `ProvaSeguito` (`--prova-carico`): la capsula «Concluso» non tocca le proposte, la scelta su un impegno
  pianificato lo segna concluso prima dell'esito, a esito dato nessun modulo e la capsula accesa, il riquadro del verbale.
  Istantanee: 452 ora sull'impegno di Marco delle 11 (ancora «prima» alle 10:24), nuove 456-agenda-impegno-concluso
  (chiara e scura: la presentazione della proposta di Laura alle 8:30, da chiudere) e
  457-agenda-impegno-concluso-senza-proposta (Giulia, «Concluso» spenta e «Non ancora scritto»).

Resta:
- **Dal «Da fare»** la voce «Com'è andato «…»?» apre «Giorno» con il dettaglio (che ora dice «Scrivi il verbale» e
  «Altro ⌄»), non la traccia della 19 sopra la settimana: aprire la traccia da `vai(.appuntamento(id))` chiede un modo
  per far nascere il dettaglio dell'Agenda dallo stato (oggi lo apre solo il tocco su un impegno).
- **«Prepara con Vera»** sparisce dalla scheda concluso; la richiesta a Vera per l'incontro passa dalla decisione 20-e
  (nel dettaglio di «Giorno» per un impegno «prima» il pulsante resta finché la miglioria 10 non lo rinomina).
- **«Presenta al cliente»** nella traccia «prima» resta finché la miglioria 1 non porta «Mostra al cliente».
- La traccia aperta non si rifà da sola quando l'impegno finisce mentre la si guarda (si rifà alla prossima apertura).
- **Istantanee da rigenerare sul Mac**: 452, 456 (chiara e scura), 457, 11-agenda e 11b-agenda-giorno (il dettaglio di un
  impegno passato alle 10:24 ferme, con «Scrivi il verbale» e «Altro ⌄»); il menu «Altro ⌄» e i passi
  dell'accettazione aperti nella scheda chiedono uno screenshot. Aggiornare la pagina delle anteprime.

## 22. «Per te» e «Per il cliente» al posto di «Prospetto» e «Report»

Fatto (solo sul Mac, `#if os(macOS)`; iPhone e iPad tengono «Prospetto | Report» nella colonna):
- **La versione separata dalla scelta** (`Dati/Prospetto.swift`): `VersioneProspetto`, `SceltaProspetto.versione`,
  `conVersione(_:)`, `soloPer` e `conTimbroPerTe` (non il portafoglio, decisione 22-c). I casi di `SceltaProspetto` non
  cambiano (chiavi dei commenti uguali).
- **Sopra la pagina** (`barraAzioniApple`, alta almeno 58): il titolo, sotto «Report · da mostrare e da consegnare» o
  «Prospetto di dettaglio · solo per te» con il numero di pagine, e accanto `SegmentatoPillola` «Per il cliente | Per te»
  (il cambio usa `cambiaAnteprima`, «Per te» = +1) o l'etichetta grigia «Solo per il cliente» / «Solo per te».
- **Via «Prospetto | Report» dalla colonna** sul Mac (`selettoreVersioneColonna`).
- **Partenza da «Per il cliente»** (decisione 22-a) in `scegli(_:)` e nella scelta predefinita (`sceltaProspetto`), con
  l'ultima versione ricordata in `StatoShell.versioneProspetti` (solo in memoria).
- **Il timbro «SOLO PER TE»** (`TimbroSoloPerTe`, `NotaSoloPerTe` in `ComponentiCarta.swift`, colori e misure in
  `Carta.swift`) da un posto solo: `DocumentoStampabile.conTimbroPerTe(alto:)` in fondo a `documentoProspetto(_:)`.
  Prima pagina a 46 dal bordo destro e 40 dall'alto; sulle pagine di `PaginaCarta` (posizione, confronto, riesame), dove
  a 40 c'è la data, nel margine alto (8). L'ultima pagina ha «Prospetto per il consulente: non va consegnato.» sotto il
  piede. Uguale a schermo, nel PDF, in stampa e nell'archiviato (22-b); il numero di pagine non cambia.
- **«Mostra al cliente»**: dalla versione per te presenta la versione per il cliente dalla prima pagina, con l'avviso «Al
  cliente si mostra la versione per il cliente»; spento per posizione, confronto e riesame («Questo documento è solo per
  te», decisione 22-d). **«Al tavolo»**: sempre la versione per il cliente; niente pulsante per i documenti solo per te.
- **«Salva PDF»**: `StampaCarta.salva` dice se il file è stato scritto; solo allora l'avviso «PDF salvato: «<nome>» ·
  versione per te / per il cliente» (`PDFDaSalvare.avvisoSalvato`). Il nome del file resta con «Prospetto»/«Report».
- La frase del vuoto con le parole delle versioni. Token in `Tema.Apple.Prospetti.Barra` (`altezzaVersione`,
  `etichettaSolo`…), testi in `TestiVersioneProspetto` (`Shell/VersioniProspetto.swift`).
- Prove in `ProvaVersioniProspetto` (`--prova-prospetti`): `conVersione` va e torna, ogni documento ha la scelta o una
  versione sola, il timbro e la frase nel PDF per te (check-up, resoconto, riesame) e non in quelli per il cliente, stesso
  numero di pagine, la seconda lettura non segnala il timbro, l'avviso del PDF salvato.
- Istantanee: nuove 466-prospetti-per-te (chiara e scura: il check-up di Giulia per te, con il selettore e il timbro).

Resta:
- **463-prospetti-solo-per-il-cliente** non aggiunta: la 460 (e la scura) mostra già «Un anno insieme» con l'etichetta
  «Solo per il cliente».
- **L'avviso di «Mostra al cliente»** nasce insieme alla sala della presentazione: va guardato sul Mac se resta visibile
  sopra la sala; se no, va ritardata la presentazione di un tempo del tema.
- La coda del check-up («… La versione per il cliente è «Il quadro di …».») non c'è: la frase dell'ultima pagina è una sola.
- Controllare a occhio che il timbro non copra logo, data o etichetta del canale su nessuna prima pagina (466 e le scene
  «…-prospetto» di `Istantanee.swift`, che ora mostrano il timbro dove sono nella versione per te); la frase dell'ultima
  pagina nei prospetti di `FoglioProspetto` sta nei 22 punti sotto il piede.
- **Istantanee da rigenerare sul Mac**: 460 (chiara e scura), 461, 466 (chiara e scura), 236 e le scene dei prospetti
  (27-44, 66, 69, 101, 102, 112, 211, 212). Aggiornare la pagina delle anteprime.

## 23. L'elenco dei documenti si legge a colpo d'occhio

Fatto (solo sul Mac, `#if os(macOS)`; l'iPad tiene i tre gruppi di prima e le scelte complete):
- **I gruppi per momento** (decisione 23-a) in `ElencoProspetti.gruppi` (`Dati/Prospetto.swift`): «Primo incontro», «Le
  analisi», «Per una proposta», «Fine anno» e «Per te» (il portafoglio, nascosto in modalità cliente). `ordineVoci` segue
  `ElencoProspetti.ordine` (il fascicolo in fondo), così la pagina gira nel verso giusto.
- **La riga «a cosa serve»** `TipoProspetto.inBreve` (23-b, i quattro del template come sono) al posto di «Prospetto e
  report», al più su due righe; «nuovo» resta per «Un anno insieme».
- **Le etichette** «per il cliente» e «per te» sotto la riga (`TipoProspetto.versioni`, come `versione`/`soloPer` della
  miglioria 22) e, in verde, «per l'incontro di oggi»: `stato.prospettoPerIncontroOggi(_:)` (in `ricavato`, chiave
  «prospetti-incontro-oggi|<cliente>») segna il primo, nell'ordine dell'elenco, dei report di `TipoProspetto.perIncontro`
  per un appuntamento di oggi non concluso (23-c; mai i blocchi «Non disponibile»).
- **La riga non si allarga più**: sotto la voce scelta restano solo le scelte che servono a impaginare (posizione,
  valutazione con «Modifica ipotesi e testi…» e «Nuova valutazione», obiettivo, le due voci di confronto e sostituzione
  con gli anni, i report del fascicolo, il commento del report: 23-d) in `scelteCompatte` (`AppProspetti.swift`); le
  parti comuni con l'iPad sono uscite in `scelteSostituzione`, `scelteConfronto`, `elencoObiettivi`, senza cambiare l'iPad.
- **La «i» sopra la pagina** (`PulsanteInfoProspetto`, accanto al selettore delle versioni): il popover «A cosa serve» con
  il nome 24 bold, `TipoProspetto.descrizione` e «Da dove vengono le cifre» (`TipoProspetto.fonti`, i testi che stavano
  sotto la voce).
- **Niente piede** con i collegamenti e la nota «Impaginati sul Mac…» (23-e). Token in `Tema.Apple.Prospetti.Laterale`
  (`etichettaVoce`, `spazioEtichette`, `sopraEtichette`, `fondoEtichettaIncontro`, `testoEtichettaIncontro`,
  `righeInBreve`) e `Tema.Apple.Prospetti.Info`; testi in `TestiElencoProspetti`.
- Prova `ProvaElencoProspetti` (`--prova-prospetti`): riga, fonti e versioni per ogni tipo, ogni tipo in un gruppo solo,
  l'ordine completo, il portafoglio in «Per te», e sul Mac la regola dell'incontro di oggi (primo incontro → check-up,
  revisione → resoconto, niente per domani, per un concluso o per «Non disponibile»).
- Istantanea nuova 464-prospetti-elenco-incontro-oggi (Giulia, revisione di oggi alle 9:30: il resoconto scelto porta
  «per l'incontro di oggi»).

Resta:
- **465-prospetti-info** non aggiunta: la scheda «A cosa serve» è un popover e le istantanee non lo catturano; serve uno
  screenshot dall'utente.
- Gli **elenchi puntati di cosa contiene ogni documento** (prospetto e report) non sono passati nella scheda della «i»:
  la scheda ha la descrizione lunga e le fonti; se servono, una `TipoProspetto.contenuto(versione:)` dai testi di oggi.
- Sotto la voce scelta non ci sono più, sul Mac, i collegamenti «Apri l'Analisi 360» (previdenza, protezione) e «Apri il
  Portafoglio in Posizioni», né l'elenco dei punti del riesame: le app sono nel dock. Per il riesame resta «Fissa
  l'incontro di riesame» (o «In agenda: …»), che serve al documento.
- La larghezza della colonna resta `Misura.Laterale.prospetti` (il template dice 300): si cambia solo il valore del token,
  se l'utente lo vuole.
- **Istantanee da rigenerare sul Mac**: 460 (chiara e scura), 461, 464, 466 (chiara e scura), 236, 81, 82. Aggiornare la
  pagina delle anteprime.

## 24. Tre pulsanti nei Prospetti

Fatto (solo Mac, `#if os(macOS)`; iPhone e iPad tengono la fila di sempre con le sole icone nelle finestre strette):
- **Tre pulsanti sempre con il nome** nella barra sopra la pagina (`treAzioniApple` in `ProspettiApple.swift`): «Mostra al
  cliente» (simbolo dello schermo, la presentazione di sempre nella vista pulita con `presentaApple`, sempre la versione
  per il cliente; spento per il portafoglio e per i documenti solo per te, con l'aiuto), «Salva PDF…» (blu, seconda
  lettura, foglio della password e avviso con la versione) e «Altro ⌄» (`Menu` con l'etichetta e la freccia come in
  Agenda): «Stampa…», «Archivia nei Documenti» (non il portafoglio), «Chiedi a Vera di commentarlo» (solo con lo spunto,
  spento mentre Vera scrive) e «Al tavolo…» (mai il portafoglio né i documenti solo per te), che apre il pannello di
  sempre del tavolo con l'iPad (`PannelloAlTavolo`, stesso `ContestoTavolo`: versione per il cliente).
- **Niente sole icone**: `ViewThatFits` fra i tre pulsanti e «Salva PDF + Altro» con «Mostra al cliente» in testa al menu.
- **24-a**: «Archiviato in Documenti ↗» resta il collegamento sobrio accanto ai pulsanti finché non si cambia documento.
- **Senza cliente** i tre pulsanti aprono «Di chi parliamo?» (`apriSceltaCliente`); il portafoglio no (è di tutti).
- Token in `Tema.Apple.Prospetti.Barra` (`frecciaAltro`, `opacitaFrecciaAltro`, `spazioFrecciaAltro`); testi in
  `TestiAzioniProspetto`. `larghezzaMinimaTitolo` resta: il titolo divide ancora la riga con i pulsanti.

Resta:
- Il pannello «Mostra al cliente» (miglioria 1) non sa ancora ricevere un documento già scelto con le due strade (tutto
  schermo o iPad al tavolo): per ora «Mostra al cliente» va a tutto schermo e il tavolo sta in «Altro › Al tavolo…», così
  nessuna funzione si perde. Con la 58 (gruppo 10), chi toglie `PulsanteAlTavolo` (oggi non più usato dai Prospetti sul
  Mac) e `PannelloAlTavolo` dai Prospetti deve portare la strada verso l'iPad nel pannello «Mostra al cliente»
  (`ContestoTavolo(documento:pagina:clienteId:)` come `contestoTavolo(_:)`).
- Il puntino dello stato del tavolo non compare più nella barra (il menu del sistema non lo disegna): lo stato si legge
  nel pannello del tavolo.
- `--prova-tavolo` (a mano) e le istantanee 460 (chiara e scura), 461, 236 da rigenerare sul Mac: il menu «Altro» aperto
  non si vede nelle istantanee.

## 26. Il messaggio senza rumore: «Tono», «Invia con», i dati usati in una riga

Fatto (solo Mac, `#if os(macOS)`; iPhone e iPad tengono la fila con la sfera e le cifre sotto il testo):
- **La fila dei controlli** (`controlliMac` in `PannelloMessaggio.swift`): «Tono» e «Invia con» (`.k`) davanti ai
  segmentati, che prendono quel nome per VoiceOver; a destra «Vera ha usato N dati del dossier ›» (singolare con un dato),
  solo se l'occasione ha cifre. `ViewThatFits`: se la fila non sta, il collegamento va a capo sotto; nella versione
  compatta tutto in colonna. Via la sfera con «Vera scrive con i dati del dossier» (Vera che scrive si vede dai puntini e
  dalle parole; il testo di Prisma dall'avviso, che resta).
- **Sotto il testo** niente più etichette delle cifre né «Le cifre vengono da Prisma · Scritto da Vera».
- **La scheda «Da dove vengono le cifre»** (`FoglioDatiMessaggio`, nuovo, solo Mac): occhiello, titolo dell'occasione, la
  frase, una riga per ogni `CifraMessaggio` vera (filo fra le righe), in fondo «Scritto da Vera» o «Testo di Prisma»
  (`TestiMessaggi.scrittoDa`, senza modello) e «Chiudi» (anche Esc). Token in `Tema.Apple.Messaggi.Pannello`
  (`etichettaControllo`, `spazioEtichetta`, `fraGruppiControlli`, `datiUsati`) e nel nuovo `Tema.Apple.Messaggi.FoglioDati`.
- La riga «Dati di prova…» resta come la lascia la 37: spenta in dimostrazione (dove la barra dice già «Dimostrazione»),
  accesa sui clienti di prova caricati nell'archivio vero.
- Istantanea nuova `1044-uso-messaggi-dati-usati` (chiara e scura): la scheda disegnata sopra il pannello, sul velo
  (`RichiestaIstantaneaMessaggi.datiAperti`), perché i fogli di sistema non entrano nell'immagine.

Resta:
- Rigenerare sul Mac 490-495 (chiare e scure) e guardare la 1044; controllare che 494 mostri ancora l'avviso del testo
  di Prisma e che la fila non vada a capo nella finestra normale.
- La 25 rifà la barra in basso dello stesso pannello («L'hai spedito?», «Mandati oggi»): partire da `controlliMac` così
  com'è.
- La 49 (campagna in tre passi) riusa «Tono» e «Invia con»: i testi stanno in `TestiMessaggi.tono` e `inviaCon`.

## 25. Messaggi segue il cliente, e si vede cosa è già partito

Fatto (solo Mac; iPhone e iPad come prima):
- **Il motore filtra prima del taglio**: `MotoreOccasioniMessaggi.calcola(…, soloCliente:)` e `dividi(…, soloCliente:)` tengono
  solo le occasioni del cliente prima del limite di 8 per gruppo (nil di base: iPhone e prove di prima invariati).
  `StatoShell.occasioniMessaggi(cliente:)` le tiene con `ricavato("messaggi-occasioni|<id>")`; la modalità cliente passa
  dalla stessa via (prima filtrava dopo il taglio), anche nel calcolo fuori di «Scrivi a …» del dossier.
- **L'elenco segue la barra**: con un cliente scelto solo i suoi messaggi (anche quelli chiesti dalle altre app), con «Tutti
  i clienti» tutti. Una richiesta per un altro cliente (`preparaMessaggio`) porta la barra su di lui, in silenzio.
- **La copertura sull'occasione** (`CoperturaMessaggio`: id, stato, canale, ora, segno «spedito», oggetto e testo del
  messaggio più recente di oggi), riempita da `dividi` e da `occasioniMessaggiConRichieste`: colonna e barra non cercano
  nell'archivio.
- **Il segno «spedito»**: `MessaggioCliente.speditoIl` (facoltativo, letto con tolleranza, nel file del cliente e nei
  backup; nessuna versione nuova), `segnaSpedito(messaggioId:)` e `togliSpedito(messaggioId:)`, `nomeStato` («Spedito il
  4 novembre») nel dossier, nelle Campagne e nel messaggio riaperto dal dossier.
- **Colonna**: numero in pillola accanto a ogni occhiello (`NumeroOcchielloApple`, voci ancora da mandare), «Mandati oggi»
  in fondo con la spunta verde e «Spedito alle …», «Aperto in Mail alle …» per i messaggi aperti e non confermati, titolo
  senza larghezza massima, vuoto per cliente («Nessun messaggio da preparare per …»); pannello vuoto «Niente da scrivere,
  per ora.».
- **Barra a tre stati** (pannello incorniciato e non compatto): «Aperto in Mail. L’hai spedito?» con «Sì, spedito» e «Non
  ancora» (`SessioneMessaggi.domandeChiuse`, in memoria; una nuova apertura la riapre), la pillola verde «Spedito oggi
  alle … con Mail» con «È nel dossier di …» e «Non è partito»; il testo spedito si rilegge (niente scrittura, niente «↻
  Riscrivi», tono e canale fermi). Entrata breve al cambio di stato (`Moto.cambioBarra`). «Sì, spedito» passa al prossimo
  messaggio da mandare (prima i non traguardi) con l'avviso «Segnato come spedito: resta nel dossier di …».
- **Prove**: M13 in `--prova-calcoli` (spedito oggi, tolto, spedito ieri, solo salvato, `nomeStato`, filtro prima del
  limite di 8, senza cliente identico); in `--prova-backup` `speditoIl` torna uguale e un messaggio senza il campo si legge.
- **Istantanee**: 1040 (Giulia scelta, con il riepilogo in «Mandati oggi»), 1041 («L’hai spedito?»), 1042 (spedito), chiare
  e scure, e 1043 (cliente di prova senza messaggi). 490-496, 730 e Campagne restano su «Tutti i clienti» (stesso elenco di
  prima, con i numeri accanto agli occhielli).

Resta:
- **Istantanee**: rigenerarle sul Mac e guardare 490-496 (numeri), 1040-1043, 730 (traguardi) e la pagina delle anteprime.
  In 1040 se Giulia non ha altre occasioni il pannello mostra lo spedito (come 1042); in 1043 controllare che il cliente di
  prova «Elena Fabbri» non abbia davvero occasioni (traguardi o consensi).
- **`--prova-fluidita`**: aggiungere il controllo che «Sì, spedito» rifà `MotoreOccasioniMessaggi` una volta sola.
- **«Mandati oggi» per un messaggio aperto ieri e segnato oggi**: oggi l'occasione è coperta dal giorno prima e sparisce
  (come prima della miglioria); se serve, la copertura potrebbe contare anche `speditoIl`.
- **Le «Occasioni» dell'Agenda** (gruppo 03) possono usare `NumeroOcchielloApple`: i token stanno oggi in
  `Tema.Apple.Messaggi.Colonna`; se lo usano altre app conviene spostarli in un enum comune.
- **iPhone e iPad**: la barra a tre stati e «Mandati oggi» arriveranno con il loro aggiornamento (l'iPhone non segna
  spediti e il giornale di «Prisma ovunque» non porta il segno).
- **Modalità cliente su iPhone e iPad**: sul Mac le occasioni del cliente si filtrano nel motore prima del limite di 8
  per gruppo (`soloCliente`); su iPhone e iPad `occasioniMessaggi` e il dossier filtrano ancora dopo il limite, come
  prima (dentro `#if os(macOS)`), e perdono le occasioni del cliente fuori dalle prime 8 di tutti. Portare la stessa
  correzione con l'aggiornamento di iPhone e iPad.

## 27. Vera dice cosa sa fare

Fatto (solo Mac, `#if os(macOS)`; iPhone e iPad tengono la colonna di prima e la fila dei suggerimenti sempre):
- **La colonna** dice tre cose: lo stato («Vera · pronta» / «non pronta» con «Verifica», già dalla 9), **«Parliamo di»**
  (`schedaAmbitoMac`: avatar 26 e nome del cliente della barra, o il glifo `person.2` e «Tutti i clienti», nessun
  controllo) e **«Per rispondere uso»** (`schedaFonti`: le righe con la spunta verde da `EsempiVera.fonti`, «Non invento
  cifre: se un dato manca, te lo dico.»). `ArchiviatiOggiVeraVista` resta. Escono «Oggi», «Da non dimenticare», il quadro
  del cliente e il tagliando (proposta di §27.6: sta in Impostazioni › Da sistemare dalla 31 e in Impostazioni › Vera).
- **Modalità Conversazione** (quella mostrata, `modalitaVeraMostrata`): «Parliamo di» si nasconde, «In questa
  conversazione» con «Le tue domande» e «Qui non uso i dati dei clienti.»; i riquadri non compaiono e resta la fila dei
  suggerimenti di sempre.
- **Gli esempi a conversazione vuota** (`GrigliaEsempiVera`, nuovo file Shell/GrigliaEsempiVera.swift; il nome
  `EsempiVera.swift` era già del motore e SwiftPM non vuole due file con lo stesso nome): «Puoi chiedermi, per esempio» e
  riquadri a due colonne (card con l'ombra, inclinazione 4°, cascata da 0,26 s senza sfocatura; fermi con «Riduci
  movimento» e nelle istantanee). Un clic chiama `chiediVera`/`chiediVeraPortafoglio` con lo spunto. La fila sopra il
  campo sparisce finché la conversazione è vuota e torna dopo la prima domanda; «Nuova conversazione» riporta i riquadri.
- **Il motore** `EsempiVera.per(cliente:portafoglio:)` (Vera/EsempiVera.swift, puro): con un cliente «Il cliente in
  breve» (`riepilogo`), «Una spiegazione» (`pensione` se ha previdenza in essere, altrimenti `protezione`), «Uno scenario»
  (`resistenza` con investimenti, `cambiare` con altre posizioni, nessuno senza posizioni); con «Tutti i clienti» quattro
  spunti del portafoglio (settimana, ricontattare, scadenze, quadro). Le domande restano quelle degli spunti (generiche):
  il catalogo non riconosce le frasi con il nome. Profilo del cliente in `ricavato("vera-esempi-<id>")`.
- Testi in `TestiVera` (nuovo, nello stesso file), token in `Tema.Apple.Vera.Colonna` (ambito, fonti) e nel nuovo
  `Tema.Apple.Vera.Esempi`. Prova `ProvaEsempiVera` in `--prova-vera`. Istantanee nuove `1045-uso-vera-tutti-i-clienti`
  e `1046-uso-vera-conversazione` (chiare e scure).

Resta:
- **«La giornata» con un cliente scelto** («Cosa ho oggi?»): non c'è, perché non è provato che la Vera grande la tenga
  nella conversazione del cliente (passa da `smistaVera` e dai comandi dell'agenda). Provarla con `--prova-vera` e, se
  resta nel dossier, aggiungerla come primo esempio con un caso in `ProvaEsempiVera`.
- Il passo della cascata è quello del tema (0,048 s) e non 0,07 del template: serve un `ritardo` con passo proprio in
  `EntrataApple` se lo si vuole esatto.
- I token di «Oggi», dell'avviso e delle tessere in `Tema.Apple.Vera.Colonna` restano: li usano ancora iPhone e iPad.
- Il tagliando nella colonna rifaceva l'esito in memoria all'apertura di Vera: sul Mac ora lo rifà solo la sua pagina e
  il controllo notturno; verificare che la riga di Da sistemare resti in pari dopo correzioni fatte a mano.
- `--prova-fluidita`: la colonna sul Mac non legge più `attivitaAperte` né `posizioniCliente`; nessun controllo nuovo.
- Rigenerare sul Mac 480-487, 19-vera, 46-vera-pensione, 47-vera-checkup e guardare 1045 e 1046 (la colonna stretta a
  metà schermo e la griglia nella finestra piccola).

## 28. Le parcelle dicono a che punto sono

Fatto (solo Mac, `#if os(macOS)`; iPhone e iPad tengono la colonna di prima e «＋ Nuova parcella» in fondo all'elenco):
- **Il prossimo passo** in `MotoreParcelle.passo(_:oggi:)` (enum `PassoParcella`: emetti, preparaXML, segnaPagata,
  nessuno) e `indicePasso` (bozza 0, emessa 1, pagata 2, annullata nil); il file XML si legge da `Parcella.documenti`
  (`haFileXML`). Prove in `--prova-calcoli` (i quattro stati, con e senza file, scaduta e no).
- **«A che punto è»** in cima alla colonna delle azioni (larga 236): occhiello, `PassiApple` (nuovo componente generico
  in DesignSystem/Apple/PassiApple.swift, token in `Tema.Apple.Passi`) e la frase `TestiParcelle.aChePunto`: bozza,
  «Emessa il …, oggi|ieri|N giorni fa: <Nome> non l’ha ancora pagata.» con « La scadenza è passata.» se
  `MotoreParcelle.scaduta` (proposta di §28.6 al posto dei 30 giorni), «Pagata il …», «Annullata il …» senza passi.
- **Un solo pulsante blu**: bozza «Emetti la parcella» (conferma di sempre) e «Modifica la bozza» (niente «Salva PDF»,
  proposta di §28.6); emessa senza file «Prepara il file XML» (o «Completa i dati» blu, verso Impostazioni › Studio o il
  dossier), «Manda con Messaggi», «Segna come pagata», «Salva PDF»; emessa con il file «Segna come pagata», «Manda con
  Messaggi» o «Manda un sollecito» se scaduta (stessa occasione «da saldare» di Messaggi), «Prepara di nuovo il file
  XML», «Salva PDF»; pagata «Salva PDF», «Prepara di nuovo»; annullata «Salva PDF», «Duplica come bozza». La nota del file
  XML solo prima del file; la tessera «✓ File XML pronto» anche dal file già nella parcella.
- Avvisi «Parcella emessa: ora prepara il file XML» e «Segnata come pagata: <importo> nel totale incassato»; dopo i due
  passi il filtro torna a «Tutte» e la scelta resta sulla parcella.
- **Il filtro** (`FiltroParcelle`, `@State` in memoria) a tutta larghezza sotto le tessere, con i numeri veri; vuoto:
  «Nessuna parcella con questo stato.». Una parcella nascosta dal filtro lascia il posto alla prima visibile.
- **«＋ Nuova parcella»** nella riga in testa di Studio (`AzioniStudio`, solo nella scheda Parcelle e non in modalità
  cliente): fa crescere `StatoShell.richiestaNuovaParcella` (in memoria), che la scheda osserva per aprire il modulo.
- Istantanee nuove 1047-uso-parcelle-bozza (anche scura), 1048-uso-parcelle-scaduta, 1049-uso-parcelle-filtro,
  1050-uso-parcelle-pagata; `RichiestaIstantaneaParcelle` prende il filtro. 510-514 cambiano da sole.

Resta:
- `--prova-fluidita`: nessun controllo nuovo che cambiare filtro non rifaccia `studio.parcelle.elenco` né i totali (il
  filtro è uno stato della vista e l'elenco sta in `ricavato`, quindi non li rifà; manca solo la prova scritta).
- Coordinarsi con la 52 (gruppo 09), che tocca la stessa riga in testa di Studio.
- Rigenerare sul Mac 510-514 e guardare 1047-1050: altezza della colonna delle azioni nelle finestre basse (la scheda
  «A che punto è» aggiunge circa 110 punti sopra i pulsanti) e il filtro nella barra stretta a 300.

## 29. Mercato segue il cliente, e ogni avviso ha la sua azione

Fatto (solo Mac, `#if os(macOS)`; su iPad fascia verde, interruttore e «Soglie degli avvisi» blu restano come prima):
- **Etichetta della riservatezza** `EtichettaRiservatezzaMercato` come primo elemento di `AzioniMercato`: lucchetto e
  «Escono solo dati pubblici» (acceso) o «Niente esce dal Mac» (spento, il caso di base), si solleva di 2 sotto il
  puntatore. Apre il foglio nuovo `FoglioMercato.riservatezza` (`FoglioRiservatezzaMercato`): «Riservatezza», il titolo
  uguale all'etichetta, la frase di sempre (`TestiAppMercato.fascia`, senza gli ISIN) e, spento, «Impostazioni ›
  Mercato». La fascia verde non c'è più sul Mac: la striscia sale.
- **Il filtro per cliente**: con un cliente nella barra `RiquadroToccati` e `RiquadroAvvisi` prendono `cliente:` e
  mostrano solo i suoi eventi e avvisi; titoli «Cosa tocca <Nome> oggi» / «… dall’ultimo aggiornamento» e «Avvisi per
  <Nome>», vuoti «Oggi il mercato non tocca <Nome>.» e «Nessun avviso per <Nome>.». La scheda dice la frase sua
  (`TestiAppMercato.fraseToccato`), senza avatar, con «Prepara un messaggio».
- **Le righe degli avvisi**: via l'interruttore senza nome; il pulsante dell'azione per tipo (`AzioneAvvisoMercato`:
  «Apri la posizione» / «Apri le posizioni» per calo dal massimo e distanza, «Prepara un messaggio» per cedola e
  variazione) e «Silenzia». «Apri le posizioni» (`apriPosizioniAvvisoMercato`) sceglie il cliente in silenzio e apre
  Posizioni sul suo quadro; il messaggio senza Messaggi consentito ripiega sull'apertura. Silenziato = `.visto` di sempre:
  riga al 60%, «Silenziato: niente più notifiche» (nessun avviso entra nel «Da fare», §29.6), solo «Riattiva»; avvisi
  «Silenziato: resta qui in grigio…» e «Riattivato: torna nelle notifiche». Il menu contestuale dice «Silenzia» /
  «Riattiva».
- **«Soglie…»** sobrio in alto a destra del riquadro degli avvisi apre il foglio delle soglie di sempre; «Soglie degli
  avvisi» blu tolto dalla riga in testa del Mac.
- Prove in `--prova-calcoli` (`ProvaCalcoliMercato.usoMercato`): `fraseToccato` con e senza cifra, con uno o due canali,
  `AzioneAvvisoMercato` per ogni `TipoEventoMercato`, l'etichetta e i titoli. La prova delle richieste non cambia.
- Istantanee: 540-547 ora su «Tutti i clienti» esplicito; nuove 1051-uso-mercato-cliente (Marco, anche scura),
  1052-uso-mercato-riservatezza e 1053-uso-mercato-spento.

Resta:
- La frase per il singolo cliente non dice ancora la quota in azioni del template («ha il 38% in azioni»): il motore
  non la porta in `ClienteToccato`.
- I pulsanti degli avvisi usano `.apple` di misura normale (il tema non ha ancora una variante piccola 6×12).
- Rigenerare sul Mac 540-547 e guardare 1051-1053: con i dati di prova Marco potrebbe non avere eventi o avvisi (allora
  1051 mostra i due vuoti con il nome); la larghezza della riga degli avvisi con due pulsanti nelle finestre strette.
- Se la miglioria 3 porterà gli avvisi `.nuovo` nel «Da fare», cambiare `TestiAppMercato.silenziato` in «Silenziato:
  non entra più nel «Da fare»».

## 32. La mappa risponde

Fatto (solo Mac, dentro `#if os(macOS)`; l'iPad tiene il clic che apre il dossier):
- **La scheda della luce**: il clic su una luce scrive `StatoTerritorio.luceScelta` (in memoria) e apre `SchedaLuce`
  (Shell/MappaTerritorio.swift): avatar 34, nome e zona, il patrimonio in un'etichetta con le etichette dei canali,
  «Cliente dal <anno>» («In Prisma dal <anno>» se l'anno viene solo dalla scheda, proposta) e « · ha qualcosa da fare»,
  «Apri il dossier». 22 a destra e 44 sopra la luce, fra il pannello e il bordo destro; entra con la molla del tema
  (0,26 s × ritmo, scala 0,9 → 1), ferma con calmo e nelle istantanee. Si chiude con un clic fuori, con Esc (prima di
  tutto il resto), accendendo un riquadro, al cambio di vista o di cliente, al doppio clic, al pizzico e al
  trascinamento. Il fumetto al passaggio resta, ma non sulla luce con la scheda. Il ⌥ clic passa da `scegliCliente`.
  VoiceOver: con la scheda aperta la mappa offre l'azione «Apri il dossier di <Nome>».
- **«Apri «Da fare» ›»** in fondo a «Con qualcosa da fare» (`TileTerritorio.collegamento`, fuori dal clic della tile:
  con il collegamento la tile si accende con un tocco, non con un Button annidato) apre il «Da fare» su «Tutti».
- **Il cliente scelto** (solo vista Oggi): `MotoreTerritorio.vicini` (soglia `minutiVicini = 10`, stima di `tratto`),
  in cache con `stato.viciniTerritorio` (chiave con le luci e i parametri della stima). Senza filtro acceso restano
  accesi lui e i vicini (le altre a 0,28, proposta §32.6), con l'anello bianco che va e torna (2,4 s, 0,95 → 0,2) e non
  conta fra i 12; un filtro acceso vince. In cima al pannello `TileClienteTerritorio` (bordo accento al 40%) con la
  frase `TestiTerritorio.vicini` (anche «Nessun cliente a meno di dieci minuti da <Nome>.», proposta) o, se non è sulla
  mappa, «<Nome> non è sulla mappa: manca l’indirizzo.» con «Metti la posizione a mano» (la specifica diceva «Mettilo a
  mano»: Prisma non conosce il genere). Cambiare cliente azzera filtri e scheda.
- Prove in `--prova-calcoli` (`ProvaCalcoliTerritorio.vicini`): appena sotto e a dieci minuti, stesso comune contro
  comuni diversi, posizione a mano senza comune, cliente non sulla mappa, frasi.
- Istantanee: 700, 701, 702, 706 e 708 su «Tutti i clienti» esplicito (700 ora con «Apri «Da fare» ›»); nuove
  1100-uso-territorio-scheda-luce (anche scura), 1101-uso-territorio-cliente, 1102-uso-territorio-cliente-filtro e
  1103-uso-territorio-cliente-senza-luogo.

Resta:
- La caduta delle luci spente in 0,4 s del template: l'opacità cambia di colpo (le luci sono disegnate in un `Canvas`).
- Al passaggio i riquadri non si alzano di 1 e non hanno l'anello azzurro (l'app li accende con il fondo, come prima).
- La prova di fluidità per «cambiare cliente non rifà `territorioOggi`» non è stata scritta.
- Guardare sul Mac 1100-1103: se Giulia ha vicini con i 35 clienti di prova, la posizione della scheda vicino al bordo
  (l'altezza per tenerla dentro la mappa è stimata, 170) e la lunghezza della riga patrimonio + due canali.

## 33. Pratiche segue il cliente, e i passi vuoti dicono cosa conterranno

Fatto (solo Mac; su iPhone e iPad `clientePratiche` è sempre nil e Pratiche resta com'era):
- **Chi è il cliente**: `StatoShell.clientePratiche` (Shell/PraticheCliente.swift), nil con «Tutti i clienti».
  Le strade che portano Pratiche su un cliente passano da `portaAlClientePratiche` (sul Mac `scegliCliente` in
  silenzio): riquadro finale, «Rimedia», prospetto, «Presenta», tappa 5 dei moduli, `proponiDaAzienda`, i bisogni chiesti
  da fuori (`richiediBisognoProposta`, se la barra è su un altro cliente), la carta «moduli» della notte, un sinistro
  aperto o salvato di un altro cliente.
- **Proposta**: `bisogniProposta(solo:)` filtra dopo la cache su tutti; barra «Bisogni scoperti per <Nome>»; senza
  bisogni lo stato vuoto nuovo `VuotoClientePratiche` con «Apri Analisi 360». Il clic su un bisogno con «Tutti i
  clienti» non cambia il cliente. I passi spenti dicono cosa conterranno (`RiquadroPassoProposta.anticipo`, testi
  `TestiPratiche.anticipiPassi`), anche con «Tutti i clienti»; VoiceOver legge «1. Il prodotto: …».
- **Moduli**: tolti `StatoModuli.clienteId`, `clientiRecentiModulo`, `scegliClienteModulo`, i chip e la ricerca «Altri».
  Con un cliente «Compilo per <Nome Cognome>»; senza, «Per chi lo compilo?» con «Scegli il cliente» e «✦ Compila con i
  dati del cliente», che aprono il pannello della barra. Al cambio di cliente la proposta e la compilazione del cliente
  di prima si azzerano (`onChange` in PraticheModuli).
- **Dopo la firma**: la cache degli stati è in `StatoShell.cacheStatiPratiche` con il cliente negli ingressi; tile
  ricontate sulle sue pratiche (la terza resta «Concluse a <mese>», proposta); senza pratiche del cliente «Nessuna pratica
  aperta per <Nome>.» al posto di tile ed elenco (come il `pratVuoto` del template).
- **Sinistri**: solo quelli del cliente, il primo scelto; senza «Nessun sinistro per <Nome>.» con «Nuovo sinistro»
  (proposta). Il modulo del nuovo sinistro con «Tutti i clienti» parte senza cliente («Scegli il cliente», «Salva»
  spento).
- **Il numero sul segmento**: `SegmentatoPillola` ha il parametro facoltativo `numero` (`NumeroVoceSegmentato`, token in
  `Tema.Apple.Controlli.Segmentato`); su «Dopo la firma» le pratiche ferme in rosso, VoiceOver «Dopo la firma, 1
  pratica ferma».
- Istantanee: 800-807, 820-823 e 830-835 su «Tutti i clienti» esplicito; nuove 1105 e 1106 (chiare e scure), 1107-1112.

Resta:
- La prova di `--prova-fluidita` («la testata di Pratiche non rifà MotorePratiche a ogni disegno», «scegliere un cliente
  filtra senza rifare `bisogniProposta`») non è stata scritta.
- Guardare sul Mac 801 e 1105: che la riga dei passi spenti si legga con l'opacità 0,7 del riquadro (se no va fuori
  dall'opacità), e 1106 se nessun cliente di prova è senza bisogni (la scena apre proposte presentate per il primo).
- I token dei chip di «Compila per» (`Tema.Apple.Pratiche.Moduli.chip…`, `paddingPopover`) restano nel tema, non più
  usati.

## 34. Le esperienze della Sala, al momento giusto

Fatto (solo Mac, `Tema.Apple.SalaEsperienze.Momento.ammesso`; iPhone e iPad tengono la griglia di prima):
- **Il modello** (Shell/StatoSala.swift): `MomentoSala` (Per aprire · Per spiegare · Per chiudere · Dopo l’incontro);
  in `EsperienzaSala` `momento`, `minuti` (le stime del template, come «circa»; il Prisma del cliente senza durata),
  `areaConsigliata` e la funzione pura `consigliate(priorita:)` (al più due, il risparmio saltato).
- **Le priorità** sono quelle della miglioria 17 (`PrioritaAree360.calcola`, stessa fonte e stesso ripiego delle card di
  Analisi 360), in cache con `stato.ricavato` (`prioritaAree360`, `esperienzeConsigliate` in Shell/SalaMomenti.swift).
- **Le schede**: «<momento> · <n> min» in alto a destra (perde la durata se accanto al tassello non c'è posto),
  «Consigliata per <Nome>» verde sotto il tassello delle piccole, dentro la colonna (non copre il titolo); le schede di
  un altro momento a 0,26 in 0,35 s × ritmo, cliccabili e inclinabili. VoiceOver legge momento, durata e consiglio.
- **Il filtro** nella testata (`FiltroMomentiSala`, osserva solo `sala.esperienza` e `sala.momento`), nascosto sul
  palco; `StatoSala.momento` in memoria, si azzera alla chiusura della Sala.
- Niente indicazioni senza cliente, in modalità cliente e nella vista pulita (`StatoShell.indicazioniSala`); presentazione
  e tavolo non mostrano la griglia.
- Prova `ProvaCalcoliSalaMomenti` in `--prova-calcoli`; istantanee nuove 1115-uso-sala-momenti (chiara e scura),
  1115-uso-sala-momenti-stretta, 1116-uso-sala-momento-filtrato, 1117-uso-sala-senza-priorita (con il campo di prova
  `StatoSala.senzaPrioritaIstantanea`). 618-app-nuove-sala e 690 ora mostrano le etichette.

Resta:
- La prova «in modalità cliente nessuna indicazione» con uno `StatoShell` vero non è stata scritta (la regola è in
  `indicazioniSala`); controllare 692 e 693 nelle istantanee.
- Guardare sul Mac 1115-stretta: con le schede piccole basse l'etichetta verde toglie spazio a titolo e frase.
- Analisi 360 calcola ancora le priorità per conto suo (`ingressiCard`): potrebbe usare `prioritaAree360` per avere un
  solo punto.

## 35. Biblioteca: prima i documenti del cliente, e si aprono con un clic

Fatto (solo Mac: la Biblioteca c'è solo lì; `clienteBiblioteca` vale nil su iPhone e iPad):
- **I documenti del cliente** (Motori/MotoreBibliotecaCliente.swift, puro): `prodottiDelCliente` (posizioni in essere e
  proposte non rifiutate) e `documentiDelCliente(prodotti:tra:)` (anche gli illeggibili, nell'ordine dell'elenco). Nello
  stato `documentiBibliotecaCliente(_:)` (Shell/BibliotecaCliente.swift) con `stato.ricavato` e la firma dei documenti
  (id e prodotto collegato) nella chiave. Nessun campo nuovo: il legame passa dal prodotto.
- **La colonna in due gruppi**: «Dei prodotti di <Nome>» con il numero e il «+», poi «Gli altri documenti» (14 sopra)
  dentro il `LazyVStack`, le letture in corso in cima. Senza cliente o senza documenti suoi: «I documenti» come prima.
- **Le domande d'esempio**: `suggerimentiBiblioteca(documento:)`. I fac-simile hanno la tabella
  `EsempiBiblioteca.domande` (documento e cliente di prova nominato): con un altro cliente scelto la domanda su Marco
  non si vede, in modalità cliente resta senza nome. Per i documenti dell'utente «Cosa dice «<rubrica>»?» dalle
  intestazioni dei suoi passi (al più tre).
- **Il documento aperto**: due colonne come la risposta. A sinistra la tile (genere, titolo 21 grassetto, «N pagine ·
  canale …» o «vale per tutti i canali», «Vera l’ha letto sul Mac.» o, per un illeggibile, «Non posso leggerlo: le
  domande non trovano niente qui.»), «Domande su questo documento» (a capo, angoli 14) o «Chiedi tu» con il testo del
  template; a destra il vassoio con le frecce. Entra salendo di 8 con la dissolvenza in 0,32 s
  (`B.entrataDocumento`, ferma con «Riduci movimento» e nelle istantanee).
- **Il campo**: con un documento aperto «Chiedi qualcosa su «<titolo breve>»…», svuotato all'apertura di un documento
  nuovo (non cambiando pagina).
- **La ricerca dentro il documento** (proposta §35.6): la domanda dal campo o dalle domande del documento cerca solo lì
  (`MotoreBiblioteca.cerca(_:in:quanti:solo:)`, l'idf resta quello di tutto l'indice; `StatoTrovaPagina.cerca(_:solo:poi:)`;
  `chiediBiblioteca(_:subito:solo:)`); «ho cercato in N pagine» conta le pagine di quel documento. Le pillole sopra la
  risposta cercano sempre in tutti.
- **Segue il cliente**: `scegliCliente` chiama `chiudiBibliotecaPerCliente()` (risposta, documento aperto, domanda in
  corso).
- Prove: `ProvaCalcoliBiblioteca.delCliente` (`--prova-calcoli`) e `ProvaTrovaPaginaVera.documentoAperto`
  (`--prova-vera`). Istantanee nuove 1120-uso-biblioteca-cliente-documenti (chiara e scura),
  1121-uso-biblioteca-documento-aperto, 1122-uso-biblioteca-documento-senza-domande; 870, 873-878 scelgono «Tutti i
  clienti» in modo esplicito e restano come prima.

Resta:
- «Cerca in tutti i documenti» per ora è il pulsante sotto la tile del documento aperto (al posto di «Torna alla
  risposta» quando non c'è una risposta): decidere guardando 1121 se serve anche accanto al campo (§35.6).
- I fac-simile non sono collegati ai prodotti di prova (proposta §35.6): con i soli dati di prova il gruppo del cliente
  si vede solo collegando a mano un documento (come fanno 1120-1122). Decide l'utente se `caricaEsempiBiblioteca`
  debba collegarli ai prodotti con lo stesso nome.
- Le domande del documento non si sollevano al passaggio del puntatore come le pillole: guardare sul Mac se serve.

## 40. Il radar dice chi e perché

Fatto (solo sul Mac; iPhone e iPad tengono la colonna di prima, con i testi `riequilibraClienti` e
`spiegaRiequilibraClienti`, fino al loro aggiornamento):
- Card dei modelli a riga unica (nome largo 92 e barra), pesi nell'aiuto della riga, legenda a colori
  (`LeggendaClassiRadar`).
- Card «chi» (`CardChiRadar`) al posto del conteggio e dei «più lontani»: numero, «fuori tolleranza», «su N seguiti con
  un modello» (aiuto: previdenza esclusa), «punti» spiegato con la tolleranza delle impostazioni, elenco pigro di tutti
  i fuori dal più lontano con capsula dei punti o «Proposta pronta», pulsante «Prepara le N proposte di riequilibrio»;
  dopo il pulsante il numero dice quanti resterebbero fuori accettando le proposte, i punti restano col trattino. Via
  la nota in fondo.
- `PuntatoreRadar` sale a `CorpoRadar`: la riga accende il punto (alone bianco nel fumetto, che resta l'unica vista che
  legge il puntatore).
- Capsula di stato comune `CapsulaStatoApple` (token in `Tema.Apple+CapsulaStato.swift`: `Tema.Apple+Capsula.swift` è
  della capsula del tempo).
- Dettaglio: «Apri le posizioni di …» → `apriPosizioniDalRadar` (cliente scelto, ancora «coerenza»); il doppio clic sul
  punto apre ancora il dossier.
- Istantanea nuova 898-posizioni-radar-riga-accesa (chiara e scura); prove dei testi in `ProvaCalcoliRadar`.

Resta:
- `--prova-fluidita`: il passo che conta i corpi passando sulle righe (`ContaCorpi`) non c'è; il passaggio del puntatore
  non si simula dal codice. Da guardare sul Mac (passare sulle righe non deve rifare la tela).
- La card «chi» che occupa l'altezza va guardata nelle istantanee 890, 895 (elenco lungo che scorre dentro) e 897
  (finestra stretta: l'elenco si allunga nello scorrimento della pagina).
- Il nome sotto i punti piccoli al passaggio (`.rNm2`): il fumetto mostra già nome e distanza, non si è aggiunto altro.

## 41. La prova del fuoco in tre gruppi

Fatto (solo sul Mac; l'iPad tiene la lista, la riga con «Chiama» e «Messaggio» e i testi di prima fino al suo giro):
- Motore: `RigaProvaFuoco` ha in più `quotaAzioni`, `quotaObbligazioni`, `quoteStimate`, `anniAllObiettivo` e
  `patrimonio` (tutte le finanziarie in essere); `GruppoProvaFuoco` (da chiamare, da tenere d'occhio, reggono, senza
  obiettivo) da `livello(calo:)`; `anniPocoTempo = 5`. Coperture e ordine non cambiano.
- Lista a gruppi (`ProvaDelFuocoApple.listaGruppi`): testate (`TestataGruppoFuoco`, capsula `CapsulaStatoApple` con il
  conto e la frase con le soglie del motore) nello stesso `LazyVStack` delle righe con id distinti; i gruppi si prendono
  insieme all'ordine (`gruppiMostrati`): mentre si trascina il cursore restano fermi, al rilascio scivolano con le righe.
- «Chi sentire, in ordine» con la legenda (`BarrettaLegendaFuoco`) e «patrimonio in meno» sopra la colonna della perdita.
- Riga Mac (`RigaProvaFuocoMac`): avatar 34, «oggi → dopo» (rossa per chi è da chiamare, «≈» delle stime), perdita
  larga 104, «›», fondo `chip` al passaggio, tutta la riga apre il dettaglio; il canale resta; via «Chiama» e
  «Messaggio».
- Dettaglio 840×440 (`DettaglioProvaFuoco`): occhiello del gruppo con lo scenario, «Obiettivo: …» che apre il dossier
  sull'obiettivo, tre riquadri, «Perché» (`TestiProvaFuoco.perche`), «Prepara il messaggio» (Messaggi sull'occasione),
  «Segna «da chiamare»» (`segnaDaChiamare`, attività `task-fuoco-<cliente>-<giorno>`, idempotente), «Apri la sua prova di
  resistenza» (`apriResistenzaDaFuoco`, ancora «resistenza»). Senza obiettivo: «Nessun obiettivo nel dossier» e
  «Aggiungi un obiettivo». Si chiude con dati nuovi.
- «Prepara i N messaggi» (`preparaMessaggiProvaFuoco`): bozze del modello fisso (cordiale, Mail), una sola assegnazione a
  `dati.messaggi`, idempotente sull'occasione; «✓ Preparati» finché scenario e valore non cambiano (stato della vista).
- Istantanea nuova 599-posizioni-fuoco-dettaglio (chiara e scura); prove P17 (gruppi, quote, anni, «Perché», testi) e
  P18 (solo Mac: niente doppioni di bozze e attività) in `ProvaCalcoliProvaFuoco`.

Resta:
- Le istantanee 590-598 cambiano (gruppi, legenda, «oggi → dopo», niente pulsanti): vanno guardate, in particolare 598
  (finestra stretta: la legenda può troncarsi) e 596 (il quarto gruppo «Senza obiettivo»).
- `--prova-carico` e `--prova-fluidita` non hanno un passo nuovo per le testate e il riordino a gruppi con 200 clienti:
  da guardare sul Mac (il calcolo dei gruppi è lineare sulle righe mostrate).
- «Prepara il messaggio» del dettaglio apre Messaggi come prima (`preparaMessaggio`): la bozza non si salva da sola; il
  template la crea e apre Messaggi su quel messaggio.

## 43. Prima di aggiungere, si controlla (Inquadra e Nuovo cliente)

Fatto (solo sul Mac; la `RigaSchedaInquadra` comune e la schermata dell'iPhone restano come sono):
- Motore (solo funzioni nuove, in `Motori/SchedaInquadra.swift`): `MotoreInquadra.daControllare` (le quattro regole di
  43.3 punto 2, solo righe con un valore), `applica(_:correzioni:)` (scrive le correzioni leggibili nei campi **e negli
  estratti**: il documento e la posizione nascono dai dati corretti; senza correzioni i dati restano identici),
  `correzioneLeggibile`, `cifra`, `dataScritta` («01/03/2021», «1 marzo 2021», «marzo 2021»).
- Stato (`StatoInquadra`): `correzioni`, `confermate`, `inModifica`, `scosse`, `datiCorretti`, `righeCorrette`,
  `dubbi(canale:)`; si azzerano con la scena e con un foglio nuovo. `clienteInquadra`, `canaleEAreaInquadra`,
  `posizioneGiaInquadrata`, `aggiungiInquadrata`, `confrontaInquadrata…` usano i dati corretti; il documento arrivato
  dall'iPhone prende i campi corretti. Nuovi (solo Mac): `origineClienteInquadra`, `avvisoClienteInquadra`,
  `scuotiDubbiInquadra`.
- Scheda: `RigaSchedaInquadraMac` (clic per correggere, Invio/Esc, matita, fondo arancio e «?» con «Va bene», scossa con
  `ScuotiEffetto`), «Di chi è» in testa alle righe con i quattro casi e l'avviso arancio, titolo «Letta: un dato da
  controllare» / «Letta e controllata», «Controlla il dato in arancione» (non blu, scuote e avvisa), poi «Aggiungi alle
  posizioni di …» e la conferma di sempre; «Senza iPhone? Scegli un file dal Mac» in fondo. Esc chiude prima la modifica.
- Nuovo cliente: sottotitolo «Letta dal documento: controlla e completa», righe «＋ Telefono» (dal potenziale con
  «Diventa cliente») e «＋ Canale» (nessuno acceso di base, nomi delle impostazioni), riga in fondo con «Scrivi tu i dati» e
  «Scegli un file dal Mac»; `clienteDaCarta` prende telefono e canali scritti.
- Istantanee: 604 con il «Tipo» in dubbio (foglio senza la compagnia, `FoglioInquadraDiProva.senzaCompagnia`); nuove
  1160 (chiara e scura), 1161, 1162, 1163. Prove IQ14-IQ16 in `ProvaCalcoliSchedaInquadra`, telefono e canali in
  `ProvaCalcoliCartaIdentita`.

Resta:
- «Va bene» usa il pulsante `.apple` (12,5 con padding 7×14) invece del 4×11 del template; «Cambia» è un menu sobrio
  (testo blu) e non un `.btn`.
- La riga «Tipo» si corregge in un campo solo («Vita intera · Esempio Vita S.p.A.»: la parte dopo «·» è la compagnia),
  non in due campi come le righe a più campi di Nuovo cliente.
- Esc con due significati (modifica, poi scena) e Invio nel campo con il pulsante principale accanto: serve uno
  screenshot o una prova sul Mac.
- Le istantanee 605, 606, 608, 609 e 841-849 cambiano (titolo, «Di chi è», righe in più, riga in fondo): vanno guardate.

## 42. Lo smontaggio ha i numeri

Fatto (solo Mac, `Shell/SmontaggioMac.swift`; l'iPad tiene `SmontaggioApple` con le note ai margini):
- Foglio senza note: accanto a ogni ellisse il cerchio rosso pieno con il numero della voce (raggio 11, 12 bold), che
  compare con la sua ellisse; il foglio non ha più i margini delle note (la scala cresce).
- Colonna a destra (520) con tre card: il documento («Documento di {nome} · valore {euro}», «Documento da assegnare»,
  l'origine nell'aiuto, avatar 38, titolo su una riga, «Cambia ⌄», «Costi l’anno, oggi» → «Con la tua proposta» e a
  destra «In 10 anni» con il netto del confronto di oggi); «Le voci cerchiate, in ordine sul documento» (numero 22,
  nome, cifra del motore o «—», valore scritto · spiegazione, accensione con l'ellisse da 0,4 a 1, menu «Non è un
  costo»); in basso grafico piccolo 186×60 con la didascalia del motore, «Confronta con», «Crea la proposta di
  sostituzione» e «Smonta un altro documento».
- Voce accesa in comune (`SopraSmontaggio`, letto solo da ellissi e righe): puntatore sulla riga → ellisse con tratto 3,6
  e fondo rosso tenue; sull'ellisse → riga con fondo rosso 0,09.
- Documenti smontati (`StatoShell.documentiSmontati`, dato ricavato) e riapertura senza ricalcolo
  (`StatoShell.riapriSmontaggio`, `MotoreSmontaggio.righe(da:titolo:)`, `vociRiaperte`, `valoreDaVoci`,
  `versatoDaVoci`): con il testo in memoria il foglio vero, altrimenti ricostruito dalle voci; le cifre sono sempre
  quelle conservate. Un conservato non si modifica e non si aggiunge di nuovo al dossier.
- La vista segue il cliente: `StatoSmontaggio.documentoScelto` per vista (cliente o «Tutti»); il documento letto resta in
  memoria e ricompare tornando alla sua vista. Vuoto nuovo del cliente (avatar 58, «Nessun documento smontato per …»,
  «Inquadra un documento», «Vedi quelli degli altri clienti», che in modalità cliente non c'è).
- Indice delle Posizioni del cliente: «Smontaggio di un documento» con il numero, prima di «Passaggio generazionale»
  (`VistaPosizioniCliente.smontaggio`, ancora "smontaggio"), anche in modalità cliente.
- «Apri l'esempio (fac-simile)» solo con i dati di prova (`haDatiDiProva`); le proposte del cliente fra i dati ricavati.
- Istantanee nuove 887 (voce accesa, chiara e scura), 888 (cliente senza documenti, chiara e scura), 889 (indice di
  Giulia con il documento conservato ricostruito dalle voci). Prove «Smontaggio 42» in `ProvaCalcoliSmontaggio`
  (numerazione, foglio ricostruito, voci riaperte, valore e versato, documenti per cliente e per tutti, riapertura senza
  e con testo in memoria). Nessun campo nuovo nell'archivio.

Resta:
- Le istantanee 880-886 cambiano (numeri al posto delle note, elenco, cifre su una riga): vanno guardate, in particolare
  la finestra stretta (886) e la card delle voci quando la colonna è bassa.
- Le righe dell'iPhone che arrivano da sole (senza la scena di Inquadra) vanno allo Smontaggio solo nella vista
  «Smontaggio» del portafoglio (`provaFuoco.vista == .smontaggio`), non nella schermata del cliente: dal cliente si passa
  da «Smonta un altro documento» / «Inquadra un documento».
- I token delle note (`nota`, `larghezzaNota`, `distanzaNota`, richiamo) restano perché l'iPad li usa ancora: si tolgono
  con il giro dell'iPad.
- L'accensione al passaggio non ha animazione propria (cambia subito); le ellissi accese si vedono solo con il puntatore
  vero: serve uno screenshot sul Mac.
- Un documento conservato con il valore scritto ma senza voci calcolate e senza posizione collegata si riapre senza
  valore («Con la tua proposta» e il confronto restano «—»), perché il testo non è conservato (decisione 42.6).

## 44. Aggiorna valori: prima i dubbi

Fatto (solo Mac, `Shell/AggiornaValoriMac.swift`; l'iPad tiene `PannelloAggiornaValori`):
- Pannello nuovo nel tema Apple: testata «Aggiorna i valori · {nome}» con «Dall’elenco della compagnia.», ««file»: N righe
  lette» e «Scegli un altro file»; «Da decidere · n» / «Deciso» con i riquadri arancio (avatar 34, domanda in chiaro,
  «È giusto» / «È nuova» / «Scegli la posizione ⌄» e «Salta»; decisa: spunta verde e «Cambia»); «Pronti · n» in quattro
  colonne (1fr · 130 · 200 · 86) con la spunta in fondo alla riga e il totale colorato; «ⓘ … Va solo nello storico.»;
  «Non si registrano · n» chiusa di base. Filtro e indicatori di prima tolti; «Importa come nuove» uscito dal piede.
- Motore: `AggiornaValori.dubbio`, `daDecidere`, `pronte`, `esclusiPerRegistrare`, `soloStorico`, `nonSiRegistrano`,
  `nuove`, `posizioniNuove`, `canaleNuova`, `zero`; `Sessione.decisioni` e `clientiNuove` (solo memoria);
  `Riepilogo.nuove`.
- Pulsante: «Decidi la riga / le N righe in arancione» (non blu: il primo dubbio trema, avviso «Prima decidi le righe in
  arancione») oppure «Registra N valori» blu, con «Prima di registrare Prisma salva una copia: si può annullare.».
- «È nuova»: la posizione nasce alla registrazione (lettura dell'importazione, canale riconosciuto mostrato nella riga),
  insieme ai valori con una sola assegnazione; per chi non è fra i clienti «È nuova: di chi è? ⌄» chiede prima il cliente.
- Annullamento: `StatoShell.annullaValori` (in memoria, `@ObservationIgnored`), `puoAnnullareValori` (vale solo se le
  posizioni toccate sono ancora quelle di subito dopo), `annullaRegistrazioneValori()`; si cancella con «Fatto», con una
  sessione nuova e al blocco. Riepilogo con «N valori registrati.», le frasi, «Prima», «Dopo», «Variazione»
  (`NumeroCheConta`), «Fatto» e «Annulla la registrazione».
- Con un cliente scelto l'elenco da file mostra solo le sue righe («N righe di altri clienti restano fuori», «Mostra tutto
  l’elenco»), e le righe nascoste non si registrano.
- Dati di prova: il calo del fondo pensione di Laura (18.000 → 13.100) e la temporanea AL-2024-077120 di Marco; la
  polizza di Sofia ora a 41.640 (prima 52.000, che con la regola nuova sarebbe stata un terzo tipo di domanda).
- Istantanee: 180 (e scura), 182 rifatte; nuove 184 (decisi, chiara e scura) e 185 (Marco). Prove AV37-AV42.

Resta:
- Nella scena 180 le righe da decidere sono 3, non 2 come nel testo della specifica: anche la polizza di «Paolo Neri» (chi
  non è fra i clienti) ha la sua domanda (44.3 punto 1).
- La griglia dei valori fermi ha solo le pillole a segmento e la tabella nel tema Apple (`.strumentiApple()`): le righe
  (`RigaGriglia`, condivisa con l'iPad) restano nei caratteri di prima.
- Il pulsante «Aggiorna valori» della barra di Posizioni resta nello stile di prima (tocca alle migliorie 4 e 6).
- L'annullamento dopo aver chiuso il pannello non c'è (proposta 44.6): resta il backup fatto prima di registrare.
- Le istantanee 180-185 vanno guardate, in particolare l'altezza dei riquadri dei dubbi e la colonna «prima → dopo» con
  importi a sei cifre.

## 45. Il simulatore mostra prima e dopo

Fatto (solo Mac, dentro `#if os(macOS)`; iPhone e iPad restano come prima):
- Previdenza (940×560) e Protezione (940×540): anello 190/19 con la percentuale 40, valore del cursore 40 (carattere
  proprio, quello da 44 resta alla Sala dei giochi), corpo e cursore a 14. Il segno «oggi» sotto il binario
  (`SegnoOggiCursore`, posizione corretta per metà manopola; protezione all'inizio). Lo scarto «+150 € al mese rispetto
  a oggi» a destra del valore (`TestiSimulatoriAnalisi.scarto`; «Nessun anno di accumulo…» al suo posto).
- La frase prima e dopo (`FraseSimulatoreApple`, testi in `Motori/TestiSimulatoriAnalisi.swift` con `articolo(_:)` e
  `al(_:)`), con i casi «non versa niente», «non ha divario» e il premio mancante (niente «per circa … al mese»).
- «LE IPOTESI»: rendimento da scegliere (quello dell'analisi e ±0,5 punti, mai sotto 0, solo nello stato della vista;
  la copertura di oggi si rifà solo al cambio di rendimento), aliquota dal reddito della scheda oppure segmentato quando
  manca, «deduzione fino a …»; protezione con da dove viene il premio (niente «Fuma», decisione 45-c). Le ipotesi intere
  nel suggerimento della riga. `SegmentatoPillola` ha la variante `compatto`.
- Piede con «Sono stime, non garanzie.» (`TestiSimulatoriAnalisi.avviso`); la nota della proposta ricorda il rendimento
  scelto se diverso da quello dell'analisi.
- Investimenti e Liquidità: `PassoDettaglioArea360` sopra il piede (testi in `TestiAree360.passoInvestimenti` e
  `passoLiquidita`, nessuna soglia dell'80%, soglia della riserva dalle ipotesi), che chiude il dettaglio e apre
  Posizioni con `StatoShell.apriPosizioniCliente(_:vista:)` (in `IndicePosizioniApple.swift`; nuova ancora «quadro»).
  I due dettagli crescono di 56 sul Mac (900×536 e 900×496).
- Istantanee 1140 (e scura), 1141, 1142, 1143; 441-444 mostrano già le novità. Prove in `ProvaCalcoliSimulatoriAnalisi`
  e `ProvaCalcoliAree360`.

Resta:
- Le aliquote da scegliere sono quelle degli scaglioni IRPEF di oggi (23 | 33 | 43, `RegoleFiscali.scaglioniIrpef`), non
  il «23% | 35% | 43%» del template: il 35% non c'è più dal 2026. Da confermare con l'utente.
- La frase non entra con la cascata del dettaglio: compare con il contenuto (che il dettaglio già fa entrare).
- Le altezze nuove (previdenza 560, investimenti 536, liquidità 496) vanno verificate nelle istantanee e a finestra bassa
  su 13": la frase a tre righe e la riga delle ipotesi senza reddito sono le parti più lunghe (il testo a destra si
  riduce fino all'80% e poi si tronca).
- «Sono stime, non garanzie.» non è ancora coordinato con la capsula delle stime della miglioria 16 (un solo testo,
  `TestiSimulatoriAnalisi.avviso`, pronto per essere riusato).

## 46. Il confronto con le famiglie porta a un passo

Fatto (solo Mac, dentro `#if os(macOS)`; iPhone e iPad restano come prima, salvo gli articoli della frase grande):
- `MotoreFamiglie.esitoPuntoDebole(_:)` / `puntoDebole(_:)` (`PuntoDeboleFamiglie`, `EsitoPuntoDeboleFamiglie`:
  `.indietro`, `.sopraLaMeta`, `.senzaCifre`), `area(_:)` voce → area, `voceSottoLaMeta(_:in:)` per le card.
- In fondo alla card principale, sopra un filo: `CapsulaStatoApple` «Dove resta indietro», la frase e il pulsante
  primario «Apri l'area …»; oppure la capsula verde «Sopra la metà in tutto» e «Non c'è un punto debole…». Senza cifre
  del cliente la riga non c'è. Resta anche in modalità cliente.
- «Apri l'area ›» (`StileCollegamento`) sulle card delle voci sotto la metà, accanto a «Completa nella scheda».
- `StatoShell.areaDaAprire` e `apriAreaAnalisi360(_:)`: torna alle quattro aree e, dopo 650 ms al ritmo dell'app
  (`Tema.Apple.Famiglie.attesaApriArea`; subito con «Riduci movimento»), apre il dettaglio dalla card (i simulatori per
  Previdenza e Protezione). Se Analisi 360 nasce con la richiesta il dettaglio è già aperto (istantanea 1145).
- Articoli: `Formati.elide`, `ilPercentuale`, `alPercentuale` (in comune con la 45); la frase grande dice «L'82% …» e
  «più dell'81%».
- Istantanee 1144 (e scura), 1145; prove P1-P7 in `ProvaCalcoliFamiglie`.

Resta / da decidere:
- Frasi senza percentile (decisione 46-a): con la quota il testo usa il nome («… ce l'ha, Giulia no.») al posto di
  «lui no» della proposta. Da approvare con le altre.
- Con la quota la voce è «sotto la metà» solo se più di metà delle famiglie ha la cosa e il cliente no (con le tavole
  della Banca d'Italia le polizze vita e i fondi pensione sono di una minoranza: chi non li ha sta con i più). La
  specifica diceva `sopra == false` e basta: scelta mia per non scrivere «la maggior parte ce l'ha» quando non è vero.
- Le voci con un percentile sotto la metà vengono prima di quelle con la sola mediana, media o quota (senza percentile
  si confrontano come 50): da confermare.
- Le card delle voci sono un solo elemento per VoiceOver (`children: .ignore`, come prima): «Apri l'area ›» e «Completa»
  non si raggiungono da VoiceOver dentro la card; il pulsante della card principale sì.

## 47. Ogni potenziale ha il suo prossimo passo

Fatto (solo Mac, dentro `#if os(macOS)` o in `Shell/DettaglioPotenzialeMac.swift`; iPhone e iPad restano come prima):
- `MotorePassaparola.prossimoPasso` / `passi` / `primiIncontri` / `fermi` / `giorniFermo`, `PassoPotenziale`,
  `AzionePotenziale`, `RegolePassaparola.giorniFermo = 14`; testi in `TestiPassaparola` (sezione «Il prossimo passo»).
  Nessun campo nuovo (47-a); il primo incontro si riconosce dal tipo e dal titolo `titoloPrimoIncontro` (47-d), che ora
  usa anche `fissaPrimoIncontro`. I passi si tengono con `stato.passiPotenziali()` (`ricavato`, chiave con l'ora).
- Scheda: nome 14 neretto, fonte, passo (accento, verde in «Cliente»), stima e «fermo da N giorni» (arancio scuro e
  semibold oltre 14); niente barra né probabilità. Il clic apre il dettaglio (anche per chi è cliente); menu con
  «Apri il dossier» per i clienti; ⌘→ e «Avanti» restano.
- Tile: la quarta è «Fermi da più di due settimane» (arancio se > 0); il probabile entro fine anno va nella nota del
  patrimonio (47-b).
- Dettaglio 820 × 460 (`DettaglioPotenzialeMac`): avatar 54 con le iniziali, occhiello «fase · fonte», tre tile, «Il
  prossimo passo», pulsanti (Chiama con il riquadro del numero e «Copia il numero», 47-c; Scrivi; Fissa l'incontro;
  Prepara l'incontro → Agenda), «Passa a «…»» o «Diventa cliente», «Non interessato»; per un cliente «Fatto», «Va bene»,
  «Apri il dossier»; sotto le righe di prima, «Modifica…» e «Scrivigli».
- «Passa a…», trascinamento e ⌘→ si annullano: `StatoPotenziali.ultimoSpostamento`, `spostaPotenzialeAnnullabile`,
  `annullaSpostamentoPotenziale` e la nota «**Nome** è passato a «fase». Annulla». Avviso di «Non interessato».
- Istantanee 1146, 1147 (e le 850-853 aggiornate da sole); prove del prossimo passo e dei giorni di fermo in
  `ProvaCalcoliPassaparola`.

Resta / da decidere:
- La nota della tile del patrimonio mostra il probabile quando c'è, altrimenti «N senza stima»: le due insieme non
  stanno su una riga. Da decidere quale prevale.
- I dati di prova hanno sette potenziali su otto fermi da più di 14 giorni (le date della storia erano già così): il
  template ne mostra meno. Si possono avvicinare le date se l'utente vuole un quadro più vario.
- Dopo «Chiama» Prisma non chiede com'è andata (non esiste ancora per i potenziali, 47-c).
- «Annulla» non vale per «Indietro» dal menu (chiude l'annullamento, come ogni altro spostamento).
- Il volo dopo «Passa a…» parte quando il dettaglio è tornato sulla scheda (`chiudi(poi:)`), con la molla di sempre
  (`Tema.Apple.Moto.Potenziali.avanza`).

## 48. Il passaparola segue la persona

Fatto (solo Mac, dentro `#if os(macOS)`; iPhone e iPad restano come prima):
- Clic su un cliente dell'albero (a qualsiasi livello) o su un ambasciatore: si sceglie la persona
  (`stato.potenziali.evidenziato`, solo in memoria); secondo clic, o «Tutti», spegne. ⌘-clic apre il dossier (48-c);
  un potenziale apre il suo dettaglio come prima. `NodoDisposto.antenati` dà il ramo di chiunque: restano pieni la
  persona, chi scende da lei e i loro legami (anche il legame verso la persona scelta, come nel template); il resto al
  20% (`Tema.Apple.Passaparola.opacitaSpenta`, 0,2 solo sul Mac) con `Tema.Apple.Moto.Passaparola.animazioneRamo`.
- Card «Il ramo di» (`RamoPassaparolaCard`) al posto degli ambasciatori, entrata 0,26 s dal basso di 6 punti: avatar 42,
  nome 19 bold, frase `TestiPassaparola.ramo(nome:clienti:valoreClienti:potenziali:)`, elenco con capsula «Cliente» /
  «Potenziale» (con la fase) e cifra, «Ringrazia …» e «Apri il dossier». Senza presentati: «Chiedi una presentazione»
  solo se c'è un momento giusto per quella persona (48-a), altrimenti la riga «Il momento giusto per chiedere te lo dice
  Prisma, dopo un fatto bello.».
- Le persone del ramo vengono da `MotorePassaparola.ramo(di:…)` (tutte, non solo le otto disegnate per persona e le tre
  generazioni dell'albero: con il «+ N» l'albero non basta), con le regole di `ambasciatori`; valore dei soli clienti.
- «Ringrazia …»: `TipoOccasioneMessaggio.ringraziamentoPresentazione` in fondo all'enum (non commerciale), modello nei
  tre toni in `ModelliMessaggi`, `StatoShell.preparaRingraziamento(clienteId:)` mette la bozza nel dossier senza
  cambiare app (come le campagne) e lo dice l'avviso; «✓ Messaggio pronto» quando la bozza di oggi esiste.
- Prestazioni: albero, ambasciatori, quota, nuovi per anno e patrimoni in `stato.datiPassaparola()` (`ricavato`), il
  momento giusto in `momentiPassaparola()` con l'impronta delle pratiche nella chiave. I potenziali sono neutri per i
  calcoli (`DatiVivi.potenziali`): la loro impronta va nella chiave. Corretto anche `passiPotenziali()` della 47, che
  senza l'impronta restava al passo di prima dopo uno spostamento.
- Istantanee 1148 (chiara e scura) e 1149; prove del ramo e del grazie in `ProvaCalcoliPassaparola`, il grazie nel
  campionario dei modelli (`ProvaCalcoliMessaggi`), andata e ritorno e tipo sconosciuto in `ProvaBackupLuceClienti`.

Resta / da decidere:
- 48-b: il testo del grazie nei tre toni va fatto vedere all'utente prima dell'unione (cordiale: «volevo dirti grazie:
  so che hai parlato di me a persone a cui tieni…»; formale con il lei; breve «grazie per aver parlato di me…»).
- La bozza del grazie è sempre nel tono cordiale e con il canale dal telefono (Messaggi con un cellulare, altrimenti
  Mail); si cambia in Messaggi prima di aprirla.
- L'avviso del template non ha un collegamento diretto a Messaggi: la bozza si trova nel dossier e in Messaggi.

## 49. La campagna in tre passi

Fatto (solo Mac, dentro `#if os(macOS)`; l'iPad in sola lettura resta come prima):
- `PannelloCampagna` in tre passi numerati (`PassoCampagna`: tondino 20 nel colore del gruppo, titolo 14 neretto,
  sottotitolo grigio): «1 · Chi» «{q} di {N} clienti con questo bisogno» con le righe di sempre e in testa la casella
  quadrata del tema (nuovo `CasellaSceltaApple`, 18 × 18, raggio 6, bordo 1,6 `inchiostro3`, piena d'accento con la
  spunta); tutta la riga include o esclude (consenso e recapito controllati come prima); le prime 8 righe e poi «e altri
  N clienti» con «Mostra tutti». «2 · Cosa scrivi»: «Tono» e «Invia con» (49-a), poi «Anteprima per {nome}» o «Scegli
  almeno un cliente.». «3 · Quando»: capsule accese (accento, testo bianco) o spente, niente barrato; tutte accese di
  base (49-b); con l'agenda piena la frase di sempre e il pulsante non chiede orari.
- Il piede resta fermo sotto i passi (lo scorrimento è solo dei passi): pulsante grande a tutta larghezza
  `TestiCampagne.pulsante(…)` («Prepara il messaggio» / «Prepara N messaggi»; spento «Scegli almeno un cliente», «Scegli
  almeno un orario», «Scegli la firma»), sopra la nota di chi resta fuori solo quando serve, sotto «Niente parte da solo:
  li rileggi e li spedisci tu, da Messaggi.».
- Dopo: «✓ pronto in Messaggi» in verde con il lampo, una riga dopo l'altra ogni 320 ms
  (`Tema.Apple.Moto.Campagne.pronta`, `ritardoPrisma`); avviso «N messaggi preparati: sono in Messaggi, da rileggere»;
  «Apri i messaggi preparati» apre Messaggi sulla prima bozza ancora da aprire (`preparaMessaggio(clienteId:messaggioId:)`,
  non Mail); sotto, sobri, «Apri la prossima in …», «Apri tutte», «Annulla la campagna». Una campagna riaperta dallo
  storico non lampeggia più.
- Con un cliente nella barra e nessun gruppo scelto, Campagne si apre sul suo gruppo.
- Istantanee 1150 (un orario spento) e 1151 (nessun cliente); prove dei testi del pulsante in `ProvaCalcoliCampagne`.

Resta:
- Il passaggio «Preparo…» del pulsante: l'avvio è sincrono (le bozze nascono subito), quindi il pulsante passa
  direttamente a «Apri i messaggi preparati» mentre le righe si accendono una dopo l'altra.
- Le istantanee non mostrano il lampo (stato finale) né «Mostra tutti» aperto: da guardare sul Mac.

## 50. Il mese a tutta larghezza

Fatto (solo Mac, dentro `#if os(macOS)` o nel file solo Mac `Shell/AgendaMeseUso.swift`; iPhone e iPad tengono la
griglia di sempre con la colonna al 42%):
- **La griglia** (`MeseAgenda.grigliaUso`): testata alta 26 «LUN … DOM» (11,5 semibold, maiuscolo, `inchiostro2`, a 10
  dal bordo), celle come card (`CellaMeseUso`: raggio 14, fondo `card`, filo `separatore`, padding 7 × 8, 6 di spazio),
  sabato e domenica sul fondo dei pannelli (`Colori.Agenda.festivo`), i giorni fuori mese senza fondo né bordo e senza
  righe, il numero nel tondo 22 (oggi rosso pieno), il giorno scelto con l'anello d'accento di 2 fuori dalla cella,
  passaggio `cardPiena`. Doppio clic: il giorno in «Giorno».
- **Le righe della cella** (`RegoleMeseAgenda.righe`, regola pura): al più due impegni, uno solo se c'è una scadenza;
  la pillola con l'ora in peso normale e il nome breve del cliente (il titolo senza cliente), filo e fondo **del canale**
  (50-a); le scadenze scritte «Scade {posizione}» con il pallino arancio; poi «+N altro / altri». Se le righe non stanno
  si tolgono prima le scadenze in più, poi gli impegni; con la cella troppo bassa tornano i segni (puntino degli impegni
  e delle scadenze). I segni dei riesami, delle attività e delle occasioni restano (50-b). I nomi brevi vengono da un
  dizionario in `ricavato` (`nomiBreviClienti`), non da `stato.cliente` per ogni pillola.
- **La colonna del giorno** (`colonnaGiornoMese`): 304 a 14 dalla griglia (`Misure.AgendaMese.larghezzaColonna`, fino a
  260 sotto la pagina minima), card piatta con padding 18 × 20. Occhiello «OGGI» in rosso o «NOVEMBRE 2026», titolo
  «lunedì 2 novembre», «{n} impegni · {n} scadenze · solo {nome}» o «nessun impegno»; le righe `RigaMeseUso` (filo del
  canale, fondo `chip`, raggio 4/10, ora in neretto larga 44, titolo in neretto, sotto il cliente o «Per te», «›»): il clic
  apre la scheda dell'impegno come prima; le scadenze con «Scade» in arancio aprono la posizione. Sotto, in piccolo, le
  attività rimaste indietro e del giorno (50-b); le occasioni restano nella vista «Occasioni». Vuoto: «Giornata
  libera{ per Marco}.» e «È un buon posto per un impegno nuovo.». «Apri il giorno» (primario) e «＋ Impegno»; la legenda
  con i quadratini dei due canali e il pallino arancio, e con un cliente scelto «Tutti i clienti» (`scegliCliente(nil)`).
  Un appuntamento aperto da ricerca o notifiche si vede ancora nella colonna (`vistaScelta`, con «‹ data»).
- Il cambio di giorno: la colonna entra da destra di 8 con l'opacità da 0,4 in 260 ms al ritmo (`EntrataGiornoMese`,
  `.id(giorno)`); con «Riduci movimento» la dissolvenza di 0,15 s; nelle istantanee già ferma.
- Prove A-U1…A-U7 in `ProvaCalcoliAgenda` (`--prova-calcoli`). Istantanee nuove 1152-uso-agenda-mese (chiara e scura),
  1153-uso-agenda-mese-cliente (Marco), 1154-uso-agenda-mese-giorno-libero; 12, 124, 132 e 238 mostrano già il mese nuovo.

Resta:
- **Altezza delle righe**: le righe della cella sono stimate a 18 punti per la Dimensione del testo (`rigaCella`); con il
  testo grande o una finestra 13" bassa guardare sul Mac che le pillole non vengano tagliate (la cella le ritaglia).
- **«Da fare» della miglioria 3** nella colonna: le attività restano le righe di sempre (`RigaRegistroAttivita`, con il
  loro rientro di 16), non ancora il «Da fare» unico.
- Il doppio clic con `onTapGesture(count: 2)` ritarda un poco il clic singolo (come nella settimana): da sentire sul Mac.
- `--prova-fluidita` con i 30 clienti fittizi sul mese: da guardare in CI che le celle non si rifacciano al passaggio
  del puntatore sulla colonna (la colonna sta in `ParteAgenda`, la griglia resta `Equatable`).
- Istantanee da rigenerare sul Mac e pagina delle anteprime da aggiornare; l'entrata della colonna e il passaggio del
  puntatore chiedono uno screenshot.

## 51. Il giro di domani si porta in tasca

Fatto (solo Mac, decisioni 51-a e 51-b come da proposta):
- **«La borsa» estratta** in `Motori/MotoreBorsa.swift`: incontri del giorno, fascicolo già nei Documenti, modelli di
  modulo compatibili, proposte con un incontro entro 7 giorni, moduli per cliente, documenti da rinnovare (senza
  richiesta già in Messaggi) e le cose di un incontro. `MotoreNotte` la usa al posto del suo codice (stesse carte: prova
  «Borsa» in `ProvaCalcoliNotte`, che confronta la carta della notte con il giro).
- **Nel giro**: «Da portare: …» (11,5, accento) sotto il motivo, da `stato.borsaGiro(giro)` in `ricavato` (giorno, tappe,
  giorni del documento e modelli nella chiave); senza cose nessuna riga. Nel giro il fascicolo conta solo se è già nei
  Documenti (la notte lo prepara, il giro non lo inventa).
- **La tappa** confermata con un cliente apre la preparazione dell'incontro (`apriIncontro(per:scheda: .preparazione)`,
  suggerimento «Prepara l'incontro», nessun incontro creato); quella da confermare apre l'Agenda come prima.
  «✓ Conferma in Agenda» è un collegamento; accanto «Togli» (`togliDalGiro`: elimina solo un appuntamento ancora
  `daConfermare`, avviso «{nome} tolto dal giro»).
- **Il pulsante in fondo** solo con «Prisma ovunque» acceso sul Mac: `mandaGiroAlliPhone` (in `StatoOvunque.swift`, fuori
  dai file del Territorio) chiama `sincronizzaOvunque()`; «✓ Il giro è sull'iPhone» quando `ovunque.giri` cresce dopo il
  tocco (stato in memoria per quel giorno, `territorio.giroIPhone`). Sotto: «Sull'iPhone lo trovi in Agenda. Tocca una
  tappa per prepararla.». Niente Mappe. Spento: la riga «Per averlo sull'iPhone accendi «Prisma ovunque» in
  Impostazioni.» con il collegamento a Impostazioni › iPhone e iPad. In dimostrazione un avviso, nessuna scrittura.
- **La crescita**: le tre date sotto il cursore (con almeno tre anni) e la tile «Hanno cominciato nel {anno}{ o prima}»
  con «**{n} famiglie**: nomi{ e un'altra / e altre n}» o «**Nessuna famiglia nuova**», che segue l'anno.
- Prove: `ProvaCalcoliTerritorio` (nomi dell'anno, «tolto dal giro», niente Mappe nel testo), `ProvaCalcoliNotte`
  (le due strade della borsa), `--prova-ovunque` (con lo spazio spento il pulsante non scrive nulla). Istantanee nuove
  1155-uso-territorio-giro-borsa (chiara e scura), 1156-uso-territorio-giro-iphone, 1157-uso-territorio-crescita-nomi;
  701-704 e 707 mostrano già le novità.

Resta:
- **Il puntatore a mano** sulle tappe toccabili: nel progetto non c'è un aiuto per il cursore; per ora il suggerimento
  «Prepara l'incontro» e il tratto di pulsante per VoiceOver.
- **«Il giro è sull'iPhone»** si basa sul contatore delle scritture riuscite: se una sincronizzazione era già in corso al
  tocco, la «✓» può arrivare con quella (che ha comunque già gli appuntamenti del giro). Una vista del giro sull'iPhone
  appartiene all'aggiornamento di iPhone e iPad (allora cambierà la frase sotto il pulsante).
- Nel giro la borsa non conta i fascicoli che la notte preparerebbe: solo quelli già nei Documenti.
- La data di mezzo sotto il cursore è centrata nella riga, non sotto la manopola dell'anno di mezzo con un numero pari di
  anni.
- Istantanee da rigenerare sul Mac e pagina delle anteprime da aggiornare; il tocco sulla tappa e il pulsante chiedono
  uno screenshot.

## 52. Lo Studio in ordine

Fatto: ordine Cruscotto · Parcelle · Spese | Track record | Esame OCF · Palestra, «OCF» torna «Esame OCF», i fili
(`separatoriPrima` di `SegmentatoPillola`, token `filo`, `marginiFilo`, `opacitaFilo`, `altezzaFilo`), prova in
`ProvaPalestraVera`, istantanee 1090 (chiara, scura, modalità cliente). Resta:
- Verificare nell'istantanea che l'altezza del filo (riga del carattere × 1,2 più il padding, meno 12) e la pillola che
  scivola sopra il filo siano come nel template; la finestra di Studio al minimo con la riga in testa più larga.
- Facoltativo: un segmentato con un filo nella vetrina «400-vetrina-apple».

## 53. Il cruscotto risponde a domande

Fatto (solo sul Mac, iPhone e iPad tengono titoli e didascalie di prima): i cinque titoli-domanda (`TestiStudio.domanda…`,
che si stringono un poco se non ci stanno), la riga degli incassi con le due etichette e «Il mese più ricco» / le cifre del
mese sotto il puntatore con i nomi dei canali scelti e la colonna schiarita (`Incassi.luceSopra`; lo stato del puntatore
sta nella card), la stima dichiarata nel fumetto del titolo e il pulsante delle aliquote quando mancano, «Il più
indietro» sotto gli anelli, la frase della dispersione senza nomi, l'asse «ricavi dell’anno ↑» e la mano su tutti i punti.
Motore: `Incassi.piuRicco`, `Obiettivi.piuIndietro`, `Obiettivi.mesiAllaFine`, `ValoreTempo.piuPesante`, con le prove in
`ProvaCalcoliStudio` (anche i testi). Istantanee nuove 1091 (mese sotto il puntatore, chiara e scura; obiettivi
raggiunti); 570, 571, 572 e 574 cambiano da sole. Resta:
- Guardare nelle istantanee 570 e 1091 che la card degli obiettivi (alta 300) tenga legenda con gli avvisi più la frase di
  due righe senza tagliare il fondo; se non ci sta, ridurre gli anelli o portare la frase su una riga sola.
- Provare a occhio `luceSopra` (0,06) chiara e scura, e le domande più lunghe alla larghezza minima della card con
  «dati di prova» accanto.
- «Il più indietro» nel mese di dicembre dice sempre «entro fine anno» (i mesi alla fine sono arrotondati per eccesso).
- `--prova-fluidita`: nessuna prova nuova che il passaggio sulle colonne non rifaccia i motori (lo stato è nella card,
  fuori dalla `ChiaveVista`).
