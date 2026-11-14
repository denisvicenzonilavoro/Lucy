# Gruppo 06 — Per chi vede Prisma la prima volta (migliorie 37-39)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html (stesse righe del template). Commento in testa: righe 48-51; regole per chi
implementa: righe 2769-2793 («IL SESTO GIRO»); CSS nuovo: righe 651-660 (`#bDemo`, `.impIn`, `.avT`, `.avS`, `.avO`);
codice: righe 4202-4265 (MIGLIORIA 37-39); pannello «✦ Migliorie» (`MIG6`): righe 4268-4271. Solo Mac: iPhone e iPad
restano come sono (le parti che li riguardano sono segnate «dopo, con iPhone e iPad»).

## Ordine consigliato

1. **38 · I canali hanno il nome che scegli**, prima la parte «nome del canale» (un solo punto da cui tutte le etichette
   leggono il nome), poi le tre domande del primo avvio. Va prima della 37 perché la terza domanda («Da dove parti»)
   accende la dimostrazione: la 37 le dà il comando da chiamare.
2. **37 · La dimostrazione è un interruttore**: è la più grande del gruppo e tocca l'archivio (niente salvataggi, backup e
   copia per iPhone e iPad mentre è accesa). Conviene farla in un branch da sola, con la prova del backup aggiornata.
3. **39 · iPhone e iPad: un collegamento solo**: indipendente dalle altre due, solo Impostazioni e i rimandi dalle app.

Dipendenze da altri gruppi:
- **Gruppo 04, miglioria 30** (le impostazioni si cercano, gruppi «Prisma», «Il lavoro», «Aiuto») e **31** («Da
  sistemare»): la 37 sposta «Strumenti › Dati di prova» in «Aiuto › Dimostrazione», la 38 riempie «Profilo», la 39
  riscrive «iPhone e iPad». Se la 30 è già fatta, l'indice della ricerca va aggiornato con le voci nuove di questo gruppo
  (titoli e sottotitoli qui sotto); se non è fatta, le pagine di questo gruppo si costruiscono già con le righe che la
  ricerca leggerà.
- **Gruppo 01, miglioria 2** (la pillola del cliente nella barra, `PillolaClienteBarra`): l'etichetta «Dimostrazione»
  sta subito dopo di lei. Se la 2 non c'è ancora, l'etichetta va dopo `appCorrente` in BarraSuperiore.swift.
- **Gruppo 01, miglioria 1** («Mostra al cliente», vista pulita): l'etichetta «Dimostrazione» non compare nella vista del
  cliente; il pulsante «Sull'iPad sul tavolo» della 1 porta alla pagina della 39 se l'iPad non è collegato.
- **Gruppo 01, miglioria 10** (le stesse parole): «Dimostrazione» è la parola al posto di «Dati di prova» e di
  «Strumenti › Clienti di prova» (gruppo-01.md, tabella delle parole).
- **Gruppo 01, miglioria 7** (l'arancione delle scritte): l'etichetta «Dimostrazione» usa `Tema.Apple.Colore.arancioTesto`,
  che esiste già (Tema.Apple+Ovunque.swift:11); il gruppo 01 lo ritocca, non ne crea un secondo con lo stesso nome.
- **Gruppo 04, migliorie 25-29**: le righe «Fonte: Dati di prova…» e «dati di prova» sotto i messaggi, nello Studio e in
  Mercato spariscono con la 37 (gruppo-04.md, righe 59 e 235).

---

## 37. La dimostrazione è un interruttore

### 37.1 Nel template

Regola 37 (righe 2770-2777), codice righe 4202-4227.

**L'interruttore** sta in Impostazioni, gruppo «Aiuto», sezione **«Dimostrazione»** (`IMPS.prove`, riga 4217), al posto
di «Dati di prova» della base (riga 4055). Accanto al nome della sezione, nella colonna, con la dimostrazione accesa c'è
la scritta piccola «accesa» (`stato`). La pagina:
- titolo «Dimostrazione», sotto l'introduzione «Per far vedere Prisma a un cliente curioso, a un collega o a chi la vuole
  comprare, senza mostrare il tuo lavoro.»;
- riga **«Dimostrazione»** · «Prisma mostra solo i clienti di prova: i tuoi restano da parte, intatti.» con
  l'interruttore (`#impDemo`);
- occhiello **«I clienti di prova»**, poi due righe: «Cinque clienti» · «Pochi, per spiegare con calma.» con il pulsante
  «Usa questi»; «Trentacinque clienti» · «Prisma piena: Vera, il territorio, lo Studio.» con l'esito verde «In uso».
  Le due righe scelgono quale gruppo di prova si mostra (nel template quello in uso è il secondo).

Al clic sull'interruttore (riga 4219): la dimostrazione si accende o si spegne, la colonna e la pagina si ridisegnano e
compare l'avviso «Dimostrazione accesa: i tuoi clienti sono da parte» oppure «Dimostrazione spenta».

**L'etichetta nella barra** (`#bDemo`, riga 4209; CSS riga 651): una pillola di vetro con la scritta «Dimostrazione»,
subito dopo la pillola del cliente (`#bCli`). Testo arancione del testo (`--orangeT`), grassetto 700, filo arancione al
40% (`rgba(224,138,0,.4)`). C'è solo con la dimostrazione accesa (`demoAggiorna`); nella vista pulita di «Mostra al
cliente» non c'è mai (riga 652).

**Al clic sull'etichetta** si apre una scheda (`apriDemo`, righe 4211-4214), larga 640:
- occhiello «Dimostrazione» in arancione del testo;
- titolo (24, grassetto) «Stai mostrando Prisma con i clienti di prova.»;
- tre righe, ognuna con la spunta verde (`fatto`, 18) a sinistra, titolo in grassetto 14,5 e testo 13,5:
  1. «I tuoi clienti sono al sicuro» · «Messi da parte, intatti: qui non compaiono e non si possono cercare.»
  2. «Niente si mescola» · «Il backup e la copia per iPhone e iPad restano fermi: i dati di prova non finiscono tra
     quelli veri.»
  3. «Si esce con un clic» · «Tutto torna com’era, senza niente da ripulire.»
- due pulsanti grandi: **«Esci dalla dimostrazione»** (principale) e «Resta»; in alto a destra la ✕.

«Esci dalla dimostrazione» spegne la dimostrazione, chiude la scheda, mostra l'avviso «Fine della dimostrazione: nell’app
qui tornano i tuoi clienti, com’erano» e ridisegna l'app aperta. «Resta» e la ✕ chiudono e basta.

**Le scritte sparse spariscono**: con la dimostrazione accesa il sottotitolo di Mercato perde « · valori di prova»
(riga 4216) e, dice la regola, spariscono tutte le scritte «dati di prova» sparse (Studio, Messaggi, Mercato,
prospetti…): basta l'etichetta nella barra.

**Le altre voci della vecchia «Strumenti»** («Confronta i modelli», «Voce e ascolto», «Prova un promemoria») vanno nelle
sezioni Vera e Promemoria e occasioni (regola, righe 2776-2777).

Il pannello «✦ Migliorie» (MIG6, riga 4269) apre Impostazioni › Dimostrazione e indica l'etichetta: è solo del
template, nell'app non si porta.

### 37.2 Nell'app oggi

- **Non esiste una dimostrazione separata dal lavoro vero.** I clienti di prova vivono nello stesso archivio dei clienti
  veri, riconosciuti per id: `StatoShell.clientiDiProva` e `haDatiDiProva` (Shell/StatoShell.swift:3540-3541; i 5 del
  template da `DatiDemo.clienti()` più i 30 di `ClientiFittizi.ids`).
- **Al primo avvio** l'archivio nasce già con i dati di prova: `Archivio` scrive `DatiPrisma.demo()` quando la cartella
  è vuota (Dati/Archivio.swift:300 e 511).
- **Impostazioni › Strumenti** (`SchedaImpostazioni.strumenti`, StatoShell.swift:3943; titolo «Strumenti», a parte in
  fondo alla colonna: `preferenze` riga 3973) ha il gruppo «Dati di prova» (Shell/AppImpostazioni.swift:540-569): «Togli
  i clienti di prova» (solo se ce ne sono), «I 5 clienti di prova» · «Ripristina», «35 clienti di prova completi» ·
  «Carica», con le conferme (AppImpostazioni.swift:49-61); poi «Vera» (`rigaConfrontaModelli`), `GruppoVelocita`
  (MisuraVelocita), «Promemoria» › «Prova un promemoria», «Parlare con Vera» › «Voce e ascolto».
- **Caricare o togliere** sostituisce l'archivio vero, sempre dopo un backup: `ripristinaDatiDiProva(completi:)`
  (StatoShell.swift:3771) carica `DatiPrisma.demo()` o `ClientiFittizi.completi()` con le impostazioni dell'utente, più
  i fac-simile di Biblioteca e Moduli (`caricaEsempiBiblioteca`, `caricaEsempiModuli`, che scrivono file accanto
  all'archivio) e il giro di prova del Territorio; `togliDatiDiProva()` (riga 3545) e `rimuoviDatiDiProva()` (riga 3723)
  tolgono tutto ciò che è di prova (clienti, prodotti d'esempio, Biblioteca, spese, moduli, Territorio, potenziali, note
  vocali, notti, sinistri, capsule).
- **La guida «Comincia con i tuoi dati»** (Shell/GuidaInizio.swift:22-46) ha il passo «Togli i clienti di prova»
  (`.togliProva`, porta a Impostazioni › Strumenti, riga 66).
- **Le scritte «dati di prova» sparse** dipendono da `stato.haDatiDiProva` (spesso con `clientiDiProva.contains(id)`):
  StudioCruscotto.swift:28, StudioScrivania.swift:56, StudioParcelle.swift:267, StudioTrackRecord.swift:288,
  StoriaLuce.swift:78, SalaLettera.swift:189, SalaLanciaAnno.swift:30 e 179, SalaPrismaCliente.swift:227,
  SalaValoreConsulente.swift:145, PannelloMessaggio.swift:285, DossierLineaVita.swift:351,
  PannelloTraguardo.swift:123, DossierApple.swift:214. Altre dipendono dalla nota o dal prefisso del singolo dato:
  PraticheDopoFirma.swift:125, PraticheComuniApple.swift:141, SalaGiornataPensione.swift:106,
  PannelloTerritorio.swift:667, MappaTerritorio.swift:737, PaginePrismaCliente.swift:70, SmontaggioApple.swift:66,
  DettaglioDocumento.swift:215, FamiglieComeLaSua.swift:100; i testi `TestiStudio.datiDiProva` (StudioApp.swift:90),
  StudioSpese.swift:27, StudioEsameOCF.swift:34. Mercato ha una condizione sua: «· valori di prova» nell'occhiello
  (`occhielloMercato`, Shell/StatoMercato.swift:70-74) viene da `mercatoDiProva` (riga 63: una serie con la fonte
  `MercatoDiProva.fonte`), non da `haDatiDiProva`. Altre costanti «dati di prova» nei motori: TestiPassaparola.swift:15,
  MotoreTraguardi.swift:319, TestiSinistri.swift:32. In tutto le scritte «di prova» toccano un centinaio di file: la lista
  qui sopra è il punto di partenza, il grep `grep -rn "di prova" Sources/Prisma/Shell Sources/Prisma/Motori` la chiude.
- **Le guardie che già fermano le scritture su disco** sono quelle di `solaLettura` (archivio di una versione più nuova,
  StatoShell.swift:523): circa 550 punti, ma la maggior parte disattiva anche la **modifica** nelle viste (che in
  dimostrazione deve restare). Quelle che toccano i file sono poche e vanno riusate: `rimuoviFile` (riga 1462),
  `pulisciDocumentiOrfani` e `pulisciDocumentiOrfaniInBackground` (righe 1473-1500, la seconda parte da sola 5 s dopo
  l'avvio, riga 676-680), le copie e le cancellazioni di Biblioteca, Moduli, Scontrini e Attestati.
- **Fuori dall'archivio ma con dati veri**: la memoria di Vera (`StatoMemoriaVera`, file cifrato con ricordi e lezioni, che
  possono nominare clienti veri) e la cache dei vettori della ricerca (`IndiceVera`, Vera/RicercaVera.swift:162,
  ~/Library/Caches/Prisma/vettori-vera.cifrato: chiavi per id del pezzo, quindi i clienti veri non escono nella ricerca
  se non sono nei dati, ma la cache si riscrive).
- **Nella barra** (Shell/BarraSuperiore.swift:13) non c'è nessuna etichetta della dimostrazione.
- Esiste già un modo di non scrivere l'archivio: `salvataggioSospeso` (StatoShell.swift:518, letto da `salvaOra` e
  `scrivi`, righe 3204-3219), e la riapertura dell'archivio dal disco dopo un ripristino (`ripristina`, riga 3427:
  `dati.carica(d)`, poi `memoriaVera.ricarica()`, `biblioteca.ricarica()`, `moduli.ricarica()`).

### 37.3 Cosa fare

**A. Il modo «dimostrazione» nello stato** (nuovo file Shell/StatoDimostrazione.swift, estensione di `StatoShell`):

1. `private(set) var inDimostrazione = false` e `var gruppoProva` **nel corpo della classe** in Shell/StatoShell.swift
   (un'estensione in un altro file non può avere proprietà salvate; osservate: la barra e le Impostazioni le leggono),
   `enum GruppoProva { case cinque, trentacinque }` nel file nuovo. `azzeraNote()` (StatoShell.swift:1148) e
   `salvataggioSospeso` (riga 518) sono `private`: o le funzioni che li usano stanno in StatoShell.swift, o diventano
   interne. Tutto solo sul Mac (`#if os(macOS)`): su iPhone e iPad `inDimostrazione` resta sempre falso.
2. `func accendiDimostrazione(_ gruppo: GruppoProva)`:
   - `salvaOra()` (l'archivio vero è sul disco, intero), poi `inDimostrazione = true` **prima** di toccare i dati;
   - costruisce i dati di prova in memoria come fa oggi `ripristinaDatiDiProva` (`DatiPrisma.demo()` o
     `ClientiFittizi.completi()`, il giro di prova del Territorio con `TerritorioDiProva.applica`), tenendo delle
     impostazioni dell'utente **l'aspetto** (aspetto, testo, acqua, movimento, nomi dei canali della 38) e **il motore e
     il ponte di Vera** (`impostazioni.vera`: indirizzo e modello di Qwen, `ponte.condividi` e `ponte.codice`; se si
     azzerassero, `ServerPonteVera.condiviso.aggiorna` (StatoShell.swift:788) spegnerebbe il ponte o cambierebbe codice, e
     Vera non risponderebbe); non quelle che portano dati (backup, ovunque, notte, studio, stile di Vera, mercato, PDF);
   - `dati.carica(demo)`, `azzeraNote()`; niente `caricaEsempiBiblioteca`/`caricaEsempiModuli` (scrivono file: vedi D);
   - chiude il dettaglio aperto e le finestre che mostrano un cliente vero (stessa pulizia di `ripristina`).
   Niente backup prima: l'archivio vero non viene toccato, quindi non serve.
3. `func spegniDimostrazione()`: rilegge l'archivio dal disco con la stessa strada di `ripristina` dopo la sostituzione
   (lettura dell'archivio a pezzi, `dati.carica(d)`, `memoriaVera.ricarica()`, `biblioteca.ricarica()`,
   `moduli.ricarica()`), poi `inDimostrazione = false`. Tutto ciò che è stato fatto in dimostrazione si perde: è il
   «senza niente da ripulire» del template.
4. **Cosa si ferma con la dimostrazione accesa** (un `guard !inDimostrazione` in ognuno, con un commento che rimanda qui):
   - `scrivi()` e `salvaOra()` (StatoShell.swift:3204-3219): nessun salvataggio sull'archivio vero;
   - backup automatico (`controllaBackupAutomatico`, riga 3852) e manuale («Crea backup» disattivato con la nota «Durante
     la dimostrazione il backup è fermo»), ripristino, importazioni (`importaClienti`, `importaPosizioni`,
     `dopoUnBackup`), `ripristinaDatiDiProva`, `togliDatiDiProva`;
   - «Prisma ovunque»: `sincronizzaOvunque` (StatoOvunque.swift:438) e l'unione dei giornali: l'istantanea non si scrive
     con i dati di prova e le modifiche arrivate dall'iPhone non si applicano ai dati di prova (restano nei giornali e si
     uniscono quando la dimostrazione si spegne);
   - «Stanotte» (StatoNotteShell.swift), le routine, il tagliando notturno: non preparano carte sui clienti di prova;
   - i promemoria del Mac (PromemoriaMac.swift): non si ripianificano con i dati di prova (altrimenti sparirebbero quelli
     veri e arriverebbero notifiche di clienti inventati); restano quelli pianificati prima;
   - i file accanto all'archivio: aggiungere un documento, uno scontrino, un attestato, un PDF in Biblioteca o un modulo
     non si può (pulsanti disattivati con l'aiuto «Non durante la dimostrazione»); le copie da condividere
     (`CartellaUscite`) restano permesse, perché vanno nella cartella temporanea e si cancellano.
   - **soprattutto le cancellazioni e le pulizie dei file** (il rischio più grave: con i soli dati di prova in memoria,
     i file dei clienti veri sembrano «orfani»): `pulisciDocumentiOrfani`/`pulisciDocumentiOrfaniInBackground`,
     `rimuoviFile`, la rimozione degli scontrini e degli attestati non più usati (StatoSpese.swift:101), le pulizie di
     Biblioteca e Moduli. Il modo più sicuro: una sola proprietà `var scrittureFerme: Bool { solaLettura ||
     inDimostrazione }` usata **solo** nelle guardie che toccano il disco (salvataggi, backup, file), lasciando le
     guardie di `solaLettura` che disattivano la modifica nelle viste come sono;
   - la memoria di Vera (`StatoMemoriaVera`): in dimostrazione non si legge (ricordi e lezioni possono nominare clienti
     veri) e non si scrive; la cache dei vettori (`IndiceVera`) non si salva.
   - Il ponte di Vera e il tavolo restano accesi: servono proprio per far vedere Prisma. Le inquadrature, le carte
     d'identità e ciò che arriva dal tavolo entrano nei dati in memoria e se ne vanno con la dimostrazione; le note
     dettate invece si rifiutano, così restano nella coda dell'iPhone (37.6, decisione 4).
5. **Una sola condizione per le scritte sparse**: `var scritteProva: Bool { haDatiDiProva && !inDimostrazione &&
   !inModoCliente }` in StatoShell, tenuta con `stato.ricavato("scritteProva") { … }` (oggi `haDatiDiProva` scorre tutti
   i clienti in ogni body che la legge). Tutti i punti elencati in 37.2 che leggono `haDatiDiProva` leggono
   `scritteProva`; quelli che guardano la nota o il prefisso aggiungono `&& !stato.inDimostrazione`. Così, con la
   dimostrazione accesa, non compare più nessuna scritta «dati di prova»; spenta, i clienti di prova rimasti
   nell'archivio di chi li ha ancora mescolati continuano a dirlo, come oggi.

**B. L'etichetta nella barra** (Shell/BarraSuperiore.swift):

6. `EtichettaDimostrazione` (nuova vista in DesignSystem/Apple/ChipBarraApple.swift, accanto alle pillole della barra):
   vetro della barra come le altre pillole, testo «Dimostrazione». Token nuovi in **Tema.Apple+BloccoBarraNotifiche.swift**
   (enum `Tema.Apple.BarraAlta`, riga 66, dove stanno le misure della barra) o in un nuovo **Tema.Apple+Dimostrazione.swift**:
   `Tema.Apple.Dimostrazione.testo` = `Tema.Apple.Colore.arancioTesto` (**esiste già**, Tema.Apple+Ovunque.swift:11,
   #B45309 / #F5A84B; il gruppo 01, miglioria 7, lo ritocca a #B4530B / #F5A94A e non deve crearne un secondo),
   `Tema.Apple.Dimostrazione.filo` = `Tema.Apple.Colore.arancio` (#E08A00, esiste già) all'opacità 0,4,
   `Tema.Apple.Dimostrazione.carattere` = il carattere delle pillole della barra in grassetto. Nessun colore scritto
   nella vista.
7. Si mostra se `stato.inDimostrazione && !stato.inModoCliente` (e non nella vista pulita della miglioria 1), subito dopo
   la pillola del cliente (gruppo 01) o, se non c'è ancora, dopo `appCorrente`. Entra con la dissolvenza del tema
   (`Tema.Apple.Moto`), ferma con «Riduci movimento».
8. Al clic apre la scheda **«Stai mostrando Prisma con i clienti di prova.»** (`SchedaDimostrazione`, nuova, in
   StatoDimostrazione.swift o in un file di vista accanto): occhiello, titolo, le tre righe con la spunta verde e i
   pulsanti esattamente come in 37.1, con la presentazione delle schede leggere già usata dalle app (`.sheet` del tema,
   come le schede del gruppo 04). «Esci dalla dimostrazione» chiama `spegniDimostrazione()` e mostra l'avviso «Fine della
   dimostrazione: tornano i tuoi clienti, com’erano» (il «nell’app qui» del template è una nota del template: si toglie).

**C. Impostazioni › Dimostrazione** (Shell/AppImpostazioni.swift):

9. `SchedaImpostazioni.strumenti` diventa `.dimostrazione` (titolo «Dimostrazione»; il valore grezzo si può lasciare
   «strumenti» se viene salvato da qualche parte, altrimenti rinominare). Nella colonna va nel gruppo «Aiuto» della
   miglioria 30; finché la 30 non c'è, resta in fondo dove sta oggi.
10. La pagina: `NotaImpostazioni`/introduzione «Per far vedere Prisma a un cliente curioso, a un collega o a chi la vuole
    comprare, senza mostrare il tuo lavoro.»; `RigaImpostazione(titolo: "Dimostrazione", sottotitolo: "Prisma mostra solo
    i clienti di prova: i tuoi restano da parte, intatti.")` con `interruttore`; gruppo «I clienti di prova» con
    «Cinque clienti» · «Pochi, per spiegare con calma.» e «Trentacinque clienti» · «Prisma piena: Vera, il territorio,
    lo Studio.»: quello in uso mostra la pillola «In uso» (tono ok), l'altro il pulsante «Usa questi» (con la
    dimostrazione accesa ricarica subito l'altro gruppo; spenta, sceglie quale gruppo userà la prossima volta).
11. Accanto alla voce nella colonna, con la dimostrazione accesa, la scritta piccola «accesa» (lo stesso stato a destra
    della voce della miglioria 31).
12. Avvisi: «Dimostrazione accesa: i tuoi clienti sono da parte» / «Dimostrazione spenta» (`mostraAvviso`).
13. **Le altre voci di Strumenti** si spostano: «Confronta i modelli» e «Voce e ascolto» in Impostazioni › Vera (in
    fondo, chiuse come oggi), `GruppoVelocita` in Vera (è la misura dei tempi di Vera e della fluidità: resta con la sua
    `.id(MisuraVelocita.ancora)`), «Prova un promemoria» in Promemoria e occasioni.
14. **«Togli i clienti di prova»** (per chi ha ancora i clienti di prova mescolati nell'archivio vero, come forse
    l'utente oggi) si sposta in Impostazioni › Archivio e backup, visibile solo se `haDatiDiProva && !inDimostrazione`,
    con lo stesso `togliDatiDiProva()` e lo stesso backup prima. È la sola pulizia rimasta.
15. «I 5 clienti di prova · Ripristina» e «35 clienti di prova completi · Carica», che oggi **sostituiscono** l'archivio
    vero, spariscono: il loro posto è la dimostrazione. `ripristinaDatiDiProva` resta solo per le prove e le istantanee
    (o diventa la base di `accendiDimostrazione`).
16. Guida «Comincia con i tuoi dati» (GuidaInizio.swift): il passo «Togli i clienti di prova» porta ad Archivio e backup
    (`.togliProva`, riga 66) e c'è solo se `haDatiDiProva && !inDimostrazione`; con la dimostrazione accesa la guida non
    si mostra (`guidaVisibile`, riga 49).
17. Il messaggio dopo l'importazione (StatoShell.swift:3606, «I clienti di prova si tolgono da Impostazioni → Archivio»)
    resta, ed è finalmente vero.
18. «Panoramica» della guida (GuidaPrisma.swift:240, «Profilo, backup, aspetto, dati di prova»): «dati di prova» →
    «dimostrazione».

**D. Il primo avvio** (lega con la 38): `Archivio` non scrive più `DatiPrisma.demo()` in una cartella vuota
(Archivio.swift:300 e 511), ma un archivio vuoto (`DatiPrisma` senza clienti, con le impostazioni di base); la scelta
«Guardo Prisma con i clienti di prova» della terza domanda accende la dimostrazione. Il caso «archivio mancante ma
cartella con documenti» (riga 298) resta in sola lettura come oggi. Le prove e le istantanee non persistenti continuano a
partire da `DatiPrisma.demo()` (StatoShell.swift:573).

**Da NON fare**: non tenere due archivi in memoria (i dati veri restano sul disco); non scrivere i dati di prova in una
seconda cartella dell'archivio (vedi 37.6); non portare le cifre e i nomi dimostrativi del template; non portare il
pannello «✦ Migliorie».

### 37.4 Dati, archivio, privacy

- **Nessun campo nuovo in `DatiPrisma`.** L'unica cosa da ricordare è se la dimostrazione era accesa alla chiusura e
  quale gruppo era in uso: proposta, nelle preferenze del Mac (`UserDefaults`, chiavi `Prisma.dimostrazione` e
  `Prisma.dimostrazioneGruppo`), **fuori dall'archivio, dai backup e da «Prisma ovunque»**: un ripristino non deve far
  ripartire una dimostrazione, e il telefono non deve saperne nulla. Riaprendo Prisma con la dimostrazione accesa si
  legge l'archivio vero (serve per la schermata di benvenuto e lo sblocco) e subito dopo lo sblocco si ricaricano i dati
  di prova (vedi 37.6).
- **Privacy, a favore**: con la dimostrazione accesa nessun dato vero è in memoria nei dati osservati, quindi non compare
  nella ricerca, in Vera, nel ponte o sul tavolo. È la garanzia scritta nella scheda («qui non compaiono e non si
  possono cercare»): va verificata con una prova (37.5).
- **Backup**: fermi durante la dimostrazione (la scheda lo promette). La prova `--prova-backup` deve controllare che
  nessun salvataggio né backup parta con la dimostrazione accesa e che, spenta, l'archivio sia identico a prima.
- **«Prisma ovunque»**: fermo (la scheda lo promette). I giornali dei dispositivi si uniscono solo a dimostrazione spenta.
  La prova `--prova-ovunque` va estesa con questo caso.
- Le preferenze di Vera, le carte della notte, i promemoria del Mac e le conversazioni di Vera fatte in dimostrazione non
  si salvano.

### 37.5 Istantanee e prove

Istantanee nuove (Sources/Prisma/Istantanee.swift o un nuovo IstantaneeDimostrazione.swift, intervallo 1060):
- `1060-uso-dimostrazione-barra` e `-scuro`: scrivania con la dimostrazione accesa (l'etichetta dopo la pillola del
  cliente).
- `1061-uso-dimostrazione-scheda`: la scheda aperta dall'etichetta.
- `1062-uso-impostazioni-dimostrazione` e `-scuro`: Impostazioni › Dimostrazione accesa, con «Trentacinque clienti · In
  uso».
- `1063-uso-studio-senza-scritte-prova`: il Cruscotto dello Studio con la dimostrazione accesa, senza «dati di prova».

Da aggiornare: `85-impostazioni-strumenti`, `86-impostazioni-velocita` e `-scuro` (Istantanee.swift:344-365: la sezione
cambia nome e le righe si spostano in Vera e Promemoria); le scene che mostrano oggi «dati di prova» nello Studio, in
Messaggi e nella Sala restano uguali (non accendono la dimostrazione) — verificare che non cambino.

Prove:
- `--prova-backup`: nuova `ProvaBackupDimostrazione` (Dati/): accendere, modificare i dati, spegnere → l'archivio sul
  disco e la sua generazione sono quelli di prima; nessun backup creato; nessun file tolto dalla cartella Documenti
  (con la dimostrazione accesa `pulisciDocumentiOrfani` restituisce 0 ed eliminare un documento non cancella file);
  `rimuoviDatiDiProva` ancora corretto.
- `--prova-ovunque`: con la dimostrazione accesa `sincronizzaOvunque` non scrive l'istantanea e non unisce i giornali.
- `--prova-vera` (ProvaVera.swift:178-185, la guida): i passi e `guidaVisibile` con la dimostrazione accesa.
- Una prova (in `--prova-calcoli` o nella prova di Vera) che, a dimostrazione accesa, la ricerca e il contesto di Vera
  non contengano nessun id di cliente vero.

### 37.6 Decisioni per l'utente e rischi

1. **Dove vivono i dati di prova mentre la dimostrazione è accesa.** Proposta: solo in memoria, rifatti ogni volta da
   `DatiPrisma.demo()`/`ClientiFittizi.completi()`; quello che si fa in dimostrazione si perde allo spegnimento.
   Alternativa: una seconda cartella `Dimostrazione/` accanto all'archivio, che terrebbe le modifiche ma obbliga a
   rendere variabile `Archivio.cartella` (usata in molti punti: Documenti, Studio, Biblioteca, Moduli, Vera) — molto più
   rischiosa.
2. **Riaprendo Prisma con la dimostrazione accesa**: proposta, riparte accesa (preferenza del Mac), così un nuovo utente
   che ha scelto «Guardo Prisma con i clienti di prova» la ritrova. Alternativa più prudente: si riapre sempre spenta.
3. **Biblioteca e Moduli** durante la dimostrazione: proposta, si vedono quelli dell'utente (sono documenti di prodotto,
   non dati dei clienti) in sola lettura, senza i fac-simile di prova. Alternativa: nasconderli.
4. **Ponte e tavolo** durante la dimostrazione: proposta, accesi (servono per far vedere Prisma); quello che arriva
   dall'iPhone se ne va con la dimostrazione. Una nota dettata sul telefono durante la dimostrazione andrebbe persa:
   proposta, finché la dimostrazione è accesa il Mac risponde alle note con «rifiutata» (`RicevutaPonte`), così restano
   nella coda cifrata dell'iPhone e arrivano dopo.
5. **Primo avvio senza dati di prova nell'archivio** (37.3 D): cambia il comportamento di oggi per chi installa da zero.
   Per l'utente non cambia nulla (l'archivio c'è già). Proposta: sì.
6. **L'archivio dell'utente** ha forse ancora clienti di prova mescolati: proposta, nessuna pulizia automatica; resta
   «Togli i clienti di prova» in Archivio e backup.
7. **Le impostazioni cambiate durante la dimostrazione** (aspetto, nomi dei canali, Vera): con la proposta 1 si
   perderebbero allo spegnimento. Proposta: allo spegnimento si riportano nell'archivio vero solo i campi tenuti al punto
   A.2 (aspetto, nomi dei canali, `impostazioni.vera`), poi un salvataggio; tutto il resto si perde.
- Rischi: dimenticare un punto che scrive su disco, cancella file o pianifica qualcosa (salvataggi, pulizia dei
  documenti orfani, giornali, promemoria, notte, routine, tagliando, Spotlight se c'è): per questo la prova del backup confronta l'archivio prima e dopo. Lo
  spegnimento rilegge l'archivio dal disco: deve passare dalla stessa strada (asincrona) dell'avvio a due tempi, senza
  bloccare il thread principale. Memoria: invariata (un solo archivio in memoria per volta).

### 37.7 Dimensione

**L** (oltre 500 righe tra stato, guardie, Impostazioni, barra, scheda, una ventina di punti con le scritte di prova,
prove). File principali: Shell/StatoDimostrazione.swift (nuovo), Shell/StatoShell.swift, Shell/AppImpostazioni.swift,
Shell/BarraSuperiore.swift, DesignSystem/Apple/ChipBarraApple.swift, Shell/StatoOvunque.swift, Dati/Archivio.swift,
Shell/GuidaInizio.swift, Dati/ProvaBackupDimostrazione.swift (nuovo).

---

## 38. I canali hanno il nome che scegli

### 38.1 Nel template

Regola 38 (righe 2778-2784), codice righe 4229-4251, CSS righe 653-660.

**Il nome dei canali** (`nomiCh`, riga 4232): di base «Alleanza» e «Indipendente». `pulisciNome` (riga 4233) toglie
`< > & "`, gli spazi ai lati e tiene al più **18 caratteri**; un nome vuoto torna al nome di base. `canaliNomi` (riga
4234) cambia **subito, mentre si scrive**, tutte le etichette dei canali aperte (`.chA`, `.chI`). I colori restano blu e
cuoio.

**Il campo** (`campoCh`, riga 4235): pallino 12 del colore del canale, campo di testo (`.impIn`: largo 150, alto 32,
raggio 9, filo, fondo della carta, testo 13,5 grassetto 600; al fuoco l'anello blu al 35%), `maxlength` 18, senza
correzione, e a destra l'etichetta del canale com'è adesso.

**Impostazioni › Profilo** (`IMPS.profilo`, righe 4236-4240), gruppo «Prisma»:
- la scheda del consulente (avatar «DV» 60, nome 19 grassetto, «Consulente finanziario»);
- occhiello **«I tuoi canali»**, testo «Li hai scelti al primo avvio. Ogni posizione e ogni proposta porta l’etichetta
  del suo canale: qui cambi il nome, i colori restano questi.»;
- riga «Il primo canale» · «Blu, sempre.» con il campo; riga «Il secondo canale» · «Cuoio, sempre.» con il campo;
- occhiello **«Il primo avvio»**, riga «Le tre domande della prima volta» · «Benvenuto, i tuoi canali, da dove parti.»
  con il pulsante **«Rivedi»**, che riapre le tre domande dalla prima.
Le voci per la ricerca (riga 4236): «I tuoi canali» · «I nomi scritti sulle due etichette.»; «Il primo avvio» · «Le tre
domande della prima volta.».

**Le tre domande del primo avvio** (`apriAvvio`/`avvioDisegna`, righe 4241-4256), in una scheda larga 640, alta almeno
300, al posto della guida a pagine:
1. **«Il primo avvio · 1 di 3»** — logo di Prisma 54 a sinistra (bianco sullo scuro), titolo (28, grassetto, `.avT`)
   «Benvenuto in Prisma», testo (15, `.avS`) «Prisma è lo studio di lavoro di un consulente finanziario. Raccoglie le
   persone che segui e quello che hanno, e ti aiuta a capire che cosa manca e che cosa conviene.», poi tre punti con il
   pallino blu 7: «I calcoli li fa Prisma: tu scegli e spieghi.», «Tutto resta su questo Mac: niente internet, niente
   cloud.», «Tre domande, e poi si comincia.».
2. **«Il primo avvio · 2 di 3»** — «I tuoi canali»; testo «Con quali etichette lavori? Prisma le tiene sempre distinte,
   una blu e una cuoio. Scrivi i nomi come li dici tu.»; una scheda con due righe «Il primo canale» e «Il secondo
   canale», ognuna con il campo (l'etichetta a destra cambia mentre si scrive); sotto «Li cambi quando vuoi, in
   Impostazioni › Profilo.».
3. **«Il primo avvio · 3 di 3»** — «Da dove parti»; testo «Puoi cambiare idea dopo: niente di questo è definitivo.»; tre
   opzioni (`.avO`: riquadri raggio 16, cerchio di scelta 20 a sinistra; la scelta ha il filo blu):
   - «Guardo Prisma con i clienti di prova» · «È la dimostrazione: niente di tuo, niente che esce dal Mac.» (scelta di
     base)
   - «Porto i miei clienti» · «Importo un elenco o incollo da Excel.»
   - «Parto da zero» · «Aggiungo il primo cliente a mano.»

In basso: i tre punti delle pagine (quello attuale lungo 18, gli altri 7, blu e grigio, con transizione), a destra
«Indietro» (dalla seconda pagina) e il pulsante principale «Avanti», che all'ultima pagina diventa «✓ Comincia». Al
cambio di pagina il contenuto entra da destra (14 pt, 320 ms, curva del tema), fermo con «Riduci movimento».

«Comincia» chiude la scheda e accende la dimostrazione se la scelta è la prima (avviso «Si comincia con la
dimostrazione»); con le altre due il template mostra «Nel template i dati restano di prova: nell’app qui si parte dai tuoi
clienti» (nota del template).

**Dove vale il nome**: «ovunque compare il canale: etichette, filtri, Studio, prospetti. I colori non cambiano mai. Per
Denis restano «Alleanza» e «Indipendente» (nei PDF, «Alleanza Assicurazioni» e «Denis Vicenzoni · Consulenza
finanziaria»). Le pagine «Le app» e «Le parole» della guida restano nel «?».» (righe 2782-2784).

Il pannello «✦ Migliorie» (MIG6, riga 4270) è solo del template.

### 38.2 Nell'app oggi

- **Il nome dei canali è fisso nel codice**: `Canale.nome` («Alleanza Assicurazioni», «Denis Vicenzoni · Consulenza
  finanziaria») e `Canale.nomeBreve` («Alleanza», «Indipendente») in Dati/Modelli.swift:10-22. `nomeBreve` è usato in
  circa 180 punti (motori, Vera, Studio, notifiche, ricerca, prospetti, iOS); in più ci sono scritte fisse con «Alleanza» nei
  testi delle viste (per esempio Studio: «Le tue aliquote Alleanza», «Produzione Alleanza»).
- **Le etichette**: `EtichettaCanale` (DesignSystem/Componenti.swift:775), `EtichettaCanaleApple`
  (DesignSystem/Apple/PulsantiApple.swift:137: Alleanza sempre «Alleanza» con il logo, indipendente con la firma completa
  o «Indipendente» nella compatta), `EtichettaCanaleStampa` (Componenti.swift:794, sui PDF, logo Alleanza),
  `EtichettaCanaleDaScegliere` (Shell/DossierApple.swift:844).
- **Impostazioni › Profilo** (`profilo`, Shell/AppImpostazioni.swift:363): scheda del consulente, «Il tuo nome» (con
  `TestoRinviato`), gruppo «Canali» con due righe fisse «Alleanza Assicurazioni» · «Solo prodotti Alleanza» e
  «Consulenza indipendente» · «Investimenti, risparmio, previdenza, protezione», ognuna con `EtichettaCanale`. Non si
  cambia nulla.
- **Il primo avvio** è l'introduzione in 5 pagine `IntroduzionePrisma` (Shell/PannelloGuida.swift:98, testi in
  `PaginaIntroduzione.pagine`, Shell/GuidaPrisma.swift:262), aperta da `dopoSblocco()` (GuidaPrisma.swift:347) finché
  `Impostazioni.introduzioneVista` è falso (Dati/DatiPrisma.swift:490); la pagina 1 dice già «Benvenuto in Prisma» con
  gli stessi primi due punti del template. Resta nel pannello della guida come scheda «Come funziona» (`SchedaGuida`,
  GuidaPrisma.swift:27). Non c'è nessuna domanda: né i canali né «da dove parti». L'introduzione si apre anche da
  Impostazioni › Aspetto, gruppo «Aiuto», riga «Come funziona Prisma» · «L'introduzione e le parole della finanza.» con
  «Apri» (Shell/AppImpostazioni.swift:487-489) e dal menu Aiuto «Come funziona Prisma (introduzione)»
  (PrismaApp.swift:168). `dopoSblocco()`, `PannelloGuida` e `IntroduzionePrisma` sono **condivisi con iPhone e iPad**
  (StatoShellFinestre.swift:545, iOS/PannelliMobile.swift:57).
- **Esistono già**: `PuntiPagine` (DesignSystem/ComponentiGuida.swift:258), `LogoPrisma` (DesignSystem/LogoPrisma.swift:119,
  bianco sullo scuro), `importaClientiDaFile()` (GuidaInizio.swift:92), `incollaDaExcel(posizioni:)` (nel menu «…» della
  Rubrica, Shell/ContenutoApp.swift:141-149) e `apriNuovoCliente()` (AppClienti.swift:166).
- **Le tre domande, il campo dei nomi e «Rivedi» non esistono.**

### 38.3 Cosa fare

**A. Il nome dei canali, in un posto solo**

1. `struct NomiCanali: Codable, Equatable { var primo: String; var secondo: String }` in Dati/Modelli.swift, con
   `static let base = NomiCanali(primo: "Alleanza", secondo: "Indipendente")`, `static func pulisci(_:) -> String`
   (toglie `< > & "` e i caratteri di controllo, gli spazi ai lati, al più 18 caratteri) e `var personalizzati: Bool`.
2. `Impostazioni.nomiCanali: NomiCanali?` (nil = base), letto con tolleranza (vedi 38.4).
3. I motori, Vera e le viste leggono `Canale.nomeBreve` anche fuori dal thread principale: il nome corrente sta in un
   valore statico protetto (`enum NomiCanaliCorrenti { static var valore: NomiCanali }` con `OSAllocatedUnfairLock`,
   disponibile da macOS 13), aggiornato da `StatoShell` quando le impostazioni cambiano (al caricamento, a ogni modifica
   del campo, alla fine della dimostrazione, al ripristino). `Canale.nomeBreve` legge da lì. L'aggiornamento si fa solo
   sul Mac (`#if os(macOS)`): su iPhone e iPad il valore resta quello di base anche se il campo arriva con «Prisma
   ovunque», finché non si fa il loro giro.
4. `Canale.nome` (la scritta lunga dei PDF e dell'etichetta estesa): con i nomi di base resta «Alleanza Assicurazioni» e
   «Denis Vicenzoni · Consulenza finanziaria» (regola di CLAUDE.md); con un nome personalizzato è il nome scelto.
5. **Il logo Alleanza** sull'etichetta (vetro e stampa) solo se il primo nome è quello di base; altrimenti il pallino blu,
   come nella versione compatta. I colori dei due canali non cambiano mai.
6. Le scritte fisse con «Alleanza»/«Indipendente» nelle viste, nei filtri, nello Studio e nei prospetti: trovarle con
   `grep -rn '"[^"]*Alleanza[^"]*"' Sources/Prisma/Shell Sources/Prisma/Motori` e sostituirle con
   `Canale.alleanza.nomeBreve`/`Canale.indipendente.nomeBreve` dove parlano dell'etichetta del canale. **Restano** i nomi
   propri che non sono il canale: i documenti di Alleanza in Impostazioni › Proposte e PDF («Allegato 3», «Allegato
   4-ter»…), i prodotti del catalogo, il simbolo `Loghi/Alleanza_simbolo.png`, i valori salvati negli archivi (`alleanza`,
   `indipendente` come `rawValue`: non si toccano).
7. I prompt di Vera (cartella Vera/): dove dicono «Alleanza» come nome del canale, il contesto che Prisma passa a Vera usa
   già `nomeBreve` (ContestoVera.swift); nei file .md lasciare «Alleanza» e aggiungere che il canale si chiama come dice
   il contesto. Da verificare con `--prova-vera`.

**B. Impostazioni › Profilo** (Shell/AppImpostazioni.swift:363):

8. Sotto la scheda del consulente e «Il tuo nome», il gruppo **«I tuoi canali»** al posto di «Canali»: nota «Li hai
   scelti al primo avvio. Ogni posizione e ogni proposta porta l’etichetta del suo canale: qui cambi il nome, i colori
   restano questi.»; righe «Il primo canale» · «Blu, sempre.» e «Il secondo canale» · «Cuoio, sempre.», ognuna con
   `CampoNomeCanale` (nuovo componente in DesignSystem/Apple/ImpostazioniApple.swift: pallino del colore del canale, campo
   largo 150 e alto 32, etichetta del canale a destra che cambia mentre si scrive). Il campo scrive con `TestoRinviato`
   (il nome entra nei calcoli in cache e nei documenti: si salva a fine scrittura, regola della fluidità), ma
   l'etichetta accanto mostra la bozza subito.
9. Gruppo **«Il primo avvio»**: riga «Le tre domande della prima volta» · «Benvenuto, i tuoi canali, da dove parti.» con
   il pulsante «Rivedi» (riapre `PrimoAvvio` dalla prima pagina).
10. Token in **Tema.Apple+Impostazioni.swift**: `Tema.Apple.Impostazioni.CampoCanale.larghezza` (150), `.altezza` (32),
    `.raggio` (9), `.pallino` (12), `.carattere` (13,5 semibold), anello di fuoco = il blu dei comandi al 35%.

**C. Le tre domande** (nuovo file Shell/PrimoAvvio.swift, vista `PrimoAvvio` e stato `pagina`, `sceltaInizio`):

11. Presentazione come scheda centrale sopra la scrivania (la stessa presentazione delle schede leggere del tema), larga
    640, contenuto alto almeno 300. Testi esattamente come in 38.1 (il testo della pagina 1 è più corto di quello di
    `PaginaIntroduzione.pagine[0]`: senza «(polizze, investimenti, piani per la pensione)»); il logo è `LogoPrisma` a 54;
    i tre punti della pagina 1 riusano i primi due punti di `PaginaIntroduzione.pagine[0]` più «Tre domande, e poi si
    comincia.». La scelta della pagina 3 parte da «Guardo Prisma con i clienti di prova».
12. Pagina 2: due `CampoNomeCanale`; i nomi si salvano in `Impostazioni.nomiCanali` solo se diversi da quelli di base.
13. Pagina 3: tre opzioni (`OpzioneInizio`, componente nuovo in DesignSystem/Apple/ImpostazioniApple.swift o
    ControlliApple.swift: riquadro raggio 16, cerchio 20, filo blu sulla scelta, con `.accessibilityAddTraits(.isSelected)`).
14. In basso `PuntiPagine` (esiste già, PannelloGuida.swift:124, usato dall'introduzione), «Indietro» e «Avanti» /
    «Comincia». Frecce ← → e Invio come nell'introduzione di oggi (PannelloGuida.swift:149).
15. «Comincia»: segna `introduzioneVista = true` (stessa chiave di oggi: chi l'ha già vista non rivede le domande), poi:
    - «Guardo Prisma con i clienti di prova» → `accendiDimostrazione(.trentacinque)` (miglioria 37) e avviso «Si
      comincia con la dimostrazione»;
    - «Porto i miei clienti» → apre Clienti › Rubrica e `importaClientiDaFile()` (come il passo della guida,
      GuidaInizio.swift:61), con l'avviso «Puoi anche incollare da Excel: menu … della Rubrica» (`incollaDaExcel`
      esiste già);
    - «Parto da zero» → apre Clienti con `apriNuovoCliente()`.
    - Come nel template (`demo=avvioDa===0`), se le domande si rivedono con la dimostrazione accesa, «Porto i miei
      clienti» e «Parto da zero» la **spengono** (`spegniDimostrazione()`) prima di proseguire.
16. `dopoSblocco()` (GuidaPrisma.swift:352) apre `PrimoAvvio` al posto di `apriGuida(.introduzione(0))`, solo sul Mac
    (`#if os(macOS)`: iPhone e iPad tengono l'introduzione di oggi). Movimento: entrata
    da destra di 14 pt con `Tema.Apple.Moto` (ritmo 0,6), con «Riduci movimento» dissolvenza 0,15 s; nelle istantanee la
    pagina è già ferma.
17. **La guida**: le pagine «Le app» e «Le parole» restano nel «?». La scheda «Come funziona» (introduzione a 5 pagine):
    proposta in 38.6. Con la proposta, sul Mac: la riga «Come funziona Prisma» di Impostazioni › Aspetto
    (AppImpostazioni.swift:487) diventa «Le tre domande della prima volta» con «Rivedi» o si toglie (c'è già in Profilo),
    e la voce del menu Aiuto «Come funziona Prisma (introduzione)» (PrismaApp.swift:168) apre `PrimoAvvio`; iPhone e
    iPad restano come sono.

**Da NON fare**: non cambiare i colori o i `rawValue` dei canali; non chiedere i nomi all'utente che ha già l'archivio
(per lui restano quelli di base e le domande non ripartono); non portare l'avviso «Nel template i dati restano di
prova…».

### 38.4 Dati, archivio, privacy

- **Campo nuovo**: `Impostazioni.nomiCanali: NomiCanali?`, chiave `nomiCanali` nelle `CodingKeys` di `Impostazioni`
  (Dati/DatiPrisma.swift:580), letto con tolleranza (`decodeIfPresent`, nil se manca): gli archivi e i backup di prima si
  aprono con i nomi di base, senza alzare la versione. Posto in `ArchivioPezzi`: dentro `impostazioni`, quindi
  nell'indice (`indice.json`), nessun caso nuovo nello `switch`. Va nei backup.
- **`stessiCalcoli`** (DerivatiDati.swift:590): **non** escluderlo, perché i nomi entrano in testi tenuti in cache
  (notifiche, Vera, Studio); cambiare nome alza `versioneCalcoli`, una volta a fine scrittura.
- **«Prisma ovunque»**: le impostazioni viaggiano nell'istantanea e il Mac ne è l'unico scrittore; `nomiCanali` non va
  tra quelle che il dispositivo tiene sue (SpazioOvunque.swift:531-545): sul telefono i nomi arrivano dal Mac. L'uso sul
  telefono (etichette di iOS) è «dopo, con iPhone e iPad»; per ora basta che il campo arrivi.
- Privacy: nessun dato del cliente; il nome è un testo dell'utente, ripulito e corto.
- `introduzioneVista` resta la chiave di «le domande sono state fatte»: nessun campo nuovo per il primo avvio. La scelta
  di pagina 3 non si conserva.

### 38.5 Istantanee e prove

Istantanee nuove (intervallo 1060):
- `1064-uso-primo-avvio-benvenuto` e `-scuro`, `1065-uso-primo-avvio-canali` (con un nome scritto, per vedere
  l'etichetta cambiata), `1066-uso-primo-avvio-da-dove`.
- `1067-uso-impostazioni-profilo` e `-scuro`: Profilo con i due campi e «Rivedi».
- `1068-uso-canale-rinominato`: una scheda di Posizioni con i nomi personalizzati (etichetta senza logo, colori uguali).

Da aggiornare: `252-impostazioni-profilo` (Istantanee.swift:1058); `222-introduzione`, `223-introduzione-app`,
`224-introduzione-percorso`, `229-introduzione-schermo-basso`, `222-introduzione-scuro` (Istantanee.swift:1157-1170,
1391) secondo la decisione su «Come funziona»; le scene che mettono `introduzioneVista = false` (Istantanee.swift:1150,
1154, 1388) mostrano ora le tre domande.

Prove:
- `--prova-calcoli`: `NomiCanali.pulisci` (18 caratteri, caratteri tolti, vuoto → base); `Canale.nomeBreve` e
  `Canale.nome` con i nomi di base e personalizzati; la verifica «Guida: introduzione in 5 pagine»
  (Motori/ProvaCalcoli.swift:1347) da aggiornare se cambia l'introduzione; un controllo «tre domande, tre opzioni».
- `--prova-backup`: un archivio con `nomiCanali` va e torna dal backup; uno senza si apre con i nomi di base.
- `--prova-prospetti`: il PDF con i nomi di base scrive ancora «Alleanza Assicurazioni» e «Denis Vicenzoni · Consulenza
  finanziaria».
- `--prova-vera`: il contesto di Vera usa il nome scelto.

### 38.6 Decisioni per l'utente e rischi

1. **Rinominare i canali tocca una regola di CLAUDE.md** («Alleanza = etichetta in vetro blu con il logo Alleanza;
   indipendente = …"Denis Vicenzoni · Consulenza finanziaria"»). Proposta: la regola resta vera per l'utente (nomi di
   base, logo, firma); con un nome diverso l'etichetta perde il logo Alleanza e mostra il nome scelto, sempre nel suo
   colore. Va aggiornata la riga di CLAUDE.md quando la miglioria entra.
2. **Il nome nei PDF** con un nome personalizzato: proposta, il nome scelto anche sui documenti (con i nomi di base,
   le scritte lunghe di oggi).
3. **La scheda «Come funziona»** della guida (introduzione a 5 pagine): il template la toglie dal primo avvio e dice che
   nel «?» restano «Le app» e «Le parole». Proposta: togliere «Come funziona» dal pannello della guida (il menu Aiuto ›
   Guida di Prisma apre «Le app»); «Rivedi» in Profilo è il nuovo modo di rivedere l'inizio. Alternativa: tenerla come
   scheda in più.
4. **«Porto i miei clienti»** apre subito l'importazione o solo Clienti? Proposta: apre Clienti e il pannello «Importa…».
- Rischi: `Canale.nomeBreve` è letto in 154 punti, anche da motori fuori dal thread principale: il valore statico va
  protetto e aggiornato prima di alzare `versioneCalcoli`. Le scritte fisse da sostituire sono tante: farlo con il grep e
  guardare le istantanee chiare e scure.

### 38.7 Dimensione

**L** (il nome in un posto solo e le sostituzioni, il Profilo, le tre domande, le prove). File principali:
Dati/Modelli.swift, Dati/DatiPrisma.swift, DesignSystem/Apple/PulsantiApple.swift, DesignSystem/Componenti.swift,
DesignSystem/Apple/ImpostazioniApple.swift, DesignSystem/Apple/Tema.Apple+Impostazioni.swift, Shell/AppImpostazioni.swift,
Shell/PrimoAvvio.swift (nuovo), Shell/GuidaPrisma.swift, Shell/PannelloGuida.swift.

---

## 39. iPhone e iPad: un collegamento solo

### 39.1 Nel template

Regola 39 (righe 2785-2791), codice righe 4258-4265.

Impostazioni › **iPhone e iPad** (gruppo «Prisma»). La pagina della base (`ovunqueHTML`, riga 1647: titolo, schema Mac ·
iCloud Drive · iPhone e iPad con i punti che viaggiano, «Sincronizzato · 2 minuti fa», «Sincronizza ora», e il telefono
d'esempio a destra) resta; cambia la colonna sotto lo schema (riga 4260), che prima aveva «Copia cifrata su iPhone e
iPad», «Lavora anche con il Mac spento» e «Modifiche in attesa». Ora, in ordine:

1. Occhiello **«I tuoi dispositivi»**, una scheda (`#ovuDisp`) con una riga per dispositivo: nome in grassetto, quando è
   stato visto, a destra la pillola verde **«Collegato»** (nel template «iPhone di Denis» · «visto 2 minuti fa» e «iPad di
   Denis» · «sul tavolo oggi alle 09:30»). In fondo la riga «Un altro iPhone o iPad» con il pulsante **«Collega con un
   codice»** (`#ovuCodice`).
2. Occhiello **«Cosa fanno insieme al Mac»**, cinque righe con l'interruttore (acceso):
   - «I dati» · «Copia cifrata in iCloud Drive: lavori anche con il Mac spento.»
   - «Vera» · «iPhone e iPad usano Vera del Mac, dalla rete di casa.»
   - «Inquadra un documento» · «Con la fotocamera dell’iPhone, da Posizioni.»
   - «Nota a voce» · «Dettata all’iPhone, arriva in Incontri.»
   - «Al tavolo» · «L’iPad davanti al cliente, guidato dal Mac.»
3. La riga «Modifiche in attesa» · «3 dall’iPhone di stamattina: una nota e due attività.» con «Vedi».
4. La nota «Una sola passphrase, scelta una volta, vale per tutto: sta nel Portachiavi di questo Mac.».

**«Collega con un codice»** apre una scheda (`apriCodice`, riga 4258): occhiello «Collega un dispositivo», titolo (24)
«Apri Prisma sull’iPhone o sull’iPad e scrivi questo codice», il codice in grande (54, grassetto, spaziato 6, cifre
tabellari: «482 913»), sotto «Si fa una volta sola: vale per i dati, per Vera, per inquadrare i documenti, per le note a
voce e per il tavolo. Il codice scade tra dieci minuti.».

Voci per la ricerca (riga 4265): «I tuoi dispositivi» · «iPhone e iPad collegati al Mac.»; «Collega un dispositivo» ·
«Una volta, con un codice.»; «I dati» · «Copia cifrata in iCloud Drive.»; «Vera su iPhone e iPad» · «Usano Vera del Mac,
dalla rete di casa.»; «Inquadra un documento» · «Con la fotocamera dell’iPhone.»; «Nota a voce» · «Dettata all’iPhone.»;
«Al tavolo» · «L’iPad davanti al cliente.»; «Modifiche in attesa» · «Dall’iPhone di stamattina.».

La regola aggiunge: in Impostazioni › Vera la riga «iPhone e iPad» diventa un rimando a questa pagina; i pulsanti dentro
le app («Inquadra con l'iPhone», «Nota dall'iPhone», «Mostra al cliente › Sull'iPad sul tavolo») restano dove sono, ma se
il dispositivo non è collegato portano qui.

Il pannello «✦ Migliorie» (MIG6, riga 4271) è solo del template.

### 39.2 Nell'app oggi

- **Due collegamenti diversi, in due posti**:
  - **«Prisma ovunque»** (la copia cifrata in iCloud Drive) in Impostazioni › iPhone e iPad
    (`SchedaImpostazioni.ovunque`, `PaginaImpostazioniOvunque`, Shell/ImpostazioniOvunque.swift:31; corpo
    `CorpoImpostazioniOvunque`, riga 47): schema, «Copia cifrata su iPhone e iPad» (riga 232), «Lavora anche con il Mac
    spento» (righe 246-255), «Porta anche i potenziali clienti» (riga 270), «Modifiche in attesa» (riga 299), «Cartella»
    (riga 312), «Passphrase» (riga 324), conflitti. Il segreto è la **passphrase** (chiave nel Portachiavi,
    `PortachiaviOvunque`).
  - **Il ponte** (Vera, «Inquadra», la carta d'identità, la nota dettata, il copilota) in Impostazioni › Vera
    (`paginaVera`, Shell/ImpostazioniPagine.swift:338): riga «iPhone e iPad» · «Usano Vera del Mac attraverso la rete di
    casa, cifrata. Mai internet.» con l'interruttore `vera.ponte.condividi` (righe 355-363) e, acceso, «Codice ABCD-…» ·
    «Da scrivere su iPhone e iPad.» con «Nuovo codice» (righe 365-375). Il segreto è il **codice di abbinamento**
    (`ImpostazioniPonte.codice`, Vera/PonteVera.swift:79-94, 12 caratteri, nell'archivio e nei backup: «aprendo il backup
    del Mac sul telefono il codice arriva da solo»).
- **Il codice è già uno solo** per tutto ciò che passa dal ponte (protocollo versione 3, Vera/MessaggiPonte.swift:21-42:
  Vera, copilota, inquadra, carta, nota) e anche per il tavolo (Tavolo/TavoloMac.swift:19 e 275-282: «Apri il tavolo»
  usa il codice del ponte, e lo crea se non c'è).
- **Un solo interruttore per il ponte**: `condividi` accende tutto insieme (ServerPonteVera.swift:28-37); non esistono
  interruttori separati per Inquadra, Nota a voce, Al tavolo. «Inquadra con l'iPhone» guarda `ponteInquadraAcceso`
  (Shell/StatoInquadra.swift:225-227) e senza ponte passa al trascinamento di un file; «Nota dall'iPhone»
  (Shell/AzioniIncontri.swift:15) apre «Come funziona»; il tavolo ha la sua testata «Al tavolo» (Shell/AlTavolo.swift).
- **Non esiste un elenco dei dispositivi.** Il Mac non conserva chi si è collegato: il ponte non riceve il nome del
  dispositivo (`BustaPonte`, PonteVera.swift:97-105), il tavolo conosce l'iPad collegato solo mentre è aperto
  (`AscoltoTavolo`, TavoloMac.swift:23), «Prisma ovunque» conosce i giornali dei dispositivi per id
  (`FileSpazio.giornale(dispositivo:)`, Dati/SpazioOvunque.swift:26-43) e la loro data.
- **Il codice non scade** e non è di sei cifre: è la chiave del ponte (`PonteVera.chiave(codice)`).

### 39.3 Cosa fare

1. **La pagina** resta `PaginaImpostazioniOvunque` (titolo «iPhone e iPad»), con lo schema e lo stato della
   sincronizzazione in testa come oggi. Sotto, in un nuovo ordine (in CorpoImpostazioniOvunque, o in una vista nuova
   `PaginaCollegamenti` che la contiene, solo Mac: `suMac`):
   - **«I tuoi dispositivi»** (`GruppoImpostazioni`): una riga per dispositivo conosciuto (vedi punto 2) con nome,
     «visto …» in parole (`Formati` relativi già usati nell'app) e la pillola «Collegato» (`Pillola`, tono ok) se è stato
     visto da quando Prisma è aperta, altrimenti nessuna pillola. In fondo la riga «Un altro iPhone o iPad» con il
     pulsante «Collega con un codice». Senza dispositivi conosciuti, solo questa riga con il sottotitolo «Nessun
     dispositivo ancora: si collega una volta, con un codice.».
   - **«Cosa fanno insieme al Mac»**: le cinque righe con i testi esatti del template (39.1) e il loro interruttore:
     «I dati» = `ovunque.attivo` (accenderlo apre il percorso di oggi: cartella e passphrase; spegnerlo chiede la conferma
     di oggi, `confermaSpegni`); «Vera», «Inquadra un documento», «Nota a voce», «Al tavolo» = i quattro filtri
     nuovi (punto 4), sotto il collegamento generale `vera.ponte.condividi`. Sotto «I dati», quando è acceso, restano le righe di oggi che lo riguardano
     («Lavora anche con il Mac spento», «Porta anche i potenziali clienti», «Cartella», «Passphrase»), rientrate o in
     «Avanzate».
   - **«Modifiche in attesa»** com'è oggi (riga 299), con i conflitti.
   - La nota finale (vedi 39.6, decisione 3): «Il codice collega il dispositivo; la passphrase protegge la copia dei
     dati e sta nel Portachiavi di questo Mac.» (il codice sta nell'archivio, non nel Portachiavi: verificato).
2. **Chi sono i dispositivi** (nuovo `RegistroDispositivi`, in memoria, in Shell/StatoOvunque.swift o un file nuovo
   Shell/DispositiviCollegati.swift, `@Observable`, sul thread principale):
   - il ponte, a ogni busta aperta, annota «un dispositivo» con l'ora: oggi ServerPonteVera passa allo stato solo gli
     arrivi (`consegnaArrivi`, la chiamata al modello no), quindi serve una seconda chiamata leggera `annotaContatto`
     (nome se c'è; oggi il nome non c'è: la riga dice «iPhone o iPad»);
   - il tavolo annota l'iPad del tavolo con il nome del saluto (`SalutoTavolo`) e «sul tavolo oggi alle HH:MM»;
   - «Prisma ovunque» aggiunge i giornali dei dispositivi letti nell'ultima sincronizzazione, con la data del file.
   Il nome vero del dispositivo («iPhone di Denis») richiede che iPhone e iPad lo mandino: è «dopo, con iPhone e iPad»
   (campo facoltativo `dispositivo` in `BustaPonte`, compatibile con il protocollo 3).
3. **«Collega con un codice»** apre la scheda `SchedaCollegaDispositivo` (nuova, stessa presentazione delle schede
   leggere): occhiello «Collega un dispositivo», titolo «Apri Prisma sull’iPhone o sull’iPad e scrivi questo codice», il
   codice di oggi (`vera.ponte.codice`; se manca lo crea con `PonteVera.nuovoCodice()` e accende il ponte) in grande con
   cifre tabellari, sotto «Si fa una volta sola: vale per Vera, per inquadrare i documenti, per le note a voce e per il
   tavolo.» Per i dati resta la passphrase (decisione 3). Niente «scade tra dieci minuti» (decisione 2). Il pulsante
   «Nuovo codice» di oggi passa qui, con il suo avviso («Il codice vecchio smette di valere: va riscritto su iPhone e
   iPad»). Token nuovi in **Tema.Apple+Ovunque.swift**: `Tema.Apple.Ovunque.Codice.carattere` (54, grassetto, cifre
   tabellari), `.spaziatura` (6), `.titolo` (24).
4. **Interruttori nuovi per il ponte** in `ImpostazioniPonte` (Vera/PonteVera.swift:79): `inquadra`, `nota`, `tavolo`
   (Bool, accesi di base). **Attenzione**: accesi di base non devono mai accendere l'ascolto in rete a chi oggi ha il
   ponte spento. Quindi `condividi` resta l'interruttore generale «collegamento acceso» (lo accende «Collega con un
   codice», lo spegne un «Scollega» nella riga dei dispositivi) e l'ascolto resta acceso solo con `condividi` e un codice
   (ServerPonteVera.swift:31-37, come oggi). La riga «Vera» diventa un quarto Bool `modello` (acceso di base) e le
   righe filtrano: il server risponde «rifiutata» (`RicevutaPonte`) ai messaggi del tipo spento: con «Vera» spento le
   chiamate al modello e il copilota, con «Inquadra» spento `prisma/inquadra` e `prisma/carta`, con «Nota a voce» spento
   `prisma/nota` (le note restano nella coda cifrata dell'iPhone, come quando il Mac non risponde). Le quattro righe con
   `condividi` spento sono disattivate con «Prima collega un dispositivo». Con «Al tavolo» spento «Apri il tavolo» porta
   a questa pagina (il tavolo ha il suo ascolto, `AscoltoTavolo`, e non dipende da `condividi`).
5. **Impostazioni › Vera** (ImpostazioniPagine.swift:355-375): la riga «iPhone e iPad» perde interruttore e codice e
   diventa un rimando: «iPhone e iPad» · «Si collegano in Impostazioni › iPhone e iPad.» con il pulsante «Apri» che
   porta a `.ovunque`.
6. **I pulsanti dentro le app** restano dove sono; se il dispositivo non è collegato (ponte spento o senza codice, o la
   funzione spenta) portano qui invece di fermarsi:
   - «Inquadra con l'iPhone» (StatoInquadra.swift:239, 257, 262): il trascinamento di un file resta, e nella scena
     compare il rimando «Collega l'iPhone» → Impostazioni › iPhone e iPad;
   - «Nota dall'iPhone» (AzioniIncontri.swift:15): nella scheda «Come funziona» lo stesso rimando;
   - «Mostra al cliente › Sull'iPad sul tavolo» (gruppo 01) e «Apri il tavolo» (TavoloMac.swift:275): con «Al tavolo»
     spento portano qui.
   Il rimando usa `stato.schedaImpostazioni = .ovunque; stato.apri(.impostazioni)` (come `eseguiPasso`,
   GuidaInizio.swift:58).
7. Testi delle voci per la ricerca (miglioria 30): quelli di 39.1, con «Collega un dispositivo» · «Una volta, con un
   codice.».

**Da NON fare**: non cambiare il protocollo del ponte, la sua cifratura o la passphrase di «Prisma ovunque»; non unire i
due segreti; non portare i nomi e gli orari dimostrativi («iPhone di Denis», «visto 2 minuti fa», «482 913», «3
dall’iPhone di stamattina»); non toccare le Impostazioni di iPhone e iPad (vengono dopo); non portare il pannello
«✦ Migliorie».

### 39.4 Dati, archivio, privacy

- **Campi nuovi**: quattro Bool in `ImpostazioniPonte` (`modello`, `inquadra`, `nota`, `tavolo`), letti con tolleranza
  (`decodeIfPresent`, accesi se mancano) come `condividi` (PonteVera.swift:87-91). Stanno in `impostazioni.vera.ponte`
  (chiave `impostazioni.eve`, da non rinominare), quindi nell'indice dell'archivio, nei backup, ed esclusi da
  `stessiCalcoli` come tutta `impostazioni.vera` (DerivatiDati.swift:609). In «Prisma ovunque» `imp.vera` resta del
  dispositivo (SpazioOvunque.swift:533): i tre interruttori decidono il Mac, che è il server.
- **Il registro dei dispositivi resta in memoria**: niente nell'archivio, niente nei backup, niente in «Prisma ovunque».
  Non contiene dati dei clienti.
- **Privacy**: nulla cambia in ciò che esce dal Mac. Il ponte resta in rete locale, cifrato con il codice; «Prisma
  ovunque» resta l'unico spazio in iCloud, cifrato con la passphrase. La nota della pagina non deve dire «una sola
  passphrase vale per tutto», che oggi non è vero (decisione 3).
- Il codice resta nell'archivio e nei backup come oggi (scelta già fatta per poter aprire il backup sul telefono).

### 39.5 Istantanee e prove

Istantanee nuove (intervallo 1060):
- `1069-uso-impostazioni-iphone-ipad` e `-scuro`: la pagina con «I tuoi dispositivi» (un dispositivo finto annotato nel
  registro per l'istantanea), «Cosa fanno insieme al Mac» e «Modifiche in attesa».
- `1070-uso-collega-dispositivo`: la scheda con il codice.
- `1071-uso-impostazioni-vera-rimando`: Impostazioni › Vera con la riga che rimanda.

Da aggiornare: le scene di Shell/IstantaneeOvunque.swift e IstantaneeImpostazioniApple.swift `560-impostazioni-ovunque`
… `566-impostazioni-ovunque-allineati` (righe 111-126) e `251-impostazioni-vera` (Istantanee.swift:1054); le scene di
«Inquadra» senza ponte (IstantaneeInquadra.swift:60) per il rimando.

Prove:
- `--prova-vera` (ProvaNucleoVera.swift:401, ProvaCopilota.swift:467): con `inquadra`/`nota` spenti il server rifiuta
  quei messaggi e continua a rispondere a Vera; con `modello` spento rifiuta il modello e accetta le note; con
  `condividi` spento l'ascolto resta chiuso anche con i quattro filtri accesi (un archivio di prima, letto con i campi
  nuovi accesi di base, non apre il ponte).
- `--prova-tavolo`: con «Al tavolo» spento il tavolo non si apre.
- `--prova-backup`: i quattro campi nuovi vanno e tornano; un archivio senza li legge accesi.
- `--prova-ovunque`: invariata (la passphrase non cambia).

### 39.6 Decisioni per l'utente e rischi

1. **Interruttori separati per Vera, Inquadra, Nota a voce e Al tavolo** (campi nuovi): il template li mostra; oggi
   tutto dipende da un solo interruttore. Proposta: sì, quattro filtri accesi di base sotto `condividi`, che resta il
   collegamento generale (così nessuno si ritrova il ponte acceso dopo l'aggiornamento). Alternativa senza campi nuovi: le tre righe
   senza interruttore, con lo stato «Con Vera» (seguono l'interruttore di Vera).
2. **Il codice di sei cifre che scade in dieci minuti**: oggi il codice è la chiave del ponte (12 caratteri, fisso,
   anche nel backup). Un codice breve che scade richiede un abbinamento nuovo (scambio di chiavi) su Mac, iPhone e iPad.
   Proposta: per ora si mostra il codice di oggi, in grande, senza scadenza; il codice breve, se lo si vuole, si fa con
   iPhone e iPad.
3. **«Una sola passphrase vale per tutto»**: non è vero oggi (codice del ponte + passphrase di «Prisma ovunque») e
   unirli toccherebbe la cifratura di «Prisma ovunque» (eccezione stretta di CLAUDE.md). Proposta: tenere i due segreti e
   scrivere la nota «Il codice collega il dispositivo; la passphrase protegge la copia dei dati e sta nel Portachiavi di
   questo Mac.» (verificato: il codice è `ImpostazioniPonte.codice`, nell'archivio e nei backup; solo la passphrase è
   nel Portachiavi, `PortachiaviOvunque`).
4. **Il nome del dispositivo** («iPhone di Denis»): serve che iPhone e iPad lo mandino (iOS dà il nome vero solo con un
   permesso speciale: altrimenti «iPhone»/«iPad»). Proposta: per ora «iPhone o iPad» e il nome dell'iPad del tavolo;
   il resto con iPhone e iPad.
- Rischi: il server del ponte deve restare leggero (nessun lavoro quando nessuno chiede): il registro annota solo un'ora
  per dispositivo, sul thread principale, al più una volta al minuto per non ridisegnare la pagina a ogni pezzo di
  risposta. La pagina iPhone e iPad è già lunga (750 righe): conviene spezzare la parte nuova in viste piccole che
  leggono solo ciò che mostrano.

### 39.7 Dimensione

**M** (circa 350-450 righe). File principali: Shell/ImpostazioniOvunque.swift, Shell/ImpostazioniPagine.swift,
Vera/PonteVera.swift, Vera/ServerPonteVera.swift, Vera/MessaggiPonte.swift, Tavolo/TavoloMac.swift, Shell/StatoInquadra.swift,
Shell/AzioniIncontri.swift, Shell/DispositiviCollegati.swift (nuovo), DesignSystem/Apple/Tema.Apple+Ovunque.swift.
