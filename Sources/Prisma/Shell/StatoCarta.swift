import Foundation

// I dati ricavati dello stile Carta, in cache come gli altri (`ricavato`): il timbro di una proposta (NOVITÀ 7).
// Le viste leggono da qui, mai i motori dentro un body.

extension StatoShell {
    /// Il timbro di Vera su una proposta: coerenza con il profilo, liquidità di emergenza, peso sul patrimonio con la soglia
    /// scelta in Impostazioni e costi. nil se la posizione non è una proposta o il cliente non c'è.
    func timbro(_ p: Posizione) -> EsitoTimbro? {
        guard p.stato == .proposta, let c = cliente(p.clienteId) else { return nil }
        let soglia = dati.impostazioni.carta.sogliaPesoTimbro
        return ricavato("timbro|\(p.id)|\(soglia)") {
            let coerenza = coerenzaCliente(c)
            let liquidita = MotoreLiquidita.calcola(posizioniCliente(c.id), obiettivi: obiettiviCliente(c.id),
                                                    analisi: analisi360(c.id).protezione, prodotti: dati.prodotti)
            return MotoreTimbro.controlla(p, incoerenze: coerenza.incoerenze, liquidita: liquidita.liquiditaAttuale,
                                          riserva: liquidita.riservaNecessaria,
                                          patrimonio: coerenza.oggi.patrimonioFinanziario, soglia: soglia)
        }
    }
}

extension StatoShell {
    /// Il fascicolo in un tocco di un cliente (NOVITÀ 5): le parti della cartella e le tre cose da dire.
    func fascicoloCarta(_ c: Cliente) -> FascicoloCarta {
        ricavato("fascicolo-carta|\(c.id)|\(dati.impostazioni.carta.sogliaPesoTimbro)") {
            let mie = posizioniCliente(c.id)
            let conto = MotoreScontrino.contoCliente(mie, data: Date())
            let costi = mie.filter { $0.stato == .inEssere && $0.area.proiettabile }
                .map { MotoreScontrino.costi($0, prodotti: dati.prodotti, cliente: c.id) }
            let proposte = mie.filter { $0.stato == .proposta }.compactMap { p in timbro(p).map { (p, $0) } }
            return MotoreFascicoloCarta.componi(posizioni: mie, conto: conto, costi: costi, proposte: proposte,
                                                moduli: 0, data: Date())
        }
    }
}
