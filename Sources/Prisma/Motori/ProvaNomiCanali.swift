import Foundation

/// Migliorie d'uso 38 «I canali hanno il nome che scegli»: la pulizia del nome (18 caratteri, caratteri tolti, vuoto =
/// quello di base), `Canale.nomeBreve`, `Canale.nome` e il logo (dal 25 novembre 2026 un solo canale, quello di Lucy,
/// con i nomi di base e con quelli scelti), il campo letto
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
        // Dal 25 novembre 2026 (decisione dell'utente) un solo canale, quello di Lucy: stesse scritte per i due valori
        // salvati, con i nomi di base e con quelli scelti, e mai il logo di una compagnia
        func unico() -> Bool {
            Canale.allCases.allSatisfy { c in
                c.nome == "Lucy · consulenza finanziaria" && c.nome == CanaleLucy.nome
                    && c.nomeBreve == "Lucy" && c.nomeInFrase == "Lucy" && !c.conLogo
            }
        }
        verifica.vero("Canali: un solo canale, «Lucy» e «Lucy · consulenza finanziaria» per i due valori salvati", unico())
        NomiCanaliCorrenti.imposta(NomiCanali(primo: "Agenzia", secondo: "Studio Rossi"))
        verifica.vero("Canali: un solo canale anche con i nomi scelti di prima", unico())
        verifica.vero("Canali: il tipo di prodotti dove una regola resta diversa, mai il nome di un canale",
                      Canale.alleanza.tipoProdotti == "prodotti assicurativi" && Canale.indipendente.tipoProdotti == "strumenti finanziari")
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
        // Dal 25 novembre 2026 (un solo canale, quello di Lucy) le domande sono due: niente pagina dei canali
        verifica.vero("Primo avvio: due domande, tre opzioni",
                      TestiPrimoAvvio.pagine == 2 && SceltaInizio.allCases.count == 3
                      && SceltaInizio.allCases.first == .prova)
        verifica.vero("Primo avvio: tre punti nella prima pagina, gli ultimi «Due domande, e poi si comincia.»",
                      TestiPrimoAvvio.punti.count == 3
                      && TestiPrimoAvvio.punti.first == "I calcoli li fa Lucy: tu scegli e spieghi."
                      && TestiPrimoAvvio.punti.last == "Due domande, e poi si comincia.")
        verifica.vero("Primo avvio: «Il primo avvio · 2 di 2»", TestiPrimoAvvio.occhiello(1) == "Il primo avvio · 2 di 2")
        #endif
    }
}
