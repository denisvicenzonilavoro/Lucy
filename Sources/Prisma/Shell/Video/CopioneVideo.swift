import Foundation

#if os(macOS)
// Il copione del video di presentazione di Lucy (`Prisma --video`). Prima versione del 27 novembre 2026; rifatto lo
// stesso giorno sullo stile del video di Lucy Exchange (richiesta dell'utente: «tienilo come base… più dinamico»):
// titoli grandi su una o due righe con l'oro, la finestra dell'app che entra e non sta mai ferma, cambi dentro la scena
// (una pagina che diventa un'altra, la domanda che si scrive e la risposta che arriva), scene chiare e scure alternate,
// una finestra che esce di lato mentre l'altra entra. Solo il conto e i testi: le scene le disegna ScenePresentazione.
// Regole: niente musica, niente numeri inventati (le cifre sono quelle dei clienti di prova nelle schermate), mai
// consigli: Lucy calcola, prepara e spiega; decide il consulente.

/// Le scene del video, nell'ordine.
enum ScenaVideo: String, CaseIterable, Sendable {
    case apertura, perche, scrivania, clienti, posizioni, portafoglio, simulatore, agenda, lucy, prospetti, chiusura

    /// Le scene con il fondo scuro.
    var scura: Bool {
        switch self {
        case .perche, .clienti, .portafoglio, .agenda: return true
        default: return false
        }
    }

    /// Le pagine della scena (istantanee di `--istantanee`), con l'istante da cui valgono. Con `tendina` la pagina
    /// nuova scende dall'alto invece di comparire in dissolvenza (la risposta di Lucy che arriva).
    var passi: [(inizio: Double, istantanea: String, tendina: Bool)] {
        switch self {
        case .scrivania: return [(0, "1-scrivania", false)]
        case .clienti: return [(0, "5-clienti-panoramica-scuro", false)]
        case .posizioni: return [(0, "2-posizioni", false), (CopioneVideo.cambioPosizioni, "8-posizioni-dettaglio", false)]
        case .portafoglio: return [(0, "420-posizioni-portafoglio-scuro", false)]
        case .simulatore:
            return [(0, "14-analisi360-simulatore", false), (CopioneVideo.cambioSimulatore, "16-analisi360-confronto", false)]
        case .agenda: return [(0, "11a-agenda-mese-scuro", false)]
        case .lucy:
            return [(0, "480-vera-apple", false), (CopioneVideo.rispostaLucy, "481-vera-risposta-calcoli", true)]
        case .prospetti: return [(0, "460-prospetti-apple", false)]
        case .apertura, .perche, .chiusura: return []
        }
    }

    /// Le istantanee intere (la scrivania e la sala sono tutto lo schermo); le altre si ritagliano alla finestra.
    static let intere: Set<String> = ["1-scrivania", "461-prospetti-sala"]

    /// Tutte le istantanee che servono al video.
    static var istantanee: [String] {
        allCases.flatMap { $0.passi.map(\.istantanea) } + ["461-prospetti-sala"]
    }
}

/// I tempi del video: scene che si toccano, dissolvenza incrociata centrata sul confine tra due scene.
struct CopioneVideo: Sendable {
    typealias Voce = (scena: ScenaVideo, inizio: Double, fine: Double)

    /// Fotogrammi al secondo.
    let fps = 60
    /// La durata della dissolvenza incrociata tra due scene.
    let dissolvenza = 0.6

    /// Le scene con inizio e fine in secondi (si toccano senza buchi). Circa 79 secondi.
    let scene: [Voce] = [
        (.apertura, 0, 6), (.perche, 6, 13), (.scrivania, 13, 19.5), (.clienti, 19.5, 26), (.posizioni, 26, 33.5),
        (.portafoglio, 33.5, 39.5), (.simulatore, 39.5, 47), (.agenda, 47, 53), (.lucy, 53, 61.5),
        (.prospetti, 61.5, 70), (.chiusura, 70, 79),
    ]

    /// I cambi dentro le scene (secondi dall'entrata della scena).
    static let cambioPosizioni = 3.7
    static let cambioSimulatore = 3.9
    /// «Chiedi a Lucy»: il campo compare, la domanda si scrive lettera per lettera, parte; poi arriva la risposta.
    static let domandaLucy = (compare: 0.9, scrive: 1.25, lettera: 0.055, invio: 3.6)
    static let rispostaLucy = 4.3
    /// Prospetti: la finestra del prospetto esce a sinistra mentre la sala entra da destra.
    static let passaggioSala = (inizio: 4.0, fine: 5.1)

    var durata: Double { scene.last?.fine ?? 0 }
    var numeroFotogrammi: Int { Int((durata * Double(fps)).rounded()) }
    func istante(del fotogramma: Int) -> Double { Double(fotogramma) / Double(fps) }

    /// Quanto dura una scena (dall'entrata alla fine della sua dissolvenza d'uscita).
    func durata(di scena: ScenaVideo) -> Double {
        guard let v = scene.first(where: { $0.scena == scena }) else { return 0 }
        return v.fine - entrata(scena) + dissolvenza / 2
    }

    /// Quando parte l'orologio di una scena: all'inizio della sua dissolvenza d'entrata (l'apertura a zero), così
    /// entra già in moto.
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

    /// I conti del copione tornano: scene in ordine, senza buchi, ognuna più lunga di due dissolvenze, i cambi dentro
    /// la durata della loro scena.
    var coerente: Bool {
        guard let prima = scene.first, prima.inizio == 0 else { return false }
        return zip(scene, scene.dropFirst()).allSatisfy { $0.fine == $1.inizio }
            && scene.allSatisfy { $0.fine - $0.inizio > 2 * dissolvenza }
            && Set(scene.map(\.scena)).count == ScenaVideo.allCases.count
            && ScenaVideo.allCases.allSatisfy { s in s.passi.allSatisfy { $0.inizio < durata(di: s) } }
            && Self.passaggioSala.fine < durata(di: .prospetti)
    }
}

/// I testi del video. Ogni titolo è una o due righe: la seconda è in oro; una riga sola ha in oro la parte dopo
/// l'ultima virgola.
enum TestiVideo {
    /// Le tre righe del perché, una dopo l'altra (l'ultima in oro).
    static let perche = ["Decine di clienti.", "Ognuno con la sua vita.", "Tutti, in un'app sola."]
    /// Le due righe della chiusura, prima del marchio.
    static let chiusura = ["Prima l'analisi.", "Poi la consulenza."]
    /// La domanda che si scrive in «Chiedi a Lucy» (la stessa della risposta nell'istantanea 481).
    static let domandaLucy = "Come è diviso il patrimonio di Giulia?"
    /// Il testo d'invito del campo, come nell'app.
    static let invitoLucy = "Chiedi una sintesi, un incontro, uno scenario…"

    /// Il titolo di una scena.
    static func titolo(_ scena: ScenaVideo) -> [String]? {
        switch scena {
        case .scrivania: return ["La tua giornata, in una pagina."]
        case .clienti: return ["Ogni cliente ha una storia.", "Lucy la tiene a mente."]
        case .posizioni: return ["Ogni posizione, spiegata."]
        case .portafoglio: return ["Tutto il portafoglio, a colpo d'occhio."]
        case .simulatore: return ["Il futuro non si indovina.", "Si simula."]
        case .agenda: return ["Ogni incontro, già preparato."]
        case .lucy: return ["Chiedi quello che ti serve."]
        case .prospetti: return ["Prospetti chiari, pronti da consegnare."]
        case .apertura, .perche, .chiusura: return nil
        }
    }

    /// Il titolo che prende il posto del primo a metà scena (al cambio della pagina), se c'è.
    static func secondoTitolo(_ scena: ScenaVideo) -> [String]? {
        switch scena {
        case .posizioni: return ["Quanto vale, come sta andando."]
        case .simulatore: return ["Due strade a confronto.", "Costi e tasse compresi."]
        case .lucy: return ["Le cifre sono di Lucy.", "La scelta è tua."]
        case .prospetti: return ["E davanti al cliente,", "a tutto schermo."]
        default: return nil
        }
    }

    /// Tutte le frasi, per il controllo.
    static var tutte: [String] {
        perche + chiusura + [domandaLucy, invitoLucy]
            + ScenaVideo.allCases.flatMap { (titolo($0) ?? []) + (secondoTitolo($0) ?? []) }
    }
}
#endif
