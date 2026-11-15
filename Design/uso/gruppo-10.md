# Gruppo 10 — La Sala, esperienza per esperienza (migliorie 58-60)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html (stesse righe). Il codice del gruppo sta alle righe 4748-4816 («SETTIMO GIRO ·
La Sala, esperienza per esperienza (58–60)»: 58 a 4752-4769, 59 a 4771-4789, 60 a 4791-4809), con il pannello `MIG10`
alle righe 4811-4816 (`apriSala` 4812, `const MIG10` 4813, voci 4814-4816); le regole che dicono come il
gruppo si porta nell'app vera sono alle righe 2867-2879 (commento «58 · Sala e «Al tavolo» [470, 471]», 59, 60), il CSS
nuovo alle righe 747-751. Per tutto ciò che il gruppo non cambia valgono Design/template-luce.html e la sua specifica
Design/template-luce-specifica.md (§1.3 la Sala, §3-§4 le esperienze, giro 16 il tavolo a doppio senso).

Il gruppo non aggiunge esperienze: rende ognuna delle undici più facile da usare davanti al cliente. **Un solo modo di
mostrare** (il tavolo diventa un'etichetta della vista del cliente, non un secondo pulsante in ogni palco), **un copione**
per ogni esperienza (che vede solo il consulente) e **una traccia** di ciò che si è fatto, con la proposta della prossima.
Grafica, vetro, acqua, logo e colori dei canali restano come sono.

## Ordine consigliato

1. **Prima le migliorie da cui il gruppo dipende.**
   - La **1** del gruppo 01 («Mostra al cliente»: la vista pulita `VistaCliente`, `StatoShell.vistaCliente`,
     `mostra(_:)`, `fineMostra()`, il menu di «DV» sull'avatar, il pannello `PannelloMostraAlCliente` con la riga
     «Sull’iPad sul tavolo»). La 58 vive **dentro** quella vista: senza la 1 non ha dove stare.
   - La **34** del gruppo 05 (le esperienze al momento giusto: `MomentoSala`, `EsperienzaSala.momento`, `.minuti`,
     `consigliate(priorita:)`). La 59 scrive nel titolo del copione il momento e i minuti; la 60 sceglie la prossima
     esperienza seguendo i momenti e preferendo le consigliate.
   - La **2** del gruppo 01 («Un solo posto per il cliente»): le pillole dei clienti spariscono dalla testata della Sala;
     il gruppo 10 non le usa più, ma va fatto dopo perché tocca la stessa testata (`AzioniSala`).
   - La **39** (l'iPad sul tavolo si collega da Impostazioni › iPhone e iPad): «Manda sull’iPad sul tavolo» con l'iPad
     non collegato porta lì. Finché la 39 non c'è, apre il pannello del tavolo di oggi (`PannelloAlTavolo`).
   - La **4** del gruppo 01 (la riga sola in testa alla finestra): non tocca la testata del palco (i pulsanti nuovi
     della 59 e della 60 stanno comunque nella fila di «✦ Aggiungi al Prisma di …», dentro il palco), ma sposta titolo e
     occhiello nella barra della finestra, dove la 60 scrive «<n> esperienze fatte oggi con <Nome>»: se la 4 è già
     fatta, l'occhiello dinamico va lì, altrimenti in `IntestazioneApp`.
   - Il **gruppo 05** (34) dà anche le consigliate in cache (`"sala-consigliate|\(id)"`) e l'etichetta del momento sulle
     schede, sotto la quale la 60 mette «✓ Fatta oggi».
2. **59 · Il copione.** È la più indipendente (solo testi e un riquadro nel palco, nessun dato). Si può fare subito dopo
   la 34.
3. **60 · Ogni esperienza lascia qualcosa.** Dopo la 59 (stessa fila di pulsanti `AzioniPalco`), con un campo nuovo
   nell'archivio e la sua prova di backup.
4. **58 · Un solo modo di mostrare.** Per ultima: è la più grande (tocca il tavolo, la presentazione dei Prospetti,
   la barra della vista pulita e la presa visione) e ha le decisioni più delicate (58-a … 58-e). Chiude anche la
   sostituzione di «▶︎ Presenta» con «Mostra al cliente» nella Sala, avviata dalla 1.

**Solo Mac.** Tutto il gruppo è dentro `#if os(macOS)` o in file solo Mac. L'iPad del tavolo **non cambia**: la 58 usa
solo i messaggi del protocollo del tavolo che esistono già (`ProtocolloTavolo`, versione di oggi). Le viste delle
esperienze sono condivise con l'iPad, e **anche la cornice della Sala**: l'iPad usa `ContenutoApp` (iOS/GuscioiPad.swift)
e quindi `AppSala` → `CorpoSala` → `PalcoSala` (AppSala.swift non è un file solo Mac: lo dicono i `#if os(macOS)` già
presenti in `PalcoSala`). Perciò i pulsanti nuovi della testata del palco (`AzioniPalco`), il riquadro del copione, i
segni della 60 sulla griglia e il segno automatico vanno tutti dentro `#if os(macOS)` (o con una condizione falsa su
iOS). Le istantanee di iPhone e iPad della Sala devono restare identiche.

---

## 58. Un solo modo di mostrare (e i comandi del tavolo in un'etichetta)

### 58.1 Nel template

Codice righe 4752-4769, CSS riga 747-748, regola righe 2867-2873, pannello `MIG10[0]` (riga 4814: sceglie Marco,
apre la Sala sul gioco del rischio ed entra nella vista del cliente con `entraPulita('sala',1)`).

**Cosa sparisce.** Nel palco di ogni esperienza il pulsante «▣ Mostra sul tavolo» (`#saTav`, base riga 1706) non c'è
più: la ridefinizione di `palcoHTML` (riga 4804) lo toglie. Restano «✦ Aggiungi al Prisma di …» dove serviva e, nella
testata della finestra, il pulsante blu «Mostra al cliente» della miglioria 1 (riga 3110). La regola (riga 2867-2872)
dice anche che sparisce **la fila di otto pulsanti di oggi** (la striscia «Al tavolo» della presentazione nell'app vera,
istantanea 470): i quattro «Manda…» non servono perché l'iPad mostra quello che c'è sullo schermo; «Lascia un cursore al
cliente» diventa «può toccare»; «Schermata neutra» resta nel menu di «DV».

**L'etichetta del luogo** (`#bTav`, riga 4757: pillola di vetro `pill glass`, 13 semibold, CSS riga 747). Sta nella
barra **subito prima di «DV»** e si vede **solo nella vista del cliente** (`pulita`), in ogni capitolo (Il quadro, Le
posizioni, Gli obiettivi, Nel tempo, La Sala). Contenuto (`tavAggiorna`, riga 4758): un glifo, il testo e una freccina
in giù al 60%:
- **«Su questo schermo»** (glifo schermo) quando il cliente guarda il Mac;
- **«iPad sul tavolo»** (glifo iPad) quando guarda l'iPad.

**Il menu dell'etichetta** (riga 4766, `apriMenu(bTav, …, true)`: sotto la pillola, 8 più in basso, **allineato al
bordo destro della pillola**, con la stessa entrata degli altri menu della barra; un secondo clic lo chiude):
- con il cliente sul Mac:
  1. «Manda sull’iPad sul tavolo» (glifo iPad)
  2. «Chiedi la presa visione»
- con il cliente sull'iPad:
  1. «Torna su questo schermo» (glifo schermo)
  2. — separatore —
  3. «Il cliente può toccare l’iPad: no» / «Il cliente può toccare l’iPad: sì» (interruttore: il testo dice lo stato
     di adesso; si parte da «no»)
  4. «Chiedi la presa visione»

**Al clic** (`tavCambia`, riga 4765; nel template `tavolo` mette anche la classe `tavolo` sullo stage, ma nessuna
regola CSS la usa: nessun cambio visibile della vista del cliente sul Mac):
- «Manda sull’iPad sul tavolo» → avviso «L’iPad sul tavolo mostra quello che vedi qui: tu guidi dal Mac»; l'etichetta
  diventa «iPad sul tavolo»; nella Sala i pulsanti del consulente del palco tornano visibili (vedi 59 e 60: sul Mac li
  vede solo il consulente, perché il cliente guarda l'iPad).
- «Torna su questo schermo» → avviso «Il cliente guarda di nuovo questo schermo»; i pulsanti del consulente spariscono
  di nuovo dal palco.
- «Il cliente può toccare l’iPad» → avviso «Sull’iPad adesso può toccare anche il cliente» oppure «Sull’iPad guidi solo
  tu».
- «Chiedi la presa visione» → `apriPresa` (riga 4759).

**La presa visione** (`apriPresa`, righe 4759-4764; senza un cliente non si apre), una scheda centrata:
- occhiello blu «Presa visione»; titolo «<Nome> conferma di aver visto.»;
- testo «Non è una firma di contratto: dice solo che quello che c’è sullo schermo gli è stato mostrato, oggi.»;
- un riquadro tratteggiato (`.presaF`, CSS riga 748: bordo 1,5 tratteggiato inchiostro3, raggio 18, padding 10×16×12,
  centrato) con un tratto di firma che si disegna in 1,6 s dopo 0,5 s (fermo con «Riduci movimento») e sotto la
  scritta «Firma qui, con il dito o con il mouse» (cliente sul Mac) oppure «Firma con il dito, sull’iPad» (cliente
  sull'iPad);
- in basso: «Registra la presa visione» (blu, grande), «Annulla», e a destra «Resta nei Documenti di <Nome>»;
- «Registra la presa visione» chiude e avvisa «Presa visione registrata: è nei Documenti di <Nome>, con data e ora».

**Entrare e uscire** (righe 4767-4769):
- entrare nella vista del cliente aggiorna l'etichetta (si parte sempre da «Su questo schermo»);
- **uscire** dalla vista del cliente («DV › Fine: torna al lavoro» o ⌥⌘M) rimette il cliente sul Mac (`tavolo=false`);
- nel pannello «Mostra al cliente» la riga «Sull’iPad sul tavolo» ora funziona: chiude il pannello, accende il tavolo
  ed entra nel capitolo «Il quadro» con l'avviso «L’iPad sul tavolo mostra il quadro: tu guidi dal Mac» (nel template
  della 1 era solo un avviso).

**Uscita dalla vista**: resta «DV» (cartellino del pannello: «Per uscire: «DV».»); «Schermata neutra» resta nel menu di
«DV» (miglioria 1).

### 58.2 Nell'app oggi

- **«▣ Mostra sul tavolo» nel palco**: `PalcoSala` (Shell/AppSala.swift:318-394, `testata` da riga 348), pulsante
  `PulsanteMostraSulTavolo` (Shell/SalaRealta.swift:339-381) per le esperienze con `EsperienzaSala.mostraSulTavolo`
  (Shell/StatoSala.swift:57) e acceso solo con `tavoloPronto` (riga 68). Al tocco chiama
  `StatoShell.mostraEsperienzaSulTavolo(_:cliente:)` (SalaRealta.swift:257-282): genere vivo per realtà aumentata,
  rischio, Lancia l'anno e disegno (`sala.tavoloEsperienza`), il foglio per la lettera (`tavolo.mandaPagina`),
  l'immagine ferma del palco per prisma di luce e giornata (`mandaImmaginePalco`, riga 291); prima la conferma delle
  cifre (`ConfermaCifreTavolo`, riga 384, decisione 49, già in `.overlay(alignment: .top)` del palco,
  AppSala.swift:336-342). Senza iPad apre in un popover `PannelloAlTavolo`. Le proprietà che servono già ci sono
  (SalaRealta.swift:235-249): `genereTavolo` (il genere a doppio senso: realtà aumentata, rischio, Lancia l'anno,
  disegno **e capsula**; nil = immagine del palco o pagina) e `cifreSulTavolo` (tutte tranne il gioco del rischio).
  Chiudere il palco chiama `lasciaTavolo(_:)` (SalaRealta.swift:328), che rimette l'iPad sulla schermata neutra se
  mostrava quel genere.
- **La capsula sull'iPad esiste già** come genere vivo: nel palco della capsula, con l'iPad collegato, il pulsante
  «Scrivi sull’iPad» (`TestiRealta.scriviSullIPad`, Shell/SalaCapsula.swift:480-495) chiama
  `tavolo.chiediTestoCapsula` (TavoloMac.swift:596): il cliente scrive e sigilla sull'iPad, il testo torna cifrato.
  Anche il gioco del rischio manda da sé il suo stato quando `sala.tavoloEsperienza == .giocoRischio`
  (`mandaAlTavolo`, Shell/SalaGiocoRischio.swift:129). Sono comandi **dell'esperienza**, non doppioni del «mostrare».
- **«▶︎ Presenta»** nella stessa testata (AppSala.swift:386): `presentaEsperienza(_:)` (Shell/SovrapposizioneLuce.swift:109)
  accende la modalità cliente e apre la sala opaca (`VistaPresentazioneEsperienza`, AppSala.swift:509). La miglioria 1
  lo sostituisce con «Mostra al cliente» → capitolo «La Sala» (gruppo 01 §1.3 punto 11). `presentaEsperienza` è usata
  anche dalla prova di Vera (Vera/ProvaVera.swift:528 e 534) e dall'istantanea «694-sala-presenta»
  (Shell/IstantaneeLuce.swift:60).
- **La striscia degli otto pulsanti**: nella presentazione dei Prospetti (Shell/Presentazione.swift:243 e 322)
  `PulsanteTavoloSala` («Al tavolo» con il puntino) apre `StrisciaTavoloSala` (Shell/AlTavolo.swift:227-275) con le
  azioni di `TavoloMac.azioni(_:)` (Tavolo/TavoloMac.swift:485-510) tranne «Manda tutto il documento»: «Manda questa
  pagina», «Manda la macchina del tempo», «Manda la famiglia», «Manda la linea della vita», «Lascia un cursore al
  cliente», «Chiedi la presa visione», «Schermata neutra», più «Chiudi il tavolo». Istantanea «470-tavolo-sala».
- **Il pannello del tavolo nei Prospetti**: `PulsanteAlTavolo` / `PannelloAlTavolo` (AlTavolo.swift:34-198) con le
  stesse azioni, i limiti del cursore («Cursore da … a … €», «Lascia») e «Presa visione archiviata in Documenti».
- **Lo stato del tavolo**: `TavoloMac` (Tavolo/TavoloMac.swift, `ObservableObject`, in `stato.tavolo`): `acceso`,
  `collegato`, `descrizione` («Tavolo chiuso», «iPad non collegato», «iPad collegato · <nome>»), `mostrato`,
  `schermataNeutra()` (313), `mandaPagina`/`mandaDocumento` (337/352), `mandaNelTempo`, `mandaFamiglia`,
  `mandaLineaVita`, `mandaImmagine` (585), `lasciaCursore` (447), `chiediPresaVisione` (472),
  `cifreDaConfermare`/`confermaCifre` (513-519).
- **La presa visione oggi** esiste **solo sull'iPad** e **solo per un documento** mandato al tavolo:
  `puoChiederePresaVisione` (riga 269) vuole un documento di quel cliente già sull'iPad; il tratto arriva dall'iPad
  (`PresaVisioneTavoloiPad`, iOS/SchermiTavoloiPad.swift:676), il Mac aggiunge la pagina finale `PaginaPresaVisione`
  (AlTavolo.swift:279) con `documentoConPresaVisione` (TavoloMac.swift:813) e archivia il PDF nei Documenti del cliente
  (`archiviaPresaVisione`, riga 713). Testo esatto della pagina: «Presa visione del documento: non costituisce firma
  contrattuale» (`ProtocolloTavolo.testoPresaVisione`, Tavolo/ProtocolloTavolo.swift:52), poi, scritto nella vista
  (AlTavolo.swift:310), «Il documento è stato mostrato al cliente sull'iPad, al tavolo, pagina per pagina. Il segno qui
  sotto dice solo che l'ha visto.». Il riquadro del tratto della pagina è 300×120 (`Tema.Apple.Tavolo.PresaVisione`,
  DesignSystem/Apple/Tema.Apple+Tavolo.swift:58-72; da lì viene anche `Tema.Apple.TavoloiPad.rapportoArea`, 2,5 : 1).
  Istantanea
  «471-tavolo-presa-visione». **Sul Mac non si firma**: non c'è un'area per il tratto con mouse o trackpad.
- **Il tavolo non «segue lo schermo»**: manda solo ciò che il consulente sceglie. Non c'è un'etichetta del luogo, né
  un interruttore «può toccare».
- **La vista del cliente** con i capitoli, la barra pulita e il menu di «DV» **non esistono ancora** (li porta la 1).

### 58.3 Cosa fare

1. **Lo stato del luogo** (nuovo file `Shell/LuogoCliente.swift`, solo Mac), accanto allo stato della vista pulita della
   miglioria 1 in `StatoShell`:
   - `enum LuogoCliente { case schermo, tavolo }`, `var luogoCliente: LuogoCliente = .schermo` (osservato, in memoria);
   - `var tavoloTocca = false` (osservato, in memoria; si azzera a ogni «Manda sull’iPad»);
   - `func mandaAlTavolo()`, `func tornaSulloSchermo()`, `func cambiaTocco()`;
   - in `fineMostra()` (gruppo 01): se `luogoCliente == .tavolo`, `tavolo.schermataNeutra()` e `luogoCliente = .schermo`,
     `tavoloTocca = false`. **Il tavolo non si chiude** (resta in ascolto: vedi decisione 58-c).
   - `mostra(_:)` entra sempre con `luogoCliente = .schermo`; la riga «Sull’iPad sul tavolo» di
     `PannelloMostraAlCliente` chiama `mostra(.quadro)` e poi `mandaAlTavolo()`, con l'avviso del template. Con l'iPad
     non collegato vale quello che dice già il gruppo 01 (§1.3 punto 4): dal pannello, che è **prima** della vista del
     cliente, porta a Impostazioni › iPhone e iPad (miglioria 39); dentro la vista invece mai (punto 4 qui sotto). Le
     due regole vanno scritte insieme quando si fa la 58, perché la 1 le tocca entrambe.
2. **L'iPad segue lo schermo** (stesso file, `extension StatoShell`): `func seguiSulTavolo()` manda all'iPad ciò che
   la vista del cliente mostra, **usando solo i messaggi che esistono già**:
   - capitolo «La Sala» con un'esperienza sul palco → `mostraEsperienzaSulTavolo(_:cliente:)` di oggi (con la conferma
     delle cifre della decisione 49, che resta);
   - capitolo «La Sala» sulla griglia, e i capitoli «Il quadro», «Le posizioni», «Gli obiettivi», «Nel tempo» →
     l'immagine ferma del capitolo, come `mandaImmaginePalco` (renderizzata con `ImageRenderer`, `\.modoIstantanea`
     vero, scura, misura `Tema.Apple.RealtaAumentata.ImmaginePalco.misura`); generalizzare `mandaImmaginePalco` in
     `mandaImmagineVista(_ vista: some View, titolo:cliente:)`;
   - il prospetto a tutto schermo (`mostraProspetto`, gruppo 01) → `tavolo.mandaPagina` della pagina che si guarda, e a
     ogni pagina sfogliata di nuovo (oggi «Manda questa pagina» a mano).
   - Si chiama a `mandaAlTavolo()` e poi a ogni cambio di capitolo, di esperienza sul palco o di pagina, **solo** con
     `luogoCliente == .tavolo` e `tavolo.collegato`. Con `.onChange` in `VistaCliente` sui soli valori che cambiano
     (capitolo, `sala.esperienza`, pagina), mai nel body. Chiudere il palco chiama già `lasciaTavolo(_:)` (schermata
     neutra se l'iPad mostrava quel genere): `seguiSulTavolo()` va chiamato **dopo**, così l'iPad passa all'immagine
     della griglia invece di restare neutro; idem a ogni cambio di esperienza con «Prossima» (60).
   - Le cifre del cliente sull'iPad chiedono la conferma una volta per cliente come oggi (`cifreDaConfermare`): con
     l'etichetta su «iPad sul tavolo» la riga `ConfermaCifreTavolo` compare sul Mac, che il cliente non guarda.
3. **«Il cliente può toccare l’iPad»** senza cambiare l'iPad (decisione 58-b): con «no» l'iPad riceve **solo immagini
   ferme e pagine** (anche per rischio, Lancia l'anno, disegno e realtà aumentata: l'immagine del palco); con «sì»
   `seguiSulTavolo()` usa i generi vivi di oggi (`sala.tavoloEsperienza`, `tavolo.mandaRealta`), nel prospetto
   `tavolo.mandaDocumento` (il cliente sfoglia) e nel capitolo «Nel tempo» il cursore del versamento
   (`tavolo.lasciaCursore` con i limiti di oggi 50-1.000 €). Cambiare l'interruttore richiama `seguiSulTavolo()`.
   - Attenzione al gioco del rischio: con «no» il cliente non può rispondere sull'iPad; il gioco si gioca sul Mac come
     oggi. La prima volta che si apre il gioco con l'iPad e «no», un avviso: «Per far rispondere il cliente sull’iPad,
     scegli «Il cliente può toccare l’iPad: sì»» (testo nuovo, decisione 58-b).
   - La capsula: con «sì» il genere vivo di oggi (`chiediTestoCapsula`, il cliente scrive e sigilla sull'iPad); il
     pulsante «Scrivi sull’iPad» del palco resta, ma si offre solo con `luogoCliente == .tavolo` e «può toccare: sì»
     (fuori dalla vista del cliente l'iPad non mostra nulla, vedi «Non fare»). Con «no» l'immagine del palco.
   - Le quattro esperienze che oggi **non** hanno «▣ Mostra sul tavolo» (Il Prisma del cliente, Quanto vale avermi
     accanto, la capsula, e il film, che non è in `tavoloPronto`): il template dice che l'iPad mostra quello che c'è
     sullo schermo, quindi anche loro vanno sull'iPad come immagine del palco (`ContenutoPalco(inSala: true)`, già nello
     stato finale). Da controllare nell'immagine del Prisma del cliente che non compaia la password (CLAUDE.md: non va
     mai nello stesso messaggio del file; sull'iPad non si salva, ma meglio non disegnarla): se compare, il campo va
     nascosto con `inSala`. Decisione 58-f.
4. **L'etichetta nella barra** (Shell/BarraSuperiore.swift, nella barra della vista pulita della miglioria 1): nuova
   vista `EtichettaLuogo` subito **prima dell'avatar con l'anello** (il «DV» del template). Pillola di vetro come le
   altre pillole della barra: `PulsanteBarra(forma: .pillola)` (BarraSuperiore.swift:234-276, oggi `private`: renderlo
   interno al file o mettere `EtichettaLuogo` nello stesso file; non esiste un `PillolaBarra`), glifo SF Symbol
   (`display` per lo schermo, `ipad.landscape` per l'iPad, come `PulsanteAlTavolo`, AlTavolo.swift:48), testo «Su
   questo schermo» / «iPad sul tavolo», freccina `chevron.down` all'opacità del token. Il menu con le voci esatte di
   58.1, nell'ordine, allineato a destra della pillola, **con lo stesso meccanismo del menu dell'avatar della miglioria
   1** (un menu solo per la barra della vista pulita: se la 1 usa un `Menu` di SwiftUI, `.menuStyle(.borderlessButton)`
   con l'etichetta personalizzata e `Divider()`; se usa un popover del tema, lo stesso popover).
   - L'etichetta osserva solo `luogoCliente` e `tavoloTocca` (e `tavolo.collegato` per il punto: vedi sotto): messa in
     una sottovista a sé, così la barra non si ridisegna a ogni cambio del tavolo.
   - **Con l'iPad non collegato** «Manda sull’iPad sul tavolo» resta nel menu e, al clic, porta a Impostazioni › iPhone
     e iPad (miglioria 39) dopo aver chiesto di uscire dalla vista del cliente? **No**: le Impostazioni non si aprono
     nella vista pulita. Proposta (decisione 58-d): la voce si mostra spenta con sotto «iPad non collegato» (il
     `PuntinoTavolo` di oggi accanto al glifo); se il tavolo è chiuso, la voce lo apre (`tavolo.avvia()`, senza codice
     sullo schermo: in modalità cliente `PannelloAlTavolo` già lo nasconde) e manda appena l'iPad si collega.
5. **La presa visione per ciò che si vede** (nuovo `Shell/PresaVisioneMac.swift`, solo Mac):
   - Scheda `SchedaPresaVisione` (stessa scheda centrata di `PannelloMostraAlCliente`), testi esatti di 58.1; il nome
     è il nome breve del cliente (`StatoShell.nomeBreve`).
   - **Sul Mac** (luogo `.schermo`): area per il tratto con `Canvas` e `DragGesture` (mouse o trackpad; stesso
     rapporto 2,5 : 1 del riquadro della pagina PDF, `Tema.Apple.Tavolo.PresaVisione.tratto` 300×120 — non il token di
     `Tema.Apple+TavoloiPad.swift`, che è dell'iPad), «Cancella» piccolo, «Registra la presa
     visione» spento finché non c'è un tratto. Il tratto di esempio del template **non si porta**: l'area parte vuota
     (nelle istantanee il tratto di prova `TrattoProvaTavolo.immagine()`).
   - **Sull'iPad** (luogo `.tavolo`): la scheda sul Mac mostra «Firma con il dito, sull’iPad» e un'attesa; parte la
     richiesta di oggi (`RichiestaPresaVisioneTavolo`, `ascolto.manda(.richiestaPresaVisione)`), generalizzando
     `chiediPresaVisione` perché valga anche per l'immagine mandata (non solo per un documento). «Registra la presa
     visione» si accende quando il tratto arriva (`archiviaPresaVisione`).
   - **Il documento**: un `DocumentoStampabile` con la pagina di ciò che si vedeva (la pagina del prospetto, oppure
     l'immagine del capitolo o del palco su carta bianca, come le pagine del PDF: niente vetro sui documenti) e in fondo
     `PaginaPresaVisione` di oggi; il testo di quella pagina oggi è fisso nella vista (AlTavolo.swift:310: «Il
     documento è stato mostrato al cliente sull'iPad, al tavolo, pagina per pagina. Il segno qui sotto dice solo che
     l'ha visto.»): renderlo un parametro con i testi in un enum (`TestiPresaVisione`): «… al cliente su questo
     schermo. …» / «… al cliente sull'iPad, al tavolo, pagina per pagina. …»; per un'immagine «pagina per pagina» non
     vale (una pagina sola).
     Archiviazione con `archiviaProspetto` di oggi, nei Documenti del cliente; avviso del template.
   - La frase della scheda («Non è una firma di contratto…») è per il cliente; quella della pagina PDF resta
     `ProtocolloTavolo.testoPresaVisione` (decisione 58-e).
6. **Togliere i doppioni.**
   - `PalcoSala.testata`: via `PulsanteMostraSulTavolo` (SalaRealta.swift:339 si toglie, o resta solo per le prove se
     servisse); via «▶︎ Presenta» (lo sostituisce «Mostra al cliente» della 1 nella testata della finestra; nella vista
     pulita sul capitolo «La Sala» il palco resta quello aperto, come `mostraCapitolo('sala', tieni)` del template).
   - `EsperienzaSala.mostraSulTavolo` non serve più (e con lui il pulsante). Il genere vivo lo dice `genereTavolo`
     (SalaRealta.swift:235), non `tavoloPronto`: `tavoloPronto` comprende anche prisma di luce, lettera e giornata, che
     vanno come immagine o pagina. Con «può toccare: no» o con `genereTavolo == nil` si manda l'immagine (la lettera: la
     sua pagina, come oggi). `tavoloPronto` si può togliere se nessun altro lo usa.
   - «▶︎ Presenta» e `presentaEsperienza`: aggiornare la prova di Vera (ProvaVera.swift:528-534) e l'istantanea
     «694-sala-presenta»; `VistaPresentazioneEsperienza` resta solo se la vista del cliente della 1 la riusa.
   - Presentazione dei Prospetti: `PulsanteTavoloSala` e `StrisciaTavoloSala` (Presentazione.swift:243, 322) si tolgono
     **quando la presentazione è dentro la vista del cliente**; restano solo se la presentazione si apre fuori (se la 1
     e la 24 la portano tutta dentro, si tolgono del tutto).
   - `PulsanteAlTavolo` / `PannelloAlTavolo` nei Prospetti: li toglie la miglioria 24 del gruppo 03 («Mostra al
     cliente» prende il posto di «Al tavolo»). Le funzioni di `TavoloMac` restano: sono usate da `seguiSulTavolo()`.
   - «Schermata neutra» resta nel menu di «DV» (gruppo 01); con il cliente sull'iPad, la schermata neutra copre **anche**
     l'iPad (`tavolo.schermataNeutra()`), e «Tocca per riprendere» richiama `seguiSulTavolo()`.
7. **Token** in `DesignSystem/Apple/Tema.Apple+MostraAlCliente.swift` (il file della 1), nuovo `enum Luogo`:
   `carattere` 13 semibold, `lato glifo` 14, `lato freccia` 11, `opacitaFreccia` 0,6, `spazio` come le pillole della
   barra. La scheda della presa visione **non** in un nuovo `enum PresaVisione` (il nome c'è già:
   `Tema.Apple.Tavolo.PresaVisione`, i token della pagina PDF), ma in `Tema.Apple.Tavolo.PresaVisione.Scheda`
   (Tema.Apple+Tavolo.swift): `area` bordo 1,5 tratteggiato (`dash` 6/5), colore inchiostro3, raggio 18,
   padding 10×16×12, altezza 120, tratto 2,6 (colore inchiostro), testo sotto 13 secondario; `disegno` del tratto di
   esempio no (vedi sopra). Tempi da `Tema.Apple.Moto` (comparsa della scheda come `PannelloMostraAlCliente`).
8. **Avvisi** con `stato.mostraAvviso(_:)`, testi esatti di 58.1.

**Non fare**: non portare il tratto di firma «finto» del template; non mandare all'iPad niente fuori dalla vista del
cliente (il Mac fuori dalla vista non è «lo schermo del cliente»); non cambiare il protocollo del tavolo né le viste
dell'iPad; non mostrare il codice di abbinamento nella vista del cliente; non lasciare «▣ Mostra sul tavolo» come
seconda strada.

### 58.4 Dati, archivio, privacy

- **Nessun campo nuovo**: `luogoCliente` e `tavoloTocca` vivono in memoria, come la modalità cliente. La presa visione
  finisce nei Documenti del cliente come oggi (un `Documento` di tipo prospetto con il PDF), quindi nei backup e, come
  gli altri documenti, **non** in «Prisma ovunque» (l'istantanea dello spazio è senza documenti).
- **Privacy del tavolo** (CLAUDE.md, «tavolo a doppio senso»): resta tutto in rete locale cifrata, niente si salva
  sull'iPad; le cifre del cliente vanno sull'iPad **solo dopo la conferma del consulente**, una volta per cliente
  finché il tavolo resta aperto. «L'iPad segue lo schermo» **non deve aggirare** questa conferma: `seguiSulTavolo()`
  passa sempre da `cifreDaConfermare` prima di mandare un capitolo con cifre (tutti tranne la griglia della Sala e il
  gioco del rischio). Con «Manda sull’iPad» e cifre da confermare, l'iPad resta neutro finché il consulente non preme
  «Mostra» nella riga di conferma.
- Le immagini dei capitoli mandate all'iPad sono come quelle del palco di oggi (decisione 111): nessun dato di altri
  clienti, perché la vista del cliente legge solo il cliente mostrato.
- Il tratto della presa visione fatto sul Mac non si salva da nessuna parte se non nel PDF archiviato.

### 58.5 Istantanee e prove

- Nuove scene (in `Shell/IstantaneeTavolo.swift`, che ha già 470 e 471; i numeri 679-689 sono liberi nel codice — 670-678
  e 690-695 sono della Sala — e in nessun'altra specifica di Design/uso/; il gruppo usa 680-688), chiare e scure dove
  ha senso:
  - **«680-mostra-luogo-schermo»**: vista del cliente, capitolo «La Sala» sul gioco del rischio, etichetta «Su questo
    schermo» con il menu aperto (serve un modo per aprire il menu nelle istantanee: uno stato
    `@ObservationIgnored var menuLuogoIstantanea` che disegna il menu come elenco fermo, perché i `Menu` di sistema non
    compaiono nelle istantanee — altrimenti chiedere uno screenshot all'utente);
  - **«681-mostra-luogo-tavolo»**: «iPad sul tavolo» (tavolo per istantanea con `mostraPerIstantanea(iPad:…)`), con i
    pulsanti del consulente visibili nel palco;
  - **«682-presa-visione-mac»**: la scheda con il tratto di prova;
  - **«683-presa-visione-attesa-ipad»**: la scheda con «Firma con il dito, sull’iPad».
- Da aggiornare: «470-tavolo-sala» (senza la striscia se la presentazione è dentro la vista), «471-tavolo-presa-visione»
  (il sottotitolo della pagina), «691-sala-palco» e le scene dei palchi 620-678 (senza «▣ Mostra sul tavolo» e senza
  «▶︎ Presenta»), «633-sala-rischio-al-tavolo», «634-sala-lancia-al-tavolo», «635-sala-realta-conferma-cifre» e
  «695-sala-tavolo» (tutte in Shell/IstantaneeSalaRealta.swift; ora si arriva dall'etichetta), «694-sala-presenta»
  (Shell/IstantaneeLuce.swift:58-60, sostituita dalla vista del cliente).
- Prove:
  - `--prova-tavolo` (Tavolo/ProvaTavolo.swift): un caso per `seguiSulTavolo()` (cambio di capitolo → un solo messaggio
    all'iPad; con cifre da confermare nessun messaggio prima della conferma; con «può toccare: no» solo immagini e
    pagine, mai `.cursore` né i generi vivi); un caso per la presa visione di un'immagine (PDF con due pagine nei
    Documenti); `fineMostra()` manda la schermata neutra.
  - `--prova-realta`: la conferma delle cifre resta una volta per cliente anche passando dall'etichetta.
  - La prova della modalità cliente (`provaModoClienteLuce`, Dati/ProvaBackupLuceClienti.swift:194, in
    `--prova-backup`, estesa dalla 1 — StatoShell.swift:4020-4045, citato dal gruppo 01, è invece una prova di Vera):
    fuori dalla vista del cliente `mandaAlTavolo()` non fa nulla.
  - `--prova-vera`: ProvaVera.swift:528-534 usa `presentaEsperienza`; va adattata se «▶︎ Presenta» si toglie.
  - `--prova-backup` non cambia (nessun campo nuovo).

### 58.6 Decisioni per l'utente e rischi

- **58-a · «L'iPad mostra quello che vedi qui».** Il template lo dà per fatto; l'app oggi manda cose scelte. Proposta:
  l'iPad **segue** la vista del cliente usando i messaggi di oggi (immagine ferma del capitolo, pagina del prospetto,
  generi vivi della Sala), senza toccare l'iPad. Uno specchio continuo dello schermo (video) non si fa: più rete, più
  memoria, e il protocollo dell'iPad cambierebbe.
- **58-b · «Il cliente può toccare l’iPad».** Proposta: «no» = solo immagini e pagine; «sì» = i generi vivi di oggi, il
  documento da sfogliare e il cursore del versamento in «Nel tempo». Così il cursore sparisce come pulsante, come chiede
  la regola. Da decidere: se il gioco del rischio, che si gioca toccando, debba passare da solo a «sì» quando lo si apre
  con l'iPad (proposta: no, si chiede con l'avviso; il consulente decide).
- **58-c · Il tavolo all'uscita.** Proposta: «Fine: torna al lavoro» mette l'iPad sulla schermata neutra e lascia il
  tavolo in ascolto (si chiude da Impostazioni › iPhone e iPad, miglioria 39, al blocco di Prisma e alla chiusura, come
  oggi). Alternativa: chiuderlo del tutto, ma poi l'iPad va ricollegato a ogni incontro.
- **58-d · iPad non collegato.** Proposta: la voce del menu resta, spenta con «iPad non collegato», e a tavolo chiuso lo
  apre e manda appena l'iPad arriva; mai le Impostazioni dentro la vista del cliente.
- **58-e · Le parole della presa visione.** Il template dice «Non è una firma di contratto: dice solo che quello che c’è
  sullo schermo gli è stato mostrato, oggi.»; la pagina PDF di oggi dice «Presa visione del documento: non costituisce
  firma contrattuale». Proposta: la frase del template nella scheda (parla al cliente), quella di oggi resta nel PDF
  (è il testo «ufficiale» già usato sull'iPad). La firma con il mouse sul Mac è una cosa nuova: chiedere conferma che
  basti un tratto fatto con il trackpad (non è una firma grafometrica).
- **58-f · Le esperienze che oggi non vanno sul tavolo.** Il Prisma del cliente, Quanto vale avermi accanto, la capsula
  e il film oggi non hanno «▣ Mostra sul tavolo». Con «l'iPad mostra quello che vedi qui» ci vanno anche loro.
  Proposta: immagine ferma del palco per tutte e quattro (senza la password del Prisma del cliente); la capsula con
  «può toccare: sì» usa il genere vivo di oggi («Scrivi sull’iPad»). Alternativa: per queste quattro l'iPad resta
  sulla schermata neutra.
- **Rischi**: `ImageRenderer` di un capitolo intero sul thread principale a ogni cambio (capitoli lunghi con grafici):
  renderizzare solo a capitolo fermo (dopo l'animazione, `Tema.Apple.Moto.tempo`), una volta per cambio, e non a ogni
  scorrimento; tenere d'occhio la memoria (8 GB) con PNG grandi (misura fissa del palco di oggi). `TavoloMac` è un
  `ObservableObject`: l'etichetta lo osservi in una sottovista piccola, mai la barra intera. Il `Menu` di sistema non
  compare nelle istantanee: serve lo stato di prova o uno screenshot.

### 58.7 Dimensione

**L** (oltre 500 righe). File principali: Shell/LuogoCliente.swift (nuovo), Shell/PresaVisioneMac.swift (nuovo),
Shell/BarraSuperiore.swift, Shell/SalaRealta.swift, Shell/AppSala.swift, Shell/AlTavolo.swift, Shell/Presentazione.swift,
Tavolo/TavoloMac.swift, Shell/StatoSala.swift, Shell/VistaCliente.swift e Shell/PannelloMostraAlCliente.swift (della 1),
Shell/SalaCapsula.swift (il pulsante «Scrivi sull’iPad»), Shell/SovrapposizioneLuce.swift (`presentaEsperienza`),
DesignSystem/Apple/Tema.Apple+MostraAlCliente.swift, DesignSystem/Apple/Tema.Apple+Tavolo.swift,
Shell/IstantaneeTavolo.swift, Shell/IstantaneeSalaRealta.swift, Tavolo/ProvaTavolo.swift, Vera/ProvaVera.swift,
Dati/ProvaBackupLuceClienti.swift.

---

## 59. Ogni esperienza ha il suo copione

### 59.1 Nel template

Codice righe 4770-4789, CSS righe 749-750, regola righe 2874-2875, pannello `MIG10[1]` (riga 4815: Marco, «Una
giornata della pensione», copione aperto). La guida della Sala (riga 3024) lo nomina: «Dentro, «Cosa dire» ti dà il
copione; per mostrarla usa «Mostra al cliente».»

**Il pulsante.** Nella testata del palco, a destra, il primo dei pulsanti del consulente (`#saMie`, prima di «✦ Aggiungi
al Prisma di …»): «**Cosa dire**» con il glifo «info» (`saAzioniHTML`, righe 4799-4800). Un clic apre il riquadro; un
secondo clic lo chiude (`copioneApri`, riga 4785).

**Il riquadro** (`#saCopP`, CSS riga 749): una scheda sopra il palco, **ancorata in alto a destra, 48 sotto la testata,
larga 372**, padding 16×18, fondo dei menu (`--pop`), ombra lunga (0 24 50 −18, blu notte al 50%), sopra il contenuto
(z 8). Entra scendendo di 8 e crescendo da 0,98 con una molla in 0,32 s (ferma con «Riduci movimento»). Dentro,
nell'ordine:
1. l'occhiello «**Cosa dire · <momento in minuscolo> · <n> minuti**» (per esempio «Cosa dire · per spiegare · 3
   minuti»; per il Prisma del cliente, che non ha durata, «Cosa dire · dopo l’incontro») e a destra una ✕ che chiude.
   Il template scrive sempre «minuti», anche per il film che dura 1 («Cosa dire · dopo l’incontro · 1 minuti»): è una
   svista, nell'app «1 minuto»;
2. «Apri così» (piccolo, secondario) e la frase d'apertura (`.copA`: carattere del titolo, 17 semibold, interlinea 1,35,
   tracking −0,2);
3. «Mentre la fate» e tre righe numerate (numerino tondo blu 20, cifra 11,5; testo 14, spazio 10, padding 5);
4. «Chiudi con una domanda» e la domanda (`.copA`);
5. in fondo, sopra un filetto: «**Lo vedi solo tu: nella vista del cliente non compare.**»

**I testi** (`COPIONE`, righe 4773-4784), esattamente:

| Esperienza | Apri così | Mentre la fate | Chiudi con una domanda |
|---|---|---|---|
| Il Prisma del cliente | «Tutto quello che abbiamo visto oggi le resta in tasca.» | Fagli scegliere la password davanti a te · Mostra come si apre sul telefono · Di’ che non passa da nessun server: glielo mandi tu | «A chi vorrebbe farlo vedere?» |
| Il prisma di luce | «Questo è tutto quello che ha, in una luce sola.» | Lascia che sia lui a passare sui raggi · Passa a «Per obiettivo»: i soldi prendono un nome · Sposta il cursore a vent’anni | «Quale raggio vorrebbe più largo?» |
| La lettera dal futuro | «Le leggo una lettera. L’ha scritta lei, a 67 anni.» | Leggi piano, senza commentare · Mostra «Senza il piano»: cambiano poche righe · Lascia un momento di silenzio | «Cosa vorrebbe che ci fosse scritto?» |
| Il film del piano | «In un minuto, quello che ci siamo detti oggi.» | Guardatelo insieme una volta · Mandalo subito, finché è fresco · Serve a chi a casa non c’era | «A chi lo fa vedere stasera?» |
| Disegna il tuo futuro | «Mi disegni come vorrebbe che crescessero i suoi risparmi.» | Non correggere il disegno · Lascia che Prisma lo trasformi nel piano possibile · Fai notare dove disegno e piano si staccano | «Cosa dovrebbe succedere in quel punto?» |
| Il gioco del rischio | «Non le chiedo quanto rischio sopporta: glielo faccio provare.» | Non suggerire la risposta · Guarda quanto ci mette a decidere · Alla fine confronta con il profilo dichiarato | «Se fosse successo davvero, cosa avrebbe fatto?» |
| Una giornata della pensione | «Questa è una sua giornata, il primo anno di pensione.» | Parti da «Senza piano» · Fai contare a lui cosa non ci sta · Passa a «Con il piano» solo dopo | «A cosa non rinuncerebbe?» |
| Lancia l’anno | «Lanciamo un anno: può andare bene o male, come nella vita.» | Fai lanciare a lui · Dopo un anno storto, guarda la colonna «Con il piano» · Dieci anni in una volta mostrano la differenza | «Quale delle due vite preferisce?» |
| Quanto vale avermi accanto | «Una volta l’anno le dico quanto è valso il nostro lavoro.» | Leggi le quattro cifre, una per volta · Spiega da dove viene ogni cifra · Confronta con la parcella, senza scusarti | «C’è qualcosa che si aspettava e non ha trovato?» |
| La capsula del tempo | «Scriva due righe a sé stesso, per il giorno in cui ce l’avrà fatta.» | Lascialo scrivere da solo · Scegliete insieme quando si apre · Sigilla davanti a lui: non la legge nessuno | «Che giorno sarà, quello?» |
| La realtà aumentata | «Mettiamo il suo patrimonio qui, sul tavolo.» | Usa l’iPad o l’iPhone · Fagli girare intorno al cristallo · «Esploso» separa gli strati | «Quale strato vorrebbe più alto tra dieci anni?» |

**Quando si vede** (`saAzioniMonta`, riga 4801): i pulsanti del consulente (qui «Cosa dire», e quelli della 60) si
vedono **nella vista di lavoro** e **nella vista del cliente solo quando il cliente guarda l'iPad** (`!pulita || tavolo`).
Quando il cliente guarda il Mac spariscono e, se il copione era aperto, si chiude. Aprire un'altra esperienza o tornare
alla griglia chiude il copione (`montaSala`, riga 4806). «✦ Aggiungi al Prisma di …» invece non è fra i pulsanti del
consulente e resta dov'è anche nella vista del cliente (il template non lo tocca).

### 59.2 Nell'app oggi

- La testata del palco: `PalcoSala.testata` (Shell/AppSala.swift:348-393); a destra oggi «▣ Mostra sul tavolo»,
  «✦ Aggiungi al Prisma di …», «▶︎ Presenta» (`HStack` con `.fixedSize()`). Sopra il contenuto del palco c'è già un
  overlay in alto: la riga `ConfermaCifreTavolo` (AppSala.swift:336-342, solo Mac).
- Le esperienze: `EsperienzaSala` (Shell/StatoSala.swift:11-76), con `titolo`, `frase`, `glifo`; **nessun momento né
  durata** finché non c'è la 34.
- I testi delle esperienze stanno in parte nei motori (`TestiRealta`, Motori/MotoreRealtaAumentata.swift:264;
  `TestiCapsule`; `TestiUscitaRischio`) e in parte nelle viste.
- Le parole a cui i copioni rimandano ci sono: «Per obiettivo» (Motori/MotoreLuce.swift:25), «Senza il piano»
  (Shell/SalaLettera.swift:143), «Senza piano» / «Con il piano» (SalaGiornataPensione.swift:122, SalaLanciaAnno.swift:237),
  «Sigilla» (SalaCapsula.swift:117). Il film dell'app dura **venti secondi** («Venti secondi da mandare dopo
  l’incontro», StatoSala.swift:45), non un minuto. «Quanto vale avermi accanto» ha tre voci che entrano nel totale
  (`TipoVoceValore`: «Tasse risparmiate», «Costi tagliati», «Rispetto all’alternativa»,
  Motori/MotoreValoreConsulente.swift:30-39) più il totale: sono **quattro cifre**, il copione va bene così (con meno di
  12 mesi il motore dice «presto per misurare» senza totale: il copione resta lo stesso, è un'indicazione di lavoro).
- **Manca** tutto: pulsante, riquadro, testi.

### 59.3 Cosa fare

1. **I testi** in un file nuovo `Motori/CopioneSala.swift` (puro, nessuna vista, comune anche se oggi lo usa solo il
   Mac): `struct CopioneSala { let apertura: String; let passi: [String]; let domanda: String }` e
   `extension EsperienzaSala { var copione: CopioneSala }` con lo `switch` completo sulle undici (una esperienza nuova
   senza copione non compila). Testi della tabella di 59.1, con le correzioni della decisione 59-a. Titoli fissi:
   `TestiCopione.titolo(_ e:)` → «Cosa dire · per spiegare · 3 minuti» (momento della 34 in minuscolo,
   «minuti»/«minuto»; senza durata solo il momento), `apriCosi` «Apri così», `mentre` «Mentre la fate», `chiudi` «Chiudi
   con una domanda», `soloTu` «Lo vedi solo tu: nella vista del cliente non compare.», `pulsante` «Cosa dire».
2. **Lo stato**: in `StatoSala` `var copioneAperto = false` (osservato, non salvato); si azzera in `apriEsperienza`,
   `tornaAllaSala`, al cambio di cliente e quando il cliente torna a guardare il Mac (58).
3. **Il pulsante** nella testata del palco: una sottovista nuova `AzioniPalco` (in AppSala.swift o in un file nuovo
   `Shell/SalaAzioniPalco.swift`) che raccoglie i pulsanti del consulente — «Cosa dire» qui, «Segna come fatta» /
   «✓ Fatta oggi» / «Prossima: … ›» della 60 — e si mostra solo se `consulenteVede`: vero fuori dalla vista del
   cliente **e fuori dalla modalità cliente** (`stato.modoCliente == nil`: la vista pulita della 1 è costruita sulla
   modalità cliente, e un'altra entrata nella modalità cliente non deve mostrare il copione), e nella vista del cliente
   solo con `luogoCliente == .tavolo` (58). Una proprietà calcolata in `StatoShell`, letta una volta nella testata.
   Ordine nella testata, da sinistra:
   `AzioniPalco`, poi «✦ Aggiungi al Prisma di …». Stile `.apple` con il glifo `info.circle` (SF Symbol, lato 14).
4. **Il riquadro** `RiquadroCopione` in `.overlay(alignment: .topTrailing)` del palco (sopra `ContenutoPalco`, sotto la
   testata), non un popover: così le istantanee lo disegnano e resta dentro la finestra. Il palco ha già un overlay in
   alto (`ConfermaCifreTavolo`, centrato): se compaiono insieme il copione sta sopra (`zIndex`) e la riga di conferma
   resta leggibile a sinistra; verificarlo con la scena 681. Superficie dei menu del tema
   (la stessa di `PannelloMostraAlCliente` o dei popover di vetro), con la ✕ (`xmark`, `.appleSobrio`). Entrata con
   `Tema.Apple.Moto` (molla breve al `ritmo`, spostamento −8 e scala 0,98), «Riduci movimento»: dissolvenza 0,15 s;
   istantanee: già aperto e fermo. Esc con il copione aperto lo chiude prima di tornare alla griglia (`EscSala`).
5. **Token** in `DesignSystem/Apple/Tema.Apple+SalaEsperienze.swift`, nuovo `enum Copione`: `larghezza` 372,
   `dallAlto` 48, `padding` 16×18, `raggio` come le schede del palco, `ombra` (y 24, raggio 50, −18, notte 0,5: usare
   l'ombra dei pannelli sospesi se il tema ne ha già una uguale), `frase` (carattere titolo 17 semibold, interlinea
   1,35, tracking −0,2), `etichetta` (il «k» del tema: secondario 12,5), `passo` (testo 14, spazio 10, padding
   verticale 5), `numerino` (lato 20, cifra 11,5 bold, fondo accento, testo bianco), `spazioSezione` 12, `filetto`
   (separatore del tema, padding 10). Movimento in `Tema.Apple.Moto.SalaEsperienze.copione`.
6. **Su iPhone e iPad niente** (`#if os(macOS)` attorno ad `AzioniPalco` e al riquadro).

**Non fare**: non mostrare il copione nella vista del cliente sul Mac, nella presentazione, nelle immagini mandate
all'iPad (`mandaImmaginePalco`, SalaRealta.swift:291, disegna solo `ContenutoPalco(inSala: true)`, mentre il riquadro
sta in `PalcoSala`: va bene così, non spostarlo dentro `ContenutoPalco`) né nei PDF; non
farlo scrivere a Vera (testi fissi, nessuna cifra).

### 59.4 Dati, archivio, privacy

Nessun campo nuovo: i copioni sono testi fissi dell'app, lo stato aperto/chiuso è della vista. Nessuna cifra del
cliente nei copioni. Privacy: il copione è un'indicazione di lavoro e non compare mai davanti al cliente (la regola
«Lo vedi solo tu»).

### 59.5 Istantanee e prove

- Nuove scene in `Shell/IstantaneeLuce.swift` (accanto a 690-694), chiare e scure: **«684-sala-copione»** (Giulia,
  «Una giornata della pensione», copione aperto), **«685-sala-copione-senza-durata»** (Il Prisma del cliente:
  occhiello senza minuti).
- Da aggiornare: «691-sala-palco» (il pulsante «Cosa dire» nella testata); verificare che «693-sala-modo-cliente» e la
  scena della vista del cliente sulla Sala (gruppo 01) **non** lo mostrino, e che «681-mostra-luogo-tavolo» (58) sì.
- Prove: in `ProvaCalcoliEsperienza` (Motori/ProvaCalcoliEsperienza.swift, `--prova-calcoli`) un caso che ogni
  esperienza abbia apertura, **tre** passi e una domanda non vuoti, e che `TestiCopione.titolo` dica «minuti»/«minuto»
  e niente durata dove manca. La prova della modalità cliente: `consulenteVede` falso nella vista del cliente con il
  cliente sul Mac.

### 59.6 Decisioni per l'utente e rischi

- **59-a · Testi da allineare all'app.** Il copione del film dice «In un minuto…», ma il film dell'app dura venti
  secondi. Proposta: «In venti secondi, quello che ci siamo detti oggi.». «Quanto vale avermi accanto» dice «Leggi le
  quattro cifre»: verificato, l'app ne mostra tre più il totale, quindi resta com'è (non serve decidere). Il Prisma
  del cliente: «Fagli scegliere la password davanti a te» contrasta con le regole (la password di tre parole e un numero
  la propone Prisma e non va mai nello stesso messaggio del file; si può anche scrivere a mano): proposta «Scegliete
  insieme la password, davanti a lui» e aggiungere nulla sulla spedizione oltre «Di’ che non passa da nessun server:
  glielo mandi tu». La realtà aumentata: «Usa l’iPad o l’iPhone» va bene (sul Mac c'è l'anteprima).
- **59-b · Copioni modificabili?** Il template li fissa. Proposta: fissi in questo giro; se l'utente li vuole suoi, in
  un giro futuro in Impostazioni › Sala (con un campo nuovo).
- **59-c · Tu o lei.** I copioni danno del «tu» al consulente e del «lei» al cliente nelle frasi da dire, come il
  template; resta così.
- Rischi: la testata del palco si allunga («Cosa dire», «Segna come fatta», «Aggiungi al Prisma di …»): con finestre
  strette i pulsanti vanno ridotti a icone con `ViewThatFits` (come le pillole di oggi), mai tagliati; verificare con
  «618-app-nuove-sala» e una scena stretta.

### 59.7 Dimensione

**S/M** (circa 200 righe, metà sono testi). File principali: Motori/CopioneSala.swift (nuovo), Shell/AppSala.swift
(o Shell/SalaAzioniPalco.swift nuovo), Shell/StatoSala.swift, DesignSystem/Apple/Tema.Apple+SalaEsperienze.swift,
Shell/IstantaneeLuce.swift, Motori/ProvaCalcoliEsperienza.swift.

---

## 60. Ogni esperienza lascia qualcosa

### 60.1 Nel template

Codice righe 4791-4809, CSS riga 751, regola righe 2876-2879, pannello `MIG10[2]` (riga 4816: Marco, gioco del
rischio, segnato come fatto, il cartellino indica «Prossima»).

**Nel palco** (`saAzioniHTML`, righe 4799-4800), dopo «Cosa dire»:
- se l'esperienza **non** è ancora fatta oggi con questo cliente: «**Segna come fatta**» (pulsante normale);
- se è fatta: l'etichetta verde «**✓ Fatta oggi**» (`st2 ok`: 11,5 bold, capsula, fondo verde 15%, testo #1F7A41,
  in scuro #6FD08E) e, se ce n'è una, il pulsante blu «**Prossima: <nome dell'esperienza> ›**», che apre subito quella
  esperienza sul palco.
- Si vedono alle stesse condizioni del copione (vista di lavoro, o cliente sull'iPad).

**Segnare** (`salaSegna`, riga 4803; senza cliente scelto non fa nulla): «Segna come fatta» → avviso «**«<nome dell'esperienza>» segnata: resta scritta nel
dossier di <Nome>, con la data di oggi**»; i pulsanti diventano «✓ Fatta oggi» e «Prossima: … ›».

**Si segna da sola** (riga 4807) quando l'esperienza ha una fine chiara: dopo un clic su un pulsante che dice
«Sigilla», «Salva come obiettivo», «Prepara il file», «Manda su WhatsApp», «Esporta il video» o «Apri e consegna»
(senza avviso, 0,6 s dopo). La regola (riga 2877-2878) li riassume: Sigilla, Salva come obiettivo, Prepara il file,
Manda, Esporta, Apri e consegna. Nel template quindi: capsula («✉︎ Sigilla la capsula»), disegno («Salva come
obiettivo»), Prisma del cliente («Prepara il file»; «Manda con Messaggi» **non** segna), film («⇩ Esporta il video»,
«Manda su WhatsApp»). Il gioco del rischio nel template **non** si segna da solo (nessun suo pulsante corrisponde).

**La prossima** (`salaProssima`, righe 4797-4798): fra le esperienze non ancora fatte oggi (esclusa quella aperta), il
**primo momento dopo** quello dell'esperienza aperta che ne ha almeno una libera (ordine «Per aprire» → «Per spiegare» →
«Per chiudere» → «Dopo l’incontro»); dentro quel momento la prima consigliata per il cliente (34), altrimenti la prima
nell'ordine del template (`SALA_M`: prisma di luce, disegna, realtà aumentata · rischio, giornata, Lancia l'anno ·
lettera, quanto vale, capsula · **film, poi** Prisma del cliente). Se nei momenti dopo non ce n'è, la prima libera
dello **stesso** momento; i momenti **prima** non si propongono mai (dopo il film, se il Prisma del cliente è fatto,
nessun pulsante anche se restano esperienze «per aprire»). Se non resta nulla, nessun pulsante. Nota: l'ordine dentro
«Dopo l’incontro» è diverso da `EsperienzaSala.allCases` (che mette prima il Prisma del cliente): va scritto esplicito.

**Nell'ingresso della Sala** (griglia, righe 4808-4809; non nella vista del cliente): ogni scheda già fatta oggi porta
in alto a destra, 44 dall'alto e 14 da destra (sotto l'etichetta del momento della 34), «✓ Fatta oggi»; il sottotitolo
della finestra (`#wSub`, la riga sotto il titolo «La sala.») diventa «Un’esperienza fatta oggi con <Nome>» oppure «<n>
esperienze fatte oggi con <Nome>»; senza esperienze fatte resta quello della base.

**Nel dossier**: la regola dice «Lascia una riga nel dossier, con data ed esperienza»; il template non mostra dove.

### 60.2 Nell'app oggi

- **Nessuna traccia generica** delle esperienze fatte. Esistono tracce **specifiche**, ognuna nel file del cliente:
  le partite del gioco del rischio (`DatiPrisma.partiteRischio`, Dati/DatiPrisma.swift:80; «L'ultima volta», scena
  «664-sala-rischio-ultima-volta»), le lettere conservate (`lettere`), le capsule (`capsule`), la giornata della
  pensione nell'Analisi 360 (`Analisi360.giornata`), gli obiettivi salvati dal disegno, e **le cose date al cliente**
  (`uscite`: `UscitaCliente`, Dati/UscitaCliente.swift:25, con `GenereUscita` prismaCliente, film, biglietto, capsula,
  aggiornamentoSinistro), mostrate in cima a Documenti da `UsciteDelCliente` (Shell/UsciteCliente.swift:140, usata in
  Shell/ClienteDocumenti.swift:67) con il titolo «Dato al cliente».
- **I punti in cui un'esperienza finisce** ci sono già: `sigilla(obiettivi:)` (Shell/SalaCapsula.swift:362) e
  `sigillaCapsula` (Shell/StatoCapsule.swift:67); «Apri e consegna» (SalaCapsula.swift); «Salva come obiettivo»
  (Shell/SalaDisegna.swift:390, modulo a riga 541); `preparaPrismaCliente` e `registraUscitaPrismaCliente`
  (Shell/StatoPrismaCliente.swift:178, 256); `esportaOra` (Shell/SalaFilm.swift:313) e `registraUscitaFilm`
  (Shell/StatoFilm.swift:64); `registraUscita` (UsciteCliente.swift:78). Il gioco del rischio **non** salva da solo al
  risultato: la partita entra nel dossier solo con «Salva nel dossier» e la conferma (decisione 52 di «Luce»;
  `salva(_:)`, Shell/SalaGiocoRischio.swift:424 e 442).
- La griglia: `GrigliaSala`, `SchedaGrandeSala`, `SchedaPiccolaSala` (Shell/AppSala.swift:155-316). **La finestra non ha
  un sottotitolo**: la barra della finestra (`FinestraInterna`, riga 97) scrive solo il titolo, e il corrispondente di
  `#wSub` è l'occhiello di `IntestazioneApp` (Shell/ContenutoApp.swift:214-230): titolo `AppPrisma.titoloIntestazione`
  «La sala.» (AppPrisma.swift:173) e occhiello `AppPrisma.occhiello` «Da vivere insieme al cliente», in maiuscolo
  (AppPrisma.swift:126). `AppPrisma.sottotitolo` («Le esperienze da vivere con il cliente», riga 157) si vede solo nel
  segnaposto e nelle righe delle Impostazioni. L'occhiello ha già un caso dinamico: Mercato (`OcchielloMercato`).
  La miglioria 4 del gruppo 01 sposta titolo e occhiello nella riga sola della finestra.
- Eliminare un cliente toglie le sue uscite (StatoShell.swift:992); «Unisci le schede» le sposta e le rimette con
  l'annullamento (Shell/CollegaTagliandoShell.swift:480, 714, 961-1039); «Prisma ovunque» le toglie dall'istantanea
  (Dati/SpazioOvunque.swift:178) e tiene quelle locali all'unione (riga 520). Un campo nuovo del file del cliente va
  in tutti questi punti.
- Le chiavi del file del cliente: `ArchivioPezzi.pezzo` (Dati/ArchivioPezzi.swift:56-63). Versione dei dati 27
  (Dati/DatiPrisma.swift:240).
- **Manca**: «Segna come fatta», «✓ Fatta oggi», «Prossima», il segno sulla griglia, il sottotitolo e la riga nel
  dossier.

### 60.3 Cosa fare

1. **Il dato** (Dati/, nuovo file `Dati/EsperienzaFatta.swift`): `struct EsperienzaFatta: Identifiable, Codable,
   Hashable { var id: String; var clienteId: String; var esperienza: EsperienzaSala; var quando: Date }`
   (`EsperienzaSala` è `String`-backed e sta nello stesso modulo: si codifica col suo rawValue, e un valore sconosciuto
   **fa fallire la decodifica dell'elemento**, così `ElencoTollerante` lo scarta; con un `String` libero invece non si
   scarterebbe nulla). Nessun testo, nessuna cifra, nessuna risposta: solo **chi, cosa, quando**. In `DatiPrisma` il
   campo `esperienzeFatte: [EsperienzaFatta] = []`, letto con `ElencoTollerante`; in `DatiVivi` il campo osservato
   (`segnala(.neutro)`: non tocca i calcoli). Tutti i punti, sul modello di `uscite`: `DatiPrisma` (campo, `CodingKeys`
   riga ~318, decodifica riga ~404, `metti` riga ~472, l'`init` se elenca i campi), `DatiVivi` (campo, carica riga ~163,
   istantanea righe ~265 e ~321, confronto riga ~380, e `numeroCampi` da 53 a 54, che la prova confronta con Mirror),
   `ArchivioPezzi` (vedi 60.4), `StatoShell.eliminaCliente` (riga 992), `CollegaTagliandoShell` (unione, annullamento e
   la struttura dell'unione, righe 480, 714, 961-1039), `SpazioOvunque` (righe 178 e 520). Vedi 60.4.
2. **Le funzioni** (Shell/StatoSala.swift o un file nuovo `Shell/StatoEsperienzeFatte.swift`):
   - `func esperienzaFattaOggi(_ e:, cliente:) -> Bool` e `func esperienzeFatteOggi(cliente:) -> Set<EsperienzaSala>`
     con `stato.ricavato(…)`, mai un filtro su tutto l'archivio nel body di ogni scheda. **Attenzione alla chiave**:
     `stato.ricavato` si rinnova solo con `versioneCalcoli`, il giorno e la modalità cliente (DerivatiDati.swift:263), e
     un campo con `segnala(.neutro)` **non** cambia `versioneCalcoli`: con la chiave `"sala-fatte|\(id)"` il segno appena
     messo non si vedrebbe fino a domani. Nella chiave va quindi ciò che cambia a ogni segno o «Togli», per esempio
     `"sala-fatte|\(id)|\(dati.esperienzeFatte.count)|\(dati.esperienzeFatte.last?.id ?? "")"` (leggere `count` e
     `last` iscrive la vista al solo campo `esperienzeFatte`, che cambia di rado); il giorno lo rinnova già
     `DerivatiDati`. Stessa regola per il riquadro del dossier (punto 7);
   - `func segnaEsperienza(_ e:, cliente:, avviso: Bool)`: se non è già fatta oggi aggiunge un `EsperienzaFatta` con
     `Date()`; con `avviso` mostra il testo esatto di 60.1. Una sola volta al giorno per esperienza e cliente. Solo Mac
     (`#if os(macOS)`, o nulla su iOS): le viste delle esperienze sono condivise con l'iPad e l'iPad non deve scrivere
     questo campo (non passa dal giornale di «Prisma ovunque»);
   - `func prossimaEsperienza(dopo e:, cliente:) -> EsperienzaSala?`: funzione **pura** in `EsperienzaSala`
     (`static func prossima(dopo:fatte:consigliate:) -> EsperienzaSala?`) con le regole di 60.1 (primo momento dopo con
     una libera, poi lo stesso momento, mai i momenti prima; l'ordine dentro un momento scritto esplicito come nel
     template, film prima del Prisma del cliente), usando `momento` e `consigliate(priorita:)` della 34 (le consigliate
     già in cache, `"sala-consigliate|\(id)"` del gruppo 05); testabile senza stato.
3. **Il segno automatico**: chiamare `segnaEsperienza(…, avviso: false)` nei punti di fine che esistono già, non
   guardando il testo dei pulsanti come il template:
   - capsula: dopo `sigillaCapsula` riuscito e dopo la consegna di una capsula aperta;
   - disegno: quando il modulo «Salva come obiettivo» salva davvero l'obiettivo;
   - Prisma del cliente: in `preparaPrismaCliente` riuscito (o in `registraUscitaPrismaCliente`);
   - film: in `registraUscitaFilm` o a esportazione riuscita (`esportaOra` → true);
   - gioco del rischio: in `salva(_:)` (SalaGiocoRischio.swift:442), cioè con «Salva nel dossier» confermato — la
     partita oggi **non** si salva da sola al risultato (decisione 60-b: il template non lo segna affatto);
   - le altre (prisma di luce, lettera, giornata, Lancia l'anno, quanto vale, realtà aumentata) solo con «Segna come
     fatta», salvo «✦ Aggiungi al Prisma di …» per la lettera e la giornata (decisione 60-b).
4. **I pulsanti nel palco** (in `AzioniPalco` della 59, dopo «Cosa dire»): «Segna come fatta» (`.apple`) oppure
   l'etichetta «✓ Fatta oggi» (lo stile delle etichette di stato positive del tema; se non c'è un componente, crearlo in
   DesignSystem come `EtichettaStato(.ok)`, token sotto) e «Prossima: <titolo> ›» (`.applePrimario`) che apre
   l'esperienza con la stessa animazione della griglia (`sala.esperienza = prossima`, rispettando
   `puoTornareAllaSala()` per il gioco del rischio a metà). Condizione di visibilità: `consulenteVede` (59).
5. **La griglia** (`SchedaPiccolaSala`, `SchedaGrandeSala`): parametro `fattaOggi: Bool`; con le indicazioni accese
   (cliente scelto, fuori dalla vista del cliente: lo stesso `indicazioni` della 34) l'etichetta «✓ Fatta oggi» in
   `overlay(alignment: .topTrailing)` a 44 dall'alto e 14 da destra, sotto quella del momento. La griglia legge
   `esperienzeFatteOggi` **una volta** e passa il booleano alle schede.
6. **L'occhiello della Sala** (il `#wSub` del template; l'app non ha un sottotitolo della finestra, vedi 60.2): in
   `IntestazioneApp.riga` (ContenutoApp.swift:220-229) un caso `.sala` accanto a `.mercato`, con una sottovista
   piccola `OcchielloSala` che legge `esperienzeFatteOggi` del cliente attivo (ricavato) e, con almeno una esperienza
   fatta oggi, scrive «Un’esperienza fatta oggi con <Nome>» / «<n> esperienze fatte oggi con <Nome>» (nome breve,
   `StatoShell.nomeBreve`), in maiuscolo come ogni occhiello; altrimenti `AppPrisma.occhiello` di oggi. Non nella vista
   del cliente né in modalità cliente; su iPad l'occhiello resta quello di oggi. Se c'è già la miglioria 4 del gruppo
   01, il caso va nella riga sola della finestra (`FinestraInterna.barraTitolo`), che riprende titolo e occhiello.
   Testi in `TestiEsperienzeFatte`. (L'occhiello è la prima cosa che sparisce in una finestra stretta: va bene, il
   segno resta sulle schede.)
7. **La riga nel dossier** (decisione 60-a): proposta, un riquadro «In Sala» come `UsciteDelCliente`
   (Shell/UsciteCliente.swift:140, che oggi filtra `dati.uscite` nel body con `usciteCliente`: per il nuovo riquadro
   usare invece il ricavato del punto 2), nella Panoramica del dossier del tema Apple (`PanoramicaDossierApple`,
   Shell/DossierPanoramica.swift:18, accanto a «Da ricordare» e «Prossimo incontro»; sotto c'è `PanoramicaCliente`,
   AppClienti.swift:614) (oppure accanto a «Dato al cliente» in Documenti, ClienteDocumenti.swift:67). Strumento del
   consulente: in modalità cliente non c'è, come la card dei dati per l'analisi. Con le ultime esperienze
   (data breve, titolo dell'esperienza), al più 5 (token `quante`), che non compare se non ce ne sono. Un clic su una
   riga apre quell'esperienza nella Sala (`apriEsperienza(_:cliente:)`). Riusare i token di `Tema.Apple.UsciteCliente`
   se uguali, altrimenti `Tema.Apple.SalaEsperienze.Fatte`.
8. **Token** in `Tema.Apple+SalaEsperienze.swift`, `enum Fatte`: `etichetta` 11,5 bold, padding 3×9, capsula, `fondo`
   verde al 15%, `testo` verde scuro (#1F7A41) e in scuro (#6FD08E) — se il tema ha già i verdi di stato (le
   etichette «In tempo» degli obiettivi, gruppo 02 miglioria 13), usare quelli —, `dallAlto` 44, `daDestra` 14.

**Non fare**: non riconoscere la fine di un'esperienza dal testo dei pulsanti (fragile); non segnare nulla dalla vista
del cliente sul Mac senza che il consulente lo veda (il segno automatico va bene: avviene su un'azione del consulente);
non salvare risposte, disegni o testi dentro `EsperienzaFatta`; non mostrare «✓ Fatta oggi» e il sottotitolo nella
vista del cliente.

### 60.4 Dati, archivio, privacy

- **Campo nuovo** `DatiPrisma.esperienzeFatte` (chiave `esperienzeFatte`), nella **versione 27** se si accettano
  campi nuovi letti con tolleranza senza cambiare versione (come i giri di «Luce»), altrimenti 28 con la conversione;
  le prove di backup oggi controllano `versioneAttuale == 27` in molti file (Dati/ProvaBackup*.swift): restare a 27
  evita di toccarle tutte.
- **Posto in ArchivioPezzi**: `.cliente` (ha il `clienteId`: va nel file del cliente, accanto a `uscite` e `lettere`;
  l'elemento di un cliente eliminato in `senza-cliente.json` come gli altri). Aggiungere la chiave allo `switch` di
  `pezzo` (Dati/ArchivioPezzi.swift:56-63), all'elenco `.elenco(.esperienzeFatte, \.esperienzeFatte)` (riga ~124) e ai
  due `switch` di confronto e copia (righe ~215 e ~274). Eliminando un cliente le sue esperienze fatte si tolgono
  come le uscite (StatoShell.swift:992).
- **Backup**: sì, come il resto del file del cliente. Aggiornare l'elenco di ciò che il backup comprende in CLAUDE.md
  («da «Migliorie d'uso» le esperienze della Sala fatte con il cliente: data ed esperienza, mai il contenuto»).
- **«Prisma ovunque»**: proposta **no** (come `uscite` e `lettere`: è una nota di lavoro del Mac; sull'iPhone la Sala
  non c'è e sull'iPad non si segna). **Non basta non fare nulla**: ogni campo di `DatiPrisma` entra nell'istantanea
  dello spazio se non lo si toglie. Quindi `x.esperienzeFatte = []` in `SpazioOvunque` (Dati/SpazioOvunque.swift:178,
  accanto a `x.uscite = []`) e `nuovo.esperienzeFatte = locale.esperienzeFatte` all'unione dell'istantanea (riga 520),
  perché sull'iPad un'istantanea senza il campo non cancelli nulla di locale. Se l'utente la vuole sull'iPhone, va
  nell'istantanea in sola lettura, mai nel giornale.
- **Unione delle schede** («Unisci le schede», `Cliente.unitaIn`): le esperienze fatte seguono il cliente che resta,
  come le uscite: `spostaTagliando(\DatiVivi.esperienzeFatte, …)` nell'unione e nell'annullamento, e il campo nella
  struttura che ricorda cosa è stato spostato (Shell/CollegaTagliandoShell.swift:480, 714, 961-1039). Due esperienze
  uguali nello stesso giorno dopo l'unione restano due righe (non si fondono).
- Privacy: solo chi, cosa, quando; nessuna risposta del gioco del rischio, nessun testo. Non esce dal Mac.

### 60.5 Istantanee e prove

- Nuove scene in `Shell/IstantaneeLuce.swift`, chiare e scure: **«686-sala-fatta-prossima»** (Marco, gioco del rischio
  segnato: «✓ Fatta oggi» e «Prossima: … ›»), **«687-sala-griglia-fatte»** (griglia con due esperienze fatte oggi e il
  sottotitolo «2 esperienze fatte oggi con Giulia»), **«688-dossier-in-sala»** (il riquadro nel dossier).
- Da aggiornare: «690-sala-griglia» (nessun segno se nulla è fatto: i dati di prova non devono averne), «691-sala-palco»
  («Segna come fatta»), la vista del cliente sulla Sala (gruppo 01: nessun segno).
- Prove:
  - `--prova-backup`: nuova `ProvaBackupEsperienzeFatte` (o un caso in `ProvaBackupSala`, Dati/ProvaBackupSala.swift):
    il campo va e torna da backup e ripristino, sta nel file del cliente, un'esperienza sconosciuta si scarta, un
    archivio di prima senza il campo si legge; e `ProvaBackupArchivioPezzi` con la chiave nuova al suo posto.
  - `--prova-ovunque` (Dati/ProvaOvunque.swift, dove già c'è `telefono.uscite = []`, riga 637): l'istantanea dello
    spazio **non** contiene `esperienzeFatte` (se la decisione è «no») e l'unione non cancella quelle locali.
  - La prova dei campi di `DatiVivi` (`numeroCampi` contro Mirror) con 54.
  - Una prova del tagliando: «Unisci le schede» sposta le esperienze fatte e l'annullamento le rimette.
  - `--prova-calcoli` (`ProvaCalcoliEsperienza`): `EsperienzaSala.prossima(dopo:fatte:consigliate:)` — il momento dopo,
    la consigliata preferita, lo stesso momento quando i dopo sono finiti, nil quando non resta nulla; il segno una
    volta al giorno.
  - `--prova-fluidita`: la griglia non rifà il filtro su tutto l'archivio a ogni scheda (ricavato in cache).

### 60.6 Decisioni per l'utente e rischi

- **60-a · Dove sta «la riga nel dossier».** Il template non lo mostra. Proposta: un riquadro «In Sala» in cima alla
  Panoramica (con le ultime cinque); alternativa: accanto a «Dato al cliente» in Documenti, o una riga nella cronologia
  degli incontri.
- **60-b · Quando si segna da sola.** Il template elenca Sigilla, Salva come obiettivo, Prepara il file, Manda, Esporta,
  Apri e consegna. Proposta: quelli (sui punti di fine del codice) **più** il gioco del rischio a «Salva nel dossier»
  confermato (la partita non si salva da sola: senza salvataggio si segna con «Segna come fatta»). Alternativa: segnare
  il rischio già all'arrivo al risultato, anche senza salvare. «✦ Aggiungi al Prisma di …» non segna (aggiungere al file
  non vuol dire averla fatta col cliente).
- **60-c · «Fatta oggi» o «fatta».** Il template ragiona per giorno (la prossima esclude solo quelle di oggi). Proposta:
  così; il riquadro nel dossier tiene lo storico con le date. Una seconda volta in un altro giorno lascia una seconda
  riga.
- **60-d · Togliere un segno.** Il template non lo prevede. Proposta: nel riquadro del dossier, menu contestuale
  «Togli» su una riga (un errore di clic non resta per sempre).
- **60-e · Prisma ovunque.** Proposta: no (vedi 60.4).
- Rischi: il filtro delle esperienze fatte su tutti i clienti nel body della griglia (va nel ricavato per cliente e
  giorno, con nella chiave ciò che cambia a ogni segno: vedi 60.3 punto 2, altrimenti il segno non si vede); il campo nuovo tocca l'archivio a pezzi e quindi le prove di backup (un campo senza posto non compila, ed è
  voluto); il segno automatico non deve scattare nelle istantanee e nelle prove dei palchi (gli stati di prova non
  chiamano le funzioni di fine).

### 60.7 Dimensione

**M** (circa 350 righe). File principali: Dati/EsperienzaFatta.swift (nuovo), Dati/DatiPrisma.swift, Dati/DatiVivi.swift,
Dati/ArchivioPezzi.swift, Shell/StatoSala.swift (o Shell/StatoEsperienzeFatte.swift nuovo), Shell/AppSala.swift,
Shell/SalaCapsula.swift, Shell/SalaDisegna.swift, Shell/StatoPrismaCliente.swift, Shell/StatoFilm.swift,
Shell/SalaGiocoRischio.swift, la Panoramica del dossier (Shell/DossierPanoramica.swift), Shell/ContenutoApp.swift
(l'occhiello), Shell/StatoShell.swift (eliminaCliente), Shell/CollegaTagliandoShell.swift, Dati/SpazioOvunque.swift,
DesignSystem/Apple/Tema.Apple+SalaEsperienze.swift, Shell/IstantaneeLuce.swift, Dati/ProvaBackupSala.swift,
Dati/ProvaOvunque.swift, Motori/ProvaCalcoliEsperienza.swift.

---

## Il pannello «✦ Migliorie»

Il pannello del template (`MIG10`, righe 4812-4817, con i cartellini `indica(…)` e le frasi «Prima … Ora …») serve solo
a presentare le migliorie all'utente: **nell'app non va portato**. Allo stesso modo le cifre e i nomi dei clienti del
template (Marco, Giulia) sono dimostrativi: nell'app valgono i clienti dell'archivio e le cifre dei motori.
