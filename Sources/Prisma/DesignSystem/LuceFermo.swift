import SwiftUI

// La scena del palco della Sala (Design/template-luce-specifica.md §2.2.5 punto 3, «Luce» giro 4) disegnata in SwiftUI,
// senza Metal e senza `Canvas`. Dal 25 novembre 2026 (decisione dell'utente) al posto del prisma di vetro c'è il sole del
// piano (`SoleDelPiano`): il disco d'oro di Lucy che si riempie di luce con gli obiettivi coperti, un raggio per
// obiettivo; dal suo bordo il ventaglio delle parti del patrimonio. Il nome del tipo resta per non cambiare le
// chiamate (palco, immagine del file dato al cliente). Gli aloni sono gradienti che sfumano a trasparente (nelle
// istantanee i filtri come `blur` possono non uscire). Sempre notte: nessun colore cambia con l'aspetto chiaro o scuro.

/// Una fascia del ventaglio come la disegna il fermo-immagine.
struct FasciaLuceFermo: Equatable {
    let colore: Color
    /// Evidenza: 1 a riposo, 1,75 la scelta, 0,22 le altre.
    let peso: Double
}

struct PrismaDiLuceFermo: View {
    let fasce: [FasciaLuceFermo]
    /// n + 1 bordi cumulati 0…1.
    let bordi: [Double]
    var rotazione: Double = 0
    /// 0…1 rispetto al patrimonio più alto del cursore.
    var frazione: Double = 1
    /// Spento: solo il disco, senza ventaglio (nessuna posizione in essere).
    var spento = false
    /// Il sole del piano: i raggi degli obiettivi e la luce del disco.
    var sole: SolePiano = .spento
    /// Sul palco il sole si accende con le animazioni di SwiftUI; nelle immagini ferme (file del cliente) no.
    var animato = false

    private typealias F = Tema.Apple.Luce.Fermo

    var body: some View {
        GeometryReader { g in
            let geo = GeometriaLuce(misura: g.size)
            let fy = geo.pavimento
            ZStack(alignment: .topLeading) {
                fondo(g.size)
                // Sotto il pavimento il fondo è più scuro e la scena si riflette capovolta, tenue
                Rectangle()
                    .fill(Color.black.opacity(0.18))
                    .frame(height: max(0, g.size.height - fy))
                    .offset(y: fy)
                scena(geo)
                    .scaleEffect(x: 1, y: -1, anchor: UnitPoint(x: 0, y: fy / max(1, g.size.height)))
                    .opacity(F.opacitaRiflesso)
                    .mask(riflessoMaschera(fy: fy, altezza: g.size.height))
                scena(geo)
                    .mask(Rectangle().frame(height: fy).frame(maxHeight: .infinity, alignment: .top))
                orizzonte(geo, fy: fy, larghezza: g.size.width)
            }
            .frame(width: g.size.width, height: g.size.height)
            .clipped()
        }
        .accessibilityHidden(true)
    }

    // MARK: Il fondo

    private func fondo(_ misura: CGSize) -> some View {
        ZStack {
            RadialGradient(colors: [F.fondoCentro, F.fondoBordo], center: F.centroFondo, startRadius: 0,
                           endRadius: misura.height * F.quotaRaggioFondo)
            RadialGradient(colors: [Color.clear, F.vignetta], center: .center, startRadius: misura.height * 0.5,
                           endRadius: misura.height * 1.3)
        }
    }

    private func riflessoMaschera(fy: CGFloat, altezza: CGFloat) -> some View {
        let alto = max(1, altezza - fy)
        return VStack(spacing: 0) {
            Color.clear.frame(height: fy)
            LinearGradient(colors: [.white, .white.opacity(0)], startPoint: .top,
                           endPoint: UnitPoint(x: 0.5, y: min(1, 120 / alto * 2)))
                .frame(height: alto)
        }
    }

    private func orizzonte(_ geo: GeometriaLuce, fy: CGFloat, larghezza: CGFloat) -> some View {
        LinearGradient(colors: [F.orizzonte.opacity(0), F.orizzonte.opacity(F.opacitaOrizzonte * 4), F.orizzonte.opacity(0)],
                       startPoint: .leading, endPoint: .trailing)
            .frame(width: larghezza, height: 1)
            .offset(y: fy)
    }

    // MARK: La scena (disegnata due volte: dritta e riflessa)

    private func scena(_ geo: GeometriaLuce) -> some View {
        let x = geo.uscita(rotazione)
        let lunghezza = geo.lunghezza(rot: rotazione, frazione: frazione)
        let disco = geo.raggio * Tema.Sole.quotaDiscoPalco
        let lato = disco / Tema.Sole.quotaDisco
        return ZStack(alignment: .topLeading) {
            if !spento {
                ventaglio(x, direzione: geo.direzione(rotazione), lunghezza: lunghezza, misura: geo.misura)
            }
            SoleDelPiano(sole: sole, accensione: frazione, animato: animato)
                .frame(width: lato, height: lato)
                .position(geo.centro)
                .opacity(spento ? F.opacitaVetroSpento : 1)
        }
    }

    /// Il ventaglio: uno spicchio per fascia, dal bianco caldo al colore entro 210 punti, che sfuma in fondo.
    private func ventaglio(_ x: CGPoint, direzione: Double, lunghezza: CGFloat, misura: CGSize) -> some View {
        let apertura = Double(Tema.Apple.Luce.Scena.apertura)
        let inizio = direzione - apertura / 2
        // I gradienti radiali si misurano sul riquadro della scena: il centro è X
        let centro = UnitPoint(x: x.x / max(1, misura.width), y: x.y / max(1, misura.height))
        return ZStack(alignment: .topLeading) {
            // L'alone intorno al ventaglio
            spicchio(x, da: inizio - 0.04, a: inizio + apertura + 0.04, raggio: lunghezza * 1.02)
                .fill(RadialGradient(colors: [Tema.Sole.oro.opacity(0.10), .clear],
                                     center: centro, startRadius: 0, endRadius: lunghezza))
            ForEach(Array(fasce.enumerated()), id: \.offset) { i, f in
                if i + 1 < bordi.count, bordi[i + 1] - bordi[i] > 0.0005 {
                    let a0 = inizio + bordi[i] * apertura
                    let a1 = inizio + bordi[i + 1] * apertura
                    let k = min(1, F.sfumaturaColore / max(1, lunghezza))
                    spicchio(x, da: a0, a: a1, raggio: lunghezza)
                        .fill(RadialGradient(stops: [
                            .init(color: Tema.Sole.oro, location: 0),
                            .init(color: f.colore, location: k),
                            .init(color: f.colore.opacity(0.75), location: 0.78),
                            .init(color: f.colore.opacity(0), location: 1),
                        ], center: centro, startRadius: 0, endRadius: lunghezza))
                        .opacity(min(1, F.opacitaVentaglio * f.peso))
                }
            }
            // I fili scuri fra le fasce, che crescono allontanandosi da X
            ForEach(1..<max(1, bordi.count - 1), id: \.self) { i in
                let a = inizio + bordi[i] * apertura
                Path { p in
                    p.move(to: CGPoint(x: x.x + CGFloat(cos(a)) * 40, y: x.y + CGFloat(sin(a)) * 40))
                    p.addLine(to: CGPoint(x: x.x + CGFloat(cos(a)) * lunghezza, y: x.y + CGFloat(sin(a)) * lunghezza))
                }
                .stroke(LinearGradient(colors: [F.filo.opacity(0), F.filo], startPoint: .leading, endPoint: .trailing),
                        lineWidth: F.spessoreFilo)
            }
        }
    }

    /// Uno spicchio di cerchio con il centro in `c`, in coordinate della scena.
    private func spicchio(_ c: CGPoint, da: Double, a: Double, raggio: CGFloat) -> Path {
        SpicchioLuce(da: da, a: a)
            .path(in: CGRect(x: c.x - raggio, y: c.y - raggio, width: raggio * 2, height: raggio * 2))
    }

    /// Il triangolo con gli angoli arrotondati come nello shader: vertici rientrati di 2·r verso il baricentro, poi il
    /// contorno a distanza r (segmenti spostati in fuori e archi intorno ai vertici rientrati).
    static func triangoloArrotondato(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, raggio r: CGFloat) -> Path {
        let c = CGPoint(x: (p0.x + p1.x + p2.x) / 3, y: (p0.y + p1.y + p2.y) / 3)
        func rientra(_ p: CGPoint) -> CGPoint {
            let dx = c.x - p.x, dy = c.y - p.y
            let l = max(0.001, hypot(dx, dy))
            return CGPoint(x: p.x + dx / l * r * 2, y: p.y + dy / l * r * 2)
        }
        let a = [rientra(p0), rientra(p1), rientra(p2)]
        // Il senso del giro: le normali verso l'esterno
        let area = (a[1].x - a[0].x) * (a[2].y - a[0].y) - (a[1].y - a[0].y) * (a[2].x - a[0].x)
        let verso: CGFloat = area > 0 ? 1 : -1
        func normale(_ i: Int) -> CGPoint {
            let p = a[i], q = a[(i + 1) % 3]
            let dx = q.x - p.x, dy = q.y - p.y
            let l = max(0.001, hypot(dx, dy))
            return CGPoint(x: dy / l * verso, y: -dx / l * verso)
        }
        var path = Path()
        for i in 0..<3 {
            let n = normale(i)
            let nPrima = normale((i + 2) % 3)
            let inizioArco = atan2(Double(nPrima.y), Double(nPrima.x))
            let fineArco = atan2(Double(n.y), Double(n.x))
            path.addArc(center: a[i], radius: r, startAngle: .radians(inizioArco), endAngle: .radians(fineArco),
                        clockwise: verso < 0)
            let q = a[(i + 1) % 3]
            path.addLine(to: CGPoint(x: q.x + n.x * r, y: q.y + n.y * r))
        }
        path.closeSubpath()
        return path
    }
}

/// Uno spicchio: centro nel mezzo del rettangolo, raggio metà del lato, fra due angoli (rad, y in giù).
private struct SpicchioLuce: Shape {
    let da: Double
    let a: Double

    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.move(to: c)
        p.addArc(center: c, radius: rect.width / 2, startAngle: .radians(da), endAngle: .radians(a), clockwise: false)
        p.closeSubpath()
        return p
    }
}
