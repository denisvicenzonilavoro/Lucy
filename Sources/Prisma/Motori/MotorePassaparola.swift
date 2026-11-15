import Foundation

// Clienti › Potenziali e Passaparola («Luce» giro 12, Design/template-luce-specifica.md §9.2): il percorso dei potenziali
// clienti con i loro totali (decisione 94: solo stime e probabilità scritte dall'utente), l'albero di chi ha presentato
// chi (decisione 95: tre generazioni, poi «+ N»), gli ambasciatori con «portato» e «in arrivo» separati, la quota del
// patrimonio nuovo nato dal passaparola, i nuovi clienti per anno e il momento giusto per chiedere una presentazione
// (decisione 17: un fatto degli ultimi 7 giorni, consenso commerciale valido, nessuna richiesta negli ultimi 180 giorni).
// Motore puro: riceve i dati, `oggi` e il calendario; niente StatoShell.

/// I totali delle tile della vista Potenziali.
struct TotaliPotenziali: Equatable {
    /// Le prime quattro colonne (la colonna «Cliente» e i non interessati non contano).
    let conteggio: Int
    /// La somma delle stime note.
    let patrimonioStimato: Double
    let senzaStima: Int
    /// Con un presentatore che è un cliente dell'archivio.
    let dalPassaparola: Int
    /// Σ stima × probabilità / 100 dei soli completi (stima, probabilità e chiusura entro il 31 dicembre).
    let probabileEntroAnno: Double
    /// Senza stima, probabilità o data (o con la data oltre l'anno): fuori dal probabile, contati a parte.
    let esclusiDalProbabile: Int
}

/// Il tipo di un nodo dell'albero del passaparola.
enum TipoNodoPassaparola: Hashable {
    case tu
    case cliente(String)
    case potenziale(String)
    /// «+ N»: le persone oltre la terza generazione o oltre gli otto presentati per persona.
    case altri(Int)
}

/// Un nodo dell'albero (cliente, potenziale o «+ N»).
struct NodoPassaparola: Identifiable, Hashable {
    let id: String
    let nome: String
    let iniziali: String
    let tipo: TipoNodoPassaparola
    /// Dei clienti.
    let tinta: TintaAvatar?
    /// Il patrimonio netto per i clienti (`RiepilogoPosizioni`), la stima per i potenziali; nil = non noto.
    let patrimonio: Double?
    /// Dei potenziali.
    let fase: FasePotenziale?
    let presentatoIl: Date?
    var figli: [NodoPassaparola]
    /// 1…3 (il «Tu» è lo 0, non è un nodo).
    let livello: Int

    var giaCliente: Bool { if case .cliente = tipo { return true } else { return false } }
}

/// L'albero di chi ha presentato chi.
struct AlberoPassaparola: Equatable {
    let primoLivello: [NodoPassaparola]
    /// «+ 34 clienti senza presentazioni»: i clienti tolti dal primo livello quando è ridotto.
    let senzaPresentazioni: Int
    /// I clienti dove un ciclo («A presenta B e B presenta A») è stato interrotto, da segnalare.
    let ciclo: [String]
    /// L'anno della presentazione più vecchia, per «DAL 2016» (nil senza date).
    let annoPiuVecchio: Int?
    /// Nessun presentatore né potenziale presentato.
    var vuoto: Bool
}

/// Un cliente che ha presentato almeno due persone.
struct Ambasciatore: Identifiable, Equatable {
    /// L'id del cliente.
    let id: String
    let nome: String
    let presentati: Int
    /// Il patrimonio netto dei presentati diventati clienti.
    let portato: Double
    /// Le stime dei potenziali presentati (non ancora clienti). Mai sommato a `portato` (decisione 95).
    let inArrivo: Double
}

/// Una persona presentata, nella card «Il ramo di» (Migliorie d'uso 48).
struct PresentatoRamo: Identifiable, Equatable {
    /// "c-\(clienteId)" o "p-\(potenzialeId)", come i nodi dell'albero.
    let id: String
    let nome: String
    /// Già cliente (capsula «Cliente») o ancora potenziale (capsula «Potenziale» con la fase).
    let giaCliente: Bool
    let fase: FasePotenziale?
    /// Il patrimonio netto per i clienti, la stima per i potenziali; nil = non noto («—»).
    let cifra: Double?
}

/// Il ramo di una persona scelta nell'albero del passaparola (Migliorie d'uso 48): chi ha presentato, con il valore dei
/// già clienti separato dalle stime dei potenziali (decisione 95: mai sommati).
struct RamoPassaparola: Equatable {
    let clienteId: String
    let nome: String
    let iniziali: String
    let tinta: TintaAvatar
    /// Prima i già clienti, poi i potenziali, ognuno dal più vecchio.
    let presentati: [PresentatoRamo]

    var clienti: Int { presentati.filter(\.giaCliente).count }
    var potenziali: Int { presentati.count - clienti }
    /// Σ dei patrimoni netti dei già clienti (lo stesso `portato` di `Ambasciatore`).
    var valoreClienti: Double { presentati.filter(\.giaCliente).reduce(0) { $0 + max(0, $1.cifra ?? 0) } }
}

/// Il momento giusto per chiedere una presentazione (decisione 17).
struct MomentoPerChiedere: Identifiable, Equatable {
    /// "\(clienteId)-\(riferimento)".
    let id: String
    let clienteId: String
    /// Un fatto, mai uno stato d'animo: «ha raggiunto «Rendita integrativa» ieri», «ha firmato «Piano Futuro» martedì».
    let fatto: String
    /// L'id del traguardo o della posizione (per l'occasione del messaggio).
    let riferimento: String
    let data: Date
}

/// La quota del patrimonio nuovo nata dal passaparola.
struct QuotaPassaparola: Equatable {
    /// 0…1.
    let quota: Double
    /// I clienti contati (iniziati negli ultimi anni).
    let contati: Int
    /// Quanti contati solo con la data della scheda (`creatoIl`): > 0 → la nota sui dati.
    let senzaDataVera: Int
}

/// Le soglie del passaparola, tutte in un punto.
enum RegolePassaparola {
    /// Decisione 17: il fatto negli ultimi 7 giorni.
    static let giorniMomento = 7
    /// Decisione 17: nessuna richiesta di presentazione negli ultimi 180 giorni.
    static let giorniRichiesta = 180
    static let minimoAmbasciatore = 2
    /// Decisione 95: tre generazioni, poi «+ N».
    static let generazioni = 3
    /// Oltre tanti presentati per persona: «+ N».
    static let massimoFigli = 8
    /// La colonna «Cliente» mostra i diventati clienti negli ultimi 12 mesi.
    static let mesiColonnaCliente = 12
    static let anniQuota = 3
    static let anniColonne = 5
    /// Oltre tanti clienti al primo livello, restano solo quelli che hanno presentato qualcuno.
    static let massimoPrimoLivelloPieno = 12
    /// Migliorie d'uso 47: un potenziale è «fermo» oltre tanti giorni nella stessa fase.
    static let giorniFermo = 14
}

/// L'azione del prossimo passo di un potenziale (Migliorie d'uso 47): il primo pulsante del dettaglio.
enum AzionePotenziale: Equatable {
    case chiama
    case scrivi
    case fissaIncontro
    case preparaIncontro(appuntamentoId: String)
}

/// Il prossimo passo di un potenziale, ricavato dal codice (decisione 47-a: nessun campo nuovo) da fase, storia, fonte,
/// recapiti e agenda, con i giorni passati nella fase di oggi.
struct PassoPotenziale: Equatable {
    /// Vuoto per i non interessati (nessun passo).
    let testo: String
    let azione: AzionePotenziale?
    /// Giorni di calendario dall'ultimo cambio di fase (o dall'inserimento).
    let giorniFermo: Int
    /// Oltre `RegolePassaparola.giorniFermo`, solo nelle prime quattro colonne.
    let fermo: Bool
}

enum MotorePassaparola {
    private static let gregoriano = Calendar(identifier: .gregorian)

    // MARK: - Percorso e totali

    /// Le cinque colonne del percorso (dalla più vecchia). «Cliente»: solo chi lo è diventato negli ultimi 12 mesi.
    /// I non interessati non compaiono.
    static func percorso(_ potenziali: [PotenzialeCliente], oggi: Date,
                         cal: Calendar = .current) -> [FasePotenziale: [PotenzialeCliente]] {
        var r: [FasePotenziale: [PotenzialeCliente]] = [:]
        for f in FasePotenziale.colonne { r[f] = [] }
        let limite = cal.date(byAdding: .month, value: -RegolePassaparola.mesiColonnaCliente, to: oggi) ?? oggi
        for p in potenziali.sorted(by: { a, b in a.creatoIl != b.creatoIl ? a.creatoIl < b.creatoIl : a.id < b.id }) {
            switch p.fase {
            case .nonInteressato: continue
            case .cliente:
                guard (diventatoCliente(p) ?? p.creatoIl) >= limite else { continue }
                r[.cliente, default: []].append(p)
            default:
                r[p.fase, default: []].append(p)
            }
        }
        return r
    }

    /// Quando è passato in «Cliente» (dalla storia).
    static func diventatoCliente(_ p: PotenzialeCliente) -> Date? {
        p.storia.last(where: { $0.fase == .cliente })?.il
    }

    /// Le tile: le prime quattro colonne. Il probabile conta solo chi ha stima, probabilità e chiusura entro il 31/12.
    static func totali(_ potenziali: [PotenzialeCliente], clienti: [Cliente], oggi: Date,
                       cal: Calendar = .current) -> TotaliPotenziali {
        let aperti = potenziali.filter { $0.fase != .cliente && $0.fase != .nonInteressato }
        let ids = Set(clienti.map(\.id))
        let anno = cal.component(.year, from: oggi)
        let fineAnno = cal.date(from: DateComponents(year: anno + 1, month: 1, day: 1)) ?? oggi
        var stimato = 0.0, senza = 0, passaparola = 0, probabile = 0.0, esclusi = 0
        for p in aperti {
            if let s = p.patrimonioStimato { stimato += s } else { senza += 1 }
            if let da = p.presentatoDa, ids.contains(da) { passaparola += 1 }
            if let s = p.patrimonioStimato, let pr = p.probabilita, let c = p.chiusuraPrevista, c < fineAnno {
                probabile += s * Double(pr) / 100
            } else {
                esclusi += 1
            }
        }
        return TotaliPotenziali(conteggio: aperti.count, patrimonioStimato: stimato, senzaStima: senza, dalPassaparola: passaparola,
                                probabileEntroAnno: probabile, esclusiDalProbabile: esclusi)
    }

    // MARK: - Il prossimo passo (Migliorie d'uso 47)

    /// Giorni di calendario da `storia.last?.il ?? creatoIl` a oggi (mai negativi).
    static func giorniFermo(_ p: PotenzialeCliente, oggi: Date, cal: Calendar = .current) -> Int {
        let da = cal.startOfDay(for: p.storia.last?.il ?? p.creatoIl)
        let a = cal.startOfDay(for: oggi)
        return max(0, cal.dateComponents([.day], from: da, to: a).day ?? 0)
    }

    /// Come si contatta: con il telefono si chiama; senza, si scrive se informativa e consenso ci sono; altrimenti nulla.
    static func azioneContatto(_ p: PotenzialeCliente) -> AzionePotenziale? {
        if !p.telefono.trimmingCharacters(in: .whitespaces).isEmpty { return .chiama }
        if p.contattabile { return .scrivi }
        return nil
    }

    /// Il prossimo passo di un potenziale (regole in Design/uso/gruppo-08.md §47.3 punto 1, testi in TestiPassaparola).
    /// `presentatore`: il nome del cliente che l'ha presentato (nil = nessuno); `primoIncontro`: l'appuntamento futuro
    /// del primo incontro (`primiIncontri`).
    static func prossimoPasso(_ p: PotenzialeCliente, presentatore: String?, primoIncontro: Appuntamento?, oggi: Date,
                              cal: Calendar = .current) -> PassoPotenziale {
        let giorni = giorniFermo(p, oggi: oggi, cal: cal)
        let aperto = p.fase != .cliente && p.fase != .nonInteressato
        let fermo = aperto && giorni > RegolePassaparola.giorniFermo
        let contatto = azioneContatto(p)
        let testo: String
        let azione: AzionePotenziale?
        switch p.fase {
        case .daContattare:
            azione = contatto
            testo = TestiPassaparola.passoDaContattare(p, presentatore: presentatore, azione: contatto)
        case .primoIncontro:
            if let a = primoIncontro, a.inizio >= oggi {
                azione = .preparaIncontro(appuntamentoId: a.id)
                testo = TestiPassaparola.passoIncontroFissato(a.inizio)
            } else {
                azione = .fissaIncontro
                testo = TestiPassaparola.passoFissaIncontro
            }
        case .analisi:
            azione = contatto
            testo = TestiPassaparola.passoAnalisi
        case .proposta:
            azione = contatto
            testo = TestiPassaparola.passoProposta
        case .cliente:
            azione = nil
            testo = TestiPassaparola.passoCliente
        case .nonInteressato:
            azione = nil
            testo = ""
        }
        return PassoPotenziale(testo: testo, azione: azione, giorniFermo: giorni, fermo: fermo)
    }

    /// Gli appuntamenti futuri del primo incontro, per potenziale (decisione 47-d: riconosciuti dal tipo e dal titolo
    /// «Primo incontro · {nome}» che scrive `fissaPrimoIncontro`, nessun campo nuovo). Il più vicino per ciascuno.
    static func primiIncontri(_ potenziali: [PotenzialeCliente], appuntamenti: [Appuntamento],
                              oggi: Date) -> [String: Appuntamento] {
        var perTitolo: [String: Appuntamento] = [:]
        for a in appuntamenti where a.tipo == .primoIncontro && a.stato == .pianificato && a.inizio >= oggi {
            if let b = perTitolo[a.titolo], b.inizio <= a.inizio { continue }
            perTitolo[a.titolo] = a
        }
        guard !perTitolo.isEmpty else { return [:] }
        var r: [String: Appuntamento] = [:]
        for p in potenziali where p.fase == .primoIncontro {
            if let a = perTitolo[TestiPassaparola.titoloPrimoIncontro(p.nome)] { r[p.id] = a }
        }
        return r
    }

    /// I passi di tutti i potenziali (id → passo), in una volta sola: la vista lo tiene con `stato.ricavato`.
    static func passi(_ potenziali: [PotenzialeCliente], clienti: [Cliente], appuntamenti: [Appuntamento], oggi: Date,
                      cal: Calendar = .current) -> [String: PassoPotenziale] {
        var nomi: [String: String] = [:]
        for c in clienti where nomi[c.id] == nil { nomi[c.id] = c.nome }
        let incontri = primiIncontri(potenziali, appuntamenti: appuntamenti, oggi: oggi)
        var r: [String: PassoPotenziale] = [:]
        for p in potenziali {
            r[p.id] = prossimoPasso(p, presentatore: p.presentatoDa.flatMap { nomi[$0] }, primoIncontro: incontri[p.id],
                                    oggi: oggi, cal: cal)
        }
        return r
    }

    /// Quanti potenziali delle prime quattro colonne sono fermi (la quarta tile).
    static func fermi(_ potenziali: [PotenzialeCliente], passi: [String: PassoPotenziale]) -> Int {
        potenziali.filter { $0.fase != .cliente && $0.fase != .nonInteressato && passi[$0.id]?.fermo == true }.count
    }

    // MARK: - Albero

    /// L'albero di chi ha presentato chi. Primo livello: i clienti senza presentatore (o con un presentatore non più in
    /// archivio); poi i presentati (clienti e potenziali) fino alla terza generazione, oltre «+ N»; al più otto per
    /// persona, oltre «+ N». Un ciclo si interrompe e si segnala. `netti`: i patrimoni già calcolati (`patrimoni`), per
    /// non rifarli quando la vista chiede anche ambasciatori e quota.
    static func albero(clienti: [Cliente], potenziali: [PotenzialeCliente], posizioni: [Posizione],
                       netti: [String: Double]? = nil) -> AlberoPassaparola {
        var perId: [String: Cliente] = [:]
        for c in clienti where perId[c.id] == nil { perId[c.id] = c }
        let netti = netti ?? patrimoni(posizioni)
        // I presentati di ognuno: clienti e potenziali (non quelli già diventati clienti presenti, non i non interessati)
        var figliClienti: [String: [Cliente]] = [:]
        for c in clienti {
            guard let da = c.presentatoDa, da != c.id, perId[da] != nil else { continue }
            figliClienti[da, default: []].append(c)
        }
        var figliPotenziali: [String: [PotenzialeCliente]] = [:]
        for p in potenziali where p.fase != .nonInteressato {
            if let cid = p.clienteId, perId[cid] != nil { continue }
            guard let da = p.presentatoDa, perId[da] != nil else { continue }
            figliPotenziali[da, default: []].append(p)
        }
        func ordina(_ a: [Cliente]) -> [Cliente] {
            a.sorted { x, y in
                let dx = x.presentatoIl ?? x.creatoIl, dy = y.presentatoIl ?? y.creatoIl
                return dx != dy ? dx < dy : x.id < y.id
            }
        }
        var visti = Set<String>()
        var ciclo: [String] = []

        func discendenti(_ id: String, _ dentro: inout Set<String>) -> Int {
            var n = 0
            for c in figliClienti[id] ?? [] where !dentro.contains(c.id) {
                dentro.insert(c.id)
                n += 1 + discendenti(c.id, &dentro)
            }
            n += (figliPotenziali[id] ?? []).count
            return n
        }

        func nodo(_ c: Cliente, livello: Int) -> NodoPassaparola {
            visti.insert(c.id)
            var figli: [NodoPassaparola] = []
            let clientiFigli = ordina(figliClienti[c.id] ?? []).filter { f in
                if visti.contains(f.id) {
                    if !ciclo.contains(f.id) { ciclo.append(f.id) }
                    return false
                }
                return true
            }
            let potenzialiFigli = (figliPotenziali[c.id] ?? []).sorted { $0.creatoIl != $1.creatoIl ? $0.creatoIl < $1.creatoIl : $0.id < $1.id }
            let totale = clientiFigli.count + potenzialiFigli.count
            if livello >= RegolePassaparola.generazioni {
                if totale > 0 {
                    var dentro = visti
                    var n = 0
                    for f in clientiFigli where !dentro.contains(f.id) {
                        dentro.insert(f.id)
                        n += 1 + discendenti(f.id, &dentro)
                    }
                    n += potenzialiFigli.count
                    // I discendenti contati nel «+ N» restano visti: non ricompaiono come radici
                    visti.formUnion(dentro)
                    figli.append(altri(n, padre: c.id, livello: livello + 1))
                }
            } else {
                var posti = RegolePassaparola.massimoFigli
                var restanti = 0
                for f in clientiFigli {
                    if visti.contains(f.id) { continue }
                    if posti > 0 {
                        figli.append(nodo(f, livello: livello + 1))
                        posti -= 1
                    } else {
                        var dentro = visti
                        dentro.insert(f.id)
                        restanti += 1 + discendenti(f.id, &dentro)
                        visti.formUnion(dentro)
                    }
                }
                for p in potenzialiFigli {
                    if posti > 0 {
                        figli.append(nodoPotenziale(p, livello: livello + 1))
                        posti -= 1
                    } else {
                        restanti += 1
                    }
                }
                if restanti > 0 { figli.append(altri(restanti, padre: c.id, livello: livello + 1)) }
            }
            return NodoPassaparola(id: "c-\(c.id)", nome: c.nome, iniziali: c.iniziali, tipo: .cliente(c.id), tinta: c.tinta,
                                   patrimonio: netti[c.id], fase: nil, presentatoIl: c.presentatoIl, figli: figli, livello: livello)
        }

        var radici: [NodoPassaparola] = []
        let senzaPresentatore = ordina(clienti.filter { c in
            guard let da = c.presentatoDa, da != c.id else { return true }
            return perId[da] == nil
        })
        for c in senzaPresentatore where !visti.contains(c.id) { radici.append(nodo(c, livello: 1)) }
        // Chi resta non visto è in un ciclo (o discende da uno): si interrompe al primo, che va al primo livello
        for c in clienti.sorted(by: { $0.id < $1.id }) where !visti.contains(c.id) {
            if !ciclo.contains(c.id) { ciclo.append(c.id) }
            radici.append(nodo(c, livello: 1))
        }
        // Tanti clienti: al primo livello solo chi ha presentato qualcuno
        var senzaPresentazioni = 0
        if radici.count > RegolePassaparola.massimoPrimoLivelloPieno {
            let conFigli = radici.filter { !$0.figli.isEmpty }
            senzaPresentazioni = radici.count - conFigli.count
            radici = conFigli
        }
        // L'anno più vecchio: le presentazioni dei clienti e i potenziali presentati
        let date = clienti.compactMap { c -> Date? in
            guard let da = c.presentatoDa, perId[da] != nil else { return nil }
            return c.presentatoIl
        } + potenziali.filter { p in p.presentatoDa.map { perId[$0] != nil } ?? false }.map(\.creatoIl)
        let anno = date.min().map { gregoriano.component(.year, from: $0) }
        let vuoto = figliClienti.isEmpty && figliPotenziali.isEmpty
        return AlberoPassaparola(primoLivello: radici, senzaPresentazioni: senzaPresentazioni, ciclo: ciclo,
                                 annoPiuVecchio: anno, vuoto: vuoto)
    }

    private static func nodoPotenziale(_ p: PotenzialeCliente, livello: Int) -> NodoPassaparola {
        NodoPassaparola(id: "p-\(p.id)", nome: p.nome, iniziali: Cliente.iniziali(di: p.nome), tipo: .potenziale(p.id), tinta: nil,
                        patrimonio: p.patrimonioStimato, fase: p.fase, presentatoIl: p.creatoIl, figli: [], livello: livello)
    }

    private static func altri(_ n: Int, padre: String, livello: Int) -> NodoPassaparola {
        NodoPassaparola(id: "altri-\(padre)", nome: "+ \(n)", iniziali: "+\(n)", tipo: .altri(n), tinta: nil, patrimonio: nil,
                        fase: nil, presentatoIl: nil, figli: [], livello: livello)
    }

    /// Il patrimonio netto di ogni cliente (posizioni in essere), lo stesso di `RiepilogoPosizioni.patrimonioNetto`, con
    /// una voce (anche 0) per ogni cliente che ha posizioni. Un solo passaggio con le sole due somme: il riepilogo intero
    /// (aree, canali, scadenze con il calendario) qui non serve, e la vista Passaparola lo chiede a ogni body. Le somme
    /// seguono l'ordine delle posizioni, come i `reduce` del riepilogo: stesse cifre.
    static func patrimoni(_ posizioni: [Posizione]) -> [String: Double] {
        var somme: [String: (attivita: Double, debiti: Double)] = [:]
        for p in posizioni {
            var s = somme[p.clienteId] ?? (attivita: 0, debiti: 0)
            if p.stato == .inEssere {
                if p.area.passivo { s.debiti += p.valore } else { s.attivita += p.valore }
            }
            somme[p.clienteId] = s
        }
        return somme.mapValues { $0.attivita - $0.debiti }
    }

    // MARK: - Ambasciatori, quota, anni

    /// Chi ha presentato almeno `minimo` persone, con il patrimonio portato (clienti) e quello in arrivo (stime dei
    /// potenziali), separati. Dal più generoso.
    static func ambasciatori(clienti: [Cliente], potenziali: [PotenzialeCliente], posizioni: [Posizione],
                             minimo: Int = RegolePassaparola.minimoAmbasciatore,
                             netti: [String: Double]? = nil) -> [Ambasciatore] {
        let ids = Set(clienti.map(\.id))
        let netti = netti ?? patrimoni(posizioni)
        // I presentati di ognuno raccolti in un passaggio, nell'ordine dell'archivio (come il filtro per cliente): niente
        // scorrimento di tutti i clienti e potenziali per ogni cliente
        var clientiPer: [String: [Cliente]] = [:]
        for x in clienti {
            guard let da = x.presentatoDa, da != x.id else { continue }
            clientiPer[da, default: []].append(x)
        }
        var potenzialiPer: [String: [PotenzialeCliente]] = [:]
        for p in potenziali where p.fase != .nonInteressato {
            // Già diventato un cliente dell'archivio: non è più «in arrivo»
            if let cid = p.clienteId, ids.contains(cid) { continue }
            guard let da = p.presentatoDa else { continue }
            potenzialiPer[da, default: []].append(p)
        }
        var r: [Ambasciatore] = []
        for c in clienti {
            let presentati = clientiPer[c.id] ?? []
            let inArrivo = potenzialiPer[c.id] ?? []
            let n = presentati.count + inArrivo.count
            guard n >= max(1, minimo) else { continue }
            r.append(Ambasciatore(id: c.id, nome: c.nome, presentati: n,
                                  portato: presentati.reduce(0) { $0 + max(0, netti[$1.id] ?? 0) },
                                  inArrivo: inArrivo.reduce(0) { $0 + ($1.patrimonioStimato ?? 0) }))
        }
        return r.sorted { a, b in
            if a.presentati != b.presentati { return a.presentati > b.presentati }
            if a.portato != b.portato { return a.portato > b.portato }
            return a.id < b.id
        }
    }

    /// Il ramo di un cliente (Migliorie d'uso 48): tutte le persone che ha presentato (non solo quelle disegnate
    /// nell'albero, che si ferma a otto per persona e a tre generazioni), con le stesse regole di `ambasciatori`: i
    /// clienti con «Presentato da», i potenziali non «Non interessato» e non già diventati clienti dell'archivio. nil se
    /// il cliente non c'è.
    static func ramo(di clienteId: String, clienti: [Cliente], potenziali: [PotenzialeCliente],
                     netti: [String: Double]) -> RamoPassaparola? {
        guard let c = clienti.first(where: { $0.id == clienteId }) else { return nil }
        let ids = Set(clienti.map(\.id))
        let presentatiClienti = clienti
            .filter { x in x.presentatoDa == clienteId && x.id != clienteId }
            .sorted { a, b in
                let da = a.presentatoIl ?? a.creatoIl, db = b.presentatoIl ?? b.creatoIl
                return da != db ? da < db : a.id < b.id
            }
            .map { x in PresentatoRamo(id: "c-\(x.id)", nome: x.nome, giaCliente: true, fase: nil, cifra: netti[x.id]) }
        let presentatiPotenziali = potenziali
            .filter { p in
                guard p.presentatoDa == clienteId, p.fase != .nonInteressato else { return false }
                if let cid = p.clienteId, ids.contains(cid) { return false }
                return true
            }
            .sorted { a, b in a.creatoIl != b.creatoIl ? a.creatoIl < b.creatoIl : a.id < b.id }
            .map { p in PresentatoRamo(id: "p-\(p.id)", nome: p.nome, giaCliente: false, fase: p.fase, cifra: p.patrimonioStimato) }
        return RamoPassaparola(clienteId: c.id, nome: c.nome, iniziali: c.iniziali, tinta: c.tinta,
                               presentati: presentatiClienti + presentatiPotenziali)
    }

    /// La data d'inizio del cliente: «Cliente dal» se scritta, altrimenti la data della scheda.
    static func inizio(_ c: Cliente) -> Date { c.clienteDal ?? c.creatoIl }

    /// La quota del patrimonio dei clienti iniziati negli ultimi `anni` anni che viene dal passaparola. nil senza clienti
    /// iniziati in quel tempo o senza patrimonio.
    static func quotaPassaparola(clienti: [Cliente], posizioni: [Posizione], oggi: Date, anni: Int = RegolePassaparola.anniQuota,
                                 cal: Calendar = .current, netti: [String: Double]? = nil) -> QuotaPassaparola? {
        let limite = cal.date(byAdding: .year, value: -anni, to: oggi) ?? oggi
        let nuovi = clienti.filter { inizio($0) >= limite && inizio($0) <= oggi }
        guard !nuovi.isEmpty else { return nil }
        let ids = Set(clienti.map(\.id))
        let netti = netti ?? patrimoni(posizioni)
        let totale = nuovi.reduce(0) { $0 + max(0, netti[$1.id] ?? 0) }
        guard totale > 0 else { return nil }
        let daPassaparola = nuovi.filter { c in c.presentatoDa.map { ids.contains($0) && $0 != c.id } ?? false }
            .reduce(0) { $0 + max(0, netti[$1.id] ?? 0) }
        return QuotaPassaparola(quota: daPassaparola / totale, contati: nuovi.count,
                                senzaDataVera: nuovi.filter { $0.clienteDal == nil }.count)
    }

    /// I clienti nuovi degli ultimi `anni` anni (l'ultimo è quello in corso), quanti dal passaparola.
    static func nuoviPerAnno(clienti: [Cliente], oggi: Date, anni: Int = RegolePassaparola.anniColonne,
                             cal: Calendar = .current) -> [(anno: Int, dalPassaparola: Int, totali: Int)] {
        let ids = Set(clienti.map(\.id))
        let corrente = cal.component(.year, from: oggi)
        let primo = corrente - max(1, anni) + 1
        return (primo...corrente).map { a in
            let delAnno = clienti.filter { cal.component(.year, from: inizio($0)) == a }
            let dal = delAnno.filter { c in c.presentatoDa.map { ids.contains($0) && $0 != c.id } ?? false }.count
            return (anno: a, dalPassaparola: dal, totali: delAnno.count)
        }
    }

    // MARK: - Il momento giusto per chiedere

    /// I clienti con un fatto bello negli ultimi `giorni` giorni (un traguardo, gli anniversari esclusi, o una proposta
    /// accettata), il consenso commerciale valido e nessuna richiesta di presentazione negli ultimi 180 giorni. Uno per
    /// cliente (il più recente); dal più recente.
    static func momentoGiusto(dati: DatiPrisma, oggi: Date, giorni: Int = RegolePassaparola.giorniMomento,
                              cal: Calendar = .current) -> [MomentoPerChiedere] {
        let inizio = cal.date(byAdding: .day, value: -max(0, giorni), to: cal.startOfDay(for: oggi)) ?? oggi
        let fine = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: oggi)) ?? oggi
        func dentro(_ d: Date) -> Bool { d >= inizio && d < fine }
        var candidati: [MomentoPerChiedere] = []
        // I traguardi (MotoreTraguardi), senza gli anniversari (domanda aperta per l'utente)
        for t in MotoreTraguardi.calcola(dati: dati, oggi: oggi, finestraGiorni: giorni, cal: cal) where t.tipo != .anniversario {
            candidati.append(MomentoPerChiedere(id: "\(t.clienteId)-\(t.id)", clienteId: t.clienteId,
                                                fatto: TestiPassaparola.fatto(t, oggi: oggi, cal: cal), riferimento: t.id, data: t.data))
        }
        // Le firme: la proposta accettata con la data dell'esito; senza, la data della pratica aperta (ripiego)
        let pratiche = Dictionary(dati.pratiche.map { ($0.posizioneId, $0) }, uniquingKeysWith: { a, _ in a })
        for p in dati.posizioni where p.esito == .accettata {
            guard let quando = p.seguito?.esitoIl ?? pratiche[p.id]?.apertaIl, dentro(quando) else { continue }
            candidati.append(MomentoPerChiedere(id: "\(p.clienteId)-\(p.id)", clienteId: p.clienteId,
                                                fatto: TestiPassaparola.firma(p.nome, il: quando, oggi: oggi, cal: cal),
                                                riferimento: p.id, data: quando))
        }
        let limiteRichiesta = cal.date(byAdding: .day, value: -RegolePassaparola.giorniRichiesta, to: oggi) ?? oggi
        let chiesti = Set(dati.messaggi.filter { m in
            m.origine.tipo == .richiestaPresentazione && m.stato.copreOccasione && m.dataMostrata >= limiteRichiesta
        }.map(\.clienteId))
        var perCliente: [String: MomentoPerChiedere] = [:]
        for m in candidati {
            guard !chiesti.contains(m.clienteId),
                  let c = dati.clienti.first(where: { $0.id == m.clienteId }),
                  MotoreConformita.commercialeValido(c, regole: dati.impostazioni.conformita, oggi: oggi, calendario: cal) else { continue }
            if let gia = perCliente[m.clienteId], gia.data >= m.data { continue }
            perCliente[m.clienteId] = m
        }
        return perCliente.values.sorted { a, b in a.data != b.data ? a.data > b.data : a.id < b.id }
    }

    // MARK: - Cambi

    /// Il potenziale che avanza o torna indietro (la storia cresce). Non porta mai in «Cliente»: quello passa dal modulo
    /// del cliente nuovo (`StatoShell.confermaClienteDaPotenziale`).
    static func sposta(_ p: PotenzialeCliente, a fase: FasePotenziale, il: Date) -> PotenzialeCliente {
        guard fase != .cliente, fase != p.fase else { return p }
        var q = p
        q.fase = fase
        q.storia.append(CambioFase(fase: fase, il: il))
        return q
    }

    /// Il cliente nuovo dal potenziale: nome, iniziali, recapiti, nota e chi l'ha presentato (con la data in cui il
    /// potenziale è stato inserito, cioè la presentazione). Mai salvato da qui.
    static func clienteDa(_ p: PotenzialeCliente, tinta: TintaAvatar, oggi: Date) -> Cliente {
        var c = Cliente(id: UUID().uuidString, nome: p.nome, iniziali: Cliente.iniziali(di: p.nome), tinta: tinta, tema: "",
                        email: p.email, telefono: p.telefono, preferito: false, nota: p.nota, creatoIl: oggi)
        c.presentatoDa = p.presentatoDa
        c.presentatoIl = p.presentatoDa == nil ? nil : p.creatoIl
        return c
    }

    // MARK: - Dalla carta d'identità (§9.1, stato «È un potenziale cliente»)

    /// Il potenziale con lo stesso nome della carta letta (nome e cognome in qualsiasi ordine, senza accenti né
    /// maiuscole): solo fra quelli non ancora diventati clienti (fuori dalla colonna «Cliente» e senza un dossier che
    /// esiste). Con più omonimi, il più recente. Nessun nome o nessun potenziale: nil (mai un potenziale indovinato).
    static func potenzialeCorrispondente(nome: String?, potenziali: [PotenzialeCliente], clienti: [Cliente]) -> PotenzialeCliente? {
        guard let nome else { return nil }
        let chiave = ImportaPosizioni.piega(nome)
        guard !chiave.isEmpty else { return nil }
        let dossier = Set(clienti.map(\.id))
        return potenziali
            .filter { p in
                guard p.fase != .cliente, ImportaPosizioni.piega(p.nome) == chiave else { return false }
                if let cid = p.clienteId, dossier.contains(cid) { return false }
                return true
            }
            .max { a, b in a.creatoIl != b.creatoIl ? a.creatoIl < b.creatoIl : a.id > b.id }
    }

    /// Due nomi della stessa persona: le parole dell'uno (senza accenti, maiuscole né ordine) stanno tutte nell'altro
    /// («Elena Maria Marchi» e «Marchi Elena» sì, «Elena Marchetti» e «Elena Marchi» no). Un nome vuoto: no.
    static func nomiCompatibili(_ a: String, _ b: String) -> Bool {
        let x = Set(ImportaPosizioni.piega(a).split(separator: " ")), y = Set(ImportaPosizioni.piega(b).split(separator: " "))
        guard !x.isEmpty, !y.isEmpty else { return false }
        return x.isSubset(of: y) || y.isSubset(of: x)
    }

    /// Il cliente nato dalla carta che porta con sé il potenziale: chi l'ha presentato (con la data dell'inserimento,
    /// cioè la presentazione) e i recapiti e la nota scritti dall'utente, solo dove la carta non dice nulla. Il nome
    /// resta quello della carta; senza nome letto, quello del potenziale.
    static func cliente(_ c: Cliente, dalPotenziale p: PotenzialeCliente) -> Cliente {
        var c = c
        if c.nome.trimmingCharacters(in: .whitespaces).isEmpty {
            c.nome = p.nome
            c.iniziali = Cliente.iniziali(di: p.nome)
        }
        c.presentatoDa = p.presentatoDa
        c.presentatoIl = p.presentatoDa == nil ? nil : p.creatoIl
        if c.email.isEmpty { c.email = p.email }
        if c.telefono.isEmpty { c.telefono = p.telefono }
        if c.nota.isEmpty { c.nota = p.nota }
        return c
    }

    /// Il potenziale diventato cliente: fase «Cliente», collegato al dossier, la storia che cresce.
    static func diventato(_ p: PotenzialeCliente, cliente clienteId: String, il: Date) -> PotenzialeCliente {
        var q = p
        q.fase = .cliente
        q.clienteId = clienteId
        q.storia.append(CambioFase(fase: .cliente, il: il))
        return q
    }

    /// L'occasione del grazie per le presentazioni (Migliorie d'uso 48, non commerciale): nessuna cifra, nessun nome delle
    /// persone presentate. Una al giorno per cliente (il riferimento è il giorno).
    static func occasioneRingraziamento(cliente: Cliente, posizioni: [Posizione], oggi: Date,
                                        cal: Calendar = .current) -> OccasioneMessaggio {
        let giorno = cal.startOfDay(for: oggi)
        let riferimento = "grazie-\(Int(giorno.timeIntervalSinceReferenceDate))"
        return OccasioneMessaggio(origine: OrigineMessaggio(tipo: .ringraziamentoPresentazione, riferimento: riferimento),
                                  clienteId: cliente.id,
                                  canale: MotoreOccasioniMessaggi.canaleComune(cliente, posizioni.filter { $0.clienteId == cliente.id }),
                                  gruppo: .oggi, titolo: TestiPassaparola.titoloRingraziamento(cliente.nome),
                                  perche: TestiPassaparola.percheRingraziamento, oggetto: TestiPassaparola.oggettoRingraziamento,
                                  cifre: [], priorita: .media, data: oggi)
    }

    /// L'occasione «richiesta di presentazione» per Messaggi (commerciale): il fatto come sola cifra.
    static func occasioneRichiesta(_ m: MomentoPerChiedere, cliente: Cliente, posizioni: [Posizione]) -> OccasioneMessaggio {
        let fatto = TestiPassaparola.maiuscola(m.fatto)
        return OccasioneMessaggio(origine: OrigineMessaggio(tipo: .richiestaPresentazione, riferimento: m.riferimento),
                                  clienteId: cliente.id,
                                  canale: MotoreOccasioniMessaggi.canaleComune(cliente, posizioni.filter { $0.clienteId == cliente.id }),
                                  gruppo: .oggi, titolo: TestiPassaparola.titoloRichiesta(cliente.nome),
                                  perche: fatto, oggetto: TestiPassaparola.oggettoRichiesta,
                                  cifre: [CifraMessaggio(.traguardo, fatto)], priorita: .media, data: m.data)
    }
}
