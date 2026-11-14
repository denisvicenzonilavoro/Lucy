# Gruppo 09 — Lo Studio, scheda per scheda (migliorie 52-57)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026). Le righe citate sono quelle della
copia senza immagini Design/uso/.template-senza-immagini.html (stesse righe del template). Commento in testa: righe
67-73; CSS del gruppo: righe 738-745; codice: righe 4616-4739 («SETTIMO GIRO · Lo Studio»); pannello «✦ Migliorie»:
`MIG9`, righe 4741-4747. Per ciò che non cambia valgono la base «Luce» (Studio: righe 1354-1456 per Cruscotto, Parcelle,
Track record ed Esame OCF; 2225-2262 per la Palestra; 2538-2574 per le Spese) e le specifiche
Design/template-novita-specifica.md (§1.6, §2 Cruscotto, §4 Track record, §11 Esame OCF) e
Design/template-luce-specifica.md (§5.3 Palestra, §6.3 Spese).

Solo Mac. Studio non è nel dock di iPhone e iPad ma **c'è in «Tutte le app»** (ProvaDockMobile.swift:62: le app del Mac
fuori dal dock dell'iPad sono Biblioteca, Mercato, Studio e Impostazioni), e Studio › Spese c'è solo sul Mac
(`SchedaStudio.speseSulDispositivo`, StudioApp.swift:37). I file di Studio in Shell/ sono gli stessi per iOS: le
modifiche non devono rompere quella compilazione e, siccome iPhone e iPad vengono dopo, ciò che cambia l'aspetto o il
comportamento su iPad e iPhone (fili del segmentato, titoli-domanda, filtri, bilancio, «Cambia») va o accettato così
com'è, perché la vista è la stessa, o tenuto dietro `#if os(macOS)`: si decide giro per giro, guardando le istantanee
iOS del workflow su main, senza riprogettare nulla per iPhone e iPad in questo gruppo. Le cose solo del puntatore
(`.onHover`, `NSCursor`) vanno comunque dietro `#if os(macOS)`. In modalità cliente Studio resta «Studio resta tuo» (`RiservatoStudio`,
StudioApp.swift:352): nessuna miglioria di questo gruppo cambia questa regola.

Il pannello «✦ Migliorie» (`MIG9`) e i cartellini `indica(...)` sono solo dimostrativi: nell'app non si portano. Non si
portano nemmeno le cifre scritte a mano del template (`PREV12`, `TR`, `OCF`, `OCFD`, `PAL_ULT`, `SPM`, `KMM`, i 24 punti
inventati della dispersione): le cifre le danno i motori che ci sono (`MotoreStudio`, `MotoreTrackRecord`, `MotoreOCF`,
`PalestraVera`, `MotoreChilometri`, `MotoreSpese`).

## Ordine consigliato

1. **52 · Lo Studio in ordine**: piccola, senza dipendenze (solo il segmentato e un titolo). Si fa per prima perché tocca
   `AzioniStudio`, la riga in testa di Studio, che usano anche la 28 (gruppo 04, «＋ Nuova parcella» nella riga in testa)
   e la miglioria 4 (gruppo 01, «Una riga sola in testa alla finestra»): conviene farla **dopo la 4** (se è già fatta) e
   coordinarla con la 28, così la riga di Studio si tocca una volta sola (con «Esame OCF», più lungo di «OCF», e i due
   fili la riga si allarga di circa 70 punti: va riprovata alla larghezza minima della finestra con la 4 e la 28).
2. **53 · Il cruscotto risponde a domande**: indipendente dalle altre. Usa i nomi dei canali della **38** (gruppo 06,
   «I canali hanno il nome che scegli») nella riga degli incassi: se la 38 non c'è ancora si usano i nomi di oggi
   («Alleanza», «Indipendente») e la frase passa ai nomi scelti quando arriva. Usa il colore arancio dei testi della **7**
   (gruppo 01) solo indirettamente.
3. **57 · Le spese, mese per mese**: indipendente; usa `apriAgendaGiorno` (c'è già). Se è già fatta la **50** (gruppo
   08, «Il mese a tutta larghezza») il rimando delle scadenze apre l'Agenda nella vista mese di quella miglioria; si
   incrocia con la **3** (gruppo 01, «Un solo "Da fare"») se le scadenze dello Studio entrano nel «Da fare» (vedi 57.6).
4. **55 · Il quiz OCF chiude con un bilancio**: indipendente, quasi tutto dentro StudioEsameOCF.swift, più la pillola di
   stato con un testo qualsiasi (che poi riusa la 56: per questo la 55 viene prima).
5. **54 · Il track record segue il cliente** e **56 · La palestra si fa sul cliente che vedrai**: per ultime, perché
   leggono il cliente della barra della **2** (gruppo 01, «Un solo posto per scegliere il cliente»: `tuttiIClienti`,
   `scegliCliente`, `clienteAttivoId` vuoto = «Tutti i clienti»). Senza la 2 si possono fare leggendo
   `stato.clienteAttivo` com'è oggi, ma il caso «Tutti i clienti» (il track record di tutti) esiste solo con la 2.
   La 54 usa anche la pillola di stato (`PillolaEsitoApple`, c'è già) e il filtro a chip del tema (`.fch`), che
   disegnano anche la **14** (gruppo 02, le capsule dei canali sopra l'elenco delle posizioni) e la **19** (gruppo 03,
   «Com'è andata?»): chi arriva per primo fa il componente comune in `DesignSystem/Apple/`, gli altri lo riusano.
   La 55 e la 56 hanno bisogno di una pillola di stato **con un testo qualsiasi** («Fatta», «Torna domani», «la più
   efficace»): `PillolaEsitoApple` oggi accetta solo un `PresentazioneTrackRecord.Esito` (vedi 55.3 punto 3).

---

## 52. Lo Studio in ordine

### 52.1 Nel template

Righe 4622-4626 e CSS riga 739. La riga in testa di Studio (`APPS.studio.act`) resta «▶︎ Il tuo anno» seguito dal
segmentato delle schede, ma le sei schede ora sono in **tre gruppi separati da un filo** (`STG`):

- i conti: **Cruscotto · Parcelle · Spese**;
- i risultati: **Track record**;
- l'allenamento: **Esame OCF · Palestra**.

Il filo (`.seg .sgS`) è un'asta verticale larga 1, alta quanto il segmentato meno 6 sopra e 6 sotto, con 6 di margine a
destra e a sinistra, colore `--ink3` all'opacità 0,5. Non si sceglie, non ha pillola: la pillola bianca scivola da una
voce all'altra passando sopra il filo come prima.

Cambiano anche due cose rispetto a «Luce» (riga 2572): **le Spese salgono dal fondo al terzo posto**, accanto alle
Parcelle, e la voce **«OCF» torna «Esame OCF»** (nella base di «Orizzonte», riga 1370, si chiamava già così). Le altre
voci restano «Cruscotto», «Parcelle», «Track record», «Palestra». Il pulsante «▶︎ Il tuo anno» resta dov'è.

Il pannello (`MIG9[0]`) spiega: «Prima le sei schede erano in fila senza un criterio, con le Spese in fondo, lontane dalle
Parcelle. Ora sono tre gruppi separati da un filo…» (dimostrativo).

### 52.2 Nell'app oggi

- `Sources/Prisma/Shell/StudioApp.swift:17` `enum SchedaStudio: CaseIterable` con l'ordine
  `cruscotto, fatture, track, ocf, palestra, spese`; `titolo` (riga 24) dà «Cruscotto», «Parcelle», «Track record»,
  **«OCF»** (riga 28), «Palestra», «Spese». `visibili(modoCliente:)` (riga 46) filtra le Spese (solo Mac, mai in
  modalità cliente).
- `AzioniStudio` (StudioApp.swift:191): «Il tuo anno» (non in modalità cliente) e `SegmentatoPillola` (riga 208) con
  `SchedaStudio.visibili`.
- `SegmentatoPillola` (DesignSystem/Apple/ControlliApple.swift:19): voci in un `HStack(spacing: 0)`, pillola con
  `matchedGeometryEffect` per indice. **Non conosce i separatori.**
- `Sources/Prisma/Vera/ProvaPalestraVera.swift:357-358` controlla `SchedaStudio.ocf.titolo == "OCF"`.
- `StatoNovita.swift` apre Studio su schede precise (`apriStudio(_:)`), senza dipendere dall'ordine.

### 52.3 Cosa fare

1. **L'ordine.** In `SchedaStudio` riordinare i casi in `cruscotto, fatture, spese, track, ocf, palestra` (i `rawValue`
   non cambiano: `schedaStudio` non è salvata nell'archivio, ma i nomi restano gli stessi per sicurezza). Aggiungere
   `var gruppo: Int` (0 conti, 1 risultati, 2 allenamento) con un commento che rimanda a questa miglioria.
2. **Il titolo.** `case .ocf: return "Esame OCF"` e aggiornare il commento (oggi cita la riga 2085 di «Luce» che
   accorciava i titoli). Aggiornare `ProvaPalestraVera.swift:358` («Esame OCF»).
3. **I fili nel segmentato.** In `SegmentatoPillola` un parametro facoltativo nuovo
   `separatoriPrima: Set<Int> = []` (indici delle voci davanti alle quali va il filo) in entrambi gli `init`. Nel `body`,
   dentro il `ForEach`, prima della voce `i` se `separatoriPrima.contains(i)` un `Rectangle()` largo
   `Segmentato.filo`, con `.padding(.vertical, Segmentato.marginiFilo)` e `.padding(.horizontal, Segmentato.marginiFilo)`,
   colore `Tema.Apple.Colore.inchiostro3.opacity(Segmentato.opacitaFilo)`, `.accessibilityHidden(true)`. La pillola
   continua a seguire le voci (gli id del `matchedGeometryEffect` restano gli indici delle voci, i fili non ne hanno);
   con «Riduci movimento» e nelle istantanee nulla cambia rispetto a oggi. **Attenzione all'altezza**: `AzioniStudio`
   mette il segmentato in `.fixedSize()`, e lì un `Rectangle` senza altezza propria prende la sua misura ideale (10
   punti), non quella delle voci. Il filo va quindi disegnato con un'altezza esplicita, da token ricavata da carattere e
   padding della voce (`Tema.Apple.Carattere.barra` e `Misura.Padding.voceSegmentato`) meno 2 × 6, come vista a sé fra
   due voci. Non come overlay o padding della voce: la pillola prende la cornice della voce (`matchedGeometryEffect`)
   e si allargherebbe sopra il filo. Da verificare nell'istantanea.
4. In `AzioniStudio` calcolare i separatori dalle schede visibili: un filo davanti a ogni scheda il cui `gruppo` è
   diverso da quello della scheda prima (così, se le Spese non si vedono, i fili restano giusti:
   «Cruscotto · Parcelle | Track record | Esame OCF · Palestra»).
5. **Token nuovi** in `DesignSystem/Apple/Tema.Apple+Controlli.swift`, `enum Segmentato`: `filo: CGFloat = 1`,
   `marginiFilo: CGFloat = 6`, `opacitaFilo: Double = 0.5`.
6. Il commento in testa a StudioApp.swift (righe 3-5) va aggiornato con l'ordine e i tre gruppi.

**Non fare**: non cambiare la larghezza o il carattere delle voci, non dare un'etichetta ai gruppi (il template non ne
ha), non toccare «▶︎ Il tuo anno».

### 52.4 Dati, archivio, privacy

Nessun campo nuovo. `schedaStudio` vive in memoria in `StatoShell`. Nessun tema di privacy: in modalità cliente il
segmentato resta com'è oggi (senza Spese; le schede mostrano «Studio resta tuo»).

### 52.5 Istantanee e prove

- Da aggiornare (si vede la riga in testa con l'ordine e i fili): «570-studio-cruscotto» (chiara e scura),
  «505-app-nuove-studio», «520-studio-track», «530-studio-ocf», «720-studio-palestra», «780-studio-spese».
- Nuova: «1090-uso-studio-in-ordine» (chiara e scura): Studio sul Cruscotto, finestra larga, per guardare i fili; e
  «1090-uso-studio-in-ordine-modo-cliente» (il segmentato senza Spese: due fili al posto giusto).
- La vetrina «400-vetrina-apple» può mostrare un segmentato con un filo (facoltativo).
- Prove: `--prova-vera` (`ProvaPalestraVera`, il titolo «Esame OCF»); `--prova-backup` (`ProvaBackupSpese.swift:231` e
  248 controllano `visibili`, restano verdi).

### 52.6 Decisioni per l'utente e rischi

- Nessuna decisione aperta: il template decide ordine, gruppi e nome.
- Rischio: il segmentato è un componente usato in molte app; il parametro nuovo ha un valore di base vuoto, quindi le
  altre chiamate non cambiano. Controllare che la pillola non «salti» passando sopra il filo (le cornici delle voci
  vicine non si toccano più: l'animazione resta la stessa molla).
- Rischio: la riga in testa più larga (vedi «Ordine consigliato», punto 1) nella finestra di Studio al minimo.

### 52.7 Dimensione

**S.** File: Shell/StudioApp.swift, DesignSystem/Apple/ControlliApple.swift, DesignSystem/Apple/Tema.Apple+Controlli.swift,
Vera/ProvaPalestraVera.swift, Shell/IstantaneeStudio.swift.

---

## 53. Il cruscotto risponde a domande

### 53.1 Nel template

Righe 4628-4630 (`MESIL`), 4724-4727 (testi) e 4732-4736 (comportamento). Il Cruscotto tiene la sua griglia di cinque
card (base, righe 1374-1390), ma:

1. **I titoli diventano domande** (stesso stile `.lbl` di prima):
   - «I tuoi ricavi 2026» → **«Quanto ho guadagnato nel 2026?»**
   - «Gli obiettivi dell’anno» → **«A che punto sono con gli obiettivi?»**
   - «L’imbuto delle proposte» → **«Dove si fermano le proposte?»**
   - «Gli incassi dei prossimi 12 mesi» → **«Cosa incasso nei prossimi 12 mesi?»**
   - «Il valore e il tempo» → **«A chi dedico più tempo di quanto rende?»**
2. **Gli incassi**: la didascalia «Rinnovi e premi ricorrenti Alleanza, parcelle già firmate. Stima con le tue aliquote.»
   sparisce; al suo posto una riga con le **due etichette dei canali** (compatte, `A` e `I`) e, a destra, `#incDett`
   (testo `.k`): a riposo **«Il mese più ricco: <mese>, <importo>»** (il mese col totale più alto, nome intero
   minuscolo da `MESIL`, per esempio «Il mese più ricco: novembre, 7.400 €»). **Passando su una colonna** la riga dice
   **«<mese>: <nome Alleanza> <importo> + <nome indipendente> <importo> = <totale>»** con il mese e il totale in
   grassetto `--ink`, e la colonna si schiarisce (`brightness(1.12)`); uscendo torna la frase di riposo. I nomi dei
   canali sono quelli scelti dall'utente (`nomiCh`, miglioria 38). Il cursore resta quello normale.
3. **Gli obiettivi**: sotto la legenda degli anelli una riga nuova `#obiDice` (`.k`, 10 sopra, interlinea 1,45):
   **«Il più indietro: nuovi clienti, 7 su 10. Ne mancano tre in due mesi.»** («Il più indietro:» in grassetto `--ink`).
4. **Il valore e il tempo**: la didascalia diventa `#scatDice`, che a riposo dice «Ogni punto è un cliente: più a
   destra, più ore; più in alto, più ricavi.» e, montato il grafico, si riscrive con ciò che si vede:
   **«<b>N clienti</b> prendono molte ore e rendono poco: il più pesante, X ore per Y € l’anno. Tocca un punto con il
   nome per aprirlo.»** oppure **«Nessun cliente prende molte ore rendendo poco.»**. Sul grafico compare in alto a
   sinistra l'etichetta dell'asse verticale **«ricavi dell’anno ↑»** (11, `--ink3`). **I punti con il nome** (le
   iniziali) hanno il cursore a mano e **aprono il dossier** del cliente (`vaiCli(k,'clienti')`); i punti senza nome no.
5. L'imbuto e la card dei ricavi cambiano solo il titolo.

### 53.2 Nell'app oggi

`Sources/Prisma/Shell/StudioCruscotto.swift` (`CruscottoStudioVista`, riga 18) e `StudioGrafici.swift`; cifre da
`MotoreStudio` in cache (`cruscottoStudio()`), token in `Tema.Apple+Studio.swift`.

- Titoli scritti nelle card: riga 200 «I tuoi ricavi \(anno)», 387 «Gli obiettivi dell’anno», 487 «L’imbuto delle
  proposte», 572 «Gli incassi dei prossimi 12 mesi», 629 «Il valore e il tempo» (`TitoloCardStudio`, riga 127, con la
  pillola «dati di prova»).
- `CardIncassiStudio` (riga 562): didascalia (riga 607, dice anche «Senza le tue aliquote…» o «Stima con le tue
  aliquote · N posizioni senza aliquota»), pulsante «Inserisci le tue aliquote in Impostazioni › Studio ›», **la legenda
  dei due canali c'è già** (`EtichettaCanaleApple` compatte, riga 597), colonne `ColonneIncassiStudio`
  (StudioGrafici.swift:16) con il fumetto `.help(TestiStudio.mese(m))` («dicembre · Alleanza 1.200 € · Indipendente
  0 €»). **Manca** la riga «Il mese più ricco» e la riga che cambia al passaggio.
- `CardObiettiviStudio` (riga 377): anelli e legenda. **Manca** «Il più indietro».
- `CardValoreTempoStudio` (riga 619): didascalia fissa `TestiStudio.didascaliaValore`, `DispersioneClientiStudio`
  (StudioGrafici.swift:124) con la zona «molto tempo, poco valore», l'asse orizzontale «0 ore … N ore l’anno»; **tutti i
  punti** (con e senza nome) aprono il dossier (`PuntoClienteStudio`, riga 230, `onTapGesture`, riga 256) e hanno il
  fumetto. **Manca** la frase che dice cosa si vede e l'etichetta dell'asse verticale.
- Il motore ha già ciò che serve: `CruscottoStudio.ValoreTempo.inZona` (MotoreStudio.swift:216, i clienti nella zona),
  `Obiettivo.frazione` (riga 111), `Incassi.mesi` con `alleanza`/`indipendente`/`totale` (riga 159).

### 53.3 Cosa fare

1. **Titoli.** Nuove costanti in `TestiStudio` (StudioApp.swift:82): `domandaRicavi(anno:)` = «Quanto ho guadagnato
   nel \(anno)?», `domandaObiettivi` = «A che punto sono con gli obiettivi?», `domandaImbuto` = «Dove si fermano le
   proposte?», `domandaIncassi` = «Cosa incasso nei prossimi 12 mesi?», `domandaValore` = «A chi dedico più tempo di
   quanto rende?». Sostituirle nelle cinque chiamate di `TitoloCardStudio`. Il titolo resta su una riga
   (`minimumScaleFactor` come oggi): «A chi dedico più tempo di quanto rende?» è il più lungo, va provato alla
   larghezza minima della card.
2. **Il motore** (`Motori/MotoreStudio.swift`), funzioni pure e provate:
   - `Incassi.piuRicco: MeseIncasso?` (il mese col totale più alto, a pari merito il primo; nil se tutti zero);
   - `Obiettivi.piuIndietro: Obiettivo?` (fra gli impostati con `frazione < 1`, quello con la frazione più bassa; nil se
     sono tutti raggiunti o nessuno è impostato) e `mesiAllaFine(oggi:)` (mesi interi che mancano al 31 dicembre,
     arrotondati per eccesso: a metà novembre «due mesi», come il template);
   - `ValoreTempo.piuPesante: PuntoCliente?` (fra `inZona`, quello con più ore; a pari merito meno ricavi).
3. **Testi** in `TestiStudio`:
   - `piuRicco(_ m:)` = «Il mese più ricco: \(mese intero), \(euro)»;
   - `meseIncasso(_ m:, nomeAlleanza:, nomeIndipendente:)` → `Text` composto: mese in grassetto, «: <nome A>
     <importo> + <nome I> <importo> = », totale in grassetto; se la parte Alleanza è nil (senza aliquote) «<nome A>
     senza aliquote» al posto dell'importo e il totale è solo l'indipendente;
   - `piuIndietro(_ o:, mesi:)` = «Il più indietro: \(voce con l'iniziale minuscola), \(fatto) su \(traguardo). Ne
     mancano \(n) in \(mesi).» (solo la prima lettera minuscola, come `TestiEsameOCF.puntoDebole`: «produzione
     Alleanza», «nuovi clienti», «ricavi consulenza»; il nome del canale resta maiuscolo e, con la 38, è quello
     scelto) dove per i nuovi clienti i numeri sono interi in lettere fino a dieci (funzione nuova
     `FormatoCifra.inLettere(_:)` o in `TestiStudio`: «uno… dieci», poi cifre) e per le cifre in euro
     `TestiStudio.euro` («Ne mancano 7.960 € in due mesi»); «in un mese», «in due mesi»… fino a «in dodici mesi»; se il
     mese è dicembre e manca meno di un mese, «entro fine anno»;
   - `valoreDice(_ v:)`: «\(n) clienti prendono molte ore e rendono poco: il più pesante, \(ore) ore per \(euro)
     l’anno. Tocca un punto con il nome per aprirlo.» (con «1 cliente prende…» al singolare; il numero in grassetto) o
     «Nessun cliente prende molte ore rendendo poco.»; se la zona non si calcola (`sogliaOre == nil`) resta la frase di
     riposo nuova `didascaliaValore` = «Ogni punto è un cliente: più a destra, più ore; più in alto, più ricavi.»;
   - `asseRicavi` = «ricavi dell’anno ↑».
4. **Gli incassi** (`CardIncassiStudio`): la riga della legenda diventa `HStack` con le due `EtichettaCanaleApple`
   compatte e, spinta a destra, la frase (`NotaStudio`, una riga, `lineLimit(1)` e `minimumScaleFactor`). Uno `@State
   var sopra: Date?` (il mese sotto il puntatore) in `CardIncassiStudio`, passato come `Binding` a
   `ColonneIncassiStudio` (usato solo qui, StudioCruscotto.swift:599), che su macOS mette `.onHover { dentro in sopra
   = dentro ? m.inizio : (sopra == m.inizio ? nil : sopra) }` su ogni colonna e schiarisce quella sotto il puntatore
   con `.brightness(Incassi.luceSopra)`. Il fumetto `.help` si toglie (lo sostituisce la riga), ma il testo del mese
   resta come `accessibilityLabel` della colonna (VoiceOver non passa col puntatore). Il cursore resta quello normale. La didascalia lunga di oggi si toglie dalla card, ma **lo stato
   di stima resta dichiarato**: la frase «Stima con le tue aliquote…» (o «Senza le tue aliquote la parte Alleanza resta
   vuota.») va nel `.help` del titolo e, quando mancano aliquote, resta il pulsante «Inserisci le tue aliquote…» (vedi
   53.6). I nomi dei canali: quelli della miglioria 38 se c'è (`Canale.nomeScelto` o come lo chiamerà il gruppo 06),
   altrimenti `Canale.nomeBreve`.
5. **Gli obiettivi** (`CardObiettiviStudio`): sotto la legenda, se `piuIndietro != nil`, `NotaStudio` con il testo
   composto (etichetta in grassetto `inchiostro`), a `Obiettivi.sopraFrase` 10. Se sono tutti raggiunti nessuna riga
   (il template non ne prevede un'altra).
6. **Il valore e il tempo** (`CardValoreTempoStudio` e `DispersioneClientiStudio`): la didascalia diventa
   `TestiStudio.valoreDice(valore)`, su due righe al massimo; dentro il grafico, in alto a sinistra, l'etichetta
   `asseRicavi` (carattere `Dispersione.asse`, colore `coloreAsse`, a −2 dall'alto). I punti **con nome** aprono il
   dossier come oggi e su macOS mostrano la mano (`.onHover` con `NSCursor.pointingHand`, come gli altri punti
   cliccabili dell'app). I punti **senza nome** nell'app aprono già il dossier e hanno il fumetto con nome, ore e
   ricavi: si tengono così, con la mano anch'essi (il template, che parte da una base in cui nessun punto si toccava,
   aggiunge il clic solo ai punti con nome; togliere un comportamento che c'è non serve, vedi 53.6).
7. **Token** in `Tema.Apple+Studio.swift`: `Incassi.luceSopra: Double = 0.06` (l'equivalente di `brightness(1.12)` in
   SwiftUI, da provare a occhio nelle istantanee chiare e scure), `Obiettivi.sopraFrase: CGFloat = 10`,
   `Obiettivi.interlineaFrase` (1,45 → `lineSpacing` dal carattere della nota), `Dispersione.asseVerticaleSopra:
   CGFloat = -2`.

**Non fare**: non portare i 24 punti inventati né le cifre di `PREV12`; non scrivere «7 su 10» fisso; non cambiare le
dimensioni della griglia.

### 53.4 Dati, archivio, privacy

Nessun campo nuovo: tutto si ricava dal `CruscottoStudio` in cache. Privacy: la frase della dispersione **non dice il
nome** del cliente più pesante (solo ore e ricavi), e Studio in modalità cliente non si mostra. Nessuna richiesta di rete.

### 53.5 Istantanee e prove

- Da aggiornare: «570-studio-cruscotto» (chiara e scura: titoli, «Il mese più ricco», «Il più indietro», la frase della
  dispersione e l'asse), «571-studio-cruscotto-vuoto», «572-studio-cruscotto-senza-aliquote» (la riga degli incassi
  senza la parte Alleanza), «574-studio-cruscotto-senza-obiettivi» (nessuna riga «Il più indietro»), e la scrivania
  «500-scrivania-orizzonte» se il riquadro di Studio usa gli stessi titoli (oggi `StudioScrivania.swift` ha i suoi).
- Nuove: «1091-uso-cruscotto-mese» (chiara e scura) con un mese «sotto il puntatore» chiesto dalla scena (una
  `RichiestaIstantaneaCruscotto` con il mese, come `RichiestaIstantaneaTrack`), così si vede la riga che cambia e la
  colonna schiarita; «1091-uso-cruscotto-obiettivi-raggiunti» (nessuna riga «Il più indietro»).
- Prove: `--prova-calcoli` (`ProvaCalcoliStudio.swift`): `piuRicco` (pari merito, tutti zero), `piuIndietro` (tutti
  raggiunti, uno a zero, nuovi clienti oltre il traguardo), `mesiAllaFine` (gennaio, metà novembre, 31 dicembre),
  `piuPesante` (zona vuota, pari merito), e i testi (`inLettere`, singolare e plurale). `--prova-fluidita`: passare sulle
  colonne non rifà i motori (lo stato del puntatore è dentro la card, non nella `ChiaveVista`).

### 53.6 Decisioni per l'utente e rischi

- **La didascalia degli incassi** («Rinnovi e premi ricorrenti Alleanza, parcelle già firmate. Stima con le tue
  aliquote.») nel template sparisce. Proposta: si toglie dalla card ma resta nel fumetto del titolo, e quando mancano le
  aliquote resta il pulsante che porta a Impostazioni › Studio; così la regola «le stime si dichiarano» resta. Va
  coordinata con la 16 (gruppo 02, «Un solo avviso sulle stime»), se l'utente vuole lo stesso trattamento anche qui.
- **I punti senza nome**: nessuna decisione. Nel template non si toccano perché nella base non si toccava nessun
  punto; nell'app aprono già il dossier (`PuntoClienteStudio`, StudioGrafici.swift:256) e si tengono così, con il
  fumetto. La frase «Tocca un punto con il nome per aprirlo» resta vera.
- **Numeri in lettere** («Ne mancano tre»): proposta, in lettere fino a dieci, poi in cifre.
- Rischi: `onHover` su dodici colonne dentro un `GeometryReader` è leggero; lo stato del puntatore sta nella card
  (non in `StatoShell`), così non ridisegna il resto del Cruscotto.

### 53.7 Dimensione

**M.** File: Shell/StudioCruscotto.swift, Shell/StudioGrafici.swift, Shell/StudioApp.swift (`TestiStudio`),
Motori/MotoreStudio.swift, Motori/ProvaCalcoliStudio.swift, DesignSystem/Apple/Tema.Apple+Studio.swift,
Shell/IstantaneeStudio.swift.

---

## 54. Il track record segue il cliente

### 54.1 Nel template

Righe 4632-4641 (`trF`, `trVis`, `trackHTML`) e 4738 (filtri e «Riproponi»). Studio entra fra le app che seguono il
cliente della barra (`APPCLI.push('studio')`, riga 4620): scegliendo un cliente il track record si ridisegna.

**Con «Tutti i clienti»** (nessun cliente scelto): le quattro tessere di sempre («Raccomandazioni dal 2024», «Accettate»
in %, «Ancora in essere dopo 12 mesi» in %, «Rispetto all’alternativa, in media» in verde) e il titolo «Le
raccomandazioni e come sono andate».

**Con un cliente scelto**: le tessere diventano **«Raccomandazioni a <Nome>»** (numero), **«Accettate»** (numero),
**«Rimandate o rifiutate»** (numero) e **«In più rispetto all’alternativa»** (la somma degli scarti delle accettate in
verde con il «+», o «—»); il titolo diventa **«Le raccomandazioni a <Nome>»** e l'elenco mostra solo le sue.

In entrambi i casi:
- **a destra del titolo i filtri a chip** (`.fch`, riga `#trFil`): **«Tutte» · «Accettate» · «Rimandate» ·
  «Rifiutate»**; uno solo acceso; filtrano l'elenco per esito;
- la nota «l’alternativa è ricostruita con i dati di mercato del periodo» lascia la riga del titolo e va **in fondo**,
  più lunga: **«L’alternativa è ricostruita con i dati di mercato del periodo. Sono stime: servono a te; al cliente le
  mostri solo spiegandole.»**;
- ogni card: avatar, proposta, «<Nome> · <data> · invece di: <alternativa>», **la pillola di stato** (`st2`: Accettata
  verde, Rimandata arancio, Rifiutata rossa), il grafico, e a destra (larga 132): lo scarto «+4.180 €» con «rispetto
  all’alternativa», oppure per le rifiutate «il cliente ha scelto diversamente», oppure, per le **rimandate**, il
  pulsante **«Riproponi»**. Al clic diventa **«✓ Tra le proposte»** e l'avviso dice **«<proposta>» torna tra le
  proposte di <Nome>, con i numeri di oggi**; il clic non apre il dettaglio della card;
- elenco vuoto: con un filtro **«Nessuna con questo esito.»**; per un cliente senza raccomandazioni **«Nessuna
  raccomandazione registrata per <Nome>: la prima nasce quando salvi una proposta.»** (44 sopra e sotto, centrato, 14,5).

Il dettaglio della card (base, righe 1438-1446) non cambia.

### 54.2 Nell'app oggi

`Sources/Prisma/Shell/StudioTrackRecord.swift`:
- `TrackRecordStudioVista` (riga 243) → `ElencoTrackRecord` (riga 275, `Equatable` su `stato`, `chiave`, `base`): dati
  da `stato.trackRecord()` (StatoTrackRecord.swift:73, in cache per giorno e versione dei calcoli), voci ordinate in
  `ricavato("studio.track.ordine")`, linee in `ricavato("studio.track.linee")`.
- `TileTrackRecord` (riga 341) con le quattro tessere di tutto l'archivio e le didascalie (`didascaliaRaccomandazioni`,
  ecc., righe 153-180); `TitoloTrackRecord` (riga 420) con `TestiTrackRecord.titolo` e `notaTitolo` («l’alternativa è
  ricostruita con i riferimenti del periodo»).
- `CardRaccomandazione` (riga 491) con `PillolaEsitoApple` (riga 514: la pillola di stato c'è già) e
  `RisultatoCardTrackRecord` (riga 564): per le rimandate la didascalia «da riproporre a <mese anno>» o «rimandata dal
  cliente» (riga 120). **Non c'è «Riproponi».**
- **Non segue il cliente**: mostra sempre tutto l'archivio. **Non ha filtri.** La `ChiaveVista` (DerivatiDati.swift:578)
  non contiene il cliente attivo.
- Il registro è immutabile (`Raccomandazione`, Dati/Raccomandazione.swift:118: `scelte` e `note` si aggiungono soltanto).
- Una raccomandazione è legata alla posizione proposta (`posizioneId`); la scelta del cliente viene da
  `Posizione.esito` (`EsitoProposta`: bozza, presentata, accettata, rifiutata, rimandata; Dati/Posizione.swift:44) e si
  registra da sola quando l'esito cambia (StatoTrackRecord.swift:66-69). **«Rimandata» non è una scelta registrata**:
  `SceltaCliente` ha solo accettata, rifiutata e in attesa (Raccomandazione.swift:93; `MotoreTrackRecord.scelta`,
  MotoreTrackRecord.swift:271, registra «in attesa» sia per presentata sia per rimandata). La pillola «Rimandata» si
  ricava dalla posizione: `PresentazioneTrackRecord.esito` (PresentazioneTrackRecord.swift:28) dà `.rimandata` quando
  la scelta è in attesa e `Posizione.esito == .rimandata`.
- Rimandare una proposta (`chiudiProposta`, StatoSeguito.swift:59) scrive `seguito.riprendereIl` e crea l'attività
  «Riprendere la proposta…» (`seguito.attivitaId`); `completaRipresa` (StatoSeguito.swift:123, oggi `private`) la
  chiude. Le proposte ferme si contano in `proposteInSospeso` (in cache per ora).

### 54.3 Cosa fare

1. **Il cliente.** `TrackRecordStudioVista` legge il cliente della barra (miglioria 2: `stato.tuttiIClienti` /
   `stato.clienteAttivoId`; senza la 2, `stato.clienteAttivo`) e lo passa a `ElencoTrackRecord` come `cliente: String?`,
   che entra nell'uguaglianza `==` (la `ChiaveVista` non lo contiene).
2. **Il motore.** In `Motori/PresentazioneTrackRecord.swift` (o in `MotoreTrackRecord`) una funzione pura
   `perCliente(_ t: TrackRecord, clienteId:) -> TrackRecordCliente` con `raccomandazioni`, `accettate`,
   `rimandateORifiutate`, `differenzaTotale: Double?` (somma delle `scarto.differenza` delle accettate misurate; nil se
   nessuna è misurata) e `voci`. In `StatoShell` tenerla con `ricavato("studio.track.cliente|" + id)`.
   E `filtra(_ voci:, esito: FiltroTrackRecord)`: `enum FiltroTrackRecord: CaseIterable { case tutte, accettate,
   rimandate, rifiutate }` (le «in attesa» compaiono solo in «Tutte»).
3. **Le tessere** (`TileTrackRecord`): con un cliente quattro tessere nuove, con i numeri che si contano come oggi:
   `TestiTrackRecord.raccomandazioniA(nome:)` = «Raccomandazioni a \(nome breve)», «Accettate», «Rimandate o
   rifiutate», «In più rispetto all’alternativa» (verde con `euroConSegno`, o «—»; didascalia «stima» come le altre
   cifre del track record: lo scarto è sempre dichiarato stima). Senza cliente le tessere di oggi. Nel template
   «Rimandate o rifiutate» è il totale meno le accettate (lì non ci sono proposte in attesa); nell'app conta solo
   rimandate e rifiutate, così le tre cifre non sommano al totale quando ci sono proposte in attesa (è voluto).
4. **Il titolo** (`TitoloTrackRecord`): «Le raccomandazioni a \(nome breve)» o il titolo di oggi; a destra il filtro. Il
   filtro: un componente a chip del tema (se il gruppo 01 o 02 ne ha già fatto uno lo si riusa; altrimenti
   `ChipFiltroApple` in `DesignSystem/Apple/`, forma `.fch`: capsula, testo 12,5 semibold, acceso = fondo `cardPiena`
   con l'ombra della pillola, spento = fondo `chip`), con `TestiTrackRecord.filtro(_:)` = «Tutte», «Accettate»,
   «Rimandate», «Rifiutate». Lo stato del filtro: `@State` in `TrackRecordStudioVista` (si azzera cambiando cliente:
   il template non lo azzera, ma un filtro vuoto sul cliente nuovo confonde), passato a `ElencoTrackRecord` ed entrato
   nella sua uguaglianza.
5. **La nota in fondo**: `notaTitolo` si toglie dalla riga del titolo; sotto l'elenco `TestiTrackRecord.notaStime` =
   «L’alternativa è ricostruita con i riferimenti del periodo. Sono stime: servono a te; al cliente le mostri solo
   spiegandole.» (l'app dice «riferimenti», non «dati di mercato»: i riferimenti sono quelli di Impostazioni, e solo con
   Mercato acceso vengono dalla BCE; vedi 54.6). Resta `TestiTrackRecord.piede` dove c'è.
6. **«Riproponi»** in `RisultatoCardTrackRecord`, solo per le **rimandate** la cui posizione c'è ancora: pulsante
   `.apple` con `TestiTrackRecord.riproponi` = «Riproponi». Al clic (che non apre il dettaglio: il pulsante sta sopra il
   tocco della card) `stato.riproponiRaccomandazione(id)` in `StatoTrackRecord.swift` (o accanto a `chiudiProposta`
   in StatoSeguito.swift, per usare `completaRipresa`):
   - fuori dalla sola lettura (`solaLettura` → `TestiSeguito.solaLettura`, come `chiudiProposta`);
   - porta la posizione collegata da `.rimandata` a `.bozza` (torna fra le proposte da preparare in Posizioni, dove i
     motori la ricalcolano con i numeri di oggi), toglie `seguito.riprendereIl` e chiude l'attività di ripresa
     ancora aperta (`seguito.attivitaId` → `completaRipresa`): la ripresa non serve più. La posizione si scrive
     direttamente in `dati.posizioni` come fa `chiudiProposta` (non con `salvaPosizione`, che rifarebbe
     `registraCambio`); `registraRaccomandazioneSeServe(prima:dopo:)` con «bozza» non registra nulla;
   - aggiunge alla raccomandazione una nota con la data, «Riproposta il \(giorno)» (`aggiungiNota`: il registro
     resta immutabile, le scelte non si toccano; la scelta registrata era e resta «in attesa»);
   - mostra l'avviso `TestiTrackRecord.riproposta(_ proposta:, nome:)` = «“\(proposta)” torna tra le proposte di
     \(nome), con i numeri di oggi».
   **Cosa si vede dopo**: siccome «Rimandata» si ricava dalla posizione, la voce passa a «In attesa» (pillola neutra)
   ed esce dal filtro «Rimandate». Nella sua card, al posto di «in attesa della scelta del cliente», la scritta «✓ Tra
   le proposte» (`TestiTrackRecord.traLeProposte`): si ricava da scelta in attesa e posizione tornata `.bozza`.
   Quando la proposta si ripresenta (`presentata`) non nasce una raccomandazione nuova (ce n'è già una per
   `posizioneId`) e la scelta «in attesa» non si ripete: **le cifre del registro restano quelle della prima
   presentazione** («con i numeri di oggi» vale per Posizioni, non per il track record; vedi 54.6).
   Senza posizione il pulsante non c'è (resta la didascalia di oggi).
7. **Vuoti**: `TestiTrackRecord.nessunaConEsito` = «Nessuna con questo esito.»; `nessunaPer(nome:)` = «Nessuna
   raccomandazione registrata per \(nome): la prima nasce quando presenti una proposta.» (l'app registra alla
   presentazione, non al salvataggio: vedi `vuotoTesto`, riga 31). Lo stato vuoto di tutto l'archivio
   (`VuotoTrackRecord`) resta quando non c'è nessuna raccomandazione.
8. Token in `Tema.Apple+TrackRecord.swift`: `Card.larghezzaDestra` da 120 a 132 (c'è già, enum `Card`, la colonna
   del risultato: deve contenere «Riproponi»), `Disposizione.vuotoSopra` 44, una `notaStimeSopra` 12 (il
   `notaSopra` che c'è vale 4 ed è d'altro), e quelli del chip se nasce qui.

**Non fare**: non portare `TR` né «64», «71%», «92%», «+3,1% l’anno»; non mostrare in modalità cliente (Studio resta
riservato); non modificare scelte o note già registrate.

### 54.4 Dati, archivio, privacy

Nessun campo nuovo: «Riproponi» usa campi che ci sono (`Posizione.esito`, le note della raccomandazione). La posizione
cambiata si salva nel file del cliente come ogni modifica, ed entra in «Prisma ovunque» come aggiornamento della
posizione (`EntitaOvunque.posizione`, esito compreso): nessuna regola nuova. Privacy: Studio non si mostra in modalità
cliente; la nota sulle stime ricorda che al cliente si spiegano.

### 54.5 Istantanee e prove

- Da aggiornare: «520-studio-track» (chiara e scura: filtro a destra, nota in fondo, «Riproponi» sulla rimandata),
  «524-studio-track-da-misurare», «525-studio-track-negativo».
- Nuove: «1092-uso-track-cliente» (chiara e scura, con un cliente scelto: tessere sue), «1092-uso-track-filtro» (filtro
  «Rimandate»), «1092-uso-track-cliente-vuoto» («Nessuna raccomandazione registrata per …»),
  «1092-uso-track-riproposta» (dopo «Riproponi»: «✓ Tra le proposte»). `RichiestaIstantaneaTrack` (riga 183) prende
  anche il filtro.
- Prove: `--prova-calcoli` (`ProvaCalcoliTrackRecord.swift` e `ProvaCalcoliPresentazioneTrack.swift`): `perCliente`
  (conteggi, somma con una misurata negativa, nessuna misurata → nil), `filtra`; `riproponiRaccomandazione` porta la
  posizione a bozza, toglie `riprendereIl`, chiude l'attività di ripresa, aggiunge la nota, non tocca le scelte, non fa
  nulla su una non rimandata, senza posizione o in sola lettura; dopo, la voce è «in attesa» e ripresentarla non crea
  una seconda raccomandazione.
  `--prova-backup`: la nota aggiunta viaggia con il backup (c'è già la prova delle note del registro, va solo estesa).
  `--prova-fluidita`: cambiare cliente non rifà `MotoreTrackRecord.calcola`.

### 54.6 Decisioni per l'utente e rischi

- **Cosa fa «Riproponi»**: il template dice solo «torna tra le proposte». Proposta: la posizione torna «bozza» in
  Posizioni (i numeri li rifanno i motori), la ripresa programmata si chiude e il registro riceve una nota datata; nel
  track record la voce torna «in attesa» con le cifre della prima presentazione. Alternativa: crea una copia nuova
  della proposta, lasciando la vecchia rimandata: alla nuova presentazione nasce una raccomandazione nuova, con le cifre
  di quel giorno (il track record conta allora due raccomandazioni per la stessa idea).
- **«dati di mercato del periodo»**: nell'app l'alternativa si ricostruisce con i riferimenti di Impostazioni (che
  vengono da BCE/Eurostat solo con Mercato acceso). Proposta: scrivere «riferimenti del periodo», come oggi.
- **Le «in attesa»** (presentate e non ancora decise) non hanno un filtro loro: proposta, compaiono solo in «Tutte» e
  nella tessera «Raccomandazioni a …».
- Rischi: la vista ora dipende anche dal cliente e dal filtro; tenerli nell'uguaglianza di `ElencoTrackRecord` e il
  calcolo per cliente in `ricavato`, mai nel body.

### 54.7 Dimensione

**M.** File: Shell/StudioTrackRecord.swift, Shell/StatoTrackRecord.swift, Shell/StatoSeguito.swift (la ripresa da
chiudere), Motori/PresentazioneTrackRecord.swift,
DesignSystem/Apple/Tema.Apple+TrackRecord.swift (e il chip del tema), Motori/ProvaCalcoliTrackRecord.swift,
Shell/IstantaneeTrackRecord.swift.

---

## 55. Il quiz OCF chiude con un bilancio

### 55.1 Nel template

Righe 4643-4657 (`ocfEs`, `ocfRis`, `OCFD`, `quizHTML` e `montaQuiz` rifatti, `ocfBilancio`), 4728 e 4737.

1. **«Salta» non è «Prossima domanda»**: finché non si risponde il pulsante in basso a destra è **«Salta»** (grande,
   non blu). Appena si sceglie una risposta diventa blu e dice **«Prossima domanda ›»**, o, all'ultima domanda del giro,
   **«Vedi com’è andata ›»**. Saltare segna la domanda come saltata e va avanti.
2. **Il bilancio** (`ocfBilancio`), al posto della domanda, entrando da destra (+40, 0,48 s): etichetta viola **«Il
   ripasso di oggi»**; titolo 30 bold **«Tutte giuste.»** oppure **«<n> giusta/giuste su <N>.»**; sotto (14,5)
   **«Quelle sbagliate o saltate tornano da sole: tra 1, 3 e 7 giorni.»**. Poi l'elenco del giro: per ogni domanda un
   segno (✓ verde, ✕ rosso, – grigio), la domanda in grassetto e la materia sotto, a destra una pillola: **«Fatta»**
   (verde), **«Torna domani»** (rossa), **«Saltata: torna domani»** (neutra). In fondo: **«Ripassa il punto debole»**
   (blu, grande), **«Ricomincia»** (grande) e a destra **«Punto debole: <materia>»**. «Ripassa il punto debole» riparte
   con le domande di quella materia; «Ricomincia» ricomincia il giro.
3. **Si parte da una materia**: le righe delle materie a sinistra diventano toccabili (`.ocfM`: raggio 10, padding 5×6,
   cursore a mano) e la nota diventa **«Le domande vengono dal tuo manuale. Tocca una materia per ripassare quella.»**.
4. **La data dell'esame si imposta davvero**: il pulsante dice **«Esame il <data> · mancano <n> giorni»** (o «Imposta
   la data dell’esame»); nel template sceglie fra tre sessioni scritte a mano (`OCFD`, dimostrative), con «Togli la
   data», e l'avviso «Mancano <n> giorni: <k> domande al giorno per arrivare pronto».

### 55.2 Nell'app oggi

`Sources/Prisma/Shell/StudioEsameOCF.swift` (`EsameOCFStudioVista`, riga 290), motore `MotoreOCF`, archivio
`DatiPrisma.ocf`.

- Il pulsante del piede (riga 781, `piede(aperta:)`) è sempre **«Prossima domanda ›»** in `.applePrimarioGrande` (riga
  791), anche senza risposta. `SessioneEsameOCF.avanti()` (riga 245): **una domanda saltata torna in fondo alla coda di
  oggi** (finché ce n'è più di una).
- A fine coda la vista `finito` (riga 866): «Per oggi il ripasso è finito.», «Le prossime tornano domani: N domande.»,
  «Altre domande nuove ›» o «Hai già visto tutte le domande…» con «Importa domande…». **Non c'è il bilancio** del giro e
  la sessione non ricorda le risposte date (vanno subito nell'archivio con `rispondiOCF`).
- **Le materie toccabili ci sono già** (`RigaMateriaOCF`, riga 511: «Allenati solo su questa materia», filtro «Solo:
  <materia> ✕»); la nota è `TestiEsameOCF.notaManuale` («…il ripasso torna sugli argomenti che sbagli.», riga 37).
- **La data dell'esame c'è già** (`RiquadroDataEsameOCF`, riga 568, con il calendario, «Salva», «Togli la data»;
  testo del pulsante `TestiEsameOCF.esame`, riga 93: «Esame il 18 febbraio 2027 · mancano 107 giorni»).
- La nota del piede dice gli intervalli veri: «Ripasso a intervalli: le sbagliate tornano domani, le giuste tra 3, 7,
  14 e 30 giorni» (`TestiEsameOCF.piede`, riga 114, da `MotoreOCF.intervalli = [1, 3, 7, 14, 30]`,
  MotoreOCF.swift:73: una giusta torna dopo 3 giorni, poi 7, 14, 30).
- Le nuove del giorno: `MotoreOCF.domandeDiOggi` (riga 137) toglie dalla quota solo quelle **risposte** oggi, quindi
  una nuova saltata, rifatta la coda con `avvia`, torna nella coda di oggi; un ripasso scaduto saltato resta scaduto.
- Le pillole di stato: `PillolaEsitoApple` (DesignSystem/Apple/PillolaEsitoApple.swift) prende solo un
  `PresentazioneTrackRecord.Esito` e ne scrive il nome: non può dire «Fatta» o «Torna domani».
- Tastiera: Invio e → vanno avanti (`ScorciatoieEsameOCF`, riga 1119).

### 55.3 Cosa fare

1. **La sessione ricorda il giro.** In `SessioneEsameOCF` (un `ObservableObject` della vista, non `StatoShell`: resta
   così) un `@Published var esiti: [EsitoGiroOCF]` con `struct EsitoGiroOCF: Equatable { let domandaId: String; let
   esito: Tipo }` e `enum Tipo { case giusta, sbagliata, saltata }`, azzerato da `avvia`. `rispondi` (riga ~799) aggiunge
   giusta o sbagliata; `avanti()` senza risposta aggiunge `saltata` e **non rimette più la domanda in coda** (torna
   domani da sé: un ripasso scaduto resta scaduto, una nuova resta fra le nuove). Aggiornare il commento di `avanti()`.
2. **Il pulsante.** In `piede(aperta:)`: senza risposta `TestiEsameOCF.salta` = «Salta» in `.appleGrande` (lo stile
   grande non primario, PulsantiApple.swift:56); con la risposta `prossima` («Prossima
   domanda ›») in `.applePrimarioGrande`, o all'ultima della coda `vediComeEAndata` = «Vedi com’è andata ›». Le
   scorciatoie: Invio e → fanno la stessa cosa del pulsante (saltare con Invio resta possibile: è il pulsante che lo
   dice).
3. **Il bilancio.** La vista `finito` si divide: se `esiti` non è vuoto mostra `BilancioOCFVista` (nuova, nello stesso
   file), altrimenti la vista di oggi (aprire Studio con nulla da ripassare). `BilancioOCFVista`:
   - etichetta `TestiEsameOCF.ripassoDiOggi` = «Il ripasso di oggi» (colore viola dell'OCF);
   - titolo `bilancio(giuste:di:)` = «Tutte giuste.» / «1 giusta su 6.» / «4 giuste su 6.»; se sono tutte saltate
     «Nessuna risposta, per ora.»;
   - riga `tornano` con gli intervalli veri del motore, costruita da `MotoreOCF.intervalli` come `piede` (mai scritta
     a mano): «Le sbagliate tornano domani, le saltate restano da fare; le giuste tornano tra 3, 7, 14 e 30 giorni.»
     (il template scrive «tra 1, 3 e 7 giorni», che sono i primi tre gradini della scala ma non dicono che la saltata
     non ha un intervallo);
   - l'elenco (`LazyVStack` dentro lo `ScrollView` della card se lungo): segno ✓ ✕ – nei colori del tema (verde, rosso,
     `inchiostro3`), testo della domanda (due righe al massimo) e materia, a destra una pillola di stato del tema:
     «Fatta» (ok), «Torna domani» (errore), «Saltata: torna domani» (neutra). `PillolaEsitoApple` non basta (prende
     solo l'esito del track record): una `PillolaStatoApple(testo:tono:)` in `DesignSystem/Apple/` con `enum
     TonoPillola { case ok, errore, avviso, neutro }` e gli stessi colori di `Tema.Apple.Studio.Track` (spostati in
     un posto comune, per esempio `Tema.Apple.Pillola`), e `PillolaEsitoApple` diventa un involucro che la usa (la
     56 la riusa per «la più efficace»). Se il gruppo 01 o 02 ha già una pillola di stato comune, si usa quella;
   - in fondo (stili `.applePrimarioGrande` e `.appleGrande`, PulsantiApple.swift:56-58): `ripassaDebole` = «Ripassa
     il punto debole» (`.applePrimarioGrande`, imposta `sessione.materia` al punto
     debole di `MotoreOCF.preparazione` e chiama `avvia`), `ricomincia` = «Ricomincia» (rifà la coda di oggi con
     `avvia`: dentro tornano le saltate, perché le nuove non risposte restano nella quota del giorno e i ripassi
     saltati restano scaduti, mentre le risposte di oggi non ci sono più; se è vuota si vede lo stato di oggi «Per
     oggi il ripasso è finito.» con «Altre domande nuove ›»), e a destra
     `puntoDeboleBreve(nome)` = «Punto debole: \(materia minuscola)». Senza punto debole (poche risposte) il primo
     pulsante non c'è.
   - Entra come la domanda nuova (da destra, con «Riduci movimento» dissolvenza, nelle istantanee fermo).
4. **La nota delle materie**: `notaManuale` = «Le domande vengono dal tuo manuale. Tocca una materia per ripassare
   quella.»; la riga della materia mostra il cursore a mano al passaggio (macOS) e un fondo `materiaScelta` tenue al
   passaggio (token `Preparazione.fondoSopra`).
5. **La data**: resta il riquadro di oggi (giorno qualsiasi, non tre sessioni scritte a mano). Dopo «Salva» un avviso
   `TestiEsameOCF.ritmo(giorni:domande:)` = «Mancano \(g) giorni: \(k) domande al giorno per arrivare pronto», con k
   calcolato da `MotoreOCF` (funzione pura nuova `domandeAlGiorno(archivio:, giorni:)`: domande mai viste più ripassi
   aperti, divisi per i giorni, almeno 1). Se le domande sono quelle di esempio l'avviso non c'è.
6. Token in `Tema.Apple+OCF.swift`: `Bilancio` (titolo 30 bold tracking −0,6, testo 14,5, riga 11 sopra e sotto con il
   filo `separatore`, segno largo 22, spazio 12, piede in basso a 24 come il piede della domanda).

**Non fare**: non portare `OCFD` (le date delle sessioni d'esame non si scrivono a mano: le sceglie l'utente), né
`QUIZ` a tre domande; non salvare il bilancio nell'archivio (le risposte ci vanno già una per una).

### 55.4 Dati, archivio, privacy

Nessun campo nuovo: gli esiti del giro vivono nella sessione (memoria della vista), la data dell'esame c'è già
(`ArchivioOCF.dataEsame`). Le domande saltate non scrivono nulla. Nessun tema di privacy (dati del consulente, mai in
modalità cliente).

### 55.5 Istantanee e prove

- Da aggiornare: «530-studio-ocf» (chiara e scura: «Salta» sul piede, nota nuova), «531-studio-ocf-sbagliata» e
  «532-studio-ocf-giusta» («Prossima domanda ›» blu), «536-studio-ocf-ripasso-finito» (resta lo stato senza giro).
- Nuove: «1093-uso-ocf-bilancio» (chiara e scura: giro con giuste, sbagliate e saltate), «1093-uso-ocf-tutte-giuste»,
  «1093-uso-ocf-ultima-domanda» («Vedi com’è andata ›»). `RichiestaIstantaneaOCF` (riga ~263) prende anche gli esiti
  del giro, senza scrivere nell'archivio.
- Prove: `--prova-calcoli` (`ProvaCalcoliOCF.swift`): `domandeAlGiorno` (zero giorni, esame passato, nessuna domanda);
  una prova della sessione: saltare non rimette in coda, non scrive risposte, `esiti` si azzera con `avvia`, «Ripassa il
  punto debole» filtra la materia.

### 55.6 Decisioni per l'utente e rischi

- **Quando tornano le domande**: il template scrive «tra 1, 3 e 7 giorni»; Prisma fa tornare le sbagliate domani e
  le giuste tra 3, 7, 14 e 30 giorni (`MotoreOCF.intervalli`). Proposta: il bilancio dice la regola vera del motore,
  ricavata dalla costante come la nota del piede.
- **La saltata non torna più nel giro di oggi** (oggi torna in fondo alla coda): proposta, come il template.
- **La data dell'esame**: proposta, il calendario di oggi (l'utente sceglie il giorno), non un elenco di sessioni.
- Rischi: nessuno particolare; l'elenco del bilancio è al più la coda di un giorno.

### 55.7 Dimensione

**M.** File: Shell/StudioEsameOCF.swift, Motori/MotoreOCF.swift, Motori/ProvaCalcoliOCF.swift,
DesignSystem/Apple/Tema.Apple+OCF.swift, Shell/IstantaneeEsameOCF.swift, DesignSystem/Apple/PillolaEsitoApple.swift
(la pillola con un testo qualsiasi, se non c'è già).

---

## 56. La palestra si fa sul cliente che vedrai

### 56.1 Nel template

Righe 4659-4694 (`PAL_CHI`, `PAL_ULT`, `paCli`, `paDiff`, `objDi`, `palestraHTML`, `paBolla`, `paScrive`, `paTurno`,
`paRisp`, `paFine`, `montaPalestra` rifatti).

1. **Vera recita il cliente scelto in alto** (prima era sempre Giulia): `paCli` segue `cliSel`. Nella colonna di
   sinistra: avatar 56, nome, «Vera nei panni di <Nome>» e a destra il pulsante **«Cambia»** (5×12), che apre il menu
   dei clienti; con un cliente scelto nella barra, sceglierne un altro **cambia il cliente di tutta Prisma**
   (`scegliCli`), con «Tutti i clienti» cambia solo quello della palestra. La scheda «Chi è · I suoi timori ·
   L’obiettivo» è quella del cliente; le bolle dicono «<Nome> · recitata/recitato da Vera».
2. **La difficoltà cambia davvero qualcosa**: sotto il segmentato «Facile · Realistica · Difficile» una riga (8 sopra,
   interlinea 1,4) dice cosa cambia: **«Facile: la risposta più efficace ha un segno.»**, **«Realistica: tre
   obiezioni, senza aiuti.»**, **«Difficile: se la risposta è debole, insiste.»**. In Facile la risposta migliore porta
   la pillola verde **«la più efficace»**; in Difficile, dopo una risposta non ottima, il cliente aggiunge **«Però non
   mi ha ancora convinto del tutto. Me lo fa vedere con i miei numeri?»** prima dell'obiezione dopo. Cambiare difficoltà
   rifà la palestra.
3. **Com'è andata l'ultima volta**: sotto la barra dell'avanzamento una tessera `#paUlt`: **«L’ultima volta con
   <Nome>»** e in grassetto **«<punteggio>% · <data>»** (per esempio «78% · 28 ottobre»), oppure **«Con <Nome>»** e
   **«Primo allenamento»**. A fine allenamento si aggiorna subito con «<punteggio>% · oggi».
4. Il resoconto finale usa il nome del cliente («<Nome> ha detto: …» o «<Nome> resta in dubbio.») e i tre strumenti
   aprono le esperienze per quel cliente (la linea della vita apre il suo dossier).

Le obiezioni e le persone con cui ne parla (`objDi`, `PAL_CHI`) sono dimostrative. Anche la correzione segnata nel
commento del template (righe 2863 e 4683: «le reazioni alle risposte A e B erano scambiate») riguarda solo le reazioni scritte
a mano del template: nell'app le repliche le scrive Qwen, non c'è niente da correggere.

### 56.2 Nell'app oggi

`Sources/Prisma/Shell/StudioPalestra.swift` (`PalestraStudioVista`, riga 92), stato in `StatoPalestra.swift`, recita
in `Vera/PalestraVera.swift`, token `Tema.Apple+Palestra.swift`.

- **Il cliente segue già quello attivo**: `StatoPalestra.clienteScelto` (StatoPalestra.swift:56) usa `clienteId` se
  scelto dal menu, altrimenti `stato.clienteAttivo`. Il menu `SelettorePalestra` (riga 282) si chiama **«Allenati
  con…»** e ha tutti i clienti più «Profilo inventato…»; sceglie solo per la palestra (`palestra.scegli(cliente:)`),
  bloccato durante l'allenamento. Senza cliente: «Scegli un cliente per allenarti».
- La scheda della recita viene da `fonteVera` in `ricavato("studio.palestra.scheda|<id>")` (riga 124): le obiezioni
  le scrive Qwen sul profilo vero del cliente (non sono scritte a mano).
- **La difficoltà** (riga 166): `DifficoltaPalestra` (PalestraVera.swift:21) cambia la convinzione iniziale, il passo
  massimo e la regola per Qwen (`regola`, riga 52: in Difficile «torni sui tuoi dubbi, chiedi numeri»). È bloccata
  durante l'allenamento (`TestiPalestra.bloccata`). **Non c'è la riga che spiega** la difficoltà, **le suggerite non
  hanno un segno** (sono tre testi senza voto, `Turno.suggerite`) e la «insistenza» dipende solo da Qwen.
- **Il registro degli allenamenti c'è già**: `Impostazioni.palestra.allenamenti: [EsitoPalestra]`
  (Dati/ImpostazioniPalestra.swift:41: data, `clienteId`, difficoltà, punteggio; al più `PalestraVera.massimoEsiti`),
  scritto a fine allenamento (`StatoPalestra.swift:243`, `registraEsitoPalestra`). **Non si mostra da nessuna parte**
  nella palestra.
- Fine: `FinePalestra` (riga 741) con `PalestraVera.fraseFinale`, gli strumenti e «↻ Rifai l’allenamento» (il
  resoconto con il nome del cliente e gli strumenti per quel cliente ci sono già).
- La bolla del cliente dice sempre «<Nome> · recitata da Vera» (`TestiPalestra.recitata`, riga 64), anche per un uomo;
  il template scrive «recitato» per i clienti maschi. Il genere si ricava già altrove con `MotoreAree360.femminile(_:)`
  (MotoreAree360.swift:320, `Bool?`).

### 56.3 Cosa fare

1. **Il cliente della barra.** Con la miglioria 2: `clienteScelto` legge prima il cliente della barra (se non è
   «Tutti i clienti»), poi `clienteId` (scelto nella palestra quando la barra è su «Tutti i clienti»). Al cambio del
   cliente della barra, se l'allenamento non è in corso, `palestra.azzera()` (come oggi `scegli`).
2. **«Cambia».** Il menu `SelettorePalestra` prende l'etichetta `TestiPalestra.cambia` = «Cambia» con lo stile del
   pulsante piccolo del tema (`.apple`, padding token `selettorePadding` 5×12) al posto del testo blu «Allenati con…»
   (che resta come aiuto). Le voci: i clienti (ordinati come la rubrica, dalla cache `ricavato("rubrica-ordinata")`,
   che c'è già in DossierApple.swift:138) e, dopo un divisore, «Profilo inventato…». Scegliere un cliente: se la barra ha un cliente,
   `stato.scegliCliente(id)` (cambia tutta Prisma, come il template); se è su «Tutti i clienti», `palestra.scegli(cliente:)`.
   Senza la miglioria 2 resta `palestra.scegli(cliente:)`. Il menu resta **bloccato durante l'allenamento** come oggi
   (`.disabled(palestra.inCorso)`): nel template «Cambia» e il cambio di difficoltà rifanno la palestra in qualunque
   momento, ma lì l'allenamento parte da solo all'apertura; nell'app si sceglie prima e poi si comincia (vedi 56.6).
3. **La riga della difficoltà**: sotto il segmentato `TestiPalestra.spiega(_ d:)` = «Facile: la risposta più efficace
   ha un segno.» / «Realistica: tre obiezioni, senza aiuti.» / «Difficile: se la risposta è debole, insiste.»
   (carattere della nota, `P.coloreNota`, token `sopraSpiega` 8, interlinea 1,4). Il segmentato della difficoltà
   resta bloccato durante l'allenamento con l'aiuto `TestiPalestra.bloccata` di oggi.
4. **Il segno in Facile.** Nello schema JSON di Qwen (PalestraVera.swift, intorno alla riga 219) un campo facoltativo
   `migliore` (intero 0-2: l'indice della suggerita più efficace), chiesto solo in Facile (nella `regola` di Facile:
   «indica in "migliore" la risposta suggerita più efficace»). Il codice lo accetta solo se è un indice valido; in
   `Turno` un `var migliore: Int?`. `OpzionePalestra` (riga 683) in Facile mostra a destra la pillola verde
   `TestiPalestra.piuEfficace` = «la più efficace» (la `PillolaStatoApple` della 55, tono ok). Se Qwen non lo dà,
   nessun segno (mai un segno inventato dal codice). Il campo va in **tre posti che devono coincidere**: lo schema
   `Vera/Schemi/palestra.json`, `PalestraVera.schemaInterno` (PalestraVera.swift:212; una prova controlla che siano
   uguali) e il testo di ripiego in `PalestraVera` (riga 199); poi le istruzioni `Vera/Istruzioni/palestra.md` e, se
   gli esempi lo devono mostrare, `Vera/Esempi/palestra.json` (costruisci-mac.sh copia le cartelle Istruzioni, Schemi
   ed Esempi nell'app).
5. **L'insistenza in Difficile.** Nella `regola` di Difficile: «se il giudizio non è "ottima", la replica torna sullo
   stesso dubbio e chiede di vederlo con i suoi numeri, prima della prossima obiezione». Il codice non scrive la frase
   del template al posto di Qwen (le parole del cliente le dice Vera); la prova con il Qwen finto controlla che in
   Difficile la regola sia nel messaggio.
6. **L'ultima volta.** In `ColonnaPalestra`, sotto la barra dell'avanzamento, una tessera (`P.tile`) con:
   - `TestiPalestra.ultimaVolta(nome)` = «L’ultima volta con \(nome breve)» e in grassetto `esito(punteggio, data)` =
     «78% · 28 ottobre» («oggi» se è di oggi, «ieri» se di ieri; l'anno solo se non è quest'anno);
   - oppure `conCliente(nome)` = «Con \(nome breve)» e «Primo allenamento».
   Il dato: l'ultimo `EsitoPalestra` con quel `clienteId` (funzione pura `PalestraVera.ultimo(_ esiti:, cliente:)`),
   letto da `stato.dati.impostazioni.palestra.allenamenti` (al più `massimoEsiti` voci: si legge nel body senza costo,
   ma la vista si iscrive solo a quelle impostazioni). Con il profilo inventato la tessera non c'è. Dopo la fine si
   aggiorna da sé (l'esito è già registrato).
7. **«recitata» o «recitato».** `TestiPalestra.recitata(_:)` prende il genere: «recitato da Vera» quando
   `MotoreAree360.femminile(cliente) == false`, «recitata da Vera» altrimenti (anche con il genere sconosciuto e con
   il profilo inventato, come oggi). La `SchedaRecita` porta il valore, calcolato una volta con la scheda.
8. Token in `Tema.Apple+Palestra.swift`: `sopraSpiega` 8, `sopraUltima` 16, `selettorePadding` (5, 12),
   `pillolaMigliore` (dalla pillola di stato del tema).

**Non fare**: non portare `objDi`, `PAL_CHI`, `PAL_ULT`, né le obiezioni scritte a mano; la palestra non si apre in
modalità cliente; la conversazione non si salva (resta così).

### 56.4 Dati, archivio, privacy

Nessun campo nuovo nell'archivio: «l'ultima volta» legge il registro che c'è già (`Impostazioni.palestra.allenamenti`,
già nei backup e già descritto in CLAUDE.md: data, cliente, difficoltà, punteggio, mai le conversazioni). Il campo
`migliore` è solo nella risposta di Qwen in memoria. Qwen resta locale (127.0.0.1). Privacy: invariata; scegliere un
cliente dalla palestra con la barra su un cliente cambia il cliente di tutta Prisma (vedi 56.6).

### 56.5 Istantanee e prove

- Da aggiornare: «720-studio-palestra» (chiara e scura: «Cambia», la riga della difficoltà, la tessera «L’ultima volta
  con …»), «721-studio-palestra-turno» (in Facile con «la più efficace» su una suggerita), «722-studio-palestra-fine»,
  «726-studio-palestra-scegli-cliente».
- Nuove: «1094-uso-palestra-primo-allenamento» («Con <Nome> · Primo allenamento»), «1094-uso-palestra-difficile» (la
  riga di Difficile e una replica che insiste, conversazione scritta nella scena come oggi).
- Prove: `--prova-vera` (`ProvaPalestraVera.swift`): `migliore` valido, fuori intervallo (scartato), assente; lo
  schema della cartella e `schemaInterno` ancora uguali con il campo nuovo; la regola di Difficile nel messaggio;
  «recitato» per un cliente maschio, «recitata» con il genere sconosciuto; `PalestraVera.ultimo` (nessun esito, più esiti dello stesso cliente, esiti di altri);
  il titolo «Esame OCF» della 52. `--prova-backup` (`ProvaBackupPalestra.swift`) resta verde (nessun campo nuovo).

### 56.6 Decisioni per l'utente e rischi

- **«Cambia» con un cliente nella barra cambia tutta Prisma** (come il template). Proposta: sì, coerente con «un solo
  posto per il cliente»; con «Tutti i clienti» cambia solo la palestra.
- **Il segno in Facile lo dà Qwen**, non il codice (il codice non sa giudicare una frase). Proposta: se Qwen non lo dà,
  nessun segno.
- **La frase dell'insistenza**: proposta, la scrive Vera seguendo la regola, non una frase fissa del codice.
- **Cambiare cliente o difficoltà durante l'allenamento**: nel template rifà la palestra; proposta, resta bloccato come
  oggi (si cambia prima di cominciare o dopo «↻ Rifai l’allenamento»), perché nell'app l'allenamento ha un inizio
  esplicito e una conversazione con Qwen che si perderebbe con un clic.
- Rischi: il campo nuovo nello schema JSON rende la risposta di Qwen un po' più lunga (qwen3.5:4b, 8 GB): tenerlo
  facoltativo e solo in Facile.

### 56.7 Dimensione

**M.** File: Shell/StudioPalestra.swift, Shell/StatoPalestra.swift, Vera/PalestraVera.swift, Vera/Istruzioni/palestra.md, Vera/Schemi/palestra.json,
Vera/ProvaPalestraVera.swift, DesignSystem/Apple/Tema.Apple+Palestra.swift, Shell/IstantaneePalestra.swift.

---

## 57. Le spese, mese per mese

### 57.1 Nel template

Righe 4696-4719 (`SPM`, `KMM`, `spM`, `euc`, `speseHTML` e `montaSpese` rifatti) e CSS 741-745. Tre card come prima
(1,1 : 1 : 1), ma:

1. **I chilometri**: il titolo diventa **«I chilometri»** e a destra c'è la scelta del mese: **«‹  Ottobre 2026  ›»**
   (frecce `.spFr` 3×10, 15; il mese 14 bold, largo almeno 112, centrato). Le frecce si spengono (opacità 0,3) dove non
   ci sono dati. Sotto il numero grande: «22 visite · 14 clienti · contati dal Territorio, da soli»; i giri del mese;
   «+ altre N visite». **Le colonne «Chilometri per mese»** sono i mesi dell'anno (G F M A M G L A S O N), fisse in
   basso: quella del mese scelto è nel colore d'accento e la sua iniziale è accento e grassetto; **toccare una colonna
   sceglie quel mese** (al passaggio la colonna si scurisce, `brightness(.92)`).
2. **Le spese**: titolo **«Le spese di <mese>»**, a destra «◎ Inquadra lo scontrino»; il totale con i centesimi
   («384,80 €»); sotto **«<n> spese · <k> senza scontrino»** (in arancio grassetto) oppure **«<n> spese · tutte con lo
   scontrino»**. Nelle righe la miniatura di una spesa **senza scontrino** è vuota con il **bordo arancio tratteggiato**
   (1,5) e la data dice **«<data> · manca lo scontrino»**.
3. **Le scadenze**: le righe hanno la freccia «›» a destra e si toccano: **portano all'Agenda** sul giorno (vista mese).
   (Nel template le due scadenze di dicembre, fuori dal mese mostrato dell'Agenda finta, danno solo l'avviso «È già in
   Agenda, il 31 dicembre»: il template dà per scontato che le scadenze dello Studio stiano nell'Agenda, vedi 57.6.)
   L'anello delle ore di aggiornamento sparisce (resta la riga «Aggiornamento professionale · 22 ore su 30»).
4. **Il pacchetto dice cosa c'è dentro prima di prepararlo**: in fondo alla terza card una tessera `#spDentro`
   **«Nel pacchetto di <mese>»** con **«<km> km in <visite> visite · <n> spese (<totale>) · <p> parcelle emesse»** e,
   se serve, in arancio **«Una spesa è senza scontrino: parte lo stesso, segnata.»** (o «<k> spese sono senza
   scontrino…»). Il pulsante dice **«Prepara il pacchetto di <mese>»**; finito: «✓ <Mese>-2026.zip» con «chilometri,
   spese e scontrini, in CSV e PDF: lo mandi tu al commercialista».

Cambiare mese ridisegna tutte e tre le card per quel mese.

### 57.2 Nell'app oggi

`Sources/Prisma/Shell/StudioSpese.swift` (`SpeseStudioVista`, riga 116), stato `StatoSpese.swift`
(`studioSpese.meseScelto`, `mese(impostazioni:)`, `sposta`, `scegli`, righe 71-87), motori `MotoreChilometri` e
`MotoreSpese`, pacchetto `Motori/PacchettoCommercialista.swift`, token `Tema.Apple+Spese.swift`.

- **Il mese si sceglie già**: frecce ‹ › attorno al titolo «I chilometri di <mese>» (`CardKmSpese`, righe 283-287,
  `freccia`, riga 315; **mai spente**, si può andare nei mesi futuri), a destra «dalle visite dell’agenda»; le colonne
  si toccano (`grafico`, riga 375: `onTapGesture { stato.studioSpese.scegli(m.inizio) }`). Ma la serie
  (`MotoreChilometri.riepilogo`, MotoreChilometri.swift:219) è **dei 10 mesi che finiscono col mese scelto**: scegliendo
  un mese le colonne scorrono, e quella accesa è sempre l'ultima (riga 384). Il pacchetto pronto si toglie cambiando
  mese (`scegli`).
- **Le spese** (`CardSpeseStudio`, riga 476): titolo «Le spese», totale, sotto `sottoTotale` («a ottobre · 2 scontrini
  su 3», riga 80); la miniatura senza scontrino (`MiniaturaScontrino`, riga 636) è vuota con il bordo normale; la data
  non dice che manca.
- **Le scadenze** (`CardScadenzeSpese`, riga 658): righe `RigaScadenzaSpese` (riga 798) che **aprono il foglio della
  scadenza** e hanno il cerchio per segnarla fatta; «Tutte le scadenze (N)», «+ Aggiungi scadenza»; l'anello delle ore
  (apre i corsi); in fondo «Prepara il pacchetto per il commercialista» con la barra e la tessera del file
  (`TilePacchettoSpese`, riga 851). **Le scadenze dello Studio non compaiono nell'Agenda.**
- **Il pacchetto** (`preparaPacchettoSpese`, StatoSpese.swift:245): `NSSavePanel`, zip con CSV dei km e delle spese
  (colonna «Scontrino» vuota se manca), PDF e scontrini. **Non contiene le parcelle.** Nessuna tessera dice prima cosa
  ci sarà.

### 57.3 Cosa fare

1. **La serie fissa.** In `MotoreChilometri.riepilogo` un parametro `fineSerie: Date` (di base il mese scelto, come
   oggi): la vista passa il **mese di calendario di oggi** (`MotoreChilometri.inizioMese(Date())`, non
   `meseMostrato`, che fino al giorno di cambio è il mese prima) se il mese scelto è dentro gli ultimi `mesiSerie`
   mesi, altrimenti il mese scelto. Il template mostra i mesi dell'anno da gennaio (11 colonne a novembre); l'app
   tiene le sue 10 colonne (`mesiSerie`, «come il template» di «Luce»), che a gennaio non si riducono a una sola. Così le colonne restano ferme e si accende quella del mese scelto
   (`i == indiceScelto`, colore `t.mese`, iniziale in accento e grassetto: token `Colonne.etichettaScelta` e
   `coloreEtichettaScelta`). Al passaggio (macOS) la colonna si scurisce (`.brightness(Colonne.ombraSopra)`, −0,04) e
   mostra la mano.
2. **Le frecce a destra.** Il titolo diventa `TestiSpese.titoloKmBreve` = «I chilometri»; a destra un gruppo
   `‹ <Mese anno> ›` (mese con l'iniziale maiuscola e l'anno, 14 bold, larghezza minima token `Km.larghezzaMese` 112).
   **›** si spegne (opacità `Km.frecciaSpenta` 0,3, `disabled`) sul **mese di calendario di oggi** (niente mesi
   futuri; il mese in corso invece sì, anche nei primi giorni quando il mese mostrato all'apertura è ancora il
   precedente: nel template si apre su ottobre e si arriva a novembre); anche `StatoSpese.sposta` e il tocco di una
   colonna non vanno oltre (un mese futuro scelto in altro modo si riporta al mese di oggi); **‹**
   resta attiva (il commercialista può chiedere un mese vecchio). La fonte va sotto il numero:
   `visiteClienti(...)` + « · contati dalle visite dell’agenda, da soli» (l'app conta dalle visite dell'Agenda, non dal
   Territorio: vedi 57.6).
3. **Le spese.** Titolo `TestiSpese.titoloSpese(mese)` = «Le spese di \(mese)»; totale con i centesimi
   (`Formati.euroDecimali`, come le righe); `sottoTotale` diventa `conteggio(spese:)` = «3 spese · 1 senza scontrino»
   (la parte «senza scontrino» in `arancioTesto` grassetto, il token della miglioria 7; finché non c'è,
   `Tema.Apple.Studio.Spese.Card.coloreAvviso`) o «3 spese · tutte con lo scontrino» («1 spesa · …» al singolare).
   `MiniaturaScontrino(conScontrino: false)` (usata anche nel foglio delle spese, FogliSpese.swift:746: cambia anche
   lì, ed è giusto): nessun fondo, bordo tratteggiato arancio (`StrokeStyle(lineWidth:
   Scontrino.bordoMancante 1,5, dash: Scontrino.trattino)`); `RigaSpesaStudio` aggiunge « · manca lo scontrino» alla
   data.
4. **Le scadenze portano all'Agenda.** Il tocco sulla riga chiama `stato.apriAgendaGiorno(s.data)` con la vista mese
   (`vistaAgenda = .mese`, o la vista mese della miglioria 50); a destra la freccia `chevron.right` (token
   `Scadenze.freccia`). La modifica della scadenza resta raggiungibile: menu contestuale «Modifica…» sulla riga e il
   foglio «Tutte le scadenze (N)» (che apre già il foglio di ogni scadenza). Il cerchio «fatta» resta. Perché l'Agenda
   le mostri, vedi 57.6.
5. **L'anello delle ore** si toglie dalla card (il template lo toglie per far posto alla tessera del pacchetto): la riga
   della scadenza «Aggiornamento professionale» dice già «22 ore su 30» (`riga(_:)`, riga ~707), e sotto le scadenze un
   collegamento `CollegamentoSpese(testo: TestiSpese.corsi)` = «I tuoi corsi e gli attestati ›» apre i corsi. Se le ore
   richieste non sono impostate resta «Imposta le ore richieste per l’anno».
6. **Cosa c'è nel pacchetto.** Prima del pulsante una tessera `DentroPacchettoSpese` (`P.tile` piatta):
   `TestiSpese.nelPacchetto(mese)` = «Nel pacchetto di \(mese)» (nota) e la riga `contenutoPacchetto(km:visite:spese:
   totale:parcelle:)` = «412 km in 22 visite · 5 spese (358,80 €) · 3 parcelle emesse» (le parti a zero si dicono:
   «nessuna spesa», «nessuna parcella emessa»; se i km non sono completi «almeno 412 km»); poi, se ci sono spese senza
   scontrino, in arancio `senzaScontrino(k)` = «Una spesa è senza scontrino: parte lo stesso, segnata.» / «\(k) spese
   sono senza scontrino: partono lo stesso, segnate.». Le cifre vengono da ciò che la vista ha già calcolato (riepilogo
   km e spese del mese) e dalle parcelle emesse nel mese (vedi punto 7). Il pulsante diventa `pacchettoDi(mese)` =
   «Prepara il pacchetto di \(mese)». Il file pronto c'è già (`TilePacchettoSpese`, riga 851, con il nome
   «Ottobre-2026.zip» dato da `NSSavePanel`); alla sua descrizione (`PacchettoCommercialista.descrizione`, oggi
   «chilometri, spese e 6 scontrini, in CSV e PDF», con il numero vero) si aggiunge «: lo mandi tu al
   commercialista» senza perdere il numero degli scontrini (e con le parcelle, se approvate, «chilometri, spese,
   parcelle e 6 scontrini…»).
7. **Segnata davvero, e le parcelle.** In `PacchettoCommercialista.csvSpese` la colonna «Scontrino» per le spese senza
   scontrino dice «manca» (oggi è vuota), così «segnata» è vero. Le parcelle: vedi 57.6; con la proposta, un
   `csvParcelle` (numero, data di emissione, imponibile, totale, stato; il cliente solo con «nomi nel pacchetto»
   acceso, `imp.nomiNelPacchetto`) delle parcelle **emesse nel mese** (`MotoreParcelle`, stato diverso da bozza e
   annullata), e il conteggio della tessera lo legge dallo stesso elenco.
8. Token in `Tema.Apple+Spese.swift`: `Km.larghezzaMese` 112, `Km.frecciaSpenta` 0,3, `Colonne.ombraSopra` −0,04,
   `Colonne.etichettaScelta` / `coloreEtichettaScelta`, `Scontrino.bordoMancante` 1,5, `Scontrino.trattino` [3, 2],
   `Scontrino.coloreMancante` (arancio), `Scadenze.freccia`, `Pacchetto.dentroSopra`.

**Non fare**: non portare `SPM` e `KMM` (settembre, ottobre e novembre scritti a mano), né l'avviso «Nel template sono
pronti settembre, ottobre e novembre», né la spesa finta aggiunta da «Inquadra lo scontrino» (resta il foglio vero).
Il pacchetto non si spedisce: resta lo zip salvato dove sceglie l'utente.

### 57.4 Dati, archivio, privacy

Nessun campo nuovo: mese scelto in memoria (`studioSpese.meseScelto`), dati da spese, scadenze, appuntamenti e
parcelle che ci sono. Studio › Spese resta solo sul Mac e fuori da «Prisma ovunque» (CLAUDE.md). Privacy del pacchetto:
le parcelle nel CSV (se l'utente approva, 57.6) portano nomi di clienti solo con «nomi nel pacchetto» acceso, come oggi
i km e le spese; lo zip resta locale e lo consegna il consulente (nessun invio). Prisma non manda nulla al
commercialista.

### 57.5 Istantanee e prove

- Da aggiornare: «780-studio-spese» (chiara e scura: «I chilometri» con il mese a destra, colonne ferme con quella
  scelta accesa, «Le spese di …», miniatura tratteggiata, scadenze con «›», tessera «Nel pacchetto di …»),
  «781-studio-spese-vuoto», «782-studio-spese-km-mancanti» («almeno … km» nella tessera), «785-studio-spese-pacchetto»,
  «788-studio-spese-stretta» (in colonna: la tessera non deve tagliarsi).
- Nuove: «1095-uso-spese-mese-prima» (chiara e scura: mese scelto a metà serie, freccia › attiva),
  «1095-uso-spese-mese-di-oggi» (› spenta), «1095-uso-spese-senza-scontrino» (avviso arancio nella tessera).
- Prove: `--prova-calcoli` (`ProvaCalcoliSpese.swift`): la serie con `fineSerie` (mese scelto dentro e fuori dagli
  ultimi 10), il conteggio dei km nel mese scelto invariato; il limite della freccia › sul mese di calendario di oggi
  anche prima del giorno di cambio (mese mostrato = mese prima, mese di oggi raggiungibile, mese dopo no); `csvSpese` con «manca»; `csvParcelle` (bozze e annullate
  fuori, cliente solo con i nomi accesi, campi con `=+-@` protetti da `campo`). `--prova-backup`
  (`ProvaBackupSpese.swift`): invariata (nessun campo nuovo); controllare che Spese resti fuori da «Prisma ovunque».

### 57.6 Decisioni per l'utente e rischi

- **Le parcelle nel pacchetto**: il template le conta («3 parcelle emesse») ma oggi lo zip non le contiene. Proposta:
  aggiungere `parcelle.csv` con le parcelle emesse nel mese (senza nomi dei clienti se «nomi nel pacchetto» è spento).
  Alternativa: togliere le parcelle dalla tessera.
- **Le scadenze nell'Agenda**: il template porta all'Agenda dove la scadenza «è già». Oggi l'Agenda non mostra le
  scadenze dello Studio. Proposta: mostrarle nella vista mese dell'Agenda come le scadenze delle posizioni (punto
  arancio, solo sul Mac, mai in modalità cliente), da coordinare con la 50 (gruppo 08) e con la 3 (gruppo 01: le
  scadenze dello Studio come voci del «Da fare»). Senza questa scelta il tocco apre l'Agenda sul giorno, vuoto.
- **L'anello delle ore**: proposta, si toglie come nel template; i corsi restano a un clic.
- **«contati dal Territorio»**: l'app conta i km dalle visite dell'Agenda e dai km per cliente; proposta, «contati
  dalle visite dell’agenda, da soli».
- **I mesi futuri**: proposta, la freccia › si ferma al mese di calendario di oggi (non al mese mostrato
  all'apertura, che nei primi giorni è il precedente); la ‹ non ha limite. Oggi le frecce non hanno limiti.
- Rischi: `MotoreChilometri.riepilogo` calcola i giri di 10 mesi nel body (oggi lo fa già, il commento lo dice leggero);
  con la serie ferma il calcolo resta lo stesso, e la tessera del pacchetto non aggiunge motori (usa lo stesso
  riepilogo e le spese del mese; il conteggio delle parcelle del mese è un filtro su `dati.parcelle`, piccolo). Se va
  portato in `stato.ricavato`, la chiave deve contenere il mese scelto, la fine della serie **e** ciò che
  `stessiCalcoli` esclude dalla versione dei calcoli: `impostazioni.studio.spese` (DatiVivi.swift:407) e
  `speseStudio` con le visite tolte (DerivatiDati.swift:624), oltre a `kmClienti` se non vi rientra; altrimenti una
  correzione dei km non ridisegnerebbe la card.

### 57.7 Dimensione

**M.** File: Shell/StudioSpese.swift, Shell/StatoSpese.swift, Motori/MotoreChilometri.swift,
Motori/PacchettoCommercialista.swift, Motori/ProvaCalcoliSpese.swift, DesignSystem/Apple/Tema.Apple+Spese.swift,
Shell/IstantaneeSpese.swift (e, con la decisione sulle scadenze, la vista mese dell'Agenda).
