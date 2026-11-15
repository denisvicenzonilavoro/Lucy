import Foundation

/// I dati delle scene del pannello «Aggiorna i valori» (180–185): relativi a oggi, così le istantanee si
/// ripetono a ogni ora del server. `DatiDemo` non cambia: le posizioni di prova hanno il valore a −5 giorni.
enum DatiAggiornaValoriDemo {
    /// Un elenco «della compagnia» per i clienti di prova (righe CSV, date relative a oggi).
    /// −2 giorni è più recente del valore delle posizioni di prova, −200 va nello storico.
    static func elenco(oggi: Date) -> String {
        func g(_ n: Int) -> String {
            Formati.dataBreve.string(from: Calendar.current.date(byAdding: .day, value: n, to: oggi) ?? oggi)
        }
        let righe = [
            "Contraente;Numero polizza;Prodotto;Controvalore;Data valore;Totale versato;Valore gestione separata",
            "Giulia Rossi;AL-2022-104851;Piano di risparmio rivalutabile;7.790;\(g(-2));7.350;",
            "Giulia Rossi;;ETF azionario globale;37.150;\(g(-2));;",
            "Marco Bianchi;AL-2020-055120;Polizza rivalutabile a premio unico;54.420;\(g(-2));;",
            "Marco Bianchi;AL-2021-118842;Polizza multiramo;61.380;\(g(-2));;25.100",
            "Marco Bianchi;AL-2021-118842;Polizza multiramo;60.200;\(g(-200));;",
            "Sofia Romano;AL-2016-009311;Polizza rivalutabile;41.640;\(g(-2));;",
            "Giulia Rossi;AL-2023-220417;Temporanea caso morte;0;\(g(-2));;",
            "Laura Moretti;;ETF azionario globale;27.400;\(g(-2));;",
            // Migliorie d'uso 44: un calo oltre la soglia del motore (25%) e una polizza che tra le posizioni non c'è
            "Laura Moretti;;Fondo pensione aperto;13.100;\(g(-2));;",
            "Marco Bianchi;AL-2024-077120;Temporanea caso morte;0;\(g(-2));;",
            "Paolo Neri;AL-2025-777001;Piano futuro;10.000;\(g(-2));;",
        ]
        return righe.joined(separator: "\n") + "\n"
    }

    /// Invecchia i valori di tre posizioni di prova e toglie la data a una (solo per la scena della griglia).
    /// I valori passati più recenti della data nuova si tolgono, perché lo storico resti in ordine.
    static func invecchia(_ s: StatoShell) {
        let cal = Calendar.current
        let oggi = Date()
        func indietro(_ giorni: Int) -> Date {
            ValoriDaDocumento.mezzogiorno(cal.date(byAdding: .day, value: -giorni, to: oggi) ?? oggi)
        }
        let giorni = ["pos-giulia-fondo-obbligazionario-euro": 400,
                      "pos-laura-fondo-pensione-aperto": 430,
                      "pos-sofia-portafoglio-di-fondi": 380]
        var posizioni = s.dati.posizioni
        for i in posizioni.indices {
            let id = posizioni[i].id
            if let n = giorni[id] {
                let data = indietro(n)
                posizioni[i].dataValore = data
                posizioni[i].rilevazioni?.removeAll { $0.data >= data }
            } else if id == "pos-marco-piano-individuale-pensionistico" {
                posizioni[i].dataValore = nil
            }
        }
        s.dati.posizioni = posizioni
    }

    /// Le caselle già scritte nella griglia della scena.
    static func bozze() -> [String: AggiornaValori.Bozza] {
        ["pos-giulia-fondo-obbligazionario-euro": AggiornaValori.Bozza(valore: "21.350"),
         "pos-sofia-portafoglio-di-fondi": AggiornaValori.Bozza(valore: "33.100", versato: "28.000")]
    }

    /// Migliorie d'uso 44: le decisioni della scena 184 (e del riepilogo 182) sulle righe in dubbio dell'elenco: il calo
    /// è giusto, la polizza di un cliente è nuova, quella di chi non è fra i clienti si salta, la posizione da scegliere
    /// (se c'è) la prima candidata.
    static func decisioni(_ s: StatoShell, sessione: AggiornaValori.Sessione)
        -> (decisioni: [Int: AggiornaValori.DecisioneValore], clienti: [Int: String], scelte: [Int: String]) {
        let esiti = AggiornaValori.esiti(sessione.righe, posizioni: s.posizioni, clienti: s.clienti,
                                         dataComune: sessione.dataComune, oggi: Date())
        var decisioni: [Int: AggiornaValori.DecisioneValore] = [:]
        var clienti: [Int: String] = [:]
        var scelte: [Int: String] = [:]
        for e in esiti {
            switch AggiornaValori.dubbio(e) {
            case .calo?, .aumento?:
                decisioni[e.id] = .giusto
            case .nuova?:
                if let c = ImportaPosizioni.abbina(nome: e.riga.cliente, codiceFiscale: e.riga.codiceFiscale, clienti: s.clienti) {
                    decisioni[e.id] = .nuova
                    clienti[e.id] = c.id
                } else {
                    decisioni[e.id] = .salta
                }
            case .scegli?:
                if let id = e.candidate.first { scelte[e.id] = id } else { decisioni[e.id] = .salta }
            case nil:
                break
            }
        }
        return (decisioni, clienti, scelte)
    }

    /// La sessione dell'elenco di prova (scene 180, 182, 184, 185).
    static func sessione(oggi: Date = Date()) -> AggiornaValori.Sessione? {
        AggiornaValori.sessione(tabella: ImportaClienti.righeCSV(elenco(oggi: oggi)),
                                file: "Valori Alleanza e indipendenti.xlsx", dataComune: oggi)
    }
}
