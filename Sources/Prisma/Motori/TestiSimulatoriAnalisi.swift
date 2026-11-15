import Foundation

/// Un pezzo della frase prima e dopo dei simulatori: il testo e se va in neretto («Oggi», «Con 300 € al mese»).
struct PezzoFraseSimulatore: Equatable {
    let testo: String
    var grassetto = false
}

/// I testi dei simulatori dal vivo di Previdenza e Protezione (migliorie d'uso 45, Design/uso/gruppo-08.md §45): la
/// frase che dice com'è oggi e come diventa con il cursore, gli articoli accordati con il numero e l'avviso del piede.
/// Le cifre arrivano già calcolate da `MotoreSimulatoriAnalisi`: qui non si calcola niente.
enum TestiSimulatoriAnalisi {
    /// L'avviso breve del piede (lo stesso testo ovunque in Analisi 360).
    static let avviso = "Sono stime, non garanzie."
    /// L'invito quando il cursore è sul valore di oggi.
    static let invito = "Sposta il cursore: qui leggi cosa cambia."

    // MARK: - Articoli

    /// true se il numero letto comincia per vocale: 1 (uno), 8 e 80-89 (otto, ottanta…), 11 (undici). Come `elide` del
    /// template (riga 3489).
    static func elide(_ n: Int) -> Bool {
        let t = String(abs(n))
        return t == "1" || t == "11" || t.hasPrefix("8")
    }

    /// «il 42%», «l'80%», «l'11%», «lo 0%».
    static func articolo(_ percentuale: Int) -> String {
        let p = "\(percentuale)%"
        if elide(percentuale) { return "l'" + p }
        return percentuale == 0 ? "lo " + p : "il " + p
    }

    /// «al 42%», «all'80%», «all'11%», «allo 0%».
    static func al(_ percentuale: Int) -> String {
        let p = "\(percentuale)%"
        if elide(percentuale) { return "all'" + p }
        return percentuale == 0 ? "allo " + p : "al " + p
    }

    /// La prima lettera maiuscola («Il 12%», «L'8%»).
    static func maiuscola(_ s: String) -> String {
        guard let prima = s.first else { return s }
        return prima.uppercased() + s.dropFirst()
    }

    /// Una quota 0…1 in percentuale intera; `chiusa` false: mai 100 se qualcosa manca ancora.
    static func percento(_ frazione: Double, chiusa: Bool? = nil) -> Int {
        let p = Int((min(1, max(0, frazione)) * 100).rounded())
        if chiusa == false { return min(99, p) }
        if chiusa == true { return 100 }
        return p
    }

    /// Il testo semplice di una frase (prove, VoiceOver).
    static func testo(_ pezzi: [PezzoFraseSimulatore]) -> String {
        pezzi.map(\.testo).joined()
    }

    // MARK: - Previdenza

    /// «Oggi Marco versa 150 € al mese e copre il 42% del divario.», oppure senza versamento o senza divario.
    static func previdenzaOggi(nome: String, versamento: Double, copertura: Double, divario: Double) -> [PezzoFraseSimulatore] {
        let oggi = PezzoFraseSimulatore(testo: "Oggi", grassetto: true)
        if divario < 0.5 {
            return [oggi, PezzoFraseSimulatore(testo: " \(nome) non ha divario: la pensione pubblica stimata arriva a quella desiderata.")]
        }
        let p = percento(copertura)
        if versamento < 0.5 {
            if p == 0 {
                return [oggi, PezzoFraseSimulatore(testo: " \(nome) non versa niente: il divario è tutto scoperto.")]
            }
            return [oggi, PezzoFraseSimulatore(testo: " \(nome) non versa niente e il montante di oggi copre \(articolo(p)) del divario.")]
        }
        return [oggi, PezzoFraseSimulatore(testo: " \(nome) versa \(Formati.euro(versamento)) al mese e copre \(articolo(p)) del divario.")]
    }

    /// «Con 300 € al mese arriva al 61%: alla pensione che desidera mancherebbero ancora 310 € al mese.» oppure
    /// «… arriva al 100%: il divario è chiuso.».
    static func previdenzaDopo(versamento: Double, copertura: Double, mancano: Double) -> [PezzoFraseSimulatore] {
        let chiuso = mancano < 0.5
        let p = percento(copertura, chiusa: chiuso)
        let fine = chiuso ? "il divario è chiuso."
            : "alla pensione che desidera mancherebbero ancora \(Formati.euro(mancano)) al mese."
        return [PezzoFraseSimulatore(testo: "Con \(Formati.euro(versamento)) al mese", grassetto: true),
                PezzoFraseSimulatore(testo: " arriva \(al(p)): " + fine)]
    }

    /// La frase intera della previdenza: com'è oggi e, se il cursore si è spostato, come diventa (senza divario solo oggi).
    static func previdenza(nome: String, oggi: Double, versamento: Double, coperturaOggi: Double,
                           passo: MotoreSimulatoriAnalisi.PassoPrevidenza) -> [PezzoFraseSimulatore] {
        let prima = previdenzaOggi(nome: nome, versamento: oggi, copertura: coperturaOggi, divario: passo.divario)
        if passo.divario < 0.5 { return prima }
        if abs(versamento - oggi) < 0.5 { return prima + [PezzoFraseSimulatore(testo: " " + invito)] }
        return prima + [PezzoFraseSimulatore(testo: " ")]
            + previdenzaDopo(versamento: versamento, copertura: passo.copertura, mancano: passo.divarioResiduo)
    }

    // MARK: - Protezione

    /// «Oggi è protetto il 64% di quello che servirebbe: 180.000 € su 280.000 €.»
    static func protezioneOggi(assicurato: Double, fabbisogno: Double) -> [PezzoFraseSimulatore] {
        let oggi = PezzoFraseSimulatore(testo: "Oggi", grassetto: true)
        guard fabbisogno >= 0.5 else {
            return [oggi, PezzoFraseSimulatore(testo: " non serve un capitale in più: le ipotesi non danno un fabbisogno scoperto.")]
        }
        let chiusa = assicurato >= fabbisogno - 0.5
        let p = percento(assicurato / fabbisogno, chiusa: chiusa)
        return [oggi, PezzoFraseSimulatore(testo: " è protetto \(articolo(p)) di quello che servirebbe: \(Formati.euro(assicurato)) su \(Formati.euro(fabbisogno)).")]
    }

    /// «Con 100.000 € in più si arriva al 100%, per circa 32 € al mese. Chi conta su quel reddito è coperto.» oppure
    /// «… Resterebbero scoperti 20.000 €.»; senza premio stimato niente «per circa … al mese».
    static func protezioneDopo(aggiunta: Double, copertura: Double, premioMensile: Double?,
                               scoperto: Double) -> [PezzoFraseSimulatore] {
        let chiuso = scoperto < 0.5
        let p = percento(copertura, chiusa: chiuso)
        var resto = " si arriva \(al(p))"
        if let m = premioMensile { resto += ", per circa \(Formati.euro(m)) al mese" }
        resto += "."
        resto += chiuso ? " Chi conta su quel reddito è coperto." : " Resterebbero scoperti \(Formati.euro(scoperto))."
        return [PezzoFraseSimulatore(testo: "Con \(Formati.euro(aggiunta)) in più", grassetto: true),
                PezzoFraseSimulatore(testo: resto)]
    }

    /// La frase intera della protezione.
    static func protezione(_ passo: MotoreSimulatoriAnalisi.PassoProtezione) -> [PezzoFraseSimulatore] {
        let prima = protezioneOggi(assicurato: passo.giaAssicurato, fabbisogno: passo.fabbisogno)
        if passo.fabbisogno < 0.5 { return prima }
        if passo.aggiunta < 0.5 { return prima + [PezzoFraseSimulatore(testo: " " + invito)] }
        return prima + [PezzoFraseSimulatore(testo: " ")]
            + protezioneDopo(aggiunta: passo.aggiunta, copertura: passo.copertura,
                             premioMensile: passo.premioMensile, scoperto: passo.scoperto)
    }

    // MARK: - Lo scarto e le ipotesi

    /// «+150 € al mese rispetto a oggi», «−50 € al mese rispetto a oggi», vuoto sul valore di oggi.
    static func scarto(versamento: Double, oggi: Double) -> String {
        let d = versamento - oggi
        guard abs(d) >= 0.5 else { return "" }
        return "\(d > 0 ? "+" : Formati.meno)\(Formati.euro(abs(d))) al mese rispetto a oggi"
    }

    /// «Aliquota marginale 33%, dal reddito della scheda».
    static func aliquotaDalReddito(_ reddito: Double) -> String {
        "Aliquota marginale \(Formati.percentuale(RegoleFiscali.aliquotaMarginale(reddito: reddito))), dal reddito della scheda"
    }

    /// «deduzione fino a 5.300 € l'anno».
    static var deduzione: String { "deduzione fino a \(Formati.euro(RegoleFiscali.limiteDeducibilita)) l'anno" }

    /// Da dove viene il premio della protezione, al posto di «Fuma» del template (decisione 45-c).
    static func premioProtezione(_ t: MotoreSimulatoriAnalisi.TariffaCasoMorte?, eta: Int?) -> String {
        guard let t else {
            return "Premio non stimabile: nessuna copertura caso morte in archivio ha capitale e premio"
        }
        let fonte = t.fonte == .cliente ? "dalle sue coperture caso morte" : "dalle coperture caso morte in archivio"
        let anni = eta.map { ", a \($0) anni" } ?? ""
        return "Premio stimato \(fonte)\(anni): le condizioni vere vengono dal prodotto"
    }
}
