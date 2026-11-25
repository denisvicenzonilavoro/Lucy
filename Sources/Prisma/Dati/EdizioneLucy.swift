import Foundation

/// Le due edizioni di Lucy sullo stesso codice (25 novembre 2026, richiesta dell'utente): **Lucy**, l'app vera, e
/// **Lucy Demo**, un'app a parte già piena di clienti, posizioni, pratiche e storico, come se fosse usata da mesi, per
/// provarla e mostrarla senza toccare i dati veri.
///
/// Lucy Demo è lo stesso eseguibile con un Info.plist diverso (`LucyDemo` = true, identificativo `local.prisma.demo`,
/// nome «Lucy Demo»; lo prepara `Supporto/costruisci-mac.sh --demo`). Tutto ciò che resta sul Mac è separato:
/// - la cartella dei dati (`~/Library/Application Support/Prisma Demo`) e quella dei backup («Prisma Backup Demo»);
/// - i servizi del Portachiavi (« demo» in coda), così la demo non legge mai le chiavi vere (backup, Prisma ovunque,
///   capsule, memoria, note vocali);
/// - le preferenze (con l'identificativo diverso il sistema le tiene già a parte).
/// All'avvio senza archivio la demo nasce con i dati di prova completi (`ClientiFittizi.completi()`); Lucy vera nasce
/// vuota, come prima.
enum EdizioneLucy {
    /// true in Lucy Demo (chiave `LucyDemo` dell'Info.plist, o `PRISMA_DEMO=1` per le prove).
    static let demo: Bool = {
        if ProcessInfo.processInfo.environment["PRISMA_DEMO"] == "1" { return true }
        return (Bundle.main.object(forInfoDictionaryKey: "LucyDemo") as? Bool) == true
    }()

    /// Il nome mostrato dell'app: «Lucy» o «Lucy Demo».
    static var nome: String { demo ? "Lucy Demo" : "Lucy" }

    /// Da aggiungere ai nomi delle cartelle sul Mac: «» o « Demo».
    static var suffissoCartella: String { demo ? " Demo" : "" }

    /// Da aggiungere ai servizi del Portachiavi: «» o « demo».
    static var suffissoPortachiavi: String { demo ? " demo" : "" }
}
