# Migliorie d'uso · Mac — cosa resta da fare

Una sezione per miglioria: ciò che il giro non ha potuto fare (o ha fatto solo in parte) e va ripreso.

## 7. Testi piccoli più leggibili

Fatto: `inchiostro2`, `inchiostro3` e il nuovo `arancioTesto` (#B4530B / #F5A94A) nel tema Apple, `scadenza` che diventa
`arancioTesto`, il tema di prima allineato (`inchiostroSecondario`, `inchiostroTerziario`), una sessantina di token di
testo arancione passati ad `arancioTesto` (più tre usi diretti nelle viste: nota del backup, contatore del sinistro,
«fuori» del radar), la prova del contrasto (`ProvaCalcoliLeggibilita` in `--prova-calcoli`). Tutto solo sul Mac
(`#if os(macOS)`): su iPhone e iPad `arancioTesto` vale l'arancione pieno e i grigi restano quelli di prima.

Resta:
- **Istantanee**: rigenerarle tutte sul Mac (chiare e scure) e aggiornare la pagina delle anteprime; guardare per prime
  «400-vetrina-apple», «410-scrivania-apple», Agenda, Studio › Parcelle e le scadenze.
- **Token rimasti all'arancione pieno** perché colorano insieme un pallino e il suo testo, o sono timbri e glifi grandi
  (da rivedere guardando le istantanee): `Tema.Apple.Impostazioni…Stato.attenzione` («● Pronto»),
  `Tema.Apple.Tavolo.coloreInAttesa`, `Tema.Apple.Vera…nonPronto` (testo e pallino in `VeraScrivania`),
  `Tema.Apple.FaseCinqueVera.avviso`, i timbri della notte (`piuTardi`, `rimandata`), `Tema.Apple.Ovunque…coloreConflitto`,
  `Colori.Note.fissata` (il ◆). Se uno di questi è un testo piccolo, dividerlo in due token (segno e testo).
- **Tema di prima**: `Tema.Colore.arancio` (#FF9500) e i suoi token non sono toccati (la specifica parla solo del tema
  Apple); `scadenzaVicina` e simili restano com'erano.
- **Segni con `inchiostro3`** (assi, tratteggi, maniglia di ridimensionamento): diventano più scuri come nel template; se
  qualche tratteggio pesa troppo nelle istantanee, un token a parte per i segni.
- I file `Tema.Apple+Telefono.swift`, `Tema.Apple+TavoloiPad.swift` e `Tema.Apple+Luce.swift` (iPhone, iPad e glifi)
  non sono passati in rassegna: arriveranno con l'aggiornamento di iPhone e iPad.
