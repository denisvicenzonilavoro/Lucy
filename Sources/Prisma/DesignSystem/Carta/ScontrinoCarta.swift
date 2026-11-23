import SwiftUI

// Lo scontrino dello stile Carta (NOVITÀ 6, template `.receipt`): un foglietto di carta con il bordo seghettato in
// fondo, le righe in SF Mono, il totale in New York a contachilometri e il codice a barre «lo stesso conto di Prisma
// AI». Le cifre arrivano da MotoreScontrino: qui solo il disegno. Segue la carta dell'app, giorno e notte.

extension TemaCarta {
    /// Misure e caratteri dello scontrino (template, `.receipt`).
    enum Scontrino {
        static let larghezza: CGFloat = 320
        static let padding = EdgeInsets(top: 18, leading: 20, bottom: 26, trailing: 20)
        /// Altezza e passo dei denti del bordo seghettato.
        static let dente: CGFloat = 6
        static let passoDente: CGFloat = 10
        static let testata = Font.system(size: 10, weight: .regular, design: .monospaced)
        static let titolo = Font.system(size: 11, weight: .regular, design: .monospaced)
        static let totale = Font.system(size: 46, weight: .medium, design: .serif).monospacedDigit()
        static let riga = Font.system(size: 12.5, weight: .regular, design: .monospaced)
        static let rigaForte = Font.system(size: 13.5, weight: .medium, design: .monospaced)
        static let piccolo = Font.system(size: 11, weight: .regular, design: .monospaced)
        static let spazioRighe: CGFloat = 9
        static let codice: CGFloat = 30
    }
}

/// Il foglietto con il bordo seghettato in fondo.
struct FormaScontrino: Shape {
    var dente: CGFloat = TemaCarta.Scontrino.dente
    var passo: CGFloat = TemaCarta.Scontrino.passoDente

    func path(in r: CGRect) -> Path {
        var p = Path()
        let fondo = r.maxY - dente
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: fondo))
        // I denti da destra a sinistra
        var x = r.maxX
        var giu = true
        while x > r.minX {
            let prossimo = max(r.minX, x - passo / 2)
            p.addLine(to: CGPoint(x: prossimo, y: giu ? r.maxY : fondo))
            giu.toggle()
            x = prossimo
        }
        p.addLine(to: CGPoint(x: r.minX, y: r.minY))
        p.closeSubpath()
        return p
    }
}

/// Una riga dello scontrino: etichetta a sinistra, importo a destra in cifre allineate.
struct RigaScontrinoVista: View {
    let etichetta: String
    let importo: String
    var forte = false
    var colore: Color = TemaCarta.Colore.inchiostroD

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(etichetta)
                .font(forte ? TemaCarta.Scontrino.rigaForte : TemaCarta.Scontrino.riga)
                .foregroundColor(forte ? TemaCarta.Colore.inchiostroD : TemaCarta.Colore.inchiostro2D)
            Spacer(minLength: 12)
            Text(importo)
                .font(forte ? TemaCarta.Scontrino.rigaForte : TemaCarta.Scontrino.riga)
                .monospacedDigit()
                .foregroundColor(colore)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Il codice a barre di fantasia in fondo allo scontrino (decorativo, sempre lo stesso per lo stesso testo).
struct CodiceScontrino: View {
    let seme: String

    var body: some View {
        Canvas { ctx, size in
            var h: UInt32 = 2_166_136_261
            for b in seme.utf8 { h = (h ^ UInt32(b)) &* 16_777_619 }
            var x: CGFloat = 0
            while x < size.width {
                h = h &* 1_664_525 &+ 1_013_904_223
                let w = CGFloat(1 + (h >> 28) % 3)
                if (h >> 20) & 1 == 1 {
                    ctx.fill(Path(CGRect(x: x, y: 0, width: w, height: size.height)), with: .color(TemaCarta.Colore.inchiostroD))
                }
                x += w + 1
            }
        }
        .frame(height: TemaCarta.Scontrino.codice)
        .accessibilityHidden(true)
    }
}

/// La linea tratteggiata che divide le parti dello scontrino.
struct LineaTratteggiata: View {
    var body: some View {
        Rectangle()
            .stroke(TemaCarta.Colore.filo2D, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

/// Lo scontrino generico: testata, titolo, totale a contachilometri con la riga sotto, le righe e il piede.
struct ScontrinoCarta<Righe: View>: View {
    let data: Date
    let titolo: String
    let totale: String
    var sottoTotale: String? = nil
    var coloreSottoTotale: Color = TemaCarta.Colore.verdeD
    @ViewBuilder let righe: () -> Righe

    var body: some View {
        let k = TemaCarta.Scontrino.self
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("PRISMA")
                Spacer()
                Text(Formati.dataBreve.string(from: data))
            }
            .font(k.testata)
            .foregroundColor(TemaCarta.Colore.matitaD)
            .padding(.bottom, 18)

            VStack(spacing: 6) {
                Text(titolo.uppercased())
                    .font(k.titolo)
                    .tracking(2)
                    .foregroundColor(TemaCarta.Colore.matitaD)
                ContachilometriCarta(testo: totale)
                    .font(k.totale)
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
                    .segnoCarta(.sottolinea, chiave: "scontrino.\(titolo)")
                if let sottoTotale {
                    Text(sottoTotale)
                        .font(k.piccolo)
                        .foregroundColor(coloreSottoTotale)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)

            LineaTratteggiata()
            VStack(alignment: .leading, spacing: k.spazioRighe) { righe() }
                .padding(.vertical, 14)
            LineaTratteggiata()
            CodiceScontrino(seme: titolo + totale)
                .padding(.top, 16)
                .padding(.horizontal, 30)
            Text("Lo stesso conto di Prisma AI".uppercased())
                .font(k.testata)
                .tracking(2)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
        }
        .padding(k.padding)
        .frame(maxWidth: k.larghezza)
        .background { FormaScontrino().fill(TemaCarta.Colore.schedaD) }
        .overlay { FormaScontrino().stroke(TemaCarta.Colore.filoD, lineWidth: 1) }
    }
}

// MARK: - Gli scontrini di Prisma

/// Il conto di oggi del cliente (dossier, Panoramica): versato, mercati, costi, tasse, netto in tasca.
struct ScontrinoContoCliente: View {
    let conto: ContoCliente
    var data = Date()

    var body: some View {
        let f = FormatoCifra.euro
        ScontrinoCarta(data: data, titolo: "Il conto di oggi", totale: f.testo(conto.valore),
                       sottoTotale: "\(conto.differenza >= 0 ? "▲" : "▼") \(f.testo(abs(conto.differenza))) da quando hanno iniziato",
                       coloreSottoTotale: conto.differenza >= 0 ? TemaCarta.Colore.verdeD : TemaCarta.Colore.rossoD) {
            ForEach(conto.righe, id: \.etichetta) { r in
                RigaScontrinoVista(etichetta: r.etichetta, importo: Self.importo(r), colore: Self.colore(r))
            }
            LineaTratteggiata()
            RigaScontrinoVista(etichetta: "Netto in tasca", importo: Self.conSegno(conto.netto), forte: true)
            if let resa = conto.resaNetta {
                RigaScontrinoVista(etichetta: "resa netta in totale", importo: FormatoCifra.percentuale.testo(resa),
                                   colore: resa >= 0 ? TemaCarta.Colore.verdeD : TemaCarta.Colore.rossoD)
            }
            Text("I costi pagati sono una stima: costo annuo per gli anni trascorsi.")
                .font(TemaCarta.Scontrino.piccolo)
                .foregroundColor(TemaCarta.Colore.matitaD)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    static func importo(_ r: RigaScontrino) -> String {
        r.conSegno ? conSegno(r.importo) : FormatoCifra.euro.testo(r.importo)
    }

    static func conSegno(_ v: Double) -> String {
        (v > 0 ? "+" : "") + FormatoCifra.euro.testo(v)
    }

    static func colore(_ r: RigaScontrino) -> Color {
        guard r.conSegno, r.importo != 0 else { return TemaCarta.Colore.inchiostroD }
        return r.importo < 0 ? TemaCarta.Colore.rossoD : TemaCarta.Colore.verdeD
    }
}

/// Lo scontrino dei costi di una posizione o di una proposta: quest'anno, a 5 e a 10 anni, e l'alternativa.
/// «Mostra al cliente» passa alla modalità cliente (le note di Vera si spengono da sole).
struct ScontrinoCostiPosizione: View {
    let scontrino: ScontrinoCosti
    var mostraAlCliente: (() -> Void)? = nil

    var body: some View {
        let s = scontrino
        let f = FormatoCifra.euro
        VStack(alignment: .leading, spacing: 12) {
            ScontrinoCarta(data: Date(), titolo: s.posizione.stato == .proposta ? "I costi della proposta" : "I costi",
                           totale: s.costiNoti ? f.testo(s.euroAnno) : "—",
                           sottoTotale: s.costiNoti ? "all'anno · \(MotoreScontrino.percento(s.annuo)) del valore"
                                                    : "costi non indicati: completali con il KID",
                           coloreSottoTotale: s.costiNoti ? TemaCarta.Colore.matitaD : TemaCarta.Colore.rossoD) {
                if s.costiNoti {
                    RigaScontrinoVista(etichetta: "In \(s.anni5) anni", importo: "−" + f.testo(s.perso5),
                                       colore: TemaCarta.Colore.rossoD)
                    RigaScontrinoVista(etichetta: "In \(s.anni10) anni", importo: "−" + f.testo(s.perso10),
                                       colore: TemaCarta.Colore.rossoD)
                    if let a = s.alternativa {
                        LineaTratteggiata()
                        RigaScontrinoVista(etichetta: "A confronto: \(a.nome)", importo: f.testo(a.euroAnno) + "/anno")
                        RigaScontrinoVista(etichetta: "In \(a.anni) anni lascia di più", importo: "+" + f.testo(a.guadagno),
                                           forte: true, colore: TemaCarta.Colore.verdeD)
                        if a.costoUscita > 0 {
                            RigaScontrinoVista(etichetta: "Per cambiare oggi", importo: "−" + f.testo(a.costoUscita),
                                               colore: TemaCarta.Colore.rossoD)
                        }
                    }
                }
            }
            if let mostraAlCliente {
                Button(action: mostraAlCliente) {
                    Label("Mostra al cliente", systemImage: "person.crop.rectangle")
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
