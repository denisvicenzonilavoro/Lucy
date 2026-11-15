#if os(macOS)
import SwiftUI

// Migliorie d'uso 14 «Le posizioni prima di tutto» (Design/uso/gruppo-02.md §14, template righe 3461-3598): con un
// cliente scelto la colonna di sinistra di Posizioni non ha più filtri e ancore ma l'indice delle sue posizioni,
// largo 236, nello stile dell'indice del dossier (migliorie d'uso 11):
//
//   ‹ Tutto il portafoglio
//   (MB) Marco Bianchi
//        Mettere al sicuro la famiglia
//   LE POSIZIONI
//   ▌Quadro e posizioni          (6)   ← le sole posizioni in essere
//   LE ANALISI
//    Il patrimonio nel tempo · Prova di resistenza · Coerenza con il profilo · Peso dei costi ·
//    Passaggio generazionale           ← una schermata ciascuna
//   COLLEGATI
//    Il dossier · Analisi 360 · Prodotti · Simulatore · Confronto
//   🔒 Archivio locale
//
// - La voce accesa è la schermata scelta; con la scheda di una posizione aperta nessuna. La voce già scelta non fa
//   niente (la scheda di una posizione aperta si chiude).
// - La schermata scelta è stato in memoria di `AppPosizioni` (`@State`, decisione 14.6): chi da fuori vuole una
//   schermata scrive l'ancora di sempre (`stato.ancoraPosizioni = "coerenza"`), che `AppPosizioni` consuma.
// - In vista portafoglio la colonna resta quella di prima, con i filtri. In modalità cliente niente «‹ Tutto il
//   portafoglio».
// Valori in DesignSystem/Apple/Tema.Apple+Posizioni.swift (`Posizioni.Indice`, `Posizioni.Quadro`) e
// Tema.Apple+Clienti.swift (`Clienti.Indice`, le voci).

// MARK: - Le schermate

/// Le schermate della vista del cliente in Posizioni: il quadro con l'elenco, le cinque analisi e lo smontaggio dei
/// documenti del cliente (migliorie d'uso 42).
enum VistaPosizioniCliente: Hashable, CaseIterable {
    case quadro, patrimonio, resistenza, coerenza, costi, smontaggio, successione

    /// Le ancore di sempre (colonna di prima, dossier, notifiche, istantanee) aprono la schermata dell'analisi.
    init?(ancora: String) {
        switch ancora {
        case "patrimonio": self = .patrimonio
        case "resistenza": self = .resistenza
        case "coerenza": self = .coerenza
        case "costi": self = .costi
        case "successione": self = .successione
        case "smontaggio": self = .smontaggio
        default: return nil
        }
    }

    var titolo: String {
        switch self {
        case .quadro: return "Quadro e posizioni"
        case .patrimonio: return "Il patrimonio nel tempo"
        case .resistenza: return "Prova di resistenza"
        case .coerenza: return "Coerenza con il profilo"
        case .costi: return "Peso dei costi"
        case .smontaggio: return TestiSmontaggio.voceIndice
        case .successione: return "Passaggio generazionale"
        }
    }

    /// Le analisi, nell'ordine dell'indice: lo smontaggio di un documento prima del passaggio generazionale.
    static let analisi: [VistaPosizioniCliente] = [.patrimonio, .resistenza, .coerenza, .costi, .smontaggio, .successione]
}

// MARK: - Indice

/// L'indice delle posizioni del cliente scelto, nella colonna di sinistra di Posizioni.
struct IndicePosizioniApple: View {
    @Environment(StatoShell.self) var stato
    let cliente: Cliente
    /// La schermata scelta (nil con la scheda di una posizione aperta: nessuna voce accesa).
    let scelta: VistaPosizioniCliente?
    let scegli: (VistaPosizioniCliente) -> Void

    var body: some View {
        let _ = ContaCorpi.segna()
        let k = Tema.Apple.Clienti.Indice.self
        // Le sole posizioni in essere (senza le proposte), dai conti per area già in cache
        let inEssere = stato.contiAreePosizioni(portafoglio: false, canale: nil, stato: .inEssere).totale
        return VStack(alignment: .leading, spacing: 6) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if !stato.inModoCliente {
                        VoceIndiceCornice(scelta: false, azione: { stato.scegliCliente(nil, avviso: true) }) {
                            HStack(spacing: k.spazioVoce) {
                                Image(systemName: "chevron.left")
                                    .font(k.simboloRitorno.font)
                                Text(TestiSceltaCliente.tuttoIlPortafoglio)
                                    .carattereApple(k.ritorno)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                            }
                            .foregroundColor(k.coloreRitorno)
                        }
                        .help(TestiSceltaCliente.aiutoTuttoIlPortafoglio)
                        .accessibilityLabel(TestiSceltaCliente.tuttoIlPortafoglio)
                    }
                    testa
                    etichetta("Le posizioni")
                    voce(.quadro, numero: inEssere)
                    etichetta("Le analisi")
                    ForEach(VistaPosizioniCliente.analisi, id: \.self) { v in
                        // Lo smontaggio porta il numero dei documenti smontati del cliente (dato ricavato)
                        voce(v, numero: v == .smontaggio ? stato.documentiSmontati(clienteId: cliente.id).count : 0)
                    }
                    etichetta("Collegati")
                    collegamento("Il dossier") { stato.apri(.clienti) }
                    ForEach([AppPrisma.analisi360, .prodotti]) { app in
                        collegamento(app.titolo) { stato.apri(app) }
                    }
                    // Simulatore e Confronto: strumenti di Analisi 360 (sul Mac si aprono lì)
                    ForEach([StrumentoAnalisi.simulatore, .confronto]) { s in
                        collegamento(s.titolo) { stato.apriStrumentoAnalisi(s) }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Tema.Misura.Dossier.sfumaturaRail)
            }
            // L'ultima voce sfuma prima del piede invece di finire tagliata sul filo
            .mask {
                VStack(spacing: 0) {
                    Color.black
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: Tema.Misura.Dossier.sfumaturaRail)
                }
            }
            ArchivioLocaleRail()
        }
        .padding(k.padding)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    /// Avatar 40, nome 14,5 bold e motto 12 grigio, come nell'indice del dossier.
    private var testa: some View {
        let k = Tema.Apple.Clienti.Indice.self
        return HStack(spacing: k.spazioTesta) {
            AvatarCliente(iniziali: cliente.iniziali, tinta: cliente.tinta.colori, lato: k.avatar)
            VStack(alignment: .leading, spacing: k.spazioNomeMotto) {
                Text(cliente.nome)
                    .carattereApple(k.nome)
                    .foregroundColor(k.coloreNome)
                if !cliente.tema.isEmpty {
                    Text(cliente.tema)
                        .carattereApple(k.motto)
                        .foregroundColor(k.coloreMotto)
                }
            }
            .lineLimit(1)
            .truncationMode(.tail)
        }
        .padding(k.paddingTesta)
    }

    private func etichetta(_ testo: String) -> some View {
        let k = Tema.Apple.Clienti.Indice.self
        return Text(testo)
            .carattereApple(k.etichettaGruppo)
            .foregroundColor(k.coloreEtichettaGruppo)
            .padding(k.paddingEtichettaGruppo)
    }

    /// Una schermata: accesa se scelta, con il numero a destra (zero = niente numero).
    private func voce(_ v: VistaPosizioniCliente, numero: Int) -> some View {
        let k = Tema.Apple.Clienti.Indice.self
        let accesa = scelta == v
        return VoceIndiceCornice(scelta: accesa, azione: { scegli(v) }) {
            HStack(spacing: k.spazioVoce) {
                Text(v.titolo)
                    .carattereApple(k.voce)
                    .foregroundColor(k.coloreVoce)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if numero > 0 {
                    NumeroIndice(n: numero, tono: .neutro)
                }
            }
        }
        .accessibilityLabel(numero > 0 ? "\(v.titolo), \(numero)" : v.titolo)
        .accessibilityAddTraits(accesa ? AccessibilityTraits.isSelected : AccessibilityTraits())
    }

    /// Un collegamento a un'altra app: mai acceso.
    private func collegamento(_ titolo: String, azione: @escaping () -> Void) -> some View {
        let k = Tema.Apple.Clienti.Indice.self
        return VoceIndiceCornice(scelta: false, azione: azione) {
            HStack(spacing: k.spazioVoce) {
                Text(titolo)
                    .carattereApple(k.voce)
                    .foregroundColor(k.coloreVoce)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
        }
        .accessibilityLabel(titolo)
    }
}

// MARK: - La riga in testa

/// Il titolo della riga in testa di Posizioni (FinestraInterna.swift): con un cliente scelto «Le posizioni di
/// Marco.» e «{n} in essere · {n} proposte · aggiornate adesso»; nel portafoglio titolo e occhiello di sempre.
struct TitoloRigaPosizioni: View {
    @Environment(StatoShell.self) var stato
    let attiva: Bool
    let occhiello: Bool

    var body: some View {
        let t = Tema.Apple.RigaTesta.self
        let titolo: String
        let sotto: String
        if !stato.portafoglio, let c = stato.clienteAttivo {
            titolo = "Le posizioni di \(StatoShell.nomeDiBattesimo(c))."
            let inEssere = stato.contiAreePosizioni(portafoglio: false, canale: nil, stato: .inEssere).totale
            let proposte = stato.contiAreePosizioni(portafoglio: false, canale: nil, stato: .proposta).totale
            sotto = "\(inEssere) in essere · \(proposte) \(proposte == 1 ? "proposta" : "proposte") · aggiornate adesso"
        } else {
            titolo = AppPrisma.posizioni.titoloIntestazione
            sotto = AppPrisma.posizioni.occhiello
        }
        return HStack(alignment: .center, spacing: t.spazio) {
            Text(titolo)
                .carattereApple(t.titolo)
                .foregroundColor(attiva ? t.coloreTitolo : t.coloreTitoloSpento)
                .lineLimit(1)
            if occhiello {
                Text(sotto)
                    .carattereApple(t.sottotitolo)
                    .foregroundColor(t.coloreSottotitolo)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Istantanee

/// Ciò che una scena delle istantanee chiede alla vista del cliente di Posizioni (Prisma --istantanee): il filtro di
/// canale già acceso. Vale solo per lo stato della scena (riferimento debole: le scene dopo non lo vedono).
final class RichiestaIstantaneaPosizioni {
    nonisolated(unsafe) private static var attuale: RichiestaIstantaneaPosizioni?

    private weak var stato: StatoShell?
    let canale: Canale?

    private init(stato: StatoShell, canale: Canale?) {
        self.stato = stato
        self.canale = canale
    }

    static func chiedi(_ s: StatoShell, canale: Canale?) {
        attuale = RichiestaIstantaneaPosizioni(stato: s, canale: canale)
    }

    static func per(_ s: StatoShell) -> RichiestaIstantaneaPosizioni? {
        guard let r = attuale, r.stato === s else { return nil }
        return r
    }
}
#endif
