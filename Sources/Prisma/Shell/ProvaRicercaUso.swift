#if os(macOS)
import Foundation

/// La prova di «Cerca ovunque, e fa» (migliorie d'uso 61, Design/uso/gruppo-11.md §61.5), in `--prova-vera`: i filtri da
/// toccare (tipo e canale), il gruppo Parole, il codice «tipo:», le azioni nuove, la ricerca salvata che riaccende le
/// etichette, l'apertura pulita e la notifica di conformità che apre la ricerca con il suo filtro scritto.
enum ProvaRicercaUso {
    static func esegui(_ controlla: (Bool, String) -> Void) {
        let s = StatoShell(persistente: false)
        func gruppi(_ e: EsitoRicerca) -> [GruppoRicerca] { e.sezioni.map(\.gruppo) }

        // Tipo: con «Clienti» solo clienti, niente posizioni
        let soloClienti = MotoreRicerca.cercaCompleta("marco", in: s, limiti: LimitiRicerca(tipo: .clienti))
        controlla(!soloClienti.sezioni.isEmpty && gruppi(soloClienti).allSatisfy { $0 == .clienti },
                  "Cerca: con «Clienti» acceso solo clienti (niente posizioni)")
        let documenti = MotoreRicerca.cercaCompleta("marco", in: s, limiti: LimitiRicerca(tipo: .documenti))
        controlla(gruppi(documenti).allSatisfy { $0 == .documenti || $0 == .biblioteca },
                  "Cerca: con «Documenti» acceso solo documenti (anche della Biblioteca)")

        // Canale: con «Indipendente» nessuna posizione Alleanza, e solo i gruppi che hanno un canale
        let indipendente = MotoreRicerca.cercaCompleta("marco", in: s, limiti: LimitiRicerca(canale: .indipendente))
        let posizioni = indipendente.sezioni.filter { $0.gruppo == .posizioni }.flatMap(\.risultati)
        controlla(posizioni.allSatisfy { $0.canale == .indipendente },
                  "Cerca: con «Indipendente» acceso nessuna posizione Alleanza")
        controlla(gruppi(indipendente).allSatisfy { ([.clienti, .posizioni, .documenti, .biblioteca] as [GruppoRicerca]).contains($0) },
                  "Cerca: con un canale acceso niente note, appuntamenti, azioni, app o parole")

        // Le parole: «sri» trova la voce SRI, non con un filtro acceso
        let sri = MotoreRicerca.cercaCompleta("sri", in: s)
        controlla(sri.sezioni.first { $0.gruppo == .parole }?.risultati.first?.destinazione == .parola(.sri),
                  "Cerca: «sri» trova la parola SRI nel gruppo Parole")
        controlla(!gruppi(MotoreRicerca.cercaCompleta("sri", in: s, limiti: LimitiRicerca(tipo: .posizioni))).contains(.parole),
                  "Cerca: con un filtro acceso le parole non compaiono")
        controlla(gruppi(sri) == GruppoRicerca.ordineMac.filter { gruppi(sri).contains($0) },
                  "Cerca: sul Mac i gruppi nell'ordine del template (Clienti, Posizioni, Documenti… Azioni, App, Parole)")
        controlla(DestinazioneRicerca(testo: DestinazioneRicerca.parola(.sri).testo) == .parola(.sri),
                  "Cerca: la parola va e torna dal testo dei promemoria")

        // Il codice «tipo:»
        let e = FiltriRicerca.etichette("sri>3 tipo:posizioni canale:alleanza", canali: true)
        controlla(e.tipo == .posizioni && e.canale == .alleanza && e.resto == "sri>3",
                  "Cerca: «tipo:posizioni canale:alleanza» diventano etichette accese, nel campo resta «sri>3»")
        let soloTipo = FiltriRicerca.etichette("marco tipo:cli canale:alleanza", canali: false)
        controlla(soloTipo.tipo == .clienti && soloTipo.canale == nil && soloTipo.resto == "marco canale:alleanza",
                  "Cerca: «tipo:» si toglie sempre, «canale:» scritto resta un filtro scritto")
        let scritto = MotoreRicerca.cercaCompleta("tipo:clienti marco", in: s)
        controlla(!scritto.sezioni.isEmpty && gruppi(scritto).allSatisfy { $0 == .clienti },
                  "Cerca: il codice «tipo:clienti» di una ricerca salvata limita ai clienti")
        controlla(FiltriRicerca.conCodici("marco", tipo: .clienti, canale: .indipendente) == "marco tipo:clienti canale:indipendente",
                  "Cerca: le etichette accese si salvano come codici nel testo della ricerca")

        // Le azioni nuove si trovano scrivendo
        func azioni(_ testo: String) -> [AzioneRicerca] {
            MotoreRicerca.cercaCompleta(testo, in: s).sezioni.first { $0.gruppo == .azioni }?.risultati.compactMap(\.azione) ?? []
        }
        controlla(azioni("aggiorna").contains(.aggiornaValori), "Cerca: «aggiorna» trova «Aggiorna i valori»")
        controlla(azioni("nuovo cliente").contains(.nuovoCliente), "Cerca: «nuovo cliente» trova «Nuovo cliente»")
        controlla(!AzioneRicerca.disponibili.contains(.modoCliente) && !AzioneRicerca.disponibili.contains(.spaziLavoro)
                  && !AzioneRicerca.disponibili.contains(.appAperte) && AzioneRicerca.disponibili.contains(.mostraAlCliente),
                  "Cerca: sul Mac «Mostra al cliente» al posto di «Modalità cliente», spazi e app aperte nel menu della barra")
        controlla(AzioneRicerca.delPannelloVuoto.map(\.titolo) == ["Nuovo cliente", "Nuovo impegno", "Aggiorna i valori",
                                                                   "Mostra al cliente", "Inquadra un documento"],
                  "Cerca: le cinque azioni del pannello vuoto, come nel template")

        // La ricerca salvata riaperta riaccende le etichette
        let motore = StatoSpotlight()
        motore.applica("marco tipo:clienti canale:indipendente")
        controlla(motore.tipo == .clienti && motore.canale == .indipendente && motore.testo == "marco"
                  && motore.testoConCodici == "marco tipo:clienti canale:indipendente",
                  "Cerca: la ricerca salvata riaperta riaccende «Clienti» e «Indipendente», nel campo «marco»")
        let prima = s.ricercheSalvate.count
        s.salvaRicercaSubito("marco tipo:clienti", nome: "marco")
        s.salvaRicercaSubito("marco tipo:clienti", nome: "marco")
        controlla(s.ricercheSalvate.count == prima + 1 && s.ricercheSalvate.first?.testo == "marco tipo:clienti",
                  "Cerca: «Salva questa ricerca» salva subito, una volta sola con lo stesso nome")

        // Il pannello vuoto: recenti e azioni lette, non calcolate
        s.scegliCliente("giulia")
        s.scegliCliente("marco")
        let righe = StatoSpotlight.righeVuoto(s)
        controlla(righe.recenti.first?.destinazione == .cliente("marco") && righe.recenti.count <= 3 && righe.azioni.count == 5,
                  "Cerca: a campo vuoto i clienti recenti (al più tre, l'ultimo scelto prima) e le cinque azioni")

        // Apertura pulita dalla lente e da ⌘K; la notifica di conformità tiene il suo filtro scritto
        s.testoRicerca = "vecchia ricerca"
        s.alternaRicerca()
        controlla(s.pannelloRicerca && s.testoRicerca.isEmpty, "Cerca: dalla lente e da ⌘K la ricerca parte pulita")
        s.chiudiRicerca()
        s.testoRicerca = "conformita:scaduta"
        s.cercaOvunque()
        controlla(s.pannelloRicerca && s.testoRicerca == "conformita:scaduta",
                  "Cerca: la notifica di conformità apre la ricerca con «conformita:scaduta» (l'apertura pulita non lo cancella)")
        s.chiudiRicerca()
    }
}
#endif
