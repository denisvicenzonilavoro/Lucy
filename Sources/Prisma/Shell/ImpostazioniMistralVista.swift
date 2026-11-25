import SwiftUI

#if os(macOS)
/// Impostazioni › Lucy › «Mistral in cloud» (decisione dell'utente del 25 novembre 2026): l'interruttore, la chiave
/// (solo nel Portachiavi, mai visibile dopo il salvataggio) e il modello. Con l'interruttore acceso le domande
/// all'assistente, con i dati dei clienti che contengono, vanno a Mistral AI (Unione Europea); spento, si torna a Ollama
/// sul Mac.
struct GruppoMistralImpostazioni: View {
    @Environment(StatoShell.self) private var stato
    @State private var chiaveNuova = ""
    @State private var chiaveSalvata = PortachiaviMistral.presente
    @State private var esito: String?

    var body: some View {
        let vera = stato.dati.impostazioni.vera
        let acceso = vera.fornitore == .mistral
        VStack(alignment: .leading, spacing: 8) {
            GruppoImpostazioni(titolo: "Mistral in cloud") {
                RigaImpostazione(titolo: "Usa Mistral in cloud",
                                 sottotitolo: acceso ? "Acceso: le domande vanno a Mistral (UE)." : "Spento: lavora il modello sul Mac.",
                                 aiuto: "Con Mistral in cloud le domande all'assistente, con i dati dei clienti che contengono, vanno ai server di Mistral AI nell'Unione Europea, con la tua chiave") {
                    Toggle(isOn: Binding(get: { acceso }, set: { usa in
                        stato.dati.impostazioni.vera.fornitore = usa ? .mistral : .ollama
                        stato.verificaMotoreLocale()
                    })) { EmptyView() }
                        .toggleStyle(.appleSenzaEtichetta)
                        .disabled(stato.solaLettura)
                }
                RigaImpostazione(titolo: "Chiave API", sottotitolo: chiaveSalvata ? "Salvata nel Portachiavi del Mac." : "Da console.mistral.ai › API Keys.") {
                    HStack(spacing: 8) {
                        SecureField(chiaveSalvata ? "••••••••" : "La tua chiave", text: $chiaveNuova)
                            .campoTesto()
                            .frame(width: 220)
                            .onSubmit(salva)
                        Button("Salva", action: salva)
                            .buttonStyle(StilePulsanteRigaImpostazioni())
                            .disabled(chiaveNuova.trimmingCharacters(in: .whitespaces).isEmpty)
                        if chiaveSalvata {
                            Button("Togli") {
                                PortachiaviMistral.elimina()
                                chiaveSalvata = false
                                esito = "Chiave tolta dal Portachiavi."
                                stato.verificaMotoreLocale()
                            }
                            .buttonStyle(StilePulsanteRigaImpostazioni())
                        }
                    }
                }
                RigaImpostazione(titolo: "Modello", sottotitolo: "Small per tutti i giorni, Large per i lavori lunghi.", ultima: true) {
                    MenuTendina(selezione: Bindable(stato.dati).impostazioni.vera.modelloMistral,
                                opzioni: FornitoreMistral.modelliProposti.map { ($0, $0) }, larghezza: 220)
                        .onChange(of: stato.dati.impostazioni.vera.modelloMistral) { _ in stato.verificaMotoreLocale() }
                }
            }
            if let esito {
                NotaImpostazioni(esito)
            }
            NotaImpostazioni("Con Mistral in cloud le domande e i dati dei clienti che contengono escono dal Mac verso Mistral AI (Unione Europea). La chiave resta solo nel Portachiavi: mai nell'archivio né nei backup.")
        }
    }

    private func salva() {
        let k = chiaveNuova.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !k.isEmpty else { return }
        if PortachiaviMistral.salva(k) {
            chiaveSalvata = true
            chiaveNuova = ""
            esito = "Chiave salvata nel Portachiavi."
            stato.verificaMotoreLocale()
        } else {
            esito = "Il Portachiavi non ha accettato la chiave: riprova."
        }
    }
}
#endif
