#if os(macOS)
import AppKit
import SwiftUI

// Migliorie d'uso 11 «Il dossier ha un indice» (Design/uso/gruppo-02.md §11, template righe 3391-3437): con un cliente
// scelto la colonna di sinistra di Clienti non è più la rubrica ma l'indice del suo dossier, largo 216:
//
//   ‹ Rubrica
//   (MB) Marco Bianchi
//        Mettere al sicuro la famiglia
//   LA PERSONA
//   ▌Panoramica                 (3)   ← le cose da fare, rosso pieno
//    Anagrafica · Famiglia · L'azienda · Profilo · Bisogni
//   IL PIANO
//    Obiettivi                  (1)   ← non in tempo, arancio tenue
//    Linea della vita · Nel tempo
//   LE CARTE
//    Documenti                  (2)   ← da leggere o con differenze, neutro
//    In regola                  (1)   ← scadute, rosso tenue
//    Riesami · Note
//
// - Il clic su una voce scrive `stato.schedaCliente`: il cambio animato (uscita y +6, poi cascata) lo fa già
//   `DossierApple.cambiaScheda`, e il presentatore del dettaglio chiude il dettaglio aperto. La voce già scelta non fa
//   niente.
// - I numeri si leggono una volta per cliente da `contiIndiceDossier` (in `ricavato`, sopra le voci della cache per
//   cliente); con zero niente numero. In modalità cliente niente «‹ Rubrica» né cose da fare.
// - Finestra stretta (resta solo il dossier): `MenuSezioneDossier`, la capsula «Sezione: Panoramica ⌄» con i tre gruppi.
// Valori in DesignSystem/Apple/Tema.Apple+Clienti.swift (`Tema.Apple.Clienti.Indice`).

// MARK: - I numeri dell'indice

/// I numeri piccoli accanto alle voci dell'indice: zero = niente numero.
struct ContiIndiceDossier: Equatable {
    /// Panoramica: le cose da fare del cliente (l'unico «Da fare», migliorie d'uso 3).
    var daFare = 0
    /// Obiettivi: in ritardo, senza versamenti o che non ci arrivano (migliorie d'uso 13), non i già raggiunti.
    var obiettivi = 0
    /// Documenti: da leggere o con differenze, un documento una volta sola.
    var documenti = 0
    /// In regola: le voci scadute.
    var inRegola = 0

    func numero(_ s: SchedaCliente) -> Int {
        switch s {
        case .panoramica: return daFare
        case .obiettivi: return obiettivi
        case .documenti: return documenti
        case .inRegola: return inRegola
        default: return 0
        }
    }
}

extension StatoShell {
    /// I numeri dell'indice del dossier di un cliente, letti in un colpo e tenuti da parte finché non cambiano i dati
    /// dei calcoli, il giorno, la modalità cliente o l'ora (le cose da fare dipendono dall'ora, come il nastro).
    func contiIndiceDossier(_ id: String) -> ContiIndiceDossier {
        let modo = inModoCliente
        return ricavato("indice-dossier|\(id)|\(DerivatiDati.ora())") { () -> ContiIndiceDossier in
            var conti = ContiIndiceDossier()
            // In modalità cliente il quadro non mostra il «Da fare»: neanche l'indice
            if !modo { conti.daFare = nastroDaFareCompleto(cliente: id).totale }
            conti.obiettivi = obiettiviNonInTempo(id)
            conti.documenti = vociDocumenti(id).filter {
                MotoreDocumenti.appartiene($0, a: .daLeggere) || MotoreDocumenti.appartiene($0, a: .conDifferenze)
            }.count
            conti.inRegola = conformitaCliente(id)?.scadute.count ?? 0
            return conti
        }
    }
}

// MARK: - Indice

/// L'indice del dossier del cliente scelto, nella colonna di sinistra di Clienti (al posto della rubrica).
struct IndiceDossierApple: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    var body: some View {
        let _ = ContaCorpi.segna()
        let k = Tema.Apple.Clienti.Indice.self
        let scelta = stato.schedaCliente
        let conti = stato.contiIndiceDossier(cliente.id)
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                if !stato.inModoCliente {
                    RitornoRubricaIndice { stato.scegliCliente(nil) }
                }
                testa
                ForEach(SchedaCliente.indice(per: cliente, scelta: scelta), id: \.titolo) { gruppo in
                    Text(gruppo.titolo)
                        .carattereApple(k.etichettaGruppo)
                        .foregroundColor(k.coloreEtichettaGruppo)
                        .padding(k.paddingEtichettaGruppo)
                    ForEach(gruppo.voci, id: \.self) { s in
                        VoceIndiceDossier(titolo: s.titolo, numero: conti.numero(s), tono: NumeroIndice.Tono(s),
                                          scelta: s == scelta) {
                            guard stato.schedaCliente != s else { return }
                            stato.schedaCliente = s
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(k.padding)
    }

    /// Avatar 40, nome 14,5 bold e motto 12 grigio, su una riga con i puntini.
    private var testa: some View {
        let k = Tema.Apple.Clienti.Indice.self
        return HStack(spacing: k.spazioTesta) {
            AvatarCliente(iniziali: cliente.iniziali, tinta: cliente.tinta.colori, lato: k.avatar)
            VStack(alignment: .leading, spacing: k.spazioNomeMotto) {
                Text(cliente.nome)
                    .carattereApple(k.nome)
                    .foregroundColor(k.coloreNome)
                if !cliente.tema.isEmpty {
                    Text(cliente.tema)
                        .carattereApple(k.motto)
                        .foregroundColor(k.coloreMotto)
                }
            }
            .lineLimit(1)
            .truncationMode(.tail)
        }
        .padding(k.paddingTesta)
    }
}

/// «‹ Rubrica»: torna a «Tutti i clienti» (la rubrica a sinistra).
private struct RitornoRubricaIndice: View {
    let azione: () -> Void

    var body: some View {
        let k = Tema.Apple.Clienti.Indice.self
        return VoceIndiceCornice(scelta: false, azione: azione) {
            HStack(spacing: k.spazioVoce) {
                Image(systemName: "chevron.left")
                    .font(k.simboloRitorno.font)
                Text("Rubrica")
                    .carattereApple(k.ritorno)
                Spacer(minLength: 0)
            }
            .foregroundColor(k.coloreRitorno)
        }
        .help("Torna alla rubrica: tutti i clienti")
        .accessibilityLabel("Torna alla rubrica")
    }
}

/// Una voce dell'indice: alta 32, raggio 12, 13,5 medio; la scelta sul fondo accento al 13%, il numero a destra.
private struct VoceIndiceDossier: View {
    let titolo: String
    let numero: Int
    let tono: NumeroIndice.Tono
    let scelta: Bool
    let azione: () -> Void

    var body: some View {
        let k = Tema.Apple.Clienti.Indice.self
        return VoceIndiceCornice(scelta: scelta, azione: azione) {
            HStack(spacing: k.spazioVoce) {
                Text(titolo)
                    .carattereApple(k.voce)
                    .foregroundColor(k.coloreVoce)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if numero > 0 {
                    NumeroIndice(n: numero, tono: tono)
                }
            }
        }
        .accessibilityLabel(numero > 0 ? "\(titolo), \(numero)" : titolo)
        .accessibilityAddTraits(scelta ? AccessibilityTraits.isSelected : AccessibilityTraits())
    }
}

/// La riga cliccabile dell'indice con il fondo della scelta e del puntatore.
private struct VoceIndiceCornice<Etichetta: View>: View {
    let scelta: Bool
    let azione: () -> Void
    @ViewBuilder let etichetta: () -> Etichetta

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea
    @State private var sopra = false

    var body: some View {
        let k = Tema.Apple.Clienti.Indice.self
        let forma = RoundedRectangle(cornerRadius: k.raggioVoce, style: .continuous)
        return Button(action: azione) {
            etichetta()
                .padding(.horizontal, k.paddingVoce)
                .frame(maxWidth: .infinity, minHeight: k.altezzaVoce, alignment: .leading)
                .background {
                    if scelta {
                        forma.fill(k.voceScelta)
                    } else if sopra {
                        forma.fill(k.voceSopra)
                    }
                }
                .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .onHover { dentro in sopra = dentro && !istantanea }
        .animation(animazione, value: scelta)
        .animation(animazione, value: sopra)
    }

    private var animazione: Animation? {
        Tema.Apple.Moto.animazione(Tema.Apple.Clienti.Indice.animazioneFondo, calmo: calmo, istantanea: istantanea)
    }
}

/// Il numero piccolo accanto a una voce dell'indice, nei quattro toni del template.
struct NumeroIndice: View {
    enum Tono {
        /// Le cose da fare: rosso pieno con il testo bianco.
        case urgente
        /// Gli obiettivi che non ci arrivano: arancio tenue con il testo arancio.
        case attenzione
        /// Le voci scadute di In regola: rosso tenue con il testo rosso.
        case errore
        /// I documenti da guardare: neutro.
        case neutro

        init(_ s: SchedaCliente) {
            switch s {
            case .panoramica: self = .urgente
            case .obiettivi: self = .attenzione
            case .inRegola: self = .errore
            default: self = .neutro
            }
        }
    }

    let n: Int
    let tono: Tono

    var body: some View {
        let k = Tema.Apple.Clienti.Indice.self
        let colori: (fondo: Color, testo: Color) = {
            switch tono {
            case .urgente: return (k.fondoUrgente, k.testoUrgente)
            case .attenzione: return (k.fondoAttenzione, k.testoAttenzione)
            case .errore: return (k.fondoErrore, k.testoErrore)
            case .neutro: return (k.fondoNeutro, k.testoNeutro)
            }
        }()
        return Text("\(n)")
            .carattereApple(k.numero)
            .foregroundColor(colori.testo)
            .padding(k.paddingNumero)
            .background { Capsule(style: .continuous).fill(colori.fondo) }
            .fixedSize()
    }
}

// MARK: - Finestra stretta

/// «Sezione: Panoramica ⌄»: nella finestra stretta l'indice non ci sta e diventa un menu del Mac, con i tre gruppi e la
/// sezione aperta spuntata (decisione 11.6).
struct MenuSezioneDossier: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    var body: some View {
        let s = Tema.Apple.Clienti.Schede.self
        let scelta = stato.schedaCliente
        return Button(action: apri) {
            HStack(spacing: s.spazioFreccia) {
                Text(Tema.Apple.Clienti.Indice.prefissoMenu + scelta.titolo)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(s.freccia.font)
            }
            .carattereApple(Tema.Apple.Carattere.barra)
            .foregroundColor(Tema.Apple.Colore.inchiostro)
            .padding(Tema.Apple.Misura.Padding.voceSegmentato)
            .padding(Tema.Apple.Misura.Padding.segmentato)
            .background { Capsule(style: .continuous).fill(Tema.Apple.Colore.chip) }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(StileSemplice())
        .help("Le sezioni del dossier")
        .accessibilityLabel("Sezione, \(scelta.titolo)")
    }

    /// Il menu del Mac: modale finché non si sceglie, quindi il bersaglio delle voci vive abbastanza.
    private func apri() {
        let gruppi = SchedaCliente.indice(per: cliente, scelta: stato.schedaCliente)
        let voci = gruppi.flatMap { $0.voci }
        let attuale = stato.schedaCliente
        let menu = NSMenu()
        let bersaglio = BersaglioMenuAltro { [stato] i in
            guard i >= 0, i < voci.count, stato.schedaCliente != voci[i] else { return }
            stato.schedaCliente = voci[i]
        }
        var i = 0
        for (g, gruppo) in gruppi.enumerated() {
            if g > 0 { menu.addItem(.separator()) }
            let titolo = NSMenuItem(title: gruppo.titolo, action: nil, keyEquivalent: "")
            titolo.isEnabled = false
            menu.addItem(titolo)
            for v in gruppo.voci {
                let voce = NSMenuItem(title: v.titolo, action: #selector(BersaglioMenuAltro.scegli(_:)), keyEquivalent: "")
                voce.target = bersaglio
                voce.tag = i
                voce.state = v == attuale ? .on : .off
                menu.addItem(voce)
                i += 1
            }
        }
        _ = withExtendedLifetime(bersaglio) {
            menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        }
    }
}
#endif
