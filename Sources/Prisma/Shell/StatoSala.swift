import SwiftUI
import Observation

// La Sala della versione «Luce» (Design/template-luce-specifica.md §1.3): la casa delle 11 esperienze da vivere con il
// cliente. Qui il modello (le esperienze, nell'ordine di `ESP` del template) e lo stato della Sala, a parte da
// StatoShell come Inquadra: aprire un'esperienza o tornare alla griglia non ridisegna la shell né le altre app.
// Nota sui nomi: in Prisma «esperienza» vuol già dire l'esperienza in prodotti finanziari del profilo MiFID
// (`Cliente.Esperienza`, `EsperienzaCliente`): i tipi nuovi portano «Sala» nel nome.

/// Un'esperienza della Sala.
enum EsperienzaSala: String, CaseIterable, Identifiable {
    case prismaCliente, prismaLuce, lettera, film, disegna, giocoRischio, giornataPensione, lanciaAnno
    case valoreConsulente, capsula, realtaAumentata

    var id: String { rawValue }

    /// La voce del pannello Novità che apre l'esperienza.
    var novita: NovitaLuce {
        switch self {
        case .prismaCliente: return .prismaCliente
        case .prismaLuce: return .prismaLuce
        case .lettera: return .lettera
        case .film: return .film
        case .disegna: return .disegna
        case .giocoRischio: return .giocoRischio
        case .giornataPensione: return .giornataPensione
        case .lanciaAnno: return .lanciaAnno
        case .valoreConsulente: return .valoreConsulente
        case .capsula: return .capsula
        case .realtaAumentata: return .realtaAumentata
        }
    }

    var titolo: String { novita.titolo }
    var glifo: GlifoLuce { novita.glifo }
    var colore: Color { glifo.colore }

    /// La frase della scheda (`ESP[].d`, diversa da quella del pannello Novità). Il Prisma del cliente e il film seguono
    /// le decisioni 1, 3 e 108 (giro 15): un PDF protetto e un video di venti secondi che manda il consulente.
    var frase: String {
        switch self {
        case .prismaCliente: return "Il suo piano in un file protetto, da mandargli"
        case .prismaLuce: return "Il patrimonio che si scompone in raggi"
        case .lettera: return "Scritta da sé stesso a 67 anni"
        case .film: return "Venti secondi da mandare dopo l’incontro"
        case .disegna: return "Lo scarabocchio diventa un piano"
        case .giocoRischio: return "Il profilo vissuto, non dichiarato"
        case .giornataPensione: return "Il divario diventa una vita concreta"
        case .lanciaAnno: return "Due vite affiancate, con e senza piano"
        case .valoreConsulente: return "Il tuo lavoro, in cifre"
        case .capsula: return "Un messaggio sigillato fino al traguardo"
        case .realtaAumentata: return "Il patrimonio sul tavolo, dall’iPhone"
        }
    }

    /// «▣ Mostra sul tavolo»: in tutte tranne il Prisma del cliente, Quanto vale avermi accanto e la capsula.
    var mostraSulTavolo: Bool { ![.prismaCliente, .valoreConsulente, .capsula].contains(self) }

    /// «✦ Aggiungi al Prisma di …»: lettera, film, prisma di luce, giornata e disegno.
    var aggiungeAlPrisma: Bool { [.lettera, .film, .prismaLuce, .giornataPensione, .disegna].contains(self) }

    /// L'esperienza è già in Prisma (il palco la mostra); le altre dicono «Arriva con un prossimo aggiornamento».
    var disponibile: Bool { novita.disponibile }

    /// «▣ Mostra sul tavolo» già pronto («Luce» giro 16): il doppio senso per realtà aumentata, rischio, Lancia l'anno e
    /// disegno; l'immagine del palco (decisione 111) per prisma di luce e giornata; il foglio per la lettera. Il film
    /// resta fuori finché non c'è.
    var tavoloPronto: Bool {
        [.realtaAumentata, .giocoRischio, .lanciaAnno, .disegna, .prismaLuce, .lettera, .giornataPensione].contains(self)
    }

    /// Le dieci schede piccole della griglia (la prima, grande, è il Prisma del cliente).
    static var piccole: [EsperienzaSala] { allCases.filter { $0 != .prismaCliente } }

    // MARK: Migliorie d'uso 34: il momento giusto

    /// Il momento dell'incontro in cui l'esperienza serve (`SALA_M` del template).
    var momento: MomentoSala {
        switch self {
        case .prismaLuce, .disegna, .realtaAumentata: return .apre
        case .giocoRischio, .giornataPensione, .lanciaAnno: return .spiega
        case .lettera, .valoreConsulente, .capsula: return .chiude
        case .film, .prismaCliente: return .dopo
        }
    }

    /// Quanto dura, circa, in minuti: una stima editoriale fissa del template, non una cifra del cliente. Il Prisma del
    /// cliente non ha durata (si prepara e si manda). Per Lancia l'anno non dipende dagli anni della partita.
    var minuti: Int? {
        switch self {
        case .prismaLuce, .realtaAumentata, .valoreConsulente, .capsula: return 2
        case .disegna: return 5
        case .giocoRischio: return 4
        case .giornataPensione, .lanciaAnno, .lettera: return 3
        case .film: return 1
        case .prismaCliente: return nil
        }
    }

    /// L'area di Analisi 360 a cui l'esperienza risponde (il risparmio non ha un'esperienza sua).
    var areaConsigliata: AreaAnalisi? {
        switch self {
        case .giocoRischio: return .investimenti
        case .giornataPensione: return .previdenza
        case .lanciaAnno: return .protezione
        default: return nil
        }
    }

    /// Al più quante esperienze si consigliano per un cliente.
    static let consigliateMassime = 2

    /// Le esperienze consigliate dalle priorità del cliente (`PrioritaAree360`, in ordine dalla prima): al più due,
    /// nell'ordine delle priorità; le aree senza esperienza si saltano. Senza priorità nessun consiglio.
    static func consigliate(priorita: [AreaAnalisi]) -> [EsperienzaSala] {
        var esito: [EsperienzaSala] = []
        for area in priorita {
            guard esito.count < consigliateMassime else { break }
            if let e = allCases.first(where: { $0.areaConsigliata == area }), !esito.contains(e) {
                esito.append(e)
            }
        }
        return esito
    }
}

/// Migliorie d'uso 34: i quattro momenti dell'incontro, nell'ordine del filtro della Sala.
enum MomentoSala: String, CaseIterable, Identifiable, Hashable {
    case apre, spiega, chiude, dopo

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .apre: return "Per aprire"
        case .spiega: return "Per spiegare"
        case .chiude: return "Per chiudere"
        case .dopo: return "Dopo l’incontro"
        }
    }
}

/// Le schede di Pratiche (§1.2.1: Proposta · Moduli · Dopo la firma · Sinistri).
enum SchedaPratiche: String, CaseIterable, Identifiable, Hashable {
    case proposta, moduli, dopoLaFirma, sinistri

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .proposta: return "Proposta"
        case .moduli: return "Moduli"
        case .dopoLaFirma: return "Dopo la firma"
        case .sinistri: return "Sinistri"
        }
    }

    /// La novità che vivrà nella scheda.
    var novita: NovitaLuce {
        switch self {
        case .proposta: return .propostaDaSola
        case .moduli: return .compilaDaSolo
        case .dopoLaFirma: return .dopoLaFirma
        case .sinistri: return .sinistro
        }
    }
}

/// Le viste di Territorio (§1.2.1: Oggi · La crescita · Il giro di domani).
enum VistaTerritorio: String, CaseIterable, Identifiable, Hashable {
    case oggi, crescita, giro

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .oggi: return "Oggi"
        case .crescita: return "La crescita"
        case .giro: return "Il giro di domani"
        }
    }
}

/// Lo stato della Sala: l'esperienza sul palco (nil = la griglia). Lo osservano solo la Sala e la presentazione.
@Observable final class StatoSala {
    var esperienza: EsperienzaSala?
    /// «▶︎ Presenta» ha acceso la modalità cliente: alla chiusura della presentazione si spegne (non pubblicato).
    @ObservationIgnored var presentazioneHaAccesoModoCliente = false
    /// Solo istantanee (giro 4): lo stato di prova del prisma di luce e il tratto di prova di «Disegna il tuo futuro»
    /// (punti 0…1 nell'area del grafico, x = età da oggi a 90 anni, y = patrimonio da 0 al massimo dell'asse).
    @ObservationIgnored var provaLuce: ProvaLuce?
    @ObservationIgnored var provaDisegno: [CGPoint]?
    /// Una giornata della pensione: «Senza piano» o «Con il piano», ricordato tra un'apertura e l'altra (§4.2.1).
    @ObservationIgnored var giornataConPiano = false
    /// Istantanee: il punto del gioco del rischio da disegnare (scenario e risposte già date). Non pubblicato.
    @ObservationIgnored var rischioIstantanea: PuntoGiocoRischio?
    /// Il gioco del rischio sul palco ha già risposte e non è al risultato (§4.1.4): uscire dal palco o cambiare cliente
    /// chiede conferma. Lo scrive `GiocoRischioVista` (solo quella del consulente). Non pubblicato.
    @ObservationIgnored var rischioAMeta = false
    /// La conferma in attesa per lasciare il gioco del rischio a metà (§4.1.4). Osservato: la Sala mostra il dialogo.
    var uscitaRischio: UscitaRischio?
    /// La lettera dal futuro: la versione scelta resta finché si torna all'esperienza (§3.1.1). Non pubblicato.
    @ObservationIgnored var versioneLettera: VersioneLettera = .conPiano
    /// Solo istantanee: mostra l'avviso «Vera non è pronta» sotto il segmentato (642).
    @ObservationIgnored var letteraNonProntaIstantanea = false
    /// Solo istantanee: gli anni da lanciare a seme fisso, con le carte giocate a mano per anno (671, 672).
    @ObservationIgnored var lanciaIstantanea: ProvaLanciaAnno?
    /// Solo istantanee: il dettaglio aperto di «Quanto vale avermi accanto» (678).
    @ObservationIgnored var valoreDettaglioIstantanea: TipoVoceValore?
    /// «Quanto vale avermi accanto» ricordato per cliente, versione dei dati e giorno (`StatoShell.valoreConsulente`).
    @ObservationIgnored var memoValore: (chiave: String, valore: ValoreConsulente)?
    /// Il periodo di «Quanto vale avermi accanto» (§4.4.4): dall'inizio del rapporto o gli ultimi 12 mesi.
    var periodoValore: PeriodoValore = .inizio
    /// I clienti per cui il consulente ha scelto «Metti nel riesame» (decisione 18): solo per loro il prospetto del
    /// riesame mostra «Quanto vale avermi accanto». Una scelta della sessione, non salvata.
    var valoreNelRiesame: Set<String> = []
    /// Il dettaglio di «Quanto vale avermi accanto» è aperto: Esc lo chiude prima di tornare alla griglia.
    var dettaglioValoreAperto = false
    /// Le stesure della lettera dal futuro, per cliente e versione, finché il palco è aperto: la presentazione mostra
    /// solo quelle già scritte (e viste dal consulente) sul palco, mai una stesura nuova (§3.1).
    @ObservationIgnored var stesureLettera: [String: [VersioneLettera: TestoLettera]] = [:]
    /// La scheda della lettera ricordata per cliente, versione dei dati e giorno (`StatoShell.schedaLettera`).
    @ObservationIgnored var memoScheda: (chiave: String, scheda: SchedaLettera?)?
    /// Solo istantanee (giro 15): lo stato da disegnare del Prisma del cliente, del film e della capsula. Non pubblicato.
    @ObservationIgnored var provaUscite = ProvaUsciteSala()
    /// La capsula da aprire entrando nel palco della capsula (giro 15: «Apri la capsula» dai traguardi); la azzera
    /// `CapsulaDelTempo` appena apre la consegna. Non pubblicato.
    @ObservationIgnored var capsulaDaAprire: String?
    /// «▣ Mostra sul tavolo» con il doppio senso («Luce» giro 16, decisione 48): l'esperienza che manda all'iPad il suo
    /// stato a ogni passo (gioco del rischio, Lancia l'anno, disegno). nil = nessuna. Osservato: la vista del gioco lo legge.
    var tavoloEsperienza: EsperienzaSala?
    /// La riga di conferma delle cifre sull'iPad (decisione 49) in testa al palco di questa esperienza. nil = nessuna.
    var confermaCifreTavolo: EsperienzaSala?
    /// Solo istantanee: lo stato di prova della realtà aumentata (anno, esploso, strato scelto, tavolo collegato).
    @ObservationIgnored var realtaIstantanea: ScenaRealtaDiProva?
    /// iPhone e iPad: la realtà aumentata a tutto schermo è aperta («Apri in realtà aumentata»).
    var realtaAperta = false
    /// Migliorie d'uso 34: il momento scelto nel filtro della griglia (nil = «Tutte»). Osservato, non salvato: si azzera
    /// alla chiusura della Sala.
    var momento: MomentoSala?
    /// Solo istantanee (1117): il cliente come se non avesse priorità (etichette dei momenti senza consigli).
    @ObservationIgnored var senzaPrioritaIstantanea = false
}

/// Che cosa lascia a metà il gioco del rischio (§4.1.4): il ritorno alla griglia («‹ Sala» o Esc) o il cambio di cliente.
enum UscitaRischio: Equatable {
    case torna
    case cliente(String)
}

/// Solo istantanee: lo stato della realtà aumentata da disegnare («Luce» giro 16).
struct ScenaRealtaDiProva {
    /// nil = oggi; `allaPensione` = l'ultimo anno del cursore.
    var anno: Int?
    var allaPensione = false
    var esploso = false
    var scelto: String?
    var tavoloCollegato = false
    /// iPhone e iPad: il ripiego con «Consenti in Impostazioni» (73).
    var fotocameraNegata = false
}

/// Solo istantanee: una partita di Lancia l'anno già giocata (seme fisso, anni, carte a mano per anno).
struct ProvaLanciaAnno {
    var seme: UInt64
    var anni: Int
    var carte: [Int: String] = [:]
}

extension StatoShell {
    /// Apre la Sala sul palco dell'esperienza (`apriEsp` del template) e, se dato, sul cliente. Senza un cliente in
    /// archivio la Sala si apre sulla griglia, che dice «Scegli un cliente per iniziare».
    func apriEsperienza(_ e: EsperienzaSala, cliente id: String? = nil) {
        if let id, cliente(id) != nil { clienteAttivoId = id }
        sala.esperienza = clienteAttivo == nil ? nil : e
        sala.stesureLettera = [:]
        sala.dettaglioValoreAperto = false
        apri(.sala)
    }

    /// «‹ Sala»: dal palco alla griglia.
    func tornaAllaSala() {
        guard sala.esperienza != nil else { return }
        sala.esperienza = nil
    }

    // MARK: Il gioco del rischio a metà (§4.1.4)

    /// Lasciare il palco o cambiare cliente perderebbe le risposte già date al gioco del rischio.
    var partitaRischioAMeta: Bool { sala.esperienza == .giocoRischio && sala.rischioAMeta }

    /// Il cambio di cliente dalle pillole della Sala: a metà del gioco del rischio chiede prima conferma.
    func scegliClienteSala(_ id: String) {
        guard id != clienteAttivoId else { return }
        if partitaRischioAMeta { sala.uscitaRischio = .cliente(id) } else { clienteAttivoId = id }
    }

    /// «‹ Sala» ed Esc dal palco: true se si può tornare subito; a metà del gioco del rischio chiede conferma (false).
    func puoTornareAllaSala() -> Bool {
        guard partitaRischioAMeta else { return true }
        sala.uscitaRischio = .torna
        return false
    }

    /// La conferma data: le risposte a metà si perdono e si fa ciò che era stato chiesto.
    func confermaUscitaRischio() {
        guard let u = sala.uscitaRischio else { return }
        sala.uscitaRischio = nil
        sala.rischioAMeta = false
        switch u {
        case .torna: tornaAllaSala()
        case .cliente(let id): clienteAttivoId = id
        }
    }

    /// Apre Pratiche sulla scheda data (dal pannello Novità, dalle altre app).
    func apriPratiche(_ scheda: SchedaPratiche) {
        schedaPratiche = scheda
        apri(.pratiche)
    }

    /// Apre Territorio sulla vista data.
    func apriTerritorio(_ vista: VistaTerritorio = .oggi) {
        vistaTerritorio = vista
        apri(.territorio)
    }
}
