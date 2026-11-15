#if os(macOS)
import Foundation

/// Le istantanee del portafoglio di Posizioni nel tema Apple (§4.1): la card con il totale, i tre anelli e il nastro
/// «Da fare», in chiaro e in scuro; «Con le proposte» con la stima tratteggiata e la fascia; il dettaglio della prima
/// scheda del nastro aperto. Le cifre vengono dai motori di Prisma sui dati di prova; il piano previdenziale di
/// Giulia è presentato da 50 giorni e ancora senza risposta, così sul nastro c'è una proposta ferma (date relative).
extension Istantanee {
    nonisolated static var scenePosizioniApple: [(nome: String, prepara: (StatoShell) -> Void)] {
        var tutte: [(nome: String, prepara: (StatoShell) -> Void)] = [
            ("420-posizioni-portafoglio", { s in preparaPortafoglioApple(s) }),
            ("420-posizioni-portafoglio-scuro", { s in preparaPortafoglioApple(s) }),
            ("421-posizioni-con-proposte", { s in
                preparaPortafoglioApple(s)
                RichiestaIstantaneaPortafoglio.chiedi(s, conProposte: true)
            }),
            ("422-posizioni-dettaglio-da-fare", { s in
                preparaPortafoglioApple(s)
                RichiestaIstantaneaPortafoglio.chiedi(s, dettaglio: true)
            }),
        ]
        tutte += sceneQuadroPosizioni
        tutte += sceneSchedaPosizione
        return tutte
    }

    /// Migliorie d'uso 15 «La scheda di una posizione si legge dall'alto»: l'ETF di Giulia su «In breve» (frase, cifre,
    /// grafico, «Se si chiudesse oggi», chiara e scura); il piano rivalutabile di Giulia con cinque dati tolti, sulla
    /// scheda «Contratto» (righe piene e «Da completare · 5»); il piano previdenziale di Giulia in proposta, presentato da
    /// 50 giorni: tre pulsanti e la scheda «Adeguatezza». (1050-1052: 1027-1029 della specifica erano già presi)
    nonisolated private static var sceneSchedaPosizione: [(nome: String, prepara: (StatoShell) -> Void)] {
        let etf: (StatoShell) -> Void = { s in
            s.clienteAttivoId = "giulia"
            s.portafoglio = false
            s.posizioneInDettaglio = "pos-giulia-etf-azionario-globale"
            s.apri(.posizioni)
        }
        return [
            ("1050-uso-posizione-in-breve", etf),
            ("1050-uso-posizione-in-breve-scuro", etf),
            ("1051-uso-posizione-contratto", { s in
                let id = "pos-giulia-piano-di-risparmio-rivalutabile"
                if let i = s.dati.posizioni.firstIndex(where: { $0.id == id }) {
                    s.dati.posizioni[i].numeroContratto = ""
                    s.dati.posizioni[i].contraente = ""
                    s.dati.posizioni[i].assicurato = ""
                    s.dati.posizioni[i].beneficiari = ""
                    s.dati.posizioni[i].scadenza = nil
                }
                s.clienteAttivoId = "giulia"
                s.portafoglio = false
                s.posizioneInDettaglio = id
                s.apri(.posizioni)
                s.ancoraPosizioni = "dettaglio-contratto"
            }),
            ("1052-uso-proposta", { s in
                preparaPortafoglioApple(s)
                s.clienteAttivoId = "giulia"
                s.portafoglio = false
                s.posizioneInDettaglio = "pos-giulia-piano-previdenziale-integrativo"
                s.apri(.posizioni)
                s.ancoraPosizioni = "dettaglio-adeguatezza"
            }),
        ]
    }

    /// Migliorie d'uso 14 «Le posizioni prima di tutto»: l'indice delle posizioni di Marco e «Quadro e posizioni» con i
    /// filtri a zero (chiara e scura); la Protezione scelta dalla legenda, con la capsula «✕»; il filtro di canale
    /// acceso (le tessere restano quelle di tutto il cliente); la schermata della coerenza, il pannello di oggi da solo.
    /// (1040-1043: 1024-1027 sono già della scelta del cliente, migliorie d'uso 2)
    nonisolated private static var sceneQuadroPosizioni: [(nome: String, prepara: (StatoShell) -> Void)] {
        let quadro: (StatoShell) -> Void = { s in
            s.clienteAttivoId = "marco"
            s.portafoglio = false
            s.posizioneInDettaglio = nil
            s.apri(.posizioni)
        }
        return [
            ("1040-uso-posizioni-quadro", quadro),
            ("1040-uso-posizioni-quadro-scuro", quadro),
            ("1041-uso-posizioni-filtro-area", { s in
                quadro(s)
                s.areaPosizioniDaAprire = .protezione
            }),
            ("1042-uso-posizioni-coerenza", { s in
                quadro(s)
                s.ancoraPosizioni = "coerenza"
            }),
            ("1043-uso-posizioni-filtro-canale", { s in
                quadro(s)
                RichiestaIstantaneaPosizioni.chiedi(s, canale: .indipendente)
            }),
        ]
    }

    /// Posizioni › Portafoglio aperto, con la proposta di Giulia ferma da 50 giorni.
    nonisolated static func preparaPortafoglioApple(_ s: StatoShell) {
        let cal = Calendar.current
        let oggi = cal.startOfDay(for: Date())
        if let i = s.dati.posizioni.firstIndex(where: { $0.id == "pos-giulia-piano-previdenziale-integrativo" }) {
            var seguito = s.dati.posizioni[i].seguito ?? SeguitoProposta()
            seguito.presentataIl = ValoriDaDocumento.mezzogiorno(cal.date(byAdding: .day, value: -50, to: oggi) ?? oggi)
            s.dati.posizioni[i].esito = .presentata
            s.dati.posizioni[i].seguito = seguito
        }
        s.posizioneInDettaglio = nil
        s.portafoglio = true
        s.apri(.posizioni)
    }
}
#endif
