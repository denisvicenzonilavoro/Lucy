import Foundation

#if os(macOS)
// Il copione del video di presentazione di Lucy (`Prisma --video`, richiesta dell'utente del 27 novembre 2026: «un video
// un po' figo di presentazione… premium… come un art director», sull'esempio di quello di Lucy Exchange): le scene, i
// loro tempi e i testi. Solo il conto, senza grafica: le scene le disegna ScenePresentazione.swift.
// Regole: niente musica, niente numeri inventati su utenti o risultati (le cifre sono quelle dei clienti di prova nelle
// schermate), mai consigli: i testi dicono che Lucy calcola, prepara e spiega, e che decide il consulente.

/// Le scene del video, nell'ordine.
enum ScenaVideo: String, CaseIterable, Sendable {
    case apertura, manifesto, scrivania, sera, clienti, posizioni, simulatore, prospetti, lucy, agenda, chiusura

    /// La schermata (un'istantanea di `--istantanee`) delle scene che ne mostrano una.
    var istantanea: String? {
        switch self {
        case .scrivania: return "1-scrivania"
        case .sera: return "1-scrivania-scuro"
        case .clienti: return "5-clienti-panoramica"
        case .posizioni: return "2-posizioni"
        case .simulatore: return "14-analisi360-simulatore"
        case .prospetti: return "460-prospetti-apple"
        case .lucy: return "1045-uso-vera-tutti-i-clienti"
        case .agenda: return "11-agenda"
        case .apertura, .manifesto, .chiusura: return nil
        }
    }

    /// Le istantanee che servono al video.
    static var istantanee: [String] { allCases.compactMap(\.istantanea) }

    /// Il movimento di camera sulla schermata: il punto da avvicinare (0…1 nella schermata) e di quanto.
    var camera: (x: Double, y: Double, zoom: Double) {
        switch self {
        case .scrivania: return (0.34, 0.47, 1.30)
        case .clienti: return (0.58, 0.40, 1.42)
        case .posizioni: return (0.42, 0.52, 1.28)
        case .simulatore: return (0.71, 0.52, 1.38)
        case .prospetti: return (0.60, 0.50, 1.30)
        case .lucy: return (0.48, 0.40, 1.34)
        case .agenda: return (0.70, 0.40, 1.28)
        case .sera, .apertura, .manifesto, .chiusura: return (0.5, 0.5, 1)
        }
    }
}

/// I tempi del video: scene che si toccano, dissolvenza incrociata centrata sul confine tra due scene.
struct CopioneVideo: Sendable {
    typealias Voce = (scena: ScenaVideo, inizio: Double, fine: Double)

    /// Fotogrammi al secondo.
    let fps = 60
    /// La durata della dissolvenza incrociata tra due scene.
    let dissolvenza = 0.7

    /// Le scene con inizio e fine in secondi (si toccano senza buchi). Circa 80 secondi.
    let scene: [Voce] = [
        (.apertura, 0, 6.5), (.manifesto, 6.5, 15), (.scrivania, 15, 23), (.sera, 23, 28),
        (.clienti, 28, 36), (.posizioni, 36, 44), (.simulatore, 44, 52), (.prospetti, 52, 59),
        (.lucy, 59, 66.5), (.agenda, 66.5, 72.5), (.chiusura, 72.5, 81),
    ]

    var durata: Double { scene.last?.fine ?? 0 }
    var numeroFotogrammi: Int { Int((durata * Double(fps)).rounded()) }
    func istante(del fotogramma: Int) -> Double { Double(fotogramma) / Double(fps) }

    /// Quanto dura una scena (dall'entrata alla fine della sua dissolvenza d'uscita).
    func durata(di scena: ScenaVideo) -> Double {
        guard let v = scene.first(where: { $0.scena == scena }) else { return 0 }
        return v.fine - entrata(scena) + dissolvenza / 2
    }

    /// Quando parte l'orologio di una scena: all'inizio della sua dissolvenza d'entrata (l'apertura a zero).
    func entrata(_ scena: ScenaVideo) -> Double {
        guard let i = scene.firstIndex(where: { $0.scena == scena }) else { return 0 }
        return i == 0 ? 0 : scene[i].inizio - dissolvenza / 2
    }

    /// Le scene da disegnare all'istante `t`: una sola, o due durante la dissolvenza (quella che esce sotto, intera, e
    /// quella che entra sopra con la sua opacità). `locale` è il tempo dell'orologio della scena.
    func scena(a t: Double) -> [(scena: ScenaVideo, locale: Double, opacita: Double)] {
        let t = min(max(t, 0), durata)
        let mezza = dissolvenza / 2
        for (i, s) in scene.enumerated() where i + 1 < scene.count {
            if t >= s.fine - mezza, t < s.fine + mezza {
                let prossima = scene[i + 1]
                let p = TemaVideo.Curva.morbida(TemaVideo.Curva.tratto(t, s.fine - mezza, s.fine + mezza))
                return [(s.scena, t - entrata(s.scena), 1), (prossima.scena, t - entrata(prossima.scena), p)]
            }
        }
        let i = scene.lastIndex { t >= $0.inizio } ?? 0
        return [(scene[i].scena, t - entrata(scene[i].scena), 1)]
    }

    /// I conti del copione tornano: scene in ordine, senza buchi, ognuna più lunga di due dissolvenze.
    var coerente: Bool {
        guard let prima = scene.first, prima.inizio == 0 else { return false }
        return zip(scene, scene.dropFirst()).allSatisfy { $0.fine == $1.inizio }
            && scene.allSatisfy { $0.fine - $0.inizio > 2 * dissolvenza }
            && Set(scene.map(\.scena)).count == ScenaVideo.allCases.count
    }
}

/// I testi del video.
enum TestiVideo {
    /// Sotto il marchio, nell'apertura.
    static let apertura = "LO STUDIO DEL CONSULENTE FINANZIARIO"
    /// Le tre righe del manifesto, una dopo l'altra (l'ultima in oro).
    static let manifesto = ["Ogni cliente, tutto il patrimonio.", "Ogni cifra, calcolata da Lucy.", "Ogni scelta, tua."]
    /// La frase della chiusura e la riga sotto il marchio.
    static let chiusura = "Consulenza finanziaria, con tutto sotto gli occhi."
    static let firmaChiusura = "MAC · IPAD · IPHONE — L'ARCHIVIO RESTA SUL TUO MAC"

    /// Occhiello e titolo delle scene con la schermata.
    static func titolo(_ scena: ScenaVideo) -> (occhiello: String, titolo: String)? {
        switch scena {
        case .scrivania: return ("LA SCRIVANIA", "La giornata, in una pagina.")
        case .sera: return ("DI GIORNO E DI SERA", "Carta di giorno, inchiostro di sera.")
        case .clienti: return ("CLIENTI", "Ogni cliente, in un colpo d'occhio.")
        case .posizioni: return ("POSIZIONI", "Le posizioni, il cuore dell'analisi.")
        case .simulatore: return ("ANALISI 360", "Simula, confronta, spiega.")
        case .prospetti: return ("PROSPETTI", "Prospetti chiari, pronti da consegnare.")
        case .lucy: return ("LUCY", "Lucy prepara. Tu decidi.")
        case .agenda: return ("AGENDA", "Ogni incontro, già preparato.")
        case .apertura, .manifesto, .chiusura: return nil
        }
    }

    /// Tutte le frasi, per il controllo.
    static var tutte: [String] {
        [apertura, chiusura, firmaChiusura] + manifesto
            + ScenaVideo.allCases.compactMap(titolo).flatMap { [$0.occhiello, $0.titolo] }
    }
}
#endif
