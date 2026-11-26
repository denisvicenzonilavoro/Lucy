### Fluidità · commit 7382d0f

Tempi del thread principale. Mediana e massimo = aggiornamento (mediana e massimo su 3 giri, 2 con le app pesanti, dopo un giro di riscaldamento) + un disegno per azione. Aggiornamento = azione, run loop e impaginazione; disegno = cacheDisplay completo; prima volta = aggiornamento del giro di riscaldamento; corpi = body rivalutati delle viste che leggono StatoShell (con Observation, al posto degli objectWillChange di prima); avvisi StatoFinestre = proprietà osservate di StatoFinestre cambiate (shell, dock, barra, pannelli) durante l'azione.

| Scenario | Azione | Mediana | Massimo | Aggiornamento | Disegno | Prima volta | Corpi rivalutati | Avvisi StatoFinestre |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| 5 clienti | avvio (stato, dati e primo disegno) | 598 ms | 1570 ms | 598 ms | — | — | — | — |
| 5 clienti | apri Clienti | 452 ms | 527 ms | 452 ms | — | 1612 ms | 24 | 3 |
| 5 clienti | chiudi Clienti | 95 ms | 114 ms | 95 ms | — | 167 ms | 6 | 2 |
| 5 clienti | apri Posizioni | 520 ms | 527 ms | 520 ms | — | 637 ms | 15 | 3 |
| 5 clienti | chiudi Posizioni | 82 ms | 82 ms | 82 ms | — | 86 ms | 6 | 2 |
| 5 clienti | apri Analisi 360 | 212 ms | 233 ms | 212 ms | — | 277 ms | 11 | 3 |
| 5 clienti | chiudi Analisi 360 | 74 ms | 75 ms | 74 ms | — | 74 ms | 6 | 2 |
| 5 clienti | apri Incontri | 276 ms | 299 ms | 276 ms | — | 378 ms | 14 | 3 |
| 5 clienti | chiudi Incontri | 89 ms | 90 ms | 89 ms | — | 90 ms | 6 | 2 |
| 5 clienti | apri Agenda | 317 ms | 340 ms | 317 ms | — | 402 ms | 15 | 3 |
| 5 clienti | chiudi Agenda | 100 ms | 135 ms | 100 ms | — | 125 ms | 6 | 2 |
| 5 clienti | apri Messaggi | 177 ms | 211 ms | 177 ms | — | 203 ms | 16 | 3 |
| 5 clienti | chiudi Messaggi | 87 ms | 94 ms | 87 ms | — | 71 ms | 6 | 2 |
| 5 clienti | apri Pratiche | 189 ms | 215 ms | 189 ms | — | 236 ms | 13 | 3 |
| 5 clienti | chiudi Pratiche | 89 ms | 96 ms | 89 ms | — | 83 ms | 6 | 2 |
| 5 clienti | apri Prospetti e report | 248 ms | 249 ms | 248 ms | — | 376 ms | 10 | 3 |
| 5 clienti | chiudi Prospetti e report | 87 ms | 95 ms | 87 ms | — | 86 ms | 6 | 2 |
| 5 clienti | apri Sala | 229 ms | 244 ms | 229 ms | — | 259 ms | 16 | 3 |
| 5 clienti | chiudi Sala | 84 ms | 85 ms | 84 ms | — | 86 ms | 7 | 2 |
| 5 clienti | apri Biblioteca | 119 ms | 120 ms | 119 ms | — | 228 ms | 10 | 3 |
| 5 clienti | chiudi Biblioteca | 71 ms | 77 ms | 71 ms | — | 73 ms | 6 | 2 |
| 5 clienti | apri Mercato | 142 ms | 144 ms | 142 ms | — | 176 ms | 26 | 3 |
| 5 clienti | chiudi Mercato | 89 ms | 93 ms | 89 ms | — | 83 ms | 6 | 2 |
| 5 clienti | apri Studio | 186 ms | 202 ms | 186 ms | — | 206 ms | 12 | 3 |
| 5 clienti | chiudi Studio | 73 ms | 74 ms | 73 ms | — | 73 ms | 6 | 2 |
| 5 clienti | apri Lucy | 206 ms | 224 ms | 206 ms | — | 363 ms | 15 | 3 |
| 5 clienti | chiudi Lucy | 78 ms | 79 ms | 78 ms | — | 91 ms | 6 | 2 |
| 5 clienti | apri Impostazioni | 186 ms | 198 ms | 186 ms | — | 322 ms | 8 | 3 |
| 5 clienti | chiudi Impostazioni | 77 ms | 78 ms | 77 ms | — | 79 ms | 6 | 2 |
| 5 clienti | passa all'app sotto (2 aperte) | 93 ms | 97 ms | 93 ms | — | 259 ms | 8 | 2 |
| 5 clienti | riduci Posizioni | 221 ms | 306 ms | 221 ms | — | 280 ms | 8 | 3 |
| 5 clienti | ripristina Posizioni | 220 ms | 248 ms | 220 ms | — | 238 ms | 8 | 3 |
| 5 clienti | riduci a finestra Clienti | 132 ms | 134 ms | 132 ms | — | 171 ms | 4 | 3 |
| 5 clienti | ingrandisci Clienti | 70 ms | 83 ms | 70 ms | — | 70 ms | 4 | 2 |
| 5 clienti | blocca (schermata di benvenuto) | 34 ms | 35 ms | 34 ms | — | 65 ms | 7 | 2 |
| 5 clienti | sblocca | 19 ms | 20 ms | 19 ms | — | 15 ms | 5 | 2 |
| 5 clienti | apri il centro notifiche | 179 ms | 184 ms | 179 ms | — | 212 ms | 1 | 1 |
| 5 clienti | chiudi il centro notifiche | 36 ms | 41 ms | 36 ms | — | 32 ms | 0 | 1 |
| 5 clienti | apri la ricerca (⌘K) | 182 ms | 323 ms | 182 ms | — | 253 ms | 5 | 1 |
| 5 clienti | chiudi la ricerca (⌘K) | 29 ms | 36 ms | 29 ms | — | 83 ms | 0 | 1 |
| 5 clienti | aspetto scuro | 653 ms | 836 ms | 653 ms | — | 583 ms | 9 | 0 |
| 5 clienti | aspetto chiaro | 659 ms | 660 ms | 659 ms | — | 673 ms | 9 | 0 |
| 5 clienti | modifica una nota (un tasto) | 38 ms | 40 ms | 38 ms | — | 40 ms | 1 | 0 |
| 5 clienti | annulla la modifica | 38 ms | 42 ms | 38 ms | — | 41 ms | 1 | 0 |
| 5 clienti | mostra la scrivania | 303 ms | 328 ms | 303 ms | — | 351 ms | 9 | 4 |
| 5 clienti | riapri le app (2) | 295 ms | 319 ms | 295 ms | — | 328 ms | 9 | 6 |
| 5 clienti | sposta Clienti (un passo) | 17 ms | 19 ms | 17 ms | — | 42 ms | 4 | 1 |
| 5 clienti | Luce · apri la Sala | 246 ms | 246 ms | 246 ms | — | 226 ms | 15 | 3 |
| 5 clienti | Luce · chiudi la Sala | 82 ms | 92 ms | 82 ms | — | 82 ms | 6 | 2 |
| 5 clienti | Luce · apri il sole del piano | 159 ms | 204 ms | 159 ms | — | 246 ms | 17 | 3 |
| 5 clienti | Luce · chiudi il sole del piano | 269 ms | 279 ms | 269 ms | — | 280 ms | 15 | 2 |
| 5 clienti | Luce · apri Pratiche | 158 ms | 169 ms | 158 ms | — | 155 ms | 12 | 3 |
| 5 clienti | Luce · chiudi Pratiche | 67 ms | 69 ms | 67 ms | — | 66 ms | 5 | 2 |
| 5 clienti | apri gli spazi di lavoro | 104 ms | 111 ms | 104 ms | — | 286 ms | 1 | 1 |
| 5 clienti | chiudi gli spazi di lavoro | 22 ms | 29 ms | 22 ms | — | 33 ms | 0 | 1 |
| 5 clienti | apri il menu delle app | 40 ms | 42 ms | 40 ms | — | 140 ms | 1 | 1 |
| 5 clienti | chiudi il menu delle app | 12 ms | 13 ms | 12 ms | — | 12 ms | 0 | 1 |
| 5 clienti | apri «Le tue app aperte» | 54 ms | 67 ms | 54 ms | — | 71 ms | 5 | 1 |
| 5 clienti | chiudi «Le tue app aperte» | 20 ms | 22 ms | 20 ms | — | 25 ms | 0 | 1 |
| 200 clienti | avvio (stato, dati e primo disegno) | 1993 ms | 2333 ms | 1993 ms | — | — | — | — |
| 200 clienti | apre 4 app pesanti (prima volta) | 2530 ms | 2530 ms | 2530 ms | — | — | 229 | 12 |
| 200 clienti | chiudi Clienti | 103 ms | 115 ms | 103 ms | — | 55 ms | 8 | 2 |
| 200 clienti | apri Clienti | 383 ms | 390 ms | 383 ms | — | 433 ms | 17 | 3 |
| 200 clienti | chiudi Posizioni | 111 ms | 113 ms | 111 ms | — | 69 ms | 8 | 2 |
| 200 clienti | apri Posizioni | 476 ms | 488 ms | 476 ms | — | 479 ms | 14 | 3 |
| 200 clienti | apri Analisi 360 | 114 ms | 117 ms | 114 ms | — | 136 ms | 12 | 3 |
| 200 clienti | chiudi Analisi 360 | 79 ms | 80 ms | 79 ms | — | 82 ms | 9 | 2 |
| 200 clienti | apri Incontri | 1083 ms | 1154 ms | 1083 ms | — | 991 ms | 17 | 3 |
| 200 clienti | chiudi Incontri | 254 ms | 294 ms | 254 ms | — | 191 ms | 9 | 2 |
| 200 clienti | chiudi Agenda | 179 ms | 181 ms | 179 ms | — | 164 ms | 8 | 2 |
| 200 clienti | apri Agenda | 946 ms | 980 ms | 946 ms | — | 1047 ms | 212 | 3 |
| 200 clienti | apri Messaggi | 299 ms | 326 ms | 299 ms | — | 533 ms | 16 | 3 |
| 200 clienti | chiudi Messaggi | 86 ms | 101 ms | 86 ms | — | 75 ms | 6 | 2 |
| 200 clienti | apri Pratiche | 190 ms | 190 ms | 190 ms | — | 605 ms | 13 | 3 |
| 200 clienti | chiudi Pratiche | 66 ms | 68 ms | 66 ms | — | 63 ms | 6 | 2 |
| 200 clienti | chiudi Prospetti e report | 56 ms | 57 ms | 56 ms | — | 52 ms | 5 | 2 |
| 200 clienti | apri Prospetti e report | 85 ms | 85 ms | 85 ms | — | 88 ms | 8 | 3 |
| 200 clienti | apri Sala | 99 ms | 102 ms | 99 ms | — | 96 ms | 16 | 3 |
| 200 clienti | chiudi Sala | 59 ms | 59 ms | 59 ms | — | 56 ms | 6 | 2 |
| 200 clienti | apri Biblioteca | 138 ms | 140 ms | 138 ms | — | 188 ms | 10 | 3 |
| 200 clienti | chiudi Biblioteca | 77 ms | 84 ms | 77 ms | — | 85 ms | 6 | 2 |
| 200 clienti | apri Mercato | 143 ms | 147 ms | 143 ms | — | 134 ms | 26 | 3 |
| 200 clienti | chiudi Mercato | 83 ms | 84 ms | 83 ms | — | 84 ms | 6 | 2 |
| 200 clienti | apri Studio | 217 ms | 219 ms | 217 ms | — | 226 ms | 12 | 3 |
| 200 clienti | chiudi Studio | 68 ms | 68 ms | 68 ms | — | 74 ms | 6 | 2 |
| 200 clienti | apri Lucy | 248 ms | 261 ms | 248 ms | — | 223 ms | 15 | 3 |
| 200 clienti | chiudi Lucy | 87 ms | 87 ms | 87 ms | — | 79 ms | 6 | 2 |
| 200 clienti | apri Impostazioni | 239 ms | 248 ms | 239 ms | — | 233 ms | 8 | 3 |
| 200 clienti | chiudi Impostazioni | 101 ms | 105 ms | 101 ms | — | 101 ms | 6 | 2 |
| 200 clienti | passa all'app sotto (4 aperte) | 98 ms | 115 ms | 98 ms | — | 89 ms | 12 | 2 |
| 200 clienti | riduci Posizioni | 118 ms | 118 ms | 118 ms | — | 83 ms | 9 | 3 |
| 200 clienti | ripristina Posizioni | 140 ms | 148 ms | 140 ms | — | 147 ms | 9 | 3 |
| 200 clienti | riduci a finestra Clienti | 85 ms | 87 ms | 85 ms | — | 144 ms | 9 | 3 |
| 200 clienti | ingrandisci Clienti | 77 ms | 82 ms | 77 ms | — | 83 ms | 6 | 2 |
| 200 clienti | blocca (schermata di benvenuto) | 63 ms | 65 ms | 63 ms | — | 75 ms | 7 | 2 |
| 200 clienti | sblocca | 39 ms | 43 ms | 39 ms | — | 35 ms | 5 | 2 |
| 200 clienti | apri il centro notifiche | 297 ms | 298 ms | 297 ms | — | 303 ms | 1 | 1 |
| 200 clienti | chiudi il centro notifiche | 58 ms | 58 ms | 58 ms | — | 62 ms | 0 | 1 |
| 200 clienti | apri la ricerca (⌘K) | 194 ms | 294 ms | 194 ms | — | 108 ms | 5 | 1 |
| 200 clienti | chiudi la ricerca (⌘K) | 71 ms | 99 ms | 71 ms | — | 102 ms | 0 | 1 |
| 200 clienti | aspetto scuro | 926 ms | 1026 ms | 926 ms | — | 920 ms | 11 | 0 |
| 200 clienti | aspetto chiaro | 1014 ms | 1149 ms | 1014 ms | — | 866 ms | 11 | 0 |
| 200 clienti | modifica una nota (un tasto) | 4 ms | 4 ms | 4 ms | — | 5 ms | 0 | 0 |
| 200 clienti | annulla la modifica | 6 ms | 7 ms | 6 ms | — | 5 ms | 0 | 0 |
| 200 clienti | mostra la scrivania | 260 ms | 261 ms | 260 ms | — | 324 ms | 13 | 4 |
| 200 clienti | riapri le app (4) | 258 ms | 275 ms | 258 ms | — | 259 ms | 13 | 12 |
| 200 clienti | sposta Clienti (un passo) | 37 ms | 40 ms | 37 ms | — | 58 ms | 6 | 1 |
| 200 clienti | Luce · apri la Sala | 123 ms | 124 ms | 123 ms | — | 120 ms | 19 | 3 |
| 200 clienti | Luce · chiudi la Sala | 84 ms | 85 ms | 84 ms | — | 84 ms | 9 | 2 |
| 200 clienti | Luce · apri il sole del piano | 173 ms | 184 ms | 173 ms | — | 1951 ms | 19 | 3 |
| 200 clienti | Luce · chiudi il sole del piano | 338 ms | 342 ms | 338 ms | — | 349 ms | 17 | 2 |
| 200 clienti | Luce · apri Pratiche | 197 ms | 199 ms | 197 ms | — | 206 ms | 14 | 3 |
| 200 clienti | Luce · chiudi Pratiche | 88 ms | 91 ms | 88 ms | — | 87 ms | 7 | 2 |
| 200 clienti | apri gli spazi di lavoro | 112 ms | 117 ms | 112 ms | — | 126 ms | 1 | 1 |
| 200 clienti | chiudi gli spazi di lavoro | 45 ms | 49 ms | 45 ms | — | 49 ms | 0 | 1 |
| 200 clienti | apri il menu delle app | 50 ms | 52 ms | 50 ms | — | 70 ms | 1 | 1 |
| 200 clienti | chiudi il menu delle app | 30 ms | 31 ms | 30 ms | — | 34 ms | 0 | 1 |
| 200 clienti | apri «Le tue app aperte» | 83 ms | 84 ms | 83 ms | — | 136 ms | 9 | 1 |
| 200 clienti | chiudi «Le tue app aperte» | 37 ms | 37 ms | 37 ms | — | 37 ms | 0 | 1 |

Disegno non disponibile sul server di build: misurato solo l'aggiornamento.
Memoria: all'inizio: 116 MB residenti, 104 MB di impronta · 5 clienti, dopo l'avvio: 213 MB residenti, 218 MB di impronta · 5 clienti, dopo il giro delle app: 267 MB residenti, 214 MB di impronta · 5 clienti, alla fine (shell aperta): 365 MB residenti, 291 MB di impronta · dopo lo scenario con 5 clienti (shell chiusa): 277 MB residenti, 187 MB di impronta · 200 clienti, dopo l'avvio: 333 MB residenti, 288 MB di impronta · 200 clienti, dopo il giro delle app: 428 MB residenti, 314 MB di impronta · 200 clienti, alla fine (shell aperta): 437 MB residenti, 322 MB di impronta · dopo lo scenario con 200 clienti (shell chiusa): 381 MB residenti, 257 MB di impronta.

Memoria alla fine: 381 MB residenti, 257 MB di impronta · durata della prova: 131.7 s.
