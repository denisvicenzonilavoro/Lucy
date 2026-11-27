#if os(macOS)
import SwiftUI
import AppKit

// Il video di presentazione di Lucy (27 novembre 2026, richiesta dell'utente). Dalla riga di comando, senza aprire Lucy:
//   Prisma --video <file.mp4> [--riprese <cartella>]
//       scrive <file.mp4> (1920 × 1080, 60 fps, H.264, muto, circa 80 s, 20 Mbit/s) e accanto <file>-telefono.mp4
//       (stesso video, più leggero da mandare); le schermate sono istantanee vere con i clienti di prova
//       (`Istantanee.genera`), fatte nella cartella `--riprese` (rifatte solo se mancano) o in una cartella temporanea;
//   Prisma --video-fotogrammi <cartella> <t1,t2,…> [--riprese <cartella>]
//       salva i PNG di alcuni istanti (in secondi), per controllare senza fare tutto il video.
// Non tocca l'archivio vero: le istantanee lavorano sui dati di prova in memoria. Copione in CopioneVideo.swift, scene in
// ScenePresentazione.swift, valori in DesignSystem/Carta/TemaVideo.swift.

@MainActor
enum VideoPresentazione {
    /// Esegue `--video` o `--video-fotogrammi` se ci sono; nil se non sono stati chiesti, altrimenti il codice d'uscita.
    static func daRigaDiComando(_ argomenti: [String]) -> Int32? {
        func valore(_ opzione: String, _ passo: Int = 1) -> String? {
            argomenti.firstIndex(of: opzione).flatMap { $0 + passo < argomenti.count ? argomenti[$0 + passo] : nil }
        }
        let riprese = valore("--riprese").map { URL(fileURLWithPath: $0, isDirectory: true) }
        if let cartella = valore("--video-fotogrammi"), let istanti = valore("--video-fotogrammi", 2) {
            let tempi = istanti.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
            return fotogrammi(in: URL(fileURLWithPath: cartella, isDirectory: true), istanti: tempi, riprese: riprese) ? 0 : 1
        }
        if let file = valore("--video") {
            return scrivi(in: URL(fileURLWithPath: file), riprese: riprese) ? 0 : 1
        }
        return nil
    }

    // MARK: - Le schermate

    /// Le istantanee del video, fatte se mancano, caricate in memoria.
    private static func schermate(_ riprese: URL?) throws -> [String: NSImage] {
        let cartella = riprese ?? FileManager.default.temporaryDirectory
            .appendingPathComponent("lucy-video-riprese", isDirectory: true)
        let mancanti = ScenaVideo.istantanee.filter {
            !FileManager.default.fileExists(atPath: cartella.appendingPathComponent("\($0).png").path)
        }
        if !mancanti.isEmpty {
            print("▸ Faccio le schermate: \(mancanti.joined(separator: ", "))")
            guard Istantanee.genera(in: cartella, metodo: "finestra", solo: Set(mancanti)) == 0 else {
                throw ScrittoreVideo.Errore(description: "istantanee non riuscite")
            }
        }
        var esito: [String: NSImage] = [:]
        for nome in ScenaVideo.istantanee {
            let url = cartella.appendingPathComponent("\(nome).png")
            guard let immagine = NSImage(contentsOf: url) else {
                throw ScrittoreVideo.Errore(description: "schermata \(nome).png non letta")
            }
            esito[nome] = immagine
        }
        return esito
    }

    // MARK: - Il video

    /// Scrive il video pieno e quello leggero; false se qualcosa non riesce (messaggio su stderr).
    static func scrivi(in url: URL, riprese: URL?) -> Bool {
        let copione = CopioneVideo()
        guard copione.coerente else { return fallito("il copione non torna") }
        do {
            let immagini = try schermate(riprese)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let leggero = url.deletingPathExtension().appendingPathExtension("telefono").appendingPathExtension("mp4")
            let pieno = try ScrittoreVideo(url: url, bitrate: 20_000_000)
            let telefono = try ScrittoreVideo(url: leggero, bitrate: 6_000_000)
            let inizio = Date()
            let tutti = copione.numeroFotogrammi
            print("▸ Disegno \(tutti) fotogrammi…")
            for i in 0..<tutti {
                try autoreleasepool {
                    let fotogramma = try immagine(a: copione.istante(del: i), copione: copione, schermate: immagini)
                    try pieno.aggiungi(fotogramma)
                    try telefono.aggiungi(fotogramma)
                }
                if i % 600 == 599 {
                    let passati = Date().timeIntervalSince(inizio)
                    print("… \(i + 1)/\(tutti) fotogrammi, restano circa \(Int(passati / Double(i + 1) * Double(tutti - i - 1))) s")
                }
            }
            try aspetta { try await pieno.chiudi() }
            try aspetta { try await telefono.chiudi() }
            print("✓ \(url.path)")
            print("✓ \(leggero.path)")
            return true
        } catch {
            return fallito("\(error)")
        }
    }

    /// Salva un PNG per ogni istante: `video-<t>s.png`.
    static func fotogrammi(in cartella: URL, istanti: [Double], riprese: URL?) -> Bool {
        guard !istanti.isEmpty else { return fallito("nessun istante (per esempio 3,12.5,40)") }
        let copione = CopioneVideo()
        do {
            let immagini = try schermate(riprese)
            try FileManager.default.createDirectory(at: cartella, withIntermediateDirectories: true)
            for t in istanti {
                let cg = try immagine(a: t, copione: copione, schermate: immagini)
                guard let dati = NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:]) else {
                    return fallito("PNG non creato a \(t) s")
                }
                let url = cartella.appendingPathComponent("video-\(t.formatted(.number.grouping(.never)))s.png")
                try dati.write(to: url)
                print("✓ \(url.path)")
            }
            return true
        } catch {
            return fallito("\(error)")
        }
    }

    /// Aspetta una funzione asincrona senza bloccare il filo principale con un'attesa che gira a vuoto.
    private static func aspetta(_ lavoro: @escaping @Sendable () async throws -> Void) throws {
        var esito: Result<Void, Error>?
        Task.detached { esito = await Result { try await lavoro() } }
        while esito == nil { RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01)) }
        try esito?.get()
    }

    private static func fallito(_ messaggio: String) -> Bool {
        FileHandle.standardError.write(Data("Lucy: video non riuscito (\(messaggio))\n".utf8))
        return false
    }

    // MARK: - Il fotogramma

    /// Il fotogramma dell'istante `t`, disegnato a scala 2 (3840 × 2160): lo scrittore lo riduce a 1920 × 1080 con
    /// l'interpolazione alta, così i movimenti lenti avanzano di frazioni di pixel senza scatti.
    static func immagine(a t: Double, copione: CopioneVideo, schermate: [String: NSImage]) throws -> CGImage {
        let renderer = ImageRenderer(content: fotogramma(a: t, copione: copione, schermate: schermate))
        renderer.scale = 2
        var risultato: CGImage?
        // I colori dinamici si risolvono con l'aspetto chiaro: il video ha i suoi colori fissi
        NSAppearance(named: .aqua)?.performAsCurrentDrawingAppearance { risultato = renderer.cgImage }
        guard let risultato else { throw ScrittoreVideo.Errore(description: "fotogramma non disegnato a \(t) s") }
        return risultato
    }

    /// Le scene che il copione chiede a `t`, una sull'altra: quella che esce sotto, intera, quella che entra sopra con la
    /// sua opacità (due strati a metà lascerebbero passare il fondo).
    static func fotogramma(a t: Double, copione: CopioneVideo, schermate: [String: NSImage]) -> some View {
        let scene = copione.scena(a: t)
        return ZStack {
            Color.black
            ForEach(Array(scene.enumerated()), id: \.offset) { i, s in
                SceneVideo(scena: s.scena, locale: s.locale, durata: copione.durata(di: s.scena), schermate: schermate)
                    .opacity(i == 0 ? 1 : s.opacita)
            }
        }
        .frame(width: TemaVideo.larghezza, height: TemaVideo.altezza)
        .environment(\.colorScheme, .light)
        .environment(\.modoIstantanea, true)
    }
}
#endif
