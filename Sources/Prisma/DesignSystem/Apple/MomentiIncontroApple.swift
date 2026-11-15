import SwiftUI

// Migliorie d'uso 20: i tre momenti dell'incontro (`.passi`, `.pz` del template, righe 602-612 e 3743): «1 Prima ·
// Preparazione», «2 Durante · Ascolto», «3 Dopo · Prossimi passi», uniti da un filo. Il momento aperto è una capsula
// azzurra col numero bianco su tondo blu; quelli fatti hanno la spunta verde; tutti si toccano. Sull'iPad resta
// `IndicatorePercorso` (DesignSystem/ComponentiIncontri.swift).

/// Quando un momento ha la spunta (template righe 3767 e 3788): mai quello aperto; gli altri se l'incontro è concluso,
/// se vengono prima di quello aperto, oppure se sono «Durante» e c'è il verbale del copilota.
enum RegoleMomentiIncontro {
    static let ordine: [SchedaIncontro] = [.preparazione, .ascolto, .passi]

    static func fatto(_ momento: SchedaIncontro, aperto: SchedaIncontro, concluso: Bool, verbale: Bool) -> Bool {
        guard momento != aperto else { return false }
        if concluso { return true }
        let i = ordine.firstIndex(of: momento) ?? 0
        let a = ordine.firstIndex(of: aperto) ?? 0
        if i < a { return true }
        return momento == .ascolto && verbale
    }

    /// «Prima», «Durante», «Dopo».
    static func nome(_ m: SchedaIncontro) -> String {
        switch m {
        case .preparazione: return TestiMomentiIncontro.prima
        case .ascolto: return TestiMomentiIncontro.durante
        case .passi: return TestiMomentiIncontro.dopo
        }
    }

    /// «Preparazione», «Ascolto», «Prossimi passi».
    static func sottonome(_ m: SchedaIncontro) -> String {
        switch m {
        case .preparazione: return TestiMomentiIncontro.preparazione
        case .ascolto: return TestiMomentiIncontro.ascolto
        case .passi: return TestiMomentiIncontro.prossimiPassi
        }
    }
}

#if os(macOS)
/// I tre momenti in capsula: `scegli` riceve il momento toccato (chi la usa decide se cambiare subito o chiedere prima di
/// fermare l'ascolto).
struct MomentiIncontroApple: View {
    let aperto: SchedaIncontro
    let concluso: Bool
    let verbale: Bool
    let scegli: (SchedaIncontro) -> Void

    private typealias M = Tema.Apple.Copilota.Momenti

    var body: some View {
        HStack(spacing: M.spazio) {
            ForEach(Array(RegoleMomentiIncontro.ordine.enumerated()), id: \.offset) { n, m in
                if n > 0 {
                    RoundedRectangle(cornerRadius: M.filo.height, style: .continuous)
                        .fill(M.coloreFilo)
                        .frame(width: M.filo.width, height: M.filo.height)
                }
                CapsulaMomentoIncontro(numero: n + 1, nome: RegoleMomentiIncontro.nome(m),
                                       sottonome: RegoleMomentiIncontro.sottonome(m), acceso: m == aperto,
                                       fatto: RegoleMomentiIncontro.fatto(m, aperto: aperto, concluso: concluso, verbale: verbale)) {
                    scegli(m)
                }
            }
        }
        .fixedSize()
    }
}

/// Un momento: tondo 26 (numero, o la spunta se fatto), nome in neretto e sottonome piccolo.
private struct CapsulaMomentoIncontro: View {
    let numero: Int
    let nome: String
    let sottonome: String
    let acceso: Bool
    let fatto: Bool
    let azione: () -> Void

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @State private var sopra = false

    private typealias M = Tema.Apple.Copilota.Momenti

    var body: some View {
        Button(action: azione) {
            HStack(spacing: M.spazioTondo) {
                ZStack {
                    Circle().fill(acceso ? M.fondoTondoAcceso : (fatto ? M.fondoTondoFatto : M.fondoTondo))
                    if fatto {
                        Image(systemName: "checkmark")
                            .carattereApple(M.spunta)
                            .foregroundColor(M.coloreSpunta)
                    } else {
                        Text("\(numero)")
                            .carattereApple(M.numero)
                            .foregroundColor(acceso ? M.numeroAcceso : M.coloreNumero)
                    }
                }
                .frame(width: M.tondo, height: M.tondo)
                VStack(alignment: .leading, spacing: 0) {
                    Text(nome)
                        .carattereApple(M.nome)
                        .foregroundColor(M.coloreNome)
                        .lineLimit(1)
                    Text(sottonome)
                        .carattereApple(M.sottonome)
                        .foregroundColor(M.coloreSottonome)
                        .lineLimit(1)
                }
                .fixedSize()
            }
            .padding(M.padding)
            .background {
                if acceso {
                    Capsule(style: .continuous).fill(M.fondoAcceso)
                } else if sopra {
                    Capsule(style: .continuous).fill(M.fondoSopra)
                }
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(StileSemplice())
        .onHover { dentro in sopra = dentro && !istantanea }
        .animation(Tema.Apple.Moto.animazione(M.animazioneFondo, calmo: calmo, istantanea: istantanea), value: acceso)
        .animation(Tema.Apple.Moto.animazione(M.animazioneFondo, calmo: calmo, istantanea: istantanea), value: sopra)
        .accessibilityLabel(Text("\(numero) \(nome) · \(sottonome)"))
        .accessibilityValue(Text(fatto ? "fatto" : ""))
        .accessibilityAddTraits(acceso ? AccessibilityTraits.isSelected : AccessibilityTraits())
    }
}
#endif
