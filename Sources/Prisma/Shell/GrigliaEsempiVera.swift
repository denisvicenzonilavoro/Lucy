#if os(macOS)
import SwiftUI

// Migliorie d'uso 27, «Vera dice cosa sa fare» (Design/uso/gruppo-04.md §27.3 punto 5): a conversazione vuota, sotto
// il saluto, «Puoi chiedermi, per esempio» con le domande d'esempio in riquadri a due colonne. Ogni riquadro ha il tipo
// in occhiello blu, la domanda e lo scopo; si inclina verso il puntatore ed entra a cascata (con «Riduci movimento» e
// nelle istantanee è già fermo). Un clic fa la domanda, come i suggerimenti in fila. Solo Mac.

/// La griglia degli esempi. Le domande vengono da `EsempiVera.per(cliente:portafoglio:)`.
struct GrigliaEsempiVera: View {
    let esempi: [EsempioDomandaVera]
    @Environment(StatoShell.self) var stato

    var body: some View {
        let e = Tema.Apple.Vera.Esempi.self
        let colonne = Array(repeating: GridItem(.flexible(), spacing: e.spazio, alignment: .top), count: e.colonne)
        VStack(alignment: .leading, spacing: 0) {
            Text(TestiVera.puoiChiedermi)
                .carattereApple(e.occhiello)
                .foregroundColor(e.coloreOcchiello)
                .padding(.top, e.occhielloSopra)
                .padding(.bottom, e.occhielloSotto)
                .padding(.horizontal, 4)
            LazyVGrid(columns: colonne, alignment: .leading, spacing: e.spazio) {
                ForEach(Array(esempi.enumerated()), id: \.element.id) { i, esempio in
                    Button { chiedi(esempio) } label: { RiquadroEsempioVera(esempio: esempio) }
                        .buttonStyle(StileSemplice())
                        .disabled(stato.veraInCorso)
                        .help(esempio.domanda)
                        .entrataCascata(i, base: e.cascataBase, sfocatura: false)
                }
            }
            .frame(maxWidth: e.larghezzaMassima, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// La domanda va dove va lo spunto: nella conversazione del cliente o in quella del portafoglio.
    private func chiedi(_ esempio: EsempioDomandaVera) {
        if let s = esempio.spuntoPortafoglio {
            stato.chiediVeraPortafoglio(s.domanda, spunto: s)
        } else if let s = esempio.spunto {
            stato.chiediVera(s.domanda, spunto: s)
        }
    }
}

/// Un riquadro d'esempio (`.vCard` del template): tipo, domanda, scopo.
private struct RiquadroEsempioVera: View {
    let esempio: EsempioDomandaVera

    var body: some View {
        let e = Tema.Apple.Vera.Esempi.self
        let testi = TestiVera.tipoEsempio(esempio.tipo)
        VStack(alignment: .leading, spacing: e.spazioInterno) {
            Text(testi.tipo)
                .carattereApple(e.tipo)
                .foregroundColor(e.coloreTipo)
                .lineLimit(1)
            Text(esempio.domanda)
                .carattereApple(e.domanda)
                .foregroundColor(e.coloreDomanda)
                .fixedSize(horizontal: false, vertical: true)
            Text(testi.scopo)
                .carattereApple(e.scopo)
                .foregroundColor(e.coloreScopo)
                .fixedSize(horizontal: false, vertical: true)
        }
        .multilineTextAlignment(.leading)
        .padding(e.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .superficieApple(e.superficie, raggio: e.raggio)
        .inclinazione(massimo: e.inclinazione, raggio: e.raggio)
        .contentShape(RoundedRectangle(cornerRadius: e.raggio, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
#endif
