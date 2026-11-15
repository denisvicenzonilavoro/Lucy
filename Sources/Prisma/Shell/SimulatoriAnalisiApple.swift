import SwiftUI

// I simulatori dal vivo di Analisi 360 nel tema Apple (Design/template-apple-specifica.md §4.3.2, §4.3.3): l'area
// Previdenza o Protezione si espande in un dettaglio 940×540 (PresentatoreDettaglio, origine `.origineDettaglio`)
// con l'anello, le cifre, il cursore che ricalcola dal vivo e le ipotesi scritte sotto. Qui le parti comuni:
// gli id dei due dettagli, il dettaglio da aprire subito nelle istantanee, la vista che li risolve e i pezzi
// grafici condivisi. I simulatori stanno in SimulatorePrevidenzaApple.swift e SimulatoreProtezioneApple.swift;
// i calcoli in Motori/MotoreSimulatoriAnalisi.swift; i gettoni in DesignSystem/Apple/Tema.Apple+SimulatoriAnalisi.swift.
//
// Uso dalla griglia delle aree (un solo presentatore per finestra):
//
//     @StateObject private var dettaglio = SimulatoriAnalisiApple.dettaglioIniziale(stato)
//     …
//     schedaArea(.previdenza).origineDettaglio(id: SimulatoriAnalisiApple.idPrevidenza)
//         .onTapGesture { dettaglio.apri(SimulatoriAnalisiApple.idPrevidenza, misura: SimulatoriAnalisiApple.misura(.previdenza)) }
//     …
//     .presentatoreDettaglio(dettaglio) { id in
//         if SimulatoriAnalisiApple.area(id: id) != nil { DettaglioSimulatoreAnalisiApple(id: id) }
//     }

/// Gli id dei due simulatori e come si aprono.
enum SimulatoriAnalisiApple {
    static let idPrevidenza = "simulatore-previdenza"
    static let idProtezione = "simulatore-protezione"
    /// Previdenza 940×560 sul Mac (940×540 su iPhone e iPad), Protezione 940×540
    /// (`Tema.Apple.Misura.DettaglioAperto.previdenza`, `.protezione`).
    static func misura(_ area: AreaAnalisi) -> CGSize {
        area == .previdenza ? Tema.Apple.SimulatoriAnalisi.misuraPrevidenza : Tema.Apple.SimulatoriAnalisi.misuraProtezione
    }

    /// L'id del simulatore di un'area (nil per Investimenti e Risparmio, che hanno un dettaglio senza cursore).
    static func id(_ area: AreaAnalisi) -> String? {
        switch area {
        case .previdenza: return idPrevidenza
        case .protezione: return idProtezione
        case .investimenti, .risparmio: return nil
        }
    }

    /// L'area di un id di simulatore (nil se l'id è di un altro dettaglio).
    static func area(id: String) -> AreaAnalisi? {
        switch id {
        case idPrevidenza: return .previdenza
        case idProtezione: return .protezione
        default: return nil
        }
    }

    /// Lo stato del dettaglio con cui nasce il presentatore: aperto sul simulatore se una scena delle istantanee
    /// lo chiede (`RichiestaIstantaneaSimulatore`), altrimenti chiuso.
    static func dettaglioIniziale(_ stato: StatoShell) -> StatoDettaglio {
        guard let r = RichiestaIstantaneaSimulatore.per(stato), let chiave = id(r.area) else { return StatoDettaglio() }
        return StatoDettaglio(aperto: chiave, misura: misura(r.area))
    }

    /// Il valore del cursore chiesto da una scena delle istantanee per quest'area (nil = quello di partenza).
    static func valoreIniziale(_ stato: StatoShell, _ area: AreaAnalisi) -> Double? {
        guard let r = RichiestaIstantaneaSimulatore.per(stato), r.area == area else { return nil }
        return r.valore
    }
}

/// Il contenuto del dettaglio aperto: il simulatore dell'area, per il cliente attivo e la sua analisi salvata.
struct DettaglioSimulatoreAnalisiApple: View {
    @Environment(StatoShell.self) var stato
    let id: String

    var body: some View {
        let _ = ContaCorpi.segna()
        let cid = stato.clienteAttivoId
        if let c = stato.cliente(cid), let area = SimulatoriAnalisiApple.area(id: id) {
            let analisi = Binding<Analisi360>(get: { stato.analisi360(cid) }, set: { stato.salvaAnalisi(cid, $0) })
            switch area {
            case .previdenza:
                // Un altro cliente: il cursore riparte dal suo versamento
                SimulatorePrevidenzaApple(cliente: c, analisi: analisi).id(c.id)
            case .protezione:
                SimulatoreProtezioneApple(cliente: c, analisi: analisi).id(c.id)
            case .investimenti, .risparmio:
                EmptyView()
            }
        }
    }
}

/// Ciò che una scena delle istantanee chiede ad Analisi 360 (Prisma --istantanee): il simulatore di un'area già
/// aperto, con il cursore a un valore diverso da quello di partenza. Vale solo per lo stato della scena
/// (riferimento debole: le scene dopo non lo vedono).
final class RichiestaIstantaneaSimulatore {
    nonisolated(unsafe) private static var attuale: RichiestaIstantaneaSimulatore?
    private weak var stato: StatoShell?
    let area: AreaAnalisi
    let valore: Double

    private init(stato: StatoShell, area: AreaAnalisi, valore: Double) {
        self.stato = stato
        self.area = area
        self.valore = valore
    }

    static func chiedi(_ s: StatoShell, area: AreaAnalisi, valore: Double) {
        attuale = RichiestaIstantaneaSimulatore(stato: s, area: area, valore: valore)
    }

    static func per(_ s: StatoShell) -> RichiestaIstantaneaSimulatore? {
        guard let r = attuale, r.stato === s else { return nil }
        return r
    }
}

// MARK: - Pezzi comuni

/// `.lbl` nel colore dell'area («PREVIDENZA · NOME COGNOME») e il titolo 28 bold.
struct TestataSimulatoreApple: View {
    let etichetta: String
    let titolo: String
    let colore: Color

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return VStack(alignment: .leading, spacing: s.spazioTestata) {
            Text(etichetta)
                .carattereApple(s.etichetta)
                .foregroundColor(colore)
                .lineLimit(1)
            Text(titolo)
                .carattereApple(s.titolo)
                .foregroundColor(s.coloreTitolo)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.trailing, s.margineChiudi)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Una cifra `.k`/`.v`. All'apertura conta in 1,0 s; da quando il cursore si muove cambia subito (§4.3.2).
/// `valore` nil: la cifra non si può calcolare dai dati («—»).
struct CifraSimulatoreApple: View {
    let titolo: String
    let valore: Double?
    var formato: FormatoCifra = .euro
    var indice: Int = 0
    var mosso = false
    var colore: Color = Tema.Apple.SimulatoriAnalisi.coloreValore
    /// La capsula «stima» accanto all'etichetta.
    var stima = false
    var aiuto: String?

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return VStack(alignment: .leading, spacing: s.spazioEtichettaValore) {
            HStack(alignment: .center, spacing: s.spazioStima) {
                Text(titolo)
                    .carattereApple(s.etichettaCifra)
                    .foregroundColor(s.coloreEtichetta)
                    .lineLimit(1)
                if stima {
                    EtichettaStimaSimulatoreApple()
                }
            }
            valoreScritto
                .carattereApple(s.valoreCifra)
                .foregroundColor(valore == nil ? s.coloreEtichetta : colore)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .fixedSize(horizontal: true, vertical: false)
        .help(aiuto ?? "")
    }

    @ViewBuilder private var valoreScritto: some View {
        if let v = valore {
            if mosso {
                Text(formato.testo(v, finale: v))
                    .monospacedDigit()
            } else {
                NumeroCheConta(v, formato: formato, indice: indice, durata: Tema.Apple.Moto.NumeroSimulatore.durata)
            }
        } else {
            Text(Tema.Apple.SimulatoriAnalisi.senzaValore)
        }
    }
}

/// La capsula «stima»: la cifra viene da un'ipotesi, non dai dati del contratto.
struct EtichettaStimaSimulatoreApple: View {
    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return Text("stima")
            .carattereApple(s.testoStima)
            .foregroundColor(s.coloreStima)
            .padding(s.paddingStima)
            .background(Capsule().fill(s.fondoStima))
            .fixedSize()
    }
}

/// L'anello 210/20 nel colore dell'area, con la percentuale 42 e la riga sotto: insegue il cursore in 1,4 s
/// (lo fa `Anello`); brilla quando arriva al 100%.
struct AnelloSimulatoreApple: View {
    let frazione: Double
    let colore: Color
    let sotto: String
    var mosso = false

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        let pieno = frazione >= 1
        return Anello(frazione: frazione, colore: colore, misura: s.anello, spessore: s.spessoreAnello,
                      ritardo: Tema.Apple.Moto.Anello.ritardoDettaglio, brilla: pieno) {
            VStack(spacing: 0) {
                Group {
                    if mosso {
                        Text(FormatoCifra.percentuale.testo(frazione * 100))
                            .monospacedDigit()
                    } else {
                        NumeroCheConta(frazione * 100, formato: .percentuale,
                                       durata: Tema.Apple.Moto.NumeroSimulatore.durata)
                    }
                }
                .carattereApple(s.centroAnello)
                .foregroundColor(s.coloreCentro)
                .lineLimit(1)
                Text(sotto)
                    .carattereApple(s.sottoCentro)
                    .foregroundColor(s.coloreSottoCentro)
                    .lineLimit(1)
            }
        }
        .accessibilityLabel(Text("\(FormatoCifra.percentuale.testo(frazione * 100)) \(sotto)"))
    }
}

/// Le ipotesi del calcolo, sempre scritte sotto i risultati.
struct IpotesiSimulatoreApple: View {
    let testo: String

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return Text(testo)
            .carattereApple(s.ipotesi)
            .foregroundColor(s.coloreIpotesi)
            .lineLimit(s.righeIpotesi)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Il canale della proposta che si salva: la pillola Alleanza / Indipendente e l'etichetta del canale scelto,
/// così si riconosce sempre (blu Alleanza, cuoio indipendente).
struct CanaleSimulatoreApple: View {
    @Binding var canale: Canale

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return HStack(alignment: .center, spacing: s.spazioCanale) {
            SegmentatoPillola(selezione: $canale, valori: Canale.allCases, titolo: { $0.nomeBreve })
                .fixedSize()
                .help("Il canale della proposta che si salva")
            EtichettaCanaleApple(canale: canale, compatta: true)
        }
    }
}

// MARK: - Migliorie d'uso 45 (solo Mac): il segno «oggi» e la frase prima e dopo

#if os(macOS)
/// Il segno «oggi» sotto il binario del cursore (`.simOggi` del template): una tacca 2×6 e la parola «oggi», nella
/// posizione del valore di partenza corretta per metà manopola. Non si muove con il cursore.
struct SegnoOggiCursore: View {
    /// La posizione del valore di oggi sul binario (0…1).
    let frazione: Double

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return GeometryReader { g in
            let corsa = max(0, g.size.width - s.manopolaCursore)
            let x = s.manopolaCursore / 2 + corsa * CGFloat(min(1, max(0, frazione)))
            VStack(spacing: s.segnoOggiSpazio) {
                RoundedRectangle(cornerRadius: s.segnoOggiRaggioTacca, style: .continuous)
                    .fill(s.coloreTaccaOggi)
                    .frame(width: s.segnoOggiTacca.width, height: s.segnoOggiTacca.height)
                Text("oggi")
                    .carattereApple(s.segnoOggiCarattere)
                    .foregroundColor(s.coloreSegnoOggi)
                    .lineLimit(1)
                    .fixedSize()
            }
            .position(x: x, y: s.segnoOggiSotto / 2)
        }
        .frame(height: s.segnoOggiSotto)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// La frase prima e dopo (`#simFr`): una tile a tutta larghezza, 14,5 con le parti in neretto. Cambia subito mentre
/// si trascina (come le cifre «mosse»), senza animazione.
struct FraseSimulatoreApple: View {
    let pezzi: [PezzoFraseSimulatore]

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        let testo = pezzi.reduce(Text(verbatim: "")) { (t: Text, p: PezzoFraseSimulatore) -> Text in
            p.grassetto ? t + Text(verbatim: p.testo).bold() : t + Text(verbatim: p.testo)
        }
        return testo
            .carattereApple(s.frase)
            .foregroundColor(s.coloreFrase)
            .lineLimit(s.righeFrase)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(s.paddingFrase)
            .superficieApple(s.superficieFrase)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: TestiSimulatoriAnalisi.testo(pezzi)))
    }
}

/// «Sono stime, non garanzie.» accanto ai pulsanti del piede.
struct AvvisoSimulatoreApple: View {
    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return Text(TestiSimulatoriAnalisi.avviso)
            .carattereApple(s.avviso)
            .foregroundColor(s.coloreAvviso)
            .lineLimit(1)
            .fixedSize()
            .padding(.leading, s.spazioAvviso)
    }
}

/// «LE IPOTESI» all'inizio della riga delle scelte.
struct EtichettaIpotesiSimulatoreApple: View {
    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return Text("Le ipotesi")
            .carattereApple(s.etichettaScelte)
            .foregroundColor(s.coloreScelte)
            .lineLimit(1)
            .fixedSize()
    }
}

/// Un testo grigio della riga delle ipotesi.
struct TestoIpotesiSimulatoreApple: View {
    let testo: String

    init(_ testo: String) { self.testo = testo }

    var body: some View {
        let s = Tema.Apple.SimulatoriAnalisi.self
        return Text(testo)
            .carattereApple(s.testoScelte)
            .foregroundColor(s.coloreScelte)
            .lineLimit(1)
            .minimumScaleFactor(s.riduzioneScelte)
    }
}
#endif
