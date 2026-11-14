# Gruppo 03 — Agenda, Incontri, Prospetti (migliorie 18-24)

Fonte: Design/template-uso.html («Prisma · Migliorie d'uso · Mac», 14 novembre 2026), letto nella copia senza immagini
Design/uso/.template-senza-immagini.html. Le righe citate sono di quella copia: le regole del gruppo nel commento a
righe 2672-2707, il codice a righe 3690-3880 (MIGLIORIA 18-24, «TERZO GIRO»), il pannello «✦ Migliorie» (`MIG3`) a riga
3870. La base che le migliorie ridefiniscono è a righe 1220-1240 (Agenda, `APPS.agenda`, `giorno`, `apriEv`), 1272-1301
(Prospetti) e 1517 (Incontri, con l'aggiunta di «Luce» a riga 2575). Per ciò che qui non cambia valgono «Luce»
(Design/template-luce.html e Design/template-luce-specifica.md), il copilota di Design/template-novita-specifica.md §8 e,
sotto, il tema Apple (Design/template-apple-specifica.md §4.4 Agenda, §4.5.1 Prospetti).

Regole che valgono per tutto il gruppo:

- **Solo Mac.** `AppAgenda`, `AppIncontri`, `CopilotaIncontro` e `AppProspetti` servono anche l'iPad (e, per Incontri,
  l'iPhone). Le viste nuove vanno sotto `#if os(macOS)` o dietro un parametro che l'iPad non usa: iPhone e iPad restano
  come sono, il loro giro viene dopo. Sull'iPad restano le quattro viste dell'Agenda di oggi, il copilota a tutta
  finestra e le scelte del documento di oggi.
- **La grafica non cambia.** Tema Apple, superfici, caratteri, colori dei clienti e dei canali restano; si spostano e si
  raccolgono cose che ci sono già. Ogni misura o colore nuovo diventa un token in `Sources/Prisma/DesignSystem/Apple/`
  (`Tema.Apple+Agenda.swift`, `Tema.Apple+Copilota.swift`, `Tema.Apple+Prospetti.swift`), mai un numero nel codice.
- **Le cifre e i testi di prova del template non si portano**: `EV`, `OCC`, `INC_FATTI`, `VERB_OGGI`, `DOMANDE`, i
  prospetti «per te» di `PAG[1..3].te` (righe 3836-3856: tabelle, ipotesi, «164.000 €»…), `docDisp`, `consP`. Le cifre le
  danno i motori e i compositori che ci sono (`CompositoreProspetti`, `ProspettoCheckUp`, `ReportObiettivo`, …), gli
  impegni l'archivio, i verbali il copilota (`SessioneCopilota`, `ApplicaCopilota`).
- **Il pannello «✦ Migliorie»** (`MIG3`, `indica(...)`, i cartellini numerati) è solo del template: nell'app NON va
  portato. Lo stesso vale per i `toast(«… resta com'è»)` e per i `toast` «Nel template…»: dicono che lì l'app tiene il
  comportamento di oggi, o che il template ha solo dati di prova.
- **Movimento:** gli impegni della settimana entrano a cascata come le righe di oggi (`entrataCascata`, ritmo
  `Tema.Apple.Moto.ritmo`, `ritardoPrisma`, niente sfocatura); il cambio di momento in Incontri e di versione in
  Prospetti usano le transizioni che ci sono (`Tema.Apple.Moto.CambioScheda`, `.cambioPagina`). «Riduci movimento»
  (`\.prismaCalmo`) = tutto fermo con dissolvenza di 0,15 s; istantanee (`\.modoIstantanea`) nello stato finale; la riga
  dell'ora nelle istantanee usa `OraIstantanee.data`. Niente Timer: la riga dell'ora resta `TimelineView(.everyMinute)`.
- **Prestazioni:** niente filtri, ordinamenti o motori su tutto l'archivio nei body. La settimana riusa l'indice dei giorni
  che l'Agenda già costruisce (`indiceGiorni`), l'elenco di Incontri passa da `stato.ricavato`, l'elenco dei documenti da
  costanti.

## Ordine consigliato

1. **18 · La settimana si vede tutta.** Si può partire subito, per la parte grande (sette colonne, intestazioni, impegni
   passati «da chiudere»). Introduce il piccolo motore `MomentoImpegno` (prima / da chiudere / chiuso) che 19 e 21 usano.
   Due pezzi dipendono dal gruppo 01: la striscia «Riesami del mese» sparisce solo dopo **un solo «Da fare»** (miglioria
   3: i riesami diventano voci di quell'elenco) e la tendina dei clienti esce dalla barra solo dopo **un solo posto per
   il cliente** (miglioria 2). «Mese» nel selettore resta quello di oggi finché non arriva la miglioria 50 (gruppo 08).
   La fascia «Da fare e da ricordare» della giornata diventa «Da fare oggi» con la miglioria 3 (gruppo 01, 3.3 punto 9):
   la settimana non la mostra comunque (decisione 18-c). Il numero sul pulsante «Occasioni» usa la pillola
   `NumeroOcchielloApple` che nasce con la miglioria 25 (gruppo 04): chi arriva prima la crea in `DesignSystem/Apple/`.
2. **21 · Incontri segue il cliente** e **20 · Tre momenti**, insieme, in un solo giro: toccano gli stessi file
   (`AppIncontri.swift`, `CopilotaIncontro.swift`, `VerbaleCopilota.swift`). Prima l'elenco a sinistra (21), poi i tre
   momenti a destra (20). La 21 dipende dalla miglioria 2 (il cliente della barra, con «Tutti i clienti»); finché non
   c'è, segue `stato.clienteAttivoId` senza la vista di tutti. Il «?» con «Come funziona» è la miglioria 6 del gruppo 01.
3. **19 · Un impegno passato chiede com'è andato**: dopo la 18 (usa `MomentoImpegno`) e dopo la 20 («Scrivi il verbale»
   porta al momento «Dopo»). Nello stato «prima» il pulsante «Presenta al cliente» diventa «Mostra al cliente» con la
   miglioria 1 del gruppo 01 (regola 1).
4. **22 · «Per te» e «Per il cliente»**, **23 · L'elenco dei documenti** e **24 · Tre pulsanti**, insieme, in un solo
   giro: sono la stessa schermata (`ProspettiApple.swift`, `AppProspetti.swift`). La 24 dipende dal gruppo 01:
   **«Mostra al cliente»** (miglioria 1: il pannello con «a tutto schermo» e «l'iPad sul tavolo», che prende il posto di
   «Presenta all'incontro» e «Al tavolo») e **la riga sola in testa alla finestra** (miglioria 4: lì vanno i tre
   pulsanti). Senza la miglioria 1, «Mostra al cliente» chiama per ora la presentazione di oggi (`presentaApple`).

Più avanti altre migliorie toccano le stesse viste e partono da qui: 50 (Agenda › Mese, gruppo 08), 51 (il giro del
Territorio prepara Incontri › Prima, gruppo 08), 25 (Messaggi: il «riepilogo» scritto dal momento «Dopo», gruppo 04), 58
(gruppo 10: «Un solo modo di mostrare» toglie `PulsanteAlTavolo` e `PannelloAlTavolo` dai Prospetti contando sulla 24, e
`PulsanteTavoloSala`/`StrisciaTavoloSala` dalla presentazione).

Le parole: la miglioria 10 del gruppo 01 crea `enum Parole` (`Shell/ParolePrisma.swift`) con «Mostra al cliente»,
«Preparami l'incontro», «Per il cliente», «Per te», «Da fare», «Tutti i clienti»; i testi di questo gruppo che sono
in quella tabella si prendono da lì (se la 10 non c'è ancora, si aggiungono lì). La stessa tabella toglie «Prepara con
Eve/Vera» e «Prepara l'incontro» (resta «Preparami l'incontro»): vale per la scheda dell'impegno (19), per il dettaglio
di «Giorno» e per Incontri › Prima (20).

---

## 18. La settimana si vede tutta

### 18.1 Nel template

Righe 3694-3720 (`vistaAg`, `settimanaHTML`, `montaSettimana`, la ridefinizione di `APPS.agenda`), CSS a righe 581-600,
regola a righe 2672-2677.

- **Barra della finestra** (`A.act`, riga 3715): il selettore a pillola diventa «Giorno | Settimana» (nella regola
  «Giorno | Settimana | Mese», con «Mese» della miglioria 50). Accanto, fuori dal selettore, il pulsante «Occasioni» con
  il numero in un piccolo tondo (`bN2`) quando ce ne sono; poi «＋ Nuovo impegno» (blu, com'è). La vista che si apre è
  «Settimana» (`vistaAg='sett'`).
- **Colonna a sinistra**: resta quella di «Luce» (mese piccolo con i puntini, «Questa settimana» con impegni, clienti e
  ore, il «Da fare»). Toccando un giorno del mese piccolo si apre quel giorno in «Giorno» (riga 3712).
- **La settimana** (`settimanaHTML`, riga 3705) prende il posto della giornata a destra:
  - in testa (`.sTesta`, alta 48) i sette giorni: «Oggi · lun 2», poi «mar 3», «mer 4»…; sotto ciascuno, in piccolo,
    «1 impegno», «N impegni» oppure «libero». Il nome di oggi è rosso. Sabato e domenica sono colonne più strette
    (0,62 di una feriale). Toccando l'intestazione di un giorno si apre quel giorno in «Giorno»;
  - sotto, una card senza ombra con le ore dalle 08:00 alle 19:00 a sinistra (righe ogni ora, alte 52) e sette colonne
    separate da un filo; la colonna di oggi ha un fondo rosso al 5%, sabato e domenica un fondo grigio leggerissimo;
  - nella colonna di oggi la riga rossa dell'ora (alta 2, con il pallino a sinistra);
  - ogni impegno sta al suo posto e alla sua altezza (minimo 38): fondo nel colore del cliente al 13%, filo sinistro di
    3 nel colore, nome del cliente in neretto (o il titolo, senza cliente) e sotto «09:30 · In studio». Un impegno
    passato e non chiuso è attenuato (opacità 0,62) e dice «09:30 · da chiudere»; uno chiuso è attenuato e dice
    «09:30 · ✓ tutto fatto» (la spunta e l'esito in minuscolo). Al passaggio del puntatore l'impegno si ingrandisce
    appena (1,03). Al tocco si apre la sua scheda (`apriEv`, vedi miglioria 19);
  - gli impegni entrano a cascata dal basso (14 punti, 45 ms l'uno dall'altro); con «Riduci movimento» compaiono fermi.
- **«Giorno»** resta la giornata di oggi in grande (la base: righe 1226-1236). Lì gli impegni passati sono attenuati e
  portano « · da chiudere» o « · ✓ <esito>» dopo l'orario (riga 3720).
- **«Occasioni»** (`#agOcc`, riga 3717) apre un menu sotto il pulsante con una riga per occasione:
  «Marco Bianchi · la polizza a premio unico non ha più penali di riscatto»; senza occasioni «Nessuna occasione, per
  ora». Al tocco di una riga il template dice solo «Da un'occasione si fissa un impegno o un'attività, come oggi».
- **Segue il cliente scelto** (`evDi`, `occDi`): con un cliente nella barra la settimana mostra solo i suoi impegni e le
  sue occasioni, e le intestazioni contano solo i suoi.
- **Sparisce** la riga «Riesami del mese» sopra il calendario (regola 18: sono voci del «Da fare», regola 3).

### 18.2 Nell'app oggi

- `Sources/Prisma/Shell/AppAgenda.swift:13` `AppAgenda`: barra (`rigaBarra`, :206) con frecce e «Oggi», periodo,
  riepilogo, selettore a pillola con **quattro** viste nell'ordine «Mese | Settimana | Giorno | Occasioni» (:207),
  `MenuTendina` dei clienti (`stato.filtroClienteAgenda`), «Attività» e «Nuovo impegno». La vista predefinita è
  `.mese` (`StatoShell.swift:258`, `VistaAgenda` a :12).
- Sotto la barra la striscia «Riesami del mese» (`striscia(...)`, :46; `RiesamiAgenda.swift`, `stato.riesamiDelMese`).
- `vistaSettimana` (:310) **non** mostra la settimana: è la barra laterale (`BarraLateraleAgendaApple`,
  `AgendaApple.swift:248`) più le sette pillole dei giorni (`SegmentatoPillola` con `vociSettimana`), il titolo del giorno
  e **una sola** giornata (`GiornataImpegniApple`, `AgendaApple.swift:496`). È esattamente il «prima» del template.
- `vistaGiorno` (:333): la giornata in grande più la colonna del giorno con il dettaglio (`DettaglioAppuntamento`, :1027).
- `vistaOccasioni` (:357): l'elenco delle occasioni di 12 mesi (`ElencoOccasioniAgenda`, `AgendaOccasioni.swift:504`;
  dati da `stato.elencoOccasioniAgenda`, `AgendaOccasioni.swift:49`) con il dettaglio a destra.
- I pezzi riusabili ci sono: le ore e la riga dell'ora (`OreGiornataApple`, `AgendaApple.swift:524`, privata), le corsie
  per gli impegni sovrapposti (`CorsieImpegni.disponi`, :665), l'impegno con nome, orario, canale e opacità del
  concluso (`ImpegnoGiornataApple`, :706, che apre la traccia con `origineDettaglio`), l'indice dei giorni
  (`indiceGiorni`, `GiorniAgenda`), il calendario (`CalendarioAgenda.giorni(settimanaDi:)`).
- Un impegno concluso è solo attenuato (`Tema.Apple.Agenda.Giornata.opacitaConcluso` 0,55): manca la scritta «da
  chiudere» per quelli passati e non segnati, e manca l'esito sull'impegno.
- Le ore della giornata ci sono già come token e regola: `Giornata.primaOra` 8, `ultimaOra` 19, `altezzaOra` 46,
  `impegnoMinimo` 40, `impegnoStacco` 4, `spazioCorsie` 6, `coloreLinea`/`spessoreLinea`/`pallinoOra` della riga
  dell'ora, e `OreGiornataApple.intervallo(_:)` (`AgendaApple.swift:558`, allarga 8-19 se un impegno esce dall'orario).
  La riga dell'ora è in `TimelineView(.everyMinute)` e nelle istantanee `OraIstantanee.data` (`Istantanee.swift:1885`).
- «Passato e senza esito» esiste già come regola: le notifiche (`Shell/Notifiche.swift:68-87`) chiedono «Com'è andato
  «<titolo>»?» per ogni appuntamento `.pianificato` con `fine <= adesso` (ultimi `giorniAvanti` giorni), con la proposta
  collegata se `MotoreSeguitoProposte.tipiConEsito` (proposta, firma) e `posizioneId`; la voce porta a
  `.appuntamento(id)`. Questa regola non esclude i blocchi «Non disponibile»: `MomentoImpegno` sì (punto 1), e va
  allineata anche la notifica (o la voce del «Da fare» della miglioria 3) per non chiedere l'esito di un blocco.
- L'apertura di un appuntamento da notifiche e ricerca (`Shell/Ricerca.swift:719`, `case .appuntamento`) mette
  `giornoAgenda` e `appuntamentoSelezionato` ma **non cambia la vista**: oggi funziona perché «Mese» ha la colonna del
  dettaglio; la settimana nuova non ce l'ha (punto 4).
- Le occasioni hanno già una finestra «prossima»: `impostazioni.occasioni.anticipoGiorni` (30 di base, scelta in
  Impostazioni › Promemoria e occasioni), la stessa delle notifiche e di `mostraOccasione(_:)`
  (`AgendaOccasioni.swift:76`, che però azzera `filtroClienteAgenda`).

### 18.3 Cosa fare

1. **Il momento di un impegno.** Nuovo file `Sources/Prisma/Motori/MomentoImpegno.swift`:
   `enum MomentoImpegno { case prima, daChiudere, chiuso }` con
   `static func di(_ a: Appuntamento, adesso: Date) -> MomentoImpegno`: `chiuso` se `a.stato == .concluso`; `daChiudere`
   se `a.stato == .pianificato`, `a.fine <= adesso` (la stessa regola delle notifiche, `Notifiche.swift:76`),
   `a.tipo != .nonDisponibile` e `!a.clienteId.isEmpty`; altrimenti `prima` (un blocco «Non disponibile» passato non
   chiede niente: è solo attenuato, `passato` = `a.fine <= adesso`). Più `static func esitoBreve(_ a:, proposta:
   Posizione?) -> String?` per un impegno chiuso: se la proposta collegata ha `seguito?.appuntamentoEsitoId == a.id`,
   il suo esito in minuscolo dai testi di `TestiSeguito` («accettata», «rimandata», «rifiutata»; «ci deve pensare» se è
   rimasta `.presentata`), altrimenti «concluso»; la spunta «✓ » la mette la vista. La proposta la passa chi chiama
   (letta dall'indice o da una mappa per id fatta una volta, mai cercata in `dati.posizioni` per ogni impegno). Lo usano
   18, 19 e 21.
   **L'ora che passa senza Timer:** «da chiudere» deve comparire quando l'impegno finisce, anche se nient'altro si
   rifà. Le righe di oggi leggono `adesso` da una `TimelineView(.explicit(fini))` con le `fine` degli impegni di oggi
   ancora da venire (si rifà solo a quegli istanti, non ogni minuto); gli altri giorni usano `Date()` del body (il
   passato non cambia). Nelle istantanee `adesso = OraIstantanee.data()`.
2. **Il selettore.** In `AppAgenda.rigaBarra` (:205-207) le voci diventano `[(.giorno, "Giorno"), (.settimana, "Settimana"),
   (.mese, "Mese")]`, solo sul Mac (sull'iPad resta l'elenco di oggi). `VistaAgenda.occasioni` resta come caso interno,
   raggiunto solo dal pulsante (punto 6). La vista predefinita sul Mac diventa `.settimana` (decisione 18-a).
3. **La settimana.** Nuovo file `Sources/Prisma/Shell/AgendaSettimana.swift` (solo macOS) con:
   - `SettimanaAgendaApple: View` (giorni della settimana, `GiorniAgenda`, adesso, `seleziona(giorno)`,
     `apriGiorno(giorno)`): testata a griglia + card con le ore + sette colonne, in un solo `ScrollView` verticale per
     tutte le colonne, con la testata fissa sopra. Larghezze: feriali uguali, sabato e domenica a
     `SettimanaSette.quotaFestivo` (0,62). Le ore: `OreGiornataApple.intervallo(_:)` sugli impegni di tutta la settimana
     (portarla fuori dalla struct privata), così un impegno alle 20 allarga tutte le colonne insieme; il template
     disegna 08:00-19:00, che è già `primaOra`/`ultimaOra`.
   - `IntestazioneGiornoSettimana`: «Oggi · lun 2» (oggi in `Colore.rosso`) / «mar 3» e sotto «libero», «1 impegno»,
     «N impegni» (contati dall'indice, già filtrati per cliente). È un pulsante: `stato.giornoAgenda = giorno;
     stato.vistaAgenda = .giorno`.
   - `ColonnaGiornoSettimana`: gli impegni dell'indice di quel giorno disposti con `CorsieImpegni.disponi`, l'altezza
     ora dal token, la riga dell'ora nella colonna di oggi (stessa logica di `OreGiornataApple.lineaOra`: portarla in una
     funzione condivisa invece di copiarla), il fondo di oggi e del fine settimana.
   - `ImpegnoSettimanaApple`: versione stretta di `ImpegnoGiornataApple` (nome in neretto su una riga, sotto «09:30 · In
     studio» o «09:30 · da chiudere» o «09:30 · ✓ concluso»; l'etichetta del canale solo se la colonna è larga almeno
     `Giornata.larghezzaConCanale`, altrimenti il filo del colore del canale resta riconoscibile come oggi). Opacità
     `SettimanaSette.opacitaPassato` per `daChiudere` e `chiuso` (e per un blocco «Non disponibile» passato). Stesso `origineDettaglio(id: TracciaImpegnoApple.id(...))` e
     stessa preparazione dei punti (`stato.puntiDaToccare`) prima di aprire: la traccia nasce dall'impegno come oggi.
     Inclinazione come l'impegno di oggi (`.inclinazione`); niente scala al passaggio se l'inclinazione basta.
   - Ingresso a cascata con `entrataCascata(i, sfocatura: false)` (al più `Settimana.massimoCascata` impegni, gli altri
     compaiono con l'ultimo): 14 punti dal basso, 45 ms l'uno dall'altro × ritmo, senza sfocatura.
4. **`vistaSettimana`** in `AppAgenda` diventa: `BarraLateraleAgendaApple` (com'è) + `SettimanaAgendaApple`. Sotto la
   soglia `SettimanaSette.sogliaLaterale` di larghezza la barra laterale non si mostra (la finestra stretta tiene la
   settimana). Le pillole dei giorni e la giornata singola escono da questa vista. Toccando un giorno del mese piccolo
   della barra laterale si apre quel giorno in «Giorno» (template riga 3712: `seleziona` + `vistaAgenda = .giorno`).
   Siccome la settimana non ha la colonna del dettaglio, `vai(.appuntamento(id))` (`Ricerca.swift:719`) mette anche
   `vistaAgenda = .giorno` quando la vista è `.settimana`, così notifiche, ricerca e «Da fare» mostrano ancora il
   dettaglio di quell'appuntamento.
5. **`vistaGiorno`** resta com'è (giornata in grande e colonna del giorno). Nella giornata `ImpegnoGiornataApple` aggiunge
   « · da chiudere» o « · ✓ <esito>» dopo l'orario, con `MomentoImpegno`, e usa la stessa opacità del passato della
   settimana: nel template `.ev.pas` e `.evS.pas` sono entrambi a 0,62 (CSS riga 598), quindi
   `Giornata.opacitaConcluso` passa da 0,55 a 0,62 e vale per `daChiudere` e `chiuso` (un solo token, letto anche da
   `SettimanaSette.opacitaPassato`).
6. **«Occasioni».** Nella barra, dopo il selettore, un pulsante `.apple` «Occasioni» con il numero nella pillola
   `NumeroOcchielloApple` (gruppo 04, miglioria 25; nel template `.bN2`: 11 bold, fondo `chip`, testo `inchiostro2`,
   capsula 1×7) solo quando è più di zero; il numero sono le occasioni da oggi a oggi + `anticipoGiorni` (la finestra
   delle notifiche, 30 di base, decisione 18-b) del cliente scelto (`filtroClienteAgenda`), letto da
   `stato.ricavato("agenda-occasioni-prossime|<cliente>|<anticipo>")` (il giorno è già nella validità della cache).
   Al tocco un `popover` nello stile del tema Apple con una riga per occasione («<nome> · <occasione>», i testi di
   `Occasione` di oggi), «Nessuna occasione, per ora» se vuoto, e in fondo «Tutte le occasioni ›» che apre la vista
   `.occasioni` di oggi (12 mesi, con il dettaglio). Toccando una riga: `giornoAgenda = oggi`, `vistaAgenda =
   .occasioni`, `occasioneSelezionata = occasione`, **senza** azzerare il filtro del cliente (non chiamare
   `mostraOccasione`, che lo azzera); lì si fissa l'impegno o l'attività come oggi. Il template al tocco dice solo «Da
   un'occasione si fissa un impegno o un'attività, come oggi»: nell'app quel testo non serve.
7. **Riesami del mese.** Quando la miglioria 3 del gruppo 01 è fatta, togliere `striscia(...)` e `memoriaRiesami` da
   `AppAgenda.body` (i riesami sono voci del «Da fare»). Non togliere `RiesamiAgenda.swift`: i calcoli servono al «Da
   fare» e a «Pianifica».
8. **Tendina dei clienti.** Con la miglioria 2 la `MenuTendina` esce dalla barra e `filtroClienteAgenda` legge il
   cliente scelto nella barra di Prisma. Fino ad allora resta.
9. **Token nuovi** in `Tema.Apple+Agenda.swift`, nuovo `enum SettimanaSette` (il nome `Settimana` è già preso dalle
   pillole di oggi; chi rinomina, rinomini tutto): `altezzaTesta` 48, `altezzaOra` 52 (la giornata resta 46),
   `quotaFestivo` 0.62, `raggioIntestazione` 12, `fondoOggi` (`Colore.rosso` al 5%), `fondoFestivo` (inchiostro al 2%,
   scuro al 2,5%), `impegnoMinimo` 38, `filoImpegno` 3, `raggioImpegno` 10, `paddingImpegno` 4×8, `margineColonna`
   4/5, `nomeImpegno` (12,5 bold), `sottoImpegno` (11, `inchiostro2`), `intestazioneGiorno` (13,5 bold; oggi in
   `Colore.rosso`), `notaGiorno` (11,5 `inchiostro2`), `rientroOre` 54, `sogliaLaterale`, `massimoCascata`,
   `cascataSpostamento` 14 e `cascataPasso` 0,045 s (per `Tema.Apple.Moto.ritmo`), `scalaPassaggio` 1,03 se si tiene.
   Riusati, non copiati: `opacitaPassato = Giornata.opacitaConcluso` (0,62, punto 5), `primaOra`/`ultimaOra`,
   `spazioCorsie`, `opacitaFondo` 0,13, la riga dell'ora (`coloreLinea`, `spessoreLinea` 2; il pallino del template è
   8: `pallinoOraSettimana`). I colori vengono da `Colore` del tema, mai esadecimali qui.
10. **Testi** (in `TestiAgendaApple`): `"Oggi · \(giorno)"`, `"libero"`, `"1 impegno"`, `"\(n) impegni"`,
    `"da chiudere"`, `"Occasioni"`, `"Nessuna occasione, per ora"`, `"Tutte le occasioni"`.

Cosa NON fare: non portare le cifre di «Questa settimana» del template (9 impegni, 6 clienti, 7 ore: le dà
`RiepilogoSettimanaAgenda`), né le occasioni `OCC`, né `adesso()` che ferma l'ora alle 10:24 fuori orario (nell'app l'ora
è quella vera, e nelle istantanee `OraIstantanee`). Non togliere la vista Mese approvata.

### 18.4 Dati, archivio, privacy

Nessun campo nuovo. `vistaAgenda` resta stato della sessione (non va nell'archivio). Nessun punto di privacy: in modalità
cliente la settimana mostra solo il cliente in vista, come la giornata di oggi.

### 18.5 Istantanee e prove

- Aggiornare `450-agenda-apple` / `450-agenda-apple-scuro` (`IstantaneeAgendaApple.swift:12`): oggi preparano
  `.settimana` e mostreranno le sette colonne. Nei dati delle istantanee serve almeno un impegno di oggi già passato e
  non chiuso (per «da chiudere») e uno chiuso: aggiungerli in `preparaAgendaApple` relativi all'ora ferma di
  `OraIstantanee`.
- Nuove: `453-agenda-settimana-cliente` (con un cliente scelto: solo i suoi), `454-agenda-occasioni-pulsante` (il popover
  aperto, se le istantanee lo catturano; altrimenti uno screenshot all'utente), `455-agenda-settimana-stretta` (finestra
  860×640: senza barra laterale).
- `451-agenda-giornata` e `11-agenda`, `11b-agenda-giorno`: mostrano « · da chiudere».
- `130-agenda-occasioni`, `131-agenda-occasioni-elenco`: restano (si arriva alla vista dal pulsante).
- Prove: casi nuovi in `Motori/ProvaCalcoliAgenda.swift` (dentro `--prova-calcoli`) per `MomentoImpegno` (prima,
  da chiudere, chiuso, blocco non disponibile, impegno a cavallo dell'ora) e per il conto «libero / 1 impegno / N
  impegni». `ProvaRiesamiAgenda` (in `--prova-carico`) va aggiornata quando la striscia sparisce.
- `--prova-fluidita`: la settimana con 30 clienti fittizi non deve far crescere i corpi rifatti (`ContaCorpi`) a ogni
  minuto (si rifà solo la riga dell'ora; le righe di oggi solo alla fine di un impegno, punto 1).
- Un caso per `vai(.appuntamento(id))` con la vista `.settimana`: passa a `.giorno` e sceglie l'appuntamento.

### 18.6 Decisioni per l'utente e rischi

- **18-a Vista di partenza.** Il template apre su «Settimana»; oggi l'Agenda apre su «Mese» (approvata). Proposta:
  seguire il template, «Settimana».
- **18-b Il numero di «Occasioni».** Il template conta tutte le occasioni di prova (3). Nell'app l'elenco guarda 12 mesi
  e il numero sarebbe alto e poco utile. Proposta: contare le occasioni della finestra già scelta in Impostazioni ›
  Promemoria e occasioni (`anticipoGiorni`, 30 di base: le stesse delle notifiche); «Tutte le occasioni ›» apre i 12
  mesi.
- **18-c Scadenze e cose da fare nella settimana.** La giornata di oggi ha la fascia «Da fare e da ricordare» (attività,
  scadenze, occasioni; con la miglioria 3 del gruppo 01 diventa «Da fare oggi»); la settimana del template non la
  mostra. Proposta: niente fascia nella settimana (stanno nel «Da fare» della colonna e in «Giorno»).
- **18-d «Non disponibile».** Un blocco senza cliente passato non diventa «da chiudere». Proposta: solo attenuato.
- Rischio: sette colonne con le corsie per gli impegni sovrapposti diventano strette (circa 140 punti per feriale a
  finestra piena). Con tre corsie l'impegno mostra solo il nome; serve la prova con i clienti fittizi.
- Rischio: un solo `ScrollView` per tutte le colonne, non uno per colonna (le ore restano allineate).

### 18.7 Dimensione

M (circa 400 righe). File: `Shell/AgendaSettimana.swift` (nuovo), `Motori/MomentoImpegno.swift` (nuovo),
`Shell/AppAgenda.swift`, `Shell/AgendaApple.swift`, `DesignSystem/Apple/Tema.Apple+Agenda.swift`,
`Shell/IstantaneeAgendaApple.swift`, `Motori/ProvaCalcoliAgenda.swift`.

---

## 19. Un impegno passato chiede com'è andato

### 19.1 Nel template

Righe 3722-3740 (`ESITI`, `apriEv` ridefinita), regola a righe 2678-2683. La scheda di un impegno (il dettaglio che
nasce dall'impegno toccato, 860×500) cambia con il momento.

- **Prima dell'ora** (non passato e senza esito): resta com'è (`_apriEv`, la base a riga 1237): punti da toccare, le due
  cifre del cliente, «Preparami l'incontro», «Apri il dossier», «Mostra al cliente» (regola 1).
- **Dopo l'ora o già chiuso** (`passatoEv` o `e.esito`):
  - in testa l'avatar (o il tondo con ✓ per un impegno senza cliente), l'occhiello verde «Incontro concluso · martedì 3
    novembre» («Attività di oggi · …» senza cliente), il titolo grande, sotto «Giulia Rossi · 09:30 – 10:15 · In studio»;
  - a sinistra «Com'è andata?» con quattro scelte a capsula, una sola accesa (`fch`, alte 36): nel template «Tutto
    fatto», «Ci deve pensare», «Da rifare», «Non è venuto» (la regola dice: *gli esiti di oggi, con le parole di oggi*).
    Senza cliente la domanda è «È fatta?» con «Fatta», «Rimandata». Al tocco la scelta si accende e compare l'avviso
    «Segnato: <esito>»;
  - sotto, «Punti toccati»: i punti dell'incontro, ognuno si spunta al tocco;
  - a destra (300) due riquadri: «Il verbale» con «Pronto, da confermare» oppure «Non ancora scritto» e sotto «sta in
    Incontri, nel momento «Dopo»»; «Cosa succede adesso» con «Se ci deve pensare, la proposta resta aperta e torna nel
    «Da fare» quando è ora di risentirlo.» (senza cliente: «Se la rimandi resta nel «Da fare».»);
  - in basso a sinistra **un solo pulsante blu**, «Scrivi il verbale» (porta in Incontri, su quell'incontro, momento
    «Dopo»), poi «Apri il dossier» (dossier, Panoramica) e «Altro ⌄», un menu con «Riapri l'incontro», «Modifica»,
    «Attività collegata», «Prepara il fascicolo» (senza cliente: «Modifica», «Sposta a un altro giorno»). «Prepara il
    fascicolo» apre Prospetti con il fascicolo; le altre voci restano come oggi.
- **Spariscono** i sei pulsanti su tre righe (Prepara l'incontro, Prepara con Vera, Riapri incontro, Modifica, Attività
  collegata, Prepara il fascicolo).

### 19.2 Nell'app oggi

- La scheda che nasce dall'impegno è `TracciaImpegnoApple` (`Shell/TracciaImpegnoApple.swift:98`): testata, «Punti da
  toccare» (`ListaTiPreparo`, dai punti di `stato.puntiDaToccare`, :27), le cifre del cliente, il piede con «Preparami
  l'incontro», «Apri il dossier», «Presenta al cliente» e «Tutti i dettagli» (:251). È uguale per un impegno futuro e
  per uno passato: l'etichetta aggiunge solo « · concluso» (:190).
- I «sei pulsanti su tre righe» del template sono nel dettaglio di sempre, `DettaglioAppuntamento`
  (`Shell/AppAgenda.swift:1027`), nella colonna di «Giorno»: «Prepara l'incontro»/«Apri l'incontro», «Prepara con
  Vera», «Segna concluso»/«Riapri incontro», «Modifica», «Attività collegata», «Prepara il fascicolo»/«Apri il
  fascicolo» (:1166-1188, funzioni :1196-1245).
- Gli esiti di oggi sono quelli della **proposta**: `RiquadroEsitoProposta` (`Shell/ModuloEsitoProposta.swift:292`, con
  `FormEsitoProposta`, scelte a :79 come `PulsanteAzione` su due righe, non capsule) compare nel dettaglio
  (`AppAgenda.swift:1075`) quando `stato.propostaDaChiudere(evento)` (`StatoSeguito.swift:20`) trova una proposta da
  chiudere; le scelte sono «✓ Accettata», «Rimandata», «Rifiutata», «Ci deve pensare» (`Motori/TestiSeguito.swift:10-13`),
  con la nota `TestiSeguito.notaInAttesa(giorni:)`. Attenzione: `propostaDaChiudere` e
  `MotoreSeguitoProposte.richiedeEsito` (:176) chiedono `a.stato == .concluso`, solo per i tipi `.proposta` e `.firma`
  con `posizioneId`, e smettono di rispondere quando l'esito è dato (`seguito.appuntamentoEsitoId == a.id`). Per un
  impegno passato ma ancora `.pianificato` oggi non risponde niente.
- `chiudiProposta` (`StatoSeguito.swift:59`) scrive l'esito e mostra il suo avviso (`TestiSeguito.avviso`), ma **non**
  segna concluso l'appuntamento: lo fanno `alternaConcluso` (che chiama `segnaConclusione`: la proposta diventa
  «presentata») e `chiudiIncontro`. «Ci deve pensare» (`.inAttesa`) parte subito, senza altri passi.
- L'appuntamento ha solo `stato: .pianificato | .concluso` (`Dati/Modelli.swift:441`); `stato.alternaConcluso`
  (`StatoShell.swift:3013`) segna e riapre, e alla chiusura fa partire il seguito della proposta e la fotografia del
  riesame. Non esiste un esito dell'incontro senza proposta («Tutto fatto», «Non è venuto»).
- Il verbale vive nel copilota (`VerbaleCopilotaVista`, `Shell/VerbaleCopilota.swift`) e nell'incontro
  (`Incontro.resoconto`, `Dati/Incontro.swift`).

### 19.3 Cosa fare

1. In `TracciaImpegnoApple.corpo` scegliere il corpo con `MomentoImpegno.di(e, adesso:)` (miglioria 18): `prima` →
   il corpo di oggi (con «Mostra al cliente» al posto di «Presenta al cliente» quando c'è la miglioria 1); `daChiudere`
   o `chiuso` → nuovo `corpoConcluso(e, cliente:)` (solo macOS; sull'iPad resta il corpo di oggi). Il momento usa la
   stessa `adesso` della vista che ha aperto la scheda (punto 1 della 18).
2. **Testata** del concluso: come la testata di oggi, ma l'etichetta è «Incontro concluso · <giorno lungo>» in
   `Colore.verde` (token `Traccia.coloreConcluso`). Senza cliente (blocco «Non disponibile») non si arriva qui
   (decisione 18-d), quindi il ramo «Attività di oggi» del template non serve.
3. **«Com'è andata?»** (occhiello `Traccia.etichetta`):
   - **con una proposta collegata** (tipo `.proposta`/`.firma`, `posizioneId`, proposta ancora aperta: una funzione
     nuova `propostaCollegata(_ a:)` accanto a `propostaDaChiudere`, con le stesse condizioni **senza** `a.stato ==
     .concluso`): le quattro scelte di oggi in capsula (`TestiSeguito.sceltaAccettata`, `sceltaRimandata`,
     `sceltaRifiutata`, `sceltaInAttesa`). Al tocco, se l'appuntamento è ancora `.pianificato`, prima
     `stato.alternaConcluso(e.id)` (così parte `segnaConclusione` e la proposta è «presentata», come oggi), poi il passo
     di `FormEsitoProposta` che serve (l'accettazione chiede ancora decorrenza e valori, il rinvio la data: non si
     saltano; «Ci deve pensare» conferma subito). Il modo più corto: `RiquadroEsitoProposta` compatto in questa colonna,
     con le scelte in capsula (parametro nuovo `capsule: true` di `FormEsitoProposta`, solo Mac) e il resto del modulo
     che si apre sotto come oggi. A esito dato la proposta non risponde più a `propostaDaChiudere`: allora la capsula
     dell'esito scritto (`MomentoImpegno.esitoBreve`) resta accesa e le altre spente, **senza** tocco (l'esito di una
     proposta passa dal modulo e non si annulla da qui: gruppo 01, 3.3); l'avviso resta quello di oggi
     (`TestiSeguito.avviso`, già detto da `chiudiProposta`), senza un secondo «Segnato: …»;
   - **senza proposta**: una sola capsula «Concluso», accesa se l'appuntamento è `.concluso`; il tocco chiama
     `stato.alternaConcluso(e.id)` (decisione 19-a) e l'avviso `stato.mostraAvviso("Segnato: concluso")`.
4. **«Punti toccati»**: gli stessi punti di `puntiDaToccare(e)`, ognuno con la spunta al tocco (riusare la riga di
   `ListaTiPreparo` in modalità «da spuntare a mano»). Le spunte restano in memoria (`@State`, decisione 19-b).
5. **Colonna a destra** (larga `Traccia.larghezzaTile` 300, a `Traccia.spazioColonne` 28 dai punti: ci sono già),
   due riquadri con `riquadro(_:)` di oggi:
   - «Il verbale»: «Pronto, da confermare» se c'è una `SessioneCopilota` del cliente con schede non confermate o
     l'incontro dell'appuntamento ha un `resoconto` da firmare; «Confermato» se l'incontro è concluso; altrimenti «Non
     ancora scritto». Sotto, sempre: «sta in Incontri, nel momento «Dopo»».
   - «Cosa succede adesso»: con una proposta `TestiSeguito.notaInAttesa(giorni: impostazioni.giorniSeguitoProposte)`;
     senza, «Il prossimo passo si decide nel verbale.» (testo nuovo, decisione 19-c).
6. **Piede**: «Scrivi il verbale» (`.applePrimarioGrande`) → `dettaglio?.chiudi(subito: true)`, poi
   `stato.apriIncontro(per: e, scheda: .passi)` («Dopo», miglioria 20): `apriIncontro` (`StatoShell.swift:2138`) oggi
   mette sempre `.preparazione` (o `.passi` se l'incontro è concluso), quindi serve il parametro nuovo `scheda:
   SchedaIncontro? = nil`; «Apri il dossier» (`.appleGrande`) come oggi; «Altro ⌄» (un `Menu` di SwiftUI con
   l'etichetta a capsula del tema, come la `capsula` di `DossierApple.swift:783`: il gruppo 01 non definisce un menu
   comune «Altro», solo il `Menu` «Aggiungi» della miglioria 6) con:
   «Riapri l'incontro» (`stato.alternaConcluso`), «Modifica» (`stato.mostraDettaglioImpegno(e)` e apertura del modulo,
   come «Modifica» di oggi), «Attività collegata» (il modulo dell'attività di oggi, con `appuntamentoId`), «Prepara il
   fascicolo» / «Apri il fascicolo» (le due strade di `azioneFascicolo`, :1229). «Tutti i dettagli» non c'è più qui:
   «Modifica» porta al dettaglio di sempre.
7. **`DettaglioAppuntamento`** (colonna di «Giorno»): per un impegno `daChiudere` o `chiuso` le due file di
   `PulsanteAzione` diventano «Scrivi il verbale» + «Altro ⌄» con le stesse voci del punto 6, così la scheda e il
   dettaglio dicono le stesse cose. Per un impegno `prima` restano quelle di oggi.
8. **Token** in `Tema.Apple+Agenda.swift`, `enum Traccia`: `coloreConcluso` (`Colore.verde`), `altezzaScelta` 36,
   `paddingScelta` 0×16, `carattereScelta` 13,5, `spazioScelte` 8, `sopraPuntiToccati` 20. Le colonne usano
   `spazioColonne` 28 e `larghezzaTile` 300 che ci sono già.
9. **Testi** (in `TestiAgendaApple`): «Incontro concluso», «Com'è andata?», «Punti toccati», «Il verbale», «Pronto, da
   confermare», «Non ancora scritto», «Confermato», «sta in Incontri, nel momento «Dopo»», «Cosa succede adesso»,
   «Scrivi il verbale», «Altro», «Riapri l'incontro», «Concluso», «Segnato: concluso», «Il prossimo passo si decide nel
   verbale.». Le voci del menu e «Apri il dossier» riusano i testi di oggi (`DettaglioAppuntamento`).

Cosa NON fare: non portare le quattro parole di prova del template («Tutto fatto», «Da rifare», «Non è venuto») senza la
decisione 19-a; non saltare i passi dell'accettazione (decorrenza, valori, antiriciclaggio: `TestiSeguito.
antiriciclaggio`); non chiamare `chiudiProposta` su un appuntamento ancora `.pianificato` (la proposta non sarebbe
«presentata» e il seguito non partirebbe). «Prepara con Vera» come scritta sparisce (miglioria 10 del gruppo 01, e il
template la elenca fra i sei pulsanti tolti), ma la richiesta a Vera (`SpuntoVera.incontro`) non si perde: vedi la
decisione 20-e; nel dettaglio di «Giorno» per un impegno `prima` il pulsante resta finché la 10 non lo rinomina.

### 19.4 Dati, archivio, privacy

Nessun campo nuovo con la proposta di 19-a e 19-b (gli esiti sono quelli della proposta, già nell'archivio e in «Prisma
ovunque»; lo stato concluso è già dell'appuntamento). Se l'utente sceglie gli esiti del template (19-a, seconda strada)
serve `Appuntamento.esito: EsitoIncontro?` (versione 28 dei campi, facoltativo, nel posto degli appuntamenti in
`ArchivioPezzi.pezzo`, nei backup, e da decidere se si sincronizza con «Prisma ovunque» come `daConfermare`), con la
prova in `--prova-backup`. Nessun punto di privacy: la scheda resta del consulente, mai in modalità cliente.

### 19.5 Istantanee e prove

- `452-agenda-traccia-impegno` resta (impegno futuro, stato «prima»).
- Nuove: `456-agenda-impegno-concluso` (impegno passato con proposta da chiudere: le quattro capsule), chiara e scura;
  `457-agenda-impegno-concluso-senza-proposta` (la capsula «Concluso» e «Non ancora scritto»).
- Prove: in `ProvaCalcoliSeguito` (in `--prova-calcoli`) nessun cambio se le scelte passano da `FormEsitoProposta`; casi
  nuovi in `ProvaSeguito` (Shell, in `--prova-carico`): «la capsula senza proposta chiama `alternaConcluso` e non tocca
  le proposte», «una scelta su un appuntamento `.pianificato` con proposta lo segna concluso prima dell'esito (proposta
  presentata, poi l'esito)», «a esito dato `propostaCollegata` dà la capsula accesa e nessun modulo».

### 19.6 Decisioni per l'utente e rischi

- **19-a Gli esiti.** La regola dice «gli esiti di oggi, con le parole di oggi», ma l'app ha esiti solo per la proposta.
  Proposta: con una proposta le quattro scelte della proposta; senza, una capsula sola «Concluso». In alternativa i
  quattro esiti del template su ogni incontro, con un campo nuovo nell'archivio.
- **19-b Punti toccati.** Il template li spunta e basta. Proposta: spunte solo in memoria (nessun campo); più avanti si
  possono passare al verbale.
- **19-c Il testo di «Cosa succede adesso» senza proposta.** Proposta: «Il prossimo passo si decide nel verbale.»
- **19-d La voce «Com'è andato «…»?» del «Da fare».** La tabella 3.3 del gruppo 01 dice che con la 19 gli
  appuntamenti passati senza esito vanno «nell'Agenda». Ma la settimana mostra solo la settimana in corso: un incontro
  di lunedì scorso non chiuso sparirebbe. Proposta: la voce resta nel «Da fare» finché l'impegno non è chiuso e apre
  la scheda della 19 (`vai(.appuntamento(id))` → «Giorno» con la scheda), senza i blocchi «Non disponibile».
- Rischio: la scheda è grande 860×500; con «Com'è andata?» che apre i passi dell'accettazione la colonna sinistra va
  dentro uno `ScrollView` (come i punti di oggi) e la sfumatura sul bordo di sotto.

### 19.7 Dimensione

M (circa 300 righe). File: `Shell/TracciaImpegnoApple.swift`, `Shell/AppAgenda.swift` (`DettaglioAppuntamento`),
`Shell/ModuloEsitoProposta.swift` (capsule), `Shell/StatoSeguito.swift` (`propostaCollegata`), `Shell/StatoShell.swift`
(`apriIncontro(per:scheda:)`), `DesignSystem/Apple/Tema.Apple+Agenda.swift`, `Shell/IstantaneeAgendaApple.swift`,
`Shell/ProvaSeguito.swift`.

---

## 20. L'incontro ha tre momenti: Prima, Durante, Dopo

### 20.1 Nel template

Righe 3742-3743 e 3763-3806 (`incMainHTML`, `incPassoHTML`, `incRimonta`, `montaIncPasso`, `fineCop`), CSS a righe
602-612, regola a righe 2684-2692.

- **In testa all'incontro** (card alta 74, senza ombra): avatar 44, il titolo dell'incontro (una riga, puntini se lungo),
  sotto «Giulia Rossi · oggi, 09:30 · in studio»; a destra i tre momenti (`#incPassi`): «1 Prima · Preparazione»,
  «2 Durante · Ascolto», «3 Dopo · Prossimi passi», uniti da un filo. Quello aperto è una capsula azzurra col numero
  bianco su tondo blu; quelli fatti hanno la spunta verde; tutti si toccano. Il momento si apre da solo così: un
  incontro di oggi su «Durante» (o «Dopo» se il verbale c'è), uno dei prossimi giorni su «Prima», uno fatto su «Dopo».
- **Prima** (`incPasso==='prima'`): a sinistra «Punti da toccare» (i punti), «L'ultima volta · 30 ottobre» con le prime
  due frasi del verbale di allora, in basso «✦ Preparami l'incontro» (blu), «Apri il dossier», «Inizia l'incontro ›»
  (porta a «Durante», copilota). Per un incontro fatto, al posto dei pulsanti: «Incontro concluso: la preparazione resta
  da rileggere.» A destra quattro riquadri: «Patrimonio netto», «Dati per l'analisi» con la barra, «Da fare per
  <nome>» con il numero e la prima voce (o «niente in sospeso»), «Proposte aperte» con il numero e «per … l'anno» (o
  «nessuna»).
- **Durante**: una card alta 66 con il selettore «Copilota | Appunti a mano».
  - Copilota: lo stato («Pronto ad ascoltare» / «Incontro concluso»), sotto in verde il lucchetto e «Giulia ha dato il
    consenso · l'audio non lascia il Mac» (una riga, **non un riquadro**), l'onda, «● Avvia il copilota» (rosso). Sotto,
    «Quello che vi state dicendo» (la trascrizione) e a destra le schede («Le schede compaiono qui, mentre Prisma
    capisce.»). Per un incontro fatto: «La trascrizione non è stata conservata: resta il verbale, in «Dopo».».
  - Appunti a mano: «Le domande e gli appunti scritti da te: finiscono nel verbale.» e «Ho finito ›» (porta a «Dopo»);
    sotto le tre domande numerate con un campo ciascuna, a destra «Appunti» e «Decisioni · diventano attività» («Una per
    riga»). Per un incontro fatto i campi non si scrivono.
  - Il riquadro «Come funziona» non c'è: sta nel «?» della barra (regola 6).
- **Dopo**: se il verbale non c'è ancora, al centro «Il verbale non c'è ancora.» e «Si scrive da solo quando termini
  l'ascolto. Da qui confermi cosa entra nel dossier, crei le attività e fissi il prossimo incontro.», con «Vai
  all'ascolto» (blu) e «Scrivilo a mano» (nel template: «Il verbale si può scrivere a mano, come oggi in «Prossimi
  passi»»). Se c'è: a sinistra «Il verbale» (punti) e «Le attività»; a destra «Cosa entra nel dossier» e in basso
  «Conferma tutto» (blu: le voci si spuntano una dopo l'altra, poi «Dossier di Giulia aggiornato: 4 modifiche e 2
  attività»), «Scrivi il riepilogo a Giulia» (apre la bozza in Messaggi), «Fissa il prossimo» (in Agenda con il cliente
  già scelto). Per un incontro fatto: niente conferma, «Già nel dossier: l'incontro è archiviato, in sola lettura.» e
  «Riapri».
- **Alla fine dell'ascolto** (`fineCop`, riga 3805) Prisma passa da sola a «Dopo», segna la spunta sulla riga
  dell'elenco e dice «Incontro concluso · il verbale è pronto: conferma cosa entra nel dossier». Il verbale non è più una
  scheda che si chiude e si perde.
- Il cambio di momento: il contenuto esce in 120 ms (opacità e 6 punti in giù), il nuovo entra a cascata; con «Riduci
  movimento» si cambia e basta.

### 20.2 Nell'app oggi

- `Shell/AppIncontri.swift:11` `AppIncontri`: barra (`barra`, :131) con due `MenuTendina` (cliente, incontro) e «Nuovo
  incontro» (blu); testata grande (`testata`, :174) con avatar, nome, titolo, gettoni (quando, tipo, durata, canale,
  «Concluso») e a destra il percorso (`percorso`, :257: `IndicatorePercorso`, `DesignSystem/ComponentiIncontri.swift:51`,
  con «Preparazione», «Ascolto», «Prossimi passi» a cerchi numerati e filo) e l'azione del passo (`azioneFase`, :269:
  «Prepara con Vera», «Inizia l'ascolto», «Il copilota», «Ai prossimi passi»). I passi sono `SchedaIncontro`
  (`StatoShell.swift:45`: `.preparazione`, `.ascolto`, `.passi`; stato in `stato.schedaIncontro`, :299).
- **Nel passo «Ascolto» il copilota prende tutta la finestra** (`SceltaAscoltoIncontri`, `CopilotaIncontro.swift:27`):
  la testata con i passi sparisce. Il copilota ha la colonna «Oggi» (`ColonnaOggiCopilota`, :137) con gli incontri di
  oggi, le note dall'iPhone, il riquadro del consenso (`SchedaConsensoCopilota`, :335, verde o arancio con il modulo per
  registrarlo) e il riquadro «Come funziona» (`ComeFunzionaCopilota`, :438); in fondo due collegamenti piccoli,
  «Domande e appunti» e «Prossimi passi» (`CollegamentiCopilota`, :307). È il «prima» del template.
- «Domande e appunti» (`copilota.modo = .appunti`) torna al quaderno, passo «Ascolto»: le tre domande
  (`DomandaAscolto`), appunti e decisioni (`ascolto`, :587).
- «■ Termina» apre il verbale in un dettaglio che nasce dal pulsante (`VerbaleCopilotaVista`,
  `Shell/VerbaleCopilota.swift`, 940×520) con «Conferma tutto» / «Conferma le scelte», «Scrivi il riepilogo a …», «Più
  tardi» e «Conserva la trascrizione». Chiuso con «Più tardi», resta raggiungibile solo dal pulsante «Il verbale» della
  testata del copilota.
- «Prossimi passi» (`passi`, :684) è un'altra cosa: le proposte ricavate dagli appunti scritti (bisogni, eventi,
  attività: `EstrattoreIncontro`, «Leggi gli appunti»), il pannello con attività concordata e prossimo incontro, e la
  chiusura. Un incontro concluso mostra l'archivio in sola lettura (`concluso`, :943) con i seguiti; non c'è «Riapri».
- La preparazione (`preparazione`, :325) ha i quattro temi dell'Analisi 360, le tessere «per decidere» (priorità, cifre
  del dossier, cosa è cambiato) e «L'ultima volta» (`ultimaVolta`, :545).

### 20.3 Cosa fare

1. **I nomi dei momenti.** `SchedaIncontro` resta (`.preparazione`, `.ascolto`, `.passi`: i valori non vanno
   nell'archivio, ma meglio non cambiarli); cambiano le parole. In `percorso(_:)` i passi diventano
   «Prima · Preparazione», «Durante · Ascolto», «Dopo · Prossimi passi». Sul Mac nuovo componente
   `MomentiIncontroApple` (in `DesignSystem/Apple/`, accanto a `IndicatorePercorso`) con la capsula orizzontale del
   template: tondo 26 col numero o la spunta, nome in neretto e sottonome piccolo, filo 26×2 fra i momenti; acceso =
   capsula in accento al 12% e tondo pieno d'accento; fatto = tondo verde al 18% con la spunta. Sull'iPad resta
   `IndicatorePercorso`.
   «Fatto» come nel template (righe 3767 e 3788), non come oggi: un momento ha la spunta se **non** è quello aperto e
   (l'incontro è concluso, oppure viene prima di quello aperto, oppure è «Durante» e c'è il verbale del copilota). Il
   momento aperto non ha mai la spunta (oggi `percorso`, :257, segna «Preparazione» e «Ascolto» fatti appena
   l'incontro non è vuoto).
2. **Una testata sola, sempre in vista.** Sul Mac la testata diventa la card bassa del template (avatar 44, titolo,
   «<nome> · <quando> · <luogo>», i momenti a destra) e **resta sopra anche durante il copilota**: in `AppIncontri.body`
   `SceltaAscoltoIncontri` non sostituisce più tutto il quaderno, ma solo il contenuto del momento. I gettoni di oggi
   (tipo, durata, canale) passano nella riga sotto il titolo; l'etichetta del canale resta (canale sempre
   riconoscibile). L'azione del passo (`azioneFase`) esce dalla testata e va dentro il momento (punti 3-5).
3. **Prima.** Il contenuto di `preparazione(_:)` di oggi, riordinato come il template: a sinistra «Punti da toccare»
   (gli stessi punti della traccia, `stato.puntiDaToccare(appuntamento)` se l'incontro ha un appuntamento, altrimenti i
   temi), «L'ultima volta · <data>» (`ultimaVolta`, già c'è), in basso «✦ Preparami l'incontro» (la stessa
   `ListaTiPreparo` della traccia), «Apri il dossier», «Inizia l'incontro ›» (→ `.ascolto`, `copilota.modo =
   .copilota`). A destra quattro riquadri con i motori di oggi: patrimonio netto (`riepilogoPosizioniCliente`), dati per
   l'analisi (`completezzaCliente`), «Da fare per <nome>» (il conteggio dell'unico «Da fare» del gruppo 01, miglioria 3;
   fino ad allora le attività aperte del cliente), «Proposte aperte» (numero e premi annui dalle posizioni in
   proposta). «Patrimonio netto» e «Dati per l'analisi» (con la barra verde da 85, arancio sotto) esistono già in
   `TracciaImpegnoApple.tile(_:)` (:204, `Traccia.sogliaVerde`): portarli in una vista condivisa invece di rifarli.
   I quattro temi dell'Analisi 360, le priorità e «Cosa è cambiato» restano, sotto i punti, dentro lo scorrimento
   (decisione 20-a). «Prepara con Vera» (`azioneFase`, :275: apre Vera con `SpuntoVera.incontro`) come scritta esce
   (miglioria 10 del gruppo 01): decisione 20-e. Senza appuntamento (incontro nato da «Nuovo incontro») i punti sono i
   temi dell'incontro. «L'ultima volta» si mostra solo per un incontro non concluso (template riga 3770).
4. **Durante.** Una card alta 66 con il selettore `SegmentatoPillola` «Copilota | Appunti a mano»
   (`copilota.modo`: `.copilota` / `.appunti`).
   - Copilota: il copilota di oggi **senza** la colonna «Oggi» (l'elenco degli incontri è ora a sinistra, miglioria
     21). Il consenso diventa una riga sotto lo stato, nella testata del copilota (`TestataCopilota`,
     `CopilotaIncontro.swift:462`): lì c'è **già** la riga col lucchetto verde «sul dispositivo · l'audio non lascia il
     Mac» (`TestiCopilota.indicatore`, token `Testata.indicatore`/`coloreIndicatore`), che sul Mac diventa
     `"\(primoNome) ha dato il consenso · l'audio non lascia il Mac"` (testo nuovo in `TestiCopilota`, stessi token).
     Sul Mac la testata del copilota perde avatar e titolo (stanno nella testata dell'incontro, sopra) e diventa la card
     alta 66 del template: selettore, stato con la riga del consenso, onda, «● Avvia il copilota». Senza consenso
     la riga è arancione, «Manca il consenso all'ascolto» con «Registra il consenso…», che apre il modulo di oggi di
     `SchedaConsensoCopilota` in un foglio o in un dettaglio (il copilota resta spento come oggi). «Come funziona» va nel
     «?» della barra (gruppo 01, miglioria 6). Le note dall'iPhone (`VoceOggiNotaVocale`) vanno nell'elenco di sinistra
     (miglioria 21).
   - Appunti a mano: le tre domande e gli appunti del passo «Ascolto» di oggi (`ascolto(_:)`), con la riga «Le domande e
     gli appunti scritti da te: finiscono nel verbale.» e «Ho finito ›» (→ `.passi`, con `TestiRinviati.scriviOra()` e
     `stato.estraiProposte`, come «Ai prossimi passi» di oggi). «Decisioni · diventano attività» è il campo
     `decisioni` di oggi.
   - Per un incontro concluso i campi sono in sola lettura e il copilota non si avvia: lo stato dice «Incontro
     concluso», niente «● Avvia il copilota», e al posto della trascrizione «La trascrizione non è stata conservata:
     resta il verbale, in «Dopo».» (se «Conserva la trascrizione» era acceso, la trascrizione conservata).
   - Il selettore «Copilota | Appunti a mano» resta solo sul Mac; sull'iPhone (`CopilotaIncontro.disponibile` falso)
     resta il quaderno di oggi.
5. **Dopo.**
   - Se c'è una sessione del copilota per l'incontro (`SessioneCopilota.incontroId == i.id`; oggi
     `copilota.sessione(per:in:)`, `StatoCopilotaIncontro.swift:243`, cerca per cliente: va ristretta all'incontro,
     altrimenti il verbale di un altro incontro dello stesso cliente finirebbe qui): il contenuto di
     `VerbaleCopilotaVista` **dentro la pagina**, non
     più in un dettaglio che nasce dal pulsante. Rifattorizzare `VerbaleCopilotaVista` in un corpo riusabile
     (`CorpoVerbaleCopilota`) usato sia qui sia, sull'iPad, nel dettaglio di oggi. I pulsanti: «Conferma tutto» /
     «Conferma le scelte» (com'è), «Scrivi il riepilogo a <nome>» (com'è), «Fissa il prossimo» (il `ModuloAppuntamento`
     con il cliente già scelto, come «Fissa l'incontro di riesame» di Prospetti). «Più tardi» non serve più: il verbale
     resta qui. «Conserva la trascrizione» resta, a destra.
   - Se non c'è il copilota ma ci sono appunti scritti: i «Prossimi passi» di oggi (`passi(_:)`: proposte dagli
     appunti, attività concordata, prossimo incontro, chiusura).
   - Se non c'è niente: lo stato vuoto del template, «Il verbale non c'è ancora.», la frase, «Vai all'ascolto» (blu, →
     `.ascolto`) e «Scrivilo a mano» (→ `.ascolto` con `copilota.modo = .appunti`).
   - Incontro concluso: l'archivio di oggi (`concluso(_:)`, :943) con «Già nel dossier: l'incontro è archiviato, in sola
     lettura.» e «Riapri» (decisione 20-b). Attenzione: `chiudiIncontro` (`StatoShell.swift:2171`) a ogni chiusura crea
     l'attività di `prossimaAttivita`, l'appuntamento di `prossimoIncontro` e le attività scelte: riaprire e richiudere
     li creerebbe due volte. «Riapri» deve quindi lasciare `attivitaCreataId`/`appuntamentoCreatoId` e
     `chiudiIncontro` deve saltare la creazione quando ci sono già (con un caso nella prova).
6. **Alla fine dell'ascolto** («■ Termina», `TestataCopilota`): sul Mac invece di aprire il dettaglio
   (`apriVerbale()`) imposta `stato.schedaIncontro = .passi` e mostra l'avviso «Incontro concluso · il verbale è pronto:
   conferma cosa entra nel dossier». Il pulsante «Il verbale» della testata del copilota non serve più sul Mac (il
   verbale è il momento «Dopo»).
7. **Il cambio di momento** con `Tema.Apple.Moto.CambioScheda` (uscita 6 punti in 0,13 s × ritmo, poi cascata). Il
   copilota in ascolto non continua fuori vista (oggi `CopilotaIncontro.onDisappear`, :97, lo interrompe): con la
   proposta di 20-c, toccando «Prima» o «Dopo» mentre ascolta compare prima «Fermare l'ascolto?»; «Ferma» chiama
   `copilota.interrompi()` e cambia momento, «Annulla» resta su «Durante». Lo stesso vale per le righe dell'elenco
   (miglioria 21). Siccome sul Mac la testata resta sopra e cambia solo il contenuto, l'`onDisappear` del copilota
   scatta ora anche al cambio di momento: è quello che ferma l'ascolto, e la conferma viene prima.
8. **Token** in `Tema.Apple+Copilota.swift` (o nuovo `Tema.Apple+Incontri.swift` se si preferisce staccarli; i valori di
   oggi sono in `Tema.Misura.Incontri`, del tema vecchio, e qui vanno ricavati dal tema Apple): `altezzaTestata` 74,
   `avatarTestata` 44, `momento` (tondo 26, filo 26×2, padding 6/14/6/7, raggio capsula), `fondoMomentoAcceso`
   (accento al 12%), `fondoMomentoFatto` (verde al 18%), `nomeMomento` 13,5 bold, `sottoMomento` 11,
   `altezzaBarraDurante` 66, `numeroDomanda` 22 (tondo `.pzN`). La riga del consenso riusa `Testata.indicatore` e
   `coloreIndicatore` (verde) e, senza consenso, l'arancio del tema (`Colore.arancio` o il colore della scheda del
   consenso di oggi, `Tema.Apple.Copilota.Consenso`).
9. **Testi** (in `TestiCopilota` o nuovo `TestiIncontriUso`): «Prima», «Preparazione», «Durante», «Ascolto», «Dopo»,
   «Prossimi passi», «Inizia l'incontro», «Copilota», «Appunti a mano», «Le domande e gli appunti scritti da te:
   finiscono nel verbale.», «Ho finito», «Il verbale non c'è ancora.», «Si scrive da solo quando termini l'ascolto. Da
   qui confermi cosa entra nel dossier, crei le attività e fissi il prossimo incontro.», «Vai all'ascolto», «Scrivilo a
   mano», «Fissa il prossimo», «Già nel dossier: l'incontro è archiviato, in sola lettura.», «Riapri», «Incontro
   concluso · il verbale è pronto: conferma cosa entra nel dossier», «Da fare per …», «Proposte aperte», «niente in
   sospeso», «nessuna», «per … l'anno», «L'ultima volta · …», «Incontro concluso: la preparazione resta da
   rileggere.», «Incontro concluso» (stato del copilota), «La trascrizione non è stata conservata: resta il verbale, in
   «Dopo».», «Manca il consenso all'ascolto», «Registra il consenso…». «Pronto ad ascoltare», «Quello che vi state
   dicendo» e «Le schede compaiono qui, mentre Prisma capisce.» ci sono già in `TestiCopilota`
   (`StatoCopilotaIncontro.swift:34-41`).

Cosa NON fare: non portare `VERB_OGGI`, `INC_FATTI` e `DOMANDE` (i testi del verbale vengono dal copilota e dagli
appunti; le domande sono quelle di `DomandaAscolto`, che coincidono); non portare il contatore «4 modifiche e 2 attività»
come testo fisso (lo dice `confermaVerbale`); non togliere il consenso: senza consenso il copilota non parte, come oggi.

### 20.4 Dati, archivio, privacy

Nessun campo nuovo: incontri, sessioni del copilota, verbale e resoconto ci sono già. Privacy invariata e da rispettare:
l'audio non lascia il Mac, la trascrizione si dimentica alla conferma se «Conserva la trascrizione» è spento (di base),
il consenso resta registrato nel dossier con data e modo. La riga del consenso ripete la promessa («l'audio non lascia il
Mac»): deve restare vera (nessun audio salvato, nessuna richiesta di rete). Mai in modalità cliente.

### 20.5 Istantanee e prove

- Aggiornare `21-incontri-ascolto`, `22-incontri-passi`, `105-incontri-preparazione`, `215-incontri-cambiato`
  (`Istantanee.swift`) e le scene del copilota 580-589 (`IstantaneeCopilota.swift`): la testata con i tre momenti resta
  in vista; nel copilota sparisce la colonna «Oggi» e il consenso è una riga.
- Nuove (i numeri 590-598 sono già della Prova del fuoco, 462 di «Un anno insieme»: qui 472-477, liberi):
  `472-incontri-dopo-verbale` (il verbale del copilota dentro «Dopo», chiara e scura), `473-incontri-dopo-vuoto` («Il
  verbale non c'è ancora.»), `474-incontri-durante-appunti` («Appunti a mano»), `475-incontri-senza-consenso` (la riga
  arancione).
- Prove: `ProvaVistaCopilota` (in `--prova-vera`) — il verbale confermato voce per voce ora vive anche fuori dal
  dettaglio: aggiungere che `CorpoVerbaleCopilota` conferma come prima e che «■ Termina» porta `schedaIncontro` a
  `.passi`. `ProvaCopilota` invariata per i calcoli.

### 20.6 Decisioni per l'utente e rischi

- **20-a La preparazione di oggi.** I quattro temi dell'Analisi 360, le priorità e «Cosa è cambiato» non sono nel
  template. Proposta: restano in «Prima», sotto i punti da toccare, nello scorrimento.
- **20-b «Riapri».** Il template lo mette ma non lo fa (dice «resta com'è»); l'app oggi non riapre un incontro
  archiviato. Proposta: «Riapri» rimette l'incontro in preparazione (`Incontro.stato = .preparazione`) senza toccare
  attività, appuntamenti e dossier già aggiornati; e riapre l'appuntamento collegato (`alternaConcluso`).
- **20-c Cambiare momento durante l'ascolto.** Oggi uscire dal copilota lo ferma subito. Proposta: tenerlo così (più
  sicuro: niente ascolto fuori vista); passando a «Prima» o «Dopo» mentre ascolta, prima una conferma «Fermare
  l'ascolto?».
- **20-d «Nuovo incontro».** Il template non ha il pulsante (gli incontri nascono dall'Agenda; nella riga in testa resta
  solo «Nota dall'iPhone», `AzioniIncontri.swift`). Proposta: resta, come azione secondaria nella riga in testa
  (accanto a «Nota dall'iPhone», non più blu), per gli incontri senza appuntamento che il copilota già prevede
  (`TestiCopilota.senzaAppuntamento`).
- **20-e La richiesta a Vera di preparare l'incontro.** Oggi «Prepara con Vera» apre Vera con la domanda
  dell'incontro; il template ha un solo «✦ Preparami l'incontro» (i punti che si spuntano, come nella scheda
  dell'impegno) e la 10 toglie la scritta. Proposta: «✦ Preparami l'incontro» fa quello che fa nella scheda
  (`ListaTiPreparo`), e alla fine dei punti offre «Chiedi a Vera» (la stessa domanda di oggi) come collegamento sobrio;
  in alternativa la domanda a Vera resta solo nell'app Vera.
- Rischio: `CopilotaIncontro` rifà il corpo a ogni frase dell'ascolto; la testata nuova sopra non deve leggere dati che
  cambiano con le frasi (passarle valori fermi, come oggi `ColonnaOggiCopilota` usa `ricavato`).
- Rischio: il verbale dentro la pagina e non più nel dettaglio cambia la prova a vista del verbale e l'iPad: tenere il
  dettaglio sull'iPad.

### 20.7 Dimensione

L (oltre 500 righe). File: `Shell/AppIncontri.swift`, `Shell/CopilotaIncontro.swift`, `Shell/VerbaleCopilota.swift`,
`Shell/StatoCopilotaIncontro.swift`, `Shell/StatoShell.swift` (`chiudiIncontro`, «Riapri»), `Shell/TracciaImpegnoApple.swift`
(le tile condivise), `DesignSystem/ComponentiIncontri.swift` o nuovo `DesignSystem/Apple/MomentiIncontroApple.swift`,
`DesignSystem/Apple/Tema.Apple+Copilota.swift`, `Shell/IstantaneeCopilota.swift`, `Istantanee.swift`,
`Shell/ProvaVistaCopilota.swift`.

---

## 21. Incontri segue il cliente e non si ferma a oggi

### 21.1 Nel template

Righe 3744-3762 (`incLista`, `incScelto`, `incontriUsoHTML`), 3799-3806 (`montaIncontriUso`, `scegliCli`), regola a
righe 2693-2695.

- **Colonna a sinistra** (`#incL`, larga 300, scorre): tre gruppi con l'occhiello «Oggi», «Prossimi», «Fatti» (un gruppo
  vuoto non si mostra). Ogni riga: avatar 36, il nome in neretto, sotto «09:30 · Il punto sul progetto casa» (oggi:
  l'ora; prossimi: «gio 5 · 15:00»; fatti: «30 ottobre») e, per i fatti o per quelli con il verbale pronto, la spunta
  verde a destra. La riga scelta è accesa.
- **Segue il cliente della barra** (`cliSel`): con un cliente scelto mostra solo i suoi incontri, anche quelli passati con
  il loro verbale; con «Tutti i clienti» mostra tutti. Se il cliente non ha incontri: «Nessun incontro con <nome>. Si
  fissa in Agenda.» e a destra «Nessun incontro, per ora.» con «Apri l'Agenda».
- Cambiando cliente Incontri riparte dal suo primo incontro (riga 3807). Toccando una riga si apre l'incontro sul momento
  giusto (oggi → «Durante», o «Dopo» se c'è il verbale; prossimo → «Prima»; fatto → «Dopo», in sola lettura, con
  «Riapri»).
- **Spariscono** le due tendine (cliente e incontro, con il titolo tagliato).
- Nella barra della finestra resta «Nota dall'iPhone» di «Luce» (riga 2575).

### 21.2 Nell'app oggi

- `AppIncontri` lavora sempre su un cliente: `cliente` è `stato.clienteAttivoId` (:17); l'elenco è
  `stato.incontriCliente(cliente)` (`StatoShell.swift:2094`: filtro e ordinamento di `dati.incontri` a ogni body, non in
  cache). La scelta è in due `MenuTendina` nella barra (:135, :139).
- L'incontro aperto è `stato.incontroAperto` (:298) o il primo da preparare (`scegliCorrente`, :23). Un appuntamento
  diventa incontro solo con `stato.apriIncontro(per:)` (:2138) o `nuovoIncontro` (:2122), che **lo salvano subito
  nell'archivio**.
- La colonna «Oggi» del copilota (`ColonnaOggiCopilota`, `CopilotaIncontro.swift:137`) elenca gli appuntamenti di oggi di
  tutti i clienti (cache `ricavato("copilota-oggi")`) e le note dall'iPhone (`stato.noteDaGuardare`), e si vede solo nel
  passo «Ascolto». Non ci sono «Prossimi» e «Fatti».
- Non esiste ancora la scelta «Tutti i clienti» globale: è la miglioria 2 del gruppo 01.

### 21.3 Cosa fare

1. **I dati dell'elenco.** Nuovo `extension StatoShell` in `Shell/ElencoIncontri.swift` (nuovo):
   `struct VoceIncontri: Identifiable, Equatable { id; clienteId; titolo; quando: Date; gruppo: .oggi/.prossimi/.fatti;
   incontroId: String?; appuntamentoId: String?; fatto: Bool }` e
   `func elencoIncontri(cliente: String?) -> (oggi: [VoceIncontri], prossimi: [VoceIncontri], fatti: [VoceIncontri])`
   dentro `ricavato("incontri-elenco|\(cliente ?? "tutti")|\(DerivatiDati.ora())")` (vale finché non cambiano i dati
   dei calcoli, il giorno e la modalità cliente; l'ora nella chiave perché «da chiudere» e il passaggio da «Prossimi» a
   «Oggi» dipendono da adesso). Le regole (decisione 21-a):
   - **Oggi**: gli appuntamenti di oggi con un cliente (tipo diverso da «Non disponibile»), uniti al loro incontro se
     c'è; più gli incontri di oggi senza appuntamento. In ordine di ora.
   - **Prossimi**: gli appuntamenti con un cliente da domani ai prossimi 14 giorni (al più 20), in ordine di data.
   - **Fatti**: gli incontri conclusi degli ultimi 12 mesi (al più 30), dal più recente; e gli appuntamenti passati non
     chiusi degli ultimi 7 giorni (`MomentoImpegno.daChiudere`), in testa al gruppo e senza spunta, con «da chiudere».
   - `fatto` (spunta verde) = incontro concluso o verbale del copilota pronto. **Il verbale pronto non va dentro la
     cache:** `dati.sessioniCopilota` segnala `.neutro` (`Dati/DatiVivi.swift:67`) e non cambia `versioneCalcoli`, quindi
     la cache non lo vedrebbe; la spunta del verbale si legge fuori, solo per le righe con un incontro, dalle sessioni
     del copilota per `incontroId` (`SessioneCopilota.incontroId`), con un insieme fatto una volta per body.
   - Con un cliente scelto, solo i suoi.
2. **La colonna a sinistra.** Nuova vista `ElencoIncontriApple` (solo macOS) larga `Incontri.larghezzaElenco` (300):
   occhielli «Oggi», «Prossimi», «Fatti» nello stile dei gruppi di Prospetti (`Tema.Apple.Prospetti.Laterale.etichetta`
   o un token proprio uguale), righe con `AvatarCliente` 36, nome, «<quando> · <titolo>», spunta verde
   (`Colore.verde`) a destra. In testa le note dall'iPhone ancora da guardare (`VoceOggiNotaVocale`, com'è oggi nella
   colonna del copilota). Riga accesa = superficie della voce scelta (`voceSceltaProspetto(attiva:)` o l'equivalente
   della rubrica). Scorre da sola (`ScrollView`), cascata delle righe come le voci di Prospetti.
3. **Scegliere una riga.** Se la voce ha un incontro: `stato.incontroAperto = id` e il momento: oggi → `.ascolto`
   (`.passi` se c'è il verbale), prossimo → `.preparazione`, fatto → `.passi`. Se la voce è solo un appuntamento senza
   incontro: si mostra «Prima» costruito dall'appuntamento (punti da toccare, cifre del cliente) **senza creare niente
   nell'archivio**; l'incontro nasce (`nuovoIncontro(cliente:appuntamento:)`) al primo gesto che scrive: «Inizia
   l'incontro», «Preparami l'incontro», un appunto, il copilota avviato (decisione 21-b). Se il cliente scelto nella
   barra è un altro, sceglierlo è compito del gruppo 01 (con un cliente scelto, l'elenco ha solo i suoi).
   Come fa oggi `ColonnaOggiCopilota.scegli` (`CopilotaIncontro.swift:227`): mentre il copilota ascolta
   (`copilota.ascolta`) le righe non cambiano incontro (o chiedono «Fermare l'ascolto?», decisione 20-c); prima di
   cambiare, `copilota.azzera()` e `TestiRinviati.scriviOra()` (gli appunti in attesa vanno nell'incontro giusto);
   con «Tutti i clienti» una riga di un altro cliente mette anche `stato.clienteAttivoId`.
4. **Cambiando cliente** nella barra: `incontroAperto = nil`, si riparte dal primo della lista (oggi, poi prossimi, poi
   fatti). In `AppIncontri` togliere `riavviaCascata(cliente)` solo se l'elenco ne ha una sua.
5. **Via le due tendine** di `barra(...)`. Nella riga in testa (gruppo 01, miglioria 4) restano «Nota dall'iPhone» e,
   secondo la decisione 20-d, «Nuovo incontro».
6. **Vuoti**: colonna «Nessun incontro con <nome>. Si fissa in Agenda.»; a destra «Nessun incontro, per ora.» con
   «Apri l'Agenda» (`stato.apri(.agenda)`). Con «Tutti i clienti» e nessun incontro: solo la seconda.
7. **La colonna «Oggi» del copilota** non si mostra più sul Mac (l'elenco è a sinistra per tutta Incontri). Resta
   sull'iPad.
8. **Token** in `Tema.Apple+Copilota.swift` (o `Tema.Apple+Incontri.swift`): `larghezzaElenco` 300, `avatarRiga` 36,
   `paddingRiga` 9×10, `spazioGruppi`, `occhielloGruppo`, `sottoRiga`.
9. **Testi**: «Oggi», «Prossimi», «Fatti», «Nessun incontro con \(nome). Si fissa in Agenda.», «Nessun incontro, per
   ora.», «Apri l'Agenda», «da chiudere».

Cosa NON fare: non portare `INC_FATTI` e i giorni di prova (`GIORNI`); non filtrare `dati.incontri` e
`dati.appuntamenti` nel body (solo dentro `ricavato`); non creare incontri vuoti nell'archivio solo per aver toccato una
riga.

### 21.4 Dati, archivio, privacy

Nessun campo nuovo. Con la decisione 21-b si scrivono meno incontri vuoti di oggi. Privacy: con «Tutti i clienti» la
colonna mostra nomi di più clienti: mai in modalità cliente (Incontri in modalità cliente segue la regola del gruppo 01:
solo il cliente in vista, o l'app non si apre, come Messaggi).

### 21.5 Istantanee e prove

- Le scene di Incontri (`21-…`, `22-…`, `105-…`, `215-…`, 580-589) mostrano la colonna nuova: servono nei dati di prova
  un incontro di oggi, uno nei prossimi giorni e uno concluso per lo stesso cliente (Giulia ne ha già:
  «incontro-giulia-analisi»).
- Nuove: `476-incontri-tutti-i-clienti` (dopo la miglioria 2), `477-incontri-cliente-senza-incontri` (i due vuoti); i
  numeri 590-595 sono già della Prova del fuoco.
- Prove: casi nuovi in `ProvaCalcoliAgenda` o in una prova di Shell dentro `--prova-carico` per `elencoIncontri`: i tre
  gruppi, i limiti (14 giorni, 20 prossimi, 30 fatti, 12 mesi), il filtro per cliente, «Non disponibile» escluso, e che
  scegliere una riga senza incontro non scriva nell'archivio.
- `--prova-fluidita`: l'elenco non si rifà a ogni frase del copilota.

### 21.6 Decisioni per l'utente e rischi

- **21-a I limiti dell'elenco.** Il template mostra la settimana e quattro incontri passati. Proposta: «Prossimi» = 14
  giorni (al più 20), «Fatti» = 12 mesi (al più 30), più gli appuntamenti degli ultimi 7 giorni ancora da chiudere.
- **21-b Quando nasce l'incontro.** Oggi aprire un appuntamento in Incontri crea subito l'incontro nell'archivio.
  Proposta: crearlo al primo gesto che scrive.
- Rischio: due fonti (appuntamenti e incontri) da unire senza doppioni: la chiave è `Incontro.appuntamentoId`.

### 21.7 Dimensione

M (circa 350 righe). File: `Shell/ElencoIncontri.swift` (nuovo), `Shell/AppIncontri.swift`,
`Shell/CopilotaIncontro.swift`, `Shell/StatoShell.swift` (`apriIncontro`), `DesignSystem/Apple/Tema.Apple+Copilota.swift`,
le istantanee di Incontri.

---

## 22. «Per te» e «Per il cliente» al posto di «Prospetto» e «Report»

### 22.1 Nel template

Righe 3808-3811, 3821-3856, 3846-3859 (`verP`, `soloTe`, `paginaP`, `prospBarraHTML`, `prospCambia`, `prospBarra`),
CSS a righe 614-621, regola a righe 2696-2700.

- **Sopra la pagina** (`#pBarra`, alta 58): a sinistra il nome del documento in neretto («Check-up primo incontro») e sotto
  cos'è: «Report · da mostrare e da consegnare» oppure «Prospetto di dettaglio · solo per te». A destra il selettore a
  pillola **«Per il cliente | Per te»** (`#pVer`); per un documento che ha una versione sola, al posto del selettore
  un'etichetta grigia «Solo per il cliente». Accanto, la «i» (vedi miglioria 23).
- La versione di partenza è «Per il cliente» (`verP='cli'`); scegliendo un documento senza versione per te si torna a
  «Per il cliente».
- **Il cambio di versione**: la pagina esce (scala 0,68 e 30 punti verso l'alto o il basso, 180 ms) e la nuova entra dal
  lato opposto (520 ms, molla); «Per te» viene «dopo» (la pagina sale). Con «Riduci movimento» si cambia e basta.
- **La pagina per te** porta in alto a destra il timbro **«SOLO PER TE»** (riquadro arancio bruciato, 9,5 punti,
  spaziato) e in fondo «Prospetto per il consulente: non va consegnato.» (per il check-up: «… La versione per il
  cliente è «Il quadro di Giulia».»).
- **«Mostra al cliente»** apre sempre la versione per il cliente: se sullo schermo c'è quella per te, prima l'avviso «Al
  cliente si mostra la versione per il cliente», poi la vista pulita e la presentazione (riga 3861).
- **«Salva PDF»** salva quella che si guarda e lo dice: «PDF salvato: «Check-up primo incontro» · versione per te»
  (o «· versione per il cliente»).
- Le parole «Prospetto» e «Report» restano nei sottotitoli e nei PDF.

### 22.2 Nell'app oggi

- La versione è dentro la scelta: `SceltaProspetto` ha `report: Bool` per dodici casi (`Dati/Prospetto.swift:5`:
  resoconto, sostituzione, previdenza, protezione, obiettivo, liquidità, check-up, resistenza, costi, successione,
  patrimonio, valutazione); i
  documenti senza la scelta sono `fascicolo`, `posizione`, `confronto`, `portafoglio`, `riesame` (solo per te) e
  `annoInsieme` (solo per il cliente). `scegli(_:)` (`AppProspetti.swift:186`) parte sempre da `report: false`, cioè
  dalla versione **per te**.
- Il selettore «Prospetto | Report» (`SegmentiAnalisi`) è nella colonna, dentro le scelte della voce aperta
  (`sceltaResoconto`, :303, `sceltaCheckUp`, :404, … una per tipo, :303-777), sotto il documento scelto.
- Sopra la pagina (`barraAzioniApple`, `ProspettiApple.swift:322`) il titolo del documento e
  «<genere> · <cliente> · A4 … · N pagine»; `DocumentoStampabile.genere` è «Prospetto» o «Report»
  (`Shell/StampaCarta.swift:12`).
- Le pagine per il consulente non hanno un timbro; la frase sul vuoto dice «Il prospetto è il documento dettagliato per
  te; il report è la versione essenziale da lasciare al cliente.» (`AppProspetti.swift:138`).
- Ogni documento si impagina da sé: `documentoProspetto(_:)` (`StatoShell.swift:1621`) chiama un `DocumentoStampabile(...,
  report:)` diverso per ognuno dei dodici (pagine in `Shell/Prospetto*.swift`); solo posizione, confronto, riesame e
  portafoglio passano da `ContenutoProspetto` → `PaginaCarta` (`DesignSystem/ComponentiCarta.swift:192`, con
  `testataPrima` a :223). Le stesse `pagine` servono all'anteprima, al PDF e alla presentazione (`StampaCarta.swift:10`).
- Dopo «Salva PDF…» oggi non c'è un avviso: il foglio della password (`ModuloSalvaPDF`) salva e si chiude.
- «Al tavolo» (`PulsanteAlTavolo`) manda all'iPad il documento che si guarda, anche la versione per te.
- «Presenta all'incontro» (`presentaApple`, `ProspettiApple.swift:445`) presenta la pagina che si guarda, anche la
  versione per te.

### 22.3 Cosa fare

1. **La versione separata dalla scelta.** In `Dati/Prospetto.swift`, `extension SceltaProspetto`:
   `var versione: VersioneProspetto?` (`.perIlCliente` / `.perTe`, nil per chi non ha la scelta),
   `func conVersione(_ v: VersioneProspetto) -> SceltaProspetto` (rifà il caso con `report: v == .perIlCliente`) e
   `var soloPer: VersioneProspetto?` (`.perTe` per posizione, confronto, riesame, portafoglio; `.perIlCliente` per
   anno insieme e fascicolo). Niente cambia nei compositori.
2. **Il selettore sopra la pagina.** In `barraAzioniApple` (o nella barra sopra la pagina che resta dopo la miglioria
   24) a sinistra il nome breve del documento e sotto «Report · da mostrare e da consegnare» / «Prospetto di dettaglio
   · solo per te»; a destra `SegmentatoPillola` «Per il cliente | Per te» legato a `stato.prospetto` via `conVersione`,
   oppure l'etichetta «Solo per il cliente» / «Solo per te» (`Pillola` neutra) per chi ha una versione sola. Il cambio
   usa `cambiaAnteprima(direzione:)` di oggi: «Per te» = direzione +1.
3. **Via «Prospetto | Report» dalla colonna**: togliere `SegmentiAnalisi(opzioni: [(false, "Prospetto"), (true,
   "Report")] …)` da tutte le funzioni `scelta…` di `AppProspetti.swift` (sul Mac; sull'iPad la colonna resta com'è
   finché il suo giro non arriva).
4. **La versione di partenza**: `scegli(_:)` parte da `report: true` («Per il cliente») sul Mac (decisione 22-a), e
   ricorda per la sessione l'ultima versione scelta (`@State` o `stato.versioneProspetti`, non nell'archivio).
5. **Il timbro «SOLO PER TE».** Sulle pagine dei prospetti per il consulente (versione `.perTe` e i documenti solo per
   te, escluso il portafoglio che è già tutto per te: decisione 22-c) un timbro in alto a destra della prima pagina:
   nuovo componente `TimbroSoloPerTe` in `DesignSystem/ComponentiCarta.swift`, colori fissi e opachi di carta (nuovi
   `Colori.Carta.timbro` = `#B4530B`, `Misure.Carta.timbro…`: dimensione 9,5, spaziatura 1, bordo 1,5, raggio 6,
   padding 3×7, a 46 dal bordo destro e 40 dall'alto). Un posto solo, non i dodici `Prospetto*.swift`: una funzione
   `DocumentoStampabile.conTimbroPerTe()` che rende un documento con la prima pagina avvolta in un `overlay(alignment:
   .topTrailing)` col timbro e l'ultima con la frase «Prospetto per il consulente: non va consegnato.» nel margine
   basso (`Misure.Carta.margineBasso`, accanto al numero di pagina, senza toccare l'area del contenuto), chiamata in
   fondo a `documentoProspetto(_:)` quando la scelta è `.perTe`. Così compare uguale a schermo, nel PDF, in stampa e
   nell'archiviato (decisione 22-b), e il numero di pagine non cambia. Per i documenti in orizzontale (A4 orizzontale)
   le distanze del timbro sono le stesse, misurate dal bordo della pagina.
6. **«Mostra al cliente»** (miglioria 24): se la scelta ha `versione == .perTe`, usa `scelta.conVersione(.perIlCliente)`,
   impagina con `stato.documentoProspettoInCache` e presenta quello **dalla prima pagina** (l'indice dell'anteprima è
   della versione per te, che ha altre pagine), con l'avviso «Al cliente si mostra la versione per il cliente». Lo
   stesso vale per l'iPad al tavolo (`ContestoTavolo(documento:pagina:clienteId:)` con il documento per il cliente):
   all'iPad non va mai la versione per te. Per i documenti solo per te il pulsante è spento (decisione 22-d).
7. **«Salva PDF»**: dopo il salvataggio (alla fine di `ModuloSalvaPDF`, solo se il file è stato scritto) un avviso
   nuovo con la versione: «PDF salvato: «<nome>» · versione per te» / «· versione per il cliente» (per i documenti con
   una versione sola, senza la coda). Il nome del file (`StampaCarta.nomeFile`) resta con «Prospetto»/«Report».
8. La frase del vuoto (`AppProspetti.swift:138`) diventa «La versione per te è il documento dettagliato; quella per il
   cliente è l'essenziale da mostrare e da lasciargli.».
9. **Token**: in `Tema.Apple+Prospetti.swift`, `enum Barra`: `altezzaVersione` 58, `etichettaSolo` (carattere 12,5 e
   padding 5×12). In `DesignSystem/Carta.swift`: i colori e le misure del timbro.
10. **Testi**: «Per il cliente», «Per te», «Solo per il cliente», «Solo per te», «Report · da mostrare e da
    consegnare», «Prospetto di dettaglio · solo per te», «SOLO PER TE», «Prospetto per il consulente: non va
    consegnato.», «Al cliente si mostra la versione per il cliente», «versione per te», «versione per il cliente».

Cosa NON fare: non portare i prospetti «per te» del template (`PAG[1..3].te`: tabelle e cifre di prova); non cambiare
`SceltaProspetto` nei suoi casi (le scelte salvate altrove, come i commenti con `chiaveCommento`, devono restare uguali).

### 22.4 Dati, archivio, privacy

Nessun campo nuovo. Il timbro cambia l'aspetto dei PDF per il consulente (sempre carta bianca, colori fissi e opachi:
regola rispettata). Privacy: rafforza la regola che al cliente si mostra solo la versione per lui; il commento del
consulente (`PannelloCommento`) resta solo nel report, come oggi.

### 22.5 Istantanee e prove

- Aggiornare `460-prospetti-apple` / `-scuro`, `461-prospetti-sala`, `236-prospetti-finestra-stretta` e le scene
  «…-prospetto» di `Istantanee.swift` (27-44, 66, 69, 101, 102, 112, 211, 212; non 205, il TFR, che non passa da `SceltaProspetto`): partono dalla versione per il
  cliente o mostrano il timbro.
- Nuove: `466-prospetti-per-te` (versione per te con il timbro, chiara e scura; 462 è già di «Un anno insieme»),
  `463-prospetti-solo-per-il-cliente` (anno insieme, con l'etichetta).
- Prove: `ProvaProspetti` (`--prova-prospetti`) e `ProvaProspettiCompletezza`: il timbro non deve spostare l'impaginazione
  (stesso numero di pagine) e il testo estratto dal PDF per te contiene «SOLO PER TE», quello per il cliente no. Un caso
  per `conVersione` (tutti i casi tornano uguali con la stessa versione). La seconda lettura (`secondaLetturaProspetto`)
  non deve segnalare «SOLO PER TE».

### 22.6 Decisioni per l'utente e rischi

- **22-a La versione di partenza.** Il template parte da «Per il cliente»; oggi l'app parte dal prospetto per te.
  Proposta: «Per il cliente», e si ricorda l'ultima scelta finché Prisma resta aperto.
- **22-b Il timbro nel PDF.** La pagina a schermo è la stessa del PDF: il timbro entra anche nel PDF salvato. Proposta:
  sì, anche nel PDF (è il senso: un foglio per te stampato non finisce al cliente per sbaglio).
- **22-c Il portafoglio.** È tutto per te e parla di tutti i clienti. Proposta: timbro anche lì? Proposta: no, perché non
  si archivia né si mostra mai; basta l'etichetta «Solo per te».
- **22-d I documenti solo per te davanti al cliente.** Oggi posizione, confronto e riesame si possono presentare (il
  riesame presentato salva la fotografia, `fotografaRiesame(origine: .prospetto)`). Proposta: «Mostra al cliente» spento
  per questi, con l'aiuto «Questo documento è solo per te»; la fotografia del riesame resta dagli altri gesti di oggi.
  In alternativa: lasciarli presentabili senza timbro.
- Rischio: i `Prospetto*.swift` impaginano ognuno la sua prima pagina; per questo il timbro sta nell'avvolgimento di
  `conTimbroPerTe()` (punto 5) e non nelle testate. Va controllato a occhio che non copra il logo o l'etichetta del
  canale in alto a destra di nessuna prima pagina (istantanee 466 e le scene «…-prospetto»).

### 22.7 Dimensione

M (circa 300 righe). File: `Dati/Prospetto.swift`, `Shell/ProspettiApple.swift`, `Shell/AppProspetti.swift`,
`DesignSystem/ComponentiCarta.swift`, `DesignSystem/Carta.swift`, `DesignSystem/Apple/Tema.Apple+Prospetti.swift`,
`Shell/StampaCarta.swift` (`conTimbroPerTe`), `Shell/StatoShell.swift` (`documentoProspetto`), `Shell/ProvaProspetti.swift`.

---

## 23. L'elenco dei documenti si legge a colpo d'occhio

### 23.1 Nel template

Righe 3812-3816, 3822-3845 (`PGRUPPI`, i campi `g`, `a`, `lungo` di `PAG`, `prospettiUsoHTML`), regola a righe
2701-2704.

- **La colonna a sinistra** (`#pLista`, 300): in testa il cliente (`testaCli`, senza tendina: regola 2), poi i documenti
  **raggruppati per momento** con gli occhielli «Primo incontro», «Per una proposta», «Fine anno» (nel template; la regola
  dice: *i gruppi veri li decide l'elenco di oggi*). Ogni riga: il nome in neretto e sotto **una riga** che dice a cosa
  serve («La fotografia: cosa c'è e cosa manca», «Quanto versare e quando ci arriva», «Quanto servirebbe alla
  famiglia», «Il riepilogo dell'anno, da consegnare»), poi le etichette grigie «per il cliente» e, se c'è, «per te».
  Quello adatto all'incontro di oggi porta in più l'etichetta verde «per l'incontro di oggi».
- La riga scelta è accesa e **non si allarga**: la descrizione lunga sta dietro la «i» sopra la pagina, che apre una
  scheda «A cosa serve» con il nome e il testo lungo («Le quattro aree dell'analisi in una pagina. Per te: i numeri dietro
  ogni area, i dati che mancano e le ipotesi usate.»).
- Sotto i gruppi resta la card «Fascicolo dell'incontro» («I report scelti in un solo PDF, con la data dell'incontro.»,
  «Componi il fascicolo»).
- Scegliendo un'altra riga la pagina cambia nel verso giusto (giù = la pagina sale), come oggi.
- La nota grigia in fondo («In questo template i report completi sono pronti per Giulia Rossi…») è solo del template.

### 23.2 Nell'app oggi

- `barraLateraleApple` (`ProspettiApple.swift:137`): `RigaClienteProspettiApple` (con la tendina), il gruppo «Per
  l'incontro» con tredici voci (`tipiPerIncontro`, :101), «Prospetti di dettaglio» (riesame, posizione, confronto), «Per
  te» (portafoglio), la card del fascicolo, il piede con i collegamenti e la nota «Impaginati sul Mac…».
- Il sottotitolo delle voci è quasi sempre «Prospetto e report» (`sottotitoloVoce`, :208); «nuovo» per anno insieme.
- La voce scelta si allarga con tutte le scelte del documento (`voceApple`, :192 → `contenutoScelta`): il selettore, gli
  elenchi puntati di cosa c'è dentro, le note «le cifre vengono da…», i selettori di posizione, obiettivo, valutazione e il
  commento. La descrizione lunga è `TipoProspetto.descrizione` (`Dati/Prospetto.swift:96`).
- Il fascicolo sa già quali report servono per un appuntamento: `TipoProspetto.perIncontro(_:posizione:)`
  (`Shell/Fascicolo.swift:14`), dal tipo d'incontro e dalla posizione di cui si parla.

### 23.3 Cosa fare

1. **I gruppi.** In `ProspettiApple.swift` sostituire i tre gruppi con i gruppi per momento ricavati dall'elenco di oggi
   (decisione 23-a), come costante `static let gruppiPerMomento: [(String, [TipoProspetto])]`:
   - «Primo incontro»: Check-up primo incontro, Resoconto delle posizioni in essere, Il patrimonio nel tempo;
   - «Le analisi»: Prova di resistenza, Il costo degli investimenti, Passaggio generazionale, Capitale in scadenza e
     liquidità, Piano previdenziale, Protezione della famiglia, Piano obiettivo;
   - «Per una proposta»: Valutazione di un investimento, Sostituzione o confronto, Posizione o proposta, Confronto;
   - «Fine anno»: Un anno insieme, Riesame annuale;
   - «Per te» (non in modalità cliente): Il tuo portafoglio.
   `ordineVoci` (il verso della pagina) segue il nuovo ordine.
2. **La riga «a cosa serve».** Nuova proprietà `TipoProspetto.inBreve: String` in `Dati/Prospetto.swift`, una riga per
   tipo (decisione 23-b; i quattro del template come sono):
   - checkUp «La fotografia: cosa c'è e cosa manca»; obiettivo «Quanto versare e quando ci arriva»; protezione «Quanto
     servirebbe alla famiglia»; annoInsieme «Il riepilogo dell'anno, da consegnare»;
   - resoconto «Cosa ha e come sta andando»; patrimonio «Tutte le posizioni nei prossimi 20 anni»; resistenza «Se
     arrivassero tre anni difficili»; costi «Quanto costano gli investimenti»; successione «Cosa succede se venisse a
     mancare»; liquidita «I capitali in scadenza e la riserva»; previdenza «Quanto manca alla pensione che vuole»;
     valutazione «Un investimento da valutare, anno per anno»; sostituzione «Restare o cambiare»; posizione «Una
     posizione o una proposta in ogni dettaglio»; confronto «Due voci a fronte»; riesame «Per preparare il riesame»;
     portafoglio «Tutti i clienti insieme»; fascicolo «I report scelti in un solo PDF».
   `sottotitoloVoce` (`ProspettiApple.swift:208`) diventa `inBreve` (su più righe se serve: `lineLimit(2)`). Il segno
   «nuovo» di anno insieme (`voceNuova`, :219) resta.
3. **Le etichette** sotto la riga: «per il cliente» e «per te» (`Pillola` neutra piccola, o un token `etichettaVoce` nel
   colore `chip` e `inchiostro2`), secondo `SceltaProspetto.soloPer` e la scelta (miglioria 22). «nuovo» resta per anno
   insieme come oggi.
4. **«per l'incontro di oggi».** Se il cliente scelto ha un appuntamento di oggi non ancora concluso (solo oggi,
   decisione 23-c), si calcola `TipoProspetto.perIncontro(appuntamento, posizione:)` (`Shell/Fascicolo.swift:14`) una
   volta (dentro `stato.ricavato("prospetti-incontro-oggi|<cliente>")`) e si segna con l'etichetta verde (`Colore.verde` al 15% e testo
   verde scuro del tema, come gli stati «ok») il primo di quell'insieme nell'ordine dell'elenco (decisione 23-c).
5. **La riga non si allarga più.** In `voceApple` sotto la voce scelta restano solo le scelte che servono a impaginare
   (quale posizione, quale valutazione, quale obiettivo, le due voci del confronto e della sostituzione, gli anni, i
   report del fascicolo, il commento): via il selettore (miglioria 22), via gli elenchi puntati di cosa contiene il
   documento e le note «Le cifre vengono da…», che vanno nella scheda della «i». I documenti che non hanno scelte (check-up,
   costi, resistenza, …) non si allargano per niente, salvo il commento (decisione 23-d).
6. **La «i» sopra la pagina** (accanto al selettore della miglioria 22): un pulsante rotondo 32 con `info.circle`
   (`.appleSobrio`), aiuto «A cosa serve». Apre un `popover` del tema Apple (o un dettaglio piccolo) con l'occhiello «A
   cosa serve», il nome grande (24 bold) e `TipoProspetto.descrizione`; sotto, le note «da dove vengono le cifre» che
   oggi stanno nella colonna (spostarle in una `TipoProspetto.fonti: String`, dai testi di oggi di `scelta…`).
7. **Il cliente in testa** alla colonna: con la miglioria 2 `RigaClienteProspettiApple` perde la tendina e mostra solo il
   cliente scelto. Il piede (collegamenti e nota «Impaginati sul Mac…») non è nel template (decisione 23-e).
8. **Token** in `Tema.Apple+Prospetti.swift`, `enum Laterale`: la larghezza resta `Disposizione.larghezzaLaterale` (`Misura.Laterale.prospetti`; il template
   dice 300: si cambia solo il valore del token, se l'utente lo vuole), `etichettaVoce`
   (11,5 semibold, padding 2×8, capsula), `spazioEtichette` 5, `sopraEtichette` 5, `etichettaIncontro` (colori dello
   stato «ok»), `pulsanteInfo` 32.
9. **Testi**: i nomi dei gruppi, le righe `inBreve`, «per il cliente», «per te», «per l'incontro di oggi», «A cosa
   serve».

Cosa NON fare: non portare `docDisp`, `consP` (nel template il segno è scritto a mano per Giulia) né la nota del template
in fondo alla colonna; non togliere i selettori di posizione, valutazione, obiettivo e confronto: senza, il documento non
si impagina.

### 23.4 Dati, archivio, privacy

Nessun campo nuovo. Privacy: il gruppo «Per te» (portafoglio) resta nascosto in modalità cliente, come oggi
(`stato.inModoCliente`).

### 23.5 Istantanee e prove

- Aggiornare `460-prospetti-apple` / `-scuro`, `236-prospetti-finestra-stretta`, `81-fascicolo`, `82-agenda-fascicolo`.
- Nuove: `464-prospetti-elenco-incontro-oggi` (Giulia con l'appuntamento di oggi: l'etichetta verde),
  `465-prospetti-info` (la scheda «A cosa serve» aperta, se si cattura; altrimenti uno screenshot all'utente).
- Prove: un controllo (in `--prova-calcoli` o in `ProvaProspetti`) che ogni `TipoProspetto` abbia `inBreve` non vuoto e
  stia in esattamente un gruppo (lo `switch` completo lo garantisce già per `inBreve`).

### 23.6 Decisioni per l'utente e rischi

- **23-a I gruppi per momento.** Il template ha «Primo incontro», «Per una proposta», «Fine anno» con quattro documenti;
  l'app ne ha diciotto. Proposta: i cinque gruppi del punto 1.
- **23-b Le righe «a cosa serve».** Proposta: i testi del punto 2 (quattro dal template, gli altri nuovi).
- **23-c Quanti segnare «per l'incontro di oggi».** `perIncontro` sceglie da uno a sei report. Il template ne segna uno.
  Proposta: segnarne uno (il primo, nell'ordine dell'elenco); il fascicolo li compone tutti, come oggi. E solo per un
  appuntamento di oggi (non dei prossimi giorni).
- **23-d Il commento del consulente.** Oggi è sotto la voce scelta per i report che lo prevedono. Proposta: resta lì,
  solo con «Per il cliente» acceso (il commento va nel report).
- **23-e Il piede della colonna.** Il template non ha i collegamenti a Posizioni, Prodotti, Documenti e Confronto né la
  nota «Impaginati sul Mac…». Proposta: toglierli (le app sono nel dock; la nota è la promessa del PDF locale, che resta
  nelle Impostazioni).
- Rischio: spostare gli elenchi puntati e le note dalla colonna alla «i» tocca diciotto funzioni `scelta…` di
  `AppProspetti.swift` condivise con l'iPad: farlo con un parametro `compatta` (Mac) e lasciare l'iPad com'è.

### 23.7 Dimensione

M (circa 350 righe). File: `Shell/ProspettiApple.swift`, `Shell/AppProspetti.swift`, `Dati/Prospetto.swift`,
`DesignSystem/Apple/Tema.Apple+Prospetti.swift`, istantanee di Prospetti.

---

## 24. Tre pulsanti nei Prospetti

### 24.1 Nel template

Righe 3817-3820, 3861-3868 (`montaProspettiUso`, `A.act`, `A.mount`), regola a righe 2705-2707; la base a riga 1294 e la
regola 1 a riga 3112.

- Nella riga in testa alla finestra (`#wAct`) tre pulsanti, sempre con il nome: **«Mostra al cliente»** (con il simbolo
  dello schermo: apre la vista pulita del cliente e la presentazione del documento; a tutto schermo o sull'iPad al tavolo
  — regola 1 — e prende il posto di «Presenta all'incontro» e «Al tavolo»), **«Salva PDF»** (blu), **«Altro ⌄»**, un menu
  con «Stampa…», «Archivia nei Documenti», «Chiedi a Vera di commentarlo».
- Senza cliente scelto, «Mostra al cliente», «Salva PDF» e «Altro» aprono la scelta del cliente.
- Nella finestra stretta non diventano icone senza nome: quelli che non ci stanno restano in «Altro».

### 24.2 Nell'app oggi

- `azioniApple` (`ProspettiApple.swift:360`) mette in fila fino a sei pulsanti più il collegamento «Archiviato in
  Documenti ↗»: «Chiedi a Vera», «Al tavolo» (`PulsanteAlTavolo`, `Shell/AlTavolo.swift`, solo macOS e non per il
  portafoglio), «Presenta all'incontro» (non per il portafoglio), «Stampa…», «Archivia nei Documenti» (non per il
  portafoglio, con la seconda lettura), «Salva PDF…» (blu, con la seconda lettura e il foglio della password,
  `ModuloSalvaPDF`).
- Nelle finestre strette `ViewThatFits` (:344) passa alle sole icone (`etichettaAzione(soloIcona:)`, :435): è il «prima»
  del template.
- I pulsanti stanno nella barra sopra la pagina, non nella riga in testa alla finestra (che arriva con la miglioria 4 del
  gruppo 01).

### 24.3 Cosa fare

1. **Tre pulsanti** al posto di `azioniApple`, nella riga in testa alla finestra (miglioria 4; fino ad allora nella barra
   sopra la pagina, a destra):
   - «Mostra al cliente» (`.apple`, simbolo dello schermo come nel pulsante della barra del gruppo 01): apre il pannello
     «Mostra al cliente» della miglioria 1 con il documento già scelto (a tutto schermo con `presentaApple` dalla pagina
     mostrata, o sull'iPad al tavolo con `ContestoTavolo` come fa oggi `PulsanteAlTavolo`). Sempre la versione per il
     cliente (miglioria 22, punto 6), anche verso l'iPad. Spento per il portafoglio e per i documenti solo per te
     (decisione 22-d), con l'aiuto che lo dice. Il riesame presentato continua a salvare la fotografia se resta
     presentabile (`presentaApple`, :445). Con la miglioria 58 del gruppo 10 (un solo modo di mostrare) `PulsanteAlTavolo`
     e `PannelloAlTavolo` escono dai Prospetti: la strada verso l'iPad è solo quella del pannello «Mostra al cliente».
   - «Salva PDF…» (`.applePrimario`): com'è oggi (seconda lettura, foglio della password), e l'avviso con la versione.
   - «Altro ⌄» (un `Menu` di SwiftUI con l'etichetta a capsula del tema, come la `capsula` di `DossierApple.swift:783`;
     il gruppo 01 non ha un menu comune «Altro»): «Stampa…»,
     «Archivia nei Documenti» (non per il portafoglio), «Chiedi a Vera di commentarlo» (solo se `scelta.spuntoVera !=
     nil`, spento mentre Vera scrive). Le voci che oggi hanno condizioni le tengono.
2. **Niente sole icone.** Togliere `ViewThatFits` e `etichettaAzione(soloIcona:)`. Se nella riga non c'è posto per
   «Mostra al cliente», anche lui va in «Altro» (`ViewThatFits` fra «tre pulsanti» e «Salva PDF + Altro con Mostra al
   cliente dentro»): «Salva PDF» tiene sempre la scritta.
3. **«Archiviato in Documenti ↗»** dopo l'archiviazione: resta come collegamento sobrio accanto ai pulsanti finché non si
   cambia documento (com'è), o diventa l'avviso «Archiviato in Documenti» con «Apri» (decisione 24-a).
4. **Senza cliente** (miglioria 2): i tre pulsanti aprono la scelta del cliente, come il template.
5. **Token**: nessuno nuovo se si usano gli stili dei pulsanti (`.apple`, `.applePrimario`) e la capsula di «Altro»;
   togliere da `Tema.Apple+Prospetti.swift` `Barra.larghezzaMinimaTitolo` se il titolo non divide più la riga con i
   pulsanti.
6. **Testi**: «Mostra al cliente», «Salva PDF…», «Altro», «Stampa…», «Archivia nei Documenti», «Chiedi a Vera di
   commentarlo», «Questo documento è solo per te».

Cosa NON fare: non togliere la seconda lettura né il foglio della password di «Salva PDF» e «Archivia»; «Al tavolo» non
sparisce dall'app: entra nel pannello «Mostra al cliente» della miglioria 1 (con la regola di oggi: mai il portafoglio).

### 24.4 Dati, archivio, privacy

Nessun campo nuovo. Privacy: il tavolo con l'iPad resta com'è (rete locale cifrata, le cifre del cliente all'iPad solo
dopo la conferma); il portafoglio non si mostra e non va al tavolo; «Mostra al cliente» porta solo la versione per il
cliente.

### 24.5 Istantanee e prove

- Aggiornare `460-prospetti-apple` / `-scuro` (tre pulsanti), `236-prospetti-finestra-stretta` (niente icone: «Mostra al
  cliente» dentro «Altro»), `461-prospetti-sala`, le scene del tavolo (`IstantaneeTavolo.swift`) se partono da «Al
  tavolo» di Prospetti.
- Prove: `--prova-tavolo` (a mano) — il contesto del tavolo nasce ora dal pannello «Mostra al cliente»: il documento e la
  pagina devono restare quelli di oggi (`ContestoTavolo(documento:pagina:clienteId:)`).

### 24.6 Decisioni per l'utente e rischi

- **24-a «Archiviato in Documenti».** Proposta: resta il collegamento di oggi accanto ai pulsanti, finché non si cambia
  documento.
- Rischio: «Mostra al cliente» dipende dal pannello della miglioria 1; se arriva dopo, il pulsante chiama per ora
  `presentaApple` (tutto schermo) e «Al tavolo» resta in «Altro» fino ad allora, così nessuna funzione si perde. La 58
  (gruppo 10) toglie `PulsanteAlTavolo` contando sulla 24: chi arriva per secondo controlla che la strada verso l'iPad
  ci sia ancora.

### 24.7 Dimensione

S (circa 120 righe). File: `Shell/ProspettiApple.swift`, `Shell/AlTavolo.swift` (solo l'ingresso),
`DesignSystem/Apple/Tema.Apple+Prospetti.swift`. Dipende da 1 e 4 (gruppo 01), 22 (questo gruppo) e si incrocia con 58
(gruppo 10).
