import Foundation

// Le impostazioni dello stile Carta dentro `Prisma --prova-backup`: `Impostazioni.carta` cambiata va e torna dall'archivio
// (codifica e decodifica dell'archivio), un archivio di prima senza la chiave si apre con i valori di base, i valori
// fuori misura tornano nei limiti e un valore illeggibile non ferma la lettura delle altre impostazioni.

extension ProvaBackup {
    /// Restituisce il motivo dell'errore (nil = tutto bene).
    static func provaCarta() throws -> String? {
        var imp = Impostazioni()
        imp.carta.sogliaPesoTimbro = 25
        imp.carta.quotaAccantonamento = 32
        imp.carta.sfondo = .marmo
        let dati = try Archivio.codificatore.encode(imp)
        let letta = try Archivio.decodificatore.decode(Impostazioni.self, from: dati)
        guard letta.carta == imp.carta else { return "carta: le impostazioni non tornano uguali dall'archivio" }

        // Un archivio di prima: niente chiave «carta»
        var oggetto = try JSONSerialization.jsonObject(with: dati) as? [String: Any] ?? [:]
        oggetto.removeValue(forKey: "carta")
        let primaDati = try JSONSerialization.data(withJSONObject: oggetto)
        let prima = try Archivio.decodificatore.decode(Impostazioni.self, from: primaDati)
        guard prima.carta == ImpostazioniCarta() else { return "carta: senza la chiave non si aprono i valori di base" }
        guard prima.carta.quotaAccantonamento == nil else { return "carta: la quota da mettere da parte non deve avere un valore di base" }

        // Valori fuori misura e illeggibili
        oggetto["carta"] = ["sogliaPesoTimbro": 400, "quotaAccantonamento": -5, "sfondo": "sconosciuto"]
        let strani = try Archivio.decodificatore.decode(Impostazioni.self,
                                                       from: try JSONSerialization.data(withJSONObject: oggetto))
        guard strani.carta.sogliaPesoTimbro == 100, strani.carta.quotaAccantonamento == 0,
              strani.carta.sfondo == .luce else {
            return "carta: i valori fuori misura o illeggibili non tornano nei limiti"
        }
        guard strani.nomeUtente == imp.nomeUtente else { return "carta: un valore illeggibile ha fermato le altre impostazioni" }

        // I cedolini nell'archivio delle spese di Studio: vanno e tornano, uno illeggibile si scarta
        let cedolino = CedolinoProvvigioni(id: "cedolino-prova", mese: Date(timeIntervalSinceReferenceDate: 815_000_000),
                                           canale: .alleanza, lordo: 2_460.5, netto: 1_894.5, fonte: "cedolino.pdf",
                                           registratoIl: Date(timeIntervalSinceReferenceDate: 815_100_000))
        let spese = ArchivioSpese(cedolini: [cedolino])
        let speseLette = try Archivio.decodificatore.decode(ArchivioSpese.self, from: try Archivio.codificatore.encode(spese))
        guard speseLette.cedolini == [cedolino] else { return "carta: i cedolini non tornano uguali dall'archivio" }
        var speseOggetto = try JSONSerialization.jsonObject(with: try Archivio.codificatore.encode(spese)) as? [String: Any] ?? [:]
        var elenco = speseOggetto["cedolini"] as? [Any] ?? []
        elenco.append(["mese": "non è una data"])
        speseOggetto["cedolini"] = elenco
        let tolleranti = try Archivio.decodificatore.decode(ArchivioSpese.self, from: try JSONSerialization.data(withJSONObject: speseOggetto))
        guard tolleranti.cedolini.count == 1 else { return "carta: un cedolino illeggibile non si scarta" }
        guard ArchivioSpese(cedolini: [cedolino]).vuoto == false else { return "carta: un archivio con un cedolino non è vuoto" }

        // L'esportazione dei dati di un cliente (GDPR art. 15 e 20): solo i suoi dati, nessun altro cliente
        let demo = DatiPrisma.demo()
        if let primo = demo.clienti.first, let altro = demo.clienti.last, primo.id != altro.id {
            let soli = EsportazioneCliente.dati(di: primo.id, da: demo)
            guard soli.clienti.map(\.id) == [primo.id] else { return "gdpr: l'esportazione porta anche altri clienti" }
            guard soli.posizioni.count == demo.posizioni.filter({ $0.clienteId == primo.id }).count,
                  soli.posizioni.allSatisfy({ $0.clienteId == primo.id }) else { return "gdpr: le posizioni esportate non sono tutte e sole del cliente" }
            let file = try EsportazioneCliente.json(di: primo.id, da: demo)
            let testo = String(decoding: file, as: UTF8.self)
            guard testo.contains(primo.nome) else { return "gdpr: il file esportato non contiene il cliente" }
            guard (try? JSONSerialization.jsonObject(with: file)) != nil else { return "gdpr: il file esportato non è un JSON valido" }
        }

        // Il sigillo: 40 copie automatiche settimanali (dalla più recente) → le ultime 12 e una al mese prima
        let cal = Calendar(identifier: .gregorian)
        let oggi = cal.date(from: DateComponents(year: 2026, month: 11, day: 22, hour: 3)) ?? Date()
        let copie = (0..<40).map { k in
            VoceBackup(url: URL(fileURLWithPath: "/tmp/Prisma backup \(k) automatico.zip"),
                       data: cal.date(byAdding: .day, value: -7 * k, to: oggi) ?? oggi, dimensione: 1)
        }
        let via = Set(GestoreBackup.automaticiDaEliminare(copie, calendario: cal).map(\.url))
        let restano = copie.filter { !via.contains($0.url) }
        guard Array(restano.prefix(12)) == Array(copie.prefix(12)) else { return "sigillo: le ultime 12 settimane non restano tutte" }
        let vecchie = restano.dropFirst(12)
        let mesiVecchi = vecchie.map { cal.dateComponents([.year, .month], from: $0.data) }
        guard Set(mesiVecchi.map { "\($0.year ?? 0)-\($0.month ?? 0)" }).count == vecchie.count else {
            return "sigillo: prima delle 12 settimane deve restare una copia sola per mese"
        }
        guard !vecchie.isEmpty, vecchie.count < 28 else { return "sigillo: la rotazione mensile non ha tenuto le copie giuste" }
        guard GestoreBackup.automaticiDaEliminare(Array(copie.prefix(12)), calendario: cal).isEmpty else {
            return "sigillo: con 12 copie non si elimina niente"
        }
        // La domenica alle 03:00: da mercoledì 18 novembre 2026 alle 10 → domenica 22 alle 3
        let mercoledi = cal.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 10)) ?? Date()
        let domenica = ImpostazioniBackup.domenicaDopo(mercoledi, calendario: cal)
        let attesa = cal.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: domenica)
        guard attesa.year == 2026, attesa.month == 11, attesa.day == 22, attesa.hour == 3, attesa.minute == 0, attesa.weekday == 1 else {
            return "sigillo: la copia automatica non cade la domenica alle 03:00"
        }
        // Appena fatta la copia della domenica, la prossima è la domenica dopo
        let dopo = ImpostazioniBackup.domenicaDopo(domenica, calendario: cal)
        guard cal.dateComponents([.day], from: domenica, to: dopo).day == 7 else { return "sigillo: la copia dopo non è fra una settimana" }
        return nil
    }
}
