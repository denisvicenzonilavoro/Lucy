import Foundation

// Migliorie d'uso 37 · la dimostrazione dentro `Prisma --prova-vera` (rifinitura 32-39, Design/uso/resta-da-fare.md).
// Con la dimostrazione accesa Vera vede solo i clienti di prova: la scheda di un cliente vero non si compone, né la sua
// scheda né quella del portafoglio portano il suo nome, la guida tace, le routine programmate non partono e la nota
// dettata sull'iPhone resta nella sua coda (il Mac la rifiuta con il motivo). Spenta, il cliente vero torna. Lo stato è
// non persistente, come in tutte le prove: le guardie di «Prisma ovunque» su disco (istantanea e giornali) stanno dietro
// `persistente` e qui non si raggiungono.

enum ProvaVeraDimostrazione {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        #if os(macOS)
        let stato = StatoShell(persistente: false)
        guard let i = stato.dati.clienti.indices.first else {
            controlla(false, "Dimostrazione e Vera: nessun cliente nei dati di prova")
            return
        }
        let nomeVero = "Ermenegilda Pastrocchi"
        stato.dati.clienti[i].nome = nomeVero
        let idVero = stato.dati.clienti[i].id
        controlla(stato.fonteVera(idVero).map { ContestoVera.scheda($0).contains(nomeVero) } == true,
                  "Dimostrazione e Vera: spenta, la scheda del cliente vero porta il suo nome")

        stato.accendiDimostrazione(.cinque, avviso: false)
        controlla(stato.inDimostrazione, "Dimostrazione e Vera: si accende")
        let schede = stato.dati.clienti.compactMap { stato.fonteVera($0.id) }.map(ContestoVera.scheda)
        let portafoglio = VeraPortafoglio.scheda(stato.dati.istantanea)
        controlla(!schede.isEmpty && !schede.contains { $0.contains(nomeVero) } && !portafoglio.contains(nomeVero),
                  "Dimostrazione e Vera: le schede dei clienti e del portafoglio non portano il cliente vero")
        controlla(stato.fonteVera(idVero).map { ContestoVera.scheda($0).contains(nomeVero) } != true,
                  "Dimostrazione e Vera: la scheda del cliente vero non si compone")
        controlla(!stato.guidaVisibile, "Dimostrazione e Vera: la guida non si mostra")
        controlla(stato.controllaRoutineDovute().isEmpty, "Dimostrazione e Vera: le routine programmate non partono")
        let nota = NotaVocalePonte(id: "nota-prova-dimostrazione", testo: NotaVocaleDiProva.testo, durata: 9, dispositivo: "iPhone di prova")
        let ricevuta = stato.riceviDalPonte(.notaVocale(nota))
        controlla(!ricevuta.accettato && ricevuta.motivo == TestiDimostrazione.notaRifiutata
                  && !stato.dati.noteInArrivo.contains { $0.id == nota.id },
                  "Dimostrazione e Vera: la nota dettata resta sull'iPhone (il Mac la rifiuta con il motivo)")

        stato.spegniDimostrazione(avviso: nil)
        controlla(!stato.inDimostrazione && stato.cliente(idVero)?.nome == nomeVero,
                  "Dimostrazione e Vera: spenta, il cliente vero torna")
        #endif
    }
}
