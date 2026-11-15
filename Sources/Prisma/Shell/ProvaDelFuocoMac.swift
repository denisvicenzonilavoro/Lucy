#if os(macOS)
import SwiftUI

// Migliorie d'uso 41 (solo Mac, Design/uso/gruppo-07.md §41): «La prova del fuoco in tre gruppi».
// - «Chi sentire, in ordine» è diviso in gruppi con il nome: da chiamare (il loro obiettivo perde più di 10 punti), da
//   tenere d'occhio (tra 5 e 10), reggono (meno di 5) e, in fondo, i clienti senza obiettivo. Ogni gruppo ha la sua
//   testata con la capsula, il conto e la frase; «Da chiamare» ha «Prepara i N messaggi».
// - La riga perde «Chiama» e «Messaggio»: la cifra è una sola, «oggi → dopo», e tutta la riga apre il dettaglio che
//   nasce dalla riga (`DettaglioProvaFuoco`, 840×440) con i tre riquadri, il «Perché» e tre azioni.
// - Le bozze sono del modello fisso di Messaggi e restano in Messaggi: niente parte da solo. «Segna «da chiamare»» mette
//   un'attività nel Da fare di oggi (una sola al giorno per cliente). Il telefono resta nel dossier.
// L'iPad tiene la riga e la lista di prima (ProvaDelFuocoApple.swift) finché non arriva il suo giro.

// MARK: - Testata di un gruppo

struct TestataGruppoFuoco: View {
    let gruppo: GruppoProvaFuoco
    let numero: Int
    /// Il primo gruppo dell'elenco non ha spazio sopra.
    let primo: Bool
    /// «✓ Preparati»: le bozze di questo scenario sono già state preparate (stato della vista).
    let preparati: Bool
    let solaLettura: Bool
    let prepara: () -> Void

    var body: some View {
        let t = Tema.Apple.Posizioni.Fuoco.Gruppo.self
        return HStack(alignment: .center, spacing: t.spazio) {
            CapsulaStatoApple(testo: TestiProvaFuoco.capsulaGruppo(gruppo, numero: numero), tono: Self.tono(gruppo))
            Text(TestiProvaFuoco.fraseGruppo(gruppo, numero: numero))
                .carattereApple(t.frase)
                .foregroundColor(t.coloreFrase)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
            if gruppo == .daChiamare {
                Button(preparati ? TestiProvaFuoco.preparati : TestiProvaFuoco.prepara(numero), action: prepara)
                    .buttonStyle(.apple)
                    .fixedSize()
                    .disabled(preparati || solaLettura)
            }
        }
        .padding(EdgeInsets(top: primo ? 0 : t.sopra, leading: t.lati, bottom: t.sotto, trailing: t.lati))
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
    }

    /// Il tono della capsula: rosso, arancio, verde; grigio per i clienti senza obiettivo.
    static func tono(_ g: GruppoProvaFuoco) -> Pillola.Tono {
        switch g {
        case .daChiamare: return .errore
        case .daTenereDOcchio: return .attenzione
        case .reggono: return .ok
        case .senzaObiettivo: return .neutro
        }
    }
}

// MARK: - La legenda sopra la lista

/// Una barretta della legenda (22×8, raggio 5) con la sua parola.
struct BarrettaLegendaFuoco: View {
    let colore: Color
    let testo: String

    var body: some View {
        let t = Tema.Apple.Posizioni.Fuoco.Titolo.self
        return HStack(alignment: .center, spacing: t.spazioBarretta) {
            RoundedRectangle(cornerRadius: t.raggioBarretta, style: .continuous)
                .fill(colore)
                .frame(width: t.barretta.width, height: t.barretta.height)
                .accessibilityHidden(true)
            Text(testo)
                .carattereApple(t.nota)
                .foregroundColor(t.coloreNota)
                .lineLimit(1)
        }
    }
}

// MARK: - Una riga di «Chi sentire»

struct RigaProvaFuocoMac: View, Equatable {
    let riga: RigaProvaFuoco
    let iniziali: String
    let tinta: TintaAvatar
    let canali: [Canale]
    let misura: MisuraRigaFuoco
    /// Apre il dettaglio che nasce dalla riga.
    let apri: () -> Void
    /// «Aggiungi un obiettivo» (righe senza obiettivo): il dossier sulla scheda Obiettivi.
    let aggiungiObiettivo: () -> Void

    /// Il fondo al passaggio è della riga (la riga resta `Equatable` per il contenitore).
    @State private var sopra = false

    nonisolated static func == (a: RigaProvaFuocoMac, b: RigaProvaFuocoMac) -> Bool {
        a.riga == b.riga && a.iniziali == b.iniziali && a.tinta == b.tinta && a.canali == b.canali && a.misura == b.misura
    }

    private var stretta: Bool { misura != .piena }

    var body: some View {
        let r = Tema.Apple.Posizioni.Fuoco.Riga.self
        let spazio = misura == .minima ? r.spazioMinimo : r.spazio
        return HStack(alignment: .center, spacing: spazio) {
            AvatarCliente(iniziali: iniziali, tinta: tinta.colori, lato: r.avatar)
            nome
            canaliVista
            barra
                .frame(minWidth: misura == .minima ? r.barraMinimaStretta : r.barraMinima, maxWidth: .infinity)
            cifra
                .frame(width: misura == .minima ? misura.larghezzaPercento : r.larghezzaOggiDopo, alignment: .trailing)
            perdita
                .frame(width: misura.larghezzaPerdita, alignment: .trailing)
            Text(TestiProvaFuoco.freccia)
                .carattereApple(r.freccia)
                .foregroundColor(r.coloreFreccia)
                .frame(width: r.larghezzaFreccia)
                .accessibilityHidden(true)
        }
        .padding(r.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: r.raggio, style: .continuous)
                .fill(r.fondoSopra)
                .opacity(sopra ? 1 : 0)
        }
        .superficieApple(r.superficie, raggio: r.raggio)
        .contentShape(Rectangle())
        .onTapGesture(perform: apri)
        .onHover { dentro in if sopra != dentro { sopra = dentro } }
        .help(TestiProvaFuoco.aiutoRigaDettaglio)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(TestiProvaFuoco.voceRiga(riga)))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { apri() }
    }

    private var nome: some View {
        let r = Tema.Apple.Posizioni.Fuoco.Riga.self
        return VStack(alignment: .leading, spacing: r.spazioRighe) {
            Text(riga.nome)
                .carattereApple(r.nome)
                .foregroundColor(r.coloreNome)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(riga.titoloObiettivo ?? TestiProvaFuoco.senzaObiettivo)
                .carattereApple(r.obiettivo)
                .foregroundColor(r.coloreObiettivo)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(width: misura.larghezzaNome, alignment: .leading)
    }

    /// Il canale delle posizioni in essere resta sulla riga (regola dei canali): l'etichetta compatta, nella riga
    /// stretta il solo pallino del colore.
    @ViewBuilder private var canaliVista: some View {
        let r = Tema.Apple.Posizioni.Fuoco.Riga.self
        if !canali.isEmpty {
            if stretta {
                HStack(spacing: r.spazioCanali) {
                    ForEach(canali) { c in
                        Circle()
                            .fill(r.coloreCanale(c))
                            .frame(width: r.pallinoCanale, height: r.pallinoCanale)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(canali.map(\.nome).joined(separator: ", ")))
                .help(canali.map(\.nome).joined(separator: " · "))
            } else {
                VStack(alignment: .leading, spacing: r.spazioCanali) {
                    ForEach(canali) { c in
                        EtichettaCanaleApple(canale: c, compatta: true)
                    }
                }
                .fixedSize()
            }
        }
    }

    @ViewBuilder private var barra: some View {
        let r = Tema.Apple.Posizioni.Fuoco.Riga.self
        if riga.obiettivoId != nil {
            BarraOggiDopo(oggi: riga.coperturaOggi, dopo: riga.coperturaDopo,
                          colore: Tema.Apple.Posizioni.Fuoco.Barra.colore(MotoreProvaFuoco.livello(calo: riga.calo)))
        } else {
            HStack(spacing: r.spazio) {
                Text(TestiProvaFuoco.nessunObiettivo)
                    .carattereApple(r.senzaObiettivo)
                    .foregroundColor(r.coloreSenzaObiettivo)
                    .lineLimit(1)
                Button(TestiProvaFuoco.aggiungiObiettivo, action: aggiungiObiettivo)
                    .buttonStyle(.appleSobrio)
                    .fixedSize()
                Spacer(minLength: 0)
            }
        }
    }

    /// «52% → 38%» (rossa per chi è da chiamare), con la «≈» delle stime davanti.
    @ViewBuilder private var cifra: some View {
        let r = Tema.Apple.Posizioni.Fuoco.Riga.self
        if riga.obiettivoId != nil {
            VStack(alignment: .trailing, spacing: r.spazioRighe) {
                HStack(spacing: r.spazioStima) {
                    if riga.stimata {
                        Text(TestiProvaFuoco.segnoStima)
                            .carattereApple(r.stima)
                            .foregroundColor(r.coloreStima)
                            .help(TestiProvaFuoco.aiutoStima)
                    }
                    Text(TestiProvaFuoco.oggiDopo(riga.coperturaOggi, riga.coperturaDopo))
                        .carattereApple(r.dopo)
                        .foregroundColor(riga.oltreSoglia ? r.coloreDopoAllarme : r.coloreDopo)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                if riga.collegateAssenti && riga.calo == 0 {
                    Text(TestiProvaFuoco.nessunaCollegata)
                        .carattereApple(r.oggi)
                        .foregroundColor(r.coloreOggi)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        } else {
            Color.clear.frame(height: 1)
        }
    }

    private var perdita: some View {
        let r = Tema.Apple.Posizioni.Fuoco.Riga.self
        let p = riga.perdita
        return Text(TestiProvaFuoco.perdita(p))
            .carattereApple(r.perdita)
            .foregroundColor(p >= 0.5 ? r.colorePerdita : (p <= -0.5 ? r.coloreGuadagno : r.coloreOggi))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

// MARK: - Il dettaglio della riga

struct DettaglioProvaFuoco: View {
    let riga: RigaProvaFuoco
    let iniziali: String
    let tinta: TintaAvatar
    let scenario: ScenarioFuoco
    let solaLettura: Bool
    /// «Prepara il messaggio»: Messaggi sull'occasione di oggi.
    let prepara: () -> Void
    /// «Segna «da chiamare»»: un'attività nel Da fare di oggi.
    let segna: () -> Void
    /// «Apri la sua prova di resistenza»: le Posizioni del cliente.
    let resistenza: () -> Void
    /// Il dossier sulla scheda Obiettivi (il titolo dell'obiettivo, «Aggiungi un obiettivo»).
    let obiettivo: () -> Void

    private typealias D = Tema.Apple.Posizioni.Fuoco.Dettaglio
    private typealias K = Tema.Apple.Colore

    var body: some View {
        let g = riga.gruppo
        return VStack(alignment: .leading, spacing: 0) {
            testa(g)
            if riga.obiettivoId != nil {
                HStack(alignment: .top, spacing: D.spazioRiquadri) {
                    riquadro(TestiProvaFuoco.coperturaOggiRiquadro, MotoreProvaFuoco.percento(riga.coperturaOggi),
                             sotto: nil, colore: K.inchiostro, coloreSotto: K.inchiostro2)
                    riquadro(TestiProvaFuoco.dopoScenarioRiquadro,
                             (riga.stimata ? TestiProvaFuoco.segnoStima + " " : "") + MotoreProvaFuoco.percento(riga.coperturaDopo),
                             sotto: riga.calo < 1 ? TestiProvaFuoco.tiene : TestiProvaFuoco.puntiInMeno(Int(riga.calo.rounded())),
                             colore: g == .daChiamare ? K.rosso : K.inchiostro,
                             coloreSotto: g == .daChiamare ? K.rosso : K.inchiostro2)
                    riquadroPatrimonio
                }
                .padding(.top, D.sopraRiquadri)
                if let perche = TestiProvaFuoco.perche(riga) {
                    VStack(alignment: .leading, spacing: D.spazioRiquadro) {
                        Text(TestiProvaFuoco.percheTitolo)
                            .carattereApple(D.etichettaRiquadro)
                            .foregroundColor(K.inchiostro2)
                        Text(perche)
                            .carattereApple(D.perche)
                            .foregroundColor(K.inchiostro)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(Tema.Apple.Misura.Padding.tile)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .superficieApple(Tema.Apple.Superficie.tile)
                    .padding(.top, D.sopraPerche)
                }
            } else {
                HStack(alignment: .top, spacing: D.spazioRiquadri) {
                    VStack(alignment: .leading, spacing: D.spazioRiquadro) {
                        Text(TestiProvaFuoco.nessunObiettivo)
                            .carattereApple(D.etichettaRiquadro)
                            .foregroundColor(K.inchiostro2)
                        Text(TestiProvaFuoco.fraseGruppo(.senzaObiettivo, numero: 1))
                            .carattereApple(D.perche)
                            .foregroundColor(K.inchiostro)
                            .fixedSize(horizontal: false, vertical: true)
                        Button(TestiProvaFuoco.aggiungiObiettivo, action: obiettivo)
                            .buttonStyle(.appleSobrio)
                            .fixedSize()
                            .disabled(solaLettura)
                    }
                    .padding(Tema.Apple.Misura.Padding.tile)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .superficieApple(Tema.Apple.Superficie.tile)
                    riquadroPatrimonio
                }
                .padding(.top, D.sopraRiquadri)
            }
            Spacer(minLength: D.sopraPulsanti)
            HStack(spacing: D.spazioPulsanti) {
                Button(TestiProvaFuoco.preparaMessaggio, action: prepara)
                    .buttonStyle(StilePulsanteApple(.principale, grande: true))
                Button(TestiProvaFuoco.segnaDaChiamare, action: segna)
                    .buttonStyle(StilePulsanteApple(.secondaria, grande: true))
                    .disabled(solaLettura)
                Button(TestiProvaFuoco.apriResistenza, action: resistenza)
                    .buttonStyle(StilePulsanteApple(.secondaria, grande: true))
            }
        }
        .padding(Tema.Apple.Misura.Padding.dettaglio)
        .frame(width: D.misura.width, height: D.misura.height, alignment: .topLeading)
    }

    private func testa(_ g: GruppoProvaFuoco) -> some View {
        HStack(alignment: .center, spacing: D.spazioTesta) {
            AvatarCliente(iniziali: iniziali, tinta: tinta.colori, lato: D.avatar)
            VStack(alignment: .leading, spacing: Tema.Apple.Posizioni.Fuoco.Riga.spazioRighe) {
                Text(TestiProvaFuoco.occhielloDettaglio(g, scenario: scenario))
                    .carattereApple(D.occhiello)
                    .foregroundColor(D.colore(g))
                    .lineLimit(1)
                Text(riga.nome)
                    .carattereApple(D.nome)
                    .foregroundColor(K.inchiostro)
                    .lineLimit(1)
                if let t = riga.titoloObiettivo, riga.obiettivoId != nil {
                    // Il collegamento al dossier sull'obiettivo (prima nome e avatar della riga)
                    Button(action: obiettivo) {
                        Text(TestiProvaFuoco.obiettivoDettaglio(t))
                            .carattereApple(D.obiettivo)
                            .foregroundColor(K.inchiostro2)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)
                    .help(TestiProvaFuoco.aiutoRiga)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.trailing, D.margineChiudi - Tema.Apple.Misura.Padding.dettaglio.trailing)
    }

    private var riquadroPatrimonio: some View {
        let p = riga.perdita
        return riquadro(TestiProvaFuoco.patrimonioRiquadro, TestiProvaFuoco.perdita(p),
                        sotto: TestiProvaFuoco.suPatrimonio(riga.patrimonio),
                        colore: p >= 0.5 ? K.rosso : (p <= -0.5 ? K.verde : K.inchiostro),
                        coloreSotto: p >= 0.5 ? K.rosso : K.inchiostro2)
    }

    private func riquadro(_ etichetta: String, _ valore: String, sotto: String?, colore: Color,
                          coloreSotto: Color) -> some View {
        VStack(alignment: .leading, spacing: D.spazioRiquadro) {
            Text(etichetta)
                .carattereApple(D.etichettaRiquadro)
                .foregroundColor(K.inchiostro2)
                .lineLimit(1)
            Text(valore)
                .carattereApple(D.valoreRiquadro)
                .foregroundColor(colore)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(sotto ?? " ")
                .carattereApple(D.sottoRiquadro)
                .foregroundColor(coloreSotto)
                .lineLimit(1)
        }
        .padding(Tema.Apple.Misura.Padding.tile)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.tile)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Le azioni (StatoShell)

extension StatoShell {
    /// «Prepara i N messaggi»: una bozza del modello fisso di Messaggi per ogni riga (tono cordiale, Mail, firma del
    /// canale di lavoro), in stato «bozza», con una sola assegnazione a `dati.messaggi`. Idempotente: l'occasione dice
    /// cliente, scenario e giorno, e chi ha già un messaggio con quell'occasione si salta. Niente si apre né parte.
    /// Restituisce quante bozze ha creato.
    @discardableResult
    func preparaMessaggiProvaFuoco(_ righe: [RigaProvaFuoco], scenario: ScenarioFuoco, oggi: Date = Date()) -> Int {
        guard !solaLettura, !inModoCliente, !righe.isEmpty else { return 0 }
        let ids = Set(righe.map(\.clienteId))
        let canali = ProvaDelFuocoApple.canaliInEssere(dati.posizioni.filter { ids.contains($0.clienteId) })
        var clienti: [String: Cliente] = [:]
        for c in dati.clienti where ids.contains(c.id) { clienti[c.id] = c }
        var occasioni = Set(dati.messaggi.lazy.filter { ids.contains($0.clienteId) }.map(\.occasioneId))
        let adesso = MessaggioCliente.adesso
        let tono = TonoMessaggio.cordiale
        let canale = CanaleMessaggio.mail
        var nuovi: [MessaggioCliente] = []
        var gia = 0
        for r in righe {
            guard let c = clienti[r.clienteId] else { continue }
            let suoi = canali[r.clienteId] ?? []
            let o = MotoreProvaFuoco.occasioneMessaggio(r, scenario: scenario, canale: suoi.count == 1 ? suoi.first : nil, oggi: oggi)
            guard !occasioni.contains(o.id) else {
                gia += 1
                continue
            }
            occasioni.insert(o.id)
            let t = ModelliMessaggi.testo(o, tono: tono, canale: canale, cliente: c, firma: firmaMessaggio(o.canale, tono: tono))
            nuovi.append(MessaggioCliente(clienteId: r.clienteId, occasioneId: o.id, origine: o.origine, canaleLavoro: o.canale,
                                          tono: tono, canale: canale, oggetto: t.oggetto, testo: t.completo, cifre: o.cifre,
                                          autore: .modelloFisso, modello: nil, creatoIl: adesso))
        }
        if !nuovi.isEmpty { dati.messaggi = dati.messaggi + nuovi }
        mostraAvviso(TestiProvaFuoco.avvisoPreparati(nuovi.count, gia: gia))
        return nuovi.count
    }

    /// «Segna «da chiamare»»: un'attività per oggi, priorità alta, con scenario e coperture nelle note. Idempotente: l'id
    /// dice cliente e giorno, e una seconda pressione lo stesso giorno non crea un doppione. true se l'ha creata.
    @discardableResult
    func segnaDaChiamare(riga: RigaProvaFuoco, scenario: ScenarioFuoco, oggi: Date = Date()) -> Bool {
        guard !solaLettura, !inModoCliente else { return false }
        let id = Self.idAttivitaFuoco(clienteId: riga.clienteId, oggi: oggi)
        guard !dati.attivita.contains(where: { $0.id == id }) else {
            mostraAvviso(TestiProvaFuoco.giaNelDaFare)
            return false
        }
        let a = Attivita(id: id, clienteId: riga.clienteId, titolo: TestiProvaFuoco.titoloDaChiamare(riga.nome),
                         scadenza: Calendar.current.startOfDay(for: oggi), priorita: .alta, completata: false,
                         note: TestiProvaFuoco.noteDaChiamare(riga, scenario: scenario))
        salvaAttivita(a)
        mostraAvviso(TestiProvaFuoco.aggiuntoAlDaFare(riga.nome))
        return true
    }

    /// L'id stabile dell'attività «da chiamare»: `task-fuoco-<cliente>-<giorno>`.
    static func idAttivitaFuoco(clienteId: String, oggi: Date, calendario: Calendar = .current) -> String {
        let g = calendario.dateComponents([.year, .month, .day], from: oggi)
        return "task-fuoco-\(clienteId)-" + String(format: "%04d%02d%02d", g.year ?? 0, g.month ?? 0, g.day ?? 0)
    }

    /// «Apri la sua prova di resistenza»: le Posizioni del cliente sulla prova di resistenza (migliorie d'uso 14).
    func apriResistenzaDaFuoco(_ clienteId: String) {
        // Scegliere il cliente lascia «Tutti i clienti» (sul Mac `portafoglio` è la stessa scelta della barra)
        scegliCliente(clienteId)
        posizioneInDettaglio = nil
        ancoraPosizioni = "resistenza"
        apri(.posizioni)
    }
}
#endif
