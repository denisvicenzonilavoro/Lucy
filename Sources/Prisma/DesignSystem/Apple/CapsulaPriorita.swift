import SwiftUI

/// Migliorie d'uso 17 «Le priorità in ordine: 1, 2, 3» (`.prio` del template): la capsula «Priorità {n}» accanto al
/// nome dell'area sulle card di Analisi 360 e, con il nome dell'area («Priorità 1 · Protezione»), sulle righe della
/// scheda Bisogni. «Priorità 1» arancio tenue, le altre neutre (`Tema.Apple.Aree360.Area`).
struct CapsulaPriorita: View {
    let numero: Int
    /// Il nome dell'area dopo il numero, nella scheda Bisogni; nil sulle card (il nome è già accanto).
    var area: String? = nil

    var testo: String {
        let base = "Priorità \(numero)"
        return area.map { "\(base) · \($0)" } ?? base
    }

    var body: some View {
        let a = Tema.Apple.Aree360.Area.self
        let prima = numero == 1
        Text(testo)
            .carattereApple(a.priorita)
            .foregroundColor(prima ? a.testoPrimaPriorita : a.testoPriorita)
            .lineLimit(1)
            .fixedSize()
            .padding(a.paddingPriorita)
            .background { Capsule(style: .continuous).fill(prima ? a.fondoPrimaPriorita : a.fondoPriorita) }
    }
}
