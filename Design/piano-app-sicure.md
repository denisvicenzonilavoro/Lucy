# Piano «App sicure» (23 novembre 2026)

Dal reel di Antonio Bartolucci (14 novembre 2026): «Hai fatto l'app con Lovable, Cursor o Claude? Prima di lanciarla
controlla queste cinque cose, ognuna può costarti migliaia di euro». La copertina nomina tre temi: **GDPR**,
**accessibilità**, **bollette del cloud**. Le altre due voci si sentono solo nel video: qui non sono riportate per non
inventarle; si aggiungono quando l'utente le scrive.

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
2. Accessibilità delle schermate Carta: verifica ECC e correzioni.
3. Testo per l'informativa ai clienti (cancellazione e backup) e registro dei trattamenti del consulente.
4. Promemoria dei potenziali fermi da 24 mesi (se l'utente lo approva).
5. Prisma AI: le tre regole (GDPR, EAA, tetti di spesa) nel suo CLAUDE.md, quando l'utente riapre quel lavoro.
