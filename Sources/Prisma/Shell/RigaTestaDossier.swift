#if os(macOS)
import SwiftUI

// Migliorie d'uso 12 «Più spazio al dossier» (Design/uso/gruppo-02.md §12, template righe 3415-3433, solo Mac).
// Con un cliente scelto nella Rubrica la riga unica in testa alla finestra di Clienti (migliorie d'uso 4) dice
// «Il dossier di Marco.» con «45 anni · Libero professionista» e, a destra, le azioni del cliente (`dossierAzioni`):
// le etichette dei canali, «☆ Preferito», «Modifica», «Altro ⌄» e «Prospetti» (primario). La testata grande nella
// pagina non c'è più (DossierApple, `SchedeDossier.conRigaInTesta`). I pulsanti tengono sempre il nome: quando lo
// spazio manca gli ultimi passano nel menu «Altro ⌄», che c'è sempre (decisione 12.6) con «Analisi 360», «Un anno
// insieme» e, per chi non ha «L'azienda» nell'indice, «Aggiungi un'azienda…». Valori in
// Tema.Apple+Clienti.swift (`Tema.Apple.Clienti.RigaDossier`) e in `Tema.Apple.RigaTesta`.

/// Il dossier nella riga in testa: c'è quando Clienti mostra il dossier di un cliente (Rubrica con un cliente scelto, o
/// modalità cliente con il suo cliente). Altrimenti la riga dell'app di sempre (`altrimenti`).
struct RigaTestaClienti<Altrimenti: View>: View {
    @Environment(StatoShell.self) var stato
    let attiva: Bool
    @ViewBuilder let altrimenti: () -> Altrimenti

    var body: some View {
        if let c = stato.clienteAttivo, stato.inModoCliente || stato.vistaClienti == .rubrica {
            RigaTestaDossier(cliente: c, attiva: attiva)
        } else {
            altrimenti()
        }
    }
}

/// Titolo, sottotitolo e azioni del cliente nella riga in testa. Se lo spazio manca, prima sparisce il sottotitolo,
/// poi «Modifica» e infine «Preferito» passano in «Altro ⌄» (e le etichette dei canali si fanno compatte): mai un
/// pulsante ridotto alla sola icona.
struct RigaTestaDossier: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente
    let attiva: Bool

    private typealias R = Tema.Apple.RigaTesta
    private typealias K = Tema.Apple.Clienti.RigaDossier

    var body: some View {
        let _ = ContaCorpi.segna()
        ViewThatFits(in: .horizontal) {
            riga(sottotitolo: true, inAltro: 0)
            riga(sottotitolo: true, inAltro: 1)
            riga(sottotitolo: false, inAltro: 0)
            riga(sottotitolo: false, inAltro: 1)
            riga(sottotitolo: false, inAltro: 2)
        }
        // «Nuovo cliente» torna con «‹ Rubrica», ma ⌘N resta anche nel dossier (come con la testata di Clienti)
        .background {
            Button("Nuovo cliente") { stato.apriNuovoCliente() }
                .keyboardShortcut("n", modifiers: .command)
                .opacity(0)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    // MARK: Testi

    /// «Il dossier di Marco.»: il nome di battesimo (la scheda fiscale, altrimenti la prima parola del nome).
    private var titolo: String {
        "Il dossier di \(StatoShell.nomeDiBattesimo(cliente))."
    }

    /// «45 anni · Libero professionista»: le parti che ci sono (il motto sta sotto il nome nell'indice, migliorie d'uso 11).
    private var testoSottotitolo: String {
        let parti: [String] = [cliente.eta.map { "\($0) anni" } ?? "", cliente.professione]
        return parti
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    // MARK: La riga

    /// Una delle versioni della riga. `inAltro`: 0 tutte le azioni intere; 1 «Modifica» in «Altro»; 2 anche «Preferito»
    /// e le etichette dei canali compatte.
    private func riga(sottotitolo: Bool, inAltro: Int) -> some View {
        HStack(alignment: .center, spacing: R.spazio) {
            Text(titolo)
                .carattereApple(R.titolo)
                .foregroundColor(attiva ? R.coloreTitolo : R.coloreTitoloSpento)
                .lineLimit(1)
            if sottotitolo, !testoSottotitolo.isEmpty {
                Text(testoSottotitolo)
                    .carattereApple(R.sottotitolo)
                    .foregroundColor(R.coloreSottotitolo)
                    .lineLimit(1)
            }
            Spacer(minLength: R.spazio)
            azioni(inAltro: inAltro)
        }
    }

    private func azioni(inAltro: Int) -> some View {
        HStack(spacing: K.spazioAzioni) {
            ForEach(cliente.canali) { EtichettaCanaleApple(canale: $0, compatta: inAltro >= 2) }
            // «Luce» giro 13 (§9.1.6): il cliente nato dalla carta d'identità non ha ancora un canale
            if cliente.canali.isEmpty { EtichettaCanaleDaScegliere() }
            if inAltro < 2 {
                preferito
                    .padding(.leading, K.margineDopoCanali)
            }
            if inAltro < 1 {
                Button(action: modifica) { Text("Modifica") }
                    .buttonStyle(.apple)
                    .help("Modifica la scheda del cliente")
            }
            altro(inAltro: inAltro)
            Button("Prospetti", action: apriProspetti)
                .buttonStyle(.applePrimario)
        }
        .fixedSize()
    }

    // MARK: Azioni

    /// «☆ Preferito» / «★ Preferito»: arancio delle scritte quando il cliente è tra i preferiti; il clic lo alterna e
    /// l'avviso dice il nome intero (template: `toast(c.n + ' è tra i preferiti')`).
    private var preferito: some View {
        let p = cliente.preferito
        return Button(action: alternaPreferito) {
            Text(p ? "★ Preferito" : "☆ Preferito")
                .foregroundColor(p ? K.colorePreferito : Tema.Apple.Colore.inchiostro)
        }
        .buttonStyle(.apple)
        .help(p ? "Togli dai preferiti" : "Aggiungi ai preferiti")
        .accessibilityLabel(p ? "Preferito, togli dai preferiti" : "Aggiungi ai preferiti")
    }

    /// «Altro ⌄»: sempre, con «Analisi 360», «Un anno insieme» e «Aggiungi un'azienda…»; prima, quando non ci stanno
    /// nella riga, «Preferito» e «Modifica».
    private func altro(inAltro: Int) -> some View {
        Button {
            apriMenuAzioni(vociAltro(inAltro: inAltro))
        } label: {
            HStack(spacing: K.spazioFreccia) {
                Text("Altro")
                Image(systemName: "chevron.down")
                    .font(K.freccia.font)
            }
        }
        .buttonStyle(.apple)
        .help("Altre azioni sul cliente")
    }

    private func vociAltro(inAltro: Int) -> [VoceMenuAzioni] {
        var voci: [VoceMenuAzioni] = []
        if inAltro >= 2 {
            voci.append(.azione("Preferito", spuntata: cliente.preferito,
                                aiuto: cliente.preferito ? "Togli dai preferiti" : "Aggiungi ai preferiti") { alternaPreferito() })
        }
        if inAltro >= 1 {
            voci.append(.azione("Modifica", aiuto: "Modifica la scheda del cliente") { modifica() })
        }
        if !voci.isEmpty { voci.append(.separatore) }
        voci.append(.azione("Analisi 360", aiuto: "Le aree di analisi del cliente") { apri(.analisi360) })
        voci.append(.azione(TestiAnnoInsieme.titolo, aiuto: "Il report dell'anno per il cliente, in Prospetti") { apriAnnoInsieme() })
        // Decisione 11.6: «L'azienda» sta nell'indice per chi ce l'ha o fa l'imprenditore o il titolare; per gli altri
        // si aggiunge da qui (apre la sezione con il vuoto di sempre)
        if !SchedaCliente.mostraAzienda(per: cliente), !stato.inModoCliente, !stato.solaLettura,
           stato.schedaCliente != .azienda {
            voci.append(.separatore)
            let s = stato
            voci.append(.azione("Aggiungi un'azienda…",
                                aiuto: "Apre «L'azienda»: quota, ruolo, dipendenti e fatturato li scrivi tu") { s.schedaCliente = .azienda })
        }
        return voci
    }

    private func alternaPreferito() {
        let era = cliente.preferito
        stato.alternaPreferito(cliente.id)
        // Nel pulsante della riga, non in `alternaPreferito` (che resta di tutte le piattaforme)
        stato.mostraAvviso(era ? "\(cliente.nome) non è più tra i preferiti" : "\(cliente.nome) è tra i preferiti")
    }

    /// Il modulo di oggi: lo apre Clienti, che lo tiene (`richiestaModificaCliente`).
    private func modifica() {
        stato.richiestaModificaCliente = cliente.id
    }

    private func apriProspetti() { apri(.presentazioni) }

    private func apri(_ app: AppPrisma) {
        stato.clienteAttivoId = cliente.id
        stato.apri(app)
    }

    /// «Un anno insieme» del cliente, in Prospetti.
    private func apriAnnoInsieme() {
        stato.clienteAttivoId = cliente.id
        stato.apriProspetto(.annoInsieme)
    }
}
#endif
