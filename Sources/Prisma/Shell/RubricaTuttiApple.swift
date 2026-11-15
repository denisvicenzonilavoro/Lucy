#if os(macOS)
import SwiftUI

// «La tua rubrica» con «Tutti i clienti» (migliorie d'uso 2 §2.3 punto 7, 3 e 11; template `rubricaTuttiHTML`, righe
// 3123-3126), solo sul Mac: al posto del dossier, senza un cliente scelto, la testa con l'icona, le quattro cifre dei
// motori (persone seguite, in regola, riesami dell'anno, patrimonio seguito) e il «Da fare» di tutti con cinque voci della
// riga comune. Le cifre vengono dai motori già tenuti da parte (`statoDelLavoro`, `riepilogoPortafoglio`), il «Da fare»
// dal nastro in cache: niente calcoli sull'archivio nel body. Nelle istantanee i numeri sono già completi (lo fa
// `NumeroCheConta`).

struct RubricaTuttiApple: View {
    @Environment(StatoShell.self) var stato

    private typealias T = Tema.Apple.Clienti.TuttiIClienti

    var body: some View {
        let _ = ContaCorpi.segna()
        let lavoro = stato.statoDelLavoro()
        let patrimonio = stato.riepilogoPortafoglio(canale: nil, area: nil).riepilogo.attivita
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                testa
                    .entrataCascata(0)
                HStack(alignment: .top, spacing: T.spazioTessere) {
                    tessera(TestiSceltaCliente.personeSeguite, valore: Double(stato.clienti.count), formato: .intero,
                            suffisso: nil, indice: 1)
                    tessera(TestiSceltaCliente.inRegola, valore: Double(lavoro.inRegola.fatti), formato: .intero,
                            suffisso: TestiSceltaCliente.suTotale(lavoro.inRegola.totale), indice: 2)
                    tessera(TestiSceltaCliente.riesamiAnno, valore: Double(lavoro.riesami.fatti), formato: .intero,
                            suffisso: TestiSceltaCliente.suTotale(lavoro.riesami.totale), indice: 3)
                    tessera(TestiSceltaCliente.patrimonioSeguito, valore: patrimonio, formato: .euro,
                            suffisso: nil, indice: 4)
                }
                .padding(.top, T.tessereSopra)
                if !stato.inModoCliente {
                    DaFareRubricaApple()
                        .padding(.top, T.daFareSopra)
                        .entrataCascata(5)
                }
            }
            .frame(maxWidth: T.larghezzaMassima, alignment: .leading)
            .padding(T.padding)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private var testa: some View {
        HStack(alignment: .center, spacing: T.spazioTesta) {
            Image(systemName: "person.2.fill")
                .font(T.simbolo.font)
                .foregroundColor(T.coloreIcona)
                .frame(width: T.icona, height: T.icona)
                .background {
                    RoundedRectangle(cornerRadius: T.raggioIcona, style: .continuous).fill(T.fondoIcona)
                }
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(Parole.tuttiIClienti)
                    .carattereApple(T.occhiello)
                    .foregroundColor(T.coloreOcchiello)
                Text(TestiSceltaCliente.tuaRubrica)
                    .carattereApple(T.titolo)
                    .foregroundColor(T.coloreTitolo)
                    .lineLimit(1)
                Text(TestiSceltaCliente.tuaRubricaTesto)
                    .carattereApple(T.frase)
                    .foregroundColor(T.coloreFrase)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func tessera(_ nome: String, valore: Double, formato: FormatoCifra, suffisso: String?, indice: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(nome)
                .carattereApple(T.nomeTessera)
                .foregroundColor(T.coloreNomeTessera)
                .lineLimit(1)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                NumeroCheConta(valore, formato: formato, indice: indice)
                    .carattereApple(T.cifra)
                    .foregroundColor(T.coloreCifra)
                    .lineLimit(1)
                if let suffisso {
                    Text(suffisso)
                        .carattereApple(T.suffisso)
                        .foregroundColor(T.coloreSuffisso)
                        .lineLimit(1)
                }
            }
            .minimumScaleFactor(0.7)
        }
        .padding(T.paddingTessera)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(T.superficieTessera, raggio: T.raggioTessera)
        .entrataCascata(indice)
    }
}

/// Il «Da fare» di tutti nella rubrica: «Da fare» con il numero, «Apri tutto ›», cinque voci con il nome e i canali, in
/// fondo «altre N ›» e, senza voci, «Niente da fare.».
private struct DaFareRubricaApple: View {
    @Environment(StatoShell.self) var stato

    private typealias T = Tema.Apple.Clienti.TuttiIClienti

    var body: some View {
        let _ = ContaCorpi.segna()
        let nastro = stato.nastroDaFareCompleto(cliente: nil)
        let voci = Array(nastro.voci.prefix(T.righeDaFare))
        let altre = nastro.totale - voci.count
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: T.spazioTestataDaFare) {
                Text(TestiDaFare.titolo)
                    .carattereApple(T.etichettaDaFare)
                    .foregroundColor(T.coloreEtichettaDaFare)
                NumeroDaFare(numero: nastro.totale)
                Spacer(minLength: 0)
                Button { stato.apriDaFare() } label: {
                    Text(TestiDaFare.apriTutto)
                        .carattereApple(T.collegamento)
                        .foregroundColor(T.coloreCollegamento)
                        .lineLimit(1)
                }
                .buttonStyle(StileSemplice())
                .fixedSize()
            }
            .padding(.bottom, T.sottoTestataDaFare)
            if voci.isEmpty {
                Text(TestiSceltaCliente.nienteDaFare)
                    .carattereApple(T.nomeTessera)
                    .foregroundColor(T.coloreNomeTessera)
                    .padding(T.paddingVuoto)
            }
            ForEach(voci) { v in
                RigaDaFare(voce: v, fatto: { stato.fattoDaFare(v) }, apri: { stato.apriVoceDaFare(v) })
            }
            if altre > 0 {
                Button { stato.apriDaFare() } label: {
                    Text(TestiSceltaCliente.altreVoci(altre))
                        .carattereApple(T.collegamento)
                        .foregroundColor(T.coloreCollegamento)
                        .lineLimit(1)
                }
                .buttonStyle(StileSemplice())
                .padding(T.paddingAltre)
            }
        }
        .padding(T.paddingDaFare)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(T.superficieDaFare, raggio: T.raggioDaFare)
    }
}
#endif
