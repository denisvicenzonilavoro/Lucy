#if os(macOS)
import SwiftUI

// Migliorie d'uso 58 «Un solo modo di mostrare» (Design/uso/gruppo-10.md §58, template righe 4752-4769): il tavolo non è
// più un secondo pulsante in ogni palco, ma un'etichetta della vista del cliente, subito prima di «DV» nella barra:
// «Su questo schermo» o «iPad sul tavolo», con il menu «Manda sull’iPad sul tavolo» / «Torna su questo schermo», «Il
// cliente può toccare l’iPad: no/sì» e «Chiedi la presa visione».
//
// - L'iPad segue la vista del cliente usando solo i messaggi del tavolo di oggi (decisione 58-a): l'immagine ferma del
//   capitolo o del palco, la pagina del prospetto, e con «può toccare: sì» i generi vivi della Sala e il prospetto da
//   sfogliare (decisione 58-b). Mai fuori dalla vista del cliente; le cifre del cliente passano sempre dalla conferma
//   del consulente (decisione 49), una volta per cliente finché il tavolo resta aperto.
// - All'uscita dalla vista l'iPad torna alla schermata neutra e il tavolo resta in ascolto (decisione 58-c).
// - Con l'iPad non collegato la voce resta: a tavolo chiuso lo apre e manda appena l'iPad arriva; mai le Impostazioni
//   dentro la vista del cliente (decisione 58-d).
// Tutto in memoria. Le viste: l'etichetta in BarraSuperiore.swift, il menu in VistaCliente.swift, la presa visione in
// PresaVisioneMac.swift. Valori in Tema.Apple.MostraAlCliente.Luogo.

/// Dove guarda il cliente nella vista pulita.
enum LuogoCliente: Hashable {
    case schermo, tavolo
}

/// I testi dell'etichetta del luogo e del suo menu (template righe 4757-4769).
enum TestiLuogo {
    static let schermo = "Su questo schermo"
    static let tavolo = "iPad sul tavolo"
    static let glifoSchermo = "display"
    static let glifoTavolo = "ipad.landscape"
    static let aiuto = "Dove guarda il cliente: questo schermo o l’iPad sul tavolo"
    static let manda = "Manda sull’iPad sul tavolo"
    static let torna = "Torna su questo schermo"
    static func tocca(_ si: Bool) -> String { "Il cliente può toccare l’iPad: \(si ? "sì" : "no")" }
    static let presa = "Chiedi la presa visione"
    static let nonCollegato = "iPad non collegato"
    static let avvisoTavolo = "L’iPad sul tavolo mostra quello che vedi qui: tu guidi dal Mac"
    static let avvisoQuadro = "L’iPad sul tavolo mostra il quadro: tu guidi dal Mac"
    static let avvisoSchermo = "Il cliente guarda di nuovo questo schermo"
    static let avvisoTocca = "Sull’iPad adesso può toccare anche il cliente"
    static let avvisoGuidi = "Sull’iPad guidi solo tu"
    static let rischioTocca = "Per far rispondere il cliente sull’iPad, scegli «Il cliente può toccare l’iPad: sì»"
    static let tavoloAperto = "Il tavolo è aperto: appena l’iPad si collega, mostra quello che vedi qui"
    static let tavoloSpento = "«Al tavolo» è spento in Impostazioni › iPhone e iPad: si accende dopo l’incontro"
    static let immagineGuasta = "Non riesco a preparare l’immagine per l’iPad."
    static let nienteDaConfermare = "Sull’iPad non c’è ancora niente da far confermare: aspetta che compaia quello che vedi qui."
}

extension StatoShell {
    // MARK: L'etichetta e il suo menu

    /// «Manda sull’iPad sul tavolo»: il cliente guarda l'iPad, che segue la vista. Solo dentro la vista del cliente. A
    /// tavolo chiuso lo apre e manda appena l'iPad si collega; con l'iPad atteso e non ancora arrivato non fa nulla.
    func mandaAlTavolo(avviso testo: String = TestiLuogo.avvisoTavolo) {
        guard inVistaCliente else { return }
        menuLuogo = false
        guard tavolo.collegato else {
            guard tavolo.permesso else {
                mostraAvviso(TestiLuogo.tavoloSpento)
                return
            }
            if !tavolo.acceso { tavolo.avvia() }
            tavoloInArrivo = true
            mostraAvviso(TestiLuogo.tavoloAperto)
            return
        }
        tavoloInArrivo = false
        tavoloTocca = false
        documentoSeguito = nil
        if luogoCliente != .tavolo { luogoCliente = .tavolo }
        mostraAvviso(testo)
    }

    /// «Torna su questo schermo»: il cliente guarda di nuovo il Mac; l'iPad torna alla schermata neutra e i pulsanti del
    /// consulente spariscono dal palco (il copione si chiude).
    func tornaSulloSchermo(avviso: Bool = true) {
        menuLuogo = false
        tavoloInArrivo = false
        guard luogoCliente == .tavolo else { return }
        luogoCliente = .schermo
        tavoloTocca = false
        documentoSeguito = nil
        if cifreLuogoDaConfermare { cifreLuogoDaConfermare = false }
        if sala.copioneAperto { sala.copioneAperto = false }
        if sala.confermaCifreTavolo != nil { sala.confermaCifreTavolo = nil }
        if sala.tavoloEsperienza != nil { sala.tavoloEsperienza = nil }
        tavolo.schermataNeutra()
        if avviso { mostraAvviso(TestiLuogo.avvisoSchermo) }
    }

    /// «Il cliente può toccare l’iPad»: l'interruttore (si parte da «no»). L'iPad si aggiorna da `OsservatoreLuogo`.
    func cambiaTocco() {
        guard luogoCliente == .tavolo else { return }
        menuLuogo = false
        tavoloTocca.toggle()
        documentoSeguito = nil
        mostraAvviso(tavoloTocca ? TestiLuogo.avvisoTocca : TestiLuogo.avvisoGuidi)
    }

    /// Il menu dell'etichetta si apre (chiude quello dell'avatar) o si chiude.
    func alternaMenuLuogo() {
        if menuUscitaMostra { menuUscitaMostra = false }
        menuLuogo.toggle()
    }

    /// All'uscita dalla vista del cliente (o al blocco): l'iPad torna neutro, il tavolo resta in ascolto (decisione 58-c).
    func azzeraLuogo() {
        if luogoCliente == .tavolo { tornaSulloSchermo(avviso: false) }
        tavoloInArrivo = false
        avvisoRischioToccoVisto = false
        if menuLuogo { menuLuogo = false }
        if presaVisioneAperta { presaVisioneAperta = false }
        if cifreLuogoDaConfermare { cifreLuogoDaConfermare = false }
    }

    // MARK: L'iPad segue lo schermo

    /// Manda all'iPad ciò che la vista del cliente mostra, con i soli messaggi del tavolo di oggi. Solo con il cliente
    /// sull'iPad e l'iPad collegato; le cifre del cliente chiedono prima la conferma (decisione 49). La chiama
    /// `OsservatoreLuogo` a ogni cambio di capitolo, di esperienza, di pagina, di schermata neutra o di «può toccare».
    @MainActor
    func seguiSulTavolo() {
        guard inVistaCliente, luogoCliente == .tavolo, tavolo.collegato, let capitolo = vistaCliente, let c = clienteAttivo else { return }
        // La schermata neutra copre anche l'iPad
        if schermataNeutraMac {
            tavolo.schermataNeutra()
            return
        }
        // Il prospetto a tutto schermo: la pagina che si guarda, o con «può toccare» tutto il documento da sfogliare
        if let p = presentazione, !p.pagine.isEmpty {
            guard cifreConfermate(c) else { return }
            let d = DocumentoStampabile(titolo: p.titolo, cliente: p.cliente, genere: p.genere, formato: p.formato,
                                        pagine: p.pagine, tipo: p.tipoDocumento)
            let contesto = ContestoTavolo(documento: d, pagina: p.pagina, clienteId: c.id)
            if tavoloTocca {
                let chiave = "\(c.id)|\(p.titolo)|\(p.pagine.count)"
                guard documentoSeguito != chiave else { return }
                documentoSeguito = chiave
                tavolo.mandaDocumento(contesto)
            } else {
                documentoSeguito = nil
                tavolo.mandaPagina(contesto)
            }
            return
        }
        documentoSeguito = nil
        if capitolo == .sala, let e = sala.esperienza {
            seguiEsperienza(e, cliente: c)
            return
        }
        if sala.tavoloEsperienza != nil { sala.tavoloEsperienza = nil }
        if capitolo == .sala {
            // La griglia della Sala non porta cifre del cliente
            mandaImmagineVista(GrigliaSalaFerma(cliente: c), titolo: capitolo.titolo, cliente: c, cifre: false)
            return
        }
        guard cifreConfermate(c) else { return }
        mandaImmagineVista(CapitoloClienteFermo(capitolo: capitolo, cliente: c), titolo: capitolo.titolo, cliente: c, cifre: true)
    }

    /// Un'esperienza sul palco: con «può toccare» il genere vivo di oggi (rischio, Lancia l'anno, disegno, realtà
    /// aumentata), la lettera come la sua pagina; altrimenti l'immagine ferma del palco. La capsula si scrive sull'iPad
    /// solo dal suo «Scrivi sull’iPad».
    @MainActor
    private func seguiEsperienza(_ e: EsperienzaSala, cliente c: Cliente) {
        let vivo = tavoloTocca && e.genereTavolo != nil && e != .capsula
        let lettera = e == .lettera && sala.stesureLettera[c.id]?[sala.versioneLettera] != nil
        if vivo || lettera {
            mostraEsperienzaSulTavolo(e, cliente: c.id)
            return
        }
        if e == .giocoRischio && !tavoloTocca && !avvisoRischioToccoVisto {
            avvisoRischioToccoVisto = true
            mostraAvviso(TestiLuogo.rischioTocca)
        }
        if sala.tavoloEsperienza != nil { sala.tavoloEsperienza = nil }
        if e.cifreSulTavolo && tavolo.cifreDaConfermare(c.id) {
            sala.confermaCifreTavolo = e
            return
        }
        sala.confermaCifreTavolo = nil
        mandaImmaginePalco(e, cliente: c)
    }

    /// Le cifre del cliente sono già confermate per l'iPad; altrimenti compare la riga di conferma e l'iPad resta neutro.
    private func cifreConfermate(_ c: Cliente) -> Bool {
        if tavolo.cifreDaConfermare(c.id) {
            if !cifreLuogoDaConfermare { cifreLuogoDaConfermare = true }
            return false
        }
        if cifreLuogoDaConfermare { cifreLuogoDaConfermare = false }
        return true
    }

    /// «Mostra» della riga di conferma dei capitoli: le cifre del cliente vanno sull'iPad.
    @MainActor
    func confermaCifreLuogo() {
        guard let c = clienteAttivo else { return }
        tavolo.confermaCifre(c.id)
        cifreLuogoDaConfermare = false
        seguiSulTavolo()
    }

    // MARK: Le immagini

    /// Una vista disegnata nello stato finale, scura, alla misura del palco di oggi (decisione 111), mandata all'iPad come
    /// pagina, con la sua pagina su carta per la presa visione.
    @MainActor
    func mandaImmagineVista<Contenuto: View>(_ vista: Contenuto, titolo: String, cliente c: Cliente, cifre: Bool) {
        let misura = Tema.Apple.RealtaAumentata.ImmaginePalco.misura
        guard let immagine = immagineVista(vista), let png = ProtocolloTavolo.png(immagine) else {
            mostraAvviso(TestiLuogo.immagineGuasta)
            return
        }
        let carta = Self.documentoVista(immagine, titolo: titolo, cliente: c.nome)
        tavolo.mandaImmagine(ContestoTavolo(documento: nil, pagina: 0, clienteId: c.id), titolo: titolo, png: png, misura: misura,
                             cifre: cifre, documento: carta)
    }

    /// La vista in un'immagine: stato finale (`\.modoIstantanea`), scura, sul fondo del palco.
    @MainActor
    func immagineVista<Contenuto: View>(_ vista: Contenuto) -> CGImage? {
        let misura = Tema.Apple.RealtaAumentata.ImmaginePalco.misura
        let contenuto = vista
            .environment(self)
            .environment(\.modoIstantanea, true)
            .environment(\.colorScheme, .dark)
            .frame(width: misura.width, height: misura.height)
            .background(Tema.Apple.RealtaAumentata.ImmaginePalco.fondo)
        let r = ImageRenderer(content: contenuto)
        r.proposedSize = ProposedViewSize(misura)
        r.scale = Tema.Apple.RealtaAumentata.ImmaginePalco.scala
        return r.immaginePrisma
    }

    /// L'immagine di ciò che si vedeva su una pagina di carta bianca (come le pagine del PDF: niente vetro).
    static func documentoVista(_ immagine: CGImage, titolo: String, cliente: String) -> DocumentoStampabile {
        let pagina = AnyView(PaginaVistaMostrata(titolo: titolo, cliente: cliente, immagine: immagine))
        return DocumentoStampabile(titolo: titolo, cliente: cliente, genere: "Prospetto",
                                   formato: Tema.Apple.Tavolo.PresaVisione.Pagina.formato, pagine: [pagina], tipo: .prospetto)
    }

    /// Ciò che la vista del cliente mostra adesso, su carta (per la presa visione sul Mac): la pagina del prospetto, il
    /// palco dell'esperienza o il capitolo.
    @MainActor
    func documentoDiCioCheSiVede() -> DocumentoStampabile? {
        guard let capitolo = vistaCliente, let c = clienteAttivo else { return nil }
        if let p = presentazione, !p.pagine.isEmpty {
            let i = min(max(p.pagina, 0), p.pagine.count - 1)
            return DocumentoStampabile(titolo: p.titolo, cliente: p.cliente, genere: p.genere, formato: p.formato,
                                       pagine: [p.pagine[i]], tipo: p.tipoDocumento)
        }
        let titolo: String
        let immagine: CGImage?
        if capitolo == .sala, let e = sala.esperienza {
            titolo = e.titolo
            immagine = immagineVista(ContenutoPalco(esperienza: e, cliente: c, inSala: true))
        } else if capitolo == .sala {
            titolo = capitolo.titolo
            immagine = immagineVista(GrigliaSalaFerma(cliente: c))
        } else {
            titolo = capitolo.titolo
            immagine = immagineVista(CapitoloClienteFermo(capitolo: capitolo, cliente: c))
        }
        guard let immagine else { return nil }
        return Self.documentoVista(immagine, titolo: titolo, cliente: c.nome)
    }
}

// MARK: - La pagina su carta

/// Una pagina bianca con il titolo e l'immagine di ciò che si vedeva (un capitolo o un palco). Colori opachi e fissi.
struct PaginaVistaMostrata: View {
    let titolo: String
    let cliente: String
    let immagine: CGImage

    private typealias P = Tema.Apple.Tavolo.PresaVisione.Pagina

    var body: some View {
        FoglioDocumento(formato: P.formato) {
            VStack(alignment: .leading, spacing: P.spazio) {
                Text(verbatim: "\(titolo) · \(cliente)")
                    .carattereApple(P.titolo)
                    .foregroundColor(P.inchiostro)
                Image(decorative: immagine, scale: 1)
                    .resizable()
                    .interpolation(.high)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: P.raggioImmagine, style: .continuous))
                    .frame(maxWidth: .infinity)
                Spacer(minLength: 0)
                Text(verbatim: "Quello che era sullo schermo durante l’incontro, così come l’ha visto il cliente.")
                    .carattereApple(P.nota)
                    .foregroundColor(P.inchiostro2)
            }
            .padding(P.margine)
        }
    }
}

// MARK: - L'osservatore

/// Segue i soli valori che cambiano ciò che il cliente vede (capitolo, esperienza, pagina, schermata neutra, luogo e
/// «può toccare») e, a vista ferma, chiama `seguiSulTavolo()`: mai nel body, una volta per cambio. Osserva il tavolo per
/// mandare appena l'iPad si collega.
struct OsservatoreLuogo: View {
    @Environment(StatoShell.self) var stato
    @ObservedObject var tavolo: TavoloMac
    @Environment(\.modoIstantanea) private var istantanea

    private struct Chiave: Hashable {
        let capitolo: CapitoloCliente?
        let esperienza: EsperienzaSala?
        let pagina: Int?
        let titolo: String?
        let neutra: Bool
        let luogo: LuogoCliente
        let tocca: Bool
        let collegato: Bool
        let cliente: String
    }

    var body: some View {
        let chiave = Chiave(capitolo: stato.vistaCliente, esperienza: stato.sala.esperienza, pagina: stato.presentazione?.pagina,
                            titolo: stato.presentazione?.titolo, neutra: stato.schermataNeutraMac, luogo: stato.luogoCliente,
                            tocca: stato.tavoloTocca, collegato: tavolo.collegato, cliente: stato.clienteAttivoId)
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .task(id: chiave) {
                // Nelle istantanee il tavolo è finto (nessuna rete): niente da mandare
                guard !istantanea, chiave.luogo == .tavolo, chiave.collegato else { return }
                let attesa = Tema.Apple.Moto.tempo(Tema.Apple.MostraAlCliente.Luogo.attesaSegui)
                try? await Task.sleep(nanoseconds: UInt64(attesa * 1_000_000_000))
                guard !Task.isCancelled else { return }
                stato.seguiSulTavolo()
            }
            .onChange(of: tavolo.collegato) { _, collegato in
                if collegato && stato.tavoloInArrivo && !istantanea { stato.mandaAlTavolo() }
            }
    }
}

// MARK: - La conferma delle cifre dei capitoli

/// «Sull'iPad compaiono le cifre di Giulia. Vanno bene per chi è al tavolo?» sotto la barra, al centro: la vede il
/// consulente sul Mac (il cliente guarda l'iPad, che resta neutro finché non si preme «Mostra»).
struct ConfermaCifreLuogo: View {
    @Environment(StatoShell.self) var stato

    private typealias K = Tema.Apple.RealtaAumentata.Conferma

    var body: some View {
        if stato.cifreLuogoDaConfermare, stato.luogoCliente == .tavolo, let c = stato.clienteAttivo {
            HStack(spacing: K.spazio) {
                Text(TestiRealta.confermaCifre(TestiRealta.primoNome(c.nome)))
                    .carattereApple(K.testo)
                    .foregroundColor(K.inchiostro)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: K.spazio)
                Button("Annulla") { stato.cifreLuogoDaConfermare = false }
                    .buttonStyle(.apple)
                Button("Mostra") { stato.confermaCifreLuogo() }
                    .buttonStyle(.applePrimario)
            }
            .padding(K.padding)
            .frame(maxWidth: K.larghezza)
            .background(RoundedRectangle(cornerRadius: K.raggio, style: .continuous).fill(K.fondo))
            .overlay(RoundedRectangle(cornerRadius: K.raggio, style: .continuous).strokeBorder(K.bordo, lineWidth: 1))
            .environment(\.colorScheme, .light)
            .transition(.opacity)
        }
    }
}
#endif
