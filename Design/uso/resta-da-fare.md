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
ripiego). Prova in `--prova-calcoli` (`ProvaCalcoliPrioritaAree360`), istantanea nuova `1032-uso-dossier-bisogni` (chiara
e scura).

Resta:
- **Istantanee**: rigenerare sul Mac 440 (chiara e scura), 99, 300, 301 e la nuova 1032 e aggiornare la pagina delle
  anteprime; nella 1032 controllare che le capsule stiano accanto al collegamento senza andare a capo nella colonna
  accanto alla ruota.
- **Indice del dossier (miglioria 11)**: quando la sezione Bisogni passa nel tema Apple, la capsula e la nota vanno
  riprese da `BisogniCliente.prioritaVista` (oggi la scheda usa ancora i caratteri di Rubrica).
