#if os(macOS)
import Foundation

// Migliorie d'uso 30 «Le impostazioni si cercano, in gruppi con un nome» (Design/uso/gruppo-04.md §30), solo Mac.
//
// - I gruppi della colonna: «Da sistemare» (la Panoramica, migliorie d'uso 31) da sola in cima, poi «Prisma», «Il lavoro» e «Aiuto» (`gruppi`).
// - L'indice delle voci: una voce per ogni riga delle pagine del Mac (titolo e spiegazione scritti come nella riga; per
//   le spiegazioni che cambiano con lo stato la forma fissa più utile), con la pagina, l'ancora a cui scorrere e qualche
//   sinonimo. La ricerca guarda solo questi testi dell'interfaccia, mai i dati scritti dall'utente (nomi dei clienti,
//   cartelle).
// - `cerca(_:)`: senza maiuscole né accenti, sul titolo, sulla spiegazione, sul nome della pagina e sui sinonimi; i
//   risultati nell'ordine delle sezioni della colonna, senza classifica (come il template).
//
// ATTENZIONE: l'indice è scritto a mano e può restare indietro rispetto alle righe vere. Quando si aggiunge, toglie o
// rinomina una riga di una pagina delle Impostazioni, si aggiorna l'indice nello stesso commit. Le ancore nuove si
// chiamano «imp-<pagina>-<voce>» (la pagina è il rawValue di `SchedaImpostazioni`): `AppImpostazioni.paginaDellAncora`
// le risolve da sole. La prova `ProvaIndiceImpostazioni` (in `--prova-calcoli`) controlla pagine, doppioni e ancore.

/// I testi della colonna e della ricerca delle Impostazioni.
enum TestiImpostazioni {
    static let gruppoPrisma = "Prisma"
    static let gruppoLavoro = "Il lavoro"
    static let gruppoAiuto = "Aiuto"
    static let cerca = "Cerca nelle impostazioni"
    static let apri = "Apri"
    static let provaAltraParola = "Prova con un’altra parola: «backup», «testo», «promemoria»…"

    /// «3 risultati per «backup»», «1 risultato per «backup»», «Nessun risultato per «xyz»».
    static func risultati(_ n: Int, _ testo: String) -> String {
        switch n {
        case 0: return "Nessun risultato per «\(testo)»"
        case 1: return "1 risultato per «\(testo)»"
        default: return "\(n) risultati per «\(testo)»"
        }
    }
}

/// Un gruppo della colonna delle Impostazioni (il primo senza nome).
struct GruppoColonnaImpostazioni {
    let titolo: String?
    let pagine: [SchedaImpostazioni]
}

/// Una riga di una pagina delle Impostazioni, per la ricerca.
struct VoceIndiceImpostazioni {
    let titolo: String
    let spiegazione: String
    let pagina: SchedaImpostazioni
    /// Il punto della pagina a cui scorrere (nil: la pagina dall'alto).
    var ancora: String? = nil
    /// Sinonimi utili per la ricerca («copia», «password», «dark»…).
    var parole: [String] = []
}

enum IndiceImpostazioni {
    /// I gruppi della colonna, dall'alto in basso. Le pagine che il template non ha stanno in «Il lavoro» accanto a
    /// quelle con cui lavorano (§30.6).
    static let gruppi: [GruppoColonnaImpostazioni] = [
        GruppoColonnaImpostazioni(titolo: nil, pagine: [.panoramica]),
        GruppoColonnaImpostazioni(titolo: TestiImpostazioni.gruppoPrisma,
                                  pagine: [.aspetto, .ovunque, .archivio, .vera, .profilo]),
        GruppoColonnaImpostazioni(titolo: TestiImpostazioni.gruppoLavoro,
                                  pagine: [.studio, .mercato, .lavoro, .promemoria, .conformita, .proposte, .moduli,
                                           .pratiche, .portafogliModello, .rendimenti, .sala, .territorio]),
        GruppoColonnaImpostazioni(titolo: TestiImpostazioni.gruppoAiuto, pagine: [.scorciatoie, .strumenti]),
    ]

    /// Le pagine della colonna nell'ordine in cui si vedono.
    static var pagineInColonna: [SchedaImpostazioni] { gruppi.flatMap { $0.pagine } }

    /// Il testo da confrontare: senza maiuscole né accenti, con l'apostrofo tipografico come quello della tastiera.
    static func piega(_ testo: String) -> String {
        testo.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Formati.italiano)
            .replacingOccurrences(of: "’", with: "'")
    }

    /// Le voci che contengono il testo (nel titolo, nella spiegazione, nel nome della pagina o nei sinonimi),
    /// nell'ordine delle sezioni della colonna. Testo vuoto (o solo spazi): nessuna voce.
    static func cerca(_ testo: String) -> [VoceIndiceImpostazioni] {
        let q = piega(testo.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !q.isEmpty else { return [] }
        let ordine = pagineInColonna
        let trovate = voci.enumerated().filter { _, v in
            ([v.titolo, v.spiegazione, v.pagina.titolo] + v.parole).contains { piega($0).contains(q) }
        }
        return trovate.sorted { a, b in
            let pa = ordine.firstIndex(of: a.element.pagina) ?? ordine.count
            let pb = ordine.firstIndex(of: b.element.pagina) ?? ordine.count
            return pa != pb ? pa < pb : a.offset < b.offset
        }.map { $0.element }
    }

    // MARK: Le voci

    private typealias V = VoceIndiceImpostazioni

    /// Le righe delle pagine del Mac, pagina per pagina nell'ordine della colonna.
    static let voci: [VoceIndiceImpostazioni] = [
        daSistemare, aspetto, ovunque, archivio, vera, profilo, studio, mercato, lavoro, promemoria, conformita, proposte, moduli,
        pratiche, portafogli, rendimenti, sala, territorio, scorciatoie, strumenti,
    ].flatMap { $0 }

    /// Migliorie d'uso 31: la prima voce della colonna.
    private static let daSistemare: [V] = [
        V(titolo: "Da sistemare", spiegazione: "Cosa manca perché Prisma sia a posto, con «Sistema» per ogni cosa.",
          pagina: .panoramica, parole: ["panoramica", "stato", "problemi", "a posto"]),
    ]

    private static let aspetto: [V] = [
        V(titolo: "Aspetto", spiegazione: "Chiaro, scuro o automatico come il Mac.", pagina: .aspetto,
          parole: ["tema", "dark", "scuro", "chiaro", "notte"]),
        V(titolo: "Sfondo", spiegazione: "Acqua con le gocce al rallentatore.", pagina: .aspetto,
          parole: ["scrivania", "animato", "fermo"]),
        V(titolo: "Pioggia", spiegazione: "Quante gocce cadono.", pagina: .aspetto, parole: ["gocce"]),
        V(titolo: "L'acqua della scrivania", spiegazione: "Pioggia sempre attiva. Toccando l'acqua cade una goccia.",
          pagina: .aspetto),
        V(titolo: "Riduci movimento", spiegazione: "Animazioni brevi e acqua ferma.", pagina: .aspetto,
          parole: ["animazioni", "accessibilità"]),
        V(titolo: "Dimensione del testo", spiegazione: "Normale, grande, molto grande.", pagina: .aspetto,
          parole: ["carattere", "font", "grandezza", "leggibilità"]),
        V(titolo: "Schermo intero", spiegazione: "Tutto lo schermo a Prisma.", pagina: .aspetto,
          ancora: "imp-aspetto-finestra", parole: ["finestra"]),
        V(titolo: "Guida per cominciare", spiegazione: "Sulla scrivania, finché non è finita.", pagina: .aspetto,
          ancora: "imp-aspetto-aiuto", parole: ["aiuto"]),
        V(titolo: "Come funziona Prisma", spiegazione: "L'introduzione e le parole della finanza.", pagina: .aspetto,
          ancora: "imp-aspetto-aiuto", parole: ["aiuto", "glossario", "guida"]),
    ]

    /// Migliorie d'uso 39: le voci della pagina in un collegamento solo (testi del template, §39.1).
    private static let ovunque: [V] = [
        V(titolo: "I tuoi dispositivi", spiegazione: "iPhone e iPad collegati al Mac.", pagina: .ovunque,
          parole: ["iPhone", "iPad", "collegati"]),
        V(titolo: "Collega un dispositivo", spiegazione: "Una volta, con un codice.", pagina: .ovunque,
          parole: ["codice", "abbinamento", "ponte"]),
        V(titolo: "I dati", spiegazione: "Copia cifrata in iCloud Drive.", pagina: .ovunque,
          parole: ["Prisma ovunque", "sincronizzazione", "iCloud", "copia cifrata"]),
        V(titolo: "Vera su iPhone e iPad", spiegazione: "Usano Vera del Mac, dalla rete di casa.", pagina: .ovunque,
          parole: ["ponte", "Qwen"]),
        V(titolo: "Inquadra un documento", spiegazione: "Con la fotocamera dell’iPhone.", pagina: .ovunque,
          parole: ["fotocamera", "polizza", "carta d'identità"]),
        V(titolo: "Nota a voce", spiegazione: "Dettata all’iPhone.", pagina: .ovunque, parole: ["nota vocale", "dettatura"]),
        V(titolo: "Al tavolo", spiegazione: "L’iPad davanti al cliente.", pagina: .ovunque, parole: ["tavolo", "iPad"]),
        V(titolo: "Lavora anche con il Mac spento",
          spiegazione: "Dal cliente, in treno, ovunque: al ritorno le modifiche si uniscono da sole.", pagina: .ovunque),
        V(titolo: "Porta anche i potenziali clienti",
          spiegazione: "I potenziali clienti (persone che non sono ancora clienti) vanno su iPhone e iPad, cifrati.",
          pagina: .ovunque),
        V(titolo: "Modifiche in attesa", spiegazione: "Dall’iPhone di stamattina.",
          pagina: .ovunque, parole: ["da decidere", "conflitti", "unire"]),
        V(titolo: "Cartella", spiegazione: "La cartella di iCloud Drive dello spazio cifrato.", pagina: .ovunque),
        V(titolo: "Passphrase", spiegazione: "Solo tua: Prisma non la conserva. Su questo Mac la chiave sta nel Portachiavi.",
          pagina: .ovunque, parole: ["password", "chiave"]),
    ]

    private static let archivio: [V] = [
        V(titolo: "Crea backup", spiegazione: "Copia completa di clienti, agenda, posizioni, documenti e impostazioni di Vera.",
          pagina: .archivio, parole: ["copia", "salva"]),
        V(titolo: "Backup automatico settimanale", spiegazione: "Ogni settimana; tengo le ultime \(GestoreBackup.massimo) copie.",
          pagina: .archivio, parole: ["copia", "automatico"]),
        V(titolo: "Dove salvare", spiegazione: "Una cartella di iCloud Drive o un disco esterno.", pagina: .archivio,
          parole: ["cartella", "disco", "iCloud"]),
        V(titolo: "Ripristina", spiegazione: "Torna a una copia precedente, anche salvata altrove.", pagina: .archivio,
          parole: ["copia", "recupera"]),
        V(titolo: "Proteggi con una password", spiegazione: "AES-256, password nel Portachiavi.", pagina: .archivio,
          parole: ["cifrato", "cifratura", "sicurezza"]),
        V(titolo: "Escludi la Biblioteca dal backup", spiegazione: "Circolari e manuali interni possono essere riservati.",
          pagina: .archivio, ancora: "imp-archivio-biblioteca", parole: ["documenti", "PDF"]),
        V(titolo: "Backup disponibili", spiegazione: "Le copie salvate, da ripristinare.", pagina: .archivio,
          ancora: "imp-archivio-elenco", parole: ["copia"]),
        V(titolo: "Sul Mac", spiegazione: "L'archivio di Prisma, da mostrare nel Finder.", pagina: .archivio,
          ancora: "imp-archivio-mac", parole: ["Finder", "dati"]),
    ]

    private static let vera: [V] = [
        V(titolo: "Motore", spiegazione: "Qwen sul Mac, solo indirizzi locali.", pagina: .vera,
          parole: ["Qwen", "Ollama", "intelligenza artificiale"]),
        V(titolo: "iPhone e iPad", spiegazione: "Si collegano in Impostazioni › iPhone e iPad.",
          pagina: .vera, parole: ["ponte", "codice"]),
        V(titolo: "Scorciatoia", spiegazione: "Apri la mini Vera; tienila premuta per parlare.", pagina: .vera,
          parole: ["tasto", "mini Vera"]),
        V(titolo: TestiNotte.rigaAttivo, spiegazione: "Prepara le cose di domani mentre non usi Prisma.", pagina: .vera,
          ancora: TestiNotte.ancoraImpostazioni, parole: ["stanotte", "notte"]),
        V(titolo: TestiNotte.rigaBozze, spiegazione: TestiNotte.notaBozze, pagina: .vera, ancora: TestiNotte.ancoraImpostazioni),
        V(titolo: TestiNotte.rigaApri, spiegazione: "Una volta, dopo lo sblocco; mai con un cliente davanti.", pagina: .vera,
          ancora: TestiNotte.ancoraImpostazioni),
        V(titolo: TestiNotte.rigaNotifica, spiegazione: "All'inizio della mattina di lavoro.", pagina: .vera,
          ancora: TestiNotte.ancoraImpostazioni),
        V(titolo: "Modello", spiegazione: "Il nome in Ollama.", pagina: .vera, ancora: "imp-vera-come"),
        V(titolo: "Ragionamento", spiegazione: "Sulle domande difficili.", pagina: .vera, ancora: "imp-vera-come"),
        V(titolo: "Ragiona a passi", spiegazione: "Divide un budget tra protezione e obiettivi.", pagina: .vera,
          ancora: "imp-vera-come"),
        V(titolo: "Mostra il ragionamento", spiegazione: "Il piano e la regola accanto alla risposta.", pagina: .vera,
          ancora: "imp-vera-come"),
        V(titolo: "Pronta all'avvio", spiegazione: "La prima risposta non aspetta.", pagina: .vera, ancora: "imp-vera-come"),
        V(titolo: "Conserva le conversazioni", spiegazione: "Nel dossier, sul Mac e nei backup.", pagina: .vera,
          ancora: "imp-vera-come", parole: ["chat"]),
        V(titolo: "Vera ricorda", spiegazione: "Propone i ricordi, li salva dopo il tuo sì.", pagina: .vera,
          ancora: "imp-vera-memoria", parole: ["memoria"]),
        V(titolo: "Impara dalle correzioni", spiegazione: "👍 e 👎 sotto le risposte.", pagina: .vera,
          ancora: "imp-vera-memoria", parole: ["lezioni"]),
        V(titolo: "Il sussurro", spiegazione: "Due o tre cose da sapere quando apri un cliente.", pagina: .vera,
          ancora: "imp-vera-memoria"),
        V(titolo: "Il filo lungo", spiegazione: "La memoria della conversazione.", pagina: .vera, ancora: "imp-vera-memoria"),
        V(titolo: "Ricerca per significato", spiegazione: "Modello in Ollama, solo quando serve.", pagina: .vera,
          ancora: "imp-vera-memoria"),
        V(titolo: "La memoria di Vera", spiegazione: "I ricordi e le lezioni salvati.", pagina: .vera,
          ancora: "imp-vera-memoria"),
        V(titolo: "Il tuo stile", spiegazione: "Come scrivi: Vera segue le tue regole, mai testi copiati.", pagina: .vera,
          ancora: "imp-vera-stile", parole: ["scrive come te", "tono"]),
        V(titolo: "Vera su misura", spiegazione: "Esempi approvati e resi anonimi; l'esame resta sul Mac.", pagina: .vera,
          ancora: "imp-vera-motori"),
        V(titolo: "Due velocità", spiegazione: "Prima le regole di Prisma, poi Qwen sul Mac. Il modello Apple è spento.",
          pagina: .vera, ancora: "imp-vera-motori"),
        V(titolo: "Motore esterno",
          spiegazione: "Solo per le conversazioni generali: i dati dei clienti non escono mai dal Mac.", pagina: .vera,
          ancora: "imp-vera-motori"),
        V(titolo: "Chi risponde", spiegazione: "Etichetta sotto ogni risposta · sempre accesa", pagina: .vera,
          ancora: "imp-vera-motori"),
        V(titolo: "Controllo notturno", spiegazione: "Doppioni, campi vuoti, consensi e documenti.", pagina: .vera,
          ancora: "imp-vera-tagliando", parole: ["tagliando"]),
        V(titolo: "Ora del controllo", spiegazione: "Con il Mac acceso e Prisma aperto.", pagina: .vera,
          ancora: "imp-vera-tagliando", parole: ["tagliando"]),
        V(titolo: "Ultimo controllo", spiegazione: "Quando e che cosa ha trovato il tagliando dei dati.", pagina: .vera,
          ancora: "imp-vera-tagliando", parole: ["tagliando"]),
        V(titolo: "Fornitore e indirizzo", spiegazione: "Ollama o compatibile OpenAI · solo indirizzi del Mac.",
          pagina: .vera, ancora: "imp-vera-avanzate", parole: ["avanzate", "127.0.0.1"]),
    ]

    private static let profilo: [V] = [
        V(titolo: "Il tuo nome", spiegazione: "Come ti accoglie la scrivania.", pagina: .profilo, parole: ["nome"]),
        // Migliorie d'uso 38: i nomi dei canali e le tre domande del primo avvio
        V(titolo: "I tuoi canali", spiegazione: "I nomi scritti sulle due etichette.", pagina: .profilo,
          ancora: "imp-profilo-canali", parole: ["canale", "Alleanza", "indipendente", "etichetta"]),
        V(titolo: "Il primo avvio", spiegazione: "Le tre domande della prima volta.", pagina: .profilo,
          ancora: "imp-profilo-avvio", parole: ["benvenuto", "introduzione", "rivedi"]),
    ]

    private static let studio: [V] = [
        V(titolo: "Le tue aliquote Alleanza", spiegazione: "Per tipo di prodotto: nuova produzione e rate successive.",
          pagina: .studio, parole: ["provvigioni", "percentuali"]),
        V(titolo: "Anno", spiegazione: "Gli obiettivi valgono per un anno solo", pagina: .studio, parole: ["obiettivi"]),
        V(titolo: VoceObiettivoStudio.produzioneAlleanza.nome,
          spiegazione: "Versamenti iniziali e premi annui delle posizioni Alleanza con decorrenza nell’anno",
          pagina: .studio, parole: ["obiettivi"]),
        V(titolo: VoceObiettivoStudio.nuoviClienti.nome, spiegazione: "Clienti inseriti in Prisma nell’anno",
          pagina: .studio, parole: ["obiettivi"]),
        V(titolo: VoceObiettivoStudio.ricaviConsulenza.nome, spiegazione: "Parcelle della consulenza indipendente dell’anno",
          pagina: .studio, parole: ["obiettivi"]),
        V(titolo: "Da dove parti", spiegazione: "Una descrizione, per esempio «Studio di via Roma»: nessuna coordinata",
          pagina: .studio, ancora: TestiSpese.ancoraImpostazioni, parole: ["chilometri", "km", "spese"]),
        V(titolo: "Il mese di Studio › Spese",
          spiegazione: "Fino a questo giorno Studio mostra il mese prima, quello da chiudere col commercialista",
          pagina: .studio, ancora: TestiSpese.ancoraImpostazioni, parole: ["spese"]),
        V(titolo: "Appuntamenti senza cliente",
          spiegazione: "Contali fra le visite: i loro km solo con la correzione del giorno", pagina: .studio,
          ancora: TestiSpese.ancoraImpostazioni, parole: ["km", "spese"]),
        V(titolo: "Valore per km nel pacchetto",
          spiegazione: "Facoltativo: se lo vuoi, scrivilo tu (accordi o tabelle che usi). Vuoto: nessun euro per i km",
          pagina: .studio, ancora: TestiSpese.ancoraImpostazioni, parole: ["chilometri", "spese", "rimborso"]),
        V(titolo: "I km di andata e ritorno per cliente", spiegazione: "I km si scrivono per i clienti che visiti",
          pagina: .studio, ancora: TestiSpese.ancoraImpostazioni, parole: ["chilometri", "spese"]),
        V(titolo: "Ore richieste", spiegazione: "Le scrivi tu: Prisma non contiene i requisiti di IVASS o OCF",
          pagina: .studio, ancora: TestiSpese.ancoraImpostazioni, parole: ["aggiornamento professionale", "corsi"]),
        V(titolo: "Ente", spiegazione: "Facoltativo: compare accanto all’anello delle ore", pagina: .studio,
          ancora: TestiSpese.ancoraImpostazioni, parole: ["corsi"]),
        V(titolo: "Nomi dei clienti nel pacchetto", spiegazione: "Spento: dei giri solo data, km e numero di visite",
          pagina: .studio, ancora: TestiSpese.ancoraImpostazioni, parole: ["commercialista", "privacy"]),
        V(titolo: "Prisma prepara il file, non lo invia",
          spiegazione: "Il PDF e il file XML della fattura elettronica (tracciato FatturaPA).", pagina: .studio,
          ancora: TestiParcelle.ancoraImpostazioni, parole: ["fatture", "fattura elettronica", "parcelle"]),
        V(titolo: "Chi emette la fattura", spiegazione: "Nome, cognome o denominazione, partita IVA, codice fiscale, PEC.",
          pagina: .studio, ancora: TestiParcelle.ancoraImpostazioni, parole: ["fatture", "partita IVA", "codice fiscale"]),
        V(titolo: "Sede", spiegazione: "Indirizzo, CAP, comune e provincia della fattura.", pagina: .studio,
          ancora: TestiParcelle.ancoraImpostazioni, parole: ["fatture", "indirizzo"]),
        V(titolo: "Regime fiscale e IVA", spiegazione: "Il codice RF del tracciato, l'aliquota o la natura dell'operazione.",
          pagina: .studio, ancora: TestiParcelle.ancoraImpostazioni, parole: ["fatture", "forfettario", "IVA"]),
        V(titolo: "Contributo previdenziale", spiegazione: "Rivalsa o contributo integrativo della tua cassa.",
          pagina: .studio, ancora: TestiParcelle.ancoraImpostazioni, parole: ["fatture", "cassa"]),
        V(titolo: "Ritenuta d’acconto", spiegazione: "Se e come si applica sulle parcelle.", pagina: .studio,
          ancora: TestiParcelle.ancoraImpostazioni, parole: ["fatture"]),
    ]

    private static let mercato: [V] = [
        V(titolo: TestiAppMercato.interruttore, spiegazione: TestiAppMercato.interruttoreSpiegazione, pagina: .mercato,
          parole: ["BCE", "Eurostat", "internet"]),
        V(titolo: TestiAppMercato.ultimoAggiornamento, spiegazione: "Quando sono arrivate le ultime serie.", pagina: .mercato),
        V(titolo: TestiAppMercato.serieGruppo, spiegazione: "Le serie pubbliche di BCE ed Eurostat.", pagina: .mercato,
          parole: ["tassi", "inflazione"]),
        V(titolo: TestiAppMercato.soglieGruppo, spiegazione: "Quando un movimento del mercato diventa un avviso.",
          pagina: .mercato, parole: ["avvisi"]),
        V(titolo: TestiAppMercato.riferimentiGruppo, spiegazione: "Le quote dei fondi per ISIN.", pagina: .mercato,
          parole: ["ISIN", "fondi", "quote"]),
        V(titolo: TestiAppMercato.importaFile, spiegazione: TestiAppMercato.importaSpiegazione, pagina: .mercato,
          parole: ["CSV", "importa"]),
        V(titolo: TestiAppMercato.aMano, spiegazione: TestiAppMercato.datiNota, pagina: .mercato),
        V(titolo: TestiAppMercato.aggiornaPosizioni, spiegazione: "Il valore di oggi delle posizioni dalle quote importate.",
          pagina: .mercato),
    ]

    private static let lavoro: [V] = [
        V(titolo: "Giorni di lavoro", spiegazione: "«Pianifica» cerca solo qui", pagina: .lavoro, parole: ["orari", "agenda"]),
        V(titolo: "Mattina", spiegazione: "Anche orario continuato", pagina: .lavoro, parole: ["orari"]),
        V(titolo: "Pomeriggio", spiegazione: "Dopo la pausa pranzo", pagina: .lavoro, parole: ["orari"]),
        V(titolo: "Margine tra gli appuntamenti", spiegazione: "Prima e dopo ogni appuntamento", pagina: .lavoro,
          parole: ["pausa", "agenda"]),
        V(titolo: "Riesami al giorno", spiegazione: "Oltre, il riesame va al giorno dopo", pagina: .lavoro),
        V(titolo: "Festività", spiegazione: "Nazionali italiane", pagina: .lavoro, parole: ["ferie", "feste"]),
        V(titolo: "Recupera dopo", spiegazione: "Proposte senza risposta né appuntamento", pagina: .lavoro,
          parole: ["proposte", "seguito"]),
    ]

    private static let promemoria: [V] = [
        V(titolo: "Promemoria nel Centro notifiche", spiegazione: "Anche a Prisma chiusa", pagina: .promemoria,
          parole: ["notifiche", "avvisi"]),
        V(titolo: "Appuntamenti", spiegazione: "Prima dell'inizio, con il luogo", pagina: .promemoria, parole: ["notifiche"]),
        V(titolo: "Attività", spiegazione: "Il giorno di scadenza", pagina: .promemoria, parole: ["notifiche"]),
        V(titolo: "Scadenze delle polizze", spiegazione: "30 e 7 giorni prima e il giorno stesso", pagina: .promemoria,
          parole: ["notifiche", "polizze"]),
        V(titolo: "Compleanni dei clienti", spiegazione: "Il giorno stesso", pagina: .promemoria, parole: ["notifiche"]),
        V(titolo: "Occasioni", spiegazione: "Giorni prima e il giorno stesso", pagina: .promemoria, parole: ["notifiche"]),
        V(titolo: "Nomi dei clienti", spiegazione: "Spento: solo l'ora e cosa fare", pagina: .promemoria,
          parole: ["privacy", "notifiche"]),
        V(titolo: "Nel calendario", spiegazione: "Settimana e mese dell'Agenda", pagina: .promemoria,
          ancora: "impostazioni-occasioni", parole: ["occasioni"]),
        V(titolo: "Anticipo", spiegazione: "Notifiche e promemoria del Mac", pagina: .promemoria,
          ancora: "impostazioni-occasioni", parole: ["occasioni"]),
        V(titolo: "Età limite delle coperture", spiegazione: "Controlla quelle del prodotto", pagina: .promemoria,
          ancora: "impostazioni-occasioni", parole: ["occasioni", "età"]),
    ]

    private static let conformita: [V] = [
        V(titolo: "Validità", spiegazione: "Poi il profilo va aggiornato", pagina: .conformita,
          parole: ["questionario", "adeguatezza", "Alleanza"]),
        V(titolo: "Validità", spiegazione: "Ogni quanto si aggiorna il profilo", pagina: .conformita,
          parole: ["questionario", "adeguatezza", "indipendente"]),
        V(titolo: "Rinnovo per rischio", spiegazione: "Antiriciclaggio", pagina: .conformita,
          ancora: "impostazioni-conformita", parole: ["AML"]),
        V(titolo: "Anche sul canale indipendente", spiegazione: "Se sei tenuto all'antiriciclaggio", pagina: .conformita,
          ancora: "impostazioni-conformita"),
        V(titolo: "Consenso commerciale", spiegazione: "Ogni quanto riconfermarlo", pagina: .conformita,
          ancora: "impostazioni-conformita", parole: ["privacy", "consensi"]),
        V(titolo: "Informativa privacy aggiornata il", spiegazione: "Chi l'ha firmata prima la riceve di nuovo",
          pagina: .conformita, ancora: "impostazioni-conformita", parole: ["privacy"]),
    ]

    private static let proposte: [V] = [
        V(titolo: "Documenti da consegnare", spiegazione: "Per canale: quelli spenti non compaiono nelle schede delle proposte.",
          pagina: .proposte, parole: ["proposte", "Alleanza", "indipendente"]),
        V(titolo: "Aggiungi un documento", spiegazione: "Un documento in più da consegnare con le proposte.",
          pagina: .proposte),
        V(titolo: "Ripristina l'elenco di Prisma",
          spiegazione: "Torna ai documenti predefiniti dei due canali: le spunte già messe nelle schede restano.",
          pagina: .proposte),
        V(titolo: "Proponi la password", spiegazione: "Protezione già attiva al salvataggio", pagina: .proposte,
          ancora: "impostazioni-pdf", parole: ["PDF", "protezione"]),
        V(titolo: "Password proposta", spiegazione: "Dai dati del cliente", pagina: .proposte, ancora: "impostazioni-pdf",
          parole: ["PDF"]),
    ]

    private static let moduli: [V] = [
        V(titolo: "Moduli da preparare", spiegazione: "Carica i PDF veri che usi per il canale indipendente",
          pagina: .moduli, parole: ["compila da solo", "PDF"]),
        V(titolo: "Conserva l'IBAN nel dossier", spiegazione: "Spento: l'IBAN si scrive solo sul modulo, ogni volta",
          pagina: .moduli, parole: ["conto", "banca"]),
    ]

    private static let pratiche: [V] = [
        V(titolo: "Ferma dopo", spiegazione: "Oltre questi giorni senza un passo nuovo la pratica è segnata in rosso",
          pagina: .pratiche, parole: ["pratiche ferme"]),
        V(titolo: "Indirizzi dei sinistri", spiegazione: "Il sollecito apre una bozza in Mail all'indirizzo della compagnia",
          pagina: .pratiche, parole: ["compagnia", "sollecito", "sinistri"]),
        V(titolo: "Documenti per tipo di sinistro",
          spiegazione: "Gli elenchi li dai tu, per tipo e compagnia: Prisma non li inventa", pagina: .pratiche,
          parole: ["sinistri"]),
        V(titolo: "Fermo dopo",
          spiegazione: "Oltre questi giorni senza un fatto nuovo il sinistro compare fra le cose da sistemare",
          pagina: .pratiche, parole: ["sinistri fermi"]),
    ]

    private static let portafogli: [V] = [
        V(titolo: "Tolleranza generale", spiegazione: "Oltre questa distanza dal modello il cliente è «fuori» sul radar",
          pagina: .portafogliModello, parole: ["radar"]),
        V(titolo: "Il modello di ogni cliente", spiegazione: "Il portafoglio modello con cui si confronta ogni cliente.",
          pagina: .portafogliModello, parole: ["radar"]),
        V(titolo: "Pesi delle classi", spiegazione: TestiRadar.leggendaClassi, pagina: .portafogliModello,
          parole: ["azioni", "obbligazioni"]),
        V(titolo: "Tolleranza del modello", spiegazione: "Vuota: vale quella generale", pagina: .portafogliModello),
    ]

    private static let rendimenti: [V] = [
        V(titolo: TestiRiferimenti.gruppoMetro, spiegazione: "Il riferimento con cui si confronta ogni tipo di posizione.",
          pagina: .rendimenti, parole: ["benchmark", "confronto"]),
        V(titolo: TestiRiferimenti.gruppoValori, spiegazione: "I rendimenti dei riferimenti, un anno alla volta.",
          pagina: .rendimenti),
        V(titolo: TestiRiferimenti.aggiungiIndice, spiegazione: "Un indice tuo, con il nome e la fonte.",
          pagina: .rendimenti, parole: ["indici"]),
        V(titolo: TestiRiferimenti.valoriRivisti, spiegazione: "L'ultima revisione dei valori.", pagina: .rendimenti,
          parole: ["fonti"]),
        V(titolo: TestiFamiglie.gruppo, spiegazione: "Le tavole della Banca d'Italia per il confronto con le famiglie.",
          pagina: .rendimenti, ancora: TestiFamiglie.ancoraImpostazioni, parole: ["Banca d'Italia", "famiglie"]),
    ]

    private static let sala: [V] = [
        V(titolo: "Durata della partita", spiegazione: "Quanti anni si lanciano prima della fine", pagina: .sala,
          parole: ["Lancia l'anno"]),
        V(titolo: "Gli imprevisti", spiegazione: "Un evento esce a caso solo con la probabilità annua e la fonte.",
          pagina: .sala, parole: ["Lancia l'anno", "probabilità"]),
        V(titolo: "Prepara anche il file per il browser", spiegazione: "Sperimentale: da provare prima su iPhone e Android veri",
          pagina: .sala, parole: ["Prisma del cliente"]),
        V(titolo: TestiRealta.scattoConStanzaTitolo, spiegazione: "Di base lo scatto è solo il cristallo su fondo neutro",
          pagina: .sala, parole: ["realtà aumentata", "foto"]),
    ]

    private static let territorio: [V] = [
        V(titolo: "Fattore strada", spiegazione: "La linea d'aria per questo numero: i km stimati", pagina: .territorio,
          parole: ["distanze", "km"]),
        V(titolo: "Velocità nello stesso comune", spiegazione: "Media stimata in città", pagina: .territorio,
          parole: ["distanze"]),
        V(titolo: "Velocità fra comuni", spiegazione: "Media stimata fuori città", pagina: .territorio, parole: ["distanze"]),
        V(titolo: "Minuti minimi di un tratto", spiegazione: "Parcheggio e uscita compresi", pagina: .territorio),
        V(titolo: "Deviazione massima", spiegazione: "Per proporre un cliente «lungo la strada»", pagina: .territorio,
          parole: ["giro"]),
        V(titolo: "Visita breve", spiegazione: "La durata dell'appuntamento proposto dal Territorio", pagina: .territorio,
          parole: ["giro"]),
        V(titolo: "Partenza del giro", spiegazione: "Il comune da cui parti.", pagina: .territorio),
        V(titolo: "Torna alla sede dello studio", spiegazione: "La sede si scrive in Impostazioni › Studio › Fatturazione",
          pagina: .territorio, parole: ["giro"]),
        V(titolo: "Le zone sono i comuni", spiegazione: "Puoi raggruppare più comuni in una zona tua", pagina: .territorio,
          parole: ["zone"]),
        V(titolo: "L'anello arancio", spiegazione: "Accende l'anello come le cose da fare del mese", pagina: .territorio,
          parole: ["attenzione"]),
        V(titolo: "Fonte delle mappe",
          spiegazione: "Niente CAP e niente indirizzi in rete: la posizione è quella del comune o quella che metti a mano.",
          pagina: .territorio, parole: ["ISTAT", "mappa"]),
    ]

    private static let scorciatoie: [V] = [
        V(titolo: "Cerca ovunque", spiegazione: "⌘K", pagina: .scorciatoie, parole: ["tasti", "tastiera"]),
        V(titolo: "Torna alla scrivania", spiegazione: "Riduce tutte le finestre", pagina: .scorciatoie,
          parole: ["tasti", "tastiera"]),
        V(titolo: "Modalità cliente", spiegazione: "⌥⌘M", pagina: .scorciatoie, parole: ["tasti", "Mostra al cliente"]),
        V(titolo: "Parla con Vera", spiegazione: "Di nuovo per mandare la frase", pagina: .scorciatoie,
          parole: ["tasti", "voce"]),
        V(titolo: "Le app del dock", spiegazione: "⌥1…⌥9 aprono le app del dock.", pagina: .scorciatoie,
          parole: ["tasti", "tastiera"]),
    ]

    /// Migliorie d'uso 37: sul Mac la pagina è «Dimostrazione»; le prove di Vera, dei promemoria e «Togli i clienti di
    /// prova» stanno nelle loro pagine (Vera, Promemoria e occasioni, Archivio e backup).
    private static let strumenti: [V] = [
        V(titolo: TestiDimostrazione.interruttore, spiegazione: TestiDimostrazione.interruttoreSpiegazione, pagina: .strumenti,
          ancora: "imp-strumenti-dimostrazione", parole: ["dati di prova", "clienti di prova", "demo", "mostrare Prisma"]),
        V(titolo: GruppoProva.cinque.titolo, spiegazione: GruppoProva.cinque.spiegazione, pagina: .strumenti,
          ancora: "imp-strumenti-gruppi", parole: ["dati di prova", "dimostrazione", "5 clienti"]),
        V(titolo: GruppoProva.trentacinque.titolo, spiegazione: GruppoProva.trentacinque.spiegazione, pagina: .strumenti,
          ancora: "imp-strumenti-gruppi", parole: ["dati di prova", "dimostrazione", "35 clienti"]),
        V(titolo: "Togli i clienti di prova", spiegazione: "Restano solo i tuoi clienti", pagina: .archivio,
          ancora: "imp-archivio-prova", parole: ["dati di prova", "dimostrazione"]),
        V(titolo: "Confronta i modelli", spiegazione: "Le stesse domande a ogni modello", pagina: .vera,
          ancora: "imp-vera-confronta", parole: ["Vera", "prove"]),
        V(titolo: "Misura la velocità su questo Mac", spiegazione: "La prova della fluidità con 5 e 200 clienti di prova",
          pagina: .vera, ancora: "impostazioni-velocita", parole: ["velocità", "fluidità"]),
        V(titolo: "Misura Vera", spiegazione: "Caricamento di Qwen, prima parola, parole al secondo", pagina: .vera,
          ancora: "impostazioni-velocita", parole: ["velocità"]),
        V(titolo: "Prova un promemoria", spiegazione: "Arriva subito, per vedere com'è", pagina: .promemoria,
          ancora: "imp-promemoria-prova", parole: ["notifiche"]),
        V(titolo: "Voce e ascolto", spiegazione: "Voce di Vera, microfono e riconoscimento della voce.", pagina: .vera,
          ancora: "imp-vera-voce", parole: ["microfono", "dettatura"]),
    ]
}
#endif
