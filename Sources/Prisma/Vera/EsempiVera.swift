import Foundation

// Migliorie d'uso 27, «Vera dice cosa sa fare» (Design/uso/gruppo-04.md §27): a conversazione vuota, sotto il saluto,
// Vera mostra da una a quattro domande d'esempio in riquadri, ognuna con il suo tipo e il suo scopo. Ogni riquadro
// finisce su uno spunto che Vera riconosce già (`SpuntoVera` o `SpuntoPortafoglio`): nessuna domanda nuova da
// instradare. Motore piccolo e puro, provato in `--prova-vera` (ProvaEsempiVera).

/// I testi della colonna di Vera e degli esempi a conversazione vuota (migliorie d'uso 27).
enum TestiVera {
    static let perRispondereUso = "Per rispondere uso"
    static let inQuestaConversazione = "In questa conversazione"
    static let parliamoDi = "Parliamo di"
    static let puoiChiedermi = "Puoi chiedermi, per esempio"
    static let nonInvento = "Non invento cifre: se un dato manca, te lo dico."
    static let senzaClienti = "Qui non uso i dati dei clienti."
    static let calcoliDiPrisma = "I calcoli di Prisma"
    static let tuaAgenda = "La tua agenda"
    static let tueDomande = "Le tue domande"

    /// «Il dossier di Giulia Rossi», o «I dossier dei tuoi clienti» con «Tutti i clienti».
    static func fonteDossier(_ nome: String?) -> String {
        guard let n = nome, !n.isEmpty else { return "I dossier dei tuoi clienti" }
        return "Il dossier di \(n)"
    }

    /// Il tipo (occhiello) e lo scopo di un riquadro d'esempio. Le prime quattro coppie sono quelle del template.
    static func tipoEsempio(_ tipo: EsempioVera.Tipo) -> (tipo: String, scopo: String) {
        switch tipo {
        case .giornata: return ("La giornata", "Impegni e cose urgenti, in ordine")
        case .clienteInBreve: return ("Il cliente in breve", "Chi è, cosa ha, cosa manca")
        case .spiegazione: return ("Una spiegazione", "Con le sue cifre, in parole semplici")
        case .scenario: return ("Uno scenario", "Cosa cambia, con i calcoli di Prisma")
        case .portafoglioInBreve: return ("Il portafoglio in breve", "Chi segui, cosa hanno, come è diviso")
        case .chiSentire: return ("Chi sentire", "I clienti da richiamare, in ordine")
        }
    }
}

/// Una domanda d'esempio: il tipo, la domanda e lo spunto che Vera riconosce (del cliente o del portafoglio, mai tutti
/// e due).
struct EsempioVera: Equatable, Identifiable {
    enum Tipo: String, CaseIterable {
        case giornata, clienteInBreve, spiegazione, scenario, portafoglioInBreve, chiSentire
    }

    let tipo: Tipo
    /// Lo spunto del cliente (conversazione del cliente, `chiediVera`).
    let spunto: SpuntoVera?
    /// Lo spunto del portafoglio (conversazione di tutti i clienti, `chiediVeraPortafoglio`).
    let spuntoPortafoglio: SpuntoPortafoglio?

    var id: String { tipo.rawValue }
    /// La domanda è quella dello spunto, così Vera la riconosce com'è scritta.
    var domanda: String { spunto?.domanda ?? spuntoPortafoglio?.domanda ?? "" }
    /// true se la domanda va nella conversazione del portafoglio.
    var delPortafoglio: Bool { spuntoPortafoglio != nil }

    init(_ tipo: Tipo, spunto: SpuntoVera) {
        self.tipo = tipo
        self.spunto = spunto
        self.spuntoPortafoglio = nil
    }

    init(_ tipo: Tipo, portafoglio: SpuntoPortafoglio) {
        self.tipo = tipo
        self.spunto = nil
        self.spuntoPortafoglio = portafoglio
    }
}

enum EsempiVera {
    /// Le righe di «Per rispondere uso»: ciò che Vera legge davvero. In lavoro la scheda del cliente
    /// (`ContestoVera.scheda`, che porta anche gli impegni in agenda) o quella del portafoglio (`MotorePortafoglio`,
    /// che legge appuntamenti e incontri) e le cifre dei motori di Prisma. In conversazione i dati dei clienti non
    /// entrano (Vera/Istruzioni/conversazione.md): solo le domande.
    static func fonti(nomeCliente: String?, conversazione: Bool) -> [String] {
        if conversazione { return [TestiVera.tueDomande] }
        return [TestiVera.fonteDossier(nomeCliente), TestiVera.calcoliDiPrisma, TestiVera.tuaAgenda]
    }

    /// Quanto serve sapere del cliente per scegliere gli esempi: niente cifre, solo cosa ha.
    struct Profilo: Equatable {
        var haPosizioni = false
        var haPrevidenza = false
        var haInvestimenti = false

        init(haPosizioni: Bool = false, haPrevidenza: Bool = false, haInvestimenti: Bool = false) {
            self.haPosizioni = haPosizioni
            self.haPrevidenza = haPrevidenza
            self.haInvestimenti = haInvestimenti
        }

        /// Dalle posizioni in essere del cliente (le proposte non contano).
        init(posizioni: [Posizione]) {
            let inEssere = posizioni.filter { $0.stato == .inEssere }
            haPosizioni = !inEssere.isEmpty
            haPrevidenza = inEssere.contains { $0.area == .previdenza }
            haInvestimenti = inEssere.contains { $0.area == .investimento }
        }
    }

    /// Gli esempi per il cliente scelto (con il suo profilo) o, con `portafoglio`, per tutti i clienti: da uno a
    /// quattro, mai due dello stesso tipo. Con un cliente scelto nessun esempio va nella conversazione del portafoglio.
    /// «La giornata» («Cosa ho oggi?») non c'è con un cliente scelto: «Cosa ho questa settimana?» è uno spunto del
    /// portafoglio e porterebbe la domanda fuori dal dossier (Design/uso/resta-da-fare.md, 27).
    static func per(cliente: Profilo?, portafoglio: Bool) -> [EsempioVera] {
        if portafoglio || cliente == nil {
            return [
                EsempioVera(.giornata, portafoglio: .settimana),
                EsempioVera(.chiSentire, portafoglio: .ricontattare),
                EsempioVera(.spiegazione, portafoglio: .scadenze),
                EsempioVera(.portafoglioInBreve, portafoglio: .quadro),
            ]
        }
        let p = cliente ?? Profilo()
        var esempi = [EsempioVera(.clienteInBreve, spunto: .riepilogo)]
        // La spiegazione su ciò che il cliente ha: il piano pensione se c'è, altrimenti dove è scoperto
        esempi.append(EsempioVera(.spiegazione, spunto: p.haPrevidenza ? .pensione : .protezione))
        // Lo scenario solo se c'è qualcosa da far cambiare: il crollo dei mercati sugli investimenti, altrimenti
        // restare o cambiare sulle posizioni che ha
        if p.haInvestimenti {
            esempi.append(EsempioVera(.scenario, spunto: .resistenza))
        } else if p.haPosizioni {
            esempi.append(EsempioVera(.scenario, spunto: .cambiare))
        }
        return esempi
    }
}

/// La prova degli esempi di Vera (`--prova-vera`): ogni riquadro porta a uno spunto che Vera riconosce dalla domanda
/// scritta così, da uno a quattro esempi, mai due dello stesso tipo, e con un cliente scelto nessuno va nella
/// conversazione del portafoglio. Le fonti in conversazione non parlano dei dossier.
enum ProvaEsempiVera {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        let profili: [(String, EsempiVera.Profilo)] = [
            ("senza posizioni", EsempiVera.Profilo()),
            ("con posizioni", EsempiVera.Profilo(haPosizioni: true)),
            ("con previdenza", EsempiVera.Profilo(haPosizioni: true, haPrevidenza: true)),
            ("con investimenti", EsempiVera.Profilo(haPosizioni: true, haInvestimenti: true)),
            ("con tutto", EsempiVera.Profilo(haPosizioni: true, haPrevidenza: true, haInvestimenti: true)),
        ]
        var casi: [(String, [EsempioVera], Bool)] = profili.map { ("cliente \($0.0)", EsempiVera.per(cliente: $0.1, portafoglio: false), false) }
        casi.append(("tutti i clienti", EsempiVera.per(cliente: nil, portafoglio: true), true))
        for (nome, esempi, portafoglio) in casi {
            controlla((1...4).contains(esempi.count), "Esempi di Vera (\(nome)): da uno a quattro (\(esempi.count))")
            controlla(Set(esempi.map(\.tipo)).count == esempi.count, "Esempi di Vera (\(nome)): mai due dello stesso tipo")
            let riconosciuti = esempi.allSatisfy { e in
                if let s = e.spuntoPortafoglio { return e.spunto == nil && SpuntoPortafoglio.da(e.domanda) == s }
                if let s = e.spunto { return SpuntoVera.da(e.domanda) == s }
                return false
            }
            controlla(riconosciuti, "Esempi di Vera (\(nome)): ogni domanda porta allo spunto che Vera riconosce")
            if portafoglio {
                controlla(esempi.allSatisfy(\.delPortafoglio), "Esempi di Vera (tutti i clienti): tutti nella conversazione del portafoglio")
            } else {
                controlla(!esempi.contains(where: \.delPortafoglio), "Esempi di Vera (\(nome)): nessuno nella conversazione del portafoglio")
            }
            controlla(esempi.allSatisfy { !TestiVera.tipoEsempio($0.tipo).tipo.isEmpty && !$0.domanda.isEmpty },
                      "Esempi di Vera (\(nome)): ogni riquadro ha tipo e domanda")
        }
        let lavoro = EsempiVera.fonti(nomeCliente: "Giulia Rossi", conversazione: false)
        controlla(lavoro == ["Il dossier di Giulia Rossi", "I calcoli di Prisma", "La tua agenda"], "Fonti di Vera in lavoro: dossier, calcoli e agenda")
        controlla(EsempiVera.fonti(nomeCliente: nil, conversazione: false).first == "I dossier dei tuoi clienti",
                  "Fonti di Vera con tutti i clienti: i dossier dei tuoi clienti")
        let chiacchiera = EsempiVera.fonti(nomeCliente: "Giulia Rossi", conversazione: true)
        controlla(!chiacchiera.contains { $0.contains("dossier") || $0.contains("calcoli") },
                  "Fonti di Vera in conversazione: niente dati dei clienti")
    }
}
