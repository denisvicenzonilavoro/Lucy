#if os(macOS)
import Foundation
import CoreGraphics

/// Le istantanee della Biblioteca · «Trova la pagina» (Design/template-luce-specifica.md §8.1.7, «Luce» giro 6), nello
/// stato finale (contatore sulla pagina, foglio fermo, evidenziatore pieno, risposta completa):
/// - 870: i sei fac-simile, nessuna domanda, chiaro e scuro;
/// - 871: la domanda sul riscatto, risposta completa, pagina 14 con la frase evidenziata, documento acceso, chiaro e scuro;
/// - 872: archivio senza documenti, la zona di rilascio, chiaro e scuro;
/// - 873: tre documenti in lettura con l'avanzamento;
/// - 874: risposta non trovata con le pagine più vicine;
/// - 875: Vera non pronta, la pagina con i passi trovati evidenziati;
/// - 876: «Mostra al cliente», la pagina a tutto schermo con la frase;
/// - 877: la finestra alla larghezza minima (1100);
/// - 878 (§8.1.6 punto 3): la risposta dal piano rivalutabile con una seconda edizione più vecchia dello stesso prodotto,
///   «C'è anche un'edizione più vecchia», chiaro e scuro; la scheda del prodotto collegato con «Condizioni nella
///   Biblioteca» (§8.1.5.2 punto 6), chiaro e scuro;
/// - 879 (§8.1.5.2 punto 6): «Cerca ovunque» (⌘K) con il gruppo «Biblioteca», chiaro e scuro; Vera che propone «Cerca
///   nella Biblioteca» sotto una risposta su condizioni, chiaro e scuro;
/// - 1120-1122 (migliorie d'uso 35): Giulia scelta con un documento dei suoi prodotti, la colonna in due gruppi (chiaro e
///   scuro); il piano rivalutabile aperto con le sue domande e il campo «Chiedi qualcosa su …»; il KID aperto, «Chiedi tu».
/// - 1400-1402 (migliorie d'uso 63): il catalogo «Prodotti» senza cliente (la scheda con «È per / Non è per»), una
///   scheda di protezione, e Andrea (prudente) con l'ETF che rischia più del suo profilo, ultimo nell'elenco.
/// 870-878 scelgono «Tutti i clienti» in modo esplicito: restano come prima.
/// DATI DI PROVA DICHIARATI: i documenti sono i sei fac-simile scritti per Prisma (Risorse/Biblioteca); le risposte di
/// Vera sono JSON di prova passati dalla stessa verifica di Prisma che vale per Qwen.
extension Istantanee {
    nonisolated static var sceneBiblioteca: [(nome: String, prepara: (StatoShell) -> Void)] {
        var scene: [(nome: String, prepara: (StatoShell) -> Void)] = []
        func una(_ nome: String, _ prepara: @escaping (StatoShell) -> Void) {
            scene.append((nome: nome, prepara: prepara))
        }
        func coppia(_ nome: String, _ prepara: @escaping (StatoShell) -> Void) {
            una(nome, prepara)
            una(nome + "-scuro", prepara)
        }
        coppia("870-biblioteca") { s in
            s.scegliCliente(nil)
            s.caricaEsempiBiblioteca()
            s.apri(.biblioteca)
        }
        coppia("871-biblioteca-risposta") { s in preparaRispostaBiblioteca(s) }
        coppia("872-biblioteca-vuota") { s in s.apri(.biblioteca) }
        una("873-biblioteca-lettura") { s in
            s.scegliCliente(nil)
            s.caricaEsempiBiblioteca()
            s.trovaPagina.mostraLetture([
                LetturaBiblioteca(id: "l1", nome: "Set informativo · Piano di risparmio (prova)", lette: 12, totale: 38),
                LetturaBiblioteca(id: "l2", nome: "KID · Fondo obbligazionario (prova)", lette: 1, totale: 3),
                LetturaBiblioteca(id: "l3", nome: "Circolare interna (prova)", lette: 5, totale: 20),
            ])
            s.apri(.biblioteca)
        }
        una("874-biblioteca-non-trovata") { s in
            s.scegliCliente(nil)
            s.caricaEsempiBiblioteca()
            let domanda = "Il riscatto del fondo pensione si può chiedere online?"
            s.trovaPagina.domanda = domanda
            s.chiediBiblioteca(domanda, subito: true)
            s.applicaEsitoBiblioteca(.nonTrovata)
            s.apri(.biblioteca)
        }
        una("875-biblioteca-senza-ruby") { s in
            s.scegliCliente(nil)
            s.caricaEsempiBiblioteca()
            let domanda = "Se Marco non paga la temporanea?"
            s.trovaPagina.domanda = domanda
            s.chiediBiblioteca(domanda, subito: true)
            s.senzaVeraBiblioteca()
            s.apri(.biblioteca)
        }
        una("876-biblioteca-cliente") { s in
            preparaRispostaBiblioteca(s)
            s.mostraBibliotecaAlCliente()
        }
        una("877-biblioteca-stretta") { s in
            preparaRispostaBiblioteca(s)
            s.alternaIngrandimento(.biblioteca)
            s.ridimensiona(.biblioteca, dimensione: CGSize(width: 1100, height: 760))
        }
        coppia("878-biblioteca-edizioni") { s in
            preparaRispostaBiblioteca(s)
            _ = edizionePrecedenteDiProva(s)
            s.apri(.biblioteca)
        }
        coppia("878-biblioteca-prodotto") { s in
            s.caricaEsempiBiblioteca()
            if let prodotto = edizionePrecedenteDiProva(s) {
                s.filtroCanaleProdotti = nil
                s.filtroAreaProdotti = nil
                s.prodottoSelezionato = prodotto
            }
            s.apri(.prodotti)
        }
        // Migliorie d'uso 63 «I prodotti parlano chiaro»: il catalogo nella Biblioteca
        coppia("1400-uso-biblioteca-prodotti") { s in
            s.scegliCliente(nil)
            s.filtroCanaleProdotti = nil
            s.filtroAreaProdotti = nil
            s.prodottoSelezionato = "prodotto-risparmio-rivalutabile"
            s.apri(.prodotti)
        }
        coppia("1401-uso-biblioteca-prodotto-protezione") { s in
            s.scegliCliente(nil)
            s.filtroCanaleProdotti = nil
            s.filtroAreaProdotti = nil
            s.prodottoSelezionato = "prodotto-tcm"
            s.apri(.prodotti)
        }
        coppia("1402-uso-biblioteca-prodotto-oltre-profilo") { s in
            // Andrea è prudente (SRI fino a 2): l'ETF (SRI 4) rischia più del suo profilo ed è in fondo all'elenco
            s.scegliCliente("andrea")
            s.filtroCanaleProdotti = nil
            s.filtroAreaProdotti = nil
            s.prodottoSelezionato = "prodotto-etf-globale"
            s.apri(.prodotti)
        }
        coppia("879-biblioteca-cerca-ovunque") { s in
            s.caricaEsempiBiblioteca()
            s.testoRicerca = "riscatto penali"
            s.cercaOvunque()
        }
        coppia("879-biblioteca-da-vera") { s in
            s.caricaEsempiBiblioteca()
            s.rispostePreparate = true
            s.disponibilitaLocale = .pronto
            s.clienteAttivoId = "marco"
            s.veraPortafoglio = false
            s.aggiungiMessaggio(MessaggioVera(autore: .utente, testo: "Il riscatto nei primi anni ha penali?"), cliente: "marco", parla: false)
            s.aggiungiMessaggio(MessaggioVera(autore: .vera, testo: "Nelle posizioni di Marco non c'è scritto: le penali le dicono le condizioni del prodotto. (Risposta di prova.)"),
                                cliente: "marco", parla: false)
            s.apri(.vera)
        }
        // Migliorie d'uso 35 (Design/uso/gruppo-05.md §35.5): Giulia scelta, il fac-simile del fondo pensione collegato a
        // mano al suo piano previdenziale (come in 878): la colonna in due gruppi, la domanda su Marco nascosta
        coppia("1120-uso-biblioteca-cliente-documenti") { s in
            preparaClienteBiblioteca(s)
            s.apri(.biblioteca)
        }
        una("1121-uso-biblioteca-documento-aperto") { s in
            preparaClienteBiblioteca(s)
            if let d = s.biblioteca.tutti.first(where: { $0.titolo.hasPrefix("Piano rivalutabile") }) {
                s.apriDocumentoBiblioteca(d.id)
            }
            s.apri(.biblioteca)
        }
        una("1122-uso-biblioteca-documento-senza-domande") { s in
            preparaClienteBiblioteca(s)
            if let d = s.biblioteca.tutti.first(where: { $0.titolo.hasPrefix("Fondo azionario") }) {
                s.apriDocumentoBiblioteca(d.id)
            }
            s.apri(.biblioteca)
        }
        return scene
    }

    /// DATI DI PROVA DICHIARATI (migliorie d'uso 35): Giulia scelta nella barra e il fac-simile «Fondo pensione aperto»
    /// collegato al piano previdenziale integrativo di prova (la sua proposta presentata).
    nonisolated static func preparaClienteBiblioteca(_ s: StatoShell) {
        s.caricaEsempiBiblioteca()
        s.scegliCliente("giulia")
        if let d = s.biblioteca.tutti.first(where: { $0.titolo.hasPrefix("Fondo pensione aperto") }) {
            s.collegaProdottoBiblioteca(d.id, prodotto: "prodotto-previdenza-pip")
        }
    }

    /// DATI DI PROVA DICHIARATI: una seconda edizione (06/2024, stesso testo del fac-simile) del piano rivalutabile, e
    /// tutte e due collegate al primo prodotto Alleanza dei dati di prova. Restituisce l'id del prodotto.
    nonisolated static func edizionePrecedenteDiProva(_ s: StatoShell) -> String? {
        guard let prodotto = (s.dati.prodotti.first { $0.canale == .alleanza } ?? s.dati.prodotti.first)?.id,
              let attuale = s.biblioteca.tutti.first(where: { $0.titolo.hasPrefix("Piano rivalutabile") }),
              let pagine = EsempiBiblioteca.pagine("piano-rivalutabile") else { return nil }
        let scelto = s.biblioteca.scelto
        let d = s.biblioteca.aggiungi(titolo: "Piano rivalutabile · Condizioni (edizione precedente)", sigla: "",
                                      edizione: "fac-simile, ed. 06/2024", file: "esempio", pagine: [])
        s.biblioteca.aggiorna(d.id) { x in
            x.file = "\(d.id).txt"
            x.testo = "\(d.id).txt"
            x.genere = .condizioni
            x.canale = .alleanza
            x.confermato = true
            x.pagine = pagine.count
            x.pagineOCR = 0
            x.diProva = true
            x.prodottoId = prodotto
        }
        s.trovaPagina.salvaTesto(d.id, pagine)
        s.collegaProdottoBiblioteca(attuale.id, prodotto: prodotto)
        s.biblioteca.scelto = scelto
        return prodotto
    }

    /// La domanda sul riscatto con la risposta di prova di Vera, verificata come quella di Qwen.
    nonisolated static func preparaRispostaBiblioteca(_ s: StatoShell) {
        // Con «Tutti i clienti», come prima delle migliorie d'uso 35 (le tre domande del template)
        s.scegliCliente(nil)
        s.caricaEsempiBiblioteca()
        let domanda = "Il riscatto nei primi anni ha penali?"
        s.trovaPagina.domanda = domanda
        s.chiediBiblioteca(domanda, subito: true)
        let passi = TrovaPaginaVera.passi(s.trovaPagina.risultato?.trovati ?? [], documenti: s.biblioteca.tutti)
        let json = #"{"trovato":true,"passo":"P1","frase":"Fino al quinto anno di contratto si applica una penale dell'1% per ogni anno che manca al quinto.","risposta":"Sì. Dopo il primo anno si può riscattare, ma fino al quinto anno si paga una penale dell'1% per ogni anno che manca al quinto. Dal quinto anno in poi il riscatto non ha penali."}"#
        if let esito = TrovaPaginaVera.leggi(json, passi: passi, domanda: domanda) { s.applicaEsitoBiblioteca(esito) }
        s.apri(.biblioteca)
    }
}
#endif
