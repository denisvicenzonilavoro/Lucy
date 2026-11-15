#if os(macOS)
import Foundation

/// Le istantanee di Prospetti nel tema Apple (§4.5.1, §4.5.3), come PIE p01 e p10: la barra laterale con Giulia,
/// «Per l'incontro» con «Un anno insieme» scelto («nuovo»), la card «Fascicolo dell'incontro» e l'anteprima su carta
/// della prima pagina del report, in chiaro e in scuro (la carta resta bianca); poi la sala della presentazione con la
/// stessa pagina, «1 di N» e «Chiudi». Le cifre vengono dai motori di Prisma sui dati di prova.
extension Istantanee {
    nonisolated static var sceneProspettiApple: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("460-prospetti-apple", { s in preparaProspettiApple(s) }),
            ("460-prospetti-apple-scuro", { s in preparaProspettiApple(s) }),
            ("461-prospetti-sala", { s in
                preparaProspettiApple(s)
                if let d = s.documentoProspetto(sceltaProspettiApple) { s.presenta(d) }
            }),
            // Migliorie d'uso 22: il check-up di Giulia nella versione per te, con «Per il cliente | Per te» sopra la
            // pagina e il timbro «SOLO PER TE» sulla carta (la 460 mostra già «Solo per il cliente» di «Un anno insieme»)
            ("466-prospetti-per-te", { s in preparaProspettiPerTe(s) }),
            ("466-prospetti-per-te-scuro", { s in preparaProspettiPerTe(s) }),
            // Migliorie d'uso 23: l'elenco per momento con Giulia, che oggi alle 9:30 ha la revisione «Il punto sul
            // progetto casa»: il resoconto, primo dell'elenco tra i report adatti, porta «per l'incontro di oggi».
            // La scheda «A cosa serve» (465) è un popover: le istantanee non lo catturano, serve uno screenshot.
            ("464-prospetti-elenco-incontro-oggi", { s in preparaProspettiIncontroOggi(s) }),
        ]
    }

    /// «Un anno insieme» di Giulia: il primo della lista «Per l'incontro», come nel template.
    nonisolated static var sceltaProspettiApple: SceltaProspetto { .annoInsieme }

    /// Prospetti aperto su Giulia, con il report scelto.
    nonisolated static func preparaProspettiApple(_ s: StatoShell) {
        s.clienteAttivoId = "giulia"
        s.apriProspetto(sceltaProspettiApple)
    }

    /// Prospetti aperto su Giulia con il resoconto per il cliente: la riga scelta porta «per l'incontro di oggi».
    nonisolated static func preparaProspettiIncontroOggi(_ s: StatoShell) {
        s.clienteAttivoId = "giulia"
        s.versioneProspetti = .perIlCliente
        s.apriProspetto(.resoconto(report: true))
    }

    /// Prospetti aperto su Giulia, con il check-up nella versione per te (ricordata per la sessione).
    nonisolated static func preparaProspettiPerTe(_ s: StatoShell) {
        s.clienteAttivoId = "giulia"
        s.versioneProspetti = .perTe
        s.apriProspetto(.checkUp(report: false))
    }
}
#endif
