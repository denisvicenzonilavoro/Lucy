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

/// La Scrivania nel dock: il simbolo di Lucy (la L e il disco d'oro).
struct IconaScrivaniaCarta: View {
    let lato: CGFloat

    var body: some View {
        TesseraCarta(lato: lato) {
            LogoLucy()
                .frame(width: lato * 0.5, height: lato * 0.5)
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

/// L'assistente (Lucy, prima Vera): tessera d'inchiostro (di notte di carta) con il simbolo di Lucy.
struct IconaVeraCarta: View {
    let lato: CGFloat

    var body: some View {
        // L'assistente si chiama Lucy (25 novembre 2026): sulla tessera scura il simbolo di Lucy, avorio e oro, come
        // l'icona di iPhone e iPad (Design/Logo/LucyByLogic); prima la «V» di Vera
        TesseraCarta(lato: lato, alto: TemaCarta.Colore.veraAltoD, basso: TemaCarta.Colore.veraBassoD) {
            // La L avorio sulla tessera d'inchiostro di giorno, d'inchiostro sulla tessera di carta di notte
            LogoLucy(colore: Color.dinamico(chiaro: Tema.Marca.avorio, scuro: Tema.Marca.inchiostro), oro: Tema.Marca.oro)
                .frame(width: lato * 0.5, height: lato * 0.5)
        }
    }
}

