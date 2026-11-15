#if os(macOS)
import SwiftUI

// Migliorie d'uso 15 «La scheda di una posizione si legge dall'alto» (Design/uso/gruppo-02.md §15), solo sul Mac:
// - la barra alta 34: «‹ Le posizioni» (torna alla schermata di prima, con i filtri di prima) e al più quattro azioni con
//   il nome, il resto in «Altro ⌄» (per una proposta tre pulsanti: «Segna come in essere», «Esito…», «Altro ⌄»);
//   «Elimina la posizione…» esce dal fondo della pagina e va in «Altro ⌄», con la conferma di sempre;
// - la testata di oggi, poi una frase (19 semibold) e le quattro cifre, coi testi di `TestiDettaglioPosizione`;
// - il segmentato delle schede che hanno contenuto (`SchedaPosizione.disponibili`) e la sola scheda scelta: tutte le
//   sezioni della pagina lunga di prima ci sono ancora, ognuna nella sua scheda;
// - le ancore «dettaglio-…» (istantanee, completezza) scelgono la scheda e poi scorrono, al giro dopo.
// Esc fa un passo indietro (EscFinestra.swift). iPhone e iPad tengono la pagina lunga (`paginaLunga`).

extension DettaglioPosizione {
    private typealias K = Tema.Apple.Posizioni.SchedaDettaglio
    private typealias T = TestiDettaglioPosizione

    // MARK: - La pagina

    func paginaMac(_ calcoli: CalcoliDettaglio) -> some View {
        let p = posizione
        let disponibili = schedeDisponibili(calcoli)
        let mostrata = disponibili.contains(scheda) ? scheda : .inBreve
        return VStack(spacing: 0) {
            barraMac
            ScrollViewReader { lettore in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        intestazione
                        Text(T.frase(p, voce: calcoli.voce, nome: nomeCliente, mesiSpese: liquidita?.mesi))
                            .carattereApple(K.frase)
                            .foregroundColor(K.coloreFrase)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                            .padding(.top, K.fraseSopra)
                            .padding(.bottom, K.fraseSotto)
                        cifre(calcoli)
                        if disponibili.count > 1 {
                            SegmentatoPillola(selezione: Binding(get: { mostrata }, set: { scheda = $0 }),
                                              voci: disponibili.map { ($0, $0.titolo(protezione: p.area == .protezione)) })
                                .padding(.top, K.schedeSopra)
                                .padding(.bottom, K.schedeSotto)
                        }
                        contenutoScheda(mostrata, calcoli)
                    }
                    .padding(K.margine)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                // Il contenuto che scorre sfuma sotto la barra invece di finire tagliato sul filo
                .mask {
                    VStack(spacing: 0) {
                        LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                            .frame(height: Tema.Misura.Dossier.sfumaturaBarra)
                        Color.black
                    }
                }
                .onAppear { apriAncora(lettore, disponibili: disponibili) }
                .onChange(of: stato.ancoraPosizioni) { _, _ in apriAncora(lettore, disponibili: disponibili) }
            }
        }
        // Un'altra posizione riparte da «In breve» (o dalla scheda dell'ancora che la apre, se arriva insieme)
        .onChange(of: posizione.id) { _, _ in
            scheda = stato.ancoraPosizioni.flatMap { SchedaPosizione(ancora: $0) } ?? .inBreve
        }
    }

    /// Le schede che hanno contenuto per questa posizione.
    private func schedeDisponibili(_ calcoli: CalcoliDettaglio) -> [SchedaPosizione] {
        let p = posizione
        return SchedaPosizione.disponibili(p, andamento: calcoli.andamento != nil, proiezione: calcoli.proiezione != nil,
                                           riscatto: !(calcoli.riscatto?.righe.isEmpty ?? true),
                                           adeguatezza: MotoreAdeguatezza.pertinente(p, scheda: stato.schedaAdeguatezza(p.id)))
    }

    /// Un'ancora «dettaglio-…» sceglie la sua scheda; poi, se la parte non è in cima alla scheda, ci si scorre al giro
    /// dopo (la scheda nuova deve essere già costruita). L'ancora si consuma comunque.
    private func apriAncora(_ lettore: ScrollViewProxy, disponibili: [SchedaPosizione]) {
        guard let ancora = stato.ancoraPosizioni, ancora.hasPrefix("dettaglio-") else { return }
        if let s = SchedaPosizione(ancora: ancora), disponibili.contains(s) { scheda = s }
        let istantanea = modoIstantanea
        let scorre = !SchedaPosizione.inCima(ancora)
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                if scorre {
                    // Nell'istantanea si scorre di colpo: con il movimento la foto arriverebbe a metà strada
                    if istantanea {
                        lettore.scrollTo(ancora, anchor: .top)
                    } else {
                        withAnimation(Animazioni.apertura) { lettore.scrollTo(ancora, anchor: .top) }
                    }
                }
                if stato.ancoraPosizioni == ancora { stato.ancoraPosizioni = nil }
            }
        }
    }

    // MARK: - Dati del cliente

    private var cliente: Cliente? { stato.cliente(posizione.clienteId) }

    /// Il nome di battesimo per la frase (in modalità cliente è il suo: nessun dato di altri clienti).
    private var nomeCliente: String { cliente.map(StatoShell.nomeDiBattesimo) ?? "Il cliente" }

    /// La liquidità di Analisi 360 (mesi di spese e soglia), solo per i conti: le aree sono in cache.
    private var liquidita: Liquidita360? {
        guard posizione.area == .liquidita, posizione.stato == .inEssere else { return nil }
        return stato.aree360(posizione.clienteId).liquidita
    }

    // MARK: - La barra

    private var barraMac: some View {
        HStack(spacing: K.spazioAzioni) {
            Button { stato.posizioneInDettaglio = nil } label: {
                Label(T.indietro, systemImage: "chevron.left")
            }
            .buttonStyle(StileVetro())
            .help(T.aiutoIndietro)
            Spacer(minLength: K.spazioAzioni)
            // Con poco spazio le azioni secondarie passano in «Altro ⌄»: mai pulsanti con la sola icona
            ViewThatFits(in: .horizontal) {
                azioniMac(compatte: false)
                azioniMac(compatte: true)
            }
        }
        .environment(\.pulsantiSoloIcona, false)
        .padding(.horizontal, K.margineBarra)
        .padding(.vertical, K.paddingBarra)
        .frame(minHeight: K.altezzaBarra)
        .bordoBasso(Colori.Analisi.tabellaRiga)
    }

    /// Le azioni in vista. `compatte`: solo la principale (e «Esito…» per una proposta), il resto in «Altro ⌄».
    private func azioniMac(compatte: Bool) -> some View {
        let p = posizione
        return HStack(spacing: K.spazioAzioni) {
            if p.stato == .proposta {
                // L'esito della proposta passa dal modulo: decorrenza, primo valore e versato veri
                Button { stato.apriEsito(p, passo: .accettata, origine: .posizioni) } label: {
                    Label("Segna come in essere", systemImage: "checkmark")
                }
                .buttonStyle(StileBlu())
                .help("Chiede decorrenza, primo valore e versato prima di passarla in essere")
                Button("Esito…") { stato.apriEsito(p, passo: .scelta, origine: .posizioni) }
                    .buttonStyle(StileVetro())
                    .help("Rifiutata, rimandata o ancora in attesa")
            } else if !compatte {
                if p.area.proiettabile {
                    Button("Simula") { stato.simula(p) }
                        .buttonStyle(StileVetro())
                        .help("Porta le ipotesi di questa posizione nel simulatore")
                    Button("Confronta") { stato.confronta(p) }
                        .buttonStyle(StileVetro())
                        .help("Confronta con una proposta o un'altra posizione")
                }
                if sinistroPossibile {
                    Button(TestiSinistri.apriUnSinistro) { stato.apriNuovoSinistro(cliente: p.clienteId, posizione: p.id) }
                        .buttonStyle(StileVetro())
                        .help("Segui il sinistro di questa polizza in Pratiche › Sinistri, come una spedizione")
                        .disabled(stato.solaLettura)
                }
                Button("Prospetto") { stato.apriProspetto(.posizione(p.id)) }
                    .buttonStyle(StileVetro())
                    .help("Il prospetto di dettaglio in PDF: contratto, costi, proiezione anno per anno, fonti")
                Button("Modifica", action: modifica)
                    .buttonStyle(StileVetro())
                    .help("Modifica i dati della posizione")
            }
            MenuAzioni(voci: { vociAltro(compatte: compatte) }, margine: Misure.Pulsante.vetroMargine, taglia: .normale) {
                HStack(spacing: K.spazioFreccia) {
                    Text(T.altro)
                    Image(systemName: "chevron.down")
                        .font(K.freccia.font)
                }
            }
            .help("Altre azioni sulla posizione")
        }
        .fixedSize()
    }

    /// «Apri un sinistro»: dalla polizza di protezione in essere, fuori dalla modalità cliente («Luce» giro 15).
    private var sinistroPossibile: Bool {
        posizione.area == .protezione && posizione.stato == .inEssere && !stato.inModoCliente
    }

    private func vociAltro(compatte: Bool) -> [VoceMenuAzioni] {
        let p = posizione
        let s = stato
        let apriProspetto = { s.apriProspetto(.posizione(p.id)) }
        var voci: [VoceMenuAzioni] = []
        if p.stato == .proposta {
            if p.area.proiettabile {
                voci.append(.azione("Simula", aiuto: "Porta le ipotesi di questa proposta nel simulatore") { s.simula(p) })
                voci.append(.azione("Confronta", aiuto: "Confronta la proposta con la posizione in essere") { s.confronta(p) })
            }
            if MotoreAdeguatezza.pertinente(p, scheda: s.schedaAdeguatezza(p.id)) {
                let scegli = Binding(get: { scheda }, set: { scheda = $0 })
                voci.append(.azione("Adeguatezza", aiuto: "La scheda di adeguatezza: controlli, documenti, PDF da firmare") {
                    scegli.wrappedValue = .adeguatezza
                })
            }
            if s.prodotto(p.prodottoId)?.condizioni != nil {
                voci.append(.azione("Valutazione", aiuto: "Prospetto e report di riscatto: incassi netti anno per anno in tre scenari") {
                    s.valutaPosizione(p)
                })
            }
            voci.append(.azione("Prospetto", aiuto: "Il prospetto di dettaglio in PDF", apriProspetto))
            voci.append(.azione("Modifica", aiuto: "Modifica i dati della posizione", modifica))
        } else if compatte {
            if p.area.proiettabile {
                voci.append(.azione("Simula", aiuto: "Porta le ipotesi di questa posizione nel simulatore") { s.simula(p) })
                voci.append(.azione("Confronta", aiuto: "Confronta con una proposta o un'altra posizione") { s.confronta(p) })
            }
            if sinistroPossibile {
                voci.append(.azione(TestiSinistri.apriUnSinistro, attiva: !s.solaLettura,
                                    aiuto: "Segui il sinistro di questa polizza in Pratiche › Sinistri") {
                    s.apriNuovoSinistro(cliente: p.clienteId, posizione: p.id)
                })
            }
            voci.append(.azione("Prospetto", aiuto: "Il prospetto di dettaglio in PDF", apriProspetto))
            voci.append(.azione("Modifica", aiuto: "Modifica i dati della posizione", modifica))
        }
        if !voci.isEmpty { voci.append(.separatore) }
        let conferma = Binding(get: { confermaEliminazione }, set: { confermaEliminazione = $0 })
        voci.append(.azione(T.elimina, aiuto: "Toglie la posizione dal dossier, dopo la conferma") {
            conferma.wrappedValue = true
        })
        return voci
    }

    // MARK: - Le quattro cifre

    private func cifre(_ calcoli: CalcoliDettaglio) -> some View {
        let p = posizione
        let riepilogo: RiepilogoPosizioni? = (p.area == .liquidita || p.area == .immobili) && p.stato == .inEssere
            ? stato.riepilogoPosizioniCliente(p.clienteId) : nil
        let elenco = T.cifre(p, voce: calcoli.voce, attesoNetto: attesoNetto(calcoli),
                             mesiSpese: liquidita?.mesi, sogliaMesi: liquidita?.soglia,
                             attivita: riepilogo?.attivita, debiti: riepilogo?.debiti,
                             adeguatezza: adeguatezzaInBreve)
        return Group {
            if !elenco.isEmpty {
                FasciaKPI {
                    ForEach(Array(elenco.enumerated()), id: \.offset) { i, c in
                        KPI(titolo: c.titolo, valore: c.valore, ultimo: i == elenco.count - 1, coloreValore: colore(c.tono)) {
                            Text(c.nota)
                        }
                    }
                }
            }
        }
    }

    /// Il rendimento atteso al netto dei costi: quello dell'andamento o, senza storico, atteso meno costo annuo.
    private func attesoNetto(_ calcoli: CalcoliDettaglio) -> Double? {
        if let a = calcoli.andamento?.attesoAnnuo { return a }
        let p = posizione
        guard p.area.proiettabile, !p.multiramoDivisa, let r = p.rendimentoAtteso else { return nil }
        return r - (p.costoAnnuo ?? 0)
    }

    /// L'esito della scheda di adeguatezza di una proposta (in cache, lo stesso del pannello).
    private var adeguatezzaInBreve: AdeguatezzaInBreve? {
        let p = posizione
        guard p.stato == .proposta, MotoreAdeguatezza.pertinente(p, scheda: stato.schedaAdeguatezza(p.id)),
              let i = stato.ingressoAdeguatezza(p) else { return nil }
        let e = stato.esitoAdeguatezzaPannello(i)
        return AdeguatezzaInBreve(complessivo: e.complessivo, inOrdine: e.conta(.verde), controlli: e.controlli.count)
    }

    private func colore(_ t: CifraPosizione.Tono) -> Color? {
        switch t {
        case .normale: return nil
        case .verde: return K.verde
        case .rosso: return K.rosso
        case .arancio: return K.arancio
        case .viola: return K.viola
        }
    }

    // MARK: - Le schede

    @ViewBuilder private func contenutoScheda(_ s: SchedaPosizione, _ calcoli: CalcoliDettaglio) -> some View {
        switch s {
        case .inBreve: inBreve(calcoli)
        case .andamento: schedaAndamento(calcoli)
        case .costiRischio: schedaCosti(calcoli)
        case .adeguatezza: PannelloAdeguatezza(posizione: posizione).id("dettaglio-adeguatezza")
        case .contratto: schedaContratto
        }
    }

    /// Andamento: com'è andata (grafico, periodi), il riferimento, lo storico dei valori e la proiezione con gli scenari.
    private func schedaAndamento(_ calcoli: CalcoliDettaglio) -> some View {
        let p = posizione
        return VStack(alignment: .leading, spacing: K.spazioPannelli) {
            if let a = calcoli.andamento {
                andamento(a, voce: calcoli.voce).id("dettaglio-andamento")
                PannelloRiferimento(posizione: p, andamento: a, voce: calcoli.voce).id("dettaglio-riferimento")
            }
            if p.stato == .inEssere, p.area.proiettabile, calcoli.fisco != nil {
                storico(calcoli.voce)
            }
            if let x = calcoli.proiezione {
                proiezione(x)
            }
        }
    }

    /// Costi e rischio: costi e ipotesi, «Se si chiudesse oggi», composizione, gestione separata, riscatto; per una
    /// copertura il quadro della copertura.
    private func schedaCosti(_ calcoli: CalcoliDettaglio) -> some View {
        let p = posizione
        return VStack(alignment: .leading, spacing: K.spazioPannelli) {
            if p.area.proiettabile {
                HStack(alignment: .top, spacing: K.spazio) {
                    costiERischio(calcoli)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    if p.stato == .inEssere, let f = calcoli.fisco {
                        // Il rendimento dei versamenti va qui solo se manca il pannello dell'andamento
                        fiscalita(f, voce: calcoli.andamento == nil ? calcoli.voce : nil)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
                if p.multiramo {
                    PannelloComposizione(posizione: p, sriMassimo: sriMassimoProfilo, completa: modifica)
                        .id("dettaglio-composizione")
                }
                if let g = calcoli.gestione {
                    if p.multiramoDivisa {
                        PannelloGestioneSeparata(
                            esito: g, posizione: p,
                            titolo: "La parte in gestione separata · \(Formati.percentuale(p.parteGestione * 100))",
                            notaQuota: Formati.euro(p.valore * p.parteGestione))
                            .id("dettaglio-gestione")
                    } else {
                        PannelloGestioneSeparata(esito: g, posizione: p).id("dettaglio-gestione")
                    }
                }
            }
            if let r = calcoli.riscatto, !r.righe.isEmpty {
                PannelloRiscatto(esito: r).id("dettaglio-riscatto")
            }
            if p.area == .protezione && calcoli.proiezione == nil {
                protezione
            }
        }
    }

    // MARK: Contratto

    /// Contratto: a sinistra le sole righe piene; a destra «Da completare · {n}» con i nomi e un solo «Completa i dati».
    private var schedaContratto: some View {
        let p = posizione
        let righe = T.righeContratto(p)
        let vuoti = T.campiVuoti(p)
        return HStack(alignment: .top, spacing: K.spazio) {
            PannelloAnalisi(titolo: T.datiDelContratto) { EmptyView() } contenuto: {
                VStack(spacing: 0) {
                    ForEach(Array(righe.enumerated()), id: \.offset) { _, r in
                        RigaDato(r.etichetta, r.valore)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .layoutPriority(1)
            .id("dettaglio-contratto")
            PannelloAnalisi(titolo: vuoti.isEmpty ? T.datiDelContratto : T.daCompletare(vuoti.count)) {
                if !vuoti.isEmpty {
                    Button(T.completaIDati) {
                        // Sul primo campo vuoto, evidenziato e portato in vista dal modulo
                        if let campo = T.primoCampoModulo(p), let suCampo = modificaSuCampo {
                            suCampo(campo)
                        } else {
                            modifica()
                        }
                    }
                        .buttonStyle(StileVetro())
                        .disabled(stato.solaLettura)
                        .help("Apre «Modifica»: i campi vuoti si completano in una volta")
                }
            } contenuto: {
                VStack(alignment: .leading, spacing: K.spazioStriscia) {
                    if vuoti.isEmpty {
                        Text(T.nessunVuoto)
                            .carattereApple(K.nota)
                            .foregroundColor(K.coloreNota)
                    } else {
                        CapsuleNomi(nomi: vuoti)
                        Text(T.siCompletano)
                            .carattereApple(K.nota)
                            .foregroundColor(K.coloreNota)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    // MARK: In breve

    @ViewBuilder private func inBreve(_ calcoli: CalcoliDettaglio) -> some View {
        let p = posizione
        let vuoti = T.campiVuoti(p)
        VStack(alignment: .leading, spacing: K.spazio) {
            if p.stato == .proposta {
                dueCard {
                    cardTesto("A cosa risponde", T.aCosaRisponde(p, obiettivo: obiettivoCollegato))
                } destra: {
                    cardCosaManca(T.cosaManca(p, nome: nomeCliente))
                }
            } else if p.stato == .inEssere && p.area.proiettabile {
                dueCard {
                    if let a = calcoli.andamento {
                        PannelloAnalisi(titolo: "Come sta andando") {
                            collegamento(T.andamentoLink, .andamento)
                        } contenuto: {
                            GraficoAndamento(punti: a.punti)
                        }
                    } else {
                        cardTesto("Come sta andando", T.andamentoCorto(conDecorrenza: p.decorrenza != nil))
                    }
                } destra: {
                    if p.area == .previdenza {
                        perLaPensione
                    } else if let f = calcoli.fisco {
                        seSiChiudesseOggi(f)
                    }
                }
            } else if p.stato == .inEssere && p.area == .protezione {
                dueCard {
                    if let s = p.scadenza, p.scaduta || p.scadeEntro(RiepilogoPosizioni.giorniScadenza) {
                        PannelloAnalisi(titolo: "Da fare") {
                            if !stato.inModoCliente {
                                Button(T.daFareLink) { stato.apriDaFare(soloCliente: true) }
                                    .buttonStyle(StileCollegamento())
                            }
                        } contenuto: {
                            testoCard(T.daFareScadenza(s, nome: nomeCliente, adesso: Date()))
                        }
                    } else {
                        PannelloAnalisi(titolo: "Rispetto al bisogno") {
                            if !stato.inModoCliente {
                                Button(T.analisi360Link) { stato.apri(.analisi360) }
                                    .buttonStyle(StileCollegamento())
                            }
                        } contenuto: {
                            testoCard(stato.aree360(p.clienteId).sintesi(.protezione)?.testo ?? "")
                        }
                    }
                } destra: {
                    cardTesto("Se succede", T.seSuccede(p))
                }
            } else {
                cardTesto("In breve", T.inBreveAltro(p, mesiSpese: liquidita?.mesi, sogliaMesi: liquidita?.soglia))
            }
            if !vuoti.isEmpty {
                strisciaDaCompletare(vuoti)
            }
        }
    }

    /// Due card affiancate in alto, la sinistra un po' più larga (1,25 a 1 nel template).
    private func dueCard<A: View, B: View>(@ViewBuilder sinistra: () -> A, @ViewBuilder destra: () -> B) -> some View {
        HStack(alignment: .top, spacing: K.spazio) {
            sinistra()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .layoutPriority(1)
            destra()
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private func cardTesto(_ titolo: String, _ testo: String) -> some View {
        PannelloAnalisi(titolo: titolo) { EmptyView() } contenuto: {
            testoCard(testo)
        }
    }

    private func testoCard(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(K.testoCard)
            .foregroundColor(K.coloreTestoCard)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// «Andamento ›», «Costi e rischio ›»: scelgono la scheda.
    private func collegamento(_ testo: String, _ s: SchedaPosizione) -> some View {
        let scegli = Binding(get: { scheda }, set: { scheda = $0 })
        return Button(testo) { scegli.wrappedValue = s }
            .buttonStyle(StileCollegamento())
    }

    private func cardCosaManca(_ righe: [String]) -> some View {
        PannelloAnalisi(titolo: "Cosa manca per chiuderla") { EmptyView() } contenuto: {
            VStack(alignment: .leading, spacing: K.spazioRighe) {
                if righe.isEmpty {
                    testoCard("Niente: la proposta è chiusa.")
                }
                ForEach(righe, id: \.self) { r in
                    HStack(spacing: K.spazioRighe) {
                        Circle().fill(K.colorePallino).frame(width: K.pallino, height: K.pallino)
                        Text(r)
                            .carattereApple(K.riga)
                            .foregroundColor(K.coloreTestoCard)
                    }
                }
            }
        }
    }

    /// «Se si chiudesse oggi»: imposta, netto e la scala del rischio, con «Costi e rischio ›».
    private func seSiChiudesseOggi(_ f: EsitoFiscale) -> some View {
        PannelloAnalisi(titolo: "Se si chiudesse oggi") {
            collegamento(T.costiLink, .costiRischio)
        } contenuto: {
            VStack(alignment: .leading, spacing: 0) {
                RigaDato("Imposta", f.imposta > 0.005 ? "\(Formati.euroDecimali(f.imposta)) (\(CifreDoc.percento(f.aliquota, decimali: 2)))" : "nessuna",
                         larghezza: Tema.Misura.MotoriPosizioni.etichettaRiga)
                RigaDato("Netto", Formati.euroDecimali(f.netto), larghezza: Tema.Misura.MotoriPosizioni.etichettaRiga)
                rigaRischio
            }
        }
    }

    /// «Per la pensione» (la previdenza non ha imposta sul rendimento): quanto versa, la deduzione, il rischio.
    private var perLaPensione: some View {
        let p = posizione
        return PannelloAnalisi(titolo: "Per la pensione") {
            collegamento(T.costiLink, .costiRischio)
        } contenuto: {
            VStack(alignment: .leading, spacing: 0) {
                RigaDato("Versa", p.premioAnnuo > 0 ? "\(Formati.euro(p.premioAnnuo)) l'anno" : "niente, per ora",
                         larghezza: Tema.Misura.MotoriPosizioni.etichettaRiga)
                RigaDato("I versamenti", "si deducono dal reddito", larghezza: Tema.Misura.MotoriPosizioni.etichettaRiga)
                rigaRischio
            }
        }
    }

    private var rigaRischio: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Rischio (SRI)")
                .font(Tipo.campoEtichetta)
                .foregroundColor(Colori.Analisi.kpiNota)
                .frame(width: Tema.Misura.MotoriPosizioni.etichettaRiga, alignment: .leading)
            ScalaRischio(valore: posizione.sri)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }

    /// La striscia in fondo a «In breve»: «{n} dati da completare» · i nomi · «Vedi ›» (porta a Contratto).
    private func strisciaDaCompletare(_ vuoti: [String]) -> some View {
        let scegli = Binding(get: { scheda }, set: { scheda = $0 })
        return Button { scegli.wrappedValue = .contratto } label: {
            HStack(alignment: .firstTextBaseline, spacing: K.spazioStriscia) {
                Text(T.datiDaCompletare(vuoti.count))
                    .carattereApple(K.striscia)
                    .foregroundColor(K.coloreStriscia)
                Text(vuoti.joined(separator: ", "))
                    .carattereApple(K.nomiStriscia)
                    .foregroundColor(K.coloreNomiStriscia)
                    .lineLimit(1)
                Spacer(minLength: K.spazioStriscia)
                Text(T.vedi)
                    .carattereApple(K.nomiStriscia)
                    .foregroundColor(Tema.Apple.Colore.accento)
            }
            .padding(K.paddingStriscia)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: K.raggioStriscia, style: .continuous).fill(K.fondoStriscia)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Apre la scheda Contratto")
    }

    /// L'obiettivo collegato nella scheda di adeguatezza della proposta, se c'è.
    private var obiettivoCollegato: String? {
        guard let id = stato.schedaAdeguatezza(posizione.id)?.obiettivoId else { return nil }
        return stato.obiettiviCliente(posizione.clienteId).first { $0.id == id }?.titolo
    }
}

/// I nomi dei campi vuoti in capsule, su più righe se serve.
private struct CapsuleNomi: View {
    let nomi: [String]
    private typealias K = Tema.Apple.Posizioni.SchedaDettaglio

    var body: some View {
        RigheCapsule(spazio: K.spazioCapsule) {
            ForEach(nomi, id: \.self) { n in
                Text(n)
                    .carattereApple(K.capsula)
                    .foregroundColor(K.coloreCapsula)
                    .padding(K.paddingCapsula)
                    .background { Capsule(style: .continuous).fill(K.fondoCapsula) }
                    .fixedSize()
            }
        }
    }
}

/// Le capsule una dopo l'altra, a capo quando la riga è piena.
private struct RigheCapsule: Layout {
    let spazio: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let larghezza = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, riga: CGFloat = 0, massima: CGFloat = 0
        for s in subviews {
            let m = s.sizeThatFits(.unspecified)
            if x > 0 && x + m.width > larghezza {
                y += riga + spazio
                x = 0
                riga = 0
            }
            x += m.width + spazio
            riga = max(riga, m.height)
            massima = max(massima, x - spazio)
        }
        return CGSize(width: proposal.width ?? massima, height: y + riga)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, riga: CGFloat = 0
        for s in subviews {
            let m = s.sizeThatFits(.unspecified)
            if x > bounds.minX && x + m.width > bounds.maxX {
                y += riga + spazio
                x = bounds.minX
                riga = 0
            }
            s.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(m))
            x += m.width + spazio
            riga = max(riga, m.height)
        }
    }
}
#endif
