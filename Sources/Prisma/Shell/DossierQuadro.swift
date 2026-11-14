#if os(macOS)
import SwiftUI

// Migliorie d'uso 5 «Il dossier parte dal quadro del cliente» (Design/uso/gruppo-01.md §5), solo sul Mac. La Panoramica
// del dossier apre sulle quattro aree del cliente (le stesse cifre e gli stessi testi delle card di Analisi 360, da
// `stato.aree360`, in cache) e tiene i dati da completare in una riga in fondo alla card:
//
//   ┌ IL QUADRO DI GIULIA ─── Il cliente in 30 secondi ›  Apri Analisi 360 › ┐┌ DA FARE PER GIULIA ③ ── Apri tutto › ┐
//   │ ┌ ◎ 72%  PREVIDENZA ─────────┐ ┌ ◎ 64%  PROTEZIONE ─────────┐         ││ ○ ● Rinnovo polizza casa              │
//   │ │  72% del divario coperto   │ │  64% della famiglia protetta│         │└───────────────────────────────────────┘
//   │ └────────────────────────────┘ └─────────────────────────────┘         │┌ PROSSIMO INCONTRO ────────────────────┐
//   │ ┌ ◎ 92%  INVESTIMENTI ───────┐ ┌ ◎ 3,5 mesi  RISPARMIO ──────┐         │└───────────────────────────────────────┘
//   │ └────────────────────────────┘ └─────────────────────────────┘         │┌ DA RICORDARE ─────────────────────────┐
//   │ DATI PER L'ANALISI ▬▬▬▬▬▬▭▭ 84%                    3 da completare ›   │└───────────────────────────────────────┘
//   └─────────────────────────────────────────────────────────────────────────┘
//
// - Un clic su un riquadro apre Analisi 360 con il dettaglio di quell'area già aperto (`dettaglioArea360DaAprire`,
//   consumato da PresentatoreAree360); «Apri Analisi 360 ›» apre la griglia delle aree.
// - La riga «Dati per l'analisi» apre l'elenco dei dati da completare in un dettaglio che nasce dalla riga (il
//   presentatore del dossier, DossierObiettivi.swift), con «Completa» e la croce «non pertinente» come prima.
// - In modalità cliente il quadro resta; la riga dei dati e «Da fare» no (strumenti del consulente).
// Valori in `Tema.Apple.Clienti.Panoramica.Quadro` (DesignSystem/Apple/Tema.Apple+Dossier.swift).

/// L'id e la misura del dettaglio «Dati per l'analisi» nato dalla riga del quadro.
enum QuadroDossier {
    static let idDati = "dossier-dati-analisi"

    /// 680 × (196 + 62 per voce), fra 320 e 640.
    static func misuraDati(_ k: CompletezzaCliente?) -> CGSize {
        let q = Tema.Apple.Clienti.Panoramica.Quadro.self
        let voci = CGFloat(max(1, k?.daCompletare.count ?? 1))
        let altezza = min(q.altezzaMassimaDettaglio,
                          max(q.altezzaMinimaDettaglio, q.altezzaBaseDettaglio + voci * q.altezzaVoceDettaglio))
        return CGSize(width: q.larghezzaDettaglio, height: altezza)
    }
}

/// I testi del quadro del cliente (dal template, `panoramicaHTML()` e `apriDati()`).
enum TestiQuadroDossier {
    static func titolo(_ nome: String) -> String { "Il quadro di \(nome)" }
    static let apriAnalisi = "Apri Analisi 360 ›"
    static let trentaSecondi = "Il cliente in 30 secondi ›"
    static func aiutoTrentaSecondi(_ nome: String) -> String { "Apre Vera e ti racconta \(nome) a voce in 30 secondi" }
    static func aiutoArea(_ area: String) -> String { "Apri \(area) in Analisi 360" }
    static func daCompletare(_ n: Int) -> String { "\(n) da completare ›" }
    static let datiCompleti = "Dati completi"
    static let aiutoDati = "Apri l’elenco dei dati da completare"
    static func titoloDettaglio(_ nome: String) -> String { "Dati per l'analisi · \(nome)" }
    static func completi(_ percentuale: Int) -> String { "Completi al \(percentuale)%" }
    static let frase = "Più dati ci sono, meno stime fa Prisma. Questi sono quelli che mancano."
    static let tuttiCi = "Tutti i dati ci sono: nessuna stima in uso."
    static func daFare(_ nome: String) -> String { "Da fare per \(nome)" }
    static let mese = "mese"
    static let mesi = "mesi"
}

extension StatoShell {
    /// Apre Analisi 360 sulla griglia delle aree del cliente attivo e, con `area`, con il dettaglio di quell'area già
    /// aperto (lo apre PresentatoreAree360 appena c'è).
    func apriAnalisi360DalQuadro(area: AreaAnalisi?) {
        if areaAnalisi != nil { areaAnalisi = nil }
        scegliStrumentoAnalisi(nil)
        dettaglioArea360DaAprire = area
        apri(.analisi360)
    }
}

// MARK: - Il quadro

/// La card «Il quadro di <Nome>»: testata, i quattro riquadri delle aree e, fuori dalla modalità cliente, la riga
/// «Dati per l'analisi».
struct QuadroDossierApple: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.statoDettaglioApple) private var dettaglio
    let cliente: Cliente
    /// nil in modalità cliente: la riga dei dati non c'è.
    let completezza: CompletezzaCliente?

    private typealias Q = Tema.Apple.Clienti.Panoramica.Quadro
    private typealias P = Tema.Apple.Clienti.Panoramica

    /// Le aree in due righe, nell'ordine di Analisi 360.
    private static let righe: [[AreaAnalisi]] = [[.previdenza, .protezione], [.investimenti, .risparmio]]

    var body: some View {
        let _ = ContaCorpi.segna()
        // In cache per cliente (DerivatiDati): il body non rifà i motori
        let aree = stato.aree360(cliente.id)
        let nome = TestiTraguardi.primoNome(cliente.nome)
        return VStack(alignment: .leading, spacing: 0) {
            testata(nome)
            VStack(spacing: Q.spazioGriglia) {
                ForEach(0..<Self.righe.count, id: \.self) { r in
                    HStack(spacing: Q.spazioGriglia) {
                        ForEach(Self.righe[r], id: \.self) { a in
                            TesseraAreaDossier(area: a, sintesi: aree.sintesi(a),
                                               indice: r * 2 + (Self.righe[r].firstIndex(of: a) ?? 0),
                                               apri: { stato.apriAnalisi360DalQuadro(area: a) })
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.top, Q.sopraGriglia)
            if let k = completezza {
                RigaDatiAnalisi(completezza: k) {
                    dettaglio?.apri(QuadroDossier.idDati, misura: QuadroDossier.misuraDati(k))
                }
                .origineDettaglio(id: QuadroDossier.idDati)
                .padding(.top, Q.sopraDati)
            }
        }
        .padding(Q.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(P.superficie)
    }

    private func testata(_ nome: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Q.spazioTestata) {
            Text(TestiQuadroDossier.titolo(nome))
                .carattereApple(P.titolo)
                .foregroundColor(P.coloreTitolo)
                .lineLimit(1)
            Spacer(minLength: 0)
            // Vera, fase 2: «Il cliente in 30 secondi» diventa un collegamento della testata (non in modalità cliente)
            if !stato.inModoCliente {
                Button { stato.trentaSecondiDallaScheda(cliente.id) } label: {
                    Text(TestiQuadroDossier.trentaSecondi)
                        .carattereApple(Q.collegamento)
                        .foregroundColor(Q.coloreCollegamento)
                        .lineLimit(1)
                }
                .buttonStyle(StileSemplice())
                .fixedSize()
                .disabled(stato.veraInCorso)
                .help(TestiQuadroDossier.aiutoTrentaSecondi(nome))
            }
            Button { stato.apriAnalisi360DalQuadro(area: nil) } label: {
                Text(TestiQuadroDossier.apriAnalisi)
                    .carattereApple(Q.collegamento)
                    .foregroundColor(Q.coloreCollegamento)
                    .lineLimit(1)
            }
            .buttonStyle(StileSemplice())
            .fixedSize()
        }
    }
}

// MARK: - Un riquadro

/// Un riquadro delle aree: l'anello 76/9 con la cifra al centro (i mesi su due righe), l'occhiello nel colore
/// dell'area, la riga della cifra e il testo breve delle card di Analisi 360. Si inclina di 4° e un clic apre l'area.
private struct TesseraAreaDossier: View {
    let area: AreaAnalisi
    let sintesi: SintesiArea360?
    let indice: Int
    let apri: () -> Void

    private typealias Q = Tema.Apple.Clienti.Panoramica.Quadro

    var body: some View {
        let colore = Tema.Apple.Aree360.colore(area)
        let forma = RoundedRectangle(cornerRadius: Q.raggioTessera, style: .continuous)
        let nomeArea = TestiAree360.nomeArea(area)
        return HStack(alignment: .center, spacing: Q.spazioTessera) {
            Anello(frazione: sintesi?.frazione ?? 0, colore: colore, misura: Q.anello, spessore: Q.spessoreAnello,
                   ritardo: Tema.Apple.Clienti.Moto.ritardoAnelli) {
                centro
                    .frame(maxWidth: max(0, Q.anello - 2 * Q.spessoreAnello))
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(nomeArea)
                    .carattereApple(Q.occhiello)
                    .foregroundColor(colore)
                    .lineLimit(1)
                Text(sintesi?.titolo ?? nomeArea)
                    .carattereApple(Q.riga)
                    .foregroundColor(Q.coloreRiga)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, Q.sopraRiga)
                    .padding(.bottom, Q.sottoRiga)
                if let testo = sintesi?.testo, !testo.isEmpty {
                    Text(testo)
                        .carattereApple(Q.testo)
                        .foregroundColor(Q.coloreTesto)
                        .lineLimit(Q.righeTesto)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Q.paddingTessera)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .contentShape(forma)
        .onTapGesture(perform: apri)
        .superficieApple(Q.superficieTessera, raggio: Q.raggioTessera)
        .inclinazione(massimo: Q.inclinazioneTessera, raggio: Q.raggioTessera)
        .help(TestiQuadroDossier.aiutoArea(nomeArea))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { apri() }
    }

    /// Al centro la percentuale che si conta, i mesi con la virgola su due righe o il trattino se l'area non si misura.
    @ViewBuilder private var centro: some View {
        if let s = sintesi, let v = s.valore, s.unita == .percentuale {
            NumeroCheConta(v, formato: .percentuale, indice: indice)
                .carattereApple(Q.cifra)
                .foregroundColor(Q.coloreCifra)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        } else if let s = sintesi, let v = s.valore {
            VStack(spacing: 0) {
                NumeroCheConta(v, formato: .mesi, indice: indice)
                    .carattereApple(Q.cifraMesi)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(TestiAree360.mesi(v) == "1" ? TestiQuadroDossier.mese : TestiQuadroDossier.mesi)
                    .carattereApple(Q.cifraMesi)
                    .lineLimit(1)
            }
            .foregroundColor(Q.coloreCifra)
            .multilineTextAlignment(.center)
        } else {
            Text("—")
                .carattereApple(Q.cifra)
                .foregroundColor(Q.coloreTrattino)
        }
    }
}

// MARK: - La riga dei dati

/// «Dati per l'analisi», la barra (al più 200: verde da 85%, altrimenti arancio), la percentuale che si conta e
/// «<N> da completare ›» («Dati completi» senza freccia); un filo sopra. Un clic apre l'elenco.
struct RigaDatiAnalisi: View {
    let completezza: CompletezzaCliente
    let apri: () -> Void

    private typealias Q = Tema.Apple.Clienti.Panoramica.Quadro
    private typealias P = Tema.Apple.Clienti.Panoramica

    var body: some View {
        let k = completezza
        let completo = k.percentuale >= P.sogliaVerde
        let tutto = k.daCompletare.isEmpty
        return Button(action: apri) {
            HStack(alignment: .center, spacing: Q.spazioDati) {
                Text(TestiCompletezza.occhiello)
                    .carattereApple(P.titolo)
                    .foregroundColor(P.coloreTitolo)
                    .lineLimit(1)
                    .fixedSize()
                BarraPiena(frazione: k.quota, colore: completo ? P.anelloCompleto : P.anelloParziale)
                    .frame(maxWidth: Q.barraMassima)
                    .layoutPriority(1)
                NumeroCheConta(Double(k.percentuale), formato: .percentuale)
                    .carattereApple(Q.percentuale)
                    .foregroundColor(completo ? P.testoCompleto : P.testoParziale)
                    .fixedSize()
                    .help(TestiCompletezza.metodo)
                Spacer(minLength: 0)
                Text(tutto ? TestiQuadroDossier.datiCompleti : TestiQuadroDossier.daCompletare(k.daCompletare.count))
                    .carattereApple(Q.collegamento)
                    .foregroundColor(tutto ? Q.coloreDatiCompleti : Q.coloreCollegamento)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.top, Q.sopraDati)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(P.filo)
                    .frame(height: Tema.Apple.Misura.bordo)
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(StileSemplice())
        .help(TestiQuadroDossier.aiutoDati)
    }
}

// MARK: - L'elenco nato dalla riga

/// Il dettaglio «Dati per l'analisi · <Nome>»: «Completi al N%», la frase del template e le voci da completare con
/// «Completa» e la croce «non pertinente» (come la card di prima); sotto, le voci segnate non pertinenti con «Ripristina».
struct DettaglioDatiAnalisiApple: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.statoDettaglioApple) private var dettaglio

    private typealias Q = Tema.Apple.Clienti.Panoramica.Quadro
    private typealias P = Tema.Apple.Clienti.Panoramica

    var body: some View {
        let _ = ContaCorpi.segna()
        if let c = stato.cliente(stato.clienteAttivoId), let k = stato.completezzaCliente(c.id) {
            VStack(alignment: .leading, spacing: 0) {
                Text(TestiQuadroDossier.titoloDettaglio(c.nome))
                    .carattereApple(P.titolo)
                    .foregroundColor(P.coloreTitolo)
                    .lineLimit(1)
                Text(TestiQuadroDossier.completi(k.percentuale))
                    .carattereApple(Q.titoloDettaglio)
                    .foregroundColor(Tema.Apple.Colore.inchiostro)
                    .padding(.top, Q.sopraTitoloDettaglio)
                    .help(TestiCompletezza.metodo)
                Text(TestiQuadroDossier.frase)
                    .carattereApple(Q.fraseDettaglio)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: Q.larghezzaFrase, alignment: .leading)
                    .padding(.top, Q.sopraFrase)
                    .padding(.bottom, Q.sottoFrase)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if k.daCompletare.isEmpty {
                            Label(TestiQuadroDossier.tuttiCi, systemImage: "checkmark.circle.fill")
                                .carattereApple(Q.tuttiCi)
                                .foregroundColor(Q.coloreDatiCompleti)
                                .padding(.vertical, Q.paddingTuttiCi)
                        }
                        ForEach(k.daCompletare) { v in
                            VoceDaCompletareApple(voce: v,
                                                  completa: { completa(v, cliente: c.id) },
                                                  escludi: { escludi(v, cliente: c) },
                                                  solaLettura: stato.solaLettura)
                        }
                        piede(k, cliente: c.id)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    /// «Completa»: il dettaglio si chiude e si apre il posto del dato.
    private func completa(_ v: VoceCompletezza, cliente id: String) {
        dettaglio?.chiudi(subito: true)
        stato.apriCompletamento(v, cliente: id)
    }

    private func escludi(_ v: VoceCompletezza, cliente c: Cliente) {
        stato.segnaDatoNonPertinente(v.id, cliente: c.id)
        stato.mostraAvviso(TestiCompletezza.avvisoEsclusa(v.titolo, nome: c.nome))
    }

    @ViewBuilder private func piede(_ k: CompletezzaCliente, cliente id: String) -> some View {
        if !k.escluse.isEmpty {
            HStack(spacing: P.spazioTitolo) {
                Text(TestiCompletezza.escluse(k.escluse.count))
                    .carattereApple(P.piede)
                    .foregroundColor(P.colorePiede)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Button(TestiCompletezza.ripristina) { stato.ripristinaDatiNonPertinenti(id) }
                    .buttonStyle(.appleSobrio)
                    .help(TestiCompletezza.aiutoRipristina)
                    .disabled(stato.solaLettura)
            }
            .padding(.top, P.sopraPiede)
        }
    }
}

// MARK: - Da fare per il cliente

/// «Da fare per <Nome>» con il numero, «[altre N · ]Apri tutto ›» (il pannello «Da fare» su «Solo <Nome>») e le prime
/// tre voci del nastro unico del cliente con la riga comune (migliorie d'uso 3). Non in modalità cliente.
struct DaFareDossierApple: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    private typealias Q = Tema.Apple.Clienti.Panoramica.Quadro
    private typealias P = Tema.Apple.Clienti.Panoramica

    var body: some View {
        let _ = ContaCorpi.segna()
        let nastro = stato.nastroDaFareCompleto(cliente: cliente.id)
        let voci = Array(nastro.voci.prefix(Q.righeDaFare))
        let altre = nastro.totale - voci.count
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: Q.spazioTitoloDaFare) {
                Text(TestiQuadroDossier.daFare(TestiTraguardi.primoNome(cliente.nome)))
                    .carattereApple(P.titolo)
                    .foregroundColor(P.coloreTitolo)
                    .lineLimit(1)
                NumeroDaFare(numero: nastro.totale)
                Spacer(minLength: 0)
                Button { stato.apriDaFare(soloCliente: true) } label: {
                    Text((altre > 0 ? TestiDaFare.altre(altre) : "") + TestiDaFare.apriTutto)
                        .carattereApple(Q.collegamento)
                        .foregroundColor(Q.coloreCollegamento)
                        .lineLimit(1)
                }
                .buttonStyle(StileSemplice())
                .fixedSize()
            }
            .padding(.bottom, Q.sottoTitoloDaFare)
            if voci.isEmpty {
                Text(TestiDaFare.niente)
                    .carattereApple(P.nota)
                    .foregroundColor(P.notaVuota)
                    .padding(.vertical, P.sottoTitolo)
            }
            ForEach(voci) { v in
                RigaDaFare(voce: v, conNome: false, conCanali: false,
                           fatto: { stato.fattoDaFare(v) }, apri: { stato.apriVoceDaFare(v) })
            }
        }
        .padding(Q.paddingDaFare)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .superficieApple(P.superficie)
    }
}
#endif
