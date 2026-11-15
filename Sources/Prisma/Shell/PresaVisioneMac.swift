#if os(macOS)
import SwiftUI

// Migliorie d'uso 58: «Chiedi la presa visione» dall'etichetta del luogo (template `apriPresa`, righe 4759-4764): una
// scheda centrata con occhiello «Presa visione», «<Nome> conferma di aver visto.», la frase per il cliente (decisione
// 58-e: «Non è una firma di contratto…»; nel PDF resta `ProtocolloTavolo.testoPresaVisione`) e il riquadro tratteggiato.
// - Con il cliente davanti al Mac il tratto si fa qui, con il mouse o il trackpad (Canvas e trascinamento); l'area parte
//   vuota (il tratto «finto» del template non si porta; nelle istantanee il tratto di prova).
// - Con il cliente sull'iPad parte la richiesta di oggi (`chiediPresaVisione`) per ciò che l'iPad mostra; «Registra la
//   presa visione» si accende quando il tratto è arrivato e il PDF è già nei Documenti.
// Il documento: la pagina di ciò che si vedeva (su carta) e in fondo `PaginaPresaVisione`. Il tratto non si salva da
// nessuna parte se non nel PDF archiviato. Valori in Tema.Apple.Tavolo.PresaVisione.Scheda.

/// I testi della scheda (template righe 4759-4764).
enum TestiPresaVisioneMac {
    static let occhiello = "Presa visione"
    static func titolo(_ nome: String) -> String { "\(nome) conferma di aver visto." }
    static let testo = "Non è una firma di contratto: dice solo che quello che c’è sullo schermo gli è stato mostrato, oggi."
    static let firmaQui = "Firma qui, con il dito o con il mouse"
    static let firmaIPad = "Firma con il dito, sull’iPad"
    static let attesa = "Aspetto il segno dall’iPad…"
    static let registra = "Registra la presa visione"
    static let annulla = "Annulla"
    static let cancella = "Cancella"
    static func resta(_ nome: String) -> String { "Resta nei Documenti di \(nome)" }
    static func registrata(_ nome: String) -> String { "Presa visione registrata: è nei Documenti di \(nome), con data e ora" }
    static let guasta = "Non sono riuscito a creare il PDF della presa visione."
}

extension StatoShell {
    /// «Chiedi la presa visione» del menu del luogo: senza un cliente non si apre. Con il cliente sull'iPad chiede il
    /// segno per ciò che l'iPad mostra (se non mostra ancora niente del cliente, lo dice e non apre la scheda).
    func apriPresaVisione() {
        menuLuogo = false
        guard inVistaCliente, let c = clienteAttivo else { return }
        if luogoCliente == .tavolo {
            guard tavolo.puoChiederePresaVisione(c.id) else {
                mostraAvviso(TestiLuogo.nienteDaConfermare)
                return
            }
            presaVisioneConteggio = tavolo.presaVisioneArchiviate
            tavolo.chiediPresaVisione(ContestoTavolo(documento: nil, pagina: 0, clienteId: c.id))
        }
        presaVisioneAperta = true
    }

    /// «Annulla»: con il cliente sull'iPad la richiesta si ritira e l'iPad torna a ciò che si vede.
    @MainActor
    func annullaPresaVisione() {
        presaVisioneAperta = false
        if luogoCliente == .tavolo, tavolo.attesaPresaVisione != nil {
            tavolo.schermataNeutra()
            seguiSulTavolo()
        }
    }

    /// «Registra la presa visione» con il segno fatto sul Mac: la pagina di ciò che si vede e la pagina della presa
    /// visione, nel PDF nei Documenti del cliente. L'id del documento, o nil.
    @MainActor
    @discardableResult
    func registraPresaVisioneMac(tratto: CGImage) -> String? {
        guard let c = clienteAttivo, let d = documentoDiCioCheSiVede() else {
            mostraAvviso(TestiPresaVisioneMac.guasta)
            return nil
        }
        let completo = TavoloMac.documentoConPresaVisione(d, tratto: tratto, data: Date(), testo: TestiPresaVisione.schermo)
        guard let pdf = StampaCarta.pdf(completo), let id = archiviaProspetto(pdf, documento: completo, cliente: c.id) else {
            mostraAvviso(TestiPresaVisioneMac.guasta)
            return nil
        }
        presaVisioneAperta = false
        mostraAvviso(TestiPresaVisioneMac.registrata(StatoShell.nomeBreve(c)))
        return id
    }

    /// «Registra la presa visione» con il segno arrivato dall'iPad: il PDF è già nei Documenti, la scheda si chiude.
    func chiudiPresaVisioneArrivata() {
        presaVisioneAperta = false
        if let c = clienteAttivo { mostraAvviso(TestiPresaVisioneMac.registrata(StatoShell.nomeBreve(c))) }
    }

    /// Il tratto disegnato sul Mac in un'immagine trasparente (2×), con l'inchiostro della carta, per la pagina del PDF.
    static func immagineTratto(_ tratti: [[CGPoint]], misura: CGSize) -> CGImage? {
        typealias K = Tema.Apple.Tavolo.PresaVisione.Scheda
        let scala = K.scalaTratto
        let w = Int((misura.width * scala).rounded()), h = Int((misura.height * scala).rounded())
        guard w > 0, h > 0, let spazio = CGColorSpace(name: CGColorSpace.sRGB),
              let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: spazio,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        // CoreGraphics ha l'origine in basso: si capovolge, così il tratto resta come lo si è disegnato
        ctx.translateBy(x: 0, y: CGFloat(h))
        ctx.scaleBy(x: scala, y: -scala)
        ctx.setStrokeColor(K.inchiostroCarta)
        ctx.setLineWidth(K.tratto)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        for t in tratti {
            guard let primo = t.first else { continue }
            ctx.move(to: primo)
            if t.count == 1 {
                ctx.addLine(to: CGPoint(x: primo.x + 0.5, y: primo.y))
            } else {
                for p in t.dropFirst() { ctx.addLine(to: p) }
            }
            ctx.strokePath()
        }
        return ctx.makeImage()
    }
}

/// La scheda «Presa visione» al centro, sopra il velo.
struct SchedaPresaVisione: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo
    @ObservedObject var tavolo: TavoloMac
    let cliente: Cliente
    /// I tratti fatti con il mouse o il trackpad, in punti dell'area.
    @State private var tratti: [[CGPoint]] = []
    @State private var misuraArea: CGSize = .zero

    private typealias K = Tema.Apple.Tavolo.PresaVisione.Scheda
    private typealias P = Tema.Apple.MostraAlCliente.Pannello

    var body: some View {
        let nome = StatoShell.nomeBreve(cliente)
        ZStack {
            P.velo
                .contentShape(Rectangle())
                .onTapGesture { stato.annullaPresaVisione() }
            VStack(alignment: .leading, spacing: K.spazio) {
                Text(TestiPresaVisioneMac.occhiello)
                    .carattereApple(K.occhiello)
                    .foregroundColor(K.coloreOcchiello)
                Text(TestiPresaVisioneMac.titolo(nome))
                    .carattereApple(K.titolo)
                    .foregroundColor(K.coloreTitolo)
                    .fixedSize(horizontal: false, vertical: true)
                Text(TestiPresaVisioneMac.testo)
                    .carattereApple(K.testo)
                    .foregroundColor(K.coloreTesto)
                    .fixedSize(horizontal: false, vertical: true)
                area
                pulsanti(nome)
                    .padding(.top, K.sopraPulsanti)
            }
            .padding(K.padding)
            .frame(width: K.larghezza)
            .superficieApple(K.superficie, raggio: K.raggio)
            .entrataScheda(Tema.Apple.Moto.animazione(P.animazione, calmo: calmo), scala: P.entrataScala,
                           ancora: .center, y: P.entrataY)
        }
    }

    private var sulTavolo: Bool { stato.luogoCliente == .tavolo }

    /// Il segno è arrivato dall'iPad e il PDF è nei Documenti.
    private var arrivata: Bool { tavolo.presaVisioneArchiviate > stato.presaVisioneConteggio }

    // MARK: Il riquadro del tratto

    private var area: some View {
        let forma = RoundedRectangle(cornerRadius: K.raggioArea, style: .continuous)
        return VStack(spacing: K.spazio / 2) {
            ZStack {
                if sulTavolo {
                    Text(arrivata ? "✓" : TestiPresaVisioneMac.attesa)
                        .carattereApple(K.sottoArea)
                        .foregroundColor(K.coloreSottoArea)
                } else {
                    tela
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: K.altezzaArea)
            Text(sulTavolo ? TestiPresaVisioneMac.firmaIPad : TestiPresaVisioneMac.firmaQui)
                .carattereApple(K.sottoArea)
                .foregroundColor(K.coloreSottoArea)
        }
        .padding(K.paddingArea)
        .frame(maxWidth: .infinity)
        .overlay(forma.strokeBorder(K.coloreArea, style: StrokeStyle(lineWidth: K.bordoArea, dash: K.trattini)))
    }

    /// L'area del tratto sul Mac: si disegna trascinando; nelle istantanee il tratto di prova.
    private var tela: some View {
        GeometryReader { geo in
            ZStack {
                if stato.trattoProvaIstantanea && tratti.isEmpty, let prova = TrattoProvaTavolo.immagine() {
                    Image(decorative: prova, scale: 1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                }
                Canvas { contesto, _ in
                    for t in tratti {
                        guard let primo = t.first else { continue }
                        var linea = Path()
                        linea.move(to: primo)
                        if t.count == 1 {
                            linea.addLine(to: CGPoint(x: primo.x + 0.5, y: primo.y))
                        } else {
                            for p in t.dropFirst() { linea.addLine(to: p) }
                        }
                        contesto.stroke(linea, with: .color(K.coloreTratto),
                                        style: StrokeStyle(lineWidth: K.tratto, lineCap: .round, lineJoin: .round))
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { v in
                        let p = CGPoint(x: min(max(v.location.x, 0), geo.size.width), y: min(max(v.location.y, 0), geo.size.height))
                        if v.translation == .zero || tratti.isEmpty {
                            tratti.append([p])
                        } else {
                            tratti[tratti.count - 1].append(p)
                        }
                    }
                    .onEnded { _ in tratti.append([]) }
            )
            .onAppear { misuraArea = geo.size }
            .onChange(of: geo.size) { _, nuova in misuraArea = nuova }
        }
    }

    private var conTratto: Bool {
        tratti.contains { !$0.isEmpty } || (stato.trattoProvaIstantanea && !sulTavolo)
    }

    // MARK: I pulsanti

    private func pulsanti(_ nome: String) -> some View {
        HStack(spacing: K.spazio) {
            Button(TestiPresaVisioneMac.registra) { registra() }
                .buttonStyle(.applePrimario)
                .controlSize(.large)
                .disabled(sulTavolo ? !arrivata : !conTratto)
            Button(TestiPresaVisioneMac.annulla) { stato.annullaPresaVisione() }
                .buttonStyle(.apple)
            if !sulTavolo && conTratto && !stato.trattoProvaIstantanea {
                Button(TestiPresaVisioneMac.cancella) { tratti = [] }
                    .buttonStyle(.apple)
                    .controlSize(.small)
            }
            Spacer(minLength: K.spazio)
            Text(TestiPresaVisioneMac.resta(nome))
                .carattereApple(K.piccolo)
                .foregroundColor(K.coloreSottoArea)
                .lineLimit(1)
        }
    }

    private func registra() {
        if sulTavolo {
            stato.chiudiPresaVisioneArrivata()
            return
        }
        let pieni = tratti.filter { !$0.isEmpty }
        let immagine = pieni.isEmpty ? TrattoProvaTavolo.immagine() : StatoShell.immagineTratto(pieni, misura: misuraArea)
        guard let immagine else { return }
        stato.registraPresaVisioneMac(tratto: immagine)
    }
}
#endif
