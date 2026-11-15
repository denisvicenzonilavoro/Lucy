# Gruppo 04 — Messaggi, Vera, Studio (parcelle), Mercato, Impostazioni (migliorie 25-31)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html. Le righe citate sono di quella copia: le regole del gruppo nel commento a
righe 2709-2745 («IL QUARTO GIRO»), il codice a righe 3883-4078 (MIGLIORIA 25-31), il pannello «✦ Migliorie» (`MIG4`) a
righe 4082-4089, il CSS nuovo a righe 580 (`.bN2`), 624-638 (`.vGr`, `.vCard`, `.passiF`, `.mkA.zitto`, `.impQ`,
`.impSt`, `.impF`, `.card.spento`). La base da confrontare («Luce» nel template) sta a righe 1246-1257 (Vera),
1312-1368 (Impostazioni), 1369-1420 (Studio), 1480-1496 (Messaggi), 1498-1510 (Mercato). Per ciò che qui non cambia
valgono «Luce» (Design/template-luce.html e Design/template-luce-specifica.md), la specifica di «Orizzonte»
(Design/template-novita-specifica.md: §3 Parcelle, §5 Messaggi, §12 Mercato, §13 Impostazioni) e il tema Apple
(Design/template-apple-specifica.md: §4.6 Impostazioni, §4.7 Vera).

Regole che valgono per tutto il gruppo:

- **Solo Mac.** `PannelloMessaggio` serve anche l'iPhone e l'iPad (iOS/MessaggiTelefono.swift), `AppImpostazioni` e
  `AppMercato` anche l'iPad (iOS/MercatoTelefono.swift per l'iPhone), `SessioneMessaggi` e `MotoreOccasioniMessaggi` anche l'iPhone. Le viste nuove vanno sotto
  `#if os(macOS)` o dietro un parametro che iPhone e iPad non usano: il loro giro viene dopo. I motori possono crescere
  (un campo in più che iPhone e iPad ignorano), ma il loro comportamento lì non cambia.
- **La grafica non cambia.** Tema Apple, vetro, colori dei canali, caratteri restano. Ogni misura o colore nuovo
  diventa un token in `Sources/Prisma/DesignSystem/Apple/` (file indicati per miglioria).
- **Le cifre e i testi del template sono dimostrativi** (`MSG`, `FATT`, `EVM`, `AVM`, `IMPS`, gli importi di Laura,
  Marco, Sofia, le soglie scritte nella scheda «Soglie degli avvisi», `incF=21300`, «3 di 12 compilati»): non si
  portano. Le cifre le danno i motori che ci sono (`MotoreOccasioniMessaggi`, `MotoreParcelle`, `MotoreFattura`,
  `MotoreMercato`, `TestiAppMercato`), gli stati veri vengono dall'archivio e dalle impostazioni.
- **Il pannello «✦ Migliorie»** (`MIG4`, `indica(...)`, i cartellini numerati) è solo del template: nell'app NON va
  portato. Lo stesso per i `toast('… come oggi')` / `data-toast="Si cambia come oggi"`: dicono che lì l'app tiene il
  comportamento e i controlli di oggi.
- **Movimento:** solo le transizioni che le app hanno già (cascata con `entrataCascata`, cambio di voce con uscita breve,
  `Tema.Apple.Moto.ritmo`, `ritardoPrisma`); «Riduci movimento» (`\.prismaCalmo`) = dissolvenza 0,15 s; istantanee
  (`\.modoIstantanea`) nello stato finale. Niente Timer: la barra di avanzamento finta di «Preparo il file…» (riga
  3984) non si porta.
- **Prestazioni:** niente filtri, ordinamenti o motori su tutto l'archivio nei body. Gli elenchi di questo gruppo sono
  già piccoli e in cache (`occasioniMessaggi` in `DerivatiDati`, `stato.ricavato("studio.parcelle.elenco")`,
  `mercato-eventi|<ora>`): filtrare per cliente o per stato quegli elenchi è ammesso nel body; rifare i motori no.

## Ordine consigliato

Il gruppo poggia su quattro migliorie del gruppo 01, che vanno fatte prima:

- **2 · Un solo posto per il cliente** (`StatoShell.tuttiIClienti`, `scegliCliente(_:)`, `clienteAttivoId == ""` =
  «Tutti i clienti»): la usano la 25 (Messaggi segue il cliente), la 27 («Parliamo di» senza tendina né segmentato) e
  la 29 (Mercato segue il cliente).
- **4 · Una riga sola in testa alla finestra**: ci vanno «＋ Nuova parcella» (28) e l'etichetta «Escono solo dati
  pubblici» (29).
- **3 · Un solo «Da fare»**: la 27 toglie «Da non dimenticare» da Vera perché sta nel «Da fare»; la 29 dice che un
  avviso silenziato «non entra più nel «Da fare»». Attenzione: oggi gli avvisi di Mercato **non** sono in nessun «Da
  fare» (stanno solo nelle notifiche, Notifiche.swift:385, e come occasioni di Messaggi), e la tabella di 3.3 del
  gruppo 01 non dice dove vanno. Va deciso lì (proposta: voce del «Da fare» solo per gli avvisi `.nuovo`); finché non
  c'è, la frase della 29 deve dire il vero (vedi 29.6). La 31 riceve dalla 3 le «cose da sistemare» delle notifiche
  (backup non riuscito e in ritardo: Notifiche.swift:392-401).
- **9 e 10 · Niente nomi tecnici, le stesse parole**: «Vera · pronta» (27), via «Scritto da Vera con qwen…» (26), le
  parole «Tono», «Invia con», «Da sistemare» (26, 31).

Dentro il gruppo, in quest'ordine:

1. **26 · Il messaggio senza rumore**: solo il pannello del messaggio, testi e una scheda; nessun dato nuovo. Prima
   della 25 perché la 25 rifà la barra in basso dello stesso pannello.
2. **25 · Messaggi segue il cliente, e si vede cosa è partito**: un campo nuovo in `MessaggioCliente` (`speditoIl`) e la
   sezione «Mandati oggi».
3. **28 · Le parcelle dicono a che punto sono**: autonoma (serve solo la 4 per la riga in testa). Va coordinata con la
   **52** (gruppo 09, «Lo Studio in ordine»), che rifà lo stesso segmentato di `AzioniStudio`.
4. **29 · Mercato segue il cliente**: dopo la 2 e la 4. Il messaggio preparato da Mercato entra in Messaggi già filtrato
   sul cliente (25). «Fonte: Dati di prova…» sotto le tessere sparisce con la **37** (gruppo 06, Dimostrazione).
5. **27 · Vera dice cosa sa fare**: dopo la 2, la 3 e la 9 (la colonna perde tendina, «Oggi», «Da non dimenticare»,
   «Il quadro di…»).
6. **30 · Le impostazioni si cercano** e **31 · Si vede cosa resta da sistemare**: insieme (stessa barra laterale).
   Prima di queste conviene sapere cosa fanno la **37** (Strumenti diventa «Dimostrazione», in «Aiuto»), la **38**
   (Profilo: i nomi dei canali) e la **39** (iPhone e iPad: un collegamento solo), che cambiano tre sezioni: l'indice
   della ricerca (30) va aggiornato quando arrivano.

Altri incroci: `NumeroOcchielloApple` (25) serve anche al gruppo 03 (gruppo-03.md riga 45: chi arriva prima lo crea);
la 49 del gruppo 08 (campagna in tre passi) riusa «Tono» e «Invia con» della 26; la 37 del gruppo 06 toglie le righe
«Dati di prova…» di Messaggi e Mercato. Le istantanee nuove di questo gruppo stanno in **1040-1058** (convenzione
1000 + 20 × gruppo, gruppo-02.md riga 181: il gruppo 06 usa già 1060-1071).

---

## 25. Messaggi segue il cliente, e si vede cosa è già partito

### 25.1 Nel template

Regola 25 (righe 2710-2713), codice righe 3883-3935 (`msgVisibili`, `msgDi`, `msgNuovo`, `msgUsoHTML`, `compoUso`,
`barraMsg`, `montaBarraMsg`, `montaMsgUso`), pannello `MIG4[0]` riga 4083 (si apre con `vaiCli(0,'messaggi',…)`, cioè
con Giulia scelta nella barra).

- **L'elenco segue il cliente della barra** (`msgVisibili`, riga 3896): con un cliente scelto la colonna mostra solo i
  suoi messaggi; con «Tutti i clienti» (`cliSel==null`) tutti, come oggi. Messaggi entra nelle app che seguono il
  cliente (`APPCLI.push('messaggi')`, riga 3935).
- **Ogni gruppo ha il numero** (riga 3903): occhiello «Da mandare oggi», «Questa settimana», «Da festeggiare» seguito
  da un numerino in pillola `.bN2` (11 bold, fondo `chip`, testo `ink2`, raggio 99, padding 1×7; riga 580) con le voci
  ancora da mandare di quel gruppo.
- **Elenco vuoto per un cliente** (riga 3905): «Nessun messaggio da preparare per <Nome>. Quando c’è un incontro, una
  scadenza o un compleanno, lo trovi qui.». Pannello vuoto: «Niente da scrivere, per ora.» (riga 3907).
- **La riga** (riga 3902): avatar 38, nome, titolo del messaggio su una riga senza larghezza massima; a destra la spunta
  verde (`gu('fatto',17)`, colore `--green`) se è stato spedito.
- **La barra in basso ha tre stati** (`barraMsg`, righe 3917-3920):
  1. normale: «Apri in Mail» / «Apri in Messaggi» (blu), «Salva nel dossier», «↻ Riscrivi», a destra «Lo controlli e
     lo spedisci tu» (come oggi);
  2. dopo «Apri in …» (`m.aperto`): **«Aperto in Mail. L’hai spedito?»** (14,5 bold) con «Sì, spedito» (blu) e «Non
     ancora»; l'avviso dice «Aperto in Mail, già compilato: lo spedisci tu»;
  3. spedito (`m.inviato`): pillola verde con la spunta **«Spedito oggi alle 10:42 con Mail»**, accanto «È nel dossier di
     <Nome>.», a destra «Non è partito».
  La barra cambia stato con un'entrata breve (opacità 0→1, y 6→0, 260 ms; niente con «Riduci movimento»).
- **«Sì, spedito»** (riga 3925): segna l'ora e il canale, il messaggio passa in fondo all'elenco nella sezione
  **«Mandati oggi»** (con il numero), il pannello passa al prossimo messaggio da mandare (prima i non festeggiamenti);
  avviso «Segnato come spedito: resta nel dossier di <Nome>». **«Non ancora»** torna alla barra normale. **«Non è
  partito»** toglie il segno: il messaggio torna fra quelli da mandare.
- In fondo alla colonna resta la nota «Vera scrive, tu spedisci: niente parte da solo. Ogni messaggio resta nel dossier
  del cliente.».
- Un messaggio nato da un'altra app (Mercato, Parcelle: `msgNuovo`, riga 3900) entra in «Da mandare oggi»; se il
  cliente della barra è un altro, la barra passa a quel cliente (`scegliCli(k,1)`, righe 3983 e 4021).
- **La scelta segue il filtro** (riga 3901): se il messaggio scelto non è fra quelli del cliente, il pannello passa al
  primo da mandare, poi al primo dei mandati, altrimenti al pannello vuoto.
- **Un messaggio spedito si rilegge, non si riscrive** (riga 3929): il testo compare subito com'era (niente puntini né
  parola per parola) e la barra non ha «↻ Riscrivi».
- **I traguardi «Da festeggiare» non hanno la barra a tre stati**: `compoUso` li manda a `festHTML` come prima (riga
  3908), `msgDi` e il «prossimo» dopo «Sì, spedito» li saltano; non finiscono mai in «Mandati oggi».

### 25.2 Nell'app oggi

- `Sources/Prisma/Shell/AppMessaggi.swift:91` `AppMessaggi`: `elencoEPannello` (riga 131) prende
  `sessione.elenco(stato.occasioniMessaggiConRichieste())` di **tutti i clienti visibili**; non segue il cliente attivo
  (lo filtra solo in modalità cliente: `StatoMessaggi.swift:11`, `occasioniMessaggi` con `soloCliente`).
- `ColonnaOccasioniMessaggi` (AppMessaggi.swift:226): gruppi `GruppoMessaggio.allCases` («Da festeggiare», «Da mandare
  oggi», «Questa settimana»; `Motori/MotoreOccasioniMessaggi.swift:49`), occhielli **senza numero** (`occhiello`, riga
  320), nota in fondo `TestiMessaggi.notaColonna`. Vuoto: «Niente da mandare oggi» (`TestiMessaggi.nienteOggi`) e
  `VuotoMessaggi` (riga 422) con `TestiMessaggi.vuoto`.
- `VoceOccasioneMessaggio` (riga 333): avatar, nome, etichetta del canale compatta, titolo, e sotto il perché oppure
  **«✓ Preparato alle 10:42»** (`TestiMessaggi.preparato`, `OccasioneMessaggio.preparatoIl`).
- Dopo «Apri in Mail» (`PannelloMessaggio.apri`, PannelloMessaggio.swift:419 → `StatoShell.apriMessaggio`,
  StatoMessaggi.swift:69) il messaggio si salva nel dossier con `StatoMessaggio.apertoInMail`/`.apertoInMessaggi`
  (`Dati/MessaggioCliente.swift:199`) e `apertoIl`; l'occasione resta nel suo gruppo con «✓ Preparato alle…»
  (`MotoreOccasioniMessaggi.dividi`, riga 423: le occasioni coperte oggi restano con `preparatoIl`, quelle coperte
  nei giorni prima spariscono). **Non esiste la domanda «L'hai spedito?», né lo stato «spedito», né «Mandati oggi».**
- La barra (`PannelloMessaggio.barra`, riga 340) è sempre la stessa: «Apri in …» (o «Aggiungi nel dossier» se manca il
  recapito), «Salva nel dossier», «↻ Riscrivi», «Lo controlli e lo spedisci tu».
- Le richieste dalle altre app passano da `StatoShell.preparaMessaggio(…)` (CollegamentiMessaggi.swift:37) e
  `occasioniSuRichiesta` (righe 69-88); non cambiano il cliente attivo.
- **Il limite di 8 per gruppo** (`RegoleMessaggi.massimoPerGruppo`, applicato in `dividi` righe 456-460 su tutti i
  clienti, campagne escluse): oggi `soloCliente` della modalità cliente filtra **dopo** il taglio, quindi un cliente
  con occasioni oltre le prime 8 globali le perde.
- Il pannello di un traguardo è un altro (`PannelloTraguardo`, AppMessaggi.swift:157); `PannelloMessaggio.apri`
  (righe 419-436) passa prima dalla seconda lettura (`FoglioSecondaLettura`) e dal consenso commerciale, e segna il
  messaggio solo se `esito.aperto`; senza recapito il pulsante è «Aggiungi nel dossier». La riga dell'elenco limita il
  titolo a `Voce.larghezzaTitolo` (260) e mostra il canale e il perché (cose che «Luce» non aveva: restano).
- Nel dossier la riga del messaggio è in AppClienti.swift:510 («canale · tono · `m.stato.nome` · autore»); il messaggio
  riaperto dal dossier usa `m.stato.nome` anche in SessioneMessaggi.swift:290.

### 25.3 Cosa fare

1. **L'elenco segue il cliente** (AppMessaggi.swift, `elencoEPannello`), ma **non** filtrando l'elenco già tagliato:
   `soloCliente` (MotoreOccasioniMessaggi.swift:156) dopo il limite di 8 per gruppo perderebbe le occasioni del cliente
   che non stanno fra le prime 8 di tutti (vedi 25.2). Il motore riceve il cliente prima del taglio:
   `MotoreOccasioniMessaggi.dividi(…, soloCliente: String? = nil)` (e `calcola`, stesso parametro facoltativo: l'iPhone
   non lo passa e non cambia), e `StatoShell.occasioniMessaggi(cliente:)` lo tiene con
   `stato.ricavato("messaggi-occasioni|<clienteId>") { … }` (stessa validità della cache di oggi: dati dei calcoli,
   giorno, modalità cliente). La stessa via corregge la modalità cliente (oggi `soloCliente` dopo il taglio,
   StatoMessaggi.swift:14). `occasioniMessaggiConRichieste` filtra anche le occasioni su richiesta per il cliente. Solo
   Mac (`#if os(macOS)` nella vista), l'iPhone resta com'è. La vista Campagne non cambia (decisione 50 di «Luce»: mostra
   tutti). La scelta del pannello segue il filtro come nel template (25.1): `sessione.occasione(in:)` lo fa già
   (scelta assente → prima voce); al cambio di cliente la prima voce è quella di `tutte.first`, e se `tutte` è vuota il
   pannello è vuoto.
2. **Il numero accanto all'occhiello**: `occhiello(_:numero:primo:)` con una pillola nuova `NumeroOcchielloApple`
   (DesignSystem/Apple/, riusabile: la usa anche «Occasioni» in Agenda nel gruppo 03). Il numero conta le voci del
   gruppo **non spedite**.
3. **Lo stato «spedito»**:
   - `MessaggioCliente.speditoIl: Date?` (campo nuovo, vedi 25.4). Funzioni nuove in `StatoMessaggi.swift`:
     `segnaSpedito(messaggioId:)` (mette `speditoIl = MessaggioCliente.adesso`, solo se il messaggio è
     `apertoInMail`/`apertoInMessaggi`, non in sola lettura) e `togliSpedito(messaggioId:)`.
   - Sull'occasione, non salvati (come `preparatoIl`): `speditoIl: Date?` e **la copertura** che oggi `dividi` butta
     via, cioè id, stato (`apertoInMail`/`apertoInMessaggi`/`salvato`) e canale del messaggio più recente che la copre
     (per esempio `copertura: CoperturaMessaggio?`). Li riempie `MotoreOccasioniMessaggi.dividi` nello stesso giro che
     oggi riempie `preparatoIl` (righe 430-441), e `occasioniMessaggiConRichieste` (CollegamentiMessaggi.swift:81) per
     quelle su richiesta. Così la colonna e la barra sanno «aperto / salvato / spedito» senza cercare in
     `dati.messaggi` nel body (regola: niente filtri su tutto l'archivio nei body). `GruppoMessaggio` **non** cambia (lo
     usa l'iPhone).
   - Nella colonna del Mac le voci con `speditoIl` di oggi escono dal loro gruppo e vanno in fondo, nell'occhiello nuovo
     **«Mandati oggi»** (`TestiMessaggi.mandatiOggi`) con il numero; la riga mostra la spunta verde a destra
     (`Tema.Apple.Messaggi.Voce.spuntaSpedito`, `coloreSpedito` = `Colore.verde`) e sotto «Spedito alle 10:42»
     (`TestiMessaggi.spedito(_:)`), al posto di «✓ Preparato alle…».
   - Le voci aperte ma non confermate restano nel loro gruppo; sotto il titolo «Aperto in Mail alle 10:42» al posto di
     «✓ Preparato alle…» (`TestiMessaggi.aperto(_:canale:)`; vedi 25.6). Le voci solo salvate tengono «✓ Preparato
     alle…»; i traguardi tengono `TestiTraguardi.festeggiato`.
   - Il titolo della riga perde la larghezza massima sul Mac (`Voce.larghezzaTitolo` resta per l'iPhone), come
     `max-width:none` del template; canale e perché restano.
4. **La barra a tre stati** (PannelloMessaggio.swift, `barra`, solo Mac quando `incorniciato` e non `compatto`; iPad e
   iPhone tengono la barra di oggi):
   - stato «da confermare» = la `copertura` dell'occasione è `apertoInMail`/`apertoInMessaggi` di oggi, senza
     `speditoIl`, e la domanda non è stata chiusa con «Non ancora» in questa sessione
     (`SessioneMessaggi.domandeChiuse: Set<String>`, in memoria). Nasce solo dopo un'apertura riuscita (`esito.aperto`
     in `PannelloMessaggio.apri`, cioè dopo la seconda lettura e l'eventuale conferma del consenso); mai dopo
     «Aggiungi nel dossier» o «Salva nel dossier». Il canale della frase («Mail»/«Messaggi») è quello della copertura,
     non quello scelto adesso nel segmentato. Testo `TestiMessaggi.haiSpedito(canale)` = «Aperto in Mail. L’hai spedito?», pulsanti «Sì, spedito»
     (`.applePrimarioGrande`) e «Non ancora» (`.appleGrande`).
   - stato «spedito»: `PillolaStatoApple` verde con la spunta e `TestiMessaggi.speditoAlle(ora:canale:)` = «Spedito oggi
     alle 10:42 con Mail», poi «È nel dossier di <Nome>.» (`TestiMessaggi.nelDossier(nome)`, primo nome), a destra «Non è
     partito» (`.appleGrande`). In questo stato il pannello **rilegge il testo spedito** (`MessaggioCliente.testo` della
     copertura, come fa oggi `riapri` per un messaggio del dossier): niente nuova scrittura di Qwen, niente «↻
     Riscrivi», segmentati di tono e canale non attivi.
   - I traguardi (`PannelloTraguardo`) non cambiano: nessuna barra a tre stati.
   - Cambio di stato: entrata `Tema.Apple.Messaggi.Moto.cambioBarra` (opacità e y 6, 0,26 s × ritmo; calmo: dissolvenza
     0,15 s; istantanee: ferma).
5. **«Sì, spedito»**: `segnaSpedito`, poi la sessione passa alla prossima occasione da mandare (prima le non
   `.traguardo`, nello stesso ordine dell'elenco), avviso `TestiMessaggi.segnatoSpedito(nome)` = «Segnato come spedito:
   resta nel dossier di <Nome>». **«Non è partito»**: `togliSpedito`; il messaggio resta aperto e coperto, la barra torna
   normale (la domanda resta chiusa per la sessione). **«Non ancora»**: aggiunge l'occasione a `domandeChiuse`.
6. **Vuoti**: con un cliente scelto e niente da mandare, nella colonna «Nessun messaggio da preparare per <Nome>. Quando
   c’è un incontro, una scadenza o un compleanno, lo trovi qui.» (`TestiMessaggi.vuotoPer(nome)`); il pannello resta
   `VuotoMessaggi` con «Niente da scrivere, per ora.» (nuovo `TestiMessaggi.nienteDaScrivere`, solo Mac).
7. **Richieste da altre app per un altro cliente**: in `preparaMessaggio(…)` (CollegamentiMessaggi.swift:37), sul Mac,
   se `!tuttiIClienti && clienteAttivoId != o.clienteId` chiamare `scegliCliente(o.clienteId)` prima di aprire
   Messaggi (come `scegliCli(k,1)` del template, senza avviso).
8. Il dossier del cliente (AppClienti.swift:510, dove oggi compare `m.stato.nome`) mostra «Spedito il …» al posto di
   «Aperto in Mail» per i messaggi con `speditoIl` (una proprietà `MessaggioCliente.nomeStato` che lo dica, usata
   anche in SessioneMessaggi.swift:290). Le bozze delle Campagne (MessaggiCampagne.swift:614) possono mostrare lo
   stesso nome; nessun'altra modifica alle Campagne.

**Non fare**: Prisma non sa se Mail ha spedito e non lo deve indovinare (niente letture di Mail o di Messaggi, niente
AppleScript): il segno lo mette solo il consulente. Non portare i messaggi d'esempio di `MSG`. Non cambiare
`GruppoMessaggio` né l'elenco dell'iPhone.

Token in `DesignSystem/Apple/Tema.Apple+Messaggi.swift`: `Colonna.numeroOcchiello` (carattere 11 bold, fondo
`Colore.chip`, testo `inchiostro2`, padding 1×7, raggio 99, spazio 6 dal titolo), `Voce.spuntaSpedito` (17),
`Voce.coloreSpedito`, `Barra.domanda` (carattere 14,5 bold), `Barra.spazioDomanda` (8), `Moto.cambioBarra`.

### 25.4 Dati, archivio, privacy

- Campo nuovo **`MessaggioCliente.speditoIl: Date?`** (Dati/MessaggioCliente.swift:229), nei `CodingKeys` (riga 282)
  e letto con `decodeIfPresent` (lettura tollerante come `apertoIl`, riga 302). Sta dove stanno già i messaggi: nel file del cliente
  (`ArchivioPezzi`, chiave `.messaggi`, ArchivioPezzi.swift:187 e 246), quindi nei backup. Nessuna versione nuova del
  formato (campo facoltativo), ma va citato nel commento di `DatiPrisma` sulla versione 27.
- «Prisma ovunque»: i messaggi viaggiano nell'istantanea del Mac; il campo in più l'iPhone lo ignora. Nessuna voce nuova
  nel giornale (l'iPhone non segna spediti in questo giro).
- Privacy: nulla esce; il segno è una data. La regola «Prisma non spedisce mai da solo» resta intatta (la domanda la
  rafforza).

### 25.5 Istantanee e prove

- Aggiornare `490-messaggi-apple` (e scura) in `Shell/IstantaneeMessaggi.swift`: i numeri accanto agli occhielli.
- Nuove: `1040-uso-messaggi-cliente` (Giulia scelta: solo i suoi, con un messaggio in «Mandati oggi»),
  `1041-uso-messaggi-hai-spedito` (barra «Aperto in Mail. L’hai spedito?»), `1042-uso-messaggi-spedito` (pillola verde
  e «Non è partito»), `1043-uso-messaggi-vuoto-cliente`; chiare e scure le prime tre. `RichiestaIstantaneaMessaggi`
  (AppMessaggi.swift:53) prende un parametro per lo stato della barra.
- `--prova-calcoli` (`Motori/ProvaCalcoliMessaggi.swift`): un messaggio aperto oggi con `speditoIl` dà
  `OccasioneMessaggio.speditoIl` e la copertura «aperto»; aperto ieri e spedito ieri non ricompare; `togliSpedito`
  lascia l'occasione coperta; con 10 occasioni «oggi» di altri clienti più importanti, `dividi(…, soloCliente:)` dà
  ancora quelle del cliente (il taglio a 8 viene dopo il filtro); senza `soloCliente` il risultato è identico a oggi.
- `--prova-backup` (`Dati/ProvaBackupMessaggi.swift`): `speditoIl` sopravvive al giro backup → ripristino; un archivio
  senza il campo si legge.
- `--prova-fluidita`: «Sì, spedito» non rifà `MotoreOccasioniMessaggi` più di una volta (cambia `versioneCalcoli`, come
  oggi «Apri in Mail»).

### 25.6 Decisioni per l'utente e rischi

- **Testo delle voci aperte ma non confermate.** Il template non mostra niente; oggi l'app dice «✓ Preparato alle…».
  Proposta: «Aperto in Mail alle 10:42», così si capisce che manca la conferma.
- **Un messaggio aperto e mai confermato**: proposta, la domanda ricompare ogni volta che si torna su quell'occasione nel
  giorno; dal giorno dopo l'occasione è coperta come oggi e sparisce (nessun promemoria in più nel «Da fare»).
- **«Salva nel dossier» senza aprire**: non chiede «L'hai spedito?» (non è partito niente). Proposta: così.
- Rischio: `PannelloMessaggio` è condiviso con iPhone e iPad; la barra nuova va tenuta in un ramo solo Mac per non
  cambiare le loro istantanee.
- Rischio: filtrare per cliente l'elenco già tagliato a 8 per gruppo nasconderebbe messaggi veri del cliente (25.2).
  Il parametro `soloCliente` di `dividi` ha `nil` di base: iPhone e prove di oggi restano identici.

### 25.7 Dimensione

M (circa 300 righe). File: Shell/AppMessaggi.swift, Shell/PannelloMessaggio.swift, Shell/StatoMessaggi.swift,
Shell/SessioneMessaggi.swift, Shell/CollegamentiMessaggi.swift, Motori/MotoreOccasioniMessaggi.swift,
Dati/MessaggioCliente.swift, DesignSystem/Apple/Tema.Apple+Messaggi.swift, Shell/IstantaneeMessaggi.swift,
Shell/AppClienti.swift (riga del dossier), le due prove.

---

## 26. Il messaggio senza rumore: «Tono», «Invia con», i dati usati in una riga

### 26.1 Nel template

Regola 26 (righe 2714-2717), codice righe 3887-3895 (i dati di ogni messaggio, `m.dati`) e `compoUso` righe
3908-3916, `montaCompoUso` righe 3927-3929; pannello `MIG4[1]` riga 4084 (indica `#mScelte`).

- La testata del pannello non cambia: avatar 46, «A: <Nome> · indirizzo email del dossier», il titolo 23 bold, la
  pillola «Perché adesso: …» (con `white-space:nowrap`, così non va a capo).
- **La fila dei controlli** (`#mScelte`, riga 3911): l'etichetta **«Tono»** (`.k`) prima del segmentato «Cordiale ·
  Formale · Breve»; 14 punti di spazio; l'etichetta **«Invia con»** prima del segmentato «Mail · Messaggi»; a destra il
  collegamento **«Vera ha usato N dati del dossier ›»** (`.lnk`, solo se il messaggio ha dati). Sparisce a destra la
  sfera con «Vera scrive con i dati del dossier».
- **Sotto il testo non c'è più la fila di etichette** con le cifre, né le righe «Dati di prova…» e «Scritto da Eve con
  qwen…» (regole 9 e 37).
- Il clic su «Vera ha usato N dati del dossier ›» apre una scheda (`apriScheda`, riga 3928): occhiello «Da dove vengono
  le cifre», titolo del messaggio (23 bold), «Vera ha scritto il testo con questi dati del dossier di <Nome>: le cifre le
  dà Prisma.», poi le righe etichetta → valore (`kv`), per esempio «Obiettivo casa · 52% · 550 € al mese».
- Con «Invia con: Messaggi» il testo va nella nuvoletta blu e l'oggetto sparisce, come oggi.

### 26.2 Nell'app oggi

- `Sources/Prisma/Shell/PannelloMessaggio.swift:31` `PannelloMessaggio`:
  - `controlli` (riga 220): `segmentatoTono` e `segmentatoCanale` (righe 212-218, `SegmentatoPillola`) **senza
    etichetta**, a destra `notaVera` (riga 238: `SferaVera` + «Vera scrive con i dati del dossier» / «Vera sta
    scrivendo…» / «Testo di Prisma, con i dati del dossier»).
  - `corpo` (riga 273): l'avviso del testo di Prisma (`pronto?.avviso`, con la sfera ferma), la riga
    `TestiMessaggi.datiDiProva` sui clienti di prova (riga 286), il testo, poi `cifre` (riga 301: le etichette in
    capsula `DisposizioneAcapoRicerca`, troncate a `Cifre.larghezzaMassima`) e `nota` (riga 328: «Le cifre vengono da
    Prisma · Scritto da Vera con qwen3.5:4b», `TestiMessaggi.autore`, SessioneMessaggi.swift:273).
- Le cifre stanno in `OccasioneMessaggio.cifre: [CifraMessaggio]` (etichetta, valore; Dati/MessaggioCliente.swift:128):
  sono già le sole che il testo può citare (verifica delle cifre di `MessaggiVera`).
- `TonoMessaggio.nome` e `CanaleMessaggio.nome` danno «Cordiale/Formale/Breve» e «Mail/Messaggi».

### 26.3 Cosa fare

1. In `controlli` (solo Mac, non `compatto`): `HStack` con `Text(TestiMessaggi.tono)` = «Tono» + `segmentatoTono`,
   spazio `Pannello.fraGruppiControlli` (14), `Text(TestiMessaggi.inviaCon)` = «Invia con» + `segmentatoCanale`, `Spacer`,
   poi `PulsanteDatiUsati` (nuovo, privato al file) con `TestiMessaggi.datiUsati(n)` = «Vera ha usato 1 dato del
   dossier ›» / «Vera ha usato 5 dati del dossier ›» (il template scrive sempre «dati»: il singolare è una correzione)
   con `.buttonStyle(StileCollegamento())` (DesignSystem/Componenti.swift:449, il testo blu del tema; non esiste uno
   stile `.appleCollegamento`). Nessun pulsante se `occasione.cifre` è vuoto.
   Gli accessibilityLabel dei segmentati diventano «Tono» e «Invia con».
2. Togliere dal Mac `notaVera` nella fila: lo stato «Vera sta scrivendo» resta visibile perché il testo arriva a
   puntini e parola per parola; il testo di Prisma resta riconoscibile dall'avviso (`pronto?.avviso`) che **resta**.
3. Togliere dal Mac `cifre` e `nota` sotto il testo (restano su iPhone e iPad). La riga «Dati di prova…» la toglie la
   miglioria 37 (Dimostrazione: un'etichetta sola nella barra); se la 37 non è ancora fatta, toglierla qui solo quando
   la barra mostra già che si è in dimostrazione — altrimenti lasciarla (vedi 26.6).
4. **La scheda «Da dove vengono le cifre»**: `FoglioDatiMessaggio` (Shell/, nuovo, piccolo) presentato con
   `.sheet(item:)` come la seconda lettura nello stesso pannello (PannelloMessaggio.swift:125; `FoglioSecondaLettura`
   in Shell/VisteFaseTreVera.swift:164, stesso aspetto; non esiste un `PresentatoreDettaglio`): occhiello `TestiMessaggi.daDoveCifre` = «Da dove vengono le cifre», titolo =
   `occasione.titolo`, frase `TestiMessaggi.cifreDelDossier(nome)` = «Vera ha scritto il testo con questi dati del
   dossier di <Nome>: le cifre le dà Prisma.», poi una riga per `CifraMessaggio` (etichetta a sinistra, valore a destra
   in tabellari, filo fra le righe: una riga privata al file con i token di `FoglioDati`; non esiste un componente
   chiave/valore del tema Apple, e `RigaDato` di DettaglioPosizione.swift:812 usa misure fisse del tema vecchio). In fondo, solo testo: chi ha scritto il testo («Scritto da Vera» o «Testo di Prisma»), senza
   il nome del modello (regola 9). Esc o «Chiudi» chiude.
5. Testi nuovi in `TestiMessaggi` (SessioneMessaggi.swift:230): `tono`, `inviaCon`, `datiUsati(_:)`, `daDoveCifre`,
   `cifreDelDossier(_:)`, `scrittoDa(_:)` (senza modello).

**Non fare**: non chiamare «Canale» il segmentato Mail/Messaggi (in Prisma «canale» è Alleanza o indipendente). Non
portare i dati d'esempio delle righe 3891-3895: la scheda mostra le `cifre` vere dell'occasione.

Token in `Tema.Apple+Messaggi.swift`, `enum Pannello`: `etichettaControllo` (carattere `.k` 13, `inchiostro2`),
`spazioEtichetta` (8), `fraGruppiControlli` (14), `datiUsati` (carattere 13 semibold, `accento`); nuovo `enum
FoglioDati` (larghezza 440, padding 22×24, occhiello, titolo 23 bold tracking −0,4, frase 13,5 `inchiostro2`, riga
chiave/valore 14 con filo `separatore`).

### 26.4 Dati, archivio, privacy

Nessun campo nuovo. Le cifre mostrate sono quelle che l'occasione ha già. Privacy invariata (la scheda resta sul Mac).
Regola 9: il nome del modello sparisce da Messaggi; resta in Impostazioni › Vera.

### 26.5 Istantanee e prove

- Aggiornare tutte le scene `490`-`495` di Messaggi (chiare e scure): la fila con «Tono» e «Invia con», niente
  etichette delle cifre né riga dell'autore. `494-messaggi-vera-non-pronta` deve mostrare ancora l'avviso del testo di
  Prisma.
- Nuova `1044-uso-messaggi-dati-usati` (la scheda aperta) e la scura.
- `--prova-vera` (`Vera/ProvaMessaggiVera.swift`): nessun cambiamento ai testi; controllare solo che `TestiMessaggi.autore`
  resti usato dove serve (iPhone) o che la prova usi il testo nuovo.

### 26.6 Decisioni per l'utente e rischi

- **«Dati di prova…» prima della miglioria 37**: proposta, toglierla insieme alla 37 (stesso giro o subito dopo), per
  non perdere l'avviso che i testi sono dei modelli.
- **Messaggi con zero cifre** (un augurio senza numeri): niente collegamento. Proposta: così, senza scrivere «Vera non ha
  usato dati».
- Rischio: la fila dei controlli più lunga nelle finestre strette. Usare `ViewThatFits`: se non sta, le etichette
  restano e il collegamento va a capo sotto la fila (non diventa un'icona senza nome).

### 26.7 Dimensione

S (circa 140 righe). File: Shell/PannelloMessaggio.swift, Shell/SessioneMessaggi.swift (testi), nuovo
Shell/FoglioDatiMessaggio.swift, DesignSystem/Apple/Tema.Apple+Messaggi.swift, Shell/IstantaneeMessaggi.swift.

---

## 27. Vera dice cosa sa fare

### 27.1 Nel template

Regola 27 (righe 2718-2723), codice righe 3937-3948 (`veraUsaHTML`, `veraInizio`, `chiediRuby` rifatta), base righe
1246-1257 e `veraDiChi`/`veraDomande` righe 3117-3121; CSS `.vGr`/`.vCard` righe 624-626; pannello `MIG4[2]` riga 4085
(si apre con Marco scelto e la conversazione vuota).

- **La colonna dice tre cose** (riga 1248-1251):
  1. la sfera, «Ciao, sono Vera.», «Mettiamo in ordine le idee.»; la scheda dello stato con il pallino verde **«Vera ·
     pronta»** e «I numeri li calcola Prisma, io li racconto.»;
  2. **«Parliamo di»** (`veraDiChi`): avatar 26 e nome del cliente della barra, oppure il glifo persone e «Tutti i
     clienti» (niente tendina, niente segmentato);
  3. **«Per rispondere uso»** (`veraUsaHTML`, riga 3942): tre righe con la spunta verde: «Il dossier di <Nome>» (o «I
     dossier dei tuoi clienti» senza cliente), «I calcoli di Prisma», «La tua agenda»; sotto «Non invento cifre: se un
     dato manca, te lo dico.».
- **Escono dalla colonna** «Oggi» (gli impegni), «Da non dimenticare» e «Il quadro di…» (regola 27: stanno in Agenda,
  nel «Da fare» e nel dossier).
- **A conversazione vuota** (solo il saluto di Vera, `conv.length<=1`; `veraInizio` riga 3943): la fila dei
  suggerimenti sopra il campo sparisce e sotto il saluto compare **«Puoi chiedermi, per esempio»** con una griglia di
  riquadri `.vGr` (2 colonne, spazio 12, larghezza massima 660). Ogni riquadro `.vCard` (padding 16×18, si inclina verso
  il puntatore di 4°) ha: il tipo in occhiello blu (11), la domanda (15 bold), lo scopo (`.k`). Tipi (riga 3944):
  - «La giornata» — «Impegni e cose urgenti, in ordine» (per «Cosa ho oggi?»);
  - «Il cliente in breve» — «Chi è, cosa ha, cosa manca» (per «Riepilogo di …»);
  - «Una spiegazione» — «Con le sue cifre, in parole semplici» (per «Spiegami la previdenza di …»);
  - «Uno scenario» — «Cosa cambia, con i calcoli di Prisma» (per «E se Marco va in pensione a 63 anni?»).
  Le domande parlano del cliente scelto (`veraDomande`, riga 3117). I riquadri entrano a cascata (y 16→0, 480 ms,
  ritardo 260 + 70 per riquadro); un clic fa la domanda.
- **Dopo la prima domanda** i riquadri spariscono e tornano i suggerimenti in fila sopra il campo (riga 3947). «Nuova
  conversazione» riporta i riquadri.
- Il selettore «Lavoro | Conversazione» nella testata resta com'è.
- Il saluto del template non cambia rispetto a «Luce» («Buonasera Denis. Oggi hai tre appuntamenti con i clienti: ho già
  preparato le tracce. Da dove partiamo?»; dopo «Nuova conversazione» «Ricominciamo. Di cosa hai bisogno?», righe
  1254-1256): i riquadri compaiono sotto il saluto in entrambi i casi (`conv.length<=1`). Il template non tocca il saluto
  e non ha una versione per la modalità Conversazione.

### 27.2 Nell'app oggi

- `Sources/Prisma/Shell/AppVera.swift:130` `ColonnaAppVera`, nell'ordine (righe 143-161): `SferaColonnaVera`, «Ciao,
  sono Vera.», «Mettiamo in ordine le idee.», poi
  - `schedaMotore` (riga 175): «qwen3.5:4b · pronto» (il **nome del modello**, `q.nome`), «I numeri li calcola Prisma,
    io li racconto.» o il motivo, «Verifica» se non è pronto, e la riga **«Smista: regole e Qwen · Apple spento»** con
    il pulsante «Motori» (fase 5);
  - `schedaOggi` (riga 224): «Oggi» con gli impegni (`appuntamentiDiOggi`);
  - `schedaAmbito` (riga 273): «Parliamo di» con il segmentato «Cliente | Portafoglio» (`veraPortafoglio`) e la tendina
    `MenuTendina` dei clienti;
  - `SchedaTagliandoColonnaVera` (Shell/VisteTagliandoVera.swift:502): anello della salute dell'archivio e le cose da
    sistemare, apre la pagina del tagliando;
  - `ArchiviatiOggiVeraVista` (Shell/VisteLasciaCadereVera.swift:119): i documenti archiviati da Vera oggi, solo se ce
    ne sono;
  - `schedaAvviso` (riga 308): «Da non dimenticare» con l'attività più urgente;
  - `quadro` (riga 339): «Il quadro di <Nome>» con quattro tessere (posizioni, proposte, attività aperte, simulazioni).
- Chat (riga 394): a conversazione vuota solo la bolla `benvenuto` (riga 496, `fraseBenvenuto` riga 514: «Buonasera
  Denis. Oggi hai 3 appuntamenti con i clienti. Sono sul dossier di Giulia Rossi: da dove partiamo?»); i
  `suggerimenti` (riga 531) sono **sempre** una fila orizzontale di pillole sopra il campo: `SpuntoVera.allCases` (16
  domande generiche, Vera/ModelliVera.swift:151) o `SpuntoPortafoglio.allCases` (8, Vera/PortafoglioVera.swift:6).
- La testata: `AzioniVera` (riga 728) con «Lavoro / Conversazione» e «Nuova conversazione».
- Il gruppo 01 già prevede (miglioria 2) che il segmentato «Cliente | Portafoglio» e la tendina spariscano e che
  `veraPortafoglio` diventi la lettura di `tuttiIClienti`; (miglioria 9) «Vera · pronta» al posto del nome del modello.

### 27.3 Cosa fare

1. **La scheda dello stato** (`schedaMotore`): «Vera · pronta» / «Vera · non pronta» (dalla miglioria 9), la frase di
   oggi, «Verifica» se non è pronta. La riga «Smista: regole e Qwen · Apple spento» con «Motori» (AppVera.swift:204-209)
   esce dalla colonna e basta: Impostazioni › Vera ha **già** il gruppo «Motori e su misura» con «Due velocità» › Apri
   (`apriPaginaMotori(.dueVelocita)`) e «Motore esterno» › Apri (ImpostazioniPagine.swift:454-470). Nessuna riga nuova.
2. **«Parliamo di»** (`schedaAmbito`): avatar 26 (`AvatarCliente`) e nome del cliente attivo, oppure glifo
   `person.2` e «Tutti i clienti». Nessun controllo: si cambia dalla pillola della barra (miglioria 2). In modalità
   cliente uguale (il nome del cliente mostrato).
3. **«Per rispondere uso»** (nuova `schedaFonti`, privata al file): occhiello `TestiVera.perRispondereUso`, tre righe con
   `checkmark` verde: `TestiVera.fonteDossier(nome)` = «Il dossier di <Nome>» oppure «I dossier dei tuoi clienti»
   (con «Tutti i clienti»), «I calcoli di Prisma», «La tua agenda»; nota «Non invento cifre: se un dato manca, te lo
   dico.». In modalità **Conversazione** le righe cambiano (vedi 27.6). Le righe dicono solo ciò che Vera legge
   davvero: «La tua agenda» compare solo se il contesto di Vera la include (`ContestoVera`/`PortafoglioVera`: verificare
   dove si costruisce il contesto e ricavare le righe da lì, non scriverle fisse).
4. **Via dalla colonna** `schedaOggi`, `schedaAvviso` (con `urgente`) e `quadro`, e le loro costanti in
   `Tema.Apple.Vera.Colonna` che non usa più nessuno. `ArchiviatiOggiVeraVista` resta (compare solo quando Vera ha
   archiviato qualcosa oggi: è il riscontro di «Lascia cadere qui»). Per `SchedaTagliandoColonnaVera` vedi 27.6.
5. **Gli esempi a conversazione vuota** (`messaggiVista`, riga 418): quando `elenco.isEmpty && !stato.veraInCorso`, dopo
   la bolla `benvenuto` una vista nuova `EsempiVera` (nuovo file Shell/EsempiVera.swift):
   - occhiello `TestiVera.puoiChiedermi` = «Puoi chiedermi, per esempio»;
   - `LazyVGrid` a due colonne (spazio 12, larghezza massima 660) di `RiquadroEsempioVera`: tipo (occhiello `accento`
     11), domanda (15 bold, `fixedSize` in verticale), scopo (`.k`); superficie `cardPiena` del tema, inclinazione con
     il modificatore delle schede del tema (`inclinazioneApple(massimo: 4)` o quello che usa la scrivania), cascata
     con `entrataCascata` (base 0,26 × ritmo, passo 0,07; calmo: dissolvenza; istantanee: fermo).
   - Un clic chiama `stato.chiediVera(domanda, spunto:)` o `stato.chiediVeraPortafoglio(…)` come i suggerimenti di oggi.
   - **Le domande** vengono da un motore piccolo e puro `EsempiVera.per(cliente:portafoglio:)` (in `Vera/ModelliVera.swift`,
     accanto a `SpuntoVera`), che sceglie **fino a quattro** spunti già esistenti e dà loro tipo e scopo (anche il template ne mostra da due a
     quattro secondo il cliente, `veraDomande` riga 3117):
     «La giornata» → «Cosa ho oggi?», la domanda libera che la Mini Vera usa già (Vera/MiniVera.swift:239), solo se
     la Vera grande la instrada allo stesso modo senza cambiare conversazione (da verificare con `--prova-vera`);
     **non** `SpuntoPortafoglio.settimana` con un cliente scelto: è uno spunto del portafoglio, va con
     `chiediVeraPortafoglio` e porterebbe la domanda nella conversazione di tutti i clienti; «Il cliente in breve» → `SpuntoVera.riepilogo`; «Una spiegazione» →
     `SpuntoVera.pensione` (o `.protezione`/`.scadenze` secondo ciò che il cliente ha, dalle voci per cliente di
     `CacheClienti`); «Uno scenario» → `SpuntoVera.resistenza` o `.cambiare`. Con il nome del cliente nella domanda
     solo se il catalogo di Vera sa già riconoscere la domanda scritta così (le domande degli spunti oggi sono generiche:
     «Fammi un riepilogo del cliente»); altrimenti la domanda resta quella dello spunto. Con «Tutti i clienti»: quattro
     `SpuntoPortafoglio` (settimana, ricontattare, scadenze, quadro) con i loro tipi.
   - Testi dei tipi e degli scopi in `TestiVera.tipoEsempio` (le quattro coppie del template, esatte).
6. **I suggerimenti in fila** (`suggerimenti`, riga 531): nascosti finché la conversazione è vuota (`elenco.isEmpty`),
   tornano dopo la prima domanda come oggi. «Nuova conversazione» svuota l'elenco e i riquadri tornano da soli.
7. La frase del benvenuto (`fraseBenvenuto`) resta. Facoltativo, non nel template (vedi 27.6): la parte «Sono sul
   dossier di…» si accorcia in «Parliamo di <Nome>: da dove partiamo?» per non ripetere la colonna.

**Non fare**: non portare le domande d'esempio scritte nel template su Giulia e Marco; non aggiungere un catalogo di
domande nuovo che Vera non sappia instradare (ogni riquadro deve finire su uno spunto che Vera riconosce oggi).

Token in `DesignSystem/Apple/Tema.Apple+Vera.swift`: `Colonna.spuntaFonte` (14, `Colore.verde`), `Colonna.rigaFonte`
(13,5, padding verticale 3, spazio 8), `Colonna.avatarAmbito` (26); nuovo `enum Esempi` (occhiello sopra 22 sotto 10,
colonne 2, spazio 12, larghezza massima 660, padding 16×18, spazio interno 5, tipo 11 `accento`, domanda 15 bold
interlinea 1,3, scopo `.k`, inclinazione 4, cascata base 0,26 passo 0,07).

### 27.4 Dati, archivio, privacy

Nessun campo nuovo. Le fonti mostrate dicono la verità sul contesto di Vera (che resta locale). In modalità
Conversazione i dati dei clienti non entrano (regola di `conversazione.md`): la colonna lo deve dire, non affermare il
contrario.

### 27.5 Istantanee e prove

- Aggiornare `480-vera-apple` e `480-vera-apple-scuro` (Shell/IstantaneeVeraApple.swift): colonna con le tre schede,
  conversazione vuota con i riquadri. Aggiornare `481`-`487` (conversazioni piene: niente riquadri, suggerimenti in
  fila, colonna nuova), `483-vera-qwen-non-pronto` («Vera · non pronta» e «Verifica»), `19-vera`, `46-vera-pensione`,
  `47-vera-checkup` (Istantanee.swift).
- Nuove: `1045-uso-vera-tutti-i-clienti` (colonna con «Tutti i clienti», riquadri del portafoglio),
  `1046-uso-vera-conversazione` (modalità Conversazione, fonti diverse).
- `--prova-vera`: ogni riquadro di `EsempiVera.per(…)` porta a uno spunto riconosciuto (`SpuntoVera` /
  `SpuntoPortafoglio.da(_:)` restituisce lo stesso spunto della domanda); da uno a quattro esempi, mai due dello stesso
  tipo; con un cliente scelto nessun esempio va nella conversazione del portafoglio.
- `--prova-fluidita`: la colonna non legge più `attivitaAperte` né `posizioniCliente` (meno lavoro nel body).

### 27.6 Decisioni per l'utente e rischi

- **Il tagliando dei dati nella colonna**: il template non lo disegna. Proposta: toglierlo dalla colonna e farne una
  riga di Impostazioni › Da sistemare (miglioria 31: «Il tagliando dei dati ha trovato N cose da guardare» → apre la
  pagina del tagliando), così le cose da sistemare stanno in un posto solo. Togliendolo dalla colonna non si perde
  niente: Impostazioni › Vera ha già il gruppo del tagliando (`GruppoTagliandoImpostazioni`, ImpostazioniPagine.swift:479,
  con «Controlla adesso»). In alternativa resta in colonna sotto «Per rispondere uso».
- **«Smista: regole e Qwen · Apple spento» e «Motori»**: non serve una decisione: escono dalla colonna (regola 9) e le
  stesse pagine si aprono già da Impostazioni › Vera › «Motori e su misura».
- **Fonti in modalità Conversazione** (quella mostrata, `stato.modalitaVeraMostrata`: finché non scegli Vera decide
  dalla domanda, AppVera.swift:727): proposta, «Per rispondere uso» diventa «In questa conversazione» con «Le tue
  domande» e la nota «Qui non uso i dati dei clienti.»; «Parliamo di» si nasconde.
- **Il saluto «Sono sul dossier di…»** (27.3 punto 7): il template non lo cambia; accorciarlo è facoltativo. Proposta:
  lasciarlo com'è in questo giro.
- **Domande con il nome del cliente**: il template le scrive con il nome («Spiegami la previdenza di Marco»). Proposta:
  usare il nome solo dove l'instradamento di Vera già riconosce la frase; altrimenti la domanda dello spunto.
- Rischio: le card tolte (Oggi, Da non dimenticare, il quadro) erano anche scorciatoie verso Agenda, Attività e
  Posizioni; con la miglioria 3 il «Da fare» e la barra le sostituiscono. Se la 3 non c'è ancora, aspettare a toglierle.

### 27.7 Dimensione

M (circa 350 righe). File: Shell/AppVera.swift, nuovo Shell/EsempiVera.swift, Vera/ModelliVera.swift (o un file nuovo
Vera/EsempiVera.swift per il motore), Shell/VisteTagliandoVera.swift (se il tagliando esce dalla colonna),
DesignSystem/Apple/Tema.Apple+Vera.swift, Shell/IstantaneeVeraApple.swift, Istantanee.swift (19, 46, 47).

---

## 28. Le parcelle dicono a che punto sono

### 28.1 Nel template

Regola 28 (righe 2724-2728), codice righe 3950-3992 (`parcelleUsoHTML`, `parcAzioniHTML`, `montaParcAzioni`,
`montaParcelleUso`, `studioHTML`/`montaStudio` rifatti), CSS `.passiF` righe 627-632; pannello `MIG4[3]` riga 4086.

- **La colonna** (larga 440): le due tessere di sempre («Incassato nel 2026», «Da incassare» in arancio, numeri che si
  contano); sotto, **un segmentato a tutta larghezza per filtrare** (riga 3964): «Tutte N», «Da incassare N», «Bozze
  N», «Pagate N» (con i numeri veri); poi l'elenco filtrato (avatar 34, nome, «numero · consulenza», a destra importo e
  pillola di stato: Bozza neutra, Da incassare arancio, Pagata verde). Filtro vuoto: «Nessuna parcella con questo
  stato.». **Il pulsante blu «Nuova parcella» in fondo alla colonna sparisce.**
- **«＋ Nuova parcella»** sta nella riga in testa alla finestra (riga 3992), dopo il segmentato delle schede, solo nella
  scheda Parcelle.
- **A destra della fattura** (`#fAz`, larga 236, in alto a destra): una scheda **«A che punto è»** con tre passi in fila
  (`.passiF`): «Bozza», «Emessa», «Pagata». Ogni passo è un cerchio 22 con bordo 2: fatto = bordo verde e spunta verde,
  attuale = pieno blu con il numero bianco, futuro = bordo `track` con il numero; un filo 2 `track` li unisce. Sotto una
  riga che dice cosa manca:
  - Bozza: «È una bozza: puoi ancora cambiarla.»
  - Emessa: «Emessa il 2 nov 2026, oggi|ieri|N giorni fa: <Nome> non l’ha ancora pagata.» + « I 30 giorni sono
    passati.» quando serve
  - Pagata: «Pagata: è nel totale incassato.»
- **Un solo pulsante blu, il prossimo passo** (riga 3972), gli altri bianchi sotto, tutti a tutta larghezza:
  - Bozza → **«Emetti la parcella»**, «Modifica»;
  - Emessa senza file XML → **«Prepara il file XML»**, «Manda con Messaggi», «Segna come pagata», «Salva PDF»;
  - Emessa con il file → **«Segna come pagata»**, «Manda con Messaggi» (oltre i 30 giorni **«Manda un sollecito»**),
    «Prepara di nuovo il file XML», «Salva PDF»;
  - Pagata → nessun pulsante blu: «Salva PDF», «Prepara di nuovo il file XML».
  Sotto, per Emessa senza file: «Il file XML della fattura elettronica lo carichi tu sul portale dell’Agenzia delle
  Entrate, o lo dai al commercialista.». File pronto: tessera con bordo verde «✓ File XML pronto» e il nome del file.
- Dopo «Emetti la parcella» l'avviso «Parcella emessa: ora prepara il file XML»; dopo «Segna come pagata» «Segnata come
  pagata: <importo> nel totale incassato»; il filtro torna a «Tutte».
- «Manda un sollecito» prepara in Messaggi «Un promemoria per la parcella n. …» («Emessa da N giorni»), con i dati
  «Parcella, Del, Importo, Consulenza».

### 28.2 Nell'app oggi

- `Sources/Prisma/Shell/StudioParcelle.swift:169` `ParcelleStudioVista`: elenco ordinato in cache
  (`studio.parcelle.elenco`, riga 200), totali (`studio.parcelle.totali`), barra laterale `barra` (riga 264) con le due
  `TileTotaleParcelle`, l'elenco `VoceParcellaApple` (riga 727) **senza filtro**, e in fondo **«＋ Nuova parcella»** in
  `.applePrimarioGrande` (righe 305-313).
- `azioni` (riga 387): **sempre** «Prepara il file XML» blu in cima (spento se mancano dati), «Salva PDF», poi per stato:
  bozza «Emetti» (conferma con l'avviso «Emettere la parcella?», riga 246) e «Modifica la bozza»; emessa «Segna
  pagata»; poi sempre «Manda con Messaggi» (spento sulle bozze), «Pagata il …», la nota `TestiParcelle.notaXML` e
  `statoFile` (tessera «file pronto» o le tessere arancio di ciò che manca, con i rimandi a Impostazioni › Studio e al
  dossier). **Due pulsanti blu sulla stessa schermata** («Prepara il file XML» e «Nuova parcella»); **nessuna fila dei
  passi**.
- Gli stati sono quattro: `StatoParcella` bozza, emessa («Da incassare»), pagata, **annullata** (Dati/Parcella.swift:34).
- Il file XML preparato resta scritto nella parcella: `preparaFatturaPA` (StatoParcelle.swift:141) aggiunge un
  `DocumentoParcella(formato: .xml, …)` a `Parcella.documenti`. La scadenza è un dato della parcella
  (`Parcella.scadenza`), e «scaduta» la decide `MotoreParcelle.scaduta` (MotoreParcelle.swift:51), non «30 giorni».
- «Manda con Messaggi» usa `stato.occasioneParcella(p)` (CollegamentiMessaggi.swift:93), che dà già l'occasione «da
  mandare» o «da saldare» con le cifre della parcella.
- La riga in testa di Studio: `AzioniStudio` (StudioApp.swift:191) con «▶︎ Il tuo anno» e il segmentato delle schede.
- Il modulo «Nuova parcella» (`ModuloParcella`, Shell/ModuloParcella.swift) si apre da `apriNuova()` (riga 536), con
  `@State modulo` dentro la vista.

### 28.3 Cosa fare

1. **Il prossimo passo** come funzione pura in `Motori/MotoreParcelle.swift`:
   `static func passo(_ p: Parcella, oggi: Date) -> PassoParcella` con `enum PassoParcella { case emetti, preparaXML,
   segnaPagata, nessuno }` e `static func indicePasso(_ p:) -> Int` (bozza 0, emessa 1, pagata 2; annullata a parte).
   Regola: bozza → `.emetti`; emessa senza `documenti` `.xml` → `.preparaXML`; emessa con il file → `.segnaPagata`;
   pagata e annullata → `.nessuno`.
2. **La scheda «A che punto è»** in cima ad `azioni`: componente `PassiParcellaApple` (nuovo, in
   DesignSystem/Apple/PassiApple.swift, generico: `passi: [String]`, `attuale: Int`), occhiello «A che punto è», sotto
   la frase `TestiParcelle.aChePunto(p, cliente:, oggi:)`:
   - bozza: «È una bozza: puoi ancora cambiarla.»;
   - emessa: «Emessa il 2 nov 2026, oggi|ieri|N giorni fa: <Nome> non l’ha ancora pagata.» e, se
     `MotoreParcelle.scaduta(p, oggi:)`, « La scadenza è passata.» (al posto dei «30 giorni» del template, vedi 28.6);
   - pagata: «Pagata il <data>: è nel totale incassato.» (unisce il «Pagata il …» di oggi);
   - annullata: niente passi, la frase «Annullata il <data>: non conta più nei totali.».
   Nomi dei passi: «Bozza», «Emessa», «Pagata» (nella colonna lo stato resta «Da incassare», come oggi).
3. **I pulsanti**, uno solo blu (`.applePrimarioGrande`), gli altri `.appleGrande`, tutti a tutta larghezza:
   - `.emetti`: «Emetti la parcella» (apre la conferma di oggi «Emettere la parcella?» e resta spento come oggi in sola
     lettura o se alla bozza manca altro oltre al numero, StudioParcelle.swift:408), «Modifica la bozza». Oggi la bozza
     ha anche «Salva PDF» (e «Prepara il file XML» blu): il template non li mostra sulla bozza (vedi 28.6);
   - `.preparaXML`: «Prepara il file XML» (se mancano dati il blu diventa **«Completa i dati»**, che porta a
     Impostazioni › Studio o al dossier come le tessere arancio di oggi), «Manda con Messaggi», «Segna come pagata»,
     «Salva PDF»;
   - `.segnaPagata`: «Segna come pagata», «Manda con Messaggi» oppure **«Manda un sollecito»** se scaduta, «Prepara di
     nuovo il file XML», «Salva PDF»;
   - `.nessuno` (pagata): «Salva PDF», «Prepara di nuovo il file XML»; annullata: «Salva PDF», «Duplica come bozza».
   «Segna pagata» diventa «Segna come pagata» anche nel menu contestuale (riga 328). Le tessere di `statoFile` (file
   pronto, dati mancanti) e la nota `notaXML` (solo con `.preparaXML`) restano sotto i pulsanti.
4. **«Manda un sollecito»**: lo stesso `mandaConMessaggi` di oggi; l'occasione «da saldare» di `occasioneParcella` ha già
   il testo del promemoria (MotoreOccasioniMessaggi.swift:373-377: titolo «La parcella n. … da saldare», perché
   «Scaduta il …»). Il titolo del template («Un promemoria per la parcella n. …», «Emessa da N giorni») è
   dimostrativo: non si cambia il motore, che serve anche l'iPhone. Senza `Parcella.scadenza` la parcella non è mai
   scaduta: niente sollecito, resta «Manda con Messaggi».
5. **Il filtro**: `enum FiltroParcelle: CaseIterable { case tutte, daIncassare, bozze, pagate }` (StudioParcelle.swift),
   `@State filtro` nella vista (in memoria), `SegmentatoPillola(larghezzaPiena: true)` sotto le tessere con le etichette
   `TestiParcelle.filtro(_:numero:)` = «Tutte 6», «Da incassare 2», «Bozze 1», «Pagate 3». I conteggi dall'elenco in
   cache (poche voci: nel body va bene). Elenco filtrato vuoto: `TestiParcelle.nessunaConStato` = «Nessuna parcella con
   questo stato.». Dopo «Emetti» e «Segna come pagata» il filtro torna a «Tutte» e la scelta resta sulla parcella.
6. **«＋ Nuova parcella» nella riga in testa**: in `AzioniStudio` (StudioApp.swift:191), solo quando `schedaStudio ==
   .fatture` e non in modalità cliente, un pulsante `.applePrimario` con `TestiParcelle.nuova`. Serve un modo per aprire
   il modulo da fuori della vista: `stato.richiestaNuovaParcella: Int` (contatore in memoria, `@Observable` in
   `StatoShell` o in un piccolo stato di Studio) osservato da `ParcelleStudioVista` con `onChange` → `apriNuova()`.
   Togliere il pulsante in fondo alla colonna (righe 305-313) sul Mac.
7. Testi nuovi in `TestiParcelle` (StudioParcelle.swift:60): `aChePunto`, `passi`, `emetti` («Emetti la parcella»),
   `segnaPagata` («Segna come pagata»), `preparaDiNuovo` («Prepara di nuovo il file XML»), `sollecito` («Manda un
   sollecito»), `completaDati` («Completa i dati»), `filtro`, `nessunaConStato`, gli avvisi «Parcella emessa: ora
   prepara il file XML» e «Segnata come pagata: <importo> nel totale incassato».

**Non fare**: non portare la barra «Preparo il file…» con il `setTimeout` (righe 3984-3985): il file si prepara come
oggi, con il pannello di salvataggio. Non portare `incF=21300` né le parcelle di `FATT`. Niente invio allo SdI: Prisma
prepara solo il file (come oggi). Non togliere la conferma prima di emettere (il numero si consuma).

Token in `DesignSystem/Apple/Tema.Apple+Parcelle.swift`: nuovo `enum Passi` (cerchio 22, bordo 2, filo 2 `track`,
numero 11 bold, spunta 11, nome 12 semibold, spazio cerchio-nome 5, sopra 12; colori: attuale `accento` pieno con testo
bianco, fatto bordo e spunta `verde` con nome `inchiostro2`, futuro bordo `track` e nome `inchiostro3`), `Azioni.larghezza`
(236), `Filtro.sotto` (10). Il componente `PassiApple` in DesignSystem/Apple/ con i suoi token in
`Tema.Apple+Passi.swift` se lo si vuole riusare (le pratiche dopo la firma, miglioria 33, hanno passi simili).

### 28.4 Dati, archivio, privacy

Nessun campo nuovo: il file XML preparato si legge da `Parcella.documenti`, la scadenza da `Parcella.scadenza`, il
filtro e la richiesta del modulo restano in memoria. Privacy invariata.

### 28.5 Istantanee e prove

- Aggiornare `510-studio-parcelle` (e scura), `511-studio-parcelle-vuoto`, `512-studio-parcelle-xml-pronto`,
  `513-studio-parcelle-dati-mancanti` (il blu «Completa i dati»), `514-studio-nuova-parcella` (il pulsante nella riga in
  testa) in `Shell/IstantaneeParcelle.swift`.
- Nuove: `1047-uso-parcelle-bozza`, `1048-uso-parcelle-scaduta` (emessa con il file, «Manda un sollecito»),
  `1049-uso-parcelle-filtro` (filtro «Bozze»), `1050-uso-parcelle-pagata`; la prima anche scura.
  `RichiestaIstantaneaParcelle` (riga 31) prende anche il filtro.
- `--prova-calcoli` (`Motori/ProvaCalcoliParcelle.swift`): `MotoreParcelle.passo` per i quattro stati, con e senza
  file XML, scaduta e no.
- `--prova-fluidita`: cambiare filtro non rifà `studio.parcelle.elenco` né i totali.

### 28.6 Decisioni per l'utente e rischi

- **«I 30 giorni sono passati»**: il template conta 30 giorni dall'emissione; l'app ha già la scadenza della parcella
  (`Parcella.scadenza`, `MotoreParcelle.scaduta`). Proposta: usare la scadenza («La scadenza è passata.») e lo stesso
  criterio per «Manda un sollecito».
- **Le annullate**: il template non le ha. Proposta: contano in «Tutte» con la loro pillola, niente passi, la frase
  «Annullata il …», nessun pulsante blu.
- **«Salva PDF» sulla bozza**: oggi c'è, il template lo toglie (la bozza ha solo «Emetti la parcella» e «Modifica»).
  Proposta: come il template (il PDF da consegnare è quello della parcella emessa); in alternativa «Salva PDF» resta
  come ultimo pulsante bianco anche sulla bozza.
- **«Completa i dati» come pulsante blu** quando mancano dati per il file: il template non lo prevede (lì i dati ci sono
  sempre). Proposta: così, invece di un blu spento.
- Coordinamento con la **52** (gruppo 09): stesso `AzioniStudio`; fare la 52 dopo o insieme, per non rifare due volte
  la riga in testa.

### 28.7 Dimensione

M (circa 350 righe). File: Shell/StudioParcelle.swift, Shell/StudioApp.swift, Motori/MotoreParcelle.swift, nuovo
DesignSystem/Apple/PassiApple.swift, DesignSystem/Apple/Tema.Apple+Parcelle.swift, Shell/IstantaneeParcelle.swift,
Motori/ProvaCalcoliParcelle.swift.

---

## 29. Mercato segue il cliente, e ogni avviso ha la sua azione

### 29.1 Nel template

Regola 29 (righe 2729-2734), codice righe 3994-4027 (`EVM`, `AVM`, `avZitti`, `msgMercato`, `mercatoUsoHTML`, `A.act`,
`A.render`, `A.mount`), base righe 1498-1510; CSS `.mkA.zitto` riga 633; pannello `MIG4[4]` riga 4087 (Marco scelto).

- **La riga in testa** (riga 4019): prima di tutto un'etichetta `.chipC` con il lucchetto **«Escono solo dati
  pubblici»**, poi il campo «Cerca un ISIN» e gli altri pulsanti di sempre. Un clic apre una scheda «Riservatezza» /
  «Escono solo dati pubblici» / «Per aggiornare il mercato, dal Mac escono solo gli ISIN e le richieste di dati pubblici
  (BCE, Eurostat). **Nessun dato dei clienti lascia Prisma.**» (riga 4022; vedi 29.6: nell'app gli ISIN **non** escono).
- **La fascia verde** in cima alla schermata (base riga 1500) sparisce: le tessere salgono (i riquadri partono da 150
  invece di 206).
- **Con un cliente scelto** le tessere del mercato restano; i due riquadri cambiano:
  - «Chi è toccato oggi» diventa **«Cosa tocca <Nome> oggi»** (riga 4011) e mostra solo gli eventi che toccano lui,
    con la frase per lui («Il portafoglio di Marco perde circa 1.150 €: ha il 38% in azioni.»), senza la fila di
    avatar, con «Prepara un messaggio»; senza eventi: «Oggi il mercato non tocca <Nome>.»;
  - «Avvisi» diventa **«Avvisi per <Nome>»**, solo i suoi; senza avvisi: «Nessun avviso per <Nome>.».
- **Con «Tutti i clienti»** le schede di «Chi è toccato oggi» hanno la frase di tutti, gli avatar (al più 3) e
  **«Prepara un messaggio a <Nome>»** (il più toccato), che apre Messaggi con il testo già scritto (`msgMercato`,
  riga 4004: «I mercati di oggi, in due righe», perché «Mercato: <evento>», dati Evento, Cliente, «Fonte: dati pubblici
  di mercato»); se il cliente è un altro, la barra passa a lui.
- **Ogni avviso ha la sua azione** (riga 4016): pallino del tono (il rosso pulsa), avatar 30, titolo, dettaglio, poi
  **«Apri le posizioni»** (per gli avvisi sul portafoglio: calo dal massimo, distanza dal riferimento) o **«Prepara un
  messaggio»** (cedola in arrivo, fondo salito), e **«Silenzia»**. Niente interruttore senza nome.
- **«Silenzia»**: la riga resta in grigio (opacità 0,6, pallino `ink3`), il dettaglio diventa «Silenziato: non entra più
  nel «Da fare»», al posto dei pulsanti **«Riattiva»**; avviso «Silenziato: resta qui in grigio, e si riattiva quando
  vuoi».
- **«Soglie…»** è un pulsante piccolo in alto a destra nel riquadro degli avvisi (riga 4014); apre le soglie (nel
  template una scheda di sola lettura: «Le soglie si cambiano come oggi; le trovi anche in Impostazioni › Mercato.»).
- «Fonte: Dati di prova…» sotto ogni tessera sparisce (regola 37).

### 29.2 Nell'app oggi

- `Sources/Prisma/Shell/AppMercato.swift:37` `CorpoMercato`: tessere ed eventi in cache (`mercato-tessere|<ora>`,
  `mercato-eventi|<ora>`, righe 60-61), poi `contenuto` (riga 109): `FasciaRiservatezzaMercato` (riga 250: fascia
  verde, testi `TestiAppMercato.fascia(attivo:)` in Motori/TestiAppMercato.swift:18, con «Impostazioni › Mercato» se
  spento), `StrisciaMercato`/`VuotoMercato`, i due riquadri `RiquadroToccati` e `RiquadroAvvisi`. **Nessun filtro per
  cliente.**
- `AzioniMercato` (riga 184): `CampoISINMercato`, `PulsanteMercatoClientiVera` («Per i tuoi clienti», fase 4 di Vera),
  **«Soglie degli avvisi»** in `.applePrimario` (blu) nella testata.
- `Shell/AppMercatoRiquadri.swift`:
  - `RiquadroToccati` (riga 11) con titolo `TestiAppMercato.titoloToccati` («Chi è toccato oggi» /«… dall’ultimo
    aggiornamento»); `SchedaToccatiMercato` (riga 84): titolo, frase `fraseToccati` (riga 88), fonte, avatar,
    canale, **«Prepara un messaggio a <Nome>»** già presente (con gli altri clienti nel menu contestuale).
  - `RiquadroAvvisi` (riga 189): «AVVISI», il risultato della ricerca ISIN, le righe `RigaAvvisoMercato` (riga 245):
    pallino, avatar, nome e canale, titolo, fonte; clic sul testo apre posizione o dossier; a destra **un interruttore
    senza nome** («Da guardare», `StatoAvvisoMercato.nuovo/.visto`); azioni solo nel menu contestuale («Prepara un
    messaggio», «Apri la posizione»/«Apri il dossier», «Segna come visto»).
- Un avviso `.visto` ha già il pallino spento (`tonoAvvisoMercato`, StatoMercato.swift:90) e **non entra nelle
  notifiche** (Notifiche.swift:385 legge solo `.nuovo`): è già, nei fatti, «silenziato». Ma resta un'occasione di
  Messaggi, solo con priorità più bassa (`MotoreOccasioniMessaggi.avvisiMercato`, riga 412), e oggi nessun avviso entra
  in un «Da fare» (non c'è una voce del «Da fare» per Mercato).
- `apriAvvisoMercato` (StatoMercato.swift:154) apre la posizione se è una, **altrimenti il dossier** (Clienti), non
  Posizioni; il template con «Apri le posizioni» sceglie il cliente nella barra e apre Posizioni sul suo quadro (riga
  4024). L'interruttore è spento quando `!stato.mercatoModificabile` (iPad, sola lettura).
- `ClienteToccato` (Motori/MotoreMercato.swift:30) ha `impatto`, `perCanale`, `posizioni` per cliente: basta per la
  frase del singolo cliente.

### 29.3 Cosa fare

1. **Il filtro per cliente** (solo Mac): in `CorpoMercato`, se `!stato.tuttiIClienti`, passare ai riquadri gli eventi
   con `toccati.contains { $0.clienteId == id }` e gli avvisi con `clienteId == id` (filtri su elenchi già in cache e
   piccoli). `RiquadroToccati` e `RiquadroAvvisi` prendono un `cliente: Cliente?`.
2. **Titoli e vuoti** in `TestiAppMercato`: `titoloToccati(vecchi:cliente:)` → «Cosa tocca <Nome> oggi» (e «Cosa tocca
   <Nome> dall’ultimo aggiornamento» con i dati vecchi); `avvisi(cliente:)` → «Avvisi per <Nome>»;
   `nessunoToccatoPer(nome)` = «Oggi il mercato non tocca <Nome>.»; `nessunAvvisoPer(nome)` = «Nessun avviso per
   <Nome>.». <Nome> = primo nome (`primoNome`, già in TestiAppMercato).
3. **La frase del singolo cliente**: `TestiAppMercato.fraseToccato(_ e:, toccato: ClienteToccato, tipoSerie:, nome:)`
   dalle cifre del motore («Il portafoglio di <Nome> perde circa 1.150 €», con i canali separati come fa già
   `fraseToccati`; senza cifra la frase qualitativa del tipo di serie). Con un cliente scelto: niente avatar, pulsante
   «Prepara un messaggio» (senza nome), che chiama `preparaMessaggioMercato(e, clienteId:)`.
4. **Le righe degli avvisi** (`RigaAvvisoMercato`): via il `Toggle`; a destra due pulsanti `.apple` piccoli:
   - l'azione: `TestiAppMercato.azioneAvviso(a)` = «Apri le posizioni» (o «Apri la posizione» con una sola) per
     `.caloDalMassimo` e `.distanzaDalRiferimento`: con una posizione «Apri la posizione» → `apriPosizione` (come oggi);
     con più posizioni «Apri le posizioni» → `scegliCliente(a.clienteId)` (miglioria 2, in silenzio) e Posizioni sul
     quadro del cliente, come il template. Non il dossier: il nome del pulsante deve dire dove porta (la funzione
     nuova `apriPosizioniAvvisoMercato(a)` accanto ad `apriAvvisoMercato`, che resta per il clic sul testo e il menu); «Prepara un messaggio» per
     `.cedolaInArrivo` e `.variazioneSerie` → `stato.preparaMessaggioAvviso(a)` (se Messaggi è consentito, altrimenti
     l'apertura della posizione);
   - «Silenzia» → `segnaAvvisoMercato(a.id, visto: true)`; «Silenzia» e «Riattiva» spenti come l'interruttore di oggi
     quando `!stato.mercatoModificabile`.
   Riga `.visto`: opacità `Avviso.opacitaSilenziato` (0,6), al posto della riga della fonte
   `TestiAppMercato.silenziato` = «Silenziato: non entra più nel «Da fare»» (solo se la miglioria 3 mette davvero gli
   avvisi `.nuovo` nel «Da fare», vedi 29.6; altrimenti «Silenziato: niente più notifiche»), un solo pulsante «Riattiva» → `segnaAvvisoMercato(a.id, visto: false)`. Avviso
   `TestiAppMercato.avvisoSilenziato` = «Silenziato: resta qui in grigio, e si riattiva quando vuoi». Il menu
   contestuale resta con le stesse voci ridenominate («Silenzia», «Riattiva»).
5. **«Soglie…»** nel riquadro degli avvisi: in alto a destra accanto al titolo, `.appleSobrio` piccolo
   (`TestiAppMercato.soglieBreve` = «Soglie…») che apre il foglio di oggi `sessione.foglio = .soglie` (si modificano lì,
   come oggi). Togliere «Soglie degli avvisi» blu da `AzioniMercato` (sul Mac).
6. **L'etichetta della riservatezza nella riga in testa**: `EtichettaRiservatezzaMercato` (in AppMercato.swift) come
   primo elemento di `AzioniMercato`: capsula `chip`-bordo (lo stile `.chipC` = quello della pillola del cliente della
   miglioria 2), lucchetto 14 e testo. Testo (vedi 29.6): acceso «Escono solo dati pubblici», spento «Niente esce dal
   Mac». Un clic apre una scheda «Riservatezza» con il titolo uguale all'etichetta e la frase di oggi
   (`TestiAppMercato.fascia(attivo:)`), più «Impostazioni › Mercato» quando è spento. Togliere
   `FasciaRiservatezzaMercato` da `contenuto` sul Mac: la striscia sale di quanto era alta la fascia.
7. Il messaggio di Mercato verso un cliente diverso da quello della barra: lo fa già la miglioria 25 (punto 7).
8. «Fonte: Dati di prova…» sotto le tessere: lo toglie la miglioria 37.

**Non fare**: non copiare la frase del template «dal Mac escono solo gli ISIN»: è falsa per l'app (CLAUDE.md: «Gli ISIN
non escono»; la ricerca ISIN è locale). Non portare `EVM`/`AVM` né la scheda delle soglie in sola lettura con le soglie
scritte a mano. Non aggiungere «＋ Nuovo avviso»: sta nella riga in testa di «Luce» (riga 1499) che il template riusa,
ma l'app non l'ha (gli avvisi nascono dalle soglie) e il gruppo non aggiunge funzioni. Nessuna richiesta di rete nuova: tutto passa ancora da `ClienteMercato.richiesta`.

Token in `DesignSystem/Apple/Tema.Apple+Mercato.swift`: `Avviso.opacitaSilenziato` (0,6), `Avviso.pulsante` (padding
6×12), `Avviso.spazioPulsanti` (6), `Riquadro.soglie` (padding 5×11), nuovo `enum Riservatezza` (lucchetto 14, testo 13
semibold, padding 4×12×4×10, bordo `separatore`, fondo `cardPiena`, solleva 2 sotto il puntatore come le pillole della
riga in testa). Se la miglioria 2 ha già un token per la pillola `.chipC`, riusarlo.

### 29.4 Dati, archivio, privacy

- Nessun campo nuovo: «Silenzia» = `StatoAvvisoMercato.visto` (già salvato in `dati.mercato.avvisi`, nei backup), che
  già non entra nelle notifiche; nel «Da fare» oggi non c'è nessun avviso (dipende dalla miglioria 3). Resta
  un'occasione di Messaggi a priorità bassa, come oggi.
- **Privacy (CLAUDE.md, Mercato):** l'etichetta e la scheda devono dire solo il vero: con l'interruttore acceso escono
  solo richieste di dati pubblici a BCE ed Eurostat; mai ISIN, mai dati dei clienti; spento non esce niente. La prova
  `ProvaCalcoliMercato` (nessuna richiesta con dati dei clienti) resta com'è e deve restare verde.

### 29.5 Istantanee e prove

- Aggiornare `540-mercato` (etichetta nella riga in testa, niente fascia, righe degli avvisi con i pulsanti),
  `541-mercato-vuoto`, `545-mercato-dati-vecchi`, `546-mercato-avviso-spento` (riga silenziata con «Riattiva»),
  `544-mercato-soglie` (aperto da «Soglie…»), `542`/`543` (ricerca ISIN dentro gli avvisi) in Shell/IstantaneeMercato.swift.
- Nuove: `1051-uso-mercato-cliente` (Marco scelto: «Cosa tocca Marco oggi», «Avvisi per Marco»), scura;
  `1052-uso-mercato-riservatezza` (la scheda aperta, interruttore acceso) e `1053-uso-mercato-spento` (etichetta
  «Niente esce dal Mac»).
- `--prova-calcoli`: `ProvaCalcoliMercato` invariata; aggiungere un caso per `fraseToccato` (con e senza cifra) e per
  `azioneAvviso` per ogni `TipoEventoMercato`.

### 29.6 Decisioni per l'utente e rischi

- **Testo dell'etichetta con l'interruttore spento** (di base è spento): «Escono solo dati pubblici» sarebbe falso.
  Proposta: «Niente esce dal Mac» con il lucchetto, e nella scheda come accenderlo.
- **La frase della scheda «Riservatezza»**: il template dice che escono gli ISIN; l'app no. Proposta: «Per aggiornare il
  mercato, dal Mac escono solo le richieste di dati pubblici (BCE, Eurostat). Nessun dato dei clienti lascia Prisma.»
  (la frase di oggi).
- **Quale azione per quale avviso**: il template decide avviso per avviso; proposta per tipo come al punto 4.
- **La frase «non entra più nel «Da fare»»**: è vera solo se la miglioria 3 (gruppo 01) porta gli avvisi `.nuovo` nel
  «Da fare» (la sua tabella di 3.3 oggi non li nomina). Proposta: decidere lì; finché non c'è, «Silenziato: niente più
  notifiche». Un avviso silenziato resta un'occasione di Messaggi (priorità bassa): proposta, lasciarlo così.
- **«Niente esce dal Mac» o la frase di oggi** («Nessun dato esce dal Mac.», `TestiAppMercato.fascia(attivo: false)`):
  proposta, l'etichetta corta «Niente esce dal Mac» e nella scheda la frase di oggi intera, con il rimando a
  Impostazioni › Mercato.
- Rischio: `AppMercato` serve anche l'iPad (sola lettura); fascia e interruttore restano lì finché non arriva il loro
  giro.

### 29.7 Dimensione

M (circa 300 righe). File: Shell/AppMercato.swift, Shell/AppMercatoRiquadri.swift, Shell/StatoMercato.swift
(`apriPosizioniAvvisoMercato`), Motori/TestiAppMercato.swift,
DesignSystem/Apple/Tema.Apple+Mercato.swift, Shell/IstantaneeMercato.swift, Motori/ProvaCalcoliMercato.swift.

---

## 30. Le impostazioni si cercano, in gruppi con un nome

### 30.1 Nel template

Regola 30 (righe 2735-2739), codice righe 4029-4078 (`IMPG`, `IMPS`, `impVociHTML`, `impRisultatiHTML`,
`impPaginaHTML`, `impVai`, `A.render`, il tasto Esc a riga 4078), CSS `.impQ` righe 634-635, `.lbl.ig` riga 541;
pannello `MIG4[5]` riga 4088 («Prova a scrivere «backup»»).

- **In cima alla colonna** (larga 260) un campo `.impQ` (alto 34, raggio 10, fondo `chip`, lente 15 `ink3`, testo
  13,5) con il segnaposto **«Cerca nelle impostazioni»**.
- **I gruppi hanno tutti un nome** (`IMPG`, riga 4039), occhielli `.lbl.ig` (11, 13 sopra, 4 sotto):
  - **«Prisma»**: Aspetto, iPhone e iPad, Archivio e backup, Vera, Profilo;
  - **«Il lavoro»**: Studio, Mercato, Agenda e orari, Promemoria e occasioni, Conformità, Proposte e PDF, Rendimenti di
    confronto;
  - **«Aiuto»**: Scorciatoie, Dati di prova (che la miglioria 37 chiama «Dimostrazione»).
  Sopra i gruppi, da sola, la voce «Da sistemare» (miglioria 31).
- **La ricerca** (`impRisultatiHTML`, riga 4064) cerca, mentre si scrive, nel titolo e nella spiegazione di ogni riga di
  ogni sezione e nel nome della sezione (senza distinguere maiuscole). La pagina a destra diventa «N risultati per
  «backup»» (o «1 risultato», «Nessun risultato»); ogni risultato è una riga come quelle delle impostazioni (titolo,
  spiegazione) con a destra un'etichetta con il nome della sezione e **«Apri»**, che svuota la ricerca e apre la
  sezione. Nessun risultato: «Prova con un’altra parola: «backup», «testo», «promemoria»…». Durante la ricerca nessuna
  voce della colonna è evidenziata.
- **Esc** nel campo pieno lo svuota (e non chiude la finestra); a campo vuoto Esc fa quello che fa sempre.
- Il contenuto delle sezioni resta quello di oggi (regola 30: «qui è ridotto: non è da copiare»).

### 30.2 Nell'app oggi

- `Sources/Prisma/Shell/ImpostazioniAppleMac.swift:24-29`: le sezioni sono **20** (`SchedaImpostazioni`,
  Shell/StatoShell.swift:3913), in tre liste: `sezioniPrincipali` = Panoramica, Aspetto, iPhone e iPad, Archivio e
  backup, Vera, Profilo (**senza titolo di gruppo**); `sezioniLavoro` = Studio, Mercato, Portafogli modello, Pratiche,
  Sala, Moduli, Territorio, Agenda e lavoro, Promemoria e occasioni, Conformità, Proposte e PDF, Rendimenti di
  confronto, **Scorciatoie** (sotto «Il lavoro»); `sezioniProve` = Strumenti (sotto «Per le prove»).
- `barraLateraleApple` (riga 47): nessun campo di ricerca; `gruppoLateraleApple` (riga 70) con l'occhiello facoltativo;
  `VoceLateraleImpostazioniApple` (DesignSystem/Apple/ImpostazioniApple.swift:76) con il pallino facoltativo; in fondo
  `piedeLateraleApple` (archivio locale e versione).
- Le righe delle pagine sono `RigaImpostazione(titolo:sottotitolo:…)` (DesignSystem/ComponentiImpostazioni.swift:129)
  scritte a mano in molti file (AppImpostazioni.swift, ImpostazioniPagine.swift, ImpostazioniArchivio.swift,
  ImpostazioniOvunque.swift, StudioImpostazioni.swift, ImpostazioniMercatoVista.swift, ImpostazioniModelli.swift,
  ImpostazioniPraticheVista.swift, ImpostazioniSalaVista.swift, ImpostazioniModuliVista.swift,
  PaginaImpostazioniTerritorio.swift, ImpostazioniNotteVista.swift, ImpostazioniSpeseVista.swift,
  ImpostazioniFatture.swift…): **nessun indice** delle voci.
- C'è già il meccanismo per andare a un punto di una pagina: `stato.ancoraImpostazioni` + `scorri(_:)`
  (AppImpostazioni.swift:169) + `paginaDellAncora` (riga 183, uno `switch` sulle ancore note), con `.id("…")` sui
  gruppi.

### 30.3 Cosa fare

1. **I gruppi** (ImpostazioniAppleMac.swift, solo Mac): tre liste con nome, sopra la voce «Da sistemare» da sola
   (miglioria 31):
   - «Prisma»: Aspetto, iPhone e iPad, Archivio e backup, Vera, Profilo;
   - «Il lavoro»: Studio, Mercato, Agenda e orari, Promemoria e occasioni, Conformità, Proposte e PDF, Moduli, Pratiche,
     Portafogli modello, Rendimenti di confronto, Sala, Territorio (le sette del template nel loro ordine, le pagine
     che il template non ha accanto a quelle con cui lavorano; vedi 30.6);
   - «Aiuto»: Scorciatoie, Strumenti (che la miglioria 37 rinomina «Dimostrazione»).
   «Per le prove» sparisce. `TestiImpostazioni.gruppoPrisma`, `gruppoLavoro`, `gruppoAiuto`.
2. **Il campo di ricerca** in cima a `barraLateraleApple`, fuori dallo scorrimento: `CampoCercaImpostazioni` (nuovo,
   DesignSystem/Apple/ImpostazioniApple.swift) con lente `magnifyingglass`, `TextField` con `prompt`
   «Cerca nelle impostazioni», `.onExitCommand` che svuota il campo se pieno (a campo vuoto non intercetta Esc), senza
   bordo di fuoco di sistema (come `CampoISINMercato`). Testo in `stato.cercaImpostazioni: String` (in memoria, si
   svuota chiudendo l'app Impostazioni).
3. **L'indice delle voci**: `IndiceImpostazioni` (nuovo file Shell/IndiceImpostazioni.swift, solo Mac):
   `struct VoceIndiceImpostazioni { titolo, spiegazione, pagina: SchedaImpostazioni, ancora: String?, parole: [String] }`
   e `static let voci: [VoceIndiceImpostazioni]`, una per ogni `RigaImpostazione` delle pagine del Mac (titolo e
   sottotitolo scritti come nella riga; per i sottotitoli che cambiano con lo stato, come «Ogni settimana; tengo le
   ultime 8 copie.», la forma fissa più utile). `parole` per i sinonimi utili («copia», «password», «dark»…).
   `static func cerca(_ testo: String) -> [VoceIndiceImpostazioni]`: confronto senza maiuscole né accenti
   (`folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Formati.italiano)`), su titolo, spiegazione,
   nome della pagina e parole; spazi in testa e in coda tolti (`trim` del template). Il template mostra i risultati
   nell'ordine delle sezioni della colonna, senza classifica: proposta, lo stesso ordine (una classifica «prima chi ha la
   parola nel titolo» è un'aggiunta, solo se l'utente la vuole). Nota: cercando il nome di una sezione («backup») escono
   tutte le sue righe, come nel template.
4. **La pagina dei risultati** in `paginaApple` quando il campo non è vuoto: titolo `.h2`
   `TestiImpostazioni.risultati(n, testo)` = «3 risultati per «backup»» / «1 risultato per «backup»» / «Nessun risultato
   per «xyz»»; una `RigaImpostazione` per voce con accessorio = `PillolaApple` neutra col nome della pagina + «Apri»
   (`ValoreRiga` o `.apple`). «Apri» svuota il campo, `stato.schedaImpostazioni = voce.pagina`,
   `stato.ancoraImpostazioni = voce.ancora` (lo `scorri` di oggi porta la riga in vista). Vuoto:
   `TestiImpostazioni.provaAltraParola` = «Prova con un’altra parola: «backup», «testo», «promemoria»…». Durante la
   ricerca `VoceLateraleImpostazioniApple(attiva: false)` per tutte.
5. **Le ancore**: aggiungere `.id(ancora)` alle righe (o ai gruppi) che l'indice indica, con un nome stabile
   «imp-<pagina>-<voce>», e allargare `paginaDellAncora` con la regola «imp-<pagina>-…» → pagina (così non serve un
   `case` per ogni ancora).
6. **Rinomina**: «Agenda e lavoro» → «Agenda e orari» (solo `titolo` sul Mac, il `case .lavoro` resta).
7. iPad: niente cambia (`corpoApple` serve anche l'iPad: ramo `#if os(macOS)`).

**Non fare**: non copiare `IMPS` (il contenuto delle sezioni nel template è ridotto e in parte inventato: «Ogni giorno
alle 18:00», «Ogni lunedì alle 9», le aliquote «Impostate»…); le pagine restano quelle di oggi. Niente ricerca nei
valori scritti dall'utente (nomi dei clienti, cartelle): solo nelle voci dell'interfaccia.

Token in `DesignSystem/Apple/Tema.Apple+Impostazioni.swift`, `enum Laterale`: `cerca` (altezza 34, raggio 10, fondo
`Colore.chip`, padding orizzontale 11, spazio 8, lente 15 `inchiostro3`, testo 13,5, sotto 10, sopra 2), occhiello dei
gruppi `sopraGruppo` 13 e `sottoEtichetta` 4 (i valori del template; oggi 16 e 8: verificare nell'istantanea che non
stringa troppo); `enum Risultati` (pillola della pagina 12 con padding 4×10, spazio 8).

### 30.4 Dati, archivio, privacy

Nessun campo nuovo: il testo della ricerca resta in memoria, l'indice è nel codice. Privacy: la ricerca guarda solo i
testi dell'interfaccia.

### 30.5 Istantanee e prove

- Aggiornare `470-impostazioni-apple` (e scura), `471-impostazioni-archivio-apple` (Shell/IstantaneeImpostazioniApple.swift),
  `3-impostazioni-archivio`, `90-impostazioni-aspetto`, `126-impostazioni-orari`, `134-impostazioni-occasioni`,
  `144-impostazioni-proposte`, `85-impostazioni-strumenti`, `251-impostazioni-vera`, `516-impostazioni-fatturazione`,
  `548-impostazioni-mercato` (la colonna con i gruppi e il campo).
- Nuove: `1054-uso-impostazioni-cerca` («backup», con risultati), scura; `1055-uso-impostazioni-cerca-vuota` (nessun
  risultato).
- Una prova piccola `ProvaIndiceImpostazioni` (in `--prova-calcoli`, sul Mac): ogni voce ha una pagina che sta nella
  barra laterale; nessuna voce doppia; «backup» trova almeno una voce di Archivio e backup; «Backup» e «bàckup» danno lo
  stesso risultato; ogni ancora dell'indice si risolve con `paginaDellAncora`.

### 30.6 Decisioni per l'utente e rischi

- **Dove mettere le pagine che il template non ha** (Portafogli modello, Pratiche, Sala, Moduli, Territorio): proposta
  tutte in «Il lavoro» nell'ordine del punto 1. In alternativa un quarto gruppo «Le app» (Mercato, Pratiche, Sala,
  Territorio, Moduli).
- **«Agenda e lavoro» → «Agenda e orari»**: proposta sì (parola del template); la pagina contiene anche festività e
  seguito delle proposte, che restano.
- **Un tasto per il campo** (⌘F dentro Impostazioni): il template non lo dice. Proposta: sì, solo con Impostazioni in
  primo piano, senza toccare ⌘K («Cerca ovunque»).
- Rischio: **l'indice scritto a mano può restare indietro** rispetto alle righe vere. Mitigazione: la prova del punto
  30.5 e, quando si tocca una pagina, aggiornare l'indice nello stesso commit (da scrivere nel commento in testa a
  IndiceImpostazioni.swift). Le migliorie 37, 38, 39 cambiano tre pagine: aggiornare l'indice con loro.

### 30.7 Dimensione

M (circa 450 righe, metà sono l'indice). File: Shell/ImpostazioniAppleMac.swift, nuovo Shell/IndiceImpostazioni.swift,
DesignSystem/Apple/ImpostazioniApple.swift, DesignSystem/Apple/Tema.Apple+Impostazioni.swift, Shell/AppImpostazioni.swift
(ancore), Shell/StatoShell.swift (titolo, `cercaImpostazioni`), Shell/IstantaneeImpostazioniApple.swift.

---

## 31. Si vede cosa resta da sistemare

### 31.1 Nel template

Regola 31 (righe 2740-2745), codice righe 4033-4073 (`impDaSist`, `impVociHTML`, `impSistHTML`, `montaImpPagina`),
CSS `.impSt` riga 636, `.card.spento` riga 638; pannello `MIG4[6]` riga 4089.

- **La prima voce della colonna è «Da sistemare»** (al posto di «Panoramica»), sopra i gruppi, con a destra il
  **numero** in pillola arancio (`.impSt`: fondo arancio al 16%, testo `--orangeT`, 600); a zero, al posto del numero
  la spunta verde (`gu('fatto',16)`).
- **Accanto alle sezioni**, al posto del pallino arancione, è scritto cosa manca, nella stessa pillola: «mai fatto»
  (Archivio e backup), «spenti» (Promemoria e occasioni), «da completare» (Studio).
- **La pagina** (`impSistHTML`, riga 4060): titolo «Da sistemare» e «Tre cose, poi Prisma è a posto.» («Una cosa…»,
  «Due cose…»); una riga per cosa (titolo, spiegazione, a destra **«Sistema»** blu che porta alla sua sezione):
  - «Nessun backup ancora» — «Il primo backup protegge tutto il lavoro fatto finora.»;
  - «I promemoria sono spenti» — «Appuntamenti e scadenze non arrivano nel Centro notifiche del Mac.»;
  - «Mancano i dati per le fatture» — «Servono per il file della fattura elettronica: 3 su 12 sono compilati.»;
  (la regola 31 aggiunge «Vera non pronta…»). Sotto, occhiello **«A posto»** e le righe con la spunta verde: «Vera è
  pronta» — «Risponde dal Mac: niente esce da qui.»; «iPhone e iPad allineati» — «Sincronizzati 2 minuti fa.»; e, man
  mano, «Backup fatto» — «L’ultima copia è di oggi, cifrata.», «Promemoria accesi» — «Arrivano nel Centro notifiche del
  Mac.», «Dati per le fatture completi» — «Il file della fattura elettronica si può preparare.».
- A zero: titolo **«Tutto a posto»**, «Non c’è niente da sistemare.».
- Sistemata una cosa (backup creato, promemoria accesi, dati completati) il numero scende e la voce nella colonna perde
  la sua etichetta.
- **Le righe che dipendono da un interruttore spento** (i singoli promemoria) sono attenuate (opacità 0,45), non
  nascoste.
- Spariscono i quattro riquadri di stato della «Panoramica» che non portavano da nessuna parte.

### 31.2 Nell'app oggi

- `Sources/Prisma/Shell/AppImpostazioni.swift:236` `panoramica`: quattro `TesseraImpostazioni` (Vera, Ultimo backup,
  Promemoria, Archivio; righe 266-339; ognuna in realtà apre la sua pagina), **un solo** avviso
  (`avvisoPanoramica`, riga 342: sola lettura, copie non leggibili, backup non riuscito o in ritardo, Vera non pronta)
  con «Da guardare» e «Apri», poi logo e «Il tuo spazio. Tutto a portata di mano.». Usa ancora i token del tema vecchio
  (`Tema.Misura.Impostazioni`, `Tema.Testo`).
- `statoVoceLaterale` (ImpostazioniAppleMac.swift:101): un **pallino** (errore o attenzione) accanto a Archivio e
  backup, Vera, iPhone e iPad, Mercato; nessun testo.
- I fatti che servono ci sono già: `stato.solaLettura`, `stato.copieNonLeggibili`, `dati.impostazioni.backup`
  (`ultimo`, `inRitardo`, `ultimoErrore`, `automatico`), `stato.cartellaBackupPredefinita`, `avvertenzaBackup`
  (ImpostazioniArchivio.swift:274), `dati.impostazioni.promemoria.attivi` e `stato.permessoPromemoria`,
  `stato.disponibilitaLocale.pronto`, `stato.ovunque.problema` e `dati.conflittiOvunque`,
  `dati.mercato.ultimoErrore`, i dati per le fatture (`MotoreFattura.mancantiConsulente`, `mancantiRegime`,
  `mancantiPagamento`, Motori/MotoreFattura.swift:151-243), il tagliando dei dati (`stato.esitoTagliando`,
  `dati.tagliando.ultimo`).
- Le righe dei promemoria sono già attenuate quando l'interruttore è spento (ImpostazioniPagine.swift:174-175:
  `.disabled(!scelte.attivi)` e `.opacity(…opacitaDisabilitato)`).

### 31.3 Cosa fare

1. **Il motore** `MotoreDaSistemare` (nuovo, Motori/MotoreDaSistemare.swift, puro e testabile):
   `static func calcola(_ f: FattiDaSistemare) -> (daSistemare: [VoceDaSistemare], aPosto: [VoceDaSistemare])`, con
   `FattiDaSistemare` = i fatti del punto 31.2 già letti (niente scorrimenti dell'archivio) e
   `VoceDaSistemare { id, titolo, spiegazione, pagina: SchedaImpostazioni, ancora: String?, etichettaColonna: String,
   tono }`. Voci, in ordine di gravità:
   - archivio in sola lettura → «L’archivio è in sola lettura» — «Salvato da una versione più recente di Prisma.» —
     colonna «sola lettura» (errore);
   - copie non leggibili → «I backup automatici sono fermi» — «All’avvio una parte dell’archivio non era leggibile.» —
     «da controllare»;
   - backup non riuscito → «L’ultimo backup non è riuscito» — l'errore di `avvertenzaBackup` — «non riuscito»;
   - nessun backup → «Nessun backup ancora» — «Il primo backup protegge tutto il lavoro fatto finora.» — «mai fatto»;
   - backup in ritardo → «Nessun backup da più di 8 giorni» — «Crea un backup a mano, o controlla la cartella.» — «in
     ritardo» (solo con `ultimo != nil`: `ImpostazioniBackup.inRitardo`, DatiPrisma.swift:968, è vero anche senza
     alcun backup dopo un tentativo, e allora vale «Nessun backup ancora»; le due voci non escono mai insieme);
   - backup sullo stesso Mac (`cartellaBackupPredefinita`) → «I backup sono sullo stesso Mac» — «Scegli iCloud Drive o
     un disco esterno.» — «sullo stesso Mac»;
   - Vera non pronta → «Vera non è pronta» — il motivo (`disponibilitaLocale.motivo`) — «non pronta»; **solo dopo la
     prima verifica**: all'avvio `disponibilitaLocale` vale «Ollama non ancora verificato.» (StatoShell.swift:411) e
     contarla farebbe comparire e sparire la voce a ogni apertura;
   - promemoria spenti → «I promemoria sono spenti» — «Appuntamenti e scadenze non arrivano nel Centro notifiche del
     Mac.» — «spenti»; promemoria non consentiti dal Mac → «I promemoria non sono consentiti» — «Consentili in
     Impostazioni di Sistema › Notifiche.» — «non consentiti»;
   - dati per le fatture incompleti (solo se ci sono parcelle o clienti del canale indipendente) → «Mancano i dati per
     le fatture» — «Servono per il file della fattura elettronica: ne mancano N.» — «da
     completare» (`MotoreFattura.mancantiConsulente`, riga 213, dà solo i mancanti, non il totale: «N su M» del template
     richiederebbe un conteggio dei dati richiesti da aggiungere al motore; proposta, «ne mancano N»), ancora `TestiParcelle.ancoraImpostazioni`;
   - «Prisma ovunque» acceso con un problema o con conflitti → «iPhone e iPad non sono allineati» / «Ci sono N modifiche
     da decidere» — «da decidere» / «errore»;
   - Mercato acceso con l'ultimo scaricamento non riuscito → «I dati di mercato non si sono aggiornati» — «non
     aggiornato».
   «A posto», solo per ciò che è attivo: «Vera è pronta» — «Risponde dal Mac: niente esce da qui.»; «Backup fatto» —
   «L’ultima copia è di <giorno relativo>[, protetta da password].» (da `ImpostazioniBackup.protetto`; mai «cifrata» se
   non lo è); «Promemoria accesi» —
   «Arrivano nel Centro notifiche del Mac.»; «Dati per le fatture completi» — «Il file della fattura elettronica si può
   preparare.»; «iPhone e iPad allineati» — «Sincronizzati <quando>.» (solo con «Prisma ovunque» acceso).
2. **I fatti** si leggono in `StatoShell` con `func fattiDaSistemare() -> FattiDaSistemare` (Shell/, nuovo
   StatoDaSistemare.swift): letture dirette, nessun motore pesante; i mancanti delle fatture con
   `stato.ricavato("impostazioni-da-sistemare-fatture")` (dipendono solo dai dati dei calcoli).
3. **La pagina** (sostituisce `panoramica` sul Mac; `SchedaImpostazioni.panoramica` resta il `case`, il titolo sul Mac
   diventa «Da sistemare»): titolo `.h2` «Da sistemare» o «Tutto a posto»; frase `TestiDaSistemare.conteggio(n)` = «Una
   cosa, poi Prisma è a posto.» / «Due cose, poi…» / «Tre cose, poi…» / «N cose, poi…»; «Non c’è niente da sistemare.» a
   zero. Una `RigaImpostazione` per voce con **«Sistema»** (`.applePrimario`) che apre `voce.pagina` con
   `voce.ancora`; occhiello «A posto» e le righe con `checkmark.circle.fill` verde (20). Cascata come le altre pagine.
   Via le quattro tessere, il logo e la frase in fondo.
4. **La colonna**: la voce «Da sistemare» prima dei gruppi, con a destra `PillolaColonnaImpostazioni` (nuova, accanto a
   `VoceLateraleImpostazioniApple`) col numero, o la spunta verde 16 a zero. `statoVoceLaterale` diventa
   `etichettaVoceLaterale(p) -> (testo, tono)?`: la `etichettaColonna` della voce più grave di quella pagina («mai
   fatto», «spenti», «da completare», «non pronta»…), al posto del pallino; tono errore in rosso
   (`StatoRigaApple.colore(.errore)` al 13% / testo rosso), attenzione in arancio (`--orangeT` su arancio al 16%).
5. **Il pallino accanto a iPhone e iPad e a Mercato** di oggi passa dentro il motore (stesse condizioni), così ogni
   segnale della colonna ha anche la sua riga in «Da sistemare».
6. Le righe attenuate dei promemoria ci sono già: nessun lavoro; controllare che le pagine che hanno righe sotto un
   interruttore (Mercato con «Dati di mercato» spento, «Prisma ovunque», Notte) facciano lo stesso: attenuate, non
   nascoste.
7. iPad: tiene la Panoramica di oggi (ramo `#if os(macOS)`).

**Non fare**: non portare i flag finti del template (`bkOk`, `promOn`, `fattOk`, «3 di 12 compilati», «Sincronizzati 2
minuti fa»). Il pulsante «Completa» dei dati per le fatture del template (che segna tutto completo con un clic) **non**
esiste: «Sistema» porta alla pagina dove si scrivono.

Token in `DesignSystem/Apple/Tema.Apple+Impostazioni.swift`: `Laterale.etichettaStato` (carattere 11 semibold, padding
2×7, raggio 99, fondo arancio al 16% con testo `arancioTesto`; errore: rosso al 13% con testo rosso), `Laterale.spunta`
(16, `verde`); nuovo `enum DaSistemare` (frase 13,5 `inchiostro2`, sotto il titolo 4, sotto la frase 14, occhiello «A
posto» 18 sopra 8 sotto, spunta 20). Se la miglioria 7 (gruppo 01) ha creato `arancioTesto`, usarlo.

### 31.4 Dati, archivio, privacy

Nessun campo nuovo: tutto si ricava da stati e impostazioni che ci sono. Privacy: le frasi non contengono dati dei
clienti (solo conteggi). La riga del backup dice «protetta da password» solo se lo è davvero.

### 31.5 Istantanee e prove

- Aggiornare `470-impostazioni-apple` (la colonna con «Da sistemare» e le etichette) e tutte le scene di Impostazioni
  elencate in 30.5.
- Nuove: `1056-uso-da-sistemare` (backup mai fatto, promemoria spenti, dati per le fatture incompleti, Vera pronta e
  backup in «A posto»), scura; `1057-uso-tutto-a-posto` (backup di oggi, promemoria accesi, dati completi: titolo «Tutto
  a posto» e la spunta nella colonna); `1058-uso-da-sistemare-vera` (Vera non pronta, archivio in sola lettura).
- `--prova-calcoli`: `ProvaMotoreDaSistemare` con i casi del punto 31.3 (ordine di gravità, etichetta della colonna
  per pagina, «A posto» solo per ciò che è attivo, fatture solo con parcelle o clienti indipendenti).
- `--prova-backup`: dopo «Crea backup» la voce «Nessun backup ancora» sparisce (si può controllare con il motore sui
  fatti dopo il backup di prova).

### 31.6 Decisioni per l'utente e rischi

- **«I promemoria sono spenti» come cosa da sistemare**: sono spenti di base e qualcuno li vuole spenti. Proposta:
  contano (come nel template); se l'utente preferisce, si aggiunge «Lasciali spenti» che li sposta in «A posto» come
  scelta (servirebbe un campo in `Impostazioni`, da evitare se non chiesto).
- **Il tagliando dei dati** (fase 4 di Vera): proposta, una riga in «Da sistemare» quando il tagliando ha trovato
  qualcosa («Il tagliando dei dati ha trovato N cose da guardare», «Sistema» apre la pagina del tagliando), e la card
  esce dalla colonna di Vera (vedi 27.6).
- **«3 su 12 compilati» dei dati per le fatture**: il motore conosce solo i mancanti. Proposta: «Servono per il file
  della fattura elettronica: ne mancano N.»; il «N su M» solo se si aggiunge a `MotoreFattura` il conteggio dei dati
  richiesti.
- **Backup «sullo stesso Mac»**: oggi è una pillola d'attenzione della tessera. Proposta: conta come cosa da sistemare
  (un backup sullo stesso disco non protegge da un guasto).
- Rischio: la colonna si ridisegna a ogni cambio di `disponibilitaLocale` o di `ovunque.problema`; tenere il calcolo
  leggero (solo letture) e fuori dai body delle pagine.

### 31.7 Dimensione

M (circa 400 righe). File: nuovo Motori/MotoreDaSistemare.swift, nuovo Shell/StatoDaSistemare.swift,
Shell/AppImpostazioni.swift (pagina), Shell/ImpostazioniAppleMac.swift (colonna), DesignSystem/Apple/ImpostazioniApple.swift,
DesignSystem/Apple/Tema.Apple+Impostazioni.swift, Shell/StatoShell.swift (titolo), Shell/IstantaneeImpostazioniApple.swift,
la prova del motore.
