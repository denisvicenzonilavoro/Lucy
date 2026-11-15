# Gruppo 07 — Posizioni fino in fondo (migliorie 40-44)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), secondo passaggio («14 novembre,
sera»). Le righe citate sono quelle della copia senza immagini Design/uso/.template-senza-immagini.html (stesse righe
del template). Commento in testa: righe 52-58; CSS del gruppo: righe 677-701; codice: righe 4272-4442 (sezioni «40 ·» …
«44 ·»); pannello «✦ Migliorie»: `MIG7`, righe 4436-4441. La base «Luce» che le migliorie ridefiniscono: `fuocoHTML`,
`montaFuoco`, `ricalcola` (righe 1564-1586), `apriScanner` (1589-1597), `radarHTML` e `montaRadar` (2425-2447), `SMN`,
`smontaHTML`, `montaSmonta` (2449-2463), `apriNuovo` (2487-…), `barraPos`/`agganciaBarraPos` (3181-3182). Solo Mac:
iPhone e iPad restano come sono (attenzione ai file comuni: `RigaSchedaInquadra`, `MotoreInquadra`, i motori).

**Codice comune con l'iPad (vale per tutto il gruppo).** Le viste toccate qui non sono solo del Mac: l'iPad disegna
Posizioni con la stessa `AppPosizioni` (`iOS/GuscioiPad.swift:79` → `ContenutoApp` → `AppPosizioni`), e quindi con le
stesse `RadarPortafoglioApple`, `ProvaDelFuocoApple`, `SmontaggioApple` e `PannelloAggiornaValori` (in questi file oggi
ci sono solo pochi `#if os(macOS)`). Come per il gruppo 01, ogni cambiamento di comportamento va dentro `#if os(macOS)`
o in viste nuove solo Mac (per la 44, che rifà il pannello, un file nuovo solo Mac e il pannello di oggi lasciato
all'iPad); i motori e i testi nuovi si possono condividere perché l'iPad non li chiama. Le istantanee dell'iPad (che
girano su main) devono restare uguali. Solo Inquadra e Nuovo cliente (43) stanno già in viste solo Mac
(`SchedaInquadraMac`, `SchedaNuovoClienteMac`). Vedi la decisione in fondo («Le migliorie arrivano anche sull'iPad?»).

Il pannello «✦ Migliorie» (`MIG7`) e il cartellino `indica(...)` sono solo dimostrativi: nell'app **non** vanno portati.
Le cifre del template (`RAD`, `FUOCO`, `SMD`, `AGG`, le percentuali «Vita intera · altra compagnia», «Valori di
novembre.xlsx») sono di prova: nell'app le cifre le danno i motori di oggi (`MotoreRadar`, `MotoreProvaFuoco`,
`MotoreSmontaggio`/`MotoreSostituzione`, `MotoreInquadra`, `MotoreCartaIdentita`, `AggiornaValori`).

## Ordine consigliato

1. **Un componente comune prima di tutto**: la capsula di stato `.st2` del template (testo 11,5 bold, padding 3×9,
   capsula, toni `ok` verde, `avv` arancio, `ko` rosso, `neu` grigio). La usano la 40 (le righe del radar), la 41 (i tre
   gruppi) e la 44 (Da decidere · Pronti). Se il gruppo 02 (miglioria 13, `StatoArrivoObiettivo`) o il gruppo 05 l'hanno
   già fatta, si riusa quella; altrimenti si crea qui `CapsulaStatoApple` (vedi 40.3) e gli altri la riusano. Attenzione:
   la capsula del gruppo 02 è più grande (testo 12,5, padding 4×11, stessa `.st2` con lo stile in linea della 13);
   quella di questo gruppo è la `.st2` di base (11,5, 3×9). Un solo componente con due misure (`.normale`, `.grande`),
   non due componenti.
2. **40 · Il radar dice chi e perché**: tutta nella colonna di destra del radar, motore già pronto. Piccola e senza
   dipendenze (salvo il pulsante «Apri le posizioni di …», che usa la vista «Coerenza con il profilo» della miglioria 14
   del gruppo 02; finché non c'è, si usa `ancoraPosizioni = "coerenza"` come oggi).
3. **41 · La prova del fuoco in tre gruppi**: serve qualche campo in più nella riga del motore (quote e anni per «Perché»)
   e il dettaglio che nasce dalla riga (come il radar). «Segna «da chiamare»» scrive un'attività: con la miglioria 3 del
   gruppo 01 («un solo Da fare») il testo dell'avviso dice «Da fare»; «Apri la sua prova di resistenza» usa la vista
   `.resistenza` della miglioria 14 (o l'ancora di oggi).
4. **44 · Aggiorna valori: prima i dubbi**: riordina il pannello di oggi e aggiunge «Annulla la registrazione». Il
   pulsante che lo apre sta nella riga in testa (miglioria 4) accanto ad «Aggiungi» (miglioria 6): si può fare prima, sul
   pulsante di oggi in `AzioniPosizioni`. Il filtro per cliente usa «un solo posto per il cliente» (miglioria 2).
5. **43 · Prima di aggiungere, si controlla**: tocca Inquadra e Nuovo cliente, due scene già complete. Va dopo la 6
   (l'«Inquadra con l’iPhone» entra nel menu «Aggiungi») e prima o insieme alla 39 (iPhone e iPad: un collegamento
   solo), perché i testi «Senza iPhone?» rimandano al collegamento. Attenzione al codice comune con l'iPhone.
6. **42 · Lo smontaggio ha i numeri**: la più lunga. Dipende dalla miglioria 14 (l'indice di Posizioni del cliente,
   dove entra «Smontaggio di un documento») e dalla 2 (con «Tutti i clienti» si sceglie fra i documenti di tutti).

Dopo ogni miglioria: build verde, prove, istantanee rigenerate e pagina delle anteprime aggiornata.

---

## 40. Il radar dice chi e perché

### 40.1 Nel template

Righe 4278-4302 (`RADCOL`, `RADN`, `radFuori`, nuova `radarHTML`, estensione di `montaRadar`); CSS righe 677-679. Si
apre con `vaiM('posizioni')` e `vistaP='radar'` con «Tutti i clienti» (`MIG7[0]`, cartellino su `#radChi`).

**La tela scura resta com'è** (cerchi, settori dei modelli, fascio, punti, clic sul punto che apre il dettaglio). Cambia
la colonna di destra, che ora ha **due card** (prima erano tre più una nota in fondo):

1. **«I tuoi portafogli modello»** (padding 16×22): per ogni modello una riga sola — il nome nel colore del modello
   (bold 13,5, largo 92) e accanto la barra divisa nelle quattro classi (alta 9, raggio 6, spazio 2). **I pesi scritti
   («20 · 55 · 20 · 5») non ci sono più.** Sotto, **la legenda con i colori**: quattro quadratini 9×9 (raggio 3) con
   «Azioni», «Obbligazioni», «Gestione separata», «Liquidità» (12, `ink2`, a capo se serve). Prima era la sola riga di
   testo «Azioni · obbligazioni · gestione separata · liquidità».
2. **La card «chi»** (`#radChi`, occupa tutto lo spazio che resta, padding 16×22×14):
   - in testa, sulla stessa linea di base: il numero dei fuori tolleranza (34, arancio), «fuori tolleranza» (15 bold) e
     a destra «su {N} seguiti con un modello» (`k`);
   - sotto, **«punti» spiegato una volta**: «Un punto è un centesimo del portafoglio finito fuori posto rispetto al
     modello scelto. Fino a 5 punti va bene.» (`k`, interlinea 1,45);
   - **l'elenco di TUTTI i clienti fuori tolleranza** (prima erano i tre più lontani, compresi quelli dentro), dal più
     lontano, che scorre senza barra: per riga avatar 26, nome in grassetto e «· {Modello}» in grigio, a destra la
     capsula arancio «{7,8} punti» (`st2 avv`), poi «›»; righe con il filo sotto e lo sfondo `chip` al passaggio (`.pk`);
   - **passando su una riga si accende il suo punto** sulla tela (classe `su`: alone bianco `drop-shadow(0 0 7px)` e il
     nome sotto il punto, `.rNm2`); **toccando la riga si apre la stessa scheda** del punto (il dettaglio nasce dal
     punto, non dalla riga);
   - il pulsante blu a tutta larghezza **«Prepara le {n} proposte di riequilibrio»** (prima «Riequilibra i {n}
     clienti»: ora dice che prepara proposte, non che sposta soldi);
   - sotto: «Una per cliente, con costi e tasse. Restano proposte: niente parte senza di te.»
3. **Sparisce** la card «I più lontani dal modello» e la nota in fondo («Più un cliente è lontano dal centro…»).

Sulla tela, il nome dei punti piccoli compare solo al passaggio (`.rNm2`, opacità 0 → 1 in 0,2 s).

**Dopo il pulsante** (righe 4296-4302, il ritardo è quello della base: 1,76 s): il numero scende a 0 e i punti fuori si
spostano verso il centro (base «Luce»), ogni capsula diventa «Proposta pronta» (`st2 ok`), il pulsante
«✓ Proposte pronte, una per cliente», l'etichetta «fuori tolleranza, se le accetti tutte», la spiegazione «Con le
proposte accettate tornerebbero tutti dentro la tolleranza: sulla tela vedi dove andrebbero.»

**Nel dettaglio del punto** (base: barre «oggi / modello», «Il riequilibrio proposto», «Prepara la proposta») si
aggiunge, per i clienti veri, il pulsante **«Apri le posizioni di {nome}»**, che chiude il dettaglio e apre le Posizioni
del cliente sulla vista «Coerenza con il profilo» (`posV='coerenza'`).

### 40.2 Nell'app oggi

- `Shell/RadarPortafoglio.swift`: `RadarPortafoglioApple` (:25), `CorpoRadar` (:70, colonna in `colonnaVista` :141),
  `RadarModelli` (:176, la tela: due `Canvas`, fumetto al passaggio), `PuntatoreRadar` (:412, `@Observable`, `sopra`),
  `FumettoRadar` (:417, l'unica vista che legge il puntatore: nome, modello, distanza), `CardModelliRadar` (:644, nome,
  pesi scritti, barra; sotto `TestiRadar.leggendaClassi`), `CardConteggioRadar` (:692, numero, «sul radar», pulsante
  «Riequilibra i N clienti», `spiegaRiequilibra`, link «N clienti senza modello ›»), `CardLontaniRadar` (:752, i tre più
  lontani con `BarraPiena` arancio), la nota in fondo (`TestiRadar.piede`, `senzaTolleranza`, `previdenzaEsclusa`),
  `DettaglioRadar` (:796, pulsanti «Prepara la proposta» / «✓ Proposta pronta» e «Apri il dossier» :861-864).
- `Motori/MotoreRadar.swift`: `RadarPortafoglio.fuori` (:78, già tutti i fuori dal più lontano), `piuLontani` (:79),
  `daRiequilibrare` (:81), `VoceRadar.tolleranza`/`fuori`/`bozzaPronta`; `TestiRadar` (:264-405).
- Token: `DesignSystem/Apple/Tema.Apple+Radar.swift` (`Radar.Colonna` :119, `Radar.Dettaglio` :156), colori delle
  classi `Tema.Apple.Posizioni.Radar.colore(_ classe:)`.
- Già come il template: i punti al passaggio danno nome e distanza (fumetto); clic su una riga dei «più lontani» apre il
  dettaglio; «Riequilibra» prepara bozze e i punti **restano al loro posto** con il trattino verso dove andrebbero
  (decisione 2 di «Luce»). Manca: la legenda a colori, la spiegazione dei punti, l'elenco completo dei fuori, la riga che
  accende il punto, i testi nuovi del pulsante, la capsula «Proposta pronta» per riga, «Apri le posizioni di …».

### 40.3 Cosa fare

1. **Capsula di stato comune** (se non c'è già da un altro gruppo): `DesignSystem/Apple/CapsulaStatoApple.swift`,
   `struct CapsulaStatoApple: View { let testo: String; let tono: Pillola.Tono }` (riusa i toni di `Pillola.Tono`
   `.ok/.attenzione/.errore/.neutro`, come `StatoRigaApple`). Token in un nuovo
   `DesignSystem/Apple/Tema.Apple+Capsula.swift` se libero, altrimenti nel file che il gruppo 02 avrà scelto: carattere
   11,5 bold, padding 3×9, fondi `verde 0,15`, `arancio 0,16`, `rosso 0,13`, `chip`; testi `#1F7A41`/`#6FD08E` (scuro),
   arancio del testo (`--orangeT`, miglioria 7), `#C2333A`/`#FF8A8F`, `inchiostro2`.
2. `CardModelliRadar`: riga unica nome (larghezza token `Colonna.nomeModello` 92) + `BarraPienaSegmenti`; i pesi
   escono dalla vista e vanno nell'aiuto della riga (`.help("\(m.nome): \(TestiRadar.pesi(m.pesi)) · apri in Impostazioni
   › Portafogli modello")`); al posto di `leggendaClassi` una `LeggendaClassiRadar` (HStack a capo con quadratino 9,
   raggio 3, colore `Radar.colore(classe)`, nome da `TestiRadar.nomeClasse`).
3. Nuova `CardChiRadar` al posto di `CardConteggioRadar` + `CardLontaniRadar` (le due si tolgono), con `frame(maxHeight:
   .infinity)` quando la colonna è affiancata (l'elenco scorre dentro la card; nella finestra stretta l'elenco si allunga
   nella ScrollView di oggi):
   - testa: `NumeroCheConta` del numero (vedi sotto), `TestiRadar.etichettaFuori(...)`, a destra
     `TestiRadar.suSeguiti(radar.voci.count)` = «su {N} seguiti con un modello» (aiuto: `previdenzaEsclusa`);
   - spiegazione: `TestiRadar.cosaSonoIPunti(tolleranza)` = «Un punto è un centesimo del portafoglio finito fuori posto
     rispetto al modello scelto. Fino a {5} punti va bene.» con la tolleranza **delle impostazioni**
     (`radar.tolleranzaGenerale`, formattata con `TestiRadar.punti`); senza tolleranza la frase di oggi
     `senzaTolleranza`; senza modelli resta l'invito sopra la tela (`avvisoVuoto`) e la card mostra solo il pulsante
     «Imposta i modelli»;
   - elenco: `LazyVStack` su `radar.fuori` (già ordinato); riga `RigaChiRadar` con `AvatarCliente` 26, nome +
     «· {Modello}», `CapsulaStatoApple(testo: TestiRadar.puntiConNome(v.distanza), tono: .attenzione)` oppure, con la
     bozza pronta, `CapsulaStatoApple(testo: "Proposta pronta", tono: .ok)`, poi «›». Sfondo al passaggio con il token
     `Colonna.fondoRigaSopra` (`chip`), raggio 10;
   - **la riga accende il punto**: `PuntatoreRadar` sale da `RadarModelli` a `CorpoRadar` (passato come parametro, così
     tela e righe leggono lo stesso oggetto); `onHover` della riga scrive `puntatore.sopra = v.id` (e nil all'uscita).
     Solo `FumettoRadar` legge il puntatore, quindi passare sulle righe non ridisegna tela né colonna. In
     `FumettoRadar`, quando il puntatore viene da una riga, si aggiunge sotto il fumetto l'alone del punto (un cerchio con
     ombra bianca, token `Radar.aloneSopra` raggio 7 opacità 0,9);
   - clic: `apri(v.id)` come oggi (il dettaglio nasce dall'ancora del punto);
   - pulsante: `TestiRadar.pulsanteRiequilibra(n)` diventa «Prepara le {n} proposte di riequilibrio» (n = 1: «Prepara la
     proposta di riequilibrio»); a lavoro finito «✓ Proposte pronte, una per cliente»; con zero fuori «Tutti entro la
     tolleranza» (di oggi); `spiegaRiequilibra` diventa «Una per cliente, con costi e tasse. Restano proposte: niente
     parte senza di te.»;
   - dopo la preparazione: il numero mostra **quanti resterebbero fuori accettando le proposte**
     (`radar.daRiequilibrare.count`, quindi 0 quando le bozze sono tutte pronte), l'etichetta «fuori tolleranza, se le
     accetti tutte» e la spiegazione «Con le proposte accettate tornerebbero tutti dentro la tolleranza: sulla tela vedi
     dove andrebbero.». I punti restano dove sono con il trattino (decisione 2 di «Luce»): non si portano al centro;
   - il link «N clienti senza modello ›» resta, sotto il testo del pulsante.
4. Via la nota in fondo (`TestiRadar.piede`); `previdenzaEsclusa` va nell'aiuto di «su N seguiti».
5. `DettaglioRadar`: «Apri il dossier» diventa «Apri le posizioni di {nome breve}» (vedi 40.6): chiude il dettaglio,
   `stato.clienteAttivoId = v.clienteId`, `portafoglio = false`, vista `.coerenza` della miglioria 14
   (`VistaPosizioniCliente`) o, prima di quella, `stato.ancoraPosizioni = "coerenza"`. Nuova funzione in `StatoShell`
   (estensione a :936): `apriPosizioniDalRadar(_ clienteId:)`. Il doppio clic sul punto continua ad aprire il dossier.
6. Token nuovi in `Tema.Apple+Radar.swift` (`Radar.Colonna`): `nomeModello` 92, `quadratinoLeggenda` 9, `raggioLeggenda`
   3, `spazioLeggenda` (6, 14), `numeroChi` 34, `avatarChi` 26, `rigaChi` (padding 5×6), `fondoRigaSopra`, `raggioRiga`
   10, `paddingChi` (16, 22, 14), `aloneSopra`.

**Non fare**: non scrivere «Fino a 5 punti» fisso; non spostare i punti al centro dopo il pulsante; non togliere la
tastiera di oggi (Tab, Invio, Esc sul radar).

### 40.4 Dati, archivio, privacy

Nessun campo nuovo. Le bozze sono quelle di oggi (`preparaBozzeRiequilibrio`). Il radar resta chiuso in modalità cliente
(`apriRadar` :966).

### 40.5 Istantanee e prove

- Da aggiornare: «890-posizioni-radar» (e -scuro), «894-posizioni-radar-bozze» (capsule «Proposta pronta», numero 0,
  etichetta «se le accetti tutte»), «893-posizioni-radar-senza-modelli», «895-posizioni-radar-carico» (elenco lungo che
  scorre dentro la card), «897-posizioni-radar-stretta», «891»/«892» (pulsante «Apri le posizioni di …»).
- Nuova (898 è libero oggi): «898-posizioni-radar-riga-accesa» (puntatore scritto su un cliente fuori: `s.radarPuntatoreIstantanea`,
  `@ObservationIgnored` come `radarDettaglioIstantanea`), chiara e scura.
- Prove: `ProvaCalcoliRadar` per i testi nuovi (`pulsanteRiequilibra`, `cosaSonoIPunti` con tolleranza 5 e 3,5, nil);
  `--prova-carico` (200 clienti: l'elenco è pigro); `--prova-fluidita` (passare sulle righe non rifà il corpo del radar:
  contare i corpi con `ContaCorpi`).

### 40.6 Decisioni per l'utente e rischi

- **«Apri il dossier» o «Apri le posizioni di …»?** Il template ha solo il secondo. Proposta: il secondo al posto del
  primo; il dossier resta col doppio clic sul punto.
- **Il numero dopo «Prepara»**: il template lo porta a 0 spostando i punti; l'app tiene i punti fermi (decisione 2).
  Proposta: il numero dice quanti resterebbero fuori accettando tutte le proposte (0), i punti restano col trattino.
- **I pesi dei modelli** spariscono dalla card: proposta, nell'aiuto della riga (e in Impostazioni › Portafogli modello).
- Rischi: alzare `PuntatoreRadar` a `CorpoRadar` non deve far leggere il puntatore a nessun'altra vista (solo il
  fumetto), o ogni passaggio rifà la colonna. La card che occupa l'altezza va provata nella finestra stretta.

### 40.7 Dimensione

**M.** File: Shell/RadarPortafoglio.swift, Motori/MotoreRadar.swift (TestiRadar), DesignSystem/Apple/Tema.Apple+Radar.swift,
DesignSystem/Apple/CapsulaStatoApple.swift (nuovo, se serve), Shell/IstantaneeRadar.swift.

---

## 41. La prova del fuoco in tre gruppi

### 41.1 Nel template

Righe 4304-4334 (`FGR`, `fCli`, estensione di `fuocoHTML`, nuova `ricalcola`, `fuocoMsg`, `fuocoScheda`, estensione di
`montaFuoco`); CSS righe 681-682. Si apre con `vistaP='fuoco'` e «Tutti i clienti» (`MIG7[1]`, cartellino su
`#fLista .fGr`).

- **In testa resta lo scenario** (chip, cursore, i due numeri). Cambia solo il testo sotto il primo numero: «da chiamare:
  il loro obiettivo perde più di 10 punti» (prima «clienti scendono di più di 10 punti sui loro obiettivi»).
- **Il titolo della lista** (riga 4306): «Chi sentire, in ordine» (prima «Chi chiamare, in ordine»), poi **la legenda
  disegnata** al posto della frase: una barretta 22×8 chiara «obiettivo coperto oggi», una piena «dopo lo scenario», e
  a destra, sopra la colonna delle cifre, «patrimonio in meno».
- **L'elenco è diviso in tre gruppi con il nome** (righe 4316-4319), nell'ordine: ogni gruppo ha una testata con la
  capsula e il conto e una frase:
  - «Da chiamare · {n}» (`st2 ko`) — «il loro obiettivo perde più di 10 punti», e a destra il pulsante **«Prepara i {n}
    messaggi»** («Prepara il messaggio» se è uno solo);
  - «Da tenere d’occhio · {n}» (`st2 avv`) — «perde tra 5 e 10 punti»;
  - «Reggono · {n}» (`st2 ok`) — «perde meno di 5 punti».
  Dentro ogni gruppo le righe sono in ordine di calo; riordinando (chip, rilascio del cursore) le testate si rifanno e le
  righe scivolano al nuovo posto (650 ms, come la base; «Riduci movimento»: subito).
- **La riga** (riga 4307-4309): avatar 34, nome (bold 14) e obiettivo sotto (largo 200), la barra (chiara = oggi, piena
  = dopo, colore del gruppo: rosso, arancio, blu), la cifra **«oggi → dopo»** («52% → 38%», rossa per chi è da chiamare,
  cifre tabellari, larga 118), il patrimonio in meno «−12.400 €» in rosso (largo 104), «›». **I due pulsanti «Chiama» e
  «Messaggio» non ci sono più**: tutta la riga si apre (sfondo `chip` al passaggio).
- **«Prepara i {n} messaggi»** prepara una bozza per ogni cliente da chiamare (testo del modello `fuocoMsg`: oggetto «Il
  tuo piano, se i mercati scendono», con scenario, obiettivo, copertura oggi e dopo) e dice «{n} messaggi preparati: li
  trovi in Messaggi, da rileggere e spedire» («Un messaggio preparato: …»); il pulsante diventa «✓ Preparati».
- **La riga si apre** in un dettaglio 840×440 che nasce dalla riga (`fuocoScheda`, righe 4321-4331):
  - testa: avatar 54, occhiello nel colore del gruppo «{Da chiamare | Da tenere d’occhio | Reggono} · {scenario}», nome
    (26 bold), «Obiettivo: {obiettivo}»;
  - tre riquadri: «Obiettivo coperto oggi» {52%}; «Dopo lo scenario» {38%} con sotto «−14 punti» (rosso per chi è da
    chiamare) o «tiene» se perde meno di un punto; «Patrimonio in meno» «−X €» con sotto «su {patrimonio}» (rosso);
  - riquadro **«Perché»**: «Ha il {38}% in azioni e il {34}% in obbligazioni.» e poi, se all'obiettivo mancano meno di 5
    anni, «All’obiettivo mancano solo {3} anni: c’è poco tempo per recuperare una discesa.», altrimenti «All’obiettivo
    mancano {10} anni: c’è tempo per recuperare, ma va detto prima che lo scopra da solo.»;
  - pulsanti: **«Prepara il messaggio»** (blu: prepara la bozza e apre Messaggi su quel messaggio), **«Segna «da
    chiamare»»** (avviso ««Chiamare {nome e cognome}» aggiunto al Da fare di oggi», con le caporali come nel template),
    **«Apri la sua prova di resistenza»** (apre le Posizioni del cliente sulla vista «Prova di resistenza»).
- Il testo della bozza del template (`fuocoMsg`, oggetto «Il tuo piano, se i mercati scendono», «Hai mezz’ora questa
  settimana?», firma «Denis») è dimostrativo: nell'app oggetto, testo e firma vengono dall'occasione di oggi
  (`MotoreProvaFuoco.occasioneMessaggio`, oggetto «Il portafoglio alla prova di uno scenario difficile») e dal modello
  fisso di Messaggi (`.provaFuoco`, che dice sempre che lo scenario non è una previsione).

### 41.2 Nell'app oggi

- `Shell/ProvaDelFuocoApple.swift`: `ProvaDelFuocoApple` (:170) con `CardScenarioFuoco` (:505; testo sotto il numero
  `TestiProvaFuoco.sottoClienti`, :620), `titoloLista` (:353: «Chi chiamare, in ordine» + `notaLista`), `lista` (:374:
  `LazyVStack` senza gruppi), `RigaProvaFuocoApple` (:656: avatar, nome/obiettivo che apre il dossier su Obiettivi,
  canali, `BarraOggiDopo`, «dopo X% / oggi Y%», perdita, **«Chiama»** con conferma e `tel:` e **«Messaggio»**), le righe
  senza obiettivo («Nessun obiettivo nel dossier» + «Aggiungi un obiettivo»), la nota delle stime, `TestiProvaFuoco`
  (:828). Il riordino con `Tema.Apple.Moto.Riordino` e l'ordine in `@State ordine` ci sono già.
- `Motori/MotoreProvaFuoco.swift`: `RigaProvaFuoco` (:59: cliente, telefono, obiettivo, coperture, perdita, voci,
  `calo`, `oltreSoglia`), `livello(calo:)` (:150: `.allarme` sopra 10, `.attenzione` sopra 5, `.tranquillo`) — **i tre
  gruppi esistono già come livelli**; `Motori/MessaggioProvaFuoco.swift` (`occasioneMessaggio`).
- Messaggi: `stato.preparaMessaggio(clienteId:occasione:)` (CollegamentiMessaggi.swift:37) per uno; per più bozze in
  blocco senza aprire nulla lo stampo c'è già: `avviaCampagna` (CampagneMessaggi.swift:43: `ModelliMessaggi.testo`,
  ModelliMessaggi.swift:78, bozze `.bozza` del modello fisso, una sola assegnazione a `dati.messaggi`). `salvaMessaggio`
  (StatoMessaggi.swift:48) salva un messaggio alla volta.
- Attività: `salvaAttivita(Attivita(...))`; un'attività idempotente con l'id che dice cosa, cliente e giorno c'è già in
  `creaAttivitaImpatto` (StatoConfrontoDossier.swift:209-229).
- Il dettaglio che nasce da un elemento: `StatoDettaglio` + `.presentatoreDettaglio` (come `RadarPortafoglioApple`).
- Mancano: gruppi con testata, legenda, «oggi → dopo», dettaglio della riga, «Perché» (il motore non espone quote e anni
  all'obiettivo), «Prepara i N messaggi», «Segna «da chiamare»», «Apri la sua prova di resistenza».

### 41.3 Cosa fare

1. **Motore** (`MotoreProvaFuoco.swift`, codice comune ma solo dati in più): `RigaProvaFuoco` riceve
   `quotaAzioni: Double?`, `quotaObbligazioni: Double?` (sul patrimonio finanziario del cliente, dalle composizioni che
   il motore usa già: `ClienteBase.finanziarie`, pesate sul valore: azioni = `composizione.azioni`, obbligazioni =
   `governativi + societarie`; nil se nessuna posizione ha la composizione), `quoteStimate: Bool` (se una delle
   composizioni è stimata: il «Perché» lo dice con «circa»), `anniAllObiettivo: Int?` (dalla scadenza dell'obiettivo
   mostrato e da `oggi`; nil senza obiettivo), `patrimonio: Double` (la somma dei valori di **tutte** le
   `finanziarie` del cliente, non delle sole `voci`, che contengono solo le posizioni che cambiano valore). Niente
   cambia nei calcoli delle coperture né nell'ordine (`ordina`: con obiettivo per calo, poi i senza obiettivo, quindi i
   gruppi escono già contigui).
2. **Gruppi**: `enum GruppoProvaFuoco { case daChiamare, daTenereDOcchio, reggono, senzaObiettivo }` (in
   `MotoreProvaFuoco`, da `livello(calo:)`; le righe senza obiettivo nel quarto gruppo, vedi 41.6). Nella `lista`, le
   righe mostrate (`righeMostrate`) si dividono per gruppo mantenendo l'ordine; per ogni gruppo non vuoto una
   `TestataGruppoFuoco` (capsula `CapsulaStatoApple` «{nome} · {n}» con tono `.errore/.attenzione/.ok/.neutro`, frase in
   `Titolo.nota`, e per «Da chiamare» il pulsante a destra). Le testate entrano nel `LazyVStack` con id stabili
   («gruppo-0»…), così il riordino animato di oggi le sposta insieme alle righe.
3. **Titolo e legenda**: `TestiProvaFuoco.titoloLista` = «Chi sentire, in ordine»; al posto di `notaLista` due
   `BarrettaLegendaFuoco` (22×8, raggio 5: chiara `Barra.oggi`, piena `Barra.colore(.tranquillo)`) con «obiettivo
   coperto oggi» e «dopo lo scenario», e a destra, allineato alla colonna della perdita, «patrimonio in meno». Il criterio
   d'ordine resta nell'aiuto (`MotoreProvaFuoco.criterioOrdine`).
4. **Riga**: `RigaProvaFuocoApple` perde `chiama` e `scrivi`; la cifra diventa una sola `TestiProvaFuoco.oggiDopo(oggi,
   dopo)` = «52% → 38%» (rossa con `oltreSoglia`, `monospacedDigit`), il segno «≈» delle stime resta davanti; «›» in
   fondo; tutta la riga (non più solo nome e avatar) apre il dettaglio; sfondo al passaggio con `Riga.fondoSopra`. Il
   canale delle posizioni in essere **resta** sulla riga (regola dei canali; il template non lo disegna ma l'app sì).
   Nella misura `.minima` la cifra si accorcia come oggi. Restano anche la nota «nessuna posizione collegata» sotto la
   cifra e la perdita che diventa guadagno («+X €» in verde, `TestiProvaFuoco.perdita`). Oggi nome e avatar aprono il
   dossier su Obiettivi (`apriDossier(…, scheda: .obiettivi, …)`): quel collegamento non si perde, passa nel dettaglio
   (la riga «Obiettivo: {titolo}» è un link al dossier su quell'obiettivo; aiuto `TestiProvaFuoco.aiutoRiga`). Le righe
   restano `.equatable()`: lo sfondo al passaggio è uno `@State` della riga, non del contenitore.
5. **Dettaglio**: nuova `DettaglioProvaFuoco` (stesso file o `Shell/DettaglioProvaFuoco.swift`), presentata con
   `StatoDettaglio`/`.presentatoreDettaglio` e misura token `Fuoco.Dettaglio.misura` 840×440. Contenuto come 41.1, con i
   numeri della riga e `esito.scenario.titolo`; «Perché» da `TestiProvaFuoco.perche(riga)` (soglia 5 anni in
   `MotoreProvaFuoco.anniPocoTempo = 5`; se le quote mancano, solo la frase degli anni; se manca anche quella, il
   riquadro non c'è). Senza obiettivo il dettaglio mostra «Nessun obiettivo nel dossier» e «Aggiungi un obiettivo».
   Pulsanti:
   - «Prepara il messaggio» → `stato.preparaMessaggio(clienteId:occasione:)` di oggi (apre Messaggi sull'occasione);
   - «Segna «da chiamare»» → `StatoShell.segnaDaChiamare(riga:scenario:)`: un'`Attivita` con id stabile
     `task-fuoco-<cliente>-<giorno>` (idempotente), titolo «Chiamare {nome}», scadenza oggi, priorità alta, note con
     scenario e coperture (come `creaAttivitaImpatto`, StatoConfrontoDossier.swift:209, che fa già così con
     `task-kid-…`); avviso ««Chiamare {nome}» aggiunto al Da fare di oggi» (con la miglioria 3; prima «… alle attività
     di oggi»); una seconda pressione lo stesso giorno non crea un doppione e dice «È già nel Da fare di oggi»;
   - «Apri la sua prova di resistenza» → Posizioni del cliente, vista `.resistenza` (miglioria 14) o
     `ancoraPosizioni = "resistenza"`.
6. **«Prepara i {n} messaggi»**: `StatoShell.preparaMessaggiProvaFuoco(_ righe:scenario:)`, sullo stampo di
   `avviaCampagna` (Shell/CampagneMessaggi.swift:43), che crea già bozze in blocco con il modello fisso — per ogni
   cliente da chiamare l'occasione di oggi (`occasioneMessaggio`, canale di lavoro quello delle sue posizioni in essere
   se è uno solo, come `scrivi` di oggi), il testo di `ModelliMessaggi.testo` (tono cordiale, canale mail, firma da
   `firmaMessaggio(canale, tono:)`) e un `MessaggioCliente` in stato **`.bozza`** (non `.salvato`, che vuol dire
   «Salvato nel dossier»), autore `.modelloFisso`; **una sola assegnazione** a `dati.messaggi` per tutte le bozze (non
   `salvaMessaggio` in un ciclo, che riscrive l'archivio a ogni cliente). Idempotente: l'id dell'occasione dice già
   cliente, scenario e giorno (`provaFuoco` + `chiave(scenario)-giorno`), e chi ha già un messaggio con quell'
   `occasioneId` si salta; avviso «{n} messaggi preparati: li trovi in Messaggi, da rileggere e spedire» («Un
   messaggio preparato: …»); la testata mostra «✓ Preparati» finché scenario e valore non cambiano (stato locale della
   vista). Niente parte: le bozze restano in Messaggi. In sola lettura il pulsante è spento.
7. Testi nuovi in `TestiProvaFuoco`: `sottoClienti` = «da chiamare: il loro obiettivo perde più di 10 punti» (n = 1:
   «da chiamare: il suo obiettivo perde più di 10 punti»), i nomi e le frasi dei gruppi (con le soglie dal motore, non
   scritte a mano), `prepara(n)`, `preparati`, `oggiDopo`, `perche`, `segnaDaChiamare`, `apriResistenza`, le etichette dei
   tre riquadri, `tiene`, `puntiInMeno(n)`, `suPatrimonio`.
8. Token in `Tema.Apple+ProvaFuoco.swift`: `Titolo.barretta` (22×8, raggio 5), `Gruppo` (spazio 10, padding 10/4/7,
   primo senza spazio sopra), `Riga.fondoSopra`, `Riga.larghezzaOggiDopo` 118, `Riga.larghezzaPerdita` 104,
   `Riga.avatar` 34, `Dettaglio` (misura, avatar 54, nome 26, spazio riquadri 12, sopra riquadri 20).

**Non fare**: non portare le cifre e i clienti di `FUOCO`; non telefonare dalla riga (vedi 41.6); non spedire i messaggi.

### 41.4 Dati, archivio, privacy

Nessun campo nuovo. Le bozze sono `MessaggioCliente` come oggi (nel file del cliente e in «Prisma ovunque» come ogni
messaggio), le attività sono `Attivita` come oggi. Il telefono non esce da Prisma. La prova del fuoco resta chiusa in
modalità cliente.

### 41.5 Istantanee e prove

- Da aggiornare: tutte le «590»-«598» (gruppi, legenda, «oggi → dopo», niente pulsanti sulle righe; «596-…-senza-obiettivi»
  con il quarto gruppo; «598-…-stretta»).
- Nuove (599 è libero oggi): «599-posizioni-fuoco-dettaglio» (dettaglio aperto sul primo da chiamare: `provaFuoco.dettaglioIstantanea`,
  `@ObservationIgnored`), chiara e scura; una scena con «✓ Preparati» non serve (stato locale, si vede nella prova).
- Prove: `ProvaCalcoliProvaFuoco` — gruppi da `livello` (10 e 5 punti esatti: 10 è «da tenere d'occhio», 10,1 «da
  chiamare»), quote e anni nella riga, `perche` con 3 e 10 anni; idempotenza di `preparaMessaggiProvaFuoco` e
  `segnaDaChiamare` (in `ProvaCalcoliMessaggi` o una prova nuova su `StatoShell` in memoria); `--prova-carico` (200
  clienti: testate pigre, riordino); `--prova-fluidita`.

### 41.6 Decisioni per l'utente e rischi

- **«Chiama» sparisce**: oggi apre il numero con conferma. Proposta: come il template, al suo posto «Segna «da
  chiamare»» (il numero resta nel dossier); in alternativa un piccolo «Chiama» nel dettaglio, accanto agli altri tre.
- **Clienti senza obiettivo**: il template non li ha. Proposta: un quarto gruppo in fondo «Senza obiettivo · {n}»
  (capsula grigia, «aggiungi un obiettivo per vedere quanto regge») con il pulsante di oggi «Aggiungi un obiettivo».
- **Il messaggio scritto da Vera o dal modello fisso?** Proposta: il modello fisso (subito, per tutti); «Prepara il
  messaggio» del dettaglio apre Messaggi, dove si può chiedere a Vera come oggi.
- Rischi: le testate dentro il `LazyVStack` animato non devono rompere l'identità delle righe (id distinti); il
  dettaglio deve chiudersi al cambio di scenario o di dati (la riga può cambiare gruppo).

### 41.7 Dimensione

**M** (circa 400 righe). File: Shell/ProvaDelFuocoApple.swift, Motori/MotoreProvaFuoco.swift, Motori/MessaggioProvaFuoco.swift,
DesignSystem/Apple/Tema.Apple+ProvaFuoco.swift, Shell/IstantaneeProvaFuoco.swift, Motori/ProvaCalcoliProvaFuoco.swift.

---

## 42. Lo smontaggio ha i numeri

### 42.1 Nel template

Righe 4336-4383 (`SMD`, `smDocs`, nuova `smontaHTML`, nuova `montaSmonta`, estensioni di `posRailHTML`, `posPaginaHTML`,
`montaPosPagina` e di `APPS.posizioni`); CSS righe 684-689. Si apre con `vistaP='smonta'` (`MIG7[2]`, cartellino su
`#smVoci`).

- **Il foglio resta a sinistra** (carta bianca nel vassoio grigio, scala 0,8), ma **le note rosse ai margini non ci sono
  più**: erano piccole e in parte tagliate. Ogni voce di costo ha la sua ellisse a mano (come oggi) e **accanto
  all'ellisse un cerchio rosso pieno (raggio 11) con il numero** in bianco (12 bold).
- **A destra, larga 520, tre card**:
  1. **Il documento** (padding 16×20): avatar 38, «Documento di {nome} · valore {90.000 €}» (`k`), il titolo (15,5 bold,
     su una riga) e, con più documenti e «Tutti i clienti», il pulsante **«Cambia ⌄»** che apre il menu «{titolo} ·
     {nome}» dei documenti. Sotto, su una riga: «Costi l’anno, oggi» {2.410 €} rosso (28) → «Con la tua proposta»
     {760 €} verde, e a destra «In dieci anni» «+{22.100 €}» verde. I numeri si contano.
  2. **«Le voci cerchiate, in ordine sul documento»** (`#smVoci`, prende lo spazio che resta e scorre): per ogni voce il
     numero nel cerchio rosso 22 (`smNum`), il nome in grassetto, a destra la cifra in euro in rosso («1.890 € nel
     2025»), sotto in grigio la condizione e la spiegazione («2,10% l’anno · La voce più pesante: da sola fa il 78% dei
     costi.»). Le righe partono attenuate (0,4) e si accendono una alla volta **insieme alla loro ellisse** (la riga
     passa a 1 in 0,5 s nel momento in cui la sua ellisse comincia a disegnarsi: 500 ms + 520 ms per voce nel template,
     nell'app il passo di `S.Moto.partenza(i)`); **passando su una riga si accende la sua ellisse** (tratto 3,6 e fondo
     rosso tenue) **e viceversa** (riga con fondo rosso 0,09, raggio 10).
  3. **In dieci anni**: il grafico piccolo (186×60, rosso «oggi», verde «con te», area verde tra le due) e la frase «In
     dieci anni, a parità di mercato, solo per i costi più bassi. Stima con rendimento lordo del 5% l’anno: non è una
     promessa.»; pulsanti «Crea la proposta di sostituzione» (blu) e **«Smonta un altro documento»**.
- **Il documento si sceglie** e **la vista segue il cliente**: con un cliente scelto si vedono solo i suoi documenti
  smontati; senza documenti per lui, al centro: avatar 58, «Nessun documento smontato per {nome}.» (23 bold), «Inquadra
  un estratto conto o un rendiconto: Prisma cerchia i costi e li mette in fila, in euro.» e i pulsanti «Inquadra un
  documento» (blu) e «Vedi quelli degli altri clienti» (torna a «Tutti i clienti»).
- **Con un cliente scelto lo smontaggio è nell'indice delle sue Posizioni**: la voce «Smontaggio di un documento» con il
  numero dei suoi documenti smontati, prima di «Passaggio generazionale»; con «Tutti i clienti» resta la vista
  «Smontaggio» della testata del portafoglio.

### 42.2 Nell'app oggi

- `Shell/SmontaggioApple.swift`: `StatoSmontaggio` (:27, un solo documento in memoria: righe, titolo, origine,
  cliente, posizione, scelte), `SmontaggioApple` (:79; nel `body` calcola `MotoreSmontaggio.smonta`, le proposte del
  cliente filtrando `stato.dati.posizioni` e il confronto), `vassoio` (:165, trascinamento di PDF e foto), `vuoto`
  (:206: `PulsanteInquadra`, «Scegli un documento…», «Apri l'esempio (fac-simile)»), `cardDocumento` (:252: avatar,
  «Il documento di {nome} · {origine}», titolo e valore, canale, le due cifre, «Aggiungi al dossier di …» con conferma),
  `cardDieciAnni` (:324: menu della proposta da confrontare, guadagno netto da `MotoreSostituzione` con penale, ingresso
  e tasse, didascalia con le ipotesi di Prisma, `GraficoDieciAnni`, «Crea la proposta di sostituzione», «Inquadra un
  altro documento»), `FoglioAnnotato` (:405: righe, `CerchioAMano`, fumetto al clic con «Non è un costo», menu
  contestuale «Segna come costo»), `note(...)` (:529) e `NotaRichiamo` (:594): **le note ai margini di oggi**.
- `Motori/MotoreSmontaggio.swift`: voci, cifre, `TestiSmontaggio.nota` (:315, le spiegazioni), `vuoto` (:334).
- I documenti smontati e conservati: `Documento.costiTrovati` (Dati/Documento.swift:78), scritto da
  `aggiungiSmontaggioAlDossier` (SmontaggioApple.swift:763). **Attenzione: il testo letto non è conservato.** Il
  documento nasce senza `file` e `memorizzaTesto` (StatoShell.swift:1340) scrive solo in `MemoriaTesti`, che è una
  cache in memoria a tempo (al più 4 milioni di caratteri, i meno recenti escono) e si svuota alla chiusura di Prisma;
  `testoDocumento` (StatoShell.swift:1320) cerca poi un `.txt` accanto al file, che qui non c'è. Dopo un riavvio di
  quel documento restano solo le voci di `costiTrovati` (tipo, etichetta, valore scritto, euro, conto, motivo,
  numero di riga), non le righe del foglio.
- Lo smontaggio è solo una vista del portafoglio (`VistaPosizioni.smontaggio`, VistePosizioni.swift:7; `apriSmontaggio`
  :696); nella vista cliente di Posizioni non c'è (la colonna «Analisi» di AppPosizioni.swift:244-255 ha cinque voci).
- Token: `DesignSystem/Apple/Tema.Apple+Smontaggio.swift` (note: `larghezzaNota` 190, `distanzaNota` 18, …).

### 42.3 Cosa fare

1. **Numeri al posto delle note.** In `FoglioAnnotato`: via `note(...)`, `NotaRichiamo`, `ComparsaNota` e il margine
   delle note (`larghezzaTotale` diventa il foglio scalato più lo spazio del numero). Accanto a `CerchioAMano` un
   `NumeroVoceSmontaggio` (cerchio pieno rosso raggio 11, numero 12 bold bianco) a destra dell'ellisse, che compare con
   la sua ellisse. Il numero è la posizione della voce in `costi.voci` + 1 (lo stesso nell'elenco a destra).
2. **Voce accesa in comune** tra foglio ed elenco: `StatoSmontaggio.voceSopra: Int?` (la riga del documento) oppure, per
   non ridisegnare tutta la vista a ogni passaggio, un piccolo `@Observable final class SopraSmontaggio { var riga: Int? }`
   letto solo dall'ellisse e dalla riga dell'elenco (come `PuntatoreRadar`). Ellisse accesa: tratto 3,6 (token
   `tratteggioAcceso`), fondo `rosso 0,10`; riga accesa: fondo `rosso 0,09`, raggio 10.
3. **Elenco «Le voci cerchiate, in ordine sul documento»**: nuova card `CardVociSmontaggio` (tra le due card di oggi),
   con `RigaVoceSmontaggio`: `smNum` 22, nome (`voce.etichetta`), a destra la cifra in euro (`voce.euro` con la frase di
   oggi del motore, es. «1.890 € nel 2025»; senza euro «—»), sotto `voce.valoreScritto` + « · » + `TestiSmontaggio.nota`
   se c'è. L'accensione a cascata usa lo stesso ritardo delle ellissi (`S.Moto`, `ritardoPrisma`): opacità 0,4 → 1; con
   «Riduci movimento» e nelle istantanee tutte accese. Le azioni di oggi sulla voce («Non è un costo», il fumetto)
   restano sul foglio e si aggiungono al menu contestuale della riga dell'elenco.
4. **Card del documento** (`cardDocumento`): testo «Documento di {nome} · valore {valore}» (senza valore letto né
   posizione: solo «Documento di {nome}»; senza cliente: «Documento da assegnare»; l'origine di oggi, «inquadrato con
   l'iPhone» o il nome del file, passa nell'aiuto); avatar 38 al posto di 40; titolo su una riga; «Cambia ⌄»
   (vedi punto 6); le cifre su una riga: «Costi l’anno, oggi» → «Con la tua proposta», e a destra «In {10} anni» con il
   guadagno **netto del confronto di oggi** (`esito.finale.differenza`, verde o rosso), che quindi esce dalla card in
   basso. Il canale della posizione e «Aggiungi al dossier di …» restano.
5. **Card in basso** (`cardDieciAnni`): grafico piccolo (token `graficoPiccolo` 186×60, etichette «con te» e «oggi»), a
   fianco la didascalia del motore (`TestiSmontaggio.didascalia`, con penale, ingresso, tasse e le ipotesi di Prisma: **non**
   la frase «5% l’anno» del template), il menu «Confronta con: …» di oggi, i pulsanti «Crea la proposta di sostituzione»
   e «Smonta un altro documento» (al posto di «Inquadra un altro documento», stessa azione `apriInquadraSmontaggio()`:
   la scena di Inquadra per lo Smontaggio offre già sia l'iPhone sia il trascinamento e «Scegli un file…» nelle fasi di
   attesa, quindi niente menu in più). Resta il solo Mac (`#if os(macOS)` di oggi).
6. **I documenti smontati del cliente.** `StatoShell.documentiSmontati(clienteId: String?) -> [Documento]`: i
   documenti con `costiTrovati` non vuoto (del cliente, o di tutti con «Tutti i clienti»), tenuti con
   `stato.ricavato("smontaggio-documenti-\(id ?? "tutti")")` (i documenti entrano nei dati dei calcoli: la cache si
   rifà da sola quando se ne aggiunge uno). Il menu «Cambia ⌄» elenca «{titolo} · {nome}» di questi più quello in
   memoria. **Riaprire un documento conservato** (vedi 42.2: il testo non c'è più dopo un riavvio): si ricostruisce il
   foglio dalle sue voci, una riga per voce («{etichetta} {valoreScritto}», nell'ordine di `riga`), con il titolo del
   documento in testa, e **le cifre non si ricalcolano**: le voci conservate (con gli euro già fatti da Prisma al
   momento dell'aggiunta) diventano direttamente il `SmontaggioCosti` mostrato, con il valore della posizione collegata
   (`posizioneId`) se c'è. Rifare `MotoreSmontaggio.smonta` su righe ricostruite perderebbe le cifre calcolate dalle
   percentuali quando il valore non è scritto. Funzione pura nuova `MotoreSmontaggio.righe(da voci:
   [VoceCostoTrovata], titolo:) -> [RigaLetta]` (in comune, l'iPad non la chiama), e in `StatoSmontaggio` una
   `vociConservate: [VoceCostoTrovata]?` con il `documentoId` (azzerati da `carica` e `svuota`): con le voci conservate
   la vista le usa al posto di `smonta`, «Non è un costo» e «Segna come costo» sono spenti (il documento è già nel
   dossier) e «Aggiungi al dossier» resta spento (`documentoSmontaggioPresente`). Se il testo è ancora in memoria
   (`testoDocumento` non vuoto, per esempio nella stessa sessione o con i documenti dei dati di prova) si usano le righe
   vere con `smonta`, come oggi. Il pulsante c'è quando
   l'elenco ha più di un documento, **anche con un cliente scelto** che ne ha più d'uno (il template lo mostra solo con
   «Tutti i clienti», ma nei suoi dati nessun cliente ne ha due).
7. **La vista segue il cliente** (miglioria 2): con un cliente scelto e il documento in memoria di un altro cliente,
   lo smontaggio mostra il primo documento smontato del cliente scelto, o il vuoto nuovo: `AvatarCliente` 58,
   «Nessun documento smontato per {nome}.», «Inquadra un estratto conto o un rendiconto: Prisma cerchia i costi e li
   mette in fila, in euro.», «Inquadra un documento» (blu, `apriInquadraSmontaggio`) e «Vedi quelli degli altri clienti»
   (`scegliCliente(nil)` e vista Smontaggio). Il vuoto di oggi (senza cliente) resta, con «Apri l'esempio (fac-simile)»
   solo con i dati di prova. **Un documento letto e non ancora aggiunto al dossier non si perde** cambiando cliente:
   `StatoSmontaggio` ha un solo posto, quindi il documento letto resta in memoria (righe, scelte, cliente) e la vista
   mostra quello conservato del cliente scelto senza sovrascriverlo (il conservato si mostra da `vociConservate`, non
   con `carica`); tornando a «Tutti i clienti» o al suo cliente il documento letto ricompare, ed è la prima voce di
   «Cambia ⌄».
8. **Nell'indice di Posizioni del cliente** (`IndicePosizioniApple` della miglioria 14): voce «Smontaggio di un
   documento» con il numero `documentiSmontati(clienteId).count` (se > 0), prima di «Passaggio generazionale»; nuovo caso
   `VistaPosizioniCliente.smontaggio` (caso da aggiungere all'enum del gruppo 02) che mostra `SmontaggioApple` nel
   contenuto, senza passare da `apriSmontaggio()` (che porta al Portafoglio di tutti i clienti e in modalità cliente si
   rifiuta: SmontaggioApple.swift:696). Prima della 14, la stessa voce entra nella colonna «Analisi» di oggi
   (AppPosizioni.swift:247, oggi un elenco di ancore `(titolo, ancora)`) come voce a parte che apre `apriSmontaggio()`
   e quindi, fino alla 14, porta al portafoglio (con il cliente scelto la vista segue lui, punto 7) e non c'è in
   modalità cliente.
9. **Prestazioni**: le proposte del cliente (`proposteDelCliente`) e i documenti smontati non si filtrano più su tutto
   l'archivio nel `body`: `CacheClienti` o `stato.ricavato("smontaggio-proposte-\(id)")`.
10. Testi in `TestiSmontaggio`: «Le voci cerchiate, in ordine sul documento», «Documento di {nome} · valore {euro}»,
    «Cambia», «In {n} anni», «Smonta un altro documento», «Nessun documento smontato per {nome}.», la frase del vuoto,
    «Inquadra un documento», «Vedi quelli degli altri clienti», «Smontaggio di un documento».
11. Token in `Tema.Apple+Smontaggio.swift`: `numeroFoglio` (raggio 11, carattere 12 bold), `numeroElenco` 22,
    `opacitaSpenta` 0,4, `fondoVoceAccesa`, `tratteggioAcceso` 3,6, `larghezzaColonna` 520, `avatarDocumento` 38,
    `cifraRiga` 28, `graficoPiccolo` 186×60, `avatarVuoto` 58, `titoloVuoto` 23 bold; via `larghezzaNota`,
    `distanzaNota` e i token delle note.

**Non fare**: non portare `SMD` né il secondo fac-simile di Laura; non inventare percentuali (le voci restano quelle del
motore); non togliere «Aggiungi al dossier di …», il menu della proposta e la lettura dal trascinamento.

### 42.4 Dati, archivio, privacy

Nessun campo nuovo: i documenti smontati sono quelli che l'utente ha già aggiunto ai Documenti del cliente
(`Documento.costiTrovati`, nel file del cliente e nei backup; mai la foto, decisione 47). Il documento in memoria resta
in memoria come oggi. Riaprire un documento conservato usa le voci già nell'archivio (`costiTrovati`) e, se è ancora in
memoria, il testo letto (`MemoriaTesti`, solo cache): niente si scrive di nuovo su disco, niente esce dal Mac. Conservare
anche il testo del foglio (un `.txt` nella cartella Documenti del cliente, che entrerebbe nei backup) sarebbe un
cambiamento d'archivio: non si fa senza decisione (vedi 42.6).
In modalità cliente lo smontaggio non si apre dal portafoglio; dall'indice del cliente in modalità cliente: vedi 42.6.

### 42.5 Istantanee e prove

- Da aggiornare: «880-posizioni-smontaggio» (numeri, elenco, cifre su una riga), «881-…-vuoto», «882-…-senza-proposta»,
  «883-…-mancanti» (voce tratteggiata con la sua riga «—»), «884-…-fumetto», «885-posizioni-testata-quattro-viste»,
  «886-…-stretta».
- Nuove: «887-posizioni-smontaggio-voce-accesa» (una voce accesa: `smontaggio.sopraIstantanea`), «888-posizioni-smontaggio-
  vuoto-cliente» (cliente scelto senza documenti), «889-posizioni-indice-smontaggio» (indice del cliente con la voce e il
  numero), chiare e scure le prime due.
- Prove: `ProvaCalcoliSmontaggio` (numerazione = ordine delle voci, `documentiSmontati` per cliente e per tutti,
  `righe(da:titolo:)` e riapertura di un documento conservato **senza testo in memoria** con le stesse cifre di quando
  è stato aggiunto, compresa una voce calcolata dalla percentuale); `ProvaBackupSmontaggio` resta valida (nessun cambio
  d'archivio).
- I numeri 887, 888, 889 sono liberi oggi (verificato nel codice e nelle altre specifiche; il gruppo 05 usa la serie
  1100-1126, quindi nessun conflitto con «880-posizioni-smontaggio»).

### 42.6 Decisioni per l'utente e rischi

- **Quali documenti si possono «scegliere»?** Proposta: quelli aggiunti ai Documenti del cliente dallo Smontaggio (con le
  voci di costo) più quello aperto adesso; niente archivio nuovo dei documenti smontati.
- **Il foglio di un documento riaperto**: oggi il testo letto non si conserva (42.2), quindi dopo un riavvio il foglio
  si ricostruisce con le sole voci di costo (una riga per voce), non con tutte le righe del documento. Proposta: così,
  senza cambiare l'archivio. In alternativa, «Aggiungi al dossier» salva anche il testo letto in un `.txt` accanto ai
  Documenti del cliente (nei backup, mai in «Prisma ovunque»): è un cambiamento d'archivio e va aggiornata
  `ProvaBackupSmontaggio`.
- **«In dieci anni»**: il template usa una stima semplice al 5%; l'app ha il confronto netto (penale, ingresso, tasse).
  Proposta: la cifra dell'app, con la didascalia dell'app.
- **Lo smontaggio nell'indice del cliente in modalità cliente**: proposta, sì (è il documento del cliente, niente di altri
  clienti): «Vedi quelli degli altri clienti» non compare in modalità cliente.
- Rischi: togliere le note cambia la larghezza del foglio e quindi la scala: rivedere la finestra stretta. Il foglio
  ricostruito dalle voci di un documento conservato è più corto di quello letto la prima volta: va provato con
  l'esempio, dopo un riavvio (una scena con `costiTrovati` e senza testo in memoria). La vista oggi calcola nel `body`: con il
  punto 9 il costo resta piccolo. Cambiare cliente non deve buttare un documento letto e non aggiunto (punto 7).

### 42.7 Dimensione

**L** (oltre 500 righe tra vista, stato, indice e prove). File: Shell/SmontaggioApple.swift, Motori/MotoreSmontaggio.swift,
DesignSystem/Apple/Tema.Apple+Smontaggio.swift, Shell/IndicePosizioniApple.swift (miglioria 14) o Shell/AppPosizioni.swift,
Shell/IstantaneeSmontaggio.swift, Motori/ProvaCalcoliSmontaggio.swift.

---

## 43. Prima di aggiungere, si controlla (Inquadra e Nuovo cliente)

### 43.1 Nel template

Righe 4385-4403 (`quandoPronto`, `rendiCorreggibili`, `SENZA`, estensioni di `apriScanner` e `apriNuovo`); CSS righe
691-696. Si apre con `apriScanner()` da Posizioni (`MIG7[3]`, cartellino su `#scMac` dopo 4,3 s).

**Inquadra e capisci** (la scena con il telefono e la scheda «Prisma sul Mac»):
- In fondo alla scheda, sopra un filo: «Senza iPhone? **Scegli un file dal Mac**» (link; avviso «Si sceglie un PDF o
  una foto dal Mac, come con «Importa»»).
- A lettura finita:
  - **ogni valore si corregge toccandolo** (aiuto «Tocca per correggere»; sfondo `chip` al passaggio, anello blu al
    fuoco; Invio conferma);
  - **il dato incerto è in arancione**: la riga (nel template la quinta, «Tipo») ha lo sfondo arancio tenue, il segno «?»
    arancio al posto della spunta verde, e a destra il pulsante «Va bene»; premuto, la riga torna normale con «✓» verde;
  - in testa alle righe **«Di chi è · letto dal documento»**: avatar 34, il nome del cliente letto, «Cambia» (menu dei
    clienti). Se si sta lavorando su un altro cliente, sotto in arancio: «Stai lavorando su {nome}: questo documento è
    intestato a Giulia.» (sparisce cambiando cliente);
  - il titolo dice «Letta: un dato da controllare» finché il dubbio c'è, poi «Letta e controllata»;
  - il pulsante principale dice «**Controlla il dato in arancione**» (non blu) finché il dubbio c'è; premuto, la riga
    incerta trema (300 ms, niente con «Riduci movimento») e l'avviso «Prima conferma o correggi il dato in arancione».
    Risolto il dubbio diventa blu: «**Aggiungi alle posizioni di {nome}**» → avviso «Aggiunta alle posizioni di {nome},
    canale: altra compagnia»;
  - **«Confronta» non cancella più i pulsanti**: la tabella «La sua vita intera / Una temporanea» si apre sopra, il
    pulsante «Confronta» si nasconde e si può ancora aggiungere.

**Nuovo cliente** (carta d'identità):
- I valori letti si correggono toccandoli; il sottotitolo dice «Letta dal documento: controlla e completa».
- Due righe in più: «＋ Telefono» con il campo vuoto «da aggiungere», e «＋ Canale» con le due capsule dei canali
  (pallino del colore e nome: Alleanza / indipendente; un clic accende o spegne; nel template Alleanza è accesa).
- In fondo, sopra un filo: «Telefono ed email si possono aggiungere anche dopo, dal dossier. Senza documento? **Scrivi tu
  i dati** · **Scegli un file dal Mac**».

### 43.2 Nell'app oggi

- **Inquadra** — `Shell/ScenaInquadra.swift`: `SchedaInquadraMac` (:229), `letto` (:332: righe con `RigaSchedaInquadra`,
  poi cliente, tabella, conferma o pulsanti), `cliente(canale:)` (:357: «Cliente» + menu «Scegli il cliente» + canale),
  `pulsanti` (:380: «Aggiungi a Posizioni di {nome}» / «Aggiorna la posizione», «Confronta» o «Chiudi»), `conferma`
  (:411: frase e «Conferma e aggiungi»), `ZonaInquadra` (:494: trascina o «Scegli un file…» nelle fasi di attesa).
  `Shell/FoglioInquadra.swift`: `RigaSchedaInquadra` (:164, **comune a Mac e iPhone**: spunta, etichetta, valore o «non
  letto»). `Shell/StatoInquadra.swift`: `StatoInquadra` (`righeScheda` :72, `clienteScelto`, `conferma`, `confronto`),
  `clienteInquadra` (:378), `aggiungiInquadrata` (:420). `Motori/SchedaInquadra.swift`: `RigaInquadra` (:12),
  `MotoreInquadra.righe` (:56: Contraente, Premio, Capitale assicurato, Decorrenza, Tipo; il resto di `MotoreInquadra`,
  `DatiInquadrati` e `leggi`, sta in `Motori/MotoreInquadra.swift`). La tabella aperta da «Confronta» lascia già
  «Aggiungi» al suo posto e mette «Chiudi» al posto di «Confronta» (il template invece nasconde «Confronta» e basta):
  questa parte della 43 c'è già.
  C'è già: la via senza iPhone (trascina o «Scegli un file…», ma solo prima della lettura), la scelta del cliente, la
  conferma in due passi, «Aggiorna la posizione» se la polizza c'è già, la tabella che lascia «Aggiungi». **Manca**: la
  correzione dei valori, il dato incerto (il motore non ne segna nessuno), «Di chi è · letto dal documento» con l'avviso
  del cliente diverso, i titoli e il pulsante che cambiano col dubbio, il link «Senza iPhone?» a lettura finita.
- **Nuovo cliente** — `Shell/ScenaNuovoCliente.swift`: `RigaSchedaNuovoCliente` (:513: **già correggibile** al clic,
  con gli stati `letta`, `scrittaDaTe` (matita), `mancante`, `daGuardare` («!» arancio con la nota)), `letto` (:360),
  `pulsante` (:494: «Crea il dossier di {nome}» / «Completa e crea il dossier»), «Scrivi a mano» (nell'intestazione e da
  illeggibile), `ZonaNuovoCliente` con «Scegli un file…». `Shell/NuovoClienteShell.swift`: `clienteDaCarta` (:215:
  «Mai canali, consensi, email, telefono o professione: la completezza li chiede»), `creaClienteDaCarta` (:236).
  **Manca**: le righe Telefono e Canale, il sottotitolo nuovo, la riga in fondo.

### 43.3 Cosa fare

**Inquadra**
1. **Correzioni**: `StatoInquadra.correzioni: [String: String]` (per id di riga; più campi per «Tipo»: tipologia e
   compagnia, come le righe a più campi di Nuovo cliente) e `confermate: Set<String>`. Si azzerano in `svuota()`.
   `MotoreInquadra.applica(_ d: DatiInquadrati, correzioni:) -> DatiInquadrati` (codice comune, solo funzione nuova):
   rilegge premio e frequenza, capitale, decorrenza con i lettori che il motore usa già sul testo; un valore che non si
   legge resta come scritto e la riga torna «da controllare». La correzione va scritta **sia nei `campi`
   (`CampoInquadrato.valore`) sia negli `estratti`** (`CampoEstratto`): il documento che nasce con «Conferma e
   aggiungi» prende i suoi campi dagli `estratti` (`MotoreInquadra.documento`, MotoreInquadra.swift:216) e la posizione
   nasce da quel documento (`creaDaDocumento`); correggere solo la scheda non basterebbe. Vale anche per il documento già
   creato dal testo arrivato dall'iPhone (`documentoDaInquadratura`). `aggiungiInquadrata`, `confrontaInquadrata`,
   `canaleEAreaInquadra`, `posizioneGiaInquadrata` e `clienteInquadra` (se si corregge il contraente) usano i dati
   corretti (`datiCorretti`).
2. **Il dato incerto viene da regole**, non dal template: `MotoreInquadra.daControllare(_ d:, canale:) -> Set<String>`:
   «tipo» se la compagnia non è letta e il canale è indipendente («altra compagnia») o se manca la tipologia;
   «premio» se la frequenza non è scritta o il premio annuo supera il capitale; «capitale» se è minore del premio
   annuo; «decorrenza» se è nel futuro o prima del 1950. Una riga corretta a mano o confermata con «Va bene» esce dai
   dubbi. Le righe «non letto» restano grigie come oggi (non sono dubbi).
3. **Riga correggibile, solo Mac**: nuova `RigaSchedaInquadraMac` in ScenaInquadra.swift (la `RigaSchedaInquadra` comune
   resta per l'iPhone): stessa grafica, più il clic che apre il campo sul posto (`TextField` con Invio che conferma ed
   Esc che annulla, come `RigaSchedaNuovoCliente`), l'aiuto «Tocca per correggere», la matita «scritto da te» dopo una
   correzione, e per le righe in dubbio sfondo arancio tenue (token `Inquadra.Scheda.fondoDubbio`, raggio 10), «?»
   arancio (`coloreDubbio` = arancio del testo, miglioria 7) e il pulsante piccolo «Va bene». Esc chiude prima la modifica,
   poi la scena (come Nuovo cliente).
4. **«Di chi è · letto dal documento»**: `cliente(canale:)` sale in testa alle righe e diventa: `AvatarCliente` 34,
   «Di chi è · letto dal documento» (o «Di chi è · scelto da te» dopo un cambio), il nome, «Cambia» (il menu dei clienti di
   oggi). Il canale proposto resta visibile (`EtichettaCanaleApple`). Se il cliente attivo (non in «Tutti i clienti») è
   diverso da quello letto: riga arancio «Stai lavorando su {nome}: questo documento è intestato a {nome letto}.», che
   sparisce scegliendo con «Cambia». Attenzione a come `clienteInquadra` (StatoInquadra.swift:378) sceglie oggi: prima
   quello scelto, poi quello il cui nome è il contraente (`clienteProbabile`), **poi il cliente attivo** se la scena non
   si è aperta dal Portafoglio. Le etichette seguono questi tre casi: «letto dal documento» solo con `clienteProbabile`,
   «scelto da te» dopo «Cambia», «il cliente su cui lavori · il documento non dice di chi è» nel ripiego sul cliente
   attivo (e allora niente avviso arancio). Senza nessuno dei tre: «Di chi è · da scegliere» e il pulsante resta spento.
5. **Titolo e pulsante**: `titolo` (oggi «Polizza riconosciuta») → con dubbi «Letta: un dato da controllare» («Letta:
   {n} dati da controllare»), senza «Letta e controllata»; il pulsante principale → con dubbi «Controlla il dato in
   arancione» in stile normale (`.appleGrande`): premuto, scuote le righe in dubbio (`Tema.Apple.Moto` scossa 300 ms,
   niente con `prismaCalmo`) e avvisa «Prima conferma o correggi il dato in arancione»; senza dubbi «Aggiungi alle
   posizioni di {nome}» blu. Poi resta **la conferma di oggi** (vedi 43.6). Con «Aggiorna la posizione» i dubbi valgono
   allo stesso modo.
6. **«Senza iPhone? Scegli un file dal Mac»** anche a lettura finita, in fondo alla scheda sopra un filo
   (`stato.scegliFileInquadra()`, che ricomincia la lettura con il file scelto). Con il ponte spento la frase diventa la
   via principale come oggi.

**Nuovo cliente**
7. Sottotitolo a lettura finita (`sottotitolo` :316): «Letta dal documento: controlla e completa» (al posto di
   `MotoreCartaIdentita.sottotitolo` quando non mancano dati; se mancano, la frase di oggi).
8. Due righe nuove dopo quelle lette, nello stile delle righe (segno «＋» grigio): **«Telefono»** (campo sul posto con il
   segnaposto «da aggiungere»; `StatoNuovoCliente.telefono: String`) e **«Canale»** (due capsule con pallino del colore
   del canale e `canale.nomeBreve`, accese e spente con un clic; `StatoNuovoCliente.canali: Set<Canale>`, che nel
   `Cliente` diventa l'array `canali` nell'ordine dei canali). Il nome dei canali è quello delle impostazioni
   (miglioria 38, «I canali hanno il nome che scegli»). Da «Diventa cliente» (un potenziale) il telefono parte già
   scritto con quello del potenziale, che oggi `MotorePassaparola.cliente(_:dalPotenziale:)` copia comunque se il
   cliente non ne ha uno: la riga lo mostra invece di «da aggiungere». Telefono e canali si azzerano con la carta
   (chiusura, blocco, riposo).
9. `clienteDaCarta` riceve telefono e canali (cambia il commento «Mai canali … telefono»: ora solo se scritti
   dall'utente nella scheda); la completezza continua a chiedere ciò che manca.
10. In fondo, sopra un filo: «Telefono ed email si possono aggiungere anche dopo, dal dossier. Senza documento? **Scrivi
    tu i dati** · **Scegli un file dal Mac**» (link a `scriviAManoDaCarta()` e `scegliFileNuovoCliente()`).
11. Testi in `TestiInquadra` / `TestiNuovoCliente` (o le costanti dei due file), token in `Tema.Apple+Inquadra.swift`
    (`Scheda.fondoDubbio`, `coloreDubbio`, `raggioDubbio` 10, `pulsanteVaBene` padding 4×11 carattere 12,5,
    `avatarDiChi` 34, `filoSenzaIPhone`, `campoCorrezione`) e `Tema.Apple+NuovoCliente.swift` (`segnoPiu`, `capsulaCanale`).

**Non fare**: non toccare la riga comune dell'iPhone; non segnare in arancione la quinta riga per regola fissa; non far
nascere la posizione senza il passo di conferma; non scrivere «canale: altra compagnia» se il canale è Alleanza (l'avviso
di oggi distingue già).

### 43.4 Dati, archivio, privacy

Nessun campo nuovo nell'archivio. Le correzioni restano in memoria finché la scena è aperta (si scartano alla chiusura,
al blocco e al riposo come la carta d'identità: regola «Dall'iPhone al Mac»). Il telefono e i canali del nuovo cliente
vanno nei campi di oggi del `Cliente` (`telefono`, `canali`), e quindi anche in «Prisma ovunque» come ogni anagrafica.
Nessun dato nuovo esce dal Mac; la carta continua a vivere solo in memoria.

### 43.5 Istantanee e prove

- Da aggiornare: «604-posizioni-inquadra-fatto» (riga in dubbio, «Di chi è», titolo «Letta: un dato da controllare»,
  pulsante «Controlla il dato in arancione»), «605-…-confronta», «606-…-pochi-dati», «608-…-conferma»; «841-clienti-
  nuovo-letto» (righe Telefono e Canale, riga in fondo, sottotitolo), «842»-«849» dove si vede la scheda letta.
- Nuove: le famiglie 600-609 e 840-849 sono piene, quindi la serie delle migliorie d'uso come negli altri gruppi
  (1160-1169, libera oggi): «1160-uso-inquadra-controllata» (dubbio risolto, pulsante blu), «1161-uso-inquadra-altro-
  cliente» (avviso arancio «Stai lavorando su …»), «1162-uso-inquadra-correzione» (campo aperto), chiare e scure la
  prima; «1163-uso-clienti-nuovo-telefono-canale» (riga Telefono scritta e un canale acceso).
- Prove: `ProvaCalcoliSchedaInquadra` e `ProvaCalcoliInquadra` (regole di `daControllare`, `applica` con premio «120 € al
  mese», capitale illeggibile, decorrenza futura); `ProvaCalcoliCartaIdentita` (telefono e canali nel cliente creato,
  niente telefono se vuoto); `--prova-vera` non cambia (il ponte manda solo testo come oggi).

### 43.6 Decisioni per l'utente e rischi

- **Il passo di conferma resta?** Il template aggiunge subito; l'app chiede «Conferma e aggiungi» con la frase (regola di
  «Inquadra», niente entra nel dossier senza un sì). Proposta: resta, dopo il controllo dei dubbi.
- **Canale di base nel nuovo cliente**: il template accende Alleanza. Proposta: nessuno acceso (un canale sbagliato è
  peggio di uno da scegliere); in alternativa quello del template.
- **Telefono e canale nel nuovo cliente**: «Luce» li aveva lasciati alla completezza; il template li porta nella scheda.
  Proposta: sì, come il template (scritti dall'utente sul Mac, nessun cambio di privacy).
- **Quali dati sono «incerti»**: proposta, le quattro regole di 43.3 punto 2; l'utente può chiederne altre.
- Rischi: `MotoreInquadra` e `SchedaInquadra` sono comuni con l'iPhone: solo funzioni nuove, nessun cambio a quelle
  usate dall'iPhone. Esc ha già due significati nella scena: provarli con le istantanee non basta, serve uno screenshot.

### 43.7 Dimensione

**M** (circa 400 righe). File: Shell/ScenaInquadra.swift, Shell/StatoInquadra.swift, Motori/SchedaInquadra.swift,
Motori/MotoreInquadra.swift, Shell/ScenaNuovoCliente.swift, Shell/StatoNuovoCliente.swift, Shell/NuovoClienteShell.swift,
DesignSystem/Apple/Tema.Apple+Inquadra.swift, DesignSystem/Apple/Tema.Apple+NuovoCliente.swift.

---

## 44. Aggiorna valori: prima i dubbi

### 44.1 Nel template

Righe 4405-4433 (`AGG`, `aggDec`, `aggFatto`, `aggRighe`, `aggHTML`, `apriAggiorna`, estensione di
`agganciaBarraPos`); CSS righe 698-701. Prima il pulsante «Aggiorna valori» della barra diceva solo «Valori aggiornati
adesso» (riga 3182); ora apre **la sua scheda** (`apriScheda`). Si apre con `MIG7[4]` (cartellino su `#aggDub`).

- **Testa**: occhiello blu «Aggiorna i valori» (« · {nome}» con un cliente scelto), titolo «Dall’elenco della
  compagnia.»; sotto ««Valori di novembre.xlsx»: {n} righe lette» (« per {nome}» con un cliente), e il link «Scegli un
  altro file».
- **In alto le righe che chiedono una decisione** (`#aggDub`), con la capsula «Da decidere · {n}» (`st2 avv`) e «Prima
  queste: poi si registra tutto insieme.» (a decisioni prese «Deciso» `st2 ok` e «Puoi registrare.»). Ogni dubbio è un
  riquadro arancio tenue (raggio 16, bordo arancio 0,25) con avatar 34, titolo e **la domanda scritta in chiaro**:
  - valore molto più basso: «{Fondo bilanciato globale} · {Laura Moretti}» — «Il valore nuovo è più basso del {18}%: da
    {96.000 €} a {78.700 €}. È giusto, o nell’elenco c’è un errore?» — pulsanti «È giusto» e «Salta»;
  - polizza che non c'è: «{Polizza n. AL-2024-77120 · Temporanea caso morte}» — «Nell’elenco è intestata a {Marco
    Bianchi}, ma tra le sue posizioni non c’è. È una polizza nuova?» — «È nuova» e «Salta».
  Decisa, la riga diventa una riga sola con la spunta verde: «**{titolo}** · {nome}: il valore è giusto, si registra» /
  «è una posizione nuova, si aggiunge» / «saltata, resta com’è», e a destra «Cambia».
- **Sotto, quelle pronte**: capsula «Pronti · {n}» (`st2 ok`), «riconosciuti dal numero di polizza o dal nome», a destra
  la variazione totale (verde o rossa). Tabella a quattro colonne (1fr · 130 · 200 · 86): nome con il canale, cliente,
  «{prima} → **{dopo}**», variazione colorata. Sotto, per i valori più vecchi: «ⓘ **{Polizza multiramo} · {Marco
  Bianchi}**: valore del 19 aprile 2026: più vecchio di quello che hai già. Va solo nello storico.»
- **Il pulsante dice quanti valori registra**: con dubbi aperti «Decidi la riga in arancione» / «Decidi le {n} righe in
  arancione» (non blu; premuto, il primo dubbio trema e l'avviso «Prima decidi le righe in arancione»); senza dubbi, blu,
  «Registra {n} valori» («Registra 1 valore»). Accanto: «Prima di registrare Prisma salva una copia: si può annullare.»
- **Dopo**: titolo «{n} valori registrati.», «Il valore di prima resta nello storico di ogni posizione e
  nell’andamento.» (+ «Un valore più vecchio è andato solo nello storico.» + «Una posizione nuova è stata aggiunta.»),
  tre riquadri «Prima» ({totale}, «{n} posizioni»), «Dopo», «Variazione» («+X €», «+1,2%», verde o rosso); pulsanti
  «Fatto» (blu) e **«Annulla la registrazione»**, a destra «Prima di registrare Prisma ha salvato una copia.». Avvisi:
  «Valori registrati: quelli di prima restano nello storico», «Registrazione annullata: i valori sono quelli di prima».
- Con un cliente scelto la scheda mostra solo le sue righe.

### 44.2 Nell'app oggi

- `Shell/AggiornaValoriVista.swift`: `PannelloAggiornaValori` (:11), **ancora nello stile vecchio** (`Tema.Colore`,
  `Tema.Testo`, `StileBlu`, `StileVetro`, `.vetro`): testata con «Aggiorna i valori» e i segmenti «Da un elenco della
  compagnia | Valori fermi» (:213), piede con la nota del backup, «Importa come nuove» e «Registra N» (:230),
  `elencoConFile` (:293: intestazione del file, data comune, filtro «Tutte | Da controllare (n)», quattro KPI,
  righe per canale, tabella con spunta, riga, posizione o menu di scelta, attuale, nuovo, variazione, pillola d'esito),
  `rigaElenco` (:402), `riepilogo` (:607: KPI e tabella delle posizioni aggiornate, «Continua»), la griglia dei valori
  fermi (`corpoGriglia`, :503). **Lo disegna anche l'iPad** (stessa `AppPosizioni`): vedi «Codice comune con l'iPad»
  in testa.
- `Motori/AggiornaValori.swift`: `Stato` (:45: `aggiorna`, `storico`, `giaRegistrato`, `daScegliere`, `nonTrovata`,
  `nonInEssere`, `copertura`, `senzaValore`, `dataFutura`, `ripetuta`), `insolita` (:469: variazione oltre
  `sogliaInsolita` = 25% (:10) o valore zero), `esclusiIniziali` (:474: le righe a zero su una posizione che valeva
  qualcosa partono escluse, «riscattata o scaduta: si chiude dalla scheda, non si azzera da qui»), `Sessione` (:122,
  con `soloCliente` e le `scelte`/`esclusi` già conservate quando il dettaglio copre il pannello), `applica`
  (posizioni aggiornate e `Riepilogo`).
- `Shell/StatoAggiornaValori.swift`: `apriAggiornaValori` (:11), `registraValoriInBlocco` (:89, **backup prima**
  con `dopoUnBackup`), `applicaValoriInBlocco` (:102), `importaComeNuove(soloRighe:)` (:109: apre il modulo di
  importazione). Il pulsante: `AzioniPosizioni` (ContenutoApp.swift:277); il pannello prende il posto del contenuto
  (AppPosizioni.swift:145). `soloCliente` oggi vale solo per la griglia aperta dal dossier (`apriAggiornaValori`,
  :11-21); un elenco scelto da file o dagli appunti (`apriElencoValori`, :78) apre una sessione nuova senza
  `soloCliente`. `mostraAvviso` accetta già un'azione (`AzioneAvviso`, StatoShell.swift:4116), utile per un «Annulla»
  nell'avviso se l'utente lo preferisce al riepilogo.
- C'è già quasi tutto il **motore**: dubbi (`daScegliere`, `nonTrovata`, `insolita`), storico, backup. **Manca** la
  disposizione «prima i dubbi» con la domanda, la decisione per riga, il pulsante che si accende solo a dubbi risolti,
  l'annullamento. Oggi una riga insolita è spuntata e si registra se non la si toglie.

### 44.3 Cosa fare

1. **Decisioni**: `@State decisioni: [Int: DecisioneValore]` nel pannello (`enum DecisioneValore { case giusto, nuova,
   salta }`), conservate nella sessione come `scelte` (`AggiornaValori.Sessione.decisioni`, solo memoria). Le righe
   «da decidere» sono: `insolita` con stato `.aggiorna` (domanda del calo o dell'aumento), `.nonTrovata` (domanda «È una
   polizza nuova?»), `.daScegliere` (la domanda è il menu di oggi «Scegli la posizione»: decisa quando c'è una scelta o
   «Salta»). Funzione pura in `AggiornaValori`: `daDecidere(_ esiti:, decisioni:, scelte:) -> [Int]` e
   `pronte(...)`, così la prova le controlla. Il **valore zero** non è una domanda «È giusto?»: `insolita` lo segna, ma
   oggi parte escluso (`esclusiIniziali`) perché una polizza riscattata o scaduta si chiude dalla sua scheda; resta così
   e va in «Non si registrano» con la spiegazione di oggi. La **non trovata senza un cliente riconosciuto** (nei dati di
   prova «Paolo Neri», che non è fra i clienti) ha la sua domanda: «Nell’elenco è intestata a {nome scritto}, che non è
   fra i tuoi clienti. È una polizza nuova?» e «È nuova» chiede prima il cliente (menu dei clienti), altrimenti resta
   da decidere.
2. **Disposizione** di `elencoConFile`, dall'alto:
   - testa (occhiello «Aggiorna i valori» + « · {nome}» con il cliente scelto, titolo «Dall’elenco della compagnia.»);
     ««{file}»: {n} righe lette» + « per {nome}» e il link «Scegli un altro file» (`scegliFileValori`); data comune solo se
     serve (come oggi);
   - **Da decidere** (`SezioneDubbiValori`): `CapsulaStatoApple` «Da decidere · {n}» / «Deciso», la frase, i riquadri
     `RigaDubbioValori` (avatar, titolo, domanda da `TestiAggiornaValori.domanda(e)`, pulsanti «È giusto»/«È nuova» e
     «Salta»; decisa: riga con spunta verde, frase della decisione, «Cambia»);
   - **Pronti** (`SezioneProntiValori`): capsula «Pronti · {n}», «riconosciuti dal numero di polizza o dal nome», totale
     a destra; tabella a quattro colonne (posizione con `EtichettaCanaleApple` compatta, cliente, «prima → dopo»,
     variazione); le righe `.storico` sotto con «ⓘ … Va solo nello storico.»;
   - **Non si registrano · {n}** (nuovo, chiuso di base, vedi 44.6): le righe `giaRegistrato`, `nonInEssere`,
     `copertura`, `senzaValore`, `dataFutura`, `ripetuta` con la pillola e la spiegazione di oggi;
   - il filtro «Tutte | Da controllare» e i quattro KPI di oggi escono (la disposizione li sostituisce); la spunta per
     riga resta solo nei «Pronti» (togliere una riga = non registrarla), in fondo alla riga.
3. **Piede**: il pulsante principale da `TestiAggiornaValori.pulsanteRegistra(daDecidere:, valori:)` (non
   `pulsante`: il nome c'è già, è «Aggiorna valori» di `AzioniPosizioni`): «Decidi la riga in
   arancione» / «Decidi le {n} righe in arancione» (stile normale; premuto, scossa del primo dubbio e avviso «Prima
   decidi le righe in arancione») oppure «Registra {n} valori» blu (⌘↩ come oggi); accanto «Prima di registrare Prisma
   salva una copia: si può annullare.». «Importa come nuove» esce dal piede (le non trovate si decidono una per una).
   Il numero del pulsante e dei «Pronti» conta i valori attuali che si registrano (pronti + «È giusto»); i valori più
   vecchi (`.storico`) si registrano lo stesso nello storico ma non entrano nel numero (come nel template), e le «È
   nuova» non sono valori ma posizioni nuove (dette nel riepilogo). Lo stato iniziale senza file (`vuota`, «Scegli il
   file…», «Incolla da Excel») resta, nel nuovo stile: il template parte già da un file.
4. **Registrare**: `registraValoriInBlocco` di oggi (backup prima) con le decisioni: `giusto` → la riga si registra;
   `salta` → esclusa; `nuova` → dopo i valori, le righe nuove diventano posizioni con `ImportaPosizioni.daRighe` (stessa
   lettura dell'importazione: canale e prodotto riconosciuti; cliente quello scritto nella riga o quello scelto nel
   dubbio) e `salvaPosizione`, senza aprire il modulo (vedi 44.6). Le posizioni nuove si aggiungono con **una sola
   assegnazione** a `dati.posizioni`, insieme ai valori (`applica` scrive già tutto l'array in una volta).
5. **Annullare**: prima di applicare, `StatoShell` tiene in memoria (`@ObservationIgnored var annullaValori:
   AnnullaValori?`, con le `Posizione` toccate com'erano e gli id delle posizioni nuove). «Annulla la registrazione»
   rimette quelle posizioni (per id) e toglie le nuove, poi avviso «Registrazione annullata: i valori sono quelli di
   prima». Il ricordo si cancella con «Fatto», chiudendo il pannello, cambiando sessione o al blocco; se nel frattempo una
   delle posizioni è cambiata altrove, «Annulla» non c'è più. `Posizione` non ha un numero di versione: il ricordo tiene
   anche le posizioni **com'erano subito dopo** la registrazione, e «Annulla» c'è solo se quelle dell'archivio sono
   ancora uguali (`==`). Anche l'annullamento passa da una sola assegnazione a `dati.posizioni`. Non serve un backup
   nuovo: quello fatto prima di registrare resta.
6. **Dopo** (`riepilogo`): titolo «{n} valori registrati.» nella testata, le frasi del template (con «Un valore più
   vecchio è andato solo nello storico.» se `r.storico > 0`, «Una posizione nuova è stata aggiunta.» / «{n} posizioni nuove
   sono state aggiunte.»), tre riquadri «Prima», «Dopo», «Variazione» (con `NumeroCheConta`), pulsanti «Fatto» (chiude) e
   «Annulla la registrazione», nota «Prima di registrare Prisma ha salvato una copia.». La tabella delle posizioni
   aggiornate di oggi resta sotto (utile, il template non la vieta).
7. **Con un cliente scelto** (miglioria 2): oggi l'elenco da file non ha `soloCliente` (44.2); `apriElencoValori`
   riceve il cliente scelto come la griglia (con il Portafoglio di tutti i clienti resta nil); si mostrano le
   righe abbinate a quel cliente (e le non trovate intestate a lui), con la frase «{n} righe di altri clienti restano
   fuori» e il link «Mostra tutto l’elenco».
8. **Il tema**: il pannello passa ai componenti del tema Apple (`TitoloStrumento` Apple o la testata di Studio,
   `StilePulsanteApple`, `superficieApple(.cardPiatta)`, `CapsulaStatoApple`, `AvatarCliente`), con token nuovi in
   `DesignSystem/Apple/Tema.Apple+Posizioni.swift` (`Posizioni.AggiornaValori`: riquadro del dubbio raggio 16 padding
   12×14 fondo arancio 0,10 bordo arancio 0,25, avatar 34, colonne 130/200/86, spazi 16/8/6); i token di
   `Tema.Misura.AggiornaValori` e `Tema.Colore.AggiornaValori` restano per l'iPad finché non tocca a lui. La griglia dei
   valori fermi (seconda scheda) cambia solo di stile.
9. Testi nuovi in `Motori/TestiAggiornaValori.swift`: `titoloElenco` «Dall’elenco della compagnia.», `righeLette(file:n:
   cliente:)`, `scegliAltroFile`, `daDecidere(n)`, `deciso`, `primaQueste`, `puoiRegistrare`, `domandaCalo(pct:prima:
   dopo:)` («Il valore nuovo è più basso del {x}%: da {a} a {b}. È giusto, o nell’elenco c’è un errore?»), per l'aumento
   insolito «Il valore nuovo è più alto del {x}%: …», per il valore zero «Il valore nuovo è zero: …», `domandaNuova(nome:)`,
   `eGiusto`, `eNuova`, `salta`, `cambia`, le tre frasi della decisione, `pronti(n)`, `riconosciuti`, `soloStorico`,
   `pulsante(...)`, `notaCopia`, `notaCopiaFatta`, `registrati(n)`, `frasiDopo`, `annulla`, `avvisoRegistrati`,
   `avvisoAnnullata`, `prima`, `dopo`, `variazione`.

**Non fare**: non portare `AGG`, «Valori di novembre.xlsx» né la soglia del 18% del template (la soglia resta
`sogliaInsolita` del motore); non registrare senza il backup di oggi; non togliere la griglia dei valori fermi.

### 44.4 Dati, archivio, privacy

Nessun campo nuovo: decisioni e ricordo per l'annullamento restano in memoria. Il backup prima della registrazione resta
(`dopoUnBackup`). Le posizioni nuove sono `Posizione` come quelle importate oggi (nel file del cliente, nei backup e, come
ogni posizione, nello spazio cifrato di «Prisma ovunque»). Il pannello resta chiuso in modalità cliente (lavoro su più
clienti). Nessun dato esce dal Mac.

### 44.5 Istantanee e prove

- Da aggiornare: «180-posizioni-aggiorna-elenco» (e -scuro: dubbi in alto con le domande, pronti sotto, pulsante «Decidi
  le 2 righe in arancione»), «181-posizioni-valori-fermi» (solo stile), «182-posizioni-aggiorna-registrati» (riquadri e
  «Annulla la registrazione»), «183-posizioni-multiramo-aggiornata». I dati di prova `DatiAggiornaValoriDemo.elenco`
  danno già una non trovata senza cliente («Paolo Neri», che non è fra i clienti di prova), una temporanea a zero
  (esclusa: «Non si registrano») e un valore più vecchio (la multiramo a −200 giorni, «Va solo nello storico»); vanno
  aggiunte una riga con un calo oltre `sogliaInsolita` (25%) su una posizione di prova e una polizza non trovata
  intestata a un cliente di prova, così la scena mostra le due domande del template. Le cifre si scelgono sui dati di
  prova, non quelle di `AGG`.
- I numeri 184 e 185 sono liberi oggi (verificato).
- Nuove: «184-posizioni-aggiorna-decisi» (dubbi decisi, pulsante blu «Registra {n} valori»), «185-posizioni-aggiorna-
  cliente» (cliente scelto, «righe di altri clienti restano fuori»), chiare e scure la prima.
- Prove: `ProvaCalcoliAggiornaValori` — `daDecidere`/`pronte` con insolita, non trovata e da scegliere; registrazione con
  «salta», «giusto» e «nuova»; **annullamento** che rimette valori, storico e date e toglie le nuove; nessun annullamento
  se una posizione è cambiata dopo. `--prova-backup` non cambia (nessun campo nuovo), ma la prova dell'annullamento va
  fatta su `StatoShell` in memoria come `applicaValoriInBlocco`.

### 44.6 Decisioni per l'utente e rischi

- **Scheda sopra o pannello nella finestra?** Il template apre una scheda; l'app mostra un pannello al posto del
  contenuto (le istantanee lo fotografano, gli elenchi lunghi hanno spazio). Proposta: pannello nella finestra, con la
  disposizione del template.
- **«È nuova»** oggi passa dal modulo di importazione (dove si controllano canale e prodotto). Proposta: la posizione
  nasce subito alla registrazione, con il canale riconosciuto mostrato nella riga del dubbio («canale: Alleanza»), e si
  può annullare; in alternativa resta il modulo di oggi dopo la registrazione.
- **Le righe che non si registrano** (già registrate, chiuse, coperture, senza valore, date future, ripetute): il template
  non le mostra. Proposta: una sezione chiusa «Non si registrano · {n}» in fondo.
- **Annullare dopo aver chiuso**: proposta, no (solo dal riepilogo; dopo resta il backup fatto prima). In alternativa
  anche un «Annulla» nell'avviso (`mostraAvviso(…, azione:)`), finché il ricordo vale.
- **La non trovata di una persona che non è cliente** («È nuova» con il cliente da scegliere, 44.3 punto 1): proposta,
  sì; in alternativa queste righe vanno solo in «Non si registrano» con «Importa come posizioni nuove» di oggi.
- Rischi: il pannello è lungo (835 righe) e nello stile vecchio: rifarlo nel tema Apple è la parte più grande; le righe
  devono restare pigre (elenchi della compagnia con centinaia di righe) e i calcoli fuori dal `body` come oggi
  (`ricalcolaElenco` all'`onChange`). L'annullamento deve coprire anche lo storico dei valori delle posizioni (le
  `rilevazioni` e `dataValore`: rimettendo le `Posizione` intere com'erano si coprono da sé). Il pannello di oggi resta
  all'iPad (vedi in testa): il nuovo è un file a parte solo Mac, e `AppPosizioni` sceglie con `#if os(macOS)`.

### 44.7 Dimensione

**L** (oltre 500 righe con il passaggio al tema Apple). File: Shell/AggiornaValoriVista.swift, Shell/StatoAggiornaValori.swift,
Motori/AggiornaValori.swift, Motori/TestiAggiornaValori.swift, DesignSystem/Apple/Tema.Apple+Posizioni.swift,
Shell/DatiAggiornaValoriDemo.swift, Sources/Prisma/Istantanee.swift, Motori/ProvaCalcoliAggiornaValori.swift.

---

## Decisioni comuni a tutto il gruppo

- **Le migliorie arrivano anche sull'iPad?** Radar, prova del fuoco, smontaggio e «Aggiorna valori» sono le stesse viste
  sul Mac e sull'iPad (`AppPosizioni` dentro `GuscioiPad`). La richiesta di oggi è «per il momento solo il Mac».
  Proposta: i cambiamenti di comportamento sotto `#if os(macOS)` (o in viste nuove solo Mac, come il pannello della 44),
  l'iPad resta com'è e le sue istantanee non cambiano; arriveranno sull'iPad con il suo giro. In alternativa le si lascia
  arrivare anche sull'iPad subito (meno codice doppio, ma le istantanee dell'iPad cambiano e vanno guardate).
- Le decisioni delle singole migliorie sono nei paragrafi 40.6, 41.6, 42.6, 43.6 e 44.6. Nessuna tocca la grafica del
  tema, i colori dei canali, la privacy o l'archivio, salvo l'alternativa del `.txt` dello smontaggio (42.6), che
  cambierebbe l'archivio e quindi non è la proposta.
