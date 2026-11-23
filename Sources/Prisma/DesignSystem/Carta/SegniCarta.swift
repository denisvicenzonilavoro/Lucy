import SwiftUI

// I segni a mano dello stile Carta (template, «SOTTOLINEATURE, CERCHI, EVIDENZIATORE»): la sottolineatura dorata, il
// cerchio rosso e l'evidenziatore si disegnano all'apertura di una schermata, solo su una o due cose che contano.
// Dalla seconda apertura sono già al loro posto: lo ricorda `MemoriaSegni`, solo in memoria e per il giorno (il giorno
// dopo il disegno torna una volta). Niente Timer: animazioni di SwiftUI con `trim`. Con «Riduci movimento» e nelle
// istantanee il segno è già fermo nello stato finale. Con lo stile Apple (iPhone) i segni non si disegnano.

/// Il tipo di segno.
enum SegnoCarta {
    /// La sottolineatura dorata (`data-a=ul`).
    case sottolinea
    /// Il cerchio rosso (`data-a=circle`).
    case cerchio
    /// L'evidenziatore (`data-a=mk`).
    case evidenzia
}

/// Cosa si è già visto oggi: chiave del segno e giorno. Solo in memoria (mai nell'archivio né nei backup): è un'abitudine
/// visiva, non un dato. Non è osservata: chiederla non ridisegna niente.
final class MemoriaSegni: @unchecked Sendable {
    static let condivisa = MemoriaSegni()

    private var visti: Set<String> = []
    private let blocco = NSLock()

    /// true se il segno con questa chiave va disegnato adesso (la prima volta del giorno); lo segna come visto.
    /// `giorno` è l'inizio del giorno: lo passa chi chiede, così la prova può scegliere la data.
    func daDisegnare(_ chiave: String, giorno: Date) -> Bool {
        let voce = "\(chiave)|\(Int(giorno.timeIntervalSinceReferenceDate))"
        blocco.lock(); defer { blocco.unlock() }
        return visti.insert(voce).inserted
    }

    /// Dimentica tutto (per le prove).
    func svuota() {
        blocco.lock(); visti.removeAll(); blocco.unlock()
    }
}

extension View {
    /// Un segno a mano dello stile Carta su questa vista. `chiave` lo distingue dagli altri (per esempio
    /// «scrivania.saluto»): la prima apertura del giorno lo disegna, le altre lo mostrano già fatto.
    func segnoCarta(_ segno: SegnoCarta, chiave: String, ritardo: Double = 0.3) -> some View {
        modifier(ModificatoreSegnoCarta(segno: segno, chiave: chiave, ritardo: ritardo))
    }
}

private struct ModificatoreSegnoCarta: ViewModifier {
    let segno: SegnoCarta
    let chiave: String
    let ritardo: Double
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var fatto: CGFloat = 0
    @State private var deciso = false

    func body(content: Content) -> some View {
        if Tema.Stile.carta {
            let p: CGFloat = statoFinale ? 1 : fatto
            switch segno {
            case .sottolinea:
                content
                    .overlay(alignment: .bottomLeading) {
                        GeometryReader { g in
                            TrattoSottolineatura()
                                .trim(from: 0, to: p)
                                .stroke(TemaCarta.Colore.oroD, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                .frame(width: g.size.width + 10, height: 14)
                                .offset(x: -5, y: g.size.height - 4)
                        }
                        .allowsHitTesting(false)
                    }
                    .onAppear(perform: comincia)
            case .cerchio:
                content
                    .overlay {
                        GeometryReader { g in
                            TrattoCerchio()
                                .trim(from: 0, to: p)
                                .stroke(TemaCarta.Colore.rossoD, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                                .frame(width: g.size.width + 26, height: g.size.height + 18)
                                .offset(x: -13, y: -9)
                        }
                        .allowsHitTesting(false)
                    }
                    .onAppear(perform: comincia)
            case .evidenzia:
                content
                    .background(alignment: .leading) {
                        GeometryReader { g in
                            // background-size 62% in altezza, posizione 78%: la parte bassa della riga
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(TemaCarta.Colore.evidenziatoreD)
                                .frame(width: (g.size.width + 4) * p, height: g.size.height * 0.62)
                                .offset(x: -2, y: g.size.height * (0.78 - 0.62 * 0.78))
                        }
                        .allowsHitTesting(false)
                    }
                    .onAppear(perform: comincia)
            }
        } else {
            content
        }
    }

    private var durata: Double {
        switch segno {
        case .sottolinea: return TemaCarta.Moto.sottolineatura
        case .cerchio: return TemaCarta.Moto.cerchio
        case .evidenzia: return TemaCarta.Moto.evidenziatore
        }
    }

    /// Alla comparsa: la prima volta del giorno si disegna, poi è già al suo posto.
    private func comincia() {
        guard !deciso else { return }
        deciso = true
        guard !statoFinale else { fatto = 1; return }
        let giorno = Calendar.current.startOfDay(for: Date())
        if MemoriaSegni.condivisa.daDisegnare(chiave, giorno: giorno) {
            withAnimation(Tema.Apple.Moto.Curva.ease.animazione(durata).ritardoPrisma(ritardo)) { fatto = 1 }
        } else {
            fatto = 1
        }
    }
}

/// La sottolineatura disegnata a mano (`ulPath` del template: M3 H−5 C 0,28W H−9, 0,62W H−2, W−3 H−7).
struct TrattoSottolineatura: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        p.move(to: CGPoint(x: r.minX + 3, y: r.minY + h - 5))
        p.addCurve(to: CGPoint(x: r.minX + w - 3, y: r.minY + h - 7),
                   control1: CGPoint(x: r.minX + w * 0.28, y: r.minY + h - 9),
                   control2: CGPoint(x: r.minX + w * 0.62, y: r.minY + h - 2))
        return p
    }
}

/// Il cerchio a mano che non si chiude del tutto (`circlePath` del template).
struct TrattoCerchio: Shape {
    func path(in r: CGRect) -> Path {
        let cx = r.midX, cy = r.midY, rx = r.width / 2 - 3, ry = r.height / 2 - 3
        func q(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: cx + rx * x, y: cy + ry * y) }
        var p = Path()
        p.move(to: q(0.25, -1))
        p.addCurve(to: q(0, 1), control1: q(1.02, -1.02), control2: q(1.04, 0.92))
        p.addCurve(to: q(-0.1, -1.04), control1: q(-1.04, 1.04), control2: q(-1.02, -0.96))
        p.addCurve(to: q(0.72, -0.7), control1: q(0.3, -1.1), control2: q(0.55, -0.92))
        return p
    }
}

/// Le cifre a contachilometri dei totali (template, `odo`): ogni cifra scorre dal basso fino al suo valore, una dopo
/// l'altra (70 ms di distanza). Nelle istantanee e con «Riduci movimento» è un testo fermo con il valore finale.
struct ContachilometriCarta: View {
    /// Il valore già scritto («412.380 €»): le cifre scorrono, il resto resta fermo.
    /// Il carattere arriva da chi lo mostra (come per `NumeroCheConta`).
    let testo: String
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var arrivato = false

    var body: some View {
        if statoFinale || !Tema.Stile.carta {
            Text(testo).monospacedDigit()
        } else {
            HStack(spacing: 0) {
                ForEach(Array(testo.enumerated()), id: \.offset) { i, c in
                    if let n = c.wholeNumberValue {
                        ColonnaCifra(cifra: n, arrivato: arrivato)
                            .animation(Tema.Apple.Moto.Curva.uscita.animazione(TemaCarta.Moto.contachilometri)
                                .ritardoPrisma(Double(i) * 0.07), value: arrivato)
                    } else {
                        Text(String(c))
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(testo)
            .onAppear { arrivato = true }
        }
    }
}

/// Una colonna di cifre 0-9 che scorre sotto una finestra alta una riga.
private struct ColonnaCifra: View {
    let cifra: Int
    let arrivato: Bool

    var body: some View {
        // La misura di una cifra la dà un «0» trasparente; la colonna scorre sopra, ritagliata
        Text("0").monospacedDigit().hidden()
            .overlay(alignment: .top) {
                GeometryReader { g in
                    VStack(spacing: 0) {
                        ForEach(0..<10, id: \.self) { k in
                            Text("\(k)").monospacedDigit().frame(height: g.size.height)
                        }
                    }
                    .offset(y: -CGFloat(arrivato ? cifra : 0) * g.size.height)
                }
            }
            .clipped()
    }
}
