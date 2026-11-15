#if os(macOS)
import SwiftUI

// Migliorie d'uso 70 (Design/uso/gruppo-12.md §70): il fascicolo si compone a vista, solo sul Mac.
//
//   PER MARCO · INCONTRO DI OGGI, 2 NOVEMBRE
//   Il fascicolo dell'incontro                                                        ✕
//   ┌ COSA C'È DENTRO ─────────────────────────────┐  ┌ la copertina vera, scalata ┐
//   │ ☑ Copertina · con la data, il nome e l'indice │  │  Il punto insieme · DENTRO  │
//   │ ☑ Resoconto · …            3 pagine  ˄ ˅      │  └────────────────────────────┘
//   │ ☐ Prova di resistenza · …  4 pagine  ˄ ˅      │  3 report · 9 pagine  con la copertina
//   └───────────────────────────────────────────────┘
//   [Salva il PDF · 9 pagine]  [Mostra al cliente]  [Altro ⌄]     Lo ritrovi nei Documenti di Marco, …
//
// - Il dettaglio del tema nasce dalla card «Fascicolo dell'incontro» di Prospetti (`PresentatoreFascicoloMac`) e si apre
//   anche da `apriProspetto(.fascicolo)` e `preparaFascicolo(per:)` (`stato.fascicoloDaAprire`). Non in modalità cliente.
// - La scelta (report, ordine, appuntamento) è del cliente, in memoria (`StatoShell.fascicoli`, decisione 70-a).
// - Le pagine di ogni report sono quelle vere (`pagineFascicolo`, la stessa impaginazione tenuta da parte per comporre):
//   spuntare una riga rifà solo la copertina. L'anteprima è la prima pagina del documento, non un disegno.
// Valori in Tema.Apple.Prospetti.Fascicolo, testi in TestiFascicolo.

private typealias F = Tema.Apple.Prospetti.Fascicolo

/// Il contenuto di Prospetti con sopra la scheda del fascicolo, che nasce dalla card (`origineDettaglio`).
struct PresentatoreFascicoloMac<Contenuto: View, Scheda: View>: View {
    @Environment(StatoShell.self) private var stato
    @StateObject private var dettaglio: StatoDettaglio
    private let contenuto: Contenuto
    private let scheda: (StatoDettaglio) -> Scheda

    /// `apertoSubito`: la scheda chiesta prima che Prospetti si veda (istantanee, Agenda): già aperta, a misura piena.
    init(apertoSubito: Bool, @ViewBuilder contenuto: () -> Contenuto,
         @ViewBuilder scheda: @escaping (StatoDettaglio) -> Scheda) {
        _dettaglio = StateObject(wrappedValue: apertoSubito
            ? StatoDettaglio(aperto: ComponiFascicoloMac.idDettaglio, misura: F.misuraDettaglio)
            : StatoDettaglio())
        self.contenuto = contenuto()
        self.scheda = scheda
    }

    var body: some View {
        let d = dettaglio
        return contenuto
            .presentatoreDettaglio(dettaglio) { _ in scheda(d) }
            .onAppear { apriSeChiesto(d) }
            .onChange(of: stato.fascicoloDaAprire) { _ in apriSeChiesto(d) }
            // La scheda è lavoro del consulente: davanti al cliente si chiude
            .onChange(of: stato.inModoCliente) { dentro in if dentro { d.chiudi(subito: true) } }
            .onDisappear { d.chiudi(subito: true) }
    }

    private func apriSeChiesto(_ d: StatoDettaglio) {
        guard stato.fascicoloDaAprire else { return }
        stato.fascicoloDaAprire = false
        guard !stato.inModoCliente, stato.clienteAttivo != nil else { return }
        d.apri(ComponiFascicoloMac.idDettaglio, misura: F.misuraDettaglio)
    }
}

/// La scheda «Il fascicolo dell'incontro»: a sinistra cosa c'è dentro (spunte, pagine, ordine), a destra la copertina
/// vera con l'indice e la somma; sotto «Salva il PDF», «Mostra al cliente» e «Altro».
struct ComponiFascicoloMac: View {
    /// L'id della card da cui nasce il dettaglio.
    static let idDettaglio = "fascicolo"

    @Environment(StatoShell.self) private var stato
    /// Il nome breve del report (quello dell'elenco dei Prospetti).
    let nome: (TipoProspetto) -> String
    let salva: () -> Void
    let salvaAltrove: () -> Void
    let stampa: () -> Void
    let mostra: () -> Void

    var body: some View {
        let cliente = stato.clienteAttivo
        let nomeCliente = cliente.map { $0.nome.split(separator: " ").first.map(String.init) ?? $0.nome } ?? ""
        let scelta = stato.sceltaFascicoloCompleta
        // I report che il cliente ha, con le loro pagine (impaginati una volta e tenuti da parte)
        let righe: [RigaFascicolo] = scelta.ordine.compactMap { t -> RigaFascicolo? in
            guard let n = stato.pagineFascicolo(t) else { return nil }
            return RigaFascicolo(tipo: t, pagine: n)
        }
        let visibili = righe.map(\.tipo)
        let scelti = righe.filter { scelta.scelti.contains($0.tipo) }
        let documento = scelti.isEmpty ? nil : stato.documentoFascicolo()
        let totale = documento?.pagine.count ?? 1
        let incontro = stato.incontroScheda()
        let oggi = stato.prospettoPerIncontroOggi(stato.clienteAttivoId)
        return VStack(alignment: .leading, spacing: 0) {
            Text(TestiFascicolo.occhiello(nome: nomeCliente, incontro: incontro.testo))
                .carattereApple(F.occhiello)
                .foregroundColor(F.coloreOcchiello)
                .lineLimit(1)
            Text(TestiFascicolo.titolo)
                .carattereApple(F.titolo)
                .foregroundColor(F.coloreTitolo)
                .padding(.top, F.sottoOcchiello)
            HStack(alignment: .top, spacing: F.spazioColonne) {
                elenco(righe, scelta: scelta, visibili: visibili, oggi: oggi, nomeCliente: nomeCliente)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                anteprima(documento, cliente: cliente, report: scelti.count, pagine: totale)
                    .frame(width: F.larghezzaAnteprima, alignment: .topLeading)
            }
            .padding(.top, F.sopraColonne)
            .frame(maxHeight: .infinity, alignment: .top)
            fila(report: scelti.count, pagine: totale, nomeCliente: nomeCliente, legato: incontro.legato)
                .padding(.top, F.sopraFila)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: Cosa c'è dentro

    private func elenco(_ righe: [RigaFascicolo], scelta: SceltaFascicolo, visibili: [TipoProspetto],
                        oggi: TipoProspetto?, nomeCliente: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(TestiFascicolo.cosaCeDentro)
                .carattereApple(F.etichetta)
                .foregroundColor(F.coloreEtichetta)
                .padding(.bottom, F.sottoEtichetta)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    rigaCopertina
                    ForEach(Array(righe.enumerated()), id: \.element.id) { i, r in
                        rigaReport(r.tipo, pagine: r.pagine, primo: i == 0, ultimo: i == righe.count - 1,
                                   scelto: scelta.scelti.contains(r.tipo), oggi: oggi == r.tipo, visibili: visibili)
                    }
                    Text(nota(righe.count, nomeCliente: nomeCliente))
                        .carattereApple(F.nota)
                        .foregroundColor(F.coloreNota)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, F.sopraNota)
                }
            }
        }
    }

    private func nota(_ n: Int, nomeCliente: String) -> String {
        switch n {
        case 0: return TestiFascicolo.senzaReport
        case 1: return TestiFascicolo.unSoloReport(nomeCliente)
        default: return TestiFascicolo.istruzioni
        }
    }

    /// La copertina: sempre dentro, la spunta non si toglie, niente frecce.
    private var rigaCopertina: some View {
        HStack(alignment: .center, spacing: F.spazioRiga) {
            SpuntaFascicolo(accesa: true, fissa: true)
            testi(TestiFascicolo.copertina, sotto: Text(TestiFascicolo.copertinaSotto), scelto: true)
            Spacer(minLength: F.spazioRiga)
            pagine(1)
            // Lo spazio delle frecce, per allineare le pagine
            Color.clear.frame(width: F.freccia * 2 + F.spazioFrecce, height: F.freccia)
        }
        .padding(F.paddingRiga)
        .overlay(alignment: .bottom) { filetto }
        .accessibilityElement(children: .combine)
    }

    private func rigaReport(_ t: TipoProspetto, pagine n: Int, primo: Bool, ultimo: Bool, scelto: Bool, oggi: Bool,
                            visibili: [TipoProspetto]) -> some View {
        var sotto = Text(t.inBreve)
        if oggi {
            sotto = sotto + Text(" · ") + Text(TestiFascicolo.incontroOggi).foregroundColor(F.coloreIncontro)
        }
        return HStack(alignment: .center, spacing: F.spazioRiga) {
            Button {
                stato.sceltaFascicoloCompleta.alterna(t)
            } label: {
                HStack(alignment: .center, spacing: F.spazioRiga) {
                    SpuntaFascicolo(accesa: scelto, fissa: false)
                    testi(nome(t), sotto: sotto, scelto: scelto)
                    Spacer(minLength: F.spazioRiga)
                    pagine(n)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(StileSemplice())
            .accessibilityAddTraits(scelto ? .isSelected : [])
            HStack(spacing: F.spazioFrecce) {
                freccia("chevron.up", aiuto: TestiFascicolo.su, spenta: primo) {
                    stato.sceltaFascicoloCompleta.sposta(t, di: -1, visibili: visibili)
                }
                freccia("chevron.down", aiuto: TestiFascicolo.giu, spenta: ultimo) {
                    stato.sceltaFascicoloCompleta.sposta(t, di: 1, visibili: visibili)
                }
            }
        }
        .padding(F.paddingRiga)
        .overlay(alignment: .bottom) { filetto }
    }

    private func testi(_ titolo: String, sotto: Text, scelto: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titolo)
                .carattereApple(F.nome)
                .foregroundColor(scelto ? F.coloreNome : F.coloreNomeTolto)
                .lineLimit(1)
            sotto
                .carattereApple(F.sotto)
                .foregroundColor(F.coloreSotto)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func pagine(_ n: Int) -> some View {
        Text(TestiFascicolo.pagine(n))
            .carattereApple(F.pagine)
            .foregroundColor(F.colorePagine)
            .lineLimit(1)
            .fixedSize()
    }

    private func freccia(_ simbolo: String, aiuto: String, spenta: Bool, _ azione: @escaping () -> Void) -> some View {
        Button(action: azione) {
            Image(systemName: simbolo)
                .carattereApple(F.carattereFreccia)
                .foregroundColor(F.coloreNome)
                .frame(width: F.freccia, height: F.freccia)
                .background { RoundedRectangle(cornerRadius: F.raggioFreccia, style: .continuous).fill(F.fondoFreccia) }
                .contentShape(RoundedRectangle(cornerRadius: F.raggioFreccia, style: .continuous))
        }
        .buttonStyle(StileSemplice())
        .disabled(spenta)
        .opacity(spenta ? F.opacitaFrecciaSpenta : 1)
        .help(aiuto)
        .accessibilityLabel(Text(aiuto))
    }

    private var filetto: some View {
        Rectangle().fill(F.filetto).frame(height: F.spessoreFiletto)
    }

    // MARK: L'anteprima e la somma

    private func anteprima(_ documento: DocumentoStampabile?, cliente: Cliente?, report n: Int, pagine p: Int) -> some View {
        let formato = Misure.Documento.report
        let scala = (F.larghezzaAnteprima - F.paddingAnteprima * 2) / formato.width
        let forma = RoundedRectangle(cornerRadius: F.raggioAnteprima, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            Group {
                if let prima = documento?.pagine.first {
                    prima
                } else if let c = cliente {
                    // Senza report: la copertina con «Nessun report scelto»
                    stato.copertinaFascicolo(c, voci: [], pagine: 1, indiceInCopertina: true)
                        .environment(\.paletteDocumento, Colori.Documento.prisma)
                }
            }
            .prismaScalaTesto(1)
            .frame(width: formato.width, height: formato.height)
            .scaleEffect(scala, anchor: .topLeading)
            .frame(width: formato.width * scala, height: formato.height * scala, alignment: .topLeading)
            .shadow(color: F.ombraCarta, radius: F.raggioOmbraCarta)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .padding(F.paddingAnteprima)
            .background { forma.fill(F.fondoAnteprima) }
            HStack(alignment: .firstTextBaseline, spacing: F.spazioSomma) {
                Text(TestiFascicolo.somma(report: n, pagine: p))
                    .carattereApple(F.somma)
                    .foregroundColor(F.coloreSomma)
                Text(TestiFascicolo.conCopertina)
                    .carattereApple(F.nota)
                    .foregroundColor(F.coloreNota)
                Spacer(minLength: 0)
                if p > F.pagineTante {
                    PillolaStatoApple(testo: TestiFascicolo.tante, tono: .avviso)
                }
            }
            .padding(.top, F.sopraSomma)
            if p > F.pagineTante {
                Text(TestiFascicolo.tanteSotto)
                    .carattereApple(F.nota)
                    .foregroundColor(F.coloreNota)
                    .padding(.top, F.sottoOcchiello)
            }
        }
    }

    // MARK: La fila

    private func fila(report n: Int, pagine p: Int, nomeCliente: String, legato: Bool) -> some View {
        HStack(spacing: F.spazioFila) {
            Button(action: salva) {
                Text(n == 0 ? TestiFascicolo.scegliAlmenoUno : TestiFascicolo.salva(pagine: p))
            }
            .buttonStyle(.applePrimarioGrande)
            .fixedSize()
            .disabled(n == 0)
            Button(action: mostra) {
                Label(TestiFascicolo.mostra, systemImage: TestiAzioniProspetto.simboloMostra)
            }
            .buttonStyle(.appleGrande)
            .fixedSize()
            .disabled(n == 0)
            Menu {
                Button(action: salvaAltrove) { Label(TestiFascicolo.salvaAltrove, systemImage: "square.and.arrow.down") }
                Button(action: stampa) { Label(TestiFascicolo.stampa, systemImage: "printer") }
            } label: {
                HStack(spacing: Tema.Apple.Prospetti.Barra.spazioFrecciaAltro) {
                    Text(TestiFascicolo.altro)
                    Image(systemName: "chevron.down")
                        .carattereApple(Tema.Apple.Prospetti.Barra.frecciaAltro)
                        .opacity(Tema.Apple.Prospetti.Barra.opacitaFrecciaAltro)
                }
            }
            .menuStyle(.button)
            .menuIndicator(.hidden)
            .buttonStyle(.appleGrande)
            .fixedSize()
            .disabled(n == 0)
            Spacer(minLength: F.spazioFila)
            Text(TestiFascicolo.ritrovi(nomeCliente, conIncontro: legato))
                .carattereApple(F.nota)
                .foregroundColor(F.coloreNota)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// Una riga dell'elenco: un report che il cliente ha, con le sue pagine.
private struct RigaFascicolo: Identifiable {
    let tipo: TipoProspetto
    let pagine: Int
    var id: TipoProspetto { tipo }
}

/// La spunta di una riga del fascicolo: accesa nell'accento con il segno bianco, spenta con il bordo. Quella della
/// copertina è fissa (sempre accesa, attenuata: non si toglie).
private struct SpuntaFascicolo: View {
    let accesa: Bool
    let fissa: Bool

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: F.raggioSpunta, style: .continuous)
        return ZStack {
            if accesa {
                forma.fill(F.fondoSpunta)
                Image(systemName: "checkmark")
                    .carattereApple(F.segnoSpunta)
                    .foregroundColor(F.coloreSegnoSpunta)
            } else {
                forma.strokeBorder(F.bordoSpunta, lineWidth: F.spessoreBordoSpunta)
            }
        }
        .frame(width: F.spunta, height: F.spunta)
        .opacity(fissa ? F.opacitaSpuntaFissa : 1)
        .accessibilityHidden(true)
    }
}
#endif
