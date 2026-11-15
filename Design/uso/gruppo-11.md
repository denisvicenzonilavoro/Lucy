# Gruppo 11 — Le parti che «Luce» non disegnava, prima metà: cerca, documento, parole, app aperte, conferme (migliorie 61, 62, 66, 67, 68)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026). Le righe citate sono quelle della
copia senza immagini Design/uso/.template-senza-immagini.html (stesse righe del template). Commento in testa: righe
79-86; regole per chi implementa: righe 2881-2918; CSS del gruppo: righe 752-784; codice: righe 4819-4975 («66 ·»,
«61 ·», «62 ·», «67 ·», «68 ·»); pannello «✦ Migliorie»: `MIG11a`, righe 4978-4983. Le funzioni della base «Luce» che
queste migliorie estendono: `apriNotte`/`decidi` (2293-2316), `apriNota` (2526-2533), `apriMenu` (3098-3103),
`apriScheda` (3007-3010), `GLOSS`/`apriTermine`/`TM` (3278-3283), la barra (`#bApp` riga 846, `#bCerca` riga 850; nella
base `#bApp` non faceva niente: riga 2580).

Solo Mac. iPhone e iPad restano come sono: `RicercaSpotlight`, `DettaglioDocumento`, `Glossario`, `SpazioLavoro`,
`StatoNotte` e `NotaInArrivo` sono codice comune, quindi ogni cambiamento di comportamento va in file solo Mac o dentro
`#if os(macOS)`, e le istantanee di iPhone e iPad (che girano su main) devono restare uguali.

## Ordine consigliato

1. **68 · Si conferma allo stesso modo** (la parte comune): prima di tutto il componente delle conferme
   (`ConfermeApple.swift`: la riga verde o arancione, «Annulla»/«Rimetti», il pulsante unico che non è blu finché resta
   dell'arancione, la scossa del primo dubbio). Lo usano la 62 di questo gruppo e, fuori dal gruppo, la **43** (Inquadra
   e Nuovo cliente) e la **44** (Aggiorna valori: prima i dubbi) del gruppo 07, che oggi descrivono ognuna la sua riga
   «in arancione»: se il gruppo 07 è già fatto, quelle righe passano al componente comune; se no, lo usano da subito.
   Poi le due applicazioni della 68 (Stanotte e nota vocale). La frase «nel «Da fare» di oggi» di Stanotte presuppone la
   **3** del gruppo 01 (la riga «Arrivati» del «Da fare»): prima della 3 dice «restano qui per domani».
2. **62 · Il documento si apre in grande**: dopo la parte comune della 68 e dopo la **11** e la **12** del gruppo 02 (il
   dossier con l'indice e la riga in testa: la sezione Documenti da cui si apre il lettore) e la **35** del gruppo 05
   (Biblioteca: prima i documenti del cliente, stessi file). La **2** del gruppo 01 («un solo posto per il cliente»)
   decide di chi è il documento quando si apre dalla ricerca.
3. **66 · Le parole si spiegano dove sono**: indipendente, ma va fatta prima della 61 (la ricerca ha il gruppo «Parole»
   e la scheda «Apri il glossario») e dopo la **9** e la **10** del gruppo 01 (le parole dell'interfaccia sono quelle).
   Tocca le stesse viste di molte altre migliorie (frasi di Analisi 360, Posizioni, Prodotti): conviene farla quando
   quelle viste sono già al loro posto, per non segnare due volte le stesse frasi.
4. **61 · Cerca ovunque, e fa**: dopo la 66 e dopo, nel gruppo 01, la **2** (`clientiRecenti` per il pannello vuoto),
   la **1** (l'azione «Mostra al cliente»), la **3** (il «Da fare» al posto delle notifiche: esce l'azione «Centro
   notifiche») e la **6** («Cerca» tondo nella barra, via «Cerca ovunque» dalla scrivania). Le azioni «Inquadra un
   documento» e «Aggiorna i valori» aprono le schermate della 43 e della 44 (gruppo 07) come sono in quel momento;
   le note dei clienti trovate dalla ricerca sono quelle della **65** (gruppo 11, seconda metà) se è già fatta.
5. **67 · App aperte e spazi dal nome dell'app**: piccola e quasi indipendente; va dopo la **4** (una riga sola in testa)
   e la **1** del gruppo 01 (che toglie dalla barra l'icona della modalità cliente) e accanto alla **2** (la pillola del
   cliente nasce subito dopo quella dell'app: le due pillole vanno provate insieme).

**Cosa non si porta, per tutto il gruppo.** Il pannello «✦ Migliorie» (`MIG11a`), il cartellino `indica()` e i testi
«Prima…/Ora…» delle sue schede servono solo a presentare il template. Le cifre e i nomi del template sono dimostrativi:
i campi del documento di `lettDati` (riga 4923: «AL-2025-551203», «3.600 €», «eredi legittimi», le tre differenze
scritte a mano), le ricerche salvate di `CERCA_SALV` con i loro risultati fissi (riga 4866: «scade tra 15 giorni»), la
nota di Giulia con le sue quattro voci (riga 2531) e la scelta della quarta riga come «dubbio» (riga 4970: `i===3`), gli
spazi di `SPAZI` come elenco fisso. Le cifre le danno i motori di Prisma, i nomi l'archivio, i dubbi le regole.

---

## 61. Cerca ovunque, e fa

### 61.1 Nel template

Righe 4861-4912; CSS 756-767; regola a riga 2881-2884 (istantanee da rifare indicate dalla regola: 53, 54, 103, 104).
Si apre con la lente tonda della barra `#bCerca` (riga 850, aiuto «Cerca · ⌘K») o con ⌘K da qualsiasi punto (riga
4912); ⌘K e un secondo tocco sulla lente la richiudono. Non si apre nella vista del cliente (`if(pulita)return`, riga
4902); aprendosi chiude novità, «Da fare», scelta del cliente, menu e la scheda delle parole. **Ogni apertura parte
pulita**: campo vuoto, filtri su «Tutto» e nessun canale, prima riga scelta (`cercaF={tipo:null,ch:null}`, riga 4902).

**La scatola** (`apriCerca`, righe 4902-4909): velo sfocato su tutta la finestra (`#cerca`, scrim e sfocatura 8);
scatola larga 900 a 84 punti dall'alto, raggio 26, fondo `--pop`, filo `--glassE`, ombra grande, padding 14×16×10.
Entra in 380 ms (da 14 punti più su e scala 0,97, molla) col velo in 200 ms; con «Riduci movimento» compare ferma.
Dall'alto:
- **Il campo**: lente 22, campo 19 con il testo d'invito **«Cerca un cliente, una posizione, un documento… o scrivi
  cosa vuoi fare»**, a destra il pulsante «esc» (chiude). Il fuoco va subito nel campo; una lettera scritta altrove
  mentre la scatola è aperta torna nel campo.
- **I filtri** (`#ceF`, riga 4887), etichette da toccare: «Tutto», «Clienti», «Posizioni», «Documenti», un filetto
  verticale, poi i due canali con il loro pallino colorato («Alleanza», «Indipendente», dai nomi dei canali). Il tipo è
  una scelta sola (Tutto è il predefinito); il canale si accende e si spegne con un secondo tocco. A destra, solo con
  del testo scritto, il link **«Salva questa ricerca»**.
- **Il corpo**, due colonne alte 392: a sinistra l'elenco (420), a destra l'anteprima.
- **Il piede**, sopra un filo, testo 12 secondario: «↑ ↓ per scegliere», «Invio per aprire», «Esc per chiudere» e, in
  fondo a destra, **«Cerca solo su questo Mac»**.

**Campo vuoto** (righe 4888-4890): a sinistra «Clienti recenti» (avatar 30, nome, motto) e «Azioni» (tessera «+» 30,
titolo, riga): **Nuovo cliente** («Dal documento, o scrivendo i dati»), **Nuovo impegno** («In Agenda»), **Aggiorna i
valori** («Dall’elenco della compagnia»), **Mostra al cliente** («Scegli cosa mostrare»), **Inquadra un documento**
(«Con l’iPhone») (`CERCA_AZ`, riga 4865). A destra «Ricerche salvate» (tessera con la lente, nome) e sotto: «Scrivi un
nome, un prodotto o una parola. Oppure quello che vuoi fare: «nuovo cliente», «aggiorna».»

**Scrivendo** (`cercaTrova`, righe 4869-4874; `cercaDisegna`, 4891-4893): i risultati per gruppi, nell'ordine
**Clienti** (nome, motto, professione), **Posizioni** (in essere e proposte: «<cliente> · in essere» / «· proposta»),
**Documenti** (del cliente: «<cliente> · <pagine>»; della Biblioteca: «Biblioteca · <tipo> · N pagine»), **Azioni**,
**App** («Apri l’app»), **Parole** (termine e definizione). Azioni, App e Parole compaiono solo senza filtri. Al più 40
risultati. Ogni riga: avatar 30 o tessera 30 (raggio 10, fondo `chip`) col glifo del tipo, titolo 14 e riga 12,5
troncati; la riga scelta ha il fondo blu al 12% (anche al passaggio del mouse, che sposta la scelta). La prima riga è
scelta all'inizio.

**Nessun risultato** (riga 4893): «**Nessun risultato per «<testo>».**», «Prova con una parte del nome, o togli un
filtro.» e il pulsante **«Chiedilo a Vera»** (chiude, apre Vera e le passa il testo).

**L'anteprima** (`cercaAnteprima`, righe 4880-4885), con i pulsanti per agire (il primo è blu):
- Cliente: avatar 48, nome 20 bold, motto; righe «Patrimonio netto», «Prossimo incontro» («non fissato»), «Da fare»
  («N aperti» / «niente»); pulsanti **«Apri il dossier»**, **«Posizioni»**, **«Mostra al cliente»**.
- Posizione: occhiello «Proposta» / «Posizione in essere», nome 20, «<cliente> · <area>»; «Versamento l’anno» o
  «Valore», «Canale» (con l'etichetta del canale); **«Apri la scheda»**.
- Documento: occhiello «Documento», titolo 19, riga; **«Apri il documento»** (apre il lettore della 62 sulla sezione
  Documenti del cliente, o la Biblioteca sul documento).
- Parola: occhiello azzurro «Le parole», termine, definizione 14,5; **«Apri il glossario»** (sulla parola).
- Azione e app: occhiello del gruppo, titolo, riga; **«Fai»** / **«Apri»**.

**Tasti** (righe 4901, 4912): ↑ ↓ scelgono (in giro, l'elenco scorre per tenere la scelta in vista), Invio apre la
scelta, Esc chiude. Aprire una riga chiude sempre la scatola. Un clic sul velo chiude.

**Salvare una ricerca** (riga 4897): un tocco su «Salva questa ricerca» salva subito, senza chiedere un nome: il nome è
il testo scritto, i filtri accesi si ricordano, una ricerca con lo stesso nome non si salva due volte; avviso «Ricerca
salvata: la ritrovi aprendo «Cerca»». Una ricerca salvata si riapre con un tocco a campo vuoto: il suo nome va nel
campo e sotto compaiono i risultati con i filtri di quando è stata salvata; scrivendo di nuovo si torna alla ricerca
normale (riga 4906: `oninput` azzera i risultati).

### 61.2 Nell'app oggi

La ricerca c'è già, ed è ricca: manca soprattutto la faccia «da toccare» del template.
- `Shell/RicercaSpotlight.swift`: `StatoSpotlight` (:15, testo, esito, suggerimenti, selezione, nome da salvare),
  `TastiSpotlight` (:72, frecce, Invio, Tab, Esc dal monitor di AppKit), `RicercaSpotlight` (:105). Il pannello
  (`pannello`, :223): `campo` (:238, invito **«Clienti, posizioni, app… o un filtro come scade:2027»**, a destra la ✕
  che cancella il testo), `striscia` (:263: i suggerimenti dei filtri scritti, i filtri riconosciuti e i totali per
  canale), `corpo` (:295: elenco 330 e anteprima; senza risultati «Nessun risultato. Prova con meno parole o con una
  parte del nome.» o «Completa il filtro: per esempio scade:2027, sri>4, canale:alleanza, stato:proposta.»), `vuoto`
  (:348: «Ricerche salvate» e **«Cerca per criterio»** con i codici `FiltriRicerca.chiavi`), `pie` (:471: i tasti,
  «Salva ricerca» che apre nel piede il campo «Salva come» per il nome, proposto da `nomeProposto`).
  `AnteprimaRicerca` (:834), `SchedeRicerca.scheda` (:671: cifre e azioni per ogni tipo; cliente: cifre «In essere», i
  totali per canale, «Debiti», «Proposte aperte», «Prossimo incontro» solo se c'è, «Attività aperte» solo se ce ne
  sono; azioni «Apri il dossier», «Resoconto», «Fissa un appuntamento», «Crea un'attività»), `AzioneAnteprima` (:644).
  Lo stesso pannello è anche quello stretto dell'iPhone (`compatto`, sotto `sogliaAnteprima` 600).
- Il testo resta fra un'apertura e l'altra: `RicercaSpotlight` lo rilegge da `stato.testoRicerca` (StatoShell.swift:357)
  all'apertura e lo riscrive alla chiusura. Chi apre la ricerca con un testo già scritto lo usa: le notifiche di
  conformità con più clienti (`apriNotifica`, Notifiche.swift:510: «conformita:scaduta», «conformita:inscadenza»),
  le istantanee (Istantanee.swift:435, 614, 862…) e quella della Biblioteca (IstantaneeBiblioteca.swift:88).
- C'è anche `AppRicerca` (Shell/AppRicerca.swift, la vecchia finestra «Ricerca», raggiungibile solo da finestre di
  archivi di prima: `apriApp(.ricerca)` porta al pannello), che usa lo stesso `MotoreRicerca`.
- `Shell/Ricerca.swift`: `GruppoRicerca` (:7: app, clienti, posizioni, documenti, note, appuntamenti, attività,
  obiettivi, incontri, prodotti, biblioteca, azioni; **niente parole**), `AzioneRicerca` (:51: nuovo appuntamento,
  nuova attività, nuova nota, crea backup, **modalità cliente**, **spazi di lavoro**, **le tue app aperte**, **centro
  notifiche**, mostra la scrivania), `MotoreRicerca.cercaCompleta` (:345) con l'indice dei testi
  (`IndiceTestiRicerca.swift`) e le pagine della Biblioteca.
- `Shell/FiltriRicerca.swift`: i filtri scritti (`scade:`, `sri>`, `canale:`, `costo>`, `beneficiari:vuoti`, `senza:`,
  `riesame:dovuto`, `stato:`, `area:`, `conformita:scaduta`), `FiltriRicerca.chiavi` (:174), `interpreta`, `completa`.
- `Dati/RicercaSalvata.swift`: `RicercaSalvata` (nome, testo) in `Impostazioni.ricercheSalvate` (già nell'archivio e
  nei backup); `StatoShell.salvaRicerca`/`eliminaRicerca`.
- Componenti in `DesignSystem/ComponentiRicerca.swift` (`RigaRicerca`, `RigaSpotlight`, `IconaRisultatoRicerca`,
  `TesseraAzioneRicerca`, `CifraAnteprimaRicerca`, `TotaleCanaleSpotlight` con il pallino colorato
  `Tema.Apple.AltreApp.canale(c)`), misure in `DesignSystem/MisureSpotlight.swift` (`Misure.Spotlight`: larghezza 760,
  colonna 330, distanza dall'alto 15% con minimo barra + 16), token del tema già esistenti in
  `DesignSystem/Apple/AltreAppApple.swift:181` (`Tema.Apple.AltreApp.Ricerca`: superficie, **raggio 22**, selezione,
  caratteri del campo 20, del gruppo, della voce 13,5 e della riga 12).
- Si apre con `StatoShell.cercaOvunque()`/`alternaRicerca()`; aperto e chiuso in `StatoFinestre.pannelloRicerca`
  (:42); si chiude entrando in modalità cliente (RicercaSpotlight.swift:171). Pulsante «Cerca ⌘K» nella barra
  (BarraSuperiore.swift:136-146; la miglioria 6 lo fa tondo).
- **Manca**: i filtri come etichette (oggi sono codici da scrivere), il pannello vuoto con «Clienti recenti» e
  «Azioni» (oggi «Cerca per criterio» con i codici), il gruppo «Parole», «Chiedilo a Vera» senza risultati, «Cerca solo
  su questo Mac», le azioni del template («Nuovo cliente», «Aggiorna i valori», «Mostra al cliente», «Inquadra un
  documento»), «Posizioni» e «Mostra al cliente» nell'anteprima del cliente, «Salva questa ricerca» in alto, il pulsante
  «esc» nel campo, l'apertura pulita (oggi riparte dal testo di prima).

### 61.3 Cosa fare

1. **Filtri da toccare** (solo Mac). In `StatoSpotlight` due campi in memoria: `tipo: GruppoRicerca?` (nil = Tutto;
   ammessi `.clienti`, `.posizioni`, `.documenti`) e `canale: Canale?`. `MotoreRicerca.cercaCompleta` riceve un
   parametro nuovo `limiti: LimitiRicerca` (tipo e canale; predefinito vuoto, così iPhone e iPad non cambiano) e tiene
   solo i gruppi ammessi: con un tipo, solo quel gruppo (i Documenti comprendono la Biblioteca, come nel template); con
   un canale, solo clienti con quel canale, posizioni e documenti di quel canale; Azioni, App e Parole solo senza
   filtri. Il canale si applica con lo stesso codice di `FiltroRicerca.canale` (nessun motore nuovo); i gruppi senza
   canale (note, appuntamenti, attività, obiettivi, incontri) con un canale acceso non compaiono, come nel template. La
   fila `FiltriSpotlight` (nuovo, in RicercaSpotlight.swift o in un file solo Mac `RicercaSpotlightMac.swift`) sostituisce
   la `striscia` sul Mac: «Tutto», «Clienti», «Posizioni», «Documenti», filetto, i due canali con il pallino colorato
   (`Tema.Apple.AltreApp.canale(c)`, come `TotaleCanaleSpotlight`: un componente `PallinoCanale` oggi non esiste) e
   `Canale.nomeBreve` (i nomi della miglioria 38 se è fatta), a destra, solo con del testo scritto, «Salva questa
   ricerca» (collegamento). Il tipo è una scelta sola; il canale si spegne con un secondo tocco. Componente
   `EtichettaFiltroRicerca` in `ComponentiRicerca.swift` (acceso: fondo accento al 14%, testo accento; spento: fondo
   `chip`). Toccare un filtro rifà la ricerca e rimette la scelta sulla prima riga; il fuoco resta nel campo.
2. **I codici restano, nascosti.** I filtri scritti (`sri>3 canale:alleanza`) continuano a funzionare (le ricerche
   salvate di oggi li usano, `--prova-vera` e la Biblioteca pure), ma non si mostrano più: via l'invito con
   «scade:2027», via «Cerca per criterio», via i suggerimenti con Tab dalla fila in alto (restano i filtri riconosciuti
   come pillole solo quando l'utente ne scrive uno, o quando la ricerca arriva già scritta da una notifica di
   conformità: «conformita:scaduta» deve restare leggibile come pillola «Conformità scaduta»). Nuovo invito: «Cerca un
   cliente, una posizione, un documento… o scrivi cosa vuoi fare». A destra del campo il pulsante piccolo «esc» (chiude,
   come Esc); la ✕ di oggi che cancella il testo resta accanto finché c'è del testo.
   **Apertura pulita** (solo Mac): aperta dalla lente, da ⌘K o dal menu «Vai» la ricerca parte vuota, su «Tutto»
   (`testoRicerca = ""` in `alternaRicerca()` quando apre, Ricerca.swift:634: la chiamano la barra, ⌘K e il menu
   «Vai»; **non** in `cercaOvunque()`, che `apriNotifica` chiama dopo aver scritto il filtro). Chi la apre con un testo
   apposta (notifiche, istantanee, Biblioteca) lo trova come oggi. iPhone e iPad restano come sono.
3. **Pannello vuoto** (`vuoto`, sul Mac): due colonne come il template. A sinistra «Clienti recenti» (gli ultimi tre
   da `stato.clientiRecenti` della miglioria 2; finché la 2 non c'è, i tre clienti con l'ultima modifica, dal
   `CacheClienti`) con `AvatarCliente` 30, nome e motto; poi «Azioni». A destra «Ricerche salvate» (quelle di oggi, con
   la ✕ per toglierle) e la frase «Scrivi un nome, un prodotto o una parola. Oppure quello che vuoi fare: «nuovo
   cliente», «aggiorna».». Le «Azioni» del pannello vuoto sono **solo le cinque del template** (Nuovo cliente, Nuovo
   impegno, Aggiorna i valori, Mostra al cliente, Inquadra un documento); le altre si trovano scrivendo. Frecce e Invio
   funzionano anche qui (le righe del pannello vuoto entrano in `elenco`). I recenti e le cinque azioni sono letti, non
   calcolati: niente scorrimento dell'archivio nel body.
4. **Le azioni** (`AzioneRicerca`, codice comune: si aggiungono casi, gli altri restano per iPhone e iPad): sul Mac
   l'elenco mostrato diventa `nuovoCliente` («Nuovo cliente», «Dal documento, o scrivendo i dati»:
   `stato.apriNuovoCliente()`, NuovoClienteShell.swift:18), `nuovoAppuntamento` con il titolo «Nuovo impegno» («In
   Agenda»; sul Mac apre il modulo dell'appuntamento come oggi, `conModulo`), `aggiornaValori` («Aggiorna i valori»,
   «Dall’elenco della compagnia»: `stato.apriAggiornaValori()`, StatoAggiornaValori.swift:11), `mostraAlCliente`
   («Mostra al cliente», «Scegli cosa mostrare»: il pannello della miglioria 1; prima di quella, `entraModoCliente`),
   `inquadra` («Inquadra un documento», «Con l’iPhone»: `stato.apriInquadra()`, StatoInquadra.swift:232), poi quelle di
   oggi che servono ancora (nuova attività, nuova nota, crea backup,
   mostra la scrivania). Escono sul Mac: «Modalità cliente» (diventa «Mostra al cliente»), «Spazi di lavoro» e «Le tue
   app aperte» (sono nel menu della 67), «Centro notifiche» (con la miglioria 3 è il «Da fare»: azione «Da fare» se la
   3 è fatta). Le parole chiave (`parole`) restano, così «aggiorna», «nuovo cliente» trovano le azioni.
5. **Il gruppo «Parole»**: `GruppoRicerca.parole` e `DestinazioneRicerca.parola(VoceGlossario.Chiave)`; i candidati da
   `Glossario.voci` (termine e per esteso nel titolo, `breve` nel dettaglio), solo senza filtri. Ordine dei gruppi sul
   Mac: Clienti, Posizioni, Documenti, Note, Appuntamenti, Attività, Obiettivi, Incontri, Prodotti, Biblioteca, Azioni,
   App, Parole (quelli del template prima, gli altri dove sono oggi). Anteprima: occhiello «Le parole», termine,
   `breve`, pulsante «Apri il glossario» (`stato.apriGuida(.glossario(chiave))`).
6. **L'anteprima del cliente**: avatar 48, nome, motto (o tema · professione come oggi); le righe diventano quelle del
   template, sul Mac: «Patrimonio netto» (la cifra del riepilogo del cliente che già c'è, `RiepilogoPosizioni.patrimonioNetto`,
   Motori/Riepilogo.swift:8, presa da `CacheClienti` che tiene già il `riepilogo` per cliente, non ricalcolata), «Prossimo incontro» (sempre, con «non
   fissato» se non c'è), «Da fare» («N aperti» / «niente»: le voci del «Da fare» di quel cliente se la miglioria 3 è
   fatta, altrimenti le attività aperte di oggi). I totali per canale, i debiti e le proposte aperte escono
   dall'anteprima sul Mac (sono nel dossier); iPhone e iPad tengono le cifre di oggi. Oggi `SchedeRicerca.scheda` filtra
   `dati.posizioni` e `dati.attivita` a ogni scelta: le righe nuove si leggono dalle cache per cliente, non dal body.
   I pulsanti diventano «Apri il dossier» (blu), «Posizioni» (Posizioni con quel cliente scelto, `scegliCliente` della
   miglioria 2, che oggi non esiste: prima, `clienteAttivoId` e `apri(.posizioni)` come fa oggi `.cliente(id)`) e
   «Mostra al cliente» (lo sceglie e apre il pannello della miglioria 1). «Resoconto», «Fissa un appuntamento» e «Crea un'attività» passano nel
   menu «⋯» dell'anteprima (non spariscono). Posizione: primo pulsante «Apri la scheda». Documento: «Apri il
   documento» apre il lettore della 62.
7. **Nessun risultato**: «Nessun risultato per «<testo>».», «Prova con una parte del nome, o togli un filtro.» e il
   pulsante «Chiedilo a Vera»: chiude, apre Vera e chiama `stato.chiediVera(testo)` (Vera è Qwen sul Mac: nessun dato
   esce). Con un filtro scritto incompleto resta il messaggio di oggi. In modalità cliente la ricerca non si apre
   (come oggi), quindi «Chiedilo a Vera» non può portare dati di altri clienti davanti al cliente.
8. **Piede**: i tre tasti di oggi (senza «Tab per completare» sul Mac) e a destra «Cerca solo su questo Mac» (testo,
   non un pulsante). «Salva ricerca» sale in alto (punto 1) e, come nel template, **salva subito** senza il campo «Salva
   come» nel piede: nome = il testo scritto (o `nomeProposto` se il testo è fatto solo di codici), niente doppioni con
   lo stesso nome, avviso «Ricerca salvata: la ritrovi aprendo «Cerca»» (`stato.salvaRicerca`, che c'è già). Una
   ricerca salvata con i filtri da toccare li scrive nel suo `testo` come codici (`canale:alleanza`, e un codice nuovo
   `tipo:clienti|posizioni|documenti` in `FiltriRicerca`), così `RicercaSalvata` non cambia forma. **Riaprendola** dal
   pannello vuoto, i codici `tipo:` e `canale:` tornano etichette accese (non restano scritti nel campo); nel campo va
   il resto del testo e gli altri codici restano pillole riconosciute, come al punto 2.
9. **Misure**: la scatola passa a 900 (oggi 760), la colonna dell'elenco a 420 (oggi 330), raggio 26 (oggi 22),
   distanza dall'alto 84 (oggi il 15% dell'altezza, al minimo barra + 16), corpo alto 392 (oggi cresce fra 360 e 470
   con i risultati). I token **non** vanno in un enum nuovo `Tema.Apple.Ricerca` (si confonderebbe con quello che c'è):
   si estende `Tema.Apple.AltreApp.Ricerca` (AltreAppApple.swift:181) con un blocco del Mac (`enum Mac` o costanti
   `…Mac`): `larghezza` 900, `colonnaElenco` 420, `raggio` 26, `distanzaAlto` 84, `altezzaCorpo` 392,
   `etichettaFiltro` (padding 5×11, raggio capsula), `fondoFiltroAcceso` (accento al 14%), `filettoFiltri` (1×18),
   `avatarRecente` 30, `avatarAnteprima` 48, `carattereCampoMac` 19, `velo` (scrim e sfocatura 8 del template, con il
   ripiego senza sfocatura delle istantanee). `Misure.Spotlight` e il raggio 22 restano per iPhone e iPad (il pannello
   stretto non cambia).

**Non fare**: non togliere i filtri scritti (le ricerche salvate e la Biblioteca li usano); non portare le ricerche
salvate dimostrative del template («Polizze in scadenza entro 90 giorni», «Clienti con poca protezione») come voci
fisse con risultati scritti a mano (vedi 61.6); non cercare dentro i testi dei documenti in un `body` (l'indice c'è già
ed è fuori dal body); non aprire la ricerca in modalità cliente.

### 61.4 Dati, archivio, privacy

Nessun campo nuovo. Le ricerche salvate stanno già in `Impostazioni.ricercheSalvate` (archivio, backup, non in «Prisma
ovunque» come oggi); il codice nuovo `tipo:` sta dentro il loro testo. I clienti recenti sono in memoria (miglioria 2).
«Cerca solo su questo Mac» dice il vero: la ricerca non usa la rete; «Chiedilo a Vera» passa il testo a Qwen su
127.0.0.1.

### 61.5 Istantanee e prove

- Da aggiornare: «53-ricerca» (e «53-ricerca-scuro»), «54-ricerca-documento», «103-ricerca-filtri» (oggi con
  `sri>3 canale:alleanza`: diventa la fila con «Posizioni» e «Alleanza» accesi; il testo scritto resta per provare che
  i codici funzionano), «104-ricerca-salvate» (pannello vuoto a due colonne), «154-ricerca-conformita»,
  «879-biblioteca-cerca-ovunque».
- Nuove: «1300-uso-ricerca-vuota» (clienti recenti, azioni, ricerche salvate; chiara e scura), «1301-uso-ricerca-mar»
  (il testo «mar» come nel template: clienti, posizioni, documenti, parole), «1302-uso-ricerca-nessun-risultato»
  («Chiedilo a Vera»), «1303-uso-ricerca-parola» (anteprima di una parola).
- Prove: in `--prova-vera` (ProvaVera.swift usa già `MotoreRicerca`) o in `--prova-calcoli`: i limiti di tipo e canale
  (con «Clienti» niente posizioni; con «Indipendente» nessuna posizione Alleanza), il gruppo Parole («sri» trova la voce
  SRI, non con un filtro acceso), il codice `tipo:` letto da `FiltriRicerca.interpreta`, le azioni nuove trovate da
  «aggiorna» e «nuovo cliente», la ricerca salvata con `tipo:`/`canale:` che riaperta riaccende le etichette, la
  notifica di conformità che apre la ricerca con «conformita:scaduta» (il testo resta, l'apertura pulita non lo
  cancella). `--prova-carico` e `--prova-fluidita` (ProvaCarico.swift e ProvaFluidita.swift aprono
  la ricerca): controllare che i tempi non peggiorino con i 30 clienti di prova.

### 61.6 Decisioni per l'utente e rischi

- **I filtri scritti spariscono dalla vista**: proposta, sì come il template (restano capiti se scritti, e nelle
  ricerche salvate). In alternativa «Cerca per criterio» resta in fondo al pannello vuoto, chiuso di base.
- **Le ricerche salvate di partenza**: il template ne mostra due, dimostrative. Proposta: si parte come oggi, con le
  ricerche salvate dall'utente e nessuna voce fissa (la miglioria non aggiunge funzioni). In alternativa, al primo
  avvio due ricerche salvate vere: «Polizze in scadenza entro 90 giorni» richiede un filtro relativo `scade:90g` che oggi
  non c'è (`FiltroRicerca.scade` ha solo anno e mese) e «Clienti con poca protezione» un filtro nuovo `protezione<40` dal
  motore di Analisi 360: due filtri in più da provare.
- **Cosa resta di «Resoconto», «Fissa un appuntamento», «Crea un'attività»** nell'anteprima del cliente: proposta, nel
  menu «⋯».
- **Le righe dell'anteprima del cliente**: proposta, le tre del template (Patrimonio netto, Prossimo incontro, Da fare)
  al posto delle cifre di oggi (In essere, totali per canale, debiti, proposte aperte); il canale resta riconoscibile
  nelle righe delle posizioni.
- **Salvare senza chiedere il nome**: proposta, come il template (un tocco, il nome è il testo); in alternativa resta il campo
  «Salva come» di oggi nel piede.
- **Rischi**: `RicercaSpotlight` e `MotoreRicerca` sono comuni con iPhone e iPad (il pannello stretto): i parametri nuovi
  hanno valori predefiniti che lasciano tutto com'è, la fila dei filtri e il pannello vuoto nuovo sono solo Mac.
  Allargare la scatola a 900 su una finestra stretta: resta la regola di oggi (`min(larghezza, finestra − 2·margine)`),
  e sotto `sogliaAnteprima` resta il pannello stretto. Il pannello vuoto non deve calcolare niente sull'archivio nel body
  (recenti dalla miglioria 2, azioni fisse). L'apertura pulita non deve rompere le notifiche di conformità che aprono la
  ricerca con il filtro scritto (Notifiche.swift:510): azzerare il testo solo in `alternaRicerca()`. `AppRicerca` (la
  finestra di prima) non cambia: riceve i parametri predefiniti.

### 61.7 Dimensione

**M** (circa 450 righe). File: Shell/RicercaSpotlight.swift (o Shell/RicercaSpotlightMac.swift nuovo), Shell/Ricerca.swift,
Shell/FiltriRicerca.swift, DesignSystem/ComponentiRicerca.swift, DesignSystem/Apple/AltreAppApple.swift (i token del Mac
in `Tema.Apple.AltreApp.Ricerca`), Istantanee.swift.

---

## 62. Il documento si apre in grande

### 62.1 Nel template

Righe 4914-4949; CSS 768-781; regola a riga 2885-2889. Si apre toccando un documento nella sezione Documenti del
dossier (prima un avviso diceva «Il documento si apre come oggi, con «Dati», «Confronto» e «Testo»», riga 4921) e
dall'anteprima della ricerca (61). Pannello: `MIG11a[1]` (Marco, secondo documento).

**La scheda** (`apriLettore`, riga 4941): una scheda grande al centro, sopra tutto Prisma (`apriScheda` larga, righe
3007-3010 e CSS 441-442: 1220×790 al più, raggio 28, fondo `--pop`, velo sfocato 10 su tutto; entrata dal basso di 18
punti e scala 0,97 in 0,48 s, velo in 0,26 s; ✕ in alto a destra; un clic sul velo chiude). Non c'è più l'intestazione del dossier sopra
il documento: il documento prende tutto lo spazio. Due colonne, alte 660, spazio 22 (`lettHTML`, righe 4929-4940):

- **A sinistra la pagina** (`.leCarta`, larga 470, fondo `chip`, raggio 20): il foglio bianco (sempre chiaro) in scala
  0,74 con l'intestazione della compagnia, il titolo, le righe dei campi letti; in basso al centro la capsula
  «pagina 1 · <data>». **Passando su un dato a destra, la sua riga sulla pagina si accende in giallo** (`.leL.su`,
  giallo al 40%, riga 4945).
- **A destra i tre passi**: occhiello azzurro «Documento di <Nome> · <gruppo>», titolo 24 (nome del documento), sotto
  la data e l'etichetta del canale. Poi, in una colonna che scorre (`#leCorpo`):
  1. **«I dati letti»** (numero tondo 20 nell'accento, titolo 15, a destra la capsula «N da controllare» arancione o «a
     posto» verde). **Prima i dati da controllare**: riga con fondo arancio al 10% (`.leR.dub`), «?» arancio, nome del
     campo (150), il valore **correggibile sul posto** (Invio conferma) e sotto, in arancio 12,5, il perché («La cifra è
     vicino a una piega del foglio: controlla.», «In queste pagine non c’è la parte sui beneficiari.»), a destra il
     pulsante piccolo **«Va bene»**. Premuto, la riga diventa «✓» verde col valore scritto in quel momento (la
     correzione e la conferma sono un gesto solo; riaprendo il documento il valore corretto resta, riga 4949). **Poi gli altri in una riga
     sola**: «✓ **N dati letti con certezza**» e a destra «Mostra» (con tre o meno si mostrano tutti); «Mostra» li apre
     uno per riga.
  2. **«A cosa è collegato»** (capsula «a posto»): «✓ Alla posizione «<nome>» di <Nome>» (o «Al dossier di <Nome>» per
     la carta d'identità) e, con una posizione, il link «Cambia» («Si sceglie un’altra posizione dello stesso cliente»).
  3. **«Cosa non torna»** (solo se ci sono differenze; capsula «N da decidere» / «deciso»): per ogni differenza un
     riquadro arancio (`.leD`) con il nome della voce, la spiegazione in grigio e **due riquadri da toccare**: «Nel
     documento» <valore> e «Nella posizione» <valore>. Toccato, quello scelto ha il bordo verde e il fondo verde al
     10%, il riquadro diventa normale. Sotto: «Tocca il valore giusto: l’altro viene corretto.»
- **Il piede** (sopra un filo): **un pulsante solo**, grande, che cambia: «Controlla il dato in arancione» / «Controlla
  i N dati in arancione» → «Decidi la differenza» / «Decidi le N differenze» → **«Fatto: salva nel dossier»** (blu solo
  ora) → «Chiudi» se era già salvato. Accanto «Chiedi a Vera» (avviso «Vera risponde solo con il testo di questo
  documento, citando la pagina»). A destra: «I dati entrano nel dossier solo quando lo dici tu» o «Già salvato nel
  dossier».
- **Premendo il pulsante con dell'arancione** (riga 4946): il primo dato o la prima differenza da decidere scorre in
  vista e trema (300 ms, niente con «Riduci movimento»), avviso «Prima controlla i dati in arancione» / «Prima scegli il
  valore giusto per ogni differenza». **A posto**: la scheda si chiude e l'avviso «<documento> salvato nel dossier di
  <Nome>»; il documento non è più «da leggere» né «con differenze» nell'elenco (riga 4920).
- «Conferma tutti» sparisce; «Dati / Confronto / Testo» non sono più tre schede ma i tre passi (regola 62).

### 62.2 Nell'app oggi

- `Shell/DettaglioDocumento.swift`: `DettaglioDocumento` (:10). Il foglio (`AnteprimaDocumento`, :108) a tutta altezza,
  sopra una barra compatta (titolo, stato e canale `filaStato`, l'azione che vale `azionePrincipaleVista`, «Apri con
  Vera», menu «⋯», pulsante «Dati»); accanto o in un cassetto il pannello con **tre schede** «Dati», «Confronto» (solo
  per KID, polizze, identità e questionari), «Testo» (`opzioniSchede`, :35; `colonnaScheda`). Il banner in testa ai dati
  (`banner`, :752) ha, con dati da controllare, **«Conferma tutti»** (:770, `StatoShell.confermaTutti`,
  StatoDocumenti.swift:148). Ogni dato si conferma col cerchio (`StatoShell.confermaCampo`, StatoShell.swift:1443) e si
  corregge col doppio clic; la fonte «p. N» porta la pagina e illumina la riga (`mostraFonte`, :87:
  `vistaDocumenti.pagina` e `vistaDocumenti.evidenzia`). L'azione principale (`AzionePrincipale`, :511: «Rileggi»,
  «Vedi cosa non torna (N)», «Aggiorna il valore», «Collega a «…»», «Crea …», «Conferma i N dati»).
- Il confronto: `Shell/ConfrontoDossierVista.swift` (`ConfrontoDossierVista`, :8: tabella «Nel documento / In
  Prisma», scelte delle voci da tenere, aggiornamento con lo storico, impatto di un KID) e
  `Shell/StatoConfrontoDossier.swift` (`collegaDocumento` :87, `alternaVociTenute` :111, `aggiornaDalDocumento` :129,
  `ripristina` :165, `candidateCollegamento` :57, `suggerimentoCollegamento` :75).
- Dove si apre: nel dossier, `Shell/ClienteDocumenti.swift:186` (`dettaglio`) accanto all'elenco, **dentro** la
  finestra del dossier, sotto l'intestazione del cliente e le sue schede; nell'app Documenti, AppDocumenti.swift:79.
  Il dossier ha **già** un presentatore del dettaglio del tema (`DossierObiettivi.swift:635`:
  `.presentatoreDettaglio(dettaglio) { DettaglioDossierApple(id:) }`, con la richiesta delle istantanee
  `RichiestaIstantaneaDossier`): è il «dettaglio che nasce dalla scheda toccata» di CLAUDE.md
  (DesignSystem/Apple/DettaglioApple.swift: velo, misura W×H chiesta all'apertura, ✕, Esc e clic sul velo chiudono,
  «Riduci movimento» e istantanee già gestiti).
- La riga accesa sul foglio: `AnteprimaDocumento` legge `stato.vistaDocumenti.evidenzia` (AnteprimaDocumento.swift:97)
  e la disegna nel foglio ricostruito (`PaginaTestoDocumento`) o come selezione nel PDF (`VistaPDF`, :401-416, che
  cerca il testo dell'estratto nella pagina), in **azzurro** (`Tema.Colore.Documenti.evidenziaFoglio` 16% ed
  `evidenziaPDF` 28%, TemaAppDocumenti.swift:158, 173). Le pagine da scansione senza testo non si possono accendere.
- Un documento può essere collegato a più posizioni o schede (`StatoConfrontoDossier.bersagli`, :12): oggi il
  confronto si sceglie per bersaglio.
- I dati: `CampoEstratto` (Dati/Documento.swift:344: chiave, valore, pagina, estratto, origine, `confermato`). **Non
  c'è** una distinzione fra dati certi e incerti: ogni dato non confermato conta come «da controllare»
  (`MotoreDocumenti.Indicatori.daControllare`, MotoreDocumenti.swift:76).
- **Manca**: il lettore a tutta finestra; i tre passi in fila al posto delle tre schede; i dati incerti prima e i certi
  in una riga; la riga accesa sulla pagina al passaggio del mouse (oggi solo cliccando «p. N»); la scelta di una
  differenza toccando il valore giusto; il pulsante unico che dice cosa manca.

### 62.3 Cosa fare

1. **Dati certi e incerti, da regole** (`Motori/MotoreDocumenti.swift`, funzione pura nuova, codice comune ma solo
   aggiunta): `static func incerti(_ d: Documento) -> [CampoDocumento: String]` (il dato e il perché). Proposta di regole
   (vedi 62.6): un dato è incerto se non ha la riga d'origine (`estratto` vuoto) e non è scritto a mano; se il valore non
   si rilegge nel formato del suo campo (importo, data, percentuale, ISIN con la cifra di controllo, codice fiscale,
   SRI fra 1 e 7); se è stato letto da Qwen e non dalle regole (`origine`); se lo stesso campo compare nel testo con due
   valori diversi; se una data è nel futuro dove non può esserlo. Il perché è una frase breve in
   `TestiDocumenti.perche(_:)` (enum nuovo, Motori/TestiDocumenti.swift) («Nel testo non trovo la riga da cui viene: controlla.», «Il numero non ha la forma di un
   importo.», «L’ho letto con Qwen: controlla.», «Nel documento ci sono due valori diversi.»). Un campo mancante che il
   tipo di documento dovrebbe avere (oggi `MotoreDocumenti.mancanti`, :368) è anch'esso «da controllare» con il suo
   perché («In queste pagine non c’è la parte sui beneficiari.»). Un mancante non è un `CampoEstratto`: «Va bene» senza
   valore lo lascia mancante (niente si scrive, la scelta resta in memoria finché il lettore è aperto); scrivendo un
   valore e premendo «Va bene» entra con `aggiungiCampo` («A mano», confermato). I mancanti contano come dubbi solo
   finché il documento ha dati non confermati: a documento salvato (vedi punto 8) si mostrano come riga grigia «Non
   trovato: <campo>» con «Aggiungi», così riaprendolo il pulsante dice «Chiudi». Un dato scritto a mano
   (`origine == "A mano"`) non è mai incerto.
2. **Il lettore a tutta finestra** (`Shell/LettoreDocumento.swift`, nuovo, solo Mac): `LettoreDocumento(voce:)`.
   **Non** una sovrapposizione nuova: è un dettaglio del tema che nasce dalla scheda del documento toccata
   (`.origineDettaglio(id: "documento:<id>")` sulla riga dell'elenco) e si apre con il presentatore che il dossier ha
   già (`DettaglioDossierApple(id:)` riconosce il prefisso «documento:»; nell'app Documenti, che oggi non ne ha uno, si
   aggiunge `.presentatoreDettaglio` sul suo contenuto). Velo, entrata e chiusura sono quelli del tema (`Tema.Apple.Moto`
   al ritmo `ritmo`, ✕, Esc, clic sul velo; con `\.prismaCalmo` dissolvenza 0,15 s; nelle istantanee già aperto con
   `StatoDettaglio(aperto:misura:)`). La misura: `Tema.Apple.Lettore.misura` 1220×790, ristretta all'area della
   finestra (il presentatore la limita già, DettaglioApple.swift:350-353; la finestra interna è quasi sempre più piccola di 1220: il lettore la riempie, come
   dice il template, «prende tutta la finestra»). Il template la mette sopra tutto Prisma; nell'app resta dentro la
   finestra del dossier, come tutti i dettagli del tema (vedi 62.6). Chi apre un documento da fuori (ricerca, notifiche,
   Vera, Prodotti: oggi scelgono il documento in `ClienteDocumenti`) scrive una richiesta in memoria
   `stato.vistaDocumenti.lettore: String?` che la finestra consuma all'apparire (apre il dettaglio e la azzera).
   In `ClienteDocumenti` e `AppDocumenti` sul Mac l'elenco prende tutta la larghezza e il tocco su un documento apre il
   lettore invece del dettaglio affiancato; chiudendo si torna all'elenco con il documento scelto. Il dettaglio di oggi
   (`DettaglioDocumento`) resta per iPhone e iPad.
3. **Colonna sinistra**: `AnteprimaDocumento` di oggi (foglio vero, sempre chiaro, zoom e pagine come oggi), larga
   `Tema.Apple.Lettore.colonnaPagina` (470 al minimo, cresce con la finestra), fondo `chip`, raggio 20; sotto, la capsula
   «pagina N · <data del documento>». La riga accesa al passaggio: il lettore tiene `@State sopra: CampoDocumento?` e lo
   passa all'anteprima come parametro (nuovo `evidenziaSopra:`), senza scrivere `stato.vistaDocumenti` a ogni
   movimento del mouse; colore `Tema.Apple.Lettore.rigaAccesa` (giallo al 40%, quello del template, fisso: è sul foglio).
   L'anteprima usa il dato sopra il mouse se c'è, altrimenti `vistaDocumenti.evidenzia` (il clic su «p. N», che cambia
   pagina come oggi). Il passaggio **non cambia pagina**: accende la riga solo se il dato è sulla pagina mostrata e ha la
   riga d'origine (sulle scansioni senza testo non si accende niente). Nel PDF la ricerca dell'estratto
   (`VistaPDF.mostra`) va fatta una volta per dato e tenuta, non a ogni movimento.
4. **Colonna destra, testata**: occhiello «Documento di <Nome> · <tipo>», titolo (rinominabile come oggi con il doppio
   clic), data e `EtichettaCanaleApple` (o «Canale da indicare» come oggi). Il menu «⋯» di oggi (`vociMenu`) resta in
   testata a destra (tipo, collega, crea, apri in Anteprima, Finder, condividi, stampa, rileggi, scollega, elimina):
   niente sparisce.
5. **Passo 1 «I dati letti»** (`PassoDatiLetti`): `NumeroPasso` (o un numero del tema di 20) e la capsula. Righe
   incerte con `RigaConfermaApple` della 68 (stato «da decidere»: «?» arancio, valore correggibile con un `TextField`
   sul posto come oggi, il perché sotto, «Va bene» → `confermaCampo(id, chiave, true)`; una correzione scrive con
   `aggiungiCampo` che conferma). I dati certi e non ancora confermati: una riga «✓ N dati letti con certezza ·
   Mostra» (`Mostra` li apre, ognuno con la sua fonte «p. N»); con tre o meno si mostrano subito. I dati già confermati
   stanno fra i certi.
6. **Passo 2 «A cosa è collegato»**: il collegamento di oggi (`voce.nomeCollegato`, `collegaDocumento`) in una riga
   con la spunta; «Cambia» apre il menu `vociCollega()` di oggi. Senza collegamento: riga arancio «Non è collegato» con
   il suggerimento di oggi («Sembra la posizione «…» di …» e «Collega», `suggerimentoCollegamento`), che conta come un
   dubbio. Documenti del cliente senza posizione (identità, questionari): «Al dossier di <Nome>».
7. **Passo 3 «Cosa non torna»** (solo se `ConfrontoDossier` ha differenze; con più bersagli, `bersagli(d)`, un gruppo
   di riquadri per bersaglio col suo nome; il confronto si tiene con `stato.ricavato("documento-confronto|<id>")`, non
   nel body): per ogni voce diversa un riquadro
   (`SceltaDifferenza`) con il nome, la frase di `TestiConfrontoDossier`, e due riquadri da toccare «Nel documento» e
   «Nella posizione» (per le schede prodotto «Nella scheda»). La scelta resta in memoria finché il lettore è aperto
   (`@State scelte: [VoceDossier: Lato]`); si applica solo con il pulsante finale: «Nel documento» → la voce entra in
   `aggiornaDalDocumento(..., voci:)` (con lo storico di oggi, si annulla con `ripristina`); «Nella posizione» → la voce
   entra in `alternaVociTenute`. L'impatto di un KID su altri clienti (`ConfrontoDossierVista` di oggi) resta come riga
   in fondo al passo con «Vedi chi» (apre il confronto completo di oggi in una scheda).
8. **Il piede**: `PulsanteChiusuraConferma` della 68 con i testi del template: «Controlla il dato in arancione» /
   «Controlla i N dati in arancione» → «Decidi la differenza» / «Decidi le N differenze» → «Fatto: salva nel dossier»
   (blu) → «Chiudi». «Fatto» conferma i dati certi (`confermaCampo` per ciascuno: sono stati visti nella riga riassunto)
   e applica le scelte del passo 3, poi chiude con l'avviso ««<documento>» salvato nel dossier di <Nome>». Il premuto
   con dell'arancione: il primo dato o la prima differenza da decidere scorre in vista (`ScrollViewReader`) e trema
   (`ScuotiConferma` della 68), avviso «Prima controlla i dati in arancione» / «Prima scegli il valore giusto per ogni
   differenza». «Già salvato» non è un campo nuovo: si ricava all'apertura (nessun dato non confermato e nessuna
   differenza aperta, cioè `Indicatori.daControllare == 0 && differenze == 0`) e allora il pulsante è «Chiudi». Accanto
   «Chiedi a Vera» (l'«Apri con Vera» di oggi, con l'aiuto «Vera risponde solo con il testo di questo documento,
   citando la pagina»). A destra «I dati entrano nel dossier solo quando lo dici tu» / «Già salvato nel dossier».
9. **«Testo»** non è più una scheda: diventa la voce «Mostra il testo» nel menu «⋯» (apre il testo letto, pagina per
   pagina, nella colonna destra al posto dei passi, con «‹ Torna ai passi»). «Aggiorna il valore» di un estratto conto
   (`aggiornaValoreDaDocumento`) diventa la differenza «Valore» del passo 3 quando il documento è più recente.
10. **Documenti impaginati da Prisma** (`genere == .prisma`): niente passi, la pagina a tutta larghezza con la nota di oggi
   (`notaImpaginato`). Documenti illeggibili: il banner di oggi al posto dei passi, con «Rileggi».
11. **Token** in `DesignSystem/Apple/Tema.Apple+Lettore.swift` (`Tema.Apple.Lettore`, nuovo): `misura` (CGSize 1220×790,
   come le altre misure dei dettagli in `Tema.Apple.Misura.DettaglioAperto`), `margine` 28, `spazioColonne` 22, `colonnaPagina` 470, `raggioPagina` 20, `fondoPagina`
   (= `chip`), `rigaAccesa` (giallo `#FFD60A` al 40%), `numeroPasso` 20, `titolo` (24 display), `titoloPasso` 15,
   `rigaDato` (14), `perche` (12,5 arancio testo), `riquadroScelta` (raggio 12, bordo 1,5, padding 8×12),
   `sceltaAccesa` (bordo verde, fondo verde al 10%), `fondoDifferenza` (arancio al 10%, bordo arancio al 25%, raggio
   14). I colori arancio e verde sono quelli del tema (con la miglioria 7 l'arancio del testo è più scuro).

**Non fare**: niente «Conferma tutti»; non portare i campi e le differenze dimostrative di `lettDati`; non scrivere
`vistaDocumenti` al passaggio del mouse; non mettere vetro sul foglio (resta carta bianca).

### 62.4 Dati, archivio, privacy

Nessun campo nuovo: «certo» e «incerto» si ricavano dalle regole a ogni apertura (in cache con
`stato.ricavato("documento-incerti|<id>")`, valido finché il documento non cambia). Le conferme e le correzioni
scrivono i campi di oggi (`CampoEstratto.confermato`, `aggiungiCampo`); le scelte delle differenze scrivono la posizione
o la scheda con lo storico di oggi. «Chiedi a Vera» usa Qwen sul Mac come oggi. Nessun dato nuovo esce dal Mac.

### 62.5 Istantanee e prove

- Da aggiornare (si aprono nel lettore): «161-clienti-documenti-cosa-non-torna» (e scura), «162-clienti-documenti-
  fonte-pagina», «163-clienti-documenti-testo» (testo dal menu), «164-…-schermo-basso», «165-…-identita-in-regola»,
  «166-…-kid-categorie», «190-…-confronto-polizza», «191-…-confronto-kid-impatto» (e scura), «193-…-appendice-da-
  collegare», «194-…-confronto-storico», «237-clienti-documenti-stretta», «290-…-stretta-dati», «281-…-da-leggere»,
  «903-scheda-dai-documenti». Le scene che mostrano solo l'elenco (280, 160) non cambiano.
- Nuove: «1304-uso-lettore-da-controllare» (polizza di Marco: un dato incerto, certi in una riga, una differenza; chiara
  e scura), «1305-uso-lettore-deciso» (tutto a posto, pulsante blu «Fatto: salva nel dossier»),
  «1306-uso-lettore-certi-aperti» (dopo «Mostra»), «1307-uso-lettore-riga-accesa» (passaggio simulato su un dato).
- Prove: `ProvaCalcoliDocumenti` (Motori/ProvaCalcoliDocumenti.swift): le regole di `incerti` (riga d'origine vuota,
  importo illeggibile, due valori, data futura, dato a mano mai incerto); «Fatto» non conferma un dato incerto; la scelta
  «Nel documento» aggiorna la posizione con lo storico e `ripristina` la riporta. `--prova-backup` non cambia (nessun
  campo nuovo).

### 62.6 Decisioni per l'utente e rischi

- **Quali dati sono «incerti»**: il template li marca a mano. Proposta: le regole di 62.3 punto 1; l'utente può
  aggiungerne o toglierne.
- **«Fatto» conferma i dati certi senza aprirli uno per uno**: è quello che fa il template (la riga «N dati letti con
  certezza» è vista, non cieca). Proposta: sì; in alternativa «Fatto» resta spento finché non si apre «Mostra».
- **Il lettore anche nell'app Documenti e dalla Biblioteca**: il template lo mostra solo dal dossier. Proposta: lo
  stesso lettore ovunque si apra un documento di un cliente sul Mac (un solo modo); la Biblioteca resta com'è (i suoi
  documenti non hanno dati da confermare).
- **«Testo» nel menu «⋯»**: proposta, sì.
- **Dove si apre il lettore**: il template lo mette sopra tutto Prisma (velo su tutta la finestra principale).
  Proposta: dentro la finestra del dossier (o di Documenti), con il dettaglio del tema che nasce dalla scheda, come tutti
  gli altri dettagli dell'app; ingrandendo la finestra il lettore cresce fino a 1220×790. In alternativa una
  sovrapposizione della shell sopra tutte le finestre (più codice, e un'eccezione al movimento del tema).
- **Il colore della riga accesa**: il template usa il giallo al 40%; oggi la riga del «p. N» è azzurra. Proposta: nel
  lettore del Mac il giallo del template sia al passaggio sia per «p. N» (un colore solo sullo stesso foglio); iPhone e
  iPad restano azzurri.
- **Rischi**: `DettaglioDocumento` (1323 righe) resta per iOS: il lettore nuovo non deve copiarlo ma riusarne i pezzi
  (`AnteprimaDocumento`, `SezioneSchedaDocumento`, `vociMenu`, il confronto): `vociMenu`, `vociCollega` e
  `AzionePrincipale` oggi sono `private` dentro `DettaglioDocumento` e vanno spostati in un tipo comune. Il dettaglio
  dentro una finestra interna deve rispettare `VisibilitaFinestra` (niente animazioni continue). Le istantanee del
  dossier aprono i dettagli con `RichiestaIstantaneaDossier`: le scene del lettore passano da lì. La memoria: un PDF grande nel foglio
  usa già `MemoriaTesti`; il lettore non deve tenere aperte due anteprime insieme (chiude il dettaglio dietro).

### 62.7 Dimensione

**L** (circa 650 righe). File: Shell/LettoreDocumento.swift (nuovo), Shell/ClienteDocumenti.swift, Shell/AppDocumenti.swift,
Shell/AnteprimaDocumento.swift, Shell/StatoDocumenti.swift, Shell/StatoConfrontoDossier.swift, Motori/MotoreDocumenti.swift,
Shell/DossierObiettivi.swift (`DettaglioDossierApple` apre il lettore), Shell/DettaglioDocumento.swift (menu e azione
principale in un tipo comune), Shell/VistaDocumenti.swift (la richiesta `lettore`),
DesignSystem/Apple/Tema.Apple+Lettore.swift (nuovo), Istantanee.swift.

---

## 66. Le parole si spiegano dove sono

### 66.1 Nel template

Righe 4821-4859; CSS 753-755; regola a riga 2908-2910. Pannello: `MIG11a[2]` (Marco, Posizioni › Costi).

**Il filo tratteggiato** (`glSegna`, righe 4838-4842): le parole del mestiere hanno un filo a puntini sotto (1,5 punti,
3 sotto la riga, color accento; al passaggio del mouse la parola diventa accento; il cursore è quello dell'aiuto),
**solo la prima volta che compaiono in una schermata** (il contenuto della finestra e il dettaglio aperto contano come
due schermate). Si segna **nel testo e nelle etichette**, non in: titoli (testo oltre 17,5 punti), pulsanti, segmentati,
etichette di stato, chip, righe di elenco, cifre grandi, testo in grassetto, occhielli, documenti su carta, campi da
scrivere, parole già spiegate nella vista del cliente (`GL_NO`, riga 4837), testi più corti di tre lettere. Il filo si
mette su **una sola occorrenza per parola** (la prima nell'ordine del testo; parole diverse nello stesso paragrafo si
segnano tutte). Il template ripassa la schermata 420 ms dopo ogni cambiamento (`MutationObserver`, 120 ms con «Riduci
movimento»). **Nella vista del cliente** (`pulita`) il filo non c'è: lì restano i termini spiegati della miglioria 1.

Le parole e le forme che si riconoscono (`GLRE`, riga 4836): SRI, KID, gestione separata, riscatto/riscatti, caso morte,
divario, multiramo, TFR, caricamento/caricamenti, deduzione/deduzioni/deducibile/deducibili, adeguatezza,
consolidamento, plusvalenza/plusvalenze, patrimonio netto, rendita, premio/premi. Le definizioni (`GLOSS`, righe
3278-3280 e 4824-4835) sono di due righe.

**La scheda della parola** (`glApri`, righe 4846-4849): un tocco sulla parola apre, lì accanto (sotto la parola, 8 punti;
sopra se non ci sta), una scheda larga 340 (padding 14×16, fondo `--pop`, ombra): occhiello azzurro «Le parole»,
termine 16 bold, definizione 14 con interlinea 1,5, e il link **«Tutte le parole ›»** che apre il glossario su quella
parola. Entra in 240 ms (6 punti dal basso, scala 0,98, molla). Si chiude con un clic fuori o con Esc.

**Il glossario** (`apriGlossario`, righe 4851-4858): una scheda grande con l'occhiello «Le parole», il titolo «Il
glossario di Prisma», il campo «Cerca una parola: SRI, riscatto, TFR…», due colonne (elenco alfabetico 270 a sinistra,
la parola scelta a destra: termine 24 bold e definizione 16,5; la ricerca guarda il termine e la definizione; aperto da
una parola, quella è già scelta); senza risultati «Nessuna parola così.»; in fondo «Nelle
schermate, le parole con il filo tratteggiato si aprono con un tocco. Nella vista del cliente restano spiegate.». Il
glossario si trova anche dalla lente (61, gruppo «Parole»).

### 66.2 Nell'app oggi

- `Shell/Glossario.swift`: `VoceGlossario` (:7: chiave, termine, per esteso, categoria, `breve` di al più 110
  caratteri, spiegazione, esempio, dove) e `Glossario.voci` (:54, una cinquantina di voci in cinque categorie);
  `Glossario.etichette` (:289: le etichette esatte dell'interfaccia che hanno una voce), `voce(perEtichetta:)`,
  `cerca(_:categoria:)`. Ci sono già KID, SRI, gestione separata, riscatto, multiramo, TFR, premio, caricamento,
  deducibilità, rendita, adeguatezza, consolidamento, capitale caso morte, patrimonio netto, in essere. **Mancano**
  «plusvalenza» e «divario previdenziale».
- `DesignSystem/ComponentiGuida.swift`: la **«i»** accanto a un'etichetta tecnica (`InfoTermine`, :8: suggerimento con la
  riga breve, popover `SchedaTermine` con termine, per esteso, breve, spiegazione, esempio e «Apri nel glossario») e
  `EtichettaConTermine` (:103: mette da sé la «i» se l'etichetta è in `Glossario.etichette`). Usate in 9 file
  (PannelliPosizione, DettaglioPosizione, ModuloCliente, ModuloCondizioni, SezioneComposizione, ComponentiRubrica,
  ComponentiAnalisi, ComponentiProdotti, ComponentiMultiramo). Sui documenti (`\.etichetteStampa`) non c'è.
- Il glossario: `Shell/PannelloGuida.swift` (:443 «Le parole», una delle tre parti della «Guida di Prisma» con «Come
  funziona» e «Le app»; categorie «Tutte» + cinque, campo «Cerca una parola: SRI, riscatto, TFR…» a :466, elenco e voce;
  senza risultati, a :480, «Nessuna parola trovata. Prova con una parte della parola, o chiedi a Vera.»), aperto da
  `stato.apriGuida(.glossario(chiave))` (GuidaPrisma.swift:311) e dal «?» della barra.
- Prova: ProvaCalcoli.swift:1333-1346 (una voce per chiave, niente doppioni, etichette con voce, breve entro 110
  caratteri, ricerca senza accenti, parole delle app con voce).
- **Manca**: le parole spiegate dentro le frasi (oggi solo la «i» accanto a etichette esatte); la regola «la prima
  volta in una schermata»; il collegamento dalla scheda della parola al glossario si chiama «Apri nel glossario».

### 66.3 Cosa fare

1. **Le forme delle parole** (`Shell/Glossario.swift`, dati puri): `static let forme: [(VoceGlossario.Chiave,
   NSRegularExpression)]` preparata una volta (come `FiltriRicerca.spaziFiltri`), con le forme del template legate alle
   chiavi di oggi: `sri` (`\bSRI\b`), `kid`, `gestioneSeparata`, `riscatto` (`riscatt[oi]`), `capitaleMorte` («caso
   morte»), `divarioPrevidenziale` (nuova), `multiramo`, `tfr`, `caricamento` (`caricament[oi]`), `deducibilita`
   («deduzion[ei]», «deducibil[ei]»), `adeguatezza`, `consolidamento`, `plusvalenza` (nuova, «plusvalenz[ae]»),
   `patrimonioNetto`, `rendita`, `premio` (`premio?`: «premio» e «premi»; `premi[oi]` del template non trova «premi»). Nell'ordine del template (il primo che corrisponde vince);
   le sigle SRI, KID e TFR solo in maiuscolo, le altre senza badare a maiuscole e minuscole, sempre a parola intera
   (`\b`). Due
   voci nuove in `Glossario.voci`: `plusvalenza` (categoria «Previdenza e tasse») e `divarioPrevidenziale` («Le parole
   di Prisma»), con `breve` dalle definizioni del template (righe 4835 e 3279), entro 110 caratteri.
2. **Dove sono, una volta per schermata** (funzione pura): `ParoleSchermata.segna(_ testi: [String]) -> [Set<Chiave>]`
   riceve i testi di una schermata **nell'ordine in cui si leggono** e dice, per ognuno, quali parole segnare: la prima
   occorrenza di ogni chiave nell'intera schermata. La schermata la calcola una volta, fuori dal body, con
   `stato.ricavato("parole|<schermata>|<chiave dei testi>") { ParoleSchermata.segna(testi) }`, e passa a ogni testo il
   suo insieme. Così il risultato è stabile (non dipende dall'ordine in cui SwiftUI disegna) ed è provabile. Come nel
   template, il contenuto della finestra e il dettaglio aperto sopra (`presentatoreDettaglio`) sono due schermate: ognuno
   ha il suo elenco e la sua chiave.
3. **Il testo con le parole** (`DesignSystem/Apple/TestoConParoleApple.swift`, nuovo): `TestoConParole(_ testo:,
   parole: Set<Chiave>, carattere:, colore:)`. Costruisce un `AttributedString` (in cache per testo e insieme) con la
   prima occorrenza di ogni parola dell'insieme sottolineata a puntini (`underlineStyle(Text.LineStyle(pattern: .dot,
   color: accento))`, macOS 13+) e con un `link` interno `prisma-parola://<chiave>`; il testo della parola resta del
   colore del paragrafo (SwiftUI colora i link con la tinta: `.tint` del `Text` uguale al colore del testo, come nel
   template dove la parola cambia colore solo al passaggio); il `Text` riceve
   `.environment(\.openURL, OpenURLAction { … .handled })` che apre la scheda. Nessun indirizzo esterno: lo schema è
   interno e non arriva mai al sistema. Su un documento (`\.etichetteStampa`), nella vista pulita della miglioria 1 o in
   modalità cliente (`stato.inModoCliente`, letto nell'azione e in un `@Environment` già esistente, non nel body di chi
   non lo legge già) il testo è semplice.
4. **La scheda della parola**: `SchedaParola` (nuova, accanto a `SchedaTermine` in ComponentiGuida.swift) in un
   `.popover` ancorato al testo (SwiftUI non sa ancorare alla singola parola: la freccia indica il paragrafo, vedi 66.6):
   occhiello «Le parole» (accento), termine 16 bold, `breve` e la spiegazione (due righe), link «Tutte le parole ›»
   (`stato.apriGuida(.glossario(chiave))`). Esc e il clic fuori la chiudono (comportamento del popover). Entrata del
   popover di sistema; con `\.prismaCalmo` nessun movimento in più.
5. **Le etichette**: `EtichettaConTermine` smette di mettere la «i» e segna l'etichetta stessa col filo (un solo modo di
   spiegare); `InfoTermine` resta solo dove l'etichetta non è testo (per esempio un'intestazione di colonna con un
   simbolo). «Apri nel glossario» diventa «Tutte le parole ›» anche in `SchedaTermine`.
6. **Dove si applica, per primo**: i testi di spiegazione e le frasi (non titoli, pulsanti, righe di elenco, cifre,
   occhielli, campi): le frasi delle aree di Analisi 360 (`frasi`/`TestiAree360`), la sezione Costi e i dettagli di
   Posizioni (`PannelliPosizione`, `DettaglioPosizione`), la scheda di un prodotto (`ComponentiProdotti`), le spiegazioni
   del TFR e del simulatore previdenza, le note di metodo (`NotaMetodo`). Ogni vista che adotta `TestoConParole`
   aggiunge i suoi testi all'elenco della schermata (punto 2). Le altre viste restano com'erano finché non vengono
   toccate: la miglioria si estende a pezzi.
7. **Il glossario** (`PannelloGuida`, già quasi come il template): sotto il campo, la frase «Nelle schermate, le parole
   con il filo tratteggiato si aprono con un tocco. Nella vista del cliente restano spiegate.»; senza risultati «Nessuna
   parola così.». Le categorie di oggi restano (il template non le ha, ma non le vieta: vedi 66.6).
8. **Token** in `DesignSystem/Apple/Tema.Apple+Parole.swift` (`Tema.Apple.Parole`, nuovo): `filo` (puntini, accento),
   `schedaLarghezza` 340, `schedaMargine` 14×16, `termine` (16 bold),
   `definizione` (14, interlinea 1,5). Nessun colore nuovo: tutti dal tema.

**Non fare**: non scorrere tutti i testi dell'app cercando parole (niente equivalente di `MutationObserver`); non
segnare titoli, pulsanti, cifre, documenti su carta, PDF; non mettere il filo nella vista del cliente.

### 66.4 Dati, archivio, privacy

Nessun campo nuovo: le parole e le forme sono codice (Glossario.swift), come le voci di oggi. Il link interno
`prisma-parola://` non apre niente fuori da Prisma (la `OpenURLAction` lo gestisce e restituisce `.handled`; ogni altro
indirizzo restituisce `.discarded`). Nessun dato esce.

### 66.5 Istantanee e prove

- Da aggiornare: «227-glossario», «228-glossario-sri» (e scura): la frase in fondo; le scene di Posizioni, Analisi 360 e
  Prodotti che mostrano testi con le parole (il filo si vede nelle istantanee), «106-posizioni-multiramo» (e scura),
  «102-costi-prospetto» resta senza filo (è un documento).
- Nuove: «1308-uso-parole-filo» (Marco, Posizioni › Costi, come il template: le parole segnate una volta; chiara e
  scura), «1309-uso-parole-scheda» (la scheda di «gestione separata» aperta: nelle istantanee il popover non si
  fotografa, quindi la scena mostra `SchedaParola` dentro una vetrina, come le altre schede a comparsa).
- Prove: in `--prova-calcoli` (accanto alle righe 1334-1346): ogni forma ha una voce; `ParoleSchermata.segna` segna
  la prima occorrenza nell'ordine («SRI» in due testi: solo il primo), le forme al plurale («premi», «riscatti»,
  «deducibili») trovano la voce, nessuna parola dentro un'altra («premiato» no), le due voci nuove entro 110 caratteri;
  `TestoConParole` non produce link fuori dallo schema interno.

### 66.6 Decisioni per l'utente e rischi

- **La «i» accanto alle etichette sparisce** a favore del filo: proposta, sì (un solo modo); dove l'etichetta è un
  simbolo resta la «i».
- **La scheda ancorata al paragrafo e non alla parola**: limite di SwiftUI su macOS 14. Proposta: va bene così; in
  alternativa una scheda sotto il puntatore (si sa dove si è cliccato con un gesto sopra il testo), più codice.
- **Le categorie del glossario restano**: proposta, sì (il template non le mostra ma il glossario di oggi ha 54 voci, 56 con le due
  nuove, e con le categorie si scorrono meglio).
- **Le definizioni del template sostituiscono le `breve` di oggi?** Proposta: no, restano quelle di oggi (già provate e
  fatte con le regole fiscali vere, per esempio la deduzione da `RegoleFiscali`); dal template si prendono solo le due
  voci nuove.
- **Rischi**: costruire `AttributedString` nel body costa: va in cache per testo; i link in `Text` non hanno lo stile
  del cursore d'aiuto (su macOS il cursore diventa la mano) e SwiftUI su macOS 14 non sa cambiare il colore di una sola
  parola al passaggio del mouse: niente colore al passaggio (il template lo ha), accettabile. Le frasi composte con interpolazioni
  (`Text("… \(x) …")`) vanno prima scritte come stringa intera per poter essere segnate.

### 66.7 Dimensione

**M** (circa 350 righe, più l'adozione nelle viste, che cresce a pezzi). File: Shell/Glossario.swift,
DesignSystem/Apple/TestoConParoleApple.swift (nuovo), DesignSystem/ComponentiGuida.swift, Shell/PannelloGuida.swift,
DesignSystem/Apple/Tema.Apple+Parole.swift (nuovo), Motori/ProvaCalcoli.swift, le prime viste (PannelliPosizione,
DettaglioPosizione, Analisi360Apple, ComponentiProdotti).

---

## 67. App aperte e spazi dal nome dell'app

### 67.1 Nel template

Righe 4951-4959; regola a riga 2911-2913. Pannello: `MIG11a[3]` (apre Clienti, poi Agenda, poi tocca l'etichetta).

L'etichetta con il nome dell'app nella barra (`#bApp`, riga 846; nella base non faceva niente, riga 2580) apre un menu
(`apriMenu`, riga 3098: scheda larga almeno 236, padding 8, sotto l'etichetta a 8 punti, entrata di 320 ms da 8 punti più
su e scala 0,97, molla; un clic fuori la chiude; un secondo tocco sull'etichetta la chiude). Non si apre nella vista del
cliente. Le voci, dall'alto (riga 4959):
- **Le app usate da poco** (il template ne ricorda cinque compresa quella davanti, quindi nel menu **al più quattro**,
  l'ultima usata prima, senza quella davanti): icona dell'app 20 (raggio 5), nome e, a destra in piccolo, il nome del
  cliente scelto (`nomeDi`, il nome di battesimo) se l'app lavora su un cliente (`APPCLI`: Clienti, Posizioni, Analisi
  360…). Un tocco ci torna. Senza altre app: «Nessun’altra app aperta, per ora».
- un filetto;
- **Gli spazi di lavoro, con il loro nome**: «**Preparo un incontro**» (Incontri + Vera), «**Faccio un’analisi**»
  (Analisi 360 + Posizioni), «**Comincio la giornata**» (Agenda + Messaggi): glifo dello schermo 16, nome, a destra in
  piccolo le due app scritte proprio così («Incontri + Vera»). Un tocco apre lo spazio (le due app affiancate; il
  template, che non ha finestre, apre la prima e lo dice con un avviso). Il template mostra solo i tre spazi pronti:
  gli spazi salvati dall'utente non li disegna (nell'app ci sono e vanno nel menu, sotto i pronti).
- un filetto;
- **«Salva le finestre aperte come spazio…»** (lo spazio si salva con il nome scelto, come oggi);
- **«Torna alla scrivania»**.

Prende il posto dell'icona delle app aperte (regola 67: «a destra nella barra»; istantanee indicate: 56 e 64) e di
quella degli spazi, «senza nome». Nell'app un'icona delle app aperte nella barra non c'è (vedi 67.2): niente da togliere.

### 67.2 Nell'app oggi

- La pillola c'è e fa già qualcosa: `BarraSuperiore.appCorrente` (Shell/BarraSuperiore.swift:102) mostra
  `TitoloAppAttiva` (:222, «Scrivania» se non c'è un'app) e apre **il pannello degli spazi** (`stato.pannelloSpazi`,
  aiuto «Spazi di lavoro»), non in modalità cliente.
- `Shell/PannelloSpazi.swift`: `PannelloSpazi` (:5), una scheda grande dall'alto con «Spazi di lavoro», «Le app che ti
  servono, già disposte: si riaprono con un clic.», «PRONTI» e «I TUOI SPAZI» con le miniature (`MiniaturaSpazio`), la ✕
  per eliminare uno spazio salvato, e in fondo «Salva le finestre aperte (…)» con il nome e «Salva».
- `Dati/SpaziLavoro.swift:62`: `SpazioLavoro.predefiniti`: «Incontro con il cliente» (Vera + Clienti), «Analisi 360 con
  Vera» (Vera + Analisi 360), «La giornata» (Clienti + Agenda). Gli spazi dell'utente in `dati.spazi` (archivio).
  **Attenzione**: il commento sopra i predefiniti (SpaziLavoro.swift:58-61) dice che «Posizioni e Prospetti non si
  affiancano: su uno schermo da 13″ rendono solo a schermo pieno»; la principale prende il 58% (`quotaPrincipale`),
  l'altra il 42%. «Faccio un’analisi» del template affianca proprio Posizioni (vedi 67.6).
  `StatoShellFinestre.swift`: `apriSpazio` (:713), `salvaSpazio(nome:)` (:776), `eliminaSpazio` (:792),
  `mostraScrivania` (:552).
- **Le tue app aperte**: `PannelloAppAperte` (Shell/SchermataBenvenuto.swift:266), griglia delle finestre aperte con
  «Mostra la scrivania» e «Chiudi»; si apre dal menu «Vai › Le tue app aperte…» (PrismaApp.swift:132), dall'azione della
  ricerca e dalle prove; **nella barra non c'è un'icona** per le app aperte.
- Le finestre aperte e il loro ordine: `StatoFinestre.elenco` (:25, comprese le ridotte nel dock), `visibili` (:97,
  senza le ridotte), `appAttiva` (:100). Non c'è una storia delle app usate: l'ordine di `elenco` è quello di
  sovrapposizione (l'ultima è davanti).
- Il pannello degli spazi si chiude a mano in molti posti, per tenerne aperto uno solo: `cercaOvunque`
  (Ricerca.swift:626), `apriNotifica` (Notifiche.swift:446), `apriGuida` (GuidaPrisma.swift:327), le novità
  (StatoNovita.swift:132), la modalità cliente (ModoCliente.swift:30), le aperture di finestre e spazi
  (StatoShellFinestre.swift:465, 735, 748, 761); e lo controllano `VeraScrivania.swift:38`, `StatoNotteShell.swift:102`,
  `StatoNovita.swift:309`, `AppRicerca.swift:79/115`, `RicercaSpotlight.swift:174`, `ProvaGuidata.swift:165-232`.
- **Manca**: un menu unico sotto la pillola con le app aperte (per tornarci) e gli spazi con il loro nome; il nome del
  cliente accanto alle app che lo seguono; i nomi degli spazi del template.

### 67.3 Cosa fare

1. **Il menu** (`Shell/MenuAppBarra.swift`, nuovo, solo Mac): `MenuAppBarra`, un pannello della shell come
   `PannelloNotifiche` (vetro coprente del tema, ombra del tema, raggio dei menu del tema), ancorato sotto la pillola
   dell'app (ancora `anchorPreference`, come la campanella), largo almeno 236 (cresce col contenuto). Aperto e chiuso in
   `StatoFinestre.menuApp` (nuovo campo in memoria, accanto a `pannelloSpazi`, con `avvisi &+= 1`): così la shell non si
   ridisegna. Un clic fuori, Esc o un secondo tocco sulla pillola lo chiudono; si chiude da sé in modalità cliente e
   aprendo ricerca, «Da fare», notifiche o la scelta del cliente (e viceversa). Entrata: `Tema.Apple.Moto` (8 punti
   dall'alto, scala 0,97, molla, al ritmo `ritmo`); con `\.prismaCalmo` dissolvenza 0,15 s.
2. **Le voci**:
   - le finestre aperte tranne quella davanti, comprese le ridotte, dalla più vicina (`sistema.elenco` al contrario: è
     l'ordine di sovrapposizione, che sul Mac fa da «usate da poco»; al più quattro, come il template), con
     `IconaApp` 20, il titolo e a destra il nome breve del cliente se l'app segue il cliente (`AppPrisma` che lavorano su
     un cliente: la stessa lista che usa la miglioria 2; con «Tutti i clienti» niente nome). Un tocco porta la finestra
     davanti (`stato.apri(app)`). Senza altre finestre: «Nessun’altra app aperta, per ora» (grigio, non toccabile);
   - filetto; gli spazi pronti e poi quelli dell'utente, con il glifo dello schermo (SF Symbol `rectangle.split.2x1`, come
     l'azione di oggi), il nome e a destra le app come nel template («Incontri + Vera», dai titoli delle app di
     `SpazioLavoro.app`). Un tocco: `apriSpazio`. Quelli dell'utente hanno
     nel menu contestuale (clic destro) «Elimina lo spazio» (`eliminaSpazio`, con la conferma di oggi se c'è);
   - filetto; «Salva le finestre aperte come spazio…»: apre un piccolo modulo (`ModuloSalvaSpazio`, il piede di oggi di
     `PannelloSpazi` in una scheda: «Nome dello spazio», «Salva», spento senza nome); senza finestre aperte la voce è
     spenta con l'aiuto «Apri e disponi le app che ti servono, poi salvale qui come spazio.»;
   - «Torna alla scrivania» (`mostraScrivania`).
3. **La pillola** (`appCorrente`): aiuto «App aperte e spazi di lavoro»; azione `sistema.menuApp.toggle()` al posto di
   `pannelloSpazi.toggle()`. Come nel template, niente freccia dopo il nome (la proposta di 67.6): la pillola resta
   com'è, cambia solo cosa apre e l'aiuto.
4. **I nomi degli spazi pronti** (`SpazioLavoro.predefiniti`: il file si compila anche per iPhone e iPad, ma lì gli
   spazi non si usano): «Preparo un incontro» con Incontri e Vera, «Faccio un’analisi» con Analisi 360 e Posizioni, «Comincio la
   giornata» con Agenda e Messaggi. Gli `id` restano (`pronto-incontro`, `pronto-analisi`, `pronto-giornata`), così
   nulla cambia nell'archivio. La principale (a sinistra, 58%, in primo piano) è la prima app del nome: Incontri,
   Analisi 360, Agenda; l'altra a destra. Per «Faccio un’analisi» vale la decisione di 67.6 su Posizioni affiancata; il
   commento sopra `predefiniti` va riscritto di conseguenza.
5. **Cosa resta e cosa esce**: `PannelloSpazi` e `PannelloAppAperte` restano raggiungibili dal menu «Vai» (per chi li
   usa e per le prove), ma la barra apre solo il menu nuovo; le azioni «Spazi di lavoro» e «Le tue app aperte» della
   ricerca escono sul Mac (61.3 punto 4).
6. **Token** in `DesignSystem/Apple/Tema.Apple+DockFinestre.swift` (enum `MenuApp`, nuovo, accanto a dock e finestre):
   `larghezzaMinima` 236, `margine` 8, `distanzaPillola` 8, `icona` 20, `raggioIcona` 5, `rigaPadding` (7×10),
   `raggioRiga` (quello delle voci del tema), `notaCliente` (carattere 12 secondario), `filetto` (separatore del tema,
   margine 5×8). Testi in `enum TestiMenuApp` (Shell/MenuAppBarra.swift).

**Non fare**: non togliere gli spazi salvati dall'utente né il loro salvataggio; non aprire il menu in modalità cliente;
non mettere nel menu le app che non ci sono (il template elenca le app visitate; nell'app sono le finestre aperte, che
è la stessa cosa sul Mac).

### 67.4 Dati, archivio, privacy

Nessun campo nuovo: il menu è in memoria (`StatoFinestre.menuApp`), gli spazi dell'utente stanno già in `dati.spazi`
(archivio e backup, mai in «Prisma ovunque»). Il nome del cliente accanto alle app si vede solo fuori dalla modalità
cliente (il menu lì non si apre).

### 67.5 Istantanee e prove

- Da aggiornare: «55-spazio-incontro», «57-spazio-analisi», «58-spazio-giornata» (le app dei nuovi spazi pronti),
  «56-spazi» (il pannello di oggi con i nuovi nomi), «64-app-aperte» resta.
- Nuove: «1310-uso-menu-app» (Clienti con Giulia e Agenda aperte, menu sotto «Agenda»: Clienti con «Giulia», i tre spazi,
  le due voci in fondo; chiara e scura), «1311-uso-menu-app-vuoto» (dalla scrivania: «Nessun’altra app aperta, per
  ora»), «1312-uso-salva-spazio» (il modulo del nome).
- Prove: `--prova-vera` (Vera/ProvaVera.swift:628-636 controlla che il primo spazio pronto apra Vera e Clienti:
  diventa Incontri e Vera; la disposizione affiancata e dentro lo schermo per ogni spazio pronto resta);
  `--prova-fluidita` (ProvaFluidita.swift:339-342: aggiungere i passi «apri il menu delle app» e «chiudi il menu
  delle app», che non devono ridisegnare la shell: colonna «avvisi StatoFinestre»). iPhone e iPad non usano gli spazi
  (nessun riferimento a `SpazioLavoro` o `apriSpazio` in iOS/): nessuna prova mobile da toccare.

### 67.6 Decisioni per l'utente e rischi

- **«Faccio un’analisi» affianca Posizioni**: oggi Prisma non affianca mai Posizioni (SpaziLavoro.swift:58-61: «su uno
  schermo da 13″ rende solo a schermo pieno»), e il Mac dell'utente è un 13″. Proposta: lo spazio come il template, con
  Analisi 360 principale (58%) e Posizioni al 42%, provato con l'istantanea «57-spazio-analisi» e la prova della misura
  minima di `--prova-vera`; se Posizioni stretta non si legge, Posizioni principale e Analisi 360 accanto. (I nomi degli
  spazi pronti non toccano iPhone e iPad: lì gli spazi non ci sono.)
- **La freccia «⌄» nella pillola**: il template non la disegna. Proposta: niente freccia, come il template (l'aiuto dice
  cosa fa); la freccia solo se dopo lo screenshot l'utente la vuole.
- **Il pannello grande degli spazi con le miniature**: proposta, resta nel menu «Vai» (non nella barra).
- **Rischi**: un pannello in più nella shell va nell'elenco delle sovrapposizioni che si escludono a vicenda: in
  tutti i posti che oggi chiudono o controllano `pannelloSpazi` (elenco in 67.2) si aggiunge `menuApp`. La pillola cambia larghezza col nome dell'app: l'ancora va letta dal
  layout, non calcolata.

### 67.7 Dimensione

**S/M** (circa 220 righe). File: Shell/MenuAppBarra.swift (nuovo), Shell/BarraSuperiore.swift, Shell/StatoFinestre.swift,
Dati/SpaziLavoro.swift, Shell/ShellView.swift (monta i pannelli della shell), DesignSystem/Apple/Tema.Apple+DockFinestre.swift,
Vera/ProvaVera.swift, Istantanee.swift.

---

## 68. Quello che Prisma prepara da solo si conferma allo stesso modo

### 68.1 Nel template

Righe 4961-4975; CSS 782-784; regola a riga 2914-2918. Pannello: `MIG11a[4]` (Incontri, la nota vocale).

**La regola** (riga 2914): quando Prisma fa da sola (Stanotte, nota vocale, Inquadra, lettura di un documento) si
conferma sempre nello stesso modo: **il verde è fatto, l'arancione chiede una risposta, ogni cosa si può annullare, un
pulsante solo chiude e non è blu finché resta dell'arancione**. Inquadra è la miglioria 43 (gruppo 07), la lettura di un
documento è la 62: qui le altre due.

**Stanotte** (estensione di `apriNotte` e `decidi`, righe 4964-4966; base 2293-2316):
- sotto i due pulsanti tondi (✕ a sinistra, ✓ a destra, il contatore «N di M» in mezzo) compaiono le loro parole:
  **«Più tardi»** sotto ✕ e **«Va bene»** sotto ✓ (`.nCap`: 12,5 semibold secondario, ognuna larga 66, il posto del
  contatore 120 in mezzo, spazio 30). Quando le carte sono finite le parole svaniscono (opacità 0 in 0,4 s);
- la colonna a destra, che si chiamava «Fatto adesso», si chiama **«Cosa hai deciso»**; vuota, dice: «Qui compare ogni
  decisione, una riga per volta. Quelle rimandate finiscono nel «Da fare» di oggi.» (sparisce alla prima decisione);
- nella carta finale, sopra «Vai alla scrivania», se qualcosa è stato rimandato: «Le N cose rimandate sono nel «Da
  fare» di oggi.» (con una: «La cosa rimandata è nel «Da fare» di oggi.»; nel template c'è un refuso, «Le cosa
  rimandata è»). Gesto delle carte, frecce, timbri e aiuto del ✓ non cambiano.

**La nota vocale** (estensione di `apriNota`, righe 4967-4975; base 2526-2533), la scheda «Arriva sul Mac»:
- in testa, «Prisma ha capito che si parla di **<Nome>**» con a destra il pulsante **«Cambia»** (la nota e tutto il
  resto passano a un altro cliente);
- le voci preparate (nota salvata nel dossier, attività creata, messaggio pronto) sono **fatte**: ognuna ha a destra
  il link **«Annulla»**; annullata, la riga si attenua (opacità 0,45) e il link diventa **«Rimetti»**;
- la voce da decidere (l'obiettivo da aggiornare, «Casa: un anno prima · da confermare») è **arancione** (fondo arancio
  al 14%) con due pulsanti piccoli **«Aggiorna»** (blu) e **«No»**. Risposto, la riga dice «Casa: un anno prima ·
  aggiornato» con la capsula verde «Aggiornato», oppure «Casa: resta com’era» con la capsula neutra «Lasciato com’era»;
- in fondo **un pulsante solo**, grande: «Rispondi alla riga in arancione» (non blu) → **«Va bene così»** (blu), e
  accanto la frase che conta: «Tre cose fatte, una da decidere.» → «3 cose fatte, 1 annullata, una da decidere.» →
  «3 cose fatte.» (`agg`, riga 4972; il numero delle fatte conta solo le non annullate: «2 cose fatte, 1 annullata.»;
  con una sola «1 cosa fatta»). Il pulsante diventa blu solo quando non c'è più arancione; le annullate non lo
  fermano. Premuto con dell'arancione: la riga trema (300 ms, niente con «Riduci movimento») e l'avviso «Prima rispondi
  alla riga in arancione». A posto: la scheda si chiude con l'avviso «Nota di Giulia a posto: la trovi nel suo dossier»
  (Giulia è il nome di battesimo del cliente della nota).

### 68.2 Nell'app oggi

- **Stanotte**: `Shell/CarteNotte.swift`: `CarteNotte` (:12, frecce ← → e ⌘Z come oggi), `ComandiNotte` (:425: ✕,
  contatore, ✓; **senza parole sotto**, solo l'aiuto «Più tardi»/«Approva»), `RegistroNotte` (:479: titolo
  `TestiNotte.registro` = **«FATTO ADESSO»**, righe ✓/↺, clic per annullare: l'annullamento c'è già,
  `stato.annullaCartaNotte`), `FineNotte` (:538: «Tutto fatto.», `TestiNotte.fine`, «Vai alla scrivania»). Testi in
  `Motori/TestiNotte.swift` (:7). Le carte rimandate restano nella pila della notte e tornano alla prossima apertura
  (StatoNotteShell.swift:77, StatoNotteMac.swift:498): **non vanno nel «Da fare»**. Token `Tema.Apple.Notte`
  (Tema.Apple+Notte.swift).
- **La nota vocale**: `Shell/NotaVocaleArrivo.swift`: `SchedaNotaVocaleArrivo` (:110) con il cliente riconosciuto e
  «Cambia» (menu dei clienti, già c'è), le voci `VoceNotaVocale` (:234) **ognuna con «Conferma» e «Scarta»** (più
  «Modifica» per l'attività e «Apri l’obiettivo» per l'obiettivo), in fondo **«Conferma tutto»** (blu, ↩) e «Scarta la
  nota», e «Capito con Qwen» / «Capito con le regole di Prisma». Il modello: `Dati/NotaInArrivo.swift`
  (`PropostaNota`: tipo nota, attività, messaggio, obiettivo; stato proposta, confermata, scartata;
  `scadenzaDaConfermare`). Nell'app **niente si fa senza un «Conferma»** (Design/template-luce-specifica.md §6.2.1):
  il «prima» del template (quattro cose fatte senza chiedere) era della base «Luce», non dell'app. La conferma la fa
  `StatoShell.confermaNota(id, proposte:)` (Shell/NotaVocaleShell.swift:102) con il motore puro
  `ApplicaNotaVocale.applica` (Motori/ApplicaNotaVocale.swift:28: id stabili, confermare due volte non crea doppioni;
  l'obiettivo si aggiorna solo se esiste); mostra già un avviso («Nel dossier di <Nome>: la nota, un'attività,
  l'obiettivo aggiornato.») e, se fra le confermate c'è il messaggio, **apre Messaggi** con l'occasione pronta
  (`preparaMessaggio`: il messaggio non si scrive nell'archivio e non parte). `scartaPropostaNota` (:126) e
  `scartaNota` ci sono già.
- **Il componente comune non c'è**: ogni schermata disegna la sua riga «da controllare» (Inquadra nella 43, Aggiorna
  valori nella 44, il documento nel banner). Lo scuotimento c'è in due posti a sé (`ScuotiEffetto`,
  VisteMotoriVera.swift:330; il tremolio dell'esame OCF, Tema.Apple+OCF.swift:211).

### 68.3 Cosa fare

**La parte comune** (prima di tutto):
1. `DesignSystem/Apple/ConfermeApple.swift` (nuovo):
   - `enum StatoConferma { case fatta, daDecidere, annullata, decisa(testo: String, tono: Pillola.Tono) }` (il tono
     delle pillole che c'è già, ComponentiAnalisi.swift:314: `.ok` verde per «Aggiornato», `.neutro` per «Lasciato
     com’era»; nessun tipo nuovo per la capsula);
   - `RigaConfermaApple<Contenuto, Azioni>`: segno a sinistra («✓» verde per fatta e decisa, «?» arancio per da decidere,
     «✓» grigio per annullata), il contenuto, a destra le azioni. Da decidere: fondo arancio tenue, raggio 10. Annullata:
     opacità 0,45. Il link standard «Annulla» / «Rimetti» (`AnnullaRimettiApple`). Accessibilità: «Fatto», «Da
     decidere», «Annullato» letti prima del contenuto;
   - `PulsanteChiusuraConferma(dubbi: Int, testoDubbi: String, testoPronto: String, azione:, primoDubbio:)`: grande,
     stile normale finché `dubbi > 0` (premuto chiama `primoDubbio`, che scuote la riga e mostra l'avviso), blu con
     `.applePrimarioGrande` quando non ce ne sono (↩ solo allora);
   - `ScuotiConferma` (sposta qui `ScuotiEffetto` da VisteMotoriVera.swift, che lo riusa): 0 → −6 → +6 → 0 in 0,3 s
     al ritmo del tema, niente con `\.prismaCalmo` e nelle istantanee; si avvia con un contatore (`Animatable`, niente
     Timer).
2. Token in `DesignSystem/Apple/Tema.Apple+Conferme.swift` (`Tema.Apple.Conferme`, nuovo): `fondoDubbio` (arancio del
   tema al 12%), `raggioRiga` 10, `segno` (carattere 14 bold, larghezza 14), `opacitaAnnullata` 0.45, `scossa` 6,
   `durataScossa` 0.3 (moltiplicata per `Tema.Apple.Moto.ritmo`, come il tremolio dell'OCF). Colori dal tema (verde,
   arancio del testo della miglioria 7). Le didascalie di Stanotte non stanno qui ma accanto ai comandi della notte
   (punto 4).
3. Le migliorie 43 e 44 (gruppo 07) e la 62 usano questi componenti invece delle loro righe a sé.

**Stanotte**:
4. `ComandiNotte`: sotto ✕ e ✓ le didascalie `TestiNotte.piuTardi` («Più tardi») e `TestiNotte.vaBene` (nuovo, «Va
   bene»), larghe come il pulsante (`Tema.Apple.Notte.Comandi.pulsante` 66: le misure del template, 66, 120 e 30, sono
   già quelle dei comandi), il contatore in mezzo; svaniscono quando la pila è finita (opacità, 0,4 s al ritmo del
   tema; con `\.prismaCalmo` 0,15 s). Token nuovi in `Tema.Apple.Notte.Comandi`: `didascalia` (carattere 12,5
   semibold), `coloreDidascalia` (testo secondario della carta), `sottoPulsanti` (lo spazio fra pulsante e parola).
   L'aiuto del ✓ resta «Approva».
5. `RegistroNotte`: `TestiNotte.registro` = «COSA HAI DECISO» (l'occhiello è maiuscolo come oggi); vuoto, la frase
   `TestiNotte.registroVuoto` = «Qui compare ogni decisione, una riga per volta. Quelle rimandate finiscono nel «Da fare»
   di oggi.». Le righe restano cliccabili per annullare (aiuto «Clic per annullare»): è già la regola.
6. `FineNotte`: sopra «Vai alla scrivania» `TestiNotte.rimandateNelDaFare(_ n:)` («La cosa rimandata è nel «Da fare» di
   oggi.» / «Le N cose rimandate sono nel «Da fare» di oggi.»), solo con n > 0.
7. **Le rimandate nel «Da fare»** (dipende dalla miglioria 3 del gruppo 01): la specifica del gruppo 01 (tabella di
   3.3 punto 1 e 3.6) ha già deciso che le carte della notte **non** diventano voci da spuntare di `MotoreDaFare` ma
   stanno nella riga «Arrivati» in testa al pannello «Da fare». Quindi niente fonte nuova nel motore: la riga
   «Arrivati» conta anche le carte rimandate della notte di oggi («Stanotte: 2 cose rimandate»), lette dalla notte di
   oggi (`notteDiOggi`, le carte con stato `.rimandata`) dalla cache che la 3 usa per gli arrivi, e un tocco riapre
   Stanotte (`apriNotte`), dove le rimandate sono già in pila (StatoNotteShell.swift:77). Decisione e annullamento
   restano quelli di Stanotte. Finché la 3 non c'è, la frase della carta finale e del registro vuoto dice «… restano
   qui per domani» (vedi 68.6).

**La nota vocale**:
8. `SchedaNotaVocaleArrivo` e `VoceNotaVocale` passano alla regola con il componente comune. Quali voci sono verdi e
   quali arancioni, da regole (funzione pura in `Motori/MotoreNotaVocale.swift`, codice comune ma solo aggiunta): `daDecidere(_ p: PropostaNota) -> Bool` vero per l'obiettivo (cambia un piano del cliente), per
   un'attività con `scadenzaDaConfermare`, e per tutte quando il cliente non è riconosciuto (la testa diventa arancione
   con «Di chi si parla?» e «Scegli il cliente», come oggi). Nota, attività con data certa e messaggio sono verdi.
9. Le righe verdi hanno «Annulla» / «Rimetti» (tolgono o rimettono la voce da ciò che si fa); l'attività tiene
   «Modifica» come link accanto. La riga arancione dell'obiettivo ha «Aggiorna» (blu) e «No»; risposta: il testo con
   «aggiornato» / «resta com’era» e la capsula «Aggiornato» (verde) / «Lasciato com’era» (neutra), con «Cambia» per
   tornare indietro; «Apri l’obiettivo» di oggi resta come collegamento sulla riga. L'attività da confermare ha «Va
   bene» e «Modifica». Per le voci di Qwen resta l'etichetta di oggi («Capito con Qwen» / «Capito con le regole di
   Prisma»).
10. In fondo `PulsanteChiusuraConferma`: «Rispondi alla riga in arancione» / «Rispondi alle N righe in arancione» →
   «Va bene così»; accanto il conteggio di `TestiNotaVocale.conteggio(fatte:annullate:daDecidere:)` (enum nuovo in Motori/MotoreNotaVocale.swift) («3 cose pronte, 1
   annullata, una da decidere.», vedi 68.6 per «fatte»/«pronte»). «Va bene così» prima scarta le annullate e i «No»
   (`scartaPropostaNota`), poi chiama `confermaNota(id, proposte:)` con le voci verdi non annullate e le arancioni con
   «Aggiorna» (un solo `dati.carica`, come oggi). Un avviso solo: «Nota di <Nome> a posto: la trovi nel suo dossier»
   al posto di quello di oggi («Nel dossier di …»: `confermaNota` riceve un parametro per il testo dell'avviso, così le
   altre chiamate non cambiano). Se fra le confermate c'è il messaggio, dopo la chiusura si apre Messaggi con la bozza
   come oggi (`preparaMessaggio`: niente parte da solo; il template, che non ha Messaggi dietro, chiude e basta). Se
   tutte le voci sono annullate o «No», «Va bene così» equivale a «Scarta
   la nota». «Scarta la nota» resta, come link sotto il
   pulsante («Scarta tutta la nota»). ✕ ed Esc chiudono lasciando la nota «da decidere» in Incontri › Oggi, come oggi.
11. «Conferma tutto», «Conferma» e «Scarta» per voce escono (la regola li sostituisce).

**Non fare**: non applicare le voci della nota appena arriva senza la decisione dell'utente (vedi 68.6); non cambiare il
gesto delle carte della notte né le frecce; non portare la scelta fissa del template della quarta riga come dubbio.

### 68.4 Dati, archivio, privacy

Nessun campo nuovo. Le annullate e le risposte della nota restano in memoria finché la scheda è aperta e diventano, con
«Va bene così», gli stati di oggi di `PropostaNota` (`confermata`, `scartata`) in `noteInArrivo` (sezione «ovunque»,
mai in «Prisma ovunque»). Le carte rimandate contate nella riga «Arrivati» del «Da fare» si leggono da `dati.notti`
(già nell'archivio, sezione «relazione», mai su iPhone e iPad né in «Prisma ovunque»): solo il loro numero, senza
nomi, come gli altri arrivi del gruppo 01. La regola di
CLAUDE.md su «Stanotte» («Approva» non manda nulla e ogni approvazione si annulla) resta intatta.

### 68.5 Istantanee e prove

- Da aggiornare: «760-notte-carte» (le parole sotto i pulsanti, «COSA HAI DECISO» con la frase del vuoto),
  «762-notte-registro», «763-notte-fine» (la frase delle rimandate: in quella scena una carta è rimandata),
  «766-notte-stretta»; «771-nota-arrivata» (righe verdi con «Annulla», l'obiettivo arancione, «Rispondi alla riga in
  arancione»), «772-nota-confermata», «773-nota-cliente-dubbio» (testa arancione, pulsante spento).
- Nuove: «1313-uso-nota-decisa» (obiettivo «Aggiornato», un'attività annullata, «Va bene così» blu; chiara e scura),
  «1314-uso-notte-vuota-registro» (prima decisione non ancora presa, solo la frase del vuoto), «1315-uso-conferme-vetrina»
  (i componenti di ConfermeApple.swift in tutti gli stati, chiari e scuri, nella vetrina del tema come «400-vetrina-apple»).
- Prove: `--prova-vera` (le prove della nota dettata stanno in Vera/ProvaNotaVocale.swift, chiamata da
  ProvaVera.swift:1068: `daDecidere` per obiettivo, data da confermare e cliente mancante; «Va bene così» conferma le
  verdi, scarta le annullate e i «No», con tutto annullato scarta la nota; il ponte non cambia); la riga «Arrivati»
  con una carta rimandata, nella prova del «Da fare» del gruppo 01, se la miglioria 3 è fatta; `ProvaStatoFinaleApple`
  (DesignSystem/Apple/ProvaStatoFinaleApple.swift) per la scossa ferma nelle istantanee.

### 68.6 Decisioni per l'utente e rischi

- **Verde = «fatto» o «pronto»?** Nel template le voci della nota sono già fatte e si annullano; nell'app nulla entra nel
  dossier senza una conferma (Luce §6.2.1, e per Vera «ogni azione passa dalla scheda «Conferma»»). Proposta: il verde
  vuol dire «pronto, si fa con «Va bene così»», con «Annulla»/«Rimetti» prima; la frase dice «3 cose pronte, una da
  decidere.». In alternativa, come il template: le voci verdi si applicano all'arrivo della nota e «Annulla» le toglie
  (si può fare: `ApplicaNotaVocale` ha già id stabili, ma l'annullamento andrebbe scritto), con il testo «fatte».
  L'alternativa cambia una decisione già presa con l'utente in «Luce» (decisione 102: le proposte della nota sono
  «tutte da confermare sul Mac», Dati/NotaInArrivo.swift:4-5): va scelta esplicitamente.
- **Le rimandate nel «Da fare»**: proposta, sì, come il template, dopo la miglioria 3, nella forma già decisa dal
  gruppo 01 (la riga «Arrivati» col numero, non voci da spuntare); restano anche nella pila di Stanotte finché non si
  decidono. Prima della 3 la frase dice «Le N cose rimandate restano qui per domani.» / «La cosa rimandata resta qui
  per domani.».
- **Quali voci della nota sono arancioni**: proposta, le tre regole di 68.3 punto 8.
- **Rischi**: `NotaInArrivo` e il riconoscimento sono comuni con l'iPhone (che detta): solo funzioni nuove, nessun cambio
  al ponte (versione 3) né al modello. Il componente comune sarà usato da quattro schermate: va fatto bene una volta,
  con la vetrina e le istantanee chiare e scure, prima delle altre.

### 68.7 Dimensione

**M** (circa 400 righe: 150 il componente comune, 80 Stanotte, 170 la nota vocale). File:
DesignSystem/Apple/ConfermeApple.swift (nuovo), DesignSystem/Apple/Tema.Apple+Conferme.swift (nuovo),
Shell/CarteNotte.swift, Motori/TestiNotte.swift, DesignSystem/Apple/Tema.Apple+Notte.swift (le didascalie),
Shell/NotaVocaleArrivo.swift, Shell/NotaVocaleShell.swift (il testo dell'avviso di `confermaNota`),
Motori/MotoreNotaVocale.swift, la riga «Arrivati» del «Da fare» del gruppo 01 (dopo la 3), Shell/VisteMotoriVera.swift
(sposta lo scuotimento), Shell/IstantaneeNotte.swift, Shell/IstantaneeNotaVocale.swift, Vera/ProvaNotaVocale.swift.
