#if os(macOS)
import Foundation

/// Le istantanee di Territorio, «Il tuo territorio» (Design/template-luce-specifica.md §5.1.7, serie 700-709, «Luce»
/// giro 11), tutte nello stato finale (`\.modoIstantanea`):
/// - 700: Oggi con i 35 clienti di prova (5 + 30 fittizi), chiaro e scuro; 701: La crescita all'ultimo anno, chiaro e
///   scuro; 702: La crescita a metà degli anni;
/// - 703: Il giro con 2 visite, il suggerimento «Lungo la strada» e l'auto all'arrivo, chiaro e scuro; 704: dopo
///   «＋ Aggiungi Sofia al giro» (3 visite, la riga nuova evidenziata);
/// - 705: nessun cliente con un luogo, chiaro e scuro; 706: tre clienti non sulla mappa con l'elenco aperto;
/// - 707: il giorno senza visite fuori studio («Il prossimo giro: …»); 708: il fumetto di Giulia (solo chiaro);
/// - 709: Impostazioni › Territorio, chiaro e scuro.
///
/// Migliorie d'uso 32 «La mappa risponde» (serie 1100-1129 del gruppo 05): 700, 701, 702, 706 e 708 restano su «Tutti i
/// clienti» (con un cliente scelto la vista Oggi lo mette in evidenza con i vicini); 700 mostra «Apri «Da fare» ›».
/// Migliorie d'uso 51 «Il giro di domani si porta in tasca»: 703, 704 (con «Togli»), 707 mostrano il piede nuovo
/// («Per averlo sull'iPhone accendi «Prisma ovunque»…»), 701 e 702 le date sotto il cursore e «Hanno cominciato nel …».
/// - 1155: le tappe con «Da portare: …», chiaro e scuro; 1156: «Prisma ovunque» acceso finto e «✓ Il giro è sull'iPhone»;
///   1157: la crescita su un anno con i nomi.
/// - 1100: la scheda aperta su un cliente con qualcosa da fare, chiaro e scuro; 1101: il cliente scelto (riquadro suo,
///   vicini accesi, anello bianco fermo); 1102: lo stesso con «Con qualcosa da fare» acceso (niente anello); 1103: il
///   cliente scelto non è sulla mappa.
///
/// DATI DI PROVA DICHIARATI: la tabella dei comuni è quella ridotta di prova (32 comuni, confini a ottagono); il giro di
/// Bologna (posizioni a mano di Laura, Andrea e Sofia, partenza, l'attività di Sofia) è `TerritorioDiProva`. Il giorno
/// del giro è il primo giorno di lavoro da domani, così l'istantanea non cambia con il giorno in cui gira il workflow.
extension Istantanee {
    nonisolated static var sceneTerritorio: [(nome: String, prepara: (StatoShell) -> Void)] {
        var scene: [(nome: String, prepara: (StatoShell) -> Void)] = []
        func una(_ nome: String, _ prepara: @escaping (StatoShell) -> Void) {
            scene.append((nome: nome, prepara: prepara))
        }
        func coppia(_ nome: String, _ prepara: @escaping (StatoShell) -> Void) {
            una(nome, prepara)
            una(nome + "-scuro", prepara)
        }
        coppia("700-territorio-oggi") { s in
            s.scegliCliente(nil)
            conFittizi(s)
            s.apriTerritorioIstantanea(.oggi)
        }
        coppia("701-territorio-crescita") { s in
            s.scegliCliente(nil)
            conFittizi(s)
            s.territorio.avvioCrescitaFatto = true
            s.territorio.annoCrescita = nil
            s.apriTerritorioIstantanea(.crescita)
        }
        una("702-territorio-crescita-anno") { s in
            s.scegliCliente(nil)
            conFittizi(s)
            s.territorio.avvioCrescitaFatto = true
            s.apriTerritorioIstantanea(.crescita)
            let anni = s.crescitaTerritorio().anni
            if let primo = anni.first?.anno, let ultimo = anni.last?.anno { s.territorio.annoCrescita = (primo + ultimo) / 2 }
        }
        coppia("703-territorio-giro") { s in
            giroDiProva(s, spostaVisite: 0)
            s.apriTerritorioIstantanea(.giro)
        }
        una("704-territorio-giro-aggiunto") { s in
            let g = giroDiProva(s, spostaVisite: 0)
            s.apriTabellaTerritorio()
            if let primo = s.giroTerritorio(g).suggerimenti.first { s.aggiungiAlGiro(primo) }
            s.apriTerritorioIstantanea(.giro)
        }
        coppia("705-territorio-vuoto") { s in
            for i in s.dati.clienti.indices {
                s.dati.clienti[i].indirizzo = ""
                s.dati.clienti[i].fiscale = nil
                s.dati.clienti[i].luogo = nil
            }
            s.apriTerritorioIstantanea(.oggi)
        }
        una("706-territorio-senza-luogo") { s in
            s.scegliCliente(nil)
            let indirizzi = ["giulia": "Via Che Non Esiste 3, Paperopoli", "marco": "Piazza 1, Samone", "laura": ""]
            for i in s.dati.clienti.indices {
                if let nuovo = indirizzi[s.dati.clienti[i].id] {
                    s.dati.clienti[i].indirizzo = nuovo
                    s.dati.clienti[i].fiscale = nil
                    s.dati.clienti[i].luogo = nil
                }
            }
            s.apriTerritorioIstantanea(.oggi)
            s.territorio.elencoSenzaLuogo = true
        }
        una("707-territorio-giro-vuoto") { s in
            giroDiProva(s, spostaVisite: 3)
            s.apriTerritorioIstantanea(.giro)
        }
        una("708-territorio-fumetto") { s in
            s.scegliCliente(nil)
            conFittizi(s)
            s.apriTerritorioIstantanea(.oggi)
            s.territorio.lucePuntata = "giulia"
        }
        coppia("709-impostazioni-territorio") { s in
            s.territorio.caricaSeServe()
            s.schedaImpostazioni = .territorio
            s.apri(.impostazioni)
        }
        // Migliorie d'uso 32
        coppia("1100-uso-territorio-scheda-luce") { s in
            s.scegliCliente(nil)
            conFittizi(s)
            s.apriTerritorioIstantanea(.oggi)
            let luci = s.territorioOggi().luci
            s.territorio.luceScelta = (luci.first { $0.daFare != nil } ?? luci.first)?.id
        }
        una("1101-uso-territorio-cliente") { s in
            conFittizi(s)
            s.scegliCliente("giulia")
            s.apriTerritorioIstantanea(.oggi)
        }
        una("1102-uso-territorio-cliente-filtro") { s in
            conFittizi(s)
            s.scegliCliente("giulia")
            s.apriTerritorioIstantanea(.oggi)
            s.territorio.soloDaFare = true
        }
        una("1103-uso-territorio-cliente-senza-luogo") { s in
            conFittizi(s)
            if let i = s.dati.clienti.firstIndex(where: { $0.id == "giulia" }) {
                s.dati.clienti[i].indirizzo = ""
                s.dati.clienti[i].fiscale = nil
                s.dati.clienti[i].luogo = nil
            }
            s.scegliCliente("giulia")
            s.apriTerritorioIstantanea(.oggi)
        }
        // Migliorie d'uso 51
        coppia("1155-uso-territorio-giro-borsa") { s in
            let g = giroDiProva(s, spostaVisite: 0)
            borsaDiProva(s, giorno: g)
            s.apriTerritorioIstantanea(.giro)
        }
        una("1156-uso-territorio-giro-iphone") { s in
            let g = giroDiProva(s, spostaVisite: 0)
            borsaDiProva(s, giorno: g)
            // «Prisma ovunque» acceso solo nella scena (nessuna cartella, nessuna scrittura): il giro risulta già mandato
            s.dati.impostazioni.ovunque.acceso = true
            s.territorio.giroIPhone = GiroInviatoIPhone(giorno: g, giri: s.ovunque.giri - 1)
            s.apriTerritorioIstantanea(.giro)
        }
        una("1157-uso-territorio-crescita-nomi") { s in
            s.scegliCliente(nil)
            conFittizi(s)
            s.territorio.avvioCrescitaFatto = true
            s.apriTerritorioIstantanea(.crescita)
            // L'anno con più famiglie nuove dopo il primo (così si vedono i nomi e «e altre n»)
            let anni = s.crescitaTerritorio().anni
            if let a = anni.dropFirst().max(by: { ($0.nuovi.count, -$0.anno) < ($1.nuovi.count, -$1.anno) }) {
                s.territorio.annoCrescita = a.anno
            }
        }
        return scene
    }

    /// Migliorie d'uso 51 (DATI DI PROVA): il fascicolo della visita di Laura già nei Documenti e il documento d'identità di
    /// Andrea che scade fra dieci giorni, così le tappe dicono «Da portare: …».
    nonisolated static func borsaDiProva(_ s: StatoShell, giorno: Date) {
        var d = s.dati.istantanea
        let cal = Calendar.current
        if let a = d.appuntamenti.first(where: { $0.clienteId == "laura" && cal.isDate($0.inizio, inSameDayAs: giorno) }) {
            d.documenti.append(Documento(clienteId: "laura", titolo: MotoreBorsa.titoloFascicolo(a), tipo: .report))
        }
        if let i = d.clienti.firstIndex(where: { $0.id == "andrea" }) {
            var conf = d.clienti[i].conformita ?? ConformitaCliente()
            let scadenza = cal.date(byAdding: .day, value: 10, to: giorno) ?? giorno
            conf.documento = DocumentoIdentita(tipo: .cartaIdentita, numero: nil,
                                               rilasciatoIl: cal.date(byAdding: .year, value: -10, to: scadenza), scadenza: scadenza)
            d.clienti[i].conformita = conf
        }
        s.dati.carica(d)
    }

    /// I 5 clienti di prova più i 30 fittizi (dati di prova).
    nonisolated static func conFittizi(_ s: StatoShell) {
        var d = s.dati.istantanea
        ClientiFittizi.aggiungi(a: &d)
        s.dati.carica(d)
    }

    /// Il giro di prova di Bologna sul primo giorno di lavoro da domani; con `spostaVisite` le visite vanno a quel giorno
    /// più tanti giorni (707: il giorno resta senza visite fuori studio). Restituisce il giorno mostrato.
    @discardableResult
    nonisolated static func giroDiProva(_ s: StatoShell, spostaVisite: Int) -> Date {
        let g = TerritorioDiProva.giorno(da: Date(), orari: s.dati.impostazioni.orari)
        let giornoVisite = Calendar.current.date(byAdding: .day, value: spostaVisite, to: g) ?? g
        var d = s.dati.istantanea
        TerritorioDiProva.applica(&d, giorno: giornoVisite, conPartenza: true)
        s.dati.carica(d)
        s.territorio.giornoGiro = g
        return g
    }
}

extension StatoShell {
    /// Nelle istantanee `onAppear` può arrivare tardi: tabella e confini si caricano prima di aprire Territorio.
    func apriTerritorioIstantanea(_ vista: VistaTerritorio) {
        apriTabellaTerritorio()
        apriTerritorio(vista)
    }
}
#endif
