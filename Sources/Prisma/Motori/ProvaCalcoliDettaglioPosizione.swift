import Foundation

/// Migliorie d'uso 15 «La scheda di una posizione si legge dall'alto»: la frase non inventa cifre (senza versato è
/// corta, senza anni perde «in N anni», con una perdita dice «ne ha persi»), le cifre senza dato non ci sono, i campi
/// vuoti contano solo quelli pertinenti al tipo (un ETF senza numero né intestatario: 2, mai «Assicurato» o
/// «Beneficiari»), le schede solo con un contenuto e le ancore nella scheda giusta. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliDettaglioPosizione {
    static func esegui(_ verifica: VerificaCalcoli) {
        let cal = Calendar.current
        let oggi = cal.startOfDay(for: Date())
        let data = cal.date(from: DateComponents(year: 2026, month: 10, day: 31)) ?? oggi

        // Un ETF senza versato: la frase si accorcia, nessun guadagno inventato
        var etf = Posizione(clienteId: "prova", canale: .indipendente, stato: .inEssere, area: .investimento,
                            nome: "ETF azionario globale")
        etf.tipologia = "ETF"
        etf.controvalore = 18_400
        etf.dataValore = data
        let voceCorta = MotoreResoconto.voce(etf)
        let corta = TestiDettaglioPosizione.frase(etf, voce: voceCorta, nome: "Giulia", mesiSpese: nil)
        verifica.vero("Dettaglio 15: senza versato la frase è corta", corta == "Vale \(Formati.euro(18_400)) al 31 ottobre 2026.")
        verifica.vero("Dettaglio 15: senza versato nessun «guadagnati»", !corta.contains("guadagnati") && !corta.contains("versato"))
        let cifreCorte = TestiDettaglioPosizione.cifre(etf, voce: voceCorta, attesoNetto: nil, mesiSpese: nil, sogliaMesi: nil,
                                                       attivita: nil, debiti: nil, adeguatezza: nil)
        verifica.vero("Dettaglio 15: senza versato niente tessere «Versato» e «Guadagno»",
                      !cifreCorte.contains { $0.titolo == "Versato" || $0.titolo == "Guadagno" || $0.titolo == "Perdita" })
        verifica.vero("Dettaglio 15: senza rendimenti niente «Rende all'anno»", !cifreCorte.contains { $0.titolo == "Rende all'anno" })

        // Con versato e anni: la frase intera del template
        let intera = TestiDettaglioPosizione.fraseFinanziaria(nome: "Giulia", valore: 18_400, dataValore: data, versato: 15_000,
                                                              risultato: 3_400, anni: 4)
        verifica.vero("Dettaglio 15: la frase intera con versato, guadagno e anni",
                      intera == "Vale \(Formati.euro(18_400)): Giulia ha versato \(Formati.euro(15_000)) e ne ha guadagnati \(Formati.euro(3_400)) in 4 anni.")
        let persa = TestiDettaglioPosizione.fraseFinanziaria(nome: "Giulia", valore: 9_000, dataValore: nil, versato: 10_000,
                                                             risultato: -1_000, anni: nil)
        verifica.vero("Dettaglio 15: con una perdita «ne ha persi», senza anni niente «in N anni»",
                      persa == "Vale \(Formati.euro(9_000)): Giulia ha versato \(Formati.euro(10_000)) e ne ha persi \(Formati.euro(1_000)).")
        verifica.vero("Dettaglio 15: gli anni all'intero, sotto il mezzo anno nessuno",
                      TestiDettaglioPosizione.anniInteri(3.6) == 4 && TestiDettaglioPosizione.anniInteri(0.3) == nil
                        && TestiDettaglioPosizione.inAnni(1) == "in 1 anno")

        // Con il versato vero: le cifre del motore (guadagno verde, «+x% in tutto»)
        var conVersato = etf
        conVersato.totaleVersato = 15_000
        conVersato.decorrenza = cal.date(byAdding: .year, value: -4, to: data)
        let voce = MotoreResoconto.voce(conVersato)
        let cifre = TestiDettaglioPosizione.cifre(conVersato, voce: voce, attesoNetto: nil, mesiSpese: nil, sogliaMesi: nil,
                                                  attivita: nil, debiti: nil, adeguatezza: nil)
        let guadagno = cifre.first { $0.titolo == "Guadagno" }
        verifica.vero("Dettaglio 15: «Guadagno» è valore meno versato, in verde",
                      guadagno?.valore == CifreDoc.euroSegno(3_400) && guadagno?.tono == .verde)
        verifica.vero("Dettaglio 15: la frase usa le cifre del motore",
                      TestiDettaglioPosizione.frase(conVersato, voce: voce, nome: "Giulia", mesiSpese: nil)
                        == "Vale \(Formati.euro(18_400)): Giulia ha versato \(Formati.euro(15_000)) e ne ha guadagnati \(Formati.euro(3_400)) in 4 anni.")
        verifica.vero("Dettaglio 15: al più quattro cifre", cifre.count <= 4)

        // Campi vuoti: solo quelli pertinenti al tipo
        let vuotiETF = TestiDettaglioPosizione.campiVuoti(etf)
        verifica.vero("Dettaglio 15: un ETF senza numero né intestatario ha 2 dati da completare",
                      vuotiETF == ["Numero del deposito", "Intestatario"])
        verifica.vero("Dettaglio 15: un ETF non chiede mai assicurato o beneficiari",
                      !vuotiETF.contains("Assicurato") && !vuotiETF.contains("Beneficiari"))
        var polizza = Posizione(clienteId: "prova", canale: .alleanza, stato: .inEssere, area: .protezione, nome: "Temporanea caso morte")
        polizza.numeroContratto = "123"
        verifica.vero("Dettaglio 15: una polizza conta contraente, assicurato, beneficiari, decorrenza e scadenza",
                      TestiDettaglioPosizione.campiVuoti(polizza) == ["Contraente", "Assicurato", "Beneficiari", "Decorrenza", "Scadenza"])
        polizza.note = ""
        polizza.garanzie = ""
        verifica.vero("Dettaglio 15: note e garanzie vuote non contano",
                      !TestiDettaglioPosizione.campiVuoti(polizza).contains("Note") && !TestiDettaglioPosizione.campiVuoti(polizza).contains("Garanzie"))
        let conto = Posizione(clienteId: "prova", canale: .indipendente, stato: .inEssere, area: .liquidita, nome: "Conto corrente")
        verifica.vero("Dettaglio 15: un conto chiede solo l'intestatario", TestiDettaglioPosizione.campiVuoti(conto) == ["Intestatario"])
        // «Completa i dati» apre il modulo sul primo campo vuoto, con l'etichetta del modulo
        verifica.vero("Dettaglio 15: un ETF apre il modulo su «Numero di contratto»",
                      TestiDettaglioPosizione.primoCampoModulo(etf) == "Numero di contratto")
        verifica.vero("Dettaglio 15: la polizza col numero apre il modulo su «Contraente»",
                      TestiDettaglioPosizione.primoCampoModulo(polizza) == "Contraente")
        verifica.vero("Dettaglio 15: «Intestatario» è «Contraente» nel modulo",
                      TestiDettaglioPosizione.etichettaModulo("Intestatario") == "Contraente"
                        && TestiDettaglioPosizione.etichettaModulo("Decorrenza") == "Decorrenza")
        verifica.vero("Dettaglio 15: le righe del contratto sono solo quelle piene",
                      TestiDettaglioPosizione.righeContratto(polizza).allSatisfy { !$0.valore.isEmpty }
                        && TestiDettaglioPosizione.righeContratto(polizza).contains { $0.etichetta == "Numero" })

        // Le schede: un conto ha solo In breve e Contratto; le ancore vanno nella scheda giusta
        verifica.vero("Dettaglio 15: un conto ha solo In breve e Contratto",
                      SchedaPosizione.disponibili(conto, andamento: false, proiezione: false, riscatto: false, adeguatezza: false)
                        == [.inBreve, .contratto])
        verifica.vero("Dettaglio 15: una finanziaria ha In breve, Andamento, Costi e rischio, Contratto",
                      SchedaPosizione.disponibili(etf, andamento: true, proiezione: true, riscatto: false, adeguatezza: false)
                        == [.inBreve, .andamento, .costiRischio, .contratto])
        verifica.vero("Dettaglio 15: per una copertura la scheda dei costi si chiama «La copertura»",
                      SchedaPosizione.costiRischio.titolo(protezione: true) == "La copertura")
        verifica.vero("Dettaglio 15: le ancore aprono la loro scheda",
                      SchedaPosizione(ancora: "dettaglio-riferimento") == .andamento
                        && SchedaPosizione(ancora: "dettaglio-riscatto") == .costiRischio
                        && SchedaPosizione(ancora: "dettaglio-adeguatezza") == .adeguatezza
                        && SchedaPosizione(ancora: "coerenza") == nil)

        // La proposta: senza data di presentazione dice lo stato, con la data aspetta una risposta
        var proposta = Posizione(clienteId: "prova", canale: .alleanza, stato: .proposta, area: .previdenza, nome: "PIP")
        proposta.premio = 150
        proposta.frequenza = .mensile
        proposta.esito = .bozza
        verifica.vero("Dettaglio 15: proposta senza data «è bozza»",
                      TestiDettaglioPosizione.fraseProposta(proposta) == "Una proposta da \(Formati.euro(1_800)) l'anno: è bozza.")
        var seguito = SeguitoProposta()
        seguito.presentataIl = data
        proposta.seguito = seguito
        proposta.esito = .presentata
        verifica.vero("Dettaglio 15: proposta presentata «aspetta una risposta»",
                      TestiDettaglioPosizione.fraseProposta(proposta)
                        == "Una proposta da \(Formati.euro(1_800)) l'anno, presentata il 31 ottobre 2026: aspetta una risposta.")
        let adeguata = TestiDettaglioPosizione.cifre(proposta, voce: nil, attesoNetto: nil, mesiSpese: nil, sogliaMesi: nil,
                                                     attivita: nil, debiti: nil,
                                                     adeguatezza: AdeguatezzaInBreve(complessivo: .verde, inOrdine: 6, controlli: 6))
        verifica.vero("Dettaglio 15: la tessera dell'adeguatezza «Coerente · 6 controlli su 6»",
                      adeguata.contains { $0.titolo == "Adeguatezza" && $0.valore == "Coerente" && $0.nota == "6 controlli su 6" })
        verifica.vero("Dettaglio 15: «Scade tra 1 giorno», «Scade tra 12 giorni»",
                      TestiDettaglioPosizione.scadeTra(1) == "Scade tra 1 giorno" && TestiDettaglioPosizione.scadeTra(12) == "Scade tra 12 giorni")
    }
}
