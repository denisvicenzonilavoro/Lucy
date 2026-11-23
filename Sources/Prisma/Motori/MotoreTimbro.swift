import Foundation

// Il timbro (NOVITÀ 7 dello stile Carta): Vera controlla che una proposta sia coerente con il profilo del cliente e
// mette il timbro sul documento. Cinque controlli, tutti del codice: rischio ed esperienza (MotoreCoerenza), orizzonte
// (MotoreCoerenza), liquidità di emergenza (MotoreLiquidita: la riserva resta intatta dopo il versamento), peso sul
// patrimonio (oltre la soglia scelta dall'utente in Impostazioni) e costi (oltre la soglia alta di MotoreCosti).
// È sempre un aiuto: non sostituisce la valutazione di adeguatezza prevista dalle procedure, e il timbro lo scrive.
// Puro: niente SwiftUI, niente rete.

/// Uno dei cinque controlli del timbro.
struct ControlloTimbro: Hashable, Identifiable {
    enum Voce: String, CaseIterable {
        case rischio, orizzonte, liquidita, peso, costi

        var nome: String {
            switch self {
            case .rischio: return "Rischio"
            case .orizzonte: return "Orizzonte"
            case .liquidita: return "Liquidità di emergenza"
            case .peso: return "Peso sul patrimonio"
            case .costi: return "Costi"
            }
        }
    }

    let voce: Voce
    /// true se il controllo passa.
    let passa: Bool
    let testo: String
    var id: String { voce.rawValue }
}

/// L'esito del timbro: coerente solo se passano tutti e cinque i controlli.
struct EsitoTimbro: Hashable {
    let controlli: [ControlloTimbro]
    var coerente: Bool { controlli.allSatisfy(\.passa) }
    var daRivedere: [ControlloTimbro] { controlli.filter { !$0.passa } }
    /// La scritta del timbro.
    var scritta: String { coerente ? "Coerente con il profilo" : "Da rivedere" }
}

enum MotoreTimbro {
    /// La frase che accompagna sempre il timbro.
    static let avvertenza = "Un aiuto di Vera: non sostituisce la valutazione di adeguatezza prevista dalle procedure."

    /// L'importo che la proposta chiede oggi: il versamento iniziale o, se non c'è, un anno di premi.
    static func importo(_ p: Posizione) -> Double {
        p.versamentoIniziale > 0 ? p.versamentoIniziale : p.premioAnnuo
    }

    /// I cinque controlli di una proposta.
    /// - incoerenze: quelle di MotoreCoerenza per il cliente (si guardano solo quelle di questa proposta).
    /// - liquidita, riserva: la liquidità di oggi e la riserva di emergenza (MotoreLiquidita); riserva 0 = non calcolata.
    /// - patrimonio: il patrimonio finanziario di oggi; soglia: il peso massimo in % (Impostazioni › Carta).
    static func controlla(_ proposta: Posizione, incoerenze: [Incoerenza], liquidita: Double, riserva: Double,
                          patrimonio: Double, soglia: Double) -> EsitoTimbro {
        let mie = incoerenze.filter { $0.posizione?.id == proposta.id }
        let euro = FormatoCifra.euro
        var c: [ControlloTimbro] = []

        // Rischio ed esperienza
        let rischio = mie.filter { [.proposta, .esperienza, .perdite].contains($0.tipo) }
        c.append(ControlloTimbro(voce: .rischio, passa: rischio.isEmpty,
                                 testo: rischio.first?.titolo ?? "Nel profilo di rischio e nell'esperienza del cliente."))
        // Orizzonte
        let orizzonte = mie.first { $0.tipo == .orizzonte }
        c.append(ControlloTimbro(voce: .orizzonte, passa: orizzonte == nil,
                                 testo: orizzonte?.titolo ?? "Dentro l'orizzonte del cliente."))
        // Liquidità di emergenza: la riserva resta intatta dopo il versamento
        let importo = importo(proposta)
        if riserva > 0 {
            let resta = liquidita - importo
            let passa = resta >= riserva
            c.append(ControlloTimbro(voce: .liquidita, passa: passa,
                                     testo: passa ? "Dopo il versamento restano \(euro.testo(resta)), la riserva è al sicuro."
                                                  : "Dopo il versamento restano \(euro.testo(max(0, resta))): sotto la riserva di \(euro.testo(riserva))."))
        } else {
            c.append(ControlloTimbro(voce: .liquidita, passa: false,
                                     testo: "La riserva di emergenza non è calcolata: manca il fabbisogno mensile."))
        }
        // Peso sul patrimonio
        if patrimonio > 0 {
            let peso = importo / patrimonio * 100
            let passa = peso <= soglia
            c.append(ControlloTimbro(voce: .peso, passa: passa,
                                     testo: "Pesa il \(Int(peso.rounded()))% del patrimonio (soglia \(Int(soglia.rounded()))%)."))
        } else {
            c.append(ControlloTimbro(voce: .peso, passa: false, testo: "Il patrimonio del cliente non è noto."))
        }
        // Costi
        if let costo = proposta.costoComplessivo {
            let passa = costo <= MotoreCosti.sogliaAlto
            c.append(ControlloTimbro(voce: .costi, passa: passa,
                                     testo: "Costo annuo \(FormatoCifra.percentuale.testo(costo))" + (passa ? "." : ": sopra la soglia alta.")))
        } else {
            c.append(ControlloTimbro(voce: .costi, passa: false, testo: "Costi non indicati: servono il KID o la scheda."))
        }
        return EsitoTimbro(controlli: c)
    }
}
