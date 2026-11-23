import Foundation

// Il fascicolo in un tocco (NOVITÀ 5 dello stile Carta): dall'agenda o dal cliente la cartella dell'incontro si compone a
// vista. Questo motore decide cosa c'è dentro e scrive le «tre cose da dire», tutte con le cifre di Prisma (scontrino,
// costi, timbro, scadenze): mai inventate. Il PDF resta quello del fascicolo di sempre (Fascicolo.swift). Puro.

/// Una parte della cartella dell'incontro.
struct ParteCartella: Hashable, Identifiable {
    enum Tipo: String, CaseIterable {
        case quadro, posizioni, treCose, proposta, moduli

        var titolo: String {
            switch self {
            case .quadro: return "Il quadro"
            case .posizioni: return "Le posizioni e lo scontrino"
            case .treCose: return "Tre cose da dire"
            case .proposta: return "La proposta con il timbro"
            case .moduli: return "I moduli"
            }
        }
    }

    let tipo: Tipo
    /// Una riga che dice cosa c'è dentro («7 posizioni · 412.380 €»).
    let sotto: String
    var id: String { tipo.rawValue }
}

struct FascicoloCarta: Hashable {
    let parti: [ParteCartella]
    /// Al più tre frasi, dalla più importante.
    let treCose: [String]
}

enum MotoreFascicoloCarta {
    /// Compone la cartella. `costi`: gli scontrini dei costi delle posizioni in essere; `proposte`: le proposte aperte con
    /// il loro timbro; `moduli`: quanti moduli sono pronti da firmare; `data`: oggi.
    static func componi(posizioni: [Posizione], conto: ContoCliente, costi: [ScontrinoCosti],
                        proposte: [(Posizione, EsitoTimbro)], moduli: Int, data: Date) -> FascicoloCarta {
        let euro = FormatoCifra.euro
        let inEssere = posizioni.filter { $0.stato == .inEssere }
        var parti = [ParteCartella(tipo: .quadro, sotto: "Profilo, obiettivi e famiglia")]
        if !inEssere.isEmpty {
            let n = inEssere.count
            parti.append(ParteCartella(tipo: .posizioni,
                                        sotto: "\(n == 1 ? "1 posizione" : "\(n) posizioni") · \(euro.testo(conto.valore))"))
        }
        let cose = treCose(posizioni: inEssere, conto: conto, costi: costi, proposte: proposte, data: data)
        if !cose.isEmpty { parti.append(ParteCartella(tipo: .treCose, sotto: cose[0])) }
        if let prima = proposte.first {
            parti.append(ParteCartella(tipo: .proposta, sotto: "\(prima.0.nome) · \(prima.1.scritta.lowercased())"))
        }
        if moduli > 0 {
            parti.append(ParteCartella(tipo: .moduli, sotto: moduli == 1 ? "1 modulo da firmare" : "\(moduli) moduli da firmare"))
        }
        return FascicoloCarta(parti: parti, treCose: cose)
    }

    /// Le tre cose da dire, in ordine: una scadenza vicina, la posizione che costa di più (o l'alternativa che lascia di
    /// più), il timbro di una proposta da rivedere, il risultato netto del conto.
    static func treCose(posizioni: [Posizione], conto: ContoCliente, costi: [ScontrinoCosti],
                        proposte: [(Posizione, EsitoTimbro)], data: Date) -> [String] {
        let euro = FormatoCifra.euro
        var cose: [String] = []
        let fraTreMesi = Calendar(identifier: .gregorian).date(byAdding: .day, value: 90, to: data) ?? data
        if let s = posizioni.filter({ $0.scadenza.map { $0 >= data && $0 <= fraTreMesi } == true })
            .min(by: { ($0.scadenza ?? data) < ($1.scadenza ?? data) }), let quando = s.scadenza {
            cose.append("\(s.nome) scade il \(Formati.dataBreve.string(from: quando)): decidere dove va il capitale.")
        }
        if let alt = costi.compactMap({ c in c.alternativa.map { (c, $0) } }).max(by: { $0.1.guadagno < $1.1.guadagno }) {
            cose.append("\(alt.0.posizione.nome): con \(alt.1.nome), in \(alt.1.anni) anni, \(euro.testo(alt.1.guadagno)) in più.")
        } else if let cara = costi.filter(\.costiNoti).max(by: { $0.perso10 < $1.perso10 }), cara.perso10 > 0 {
            cose.append("\(cara.posizione.nome): in \(cara.anni10) anni i costi tolgono \(euro.testo(cara.perso10)).")
        }
        if let daRivedere = proposte.first(where: { !$0.1.coerente }), let primo = daRivedere.1.daRivedere.first {
            cose.append("\(daRivedere.0.nome): da rivedere, \(primo.voce.nome.lowercased()). \(primo.testo)")
        }
        if conto.posizioni > 0, cose.count < 3 {
            cose.append("Da quando hanno iniziato: \(conto.netto >= 0 ? "+" : "")\(euro.testo(conto.netto)) netti in tasca.")
        }
        return Array(cose.prefix(3))
    }
}
