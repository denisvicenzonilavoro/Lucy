#if os(macOS)
import Foundation

/// Le istantanee delle Impostazioni nel tema Apple (§4.6), come PIE i01, i02 e i03: la barra laterale con le sezioni
/// e la sezione Aspetto (Chiaro / Scuro / Automatico, l'acqua della scrivania, «Riduci movimento», la dimensione del
/// testo) in chiaro e in scuro; poi Archivio e backup con la card dell'anello pieno («Backup creato adesso»), il
/// backup automatico settimanale, «Dove salvare» e «Ripristina…». Ferme nello stato finale (`\.modoIstantanea`).
/// Migliorie d'uso 30: la colonna con il campo «Cerca nelle impostazioni» e i gruppi con un nome; 1054 e 1055 la ricerca.
/// Migliorie d'uso 31: la colonna con «Da sistemare» e le etichette; 1056-1058 la pagina «Da sistemare».
/// Migliorie d'uso 38: 1064-1066 le tre domande del primo avvio, 1067 Profilo con i nomi dei canali, 1068 i nomi scelti.
/// Migliorie d'uso 39: 1069 iPhone e iPad in un collegamento solo, 1070 la scheda del codice, 1071 Vera con il rimando.
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
            // Migliorie d'uso 38: le tre domande del primo avvio (la seconda con un nome scritto: l'etichetta cambia),
            // Profilo con i due campi e «Rivedi», e una scheda di Posizioni con i nomi scelti (etichetta senza logo)
            ("1064-uso-primo-avvio-benvenuto", { s in s.apriPrimoAvvio(pagina: 0) }),
            ("1064-uso-primo-avvio-benvenuto-scuro", { s in s.apriPrimoAvvio(pagina: 0) }),
            ("1065-uso-primo-avvio-canali", { s in
                s.dati.impostazioni.nomiCanali = NomiCanali(primo: "Agenzia Rossi", secondo: "Indipendente")
                s.apriPrimoAvvio(pagina: 1)
            }),
            ("1066-uso-primo-avvio-da-dove", { s in s.apriPrimoAvvio(pagina: 2) }),
            ("1067-uso-impostazioni-profilo", { s in preparaImpostazioniApple(s, sezione: .profilo) }),
            ("1067-uso-impostazioni-profilo-scuro", { s in preparaImpostazioniApple(s, sezione: .profilo) }),
            ("1068-uso-canale-rinominato", { s in
                s.dati.impostazioni.nomiCanali = NomiCanali(primo: "Agenzia Rossi", secondo: "Studio Bianchi")
                s.clienteAttivoId = "giulia"
                s.apri(.posizioni)
            }),
            // Migliorie d'uso 39: iPhone e iPad in un collegamento solo (un dispositivo annotato per l'istantanea,
            // «Cosa fanno insieme al Mac», «Modifiche in attesa»), la scheda del codice e Impostazioni › Vera con il rimando
            ("1069-uso-impostazioni-iphone-ipad", { s in preparaCollegamenti(s) }),
            ("1069-uso-impostazioni-iphone-ipad-scuro", { s in preparaCollegamenti(s) }),
            ("1070-uso-collega-dispositivo", { s in
                preparaCollegamenti(s)
                s.apriCodiceDispositivo()
            }),
            ("1071-uso-impostazioni-vera-rimando", { s in preparaImpostazioniApple(s, sezione: .vera) }),
        ]
    }

    /// Un codice fisso per le istantanee (valido per `PonteVera.normalizza`, mai usato davvero).
    nonisolated static let codicePonteDiProva = "PRSM-4K7Q-2XHN"

    /// Migliorie d'uso 39: lo spazio acceso sul Mac (dati di prova di «Prisma ovunque»), il collegamento acceso con il
    /// codice di prova e un dispositivo del ponte visto 2 minuti fa (solo nel registro in memoria dell'istantanea).
    nonisolated static func preparaCollegamenti(_ s: StatoShell) {
        s.dati.impostazioni.vera.ponte.codice = codicePonteDiProva
        s.dati.impostazioni.vera.ponte.condividi = true
        s.dispositivi.annotaPerIstantanea(RegistroDispositivi.Dispositivo(
            id: "ponte-istantanea", nome: RegistroDispositivi.generico, visto: Date().addingTimeInterval(-120), via: .ponte))
        preparaOvunque(s)
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
