import Foundation

/// Prove dello smontaggio (Design/template-luce-specifica.md §8.2.5.2, punto 7): le cinque righe del template, con valore
/// 90.000 e un versato di 78.000 dato dalla prova (il template non lo scrive), danno 1.890, 100, 1.950, 2.700 e la
/// performance «mancante» senza l'importo; senza versato i costi d'ingresso restano senza cifra; costo annuo 2.410 con
/// la performance scritta (420); voce più pesante 78%; diritti fissi a trimestre ×4; una riga senza numero non diventa
/// un costo. Il confronto passa da MotoreSostituzione. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliSmontaggio {
    static func esegui(_ verifica: VerificaCalcoli) {
        numeri(verifica)
        template(verifica)
        confronto(verifica)
        riapertura(verifica)
    }

    private static func righe(_ testi: [String]) -> [RigaLetta] { testi.map { RigaLetta(testo: $0) } }

    private static func numeri(_ verifica: VerificaCalcoli) {
        verifica("Smontaggio: numero all'italiana con la virgola", MotoreSmontaggio.numero("2,10") ?? -1, 2.1)
        verifica("Smontaggio: migliaia con il punto", MotoreSmontaggio.numero("90.000") ?? -1, 90_000)
        verifica("Smontaggio: migliaia e decimali", MotoreSmontaggio.numero("1.890,50") ?? -1, 1_890.5)
        verifica("Smontaggio: importo dopo il simbolo", MotoreSmontaggio.importi("Diritti fissi € 25 a trimestre").first ?? -1, 25)
        verifica("Smontaggio: anno della penale", Double(MotoreSmontaggio.anno("Penale 3% fino al 2027") ?? 0), 2027)
        verifica("Smontaggio: trimestre ×4", Double(MotoreSmontaggio.voltePerAnno("25 € a trimestre")), 4)
        verifica.vero("Smontaggio: una riga senza numero non diventa un costo",
                      MotoreSmontaggio.smonta(righe(["Commissione di gestione: vedi il prospetto"]), valore: 90_000).vuoto)
        verifica.vero("Smontaggio: una riga senza parole di costo non è un costo",
                      MotoreSmontaggio.smonta(righe(["Rendimento dell'anno 4,2%"]), valore: 90_000).vuoto)
    }

    private static func template(_ verifica: VerificaCalcoli) {
        let senzaImporto = TestiSmontaggio.righeFacSimile.map {
            $0.hasPrefix("Commissione di performance") ? "Commissione di performance 20% oltre l'indice" : $0
        }
        let s = MotoreSmontaggio.smonta(righe(senzaImporto), versato: 78_000)
        func euro(_ t: TipoCosto) -> Double { s.voci.first { $0.tipo == t }?.euro ?? -1 }
        verifica("Smontaggio: valore letto dal documento", s.valore ?? -1, 90_000)
        verifica("Smontaggio: versato letto dal documento", MotoreSmontaggio.smonta(righe(senzaImporto)).versato ?? -1, 78_000)
        verifica("Smontaggio: gestione 2,10% × 90.000", euro(.gestione), 1_890)
        verifica("Smontaggio: diritti fissi 25 € a trimestre", euro(.dirittiFissi), 100)
        verifica("Smontaggio: ingresso 2,50% × 78.000 versati", euro(.ingresso), 1_950)
        verifica("Smontaggio: penale 3% × 90.000 se esce ora", euro(.uscita), 2_700)
        verifica.vero("Smontaggio: performance senza importo segnata «mancante»",
                      s.voci.first { $0.tipo == .performance }?.fonte == .mancante && s.mancanti == [.performance])
        verifica.vero("Smontaggio: la gestione calcolata è una stima di Prisma",
                      s.voci.first { $0.tipo == .gestione }?.fonte == .calcolata)
        let senzaVersato = MotoreSmontaggio.smonta(righe(senzaImporto.filter { !$0.hasPrefix("Totale versato") }))
        verifica.vero("Smontaggio: senza versato i costi d'ingresso restano senza cifra",
                      senzaVersato.voci.first { $0.tipo == .ingresso }?.euro == nil)
        let conImporto = MotoreSmontaggio.smonta(righe(TestiSmontaggio.righeFacSimile), versato: 78_000)
        verifica("Smontaggio: costo annuo con la performance scritta", conImporto.costoAnnuo ?? -1, 2_410)
        verifica("Smontaggio: la performance usa l'importo scritto", conImporto.voci.first { $0.tipo == .performance }?.euro ?? -1, 420)
        verifica("Smontaggio: voce più pesante 78%", ((conImporto.piuPesante?.quota ?? 0) * 100).rounded(), 78)
        verifica("Smontaggio: costo annuo sul valore", (conImporto.quotaAnnua ?? 0) * 100, 2.678, tolleranza: 0.001)
        verifica.vero("Smontaggio: nota della voce più pesante",
                      conImporto.voci.first { $0.tipo == .gestione }.flatMap { TestiSmontaggio.nota($0, in: conImporto, nomeCliente: "Giulia") }
                        == "La voce più pesante: da sola fa il 78% dei costi.")
        verifica.vero("Smontaggio: la penale delle condizioni vince su quella scritta",
                      MotoreSmontaggio.smonta(righe(["Penale di rimborso 3% fino al 2027"]), valore: 90_000, penaleCondizioni: 1)
                        .voci.first?.euro == 900)
    }

    private static func confronto(_ verifica: VerificaCalcoli) {
        let s = MotoreSmontaggio.smonta(righe(TestiSmontaggio.righeFacSimile), versato: 78_000)
        guard let attuale = MotoreSmontaggio.posizioneProvvisoria(s, da: nil, clienteId: "prova", nome: "Fondo Esempio Globale") else {
            verifica.vero("Smontaggio: posizione provvisoria dai dati letti", false)
            return
        }
        verifica("Smontaggio: posizione provvisoria con il valore letto", attuale.valore, 90_000)
        verifica("Smontaggio: costo annuo della provvisoria in %", attuale.costoAnnuo ?? -1, 2_410.0 / 90_000 * 100, tolleranza: 1e-6)
        var proposta = AiutiProva.posizione("Proposta", .investimento, 90_000)
        proposta.stato = .proposta
        proposta.versamentoIniziale = 90_000
        proposta.costoAnnuo = 760.0 / 90_000 * 100
        let e = MotoreSmontaggio.confronto(s, attuale: attuale, proposta: proposta, prodotti: [])
        verifica("Smontaggio: confronto su dieci anni", Double(e.anni), Double(IpotesiCalcolo.orizzontePredefinito))
        verifica.vero("Smontaggio: con costi più bassi la proposta rende di più a dieci anni", (e.finale?.differenza ?? 0) > 0)
        verifica.vero("Smontaggio: il confronto conta la penale d'uscita", e.penaleUscita > 0)
    }

    /// Migliorie d'uso 42: la numerazione segue l'ordine delle voci sul documento; un documento conservato si riapre
    /// dalle sue voci, anche senza il testo in memoria, con le stesse cifre di quando è stato aggiunto (compresa la
    /// gestione calcolata dalla percentuale); i documenti smontati per cliente e per tutti.
    private static func riapertura(_ verifica: VerificaCalcoli) {
        let s = MotoreSmontaggio.smonta(righe(TestiSmontaggio.righeFacSimile), versato: 78_000)
        let righeVoci = s.voci.map(\.riga)
        verifica.vero("Smontaggio 42: numeri nell'ordine delle voci sul documento", righeVoci == righeVoci.sorted() && Set(righeVoci).count == righeVoci.count)
        let foglio = MotoreSmontaggio.righe(da: Array(s.voci.reversed()), titolo: "Fondo Esempio Globale")
        verifica("Smontaggio 42: foglio ricostruito, testata e una riga per voce", Double(foglio.count), Double(s.voci.count + 2))
        verifica.vero("Smontaggio 42: le righe ricostruite nell'ordine del documento",
                      foglio.count > 2 && foglio[1].testo == "Fondo Esempio Globale" && foglio[2].testo.hasPrefix("Commissione di gestione"))
        let riaperte = MotoreSmontaggio.vociRiaperte(s.voci)
        verifica.vero("Smontaggio 42: voci riaperte sulle righe del foglio, stesse cifre",
                      riaperte.map(\.riga) == Array(2..<(2 + s.voci.count)) && riaperte.map(\.euro) == s.voci.map(\.euro))
        verifica.vero("Smontaggio 42: ogni voce riaperta trova la sua riga",
                      riaperte.allSatisfy { v in foglio[v.riga].testo.hasPrefix(v.etichetta) })
        verifica("Smontaggio 42: valore usato da Prisma ricavato dalla gestione calcolata", MotoreSmontaggio.valoreDaVoci(s.voci) ?? -1, 90_000)
        verifica("Smontaggio 42: versato ricavato dai costi d'ingresso calcolati", MotoreSmontaggio.versatoDaVoci(s.voci) ?? -1, 78_000)
        verifica("Smontaggio 42: anno del documento", Double(MotoreSmontaggio.annoDocumento(righe(TestiSmontaggio.righeFacSimile)) ?? 0), 2025)
        verifica.vero("Smontaggio 42: cifra della voce senza euro «—»",
                      s.voci.first { $0.fonte == .mancante }.map { TestiSmontaggio.cifraVoce($0, anno: 2025) == "—" } ?? true)
        verifica.vero("Smontaggio 42: testi della card", TestiSmontaggio.occhielloDocumento(nome: "Giulia", valore: nil) == "Documento di Giulia"
                      && TestiSmontaggio.occhielloDocumento(nome: nil, valore: 90_000) == TestiSmontaggio.daAssegnare
                      && TestiSmontaggio.vuotoCliente("Marco") == "Nessun documento smontato per Marco.")

        #if os(macOS)
        let stato = StatoShell(persistente: false)
        guard let c = stato.dati.clienti.first, let altro = stato.dati.clienti.dropFirst().first else {
            verifica.vero("Smontaggio 42: dati di prova con due clienti", false)
            return
        }
        // Il documento com'era al momento dell'aggiunta (senza testo in memoria: come dopo un riavvio)
        let conImporto = MotoreSmontaggio.smonta(righe(TestiSmontaggio.righeFacSimile))
        var doc = Documento(clienteId: c.id, titolo: "Fondo Esempio Globale", tipo: .estrattoConto)
        doc.id = "doc-prova-42-smontaggio"
        doc.costiTrovati = conImporto.voci
        var secondo = Documento(clienteId: altro.id, titolo: "Rendiconto di prova", tipo: .estrattoConto)
        secondo.id = "doc-prova-42-altro"
        secondo.costiTrovati = [conImporto.voci[0]]
        stato.dati.documenti.removeAll { !($0.costiTrovati ?? []).isEmpty }
        stato.dati.documenti.append(doc)
        stato.dati.documenti.append(secondo)
        verifica.vero("Smontaggio 42: documenti smontati del cliente", stato.documentiSmontati(clienteId: c.id).map(\.id) == [doc.id])
        verifica("Smontaggio 42: documenti smontati di tutti", Double(stato.documentiSmontati(clienteId: nil).count), 2)
        let senzaTesto = stato.riapriSmontaggio(doc)
        verifica.vero("Smontaggio 42: senza testo il foglio si ricostruisce dalle voci", senzaTesto.ricostruito
                      && senzaTesto.righe.count == conImporto.voci.count + 2)
        verifica("Smontaggio 42: riaperto senza testo, stesso costo annuo", senzaTesto.costi.costoAnnuo ?? -1, conImporto.costoAnnuo ?? -2)
        verifica("Smontaggio 42: riaperto senza testo, la gestione calcolata resta 1.890",
                 senzaTesto.costi.voci.first { $0.tipo == .gestione }?.euro ?? -1, 1_890)
        verifica.vero("Smontaggio 42: riaperto senza testo, stesse cifre voce per voce",
                      senzaTesto.costi.voci.map(\.euro) == conImporto.voci.map(\.euro)
                      && senzaTesto.costi.voci.map(\.fonte) == conImporto.voci.map(\.fonte))
        verifica("Smontaggio 42: riaperto senza testo, il valore di Prisma", senzaTesto.costi.valore ?? -1, 90_000)
        stato.memorizzaTesto(doc.id, [TestiSmontaggio.righeFacSimile.joined(separator: "\n")])
        let conTesto = stato.riapriSmontaggio(doc)
        verifica.vero("Smontaggio 42: con il testo in memoria il foglio è quello vero, le voci quelle conservate",
                      !conTesto.ricostruito && conTesto.righe.count == TestiSmontaggio.righeFacSimile.count && conTesto.costi.voci == conImporto.voci)
        verifica("Smontaggio 42: con il testo, valore letto dal documento", conTesto.costi.valore ?? -1, 90_000)
        #endif
    }
}
