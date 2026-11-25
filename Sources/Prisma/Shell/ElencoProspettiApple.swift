#if os(macOS)
import SwiftUI

// Migliorie d'uso 23 (Design/uso/gruppo-03.md §23): l'elenco dei documenti di Prospetti si legge a colpo d'occhio.
// Qui il report adatto all'incontro di oggi, le etichette sotto la riga e la «i» sopra la pagina con la scheda
// «A cosa serve». I gruppi, le righe e le fonti stanno in Dati/Prospetto.swift (`ElencoProspetti`, `TipoProspetto.inBreve`,
// `fonti`); la colonna in Shell/ProspettiApple.swift; i valori in Tema.Apple.Prospetti.Laterale e `.Info`.

extension StatoShell {
    /// Il documento da segnare «per l'incontro di oggi» (decisione 23-c): se il cliente ha un appuntamento di oggi non
    /// ancora concluso, il primo, nell'ordine dell'elenco, dei report adatti a quell'incontro (`TipoProspetto.perIncontro`).
    /// Ricavato una volta per cliente finché non cambiano i dati dei calcoli o il giorno.
    func prospettoPerIncontroOggi(_ clienteId: String) -> TipoProspetto? {
        guard !clienteId.isEmpty else { return nil }
        return ricavato("prospetti-incontro-oggi|\(clienteId)") { () -> TipoProspetto? in
            StatoShell.prospettoPerIncontro(appuntamenti: appuntamentiCliente(clienteId), posizioni: posizioni, adesso: Date())
        }
    }

    /// La regola pura, per la prova: solo gli appuntamenti di oggi ancora da concludere (non i blocchi «Non disponibile»).
    static func prospettoPerIncontro(appuntamenti: [Appuntamento], posizioni: [Posizione], adesso: Date) -> TipoProspetto? {
        let cal = Calendar.current
        guard let a = appuntamenti.first(where: {
            cal.isDate($0.inizio, inSameDayAs: adesso) && $0.stato != .concluso && $0.tipo != .nonDisponibile
        }) else { return nil }
        let posizione = a.posizioneId.flatMap { id in posizioni.first { $0.id == id } }
        let scelti = TipoProspetto.perIncontro(a, posizione: posizione, oggi: adesso)
        return ElencoProspetti.ordine.first { scelti.contains($0) }
    }
}

/// Le etichette sotto la riga di un documento: «per il cliente», «per te» (neutre) e, se è il caso, «per l'incontro
/// di oggi» in verde.
struct EtichetteVoceProspetto: View {
    let versioni: [VersioneProspetto]
    let perIncontroOggi: Bool

    var body: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        // Tutte su una riga se c'è posto; altrimenti «per l'incontro di oggi» va a capo: nessuna etichetta esce dalla
        // colonna né tocca il suo bordo
        ViewThatFits(in: .horizontal) {
            HStack(spacing: l.spazioEtichette) {
                versioniVista
                if perIncontroOggi { incontro }
            }
            VStack(alignment: .leading, spacing: l.spazioEtichette) {
                HStack(spacing: l.spazioEtichette) { versioniVista }
                if perIncontroOggi { incontro }
            }
        }
        .padding(.top, l.sopraEtichette)
    }

    private var versioniVista: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        return ForEach(versioni, id: \.self) { v in
            etichetta(TestiElencoProspetti.etichetta(v), testo: l.testoEtichettaVoce, fondo: l.fondoEtichettaVoce)
        }
    }

    private var incontro: some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        return etichetta(TestiElencoProspetti.incontroOggi, testo: l.testoEtichettaIncontro, fondo: l.fondoEtichettaIncontro)
    }

    private func etichetta(_ s: String, testo: Color, fondo: Color) -> some View {
        let l = Tema.Apple.Prospetti.Laterale.self
        return Text(s)
            .carattereApple(l.etichettaVoce)
            .foregroundColor(testo)
            .lineLimit(1)
            .fixedSize()
            .padding(l.paddingEtichettaVoce)
            .background { Capsule(style: .continuous).fill(fondo) }
    }
}

/// La «i» sopra la pagina (accanto al selettore delle versioni): apre la scheda «A cosa serve» con il nome del
/// documento, la descrizione lunga e da dove vengono le cifre.
struct PulsanteInfoProspetto: View {
    let tipo: TipoProspetto
    @State private var aperto = false

    var body: some View {
        let i = Tema.Apple.Prospetti.Info.self
        Button { aperto.toggle() } label: {
            Image(systemName: "info.circle")
                .carattereApple(i.carattereSimbolo)
                .foregroundColor(i.coloreSimbolo)
                .frame(width: i.pulsante, height: i.pulsante)
                .background { Circle().fill(i.fondoPulsante) }
                .overlay { Circle().strokeBorder(i.bordoPulsante, lineWidth: Tema.Apple.Misura.bordo) }
                .contentShape(Circle())
        }
        .buttonStyle(StileSemplice())
        .help(TestiElencoProspetti.aCosaServe)
        .accessibilityLabel(Text(TestiElencoProspetti.aCosaServe))
        .popover(isPresented: $aperto, arrowEdge: .bottom) { SchedaInfoProspetto(tipo: tipo) }
    }
}

/// La scheda «A cosa serve»: occhiello, nome grande, descrizione e le fonti delle cifre.
struct SchedaInfoProspetto: View {
    let tipo: TipoProspetto

    var body: some View {
        let i = Tema.Apple.Prospetti.Info.self
        VStack(alignment: .leading, spacing: i.spazio) {
            Text(TestiElencoProspetti.aCosaServe)
                .carattereApple(i.occhiello)
                .foregroundColor(i.coloreOcchiello)
            Text(tipo.nome)
                .carattereApple(i.nome)
                .foregroundColor(i.coloreNome)
                .fixedSize(horizontal: false, vertical: true)
            Text(tipo.descrizione)
                .carattereApple(i.testo)
                .foregroundColor(i.coloreTesto)
                .fixedSize(horizontal: false, vertical: true)
            Text(TestiElencoProspetti.daDove)
                .carattereApple(i.occhiello)
                .foregroundColor(i.coloreOcchiello)
                .padding(.top, i.sopraFonti)
            Text(tipo.fonti)
                .carattereApple(i.nota)
                .foregroundColor(i.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(i.padding)
        .frame(width: i.larghezza, alignment: .leading)
    }
}
#endif
