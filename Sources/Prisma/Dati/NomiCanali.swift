import Foundation
import Observation

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

/// I nomi dei canali in uso adesso. `Canale.nomeBreve` e `Canale.nome` li leggono da qui, anche fuori dal thread
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
