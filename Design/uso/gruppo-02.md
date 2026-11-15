# Gruppo 02 — Clienti, Posizioni, Analisi 360 (migliorie 11-17)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html. Le righe citate sono di quella copia: le regole del gruppo nel commento a
righe 2621-2667, il codice a righe 3366-3693 (MIGLIORIA 11-17), il pannello «✦ Migliorie» (`MIG2`) a riga 3680. Per ciò
che qui non cambia valgono «Luce» (Design/template-luce.html e Design/template-luce-specifica.md) e, sotto, il tema
Apple (Design/template-apple-specifica.md).

Regole che valgono per tutto il gruppo:

- **Solo Mac.** `DossierApple`, `AppPosizioni` e `Analisi360Apple` servono anche l'iPad (e in parte l'iPhone). Le viste
  nuove vanno sotto `#if os(macOS)` o dietro un parametro che l'iPad non usa: iPhone e iPad restano come sono, il loro
  giro viene dopo.
- **La grafica non cambia.** Tema Apple, superfici, caratteri, colori dei canali e delle aree restano; si spostano e si
  raccolgono cose che ci sono già. Ogni misura o colore nuovo diventa un token in `Sources/Prisma/DesignSystem/Apple/`.
- **Le cifre del template sono dimostrative** (`CLI`, `POS`, `PROF`, `tipoP`, `contoP`, le crisi e i costi «ridotti»):
  non si portano. Le cifre le danno i motori che ci sono (`AnalisiDossier`, `MotoreCoerenza`, `CalcoliDettaglio`,
  `CurvaObiettivo`, `MotoreCompletezza`, `MotoreBisogni`, `MotoreAree360`).
- **Il pannello «✦ Migliorie»** (`MIG2`, la funzione `indica(...)` e i cartellini numerati) è solo del template: nell'app
  NON va portato. Lo stesso vale per i `toast(«… resta com'è»)`: dicono che lì l'app tiene il comportamento di oggi.
- **Movimento:** cambi di sezione e di scheda con le transizioni che il dossier ha già (`Tema.Apple.Moto.CambioScheda`,
  uscita y +6 in 0,13 s × ritmo, poi cascata); «Riduci movimento» = dissolvenza 0,15 s; istantanee nello stato finale.
  Niente Timer.
- **Prestazioni:** niente filtri, ordinamenti o motori su tutto l'archivio nei body. I numeri dell'indice e delle schede
  si leggono dalle voci per cliente (`CacheClienti`, `stato.ricavato`), come oggi.
- **«Tutti i clienti» è quello del gruppo 01** (miglioria 2, §2.3): `clienteAttivoId == ""`, `stato.tuttiIClienti`,
  `stato.scegliCliente(nil)`; `stato.portafoglio` diventa una lettura di `tuttiIClienti`. «‹ Rubrica» (11) e «‹ Tutto il
  portafoglio» (14) chiamano `stato.scegliCliente(nil)`: niente variabili di vista nuove per lo stesso scopo.
- **Le parole arancioni** (stati, «Priorità 1», «Da completare», «Stime in uso») usano l'arancione delle scritte della
  miglioria 7 (gruppo 01: `Tema.Apple.Colore.arancioTesto`, #B4530B / #F5A94A; oggi ne esiste una copia locale in
  `Tema.Apple+Ovunque.swift:11`). L'arancione pieno `Colore.arancio` resta per i segni.

## Ordine consigliato

1. **13 · Obiettivi** e **17 · Priorità in ordine**: piccole, indipendenti, si possono fare subito.
2. **11 · Indice del dossier** e **12 · Più spazio al dossier**, insieme, in un solo giro: si toccano gli stessi file
   (`DossierApple.swift`, `AppClienti.swift`). Dipendono dal gruppo 01: la **riga sola in testa alla finestra**
   (miglioria 4, dove vanno nome e azioni del cliente), **un solo posto per il cliente** (miglioria 2: «‹ Rubrica» è
   come «Tutti i clienti»), **un solo «Da fare»** (miglioria 3: il numero accanto a Panoramica) e **il dossier parte dal
   quadro** (miglioria 5: la Panoramica con le quattro aree e «Dati per l'analisi» come riga). Se la riga in testa non è
   ancora pronta, la 12 si ferma alla parte «le quattro cifre solo in Panoramica» e la testata resta finché non c'è.
   La 11 non parte prima della miglioria 2: «‹ Rubrica» è «Tutti i clienti» e, senza, non avrebbe dove tornare.
3. **16 · Un solo avviso sulle stime**: dopo la miglioria 5 del gruppo 01, perché apre lo stesso elenco «Dati per
   l'analisi» che quella trasforma in un dettaglio; e dopo la miglioria 2 (in Analisi 360 spariscono le pillole dei
   clienti, e lo spazio a destra della testata va all'avviso).
4. **14 · Le posizioni prima di tutto**: dopo le migliorie 2 (via «Cliente | Portafoglio» e «Dossier di…»), 3 (il
   collegamento «N da fare per …»), 6 («Aggiorna valori» e «Aggiungi» nella barra) e 8 (il totale in `--tot`) del
   gruppo 01; i nomi dei canali nei filtri seguono la miglioria 38 del gruppo 06 se è già fatta.
5. **15 · La scheda di una posizione**: dopo la 14 (il ritorno «‹ Le posizioni» e Esc tornano all'elenco della 14).

Più avanti altre migliorie toccano le stesse viste e partono da qui: 40-44 (radar, prova del fuoco, smontaggio, nuovo
cliente, aggiorna valori: il portafoglio di Posizioni), 45 (simulatore), 62 (il documento si apre in grande: sezione
Documenti), 65 (le note stanno con il cliente: sezione Note), 66 (le parole si spiegano dove sono).

---

## 11. Il dossier ha un indice

### 11.1 Nel template

Codice: righe 3391-3437 (`SEZ_D`, `badgeSez`, `clientiUsoHTML`, `vaiSezione`, `montaClientiUso`) e le sette sezioni di
`SEZ_N` (righe 3436-3449, il contenuto «resta quello di oggi»). Regola 11 a righe 2621-2627. Si apre con
`vaiCli(1,'clienti', tabCli='panoramica')` e il cartellino indica `#dosIdx`.

- Con un cliente scelto, in Clienti la colonna di sinistra **non è più la rubrica** ma l'**indice del dossier**
  (`#dosIdx`, larga 216, pannello `.side`, scorre senza barra). Il dossier a destra parte a 232 (16 di spazio).
- Dall'alto:
  1. «‹ Rubrica» (simbolo `sx` 14, colore accento, peso 600): torna all'elenco dei clienti (`scegliCli(null)`, cioè
     «Tutti i clienti» della miglioria 2).
  2. La testa del cliente (`testaCli`): avatar 40, nome 14,5 bold su una riga con i puntini, sotto il motto 12 grigio.
  3. Tre gruppi con l'etichetta `.lbl` (11, margine 13/8/4):
     - **La persona**: Panoramica, Anagrafica, Famiglia, L'azienda (solo per chi è imprenditore), Profilo, Bisogni.
     - **Il piano**: Obiettivi, Linea della vita, Nel tempo.
     - **Le carte**: Documenti, In regola, Riesami, Note.
  Ogni voce è una riga `.vo` alta 32, raggio 12, 13,5 peso 500; la voce scelta ha il fondo accento al 13%.
- **Il numero piccolo** accanto a una voce (`badgeSez`) c'è solo quando c'è qualcosa da guardare:
  - Panoramica: le cose da fare del cliente (`aperti(k)`), capsula **rossa piena con il testo bianco**;
  - Obiettivi: gli obiettivi non «in tempo» (miglioria 13), capsula arancio tenue con il testo arancio;
  - Documenti: i documenti da leggere o con differenze, capsula neutra;
  - In regola: le voci scadute, capsula rossa tenue con il testo rosso.
  Con zero, niente numero.
- Clic su una voce (`vaiSezione`): chiude un dettaglio aperto, accende la voce, il contenuto esce (opacità 0, y +6,
  120 ms) e rientra con la cascata, i numeri che contano, gli anelli e le linee. Con «Riduci movimento» cambia subito.
- Spariscono il segmentato delle cinque schede in alto e il menu «Altro ⌄» (oggi Bisogni, Documenti, Anagrafica,
  Profilo, In regola, Note, Riesami). «L'azienda» non c'è per chi non è imprenditore; se era scelta si torna a
  Panoramica.
- Chi sceglie una persona nella rubrica entra nel suo dossier con l'indice (`aggiornaDossier`). Senza un cliente scelto
  Clienti resta com'è (rubrica e vuoto).
- **«Nuovo cliente» sta nella rubrica** (regola 11, riga 2626): con un cliente scelto le azioni della riga in testa sono
  quelle del dossier (miglioria 12: `A.act` → `dossierAzioni`), quindi «Nuovo cliente» e la scelta Rubrica / Potenziali /
  Passaparola tornano solo con «‹ Rubrica».
- Un clic sulla voce già scelta non fa niente (`if(tabCli===s) return`).
- Le sezioni di `SEZ_N` (Anagrafica, Profilo, Bisogni, Documenti, In regola, Riesami, Note) hanno una testata
  `sezT(titolo, sottotitolo, pulsanti)`: per esempio «Anagrafica · i dati della persona» con «Modifica», «Documenti ·
  letti e collegati alle posizioni» con «Importa…», «Note · le parole da ricordare · si salvano da sole». Il loro
  contenuto è dimostrativo: nell'app resta quello di oggi.

### 11.2 Nell'app oggi

- `Sources/Prisma/Shell/AppClienti.swift:117-133` (`dossierERubrica`): sul Mac `ViewThatFits` con la rubrica
  (`RubricaApple`, larga `Tema.Apple.Clienti.larghezzaRubrica`, superficie `pannello`) e il dossier (`cardPiatta`);
  finestra stretta: solo il dossier. La rubrica resta **sempre**, anche con un cliente scelto.
- `Sources/Prisma/Shell/DossierApple.swift:20-47`: `SchedaCliente.delSegmentato` (Panoramica, Obiettivi, Linea della
  vita, Nel tempo, Famiglia, più L'azienda per chi ne ha una) e `dellAltro` (Bisogni, Documenti, In regola, Riesami,
  Anagrafica, Profilo, Note, più «Azienda» per aggiungerla). `SchedeDossierApple` (riga 731) e `AltroSchedeDossier`
  (riga 746, con `NSMenu` e `BersaglioMenuAltro` a riga 835).
- `DossierApple` (riga 346): testata, tessere, schede, contenuto; cambio di scheda con uscita e cascata (righe 487-516).
- `SchedaCliente` (`Sources/Prisma/Shell/StatoShell.swift:3976`) ha già i tredici casi con i titoli; la scelta è
  `stato.schedaCliente`, che molte parti dell'app impostano già (In regola, Documenti, prove…).
- I numeri per le voci ci sono già, da leggere dalla cache per cliente: conformità (`CacheClienti.Voce.conformita`,
  `EsitoConformita.scadute`), documenti da leggere e con differenze (`MotoreDocumenti.appartiene(_:a: .daLeggere /
  .conDifferenze)`, usati in `ClienteDocumenti.swift:93-102`), obiettivi (dalla miglioria 13). Le cose da fare del
  cliente vengono dall'unico «Da fare» del gruppo 01 (miglioria 3).
- Differenza: oggi «L'azienda» compare in «Altro» anche per chi non ha un'azienda, per aggiungerla (`dellAltro(per:)`).
  Il template la mostra solo per l'imprenditore (`c.prof==='Imprenditore'`). Oggi un'azienda si aggiunge **solo** dalla
  scheda stessa (vuoto con «Aggiungi l'azienda di …», `DossierAzienda.swift:185`, modulo `ModuloAzienda`): il modulo del
  cliente (`ModuloCliente`) non ha campi dell'azienda.
- C'è già: il ritorno a Panoramica se si cambia cliente con «L'azienda» aperta e il nuovo non ha aziende
  (`DossierApple.cambiaCliente`, righe 446-449); la chiusura del dettaglio aperto al cambio di scheda
  (`PresentatoreDettaglioDossier`, `DossierObiettivi.swift:638-639`, che avvolge anche la colonna di sinistra): non vanno
  rifatti.
- Oggi «Nuovo cliente», il menu «…» (Importa, Incolla da Excel) e il segmentato Rubrica / Potenziali / Passaparola sono le
  azioni dell'intestazione di Clienti (`AzioniClienti`, `ContenutoApp.swift:128-168`), visibili anche con il dossier.
- In modalità cliente la rubrica mostra il solo cliente (`StatoShell.clienti`, riga 827) e accanto c'è il suo dossier.

### 11.3 Cosa fare

1. In `DossierApple.swift` aggiungere a `SchedaCliente` i gruppi dell'indice:
   `static let indice: [(titolo: String, voci: [SchedaCliente])]` = La persona (panoramica, anagrafica, famiglia,
   azienda, profilo, bisogni), Il piano (obiettivi, lineaVita, nelTempo), Le carte (documenti, inRegola, riesami,
   note), e `static func indice(per c: Cliente?)` che toglie `.azienda` quando non va mostrata (vedi 11.6).
2. Nuova vista `IndiceDossierApple` (file nuovo `Sources/Prisma/Shell/IndiceDossierApple.swift`, solo macOS):
   - «‹ Rubrica» (`Button` stile semplice, simbolo `chevron.left`, colore accento): `stato.scegliCliente(nil)` della
     miglioria 2 («Tutti i clienti»: rubrica e, a destra, «La tua rubrica» del gruppo 01 §2.3 punto 7). Non c'è in
     modalità cliente (la rubrica avrebbe una persona sola).
   - La testa del cliente: `AvatarCliente` 40, nome e motto (riuso dei caratteri della rubrica, `VoceRubricaApple`).
   - I tre gruppi con `.lbl` e le voci; la voce scelta è `stato.schedaCliente`; il clic scrive `stato.schedaCliente`
     (il cambio animato lo fa già `DossierApple.cambiaScheda`).
   - Il numero: una vista `NumeroIndice(n:, tono:)` con quattro toni (`.urgente` rosso pieno, `.attenzione` arancio tenue,
     `.errore` rosso tenue, `.neutro`). Obiettivi conta quelli «in ritardo», «senza versamenti» e «non ci arriva» della
     miglioria 13, **non** i «già raggiunti»; Documenti conta i documenti da leggere **o** con differenze (un documento
     una volta sola); In regola conta `EsitoConformita.scadute`. I conteggi si leggono una volta per il cliente in una struttura
     `ContiIndiceDossier` ricavata con `stato.ricavato("indice-dossier|\(id)") { … }` (la chiave dipende solo dai dati dei
     calcoli e dal giorno; le cose da fare vanno nella chiave se il «Da fare» non è dato dei calcoli).
   - Scorre in verticale senza indicatori, con la sfumatura in fondo come le altre colonne.
3. In `AppClienti.dossierERubrica` (macOS, righe 117-133): con un cliente scelto, al posto di `rubrica` si mette
   `IndiceDossierApple` (stessa superficie `pannello`, stesso raggio, larghezza 216 al posto di 250); senza cliente
   scelto resta la rubrica. In finestra stretta resta solo il dossier (come oggi): l'indice va allora in un menu a
   tendina nella riga in testa (vedi 11.6). La soglia di `ViewThatFits` (`larghezzaMinimaDossier` 560) resta.
4. «L'azienda» nell'indice: la regola di oggi (`elencoAziende` non vuoto) più quella della decisione 11.6;
   `cambiaCliente` già torna a Panoramica, basta allinearne la condizione a `SchedaCliente.indice(per:)`.
5. Togliere dal Mac `SchedeDossierApple` e `AltroSchedeDossier` dal `dossier(_:scheda:)` di `DossierApple`
   (righe 402-405); restano per l'iPad finché non arriva il suo giro (parametro `conSchede: Bool`, vero su iOS).
   Aggiornare `Tema.Apple.Clienti.Moto.indiceSchede`/`primoIndiceScheda` perché la cascata non aspetti un blocco che non
   c'è più.
6. Le sezioni che oggi entrano nella cornice di Prisma (`corniceSchedaDossier`) restano quelle di oggi. La testata
   `sezT` del template («Anagrafica · i dati della persona» e i pulsanti) si porta solo dove la sezione non ha già un
   titolo suo; non si rifà il contenuto (nota del template: «Il contenuto resta quello di oggi»).
7. Token nuovi in `DesignSystem/Apple/Tema.Apple+Clienti.swift`, `enum Indice`: `larghezza` 216, `spazio` 16,
   `padding` 14×12, `altezzaVoce` 32, `raggioVoce` 12, `voce` (13,5 medio), `voceScelta` (fondo accento 13%),
   `ritorno` (13,5 semibold accento), `avatar` 40, `nome` 14,5 bold, `motto` 12, `etichettaGruppo` (11, margine
   13/8/4), `numero` (11,5, padding 1×7) e i quattro toni del numero (fondo e testo per `urgente`, `attenzione`,
   `errore`, `neutro`). I colori vengono da `Tema.Apple.Colore` (rosso, arancio, chip, inchiostro2).
8. Non fare: niente rubrica e indice insieme; niente «Altro»; non copiare il contenuto dimostrativo di `SEZ_N`.

### 11.4 Dati, archivio, privacy

Nessun campo nuovo: la sezione scelta è `stato.schedaCliente` (in memoria, come oggi). La regola di CLAUDE.md «Clienti
in modalità cliente resta sulla Rubrica» riguarda la scelta Rubrica / Potenziali / Passaparola (`AppClienti.contenuto`,
riga 74), non la colonna: in modalità cliente oggi si vedono la rubrica con il solo cliente e il suo dossier. Con
l'indice: in modalità cliente l'indice c'è (è il dossier del cliente stesso), senza «‹ Rubrica»; i numeri restano quelli
che il dossier mostra già al cliente (niente «Da fare» se la miglioria 3 lo nasconde in modalità cliente). La vista
pulita del gruppo 01 (miglioria 1) decide da sé che cosa nascondere.

### 11.5 Istantanee e prove

- Aggiornare `431-clienti-panoramica-apple`, `432-clienti-obiettivi-apple`, `433-clienti-obiettivo-dettaglio`
  (`Shell/IstantaneeDossierApple.swift`): ora mostrano l'indice al posto della rubrica.
- Nuove: `1020-uso-dossier-indice` (Marco, Panoramica, con i numeri di Panoramica, Obiettivi, Documenti e In regola) e
  `1020-uso-dossier-indice-scuro`; `1021-uso-dossier-documenti` (Giulia su Documenti: una sezione che prima stava in
  «Altro»). Proposta di numerazione per i gruppi: 1000 + 10 × gruppo (gruppo 02 → 1020-1039).
- Tutte le scene che impostano `schedaCliente` su una scheda di «Altro» (cercare `schedaCliente =` in `Istantanee*.swift`
  e `ProvaDelFuocoApple.swift:331`) restano valide: cambia solo dove si sceglie. Da rigenerare e guardare in particolare
  `430-clienti-dossier` e `-scuro`, `431-clienti-dossier-altro` (`Istantanee.swift:1441`: nata per mostrare «Altro» su
  In regola, va rinominata, per esempio `431-clienti-dossier-in-regola`) e `434-clienti-nel-tempo`.
- `--prova-fluidita`: il passo di Clienti deve restare dentro i limiti di disegno (l'indice legge i conti dalla cache;
  controllare `ContaCorpi` dell'indice).

### 11.6 Decisioni per l'utente e rischi

- **«L'azienda» per chi non ce l'ha.** Il template la mostra solo all'imprenditore; oggi Prisma la offre in «Altro» a
  tutti, perché l'unico modo di aggiungere un'azienda è il vuoto della scheda («Aggiungi l'azienda di …»): il modulo del
  cliente non ha l'azienda. Proposta: nell'indice se il cliente ha almeno un'azienda **o** la sua professione contiene
  «imprenditore» o «titolare» (`Cliente.professione`, senza maiuscole); per gli altri l'azienda si aggiunge da una voce
  «Aggiungi un'azienda…» nel menu «Altro ⌄» della riga in testa (miglioria 12), che apre `ModuloAzienda` come il vuoto di
  oggi. Così non si perde la strada di oggi.
- **Finestra stretta** (mezza finestra di uno spazio, dove oggi resta solo il dossier): il template non lo disegna.
  Proposta: l'indice diventa un menu «Sezione: Panoramica ⌄» nella riga in testa.
- Rischio: l'indice è un'altra vista che osserva lo stato; i conteggi vanno letti in un colpo da una struttura in cache,
  non con quattro filtri nel body.

### 11.7 Dimensione

M. File: `Shell/DossierApple.swift`, `Shell/AppClienti.swift`, nuovo `Shell/IndiceDossierApple.swift`,
`DesignSystem/Apple/Tema.Apple+Clienti.swift`, `Shell/IstantaneeDossierApple.swift`.

---

## 12. Più spazio al dossier

### 12.1 Nel template

Codice: righe 3415-3433 (`dossierHTML`, `dossierAzioni`, `montaClientiUso`, `montaClientiAzioni`). Regola 12 a righe
2628-2631. Si apre con `vaiCli(1,'clienti', tabCli='documenti')` e il cartellino indica `#win .hd`, la riga in testa.

- Nella **riga unica in testa alla finestra** (miglioria 4): titolo «Il dossier di Marco.» (`nomeDi`), sottotitolo
  «45 anni · Libero professionista» (età · professione), a destra le azioni (`dossierAzioni`): le etichette dei canali
  del cliente, «☆ Preferito» / «★ Preferito» (la stella arancio quando è preferito), «Modifica», «Prospetti» (primario).
- Clic su «Preferito»: si alterna, la riga si ridisegna, avviso con il nome intero «Marco Bianchi è tra i preferiti» /
  «Marco Bianchi non è più tra i preferiti». «Modifica» apre il modulo di oggi. «Prospetti» apre Prospetti.
- Il titolo usa il nome breve («Il dossier di Marco.», `nomeDi`), l'avviso il nome intero (`c.n`).
- **La testata grande dentro la pagina sparisce** (avatar, «Dossier personale», nome, motto).
- **Le quattro cifre** (Patrimonio netto, Capitale assicurato, Premi annui, Proposte aperte · «x € l'anno») restano
  **solo in Panoramica**: in cima, quattro tessere in griglia, e la sezione parte sotto (a 116). Nelle altre sezioni il
  contenuto parte subito in alto (a 22).
- Le azioni hanno **sempre il nome scritto**: non diventano icone quando lo spazio cala; se non ci stanno, le ultime
  vanno in «Altro ⌄» (regola 12).

### 12.2 Nell'app oggi

- `TestataDossierApple` (`Shell/DossierApple.swift:523-640`): avatar 56, «Dossier personale», nome 27, motto · età ·
  professione; a destra canali, stella, «Modifica», «Analisi 360», «Un anno insieme» (`TestiAnnoInsieme.titolo`) e
  «Prospetti» (primario). Con poco spazio «Modifica» e «Un anno insieme» diventano **icone** (`comandi(compatti:)`),
  poi i comandi scendono sotto il nome.
- `TessereDossierApple` (riga 647): quattro tessere 258×76, sempre visibili sopra le schede (`dossier(_:scheda:)`,
  righe 398-401), in tutte le schede.
- La riga in testa alla finestra è del gruppo 01 (miglioria 4): oggi la finestra interna ha la sua barra
  (`Shell/FinestraInterna.swift`) e la testata del dossier è dentro il contenuto. Il gruppo 01 (§4.3) porta nella riga
  `app.titoloIntestazione` e le azioni di `ContenutoApp.azioni` (per Clienti `AzioniClienti`, `ContenutoApp.swift:99` e
  128-168) e lascia alla miglioria 12 le azioni «sempre con il nome».
- Il preferito oggi è la sola stella «☆»/«★» senza parola (`TestataDossierApple.stella`, aiuto «Aggiungi ai preferiti»);
  `stato.alternaPreferito` (`StatoShell.swift:1194`) non mostra avvisi; `stato.mostraAvviso(_:)` c'è
  (`StatoShell.swift:3880`).

### 12.3 Cosa fare

1. Dalla miglioria 4 del gruppo 01 serve che titolo e sottotitolo della riga in testa possano dipendere dallo stato
   dell'app (il gruppo 01 li prende da `app.titoloIntestazione`, fisso: va esteso, per esempio una funzione di
   `StatoShell` `titoloRiga(app)` letta dalla riga; il gruppo 01 cita già «Le posizioni di Giulia.»). Le azioni sono quelle
   di `ContenutoApp.azioni`: in `AzioniClienti`, con un cliente scelto e la vista Rubrica, al posto del segmentato e di
   «Nuovo cliente» (che tornano con «‹ Rubrica»). Clienti, con un cliente scelto, dà:
   - titolo «Il dossier di {nome breve}.» (`StatoShell.nomeBreve`), sottotitolo dalle parti che ci sono:
     «{età} anni · {professione}» (riuso del calcolo di `TestataDossierApple.sottotitolo`, senza il motto, che sta già
     nell'indice);
   - azioni: `EtichettaCanaleApple` per ogni canale (o `EtichettaCanaleDaScegliere`), «Preferito» con la stella
     (☆/★ + la parola), «Modifica», «Prospetti» (`.applePrimario`).
2. Le azioni non diventano mai icone: `ViewThatFits` con due varianti, tutte intere oppure le prime intere e le altre in
   un menu «Altro ⌄» (stesso stile `.apple`). Togliere da `TestataDossierApple` le varianti `compatti` con le icone.
3. Spostare in «Altro ⌄» i due pulsanti che il template non ha: «Analisi 360» e «Un anno insieme» (vedi 12.6).
4. Il preferito: `stato.alternaPreferito(id)` come oggi, più l'avviso `stato.mostraAvviso("{nome intero} è tra i
   preferiti")` / «{nome intero} non è più tra i preferiti» (nel pulsante della riga, non dentro `alternaPreferito`,
   che resta di tutte le piattaforme).
5. In `DossierApple.dossier(_:scheda:)` (macOS): togliere `TestataDossierApple` e mostrare `TessereDossierApple` solo se
   `scheda == .panoramica` (in cima alla scheda, prima del contenuto). Rivedere gli indici della cascata
   (`Tema.Apple.Clienti.Moto`): con la Panoramica le tessere sono il primo blocco, nelle altre il contenuto parte da 0.
6. Le tessere restano quelle di oggi (cifre da `RiepilogoPosizioni` in cache, numeri che contano). Il testo della
   quarta segue il template: «{n}» con accanto «· {valore} l'anno».
7. Token: in `Tema.Apple+Clienti.swift` (`Testata`) i caratteri della riga in testa se il gruppo 01 non li ha già;
   `Tessere.sopra` diventa lo spazio sopra la Panoramica. Nessun colore nuovo.
8. Non fare: non rimettere avatar e nome grande nella pagina; non tenere le tessere fuori da Panoramica.

### 12.4 Dati, archivio, privacy

Nessun campo nuovo. Il preferito è già `Cliente.preferito`.

### 12.5 Istantanee e prove

- Le stesse del punto 11.5; in più `1022-uso-dossier-riga-in-testa` (Giulia su Documenti: mezza finestra in più per
  l'elenco) e una variante in finestra stretta (`1022-uso-dossier-riga-in-testa-stretta`) per vedere «Altro ⌄».
- Controllare la scena del report di fine anno (`TestiAnnoInsieme`) che parte dal dossier: ora il pulsante è in «Altro».

### 12.6 Decisioni per l'utente e rischi

- **«Analisi 360» e «Un anno insieme».** Il template ha solo Preferito, Modifica, Prospetti. Proposta: tutti e due in
  «Altro ⌄» nella riga in testa (Analisi 360 si raggiunge anche dal dock e da «Bisogni › Analizza in Analisi 360 ›»),
  insieme ad «Aggiungi un'azienda…» per chi non ha la voce «L'azienda» nell'indice (decisione 11.6). «Altro ⌄» c'è
  quindi sempre, non solo quando lo spazio manca.
- **Il motto del cliente** («Una casa, un nuovo inizio.») esce dalla riga in testa: resta sotto il nome nell'indice
  (miglioria 11). Proposta: va bene così.
- Rischio: finché la miglioria 4 non è fatta, togliere la testata lascerebbe il dossier senza nome. Le due parti vanno
  nello stesso giro o la testata si toglie solo quando la riga in testa c'è.

### 12.7 Dimensione

S. File: `Shell/DossierApple.swift` (testata e tessere), il punto della riga in testa del gruppo 01,
`DesignSystem/Apple/Tema.Apple+Clienti.swift`.

---

## 13. Obiettivi: si vede se ci arriva

### 13.1 Nel template

Codice: righe 3368-3379 (`MESI_IT`, `scadenzaMesi`, `obiSt`, `obiChip`, `obiRiga`, la ridefinizione di
`apriObiettivo`); la card della base a riga 1066-1070 (usa `obiRiga`). Regola 13 a righe 2632-2635. Si apre con
`vaiCli(1,'clienti', tabCli='obiettivi')` e il cartellino indica `#tabC .obi .st2`.

- Sotto ogni obiettivo, nella card, ci sono:
  1. la riga 13,5 grigia «{versamento} € al mese · scadenza {mese anno}» (prima: «550 € al mese · non ci arriva»);
  2. **uno stato scritto e colorato** (capsula `.st2`, 12,5, padding 4×11), a 10 sotto:
     - verde (`ok`) «In tempo: ci arriva a {mese anno}»;
     - arancio (`avv`) «In ritardo: ci arriva {N anni e M mesi / N mesi} dopo» (singolare e plurale: «1 anno»,
       «2 anni e 3 mesi», «1 mese»);
     - rosso (`ko`) «Senza versamenti non ci arriva» (versamento zero).
- **La percentuale è una sola**: quanto è già messo da parte (`pctObi`), uguale nella card e nel dettaglio (oggi 40% e
  39%). L'anello del dettaglio dice «oggi», come la card.
- Nel dettaglio (`apriObiettivo`) sotto «Arriva a …» e la riga dello scarto compaiono lo stato (`#ovSt`) e la nota
  «Scadenza: {mese anno}. La percentuale è la stessa della scheda: quanto è già messo da parte.» Lo stato **segue il
  cursore del versamento** a ogni passo.
- Gli obiettivi non «in tempo» danno il numero arancio accanto a «Obiettivi» nell'indice (miglioria 11).

### 13.2 Nell'app oggi

- Card: `SchedaObiettivoApple` (`Shell/DossierObiettivi.swift:221-293`): anello con `a.quota` e «oggi», nome,
  «20.800 € di 40.000 €», poi `TestiObiettivoApple.riga` (righe 185-194): «{totale} al mese · arriva a {mese}» /
  «… · già raggiunto» / «… · non ci arriva», grigia (`s.coloreTesto`).
- Dettaglio: `DettaglioObiettivoApple` (righe 339-560): l'anello mostra la **copertura alla scadenza**
  (`curva.copertura(versamento:)`, «alla scadenza»), che segue il cursore: è la seconda percentuale. Sotto il cursore
  «Arriva a **ottobre 2029**» (`arrivo`, riga 500), poi lo scarto con la scadenza (`TestiObiettivoApple.scarto`).
- I conti ci sono già: `CurvaObiettivo` (`Sources/Prisma/Motori/CurvaObiettivo.swift`) dà `mesiScadenza` e
  `mesiArrivo(versamento:)` (0 se c'è già, nil se non ci arriva entro 30 anni dalla scadenza), dai motori di
  `MotoreObiettivo`, con le posizioni collegate. Il ritardo è `mesiArrivo − mesiScadenza`. Attenzione: `versamento` è
  quello **in più** (`Obiettivo.versamentoMensile`); i versamenti delle posizioni collegate in essere sono già dentro la
  curva (`AvanzamentoObiettivo.versamentiAttivi`). La curva in memoria è `CacheMotoriAnalisi.curva` (estensione in
  `CurvaObiettivo.swift:123-148`, al più 24 curve, svuotata tutta quando è piena).
- Oggi il dettaglio dice già «Senza versamenti in più non ci arriva» (con versamenti attivi e cursore a zero) e «Con
  {x} € al mese non ci arriva» (`DettaglioObiettivoApple.arrivo`, righe 500-518). La frase «Così non ci arriva» esiste
  già, ma per la **probabilità** senza oscillazioni (`ClienteObiettivi.swift:637`, `PannelliMotoriAnalisi.swift:105`).
- C'è anche `StatoObiettivo` (`Shell/ClienteObiettivi.swift:243`): un semaforo dalla **probabilità** (in linea, da
  rinforzare, non ci arriva) usato dalle viste di prima e dal dettaglio completo («Ci arriva in ogni caso», «Così non
  ci arriva», riga 637). È un'altra misura, non quella del template.

### 13.3 Cosa fare

1. In `DossierObiettivi.swift` un tipo nuovo `ArrivoObiettivo` (enum, solo testo e tono, nessun calcolo nuovo):
   `.giaRaggiunto`, `.inTempo(mese: String)`, `.inRitardo(mesi: Int)`, `.senzaVersamenti`, `.nonCiArriva`, con
   `init(curva:versamento:attivi:)`:
   - `mesiArrivo == 0` → già raggiunto; `mesiArrivo ≤ mesiScadenza` → in tempo; `> mesiScadenza` → in ritardo di
     `mesiArrivo − mesiScadenza`;
   - `mesiArrivo == nil` e versamento totale (attivi + in più) zero → senza versamenti; altrimenti → non ci arriva.
   - L'ordine dei controlli è questo (prima `mesiArrivo`): a differenza del template, che con versamento zero dice
     sempre «Senza versamenti», un obiettivo già raggiunto o che ci arriva con ciò che c'è resta verde.
2. Testi in `TestiObiettivoApple`: «In tempo: ci arriva a {mese}», «In ritardo: ci arriva {durata} dopo» (funzione
   `durata(mesi:)` con «1 anno», «2 anni e 3 mesi», «5 mesi», «1 mese»), «Senza versamenti non ci arriva», «Già
   raggiunto» (verde), e per il caso che il template non ha «Con questo versamento non ci arriva» (rosso, vedi 13.6). La
   riga grigia diventa «{totale} al mese · scadenza {mese anno}» (`Formati.meseAnno`); `TestiObiettivoApple.riga` è usata
   solo dalla card (`DossierObiettivi.swift:261`).
3. Componente `StatoArrivoObiettivo` (capsula del tema, testo 12,5, padding 4×11, colori di tono) in
   `DesignSystem/Apple/` (o il componente di pillola di stato del gruppo 01, se c'è già: stessa forma `.st2`).
   Token in `Tema.Apple+Dossier.swift` (dove vive `Tema.Apple.Clienti.Obiettivi`): `statoArrivo` (carattere),
   `paddingStato`, `sopraStato` 10, e i colori `ok`/`attenzione`/`errore` da `Tema.Apple.Colore` (verde, arancio del
   testo `--orangeT` della miglioria 7, rosso) con i fondi tenui.
4. Card: sotto la riga grigia lo `StatoArrivoObiettivo` calcolato con `o.versamentoMensile` (il versamento di oggi).
5. Dettaglio:
   - l'anello mostra **la quota di oggi** (`a.quota`, «oggi»), la stessa della card; resta fermo quando si muove il
     cursore;
   - sotto «Arriva a …» e lo scarto, lo `StatoArrivoObiettivo` calcolato con il `versamento` del cursore (si aggiorna a
     ogni passo: è una lettura di `curva`, già in memoria, nessun motore nel body); «Arriva a …» resta com'è (il template
     lo tiene: lo stato si aggiunge sotto);
   - la nota «Scadenza: {mese anno}. La percentuale è la stessa della scheda: quanto è già messo da parte.» (12,5,
     `coloreNota`); lo scarto non ripete più «· scadenza …».
6. Esportare il conteggio per l'indice (miglioria 11): `obiettiviNonInTempo(clienteId)` dai `CacheClienti.Voce.obiettivi`
   e `avanzamenti` già in cache, con la curva in `CacheMotoriAnalisi.curva` (memoria di 24 curve: controllare che non si
   svuoti con molti obiettivi, vedi 13.6). Conta in ritardo, senza versamenti e non ci arriva; non i già raggiunti. Il
   numero va dentro la struttura `ContiIndiceDossier` ricavata una volta (11.3), non ricalcolato a ogni disegno
   dell'indice.
7. Non fare: non togliere la probabilità del dettaglio completo; non portare i conti del template (`Math.ceil((target −
   cur)/v)`, senza rendimenti): i mesi li dà `CurvaObiettivo`.

### 13.4 Dati, archivio, privacy

Nessun campo nuovo. Il versamento salvato resta `Obiettivo.versamentoMensile`.

### 13.5 Istantanee e prove

- Aggiornare `432-clienti-obiettivi-apple` e `433-clienti-obiettivo-dettaglio` (le card con lo stato, il dettaglio
  con l'anello «oggi» e lo stato), `282-clienti-obiettivi-quadro`, `283-clienti-obiettivi-stretta`,
  `98-clienti-obiettivi-probabilita` (`Istantanee.swift`).
- Nuova `1023-uso-obiettivi-stato` (un cliente con un obiettivo in tempo, uno in ritardo e uno senza versamenti: si
  preparano nella scena cambiando `versamentoMensile` sui dati di prova) e la variante scura.
- `--prova-calcoli`: aggiungere un caso per `ArrivoObiettivo` (in tempo, in ritardo con «1 anno e 2 mesi», senza
  versamenti, già raggiunto) e uno per `durata(mesi:)`.

### 13.6 Decisioni per l'utente e rischi

- **Due giudizi sullo stesso obiettivo.** Il dettaglio completo mostra anche la probabilità («Così non ci arriva» con
  il 30%), mentre lo stato nuovo è deterministico (al rendimento atteso). Possono dire cose diverse. Proposta: lo stato
  nuovo è quello «di testa» (card e cursore); la probabilità resta sotto, nel dettaglio completo, con le sue parole di
  oggi (cambiarle non serve, ora che lo stato nuovo non usa «Così non ci arriva»).
- **Con versamenti ma oltre trent'anni dopo la scadenza** `mesiArrivo` è nil: il template non ha questo caso. Proposta:
  rosso «Con questo versamento non ci arriva» (come la frase di oggi del dettaglio, «Con {x} € al mese non ci arriva»,
  e diversa da «Così non ci arriva» della probabilità).
- **L'anello del dettaglio smette di seguire il cursore.** È una scelta del template (una sola percentuale). Proposta:
  seguire il template; la copertura alla scadenza, se l'utente la vuole, resta come riga di testo «Alla scadenza
  copre il 78%».
- Rischio: il numero dell'indice chiede la curva di ogni obiettivo del cliente; la memoria delle curve tiene 24 voci.
  Con un cliente si resta sotto; va controllato con `--prova-carico`.

### 13.7 Dimensione

S. File: `Shell/DossierObiettivi.swift`, `DesignSystem/Apple/Tema.Apple+Dossier.swift` (o il file dei token degli
obiettivi), una prova in `--prova-calcoli`.

---

## 14. Le posizioni prima di tutto

### 14.1 Nel template

Codice: righe 3461-3598 (`posRailHTML`, `posClienteHTML`, `posPaginaHTML`, `posRighe`, `posQuadroHTML`, le cinque pagine
`posTempoHTML`, `posResistenzaHTML`, `posCoerenzaHTML`, `posCostiHTML`, `posSuccessioneHTML`, `posConta`, `posFiltra`,
`posRimonta`, `montaPosCliente`); il ritorno alla prima schermata al cambio di cliente a riga 3673. Regola 14 a righe
2636-2644. Si apre con `vaiCli(1,'posizioni', posV='quadro')` e il cartellino indica `#posCard`.

- Titolo nella riga in testa: «Le posizioni di Marco.», sottotitolo «{n} in essere · {n} proposte · aggiornate adesso».
- **La colonna di sinistra è l'indice** (`#posIdx`, larga 236; il contenuto parte a 252):
  1. «‹ Tutto il portafoglio» (accento): come «Tutti i clienti» (miglioria 2);
  2. la testa del cliente (avatar 40, nome, motto), come nel dossier;
  3. **Le posizioni**: «Quadro e posizioni» con il numero delle posizioni;
  4. **Le analisi**: «Il patrimonio nel tempo», «Prova di resistenza», «Coerenza con il profilo», «Peso dei costi»,
     «Passaggio generazionale» — **una schermata ciascuna**;
  5. **Collegati**: nel template «Il dossier» e «Analisi 360»; la regola dice «com'è oggi: Analisi 360, Prodotti,
     Simulatore, Confronto», con «Archivio locale» in fondo.
  Il numero accanto a «Quadro e posizioni» conta le sole posizioni **in essere** (`POS[k].length`, senza le proposte).
  Con la scheda di una posizione aperta nessuna voce è accesa; un clic sulla voce già scelta non fa niente.
- **«Quadro e posizioni»** (la prima schermata, `posQuadroHTML`):
  - in alto quattro tessere alte 92: «Patrimonio netto» (con le capsule «Attività {k} €» e, solo se ci sono, «Debiti
    {k} €»), «Premi e
    versamenti» («all'anno · {n} contratti» o «nessun versamento a rate»), «Capitale assicurato» («caso morte» o
    «nessuna copertura»), «Proposte aperte» («per {valore} l'anno» o «nessuna»);
  - a sinistra, grande, la card **«Le posizioni»** (`#posCard`): titolo 18 bold, il conto «{n} voci», e sulla stessa
    riga a destra **i filtri**: segmentato «In essere | Proposte | Tutte» e le due capsule dei canali (pallino del
    colore del canale e nome; un secondo clic toglie il filtro). Sotto, se c'è un filtro di area, la sua capsula con
    «✕» (`#posFA`). Poi l'elenco che scorre; in fondo, sopra un filo, «Tocca una riga per la scheda della posizione.».
    «{n} voci» («1 voce») sparisce con zero risultati. **I filtri filtrano solo l'elenco**: tessere, «Ripartizione per
    area» e «Per canale» restano sempre quelle di tutto il cliente. A ogni cambio di filtro l'elenco rientra (opacità e
    y +6, 240 ms; con «Riduci movimento» di colpo);
  - le righe (`posRighe`): segno dell'area, nome, sotto «{area} · {tipologia}»; a destra l'eventuale «Scade tra {n}
    giorni» (arancio), il canale, l'importo (per una protezione il capitale con «assicurati», per un debito in rosso),
    «›». Le proposte: segno attenuato, «Proposta · {stato}», capsula viola «Proposta», importo viola con «l'anno».
    L'elenco è **ordinato per area**. Niente risultati: «Niente con questi filtri.»;
  - a destra (larga 392) **«Ripartizione per area»** («Tocca un'area per vedere solo quelle posizioni»: anello 118 con
    «Attività» al centro, la legenda con importi e percentuali; per la Protezione «{n} polizze»). **La legenda è il
    filtro per area**: un clic filtra, un secondo clic o la «✕» lo toglie;
  - sotto, **«Per canale»** («Attività in essere»): la barra divisa nei due colori, le due righe con importo e
    percentuale; in fondo, sopra un filo, «{n} da fare per {nome} ›» (apre il «Da fare») o «Niente da fare per {nome}.».
- **Le cinque analisi** hanno una testata comune (`testaAn`): titolo 21 bold, sottotitolo, a destra una capsula di
  stato e «Report per il cliente». Il CONTENUTO resta quello di oggi (nel template è ridotto e con dati di prova). I
  sottotitoli e le capsule di `testaAn` sono **gli stessi dei pannelli di oggi** (vedi 14.2): la testata c'è già.
- Clic su una voce dell'indice: il contenuto esce (120 ms) e rientra in cima (`posRimonta`). Clic su una riga: la scheda
  della posizione (miglioria 15).
- **Cambiando cliente si torna sempre a «Quadro e posizioni»**, filtri azzerati (stato «In essere», nessun canale,
  nessuna area).

### 14.2 Nell'app oggi

- `Sources/Prisma/Shell/AppPosizioni.swift`:
  - colonna (`rail`, righe 200-290): segmentato «Cliente | Portafoglio» (`SegmentiAnalisi`), `DossierRail` («Dossier
    di» con la tendina dei clienti, `DesignSystem/ComponentiStrumenti.swift:162`), poi i filtri **Stato** («Attive,
    Proposte, Tutte»), **Canale** (due voci), **Aree** («Tutte le aree» e le aree con i conti da
    `stato.contiAreePosizioni`), **Analisi** (cinque voci che scrivono `stato.ancoraPosizioni` e scorrono la pagina),
    **Collegati** (Analisi 360, Prodotti, Simulatore, Confronto) e `ArchivioLocaleRail` in fondo;
  - contenuto (`principale`, righe 339-411): **una sola pagina lunga** con `FasciaKPI` (le quattro cifre), «Ripartizione
    per area» e «Per canale» affiancati, poi `PannelloPatrimonio`, `PannelloResistenza`, `PannelloCoerenza`,
    `PannelloCosti`, `PannelloSuccessione` (ognuno solo se ha dati) e **in fondo** `TabellaPosizioni` (riga 540);
  - le ancore: `scorri(_:)` (riga 414) porta in vista «patrimonio», «resistenza», «coerenza», «costi», «successione».
    Le scrivono anche altre parti: `DossierFamiglia.swift:123` e `DossierAzienda.swift:153` («successione»),
    `Notifiche.swift:539`, le istantanee (`Istantanee.swift:268-293, 560-572, 736`). «attenzioni» e «seguito» sono del
    portafoglio (`ancorePortafoglio`) e restano;
  - i calcoli ci sono già e sono in cache: `stato.analisiDossier(id)` (patrimonio, prova, costi, successione),
    `stato.coerenzaCliente(c)`, `stato.riepilogoPosizioniCliente(id)`; `AppPosizioni.ripartizione(_:)` e
    `canali(_:apri:)` (righe 437-530) disegnano anello, legenda e canali.
- Sull'iPad la stessa vista usa `ColonnaLateraleAdattiva` (righe 63-71): non va toccata.
- **I pannelli hanno già la testata del template**: `PannelloAnalisi(titolo:nota:)` con lo stesso titolo, lo stesso
  sottotitolo (le cinque frasi di `testaAn` sono identiche a quelle di oggi), la capsula di stato e «Report per il
  cliente» — `PannelloPatrimonio.swift:11-17` («Con le proposte +…», `.patrimonio(report: true)`),
  `PannelloResistenza.swift:14-17` (giudizio, `.resistenza(report: true)`), `PannelloCosti.swift:11-16` («Si può
  risparmiare», `.costi(report: true)`), `PannelloSuccessione.swift:11-16` («Da sistemare», `.successione(report:
  true)`); `PannelloCoerenza` ha le sue capsule («Coerente con il profilo», «Un punto da rivedere», «Profilo da
  completare», righe 68-74) ma **nessun** «Report per il cliente»: in `SceltaProspetto` (`Dati/Prospetto.swift`) non c'è
  un prospetto della coerenza.
- **Il filtro di canale oggi cambia anche le cifre**: `principale` (riga 341) rifà il riepilogo da `delCliente`, già
  filtrato per canale, e con esso tessere, ripartizione e canali. Il template no.
- `TabellaPosizioni` (riga 540) è una tabella a sette colonne (Posizione, Canale 130, Area 116, Stato 130, Valore 110,
  Premi 120, Scadenza 96, con la riga di testa), con «Nessuna posizione con questi filtri.» e `.scorreSeStretto()`
  (scorre in orizzontale se non sta); la usa solo `principale`. Le righe del template sono diverse (vedi 14.3).
- Anche la storia dell'anno apre Posizioni su un'area: `stato.areaPosizioniDaAprire` (`StoriaLuce.swift:133`), consumata
  in `AppPosizioni` righe 86-92 (area, stato «in essere», canale tolto).
- `PannelloCosti` (riga 67) e `PannelloSuccessione` (riga 79) aprono la scheda di una posizione con un clic sulla riga.

### 14.3 Cosa fare

1. Stato della vista: in `StatoShell` (o come `@State` di `AppPosizioni`, vedi 14.6) un enum
   `VistaPosizioniCliente { case quadro, patrimonio, resistenza, coerenza, costi, successione }` con titoli e
   `init?(ancora:)` («patrimonio», «resistenza», «coerenza», «costi», «successione»). Quando arriva una di queste
   ancore, la vista passa a quella schermata e l'ancora si consuma (così `DossierFamiglia`, `DossierAzienda`, le
   notifiche e le istantanee continuano a funzionare senza toccarle). Al cambio di `clienteAttivoId`: vista `.quadro`,
   `filtroStato = .inEssere`, `filtroCanale = nil`, `area = nil` (oggi si chiude solo il dettaglio, riga 135). Anche
   `areaPosizioniDaAprire` (righe 86-92) porta la vista a `.quadro`, dove il filtro si vede.
2. Nuova vista `IndicePosizioniApple` (file nuovo `Shell/IndicePosizioniApple.swift`, macOS), nello stile
   dell'indice del dossier (stessi token `Tema.Apple.Clienti.Indice` o un `Tema.Apple.Posizioni.Indice` che li riusa):
   «‹ Tutto il portafoglio» (`stato.scegliCliente(nil)`, «Tutti i clienti» della miglioria 2, che rende vero
   `portafoglio`; non c'è in modalità cliente, come oggi il segmentato), testa del cliente, «Le posizioni › Quadro e
   posizioni (n)», «Le analisi» (cinque voci), «Collegati» (vedi 14.6, con `stato.apri` e `stato.apriStrumentoAnalisi`),
   `ArchivioLocaleRail` in fondo. Il numero accanto a «Quadro e posizioni» è il conto delle posizioni **in essere** del
   cliente (dal riepilogo o dai conti per area in cache, `contiAreePosizioni`). Voce accesa = vista scelta, nessuna con la
   scheda di una posizione aperta.
3. In `AppPosizioni` (macOS, vista cliente): `rail` → `IndicePosizioniApple`; in vista portafoglio la colonna di oggi
   resta (con i filtri), finché le migliorie 40-44 non la ridisegnano. Via «Cliente | Portafoglio» e `DossierRail`
   (lo fa la miglioria 2: qui basta non metterli nell'indice).
4. Nuova vista `QuadroPosizioniApple` (file nuovo `Shell/QuadroPosizioniApple.swift`), al posto di `principale` quando
   la vista è `.quadro`:
   - in alto `FasciaKPI` con le quattro tessere di oggi e i testi del template («all'anno · {n} contratti» /
     «nessun versamento a rate», «caso morte» / «nessuna copertura» al posto del chip «{n} coperture», «per {valore}
     l'anno» / «nessuna»; il chip «Debiti» solo se `r.debiti > 0`). Le cifre sono **sempre del cliente intero**:
     `r = stato.riepilogoPosizioniCliente(id)`, senza più il ramo `RiepilogoPosizioni(delCliente)` filtrato per canale;
   - sotto, due colonne: a sinistra la card «Le posizioni» (titolo, «{n} voci», segmentato
     «In essere | Proposte | Tutte» — la parola «In essere» al posto di «Attive», come la miglioria 10 —, le capsule dei
     canali con `EtichettaCanaleApple` compatta o un chip con pallino e nome, la capsula dell'area con «✕»,
     l'elenco che scorre dentro la card, il piede «Tocca una riga per la scheda della posizione.», «Niente con questi
     filtri.» quando l'elenco è vuoto). **L'elenco non può essere la `TabellaPosizioni` di oggi così com'è**: le sei
     colonne fisse fanno ~700 pt più il nome, e la card è larga la finestra meno 252 (indice) e 404 (colonna destra).
     Serve una variante a righe come il template (`TabellaPosizioni(stile: .righe)` o una `RigaPosizioneApple`): segno
     dell'area (attenuato per le proposte), nome, sotto «{area} · {tipologia}» (per le proposte «Proposta · {esito}»), a
     destra `PillolaStato` solo quando dice qualcosa (scadenza vicina, proposta), il canale compatto, l'importo
     (protezione: capitale con «assicurati»; debito in rosso; proposta: versamento con «l'anno», nel viola delle
     proposte), «›». `LazyVStack`; la tabella a colonne resta per l'iPad. A destra, larga 392, «Ripartizione per area»
     (`AppPosizioni.ripartizione(r)` con la legenda che diventa pulsante: clic = `area`, secondo clic = nil; nota
     «Tocca un'area per vedere solo quelle posizioni») e sotto «Per canale» (`AppPosizioni.canali(r)`) con il
     collegamento «{n} da fare per {nome} ›» del «Da fare» (miglioria 3).
   - `elenco` resta quello di oggi (ordinato per area, poi per valore): i filtri sono le stesse variabili `@State`.
5. Nuova vista `AnalisiPosizioniApple(vista:)` per le cinque schermate: **il pannello di oggi** (`PannelloPatrimonio`,
   `PannelloResistenza`, `PannelloCoerenza`, `PannelloCosti`, `PannelloSuccessione`) da solo, in uno `ScrollView` suo,
   con i dati che `principale` gli passa oggi (`stato.analisiDossier`, `stato.coerenzaCliente`). **Nessuna testata
   nuova**: titolo, sottotitolo, capsula di stato e «Report per il cliente» li disegna già il `PannelloAnalisi` di ogni
   pannello (14.2), con le stesse parole del template; una `TestataAnalisiPosizioni` li raddoppierebbe. Le capsule
   restano quelle dei motori di oggi (per la coerenza «Coerente con il profilo», non «Dentro il profilo» del template;
   per il passaggio generazionale niente «In ordine» se oggi non c'è). La coerenza resta senza «Report per il cliente»
   (non esiste il prospetto: non si inventa). Se serve che la testata sembri quella di una schermata (titolo 21), è un
   parametro del `PannelloAnalisi` (`titoloGrande: true`), non una copia.
6. Cambio di schermata: stessa transizione del dossier (uscita y +6, poi cascata; «Riduci movimento» e istantanee come
   sopra). Ogni schermata parte in cima. La scheda di una posizione aperta da una riga di «Peso dei costi» o «Passaggio
   generazionale» torna, con «‹ Le posizioni», alla schermata da cui è partita (la vista resta quella scelta).
7. Token nuovi in `Tema.Apple+Posizioni.swift`, `enum Quadro` (larghezza colonna destra 392, spazio 12, altezza
   tessere 92, altezza della ripartizione 304, titolo della card 18 bold, piede 12,5, altezza della riga dell'elenco,
   larghezza minima dell'importo 104) e, solo se si sceglie il titolo grande del punto 5, `PannelloAnalisi.titoloGrande`
   (21 bold). I colori restano quelli delle aree, dei canali e delle proposte (viola già nel tema).
8. Non fare: non rifare il contenuto delle analisi (il template lo riduce solo per mostrarlo); non portare `tipoP`,
   `contoP`, `CRISI`, `LIM`: le cifre sono dei motori; non nascondere i canali.

### 14.4 Dati, archivio, privacy

Nessun campo nuovo: filtri e vista sono stato in memoria. In modalità cliente valgono le regole di oggi (e la vista
pulita del gruppo 01).

### 14.5 Istantanee e prove

- Aggiornare `74-posizioni-costi`, `76-posizioni-successione`, `79-posizioni-patrimonio`, le scene con «resistenza» e
  «coerenza» (`Istantanee.swift:268-293, 560-572, 736`): con l'ancora che apre la schermata mostrano la singola
  analisi in cima, invece della pagina scorsa.
- Nuove: `1024-uso-posizioni-quadro` (Marco, filtri a zero) e `-scuro`; `1025-uso-posizioni-filtro-area` (Marco,
  area Protezione dalla legenda, con la capsula «✕»); `1026-uso-posizioni-coerenza` (la schermata della coerenza: il
  pannello di oggi da solo, in cima). Una scena con il filtro di canale acceso per vedere che le
  tessere non cambiano.
- `--prova-fluidita`: Posizioni è tra le `appPesanti`; il quadro non deve costruire i pannelli delle analisi (oggi la
  `LazyVStack` li rimanda): la prova deve restare verde con 200 clienti.
- `ProvaDelFuocoApple` e `ProvaSeguito` leggono `ancoraPosizioni` («seguito», portafoglio): controllare che restino
  verdi.

### 14.6 Decisioni per l'utente e rischi

- **«Collegati»**: il codice del template mette «Il dossier» e «Analisi 360»; la regola dice «com'è oggi» (Analisi 360,
  Prodotti, Simulatore, Confronto). Proposta: «Il dossier», «Analisi 360», «Prodotti», «Simulatore», «Confronto».
- **Analisi senza dati** (oggi il pannello non compare): il template mostra sempre le cinque voci. Proposta: la voce
  resta, la schermata dice in una riga perché è vuota («Servono posizioni finanziarie in essere», «Manca il profilo
  del cliente»…), con il pulsante per completare quando c'è un dato da completare (`stato.apriCompletamento(voce,
  cliente:)`, che vuole una `VoceCompletezza`: la prima voce di `completezzaCliente(id)` che tocca quell'analisi), o per
  aggiungere una posizione («Aggiungi › Posizione»). Le condizioni di «vuoto» sono quelle di oggi (`analisi.patrimonio.
  vuoto`, `prova.vuota`, `coerenza.oggi.patrimonioFinanziario > 0 || conProposte != nil`, `costi.vuota`, `successione`
  nil o vuota).
- **Dove tenere la vista scelta**: proposta `@State` in `AppPosizioni` con le ancore che la impostano (niente di nuovo in
  `StatoShell`, così iPad e iPhone non cambiano). Chi da fuori vuole una schermata (gruppo 07: radar e smontaggio,
  «Apri le posizioni di …» su coerenza o resistenza; gruppo 08) scrive l'ancora di oggi (`stato.ancoraPosizioni =
  "coerenza"`), non una proprietà nuova: va detto a quei gruppi.
- **«Aggiorna valori» e «Aggiungi»**: li sposta la miglioria 6 del gruppo 01 nella barra; il vuoto guidato (`vuotoPosizioni`)
  resta e parla di «Aggiungi › Posizione».
- Rischio: la `TabellaPosizioni` dentro una card che scorre (prima scorreva tutta la pagina): misurare con molte
  posizioni (un cliente di prova con 40 voci) e tenere l'elenco pigro (`LazyVStack`).

### 14.7 Dimensione

L. File: `Shell/AppPosizioni.swift`, nuovi `Shell/IndicePosizioniApple.swift`, `Shell/QuadroPosizioniApple.swift`,
`Shell/AnalisiPosizioniApple.swift`, `DesignSystem/Apple/Tema.Apple+Posizioni.swift`, `Istantanee.swift`.

---

## 15. La scheda di una posizione si legge dall'alto

### 15.1 Nel template

Codice: righe 3600-3658 (`posDati`, `aliqDi`, `vuotiDi`, `posDettaglioHTML`, `posTabHTML`); i pulsanti di
`montaPosPagina` (riga 3591: «Altro» con Simula, Confronta, Adeguatezza, Prospetto, Modifica); Esc a righe 3675-3677.
Regola 15 a righe 2645-2658. Si apre con `posDet={t:'pos',i:1}` e il cartellino indica `#pdFrase`.

- Prima riga (alta 34): a sinistra «‹ Le posizioni» (torna all'elenco), a destra le azioni:
  - in essere, finanziaria: «Simula», «Confronta», «Prospetto», «Modifica»;
  - in essere, altre (protezione, conto, immobile, debito): «Prospetto», «Modifica»;
  - **proposta: tre pulsanti** — «✓ Segna come in essere» (primario), «Esito…», «Altro ⌄» (Simula, Confronta,
    Adeguatezza, Prospetto, Modifica). «Adeguatezza» apre la scheda Adeguatezza.
- Testata: barretta del colore dell'area (5), nome 24 bold, stato (capsula: «In essere» verde, «Scade tra {n} giorni»
  arancio, «Debito» neutra, «Proposta» viola), canale; sotto «{area} · {tipologia} · {emittente}».
- **Una frase** (19, semibold, `#pdFrase`):
  - finanziaria: «Vale {valore}: {nome} ha versato {versato} e ne ha guadagnati {guadagno} in {N} anni.»;
  - protezione caso morte: «Copre {capitale} in caso di morte: costa {premio} l'anno e dura fino al {anno}.»;
    infortuni: «Copre gli infortuni della famiglia fino a {capitale}: costa {premio} l'anno e scade il {data}.»;
  - conto: «Qui ci sono {saldo}: è la riserva per gli imprevisti, {n} mesi di spese.»;
  - immobile: «Vale circa {valore}: è una stima di oggi, non una perizia.»;
  - debito: «Restano da pagare {importo}.»;
  - proposta: «Una proposta da {versamento} l'anno, presentata il {data}: aspetta una risposta.»; senza data di
    presentazione «Una proposta da {versamento} l'anno: è {stato}.»
- **Quattro cifre** (tessere): finanziaria «Vale oggi» (al {data}), «Versato» (in N anni, {premio} l'anno),
  «Guadagno» (verde, «+x% in tutto»), «Rende all'anno» («al netto dei costi»); protezione «Capitale assicurato»,
  «Premio» (all'anno), «Costo per 1.000 € assicurati», «Scadenza» (arancio se vicina); conto «Saldo», «Mesi di spese»
  («la soglia è 6», arancio sotto soglia), «Rende», «Quota del patrimonio»; immobile «Valore stimato», «Mutuo
  residuo», «Al netto del mutuo», «Quota del patrimonio»; debito «Debito residuo» (rosso), «Rata», «Finisce», «Tasso»;
  proposta «Versamento proposto» (viola), «Stato», «Adeguatezza» («Coerente · 6 controlli su 6»), «Area».
- **Le schede** (segmentato), solo quelle che hanno contenuto:
  - **In breve**: l'andamento in piccolo («Come sta andando», con «Andamento ›») e «Se si chiudesse oggi» (imposta,
    netto, SRI, con «Costi e rischio ›»; per la previdenza «Per la pensione»); per una protezione «Rispetto al bisogno» o
    «Da fare» (scadenza vicina) e «Se succede»; per una proposta «A cosa risponde» e «Cosa manca per chiuderla»;
  - **Andamento**: «Storico dei valori», «Andamento dal…», «Contro un riferimento», «Proiezione a 20 anni»;
  - **Costi e rischio**: «Costi, ipotesi e rischio», «Composizione…», «La gestione separata», «La copertura»;
  - **Contratto**: «Dati del contratto» **solo con le righe compilate**; le vuote non si mostrano una per una: un riquadro
    «Da completare · {n}» con i nomi in capsule e **un solo** «Completa i dati» che apre «Modifica» sui campi vuoti
    («Si completano in una volta, da «Modifica».»);
  - **Adeguatezza**: solo per le proposte, la «Scheda di adeguatezza» di oggi.
  Un conto corrente ha solo «In breve» e «Contratto». In fondo a «In breve» (solo lì, non in Andamento né in Costi e
  rischio) una striscia «{n} dati da completare» (arancio, grassetto) · i nomi separati da virgole · «Vedi ›» porta a
  Contratto. I collegamenti «Andamento ›» e «Costi e rischio ›» delle card di In breve scelgono la scheda.
- Esc nella scheda fa un passo indietro (torna all'elenco) invece di chiudere la finestra.

### 15.2 Nell'app oggi

- `Sources/Prisma/Shell/DettaglioPosizione.swift`:
  - barra (`rigaNavigazione`, righe 164-232): «‹ Posizioni», poi Simula, Confronta (finanziarie), per una proposta
    «Segna come in essere» (`StileBlu`) ed «Esito…», «Valutazione» (proposte con condizioni), «Adeguatezza» (scorre
    all'ancora), «Apri un sinistro» (protezione in essere, macOS), «Prospetto», «Modifica»: **fino a otto pulsanti**, che
    diventano icone con poco spazio;
  - testata (`rigaIntestazione`, righe 237-268): barretta dell'area, nome, area · tipologia · emittente, canale e
    `PillolaStato`;
  - **una pagina lunga**: «Dati del contratto» (`contratto`, righe 272-304, `RigaDato` anche vuote con «—»), composizione
    e gestione separata, costi e rischio (`costiERischio`), fiscalità, storico, adeguatezza, andamento
    (`andamento`), `PannelloRiferimento`, `PannelloRiscatto`, proiezione con scenari e metodo, protezione, «Elimina la
    posizione…» in fondo;
  - i calcoli sono già in cache (`stato.ricavato("dettaglio-posizione|\(id)")`, `CalcoliDettaglio` a riga 769);
  - ancore «dettaglio-…» (`scorri`, riga 132) scritte da istantanee e da `StatoCompletezza.apriCompletamento`
    (`.dettaglioPosizione(pid, ancora)`): «dettaglio-andamento», «dettaglio-riferimento», «dettaglio-riscatto»,
    «dettaglio-composizione», «dettaglio-gestione», «dettaglio-adeguatezza».
- La frase e le quattro cifre in cima non ci sono. Esc oggi non fa niente nel dettaglio (nessun `.onExitCommand` in
  Posizioni; la miglioria 4 del gruppo 01, §4.3 punto 5, fa chiudere a Esc la finestra davanti).
- `PillolaStato` (`AppPosizioni.swift:649-679`) dice già «Scade tra {n} gg» (arancio) entro
  `RiepilogoPosizioni.giorniScadenza` = **90** giorni (`Motori/Riepilogo.swift:26`), «Scaduta» (rosso), «Chiusa»,
  «In essere» (verde) e, per le proposte, «Proposta · {esito}» (rifiutata rossa, rimandata arancio, le altre neutre). La
  usano anche le righe di `TabellaPosizioni` (righe 506 e 585). Per un debito oggi dice «In essere».
- I conti della frase e delle cifre ci sono già in `calcoli.voce` (`VoceResoconto`, `Motori/MotoreResoconto.swift:4-30`,
  solo per le finanziarie in essere): `versato`, `valore`, `risultato` e `risultatoPercento` (valore meno versato),
  `anni` (dalla decorrenza alla data del valore), `rendimentoAnnuo` (rendimento dei versamenti, XIRR, solo se la
  posizione ha almeno un anno), `rendimentoNettoAnnuo`, `costoAnnuo`, `fisco` (imposta e netto se si chiudesse oggi).

### 15.3 Cosa fare

1. In `DettaglioPosizione` (macOS) un enum `SchedaPosizione { case inBreve, andamento, costiRischio, contratto,
   adeguatezza }` con `static func disponibili(_ p: Posizione, calcoli:) -> [SchedaPosizione]`:
   andamento se c'è `calcoli.andamento` o `calcoli.proiezione`; costi e rischio se `p.area.proiettabile` o protezione;
   adeguatezza se `MotoreAdeguatezza.pertinente`; contratto sempre; in breve sempre. Stato `@State scheda` che torna a
   `.inBreve` quando cambia la posizione. Le ancore «dettaglio-…» scelgono la scheda (andamento, riferimento →
   Andamento; composizione, gestione, riscatto → Costi e rischio; adeguatezza → Adeguatezza) e poi scorrono come oggi.
2. Testata: resta `rigaIntestazione`; la `PillolaStato` di oggi con due ritocchi del template: «Scade tra {n} giorni»
   invece di «gg» (con la soglia di oggi, 90 giorni: nessuna soglia nuova) e «Debito» (neutra) per i debiti in essere.
   «Scaduta», «Chiusa» e «Proposta · {esito}» restano (il template ha solo «Proposta», ma l'esito è un'informazione in
   più che oggi c'è). Il ritocco vale anche nelle righe dell'elenco (14) e su iPad, che usano la stessa pillola.
3. **La frase** (`FraseDettaglioPosizione`, testi in un `enum TestiDettaglioPosizione`): una funzione per area con i
   dati veri — per le finanziarie in essere tutto da `calcoli.voce` (`valore`, `versato`, `risultato`, `anni`
   arrotondati all'anno intero, come il template «in {N} anni»), così frase e cifre tornano con «Rendimento dei tuoi
   versamenti» di oggi; per le altre capitale e premio annuo (`p.capitaleAssicurato`, `p.premioAnnuo`), `p.scadenza`, i
   mesi di spese dalla liquidità di Analisi 360 (`stato.aree360`, in cache), il debito residuo (`p.controvalore ??
   p.valore`). «ne ha guadagnati» / «ne ha persi» secondo il segno di `risultato`. Se manca un dato la frase si accorcia («Vale 18.400 € al 31 ottobre 2026.»): mai cifre
   inventate. Proposta: «presentata il {data}» da `p.seguito?.presentataIl`.
4. **Le quattro cifre**: `FasciaKPI`/tessere del tema con i titoli del template; una tessera senza dato non si mostra
   (tre tessere vanno bene). «Rende all'anno» = `voce.rendimentoAnnuo` (rendimento dei versamenti) quando c'è,
   altrimenti il rendimento atteso netto che il dettaglio usa già per la proiezione (`calcoli.proiezione?.parametri.
   rendimento`), con la nota «atteso, al netto dei costi» (vedi 15.6). «Guadagno» = `voce.risultato` con
   «{risultatoPercento} in tutto», verde se positivo, rosso se negativo. «Adeguatezza» per una proposta = «{ok} controlli su {tot}» da
   `stato.schedaAdeguatezza(p.id)`.
5. **Le schede**, con il segmentato del tema `SegmentatoPillola` (`DesignSystem/Apple/ControlliApple.swift:19`):
   - In breve: andamento piccolo (riuso del grafico di `andamento(_:)` in misura ridotta, con «Andamento ›»), «Se si
     chiudesse oggi» dai conti di `fiscalita` (imposta, netto) e la `ScalaRischio`, con «Costi e rischio ›»; per le
     protezioni la riga del bisogno (Analisi 360) o il «Da fare» se scade presto; per le proposte «A cosa risponde»
     (obiettivo collegato o area) e «Cosa manca per chiuderla» (risposta, firma), più la striscia dei dati vuoti. Per la
     previdenza (niente imposta sul rendimento) la seconda card è «Per la pensione» (quanto versa all'anno o «niente,
     per ora», «I versamenti si deducono dal reddito», la scala del rischio) al posto di «Se si chiudesse oggi»; per
     conti, immobili e debiti una sola card «In breve» con una frase (riserva sopra o sotto i 6 mesi di spese; immobili
     fuori dal patrimonio finanziario; debito sottratto dal netto e dall'asse);
   - Andamento: `andamento`, `periodiTabella`, `PannelloRiferimento`, `storico`, `proiezione` con scenari e metodo;
   - Costi e rischio: `costiERischio`, `PannelloComposizione`, `PannelloGestioneSeparata`, `fiscalita`,
     `PannelloRiscatto`, `protezione`;
   - Contratto: le righe di `contratto` **solo se piene**, a sinistra; a destra «Da completare · {n}» con i nomi
     (capsule) e «Completa i dati», che apre `modifica` con `FuocoModulo` sul primo campo vuoto (`\.fuocoModulo` c'è
     già in `ModuloPosizione`). L'elenco dei campi vuoti è una funzione `campiVuoti(_ p: Posizione) -> [String]` che
     conta **solo i campi pertinenti al tipo**, come il template (`vuotiDi`): per le polizze (protezione, previdenza,
     rivalutabili, multiramo) Numero, Contraente, Assicurato, Beneficiari, Decorrenza, Scadenza; per fondi ed ETF il numero
     e l'intestatario (template «Numero del deposito», «Intestatario»); per conti, immobili e debiti l'intestatario. Sono
     gli stessi campi di oggi (`numeroContratto`, `contraente`, …) con l'etichetta del tipo: nessun campo nuovo (il
     template cita «Banca» e «Indirizzo», che `Posizione` non ha: non si aggiungono). «Note» e «Garanzie» vuote non
     contano come dati da completare: se vuote semplicemente non compaiono;
   - Adeguatezza: `PannelloAdeguatezza`.
6. **I pulsanti** (al massimo quattro in vista, sempre con il nome; il resto in «Altro ⌄»):
   - proposta: «Segna come in essere» (`stato.apriEsito(…, passo: .accettata)`), «Esito…», «Altro ⌄» con Simula,
     Confronta, Adeguatezza (sceglie la scheda), Valutazione (se c'è), Prospetto, Modifica, Elimina la posizione…;
   - in essere finanziaria: Simula, Confronta, Prospetto, Modifica, e in «Altro ⌄» Elimina la posizione…;
   - in essere protezione: «Apri un sinistro», Prospetto, Modifica, «Altro ⌄» (Elimina…);
   - altre: Prospetto, Modifica, «Altro ⌄» (Elimina…).
   «Elimina la posizione…» esce dal fondo della pagina e va in «Altro ⌄» (con la conferma di oggi).
7. Il ritorno: «‹ Le posizioni» (nome del template, oggi «Posizioni») torna alla schermata della miglioria 14 da cui si
   è partiti, con i filtri di prima. **Esc**: un passo indietro (`stato.posizioneInDettaglio = nil`) invece di chiudere la
   finestra. Va messo nello stesso punto in cui la miglioria 4 del gruppo 01 aggancia Esc alla finestra davanti, con la
   precedenza al dettaglio aperto (come il template: `stopImmediatePropagation` solo se la scheda è aperta e non c'è un
   foglio, un pannello o la modalità cliente pulita): un `.onExitCommand` sulla sola vista del dettaglio non basta, perché
   scatta solo se il fuoco è dentro di lei.
8. Token in `Tema.Apple+Posizioni.swift`, `enum SchedaPosizione` (attenzione: c'è già `Posizioni.Scheda` del nastro:
   nome diverso): `frase` (19 semibold, interlinea 1,3, margini 14/12), `altezzaBarra` 34, `barrettaArea` 5,
   `titolo` 24 bold, `spazioSchede` 14/12, `striscia` (dati da completare: testo arancio della miglioria 7).
9. Non fare: non portare le cifre e le serie del template (`contoP`, `premioDi`, `CRISI`); non nascondere nessuna
   sezione di oggi (si spostano tutte in una scheda); non togliere la conferma di «Elimina».

### 15.4 Dati, archivio, privacy

Nessun campo nuovo. «Completa i dati» apre il modulo di oggi. La frase usa il nome del cliente: in modalità cliente
resta il suo (nessun dato di altri clienti).

### 15.5 Istantanee e prove

- Aggiornare le scene del dettaglio: `Istantanee.swift:39` (ETF di Giulia), `:48` (infortuni di Marco), `:533-553`
  («dettaglio-andamento», riscatto, obbligazionario), `:633-637` (composizione), `:716`, `:729`, `:804-813`
  (adeguatezza), `:966-968`, `:1025`: con l'ancora ora si apre la scheda giusta.
- Nuove: `1027-uso-posizione-in-breve` (ETF di Giulia: frase, cifre, In breve) e `-scuro`; `1028-uso-posizione-contratto`
  (una polizza con dati vuoti: righe piene e «Da completare · 5»); `1029-uso-proposta` (il piano previdenziale di Giulia
  in proposta: tre pulsanti e la scheda Adeguatezza).
- `--prova-calcoli` (o una prova nuova in `ProvaSeguito`/`ProvaAdeguatezza`): la frase non inventa cifre (posizione
  senza `totaleVersato` → frase corta); `campiVuoti` conta solo i campi pertinenti (un ETF senza numero né
  intestatario → 2, mai «Assicurato» o «Beneficiari»).

### 15.6 Decisioni per l'utente e rischi

- **«Rende all'anno»**: nel template è il rendimento atteso «al netto dei costi». Prisma ha due misure (il rendimento
  ipotizzato del prodotto e il rendimento dei tuoi versamenti, `DettaglioPosizione.notaVersamenti`, riga 445). Proposta:
  il rendimento dei versamenti quando il motore lo dà (`voce.rendimentoAnnuo`, cioè posizione con almeno un anno e i
  flussi), altrimenti l'atteso netto con la scritta «atteso».
- **La protezione ha «Costi e rischio»?** Nel codice del template no (solo In breve e Contratto); la regola mette «La
  copertura» in Costi e rischio. Proposta: per la protezione la scheda si chiama «La copertura» e contiene il pannello
  `protezione` di oggi.
- **«Apri un sinistro», «Valutazione» ed «Elimina»** non sono nel template. Proposta come al punto 6.
- Rischio: il dettaglio oggi è una vista lunga; con le schede si costruisce solo la scheda scelta (meno lavoro). Le
  ancore che arrivano mentre si cambia scheda vanno consumate dopo il cambio (come fa già `apriCompletamento` con
  `DispatchQueue.main.async`).

### 15.7 Dimensione

L. File: `Shell/DettaglioPosizione.swift` (da dividere: nuovo `Shell/SchedeDettaglioPosizione.swift` per le schede e
la frase), `Shell/AppPosizioni.swift` (`PillolaStato`), il punto di Esc della miglioria 4 (gruppo 01,
`Shell/FinestraInterna.swift`), `DesignSystem/Apple/Tema.Apple+Posizioni.swift`, `Istantanee.swift`.

---

## 16. Un solo avviso sulle stime in Analisi 360

### 16.1 Nel template

Codice: righe 3381-3388 (`apriDati`, `areaDato`, `agganciaPanoramica`) e 3665-3667 (`stimeChip`, `agganciaAn`);
`anHTML` della base a riga 1665 mette `stimeChip(c)` nella riga del segmentato. Regola 16 a righe 2659-2662. Si apre con
`vaiCli(1,'analisi', vistaA='aree')` e il cartellino indica `#anStime`.

- In Analisi 360 l'avviso sulle stime compare **una volta sola**, in alto a destra, sulla stessa riga del segmentato
  «Le quattro aree | Rispetto alle famiglie come la sua»: una capsula «Stime in uso · {n} dati da completare ›»
  (arancio: testo `--orangeT`, bordo arancio al 35%). Con zero dati mancanti: «✓ Nessuna stima: i dati ci sono tutti»
  (verde).
- Spariscono i cinque punti di oggi: «ipotesi stimate», «stimato», «Ipotesi da verificare con il cliente» sulle card, la
  riga in basso.
- Clic: si apre (nasce dalla capsula, 680 × altezza secondo le voci) **lo stesso elenco «Dati per l'analisi» del
  dossier** (miglioria 5 del gruppo 01): occhiello «Dati per l'analisi · {nome}», titolo «Completi al {n}%», testo «Un
  elenco solo, lo stesso in Clienti e in Analisi 360. Più dati ci sono, meno stime fa Prisma.», poi le voci: pallino,
  nome del dato, sotto «Finché manca, Prisma usa una stima · pesa su {Previdenza / Protezione / Investimenti /
  Risparmio}», e «Completa». Vuoto: «✓ Tutti i dati ci sono: nessuna stima in uso.»
- Completare un dato da una parte lo toglie anche dall'altra (avviso «Dato completato: una stima in meno»); chiuso il
  dettaglio, la schermata si ridisegna.

### 16.2 Nell'app oggi

- `Shell/Analisi360Apple.swift`:
  - testata (`testata`, righe 280-302): occhiello, «Il percorso di {nome}.», e `rigaCompletezza` (righe 306-323): «Dati
    per l'analisi completi al 77% · 7 ipotesi stimate» (`TestiCompletezza.rigaAnalisi`) con «Completa nella scheda del
    cliente ›»; a destra le pillole dei clienti (che la miglioria 2 toglie);
  - ogni card (`statoIpotesi`, righe 428-439): «{n} ipotesi stimate» (arancio), «Dati confermati» o «Ipotesi da
    verificare»;
  - piede (`piede`, righe 454-498): «Le quattro aree leggono ipotesi dedicate allo stesso cliente. Capitale e versamenti
    possono sovrapporsi: verifica le allocazioni prima di sommare i piani.» seguito da «Ipotesi ricavate dalle posizioni
    in essere e dall'anagrafica: rivedile con il cliente.» (o «Ipotesi corrette per questo cliente…» con l'analisi
    salvata). Solo l'ultima frase è il richiamo alle stime; la prima è un'avvertenza sulle somme dei piani;
  - `RigaVisteAnalisi360` (il segmentato delle due viste) sotto la testata.
- `Shell/AppAnalisi360.swift`: `notaStato` della cornice «Calcoli eseguiti in locale · conteggi semplificati, da
  verificare con il cliente e sui contratti» (riga 45); nella colonna «Le ipotesi» con il testo e «Riparti dalle
  posizioni» (righe 91-109); nelle aree aperte il piede «Ipotesi da verificare con il cliente» (riga 132) e la pillola
  «stimato» accanto ai campi (`Analisi360Previdenza.swift:106`).
- L'elenco: `DatiAnalisiApple` in `Shell/DossierPanoramica.swift:167` (voci di `MotoreCompletezza`, «Completa» →
  `stato.apriCompletamento`, croce «Non pertinente»), in cache con `stato.completezzaCliente(id)`. Ogni
  `VoceCompletezza` ha già `ipotesi` (che cosa usa l'analisi al posto del dato) e `analisi` (le analisi toccate, con
  `AnalisiCompletezza.areaAnalisi` per le quattro aree, `MotoreCompletezza.swift:26`). Il gruppo 01 (miglioria 5, §5.3)
  lo apre in un `DettaglioApple` che nasce dalla riga `RigaDatiAnalisi` della Panoramica.
- Il presentatore di Analisi 360 (`PresentatoreAree360`, righe 79-110) mostra `DettaglioArea360Apple(id:)` (righe
  113-133), che oggi conosce solo i simulatori e le aree Investimenti e Risparmio: un id nuovo va aggiunto lì.

### 16.3 Cosa fare

1. Riusare l'elenco che la miglioria 5 del gruppo 01 porta in un dettaglio (`DatiAnalisiApple`, che nasce dalla riga
   `RigaDatiAnalisi` della Panoramica). Qui serve solo una seconda porta: una capsula `AvvisoStimeAnalisi360` nella
   riga di `RigaVisteAnalisi360` (a destra), con `origineDettaglio(id: "stime-analisi360")`, che apre lo stesso
   contenuto nel presentatore di Analisi 360 (`PresentatoreAree360` → `dettaglio?.apri(id, misura:)`), con un ramo nuovo
   in `DettaglioArea360Apple` per questo id (`DatiAnalisiApple(cliente:)` nella testata del template: occhiello «Dati
   per l'analisi · {nome}», «Completi al {n}%», il testo «Un elenco solo…»). Se la testata del gruppo 01 è già dentro
   `DatiAnalisiApple`, qui non si aggiunge niente.
2. Testi in `TestiCompletezza`: `avvisoStime(n)` = «Stime in uso · {n} dati da completare ›» («1 dato»), `nessunaStima`
   = «Nessuna stima: i dati ci sono tutti», `unElencoSolo` = «Un elenco solo, lo stesso in Clienti e in Analisi 360.
   Più dati ci sono, meno stime fa Prisma.», `tuttiIDati` = «Tutti i dati ci sono: nessuna stima in uso.»,
   `completiAl(n)` = «Completi al {n}%». La riga sotto ogni voce: `voce.ipotesi` se c'è (è più precisa del generico),
   altrimenti «Finché manca, Prisma usa una stima», più « · pesa su {aree}» dalle `analisi` della voce che hanno
   un'`areaAnalisi`.
3. Togliere dalla schermata delle aree: `rigaCompletezza` nella testata; `statoIpotesi` sulle card (resta la riga dei
   canali); dal piede la sola frase sulle ipotesi («Ipotesi ricavate…» / «Ipotesi corrette…»; restano «Strumenti»,
   «Prepara l'incontro» e l'avvertenza «Capitale e versamenti possono sovrapporsi…», che non parla di stime); da `notaStato` di
   `AppAnalisi360` la parte «da verificare con il cliente e sui contratti» (vedi 16.6); dalla colonna il blocco «Le
   ipotesi» quando non è aperta un'area (resta «Riparti dalle posizioni» se l'analisi è salvata).
4. «Completa» nell'elenco porta dove il dato si completa (`stato.apriCompletamento`, come oggi): l'app vera non
   completa al volo come il template. Chiuso il dettaglio, la completezza si rifà da sola (è in cache su
   `versioneCalcoli`).
5. Token in `Tema.Apple+Aree360.swift`, `enum Stime`: carattere della capsula (12,5 semibold), padding, testo arancio
   (`--orangeT`), bordo arancio al 35%, verde per «nessuna stima», misura del dettaglio (larghezza 680, altezza di base
   196 + 62 per voce, massimo come i dettagli delle aree).
6. In modalità cliente la capsula non c'è (oggi `rigaCompletezza` già nasconde «Completa» al cliente).
7. Non fare: non duplicare l'elenco (una vista sola, due porte); non lasciare «ipotesi stimate» sulle card.

### 16.4 Dati, archivio, privacy

Nessun campo nuovo. I dati «non pertinenti» restano `datiNonPertinenti` di oggi.

### 16.5 Istantanee e prove

- Aggiornare `440-analisi360-apple` e `-scuro` (la capsula al posto della riga e degli stati delle card),
  `111-analisi360-ipotesi-stimate`, `17-analisi360`, `443`, `444` (`Shell/IstantaneeAnalisi360Apple.swift`).
- Nuova `1030-uso-analisi360-stime-aperte` (Giulia: l'elenco aperto dalla capsula, con `RichiestaIstantaneaAnalisi360`
  esteso a questo id) e `1031-uso-analisi360-nessuna-stima` (un cliente completo: la capsula verde).
- `ProvaProspettiCompletezza` (in `--prova-prospetti`) resta: i prospetti delle ipotesi stimate non cambiano.

### 16.6 Decisioni per l'utente e rischi

- **Le pillole «stimato» dentro un'area aperta** (accanto al campo da correggere, `Analisi360Previdenza.swift:106`) e il
  piede dei risultati dell'area aperta («Ipotesi da verificare con il cliente» / «Dati confermati con il cliente»,
  `AppAnalisi360.swift:131-132`): il template parla della schermata delle aree. Proposta: restano, perché sono accanto
  al dato che si corregge; spariscono solo i richiami ripetuti della griglia.
- **La nota in basso della cornice** («conteggi semplificati, da verificare con il cliente»): è anche un'avvertenza
  sui calcoli. Proposta: resta «Calcoli eseguiti in locale · conteggi semplificati».
- Il numero della capsula non è una decisione: è la lunghezza dello stesso elenco che apre (tutte le voci da
  completare del cliente, `daCompletare.count`, come la riga del dossier), non i conti per area delle card di oggi.
- Rischio: due porte per lo stesso dettaglio in due presentatori diversi (Clienti e Analisi 360): l'elenco deve essere
  una vista senza stato proprio (legge `completezzaCliente`), così i due restano uguali.

### 16.7 Dimensione

S. File: `Shell/Analisi360Apple.swift`, `Shell/AppAnalisi360.swift`, `Motori/TestiCompletezza.swift`, il componente
dell'elenco del gruppo 01 (`Shell/DossierPanoramica.swift`), `DesignSystem/Apple/Tema.Apple+Aree360.swift`.

---

## 17. Le priorità in ordine: 1, 2, 3

### 17.1 Nel template

Codice: righe 3661-3664 (`prioritaDi`, `prioritaChip`), la card della base a riga 1183, gli stili `.prio` e `.prio.p1`
a righe 556-557; la sezione Bisogni a righe 3441-3442. Regola 17 a righe 2663-2664. Si apre con
`vaiCli(1,'analisi', vistaA='aree')` e il cartellino indica `#griglia .prio`.

- «★ Priorità» (oggi su tre card su quattro) diventa **«Priorità 1», «Priorità 2», «Priorità 3»**, al massimo tre,
  accanto al nome dell'area sulla card.
- Stile: capsula 11 bold, padding 2×9, letter-spacing 0,2; «Priorità 1» arancio tenue con il testo arancio
  (`--orangeT`), «Priorità 2» e «3» neutre (fondo chip, testo grigio).
- L'ordine nel template: dall'area **più scoperta** (copertura più bassa), escluse quelle al 100% e gli investimenti
  dall'80% in su.
- **Lo stesso ordine è nella sezione Bisogni del dossier**: grandi numeri 1, 2, 3 nel colore dell'area, il bisogno, la
  capsula «Alta»/«Media», «Analizza in Analisi 360 ›», e la nota «L'ordine è lo stesso che vedi sulle schede di Analisi
  360 («Priorità 1, 2, 3»).»

### 17.2 Nell'app oggi

- `CardArea360Apple` (`Shell/Analisi360Apple.swift:527-640`): con `priorita: Bool` mostra «★ Priorità» (riga 612,
  aiuto «Priorità del cliente, dalla ruota dei bisogni nella sua scheda»), carattere `Tema.Apple.Aree360.Area.priorita`
  (11,5 semibold), colore `colorePriorita` (arancio).
- Le priorità: `ingressiCard` (righe 410-425) prende `MotoreBisogni.priorita(...).prefix(3).map(\.areaAnalisi)`: le
  prime tre **aree dei bisogni** (sei: casa, famiglia, salute, lavoro, pensione, patrimonio) portate sulle quattro aree
  di analisi (`Dati/Bisogni.swift:44`). Due bisogni possono cadere sulla stessa area (famiglia e salute → Protezione;
  casa e lavoro → Risparmio): per questo spesso tre card su quattro hanno la stella e nessuna dice da dove partire.
- La scheda Bisogni (`Shell/BisogniCliente.swift:52-97`) numera già 1, 2, 3 i primi tre bisogni della ruota (sei aree
  dei bisogni, `elenco.prefix(3)`), ciascuno con la capsula dell'importanza e **già** il collegamento «Analizza in
  Analisi 360 · {area} ›» (righe 84-94: sceglie il cliente, imposta `stato.areaAnalisi` e apre Analisi 360). Con la
  ruota vuota dice «La ruota è ancora vuota.». Due bisogni della stessa area di analisi hanno oggi due numeri diversi.

### 17.3 Cosa fare

1. In `Analisi360Apple.ingressiCard`: `prioritarie` diventa un **ordine senza doppioni** sulle aree di analisi
   (`[AreaAnalisi]`, al massimo tre): si prendono i primi tre bisogni di `MotoreBisogni.priorita` (gli stessi tre che
   Bisogni numera) e si tiene la prima volta che compare ogni area; con un doppione le capsule sono due, non si va a
   pescare il quarto bisogno (così ogni capsula ha la sua riga in Bisogni). Vedi 17.6 per la fonte.
2. `CardArea360Apple`: `priorita: Bool` → `numeroPriorita: Int?` (1, 2, 3 o nil), anche nel confronto `==`. Al posto di
   «★ Priorità» una capsula «Priorità {n}» (componente `CapsulaPriorita`), con l'aiuto «Da dove partire con {nome}:
   l'ordine dei bisogni nella sua scheda».
3. Token in `Tema.Apple+Aree360.swift` (`Area`): `priorita` 11 bold con tracking 0,2, `paddingPriorita` 2×9,
   `fondoPrimaPriorita` (arancio tenue), `testoPrimaPriorita` (`--orangeT`), `fondoPriorita` (chip), `testoPriorita`
   (inchiostro2). Togliere `colorePriorita` se non serve più.
4. Scheda Bisogni: il collegamento a Analisi 360 c'è già (non va rifatto). Si aggiunge sotto i tre numeri la nota
   «L'ordine è lo stesso che vedi sulle schede di Analisi 360 («Priorità 1, 2, 3»).», ma **solo se è vera**: i numeri di
   Bisogni contano i bisogni (sei aree), le card le aree di analisi (quattro), e con due bisogni sulla stessa area le due
   numerazioni divergono (vedi 17.6). Non compare con la ruota vuota.
5. Non fare: non mostrare più di tre capsule; non lasciare la stella.

### 17.4 Dati, archivio, privacy

Nessun campo nuovo. La ruota dei bisogni è già nel file del cliente (`Cliente.bisogni`).

### 17.5 Istantanee e prove

- Aggiornare `440-analisi360-apple` e `-scuro`, `99-analisi360-pensione`, `300`, `301` (le card con «Priorità n»).
- Nuova `1075-uso-dossier-bisogni` (era 1032, già preso) (Marco, sezione Bisogni con la nota sull'ordine).
- `--prova-calcoli`: un caso con due bisogni sulla stessa area (famiglia e salute in testa) → «Priorità 1»
  Protezione, «Priorità 2» l'area del terzo bisogno, nessuna «Priorità 3», mai due capsule uguali; un caso senza ruota
  (fallback dall'area più scoperta, se l'utente lo approva).

### 17.6 Decisioni per l'utente e rischi

- **La fonte dell'ordine.** Il template ordina dall'area più scoperta (la copertura degli anelli); oggi Prisma usa la
  ruota dei bisogni del cliente (quello che conta per lui), che orienta anche la traccia di Vera. Proposta: restare
  sulla ruota dei bisogni (così le capsule seguono la sezione Bisogni, salvo i doppioni del punto sotto) e, solo per un cliente senza
  ruota (nessun bisogno confermato), usare l'ordine del template: dall'area più scoperta, escluse quelle al 100% e gli
  investimenti dall'80%.
- **Bisogni e card devono dire la stessa cosa.** Esempio: ruota con 1 famiglia, 2 salute, 3 pensione → card «Priorità
  1» Protezione, «Priorità 2» Previdenza, mentre Bisogni dice «3 · La pensione». Proposta: su ogni riga di Bisogni, accanto
  al collegamento, la capsula della card («Priorità 1 · Protezione», la stessa per famiglia e salute), e la nota del
  template solo quando le due numerazioni coincidono; altrimenti «Sulle schede di Analisi 360 due bisogni della stessa
  area contano una volta.». In alternativa (più vicina al template) Bisogni raggruppa per area di analisi, come le sue
  righe «La pensione», «La protezione…»: cambia la scheda di oggi, quindi non proposta.
- **Senza ruota.** Con il fallback dall'area più scoperta le card hanno priorità mentre Bisogni dice «La ruota è ancora
  vuota.»: la nota non compare e l'aiuto della capsula dice «Dall'area più scoperta: la ruota dei bisogni è vuota».
- Rischio: nessuno di prestazioni (la priorità è già calcolata una volta per la griglia, `ingressiCard`; con il fallback
  servono le coperture delle aree, già in cache con `stato.aree360`).

### 17.7 Dimensione

S. File: `Shell/Analisi360Apple.swift`, `Shell/BisogniCliente.swift`, `DesignSystem/Apple/Tema.Apple+Aree360.swift`.
