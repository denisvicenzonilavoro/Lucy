# Gruppo 01 — Tutta Prisma (migliorie 1-10)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026). Le righe citate sono quelle della
copia senza immagini Design/uso/.template-senza-immagini.html (stesse righe del template). Commento in testa: righe 6-20;
regole per chi implementa: righe 2599-2625; CSS: righe 409-532; codice: righe 2982-3355; pannello «✦ Migliorie»: righe
3050-3064. Solo Mac: iPhone e iPad restano come sono (vedi «Codice comune con iPhone e iPad» qui sotto).

## Ordine consigliato

1. **7 · Testi piccoli più leggibili** e **8 · Il totale non è più blu Alleanza**: sono solo valori di colore nel tema,
   piccoli e senza dipendenze. Conviene farli per primi, così tutte le istantanee che seguono hanno già i colori giusti.
2. **10 · Le stesse parole ovunque** (l'elenco delle parole) e **9 · Niente nomi tecnici in vista**: sono testi. La 10 è
   anche il vocabolario di tutte le migliorie dopo: «Da fare», «Mostra al cliente», «Tutti i clienti», «Il quadro»,
   «Per il cliente · Per te», «Tono · Invia con», «Dimostrazione», «Da sistemare».
3. **2 · Un solo posto per il cliente**: è la base di quasi tutto il resto. La usano la 1, la 3 e la 5 di questo gruppo,
   e fuori dal gruppo almeno le migliorie 11, 12, 14 (Clienti e Posizioni), 16-17 (Analisi 360), 18, 21, 22-24 (Agenda,
   Incontri, Prospetti), 25, 27, 29 (Messaggi, Vera, Mercato), 33-35 (Pratiche, Sala, Biblioteca), 54 e 56 (Studio),
   65 (Note).
4. **4 · Una riga sola in testa alla finestra**: la base della 12 (nome e azioni del cliente nella riga in testa), della
   24 (tre pulsanti nei Prospetti), della 28 («Nuova parcella» nella riga in testa) e della 29 («Escono solo dati
   pubblici» nella riga in testa). Va fatta prima della 6, che toglie «Come si usa» proprio da quella riga.
5. **6 · Barre più corte**.
6. **3 · Un solo «Da fare»**: dopo la 2 (il filtro «Solo <nome>» segue il cliente della barra). La usano la 5 (la scheda
   «Da fare per <nome>» del dossier), la 11 (i numeri accanto alle voci dell'indice), la 18 (i riesami del mese diventano
   voci del «Da fare»), la 27 (esce «Da non dimenticare» da Vera), la 31 e la 32 («Con qualcosa da fare» del Territorio).
7. **5 · Il dossier parte dal quadro**: dopo la 3. Va coordinata con la 11 e la 12 (stesso dossier) e con la 16 (lo
   stesso elenco «Dati per l'analisi» apre anche da Analisi 360).
8. **1 · Mostra al cliente**: per ultima, perché usa la 2 (il cliente della barra), la 4 (la barra senza strumenti), la 3
   (il «Da fare» sparisce nella vista pulita) e i colori della 7 e della 8. Si incrocia con la 22 e la 24 (Prospetti),
   la 34 e la 58 (Sala, «un solo modo di mostrare») e la 39 (l'iPad sul tavolo passa da Impostazioni › iPhone e iPad).

**Codice comune con iPhone e iPad.** `StatoShell`, `Tema.Apple` e molti componenti sono condivisi con iOS. Le migliorie di
questo gruppo valgono solo per il Mac: ogni cambiamento di comportamento in codice condiviso va dentro `#if os(macOS)` (o
in file solo Mac), e i token di colore della 7 e della 8, che sono condivisi, sono una decisione per l'utente (vedi 7.6 e
8.6). Le istantanee di iPhone e iPad (che girano su main) devono restare uguali, salvo i colori se l'utente li accetta.

**Cosa non si porta, per tutto il gruppo.** Il pannello «✦ Migliorie» con il numero 70 nella barra (`#bNov`, righe 850,
3050-3064), il cartellino arancione che indica dove guardare (`indica()`, righe 2987-3003) e le schede che spiegano una
miglioria (`apriLeggibile()`, `apriParole()`, righe 3034-3047) servono solo a presentare il template: nell'app non vanno.
Le cifre e i nomi del template (Giulia, Marco, «35 clienti», «+ 30 clienti di prova», i 1.124.350 €, le priorità scritte
a mano di `prioritaHTML`, la frase «In questo template i report completi sono pronti per Giulia Rossi») sono dimostrativi:
le cifre le danno i motori di Prisma, i nomi l'archivio.

---

## 1. «Mostra al cliente»: un pulsante solo e una vista pulita con il suo quadro

### 1.1 Nel template

**Il pulsante.** Nella barra, a destra, dopo «Da fare» e prima del «?», la pillola di vetro `#bMostra` (riga 853): il
glifo di uno schermo con una persona e la scritta **«Mostra al cliente»**. Prende il posto dell'icona senza nome della
modalità cliente e del contrassegno «MODALITÀ CLIENTE» (regola 1, riga 2600).

**Il pannello di scelta** (`apriMostra()`, righe 3321-3328), una scheda di vetro al centro, larga 640, che entra dal basso
(18 pt, scala 0,97, 0,48 s) sopra un velo sfocato; si chiude con ✕ in alto a destra, con un clic sul velo o con Esc.

- **Con un cliente scelto nella barra**: avatar 46, occhiello azzurro «Mostra al cliente», titolo 26 **«Cosa mostri a
  <Nome>?»**. Sotto, quattro righe grandi (`.scl`: fondo `card`, filo, raggio 20, padding 14×16; quadrato del glifo 48 con
  raggio 16, fondo accento al 12%; titolo 16, testo 13,5 secondario; freccia › a destra; al passaggio sale di 2 con ombra):
  1. **«Il suo quadro»** — «Le quattro aree, le posizioni, gli obiettivi e il futuro. Testo grande, niente strumenti di
     lavoro.»
  2. **«La Sala»** — «Le esperienze da vivere insieme, senza dock, senza «Da fare», senza altri clienti.»
  3. **«Un prospetto»** — «Le pagine del report, una alla volta, a tutto schermo.»
  4. **«Sull’iPad sul tavolo»** — «Tu guidi dal Mac, il cliente guarda e tocca l’iPad.»
  
  In fondo una riga più leggera (glifo dell'onda, testo secondario): **«Schermata neutra: copre tutto con l’acqua e il
  logo»**.
- **Senza cliente** («Tutti i clienti»): occhiello «Mostra al cliente», titolo **«A chi vuoi mostrare Prisma?»**, testo
  «Scegli la persona: vedrà solo le sue cose.», poi l'elenco dei clienti (avatar 38, nome, motto). Un clic sceglie il
  cliente per tutta Prisma (miglioria 2) e riapre il pannello con le quattro scelte.

Al clic: «Il suo quadro» e «La Sala» entrano nella vista pulita su quel capitolo; «Un prospetto» entra nella vista pulita
e apre la presentazione del prospetto; la schermata neutra si apre subito; «Sull’iPad sul tavolo» nel template è solo un
avviso (««Al tavolo» resta com’è: da qui si apre con il cliente già scelto»).

**La vista pulita** (`entraPulita()`, `esciPulita()`, righe 3314-3320; CSS righe 499-526):

- Senza cliente scelto non si entra: si apre il pannello «A chi vuoi mostrare Prisma?».
- Spariscono: dock, pillola dell'app, ricerca, sfera di Vera, «Da fare», «Mostra al cliente», «?», lucchetto, la freccia
  della pillola del cliente, la chiusura delle finestre (riga 500); con loro ogni strumento di lavoro (regola 1: Importa,
  Incolla da Excel, Posizione, Proposta, filtri, riga delle ipotesi). La scrivania va a opacità 0 e non prende clic.
- Restano: logo, **nome del cliente** (la pillola, non più cliccabile, 14 pt, padding 6/14/6/6), data e ora, e l'avatar
  **«DV»** con un anello bianco al 55% (3 pt): è l'unica uscita.
- In basso al centro, sopra dove stava il dock, la barra dei capitoli `#capitoli` (capsula di vetro, padding 5, spazio 2;
  ogni voce alta 46, padding 0×24, 15,5 semibold, colore `wallInk2`; la scelta ha fondo `cardE`, testo `ink` e ombra
  leggera): **«Il quadro» · «Le posizioni» · «Gli obiettivi» · «Nel tempo» · «La Sala»**.
- La prima volta, un avviso: **«Per tornare al lavoro: «DV» in alto a destra, oppure ⌥⌘M»**.
- Il contenuto sta fra la barra e la barra dei capitoli (`#pul`: dall'alto 34, dal basso 82, padding 26×64, scorre senza
  barra di scorrimento), colore `wallInk` sull'acqua. Ogni capitolo ha un titolo 46 bold (tracking −1,5) e un sottotitolo
  19 `wallInk2`; i riquadri sono di vetro con raggio 30 e padding 26×30. Testo alla dimensione «Grande» delle Impostazioni
  (regola 1). Prima la frase, poi il numero.

I capitoli (`pulHTML()`, righe 3290-3303; le frasi in `frasi()`, righe 3285-3289):

- **Il quadro**: «<Nome>, ecco il tuo quadro.» / «Quattro aree, una frase per ciascuna.» Griglia 2×2 alta 548: anello
  156 (spessore 16) con la percentuale che si conta (per il risparmio, i mesi scritti), occhiello dell'area nel suo colore
  (13, maiuscolo), frase 29 bold, seconda frase 17,5 secondaria. Le frasi:
  - Previdenza: «Per la pensione che desideri mancano circa <X> al mese.» oppure «La pensione che desideri è coperta.»;
    sotto «Oggi i tuoi piani coprono il <N>% del divario.» oppure «Oggi non hai ancora un piano che copra questo divario.»
  - Protezione: «Se venisse a mancare il tuo reddito, alla tua famiglia servirebbero altri <X>.» («a chi conta su di te»
    senza famiglia) oppure «La tua famiglia è protetta.» / «Chi conta su di te è protetto.»; sotto «Oggi il capitale caso
    morte copre il <N>% di quello che serve.» oppure «Oggi non c’è ancora un capitale caso morte.»
  - Investimenti: «I tuoi investimenti rispettano il rischio che hai scelto.» (da 80%) oppure «Una parte dei tuoi
    investimenti rischia più di quanto hai scelto.»; sotto «Il <N>% del capitale è in linea con il tuo profilo, misurato
    con l’indicatore di rischio.»
  - Risparmio e liquidità: «Hai da parte <N> mesi di spese: la riserva c’è.» (da 6 mesi) oppure «…: la riserva è
    corta.»; sotto «Per gli imprevisti contiamo almeno 6 mesi di spese.»
  - L'articolo davanti alla percentuale si accorda (`ilp()`, riga 3282): «lo 0%», «l’1%», «l’8%», «l’11%», «l’80-89%»,
    altrimenti «il».
- **Le posizioni**: «Quello che hai oggi.» / «Le tue posizioni in essere, una per una.» A sinistra «Patrimonio netto»
  con la cifra 78 bold e «Quello che possiedi, <attività>, meno i debiti, <debiti>.», poi «Dove sono»: una barra a
  segmenti per area e la legenda a due colonne con le percentuali. A destra una riga per posizione in essere (alta almeno
  60, 18 pt): quadratino dell'area, nome, area (con «· capitale assicurato» per le protezioni), etichetta del canale
  (non per immobili, debiti e liquidità), importo (i debiti in rosso; per le protezioni il capitale assicurato).
- **Gli obiettivi**: «Il tuo obiettivo.» / «I tuoi obiettivi.» e «A che punto sei.» / «A che punto sei, uno per uno.»
  Per ogni obiettivo un anello 200 con la percentuale, il nome, «<messo da parte> di <traguardo>» e «<N> € al mese · ci
  arrivi a <quando>».
- **Nel tempo**: «Il tuo patrimonio nei prossimi anni.» / «Se continui come oggi, con i versamenti che fai già.» Tre
  riquadri «Oggi», «Tra 10 anni», «Tra 20 anni» (cifra 44, tracking −1,6; più un quarto, «Con le proposte», viola, solo
  se ci sono proposte aperte) e il grafico largo (alto 250) con la linea del patrimonio (colore `--tot`, miglioria 8,
  spessore 3,4) sopra un'area sfumata dello stesso colore (dal 18% a 0) e, **solo se ci sono proposte**, tratteggiata
  viola (3, trattini 7/8) quella con le proposte; a destra le cifre dell'asse in «k» (14, `wallInk2`); sotto «oggi»,
  «tra 10 anni», «tra 20 anni» (15). Nessuna fascia di incertezza.
- **La Sala**: la finestra della Sala dentro la vista pulita, senza il suo pulsante «Mostra al cliente». Se si entra
  dalla Sala già aperta su un'esperienza, l'esperienza resta aperta (`tieni`, riga 3306); dagli altri capitoli la Sala
  riparte dalla griglia.

Cambiare capitolo chiude i dettagli aperti; toccare il capitolo già scelto non fa niente. I riquadri entrano a cascata,
le cifre si contano, gli anelli si riempiono e le linee si disegnano (movimento del tema).

In fondo a ogni capitolo: **«ⓘ Come sono calcolate queste cifre»** (15 semibold `wallInk2`): apre la scheda «Le ipotesi»
con il testo «I calcoli li fa Prisma su questo Mac, con i dati delle tue posizioni. Le ipotesi: … Sono stime, non
garanzie.» e il pulsante «Ho capito». Le parole tecniche (`.term`: sottolineatura a puntini da 2 pt) si toccano e aprono
la scheda «Le parole» con titolo 30, spiegazione 19 e «Ho capito» (`apriTermine()`, righe 3278-3283): «in essere»,
«indicatore di rischio (SRI)», «capitale caso morte», «divario previdenziale», «patrimonio netto».

**Uscire** (riga 3334): nella vista pulita «DV» apre un menu con **«Fine: torna al lavoro»** (lucchetto, ⌥⌘M) e
**«Schermata neutra»** (onda). All'uscita torna l'app che era aperta prima (o la scrivania) e compare «Vista del cliente
chiusa». ⌥⌘M entra (senza cliente apre il pannello; con il cliente va dritto al «Il quadro», senza pannello) ed esce.
Esc nella vista pulita non fa niente, salvo chiudere ciò che c'è sopra, in quest'ordine: schermata neutra, scheda (parola,
ipotesi), menu di DV; la presentazione del prospetto e un dettaglio aperto tengono il loro Esc (riga 3349). Nella vista
pulita non si apre nessun'altra app (solo la Sala) e il logo non porta alla scrivania. L'avviso «Per tornare al lavoro…»
compare solo la prima volta per sessione e non quando si entra da «Un prospetto» (riga 3315, `zitto`).

**La schermata neutra** (righe 3337-3341, CSS 531-532): nasconde tutto tranne l'acqua; al centro il logo (104, `#0F2433`
in chiaro, bianco in scuro) e «Tocca per riprendere». Un clic o Esc la chiude.

**Gli altri ingressi**: nei Prospetti il pulsante «Presenta all’incontro» diventa «Mostra al cliente» e apre la vista
pulita con la presentazione (riga 3112-3114); nella Sala, con un cliente scelto, il pulsante blu «Mostra al cliente»
(riga 3110).

### 1.2 Nell'app oggi

- **Modalità cliente**: `Sources/Prisma/Shell/ModoCliente.swift` — `entraModoCliente(avviso:)` (riga 19), `esciModoCliente()`
  (riga 52), `appRiservate` (riga 10: note, ricerca, impostazioni, territorio, pratiche, messaggi), `ContrassegnoModoCliente`
  (riga 64: capsula blu «MODALITÀ CLIENTE <nome> Esci ⌥⌘M»). Filtra i dati (`StatoShell.clienti`, `appuntamenti`,
  `attivita`, `posizioni`, StatoShell.swift:827-832 e 1220) e blocca il cliente attivo (StatoShell.swift:836-848), ma il
  dock, la scrivania, la barra e le app restano: non c'è una vista pulita.
- **Barra**: `Sources/Prisma/Shell/BarraSuperiore.swift:178-182` — un tasto tondo senza nome (`person.crop.rectangle`),
  aiuto «Modalità cliente: mostra solo il cliente attivo, per girare lo schermo (⌥⌘M)»; in modalità cliente gli strumenti
  diventano `ContrassegnoModoCliente` (riga 131-133). Menu «Vai»: `Sources/Prisma/PrismaApp.swift:128-129` («Modalità
  cliente» / «Esci dalla modalità cliente», ⌥⌘M; la voce sopra è «Cerca ovunque» ⌘K, riga 126). `entraModoCliente`
  senza cliente attivo dice «Scegli prima il cliente in Clienti…» (ModoCliente.swift:20-22) e scrive `portafoglio`,
  `veraPortafoglio`, `filtroClienteAgenda` e `filtroClienteAttivita` (righe 31-36): con la miglioria 2 queste scritture
  cambiano senso (vedi 2.3).
- **Prospetto a tutto schermo**: `Sources/Prisma/Shell/Presentazione.swift` (la sala opaca, frecce per sfogliare);
  «Presenta all'incontro» (ProspettiApple.swift:396-400) la apre già in modalità cliente.
- **Altri «mostra» che esistono già**: nel palco della Sala il pulsante «Presenta» porta l'esperienza sulla sala opaca in
  modalità cliente (decisione 123, AppSala.swift:18-19); in Biblioteca «Mostra al cliente» porta la pagina a tutto
  schermo (`mostraBibliotecaAlCliente`, BibliotecaLuce.swift:273, AppBiblioteca.swift:236). Vanno tenuti presenti per
  non avere due «Mostra al cliente» che fanno cose diverse (vedi 1.6).
- **L'iPad sul tavolo**: `Sources/Prisma/Shell/AlTavolo.swift`, pulsante `PulsanteAlTavolo` in ProspettiApple.swift:386;
  la schermata neutra esiste solo sull'iPad del tavolo (`tavolo.schermataNeutra()`, SalaRealta.swift:333). Sul Mac non
  c'è una schermata neutra.
- **Sala**: `Sources/Prisma/Shell/AppSala.swift` (in modalità cliente si apre, istantanea «693-sala-modo-cliente»).
- **Le cifre che servono ci sono già**: le quattro aree `StatoShell.aree360(_:)` (in cache, DerivatiDati.swift:443;
  motore `MotoreAree360`; Analisi360Apple.swift:66-70 la legge con `CacheAree360`); posizioni del cliente
  `posizioniCliente(_:)`; obiettivi e «ci arrivi a» (DossierObiettivi.swift, ClienteObiettivi.swift). **Il patrimonio a
  10 e 20 anni, come oggi e con le proposte aperte**, c'è già ed è in cache: `stato.analisiDossier(id).patrimonio`
  (AnalisiDossier.swift:15, `MotorePatrimonio.calcola`, orizzonte 20 anni, MotorePatrimonio.swift:39-41, con la serie
  «con le proposte» nil se non ce ne sono). **Non** va usato `MotoreNelTempo` di Dossier › Nel tempo
  (DossierNelTempo.swift): copre 36 mesi indietro e 24 avanti, con la fascia.
- **Le ipotesi**: `IpotesiCalcolo` (Motori/Proiezione.swift:4-12): inflazione 2,0% l'anno, rendimento predefinito 3,0%
  quando la posizione non lo dice. Il «2%» del template coincide con la costante di oggi, ma il testo va composto dalla
  costante, mai scritto a mano.
- **Glossario**: `Sources/Prisma/Shell/Glossario.swift` (`VoceGlossario.Chiave`) con le voci `inEssere`, `sri`,
  `capitaleMorte`, `patrimonioNetto`, `tassoSostituzione` (manca una voce «divario previdenziale»). La «i» accanto a
  un'etichetta e il suo popover esistono già: `InfoTermine`, `SchedaTermine` ed `EtichettaConTermine`
  (DesignSystem/ComponentiGuida.swift:6-120). Le definizioni del template (`GLOSS`, riga 3277) sono più brevi di quelle
  del glossario: valgono quelle del glossario (regola 1: «aprono il glossario che c'è già»).
- **Testo grande**: `DesignSystem/Apple/ScalaTestoApple.swift` (Normale 1,0, Grande 1,12, Molto grande 1,25).
- La vista pulita con i capitoli, il pannello di scelta, le frasi per il cliente e la schermata neutra sul Mac **non
  esistono**.

### 1.3 Cosa fare

1. **Un solo modo, sopra quello di oggi.** «Mostra al cliente» resta costruito sulla modalità cliente (il filtro dei dati
   e il blocco del cliente attivo non cambiano: sono la garanzia di privacy) e ci aggiunge la vista pulita. Nuovo file
   `Shell/MostraAlCliente.swift` (solo Mac) con, in `StatoShell`:
   - `enum CapitoloCliente: CaseIterable { case quadro, posizioni, obiettivi, tempo, sala }` con `titolo` («Il quadro»,
     «Le posizioni», «Gli obiettivi», «Nel tempo», «La Sala»);
   - `var vistaCliente: CapitoloCliente?` (nil: non si mostra), `var sceltaMostra = false` (il pannello),
     `var schermataNeutraMac = false`, `@ObservationIgnored var appPrimaDellaVista: AppPrisma?`;
   - `apriMostraAlCliente()`, `mostra(_ capitolo:)` (chiama `entraModoCliente(avviso: false)`, ricorda l'app davanti,
     chiude pannelli, ricerca, mini Vera e spazi), `mostraProspetto(_:)` (vista pulita + `Presentazione` di oggi),
     `fineMostra()` (esce dalla modalità cliente, riporta l'app di prima, avviso «Vista del cliente chiusa»),
     `mostraNeutra()` / `chiudiNeutra()`.
   - `apri(_:)` e `mostraScrivania()` non fanno niente mentre `vistaCliente != nil`, salvo la Sala e la presentazione.
2. **Il pulsante nella barra.** In `BarraSuperiore.strumenti` il tasto tondo diventa una pillola con glifo e nome
   «Mostra al cliente», dopo il «Da fare» (miglioria 3) e prima del «?». `ContrassegnoModoCliente` si toglie (sul Mac).
3. **La barra nella vista pulita.** Con `vistaCliente != nil`: niente pillola dell'app, niente strumenti tranne l'avatar;
   la pillola del cliente (miglioria 2) resta, non cliccabile e senza freccia; l'avatar prende l'anello e apre un menu
   con «Fine: torna al lavoro ⌥⌘M» e «Schermata neutra» (al posto delle Impostazioni). Il marchio non porta alla scrivania.
4. **Il pannello di scelta** `PannelloMostraAlCliente` (nuovo, stessa scheda centrata di `PannelloGuida`): con cliente le
   quattro righe e la riga della schermata neutra, senza cliente l'elenco dei clienti (dalla stessa fonte della pillola
   della miglioria 2, lazy). «Sull’iPad sul tavolo» avvia il tavolo come `PulsanteAlTavolo`; se l'iPad non è collegato
   porta a Impostazioni › iPhone e iPad (miglioria 39).
5. **La vista** `VistaCliente` (nuovo, in `ShellView` sopra la scrivania): dock nascosto, riquadri della scrivania a
   opacità 0, finestre nascoste (tranne la Sala per il capitolo «La Sala»), `BarraCapitoli` in basso al centro. Ogni
   capitolo è una vista a sé: `CapitoloQuadro`, `CapitoloPosizioni`, `CapitoloObiettivi`, `CapitoloNelTempo`.
6. **Le frasi senza cifre nuove.** Motore puro nuovo `Motori/FrasiCliente.swift` (`enum FrasiCliente { static func
   quadro(_ aree: AreeAnalisi360, famiglia: Bool) -> [FraseArea] }`) che compone frase e seconda frase dalle cifre di
   `MotoreAree360` (mancanza mensile, percentuale coperta, capitale mancante, quota in linea, mesi di riserva), con
   l'articolo accordato. Le soglie (80% per gli investimenti, 6 mesi per la riserva) sono quelle dei motori di oggi: se
   i motori ne usano altre, valgono le loro. «Nel tempo» legge `stato.analisiDossier(id).patrimonio` (oggi, anno 10,
   anno 20 e la serie con le proposte; niente formula del template `futuro()` con 1,02 e 1,025). I dati ricavati che non
   sono già in cache (frasi, ripartizione per area) si tengono con `stato.ricavato("mostra-<capitolo>|<id>")`.
7. **Testo grande.** `VistaCliente` usa `.prismaScalaTesto(max(scalaImpostata, 1.12))`; le misure di base sono token.
8. **Le parole toccabili.** Componente `ParolaSpiegata` (sottolineatura a puntini, colore `inchiostroAcqua`) che apre una
   scheda «Le parole» (titolo 30, spiegazione 19, «Ho capito») con la voce di `Glossario.voce(_:)`: stessa fonte di
   `SchedaTermine`, in una variante grande per il cliente (niente esempio con le cifre di prova, niente «Apri nel
   glossario», che porterebbe fuori dalla vista). Si coordina con la miglioria 66 («Le parole si spiegano dove sono»):
   un componente solo. Aggiungere a `Glossario` la voce `divarioPrevidenziale` («La differenza tra la pensione che ti
   aspetti e il reddito che vorresti avere quando smetti di lavorare.»). «Come sono calcolate queste cifre» apre la scheda
   «Le ipotesi» (occhiello «Le ipotesi», titolo «Come sono calcolate queste cifre») con il testo del template composto
   dalle costanti di `IpotesiCalcolo` («…inflazione al <IpotesiCalcolo.inflazione>% l'anno e i rendimenti dichiarati per
   ogni posizione…»): se un giorno le ipotesi diventano impostazioni, il testo segue da solo.
9. **La schermata neutra sul Mac** `SchermataNeutraMac` (in `ShellView`, sopra tutto tranne l'acqua): `LogoPrisma` 104 e
   «Tocca per riprendere»; un clic o Esc la chiude. L'acqua continua a muoversi (non è la sala opaca).
10. **Tastiera.** La voce del menu «Vai» (PrismaApp.swift:128-129, titolo da `StatoMenu.inModoCliente`) diventa «Mostra
    al cliente» / «Fine: torna al lavoro», ⌥⌘M; con il cliente entra subito su «Il quadro», senza cliente apre il
    pannello. Nella vista pulita le altre voci del menu «Vai» (app, scrivania, spazi, ⌘K) sono spente, come oggi durante
    la presentazione (`menu.inPresentazione`), e così la guida (⌘?). Esc nella vista pulita chiude solo ciò che c'è
    sopra.
11. **Gli altri ingressi**: nei Prospetti «Presenta all’incontro» diventa «Mostra al cliente» (`mostraProspetto`; la
    guida del template dice che apre sempre la versione «Per il cliente»: miglioria 22); nella Sala, nella riga in testa
    e solo con un cliente scelto, un pulsante blu «Mostra al cliente» (`mostra(.sala)`), che non c'è dentro la vista
    pulita. Il «Presenta» del palco e il «Mostra al cliente» della Biblioteca si allineano con le migliorie 58 e 35.
12. **Mentre si mostra**: gli avvisi interni che portano il nome o i dati di un altro cliente (note e carta dall'iPhone,
    carte della notte, sincronizzazione di «Prisma ovunque», routine) non compaiono nella vista pulita: restano in coda e
    si vedono dopo «Fine». Il blocco (lucchetto nascosto, riposo del Mac) non chiude la vista, come oggi non chiude la
    modalità cliente: allo sblocco si torna dov'eri.

Token nuovi in `DesignSystem/Apple/Tema.Apple+MostraAlCliente.swift` (`Tema.Apple.MostraAlCliente`): `Pannello` (larghezza
640, riga: raggio 20, padding 14×16, quadrato 48 raggio 16, fondo accento 0,12, titolo 16 semibold, testo 13,5),
`Vista` (margini 26×64, titolo 46 bold tracking −1,5, sottotitolo 19, riquadro raggio 30 padding 26×30, spazio 16,
frase 29 bold tracking −0,7, testo 17,5, occhiello 13 maiuscolo tracking 1, cifra grande 78 tracking −3, riga posizione
alta 60, anello quadro 156/16, anello obiettivo 200/20, grafico alto 250), `Capitoli` (padding 5, voce alta 46, padding
0×24, 15,5 semibold), `Uscita` (anello dell'avatar bianco 0,55 da 3), `Neutra` (logo 104, testo 15 semibold),
`Parola` (sottolineatura a puntini 2, distanza 5). Tempi dal ritmo `Tema.Apple.Moto` (entrata del pannello 0,48 s,
cascata dei riquadri, conteggi, anelli), con «Riduci movimento» e istantanee già nello stato finale.

**Non fare**: non portare `prioritaHTML`, i dati di `POS`/`PROP` né la frase dei report pronti solo per Giulia; non
lasciare la vecchia modalità cliente come seconda strada sul Mac; non mostrare nella vista pulita niente che legga altri
clienti (Vera, ricerca, notifiche, «Da fare»).

### 1.4 Dati, archivio, privacy

Nessun campo nuovo: `vistaCliente`, `sceltaMostra` e `schermataNeutraMac` vivono solo in memoria, come oggi
`modoCliente` (anche «l'avviso già visto» della prima volta: per sessione, come nel template). Privacy: la vista pulita eredita tutte le regole della modalità cliente (solo i dati del cliente mostrato,
app riservate chiuse) e in più toglie Vera, la mini Vera (anche ⌥ Spazio), la ricerca ⌘K e il «Da fare». Il pannello
«A chi vuoi mostrare Prisma?» elenca tutti i clienti: si apre solo **prima** di girare lo schermo, mai dentro la vista
pulita. La schermata neutra non mostra nessun dato.

### 1.5 Istantanee e prove

- Nuove scene (Istantanee.swift o un nuovo `Shell/IstantaneeMostra.swift`), chiare e scure: «mostra-scelta» (con
  cliente), «mostra-scelta-senza-cliente», «mostra-quadro», «mostra-posizioni», «mostra-obiettivi» (uno e più obiettivi),
  «mostra-nel-tempo» (con e senza proposte), «mostra-parola» (scheda di una parola), «mostra-ipotesi», «mostra-uscita»
  (menu di DV), «mostra-neutra».
- Da aggiornare: «70-modo-cliente», «693-sala-modo-cliente», «83-presentazione» (ora dentro la vista pulita),
  «734-messaggi-traguardo-modo-cliente».
- Prove: `--prova-calcoli` con una prova nuova di `FrasiCliente` (soglie, articolo, famiglia sì/no, zero coperture);
  la prova della modalità cliente in StatoShell.swift (righe 4020-4045) estesa: nella vista pulita `apri(.posizioni)`
  non apre niente, la mini Vera e la ricerca non si aprono, nessun nome di un altro cliente in `contesto(di:)`.
  `--prova-fluidita`: la vista pulita non rifà i motori a ogni cambio di capitolo (ricavati in cache).

### 1.6 Decisioni per l'utente e rischi

- **La vecchia modalità cliente sparisce sul Mac?** Il template la sostituisce. Proposta: sì, sul Mac resta solo «Mostra
  al cliente» (che la usa sotto); iPhone e iPad la tengono finché non si aggiornano.
- **Le altre app durante la vista pulita.** Il template apre solo la Sala. Proposta: così; per mostrare un simulatore si
  esce e si rientra.
- **Il tavolo dal pannello.** Proposta: «Sull’iPad sul tavolo» avvia davvero il tavolo (oggi solo dai Prospetti e dalla
  Sala), con il cliente scelto.
- **«Nel tempo»** non è una decisione: le cifre a 10 e 20 anni vengono da `MotorePatrimonio` (già in cache), che non ha
  fascia; la fascia di Dossier › Nel tempo (24 mesi) resta nel dossier. Le ipotesi non sono una decisione: il testo
  segue `IpotesiCalcolo`.
- **Il «Presenta» della Sala e il «Mostra al cliente» della Biblioteca**: non sono decisioni di questo gruppo (migliorie
  58 e 35), ma con la 1 la parola «Mostra al cliente» deve voler dire sempre «entra nella vista pulita»: chi fa la 35
  verifica che la pagina della Biblioteca si apra dentro la vista pulita.
- Rischi: la vista è lunga (quattro capitoli con grafici): ogni capitolo in una sottovista `Equatable` con i ricavati in
  cache; l'acqua sotto deve restare animata (la vista non è opaca). L'avatar che diventa menu cambia un'abitudine (oggi
  apre le Impostazioni): solo nella vista pulita.

### 1.7 Dimensione

**L.** File principali: Shell/MostraAlCliente.swift (nuovo), Shell/VistaCliente.swift (nuovo), Shell/PannelloMostraAlCliente.swift
(nuovo), Motori/FrasiCliente.swift (nuovo), DesignSystem/Apple/Tema.Apple+MostraAlCliente.swift (nuovo), Shell/ModoCliente.swift,
Shell/BarraSuperiore.swift, Shell/ShellView.swift, PrismaApp.swift, Shell/Glossario.swift, Shell/ProspettiApple.swift,
Shell/AppSala.swift.

---

## 2. Un solo posto per scegliere il cliente

### 2.1 Nel template

**La pillola** `#bCli` (riga 847, CSS 420-423), a sinistra dopo la pillola dell'app: avatar 20 e il nome del cliente,
oppure il glifo delle persone e **«Tutti i clienti»**; una freccia in giù da 11 al 55%; larga al massimo 230, il nome si
taglia con i puntini. Aiuto «Di chi parliamo?».

**Il pannello** `#cliP` (righe 3082-3095, CSS 455-459): vetro, largo 348, sotto la barra (top 40) allineato alla pillola,
raggio 22, padding 12; entra con la molla (−10, scala 0,97, 0,38 s). Dentro:
- titolo 16 **«Di chi parliamo?»**, campo **«⌕  Cerca per nome»** (con il fuoco appena aperto);
- la riga **«Tutti i clienti»** (glifo persone in un cerchio 36, «Le viste d’insieme: portafoglio, agenda, rubrica»,
  spunta azzurra se è la scelta);
- **«Recenti»** (gli ultimi tre scelti), poi **«Tutti · <N>»** in ordine alfabetico; ogni riga: avatar 36, nome, motto;
  a destra la spunta se scelto, altrimenti i pallini 7 dei canali (blu Alleanza, cuoio indipendente);
- cercando, l'elenco si filtra su nome e motto; senza risultati «Nessun cliente con questo nome.»;
- in fondo «+ 30 clienti di prova» (dimostrativo).

Si chiude con Esc, con un clic fuori o scegliendo. Scegliere (`scegliCli()`, righe 3076-3078): il cliente vale per tutta
Prisma, entra nei recenti, Clienti torna alla Rubrica (`vistaC='rub'`, se era su Potenziali o Passaparola), l'app
davanti chiude il dettaglio aperto e si ridisegna se lavora su una persona (Clienti, Posizioni, Analisi 360, Agenda,
Prospetti, Sala, Vera); avviso **«Tutta Prisma ora parla di <Nome>»** o **«Tutti i clienti: tornano le viste
d’insieme»**. Scegliere il cliente già scelto non fa niente (nessun avviso). L'avviso compare solo per le scelte fatte
apposta (pannello, pillole del vuoto, «Solo <Nome> ✕», «‹ Tutto il portafoglio»); le strade che portano a un cliente
(«Apri il dossier» di una voce del «Da fare», la persona toccata nella rubrica, `aggiornaDossier`, riga 3080) lo scelgono
in silenzio, ma lo mettono nei recenti. Nella vista pulita (miglioria 1) la pillola non si apre.

**Spariscono** (regola 2, riga 2607): «Cliente | Portafoglio» e «Dossier di…» in Posizioni, la fila di avatar in Analisi
360 e in Sala, le tendine in Agenda, Prospetti e Vera. Chi sceglie una persona nella rubrica la sceglie per tutta Prisma.
La scrivania resta sempre la giornata intera.

**Le app che lavorano su una persona, senza cliente** (`vuotoCli()`, righe 3106-3115; CSS 461-462): al centro un
quadrato 84 (raggio 28, fondo accento 10%) con il glifo delle persone, un titolo 27 bold, un testo 15 secondario, il
pulsante blu grande **«Scegli il cliente»** (apre il pannello) e, sotto, «oppure» con le pillole dei primi cinque clienti
(recenti prima). Testi:
- Analisi 360: «Analisi 360 lavora su una persona alla volta.» / «Scegli il cliente nella barra in alto: tutta Prisma lo
  segue, senza doverlo riscegliere in ogni app.»
- Sala: «La Sala si apre per una persona.» / «Scegli il cliente in alto: le esperienze parlano di lui.»
- Prospetti: «I prospetti si preparano per una persona.» / «Scegli il cliente in alto: trovi i suoi report per
  l’incontro.» (qui anche «Mostra al cliente» e «Salva PDF» aprono il pannello).

**Con un cliente scelto**: in Agenda, nella riga in testa, la pillola **«Solo <Nome> ✕»** (aiuto «Mostra gli impegni di
tutti»): toccarla riporta a «Tutti i clienti» (riga 3116). In Posizioni la colonna ha in cima «‹ Tutto il portafoglio»
(riga 3147, il resto della vista è della miglioria 14). In Clienti con «Tutti i clienti» a destra c'è «La tua rubrica»
(«Scegli una persona a sinistra, oppure nella barra in alto: vale per tutta Prisma.»), con quattro cifre e il «Da fare»
(righe 3123-3125; il resto è della miglioria 11). Vera parla del cliente della barra (domande d'esempio, riquadro
«Parliamo di», righe 3117-3121: miglioria 27).

### 2.2 Nell'app oggi

- Il cliente attivo è già uno per tutta l'app: `StatoShell.clienteAttivoId` (StatoShell.swift:837-849; in modalità
  cliente il getter dà il cliente mostrato e il setter non fa niente), salvato nell'indice dell'archivio
  (`ArchivioPezzi`, chiave `.clienteAttivoId`, ArchivioPezzi.swift:276, 292, 1175). Lo scrivono oggi una trentina di
  punti (rubrica, notifiche, sussurro, mini Vera, routine, tagliando, parcelle, territorio, campagne…: `grep -rn
  "clienteAttivoId = " Sources/Prisma/Shell`). Il valore vuoto oggi vuol dire «nessun cliente», non «tutti», e in tre
  posti viene sostituito dal primo cliente: `DatiPrisma.init(from:)` se la chiave manca (DatiPrisma.swift:407),
  `ArchivioPezzi` quando ricostruisce l'indice (ArchivioPezzi.swift:763-765), e l'unione di «Prisma ovunque» che tiene
  il cliente locale solo se esiste (SpazioOvunque.swift:552). `clienteAttivo` con l'id vuoto è nil: molte viste
  ripiegano su «Nessun cliente» (`contesto(di:)`, StatoShell.swift:864-871). **Non esiste però «Tutti i clienti»** come
  scelta comune: ogni app ha il suo interruttore o filtro:
  - Posizioni: `StatoShell.portafoglio` (StatoShell.swift:161) con il segmentato «Cliente | Portafoglio»
    (AppPosizioni.swift:211) e `DossierRail` / `TestataPortafoglioRail` (AppPosizioni.swift:214-218);
  - Vera: `veraPortafoglio` (StatoShell.swift:348) con il segmentato «Cliente | Portafoglio» (AppVera.swift:280);
  - Prospetti: `sceltaProspetto.tipo == .portafoglio` e la tendina del cliente nella colonna (ProspettiApple.swift:19);
  - Agenda, Attività, Note: `filtroClienteAgenda`, `filtroClienteAttivita`, `filtroClienteNote` (letti da
    `contesto(di:)`, StatoShell.swift:884-889);
  - Analisi 360 e Sala: la fila di pillole dei clienti `PilloleClienti` (Analisi360Apple.swift:334-337,
    AppSala.swift:46-48; componente in DesignSystem/Apple/PilloleClienti.swift).
  - Questi interruttori si scrivono in molti posti: `portafoglio` e `veraPortafoglio` circa 77 volte in 35 file di
    Shell (notifiche, scrivania, sussurro, routine, radar, smontaggio, Vera della scrivania, prospetti, ModoCliente…),
    i tre `filtroCliente…` circa 23 volte; `sceltaProspetto.tipo = .portafoglio` 2 volte.
- La Sala ha già uno stato senza cliente («Ciao.» e «Scegli un cliente per iniziare», un clic porta a Clienti,
  AppSala.swift:22); per i vuoti esiste il componente `VuotoGuidato` (DesignSystem/ComponentiGuida.swift:125), con tre
  passi e un pulsante, che non ha la fila di pillole del template.
- Ogni finestra dice di chi parla con `ContestoFinestra` (FinestraInterna.swift:184), dal `contesto(di:)` di StatoShell.
- Nella barra non c'è nessun selettore del cliente (BarraSuperiore.swift:102-109 ha solo marchio e app).
- Non c'è un elenco dei clienti recenti.

### 2.3 Cosa fare

1. **Il modello.** `clienteAttivoId == ""` vuol dire «Tutti i clienti» (sul Mac). Il valore è già ammesso dal modello
   (`ArchivioPezzi.vuoto`, ArchivioPezzi.swift:129, e il default dell'indice, riga 367), ma va **difeso** nei tre posti
   che oggi lo cambiano nel primo cliente (2.2): `DatiPrisma.init(from:)` lo mette solo se la chiave manca del tutto
   (archivi vecchi: va bene), `ArchivioPezzi` alla ricostruzione dell'indice tiene `""` se l'indice lo diceva, e
   l'unione di «Prisma ovunque» tiene anche il `""` locale. In `StatoShell` (solo Mac, `#if os(macOS)`):
   `var tuttiIClienti: Bool { clienteAttivoId.isEmpty }`, `func scegliCliente(_ id: String?, avviso: Bool = false)`
   (scrive `clienteAttivoId`, aggiorna i recenti, chiude il dettaglio aperto dell'app davanti, riporta Clienti alla
   Rubrica, mostra l'avviso solo con `avviso: true`, non fa niente se il cliente è già quello),
   `var clientiRecenti: [String]` in memoria (al più 3; anche le scelte silenziose ci entrano). I trenta punti che oggi
   scrivono `clienteAttivoId =` passano da `scegliCliente` (in silenzio), così i recenti restano veri.
2. **Gli interruttori di oggi seguono il cliente** invece di essere scelte a sé: `portafoglio`, `veraPortafoglio`, il
   tipo `.portafoglio` dei Prospetti e i filtri di Agenda, Attività e Note diventano letture di `tuttiIClienti` e di
   `clienteAttivoId` (proprietà calcolate con lo stesso nome, così i molti punti che le leggono non cambiano). Restano
   però **con un setter**, perché le scritture sono un centinaio (2.2) e non si riscrivono tutte in un giro: `portafoglio =
   true` (e gli altri «tutti») → `scegliCliente(nil)`; `portafoglio = false` con «Tutti i clienti» → torna al primo dei
   `clientiRecenti` (se non c'è, resta «Tutti»); `filtroClienteAgenda = id` → `scegliCliente(id)`, `= nil` →
   `scegliCliente(nil)`. Attenzione ai punti che scrivono **due** interruttori diversi in modo opposto (per esempio
   `entraModoCliente` mette `portafoglio = false` e `filtroClienteAgenda = nil`, ModoCliente.swift:31-36: con il setter
   il secondo riporterebbe a «Tutti» il primo): vanno riletti uno per uno e, dove serve, sostituiti con una chiamata
   esplicita. Su iPhone e iPad restano campi veri (`#if os(macOS)` attorno alla versione calcolata).
3. **La pillola** `PillolaClienteBarra` in BarraSuperiore.swift, dopo `appCorrente`: avatar (`AvatarCliente` di oggi) o
   glifo, nome con `truncationMode(.tail)`, freccia; larghezza massima token.
4. **Il pannello** `PannelloSceltaCliente` (nuovo file Shell/PannelloSceltaCliente.swift), stessa entrata e stesso vetro
   di `PannelloNotifiche`: titolo, campo di ricerca con il fuoco, «Tutti i clienti», «Recenti», «Tutti · <N>» con
   `LazyVStack`; l'elenco ordinato si tiene con `stato.ricavato("rubrica-ordinata")`, i canali di ogni cliente da
   `CacheClienti`. Esc e clic fuori lo chiudono. Il motto è `Cliente.tema`.
5. **Via i selettori nelle app**: il segmentato «Cliente | Portafoglio» e `DossierRail` in Posizioni (sostituiti da
   «‹ Tutto il portafoglio», che chiama `scegliCliente(nil)`), `PilloleClienti` in Analisi 360 e Sala, la tendina dei
   Prospetti, il segmentato di Vera, il filtro cliente dell'Agenda (al suo posto la pillola «Solo <Nome> ✕» nella riga in
   testa). Scegliere una persona nella rubrica di Clienti chiama `scegliCliente`.
6. **Senza cliente**: componente `VuotoCliente(titolo:testo:)` (DesignSystem/Apple/VuotoClienteApple.swift) con
   «Scegli il cliente» e le pillole dei primi cinque (recenti prima, poi alfabetico), usato da Analisi 360, Sala e
   Prospetti (e dalle schede Obiettivi e Documenti ospitate in Clienti). Prende il posto del «Ciao. Scegli un cliente per
   iniziare» della Sala (AppSala.swift:22) e dei vuoti di Analisi 360 e Prospetti di oggi; non è `VuotoGuidato` (che ha
   tre passi e nessuna pillola), ma ne riusa i token dove coincidono. Con zero clienti in archivio niente pillole e
   «Scegli il cliente» porta a «Nuovo cliente».
7. **Clienti con «Tutti i clienti»**: a destra della rubrica «La tua rubrica» con le cifre dei motori (persone seguite,
   in regola, riesami, patrimonio seguito: da `MotoreStatoDelLavoro` e dal riepilogo delle posizioni) e il «Da fare»
   (miglioria 3). Va coordinato con la miglioria 11.
8. `ContestoFinestra` non mostra più il nome del cliente (lo dice la barra): vedi miglioria 4.

Token nuovi in `DesignSystem/Apple/Tema.Apple+SceltaCliente.swift`: pillola (avatar 20, freccia 11 al 55%, larghezza
massima 230), pannello (larghezza 348, sotto la barra 40, raggio 22, padding 12, avatar 36, pallino del canale 7, altezza
massima dell'elenco 610), vuoto (quadrato 84 raggio 28 fondo accento 0,10, glifo 42, titolo 27 bold tracking −0,6, testo
15, pillole avatar 24). Testi in un `enum TestiSceltaCliente`.

**Non fare**: non portare «+ 30 clienti di prova» né «Tutti · 35» scritto a mano (il numero è quello vero); la scrivania
non segue il cliente.

### 2.4 Dati, archivio, privacy

Nessun campo nuovo: `clienteAttivoId` c'è già, nell'indice e nei backup; il valore vuoto ora ha un senso («Tutti i
clienti»). I recenti restano in memoria (proposta, vedi 2.6). Niente cambia per «Prisma ovunque». Privacy: in modalità
cliente e nella vista pulita il pannello non si apre (elenca tutti i clienti); `clienteAttivoId` resta bloccato come oggi.

### 2.5 Istantanee e prove

- Nuove scene: «barra-cliente» (pillola con un cliente), «barra-tutti-i-clienti», «pannello-cliente» (con recenti),
  «pannello-cliente-ricerca» (con e senza risultati), «analisi-senza-cliente», «sala-senza-cliente»,
  «prospetti-senza-cliente», «agenda-solo-cliente»; chiare e scure le prime tre.
- Da aggiornare: tutte le scene che usano `s.portafoglio = true` (per esempio «420-posizioni-portafoglio»,
  «116-portafoglio-seguito») e quelle di Analisi 360 e Sala con la fila di pillole.
- Prove: `ProvaSeguito` (ProvaSeguito.swift:169 controlla `s.portafoglio`), `--prova-carico` (pannello con 200 clienti,
  aperto e filtrato), `--prova-fluidita` (scegliere un cliente non rifà i motori di tutto l'archivio nei body), la prova
  della modalità cliente (la pillola non cambia cliente). `--prova-backup`: un indice con `clienteAttivoId` vuoto si
  salva, si ripristina e si ricostruisce restando «Tutti i clienti» (`ProvaBackupArchivioPezzi`); `--prova-ovunque`:
  l'unione dell'istantanea non cambia il `""` locale. Una prova dei setter (2.3 punto 2): `portafoglio = true` poi
  `= false` torna al cliente di prima; `entraModoCliente` lascia il cliente mostrato.

### 2.6 Decisioni per l'utente e rischi

- **All'apertura di Prisma**: proposta, si riparte dal cliente salvato (o da «Tutti i clienti» se era quello).
- **I recenti**: proposta, solo in memoria (si azzerano alla chiusura), niente campo nuovo nell'archivio.
- **Clienti senza cliente scelto**: proposta, apre la rubrica con «La tua rubrica» (come il template).
- Rischi: è il cambiamento più ampio del gruppo, perché `portafoglio`, `veraPortafoglio` e i filtri si leggono e si
  scrivono in molte viste e motori (un centinaio di scritture); tenerli come proprietà calcolate con un setter riduce il
  rischio, ma ogni scrittura va riletta. Cambia anche il comportamento: oggi Vera può stare sul portafoglio mentre
  Posizioni è su un cliente, e l'Agenda può mostrare tutti con un cliente attivo; dopo, una scelta vale per tutte. Ogni scelta del cliente cambia `clienteAttivoId`
  e quindi le cache che lo leggono: controllare con `--prova-fluidita` che le viste d'insieme non si rifacciano.

### 2.7 Dimensione

**L.** File principali: Shell/StatoShell.swift, Shell/BarraSuperiore.swift, Shell/PannelloSceltaCliente.swift (nuovo),
DesignSystem/Apple/VuotoClienteApple.swift (nuovo), DesignSystem/Apple/Tema.Apple+SceltaCliente.swift (nuovo),
Shell/AppPosizioni.swift, Shell/Analisi360Apple.swift, Shell/AppSala.swift, Shell/ProspettiApple.swift, Shell/AppVera.swift,
Shell/AgendaApple.swift, Shell/AppClienti.swift, Dati/ArchivioPezzi.swift, Dati/SpazioOvunque.swift (il valore vuoto si
conserva), più i circa 35 file che scrivono `portafoglio`, `veraPortafoglio`, i filtri o `clienteAttivoId`.

---

## 3. Un solo «Da fare» al posto di notifiche, scadenze e promemoria

### 3.1 Nel template

**Una fonte sola** (righe 3193-3257; regola 3, riga 2612): l'elenco delle schede «Da fare, in ordine di tempo» di
Posizioni. Barra, scrivania, dossier, rubrica e agenda leggono da lì. Prende il posto di: Notifiche, «In scadenza entro
90 giorni», «Da non dimenticare», «Da fare e da ricordare», «Richiede attenzione». Quattro gruppi: **Oggi, Questa
settimana, Questo mese, Più avanti**.

**Una riga** (`rigaFare()`, riga 3200; CSS 479-497) è sempre: cerchio da spuntare (20, filo 2 `ink3`; al passaggio verde
al 18% e scala 1,12), pallino 8 del colore del momento (rosso, arancio, verde), titolo 13,5 semibold, sotto «<Cliente> ·
<quando>» 12 secondario (senza il nome quando l'elenco è già di un cliente), le etichette dei canali a destra. Nel
dossier («Da fare per <Nome>») e nell'Agenda («Da fare oggi») le etichette dei canali **non** ci sono (CSS riga 497) e
nell'Agenda il filo fra le righe è arancio al 22% (riga 498). Il titolo nel pannello va a capo, altrove si taglia con i
puntini. Un clic sulla riga (fuori dal cerchio) apre il dettaglio della voce.

**Nella barra**: la campanella diventa la pillola **«Da fare»** (glifo del cerchio con la spunta) con il numero delle voci
aperte (`bN`: rosso `#FF3B30`, verde quando è zero), riga 852. Il pannello `#notif` (larghezza 450, `fareP()`, righe
3211-3215):
- in testa «Da fare» con il numero; con un cliente scelto il segmentato **«Tutti | Solo <Nome>»**, altrimenti «in ordine
  di tempo». Dalla pillola si apre su «Tutti»; da «Apri tutto ›» del dossier e da «<N> da fare per <Nome> ›» di Posizioni
  si apre già su «Solo <Nome>» (`data-fare="1"`); da scrivania, rubrica e agenda su «Tutti»;
- i gruppi con il titolo maiuscolo 11 «OGGI · 3» e le righe (l'elenco scorre, alto al più 650); senza voci «Tutto
  fatto.»;
- in fondo **«+ Aggiungi»**: apre un campo («Da fare per <Nome>…» o «Scrivi una cosa da fare…», al più 70 caratteri) con
  «Aggiungi»; la voce entra fra quelle di oggi, avviso «Aggiunta al «Da fare»[ di <Nome>]»; a destra, se ce ne sono,
  **«Fatte oggi: <n> · Annulla l’ultima»**.

**Spuntare** (`fatto()`, righe 3229-3233): la riga scivola via (opacità 0, 16 a destra, 0,32 s), la voce sparisce da
tutta Prisma, gli anelli dello stato del lavoro salgono; avviso «<Nome>: fatto. La voce sparisce da tutta Prisma» (per una
voce scritta a mano «Fatto. La voce sparisce da tutta Prisma»). «Annulla l’ultima» la rimette («<Nome>: di nuovo da
fare»).

**Il dettaglio di una voce** (`apriFare()`, `schedaFare()`, righe 3240-3249): dentro Posizioni nasce dalla scheda come
oggi; altrove si apre al centro con lo stesso contenuto: avatar, quando, nome, canali, il perché, la spiegazione,
patrimonio, capitale assicurato, proposte aperte, il grafico, «Ti preparo», e i pulsanti «Preparami l'incontro», «Segna
come fatto», «Apri il dossier», con la nota «Le cifre vengono dai motori di Prisma». Una voce scritta a mano ha una scheda
semplice: «<quando> · scritta da te», il testo, «Segna come fatto», «Chiudi».

**Gli altri posti**:
- Scrivania: **la mossa del giorno è la prima voce** (`mossaHTML()`, righe 3203-3207): sfera con le iniziali del
  cliente, «La mossa del giorno» con le etichette dei canali, il titolo, la spiegazione, e a destra «✦ Preparami
  l'incontro», «Apri il dossier» (solo se la voce ha un cliente) e «✓ Fatto»; un clic sul testo apre il dettaglio. Senza
  voci la sfera viva, «Tutto fatto.» / «Nessuna cosa da fare in sospeso: un buon momento per i riesami.». Il riquadro «In
  scadenza entro 90 giorni» diventa **«Da fare»** con il numero (verde a zero), «dopo la mossa del giorno» (solo con più
  di una voce), «[altre N · ]Apri tutto ›» («altre N» con più di quattro voci) e le voci dalla seconda alla quarta; vuoto
  «Nient’altro da fare.» (righe 1009, 3208).
- Rubrica con «Tutti i clienti»: «Da fare» con il numero, «Apri tutto ›» e cinque voci; con più voci in fondo «altre N
  ›»; senza voci «Niente da fare.» (`fareRigheHTML`, riga 3201; riga 3125).
- Dossier: «Da fare per <Nome>» con il numero, «Apri tutto ›» e tre voci senza il nome (e «altre N ›», «Niente da
  fare.») (miglioria 5).
- Agenda: **«Da fare oggi»** (occhiello arancio delle scritte, miglioria 7) con il numero delle voci di oggi, «Apri tutto
  ›» e due voci di oggi del cliente della barra o di tutti; vuoto «Niente per oggi[ con <Nome>].» (riga 3209).
- Posizioni › Portafoglio: le schede «Da fare, in ordine di tempo» **restano** (regola 3: sono lo stesso elenco);
  spuntare lì usa l'animazione delle schede di oggi.

Dopo ogni spunta o annullamento si aggiornano insieme il numero della barra, la mossa, il riquadro della scrivania, la
rubrica, il dossier, l'agenda e gli anelli dello stato del lavoro (`aggiornaFare()`, riga 3236).

### 3.2 Nell'app oggi

- **Il nastro esiste già**: `Sources/Prisma/Motori/MotoreDaFare.swift` (proposte ferme, riesami dovuti, conformità,
  occasioni, attività aperte, attenzioni dei dossier; gruppi Oggi / Questa settimana / Questo mese / Più avanti; toni
  urgente / presto / sereno; `VoceDaFare.Fatto` dice cosa fa «Segna come fatto»). In cache con
  `StatoShell.nastroDaFare()` (StatoPortafoglioApple.swift:33); `segnaFatto(_:)` (StatoPortafoglioApple.swift:64) scrive
  nell'archivio con i meccanismi di sempre. Si vede solo in Posizioni › Portafoglio («Da fare, in ordine di tempo»).
  `VoceDaFare.cliente` non è opzionale: niente voci senza cliente (le attività con un `clienteId` che non c'è si
  saltano, MotoreDaFare.swift:250). **Il nastro è tagliato**: al più `MotoreDaFare.massimoPerGruppo = 8` voci per gruppo
  (`NastroDaFare.Blocco.voci`; `totale` e `nascoste` contano il resto). Le occasioni comprendono già le scadenze fiscali
  (`TipoOccasione.scadenzaFiscale`, Dati/Occasione.swift:15) e i contratti (fine del blocco, senza penali…).
- **Le notifiche**: `Sources/Prisma/Shell/Notifiche.swift` (`MotoreNotifiche.calcola`, righe 47-330; gruppi «DA
  RECUPERARE», «OGGI», «NEI PROSSIMI GIORNI», «DA SISTEMARE»). Le voci sono molte più di quelle del template: appuntamenti
  di oggi, appuntamenti passati senza esito («Com'è andato…?»), attività scadute e di oggi, posizioni in scadenza e
  scadute, proposte ferme, compleanni, dati letti da confermare nei documenti, valori di estratti conto da registrare,
  schede prodotto da verificare, clienti da ricontattare, beneficiari da indicare, proposte fuori dall'esperienza del
  cliente, schede di adeguatezza incomplete, pratiche ferme, sinistri fermi, la carta d'identità dall'iPhone, le note
  dall'iPhone, le carte della notte, le capsule pronte, più conformità, traguardi, fine anno e le cose da sistemare; `PannelloNotifiche.swift`, la campanella con il numero delle nuove (BarraSuperiore.swift:156-209,
  `notificheNuove` e `notificheViste`, Notifiche.swift:433 e StatoShell.swift:341), la goccia d'acqua sulla campanella
  (`puntoAcqua(.campanella)`, EventiShell.swift).
- **I promemoria del Mac** (notifiche di sistema): `PromemoriaMac.swift`, da `MotoreNotifiche.promemoria` (Notifiche.swift:616).
- **Scrivania**: «In scadenza entro 90 giorni» `RiquadroScadenzeScrivania` (ScrivaniaApple.swift:1262); «Da fare oggi»
  `RiquadroDaFare` (ScrivaniaApple.swift:1175-1215, solo iPad); la mossa del giorno da `MotoreMossaDelGiorno`
  (Motori/MotoreMossaDelGiorno.swift:177), separata dal nastro.
- **Agenda**: la fascia «Da fare e da ricordare» e «Da non dimenticare» (AgendaApple.swift:33-35, 165, 782).
- **Vera**: la card «Da non dimenticare» (AppVera.swift:300-317).
- **Attività**: `AppAttivita.swift` (su Mac ospitata nell'Agenda).
- Nessun «Annulla l’ultima».

### 3.3 Cosa fare

1. **Una fonte sola: `MotoreDaFare`.** Ogni voce delle notifiche di oggi deve avere un posto, perché il pannello delle
   notifiche sparisce. Proposta (da confermare con l'utente, vedi 3.6):

   | Voce delle notifiche di oggi | Dove va |
   |---|---|
   | Attività scadute e di oggi, proposte ferme, conformità, occasioni | già nel nastro: niente da fare |
   | Posizioni in scadenza (entro `RiepilogoPosizioni.giorniScadenza`) e scadute ancora in essere | nuovo `Tipo.scadenza`, `Fatto.segna` |
   | Compleanni (entro 7 giorni), traguardi da festeggiare | nuovo `Tipo.ricorrenza`, in «Questa settimana», `Fatto.segna` |
   | Fine anno (deducibili) | già come occasione `scadenzaFiscale`: controllare che non esca due volte |
   | Clienti da ricontattare, beneficiari da indicare, proposte fuori esperienza, adeguatezza incompleta | nuove voci per cliente (`Tipo.attenzione` o tipi propri), `Fatto.segna` o il modulo di oggi |
   | Pratiche ferme, sinistri fermi | una voce per pratica (`Fatto` apre Pratiche), coordinata con la miglioria 33 |
   | Dati da confermare nei documenti, valori di estratti conto da registrare, schede prodotto da verificare | voci «Per te» (senza cliente o del cliente del documento), `Fatto` apre il documento o la scheda |
   | Appuntamenti di oggi | restano in Agenda (non sono «da fare») |
   | Appuntamenti passati senza esito | miglioria 19 («Un impegno passato chiede com'è andato»): nell'Agenda; nel frattempo voce del «Da fare» |
   | Carta d'identità e note dall'iPhone, carte della notte, capsule pronte | **non** sono voci da spuntare: restano arrivi con il loro avviso e la loro scheda (decisioni 25 e 29: la carta senza nome, le carte senza nomi né cifre); nel pannello «Da fare» una riga in testa «Arrivati» che le apre |
   | Cose da sistemare (backup, impostazioni) | Impostazioni › Da sistemare (miglioria 31) |

   Il motore resta puro: gli ingressi nuovi arrivano già calcolati dalle cache di oggi (`MotoreNotifiche` le calcola già:
   spostare il calcolo, non duplicarlo).
2. **Voci senza cliente.** Per le attività scritte senza cliente (e per «+ Aggiungi» con «Tutti i clienti»)
   `VoceDaFare.cliente` diventa opzionale (o un `chi` con «Per te» e le iniziali dell'utente, come nel template).
3. **Stato.** In `StatoShell` (nuovo file Shell/StatoDaFare.swift): `vociDaFare(cliente:)` dal nastro in cache (il
   pannello mostra **tutte** le voci: il taglio a 8 per gruppo resta per le schede di Posizioni, oppure il pannello mostra
   «altre N» in fondo al gruppo come le schede), `numeroDaFare` (= `NastroDaFare.totale`, non il numero delle voci
   mostrate), `fatteOggi` in memoria (l'ultima per «Annulla l’ultima»), `fatto(_:)` (= `segnaFatto` + traccia per
   annullare) e `annullaUltimoFatto()`: attività → `completata = false`; segno → toglie l'attività `idSegno`; riesame →
   toglie l'incontro creato (tenerne l'id); rinnovo di conformità → rimette la data di prima (tenerla nella traccia).
   L'esito di una proposta passa da un modulo e non si annulla da qui.
4. **La barra.** Al posto della campanella la pillola «Da fare» con il numero (rosso, verde a zero); la goccia
   dell'acqua passa sulla pillola. Sul Mac `PannelloNotifiche` diventa `PannelloDaFare` (nuovo file); iPhone e iPad
   tengono il loro pannello.
5. **La riga comune** `RigaDaFare` (DesignSystem o Shell): cerchio da spuntare, pallino del tono, titolo, «<Cliente> ·
   <quando>», etichette compatte dei canali (colore del canale sempre riconoscibile). La usano pannello, scrivania,
   rubrica, dossier e agenda; parametri `conNome` (no nel dossier e con «Solo <Nome>») e `conCanali` (no nel dossier e
   nell'Agenda, come nel template), più la variante arancio del filo per l'Agenda.
6. **Il dettaglio** riusa quello delle schede di Posizioni › Portafoglio (istantanea «422-posizioni-dettaglio-da-fare»),
   presentato al centro (`DettaglioApple`) fuori da Posizioni; per le voci scritte a mano la scheda semplice.
7. **«+ Aggiungi»** crea un'`Attivita` di oggi (cliente della barra o nessuno, titolo al più 70 caratteri).
8. **Scrivania (Mac)**: `RiquadroScadenzeScrivania` diventa `RiquadroDaFareScrivania` (voci dalla seconda alla quarta,
   «Apri tutto ›» apre il pannello); la mossa del giorno: vedi 3.6. «Il tuo studio» resta dov'è.
9. **Agenda**: la fascia «Da fare e da ricordare» diventa «Da fare oggi» (due voci di oggi del cliente della barra o di
   tutti); «Da non dimenticare» esce (si coordina con la miglioria 18). **Vera**: esce «Da non dimenticare» (miglioria 27).
10. Via `notificheViste` e il numero delle «nuove» sul Mac: il numero è quello delle voci aperte.

Token in `DesignSystem/Apple/Tema.Apple+BloccoBarraNotifiche.swift` (enum `DaFare`, nuovo): pannello largo 450, padding
12×10, riga alta almeno 38, cerchio 20 filo 2, pallino 8, titolo 13,5 semibold, sotto 12, titolo di gruppo 11 maiuscolo
tracking 0,6, numero (rosso `rossoBadge`, verde `verde` a zero, 10 bold), uscita della riga (16 pt, 0,32 s), campo
«Aggiungi» (70 caratteri). Testi in `enum TestiDaFare`.

**Non fare**: non portare `MOSSA` (le frasi della mossa scritte a mano) né le voci di `TASK`: vengono dai motori.

### 3.4 Dati, archivio, privacy

Nessun campo nuovo: «Segna come fatto» scrive come oggi (attività, incontri, conformità); «+ Aggiungi» crea un'attività
(già nell'archivio e nei backup). «Fatte oggi» vive in memoria. Le voci portano nomi di clienti: in modalità cliente e
nella vista pulita la pillola e il pannello non ci sono. I promemoria di sistema restano locali come oggi e senza cifre
patrimoniali (Notifiche.swift:589).

### 3.5 Istantanee e prove

- Nuove scene, chiare e scure: «da-fare-pannello», «da-fare-solo-cliente», «da-fare-aggiungi», «da-fare-annulla»
  (con «Fatte oggi»), «da-fare-dettaglio» (fuori da Posizioni), «da-fare-scritta-da-te», «agenda-da-fare-oggi».
- Da aggiornare o sostituire: «412-scrivania-apple-notifiche», «117-notifiche-seguito», «133-notifiche-occasioni»,
  «153-notifiche-conformita», «410-scrivania-apple», «616-scrivania-luce», «118-scrivania-seguito», le scene dell'Agenda
  con la fascia.
- Prove: `--prova-calcoli` (ProvaCalcoli.swift già usa MotoreDaFare: aggiungere le fonti nuove, le voci senza cliente,
  l'ordine); `ProvaSeguito` e `ProvaPromemoria` (oggi passano dalle notifiche); una prova di «Annulla l’ultima» per ogni
  `Fatto`; `--prova-carico` e `--prova-fluidita` (il numero nella barra non rifà il nastro a ogni body).

### 3.6 Decisioni per l'utente e rischi

- **La mossa del giorno.** Il template la fa coincidere con la prima voce. Proposta: tenere `MotoreMossaDelGiorno` (ha
  ragioni e fascicolo suoi) e ordinare il nastro in modo che la sua voce sia la prima; il riquadro «Da fare» parte dalla
  seconda. In alternativa la mossa diventa davvero la prima voce del nastro.
- **I promemoria del Mac** (notifiche di sistema): proposta, restano (sono un modo di ricevere, non un elenco) ma leggono
  le stesse voci del «Da fare».
- **Compleanni e traguardi nel «Da fare»?** Proposta: sì, in «Questa settimana», con «Segna come fatto».
- **Le voci «Da sistemare»** (backup mai fatto…): proposta, solo in Impostazioni › Da sistemare (miglioria 31).
- **Le altre voci delle notifiche** (tabella in 3.3 punto 1): proposta come in tabella; in particolare gli arrivi
  dall'iPhone, le carte della notte e le capsule non diventano voci da spuntare ma una riga «Arrivati» in testa al
  pannello, che rispetta le decisioni 25 e 29 (niente nomi né cifre).
- Rischi: il nastro oggi si calcola per Posizioni; diventando la fonte della barra deve restare in cache (`DerivatiDati`,
  chiave con l'ora) e il numero non deve rifare il calcolo a ogni disegno della barra. Annullare un riesame tocca incontri
  e memoria del riesame: tenere la traccia completa.

### 3.7 Dimensione

**L.** File principali: Motori/MotoreDaFare.swift, Shell/StatoPortafoglioApple.swift, Shell/StatoDaFare.swift (nuovo),
Shell/PannelloDaFare.swift (nuovo), Shell/BarraSuperiore.swift, Shell/Notifiche.swift, Shell/ScrivaniaApple.swift,
Shell/AgendaApple.swift, Shell/AppVera.swift, Shell/PannelloNotifiche.swift, DesignSystem/Apple/Tema.Apple+BloccoBarraNotifiche.swift.
Si incrocia con le migliorie 19 (impegni senza esito), 31 (Da sistemare) e 33 (pratiche ferme) per la tabella di 3.3.

---

## 4. Una riga sola in testa alla finestra

### 4.1 Nel template

La testata della finestra `#win .hd` (riga 839, CSS 409-417) è una riga sola, alta 60: **chiusura** (`.wx`: cerchio 28,
fondo `chip`, ✕ da 12 con tratto 3, colore `ink2`; al passaggio fondo `#FF5F57` e ✕ bianca; premuto scala 0,9; aiuto
«Chiudi (esc)»), **icona** dell'app 26, **titolo** 17 bold (quello dell'app, che può dire il cliente: «Le posizioni di
Giulia.»), **sottotitolo** 12 maiuscolo (tracking 0,6, `ink2`), un **testo a destra** facoltativo (`#wRight`: 13 medium
`ink2`, con un filo a sinistra e 12 di spazio, per esempio «Tutto resta su questo Mac») e le **azioni** spinte a destra.
Titolo e sottotitolo non vanno a capo. Prima erano due righe (la barra con i tre pallini, l'icona e il nome dell'app, poi
la testata con titolo e azioni: 38 + 54); ora il contenuto parte da 60 e guadagna 32 punti. Il nome dell'app resta nella
pillola della barra. Una sola chiusura al posto dei tre pallini: «quelli veri sono del Mac» (regola 4, riga 2616). Le scene
disegnate su una tela fissa seguono la nuova altezza (`allunga()`, righe 2982-2985).

### 4.2 Nell'app oggi

- `Sources/Prisma/Shell/FinestraInterna.swift:84-133` — `barraTitolo`: `SemaforiFinestra` (tre pallini da 12 con ✕ − +
  al passaggio, righe 204-250; aiuti «Chiudi», «Riduci nel dock», «Ingrandisci (o doppio clic sulla barra)»), `IconaApp`
  da `Tema.Misura.iconaFinestra` = 20 (DesignSystem/Tema.swift:355) e `finestra.app.titolo`, a destra `ContestoFinestra`
  (di chi parla, righe 184-198) e il pulsante «Affianca» (righe 140-148); alta `Misure.Finestra.barraTitolo` = 36
  (DesignSystem/Misure.swift:239); doppio clic ingrandisce, trascinare sposta.
- Esc oggi non chiude la finestra interna davanti (chiude pannelli, ricerca, palco della Sala…, ognuno con il suo
  `.keyboardShortcut(.cancelAction)` nascosto, per esempio PannelloNovita.swift:34-36). ⌘M non è di Prisma: è il «Riduci»
  del menu Finestra di macOS e riduce nel Dock **tutta** la finestra di Prisma.
- Sotto, dentro `ContenutoApp` (ContenutoApp.swift:18), `IntestazioneApp` (ContenutoApp.swift:195-239): titolo
  `app.titoloIntestazione`, occhiello, `PulsanteComeSiUsa`, azioni; alta almeno 50 con margini 9
  (`Misure.IntestazioneApp`, Misure.swift:252-262), con fondo sfumato e filo sotto. Se lo spazio manca toglie l'occhiello,
  poi lascia ai pulsanti la sola icona (`ViewThatFits` con `\.pulsantiSoloIcona`, ContenutoApp.swift:200-238).
- Due righe, circa 86 punti, con il nome dell'app ripetuto (barra della finestra e pillola della barra).

### 4.3 Cosa fare

1. **Una riga** (solo Mac): `FinestraInterna.barraTitolo` diventa la riga unica: `ChiusuraFinestra` (nuovo, al posto di
   `SemaforiFinestra`), `IconaApp` 26, `Text(app.titoloIntestazione)`, occhiello, testo a destra, `Spacer`, azioni (le
   stesse di `ContenutoApp.azioni`, spostate in una vista a sé che non legge lo stato dei gesti della cornice).
   `ContenutoApp` sul Mac non disegna più `IntestazioneApp`; iPhone e iPad la tengono.
2. Il comportamento della riga resta quello della barra di oggi: trascinare la parte vuota sposta la finestra, doppio
   clic ingrandisce o rimette, il clic porta davanti. La riga cede spazio come oggi: prima l'occhiello, poi il testo a
   destra (le azioni senza nome sono materia della miglioria 12: per ora `ViewThatFits` di sempre).
3. **Il testo a destra**: nuova proprietà `AppPrisma.testoDestro: String?` (per Vera «Tutto resta su questo Mac»; le
   altre app come nel template). `ContestoFinestra` non c'è più: il cliente lo dice la pillola della barra (miglioria 2).
4. **Ridurre, ingrandire, affiancare** senza i pallini: vedi 4.6.
5. Esc chiude la finestra davanti, come dice l'aiuto della chiusura («Chiudi (esc)»): oggi non lo fa. È un
   `.keyboardShortcut(.cancelAction)` nascosto nella riga della finestra in primo piano, che deve cedere il passo a
   quelli che esistono già (pannelli, ricerca, dettagli, palco della Sala, schede, presentazione): attivo solo quando
   nessuno di loro è aperto, altrimenti due Esc si contendono il tasto (vedi il commento di NotaVocaleArrivo.swift:87).
   Se l'utente preferisce, l'aiuto resta «Chiudi» senza «(esc)» e il punto si toglie (vedi 4.6).

Token in `DesignSystem/Apple/Tema.Apple+DockFinestre.swift`, nuovo `enum RigaTesta`: altezza 60, padding 0/18/0/16,
spazio 10, chiusura 28 (glifo 12, tratto 3, fondo `chip`, `inchiostro2`, al passaggio `#FF5F57` e bianco, scala premuta
0,9), icona 26, titolo 17 bold (`Tema.Apple.Carattere`), sottotitolo 12 maiuscolo tracking 0,6, testo destro 13 medium
con filo `separatore` e 12 di spazio. `Misure.Finestra.barraTitolo` e `Misure.IntestazioneApp` restano per iOS.

**Non fare**: non togliere i pulsanti veri della finestra del Mac (quelli in alto a sinistra di Prisma).

### 4.4 Dati, archivio, privacy

Nessun dato. Niente privacy.

### 4.5 Istantanee e prove

Cambiano tutte le scene con una finestra aperta: vanno rigenerate e la pagina delle anteprime aggiornata. Da guardare in
particolare: «413-scrivania-apple-finestra», «430-clienti-dossier», «420-posizioni-portafoglio», «234-posizioni-finestra-stretta»,
«235-posizioni-dettaglio-stretta», «236-prospetti-finestra-stretta», «238-agenda-finestra-stretta». Nuova scena
«finestra-chiusura-passaggio» non serve (le istantanee non mostrano il passaggio del puntatore: chiedere uno screenshot).
Prove: `--prova-fluidita` (trascinare e ridimensionare non devono rifare le azioni dell'app: contare i body con
`ContaCorpi`).

### 4.6 Decisioni per l'utente e rischi

- **Solo ingrandite o tutte?** La regola dice «alla finestra ingrandita»; nel template la finestra è una sola. Proposta:
  la riga unica per tutte le finestre interne, ingrandite o no.
- **Ridurre e ingrandire senza i pallini.** Proposta: doppio clic sulla riga per ingrandire o rimettere (come oggi);
  ridurre con il menu contestuale della riga («Riduci nel dock», «Ingrandisci», «Affianca a sinistra») e dal dock;
  nessun pulsante in più. **Non** ⌘M: è il «Riduci» di macOS e manda nel Dock tutta Prisma.
- **Esc chiude la finestra** (l'aiuto del template dice «Chiudi (esc)»): proposta sì, solo quando non c'è niente
  sopra (punto 5).
- **«Affianca»**: proposta, nel menu contestuale della riga («Affianca a sinistra») e negli spazi di lavoro.
- Rischi: le azioni dell'app entrano nella cornice della finestra, che si rifà a ogni movimento del trascinamento: vanno
  in una sottovista senza dipendenze dai gesti. Le app che oggi misurano lo spazio sotto l'intestazione (Territorio,
  Radar, Campagne, Passaparola) guadagnano altezza: controllare che le tele si adattino.

### 4.7 Dimensione

**M.** File principali: Shell/FinestraInterna.swift, Shell/ContenutoApp.swift, Shell/AppPrisma.swift,
DesignSystem/Apple/Tema.Apple+DockFinestre.swift.

---

## 5. Il dossier parte dal quadro del cliente

### 5.1 Nel template

La Panoramica del dossier (`panoramicaHTML()`, righe 3262-3271) è una griglia 1,32fr 1fr alta quanto la pagina.

- **A sinistra** la card `#quadroC`: occhiello **«Il quadro di <Nome>»** e, a destra, **«Apri Analisi 360 ›»**; sotto
  una griglia 2×2 di riquadri inclinabili (al più 4 gradi; un clic apre Analisi 360): anello 76 (spessore 9) con la cifra
  dell'area al centro (per il risparmio «3,5» e «mesi» su due righe), occhiello dell'area nel suo colore (10,5), una riga
  15,5 bold «<cifra> <testo>», una riga 12,5 secondaria.
- **In fondo alla card** la riga `#datiC` (filo sopra): «Dati per l'analisi», una barra (al più 200; verde da 85%,
  altrimenti arancio), la percentuale che si conta e **«<N> da completare ›»**. Un clic apre l'elenco, che nasce dalla
  riga: «Dati per l'analisi · <Nome>», **«Completi al <N>%»**, «Più dati ci sono, meno stime fa Prisma. Questi sono quelli
  che mancano.» e una riga per dato con «Completa».
- **A destra**, una colonna: **«Da fare per <Nome>»** con il numero, «Apri tutto ›» e tre voci (miglioria 3);
  **«Prossimo incontro»** (inclinabile, «Apri in Agenda ›», giorno e ora grandi, titolo); **«Da ricordare»** (la nota del
  cliente).

Prima la Panoramica apriva sull'elenco «Dati per l'analisi» (regola 5, riga 2618).

### 5.2 Nell'app oggi

- `Sources/Prisma/Shell/DossierPanoramica.swift:18-73` — `PanoramicaDossierApple`: a sinistra la card grande
  `DatiAnalisiApple` (riga 167: percentuale, anello, voci da completare con «Completa» e la croce «non pertinente»,
  «Mostra tutte»), a destra `SussurroDossierVista`, `TrentaSecondiDossierVista`, `DaRicordareApple`, `ProssimoIncontroApple`,
  `DaFesteggiareApple`, `SinistriDossierApple`; sotto `PanoramicaCliente(conQuadro: false)` (AppClienti.swift:614:
  riesame, In regola, il dossier collegato). In modalità cliente la card dei dati non c'è.
- Le quattro aree con le cifre esistono in Analisi 360: `StatoShell.aree360(_:)` (in cache, DerivatiDati.swift:443) e le
  card di Analisi360Apple.swift.
- I token della Panoramica sono già in `Tema.Apple.Clienti.Panoramica` (DesignSystem/Apple/Tema.Apple+Dossier.swift:10:
  `proporzione` 1,25, `larghezzaDueColonne`, `sogliaVerde` 85 e i colori della percentuale), non in Tema.Apple+Clienti.swift.
  Le colonne proporzionali le fa `ColonneProporzionaliDossier`; con poco spazio va su una colonna.
- Nel dossier oggi non c'è il quadro delle quattro aree.

### 5.3 Cosa fare

1. Nuova vista `QuadroDossierApple` (nel file DossierPanoramica.swift o in un file nuovo): occhiello «Il quadro di
   <Nome>», «Apri Analisi 360 ›», le quattro aree da `stato.aree360(cliente.id)` (le stesse cifre e gli stessi testi
   brevi delle card di Analisi 360, in una variante piccola: anello 76/9), inclinabili come le card del tema; un clic
   apre Analisi 360 sull'area (con il dettaglio di quell'area, se la richiesta di oggi lo permette).
2. In fondo alla card la riga `RigaDatiAnalisi`: «Dati per l'analisi», barra, percentuale contata, «<N> da completare ›»
   da `stato.completezzaCliente(cliente.id)`. Il clic apre `DatiAnalisiApple` di oggi in un dettaglio che nasce dalla riga
   (`DettaglioApple`), con «Completa» e la croce come oggi. Se tutto è completo: «Dati completi» senza freccia.
3. Colonna di destra: «Da fare per <Nome>» (righe `RigaDaFare`, miglioria 3), poi «Prossimo incontro» e «Da ricordare»
   (componenti di oggi). Sussurro, «Il cliente in 30 secondi», «Da festeggiare» e i sinistri restano: vedi 5.6.
4. Sotto, `PanoramicaCliente(conQuadro: false)` resta com'è (sarà toccata dalla miglioria 12).
5. In modalità cliente: il quadro sì, la riga dei dati e il «Da fare» no.

Token nell'enum che c'è già, `Tema.Apple.Clienti.Panoramica` in `DesignSystem/Apple/Tema.Apple+Dossier.swift`:
`proporzione` da 1,25 a **1,32**; nuovi: anello piccolo 76/9, cifra 17 (12,5 per i mesi, su due righe «3,5» / «mesi»),
occhiello 10,5, riga 15,5 bold, testo 12,5, inclinazione massima 4 (riquadri) e 5 («Prossimo incontro»), barra dei dati
larga al più 200; `sogliaVerde` 85 resta quella di oggi.

### 5.4 Dati, archivio, privacy

Nessun campo nuovo. Le cifre vengono dai motori di oggi.

### 5.5 Istantanee e prove

Da aggiornare: «431-clienti-panoramica-apple», «430-clienti-dossier» (chiara e scura), «152-clienti-panoramica-in-regola».
Nuove: «clienti-panoramica-dati-aperti» (l'elenco nato dalla riga), «clienti-panoramica-dati-completi»,
«clienti-panoramica-modo-cliente». Prove: `--prova-fluidita` (le aree in cache con `aree360`, non ricalcolate nel body).

### 5.6 Decisioni per l'utente e rischi

- **Il sussurro e «Il cliente in 30 secondi»** (funzioni di Vera, fase 2 e 4) non sono nel template. Proposta: il
  sussurro resta in cima alla colonna di destra (al più tre voci, come da CLAUDE.md); «Il cliente in 30 secondi» diventa
  un collegamento nella testata del quadro; «Da festeggiare» e i sinistri restano sotto «Da ricordare».
- **Il clic su un'area**: proposta, apre Analisi 360 con il dettaglio di quell'area già aperto.
- Rischi: la colonna di destra si allunga; con poco spazio «Da ricordare» si taglia (nel template ha `overflow:hidden`).

### 5.7 Dimensione

**M.** File principali: Shell/DossierPanoramica.swift, Shell/Analisi360Apple.swift (variante piccola delle card),
DesignSystem/Apple/Tema.Apple+Dossier.swift.

---

## 6. Barre più corte: «Aggiungi» raccoglie cinque pulsanti, un solo «Cerca»

### 6.1 Nel template

- **Posizioni** (righe 3179-3186): nella riga in testa solo **«Aggiorna valori»** (glifo delle frecce) e il pulsante blu
  **«Aggiungi ⌄»**, che apre un menu (`apriMenu()`, righe 3097-3104; larghezza almeno 236, voci alte 36, semibold):
  **«Posizione»**, **«Proposta»**, filo, **«Importa…»**, **«Incolla da Excel»**, **«Inquadra con l’iPhone»**.
- **Clienti** (righe 3188-3190): «Nuovo cliente» diventa un pulsante diviso: a destra una freccia apre «Importa…» e
  «Incolla da Excel».
- **«Come si usa»** non è più in ogni testata: è il **«?»** della barra (`#bGuida`, riga 854) e parla dell'app aperta
  (`apriGuida()`, righe 3013-3032), con la scrivania se non c'è un'app. La scheda: occhiello «Come si usa», titolo, una
  frase, tre passi numerati, e in fondo «La guida parla sempre dell’app che hai davanti: per questo il pulsante «Come si
  usa» non è più ripetuto in ogni barra.» con «Le parole di Prisma».
- **Scrivania**: un solo «Cerca»: sparisce «⌕ Cerca ovunque» accanto a «La tua settimana» (riga 987 contro la riga 487 di
  «Luce»). Nella barra «Cerca» diventa un tasto tondo con la lente, aiuto «Cerca · ⌘K» (riga 850).

### 6.2 Nell'app oggi

- `Sources/Prisma/Shell/ContenutoApp.swift:277-327` — `AzioniPosizioni`: sei pulsanti (Aggiorna valori, Importa…, Incolla
  da Excel, Dal catalogo, Proposta, Posizione blu). «◎ Inquadra con l’iPhone» sta accanto ai segmenti del Portafoglio
  (ScenaInquadra.swift:524).
- `AzioniClienti` (ContenutoApp.swift:124-179): menu «…» con Importa e Incolla da Excel, poi il blu «Nuovo cliente» (già
  vicino al template).
- `PulsanteComeSiUsa` (PannelloGuida.swift:590) in ogni `IntestazioneApp` (ContenutoApp.swift:233).
- Il «?» della barra (BarraSuperiore.swift:169-172) apre `apriGuida(.app(stato.appAttiva ?? .clienti))`: con la scrivania
  davanti apre la guida di Clienti. Le schede «Come si usa» sono in `GuidaPrisma.aiuto(_:)` (GuidaPrisma.swift:58).
- Scrivania: «Cerca ovunque» in ScrivaniaApple.swift:355-360. Barra: pillola «Cerca ⌘K» (BarraSuperiore.swift:136-146).

### 6.3 Cosa fare

1. `AzioniPosizioni`: «Aggiorna valori» (vetro, solo fuori dalla modalità cliente come oggi) e un `Menu` blu «Aggiungi»
   con freccia: Posizione, Proposta, **Dal catalogo** (c'è nell'app e non nel template: resta, nel menu), filo, Importa…,
   Incolla da Excel, Inquadra con l’iPhone (`stato` apre la scena di oggi; senza iPhone collegato porta a Impostazioni ›
   iPhone e iPad, miglioria 39). Ogni voce tiene il suo aiuto e il blocco in sola lettura. Il pulsante «◎ Inquadra» accanto
   ai segmenti si toglie.
2. `AzioniClienti`: pulsante diviso «Nuovo cliente | ⌄» al posto del menu «…» separato (stesse voci).
3. Sul Mac `IntestazioneApp` (o la riga unica della miglioria 4) non mette più `PulsanteComeSiUsa`.
4. Il «?» apre la guida dell'app davanti; con la scrivania, una pagina nuova della scrivania: `PaginaGuida.scrivania` con
   i testi del template («La scrivania» / «La tua giornata in una schermata: la mossa del giorno, le cose da fare, i
   prossimi incontri, il portafoglio.» e i tre passi). La scheda «Come si usa» in grande prende la riga in fondo del
   template e «Le parole di Prisma». I testi delle altre app si aggiornano con quelli di `GUIDA` (righe 3014-3029) **solo
   dove descrivono ciò che l'app fa già**; le frasi che parlano di migliorie non ancora fatte (indice del dossier,
   settimana a sette giorni…) si aggiornano con quelle migliorie.
5. Scrivania: via «Cerca ovunque». Barra: «Cerca» tasto tondo con la lente (aiuto «Cerca in Prisma (⌘K)»). Aggiornare
   il testo della guida «⌘K, oppure «Cerca ovunque» sulla scrivania.» (GuidaPrisma.swift:233).

Token: nessun valore nuovo oltre a quelli dei pulsanti del tema; il menu usa lo stile dei menu di oggi.

### 6.4 Dati, archivio, privacy

Nessuno.

### 6.5 Istantanee e prove

Da aggiornare: «420-posizioni-portafoglio», «600» (testata con «Inquadra con l’iPhone», IstantaneeInquadra.swift),
«225-guida-posizioni», «226-guida-clienti», «410-scrivania-apple», «616-scrivania-luce», le scene «-finestra-stretta».
Nuove: «posizioni-menu-aggiungi» (il menu non si vede nelle istantanee: chiedere uno screenshot, oppure disegnarlo aperto
come fa la vetrina), «guida-scrivania». Prove: nessuna da toccare, salvo `ProvaGuidata` se legge «Come si usa».

### 6.6 Decisioni per l'utente e rischi

- **«Dal catalogo»** non è nel template: proposta, nel menu «Aggiungi», dopo «Proposta».
- **«Cerca» senza scritta nella barra**: il template lo vuole tondo; proposta, così, con l'aiuto e ⌘K.
- Rischi: pochi. Il menu cambia la scorciatoia d'uso dei pulsanti (un clic in più per «Posizione»): ⌘N in Posizioni resta
  libero; non aggiungerne senza chiedere.

### 6.7 Dimensione

**M.** File principali: Shell/ContenutoApp.swift, Shell/PannelloGuida.swift, Shell/GuidaPrisma.swift, Shell/ScrivaniaApple.swift,
Shell/BarraSuperiore.swift, Shell/ScenaInquadra.swift.

---

## 7. Testi piccoli più leggibili (arancione e grigio più scuri)

### 7.1 Nel template

Cambiano due toni e basta (regola 7, riga 2621; variabili alle righe 103-106; scheda dimostrativa `apriLeggibile()`,
righe 3042-3047):
- grigio del testo secondario `--ink2`: in chiaro da nero al 55% a **nero al 62%** (scuro invariato, bianco al 62%);
- grigio delle etichette `--ink3`: in chiaro da nero al 34% a **nero al 54%**; in scuro da bianco al 38% a **bianco al
  52%**;
- arancione delle scritte `--orangeT`: **#B4530B** in chiaro, **#F5A94A** in scuro. Prende il posto di `#E08A00` e di
  `#C25E00` («tra 45 giorni») dove l'arancione è un testo (scadenze, «Da incassare», «Da fare oggi», stato «avviso»,
  priorità 1, passo in corso).
- L'arancione pieno `#E08A00` resta per pallini, anelli e barre: «lì non si legge, si guarda».

Contrasti dichiarati sul bianco (minimo 4,5 per un testo piccolo): grigio delle etichette 2,4 → 4,6; arancione delle
scritte 2,7 → 5,0; testo secondario 4,7 → 6,2; «tra 45 giorni» 4,3 → 5,0. In scuro: grigio 3,2 → 4,6; arancione
4,6 → 6,3.

### 7.2 Nell'app oggi

- `Sources/Prisma/DesignSystem/Apple/TemaApple.swift:26` `inchiostro2 = d(nero(0.55), bianco(0.62))`; riga 28
  `inchiostro3 = d(nero(0.34), bianco(0.38))`; riga 84 `arancio = #E08A00` (fisso); `scadenza = #C25E00` («tra 45
  giorni»).
- Circa 90 token in DesignSystem puntano a `Colore.arancio`, sia per testi sia per segni.
- Il tema di prima (ancora usato da molte viste): `DesignSystem/Tema.swift:115-116` `inchiostroSecondario = d(nero(0.56),
  bianco(0.64))`, `inchiostroTerziario = d(nero(0.36), bianco(0.42))`.
- La carta (PDF) ha colori suoi (`Tema.Apple.Carta`), fissi.

### 7.3 Cosa fare

1. `TemaApple.swift`: `inchiostro2 = d(nero(0.62), bianco(0.62))`, `inchiostro3 = d(nero(0.54), bianco(0.52))`.
2. Nuovo token `Tema.Apple.Colore.arancioTesto = d(#B4530B, #F5A94A)` («L'arancione delle scritte»); `scadenza` diventa
   `arancioTesto`.
3. Passare in rassegna i token che valgono `Colore.arancio`: quelli usati per un **testo** (occhielli, stati, cifre «da
   incassare», «scade tra…», etichette di priorità) passano ad `arancioTesto`; quelli per pallini, anelli, barre, fondi
   al 16-18% restano `arancio`. Nessun valore sparso nelle viste: solo i token cambiano.
4. Il tema di prima: allineare `inchiostroSecondario` e `inchiostroTerziario` agli stessi valori (vedi 7.6).
5. La carta dei PDF non cambia.
6. Una piccola prova del contrasto (vedi 7.5).

### 7.4 Dati, archivio, privacy

Nessuno.

### 7.5 Istantanee e prove

Cambiano tutte le istantanee (chiare e scure): rigenerarle e aggiornare la pagina delle anteprime. Da guardare per prime:
«400-vetrina-apple» (chiara e scura), «410-scrivania-apple», le scene dell'Agenda, di Studio › Parcelle e delle scadenze.
Prova nuova nella verifica delle risorse di `--prove` (o in `--prova-calcoli`): il rapporto di contrasto WCAG di
`inchiostro2`, `inchiostro3` e `arancioTesto` sul fondo della finestra e della card, chiaro e scuro, almeno 4,5.

### 7.6 Decisioni per l'utente e rischi

- **iPhone e iPad.** I token sono condivisi: cambiando `inchiostro2`, `inchiostro3` e l'arancione cambiano anche lì.
  Proposta: accettarlo (è la stessa identità, e iPhone e iPad seguiranno comunque); se l'utente vuole i dispositivi
  intatti, i valori nuovi vanno sotto `#if os(macOS)`.
- **Il tema di prima** (`Tema.Colore.inchiostroSecondario` e `Terziario`): proposta, stessi valori, perché compare
  ancora in molte viste del Mac accanto al tema Apple.
- Rischi: `inchiostro3` colora anche segni (assi, tratteggi, maniglia di ridimensionamento): diventano più scuri. Il
  template lo cambia ovunque; se qualche tratteggio pesa troppo, un token a parte per i segni.

### 7.7 Dimensione

**S.** File principali: DesignSystem/Apple/TemaApple.swift, DesignSystem/Tema.swift, i file `Tema.Apple+*.swift` con
token di testo arancione (Agenda, Parcelle, Studio, Scrivania, Posizioni, Pratiche, Spese).

---

## 8. Il totale non è più blu Alleanza

### 8.1 Nel template

Le linee del totale (portafoglio e patrimonio) passano da `#0A84FF` al blu scuro del logo: variabile `--tot`, **#0F2433**
in chiaro e **#E3ECF2** in scuro (righe 104 e 106; regola 8, riga 2622). Dove: il grafico del portafoglio in Posizioni
(righe 1149-1152, linea, area sfumata al 22% e punto di oggi), «Il patrimonio, tre anni indietro e due avanti» (righe
1073-1079), «Il patrimonio nel tempo» delle posizioni di un cliente (righe 3165-3169, legenda «━ come oggi» nel colore
`--tot`), il capitolo «Nel tempo» della vista del cliente (righe 3300-3302). Il blu pieno resta ad Alleanza, sempre con il
suo nome, e ai comandi. Anelli e colori delle aree non cambiano. La tratteggiata viola delle proposte resta.

### 8.2 Nell'app oggi

- `Sources/Prisma/DesignSystem/Apple/Tema.Apple+Grafici.swift:94` — `Grafico.Portafoglio.coloreStoria = Colore.anello2`
  (`#0A84FF`), disegnato in GraficiApple.swift:579-589.
- `Sources/Prisma/DesignSystem/Apple/Tema.Apple+NelTempoFamiglia.swift:32` — `Clienti.NelTempo.colorePassato =
  Colore.anello2` (Dossier › Nel tempo, DossierNelTempo.swift:204 e 220).
- Il grafico del cliente nel dettaglio di una scheda «Da fare» usa la tinta del cliente (PortafoglioApple.swift:828): non
  è un totale, resta.
- I PDF hanno il loro blu (`Tema.Apple.Carta.bluGrafico`).

### 8.3 Cosa fare

1. Nuovo token `Tema.Apple.Colore.totale = d(#0F2433, #E3ECF2)` in TemaApple.swift («la linea del totale»).
2. `Grafico.Portafoglio.coloreStoria` e `Clienti.NelTempo.colorePassato` → `Colore.totale` (area e punto di oggi
   seguono, perché leggono lo stesso token). Le legende che mostrano la linea («━ com'era», «━ come oggi») prendono lo
   stesso token.
3. Cercare le altre linee di un totale di portafoglio o patrimonio con `anello2` (Posizioni, Dossier, scrivania) e
   portarle a `totale`; non toccare anelli, aree, Studio (la linea dei ricavi dell'anno non è un patrimonio), Mercato,
   Radar.
4. La carta dei PDF non cambia.

### 8.4 Dati, archivio, privacy

Nessuno. Il colore dei canali resta quello di sempre (Alleanza #2563EB).

### 8.5 Istantanee e prove

Da aggiornare: «420-posizioni-portafoglio» (chiara e scura), «421-posizioni-con-proposte», «434-clienti-nel-tempo»,
«435-clienti-nel-tempo-passato», le scene «298-scrivania-vera-portafoglio-canali» se mostrano la linea. Nessuna prova.

### 8.6 Decisioni per l'utente e rischi

- **iPhone e iPad**: stessi token, quindi cambierebbero anche lì. Proposta: accettarlo; altrimenti `#if os(macOS)`.
- **I PDF**: il template non ne parla. Proposta: restano come sono (carta fissa, CLAUDE.md).
- Rischi: in chiaro il blu del logo è vicino al testo: la linea va tenuta più spessa del testo (spessori di oggi, 2,6).

### 8.7 Dimensione

**S.** File principali: DesignSystem/Apple/TemaApple.swift, DesignSystem/Apple/Tema.Apple+Grafici.swift,
DesignSystem/Apple/Tema.Apple+NelTempoFamiglia.swift.

---

## 9. Niente nomi tecnici in vista (e l'assistente si chiama Vera)

### 9.1 Nel template

- Riquadro di Vera sulla scrivania (riga 1001): «Vera» e sotto un pallino verde 7 con **«Pronta»** al posto di «Qwen sul
  Mac · pronto» (riga 497 di «Luce»).
- Il nome del motore sta solo in **Impostazioni › Vera** (riga «Motore»: «Qwen sul Mac · qwen3.5:4b con Ollama, solo
  indirizzi locali.», riga 1322). Regola 9, riga 2624: «Vera · pronta».
- Nei messaggi di Vera l'intestazione è «Vera» o «Vera · Calcoli di Prisma» (riga 1258). Nelle regole vicine: «Scritto da
  Eve con qwen…» sparisce dai Messaggi (regola 26), la colonna di Vera dice «Vera · pronta» (regola 27).

### 9.2 Nell'app oggi

- Scrivania: `Sources/Prisma/Shell/ScrivaniaApple.swift:1094` — `"\(nomeMotore) · pronto"` / `"· non pronto"`
  (nome dal motore: `stato.qwen.nome`).
- App Vera: `Sources/Prisma/Shell/AppVera.swift:184` — `"\(q.nome) · pronto"`, il motivo di Ollama, «Verifica»; riga 204
  «Smista: regole e Qwen · Apple spento» con «Motori».
- Messaggi: `Sources/Prisma/Shell/SessioneMessaggi.swift:275` — «Scritto da Vera con <modello>».
- L'etichetta sotto ogni risposta: il testo lo compone `EtichettaMotore.per(_:)` in
  `Sources/Prisma/Vera/CervelloGrandeVera.swift:150-176` («Sul Mac · <nome del motore> · dati del cliente» in modalità
  lavoro, «Sul Mac · <nome>» in conversazione, dove il nome oggi è «Qwen»; «Sul Mac · Vera su misura»; «Sul Mac ·
  modello Apple»; «Sul Mac · regole e calcoli di Prisma»; «Motore esterno · nessun dato dei clienti»); la disegna
  `Sources/Prisma/Shell/EtichettaMotoreVista.swift`, che usano anche la Vera della scrivania, iPhone e iPad. Regola 3 del
  cervello grande, bloccata nel codice (CLAUDE.md, Vera fase 5); `ProvaCervelloGrandeVera.swift:82-84` controlla i testi.
- Il titolo «Qwen non è pronto» compare in 31 file, 24 senza contare le prove (Vera/ e Shell/: MiniVera, NucleoVera, MessaggiVera,
  VistaMiniVera.swift:171 e 236, MiniVeraShell.swift:206, CollegaMotoriShell.swift:60, StudioPalestra.swift:50,
  CollegaPassiShell.swift:15…), ed è usato anche come chiave nei confronti.
- Impostazioni: «Qwen sul Mac» (AppImpostazioni.swift:277, ImpostazioniPagine.swift:293): lì resta.

### 9.3 Cosa fare

1. Un posto per i testi dello stato: `enum TestiStatoVera` (in Shell/ o Vera/) con `pronta = "Pronta"`, `nonPronta =
   "Non pronta"`, `titoloNonPronta = "Vera non è pronta"` e la spiegazione senza nomi tecnici («Vera non risponde ancora:
   controlla in Impostazioni › Vera.»).
2. Scrivania: «Vera», pallino (verde pronta, arancio o rosso non pronta: token di oggi `coloreNonPronto`) e «Pronta» /
   «Non pronta».
3. App Vera: «Vera · pronta» / «Vera · non pronta»; il motivo tecnico (Ollama, modello mancante) solo in Impostazioni ›
   Vera, che si apre con «Verifica» / «Apri Impostazioni › Vera». La riga «Smista: regole e Qwen · Apple spento» con
   «Motori» va in Impostazioni › Vera.
4. Il titolo «Qwen non è pronto» diventa `TestiStatoVera.titoloNonPronta` ovunque si mostra, e i confronti fra titoli
   usano la costante, non la stringa (MiniVeraShell.swift:206, VistaMiniVera.swift:236, CollegaMotoriShell.swift:60).
   Gli altri testi con «Qwen» in vista (palestra, passi, mini Vera «Qwen si avvia sul Mac…») dicono «Vera».
5. Messaggi: «Scritto da Vera» senza il modello (la riga sparisce del tutto con la miglioria 26).
6. L'etichetta sotto le risposte: vedi 9.6.
7. Restano invariati i valori salvati e i nomi di compatibilità («eve», `impostazioni.eve`…, CLAUDE.md) e le istruzioni
   in Vera/.

### 9.4 Dati, archivio, privacy

Nessun campo nuovo; `MessaggioVera.motore` salvato resta com'è (cambia solo come si mostra). La regola del cervello
grande (etichetta sempre visibile, mai dati dei clienti) non si indebolisce.

### 9.5 Istantanee e prove

Da aggiornare: «410-scrivania-apple», «296-scrivania-vera», «297-scrivania-vera-risposta», «244-vera-mini-nonpronta»,
«251-impostazioni-vera», le scene dell'app Vera e dei Messaggi. Prove: `--prova-vera` (ProvaMiniVera, ProvaNucleoVera,
ProvaMessaggiVera, ProvaVeraScrivania, ProvaPalestraVera, ProvaLetteraVera, ProvaScenariVera controllano «Qwen non è
pronto»: passano alla costante), `ProvaCervelloGrandeVera` (l'etichetta del motore esterno resta).

### 9.6 Decisioni per l'utente e rischi

- **L'etichetta sotto ogni risposta** è bloccata dalla regola 3 del cervello grande. Proposta: le etichette restano
  sempre visibili; quella del motore esterno non cambia; quelle locali di Qwen passano da «Sul Mac · Qwen · dati del
  cliente» / «Sul Mac · Qwen» a «Sul Mac · Vera · dati del cliente» / «Sul Mac · Vera» (in `EtichettaMotore.per`, solo
  per il nome di Qwen; «Vera su misura», «modello Apple» e «regole e calcoli di Prisma» restano, perché dicono una cosa
  diversa); `ProvaCervelloGrandeVera` si aggiorna. Serve il via dell'utente, perché tocca una regola bloccata. Il testo è
  condiviso con iPhone e iPad: o cambia anche lì (stessa scelta di 7.6 e 8.6) o va sotto `#if os(macOS)`.
- **«Smista» e «Motori»** fuori dalla colonna di Vera: proposta, in Impostazioni › Vera.
- Rischi: molti file toccati per una stringa; i confronti fra titoli vanno tutti sostituiti insieme, altrimenti la mini
  Vera smette di riconoscere lo stato «non pronta».

### 9.7 Dimensione

**M.** File principali: Shell/ScrivaniaApple.swift, Shell/AppVera.swift, Vera/CervelloGrandeVera.swift (testo
dell'etichetta), Shell/EtichettaMotoreVista.swift,
Shell/SessioneMessaggi.swift, Shell/MiniVeraShell.swift, Shell/VistaMiniVera.swift, Shell/CollegaMotoriShell.swift,
Vera/MiniVera.swift, Vera/NucleoVera.swift, Vera/MessaggiVera.swift, Shell/ImpostazioniPagine.swift.

---

## 10. Le stesse parole ovunque

### 10.1 Nel template

Una parola sola per ogni cosa (`PAROLE`, righe 3035-3038; regola 10, riga 2625). A sinistra la parola che resta, a
destra quelle che spariscono:

| Resta | Spariscono |
|---|---|
| Dossier | Scheda, Fascicolo del cliente |
| Da fare | Notifiche, Attività, Promemoria, Da non dimenticare, Richiede attenzione |
| Mostra al cliente | Modalità cliente, Presenta al cliente, Presenta all’incontro |
| Vera | Eve, Ruby, Qwen |
| Preparami l’incontro | Prepara con Eve, Prepara l’incontro |
| Tutti i clienti | Portafoglio (come scelta del cliente) |
| Il quadro | Panoramica delle aree, Check-up (a schermo) |
| Posizioni: il cuore di Prisma | «Il centro della consulenza» detto di un’altra app |
| In essere | Attive, In corso |
| Proposta | Ipotesi, Preventivo |
| Riesame | Revisione periodica, Check annuale |
| Cerca | Cerca ovunque (secondo pulsante sulla scrivania) |
| Per il cliente · Per te | Report e Prospetto, come nomi delle due versioni di un documento |
| Tono · Invia con | I due selettori senza nome dei messaggi; «Canale» per dire Mail o Messaggi |
| Dimostrazione | Dati di prova, Strumenti › Clienti di prova |
| Da sistemare | Panoramica (nelle Impostazioni), il pallino arancione |

«Vale per pulsanti, titoli, notifiche e documenti. Le parole tecniche che il cliente legge (SRI, in essere, capitale caso
morte) si spiegano con un tocco nella vista «Mostra al cliente».» La scheda `apriParole()` è dimostrativa.

### 10.2 Nell'app oggi

Conteggi indicativi delle parole da cambiare nei testi in vista (Shell, Vera, DesignSystem, PrismaApp; esclusi commenti e
prove): «modalità cliente» circa 85 (di cui 6 con la maiuscola), «Notifiche» circa 140 (molte sono nomi di tipi e
commenti), «Promemoria» circa 100 (molti per i promemoria di sistema e la pagina «Promemoria e occasioni», che resta),
«Prepara l'incontro» 7 accanto a «Preparami l'incontro» 3, «Check-up» 6, «Scheda cliente» 4, «Dati di prova» 10,
«Clienti di prova» 1, «Cerca ovunque» 5, «Canale» per Mail o Messaggi in Messaggi, «Panoramica» 31 (in Impostazioni e
nel dossier). Il glossario (`Glossario.swift`, sezione «Le parole di Prisma»: inEssere, canale, dossier, riesame,
prospettoReport, patrimonioNetto, riservaLiquidita) ha già alcune di queste parole.

### 10.3 Cosa fare

1. **Un elenco solo nel codice**: `enum Parole` (Shell/ParolePrisma.swift) con le parole che restano come costanti
   («Dossier», «Da fare», «Mostra al cliente», «Preparami l’incontro», «Tutti i clienti», «Il quadro», «In essere»,
   «Proposta», «Riesame», «Cerca», «Per il cliente», «Per te», «Tono», «Invia con», «Dimostrazione», «Da sistemare»):
   le migliorie che seguono le usano da lì.
2. **In questo gruppo** si cambiano solo le parole delle schermate che il gruppo tocca: «Mostra al cliente» (1), «Tutti
   i clienti» (2), «Da fare» (3), «Il quadro» (5), «Cerca» (6), «Vera» (9), «Preparami l’incontro» al posto di «Prepara
   l'incontro» nei pulsanti (scrivania, schede «Da fare», Analisi 360). Le altre righe della tabella si cambiano con le
   migliorie che rifanno quelle schermate: «Per il cliente · Per te» (22), «Tono · Invia con» (26), «Da sistemare» (31),
   «Dimostrazione» (37); «In essere», «Proposta» e «Riesame» dove compaiono «Attive», «In corso», «Ipotesi»,
   «Preventivo» come nomi dello stato di una posizione. Il «Cerca ovunque» del menu «Vai» (PrismaApp.swift:126)
   diventa «Cerca» insieme alla 6; «Modalità cliente» del menu diventa «Mostra al cliente» insieme alla 1.
3. **Il glossario**: aggiungere alla sezione «Le parole di Prisma» le voci che mancano («Da fare», «Mostra al cliente»,
   «Tutti i clienti», «Il quadro») e togliere dai testi i sinonimi sostituiti.
4. «Posizioni: il cuore di Prisma»: nessuna altra app si descrive come «il centro della consulenza». Oggi lo fa
   l'occhiello di Analisi 360 (`AppPrisma.occhiello`, AppPrisma.swift:135: «Il centro della consulenza», che si vede
   nella testata della finestra) e il commento di AppAnalisi360.swift:3: l'occhiello diventa una frase sul suo lavoro
   (per esempio quella della guida del template: «Previdenza, protezione, investimenti e risparmio di una persona»).
5. Non cambiare: nomi di tipi e di file, valori salvati, chiavi (CLAUDE.md: «eve», `impostazioni.eve`…), i testi dei PDF
   già scritti nei documenti del cliente, la pagina «Promemoria e occasioni» delle Impostazioni.

### 10.4 Dati, archivio, privacy

Nessun dato. I testi in Vera/ (prompt) possono citare le parole nuove, ma non sono interfaccia: cambiarli solo se una
risposta di Vera mostra la parola vecchia all'utente.

### 10.5 Istantanee e prove

Le scene delle schermate toccate dalle migliorie 1-9. Prove: `ProvaGuidata` e le prove di Vera che confrontano testi
(«Modalità cliente», «Prepara l'incontro») vanno allineate; una prova semplice che nessun testo in vista del Mac contenga
le parole che spariscono è utile ma difficile da fare bene sul codice SwiftUI: proposta, un controllo statico nel
workflow (grep sulle stringhe tra virgolette in Sources/Prisma/Shell, con un elenco di eccezioni).

### 10.6 Decisioni per l'utente e rischi

- **«Promemoria»** resta per i promemoria di sistema del Mac e per la pagina «Promemoria e occasioni»? Proposta: sì;
  sparisce solo come nome dell'elenco delle cose da fare.
- **«Attività»** sparisce come nome dell'elenco, ma l'app Attività esiste ancora su iPhone e iPad e i dati si chiamano
  attività: proposta, sul Mac le cose scritte a mano sono «cose da fare» del «Da fare»; nell'Agenda (mese e giorno) la
  parola si rivede con la miglioria 18.
- Rischi: cambiare testi usati come chiave (titoli confrontati, `help` letti dalle prove). Fare il giro con grep prima di
  ogni sostituzione.

### 10.7 Dimensione

**S** per questo gruppo (l'elenco e le parole delle schermate 1-9); il resto si distribuisce sulle altre migliorie.
File principali: Shell/ParolePrisma.swift (nuovo), Shell/Glossario.swift, Shell/GuidaPrisma.swift, Shell/AppPrisma.swift,
PrismaApp.swift.
