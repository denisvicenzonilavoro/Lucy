#if os(macOS)
import SwiftUI

// Migliorie d'uso 1 «Mostra al cliente»: il pannello di scelta (template `apriMostra()`, righe 3321-3328), una scheda di
// vetro larga 640 al centro che entra dal basso sopra il velo; si chiude con ✕, con un clic sul velo o con Esc.
// - Con un cliente scelto: «Cosa mostri a <Nome>?» e le quattro righe (Il suo quadro, La Sala, Un prospetto, Sull’iPad sul
//   tavolo), poi la riga leggera della schermata neutra.
// - Con «Tutti i clienti»: «A chi vuoi mostrare Prisma?» e l'elenco dei clienti; un clic sceglie il cliente per tutta
//   Prisma e il pannello passa alle quattro scelte. Si apre solo prima di girare lo schermo, mai nella vista pulita.
// Valori in Tema.Apple.MostraAlCliente.Pannello.

struct PannelloMostraAlCliente: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo

    private typealias P = Tema.Apple.MostraAlCliente.Pannello

    var body: some View {
        let _ = ContaCorpi.segna()
        GeometryReader { geo in
            ZStack {
                P.velo
                    .contentShape(Rectangle())
                    .onTapGesture { stato.chiudiSceltaMostra() }
                scheda
                    .frame(width: max(0, min(P.larghezza, geo.size.width - 2 * P.bordo)))
                    .frame(maxHeight: max(0, geo.size.height - 2 * P.bordo))
                    .entrataScheda(Tema.Apple.Moto.animazione(P.animazione, calmo: calmo), scala: P.entrataScala,
                                   ancora: .center, y: P.entrataY)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var scheda: some View {
        let cliente = stato.clienteAttivo
        return VStack(alignment: .leading, spacing: 0) {
            testata(cliente)
            if let c = cliente {
                scelte(c)
            } else {
                elenco
            }
        }
        .padding(P.padding)
        .superficieApple(P.superficie, raggio: P.raggio)
        .overlay(alignment: .topTrailing) {
            chiudi
                .padding(P.padding * 0.6)
        }
    }

    // MARK: Testata

    private func testata(_ cliente: Cliente?) -> some View {
        HStack(alignment: .center, spacing: P.spazioTestata) {
            if let c = cliente {
                AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: P.avatar)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(TestiMostra.titolo)
                    .carattereApple(P.occhiello)
                    .foregroundColor(P.coloreOcchiello)
                Text(cliente.map { TestiMostra.cosaMostri(TestiTraguardi.primoNome($0.nome)) } ?? TestiMostra.aChi)
                    .carattereApple(P.titolo)
                    .foregroundColor(P.coloreTitolo)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if cliente == nil {
                    Text(TestiMostra.aChiTesto)
                        .carattereApple(P.testo)
                        .foregroundColor(P.coloreTesto)
                }
            }
            Spacer(minLength: P.chiudi)
        }
        .padding(.bottom, P.sottoTestata)
    }

    private var chiudi: some View {
        Button { stato.chiudiSceltaMostra() } label: {
            Image(systemName: "xmark")
                .carattereApple(P.glifoChiudi)
                .foregroundColor(P.coloreTesto)
                .frame(width: P.chiudi, height: P.chiudi)
                .background(Circle().fill(P.fondoChiudi))
                .contentShape(Circle())
        }
        .buttonStyle(StileSemplice())
        .help(TestiMostra.chiudi)
        .accessibilityLabel(Text(TestiMostra.chiudi))
    }

    // MARK: Le quattro scelte

    private func scelte(_ c: Cliente) -> some View {
        VStack(alignment: .leading, spacing: P.spazioRighe) {
            RigaSceltaMostra(glifo: "chart.pie.fill", titolo: TestiMostra.quadro, testo: TestiMostra.quadroTesto) {
                stato.mostra(.quadro)
            }
            RigaSceltaMostra(glifo: "sparkles", titolo: TestiMostra.sala, testo: TestiMostra.salaTesto) {
                stato.mostra(.sala)
            }
            RigaSceltaMostra(glifo: "doc.richtext", titolo: TestiMostra.prospetto, testo: TestiMostra.prospettoTesto) {
                stato.mostraProspettoDalPannello()
            }
            RigaSceltaMostra(glifo: "ipad.landscape", titolo: TestiMostra.tavolo, testo: TestiMostra.tavoloTesto) {
                stato.tavoloDalPannello()
            }
            Button { stato.mostraNeutra() } label: {
                HStack(spacing: P.spazioRiga) {
                    Image(systemName: "water.waves")
                    Text(TestiMostra.neutra)
                    Spacer(minLength: 0)
                }
                .carattereApple(P.neutra)
                .foregroundColor(P.coloreNeutra)
                .padding(.horizontal, P.paddingRiga.leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(StileSemplice())
            .padding(.top, P.sopraNeutra - P.spazioRighe)
        }
    }

    // MARK: L'elenco dei clienti

    private var elenco: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(stato.rubricaOrdinata) { c in
                    RigaClienteMostra(cliente: c) { stato.scegliPerMostra(c.id) }
                }
            }
        }
        .frame(maxHeight: P.altezzaMassimaElenco)
    }
}

/// Una delle quattro righe grandi (`.scl`): il quadrato del glifo, titolo e testo, la freccia; al passaggio sale di 2.
private struct RigaSceltaMostra: View {
    let glifo: String
    let titolo: String
    let testo: String
    let azione: () -> Void
    @State private var sopra = false

    private typealias P = Tema.Apple.MostraAlCliente.Pannello

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: P.raggioRiga, style: .continuous)
        return Button(action: azione) {
            HStack(spacing: P.spazioRiga) {
                Image(systemName: glifo)
                    .carattereApple(P.glifoRiga)
                    .foregroundColor(P.coloreGlifo)
                    .frame(width: P.quadrato, height: P.quadrato)
                    .background(RoundedRectangle(cornerRadius: P.raggioQuadrato, style: .continuous).fill(P.fondoQuadrato))
                VStack(alignment: .leading, spacing: 3) {
                    Text(titolo)
                        .carattereApple(P.titoloRiga)
                        .foregroundColor(P.coloreTitolo)
                    Text(testo)
                        .carattereApple(P.testoRiga)
                        .foregroundColor(P.coloreTesto)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .carattereApple(P.freccia)
                    .foregroundColor(P.coloreFreccia)
            }
            .padding(P.paddingRiga)
            .background(forma.fill(P.fondoRiga))
            .overlay(forma.strokeBorder(P.filoRiga, lineWidth: 1))
            .contentShape(forma)
            .offset(y: sopra ? -P.salitaPassaggio : 0)
        }
        .buttonStyle(StileSemplice())
        .onHover { s in withAnimation(Tema.Moto.passaggio) { sopra = s } }
    }
}

/// Una riga dell'elenco «A chi vuoi mostrare Prisma?»: avatar 38, nome e motto.
private struct RigaClienteMostra: View {
    let cliente: Cliente
    let azione: () -> Void
    @State private var sopra = false

    private typealias P = Tema.Apple.MostraAlCliente.Pannello

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: P.raggioElenco, style: .continuous)
        return Button(action: azione) {
            HStack(spacing: P.spazioRiga) {
                AvatarCliente(iniziali: cliente.iniziali, tinta: cliente.tinta.colori, lato: P.avatarElenco)
                VStack(alignment: .leading, spacing: 1) {
                    Text(cliente.nome)
                        .carattereApple(P.nomeElenco)
                        .foregroundColor(P.coloreTitolo)
                        .lineLimit(1)
                    if !cliente.tema.isEmpty {
                        Text(cliente.tema)
                            .carattereApple(P.mottoElenco)
                            .foregroundColor(P.coloreTesto)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(P.paddingElenco)
            .background(forma.fill(sopra ? P.sopraElenco : Color.clear))
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .onHover { s in withAnimation(Tema.Moto.passaggio) { sopra = s } }
    }
}
#endif
