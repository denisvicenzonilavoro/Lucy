import SwiftUI

// MARK: - Il marchio Lucy by Logic (24 novembre 2026, scelta dell'utente)
//
// Prisma diventa Lucy (app per i consulenti), Prisma AI diventa Lucy AI, la società è Logic. Fonte: Design/Logo/LucyByLogic
// (LEGGIMI.md con colori, misure, regole d'uso e animazione d'avvio). Il simbolo è la «L di luce»: una L squadrata e un
// disco d'oro. Tutto vettoriale: va bene a ogni misura e nei PDF. Colori pieni, niente sfumature, ombre o riflessi.

extension Tema {
    /// I colori del marchio (LEGGIMI.md › Colori). Solo per il logo, le icone e l'avvio: il resto dell'app segue il suo tema.
    enum Marca {
        /// Fondo scuro del marchio.
        static let fondoScuro = Color(hex: "#100E0B")
        /// Fondo chiaro del marchio (carta).
        static let fondoChiaro = Color(hex: "#F4EEE2")
        /// La L e il testo su fondo chiaro (inchiostro).
        static let inchiostro = Color(hex: "#16130F")
        /// La L e il testo su fondo scuro (avorio).
        static let avorio = Color(hex: "#F0E7D4")
        /// Oro su fondo chiaro (disco, cursore, «AI»).
        static let oroChiaro = Color(hex: "#BF923D")
        /// Oro su fondo scuro.
        static let oroScuro = Color(hex: "#CDA04A")
        /// «by» su fondo chiaro.
        static let byChiaro = Color(hex: "#6B6152")
        /// «by» su fondo scuro.
        static let byScuro = Color(hex: "#A69B86")

        /// Le versioni che seguono l'aspetto chiaro o scuro.
        static let tratto = Color.dinamico(chiaro: inchiostro, scuro: avorio)
        static let oro = Color.dinamico(chiaro: oroChiaro, scuro: oroScuro)
        static let by = Color.dinamico(chiaro: byChiaro, scuro: byScuro)
    }
}

/// Geometria del simbolo (LEGGIMI.md › Il simbolo): in un quadrato di lato S, asta e base spesse 0,255 S, disco di raggio
/// 0,305 S con il centro in (0,612 S, 0,388 S), a 0,052 S dalla L su entrambi i lati.
enum GeometriaLucy {
    static let spessore: CGFloat = 0.255
    static let raggio: CGFloat = 0.305
    static let centro = CGPoint(x: 0.612, y: 0.388)

    /// La L in un quadrato (centrato nel riquadro dato).
    static func elle(in r: CGRect) -> Path {
        let s = min(r.width, r.height)
        let o = CGPoint(x: r.midX - s / 2, y: r.midY - s / 2)
        var p = Path()
        p.move(to: o)
        p.addLine(to: CGPoint(x: o.x + spessore * s, y: o.y))
        p.addLine(to: CGPoint(x: o.x + spessore * s, y: o.y + (1 - spessore) * s))
        p.addLine(to: CGPoint(x: o.x + s, y: o.y + (1 - spessore) * s))
        p.addLine(to: CGPoint(x: o.x + s, y: o.y + s))
        p.addLine(to: CGPoint(x: o.x, y: o.y + s))
        p.closeSubpath()
        return p
    }

    /// Il disco in un quadrato (centrato nel riquadro dato).
    static func disco(in r: CGRect) -> Path {
        let s = min(r.width, r.height)
        let o = CGPoint(x: r.midX - s / 2, y: r.midY - s / 2)
        let c = CGPoint(x: o.x + centro.x * s, y: o.y + centro.y * s)
        return Path(ellipseIn: CGRect(x: c.x - raggio * s, y: c.y - raggio * s, width: 2 * raggio * s, height: 2 * raggio * s))
    }

    /// Il simbolo come SVG da mettere dentro una pagina HTML (per i file dati al cliente), in un quadrato di lato `lato`.
    /// Senza `xmlns`: nei file dati al cliente non ci sono indirizzi web (controllo statico nel workflow).
    static func svg(lato: Double, tratto: String = "#16130F", oro: String = "#BF923D") -> String {
        func n(_ v: Double) -> String { String(format: "%.2f", v) }
        let s = lato, k = Double(spessore)
        let cx = Double(centro.x) * s, cy = Double(centro.y) * s, r = Double(raggio) * s
        return "<svg viewBox=\"0 0 \(n(s)) \(n(s))\" width=\"\(n(s))\" height=\"\(n(s))\">"
            + "<path d=\"M0 0H\(n(k * s))V\(n((1 - k) * s))H\(n(s))V\(n(s))H0Z\" fill=\"\(tratto)\"/>"
            + "<circle cx=\"\(n(cx))\" cy=\"\(n(cy))\" r=\"\(n(r))\" fill=\"\(oro)\"/></svg>"
    }
}

/// La L del simbolo.
struct ElleLucy: Shape {
    func path(in rect: CGRect) -> Path { GeometriaLucy.elle(in: rect) }
}

/// Il disco del simbolo.
struct DiscoLucy: Shape {
    func path(in rect: CGRect) -> Path { GeometriaLucy.disco(in: rect) }
}

/// Il simbolo intero in un solo tracciato (filigrane, maschere, versioni a tinta unica).
struct SimboloLucy: Shape {
    func path(in rect: CGRect) -> Path {
        var p = GeometriaLucy.elle(in: rect)
        p.addPath(GeometriaLucy.disco(in: rect))
        return p
    }
}

/// Il simbolo di Lucy: la L nel colore dato (inchiostro su chiaro, avorio su scuro) e il disco d'oro. Quadrato; si adatta
/// allo spazio. Nei PDF si passa un colore fisso (i documenti restano su carta chiara).
struct LogoLucy: View {
    var colore: Color = Tema.Marca.tratto
    var oro: Color = Tema.Marca.oro

    var body: some View {
        ZStack {
            ElleLucy().fill(colore)
            DiscoLucy().fill(oro)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Lucy")
    }
}

// MARK: - Tracciati SVG

/// Un tracciato SVG del marchio (solo comandi assoluti M, L, H, V, Q, Z, come negli SVG del pacchetto), adattato al
/// riquadro come `viewBox` con `preserveAspectRatio` di base (centrato, proporzioni mantenute).
struct TracciatoMarchio: Shape {
    let dati: String
    let viewBox: CGRect

    func path(in rect: CGRect) -> Path {
        TracciatoMarchio.leggi(dati).applying(TracciatoMarchio.trasformazione(viewBox, in: rect))
    }

    static func trasformazione(_ viewBox: CGRect, in rect: CGRect) -> CGAffineTransform {
        guard viewBox.width > 0, viewBox.height > 0 else { return .identity }
        let scala = min(rect.width / viewBox.width, rect.height / viewBox.height)
        let ox = rect.minX + (rect.width - viewBox.width * scala) / 2 - viewBox.minX * scala
        let oy = rect.minY + (rect.height - viewBox.height * scala) / 2 - viewBox.minY * scala
        return CGAffineTransform(a: scala, b: 0, c: 0, d: scala, tx: ox, ty: oy)
    }

    private static let serratura = NSLock()
    nonisolated(unsafe) private static var lette: [String: Path] = [:]

    /// Il tracciato letto una volta sola.
    static func leggi(_ dati: String) -> Path {
        serratura.lock()
        defer { serratura.unlock() }
        if let p = lette[dati] { return p }
        let p = interpreta(dati)
        lette[dati] = p
        return p
    }

    /// Lettura dei comandi SVG assoluti M, L, H, V, Q, Z (con i parametri ripetuti: dopo M valgono come L).
    static func interpreta(_ dati: String) -> Path {
        var simboli: [String] = []
        var numero = ""
        func chiudiNumero() { if !numero.isEmpty { simboli.append(numero); numero = "" } }
        for c in dati {
            if "MLHVQZ".contains(c) {
                chiudiNumero()
                simboli.append(String(c))
            } else if c == " " || c == "," {
                chiudiNumero()
            } else if c == "-" {
                chiudiNumero()
                numero = "-"
            } else if c == "." && numero.contains(".") {
                chiudiNumero()
                numero = "."
            } else {
                numero.append(c)
            }
        }
        chiudiNumero()

        var p = Path()
        var i = 0
        var comando = "M"
        var attuale = CGPoint.zero
        func valore() -> CGFloat? {
            guard i < simboli.count, let v = Double(simboli[i]) else { return nil }
            i += 1
            return CGFloat(v)
        }
        while i < simboli.count {
            if let c = simboli[i].first, "MLHVQZ".contains(c) {
                comando = String(c)
                i += 1
                if comando == "Z" {
                    p.closeSubpath()
                    continue
                }
            }
            switch comando {
            case "M":
                guard let x = valore(), let y = valore() else { return p }
                attuale = CGPoint(x: x, y: y)
                p.move(to: attuale)
                comando = "L"
            case "L":
                guard let x = valore(), let y = valore() else { return p }
                attuale = CGPoint(x: x, y: y)
                p.addLine(to: attuale)
            case "H":
                guard let x = valore() else { return p }
                attuale = CGPoint(x: x, y: attuale.y)
                p.addLine(to: attuale)
            case "V":
                guard let y = valore() else { return p }
                attuale = CGPoint(x: attuale.x, y: y)
                p.addLine(to: attuale)
            case "Q":
                guard let cx = valore(), let cy = valore(), let x = valore(), let y = valore() else { return p }
                attuale = CGPoint(x: x, y: y)
                p.addQuadCurve(to: attuale, control: CGPoint(x: cx, y: cy))
            default:
                i += 1
            }
        }
        return p
    }
}

/// Un rettangolo del marchio (il cursore di Logic) nello stesso viewBox dei tracciati, con il raggio al 20% della larghezza.
struct RettangoloMarchio: Shape {
    let riquadro: CGRect
    let viewBox: CGRect

    func path(in rect: CGRect) -> Path {
        let r = riquadro.applying(TracciatoMarchio.trasformazione(viewBox, in: rect))
        return Path(roundedRect: r, cornerRadius: r.width * 0.2)
    }
}

// MARK: - Il cursore di Logic

/// Il cursore di Logic lampeggia: ciclo di 1,1 s, metà acceso e metà spento, senza dissolvenza. Con «Riduci movimento» e
/// nelle istantanee resta fisso. Niente Timer: `TimelineView`.
struct CursoreLogic: View {
    let riquadro: CGRect
    let viewBox: CGRect
    var colore: Color = Tema.Marca.oro
    var lampeggia = true
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    var body: some View {
        if lampeggia && !calmo && !istantanea {
            TimelineView(.periodic(from: .now, by: 0.55)) { contesto in
                let acceso = Int(contesto.date.timeIntervalSinceReferenceDate / 0.55) % 2 == 0
                RettangoloMarchio(riquadro: riquadro, viewBox: viewBox).fill(colore).opacity(acceso ? 1 : 0)
            }
        } else {
            RettangoloMarchio(riquadro: riquadro, viewBox: viewBox).fill(colore)
        }
    }
}

// MARK: - Il logo con il nome

/// Il logo di Lucy: simbolo e «Lucy» (con «AI» per Lucy AI), e nel logo completo «by LOGIC» sotto. `colore` per la L e il
/// nome (inchiostro su chiaro, avorio su scuro), l'oro per disco, «AI» e cursore.
struct LogoLucyConNome: View {
    var colore: Color = Tema.Marca.tratto
    /// Altezza del simbolo: il resto si proporziona da sé.
    var altezza: CGFloat = 22
    var ai = false
    var completo = false
    var oro: Color = Tema.Marca.oro
    var coloreBy: Color = Tema.Marca.by
    var lampeggia = false

    /// Il viewBox dei file (il simbolo è un quadrato di 160 unità con l'angolo in 40, 92).
    private var viewBox: CGRect {
        CGRect(x: 30, y: 82, width: ai ? 889.96 : 717, height: completo ? 302.72 : 228)
    }

    var body: some View {
        let vb = viewBox
        let scala = altezza / 160
        ZStack {
            LogoLucy(colore: colore, oro: oro)
                .frame(width: 160 * scala, height: 160 * scala)
                .position(x: (120 - vb.minX) * scala, y: (172 - vb.minY) * scala)
            TracciatoMarchio(dati: TracciatiMarchio.nome, viewBox: vb).fill(colore)
            if ai {
                TracciatoMarchio(dati: TracciatiMarchio.ai, viewBox: vb).fill(oro)
            }
            if completo {
                TracciatoMarchio(dati: TracciatiMarchio.by, viewBox: vb).fill(coloreBy)
                TracciatoMarchio(dati: TracciatiMarchio.logicPiccolo, viewBox: vb).fill(colore)
                CursoreLogic(riquadro: TracciatiMarchio.cursorePiccolo, viewBox: vb, colore: oro, lampeggia: lampeggia)
            }
        }
        .frame(width: vb.width * scala, height: vb.height * scala)
        .accessibilityElement()
        .accessibilityLabel(ai ? "Lucy AI" : (completo ? "Lucy by Logic" : "Lucy"))
    }
}

/// Il logo di Logic: «LOG C» con il cursore d'oro al posto della I, che lampeggia.
struct LogoLogic: View {
    var colore: Color = Tema.Marca.tratto
    var oro: Color = Tema.Marca.oro
    var altezza: CGFloat = 24
    var lampeggia = true

    private let viewBox = CGRect(x: -8, y: -8, width: 396.98, height: 144)

    var body: some View {
        let scala = altezza / viewBox.height
        ZStack {
            TracciatoMarchio(dati: TracciatiMarchio.logic, viewBox: viewBox).fill(colore)
            CursoreLogic(riquadro: TracciatiMarchio.cursore, viewBox: viewBox, colore: oro, lampeggia: lampeggia)
        }
        .frame(width: viewBox.width * scala, height: altezza)
        .accessibilityElement()
        .accessibilityLabel("Logic")
    }
}

// MARK: - L'animazione d'avvio

/// L'avvio di Lucy (LEGGIMI.md › Animazione di avvio), come in Lucy AI, ogni volta che compare la schermata di benvenuto
/// (all'apertura e a ogni blocco; 25 novembre 2026, richiesta dell'utente: prima una volta sola per avvio, e spesso
/// finiva mentre l'app si apriva ancora):
/// 0,25–0,9 s la L sale di 8 punti; 0,8–1,6 s il disco cresce da zero con un piccolo rimbalzo (curva 0.3, 1.45, 0.5, 1);
/// 1,5–2,1 s «Lucy» entra scorrendo di 10 punti da sinistra; 2,1–2,6 s compare «by LOGIC», con il cursore che lampeggia.
/// Con «Riduci movimento» e nelle istantanee il logo completo compare subito. I tempi sono quelli del marchio (non il ritmo
/// del tema).
struct AvvioLucy: View {
    var colore: Color = Tema.Marca.tratto
    /// Altezza del simbolo.
    var altezza: CGFloat = 56
    var ai = false

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var elle = false
    @State private var disco = false
    @State private var nome = false
    @State private var firma = false

    var body: some View {
        let vb = CGRect(x: 30, y: 82, width: ai ? 889.96 : 717, height: 302.72)
        let scala = altezza / 160
        let simbolo = CGPoint(x: (120 - vb.minX) * scala, y: (172 - vb.minY) * scala)
        ZStack {
            // La L si disegna: un tratto largo che corre lungo il contorno la scopre (come in Lucy AI)
            ElleLucy().fill(colore)
                .frame(width: 160 * scala, height: 160 * scala)
                .mask {
                    ElleLucy()
                        .trim(from: 0, to: elle ? 1 : 0)
                        .stroke(style: StrokeStyle(lineWidth: 160 * scala * GeometriaLucy.spessore * 2.2, lineCap: .round, lineJoin: .round))
                        .frame(width: 160 * scala, height: 160 * scala)
                }
                .position(simbolo)
            DiscoLucy().fill(Tema.Marca.oro)
                .frame(width: 160 * scala, height: 160 * scala)
                .scaleEffect(disco ? 1 : 0.001, anchor: UnitPoint(x: GeometriaLucy.centro.x, y: GeometriaLucy.centro.y))
                .position(simbolo)
            ZStack {
                TracciatoMarchio(dati: TracciatiMarchio.nome, viewBox: vb).fill(colore)
                if ai { TracciatoMarchio(dati: TracciatiMarchio.ai, viewBox: vb).fill(Tema.Marca.oro) }
            }
            .opacity(nome ? 1 : 0)
            .offset(x: nome ? 0 : -10)
            ZStack {
                TracciatoMarchio(dati: TracciatiMarchio.by, viewBox: vb).fill(Tema.Marca.by)
                TracciatoMarchio(dati: TracciatiMarchio.logicPiccolo, viewBox: vb).fill(colore)
                CursoreLogic(riquadro: TracciatiMarchio.cursorePiccolo, viewBox: vb, lampeggia: true)
            }
            .opacity(firma ? 1 : 0)
        }
        .frame(width: vb.width * scala, height: vb.height * scala)
        .accessibilityElement()
        .accessibilityLabel(ai ? "Lucy AI by Logic" : "Lucy by Logic")
        .onAppear(perform: avvia)
    }

    private func avvia() {
        guard !(calmo || statoFinale) else {
            elle = true
            disco = true
            nome = true
            firma = true
            return
        }
        // Si riparte da capo (la vista può tornare dopo un blocco) e si aspetta un attimo che la finestra si veda
        elle = false
        disco = false
        nome = false
        firma = false
        let attesa = 0.35
        withAnimation(.easeInOut(duration: 0.65).delay(attesa + 0.25)) { elle = true }
        withAnimation(.timingCurve(0.3, 1.45, 0.5, 1, duration: 0.8).delay(attesa + 0.8)) { disco = true }
        withAnimation(.easeOut(duration: 0.6).delay(attesa + 1.5)) { nome = true }
        withAnimation(.easeOut(duration: 0.5).delay(attesa + 2.1)) { firma = true }
    }
}

/// Lo splash all'apertura dell'app (richiesta dell'utente del 25 novembre 2026: «si deve sempre vedere a inizio
/// applicazione», come in Lucy AI): fondo del marchio a tutto schermo, il simbolo e il nome che si disegnano, poi l'app
/// dopo circa 3 s. Con «Riduci movimento» il marchio compare fermo per 0,8 s. Un clic lo salta.
struct SplashLucy: View {
    let finito: () -> Void
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.colorScheme) private var schema
    @State private var chiuso = false

    var body: some View {
        ZStack {
            (schema == .dark ? Tema.Marca.fondoScuro : Tema.Marca.fondoChiaro)
                .ignoresSafeArea()
            AvvioLucy(altezza: 96)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: chiudi)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Lucy by Logic")
        .task {
            let durata: Double = calmo ? 0.8 : 3.0
            try? await Task.sleep(nanoseconds: UInt64(durata * 1_000_000_000))
            chiudi()
        }
    }

    private func chiudi() {
        guard !chiuso else { return }
        chiuso = true
        finito()
    }
}
