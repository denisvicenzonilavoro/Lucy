#if os(macOS)
import SwiftUI
import AppKit
import UniformTypeIdentifiers

// Migliorie d'uso 42 «Lo smontaggio ha i numeri» (Design/uso/gruppo-07.md §42, template righe 4336-4383), solo Mac:
//
//   ┌ vassoio ───────────────────────────┐ ┌ il documento ─────────────────────────────┐
//   │  ┌ foglio ─────────────────────┐   │ │ (GR) Documento di Giulia · valore 90.000 €│
//   │  │ Gestione   ( 2,10% l'anno ) ①   │ │ Fondo Esempio Globale          Cambia ⌄   │
//   │  │ Diritti    ( 25 € a trim. ) ②   │ │ 2.410 € → 760 €          In 10 anni +…    │
//   │  └─────────────────────────────┘   │ ├ le voci cerchiate, in ordine ─────────────┤
//   │                                    │ │ ① Commissione di gestione      1.890 € …  │
//   └────────────────────────────────────┘ ├ in dieci anni: grafico piccolo e pulsanti ┤
//
// - Le note ai margini non ci sono più: accanto a ogni ellisse il numero della voce (la sua posizione in `costi.voci`
//   più uno), lo stesso dell'elenco a destra. Le righe dell'elenco si accendono con la loro ellisse; il puntatore su
//   una riga accende la sua ellisse e viceversa (`SopraSmontaggio`, letto solo da ellissi e righe).
// - Il documento si sceglie («Cambia ⌄»): quello letto, in memoria, e quelli già nei Documenti del cliente con le voci
//   di costo (`StatoShell.documentiSmontati`). Un documento conservato si riapre dalle sue voci, senza ricalcolare le
//   cifre (`StatoShell.riapriSmontaggio`), e non si modifica (è già nel dossier).
// - La vista segue il cliente: con un cliente scelto (indice delle sue Posizioni) solo i suoi documenti, o il vuoto
//   nuovo; il documento letto di un altro cliente resta in memoria e ricompare tornando a «Tutti i clienti».
// - iPhone e iPad tengono lo Smontaggio di prima (SmontaggioApple.swift) finché non arriva il loro giro.

/// Il documento che lo Smontaggio mostra adesso: quello letto (in memoria) o uno conservato nel dossier.
private struct DocumentoSmontaggioMac {
    var righe: [RigaLetta]
    var costi: SmontaggioCosti
    var titolo: String
    /// Da dove viene (nell'aiuto): «inquadrato con l'iPhone», il nome del file, «Nei Documenti del cliente».
    var origine: String
    var clienteId: String?
    var posizioneId: String?
    /// L'id del documento conservato; nil = il documento letto, in memoria.
    var documentoId: String?
    /// Il giro delle ellissi: cambia con il documento, così ellissi, numeri e righe ripartono.
    var identita: String

    var conservato: Bool { documentoId != nil }
}

struct SmontaggioMac: View {
    let stato: StatoShell
    let smontaggio: StatoSmontaggio
    /// Il cliente scelto (indice delle sue Posizioni); nil = «Tutti i clienti» (la vista della testata del portafoglio).
    let clienteScelto: String?
    @State private var fumetto: Int?
    @State private var sopraVassoio = false
    /// «Aggiungi al dossier…» chiede conferma: niente entra nel dossier senza un sì.
    @State private var confermaDossier = false

    private typealias S = Tema.Apple.Posizioni.Smontaggio
    private typealias C = Tema.Apple.Colore

    init(stato: StatoShell, clienteScelto: String? = nil) {
        self.stato = stato
        self.smontaggio = stato.smontaggio
        self.clienteScelto = clienteScelto
        _fumetto = State(initialValue: stato.smontaggio.fumettoIstantanea)
    }

    var body: some View {
        let elenco = stato.documentiSmontati(clienteId: clienteScelto)
        let mostrato = documentoMostrato(elenco)
        if mostrato == nil, !smontaggio.inLettura, let id = clienteScelto, let c = stato.cliente(id) {
            vuotoCliente(c)
        } else {
            contenuto(mostrato, elenco: elenco)
        }
    }

    // MARK: Quale documento

    /// La chiave della scelta di «Cambia ⌄» per questa vista.
    private var chiaveScelta: String { clienteScelto ?? "" }

    /// Il documento letto appartiene a questa vista (tutti i clienti, o il cliente scelto).
    private var lettoQui: Bool {
        !smontaggio.vuoto && (clienteScelto == nil || smontaggio.clienteId == clienteScelto)
    }

    /// Prima il conservato scelto con «Cambia ⌄», poi il documento letto (se è di questa vista), poi il primo conservato
    /// del cliente scelto. nil: niente da mostrare (il vuoto di sempre, o quello del cliente).
    private func documentoMostrato(_ elenco: [Documento]) -> DocumentoSmontaggioMac? {
        if let id = smontaggio.documentoScelto[chiaveScelta], let d = elenco.first(where: { $0.id == id }) {
            return conservato(d)
        }
        if smontaggio.inLettura || lettoQui { return letto() }
        if clienteScelto != nil, let d = elenco.first { return conservato(d) }
        return nil
    }

    private func letto() -> DocumentoSmontaggioMac {
        let posizione = smontaggio.posizioneId.flatMap { id in stato.dati.posizioni.first { $0.id == id } }
        let costi = MotoreSmontaggio.smonta(righeEffettive, valore: posizione?.valore, versato: posizione?.totaleVersato,
                                            penaleCondizioni: nil)
        return DocumentoSmontaggioMac(righe: smontaggio.righe, costi: costi, titolo: smontaggio.titolo, origine: smontaggio.origine,
                                      clienteId: smontaggio.clienteId, posizioneId: smontaggio.posizioneId, documentoId: nil,
                                      identita: "letto-\(smontaggio.giro)")
    }

    private func conservato(_ d: Documento) -> DocumentoSmontaggioMac {
        let r = stato.ricavato("smontaggio-riaperto-\(d.id)") { stato.riapriSmontaggio(d) }
        return DocumentoSmontaggioMac(righe: r.righe, costi: r.costi, titolo: r.titolo,
                                      origine: "Nei Documenti del cliente · " + Formati.dataEstesa.string(from: d.importatoIl),
                                      clienteId: r.clienteId, posizioneId: r.posizioneId, documentoId: r.documentoId,
                                      identita: "conservato-\(r.documentoId)-\(smontaggio.giro)")
    }

    /// Le righe con le scelte dell'utente: le escluse diventano testo semplice, le segnate portano la parola del tipo.
    private var righeEffettive: [RigaLetta] {
        smontaggio.righe.enumerated().map { i, r in
            if smontaggio.esclusi.contains(i) { return RigaLetta(testo: "· " + r.testo.filter { !$0.isNumber }, riquadro: r.riquadro) }
            if let t = smontaggio.tipiScelti[i], MotoreSmontaggio.tipo(r.testo) != t {
                return RigaLetta(testo: t.nome + " " + MotoreSmontaggio.valoreScritto(r.testo), riquadro: r.riquadro)
            }
            return r
        }
    }

    /// Le voci di «Cambia ⌄»: il documento letto (se è di questa vista) e i conservati.
    private func scelte(_ elenco: [Documento]) -> [(id: String?, titolo: String)] {
        var v: [(id: String?, titolo: String)] = []
        if lettoQui {
            v.append((id: nil, titolo: TestiSmontaggio.voceDocumento(titolo: smontaggio.titolo, nome: nomeDi(smontaggio.clienteId))))
        }
        v += elenco.map { (id: Optional($0.id), titolo: TestiSmontaggio.voceDocumento(titolo: $0.titolo, nome: nomeDi($0.clienteId))) }
        return v
    }

    private func nomeDi(_ id: String?) -> String? { clienteDi(id)?.nome }

    private func clienteDi(_ id: String?) -> Cliente? {
        guard let id, !id.isEmpty else { return nil }
        return stato.cliente(id)
    }

    private func nomeBreve(_ c: Cliente?) -> String {
        c?.nome.split(separator: " ").first.map(String.init) ?? "il cliente"
    }

    /// Le proposte del cliente da confrontare, tenute fra i dati ricavati (niente filtri sull'archivio nel body).
    private func proposteDelCliente(_ id: String?) -> [Posizione] {
        guard let id else { return [] }
        return stato.ricavato("smontaggio-proposte-\(id)") {
            stato.dati.posizioni.filter { $0.clienteId == id && $0.stato == .proposta && $0.area != .protezione }
        }
    }

    /// La proposta scelta, o quella con il costo annuo più basso (decisione 5).
    private func sceltaProposta(_ proposte: [Posizione], attuale: Posizione?) -> Posizione? {
        if let id = smontaggio.propostaId, let p = proposte.first(where: { $0.id == id }) { return adatta(p, a: attuale) }
        return proposte.min { ($0.costoAnnuoPercento ?? .infinity) < ($1.costoAnnuoPercento ?? .infinity) }.map { adatta($0, a: attuale) }
    }

    /// La proposta con lo stesso capitale del documento (il confronto riparte dal valore di oggi).
    private func adatta(_ p: Posizione, a attuale: Posizione?) -> Posizione {
        var q = p
        if let v = attuale?.valore, q.versamentoIniziale <= 0 { q.versamentoIniziale = v }
        return q
    }

    // MARK: Disposizione

    @ViewBuilder private func contenuto(_ m: DocumentoSmontaggioMac?, elenco: [Documento]) -> some View {
        let cliente = clienteDi(m?.clienteId)
        let posizione = m?.posizioneId.flatMap { id in stato.dati.posizioni.first { $0.id == id } }
        let costi = m?.costi ?? SmontaggioCosti(voci: [], valore: nil, versato: nil)
        let proposte = proposteDelCliente(cliente?.id)
        let attuale = m == nil ? nil : MotoreSmontaggio.posizioneProvvisoria(costi, da: posizione, clienteId: cliente?.id ?? "",
                                                                            nome: m?.titolo ?? "")
        let scelta = sceltaProposta(proposte, attuale: attuale)
        let esito = attuale.flatMap { a in scelta.map { MotoreSmontaggio.confronto(costi, attuale: a, proposta: $0, prodotti: stato.dati.prodotti) } }
        let anno = m.flatMap { MotoreSmontaggio.annoDocumento($0.righe) }
        GeometryReader { g in
            let affiancati = g.size.width >= S.sogliaAffiancati
            let colonna = min(S.larghezzaColonna, max(S.colonnaMinima, g.size.width * 0.38))
            Group {
                if affiancati {
                    HStack(alignment: .top, spacing: S.spazio) {
                        vassoio(m, costi: costi)
                            .entrataCascata(0, base: S.Moto.baseCascata)
                        VStack(alignment: .leading, spacing: S.spazio) {
                            cardDocumento(m, costi: costi, cliente: cliente, posizione: posizione, scelta: scelta, esito: esito,
                                          elenco: elenco)
                                .fixedSize(horizontal: false, vertical: true)
                                .entrataCascata(1, base: S.Moto.baseCascata)
                            cardVoci(m, costi: costi, cliente: cliente, anno: anno, scorre: true)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .entrataCascata(2, base: S.Moto.baseCascata)
                            cardDieciAnni(m, costi: costi, cliente: cliente, proposte: proposte, scelta: scelta, esito: esito,
                                          attuale: attuale)
                                .fixedSize(horizontal: false, vertical: true)
                                .entrataCascata(3, base: S.Moto.baseCascata)
                        }
                        .frame(width: colonna)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: S.spazio) {
                            vassoio(m, costi: costi).frame(minHeight: 560)
                            cardDocumento(m, costi: costi, cliente: cliente, posizione: posizione, scelta: scelta, esito: esito,
                                          elenco: elenco)
                            cardVoci(m, costi: costi, cliente: cliente, anno: anno, scorre: false)
                            cardDieciAnni(m, costi: costi, cliente: cliente, proposte: proposte, scelta: scelta, esito: esito,
                                          attuale: attuale)
                        }
                    }
                }
            }
            .padding(Tema.Apple.Posizioni.Disposizione.margine)
        }
    }

    // MARK: Vassoio e foglio

    @ViewBuilder private func vassoio(_ m: DocumentoSmontaggioMac?, costi: SmontaggioCosti) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: S.raggioVassoio, style: .continuous)
                .fill(S.fondoVassoio)
                .overlay(RoundedRectangle(cornerRadius: S.raggioVassoio, style: .continuous)
                    .stroke(sopraVassoio ? C.accento : .clear, lineWidth: 2))
            if smontaggio.inLettura, m?.conservato != true {
                Text("Leggo il documento sul Mac…")
                    .carattereApple(Tema.Apple.Carattere.corpoGrande)
                    .foregroundColor(C.inchiostro2)
            } else if let m {
                // Il foglio sta nella larghezza del vassoio: se serve si rimpicciolisce
                GeometryReader { g in
                    let scala = min(1, (g.size.width - 2 * S.sopraVassoio) / FoglioNumerato.larghezzaTotale)
                    ScrollView(.vertical, showsIndicators: false) {
                        FoglioNumerato(righe: m.righe, costi: costi, identita: m.identita, sopra: smontaggio.sopra,
                                       modificabile: !m.conservato, fumetto: $fumetto,
                                       togli: { smontaggio.esclusi.insert($0) },
                                       segna: { riga, tipo in smontaggio.tipiScelti[riga] = tipo; smontaggio.esclusi.remove(riga) })
                            .scaleEffect(scala, anchor: .top)
                            .padding(.top, S.sopraVassoio)
                            .frame(width: g.size.width)
                    }
                }
            } else {
                vuotoPortafoglio
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.fileURL], isTargeted: $sopraVassoio) { fornitori in leggi(fornitori) }
    }

    private func leggi(_ fornitori: [NSItemProvider]) -> Bool {
        guard let f = fornitori.first else { return false }
        _ = f.loadObject(ofClass: URL.self) { url, _ in
            guard let url else { return }
            DispatchQueue.main.async { stato.leggiFileSmontaggio(url) }
        }
        return true
    }

    /// Il vuoto di sempre («Tutti i clienti», nessun documento letto): inquadra, scegli un file o, con i dati di prova,
    /// l'esempio fac-simile.
    private var vuotoPortafoglio: some View {
        VStack(spacing: 16) {
            Text(TestiSmontaggio.vuoto)
                .carattereApple(Tema.Apple.Carattere.corpoGrande)
                .foregroundColor(C.inchiostro2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
            HStack(spacing: 10) {
                PulsanteInquadra()
                Button("Scegli un documento…") { scegliFile() }
                    .buttonStyle(.apple)
                if stato.haDatiDiProva {
                    Button("Apri l'esempio (fac-simile)") {
                        smontaggio.caricaEsempio(clienteId: clienteScelto ?? (stato.clienteAttivoId.isEmpty ? "giulia" : stato.clienteAttivoId))
                    }
                    .buttonStyle(.appleSobrio)
                }
            }
        }
        .padding(30)
    }

    private func scegliFile() {
        let p = NSOpenPanel()
        p.allowedContentTypes = [.pdf, .image]
        p.allowsMultipleSelection = false
        guard p.runModal() == .OK, let url = p.url else { return }
        stato.leggiFileSmontaggio(url)
    }

    /// Il cliente scelto non ha documenti smontati: avatar 58, la frase e i due pulsanti.
    private func vuotoCliente(_ c: Cliente) -> some View {
        VStack(spacing: 14) {
            AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: S.avatarVuoto)
            Text(TestiSmontaggio.vuotoCliente(nomeBreve(c)))
                .carattereApple(S.titoloVuoto)
                .foregroundColor(C.inchiostro)
                .multilineTextAlignment(.center)
            Text(TestiSmontaggio.fraseVuotoCliente)
                .carattereApple(Tema.Apple.Carattere.corpo)
                .foregroundColor(C.inchiostro2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: S.larghezzaVuoto)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button(TestiSmontaggio.inquadraUnDocumento) { stato.apriInquadraSmontaggio() }
                    .buttonStyle(StilePulsanteApple(.principale, grande: true))
                    .disabled(stato.inModoCliente)
                    .fixedSize()
                // In modalità cliente niente documenti degli altri clienti
                if !stato.inModoCliente {
                    Button(TestiSmontaggio.vediAltri) {
                        stato.scegliCliente(nil, avviso: true)
                        stato.apriSmontaggio()
                    }
                    .buttonStyle(StilePulsanteApple(.secondaria, grande: true))
                    .fixedSize()
                }
            }
            .padding(.top, 4)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onDrop(of: [.fileURL], isTargeted: $sopraVassoio) { fornitori in leggi(fornitori) }
        .entrataCascata(0, base: S.Moto.baseCascata)
    }

    // MARK: La card del documento

    private func cardDocumento(_ m: DocumentoSmontaggioMac?, costi: SmontaggioCosti, cliente: Cliente?, posizione: Posizione?,
                               scelta: Posizione?, esito: EsitoSostituzione?, elenco: [Documento]) -> some View {
        let oggi = costi.costoAnnuo
        let conTe = scelta.flatMap { p -> Double? in
            guard let v = costi.valore, let c = p.costoAnnuoPercento else { return nil }
            return v * c / 100
        }
        let titolo = (m?.titolo).flatMap { $0.isEmpty ? nil : $0 } ?? "—"
        let occhiello = m == nil ? "Nessun documento"
            : TestiSmontaggio.occhielloDocumento(nome: cliente.map { nomeBreve($0) }, valore: costi.valore)
        let voci = scelte(elenco)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                if let c = cliente {
                    AvatarCliente(iniziali: c.iniziali, tinta: c.tinta.colori, lato: S.avatarDocumento)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(occhiello)
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(C.inchiostro2)
                        .lineLimit(1)
                    Text(titolo)
                        .carattereApple(S.titoloDocumento)
                        .foregroundColor(C.inchiostro)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .help(m?.origine ?? "")
                Spacer(minLength: 0)
                if let p = posizione { EtichettaCanaleApple(canale: p.canale, compatta: true) }
                if voci.count > 1 || (m == nil && !voci.isEmpty) {
                    Menu {
                        ForEach(Array(voci.enumerated()), id: \.offset) { _, v in
                            Button(v.titolo) {
                                fumetto = nil
                                if let id = v.id {
                                    smontaggio.documentoScelto[chiaveScelta] = id
                                } else {
                                    smontaggio.documentoScelto[chiaveScelta] = nil
                                }
                            }
                        }
                    } label: {
                        Text(TestiSmontaggio.cambia + " ⌄")
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                    .help("Scegli un altro documento smontato")
                }
            }
            HStack(alignment: .bottom, spacing: 12) {
                cifra(TestiSmontaggio.costiOggi, oggi, colore: C.rosso, indice: 0)
                Image(systemName: "arrow.right")
                    .font(S.nomeVoce.font)
                    .foregroundColor(C.inchiostro3)
                    .padding(.bottom, 9)
                cifra(TestiSmontaggio.conLaProposta, conTe, colore: C.verde, indice: 1)
                Spacer(minLength: 8)
                dieciAnni(esito)
            }
            if m != nil, posizione == nil, m?.conservato != true {
                nota(TestiSmontaggio.provvisoria)
            }
            if m != nil, costi.vuoto {
                nota(TestiSmontaggio.nessunCosto)
            }
            if m?.conservato == true {
                nota(TestiSmontaggio.conservato)
            } else if let c = cliente, m != nil, !costi.vuoto {
                Button("Aggiungi al dossier di \(nomeBreve(c))…") { confermaDossier = true }
                    .buttonStyle(.appleSobrio)
                    .disabled(stato.solaLettura || stato.documentoSmontaggioPresente(costi))
                    .help(stato.documentoSmontaggioPresente(costi) ? "Il documento con queste voci è già nei Documenti del cliente"
                          : "Il documento entra nei Documenti del cliente con le voci di costo trovate, senza la foto")
                    .confirmationDialog("Aggiungere il documento al dossier di \(c.nome)?", isPresented: $confermaDossier,
                                        titleVisibility: .visible) {
                        Button("Aggiungi ai Documenti") { stato.aggiungiSmontaggioAlDossier(costi) }
                        Button("Annulla", role: .cancel) {}
                    } message: {
                        Text(TestiSmontaggio.confermaDossier(voci: costi.voci.count))
                    }
            }
        }
        .padding(S.paddingDocumento)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
    }

    private func nota(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(Tema.Apple.Carattere.secondario)
            .foregroundColor(C.inchiostro2)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private func cifra(_ titolo: String, _ v: Double?, colore: Color, indice: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titolo)
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(C.inchiostro2)
                .lineLimit(1)
            if let v {
                NumeroCheConta(v, indice: indice)
                    .carattereApple(S.cifraRiga)
                    .foregroundColor(colore)
                    .lineLimit(1)
            } else {
                Text("—").carattereApple(S.cifraRiga).foregroundColor(C.inchiostro3)
            }
        }
    }

    /// «In 10 anni» con il guadagno netto del confronto di oggi (penale, ingresso e tasse), verde o rosso.
    @ViewBuilder private func dieciAnni(_ esito: EsitoSostituzione?) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(TestiSmontaggio.inAnni(esito?.anni ?? IpotesiCalcolo.orizzontePredefinito))
                .carattereApple(Tema.Apple.Carattere.secondario)
                .foregroundColor(C.inchiostro2)
                .lineLimit(1)
            if let d = esito?.finale?.differenza {
                NumeroCheConta(d, formato: .personalizzato({ v in (v >= 0 ? "+" : "") + FormatoCifra.euro.testo(v) }), indice: 2)
                    .carattereApple(S.cifraRiga)
                    .foregroundColor(d >= 0 ? C.verde : C.rosso)
                    .lineLimit(1)
            } else {
                Text("—").carattereApple(S.cifraRiga).foregroundColor(C.inchiostro3)
            }
        }
    }

    // MARK: Le voci cerchiate

    @ViewBuilder private func cardVoci(_ m: DocumentoSmontaggioMac?, costi: SmontaggioCosti, cliente: Cliente?, anno: Int?,
                                       scorre: Bool) -> some View {
        let righe = VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(costi.voci.enumerated()), id: \.element.riga) { k, v in
                RigaVoceSmontaggio(numero: k + 1, voce: v, cifra: TestiSmontaggio.cifraVoce(v, anno: anno),
                                   dettaglio: TestiSmontaggio.dettaglioVoce(v, in: costi, nomeCliente: nomeBreve(cliente)),
                                   sopra: smontaggio.sopra, modificabile: m?.conservato == false,
                                   togli: { smontaggio.esclusi.insert(v.riga) })
            }
        }
        .id(m?.identita ?? "nessuno")
        VStack(alignment: .leading, spacing: 10) {
            Text(TestiSmontaggio.titoloVoci)
                .carattereApple(Tema.Apple.Carattere.etichetta)
                .foregroundColor(C.inchiostro2)
            if costi.voci.isEmpty {
                Text(m == nil ? "Scegli prima un documento." : TestiSmontaggio.nessunCosto)
                    .carattereApple(Tema.Apple.Carattere.corpo)
                    .foregroundColor(C.inchiostro2)
                    .fixedSize(horizontal: false, vertical: true)
            } else if scorre {
                ScrollView(.vertical, showsIndicators: false) { righe }
            } else {
                righe
            }
        }
        .padding(S.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
    }

    // MARK: In dieci anni

    private func cardDieciAnni(_ m: DocumentoSmontaggioMac?, costi: SmontaggioCosti, cliente: Cliente?, proposte: [Posizione],
                               scelta: Posizione?, esito: EsitoSostituzione?, attuale: Posizione?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("In \(IpotesiCalcolo.orizzontePredefinito) anni, con le ipotesi di Lucy")
                    .carattereApple(Tema.Apple.Carattere.etichetta)
                    .foregroundColor(C.inchiostro2)
                Spacer(minLength: 8)
                if let p = scelta { EtichettaCanaleApple(canale: p.canale, compatta: true) }
            }
            Menu {
                if proposte.isEmpty { Text("Il cliente non ha proposte: creane una in Posizioni") }
                ForEach(proposte) { p in
                    Button(p.nome + (p.costoAnnuoPercento.map { " · costi \(TestiSmontaggio.percento($0))" } ?? "")) {
                        smontaggio.propostaId = p.id
                    }
                }
            } label: {
                Text(scelta.map { "Confronta con: \($0.nome)" } ?? TestiSmontaggio.scegliProposta)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .disabled(m == nil)
            if let e = esito, e.finale != nil {
                HStack(alignment: .top, spacing: 14) {
                    GraficoDieciAnni(serie: e.serie)
                        .frame(width: S.graficoPiccolo.width, height: S.graficoPiccolo.height)
                    Text("Per \(nomeBreve(cliente)), netto, rispetto a restare. "
                         + TestiSmontaggio.didascalia(rendimento: e.resto.rendimento, anni: e.anni))
                        .carattereApple(Tema.Apple.Carattere.secondario)
                        .foregroundColor(C.inchiostro2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
            } else {
                Text(m == nil ? "Scegli prima un documento." : TestiSmontaggio.scegliProposta + ": il confronto usa penale, costi d'ingresso e tasse.")
                    .carattereApple(Tema.Apple.Carattere.corpo)
                    .foregroundColor(C.inchiostro2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) { pulsanti(m, scelta: scelta, attuale: attuale, costi: costi) }
                VStack(alignment: .leading, spacing: 10) { pulsanti(m, scelta: scelta, attuale: attuale, costi: costi) }
            }
            .padding(.top, 4)
        }
        .padding(S.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.cardPiatta)
    }

    @ViewBuilder private func pulsanti(_ m: DocumentoSmontaggioMac?, scelta: Posizione?, attuale: Posizione?,
                                       costi: SmontaggioCosti) -> some View {
        Button("Crea la proposta di sostituzione") {
            guard let m, let p = scelta, let a = attuale else { return }
            stato.proponiSostituzioneDaSmontaggio(attuale: a, registrata: m.posizioneId != nil, proposta: p, costi: costi,
                                                 titolo: m.titolo)
        }
        .buttonStyle(StilePulsanteApple(.principale, grande: true))
        .disabled(m == nil || scelta == nil || attuale == nil || stato.solaLettura)
        .fixedSize()
        // La scena di Inquadra per lo Smontaggio offre già l'iPhone, il trascinamento e «Scegli un file…»
        Button(TestiSmontaggio.smontaUnAltro) { stato.apriInquadraSmontaggio() }
            .buttonStyle(StilePulsanteApple(.secondaria, grande: true))
            .disabled(stato.inModoCliente)
            .fixedSize()
    }
}

// MARK: - Il foglio con i numeri

/// Il foglio ricostruito dalle righe, con le ellissi rosse disegnate a mano sui valori delle voci di costo e, accanto a
/// ogni ellisse, il cerchio pieno con il numero della voce. Niente note ai margini (migliorie d'uso 42).
private struct FoglioNumerato: View {
    let righe: [RigaLetta]
    let costi: SmontaggioCosti
    let identita: String
    let sopra: SopraSmontaggio
    /// false per un documento già nel dossier: niente «Non è un costo» né «Segna come costo».
    let modificabile: Bool
    @Binding var fumetto: Int?
    let togli: (Int) -> Void
    let segna: (Int, TipoCosto) -> Void
    /// Nelle istantanee i popover di sistema non si vedono: il fumetto si disegna sotto il valore.
    @Environment(\.modoIstantanea) private var istantanea

    private typealias S = Tema.Apple.Posizioni.Smontaggio
    private typealias P = Tema.Apple.Carta

    /// Il foglio scalato: i numeri stanno dentro il margine destro della carta.
    static var larghezzaTotale: CGFloat {
        let s = Tema.Apple.Posizioni.Smontaggio.self
        return s.larghezzaFoglio * s.scalaFoglio
    }

    var body: some View {
        let voci = Dictionary(costi.voci.map { ($0.riga, $0) }, uniquingKeysWith: { a, _ in a })
        let ordine = costi.voci.map(\.riga)
        return VStack(alignment: .leading, spacing: 0) {
            testata
            Rectangle().fill(P.testo).frame(height: S.filoTabella).padding(.top, S.sopraTabella)
            ForEach(Array(righe.enumerated()).filter { $0.offset >= inizioTabella }, id: \.offset) { i, r in
                rigaFoglio(i, r, voce: voci[i], ordine: ordine.firstIndex(of: i))
            }
            VStack(alignment: .leading, spacing: 10) {
                ForEach(0..<S.righeFinte, id: \.self) { k in
                    RoundedRectangle(cornerRadius: 3).fill(S.rigaFinta)
                        .frame(width: S.larghezzaFoglio * (k % 2 == 0 ? 0.62 : 0.48), height: S.altezzaRigaFinta)
                }
            }
            .padding(.top, 22)
        }
        .padding(S.paddingFoglio)
        .frame(width: S.larghezzaFoglio, alignment: .leading)
        .superficieApple(Tema.Apple.Superficie.carta)
        .environment(\.colorScheme, .light)
        .scaleEffect(S.scalaFoglio, anchor: .top)
        .frame(width: S.larghezzaFoglio * S.scalaFoglio)
        .id(identita)
    }

    /// Le prime righe che non sono costi e vengono prima del primo costo: occhiello, titolo, sottotitolo, valore.
    private var inizioTabella: Int {
        let primo = costi.voci.map(\.riga).min() ?? righe.count
        return min(primo, min(4, righe.count))
    }

    @ViewBuilder private var testata: some View {
        let testa = Array(righe.prefix(inizioTabella).enumerated())
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(testa.filter { !$0.element.testo.lowercased().contains("valore") }, id: \.offset) { k, r in
                    Text(r.testo)
                        .carattereApple(k == 0 ? S.occhiello : (k == 1 ? S.titolo : S.sottotitolo))
                        .foregroundColor(k == 0 ? S.coloreOcchiello : (k == 1 ? P.testo : P.sottotitolo))
                }
            }
            Spacer(minLength: 16)
            if let v = costi.valore {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Valore").carattereApple(S.etichettaValore).foregroundColor(P.piede)
                    Text(Formati.euro(v)).carattereApple(S.valoreFoglio).foregroundColor(P.testo)
                }
            }
        }
    }

    @ViewBuilder private func rigaFoglio(_ i: Int, _ r: RigaLetta, voce: VoceCostoTrovata?, ordine: Int?) -> some View {
        HStack(alignment: .center) {
            Text(voce?.etichetta ?? r.testo)
                .carattereApple(S.riga)
                .foregroundColor(P.testoCorrente)
            Spacer(minLength: 12)
            if let v = voce {
                let n = ordine ?? 0
                Text(v.valoreScritto)
                    .carattereApple(S.valoreRiga)
                    .foregroundColor(P.testo)
                    .overlay {
                        EllisseVoce(riga: i, indice: n, tratteggiata: v.fonte == .mancante, sopra: sopra)
                            .padding(.horizontal, -S.margineCerchio)
                            .frame(height: S.altezzaCerchio)
                    }
                    .overlay(alignment: .trailing) {
                        NumeroVoceSmontaggio(numero: n + 1, lato: 2 * S.raggioNumeroFoglio, carattere: S.numeroFoglio)
                            .modifier(AccensioneVoce(indice: n, spenta: 0))
                            .fixedSize()
                            .offset(x: S.margineCerchio + S.spazioNumero + 2 * S.raggioNumeroFoglio)
                            .allowsHitTesting(false)
                    }
                    .contentShape(Rectangle())
                    .onHover { dentro in
                        if dentro { sopra.riga = i } else if sopra.riga == i { sopra.riga = nil }
                    }
                    .onTapGesture { fumetto = fumetto == i ? nil : i }
                    .popover(isPresented: Binding(get: { fumetto == i && !istantanea }, set: { if !$0 { fumetto = nil } })) {
                        FumettoCosto(voce: v, togli: { fumetto = nil; togli(i) }, togliAttivo: modificabile)
                    }
                    .overlay(alignment: .topTrailing) {
                        if istantanea, fumetto == i {
                            FumettoCosto(voce: v, togli: {}, togliAttivo: modificabile)
                                .superficieApple(Tema.Apple.Superficie.dettaglio, raggio: Tema.Apple.Raggio.voce)
                                .fixedSize()
                                .offset(y: S.altezzaCerchio)
                                .zIndex(10)
                        }
                    }
            }
        }
        .padding(S.paddingRiga)
        .overlay(alignment: .bottom) { Rectangle().fill(P.filetto).frame(height: 1) }
        .contentShape(Rectangle())
        .contextMenu {
            if modificabile {
                if voce == nil {
                    Text("Segna come costo")
                    ForEach(TipoCosto.allCases) { t in Button(t.nome) { segna(i, t) } }
                } else {
                    Button("Non è un costo") { togli(i) }
                }
            }
        }
    }
}

/// L'ellisse rossa disegnata a mano (come `CerchioAMano`): si traccia una alla volta, tratteggiata quando la cifra in
/// euro manca; accesa (puntatore sulla sua riga o su di lei) ha il tratto 3,6 e il fondo rosso tenue.
private struct EllisseVoce: View {
    let riga: Int
    let indice: Int
    let tratteggiata: Bool
    let sopra: SopraSmontaggio
    @State private var disegno: CGFloat = 0
    @Environment(\.prismaStatoFinale) private var fermo
    private typealias S = Tema.Apple.Posizioni.Smontaggio

    var body: some View {
        let accesa = sopra.riga == riga
        ZStack {
            Ellipse().fill(accesa ? S.fondoEllisseAccesa : Color.clear)
            Ellipse()
                .trim(from: 0, to: fermo ? 1 : disegno)
                .stroke(S.coloreCerchio, style: StrokeStyle(lineWidth: accesa ? S.tratteggioAcceso : S.spessoreCerchio,
                                                            lineCap: .round, dash: tratteggiata ? S.tratteggioMancante : []))
        }
        .rotationEffect(.degrees(S.rotazioneCerchio))
        .allowsHitTesting(false)
        .onAppear {
            guard !fermo else { return }
            withAnimation(S.Moto.animazione.ritardoPrisma(S.Moto.partenza(indice))) { disegno = 1 }
        }
    }
}

/// Il cerchio rosso pieno con il numero della voce (sul foglio raggio 11, nell'elenco 22).
private struct NumeroVoceSmontaggio: View {
    let numero: Int
    let lato: CGFloat
    let carattere: Tema.Apple.Carattere
    private typealias S = Tema.Apple.Posizioni.Smontaggio

    var body: some View {
        Text("\(numero)")
            .carattereApple(carattere)
            .foregroundColor(S.testoNumero)
            .frame(width: lato, height: lato)
            .background(Circle().fill(S.coloreNumero))
            .accessibilityLabel("Voce \(numero)")
    }
}

/// La voce si accende quando la sua ellisse comincia a disegnarsi: da `spenta` a 1 in 0,5 s. «Riduci movimento» e
/// istantanee: accesa subito.
private struct AccensioneVoce: ViewModifier {
    let indice: Int
    let spenta: Double
    @State private var accesa = false
    @Environment(\.prismaStatoFinale) private var fermo
    private typealias M = Tema.Apple.Posizioni.Smontaggio.Moto

    func body(content: Content) -> some View {
        content
            .opacity(fermo || accesa ? 1 : spenta)
            .onAppear {
                guard !fermo else { return }
                withAnimation(Tema.Apple.Moto.Curva.uscita.animazione(M.durataAccensione).ritardoPrisma(M.partenza(indice))) {
                    accesa = true
                }
            }
    }
}

/// Una riga dell'elenco «Le voci cerchiate»: il numero, il nome, la cifra in euro e, sotto in grigio, il valore scritto
/// con la spiegazione di Prisma. Il puntatore sulla riga accende la sua ellisse sul foglio.
private struct RigaVoceSmontaggio: View {
    let numero: Int
    let voce: VoceCostoTrovata
    let cifra: String
    let dettaglio: String
    let sopra: SopraSmontaggio
    let modificabile: Bool
    let togli: () -> Void
    private typealias S = Tema.Apple.Posizioni.Smontaggio
    private typealias C = Tema.Apple.Colore

    var body: some View {
        let accesa = sopra.riga == voce.riga
        HStack(alignment: .top, spacing: S.spazioVoce) {
            NumeroVoceSmontaggio(numero: numero, lato: S.numeroElenco, carattere: S.carattereNumeroElenco)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(voce.etichetta)
                        .carattereApple(S.nomeVoce)
                        .foregroundColor(C.inchiostro)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(cifra)
                        .carattereApple(S.cifraVoce)
                        .foregroundColor(voce.euro == nil ? C.inchiostro3 : C.rosso)
                        .lineLimit(1)
                }
                if !dettaglio.isEmpty {
                    Text(dettaglio)
                        .carattereApple(S.dettaglioVoce)
                        .foregroundColor(C.inchiostro2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(S.paddingVoce)
        .background(RoundedRectangle(cornerRadius: S.raggioVoce, style: .continuous)
            .fill(accesa ? S.fondoVoceAccesa : Color.clear))
        .contentShape(Rectangle())
        .onHover { dentro in
            if dentro { sopra.riga = voce.riga } else if sopra.riga == voce.riga { sopra.riga = nil }
        }
        .contextMenu {
            if modificabile { Button("Non è un costo", action: togli) }
        }
        .modifier(AccensioneVoce(indice: numero - 1, spenta: S.opacitaSpenta))
        .accessibilityElement(children: .combine)
    }
}
#endif
