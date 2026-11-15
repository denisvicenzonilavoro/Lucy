import SwiftUI

// Migliorie d'uso 60 «Ogni esperienza lascia qualcosa» (Design/uso/gruppo-10.md §60, template righe 4791-4809): le
// esperienze della Sala fatte oggi con il cliente, il segno («Segna come fatta» o da solo alla fine chiara di
// un'esperienza) e la prossima da proporre. Il dato è `DatiPrisma.esperienzeFatte` (Dati/EsperienzaFatta.swift).
// Le letture passano da `ricavato`: `esperienzeFatte` segnala `.neutro` e non cambia `versioneCalcoli`, quindi nella
// chiave va ciò che cambia a ogni segno o «Togli» (quanti sono e l'id dell'ultimo); il giorno lo rinnova DerivatiDati.

/// I testi delle esperienze fatte.
enum TestiEsperienzeFatte {
    static let segna = "Segna come fatta"
    static let aiutoSegna = "Resta scritta nel dossier del cliente, con la data di oggi"
    static let fattaOggi = "✓ Fatta oggi"
    static func prossima(_ e: EsperienzaSala) -> String { "Prossima: \(e.titolo) ›" }
    static func aiutoProssima(_ e: EsperienzaSala) -> String { "Apri «\(e.titolo)» sul palco" }
    static func segnata(_ e: EsperienzaSala, nome: String) -> String {
        "«\(e.titolo)» segnata: resta scritta nel dossier di \(nome), con la data di oggi"
    }
    /// L'occhiello della Sala con almeno un'esperienza fatta oggi.
    static func occhiello(_ n: Int, nome: String) -> String {
        n == 1 ? "Un’esperienza fatta oggi con \(nome)" : "\(n) esperienze fatte oggi con \(nome)"
    }
    /// Il riquadro del dossier.
    static let titoloDossier = "In Sala"
    static let aiutoRiga = "Apri l'esperienza nella Sala"
    static let togli = "Togli"
    static func tolta(_ e: EsperienzaSala) -> String { "«\(e.titolo)» tolta dal dossier" }
}

extension StatoShell {
    /// La chiave del dato ricavato: cambia a ogni segno e a ogni «Togli» (leggere `count` e `last` iscrive la vista al
    /// solo campo `esperienzeFatte`).
    private func chiaveFatte(_ id: String) -> String {
        "\(id)|\(dati.esperienzeFatte.count)|\(dati.esperienzeFatte.last?.id ?? "")"
    }

    /// Le esperienze fatte oggi con il cliente, in cache: la griglia la legge una volta e passa il booleano alle schede.
    func esperienzeFatteOggi(cliente id: String) -> Set<EsperienzaSala> {
        ricavato("sala-fatte|\(chiaveFatte(id))") { () -> Set<EsperienzaSala> in
            EsperienzaFatta.fatte(dati.esperienzeFatte, cliente: id, il: Date())
        }
    }

    func esperienzaFattaOggi(_ e: EsperienzaSala, cliente id: String) -> Bool {
        esperienzeFatteOggi(cliente: id).contains(e)
    }

    /// Le ultime esperienze fatte con il cliente (il riquadro «In Sala» del dossier), in cache.
    func ultimeEsperienzeFatte(cliente id: String, quante: Int) -> [EsperienzaFatta] {
        ricavato("sala-ultime|\(quante)|\(chiaveFatte(id))") { () -> [EsperienzaFatta] in
            EsperienzaFatta.ultime(dati.esperienzeFatte, cliente: id, quante: quante)
        }
    }

    /// La prossima esperienza da proporre dopo quella aperta (le consigliate già in cache).
    func prossimaEsperienza(dopo e: EsperienzaSala, cliente id: String) -> EsperienzaSala? {
        EsperienzaSala.prossima(dopo: e, fatte: esperienzeFatteOggi(cliente: id), consigliate: esperienzeConsigliate(id))
    }

    /// Segna l'esperienza come fatta oggi con il cliente (una sola volta al giorno per esperienza e cliente). Con
    /// `avviso` («Segna come fatta») dice dove resta scritta; il segno automatico alla fine di un'esperienza è muto.
    /// Solo sul Mac: le viste delle esperienze sono condivise con l'iPad, che non scrive questo campo (non passa dal
    /// giornale di «Prisma ovunque»). Gli stati di prova delle istantanee non passano dalle funzioni di fine.
    func segnaEsperienza(_ e: EsperienzaSala, cliente id: String, avviso: Bool) {
        #if os(macOS)
        guard let c = cliente(id) else { return }
        guard !EsperienzaFatta.fatte(dati.esperienzeFatte, cliente: id, il: Date()).contains(e) else { return }
        dati.esperienzeFatte.append(EsperienzaFatta(clienteId: id, esperienza: e, quando: Date()))
        if avviso { mostraAvviso(TestiEsperienzeFatte.segnata(e, nome: StatoShell.nomeBreve(c))) }
        #endif
    }

    /// «Togli» dal riquadro del dossier (decisione 60-d): un errore di clic non resta per sempre.
    func togliEsperienzaFatta(_ id: String) {
        guard let f = dati.esperienzeFatte.first(where: { $0.id == id }) else { return }
        dati.esperienzeFatte.removeAll { $0.id == id }
        mostraAvviso(TestiEsperienzeFatte.tolta(f.esperienza))
    }
}

/// L'occhiello della Sala (il `#wSub` del template): sul Mac, con un cliente scelto e almeno un'esperienza fatta oggi,
/// «Un’esperienza fatta oggi con <Nome>» / «<n> esperienze fatte oggi con <Nome>»; altrimenti l'occhiello di sempre.
/// Non nella vista del cliente né in modalità cliente; su iPhone e iPad resta quello di oggi. `mostra` lo disegna nello
/// stile della riga che lo ospita.
struct OcchielloSala<Contenuto: View>: View {
    @Environment(StatoShell.self) var stato
    let mostra: (String) -> Contenuto

    var body: some View {
        let _ = ContaCorpi.segna()
        mostra(testo)
    }

    private var testo: String {
        #if os(macOS)
        if !stato.inModoCliente, !stato.inVistaCliente, let c = stato.clienteAttivo {
            let n = stato.esperienzeFatteOggi(cliente: c.id).count
            if n > 0 { return TestiEsperienzeFatte.occhiello(n, nome: StatoShell.nomeBreve(c)) }
        }
        #endif
        return AppPrisma.sala.occhiello
    }
}

#if os(macOS)
/// Il riquadro «In Sala» nella Panoramica del dossier (decisione 60-a): le ultime cinque esperienze fatte con il cliente
/// (data breve e titolo), dalla più recente. Non compare se non ce ne sono; strumento del consulente, mai in modalità
/// cliente. Un clic apre l'esperienza nella Sala; il menu contestuale «Togli» toglie un segno messo per errore (60-d).
struct InSalaDossierApple: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente

    private typealias F = Tema.Apple.SalaEsperienze.Fatte

    var body: some View {
        let _ = ContaCorpi.segna()
        let p = Tema.Apple.Clienti.Panoramica.self
        let ultime = stato.ultimeEsperienzeFatte(cliente: cliente.id, quante: F.quante)
        if !ultime.isEmpty {
            VStack(alignment: .leading, spacing: p.sottoTitolo) {
                Text(TestiEsperienzeFatte.titoloDossier)
                    .carattereApple(p.titolo)
                    .foregroundColor(p.coloreTitolo)
                VStack(alignment: .leading, spacing: F.spazioRighe) {
                    ForEach(ultime) { f in riga(f) }
                }
            }
            .padding(p.paddingLaterali)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .superficieApple(p.superficie)
        }
    }

    private func riga(_ f: EsperienzaFatta) -> some View {
        Button { stato.apriEsperienza(f.esperienza, cliente: cliente.id) } label: {
            HStack(spacing: F.spazioRiga) {
                Text(Formati.giornoMeseBreve.string(from: f.quando))
                    .carattereApple(F.data)
                    .foregroundColor(F.coloreData)
                    .frame(width: F.larghezzaData, alignment: .leading)
                TasselloGlifo(glifo: f.esperienza.glifo, lato: F.tassello, raggio: F.raggioTassello)
                Text(f.esperienza.titolo)
                    .carattereApple(F.riga)
                    .foregroundColor(F.coloreRiga)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(StileSemplice())
        .help(TestiEsperienzeFatte.aiutoRiga)
        .contextMenu {
            Button(TestiEsperienzeFatte.togli) { stato.togliEsperienzaFatta(f.id) }
                .disabled(stato.solaLettura)
        }
    }
}
#endif
