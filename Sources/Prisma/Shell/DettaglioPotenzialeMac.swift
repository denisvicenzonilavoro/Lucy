#if os(macOS)
import AppKit
import SwiftUI

// Il dettaglio di un potenziale sul Mac (Migliorie d'uso 47, Design/uso/gruppo-08.md §47.3 punto 4; template righe
// 4501-4521, `potScheda`): nasce dalla scheda toccata, 820 × 460.
//
//   (PF)  DA CONTATTARE · PRESENTATO DA MARCO
//         Paolo Ferretti                                                     [Chiudi]
//   ┌ Patrimonio stimato ┐ ┌ Probabilità ┐ ┌ Fermo da ─────────┐
//   │ 180.000 €          │ │ 20%         │ │ 21 giorni         │
//   │                    │ │ che diventi │ │ in «Da contattare»│
//   └────────────────────┘ └─────────────┘ └───────────────────┘
//   ┌ IL PROSSIMO PASSO ─────────────────────────────────────────┐
//   │ ● Chiamalo: te l'ha presentato Marco                       │
//   └────────────────────────────────────────────────────────────┘
//   [Chiama]  [Passa a «Primo incontro»]                [Non interessato]
//   Email · Telefono · Chiusura prevista · Informativa · Consenso · Nota · Storia   (scorrono sotto)
//   [Modifica…]
//
// - Il passo e i giorni di fermo vengono da `stato.passiPotenziali()` (MotorePassaparola, nessun campo nuovo).
// - «Chiama» (decisione 47-c): un riquadro con il numero in grande, selezionabile, e «Copia il numero»; Prisma non
//   chiama e non apre app. «Scrivi»: Mail o Messaggi con il saluto, solo con informativa e consenso (decisione 39).
// - «Passa a…»: il dettaglio si chiude e la scheda vola (la vista lo rende annullabile); da «Proposta» «Diventa
//   cliente» apre la scena del nuovo cliente.
// - Già cliente: la tile «Fatto», «Va bene» e «Apri il dossier».
// - Sola lettura (archivio più recente): niente pulsanti che scrivono.

/// Le azioni del dettaglio che passano dalla vista (chiudono il dettaglio con l'animazione giusta).
struct AzioniDettaglioPotenziale {
    let passaA: (String, FasePotenziale) -> Void
    let nonInteressato: (String) -> Void
    let dossier: (String) -> Void
    let diventaCliente: (String) -> Void
    /// «Prepara l'incontro»: chiude il dettaglio e apre l'appuntamento in Agenda.
    let apriIncontro: (Appuntamento) -> Void
}

struct DettaglioPotenzialeMac: View {
    let stato: StatoShell
    let potenziale: PotenzialeCliente
    let modificabile: Bool
    let azioni: AzioniDettaglioPotenziale
    let modifica: () -> Void
    let chiudi: () -> Void
    @State private var mostraNumero = false
    @State private var copiato = false

    private typealias P = Tema.Apple.Potenziali

    var body: some View {
        let p = potenziale
        let passo = stato.passiPotenziali()[p.id]
            ?? MotorePassaparola.prossimoPasso(p, presentatore: nil, primoIncontro: nil, oggi: Date())
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: P.spazioDettaglio) {
                testata(p)
                tile(p, passo: passo)
                tilePasso(p, passo: passo)
                if modificabile { pulsanti(p, passo: passo) }
                righe(p)
                if modificabile { altri(p, passo: passo) }
                if p.diProva {
                    Text(TestiPassaparola.datiDiProva)
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(Tema.Apple.Colore.inchiostro3)
                }
            }
            .padding(P.paddingDettaglio)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: Testata

    private func testata(_ p: PotenzialeCliente) -> some View {
        HStack(alignment: .center, spacing: P.spazioTesta) {
            Text(Cliente.iniziali(di: p.nome))
                .carattereApple(P.inizialiDettaglio)
                .foregroundColor(P.testoAvatar)
                .frame(width: P.avatarDettaglio, height: P.avatarDettaglio)
                .background(Circle().fill(P.fondoAvatar))
                .overlay(Circle().strokeBorder(P.bordoAvatar, lineWidth: 1))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: P.spazioPiccolo) {
                Text(occhiello(p))
                    .carattereApple(P.etichettaDettaglio)
                    .foregroundColor(Tema.Apple.Colore.inchiostro2)
                    .lineLimit(1)
                Text(p.nome)
                    .carattereApple(P.titoloDettaglio)
                    .foregroundColor(Tema.Apple.Colore.inchiostro)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: P.spazioMedio)
            Button("Chiudi", action: chiudi).buttonStyle(.apple)
        }
    }

    /// «{fase} · {fonte}» (l'etichetta è in maiuscolo).
    private func occhiello(_ p: PotenzialeCliente) -> String {
        if let f = TestiPassaparola.fonte(p, clienti: stato.dati.clienti) { return p.fase.titolo + " · " + f }
        return p.fase.titolo
    }

    // MARK: Tile

    private func tile(_ p: PotenzialeCliente, passo: PassoPotenziale) -> some View {
        HStack(alignment: .top, spacing: P.spazioTileDettaglio) {
            tileDettaglio(TestiPassaparola.tilePatrimonio, TestiPassaparola.stima(p.patrimonioStimato), nota: nil,
                          stimata: p.patrimonioStimato != nil)
            tileDettaglio("Probabilità", TestiPassaparola.probabilita(p.probabilita), nota: TestiPassaparola.cheDiventiCliente)
            if p.fase == .cliente {
                tileDettaglio("Cliente", "sì",
                              nota: MotorePassaparola.diventatoCliente(p).map { "dal " + Formati.giornoMese.string(from: $0) })
            } else {
                tileDettaglio("Fermo da", TestiPassaparola.valoreFermo(passo.giorniFermo), nota: TestiPassaparola.inFase(p.fase),
                              colore: passo.fermo ? P.coloreFermoOltre : Tema.Apple.Colore.inchiostro,
                              coloreNota: passo.fermo ? P.coloreFermoOltre : Tema.Apple.Colore.inchiostro3)
            }
        }
    }

    private func tileDettaglio(_ titolo: String, _ valore: String, nota: String?, stimata: Bool = true,
                               colore: Color = Tema.Apple.Colore.inchiostro,
                               coloreNota: Color = Tema.Apple.Colore.inchiostro3) -> some View {
        VStack(alignment: .leading, spacing: P.spazioPiccolo) {
            Text(titolo)
                .carattereApple(P.tileEtichetta)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
                .lineLimit(1)
            Text(valore)
                .carattereApple(stimata ? P.tileDettaglioValore : P.tileDettaglioNota)
                .foregroundColor(stimata ? colore : Tema.Apple.Colore.inchiostro3)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(nota ?? " ")
                .carattereApple(P.tileDettaglioNota)
                .foregroundColor(coloreNota)
                .lineLimit(1)
        }
        .padding(P.paddingTileDettaglio)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.tile)
        .accessibilityElement(children: .combine)
    }

    /// «Il prossimo passo» con il punto; per un cliente «Fatto»; per un non interessato nessun passo.
    private func tilePasso(_ p: PotenzialeCliente, passo: PassoPotenziale) -> some View {
        let cliente = p.fase == .cliente
        let testo: String
        switch p.fase {
        case .cliente: testo = TestiPassaparola.fattoCliente
        case .nonInteressato: testo = TestiPassaparola.nessunPasso
        default: testo = passo.testo
        }
        let colore = cliente ? P.colorePassoCliente : P.colorePasso
        return VStack(alignment: .leading, spacing: P.spazioMedio) {
            Text(cliente ? TestiPassaparola.tileFatto : TestiPassaparola.passoTitolo)
                .carattereApple(P.tileEtichetta)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
            HStack(alignment: .firstTextBaseline, spacing: P.spazioMedio) {
                Circle()
                    .fill(p.fase == .nonInteressato ? Tema.Apple.Colore.inchiostro3 : colore)
                    .frame(width: P.puntoPasso, height: P.puntoPasso)
                    .alignmentGuide(.firstTextBaseline) { d in d[.bottom] }
                Text(testo)
                    .carattereApple(P.testoPassoDettaglio)
                    .foregroundColor(p.fase == .nonInteressato ? Tema.Apple.Colore.inchiostro2 : Tema.Apple.Colore.inchiostro)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
        }
        .padding(P.paddingTileDettaglio)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.tile)
        .accessibilityElement(children: .combine)
    }

    // MARK: Pulsanti

    @ViewBuilder private func pulsanti(_ p: PotenzialeCliente, passo: PassoPotenziale) -> some View {
        switch p.fase {
        case .cliente:
            HStack(spacing: P.spazioMedio) {
                Button("Va bene", action: chiudi).buttonStyle(.applePrimario)
                if let cid = p.clienteId, stato.dati.clienti.contains(where: { $0.id == cid }) {
                    Button("Apri il dossier") { azioni.dossier(cid) }.buttonStyle(.appleGrande)
                }
                Spacer(minLength: 0)
            }
        case .nonInteressato:
            HStack(spacing: P.spazioMedio) {
                Button("Ripristina") { stato.spostaPotenziale(p.id, a: .daContattare) }.buttonStyle(.applePrimario)
                Spacer(minLength: 0)
            }
        default:
            VStack(alignment: .leading, spacing: P.spazioMedio) {
                HStack(spacing: P.spazioMedio) {
                    if let a = passo.azione { primario(p, azione: a) }
                    if p.fase == .proposta {
                        Button("Diventa cliente") { azioni.diventaCliente(p.id) }.buttonStyle(.appleGrande)
                    } else if let s = p.fase.successiva {
                        Button(TestiPassaparola.passaA(s)) { azioni.passaA(p.id, s) }.buttonStyle(.appleGrande)
                    }
                    Spacer(minLength: P.spazioMedio)
                    Button("Non interessato") { azioni.nonInteressato(p.id) }.buttonStyle(.appleSobrio)
                }
                if passo.azione == nil {
                    Text(TestiPassaparola.nessunContatto)
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(Tema.Apple.Colore.inchiostro3)
                } else if passo.azione == .scrivi && !p.contattabile {
                    Text(TestiPassaparola.scrivigliNonPronto)
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(Tema.Apple.Colore.inchiostro3)
                }
            }
        }
    }

    /// Il pulsante primario con l'azione del passo.
    @ViewBuilder private func primario(_ p: PotenzialeCliente, azione: AzionePotenziale) -> some View {
        switch azione {
        case .chiama:
            Button(TestiPassaparola.pulsantePasso(azione)) {
                copiato = false
                mostraNumero = true
            }
            .buttonStyle(.applePrimario)
            .help("Mostra il numero: lo componi tu dal telefono")
            .popover(isPresented: $mostraNumero, arrowEdge: .bottom) { numero(p) }
        case .scrivi:
            Button(TestiPassaparola.pulsantePasso(azione)) {
                stato.scriviAPotenziale(p.id, canale: p.email.isEmpty ? .messaggi : .mail)
            }
            .buttonStyle(.applePrimario)
            .disabled(!p.contattabile)
            .help(p.contattabile ? "Apri Mail o Messaggi con il saluto: lo spedisci tu" : TestiPassaparola.scrivigliNonPronto)
        case .fissaIncontro:
            Button(TestiPassaparola.pulsantePasso(azione)) { _ = stato.fissaPrimoIncontro(p.id) }
                .buttonStyle(.applePrimario)
                .help("Il primo spazio libero dell'Agenda, mezz'ora")
        case .preparaIncontro(let id):
            Button(TestiPassaparola.pulsantePasso(azione)) {
                guard let a = stato.dati.appuntamenti.first(where: { $0.id == id }) else { return }
                azioni.apriIncontro(a)
            }
            .buttonStyle(.applePrimario)
            .help("Apri l'appuntamento in Agenda")
        }
    }

    /// Il riquadro di «Chiama» (decisione 47-c): il numero in grande, selezionabile, e «Copia il numero».
    private func numero(_ p: PotenzialeCliente) -> some View {
        VStack(alignment: .leading, spacing: P.spazioMedio) {
            Text(p.nome)
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
            Text(p.telefono)
                .carattereApple(P.numeroChiama)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
                .textSelection(.enabled)
            Button(copiato ? TestiPassaparola.numeroCopiato : TestiPassaparola.copiaNumero) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(p.telefono, forType: .string)
                copiato = true
            }
            .buttonStyle(.apple)
            Text(TestiPassaparola.notaChiama)
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(Tema.Apple.Colore.inchiostro3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(P.paddingChiama)
        .frame(width: P.larghezzaChiama, alignment: .leading)
    }

    // MARK: Le righe di prima

    @ViewBuilder private func righe(_ p: PotenzialeCliente) -> some View {
        riga("Email", p.email.isEmpty ? "—" : p.email)
        riga("Telefono", p.telefono.isEmpty ? "—" : p.telefono)
        riga("Chiusura prevista", p.chiusuraPrevista.map { Formati.dataEstesa.string(from: $0) } ?? "—")
        riga("Informativa data il", p.informativaIl.map { Formati.dataEstesa.string(from: $0) } ?? TestiPassaparola.informativaDaDare)
        riga("Consenso al contatto", p.consensoContatto.map { $0 ? "Sì" : "No" } ?? "Non chiesto")
        if !p.nota.isEmpty { riga("Nota", p.nota) }
        if !p.storia.isEmpty {
            VStack(alignment: .leading, spacing: P.spazioPiccolo) {
                Text("STORIA").carattereApple(P.etichettaDettaglio).foregroundColor(Tema.Apple.Colore.inchiostro2)
                ForEach(Array(p.storia.enumerated()), id: \.offset) { _, c in
                    Text(c.fase.titolo + " · " + Formati.dataEstesa.string(from: c.il))
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(Tema.Apple.Colore.inchiostro2)
                }
            }
        }
    }

    private func riga(_ etichetta: String, _ valore: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: P.spazioRiga) {
            Text(etichetta)
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
                .frame(width: P.larghezzaEtichetta, alignment: .leading)
            Text(valore)
                .carattereApple(P.rigaDettaglio)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
                .textSelection(.enabled)
        }
    }

    /// «Modifica…» e, se l'azione del passo non è già scrivere, «Scrivigli» (solo con informativa e consenso).
    private func altri(_ p: PotenzialeCliente, passo: PassoPotenziale) -> some View {
        HStack(spacing: P.spazioMedio) {
            Button("Modifica…", action: modifica).buttonStyle(.appleSobrio)
            if p.fase != .cliente, p.fase != .nonInteressato, p.contattabile,
               passo.azione != .scrivi {
                Button("Scrivigli") { stato.scriviAPotenziale(p.id, canale: p.email.isEmpty ? .messaggi : .mail) }
                    .buttonStyle(.appleSobrio)
                    .help("Apri Mail o Messaggi con il saluto: lo spedisci tu")
            }
        }
    }
}
#endif
