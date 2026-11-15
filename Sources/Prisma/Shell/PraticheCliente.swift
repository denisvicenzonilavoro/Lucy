import SwiftUI

// Migliorie d'uso 33 «Pratiche segue il cliente» (Design/uso/gruppo-05.md §33): sul Mac le quattro schede di Pratiche
// mostrano solo le cose del cliente scelto nella barra, e con «Tutti i clienti» quelle di tutti. Il cliente si sceglie
// solo nella barra: dentro Pratiche nessun selettore. Su iPhone e iPad (dove Pratiche non si apre) il cliente di
// Pratiche è sempre nil: tutto resta com'era.

extension StatoShell {
    /// Il cliente di cui parla Pratiche: quello della barra, nil con «Tutti i clienti» (e sempre su iPhone e iPad).
    var clientePratiche: Cliente? {
        #if os(macOS)
        return tuttiIClienti ? nil : clienteAttivo
        #else
        return nil
        #endif
    }

    /// Le strade che portano Pratiche su un cliente (la tappa 5 della proposta, «Crea il dossier» con i moduli, la carta
    /// «moduli» della notte, il riquadro finale): sul Mac scelgono il cliente della barra in silenzio.
    func portaAlClientePratiche(_ id: String) {
        #if os(macOS)
        scegliCliente(id)
        #else
        clienteAttivoId = id
        #endif
    }

    /// «Scegli il cliente» dei moduli senza cliente: il pannello «Di chi parliamo?» della barra.
    func apriSceltaClientePratiche() {
        #if os(macOS)
        apriSceltaCliente()
        #endif
    }

    /// Gli stati delle pratiche mostrati (solo quelle del cliente `solo`, o di tutti), tenuti nella cache comune: la
    /// testata (il numero delle ferme) e la scheda «Dopo la firma» leggono gli stessi, e MotorePratiche si rifà solo
    /// quando cambia un ingresso. Legge vivi gli stessi ingressi di `statiPratiche` (la vista resta iscritta a tutti).
    func statiPraticheVisti(solo: String?, oggi: Date = Date()) -> [StatoPratica] {
        _ = derivatiValidi()
        let ingressi = IngressiStatiPratiche(versione: versioneCalcoli, giorno: Calendar.current.startOfDay(for: oggi),
                                             modo: modoCliente, solo: solo, pratiche: dati.pratiche,
                                             schede: dati.schedeAdeguatezza, impostazioni: dati.impostazioni)
        return cacheStatiPratiche.stati(ingressi) {
            let tutti = statiPratiche(oggi: oggi)
            guard let solo else { return tutti }
            return tutti.filter { $0.clienteId == solo }
        }
    }

    /// Le pratiche ferme (del cliente della barra, o di tutti): il numerino rosso su «Dopo la firma».
    func praticheFermeVisibili(oggi: Date = Date()) -> Int {
        let stati = statiPraticheVisti(solo: clientePratiche?.id, oggi: oggi)
        return MotorePratiche.riepilogo(stati, soglia: dati.impostazioni.pratiche.giorniFerma, oggi: oggi).ferme
    }

    /// I bisogni della scheda Proposta: quelli del cliente della barra, o di tutti. La cache resta su tutti i clienti
    /// (`bisogniProposta`): scegliere un cliente filtra soltanto, senza rifare i motori.
    func bisogniProposta(solo: String?) -> [BisognoScoperto] {
        let tutti = bisogniProposta()
        guard let solo else { return tutti }
        return tutti.filter { $0.clienteId == solo }
    }
}

/// Ciò da cui dipendono gli stati delle pratiche: i dati dei calcoli (versione, giorno, modalità cliente, come
/// `datiDeiCalcoli`), il cliente scelto e le pratiche, le schede e le impostazioni lette vive. Gli array si confrontano
/// subito quando sono gli stessi dell'archivio (stesso buffer).
struct IngressiStatiPratiche: Equatable {
    let versione: Int
    let giorno: Date
    let modo: String?
    let solo: String?
    let pratiche: [Pratica]
    let schede: [SchedaAdeguatezza]
    let impostazioni: Impostazioni
}

/// Gli stati delle pratiche dell'ultima rivalutazione (una sola istanza in `StatoShell`, non osservata): il dettaglio che
/// si apre o si chiude ridisegna la scheda più volte per animazione, e MotorePratiche (indici su posizioni, clienti e
/// documenti) si rifà solo se cambia un ingresso.
final class CacheStatiPratiche {
    private var ultimo: (ingressi: IngressiStatiPratiche, stati: [StatoPratica])?

    func stati(_ ingressi: IngressiStatiPratiche, calcola: () -> [StatoPratica]) -> [StatoPratica] {
        if let u = ultimo, u.ingressi == ingressi { return u.stati }
        let v = calcola()
        ultimo = (ingressi, v)
        return v
    }
}

/// Lo stato vuoto di una scheda di Pratiche per il cliente scelto (§33.3 n. 7, `pratVuoto` del template): al centro,
/// senza glifo, il titolo 22 grassetto, il testo 14 largo al più 470 e, se c'è, il pulsante blu grande.
struct VuotoClientePratiche: View {
    let titolo: String
    let testo: String
    var pulsante: String? = nil
    var azione: () -> Void = {}

    private typealias P = Tema.Apple.Pratiche

    var body: some View {
        VStack(spacing: 0) {
            Text(titolo)
                .carattereApple(P.titoloVuotoCliente)
                .foregroundColor(Tema.Apple.Colore.inchiostro)
                .entrataCascata(0, base: Tema.Apple.Moto.Cascata.baseDentroApp)
            Text(testo)
                .carattereApple(P.testoVuotoCliente)
                .foregroundColor(Tema.Apple.Colore.inchiostro2)
                .padding(.top, P.sopraTestoVuotoCliente)
                .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp)
            if let pulsante {
                Button(pulsante, action: azione)
                    .buttonStyle(.applePrimarioGrande)
                    .padding(.top, P.sottoTestoVuotoCliente)
                    .entrataCascata(2, base: Tema.Apple.Moto.Cascata.baseDentroApp)
            }
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: P.larghezzaVuotoCliente)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}
