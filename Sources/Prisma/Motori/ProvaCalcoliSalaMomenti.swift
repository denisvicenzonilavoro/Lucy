import Foundation

/// Migliorie d'uso 34 «Le esperienze della Sala, al momento giusto»: ogni esperienza ha un momento (e una durata, tranne
/// il Prisma del cliente), le etichette dicono «Per aprire · 2 min» e «Dopo l’incontro», le consigliate vengono dalle
/// priorità in ordine (al più due, il risparmio non ha un'esperienza sua, nessun consiglio senza priorità).
/// Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliSalaMomenti {
    static func esegui(_ verifica: VerificaCalcoli) {
        // Ogni esperienza ha un momento; ogni momento ha almeno un'esperienza
        let momenti = Set(EsperienzaSala.allCases.map(\.momento))
        verifica.vero("Sala momenti: ogni momento ha almeno un'esperienza", momenti.count == MomentoSala.allCases.count)
        verifica.vero("Sala momenti: tutte tranne il Prisma del cliente hanno una durata",
                      EsperienzaSala.allCases.allSatisfy { ($0.minuti != nil) == ($0 != .prismaCliente) })
        verifica.vero("Sala momenti: i titoli dei momenti del template",
                      MomentoSala.allCases.map(\.titolo) == ["Per aprire", "Per spiegare", "Per chiudere", "Dopo l’incontro"])
        verifica.vero("Sala momenti: «Per aprire · 2 min» sul prisma di luce",
                      TestiSala.momento(.prismaLuce) == "Per aprire · 2 min")
        verifica.vero("Sala momenti: «Dopo l’incontro» senza durata sul Prisma del cliente",
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
        verifica.vero("Sala consigliate: mai il Prisma del cliente né un'esperienza senza area",
                      EsperienzaSala.allCases.filter { $0.areaConsigliata != nil }.count == 3)
        verifica.vero("Sala consigliate: l'etichetta verde", TestiSala.consigliata("Giulia") == "Consigliata per Giulia")
    }
}
