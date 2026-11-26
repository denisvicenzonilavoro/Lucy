import Foundation

/// Migliorie d'uso 34 «Le esperienze della Sala, al momento giusto»: ogni esperienza ha un momento (e una durata, tranne
/// il Prisma del cliente), le etichette dicono «Per aprire · 2 min» e «Dopo l’incontro», le consigliate vengono dalle
/// priorità in ordine (al più due, il risparmio non ha un'esperienza sua, nessun consiglio senza priorità).
/// Dalla miglioria 59 anche i copioni «Cosa dire» delle esperienze, dalla 60 la prossima esperienza. Chiamata da
/// `ProvaCalcoli.esegui()`.
enum ProvaCalcoliSalaMomenti {
    static func esegui(_ verifica: VerificaCalcoli) {
        // Ogni esperienza ha un momento; ogni momento ha almeno un'esperienza
        let momenti = Set(EsperienzaSala.allCases.map(\.momento))
        verifica.vero("Sala momenti: ogni momento ha almeno un'esperienza", momenti.count == MomentoSala.allCases.count)
        verifica.vero("Sala momenti: tutte tranne la Lucy del cliente hanno una durata",
                      EsperienzaSala.allCases.allSatisfy { ($0.minuti != nil) == ($0 != .prismaCliente) })
        verifica.vero("Sala momenti: i titoli dei momenti del template",
                      MomentoSala.allCases.map(\.titolo) == ["Per aprire", "Per spiegare", "Per chiudere", "Dopo l’incontro"])
        verifica.vero("Sala momenti: «Per aprire · 2 min» sul sole del piano",
                      TestiSala.momento(.prismaLuce) == "Per aprire · 2 min")
        verifica.vero("Sala momenti: «Dopo l’incontro» senza durata sulla Lucy del cliente",
                      TestiSala.momento(.prismaCliente) == "Dopo l’incontro")
        verifica.vero("Sala momenti: Disegna il tuo futuro dura 5 minuti", TestiSala.momento(.disegna) == "Per aprire · 5 min")

        // Le consigliate: nell'ordine delle priorità, al più due, il risparmio saltato
        let tre = EsperienzaSala.consigliate(priorita: [.risparmio, .protezione, .previdenza])
        verifica.vero("Sala consigliate: il risparmio non ha un'esperienza, poi l'ordine delle priorità",
                      tre == [.lanciaAnno, .giornataPensione])
        let quattro = EsperienzaSala.consigliate(priorita: [.investimenti, .previdenza, .protezione])
        verifica.vero("Sala consigliate: al più due", quattro == [.giocoRischio, .giornataPensione])
        verifica.vero("Sala consigliate: senza priorità nessun consiglio", EsperienzaSala.consigliate(priorita: []).isEmpty)
        verifica.vero("Sala consigliate: solo il risparmio, nessun consiglio",
                      EsperienzaSala.consigliate(priorita: [.risparmio]).isEmpty)
        verifica.vero("Sala consigliate: mai la Lucy del cliente né un'esperienza senza area",
                      EsperienzaSala.allCases.filter { $0.areaConsigliata != nil }.count == 3)
        verifica.vero("Sala consigliate: l'etichetta verde", TestiSala.consigliata("Giulia") == "Consigliata per Giulia")

        // Migliorie d'uso 59: ogni esperienza ha il suo copione (apertura, tre passi, una domanda) e l'occhiello dice
        // «minuti», «minuto» al singolare e niente durata dove manca
        verifica.vero("Sala copione: ogni esperienza ha apertura, tre passi e una domanda",
                      EsperienzaSala.allCases.allSatisfy { e in
                          let c = e.copione
                          return !c.apertura.isEmpty && !c.domanda.isEmpty && c.passi.count == 3 && c.passi.allSatisfy { !$0.isEmpty }
                      })
        verifica.vero("Sala copione: «Cosa dire · per spiegare · 3 minuti» sulla giornata della pensione",
                      TestiCopione.titolo(.giornataPensione) == "Cosa dire · per spiegare · 3 minuti")
        verifica.vero("Sala copione: «1 minuto» al singolare sul film",
                      TestiCopione.titolo(.film) == "Cosa dire · dopo l’incontro · 1 minuto")
        verifica.vero("Sala copione: niente durata sulla Lucy del cliente",
                      TestiCopione.titolo(.prismaCliente) == "Cosa dire · dopo l’incontro")
        verifica.vero("Sala copione: il film dura venti secondi, non un minuto (decisione 59-a)",
                      EsperienzaSala.film.copione.apertura.contains("venti secondi"))
        verifica.vero("Sala copione: nessuna cifra nei copioni",
                      EsperienzaSala.allCases.allSatisfy { e in
                          let c = e.copione
                          return !(c.passi + [c.apertura, c.domanda]).joined().contains("€")
                      })

        // Migliorie d'uso 60: la prossima esperienza (`salaProssima` del template): il primo momento dopo con una libera,
        // dentro il momento la consigliata, poi lo stesso momento, mai i momenti prima
        verifica.vero("Sala prossima: dopo il gioco del rischio la prima «per chiudere»",
                      EsperienzaSala.prossima(dopo: .giocoRischio, fatte: [.giocoRischio], consigliate: []) == .lettera)
        verifica.vero("Sala prossima: dentro il momento vince la consigliata",
                      EsperienzaSala.prossima(dopo: .giocoRischio, fatte: [.giocoRischio], consigliate: [.capsula]) == .capsula)
        verifica.vero("Sala prossima: un momento senza esperienze libere si salta",
                      EsperienzaSala.prossima(dopo: .prismaLuce, fatte: [.prismaLuce, .giocoRischio, .giornataPensione, .lanciaAnno],
                                              consigliate: []) == .lettera)
        verifica.vero("Sala prossima: finiti i momenti dopo, lo stesso momento",
                      EsperienzaSala.prossima(dopo: .film, fatte: [.film], consigliate: []) == .prismaCliente)
        verifica.vero("Sala prossima: nel «Dopo l’incontro» il film viene prima della Lucy del cliente",
                      EsperienzaSala.prossima(dopo: .valoreConsulente, fatte: [.valoreConsulente, .lettera, .capsula],
                                              consigliate: []) == .film)
        verifica.vero("Sala prossima: i momenti prima non si propongono mai",
                      EsperienzaSala.prossima(dopo: .film, fatte: [.film, .prismaCliente], consigliate: [.giocoRischio]) == nil)
        verifica.vero("Sala prossima: nil quando non resta nulla",
                      EsperienzaSala.prossima(dopo: .capsula, fatte: [.capsula, .lettera, .valoreConsulente, .film, .prismaCliente],
                                              consigliate: []) == nil)
        verifica.vero("Sala prossima: l'ordine dei momenti copre tutte le esperienze una volta",
                      Set(EsperienzaSala.ordineMomenti) == Set(EsperienzaSala.allCases)
                          && EsperienzaSala.ordineMomenti.count == EsperienzaSala.allCases.count)
        verifica.vero("Sala fatte: i testi del template",
                      TestiEsperienzeFatte.occhiello(1, nome: "Giulia") == "Un’esperienza fatta oggi con Giulia"
                          && TestiEsperienzeFatte.occhiello(2, nome: "Giulia") == "2 esperienze fatte oggi con Giulia"
                          && TestiEsperienzeFatte.segnata(.giocoRischio, nome: "Marco").hasSuffix("resta scritta nel dossier di Marco, con la data di oggi"))
    }
}
