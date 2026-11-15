import Foundation
import PDFKit

/// Prova delle due versioni dei documenti (migliorie d'uso 22), dentro `Prisma --prova-prospetti`: `conVersione` torna
/// uguale con la stessa versione, `versione` e `soloPer` si escludono, e sul Mac il timbro «SOLO PER TE» non sposta
/// l'impaginazione, compare nel PDF per te e non in quello per il cliente, e la seconda lettura non lo segnala.
/// La chiama `ProvaProspetti.esegui` prima del riepilogo, con la sua funzione di verifica.
@MainActor
enum ProvaVersioniProspetto {
    static func esegui(_ verifica: (String, Bool, String) -> Void) {
        let tutte: [SceltaProspetto] = [
            .resoconto(report: true), .resoconto(report: false), .sostituzione("a", "b", report: true),
            .sostituzione("a", "b", report: false), .previdenza(report: true), .protezione(report: false),
            .obiettivo("o", report: true), .obiettivo("o", report: false), .liquidita(report: true), .checkUp(report: false),
            .resistenza(report: true), .costi(report: false), .successione(report: true), .patrimonio(report: false),
            .valutazione("v", report: true), .valutazione("v", report: false), .fascicolo, .posizione("p"),
            .portafoglio, .riesame, .annoInsieme,
        ]
        // Con la stessa versione ogni scelta torna uguale; senza versione non cambia mai
        let uguali = tutte.allSatisfy { s in s.versione.map { s.conVersione($0) == s } ?? (s.conVersione(.perTe) == s && s.conVersione(.perIlCliente) == s) }
        verifica("Versioni: conVersione con la stessa versione lascia la scelta com'è", uguali, "")
        let andataRitorno = tutte.allSatisfy { s in
            guard let v = s.versione else { return true }
            let altra: VersioneProspetto = v == .perTe ? .perIlCliente : .perTe
            return s.conVersione(altra).versione == altra && s.conVersione(altra).conVersione(v) == s
        }
        verifica("Versioni: il cambio di versione va e torna", andataRitorno, "")
        verifica("Versioni: ogni documento ha la scelta o una versione sola",
                 tutte.allSatisfy { ($0.versione == nil) != ($0.soloPer == nil) }, "")
        verifica("Versioni: «Per il cliente» è il report", SceltaProspetto.checkUp(report: true).versione == .perIlCliente
                 && SceltaProspetto.checkUp(report: false).versione == .perTe, "")
        verifica("Versioni: il portafoglio non ha il timbro (decisione 22-c), il riesame sì",
                 !SceltaProspetto.portafoglio.conTimbroPerTe && SceltaProspetto.riesame.conTimbroPerTe
                 && !SceltaProspetto.annoInsieme.conTimbroPerTe && !SceltaProspetto.checkUp(report: true).conTimbroPerTe, "")
        verifica("Versioni: l'avviso del PDF salvato dice la versione",
                 TestiVersioneProspetto.pdfSalvato("Check-up primo incontro", versione: .perTe) == "PDF salvato: «Check-up primo incontro» · versione per te"
                 && TestiVersioneProspetto.pdfSalvato("X", versione: nil) == "PDF salvato: «X»", "")

        #if os(macOS)
        let stato = StatoShell(persistente: false)
        stato.clienteAttivoId = "giulia"
        func testo(_ d: DocumentoStampabile?) -> String? {
            guard let d, let pdf = StampaCarta.pdf(d) else { return nil }
            return StampaCarta.testo(pdf).joined(separator: "\n")
        }
        // Il timbro senza spazi: la spaziatura delle lettere può separarle nel testo estratto
        func timbrato(_ t: String) -> Bool {
            t.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").contains("SOLOPERTE")
        }
        for scelta in [SceltaProspetto.checkUp(report: false), .resoconto(report: false), .riesame] {
            guard let d = stato.documentoProspetto(scelta), let t = testo(d) else {
                verifica("Timbro in «\(scelta.tipo.nome)»: PDF per te creato", false, "")
                continue
            }
            let pagine = PDFDocument(data: StampaCarta.pdf(d) ?? Data())?.pageCount ?? 0
            verifica("Timbro in «\(scelta.tipo.nome)»: «SOLO PER TE» e la frase dell'ultima pagina nel PDF per te",
                     timbrato(t) && ProvaProspetti.spazi(t).contains(TestiVersioneProspetto.notaUltimaPagina), "")
            verifica("Timbro in «\(scelta.tipo.nome)»: stesso numero di pagine", pagine == d.pagine.count, "\(pagine) di \(d.pagine.count)")
            let lettura = stato.secondaLetturaProspetto(t, titolo: "Prova", cliente: "giulia")
            verifica("Timbro in «\(scelta.tipo.nome)»: la seconda lettura non segnala «SOLO PER TE»",
                     !lettura.daGuardare.contains { a in timbrato("\(a.trovato ?? "") \(a.titolo)") }, "")
        }
        for scelta in [SceltaProspetto.checkUp(report: true), .resoconto(report: true), .annoInsieme] {
            guard let t = testo(stato.documentoProspetto(scelta)) else { continue }
            verifica("Nessun timbro in «\(scelta.tipo.nome)» per il cliente", !timbrato(t), "")
        }
        #endif
    }
}
