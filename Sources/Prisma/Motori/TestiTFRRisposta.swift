import Foundation

// Migliorie d'uso 69 «Il TFR: prima la risposta» (Design/uso/gruppo-12.md §69, template righe 5100-5147).
// I testi di «Simula e confronta › Il TFR» sul Mac: la frase in testa con le tre soglie, la riga sotto, le strade, i tre
// riquadri di «da dove viene la differenza», «Cosa cambia» e la schermata del non dipendente. Le cifre sono tutte di
// `EsitoTFR` (MotoreTFR non cambia: «i conti restano quelli che l'app fa già»); aliquote e limiti si leggono da
// `RegoleTFR` e `RegoleFiscali`, mai scritti a mano.

extension CifreDoc {
    /// Una cifra arrotondata come si dice a voce: alle decine sotto 10.000 €, alle centinaia sopra
    /// ("9.870 €", "16.100 €"). La usa la frase del TFR (il `tfE` del template).
    static func euroArrotondato(_ v: Double) -> String {
        let passo = abs(v) < TestiTFR.sogliaCentinaia ? TestiTFR.passoDecine : TestiTFR.passoCentinaia
        return euro((v / passo).rounded() * passo)
    }
}

extension TestiTFR {
    /// Sotto questa quota del TFR in azienda (3%) la differenza «è piccola».
    static let sogliaDifferenzaPiccola = 0.03
    /// Con questi anni o meno «mancano pochi anni».
    static let anniPochi = 8
    /// L'arrotondamento a voce: alle decine sotto 10.000 €, alle centinaia sopra.
    static let sogliaCentinaia = 10_000.0
    static let passoDecine = 10.0
    static let passoCentinaia = 100.0

    /// Un pezzo della frase: `evidenza` = la cifra in verde.
    struct ParteFrase: Equatable {
        let testo: String
        let evidenza: Bool
    }

    // MARK: - La colonna di sinistra

    static func lavoroDi(_ nome: String) -> String { "Il lavoro di \(nome)" }
    static let daVerificare = "Da verificare"
    static let etichettaRetribuzione = "Retribuzione lorda dell'anno"
    static let aiutoRetribuzione = "Quella utile al TFR"
    static let etichettaAnni = "Anni che mancano alla pensione"
    static let aiutoAnni = "Gli anni con questo datore di lavoro fino alla pensione"
    static func etichettaRendimento(netto: Bool) -> String {
        netto ? "Quanto rende il fondo, netto" : "Quanto rende il fondo, lordo"
    }
    static let aiutoRendimento = "Netto o lordo si sceglie in «Altre ipotesi»"
    static let altreIpotesi = "Altre ipotesi"

    /// La riga grigia delle ipotesi sotto i comandi, con i valori veri: «Le ipotesi: la retribuzione cresce dell'1%
    /// oltre l'inflazione; in azienda il TFR si rivaluta dell'1,5% più tre quarti dell'inflazione.».
    static func rigaIpotesi(_ i: IpotesiTFR) -> String {
        let c = i.crescitaReale
        let crescita: String
        if c > 0 {
            crescita = "la retribuzione cresce \(del(Formati.percentuale(c))) oltre l'inflazione"
        } else if c < 0 {
            crescita = "la retribuzione cresce \(del(Formati.percentuale(-c))) meno dell'inflazione"
        } else {
            crescita = "la retribuzione segue l'inflazione"
        }
        let quota = RegoleTFR.quotaInflazione == 0.75 ? "tre quarti" : il(Formati.percentuale(RegoleTFR.quotaInflazione * 100))
        return "Le ipotesi: \(crescita); in azienda il TFR si rivaluta \(del(Formati.percentuale(RegoleTFR.rivalutazioneFissa))) più \(quota) dell'inflazione."
    }

    // MARK: - La frase

    static func occhielloRisposta(_ nome: String) -> String { "Il TFR di \(nome): in azienda o nel fondo pensione" }

    /// «Tra un anno», «Tra 20 anni».
    static func tra(_ n: Int) -> String { n == 1 ? "Tra un anno" : "Tra \(n) anni" }

    /// «a Marco», «ad Anna».
    static func aNome(_ nome: String) -> String {
        guard let p = nome.first else { return "a" }
        return "AEIOUaeiou".contains(p) ? "ad \(nome)" : "a \(nome)"
    }

    /// La frase in testa, in pezzi (la cifra della prima soglia in verde). Tre soglie sulla differenza fra il fondo e
    /// l'azienda: oltre il 3% del TFR in azienda, fra 0 e 3% («la differenza è piccola», e con otto anni o meno
    /// «Mancano pochi anni…»), sotto zero («conviene lasciarlo in azienda»).
    static func fraseRispostaParti(_ e: EsitoTFR, nome: String) -> [ParteFrase] {
        let d = e.differenza
        let n = max(1, e.ipotesi.anni)
        let quando = tra(n)
        if d > e.azienda.netto * sogliaDifferenzaPiccola {
            return [ParteFrase(testo: "\(quando), con il TFR nel fondo pensione \(nome) avrebbe circa ", evidenza: false),
                    ParteFrase(testo: CifreDoc.euroArrotondato(d), evidenza: true),
                    ParteFrase(testo: " in più che lasciandolo in azienda.", evidenza: false)]
        }
        if d >= 0 {
            var t = "\(quando) la differenza è piccola: nel fondo pensione \(nome) avrebbe \(CifreDoc.euroArrotondato(d)) in più."
            if n <= anniPochi { t += " Mancano pochi anni: qui conta più la tranquillità che il conto." }
            return [ParteFrase(testo: t, evidenza: false)]
        }
        return [ParteFrase(testo: "Con queste ipotesi \(aNome(nome)) conviene lasciarlo in azienda: nel fondo avrebbe \(CifreDoc.euroArrotondato(-d)) in meno.",
                           evidenza: false)]
    }

    /// La frase intera (accessibilità, prove, domanda a Vera).
    static func fraseRisposta(_ e: EsitoTFR, nome: String) -> String {
        fraseRispostaParti(e, nome: nome).map(\.testo).joined()
    }

    /// La riga sotto la frase: il contributo (se c'è) e la differenza in soldi di oggi.
    static func sottoRisposta(_ e: EsitoTFR, nome: String) -> String {
        let i = e.ipotesi
        let anni = Double(max(1, i.anni))
        var t = ""
        if let c = e.fondoContributi {
            let inPiu = c.netto - e.azienda.netto
            let tasca = e.versatoLavoratore
            if i.contributoLavoratore > 0 {
                let azienda: String
                if i.contributoDatore <= 0 {
                    azienda = "l'azienda non aggiunge niente"
                } else if abs(i.contributoDatore - i.contributoLavoratore) < 0.05 {
                    azienda = "l'azienda mette altrettanto"
                } else {
                    azienda = "l'azienda mette \(il(Formati.percentuale(i.contributoDatore)))"
                }
                t += "Se ci aggiunge \(il(Formati.percentuale(i.contributoLavoratore))) di suo, \(CifreDoc.euroArrotondato(tasca / anni)) l'anno, \(azienda): "
            } else {
                t += "Con \(il(Formati.percentuale(i.contributoDatore))) dell'azienda "
            }
            if inPiu <= 0 {
                t += "anche così resterebbe sotto. "
            } else if tasca <= sogliaEquivalenza {
                t += "alla fine avrebbe \(CifreDoc.euroArrotondato(inPiu)) in più. "
            } else if inPiu > tasca {
                t += "alla fine avrebbe \(CifreDoc.euroArrotondato(inPiu)) in più, di cui \(CifreDoc.euroArrotondato(tasca)) versati di tasca sua. "
            } else {
                t += "alla fine avrebbe \(CifreDoc.euroArrotondato(inPiu)) in più, ma ne avrebbe versati \(CifreDoc.euroArrotondato(tasca)) di tasca sua. "
            }
        }
        t += "In soldi di oggi la differenza è \(CifreDoc.euroArrotondato(abs(e.fondo.reale - e.azienda.reale)))."
        return t
    }

    // MARK: - Le strade

    static let titoloStrade = "Le strade: quanto resta in mano, tolte le tasse"
    /// I nomi delle strade sullo schermo del Mac (decisione 69-c: prospetto e report tengono i nomi di sempre, vedi
    /// Design/uso/resta-da-fare.md).
    static let stradaLasciata = "Lasciato in azienda"
    static let stradaNelFondo = "Nel fondo pensione"
    static let stradaConContributo = "Nel fondo, con il contributo suo e dell'azienda"

    // MARK: - Da dove viene la differenza

    static let titoloTasse = "Le tasse quando lo incassa"
    static var testoTasse: String {
        "In azienda paga l'aliquota media dei suoi redditi. Nel fondo scende con gli anni, fino al \(Formati.percentuale(RegoleFiscali.previdenzaMinima))."
    }

    static let titoloContributoAzienda = "Il contributo dell'azienda"
    static func valoreContributoAzienda(_ e: EsitoTFR) -> String {
        guard e.ipotesi.contributoDatore > 0 else { return "non contato" }
        return "+ \(CifreDoc.euroArrotondato(e.versatoDatore / Double(max(1, e.ipotesi.anni)))) l'anno"
    }
    static func testoContributoAzienda(_ e: EsitoTFR, nome: String) -> String {
        e.ipotesi.contributoDatore > 0
            ? "Arriva solo se versa anche \(nome). Oggi quei soldi non li prende."
            : "Si aggiunge in «Altre ipotesi»."
    }

    static let titoloRendimento = "Il rendimento che serve al fondo"
    /// Vero se al fondo basta anche un rendimento nullo (o negativo) per stare davanti.
    static func bastaZero(_ e: EsitoTFR) -> Bool {
        switch e.pareggio {
        case .sempre: return true
        case .mai: return false
        case .a: return (e.pareggio.nellaBase(netta: e.ipotesi.rendimentoNetto) ?? 0) <= 0
        }
    }
    static func valoreRendimento(_ e: EsitoTFR) -> String {
        if bastaZero(e) { return "anche a zero" }
        if case .mai = e.pareggio { return "oltre il \(Formati.percentuale(RegoleTFR.pareggioMassimo))" }
        let v = e.pareggio.nellaBase(netta: e.ipotesi.rendimentoNetto) ?? 0
        return "\(CifreDoc.percento(v, decimali: 1)) l'anno" + (e.ipotesi.rendimentoNetto ? "" : " lordo")
    }
    static func testoRendimento(_ e: EsitoTFR) -> String {
        let cresce = "In azienda il TFR cresce \(del(CifreDoc.percento(e.rivalutazioneNetta, decimali: 1))) l'anno, senza sorprese."
        if bastaZero(e) { return "Con le tasse più basse il fondo conviene anche se non rendesse niente. " + cresce }
        if case .mai = e.pareggio { return cresce + " Con queste ipotesi il fondo non lo raggiunge." }
        return cresce + " Nel fondo dipende dai mercati: sopra questa soglia conviene il fondo."
    }

    // MARK: - Cosa cambia, la fila

    static func titoloCosaCambia(_ nome: String) -> String { "Cosa cambia per \(nome)" }
    /// Regole, non cifre: le due righe del template.
    static let cosaCambia = [
        "Nel fondo i soldi restano fino alla pensione: prima si possono chiedere solo gli anticipi previsti, per la casa o le spese mediche.",
        "La scelta del fondo non si può disfare. Lasciarlo in azienda sì: può cambiare idea quando vuole.",
    ]
    static func prospettoPer(_ nome: String) -> String { nome.isEmpty ? "Fanne un prospetto" : "Fanne un prospetto per \(nome)" }
    static let chiediVera = "Chiedi a Lucy di spiegarlo"
    static let nonPromesse = "Stime con le ipotesi qui a sinistra: non sono promesse."
    static let altro = "Altro"
    static let dettaglio = "Dettaglio"
    static let indicaRetribuzione = "Indica la retribuzione utile al TFR per confrontare le due strade."

    /// La domanda a Vera (in modalità lavoro): la frase e la riga sotto sono le cifre di Prisma, Qwen le racconta.
    static func domandaVera(_ e: EsitoTFR, nome: String) -> String {
        "Spiegami il TFR di \(nome): in azienda o nel fondo pensione? Le cifre di Lucy: \(fraseRisposta(e, nome: nome)) \(sottoRisposta(e, nome: nome))"
    }

    // MARK: - Chi non lavora da dipendente

    static func lavoroNonDipendente(professione: String, tipo: TipoLavoratore) -> String {
        let p = professione.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(p.isEmpty ? tipo.nome : p). Nel dossier non risulta un lavoro da dipendente."
    }
    static let soloDipendenti = "Il TFR matura solo per chi lavora da dipendente. Se il dato del dossier è sbagliato, si corregge in Anagrafica."
    static let apriAnagrafica = "Apri l'Anagrafica"
    static func occhielloSenzaTFR(_ nome: String) -> String { "Il TFR di \(nome)" }

    /// La frase per tipo (decisione 69-d): chi lavora in proprio, e il collaboratore, che in proprio non è.
    static func fraseSenzaTFR(_ tipo: TipoLavoratore, nome: String) -> String {
        switch tipo {
        case .collaboratore: return "\(nome) è un collaboratore: il TFR non c'è."
        case .dipendente: return "\(nome) lavora da dipendente: il TFR c'è."
        case .autonomo, .gestioneSeparata, .cassaProfessionale: return "\(nome) lavora in proprio: il TFR non c'è."
        }
    }
    static func testoSenzaTFR(_ nome: String) -> String {
        "Il TFR matura solo per chi lavora da dipendente. Per \(nome) la domanda è un'altra: quanto mettere da parte, ogni mese, per avere la pensione che vuole."
    }
    static let apriContoPensione = "Apri il conto della pensione"
    static let faiLoStesso = "Fai il conto lo stesso"
}
