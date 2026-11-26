import SwiftUI

// Migliorie d'uso 37 · «La dimostrazione è un interruttore» (Design/uso/gruppo-06.md §37, template righe 2770-2777 e
// 4202-4227). Per far vedere Prisma senza mostrare il proprio lavoro: con la dimostrazione accesa in memoria ci sono solo
// i clienti di prova (rifatti ogni volta da `DatiPrisma.demo()` o `ClientiFittizi.completi()`), l'archivio vero resta sul
// disco intatto e si rilegge allo spegnimento. Mentre è accesa si fermano salvataggi, backup, «Prisma ovunque», Stanotte,
// routine programmate, tagliando, promemoria del Mac, le pulizie e le scritture dei file accanto all'archivio, la memoria
// di Vera; le note dettate sull'iPhone restano nella sua coda. Le guardie stanno dove si scrive (StatoShell.swift e gli
// stati di Biblioteca, Moduli, Spese, memoria e ricerca di Vera), con un commento che rimanda qui.
//
// Accensione e spegnimento (`accendiDimostrazione`, `spegniDimostrazione`) stanno in StatoShell.swift, perché toccano il
// salvataggio e i filtri privati; qui i testi, i gruppi, i dati di prova, la condizione delle scritte «dati di prova»,
// la scheda dell'etichetta della barra e la pagina di Impostazioni. Solo sul Mac: su iPhone e iPad `inDimostrazione` resta
// sempre falsa. Lo stato acceso e il gruppo stanno nelle preferenze del Mac, mai nell'archivio, nei backup o in «Prisma
// ovunque» (37.4).

/// I due gruppi di clienti di prova della dimostrazione.
enum GruppoProva: String, CaseIterable, Identifiable {
    /// I 5 clienti del template: pochi, per spiegare con calma.
    case cinque
    /// I 5 più i 30 clienti inventati: Prisma piena.
    case trentacinque

    var id: String { rawValue }

    var titolo: String {
        switch self {
        case .cinque: return "Cinque clienti"
        case .trentacinque: return "Trentacinque clienti"
        }
    }

    var spiegazione: String {
        switch self {
        case .cinque: return "Pochi, per spiegare con calma."
        case .trentacinque: return "Lucy piena: Lucy, il territorio, lo Studio."
        }
    }
}

/// I testi della dimostrazione (template righe 4209-4227).
enum TestiDimostrazione {
    static let titoloPagina = "Dimostrazione"
    static let introduzione = "Per far vedere Lucy a un cliente curioso, a un collega o a chi la vuole comprare, senza mostrare il tuo lavoro."
    static let interruttore = "Dimostrazione"
    static let interruttoreSpiegazione = "Lucy mostra solo i clienti di prova: i tuoi restano da parte, intatti."
    static let gruppoClienti = "I clienti di prova"
    static let inUso = "In uso"
    static let usaQuesti = "Usa questi"
    static let accesa = "Dimostrazione accesa: i tuoi clienti sono da parte"
    static let spenta = "Dimostrazione spenta"
    static let fine = "Fine della dimostrazione: tornano i tuoi clienti, com’erano"
    static let etichettaColonna = "accesa"
    static func gruppoInUso(_ g: GruppoProva) -> String { "Dimostrazione con \(g.titolo.lowercased())" }

    // La scheda dell'etichetta
    static let schedaOcchiello = "Dimostrazione"
    static let schedaTitolo = "Stai mostrando Lucy con i clienti di prova."
    static let righe: [(titolo: String, testo: String)] = [
        ("I tuoi clienti sono al sicuro", "Messi da parte, intatti: qui non compaiono e non si possono cercare."),
        ("Niente si mescola", "Il backup e la copia per iPhone e iPad restano fermi: i dati di prova non finiscono tra quelli veri."),
        ("Si esce con un clic", "Tutto torna com’era, senza niente da ripulire."),
    ]
    static let esci = "Esci dalla dimostrazione"
    static let resta = "Resta"

    // Le cose ferme
    static let backupFermo = "Durante la dimostrazione il backup è fermo"
    static let nonDurante = "Non durante la dimostrazione"
    static let attendiBackup = "C'è un backup in corso: la dimostrazione si accende appena finisce."
    static let notaRifiutata = "Lucy sul Mac sta mostrando la dimostrazione: la nota resta sull’iPhone e arriva dopo."

    // Le preferenze del Mac (fuori dall'archivio e dai backup)
    static let chiaveAccesa = "Prisma.dimostrazione"
    static let chiaveGruppo = "Prisma.dimostrazioneGruppo"
}

extension StatoShell {
    /// Una sola condizione per le scritte «dati di prova» sparse (Studio, Messaggi, Sala, dossier…): ci sono clienti di
    /// prova nell'archivio e la dimostrazione è spenta (accesa, basta l'etichetta nella barra). Tenuta fra i dati
    /// ricavati: `haDatiDiProva` scorre tutti i clienti.
    var scritteProva: Bool {
        guard !inDimostrazione else { return false }
        return ricavato("scritte-prova") { haDatiDiProva }
    }

    /// I dati della dimostrazione, solo in memoria: il gruppo di prova con il giro di prova del Territorio, e delle
    /// impostazioni dell'utente solo quelle che non portano dati (aspetto, nomi dei canali, motore e ponte di Vera).
    static func datiDimostrazione(_ gruppo: GruppoProva, impostazioni vere: Impostazioni, oggi: Date = Date()) -> DatiPrisma {
        var demo = gruppo == .trentacinque ? ClientiFittizi.completi() : DatiPrisma.demo()
        var i = demo.impostazioni
        tieniImpostazioni(&i, da: vere)
        demo.impostazioni = i
        TerritorioDiProva.applica(&demo, giorno: TerritorioDiProva.giorno(da: oggi, orari: demo.impostazioni.orari),
                                  conPartenza: true)
        return demo
    }

    /// Le impostazioni dell'utente che restano in dimostrazione (37.3 A.2): l'aspetto, i nomi dei canali, il motore e il
    /// ponte di Vera (se si azzerassero il ponte si spegnerebbe o cambierebbe codice), il nome nel profilo, la guida e
    /// le novità già viste e le impostazioni dei backup (che restano fermi).
    static func tieniImpostazioni(_ i: inout Impostazioni, da v: Impostazioni) {
        riportaImpostazioni(&i, da: v)
        i.nomeUtente = v.nomeUtente
        i.inizialiUtente = v.inizialiUtente
        i.introduzioneVista = v.introduzioneVista
        i.guidaNascosta = v.guidaNascosta
        i.novitaViste = v.novitaViste
        i.backup = v.backup
    }

    /// Allo spegnimento tornano nell'archivio vero solo le scelte fatte in dimostrazione sull'aspetto, sui nomi dei canali
    /// e su Vera (decisione 7); tutto il resto si perde.
    static func riportaImpostazioni(_ i: inout Impostazioni, da d: Impostazioni) {
        i.dimensioneTesto = d.dimensioneTesto
        i.aspetto = d.aspetto
        i.sfondoAnimato = d.sfondoAnimato
        i.pioggia = d.pioggia
        i.acquaDellaScrivania = d.acquaDellaScrivania
        i.riduciMovimento = d.riduciMovimento
        i.nomiCanali = d.nomiCanali
        i.vera = d.vera
    }
}

#if os(macOS)
extension StatoShell {
    /// L'interruttore della pagina: accende con il gruppo scelto, o spegne.
    func impostaDimostrazione(_ accesa: Bool) {
        if accesa {
            accendiDimostrazione(gruppoProva)
        } else {
            spegniDimostrazione()
        }
    }

    /// «Usa questi»: con la dimostrazione accesa ricarica subito l'altro gruppo; spenta, sceglie quello della prossima volta.
    func usaGruppoProva(_ g: GruppoProva) {
        if inDimostrazione {
            accendiDimostrazione(g)
        } else {
            gruppoProva = g
            if persistente { UserDefaults.standard.set(g.rawValue, forKey: TestiDimostrazione.chiaveGruppo) }
        }
    }

    /// «Esci dalla dimostrazione» della scheda.
    func esciDallaDimostrazione() {
        schedaDimostrazione = false
        spegniDimostrazione(avviso: TestiDimostrazione.fine)
    }
}

// MARK: - La scheda dell'etichetta

/// «Stai mostrando Prisma con i clienti di prova.» (`apriDemo` del template): velo e vetro al centro, larga 640, con le tre
/// promesse e i pulsanti «Esci dalla dimostrazione» e «Resta». Sopra barra e dock come le altre schede leggere (ShellView);
/// «Resta», ✕, il velo ed Esc chiudono e basta.
struct SchedaDimostrazione: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo

    private typealias K = Tema.Apple.Dimostrazione.Scheda

    var body: some View {
        let _ = ContaCorpi.segna()
        GeometryReader { geo in
            ZStack {
                K.velo
                    .contentShape(Rectangle())
                    .onTapGesture { stato.schedaDimostrazione = false }
                scheda
                    .frame(width: max(0, min(K.larghezza, geo.size.width - 2 * K.bordo)))
                    .entrataScheda(Tema.Apple.Moto.animazione(K.animazione, calmo: calmo), scala: K.entrataScala,
                                   ancora: .center, y: K.entrataY)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private var scheda: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(TestiDimostrazione.schedaOcchiello)
                .carattereApple(K.occhiello)
                .foregroundColor(K.coloreOcchiello)
            Text(TestiDimostrazione.schedaTitolo)
                .carattereApple(K.titolo)
                .foregroundColor(K.coloreTitolo)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, K.sopraTitolo)
                .padding(.bottom, K.sottoTitolo)
            VStack(alignment: .leading, spacing: K.fraRighe) {
                ForEach(Array(TestiDimostrazione.righe.enumerated()), id: \.offset) { _, r in
                    HStack(alignment: .firstTextBaseline, spacing: K.spazioSpunta) {
                        Image(systemName: K.simboloSpunta)
                            .carattereApple(K.spunta)
                            .foregroundColor(K.coloreSpunta)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: K.sottoTitoloRiga) {
                            Text(r.titolo)
                                .carattereApple(K.titoloRiga)
                                .foregroundColor(K.coloreTitoloRiga)
                            Text(r.testo)
                                .carattereApple(K.testoRiga)
                                .foregroundColor(K.coloreTestoRiga)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            HStack(spacing: K.spazioPulsanti) {
                Button(TestiDimostrazione.esci) { stato.esciDallaDimostrazione() }
                    .buttonStyle(.applePrimarioGrande)
                    .keyboardShortcut(.defaultAction)
                Button(TestiDimostrazione.resta) { stato.schedaDimostrazione = false }
                    .buttonStyle(.appleGrande)
                Spacer(minLength: 0)
            }
            .padding(.top, K.sopraPulsanti)
        }
        .padding(K.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            Button { stato.schedaDimostrazione = false } label: { Image(systemName: "xmark") }
                .buttonStyle(.apple)
                .keyboardShortcut(.cancelAction)
                .help("Chiudi (Esc)")
                .accessibilityLabel(Text("Chiudi"))
                .padding(K.chiudi)
        }
        .superficieApple(K.superficie, raggio: K.raggio)
    }
}

// MARK: - Impostazioni › Dimostrazione

extension AppImpostazioni {
    /// La pagina (template `IMPS.prove`, riga 4217): l'introduzione, l'interruttore e i due gruppi di clienti di prova,
    /// con «In uso» su quello scelto e «Usa questi» sull'altro.
    var paginaDimostrazione: some View {
        VStack(alignment: .leading, spacing: M.spazioGruppi) {
            NotaImpostazioni(TestiDimostrazione.introduzione)
                .cascataImpostazioni(1)
            GruppoImpostazioni {
                RigaImpostazione(titolo: TestiDimostrazione.interruttore, sottotitolo: TestiDimostrazione.interruttoreSpiegazione,
                                 aiuto: "Il backup, la copia per iPhone e iPad, Stanotte e i promemoria restano fermi finché la dimostrazione è accesa",
                                 ultima: true) {
                    interruttore(Binding(get: { stato.inDimostrazione }, set: { stato.impostaDimostrazione($0) }))
                        .disabled(stato.spegnimentoDimostrazione)
                }
            }
            .id("imp-strumenti-dimostrazione")
            .cascataImpostazioni(2)
            GruppoImpostazioni(titolo: TestiDimostrazione.gruppoClienti) {
                ForEach(Array(GruppoProva.allCases.enumerated()), id: \.element) { i, g in
                    let inUso = g == stato.gruppoProva
                    RigaImpostazione(titolo: g.titolo, sottotitolo: g.spiegazione,
                                     stato: inUso ? Pillola(testo: TestiDimostrazione.inUso, tono: .ok) : nil,
                                     ultima: i == GruppoProva.allCases.count - 1) {
                        if !inUso {
                            ValoreRiga(testo: TestiDimostrazione.usaQuesti) { stato.usaGruppoProva(g) }
                        }
                    }
                }
            }
            .id("imp-strumenti-gruppi")
            .cascataImpostazioni(3)
        }
    }
}
#endif
