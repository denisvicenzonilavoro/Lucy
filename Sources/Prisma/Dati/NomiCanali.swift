import Foundation
import Observation

/// Un solo canale, quello di Lucy (decisione dell'utente del 25 novembre 2026: «non ci sarà più Alleanza /
/// Indipendente… c'è solo un unico canale che è quello di Lucy»). Le scritte che prima cambiavano con il canale
/// (intestazioni e firme dei PDF, firma del film, frasi di Lucy) leggono da qui. Il campo `canale` resta nei dati solo
/// per compatibilità.
enum CanaleLucy {
    /// La scritta lunga: intestazioni dei PDF, firma del film, ruolo del consulente.
    static let nome = "Lucy · consulenza finanziaria"
    /// Il nome breve.
    static let nomeBreve = "Lucy"
    /// Il nome del consulente, per le firme.
    static let consulente = "Denis Vicenzoni"
}

extension Canale {
    /// Dove una regola resta diversa per i due valori salvati (documenti da consegnare, norme del questionario), il
    /// tipo di prodotti a cui vale, mai il nome di un canale: «prodotti assicurativi» o «strumenti finanziari».
    var tipoProdotti: String { self == .alleanza ? "prodotti assicurativi" : "strumenti finanziari" }
    /// Lo stesso con la maiuscola, per i titoli: «Prodotti assicurativi», «Strumenti finanziari».
    var titoloProdotti: String { self == .alleanza ? "Prodotti assicurativi" : "Strumenti finanziari" }
}

// Migliorie d'uso 38 «I canali hanno il nome che scegli» (Design/uso/gruppo-06.md §38): il nome scritto sulle due
// etichette dei canali, in un posto solo. I colori (blu e cuoio) e i `rawValue` dei canali non cambiano mai; per Denis
// restano «Alleanza» e «Indipendente» (nei PDF «Alleanza Assicurazioni» e «Denis Vicenzoni · Consulenza finanziaria").

/// I nomi dei due canali scelti dall'utente (Impostazioni › Profilo e la seconda delle tre domande del primo avvio).
/// Nell'archivio `Impostazioni.nomiCanali`, nil = quelli di base.
struct NomiCanali: Codable, Equatable, Sendable {
    var primo: String
    var secondo: String

    /// I nomi di base: «Alleanza» (blu) e «Indipendente» (cuoio).
    static let base = NomiCanali(primo: "Alleanza", secondo: "Indipendente")

    /// Quanti caratteri tiene al più un nome (come `maxlength` del campo del template).
    static let lunghezzaMassima = 18

    /// Toglie `< > & "` e i caratteri di controllo, senza togliere gli spazi ai lati, e tiene al più 18 caratteri: è ciò
    /// che il campo accetta mentre si scrive.
    static func ripulisciScrittura(_ testo: String) -> String {
        let vietati: Set<Character> = ["<", ">", "&", "\""]
        let tenuti = testo.filter { c in
            !vietati.contains(c) && !c.unicodeScalars.contains { CharacterSet.controlCharacters.contains($0) }
        }
        return String(tenuti.prefix(lunghezzaMassima))
    }

    /// Il nome pronto da conservare: ripulito come mentre si scrive e senza spazi ai lati (vuoto se non resta nulla).
    static func pulisci(_ testo: String) -> String {
        ripulisciScrittura(testo).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// I due nomi ripuliti; un nome vuoto torna a quello di base.
    static func scelti(primo: String, secondo: String) -> NomiCanali {
        let p = pulisci(primo)
        let s = pulisci(secondo)
        return NomiCanali(primo: p.isEmpty ? base.primo : p, secondo: s.isEmpty ? base.secondo : s)
    }

    /// Diversi da quelli di base (almeno uno dei due).
    var personalizzati: Bool { self != NomiCanali.base }

    /// Il nome del canale dato.
    func nome(_ canale: Canale) -> String {
        switch canale {
        case .alleanza: return primo
        case .indipendente: return secondo
        }
    }

    /// Il canale dato porta il nome di base.
    func diBase(_ canale: Canale) -> Bool {
        nome(canale) == NomiCanali.base.nome(canale)
    }
}

/// I nomi dei canali scelti prima del 25 novembre 2026 (restano nell'archivio per compatibilità; dal 25 novembre
/// `Canale.nomeBreve` e `Canale.nome` danno sempre `CanaleLucy`). Leggibili anche fuori dal thread
/// principale (motori, Vera), quindi il valore è protetto. Lo aggiorna solo `StatoShell` sul Mac (al caricamento, a ogni
/// cambio delle impostazioni, al ripristino), prima di alzare `versioneCalcoli`; su iPhone e iPad resta quello di base
/// finché non si fa il loro giro.
enum NomiCanaliCorrenti {
    private static let blocco = NSLock()
    nonisolated(unsafe) private static var corrente = NomiCanali.base

    static var valore: NomiCanali {
        blocco.lock()
        defer { blocco.unlock() }
        return corrente
    }

    static func imposta(_ nuovi: NomiCanali) {
        blocco.lock()
        corrente = nuovi
        blocco.unlock()
    }
}

/// Lo stesso valore per le viste: le etichette dei canali lo leggono nel body, così cambiano appena cambia il nome
/// (senza osservare tutte le impostazioni). Si scrive solo dal thread principale (`StatoShell.applicaNomiCanali`).
@Observable final class SegnaleNomiCanali {
    static let condiviso = SegnaleNomiCanali()
    var nomi: NomiCanali = .base
}
