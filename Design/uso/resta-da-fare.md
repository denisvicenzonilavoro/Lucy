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
