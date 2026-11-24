import Foundation

/// Migliorie d'uso 38 «I canali hanno il nome che scegli»: la pulizia del nome (18 caratteri, caratteri tolti, vuoto =
/// quello di base), `Canale.nomeBreve`, `Canale.nome` e il logo con i nomi di base e con quelli scelti, il campo letto
/// con tolleranza dall'archivio e le tre domande del primo avvio. Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaNomiCanali {
    static func esegui(_ verifica: VerificaCalcoli) {
        verifica.vero("Canali: il nome tiene al più 18 caratteri",
                      NomiCanali.pulisci(String(repeating: "a", count: 30)).count == NomiCanali.lunghezzaMassima
                      && NomiCanali.lunghezzaMassima == 18)
        verifica.vero("Canali: il nome perde < > & \" e gli spazi ai lati", NomiCanali.pulisci("  <Agen&zia\"> ") == "Agenzia")
        verifica.vero("Canali: mentre si scrive restano gli spazi", NomiCanali.ripulisciScrittura("Studio ") == "Studio ")
        verifica.vero("Canali: un nome vuoto torna a quello di base",
                      NomiCanali.scelti(primo: "   ", secondo: "") == .base && !NomiCanali.base.personalizzati)

        let prima = NomiCanaliCorrenti.valore
        NomiCanaliCorrenti.imposta(.base)
        verifica.vero("Canali: con i nomi di base «Alleanza» e «Indipendente»",
                      Canale.alleanza.nomeBreve == "Alleanza" && Canale.indipendente.nomeBreve == "Indipendente")
        verifica.vero("Canali: con i nomi di base le scritte lunghe dei PDF",
                      Canale.alleanza.nome == "Alleanza Assicurazioni"
                      && Canale.indipendente.nome == "Denis Vicenzoni · Consulenza finanziaria")
        verifica.vero("Canali: con i nomi di base il logo Alleanza e «indipendente» nelle frasi",
                      Canale.alleanza.conLogo && !Canale.indipendente.conLogo && Canale.indipendente.nomeInFrase == "indipendente")
        NomiCanaliCorrenti.imposta(NomiCanali(primo: "Agenzia", secondo: "Studio Rossi"))
        verifica.vero("Canali: con i nomi scelti l'etichetta li porta",
                      Canale.alleanza.nomeBreve == "Agenzia" && Canale.indipendente.nomeBreve == "Studio Rossi")
        verifica.vero("Canali: con i nomi scelti anche la scritta lunga",
                      Canale.alleanza.nome == "Agenzia" && Canale.indipendente.nome == "Studio Rossi")
        verifica.vero("Canali: con un nome scelto niente logo Alleanza",
                      !Canale.alleanza.conLogo && Canale.indipendente.nomeInFrase == "Studio Rossi")
        NomiCanaliCorrenti.imposta(prima)

        // L'archivio: senza il campo i nomi di base, con il campo i nomi tornano uguali
        let vuote = try? JSONDecoder().decode(Impostazioni.self, from: Data("{}".utf8))
        verifica.vero("Canali: un archivio di prima si apre con i nomi di base", vuote != nil && vuote?.nomiCanali == nil)
        var imp = Impostazioni()
        imp.nomiCanali = NomiCanali(primo: "Agenzia", secondo: "Studio Rossi")
        let tornate = (try? JSONEncoder().encode(imp)).flatMap { try? JSONDecoder().decode(Impostazioni.self, from: $0) }
        verifica.vero("Canali: i nomi scelti vanno e tornano dall'archivio", tornate?.nomiCanali == imp.nomiCanali)
        var diBase = Impostazioni()
        diBase.nomiCanali = .base
        let base = (try? JSONEncoder().encode(diBase)).flatMap { try? JSONDecoder().decode(Impostazioni.self, from: $0) }
        verifica.vero("Canali: i nomi di base scritti nell'archivio si leggono come nessun nome", base != nil && base?.nomiCanali == nil)

        #if os(macOS)
        verifica.vero("Primo avvio: tre domande, tre opzioni",
                      TestiPrimoAvvio.pagine == 3 && SceltaInizio.allCases.count == 3
                      && SceltaInizio.allCases.first == .prova)
        verifica.vero("Primo avvio: tre punti nella prima pagina, gli ultimi «Tre domande, e poi si comincia.»",
                      TestiPrimoAvvio.punti.count == 3
                      && TestiPrimoAvvio.punti.first == "I calcoli li fa Lucy: tu scegli e spieghi."
                      && TestiPrimoAvvio.punti.last == "Tre domande, e poi si comincia.")
        verifica.vero("Primo avvio: «Il primo avvio · 2 di 3»", TestiPrimoAvvio.occhiello(1) == "Il primo avvio · 2 di 3")
        #endif
    }
}
