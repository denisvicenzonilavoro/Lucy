import Foundation

// Migliorie d'uso 60 «Ogni esperienza lascia qualcosa» dentro `Prisma --prova-backup`: le esperienze della Sala fatte
// (`esperienzeFatte`) stanno nel file del cliente, vanno e tornano da backup e ripristino; un archivio di prima, senza la
// chiave, si apre con l'elenco vuoto; un'esperienza sconosciuta si scarta e le altre restano; un cliente tolto porta via
// le sue; sul Mac il segno si mette una sola volta al giorno. Dati di prova dichiarati, date al secondo.

extension ProvaBackup {
    /// Restituisce il motivo dell'errore (nil = tutto bene).
    static func provaEsperienzeFatte(radice: URL) throws -> String? {
        let fm = FileManager.default
        let base = radice.appendingPathComponent("EsperienzeFatte", isDirectory: true)
        let dati = base.appendingPathComponent("Prisma", isDirectory: true)
        let backup = base.appendingPathComponent("Backup", isDirectory: true)
        defer { try? fm.removeItem(at: base) }
        try fm.createDirectory(at: dati, withIntermediateDirectories: true)

        guard ArchivioPezzi.pezzo(.esperienzeFatte) == .cliente else {
            return "esperienze fatte: non stanno nel file del cliente"
        }

        var archivio = DatiPrisma.demo()
        guard archivio.esperienzeFatte.isEmpty else { return "esperienze fatte: i dati di prova ne hanno già" }
        let t0 = Date(timeIntervalSinceReferenceDate: 815_003_417)
        let fatte = [
            EsperienzaFatta(id: "fatta-prova-g1", clienteId: "giulia", esperienza: .giornataPensione, quando: t0),
            EsperienzaFatta(id: "fatta-prova-g2", clienteId: "giulia", esperienza: .prismaLuce, quando: t0.addingTimeInterval(60)),
            EsperienzaFatta(id: "fatta-prova-m1", clienteId: "marco", esperienza: .giocoRischio, quando: t0.addingTimeInterval(86_400)),
        ]
        archivio.esperienzeFatte = fatte
        try Archivio.salva(archivio, in: dati)

        // Il posto su disco: nel file di Giulia (e di Marco), mai nell'indice
        let pezzi = ArchivioPezzi.cartellaPezzi(in: dati)
        func leggi(_ url: URL) -> String { (try? String(contentsOf: url, encoding: .utf8)) ?? "" }
        let clienti = pezzi.appendingPathComponent(ArchivioPezzi.nomeClienti, isDirectory: true)
        let fileGiulia = leggi(clienti.appendingPathComponent(ArchivioPezzi.nomeFile(cliente: "giulia")))
        let fileMarco = leggi(clienti.appendingPathComponent(ArchivioPezzi.nomeFile(cliente: "marco")))
        let indice = leggi(pezzi.appendingPathComponent(ArchivioPezzi.nomeIndice))
        guard fileGiulia.contains("fatta-prova-g1"), fileMarco.contains("fatta-prova-m1"), !fileGiulia.contains("fatta-prova-m1"),
              !indice.contains("fatta-prova-g1") else {
            return "esperienze fatte: non stanno al loro posto nella cartella a pezzi"
        }
        let riletto = Archivio.carica(in: dati).dati
        guard Set(riletto.esperienzeFatte) == Set(fatte) else { return "esperienze fatte: non si rileggono uguali dalla cartella a pezzi" }

        // Backup e ripristino
        let creato = try GestoreBackup.crea(sorgente: dati, destinazione: backup)
        let estratto = try GestoreBackup.estrai(creato)
        let d = estratto.dati
        GestoreBackup.pulisciEstrazione(estratto.cartella)
        guard Set(d.esperienzeFatte) == Set(fatte) else { return "esperienze fatte: non tornano uguali dal backup" }
        let ripristinata = base.appendingPathComponent("Ripristino/Prisma", isDirectory: true)
        try GestoreBackup.sostituisci(cartellaDati: ripristinata, con: try GestoreBackup.estrai(creato).cartella)
        guard Set(Archivio.carica(in: ripristinata).dati.esperienzeFatte) == Set(fatte) else {
            return "esperienze fatte: non tornano dal ripristino"
        }

        // Un archivio di prima, senza la chiave: elenco vuoto
        var vecchio = try JSONSerialization.jsonObject(with: Archivio.codificatore.encode(archivio)) as? [String: Any] ?? [:]
        vecchio["esperienzeFatte"] = nil
        let letto = try Archivio.decodificatore.decode(DatiPrisma.self, from: JSONSerialization.data(withJSONObject: vecchio))
        guard letto.esperienzeFatte.isEmpty, letto.clienti.count == archivio.clienti.count else {
            return "esperienze fatte: un archivio di prima non si apre con l'elenco vuoto"
        }

        // Lettura tollerante: un'esperienza sconosciuta (da un Prisma più nuovo) si scarta, le altre restano
        var strana = try JSONSerialization.jsonObject(with: Archivio.codificatore.encode(fatte[1])) as? [String: Any] ?? [:]
        strana["esperienza"] = "esperienzaDelFuturo"
        let buona = try JSONSerialization.jsonObject(with: Archivio.codificatore.encode(fatte[0]))
        let lette = try Archivio.decodificatore.decode(ElencoTollerante<EsperienzaFatta>.self,
                                                       from: JSONSerialization.data(withJSONObject: [strana, buona] as [Any])).elementi
        guard lette == [fatte[0]] else { return "esperienze fatte: non si leggono con tolleranza" }

        // Un cliente tolto porta via le sue; quelle degli altri restano
        let s = StatoShell(persistente: false)
        s.dati.esperienzeFatte = fatte
        s.eliminaCliente("giulia")
        guard s.dati.esperienzeFatte == [fatte[2]] else {
            return "esperienze fatte: un cliente tolto non porta via le sue (o porta via quelle degli altri)"
        }
        #if os(macOS)
        // Il segno: una sola volta al giorno per esperienza e cliente; «Togli» lo toglie
        s.dati.esperienzeFatte = []
        s.segnaEsperienza(.lettera, cliente: "marco", avviso: false)
        s.segnaEsperienza(.lettera, cliente: "marco", avviso: false)
        guard s.dati.esperienzeFatte.count == 1, s.esperienzaFattaOggi(.lettera, cliente: "marco"),
              !s.esperienzaFattaOggi(.lettera, cliente: "laura") else {
            return "esperienze fatte: il segno non si mette una sola volta al giorno"
        }
        guard s.prossimaEsperienza(dopo: .lettera, cliente: "marco") != .lettera else {
            return "esperienze fatte: la prossima propone l'esperienza aperta"
        }
        if let id = s.dati.esperienzeFatte.first?.id { s.togliEsperienzaFatta(id) }
        guard s.dati.esperienzeFatte.isEmpty, !s.esperienzaFattaOggi(.lettera, cliente: "marco") else {
            return "esperienze fatte: «Togli» non toglie il segno (o il dato ricavato resta vecchio)"
        }
        #endif
        return nil
    }
}
