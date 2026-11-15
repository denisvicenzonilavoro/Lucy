# Prisma · Migliorie d'uso · Mac — specifica

Fonte: `Design/template-uso.html` (14 novembre 2026): 70 migliorie d'uso, **solo Mac**, nessuna funzione nuova e nessun
cambio di stile. iPhone e iPad arrivano con l'aggiornamento successivo: fino ad allora ogni cambiamento in codice comune
sta dentro `#if os(macOS)` (o in file solo Mac) e le istantanee di iPhone e iPad restano uguali.

Il pannello «✦ Migliorie» del template, il cartellino arancione che indica dove guardare e le schede che spiegano una
miglioria servono solo a presentare il template: **non si portano nell'app**. Cifre e nomi del template sono
dimostrativi: le cifre le danno i motori di Prisma, i nomi l'archivio.

## I gruppi (una sezione per miglioria, con 7 sottosezioni: template, app oggi, cosa fare, dati e privacy, istantanee e
prove, decisioni e rischi, dimensione)

| Gruppo | Migliorie | File |
|---|---|---|
| 01 · Tutta Prisma | 1-10 | Design/uso/gruppo-01.md |
| 02 · Clienti, Posizioni, Analisi 360 | 11-17 | Design/uso/gruppo-02.md |
| 03 · Agenda, Incontri, Prospetti | 18-24 | Design/uso/gruppo-03.md |
| 04 · Messaggi, Vera, Parcelle, Mercato, Impostazioni | 25-31 | Design/uso/gruppo-04.md |
| 05 · Territorio, Pratiche, Sala, Biblioteca, dock | 32-36 | Design/uso/gruppo-05.md |
| 06 · Dimostrazione, canali, iPhone e iPad | 37-39 | Design/uso/gruppo-06.md |
| 07 · Radar, prova del fuoco, smontaggio, Inquadra, Aggiorna valori | 40-44 | Design/uso/gruppo-07.md |
| 08 · Simulatore, famiglie, potenziali, passaparola, campagne, mese, giro | 45-51 | Design/uso/gruppo-08.md |
| 09 · Studio | 52-57 | Design/uso/gruppo-09.md |
| 10 · Sala: mostrare, copione, ricordo | 58-60 | Design/uso/gruppo-10.md |
| 11 · Cerca, documento, parole, app aperte, conferme | 61, 62, 66, 67, 68 | Design/uso/gruppo-11.md |
| 12 · Prodotti, Simula e confronta, Note, TFR, fascicolo | 63, 64, 65, 69, 70 | Design/uso/gruppo-12.md |

## Ordine dei giri (dalle dipendenze)

1. **Giro 1** — 7, 8 (colori), 10, 9 (parole), 2 (un solo posto per il cliente), 4 (una riga sola in testa).
2. **Giro 2** — 6 (barre più corte), 3 (un solo «Da fare»), 5 (il dossier parte dal quadro), 1 (Mostra al cliente).
3. **Giro 3** — 13, 17, 11, 12, 16, 14, 15 (Clienti, Posizioni, Analisi 360).
4. **Giro 4** — 36, 30, 31, 38, 39, 37 (dock, Impostazioni, canali, collegamento, dimostrazione).
5. **Giro 5** — 18, 21, 20, 19, 22, 23, 24 (Agenda, Incontri, Prospetti).
6. **Giro 6** — 26, 25, 27, 28, 29, 32, 33, 34, 35.
7. **Giro 7** — 40, 41, 43, 42, 44.
8. **Giro 8** — 45, 46, 47, 48, 49, 50, 51.
9. **Giro 9** — 52, 53, 54, 55, 56, 57.
10. **Giro 10** — 59, 58, 60.
11. **Giro 11** — 66, 67, 68, 61, 62.
12. **Giro 12** — 63, 64, 65, 69, 70.

Ogni giro: un branch di lavoro (`uso/giri`), build verde nel workflow, poi unione in main.

## Decisioni (le quattro principali confermate dall'utente il 15 novembre 2026: colori solo Mac, etichetta «Qwen», nessun campo nuovo nei prodotti, fascicolo in memoria)

Regola generale: dove la specifica di un gruppo dà una «proposta», vale la proposta. In più:

- **Colori (7, 8)**: i token nuovi valgono solo sul Mac (`#if os(macOS)`); iPhone e iPad li prendono con il loro
  aggiornamento. I PDF tengono i loro colori fissi.
- **Etichetta del motore sotto le risposte di Vera (9)**: resta com'è («Qwen») finché l'utente non decide, perché è una
  regola bloccata del «cervello grande». Si tolgono solo gli altri nomi tecnici in vista (stato di Vera, «Smista», «Motori»
  passano in Impostazioni › Vera).
- **Modalità cliente (1)**: sul Mac il pulsante è uno solo, «Mostra al cliente», che usa la modalità cliente di oggi
  sotto; iPhone e iPad la tengono com'è.
- **Cliente scelto (2)**: all'apertura si riparte dal cliente salvato; i recenti solo in memoria; nessun campo nuovo.
- **Prodotti (63)**: nessun campo nuovo in `Prodotto`; le frasi le propone il codice dai dati del prodotto.
- **Fascicolo (70)**: la scelta del fascicolo resta in memoria.
- **Note (65)**: in modalità cliente si vede solo la nota in evidenza, in sola lettura.
- **Campi d'archivio nuovi** (25, 38, 39, 60, 65): solo quelli indicati nella specifica, con posto in `ArchivioPezzi.pezzo`,
  backup e `ProvaBackupArchivioPezzi` aggiornati; mai in «Prisma ovunque» se la specifica non lo dice.
- **Numerazione delle istantanee nuove**: 1000 + 10 × miglioria/… come nelle specifiche, riallineata giro per giro
  dove due gruppi usano gli stessi numeri.
