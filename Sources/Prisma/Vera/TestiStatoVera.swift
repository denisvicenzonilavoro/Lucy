import Foundation

/// Migliorie d'uso 9, «Niente nomi tecnici in vista»: i testi dello stato di Vera in un posto solo. Sul Mac lo stato dice
/// solo se Vera è pronta («Pronta», «Vera · pronta»); il nome del motore e il motivo tecnico (Ollama, modello mancante)
/// stanno in Impostazioni › Vera. iPhone e iPad tengono i testi di prima finché non arriva il loro aggiornamento.
/// L'etichetta sotto le risposte (`EtichettaMotore.per`, regola bloccata del cervello grande) non passa di qui.
enum TestiStatoVera {
    /// Sotto «Vera» nel riquadro della scrivania.
    static let pronta = "Pronta"
    static let nonPronta = "Non pronta"
    /// Nella colonna dell'app Vera e nella testata della Vera della scrivania.
    static let veraPronta = "Vera · pronta"
    static let veraNonPronta = "Vera · non pronta"

    /// Il titolo del messaggio di Vera quando il motore non c'è. Si confronta sempre con `eTitoloNonPronta(_:)`, mai con
    /// la stringa: le conversazioni salvate prima tengono il titolo di prima.
    #if os(macOS)
    static let titoloNonPronta = "Vera non è pronta"
    #else
    static let titoloNonPronta = titoloDiPrima
    #endif
    /// Il titolo salvato nelle conversazioni fino alla miglioria 9 (resta riconosciuto).
    static let titoloDiPrima = "Qwen non è pronto"

    /// La spiegazione senza nomi tecnici.
    static let spiegazione = "Vera non risponde ancora: controlla in Impostazioni › Vera."
    /// Il pulsante che porta dove si vede il motivo.
    static let apriImpostazioni = "Apri Impostazioni › Vera"
    /// L'aiuto di «Verifica».
    static let aiutoVerifica = "Controlla di nuovo se Vera è pronta"

    /// Un testo che sul Mac non nomina il motore (dice «Vera» o «Prisma») e su iPhone e iPad resta quello di prima.
    static func inVista(mac: String, altrove: String) -> String {
        #if os(macOS)
        return mac
        #else
        return altrove
        #endif
    }

    /// true se il titolo è quello di Vera non pronta, di oggi o di prima.
    static func eTitoloNonPronta(_ titolo: String?) -> Bool {
        guard let t = titolo else { return false }
        return t == titoloNonPronta || t == titoloDiPrima
    }
}
