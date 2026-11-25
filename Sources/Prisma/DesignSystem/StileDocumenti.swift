#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

// Stile dei documenti per i clienti (report A4 orizzontale e prospetto A4 verticale), nello stile Lucy su carta
// (Design/template-carta.html, `.a4`, dal 25 novembre 2026): New York per titoli e cifre grandi, SF Mono per occhielli
// ed etichette, SF Pro per il testo; inchiostro, matita e la sottolineatura d'oro; verde, blu stilografica e rosso per i
// tre scenari. I documenti restano su carta bianca con colori fissi e opachi, anche con l'app in scuro.

/// I colori di un documento per i clienti. Due tavolozze con la stessa veste Lucy: "moderna" per il prospetto (carta
/// bianca) e "prisma" per il report (carta appena più calda, copertina di carta con lo scontrino delle cifre).
/// I componenti comuni la leggono dall'ambiente.
struct PaletteDocumento {
    // Foglio (sfumatura radiale dall'alto a sinistra)
    var foglio: Color
    var foglioFine: Color
    // Copertina (sfumatura da copertina a copertinaFine)
    var copertina: Color
    var copertinaFine: Color
    var copertinaRiquadro: Color
    var copertinaEtichetta: Color
    var copertinaTesto: Color
    var copertinaFilo: Color
    var ombraCartellino: Color
    // Testo
    var titolo: Color
    var testo: Color
    var tenue: Color
    var occhiello: Color
    var marchio: Color
    // Riquadri e filetti
    var riquadro: Color
    var riquadroBordo: Color
    var riquadroLuce: Color
    var filetto: Color
    var filettoForte: Color
    var evidenza: Color
    var evidenzaTitolo: Color
    var barraLaterale: Color
    var bloccato: Color
    var griglia: Color
    var premio: Color
    // Scenari e parti
    var favorevole: Color
    var intermedio: Color
    var sfavorevole: Color
    var favorevoleFondo: Color
    var intermedioFondo: Color
    var sfavorevoleFondo: Color
    var gestioneSeparata: Color
    /// Ocra: il semaforo giallo e i dati da aggiornare (non più il Fondo Interno, che sembrava il cuoio dell'indipendente).
    var fondoInterno: Color
    /// Il Fondo Interno e i fondi nei grafici: viola, come nell'app, lontano dal blu e dal cuoio dei canali.
    var fondi: Color
    var negativo: Color
    var positivo: Color
    var penaleForte: Color
    var penaleMedia: Color
    var penaleLieve: Color
    var cascataTotale: Color
    var cascataPiu: Color
    var cascataMeno: Color
    /// Aree delle posizioni, nell'ordine di AreaPosizione.ordine (previdenza … debiti).
    var aree: [Color]
    /// Canali nei grafici: blu Alleanza e ambra/cuoio dell'indipendente, come le etichette da stampa.
    var alleanza: Color
    var indipendente: Color
    /// La sottolineatura dorata dello stile Lucy (titoli, cifre in evidenza, barra dei riquadri).
    var oro: Color

    func area(_ a: AreaPosizione) -> Color { aree[a.ordine % aree.count] }

    /// Dal 25 novembre 2026 (decisione dell'utente) un solo canale, quello di Lucy: lo stesso colore per tutti.
    func canale(_ c: Canale) -> Color { alleanza }

    func scenario(_ t: TipoScenario) -> Color {
        switch t {
        case .favorevole: return favorevole
        case .intermedio: return intermedio
        case .sfavorevole: return sfavorevole
        }
    }

    func scenarioFondo(_ t: TipoScenario) -> Color {
        switch t {
        case .favorevole: return favorevoleFondo
        case .intermedio: return intermedioFondo
        case .sfavorevole: return sfavorevoleFondo
        }
    }

    func parte(_ t: ComponenteContratto.Tipo) -> Color {
        t == .gestioneSeparata ? gestioneSeparata : fondi
    }
}

extension Colori {
    enum Documento {
        /// Lo stile Lucy su carta (Design/template-carta.html, `.a4`): carta bianca, inchiostro #15181F, matita
        /// #6F685B, sottolineature d'oro #DDA918, rosso #AE3D2B e verde #2C6A4D. Colori fissi e opachi: il documento
        /// resta chiaro anche con l'app in scuro. Prospetto (A4 verticale) su carta bianca.
        static let moderna = lucy(foglio: .white, foglioFine: .white)

        /// Report (A4 orizzontale): la stessa veste, su una carta appena più calda (resta chiara come il bianco).
        static let prisma = lucy(foglio: Color(hex: "#FFFEFB"), foglioFine: Color(hex: "#FCF9F1"))

        /// La tavolozza Lucy su carta, con il foglio dato. Un solo canale, Lucy: i due colori dei canali sono lo
        /// stesso inchiostro blu della stilografica.
        private static func lucy(foglio: Color, foglioFine: Color) -> PaletteDocumento {
            PaletteDocumento(
                foglio: foglio, foglioFine: foglioFine,
                copertina: Color(hex: "#FFFEFB"), copertinaFine: Color(hex: "#F8F4EA"), copertinaRiquadro: .white,
                copertinaEtichetta: Carta.matita, copertinaTesto: Carta.inchiostro2, copertinaFilo: Color(hex: "#D9D4C7"),
                ombraCartellino: Color(hex: "#15181F14"),
                titolo: Carta.inchiostro, testo: Color(hex: "#2E323B"), tenue: Carta.matita,
                occhiello: Carta.matita, marchio: Carta.inchiostro,
                riquadro: Color(hex: "#FAF7EF"), riquadroBordo: Color(hex: "#E4DFD2"), riquadroLuce: .clear,
                filetto: Color(hex: "#E4E0D6"), filettoForte: Carta.inchiostro,
                evidenza: Color(hex: "#FBF4DA"), evidenzaTitolo: Color(hex: "#8A6A0A"), barraLaterale: Carta.oro,
                bloccato: Color(hex: "#F1EEE6"), griglia: Color(hex: "#ECE8DF"), premio: Color(hex: "#8C8578"),
                favorevole: Carta.verde, intermedio: Carta.stilografica, sfavorevole: Carta.rosso,
                favorevoleFondo: Color(hex: "#E6EFE9"), intermedioFondo: Color(hex: "#E7EBF2"), sfavorevoleFondo: Color(hex: "#F5E7E3"),
                gestioneSeparata: Color(hex: "#6D7F94"), fondoInterno: Color(hex: "#C7961A"), fondi: Color(hex: "#7A6FB0"),
                negativo: Carta.rosso, positivo: Carta.verde,
                penaleForte: Carta.rosso, penaleMedia: Color(hex: "#C98473"), penaleLieve: Color(hex: "#E3BDB3"),
                cascataTotale: Color(hex: "#9C978C"), cascataPiu: Color(hex: "#86AE95"), cascataMeno: Color(hex: "#D49A8A"),
                aree: [Carta.stilografica, Carta.verde, Color(hex: "#6D7F94"), Color(hex: "#7A6FB0"),
                       Color(hex: "#3A8C86"), Color(hex: "#A49C8A"), Carta.rosso],
                alleanza: Carta.stilografica, indipendente: Carta.stilografica,
                oro: Carta.oro
            )
        }

        /// I colori di base dello stile Lucy su carta (`.a4` del template), fissi.
        enum Carta {
            static let inchiostro = Color(hex: "#15181F")
            static let inchiostro2 = Color(hex: "#4E5462")
            static let matita = Color(hex: "#6F685B")
            static let oro = Color(hex: "#DDA918")
            static let rosso = Color(hex: "#AE3D2B")
            static let verde = Color(hex: "#2C6A4D")
            /// Le note e la linea di mezzo: il blu della stilografica.
            static let stilografica = Color(hex: "#2B4C7E")
            /// Lo scontrino della copertina: carta del cartoncino, filo tratteggiato.
            static let scontrino = Color(hex: "#FFFDF8")
            static let filoScontrino = Color(hex: "#15181F40")
        }
    }
}

extension Colori.Documento {
    /// Il marchio Lucy su carta: sempre a inchiostro, anche sulla copertina (che è di carta, non più blu notte).
    static let logo = Tema.Colore.logoStampa
    static let logoCopertina = Tema.Colore.logoStampa
    /// Trasparenza del logo in filigrana nelle pagine del report e sulla copertina.
    static let filigrana: Double = 0.04
    static let filigranaCopertina: Double = 0.035

    /// Toni della carta delle pagine del report: carta chiara, appena calda, senza le tinte salvia e cielo di prima
    /// (i PDF restano su carta bianca).
    static let toniReport: [(Color, Color)] = [
        (Color(hex: "#FFFEFB"), Color(hex: "#FCF9F1")),
        (Color(hex: "#FFFEFB"), Color(hex: "#FBF8EF")),
        (Color(hex: "#FFFFFD"), Color(hex: "#FAF8F2")),
        (Color(hex: "#FFFEFB"), Color(hex: "#FBF9F3")),
    ]
}

private struct ChiavePaletteDocumento: EnvironmentKey {
    static let defaultValue = Colori.Documento.moderna
}

extension EnvironmentValues {
    /// Tavolozza dei documenti per i clienti (moderna per il prospetto, Prisma per il report).
    var paletteDocumento: PaletteDocumento {
        get { self[ChiavePaletteDocumento.self] }
        set { self[ChiavePaletteDocumento.self] = newValue }
    }
}

extension Tipo {
    /// Caratteri dei prospetti: SF del sistema a dimensioni fisse (non seguono la Dimensione del testo).
    enum Documento {
        static func sf(_ dimensione: CGFloat, _ peso: Font.Weight = .regular) -> Font {
            Font.system(size: dimensione, weight: peso)
        }

        static func sf(_ dimensione: CGFloat, grassetto: Bool) -> Font {
            sf(dimensione, grassetto ? .bold : .regular)
        }

        static func nsSF(_ dimensione: CGFloat) -> FontPiattaforma {
            FontPiattaforma.systemFont(ofSize: dimensione)
        }

        /// Lo stile Lucy (Design/template-carta.html, `.a4`): New York per titoli e cifre grandi, SF Mono per
        /// occhielli, etichette e piede, SF Pro per il testo. Dimensioni fisse.
        static func serif(_ dimensione: CGFloat, _ peso: Font.Weight = .medium) -> Font {
            Font.system(size: dimensione, weight: peso, design: .serif)
        }

        static func mono(_ dimensione: CGFloat, _ peso: Font.Weight = .medium) -> Font {
            Font.system(size: dimensione, weight: peso, design: .monospaced)
        }

        // Comuni (valori predefiniti dei componenti)
        static let occhiello = mono(7)
        static let corpo = sf(10.5)
        static let corpoForte = sf(10.5, grassetto: true)
        static let piccolo = sf(8.5)
        static let minimo = sf(7)

        // Prospetto (A4 verticale)
        static let pOcchiello = mono(6.3)
        static let pTitolo = serif(22)
        static let pSottotitolo = sf(8.5)
        static let pSezione = serif(13)
        static let pSottosezione = serif(10.5)
        static let pCorpo = sf(7.8)
        static let pCorpoForte = sf(7.8, grassetto: true)
        static let pTabella = sf(7.2)
        static let pTabellaForte = sf(7.2, grassetto: true)
        static let pTabellaTesta = sf(6.4, .semibold)
        static let pTabellaNota = sf(5.8)
        static let pKpiEtichetta = mono(5.9)
        static let pKpiValore = serif(16)
        static let pKpiNota = sf(6)
        static let pValoreScenario = serif(12)
        static let pPiede = mono(5.4, .regular)
        static let pAssi = sf(6)

        static let nsCorpo = nsSF(10.5)
        static let nsPCorpo = nsSF(7.8)
    }

    /// Caratteri del report per il cliente: SF del sistema, titoli e cifre più grandi (.slides-stage h2),
    /// note piccole, occhielli spaziati (.slides-chapter).
    enum Report {
        static func sf(_ dimensione: CGFloat, grassetto: Bool = false) -> Font {
            Documento.sf(dimensione, grassetto: grassetto)
        }

        static let testata = Documento.mono(6.3)
        static let capitolo = Documento.mono(7)
        static let piede = Documento.mono(5.6, .regular)
        static let copertinaOcchiello = Documento.mono(8)
        static let copertinaTitolo = Documento.serif(40)
        static let copertinaSottotitolo = Documento.serif(14, .regular)
        static let copertinaNomi = Documento.serif(21)
        static let copertinaConsulente = Documento.sf(10.5, grassetto: true)
        static let copertinaRuolo = Documento.sf(9)
        static let copertinaEtichetta = Documento.mono(7.2)
        static let copertinaValore = Documento.serif(17)
        /// Le righe minori dello scontrino della copertina (dopo la cifra grande).
        static let copertinaValoreMinore = Documento.sf(9.5)
        /// L'indice sulla copertina del fascicolo (migliorie d'uso 70): il titolo del report e la sua pagina.
        static let indiceCopertina = Documento.serif(11.5, .regular)
        static let paginaIndiceCopertina = Documento.mono(9, .regular)
        static let occhiello = Documento.mono(7)
        static let titoloSlide = Documento.serif(24)
        static let sottotitoloSlide = Documento.sf(10)
        static let corpo = sf(10.5)
        static let corpoForte = sf(10.5, grassetto: true)
        static let piccolo = Documento.sf(8)
        static let minimo = Documento.sf(6.8)
        static let numeroGrande = Documento.serif(24)
        static let numeroMedio = Documento.serif(18)
        static let numeroPiccolo = Documento.serif(13.5)
        static let titoloRiquadro = Documento.serif(13, .semibold)
        static let scenarioTitolo = Documento.serif(13, .semibold)
        static let scenarioRendimento = Documento.serif(26)
        static let sintesiNumero = Documento.serif(32)
        /// La lettera del consulente dopo la copertina.
        static let lettera = Documento.serif(12, .regular)
        static let letteraFirma = Font.system(size: 19, weight: .light, design: .serif).italic()
    }
}

extension Misure {
    enum Documento {
        /// A4 orizzontale (report) e verticale (prospetto), in punti.
        static let report = CGSize(width: 842, height: 595)
        static let prospetto = CGSize(width: 595, height: 842)
        static let margineReport: CGFloat = 44
        static let margineProspetto: CGFloat = 40
        static let raggio: CGFloat = 5
        static let raggioPiccolo: CGFloat = 3
        /// Il logo (altezza del simbolo): testata dei prospetti, testata e filigrana del report, copertina.
        static let logoProspetto: CGFloat = 9
        static let logoProspettoAlto: CGFloat = 13
        static let logoReport: CGFloat = 11
        static let logoFiligrana: CGFloat = 110
        static let logoCopertina: CGFloat = 22
        static let logoCopertinaFiligrana: CGFloat = 330
        /// Cornice sottile della copertina (rientro dal bordo e raggio).
        static let copertinaCornice: CGFloat = 18
        static let copertinaRaggio: CGFloat = 12
        /// I cartellini bianchi della copertina e la loro ombra.
        static let cartellinoRaggio: CGFloat = 6
        static let cartellinoOmbra: CGFloat = 6
        static let cartellinoOmbraY: CGFloat = 3
        static let spazio: CGFloat = 12
        static let rigaTabellaReport: CGFloat = 22
        static let rigaTabellaProspetto: CGFloat = 13.5
        /// Testata di tabella con titolo e sottotitolo: l'altezza minima per le due righe.
        static let altezzaTestaDoppia: CGFloat = 20
        static let tracciatoOcchiello: CGFloat = 1.6
        /// Prova di resistenza: la barra della perdita sui mercati nel prospetto e nel report.
        static let barraResistenza: CGFloat = 12
        static let barraResistenzaReport: CGFloat = 22
        /// Il grafico con e senza costi nel prospetto e nel report.
        static let graficoCosti: CGFloat = 190
        static let graficoCostiReport: CGFloat = 270
        /// Il percorso del patrimonio nel report: il grafico occupa quasi tutta l'altezza della pagina.
        static let graficoPatrimonioReport: CGFloat = 360
        /// Righe al massimo nelle tabelle dei documenti a pagina fissa (oltre: «…e altre N», l'elenco intero è in Posizioni).
        static let righeTabellaFissa = 9
        static let schedeReport = 4
        /// Migliorie d'uso 70: l'indice entra nella copertina del fascicolo fino a 8 report (oltre resta la pagina
        /// dell'indice, decisione 70-b); il riquadro «Dentro» è largo 280, le righe alte almeno 20.
        static let vociIndiceCopertina = 8
        static let larghezzaIndiceCopertina: CGFloat = 280
        static let rigaIndiceCopertina: CGFloat = 20
        static let puntiReport = 5
    }
}

// MARK: - Lucy su carta: un solo canale, la sottolineatura d'oro

private struct ChiaveCanaleUnicoLucy: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// true nei prospetti e nei report di Prospetti: c'è un solo canale, Lucy. Le etichette dei canali da stampa non
    /// si disegnano e le tabelle divise per canale diventano una tabella sola (i tipi interni restano).
    var canaleUnicoLucy: Bool {
        get { self[ChiaveCanaleUnicoLucy.self] }
        set { self[ChiaveCanaleUnicoLucy.self] = newValue }
    }
}

extension Misure.Documento {
    /// La sottolineatura d'oro sotto i titoli (stile Lucy): spessore e lunghezza nei prospetti e nei report.
    static let spessoreOro: CGFloat = 1.6
    static let lunghezzaOroProspetto: CGFloat = 34
    static let lunghezzaOroReport: CGFloat = 46
    static let lunghezzaOroCopertina: CGFloat = 120
    /// Lo scontrino della copertina del report: larghezza, margini, raggio e trattino del filo.
    static let larghezzaScontrino: CGFloat = 268
    static let margineScontrino: CGFloat = 18
    static let raggioScontrino: CGFloat = 3
    static let trattinoScontrino: CGFloat = 3
}

/// La sottolineatura d'oro disegnata a mano dello stile Lucy, ferma (sulla carta stampata niente movimento): una
/// curva appena ondulata, con le punte arrotondate.
struct SottolineaturaOro: View {
    @Environment(\.paletteDocumento) private var p
    var lunghezza: CGFloat = Misure.Documento.lunghezzaOroProspetto
    var spessore: CGFloat = Misure.Documento.spessoreOro

    var body: some View {
        let h = spessore * 2.4
        let l = lunghezza
        Path { q in
            q.move(to: CGPoint(x: 0, y: h * 0.62))
            q.addCurve(to: CGPoint(x: l, y: h * 0.38),
                       control1: CGPoint(x: l * 0.32, y: h * 0.18),
                       control2: CGPoint(x: l * 0.66, y: h * 0.92))
        }
        .stroke(p.oro, style: StrokeStyle(lineWidth: spessore, lineCap: .round))
        .frame(width: l, height: h)
    }
}
