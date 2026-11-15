#if os(macOS)
import SwiftUI

// Migliorie d'uso 14 «Le posizioni prima di tutto» (Design/uso/gruppo-02.md §14.3 punto 5): le cinque analisi delle
// posizioni del cliente, una schermata ciascuna. Il contenuto è il pannello di oggi da solo, in cima, in uno
// scorrimento suo: titolo, sottotitolo, capsula di stato e «Report per il cliente» li disegna già il `PannelloAnalisi`
// di ogni pannello, con le stesse parole del template (nessuna testata in più). La coerenza resta senza «Report per il
// cliente»: il prospetto non esiste.
//
// Senza dati (oggi il pannello non compariva) la voce dell'indice resta e la schermata dice in una riga perché è
// vuota, con «Aggiungi una posizione» (decisione 14.6). Le condizioni di «vuoto» sono quelle di prima.

struct AnalisiPosizioniApple: View {
    @Environment(StatoShell.self) var stato
    let vista: VistaPosizioniCliente
    let cliente: Cliente

    var body: some View {
        let _ = ContaCorpi.segna()
        let k = Tema.Apple.Posizioni.Quadro.self
        return ScrollView {
            VStack(alignment: .leading, spacing: k.spazioAnalisi) {
                contenuto
                    .entrataCascata(0, base: 0)
            }
            .padding(k.margine)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    /// Il pannello della schermata, calcolato una volta e riusato finché i dati non cambiano (DerivatiDati).
    @ViewBuilder private var contenuto: some View {
        let analisi = stato.analisiDossier(cliente.id)
        switch vista {
        case .quadro:
            EmptyView()
        case .patrimonio:
            if !analisi.patrimonio.vuoto {
                PannelloPatrimonio(p: analisi.patrimonio)
            } else {
                vuoto("Servono posizioni da proiettare nel tempo: investimenti, risparmio o previdenza in essere.")
            }
        case .resistenza:
            if !analisi.prova.vuota {
                PannelloResistenza(prova: analisi.prova)
            } else {
                vuoto("Servono posizioni finanziarie in essere, con il profilo di rischio del cliente.")
            }
        case .coerenza:
            // Rischio oltre la propensione e concentrazione su emittente o canale
            let coerenza = stato.coerenzaCliente(cliente)
            if coerenza.oggi.patrimonioFinanziario > 0 || coerenza.conProposte != nil {
                PannelloCoerenza(esito: coerenza)
            } else {
                vuoto("Servono posizioni finanziarie in essere o una proposta.")
            }
        case .costi:
            if !analisi.costi.vuota {
                PannelloCosti(analisi: analisi.costi)
            } else {
                vuoto("Servono posizioni con i costi indicati: costo d'ingresso, costo annuo o trattenuto.")
            }
        case .successione:
            if let successione = analisi.successione, !successione.vuota {
                PannelloSuccessione(s: successione)
            } else {
                vuoto("Servono le posizioni del cliente e la sua famiglia, con i beneficiari delle polizze.")
            }
        }
    }

    /// La schermata vuota: il titolo dell'analisi, perché è vuota, e il modo di completarla.
    private func vuoto(_ perche: String) -> some View {
        PannelloAnalisi(titolo: vista.titolo, nota: perche) { EmptyView() } contenuto: {
            HStack(spacing: Tema.Apple.Posizioni.Quadro.spazio) {
                Button("Aggiungi una posizione") { stato.richiestaNuovaPosizione = .inEssere }
                    .buttonStyle(.appleSobrio)
                    .disabled(stato.solaLettura)
                Spacer(minLength: 0)
            }
        }
    }
}
#endif
