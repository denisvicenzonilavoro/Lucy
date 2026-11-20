import Foundation

// I motori Mistral di Vera (20 novembre 2026, decisione dell'utente): modelli a pesi aperti, sempre in locale,
// scelti in automatico in base al compito.
//   · Lampo      = Ministral 3      → risposte immediate, ⌘K, comandi
//   · Quotidiano = Mistral Small 4  → documenti, KID, prospetti, immagini
//   · Profondo   = Mistral Large 4  → lavori lunghi, solo nel turno di notte, sul computer dedicato all'IA
// Finché il computer dell'IA non c'è, ogni compito va al motore più grande che entra nella memoria del Mac
// (sul MacBook Pro M1 da 8 GB: Ministral 3 da 3 miliardi di parametri). La scelta è solo codice: nessuna rete.

/// I tre ruoli dei motori.
enum RuoloMotore: String, Codable, CaseIterable, Identifiable {
    case lampo, quotidiano, profondo

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .lampo: return "Lampo"
        case .quotidiano: return "Quotidiano"
        case .profondo: return "Profondo"
        }
    }

    /// La famiglia Mistral che fa questo lavoro.
    var famiglia: String {
        switch self {
        case .lampo: return "Ministral 3"
        case .quotidiano: return "Mistral Small 4"
        case .profondo: return "Mistral Large 4"
        }
    }

    var descrizione: String {
        switch self {
        case .lampo: return "Risposte immediate, ⌘K e comandi."
        case .quotidiano: return "Documenti, KID, prospetti e immagini."
        case .profondo: return "Lavori lunghi, solo nel turno di notte, sul computer dell'IA."
        }
    }

    /// Il gradino più piccolo: il ripiego quando un ruolo non si può usare.
    var piuPiccolo: RuoloMotore? {
        switch self {
        case .lampo: return nil
        case .quotidiano: return .lampo
        case .profondo: return .quotidiano
        }
    }
}

/// Che cosa sta facendo Vera: decide il ruolo del motore.
enum CompitoVera: String, CaseIterable, Identifiable {
    /// Una domanda nella chat di Vera.
    case domanda
    /// «Chiedi a Vera» con ⌘K e la mini finestra.
    case chiediAlVolo
    /// Un comando («apri il dossier di…», «sposta l'appuntamento…»).
    case comando
    /// Leggere o spiegare un documento.
    case documento
    /// Leggere un KID (costi, rischio, scenari).
    case kid
    /// Un prospetto o una proposta da raccontare.
    case prospetto
    /// Guardare un'immagine (una foto, una pagina scansionata).
    case immagine
    /// Un lavoro lungo: fascicoli, riletture, resoconti (turno di notte).
    case lavoroLungo

    var id: String { rawValue }

    var ruolo: RuoloMotore {
        switch self {
        case .domanda, .chiediAlVolo, .comando: return .lampo
        case .documento, .kid, .prospetto, .immagine: return .quotidiano
        case .lavoroLungo: return .profondo
        }
    }
}

/// Un modello del catalogo: il nome in Ollama, quanto spazio vuole mentre lavora e la licenza.
struct ModelloMistral: Equatable, Identifiable {
    /// Il nome in Ollama («ministral-3:3b»).
    let nome: String
    let famiglia: String
    let ruolo: RuoloMotore
    /// La memoria che occupa mentre lavora (pesi a 4 bit e un po' di margine per la conversazione), in GB.
    let memoriaGB: Double
    let licenza: String
    /// Legge anche le immagini.
    let immagini: Bool

    var id: String { nome }
}

/// I modelli Mistral che Vera conosce. I nomi di Small 4 e Large 4 in Ollama sono da verificare quando escono nella
/// libreria di Ollama: si possono cambiare in Impostazioni › Vera (`ImpostazioniMotori`).
enum CatalogoMistral {
    static let ministral3B = ModelloMistral(nome: "ministral-3:3b", famiglia: "Ministral 3", ruolo: .lampo, memoriaGB: 3.5,
                                            licenza: "Apache 2.0", immagini: true)
    static let ministral8B = ModelloMistral(nome: "ministral-3:8b", famiglia: "Ministral 3", ruolo: .lampo, memoriaGB: 6.5,
                                            licenza: "Apache 2.0", immagini: true)
    static let ministral14B = ModelloMistral(nome: "ministral-3:14b", famiglia: "Ministral 3", ruolo: .lampo, memoriaGB: 10,
                                             licenza: "Apache 2.0", immagini: true)
    static let small4 = ModelloMistral(nome: "mistral-small4", famiglia: "Mistral Small 4", ruolo: .quotidiano, memoriaGB: 72,
                                       licenza: "Apache 2.0", immagini: true)
    static let large4 = ModelloMistral(nome: "mistral-large4", famiglia: "Mistral Large 4", ruolo: .profondo, memoriaGB: 600,
                                       licenza: "Mistral (MIT modificata)", immagini: true)

    /// Dal più piccolo al più grande.
    static let tutti = [ministral3B, ministral8B, ministral14B, small4, large4]

    /// Il modello del catalogo con questo nome (nil se è un altro modello, per esempio Qwen o Vera su misura).
    static func modello(_ nome: String) -> ModelloMistral? {
        tutti.first { FornitoreOllama.stessoModello($0.nome, nome) }
    }

    /// Il modello di partenza di ogni ruolo.
    static func predefinito(_ ruolo: RuoloMotore) -> ModelloMistral {
        switch ruolo {
        case .lampo: return ministral3B
        case .quotidiano: return small4
        case .profondo: return large4
        }
    }

    /// La famiglia di un nome di modello qualsiasi («Ministral 3», oppure il nome stesso se non è nel catalogo).
    static func famiglia(_ nome: String) -> String {
        modello(nome)?.famiglia ?? nome
    }
}

/// La memoria del computer: quanta ne resta per il modello una volta tolti macOS e Prisma.
enum MemoriaComputer {
    /// Quanto tengono macOS, Prisma e le altre app aperte: il resto può andare al modello.
    static let riservaGB: Double = 4.5

    /// La memoria fisica di questo computer in GB.
    static var totaleGB: Double { Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824 }

    /// Quanta memoria può prendere un modello su un computer con `totale` GB.
    static func perIlModello(totale: Double) -> Double { max(0, totale - riservaGB) }

    /// Il modello entra in un computer con `totale` GB?
    static func entra(_ m: ModelloMistral, totale: Double) -> Bool { m.memoriaGB <= perIlModello(totale: totale) }

    /// Il modello Mistral più grande che entra in un computer con `totale` GB (nil se non ne entra nessuno).
    static func piuGrandeCheEntra(totale: Double, tra modelli: [ModelloMistral] = CatalogoMistral.tutti) -> ModelloMistral? {
        modelli.filter { entra($0, totale: totale) }.max { $0.memoriaGB < $1.memoriaGB }
    }

    /// L'impronta in memoria di Prisma in GB (la cifra di Monitoraggio Attività).
    static func prismaGB() -> Double {
        #if canImport(Darwin)
        var info = task_vm_info_data_t()
        var conta = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        let esito = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(conta)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &conta)
            }
        }
        return esito == KERN_SUCCESS ? Double(info.phys_footprint) / 1_073_741_824 : 0
        #else
        return 0
        #endif
    }
}

/// Dove lavora il motore.
enum DoveLavora: String, Codable, Equatable {
    /// Il Mac dove gira Prisma.
    case mac
    /// Il computer dedicato all'IA, nella rete dello studio (tappa 2: non ancora collegato).
    case computerIA

    var nome: String {
        switch self {
        case .mac: return "Il tuo Mac"
        case .computerIA: return "Computer dell'IA"
        }
    }
}

/// La scelta del motore per un compito: il ruolo chiesto, quello che lavora davvero, il modello e il perché.
struct SceltaMotore: Equatable {
    let compito: CompitoVera
    /// Il ruolo che il compito vorrebbe.
    let ruoloChiesto: RuoloMotore
    /// Il ruolo che lavora davvero (più piccolo se quello chiesto non si può usare).
    let ruolo: RuoloMotore
    /// Il nome del modello in Ollama.
    let modello: String
    let dove: DoveLavora
    /// Il motivo del ripiego, per l'interfaccia («Mistral Small 4 vuole circa 72 GB…»); nil se lavora il motore chiesto.
    let ripiego: String?

    /// «Ministral 3», «Mistral Small 4»… (o il nome del modello se non è nel catalogo).
    var famiglia: String { CatalogoMistral.famiglia(modello) }
}

/// Il modo di scegliere: in automatico (Vera sceglie da sola) o sempre lo stesso ruolo.
enum ModoSceltaMotore: String, Codable, CaseIterable, Identifiable {
    case automatico, lampo, quotidiano, profondo

    var id: String { rawValue }

    var nome: String {
        switch self {
        case .automatico: return "Automatico · sceglie lei"
        case .lampo: return "Sempre Lampo"
        case .quotidiano: return "Sempre Quotidiano"
        case .profondo: return "Sempre Profondo"
        }
    }

    var ruolo: RuoloMotore? { RuoloMotore(rawValue: rawValue) }
}

/// Le impostazioni dei motori (Impostazioni › Vera), nell'archivio e nei backup. Il modello Lampo sul Mac è
/// `ImpostazioniVera.modelloLocale`; qui i nomi in Ollama degli altri due ruoli e il modo di scegliere.
struct ImpostazioniMotori: Codable, Equatable {
    var modo = ModoSceltaMotore.automatico
    var modelloQuotidiano = CatalogoMistral.small4.nome
    var modelloProfondo = CatalogoMistral.large4.nome

    init() {}

    private enum CodingKeys: String, CodingKey { case modo, modelloQuotidiano, modelloProfondo }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        modo = (try? c.decodeIfPresent(ModoSceltaMotore.self, forKey: .modo)) ?? .automatico
        let q = ((try? c.decodeIfPresent(String.self, forKey: .modelloQuotidiano)) ?? nil)?.trimmingCharacters(in: .whitespaces) ?? ""
        modelloQuotidiano = q.isEmpty ? CatalogoMistral.small4.nome : q
        let p = ((try? c.decodeIfPresent(String.self, forKey: .modelloProfondo)) ?? nil)?.trimmingCharacters(in: .whitespaces) ?? ""
        modelloProfondo = p.isEmpty ? CatalogoMistral.large4.nome : p
    }
}

/// La scelta automatica del motore: solo regole, nessuna chiamata.
enum SceltaMotori {
    /// Sceglie il motore per un compito.
    /// - `memoriaMac`: la memoria fisica del Mac in GB.
    /// - `installati`: i modelli presenti in Ollama (nil se non si sa ancora: allora si resta sul modello del Mac,
    ///   che è quello verificato da Prisma).
    /// - `notte`: true durante il turno di notte (il motore Profondo lavora solo allora).
    static func scegli(_ compito: CompitoVera, vera: ImpostazioniVera, memoriaMac: Double = MemoriaComputer.totaleGB,
                       installati: [String]?, notte: Bool) -> SceltaMotore {
        let chiesto = vera.motori.modo.ruolo ?? compito.ruolo
        // Il modello del Mac: quello scelto in Impostazioni › Vera (di base Ministral 3 da 3 miliardi), verificato da Prisma
        let delMac = vera.modello
        var ruolo = chiesto
        var motivo: String?
        if ruolo == .profondo, !notte {
            ruolo = .quotidiano
            motivo = "\(RuoloMotore.profondo.famiglia) lavora solo nel turno di notte."
        }
        // Il Lampo è il modello del Mac
        if ruolo == .lampo {
            return SceltaMotore(compito: compito, ruoloChiesto: chiesto, ruolo: .lampo, modello: delMac, dove: .mac, ripiego: motivo)
        }
        // Quotidiano e Profondo sul Mac solo se ci entrano e sono già scaricati; il computer dell'IA arriva con la tappa 2
        let nome = ruolo == .quotidiano ? vera.motori.modelloQuotidiano : vera.motori.modelloProfondo
        let catalogo = CatalogoMistral.modello(nome)
        let gb = catalogo?.memoriaGB ?? CatalogoMistral.predefinito(ruolo).memoriaGB
        let entra = gb <= MemoriaComputer.perIlModello(totale: memoriaMac)
        let scaricato = installati?.contains { FornitoreOllama.stessoModello($0, nome) } ?? false
        if ruolo == .profondo, !entra {
            // Di notte, se il Profondo non entra, prova il Quotidiano prima di scendere al modello del Mac
            let q = scegli(.documento, vera: vera, memoriaMac: memoriaMac, installati: installati, notte: notte)
            let perche = "\(RuoloMotore.profondo.famiglia) vuole circa \(Self.gb(gb)): sul tuo Mac non entra."
            return SceltaMotore(compito: compito, ruoloChiesto: chiesto, ruolo: q.ruolo, modello: q.modello, dove: q.dove,
                                ripiego: [perche, q.ripiego].compactMap { $0 }.joined(separator: " "))
        }
        if entra, scaricato {
            return SceltaMotore(compito: compito, ruoloChiesto: chiesto, ruolo: ruolo, modello: nome, dove: .mac, ripiego: motivo)
        }
        let famiglia = catalogo?.famiglia ?? nome
        let perche = entra
            ? "\(famiglia) non è ancora scaricato sul Mac."
            : "\(famiglia) vuole circa \(Self.gb(gb)): finché non c'è il computer dell'IA lavora \(CatalogoMistral.famiglia(delMac)) sul tuo Mac."
        return SceltaMotore(compito: compito, ruoloChiesto: chiesto, ruolo: .lampo, modello: delMac, dove: .mac,
                            ripiego: [motivo, perche].compactMap { $0 }.joined(separator: " "))
    }

    /// «72 GB», «3,5 GB».
    static func gb(_ valore: Double) -> String {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "it_IT")
        f.maximumFractionDigits = valore < 10 ? 1 : 0
        f.minimumFractionDigits = 0
        return (f.string(from: NSNumber(value: valore)) ?? "\(valore)") + " GB"
    }
}
