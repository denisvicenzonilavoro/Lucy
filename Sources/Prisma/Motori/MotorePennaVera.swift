import Foundation

// La penna di Vera (NOVITÀ 4 dello stile Carta): le note scritte a mano in blu stilografica a margine delle schermate.
// Le scrive il codice, mai il modello: ogni cifra viene da un motore di Prisma (scontrino, costi). Al più due note per
// schermata, solo quelle che cambiano una decisione. Davanti al cliente non si vedono mai (`StatoShell.notePenna`).
// Puro: niente SwiftUI, niente rete.

/// Una nota della penna: il testo, già con le cifre di Prisma.
struct NotaPenna: Hashable, Identifiable {
    let testo: String
    var id: String { testo }
}

enum MotorePennaVera {
    /// Note al più per schermata.
    static let massimo = 2
    /// Sopra questa quota dei guadagni lordi presa dai costi la penna lo fa notare.
    static let quotaCostiAlta = 0.30

    /// Le note del conto di oggi del cliente (dossier).
    static func conto(_ c: ContoCliente) -> [NotaPenna] {
        var note: [NotaPenna] = []
        if c.resoMercati > 0, c.costiPagati / c.resoMercati >= quotaCostiAlta {
            let quota = Int((c.costiPagati / c.resoMercati * 100).rounded())
            note.append(NotaPenna(testo: "I costi si sono presi il \(quota)% di quello che hanno reso i mercati."))
        }
        if c.tasse > 0, c.netto > 0 {
            note.append(NotaPenna(testo: "Riscattando oggi, \(FormatoCifra.euro.testo(c.tasse)) andrebbero in tasse."))
        }
        return Array(note.prefix(massimo))
    }

    /// Le note dei costi di una posizione o di una proposta (Posizioni).
    static func costi(_ s: ScontrinoCosti) -> [NotaPenna] {
        guard s.costiNoti else {
            return [NotaPenna(testo: "Mancano i costi: con il KID li leggo io.")]
        }
        var note: [NotaPenna] = []
        if let a = s.alternativa {
            note.append(NotaPenna(testo: "Con \(a.nome), in \(a.anni) anni, \(FormatoCifra.euro.testo(a.guadagno)) in più."))
        }
        if s.perso10 > 0 {
            note.append(NotaPenna(testo: "In \(s.anni10) anni i costi tolgono \(FormatoCifra.euro.testo(s.perso10))."))
        }
        return Array(note.prefix(massimo))
    }
}
