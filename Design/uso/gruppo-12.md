# Gruppo 12 — Le parti che «Luce» non disegnava, seconda metà: prodotti, simula e confronta, note, TFR, fascicolo (migliorie 63, 64, 65, 69, 70)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html (stesse righe). Il codice del gruppo sta alle righe 4986-5195: «63 ·» (4988-5022),
«64 ·» (5024-5064), «65 ·» (5066-5088), il pannello `MIG11b` (5091-5094), «69 ·» (5100-5147), «70 ·» (5149-5189) e il
pannello `MIG11c` (5191-5195). Le regole che dicono come il gruppo si porta nell'app vera sono nel commento grande alle
righe 2890-2938 (63 «Prodotti [23, 32]», 64 «Analisi 360 › Simula e confronta [14, 15, 16]», 65 «Note [60, 61]»,
69 «… › Il TFR [204, 207, 208]», 70 «Prospetti › Fascicolo dell'incontro [81, 82]»: i numeri fra parentesi sono le
istantanee dell'app di oggi che il template ridisegna) e alle righe 2940-2963 («NELL'APP DI OGGI … Analisi 360: … le
quattro voci di oggi (Simulatore, Scenari, Confronto, TFR) diventano una sola, «Simula e confronta»»); il CSS nuovo alle
righe 800-830 (`.tfFr`, `.tfV`, `.tfB`, `.tfC`, `.fs*`). Per tutto ciò che il gruppo non cambia valgono
Design/template-luce.html e Design/template-luce-specifica.md.

Il gruppo non aggiunge funzioni: prende cinque schermate dell'app vera che «Luce» non disegnava e le rende leggibili
davanti al cliente. **Prima la frase, poi le cifre**; meno comandi in vista, nessuno perso (le cose di oggi vanno «a
richiesta»); **un posto solo** per ogni cosa (il catalogo nella Biblioteca, le note nel dossier, gli strumenti di
Analisi 360 in una vista). Grafica, vetro, acqua, logo e colori dei canali restano come sono. **Le cifre le danno i
motori di oggi** (`MotoreProiezione`, `MotoreTFR`, `CompositoreProspetti`): i numeri e le formule del template
(`PRODOTTI`, `CF_AREA`, `cfConto`, `tfConto`, `TFRD`, `PAGP`) sono dimostrativi e non si portano (riga 2963: «di prova
anche … le schede dei prodotti, … i numeri di «Simula e confronta», le retribuzioni e le formule del TFR, le pagine dei
report nel fascicolo»).

Solo del template, da NON portare: il pannello «✦ Migliorie» con `MIG11b`/`MIG11c`, il cartellino arancione di
`indica(...)`, i `toast(...)` che dicono «resta com'è», i dati di prova del template.

## Ordine consigliato

1. **Prima le migliorie da cui il gruppo dipende.**
   - La **2** del gruppo 01 («Un solo posto per scegliere il cliente»): tutte e cinque seguono il cliente scelto nella
     barra (l'elenco dei prodotti «Per <nome>, dal più adatto», le strade di «Simula e confronta», il TFR, le note del
     dossier, il fascicolo). Senza la 2 funzionano lo stesso con `stato.clienteAttivoId`, ma le tendine dei clienti che
     la 2 toglie (in Analisi 360 il secondo selettore, in Prospetti `RigaClienteProspettiApple`) vanno tolte prima.
   - La **4** del gruppo 01 (la riga sola in testa alla finestra): le testate degli strumenti di Analisi 360 e della
     Biblioteca si appoggiano alla stessa riga.
   - La **3** del gruppo 01 (un solo «Da fare»): «Fanne un «Da fare»» della 65 crea un'attività che compare lì.
   - La **35** del gruppo 05 (Biblioteca: prima i documenti del cliente): tocca `AppBiblioteca.swift` e
     `BibliotecaLuce.swift`; la 63 aggiunge il segmentato «Documenti | Prodotti» nella stessa testata. **Fare la 35
     prima.**
   - Le **22, 23, 24** del gruppo 03 (Prospetti: «Per te / Per il cliente», l'elenco a colpo d'occhio con
     `TipoProspetto.inBreve`, tre pulsanti): la 70 usa `inBreve` per la riga «a cosa serve» dei report e il pulsante
     «Mostra al cliente» della 24 / della **1** del gruppo 01. La **20** del gruppo 03 porta «Altro › Prepara il
     fascicolo» nell'Agenda: la 70 lo fa aprire sulla stessa scheda.
   - La **16** del gruppo 02 (un solo avviso sulle stime in Analisi 360) e la **45** del gruppo 08 (i simulatori delle
     aree, prima e dopo): stessi file di Analisi 360 (`RigaVisteAnalisi360`, `Tema.Apple+Strumenti360`); la 64 e la 69
     vanno dopo, e il «Apri il conto della pensione» della 69 apre il simulatore della previdenza com'è dopo la 45.
   - La **17** del gruppo 02 (le priorità in ordine): la 63 dice «Risponde a una priorità di <nome>» con le stesse
     priorità senza doppioni.
   - La **5** del gruppo 01 (il dossier parte dal quadro del cliente): sposta la card «Da ricordare» (`DaRicordareApple`)
     nella colonna di destra della Panoramica; la 65 le fa leggere la nota in evidenza: fare la 5 prima.
   - La **62** del gruppo 11 (il documento si apre in grande): «Apri il suo documento» della 63 apre il documento con la
     stessa funzione della 35/62, non una propria.
2. **65 · Le note stanno con il cliente.** La più indipendente (dossier, nessuna dipendenza da altri strumenti); chiude
   l'app Note sul Mac.
3. **70 · Il fascicolo si compone a vista.** Solo Prospetti e la copertina del report; dopo le 22-24.
4. **63 · I prodotti parlano chiaro.** Dopo la 35. Il pulsante «Confronta con quello che ha» apre per ora il confronto
   di oggi e passa a «Simula e confronta» quando arriva la 64.
5. **64 · Simula e confronta: prima la frase.** Dopo la 63 (le strade «dal catalogo» usano le schede prodotto).
6. **69 · Il TFR: prima la risposta.** Per ultima: è la terza voce del selettore di «Simula e confronta» e ne usa la
   cornice (la colonna di sinistra, la frase a destra, il piede).

**Solo Mac.** iPhone e iPad non cambiano in questo giro: le viste nuove stanno in file `#if os(macOS)` o in rami
`#if os(macOS)`. Le viste condivise con iOS (`SimulatoreIpotesi`, `ScenariSalvati`, `ConfrontoIpotesi`, `SchedaTFR`,
`AppNote`, `AppProdotti`) restano per iOS così come sono; sul Mac non si usano più (o si usano solo i loro pezzi).

---

## 63. I prodotti parlano chiaro

### 63.1 Nel template

Codice righe 4988-5022 (`PRODOTTI`, `adatto`, `prodOrd`, `prodSchedaHTML`, `prodottiHTML`, `montaProdotti` e la
ridefinizione di `APPS.biblioteca`), regola a riga 2890. Si apre con `MIG11b[0]`: `bibV='prod'; prodI=1;
vaiCli(1,'biblioteca')`, cartellino su `#prM`.

**Il catalogo sta nella Biblioteca.** Nella testata della Biblioteca, dopo le azioni di sempre, un segmentato
«**Documenti | Prodotti**» (`A.act`, riga 5020; `bibV`, di base `doc`). Con «Prodotti» la Biblioteca mostra il catalogo
(`prodottiHTML`); con «Documenti» quella di oggi (gruppo 05, miglioria 35). Non c'è più un'app Prodotti a parte.

**La colonna di sinistra** (`.side`, larga 330, `prodottiHTML` riga 5014):
- intestazione (`lbl`): con un cliente scelto «**Per <nome>, dal più adatto**», senza cliente «**I prodotti**»; a destra
  il numero delle schede;
- ordine: con un cliente scelto prima quelle che rispondono a una priorità, poi quelle in linea, poi quelle che rischiano
  più del profilo (a parità, l'ordine del catalogo) (`prodOrd`, riga 5010); senza cliente l'ordine del catalogo;
- ogni riga (`rub prR`): il quadratino 10×10 (raggio 3) nel colore dell'area; il nome in grassetto 13,5 su più righe; sotto
  in piccolo «<Area> · costo <x>% · rischio <n> su 7» (per la protezione solo «Protezione»); se la fonte non è verificata
  «**fonte da verificare**» (arancio scuro, semibold); con un cliente, se non è «in linea», «**risponde a una
  priorità**» (verde) o «**rischia più del profilo**» (rosso); a destra l'etichetta compatta del canale. La riga scelta
  è accesa (`on`).

**La scheda** (`#prM`, `prodSchedaHTML` riga 5011), dall'alto:
1. **Testata.** A sinistra l'occhiello nel colore dell'area «<Area> · <tipo>» (es. «Investimento · gestione separata più
   fondi interni»), il nome (27, bold, tracking −0,6), sotto l'etichetta del canale e, con un cliente scelto, l'esito
   per lui (`st2`): «**Risponde a una priorità di <nome>**» (verde, `ok`), «**In linea con il profilo di <nome>**»
   (neutro) o «**Rischia più del profilo di <nome>**» (rosso, `ko`). A destra la fonte: «**Fonte verificata il <data>**»
   (verde) oppure «**Fonte da verificare: c’è un KID nuovo**» (arancio) con sotto il pulsante «**Segna verificata
   oggi**», che la segna e mostra «Fonte segnata come verificata oggi».
2. **«In una frase»** (`card`, padding 16×20): l'occhiello e la frase in 19 semibold, interlinea 1,4 («Una parte dei
   soldi sta al riparo in gestione separata, l’altra segue i mercati: le proporzioni le scegli tu.»).
3. **«È per» / «Non è per»** (due `tile` affiancate): «È per» in verde con le righe «✓ …», «Non è per» in rosso con le
   righe «✕ …» (14, due righe ciascuna nel template).
4. **Le cifre**, in una griglia `1,5fr 1fr 1fr`:
   - «**Su 10.000 € in dieci anni**»: la cifra finale (22) e accanto «**alla fine, tolti i costi**»; una barra alta 9
     in tre parti (versato grigio, guadagno verde, costi arancio); sotto «versati 10.000 € · guadagno <x> · **costi
     <y>**: <z>% del guadagno possibile» (i costi in arancio scuro, la percentuale sottolineata);
   - «**Quanto rischia**»: la scala 1-7 (`sriScala`) e «<n> su 7: <parola>» (molto basso … molto alto);
   - «**Per quanto tempo**»: «<n> anni» e «almeno, per dare il meglio».
   Per la **protezione** la griglia ha due riquadri: «Quanto costa, per dare un’idea» con «circa 190 € l’anno» e «per
   100.000 € di capitale, a 40 anni, non fumatore» (dimostrativo), e «Per quanto tempo» con «la durata più scelta».
5. **Tre condizioni** (`card`, righe chiave-valore `kv`): «Garanzia», «Uscita prima», «Tasse» (per la protezione «Cosa
   paga», «Durata», «Tasse»).
6. **Il piede**: con un cliente scelto «**Proponi a <nome>**» (primario grande) e «**Confronta con quello che ha**»;
   se la scheda ha un documento nella Biblioteca «**Apri il suo documento**»; a destra in grigio «Scheda di prova,
   compilata dal consulente: costi e condizioni veri sono nel KID in vigore.».

Comportamenti (`montaProdotti`, riga 5016): clic su una riga → la scheda cambia, torna in cima ed entra con una salita
di 8 e la dissolvenza (0,3 s); «Proponi a …» mette il prodotto fra le proposte del cliente («la completi in
Posizioni»); «Confronta con quello che ha» apre Analisi 360 su «Simula e confronta» con «Due a confronto»; «Apri il
suo documento» passa a «Documenti» e apre il documento (`bibApri`).

La regola (riga 2895) aggiunge: «**Le percentuali di oggi restano in una vista di dettaglio, se servono.**»

### 63.2 Nell'app oggi

- **L'app Prodotti** è un'app con finestra propria fuori dal dock: `AppPrisma.prodotti` (`Shell/AppPrisma.swift:24`,
  `fuoriDalDock` :43), aperta dal menu Vai, dalla ricerca ⌘K, dai «Collegati» (`CollegatiRail(app: [.posizioni,
  .prodotti])`, `Shell/AppAnalisi360.swift:107`).
- `Shell/AppProdotti.swift:5` `AppProdotti`: `CorniceStrumento` con `rail(conti)` (:208, filtri per canale e area,
  ricerca), `colonnaElenco` (:245) e `rigaElenco` (:267, sottotitolo `riassunto` :297 «Area · costo x% · SRI n»), e
  `dettaglio(_:)` (:452): `testata` (:373, barretta dell'area, nome, «area · tipologia · emittente», etichetta del
  canale), le tessere `tessere` (:401: Costo annuo, Costo d'ingresso, Rendimento ipotizzato, `TesseraRischio`,
  Orizzonte), `PesoCostiProdotto` «Su 10.000 € in 10 anni» (`DesignSystem/ComponentiProdotti.swift:123`, già con
  versato, netto e costi in euro, la barra in tre pezzi, la legenda «Versati / Guadagno netto / Costi» e **già la quota**
  `quotaCosti = costi / (netto + costi − versato)` scritta «i costi si prendono il x% del guadagno»), `AvvisoNuovoKID`
  (`Shell/AggiornamentiProdotto.swift:7`), `pannelloCondizioni` (:311: Garanzie, Riscatto e liquidabilità,
  Fiscalità, Costi come nel KID, Note), `pannelloFonte` (:342: fonte, «Verificata il …» / «Mai verificata», pillola «Da
  rileggere sul KID», «Segna verificata oggi»), `condizioni(_:)` (:121, le condizioni dettagliate del contratto),
  `StoricoAggiornamentiProdotto`, «Dove è usata», e la fila dei pulsanti «Metti su un cliente…», «Simula»,
  «Modifica», «Aggiorna dai documenti…», «Elimina la scheda…», con la `NotaMetodo` in fondo.
- Le cifre sono già in cache: `cifre(_:)` (:441) con `stato.ricavato("prodotti-scheda|…")`; l'elenco ordinato con
  `stato.ricavato("prodotti-ordinati")` (:17).
- Il modello `Prodotto` (`Dati/Prodotti.swift:5`): nome, canale, area, emittente, tipologia, rendimento, costi, aliquota,
  `sri`, `garanzie`, `liquidabilita`, `fonte`, `verificatoIl` (`daVerificare` se ≥ 12 mesi, :75), `note`, `condizioni`,
  `periodoRaccomandato`, `parametriEsempio` (:79, 10.000 € per 10 anni). **Non ha** la frase, «per chi è», «per chi non
  è».
- Il profilo del cliente e l'adeguatezza: `MotoreCoerenza.sriMassimo(_ propensione:)` (`Motori/MotoreCoerenza.swift:105`);
  le priorità dalla ruota dei bisogni: `MotoreBisogni.priorita` (`Motori/MotoreBisogni.swift:146`) → `AreaBisogno.areaAnalisi`
  → `AreaAnalisi.areaPosizioni` (miglioria 17 per l'ordine senza doppioni).
- Il legame scheda → documento della Biblioteca c'è già: `TestoNorma.prodottoId` (`Vera/NormeVera.swift:46`),
  `stato.apriDocumentoBiblioteca(_:pagina:)` (`Shell/BibliotecaLuce.swift:140`).
- «Metti su un cliente…» apre `ModuloProdottoSulCliente` (`Shell/ModuloProdottoSulCliente.swift`, init
  `prodotto:statoIniziale:clienteId:clienteScelto:…`) in due passi; **c'è già anche `stato.proponi(_ p: Prodotto)`**
  (`Shell/StatoShell.swift:2021`: crea la proposta per il cliente attivo con le condizioni della scheda, la apre in
  Posizioni e avvisa «Proposta creata per …: completa importi e durata»), che è il gesto di «Proponi a <nome>»;
  «Simula» chiama `stato.simula(_ p: Prodotto)` (`Shell/StatoShell.swift:2028`: prepara `bozzaSimulazione` e apre
  `.simulazioni`).
- I token della scheda di oggi sono già centralizzati: `Tema.Colore.Prodotti`, `Tema.Testo.Prodotti`,
  `Tema.Misura.Prodotti`, `Tema.Raggio.Prodotti` (in testa a `DesignSystem/ComponentiProdotti.swift`).
- Modalità cliente: oggi `AppProdotti` non nasconde nulla in modalità cliente; «Modifica» ed «Elimina» sono solo
  spenti con `stato.solaLettura` (archivio in sola lettura, :526 e :538), che non è la modalità cliente
  (`stato.modoCliente`).
- La Biblioteca: `Shell/AppBiblioteca.swift:22` `AppBiblioteca` → `VistaBiblioteca` (solo Mac); nessun segmentato in
  testata.
- **Mancano**: il catalogo dentro la Biblioteca, l'ordine per il cliente con l'esito, la frase, «È per / Non è per», la
  riga dei costi con le parole del template («versati … · guadagno … · costi …: x% del guadagno possibile»: la quota c'è
  già, cambiano le parole e la legenda diventa una riga), il riquadro «Quanto rischia» con «<n> su 7: <parola>» (la
  parola c'è già in `TesseraRischio.descrizione`), il piede con «Proponi a …», «Confronta con quello che ha», «Apri il
  suo documento».

### 63.3 Cosa fare

1. **Il catalogo nella Biblioteca (solo Mac).**
   - `AppPrisma.prodotti.ospite` restituisce `.biblioteca` **solo su macOS** (`#if os(macOS)` dentro `ospite`, o una
     proprietà `ospiteMac` usata da `apri`), e `fuoriDalDock` resta vero per iPhone e iPad (senza il ramo `#if`,
     `altreApp` di iOS perderebbe Prodotti). `preparaOspite(per: .prodotti)` (`Shell/AppAccorpate.swift:8`) mette
     `stato.sezioneBiblioteca = .prodotti`, e `accorpataMostrata(in: .biblioteca)` (stesso file, :21) restituisce
     `.prodotti` quando la sezione è quella (serve a chi chiedeva `appAttiva == .prodotti`). Così tutte le chiamate
     `apri(.prodotti)` di oggi (menu Vai, ricerca, Collegati, Guida, istantanee) portano al catalogo nella Biblioteca.
     `AppPrisma.altreApp` sul Mac perde «Prodotti».
   - Nuovo `enum SezioneBiblioteca { case documenti, prodotti }` e `var sezioneBiblioteca: SezioneBiblioteca =
     .documenti` in `StatoShell` (stato della vista, non archivio). **Non** chiamarlo `VistaBiblioteca`: è già il nome
     della vista della Biblioteca (`struct VistaBiblioteca: View`, `Shell/AppBiblioteca.swift:39`).
   - Nella testata della Biblioteca (la riga sola della miglioria 4) un `SegmentatoPillola` «Documenti | Prodotti»,
     come `RigaVisteAnalisi360` (`Shell/FamiglieComeLaSua.swift:67`). Con «Prodotti» il contenuto è una vista nuova
     `CatalogoProdottiMac` (file nuovo `Shell/BibliotecaProdotti.swift`, `#if os(macOS)`), che riusa i pezzi di
     `AppProdotti` (le cifre in cache, i moduli in `.sheet`, l'alert di eliminazione: spostarli in un'estensione
     comune o renderli `internal`).
2. **L'esito per il cliente** (motore puro, file nuovo `Motori/MotoreSchedaProdotto.swift`):
   `enum EsitoProdottoCliente { case priorita, inLinea, oltreProfilo }` e
   `static func esito(_ p: Prodotto, propensione: ProfiloInvestitore.Propensione?, priorita: [AreaAnalisi]) -> EsitoProdottoCliente`:
   - `oltreProfilo` se `p.sri` c'è e supera `MotoreCoerenza.sriMassimo(propensione)` (decisione 63-c: il template
     tollera un punto in più; l'app usa la soglia di sempre);
   - `priorita` se l'area della scheda è fra le prime tre priorità del cliente (le stesse della miglioria 17);
   - altrimenti `inLinea`. Senza propensione nel profilo: niente «oltre il profilo» (solo priorità o in linea).
   - `static func ordina(_ schede: [Prodotto], esiti: [String: EsitoProdottoCliente]) -> [Prodotto]`: priorità, in
     linea, oltre il profilo; a parità l'ordine di oggi (per nome).
   Nello stato: `stato.ricavato("prodotti-esiti|\(cliente)") { … }` (dati dei calcoli + cliente: il profilo e i
   bisogni sono dati dei calcoli; il cliente va nella chiave). Niente calcoli nel body.
3. **La colonna** (`CatalogoProdottiMac.colonna`): intestazione «Per \(nome), dal più adatto» / «I prodotti» con il
   numero a destra (carattere e colore dell'etichetta della barra laterale `.side`); le righe con il quadratino
   dell'area, il nome su più righe (`lineLimit(2)`), sotto `riassuntoChiaro(p)` = «\(area) · costo \(x)% · rischio \(n)
   su 7» (al posto di «SRI n», miglioria 9: niente sigle in vista), «fonte da verificare» (arancio scuro del tema) se
   `p.daVerificare`, e con un cliente «risponde a una priorità» (verde) / «rischia più del profilo» (rosso); a destra
   `EtichettaCanale(compatta: true)`. **I filtri di oggi** (canale, area, ricerca) restano: in una riga sopra
   l'elenco (il campo di ricerca piccolo e un menu «Filtra ⌄» con canale e area), non più in una barra laterale a parte.
4. **La scheda** (`CatalogoProdottiMac.scheda(_:)`), in quest'ordine, con l'entrata a cascata di oggi
   (`entrataCascata`, `riavviaCascata(p.id)`):
   1. testata: occhiello «\(area.nome) · \(tipologia)» nel colore dell'area, nome (token nuovo `titoloScheda` 27 bold,
      tracking −0,6), etichetta del canale e la pillola dell'esito («Risponde a una priorità di \(nome)» `.ok`,
      «In linea con il profilo di \(nome)» `.neutro`, «Rischia più del profilo di \(nome)» `.attenzione` rossa — usare
      `Pillola` con i toni di oggi); a destra la fonte: «Fonte verificata il \(data)» (verde) o, con `daVerificare` o
      un KID nuovo (`AvvisoNuovoKID` sa già se c'è), «Fonte da verificare: c’è un KID nuovo» / «Fonte da verificare»
      (senza KID nuovo, solo per l'età) con «Segna verificata oggi» (lo stesso codice di `pannelloFonte`). La riga della
      fonte (`p.fonte`, il testo libero) va nella vista di dettaglio.
   2. «In una frase» (card piatta): la frase della scheda (vedi 63.4 e decisione 63-a).
   3. «È per» / «Non è per»: due tessere affiancate, righe con `checkmark` verde e `xmark` rosso.
   4. Le cifre: per le aree proiettabili `PesoCostiProdotto` (c'è già) con il titolo «Su 10.000 € in dieci anni» (oggi
      «in 10 anni», `AppProdotti.swift:475`), la cifra netta e «alla fine, tolti i costi», e sotto la riga «versati
      \(versato) · guadagno \(netto − versato) · costi \(impatto): \(quota)% del guadagno possibile» (i costi in
      arancio scuro, la percentuale sottolineata). **La quota non si ricalcola**: è la `quotaCosti` che il componente ha
      già (stessa formula); si aggiunge a `PesoCostiProdotto` uno stile `.riga` (o un parametro) che sostituisce la
      legenda «Versati / Guadagno netto / Costi» e la nota «i costi si prendono il …» con questa riga sola, lasciando lo
      stile di oggi a chi lo usa altrove. Le cifre restano quelle di `CifreScheda` (cioè di `MotoreProiezione`); accanto «Quanto rischia» (la `TesseraRischio` di oggi, con «\(n) su
      7: \(TesseraRischio.descrizione(n))») e «Per quanto tempo» («\(periodoConsigliato) anni», «almeno, per dare il
      meglio»; «non indicato» se manca). Per la protezione: «Per quanto tempo» e, solo se Prisma ha una stima del premio
      (decisione 63-d), «Quanto costa, per dare un’idea».
   5. Tre condizioni in righe chiave-valore (`RigaDato`): «Garanzia» ← `garanzie`, «Uscita prima» ← `liquidabilita`,
      «Tasse» ← `aliquotaFiscale` («\(x)% sul rendimento») — vuote: la riga non c'è.
   6. Il piede: con un cliente scelto «Proponi a \(nome)» (`.applePrimario` grande: chiama `stato.proponi(p)`, che c'è
      già e crea la proposta con le condizioni della scheda; l'avviso diventa quello del template ««\(p.nome)» è tra le
      proposte di \(nome): la completi in Posizioni» con l'azione «Apri» (`mostraAvviso(_:azione:)`). Il template resta
      nella Biblioteca: `proponi` riceve un parametro `apri: Bool = true` e qui si passa `false`. Il modulo in due passi
      `ModuloProdottoSulCliente` resta per «Metti su un cliente…» senza cliente scelto) e «Confronta con quello che ha»
      (`.apple`: con la 64 apre Analisi 360 › «Simula e confronta» › «Due a confronto»; il template non preimposta le
      strade, la proposta è A = la scheda e B = la prima posizione in essere della stessa area, o «Lasciare i soldi sul
      conto»; prima della 64 apre il confronto di oggi); se un documento della Biblioteca ha `prodottoId ==
      p.id`, «Apri il suo documento» (passa a `sezioneBiblioteca = .documenti` e chiama `apriDocumentoBiblioteca`).
      Senza cliente: solo «Apri il suo documento» e «Metti su un cliente…». A destra la nota grigia «Scheda compilata
      dal consulente: costi e condizioni veri sono nel KID in vigore.» (il testo del template senza «di prova»).
   7. **«Tutti i dettagli ⌄»** (un `DisclosureGroup` o un pulsante `.appleSobrio` che apre/chiude, chiuso di base): le
      tessere delle percentuali di oggi (`tessere`), `pannelloCondizioni` completo con i costi come nel KID e le note,
      la fonte con il testo, `condizioni(_:)`, `StoricoAggiornamentiProdotto`, «Dove è usata» e la `NotaMetodo`. Niente
      sparisce.
   8. Le azioni di gestione («Modifica», «Aggiorna dai documenti…», «Simula», «Elimina la scheda…», «Nuova scheda»,
      «Dai documenti…») vanno in un menu «Altro ⌄» nella testata della Biblioteca quando è su «Prodotti» (la riga sola
      della miglioria 4 ha già il posto delle azioni) — «Nuova scheda» resta anche come voce di «Aggiungi».
5. **«Modifica» la scheda** (`ModuloProdotto`, `AppProdotti.swift:557`): tre campi nuovi in un gruppo «Per il cliente»:
   «In una frase» (una riga lunga, al più 200 caratteri), «È per» e «Non è per» (fino a tre righe ciascuno). Sotto, il
   pulsante «Proponi dai dati della scheda» che riempie i campi vuoti con le frasi di `MotoreSchedaProdotto.proposta(_:)`
   (vedi 63.4); il consulente le corregge.
6. **Token**: prima si riusano e si estendono quelli della scheda di oggi (`Tema.Colore/Testo/Misura/Raggio.Prodotti`
   in `DesignSystem/ComponentiProdotti.swift`); i nuovi in `DesignSystem/Apple/Tema.Apple+Biblioteca.swift`, `enum Catalogo`:
   `larghezzaElenco` 330, `quadratinoArea` 10 / raggio 3, `titoloScheda` (27 bold, tracking −0,6), `frase` (19
   semibold, interlinea 1,4), `paddingFrase` 16×20, `rigaPerChi` (14), `spazioRigaPerChi` 6, `cifraTessera` (22 bold),
   `spazioBlocchi` 12, i colori «fonte da verificare» (arancio scuro di `--orangeT`, già nel tema dalla miglioria 7) e
   verde/rosso degli esiti (quelli degli stati `ok`/`ko` di oggi).
7. **Testi** in un `enum TestiCatalogo` (nuovo, `Motori/TestiSchedaProdotto.swift`): «Documenti», «Prodotti», «Per
   \(nome), dal più adatto», «I prodotti», «fonte da verificare», «risponde a una priorità», «rischia più del profilo»,
   le tre pillole dell'esito, «Fonte verificata il \(data)», «Fonte da verificare: c’è un KID nuovo», «Segna
   verificata oggi», «In una frase», «È per», «Non è per», «Su 10.000 € in dieci anni», «alla fine, tolti i costi»,
   «Quanto rischia», «Per quanto tempo», «almeno, per dare il meglio», «Garanzia», «Uscita prima», «Tasse», «Proponi a
   \(nome)», «Confronta con quello che ha», «Apri il suo documento», «Tutti i dettagli».

Cosa NON fare: non portare `PRODOTTI` né le cifre del template («circa 190 € l’anno», i rendimenti, le date); non
calcolare in un body l'ordine o gli esiti dell'elenco; non togliere i filtri, le condizioni dettagliate, lo storico degli
aggiornamenti, «Dove è usata»; non scrivere nella frase cifre che non vengono dai dati della scheda.

### 63.4 Dati, archivio, privacy

**Tre campi nuovi, facoltativi, in `Prodotto`** (decisione 63-a): `inUnaFrase: String?`, `perChi: [String]?`,
`nonPerChi: [String]?`. Stanno dove sta la scheda (sezione comune `prodotti.json` di `ArchivioPezzi`, nessun posto
nuovo: `Prodotto` è già nella chiave `.prodotti`); entrano nei backup con il catalogo; in «Prisma ovunque» viaggiano come
oggi le schede (l'istantanea del Mac porta il catalogo; l'iPhone non li mostra in questo giro e non li cambia).
Opzionali con `decodeIfPresent` di Codable sintetizzato: gli archivi di prima si leggono senza conversione; non serve
cambiare la versione dei campi di `DatiPrisma` (dirlo nel commento) ma `ProvaBackupArchivioPezzi` deve rileggere una
scheda con i tre campi pieni e una senza.

Quando i campi sono vuoti, la scheda mostra le frasi **proposte dal codice** (`MotoreSchedaProdotto.proposta(_:)`,
regole fisse, nessun testo libero inventato), con una piccola nota «scritte da Prisma dai dati della scheda» che invita a
correggerle in «Modifica»:
- «È per»: «Chi ha almeno \(periodo) anni davanti» (dal periodo consigliato); «Chi vuole il capitale protetto» se
  `garanzie` dice una garanzia o c'è `minimoGarantito`; «Chi vuole molta protezione con poca spesa» per la protezione;
  «Chi vuole una pensione più alta» per la previdenza.
- «Non è per»: «Chi può avere bisogno di quei soldi prima di \(n) anni»; «Chi non sopporta di vedere il valore
  scendere» con SRI ≥ 4; «Chi cerca la crescita dei mercati» con SRI ≤ 2; «Chi cerca un rendimento» per la protezione.
- La frase: nessuna frase automatica (la scrive il consulente); senza frase il riquadro «In una frase» non c'è.

Privacy: nessun dato del cliente nella scheda (l'esito usa profilo e bisogni del cliente solo per l'etichetta in vista);
in modalità cliente l'esito per il cliente scelto si può mostrare (è il cliente presente). «Altro ⌄», «Modifica»,
«Elimina» e «Segna verificata oggi» in modalità cliente (`stato.modoCliente != nil`) **si nascondono** (novità: oggi
`AppProdotti` non li nasconde) e con l'archivio in sola lettura (`stato.solaLettura`) restano spenti come oggi. La
Biblioteca oggi si apre anche in modalità cliente (non è fra le app escluse): il catalogo segue la stessa regola.

### 63.5 Istantanee e prove

- Da aggiornare: **«23-prodotti»** e **«32-prodotti-condizioni»** (`Istantanee.swift:125`, :184): ora aprono la
  Biblioteca su «Prodotti» (con `apri(.prodotti)` lo fa il reindirizzamento); «23» con il cliente Giulia scelto
  (l'elenco «Per Giulia, dal più adatto», le pillole dell'esito), «32» con «Tutti i dettagli» aperto (le condizioni
  dettagliate devono restare visibili in un'istantanea). Anche **«192-prodotti-avviso-nuovo-kid»** (la fonte «da
  verificare: c'è un KID nuovo») e **«878-biblioteca-prodotto»**.
- Nuove (in `Shell/IstantaneeBiblioteca.swift`, chiara e scura), nel blocco libero «14xx-uso» del gruppo (i numeri
  883-885 sono già presi da `IstantaneeSmontaggio.swift`, 209-211 in parte da Riesami; gli altri gruppi usano blocchi
  «1xxx-uso-…»): **«1400-uso-biblioteca-prodotti»** (senza cliente: «I prodotti», scheda con frase e «È per / Non è
  per»), **«1401-uso-biblioteca-prodotto-protezione»** (una scheda di protezione: due riquadri o uno, decisione 63-d),
  **«1402-uso-biblioteca-prodotto-oltre-profilo»** (un cliente prudente e un prodotto con SRI alto: pillola rossa e
  ultimo nell'elenco).
- I dati di prova (`Dati/DatiDemo.swift`, `Dati/ClientiFittizi.swift`): scrivere frase, «È per» e «Non è per» per le
  schede di prova (si possono adattare i testi del template ai nomi delle schede di prova), lasciandone una vuota per
  mostrare le frasi proposte.
- Prove: in `--prova-calcoli` un `ProvaCalcoliSchedaProdotto` per `MotoreSchedaProdotto.esito` (oltre il profilo,
  priorità, in linea, senza propensione, senza SRI) e `ordina`, e per `proposta(_:)` (protezione, previdenza, SRI alto e
  basso, periodo mancante); in `--prova-backup` i tre campi nuovi (vedi 63.4). Le istantanee iOS «16-prodotti» non
  cambiano.

### 63.6 Decisioni per l'utente e rischi

- **63-a La frase e «per chi è / non è».** Il template le mostra come testi della scheda; l'app non li ha. **Proposta:**
  tre campi facoltativi scritti dal consulente in «Modifica», con frasi proposte dal codice quando sono vuoti (mai da
  Vera: la scheda deve essere stabile e verificabile). Alternativa senza campi nuovi: solo le frasi del codice, nessuna
  frase libera (si perde «In una frase»).
- **63-b L'app Prodotti sparisce dal Mac.** La regola lo dice («Il catalogo sta nella Biblioteca»). **Proposta:** sì,
  con `ospite` solo sul Mac; su iPhone e iPad resta l'app di oggi.
- **63-c La soglia di «Rischia più del profilo».** Il template tollera un punto oltre il profilo; l'app ha già
  `MotoreCoerenza.sriMassimo`. **Proposta:** la soglia di oggi, senza tolleranza, perché è la stessa delle incoerenze
  in Posizioni (una sola regola in tutta Prisma).
- **63-d «Quanto costa» della protezione.** Il template scrive un premio indicativo fisso. **Proposta:** mostrarlo solo
  se `MotoreSimulatoriAnalisi.tariffaCasoMorte` ha una stima dalle coperture in archivio, con il testo «stima dalle
  polizze in archivio»; altrimenti il riquadro non c'è.
- **63-e Dove vanno «Modifica», «Simula», «Elimina».** Il template non li mostra. **Proposta:** menu «Altro ⌄» nella
  testata (vedi 63.3, punto 4.8).
- Rischi: la scheda ha due viste (sintesi e dettaglio) dentro uno `ScrollView`; il dettaglio va montato solo quando è
  aperto (niente `opacity(0)`), così la memoria resta quella di oggi. Gli esiti dell'elenco si calcolano una volta per
  cliente e dati (`ricavato`), non per riga.

### 63.7 Dimensione

**L** (oltre 500 righe). File principali: `Shell/BibliotecaProdotti.swift` (nuovo), `Shell/AppProdotti.swift`,
`Shell/AppBiblioteca.swift`, `Shell/AppPrisma.swift`, `Shell/AppAccorpate.swift`, `Shell/StatoShell.swift` (`proponi`),
`DesignSystem/ComponentiProdotti.swift` (`PesoCostiProdotto`), `Motori/MotoreSchedaProdotto.swift`
(nuovo), `Motori/TestiSchedaProdotto.swift` (nuovo), `Dati/Prodotti.swift`, `Dati/DatiDemo.swift`,
`DesignSystem/Apple/Tema.Apple+Biblioteca.swift`, `Shell/IstantaneeBiblioteca.swift`, `Istantanee.swift`.

---

## 64. Simula e confronta: prima la frase

### 64.1 Nel template

Codice righe 5024-5064 (`cfOpz`, `cfConto`, `cfGrafico`, `cfDestraHTML`, `cfCur`, `confHTML`, `montaConf` e la
ridefinizione di `anHTML`/`agganciaAn`), regole a riga 2896 e 2948-2951. Si apre con `MIG11b[1]`: `cfM='due';
vaiCli(0,'analisi', vistaA='conf')`, cartellino su `#cfFrase`.

**Dove sta.** In Analisi 360 il segmentato delle viste («Le aree» | «Rispetto alle famiglie come la sua») ha una terza
voce, «**Simula e confronta**» (`vistaA='conf'`, riga 5062). La regola di riga 2948 aggiunge: sotto «Strumenti» le quattro
voci di oggi (Simulatore, Scenari, Confronto, TFR) diventano una sola, «Simula e confronta»; spariscono il secondo
selettore del cliente e la fila degli strumenti in fondo alla pagina.

**La colonna di sinistra** (card larga 372, `confHTML` riga 5056):
1. il segmentato «**Una strada | Due a confronto | Il TFR**» (`cfM`, di base `una`; «Il TFR» è la miglioria 69);
2. l'occhiello «**La strada**» (o «**Le due strade**») e la strada scelta come una riga che si tocca (`cfSel`): il
   tondino del colore (accento per «·» o «A», viola per «B»), il nome in grassetto, sotto «<ce l’ha già | proposta | dal
   catalogo | non fare niente> · rende <x>%, costa <y>% l’anno» e la freccia giù; il clic apre un menu con tutte le
   strade (nome e, a destra, la provenienza): le **posizioni** del cliente («ce l’ha già»), le **proposte**
   («proposta»), le schede del **catalogo** («dal catalogo») e «**Lasciare i soldi sul conto**» («non fare niente»).
   Scegliendo in A la strada di B, le due si scambiano;
3. l'occhiello «**I soldi**» (con due strade «**I soldi, uguali per tutte e due**») e **tre cursori soli**: «Quanto mette
   oggi» (0-100.000, passo 1.000, in euro), «Quanto mette al mese» (0-1.500, passo 50, «<v> €»), «Per quanti anni»
   (1-30, «<n> anni»/«1 anno»);
4. in fondo, separata da un filo, **le ipotesi in una riga** (grigio): «Le ipotesi: rendimento e costi di ogni strada
   come scritto sopra; tasse al 26% sul guadagno; inflazione al 2% per «in soldi di oggi».».

**A destra, una strada** (`cfDestraHTML`, riga 5040):
1. `#cfFrase` (card, padding 18×22): occhiello «Con «<strada>»», la frase (23 bold, tracking −0,4) «**Tra <n> anni avrà
   circa <cifra>.**» (la cifra in accento) e sotto (14,5) «Ne avrà versati <v>: il resto, <c>, è crescita, già tolti <x>
   di costi e <t> di tasse. In soldi di oggi sono <r>.»;
2. due riquadri affiancati (`300px 1fr`): «**Se va diversamente**» con tre righe e una barra ciascuna — «**Male** · due
   punti in meno l’anno» (arancio), «**Come previsto** · <x>% l’anno» (accento), «**Bene** · due punti in più l’anno»
   (verde), con la cifra a destra; «**Anno per anno, al netto**» con il grafico (linea della strada, tratteggio
   «versato», «oggi» e «tra <n> anni» sotto);
3. la fila: «**Salva questa ipotesi**» (primario), «**Confrontala con un’altra strada**» (passa a «Due a confronto»),
   «**Prospetto in PDF**», e se ci sono ipotesi salvate per il cliente «Salvate:» con una chip per ognuna («<prime tre
   parole> · <v> €/mese · <n> anni»): un tocco la riapre (strada e soldi). Salvando: «Ipotesi salvata nel dossier di
   <nome>».

**A destra, due strade:**
1. `#cfFrase`: occhiello «**Gli stessi soldi, due strade**» e la frase (21 bold):
   - quasi pari (differenza sotto l'1%): «Tra <n> anni arrivano quasi allo stesso punto: circa <cifra>. La differenza la
     fa il rischio: <a> contro <b> su 7.»;
   - altrimenti «Tra <n> anni «<vince>» arriva <diff> più in alto di «<perde>», tolti costi e tasse.» (la differenza in
     verde) e, se serve, « Ma rischia di più: <a> contro <b> su 7.» oppure « E rischia anche meno.», e se i costi
     differiscono di oltre 200 € « In costi lascia <x>, l’altra <y>.»;
2. due riquadri: la **tabella** a tre colonne (vuota | «A · <nome>» in accento | «B · <nome>» in viola) con le righe
   «Alla fine, al netto», «Se va male», «Costi in <n> anni», «Rischio, da 1 a 7», e la spunta verde «✓» accanto al
   valore migliore (per costi e rischio vince il più basso); il **grafico** «Anno per anno, al netto» con le due linee
   (etichette «A» e «B» a destra);
3. la fila: «**Fanne un prospetto per <nome>**» (primario), «**Torna a una strada sola**», a destra «Stime con le ipotesi
   qui a sinistra: non sono promesse.».

Le due strade usano **gli stessi soldi**: l'avviso «Versato diverso» non serve più (riga 2902). Muovendo un cursore
cambia subito la colonna di destra (`rifaiD`), senza ridisegnare la sinistra.

### 64.2 Nell'app oggi

- **Quattro strumenti nella barra laterale** di Analisi 360: `AppAnalisi360.rail` (`Shell/AppAnalisi360.swift:83-90`),
  `ForEach(StrumentoAnalisi.allCases)`; `enum StrumentoAnalisi { simulatore, scenari, confronto, tfr }`
  (`Shell/StatoShell.swift:20`); il contenuto `StrumentiAnalisi360` (`Shell/AnalisiStrumenti.swift:9`) sceglie fra
  `SimulatoreIpotesi(inAnalisi:)`, `ScenariSalvati`, `ConfrontoIpotesi`, `StrumentoTFR`. Le stesse viste servono
  l'app Simulazioni e Confronti di iPhone e iPad (`Shell/AppSimulazioni.swift`, `Shell/AppConfronti.swift`).
- Il segmentato delle viste: `RigaVisteAnalisi360` (`Shell/FamiglieComeLaSua.swift:67`), due voci
  (`VistaAnalisi360 { aree, famiglie }`, :36), mostrato da `Analisi360Apple` (`Shell/Analisi360Apple.swift:198`).
- **Il simulatore** (`Shell/StrumentiSimulazione.swift:6` `SimulatoreIpotesi`): **otto cursori** in colonna
  (`ComandoSimulatoreFermo`, :177-198: capitale, versamento, orizzonte, rendimento, costo d'ingresso, costo annuo,
  imposte, inflazione) e il canale dell'ipotesi; a destra «CAPITALE FINALE IPOTETICO, AL NETTO» con `NumeroCheConta`,
  quattro dettagli (versato, crescita, in euro di oggi, costi e imposte), le ipotesi in grigio (`ipotesi(_:)` :282), il
  grafico, «Come viene calcolato?», la tabella «Se il rendimento fosse» (`MotoreProiezione.scenari`,
  `Motori/Proiezione.swift:361`: Prudente / Atteso / Favorevole con lo scarto del KID se c'è, altrimenti ±2 punti,
  `IpotesiCalcolo.ampiezzaScenari`). Pulsanti «Nuova ipotesi», «Confronta», «Salva scenario» (`ModuloScenario` per il
  nome, `Shell/AppSimulazioni.swift:69`). «Parti da una posizione» (`menuPosizioni`, :99; `stato.simula(_:)`).
- **Le porte d'ingresso al simulatore** passano tutte da `stato.bozzaSimulazione` + `schedaSimulazioni` +
  `apri(.simulazioni)`: `simula(_ p: Prodotto)` (`StatoShell.swift:2028`), `simula(_ o: Obiettivo)` (:2077),
  `simula(_ area:)` di Analisi 360 (`AppAnalisi360.swift:161`); `preparaOspite(per: .simulazioni / .confronti)`
  (`Shell/AppAccorpate.swift:8`) sceglie lo strumento, `accorpataMostrata` (:21) fa il contrario con uno `switch`
  completo su `StrumentoAnalisi`.
- **La fila «Strumenti» in fondo alle aree** (`Analisi360Apple.piede`, `Shell/Analisi360Apple.swift:454-470`): un
  pulsante per ogni `StrumentoAnalisi.allCases`, che ripete la barra laterale; sotto la nota e «Prepara l'incontro».
- **Gli scenari** salvati (`ScenariSalvati`, :341): l'elenco e fino a tre a confronto. Il modello è `Simulazione`
  (`Dati/Analisi.swift:4`: cliente, titolo, capitale, versamento, anni, rendimento, costi, aliquota, inflazione, canale,
  `posizioneId`).
- **Il confronto** (`Shell/StrumentoConfronto.swift:7` `ConfrontoIpotesi`): due voci (`VoceConfronto { posizione,
  simulazione }`, `Shell/StatoShell.swift:48`; elenco `ElementoConfronto.elenco`, `Shell/AppConfronti.swift:14`), ognuna
  con i **suoi** soldi; il verdetto (:227) «A/B ARRIVA PIÙ IN ALTO, AL NETTO» e la cifra «+…», «I COSTI TOLGONO», le
  pillole «Orizzonte: scegli «Comune»» e «**Versato diverso**» (:276); le due schede con la tendina, il grafico, la
  tabella, «Prima di trarre conclusioni». Pulsanti «Inverti A e B», «Restare o cambiare…» (solo due posizioni,
  `.sostituzione`), «Prospetto in PDF» (`stato.apriProspetto(.confronto(a, b))`).
- Le schede del catalogo entrano solo come «Simula» dalla scheda (`stato.simula(_ p: Prodotto)`); nel confronto no. Il
  conto (non fare niente) non c'è.
- **Mancano**: una vista sola, i tre cursori, le strade dal catalogo e «Lasciare i soldi sul conto», le stesse cifre di
  partenza per le due strade, le frasi, «Se va diversamente» come tre barre, le ipotesi salvate in una riga di chip.

### 64.3 Cosa fare

1. **Una voce sola.** `StrumentoAnalisi` sul Mac mostra due voci: «Simula e confronta» e (fino alla 69) «TFR»; con la
   69 una sola. Concretamente: nuovo caso `.simulaConfronta` (simbolo `slider.horizontal.3`), e una proprietà
   `static var delMac: [StrumentoAnalisi]` = `[.simulaConfronta]` usata dal `rail` (`#if os(macOS)`); i casi di oggi
   restano per iPhone e iPad e per le chiamate esistenti: `scegliStrumentoAnalisi(.simulatore / .scenari / .confronto)`
   sul Mac porta a `.simulaConfronta` con la modalità giusta (`.simulatore`/`.scenari` → «Una strada», `.confronto` →
   «Due a confronto», `.tfr` → «Il TFR» dopo la 69). Così `stato.simula(_:)`, «Confronta», le istantanee e la ricerca
   continuano a funzionare. Attenzione: l'enum è `CaseIterable` e condiviso, quindi chi scorre `allCases` (il `rail`,
   la fila del piede delle aree, eventuali elenchi di iOS) va filtrato (`delMac` sul Mac, i quattro di oggi su iOS:
   per esempio `static var diIOS`), e `accorpataMostrata` (`AppAccorpate.swift:21`) restituisce `.simulazioni` per il
   caso nuovo (o `.confronti` in «Due a confronto»).
   **Le bozze di oggi entrano come strada**: quando sul Mac arriva una `bozzaSimulazione` (da `simula(_ p: Prodotto)`,
   `simula(_ o: Obiettivo)`, `simula(_ area:)`, «Parti da una posizione»), «Simula e confronta» apre «Una strada» con
   A = `.prodotto(id)` se la bozza nasce da una scheda, `.posizione(id)` se ha `posizioneId`, altrimenti una strada
   «ipotesi mia» con rendimento e costi della bozza (decisione 64-d); capitale, versamento e anni della bozza vanno
   nei tre cursori. La bozza poi si consuma.
   **Via la fila «Strumenti» del piede delle aree** (`Analisi360Apple.piede`, regola di riga 2948: «la fila degli
   strumenti in fondo alla pagina, che ripete l'indice»): resta la nota e «Prepara l'incontro».
2. **La terza voce del segmentato.** `VistaAnalisi360` resta a due casi (aree, famiglie) ma `RigaVisteAnalisi360`
   riceve una terza voce «Simula e confronta» che chiama `scegliStrumentoAnalisi(.simulaConfronta)`; quando lo strumento
   è aperto la voce è accesa e il segmentato resta in testa alla vista (stessa riga, stessa posizione). Le due porte
   (barra laterale e segmentato) portano allo stesso stato: niente doppioni. `SegmentatoPillola` lavora su un solo tipo
   (`Binding<Valore>`): oggi `RigaVisteAnalisi360` riceve `@Binding var vista: VistaAnalisi360`; serve un piccolo enum
   della riga (`VoceRigaAnalisi360 { aree, famiglie, simula }`) con un `Binding` calcolato da `vistaAnalisi360` e
   `strumentoAnalisi` (simula ⇔ strumento `.simulaConfronta`; aree/famiglie ⇔ strumento nil). Nella stessa riga resta,
   a destra, la capsula «Stime in uso · N dati da completare ›» della miglioria 16 (`AvvisoStimeAnalisi360`): nel
   template c'è anche su «Simula e confronta» (riga 5064, `#anStime` agganciato a `apriDati`) e apre lo stesso elenco.
3. **Lo stato della vista** (`StatoShell`, non archivio): `enum ModoSimula { una, due, tfr }`, `var modoSimula`,
   `var stradaA: StradaSimula?`, `var stradaB: StradaSimula?`, `var soldiSimula: SoldiSimula` (capitale, mensile, anni),
   più `var ipotesiSimula: IpotesiSimula` per tasse e inflazione (di base `IpotesiCalcolo.aliquotaPredefinita`,
   `IpotesiCalcolo.inflazione`). I soldi partono, per ogni cliente, dalle ipotesi dell'area investimenti dell'Analisi 360
   (come `simula(_ area:)`, `AppAnalisi360.swift:161`); cambiando cliente si ripartono.
4. **Le strade** (motore puro, file nuovo `Motori/MotoreSimulaConfronta.swift`):
   - `enum StradaSimula: Hashable { case posizione(String), prodotto(String), conto }` e
     `struct OpzioneStrada { let strada; let nome; let provenienza: String; let canale: Canale?; let rendimento,
     costoIngresso, costoAnnuo: Double; let sri: Int?; let scarti: [Double]? }`.
   - `static func opzioni(posizioni: [Posizione], prodotti: [Prodotto], orizzonteCliente: Int?) -> [OpzioneStrada]`:
     le posizioni proiettabili del cliente in essere («ce l’ha già») e le proposte aperte («proposta»), con i loro
     rendimenti e costi da `ParametriProiezione(posizione:orizzonteCliente:)` (per la multiramo a due parti
     `rendimentoEquivalente` e `costoAnnuoEquivalente`, come le tessere della scheda prodotto); le schede proiettabili del
     catalogo non già usate dal cliente («dal catalogo», da `Prodotto.parametriEsempio`); in fondo «Lasciare i soldi sul
     conto» («non fare niente», decisione 64-b).
   - `static func parametri(_ o: OpzioneStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> ParametriProiezione`:
     rendimento e costi della strada, **soldi e anni comuni**, tasse e inflazione comuni.
   - Le cifre: `MotoreProiezione.calcola(_:)` per netto, versato, costi, imposte, reale e i punti anno per anno;
     `MotoreProiezione.scenari(_:)` per «Se va diversamente» (Prudente → «Male», Atteso → «Come previsto», Favorevole →
     «Bene»; la nota di ogni riga dice lo scarto vero: «due punti in meno l’anno» con lo scarto di base, oppure «come
     nello scenario sfavorevole del KID» se viene dal KID); `MotoreProiezione.impattoCosti` per i costi.
   - `static func frase(una:)`, `frase(due:)` e `vincitore(...)` in `Motori/TestiSimulaConfronta.swift` (nuovo) con i testi
     esatti del template (64.1), la soglia «quasi pari» all'1% del netto migliore, la soglia dei costi a 200 €
     (`static let sogliaCostiInFrase = 200.0`), gli articoli giusti per «1 anno».
   Tutto nella vista con `stato.ricavato("simula|\(cliente)|\(strade)|\(soldi)|\(ipotesi)")`: i soldi e le ipotesi
   stanno nella chiave perché non sono dati dei calcoli.
5. **La vista** (file nuovo `Shell/SimulaConfronta.swift`, `#if os(macOS)`, `struct SimulaConfrontaMac: View`), in
   `ColonneAffiancate(larghezza: token 372)` come gli strumenti di oggi:
   - **sinistra**: `SegmentatoPillola` «Una strada | Due a confronto | Il TFR» (la terza solo dopo la 69); «La strada» /
     «Le due strade» con una o due righe `RigaStradaSimula` (tondino col colore `Colori.Strumenti.serie[0]` / `[1]` e la
     lettera, nome, «\(provenienza) · rende \(x)%, costa \(y)% l’anno», l'etichetta compatta del canale se c'è — canale
     sempre riconoscibile —, freccia giù) che apre un `Menu` con le opzioni raggruppate (Ce l’ha già, Proposte, Dal
     catalogo, Non fare niente); scambio automatico se A sceglie la strada di B; «I soldi» / «I soldi, uguali per tutte e
     due» con tre `ComandoSimulatoreFermo` (`.equatable()`, come oggi: si ridisegna solo il comando trascinato) con gli
     intervalli del template (decisione 64-c); in fondo, dopo un filo, la riga delle ipotesi in grigio con
     «**Cambia**» (`.appleSobrio`), che apre un popover con tasse e inflazione (i due `ComandoSimulatoreFermo` di oggi) —
     rendimento e costi della strada non si cambiano qui (vengono dalla posizione o dalla scheda; per un'ipotesi libera
     vedi decisione 64-d).
   - **destra, una strada**: la card della frase (occhiello «Con «\(nome)»», frase con la cifra in accento che si conta
     con `NumeroCheConta`, il sottotesto); «Se va diversamente» (tre righe con barre da `BarreApple`/le barre di
     `BarreStradeTFR` — oggi `private` in `SimulazioneTFR.swift:704`: estrarne il componente comune, che serve anche
     alla 69 —, colori arancio/accento/verde del tema) e «Anno per anno, al netto» (il `GraficoProiezione` di
     oggi, con la linea al netto, il tratteggio del versato e le etichette «oggi» / «tra \(n) anni»); la fila
     «Salva questa ipotesi», «Confrontala con un’altra strada», «Prospetto in PDF» e le chip delle ipotesi salvate.
   - **destra, due strade**: la frase; la tabella a tre colonne con le quattro righe e la spunta verde (`checkmark`,
     colore positivo del tema); il grafico con due linee (`Colori.Strumenti.serie[0]`, `[1]`) ed etichette «A»/«B»; la
     fila «Fanne un prospetto per \(nome)», «Torna a una strada sola», e a destra «Stime con le ipotesi qui a sinistra:
     non sono promesse.» (se la miglioria 16 ha già un avviso unico delle stime nella stessa schermata, questa riga si
     toglie: decisione 64-e). «Restare o cambiare…» resta quando A e B sono due posizioni (stessa condizione di oggi),
     come pulsante secondario.
   - Le ipotesi salvate: «Salva questa ipotesi» salva una `Simulazione` (il modello di oggi) con i parametri della strada
     e i soldi comuni, il titolo «\(prime tre parole del nome) · \(mensile) €/mese · \(anni) anni» senza chiedere il nome
     (niente `ModuloScenario`), `posizioneId` se la strada è una posizione; mostra «Ipotesi salvata nel dossier di
     \(nome)». Le chip (`stato.simulazioniCliente(cliente)`, al più 6 in vista, le altre in «Tutte ⌄») la riaprono: una
     ipotesi salvata diventa la strada «ipotesi salvata» con i suoi rendimento e costi (quarto caso
     `StradaSimula.simulazione(String)`, provenienza «salvata il \(data)»). Menu contestuale della chip: «Rinomina…»,
     «Elimina» (quello che oggi fa `ScenariSalvati`).
   - «Fanne un prospetto per \(nome)» e «Prospetto in PDF»: salvano le strade come `Simulazione` (le stesse delle chip;
     se ci sono già con le stesse ipotesi, `stesseIpotesi`, si riusano) e aprono `stato.apriProspetto(.confronto(
     .simulazione(a), .simulazione(b)))` o il prospetto della simulazione singola di oggi. Nessun motore nuovo nei
     prospetti.
   - Movimento: le cifre si contano, il grafico si disegna, le barre si riempiono (componenti del tema già fatti);
     cambiare un cursore aggiorna senza cascate; calmo e istantanee: tutto fermo e nello stato finale.
6. **Cosa sparisce sul Mac**: le voci «Simulatore», «Scenari», «Confronto» della barra laterale; i cinque cursori in
   più in vista; il verdetto «+…» senza frase; la pillola «Versato diverso» (le due strade hanno gli stessi soldi); la
   pillola «Orizzonte: scegli «Comune»» (un solo «Per quanti anni»). La tabella «Se il rendimento fosse» diventa «Se va
   diversamente». La formula («Come viene calcolato?») resta come «Come viene calcolato?» sotto il grafico.
7. **Token** in `DesignSystem/Apple/Tema.Apple+Strumenti360.swift`, `enum SimulaConfronta`: `larghezzaColonna` 372,
   `paddingColonna` 18×20, `fraseUna` (23 bold, tracking −0,4, interlinea 1,3), `fraseDue` (21 bold, interlinea 1,35),
   `sottoFrase` (14,5, interlinea 1,5), `paddingFrase` 18×22, `larghezzaSeVa` 300, `barraSeVa` 8, `tondinoStrada` 22,
   `spazioBlocchi` 12, `colonnaTabella` (le tre colonne), `rigaIpotesi` (il grigio delle note). Colori: quelli che il
   tema ha già (`Colori.Strumenti.serie`, positivo, arancio, accento).
8. **Testi** in `TestiSimulaConfronta`: «Simula e confronta», «Una strada», «Due a confronto», «Il TFR», «La strada»,
   «Le due strade», «ce l’ha già», «proposta», «dal catalogo», «non fare niente», «Lasciare i soldi sul conto», «I
   soldi», «I soldi, uguali per tutte e due», «Quanto mette oggi», «Quanto mette al mese», «Per quanti anni», la riga
   delle ipotesi («Le ipotesi: rendimento e costi di ogni strada come scritto sopra; tasse al \(t)% sul guadagno;
   inflazione al \(i)% per «in soldi di oggi».»), «Cambia», le frasi, «Se va diversamente», «Male», «Come previsto»,
   «Bene», «Anno per anno, al netto», «versato», «oggi», «tra \(n) anni», «Salva questa ipotesi», «Confrontala con
   un’altra strada», «Prospetto in PDF», «Salvate:», «Ipotesi salvata nel dossier di \(nome)», «Gli stessi soldi, due
   strade», le righe della tabella, «Fanne un prospetto per \(nome)», «Torna a una strada sola», «Stime con le ipotesi
   qui a sinistra: non sono promesse.».

Cosa NON fare: non portare `CF_AREA`, `cfConto`, le tasse al 26% fisse né la formula semplificata del template; non
toccare `SimulatoreIpotesi`, `ScenariSalvati`, `ConfrontoIpotesi` (servono iPhone e iPad); non calcolare le proiezioni
nel body a ogni passo del cursore per tutte le opzioni del menu (solo le una o due strade scelte, in `ricavato`).

### 64.4 Dati, archivio, privacy

Nessun campo nuovo. Le ipotesi salvate sono `Simulazione` (già nel file del cliente e nei backup; in «Prisma ovunque»
come oggi). Lo stato della vista (modo, strade, soldi, ipotesi) resta in memoria. Nessun dato esce dal Mac.

### 64.5 Istantanee e prove

- Da aggiornare: **«14-analisi360-simulatore»**, **«15-analisi360-scenari»**, **«16-analisi360-confronto»**
  (`Istantanee.swift:87-98`): ora mostrano «Simula e confronta» con «Una strada» (da una posizione di Giulia), «Una
  strada» con le chip delle ipotesi salvate, «Due a confronto» (Marco: una posizione e una scheda del catalogo);
  **«233-vuoto-analisi360-scenari»** (cliente senza posizioni: le strade sono solo catalogo e conto, la frase c'è
  lo stesso) e **«239-analisi360-confronto-stretta»** (finestra stretta: la colonna di destra va sotto, come oggi
  `ColonneAffiancate`). Chiare e scure.
- Nuove (blocco «14xx-uso» del gruppo): **«1403-uso-analisi360-simula-conto»** (A una posizione, B «Lasciare i soldi
  sul conto»: frase «… arriva … più in alto …»), **«1404-uso-analisi360-simula-pari»** (due strade quasi pari: frase sul
  rischio).
- Prove: `ProvaCalcoliSimulaConfronta` in `--prova-calcoli` — le opzioni (posizioni, proposte aperte, catalogo senza
  doppioni, conto), i parametri con gli stessi soldi (versato uguale per A e B), la frase (quasi pari, vince con più
  rischio, vince con meno rischio, costi oltre soglia), lo scambio A/B; e che i netti coincidano con quelli di
  `MotoreProiezione.calcola` (nessun calcolo nuovo). `ProvaProspetti` per il prospetto del confronto nato da due
  ipotesi salvate. La prova di carico (`--prova-fluidita`): trascinare «Quanto mette al mese» non deve ridisegnare la
  colonna di sinistra.

### 64.6 Decisioni per l'utente e rischi

- **64-a Due porte, uno strumento.** Il template mette «Simula e confronta» come terza voce del segmentato; la regola
  (riga 2948) la mette anche sotto «Strumenti». **Proposta:** tutte e due, sullo stesso stato.
- **64-b «Lasciare i soldi sul conto».** Il template gli dà l'1% l'anno. **Proposta:** rendimento 0% e costi 0 (un
  conto corrente), scritto nella riga «non fare niente · rende 0%, costa 0% l’anno», così la frase in soldi di oggi
  mostra l'inflazione che erode. Alternativa: un tasso scelto in Impostazioni › Analisi (non ci sono dati di mercato del
  conto: Mercato non lo dà).
- **64-c Gli intervalli dei cursori.** Il template arriva a 100.000 € oggi e 1.500 € al mese; oggi il simulatore arriva
  a 10 milioni (con `fineCursore` 500.000) e 100.000 al mese (fine 3.000). **Proposta:** gli intervalli e i
  `fineCursore` di oggi (il valore si scrive anche a mano oltre la fine del cursore), con i passi del template.
- **64-d Un'ipotesi libera.** Con tre cursori il consulente non può più scrivere un rendimento qualsiasi. **Proposta:**
  nel menu delle strade, in fondo, «Un’ipotesi mia…» apre un popover con rendimento, costo d'ingresso e costo annuo
  (i cursori di oggi) e crea la strada «ipotesi mia» (`StradaSimula.libera`, solo in memoria finché non si salva).
- **64-e La riga «Stime … non sono promesse».** Va concordata con la miglioria 16 (un solo avviso sulle stime in
  Analisi 360). **Proposta:** tenerla nel piede di «Simula e confronta» e del TFR (è il loro avviso), e non ripeterla
  altrove nella stessa vista.
- **64-f Il canale dell'ipotesi.** Oggi il simulatore ha «Canale dell'ipotesi» (Nessuno / Alleanza / Indipendente). Con
  le strade il canale viene dalla posizione o dalla scheda (etichetta sulla riga della strada). **Proposta:** togliere il
  segmentato; il conto non ha canale; un'«ipotesi mia» chiede il canale nel suo popover.
- Rischi: il menu delle strade con molte schede di catalogo va costruito una volta (`ricavato` sulle opzioni) e non
  ricalcola proiezioni; le proiezioni sono solo quelle delle strade scelte, tre scenari per strada (fino a otto
  calcoli: leggeri). Le viste di iOS non si toccano: attenzione a `scegliStrumentoAnalisi` condiviso.

### 64.7 Dimensione

**L** (oltre 500 righe). File principali: `Shell/SimulaConfronta.swift` (nuovo), `Motori/MotoreSimulaConfronta.swift`
(nuovo), `Motori/TestiSimulaConfronta.swift` (nuovo), `Shell/AnalisiStrumenti.swift`, `Shell/AppAnalisi360.swift`,
`Shell/StatoShell.swift`, `Shell/AppAccorpate.swift`, `Shell/Analisi360Apple.swift` (la fila del piede),
`Shell/FamiglieComeLaSua.swift`, `DesignSystem/Apple/Tema.Apple+Strumenti360.swift`, `Istantanee.swift`.

---

## 65. Le note stanno con il cliente

### 65.1 Nel template

Codice righe 5066-5088 (`NOTE`, `SEZ_N.note`, `notaRifai` e i tre ascoltatori su `stage`), regola a riga 2904. Si apre
con `MIG11b[2]`: `notaSel=0; vaiCli(0,'clienti', tabCli='note')`, cartellino su `#notaE`.

Nel dossier, sezione **Note**:
- la testata della sezione (`sezT`): «**Note**», sottotitolo «**un elenco solo · si salvano da sole**», a destra
  «**＋ Nuova nota**» (primario);
- una griglia `300px 1fr`, alta quanto la sezione (minimo 420):
  - **a sinistra l'elenco** (`#notaL`, card): ogni riga (`notaR`) ha il titolo in grassetto («Senza titolo» se vuoto),
    la stella arancio «★» se è in evidenza, la data a destra (12, grigio: «5 nov», «oggi»), sotto la prima riga del
    testo («Nota vuota» se vuoto) e, se è diventata un da fare, la pillola verde «**Nel Da fare**». La riga scelta è
    accesa. Senza note: «Nessuna nota, per ora.»;
  - **a destra la nota** (`#notaE`, card padding 18×22, in colonna): il titolo scrivibile (segnaposto «Titolo»), il testo
    scrivibile (segnaposto «Scrivi qui…»), poi sotto un filo la fila: «**★ In evidenza**» (acceso) / «**☆ Metti in
    evidenza**», «**✓ È nel Da fare**» / «**Fanne un «Da fare»**», e a destra «**Elimina**»; sotto, in grigio: per la nota
    in evidenza «È la nota che ritrovi in Panoramica e in «Prima dell’incontro».», per le altre «Modificata oggi» /
    «Modificata il <data>» + «. Quella in evidenza si vede anche in Panoramica.». Senza nota scelta: «Scegli una nota, o
    scrivine una nuova.».
- Comportamenti: «＋ Nuova nota» mette una nota vuota **in cima** e porta il cursore nel titolo; Invio nel titolo passa al
  testo; si scrive lì e si salva da solo (la data diventa «oggi», il titolo e la prima riga si aggiornano nell'elenco
  mentre si scrive); «Metti in evidenza» toglie la stella alle altre (**una sola**) e il testo della nota diventa quello
  di «Da ricordare» («In evidenza: la ritrovi in Panoramica e prima dell’incontro» / «Tolta dall’evidenza»); «Fanne un
  «Da fare»» crea il da fare per oggi (««<titolo>» è nel Da fare di <nome>, per oggi») e la riga mostra «Nel Da fare»;
  «Elimina» toglie la nota («Nota eliminata»).
- Le note di partenza di ogni cliente: «Da ricordare» (la nota di sempre, in evidenza) e una seconda nota.

La regola (riga 2904-2907): «… «Metti in evidenza» (una sola: è quella della Panoramica e di «Prima dell'incontro», e
prende il posto di «Da ricordare»); «Fanne un Da fare»; «Elimina». **La nota vocale arriva qui. L'app Note a parte non
serve più: le note di tutti i clienti si trovano dalla ricerca.**»

### 65.2 Nell'app oggi

- **Tre posti.** (1) «Da ricordare» è `Cliente.nota` (`Dati/Modelli.swift:39`), scritta nella scheda Note del dossier
  (`AppClienti.note(_:)`, `Shell/AppClienti.swift:395`, `TestoRinviato` + `TextEditor`, «Si salva da sola») e mostrata
  in Panoramica (`DaRicordareApple`, `Shell/DossierPanoramica.swift:325`, con «Scrivi una nota ›»); la leggono anche
  Vera (`Vera/ContestoVera.swift:38`, `Vera/MotoreSintesi.swift:135`) e viaggia in «Prisma ovunque» nell'anagrafica
  (`EntitaOvunque.anagrafica`: «note»). (2) Il taccuino: l'app **Note** con finestra propria fuori dal dock
  (`AppPrisma.note`, `Shell/AppNote.swift:11`: indice con ricerca e filtro per cliente, pagina a righe, «Crea attività»,
  «Esporta .txt»); nel dossier, sotto «Da ricordare», l'elenco «Nel taccuino» (`AppClienti.swift:415-439`) che apre l'app
  Note, e «Nuova nota per <nome>» (:443-446, `nuovaNota` + `apri(.note)`). (3) La nota vocale dall'iPhone arriva come `Nota` «Nota dall’iPhone: …»
  (`Motori/ApplicaNotaVocale.swift:44`), cioè nel taccuino.
- Il modello `Nota` (`Dati/Nota.swift:4`): `clienteId`, `titolo`, `testo`, `fissata` («resta in cima», più di una
  possibile), `creataIl`, `aggiornataIl`; ordine `Nota.ordina` (:51: le fissate prima, poi le più recenti). Nel file del
  cliente (`ArchivioPezzi`), nei backup e in «Prisma ovunque» (`EntitaOvunque.nota`).
- Le funzioni: `stato.nuovaNota(clienteId:)` (`Shell/StatoShell.swift:1117`), `eliminaNota` (:1173),
  `bozzaAttivitaDaNota` (:1180, apre `ModuloAttivita` precompilato), `noteCliente(_:)`, `aggiornaNota` (per
  `Cliente.nota`), `scegliNota`, `togliNoteVuote`.
- L'attività (`Attivita`, `Dati/Modelli.swift:548`) non sa da quale nota è nata (solo il testo «Dalla nota «…».» in
  `note`).
- **Mancano**: l'elenco con la nota a fianco nel dossier, una sola nota in evidenza che prende il posto di «Da
  ricordare», «Fanne un «Da fare»» in un tocco con lo stato «Nel Da fare», la fine dell'app Note sul Mac.

### 65.3 Cosa fare

1. **La sezione Note del dossier** (Mac): `AppClienti.note(_:)` diventa una vista nuova `NoteDossierMac` (file nuovo
   `Shell/DossierNote.swift`, `#if os(macOS)`), con la testata della sezione (titolo «Note», sottotitolo «un elenco solo ·
   si salvano da sole», «＋ Nuova nota» `.applePrimario`) e `ColonneAffiancate(larghezza: token 300)`:
   - **l'elenco** (`LazyVStack` in `ScrollView`, card piatta): le note del cliente. `stato.noteCliente(id)`
     (`StatoShell.swift:1102`) filtra e ordina **tutte** le note dell'archivio e `CacheClienti` non tiene le note: nel
     body va in un dato ricavato, `stato.ricavato("note-dossier|\(id)|\(stato.versioneNote)") { … }` (le note sono
     escluse da `versioneCalcoli`, `DerivatiDati.stessiCalcoli`; hanno la loro `versioneNote`, `StatoShell.swift:80`,
     come fa già `StatoTraguardi.swift:38`). In testa la nota in evidenza, poi le altre per data (vedi punto 3); la riga con il titolo
     (`titoloMostrato`; «Senza titolo» al posto di «Nota senza titolo», miglioria 10), la stella se in evidenza (glifo
     `star.fill`, arancio del tema), la data breve (`Formati.giornoMeseBreve`, «oggi» se è di oggi), l'anteprima
     (`anteprima`, «Nota vuota»), la pillola verde «Nel Da fare» se c'è un'attività aperta nata da quella nota. Menu
     contestuale della riga: «Esporta .txt…» (la funzione di oggi, decisione 65-d) ed «Elimina».
   - **la nota** a destra: il titolo e il testo scrivibili con i campi di oggi di `AppNote` (`CampiNota`, `Rinvio`, le
     attese `attesaNota`): si salvano da soli a fine scrittura (`TestoRinviato`/`Rinvio`, come chiede CLAUDE.md per i
     campi che scrivono dati dei calcoli); segnaposti «Titolo» e «Scrivi qui…»; Invio nel titolo porta al testo (`@FocusState`).
     Sotto un filo la fila: «Metti in evidenza» / «In evidenza» (`.apple`, acceso con il glifo pieno), «Fanne un «Da
     fare»» / «È nel Da fare» (spento quando c'è già), «Elimina» a destra; sotto la riga grigia del template. Senza nota
     scelta: «Scegli una nota, o scrivine una nuova.».
   - «＋ Nuova nota»: `stato.nuovaNota(clienteId: c.id)` (c'è già: mette la nota nuova, toglie le vuote) e il fuoco nel
     titolo; la nota nuova sta in cima finché è vuota (decisione 65-c).
2. **«Da ricordare» diventa la nota in evidenza** (decisione 65-a). Proposta senza campi nuovi:
   - `Cliente.nota` resta il campo di sempre (Vera, «Prisma ovunque», iPhone e iPad lo leggono e lo scrivono);
   - nell'elenco compare come una nota «**Da ricordare**» (una riga virtuale, id fisso `"da-ricordare|\(cliente)"`) quando
     non è vuota o quando nessuna nota è in evidenza; scriverci scrive `Cliente.nota` (con `aggiornaNota` e il
     `TestoRinviato` di oggi);
   - «Metti in evidenza» su una `Nota` la fissa (`fissata = true`) e toglie `fissata` alle altre note del cliente (**una
     sola**); da quel momento Panoramica, «Prima dell'incontro» (miglioria 20) e Vera leggono il testo di quella nota:
     nuova funzione `stato.notaInEvidenza(_ cliente:) -> (titolo: String, testo: String)?` = la nota fissata più recente,
     altrimenti `Cliente.nota` se non è vuota. `DaRicordareApple` usa questa funzione (il titolo della card resta «Da
     ricordare»; «Scrivi una nota ›» porta alla sezione Note); `ContestoVera` e `MotoreSintesi` pure (stesso limite di
     caratteri di oggi).
   - «Tolta dall’evidenza» rimette in evidenza «Da ricordare» se non è vuota.
3. **Una sola in evidenza nei dati di prima.** Gli archivi possono avere più note fissate per cliente: si mostra in
   evidenza la più recente, le altre si mostrano come note normali; la prima volta che l'utente tocca la stella di un
   cliente, le altre fissate si sfissano. `Nota.ordina` resta per iOS; il Mac ordina con `NoteDossierMac.ordine` (in
   evidenza, poi per `aggiornataIl`).
4. **«Fanne un «Da fare»»**: crea subito un'`Attivita` per oggi senza aprire il modulo: si parte da
   `stato.bozzaAttivitaDaNota(id)` (c'è già, `StatoShell.swift:1180`: `Attivita.nuova(clienteId:)` con scadenza oggi,
   titolo della nota, `note` «Dalla nota «…».»), si mette il titolo «La nota del \(data)» se è vuoto e `daNota`, e si
   salva con `stato.salvaAttivita(_:)` (:3030), e mostra l'avviso
   ««\(titolo)» è nel Da fare di \(nome), per oggi» con «Annulla» (`mostraAvviso(_:azione:)`, miglioria 68: ogni cosa si
   può annullare). Per sapere che la nota «è nel Da fare» serve il legame (decisione 65-b).
5. **«Elimina»** senza conferma, con l'avviso «Nota eliminata» e «Annulla» che la rimette (la nota resta in memoria fino
   alla chiusura dell'avviso). La riga virtuale «Da ricordare» non si elimina: «Svuota» la svuota.
6. **L'app Note sparisce dal Mac.** `AppPrisma.note.ospite` = `.clienti` solo su macOS (come Documenti e Obiettivi), e
   `preparaOspite(per: .note)` (`Shell/AppAccorpate.swift:8`; `accorpataMostrata` restituisce `.note` sulla scheda
   Note) mette `schedaCliente = .note` e, se c'è `notaSelezionata`, il cliente di quella nota come
   cliente attivo. Così `stato.vai(a: .nota(id))` (ricerca, Vera, copilota, traguardi, nota vocale) apre il dossier del
   cliente sulla nota giusta. «Nuova nota» dalla ricerca (`Shell/Ricerca.swift:661`) apre la sezione Note del cliente
   attivo con la nota nuova. `AppPrisma.altreApp` sul Mac perde «Note». La ricerca trova già le note (miglioria 61: il
   gruppo «Note» dei risultati porta qui).
7. **Cosa sparisce dal dossier**: il `TextEditor` «Da ricordare» a tutta larghezza, l'elenco «Nel taccuino» e «Nuova nota
   per <nome>». `MessaggiNoteDossier` (i messaggi preparati, «Scrivi a …») resta sotto la griglia, a tutta larghezza
   (decisione 65-e).
8. **Token** in `DesignSystem/Apple/Tema.Apple+Dossier.swift`, `enum Note`: `larghezzaElenco` 300, `altezzaMinima` 420,
   `paddingNota` 18×22, `rigaElenco` (titolo 14 semibold, anteprima 12,5, data 12), `spazioRighe`, `titoloNota` (come il
   titolo della pagina di `AppNote`, 22 bold), `testoNota` (15, interlinea 1,5), colore della stella (arancio del tema).
9. **Testi** in `TestiNoteDossier` (nuovo): «Note», «un elenco solo · si salvano da sole», «＋ Nuova nota», «Senza
   titolo», «Nota vuota», «Nessuna nota, per ora.», «Nel Da fare», «Titolo», «Scrivi qui…», «Metti in evidenza», «In
   evidenza», «Fanne un «Da fare»», «È nel Da fare», «Elimina», «Svuota», «È la nota che ritrovi in Panoramica e in
   «Prima dell’incontro».», «Modificata oggi», «Modificata il \(data)», «. Quella in evidenza si vede anche in
   Panoramica.», «Scegli una nota, o scrivine una nuova.», «In evidenza: la ritrovi in Panoramica e prima
   dell’incontro», «Tolta dall’evidenza», ««\(t)» è nel Da fare di \(nome), per oggi», «Nota eliminata», «Da ricordare».

Cosa NON fare: non convertire `Cliente.nota` in una `Nota` (lo leggono iPhone, iPad e «Prisma ovunque»); non togliere
`AppNote` dal codice (serve a iOS); non scrivere nell'archivio a ogni tasto.

### 65.4 Dati, archivio, privacy

- **Nessun campo nuovo per le note.** `Nota.fissata` diventa «in evidenza» (una per cliente, regola dell'interfaccia
  del Mac); `Cliente.nota` resta «Da ricordare».
- **Un campo facoltativo in `Attivita`** (decisione 65-b): `daNota: String?` (id della nota da cui è nata). Sta con le
  attività (sezione `attivita` di `ArchivioPezzi`, già il loro posto), entra nei backup, viaggia in «Prisma ovunque» con
  `EntitaOvunque.attivita` (opzionale: un giornale di prima o un iPhone non aggiornato lo ignorano; la stessa struttura
  è usata da tutti i dispositivi, quindi non si perde nella codifica). `ProvaBackupArchivioPezzi` rilegge un'attività con
  e senza `daNota`; `--prova-ovunque` controlla che un'attività con `daNota` passi dal giornale intatta.
- Privacy: le note restano nel file del cliente come oggi. In modalità cliente la sezione Note del dossier si vede? Oggi
  la scheda Note del dossier è visibile anche in modalità cliente: **proposta** (decisione 65-f) nasconderla in
  modalità cliente o mostrare solo la nota in evidenza, perché il taccuino contiene appunti del consulente.

### 65.5 Istantanee e prove

- Da aggiornare: **«61-clienti-note»** (`Istantanee.swift:469`: Marco, sezione Note con l'elenco e la nota «Da
  ricordare» in evidenza) e **«60-note»** (:465: `apri(.note)` con `nota-giulia` ora apre il dossier di Giulia sulla
  nota), le istantanee del dossier che mostrano «Da ricordare» in Panoramica (`IstantaneeDossierApple.swift`) e le
  istantanee della nota vocale arrivata (**«771-nota-arrivata»**, **«772-nota-confermata»**: la nota compare
  nell'elenco del cliente).
- Nuove (chiara e scura, blocco «14xx-uso»): **«1405-uso-clienti-note-in-evidenza»** (una nota del taccuino in
  evidenza: Panoramica la mostra), **«1406-uso-clienti-note-da-fare»** (una nota con «Nel Da fare»),
  **«1407-uso-clienti-note-vuote»** («Nessuna nota, per ora.»).
- Prove: in `--prova-vera` (o nei controlli dello stato) che `notaInEvidenza` dia la nota fissata più recente e altrimenti
  `Cliente.nota`, e che Vera la riceva nel contesto; in `--prova-backup` `Attivita.daNota`; in `--prova-ovunque` l'attività
  con `daNota`. Le istantanee iOS «18-note», «47-note» non cambiano.

### 65.6 Decisioni per l'utente e rischi

- **65-a «Da ricordare» e la nota in evidenza.** Il template copia il testo della nota fissata in «Da ricordare».
  **Proposta:** non copiare (due testi uguali in due posti si separano): «Da ricordare» è una riga dell'elenco e la nota in
  evidenza è *o* lei *o* una nota del taccuino; Panoramica, «Prima dell'incontro» e Vera leggono `notaInEvidenza`.
- **65-b Il legame nota → da fare.** Serve per «È nel Da fare» / «Nel Da fare». **Proposta:** il campo facoltativo
  `Attivita.daNota`; alternativa senza campi: riconoscere il testo «Dalla nota «…».» in `Attivita.note` (fragile se il
  titolo della nota cambia). Quando l'attività è completata, la pillola sparisce (la nota torna «Fanne un «Da fare»»).
- **65-c L'ordine.** Il template mette la nota nuova in cima e poi lascia l'ordine com'è. **Proposta:** in evidenza in
  cima, poi per data di modifica (come oggi), con la nota nuova in cima finché è la più recente.
- **65-d «Esporta .txt».** Il template non lo mostra. **Proposta:** nel menu contestuale della riga.
- **65-e I messaggi del dossier** (`MessaggiNoteDossier`). Oggi stanno nella scheda Note. **Proposta:** restano sotto la
  griglia; con la miglioria 25 (Messaggi segue il cliente) si può spostarli nella Panoramica.
- **65-f Modalità cliente.** **Proposta:** in modalità cliente la sezione mostra solo la nota in evidenza, in sola
  lettura, senza l'elenco.
- Rischi: la scrittura nel titolo e nel testo deve restare locale fino alla pausa (`Rinvio`), altrimenti l'elenco si
  ridisegna a ogni tasto; l'elenco aggiorna titolo e anteprima solo quando la bozza passa allo stato (0,3 s), non a ogni
  lettera (accettabile; il template lo fa subito). I clienti con molte note: `LazyVStack`.

### 65.7 Dimensione

**M** (150-500 righe). File principali: `Shell/DossierNote.swift` (nuovo), `Shell/AppClienti.swift`,
`Shell/DossierPanoramica.swift`, `Shell/StatoShell.swift`, `Shell/AppPrisma.swift`, `Shell/AppAccorpate.swift`,
`Dati/Modelli.swift` (`Attivita.daNota`), `Vera/ContestoVera.swift`, `Vera/MotoreSintesi.swift`,
`DesignSystem/Apple/Tema.Apple+Dossier.swift`, `Istantanee.swift`.

---

## 69. Il TFR: prima la risposta

### 69.1 Nel template

Codice righe 5100-5147 (`TFRD`, `tfConto`, `tfPari`, `tfSinistraHTML`, `tfDestraHTML`, `tfLegaD`, `montaTfr`), CSS righe
801-806, regola a riga 2920-2931. Si apre con `MIG11c[0]`: `cfM='tfr'; vaiCli(3,'analisi', vistaA='conf')`, cartellino
su `#cfFrase` («Prova con Marco: non è un dipendente, e Prisma lo dice»).

È la **terza voce** del segmentato di «Simula e confronta» («Il TFR»), al posto dello strumento TFR.

**A sinistra** (`tfSinistraHTML`, riga 5114), per un dipendente:
- l'occhiello «**Il lavoro di <nome>**» (nel template « · conto di prova» per chi non ha dati);
- se c'è una nota sul lavoro (Sofia nella scuola pubblica): la pillola arancio «**Da verificare**» e sotto il testo
  («Sofia lavora nella scuola pubblica: lì il TFR segue regole a parte. Questo conto è solo indicativo.»);
- **tre cursori soli**: «**Retribuzione lorda dell’anno**» (15.000-150.000, passo 1.000, euro), «**Anni che mancano alla
  pensione**» (1-42, «<n> anni»), «**Quanto rende il fondo, netto**» (0-6, passo 0,5, «<x>% l’anno»);
- il collegamento «**Altre ipotesi ⌄**» (la freccia si gira): apre «Inflazione» con «1% | 2% | 3%» e «Contributo suo e
  dell’azienda» con «no | 1% | 1,5% | 2%», e la nota «Qui stanno anche le altre voci di oggi: crescita della
  retribuzione, anni già fatti, TFR già maturato, dipendenti dell’azienda.»;
- in fondo, dopo un filo, le ipotesi in grigio: «Le ipotesi: la retribuzione cresce dell’1% oltre l’inflazione; in
  azienda il TFR si rivaluta dell’1,5% più tre quarti dell’inflazione.».

**A destra** (`tfDestraHTML`, riga 5122), in quest'ordine:
1. `#cfFrase` (card 16×22): occhiello «**Il TFR di <nome>: in azienda o nel fondo pensione**», la frase (`.tfFr`, 21
   bold, tracking −0,4, interlinea 1,33):
   - differenza oltre il 3% del TFR in azienda: «**Tra <n> anni, con il TFR nel fondo pensione <nome> avrebbe circa
     <diff> in più che lasciandolo in azienda.**» (la cifra in verde; «Tra un anno» per un anno);
   - differenza fra 0 e 3%: «Tra <n> anni la differenza è piccola: nel fondo pensione <nome> avrebbe <diff> in più.» e,
     con otto anni o meno, « Mancano pochi anni: qui conta più la tranquillità che il conto.»;
   - differenza negativa: «Con queste ipotesi a <nome> conviene lasciarlo in azienda: nel fondo avrebbe <diff> in meno.»
     («ad» davanti a vocale);
   sotto (14,5): con il contributo «Se ci aggiunge <c>% di suo, <euro> l’anno, l’azienda mette altrettanto: alla fine
   avrebbe <x> in più, di cui <y> versati di tasca sua.» (o «…, ma ne avrebbe versati <y> di tasca sua» o «anche così
   resterebbe sotto»), poi «In soldi di oggi la differenza è <r>.». Le cifre sono arrotondate (alle decine sotto 10.000,
   alle centinaia sopra: `tfE`);
2. `#tfStrade` (card): «**Le strade: quanto resta in mano, tolte le tasse**» e una barra per strada (`.tfB`, alta 10):
   «Lasciato in azienda» (grigio), «Nel fondo pensione» (viola) con accanto la pillola «+ <diff>» verde o «− <diff>»
   arancio, e con il contributo «Nel fondo, con il contributo suo e dell’azienda» (accento) con la sua differenza;
3. `#tfPerche`, tre riquadri (`.tfV` 20 bold): «**Le tasse quando lo incassa**» «<az>% → <fo>%» (grigio → verde) e «In
   azienda paga l’aliquota media dei suoi redditi. Nel fondo scende con gli anni, fino al 9%.»; «**Il contributo
   dell’azienda**» «+ <euro> l’anno» e «Arriva solo se versa anche <nome>. Oggi quei soldi non li prende.» (senza
   contributo «non contato», «Si aggiunge in «Altre ipotesi».»); «**Il rendimento che serve al fondo**» «<x>% l’anno» e
   «In azienda il TFR cresce <r>% l’anno, senza sorprese. Nel fondo dipende dai mercati: sopra questa soglia conviene il
   fondo.» (o «anche a zero» e «Con le tasse più basse il fondo conviene anche se non rendesse niente. …»);
4. `#tfCambia` (card): «**Cosa cambia per <nome>**» e due righe con il pallino (`.tfC`): «Nel fondo i soldi restano fino
   alla pensione: prima si possono chiedere solo gli anticipi previsti, per la casa o le spese mediche.» e «La scelta
   del fondo non si può disfare. Lasciarlo in azienda sì: può cambiare idea quando vuole.»;
5. la fila: «**Fanne un prospetto per <nome>**» (primario), «**Chiedi a Vera di spiegarlo**», a destra «Stime con le
   ipotesi qui a sinistra: non sono promesse.».

**Se il cliente non lavora da dipendente** (riga 5114 e 5123): a sinistra «Il lavoro di <nome>», «<professione>. Nel
dossier non risulta un lavoro da dipendente.» e in grigio «Il TFR matura solo per chi lavora da dipendente. Se il dato
del dossier è sbagliato, si corregge in Anagrafica.»; a destra la card con «Il TFR di <nome>», la frase «**<nome> lavora
in proprio: il TFR non c’è.**», il testo «Il TFR matura solo per chi lavora da dipendente. Per <nome> la domanda è
un’altra: quanto mettere da parte, ogni mese, per avere la pensione che vuole.» e i pulsanti «**Apri il conto della
pensione**» (primario: torna su «Le aree» e apre il dettaglio della previdenza) e «**Fai il conto lo stesso**».

La regola (riga 2929): «**I CONTI NON CAMBIANO: restano quelli che l'app fa già.** Qui cambiano l'ordine, le parole e
quante cose sono in vista.»

### 69.2 Nell'app oggi

- `Shell/SimulazioneTFR.swift:11` `SchedaTFR` (953 righe, condivisa con iPhone e iPad), dentro `StrumentoTFR`
  (`Shell/AnalisiStrumenti.swift:28`, testata «TFR · in azienda o nel fondo pensione»).
- **La console** (`console(_:_:)`, :115): **tre gruppi** e molti comandi in colonna. «Lavoratore»: «Retribuzione utile
  al TFR», «Crescita oltre l'inflazione», «Anni con questo datore fino alla pensione», «Inflazione ipotizzata», «Anni già
  fatti con questo datore», «TFR già maturato in azienda», «Dipendenti dell'azienda», «Iscritto all'INPS prima del
  29/4/1993», «TFR conferito al fondo», «Quota di TFR sulla retribuzione»; «Fondo»: «Rendimento del fondo» (netto /
  lordo), il rendimento, «Costi del fondo (ISC)», «Parte in titoli di Stato», «Contributo del cliente», «Contributo del
  datore», «Anni già nella previdenza»; «Fisco»: «Aliquota del TFR in azienda» (stimata / a mano), «Costo dei contributi
  valutato al»… La bozza locale (`bozza`, `salvaBozza` :108) scrive l'archivio solo dopo una pausa.
- **I risultati** (`risultati(_:_:)`, :372): testata con canale, fondo, prospetto/report e PDF (`testata` :447,
  `pulsanti` :486), `fondoGiaConferito` (:421), le pillole delle semplificazioni (`pillole` :437), gli avvisi
  (`TestiTFR.avvisi`), la cifra principale «TFR FUTURO, NETTO, TRA N ANNI» (`principale` :548) con la differenza «+…»,
  gli indicatori (`indicatori` :573, `TesseraAliquoteTFR` :886 «Imposta all'uscita» azienda → fondo), la frase del
  pareggio (`TestiTFR.frasePareggio`), il grafico (:600), il «Dettaglio» (:622, tabella anno per anno, metodo), il piede.
  `BarreStradeTFR` (:704) disegna già le tre strade con la capsula della differenza.
- **Il motore** (`Motori/MotoreTFR.swift`): `EsitoTFR` (:127) con `azienda`, `fondo`, `fondoContributi` (`StradaTFR`
  :84: montante, aliquota, imposta, netto, reale), `differenza`, `differenzaContributi`, `versatoLavoratore`,
  `versatoDatore`, `costoContributi`, `rivalutazioneNetta`, `pareggio` (`PareggioTFR`). I testi in `Motori/TestiTFR.swift`
  (`titoloConfronto`, `frasePareggio`, `perchePareggio`, `avvertenza`, …).
- **Non dipendente**: `nessunTFR(_:)` (:411): «Nessun TFR da confrontare», «Nel dossier: <tipo>. Il TFR spetta solo ai
  lavoratori dipendenti.», «Confronta lo stesso» (`confrontaComunque`); `IpotesiTFR.senzaTFR`
  (`Motori/MotoreTFR.swift:484`) dal `TipoLavoratore` del profilo (`Dati/Modelli.swift:276`: autonomo, gestione
  separata, collaboratore, cassa professionale).
- Prospetto e report: `stato.documentoTFR(report:)` (`Shell/StatoTFR.swift:28`), `ProspettoTFR.swift`: il TFR **non è
  un `SceltaProspetto`** di Prospetti; prospetto, report e PDF si aprono dalla testata della scheda (`testata` :447,
  `pulsanti` :486).
- **Vera: oggi lo strumento TFR non ha «Chiedi a Vera»** (nessun riferimento a Vera in `SimulazioneTFR.swift`) e fra
  gli `SpuntoVera` (`Vera/ModelliVera.swift:152`) non ce n'è uno per il TFR. Il modello del gesto c'è nei simulatori
  delle aree: `SimulatoreProtezioneApple.chiediVera` (`Shell/SimulatoreProtezioneApple.swift:230`: apre Vera e manda
  la domanda dopo `Tema.Apple.SimulatoriAnalisi.ritardoDomandaVera`, con lo spunto).
- **Le note dei ripieghi** sotto i cursori (`console`, :117-127): «Stimata: manca il reddito da lavoro», «Stimati:
  manca la data di nascita (40 anni)», «Stimati: pensione a 67 anni» (da `stato.ripieghiTFR`), quando il valore è
  ancora quello di partenza.
- **Mancano**: la frase in testa con le tre soglie, i tre cursori in vista e il resto «a richiesta», «da dove viene la
  differenza» in tre riquadri con queste parole, «Cosa cambia per <nome>», la schermata del non dipendente con «Apri il
  conto della pensione».

### 69.3 Cosa fare

1. **Il posto.** Sul Mac il TFR è la modalità `.tfr` di «Simula e confronta» (miglioria 64): `SimulaConfrontaMac` con
   «Il TFR» mostra a sinistra `ConsoleTFRMac` e a destra `RisultatiTFRMac` (file nuovo `Shell/SimulaConfrontaTFR.swift`,
   `#if os(macOS)`). La voce «TFR» sparisce dalla barra laterale; `scegliStrumentoAnalisi(.tfr)` sul Mac apre
   «Simula e confronta» su «Il TFR». `SchedaTFR` resta per iPhone e iPad. **La bozza e il salvataggio** restano quelli di
   `SchedaTFR` (`bozza`, `clienteBozza`, `salvaBozza` dopo la pausa, `stato.ipotesiTFR` / `salvaIpotesiTFR`): spostarli
   in un piccolo tipo comune `BozzaTFR` usato da tutte e due le viste, così le regole di oggi (niente scrittura a ogni
   passo del cursore) valgono anche qui.
2. **La colonna di sinistra** (`ConsoleTFRMac`):
   - occhiello «Il lavoro di \(nome)»; se `TestiTFR.avvisi` ha qualcosa (fondo già conferito, tesoreria INPS, maturato
     stimato, …) la pillola «Da verificare» e sotto il primo avviso (gli altri nel «Dettaglio»);
   - **tre cursori** (`ComandoSimulatoreFermo`, `.equatable()`): «Retribuzione lorda dell’anno» (la `retribuzione` di
     oggi, con l'aiuto «quella utile al TFR»; intervallo e passo di oggi `Console.retribuzione`), «Anni che mancano alla
     pensione» (gli `anni` di oggi), «Quanto rende il fondo, netto» (il rendimento con `rendimentoNetto = true`; se la
     bozza è sul lordo, il cursore dice «Quanto rende il fondo, lordo» e la scelta è in «Altre ipotesi»). Sotto i primi
     due restano le note dei ripieghi di oggi («Stimata: manca il reddito da lavoro», «Stimati: …»): sono l'equivalente
     vero del « · conto di prova» del template, che invece non si porta;
   - «Altre ipotesi ⌄» (`.appleSobrio`, freccia che ruota con `Tema.Apple.Moto`, ferma con calmo): apre **tutti gli altri
     comandi di oggi**, nei tre gruppi di oggi (Lavoratore, Fondo, Fisco), con i loro testi: nulla sparisce, ma non sta
     in vista. «Inflazione» e il contributo si possono mettere in cima al gruppo come segmentati del template («1% | 2% |
     3%», contributo suo e del datore insieme «no | 1% | 1,5% | 2%») **solo se** il motore usa lo stesso valore per i due
     contributi; oggi sono due cursori separati: proposta tenerli separati (decisione 69-b). La frase del template «Qui
     stanno anche le altre voci di oggi: …» non si porta: nell'app quelle voci ci sono davvero, sotto;
   - in fondo la riga grigia delle ipotesi, scritta da `TestiTFR` con i valori veri (crescita reale, rivalutazione
     `1,5% + 75% dell'inflazione`, che il motore già usa).
3. **La colonna di destra** (`RisultatiTFRMac`), in quest'ordine:
   1. **la frase**: nuova `TestiTFR.fraseRisposta(nome:)` con le tre soglie del template su `e.differenza` rispetto a
      `e.azienda.netto` (soglia 3%: `static let sogliaDifferenzaPiccola = 0.03`; «pochi anni»: `anni <= 8`, costante
      `anniPochi = 8`), la cifra arrotondata come `tfE` (nuova `CifreDoc.euroArrotondato`: alle decine sotto 10.000, alle
      centinaia sopra), l'articolo «a/ad»; sotto, `TestiTFR.sottoRisposta`: il contributo (con `fondoContributi`,
      `versatoLavoratore`, `differenzaContributi`, `tascaPropria`) e «In soldi di oggi la differenza è \(…)» (dal `reale`
      delle due strade). La cifra principale si conta (`NumeroCheConta`);
   2. **le strade**: `BarreStradeTFR` di oggi con il titolo «Le strade: quanto resta in mano, tolte le tasse» e le
      etichette «Lasciato in azienda», «Nel fondo pensione», «Nel fondo, con il contributo suo e dell’azienda» (oggi
      `TestiTFR.stradaAzienda` «TFR in azienda», `stradaFondo`, `stradaContributi` «Fondo con contributi»: cambiarli
      solo per il Mac o per tutti, decisione 69-c); la pillola della differenza c'è già (`capsulaDifferenza`);
   3. **da dove viene la differenza**, tre riquadri: «Le tasse quando lo incassa» (`TesseraAliquoteTFR` di oggi o una
      tessera nuova con `e.azienda.aliquota` → `e.fondo.aliquota` e il testo del template, «fino al 9%» dalla costante
      fiscale `previdenzaMinima` di oggi, non scritta a mano); «Il contributo dell’azienda» («+ \(versatoDatore /
      anni) l’anno» o «non contato»); «Il rendimento che serve al fondo» (da `e.pareggio`: la soglia nella base netta;
      «anche a zero» quando il pareggio è sotto zero; la rivalutazione in azienda da `e.rivalutazioneNetta`). I testi in
      `TestiTFR` (`tasseUscita`, `contributoAzienda`, `rendimentoCheServe` con i testi esatti del template);
   4. **«Cosa cambia per \(nome)»**: le due righe del template, fisse, in `TestiTFR.cosaCambia` (sono regole, non cifre);
   5. **il piede**: «Fanne un prospetto per \(nome)» (`.applePrimario`: fa quello che oggi fanno i pulsanti della
      testata, `pulsanti` :486 con `documentoTFR(report:)`; il TFR non sta nell'elenco di Prospetti, quindi niente
      «lo trovi in Prospetti»: prospetto per te e report per il cliente restano le due uscite di oggi, nel menu
      «Altro ⌄» con salva, archivia e stampa), «Chiedi a Vera di spiegarlo» (**nuovo**: oggi non c'è; stesso gesto di
      `SimulatoreProtezioneApple.chiediVera`, con uno spunto nuovo `SpuntoVera.tfr` — domanda «Spiegami il TFR: in
      azienda o nel fondo?» — e le cifre di `EsitoTFR` nella fonte, in modalità lavoro, mai cifre di Qwen; l'aggiunta di
      un caso a `SpuntoVera` va controllata con `--prova-vera`), a destra «Stime con le ipotesi qui a sinistra: non sono
      promesse.»;
   6. **«Dettaglio ⌄»** (chiuso di base, `mostraDettaglio` di oggi): il grafico, la tabella anno per anno, le pillole delle
      semplificazioni, gli altri avvisi, il metodo, `fondoGiaConferito`. Le uscite del PDF di oggi (salva, archivia,
      stampa) restano nel menu «Altro ⌄» della testata dello strumento.
4. **Non dipendente** (`senzaTFR != nil` e non `confrontaComunque`): a sinistra «Il lavoro di \(nome)», «\(professione o
   tipo.nome). Nel dossier non risulta un lavoro da dipendente.» e in grigio «Il TFR matura solo per chi lavora da
   dipendente. Se il dato del dossier è sbagliato, si corregge in Anagrafica.» (con un collegamento che apre
   l'anagrafica del cliente); a destra la card: «Il TFR di \(nome)», la frase `TestiTFR.fraseSenzaTFR(tipo, nome)` («\(nome)
   lavora in proprio: il TFR non c’è.» per autonomo, gestione separata e cassa professionale; per il collaboratore
   «\(nome) è un collaboratore: il TFR non c’è.», decisione 69-d), il testo del template, «Apri il conto della
   pensione» (`.applePrimario`: `scegliStrumentoAnalisi(nil)`, vista «Le aree», e apre il dettaglio della previdenza
   come fa oggi la card dell'area, `PresentatoreAree360`) e «Fai il conto lo stesso» (`confrontaComunque = true`).
5. **Token** in `DesignSystem/Apple/Tema.Apple+Strumenti360.swift` (`enum TFR` dentro `SimulaConfronta`) o in
   `Tema.Apple.ConfrontoTFR` che c'è già: `frase` (21 bold, tracking −0,4, interlinea 1,33), `paddingFrase` 16×22,
   `cifraTessera` (20 bold, tracking −0,3), `barra` 10, `rigaCambia` (13,5, interlinea 1,45, pallino 5), `spazioBlocchi` 10.
6. **Testi** (in `TestiTFR`): tutti quelli di 69.1, con i nomi delle strade decisi in 69-c.

Cosa NON fare: **non toccare `MotoreTFR`** né le sue costanti (regola 2929); non portare `tfConto`, `tfPari`, `TFRD`,
le aliquote 23-38% o «fino al 9%» scritti a mano; non togliere comandi: vanno sotto «Altre ipotesi»; non cambiare
`SchedaTFR` per iOS.

### 69.4 Dati, archivio, privacy

Nessun campo nuovo. Le ipotesi restano `IpotesiTFR` nel file del cliente (`confrontiTFR`), con la stessa bozza e lo
stesso salvataggio di oggi. Lo stato «Altre ipotesi aperto» e «Dettaglio aperto» resta in memoria. Nessun dato esce dal
Mac; «Chiedi a Vera» usa Qwen sul Mac come gli altri simulatori, con le cifre di Prisma.

### 69.5 Istantanee e prove

- Da aggiornare (chiare e scure): **«204-analisi360-tfr»** (la frase, le strade, i tre riquadri), **«207-analisi360-tfr-
  rendita»** (con il contributo: la terza strada e la frase sotto con «di tasca sua»), **«208-analisi360-tfr-autonomo»**
  (Marco non dipendente: «lavora in proprio», «Apri il conto della pensione»). «205-tfr-prospetto» e «206-tfr-report» non
  cambiano.
- Nuove (blocco «14xx-uso»: 210 e 211 sono già di «210-clienti-riesami» e «211-riesame-prospetto-variazioni»):
  **«1408-uso-analisi360-tfr-piccola»** (pochi anni, differenza sotto il 3%: «la differenza è piccola … Mancano pochi
  anni»), **«1409-uso-analisi360-tfr-azienda»** (rendimento del fondo basso: «conviene lasciarlo in azienda»),
  **«1410-uso-analisi360-tfr-altre-ipotesi»** («Altre ipotesi» aperto: tutti i comandi di oggi).
- Prove: `ProvaCalcoliTFR` (`--prova-calcoli`) non cambia nei conti; aggiungere i controlli di `TestiTFR.fraseRisposta`
  (tre soglie, «Tra un anno», «ad Anna»), dell'arrotondamento `euroArrotondato` e di `fraseSenzaTFR` per ogni
  `TipoLavoratore`. `ProvaProspettiTFR` non cambia. In `--prova-vera`: lo spunto nuovo `.tfr` porta a Qwen le cifre di
  `EsitoTFR` e nessun dato in più.

### 69.6 Decisioni per l'utente e rischi

- **69-a Le parole dei tre cursori.** Il template scrive «Retribuzione lorda dell’anno» e «Anni che mancano alla
  pensione»; l'app «Retribuzione utile al TFR» e «Anni con questo datore fino alla pensione», più precisi. **Proposta:**
  le parole del template, con l'aiuto al passaggio del puntatore che dice la definizione esatta di oggi.
- **69-b Il contributo e l'inflazione come segmentati.** Il template mette un solo contributo «suo e dell’azienda» a
  scelta fissa; l'app ha due cursori (cliente e datore, che possono differire) e un'inflazione continua. **Proposta:**
  tenere i comandi di oggi dentro «Altre ipotesi» (nessuna perdita di precisione).
- **69-c I nomi delle strade.** «Lasciato in azienda», «Nel fondo pensione», «Nel fondo, con il contributo suo e
  dell’azienda» al posto di «TFR in azienda», «Nel fondo pensione», «Fondo con contributi». **Proposta:** cambiarli in
  `TestiTFR` per tutti (anche nei PDF e su iPhone e iPad: sono solo parole), dopo aver guardato le istantanee 205-206.
- **69-d Il non dipendente che non «lavora in proprio».** Il collaboratore in gestione separata non è un lavoratore in
  proprio. **Proposta:** frase per tipo (vedi 69.3, punto 4).
- **69-e La nota «Da verificare».** Il template la mostra per un dipendente pubblico (TFS). L'app non distingue il
  pubblico impiego. **Proposta:** usare gli avvisi che il motore già dà; il pubblico impiego resta fuori da questo giro
  (eventuale campo futuro in `DatiLavoro`, da decidere a parte).
- **69-f «Chiedi a Vera di spiegarlo».** È nel template ma oggi lo strumento TFR non ce l'ha: serve uno spunto nuovo
  di Vera (`SpuntoVera.tfr`, prompt in `Vera/`). **Proposta:** sì, sul modello dei simulatori delle aree (solo cifre di
  Prisma); in alternativa, per questo giro, il pulsante non c'è.
- Rischi: `SchedaTFR` è lunga e condivisa: la versione Mac va scritta riusando i suoi pezzi (barre, tessere, bozza)
  spostati in tipi comuni, non copiando 900 righe. Il body non deve ricalcolare `MotoreTFR` a ogni ridisegno: l'esito è
  già calcolato dalla bozza; tenerlo in un `ricavato` con la bozza nella chiave o in uno `@State` aggiornato al cambio
  della bozza.

### 69.7 Dimensione

**M** (150-500 righe, riusando i pezzi di `SchedaTFR`). File principali: `Shell/SimulaConfrontaTFR.swift` (nuovo),
`Shell/SimulazioneTFR.swift` (pezzi comuni), `Motori/TestiTFR.swift`, `Vera/ModelliVera.swift` (`SpuntoVera.tfr`),
`Shell/AnalisiStrumenti.swift`,
`DesignSystem/Apple/Tema.Apple+Strumenti360.swift`, `Istantanee.swift`.

---

## 70. Il fascicolo si compone a vista

### 70.1 Nel template

Codice righe 5149-5189 (`PAGP`, `fascS`, `fascDi`, `fascScelti`, `fascPag`, `LOGO_B`, `fascHTML`, `apriFascicolo`, la
ridefinizione di `APPS.prospetti.mount` e di `gira`, `chiudiShow`, `presenta`), CSS righe 807-830, regola a riga 2932.
Si apre con `MIG11c[1]`: `vaiCli(0,'prospetti')` e `apriFascicolo()`, cartellino su `#fsC .fsCop`.

- In Prospetti, la card «**Fascicolo dell’incontro**» («I report scelti in un solo PDF, con la data dell’incontro.»)
  con «**Componi il fascicolo**» resta in fondo alla colonna; il clic apre **una scheda** larga 1080 (`apriScheda`).
  Senza cliente: «Il fascicolo è di un cliente: sceglilo in alto». In Agenda, «Altro › Prepara il fascicolo» apre la
  stessa scheda (riga 3740). Il fascicolo **non è più una voce dell'elenco dei report**.
- La scheda (`fascHTML`, riga 5159): l'occhiello «**Per <nome> · incontro di oggi, 2 novembre**», il titolo «**Il
  fascicolo dell’incontro**» (26 bold, tracking −0,5), poi una griglia `1fr 470px`:
  - **a sinistra «Cosa c’è dentro»**: la riga fissa «**Copertina**» (classe `fissa`, spunta sempre accesa, **non si
    toglie**: non ha `data-f`, il clic non fa nulla; «con la data, il nome e l’indice», «1 pagina», niente frecce; la
    regola di riga 2933 dice «la copertina (sempre)»); poi i report del cliente, ognuno su una riga con la spunta, il nome in grassetto, sotto
    a cosa serve e, per quello dell'incontro di oggi, «· **per l’incontro di oggi**» in verde; a destra «<n> pagine» e due
    frecce (su e giù, spente in cima e in fondo). Le righe tolte hanno il nome grigio. Sotto: «Tocca una riga per metterla
    o toglierla; le frecce cambiano l’ordine. La scelta resta per il prossimo incontro.» (con un solo report: «… c’è un
    solo report pronto. Il fascicolo serve quando ne lasci più di uno: qui basta il suo PDF.»);
  - **a destra la copertina** (`.fsCop`, alta 332): il logo e «Prisma», l'occhiello «FASCICOLO DELL’INCONTRO», il titolo
    «Il punto insieme», «<nome cognome> · <data>»; il riquadro «**DENTRO**» con **l'indice** (titolo e pagina, la prima a
    pagina 2), «Nessun report scelto» se vuoto; in fondo «**Denis Vicenzoni** · Consulenza finanziaria». Sotto
    (`#fsSomma`): «**<n> report · <p> pagine**» e «con la copertina»; oltre le dieci pagine la pillola arancio «**Tante da
    leggere a casa**» e «Lascia quello di cui avete parlato oggi.».
- La fila: «**Salva il PDF · <p> pagine**» (primario grande; senza report «Scegli almeno un report», spento), «**Mostra al
  cliente**» (spento senza report), a destra «Lo ritrovi nei Documenti di <nome>, con la data di oggi.». Salvando:
  «Fascicolo salvato nei Documenti di <nome>: <n> report, <p> pagine».
- Le scelte: di base tutti i report pronti del cliente tranne quelli del gruppo «Fine anno» della miglioria 23
  (`PAG[i].g!==2`: «Un anno insieme»), in ordine di gruppo («Primo incontro», «Per una proposta», «Fine anno»); con un
  solo report, quello. Le pagine sono sempre «report scelti + 1» (la copertina). La scelta e l'ordine **restano per il
  cliente** (`fascS[k]`) fino al prossimo incontro. (Nell'app la scelta di partenza resta quella di oggi:
  `fascicoloPredefinito`, o `perIncontro` dall'Agenda.)
- «Mostra al cliente» chiude la scheda, entra nella vista pulita e presenta **solo i report scelti, nel loro ordine**:
  il contatore dice «1 di 3 · fascicolo», le frecce sfogliano solo quelli (spente con uno solo); chiudendo la
  presentazione si torna normali (righe 5182-5188).

### 70.2 Nell'app oggi

- **Il fascicolo è una voce** (`TipoProspetto.fascicolo`, `Dati/Prospetto.swift:30`) che si apre come gli altri documenti:
  in `ProspettiApple.swift` la card `cardFascicoloApple` (:251: «Fascicolo dell'incontro», «I report scelti in un solo
  PDF, con la data dell'incontro.», «Componi il fascicolo» → `scegliApple(.fascicolo)`), e quando è scelta la card si
  allarga con `contenutoScelta` → `sceltaFascicolo` (`Shell/AppProspetti.swift:417`): un elenco di `Toggle` sui dieci
  `TipoProspetto.inFascicolo` (`Shell/Fascicolo.swift:9`), nell'ordine fisso, senza pagine; l'anteprima a destra mostra
  il fascicolo già composto (copertina, **pagina dell'indice**, report).
- **La scelta** è `stato.sceltaFascicolo: Set<TipoProspetto>` (`Shell/StatoShell.swift:147`, di base
  `fascicoloPredefinito`), **uguale per tutti i clienti**, **senza ordine**, in memoria; `fascicoloAppuntamento` (:149)
  lega il fascicolo a un appuntamento (titolo con data e ora, `titoloFascicolo`). Dall'Agenda `preparaFascicolo(per:)`
  (`Fascicolo.swift:124`) mette i report adatti con `TipoProspetto.perIncontro(_:posizione:)` (:14) e apre il fascicolo;
  lo stesso fanno `TracciaImpegnoApple.swift:77`, `PratichePropostaApple.swift:414`, `StatoPortafoglioApple.swift:114`.
- **La composizione** `stato.documentoFascicolo()` (`Fascicolo.swift:72`): ogni report impaginato una volta con
  `ricavato("fascicolo|tipo|cliente|ora")`, la copertina `CopertinaReport` (`DesignSystem/ComponentiReport.swift:150`;
  occhiello «Fascicolo dell'incontro», titolo «Il punto insieme», `ruolo` e `canali` ricavati dalle posizioni del
  cliente, quindi la firma del canale c'è già e non si scrive a mano) con `cartellini: [("Documenti", [n]), ("Pagine",
  [p])]`, una **pagina di indice** `IndiceFascicolo` (`Fascicolo.swift:139`; oggi le voci cominciano da pagina 3)
  e la numerazione continua (`NumerazioneFascicolo`).
- Salvare e archiviare: i pulsanti di Prospetti (`ProspettiApple.swift:395-411`: «Presenta all'incontro», stampa, salva,
  «Archivia» → `stato.archiviaProspetto`), con «La seconda lettura» di Vera prima di salvare (`AppProspetti.swift:20`) e
  la password del cliente come per ogni documento. «Presenta all'incontro» → `stato.presenta(d, daPagina:)`
  (`Shell/Presentazione.swift:41`) presenta **tutto** il fascicolo, pagina per pagina.
- **Mancano**: la scheda dedicata, l'ordine, le pagine di ogni report, la scelta per cliente, la copertina con l'indice,
  il conteggio delle pagine sul pulsante, l'avviso oltre le dieci pagine, «per l'incontro di oggi» sul report.

### 70.3 Cosa fare

1. **La scelta per cliente e in ordine** (stato in memoria, decisione 70-a): in `StatoShell` sostituire
   `sceltaFascicolo: Set<TipoProspetto>` con `fascicoli: [String: SceltaFascicolo]` per cliente, dove
   `struct SceltaFascicolo { var ordine: [TipoProspetto]; var scelti: Set<TipoProspetto>; var appuntamento: String? }`
   (niente interruttore della copertina: nel template è fissa), e una proprietà calcolata `sceltaFascicolo` (get/set sul cliente attivo) per non
   rompere le chiamate di oggi (`preparaFascicolo`, `TracciaImpegnoApple`, `PratichePropostaApple`,
   `StatoPortafoglioApple`, `ProvaNotte`, `ProvaAnnoInsieme`, `ProvaVera`). L'ordine di partenza è
   `TipoProspetto.inFascicolo` (il template ordina per i gruppi della miglioria 23, «Primo incontro», «Per una proposta»,
   «Fine anno»: se la 23 è già fatta, l'ordine di partenza segue i suoi gruppi); `perIncontro` sceglie i report ma non cambia l'ordine. `fascicoloAppuntamento` passa
   dentro `SceltaFascicolo.appuntamento` (con la stessa proprietà calcolata). La regola di oggi «cambiando cliente si
   scorda l'appuntamento dell'altro» (`ProvaVera.swift:835`) resta vera per costruzione.
2. **Le pagine di ogni report** (`Fascicolo.swift`): `func pagineFascicolo(_ t: TipoProspetto) -> Int?` con
   `ricavato("fascicolo-pagine|\(t)|\(cliente)|\(ora)")` che impagina il report (la stessa `ParteFascicolo` di oggi, già in
   cache per la composizione: riusare la chiave `fascicolo|…` e leggere `pagine.count`). `nil` = il cliente non ha quel
   report (non si mostra nell'elenco: «i report del cliente», come `docDisp` del template).
3. **La copertina con l'indice** (decisione 70-b): `CopertinaReport` riceve un parametro facoltativo `indice: [(String,
   Int)]?`; quando c'è, al posto dei cartellini disegna il riquadro «Dentro» con titolo e pagina (righe con il filetto, i
   caratteri del documento `Tipo.Report`, colori della carta della copertina che c'è già — il PDF resta come oggi, opaco e
   fisso). `documentoFascicolo()` passa l'indice e **non aggiunge più la pagina `IndiceFascicolo`** (le pagine cominciano
   da 2); `IndiceFascicolo` resta solo se l'indice non entra nella copertina (oltre `Misure.Documento.schedeReport + 2`
   voci: lo si decide guardando l'istantanea). La copertina c'è sempre (riga fissa, come nel template).
4. **La scheda** (file nuovo `Shell/ComponiFascicolo.swift`, `#if os(macOS)`, `struct ComponiFascicoloMac: View`), aperta
   come **dettaglio del tema che nasce dalla card** «Fascicolo dell'incontro» (`origineDettaglio(id: "fascicolo")`,
   `.presentatoreDettaglio(dettaglio)` sulla finestra di Prospetti, misura 1080 × 640 come token): 
   - occhiello «Per \(nome) · \(incontro)» («incontro di oggi, \(data)» se c'è un appuntamento oggi o quello di
     `appuntamento`; «\(tipo) del \(data)» per un appuntamento di un altro giorno; senza appuntamento solo «Per \(nome)»),
     titolo «Il fascicolo dell’incontro»;
   - **sinistra «Cosa c’è dentro»**: la riga «Copertina» fissa («con la data, il nome e l’indice», «1 pagina», spunta
     sempre accesa e non attiva, niente frecce); le righe
     dei report del cliente in `ordine`, con la casella (`stileCasella` del tema), il nome, la riga «a cosa serve»
     (`TipoProspetto.inBreve`, miglioria 23), «· per l’incontro di oggi» in verde sul report che la miglioria 23 segna
     nell'elenco dei Prospetti (stessa funzione, stessa regola: decisione 70-d), le pagine («\(n) pagine» / «1
     pagina») e due pulsanti freccia (`chevron.up` / `chevron.down`, 24×24, `.appleSobrio`, spenti in cima/in fondo;
     anche ⌥↑ / ⌥↓ sulla riga a fuoco). Clic sulla riga = spunta. Sotto il testo del template (con un solo report il
     testo per un solo report);
   - **destra**: l'anteprima **vera** della prima pagina (la `CopertinaReport` con l'indice, scalata come le miniature
     dell'anteprima di Prospetti), non un disegno del template; sotto «\(n) report · \(p) pagine» e «con la copertina»;
     con più di 10 pagine la pillola «Tante da leggere a casa» (`.attenzione`) e «Lascia quello di cui avete parlato
     oggi.» (soglia `static let pagineTante = 10`);
   - la fila: «Salva il PDF · \(p) pagine» (`.applePrimario` grande; senza report «Scegli almeno un report», spento):
     compone `documentoFascicolo()`, passa da «La seconda lettura» e dalla password del cliente come oggi e lo
     **archivia** nei Documenti del cliente (`archiviaProspetto`), con l'avviso «Fascicolo salvato nei Documenti di
     \(nome): \(n) report, \(p) pagine»; «Mostra al cliente» (`.apple`, spento senza report): chiude il dettaglio e
     presenta (vedi punto 6); a destra «Lo ritrovi nei Documenti di \(nome), con la data di oggi.» (o «con la data
     dell’incontro» se legato a un appuntamento: il titolo è `titoloFascicolo`). «Salva in un'altra cartella…» e «Stampa…»
     restano in un menu «Altro ⌄» accanto (le uscite di oggi).
5. **Il fascicolo non è più una voce dell'elenco**: in `ProspettiApple` la card resta in fondo alla colonna, senza
   `contenutoScelta`; «Componi il fascicolo» apre il dettaglio. `TipoProspetto.fascicolo` resta (archivio, Vera, notte,
   istantanee): `apriProspetto(.fascicolo)` e `preparaFascicolo(per:)` sul Mac aprono Prospetti con il dettaglio aperto
   (`stato.fascicoloDaAprire = true`, letto da `ProspettiApple` all'apparire). Senza cliente scelto il pulsante dice
   «Scegli prima un cliente» (spento) — con la miglioria 2 il cliente c'è sempre nella barra o la card non c'è.
6. **«Mostra al cliente»** (con la miglioria 1 del gruppo 01 e la 58 del gruppo 10): presenta il documento del fascicolo
   (`documentoFascicolo()`) **dalla prima pagina** nella vista pulita; il contatore della presentazione dice «\(pagina) di
   \(totale) · fascicolo» (`Presentazione.swift`, un'etichetta facoltativa `etichettaContatore`). Decisione 70-c sul
   saltare la copertina.
7. **In Agenda**: «Altro › Prepara il fascicolo» (miglioria 20) chiama `preparaFascicolo(per:)`, che ora apre Prospetti
   con il dettaglio aperto. «Apri il fascicolo» (quando è già archiviato, `fascicoloArchiviato(per:)`) resta com'è.
8. **Token** in `DesignSystem/Apple/Tema.Apple+Prospetti.swift`, `enum Fascicolo`: `misuraDettaglio` 1080×640,
   `titolo` (26 bold, tracking −0,5), `larghezzaAnteprima` 470, `spazioColonne` 26, `rigaReport` (padding 9×4, nome 14,5
   semibold, grigio se tolto), `freccia` 24 / raggio 8, `spazioFrecce` 2, `pillolaTante` (stato attenzione).
   Per la copertina del PDF i token del documento in `Misure.Documento` / `Tipo.Report` (`indiceCopertina`,
   `rigaIndiceCopertina`), colori di `Colori.Documento` (fissi, carta).
9. **Testi** in `TestiFascicolo` (nuovo): «Componi il fascicolo», «Per \(nome) · incontro di oggi, \(data)», «Il
   fascicolo dell’incontro», «Cosa c’è dentro», «Copertina», «con la data, il nome e l’indice», «1 pagina», «\(n) pagine»,
   «per l’incontro di oggi», «Tocca una riga per metterla o toglierla; le frecce cambiano l’ordine. La scelta resta per il
   prossimo incontro.», il testo per un solo report («Per \(nome) c’è un solo report pronto. Il fascicolo serve quando ne
   lasci più di uno: qui basta il suo PDF.»), «Dentro», «Nessun report scelto», «\(n) report · \(p) pagine», «con la
   copertina», «Tante da leggere a casa», «Lascia quello di cui avete parlato oggi.», «Salva il PDF · \(p) pagine»,
   «Scegli almeno un report», «Mostra al cliente», «Lo ritrovi nei Documenti di \(nome), con la data di oggi.»,
   «Fascicolo salvato nei Documenti di \(nome): \(n) report, \(p) pagine», «\(i) di \(n) · fascicolo».

Cosa NON fare: non portare `PAGP` (le pagine le conta l'impaginazione vera), `LOGO_B` né la copertina in CSS del
template; non impaginare i report nel body a ogni spunta (la cache per tipo c'è già); non mettere vetro sul documento.

### 70.4 Dati, archivio, privacy

Nessun campo nuovo nell'archivio: la scelta del fascicolo (report, ordine, copertina, appuntamento) resta **in memoria**
per cliente, fino alla chiusura di Prisma (decisione 70-a). Il PDF salvato è un `Documento` del cliente come oggi
(titolo `titoloFascicolo`), nei backup come ogni documento; la password del cliente vale come oggi. In modalità cliente
(«Mostra al cliente») si vedono solo i report scelti per quel cliente; la scheda di composizione non si apre in modalità
cliente (è lavoro del consulente).

### 70.5 Istantanee e prove

- Da aggiornare: **«81-fascicolo»** (`Istantanee.swift:299`: Marco, ora la scheda «Il fascicolo dell’incontro» aperta,
  chiara e scura) e **«82-agenda-fascicolo»** (:303: dall'appuntamento di Marco, la scheda con «per l’incontro di oggi»
  e i report di `perIncontro` spuntati); «460-prospetti-apple» (la card del fascicolo non si allarga più).
- Nuove (blocco «14xx-uso»): **«1411-uso-fascicolo-tante-pagine»** (tutti i report spuntati: la pillola «Tante da
  leggere a casa»), **«1412-uso-fascicolo-pdf-copertina»** (la prima pagina del PDF con l'indice, presentata come
  «83-presentazione»), **«1413-uso-fascicolo-un-report»** (cliente con un solo report).
- Prove: `ProvaProspetti` (`--prova-prospetti`) — il fascicolo con copertina e indice ha `1 + Σ pagine` pagine (niente
  pagina di indice, la prima voce a pagina 2); l'indice porta i titoli nell'ordine scelto e le pagine giuste; la
  numerazione continua. `ProvaCalcoliNotte.swift:150` (la notte compone il fascicolo nell'ordine di `inFascicolo`
  filtrato da `fascicoloPredefinito`): con l'ordine per cliente l'ordine di partenza resta quello, la prova va
  ricontrollata. `ProvaVera.swift:835` (cambio di cliente) e `ProvaNotte.swift:120` (la notte prepara il
  fascicolo) con la nuova `sceltaFascicolo` calcolata; `ProvaAnnoInsieme.swift:85`. La prova di carico: spuntare una
  riga non impagina altro che la copertina.

### 70.6 Decisioni per l'utente e rischi

- **70-a «La scelta resta per il prossimo incontro».** Il template la tiene per cliente. **Proposta:** in memoria per
  cliente fino alla chiusura di Prisma (nessun campo nuovo); se l'utente la vuole anche dopo la riapertura, un campo
  `Cliente.fascicolo` nel file del cliente (da decidere: tocca archivio e backup).
- **70-b La pagina dell'indice.** Con l'indice sulla copertina la pagina «Cosa trovi in questo fascicolo» non serve.
  **Proposta:** toglierla; se le voci sono troppe per la copertina (oltre 8), tenerla.
- **70-c «Mostra al cliente» parte dalla copertina?** Il template sfoglia solo i report scelti, nel loro ordine (le
  frecce spente con uno solo), senza copertina. **Proposta:**
  partire dalla copertina con l'indice (è ciò che il cliente porta a casa); in alternativa partire dal primo report.
- **70-d Il segno «per l’incontro di oggi».** Il template segna un report solo (`i===cons`), lo stesso dell'elenco dei
  Prospetti. **Proposta:** la stessa regola della decisione 23-c del gruppo 03 (uno solo, il primo di `perIncontro`
  nell'ordine dell'elenco), così le due schermate dicono la stessa cosa; gli altri report di `perIncontro` sono comunque
  spuntati all'apertura. Alternativa: segnarli tutti, ma allora anche nella 23.
- Rischi: contare le pagine di dieci report significa impaginarli tutti all'apertura della scheda (oggi si impaginano
  solo quelli spuntati). Su M1 8 GB: i report sono viste pigre (`AnyView`), l'impaginazione costa ma non disegna; tenerli
  nella cache `ricavato` già usata e, se la prova di carico mostra un'attesa, contare le pagine in un secondo passaggio
  (`Task { @MainActor in … }` dopo la comparsa, con un segnaposto «— pagine» intanto). L'anteprima della copertina è una
  sola pagina scalata.

### 70.7 Dimensione

**M** (150-500 righe). File principali: `Shell/ComponiFascicolo.swift` (nuovo), `Shell/Fascicolo.swift`,
`Shell/ProspettiApple.swift`, `Shell/AppProspetti.swift`, `Shell/StatoShell.swift`, `Shell/Presentazione.swift`,
`DesignSystem/ComponentiReport.swift` (`CopertinaReport`), `DesignSystem/Apple/Tema.Apple+Prospetti.swift`,
`Istantanee.swift`, `Shell/ProvaProspetti.swift`.
