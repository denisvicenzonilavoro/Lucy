#if os(macOS)
import Foundation

// Migliorie d'uso 3 «Un solo Da fare al posto di notifiche, scadenze e promemoria» (Design/uso/gruppo-01.md §3), solo sul
// Mac. Una fonte sola: il nastro di MotoreDaFare (StatoPortafoglioApple.swift), che sul Mac comprende anche le scadenze
// delle posizioni, i compleanni e le attività scritte senza cliente. La barra (pillola «Da fare» con il numero), il
// pannello (PannelloDaFare.swift), la scrivania e le schede di Posizioni leggono da lì. Qui:
// - il numero della barra (= il totale del nastro, anche le voci oltre le otto per gruppo delle schede di Posizioni);
// - il nastro intero per il pannello («Tutti» o «Solo <Nome>»), in cache come ogni dato ricavato;
// - «Segna come fatto» con la traccia per «Annulla l’ultima» (in memoria): attività → di nuovo aperta; segno «fatto» →
//   tolto; riesame → l'incontro creato tolto e le fotografie del riesame rimesse come prima; rinnovo di conformità →
//   le date di prima. L'esito di una proposta e il documento d'identità passano da un modulo e non si annullano da qui;
// - «+ Aggiungi»: un'attività di oggi del cliente della barra (o «Per te» con «Tutti i clienti»);
// - gli arrivi e gli avvisi che non sono voci da spuntare (carta e note dall'iPhone, carte della notte, capsule, appuntamenti
//   di oggi, cose da sistemare…): restano le notifiche di sempre, in testa al pannello.
// Nessun campo nuovo nell'archivio: si scrive con i meccanismi di sempre.

/// I testi del «Da fare» unico.
enum TestiDaFare {
    static let titolo = "Da fare"
    static let inOrdine = "in ordine di tempo"
    static let tutti = "Tutti"
    static let tuttoFatto = "Tutto fatto."
    static let aggiungi = "Aggiungi"
    static let segnaFatto = "Segna come fatto"
    static let chiudi = "Chiudi"
    static let annullaUltima = "Annulla l’ultima"
    static let apriTutto = "Apri tutto ›"
    static let arrivati = "Arrivati e avvisi"
    static let scrittaDaTe = "scritta da te"
    static let perTe = "Per te"
    static let niente = "Nient’altro da fare."
    static let dopoMossa = "dopo la mossa del giorno"
    /// «✓ Fatto» nella mossa del giorno della scrivania (proposta di 3.6).
    static let fattoMossa = "Fatto"
    static let aiutoPillola = "Da fare: le cose aperte con i clienti, in ordine di tempo"
    static let aiutoCerchio = "Segna come fatto"
    static let massimoCaratteri = Tema.Apple.ElencoDaFare.caratteriCampo

    static func solo(_ nome: String) -> String { "Solo \(nome)" }
    static func segnaposto(_ nome: String?) -> String {
        nome.map { "Da fare per \($0)…" } ?? "Scrivi una cosa da fare…"
    }
    static func fatteOggi(_ n: Int) -> String { "Fatte oggi: \(n) · " }
    static func altre(_ n: Int) -> String { "altre \(n) · " }
    /// In fondo a un gruppo del pannello tagliato a `righePerGruppo` righe.
    static func eAltre(_ n: Int) -> String { "e altre \(n)" }
    static let mostraTutte = "Mostra tutte"

    /// «Giulia Rossi: fatto. La voce sparisce da tutta Prisma» (per una voce «Per te» senza il nome).
    static func fatto(_ v: VoceDaFare) -> String {
        v.cliente.id.isEmpty ? "Fatto. La voce sparisce da tutta Lucy" : "\(v.cliente.nome): fatto. La voce sparisce da tutta Lucy"
    }

    static func diNuovo(_ v: VoceDaFare) -> String {
        v.cliente.id.isEmpty ? "Di nuovo da fare" : "\(v.cliente.nome): di nuovo da fare"
    }

    static func aggiunta(_ nome: String?) -> String {
        nome.map { "Aggiunta al «Da fare» di \($0)" } ?? "Aggiunta al «Da fare»"
    }

    /// «Giulia Rossi · Oggi» (senza il nome quando l'elenco è già di un cliente; «Per te» per le voci senza cliente).
    static func sotto(_ v: VoceDaFare, conNome: Bool) -> String {
        guard conNome else { return v.quando }
        return "\(v.cliente.nome) · \(v.quando)"
    }

    /// Il «cliente» delle attività scritte senza cliente: id vuoto, «Per te», con le iniziali dell'utente.
    static func clientePerTe(iniziali: String) -> Cliente {
        Cliente(id: "", nome: perTe, iniziali: iniziali, tinta: .blu, tema: "", email: "", telefono: "", preferito: false,
                nota: "", creatoIl: Date(timeIntervalSinceReferenceDate: 0))
    }

    /// Le notifiche che il nastro ha già (attività, proposte ferme, scadenze, compleanni, occasioni, conformità): nel
    /// pannello non si ripetono fra gli arrivi.
    static let prefissiNelNastro = ["attivita-", "seguito-", "scadenza-", "scaduta-", "compleanno-", "occasione-",
                                    "occasioni-", "conformita-"]
}

/// Una cosa segnata come fatta dal «Da fare», con ciò che serve per rimetterla da fare.
struct FattoDaFare {
    enum Annulla {
        /// L'attività torna aperta.
        case attivita(id: String)
        /// Si toglie l'attività completata che teneva il segno «fatto».
        case segno(id: String)
        /// Si toglie l'incontro di riesame creato e le fotografie del riesame tornano quelle di prima.
        case riesame(incontroId: String?, fotografie: [FotografiaRiesame])
        /// La conformità e i consensi del cliente tornano quelli di prima.
        case conformita(clienteId: String, conformita: ConformitaCliente?, consensi: Consensi)
    }

    let voce: VoceDaFare
    let annulla: Annulla
    let quando: Date
}

extension StatoShell {
    // MARK: - Le voci

    /// Il numero della pillola della barra: tutte le voci aperte del nastro (in cache, non si rifà a ogni disegno).
    var numeroDaFare: Int { nastroDaFare().totale }

    /// Il cliente del segmentato «Solo <Nome>» (nil con «Tutti i clienti» o con il segmentato su «Tutti»).
    var clienteSoloDaFare: Cliente? {
        guard daFareSoloCliente, !tuttiIClienti else { return nil }
        return cliente(clienteAttivoId)
    }

    /// Il nastro intero (senza il taglio delle schede di Posizioni) di tutti o di un cliente, in cache per ora.
    func nastroDaFareCompleto(cliente id: String?) -> NastroDaFare {
        ricavato("da-fare-completo-\(DerivatiDati.ora())-\(id ?? "*")") {
            let voci = vociDaFareTutte().voci
            let scelte = id.map { c in voci.filter { $0.cliente.id == c } } ?? voci
            return MotoreDaFare.nastro(scelte, massimo: .max)
        }
    }

    /// Le notifiche che non sono voci da spuntare (arrivi e avvisi): in testa al pannello «Da fare».
    var arriviDaFare: [Notifica] {
        notifiche.filter { n in !TestiDaFare.prefissiNelNastro.contains { n.id.hasPrefix($0) } }
    }

    /// Le cose segnate come fatte oggi dal «Da fare».
    var fatteDaFareOggi: [FattoDaFare] {
        fatteDaFare.filter { Calendar.current.isDateInToday($0.quando) }
    }

    // MARK: - Il pannello

    /// Apre il pannello «Da fare»: dalla pillola e da «Apri tutto ›» della scrivania su «Tutti», dal dossier e da
    /// Posizioni già su «Solo <Nome>».
    func apriDaFare(soloCliente: Bool = false) {
        daFareSoloCliente = soloCliente && !tuttiIClienti
        daFareScrivo = false
        if !pannelloNotifiche { alternaNotifiche() }
    }

    // MARK: - La mossa del giorno come prima voce (proposta di 3.6)

    /// La voce del nastro che è la mossa del giorno: sulla scrivania la mossa è la prima cosa da fare, il riquadro «Da
    /// fare» parte dalla seconda («dopo la mossa del giorno») e «✓ Fatto» sta nella mossa. nil se la mossa non ha una
    /// voce nel nastro (per esempio i dati incompleti) o se non c'è una mossa.
    func voceDellaMossa(in voci: [VoceDaFare]) -> VoceDaFare? {
        guard let m = mossaDelGiorno().mossa else { return nil }
        return Self.voceDellaMossa(m, in: voci)
    }

    /// Il motivo principale della mossa nel nastro: la stessa posizione del cliente, altrimenti lo stesso tipo di voce.
    static func voceDellaMossa(_ m: MossaDelGiorno, in voci: [VoceDaFare]) -> VoceDaFare? {
        guard let principale = m.segnali.first else { return nil }
        let delCliente = voci.filter { $0.cliente.id == m.cliente.id }
        if let p = principale.posizione, let v = delCliente.first(where: { $0.posizioneId == p.id }) { return v }
        let tipo: VoceDaFare.Tipo?
        switch principale.tipo {
        case .propostaFerma: tipo = .proposta
        case .riesame: tipo = .riesame
        case .scadenza: tipo = .scadenza
        case .occasione: tipo = .occasione
        case .datiIncompleti: tipo = nil
        }
        guard let tipo else { return nil }
        return delCliente.first { $0.tipo == tipo }
    }

    // MARK: - Segna come fatto e Annulla l'ultima

    /// «Segna come fatto» fuori dalle schede di Posizioni: scrive come `segnaFatto` e tiene la traccia per «Annulla
    /// l’ultima». L'esito di una proposta e «In regola» aprono il loro modulo (il pannello si chiude).
    func fattoDaFare(_ v: VoceDaFare) {
        guard !solaLettura else {
            mostraAvviso(TestiPortafoglioApple.solaLettura)
            return
        }
        let annulla: FattoDaFare.Annulla
        switch v.fatto {
        case .esitoProposta(let pid):
            guard let p = posizioni.first(where: { $0.id == pid }) else { return }
            chiudiVoceDaFare()
            if pannelloNotifiche { pannelloNotifiche = false }
            apriEsito(p, passo: .scelta, origine: .posizioni)
            return
        case .apriInRegola:
            chiudiVoceDaFare()
            if pannelloNotifiche { pannelloNotifiche = false }
            apriInRegola(v.cliente.id)
            return
        case .attivita(let id):
            guard dati.attivita.contains(where: { $0.id == id && !$0.completata }) else { return }
            annulla = .attivita(id: id)
            segnaFatto(v)
        case .segna:
            guard !dati.attivita.contains(where: { $0.id == v.idSegno }) else { return }
            annulla = .segno(id: v.idSegno)
            segnaFatto(v)
        case .riesame:
            let fotografie = dati.fotografie
            let incontriPrima = Set(dati.incontri.map(\.id))
            segnaFatto(v)
            let nuovo = dati.incontri.first { !incontriPrima.contains($0.id) }?.id
            annulla = .riesame(incontroId: nuovo, fotografie: fotografie)
        case .rinnova:
            guard let c = dati.clienti.first(where: { $0.id == v.cliente.id }) else { return }
            annulla = .conformita(clienteId: c.id, conformita: c.conformita, consensi: c.consensi)
            segnaFatto(v)
        }
        fatteDaFare.append(FattoDaFare(voce: v, annulla: annulla, quando: Date()))
        if voceDaFareAperta?.id == v.id { chiudiVoceDaFare() }
        mostraAvviso(TestiDaFare.fatto(v))
    }

    /// Rifinitura 50: la voce del nastro di un'attività aperta (nil se è completata, se è la ripresa di una proposta,
    /// già sul nastro con la proposta, o se il suo cliente non c'è più).
    func voceDaFare(attivitaId id: String) -> VoceDaFare? {
        vociDaFareTutte().voci.first { $0.fatto == .attivita(id: id) }
    }

    /// Rifinitura 50: la spunta delle attività nella colonna dell'Agenda. Un'attività aperta che è una voce del nastro si
    /// segna con «Segna come fatto» del «Da fare» unico (vale in tutta Prisma e si annulla dal pannello con «Annulla
    /// l’ultima»); le altre, e una già fatta da riaprire, si alternano come prima.
    func spuntaAttivitaAgenda(_ id: String) {
        if let a = dati.attivita.first(where: { $0.id == id }), !a.completata, let v = voceDaFare(attivitaId: id) {
            fattoDaFare(v)
        } else {
            alternaCompletata(id)
        }
    }

    /// «Annulla l’ultima»: rimette da fare l'ultima cosa segnata dal «Da fare».
    func annullaUltimoFattoDaFare() {
        guard !solaLettura else {
            mostraAvviso(TestiPortafoglioApple.solaLettura)
            return
        }
        guard let u = fatteDaFare.popLast() else { return }
        switch u.annulla {
        case .attivita(let id):
            if let i = dati.attivita.firstIndex(where: { $0.id == id }), dati.attivita[i].completata {
                dati.attivita[i].completata = false
            }
        case .segno(let id):
            if dati.attivita.contains(where: { $0.id == id }) { dati.attivita.removeAll { $0.id == id } }
        case .riesame(let incontroId, let prima):
            if let incontroId { eliminaIncontro(incontroId) }
            // Via le fotografie nate dopo, di nuovo quelle sostituite (le altre restano dove sono)
            let idPrima = Set(prima.map(\.id))
            var elenco = dati.fotografie.filter { idPrima.contains($0.id) }
            let rimaste = Set(elenco.map(\.id))
            elenco += prima.filter { !rimaste.contains($0.id) }
            if elenco.map(\.id) != dati.fotografie.map(\.id) { dati.fotografie = elenco }
        case .conformita(let clienteId, let conformita, let consensi):
            if let i = dati.clienti.firstIndex(where: { $0.id == clienteId }) {
                var c = dati.clienti[i]
                c.conformita = conformita
                c.consensi = consensi
                if c != dati.clienti[i] { dati.clienti[i] = c }
            }
        }
        mostraAvviso(TestiDaFare.diNuovo(u.voce))
    }

    // MARK: - Aggiungi

    /// «+ Aggiungi»: un'attività di oggi (al più 70 caratteri) del cliente della barra, o «Per te» con «Tutti i clienti».
    func aggiungiDaFare(_ testo: String) {
        let titolo = String(testo.trimmingCharacters(in: .whitespacesAndNewlines).prefix(TestiDaFare.massimoCaratteri))
        daFareScrivo = false
        guard !titolo.isEmpty else { return }
        guard !solaLettura else {
            mostraAvviso(TestiPortafoglioApple.solaLettura)
            return
        }
        let c = tuttiIClienti ? nil : cliente(clienteAttivoId)
        var a = Attivita.nuova(clienteId: c?.id ?? "")
        a.titolo = titolo
        salvaAttivita(a)
        mostraAvviso(TestiDaFare.aggiunta(c?.nome))
    }

    // MARK: - Il dettaglio fuori da Posizioni

    /// Apre al centro il dettaglio di una voce (dal pannello, dalla scrivania): lo stesso contenuto delle schede di
    /// Posizioni; per le voci scritte a mano (le attività) la scheda semplice.
    func apriVoceDaFare(_ v: VoceDaFare) {
        if pannelloNotifiche { pannelloNotifiche = false }
        voceDaFareAperta = v
    }

    func chiudiVoceDaFare() {
        if voceDaFareAperta != nil { voceDaFareAperta = nil }
    }
}

/// Migliorie d'uso 3 (in `--prova-vera`, solo sul Mac): il numero della barra è il totale del nastro, «Segna come fatto»
/// toglie la voce da tutta Prisma e «Annulla l’ultima» la rimette, per attività, segni, riesami e conformità; «+ Aggiungi»
/// crea un'attività di oggi del cliente della barra o «Per te».
enum ProvaDaFareShell {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        let s = StatoShell(persistente: false)
        let oggi = Calendar.current.startOfDay(for: Date())
        let primoCliente = s.clienti.first?.id ?? ""
        s.scegliCliente(nil)
        // Un'attività aperta di oggi: entra nel nastro e nel numero
        let prima = s.numeroDaFare
        s.salvaAttivita(Attivita(id: "prova-da-fare", clienteId: primoCliente, titolo: "Chiamare per il KID", scadenza: oggi,
                                 priorita: .normale, completata: false))
        controlla(s.numeroDaFare == prima + 1, "Da fare: l'attività nuova conta nel numero della barra (\(prima) → \(s.numeroDaFare))")
        let intero = s.nastroDaFareCompleto(cliente: nil)
        controlla(intero.totale == s.numeroDaFare && intero.voci.count == intero.totale,
                  "Da fare: il pannello mostra tutte le voci del numero")
        guard let voce = intero.voci.first(where: { $0.id == "attivita-prova-da-fare" }) else {
            controlla(false, "Da fare: l'attività è fra le voci")
            return
        }
        s.fattoDaFare(voce)
        controlla(s.dati.attivita.first { $0.id == "prova-da-fare" }?.completata == true && s.numeroDaFare == prima,
                  "Da fare: «Segna come fatto» chiude l'attività e la toglie dal numero")
        controlla(s.fatteDaFareOggi.count == 1, "Da fare: «Fatte oggi» conta la voce")
        s.annullaUltimoFattoDaFare()
        controlla(s.dati.attivita.first { $0.id == "prova-da-fare" }?.completata == false && s.numeroDaFare == prima + 1
                  && s.fatteDaFare.isEmpty, "Da fare: «Annulla l’ultima» rimette l'attività da fare")

        // Il segno «fatto» (occasioni, attenzioni, scadenze, compleanni): si toglie con «Annulla l’ultima»
        let attivitaPrima = s.dati.attivita.count
        if let segnabile = s.nastroDaFareCompleto(cliente: nil).voci.first(where: { $0.fatto == .segna }) {
            s.fattoDaFare(segnabile)
            controlla(s.dati.attivita.contains { $0.id == segnabile.idSegno }
                      && !s.nastroDaFareCompleto(cliente: nil).voci.contains { $0.id == segnabile.id },
                      "Da fare: il segno «fatto» toglie la voce dal nastro")
            s.annullaUltimoFattoDaFare()
            controlla(s.dati.attivita.count == attivitaPrima && s.nastroDaFareCompleto(cliente: nil).voci.contains { $0.id == segnabile.id },
                      "Da fare: «Annulla l’ultima» toglie il segno e la voce torna")
        }

        // Il riesame: l'incontro creato si toglie e le fotografie tornano quelle di prima
        if let riesame = s.nastroDaFareCompleto(cliente: nil).voci.first(where: { $0.fatto == .riesame }) {
            let incontri = s.dati.incontri.count
            let fotografie = s.dati.fotografie.map(\.id)
            s.fattoDaFare(riesame)
            controlla(s.dati.incontri.count == incontri + 1, "Da fare: il riesame fatto registra l'incontro")
            s.annullaUltimoFattoDaFare()
            controlla(s.dati.incontri.count == incontri && Set(s.dati.fotografie.map(\.id)) == Set(fotografie),
                      "Da fare: «Annulla l’ultima» toglie l'incontro di riesame e le sue fotografie")
        }

        // Il rinnovo di conformità: tornano le date di prima
        if let rinnovo = s.nastroDaFareCompleto(cliente: nil).voci.first(where: { if case .rinnova = $0.fatto { return true } else { return false } }),
           let cliente = s.dati.clienti.first(where: { $0.id == rinnovo.cliente.id }) {
            s.fattoDaFare(rinnovo)
            s.annullaUltimoFattoDaFare()
            let dopo = s.dati.clienti.first { $0.id == cliente.id }
            controlla(dopo?.conformita == cliente.conformita && dopo?.consensi == cliente.consensi,
                      "Da fare: «Annulla l’ultima» rimette la conformità di prima")
        }

        // Rifinitura 50: le attività dell'Agenda sono le voci del nastro; la spunta dell'Agenda si annulla dal pannello
        s.salvaAttivita(Attivita(id: "prova-agenda", clienteId: primoCliente, titolo: "Mandare il KID", scadenza: oggi,
                                 priorita: .normale, completata: false))
        let aperte = Set(s.dati.attivita.filter { !$0.completata }.map(\.id))
        let vociAttivita = s.vociDaFareTutte().voci.compactMap { v -> String? in
            if case .attivita(let id) = v.fatto { return id } else { return nil }
        }
        controlla(vociAttivita.contains("prova-agenda") && vociAttivita.allSatisfy { aperte.contains($0) },
                  "Da fare: le voci delle attività sono le attività aperte dell'Agenda")
        s.fatteDaFare.removeAll()
        s.spuntaAttivitaAgenda("prova-agenda")
        controlla(s.dati.attivita.first { $0.id == "prova-agenda" }?.completata == true && s.fatteDaFare.count == 1
                  && s.voceDaFare(attivitaId: "prova-agenda") == nil,
                  "Da fare: la spunta dell'Agenda segna la voce come fatta in tutta Lucy")
        s.annullaUltimoFattoDaFare()
        controlla(s.dati.attivita.first { $0.id == "prova-agenda" }?.completata == false
                  && s.voceDaFare(attivitaId: "prova-agenda") != nil,
                  "Da fare: «Annulla l’ultima» riapre l'attività spuntata nell'Agenda")
        s.eliminaAttivita("prova-agenda")

        // «+ Aggiungi»: con «Tutti i clienti» è «Per te», con un cliente scelto è sua
        s.aggiungiDaFare("  Rinnovare l'iscrizione all'albo  ")
        controlla(s.dati.attivita.last.map { $0.clienteId.isEmpty && $0.titolo == "Rinnovare l'iscrizione all'albo" } ?? false,
                  "Da fare: «+ Aggiungi» con «Tutti i clienti» scrive una cosa «Per te»")
        controlla(s.nastroDaFareCompleto(cliente: nil).voci.contains { $0.cliente.id.isEmpty && $0.perche == "Rinnovare l'iscrizione all'albo" },
                  "Da fare: la cosa «Per te» è nel nastro")
        s.scegliCliente(primoCliente)
        s.aggiungiDaFare(String(repeating: "x", count: 100))
        controlla(s.dati.attivita.last.map { $0.clienteId == primoCliente && $0.titolo.count == TestiDaFare.massimoCaratteri } ?? false,
                  "Da fare: «+ Aggiungi» con un cliente scelto è sua, al più 70 caratteri")
        s.apriDaFare(soloCliente: true)
        controlla(s.pannelloNotifiche && s.clienteSoloDaFare?.id == primoCliente
                  && s.nastroDaFareCompleto(cliente: primoCliente).voci.allSatisfy { $0.cliente.id == primoCliente },
                  "Da fare: «Solo <Nome>» mostra solo le voci del cliente")
        s.pannelloNotifiche = false
        controlla(!s.arriviDaFare.contains { n in TestiDaFare.prefissiNelNastro.contains { n.id.hasPrefix($0) } },
                  "Da fare: gli arrivi non ripetono le voci del nastro")
    }
}
#endif
