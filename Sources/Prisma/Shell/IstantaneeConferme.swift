#if os(macOS)
import SwiftUI

/// Le istantanee di «Quello che Prisma prepara da solo si conferma allo stesso modo» (migliorie d'uso 68,
/// Design/uso/gruppo-11.md §68.5), nello stato finale (nessuna scossa):
/// - 1313: la scheda «Arriva sul Mac» con l'obiettivo «Aggiornato», l'attività annullata e «Va bene così» blu (chiara
///   e scura);
/// - 1314: Stanotte prima della prima decisione: «COSA HAI DECISO» con la sola frase del vuoto, le parole sotto ✕ e ✓;
/// - 1315: i componenti di ConfermeApple.swift in tutti gli stati, sopra la scrivania velata (chiara e scura).
///
/// DATI DI PROVA DICHIARATI: la nota del template (`NotaVocaleDiProva`) e le carte di `NotteDiProva`, solo dentro queste
/// scene.
extension Istantanee {
    nonisolated static var sceneConferme: [(nome: String, prepara: (StatoShell) -> Void)] {
        let decisa: (StatoShell) -> Void = { s in
            let id = notaDiProvaScena(s)
            guard let n = s.dati.noteInArrivo.first(where: { $0.id == id }) else { return }
            if let a = n.proposte.first(where: { $0.tipo == .attivita }) { s.notaVocale.alternaAnnullata(a.id, nota: id) }
            if let o = n.proposte.first(where: { $0.tipo == .obiettivo }) { s.notaVocale.rispondi(o.id, si: true, nota: id) }
        }
        return [
            (nome: "1313-uso-nota-decisa", prepara: decisa),
            (nome: "1313-uso-nota-decisa-scuro", prepara: decisa),
            (nome: "1314-uso-notte-vuota-registro", prepara: { s in notteScena(s) }),
            (nome: "1315-uso-conferme-vetrina", prepara: { _ in }),
            (nome: "1315-uso-conferme-vetrina-scuro", prepara: { _ in }),
        ]
    }

    /// La vetrina delle conferme (1315), sopra la shell velata.
    static func tavolaConferme(_ nome: String) -> AnyView? {
        guard nome.hasPrefix("1315-uso-conferme-vetrina") else { return nil }
        return AnyView(
            ZStack {
                ShellView()
                Tema.Apple.Colore.velo
                VetrinaConferme()
            }
        )
    }
}
#endif
