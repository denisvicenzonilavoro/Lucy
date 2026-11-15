#if os(macOS)
import SwiftUI

// Migliorie d'uso 69 «Il TFR: prima la risposta» (Design/uso/gruppo-12.md §69, template righe 5100-5147).
// Sul Mac il TFR è la terza voce del segmentato di «Simula e confronta». A sinistra tre cursori soli (retribuzione,
// anni alla pensione, quanto rende il fondo) e tutti gli altri comandi di oggi sotto «Altre ipotesi ⌄»; a destra prima
// la frase, poi le strade, da dove viene la differenza, cosa cambia per il cliente e la fila; il resto nel «Dettaglio».
// Chi non lavora da dipendente lo legge subito, con la strada per il conto della pensione.
// È la stessa `SchedaTFR` di iPhone e iPad: stessa bozza, stesso salvataggio dopo la pausa, stesse cifre di `MotoreTFR`
// (qui solo l'ordine, le parole e quante cose sono in vista).

private typealias SC = Tema.Apple.SimulaConfronta
private typealias TT = Tema.Apple.SimulaConfronta.TFR

extension SchedaTFR {
    /// Il nome breve del cliente nelle frasi («Marco»).
    var nomeTFR: String {
        stato.cliente(cliente).map { StatoShell.nomeBreve($0) } ?? "il cliente"
    }

    func corpoMac(_ i: IpotesiTFR, _ e: EsitoTFR?) -> some View {
        let senza = confrontaComunque ? nil : stato.senzaTFR(cliente)
        return ColonneAffiancate(larghezza: SC.larghezzaColonna) {
            consoleMac(i, e, senza: senza)
        } flessibile: {
            risultatiMac(i, e, senza: senza)
        }
    }

    // MARK: - La colonna di sinistra

    func consoleMac(_ i: IpotesiTFR, _ e: EsitoTFR?, senza: TipoLavoratore?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SC.spazioBlocchi) {
                SegmentatoModoSimula()
                occhielloMac(TestiTFR.lavoroDi(nomeTFR))
                    .padding(.top, SC.spazioOcchiello)
                if let tipo = senza {
                    lavoroNonDipendente(tipo)
                } else {
                    avvisoDaVerificare(e)
                    comandiPrincipali(i)
                    pulsanteAltreIpotesi
                    if stato.altreIpotesiTFR {
                        altreIpotesiMac(i, e)
                    }
                    Rectangle().fill(SC.filo).frame(height: Tema.Misura.filo)
                    Text(TestiTFR.rigaIpotesi(i))
                        .carattereApple(SC.rigaIpotesi)
                        .foregroundColor(SC.coloreRigaIpotesi)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(SC.paddingColonna)
        }
    }

    func occhielloMac(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(SC.occhiello)
            .foregroundColor(SC.coloreOcchiello)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Il dossier dice che non lavora da dipendente: lo si legge qui, e si corregge in Anagrafica.
    @ViewBuilder
    func lavoroNonDipendente(_ tipo: TipoLavoratore) -> some View {
        Text(TestiTFR.lavoroNonDipendente(professione: stato.cliente(cliente)?.professione ?? "", tipo: tipo))
            .carattereApple(TT.corpo)
            .foregroundColor(TT.coloreCorpo)
            .fixedSize(horizontal: false, vertical: true)
        Rectangle().fill(SC.filo).frame(height: Tema.Misura.filo)
        Text(TestiTFR.soloDipendenti)
            .carattereApple(SC.rigaIpotesi)
            .foregroundColor(SC.coloreRigaIpotesi)
            .fixedSize(horizontal: false, vertical: true)
        if !stato.inModoCliente {
            Button(TestiTFR.apriAnagrafica) {
                stato.schedaCliente = .anagrafica
                stato.apri(.clienti)
            }
            .buttonStyle(.appleSobrio)
        }
    }

    /// Gli avvisi delle ipotesi: il fondo che riceve già il TFR e quelli del motore (decisione 69-e). Il primo qui, con
    /// la pillola «Da verificare»; gli altri nel «Dettaglio».
    func avvisiTFR(_ e: EsitoTFR?) -> [String] {
        var a: [String] = []
        if let p = stato.fondoConTFR(cliente), let tfr = p.tfrConferito {
            a.append("Il TFR va già in «\(p.nome)»: \(Formati.euro(tfr)) l'anno. La scelta non si revoca: il confronto mostra cosa è cambiato rispetto a lasciarlo in azienda.")
        }
        if let e { a += TestiTFR(e, cliente: stato.cliente(cliente)).avvisi }
        return a
    }

    @ViewBuilder
    func avvisoDaVerificare(_ e: EsitoTFR?) -> some View {
        if let primo = avvisiTFR(e).first {
            VStack(alignment: .leading, spacing: TT.spazioInterno) {
                Pillola(testo: TestiTFR.daVerificare, tono: .attenzione)
                Text(primo)
                    .carattereApple(TT.nota)
                    .foregroundColor(TT.coloreCorpo)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// I tre cursori in vista (decisione 69-a: le parole del template, la definizione esatta nell'aiuto), con sotto i
    /// primi due le note dei ripieghi di sempre.
    @ViewBuilder
    func comandiPrincipali(_ i: IpotesiTFR) -> some View {
        let b = legame
        let rip = stato.ripieghiTFR(cliente)
        let partenza = self.partenza
        ComandoSimulatoreFermo(etichetta: TestiTFR.etichettaRetribuzione, valore: b.retribuzione, unita: "€",
                               intervallo: Console.retribuzione, passo: Console.passoRetribuzione,
                               fineCursore: Console.fineRetribuzione)
            .equatable()
            .help(TestiTFR.aiutoRetribuzione)
        notaComando(rip.retribuzione && i.retribuzione == partenza.retribuzione ? "Stimata: manca il reddito da lavoro" : nil)
        ComandoSimulatoreFermo(etichetta: TestiTFR.etichettaAnni, valore: intero(b.anni, Console.anni),
                               unita: "anni", intervallo: Console.anni, passo: 1)
            .equatable()
            .help(TestiTFR.aiutoAnni)
        notaComando(notaAnniMac(i, rip: rip, partenza: partenza))
        ComandoSimulatoreFermo(etichetta: TestiTFR.etichettaRendimento(netto: i.rendimentoNetto), valore: b.rendimentoFondo,
                               unita: "%", intervallo: Console.rendimento, passo: Console.passo, decimali: 1)
            .equatable()
            .help(TestiTFR.aiutoRendimento)
    }

    func notaAnniMac(_ i: IpotesiTFR, rip: IpotesiTFR.Ripieghi, partenza: IpotesiTFR) -> String? {
        guard i.anni == partenza.anni else { return nil }
        if rip.eta { return "Stimati: manca la data di nascita (\(RegoleTFR.etaPredefinita) anni)" }
        if rip.etaPensione { return "Stimati: pensione a \(RegoleTFR.etaPensionePredefinita) anni" }
        return nil
    }

    /// «Altre ipotesi ⌄»: la freccia si gira (ferma con «Riduci movimento»).
    var pulsanteAltreIpotesi: some View {
        let s = stato
        let aperte = s.altreIpotesiTFR
        return Button {
            withAnimation(Movimenti.calmo ? nil : Tema.Moto.passaggio) { s.altreIpotesiTFR.toggle() }
        } label: {
            HStack(spacing: TT.spazioInterno) {
                Text(TestiTFR.altreIpotesi)
                Image(systemName: "chevron.down")
                    .carattereApple(TT.frecciaAltre)
                    .rotationEffect(.degrees(aperte ? TT.rotazioneAperta : 0))
            }
        }
        .buttonStyle(.appleSobrio)
    }

    /// Tutti gli altri comandi di oggi, nei tre gruppi di sempre (decisione 69-b: nulla sparisce, ma non sta in vista).
    func altreIpotesiMac(_ i: IpotesiTFR, _ e: EsitoTFR?) -> some View {
        let b = legame
        return VStack(alignment: .leading, spacing: M.spazioConsole) {
            gruppo("Lavoratore") {
                Group {
                    ComandoSimulatoreFermo(etichetta: "Crescita oltre l'inflazione", valore: b.crescitaReale, unita: "%",
                                           intervallo: Console.crescita, passo: Console.passo, decimali: 1)
                        .equatable()
                    ComandoSimulatoreFermo(etichetta: "Inflazione ipotizzata", valore: b.inflazione, unita: "%",
                                           intervallo: Console.inflazione, passo: Console.passo, decimali: 1,
                                           fineCursore: Console.fineInflazione)
                        .equatable()
                    ComandoSimulatoreFermo(etichetta: "Anni già fatti con questo datore",
                                           valore: interoFacoltativo(b.anniServizio, Console.servizio),
                                           unita: "anni", intervallo: Console.servizio, passo: 1)
                        .equatable()
                    ComandoSimulatoreFermo(etichetta: "TFR già maturato in azienda",
                                           valore: facoltativo(b.tfrMaturato, Console.maturato), unita: "€",
                                           intervallo: Console.maturato, passo: M.passoMaturato, fineCursore: M.fineMaturato)
                        .equatable()
                    notaComando(e?.maturatoStimato == true
                                ? "Stimato dagli anni: \(Formati.euro(e?.tfrMaturato ?? 0)). Conta solo per l'aliquota" : nil)
                }
                Group {
                    scelta("Dipendenti dell'azienda") {
                        SegmentiAnalisiFermi(opzioni: [(false, "Meno di \(RegoleTFR.dipendentiTesoreria)"),
                                                       (true, "\(RegoleTFR.dipendentiTesoreria) o più")],
                                             selezione: vero(b.aziendaGrande))
                            .equatable()
                    }
                    scelta("Iscritto all'INPS prima del 29/4/1993") {
                        SegmentiAnalisiFermi(opzioni: [(false, "No"), (true, "Sì")], selezione: vero(b.vecchioIscritto))
                            .equatable()
                    }
                    if i.vecchioIscritto == true {
                        ComandoSimulatoreFermo(etichetta: "TFR conferito al fondo",
                                               valore: Binding(get: { b.wrappedValue.quotaConferitaEffettiva },
                                                               set: { b.wrappedValue.quotaConferita = $0 }),
                                               unita: "%", intervallo: Console.conferita, passo: M.passoConferita)
                            .equatable()
                    }
                    ComandoSimulatoreFermo(etichetta: "Quota di TFR sulla retribuzione",
                                           valore: Binding(get: { b.wrappedValue.quotaTFR ?? RegoleTFR.quotaAnnua },
                                                           set: { v in
                                                               b.wrappedValue.quotaTFR = abs(v - RegoleTFR.quotaAnnua) < M.passoQuota / 2 ? nil : v
                                                           }),
                                           unita: "%", intervallo: Console.quota, passo: M.passoQuota, decimali: 2)
                        .equatable()
                }
            }
            filo
            gruppo("Fondo") {
                Group {
                    scelta("Rendimento del fondo") {
                        SegmentiAnalisiFermi(opzioni: [(true, "Netto (COVIP)"), (false, "Lordo")], selezione: baseNetta(b))
                            .equatable()
                    }
                    notaComando(i.rendimentoNetto
                                ? "Già tolti costi e imposta, come nei dati COVIP e nelle schede"
                                : "Prisma toglie costi (ISC) e imposta sui rendimenti")
                    if !i.rendimentoNetto {
                        ComandoSimulatoreFermo(etichetta: "Costi del fondo (ISC)", valore: b.costoFondo, unita: "%",
                                               intervallo: Console.costo, passo: Console.passoCosto, decimali: 2)
                            .equatable()
                        ComandoSimulatoreFermo(etichetta: "Parte in titoli di Stato",
                                               valore: facoltativo(b.titoliStatoFondo, Console.titoliStato), unita: "%",
                                               intervallo: Console.titoliStato, passo: 1)
                            .equatable()
                    }
                }
                Group {
                    ComandoSimulatoreFermo(etichetta: "Contributo del cliente", valore: b.contributoLavoratore, unita: "%",
                                           intervallo: Console.contributo, passo: Console.passo, decimali: 1)
                        .equatable()
                    ComandoSimulatoreFermo(etichetta: "Contributo del datore", valore: b.contributoDatore, unita: "%",
                                           intervallo: Console.contributo, passo: Console.passo, decimali: 1)
                        .equatable()
                    notaComando(i.contributoDatore > 0 && i.contributoLavoratore <= 0
                                ? "Di solito il datore versa solo se versa anche il cliente" : nil, avviso: true)
                    ComandoSimulatoreFermo(etichetta: "Anni già nella previdenza", valore: intero(b.anniPartecipazione, Console.partecipazione),
                                           unita: "anni", intervallo: Console.partecipazione, passo: 1)
                        .equatable()
                }
            }
            filo
            gruppo("Fisco") {
                scelta("Aliquota del TFR in azienda") {
                    SegmentiAnalisiFermi(opzioni: [(false, "Calcolata"), (true, "La indico io")], selezione: aliquotaAMano(b))
                        .equatable()
                }
                if i.aliquotaTFR != nil {
                    ComandoSimulatoreFermo(etichetta: "Aliquota della tassazione separata",
                                           valore: Binding(get: { b.wrappedValue.aliquotaTFR ?? 0 },
                                                           set: { b.wrappedValue.aliquotaTFR = min(max($0, Console.aliquota.lowerBound), Console.aliquota.upperBound) }),
                                           unita: "%", intervallo: Console.aliquota, passo: Console.passo, decimali: 1)
                        .equatable()
                }
                if i.contributoLavoratore > 0 {
                    scelta("Costo dei contributi valutato al") {
                        SegmentiAnalisiFermi(opzioni: [(false, "Inflazione"), (true, "Un tasso mio")], selezione: tassoAMano(b))
                            .equatable()
                    }
                    if i.tassoAlternativo != nil {
                        ComandoSimulatoreFermo(etichetta: "Rendimento netto alternativo",
                                               valore: Binding(get: { b.wrappedValue.tassoAlternativo ?? 0 },
                                                               set: { b.wrappedValue.tassoAlternativo = $0 }),
                                               unita: "%", intervallo: Console.tasso, passo: Console.passo, decimali: 1)
                            .equatable()
                    }
                }
            }
            Button {
                bozza = nil
                clienteBozza = nil
                stato.ripartiTFR(cliente)
            } label: {
                Label("Riparti dai dati del cliente", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.appleSobrio)
            .help("Toglie tutte le ipotesi salvate: retribuzione, anni, contributi, fondo, canale e aliquota ripartono dal dossier")
        }
        .padding(.top, SC.spazioOcchiello)
    }

    // MARK: - La colonna di destra

    func risultatiMac(_ i: IpotesiTFR, _ e: EsitoTFR?, senza: TipoLavoratore?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TT.spazioBlocchi) {
                if let tipo = senza {
                    senzaTFRMac(tipo)
                } else if let e {
                    fraseMac(i, e)
                    StradeRispostaTFR(e: e)
                    perche(e)
                    cosaCambia
                    filaMac(e)
                    dettaglioMac(e)
                } else {
                    Text(TestiTFR.indicaRetribuzione)
                        .carattereApple(TT.corpo)
                        .foregroundColor(TT.coloreNota)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SC.paddingColonna)
        }
    }

    /// La frase in testa (la cifra in verde), la riga sotto e il canale, che si cambia toccando l'etichetta.
    func fraseMac(_ i: IpotesiTFR, _ e: EsitoTFR) -> some View {
        let nome = nomeTFR
        let b = legame
        return VStack(alignment: .leading, spacing: TT.spazioInterno) {
            HStack(alignment: .firstTextBaseline, spacing: SC.spazioStrada) {
                occhielloMac(TestiTFR.occhielloRisposta(nome))
                Spacer(minLength: SC.spazioStrada)
                // Canale sempre riconoscibile
                Button {
                    b.wrappedValue.canale = i.canale == .alleanza ? .indipendente : .alleanza
                } label: {
                    EtichettaCanale(canale: i.canale, compatta: true)
                }
                .buttonStyle(.plain)
                .help("Canale della consulenza: tocca per passare ad Alleanza o a indipendente")
            }
            TestiTFR.fraseRispostaParti(e, nome: nome)
                .reduce(Text("")) { t, p in t + testoParte(p) }
                .carattereApple(TT.frase)
                .foregroundColor(TT.coloreCorpo)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(TestiTFR.fraseRisposta(e, nome: nome))
            Text(CifreDoc.unisciAlSegno(TestiTFR.sottoRisposta(e, nome: nome)))
                .carattereApple(TT.corpo)
                .foregroundColor(TT.coloreCorpo)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TT.paddingFrase)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(SC.superficie)
    }

    /// Un pezzo della frase: la cifra della prima soglia in verde.
    func testoParte(_ p: TestiTFR.ParteFrase) -> Text {
        let t = Text(CifreDoc.unisciAlSegno(p.testo))
        return p.evidenza ? t.foregroundColor(A.positivo) : t
    }

    /// Da dove viene la differenza: le tasse, il contributo dell'azienda, il rendimento che serve.
    func perche(_ e: EsitoTFR) -> some View {
        let aliquote = Text(CifreDoc.percento(e.azienda.aliquota, decimali: 1)).foregroundColor(TT.primaAliquota)
            + Text(" → ").foregroundColor(TT.primaAliquota)
            + Text(CifreDoc.percento(e.fondo.aliquota, decimali: 1)).foregroundColor(TT.dopoAliquota)
        return HStack(alignment: .top, spacing: TT.spazioBlocchi) {
            TesseraRispostaTFR(titolo: TestiTFR.titoloTasse, valore: aliquote, testo: TestiTFR.testoTasse)
            TesseraRispostaTFR(titolo: TestiTFR.titoloContributoAzienda,
                               valore: Text(CifreDoc.unisciAlSegno(TestiTFR.valoreContributoAzienda(e))),
                               testo: TestiTFR.testoContributoAzienda(e, nome: nomeTFR))
            TesseraRispostaTFR(titolo: TestiTFR.titoloRendimento, valore: Text(TestiTFR.valoreRendimento(e)),
                               testo: TestiTFR.testoRendimento(e))
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// «Cosa cambia per <nome>»: due regole, con il pallino.
    var cosaCambia: some View {
        VStack(alignment: .leading, spacing: TT.spazioInterno) {
            occhielloMac(TestiTFR.titoloCosaCambia(nomeTFR))
            ForEach(TestiTFR.cosaCambia, id: \.self) { riga in
                HStack(alignment: .top, spacing: TT.spazioPallino) {
                    Circle()
                        .fill(TT.colorePallino)
                        .frame(width: TT.pallino, height: TT.pallino)
                        .padding(.top, TT.altezzaPallino)
                    Text(riga)
                        .carattereApple(TT.rigaCambia)
                        .foregroundColor(TT.coloreCorpo)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(TT.paddingCambia)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(SC.superficie)
    }

    /// La fila: il prospetto (o il report) mostrato al cliente, «Chiedi a Vera», le uscite del PDF in «Altro ⌄».
    func filaMac(_ e: EsitoTFR) -> some View {
        let nome = nomeTFR
        let s = stato
        return HStack(spacing: SC.spazioStrada) {
            Button(TestiTFR.prospettoPer(nome)) {
                if let d = documento() { s.presenta(d) }
            }
            .buttonStyle(.applePrimario)
            .fixedSize()
            .help("Mostra il documento a tutto schermo, una pagina alla volta, in modalità cliente")
            Button(TestiTFR.chiediVera) {
                s.chiediVeraTFR(TestiTFR.domandaVera(e, nome: nome))
            }
            .buttonStyle(.apple)
            .fixedSize()
            .disabled(s.veraInCorso)
            menuAltroMac
            Spacer(minLength: SC.spazioStrada)
            Text(TestiTFR.nonPromesse)
                .carattereApple(SC.notaFila)
                .foregroundColor(SC.coloreNotaFila)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
    }

    /// «Altro ⌄»: prospetto per te o report per il cliente, e le uscite di sempre (presenta, salva, stampa, archivia).
    var menuAltroMac: some View {
        let s = stato
        return Menu {
            Picker(selection: $report) {
                Text("Prospetto per te").tag(false)
                Text("Report per il cliente").tag(true)
            } label: {
                Text("Documento")
            }
            .pickerStyle(.inline)
            Divider()
            Button {
                if let d = documento(), let dati = pdf(d) {
                    daSalvare = PDFDaSalvare(dati: dati, nome: StampaCarta.nomeFile(d), cliente: s.clienteAttivo)
                }
            } label: {
                Label("Salva PDF…", systemImage: "square.and.arrow.down")
            }
            Button {
                if let d = documento(), let dati = pdf(d) { StampaCarta.stampa(dati, formato: d.formato) }
            } label: {
                Label("Stampa…", systemImage: "printer")
            }
            Button {
                if let d = documento(), let dati = pdf(d) { archiviato = s.archiviaProspetto(dati, documento: d) }
            } label: {
                Label("Archivia nei Documenti", systemImage: "archivebox")
            }
            if let id = archiviato {
                Button {
                    s.documentoSelezionato = id
                    s.apri(.documenti)
                } label: {
                    Label("Apri in Documenti", systemImage: "arrow.up.right")
                }
            }
        } label: {
            HStack(spacing: TT.spazioInterno) {
                Text(TestiTFR.altro)
                Image(systemName: "chevron.down")
                    .carattereApple(TT.frecciaAltre)
            }
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
        .buttonStyle(.apple)
        .fixedSize()
    }

    /// «Dettaglio ⌄» (chiuso di base): gli altri avvisi, le semplificazioni, il grafico, il perché, la tabella anno per
    /// anno e il metodo.
    func dettaglioMac(_ e: EsitoTFR) -> some View {
        let testi = TestiTFR(e, cliente: stato.cliente(cliente))
        return VStack(alignment: .leading, spacing: M.spazioRisultati) {
            Button {
                withAnimation(Movimenti.calmo ? nil : Tema.Moto.passaggio) { mostraDettaglio.toggle() }
            } label: {
                HStack(spacing: TT.spazioInterno) {
                    Text(TestiTFR.dettaglio)
                    Image(systemName: "chevron.down")
                        .carattereApple(TT.frecciaAltre)
                        .rotationEffect(.degrees(mostraDettaglio ? TT.rotazioneAperta : 0))
                }
            }
            .buttonStyle(.appleSobrio)
            if mostraDettaglio {
                ForEach(Array(avvisiTFR(e).dropFirst().enumerated()), id: \.offset) { _, a in
                    Text(a)
                        .carattereApple(A.nota)
                        .foregroundColor(A.avviso)
                        .fixedSize(horizontal: false, vertical: true)
                }
                pillole(testi)
                Text(testi.frasePareggio + ".")
                    .carattereApple(A.pareggio)
                    .foregroundColor(A.coloreTesto)
                    .fixedSize(horizontal: false, vertical: true)
                grafico(e)
                Text(testi.perchePareggio)
                    .carattereApple(A.testo)
                    .foregroundColor(A.coloreTesto)
                    .fixedSize(horizontal: false, vertical: true)
                if let c = testi.testoContributi {
                    Text(c)
                        .carattereApple(A.testo)
                        .foregroundColor(A.coloreTesto)
                        .fixedSize(horizontal: false, vertical: true)
                }
                tabella(e, eta: testi.eta)
                NotaMetodo(testo: TestiTFR.metodo.joined(separator: "\n"), titolo: "Come si calcola")
                NotaMetodo(testo: TestiTFR.semplificazioni.joined(separator: "\n"), titolo: "Semplificazioni")
                NotaMetodo(testo: (TestiTFR.daSapere + [TestiTFR.avvertenza]).joined(separator: "\n"), titolo: "Da sapere")
            }
        }
    }

    // MARK: - Chi non lavora da dipendente

    func senzaTFRMac(_ tipo: TipoLavoratore) -> some View {
        let nome = nomeTFR
        let s = stato
        return VStack(alignment: .leading, spacing: TT.spazioInterno) {
            occhielloMac(TestiTFR.occhielloSenzaTFR(nome))
            Text(TestiTFR.fraseSenzaTFR(tipo, nome: nome))
                .carattereApple(TT.frase)
                .foregroundColor(TT.coloreCorpo)
                .fixedSize(horizontal: false, vertical: true)
            Text(TestiTFR.testoSenzaTFR(nome))
                .carattereApple(TT.corpo)
                .foregroundColor(TT.coloreCorpo)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: SC.spazioStrada) {
                Button(TestiTFR.apriContoPensione) {
                    // «Le aree», poi il dettaglio della previdenza dalla sua card (come «Apri l'area», migliorie d'uso 46)
                    s.scegliStrumentoAnalisi(nil)
                    s.apriAreaAnalisi360(.previdenza)
                }
                .buttonStyle(.applePrimario)
                .fixedSize()
                Button(TestiTFR.faiLoStesso) { confrontaComunque = true }
                    .buttonStyle(.apple)
                    .fixedSize()
                    .help("Per esempio se il cliente sta per diventare dipendente")
            }
            .padding(.top, SC.spazioBlocchi)
        }
        .padding(TT.paddingSenza)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(SC.superficie)
    }
}

// MARK: - Le strade

/// «Le strade: quanto resta in mano, tolte le tasse»: una riga per strada (nome, cifra e la differenza dal TFR in
/// azienda in una pillola), poi la barra alta 10 sulla scala della più lunga.
private struct StradeRispostaTFR: View {
    let e: EsitoTFR

    private var massimo: Double { max(e.azienda.netto, e.fondo.netto, e.fondoContributi?.netto ?? 0, 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: TT.spazioStrade) {
            Text(TestiTFR.titoloStrade)
                .carattereApple(SC.occhiello)
                .foregroundColor(SC.coloreOcchiello)
            riga(TestiTFR.stradaLasciata, e.azienda.netto, colore: TT.coloreAzienda, differenza: nil)
            riga(TestiTFR.stradaNelFondo, e.fondo.netto, colore: TT.coloreFondo, differenza: e.differenza)
            if let c = e.fondoContributi {
                riga(TestiTFR.stradaConContributo, c.netto, colore: TT.coloreContributi, differenza: c.netto - e.azienda.netto)
            }
        }
        .padding(TT.paddingStrade)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(SC.superficie)
        .accessibilityElement(children: .combine)
    }

    private func riga(_ nome: String, _ valore: Double, colore: Color, differenza: Double?) -> some View {
        VStack(alignment: .leading, spacing: TT.spazioBarra) {
            HStack(spacing: SC.spazioStrada) {
                Text(nome)
                    .carattereApple(TT.rigaStrada)
                    .foregroundColor(TT.coloreCorpo)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: SC.spazioStrada)
                Text(CifreDoc.unisciAlSegno(CifreDoc.euroArrotondato(valore)))
                    .carattereApple(TT.cifraStrada)
                    .foregroundColor(TT.coloreCorpo)
                    .lineLimit(1)
                    .fixedSize()
                if let d = differenza {
                    Pillola(testo: CifreDoc.unisciAlSegno((d >= 0 ? "+ " : "\(CifreDoc.meno) ") + CifreDoc.euroArrotondato(abs(d))),
                            tono: d >= 0 ? .ok : .attenzione)
                }
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous).fill(TT.binario)
                    Capsule(style: .continuous).fill(colore)
                        .frame(width: g.size.width * CGFloat(max(TT.barraMinima, min(1, max(0, valore) / massimo))))
                }
            }
            .frame(height: TT.barra)
        }
    }
}

// MARK: - I tre riquadri

/// Un riquadro di «da dove viene la differenza»: titolo, cifra grande e testo breve.
private struct TesseraRispostaTFR: View {
    let titolo: String
    let valore: Text
    let testo: String

    var body: some View {
        VStack(alignment: .leading, spacing: TT.spazioInterno) {
            Text(titolo)
                .carattereApple(SC.occhiello)
                .foregroundColor(SC.coloreOcchiello)
                .fixedSize(horizontal: false, vertical: true)
            valore
                .carattereApple(TT.cifraTessera)
                .foregroundColor(TT.coloreCorpo)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(testo)
                .carattereApple(TT.testoTessera)
                .foregroundColor(TT.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TT.paddingTessera)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(SC.riquadro)
    }
}

// MARK: - Vera

extension StatoShell {
    /// «Chiedi a Vera di spiegarlo» (decisione 69-f): apre Vera e, finito il passaggio, manda la domanda con la frase e
    /// la riga di Prisma (modalità lavoro, sullo spunto della pensione): Qwen racconta le cifre di Prisma, non le fa.
    func chiediVeraTFR(_ domanda: String) {
        guard appConsentita(.vera) else {
            apri(.vera)
            return
        }
        if veraPortafoglio { veraPortafoglio = false }
        apri(.vera)
        let attesa = Movimenti.calmo ? 0 : Tema.Apple.Moto.DomandaDaScrivania.ritardo
        DispatchQueue.main.asyncAfter(deadline: .now() + attesa) { [weak self] in
            _ = self?.chiediVera(domanda, spunto: .pensione)
        }
    }
}
#endif
