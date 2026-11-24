import SwiftUI

// Le icone delle app nello stile Carta (template, `.dk`): una tessera di carta (`--iconbg`) con un filo d'inchiostro
// e il simbolo disegnato a tratto sottile. L'Agenda scrive il mese in mono rosso e il giorno in serif; Vera è una
// tessera d'inchiostro con la «V» corsiva e la curva dorata. Sull'iPhone restano le icone di vetro (PNG).

extension AppPrisma {
    /// Il simbolo di sistema dell'icona Carta (SF Symbols, tratto sottile come le icone del template).
    var simboloCarta: String {
        switch self {
        case .clienti: return "person.text.rectangle"
        case .posizioni: return "list.bullet.rectangle"
        case .analisi360: return "chart.pie"
        case .incontri: return "person.2"
        case .obiettivi: return "scope"
        case .confronti: return "arrow.left.arrow.right"
        case .simulazioni: return "function"
        case .agenda: return "calendar"
        case .attivita: return "checklist"
        case .documenti: return "doc.text"
        case .territorio: return "map"
        case .messaggi: return "envelope"
        case .pratiche: return "tray.full"
        case .presentazioni: return "doc.richtext"
        case .sala: return "theatermasks"
        case .biblioteca: return "books.vertical"
        case .mercato: return "chart.line.uptrend.xyaxis"
        case .studio: return "book.closed"
        case .vera: return "sparkle"
        case .impostazioni: return "gearshape"
        case .prodotti: return "shippingbox"
        case .note: return "note.text"
        case .ricerca: return "magnifyingglass"
        }
    }
}

/// La tessera di carta di un'icona: fondo `--iconbg`, filo `--hair2`, raggio 15 su 56.
private struct TesseraCarta<Contenuto: View>: View {
    let lato: CGFloat
    var alto: Color = TemaCarta.Colore.iconaAltoD
    var basso: Color = TemaCarta.Colore.iconaBassoD
    @ViewBuilder let contenuto: () -> Contenuto

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: lato * TemaCarta.Raggio.icona / 56, style: .continuous)
        ZStack {
            forma.fill(LinearGradient(colors: [alto, basso], startPoint: .top, endPoint: .bottom))
            forma.strokeBorder(TemaCarta.Colore.filo2D, lineWidth: 1)
            contenuto()
        }
        .frame(width: lato, height: lato)
    }
}

/// L'icona di un'app nello stile Carta.
struct IconaCarta: View {
    let app: AppPrisma
    let lato: CGFloat

    var body: some View {
        switch app {
        case .agenda: IconaAgendaCarta(lato: lato)
        case .vera: IconaVeraCarta(lato: lato)
        default:
            TesseraCarta(lato: lato) {
                Image(systemName: app.simboloCarta)
                    .font(.system(size: lato * 0.42, weight: .light))
                    .foregroundColor(TemaCarta.Colore.inchiostroD)
            }
        }
    }
}

/// La Scrivania nel dock: il prisma a inchiostro con la sottolineatura dorata.
struct IconaScrivaniaCarta: View {
    let lato: CGFloat

    var body: some View {
        TesseraCarta(lato: lato) {
            LogoInchiostro(lato: lato * 0.62)
        }
    }
}

/// L'Agenda: il mese in SF Mono rosso, il giorno in New York (template, `.dk.cal`).
struct IconaAgendaCarta: View {
    let lato: CGFloat

    var body: some View {
        TimelineView(.everyMinute) { contesto in
            let oggi = contesto.date
            TesseraCarta(lato: lato) {
                VStack(spacing: lato * 0.02) {
                    Text(Formati.meseBreve.string(from: oggi).uppercased())
                        .font(.system(size: lato * 9 / 56, weight: .medium, design: .monospaced))
                        .tracking(lato * 1.5 / 56)
                        .foregroundColor(TemaCarta.Colore.rossoD)
                    Text(Formati.giorno.string(from: oggi))
                        .font(.system(size: lato * 28 / 56, weight: .medium, design: .serif))
                        .tracking(-lato / 56)
                        .foregroundColor(TemaCarta.Colore.inchiostroD)
                }
                .fixedSize()
            }
        }
    }
}

/// Vera: tessera d'inchiostro (di notte di carta), la «V» corsiva in serif e la curva dorata sotto.
struct IconaVeraCarta: View {
    let lato: CGFloat

    var body: some View {
        TesseraCarta(lato: lato, alto: TemaCarta.Colore.veraAltoD, basso: TemaCarta.Colore.veraBassoD) {
            ZStack {
                Text("V")
                    .font(.system(size: lato * 31 / 56, weight: .medium, design: .serif).italic())
                    .foregroundColor(TemaCarta.Colore.veraLetteraD)
                    .offset(y: -lato * 4 / 56)
                CurvaVeraCarta()
                    .stroke(TemaCarta.Colore.oro.0, style: StrokeStyle(lineWidth: lato * 2.4 / 56, lineCap: .round))
                    .frame(width: lato * 28 / 56, height: lato * 6 / 56)
                    .offset(y: lato * 17 / 56)
            }
        }
    }
}

/// La curva dorata sotto la «V» di Vera.
private struct CurvaVeraCarta: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.midY + r.height * 0.2))
        p.addCurve(to: CGPoint(x: r.maxX, y: r.midY),
                   control1: CGPoint(x: r.minX + r.width * 0.33, y: r.minY),
                   control2: CGPoint(x: r.minX + r.width * 0.66, y: r.maxY))
        return p
    }
}
