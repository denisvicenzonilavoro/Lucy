import SwiftUI

#if os(macOS)
/// Il vuoto delle app che lavorano su una persona quando la barra dice «Tutti i clienti» (migliorie d'uso 2, template
/// `vuotoCli()`, righe 3106-3115): al centro il quadrato 84 con il glifo delle persone, il titolo, il testo, il pulsante
/// blu grande «Scegli il cliente» (apre il pannello della barra) e, sotto, «oppure» con le pillole dei primi cinque
/// clienti (prima i recenti). Con zero clienti niente pillole, e il pulsante porta a «Nuovo cliente».
/// Valori in Tema.Apple+SceltaCliente.swift. Non è `VuotoGuidato` (tre passi, nessuna pillola).
struct VuotoCliente: View {
    @Environment(StatoShell.self) var stato
    let titolo: String
    let testo: String

    private typealias V = Tema.Apple.SceltaCliente.Vuoto

    var body: some View {
        let _ = ContaCorpi.segna()
        let primi = stato.primiPerIlVuoto
        VStack(spacing: V.spazio) {
            Image(systemName: "person.2.fill")
                .carattereApple(V.glifo)
                .foregroundColor(V.coloreGlifo)
                .frame(width: V.quadrato, height: V.quadrato)
                .background {
                    RoundedRectangle(cornerRadius: V.raggioQuadrato, style: .continuous)
                        .fill(V.fondoQuadrato)
                }
            Text(titolo)
                .carattereApple(V.titolo)
                .foregroundColor(V.coloreTitolo)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(testo)
                .carattereApple(V.testo)
                .foregroundColor(V.coloreTesto)
                .multilineTextAlignment(.center)
                .frame(maxWidth: V.larghezzaTesto)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                if primi.isEmpty {
                    stato.richiestaNuovoCliente = true
                    stato.apri(.clienti)
                } else {
                    stato.apriSceltaCliente()
                }
            } label: {
                Text(primi.isEmpty ? TestiSceltaCliente.nuovoCliente : TestiSceltaCliente.scegli)
            }
            .buttonStyle(.applePrimarioGrande)
            .padding(.top, V.sopraPulsante)
            if !primi.isEmpty {
                Text(TestiSceltaCliente.oppure)
                    .carattereApple(V.oppure)
                    .foregroundColor(V.coloreTesto)
                ViewThatFits(in: .horizontal) {
                    pillole(primi)
                    pillole(Array(primi.prefix(3)))
                    pillole(Array(primi.prefix(1)))
                }
            }
        }
        .padding(V.margine)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func pillole(_ elenco: [Cliente]) -> some View {
        HStack(spacing: V.spazioPillole) {
            ForEach(elenco) { c in
                Button { stato.scegliCliente(c.id, avviso: true) } label: {
                    HStack(spacing: Tema.Apple.SceltaCliente.Pillola.spazio) {
                        AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: V.avatarPillola)
                        Text(StatoShell.nomeBreve(c))
                            .carattereApple(V.nomePillola)
                            .foregroundColor(Tema.Apple.Colore.inchiostro)
                            .lineLimit(1)
                    }
                    .padding(V.paddingPillola)
                    .background(Capsule(style: .continuous).fill(V.fondoPillola))
                    .contentShape(Capsule(style: .continuous))
                }
                .buttonStyle(StileSemplice())
                .help(c.nome)
            }
        }
        .fixedSize()
    }
}

/// «Solo <Nome> ✕» nella riga in testa dell'Agenda (migliorie d'uso 2, template riga 3116): toccarla riporta a «Tutti i
/// clienti». Valori in Tema.Apple+SceltaCliente.swift.
struct PillolaSoloCliente: View {
    let nome: String
    let azione: () -> Void

    private typealias S = Tema.Apple.SceltaCliente.Solo

    var body: some View {
        Button(action: azione) {
            HStack(spacing: S.spazio) {
                Text(TestiSceltaCliente.solo(nome))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: S.larghezzaMassima, alignment: .leading)
                    .fixedSize(horizontal: true, vertical: false)
                Image(systemName: "xmark")
            }
            .carattereApple(S.testo)
            .foregroundColor(S.colore)
            .padding(S.padding)
            .background(Capsule(style: .continuous).fill(S.fondo))
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(StileSemplice())
        .fixedSize()
        .help(TestiSceltaCliente.aiutoSolo)
    }
}
#endif
