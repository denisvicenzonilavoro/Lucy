#if os(macOS)
import Foundation
import CoreGraphics

/// Le istantanee di Posizioni › Smontaggio (Design/template-luce-specifica.md §8.2.7, «Luce» giro 2), nello stato
/// finale (ellissi chiuse, note visibili, numeri completi, linee tracciate):
/// - 880: l'estratto fac-simile di Giulia con le ellissi e le note, card con la proposta, chiaro e scuro;
/// - 881: nessun documento (invito a inquadrare o trascinare), chiaro e scuro;
/// - 882: costi trovati, senza proposte del cliente (card 2 con «Scegli un prodotto da confrontare»);
/// - 883: performance senza importo (ellisse tratteggiata) e versato mancante;
/// - 884: il fumetto del conto su un'ellisse; 885: la testata con i quattro segmenti, chiara e scura;
/// - 886: la finestra stretta.
/// Migliorie d'uso 42 (sul Mac numeri accanto alle ellissi ed elenco delle voci al posto delle note): 887 una voce
/// accesa, chiara e scura; 888 il cliente scelto senza documenti smontati, chiaro e scuro; 889 l'indice delle
/// Posizioni di Giulia con «Smontaggio di un documento» e il documento conservato riaperto dalle voci.
/// DATI DI PROVA DICHIARATI: l'estratto è il fac-simile del template (`TestiSmontaggio.righeFacSimile`); la proposta di
/// confronto è una proposta di prova di Giulia, con costi di prova, che esiste solo dentro la scena.
extension Istantanee {
    nonisolated static var sceneSmontaggio: [(nome: String, prepara: (StatoShell) -> Void)] {
        var scene: [(nome: String, prepara: (StatoShell) -> Void)] = []
        func una(_ nome: String, _ prepara: @escaping (StatoShell) -> Void) {
            scene.append((nome: nome, prepara: prepara))
        }
        func coppia(_ nome: String, _ prepara: @escaping (StatoShell) -> Void) {
            una(nome, prepara)
            una(nome + "-scuro", prepara)
        }
        coppia("880-posizioni-smontaggio") { s in preparaSmontaggio(s) }
        coppia("881-posizioni-smontaggio-vuoto") { s in
            s.smontaggio.svuota()
            s.apriSmontaggio()
        }
        una("882-posizioni-smontaggio-senza-proposta") { s in
            s.dati.posizioni.removeAll { $0.clienteId == "giulia" && $0.stato == .proposta }
            preparaSmontaggio(s, proposta: false)
        }
        una("883-posizioni-smontaggio-mancanti") { s in
            preparaSmontaggio(s)
            let righe = TestiSmontaggio.righeFacSimile
                .filter { !$0.hasPrefix("Totale versato") }
                .map { $0.hasPrefix("Commissione di performance") ? "Commissione di performance 20% oltre l'indice" : $0 }
            s.smontaggio.carica(righe: righe.map { RigaLetta(testo: $0) }, titolo: "Fondo Esempio Globale",
                                origine: "Fac-simile di esempio · dati di prova", clienteId: "giulia")
        }
        una("884-posizioni-smontaggio-fumetto") { s in
            preparaSmontaggio(s)
            s.smontaggio.fumettoIstantanea = TestiSmontaggio.righeFacSimile.firstIndex { $0.hasPrefix("Commissione di gestione") }
        }
        coppia("885-posizioni-testata-quattro-viste") { s in preparaSmontaggio(s) }
        una("886-posizioni-smontaggio-stretta") { s in
            preparaSmontaggio(s)
            s.alternaIngrandimento(.posizioni)
            s.ridimensiona(.posizioni, dimensione: CGSize(width: 760, height: 640))
        }
        // Migliorie d'uso 42: una voce accesa (riga dell'elenco ed ellisse), il cliente scelto senza documenti smontati e
        // l'indice delle Posizioni del cliente con «Smontaggio di un documento» e il numero
        coppia("887-posizioni-smontaggio-voce-accesa") { s in
            preparaSmontaggio(s)
            s.smontaggio.sopra.riga = TestiSmontaggio.righeFacSimile.firstIndex { $0.hasPrefix("Commissione di gestione") }
        }
        coppia("888-posizioni-smontaggio-vuoto-cliente") { s in
            s.smontaggio.svuota()
            s.dati.documenti.removeAll { $0.clienteId == "marco" && !($0.costiTrovati ?? []).isEmpty }
            s.clienteAttivoId = "marco"
            s.posizioneInDettaglio = nil
            s.apri(.posizioni)
            s.ancoraPosizioni = "smontaggio"
        }
        una("889-posizioni-indice-smontaggio") { s in
            preparaSmontaggio(s)
            documentoSmontatoDiProva(s)
            s.smontaggio.svuota()
            s.clienteAttivoId = "giulia"
            s.posizioneInDettaglio = nil
            s.apri(.posizioni)
            s.ancoraPosizioni = "smontaggio"
        }
        return scene
    }

    /// Un documento smontato già nei Documenti di Giulia (il fac-simile, con le voci di Prisma), senza il testo in
    /// memoria: il foglio si ricostruisce dalle voci. DATI DI PROVA DICHIARATI.
    nonisolated static func documentoSmontatoDiProva(_ s: StatoShell) {
        let costi = MotoreSmontaggio.smonta(TestiSmontaggio.righeFacSimile.map { RigaLetta(testo: $0) })
        var doc = Documento(clienteId: "giulia", titolo: "Fondo Esempio Globale", tipo: .estrattoConto)
        doc.id = "doc-prova-smontaggio-istantanea"
        doc.lettura = .letto
        doc.pagine = 1
        doc.costiTrovati = costi.voci
        s.dati.documenti.removeAll { $0.id == doc.id }
        s.dati.documenti.append(doc)
    }

    /// L'esempio fac-simile per Giulia, con una proposta di prova da confrontare; poi Posizioni › Smontaggio.
    nonisolated static func preparaSmontaggio(_ s: StatoShell, proposta: Bool = true) {
        if proposta {
            var p = Posizione(clienteId: "giulia", canale: .indipendente, stato: .proposta, area: .investimento,
                              nome: "Fondo indicizzato di prova")
            p.id = "pos-prova-smontaggio"
            p.esito = .bozza
            p.versamentoIniziale = 90_000
            p.costoAnnuo = 760.0 / 90_000 * 100
            p.note = "Dati di prova"
            s.dati.posizioni.removeAll { $0.clienteId == "giulia" && $0.stato == .proposta }
            s.dati.posizioni.append(p)
        }
        s.clienteAttivoId = "giulia"
        s.smontaggio.caricaEsempio(clienteId: "giulia")
        s.apriSmontaggio()
    }
}
#endif
