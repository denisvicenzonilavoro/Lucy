# Gruppo 05 — Territorio, Pratiche, Sala, Biblioteca, il dock (migliorie 32-36)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html. Le righe citate sono di quella copia: elenco in testa righe 43-47, regole per
chi implementa righe 2747-2767 («IL QUINTO GIRO»), CSS righe 641-648, codice righe 4096-4189 (MIGLIORIA 32-36), pannello
«✦ Migliorie» (`MIG5`) righe 4191-4196. La base che le migliorie ridefiniscono: Sala righe 1676-1730 (`ESP`, `APPS.sala`,
`salaHTML`, `montaSala`), Territorio righe 2139-2190 (`ZONE`, `TER`, `APPS.territorio`, `luce`, `terDisegna`), Pratiche
righe 2324-2398 (`BIS`, `PRAT`, `SIN`, `APPS.pratiche`, `pratHTML`, `montaPrat`), Biblioteca righe 2399-2416 (`DOCS`,
`QA`, `APPS.biblioteca`, `chiediLib`), dock righe 975-981 (`DOCK`). I documenti `srcdoc` «Sala», «Territorio», «Pratiche»,
«Biblioteca» in fondo al file (righe 5215-5400) sono solo le icone in vetro delle quattro app: non cambiano.

Per ciò che qui non cambia valgono «Luce» (Design/template-luce.html e Design/template-luce-specifica.md: Territorio
§5.1, Pratiche §7, Sala §1.3 e §3-§4, Biblioteca §8.1) e, sotto, il tema Apple (Design/template-apple-specifica.md).

**Attenzione a una frase del template.** Le regole a riga 2748 dicono «Le prime quattro oggi esistono solo in «Luce»:
queste regole valgono quando verranno costruite». Nell'app Territorio, Pratiche, Sala e Biblioteca **esistono già**
(«Luce» giri 1-16): le migliorie si applicano alle viste di oggi, non a viste nuove.

Regole che valgono per tutto il gruppo:

- **Solo Mac.** Territorio, Pratiche e Biblioteca sono già solo del Mac; la Sala e il dock servono anche iPhone e iPad
  (`AppSala`, `DockMobile`). Le parti nuove della Sala vanno sotto `#if os(macOS)`; il dock di iPhone e iPad
  (`iOS/DockMobile.swift`, che legge `AppPrisma.delDock`) non cambia.
- **La grafica non cambia.** Tema Apple, superfici, caratteri, colori dei canali e la mappa scura restano. Ogni misura o
  colore nuovo diventa un token nel file del tema dell'app (`Tema.Apple+Territorio.swift`, `Tema.Apple+Pratiche.swift`,
  `Tema.Apple+PraticheDopo.swift`, `Tema.Apple+SalaEsperienze.swift`, `Tema.Apple+Biblioteca.swift`), mai un numero nel
  codice.
- **Le cifre e i dati del template sono dimostrativi** (`TER`, `ZONE`, `BIS`, `PRAT`, `SIN`, `DOCS`, `QA`, `DOC_CLI`,
  `QA_CLI`, «Centro storico», «Le Fornaci», la soglia `terVicino` a 170 pixel): non si portano. I clienti, le distanze, i
  bisogni, le pratiche, i sinistri e i documenti vengono dai motori e dall'archivio che ci sono (`MotoreTerritorio`,
  `MotoreProposta`, `MotorePratiche`, `MotoreSinistri`, `MotoreBiblioteca`).
- **Il pannello «✦ Migliorie»** (`MIG5`, la funzione `indica(...)`, i cartellini numerati) è solo del template: nell'app
  NON va portato.
- **Movimento:** comparse e filtri con i tempi del tema (`Tema.Apple.Moto.ritmo`, `ritardoPrisma`, niente sfocatura);
  «Riduci movimento» (`\.prismaCalmo`) = tutto fermo con la dissolvenza di 0,15 s; istantanee (`\.modoIstantanea`,
  `\.prismaStatoFinale`) nello stato finale (anelli fermi, schede già comparse). Niente Timer: l'anello che pulsa si fa
  con `AnelloPulsanteTerritorio`, che c'è già e si ferma quando Prisma non si vede.
- **Prestazioni:** niente filtri, ordinamenti o motori su tutto l'archivio nei body. Le cose nuove ricavate (i vicini sul
  Territorio, le pratiche ferme del cliente, i documenti dei suoi prodotti, le esperienze consigliate) si tengono con
  `stato.ricavato("chiave|<clienteId>") { … }` o nelle cache che le viste hanno già (`CacheStatiPratiche`,
  `cacheBisogni`, `derivatiValidi`).
- **Modalità cliente.** Territorio, Pratiche e Messaggi non si aprono in modalità cliente (CLAUDE.md, `StatoShell.appRiservate`):
  resta così. La Sala e la Biblioteca si aprono: lì le indicazioni di lavoro nuove (momenti, consigli) non si mostrano.

## Ordine consigliato

Tutto il gruppo, tranne il dock, si appoggia alla **miglioria 2 del gruppo 01 («Un solo posto per il cliente»)**: il
cliente scelto nella barra, con «Tutti i clienti» come scelta (`clienteAttivoId == ""`, `stato.tuttiIClienti`,
`stato.scegliCliente(_:)`, il pannello `PannelloSceltaCliente` e il componente `VuotoCliente`). Senza la 2 Pratiche e
Biblioteca non sanno quando mostrare «tutti» e quando «solo lui», perché oggi un cliente attivo c'è sempre.

1. **36 · Il dock è in gruppi**: indipendente da tutto, si può fare per primo. Conviene farla presto perché cambia le
   istantanee di quasi tutte le scene con il dock e le scorciatoie ⌥1…⌥9.
2. **32 · La mappa risponde**: dopo la 2 del gruppo 01. Il collegamento «Apri «Da fare» ›» usa il pannello «Da fare»
   della **miglioria 3** (gruppo 01); finché non c'è, apre l'elenco «Con qualcosa da fare» che il pannello del
   Territorio ha già.
3. **33 · Pratiche segue il cliente**: dopo la 2 del gruppo 01 (pannello e «Tutti i clienti»). Il numero sul segmento
   «Dopo la firma» ha bisogno di un piccolo ritocco a `SegmentatoPillola` (DesignSystem), utile anche ad altri gruppi.
4. **34 · Le esperienze della Sala, al momento giusto**: dopo la 2 del gruppo 01 (che toglie le pillole dei clienti dalla
   testata della Sala), dopo la **17** del gruppo 02 («Le priorità in ordine»: da lì vengono le due esperienze
   consigliate) e coordinata con la **1** del gruppo 01 (la vista pulita: lì etichette, filtro e consigli spariscono) e
   con le **58-60** (la Sala esperienza per esperienza), che toccano gli stessi file.
5. **35 · Biblioteca: prima i documenti del cliente**: dopo la 2 del gruppo 01. Si incrocia con la **62** («Il documento
   si apre in grande») e con la **63** («I prodotti parlano chiaro», che aggiunge alla Biblioteca il segmentato
   «Documenti | Prodotti»): stessi file, va fatta prima di quelle due. Anche la **61** («Cerca ovunque, e fa») apre un
   documento della Biblioteca con la funzione della 35 (`bibApri(r.i)`, template riga 4878): la 35 viene prima. E con la
   **1** del gruppo 01 chi fa la 35 verifica che «Mostra al cliente» della Biblioteca (`mostraBibliotecaAlCliente`,
   BibliotecaLuce.swift:275) apra la pagina dentro la vista pulita (gruppo 01, §1.3 e §1.6).

Altre dipendenze da sapere:
- La **51** («Il giro di domani si porta in tasca», template righe 4591-4596) ridefinisce di nuovo `terDisegna` per le viste
  «Il giro di domani» e «La crescita»: tocca gli stessi file del Territorio (MappaTerritorio.swift, PannelloTerritorio.swift).
  Le due migliorie non si pestano (la 32 vale solo nella vista Oggi), ma conviene farle in giri diversi.
- Le **58-60** (la Sala esperienza per esperienza) **usano i dati della 34**: il copione della 59 scrive «Cosa dire · per
  aprire · 2 minuti» (`SALA_M`, `MOM`, template righe 4785-4786) e «La prossima» della 60 sceglie l'esperienza del momento dopo,
  preferendo le consigliate (`salaProssima`, riga 4797, con `salaConsigliate`). Quindi `MomentoSala`,
  `EsperienzaSala.momento`, `minuti` e `consigliate(priorita:)` vanno pensati come modello comune, non come dettagli della
  griglia.

---

## 32. La mappa risponde

### 32.1 Nel template

Codice righe 4096-4117, CSS righe 641-644, regola a riga 2749. Vale nella vista **«Oggi»** del Territorio
(`terUso()` esce se `terM!=='oggi'`). Il Territorio entra fra le app che seguono il cliente (`APPCLI.push('territorio')`,
riga 4117): scegliere un altro cliente ridisegna la mappa e azzera il filtro (`scegliCli`, riga 4180: `terFiltro=null`).

**Ogni luce si tocca** (`terScheda(i,g)`, righe 4106-4109). Il puntatore sulle luci diventa la manina. Un clic apre,
vicino alla luce, una **scheda piccola** `#terK` (CSS riga 644: larga 268, padding 12×14, raggio 16, fondo `--pop`, ombra
`0 18px 40px -16px`, testo 13,5), posta 22 a destra e 44 sopra il centro della luce, tenuta dentro la mappa e mai sopra
il pannello di sinistra (x almeno 372). Contenuto, dall'alto:
- avatar 34, il **nome** in grassetto e sotto il **quartiere** (secondario); per una luce che non è un cliente del
  template «Un cliente di prova» (solo dimostrativo);
- una riga con il **patrimonio** in un'etichetta e le **etichette dei canali**;
- «**Cliente dal <anno>**» e, se ha qualcosa da fare, « · ha qualcosa da fare»;
- il pulsante blu **«Apri il dossier»**.

Entra con una molla (scala 0,9 → 1, opacità 0 → 1, 0,26 s). Si chiude con un clic sulla mappa fuori dalla scheda, con un
clic su un riquadro, cambiando vista o ridisegnando la mappa. Un clic su un'altra luce la sposta.

**I tre riquadri a sinistra sono interruttori** (`terUso`, righe 4110-4112; `terAccendi`, righe 4103-4105). Prendono la
classe `.terT` (manina, al passaggio si alzano di 1, acceso = anello azzurro di 2 attorno). Un clic accende il riquadro e
sulla mappa restano accese **solo le luci di cui parla**; le altre scendono a opacità **0,14** in 0,4 s. Un secondo clic
lo spegne. Un solo riquadro acceso alla volta. Il terzo riquadro, «Con qualcosa da fare», ha in fondo il collegamento
**«Apri «Da fare» ›»**, che apre il pannello «Da fare» della barra (miglioria 3, con «Tutti»).

**Con un cliente scelto** (righe 4113-4114, 4104-4105):
- in cima al pannello, prima dei tre riquadri, un **riquadro suo** `#terIo` con il bordo azzurro al 40%: avatar 34, nome
  15 grassetto, sotto «<quartiere> · cliente dal <anno>»; poi la frase «**<N> clienti a meno di dieci minuti da
  <Nome>: sono le luci rimaste accese.**» (al singolare «1 cliente»);
- sulla mappa restano accese **lui e chi gli sta a meno di dieci minuti**; le altre a 0,14;
- attorno alla sua luce un **anello bianco che pulsa** (`#terSel`: raggio da 17 a 30 e ritorno, opacità 0,95 → 0,2,
  2,4 s, all'infinito), che non intercetta i clic;
- se si accende un riquadro, vale il riquadro: l'anello sparisce e restano accese solo le luci del riquadro; spegnendolo
  si torna a lui e ai vicini.

Senza cliente: niente riquadro suo, niente anello, tutte le luci accese (come oggi).

Pannello «✦ Migliorie» (riga 4192): «Prima le luci non si toccavano, i tre riquadri erano solo testo e con un cliente
scelto la mappa non cambiava…». Solo template.

### 32.2 Nell'app oggi

Il Territorio è molto più avanti della base «Luce» del template:
- `Shell/AppTerritorio.swift:8` `AppTerritorio`: mappa `MappaTerritorio` e pannello a sinistra (`PannelloOggi`,
  `PannelloCrescita`, `PannelloGiro`). La mappa scrive il nome solo dei preferiti e del cliente attivo
  (`contenuto(...)`, AppTerritorio.swift:64-70).
- **I riquadri sono già interruttori**: `TileTerritorio` con `accesa` e `azione` (Shell/PannelloTerritorio.swift:24-58);
  in `PannelloOggi.tile` (PannelloTerritorio.swift:131-160) «La zona con più patrimonio» / «Il comune con più patrimonio»,
  «Dove hai un solo cliente» e «Con qualcosa da fare» accendono `StatoTerritorio.filtroZona` o `soloDaFare`
  (Shell/StatoTerritorio.swift:18-22). Con «Con qualcosa da fare» acceso il pannello mostra l'elenco dei clienti con la
  cosa da fare (`elencoDaFare`, PannelloTerritorio.swift:162-183), ognuno apre il dossier.
- Le luci fuori filtro scendono a `Tema.Apple.Territorio.Luce.opacitaFuori` = **0,28** (MappaTerritorio.swift:211-232;
  Tema.Apple+Territorio.swift, `Luce`).
- **Puntatore su una luce**: il fumetto `FumettoLuce` (MappaTerritorio.swift:697-743: nome, canali, «… € seguiti», la
  cosa da fare, la provenienza della posizione), via `StatoTerritorio.lucePuntata` (MappaTerritorio.swift:103-121).
- **Clic su una luce**: apre subito il dossier (`clic(...)`, MappaTerritorio.swift:379-399, `stato.apriCliente`;
  ⌥ clic: Posizioni del cliente). Doppio clic: torna a vedere tutti (`tornaATutti`, MappaTerritorio.swift:432-438). Esc
  chiude una cosa alla volta (`StatoTerritorio.chiudiUno`, StatoTerritorio.swift:87).
- L'anello arancio che pulsa per «qualcosa da fare» c'è già: `AnelloPulsanteTerritorio` (MappaTerritorio.swift:558-584),
  al più `Tema.Apple.Territorio.Moto.pulsantiMassimi` anelli.
- Distanze e tempi: `MotoreTerritorio.tratto(_:_:stessoComune:impostazioni:)` (Motori/MotoreTerritorio.swift:307-314,
  linea d'aria × fattore strada, velocità e minimo dalle `ImpostazioniTerritorio`).
- I dati ricavati della vista Oggi sono in cache: `StatoShell.territorioOggi()` (StatoTerritorio.swift:164-175).
- **Mancano**: la scheda al clic con «Apri il dossier» (oggi il clic apre subito il dossier); il collegamento «Apri «Da
  fare» ›»; tutto ciò che riguarda il cliente scelto (riquadro suo, vicini, anello bianco). La mappa non cambia quando si
  sceglie un cliente, salvo il nome scritto.

### 32.3 Cosa fare

1. **La scheda della luce** (Shell/MappaTerritorio.swift). In `StatoTerritorio` un campo nuovo `var luceScelta: String?`
   (osservato, non salvato). In `clic(...)`: con una luce sotto il puntatore, `luceScelta = id` (al posto di
   `apriCliente`); senza luce, `luceScelta = nil`. Il ⌥ clic resta (Posizioni). Nuova vista privata `SchedaLuce`
   (accanto a `FumettoLuce`, stesso file) con: `AvatarCliente` 34, nome (`F.titolo`), la zona (`luce.luogo.zona`) in
   secondario; una riga con `Formati.euro(luce.patrimonio)` in un'etichetta e le `EtichettaCanale` compatte (come il
   fumetto, `switch luce.canale`); «Cliente dal \(luce.annoInizio)» (se `annoStimato`, cioè l'anno viene solo dalla data
   della scheda, oggi nessuna vista lo dice: proposta «In Prisma dal \(anno)», testo da approvare con le istantanee) e « · ha qualcosa da fare» se `luce.daFare != nil`; il pulsante `.applePrimario` «Apri il dossier»
   (`stato.apriCliente(id)`). Posizione: 22 a destra e 44 sopra il punto, tenuta fra `contenuto.coperto` e il bordo
   destro, e sopra il bordo basso (stessa logica di `.position` del fumetto). Il fumetto al passaggio resta, ma non si
   mostra sulla luce che ha la scheda aperta. Entrata: molla del tema (`Tema.Apple.Moto` con il ritmo), scala 0,9 →
   1; calmo e istantanee: subito ferma. `luceScelta` si azzera in `chiudi()`, in `tornaATutti`, al cambio di vista
   (AppTerritorio.swift:47-53), al cambio di cliente e accendendo un riquadro; `chiudiUno()` la chiude per prima. Il
   template non ha zoom né trascinamento: nell'app la scheda si chiude anche al pizzico e al trascinamento della mappa
   (`gestoZoom`, `gestoSpostamento`), così non resta staccata dalla sua luce. Il ⌥ clic di oggi scrive
   `stato.clienteAttivoId` a mano (MappaTerritorio.swift:389-392): con la miglioria 2 del gruppo 01 passa da
   `scegliCliente` come gli altri trenta punti.
2. **Token** in `Tema.Apple+Territorio.swift`, `enum SchedaLuce`: `larghezza` 268, `padding` 12×14, `raggio` 16,
   `superficie` (quella del fumetto, `Tema.Apple.Superficie.dettaglio`), `avatar` 34, `spazio` 9, `distanzaX` 22,
   `distanzaY` 44, `testo` 13,5, `scalaEntrata` 0,9; in `Moto` `entrataScheda` (molla 0,26 s × ritmo).
3. **I riquadri** restano quelli di oggi (testi onesti dell'app, non quelli del template). Due ritocchi:
   - l'opacità delle luci spente: il template dice 0,14, l'app ha 0,28. **Proposta: tenere 0,28** (sulla mappa scura
     0,14 fa sparire le luci piccole); vedi 32.6.
   - sotto «Con qualcosa da fare» il collegamento **«Apri «Da fare» ›»** (`Button` con `.buttonStyle(.plain)`, colore
     accento, carattere `P.piccolo`) che apre il pannello «Da fare» della miglioria 3 su «Tutti» (`stato.apriDaFare(solo:
     false)` o il nome che darà il gruppo 01). Finché la 3 non c'è, il collegamento non si mostra (l'elenco nel pannello
     c'è già). Il collegamento è dentro la tile: va messo fuori dal `Button` della tile (un `VStack` con la tile e il
     collegamento sotto, oppure un parametro `piede` di `TileTerritorio`).
4. **Il cliente scelto.** Solo con un cliente scelto nella barra (`!stato.tuttiIClienti`, miglioria 2 del gruppo 01) e
   solo nella vista Oggi:
   - **I vicini**: funzione pura nuova `MotoreTerritorio.vicini(di id: String, luci: [LuceCliente], impostazioni:
     ImpostazioniTerritorio, minuti: Int) -> [String]` che usa `tratto(...)` (stesso comune compreso) e tiene chi è entro
     `minuti`. La soglia è una regola di calcolo, non grafica: costante `MotoreTerritorio.minutiVicini = 10` (non un
     token del tema). Il risultato in cache:
     `stato.ricavato("territorio-vicini|\(id)") { … }` (dipende dalle luci di oggi e dalle impostazioni del Territorio:
     metterne la firma nella chiave, come fa `territorioOggi()` con `imp`).
   - **Sulla mappa** (`posa(...)`, MappaTerritorio.swift:211): se non c'è filtro acceso (`filtroZona == nil && !soloDaFare`)
     e c'è un cliente scelto con la luce sulla mappa, le luci che non sono lui né un vicino prendono `L.opacitaFuori`.
     `ContenutoMappa` riceve `clienteScelto: String?` e `vicini: Set<String>` (calcolati in `AppTerritorio`, non nella
     mappa). Il filtro acceso vince sul cliente.
   - **L'anello bianco**: in `anelli(...)`, con cliente scelto e nessun filtro, un `AnelloPulsanteTerritorio` in più
     attorno alla sua luce, con colore bianco e i tempi propri (token `Luce.anelloScelto` bianco, `distanzaScelto`,
     `spessoreScelto` 2; in `Moto` `pulsazioneScelto` 2,4 s, scala da 17/24 a 30/24, opacità da 0,95 a 0,2). Il moto
     non è quello dell'anello arancio: l'arancio si allarga e svanisce e riparte da capo (`repeatForever(autoreverses:
     false)`, opacità fino a 0,35, Tema.Apple+Territorio.swift:253-256), il bianco va e torna (17 → 30 → 17, 0,95 → 0,2 →
     0,95: `autoreverses: true` su metà durata, 1,2 s × ritmo). Servono parametri in più ad `AnelloPulsanteTerritorio`
     (oggi scala, opacità e animazione sono fisse in `Mo`): `init(raggio:colore:spessore:scala: CGFloat =
     Mo.scalaPulsazione, opacita: Double = Mo.opacitaPulsazione, animazione: Animation = Mo.animazionePulsazione)`, e
     l'opacità di partenza (0,95) come token. Non conta nel limite `pulsantiMassimi`. Calmo e istantanee: fermo, pieno.
   - **Il riquadro suo**, primo in `PannelloOggi.tile`: una `TileTerritorio` con bordo accento al 40% (token
     `Pannello.bordoCliente`) e contenuto proprio (un parametro `@ViewBuilder` o una vista `TileClienteTerritorio`
     nello stesso file): avatar 34, nome (`P.testoForte` a 15), «<zona> · cliente dal <anno>», e la frase
     `TestiTerritorio.vicini(n, nome:)` (enum nuovo in Motori/, oggi non c'è: i testi del Territorio stanno nelle viste): «\(n) clienti a meno di dieci minuti da \(nome): sono le luci rimaste accese.»,
     «1 cliente a meno di dieci minuti da …», e per zero «Nessun cliente a meno di dieci minuti da \(nome).» (il template
     non lo prevede: proposta). Il nome è quello di battesimo (`MotoreTerritorio.nomeBattesimo`). Non è un interruttore.
   - Se il cliente scelto **non è sulla mappa** (senza indirizzo), il riquadro dice «\(nome) non è sulla mappa:
     manca l'indirizzo.» con «Mettilo a mano» (`stato.apriTerritorioSposta(id)`, c'è già) e la mappa resta tutta accesa.
5. **Il Territorio segue il cliente**: cambiare cliente nella barra azzera `filtroZona`, `soloDaFare` e `luceScelta`
   (in `scegliCliente` del gruppo 01, o con un `onChange(of: stato.clienteAttivoId)` in `AppTerritorio`). Le viste «La
   crescita» e «Il giro di domani» non cambiano.
6. **Accessibilità**: ogni luce resta raggiungibile da VoiceOver come oggi; la scheda è un gruppo con il pulsante «Apri
   il dossier»; il riquadro suo legge la frase intera.

**Non fare**: non portare «Centro storico», «Le Fornaci», «Un cliente di prova», la soglia in pixel (170) né i testi dei
riquadri del template (l'app ha già i suoi, più onesti); non togliere il fumetto al passaggio, il ⌥ clic, il doppio clic
né l'elenco «Con qualcosa da fare» del pannello. Nessuna richiesta di rete: le distanze restano stime in linea d'aria.

### 32.4 Dati, archivio, privacy

Nessun campo nuovo: `luceScelta` è stato della vista (in memoria), i vicini si calcolano dalle luci di oggi. Privacy:
invariata (nessuna richiesta di rete, controllo statico del workflow già in essere; il Territorio non si apre in modalità
cliente, quindi la scheda con patrimonio e nome non va mai davanti al cliente). La frase sui vicini dice «a meno di
dieci minuti»: è una stima in linea d'aria come tutte le altre del Territorio (CLAUDE.md).

### 32.5 Istantanee e prove

- Nuove scene in `Shell/IstantaneeTerritorio.swift`. I numeri 710-719 sono già della storia della settimana e
  dell'anno, quindi il gruppo usa la serie **1100-1129** (libera nel codice e nelle altre specifiche; proposta di
  numerazione del gruppo 02: una serie per gruppo): **«1100-uso-territorio-scheda-luce»** (chiara e scura: la scheda
  aperta su un cliente con qualcosa da fare), **«1101-uso-territorio-cliente»** (cliente scelto: riquadro suo, vicini
  accesi, anello bianco fermo), **«1102-uso-territorio-cliente-filtro»** (cliente scelto e «Con qualcosa da fare» acceso:
  niente anello), **«1103-uso-territorio-cliente-senza-luogo»**.
- Da aggiornare: «700-territorio-oggi» (il collegamento «Apri «Da fare» ›», se la miglioria 3 c'è), «708-territorio-fumetto»
  (resta: il fumetto al passaggio).
- Prove: `ProvaCalcoliTerritorio` (`--prova-calcoli`) con un caso per `MotoreTerritorio.vicini` (stesso comune, appena
  sotto e appena sopra i dieci minuti, cliente senza luogo); `--prova-fluidita` (cambiare cliente non rifà
  `territorioOggi`, solo i vicini; la mappa non rimonta); `ProvaBackupTerritorio` non cambia.

### 32.6 Decisioni per l'utente e rischi

- **Clic sulla luce**: oggi apre subito il dossier, il template apre la scheda con «Apri il dossier». **Proposta**: la
  scheda (è la miglioria), con il ⌥ clic per le Posizioni come oggi; il doppio clic resta «torna a vedere tutti».
- **Opacità delle luci spente**: template 0,14, app 0,28. **Proposta**: tenere 0,28 per filtri e cliente scelto.
- **«Dieci minuti»**: il template li scrive fissi. **Proposta**: costante di calcolo a 10, non un'impostazione nuova.
- **Nessun vicino**: il template non lo dice. **Proposta**: «Nessun cliente a meno di dieci minuti da <Nome>.».
- Rischi: con 200 clienti i vicini sono 200 tratti per cliente scelto, una volta sola grazie alla cache; la mappa
  disegna già in `Canvas`, cambiare l'opacità non aggiunge viste. Attenzione a non far rimontare la mappa (oggi «la
  mappa non rimonta al cambio di vista»): i dati nuovi entrano in `ContenutoMappa`, non in un `.id`.

### 32.7 Dimensione

**M.** File principali: Shell/MappaTerritorio.swift, Shell/PannelloTerritorio.swift, Shell/AppTerritorio.swift,
Shell/StatoTerritorio.swift, Motori/MotoreTerritorio.swift, DesignSystem/Apple/Tema.Apple+Territorio.swift,
Shell/IstantaneeTerritorio.swift, Motori/ProvaCalcoliTerritorio.swift.

---

## 33. Pratiche segue il cliente, e i passi vuoti dicono cosa conterranno

### 33.1 Nel template

Codice righe 4119-4143, regola a riga 2753. Pratiche entra fra le app che seguono il cliente (`APPCLI.push('pratiche')`).
Senza cliente scelto («Tutti i clienti») ogni scheda è come oggi, con tutti i clienti. Con un cliente scelto
(`pratHTML` e `montaPrat` ridefinite, righe 4125-4141):

**Proposta.**
- La colonna a sinistra mostra solo i suoi bisogni e l'etichetta diventa «**Bisogni scoperti per <Nome>**»; il bisogno
  scelto passa al suo primo.
- Se non ne ha, al posto della scheda uno stato vuoto centrato (`pratVuoto`, riga 4124: titolo 22 grassetto, testo 14
  secondario largo al più 470, pulsante blu grande): «**Nessun bisogno scoperto per <Nome>.**» / «**I bisogni arrivano
  dall’Analisi 360: quando un’area resta scoperta, qui trovi la proposta da costruire.**» / **«Apri Analisi 360»**.
- **I cinque passi**, prima di «✦ Costruisci la proposta», non sono più riquadri vuoti: ognuno dice in una riga
  (12,5, interlinea 1,4, 12 sotto l'etichetta, CSS riga 645) cosa conterrà (`PASSI_COSA`, riga 4123):
  1. Il prodotto — «Quello adatto al bisogno, con il suo canale»
  2. L’importo — «Quanto, e per quanto tempo»
  3. Il prospetto — «Le pagine da mostrare al cliente»
  4. L’adeguatezza — «Il controllo su profilo, obiettivo e orizzonte»
  5. I moduli — «Già compilati con i dati del dossier»

  Questo vale anche senza cliente scelto. Costruita la proposta, la riga lascia il posto al contenuto di oggi.

**Moduli.**
- Con un cliente: sparisce la fila «Compila per» con i chip dei clienti (era un terzo selettore del cliente); al suo
  posto l'etichetta «**Compilo per <Nome Cognome>**» (il nome in inchiostro, 13,5, non maiuscolo); il pulsante resta
  «✦ Compila con i dati di <Nome>».
- Senza cliente: l'etichetta diventa «**Per chi lo compilo?**» con il pulsante **«Scegli il cliente»**; il pulsante
  principale diventa «**✦ Compila con i dati del cliente**» e, come «Scegli il cliente», apre il pannello di scelta del
  cliente della barra.

**Dopo la firma.**
- Con un cliente si vedono solo le sue pratiche; le tre tile contano solo le sue (aperte, ferme, concluse).
- Se non ne ha: «**Nessuna pratica aperta per <Nome>.**» / «**Quando una proposta viene firmata, qui segui i passi fino
  alla consegna.**» (senza pulsante).

**Sinistri.**
- Con un cliente la colonna mostra solo i suoi sinistri e il primo è scelto.
- Se non ne ha: «**Nessun sinistro per <Nome>.**» / «**Quando ne apri uno, qui segui la denuncia, i documenti e la
  liquidazione.**» (senza pulsante).

**Il numero delle pratiche ferme** (riga 4142): nella testata il segmento «Dopo la firma» porta un numerino (`bN2`, CSS
riga 580: 11 grassetto, capsula, padding 1×7) **rosso** (fondo rosso al 14%, testo rosso) con le pratiche ferme — del
cliente scelto, o di tutti. A zero non c'è.

### 33.2 Nell'app oggi

- `Shell/AppLuce.swift:20` `AzioniPratiche` (il segmentato `SegmentatoPillola` di `SchedaPratiche`) e `AppLuce.swift:32`
  `AppPratiche`, che smista sulle quattro schede. `SchedaPratiche` in Shell/StatoSala.swift:77.
- **Proposta**: `Shell/PratichePropostaApple.swift:18` `CorpoPraticheProposta`; barra «Bisogni scoperti dall'analisi»
  (riga 59) con i bisogni di **tutti** i clienti da `StatoShell.bisogniProposta()` (Shell/StatoPraticheProposta.swift:149,
  in cache `cacheBisogni`, ordinati a giri: il primo di ognuno, poi il secondo…). Vuoto: «Nessun bisogno scoperto. Le
  analisi dei clienti sono in ordine o hanno già una proposta aperta.». Scegliere un bisogno **non** cambia il cliente
  attivo: `scegliBisognoProposta` (StatoPraticheProposta.swift:235) scrive solo `praticheProposta.scelto`; il cliente
  attivo cambia solo con le azioni che portano altrove (riquadro finale «Nel fascicolo», PratichePropostaApple.swift:410;
  Posizioni e moduli, StatoPraticheProposta.swift:342-374; `proponiDaAzienda`, riga 114). I cinque passi: `RiquadroPassoProposta` (PratichePropostaApple.swift:487-568);
  spento (`aspetto.spento`) mostra solo numero ed etichetta, con il bordo a trattini: **nessuna riga su cosa conterrà**.
  Le etichette in `ColonnaProposta.etichette` (riga 174).
- **Moduli**: `Shell/PraticheModuli.swift:499` `ColonnaCompila` con «Compila per» e i chip
  (`ChipClienteModulo`, `FlussoChip`, «Altri» con la ricerca); `StatoShell.clienteModulo` e `clientiRecentiModulo`
  (Shell/StatoModuli.swift:212-228: il cliente di «Compila per», altrimenti il cliente attivo; i chip filtrano e
  ordinano `dati.posizioni` **dentro una proprietà letta dal body**), `scegliClienteModulo` (StatoModuli.swift:281).
- **Dopo la firma**: `Shell/PraticheDopoFirma.swift:66` `CorpoPraticheDopo`, con `CacheStatiPratiche` e
  `MotorePratiche.riepilogo`; tile «Pratiche aperte», «Ferme da più di N giorni» (`TestiPratiche.tileFerme`), «Concluse a
  <mese>», che filtrano l'elenco. Mostra le pratiche di **tutti** (`statiPratiche`, Shell/StatoPratiche.swift:10, filtra
  solo in modalità cliente, che per Pratiche non si apre).
- **Sinistri**: `Shell/PraticheSinistri.swift:83` `BarraSinistri` con tutti i sinistri, «Nuovo sinistro» in cima;
  `StatoSinistri.scelto`.
- `SegmentatoPillola` (DesignSystem/Apple/ControlliApple.swift:19) non sa mostrare un numero accanto a una voce.
- **Mancano**: il filtro sul cliente in tutte e quattro le schede, gli stati vuoti per cliente, la riga dei passi
  spenti, il numero sul segmento, «Compilo per» al posto dei chip.

### 33.3 Cosa fare

1. **Chi è il cliente.** `let solo: String? = stato.tuttiIClienti ? nil : stato.clienteAttivoId` (miglioria 2 del gruppo
   01), letto una volta in `AppPratiche` e passato alle schede.
2. **Proposta** (PratichePropostaApple.swift, StatoPraticheProposta.swift):
   - `bisogniProposta()` resta (cache su tutti i clienti); il filtro per cliente è un passo leggero dopo la cache:
     `bisogniProposta(solo:)` che ritorna `tutti.filter { $0.clienteId == solo }` tenuto in `cacheBisogni` accanto al
     resto (stessa chiave più il cliente), oppure con `stato.ricavato("proposta-bisogni|\(id)")`.
   - Barra: titolo «Bisogni scoperti per \(nome)» (nome di battesimo, `StatoShell.nomeBreve`).
   - Se il cliente scelto non ha bisogni: al posto di barra e colonna lo stato vuoto nuovo (vedi 6) con «Nessun bisogno
     scoperto per \(nome).», il testo del template e «Apri Analisi 360» (`stato.apri(.analisi360)`).
   - `bisognoSceltoProposta` sceglie fra i bisogni filtrati (se lo scelto è di un altro cliente, il primo del cliente).
   - Scegliere un bisogno nella barra con «Tutti i clienti» resta come oggi e come nel template (`bisI=…`, nessun
     `scegliCli`): mostra il bisogno e **non** cambia il cliente della barra. Le azioni che oggi scrivono
     `clienteAttivoId` (riquadro finale, Posizioni, moduli, `proponiDaAzienda`) passano da `scegliCliente` (gruppo 01).
3. **La riga dei passi spenti**: in `RiquadroPassoProposta` un parametro `anticipo: String?`; con `aspetto.spento` e
   `anticipo != nil` sotto la riga del numero un `Text(anticipo)` (token `Tema.Apple.Pratiche.Proposta.anticipo` 12,5 con
   interlinea 1,4 — `lineSpacing` dal tema —, colore `inchiostro2`, `sopraAnticipo` 12). I cinque testi in
   `ColonnaProposta.anticipi` (o in un `enum TestiProposta`) accanto a `etichette`, esattamente quelli del template.
   L'opacità del riquadro spento resta quella di oggi (`Q.opacitaSpento`): controllare nelle istantanee che la riga si
   legga (se no, la riga va fuori dall'opacità). Il riquadro ha l'altezza fissa `Q.altezzaPasso` (320): la riga ci sta.
   L'etichetta per VoiceOver diventa «\(numero). \(etichetta): \(anticipo)» quando il passo è spento.
   `RiquadroPassoProposta` è usato solo da `ColonnaProposta` (riga 174): il parametro nuovo non tocca altro.
4. **Moduli** (PraticheModuli.swift, StatoModuli.swift):
   - `clienteModulo` diventa il cliente della barra (`tuttiIClienti ? nil : clienteAttivo`); `moduli.clienteId`,
     `clientiRecentiModulo`, `chipModuli`, `scegliClienteModulo`, `ChipClienteModulo`, `FlussoChip` e la ricerca «Altri»
     si tolgono (sul Mac; Pratiche c'è solo sul Mac). Chi oggi scrive il cliente dei moduli chiama invece
     `scegliCliente(id)` prima di `apriPratiche(.moduli)`: `apriModuliProposta` (la tappa 5 della proposta,
     StatoPraticheProposta.swift:372-381), «Crea il dossier» con i moduli (`NuovoClienteShell.swift:268`, `if conModuli
     { moduli.clienteId = c.id }`), la carta «moduli» della notte approvata al mattino (`StatoNotteMac.swift:573-578`,
     `scegliClienteModulo(cid)`: è un'azione dell'utente, quindi può cambiare il cliente della barra), l'istantanea
     `IstantaneePraticheModuli.swift:81` e la prova `ProvaCalcoliModuli.swift:354`.
   - `scegliClienteModulo` oggi azzera anche `moduli.posizioneId` e la compilazione: al cambio di cliente nella barra
     va fatto lo stesso (in `scegliCliente` o con un `onChange(of: clienteAttivoId)` in `PraticheModuli`), altrimenti la
     proposta scelta per il cliente di prima resta in memoria (oggi `fonteModulo` la scarta perché controlla il cliente,
     ma è meglio non lasciarla).
   - Con un cliente: l'etichetta «Compilo per» (stile `Tema.Apple.Carattere.etichetta`) seguita dal nome completo in
     inchiostro 13,5 senza maiuscolo (token `Moduli.nomeCompila`); il pulsante resta «✦ Compila con i dati di \(nome)».
   - Senza cliente: l'etichetta «Per chi lo compilo?», il pulsante `.apple` «Scegli il cliente» e il pulsante principale
     «✦ Compila con i dati del cliente»: entrambi aprono il pannello di scelta del cliente della barra (gruppo 01,
     `stato.apriSceltaCliente()` o il nome che avrà). L'anteprima del modulo resta vuota. Oggi senza cliente c'è un
     pulsante «Scegli un cliente» **spento** (`pulsante(_:)`, PraticheModuli.swift:615-619): diventa il pulsante attivo
     del template.
   - Restano come oggi, con o senza cliente: l'etichetta «dati di prova» accanto all'intestazione
     (`EtichettaDatiDiProvaPratiche`), il menu «Per la proposta «…»» (`proposta(_:)`) e, prima del pulsante di
     compilazione, i due casi che vincono su tutto: «I moduli Alleanza non si compilano in Prisma…» e «Controlla la mappa
     dei campi» (decisione 61).
   - `anteprimaModulo` (StatoModuli.swift:254) continua a scartare un'anteprima di un altro cliente: cambiare cliente
     nella barra la nasconde, come oggi.
5. **Dopo la firma** (PraticheDopoFirma.swift): `IngressiStatiPratiche` riceve `solo`; gli stati si filtrano dopo
   `statiPratiche` (`stati.filter { $0.clienteId == solo }`) dentro la stessa cache (`CacheStatiPratiche`, chiave con il
   cliente). Le tre tile si contano sugli stati filtrati con lo stesso `MotorePratiche.riepilogo` (la terza resta
   «Concluse a <mese>», non «concluse» in assoluto come il template). Senza pratiche del cliente: lo stato vuoto nuovo
   «Nessuna pratica aperta per \(nome).» / «Quando una proposta viene firmata, qui segui i passi fino alla consegna.».
   Con «Tutti i clienti» resta il vuoto di oggi (`StatoVuotoPratiche`, PraticheDopoFirma.swift:253, con «Vai alle
   proposte»).
6. **Sinistri** (PraticheSinistri.swift): `BarraSinistri` riceve l'elenco filtrato; `StatoSinistri.scelto` passa al primo
   del cliente se quello scelto è di un altro. Senza sinistri del cliente: «Nessun sinistro per \(nome).» / «Quando ne
   apri uno, qui segui la denuncia, i documenti e la liquidazione.», con sotto il pulsante «Nuovo sinistro» (proposta;
   il template non ha il pulsante nel vuoto). Il vuoto di oggi senza nessun sinistro è già un `VuotoPratiche` con quel
   pulsante (`CorpoPraticheSinistri`, PraticheSinistri.swift:42-46, `TestiSinistri.titoloModulo`, spento in sola lettura
   o senza clienti): basta cambiarne frase e nota quando il cliente è scelto. Il modulo del nuovo sinistro
   (`ModuloSinistro`, Shell/ModuloSinistro.swift:22-39) **parte già** con il cliente attivo; ha però un suo campo
   «Cliente» (`Picker`, riga 49-50) che è un dato del sinistro, non un selettore della vista: resta. Da sistemare il caso
   «Tutti i clienti» (`clienteAttivoId == ""`): oggi cadrebbe in silenzio sul primo cliente dell'elenco
   (`clienti.first`, riga 32); deve partire senza cliente, con «Salva» spento finché non se ne sceglie uno (`valido`,
   riga 165).
7. **Lo stato vuoto per cliente**: `VuotoPratiche` (Shell/PraticheComuniApple.swift:99) c'è già (glifo, frase, nota,
   pulsante). Aggiungere una variante con titolo 22 grassetto e testo 14 largo al più 470 senza glifo, oppure riusare
   `VuotoPratiche` con `glifo` opzionale: decidere guardando le istantanee; i token (`titoloVuotoCliente` 22 bold
   tracking −0,4, `testoVuotoCliente` 14 interlinea 1,5, `larghezzaVuotoCliente` 470, `sottoTestoVuoto` 18) in
   `Tema.Apple+Pratiche.swift`. Testi in `enum TestiPratiche` (c'è già) con le funzioni `nessunBisogno(nome)`,
   `nessunaPratica(nome)`, `nessunSinistro(nome)`.
8. **Il numero sul segmento «Dopo la firma»**:
   - `SegmentatoPillola` riceve un parametro facoltativo `numero: ((Valore) -> Int?)? = nil`; se dà un numero > 0, dopo il
     titolo una capsula (token in `Tema.Apple+Controlli` o dove vive il segmentato: `numeroVoce` 11 bold, padding 1×7,
     `spazioNumero` 2) con i colori passati (`ColoriNumeroVoce`: fondo e testo). Il resto del segmentato non cambia
     (larghezza calcolata con la capsula).
   - In `AzioniPratiche`: `numero: { $0 == .dopoLaFirma ? ferme : nil }` con colori rossi (token
     `Tema.Apple.PraticheDopo.fondoNumeroFerme` rosso al 14%, `testoNumeroFerme` rosso del tema).
   - `ferme` non può venire da un semplice `stato.ricavato("…")`: pratiche, schede di adeguatezza e impostazioni delle
     pratiche **non** sono nei dati dei calcoli (`DatiPrisma.stessiCalcoli`, DerivatiDati.swift:275-278), quindi una voce
     di `ricavato` resterebbe vecchia dopo un passo segnato. Si usa la cache che c'è già: `CacheStatiPratiche` con
     `IngressiStatiPratiche` (PraticheDopoFirma.swift:44-64, oggi `private` e tenuta in `@State` dal corpo) si sposta in
     `StatoShell` (`@ObservationIgnored`, una sola istanza) con il cliente `solo` negli ingressi; la testata
     (`AzioniPratiche`) e `CorpoPraticheDopo` leggono gli stessi stati, e il numero è
     `MotorePratiche.riepilogo(stati, soglia:, oggi:).ferme` su quegli stati (un conteggio, non un motore su tutto
     l'archivio). `AzioniPratiche` legge gli stessi ingressi vivi (`stato.dati.pratiche`, `schedeAdeguatezza`,
     `impostazioni`, `derivatiValidi()`), così si ridisegna quando cambiano.
9. **Accessibilità**: il segmento legge «Dopo la firma, 1 pratica ferma».

**Non fare**: non portare i bisogni, i moduli, le pratiche e i sinistri del template (`BIS`, `MODULI`, `PRAT`, `SIN`,
`ANAG`, `CAMPI`); non mettere un selettore del cliente dentro Pratiche (né chip né tendina): il cliente si sceglie solo
nella barra.

### 33.4 Dati, archivio, privacy

Nessun campo nuovo. `StatoModuli.clienteId` (in memoria) si toglie. Pratiche resta fuori dalla modalità cliente
(`appRiservate`). L'IBAN e i dati del modulo restano come oggi (Impostazioni › Moduli, mai in «Prisma ovunque»).

### 33.5 Istantanee e prove

- Nuove scene (serie del gruppo, vedi 32.5; 808, 824 e 836 sono già di iPad e iPhone): **«1105-uso-pratiche-proposta-cliente»**
  (barra «Bisogni scoperti per …», passi con la riga), **«1106-uso-pratiche-proposta-cliente-vuota»** (Nessun bisogno … con
  «Apri Analisi 360»), **«1107-uso-pratiche-moduli-cliente»** («Compilo per …»), **«1108-uso-pratiche-moduli-senza-cliente»**
  («Per chi lo compilo?»), **«1109-uso-pratiche-dopo-cliente»** (solo le sue, tile ricontate),
  **«1110-uso-pratiche-dopo-cliente-vuota»**, **«1111-uso-pratiche-sinistri-cliente»** e
  **«1112-uso-pratiche-sinistri-cliente-vuoto»**. Chiare e scure le prime due.
- Da aggiornare: «801-pratiche-proposta» (con «Tutti i clienti»: passi spenti con la riga), «810-pratiche-moduli» e
  «811-pratiche-moduli-compilato» (niente chip: «Compilo per»), «820-pratiche-dopo» (il numero rosso sul segmento si
  vede se la scena ha una pratica ferma), «830-pratiche-sinistri».
- Prove: `ProvaBackupLuce` non cambia; `--prova-fluidita` (la testata di Pratiche non rifà `MotorePratiche` a ogni
  disegno; scegliere un cliente filtra senza rifare `bisogniProposta`); le prove dei moduli che usano
  `scegliClienteModulo` (grep in Motori/ e Shell/ `scegliClienteModulo`, `clientiRecentiModulo`) passano a
  `scegliCliente`.

### 33.6 Decisioni per l'utente e rischi

- **Clic su un bisogno con «Tutti i clienti»**: non serve una decisione. Oggi e nel template il clic mostra il bisogno e
  non cambia il cliente (`scegliBisognoProposta`; nel template `bisI=…` senza `scegliCli`): resta così, la barra resta su
  «Tutti i clienti».
- **Il vuoto dei sinistri**: il template non ha il pulsante. **Proposta**: tenere «Nuovo sinistro» (già oggi in cima
  alla barra e nel vuoto senza sinistri), che nasce per il cliente scelto.
- **La terza tile di «Dopo la firma»** con un cliente: **proposta** «Concluse a <mese>» come oggi (il template, per
  semplicità, conta tutte le concluse).
- Rischi: togliere `clienteId` dai moduli tocca le prove e le istantanee dei moduli (810-815) e i cinque punti che lo
  scrivono (33.3 n. 4); con «Tutti i clienti» il modulo del nuovo sinistro non deve più cadere sul primo cliente; il
  numero sul segmentato
  cambia un componente usato da molte app (solo un parametro facoltativo, valore di base nil: nessun effetto altrove).

### 33.7 Dimensione

**M** (vicino a L). File principali: Shell/AppLuce.swift, Shell/PratichePropostaApple.swift,
Shell/StatoPraticheProposta.swift, Shell/PraticheModuli.swift, Shell/StatoModuli.swift, Shell/PraticheDopoFirma.swift,
Shell/PraticheSinistri.swift, Shell/ModuloSinistro.swift, Shell/PraticheComuniApple.swift,
Shell/NuovoClienteShell.swift, Shell/StatoNotteMac.swift, DesignSystem/Apple/ControlliApple.swift,
DesignSystem/Apple/Tema.Apple+Pratiche.swift, DesignSystem/Apple/Tema.Apple+PraticheDopo.swift, le quattro
Shell/IstantaneePratiche*.swift.

---

## 34. Le esperienze della Sala, al momento giusto

### 34.1 Nel template

Codice righe 4145-4158, CSS righe 646-647, regola a riga 2757. Vale nella griglia della Sala (non nel palco) con un
cliente scelto e fuori dalla vista del cliente (`pulita`).

**Ogni esperienza dice il suo momento e quanto dura** (`SALA_M`, `MOM`, righe 4150-4151). In alto a destra di ogni
scheda un'etichetta (`.saMom`: 11 semibold, colore secondario, fondo `--chip`, capsula, padding 3×9, a 14 dal bordo
destro e 16 dall'alto) con «<momento> · <n> min»:

| Esperienza | Momento | Durata |
|---|---|---|
| Il prisma di luce | Per aprire | 2 min |
| Disegna il tuo futuro | Per aprire | 5 min |
| La realtà aumentata | Per aprire | 2 min |
| Il gioco del rischio | Per spiegare | 4 min |
| Una giornata della pensione | Per spiegare | 3 min |
| Lancia l’anno | Per spiegare | 3 min |
| La lettera dal futuro | Per chiudere | 3 min |
| Quanto vale avermi accanto | Per chiudere | 2 min |
| La capsula del tempo | Per chiudere | 2 min |
| Il film del piano | Dopo l’incontro | 1 min |
| Il Prisma del cliente | Dopo l’incontro | (nessuna durata) |

I quattro momenti si chiamano esattamente «Per aprire», «Per spiegare», «Per chiudere», «Dopo l’incontro».

**Il filtro in testa** (riga 4158): nella testata della Sala, prima di «Mostra al cliente», un segmentato
«**Tutte · Per aprire · Per spiegare · Per chiudere · Dopo l’incontro**». Scegliere un momento attenua le altre schede a
opacità **0,26** in 0,35 s (`salaFiltra`, riga 4153): **non spariscono**, restano cliccabili. Nel palco il segmentato si
nasconde. Si apre su «Tutte».

**Due consigliate** (`salaConsigliate`, riga 4152): dalle priorità del cliente (`prioritaDi`, miglioria 17, riga 3663:
le aree sotto il 100%, in ordine dalla più scoperta, al più tre) si prendono le esperienze legate a un'area, al più due:
investimenti → Il gioco del rischio, previdenza → Una giornata della pensione, protezione → Lancia l’anno (il risparmio
non ha un'esperienza sua). La scheda porta l'etichetta verde «**Consigliata per <Nome>**» (`st2 ok`, a 16 da sinistra e
72 dall'alto, CSS riga 647).

**Nella vista del cliente** (regola 1) e senza cliente scelto, etichette, filtro e consigli non compaiono: sono
indicazioni di lavoro.

### 34.2 Nell'app oggi

- `Shell/AppSala.swift:28` `AppSala` → `CorpoSala` (riga 55) → `GrigliaSala` (righe 155-187: la scheda grande
  `SchedaGrandeSala`, righe 190-275, e le dieci piccole `SchedaPiccolaSala`, righe 277-316), entrata a cascata e
  inclinazione. Le piccole hanno già `spenta` (senza cliente, `S.opacitaSpenta`): l'attenuazione del filtro è un'altra
  opacità e si somma.
- `AzioniSala` (AppSala.swift:39-53): nella testata le pillole dei clienti `PilloleClienti` (che la miglioria 2 del
  gruppo 01 toglie e sostituisce con «Mostra al cliente»).
- Le esperienze: `enum EsperienzaSala` (Shell/StatoSala.swift:11-76) con `titolo`, `glifo`, `frase`, `mostraSulTavolo`,
  `aggiungeAlPrisma`, `tavoloPronto`, `piccole`. **Non hanno momento né durata.**
- Le priorità del cliente: `MotoreBisogni.priorita(_:profilo:)` (Motori/MotoreBisogni.swift:146), usate da Analisi 360
  in `ingressiCard` (Shell/Analisi360Apple.swift:414-426) con `areaAnalisi`; la miglioria 17 (gruppo 02, §17.3) le
  rende un ordine senza doppioni sulle `AreaAnalisi`.
- In modalità cliente la Sala si apre (istantanea «693-sala-modo-cliente»).
- Lo stato della Sala sta in `StatoSala` (StatoSala.swift:127), a parte da StatoShell.
- **Manca** tutto: etichette, filtro, consigli.

### 34.3 Cosa fare

1. **Il modello** (Shell/StatoSala.swift): `enum MomentoSala: String, CaseIterable { case apre, spiega, chiude, dopo }`
   con `titolo` («Per aprire», «Per spiegare», «Per chiudere», «Dopo l’incontro»). In `EsperienzaSala`: `var momento:
   MomentoSala` e `var minuti: Int?` dalla tabella di 34.1 (la durata è una stima editoriale, non una cifra del
   cliente: si porta; la riusa anche il copione della 59, «Cosa dire · per aprire · 2 minuti»), `var areaConsigliata:
   AreaAnalisi?` (`.giocoRischio` → `.investimenti`, `.giornataPensione` → `.previdenza`, `.lanciaAnno` → `.protezione`,
   le altre nil). Testo dell'etichetta in un enum nuovo `TestiSala.momento(_:)` (oggi non c'è; può stare accanto a
   `TestiEsperienza` in Motori/): «Per aprire · 2 min», «Dopo l’incontro» (senza durata).
2. **Lo stato del filtro**: in `StatoSala` `var momento: MomentoSala?` (nil = «Tutte»), osservato, non salvato; si
   azzera alla chiusura della Sala.
3. **Le consigliate**: funzione pura `EsperienzaSala.consigliate(priorita: [AreaAnalisi]) -> [EsperienzaSala]` (al più
   due, nell'ordine delle priorità). Le priorità si leggono con la stessa fonte della miglioria 17, in cache:
   `stato.ricavato("sala-consigliate|\(id)") { … }` — mai `MotoreBisogni` nel body di ogni scheda. Se la 17 sceglie
   un'altra fonte (le aree sotto il 100% di `MotoreAree360`, come il template), vale quella: una sola definizione di
   «priorità» in tutta Prisma.
4. **Le etichette sulle schede** (AppSala.swift): `SchedaPiccolaSala` e `SchedaGrandeSala` ricevono `indicazioni: Bool`
   (vero con un cliente scelto, fuori dalla modalità cliente e dalla vista pulita del gruppo 01, cioè
   `stato.vistaCliente == nil`; calcolato una volta in `CorpoSala` e passato giù), `consigliata: Bool`, `attenuata:
   Bool`. Con `indicazioni`:
   - in `overlay(alignment: .topTrailing)` la capsula del momento (token in `Tema.Apple+SalaEsperienze.swift`, `enum
     Momento`: `carattere` 11 semibold, `colore` inchiostro2, `fondo` chip, `padding` 3×9, `dallAlto` 16, `daDestra` 14);
   - se consigliata, sotto il tassello l'etichetta verde «Consigliata per \(nome)» (lo stile delle etichette di stato
     positive che il tema ha già — la `st2 ok` del template —, token `Momento.sopraConsiglio` 72 dall'alto, 16 da
     sinistra; nella scheda piccola va fra il tassello e il titolo, controllare che non copra il testo: le schede piccole
     hanno `righeFrase` limitate);
   - `attenuata` → `.opacity(Momento.opacitaAttenuata)` (0,26) con l'animazione `Momento.cambio` (0,35 s × ritmo); calmo
     e istantanee senza animazione. La scheda resta cliccabile e l'inclinazione resta.
   La scheda grande (Il Prisma del cliente) ha anche lei l'etichetta «Dopo l’incontro».
5. **Il filtro nella testata** (`AzioniSala`, solo Mac): con `indicazioni` e senza esperienza sul palco, un
   `SegmentatoPillola` con «Tutte» e i quattro momenti (`selezione: Binding` su `stato.sala.momento`), prima del pulsante
   «Mostra al cliente» della miglioria 1. `AzioniSala` deve osservare `sala.esperienza` per nasconderlo nel palco: leggere
   solo quel campo, così la testata non si ridisegna per il resto.
6. **Su iPhone e iPad niente cambia** (`#if os(macOS)` attorno a filtro ed etichette, oppure `indicazioni` sempre falso
   fuori dal Mac).

**Non fare**: non mostrare momenti, filtro e consigli in modalità cliente, nella vista pulita, nella presentazione e sul
tavolo; non nascondere le schede filtrate (si attenuano); non inventare consigli quando il cliente non ha priorità
(nessuna etichetta).

### 34.4 Dati, archivio, privacy

Nessun campo nuovo: momento e durata sono proprietà fisse delle esperienze, il filtro è stato della vista. Privacy: i
consigli dicono qualcosa sulle priorità del cliente; sono indicazioni di lavoro e per questo spariscono davanti al cliente
(modalità cliente, vista pulita, presentazione, tavolo), come chiede la regola 34 del template.

### 34.5 Istantanee e prove

- Nuove scene in `Shell/IstantaneeLuce.swift` (695 è già «695-sala-tavolo»: serie del gruppo, vedi 32.5):
  **«1115-uso-sala-momenti»** (chiara e scura: etichette e due consigliate), **«1116-uso-sala-momento-filtrato»** («Per
  spiegare» acceso, le altre attenuate), **«1117-uso-sala-senza-priorita»** (cliente senza priorità: etichette senza
  consigli).
- Da aggiornare: «690-sala-griglia» (le etichette compaiono), «692-sala-senza-cliente» (verificare che **non**
  compaiano), «693-sala-modo-cliente» e «695-sala-tavolo» (verificare che **non** compaiano), «694-sala-presenta»; le
  scene di iPad della Sala restano identiche.
- Prove: `ProvaCalcoliEsperienza` (`--prova-calcoli`) con un caso per `consigliate(priorita:)` (tre priorità, il
  risparmio senza esperienza, al più due) e uno che ogni esperienza abbia un momento; la prova della modalità cliente
  (nessuna indicazione).

### 34.6 Decisioni per l'utente e rischi

- **Durate**: sono stime fisse del template («2 min», «5 min»…). **Proposta**: portarle così, come «circa»; per
  Lancia l'anno la durata non dipende dagli anni della partita (`ImpostazioniSala.anniPartita`). Se l'utente preferisce,
  si tolgono e resta solo il momento (anche nel copione della 59).
- **Quale «priorità»**: una sola in tutta Prisma, quella della miglioria 17 (proposta in gruppo 02 §17.6).
- **Momento ricordato**: proposta, il filtro si azzera alla chiusura della Sala (non si salva).
- Rischi: l'etichetta del consiglio nelle schede piccole può coprire il titolo su finestre strette: verificare con
  «618-app-nuove-sala» e una scena stretta; `AzioniSala` non deve iscriversi a tutto `StatoSala`.

### 34.7 Dimensione

**S/M** (circa 200 righe). File principali: Shell/StatoSala.swift, Shell/AppSala.swift,
DesignSystem/Apple/Tema.Apple+SalaEsperienze.swift, Shell/IstantaneeLuce.swift, Motori/ProvaCalcoliEsperienza.swift.

---

## 35. Biblioteca: prima i documenti del cliente, e si aprono con un clic

### 35.1 Nel template

Codice righe 4160-4180, regola a riga 2761. La Biblioteca segue il cliente (`APPCLI.push('biblioteca')`); cambiando
cliente si chiude la risposta aperta (`qaI=-1`, riga 4180).

**Con un cliente scelto, la colonna ha due gruppi** (`bibUso`, righe 4173-4177):
- in cima «**Dei prodotti di <Nome>**» con il numero a destra, e sotto i documenti dei suoi prodotti (nell'ordine
  dell'elenco);
- poi «**Gli altri documenti**» con il numero, e il resto (l'intestazione solo se ce n'è almeno uno).
Se il cliente non ha documenti suoi, la colonna resta com'è («I documenti»). Senza cliente: com'è oggi.

**Le domande d'esempio che parlano di un altro cliente non si vedono** (riga 4177, `QA_CLI=[0,null,1]`): «Se Marco non
paga la temporanea?» sparisce se il cliente è un altro, e così «Il riscatto nei primi anni ha penali?», perché nel
template la sua risposta fissa nomina Giulia («Dopo il primo anno Giulia può riscattare…», riga 2393). Nell'app le
risposte le scrive Qwen dai passi del documento e non nominano clienti: conta solo il testo della domanda, quindi si
nasconde solo quella di Marco.

**Un clic su un documento lo apre alla prima pagina** (`bibApri(d)`, righe 4165-4172; prima l'elenco non rispondeva):
- la riga del documento si accende;
- il campo della domanda si svuota e dice «**Chiedi qualcosa su «<titolo breve>»…**» (il titolo prima di « · »);
- a sinistra (larga 380) una tile del documento: l'etichetta del genere (es. «CONDIZIONI»), il titolo 21 grassetto, sotto
  «<n> pagine · canale Alleanza» / «canale indipendente» / «vale per tutti i canali» e, a capo, «**Vera l’ha letto sul
  Mac.**»;
- sotto, «**Domande su questo documento**» con le domande d'esempio di quel documento (senza quelle di un altro cliente);
  se non ce ne sono «**Chiedi tu**» e il testo «**Scrivi una domanda in alto: Vera risponde solo con il testo di questo
  documento, citando la pagina.**»;
- a destra il vassoio con la chip «pagina 1 di <n>» e il foglio alla prima pagina;
- entra con una salita di 8 e la dissolvenza (0,32 s).
Un clic su una domanda fa la domanda come oggi (`chiediLib`). Nel template aprire un documento chiude la risposta che
c'era (`qaI=-1`); nell'app resta raggiungibile con «Torna alla risposta» (vedi 35.3 n. 4).

### 35.2 Nell'app oggi

- `Shell/AppBiblioteca.swift:39` `VistaBiblioteca`: a sinistra `LateraleBiblioteca` (riga 387: «I documenti», il
  numero, «+», `LazyVStack` delle letture e dei documenti, didascalia), a destra `BarraDomandaBiblioteca` (riga 541),
  i suggerimenti (`suggerimenti`, riga 129) e `zonaRisposta` (riga 150).
- **Il clic su un documento c'è già**: `rigaDocumento` (AppBiblioteca.swift:455) chiama `stato.apriDocumentoBiblioteca`
  (Shell/BibliotecaLuce.swift:140), che apre il documento nel vassoio alla prima pagina; `documentoAperto(...)`
  (AppBiblioteca.swift:355-384): tassello, titolo, dettaglio ed edizione in alto, il vassoio con le frecce delle pagine,
  «Torna alla risposta» se c'era una risposta. **Manca** la colonna di sinistra con la tile del documento e le domande
  su quel documento; il campo non cambia testo.
- I suggerimenti: `StatoShell.suggerimentiBiblioteca` (BibliotecaLuce.swift:110-124): con i fac-simile le tre domande del
  template (in modalità cliente «Se il cliente non paga la temporanea?» al posto di «Se Marco…», decisione 5); con i
  documenti dell'utente fino a tre «Cosa dicono i documenti su «<rubrica>»?» dalle intestazioni dei passi.
- Il collegamento documento → prodotto c'è già: `TestoNorma.prodottoId` (Vera/NormeVera.swift:46; `DocumentoBiblioteca`
  è un alias, Dati/Biblioteca.swift:11), scelto dal menu della riga (`collegaProdottoBiblioteca`,
  BibliotecaLuce.swift:222); `MotoreBiblioteca.condizioniDelProdotto` (Motori/MotoreBiblioteca.swift:493). Le posizioni
  hanno `prodottoId` (Dati/Posizione.swift:188). **I sei fac-simile non sono collegati a nessun prodotto**
  (`EsempiBiblioteca.elenco`, Dati/Biblioteca.swift:103-116; `caricaEsempiBiblioteca`, BibliotecaLuce.swift:345, non
  scrive `prodottoId`): con i soli dati di prova il gruppo «Dei prodotti di …» non compare mai, salvo collegare a mano
  un documento (come fa «878-biblioteca-prodotto»).
- La ricerca cerca sempre in tutti i documenti: `StatoTrovaPagina.cerca(_:poi:)` (Shell/StatoTrovaPagina.swift:228).
- **Mancano**: i due gruppi per cliente, il filtro delle domande che nominano un altro cliente, la colonna del documento
  aperto, il testo del campo, la ricerca dentro un solo documento.

### 35.3 Cosa fare

1. **I documenti del cliente** (motore puro): `MotoreBiblioteca.documentiDelCliente(prodotti: Set<String>, tra:
   [DocumentoBiblioteca]) -> [String]` — i documenti con `prodottoId` fra i prodotti delle posizioni del cliente (in
   essere e in proposta, non rifiutate), **anche quelli illeggibili** (`illeggibile`, Dati/Biblioteca.swift:45): la
   colonna li mostra già tutti, qui si raggruppano soltanto; la ricerca continua a saltarli come fa
   `condizioniDelProdotto`. Nello stato: `stato.ricavato("biblioteca-cliente|\(id)|\(firma)")`
   dove la firma dice quali documenti ci sono (numero e ultimo cambiamento di `biblioteca.tutti`, che non è nei dati dei
   calcoli). I prodotti del cliente si leggono da `posizioniCliente(id)` (in `CacheClienti`).
2. **La colonna in due gruppi** (`LateraleBiblioteca`): con un cliente scelto e almeno un documento suo, due intestazioni
   nello stile di «I documenti» (`B.etichetta`, numero a destra): «Dei prodotti di \(nome)» e «Gli altri documenti»
   (14 sopra la seconda, token `B.sopraGruppo`), sempre dentro il `LazyVStack` (le letture in corso restano in cima). Il
   «+» resta sulla prima intestazione. Senza documenti suoi o senza cliente: «I documenti» come oggi.
3. **Le domande d'esempio**: `suggerimentiBiblioteca` diventa una funzione `suggerimentiBiblioteca(documento: String?)`.
   - I fac-simile portano per ogni domanda il documento di cui parla e, se nomina un cliente di prova, l'id di quel
     cliente (una piccola tabella accanto alle domande: «Il riscatto…» → Piano rivalutabile; «Quanto si deduce…» →
     circolare sulla deducibilità; «Se Marco non paga…» → Temporanea, cliente di prova Marco). Con un cliente scelto
     diverso da quello nominato, la domanda non si mostra; in modalità cliente resta la versione senza nome di oggi.
   - Per i documenti dell'utente, le domande di un documento si ricavano dalle intestazioni dei suoi passi (lo stesso
     codice di oggi, filtrato su `documentoId`), al più tre, con il testo «Cosa dice «<rubrica>»?».
4. **Il documento aperto** (`documentoAperto(...)`): diventa due colonne come la risposta (`colonnaRisposta` ha già la
   larghezza giusta): a sinistra la tile del documento (etichetta del genere `d.genereVisto`, titolo con il carattere
   un token nuovo `B.titoloDocumentoAperto` 21 bold tracking −0,4 (in Tema.Apple+Biblioteca.swift oggi ci sono solo
   `titoloDocumento` 13 e `titoloArticolo` 15), poi «\(n) pagine · canale
   Alleanza» / «canale indipendente» / «vale per tutti i canali» e a capo «Vera l’ha letto sul Mac.»; per un documento
   illeggibile «Non posso leggerlo: le domande non trovano niente qui.», proposta: il template non ha il caso); sotto «Domande su questo documento» con le
   domande come pillole (`PillolaSpuntoVera`, in colonna, testo a capo) o, se non ce ne sono, «Chiedi tu» e il testo del
   template; a destra il vassoio di oggi con le frecce. «Torna alla risposta» resta. Entrata: salita 8 e dissolvenza con
   i tempi del tema (`Tema.Apple.Moto.CambioScheda` o un token `B.Moto.aperturaDocumento`), ferma con calmo e nelle
   istantanee.
5. **Il campo della domanda** (`BarraDomandaBiblioteca`): con un documento aperto il segnaposto diventa «Chiedi qualcosa
   su «\(d.titoloBreve)»…» e il campo si svuota all'apertura; chiudendo il documento torna «Chiedi qualcosa ai tuoi
   documenti…».
6. **La ricerca dentro il documento**: il testo del template («Vera risponde solo con il testo di questo documento»)
   chiede che la domanda fatta con un documento aperto cerchi solo lì. `StatoTrovaPagina.cerca(_:solo:poi:)` con
   `solo: String?` passa a `MotoreBiblioteca.cerca` un indice ristretto ai passi di quel documento (filtro sui passi,
   sulla coda dell'indice come oggi). `chiediBiblioteca(_:subito:)` riceve il documento aperto, se c'è. La risposta e la
   verifica della frase restano quelle di oggi (Qwen sul Mac, solo dai passi trovati).
7. **Segue il cliente**: cambiare cliente nella barra chiude la risposta e il documento aperto (`trovaPagina.risultato =
   nil`, `aperta = nil`), come `qaI=-1` del template.

**Non fare**: non portare `DOCS`, `QA`, `DOC_CLI`, `QA_CLI` né il foglio fac-simile del template (l'app ha i suoi sei
fac-simile e i PDF veri); non legare i documenti al cliente con un campo nuovo: passa dal prodotto.

### 35.4 Dati, archivio, privacy

Nessun campo nuovo: il legame documento → cliente passa da `TestoNorma.prodottoId` e dalle posizioni del cliente. La
Biblioteca resta solo sul Mac e mai in «Prisma ovunque». A Qwen (127.0.0.1) vanno come oggi la domanda e i passi, mai
dati dei clienti: il nome del cliente compare solo nell'intestazione della colonna, non nella domanda. In modalità
cliente la colonna può mostrare «Dei prodotti di <Nome>» (è il cliente presente), le domande restano senza nomi
(decisione 5 di «Luce»).

### 35.5 Istantanee e prove

- Nuove scene in `Shell/IstantaneeBiblioteca.swift` (870-886 sono già usati: serie del gruppo, vedi 32.5):
  **«1120-uso-biblioteca-cliente-documenti»** (chiara e scura: due gruppi, con un fac-simile collegato a mano a un
  prodotto del cliente come in 878; domanda di Marco nascosta con un altro cliente), **«1121-uso-biblioteca-documento-aperto»**
  (tile del documento, domande del documento, campo «Chiedi qualcosa su …»), **«1122-uso-biblioteca-documento-senza-domande»**
  («Chiedi tu»).
- Da aggiornare: «870-biblioteca» (con «Tutti i clienti» resta com'è), «873-biblioteca-lettura», «878-biblioteca-prodotto»
  (il documento collegato al prodotto ora sta nel gruppo del cliente).
- Prove: `ProvaCalcoliBiblioteca` (`--prova-calcoli`) con `documentiDelCliente` (prodotto in essere, in proposta,
  rifiutato, documento illeggibile) e con la ricerca ristretta a un documento; `ProvaTrovaPaginaVera` (`--prova-vera`)
  per la domanda fatta con il documento aperto; `ProvaBackupBiblioteca` non cambia.

### 35.6 Decisioni per l'utente e rischi

- **Ricerca dentro il documento aperto**: il template lo dice nel testo ma non lo mostra. **Proposta**: sì, con il
  documento aperto la domanda cerca solo lì; per cercare in tutti si chiude il documento (o «Cerca in tutti» accanto al
  campo: proposta da decidere guardando le istantanee).
- **Domande che nominano un cliente di prova**: il template le nasconde. **Proposta**: nasconderle con un altro cliente
  scelto, come il template (non riscriverle con il nome del cliente).
- **I fac-simile e i prodotti di prova**: senza un collegamento il gruppo del cliente non si vede mai con i dati di
  prova. **Proposta**: lasciare i fac-simile come sono (nessun legame inventato) e mostrarlo nelle istantanee con un
  collegamento fatto a mano; in alternativa `caricaEsempiBiblioteca` collega ogni fac-simile al prodotto di prova con
  lo stesso nome nel catalogo, se c'è (decide l'utente: tocca i dati di prova).
- **Aprire un documento con una risposta aperta**: il template la chiude, l'app oggi la tiene con «Torna alla
  risposta». **Proposta**: tenerla (non si perde una risposta di Vera con un clic).
- Rischi: con molti documenti la colonna resta pigra (`LazyVStack`); i documenti del cliente non vanno ricalcolati a ogni
  pagina letta durante un'importazione (la firma nella chiave del `ricavato` cambia solo a lettura finita).

### 35.7 Dimensione

**M.** File principali: Shell/AppBiblioteca.swift, Shell/BibliotecaLuce.swift, Shell/StatoTrovaPagina.swift,
Motori/MotoreBiblioteca.swift, DesignSystem/Apple/Tema.Apple+Biblioteca.swift, Shell/IstantaneeBiblioteca.swift,
Motori/ProvaCalcoliBiblioteca.swift.

---

## 36. Il dock è in gruppi

### 36.1 Nel template

Codice righe 4182-4188, CSS riga 648, regola a riga 2764. Le stesse icone, con lo stesso ingrandimento e lo stesso
rimbalzo, in **gruppi separati da un filo sottile** (`.dkSep`: largo 1, margini 8 sopra, 5 ai lati, 18 sotto, colore
`--wallInk` al 20%), nell'ordine del lavoro:

**Scrivania | Clienti, Posizioni, Analisi 360 | Agenda, Incontri, Prospetti, Sala, Pratiche | Messaggi, Territorio |
Mercato, Biblioteca, Studio | Vera, Impostazioni.**

Cioè: le persone, l'incontro, il contatto, il mestiere, e in fondo Vera e Impostazioni. Prima le icone erano in fila
nell'ordine in cui le app erano nate. La regola aggiunge: «Con le dodici app di oggi i gruppi sono gli stessi, senza Sala,
Pratiche, Territorio e Biblioteca» (vale per iPhone e iPad, che non hanno quelle app: qui non si toccano).

### 36.2 Nell'app oggi

- `Shell/Dock.swift:12` `Dock` → `FilaDock` (riga 55): Scrivania, un solo `DivisoreDock` (riga 241, un filo sfumato),
  poi le app di `AppPrisma.delDock` filtrate da `appConsentita`.
- L'ordine è quello di `AppPrisma.allCases` (Shell/AppPrisma.swift:17-24, `delDock` riga 51): Clienti, Posizioni,
  Analisi 360, Incontri, Agenda, Territorio, Messaggi, Pratiche, Prospetti, Sala, Biblioteca, Mercato, Studio, Vera,
  Impostazioni.
- La disposizione (per l'ingrandimento e per le finestre che escono dall'icona e vi rientrano) è in `DisposizioneDock`
  (Dock.swift:192-238): `disposizione(icone:)` conta **un solo divisore dopo la Scrivania**; `centroIcona(...)` è usato
  da `StatoShellFinestre.swift:85`.
- Le scorciatoie ⌥1…⌥9 sono le prime nove app di `delDock`: `Dock.scorciatoia` (Dock.swift:39), il menu Vai
  (PrismaApp.swift:139-146), la pagina Scorciatoie delle Impostazioni (AppImpostazioni.swift:519). Oggi: da Clienti a
  Prospetti (decisione 120: Mercato e Studio senza scorciatoia).
- `delDock` lo leggono anche `iOS/DockMobile.swift:192`, `iOS/ProvaDockMobile.swift`, `Shell/IstantaneeLuce.swift:101`,
  `Shell/ProvaFluidita.swift:204` e `Vera/ProvaVera.swift:425-434` (che controlla ordine e scorciatoie).

### 36.3 Cosa fare

1. **I gruppi del Mac** (Shell/AppPrisma.swift): `static let gruppiDockMac: [[AppPrisma]] = [[.clienti, .posizioni,
   .analisi360], [.agenda, .incontri, .presentazioni, .sala, .pratiche], [.messaggi, .territorio], [.mercato,
   .biblioteca, .studio], [.vera, .impostazioni]]` e `static var dockMac: [AppPrisma] { gruppiDockMac.flatMap { $0 } }`.
   **`allCases` non cambia** (l'ordine dei casi si usa in archivi, prove, iPhone e iPad). Una prova controlla che
   `Set(dockMac) == Set(delDock)` (nessuna app persa).
2. **Il dock** (Shell/Dock.swift): `Dock` costruisce i gruppi filtrati da `appConsentita` e toglie i gruppi vuoti (in
   modalità cliente Messaggi, Territorio, Pratiche e Impostazioni non ci sono, `appRiservate`: il gruppo «il contatto»
   sparisce con il suo filo). `FilaDock`
   riceve `gruppi: [[VoceDock]]` (o le voci con l'indice del gruppo) e mette un `DivisoreDock` fra un gruppo e l'altro,
   oltre a quello dopo la Scrivania. Indici, ingrandimento, rimbalzi e fumetti restano per posizione nella fila.
   L'uguaglianza di `FilaDock` confronta anche i gruppi.
3. **La disposizione** (`DisposizioneDock`): `disposizione(icone:)` diventa `disposizione(gruppi: [Int])` (quante icone
   per gruppo, la Scrivania è il primo gruppo da 1) e aggiunge `larghezzaDivisore + spazio` a ogni confine. Lo usano
   `ingrandimenti(...)` e `centroIcona(...)`, che riceve i gruppi consentiti al posto dell'elenco piatto
   (StatoShellFinestre.swift:85). Così le finestre escono e rientrano dall'icona giusta.
4. **Il filo**: lo stesso `DivisoreDock` di oggi (il filo sfumato del tema) per tutti i confini: è «un filo sottile come
   nel Dock del Mac». Nessun token nuovo, salvo se il filo fra i gruppi va più corto di quello dopo la Scrivania (il
   template li fa tutti uguali: **proposta** uguali).
5. **Le scorciatoie**: `Dock.scorciatoia`, il menu Vai e la pagina Scorciatoie leggono `dockMac.prefix(9)`. Con i gruppi:
   ⌥1 Clienti, ⌥2 Posizioni, ⌥3 Analisi 360, ⌥4 Agenda, ⌥5 Incontri, ⌥6 Prospetti, ⌥7 Sala, ⌥8 Pratiche, ⌥9 Messaggi;
   senza: Territorio, Mercato, Biblioteca, Studio, Vera, Impostazioni (vedi 36.6). Il menu Vai mette un `Divider` fra i
   gruppi.
6. **Solo Mac**: `DockMobile` (iPhone e iPad) continua a leggere `delDock` e non cambia. Le scorciatoie ⌥0…⌥9
   dell'iPad non passano da `Dock.scorciatoia`: le conta `DockMobile` sull'indice del suo dock (iOS/DockMobile.swift:38
   e 47), quindi cambiare `Dock.scorciatoia` non le tocca. Il menu Vai sta in PrismaApp.swift, che è tutto sotto
   `#if os(macOS)`.
7. **Larghezza**: cinque fili in più allargano il dock di 5 × (`larghezzaDivisore` + `spazio`). Verificare nelle
   istantanee a 1440 e nello schermo basso («415-scrivania-apple-schermo-basso») che il dock stia nella finestra con le
   icone ingrandite; se non sta, ridurre `Tema.Misura.Shell.divisoreMargine` solo per i fili fra i gruppi (token nuovo
   `Tema.Misura.Shell.divisoreGruppiMargine`).

**Non fare**: non cambiare icone, nomi sotto le icone, ingrandimento, rimbalzo, il puntino delle app aperte né l'icona
dell'Agenda con la data; non cambiare l'ordine di `AppPrisma.allCases`; non toccare il dock di iPhone e iPad.

### 36.4 Dati, archivio, privacy

Nessun campo nuovo: i gruppi sono costanti del codice. Nessun effetto su archivio, backup e «Prisma ovunque» (`AppPrisma`
si salva per valore, non per posizione). Modalità cliente: il dock mostra solo le app consentite come oggi.

### 36.5 Istantanee e prove

- Nuove scene (serie del gruppo, vedi 32.5): **«1125-uso-dock-gruppi»** (chiara e scura, la scrivania con tutto il dock)
  e **«1126-uso-dock-gruppi-modo-cliente»** (senza Messaggi, Territorio, Pratiche e Impostazioni, le app di
  `StatoShell.appRiservate`, ModoCliente.swift:10: il gruppo «il contatto» sparisce con il suo filo, niente filo doppio).
- Da aggiornare: tutte le scene con il dock in vista (410-415, 616-scrivania-luce, 617-icone-luce, le scene della
  scrivania di «Prisma istantaneo») e la pagina Scorciatoie delle Impostazioni.
- Prove: `ProvaVera` (Vera/ProvaVera.swift:425-434): l'ordine atteso diventa quello di `dockMac` per il Mac e le
  scorciatoie le nuove nove; `delDock` resta controllato per iPhone e iPad. `ProvaDockMobile` deve passare senza
  modifiche (è la garanzia che iPhone e iPad non cambiano). `ProvaFluidita` (Shell/ProvaFluidita.swift:204) apre le app
  nell'ordine del dock: passare a `dockMac` o lasciarlo (l'ordine lì non conta). Una prova per `centroIcona` con i gruppi
  (l'icona di Impostazioni nel posto giusto, con e senza modalità cliente).

### 36.6 Decisioni per l'utente e rischi

- **Le scorciatoie ⌥1…⌥9**: seguire il nuovo ordine o tenere le vecchie. Cambia la memoria della mano per sei tasti:
  ⌥4 Incontri → Agenda, ⌥5 Agenda → Incontri, ⌥6 Territorio → Prospetti, ⌥7 Messaggi → Sala, ⌥9 Prospetti → Messaggi
  (⌥1-⌥3 e ⌥8 Pratiche restano); Territorio perde la scorciatoia, Sala la guadagna. **Proposta**: seguire il dock,
  come dice la regola di sempre («⌥1…⌥9 per le prime nove app del dock»); Territorio resta senza scorciatoia, come oggi
  Mercato e Studio (decisione 120).
- **L'ordine di CLAUDE.md**: la frase «Nel dock dopo Agenda, Messaggi e Prospetti» (Territorio, Pratiche, Sala e
  Biblioteca) va aggiornata con i gruppi nuovi quando la miglioria entra in main.
- **I fili tutti uguali**: proposta sì, come il template.
- Rischi: `DisposizioneDock` serve anche alle finestre che escono e rientrano (genio): se i centri sbagliano, le finestre
  volano verso l'icona vicina. La prova di `centroIcona` e un'occhiata alle istantanee con una finestra ridotta lo
  scoprono.

### 36.7 Dimensione

**S/M** (circa 150 righe). File principali: Shell/AppPrisma.swift, Shell/Dock.swift, Shell/StatoShellFinestre.swift,
PrismaApp.swift, Shell/AppImpostazioni.swift, Vera/ProvaVera.swift, Istantanee.swift.
