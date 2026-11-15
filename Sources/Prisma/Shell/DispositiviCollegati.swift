#if os(macOS)
import Observation
import SwiftUI

// Migliorie d'uso 39 «iPhone e iPad: un collegamento solo» (Design/uso/gruppo-06.md §39), solo sul Mac.
//
//   Impostazioni › iPhone e iPad
//   [schema · Sincronizzato · Sincronizza ora]
//   I TUOI DISPOSITIVI
//   ┌──────────────────────────────────────────────────────┐
//   │ iPhone o iPad   visto 2 minuti fa        (Collegato) │   ← dal ponte, dal tavolo, dai giornali di «Prisma ovunque»
//   │ Un altro iPhone o iPad        [Collega con un codice] │
//   └──────────────────────────────────────────────────────┘
//   COSA FANNO INSIEME AL MAC
//   I dati · Vera · Inquadra un documento · Nota a voce · Al tavolo   (ognuna con il suo interruttore)
//   Modifiche in attesa
//   Il codice collega il dispositivo; la passphrase protegge la copia dei dati…
//
// I due segreti restano due (decisione 3): il codice del ponte (nell'archivio e nei backup) collega Vera, Inquadra, la
// nota e il tavolo; la passphrase di «Prisma ovunque» (nel Portachiavi) protegge la copia dei dati. Il codice resta
// quello di oggi, senza scadenza (decisione 2). Il registro dei dispositivi vive solo in memoria: niente archivio,
// niente backup, niente «Prisma ovunque», nessun dato dei clienti.

/// I dispositivi che si sono fatti vivi da quando Prisma è aperta (più quelli dei giornali di «Prisma ovunque»).
/// Sul thread principale; si aggiorna al più una volta al minuto per dispositivo, così la pagina non si ridisegna a ogni
/// pezzo di risposta di Vera.
@Observable final class RegistroDispositivi {
    enum Via: Equatable {
        /// Il ponte di Vera (Vera, copilota, Inquadra, carta, nota).
        case ponte
        /// L'iPad del tavolo.
        case tavolo
        /// Il giornale di «Prisma ovunque» (la data è quella del file).
        case ovunque
    }

    struct Dispositivo: Identifiable, Equatable {
        let id: String
        var nome: String
        var visto: Date
        var via: Via
    }

    /// Il nome quando iPhone e iPad non lo mandano (le chiamate al modello non lo portano).
    static let generico = "iPhone o iPad"
    /// Al più un aggiornamento al minuto per dispositivo.
    static let intervallo: TimeInterval = 60

    private(set) var elenco: [Dispositivo] = []
    /// La scheda «Collega con un codice» è aperta (in memoria).
    var schedaCodice = false
    /// Da quando Prisma è aperta: un dispositivo visto dopo è «Collegato».
    private(set) var avvio: Date

    init(avvio: Date = Date()) {
        self.avvio = avvio
    }

    /// I dispositivi dal più recente.
    var ordinati: [Dispositivo] { elenco.sorted { $0.visto > $1.visto } }

    /// «Collegato»: visto da quando Prisma è aperta.
    func collegato(_ d: Dispositivo) -> Bool { d.visto >= avvio }

    /// Il ponte ha aperto una busta. Senza nome (le chiamate al modello): se c'è un solo dispositivo del ponte con il
    /// nome, è lui; altrimenti la riga «iPhone o iPad».
    func annotaPonte(nome: String?, adesso: Date = Date()) {
        let pulito = nome.map { String($0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(PonteVera.massimoDispositivo)) } ?? ""
        if pulito.isEmpty {
            let conNome = elenco.filter { $0.via == .ponte && $0.id != Self.idGenerico }
            if conNome.count == 1 {
                aggiorna(id: conNome[0].id, nome: conNome[0].nome, via: .ponte, adesso: adesso)
            } else {
                aggiorna(id: Self.idGenerico, nome: Self.generico, via: .ponte, adesso: adesso)
            }
        } else {
            // Il nome vero sostituisce la riga senza nome (era quasi certamente lo stesso dispositivo)
            elenco.removeAll { $0.id == Self.idGenerico }
            aggiorna(id: "ponte-" + pulito, nome: pulito, via: .ponte, adesso: adesso)
        }
    }

    /// L'iPad del tavolo si è collegato (il nome è quello del saluto).
    func annotaTavolo(nome: String, adesso: Date = Date()) {
        let pulito = String(nome.trimmingCharacters(in: .whitespacesAndNewlines).prefix(PonteVera.massimoDispositivo))
        aggiorna(id: "tavolo-" + pulito, nome: pulito.isEmpty ? "iPad" : pulito, via: .tavolo, adesso: adesso, subito: true)
    }

    /// I giornali letti nell'ultimo controllo di «Prisma ovunque»: id del dispositivo, nome e data del file.
    func annotaOvunque(_ giornali: [(id: String, nome: String, data: Date)]) {
        for g in giornali {
            let id = "ovunque-" + g.id
            if let i = elenco.firstIndex(where: { $0.id == id }) {
                if elenco[i].visto < g.data || elenco[i].nome != g.nome {
                    elenco[i].visto = max(elenco[i].visto, g.data)
                    elenco[i].nome = g.nome
                }
            } else {
                elenco.append(Dispositivo(id: id, nome: g.nome.isEmpty ? Self.generico : g.nome, visto: g.data, via: .ovunque))
            }
        }
    }

    /// Solo per le istantanee e le prove: un dispositivo già annotato (visto da quando Prisma è «aperta»).
    func annotaPerIstantanea(_ d: Dispositivo) {
        if d.visto < avvio { avvio = d.visto }
        elenco.removeAll { $0.id == d.id }
        elenco.append(d)
    }

    func svuota() { elenco = [] }

    private static let idGenerico = "ponte-generico"

    private func aggiorna(id: String, nome: String, via: Via, adesso: Date, subito: Bool = false) {
        if let i = elenco.firstIndex(where: { $0.id == id }) {
            guard subito || adesso.timeIntervalSince(elenco[i].visto) >= Self.intervallo else { return }
            elenco[i].visto = adesso
            if elenco[i].nome != nome { elenco[i].nome = nome }
        } else {
            elenco.append(Dispositivo(id: id, nome: nome, visto: adesso, via: via))
        }
    }
}

/// I testi della pagina (come nel template, §39.1; la nota e la frase del codice secondo le decisioni 2 e 3).
enum TestiCollegamenti {
    static let dispositivi = "I tuoi dispositivi"
    static let altro = "Un altro iPhone o iPad"
    static let nessuno = "Nessun dispositivo ancora: si collega una volta, con un codice."
    static let collega = "Collega con un codice"
    static let scollega = "Scollega"
    static let insieme = "Cosa fanno insieme al Mac"
    static let collegato = "Collegato"
    static let primaCollega = "Prima collega un dispositivo."
    static let nota = "Il codice collega il dispositivo; la passphrase protegge la copia dei dati e sta nel Portachiavi di questo Mac."

    static let dati = "I dati"
    static let datiSotto = "Copia cifrata in iCloud Drive: lavori anche con il Mac spento."
    static let vera = "Vera"
    static let veraSotto = "iPhone e iPad usano Vera del Mac, dalla rete di casa."
    static let inquadra = "Inquadra un documento"
    static let inquadraSotto = "Con la fotocamera dell’iPhone, da Posizioni."
    static let notaVoce = "Nota a voce"
    static let notaSotto = "Dettata all’iPhone, arriva in Incontri."
    static let tavolo = "Al tavolo"
    static let tavoloSotto = "L’iPad davanti al cliente, guidato dal Mac."

    static let schedaOcchiello = "Collega un dispositivo"
    static let schedaTitolo = "Apri Prisma sull’iPhone o sull’iPad e scrivi questo codice"
    static let schedaFrase = "Si fa una volta sola: vale per Vera, per inquadrare i documenti, per le note a voce e per il tavolo."
    static let schedaDati = "Per i dati serve anche la passphrase della copia cifrata, che scegli accendendo «I dati»."
    static let nuovoCodice = "Nuovo codice"
    static let nuovoCodiceAiuto = "Il codice vecchio smette di valere: va riscritto su iPhone e iPad"
    static let fine = "Fine"

    /// Il rimando dentro le app («Inquadra con l'iPhone», «Nota dall'iPhone»).
    static let collegaIPhone = "Collega l’iPhone"
    static let rimandoVera = "Si collegano in Impostazioni › iPhone e iPad."

    /// «visto 2 minuti fa», «sul tavolo oggi alle 09:30».
    static func visto(_ d: RegistroDispositivi.Dispositivo, adesso: Date = Date()) -> String {
        switch d.via {
        case .tavolo:
            let ora = Formati.ora.string(from: d.visto)
            if Calendar.current.isDateInToday(d.visto) { return "sul tavolo oggi alle \(ora)" }
            return "sul tavolo " + TestiOvunque.quando(d.visto, adesso: adesso)
        case .ponte, .ovunque:
            return "visto " + TestiOvunque.quando(d.visto, adesso: adesso)
        }
    }

    /// Il codice in gruppi di quattro, per leggerlo meglio («ABCD EFGH JKLM»).
    static func codiceInGruppi(_ codice: String) -> String {
        let pulito = codice.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "")
        var gruppi: [String] = []
        var resto = Substring(pulito)
        while !resto.isEmpty {
            gruppi.append(String(resto.prefix(4)))
            resto = resto.dropFirst(4)
        }
        return gruppi.joined(separator: " ")
    }
}

extension ArrivoPonte {
    /// Il nome del dispositivo che manda il messaggio («iPhone di Denis»).
    var nomeDispositivo: String {
        switch self {
        case .schedeCopilota(let p): return p.dispositivo
        case .inquadratura(let i): return i.dispositivo
        case .cartaIdentita(let c): return c.dispositivo
        case .notaVocale(let n): return n.dispositivo
        }
    }
}

extension StatoShell {
    /// Il rimando dalle app: Impostazioni › iPhone e iPad (come `eseguiPasso` della guida).
    func apriCollegamenti() {
        schedaImpostazioni = .ovunque
        ancoraImpostazioni = nil
        apri(.impostazioni)
    }

    /// «Collega con un codice»: accende il collegamento (con un codice nuovo se non c'è) e mostra la scheda.
    func apriCodiceDispositivo() {
        guard !solaLettura else {
            mostraAvviso("L’archivio è in sola lettura: il collegamento non si può accendere.")
            return
        }
        if !dati.impostazioni.vera.ponte.abbinato { dati.impostazioni.vera.ponte.codice = PonteVera.nuovoCodice() }
        if !dati.impostazioni.vera.ponte.condividi { dati.impostazioni.vera.ponte.condividi = true }
        dispositivi.schedaCodice = true
    }

    func chiudiCodiceDispositivo() {
        guard dispositivi.schedaCodice else { return }
        dispositivi.schedaCodice = false
    }

    /// «Nuovo codice»: il codice vecchio smette di valere.
    func nuovoCodiceDispositivo() {
        guard !solaLettura else { return }
        dati.impostazioni.vera.ponte.codice = PonteVera.nuovoCodice()
    }

    /// «Scollega»: il collegamento si spegne (il codice resta, per ricollegare senza riscriverlo).
    func scollegaDispositivi() {
        guard !solaLettura, dati.impostazioni.vera.ponte.condividi else { return }
        dati.impostazioni.vera.ponte.condividi = false
    }

    /// La nota dall'iPhone può arrivare: collegamento acceso e «Nota a voce» accesa.
    var ponteNotaAcceso: Bool {
        let p = dati.impostazioni.vera.ponte
        return p.collegato && p.nota
    }
}

// MARK: - Viste della pagina

/// «I tuoi dispositivi»: la card con una riga per dispositivo e «Un altro iPhone o iPad». Legge solo il registro e
/// il ponte: la pagina non si ridisegna quando un dispositivo si fa vivo.
struct GruppoDispositiviCollegati: View {
    @Environment(StatoShell.self) var stato
    let registro: RegistroDispositivi

    private typealias D = Tema.Apple.Ovunque.Dispositivi

    var body: some View {
        let elenco = registro.ordinati
        let collegato = stato.dati.impostazioni.vera.ponte.condividi
        return GruppoImpostazioni(titolo: TestiCollegamenti.dispositivi) {
            VStack(spacing: 0) {
                ForEach(elenco) { d in
                    riga {
                        Text(d.nome)
                            .carattereApple(D.nome)
                            .foregroundColor(D.coloreNome)
                            .lineLimit(1)
                        Text(TestiCollegamenti.visto(d))
                            .carattereApple(D.visto)
                            .foregroundColor(D.coloreVisto)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if registro.collegato(d) {
                            StatoRigaApple(testo: TestiCollegamenti.collegato, tono: .ok)
                        }
                    }
                    filo
                }
                riga {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(TestiCollegamenti.altro)
                            .carattereApple(D.altro)
                            .foregroundColor(D.coloreAltro)
                        if elenco.isEmpty {
                            Text(TestiCollegamenti.nessuno)
                                .carattereApple(D.visto)
                                .foregroundColor(D.coloreVisto)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: D.spazioPulsanti) {
                        if collegato {
                            Button(TestiCollegamenti.scollega) { stato.scollegaDispositivi() }
                                .buttonStyle(.apple)
                                .fixedSize()
                                .help("Spegne il collegamento con iPhone e iPad: il codice resta, per ricollegarli senza riscriverlo")
                        }
                        Button(TestiCollegamenti.collega) { stato.apriCodiceDispositivo() }
                            .buttonStyle(.apple)
                            .fixedSize()
                    }
                }
            }
            .padding(D.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .superficieApple(D.superficie, raggio: D.raggio)
        }
    }

    private func riga<C: View>(@ViewBuilder _ contenuto: () -> C) -> some View {
        HStack(alignment: .center, spacing: D.spazio) {
            contenuto()
        }
        .padding(.vertical, D.paddingRiga)
        .frame(maxWidth: .infinity, minHeight: D.altezzaRiga, alignment: .leading)
    }

    private var filo: some View {
        Rectangle()
            .fill(D.filo)
            .frame(height: D.spessoreFilo)
    }
}

/// Una delle quattro righe del ponte in «Cosa fanno insieme al Mac»: disattivata finché il collegamento è spento.
struct RigaFunzionePonte: View {
    @Environment(StatoShell.self) var stato
    let titolo: String
    let sottotitolo: String
    let chiave: WritableKeyPath<ImpostazioniPonte, Bool>

    var body: some View {
        let ponte = stato.dati.impostazioni.vera.ponte
        let attiva = ponte.collegato
        let acceso = Binding<Bool>(
            get: { stato.dati.impostazioni.vera.ponte[keyPath: chiave] },
            set: { nuovo in
                guard !stato.solaLettura else { return }
                stato.dati.impostazioni.vera.ponte[keyPath: chiave] = nuovo
            })
        return RigaImpostazione(titolo: titolo,
                                sottotitolo: attiva ? sottotitolo : TestiCollegamenti.primaCollega,
                                aiuto: attiva ? nil : sottotitolo) {
            Toggle(isOn: acceso) { EmptyView() }
                .toggleStyle(.appleSenzaEtichetta)
                .accessibilityLabel(Text(titolo))
                .disabled(!attiva)
        }
        .opacity(attiva ? 1 : Tema.Apple.Ovunque.Dispositivi.opacitaSpenta)
    }
}

/// Il rimando dentro le app quando l'iPhone non è collegato: «Collega l’iPhone» → Impostazioni › iPhone e iPad.
struct RimandoCollegaDispositivo: View {
    @Environment(StatoShell.self) var stato
    var titolo = TestiCollegamenti.collegaIPhone
    /// Prima di aprire le Impostazioni (chiude la scena da cui si parte).
    var prima: () -> Void = {}

    var body: some View {
        Button {
            prima()
            stato.apriCollegamenti()
        } label: {
            Label(titolo, systemImage: "iphone")
        }
        .buttonStyle(.apple)
        .fixedSize()
        .help("Impostazioni › iPhone e iPad: si collega una volta, con un codice")
    }
}

// MARK: - La scheda del codice

/// «Collega con un codice» (`apriCodice` del template): velo e vetro al centro, il codice di oggi in grande. Sopra barra
/// e dock come le tre domande del primo avvio (ShellView); Esc, ✕, «Fine» e il velo chiudono.
struct SchedaCollegaDispositivo: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo

    private typealias K = Tema.Apple.Ovunque.Codice

    var body: some View {
        let _ = ContaCorpi.segna()
        GeometryReader { geo in
            ZStack {
                K.velo
                    .contentShape(Rectangle())
                    .onTapGesture { stato.chiudiCodiceDispositivo() }
                scheda
                    .frame(width: max(0, min(K.larghezza, geo.size.width - 2 * K.bordo)))
                    .entrataScheda(Tema.Apple.Moto.animazione(K.animazione, calmo: calmo), scala: K.entrataScala,
                                   ancora: .center, y: K.entrataY)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var scheda: some View {
        let codice = stato.dati.impostazioni.vera.ponte.codice
        return VStack(alignment: .leading, spacing: 0) {
            Text(TestiCollegamenti.schedaOcchiello)
                .carattereApple(K.occhiello)
                .foregroundColor(K.coloreOcchiello)
            Text(TestiCollegamenti.schedaTitolo)
                .carattereApple(K.titolo)
                .foregroundColor(K.coloreTitolo)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, K.sopraTitolo)
                .padding(.bottom, K.sottoTitolo)
            Text(TestiCollegamenti.codiceInGruppi(codice))
                .carattereApple(K.carattere)
                .foregroundColor(K.coloreCodice)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .textSelection(.enabled)
                .padding(.top, K.sopraCodice)
                .padding(.bottom, K.sottoCodice)
                .accessibilityLabel(Text("Codice \(codice)"))
            Text(TestiCollegamenti.schedaFrase)
                .carattereApple(K.frase)
                .foregroundColor(K.coloreFrase)
                .fixedSize(horizontal: false, vertical: true)
            Text(TestiCollegamenti.schedaDati)
                .carattereApple(K.avviso)
                .foregroundColor(K.coloreAvviso)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, K.sottoTitolo)
            HStack(spacing: K.spazioPulsanti) {
                Button { stato.nuovoCodiceDispositivo() } label: {
                    Label(TestiCollegamenti.nuovoCodice, systemImage: "key")
                }
                .buttonStyle(.apple)
                .help(TestiCollegamenti.nuovoCodiceAiuto)
                Spacer(minLength: 0)
                Button(TestiCollegamenti.fine) { stato.chiudiCodiceDispositivo() }
                    .buttonStyle(.applePrimario)
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.top, K.sopraPulsanti)
        }
        .padding(K.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            Button { stato.chiudiCodiceDispositivo() } label: { Image(systemName: "xmark") }
                .buttonStyle(.apple)
                .keyboardShortcut(.cancelAction)
                .help("Chiudi (Esc)")
                .accessibilityLabel(Text("Chiudi"))
                .padding(K.chiudi)
        }
        .superficieApple(K.superficie, raggio: K.raggio)
    }
}
#endif
