import Foundation

// Lo scontrino (NOVITÀ 6 dello stile Carta, lo stesso linguaggio di Prisma AI): il conto di oggi del cliente e lo
// scontrino dei costi di ogni posizione e di ogni proposta. Puro: niente SwiftUI, niente rete, nessuna data presa da
// sola. Le cifre le danno i motori di sempre: MotoreCosti (costi dell'anno, costi persi a 5 e 10 anni, alternativa a
// parità di rischio) e MotoreRiscatto (imposta se il cliente riscatta oggi). I costi già pagati sono una stima
// dichiarata: costo annuo per gli anni trascorsi sul valore medio fra versato e valore di oggi.

/// Una riga dello scontrino: un'etichetta e un importo con il segno.
struct RigaScontrino: Hashable {
    let etichetta: String
    let importo: Double
    /// true se l'importo va scritto con il segno (+ o −).
    var conSegno = true
}

/// Il conto di oggi del cliente: quanto ha versato, quanto vale, cosa hanno fatto i mercati e i costi, e quanto
/// gli resterebbe in tasca riscattando oggi. Solo le posizioni finanziarie in essere con il versato noto.
struct ContoCliente: Hashable {
    let versato: Double
    let valore: Double
    /// Stima dei costi pagati finora (costo annuo × anni trascorsi sul valore medio).
    let costiPagati: Double
    /// Le imposte se il cliente riscattasse tutto oggi (MotoreRiscatto, anno 0).
    let tasse: Double
    /// Quante posizioni entrano nel conto.
    let posizioni: Int

    /// Valore meno versato.
    var differenza: Double { valore - versato }
    /// Cosa hanno reso i mercati prima dei costi.
    var resoMercati: Double { differenza + costiPagati }
    /// Il netto in tasca rispetto al versato, tasse comprese.
    var netto: Double { differenza - tasse }
    /// La resa netta in totale sul versato, in percentuale (nil senza versato).
    var resaNetta: Double? { versato > 0 ? netto / versato * 100 : nil }

    /// Le righe dello scontrino: versato, reso dai mercati, costi pagati, tasse se riscatta oggi.
    var righe: [RigaScontrino] {
        [RigaScontrino(etichetta: "Hanno versato", importo: versato, conSegno: false),
         RigaScontrino(etichetta: "Hanno reso i mercati", importo: resoMercati),
         RigaScontrino(etichetta: "Costi pagati", importo: -costiPagati),
         RigaScontrino(etichetta: "Tasse se riscattano oggi", importo: -tasse)]
    }
}

/// Lo scontrino dei costi di una posizione o di una proposta: euro di quest'anno, quanto tolgono i costi in 5 e in
/// 10 anni (o fino alla scadenza) e l'alternativa del catalogo che costa meno a parità di rischio, se c'è.
struct ScontrinoCosti {
    struct Alternativa: Hashable {
        let nome: String
        /// Costo annuo dell'alternativa, in %.
        let costoAnnuo: Double
        /// I suoi costi di quest'anno in euro, sullo stesso valore.
        let euroAnno: Double
        /// Netto in più a fine periodo, uscita compresa.
        let guadagno: Double
        /// Gli anni del confronto.
        let anni: Int
        /// Penali e imposte pagate oggi per cambiare.
        let costoUscita: Double
    }

    let posizione: Posizione
    /// false se la posizione non ha costi indicati: lo scontrino chiede il KID invece di inventare.
    let costiNoti: Bool
    /// Costo annuo complessivo in %.
    let annuo: Double
    let euroAnno: Double
    let anni5: Int
    let perso5: Double
    let anni10: Int
    let perso10: Double
    let alternativa: Alternativa?
}

enum MotoreScontrino {
    /// Il conto di oggi del cliente dalle sue posizioni (le altre si scartano: proposte, chiuse, non finanziarie,
    /// senza versato).
    static func contoCliente(_ posizioni: [Posizione], data: Date) -> ContoCliente {
        var versato = 0.0, valore = 0.0, costi = 0.0, tasse = 0.0, n = 0
        for p in posizioni where p.stato == .inEssere && (p.area.proiettabile || p.area == .liquidita) {
            guard let v = versatoNoto(p) else { continue }
            n += 1
            versato += v
            valore += p.valore
            costi += costiPagati(p, versato: v, data: data)
            if let r = MotoreRiscatto.calcola(p, data: data)?.righe.first(where: { $0.anni == 0 }) {
                tasse += max(0, r.imposta)
            }
        }
        return ContoCliente(versato: versato, valore: valore, costiPagati: costi, tasse: tasse, posizioni: n)
    }

    /// Il versato noto di una posizione (come il resoconto): il totale versato o, se manca, il versamento iniziale.
    static func versatoNoto(_ p: Posizione) -> Double? {
        if let t = p.totaleVersato { return t }
        return p.versamentoIniziale > 0 ? p.versamentoIniziale : nil
    }

    /// Stima dei costi già pagati: costo annuo complessivo × anni dalla decorrenza × valore medio.
    static func costiPagati(_ p: Posizione, versato: Double, data: Date) -> Double {
        guard let costo = p.costoComplessivo, costo > 0, let inizio = p.decorrenza, inizio < data else { return 0 }
        let anni = data.timeIntervalSince(inizio) / (365.25 * 86_400)
        return costo / 100 * anni * (versato + p.valore) / 2
    }

    /// Lo scontrino dei costi di una posizione in essere o di una proposta.
    static func costi(_ p: Posizione, prodotti: [Prodotto], cliente: String) -> ScontrinoCosti {
        let noti = p.costoComplessivo != nil || p.costoIngresso != nil
        let a5 = MotoreCosti.anni(p, 5), a10 = MotoreCosti.anni(p, 10)
        guard noti else {
            return ScontrinoCosti(posizione: p, costiNoti: false, annuo: 0, euroAnno: 0, anni5: a5, perso5: 0,
                                  anni10: a10, perso10: 0, alternativa: nil)
        }
        let voce = MotoreCosti.voce(p, prodotti: prodotti, cliente: cliente)
        let alternativa = voce.alternativa.map {
            ScontrinoCosti.Alternativa(nome: $0.prodotto.nome, costoAnnuo: $0.costoAnnuo,
                                       euroAnno: p.valore * $0.costoAnnuo / 100, guadagno: $0.guadagno,
                                       anni: $0.anni, costoUscita: $0.costoUscita)
        }
        return ScontrinoCosti(posizione: p, costiNoti: true, annuo: voce.annuo, euroAnno: voce.euroAnno,
                              anni5: a5, perso5: MotoreCosti.perso(p, anni: a5),
                              anni10: voce.anni10, perso10: voce.perso10, alternativa: alternativa)
    }
}
