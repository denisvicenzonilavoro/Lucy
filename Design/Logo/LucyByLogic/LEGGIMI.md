# Lucy by Logic — loghi

Prisma diventa **Lucy** (app per consulenti), Prisma AI diventa **Lucy AI** (app per i clienti), la società è **Logic**.

## Prompt per Claude Code

> Lavora con ECC (Everything Claude Code). Nella cartella `LucyByLogic-loghi` ci sono i nuovi loghi e le nuove icone. Prisma diventa Lucy, Prisma AI diventa Lucy AI, la società è Logic. Sostituisci in tutto il progetto i vecchi loghi, le icone dell'app e i nomi mostrati all'utente, seguendo le regole del file `LEGGIMI.md`. Non cambiare colori, proporzioni o caratteri dei loghi.

## Cosa c'è

| Cartella | File |
|---|---|
| `logic/` | logo per fondo chiaro e per fondo scuro (SVG e PNG); avatar quadrato 1024, scuro e chiaro |
| `lucy/` | logo (simbolo + nome), logo completo (con «by LOGIC»), simbolo da solo |
| `lucy/icone/` | icona iPhone/iPad 1024 scura (principale) e chiara (alternativa); icona Mac 1024 con la forma già arrotondata e i margini trasparenti |
| `lucy-ai/` | logo e logo completo, per fondo chiaro e scuro |
| `lucy-ai/icone/` | icona iPhone 1024 oro (principale) e scura (per la modalità scura) |

Negli SVG le scritte sono già trasformate in tracciati: non serve nessun font installato.
I file «fondo-scuro» hanno il testo chiaro: su fondo bianco non si vedono, è normale.

## Colori

| Uso | Colore |
|---|---|
| Fondo scuro | `#100E0B` |
| L e testo su fondo scuro | `#F0E7D4` (avorio) |
| L e testo su fondo chiaro | `#16130F` (inchiostro) |
| Fondo chiaro | `#F4EEE2` (carta) |
| Oro su fondo scuro (disco, cursore, «AI», sfondo icona Lucy AI) | `#CDA04A` |
| Oro su fondo chiaro | `#BF923D` |
| «by» su fondo scuro | `#A69B86` |
| «by» su fondo chiaro | `#6B6152` |

Tutti i colori sono pieni: niente sfumature, ombre o riflessi.

## Caratteri (Google Fonts, gratuiti)

- «Lucy»: **Newsreader** SemiBold 600, dimensione ottica 72
- «LOGIC» e «AI»: **Hanken Grotesk** Bold 700, spaziatura +0,06 em («AI» +0,04 em)
- «by»: Hanken Grotesk Medium 500

## Il simbolo: la L di luce

In un quadrato di lato S, con l'origine in alto a sinistra:

- la L è squadrata, con angoli vivi; asta e base sono spesse **0,255 S**
- il disco ha raggio **0,305 S** e sta a **0,052 S** dalla L su entrambi i lati, quindi il centro è in (**0,612 S**, **0,388 S**)
- nel logo il simbolo è alto quanto la L di «Lucy»

## Il cursore di Logic

- È una barra d'oro al posto della I, con gli angoli appena arrotondati (raggio pari al 20% della larghezza).
- Misure, in em del carattere di «LOGIC»: larga **0,1**, alta **1,067**; la cima sta **0,867** sopra la riga di base, quindi sporge sopra le maiuscole e sotto la riga.
- Posizione: la barra inizia a **2,221 em** dall'inizio della L, la C a **2,466 em**.
- Lampeggia: ciclo di **1,1 s**, metà acceso e metà spento, senza dissolvenza. Con «Riduci movimento» attivo resta fisso.

```css
.logic-cursore { animation: lampeggio 1.1s step-end infinite; }
@keyframes lampeggio { 0%, 49% { opacity: 1 } 50%, 100% { opacity: 0 } }
@media (prefers-reduced-motion: reduce) { .logic-cursore { animation: none } }
```

Negli SVG il cursore ha già la classe `logic-cursore`.

## Animazione di avvio (Lucy e Lucy AI)

Nell'app si vede una volta sola all'apertura.

| Tempo | Cosa succede |
|---|---|
| 0,25 – 0,9 s | la L compare salendo di 8 punti |
| 0,8 – 1,6 s | il disco d'oro cresce da zero con un piccolo rimbalzo (curva `0.3, 1.45, 0.5, 1`) |
| 1,5 – 2,1 s | «Lucy» (o «Lucy AI») entra scorrendo di 10 punti da sinistra |
| 2,1 – 2,6 s | compare «by LOGIC», con il cursore che lampeggia |

Con «Riduci movimento» attivo, mostrare subito il logo completo.

## Regole d'uso

- Su fondo chiaro usare i file «fondo-chiaro», su fondo scuro i file «fondo-scuro».
- Attorno al logo lasciare libero almeno lo spazio del raggio del disco.
- Misure minime: simbolo 16 px; logo completo 120 px di larghezza.
- Icone iPhone/iPad: PNG 1024 senza trasparenza, gli angoli li arrotonda il sistema. Mac: usare il file «mac», che ha già la forma.
- Lucy e Lucy AI hanno lo stesso simbolo: si distinguono dall'icona (nera per Lucy, oro per Lucy AI) e dalla scritta «AI».
