import Foundation

/// Migliorie d'uso 11 «Il dossier ha un indice»: i tre gruppi dell'indice (La persona, Il piano, Le carte) con tutte le
/// sezioni una volta sola, e «L'azienda» solo per chi ha un'azienda o fa l'imprenditore o il titolare (o quando è la
/// sezione aperta, da «Aggiungi un'azienda…»). Chiamata da `ProvaCalcoli.esegui()`.
enum ProvaCalcoliIndiceDossier {
    static func esegui(_ verifica: VerificaCalcoli) {
        var dipendente = Cliente.nuovo(tinta: .blu)
        dipendente.professione = "Impiegata"
        var imprenditore = Cliente.nuovo(tinta: .verde)
        imprenditore.professione = "Imprenditrice edile"
        var titolare = Cliente.nuovo(tinta: .oro)
        titolare.professione = "Titolare di un bar"

        let tutte = SchedaCliente.indice.flatMap { $0.voci }
        verifica.vero("Indice del dossier: ogni sezione una volta sola",
                      tutte.count == SchedaCliente.allCases.count && Set(tutte) == Set(SchedaCliente.allCases))
        verifica.vero("Indice del dossier: tre gruppi nell'ordine del template",
                      SchedaCliente.indice.map { $0.titolo } == ["La persona", "Il piano", "Le carte"])

        let voci: (Cliente, SchedaCliente?) -> [SchedaCliente] = { c, s in
            SchedaCliente.indice(per: c, scelta: s).flatMap { $0.voci }
        }
        verifica.vero("Indice del dossier: niente «L'azienda» per chi non è imprenditore",
                      !voci(dipendente, .panoramica).contains(.azienda) && voci(dipendente, .panoramica).count == tutte.count - 1)
        verifica.vero("Indice del dossier: «L'azienda» per imprenditori e titolari",
                      voci(imprenditore, nil).contains(.azienda) && voci(titolare, nil).contains(.azienda))
        verifica.vero("Indice del dossier: «L'azienda» aperta da «Aggiungi un'azienda…» resta in vista",
                      voci(dipendente, .azienda).contains(.azienda))
        var conAzienda = dipendente
        conAzienda.aziende = [AziendaCliente(ragioneSociale: "Prova S.r.l.")]
        verifica.vero("Indice del dossier: «L'azienda» per chi ne ha una registrata",
                      SchedaCliente.mostraAzienda(per: conAzienda) && !SchedaCliente.mostraAzienda(per: nil))
    }
}
