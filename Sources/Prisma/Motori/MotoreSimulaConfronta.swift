import Foundation

// Migliorie d'uso 64 «Simula e confronta: prima la frase» (Design/uso/gruppo-12.md §64): le strade fra cui il
// consulente sceglie (le posizioni del cliente, le proposte aperte, le schede del catalogo, le ipotesi salvate,
// un'ipotesi sua e «Lasciare i soldi sul conto») e le loro cifre con **gli stessi soldi** (capitale, versamento
// mensile e anni comuni) e le stesse tasse e inflazione. Nessun calcolo nuovo: le cifre sono di `MotoreProiezione`
// (calcola, scenari, impattoCosti), come nel simulatore di prima. Motore puro: niente stato, niente viste.

/// La modalità di «Simula e confronta»: una strada, due a confronto o il TFR.
enum ModoSimula: Hashable {
    case una, due
    /// Migliorie d'uso 69: «Il TFR», la terza voce del segmentato (SimulaConfrontaTFR.swift).
    case tfr
}

/// Una strada di «Simula e confronta».
enum StradaSimula: Hashable {
    /// Una posizione del cliente, in essere o proposta aperta.
    case posizione(String)
    /// Una scheda del catalogo dei prodotti.
    case prodotto(String)
    /// Un'ipotesi salvata nel dossier (`Simulazione`).
    case simulazione(String)
    /// «Un'ipotesi mia» (decisione 64-d): rendimento e costi scritti dal consulente, solo in memoria.
    case libera
    /// «Lasciare i soldi sul conto» (decisione 64-b): rende 0%, costa 0%.
    case conto
}

/// I soldi, uguali per tutte le strade: quanto mette oggi, quanto al mese, per quanti anni.
struct SoldiSimula: Hashable {
    var capitale: Double
    var mensile: Double
    var anni: Int
}

/// Le ipotesi comuni: tasse sul guadagno e inflazione per «in soldi di oggi».
struct IpotesiSimula: Hashable {
    var tasse = IpotesiCalcolo.aliquotaPredefinita
    var inflazione = IpotesiCalcolo.inflazione
}

/// «Un'ipotesi mia» (decisione 64-d e 64-f): rendimento, costi e canale scritti a mano.
struct IpotesiLibera: Hashable {
    var nome = TestiSimulaConfronta.ipotesiMia
    var rendimento = IpotesiCalcolo.rendimentoPredefinito
    var costoIngresso = 0.0
    var costoAnnuo = 0.0
    var canale: Canale?
}

/// I gruppi del menu delle strade, nell'ordine in cui compaiono.
enum GruppoStrada: Int, CaseIterable, Hashable {
    case haGia, proposte, catalogo, salvate, mia, conto

    var titolo: String {
        switch self {
        case .haGia: return TestiSimulaConfronta.gruppoHaGia
        case .proposte: return TestiSimulaConfronta.gruppoProposte
        case .catalogo: return TestiSimulaConfronta.gruppoCatalogo
        case .salvate: return TestiSimulaConfronta.gruppoSalvate
        case .mia: return TestiSimulaConfronta.gruppoMia
        case .conto: return TestiSimulaConfronta.gruppoConto
        }
    }
}

/// Una strada con ciò che serve per proiettarla: nome, provenienza, canale, rendimento e costi (comparto unico,
/// come il simulatore di prima: per una multiramo a due parti gli equivalenti pesati sulle quote), SRI e scarti del KID.
struct OpzioneStrada: Hashable, Identifiable {
    let strada: StradaSimula
    let nome: String
    let provenienza: String
    let gruppo: GruppoStrada
    let canale: Canale?
    let rendimento: Double
    let costoIngresso: Double
    let costoAnnuo: Double
    /// L'SRI (1-7) per il confronto del rischio; nil se non si sa (ipotesi salvate e ipotesi mia).
    let sri: Int?
    /// Scarti degli scenari del KID dal moderato ([sfavorevole, favorevole]); nil = ±2 punti.
    let scarti: [Double]?

    var id: StradaSimula { strada }
}

/// Le cifre di una strada con i soldi comuni.
struct EsitoStrada {
    let opzione: OpzioneStrada
    let parametri: ParametriProiezione
    let esito: EsitoProiezione
    /// Prudente, atteso, favorevole (`MotoreProiezione.scenari`): «Male», «Come previsto», «Bene».
    let scenari: [(nome: String, rendimento: Double, esito: EsitoProiezione)]
    /// Quanto tolgono i costi (`MotoreProiezione.impattoCosti`).
    let impattoCosti: Double

    /// Il netto dello scenario sfavorevole («Se va male»).
    var seVaMale: Double { scenari.first?.esito.netto ?? esito.netto }
}

enum MotoreSimulaConfronta {
    /// «Quasi pari»: differenza sotto l'1% del netto migliore.
    static let sogliaQuasiPari = 0.01

    /// Le strade del cliente, nell'ordine del menu: posizioni in essere («ce l'ha già»), proposte aperte, schede
    /// proiettabili del catalogo non già usate dal cliente, ipotesi salvate, l'ipotesi mia (se c'è) e il conto.
    static func opzioni(posizioni: [Posizione], prodotti: [Prodotto], simulazioni: [Simulazione],
                        libera: IpotesiLibera?, orizzonteCliente: Int?) -> [OpzioneStrada] {
        var elenco: [OpzioneStrada] = []
        let proiettabili = posizioni.filter { $0.area.proiettabile }
        for p in proiettabili where p.stato == .inEssere {
            elenco.append(opzione(posizione: p, gruppo: .haGia, provenienza: TestiSimulaConfronta.haGia,
                                  orizzonteCliente: orizzonteCliente))
        }
        for p in proiettabili where propostaAperta(p) {
            elenco.append(opzione(posizione: p, gruppo: .proposte, provenienza: TestiSimulaConfronta.proposta,
                                  orizzonteCliente: orizzonteCliente))
        }
        let usati = Set(posizioni.compactMap(\.prodottoId))
        for s in prodotti where s.area.proiettabile && !usati.contains(s.id) {
            elenco.append(opzione(prodotto: s))
        }
        for s in simulazioni {
            elenco.append(OpzioneStrada(strada: .simulazione(s.id), nome: s.titolo,
                                        provenienza: TestiSimulaConfronta.salvata(s.creataIl), gruppo: .salvate,
                                        canale: s.canale, rendimento: s.rendimento, costoIngresso: s.costoIngresso,
                                        costoAnnuo: s.costoAnnuo, sri: nil, scarti: nil))
        }
        if let l = libera {
            elenco.append(OpzioneStrada(strada: .libera, nome: l.nome, provenienza: TestiSimulaConfronta.ipotesiMiaProvenienza,
                                        gruppo: .mia, canale: l.canale, rendimento: l.rendimento,
                                        costoIngresso: l.costoIngresso, costoAnnuo: l.costoAnnuo, sri: nil, scarti: nil))
        }
        elenco.append(conto)
        return elenco
    }

    /// «Lasciare i soldi sul conto»: rende 0%, costa 0%, rischio 1, nessun canale (decisione 64-b).
    static let conto = OpzioneStrada(strada: .conto, nome: TestiSimulaConfronta.conto,
                                     provenienza: TestiSimulaConfronta.nonFareNiente, gruppo: .conto, canale: nil,
                                     rendimento: 0, costoIngresso: 0, costoAnnuo: 0, sri: 1, scarti: nil)

    static func propostaAperta(_ p: Posizione) -> Bool {
        p.stato == .proposta && p.esito != .accettata && p.esito != .rifiutata
    }

    /// Una posizione come strada: rendimento e costi della sua proiezione (`ParametriProiezione(posizione:)`).
    static func opzione(posizione p: Posizione, gruppo: GruppoStrada, provenienza: String,
                        orizzonteCliente: Int?) -> OpzioneStrada {
        let q = ParametriProiezione(posizione: p, orizzonteCliente: orizzonteCliente)
        return OpzioneStrada(strada: .posizione(p.id), nome: p.nome, provenienza: provenienza, gruppo: gruppo,
                             canale: p.canale, rendimento: q.rendimentoEquivalente, costoIngresso: q.costoIngresso,
                             costoAnnuo: q.costoAnnuoEquivalente, sri: MotoreCoerenza.sriStimato(p), scarti: q.scartiKID)
    }

    /// Una scheda del catalogo come strada: le stesse ipotesi di «Simula» dalla scheda (`StatoShell.simula(_:)`).
    static func opzione(prodotto s: Prodotto) -> OpzioneStrada {
        let proposta = s.proposta(per: "simula")
        var rendimento = s.rendimentoAtteso ?? IpotesiCalcolo.rendimentoPredefinito
        var costoAnnuo = s.costoAnnuo ?? 0
        var scarti = s.scartiScenariKID
        if proposta.multiramoDivisa {
            let q = ParametriProiezione(posizione: proposta)
            rendimento = q.rendimentoEquivalente
            costoAnnuo = q.costoAnnuoEquivalente
            scarti = nil
        }
        return OpzioneStrada(strada: .prodotto(s.id), nome: s.nome, provenienza: TestiSimulaConfronta.dalCatalogo,
                             gruppo: .catalogo, canale: s.canale, rendimento: rendimento,
                             costoIngresso: s.costoIngresso ?? 0, costoAnnuo: costoAnnuo,
                             sri: MotoreCoerenza.sriStimato(proposta), scarti: scarti)
    }

    /// I parametri della proiezione: rendimento e costi della strada, soldi e anni comuni, tasse e inflazione comuni.
    static func parametri(_ o: OpzioneStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> ParametriProiezione {
        var q = ParametriProiezione(capitaleIniziale: max(0, soldi.capitale), versamento: max(0, soldi.mensile),
                                    frequenza: .mensile, anni: max(1, soldi.anni), rendimento: o.rendimento,
                                    costoIngresso: o.costoIngresso, costoAnnuo: o.costoAnnuo,
                                    aliquotaFiscale: ipotesi.tasse, inflazione: ipotesi.inflazione)
        q.scartiKID = o.scarti
        return q
    }

    /// Le cifre di una strada: esito, tre scenari e peso dei costi.
    static func esito(_ o: OpzioneStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula) -> EsitoStrada {
        let q = parametri(o, soldi: soldi, ipotesi: ipotesi)
        return EsitoStrada(opzione: o, parametri: q, esito: MotoreProiezione.calcola(q),
                           scenari: MotoreProiezione.scenari(q), impattoCosti: MotoreProiezione.impattoCosti(q))
    }

    /// La strada di partenza per A: la prima posizione in essere, poi la prima proposta, poi il catalogo, poi il conto.
    static func predefinitaA(_ opzioni: [OpzioneStrada]) -> StradaSimula {
        for g in [GruppoStrada.haGia, .proposte, .catalogo] {
            if let o = opzioni.first(where: { $0.gruppo == g }) { return o.strada }
        }
        return .conto
    }

    /// La strada di partenza per B: la prima scheda del catalogo diversa da A, altrimenti il conto (o, se A è il
    /// conto, la prima strada diversa).
    static func predefinitaB(_ opzioni: [OpzioneStrada], a: StradaSimula) -> StradaSimula {
        if let o = opzioni.first(where: { $0.gruppo == .catalogo && $0.strada != a }) { return o.strada }
        if a != .conto { return .conto }
        return opzioni.first(where: { $0.strada != a })?.strada ?? .conto
    }

    /// Sceglie `nuova` per A (o per B): se l'altra strada è proprio quella, le due si scambiano.
    static func scegli(_ nuova: StradaSimula, perA: Bool, a: StradaSimula, b: StradaSimula) -> (a: StradaSimula, b: StradaSimula) {
        if perA {
            return nuova == b ? (b, a) : (nuova, b)
        }
        return nuova == a ? (b, a) : (a, nuova)
    }

    /// L'ipotesi da salvare nel dossier: i parametri della strada con i soldi comuni, il titolo «<prime tre parole> ·
    /// <mensile> €/mese · <anni> anni» e la posizione se la strada è una posizione.
    static func simulazione(_ e: EsitoStrada, soldi: SoldiSimula, ipotesi: IpotesiSimula, cliente: String,
                            adesso: Date = Date()) -> Simulazione {
        var s = Simulazione(clienteId: cliente, titolo: TestiSimulaConfronta.titoloSalvata(nome: e.opzione.nome, soldi: soldi))
        s.creataIl = adesso
        s.capitale = soldi.capitale
        s.versamentoMensile = soldi.mensile
        s.anni = max(1, soldi.anni)
        s.rendimento = e.opzione.rendimento
        s.costoIngresso = e.opzione.costoIngresso
        s.costoAnnuo = e.opzione.costoAnnuo
        s.aliquota = ipotesi.tasse
        s.inflazione = ipotesi.inflazione
        s.canale = e.opzione.canale
        if case .posizione(let id) = e.opzione.strada { s.posizioneId = id }
        return s
    }

    /// Il vincitore di due strade: nil se quasi pari (differenza sotto l'1% del netto migliore).
    static func vincitore(_ a: EsitoStrada, _ b: EsitoStrada) -> Bool? {
        let migliore = max(abs(a.esito.netto), abs(b.esito.netto))
        if abs(a.esito.netto - b.esito.netto) < migliore * sogliaQuasiPari { return nil }
        return a.esito.netto > b.esito.netto
    }
}
