#if os(macOS)
import Foundation

/// Le istantanee del tavolo con l'iPad (Tavolo/TavoloMac.swift, viste in Shell/AlTavolo.swift), senza rete:
/// - 470: la sala della presentazione con «Al tavolo» (iPad collegato) e la striscia dei comandi aperta;
/// - 471: la pagina finale della presa visione nel PDF (con un tratto di prova), in sala, sulla carta bianca.
/// Migliorie d'uso 58 (chiare e scure), nella vista del cliente con Giulia:
/// - 680: «La Sala» sul gioco del rischio, l'etichetta «Su questo schermo» con il menu aperto;
/// - 681: «iPad sul tavolo» (iPad per istantanea), con i pulsanti del consulente visibili nel palco;
/// - 682: la scheda della presa visione sul Mac con il tratto di prova; 683: la scheda in attesa del segno dall'iPad.
extension Istantanee {
    nonisolated static var sceneTavolo: [(nome: String, prepara: (StatoShell) -> Void)] {
        [
            ("470-tavolo-sala", { s in
                preparaProspettiApple(s)
                if let d = s.documentoProspetto(sceltaProspettiApple) { s.presenta(d) }
                s.tavolo.mostraPerIstantanea(iPad: "iPad di Denis", mostrato: "Pagina 1 · Un anno insieme", pannello: true)
            }),
            ("471-tavolo-presa-visione", { s in
                preparaProspettiApple(s)
                guard let d = s.documentoProspetto(sceltaProspettiApple), let tratto = TrattoProvaTavolo.immagine() else { return }
                let completo = TavoloMac.documentoConPresaVisione(d, tratto: tratto, data: Date())
                s.presenta(completo, daPagina: completo.pagine.count - 1)
            }),
        ] + sceneLuogo
    }

    /// Migliorie d'uso 58: l'etichetta del luogo, il suo menu e la presa visione, chiare e scure.
    nonisolated private static var sceneLuogo: [(nome: String, prepara: (StatoShell) -> Void)] {
        func rischio(_ s: StatoShell) {
            s.avvisoVistaVisto = true
            s.avvisoRischioToccoVisto = true
            s.sala.rischioIstantanea = PuntoGiocoRischio(scenario: 0, risposte: [])
            s.apriEsperienza(.giocoRischio, cliente: "giulia")
            s.mostra(.sala)
        }
        let chiare: [(String, (StatoShell) -> Void)] = [
            ("680-mostra-luogo-schermo", { s in
                rischio(s)
                s.menuLuogo = true
            }),
            ("681-mostra-luogo-tavolo", { s in
                s.tavolo.mostraPerIstantanea(iPad: "iPad di prova", mostrato: EsperienzaSala.giocoRischio.titolo, pannello: false)
                rischio(s)
                s.luogoCliente = .tavolo
            }),
            ("682-presa-visione-mac", { s in
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.quadro)
                s.trattoProvaIstantanea = true
                s.presaVisioneAperta = true
            }),
            ("683-presa-visione-attesa-ipad", { s in
                s.tavolo.mostraPerIstantanea(iPad: "iPad di prova", mostrato: CapitoloCliente.quadro.titolo, pannello: false)
                s.scegliCliente("giulia")
                s.avvisoVistaVisto = true
                s.mostra(.quadro)
                s.luogoCliente = .tavolo
                s.presaVisioneAperta = true
            }),
        ]
        return chiare.flatMap { nome, prepara in
            [(nome: nome, prepara: prepara), (nome: nome + "-scuro", prepara: prepara)]
        }
    }
}
#endif
