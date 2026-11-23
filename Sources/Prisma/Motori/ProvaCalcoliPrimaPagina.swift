import Foundation

/// Prova della Prima Pagina (NOVITÀ 1 dello stile Carta) dentro `Prisma --prova-calcoli`: le due edizioni (06:00 e 18:00),
/// il titolo (scadenze, poi incontri, poi la giornata libera), il numero del giornale, i limiti delle sezioni.
enum ProvaCalcoliPrimaPagina {
    static func esegui(_ verifica: VerificaCalcoli) {
        let cal = Calendar(identifier: .gregorian)
        func alle(_ g: Int, _ h: Int, _ m: Int = 0) -> Date {
            cal.date(from: DateComponents(year: 2026, month: 11, day: g, hour: h, minute: m)) ?? Date()
        }
        let mattina = alle(20, 7)
        verifica.vero("Prima Pagina: alle 7 è l'edizione del mattino", MotorePrimaPagina.edizione(mattina, calendario: cal) == .mattino)
        verifica.vero("Prima Pagina: alle 18 esce l'edizione della sera", MotorePrimaPagina.edizione(alle(20, 18), calendario: cal) == .sera)

        var i = IngressiPrimaPagina(data: mattina)
        i.incontri = [IncontroPrimaPagina(ora: alle(20, 11), chi: "Giorgio Ferri", cosa: "telefonata"),
                      IncontroPrimaPagina(ora: alle(20, 9, 30), chi: "Marco e Laura Bianchi", cosa: "revisione")]
        i.patrimonio = 412_380
        i.clienti = 5
        let solo = MotorePrimaPagina.componi(i, calendario: cal)
        verifica.vero("Prima Pagina: senza scadenze il titolo è il primo incontro",
                      solo.titolo == "Oggi due incontri: il primo alle 09:30 con Marco e Laura Bianchi")
        verifica.vero("Prima Pagina: gli incontri in ordine d'ora", solo.incontri.first?.chi == "Marco e Laura Bianchi")
        verifica("Prima Pagina: il numero del giornale è il giorno dell'anno", Double(solo.numero), 324)
        verifica.vero("Prima Pagina: il numero del giorno", solo.numeroDelGiorno == FormatoCifra.euro.testo(412_380)
                      && solo.didascaliaNumero == "seguiti per 5 clienti")

        i.scadenze = [ScadenzaPrimaPagina(cliente: "Ferri", posizione: "Polizza", data: alle(28, 12), valore: 20_000),
                      ScadenzaPrimaPagina(cliente: "Bianchi", posizione: "Polizza vita", data: alle(18 + 10, 12), valore: 90_000),
                      ScadenzaPrimaPagina(cliente: "Conti", posizione: "BTP", data: alle(30, 12), valore: 40_000),
                      ScadenzaPrimaPagina(cliente: "Lontano", posizione: "Fondo", data: cal.date(byAdding: .day, value: 200, to: mattina) ?? mattina,
                                          valore: 500_000)]
        let conScadenze = MotorePrimaPagina.componi(i, calendario: cal)
        verifica.vero("Prima Pagina: le scadenze vicine fanno il titolo, con la più importante",
                      conScadenze.titolo == "Tre posizioni scadono entro 45 giorni: la più importante è di Bianchi")
        verifica.vero("Prima Pagina: le scadenze lontane non contano", !conScadenze.scadenze.contains { $0.cliente == "Lontano" })

        var sera = IngressiPrimaPagina(data: alle(20, 19))
        sera.clienti = 1
        let vuota = MotorePrimaPagina.componi(sera, calendario: cal)
        verifica.vero("Prima Pagina: la sera senza incontri domani", vuota.titolo == "Domani nessun incontro: il momento giusto per chiamare chi aspetta"
                      && vuota.edizione == .sera && vuota.didascaliaNumero == "seguiti per 1 cliente")
        verifica.vero("Prima Pagina: niente mercati se l'utente non li ha accesi", vuota.mercati.isEmpty && vuota.notaVera == nil)
    }
}
