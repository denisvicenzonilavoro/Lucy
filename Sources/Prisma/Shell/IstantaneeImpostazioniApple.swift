#if os(macOS)
import Foundation

/// Le istantanee delle Impostazioni nel tema Apple (§4.6), come PIE i01, i02 e i03: la barra laterale con le sezioni
/// e la sezione Aspetto (Chiaro / Scuro / Automatico, l'acqua della scrivania, «Riduci movimento», la dimensione del
/// testo) in chiaro e in scuro; poi Archivio e backup con la card dell'anello pieno («Backup creato adesso»), il
/// backup automatico settimanale, «Dove salvare» e «Ripristina…». Ferme nello stato finale (`\.modoIstantanea`).
/// Migliorie d'uso 30: la colonna con il campo «Cerca nelle impostazioni» e i gruppi con un nome; 1054 e 1055 la ricerca.
/// Migliorie d'uso 31: la colonna con «Da sistemare» e le etichette; 1056-1058 la pagina «Da sistemare».
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
            // Migliorie d'uso 31: «Da sistemare» (backup mai fatto, promemoria spenti, dati per le fatture incompleti,
            // Vera pronta in «A posto»), «Tutto a posto» con la spunta nella colonna, e Vera non pronta con l'archivio in
            // sola lettura
            ("1056-uso-da-sistemare", { s in preparaDaSistemare(s) }),
            ("1056-uso-da-sistemare-scuro", { s in preparaDaSistemare(s) }),
            ("1057-uso-tutto-a-posto", { s in
                s.dati.impostazioni.backup.ultimo = Date()
                s.dati.impostazioni.backup.ultimoErrore = nil
                s.dati.impostazioni.backup.cartella = cartellaBackupDiProva
                s.dati.impostazioni.promemoria.attivi = true
                s.dati.impostazioni.studio.fatturazione = ProvaBackup.fatturazioneDiProva()
                s.disponibilitaLocale = .pronto
                preparaImpostazioniApple(s, sezione: .panoramica)
            }),
            ("1058-uso-da-sistemare-vera", { s in
                preparaDaSistemare(s)
                s.disponibilitaLocale = .nonDisponibile("Ollama non è aperto.")
                s.segnaSolaLetturaPerIstantanea()
            }),
        ]
    }

    /// Una cartella di backup scelta (inventata): i backup non sono «sullo stesso Mac».
    nonisolated static let cartellaBackupDiProva = "/Volumes/Backup/Prisma"

    /// Migliorie d'uso 31: le tre cose del template (backup mai fatto, promemoria spenti, dati per le fatture da
    /// completare) e Vera pronta.
    nonisolated static func preparaDaSistemare(_ s: StatoShell) {
        s.dati.impostazioni.backup.ultimo = nil
        s.dati.impostazioni.backup.ultimoErrore = nil
        s.dati.impostazioni.backup.ultimoTentativo = nil
        s.dati.impostazioni.backup.cartella = cartellaBackupDiProva
        s.dati.impostazioni.promemoria.attivi = false
        s.dati.impostazioni.studio.fatturazione = DatiFatturazione()
        s.disponibilitaLocale = .pronto
        preparaImpostazioniApple(s, sezione: .panoramica)
    }

    /// Le Impostazioni aperte sulla sezione data.
    nonisolated static func preparaImpostazioniApple(_ s: StatoShell, sezione: SchedaImpostazioni) {
        s.ancoraImpostazioni = nil
        s.schedaImpostazioni = sezione
        s.apri(.impostazioni)
    }
}
#endif
