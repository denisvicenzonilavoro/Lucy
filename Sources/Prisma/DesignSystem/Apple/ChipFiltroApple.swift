import SwiftUI

// Migliorie d'uso 54: il filtro a chip del tema Apple (`.fch` del template), nato con i filtri del track record e
// pronto per altri elenchi. Capsula alta 30: spenta fondo `chip` con il testo `inchiostro2`, accesa fondo `cardPiena`
// con l'ombra della pillola. Un clic sulla chip accesa non fa nulla. «Riduci movimento»: la dissolvenza del tema;
// istantanee: nessuna animazione. Gettoni in Tema.Apple+Controlli.swift (`Controlli.ChipFiltro`).
//
//     ChipFiltroApple(titolo: "Accettate", acceso: filtro == .accettate) { filtro = .accettate }

struct ChipFiltroApple: View {
    let titolo: String
    let acceso: Bool
    let azione: () -> Void

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    init(titolo: String, acceso: Bool, azione: @escaping () -> Void) {
        self.titolo = titolo
        self.acceso = acceso
        self.azione = azione
    }

    var body: some View {
        let c = Tema.Apple.Controlli.ChipFiltro.self
        let forma = Capsule(style: .continuous)
        return Text(titolo)
            .carattereApple(c.carattere)
            .foregroundColor(acceso ? c.testoAcceso : c.testo)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, c.paddingOrizzontale)
            .frame(height: c.altezza)
            .background {
                if acceso {
                    forma.fill(c.fondoAcceso).ombraApple(.pillola)
                } else {
                    forma.fill(c.fondo)
                }
            }
            .contentShape(forma)
            .animation(Tema.Apple.Moto.animazione(c.animazione, calmo: calmo, istantanea: istantanea), value: acceso)
            .onTapGesture { scegli() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(titolo))
            .accessibilityAddTraits(acceso ? Self.trattiAcceso : Self.trattiSpento)
            .accessibilityAction { scegli() }
    }

    private func scegli() {
        guard !acceso else { return }
        azione()
    }

    private static var trattiSpento: AccessibilityTraits { .isButton }
    private static var trattiAcceso: AccessibilityTraits { [.isButton, .isSelected] }
}
