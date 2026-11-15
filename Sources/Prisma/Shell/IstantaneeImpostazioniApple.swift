#if os(macOS)
import Foundation

/// Le istantanee delle Impostazioni nel tema Apple (§4.6), come PIE i01, i02 e i03: la barra laterale con le sezioni
/// e la sezione Aspetto (Chiaro / Scuro / Automatico, l'acqua della scrivania, «Riduci movimento», la dimensione del
/// testo) in chiaro e in scuro; poi Archivio e backup con la card dell'anello pieno («Backup creato adesso»), il
/// backup automatico settimanale, «Dove salvare» e «Ripristina…». Ferme nello stato finale (`\.modoIstantanea`).
/// Migliorie d'uso 30: la colonna con il campo «Cerca nelle impostazioni» e i gruppi con un nome; 1054 e 1055 la ricerca.
extension Istantanee {
    nonisolated static var sceneImpostazioniApple: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("470-impostazioni-apple", { s in preparaImpostazioniApple(s, sezione: .aspetto) }),
            ("470-impostazioni-apple-scuro", { s in preparaImpostazioniApple(s, sezione: .aspetto) }),
            ("471-impostazioni-archivio-apple", { s in
                // Un backup appena riuscito: l'anello è pieno con la ✓
                s.dati.impostazioni.backup.ultimo = Date()
                s.dati.impostazioni.backup.ultimoErrore = nil
                preparaImpostazioniApple(s, sezione: .archivio)
            }),
            // Migliorie d'uso 30: la ricerca nelle impostazioni, con i risultati per «backup» e senza risultati
            ("1054-uso-impostazioni-cerca", { s in
                preparaImpostazioniApple(s, sezione: .aspetto)
                s.cercaImpostazioni = "backup"
            }),
            ("1054-uso-impostazioni-cerca-scuro", { s in
                preparaImpostazioniApple(s, sezione: .aspetto)
                s.cercaImpostazioni = "backup"
            }),
            ("1055-uso-impostazioni-cerca-vuota", { s in
                preparaImpostazioniApple(s, sezione: .aspetto)
                s.cercaImpostazioni = "xyz"
            }),
        ]
    }

    /// Le Impostazioni aperte sulla sezione data.
    nonisolated static func preparaImpostazioniApple(_ s: StatoShell, sezione: SchedaImpostazioni) {
        s.ancoraImpostazioni = nil
        s.schedaImpostazioni = sezione
        s.apri(.impostazioni)
    }
}
#endif
