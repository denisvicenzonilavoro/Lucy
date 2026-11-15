import Foundation

/// Prove dei simulatori dal vivo di Previdenza e Protezione (Analisi 360, §4.3.2-4.3.3): con il versamento delle
/// ipotesi il passo leggero dà gli stessi numeri di `MotoreAnalisi.previdenza`; deduzione entro il limite e IRPEF
/// per scaglioni; tariffa caso morte dal cliente o, se manca, dall'archivio; premio, scoperto e copertura.
/// Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliSimulatoriAnalisi {
    static func esegui(_ verifica: VerificaCalcoli) {
        previdenza(verifica)
        protezione(verifica)
        primaEDopo(verifica)
    }

    /// Migliorie d'uso 45: gli articoli, la frase prima e dopo, i rendimenti da scegliere e l'aliquota scelta.
    private static func primaEDopo(_ verifica: VerificaCalcoli) {
        let t = TestiSimulatoriAnalisi.self
        verifica.vero("Simulatore: «il 42%»", t.articolo(42) == "il 42%")
        verifica.vero("Simulatore: «l'80%»", t.articolo(80) == "l'80%")
        verifica.vero("Simulatore: «l'1%» e «l'8%»", t.articolo(1) == "l'1%" && t.articolo(8) == "l'8%")
        verifica.vero("Simulatore: «il 18%» non si elide", t.articolo(18) == "il 18%")
        verifica.vero("Simulatore: «all'11%»", t.al(11) == "all'11%")
        verifica.vero("Simulatore: «al 100%» e «allo 0%»", t.al(100) == "al 100%" && t.al(0) == "allo 0%")

        var i = IpotesiPrevidenza()
        i.eta = 40; i.etaPensione = 67; i.redditoDesiderato = 2_200; i.pensionePubblica = 1_400
        i.capitale = 0; i.versamentoMensile = 0; i.rendimentoReale = 1.5; i.anniIntegrazione = 25
        let fermo = MotoreSimulatoriAnalisi.previdenza(i, versamento: 0, reddito: nil)
        let senza = t.testo(t.previdenza(nome: "Marco", oggi: 0, versamento: 0, coperturaOggi: fermo.copertura, passo: fermo))
        verifica.vero("Simulatore: nessun versamento, divario tutto scoperto",
                      senza == "Oggi Marco non versa niente: il divario è tutto scoperto. " + t.invito)
        // Un versamento che chiude il divario
        let pieno = MotoreSimulatoriAnalisi.previdenza(i, versamento: 5_000, reddito: nil)
        let chiuso = t.testo(t.previdenza(nome: "Marco", oggi: 0, versamento: 5_000, coperturaOggi: 0, passo: pieno))
        verifica.vero("Simulatore: divario chiuso", chiuso.hasSuffix("arriva al 100%: il divario è chiuso."))
        var senzaDivario = i
        senzaDivario.pensionePubblica = 2_500
        let nessuno = MotoreSimulatoriAnalisi.previdenza(senzaDivario, versamento: 100, reddito: nil)
        verifica.vero("Simulatore: senza divario solo com'è oggi",
                      t.testo(t.previdenza(nome: "Marco", oggi: 0, versamento: 100, coperturaOggi: 1, passo: nessuno)).hasPrefix("Oggi Marco non ha divario"))

        // Protezione senza premio: niente «per circa … al mese»
        let p = MotoreSimulatoriAnalisi.PassoProtezione(aggiunta: 50_000, fabbisogno: 221_000, giaAssicurato: 150_000,
                                                        scoperto: 21_000, copertura: 200_000.0 / 221_000, premioAnnuo: nil)
        let frase = t.testo(t.protezione(p))
        verifica.vero("Simulatore protezione: premio mancante, nessuna cifra inventata",
                      !frase.contains("per circa") && frase.contains("Resterebbero scoperti"))
        verifica.vero("Simulatore protezione: com'è oggi", frase.hasPrefix("Oggi è protetto il 68% di quello che servirebbe"))

        // Rendimenti a ±0,5 punti, mai sotto 0
        verifica.vero("Simulatore: rendimenti attorno a quello dell'analisi",
                      MotoreSimulatoriAnalisi.rendimentiDaScegliere(1.5) == [1.0, 1.5, 2.0])
        verifica.vero("Simulatore: rendimento mai negativo",
                      MotoreSimulatoriAnalisi.rendimentiDaScegliere(0.3) == [0.0, 0.3, 0.8])
        verifica.vero("Simulatore: senza doppioni a zero", MotoreSimulatoriAnalisi.rendimentiDaScegliere(0) == [0.0, 0.5])

        // Aliquota scelta = IRPEF quando la deduzione resta tutta nello stesso scaglione: 200 € al mese (2.400 € l'anno)
        // su 40.000 € di reddito stanno tutti nel 33%
        var j = i
        j.versamentoMensile = 0
        let conReddito = MotoreSimulatoriAnalisi.previdenza(j, versamento: 200, reddito: 40_000)
        let conAliquota = MotoreSimulatoriAnalisi.previdenza(j, versamento: 200,
                                                             aliquota: RegoleFiscali.aliquotaMarginale(reddito: 40_000))
        verifica("Simulatore: risparmio con l'aliquota scelta come l'IRPEF", conAliquota.risparmioFiscale ?? -1,
                 conReddito.risparmioFiscale ?? -2)
        verifica("Simulatore: aliquota scelta, stesse cifre del resto", conAliquota.montante, conReddito.montante)
    }

    private static func previdenza(_ verifica: VerificaCalcoli) {
        var i = IpotesiPrevidenza()
        i.eta = 40; i.etaPensione = 67; i.redditoDesiderato = 2_200; i.pensionePubblica = 1_400
        i.capitale = 12_000; i.versamentoMensile = 150; i.rendimentoReale = 1.5; i.anniIntegrazione = 25
        let pieno = MotoreAnalisi.previdenza(i)
        let passo = MotoreSimulatoriAnalisi.previdenza(i, versamento: i.versamentoMensile, reddito: nil)
        verifica("Simulatore previdenza: montante come l'area", passo.montante, pieno.montante)
        verifica("Simulatore previdenza: rendita come l'area", passo.integrazione, pieno.integrazione)
        verifica("Simulatore previdenza: divario residuo come l'area", passo.divarioResiduo, pieno.divarioResiduo)
        verifica("Simulatore previdenza: copertura = rendita / divario", passo.copertura, pieno.integrazione / 800, tolleranza: 1e-9)
        verifica.vero("Simulatore previdenza: senza reddito niente risparmio fiscale", passo.risparmioFiscale == nil)
        // 500 € al mese = 6.000 € l'anno: si deducono 5.300 €; reddito 32.000 € → IRPEF(32.000) − IRPEF(26.700)
        let alto = MotoreSimulatoriAnalisi.previdenza(i, versamento: 500, reddito: 32_000)
        verifica("Simulatore previdenza: deduzione entro il limite", alto.deducibili, RegoleFiscali.limiteDeducibilita)
        verifica("Simulatore previdenza: IRPEF risparmiata per scaglioni", alto.risparmioFiscale ?? -1, 1_619)
        // Con il datore a 1.300 € l'anno restano 4.000 € deducibili per il cliente
        let datore = MotoreSimulatoriAnalisi.previdenza(i, versamento: 500, datore: 1_300, reddito: 32_000)
        verifica("Simulatore previdenza: il datore riduce il limite", datore.deducibili, 4_000)
        verifica.vero("Simulatore previdenza: più versamento, più rendita", alto.integrazione > passo.integrazione)
        // Senza divario la copertura è piena
        var senza = i
        senza.pensionePubblica = 2_500
        verifica("Simulatore previdenza: senza divario copertura piena",
                 MotoreSimulatoriAnalisi.previdenza(senza, versamento: 0, reddito: nil).copertura, 1)
    }

    private static func protezione(_ verifica: VerificaCalcoli) {
        let tcm1 = AiutiProva.posizione("TCM 1", .protezione, 0) {
            $0.rischio = .vita; $0.capitaleAssicurato = 150_000; $0.premio = 22; $0.frequenza = .mensile
        }
        let tcm2 = AiutiProva.posizione("TCM 2", .protezione, 0) {
            $0.rischio = .vita; $0.capitaleAssicurato = 300_000; $0.premio = 45; $0.frequenza = .mensile
        }
        let decrescente = AiutiProva.posizione("TCM mutuo", .protezione, 0) {
            $0.rischio = .vita; $0.capitaleAssicurato = 200_000; $0.premio = 300; $0.frequenza = .annuale
            $0.capitaleDecrescente = true
        }
        // Il cliente non ha coperture con premio: vale la media dell'archivio (la decrescente non conta)
        let t = MotoreSimulatoriAnalisi.tariffaCasoMorte(cliente: [], archivio: [tcm1, tcm2, decrescente])
        verifica("Simulatore protezione: tariffa dall'archivio", t?.perMille ?? -1, (264.0 + 540) / 450_000 * 1_000, tolleranza: 1e-9)
        verifica.vero("Simulatore protezione: fonte archivio", t?.fonte == .archivio && t?.coperture == 2)
        let propria = MotoreSimulatoriAnalisi.tariffaCasoMorte(cliente: [tcm1], archivio: [tcm1, tcm2])
        verifica.vero("Simulatore protezione: prima le coperture del cliente", propria?.fonte == .cliente && propria?.coperture == 1)
        verifica.vero("Simulatore protezione: senza coperture nessuna tariffa",
                      MotoreSimulatoriAnalisi.tariffaCasoMorte(cliente: [], archivio: [decrescente]) == nil)

        var i = IpotesiProtezione()
        i.fabbisognoMensile = 1_800; i.anniSostegno = 10; i.debiti = 0; i.speseImmediate = 15_000; i.capitaleDisponibile = 10_000
        let e = MotoreAnalisi.protezione(i, posizioni: [tcm1])
        // Fabbisogno 15.000 + 216.000 − 10.000 = 221.000; assicurati 150.000 + 50.000
        let p = MotoreSimulatoriAnalisi.protezione(e, aggiunta: 50_000, tariffa: t)
        verifica("Simulatore protezione: fabbisogno dal motore", p.fabbisogno, 221_000)
        verifica("Simulatore protezione: scoperto che resta", p.scoperto, 21_000)
        verifica("Simulatore protezione: copertura", p.copertura, 200_000.0 / 221_000, tolleranza: 1e-9)
        verifica("Simulatore protezione: premio stimato l'anno", p.premioAnnuo ?? -1, 50_000 * (804.0 / 450_000), tolleranza: 1e-6)
        verifica("Simulatore protezione: premio al mese", p.premioMensile ?? -1, 50_000 * (804.0 / 450_000) / 12, tolleranza: 1e-6)
        let oltre = MotoreSimulatoriAnalisi.protezione(e, aggiunta: 200_000, tariffa: nil)
        verifica.vero("Simulatore protezione: oltre il fabbisogno copertura piena e niente scoperto",
                      oltre.copertura == 1 && oltre.scoperto == 0 && oltre.premioAnnuo == nil)
    }
}
