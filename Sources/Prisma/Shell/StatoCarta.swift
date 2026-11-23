import Foundation
#if os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

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

extension StatoShell {
    /// La Prima Pagina di adesso (NOVITÀ 1): mattino con gli incontri di oggi, sera (dalle 18) con quelli di domani.
    /// Non in modalità cliente (porta i nomi di tutti i clienti). La chiave cambia ogni ora: alle 6 e alle 18 si «ristampa».
    func primaPagina(ristampa: Int = 0) -> PrimaPagina {
        let adesso = Date()
        let cal = Calendar.current
        let ora = cal.component(.hour, from: adesso)
        return ricavato("prima-pagina|\(cal.startOfDay(for: adesso).timeIntervalSinceReferenceDate)|\(ora)|\(ristampa)") {
            let sera = MotorePrimaPagina.edizione(adesso, calendario: cal) == .sera
            let giorno = sera ? (cal.date(byAdding: .day, value: 1, to: adesso) ?? adesso) : adesso
            let nomi = Dictionary(dati.clienti.map { ($0.id, $0.nome) }, uniquingKeysWith: { a, _ in a })
            let incontri = appuntamentiDelGiorno(giorno)
                .filter { $0.stato == .pianificato && $0.tipo != .nonDisponibile }
                .map { IncontroPrimaPagina(ora: $0.inizio, chi: nomi[$0.clienteId] ?? $0.titolo, cosa: $0.titolo) }
            let inEssere = dati.posizioni.filter { $0.stato == .inEssere }
            let scadenze = inEssere.compactMap { p -> ScadenzaPrimaPagina? in
                guard let s = p.scadenza, let chi = nomi[p.clienteId] else { return nil }
                return ScadenzaPrimaPagina(cliente: chi, posizione: p.nome, data: s, valore: p.valore)
            }
            let chiamate = attivitaAperte.prefix(3).map {
                ChiamataPrimaPagina(chi: nomi[$0.clienteId] ?? "", perche: $0.titolo)
            }
            var i = IngressiPrimaPagina(data: adesso)
            i.incontri = incontri
            i.scadenze = scadenze
            i.daChiamare = Array(chiamate)
            i.patrimonio = inEssere.filter { $0.area != .debiti }.reduce(0) { $0 + $1.valore }
            i.clienti = dati.clienti.count
            return MotorePrimaPagina.componi(i, calendario: cal)
        }
    }

    /// «Ascolta»: Vera legge il titolo e gli incontri con la voce del Mac (nessun testo esce dal computer).
    func ascoltaPrimaPagina(_ p: PrimaPagina) {
        var testo = p.titolo + ". "
        if !p.incontri.isEmpty {
            testo += p.incontri.map { "Alle \(Formati.ora.string(from: $0.ora)), \($0.chi)." }.joined(separator: " ")
        }
        let vera = dati.impostazioni.vera
        voceVera.di(testo, voce: vera.voce, velocita: vera.velocitaVoce)
    }
}

#if os(macOS)
extension StatoShell {
    /// GDPR (art. 15 e 20): salva i dati di un cliente in un file JSON dove sceglie il consulente. Prisma non lo spedisce.
    func esportaDatiCliente(_ c: Cliente) {
        let pannello = NSSavePanel()
        pannello.allowedContentTypes = [.json]
        pannello.nameFieldStringValue = "Dati di \(c.nome.replacingOccurrences(of: "/", with: "-")).json"
        pannello.canCreateDirectories = true
        pannello.message = "Tutto ciò che Prisma conserva di \(c.nome). Il file resta dove lo salvi: Prisma non lo invia a nessuno."
        guard pannello.runModal() == .OK, let url = pannello.url else { return }
        do {
            try EsportazioneCliente.json(di: c.id, da: dati.istantanea).write(to: url, options: .atomic)
            mostraAvviso("Dati di \(c.nome) esportati.")
        } catch {
            mostraAvviso("Non sono riuscito a esportare i dati di \(c.nome).")
        }
    }
}
#endif
