import Foundation

/// Le regole fiscali dei calcoli sul catalogo dei prodotti, in un solo posto: per aggiornarle basta cambiare qui.
///
/// Fonte: il foglio «Fiscalità» di `Supporto/catalogo/catalogo_lucy.xlsx` (copiato in `catalogo.json`, chiave
/// `fiscalita`, con il link di ogni regola) e le formule del foglio «Leggimi». Le aliquote dei rami danni diversi da
/// infortuni e malattia sono indicative (lo dice il Leggimi): vince sempre l'aliquota scritta nella riga del prodotto,
/// se c'è. Tutti i valori sono frazioni (0.025 = 2,5%).
enum FiscoCatalogo {

    // MARK: Imposte sui premi delle polizze danni (incluse nel prezzo)

    /// Infortuni e malattia: 2,5% («Premi di polizze danni: infortuni e malattia», anche per le complementari abbinate
    /// alle polizze vita).
    static let impostaInfortuniMalattia = 0.025
    /// Casa, incendio, furto e RC: 22,25% (aliquota di legge dei rami incendio e RC generale). Il foglio Fiscalità riporta
    /// 22,5% dal DIP Casa Genertel e alcune righe del catalogo 22,5%: per questo la riga del prodotto, se dice la sua
    /// aliquota, vince sempre su questa.
    static let impostaCasaRC = 0.2225
    /// Tutela legale: 12,5% («altri rami», DIP Casa Genertel ed. 06/2026).
    static let impostaTutelaLegale = 0.125
    /// Assistenza: 10% (stessa fonte).
    static let impostaAssistenza = 0.10
    /// RC auto: 12,5% di imposta (indicativa: varia per provincia) …
    static let impostaRCAuto = 0.125
    /// … più il 10,5% di contributo al Servizio sanitario nazionale.
    static let contributoSSNRCAuto = 0.105

    /// Il ramo fiscale di una polizza di protezione, per scegliere l'aliquota quando la riga non la dice.
    enum Ramo: String, CaseIterable, Sendable {
        case infortuniMalattia, casaRC, tutelaLegale, assistenza, rcAuto

        var nome: String {
            switch self {
            case .infortuniMalattia: return "infortuni e malattia"
            case .casaRC: return "casa e RC"
            case .tutelaLegale: return "tutela legale"
            case .assistenza: return "assistenza"
            case .rcAuto: return "RC auto"
            }
        }

        /// L'imposta sul premio (senza il contributo SSN).
        var imposta: Double {
            switch self {
            case .infortuniMalattia: return FiscoCatalogo.impostaInfortuniMalattia
            case .casaRC: return FiscoCatalogo.impostaCasaRC
            case .tutelaLegale: return FiscoCatalogo.impostaTutelaLegale
            case .assistenza: return FiscoCatalogo.impostaAssistenza
            case .rcAuto: return FiscoCatalogo.impostaRCAuto
            }
        }

        /// Il contributo SSN (solo RC auto).
        var contributoSSN: Double? { self == .rcAuto ? FiscoCatalogo.contributoSSNRCAuto : nil }

        /// Il ramo dalla categoria della riga («Infortuni», «Casa (mutuo)», «RC Auto»…); nil se non è chiaro (vita,
        /// TCM, LTC, auto senza RC…): allora l'imposta resta «dato non disponibile», mai un'aliquota tirata a indovinare.
        init?(categoria: String) {
            let c = CatalogoProdotti.normalizza(categoria)
            let parole = Set(c.split(separator: " ").map(String.init))
            if c.contains("rc auto") || parole.contains("rca") || c.contains("rc obbligatoria monopattini") {
                self = .rcAuto
            } else if c.contains("tutela legale") {
                self = .tutelaLegale
            } else if ["infortuni", "malattia", "salute", "malattie"].contains(where: { parole.contains($0) }) {
                self = .infortuniMalattia
            } else if parole.contains("assistenza") {
                self = .assistenza
            } else if ["casa", "rc", "incendio", "condominio"].contains(where: { parole.contains($0) }) || c.contains("catastrofal") {
                self = .casaRC
            } else {
                return nil
            }
        }
    }

    // MARK: Detrazioni IRPEF sui premi

    /// Detrazione IRPEF sui premi: 19%.
    static let aliquotaDetrazione = 0.19
    /// TCM e infortuni (morte e invalidità permanente non inferiore al 5%): premi fino a 530 € l'anno …
    static let massimaleTCMInfortuni = 530.0
    /// … 750 € se il beneficiario è un familiare con disabilità grave.
    static let massimaleTCMDisabilitaGrave = 750.0
    /// La soglia di invalidità permanente perché il premio sia detraibile: 5%.
    static let sogliaInvaliditaDetraibile = 0.05
    /// LTC (non autosufficienza): premi fino a 1.291,14 € l'anno, limite separato da quello della TCM (TUIR art. 15).
    static let massimaleLTC = 1291.14
    /// Oltre questo reddito la detrazione si riduce fino ad azzerarsi (detto nei passi, non calcolato).
    static let redditoRiduzioneDetrazione = 120_000.0

    /// Le regole di detrazione dei premi.
    enum Detrazione: String, Sendable {
        case tcmInfortuni, ltc

        func massimale(disabilitaGrave: Bool = false) -> Double {
            switch self {
            case .tcmInfortuni: return disabilitaGrave ? FiscoCatalogo.massimaleTCMDisabilitaGrave : FiscoCatalogo.massimaleTCMInfortuni
            case .ltc: return FiscoCatalogo.massimaleLTC
            }
        }

        var nome: String { self == .ltc ? "LTC" : "TCM e infortuni" }

        /// La regola dalla categoria della riga; nil se non è chiara.
        init?(categoria: String) {
            let c = CatalogoProdotti.normalizza(categoria)
            let parole = Set(c.split(separator: " ").map(String.init))
            if parole.contains("ltc") || c.contains("non autosufficien") {
                self = .ltc
            } else if ["tcm", "infortuni", "invalidita", "vita"].contains(where: { parole.contains($0) }) {
                self = .tcmInfortuni
            } else {
                return nil
            }
        }
    }

    // MARK: Prodotti finanziari

    /// Imposta di bollo annua sui prodotti finanziari (ramo III e V; nelle multiramo solo sulla quota in fondi): 0,2%.
    static let bollo = 0.002
    /// Imposta sostitutiva sui rendimenti delle polizze di investimento: 26% …
    static let impostaRendimenti = 0.26
    /// … 12,5% sulla quota in titoli di Stato e white list.
    static let impostaRendimentiTitoliStato = 0.125
}
