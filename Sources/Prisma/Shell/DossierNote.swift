#if os(macOS)
import AppKit
import SwiftUI
import UniformTypeIdentifiers

// Migliorie d'uso 65 «Le note stanno con il cliente» (Design/uso/gruppo-12.md, §65): sul Mac la sezione Note del dossier
// è un elenco solo, con la nota a fianco. A sinistra le note del cliente (in cima quella in evidenza, poi per data di
// modifica) e «Da ricordare» (`Cliente.nota`, una riga dell'elenco con id fisso, mai copiata in una nota); a destra il
// titolo e il testo scrivibili, che passano all'archivio poco dopo l'ultimo tasto (`TestoRinviato`), e la fila «Metti in
// evidenza» (una sola per cliente: è quella di Panoramica e della scheda di Vera), «Fanne un «Da fare»» (un'attività per
// oggi, legata alla nota con `Attivita.daNota`) ed «Elimina» (con «Annulla»). L'app Note a parte sul Mac non c'è più:
// `apri(.note)` porta qui (AppAccorpate.swift). In modalità cliente si vede solo la nota in evidenza, in sola lettura.
// Valori in DesignSystem/Apple/Tema.Apple+Dossier.swift (`Tema.Apple.Clienti.NoteDossier`), testi in TestiNoteDossier.

/// Una riga dell'elenco delle note del dossier: una nota del taccuino o «Da ricordare» (`nota` nil).
struct RigaNotaDossier: Identifiable, Equatable {
    let id: String
    let nota: Nota?
    let titolo: String
    let anteprima: String
    /// La data dell'ultima modifica (nil per «Da ricordare», che non ne ha una).
    let data: Date?
    let inEvidenza: Bool
    /// C'è un'attività aperta nata da questa nota.
    let nelDaFare: Bool

    var daRicordare: Bool { nota == nil }
}

/// L'ordine dell'elenco del Mac (decisione 65-c): in cima la nota in evidenza, poi le altre per data di modifica (la nota
/// nuova, la più recente, sta subito sotto). «Da ricordare» sta in cima quando è lei in evidenza, altrimenti in fondo; si
/// mostra quando non è vuota, quando è la riga scelta o quando nessuna nota è in evidenza e ce ne sono altre. `Nota.ordina`
/// resta per iPhone e iPad.
enum OrdineNoteDossier {
    static func righe(note: [Nota], cliente c: Cliente, attivita: [Attivita], scelta: String?) -> [RigaNotaDossier] {
        let mie = note.filter { $0.clienteId == c.id }
        let evidenza = Nota.inEvidenza(mie, cliente: c, titoloDaRicordare: TestiNoteDossier.daRicordare)
        let aperte = Set(attivita.filter { !$0.completata && $0.clienteId == c.id }.compactMap(\.daNota))
        func riga(_ n: Nota) -> RigaNotaDossier {
            let titolo = n.titolo.trimmingCharacters(in: .whitespacesAndNewlines)
            let vuoto = n.testo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return RigaNotaDossier(id: n.id, nota: n, titolo: titolo.isEmpty ? TestiNoteDossier.senzaTitolo : titolo,
                                   anteprima: vuoto ? TestiNoteDossier.notaVuota : n.anteprima, data: n.aggiornataIl,
                                   inEvidenza: evidenza?.id == n.id, nelDaFare: aperte.contains(n.id))
        }
        let idDR = StatoShell.idDaRicordare(c.id)
        let testoDR = c.nota.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
        let drInEvidenza = evidenza?.daRicordare == true
        let notaInEvidenza = evidenza.map { !$0.daRicordare } ?? false
        let mostraDR = !testoDR.isEmpty || scelta == idDR || (!notaInEvidenza && !mie.isEmpty)
        let rigaDR = RigaNotaDossier(id: idDR, nota: nil, titolo: TestiNoteDossier.daRicordare,
                                     anteprima: testoDR.isEmpty ? TestiNoteDossier.notaVuota : String(testoDR.prefix(Nota.limiteAnteprima)),
                                     data: nil, inEvidenza: drInEvidenza, nelDaFare: false)
        var esito: [RigaNotaDossier] = []
        if let id = evidenza?.id, let n = mie.first(where: { $0.id == id }) { esito.append(riga(n)) }
        if mostraDR && drInEvidenza { esito.append(rigaDR) }
        esito += mie.filter { $0.id != evidenza?.id }.sorted { $0.aggiornataIl > $1.aggiornataIl }.map(riga)
        if mostraDR && !drInEvidenza { esito.append(rigaDR) }
        return esito
    }
}

extension StatoShell {
    /// L'id della riga «Da ricordare» del cliente nell'elenco delle note (sta in `notaSelezionata` quando è scelta).
    static func idDaRicordare(_ cliente: String) -> String { "da-ricordare|\(cliente)" }

    /// La nota in evidenza del cliente: la nota fissata più recente, altrimenti «Da ricordare» (migliorie d'uso 65). Le
    /// note non sono dati dei calcoli: la loro versione sta nella chiave.
    func notaInEvidenza(_ c: Cliente) -> NotaInEvidenza? {
        let chiave = "nota-evidenza|\(c.id)|\(versioneNote)|\(c.nota.hashValue)"
        return ricavato(chiave) { () -> NotaInEvidenza? in
            Nota.inEvidenza(dati.note, cliente: c, titoloDaRicordare: TestiNoteDossier.daRicordare)
        }
    }

    /// Le righe dell'elenco delle note del dossier, tenute fra un ridisegno e l'altro (la scelta sta nella chiave: decide
    /// se «Da ricordare» vuota si vede).
    func righeNoteDossier(_ c: Cliente) -> [RigaNotaDossier] {
        let scelta = notaSelezionata
        let chiave = "note-dossier|\(c.id)|\(versioneNote)|\(c.nota.hashValue)|\(scelta ?? "")"
        return ricavato(chiave) { () -> [RigaNotaDossier] in
            OrdineNoteDossier.righe(note: dati.note, cliente: c, attivita: dati.attivita, scelta: scelta)
        }
    }

    /// Sceglie una riga dell'elenco: prima il testo in attesa va all'archivio (una nota nuova lasciata vuota se ne va).
    func scegliNotaDossier(_ id: String) {
        TestiRinviati.scriviOra()
        scegliNota(id)
    }

    /// «＋ Nuova nota»: una nota vuota per il cliente, in cima alle altre e scelta.
    @discardableResult
    func nuovaNotaDossier(_ cliente: String) -> Nota? {
        TestiRinviati.scriviOra()
        return nuovaNota(clienteId: cliente)
    }

    /// «Metti in evidenza»: una sola per cliente. Su una nota la fissa e toglie la stella alle altre; su «Da ricordare»
    /// toglie la stella a tutte le note, così torna in evidenza lei.
    func mettiInEvidenza(_ id: String, cliente: String) {
        TestiRinviati.scriviOra()
        let fissate = dati.note.filter { $0.clienteId == cliente && $0.fissata && $0.id != id }.map(\.id)
        for f in fissate { modificaNota(f) { $0.fissata = false } }
        if id != Self.idDaRicordare(cliente) { modificaNota(id) { $0.fissata = true } }
        mostraAvviso(TestiNoteDossier.avvisoInEvidenza)
    }

    /// Toglie dall'evidenza la nota (e le altre fissate del cliente, rimaste dagli archivi di prima): torna in evidenza
    /// «Da ricordare», se non è vuota.
    func togliEvidenza(cliente: String) {
        TestiRinviati.scriviOra()
        let fissate = dati.note.filter { $0.clienteId == cliente && $0.fissata }.map(\.id)
        for f in fissate { modificaNota(f) { $0.fissata = false } }
        mostraAvviso(TestiNoteDossier.avvisoTolta)
    }

    /// «Fanne un «Da fare»»: un'attività per oggi nata dalla nota, salvata subito (senza il modulo), con «Annulla».
    func notaNelDaFare(_ id: String) {
        TestiRinviati.scriviOra()
        guard !solaLettura, let n = nota(id), var a = bozzaAttivitaDaNota(id) else { return }
        if a.titolo.isEmpty { a.titolo = TestiNoteDossier.titoloAttivita(Formati.giornoMese.string(from: n.creataIl)) }
        a.daNota = id
        salvaAttivita(a)
        let nome = cliente(n.clienteId).map(StatoShell.nomeDiBattesimo) ?? ""
        let idAttivita = a.id
        mostraAvviso(TestiNoteDossier.avvisoDaFare(a.titolo, nome: nome),
                     azione: AzioneAvviso(titolo: TestiNoteDossier.annulla) { [weak self] in self?.eliminaAttivita(idAttivita) })
    }

    /// «Elimina» senza conferma: la nota se ne va e «Annulla» la rimette com'era.
    func eliminaNotaDossier(_ id: String) {
        TestiRinviati.scriviOra()
        guard !solaLettura, let n = nota(id) else { return }
        eliminaNota(id)
        mostraAvviso(TestiNoteDossier.avvisoEliminata, azione: AzioneAvviso(titolo: TestiNoteDossier.annulla) { [weak self] in
            guard let self, self.nota(n.id) == nil, self.cliente(n.clienteId) != nil else { return }
            self.dati.note.append(n)
            self.scegliNota(n.id)
        })
    }

    /// «Svuota» su «Da ricordare» (che non si elimina), con «Annulla».
    func svuotaDaRicordare(_ clienteId: String) {
        TestiRinviati.scriviOra()
        guard !solaLettura, let prima = cliente(clienteId)?.nota, !prima.isEmpty else { return }
        aggiornaNota(clienteId, "")
        mostraAvviso(TestiNoteDossier.avvisoSvuotata, azione: AzioneAvviso(titolo: TestiNoteDossier.annulla) { [weak self] in
            self?.aggiornaNota(clienteId, prima)
        })
    }
}

/// I due campi della nota scelta, per il fuoco: Invio nel titolo porta al testo.
private enum CampoNotaDossier: Hashable {
    case titolo, testo
}

/// La sezione Note del dossier sul Mac.
struct NoteDossierMac: View {
    let cliente: Cliente
    @Environment(StatoShell.self) var stato
    @FocusState private var fuoco: CampoNotaDossier?
    /// La nota nuova che aspetta il fuoco nel titolo (il campo nasce con la riga scelta).
    @State private var fuocoInAttesa: String?

    private typealias K = Tema.Apple.Clienti.NoteDossier

    var body: some View {
        let _ = ContaCorpi.segna()
        if stato.inModoCliente {
            soloInEvidenza
                .entrataDossier(0)
        } else {
            let righe = stato.righeNoteDossier(cliente)
            let scelta = righe.first { $0.id == stato.notaSelezionata } ?? righe.first
            VStack(alignment: .leading, spacing: K.spazioBlocchi) {
                testata
                    .entrataDossier(0)
                HStack(alignment: .top, spacing: K.spazioColonne) {
                    elenco(righe, scelta: scelta?.id)
                        .frame(width: K.larghezzaElenco)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .superficieApple(K.superficie)
                    Group {
                        if let r = scelta {
                            nota(r)
                                .id(r.id)
                        } else {
                            Text(TestiNoteDossier.scegli)
                                .carattereApple(K.rigaGrigia)
                                .foregroundColor(K.secondario)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .superficieApple(K.superficie)
                }
                .frame(height: K.altezzaMinima)
                .entrataDossier(1, sfocatura: false)
            }
        }
    }

    // MARK: Testata

    private var testata: some View {
        HStack(alignment: .center, spacing: K.spazioFila) {
            VStack(alignment: .leading, spacing: K.spazioTestata) {
                Text(TestiNoteDossier.titolo)
                    .carattereApple(K.titoloSezione)
                    .foregroundColor(K.testo)
                Text(TestiNoteDossier.sottotitolo)
                    .carattereApple(K.sottotitolo)
                    .foregroundColor(K.secondario)
            }
            Spacer(minLength: K.spazioFila)
            Button {
                if let n = stato.nuovaNotaDossier(cliente.id) { fuocoInAttesa = n.id }
            } label: {
                Label(TestiNoteDossier.nuova, systemImage: "plus")
            }
            .buttonStyle(.applePrimario)
            .disabled(stato.solaLettura)
        }
    }

    // MARK: Elenco

    private func elenco(_ righe: [RigaNotaDossier], scelta: String?) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            if righe.isEmpty {
                Text(TestiNoteDossier.nessuna)
                    .carattereApple(K.anteprimaRiga)
                    .foregroundColor(K.secondario)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(K.paddingVuoto)
            } else {
                LazyVStack(alignment: .leading, spacing: K.spazioRighe) {
                    ForEach(righe) { r in
                        Button { stato.scegliNotaDossier(r.id) } label: {
                            rigaElenco(r, accesa: r.id == scelta)
                        }
                        .buttonStyle(StileSemplice())
                        .contextMenu {
                            if let n = r.nota {
                                Button(TestiNoteDossier.esporta) { esporta(n.id) }
                                Button(TestiNoteDossier.elimina, role: .destructive) { stato.eliminaNotaDossier(n.id) }
                                    .disabled(stato.solaLettura)
                            }
                        }
                    }
                }
                .padding(K.paddingElenco)
            }
        }
    }

    private func rigaElenco(_ r: RigaNotaDossier, accesa: Bool) -> some View {
        let forma = RoundedRectangle(cornerRadius: K.raggioRiga, style: .continuous)
        return VStack(alignment: .leading, spacing: K.spazioInRiga) {
            HStack(spacing: K.spazioInRiga * 2) {
                Text(r.titolo)
                    .carattereApple(K.titoloRiga)
                    .foregroundColor(K.testo)
                    .lineLimit(1)
                if r.inEvidenza {
                    Image(systemName: "star.fill")
                        .font(K.stella.font)
                        .foregroundColor(K.coloreStella)
                        .accessibilityLabel(Text(TestiNoteDossier.inEvidenza))
                }
                Spacer(minLength: K.spazioInRiga)
                if let d = r.data {
                    Text(TestiNoteDossier.data(d))
                        .carattereApple(K.dataRiga)
                        .foregroundColor(K.secondario)
                        .lineLimit(1)
                }
            }
            Text(r.anteprima)
                .carattereApple(K.anteprimaRiga)
                .foregroundColor(K.secondario)
                .lineLimit(1)
            if r.nelDaFare {
                PillolaStatoApple(testo: TestiNoteDossier.nelDaFare, tono: .ok)
                    .padding(.top, K.spazioInRiga)
            }
        }
        .padding(K.paddingRiga)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(forma.fill(accesa ? K.fondoRigaAccesa : Color.clear))
        .contentShape(forma)
    }

    // MARK: La nota

    private func nota(_ r: RigaNotaDossier) -> some View {
        VStack(alignment: .leading, spacing: K.spazioNota) {
            if let n = r.nota {
                let id = n.id
                TestoRinviato(testo: Binding(get: { stato.nota(id)?.titolo ?? n.titolo },
                                             set: { v in stato.modificaNota(id) { $0.titolo = v } }),
                              salvaOra: { stato.salvaOra() }) { bozza in
                    TextField(TestiNoteDossier.segnapostoTitolo, text: bozza)
                        .textFieldStyle(.plain)
                        .carattereApple(K.titoloNota)
                        .foregroundColor(K.testo)
                        .focused($fuoco, equals: .titolo)
                        .onSubmit { fuoco = .testo }
                        .disabled(stato.solaLettura)
                }
                TestoRinviato(testo: Binding(get: { stato.nota(id)?.testo ?? n.testo },
                                             set: { v in stato.modificaNota(id) { $0.testo = v } }),
                              salvaOra: { stato.salvaOra() }) { bozza in
                    campoTesto(bozza)
                }
            } else {
                let id = cliente.id
                Text(TestiNoteDossier.daRicordare)
                    .carattereApple(K.titoloNota)
                    .foregroundColor(K.testo)
                TestoRinviato(testo: Binding(get: { stato.cliente(id)?.nota ?? cliente.nota },
                                             set: { stato.aggiornaNota(id, $0) }),
                              salvaOra: { stato.salvaOra() }) { bozza in
                    campoTesto(bozza)
                }
            }
            Rectangle()
                .fill(K.filo)
                .frame(height: K.spessoreFilo)
            fila(r)
            Text(rigaGrigia(r))
                .carattereApple(K.rigaGrigia)
                .foregroundColor(K.secondario)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(K.paddingNota)
        .onAppear {
            guard fuocoInAttesa == r.id else { return }
            fuocoInAttesa = nil
            // Il campo è appena nato con la riga: il fuoco al giro dopo
            DispatchQueue.main.async { fuoco = .titolo }
        }
    }

    private func campoTesto(_ bozza: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: bozza)
                .font(K.testoNota.font)
                .lineSpacing(K.testoNota.spazioRighe)
                .foregroundColor(K.testo)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.never)
                .focused($fuoco, equals: .testo)
                .disabled(stato.solaLettura)
            if bozza.wrappedValue.isEmpty {
                Text(TestiNoteDossier.segnapostoTesto)
                    .font(K.testoNota.font)
                    .foregroundColor(K.segnaposto)
                    .padding(.leading, K.spazioInRiga + 2)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func fila(_ r: RigaNotaDossier) -> some View {
        let vuota = r.nota.map(\.vuota) ?? cliente.nota.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return HStack(spacing: K.spazioFila) {
            Button {
                if r.inEvidenza {
                    stato.togliEvidenza(cliente: cliente.id)
                } else {
                    stato.mettiInEvidenza(r.id, cliente: cliente.id)
                }
            } label: {
                Label(r.inEvidenza ? TestiNoteDossier.inEvidenza : TestiNoteDossier.mettiInEvidenza,
                      systemImage: r.inEvidenza ? "star.fill" : "star")
            }
            .buttonStyle(.apple)
            // «Da ricordare» in evidenza resta lì finché un'altra nota non la prende; una nota vuota non va in evidenza
            .disabled(stato.solaLettura || (r.daRicordare && r.inEvidenza) || (!r.inEvidenza && vuota))
            if let n = r.nota {
                Button { stato.notaNelDaFare(n.id) } label: {
                    Label(r.nelDaFare ? TestiNoteDossier.eNelDaFare : TestiNoteDossier.fanneUnDaFare,
                          systemImage: r.nelDaFare ? "checkmark" : "checklist")
                }
                .buttonStyle(.apple)
                .disabled(stato.solaLettura || r.nelDaFare)
            }
            Spacer(minLength: K.spazioFila)
            if let n = r.nota {
                Button(TestiNoteDossier.elimina) { stato.eliminaNotaDossier(n.id) }
                    .buttonStyle(.appleSobrio)
                    .disabled(stato.solaLettura)
            } else {
                Button(TestiNoteDossier.svuota) { stato.svuotaDaRicordare(cliente.id) }
                    .buttonStyle(.appleSobrio)
                    .disabled(stato.solaLettura || vuota)
            }
        }
    }

    private func rigaGrigia(_ r: RigaNotaDossier) -> String {
        if r.inEvidenza { return TestiNoteDossier.rigaInEvidenza }
        guard let d = r.data else { return TestiNoteDossier.quellaInEvidenza }
        let quando = Calendar.current.isDateInToday(d)
            ? TestiNoteDossier.modificataOggi
            : TestiNoteDossier.modificataIl(Formati.giornoMese.string(from: d))
        return quando + TestiNoteDossier.codaQuellaInEvidenza
    }

    // MARK: Modalità cliente

    /// Davanti al cliente: solo la nota in evidenza, in sola lettura, senza l'elenco (il taccuino è del consulente).
    private var soloInEvidenza: some View {
        let e = stato.notaInEvidenza(cliente)
        return VStack(alignment: .leading, spacing: K.spazioNota) {
            Text(TestiNoteDossier.daRicordare)
                .carattereApple(K.titoloSezione)
                .foregroundColor(K.testo)
            if let e {
                if !e.daRicordare, !e.titolo.isEmpty {
                    Text(e.titolo)
                        .carattereApple(K.titoloRiga)
                        .foregroundColor(K.testo)
                }
                Text(e.testo)
                    .carattereApple(K.testoNota)
                    .foregroundColor(K.testo)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(TestiNoteDossier.nienteDaRicordare)
                    .carattereApple(K.testoNota)
                    .foregroundColor(K.secondario)
            }
        }
        .padding(K.paddingNota)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .superficieApple(K.superficie)
    }

    // MARK: Esporta

    /// «Esporta .txt…» dal menu della riga (decisione 65-d): la copia resta dove la salva l'utente.
    private func esporta(_ id: String) {
        TestiRinviati.scriviOra()
        guard let n = stato.nota(id) else { return }
        let pannello = NSSavePanel()
        pannello.allowedContentTypes = [.plainText]
        pannello.nameFieldStringValue = "\(n.titoloMostrato.replacingOccurrences(of: "/", with: "-")).txt"
        pannello.canCreateDirectories = true
        pannello.message = "La copia resta dove la salvi: Prisma non la invia a nessuno."
        if pannello.runModal() == .OK, let url = pannello.url {
            try? Data(stato.testoEsportato(n).utf8).write(to: url)
        }
    }
}
#endif
