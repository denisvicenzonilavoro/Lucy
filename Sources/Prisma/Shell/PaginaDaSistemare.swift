#if os(macOS)
import SwiftUI

// Migliorie d'uso 31 «Si vede cosa resta da sistemare» (Design/uso/gruppo-04.md §31, template righe 4033-4073): la
// prima voce delle Impostazioni sul Mac, al posto della Panoramica con le quattro tessere.
//
//   Da sistemare
//   Tre cose, poi Prisma è a posto.
//   ┌────────────────────────────────────────────────────────────┐
//   │ Nessun backup ancora                              [Sistema] │
//   │ Il primo backup protegge tutto il lavoro fatto finora.      │
//   └────────────────────────────────────────────────────────────┘
//   A POSTO
//   ┌────────────────────────────────────────────────────────────┐
//   │ Vera è pronta                                            ✓  │
//   └────────────────────────────────────────────────────────────┘
//
// «Sistema» apre la pagina della voce e scorre alla riga (con l'ancora). A zero: «Tutto a posto» e «Non c’è niente da
// sistemare.». Righe a cascata come le altre pagine; «Riduci movimento» e istantanee: subito ferme.
// Valori in Tema.Apple.Impostazioni.DaSistemare.

struct PaginaDaSistemare: View {
    @Environment(StatoShell.self) private var stato

    private typealias D = Tema.Apple.Impostazioni.DaSistemare
    private typealias P = Tema.Apple.Impostazioni.Pagina
    private typealias T = TestiDaSistemare

    var body: some View {
        let esito = stato.daSistemare()
        let n = esito.conteggio
        VStack(alignment: .leading, spacing: 0) {
            Text(n == 0 ? T.tuttoAPosto : T.titolo)
                .carattereApple(P.titolo)
                .foregroundColor(P.coloreTitolo)
                .padding(.top, P.sopraTitolo)
                .padding(.bottom, D.sottoTitolo)
                .entrataCascata(0, base: Tema.Apple.Moto.Cascata.baseDentroApp, sfocatura: false)
            Text(T.conteggio(n))
                .carattereApple(D.frase)
                .foregroundColor(D.coloreFrase)
                .padding(.bottom, D.sottoFrase)
                .cascataImpostazioni(1)
            if n > 0 {
                GruppoImpostazioni {
                    ForEach(Array(esito.daSistemare.enumerated()), id: \.element.id) { i, v in
                        RigaImpostazione(titolo: v.titolo, sottotitolo: v.spiegazione, ultima: i == n - 1) {
                            Button(T.sistema) { apri(v) }
                                .buttonStyle(.applePrimario)
                                .fixedSize()
                                .accessibilityLabel(Text("\(T.sistema): \(v.titolo)"))
                        }
                        .cascataImpostazioni(2 + i)
                    }
                }
            }
            if !esito.aPosto.isEmpty {
                GruppoImpostazioni(titolo: T.aPosto) {
                    ForEach(Array(esito.aPosto.enumerated()), id: \.element.id) { i, v in
                        RigaImpostazione(titolo: v.titolo, sottotitolo: v.spiegazione, ultima: i == esito.aPosto.count - 1) {
                            Image(systemName: Tema.Apple.Impostazioni.Laterale.simboloSpunta)
                                .carattereApple(D.spunta)
                                .foregroundColor(D.coloreSpunta)
                                .accessibilityLabel(Text(T.aPosto))
                        }
                        .cascataImpostazioni(2 + n + i)
                    }
                }
                .padding(.top, n > 0 ? D.sopraOcchiello : 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// «Sistema»: la pagina della voce, e la riga se ha un'ancora (`AppImpostazioni.scorri`).
    private func apri(_ v: VoceDaSistemare) {
        stato.ancoraImpostazioni = v.ancora
        stato.schedaImpostazioni = v.pagina
    }
}
#endif
