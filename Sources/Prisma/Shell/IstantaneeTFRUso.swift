#if os(macOS)
import Foundation

/// Migliorie d'uso 69 «Il TFR: prima la risposta»: la differenza piccola con pochi anni, il fondo che resta indietro
/// («conviene lasciarlo in azienda») e «Altre ipotesi» aperto con tutti i comandi di oggi. In chiaro e in scuro.
/// La 204, la 207 e la 208 (Marco, Marco con i contributi, Marco non dipendente) cambiano da sole.
extension Istantanee {
    nonisolated static var sceneTFRUso: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("1408-uso-analisi360-tfr-piccola", { s in preparaTFRPiccola(s) }),
            ("1408-uso-analisi360-tfr-piccola-scuro", { s in preparaTFRPiccola(s) }),
            ("1409-uso-analisi360-tfr-azienda", { s in preparaTFRAzienda(s) }),
            ("1409-uso-analisi360-tfr-azienda-scuro", { s in preparaTFRAzienda(s) }),
            ("1410-uso-analisi360-tfr-altre-ipotesi", { s in preparaTFRAltreIpotesi(s) }),
            ("1410-uso-analisi360-tfr-altre-ipotesi-scuro", { s in preparaTFRAltreIpotesi(s) }),
        ]
    }

    /// Le ipotesi di Marco da capo, con le cifre della frase scelte (le prove T17 di `ProvaCalcoliTFR` usano le stesse).
    nonisolated static func ipotesiTFRUso(retribuzione: Double, anni: Int, rendimento: Double) -> IpotesiTFR {
        var i = IpotesiTFR()
        i.retribuzione = retribuzione
        i.anni = anni
        i.rendimentoFondo = rendimento
        i.rendimentoNetto = true
        i.canale = .indipendente
        i.nomeFondo = "Fondo negoziale di categoria"
        return i
    }

    nonisolated static func apriTFRUso(_ s: StatoShell) {
        s.scegliStrumentoAnalisi(.tfr)
        s.apri(.analisi360)
    }

    /// Sei anni alla pensione e il fondo fermo: «la differenza è piccola … Mancano pochi anni».
    nonisolated static func preparaTFRPiccola(_ s: StatoShell) {
        s.clienteAttivoId = "marco"
        s.salvaIpotesiTFR("marco", ipotesiTFRUso(retribuzione: 30_000, anni: 6, rendimento: 0))
        apriTFRUso(s)
    }

    /// Vent'anni con il fondo allo 0,5% netto: «Con queste ipotesi a Marco conviene lasciarlo in azienda».
    nonisolated static func preparaTFRAzienda(_ s: StatoShell) {
        s.clienteAttivoId = "marco"
        s.salvaIpotesiTFR("marco", ipotesiTFRUso(retribuzione: 40_000, anni: 20, rendimento: 0.5))
        apriTFRUso(s)
    }

    /// Le ipotesi della 204 (contributi del cliente e del datore) con «Altre ipotesi» aperto.
    nonisolated static func preparaTFRAltreIpotesi(_ s: StatoShell) {
        s.clienteAttivoId = "marco"
        var i = s.ipotesiTFR("marco")
        i.contributoLavoratore = 1.2
        i.contributoDatore = 1.6
        i.canale = .indipendente
        i.nomeFondo = "Fondo negoziale di categoria"
        s.salvaIpotesiTFR("marco", i)
        s.altreIpotesiTFR = true
        apriTFRUso(s)
    }
}
#endif
