# Gruppo 08 — Analisi 360, Clienti, Messaggi, Agenda, Territorio: le viste interne (migliorie 45-51)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html (stesse righe). Il codice del gruppo sta alle righe 4442-4615 («SETTIMO GIRO ·
Analisi 360, Clienti, Messaggi, Agenda, Territorio (45–51)»), con il pannello `MIG8` alle righe 4608-4615. Per tutto ciò
che il gruppo non cambia valgono Design/template-luce.html e la sua specifica Design/template-luce-specifica.md.

Il gruppo non aggiunge funzioni: ogni vista interna finisce con **un passo** (aprire l'area giusta, fare la cosa giusta
con un potenziale, ringraziare chi ha presentato, preparare i messaggi, aprire il giorno, preparare la tappa) e dice in
chiaro **com'è oggi e cosa cambia**. Grafica, vetro, acqua, logo e colori dei canali restano come sono.

## Ordine consigliato

1. **50 · Il mese a tutta larghezza.** È la più indipendente (solo Agenda) e conviene farla subito dopo la **18** del
   gruppo 03 («La settimana si vede tutta»), che riordina il selettore in «Giorno | Settimana | Mese» e lascia «Mese»
   com'è proprio in attesa di questa miglioria. Il filtro per cliente usa la **2** del gruppo 01 («Un solo posto per il
   cliente»); finché non c'è, segue `stato.filtroClienteAgenda` come oggi.
2. **45 · Il simulatore mostra prima e dopo.** Solo Analisi 360. Il passo delle aree Investimenti e Liquidità porta a
   una schermata di Posizioni che nasce con la **14** del gruppo 02 («Le posizioni prima di tutto»:
   `VistaPosizioniCliente.coerenza` e `.quadro`); finché la 14 non c'è, il passo apre Posizioni con l'ancora
   «coerenza» di oggi (`scorri(_:)`). L'avviso «Sono stime, non garanzie.» va coordinato con la **16** (un solo avviso
   sulle stime in Analisi 360).
3. **46 · Il confronto con le famiglie porta a un passo.** Dopo la 45: riusa la funzione degli articoli
   (`articolo(_:)`, 45.3 punto 3) e apre i simulatori nuovi; il meccanismo per aprire il dettaglio di un'area da codice
   (`StatoShell.areaDaAprire`) nasce qui, al punto 46.3.4 (la 45 non ne ha bisogno: i suoi passi vanno verso Posizioni).
4. **47 · Ogni potenziale ha il suo prossimo passo**, poi **48 · Il passaparola segue la persona**: stessi file e
   stesso oggetto di stato (`StatoPotenziali` in `Shell/StatoClientiLuce.swift`, `stato.potenziali`). La 48 riusa il testo del prossimo passo della 47
   per i potenziali del ramo. Tutte e due vivono in Clienti › Potenziali e Passaparola, che in modalità cliente non si
   aprono: non dipendono dalla **1** del gruppo 01.
5. **49 · La campagna in tre passi.** Dopo la **26** del gruppo 04 («Tono», «Invia con» e le parole del messaggio) e la
   **25** (Messaggi segue il cliente, «già partito»); la preselezione del gruppo del cliente usa la **2** del gruppo 01.
6. **51 · Il giro di domani si porta in tasca.** Per ultima: «Prepara l'incontro» usa `apriIncontro(per:)`, che esiste già e apre
   Incontri sulla preparazione (il momento «Prima» quando arriva la **20** del gruppo 03, che ne cambia la firma); il pulsante «Manda il giro all'iPhone» tocca le regole di privacy del
   Territorio e di «Prisma ovunque» e aspetta la decisione 51-a dell'utente. Si coordina con la **32** del gruppo 05
   («La mappa risponde»), che tocca lo stesso `PannelloTerritorio.swift` ma non «Il giro» né «La crescita».

**Codice comune con iPhone e iPad.** Nessuna vista di questo gruppo è solo Mac: il pacchetto ha un solo target
(`Package.swift`, `path: "Sources/Prisma"`, nessun `exclude`), e l'iPad apre le stesse app attraverso
`iOS/GuscioiPad.swift` → `ContenutoApp` (`Shell/ContenutoApp.swift:54`, `case .agenda: AppAgenda()`, e così Analisi 360,
Clienti, Messaggi, Territorio). `AppAgenda`, `AgendaMese`, `Analisi360Apple`, i simulatori, `PannelloTerritorio`,
`MessaggiCampagne`, `ClientiPotenziali` e `ClientiPassaparola` si compilano per iOS e in gran parte si vedono sull'iPad
(Potenziali e Passaparola in sola lettura: `potenzialiInSolaLettura`). Ogni cambiamento di comportamento o di
impaginazione va quindi dentro `#if os(macOS)` (come già fa `MessaggiCampagne.swift:182` per il ⌘-clic) o in un
ramo che l'iPad non usa; i motori e i testi nuovi (prossimo passo, borsa, frasi) possono restare comuni perché non
cambiano nulla su iOS finché nessuna vista iOS li usa. Le istantanee di iPhone e iPad devono restare uguali (girano su
main o lanciando il workflow a mano: prima dell'unione vanno lanciate).

**Cosa non si porta, per tutto il gruppo.** Il pannello «✦ Migliorie» (`MIG8`, righe 4608-4615), il cartellino
arancione `indica()` e i testi «Prima… Ora…» delle sue schede servono solo a presentare il template. Le cifre e i nomi
del template sono dimostrativi: `POTX` (i prossimi passi scritti a mano, riga 4504), `MESE_EV` e `MESE_SC` (gli impegni
e le scadenze del mese, righe 4564-4565), `GIRO_PORTA` (le cose da portare, riga 4594), `CAMPT` e `CAMPO` (i bisogni e
gli orari delle campagne, riga 4544), le formule del simulatore (`v*.0012*(c.eta/37)*(simFum?1.6:1)`, il 3% composto,
le aliquote fisse), il 2.300 € al mese della liquidità, la soglia dell'80% di coerenza, `PASS`/`POTN` del passaparola.
Le cifre le danno i motori di Prisma (`MotoreSimulatoriAnalisi`, `MotoreAree360`, `MotoreFamiglie`,
`MotorePassaparola`, `MotoreCampagne`, `MotoreTerritorio`, `MotoreNotte`), i nomi l'archivio. I messaggi «toast» del
template che descrivono cose finte («Nel template si aprono gli impegni dal 2 all'8 novembre», «Il giro di domani è
sull'iPhone: si apre in Mappe») non si portano così come sono.

---

## 45. Il simulatore mostra prima e dopo

### 45.1 Nel template

Righe 4448-4489: `simPrev` (4452-4469) e `simProt` (4470-4485) sostituiscono i due simulatori della base (`apriArea`,
riga 1186), e la ridefinizione di `apriArea` (4486-4489) aggiunge un passo in fondo alle altre due aree. Si apre con
`vaiCli(1,'analisi', vistaA='aree')` e la card «Previdenza» (`apriArea(el,'prev')`); il cartellino indica `#simFr`.

**Previdenza** (dettaglio 940 × 560, prima 940 × 540):
- testata come prima: «Previdenza · {nome cognome}» nel colore dell'area, titolo «Quanto mettere da parte per la
  pensione»; anello 190 (prima 210) con «{n}%» e «del divario»; le tre cifre «Pensione pubblica stimata», «Desiderata»,
  «Divario al mese» (nel colore dell'area);
- sopra il cursore: «Versamento mensile nel fondo pensione» e il valore grande (40, prima 44); **a destra, sulla stessa
  riga**, `#pDelta`: vuoto quando il cursore è sul valore di oggi, altrimenti «+150 € al mese rispetto a oggi» oppure
  «−50 € al mese rispetto a oggi»;
- **il cursore ha il segno «oggi»** (`.simOggi`, CSS riga 703-704): una tacca verticale 2 × 6 sopra la parola «oggi»
  (11, semibold, `--ink2`), messa sotto la posizione del versamento di oggi (`left: calc(fr0·100% + (0,5 − fr0)·22px)`,
  cioè corretta per il raggio della manopola); il segno non si muove con il cursore;
- sotto il cursore le tre cifre «Rendita in più al mese», «Capitale a {età} anni», «Risparmio fiscale l'anno» (verde);
- **la frase prima e dopo** (`#simFr`, una tile a tutta larghezza, testo 14,5, interlinea 1,5, margini 12 × 16):
  - cursore sul valore di oggi: «**Oggi** {nome} versa {v0} € al mese e copre il {n}% del divario. Sposta il cursore:
    qui leggi cosa cambia.» (senza versamento: «**Oggi** {nome} non versa niente: il divario è tutto scoperto.»);
  - cursore spostato: la frase di oggi, poi «**Con {v} € al mese** arriva al {n}%: alla pensione che desidera
    mancherebbero ancora {euro} al mese.», oppure «… arriva al 100%: il divario è chiuso.». Gli articoli («il»,
    «l'», «allo») si accordano con il numero (`il`, `al`, `elide`, `zero`, riga 4445);
- **le ipotesi non sono più una riga grigia ma due scelte**: «LE IPOTESI» (etichetta), «Rendimento l'anno» con un
  segmentato piccolo (`segS`, CSS `.segP`: padding 4 × 11, testo 12,5) «2% | 3% | 4%», «Aliquota» con «23% | 35% |
  43%», a destra in grigio «deduzione fino a 5.164,57 € l'anno». Cambiare una scelta ricalcola tutto subito (senza
  conteggio);
- piede: «Salva come proposta» (primario grande), «Chiedi a Vera di spiegarlo», e in grigio «Sono stime, non garanzie.»
  (al posto della vecchia riga «Rendimento ipotizzato 3% l'anno · deduzione … · aliquota 35%»).

**Protezione** (940 × 540): stessa idea. Anello «protetto», cifre «Capitale che servirebbe», «Già assicurato»;
«Capitale da aggiungere con una temporanea caso morte» con il cursore e il segno «oggi» all'inizio (oggi = 0 in più);
«Premio stimato l'anno», «Al mese». Frase: «**Oggi** è protetto il {n}% di quello che servirebbe: {euro} su {euro}.»,
poi «**Con {euro} in più** si arriva al {n}%, per circa {euro} al mese.» e «Chi conta su quel reddito è coperto.»
oppure «Resterebbero scoperti {euro}.». Ipotesi: «Fuma» con «No | Sì» e a destra «premio indicativo a {età} anni: le
condizioni vere vengono dal prodotto». Piede uguale alla previdenza.

**Investimenti e Risparmio e liquidità** (le altre due aree): in fondo al dettaglio della base compare una riga con una
frase a sinistra (14,5) e un pulsante primario grande a destra (`#anPasso`):
- Investimenti: con la coerenza ≥ 80% «Il portafoglio è in linea con il profilo: niente da sistemare.», altrimenti
  «Il {100−n}% del capitale rischia più del profilo scelto: si vede posizione per posizione.»; pulsante «Apri la
  coerenza nelle posizioni» → chiude il dettaglio e apre Posizioni del cliente sulla schermata «Coerenza con il
  profilo»;
- Risparmio e liquidità: con almeno sei mesi «La riserva c'è: oltre i sei mesi di spese.», altrimenti «Per arrivare a
  sei mesi servono ancora circa {euro}.»; pulsante «Vedi dove sono i suoi soldi» → Posizioni del cliente su «Quadro e
  posizioni».

### 45.2 Nell'app oggi

- `Sources/Prisma/Shell/SimulatorePrevidenzaApple.swift`: `SimulatorePrevidenzaApple` (:28), `QuadroSimulatorePrevidenza`
  (:60), `CorpoSimulatorePrevidenzaApple` (:81). Le cifre vengono da `MotoreSimulatoriAnalisi.previdenza` con le
  ipotesi dell'analisi (`IpotesiPrevidenza.rendimentoReale`, 1,5 di base, `Dati/Analisi.swift:130`) e l'IRPEF per
  scaglioni sul reddito lordo della scheda (non un'aliquota fissa). Sotto il cursore (`CursoreApple`) c'è già la riga
  `scarto` (:172): «oggi 150 € al mese · 150 € in più». Sotto le cifre `IpotesiSimulatoreApple(testo: ipotesi(p))`
  (:117, testo a :182): un paragrafo grigio con rendimento, montante, anni, fisco, TFR. Piede (:198): «Salva come
  proposta» (crea una `Posizione` proposta in bozza, :222), «Chiedi a Vera di spiegarlo», `CanaleSimulatoreApple`
  (Alleanza | Indipendente, sempre riconoscibile). Le etichette dell'app sono già più precise di quelle del template e
  **restano**: «Versamento mensile nei piani di previdenza» (il template dice «nel fondo pensione»), «Pensione
  pubblica» con l'aiuto (il template «Pensione pubblica stimata»). «Salva come proposta» è spento finché il cursore non
  supera il versamento di oggi (:204).
- `Sources/Prisma/Shell/SimulatoreProtezioneApple.swift`: `CorpoSimulatoreProtezioneApple` (:67), cursore del capitale
  in più, premio da `MotoreSimulatoriAnalisi.tariffaCasoMorte` (stima dalle coperture in archivio; senza, «—» e le
  ipotesi dicono perché), ipotesi a :149, piede a :184. **Non c'è nessuna ipotesi sul fumo**: la tariffa viene
  dall'archivio, non da una formula.
- Pezzi comuni in `Sources/Prisma/Shell/SimulatoriAnalisiApple.swift`: `TestataSimulatoreApple` (:111),
  `CifraSimulatoreApple` (:136), `AnelloSimulatoreApple` (:198), `IpotesiSimulatoreApple` (:233),
  `CanaleSimulatoreApple` (:249); `DettaglioSimulatoreAnalisiApple` (:61). Token in
  `DesignSystem/Apple/Tema.Apple+SimulatoriAnalisi.swift`.
- **Manca**: il segno «oggi» sul cursore, la frase «Oggi… / Con…», le ipotesi da scegliere, l'avviso breve nel piede.
- Investimenti e Liquidità: `Sources/Prisma/Shell/Analisi360AppleDettagli.swift`, `DettaglioInvestimentiApple` (:19) e
  `DettaglioLiquiditaApple` (:157), con `TestataDettaglioArea360` (:258, «Apri l'analisi completa ›»),
  `IpotesiDettaglioArea360` (:348, la riga delle ipotesi: resta) e `PiedeDettaglioArea360` (:364: «Salva come
  proposta», «Chiedi a Vera di spiegarlo», canale). Le cifre ci sono già in
  `MotoreAree360` (in cache, `stato.aree360(id)`): la coerenza `composizione.entroProfilo` con
  `MotoreAree360.quotaEntroProfilo`, la liquidità `Liquidita360` (`mesi`, `soglia` delle ipotesi, `riservaNecessaria`,
  `liquidita`, `eccedenza`). **Manca** la riga del passo verso Posizioni.
- Posizioni oggi non ha schermate separate «Coerenza» e «Quadro»: è una pagina lunga con le ancore (`scorri(_:)`); le
  schermate nascono con la miglioria 14 (gruppo 02, `VistaPosizioniCliente`).
- Il dettaglio di un'area si apre solo dal clic sulla card (`PresentatoreAree360`, `Analisi360Apple.swift:79`, con
  `StatoDettaglio`); da codice solo per le istantanee (`RichiestaIstantaneaAnalisi360`, `RichiestaIstantaneaSimulatore`).

### 45.3 Cosa fare

1. **Il segno «oggi» sul cursore.** In `SimulatoriAnalisiApple.swift` nuovo `SegnoOggiCursore: View` (frazione 0…1,
   larghezza della manopola dal tema): una tacca e la parola «oggi» sotto il binario, nella posizione del valore di
   partenza corretta per metà manopola (come la formula del template). In `CorpoSimulatorePrevidenzaApple.colonna` e
   in quello della protezione si mette in `.overlay(alignment: .bottomLeading)` del `CursoreApple`, dentro lo stesso
   `frame(maxWidth: s.larghezzaCursore)`. Protezione: frazione 0. Token nuovi in `Tema.Apple+SimulatoriAnalisi.swift`:
   `segnoOggiTacca` (CGSize 2 × 6), `segnoOggiSotto` (22), `segnoOggiCarattere` (11 semibold), `coloreSegnoOggi`
   (`inchiostro2`), `coloreTaccaOggi` (`inchiostro3`), `manopolaCursore` (22, se `CursoreApple` non lo espone già).
2. **Lo scarto a destra del valore.** La riga `scarto` di oggi diventa il testo a destra del valore grande (sulla
   stessa linea di base, `Spacer` in mezzo): vuoto sul valore di oggi, «+150 € al mese rispetto a oggi» /
   «−50 € al mese rispetto a oggi»; per la protezione nessuno scarto (il valore è già «in più»). Il caso «Nessun anno
   di accumulo…» resta, al posto dello scarto.
3. **La frase prima e dopo.** Nuovo `FraseSimulatoreApple: View` (una tile `Tema.Apple.Superficie` leggera a tutta
   larghezza, testo con le parti in neretto) sotto la colonna, al posto di `IpotesiSimulatoreApple`. I testi in un
   enum nuovo `TestiSimulatoriAnalisi` (file `Motori/TestiSimulatoriAnalisi.swift`), con le cifre già calcolate:
   - previdenza: `oggi(nome:versamento:copertura:)` → «Oggi Marco versa 150 € al mese e copre il 42% del divario.»;
     senza versamento «Oggi Marco non versa niente: il divario è tutto scoperto.»; senza divario «Oggi Marco non ha
     divario: la pensione pubblica stimata arriva a quella desiderata.» (caso che il template non ha);
     `dopo(versamento:copertura:mancano:)` → «Con 300 € al mese arriva al 61%: alla pensione che desidera
     mancherebbero ancora 310 € al mese.» / «… arriva al 100%: il divario è chiuso.»; sul valore di oggi si aggiunge
     «Sposta il cursore: qui leggi cosa cambia.». La copertura di oggi (versamento di oggi, rendimento scelto) dipende
     dal rendimento del punto 4 (nel template `pcA` cambia con `simR`): si calcola quando cambia il rendimento, non a
     ogni passo del cursore (un valore in `@State` aggiornato con `.onChange` della scelta, oppure una cache piccola
     per rendimento nel corpo); con il rendimento dell'analisi è quella di `QuadroSimulatorePrevidenza`;
   - protezione: «Oggi è protetto il 64% di quello che servirebbe: 180.000 € su 280.000 €.», «Con 100.000 € in più si
     arriva al 100%, per circa 32 € al mese. Chi conta su quel reddito è coperto.» / «… Resterebbero scoperti
     20.000 €.»; senza tariffa il pezzo «per circa … al mese» si toglie (nessun premio inventato);
   - gli articoli («il 42%», «l'80%», «all'11%», «al 100%») con una funzione `articolo(_ percentuale:)` in
     `TestiSimulatoriAnalisi` (come `il`/`al`/`elide` del template, riga 4445). Il nome è `StatoShell.nomeBreve`.
4. **Le ipotesi come scelte.** Sotto la frase una riga «LE IPOTESI» con due segmentati piccoli (`SegmentatoPillola`,
   `DesignSystem/Apple/ControlliApple.swift:19`, oggi senza varianti di misura: aggiungere un parametro `compatto`
   e i token accanto a quelli di `enum Segmentato` in `DesignSystem/Apple/Tema.Apple+Controlli.swift:17`, padding
   4 × 11 e testo 12,5; controllare che un altro gruppo non lo aggiunga già con un altro nome). **Le cifre non sono quelle del template** (decisione 45-a):
   - previdenza, «Rendimento l'anno»: tre valori attorno al rendimento reale dell'analisi (quello salvato, −0,5 e
     +0,5 punti, mai sotto 0), con quello salvato scelto all'apertura; la scelta vale solo nel simulatore (stato
     `@State` del corpo), non cambia l'analisi; le cifre si rifanno con `MotoreSimulatoriAnalisi.previdenza` su una
     copia delle ipotesi con il rendimento scelto;
   - previdenza, al posto di «Aliquota»: se la scheda ha il reddito lordo, nessun segmentato ma il testo fisso
     «Aliquota marginale {n}%, dal reddito della scheda» (la cifra vera dell'IRPEF per scaglioni); se il reddito manca,
     il segmentato «23% | 35% | 43%» con la nota «finché manca il reddito nella scheda» e il risparmio fiscale calcolato
     con l'aliquota scelta (una funzione nuova in `MotoreSimulatoriAnalisi` che riceve l'aliquota al posto del
     reddito). A destra «deduzione fino a {RegoleFiscali.limiteDeducibilita} l'anno»;
   - protezione: **niente «Fuma»** (la tariffa viene dalle coperture in archivio, un fattore 1,6 sarebbe inventato);
     al suo posto il testo «Premio stimato dalle coperture caso morte in archivio, a {età} anni: le condizioni vere
     vengono dal prodotto» (o la ragione per cui il premio manca).
   - Il resto delle ipotesi vere (montante oggi, anni di versamento, integrazione, TFR, contributi del datore) non si
     perde: va nel suggerimento (`.help`) della riga «LE IPOTESI» e resta in «Chiedi a Vera di spiegarlo».
5. **Il piede.** Accanto ai due pulsanti, in grigio, «Sono stime, non garanzie.» (testo unico in
   `TestiSimulatoriAnalisi.avviso`, lo stesso che la miglioria 16 usa altrove se lo sceglie); il canale resta a destra.
   «Salva come proposta» resta com'è (anche le proposte salvate non portano il rendimento scelto: la nota della
   posizione dice «rendimento ipotizzato {n}% l'anno» se diverso da quello dell'analisi).
6. **Misure.** Il dettaglio previdenza passa da 540 a 560 di altezza: oggi la misura è una sola,
   `Tema.Apple.Misura.DettaglioAperto.previdenzaProtezione` (`Tema.Apple+Schede.swift:27`, 940 × 540) letta da
   `SimulatoriAnalisi.misura` e da `DettagliAree360.misura`/`SimulatoriAnalisiApple`; va divisa in `previdenza`
   (940 × 560) e `protezione` (940 × 540). Anello 190 × 19 (token `anello` e `spessoreAnello`, oggi 210 × 20),
   centro 40 (`centroAnello`, oggi 42), valore del cursore 40 (`valoreCursore` = `Carattere.valoreCursoreAnalisi`, oggi
   44: serve un carattere nuovo, quello di oggi è usato anche dalla Sala dei giochi), spazio sopra il corpo e sopra il
   cursore 14 (`sopraCorpo`, `sopraCursore`, oggi 20). Controllare con le istantanee che nulla si tagli su
   uno schermo da 13" (la finestra più bassa).
7. **Il passo di Investimenti e Liquidità.** In `Analisi360AppleDettagli.swift` nuovo `PassoDettaglioArea360: View`
   (frase a sinistra, pulsante `.applePrimarioGrande` a destra), messo **sopra** `PiedeDettaglioArea360` (il piede di
   oggi resta: le due aree hanno già «Salva come proposta» e Vera, che il template base non aveva). Testi in
   `TestiAree360`:
   - Investimenti: se `entroProfilo` è nil (nessun profilo o nessuna posizione) nessun passo; se la quota fuori
     profilo è 0 «Il portafoglio è in linea con il profilo: niente da sistemare.»; altrimenti «Il {n}% del capitale
     rischia più del profilo scelto: si vede posizione per posizione.» (la soglia dell'80% del template non si porta:
     basta che una parte sia fuori profilo; vedi 45-b). Pulsante «Apri la coerenza nelle posizioni»;
   - Liquidità: se `mesi` è nil nessun passo; se `mesi >= soglia` «La riserva c'è: oltre i {soglia} mesi di spese.»;
     altrimenti «Per arrivare a {soglia} mesi servono ancora circa {riservaNecessaria − liquidita, arrotondato alle
     centinaia}.» (la soglia è quella delle ipotesi, non sei mesi fissi). Pulsante «Vedi dove sono i suoi soldi».
   - Azione: `dettaglio?.chiudi(poi:)` e poi `stato.apriPosizioniCliente(id, vista: .coerenza / .quadro)` (funzione
     nuova in `StatoShell`, accanto a quelle della miglioria 14: imposta `clienteAttivoId`, la vista di Posizioni e
     apre l'app). Finché la 14 non c'è, `.coerenza` apre Posizioni con l'ancora «coerenza» e `.quadro` in cima.
8. **Movimento.** La frase cambia senza animazione mentre si trascina (come le cifre «mosso»); all'apertura entra con
   la cascata del dettaglio. Con «Riduci movimento» e nelle istantanee tutto fermo nello stato finale (lo fanno già i
   componenti). Niente Timer.

### 45.4 Dati, archivio, privacy

Nessun campo nuovo. Il rendimento e l'aliquota scelti restano nello stato della vista (non si salvano, non entrano in
backup né in «Prisma ovunque»). Nessun dato esce dal Mac.

### 45.5 Istantanee e prove

- Aggiornare `441-analisi360-previdenza-simulatore` e `442-analisi360-protezione-simulatore`
  (`Shell/IstantaneeSimulatoriApple.swift`): mostrano già il cursore spostato, quindi la frase «Oggi… Con…».
- Nuove: `1140-uso-simulatore-previdenza-oggi` (Marco, cursore sul valore di oggi: frase con «Sposta il cursore…» e
  segno «oggi» sotto la manopola) e `-scuro`; `1141-uso-simulatore-previdenza-senza-reddito` (un cliente senza reddito
  lordo: il segmentato dell'aliquota); `1142-uso-investimenti-passo` (dettaglio Investimenti con il passo, via
  `RichiestaIstantaneaAnalisi360`); `1143-uso-liquidita-passo`.
- `--prova-calcoli`: aggiungere alla prova esistente dei simulatori (`Motori/ProvaCalcoliSimulatoriAnalisi.swift`) i
  casi dei testi e del passo di Investimenti e Liquidità (`ProvaCalcoliAree360.swift`): articoli («il 42%», «l'80%», «all'11%»), divario chiuso, nessun versamento, premio
  mancante, rendimento a ±0,5 mai negativo, risparmio fiscale con aliquota scelta uguale a quello con l'IRPEF quando il
  reddito dà la stessa aliquota marginale.

### 45.6 Decisioni per l'utente e rischi

- **45-a Le ipotesi da scegliere.** Il template offre «2% | 3% | 4%» e «23% | 35% | 43%»; l'app usa il rendimento
  reale delle ipotesi dell'analisi (1,5% di base) e l'IRPEF vera. Proposta: tre valori attorno al rendimento
  dell'analisi (solo per il simulatore, non salvati) e l'aliquota scelta solo quando manca il reddito.
- **45-b La soglia della coerenza.** Il template dice «in linea» dall'80% in su; proposta: «in linea» solo se nulla è
  fuori profilo, altrimenti la quota fuori profilo, senza soglia inventata.
- **45-c «Fuma».** Proposta: non portarlo (il premio viene dall'archivio). Se l'utente lo vuole, servirebbe una tariffa
  vera per fumatori nelle coperture, non un moltiplicatore.
- Rischio: il body del corpo del simulatore rifà una proiezione a ogni passo del cursore; la frase non deve aggiungere
  altri calcoli pesanti (la copertura di oggi si calcola una volta nel quadro). Le altezze nuove vanno verificate a
  finestra bassa: il dettaglio cresce di 20 punti.

### 45.7 Dimensione

M. File: `Shell/SimulatorePrevidenzaApple.swift`, `Shell/SimulatoreProtezioneApple.swift`,
`Shell/SimulatoriAnalisiApple.swift`, `Shell/Analisi360AppleDettagli.swift`, `Motori/TestiSimulatoriAnalisi.swift`
(nuovo), `Motori/MotoreSimulatoriAnalisi.swift`, `Motori/MotoreAree360.swift` (`TestiAree360`),
`DesignSystem/Apple/Tema.Apple+SimulatoriAnalisi.swift`, `DesignSystem/Apple/Tema.Apple+Schede.swift`,
`DesignSystem/Apple/ControlliApple.swift` e `Tema.Apple+Controlli.swift` (segmentato compatto),
`Shell/IstantaneeSimulatoriApple.swift`, `Motori/ProvaCalcoliSimulatoriAnalisi.swift`.

---

## 46. Il confronto con le famiglie porta a un passo

### 46.1 Nel template

Righe 4491-4499: ridefiniscono `famHTML` e `montaFam` della base (righe 1637-1644). Si apre con `vaiCli(1,'analisi',
vistaA='fam')`; il cartellino indica `#famPasso`.

- La card in testa resta quella della base (la frase grande con la percentuale in blu e il sottotitolo); le frasi
  sistemano gli articoli («del 38%» → «dell'8%», «Il 62% delle famiglie» → «L'82% delle famiglie»).
- **In fondo alla card in testa** (`#famPasso`, sopra un filo `--sep`, margine 14, padding 12):
  - se almeno una delle quattro voci è sotto il 50%: la capsula di stato arancio «Dove resta indietro», poi
    «{Sul risparmio | Sul patrimonio | Sulla protezione | Sulla previdenza}: il {100−p}% delle famiglie come la sua fa
    meglio.» e a destra il pulsante primario «Apri l'area {Risparmio e liquidità | Investimenti | Protezione |
    Previdenza}» (il nome dell'area di Analisi 360). La voce scelta è quella con la percentuale più bassa;
  - altrimenti la capsula verde «Sopra la metà in tutte e quattro» e «Non c'è un punto debole rispetto alle famiglie
    come la sua.» (senza pulsante).
- Ogni card sotto la metà, dopo «… fa meglio: qui c'è margine.», ha il collegamento «Apri l'area ›».
- Pulsante e collegamenti: tornano alla vista «Le quattro aree» (`vistaA='aree'`, con il cambio di vista di sempre) e,
  dopo 0,65 s, aprono il dettaglio di quell'area dalla sua card (per Previdenza e Protezione il simulatore della 45).
- Il commento del template accenna anche a «gli articoli giusti»: è la sistemazione delle frasi, non articoli da
  leggere.

### 46.2 Nell'app oggi

- `Sources/Prisma/Shell/FamiglieComeLaSua.swift`: `FamiglieComeLaSuaApple` (:112, `Equatable`), card principale
  `principale(_:nome:)` (:150) con la frase (`frase`, :177) e il sottotitolo; la griglia delle voci (`griglia`, :201)
  con `CardVoceFamiglie` (:316); `azioneCompleta` (:237, «Completa nella scheda del cliente ›», mai in modalità
  cliente); `nota` (:288). Testi in `Motori/TestiFamiglieVista.swift`, token in `Tema.Apple+Famiglie.swift`.
- Il confronto è più ricco del template: `stato.confrontoFamiglie(id)` dà `ConfrontoFamiglie` con cinque voci
  (`VoceFamiglie`: `tassoRisparmio`, `ricchezzaFinanziaria`, `ricchezzaNetta`, `protezione`,
  `previdenzaComplementare`, `Dati/TabelleFamiglie.swift:16`), due gruppi (età e quinto di reddito), e per ogni voce
  `ConfrontoVoceFamiglie` (`Motori/MotoreFamiglie.swift:120`) con `percentile` (solo con i quantili), `sopra` (con
  mediana, media, rapporto, quota) e la `frase`.
- Il cambio di vista: `stato.vistaAnalisi360` (`StatoShell.swift:284`, `.aree` / `.famiglie`; il selettore è
  `RigaVisteAnalisi360`, `FamiglieComeLaSua.swift:67`) con l'uscita e l'entrata di `cambiaVista`
  (`Analisi360Apple.swift:256`). `PresentatoreAree360` chiude il dettaglio quando cambiano `clienteAttivoId`,
  `areaAnalisi` o `strumentoAnalisi` (:105-107): il nuovo `areaDaAprire` non deve toccare quelle tre proprietà.
- **Manca** «Dove resta indietro» e ogni collegamento verso le aree; manca un modo di aprire il dettaglio di un'area da
  codice fuori dalle istantanee.

### 46.3 Cosa fare

1. **Il punto debole.** In `Motori/MotoreFamiglie.swift` nuova funzione pura
   `static func puntoDebole(_ c: ConfrontoFamiglie) -> PuntoDeboleFamiglie?` con
   `struct PuntoDeboleFamiglie { let voce: VoceFamiglie; let area: AreaAnalisi; let percentile: Int?; let sopra: Bool? }`:
   - per ogni voce il confronto più severo dei due gruppi (età e reddito);
   - voci sotto la metà: `percentile < 50` con i quantili, `sopra == false` con mediana, media, rapporto o quota;
   - si sceglie la voce con il percentile più basso; a parità, o senza percentile, l'ordine risparmio, patrimonio,
     protezione, previdenza;
   - `ricchezzaFinanziaria` e `ricchezzaNetta` sono una voce sola per l'area («Sul patrimonio» → Investimenti);
   - `nil` se nessuna voce è sotto la metà; un valore speciale (o un `Bool` a parte) per «nessun confronto utile»
     quando mancano le cifre del cliente in tutte le voci: allora la riga non compare.
   - Mappa voce → area: `tassoRisparmio` → `.risparmio`, `ricchezzaFinanziaria`/`ricchezzaNetta` → `.investimenti`,
     `protezione` → `.protezione`, `previdenzaComplementare` → `.previdenza`.
2. **La riga in fondo alla card principale.** In `FamiglieComeLaSuaApple.principale` aggiungere sotto il sottotitolo
   un filo (`Tema.Misura.filo`, colore separatore) e la riga: la capsula di stato arancio «Dove resta indietro» (non
   esiste un `CapsulaStato`: riusare `Pillola(testo:tono:)` di `DesignSystem/ComponentiAnalisi.swift:314` con
   `.attenzione` / `.ok`, se nel tema Apple rende come `st2` del template, altrimenti una capsula nuova nel tema
   Apple con i colori di `StatoRigaApple.colore(_:)`, `ImpostazioniApple.swift:139`), la frase e il pulsante `.applePrimario` «Apri l'area
   {TestiAree360.nomeArea(area)}». Frasi in `TestiFamiglieVista`:
   - con il percentile: «Sul risparmio: il 62% delle famiglie come la sua fa meglio.» (`100 − percentile`, con
     l'articolo giusto: «l'82%», «l'8%»);
   - con mediana o media: «Sul risparmio: sta sotto la media (o la mediana) delle famiglie come la sua.»;
   - con la quota: «Sulla previdenza: la maggior parte delle famiglie come la sua ce l'ha, lui no.» (testo da far
     approvare insieme alle altre frasi, decisione 46-a);
   - tutte sopra: capsula verde «Sopra la metà in tutto», frase «Non c'è un punto debole rispetto alle famiglie come la
     sua.» (il template dice «in tutte e quattro»: le voci dell'app possono essere cinque o meno).
   In modalità cliente la riga e il pulsante restano (Analisi 360 si apre in modalità cliente e le aree sono del
   cliente mostrato; è un'analisi da guardare insieme); nessun testo nuovo da nascondere. Resta nascosto, come oggi,
   solo «Completa nella scheda del cliente ›».
3. **«Apri l'area ›» sulle card.** In `CardVoceFamiglie` un collegamento `StileCollegamento` «Apri l'area ›» sotto la
   frase della voce quando quella voce è sotto la metà (stessa regola del punto 1); accanto a «Completa nella scheda»
   se c'è anche quello.
4. **Aprire un'area da codice.** Nuova proprietà non salvata in `StatoShell` (accanto a `vistaAnalisi360`):
   `var areaDaAprire: AreaAnalisi?` e la funzione `apriAreaAnalisi360(_ area: AreaAnalisi)`: imposta
   `vistaAnalisi360 = .aree` e poi `areaDaAprire = area`. `PresentatoreAree360` (`Analisi360Apple.swift:79`) ascolta
   `.onChange(of: stato.areaDaAprire)`: aspetta la fine del cambio di vista (`Tema.Apple.Moto.tempo(...)` del
   `rimonta`, la stessa attesa che il template chiama 650 ms, al ritmo `Tema.Apple.Moto.ritmo`; subito con «Riduci
   movimento»), poi `dettaglio.apri(id, misura:)` con l'id della card (`DettagliAree360.id` o
   `SimulatoriAnalisiApple.id`) così il dettaglio nasce dalla card (`origineDettaglio`), e rimette `areaDaAprire = nil`.
   Lo stesso meccanismo serve alle istantanee nuove (al posto di aggiungere un'altra `RichiestaIstantanea…`).
5. **Le frasi con gli articoli.** Le frasi di oggi dei testi famiglie usano già le cifre del motore; controllare che
   «il 8%» o «del 11%» non escano mai (funzione comune `articolo(_:)` della 45, messa in un posto condiviso, per esempio
   `Formati` o `TestiComuni`).

### 46.4 Dati, archivio, privacy

Nessun campo nuovo; `areaDaAprire` è stato della finestra, non si salva. Le tabelle delle famiglie restano risorse
incluse o caricate a mano: niente rete.

### 46.5 Istantanee e prove

- Aggiornare `445-analisi360-famiglie` (e le varianti 446-449 di `Shell/IstantaneeFamiglie.swift`): compare la riga
  «Dove resta indietro» o «Sopra la metà».
- Nuove: `1144-uso-famiglie-passo` (Giulia o Marco, con una voce sotto la metà) e `-scuro`;
  `1145-uso-famiglie-apri-area` (dopo `apriAreaAnalisi360(.previdenza)`: il simulatore aperto dalla card, stato
  finale).
- `--prova-calcoli`: in `ProvaCalcoliFamiglie` i casi di `puntoDebole`: tutte sopra → nil; quantili (percentile più
  basso vince); mediana `sopra == false`; patrimonio con due voci che diventano una; senza cifre del cliente.

### 46.6 Decisioni per l'utente e rischi

- **46-a Le frasi senza percentile.** Il template ha solo percentili; l'app dà spesso mediana, media o quota (tavole
  della Banca d'Italia a una dimensione). Proposta: le tre frasi del punto 2, mai un percentile inventato.
- Rischio: `FamiglieComeLaSuaApple` è `Equatable` sulla chiave dei dati: il punto debole si calcola dal confronto già in
  cache (`stato.confrontoFamiglie`), nessun calcolo in più nel body. L'attesa prima di aprire il dettaglio non deve
  usare `DispatchQueue` con valori sparsi: un token `Tema.Apple.Moto` per il ritardo.

### 46.7 Dimensione

M. File: `Shell/FamiglieComeLaSua.swift`, `Motori/MotoreFamiglie.swift`, `Motori/TestiFamiglieVista.swift`,
`Shell/Analisi360Apple.swift`, `Shell/StatoShell.swift`, `DesignSystem/Apple/Tema.Apple+Famiglie.swift`,
`Shell/IstantaneeFamiglie.swift`, `Motori/ProvaCalcoliFamiglie.swift`.

---

## 47. Ogni potenziale ha il suo prossimo passo

### 47.1 Nel template

Righe 4501-4521: `POTX` (4504, i passi scritti a mano), `potX`, la nuova `potHTML` (4508), `potRifai` (4511),
`potScheda` (4513) e la nuova `montaPot` (4521), al posto di quelle della base (righe 2503-2506). Si apre con
`scegliCli(null,1); vistaC='pot'; vaiM('clienti')`; il cartellino indica la prima `.kCard`.

- **Le quattro tile in testa**: «Potenziali clienti», «Patrimonio stimato», «Dal passaparola» come prima; la quarta
  **«Probabile entro fine anno» diventa «Fermi da più di due settimane»** (il numero in arancio se più di zero).
- **La scheda** (`.kCard`): nome (14, neretto), fonte («presentato da Marco», 12, grigio), poi **il prossimo passo**
  (`.kPasso`: 12,5, semibold, colore accento, interlinea 1,35) — per esempio «Chiamalo: Marco gli ha già parlato di
  te», «Rispondi alla richiesta arrivata dal sito», «Primo incontro giovedì 5 alle 18:00», «Fissa la data del primo
  incontro», «Finisci l'analisi: mancano i dati della pensione», «Ha la proposta in mano: senti cosa ne pensa» —; in
  fondo la stima in euro a sinistra e a destra «fermo da {n} giorni» (arancio scuro e semibold oltre i 14 giorni). Nella
  colonna «Cliente» al posto del passo, in verde, «Cliente: è nell'albero del passaparola». **Sparisce la barra della
  probabilità** e la percentuale dalla scheda.
- **Toccare la scheda non la sposta più: la apre** (`potScheda`, dettaglio 820 × 430 che nasce dalla scheda):
  - avatar 54 con le iniziali, occhiello «{fase} · {fonte}», nome 26 bold;
  - tre tile: «Patrimonio stimato» {euro}; «Probabilità» {n}% con sotto «che diventi cliente»; «Fermo da» «{n} giorni»
    con sotto «in «{fase}»» (in arancio oltre i 14 giorni) — per un cliente «Cliente» «sì» «dal 28 ottobre»;
  - una tile «**Il prossimo passo**» con il testo del passo e il punto;
  - pulsanti: il primario con l'azione del passo («Chiama», «Scrivi», «Prepara l'incontro», «Fissa l'incontro»,
    «Chiedi i dati»), «Passa a «{fase dopo}»», e a destra «Non interessato». Per chi è già cliente: tile «Fatto», «È
    diventata cliente: la trovi tra i clienti e nell'albero del passaparola.» e «Va bene».
  - «Passa a…»: il dettaglio si chiude, la scheda vola nella colonna dopo (650 ms, molla) e sotto le colonne compare
    «**{nome}** è passato a «{fase}». Annulla»; «Annulla» la rimette dov'era, nella stessa posizione. Arrivando in
    «Cliente» l'avviso «Nuovo cliente: entra nell'albero del passaparola».
  - «Non interessato»: si toglie dalle colonne con l'avviso «{nome} tolto dai potenziali: resta in archivio».
  - L'azione del passo: nel template solo un avviso («Il numero è nella scheda: dopo la chiamata Prisma ti chiede com'è
    andata», ««Scrivi»: si apre con Paolo già scelto»).
- La nota sotto le colonne, senza spostamenti recenti: «Tocca una scheda per aprirla: dentro c'è il prossimo passo.
  Prisma ricorda chi l'ha presentata: quando diventa cliente compare nell'albero del passaparola.»

### 47.2 Nell'app oggi

- `Sources/Prisma/Shell/ClientiPotenziali.swift`: `VistaPotenziali` (:26), `CorpoPotenziali` (:35) con le quattro
  `TilePotenziali` (`tile`, :142: «Potenziali clienti», «Patrimonio stimato» con «N senza stima», «Dal passaparola»,
  «Probabile entro fine anno» con «N senza tutti i dati»), le colonne (`ColonnaPotenziali`, :304), il piede (:153: la
  nota `TestiPassaparola.notaPercorso` e i «Non interessati»). `SchedaPotenziale` (:407): nome (clic → dettaglio), fonte,
  «stima · probabilità», `BarraPiena` della probabilità, il segno «Informativa da dare»; **il clic sulla scheda la fa
  avanzare** (`azioni.avanti`, :464; un cliente apre il dossier); trascinamento fra le colonne
  (`TrascinabilePotenziale`), menu «Avanti · Indietro · Modifica… · Non interessato · Elimina», tastiera (frecce,
  ⌘→/⌘←, Invio, Canc, :225).
- `DettaglioPotenziale` (:494): occhiello «POTENZIALE CLIENTE · {FASE}», nome, fonte, righe Email, Telefono, Patrimonio
  stimato, Probabilità, Chiusura prevista, Informativa, Consenso, Nota, «STORIA»; pulsanti (:565) «Fissa il primo
  incontro» (`stato.fissaPrimoIncontro`), «Scrivigli» (solo con informativa e consenso, `scriviAPotenziale`: apre Mail o
  Messaggi, Prisma non spedisce), «Diventa cliente» (`proponiCliente`), «Modifica…», «Ripristina».
- Stato e azioni: `Shell/StatoPotenziali.swift` (`spostaPotenziale` :45, `avanzaPotenziale` :57, `arretraPotenziale`,
  `fissaPrimoIncontro` :120, che crea un appuntamento `tipo: .primoIncontro` con titolo «Primo incontro · {nome}» e
  `clienteId` vuoto, senza legame con il potenziale), `StatoPotenziali` in `Shell/StatoClientiLuce.swift` (`stato.potenziali`: scelto, evidenziato,
  daEliminare, dettaglioIstantanea). Dati: `Dati/PotenzialeCliente.swift` (`FasePotenziale`, `CambioFase`, `storia`,
  `creatoIl`, decisione 94: stima, probabilità e data le scrive l'utente). Motore: `Motori/MotorePassaparola.swift`
  (`sposta`, totali), testi `Motori/TestiPassaparola.swift`, token `Tema.Apple+Potenziali.swift`.
- **Manca**: il prossimo passo (non esiste nemmeno come campo), i giorni di fermo, la tile «Fermi», l'apertura al
  clic, «Passa a…» nel dettaglio, l'annullamento dello spostamento.

### 47.3 Cosa fare

1. **Il prossimo passo, dal codice** (nessun campo nuovo, decisione 47-a). In `Motori/MotorePassaparola.swift`:
   `struct PassoPotenziale: Equatable { let testo: String; let azione: AzionePotenziale?; let giorniFermo: Int; let fermo: Bool }`,
   `enum AzionePotenziale { case chiama, scrivi, fissaIncontro, preparaIncontro(appuntamentoId: String) }` e
   `static func prossimoPasso(_ p: PotenzialeCliente, presentatore: String?, primoIncontro: Appuntamento?, oggi: Date) -> PassoPotenziale`.
   Regole (testi in `TestiPassaparola`):
   - **Da contattare**: presentato da un cliente → «Chiamalo: te l'ha presentato {nome breve}» (o «Scrivigli: …» senza
     telefono); fonte libera → «Rispondi: arriva {dalla fonte}» («dal sito dello studio»); né l'uno né l'altro →
     «Decidi come contattarlo». Azione: `.chiama` con il telefono, altrimenti `.scrivi` se `contattabile`, altrimenti
     nessuna (resta «Modifica…»). Se manca l'informativa la frase lo dice prima: «Prima dagli l'informativa: poi
     chiamalo» (l'informativa ai terzi è la decisione 39).
   - **Primo incontro**: con un appuntamento futuro «Primo incontro · {nome}» (lo stesso titolo che crea
     `fissaPrimoIncontro`) → «Primo incontro {giovedì 5} alle {18:00}», azione `.preparaIncontro`; altrimenti «Fissa la
     data del primo incontro», azione `.fissaIncontro`.
   - **Analisi**: «Raccogli i dati per l'analisi» (azione `.chiama` o `.scrivi`).
   - **Proposta**: «Ha la proposta in mano: senti cosa ne pensa» (azione `.chiama` o `.scrivi`).
   - **Cliente**: «Cliente: è nell'albero del passaparola». **Non interessato**: nessun passo.
   - Giorni di fermo: da `storia.last?.il ?? creatoIl` a oggi (giorni di calendario); `fermo` oltre
     `RegolePassaparola.giorniFermo = 14` (costante nuova accanto alle altre regole del motore).
   Il cerca-appuntamento si fa una volta per tutti i potenziali in `stato.ricavato("potenziali-passi") { … }`
   (un dizionario id → passo; chiave con il giorno, che `ricavato` già segue), non nel body di ogni scheda.
2. **Le tile.** La quarta tile diventa «Fermi da più di due settimane» (valore intero, colore `Tema.Apple.Colore.arancio`
   se > 0). «Probabile entro fine anno» non sparisce dall'app: va nella nota della tile «Patrimonio stimato» («di cui
   probabile entro fine anno: {euro}») — vedi decisione 47-b.
3. **La scheda.** In `SchedaPotenziale`: togliere `BarraPiena` e la probabilità; sotto la fonte il passo
   (`P.passoScheda` 12,5 semibold, `P.colorePasso` = accento; in «Cliente» `P.colorePassoCliente` = verde); in fondo la
   stima (o «stima da scrivere») e a destra «fermo da {n} giorni» (`P.fermoScheda` 12,5; oltre la soglia
   `Tema.Apple.Colore.arancioTesto` semibold, il `#B45309` già definito in `Tema.Apple+Ovunque.swift:11`, lo stesso
   `--orangeT` del template). Nella colonna «Cliente» niente «fermo da». Il segno «Informativa da dare» resta.
   **Clic sulla scheda: il dettaglio** (`azioni.dettaglio`), non più `avanti`; anche per chi è già cliente (il template
   apre la scheda «Fatto», punto 4), con il dossier raggiungibile dal pulsante nel dettaglio e dal menu. Il nome non
   ha più un tocco a parte.
   Restano trascinamento, menu contestuale e tastiera (⌘→ fa ancora avanzare: è esplicito). L'aiuto
   d'accessibilità diventa «Tocca per aprirla».
4. **Il dettaglio.** In `DettaglioPotenziale` (misura `Tema.Apple.Potenziali.larghezzaDettaglio/altezzaDettaglio`
   portata a 820 × 430 o lasciata crescere con lo scorrimento): testata con `AvatarCliente` 54 (iniziali, tinta neutra
   dei potenziali), occhiello «{FASE} · {fonte}», nome; poi tre tile («Patrimonio stimato», «Probabilità» con «che
   diventi cliente» — «—» se non scritta —, «Fermo da» con «in «{fase}»», arancio oltre la soglia; per chi è già
   cliente la terza tile è «Cliente» «sì» «dal {data}», con la data del `CambioFase` verso `.cliente` nella storia,
   senza data se manca); poi la tile «Il
   prossimo passo» con il testo; poi i pulsanti:
   - primario: l'azione del passo — `.chiama` «Chiama» (vedi decisione 47-c), `.scrivi` «Scrivi» →
     `scriviAPotenziale` (spento senza informativa e consenso, con il motivo nel suggerimento), `.fissaIncontro`
     «Fissa l'incontro» → `fissaPrimoIncontro`, `.preparaIncontro` «Prepara l'incontro» →
     `apriAppuntamentoInAgenda`;
   - «Passa a «{fase dopo}»» (`.appleGrande`); da «Proposta» diventa «Diventa cliente» (`proponiCliente`, come oggi);
   - a destra «Non interessato» (`.appleSobrio`).
   - Per un cliente: tile «Fatto» con «È diventato cliente: lo trovi tra i clienti e nell'albero del passaparola.»
     (il genere non si conosce: forma neutra «È diventato/a…» da evitare; proposta «Ora è un cliente: lo trovi tra i
     clienti e nell'albero del passaparola.»), «Va bene» e, perché il clic sulla scheda di un cliente oggi apre il
     dossier e quel gesto non va perso, «Apri il dossier» (`.appleGrande`, `azioni.dossier`).
   - Sotto, le righe di oggi (Email, Telefono, Chiusura prevista, Informativa, Consenso, Nota, Storia) e «Modifica…»:
     non si perdono, scendono sotto i pulsanti.
5. **Lo spostamento si può annullare.** In `StatoPotenziali` (`Shell/StatoClientiLuce.swift`) nuovo `ultimoSpostamento: (prima: PotenzialeCliente, a: FasePotenziale)?`
   (in memoria). `spostaPotenziale` (quando parte da «Passa a…», dal trascinamento o da ⌘→) salva la copia di prima;
   sotto le colonne la nota diventa «**{nome}** è passato a «{fase}». Annulla» (`StileCollegamento`); «Annulla»
   (nuova `stato.annullaSpostamentoPotenziale()`) rimette la copia salvata così com'era (storia compresa: nessun
   `CambioFase` in più) con la stessa animazione di volo (`Tema.Apple.Moto.Potenziali.avanza`). L'annullamento vale
   finché non si fa un altro spostamento o si lascia la vista; non vale per «Diventa cliente» (che apre la scena del
   nuovo cliente) né per «Non interessato» (che si ripristina dal piede come oggi).
6. **La nota sotto le colonne** senza spostamenti recenti: «Tocca una scheda per aprirla: dentro c'è il prossimo
   passo. Prisma ricorda chi l'ha presentata: quando diventa cliente compare nell'albero del passaparola.» (aggiornare
   `TestiPassaparola.notaPercorso`).
7. Avvisi: «Non interessato» → «{nome} tolto dai potenziali: resta in archivio»; arrivo in «Cliente» come oggi
   (`TestiPassaparola.benvenuto`).

### 47.4 Dati, archivio, privacy

Nessun campo nuovo: il passo e i giorni di fermo si ricavano da fase, storia, fonte, recapiti e agenda. (Se l'utente
vuole scrivere il passo a mano, servirebbe `PotenzialeCliente.prossimoPasso: String?` nella sezione `relazione.json`,
nei backup e in «Prisma ovunque» solo con «Porta anche i potenziali clienti»: vedi 47-a.) I potenziali sono dati di
terzi: «Chiama» e «Scrivi» restano gesti del consulente, mai un invio di Prisma; «Scrivi» continua a richiedere
informativa e consenso.

### 47.5 Istantanee e prove

- Aggiornare `850-clienti-potenziali` (e `-scuro`), `851-…-vuoto`, `852-…-senza-stime`, `853-clienti-potenziale-dettaglio`
  (`Shell/IstantaneeClientiLuce.swift`): le schede con il passo e i giorni, la tile «Fermi», il dettaglio nuovo.
- Nuove: `1146-uso-potenziali-annulla` (dopo «Passa a…»: la nota con «Annulla»); `1147-uso-potenziale-dettaglio-incontro`
  (un potenziale in «Primo incontro» con l'appuntamento fissato: «Prepara l'incontro»). I dati di prova
  (`Dati/PotenzialiDiProva.swift`) devono avere storie con date che diano almeno un «fermo» oltre i 14 giorni rispetto
  alla data fissa delle istantanee.
- `--prova-calcoli`: in `ProvaCalcoliPassaparola` i casi di `prossimoPasso` (ogni fase, con e senza presentatore,
  telefono, informativa, primo incontro fissato o passato) e dei giorni di fermo (storia vuota → `creatoIl`).
- `--prova-backup`: nessuna modifica (nessun campo nuovo).

### 47.6 Decisioni per l'utente e rischi

- **47-a Il passo scritto da Prisma o dall'utente.** Proposta: lo scrive Prisma dalle regole del punto 1 (nessun campo
  nuovo, coerente con la decisione 94 che vuole dall'utente solo stima, probabilità e data).
- **47-b La tile «Probabile entro fine anno».** Il template la sostituisce con «Fermi da più di due settimane».
  Proposta: seguire il template e spostare il probabile nella nota della tile del patrimonio.
- **47-c «Chiama».** Il template mostra solo un avviso. Proposta: «Chiama» apre un piccolo riquadro con il numero in
  grande, selezionabile, e «Copia il numero» (nessun `tel:`, nessuna app di sistema aperta da Prisma); dopo, nessuna
  domanda automatica («Prisma ti chiede com'è andata» non esiste ancora per i potenziali).
- **47-d Il legame con il primo incontro.** Oggi l'appuntamento del primo incontro non sa di quale potenziale è (titolo
  «Primo incontro · {nome}», `clienteId` vuoto). Proposta: riconoscerlo dal titolo e dal tipo (nessun campo nuovo);
  un campo `Appuntamento.potenzialeId` sarebbe più solido ma tocca archivio, backup e sincronizzazione.
- Rischio: il body di `CorpoPotenziali` non deve cercare negli appuntamenti per ogni scheda (con 200 potenziali e
  migliaia di appuntamenti): tutto in `stato.ricavato`. Cambiare il clic da «avanza» ad «apri» cambia un'abitudine:
  il menu e ⌘→ restano per chi avanzava al volo.

### 47.7 Dimensione

M (vicina a L). File: `Shell/ClientiPotenziali.swift`, `Shell/StatoPotenziali.swift`, `Shell/StatoClientiLuce.swift`, `Motori/MotorePassaparola.swift`, `Motori/TestiPassaparola.swift`,
`DesignSystem/Apple/Tema.Apple+Potenziali.swift`, `Dati/PotenzialiDiProva.swift`, `Shell/IstantaneeClientiLuce.swift`,
`Motori/ProvaCalcoliPassaparola.swift`.

---

## 48. Il passaparola segue la persona

### 48.1 Nel template

Righe 4523-4539: ridefiniscono `passHTML` e `montaPass` della base (righe 2508-2520). Si apre con
`scegliCli(null,1); vistaC='pass'; vaiM('clienti')` e, dopo 1,3 s, sceglie la prima persona; il cartellino indica
`#psChi`.

- La nota sotto l'albero aggiunge «Tocca una persona per vedere il suo ramo.».
- **Toccare una persona** (un nodo del primo livello nell'albero, `.psN[data-capo]`, oppure una riga tra «I tuoi
  ambasciatori») **accende il suo ramo**: tutto il resto dell'albero scende al 20% di opacità (transizione 0,3 s), il
  nodo, i suoi legami e le persone che ha presentato restano pieni. Un secondo tocco sulla stessa persona spegne la
  scelta.
- **A destra la card «I tuoi ambasciatori» diventa «Il ramo di»** (stesso posto, entrata 260 ms dal basso di 6 punti):
  - testata: avatar 42, occhiello «Il ramo di», nome 19 bold, a destra il pulsante «Tutti» (torna agli ambasciatori);
  - frase: «Ti ha presentato {una persona | N persone}: {una è già cliente | N sono già clienti} ({euro}), {una è
    ancora un potenziale | N sono ancora potenziali}.» oppure «… nessuna è ancora cliente…»; chi non ha presentato
    nessuno: «{nome} non ti ha ancora presentato nessuno.»;
  - l'elenco delle persone presentate: nome, capsula «Potenziale» (neutra) o «Cliente» (verde), cifra a destra;
  - pulsanti: primario «Ringrazia {nome}» (con presentati) oppure «Chiedi una presentazione» (senza), e «Apri il
    dossier». Il primario diventa «✓ Messaggio pronto» con l'avviso «Per {nome}: un grazie per le persone che ti ha
    presentato. Lo trovi in Messaggi» / «Per {nome}: una richiesta leggera, senza pressione. La trovi in Messaggi».
    «Apri il dossier» porta al dossier del cliente.

### 48.2 Nell'app oggi

- `Sources/Prisma/Shell/ClientiPassaparola.swift`: `VistaPassaparola` (:21) calcola nel body albero, ambasciatori,
  quota, nuovi per anno e momento giusto con `MotorePassaparola` (`patrimoni`, `albero`, `ambasciatori`,
  `quotaPassaparola`, `nuoviPerAnno`, `momentoGiusto`); `DisegnoAlbero` (:190) con `NodoPassaparolaVista` (:284);
  `AmbasciatoriCard` (:356): **il clic su un ambasciatore evidenzia già i suoi rami** (gli altri al 30%,
  `Tema.Apple.Passaparola.opacitaSpenta = 0.30`, `Tema.Apple+Potenziali.swift:107`; `stato.potenziali.evidenziato`,
  :365). L'attenuazione confronta `evidenziato` con `NodoDisposto.ramo` (:107, :138), che è l'id del **cliente del
  primo livello** da cui scende il nodo: oggi si può evidenziare solo un ramo intero dal primo livello; `MomentoGiustoCard` (:427: «Il momento giusto per chiedere» con «Prepara la
  richiesta» → `stato.preparaRichiestaPresentazione`, che diventa «✓ Messaggio pronto» solo quando il messaggio esiste);
  `ColonneAnniPassaparola` (:456).
- **Il clic su un nodo cliente apre il dossier** (`tocca`, :80); su un potenziale il suo dettaglio in Potenziali.
- `NodoPassaparola` (`Motori/MotorePassaparola.swift:35`: tipo, patrimonio, fase, figli) e `Ambasciatore` (:68:
  presentati, portato, inArrivo; solo chi ha presentato almeno due persone).
- Messaggi: `TipoOccasioneMessaggio.richiestaPresentazione` (`Dati/MessaggioCliente.swift:31`, decisione 17: dopo un
  fatto bello, mai nomi d'altri, mai cifre, mai incentivi, commerciale) con il modello in `ModelliMessaggi`. **Non
  esiste** un messaggio di ringraziamento per le presentazioni.
- **Manca**: la scelta di una persona qualsiasi dall'albero, la card «Il ramo di», il ringraziamento.

### 48.3 Cosa fare

1. **La scelta.** `stato.potenziali.evidenziato` resta il solo stato (id del cliente scelto, nil = nessuno). In
   `tocca(_:)`: un nodo **cliente** non apre più il dossier ma sceglie la persona (secondo tocco: spegne); un
   potenziale apre il suo dettaglio come oggi. Anche le righe di `AmbasciatoriCard` scelgono (come oggi). Il dossier
   si apre dal pulsante «Apri il dossier» e con ⌘-clic sul nodo (scorciatoia come nelle campagne).
2. **Il ramo nell'albero.** `DisegnoAlbero` già attenua i rami non evidenziati al 30%: portare il token esistente
   `Tema.Apple.Passaparola.opacitaSpenta` da 0,30 a 0,2 (come il template; nessun token nuovo). Il template rende
   sceglibili solo le persone del primo livello (`.psN[data-capo]`); nell'app un nodo cliente di secondo o terzo livello
   oggi apre il dossier, e con il punto 1 sceglie anch'esso: allora il ramo è il nodo, i suoi legami verso i figli e i
   figli, e il confronto con `ramo` (id del primo livello) non basta più. `DisposizioneAlbero` deve dare a ogni nodo
   l'elenco dei suoi antenati clienti (o il percorso), e «spento» diventa «né il nodo scelto né un suo discendente né
   il legame fra loro». Transizione con `Tema.Apple.Moto.Passaparola.ramo` (0,3 s al ritmo; l'`enum Passaparola` del
   moto esiste già in `Tema.Apple+Potenziali.swift:234`); con «Riduci movimento» subito.
3. **La card «Il ramo di».** Nuova `RamoPassaparolaCard: View` in `ClientiPassaparola.swift`, mostrata al posto di
   `AmbasciatoriCard` quando `evidenziato != nil` (la card degli ambasciatori torna con «Tutti»):
   - testata: `AvatarCliente` 42, occhiello «IL RAMO DI», nome (19 bold, token nuovo `P.nomeRamo`), pulsante
     `.appleSobrio` «Tutti» (`evidenziato = nil`);
   - la frase da una funzione nuova `TestiPassaparola.ramo(nome:clienti:valoreClienti:potenziali:)` con le cifre del
     nodo (i figli già nell'albero: `NodoPassaparola.figli`, il loro `patrimonio` e `fase`); il valore dei già clienti
     è la somma dei patrimoni netti dei figli clienti (lo stesso `portato` di `Ambasciatore`), mai sommato alle stime
     dei potenziali (decisione 95);
   - l'elenco dei presentati: nome, capsula «Cliente» (verde) o «Potenziale» (neutra) — per i potenziali anche la
     fase in piccolo —, cifra (patrimonio o stima; «—» se non nota);
   - pulsanti: «Apri il dossier» sempre (`stato.clienteAttivoId = id`, scheda `.panoramica`, `vistaClienti = .rubrica`)
     e il primario secondo la decisione 48-a.
   - Se la persona scelta non ha presentato nessuno: «{nome} non ti ha ancora presentato nessuno.».
   Il nodo e i figli si cercano nell'albero già calcolato (passato alla card): nessun motore in più.
4. **«Ringrazia».** Nuovo `TipoOccasioneMessaggio.ringraziamentoPresentazione` **in fondo all'enum** (un Prisma di
   prima lo salta con `ElencoTollerante`), non commerciale, con il modello in `ModelliMessaggi` (tre toni, come gli
   altri): un grazie per la fiducia e per aver parlato di te, **senza i nomi delle persone presentate e senza cifre**
   (sono dati di terzi). In `Shell/StatoPotenziali.swift` (estensione di `StatoShell`)
   `preparaRingraziamento(clienteId:)` come `preparaRichiestaPresentazione` (:159: crea l'occasione, mette
   `vistaMessaggi = .messaggi` e prepara la bozza; non spedisce). Il template invece resta sul passaparola, cambia il
   pulsante in «✓ Messaggio pronto» e lo dice con l'avviso: se `preparaMessaggio(occasione:)` porta via dalla vista,
   per il ringraziamento preparare la bozza senza cambiare app (come le campagne) e lasciare l'avviso; «✓ Messaggio pronto» solo quando il messaggio esiste (come
   `richiestaPreparata`). L'avviso: «Per {nome}: un grazie per le persone che ti ha presentato. Lo trovi in Messaggi».
5. **La nota sotto l'albero.** `TestiPassaparola.notaAlbero` + « Tocca una persona per vedere il suo ramo.».
6. **Prestazioni (da sistemare insieme).** Il body di `VistaPassaparola` rifà oggi i motori su tutto l'archivio a ogni
   ridisegno: contro la regola del 12 novembre. Portare albero, ambasciatori, quota e nuovi per anno in
   `stato.ricavato("passaparola") { … }` (un valore `Equatable` con i quattro risultati). Il momento giusto legge le
   pratiche (escluse da `stessiCalcoli`): nella chiave va la versione delle pratiche, come dice CLAUDE.md. La scelta
   della persona deve ridisegnare solo l'albero e la colonna di destra (come oggi con `evidenziato` in
   `StatoPotenziali`).

### 48.4 Dati, archivio, privacy

Nessun campo nuovo. Un caso nuovo di `TipoOccasioneMessaggio` (valore salvato nei messaggi del cliente, quindi nel suo
file, nei backup e in «Prisma ovunque» come gli altri messaggi): in fondo all'enum, letto in modo tollerante dalle
versioni di prima. Il ringraziamento non nomina mai le persone presentate (dati di terzi) e non contiene cifre.
«Chiedi una presentazione» resta legata alla decisione 17 (vedi 48-a).

### 48.5 Istantanee e prove

- Aggiornare `854-clienti-passaparola` (`-scuro`), `855-…-vuoto`, `856-…-fittizi`, `857-…-calmo`: la nota nuova.
- Nuove: `1148-uso-passaparola-ramo` (un ambasciatore scelto: albero attenuato e card «Il ramo di») e `-scuro`;
  `1149-uso-passaparola-ramo-vuoto` (un cliente che non ha presentato nessuno). Serve un modo di scegliere la persona
  nella scena: `s.potenziali.evidenziato = "<id>"` prima di aprire.
- `--prova-calcoli`: in `ProvaCalcoliPassaparola` la frase del ramo (singolari e plurali, nessun cliente, valore senza
  stime dei potenziali) e il modello del ringraziamento: nessun nome dei presentati, nessuna cifra, in tutti e tre i
  toni.
- `--prova-backup`: un messaggio `ringraziamentoPresentazione` va e torna dal backup; un archivio con questo tipo letto
  come «sconosciuto» non perde gli altri messaggi (c'è già la prova `ElencoTollerante` per i tipi nuovi: aggiungere il
  caso).

### 48.6 Decisioni per l'utente e rischi

- **48-a «Chiedi una presentazione».** Il template la offre a chiunque non abbia presentato nessuno; la decisione 17
  vuole la richiesta solo dopo un fatto bello (il «momento giusto» di `MotorePassaparola.momentoGiusto`). Proposta: il
  pulsante compare solo se per quella persona c'è un momento giusto in corso (e allora usa
  `preparaRichiestaPresentazione` di oggi); altrimenti nessun pulsante, con la riga «Il momento giusto per chiedere te
  lo dice Prisma, dopo un fatto bello.».
- **48-b Il ringraziamento.** È un tipo di messaggio nuovo (non commerciale, senza nomi né cifre). Proposta: sì, con il
  testo dei tre toni da far vedere all'utente prima dell'unione.
- **48-c Il clic sul nodo.** Oggi apre il dossier; con la miglioria sceglie il ramo. Proposta: seguire il template, con
  «Apri il dossier» nella card e ⌘-clic per chi va di fretta.
- Rischio: i motori nel body (punto 6) con i 30 clienti fittizi sono già visibili nella prova di fluidità; con la scelta
  della persona i ridisegni aumentano. Va fatto insieme.

### 48.7 Dimensione

M. File: `Shell/ClientiPassaparola.swift`, `Shell/StatoPotenziali.swift`, `Motori/TestiPassaparola.swift`,
`Motori/ModelliMessaggi.swift`, `Dati/MessaggioCliente.swift`, `DesignSystem/Apple/Tema.Apple+Potenziali.swift`,
`Shell/IstantaneeClientiLuce.swift`, `Motori/ProvaCalcoliPassaparola.swift`, la prova dei backup.

---

## 49. La campagna in tre passi

### 49.1 Nel template

Righe 4541-4559: la nuova `campDett` al posto di quella della base (righe 2477-2483) e una ridefinizione di
`montaCamp` (riga 4559). Si apre con `scegliCli(null,1); vistaM='camp'; campI=0; vaiM('messaggi')`; il cartellino indica
`#cmP`.

Il pannello di destra della campagna (la mappa a sinistra non cambia):
- occhiello «Campagna» nel colore del gruppo, titolo del gruppo (22 bold);
- **1 · Chi** (riga `.cmPa`: tondino numerato 20 nel colore del gruppo, «Chi» in neretto, in grigio «{q} di {N} clienti
  con questo bisogno»), poi l'elenco: per ogni cliente una casella da spuntare (`.cmCk`, 18, raggio 6, piena
  d'accento con la spunta quando scelta), avatar 26, nome, a destra lo stato («✓ pronto in Messaggi» dopo). Un tocco
  sulla riga toglie o rimette il cliente. I clienti di prova sono una riga sola «altri {n} clienti di prova» con la sua
  casella;
- **2 · Cosa scrivi** («a ognuno il suo nome e il suo dato»): una tile con «Anteprima per {nome}» (il primo cliente
  scelto) e il testo («Ciao {nome}, guardando il tuo piano ho notato una cosa che vale la pena sistemare insieme: {il
  bisogno}. Ti va di vederci 30 minuti?»); senza clienti con il nome «Scegli almeno un cliente con il nome.»;
- **3 · Quando** («gli orari che proponi»): le capsule degli orari; quelle scelte sono piene d'accento con il testo
  bianco (`.chip.on3`), le altre normali; un tocco le accende o le spegne (all'inizio tre su quattro accese);
- in fondo, a tutta larghezza, il pulsante: «Prepara {N} messaggi» / «Prepara il messaggio» (primario) oppure, spento,
  «Scegli almeno un cliente» / «Scegli almeno un orario»; sotto, centrato, «Niente parte da solo: li rileggi e li
  spedisci tu, da Messaggi.»;
- al tocco: il pulsante dice «Preparo…», le righe una dopo l'altra (320 ms) diventano «✓ pronto in Messaggi» in verde
  con un lampo verde sul fondo, poi l'avviso «{N} messaggi preparati: sono in Messaggi, da rileggere» e il pulsante
  diventa «Apri i messaggi preparati» (apre Messaggi sul primo); le caselle e gli orari non si toccano più;
- `montaCamp`: se c'è un cliente scelto, la campagna che si apre è quella del gruppo che lo contiene.

### 49.2 Nell'app oggi

- `Sources/Prisma/Shell/MessaggiCampagne.swift`: `VistaCampagne` (:35), `MappaCampagne` (:104, un `Canvas`),
  `PannelloCampagna` (:301). Il pannello ha già quasi tutto, ma in un altro ordine e con altre parole: occhiello
  «CAMPAGNA», titolo, sottotitolo «{n} clienti · Marco, Giulia e altri», la nota dei non valutati; i segmentati
  **tono** e **canale**; l'anteprima (`anteprima`, :381) del primo incluso o di quello scelto con «vedi»; le capsule
  degli orari (`chip`, :398) con l'etichetta `TestiCampagne.appuntamenti` («Appuntamenti da proporre»): tutte accese
  di base e **barrate** quando si tolgono (`campagne.chipTolti`); le righe dei membri (`RigaMembroCampagna`, :530) con
  inclusione, consenso (decisione 16: senza consenso serve la conferma), recapito, stato della bozza, «Fai riscrivere a
  Vera», «Apri in Mail»; il piede (:426) con la firma da scegliere per i canali misti, la nota
  `TestiCampagne.notaPulsante` e **«Avvia la campagna»** (`stato.avviaCampagna`: crea le bozze, decisione 15, niente si
  apre da solo); dopo l'avvio «Apri la prossima», «Apri tutte» (conferma oltre 5), «Annulla la campagna».
- Le azioni stanno in `Shell/CampagneMessaggi.swift` (estensione di `StatoShell`: `gruppiCampagne()` in cache,
  gli orari liberi, `avviaCampagna` :43, le aperture e l'annullamento). L'avviso di oggi dopo l'avvio è
  `TestiCampagne.toastPronte` (`MotoreCampagne.swift:410`: «{n} bozze pronte in Messaggi: le spedisci tu»).
- Testi in `TestiCampagne` (`Motori/MotoreCampagne.swift:309`) e motore in `Motori/MotoreCampagne.swift`, token
  `Tema.Apple.Campagne` (in `Tema.Apple+Potenziali.swift`). Stato in `stato.campagne` (gruppo, tono, canale,
  chipTolti, avviata, anteprima, conferma).
- **Manca**: i tre passi numerati, la casella visibile, le capsule accese/spente al posto del barrato, il pulsante che
  dice quanti messaggi prepara e perché è spento, la frase «Niente parte da solo…», «Apri i messaggi preparati», la
  preselezione del gruppo del cliente.

### 49.3 Cosa fare

1. **Riordinare `PannelloCampagna` in tre passi**, senza togliere nulla di ciò che c'è:
   - testata come oggi (occhiello, titolo; il sottotitolo con i nomi sparisce: lo dice il passo 1);
   - nuovo `PassoCampagna: View` (tondino numerato 20 nel colore del gruppo con la cifra bianca 11,5 bold, titolo
     neretto 14, sottotitolo grigio) — token `C.passoTondino` (20), `C.passoCifra`, `C.passoTitolo`,
     `C.passoSottotitolo`, `C.spazioPassi` (14);
   - **1 · Chi** «{q} di {N} clienti con questo bisogno», poi le `RigaMembroCampagna` di oggi con, in testa, la
     casella (`CasellaSpunta`: componente del tema se c'è, altrimenti nuovo in DesignSystem, 18 × 18, raggio 6, bordo
     1,6 `inchiostro3`, piena d'accento con la spunta). Tutta la riga è il pulsante che include o esclude (`cambia`);
     consenso, recapito, stato e azioni di Vera restano a destra come oggi. Con molti membri (clienti fittizi) le prime
     `C.righeVisibili` (8) e poi una riga «e altri {n} clienti» che si apre («Mostra tutti»); i clienti di prova non
     diventano una riga sola (l'app li tratta come gli altri);
   - **2 · Cosa scrivi** «a ognuno il suo nome e il suo dato»: i segmentati tono e canale su una riga (con le parole
     della miglioria 26: «Tono», «Invia con»), poi l'anteprima di oggi con l'intestazione «Anteprima per {nome}»;
     senza inclusi «Scegli almeno un cliente.»;
   - **3 · Quando** «gli orari che proponi»: le capsule di oggi, ma **accese** (fondo accento, testo bianco: token
     `C.fondoChipScelto`, `C.testoChipScelto`) o **spente** (fondo `C.fondoChip`), niente barrato. Lo stato resta
     `chipTolti` (tutte accese di base, come oggi). Con l'agenda piena il testo di oggi
     (`TestiCampagne.agendaPiena`) e il passo non chiede orari.
2. **Il pulsante a tutta larghezza.** Al posto di «Avvia la campagna»: `.applePrimarioGrande` a tutta larghezza con
   `TestiCampagne.prepara(n)`: «Prepara il messaggio» / «Prepara {n} messaggi»; spento con «Scegli almeno un cliente»
   (nessun incluso), «Scegli almeno un orario» (orari disponibili ma tutti spenti), «Scegli la firma» (canali misti
   senza firma). Sotto, centrata, «Niente parte da solo: li rileggi e li spedisci tu, da Messaggi.» (sostituisce
   `notaPulsante`; i conteggi «senza consenso» e «senza recapito» restano come nota piccola sopra il pulsante quando
   servono). L'azione resta `stato.avviaCampagna` (crea le bozze, decisione 15).
3. **Dopo.** Le righe incluse mostrano «✓ pronto in Messaggi» (verde, `C.pronta`) con un lampo verde sul fondo, una
   dopo l'altra (`Tema.Apple.Moto.Campagne.pronta`, ritardo `ritardoPrisma`, al ritmo; con «Riduci movimento» e nelle
   istantanee tutte subito). Avviso «{n} messaggi preparati: sono in Messaggi, da rileggere» (aggiornare
   `TestiCampagne.toastPronte`). Il pulsante diventa «Apri i messaggi preparati»: `stato.vistaMessaggi = .messaggi` e
   la prima bozza scelta (la funzione che oggi apre una bozza in Messaggi, non in Mail). Sotto, sobri, «Apri la
   prossima in {Mail | Messaggi}», «Apri tutte» e «Annulla la campagna» (finché nessuna è aperta) come oggi. Caselle e
   orari non si toccano più (come oggi `modificabile && campagnaAvviata == nil`).
4. **Il gruppo del cliente.** In `VistaCampagne`, alla comparsa: se il cliente della barra (miglioria 2 del gruppo 01;
   oggi `stato.clienteAttivoId` solo se scelto esplicitamente) è membro di un gruppo e `campagne.gruppo` è vuoto,
   scegliere quel gruppo. La mappa continua a mostrare tutti i clienti (decisione 50 di «Luce»).
5. Testi nuovi in `TestiCampagne`: `passoChi`, `contoChi(q:n:)`, `passoCosa`, `sottoCosa`, `passoQuando`,
   `sottoQuando`, `prepara(_:)`, `scegliCliente`, `scegliOrario`, `scegliFirma`, `nienteParte`, `apriPreparati`,
   `prontoInMessaggi`, `altriClienti(_:)`.

### 49.4 Dati, archivio, privacy

Nessun campo nuovo: lo storico delle campagne (`relazione.json`, «Prisma ovunque») resta com'è. Niente parte da solo
(decisione 15); consenso commerciale (decisione 16) e recapito restano controllati riga per riga.

### 49.5 Istantanee e prove

- Aggiornare `862-messaggi-campagne` (`-scuro`), `863-…-btp`, `864-…-avviata` (`-scuro`), `865-…-consenso`, `866-…-vuoto`,
  `867-…-vera-non-pronta`, `868-…-fittizi`, `869-messaggi-testata-campagne` (`Shell/IstantaneeCampagne.swift`).
- Nuove: `1150-uso-campagna-orario-spento` (un orario spento: la capsula non accesa); `1151-uso-campagna-nessun-cliente`
  (tutti esclusi: pulsante spento «Scegli almeno un cliente»).
- `--prova-calcoli`: in `ProvaCalcoliCampagne` i testi del pulsante (singolare, plurale, spento per cliente, orario,
  firma).

### 49.6 Decisioni per l'utente e rischi

- **49-a Tono e canale.** Il template non li mostra nel pannello; l'app li ha (e la miglioria 26 li rinomina).
  Proposta: tenerli dentro il passo 2.
- **49-b Gli orari di partenza.** Il template accende tre orari su quattro; l'app li accende tutti. Proposta: tutti
  accesi (sono già spazi liberi veri dell'agenda).
- Rischio: il pannello è uno `ScrollView` con tutte le righe; con 30 clienti fittizi in un gruppo l'elenco va tagliato
  a 8 righe con «Mostra tutti», altrimenti il pulsante finisce lontano.

### 49.7 Dimensione

M. File: `Shell/MessaggiCampagne.swift`, `Shell/CampagneMessaggi.swift` (se l'apertura dei preparati in Messaggi o il
lampo delle righe chiedono una funzione nuova), `Motori/MotoreCampagne.swift` (`TestiCampagne`),
`DesignSystem/Apple/Tema.Apple+Potenziali.swift` (`Tema.Apple.Campagne`), un eventuale componente `CasellaSpunta` in
DesignSystem, `Shell/IstantaneeCampagne.swift`, `Motori/ProvaCalcoliCampagne.swift`.

---

## 50. Il mese a tutta larghezza

### 50.1 Nel template

Righe 4561-4589: `MESE_EV`, `MESE_SC` (dimostrativi), `meseEvDi`, `meseScDi`, `meseGiornoHTML` (4571), `meseHTML`
(4578), `montaMese` (4583) e la ridefinizione di `APPS.agenda` (4587-4589), che aggiunge «Mese» al selettore della
miglioria 18 (riga 3715: «Giorno | Settimana | Mese»). CSS a righe 721-737. Si apre con `vaiCli(null,'agenda',
vistaAg='mese', meseSel=2)`; il cartellino indica `#mese`.

- **Niente calendario piccolo accanto**: la griglia prende tutta la larghezza meno la colonna del giorno (304 di
  larghezza, 14 di distanza: la griglia finisce a `right: 318px`).
- Testata della griglia (alta 26): «LUN … DOM» (11,5, semibold, maiuscolo, spaziatura 0,5, `--ink2`).
- **La griglia**: 7 × 6 celle con 6 di spazio; ogni cella è una card (raggio 14, fondo `--card`, filo `--sep`, padding
  7 × 8); sabato e domenica con il fondo `--panel`; i giorni fuori dal mese senza fondo né bordo, in `--ink3`; il
  numero in un tondo 22 (oggi rosso pieno con il numero bianco); il giorno scelto con un anello d'accento di 2;
  passaggio del puntatore: fondo `--cardE`.
- In ogni cella **fino a due impegni con l'ora** (`.mEv`: 11,5 semibold, filo sinistro di 3 nel colore del cliente,
  fondo nel colore al 13%, raggio 5, una riga con i puntini): «09:30 Marco» (l'ora in peso normale `--ink2`, poi il
  nome breve del cliente o il titolo senza cliente); se nel giorno c'è una scadenza, un impegno solo; **le scadenze
  hanno il loro segno** (`.mSc`: pallino arancio 6 e il testo in `--orangeT` 11,5 semibold: «Scade il Piano di risparmio
  rivalutabile», «F24 del mese»); poi «+{n} altro / altri» (11, `--ink2`).
- **Il giorno toccato si apre a destra** (`#mGiorno`, card senza ombra, padding 18 × 20; entrata 260 ms da destra di 8
  punti con l'opacità da 0,4):
  - occhiello «Oggi» (rosso) o «Novembre 2026», titolo «{lunedì} {2} novembre», sotto «{n} impegni · {n} scadenze ·
    solo {nome}» (oppure «nessun impegno»);
  - le righe (`.mRiga`: filo sinistro 3 nel colore, fondo `--chip`, raggio 4/10): l'ora in neretto (44), il titolo in
    neretto e sotto il cliente o «Per te», a destra «›» se si apre; le scadenze con «Scade» in arancio al posto
    dell'ora;
  - giorno vuoto: «Giornata libera{ per Marco}.» e sotto «È un buon posto per un impegno nuovo.»;
  - pulsanti: «Apri il giorno» (primario, porta alla vista «Giorno» su quel giorno) e «＋ Impegno» («Nuovo impegno» si
    apre già su quel giorno);
  - in fondo, sopra un filo: la legenda «▪ impegno» (quadratino accento) e «● scadenza» (pallino arancio), e con un
    cliente scelto il collegamento «Tutti i clienti».
- Clic su una riga: la scheda dell'impegno (`apriEv`); doppio clic su una cella: la vista «Giorno» su quel giorno.
- **Segue il cliente scelto**: con un cliente solo i suoi impegni e le sue scadenze.

### 50.2 Nell'app oggi

- `Sources/Prisma/Shell/AppAgenda.swift`: `AppAgenda` (:13), selettore a pillola `rigaBarra` (:206) con «Mese |
  Settimana | Giorno | Occasioni»; `vistaMese` (:288): `MeseAgenda` a sinistra e a destra `ParteAgenda { colonnaMese }`
  larga `Misure.AgendaImpaginazione.dettaglio(width)` = **il 42% della finestra** (tra 320 e 580,
  `DesignSystem/MisureAgendaIncontri.swift:13-15`): è il «metà finestra» di cui parla il template. `colonnaMese` (:446)
  mostra `paginaGiorno` (:479: appuntamenti, rimaste indietro, da fare, in scadenza, occasioni) o il dettaglio della
  riga scelta (`vistaScelta`, con «‹ {data}» per tornare).
- `Sources/Prisma/Shell/AgendaMese.swift`: `MeseAgenda` (:68, `Equatable`), `CellaGiornoMese` (:147): numero (oggi nel
  cerchio rosso), segni del giorno (riesami, scadenze **come un numero in un segno**, :226), pillole degli appuntamenti
  (`PillolaAppuntamento`, :284: barretta e fondo **del canale**, ora e **titolo** dell'appuntamento), tante quante ne
  stanno (al massimo tre, poi «+N»), con il puntino se la cella è troppo bassa. Nei segni c'è anche quello delle
  **attività da fare** (arancio, o scadute: :224), che il template non mostra. Token in `Tema.Apple.Agenda.Mese`
  (`Tema.Apple+Agenda.swift:133`), `Misure.AgendaMese` (**in `DesignSystem/TemaAgendaMese.swift`**, non in
  `MisureAgendaIncontri.swift`) e colori `Colori.Agenda` (`DesignSystem/Colori.swift:607`).
- Sopra il calendario c'è la striscia «Riesami del mese» (`StrisciaRiesami`, `AppAgenda.swift:40-46`): il commento
  del template per la 50 dice che nel mese «non c'è (regola 18)»; la toglie la miglioria 18 del gruppo 03 (punto 7)
  quando c'è il «Da fare» unico della 3: questa miglioria non la tocca.
- La colonna del mese serve anche a chi apre un appuntamento da notifiche e ricerca (`Shell/Ricerca.swift:719`:
  mette `giornoAgenda` e `appuntamentoSelezionato` senza cambiare vista, gruppo 03 punto 4): la colonna nuova deve
  continuare a mostrare l'appuntamento scelto (`vistaScelta`).
- Il filtro: `stato.filtroClienteAgenda` (tendina nella barra).
- Il gruppo 03 (miglioria 18) riordina il selettore in «Giorno | Settimana | Mese» e lascia «Mese» com'è in attesa di
  questa miglioria.
- **Manca**: la colonna del giorno stretta e fissa, il nome del cliente nelle pillole, le scadenze scritte, il limite di
  due impegni, il doppio clic, «Apri il giorno», «＋ Impegno» nella colonna, la legenda, «Giornata libera».

### 50.3 Cosa fare

1. **La colonna del giorno stretta.** In `vistaMese` la colonna diventa fissa: `Misure.AgendaMese.colonnaGiorno`
   (304) con `Misure.AgendaMese.spazioColonna` (14); la griglia prende il resto. Sotto `Misure.AgendaImpaginazione.paginaMinima`
   la colonna si stringe fino a `colonnaGiornoMinima` (260) prima di comprimere la griglia. La colonna è una card
   piatta (superficie del tema senza ombra, padding 18 × 20), non più il fondo `dettaglioFondo` con il filo.
2. **Le celle** (`CellaGiornoMese`, `PillolaAppuntamento`):
   - massimo **due** pillole (`Misure.AgendaMese.pilloleMassime = 2`, in `TemaAgendaMese.swift`; una sola se nel
     giorno c'è una scadenza), poi
     «+{n} altro / altri» (testo, non solo «+N»);
   - la pillola: ora (peso normale, `inchiostro2`) e **il nome breve del cliente** (`StatoShell.nomeBreve`), il titolo
     solo senza cliente; colore: **resta quello del canale** (Alleanza blu, indipendente cuoio, la regola dei canali
     sempre riconoscibili; il template usa il colore del cliente — decisione 50-a);
   - le scadenze: una riga per scadenza con il pallino arancio (`Tema.Apple.Agenda.Segno.scadenza`) e il testo
     arancio scuro (titolo breve della posizione in scadenza, «Scade {nome posizione}»), al posto del numero nel segno;
     i riesami e le attività da fare tengono il loro segno di oggi (il template non li ha, ma toglierli farebbe perdere
     un'informazione: vedi 50-b);
   - sabato e domenica con il fondo `Colori.Agenda.festivo` (nuovo token, `Tema.Apple.Colore.pannello`); i giorni
     fuori mese senza fondo né bordo; il giorno scelto con l'anello d'accento 2 (`Misure.AgendaMese.anelloScelto`);
   - **doppio clic** su una cella: `stato.giornoAgenda = giorno; stato.vistaAgenda = .giorno` (`onTapGesture(count: 2)`
     prima di quello singolo, come nella settimana della 18).
3. **La colonna del giorno** (riscrivere `colonnaMese` per la sola vista mese, senza toccare `paginaGiorno` della vista
   «Giorno»):
   - occhiello «OGGI» in rosso o «{MESE ANNO}», titolo «{lunedì 2 novembre}», sotto il conteggio «{n} impegni ·
     {n} scadenze · solo {nome}» (con il filtro) oppure «nessun impegno»;
   - le righe degli appuntamenti (`RigaEventoAgenda` di oggi, :908, nello stile `.mRiga`: filo del canale, fondo chip,
     ora in neretto 44, titolo in neretto, sotto il cliente o «Per te», «›»): il clic apre la scheda dell'impegno
     (`seleziona` / `vistaScelta`, come oggi);
   - le scadenze (`RigaScadenzaAgenda`, :983) con «Scade» in arancio al posto dell'ora;
   - le attività del giorno e le occasioni restano sotto, più piccole (decisione 50-b), oppure diventano il «Da fare»
     della miglioria 3 (gruppo 01) quando c'è;
   - vuoto: «Giornata libera.» (con il filtro «Giornata libera per {nome}.») e «È un buon posto per un impegno nuovo.»;
   - pulsanti: «Apri il giorno» (`.applePrimario`, porta alla vista «Giorno») e «＋ Impegno» (`.apple`,
     `nuovoAppuntamento()` già sul giorno scelto);
   - in fondo, sopra un filo, la legenda («impegno» con il quadratino nel colore del canale… meglio due quadratini,
     Alleanza e indipendente, vedi 50-a; «scadenza» con il pallino arancio) e, con il filtro, «Tutti i clienti»
     (`filtroClienteAgenda = nil`, o `scegliCliente(nil)` della miglioria 2).
   - cambio di giorno: la colonna entra da destra di 8 punti con l'opacità da 0,4 (`Tema.Apple.Moto.Agenda.giornoMese`,
     al ritmo; con «Riduci movimento» una dissolvenza di 0,15 s).
4. **Prestazioni.** `MeseAgenda` resta `Equatable` con l'indice dei giorni calcolato una volta (`indiceGiorni`); il nome
   breve del cliente si legge da un dizionario id → nome preparato una volta per disegno (o da `CacheClienti`), non con
   `stato.cliente(id)` per ogni pillola.

### 50.4 Dati, archivio, privacy

Nessun campo nuovo.

### 50.5 Istantanee e prove

- Aggiornare `12-agenda-mese-scadenza`, `124-agenda-riesami-mese` (`-scuro`), `132-agenda-occasioni-mese-scuro`,
  `238-agenda-finestra-stretta` e le scene in `Shell/IstantaneeAgendaApple.swift` che aprono il mese (la vista
  predefinita, se la 18 non l'ha già cambiata in «Settimana»).
- Nuove: `1152-uso-agenda-mese` (mese di novembre con tutti i clienti, oggi scelto) e `-scuro`;
  `1153-uso-agenda-mese-cliente` (filtro su Marco: «solo Marco», «Tutti i clienti»); `1154-uso-agenda-mese-giorno-libero`
  (un giorno senza impegni: «Giornata libera»).
- Prove: `ProvaRiesamiAgenda` (`Shell/ProvaRiesamiAgenda.swift`) se legge la vista mese; `--prova-fluidita` per il
  mese con i 30 clienti fittizi.

### 50.6 Decisioni per l'utente e rischi

- **50-a Il colore delle pillole.** Il template colora gli impegni con il colore del cliente; CLAUDE.md vuole il canale
  sempre riconoscibile e oggi le pillole sono nel colore del canale. Proposta: restano nel colore del canale, con il
  nome del cliente al posto del titolo.
- **50-b Attività e occasioni nella colonna.** Il template mostra solo impegni e scadenze. Proposta: le attività del
  giorno restano sotto, in piccolo, finché la miglioria 3 non porta il «Da fare» unico; le occasioni restano nella vista
  «Occasioni» (dalla 18, il pulsante «Occasioni»). Nelle celle i segni delle attività e dei riesami restano.
- Rischio: le celle con due pillole e le scadenze scritte devono stare in una finestra bassa (13"): sotto una certa
  altezza una pillola sola, poi il puntino di oggi.

### 50.7 Dimensione

M. File: `Shell/AppAgenda.swift`, `Shell/AgendaMese.swift`, `DesignSystem/TemaAgendaMese.swift` (`Misure.AgendaMese`),
`DesignSystem/MisureAgendaIncontri.swift` (`AgendaImpaginazione`, solo se serve),
`DesignSystem/Apple/Tema.Apple+Agenda.swift`, i colori `Colori.Agenda` (`DesignSystem/Colori.swift`), `Istantanee.swift`,
`Shell/IstantaneeAgendaApple.swift`.

---

## 51. Il giro di domani si porta in tasca

### 51.1 Nel template

Righe 4591-4606: `GIRO_PORTA` (dimostrativo), `giroInv` e la ridefinizione di `terDisegna` (base a riga 2163, «Il giro»
a riga 2177, «La crescita» a riga 2170). Si apre con `vaiCli(null,'territorio', terM='giro')`; il cartellino indica
`#giroTel`.

**Il giro di domani:**
- ogni tappa con un cliente diventa toccabile (puntatore a mano, suggerimento «Prepara l'incontro») e sotto il motivo
  dice **cosa portare** (11,5, accento): «Da portare: il fascicolo sulla pensione a 60 anni», «Da portare: informativa
  privacy e adeguata verifica», «Da portare: il modulo del consenso da firmare»;
- il tocco su una tappa **apre la preparazione dell'incontro**: il dossier del cliente su Incontri, momento «Prima»
  (`vaiCli(k,'incontri', incPasso='prima')`);
- la tappa aggiunta da «Lungo la strada» (Sofia) ha accanto il collegamento «Togli»: la toglie dal giro, con l'avviso
  «Sofia tolta dal giro» (e il suggerimento torna);
- in fondo al pannello **un pulsante solo**, a tutta larghezza: «Manda il giro all'iPhone» (primario); dopo il tocco
  «✓ Il giro è sull'iPhone» (non più primario) e l'avviso «Il giro di domani è sull'iPhone: si apre in Mappe»; sotto,
  centrato, «Si apre in Mappe, una tappa dopo l'altra. Tocca una tappa per prepararla.» (12).

**La crescita:**
- sotto il cursore degli anni le tre date «2016 · 2021 · 2026» (11,5, agli estremi e al centro);
- sotto «▶︎ Guarda la crescita» una tile (`#tChi`, 13,5): «Hanno cominciato nel {anno}» (grigio) e «**{n} famiglie**:
  {nomi}{ e altre n}» oppure «**Nessuna famiglia nuova**»; si aggiorna a ogni anno, anche durante «Guarda la crescita».

### 51.2 Nell'app oggi

- `Sources/Prisma/Shell/PannelloTerritorio.swift`: `PannelloGiro` (:315): testata «IL GIRO DI DOMANI · {GIORNO}» con
  le frecce, titolo, «circa {durata} in auto · stima in linea d'aria», partenza o «Aggiungi l'indirizzo dello
  studio…», le tappe (`riga`, :454: ora, avatar, nome, motivo, «✓ Conferma in Agenda» per le tappe proposte, «{n} min
  ›»), **il clic su una tappa apre l'appuntamento in Agenda** (`stato.apriAppuntamentoInAgenda`, :488), «Lungo la
  strada» con «＋ Aggiungi {nome} al giro» e «Scrivi a {nome}», gli altri suggerimenti. **Non c'è** un modo di togliere
  la tappa aggiunta (solo confermarla in Agenda, `confermaAppuntamento`), **non c'è** «cosa portare», **non c'è**
  l'invio all'iPhone.
- `PannelloCrescita` (:221): anno grande, clienti e patrimonio contati, `CursoreApple` degli anni, «▶︎ Guarda la
  crescita» (`t.avviaCrescita`, senza Timer), «Ogni luce che si accende è una famiglia che ha cominciato con te.», la
  nota dei clienti con l'anno stimato. **Manca** chi ha cominciato nell'anno; il dato c'è già:
  `AnnoCrescita.nuovi` (`Motori/MotoreTerritorio.swift:113`, gli id dei clienti che cominciano quell'anno; il primo anno
  comprende anche quelli di prima).
- Stato e azioni: `Shell/StatoTerritorio.swift` (`aggiungiAlGiro` :222, che crea un appuntamento `daConfermare: true`
  con `territorio.rigaNuovaId`; `confermaAppuntamento` :237; `apriAppuntamentoInAgenda` :243).
- **Le cose da portare esistono già** nel lavoro della notte: `Motori/MotoreNotte.swift:247-266` («la borsa»:
  fascicolo preparato, moduli da firmare compatibili, documento d'identità da rinnovare), testi in
  `Motori/TestiNotte.swift:230-241` (`notaBorsa` «Da portare: », `borsaFascicolo`, `borsaModuli(_:)`,
  `borsaDocumento`), ma solo come carta della notte.
- Privacy del Territorio (`.github/workflows/build.yml:105-111`, decisioni 20 e 21 di «Luce»): nei file
  `*Territorio*` niente rete, geocodifica, percorsi, MapKit o CoreLocation.

### 51.3 Cosa fare

1. **Cosa portare.** Estrarre «la borsa» da `MotoreNotte` in una funzione pura riusabile, per esempio
   `Motori/MotoreBorsa.swift`: `static func cose(per appuntamenti: [Appuntamento], dati: DatiPrisma, oggi: Date) -> [String: [String]]`
   (id appuntamento → cose), con le stesse regole di oggi (fascicolo preparato per quell'appuntamento, moduli da
   firmare del cliente, documento d'identità da rinnovare). `MotoreNotte` la chiama al posto del codice di oggi (stessi
   risultati: la prova della notte lo verifica). Nel giro: `stato.ricavato("borsa-giro-\(giorno)") { … }` sugli
   appuntamenti del giorno; nella riga della tappa, sotto il motivo, «Da portare: {cose unite con la virgola}»
   (`TestiNotte.notaBorsa`, 11,5, accento: token `G.daPortare`, `G.coloreDaPortare`); senza cose nessuna riga (mai
   «niente di particolare» nel giro).
2. **La tappa apre la preparazione.** Il clic su una tappa con un cliente: `stato.apriIncontro(per: appuntamento)`,
   suggerimento «Prepara l'incontro». La funzione **esiste già** (`StatoShell.swift:2138`): mette il cliente, apre
   Incontri sulla scheda `.preparazione` (che con la miglioria 20 del gruppo 03 diventa il momento «Prima», con la
   firma `apriIncontro(per:scheda:)`), quindi non serve aspettare la 20. Attenzione: se l'incontro non c'è, la chiama
   `nuovoIncontro` (:2122), che **crea e salva** un `Incontro` legato all'appuntamento: per una tappa ancora
   `daConfermare` (proposta dal Territorio) non va creato nulla, quindi su quelle il clic resta
   `apriAppuntamentoInAgenda` di oggi (dove si conferma). La conferma in Agenda resta raggiungibile dalla scritta «✓ Conferma in
   Agenda» (diventa un collegamento).
3. **«Togli».** Accanto alle tappe proposte dal Territorio e non ancora confermate (`appuntamento.daConfermare == true`)
   un collegamento `StileCollegamento` «Togli»; azione nuova `stato.togliDalGiro(appuntamentoId)` in
   `StatoTerritorio.swift`: elimina l'appuntamento solo se è ancora `daConfermare` (mai un appuntamento confermato),
   azzera `rigaNuovaId`, avviso «{nome di battesimo} tolto dal giro» (`MotoreTerritorio.nomeBattesimo`: Prisma non
   conosce il genere, come per «Aggiungi»). Il suggerimento «Lungo la strada» torna da solo al ricalcolo del giro.
4. **Il pulsante in fondo.** Dipende dalla decisione 51-a. Proposta:
   - il pulsante «Manda il giro all'iPhone» compare solo con «Prisma ovunque» acceso (`Impostazioni.ovunque`): gli
     appuntamenti del giro (con `presso` e `daConfermare`) sono **già** nell'istantanea cifrata che il Mac scrive; il
     pulsante chiede di scriverla subito: oggi l'istantanea parte al ritmo da `programmaIstantaneaOvunque()`
     (`Shell/StatoOvunque.swift:349`, al massimo una ogni 10 minuti) che chiama `sincronizzaOvunque(automatica:)`;
     il pulsante chiama `sincronizzaOvunque()` (`StatoOvunque.swift:438`, la stessa chiamata di «Unisci ora» in Impostazioni › iPhone e iPad, `ImpostazioniOvunque.swift:580`) solo con
     `impostazioni.ovunque.acceso`, `ruolo == .mac` e la chiave nel Portachiavi, e a scrittura riuscita diventa
     «✓ Il giro è sull'iPhone» (stato in memoria per quel giorno, in `stato.territorio`); se fallisce, l'avviso
     d'errore di «Prisma ovunque» e il pulsante resta;
   - sotto, al posto di «Si apre in Mappe…»: «Sull'iPhone lo trovi in Agenda. Tocca una tappa per prepararla.» (una
     vista del giro sull'iPhone non esiste: appartiene all'aggiornamento di iPhone e iPad, e allora la frase cambierà);
   - **niente Mappe** e niente indirizzi passati ad app di mappe: è vietato dalla privacy del Territorio.
   - Con «Prisma ovunque» spento: nessun pulsante, e una riga piccola «Per averlo sull'iPhone accendi «Prisma ovunque»
     in Impostazioni.» con il collegamento.
5. **La crescita.** In `PannelloCrescita`: sotto il `CursoreApple` tre date (primo anno, anno di mezzo, ultimo anno;
   11,5, `P.coloreTesto2`; token `P.dateCursore`) — solo se gli anni sono almeno tre; sotto «▶︎ Guarda la crescita» una
   tile «Hanno cominciato nel {anno}» (il primo anno: «Hanno cominciato nel {anno} o prima») con «**{n} famiglie**:
   {nomi}» (i nomi di `AnnoCrescita.nuovi` letti dai clienti, al più `P.nomiCrescita` = 4, poi « e altre {n}» /
   « e un'altra») oppure «**Nessuna famiglia nuova**». Si aggiorna con l'anno (`t.annoCrescita`), anche durante
   «Guarda la crescita» (niente `MutationObserver`: è lo stato). «Famiglie» è la parola del template e della frase
   «Ogni luce che si accende è una famiglia…»: i nomi sono quelli dei clienti.

### 51.4 Dati, archivio, privacy

Nessun campo nuovo: le cose da portare si ricavano (fascicolo, moduli, documento), la tappa tolta è un appuntamento
eliminato, «Il giro è sull'iPhone» è stato in memoria. **Punto di privacy (51-a):** il template manda il giro all'iPhone
e lo apre in Mappe; CLAUDE.md e le decisioni 20-21 vietano nel Territorio servizi di mappe e percorsi (controllo
statico nel workflow), e l'unico canale verso l'iPhone ammesso per dati dei clienti è lo spazio cifrato di «Prisma
ovunque» (o il ponte in rete locale). La proposta non aggiunge nessun dato in uscita: usa solo l'istantanea che già
esiste. I file `*Territorio*` non devono importare nulla di «Prisma ovunque» che usi la rete (lo spazio usa file in una
cartella, non la rete: il controllo statico resta verde); meglio chiamare la scrittura da una funzione di `StatoShell`
fuori dai file `*Territorio*`.

### 51.5 Istantanee e prove

- Aggiornare `703-territorio-giro`, `704-territorio-giro-aggiunto` (con «Togli»), `707-territorio-giro-vuoto`,
  `701-territorio-crescita`, `702-territorio-crescita-anno` (`Shell/IstantaneeTerritorio.swift`).
- Nuove: `1155-uso-territorio-giro-borsa` (tappe con «Da portare: …») e `-scuro`; `1156-uso-territorio-giro-iphone`
  (con «Prisma ovunque» acceso finto nella scena e «✓ Il giro è sull'iPhone»); `1157-uso-territorio-crescita-nomi`
  (un anno con i nomi). I dati di prova devono avere almeno un fascicolo o un modulo da firmare per i clienti del giro di
  domani nella data fissa delle istantanee.
- `--prova-calcoli`: `ProvaCalcoliTerritorio` per i nomi dell'anno (primo anno con «o prima», «e un'altra», «e altre
  n»); `ProvaCalcoliNotte` / `ProvaNotte` devono restare uguali dopo l'estrazione di `MotoreBorsa` (aggiungere un caso
  che confronti le due strade).
- `--prova-ovunque`: se il pulsante chiama la scrittura dell'istantanea, un caso che la scrittura forzata con lo spazio
  spento non faccia nulla.
- Workflow: il controllo «Privacy del Territorio» resta verde (nessun `import MapKit`, nessuna rete nei file del
  Territorio).

### 51.6 Decisioni per l'utente e rischi

- **51-a «Manda il giro all'iPhone» e «Si apre in Mappe».** Tocca le regole di privacy (niente servizi di mappe nel
  Territorio; «Prisma ovunque» spento finché l'utente non lo accende). Proposta: il pulsante solo con «Prisma ovunque»
  acceso, che scrive subito l'istantanea cifrata (nessun dato nuovo); niente Mappe. In alternativa: rimandare il
  pulsante all'aggiornamento di iPhone e iPad.
- **51-b Il clic sulla tappa.** Oggi apre l'Agenda; con la miglioria apre la preparazione dell'incontro. Proposta:
  seguire il template subito (con `apriIncontro(per:)` di oggi) per le tappe confermate; le tappe ancora da confermare
  aprono l'Agenda come oggi, perché aprire Incontri creerebbe un incontro su un appuntamento solo proposto.
- Rischio: «la borsa» oggi è calcolata solo di notte; nel giro va in `stato.ricavato` con la chiave del giorno del giro,
  mai nel body. L'estrazione da `MotoreNotte` non deve cambiare le carte della notte (prova). «Togli» elimina un
  appuntamento: solo se `daConfermare`, e l'eliminazione deve passare come le altre in «Prisma ovunque» (l'iPad può
  avere già visto l'appuntamento proposto).

### 51.7 Dimensione

M. File: `Shell/PannelloTerritorio.swift`, `Shell/StatoTerritorio.swift`, `Shell/StatoOvunque.swift` (la funzione
che scrive subito l'istantanea, fuori dai file `*Territorio*`; solo con 51-a approvata), `Motori/MotoreBorsa.swift` (nuovo),
`Motori/MotoreNotte.swift`, `Motori/TestiNotte.swift`, `DesignSystem/Apple/Tema.Apple+Territorio.swift`,
`Shell/IstantaneeTerritorio.swift`, `Motori/ProvaCalcoliTerritorio.swift`, `Motori/ProvaCalcoliNotte.swift`.
