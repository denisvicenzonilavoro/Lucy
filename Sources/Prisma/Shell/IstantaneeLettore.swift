#if os(macOS)
import Foundation

/// Le istantanee di «Il documento si apre in grande» (migliorie d'uso 62, Design/uso/gruppo-11.md §62.5), tutte sulla
/// polizza di Marco aperta nel lettore dalla scheda Documenti del dossier:
/// - 1304: un dato da controllare (senza la riga d'origine), i certi in una riga, le differenze da decidere (chiara e scura);
/// - 1305: tutto deciso, il pulsante blu «Fatto: salva nel dossier»;
/// - 1306: i dati certi aperti con «Mostra»;
/// - 1307: il puntatore su un dato della prima pagina, la sua riga accesa in giallo sul foglio.
/// Le scene della scheda Documenti di prima (161-166, 190-194…) si aprono da sole nel lettore.
extension Istantanee {
    nonisolated static var sceneLettore: [(nome: String, prepara: (StatoShell) -> Void)] {
        let polizza = "doc-marco-polizza"
        /// La polizza con i dati da confermare: il primo senza la riga d'origine (incerto per le regole).
        let daControllare: (StatoShell) -> Void = { s in
            s.clienteAttivoId = "marco"
            s.aggiornaDocumento(polizza) { d in
                for i in d.campi.indices { d.campi[i].confermato = false }
                if let i = d.campi.firstIndex(where: { $0.chiave == .beneficiari }) ?? d.campi.indices.first {
                    d.campi[i].estratto = ""
                }
            }
            s.documentoSelezionato = polizza
            s.apri(.documenti)
        }
        return [
            (nome: "1304-uso-lettore-da-controllare", prepara: daControllare),
            (nome: "1304-uso-lettore-da-controllare-scuro", prepara: daControllare),
            (nome: "1305-uso-lettore-deciso", prepara: { s in
                daControllare(s)
                if let d = s.documento(polizza) {
                    for k in MotoreDocumenti.incerti(d).keys { s.confermaCampo(polizza, k, true) }
                }
                RichiestaIstantaneaLettore.chiedi(s, tuttoDeciso: true)
            }),
            (nome: "1306-uso-lettore-certi-aperti", prepara: { s in
                daControllare(s)
                RichiestaIstantaneaLettore.chiedi(s, certiAperti: true)
            }),
            (nome: "1307-uso-lettore-riga-accesa", prepara: { s in
                daControllare(s)
                let sopra = s.documento(polizza)?.campi.first { $0.pagina == 1 && !$0.estratto.isEmpty }?.chiave
                RichiestaIstantaneaLettore.chiedi(s, certiAperti: true, sopra: sopra)
            }),
        ]
    }
}
#endif
