# Piano «App sicure» (23 novembre 2026)

Dal reel di Antonio Bartolucci (14 novembre 2026, trascrizione data dall'utente): cinque rischi per chi scrive un'app con
l'AI, ognuno da migliaia di euro.

| # | Il rischio del video | Prisma (sul Mac, niente server) | Prisma AI (server UE, utenti veri) |
|---|---|---|---|
| 1 | Sito statico su un hosting che fattura a gigabyte: un attacco DDoS e arriva un conto da 104.500 $ (Netlify) | Nessun sito, nessun hosting: non si applica | Landing su un hosting a prezzo fisso o con tetto di spesa che **ferma** il servizio (non solo un avviso), dietro una protezione dai DDoS; mai a consumo senza limite |
| 2 | Sito non navigabile da tastiera, immagini senza testo alternativo: European Accessibility Act dal giugno 2025, multe AgID da 5 a 40.000 € (chi ha almeno 10 dipendenti e 2 milioni di fatturato) | Uso personale del consulente; le schermate mostrate al cliente rese accessibili lo stesso (§2) | App al pubblico: tastiera, VoiceOver, testo alternativo, contrasto, dichiarazione di accessibilità prima del lancio |
| 3 | Database Supabase con la RLS spenta: chiunque legge tutti gli utenti con la chiave pubblica. È un data breach: 72 ore per dirlo al Garante, multe fino a 10 milioni o al 2% del fatturato | Nessun database in rete; i dati stanno sul Mac (FileVault), i backup possono essere cifrati, «Prisma ovunque» è cifrato | Già nelle regole: ogni tabella nasce chiusa. In più: una prova automatica che con la chiave pubblica nessuna tabella si legga, prima di ogni rilascio; la procedura delle 72 ore scritta prima del lancio |
| 4 | SMS alla waitlist senza consenso esplicito: il Codice Privacy lo vieta (75.000 € a un ateneo telematico) | Le campagne lasciano fuori chi non ha il consenso commerciale; il messaggio singolo e l'inclusione a mano lo chiedono, e ora la conferma dice il divieto del Codice Privacy; Prisma non spedisce mai da solo | Nessun messaggio promozionale senza un consenso a parte, non preselezionato, registrato con la data; la lista d'attesa solo con quel consenso |
| 5 | Una funzione che richiama se stessa: gli avvisi di budget mandano una mail e basta, sveglia con 72.000 $ di Google Cloud | Nessun servizio a consumo; i lavori di Vera hanno limiti fissi (al più 5 passi, al più 10 bozze di notte, stop al primo avviso di memoria) | Tetto di spesa che spegne le funzioni, non solo un avviso; nessuna funzione che ne chiama altre senza un limite di profondità; tetto di domande per utente (c'è già) |

Il piano vale per le due app, che hanno regole diverse (CLAUDE.md):
- **Prisma** (questa, per il consulente): tutto in locale, nessun server, nessun utente esterno. Il consulente è
  titolare del trattamento dei dati dei suoi clienti.
- **Prisma AI** (app gratuita per i clienti, repository privato a parte, da non sviluppare finché l'utente non lo chiede):
  server gestito nell'Unione Europea, utenti veri, AI attraverso un server. Lì i tre temi pesano di più.

## 1. GDPR

| Cosa | Prisma | Prisma AI | Stato |
|---|---|---|---|
| Diritto di accesso e portabilità (art. 15, 20) | «Esporta i dati del cliente…» nel menu «Altro» del dossier: un file JSON con tutto ciò che Prisma conserva della persona (il suo file della cartella a pezzi, appuntamenti e attività), salvato dove sceglie il consulente (`EsportazioneCliente`, prova in `--prova-backup`) | esportazione dall'account | Prisma: fatto |
| Cancellazione (art. 17) | «Elimina il cliente» c'è già; i backup lo tengono fino alla rotazione (sigillo: 12 settimane, poi una copia al mese per 24 mesi): va scritto nell'informativa | cancellazione dell'account e delle richieste | da scrivere nell'informativa |
| Registro dei trattamenti (art. 30) | documento del consulente: cosa conserva Prisma, dove, per quanto (dalla sezione «Dati e privacy» di CLAUDE.md) | registro del titolare dell'app | da preparare |
| Conservazione | potenziali clienti: nessuna cancellazione automatica (scelta dell'utente); proposta: un promemoria in «Da sistemare» per i potenziali fermi da 24 mesi | segnalazioni cancellate dopo 30 giorni (già nelle regole) | proposta |
| Fornitori | nessuno (tutto sul Mac; iCloud solo cifrato per «Prisma ovunque») | Supabase UE, Mistral: contratti DPA prima del lancio | Prisma AI |

## 2. Accessibilità (European Accessibility Act, in vigore dal 28 giugno 2025)

- Prisma: uso personale del consulente, ma le schermate mostrate al cliente (modalità cliente, Sala, tavolo dell'iPad)
  devono essere leggibili da tutti. Già fatto: contrasto almeno 4,5 per i colori Carta (prova `ProvaTemaCarta`),
  «Riduci movimento», «Dimensione del testo». In corso: verifica ECC (a11y-architect) delle schermate Carta, con le
  correzioni di VoiceOver, tastiera e colore.
- Prisma AI: app al pubblico, l'EAA si applica in pieno: VoiceOver, Dynamic Type, contrasto, tocchi da 44 pt, mai
  un'informazione data solo dal colore; dichiarazione di accessibilità prima del lancio.

## 3. Bollette del cloud

- Prisma: costo zero per costruzione (niente server, niente API a consumo; Vera in locale con Ollama).
- Prisma AI (proposta per le sue regole, da decidere dall'utente): tetto di spesa mensile su Supabase e sul fornitore
  del modello, avvisi al 50% e all'80%, tetto di domande per utente (c'è già), niente funzioni a consumo senza limite,
  un solo ambiente di prova piccolo.

## Tappe

1. Esportazione dei dati del cliente: fatta.
2. Accessibilità delle schermate Carta: verifica ECC (a11y-architect) fatta e corretta in gran parte: il cedolino si
   sceglie anche con un pulsante (tastiera e VoiceOver), etichette e tratti per VoiceOver (interruttore «Note di Vera»,
   esiti del timbro letti come «superato» o «da rivedere», glifi nascosti, titoli), aree di tocco da 44 pt sull'iPad,
   ⌘P per stampare il fascicolo, oro delle scritte a #856300 (contrasto almeno 4,5 anche sul foglio), testi mai sotto
   gli 11 pt. I testi delle viste Carta seguono «Dimensione del testo» di Prisma (`fontCarta`, `TestoCarta`, che leggono
   `\.prismaScalaTesto` come `carattereApple`). Resta da fare: le coppie di contrasto sulla velina e sugli sfondi vivi
   nella prova.
3. Testo per l'informativa ai clienti (cancellazione e backup) e registro dei trattamenti del consulente.
4. Promemoria dei potenziali fermi da 24 mesi (se l'utente lo approva).
5. Prisma AI: le regole della tabella qui sopra (hosting con tetto che ferma, accessibilità, prova automatica della
   RLS e procedura delle 72 ore, consenso a parte per i messaggi promozionali, tetti di spesa che spengono) nel suo
   CLAUDE.md, quando l'utente riapre quel lavoro (è un repository a parte: da qui non si tocca).
6. Sicurezza di Prisma: controllo ECC fatto (nessun dato esce dal Mac, nessuna chiamata di rete nuova, lettere di Prisma
   AI spente). Proposta: un avviso in «Da sistemare» quando i backup sono in chiaro (oggi il backup senza password
   conta «a posto»), perché un disco esterno o una cartella iCloud persi sarebbero una violazione da comunicare entro
   72 ore. Da decidere dall'utente: cambia una voce che oggi è «a posto».
