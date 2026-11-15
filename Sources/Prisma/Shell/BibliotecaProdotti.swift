import SwiftUI

// Migliorie d'uso 63 «I prodotti parlano chiaro» (Design/uso/gruppo-12.md §63, template righe 4988-5022):
//
//   ┌ PER GIULIA, DAL PIÙ ADATTO   6 ┐ ┌ PREVIDENZA · PIP                     Fonte verificata il … ┐
//   │ (cerca…)            [Filtra ⌄] │ │ Piano pensione                                              │
//   │ ■ Piano pensione       [canale]│ │ [canale] (Risponde a una priorità di Giulia)                │
//   │   Previdenza · costo 1,2% · …  │ │ ┌ È per ─────────────┐ ┌ Non è per ──────────┐             │
//   │   risponde a una priorità      │ │ │ ✓ …                │ │ ✕ …                  │             │
//   │ ■ …                            │ │ ┌ Su 10.000 € in dieci anni ┐ ┌ Quanto rischia ┐ ┌ Per quanto tempo ┐
//   └────────────────────────────────┘ │ [Proponi a Giulia] [Confronta con quello che ha]   nota grigia │
//                                      │ Tutti i dettagli ⌄                                            ┘
//
// Sul Mac il catalogo sta nella Biblioteca (segmentato «Documenti | Prodotti» nella testata): `apri(.prodotti)` ci porta
// da solo (`AppPrisma.ospite`). Su iPhone e iPad Prodotti resta l'app di sempre (AppProdotti.swift).

/// Le due sezioni della Biblioteca sul Mac.
enum SezioneBiblioteca: String, CaseIterable, Identifiable, Hashable {
    case documenti, prodotti

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .documenti: return TestiCatalogo.documenti
        case .prodotti: return TestiCatalogo.prodotti
        }
    }
}

/// Le azioni di gestione del menu «Altro» della testata, per la scheda scelta nel catalogo (decisione 63-e).
enum RichiestaCatalogo: Equatable {
    case nuova, daiDocumenti, modifica, aggiorna, simula, elimina
}

/// La testata della Biblioteca: «Documenti | Prodotti» e, sul catalogo, il menu «Altro» (nascosto in modalità cliente).
/// Su iPhone e iPad niente (la Biblioteca non c'è).
struct AzioniBiblioteca: View {
    @Environment(StatoShell.self) var stato

    var body: some View {
        #if os(macOS)
        HStack(spacing: Misure.IntestazioneApp.spazioAzioni) {
            SegmentatoPillola(selezione: Bindable(stato).sezioneBiblioteca, valori: SezioneBiblioteca.allCases,
                              titolo: { $0.titolo })
                .fixedSize()
            if stato.sezioneBiblioteca == .prodotti && !stato.inModoCliente {
                MenuAzioni(voci: { voci }, margine: Misure.Pulsante.vetroMargine, taglia: .normale) {
                    HStack(spacing: Tema.Apple.Catalogo.spazioFreccia) {
                        Text(TestiCatalogo.altro)
                        Image(systemName: "chevron.down")
                    }
                }
                .help("Nuova scheda, modifica, aggiorna dai documenti, simula o elimina la scheda scelta")
            }
        }
        #else
        EmptyView()
        #endif
    }

    #if os(macOS)
    private var voci: [VoceMenuAzioni] {
        let s = stato
        let modifica = !s.solaLettura
        let conScheda = !s.dati.prodotti.isEmpty
        return [
            .azione("Nuova scheda", attiva: modifica) { s.richiestaCatalogo = .nuova },
            .azione("Dai documenti…", attiva: modifica,
                    aiuto: "Nuova scheda dai documenti: KID, DIP, condizioni, scheda costi") { s.richiestaCatalogo = .daiDocumenti },
            .separatore,
            .azione("Modifica", attiva: modifica && conScheda) { s.richiestaCatalogo = .modifica },
            .azione("Aggiorna dai documenti…", attiva: modifica && conScheda,
                    aiuto: "Leggi il KID nuovo, il DIP aggiuntivo o le condizioni e aggiorna costi, scenari e penali della scheda") {
                s.richiestaCatalogo = .aggiorna
            },
            .azione("Simula", attiva: conScheda) { s.richiestaCatalogo = .simula },
            .separatore,
            .azione("Elimina la scheda…", attiva: modifica && conScheda) { s.richiestaCatalogo = .elimina },
        ]
    }
    #endif
}

#if os(macOS)
/// Il catalogo dei prodotti nella Biblioteca: è `AppProdotti` con la scheda che parla chiaro (moduli, cifre in cache e
/// pannelli di dettaglio restano quelli dell'app).
struct CatalogoProdottiMac: View {
    var body: some View {
        AppProdotti(nellaBiblioteca: true)
    }
}

private typealias KC = Tema.Apple.Catalogo
private typealias BC = Tema.Apple.Biblioteca

extension AppProdotti {
    // MARK: - Esiti e ordine (una volta per dati dei calcoli e cliente, mai per riga)

    /// L'esito di ogni scheda per il cliente scelto (vuoto senza cliente).
    func esitiCatalogo(_ c: Cliente?) -> [String: EsitoProdottoCliente] {
        guard let c else { return [:] }
        return stato.ricavato("prodotti-esiti|\(c.id)") { () -> [String: EsitoProdottoCliente] in
            let bisogni = MotoreBisogni.priorita(stato.bisogniRilevati(c.id), profilo: c.bisogni)
            let priorita = PrioritaAree360.dallaRuota(bisogni)
            var esiti: [String: EsitoProdottoCliente] = [:]
            for p in stato.dati.prodotti {
                esiti[p.id] = MotoreSchedaProdotto.esito(p, propensione: c.profilo.propensione, priorita: priorita)
            }
            return esiti
        }
    }

    /// Le schede del catalogo: con un cliente dal più adatto, senza in ordine di nome; poi i filtri e la ricerca.
    var elencoCatalogo: [Prodotto] {
        let base = ordinati
        guard let c = stato.clienteAttivo else { return filtrati(base) }
        let esiti = esitiCatalogo(c)
        let perCliente = stato.ricavato("prodotti-catalogo|\(c.id)") { () -> [Prodotto] in
            MotoreSchedaProdotto.ordina(base, esiti: esiti)
        }
        return filtrati(perCliente)
    }

    // MARK: - Il catalogo

    var catalogo: some View {
        let cliente = stato.clienteAttivo
        let esiti = esitiCatalogo(cliente)
        let elenco = elencoCatalogo
        let attuale = Self.schedaScelta(in: elenco, id: stato.prodottoSelezionato)
        return HStack(alignment: .top, spacing: BC.spazioLaterale) {
            colonnaCatalogo(elenco, sceltoId: attuale?.id, cliente: cliente, esiti: esiti)
                .frame(width: KC.larghezzaElenco)
                .entrataCascata(0, base: BC.baseCascata)
            Group {
                if let p = attuale {
                    schedaCatalogo(p, cliente: cliente, esito: cliente == nil ? nil : (esiti[p.id] ?? .inLinea))
                } else {
                    vuotoCatalogo
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(BC.margine)
        .altreAppApple()
        .onAppear {
            // «Apri il suo documento» guarda i documenti della Biblioteca
            stato.biblioteca.carica()
            eseguiRichiestaCatalogo()
        }
        .onChange(of: stato.richiestaCatalogo) { _ in eseguiRichiestaCatalogo() }
    }

    /// Le azioni del menu «Altro» della testata, sulla scheda scelta.
    func eseguiRichiestaCatalogo() {
        guard let r = stato.richiestaCatalogo else { return }
        stato.richiestaCatalogo = nil
        let p = scelto
        switch r {
        case .nuova: nuova()
        case .daiDocumenti: daiDocumenti = RichiestaSchedaDocumenti()
        case .modifica: if let p { modulo = p }
        case .aggiorna: if let p { daiDocumenti = RichiestaSchedaDocumenti(esistente: p) }
        case .simula: if let p { stato.simula(p) }
        case .elimina: if p != nil { confermaEliminazione = true }
        }
    }

    var vuotoCatalogo: some View {
        VStack(spacing: KC.spazioColonna) {
            Text(TestiCatalogo.nessunaScheda)
                .font(Tema.Apple.AltreApp.titoloScheda.fontLeggibile)
                .foregroundColor(Tema.Apple.AltreApp.testo)
            if !stato.inModoCliente {
                Button { nuova() } label: { Label("Nuova scheda", systemImage: "plus") }
                    .buttonStyle(.applePrimario)
                    .disabled(stato.solaLettura)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .entrataCascata(1, base: BC.baseCascata)
    }

    // MARK: - La colonna

    func colonnaCatalogo(_ elenco: [Prodotto], sceltoId: String?, cliente: Cliente?,
                         esiti: [String: EsitoProdottoCliente]) -> some View {
        VStack(alignment: .leading, spacing: KC.spazioColonna) {
            // I filtri di sempre in una riga: la ricerca e «Filtra ⌄» con canale e area
            HStack(spacing: KC.spazioFiltri) {
                CampoRicerca(testo: $ricerca, segnaposto: TestiCatalogo.cerca)
                MenuAzioni(voci: { vociFiltro }, taglia: .compatta) {
                    HStack(spacing: KC.spazioFreccia) {
                        Text(etichettaFiltro)
                        Image(systemName: "chevron.down")
                    }
                }
                .help("Filtra per canale e per area")
            }
            HStack {
                Text(cliente.map { TestiCatalogo.perCliente(StatoShell.nomeBreve($0)) } ?? TestiCatalogo.iProdotti)
                    .carattereApple(BC.etichetta)
                    .foregroundColor(BC.coloreEtichetta)
                    .lineLimit(1)
                Spacer()
                Text("\(elenco.count)")
                    .carattereApple(BC.etichetta)
                    .foregroundColor(BC.coloreEtichetta)
                    .monospacedDigit()
            }
            .accessibilityAddTraits(.isHeader)
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(elenco) { p in
                        Button { stato.prodottoSelezionato = p.id } label: {
                            rigaCatalogo(p, accesa: p.id == sceltoId, esito: cliente == nil ? nil : esiti[p.id])
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(BC.paddingLaterale)
        .frame(maxHeight: .infinity, alignment: .top)
        .superficieApple(BC.superficieLaterale, raggio: BC.raggioLaterale)
    }

    /// «Filtra», o i filtri accesi («Alleanza · Previdenza»).
    var etichettaFiltro: String {
        let parti = [stato.filtroCanaleProdotti?.nomeBreve, stato.filtroAreaProdotti?.nome].compactMap { $0 }
        return parti.isEmpty ? TestiCatalogo.filtra : parti.joined(separator: " · ")
    }

    var vociFiltro: [VoceMenuAzioni] {
        let s = stato
        var voci: [VoceMenuAzioni] = [
            .sezione("Canale"),
            .azione("Tutti i canali", spuntata: s.filtroCanaleProdotti == nil) { s.filtroCanaleProdotti = nil },
        ]
        for c in Canale.allCases {
            voci.append(.azione(c.nomeBreve, spuntata: s.filtroCanaleProdotti == c) { s.filtroCanaleProdotti = c })
        }
        voci.append(.separatore)
        voci.append(.sezione("Area"))
        voci.append(.azione("Tutte le aree", spuntata: s.filtroAreaProdotti == nil) { s.filtroAreaProdotti = nil })
        for a in [AreaPosizione.investimento, .risparmio, .previdenza, .protezione] {
            voci.append(.azione(a.nome, spuntata: s.filtroAreaProdotti == a) { s.filtroAreaProdotti = a })
        }
        return voci
    }

    func rigaCatalogo(_ p: Prodotto, accesa: Bool, esito: EsitoProdottoCliente?) -> some View {
        let forma = RoundedRectangle(cornerRadius: KC.raggioRiga, style: .continuous)
        return HStack(alignment: .top, spacing: KC.spazioFiltri) {
            RoundedRectangle(cornerRadius: KC.raggioQuadratino, style: .continuous)
                .fill(Colori.Analisi.area(p.area))
                .frame(width: KC.quadratinoArea, height: KC.quadratinoArea)
                .padding(.top, KC.spazioFiltri / 2)
            VStack(alignment: .leading, spacing: KC.spazioRiga) {
                Text(p.nome)
                    .carattereApple(KC.nomeRiga)
                    .foregroundColor(KC.testo)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(Self.riassuntoChiaro(p))
                    .carattereApple(KC.dettaglioRiga)
                    .foregroundColor(KC.secondario)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if p.daVerificare {
                    Text(TestiCatalogo.fonteDaVerificareBreve)
                        .carattereApple(KC.segnoRiga)
                        .foregroundColor(KC.daVerificare)
                }
                if let esito, esito != .inLinea {
                    Text(esito == .priorita ? TestiCatalogo.rispondePriorita : TestiCatalogo.rischiaPiu)
                        .carattereApple(KC.segnoRiga)
                        .foregroundColor(esito == .priorita ? KC.positivo : KC.negativo)
                }
            }
            .layoutPriority(1)
            Spacer(minLength: 4)
            EtichettaCanale(canale: p.canale, compatta: true)
        }
        .padding(KC.paddingRiga)
        .background(forma.fill(accesa ? KC.fondoRigaAccesa : Color.clear))
        .contentShape(forma)
    }

    /// La riga sotto il nome, senza sigle (migliorie d'uso 9): «Previdenza · costo 1,20% · rischio 3 su 7»; per la
    /// protezione solo «Protezione».
    static func riassuntoChiaro(_ p: Prodotto) -> String {
        guard p.area != .protezione else { return p.area.nome }
        return [p.area.nome,
                p.costoAnnuo.map { "costo \(Formati.percentuale($0))" } ?? "",
                p.sri.map { "rischio \($0) su 7" } ?? ""]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    // MARK: - La scheda

    func schedaCatalogo(_ p: Prodotto, cliente: Cliente?, esito: EsitoProdottoCliente?) -> some View {
        let c = cifre(p)
        let nome = cliente.map { StatoShell.nomeBreve($0) }
        let gestione = !stato.inModoCliente
        let frasi = MotoreSchedaProdotto.proposta(p)
        let documento = stato.condizioniInBiblioteca(p.id)
        return ScrollView {
            VStack(alignment: .leading, spacing: KC.spazioBlocchi) {
                testataCatalogo(p, nome: nome, esito: esito, gestione: gestione)
                    .entrataCascata(0, base: BC.baseCascata)
                AvvisoNuovoKID(prodotto: p)
                // «In una frase» c'è solo con un testo del consulente: nessuna frase automatica (decisione presa)
                if !frasi.vuota {
                    perChiCatalogo(frasi)
                        .entrataCascata(1, base: BC.baseCascata)
                }
                cifreCatalogo(p, cifre: c)
                    .entrataCascata(2, base: BC.baseCascata)
                condizioniCatalogo(p)
                    .entrataCascata(3, base: BC.baseCascata)
                piedeCatalogo(p, nome: nome, documento: documento)
                    .entrataCascata(4, base: BC.baseCascata)
                dettagliCatalogo(p, cifre: c, gestione: gestione)
                    .entrataCascata(5, base: BC.baseCascata)
            }
            .padding(KC.margineScheda)
        }
        // Un'altra scheda: torna in cima e i blocchi rientrano a cascata
        .id(p.id)
        .riavviaCascata(p.id)
    }

    func testataCatalogo(_ p: Prodotto, nome: String?, esito: EsitoProdottoCliente?, gestione: Bool) -> some View {
        HStack(alignment: .top, spacing: KC.spazioTestataFonte) {
            VStack(alignment: .leading, spacing: KC.spazioTestata) {
                Text([p.area.nome, p.tipologia].filter { !$0.isEmpty }.joined(separator: " · "))
                    .carattereApple(KC.occhiello)
                    .foregroundColor(Colori.Analisi.area(p.area))
                    .lineLimit(1)
                Text(p.nome)
                    .carattereApple(KC.titoloScheda)
                    .foregroundColor(KC.testo)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: KC.spazioFiltri) {
                    EtichettaCanale(canale: p.canale)
                    if let esito, let nome {
                        Pillola(testo: TestiCatalogo.esito(esito, nome: nome), tono: Self.tono(esito))
                    }
                }
            }
            .layoutPriority(1)
            Spacer(minLength: KC.spazioBlocchi)
            fonteCatalogo(p, gestione: gestione)
        }
    }

    static func tono(_ e: EsitoProdottoCliente) -> Pillola.Tono {
        switch e {
        case .priorita: return .ok
        case .inLinea: return .neutro
        case .oltreProfilo: return .errore
        }
    }

    /// La fonte a destra della testata: verificata (verde) o da verificare (arancio), con «Segna verificata oggi»
    /// (nascosto in modalità cliente, spento con l'archivio in sola lettura).
    func fonteCatalogo(_ p: Prodotto, gestione: Bool) -> some View {
        // Un KID nuovo arrivato dopo l'ultima verifica (o lo stesso giorno) chiede di rileggere la scheda
        let kidNuovo: Bool = stato.impattoProdotto(p).map { x in
            (p.verificatoIl ?? .distantPast) <= Calendar.current.startOfDay(for: x.il)
        } ?? false
        let segnata = segnateOggi.contains(p.id)
        let daVerificare = !segnata && (kidNuovo || p.daVerificare)
        return VStack(alignment: .trailing, spacing: KC.spazioTestata) {
            if segnata {
                Label(TestiCatalogo.segnataOggi, systemImage: "checkmark.seal.fill")
                    .carattereApple(KC.segnoRiga)
                    .foregroundColor(KC.positivo)
            } else if daVerificare {
                Label(kidNuovo ? TestiCatalogo.fonteKIDNuovo : TestiCatalogo.fonteDaVerificare,
                      systemImage: "exclamationmark.triangle.fill")
                    .carattereApple(KC.segnoRiga)
                    .foregroundColor(KC.daVerificare)
                if gestione {
                    Button(TestiCatalogo.segnaVerificata) {
                        var x = p
                        x.verificatoIl = Calendar.current.startOfDay(for: Date())
                        stato.salvaProdotto(x)
                        segnateOggi.insert(p.id)
                    }
                    .buttonStyle(.apple)
                    .disabled(stato.solaLettura)
                }
            } else if let d = p.verificatoIl {
                Label(TestiCatalogo.fonteVerificata(d), systemImage: "checkmark.seal.fill")
                    .carattereApple(KC.segnoRiga)
                    .foregroundColor(KC.positivo)
            } else {
                Text(TestiCatalogo.fonteMaiVerificata)
                    .carattereApple(KC.segnoRiga)
                    .foregroundColor(KC.daVerificare)
            }
        }
        .multilineTextAlignment(.trailing)
        .fixedSize()
    }

    /// «È per» / «Non è per»: due tessere affiancate con le frasi proposte da Prisma dai dati della scheda.
    func perChiCatalogo(_ f: MotoreSchedaProdotto.Proposta) -> some View {
        VStack(alignment: .leading, spacing: KC.spazioTestata) {
            HStack(alignment: .top, spacing: KC.spazioBlocchi) {
                colonnaPerChi(TestiCatalogo.ePer, righe: f.perChi, simbolo: "checkmark", colore: KC.positivo)
                colonnaPerChi(TestiCatalogo.nonEPer, righe: f.nonPerChi, simbolo: "xmark", colore: KC.negativo)
            }
            .fixedSize(horizontal: false, vertical: true)
            Text(TestiCatalogo.scritteDaPrisma)
                .carattereApple(KC.notaPiede)
                .foregroundColor(KC.secondario)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func colonnaPerChi(_ titolo: String, righe: [String], simbolo: String, colore: Color) -> some View {
        VStack(alignment: .leading, spacing: KC.spazioRigaPerChi) {
            Text(titolo)
                .carattereApple(KC.occhiello)
                .foregroundColor(colore)
            if righe.isEmpty {
                Text("—")
                    .carattereApple(KC.rigaPerChi)
                    .foregroundColor(KC.secondario)
            } else {
                ForEach(righe, id: \.self) { r in
                    HStack(alignment: .firstTextBaseline, spacing: KC.spazioFiltri) {
                        Image(systemName: simbolo)
                            .carattereApple(KC.segnoRiga)
                            .foregroundColor(colore)
                        Text(r)
                            .carattereApple(KC.rigaPerChi)
                            .foregroundColor(KC.testo)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(KC.paddingTile)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(KC.superficieTile)
    }

    /// Le cifre: il peso dei costi in parole, «Quanto rischia» e «Per quanto tempo». Per la protezione solo «Per quanto
    /// tempo» (decisione 63-d: niente premio indicativo fisso; la stima dalle polizze in archivio resta da fare).
    @ViewBuilder func cifreCatalogo(_ p: Prodotto, cifre c: CifreScheda) -> some View {
        if p.area.proiettabile {
            HStack(alignment: .top, spacing: KC.spazioBlocchi) {
                PesoCostiProdotto(titolo: TestiCatalogo.suDiecimila, versato: c.versato, netto: c.netto, costi: c.impatto,
                                  coloreGuadagno: Colori.Analisi.area(p.area), riga: true, sottotitolo: TestiCatalogo.allaFine)
                TesseraRischio(sri: p.sri, chiara: true)
                    .frame(width: KC.larghezzaTesseraPiccola)
                tesseraTempoCatalogo(p)
                    .frame(width: KC.larghezzaTesseraPiccola)
            }
            .fixedSize(horizontal: false, vertical: true)
        } else {
            HStack(alignment: .top, spacing: KC.spazioBlocchi) {
                tesseraTempoCatalogo(p)
                    .frame(width: KC.larghezzaTesseraPiccola)
                Spacer(minLength: 0)
            }
        }
    }

    func tesseraTempoCatalogo(_ p: Prodotto) -> some View {
        VStack(alignment: .leading, spacing: Tema.Misura.Prodotti.spazioTessera) {
            Text(TestiCatalogo.perQuantoTempo)
                .font(Tema.Testo.Prodotti.etichetta)
                .foregroundColor(KC.secondario)
                .lineLimit(1)
            Text(p.periodoConsigliato.map { TestiCatalogo.anni($0) } ?? "—")
                .carattereApple(KC.cifraTessera)
                .foregroundColor(KC.testo)
                .lineLimit(1)
            Text(p.periodoConsigliato == nil ? TestiCatalogo.nonIndicato : TestiCatalogo.almeno)
                .carattereApple(KC.notaTessera)
                .foregroundColor(KC.secondario)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(KC.paddingTile)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(KC.superficieTile)
    }

    /// Tre condizioni in chiaro: garanzia, uscita prima, tasse (le righe vuote non ci sono).
    @ViewBuilder func condizioniCatalogo(_ p: Prodotto) -> some View {
        let tasse = p.aliquotaFiscale.map { TestiCatalogo.tasseSulRendimento($0) } ?? ""
        let righe: [(String, String)] = [(TestiCatalogo.garanzia, p.garanzie),
                                         (TestiCatalogo.uscitaPrima, p.liquidabilita),
                                         (TestiCatalogo.tasse, tasse)]
            .filter { !$0.1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        if !righe.isEmpty {
            VStack(spacing: 0) {
                ForEach(Array(righe.enumerated()), id: \.offset) { voce in
                    RigaDato(voce.element.0, voce.element.1)
                }
            }
            .padding(KC.paddingFrase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .superficieApple(KC.superficieCard)
        }
    }

    /// Il piede: «Proponi a …» e «Confronta con quello che ha» con un cliente scelto, altrimenti «Metti su un cliente…»;
    /// «Apri il suo documento» se la scheda ha un documento nella Biblioteca; a destra la nota grigia.
    func piedeCatalogo(_ p: Prodotto, nome: String?, documento: DocumentoBiblioteca?) -> some View {
        HStack(alignment: .center, spacing: KC.spazioPiede) {
            if let nome {
                Button(TestiCatalogo.proponiA(nome)) { stato.proponi(p, apri: false) }
                    .buttonStyle(.applePrimarioGrande)
                    .disabled(stato.solaLettura)
                    .help("Mette il prodotto fra le proposte di \(nome), con le condizioni della scheda: la completi in Posizioni")
                // Migliorie d'uso 64: «Simula e confronta» › «Due a confronto», la scheda contro quello che ha
                Button(TestiCatalogo.confronta) {
                    #if os(macOS)
                    stato.confrontaProdottoInSimula(p)
                    #else
                    stato.apri(.confronti)
                    #endif
                }
                    .buttonStyle(.appleGrande)
            } else {
                Button(TestiCatalogo.mettiSuCliente) {
                    sulCliente = RichiestaProdottoCliente(prodottoId: p.id, stato: .proposta, clienteScelto: true)
                }
                .buttonStyle(.appleGrande)
                .disabled(stato.solaLettura)
                .help("Proposta o posizione in essere per un cliente: scrivi solo importi e durata")
            }
            if let d = documento {
                Button(TestiCatalogo.apriDocumento) { stato.apriCondizioniInBiblioteca(p.id) }
                    .buttonStyle(.appleGrande)
                    .help("Apri «\(d.titolo)» nella Biblioteca")
            }
            Spacer(minLength: KC.spazioBlocchi)
            Text(TestiCatalogo.notaPiede)
                .carattereApple(KC.notaPiede)
                .foregroundColor(KC.secondario)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: KC.larghezzaNotaPiede, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// «Tutti i dettagli ⌄»: le percentuali di oggi, le condizioni complete, la fonte, le condizioni del contratto, lo
    /// storico, «Dove è usata» e la nota di metodo. Montati solo quando sono aperti (la memoria resta quella di prima).
    @ViewBuilder func dettagliCatalogo(_ p: Prodotto, cifre c: CifreScheda, gestione: Bool) -> some View {
        let aperti = stato.dettagliProdottoAperti
        VStack(alignment: .leading, spacing: 16) {
            Button { stato.dettagliProdottoAperti.toggle() } label: {
                HStack(spacing: KC.spazioFreccia) {
                    Text(TestiCatalogo.tuttiDettagli)
                    Image(systemName: aperti ? "chevron.up" : "chevron.down")
                }
            }
            .buttonStyle(.appleSobrio)
            if aperti {
                if p.area.proiettabile {
                    tessere(p, parametri: c.parametri, dueParti: c.parametri.gestione != nil, composizione: c.composizione)
                }
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: Misure.SchedaProdotto.spazioAffiancate) {
                        pannelloCondizioni(p, cifre: c)
                        pannelloFonte(p, gestione: gestione)
                    }
                    .frame(idealWidth: Misure.SchedaProdotto.affiancate, maxWidth: .infinity, alignment: .leading)
                    VStack(alignment: .leading, spacing: Misure.SchedaProdotto.spazioImpilate) {
                        pannelloCondizioni(p, cifre: c)
                        pannelloFonte(p, gestione: gestione)
                    }
                }
                condizioni(p, gestione: gestione)
                StoricoAggiornamentiProdotto(prodotto: p)
                doveUsata(c.usi)
                NotaMetodo(testo: "I costi della scheda entrano in proposte, simulazioni e confronti così come sono: tienili allineati al KID in vigore.")
                    .help("L'ISC di una forma pensionistica non è una commissione di gestione: inserisci i costi che il modello applica davvero.")
            }
        }
    }
}
#endif
