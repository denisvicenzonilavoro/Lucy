import Foundation

// Migliorie d'uso 31 «Si vede cosa resta da sistemare» (Design/uso/gruppo-04.md §31): la prima voce delle Impostazioni
// sul Mac. Dai fatti già letti (`FattiDaSistemare`, StatoDaSistemare.swift: solo letture, nessuno scorrimento
// dell'archivio) il motore dice cosa resta da sistemare, in ordine di gravità, e cosa è «A posto» (solo ciò che è
// attivo). Ogni voce porta alla sua pagina (e alla riga, con l'ancora) e dà l'etichetta breve che la colonna scrive
// accanto alla pagina al posto del pallino («mai fatto», «spenti», «da completare»…).
// Le frasi non contengono dati dei clienti: solo conteggi. «Protetta da password» solo se il backup lo è davvero.

/// I fatti che servono, letti da `StatoShell.fattiDaSistemare()`. Tutti con un valore di base «niente da dire».
struct FattiDaSistemare: Equatable {
    // Archivio
    var solaLettura = false
    var copieNonLeggibili = 0
    // Backup
    var backupUltimo: Date?
    /// L'errore dell'ultimo backup non riuscito (con il momento del tentativo, se c'è).
    var backupErrore: String?
    /// `ImpostazioniBackup.inRitardo`: vero anche senza alcun backup dopo un tentativo.
    var backupInRitardo = false
    var backupProtetto = false
    /// Nessuna cartella scelta: i backup restano sullo stesso Mac.
    var backupStessoMac = false
    // Vera
    /// false finché Qwen non è stato verificato la prima volta («Ollama non ancora verificato.»).
    var veraVerificata = false
    var veraPronta = false
    var veraMotivo: String?
    // Promemoria
    var promemoriaAccesi = false
    var promemoriaNegati = false
    // Dati per le fatture
    /// Ci sono parcelle o posizioni del canale indipendente: i dati per le fatture servono.
    var fattureServono = false
    var fattureMancanti = 0
    // Prisma ovunque
    var ovunqueAcceso = false
    var ovunqueProblema: String?
    var ovunqueConflitti = 0
    var ovunqueUltima: Date?
    // Mercato
    var mercatoAcceso = false
    var mercatoErrore = false
    // Il tagliando dei dati (fase 4 di Vera): le voci trovate oggi, se l'elenco in memoria vale ancora
    var tagliandoVoci = 0
}

/// La gravità di una voce: decide il colore dell'etichetta nella colonna.
enum TonoDaSistemare: Equatable {
    case errore, attenzione
}

/// Una cosa da sistemare (o «A posto»): titolo, spiegazione, dove porta «Sistema» e l'etichetta della colonna.
struct VoceDaSistemare: Equatable, Identifiable {
    let id: String
    let titolo: String
    let spiegazione: String
    let pagina: SchedaImpostazioni
    var ancora: String? = nil
    /// L'etichetta accanto alla pagina nella colonna («mai fatto», «spenti»…); vuota per le voci «A posto».
    var etichettaColonna: String = ""
    var tono: TonoDaSistemare = .attenzione
}

/// L'esito: le cose da sistemare in ordine di gravità e quelle «A posto».
struct EsitoDaSistemare: Equatable {
    let daSistemare: [VoceDaSistemare]
    let aPosto: [VoceDaSistemare]

    var conteggio: Int { daSistemare.count }

    /// La voce più grave di una pagina (la prima nell'ordine): la sua etichetta va nella colonna.
    func etichetta(per pagina: SchedaImpostazioni) -> VoceDaSistemare? {
        daSistemare.first { $0.pagina == pagina }
    }
}

enum MotoreDaSistemare {
    /// Le cose da sistemare, in ordine di gravità, e quelle «A posto», solo per ciò che è attivo.
    static func calcola(_ f: FattiDaSistemare) -> EsitoDaSistemare {
        typealias T = TestiDaSistemare
        var da: [VoceDaSistemare] = []
        var ok: [VoceDaSistemare] = []

        // Archivio
        if f.solaLettura {
            da.append(VoceDaSistemare(id: "sola-lettura", titolo: T.solaLettura, spiegazione: T.solaLetturaSpiegazione,
                                      pagina: .archivio, etichettaColonna: "sola lettura", tono: .errore))
        }
        if f.copieNonLeggibili > 0 {
            da.append(VoceDaSistemare(id: "copie-non-leggibili", titolo: T.backupFermi, spiegazione: T.backupFermiSpiegazione,
                                      pagina: .archivio, etichettaColonna: "da controllare"))
        }

        // Backup: una voce sola fra non riuscito, mai fatto e in ritardo (le ultime due non escono mai insieme)
        if let e = f.backupErrore {
            da.append(VoceDaSistemare(id: "backup-non-riuscito", titolo: T.backupNonRiuscito, spiegazione: e,
                                      pagina: .archivio, etichettaColonna: "non riuscito", tono: .errore))
        } else if f.backupUltimo == nil {
            da.append(VoceDaSistemare(id: "backup-mai", titolo: T.backupMai, spiegazione: T.backupMaiSpiegazione,
                                      pagina: .archivio, etichettaColonna: "mai fatto"))
        } else if f.backupInRitardo {
            da.append(VoceDaSistemare(id: "backup-ritardo", titolo: T.backupRitardo, spiegazione: T.backupRitardoSpiegazione,
                                      pagina: .archivio, etichettaColonna: "in ritardo"))
        }
        if f.backupStessoMac {
            da.append(VoceDaSistemare(id: "backup-stesso-mac", titolo: T.backupStessoMac, spiegazione: T.backupStessoMacSpiegazione,
                                      pagina: .archivio, etichettaColonna: "sullo stesso Mac"))
        }
        if let ultimo = f.backupUltimo, f.backupErrore == nil, !f.backupInRitardo, !f.backupStessoMac {
            ok.append(VoceDaSistemare(id: "backup-fatto", titolo: T.backupFatto,
                                      spiegazione: T.backupFattoSpiegazione(ultimo, protetto: f.backupProtetto), pagina: .archivio))
        }

        // Vera: solo dopo la prima verifica, così la voce non compare e sparisce a ogni apertura
        if f.veraVerificata && !f.veraPronta {
            da.append(VoceDaSistemare(id: "vera-non-pronta", titolo: T.veraNonPronta,
                                      spiegazione: f.veraMotivo ?? T.veraNonProntaSpiegazione,
                                      pagina: .vera, etichettaColonna: "non pronta"))
        }
        if f.veraPronta {
            ok.append(VoceDaSistemare(id: "vera-pronta", titolo: T.veraPronta, spiegazione: T.veraProntaSpiegazione, pagina: .vera))
        }

        // Promemoria
        if !f.promemoriaAccesi {
            da.append(VoceDaSistemare(id: "promemoria-spenti", titolo: T.promemoriaSpenti, spiegazione: T.promemoriaSpentiSpiegazione,
                                      pagina: .promemoria, etichettaColonna: "spenti"))
        } else if f.promemoriaNegati {
            da.append(VoceDaSistemare(id: "promemoria-negati", titolo: T.promemoriaNegati, spiegazione: T.promemoriaNegatiSpiegazione,
                                      pagina: .promemoria, etichettaColonna: "non consentiti", tono: .errore))
        } else {
            ok.append(VoceDaSistemare(id: "promemoria-accesi", titolo: T.promemoriaAccesi, spiegazione: T.promemoriaAccesiSpiegazione,
                                      pagina: .promemoria))
        }

        // Dati per le fatture: solo con parcelle o posizioni del canale indipendente
        if f.fattureServono {
            if f.fattureMancanti > 0 {
                da.append(VoceDaSistemare(id: "fatture-mancanti", titolo: T.fattureMancanti,
                                          spiegazione: T.fattureMancantiSpiegazione(f.fattureMancanti),
                                          pagina: .studio, ancora: TestiParcelle.ancoraImpostazioni, etichettaColonna: "da completare"))
            } else {
                ok.append(VoceDaSistemare(id: "fatture-complete", titolo: T.fattureComplete, spiegazione: T.fattureCompleteSpiegazione,
                                          pagina: .studio, ancora: TestiParcelle.ancoraImpostazioni))
            }
        }

        // Prisma ovunque, solo acceso
        if f.ovunqueAcceso {
            if let p = f.ovunqueProblema {
                da.append(VoceDaSistemare(id: "ovunque-problema", titolo: T.ovunqueProblema, spiegazione: p,
                                          pagina: .ovunque, etichettaColonna: "errore", tono: .errore))
            } else if f.ovunqueConflitti > 0 {
                da.append(VoceDaSistemare(id: "ovunque-conflitti", titolo: T.ovunqueConflitti(f.ovunqueConflitti),
                                          spiegazione: T.ovunqueConflittiSpiegazione, pagina: .ovunque, etichettaColonna: "da decidere"))
            } else {
                ok.append(VoceDaSistemare(id: "ovunque-allineati", titolo: T.ovunqueAllineati,
                                          spiegazione: T.ovunqueAllineatiSpiegazione(f.ovunqueUltima), pagina: .ovunque))
            }
        }

        // Mercato, solo acceso
        if f.mercatoAcceso && f.mercatoErrore {
            da.append(VoceDaSistemare(id: "mercato-errore", titolo: T.mercatoErrore, spiegazione: T.mercatoErroreSpiegazione,
                                      pagina: .mercato, etichettaColonna: "non aggiornato"))
        }

        // Il tagliando dei dati (proposta di §31.6): la pagina di Vera, al suo gruppo
        if f.tagliandoVoci > 0 {
            da.append(VoceDaSistemare(id: "tagliando", titolo: T.tagliando(f.tagliandoVoci), spiegazione: T.tagliandoSpiegazione,
                                      pagina: .vera, ancora: T.ancoraTagliando, etichettaColonna: "da guardare"))
        }

        return EsitoDaSistemare(daSistemare: da, aPosto: ok)
    }
}

/// I testi di «Da sistemare» (come nel template, righe 4033-4073).
enum TestiDaSistemare {
    static let titolo = "Da sistemare"
    static let tuttoAPosto = "Tutto a posto"
    static let niente = "Non c’è niente da sistemare."
    static let aPosto = "A posto"
    static let sistema = "Sistema"
    /// L'ancora del gruppo del tagliando nella pagina di Vera (la stessa dell'indice della ricerca).
    static let ancoraTagliando = "imp-vera-tagliando"

    /// «Una cosa, poi Prisma è a posto.» … «N cose, poi…»; a zero «Non c’è niente da sistemare.».
    static func conteggio(_ n: Int) -> String {
        switch n {
        case ..<1: return niente
        case 1: return "Una cosa, poi Lucy è a posto."
        case 2: return "Due cose, poi Lucy è a posto."
        case 3: return "Tre cose, poi Lucy è a posto."
        default: return "\(n) cose, poi Lucy è a posto."
        }
    }

    static let solaLettura = "L’archivio è in sola lettura"
    static let solaLetturaSpiegazione = "Salvato da una versione più recente di Lucy."
    static let backupFermi = "I backup automatici sono fermi"
    static let backupFermiSpiegazione = "All’avvio una parte dell’archivio non era leggibile."
    static let backupNonRiuscito = "L’ultimo backup non è riuscito"
    static let backupMai = "Nessun backup ancora"
    static let backupMaiSpiegazione = "Il primo backup protegge tutto il lavoro fatto finora."
    static let backupRitardo = "Nessun backup da più di 8 giorni"
    static let backupRitardoSpiegazione = "Crea un backup a mano, o controlla la cartella."
    static let backupStessoMac = "I backup sono sullo stesso Mac"
    static let backupStessoMacSpiegazione = "Scegli iCloud Drive o un disco esterno."
    static let backupFatto = "Backup fatto"
    /// «L’ultima copia è di oggi, protetta da password.» (mai «protetta» se non lo è).
    static func backupFattoSpiegazione(_ ultimo: Date, protetto: Bool) -> String {
        "L’ultima copia è di \(Formati.giornoRelativo(ultimo))" + (protetto ? ", protetta da password." : ".")
    }

    static let veraNonPronta = "Vera non è pronta"
    static let veraNonProntaSpiegazione = TestiStatoVera.inVista(mac: "Vera non risponde ancora sul Mac.", altrove: "Qwen non risponde sul Mac.")
    static let veraPronta = "Vera è pronta"
    static let veraProntaSpiegazione = "Risponde dal Mac: niente esce da qui."

    static let promemoriaSpenti = "I promemoria sono spenti"
    static let promemoriaSpentiSpiegazione = "Appuntamenti e scadenze non arrivano nel Centro notifiche del Mac."
    static let promemoriaNegati = "I promemoria non sono consentiti"
    static let promemoriaNegatiSpiegazione = "Consentili in Impostazioni di Sistema › Notifiche."
    static let promemoriaAccesi = "Promemoria accesi"
    static let promemoriaAccesiSpiegazione = "Arrivano nel Centro notifiche del Mac."

    static let fattureMancanti = "Mancano i dati per le fatture"
    static func fattureMancantiSpiegazione(_ n: Int) -> String {
        "Servono per il file della fattura elettronica: " + (n == 1 ? "ne manca uno." : "ne mancano \(n).")
    }
    static let fattureComplete = "Dati per le fatture completi"
    static let fattureCompleteSpiegazione = "Il file della fattura elettronica si può preparare."

    static let ovunqueProblema = "iPhone e iPad non sono allineati"
    static func ovunqueConflitti(_ n: Int) -> String {
        n == 1 ? "C’è una modifica da decidere" : "Ci sono \(n) modifiche da decidere"
    }
    static let ovunqueConflittiSpiegazione = "Arrivano da iPhone e iPad e aspettano la tua scelta."
    static let ovunqueAllineati = "iPhone e iPad allineati"
    static func ovunqueAllineatiSpiegazione(_ ultima: Date?) -> String {
        guard let ultima else { return "La copia cifrata è accesa." }
        return "Sincronizzati \(TestiOvunque.quando(ultima))."
    }

    static let mercatoErrore = "I dati di mercato non si sono aggiornati"
    static let mercatoErroreSpiegazione = "L’ultimo scaricamento da BCE ed Eurostat non è riuscito."

    static func tagliando(_ n: Int) -> String {
        n == 1 ? "Il tagliando dei dati ha trovato una cosa da guardare"
               : "Il tagliando dei dati ha trovato \(n) cose da guardare"
    }
    static let tagliandoSpiegazione = "Nulla si cancella da solo: decidi tu, una voce alla volta."
}
