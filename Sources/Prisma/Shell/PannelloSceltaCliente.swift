import SwiftUI

#if os(macOS)
// Il pannello «Di chi parliamo?» (migliorie d'uso 2, template #cliP righe 3082-3095, CSS 455-459): vetro largo 348
// sotto la barra, allineato alla pillola del cliente, con il campo di ricerca, «Tutti i clienti», «Recenti» e
// «Tutti · N» in ordine alfabetico. Esc, un clic fuori o una scelta lo chiudono. Valori in Tema.Apple+SceltaCliente.

/// Dove sta la pillola del cliente nella barra: il pannello si allinea al suo bordo sinistro.
struct AncoraPillolaCliente: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

struct PannelloSceltaCliente: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo
    /// Il bordo sinistro della pillola nella barra (coordinate della shell).
    let sinistra: CGFloat
    @State private var ricerca = ""
    @FocusState private var fuoco: Bool

    private typealias P = Tema.Apple.SceltaCliente.Pannello

    /// Oltre queste righe l'elenco scorre e si impagina solo ciò che si vede.
    private static let righeSenzaScorrere = 12

    var body: some View {
        let _ = ContaCorpi.segna()
        ZStack(alignment: .topLeading) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { chiudi() }
            pannello
                .frame(width: P.larghezza)
                .entrataScheda(Tema.Apple.Moto.animazione(Tema.Apple.Moto.PannelloNotifiche.animazione, calmo: calmo),
                               scala: Tema.Apple.Moto.PannelloNotifiche.scala, ancora: .topLeading,
                               y: Tema.Apple.Moto.PannelloNotifiche.spostamento)
                .padding(.top, P.alto)
                .padding(.leading, max(0, sinistra))
                .padding(.bottom, P.basso)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .onExitCommand { chiudi() }
        .onAppear { DispatchQueue.main.async { fuoco = true } }
    }

    private func chiudi() {
        stato.pannelloCliente = false
    }

    private func scegli(_ id: String?) {
        stato.scegliCliente(id, avviso: true)
        chiudi()
    }

    // MARK: Il pannello

    private var pannello: some View {
        let testo = ricerca.trimmingCharacters(in: .whitespacesAndNewlines)
        let tutti = stato.rubricaOrdinata
        let filtrati = testo.isEmpty ? tutti : tutti.filter {
            $0.nome.localizedCaseInsensitiveContains(testo) || $0.tema.localizedCaseInsensitiveContains(testo)
        }
        let recenti = testo.isEmpty ? stato.recentiVisibili : []
        let scelto = stato.clienteAttivoId
        return VStack(alignment: .leading, spacing: 0) {
            Text(TestiSceltaCliente.titoloPannello)
                .carattereApple(P.titolo)
                .foregroundColor(P.coloreNome)
                .padding(.horizontal, P.paddingRiga.leading)
                .padding(.bottom, P.spazioTitolo)
            campo
                .padding(.bottom, P.spazioTitolo)
            if filtrati.isEmpty {
                Text(TestiSceltaCliente.nessuno)
                    .carattereApple(P.vuoto)
                    .foregroundColor(P.coloreMotto)
                    .padding(P.paddingRiga)
            } else if filtrati.count + recenti.count <= Self.righeSenzaScorrere {
                elenco(filtrati, recenti: recenti, conTutti: testo.isEmpty, scelto: scelto, pigro: false)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    elenco(filtrati, recenti: recenti, conTutti: testo.isEmpty, scelto: scelto, pigro: true)
                }
                .frame(maxHeight: P.altezzaMassimaElenco)
            }
        }
        .padding(P.padding)
        // Vetro che sfoca nell'app; senza sfocatura (istantanee) coprente, come il centro notifiche
        .superficieApple(.vetroSopra, raggio: P.raggio)
    }

    /// «⌕  Cerca per nome», con il fuoco appena aperto.
    private var campo: some View {
        HStack(spacing: P.spazioRiga) {
            Image(systemName: "magnifyingglass")
                .carattereApple(P.campo)
                .foregroundColor(P.coloreMotto)
            TextField(TestiSceltaCliente.cerca, text: $ricerca)
                .textFieldStyle(.plain)
                .carattereApple(P.campo)
                .focused($fuoco)
                .onSubmit {
                    // Invio sceglie il primo trovato
                    let t = ricerca.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !t.isEmpty, let primo = stato.rubricaOrdinata.first(where: {
                        $0.nome.localizedCaseInsensitiveContains(t) || $0.tema.localizedCaseInsensitiveContains(t)
                    }) else { return }
                    scegli(primo.id)
                }
        }
        .padding(.horizontal, P.paddingCampo)
        .frame(height: P.altezzaCampo)
        .background(RoundedRectangle(cornerRadius: P.raggioCampo, style: .continuous).fill(P.fondoCampo))
    }

    @ViewBuilder
    private func elenco(_ filtrati: [Cliente], recenti: [Cliente], conTutti: Bool, scelto: String, pigro: Bool) -> some View {
        let righe = Group {
            if conTutti {
                RigaSceltaCliente(cliente: nil, scelta: scelto.isEmpty) { scegli(nil) }
            }
            if !recenti.isEmpty {
                titoloGruppo(TestiSceltaCliente.recenti)
                ForEach(recenti) { c in
                    RigaSceltaCliente(cliente: c, scelta: c.id == scelto) { scegli(c.id) }
                }
            }
            titoloGruppo(TestiSceltaCliente.tutti(filtrati.count))
            ForEach(filtrati) { c in
                RigaSceltaCliente(cliente: c, scelta: c.id == scelto) { scegli(c.id) }
            }
        }
        if pigro {
            LazyVStack(alignment: .leading, spacing: 0) { righe }
        } else {
            VStack(alignment: .leading, spacing: 0) { righe }
        }
    }

    private func titoloGruppo(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(P.gruppo)
            .foregroundColor(P.coloreGruppo)
            .padding(.horizontal, P.paddingRiga.leading)
            .padding(.top, P.sopraGruppo)
            .padding(.bottom, P.sottoGruppo)
    }
}

/// Una riga del pannello: «Tutti i clienti» (cliente nil) o un cliente con avatar 36, nome e motto; a destra la spunta
/// se è la scelta, altrimenti i pallini dei canali.
private struct RigaSceltaCliente: View {
    let cliente: Cliente?
    let scelta: Bool
    let azione: () -> Void
    @State private var sopra = false

    private typealias P = Tema.Apple.SceltaCliente.Pannello

    var body: some View {
        Button(action: azione) {
            HStack(spacing: P.spazioRiga) {
                if let c = cliente {
                    AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: P.avatar)
                } else {
                    Image(systemName: "person.2.fill")
                        .carattereApple(P.glifoTutti)
                        .foregroundColor(P.coloreSpunta)
                        .frame(width: P.avatar, height: P.avatar)
                        .background(Circle().fill(P.fondoGlifo))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(cliente?.nome ?? TestiSceltaCliente.tuttiIClienti)
                        .carattereApple(P.nome)
                        .foregroundColor(P.coloreNome)
                        .lineLimit(1)
                    let sotto = cliente?.tema ?? TestiSceltaCliente.tuttiSottotitolo
                    if !sotto.isEmpty {
                        Text(sotto)
                            .carattereApple(P.motto)
                            .foregroundColor(P.coloreMotto)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
                if scelta {
                    Image(systemName: "checkmark")
                        .carattereApple(P.spunta)
                        .foregroundColor(P.coloreSpunta)
                } else if let c = cliente {
                    HStack(spacing: P.spazioPallini) {
                        ForEach(c.canali, id: \.self) { canale in
                            Circle()
                                .fill(canale == .alleanza ? P.alleanza : P.indipendente)
                                .frame(width: P.pallino, height: P.pallino)
                        }
                    }
                }
            }
            .padding(P.paddingRiga)
            .background {
                RoundedRectangle(cornerRadius: P.raggioRiga, style: .continuous)
                    .fill(scelta ? P.rigaScelta : (sopra ? P.rigaSopra : Color.clear))
            }
            .contentShape(RoundedRectangle(cornerRadius: P.raggioRiga, style: .continuous))
        }
        .buttonStyle(StileSemplice())
        .onHover { s in withAnimation(Tema.Moto.passaggio) { sopra = s } }
    }
}
#endif
