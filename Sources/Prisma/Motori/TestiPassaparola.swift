import Foundation

/// Le frasi di Clienti › Potenziali e Passaparola («Luce» giro 12, §9.2), tutte in un punto. Solo fatti: mai uno stato
/// d'animo del cliente, mai cifre inventate.
enum TestiPassaparola {
    // MARK: - Potenziali

    #if os(macOS)
    /// Migliorie d'uso 47: il clic apre la scheda, con il prossimo passo.
    static let notaPercorso = "Tocca una scheda per aprirla: dentro c'è il prossimo passo. Prisma ricorda chi l'ha presentata: quando diventa cliente compare nell'albero del passaparola."
    #else
    static let notaPercorso = "Tocca una scheda per farla avanzare. Prisma ricorda chi l'ha presentata: quando diventa cliente, compare nell'albero del passaparola."
    #endif
    static let notaPercorsoSolaLettura = "Su iPad il percorso si guarda soltanto: le schede si spostano dal Mac."
    static let aggiungi = "Aggiungi un potenziale cliente"
    static let aggiungiBreve = "+ Potenziale"
    static let vuoto = "Nessun potenziale cliente per ora. Quando qualcuno ti viene presentato, o ti contatta, aggiungilo qui: Prisma ricorda chi te l'ha presentato."
    static let stimaDaInserire = "stima da inserire"
    static let informativaDaDare = "informativa da dare"
    static let datiDiProva = "dati di prova"
    static let nonInteressati = "Non interessati"
    static let tilePotenziali = "Potenziali clienti"
    static let tilePatrimonio = "Patrimonio stimato"
    static let tilePassaparola = "Dal passaparola"
    static let tileProbabile = "Probabile entro fine anno"

    /// «presentato da Marco» (il primo nome del cliente) o la fonte libera («dal sito dello studio»).
    static func fonte(_ p: PotenzialeCliente, clienti: [Cliente]) -> String? {
        if let da = p.presentatoDa, let c = clienti.first(where: { $0.id == da }) {
            return "presentato da " + TestiTraguardi.primoNome(c.nome)
        }
        return p.fonte
    }

    /// La scena del nuovo cliente (§9.1, «È un potenziale cliente»): «Elena Marchi è tra i potenziali, presentata da
    /// Sofia». Il genere viene dalla carta (sesso o codice fiscale); se non si sa, «su presentazione di Sofia». Senza un
    /// presentatore cliente, la fonte libera tra parentesi.
    static func traIPotenziali(_ p: PotenzialeCliente, nome: String? = nil, clienti: [Cliente], femminile: Bool?) -> String {
        let chi = (nome?.isEmpty == false ? nome : nil) ?? p.nome
        if let da = p.presentatoDa, let c = clienti.first(where: { $0.id == da }) {
            let primo = TestiTraguardi.primoNome(c.nome)
            switch femminile {
            case .some(true): return "\(chi) è tra i potenziali, presentata da \(primo)"
            case .some(false): return "\(chi) è tra i potenziali, presentato da \(primo)"
            case .none: return "\(chi) è tra i potenziali, su presentazione di \(primo)"
            }
        }
        if let f = p.fonte { return "\(chi) è tra i potenziali (\(f))" }
        return "\(chi) è tra i potenziali"
    }

    /// La nota sotto la frase: prima della lettura (aperta da «Diventa cliente») e a lettura finita.
    static let notaPotenzialeAttesa = "Inquadra la sua carta d’identità o scrivi a mano: il dossier ricorderà la presentazione."
    static let notaPotenzialeLetto = "Con «Crea il dossier» la scheda passa in «Cliente» ed entra nell’albero del passaparola."

    /// «2 senza stima».
    static func senzaStima(_ n: Int) -> String { "\(n) senza stima" }

    /// «3 senza data» (fuori dal probabile).
    static func esclusi(_ n: Int) -> String { n == 1 ? "1 senza tutti i dati" : "\(n) senza tutti i dati" }

    /// «45%» o «—».
    static func probabilita(_ p: Int?) -> String { p.map { "\($0)%" } ?? "—" }

    static func stima(_ s: Double?) -> String { s.map { Formati.euro($0) } ?? stimaDaInserire }

    /// Il toast all'arrivo di un nuovo cliente dal percorso.
    static func benvenuto(_ nome: String) -> String {
        "Nuovo cliente: \(TestiTraguardi.primoNome(nome)) entra nel passaparola"
    }

    static func avanzato(_ nome: String, _ fase: FasePotenziale) -> String {
        "\(TestiTraguardi.primoNome(nome)): \(fase.titolo.lowercased())"
    }

    static let scrivigliNonPronto = "Per scrivergli servono l'informativa data e il consenso a essere contattato."
    static let primoIncontroFissato = "Primo incontro fissato in Agenda"
    static let agendaPiena = "Nessuno spazio libero nelle prossime settimane: fissalo a mano in Agenda."

    // MARK: - Il prossimo passo (Migliorie d'uso 47)

    static let tileFermi = "Fermi da più di due settimane"

    /// La nota della tile del patrimonio (decisione 47-b): il probabile entro fine anno non sparisce.
    static func diCuiProbabile(_ euro: Double) -> String { "di cui probabile entro fine anno: " + Formati.euro(euro) }

    /// Il titolo dell'appuntamento del primo incontro (lo scrive `fissaPrimoIncontro`, lo riconosce il prossimo passo).
    static func titoloPrimoIncontro(_ nome: String) -> String { "Primo incontro · \(nome)" }

    /// «Da contattare»: chi l'ha presentato, la fonte o «Decidi come contattarlo»; senza informativa, prima quella.
    static func passoDaContattare(_ p: PotenzialeCliente, presentatore: String?, azione: AzionePotenziale?) -> String {
        if p.informativaIl == nil {
            return azione == .chiama ? "Prima dagli l'informativa: poi chiamalo" : "Prima dagli l'informativa: poi contattalo"
        }
        if let presentatore {
            let chi = TestiTraguardi.primoNome(presentatore)
            switch azione {
            case .some(.chiama): return "Chiamalo: te l'ha presentato \(chi)"
            case .some(.scrivi): return "Scrivigli: te l'ha presentato \(chi)"
            default: return "Contattalo: te l'ha presentato \(chi)"
            }
        }
        if let f = p.fonte?.trimmingCharacters(in: .whitespaces), !f.isEmpty {
            return "Rispondi: arriva " + daFonte(f)
        }
        return "Decidi come contattarlo"
    }

    /// «dal sito dello studio» resta com'è; «evento in Comune» diventa «da «evento in Comune»».
    static func daFonte(_ f: String) -> String {
        let prima = f.lowercased().split(separator: " ").first.map(String.init) ?? ""
        let preposizioni: Set<String> = ["da", "dal", "dalla", "dallo", "dai", "dagli", "dalle"]
        if preposizioni.contains(prima) || prima.hasPrefix("dall'") || prima.hasPrefix("dall’") { return f }
        return "da «\(f)»"
    }

    private static let giornoIncontro = Formati.formato("EEEE d")

    /// «Primo incontro giovedì 5 alle 18:00».
    static func passoIncontroFissato(_ inizio: Date) -> String {
        "Primo incontro " + giornoIncontro.string(from: inizio) + " alle " + Formati.ora.string(from: inizio)
    }

    static let passoFissaIncontro = "Fissa la data del primo incontro"
    static let passoAnalisi = "Raccogli i dati per l'analisi"
    static let passoProposta = "Ha la proposta in mano: senti cosa ne pensa"
    static let passoCliente = "Cliente: è nell'albero del passaparola"

    /// «fermo da 3 giorni», «fermo da 1 giorno», «fermo da oggi».
    static func fermoDa(_ giorni: Int) -> String {
        switch giorni {
        case ..<1: return "fermo da oggi"
        case 1: return "fermo da 1 giorno"
        default: return "fermo da \(giorni) giorni"
        }
    }

    /// Il valore della tile «Fermo da» del dettaglio: «3 giorni», «1 giorno», «oggi».
    static func valoreFermo(_ n: Int) -> String {
        switch n {
        case ..<1: return "oggi"
        case 1: return "1 giorno"
        default: return "\(n) giorni"
        }
    }

    /// «in «Analisi»».
    static func inFase(_ f: FasePotenziale) -> String { "in «\(f.titolo)»" }

    /// Il pulsante primario del dettaglio, secondo l'azione del passo.
    static func pulsantePasso(_ a: AzionePotenziale) -> String {
        switch a {
        case .chiama: return "Chiama"
        case .scrivi: return "Scrivi"
        case .fissaIncontro: return "Fissa l'incontro"
        case .preparaIncontro: return "Prepara l'incontro"
        }
    }

    /// «Passa a «Analisi»».
    static func passaA(_ f: FasePotenziale) -> String { "Passa a «\(f.titolo)»" }

    /// La nota sotto le colonne dopo uno spostamento (il nome in neretto sta a parte).
    static func passatoA(_ f: FasePotenziale) -> String { "è passato a «\(f.titolo)»." }

    /// L'avviso di «Non interessato».
    static func toltoDaiPotenziali(_ nome: String) -> String { "\(nome) tolto dai potenziali: resta in archivio" }

    static let passoTitolo = "Il prossimo passo"
    static let tileFatto = "Fatto"
    static let fattoCliente = "Ora è un cliente: lo trovi tra i clienti e nell'albero del passaparola."
    static let cheDiventiCliente = "che diventi cliente"
    static let nessunPasso = "Nessun passo: non è interessato. Con «Ripristina» torna in «Da contattare»."
    static let nessunContatto = "Scrivi un telefono, o l'informativa e il consenso, con «Modifica…»."
    static let copiaNumero = "Copia il numero"
    static let numeroCopiato = "Numero copiato"
    static let notaChiama = "Prisma non chiama: componi il numero dal telefono."

    // MARK: - Albero

    /// «CHI TI HA PRESENTATO CHI · DAL 2016» (senza date solo «Chi ti ha presentato chi»).
    static func etichettaAlbero(anno: Int?) -> String {
        anno.map { "CHI TI HA PRESENTATO CHI · DAL \($0)" } ?? "CHI TI HA PRESENTATO CHI"
    }

    #if os(macOS)
    /// Migliorie d'uso 48: toccare una persona accende il suo ramo.
    static let notaAlbero = "La grandezza di ogni cerchio è il patrimonio. Le persone in grigio sono ancora potenziali clienti. Tocca una persona per vedere il suo ramo."
    #else
    static let notaAlbero = "La grandezza di ogni cerchio è il patrimonio. Le persone in grigio sono ancora potenziali clienti."
    #endif
    static let vuotoAlbero = "Nessuna presentazione registrata per ora. Quando un cliente te ne presenta un altro, scrivilo nel suo dossier («Presentato da»): qui nasce l'albero."
    static let tu = "Tu"

    /// «+ 34 clienti senza presentazioni».
    static func senzaPresentazioni(_ n: Int) -> String {
        n == 1 ? "+ 1 cliente senza presentazioni" : "+ \(n) clienti senza presentazioni"
    }

    /// Il ciclo interrotto («A presenta B e B presenta A»).
    static func ciclo(_ nomi: [String]) -> String {
        "Presentazioni in cerchio interrotte: " + nomi.joined(separator: ", ") + ". Controlla «Presentato da» nei loro dossier."
    }

    /// «320.000 € · potenziale», «180.000 €», «—».
    static func cifraNodo(_ n: NodoPassaparola) -> String {
        let cifra = n.patrimonio.map { Formati.euro($0) } ?? "—"
        if case .potenziale = n.tipo { return cifra + " · potenziale" }
        return cifra
    }

    /// Il suggerimento al passaggio: nome, fase, patrimonio o stima, data della presentazione.
    static func suggerimento(_ n: NodoPassaparola) -> String {
        var parti = [n.nome]
        switch n.tipo {
        case .cliente: parti.append("cliente")
        case .potenziale: parti.append(n.fase.map { "potenziale · " + $0.titolo.lowercased() } ?? "potenziale")
        case .tu, .altri: break
        }
        if let p = n.patrimonio { parti.append(Formati.euro(p)) }
        if let d = n.presentatoIl { parti.append("presentato il " + Formati.dataEstesa.string(from: d)) }
        return parti.joined(separator: " · ")
    }

    // MARK: - Ambasciatori e quota

    static let ambasciatori = "I tuoi ambasciatori"
    static let nessunAmbasciatore = "Nessuno ancora"
    static let portato = "portato"
    static let inArrivo = "in arrivo"

    /// «3 persone presentate».
    static func presentati(_ n: Int) -> String { n == 1 ? "1 persona presentata" : "\(n) persone presentate" }

    /// «Il 38% del patrimonio nuovo degli ultimi tre anni è nato dal passaparola».
    static func quota(_ q: QuotaPassaparola) -> String {
        "Il \(Int((q.quota * 100).rounded()))% del patrimonio nuovo degli ultimi tre anni è nato dal passaparola"
    }

    /// La nota quando alcuni clienti non hanno «Cliente dal».
    static func notaQuota(_ q: QuotaPassaparola) -> String? {
        q.senzaDataVera > 0 ? "calcolato sui clienti con la data d'inizio (per \(q.senzaDataVera) vale la data della scheda)" : nil
    }

    // MARK: - Momento giusto

    static let momentoTitolo = "Il momento giusto per chiedere"
    static let preparaRichiesta = "Prepara la richiesta"
    static let messaggioPronto = "✓ Messaggio pronto"

    static func richiestaPronta(_ nome: String) -> String {
        "Richiesta per \(TestiTraguardi.primoNome(nome)) pronta in Messaggi: la spedisci tu"
    }

    /// Il fatto di un traguardo: «ha raggiunto «Rendita integrativa» ieri».
    static func fatto(_ t: Traguardo, oggi: Date, cal: Calendar) -> String {
        minuscola(t.titolo) + " " + TestiTraguardi.quando(t.data, oggi: oggi, cal: cal)
    }

    /// Il fatto di una firma: «ha firmato «Piano Futuro» ieri».
    static func firma(_ nome: String, il data: Date, oggi: Date, cal: Calendar) -> String {
        "ha firmato «\(nome)» " + TestiTraguardi.quando(data, oggi: oggi, cal: cal)
    }

    static func titoloRichiesta(_ nome: String) -> String { "Chiedere una presentazione a \(TestiTraguardi.primoNome(nome))" }
    static let oggettoRichiesta = "Un grazie"

    // MARK: - Il ramo di una persona (Migliorie d'uso 48)

    static let ramoDi = "Il ramo di"
    static let tutti = "Tutti"
    static let apriDossier = "Apri il dossier"
    static let capsulaCliente = "Cliente"
    static let capsulaPotenziale = "Potenziale"
    static let chiediPresentazione = "Chiedi una presentazione"
    /// Decisione 48-a: senza un fatto bello in corso, niente richiesta.
    static let momentoDaPrisma = "Il momento giusto per chiedere te lo dice Prisma, dopo un fatto bello."
    static let suggerimentoNodo = "Clic: il suo ramo · ⌘-clic: il dossier"

    /// «Ringrazia Sofia».
    static func ringrazia(_ nome: String) -> String { "Ringrazia " + TestiTraguardi.primoNome(nome) }

    /// La frase del ramo: «Ti ha presentato 3 persone: 2 sono già clienti (328.000 €), una è ancora un potenziale.»;
    /// senza clienti «… nessuna è ancora cliente…»; senza presentati «Sofia non ti ha ancora presentato nessuno.».
    /// Il valore è dei soli già clienti: mai sommato alle stime dei potenziali (decisione 95).
    static func ramo(nome: String, clienti: Int, valoreClienti: Double, potenziali: Int) -> String {
        let totale = clienti + potenziali
        guard totale > 0 else { return "\(TestiTraguardi.primoNome(nome)) non ti ha ancora presentato nessuno." }
        var frase = "Ti ha presentato " + (totale == 1 ? "una persona" : "\(totale) persone") + ": "
        switch clienti {
        case 0: frase += "nessuna è ancora cliente"
        case 1: frase += "una è già cliente (\(Formati.euro(valoreClienti)))"
        default: frase += "\(clienti) sono già clienti (\(Formati.euro(valoreClienti)))"
        }
        switch potenziali {
        case 0: break
        case 1: frase += ", una è ancora un potenziale"
        default: frase += ", \(potenziali) sono ancora potenziali"
        }
        return frase + "."
    }

    /// La cifra a destra di un presentato: patrimonio o stima, «—» se non nota.
    static func cifraPresentato(_ p: PresentatoRamo) -> String { p.cifra.map { Formati.euro($0) } ?? "—" }

    static func titoloRingraziamento(_ nome: String) -> String { "Ringraziare \(TestiTraguardi.primoNome(nome)) per le presentazioni" }
    static let percheRingraziamento = "Ti ha presentato delle persone"
    static let oggettoRingraziamento = "Grazie di cuore"

    /// L'avviso dopo «Ringrazia…»: la bozza è in Messaggi, la spedisce il consulente.
    static func ringraziamentoPronto(_ nome: String) -> String {
        "Per \(TestiTraguardi.primoNome(nome)): un grazie per le persone che ti ha presentato. Lo trovi in Messaggi"
    }

    // MARK: - Colonne degli anni

    static let nuoviTitolo = "Nuovi clienti dal passaparola"

    /// «2026: 6 clienti nuovi dal passaparola su 11».
    static func colonnaAnno(anno: Int, dal: Int, totali: Int) -> String {
        "\(anno): \(dal) \(dal == 1 ? "cliente nuovo" : "clienti nuovi") dal passaparola su \(totali)"
    }

    // MARK: - Aiuti

    static func maiuscola(_ s: String) -> String { s.prefix(1).uppercased() + s.dropFirst() }
    static func minuscola(_ s: String) -> String { s.prefix(1).lowercased() + s.dropFirst() }
}
