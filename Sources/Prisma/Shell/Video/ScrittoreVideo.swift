#if os(macOS)
import AVFoundation
import CoreGraphics
import CoreVideo

/// Scrive un MP4 H.264 (profilo alto, 60 fps, 1920 × 1080, colori BT.709) fotogramma per fotogramma, da immagini già
/// pronte (come quello di Lucy Exchange). `aggiungi` per ogni fotogramma, in ordine, poi `chiudi()`. Il file esistente si
/// sovrascrive. `bitrate`: 40 Mbit/s per il file pieno, meno per quello da mandare col telefono.
final class ScrittoreVideo: @unchecked Sendable {
    static let larghezza = 1920
    static let altezza = 1080
    static let fps = 60

    struct Errore: Error, CustomStringConvertible {
        let description: String
    }

    private let scrittore: AVAssetWriter
    private let ingresso: AVAssetWriterInput
    private let adattatore: AVAssetWriterInputPixelBufferAdaptor
    private var numero = 0

    init(url: URL, bitrate: Int) throws {
        try? FileManager.default.removeItem(at: url)
        scrittore = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let impostazioni: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Self.larghezza,
            AVVideoHeightKey: Self.altezza,
            AVVideoColorPropertiesKey: [
                AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2,
            ],
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: bitrate,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                AVVideoExpectedSourceFrameRateKey: Self.fps,
                // Un fotogramma chiave ogni 2 s (come Lucy Exchange): niente salto di qualità a ogni secondo
                AVVideoMaxKeyFrameIntervalKey: Self.fps * 2,
                AVVideoAllowFrameReorderingKey: false,
            ] as [String: Any],
        ]
        ingresso = AVAssetWriterInput(mediaType: .video, outputSettings: impostazioni)
        ingresso.expectsMediaDataInRealTime = false
        adattatore = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: ingresso,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: Self.larghezza,
                kCVPixelBufferHeightKey as String: Self.altezza,
            ])
        guard scrittore.canAdd(ingresso) else { throw Errore(description: "il file video non accetta la traccia") }
        scrittore.add(ingresso)
        guard scrittore.startWriting() else {
            throw Errore(description: "scrittura non avviata: \(scrittore.error?.localizedDescription ?? "?")")
        }
        scrittore.startSession(atSourceTime: .zero)
    }

    /// Aggiunge il fotogramma successivo (l'immagine si porta a 1920 × 1080 con l'interpolazione alta).
    func aggiungi(_ immagine: CGImage) throws {
        while !ingresso.isReadyForMoreMediaData {
            if scrittore.status == .failed { throw Errore(description: scrittore.error?.localizedDescription ?? "scrittura fallita") }
            usleep(2_000)
        }
        guard let pool = adattatore.pixelBufferPool else { throw Errore(description: "nessun pool di pixel") }
        var buffer: CVPixelBuffer?
        guard CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer) == kCVReturnSuccess, let buffer else {
            throw Errore(description: "pixel buffer non creato")
        }
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        guard let contesto = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer), width: Self.larghezza, height: Self.altezza,
            bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        else { throw Errore(description: "contesto di disegno non creato") }
        contesto.interpolationQuality = .high
        contesto.draw(immagine, in: CGRect(x: 0, y: 0, width: Self.larghezza, height: Self.altezza))
        let tempo = CMTime(value: CMTimeValue(numero), timescale: CMTimeScale(Self.fps))
        guard adattatore.append(buffer, withPresentationTime: tempo) else {
            throw Errore(description: scrittore.error?.localizedDescription ?? "fotogramma \(numero) non scritto")
        }
        numero += 1
    }

    /// Finisce il file.
    func chiudi() async throws {
        ingresso.markAsFinished()
        // La fine della traccia cade dopo l'ultimo fotogramma, così la durata è esatta
        scrittore.endSession(atSourceTime: CMTime(value: CMTimeValue(numero), timescale: CMTimeScale(Self.fps)))
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            scrittore.finishWriting { c.resume() }
        }
        if scrittore.status != .completed {
            throw Errore(description: scrittore.error?.localizedDescription ?? "file non finito")
        }
    }
}
#endif
