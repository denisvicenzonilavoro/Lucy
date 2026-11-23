import Foundation

/// Prova del timbro (NOVITÀ 7 dello stile Carta) dentro `Prisma --prova-calcoli`: i cinque controlli (rischio,
/// orizzonte, liquidità di emergenza, peso sul patrimonio con la soglia scelta, costi) e la scritta del timbro.
enum ProvaCalcoliTimbro {
    static func esegui(_ verifica: VerificaCalcoli) {
        var p = Posizione(clienteId: "timbro", canale: .alleanza, stato: .proposta, area: .investimento, nome: "Proposta")
        p.versamentoIniziale = 20_000
        p.costoAnnuo = 1.2

        let buona = MotoreTimbro.controlla(p, incoerenze: [], liquidita: 50_000, riserva: 15_000, patrimonio: 200_000, soglia: 30)
        verifica.vero("Timbro: proposta coerente con tutti e cinque i controlli", buona.coerente && buona.controlli.count == 5)
        verifica.vero("Timbro: la scritta del timbro coerente", buona.scritta == "Coerente con il profilo")
        verifica.vero("Timbro: l'avvertenza dice che non sostituisce l'adeguatezza",
                      MotoreTimbro.avvertenza.contains("non sostituisce la valutazione di adeguatezza"))

        // Peso oltre la soglia scelta: 20.000 su 50.000 = 40%
        let pesante = MotoreTimbro.controlla(p, incoerenze: [], liquidita: 50_000, riserva: 15_000, patrimonio: 50_000, soglia: 30)
        verifica.vero("Timbro: peso oltre la soglia da rivedere", !pesante.coerente && pesante.daRivedere.map(\.voce) == [.peso])
        let soglia50 = MotoreTimbro.controlla(p, incoerenze: [], liquidita: 50_000, riserva: 15_000, patrimonio: 50_000, soglia: 50)
        verifica.vero("Timbro: con la soglia al 50% lo stesso peso passa", soglia50.coerente)

        // La riserva di emergenza: 30.000 − 20.000 = 10.000 sotto 15.000
        let corta = MotoreTimbro.controlla(p, incoerenze: [], liquidita: 30_000, riserva: 15_000, patrimonio: 200_000, soglia: 30)
        verifica.vero("Timbro: la riserva intaccata da rivedere", corta.daRivedere.map(\.voce) == [.liquidita])
        let senzaRiserva = MotoreTimbro.controlla(p, incoerenze: [], liquidita: 30_000, riserva: 0, patrimonio: 200_000, soglia: 30)
        verifica.vero("Timbro: senza fabbisogno la riserva non si dà per buona", senzaRiserva.daRivedere.map(\.voce) == [.liquidita])

        // Costi alti e costi mancanti
        var cara = p
        cara.costoAnnuo = MotoreCosti.sogliaAlto + 0.5
        verifica.vero("Timbro: costi sopra la soglia alta da rivedere",
                      MotoreTimbro.controlla(cara, incoerenze: [], liquidita: 50_000, riserva: 15_000, patrimonio: 200_000, soglia: 30)
                          .daRivedere.map(\.voce) == [.costi])
        var muta = p
        muta.costoAnnuo = nil
        verifica.vero("Timbro: senza costi indicati non si timbra coerente",
                      !MotoreTimbro.controlla(muta, incoerenze: [], liquidita: 50_000, riserva: 15_000, patrimonio: 200_000, soglia: 30).coerente)

        // Rischio e orizzonte da MotoreCoerenza, solo quelli di questa proposta
        let oltre = Incoerenza(tipo: .proposta, titolo: "SRI 6 oltre il profilo", dettaglio: "", posizione: p, valore: 6, soglia: 4,
                               dopoLeProposte: true)
        let lunga = Incoerenza(tipo: .orizzonte, titolo: "Durata oltre l'orizzonte", dettaglio: "", posizione: p, valore: 15, soglia: 10,
                               dopoLeProposte: true)
        var altra = p
        altra.id = "altra-proposta"
        let dAltri = Incoerenza(tipo: .proposta, titolo: "Altra", dettaglio: "", posizione: altra, valore: 6, soglia: 4, dopoLeProposte: true)
        let e = MotoreTimbro.controlla(p, incoerenze: [oltre, lunga, dAltri], liquidita: 50_000, riserva: 15_000,
                                       patrimonio: 200_000, soglia: 30)
        verifica.vero("Timbro: rischio e orizzonte della proposta da rivedere", e.daRivedere.map(\.voce) == [.rischio, .orizzonte])
        verifica.vero("Timbro: il testo del rischio è quello di MotoreCoerenza", e.daRivedere.first?.testo == "SRI 6 oltre il profilo")
        verifica.vero("Timbro: le incoerenze di altre proposte non contano",
                      MotoreTimbro.controlla(p, incoerenze: [dAltri], liquidita: 50_000, riserva: 15_000, patrimonio: 200_000, soglia: 30).coerente)

        // Un premio annuo senza versamento iniziale
        var annua = p
        annua.versamentoIniziale = 0
        annua.premio = 1_000
        annua.frequenza = .mensile
        verifica("Timbro: l'importo di un piano è un anno di premi", MotoreTimbro.importo(annua), 12_000)
    }
}
