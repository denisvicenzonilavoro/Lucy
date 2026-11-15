#if os(macOS)
import Foundation

/// Migliorie d'uso 70 «Il fascicolo si compone a vista»: la scheda di Marco in scuro, tutti i report spuntati (la
/// pillola «Tante da leggere a casa») e la prima pagina del PDF con l'indice sulla copertina, presentata come la
/// «83-presentazione». La 81 (la scheda aperta), la 82 (dall'appuntamento di Marco) e la 460 cambiano da sole.
extension Istantanee {
    nonisolated static var sceneFascicoloUso: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("81-fascicolo-scuro", { s in
                s.clienteAttivoId = "marco"
                s.apriProspetto(.fascicolo)
            }),
            ("1411-uso-fascicolo-tante-pagine", { s in preparaFascicoloTantePagine(s) }),
            ("1411-uso-fascicolo-tante-pagine-scuro", { s in preparaFascicoloTantePagine(s) }),
            ("1412-uso-fascicolo-pdf-copertina", { s in preparaFascicoloCopertina(s) }),
            ("1412-uso-fascicolo-pdf-copertina-scuro", { s in preparaFascicoloCopertina(s) }),
        ]
    }

    /// Tutti i report di Marco spuntati: più di dieci pagine.
    nonisolated static func preparaFascicoloTantePagine(_ s: StatoShell) {
        s.clienteAttivoId = "marco"
        s.sceltaFascicolo = Set(TipoProspetto.inFascicolo)
        s.apriProspetto(.fascicolo)
    }

    /// Il fascicolo di Marco (i report predefiniti) mostrato al cliente: la copertina con l'indice e «1 di n · fascicolo».
    nonisolated static func preparaFascicoloCopertina(_ s: StatoShell) {
        s.clienteAttivoId = "marco"
        guard let d = s.documentoFascicolo() else { return }
        s.presenta(d)
        s.presentazione?.etichettaContatore = TestiFascicolo.etichettaContatore
    }
}
#endif
