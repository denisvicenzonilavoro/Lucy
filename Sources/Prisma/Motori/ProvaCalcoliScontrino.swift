import Foundation

/// Prova dello scontrino (NOVITÀ 6 dello stile Carta) dentro `Prisma --prova-calcoli`: il conto di oggi del cliente
/// (versato, reso dai mercati, costi pagati, tasse se riscatta oggi, netto in tasca) e lo scontrino dei costi di una
/// posizione o di una proposta (euro all'anno, a 5 e a 10 anni, l'alternativa a confronto). Le cifre vengono tutte
/// dai motori di Prisma (costi, riscatto): qui si controlla che lo scontrino le sommi giuste.
enum ProvaCalcoliScontrino {
    static func esegui(_ verifica: VerificaCalcoli) {
        let cal = Calendar.current
        let oggi = cal.startOfDay(for: Date())

        // Un fondo comune di 4 anni: 50.000 versati, 58.000 di valore, costi dell'1,5% all'anno
        var fondo = Posizione(clienteId: "scontrino", canale: .indipendente, stato: .inEssere, area: .investimento, nome: "Fondo")
        fondo.decorrenza = cal.date(byAdding: .year, value: -4, to: oggi)
        fondo.dataValore = oggi
        fondo.versamentoIniziale = 50_000
        fondo.totaleVersato = 50_000
        fondo.controvalore = 58_000
        fondo.costoAnnuo = 1.5
        fondo.tipologia = "Fondo comune"

        // La liquidità: 10.000 fermi, senza costi né tasse
        var conto = Posizione(clienteId: "scontrino", canale: .indipendente, stato: .inEssere, area: .liquidita, nome: "Conto")
        conto.totaleVersato = 10_000
        conto.controvalore = 10_000

        // Una proposta non entra nel conto di oggi
        var proposta = fondo
        proposta.id = "proposta-scontrino"
        proposta.stato = .proposta

        let c = MotoreScontrino.contoCliente([fondo, conto, proposta], data: oggi)
        verifica("Scontrino: versato (solo le posizioni in essere)", c.versato, 60_000)
        verifica("Scontrino: valore di oggi", c.valore, 68_000)
        verifica("Scontrino: differenza dal versato", c.differenza, 8_000)
        // Costi pagati stimati: 4 anni × 1,5% sul valore medio fra versato e valore (54.000) = 3.240
        verifica("Scontrino: costi pagati stimati", c.costiPagati, 3_240, tolleranza: 30)
        verifica("Scontrino: i mercati hanno reso differenza + costi", c.resoMercati, c.differenza + c.costiPagati, tolleranza: 0.01)
        verifica.vero("Scontrino: le tasse se riscatta oggi non sono negative", c.tasse >= 0)
        verifica("Scontrino: netto in tasca = valore − versato − tasse", c.netto, c.valore - c.versato - c.tasse, tolleranza: 0.01)
        verifica("Scontrino: resa netta sul versato", c.resaNetta ?? 0, c.netto / c.versato * 100, tolleranza: 0.0001)
        verifica.vero("Scontrino: le righe del conto sono quattro (versato, mercati, costi, tasse)", c.righe.count == 4)
        verifica("Scontrino: le prime tre righe tornano al valore", c.righe[0].importo + c.righe[1].importo + c.righe[2].importo,
                 c.valore, tolleranza: 0.01)

        let vuoto = MotoreScontrino.contoCliente([], data: oggi)
        verifica.vero("Scontrino: senza posizioni niente resa (nessuna divisione per zero)", vuoto.resaNetta == nil && vuoto.netto == 0)

        // I costi di una posizione: euro all'anno, a 5 e a 10 anni
        let s = MotoreScontrino.costi(fondo, prodotti: [], cliente: "scontrino")
        verifica("Scontrino: costi di quest'anno in euro (1,5% di 58.000)", s.euroAnno, 870, tolleranza: 0.5)
        verifica.vero("Scontrino: i costi a 10 anni pesano più che a 5", s.perso10 > s.perso5 && s.perso5 > 0)
        verifica.vero("Scontrino: a 5 anni i costi tolgono almeno metà di 5 anni di costi di oggi (anche dopo le imposte)", s.perso5 >= s.euroAnno * 5 * 0.5)
        verifica.vero("Scontrino: senza catalogo nessuna alternativa inventata", s.alternativa == nil)

        var senzaCosti = fondo
        senzaCosti.costoAnnuo = nil
        let z = MotoreScontrino.costi(senzaCosti, prodotti: [], cliente: "scontrino")
        verifica.vero("Scontrino: senza costi indicati lo dice (da completare con il KID)", !z.costiNoti && z.euroAnno == 0)

        // La penna di Vera (NOVITÀ 4): note scritte dal codice con le cifre di Prisma, al più due
        let costosa = ContoCliente(versato: 100_000, valore: 104_000, costiPagati: 6_000, tasse: 1_000, posizioni: 1)
        let noteConto = MotorePennaVera.conto(costosa)
        verifica.vero("Penna: i costi che si prendono il 60% dei guadagni si notano",
                      noteConto.first?.testo == "I costi si sono presi il 60% di quello che hanno reso i mercati.")
        verifica.vero("Penna: al più due note per schermata", noteConto.count <= MotorePennaVera.massimo)
        let leggera = ContoCliente(versato: 100_000, valore: 120_000, costiPagati: 1_000, tasse: 0, posizioni: 1)
        verifica.vero("Penna: niente note quando non c'è niente da dire", MotorePennaVera.conto(leggera).isEmpty)
        verifica.vero("Penna: senza costi chiede il KID", MotorePennaVera.costi(z).first?.testo == "Mancano i costi: con il KID li leggo io.")
        verifica.vero("Penna: con i costi noti dice quanto tolgono in 10 anni",
                      MotorePennaVera.costi(s).contains { $0.testo.hasPrefix("In \(s.anni10) anni i costi tolgono") })
    }
}
