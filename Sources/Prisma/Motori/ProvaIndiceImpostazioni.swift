#if os(macOS)
import Foundation

/// Migliorie d'uso 30 «Le impostazioni si cercano, in gruppi con un nome»: l'indice della ricerca non resta indietro
/// rispetto alla colonna (ogni voce ha una pagina della colonna, nessun doppione, ogni ancora porta alla sua pagina) e la
/// ricerca non guarda maiuscole né accenti. Chiamata da `ProvaCalcoli.esegui()` sul thread principale; solo Mac.
enum ProvaIndiceImpostazioni {
    @MainActor static func esegui(_ verifica: VerificaCalcoli) {
        let colonna = IndiceImpostazioni.pagineInColonna
        let voci = IndiceImpostazioni.voci

        verifica.vero("Impostazioni: ogni pagina una volta sola nella colonna",
                      colonna.count == SchedaImpostazioni.allCases.count && Set(colonna) == Set(SchedaImpostazioni.allCases))
        verifica.vero("Impostazioni: i gruppi della colonna si chiamano «Lucy», «Il lavoro» e «Aiuto»",
                      IndiceImpostazioni.gruppi.compactMap { $0.titolo } == ["Lucy", "Il lavoro", "Aiuto"])
        verifica.vero("Impostazioni: ogni voce dell'indice ha una pagina della colonna",
                      voci.allSatisfy { colonna.contains($0.pagina) })
        let chiavi = voci.map { "\($0.pagina.rawValue)|\($0.titolo)|\($0.spiegazione)" }
        verifica.vero("Impostazioni: nessuna voce doppia nell'indice", Set(chiavi).count == chiavi.count)
        verifica.vero("Impostazioni: ogni voce ha titolo e spiegazione",
                      voci.allSatisfy { !$0.titolo.isEmpty && !$0.spiegazione.isEmpty })
        let senzaPagina = voci.filter { v in v.ancora.map { AppImpostazioni.paginaDellAncora($0) != v.pagina } ?? false }
        verifica.vero("Impostazioni: ogni ancora dell'indice porta alla sua pagina"
                      + (senzaPagina.isEmpty ? "" : " (\(senzaPagina.map { $0.titolo }.joined(separator: ", ")))"),
                      senzaPagina.isEmpty)

        let backup = IndiceImpostazioni.cerca("backup")
        verifica.vero("Impostazioni: «backup» trova Archivio e backup", backup.contains { $0.pagina == .archivio })
        let titoli: ([VoceIndiceImpostazioni]) -> [String] = { $0.map { "\($0.pagina.rawValue)|\($0.titolo)" } }
        verifica.vero("Impostazioni: «Backup», «bàckup» e « backup » trovano le stesse voci",
                      titoli(IndiceImpostazioni.cerca("Backup")) == titoli(backup)
                        && titoli(IndiceImpostazioni.cerca("bàckup")) == titoli(backup)
                        && titoli(IndiceImpostazioni.cerca("  backup ")) == titoli(backup))
        verifica.vero("Impostazioni: i risultati nell'ordine della colonna",
                      backup.map { colonna.firstIndex(of: $0.pagina) ?? 0 } == backup.map { colonna.firstIndex(of: $0.pagina) ?? 0 }.sorted())
        verifica.vero("Impostazioni: testo vuoto, nessun risultato", IndiceImpostazioni.cerca("   ").isEmpty)
        verifica.vero("Impostazioni: «xyzzy» non trova niente", IndiceImpostazioni.cerca("xyzzy").isEmpty)
        verifica.vero("Impostazioni: «l'acqua» trova anche con l'apostrofo tipografico",
                      !IndiceImpostazioni.cerca("l’acqua").isEmpty)
        verifica.vero("Impostazioni: i testi dei risultati",
                      TestiImpostazioni.risultati(3, "backup") == "3 risultati per «backup»"
                        && TestiImpostazioni.risultati(1, "backup") == "1 risultato per «backup»"
                        && TestiImpostazioni.risultati(0, "xyz") == "Nessun risultato per «xyz»")
        verifica.vero("Impostazioni: «Agenda e lavoro» si chiama «Agenda e orari»", SchedaImpostazioni.lavoro.titolo == "Agenda e orari")
    }
}
#endif
