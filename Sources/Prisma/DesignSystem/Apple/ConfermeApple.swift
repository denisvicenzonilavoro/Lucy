import SwiftUI

// Migliorie d'uso 68 «Quello che Prisma prepara da solo si conferma allo stesso modo» (Design/uso/gruppo-11.md §68.3
// punto 1): i componenti comuni delle conferme. Quando Prisma fa da sola (Stanotte, la nota vocale, Inquadra, la lettura
// di un documento) la regola è una: il verde è pronto, l'arancione chiede una risposta, ogni cosa si può annullare, un
// pulsante solo chiude e non è blu finché resta dell'arancione. Valori in `Tema.Apple.Conferme`.
// La scossa (`ScuotiEffetto`, `ScuotiConferma`) compila anche su iPhone e iPad perché la usano viste comuni; le righe e il
// pulsante solo sono del Mac.

/// Lo stato di una riga di conferma.
enum StatoConferma {
    /// Pronta (verde): si fa con il pulsante solo.
    case fatta
    /// Chiede una risposta (arancione).
    case daDecidere
    /// Tolta da ciò che si fa (sbiadita): si rimette.
    case annullata
    /// Una risposta data: la capsula con il suo tono (`.ok` verde per «Aggiornato», `.neutro` per «Lasciato com’era»).
    case decisa(testo: String, tono: Pillola.Tono)

    /// Il segno a sinistra: «✓» per fatta, decisa e annullata, «?» per da decidere.
    var segno: String {
        if case .daDecidere = self { return "?" }
        return "✓"
    }

    /// Letto prima del contenuto da VoiceOver.
    var perAccessibilita: String {
        switch self {
        case .fatta, .decisa: return "Fatto"
        case .daDecidere: return "Da decidere"
        case .annullata: return "Annullato"
        }
    }

    var daDecidere: Bool {
        if case .daDecidere = self { return true }
        return false
    }

    var annullata: Bool {
        if case .annullata = self { return true }
        return false
    }
}

/// Lo scuotimento orizzontale (Animatable, niente Timer): `animatableData` è un contatore, ogni unità un'oscillazione
/// intera di `volte` giri. Usato dall'interruttore bloccato dei motori di Vera, da Inquadra, da Aggiorna valori e dalle
/// conferme.
struct ScuotiEffetto: GeometryEffect {
    var ampiezza: CGFloat
    var volte: CGFloat
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: ampiezza * sin(animatableData * .pi * volte * 2), y: 0))
    }
}

/// La scossa della riga in arancione: 0 → −6 → +6 → 0 in 0,3 s al ritmo del tema, avviata dall'aumento di `scosse`
/// (`withAnimation(Tema.Apple.Conferme.animazioneScossa) { scosse += 1 }`). Ferma con «Riduci movimento» e nelle
/// istantanee.
struct ScuotiConferma: ViewModifier {
    var scosse: CGFloat
    var attiva = true

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    /// L'ampiezza della scossa: zero quando non è la riga scelta, con calma e nelle istantanee.
    static func ampiezza(attiva: Bool, calmo: Bool, istantanea: Bool) -> CGFloat {
        attiva && !calmo && !istantanea ? -Tema.Apple.Conferme.scossa : 0
    }

    func body(content: Content) -> some View {
        content.modifier(ScuotiEffetto(ampiezza: Self.ampiezza(attiva: attiva, calmo: calmo, istantanea: istantanea),
                                       volte: Tema.Apple.Conferme.volteScossa, animatableData: scosse))
    }
}

#if os(macOS)

/// Una riga di conferma: il segno a sinistra, il contenuto, a destra le azioni (e la capsula di una risposta data).
/// Da decidere: fondo arancio tenue; annullata: sbiadita.
struct RigaConfermaApple<Contenuto: View, Azioni: View>: View {
    let stato: StatoConferma
    let contenuto: () -> Contenuto
    let azioni: () -> Azioni

    private typealias K = Tema.Apple.Conferme

    init(_ stato: StatoConferma, @ViewBuilder contenuto: @escaping () -> Contenuto, @ViewBuilder azioni: @escaping () -> Azioni) {
        self.stato = stato
        self.contenuto = contenuto
        self.azioni = azioni
    }

    var body: some View {
        let forma = RoundedRectangle(cornerRadius: K.raggioRiga, style: .continuous)
        HStack(alignment: .center, spacing: K.spazio) {
            Text(stato.segno)
                .carattereApple(K.segno)
                .foregroundColor(coloreSegno)
                .frame(width: K.larghezzaSegno, alignment: .leading)
                .accessibilityLabel(Text(stato.perAccessibilita))
            VStack(alignment: .leading, spacing: 0) {
                contenuto()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if case .decisa(let testo, let tono) = stato {
                Pillola(testo: testo, tono: tono)
            }
            HStack(spacing: K.spazioAzioni) {
                azioni()
            }
            .fixedSize()
        }
        .padding(K.paddingRiga)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(forma.fill(stato.daDecidere ? K.fondoDubbio : K.fondoRiga))
        .opacity(stato.annullata ? K.opacitaAnnullata : 1)
        .accessibilityElement(children: .contain)
    }

    private var coloreSegno: Color {
        switch stato {
        case .fatta, .decisa: return K.coloreFatta
        case .daDecidere: return K.coloreDubbio
        case .annullata: return K.coloreAnnullata
        }
    }
}

extension RigaConfermaApple where Azioni == EmptyView {
    /// Una riga senza azioni (decisa altrove o in sola lettura).
    init(_ stato: StatoConferma, @ViewBuilder contenuto: @escaping () -> Contenuto) {
        self.init(stato, contenuto: contenuto, azioni: { EmptyView() })
    }
}

/// Il collegamento standard «Annulla» / «Rimetti» delle righe pronte.
struct AnnullaRimettiApple: View {
    let annullata: Bool
    let azione: () -> Void

    private typealias K = Tema.Apple.Conferme

    var body: some View {
        Button(action: azione) {
            Text(annullata ? TestiConferme.rimetti : TestiConferme.annulla)
                .carattereApple(K.collegamento)
                .foregroundColor(K.coloreCollegamento)
        }
        .buttonStyle(StileSemplice())
        .help(annullata ? TestiConferme.aiutoRimetti : TestiConferme.aiutoAnnulla)
    }
}

/// Un collegamento della riga (stesso aspetto di «Annulla»): «Modifica», «Cambia», «Apri l’obiettivo».
struct CollegamentoConfermaApple: View {
    let testo: String
    let azione: () -> Void

    private typealias K = Tema.Apple.Conferme

    var body: some View {
        Button(action: azione) {
            Text(testo)
                .carattereApple(K.collegamento)
                .foregroundColor(K.coloreCollegamento)
        }
        .buttonStyle(StileSemplice())
    }
}

/// Il pulsante solo in fondo: grande, in stile normale finché restano dubbi (premuto chiama `primoDubbio`, che scuote la
/// riga e mostra l'avviso), blu quando non ce ne sono più (↩ solo allora).
struct PulsanteChiusuraConferma: View {
    let dubbi: Int
    let testoDubbi: String
    let testoPronto: String
    let azione: () -> Void
    let primoDubbio: () -> Void

    var body: some View {
        if dubbi > 0 {
            Button(action: primoDubbio) { Text(testoDubbi) }
                .buttonStyle(.appleGrande)
        } else {
            Button(action: azione) { Text(testoPronto) }
                .buttonStyle(.applePrimarioGrande)
                .keyboardShortcut(.defaultAction)
        }
    }
}

/// I testi comuni delle conferme.
enum TestiConferme {
    static let annulla = "Annulla"
    static let rimetti = "Rimetti"
    static let aiutoAnnulla = "Toglila da ciò che si fa"
    static let aiutoRimetti = "Rimettila fra ciò che si fa"
    static let primaRispondi = "Prima rispondi alla riga in arancione"
    static let vaBeneCosi = "Va bene così"

    /// «Rispondi alla riga in arancione» / «Rispondi alle 2 righe in arancione».
    static func rispondi(_ n: Int) -> String {
        n <= 1 ? "Rispondi alla riga in arancione" : "Rispondi alle \(n) righe in arancione"
    }
}

// MARK: - Vetrina

/// I componenti delle conferme in tutti gli stati (istantanea «1315-uso-conferme-vetrina», chiara e scura).
struct VetrinaConferme: View {
    private typealias K = Tema.Apple.Conferme

    var body: some View {
        VStack(alignment: .leading, spacing: K.spazioRighe) {
            Text("Le conferme")
                .carattereApple(Tema.Apple.Carattere.etichetta)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
            riga(.fatta, "Nota per il dossier", "«Giulia vuole anticipare la casa di un anno.»") {
                AnnullaRimettiApple(annullata: false) {}
            }
            riga(.annullata, "Attività da creare", "Risentire Giulia per il mutuo · gennaio") {
                AnnullaRimettiApple(annullata: true) {}
            }
            riga(.daDecidere, "Obiettivo da aggiornare", "Casa: un anno prima · da confermare") {
                Button("Aggiorna") {}.buttonStyle(.applePrimario)
                Button("No") {}.buttonStyle(.apple)
            }
            riga(.decisa(testo: "Aggiornato", tono: .ok), "Obiettivo aggiornato", "Casa: un anno prima · aggiornato") {
                CollegamentoConfermaApple(testo: "Cambia") {}
            }
            riga(.decisa(testo: "Lasciato com’era", tono: .neutro), "Obiettivo", "Casa: resta com’era") {
                CollegamentoConfermaApple(testo: "Cambia") {}
            }
            HStack(spacing: K.spazioPiede) {
                PulsanteChiusuraConferma(dubbi: 1, testoDubbi: TestiConferme.rispondi(1), testoPronto: TestiConferme.vaBeneCosi,
                                         azione: {}, primoDubbio: {})
                PulsanteChiusuraConferma(dubbi: 0, testoDubbi: TestiConferme.rispondi(1), testoPronto: TestiConferme.vaBeneCosi,
                                         azione: {}, primoDubbio: {})
            }
            .padding(.top, K.sopraPiede)
        }
        .padding(Tema.Apple.NotaVocale.Scheda.padding)
        .frame(width: Tema.Apple.NotaVocale.Scheda.larghezza, alignment: .leading)
        .superficieApple(Tema.Apple.NotaVocale.Scheda.superficie)
    }

    private func riga<A: View>(_ stato: StatoConferma, _ titolo: String, _ testo: String,
                               @ViewBuilder azioni: @escaping () -> A) -> some View {
        RigaConfermaApple(stato, contenuto: {
            Text(titolo)
                .carattereApple(Tema.Apple.NotaVocale.Voce.titolo)
                .foregroundColor(Tema.Apple.NotaVocale.Voce.coloreTitolo)
            Text(testo)
                .carattereApple(Tema.Apple.NotaVocale.Voce.riga)
                .foregroundColor(Tema.Apple.NotaVocale.Voce.coloreRiga)
        }, azioni: azioni)
    }
}
#endif
