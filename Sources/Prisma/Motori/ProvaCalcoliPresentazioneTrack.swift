import CoreGraphics
import Foundation

/// Prove di ciò che Studio › Track record mostra (`PresentazioneTrackRecord`, chiamate da `ProvaCalcoli.esegui()`, cioè da
/// `Prisma --prova-calcoli`): la scala comune delle due linee, l'ordine dell'elenco, la pillola «Rimandata» e le linee
/// di un'accettata. Casi costruiti a mano; l'indice «indice-prova» è un RIFERIMENTO DI PROVA scritto qui.
enum ProvaCalcoliPresentazioneTrack {
    static func esegui(_ verifica: VerificaCalcoli) {
        func d(_ a: Int, _ m: Int, _ g: Int) -> Date { AiutiProva.data(a, m, g) }

        // 1. Normalizzazione: scala comune, punti tra 0 e 1, x in proporzione alle date
        let date = [d(2024, 1, 1), d(2025, 1, 1), d(2026, 1, 1)]
        let n = PresentazioneTrackRecord.normalizza([100, 110, 120], [100, 105, 108], date: date)
        let tutti = n.a + n.b
        verifica.vero("Track record (vista): punti tra 0 e 1", tutti.allSatisfy { $0.x >= 0 && $0.x <= 1 && $0.y >= 0 && $0.y <= 1 })
        verifica.vero("Track record (vista): stessa scala per le due linee", n.a[0].y == n.b[0].y && n.a[2].y > n.b[2].y)
        verifica("Track record (vista): x in proporzione alle date", Double(n.a[1].x), 366.0 / 731.0, tolleranza: 1e-6)
        verifica.vero("Track record (vista): margine sopra e sotto", n.a[2].y < 1 && n.a[0].y > 0)
        let costante = PresentazioneTrackRecord.normalizza([50, 50], [], date: [d(2025, 1, 1), d(2026, 1, 1)])
        verifica.vero("Track record (vista): serie costante a metà altezza",
                      costante.a.count == 2 && costante.a.allSatisfy { abs($0.y - 0.5) < 1e-9 } && costante.b.isEmpty)
        let senza = PresentazioneTrackRecord.normalizza([1, 2, 3], [], date: [])
        verifica.vero("Track record (vista): senza date x equidistanti", senza.a.map { $0.x } == [0, 0.5, 1])
        verifica.vero("Track record (vista): nessun valore, nessun punto",
                      PresentazioneTrackRecord.normalizza([], [], date: []).a.isEmpty)

        // 2. Ordine: accettate per differenza decrescente, poi da misurare, in attesa, rifiutate; a parità la più recente
        func racc(_ id: String, _ data: Date, _ scelta: SceltaCliente) -> Raccomandazione {
            var r = Raccomandazione(id: id, data: data, clienteId: "anna", posizioneId: "p-\(id)", canale: .indipendente,
                                    area: .investimento, proposta: "Proposta \(id)", motivazione: "",
                                    cifre: CifreRaccomandazione(), alternativa: .nessuna)
            r.registraScelta(scelta, il: data)
            return r
        }
        func scarto(_ x: Double) -> TrackRecord.Misura {
            .scarto(TrackRecord.Scarto(differenza: x, valoreEffettivo: 10_000 + x, valoreAlternativa: 10_000,
                                       tassoEffettivo: nil, tassoAlternativa: nil, puntiAnnui: nil, anniStimati: [], stima: true))
        }
        func voce(_ r: Raccomandazione, _ m: TrackRecord.Misura, posizione: Posizione? = nil) -> TrackRecord.Voce {
            TrackRecord.Voce(raccomandazione: r, posizione: posizione, daAlmeno12Mesi: false, inEssere: true, misura: m)
        }
        let voci = [
            voce(racc("rifiutata", d(2026, 5, 1), .rifiutata), .nonAccettata),
            voce(racc("piccola", d(2025, 1, 1), .accettata), scarto(200)),
            voce(racc("attesa", d(2026, 6, 1), .inAttesa), .nonAccettata),
            voce(racc("da-misurare", d(2026, 2, 1), .accettata), .pochiDati),
            voce(racc("grande", d(2024, 1, 1), .accettata), scarto(4_000)),
            voce(racc("negativa", d(2025, 3, 1), .accettata), scarto(-1_200)),
        ]
        let ordine = PresentazioneTrackRecord.ordinate(voci).map { $0.id }
        verifica.vero("Track record (vista): ordine dell'elenco",
                      ordine == ["grande", "piccola", "negativa", "da-misurare", "attesa", "rifiutata"])

        // 3. Pillola: «in attesa» con la proposta rimandata diventa «Rimandata», con la data in cui riprenderla
        var rimandata = Posizione(clienteId: "anna", canale: .alleanza, stato: .proposta, area: .previdenza, nome: "Rendita")
        rimandata.esito = .rimandata
        var seguito = SeguitoProposta()
        seguito.riprendereIl = d(2027, 1, 15)
        rimandata.seguito = seguito
        let vRimandata = voce(racc("rim", d(2026, 6, 1), .inAttesa), .nonAccettata, posizione: rimandata)
        verifica.vero("Track record (vista): rimandata con la data", PresentazioneTrackRecord.esito(vRimandata) == .rimandata(riprendereIl: d(2027, 1, 15)))
        verifica.vero("Track record (vista): in attesa senza proposta rimandata", PresentazioneTrackRecord.esito(voci[2]) == .inAttesa)

        // 4. Copertura accettata: il capitale assicurato al posto della differenza
        var copertura = Posizione(clienteId: "anna", canale: .alleanza, stato: .inEssere, area: .protezione, nome: "Temporanea")
        copertura.capitaleAssicurato = 200_000
        let rCopertura = Raccomandazione(id: "cop", data: d(2025, 1, 1), clienteId: "anna", posizioneId: copertura.id,
                                         canale: .alleanza, area: .protezione, proposta: "Temporanea", motivazione: "",
                                         cifre: CifreRaccomandazione(), alternativa: .nessuna)
        var accettataCopertura = rCopertura
        accettataCopertura.registraScelta(.accettata, il: d(2025, 1, 10))
        verifica("Track record (vista): capitale assicurato della copertura",
                 PresentazioneTrackRecord.capitaleAssicurato(voce(accettataCopertura, .senzaRiferimento, posizione: copertura)) ?? -1, 200_000)
        verifica.vero("Track record (vista): una copertura non accettata non mostra il capitale",
                      PresentazioneTrackRecord.capitaleAssicurato(voce(rCopertura, .nonAccettata, posizione: copertura)) == nil)

        // 5. Le linee di un'accettata: valori rilevati e alternativa al ritmo dell'indice di prova (+1% l'anno)
        let indice = "indice-prova"
        var riferimenti = RiferimentiRendimento()
        riferimenti.indici = [IndiceRiferimento(id: indice, nome: "Indice di prova")]
        riferimenti.valori = [2024, 2025, 2026].map { ValoreRiferimento(serie: indice, anno: $0, valore: 1.0) }
        let tabella = TabellaRiferimenti(riferimenti)
        let p = AiutiProva.posizione("ETF", .investimento, 10_800) { q in
            q.id = "p-linee"
            q.decorrenza = d(2024, 1, 1)
            q.dataValore = d(2026, 1, 1)
            q.totaleVersato = 10_000
            q.rilevazioni = [Rilevazione(data: d(2024, 1, 1), controvalore: 10_000, versato: 10_000),
                             Rilevazione(data: d(2025, 1, 1), controvalore: 10_300, versato: 10_000)]
        }
        let alternativa = AlternativaRaccomandazione(tipo: .riferimento, descrizione: "Lo stesso capitale al ritmo dell'indice di prova",
                                                     serieRiferimento: indice, ricavata: false)
        var rLinee = Raccomandazione(id: "linee", data: d(2023, 12, 15), clienteId: "anna", posizioneId: p.id, canale: .indipendente,
                                     area: .investimento, proposta: "ETF", motivazione: "", cifre: CifreRaccomandazione(),
                                     alternativa: alternativa)
        rLinee.registraScelta(.accettata, il: d(2024, 1, 1))
        if let l = PresentazioneTrackRecord.linee(voce(rLinee, .pochiDati, posizione: p), tabella: tabella) {
            verifica.vero("Track record (vista): tre punti per linea", l.proposta.count == 3 && l.alternativa.count == 3)
            verifica.vero("Track record (vista): le linee partono insieme e la proposta finisce sopra",
                          l.proposta[0] == l.alternativa[0] && l.proposta[2].y > l.alternativa[2].y)
        } else {
            verifica.vero("Track record (vista): linee di un'accettata", false)
        }
        verifica.vero("Track record (vista): una rifiutata non ha linee",
                      PresentazioneTrackRecord.linee(voce(racc("no", d(2025, 1, 1), .rifiutata), .nonAccettata, posizione: p),
                                                     tabella: tabella) == nil)

        miglioria54(verifica)
    }

    // MARK: - Migliorie d'uso 54: il track record segue il cliente

    private static func miglioria54(_ verifica: VerificaCalcoli) {
        func d(_ a: Int, _ m: Int, _ g: Int) -> Date { AiutiProva.data(a, m, g) }
        func racc(_ id: String, cliente: String, _ scelta: SceltaCliente) -> Raccomandazione {
            var r = Raccomandazione(id: id, data: d(2026, 1, 1), clienteId: cliente, posizioneId: "p-\(id)",
                                    canale: .indipendente, area: .investimento, proposta: "Proposta \(id)", motivazione: "",
                                    cifre: CifreRaccomandazione(), alternativa: .nessuna)
            r.registraScelta(scelta, il: d(2026, 1, 1))
            return r
        }
        func scarto(_ x: Double) -> TrackRecord.Misura {
            .scarto(TrackRecord.Scarto(differenza: x, valoreEffettivo: 10_000 + x, valoreAlternativa: 10_000,
                                       tassoEffettivo: nil, tassoAlternativa: nil, puntiAnnui: nil, anniStimati: [], stima: true))
        }
        func voce(_ r: Raccomandazione, _ m: TrackRecord.Misura, posizione: Posizione? = nil) -> TrackRecord.Voce {
            TrackRecord.Voce(raccomandazione: r, posizione: posizione, daAlmeno12Mesi: false, inEssere: true, misura: m)
        }
        var rimandata = Posizione(clienteId: "anna", canale: .alleanza, stato: .proposta, area: .previdenza, nome: "Rendita")
        rimandata.esito = .rimandata
        let voci = [
            voce(racc("a1", cliente: "anna", .accettata), scarto(1_500)),
            voce(racc("a2", cliente: "anna", .accettata), scarto(-400)),
            voce(racc("a3", cliente: "anna", .accettata), .pochiDati),
            voce(racc("r1", cliente: "anna", .rifiutata), .nonAccettata),
            voce(racc("m1", cliente: "anna", .inAttesa), .nonAccettata, posizione: rimandata),
            voce(racc("w1", cliente: "anna", .inAttesa), .nonAccettata),
            voce(racc("b1", cliente: "bruno", .accettata), scarto(9_000)),
        ]
        let anna = PresentazioneTrackRecord.perCliente(voci: voci, clienteId: "anna")
        verifica.vero("Track record 54: conteggi del cliente",
                      anna.raccomandazioni == 6 && anna.accettate == 3 && anna.rimandateORifiutate == 2 && anna.inAttesa == 1
                        && anna.misurate == 2 && anna.voci.allSatisfy { $0.raccomandazione.clienteId == "anna" })
        verifica("Track record 54: somma degli scarti con una misurata negativa", anna.differenzaTotale ?? -1, 1_100)
        verifica.vero("Track record 54: voci del cliente nell'ordine dell'elenco",
                      anna.voci.map(\.id) == PresentazioneTrackRecord.ordinate(Array(voci.prefix(6))).map(\.id))
        let soloDaMisurare = PresentazioneTrackRecord.perCliente(voci: [voci[2], voci[3]], clienteId: "anna")
        verifica.vero("Track record 54: nessuna misurata, nessuna somma", soloDaMisurare.differenzaTotale == nil)
        verifica.vero("Track record 54: cliente senza raccomandazioni",
                      PresentazioneTrackRecord.perCliente(voci: voci, clienteId: "carla").raccomandazioni == 0)
        let filtra = { (f: FiltroTrackRecord) in PresentazioneTrackRecord.filtra(voci, esito: f).map(\.id) }
        verifica.vero("Track record 54: filtro «Tutte»", filtra(.tutte).count == voci.count)
        verifica.vero("Track record 54: filtro «Accettate»", filtra(.accettate) == ["a1", "a2", "a3", "b1"])
        verifica.vero("Track record 54: filtro «Rimandate»", filtra(.rimandate) == ["m1"])
        verifica.vero("Track record 54: filtro «Rifiutate» (le in attesa solo in «Tutte»)", filtra(.rifiutate) == ["r1"])
        verifica.vero("Track record 54: «Riproponi» solo per le rimandate con la proposta",
                      PresentazioneTrackRecord.riproponibile(voci[4]) && !PresentazioneTrackRecord.riproponibile(voci[5])
                        && !PresentazioneTrackRecord.riproponibile(voci[3]))
        #if os(macOS)
        riproponi(verifica)
        #endif
    }

    #if os(macOS)
    /// «Riproponi» nello stato: la proposta torna bozza, la ripresa si chiude, la nota si aggiunge, le scelte restano.
    private static func riproponi(_ verifica: VerificaCalcoli) {
        let stato = StatoShell(persistente: false)
        let oggi = AiutiProva.data(2026, 11, 15)
        var p = Posizione(clienteId: "anna", canale: .alleanza, stato: .proposta, area: .previdenza, nome: "Rendita")
        p.id = "p-prova-54"
        p.esito = .rimandata
        var seguito = SeguitoProposta()
        seguito.presentataIl = AiutiProva.data(2026, 6, 1)
        seguito.esitoIl = AiutiProva.data(2026, 7, 1)
        seguito.riprendereIl = AiutiProva.data(2027, 1, 15)
        seguito.attivitaId = "task-prova-54"
        p.seguito = seguito
        let ripresa = Attivita(id: "task-prova-54", clienteId: "anna", titolo: "Riprendere la proposta",
                               scadenza: AiutiProva.data(2027, 1, 15), priorita: .normale, completata: false)
        var r = Raccomandazione(id: "racc-prova-54", data: AiutiProva.data(2026, 6, 1), clienteId: "anna", posizioneId: p.id,
                                canale: .alleanza, area: .previdenza, proposta: "Rendita integrativa", motivazione: "",
                                cifre: CifreRaccomandazione(), alternativa: .nessuna)
        r.registraScelta(.inAttesa, il: AiutiProva.data(2026, 6, 1))
        // Una rifiutata: «Riproponi» non fa nulla
        var rifiutata = Posizione(clienteId: "anna", canale: .alleanza, stato: .proposta, area: .protezione, nome: "Temporanea")
        rifiutata.id = "p-prova-54-no"
        rifiutata.esito = .rifiutata
        var rNo = Raccomandazione(id: "racc-prova-54-no", data: AiutiProva.data(2026, 6, 1), clienteId: "anna",
                                  posizioneId: rifiutata.id, canale: .alleanza, area: .protezione, proposta: "Temporanea",
                                  motivazione: "", cifre: CifreRaccomandazione(), alternativa: .nessuna)
        rNo.registraScelta(.rifiutata, il: AiutiProva.data(2026, 7, 1))
        // Una senza posizione
        let rSenza = Raccomandazione(id: "racc-prova-54-senza", data: AiutiProva.data(2026, 6, 1), clienteId: "anna",
                                     posizioneId: "p-che-non-c-e", canale: .alleanza, area: .previdenza, proposta: "Altro",
                                     motivazione: "", cifre: CifreRaccomandazione(), alternativa: .nessuna)
        stato.dati.posizioni += [p, rifiutata]
        stato.dati.attivita.append(ripresa)
        stato.dati.raccomandazioni += [r, rNo, rSenza]

        verifica.vero("Track record 54: «Riproponi» non fa nulla su una rifiutata",
                      !stato.riproponiRaccomandazione(rNo.id, il: oggi)
                        && stato.dati.posizioni.first { $0.id == rifiutata.id }?.esito == .rifiutata)
        verifica.vero("Track record 54: «Riproponi» non fa nulla senza posizione",
                      !stato.riproponiRaccomandazione(rSenza.id, il: oggi))
        let fatto = stato.riproponiRaccomandazione(r.id, il: oggi)
        let dopo = stato.dati.posizioni.first { $0.id == p.id }
        let rDopo = stato.dati.raccomandazioni.first { $0.id == r.id }
        verifica.vero("Track record 54: la proposta torna bozza senza la data della ripresa",
                      fatto && dopo?.esito == .bozza && dopo?.seguito?.riprendereIl == nil && dopo?.seguito?.presentataIl != nil)
        verifica.vero("Track record 54: l'attività di ripresa è completata",
                      stato.dati.attivita.first { $0.id == ripresa.id }?.completata == true)
        verifica.vero("Track record 54: nota datata aggiunta, scelte invariate",
                      rDopo?.note.last?.testo == TestiTrackRecord.notaRiproposta(oggi) && rDopo?.note.last?.data == oggi
                        && rDopo?.scelte == r.scelte && rDopo?.scelta == .inAttesa)
        verifica.vero("Track record 54: «Riproponi» una seconda volta non fa nulla",
                      !stato.riproponiRaccomandazione(r.id, il: oggi))
        if let dopo, let rDopo {
            let v = TrackRecord.Voce(raccomandazione: rDopo, posizione: dopo, daAlmeno12Mesi: false, inEssere: false,
                                     misura: .nonAccettata)
            verifica.vero("Track record 54: dopo «Riproponi» la voce è «in attesa» e tra le proposte",
                          PresentazioneTrackRecord.esito(v) == .inAttesa && PresentazioneTrackRecord.traLeProposte(v)
                            && PresentazioneTrackRecord.filtra([v], esito: .rimandate).isEmpty)
            // Ripresentarla non crea una seconda raccomandazione e non ripete «in attesa»
            var ripresentata = dopo
            ripresentata.esito = .presentata
            if let i = stato.dati.posizioni.firstIndex(where: { $0.id == p.id }) { stato.dati.posizioni[i] = ripresentata }
            stato.registraRaccomandazioneSeServe(prima: dopo, dopo: ripresentata, adesso: oggi)
            let perPosizione = stato.dati.raccomandazioni.filter { $0.posizioneId == p.id }
            verifica.vero("Track record 54: ripresentata, nessuna raccomandazione nuova",
                          perPosizione.count == 1 && perPosizione.first?.scelte == r.scelte)
        }

        // In sola lettura nulla cambia
        let lettura = StatoShell(persistente: false)
        var p2 = p
        p2.id = "p-prova-54-lettura"
        var r2 = Raccomandazione(id: "racc-prova-54-lettura", data: AiutiProva.data(2026, 6, 1), clienteId: "anna",
                                 posizioneId: p2.id, canale: .alleanza, area: .previdenza, proposta: "Rendita", motivazione: "",
                                 cifre: CifreRaccomandazione(), alternativa: .nessuna)
        r2.registraScelta(.inAttesa, il: AiutiProva.data(2026, 6, 1))
        lettura.dati.posizioni.append(p2)
        lettura.dati.raccomandazioni.append(r2)
        lettura.segnaSolaLetturaPerIstantanea()
        verifica.vero("Track record 54: in sola lettura «Riproponi» non fa nulla",
                      !lettura.riproponiRaccomandazione(r2.id, il: oggi)
                        && lettura.dati.posizioni.first { $0.id == p2.id }?.esito == .rimandata
                        && lettura.dati.raccomandazioni.first { $0.id == r2.id }?.note.isEmpty == true)
    }
    #endif
}
