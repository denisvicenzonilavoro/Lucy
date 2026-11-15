#if os(macOS)
import SwiftUI

// Migliorie d'uso 26 (solo Mac): la scheda «Da dove vengono le cifre», aperta da «Vera ha usato N dati del dossier ›»
// nella fila dei controlli del messaggio (PannelloMessaggio):
//
//   DA DOVE VENGONO LE CIFRE
//   Il riepilogo dell'incontro di ieri
//   Vera ha scritto il testo con questi dati del dossier di Giulia Rossi: le cifre le dà Prisma.
//   Decisioni ........................................ Portare il versamento per la casa a 550 €…
//   ──────────────────────────────────────────────────────────────────────────────
//   Prossimo incontro ................................ 15 dicembre 2026
//   Scritto da Vera                                                                    [Chiudi]
//
// Le righe sono le cifre vere dell'occasione (`OccasioneMessaggio.cifre`, le sole che il testo può citare); in fondo
// chi ha scritto il testo, senza il nome del modello (regola 9). Esc o «Chiudi» chiude. Valori in
// DesignSystem/Apple/Tema.Apple+Messaggi.swift (`FoglioDati`).

struct FoglioDatiMessaggio: View {
    let titolo: String
    let nomeCliente: String
    let cifre: [CifraMessaggio]
    /// «Scritto da Vera» / «Testo di Prisma»; nil mentre il testo non è ancora pronto.
    let autore: String?
    /// Chi chiude la scheda; nil = il foglio di sistema (`dismiss`).
    var chiudi: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    private typealias F = Tema.Apple.Messaggi.FoglioDati

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(TestiMessaggi.daDoveCifre)
                .carattereApple(F.occhiello)
                .foregroundColor(F.coloreOcchiello)
            Text(titolo)
                .carattereApple(F.titolo)
                .foregroundColor(F.coloreTitolo)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, F.sopraTitolo)
            Text(TestiMessaggi.cifreDelDossier(nomeCliente))
                .carattereApple(F.frase)
                .foregroundColor(F.coloreFrase)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, F.sopraFrase)
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(cifre.enumerated()), id: \.offset) { i, cifra in
                    riga(cifra, primo: i == 0)
                }
            }
            .padding(.top, F.sopraRighe)
            HStack(alignment: .center) {
                if let autore {
                    Text(autore)
                        .carattereApple(F.nota)
                        .foregroundColor(F.coloreNota)
                }
                Spacer(minLength: F.spazioRiga)
                Button(TestiMessaggi.chiudi) { chiudiScheda() }
                    .buttonStyle(.apple)
                    .keyboardShortcut(.cancelAction)
            }
            .padding(.top, F.sopraPulsanti)
        }
        .padding(F.padding)
        .frame(width: F.larghezza, alignment: .leading)
    }

    /// Una riga chiave → valore, con il filo sopra (tranne la prima).
    private func riga(_ cifra: CifraMessaggio, primo: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: F.spazioRiga) {
            Text(cifra.etichetta)
                .carattereApple(F.chiave)
                .foregroundColor(F.coloreChiave)
                .frame(maxWidth: F.larghezzaChiave, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Text(cifra.valore)
                .carattereApple(F.valore)
                .foregroundColor(F.coloreValore)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, F.paddingRiga)
        .frame(maxWidth: .infinity, minHeight: F.altezzaRiga, alignment: .leading)
        .overlay(alignment: .top) {
            if !primo {
                Rectangle().fill(F.filo).frame(height: F.spessoreFilo).allowsHitTesting(false)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func chiudiScheda() {
        if let chiudi {
            chiudi()
        } else {
            dismiss()
        }
    }
}
#endif
