import Foundation

// «L'acqua della scrivania» dentro `Prisma --prova-backup`: il campo nuovo delle impostazioni torna uguale dal backup,
// e un archivio della versione di oggi salvato prima del campo (senza la chiave) si apre con l'acqua accesa.

extension ProvaBackup {
    /// Lo stesso archivio codificato, senza la chiave `campo` dentro le impostazioni (come un archivio di prima).
    /// nil se il JSON non ha la forma attesa o la chiave non c'era.
    static func senzaCampo(_ campo: String, in archivio: Data) throws -> Data? {
        guard var radice = try JSONSerialization.jsonObject(with: archivio) as? [String: Any],
              var impostazioni = radice["impostazioni"] as? [String: Any],
              impostazioni.removeValue(forKey: campo) != nil else { return nil }
        radice["impostazioni"] = impostazioni
        return try JSONSerialization.data(withJSONObject: radice)
    }

    /// Migliorie d'uso 39: l'archivio senza i quattro filtri del ponte (`impostazioni.eve.ponte`), com'era prima.
    static func senzaFiltriPonte(in archivio: Data) throws -> Data? {
        guard var radice = try JSONSerialization.jsonObject(with: archivio) as? [String: Any],
              var impostazioni = radice["impostazioni"] as? [String: Any],
              var vera = impostazioni["eve"] as? [String: Any],
              var ponte = vera["ponte"] as? [String: Any] else { return nil }
        for chiave in ["modello", "inquadra", "nota", "tavolo"] {
            guard ponte.removeValue(forKey: chiave) != nil else { return nil }
        }
        vera["ponte"] = ponte
        impostazioni["eve"] = vera
        radice["impostazioni"] = impostazioni
        return try JSONSerialization.data(withJSONObject: radice)
    }
}
