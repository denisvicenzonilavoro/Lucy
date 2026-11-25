import SwiftUI

private typealias T = Tipo.Report
private typealias D = Misure.Documento

// La veste comune dei report per i clienti (A4 orizzontale), nello stile Lucy su carta (Design/template-carta.html,
// `.a4`): copertina di carta con il titolo in New York, la sottolineatura d'oro e lo scontrino delle cifre; pagine di
// carta chiara, testata con il marchio Lucy e l'intestazione in SF Mono, capitoli numerati, piede con il motto.
// Colori fissi: il report resta chiaro anche con l'app in scuro. Un solo canale, Lucy (`\.canaleUnicoLucy`).

/// Mette in fila copertina e pagine interne: numera le pagine e applica la tavolozza di Prisma.
enum ImpaginaReport {
    static func pagine(copertina: AnyView, interne: [AnyView], intestazione: String, lettera: LetteraConsulente? = nil) -> [AnyView] {
        // La lettera del consulente, se c'è, apre il report subito dopo la copertina
        let interne = (lettera.map { [AnyView($0)] } ?? []) + interne
        let totale = interne.count + 1
        let numerate = interne.enumerated().map { i, s in
            AnyView(CorniceReport(intestazione: intestazione, numero: i + 2, totale: totale) { s })
        }
        return ([copertina] + numerate).map {
            AnyView($0.environment(\.paletteDocumento, Colori.Documento.prisma).environment(\.canaleUnicoLucy, true))
        }
    }
}

private struct ChiaveNumeroPaginaReport: EnvironmentKey {
    static let defaultValue = 1
}

/// La numerazione di un report dentro il fascicolo: le sue pagine contano dall'inizio del fascicolo.
struct NumerazioneFascicolo {
    /// Pagine del fascicolo prima della copertina del report.
    let scostamento: Int
    /// Pagine dell'intero fascicolo.
    let totale: Int
}

private struct ChiaveDocumentoInSala: EnvironmentKey {
    static let defaultValue = false
}

private struct ChiaveNumerazioneFascicolo: EnvironmentKey {
    static let defaultValue: NumerazioneFascicolo? = nil
}

extension EnvironmentValues {
    /// Numero della pagina del report, per il capitolo ("05 —").
    var numeroPaginaReport: Int {
        get { self[ChiaveNumeroPaginaReport.self] }
        set { self[ChiaveNumeroPaginaReport.self] = newValue }
    }

    /// Il documento mostrato nella sala della presentazione: le etichette piccole crescono e scuriscono.
    /// Nel PDF resta false.
    var documentoInSala: Bool {
        get { self[ChiaveDocumentoInSala.self] }
        set { self[ChiaveDocumentoInSala.self] = newValue }
    }

    /// Dentro il fascicolo il piede stampa la pagina del fascicolo («13 / 24»), come l'indice; fuori è nil.
    var numerazioneFascicolo: NumerazioneFascicolo? {
        get { self[ChiaveNumerazioneFascicolo.self] }
        set { self[ChiaveNumerazioneFascicolo.self] = newValue }
    }
}

/// La cornice di una pagina interna, come le slide di Presentazioni del template: testata con il
/// logo e l'intestazione, carta avorio nei suoi toni, logo in filigrana, piede con il motto e il numero.
struct CorniceReport<Contenuto: View>: View {
    @Environment(\.paletteDocumento) private var C
    @Environment(\.numerazioneFascicolo) private var fascicolo
    @Environment(\.documentoInSala) private var inSala
    let intestazione: String
    let numero: Int
    let totale: Int
    @ViewBuilder let contenuto: () -> Contenuto

    /// «4 / 10» nel report, «13 / 24» dentro il fascicolo.
    private var numerazione: String {
        guard let f = fascicolo else { return "\(numero) / \(totale)" }
        return "\(numero + f.scostamento) / \(f.totale)"
    }

    var body: some View {
        let tono = Colori.Documento.toniReport[numero % Colori.Documento.toniReport.count]
        FoglioDocumento(formato: D.report, sfondo: tono.0) {
            ZStack(alignment: .bottomTrailing) {
                RadialGradient(colors: [tono.0, tono.1], center: UnitPoint(x: 0.1, y: 0.05), startRadius: 0, endRadius: D.report.width)
                if numero % 4 == 0 {
                    LogoLucy(colore: Colori.Documento.logo)
                        .frame(height: D.logoFiligrana)
                        .opacity(Colori.Documento.filigrana)
                        .padding(.trailing, 30).padding(.bottom, 26)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        LogoLucyConNome(colore: Colori.Documento.logo, altezza: D.logoReport)
                        Spacer()
                        Text(verbatim: intestazione.uppercased()).font(T.testata).tracking(1.3)
                            .foregroundColor(C.tenue).lineLimit(1)
                    }
                    .padding(.bottom, 9)
                    .overlay(Rectangle().fill(C.filettoForte.opacity(0.14)).frame(height: 0.8), alignment: .bottom)
                    contenuto()
                        .padding(.top, 14)
                        .environment(\.numeroPaginaReport, numero)
                    Spacer(minLength: 0)
                    HStack {
                        Text(verbatim: "PERSONE. PRIORITÀ. PROSPETTIVE.")
                        Spacer()
                        Text(verbatim: numerazione)
                    }
                    .font(inSala ? T.piedeSala : T.piede).tracking(1.2).foregroundColor(inSala ? C.testo : C.tenue)
                    .padding(.top, 7)
                    .overlay(Rectangle().fill(C.filetto).frame(height: 0.8), alignment: .top)
                }
                .padding(EdgeInsets(top: 22, leading: D.margineReport, bottom: 14, trailing: D.margineReport))
            }
        }
    }
}

/// Capitolo, titolo che dice la conclusione e sottotitolo (.slides-chapter, .slides-stage h2).
struct TestaReport: View {
    @Environment(\.paletteDocumento) private var C
    @Environment(\.numeroPaginaReport) private var numero
    let occhiello: String
    let titolo: String
    var sottotitolo: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 9) {
                Text(verbatim: String(format: "%02d", numero)).font(T.capitolo)
                Rectangle().fill(C.filetto).frame(width: 25, height: 1)
                Text(verbatim: occhiello.uppercased()).font(T.capitolo).tracking(1.9)
            }
            .foregroundColor(C.occhiello)
            Text(verbatim: titolo).font(T.titoloSlide).tracking(-0.4).foregroundColor(C.titolo).lineLimit(1).minimumScaleFactor(0.7)
                // La sottolineatura d'oro nello spazio sotto il titolo: non sposta l'impaginazione della pagina
                .overlay(alignment: .bottomLeading) {
                    SottolineaturaOro(lunghezza: D.lunghezzaOroReport).offset(y: D.spessoreOro * 2.8)
                }
            if let sottotitolo, !sottotitolo.isEmpty {
                Text(verbatim: sottotitolo).font(T.sottotitoloSlide).foregroundColor(C.tenue)
                    .lineSpacing(2).fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// La copertina di carta dello stile Lucy: a sinistra il marchio, l'occhiello in SF Mono, il titolo grande in New York
/// con la sottolineatura d'oro, il sottotitolo, per chi è e il consulente; a destra lo scontrino con le cifre del report
/// (i cartellini: la prima riga è la cifra grande, le altre sotto), alto quanto la pagina. Nel fascicolo, al posto delle
/// cifre, lo scontrino «Dentro» con i report e le pagine. Un solo canale, Lucy: niente etichette dei canali.
struct CopertinaReport: View {
    @Environment(\.paletteDocumento) private var C
    let occhiello: String
    let titolo: String
    let sottotitolo: String
    let nomi: String
    let ruolo: String
    let data: Date
    /// I canali delle posizioni: restano per chi li passa, ma sulla carta c'è un solo canale, Lucy.
    let canali: [Canale]
    let cartellini: [(String, [String])]
    /// Migliorie d'uso 70: l'indice del fascicolo (titolo e pagina): quando c'è, al posto dei cartellini lo scontrino
    /// «Dentro» con i report e la pagina da cui comincia ciascuno.
    var indice: [(String, Int)]? = nil

    var body: some View {
        FoglioDocumento(formato: D.report, sfondo: C.copertina) {
            ZStack {
                LinearGradient(colors: [C.copertina, C.copertinaFine], startPoint: .topLeading, endPoint: .bottomTrailing)
                // Il marchio grande in filigrana, in basso a sinistra, appena accennato
                LogoLucy(colore: Colori.Documento.logoCopertina)
                    .frame(height: D.logoCopertinaFiligrana)
                    .opacity(Colori.Documento.filigranaCopertina)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .offset(x: -D.logoCopertinaFiligrana * 0.12, y: D.logoCopertinaFiligrana * 0.22)
                RoundedRectangle(cornerRadius: D.copertinaRaggio)
                    .strokeBorder(C.copertinaFilo, lineWidth: 0.8)
                    .padding(D.copertinaCornice)
                HStack(alignment: .top, spacing: 40) {
                    sinistra
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    Group {
                        if let indice {
                            scontrino(titolo: TestiFascicolo.dentro) { righeIndice(indice) }
                        } else {
                            scontrino(titolo: "In sintesi") { righeCifre }
                        }
                    }
                    .frame(width: D.larghezzaScontrino)
                    .frame(maxHeight: .infinity)
                }
                .padding(EdgeInsets(top: 46, leading: 56, bottom: 44, trailing: 52))
            }
            .environment(\.canaleUnicoLucy, true)
        }
    }

    // MARK: A sinistra: il titolo

    private var sinistra: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                LogoLucyConNome(colore: Colori.Documento.logoCopertina, altezza: D.logoCopertina)
                Spacer(minLength: 12)
                Text(verbatim: CifreDoc.data(data).uppercased()).font(T.copertinaEtichetta).tracking(1.2)
                    .foregroundColor(C.copertinaEtichetta).lineLimit(1)
            }
            Spacer(minLength: 18)
            OcchielloDoc(testo: occhiello, font: T.copertinaOcchiello, colore: C.copertinaEtichetta)
            Text(verbatim: titolo).font(T.copertinaTitolo).tracking(-0.8).foregroundColor(C.titolo)
                .lineLimit(3).minimumScaleFactor(0.6)
                .padding(.top, 10)
            SottolineaturaOro(lunghezza: D.lunghezzaOroCopertina, spessore: D.spessoreOro * 1.6)
                .padding(.top, 8)
            // Larghezza limitata: le righe del sottotitolo vanno a capo bilanciate
            Text(verbatim: sottotitolo).font(T.copertinaSottotitolo).italic().foregroundColor(C.copertinaTesto)
                .lineSpacing(2)
                .frame(maxWidth: 400, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
            OcchielloDoc(testo: "Preparato per", font: T.copertinaEtichetta, colore: C.copertinaEtichetta)
                .padding(.top, 26)
            Text(verbatim: nomi).font(T.copertinaNomi).foregroundColor(C.titolo)
                .lineLimit(2).minimumScaleFactor(0.7)
                .padding(.top, 4)
            Spacer(minLength: 18)
            Rectangle().fill(C.copertinaFilo).frame(width: 220, height: 0.8)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: TestiValutazione.consulente).font(T.copertinaConsulente).foregroundColor(C.titolo)
                Text(verbatim: ruolo).font(T.copertinaRuolo).foregroundColor(C.copertinaTesto)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.top, 8)
        }
    }

    // MARK: A destra: lo scontrino

    /// Lo scontrino di carta (come `ScontrinoCarta`, con i colori fissi da stampa): testata in SF Mono, filo
    /// tratteggiato, le voci distribuite su tutta l'altezza, il piede «Cifre calcolate da Lucy».
    private func scontrino<Righe: View>(titolo: String, @ViewBuilder _ righe: () -> Righe) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                OcchielloDoc(testo: titolo, font: T.copertinaEtichetta, colore: C.titolo)
                Spacer(minLength: 8)
                Text(verbatim: CifreDoc.dataBreve(data)).font(T.copertinaEtichetta).foregroundColor(C.copertinaEtichetta)
            }
            filo.padding(.top, 9)
            righe()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 4)
            filo
            Text(verbatim: "CIFRE CALCOLATE DA LUCY")
                .font(T.copertinaEtichetta).tracking(0.8).foregroundColor(C.copertinaEtichetta)
                .lineLimit(1).minimumScaleFactor(0.7)
                .padding(.top, 8)
        }
        .padding(D.margineScontrino)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(RoundedRectangle(cornerRadius: D.raggioScontrino).fill(Colori.Documento.Carta.scontrino)
            .shadow(color: C.ombraCartellino, radius: D.cartellinoOmbra, x: 0, y: D.cartellinoOmbraY))
        .overlay(RoundedRectangle(cornerRadius: D.raggioScontrino).strokeBorder(C.copertinaFilo, lineWidth: 0.6))
        .overlay(alignment: .top) {
            Rectangle().fill(C.oro).frame(height: D.spessoreOro * 1.4).padding(.horizontal, D.raggioScontrino)
        }
    }

    /// Il filo tratteggiato dello scontrino.
    private var filo: some View {
        let larghezza = D.larghezzaScontrino - D.margineScontrino * 2
        return Path { q in
            q.move(to: CGPoint(x: 0, y: 0.5))
            q.addLine(to: CGPoint(x: larghezza, y: 0.5))
        }
        .stroke(Colori.Documento.Carta.filoScontrino,
                style: StrokeStyle(lineWidth: 0.8, dash: [D.trattinoScontrino, D.trattinoScontrino]))
        .frame(width: larghezza, height: 1)
    }

    /// I cartellini come voci dello scontrino: l'etichetta in SF Mono, la cifra grande in New York, il resto sotto.
    /// Lo spazio fra le voci cresce con la pagina: lo scontrino è pieno, mai una colonna vuota.
    private var righeCifre: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(cartellini.enumerated()), id: \.offset) { i, c in
                VStack(alignment: .leading, spacing: 4) {
                    OcchielloDoc(testo: c.0, font: T.copertinaEtichetta, colore: C.copertinaEtichetta)
                    ForEach(Array(c.1.enumerated()), id: \.offset) { j, riga in
                        Text(verbatim: riga)
                            .font(j == 0 ? T.copertinaValore : T.copertinaValoreMinore)
                            .foregroundColor(j == 0 ? C.titolo : C.copertinaTesto)
                            .lineLimit(2).minimumScaleFactor(0.7)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 8)
                if i < cartellini.count - 1 {
                    Spacer(minLength: 0)
                    filo.opacity(0.6)
                    Spacer(minLength: 0)
                }
            }
            Spacer(minLength: 0)
        }
    }

    /// Lo scontrino «Dentro» del fascicolo: una riga per report con la sua pagina.
    private func righeIndice(_ voci: [(String, Int)]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if voci.isEmpty {
                Text(verbatim: TestiFascicolo.nessunReport).font(T.paginaIndiceCopertina).foregroundColor(C.tenue)
                    .padding(.top, 8)
            }
            ForEach(Array(voci.enumerated()), id: \.offset) { i, v in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    // Due righe al più: nel PDF il titolo resta intero (si cerca nel testo)
                    Text(verbatim: v.0).font(T.indiceCopertina).foregroundColor(C.titolo)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 6)
                    Text(verbatim: "\(v.1)").font(T.paginaIndiceCopertina).foregroundColor(C.tenue)
                }
                .padding(.vertical, 4)
                .frame(minHeight: D.rigaIndiceCopertina)
                if i < voci.count - 1 {
                    filo.opacity(0.5)
                }
            }
        }
    }
}

/// La lettera del consulente al cliente, dopo la copertina: il commento scritto con Vera e riletto
/// dal consulente, con la firma.
struct LetteraConsulente: View {
    @Environment(\.paletteDocumento) private var C
    let testo: String
    let ruolo: String
    let data: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TestaReport(occhiello: "Il commento del consulente", titolo: "Due parole per te")
            HStack(alignment: .top, spacing: 22) {
                Text(verbatim: testo)
                    .font(T.lettera).foregroundColor(C.titolo).lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .riquadroDoc()
                VStack(alignment: .leading, spacing: 6) {
                    Text(verbatim: TestiValutazione.consulente).font(T.letteraFirma).foregroundColor(C.titolo)
                    Rectangle().fill(C.filetto).frame(width: 150, height: 0.8)
                    Text(verbatim: ruolo).font(T.piccolo).foregroundColor(C.testo).fixedSize(horizontal: false, vertical: true)
                    Text(verbatim: CifreDoc.data(data)).font(T.piccolo).foregroundColor(C.tenue)
                }
                .padding(.top, 18)
                .frame(width: 190, alignment: .topLeading)
            }
            Spacer(minLength: 0)
        }
    }
}
