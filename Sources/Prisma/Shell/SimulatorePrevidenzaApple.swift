import SwiftUI

// Analisi 360 › Previdenza: il simulatore dal vivo (Design/template-apple-specifica.md §4.3.2, riferimenti
// analisi-agenda A06-A12, A23-A24). L'area si espande in un dettaglio 940×540:
//
//   PREVIDENZA · MARCO BIANCHI
//   Quanto mettere da parte per la pensione
//   ╭────╮   Pensione pubblica   Desiderata   Divario al mese
//   │ 42%│   1.400 €             2.200 €      800 €
//   │del │   Versamento mensile nei piani di previdenza
//   │div.│   300 €
//   ╰────╯   ───────●──────────────   oggi 150 € al mese · 150 € in più
//            Rendita in più al mese   Capitale a 67 anni   Risparmio fiscale l'anno
//   Ipotesi: …
//   [Salva come proposta] [Chiedi a Vera di spiegarlo]                    [Alleanza|Indipendente] (canale)
//
// Sul Mac (migliorie d'uso 45, Design/uso/gruppo-08.md §45, dettaglio 940×560): lo scarto «+150 € al mese rispetto a
// oggi» a destra del valore, il segno «oggi» sotto il binario, al posto delle ipotesi scritte la frase prima e dopo
// («Oggi Marco versa… Con 300 € al mese arriva al 61%…») e la riga «LE IPOTESI» con il rendimento da scegliere (quello
// dell'analisi e mezzo punto sopra e sotto, solo nel simulatore) e l'aliquota (dal reddito della scheda o, se manca,
// da scegliere); le ipotesi intere restano nel suggerimento della riga. Nel piede «Sono stime, non garanzie.».
//
// - Le cifre vengono da MotoreSimulatoriAnalisi (stessa proiezione di MotoreAnalisi.previdenza) e dalla
//   deducibilità di DeducibilitaPrevidenza con l'IRPEF per scaglioni: nessuna formula del template.
// - Ricalcolo leggero: la cornice (ipotesi, versamento teorico per il massimo del cursore, contributi del datore)
//   si calcola una volta per disegno di SimulatorePrevidenzaApple; a ogni passo del cursore il corpo rifà solo
//   una proiezione del montante e l'IRPEF.
// - Movimento: all'apertura le cifre contano in 1,0 s; trascinando cambiano subito e l'anello insegue in 1,4 s.
//   «Riduci movimento» e istantanee: tutto nello stato finale (lo fanno NumeroCheConta e Anello).

private typealias SP = Tema.Apple.SimulatoriAnalisi.Previdenza

/// Il simulatore della previdenza per `cliente`, sulle ipotesi della sua Analisi 360 (`analisi`).
struct SimulatorePrevidenzaApple: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente
    let analisi: Binding<Analisi360>

    var body: some View {
        let _ = ContaCorpi.segna()
        let i = analisi.wrappedValue.previdenza
        // Una volta per disegno della cornice (il cursore non la rifà): serve il versamento teorico per il massimo
        let e = MotoreAnalisi.previdenza(i)
        let piani = stato.posizioniCliente(cliente.id)
        let fisco = DeducibilitaPrevidenza(piani: piani)
        let quadro = QuadroSimulatorePrevidenza(
            clienteId: cliente.id, nome: cliente.nome, ipotesi: i, anni: e.anniAccumulo,
            versamentoTeorico: e.versamentoTeorico, datore: fisco.datore,
            reddito: cliente.profilo.redditoLordoAnnuo, canale: Self.canaleIniziale(cliente, piani: piani),
            nomeBreve: StatoShell.nomeBreve(cliente),
            coperturaOggi: e.divario > 0 ? min(1, max(0, e.integrazione / e.divario)) : 1
        )
        return CorpoSimulatorePrevidenzaApple(
            quadro: quadro, iniziale: SimulatoriAnalisiApple.valoreIniziale(stato, .previdenza) ?? i.versamentoMensile
        )
    }

    /// Il canale proposto per la proposta: quello dei piani di previdenza in essere se è uno solo, altrimenti il
    /// primo canale del cliente (Alleanza se non ne ha).
    private static func canaleIniziale(_ c: Cliente, piani: [Posizione]) -> Canale {
        let canali = Set(piani.filter { $0.area == .previdenza && $0.stato == .inEssere }.map(\.canale))
        if canali.count == 1, let unico = canali.first { return unico }
        return c.canali.first ?? .alleanza
    }
}

/// Ciò che non cambia mentre si trascina il cursore.
struct QuadroSimulatorePrevidenza {
    let clienteId: String
    let nome: String
    let ipotesi: IpotesiPrevidenza
    let anni: Int
    let versamentoTeorico: Double?
    /// Contributi annui del datore di lavoro (contano nel limite di deducibilità).
    let datore: Double
    let reddito: Double?
    let canale: Canale
    /// Il nome proprio, per la frase prima e dopo.
    let nomeBreve: String
    /// Quota del divario coperta con il versamento di oggi e il rendimento dell'analisi (0…1).
    let coperturaOggi: Double

    /// true se la scheda ha il reddito lordo (il risparmio fiscale con l'IRPEF per scaglioni).
    var conReddito: Bool { (reddito ?? 0) > 0 }

    /// Da 0 a max(900; versamento teorico·1,2 arrotondato a 50; versamento di oggi), passo 10 (§4.9.9).
    func massimo(_ iniziale: Double) -> Double {
        let p = SP.self
        let teorico = versamentoTeorico ?? 0
        let daFabbisogno = (teorico * p.margineFabbisogno / p.arrotondamento).rounded(.up) * p.arrotondamento
        let daOggi = (max(ipotesi.versamentoMensile, iniziale) / p.passo).rounded(.up) * p.passo
        return max(p.massimoMinimo, daFabbisogno, daOggi)
    }
}

private struct CorpoSimulatorePrevidenzaApple: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.statoDettaglioApple) private var dettaglio
    let quadro: QuadroSimulatorePrevidenza
    private let massimo: Double
    /// Il versamento mensile del cursore (parte da quello delle ipotesi).
    @State private var versamento: Double
    /// Da quando il cursore si muove le cifre cambiano subito, senza contare.
    @State private var mosso = false
    @State private var canale: Canale
    /// Migliorie d'uso 45: il rendimento scelto (solo nel simulatore, non cambia l'analisi) e l'aliquota scelta quando
    /// manca il reddito. La copertura con il versamento di oggi si rifà solo quando cambia il rendimento.
    @State private var rendimento: Double
    @State private var aliquota: Double
    @State private var coperturaOggi: Double

    init(quadro: QuadroSimulatorePrevidenza, iniziale: Double) {
        self.quadro = quadro
        let m = quadro.massimo(iniziale)
        massimo = m
        _versamento = State(initialValue: min(max(0, iniziale), m))
        _canale = State(initialValue: quadro.canale)
        let r = quadro.ipotesi.rendimentoReale
        #if os(macOS)
        // Il rendimento dell'analisi come compare fra le scelte (lo stesso valore esatto, mai sotto 0)
        _rendimento = State(initialValue: MotoreSimulatoriAnalisi.rendimentiDaScegliere(r)
            .first { abs($0 - r) < MotoreSimulatoriAnalisi.toleranzaRendimento } ?? r)
        #else
        // Su iPhone e iPad non c'è scelta: il rendimento dell'analisi com'è scritto
        _rendimento = State(initialValue: r)
        #endif
        _aliquota = State(initialValue: MotoreSimulatoriAnalisi.aliquotaIniziale)
        _coperturaOggi = State(initialValue: quadro.coperturaOggi)
    }

    /// Le ipotesi del calcolo con il rendimento scelto.
    private var ipotesiScelte: IpotesiPrevidenza {
        var q = quadro.ipotesi
        q.rendimentoReale = rendimento
        return q
    }

    /// Un passo del calcolo: con il reddito l'IRPEF per scaglioni, senza reddito (sul Mac) l'aliquota scelta.
    private func passo(_ v: Double) -> MotoreSimulatoriAnalisi.PassoPrevidenza {
        #if os(macOS)
        if !quadro.conReddito {
            return MotoreSimulatoriAnalisi.previdenza(ipotesiScelte, versamento: v, datore: quadro.datore, aliquota: aliquota)
        }
        #endif
        return MotoreSimulatoriAnalisi.previdenza(ipotesiScelte, versamento: v, datore: quadro.datore, reddito: quadro.reddito)
    }

    var body: some View {
        let _ = ContaCorpi.segna()
        let s = Tema.Apple.SimulatoriAnalisi.self
        let colore = SP.colore
        // Il solo calcolo di ogni passo: una proiezione del montante e l'IRPEF
        let p = passo(versamento)
        return VStack(alignment: .leading, spacing: 0) {
            TestataSimulatoreApple(etichetta: "Previdenza · \(quadro.nome)",
                                   titolo: "Quanto mettere da parte per la pensione", colore: colore)
            HStack(alignment: .center, spacing: s.spazioAnello) {
                AnelloSimulatoreApple(frazione: p.copertura, colore: colore,
                                      sotto: p.divario > 0 ? "del divario" : "nessun divario", mosso: mosso)
                colonna(p, colore: colore)
            }
            .padding(.top, s.sopraCorpo)
            Spacer(minLength: 0)
            #if os(macOS)
            FraseSimulatoreApple(pezzi: TestiSimulatoriAnalisi.previdenza(
                nome: quadro.nomeBreve, oggi: quadro.ipotesi.versamentoMensile, versamento: versamento,
                coperturaOggi: coperturaOggi, passo: p))
                .padding(.top, s.sopraFrase)
            scelte(p)
                .padding(.top, s.sopraScelte)
            #else
            IpotesiSimulatoreApple(testo: ipotesi(p))
                .padding(.top, s.sopraIpotesi)
            #endif
            piede
                .padding(.top, s.sopraPiede)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onChange(of: versamento) { _ in
            if !mosso { mosso = true }
        }
        .onChange(of: rendimento) { r in
            if !mosso { mosso = true }
            // Con il rendimento dell'analisi la copertura di oggi è quella del quadro; altrimenti una sola proiezione
            coperturaOggi = abs(r - quadro.ipotesi.rendimentoReale) < MotoreSimulatoriAnalisi.toleranzaRendimento
                ? quadro.coperturaOggi
                : passo(quadro.ipotesi.versamentoMensile).copertura
        }
        .onChange(of: aliquota) { _ in
            if !mosso { mosso = true }
        }
    }

    // MARK: Parti

    private func colonna(_ p: MotoreSimulatoriAnalisi.PassoPrevidenza, colore: Color) -> some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        let i = quadro.ipotesi
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: s.spazioCifre) {
                CifraSimulatoreApple(titolo: "Pensione pubblica", valore: i.pensionePubblica, indice: 0,
                                     aiuto: "Netta al mese, dalle ipotesi dell'analisi (estratto INPS o stima contributiva)")
                CifraSimulatoreApple(titolo: "Desiderata", valore: i.redditoDesiderato, indice: 1,
                                     aiuto: "Reddito netto desiderato in pensione, al mese, in euro di oggi")
                CifraSimulatoreApple(titolo: "Divario al mese", valore: p.divario, indice: 2, colore: colore)
            }
            #if os(macOS)
            cursoreMac(colore: colore)
                .padding(.top, s.sopraCursore)
            #else
            VStack(alignment: .leading, spacing: s.spazioEtichettaCursore) {
                Text("Versamento mensile nei piani di previdenza")
                    .carattereApple(s.etichettaCursore)
                    .foregroundColor(s.coloreEtichetta)
                CursoreApple(valore: $versamento, intervallo: 0...massimo, passo: SP.passo,
                             etichetta: "Versamento mensile nei piani di previdenza", formato: .euro,
                             carattereValore: s.valoreCursore, coloreValore: colore)
                    .frame(maxWidth: s.larghezzaCursore)
                    .padding(.vertical, s.margineCursore)
                    .disabled(quadro.anni <= 0)
                Text(scarto)
                    .carattereApple(s.etichettaCifra)
                    .foregroundColor(s.coloreEtichetta)
                    .lineLimit(1)
            }
            .padding(.top, s.sopraCursore)
            #endif
            HStack(alignment: .top, spacing: s.spazioCifre) {
                CifraSimulatoreApple(titolo: "Rendita in più al mese", valore: p.integrazione, indice: 3, mosso: mosso,
                                     aiuto: "Il montante dei piani diviso per i \(i.anniIntegrazione) anni di integrazione")
                CifraSimulatoreApple(titolo: "Capitale a \(i.etaPensione) anni", valore: p.montante, indice: 4, mosso: mosso,
                                     aiuto: "Montante dei piani alla pensione, in euro di oggi")
                CifraSimulatoreApple(titolo: "Risparmio fiscale l'anno", valore: p.risparmioFiscale, indice: 5, mosso: mosso,
                                     colore: s.colorePositivo,
                                     aiuto: "IRPEF risparmiata deducendo \(Formati.euro(p.deducibili)) di versamenti in un anno")
            }
            .padding(.top, s.sopraRisultati)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    #if os(macOS)
    /// Migliorie d'uso 45: l'etichetta, il valore grande con lo scarto a destra sulla stessa riga, il binario e sotto
    /// il segno «oggi» nella posizione del versamento di oggi.
    private func cursoreMac(colore: Color) -> some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        let oggi = quadro.ipotesi.versamentoMensile
        let destra = quadro.anni <= 0 ? "Nessun anno di accumulo: l'età di pensione è già raggiunta"
            : TestiSimulatoriAnalisi.scarto(versamento: versamento, oggi: oggi)
        return VStack(alignment: .leading, spacing: s.spazioEtichettaCursore) {
            Text("Versamento mensile nei piani di previdenza")
                .carattereApple(s.etichettaCursore)
                .foregroundColor(s.coloreEtichetta)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: s.spazioScarto) {
                    Text(FormatoCifra.euro.testo(versamento, finale: versamento))
                        .monospacedDigit()
                        .carattereApple(s.valoreCursore)
                        .foregroundColor(colore)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                    Spacer(minLength: 0)
                    Text(destra)
                        .carattereApple(s.scarto)
                        .foregroundColor(s.coloreScarto)
                        .lineLimit(1)
                        .minimumScaleFactor(s.riduzioneScelte)
                }
                CursoreApple(valore: $versamento, intervallo: 0...massimo, passo: SP.passo,
                             etichetta: "Versamento mensile nei piani di previdenza")
                    .padding(.top, s.sottoValoreCursore)
                    .disabled(quadro.anni <= 0)
                SegnoOggiCursore(frazione: massimo > 0 ? oggi / massimo : 0)
            }
            .frame(maxWidth: s.larghezzaCursore)
        }
    }

    /// «LE IPOTESI»: il rendimento da scegliere, l'aliquota (dal reddito o da scegliere) e il limite di deduzione; le
    /// ipotesi intere nel suggerimento della riga.
    private func scelte(_ p: MotoreSimulatoriAnalisi.PassoPrevidenza) -> some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return HStack(alignment: .center, spacing: s.spazioScelte) {
            EtichettaIpotesiSimulatoreApple()
            HStack(alignment: .center, spacing: s.spazioGruppoScelte) {
                TestoIpotesiSimulatoreApple("Rendimento l'anno")
                    .fixedSize()
                SegmentatoPillola(selezione: $rendimento,
                                  valori: MotoreSimulatoriAnalisi.rendimentiDaScegliere(quadro.ipotesi.rendimentoReale),
                                  titolo: { Formati.percentuale($0) }, compatto: true)
                    .fixedSize()
                    .help("Rendimento netto reale l'anno: quello delle ipotesi dell'analisi e mezzo punto sopra e sotto. Vale solo qui, l'analisi non cambia")
            }
            if let r = quadro.reddito, r > 0 {
                TestoIpotesiSimulatoreApple(TestiSimulatoriAnalisi.aliquotaDalReddito(r))
            } else {
                HStack(alignment: .center, spacing: s.spazioGruppoScelte) {
                    TestoIpotesiSimulatoreApple("Aliquota")
                        .fixedSize()
                    SegmentatoPillola(selezione: $aliquota, valori: MotoreSimulatoriAnalisi.aliquoteDaScegliere,
                                      titolo: { Formati.percentuale($0) }, compatto: true)
                        .fixedSize()
                        .help("Aliquota IRPEF marginale per il risparmio fiscale, finché manca il reddito nella scheda")
                    TestoIpotesiSimulatoreApple("finché manca il reddito")
                }
            }
            Spacer(minLength: 0)
            TestoIpotesiSimulatoreApple(TestiSimulatoriAnalisi.deduzione)
                .layoutPriority(-1)
        }
        .help(ipotesi(p))
    }
    #endif

    /// «oggi 150 € al mese · 150 € in più», oppure perché il cursore è fermo.
    private var scarto: String {
        let oggi = quadro.ipotesi.versamentoMensile
        if quadro.anni <= 0 { return "Nessun anno di accumulo: l'età di pensione è già raggiunta" }
        let d = versamento - oggi
        let base = "oggi \(Formati.euro(oggi)) al mese"
        if abs(d) < 0.5 { return base }
        return base + " · \(Formati.euro(abs(d))) \(d > 0 ? "in più" : "in meno")"
    }

    /// Le ipotesi vere del calcolo (§4.3.2: «la riga delle ipotesi elenca le ipotesi vere del motore»).
    private func ipotesi(_ p: MotoreSimulatoriAnalisi.PassoPrevidenza) -> String {
        let i = quadro.ipotesi
        let anni = quadro.anni == 1 ? "1 anno" : "\(quadro.anni) anni"
        var parti = [
            "Ipotesi: rendimento netto reale \(Formati.percentuale(rendimento)) l'anno, costante; montante dei piani oggi \(Formati.euro(i.capitale)); \(anni) di versamenti fino a \(i.etaPensione) anni, poi integrazione per \(i.anniIntegrazione) anni senza rendimento; in euro di oggi."
        ]
        let limite = Formati.euro(RegoleFiscali.limiteDeducibilita)
        let datore = quadro.datore >= 0.5 ? ", compresi i contributi del datore (\(Formati.euro(quadro.datore)) l'anno)" : ""
        if let r = quadro.reddito, r > 0 {
            parti.append("Fisco: versamenti deducibili fino a \(limite) l'anno\(datore), IRPEF per scaglioni su un reddito lordo di \(Formati.euro(r)).")
        } else {
            #if os(macOS)
            parti.append("Fisco: deducibili fino a \(limite) l'anno\(datore); risparmio con l'aliquota scelta (\(Formati.percentuale(aliquota))) finché manca il reddito lordo nella scheda del cliente.")
            #else
            parti.append("Fisco: deducibili fino a \(limite) l'anno\(datore); il risparmio compare con il reddito lordo nella scheda del cliente.")
            #endif
        }
        parti.append("TFR e contributi del datore non entrano nel montante.")
        return parti.joined(separator: " ")
    }

    private var piede: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        let delta = versamento - quadro.ipotesi.versamentoMensile
        let salvabile = !stato.solaLettura && delta >= SP.passo / 2
        return HStack(alignment: .center, spacing: s.spazioPiede) {
            Button("Salva come proposta", action: salva)
                .buttonStyle(.applePrimarioGrande)
                .disabled(!salvabile)
                .help(salvabile
                      ? "Crea in Posizioni una proposta di \(Formati.euro(delta)) al mese in più, sul canale scelto"
                      : "Sposta il cursore oltre il versamento di oggi per salvare una proposta")
            Button("Chiedi a Vera di spiegarlo", action: chiediVera)
                .buttonStyle(.appleGrande)
                .disabled(stato.veraInCorso)
            #if os(macOS)
            AvvisoSimulatoreApple()
            #endif
            Spacer(minLength: s.spazioPiede)
            CanaleSimulatoreApple(canale: $canale)
        }
    }

    // MARK: Azioni

    /// Il versamento in più diventa una proposta di previdenza (bozza) nel dossier, sul canale scelto: le
    /// proposte aperte entrano già nella sintesi dell'area («Con la proposta»).
    private func salva() {
        let delta = (versamento - quadro.ipotesi.versamentoMensile).rounded()
        guard !stato.solaLettura, delta > 0 else { return }
        var p = Posizione(clienteId: quadro.clienteId, canale: canale, stato: .proposta, area: .previdenza,
                          nome: "Piano di previdenza complementare")
        p.esito = .bozza
        p.tipologia = "Dal simulatore di Analisi 360"
        p.contraente = quadro.nome
        p.assicurato = quadro.nome
        p.premio = delta
        p.frequenza = .mensile
        p.note = "Proposta dal simulatore: \(Formati.euro(versamento)) al mese in tutto, \(Formati.euro(delta)) in più di oggi. Completa prodotto, costi e rendimento."
        // Migliorie d'uso 45: la proposta non porta il rendimento scelto, la nota lo ricorda se diverso dall'analisi
        if abs(rendimento - quadro.ipotesi.rendimentoReale) >= MotoreSimulatoriAnalisi.toleranzaRendimento {
            p.note += " Rendimento ipotizzato nel simulatore \(Formati.percentuale(rendimento)) l'anno."
        }
        stato.salvaPosizione(p)
        let testo = "Proposta salvata nel dossier di \(quadro.nome)"
        let s = stato
        if let d = dettaglio {
            d.chiudi(poi: { s.mostraAvviso(testo) })
        } else {
            s.mostraAvviso(testo)
        }
    }

    /// Chiude subito il dettaglio, apre Vera e manda la domanda sulla pensione dopo 0,7 s.
    private func chiediVera() {
        let s = stato
        dettaglio?.chiudi(subito: true)
        s.apri(.vera)
        DispatchQueue.main.asyncAfter(deadline: .now() + Tema.Apple.SimulatoriAnalisi.ritardoDomandaVera) {
            s.chiediVera(SpuntoVera.pensione.domanda, spunto: .pensione)
        }
    }
}
