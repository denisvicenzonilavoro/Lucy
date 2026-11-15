import Foundation

/// Migliorie d'uso 21 «Incontri segue il cliente e non si ferma a oggi» (solo sul Mac, dentro `--prova-vera`): i tre
/// gruppi dell'elenco, i limiti (14 giorni e 20 prossimi, 12 mesi e 30 fatti, 7 giorni per «da chiudere»), il filtro
/// per cliente, i blocchi «Non disponibile» esclusi, niente doppioni fra appuntamento e incontro, il momento su cui si
/// apre una riga, e che aprire un appuntamento senza incontro non scriva nell'archivio finché non si scrive.
enum ProvaElencoIncontri {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        #if os(macOS)
        regole(controlla)
        stato(controlla)
        #endif
    }

    #if os(macOS)
    private static func appuntamento(_ id: String, _ cliente: String, _ inizio: Date, minuti: Int = 45,
                                     stato: Appuntamento.Stato = .pianificato,
                                     tipo: TipoAppuntamento = .analisi) -> Appuntamento {
        Appuntamento(id: id, clienteId: cliente, titolo: "Incontro \(id)", inizio: inizio, durataMinuti: minuti,
                     luogo: "In studio", note: "", stato: stato, tipo: tipo)
    }

    private static func regole(_ controlla: (Bool, String) -> Void) {
        let cal = Calendar.current
        let oggi = cal.startOfDay(for: Date())
        let adesso = cal.date(bySettingHour: 12, minute: 0, second: 0, of: oggi) ?? oggi
        func giorno(_ d: Int, _ h: Int = 10) -> Date {
            let g = cal.date(byAdding: .day, value: d, to: oggi) ?? oggi
            return cal.date(bySettingHour: h, minute: 0, second: 0, of: g) ?? g
        }
        var app: [Appuntamento] = [
            appuntamento("oggi-mattina", "anna", giorno(0, 9)),
            appuntamento("oggi-pomeriggio", "anna", giorno(0, 15)),
            appuntamento("blocco", "", giorno(0, 16), tipo: .nonDisponibile),
            appuntamento("blocco-cliente", "anna", giorno(0, 17), tipo: .nonDisponibile),
            appuntamento("altro-cliente", "bruno", giorno(1)),
            appuntamento("ieri-aperto", "anna", giorno(-1)),
            appuntamento("ieri-chiuso", "anna", giorno(-2), stato: .concluso),
            appuntamento("troppo-vecchio", "anna", giorno(-9)),
            appuntamento("oltre-14", "anna", giorno(15)),
        ]
        // 25 appuntamenti nei prossimi giorni: ne entrano 20
        for k in 0..<25 { app.append(appuntamento("prossimo-\(k)", "anna", giorno(1 + k % 14, 8 + k % 10))) }
        var legato = Incontro(clienteId: "anna", titolo: "Il punto di oggi", data: giorno(0, 9), appuntamentoId: "oggi-mattina")
        legato.id = "incontro-legato"
        var sciolto = Incontro(clienteId: "anna", titolo: "Senza appuntamento", data: giorno(0, 11))
        sciolto.id = "incontro-sciolto"
        var incontri = [legato, sciolto]
        // 35 incontri conclusi negli ultimi mesi (ne entrano 30) e uno di 13 mesi fa (fuori)
        for k in 0..<35 {
            var i = Incontro(clienteId: "anna", titolo: "Concluso \(k)", data: giorno(-3 - k * 5))
            i.id = "concluso-\(k)"
            i.stato = .concluso
            incontri.append(i)
        }
        var vecchio = Incontro(clienteId: "anna", titolo: "Vecchio",
                               data: cal.date(byAdding: .month, value: -13, to: oggi) ?? oggi)
        vecchio.id = "concluso-vecchio"
        vecchio.stato = .concluso
        incontri.append(vecchio)

        let tutti = RegoleElencoIncontri.calcola(appuntamenti: app, incontri: incontri, cliente: nil,
                                                 visibile: { _ in true }, adesso: adesso)
        let anna = RegoleElencoIncontri.calcola(appuntamenti: app, incontri: incontri, cliente: "anna",
                                                visibile: { _ in true }, adesso: adesso)
        controlla(anna.oggi.map(\.id) == ["incontro-legato", "incontro-sciolto", "appuntamento:oggi-pomeriggio"],
                  "Elenco incontri: «Oggi» unisce l'appuntamento al suo incontro, aggiunge l'incontro senza appuntamento, in ordine di ora, senza blocchi «Non disponibile»")
        controlla(anna.oggi.first?.daChiudere == true && anna.oggi.last?.daChiudere == false,
                  "Elenco incontri: l'appuntamento di stamattina passato è «da chiudere», quello del pomeriggio no")
        controlla(anna.prossimi.count == RegoleElencoIncontri.massimoProssimi
                  && !anna.prossimi.contains { $0.appuntamentoId == "oltre-14" }
                  && zip(anna.prossimi, anna.prossimi.dropFirst()).allSatisfy { coppia in coppia.0.quando <= coppia.1.quando },
                  "Elenco incontri: «Prossimi» al più 20, entro 14 giorni, in ordine di data")
        controlla(anna.fatti.first?.appuntamentoId == "ieri-aperto" && anna.fatti.first?.daChiudere == true
                  && !anna.fatti.contains { $0.appuntamentoId == "ieri-chiuso" || $0.appuntamentoId == "troppo-vecchio" },
                  "Elenco incontri: in testa ai «Fatti» gli appuntamenti degli ultimi 7 giorni ancora da chiudere")
        let conclusi = anna.fatti.filter { !$0.daChiudere }
        controlla(conclusi.count == RegoleElencoIncontri.massimoFatti && conclusi.allSatisfy(\.fatto)
                  && !conclusi.contains { $0.id == "concluso-vecchio" } && conclusi.first?.id == "concluso-0",
                  "Elenco incontri: «Fatti» al più 30 incontri conclusi degli ultimi 12 mesi, dal più recente")
        controlla(!anna.tutte.contains { $0.clienteId != "anna" } && tutti.prossimi.contains { $0.clienteId == "bruno" },
                  "Elenco incontri: con un cliente scelto solo i suoi, con «Tutti i clienti» anche gli altri")
        let ids = tutti.tutte.map(\.id)
        controlla(Set(ids).count == ids.count && !ids.contains("appuntamento:oggi-mattina"),
                  "Elenco incontri: nessun doppione fra l'appuntamento e il suo incontro")
        let nascosto = RegoleElencoIncontri.calcola(appuntamenti: app, incontri: incontri, cliente: nil,
                                                    visibile: { $0 == "bruno" }, adesso: adesso)
        controlla(nascosto.tutte.allSatisfy { $0.clienteId == "bruno" },
                  "Elenco incontri: i clienti che non si vedono (modalità cliente) restano fuori")
        if let o = anna.oggi.last, let p = anna.prossimi.first, let f = conclusi.first {
            controlla(RegoleElencoIncontri.momento(o, verbale: false) == .ascolto
                      && RegoleElencoIncontri.momento(o, verbale: true) == .passi
                      && RegoleElencoIncontri.momento(p, verbale: false) == .preparazione
                      && RegoleElencoIncontri.momento(f, verbale: false) == .passi,
                      "Elenco incontri: oggi si apre su «Ascolto» («Prossimi passi» con il verbale), prossimo su «Preparazione», fatto su «Prossimi passi»")
        }
    }

    private static func stato(_ controlla: (Bool, String) -> Void) {
        let s = StatoShell(persistente: false)
        guard let c = s.clienti.first else {
            controlla(false, "Elenco incontri: nei dati di prova manca un cliente")
            return
        }
        let cal = Calendar.current
        let domani = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date())) ?? Date()
        let inizio = cal.date(bySettingHour: 11, minute: 0, second: 0, of: domani) ?? domani
        let a = appuntamento("prova-elenco-incontri", c.id, inizio)
        s.dati.appuntamenti.append(a)
        let prima = s.dati.incontri.count
        s.apriIncontro(per: a)
        controlla(s.dati.incontri.count == prima && s.appuntamentoIncontro == a.id && s.incontroAperto == nil,
                  "Elenco incontri: aprire un appuntamento senza incontro non scrive nell'archivio")
        controlla(s.elencoIncontri(cliente: c.id).prossimi.contains { $0.appuntamentoId == a.id && $0.incontroId == nil },
                  "Elenco incontri: l'appuntamento senza incontro è fra i «Prossimi» del cliente")
        let bozza = s.bozzaIncontroElenco(per: a)
        controlla(s.dati.incontri.count == prima && bozza.appuntamentoId == a.id,
                  "Elenco incontri: la bozza dall'appuntamento resta fuori dall'archivio")
        s.assicuraIncontro(bozza)
        s.assicuraIncontro(bozza)
        controlla(s.dati.incontri.count == prima + 1 && s.incontroAperto == bozza.id && s.appuntamentoIncontro == nil,
                  "Elenco incontri: l'incontro nasce una volta sola, al primo gesto che scrive")
        controlla(s.elencoIncontri(cliente: c.id).prossimi.contains { $0.appuntamentoId == a.id && $0.incontroId == bozza.id },
                  "Elenco incontri: dopo il primo gesto la riga è dell'incontro, senza doppioni")
        if let altro = s.clienti.first(where: { $0.id != c.id }) {
            s.scegliCliente(altro.id)
            controlla(s.incontroAperto == nil && s.appuntamentoIncontro == nil,
                      "Elenco incontri: cambiando cliente nella barra si riparte dal suo primo incontro")
        }
    }
    #endif
}
