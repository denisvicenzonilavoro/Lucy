#if os(macOS)
import SwiftUI

// Migliorie d'uso 50 (Design/uso/gruppo-08.md §50), solo Mac: il mese a tutta larghezza. Le celle sono card (sabato e
// domenica sul fondo dei pannelli, i giorni fuori dal mese senza fondo né bordo, il giorno scelto con l'anello
// d'accento), con fino a due impegni («09:30 Marco», nel colore del canale: decisione 50-a), le scadenze scritte con il
// pallino arancio e «+N altri»; il doppio clic apre il giorno in «Giorno». La colonna del giorno, a destra, la monta
// AppAgenda (`colonnaGiornoMese`) con le righe `RigaMeseUso` e l'entrata `EntrataGiornoMese`. Le regole pure
// (quante righe, i testi) stanno in Motori/RegoleMeseAgenda.swift.

/// Una cella del mese a tutta larghezza.
struct CellaMeseUso: View {
    let giorno: Date
    let nelMese: Bool
    let selezionato: Bool
    let oggi: Bool
    /// Sabato o domenica.
    let festivo: Bool
    let appuntamenti: [Appuntamento]
    let scadenze: [Posizione]
    /// Rifinitura 57: le scadenze dello Studio da fare in questo giorno («Scade F24», dopo quelle delle posizioni).
    var scadenzeStudio: [ScadenzaStudio] = []
    /// Le attività ancora da fare con scadenza in questo giorno (il segno arancio resta: decisione 50-b).
    let daFare: Int
    /// Il giorno è passato e ha attività non fatte: il segno diventa rosso.
    let scadute: Bool
    var occasioni = SegniOccasioni()
    /// Quante righe (pillole, scadenze, «+N») stanno nella cella (0: solo numero e segni).
    let posto: Int
    /// I nomi brevi dei clienti, preparati una volta per disegno (mai `stato.cliente` per ogni pillola).
    let nomi: [String: String]
    let canale: (Appuntamento) -> Canale?
    let azione: () -> Void
    let doppio: () -> Void
    @State var sopra = false

    var body: some View {
        let m = Misure.AgendaMese.self
        let forma = RoundedRectangle(cornerRadius: m.raggioCellaUso, style: .continuous)
        let r = RegoleMeseAgenda.righe(appuntamenti: appuntamenti.count, scadenze: tutteLeScadenze, posto: posto)
        VStack(alignment: .leading, spacing: m.spazioRigheCella) {
            testa
            if nelMese {
                ForEach(appuntamenti.prefix(r.pillole)) { e in
                    PillolaMeseUso(
                        ora: Formati.ora.string(from: e.inizio),
                        nome: RegoleMeseAgenda.nomePillola(cliente: nomi[e.clienteId], titolo: e.titolo),
                        canale: canale(e),
                        concluso: e.stato == .concluso
                    )
                }
                ForEach(scadenze.prefix(r.scadenze)) { p in
                    ScadenzaMeseUso(testo: RegoleMeseAgenda.scadenza(p.nome))
                }
                ForEach(scadenzeStudio.prefix(max(0, r.scadenze - scadenze.count))) { s in
                    ScadenzaMeseUso(testo: RegoleMeseAgenda.scadenza(s.titolo))
                }
                if r.altri > 0 && posto > 0 {
                    Text(RegoleMeseAgenda.altri(r.altri))
                        .carattereApple(Tema.Apple.Agenda.MeseUso.altri)
                        .foregroundColor(Tema.Apple.Agenda.MeseUso.coloreAltri)
                        .lineLimit(1)
                        .padding(.leading, m.rientroScadenza)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(m.margineCellaUso)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background { sfondo(forma) }
        .clipShape(forma)
        .overlay {
            // L'anello del giorno scelto sta fuori dalla cella, come il box-shadow di 2 del template
            if selezionato {
                forma.inset(by: -m.anelloScelto / 2)
                    .stroke(Tema.Apple.Agenda.MeseUso.anelloScelto, lineWidth: m.anelloScelto)
            }
        }
        .contentShape(forma)
        // Il doppio clic prima di quello singolo (come nella settimana della miglioria 18)
        .onTapGesture(count: 2) { doppio() }
        .onTapGesture { azione() }
        .onHover { sopra = $0 }
        .help(descrizione + " · doppio clic: apri il giorno")
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(descrizione)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { azione() }
    }

    /// Il numero nel tondo (oggi rosso pieno), a destra i segni che la cella non scrive: riesami, attività da fare,
    /// occasioni e, se la cella è troppo bassa per le righe, impegni e scadenze.
    private var testa: some View {
        let m = Misure.AgendaMese.self
        let t = Tema.Apple.Agenda.MeseUso.self
        return HStack(spacing: m.spazioSegni) {
            Text(Formati.giorno.string(from: giorno))
                .carattereApple(oggi ? t.numeroOggi : t.numero)
                .foregroundColor(oggi ? t.testoOggi : (nelMese ? t.coloreNumero : t.coloreFuoriMese))
                .frame(width: m.cerchioNumero, height: m.cerchioNumero)
                .background {
                    if oggi { Circle().fill(t.fondoOggi) }
                }
            Spacer(minLength: 0)
            if nelMese {
                if posto == 0 && !appuntamenti.isEmpty {
                    segno(Tema.Apple.Agenda.Segno.appuntamento, conteggio: appuntamenti.count)
                }
                if riesami > 0 {
                    segno(Tema.Apple.Agenda.Segno.riesame, conteggio: riesami)
                }
                if daFare > 0 {
                    segno(scadute ? Tema.Apple.Agenda.Segno.attivitaScaduta : Tema.Apple.Agenda.Segno.attivita,
                          conteggio: daFare)
                }
                if posto == 0 && tutteLeScadenze > 0 {
                    segno(t.pallinoScadenza, conteggio: tutteLeScadenze)
                }
                if !occasioni.vuoto {
                    AnelliOccasioni(segni: occasioni, selezionato: false)
                }
            }
        }
        .lineLimit(1)
    }

    /// Un segno pieno, con il numero se sono più di uno.
    private func segno(_ colore: Color, conteggio: Int) -> some View {
        let m = Misure.AgendaMese.self
        return HStack(spacing: m.spazioConteggio) {
            Circle().fill(colore).frame(width: m.segno, height: m.segno)
            if conteggio > 1 {
                Text("\(conteggio)")
                    .font(Tipo.conteggioSegno)
                    .foregroundColor(Colori.Agenda.conteggioSegno)
                    .fixedSize()
            }
        }
    }

    /// Card con il filo (sabato e domenica sul fondo dei pannelli, passaggio `cardPiena`); fuori dal mese niente.
    @ViewBuilder private func sfondo(_ forma: RoundedRectangle) -> some View {
        let t = Tema.Apple.Agenda.MeseUso.self
        if nelMese {
            forma.fill(sopra ? t.fondoPassaggio : (festivo ? t.fondoFestivo : t.fondo))
                .overlay { forma.strokeBorder(t.bordo, lineWidth: Tema.Apple.Misura.bordo) }
        } else {
            Color.clear
        }
    }

    /// Le scadenze del giorno: delle posizioni e dello Studio.
    private var tutteLeScadenze: Int { scadenze.count + scadenzeStudio.count }

    /// Gli appuntamenti di revisione del giorno (i riesami).
    private var riesami: Int { appuntamenti.filter { $0.tipo == .revisione }.count }

    private var descrizione: String {
        var parti = [Formati.dataLunga.string(from: giorno)]
        if oggi { parti.append("oggi") }
        parti.append(RegoleMeseAgenda.conteggio(impegni: appuntamenti.count, scadenze: tutteLeScadenze, solo: nil))
        if riesami > 0 { parti.append("\(riesami) \(riesami == 1 ? "riesame" : "riesami")") }
        if daFare > 0 { parti.append("\(daFare) da fare") }
        if occasioni.numero > 0 { parti.append("\(occasioni.numero) \(occasioni.numero == 1 ? "occasione" : "occasioni")") }
        return parti.joined(separator: " · ")
    }
}

/// La pillola di un impegno nella cella: filo sinistro e fondo del canale, l'ora in peso normale e il nome breve del
/// cliente (il titolo solo senza cliente), su una riga con i puntini.
struct PillolaMeseUso: View {
    let ora: String
    let nome: String
    let canale: Canale?
    let concluso: Bool

    var body: some View {
        let m = Misure.AgendaMese.self
        let t = Tema.Apple.Agenda.MeseUso.self
        let forma = RoundedRectangle(cornerRadius: m.raggioPillolaUso, style: .continuous)
        HStack(spacing: m.spazioOraPillola) {
            Text(ora)
                .carattereApple(t.oraPillola)
                .foregroundColor(concluso ? t.colorePillolaConclusa : t.coloreOraPillola)
                .lineLimit(1)
                .fixedSize()
            Text(nome)
                .carattereApple(t.pillola)
                .foregroundColor(concluso ? t.colorePillolaConclusa : t.colorePillola)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(m.marginePillolaUso)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(forma.fill(Colori.Agenda.pillolaFondo(canale)))
        .overlay(alignment: .leading) {
            Rectangle().fill(Colori.Agenda.pillola(canale)).frame(width: m.filoPillola)
        }
        .clipShape(forma)
    }
}

/// Una scadenza scritta nella cella: il pallino arancio e «Scade …» in arancio scuro.
struct ScadenzaMeseUso: View {
    let testo: String

    var body: some View {
        let m = Misure.AgendaMese.self
        let t = Tema.Apple.Agenda.MeseUso.self
        HStack(spacing: m.spazioScadenza) {
            Circle().fill(t.pallinoScadenza).frame(width: m.pallinoScadenza, height: m.pallinoScadenza)
            Text(testo)
                .carattereApple(t.scadenza)
                .foregroundColor(t.coloreScadenza)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.leading, m.rientroScadenza)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Una riga della colonna del giorno (`.mRiga`): filo sinistro nel colore, fondo `chip`, l'ora in neretto (o «Scade»
/// in arancio), il titolo in neretto e sotto il cliente o «Per te», a destra «›».
struct RigaMeseUso: View {
    let ora: String
    let titolo: String
    let sotto: String
    let colore: Color
    /// La riga di una scadenza: «Scade» in arancio al posto dell'ora.
    var scadenza = false
    var aiuto = ""
    let azione: () -> Void
    @State var sopra = false

    var body: some View {
        let m = Misure.AgendaMese.self
        let t = Tema.Apple.Agenda.MeseUso.self
        let forma = UnevenRoundedRectangle(topLeadingRadius: m.raggioRigaSinistra, bottomLeadingRadius: m.raggioRigaSinistra,
                                           bottomTrailingRadius: m.raggioRigaDestra, topTrailingRadius: m.raggioRigaDestra,
                                           style: .continuous)
        Button(action: azione) {
            HStack(alignment: .firstTextBaseline, spacing: m.spazioRiga) {
                Text(ora)
                    .carattereApple(t.oraRiga)
                    .foregroundColor(scadenza ? t.coloreScadenza : t.coloreTitolo)
                    .lineLimit(1)
                    .fixedSize()
                    .frame(width: m.colonnaOraRiga, alignment: .leading)
                VStack(alignment: .leading, spacing: m.spazioTitoloRiga) {
                    Text(titolo)
                        .carattereApple(t.titoloRiga)
                        .foregroundColor(t.coloreTitolo)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(sotto)
                        .carattereApple(t.clienteRiga)
                        .foregroundColor(t.coloreConteggio)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text("›")
                    .carattereApple(t.titoloRiga)
                    .foregroundColor(t.freccia)
            }
            .padding(m.paddingRiga)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(forma.fill(sopra ? t.fondoRigaPassaggio : t.fondoRiga))
            .overlay(alignment: .leading) {
                Rectangle().fill(colore).frame(width: m.filoPillola)
            }
            .clipShape(forma)
            .contentShape(forma)
        }
        .buttonStyle(StileSemplice())
        .onHover { sopra = $0 }
        .help(aiuto)
    }
}

/// La legenda in fondo alla colonna, sopra un filo: «impegno» con i quadratini dei due canali (decisione 50-a),
/// «scadenza» con il pallino arancio e, con un cliente scelto, «Tutti i clienti».
struct LegendaMeseUso: View {
    let tuttiIClienti: (() -> Void)?

    var body: some View {
        let m = Misure.AgendaMese.self
        let t = Tema.Apple.Agenda.MeseUso.self
        HStack(spacing: m.spazioLegenda) {
            HStack(spacing: m.spazioVoceLegenda) {
                HStack(spacing: m.spazioQuadratini) {
                    quadratino(Colori.Agenda.pillola(.alleanza))
                    quadratino(Colori.Agenda.pillola(.indipendente))
                }
                Text("impegno")
            }
            HStack(spacing: m.spazioVoceLegenda) {
                Circle().fill(t.pallinoScadenza).frame(width: m.quadratinoLegenda, height: m.quadratinoLegenda)
                Text("scadenza")
            }
            Spacer(minLength: 0)
            if let tuttiIClienti {
                Button(action: tuttiIClienti) { Text("Tutti i clienti") }
                    .buttonStyle(StileCollegamento())
                    .fixedSize()
                    .help("Torna agli impegni di tutti i clienti")
            }
        }
        .carattereApple(t.legenda)
        .foregroundColor(t.coloreLegenda)
        .lineLimit(1)
        .padding(.top, m.paddingLegenda)
        .overlay(alignment: .top) {
            Rectangle().fill(t.filo).frame(height: Tema.Apple.Misura.bordo)
        }
    }

    private func quadratino(_ colore: Color) -> some View {
        let m = Misure.AgendaMese.self
        return RoundedRectangle(cornerRadius: m.raggioQuadratino, style: .continuous)
            .fill(colore)
            .frame(width: m.quadratinoLegenda, height: m.quadratinoLegenda)
    }
}

/// L'entrata della colonna del giorno a ogni cambio di giorno (con `.id(giorno)`): da destra di 8 con l'opacità da 0,4,
/// in 260 ms al ritmo dell'app; con «Riduci movimento» una dissolvenza di 0,15 s; nelle istantanee già ferma.
struct EntrataGiornoMese: ViewModifier {
    @Environment(\.prismaCalmo) var calmo
    @Environment(\.prismaScatto) var scatto
    @State var entrata = false

    func body(content: Content) -> some View {
        let m = Misure.AgendaMese.self
        let ferma = entrata || scatto
        content
            .opacity(ferma ? 1 : (calmo ? 0 : m.opacitaEntrataGiorno))
            .offset(x: ferma || calmo ? 0 : m.entrataGiorno)
            .onAppear {
                guard !scatto, !entrata else { return }
                withAnimation(Tema.Apple.Moto.animazione(Tema.Apple.Agenda.MeseUso.animazioneEntrata, calmo: calmo)) {
                    entrata = true
                }
            }
    }
}
#endif
