import SwiftUI

// La Prima Pagina sulla scrivania (NOVITÀ 1 dello stile Carta, template `.w-paper`): «Il Foglio di Prisma» con il numero,
// l'edizione (06:00 o 18:00), il titolo della giornata con l'evidenziatore, chi chiamare e la nota di Vera, e i pulsanti
// «Ascolta» (la voce del Mac) e «Ristampa» (ricompone e rifà l'entrata). Le frasi le scrive MotorePrimaPagina. Mai in
// modalità cliente: porta i nomi di tutti i clienti.

struct PrimaPaginaWidget: View {
    @Environment(StatoShell.self) private var stato
    @Environment(\.prismaStatoFinale) private var statoFinale
    @State private var ristampa = 0
    @State private var visibile = true

    var body: some View {
        let p = stato.primaPagina(ristampa: ristampa)
        let mono = Font.system(size: 11, weight: .regular, design: .monospaced)
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("N. \(p.numero)")
                Spacer()
                Text(p.edizione.nome.uppercased())
                Spacer()
                Text(Formati.dataBreve.string(from: p.data))
            }
            .font(mono).tracking(1.5)
            .foregroundColor(TemaCarta.Colore.matitaD)
            .padding(.bottom, 6)
            .overlay(alignment: .bottom) { Rectangle().fill(TemaCarta.Colore.filo2D).frame(height: 1) }

            Text("Il Foglio di Prisma")
                .accessibilityAddTraits(.isHeader)
                .font(.system(size: 34, weight: .medium, design: .serif))
                .tracking(-1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 2) {
                        Rectangle().frame(height: 1)
                        Rectangle().frame(height: 1)
                    }
                    .foregroundColor(TemaCarta.Colore.inchiostroD.opacity(0.55))
                }

            Text(p.titolo)
                .font(.system(size: 23, weight: .medium, design: .serif))
                .tracking(-0.4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
                .segnoCarta(.evidenzia, chiave: "prima-pagina.\(p.numero).\(p.edizione.rawValue)")

            HStack(alignment: .top, spacing: 16) {
                colonna("Da chiamare", p.daChiamare.first.map { "\($0.chi): \($0.perche)" }
                        ?? (p.incontri.first.map { "Alle \(Formati.ora.string(from: $0.ora)): \($0.chi)" } ?? "Nessuno oggi."),
                        penna: false)
                colonna("La nota di Vera", p.notaVera ?? notaDaScadenze(p), penna: true)
            }
            .padding(.top, 10)

            HStack(spacing: 14) {
                Button { stato.ascoltaPrimaPagina(p) } label: { Label("Ascolta", systemImage: "speaker.wave.2") }
                Button { ristampaPagina() } label: { Label("Ristampa", systemImage: "arrow.clockwise") }
                Spacer()
                Text("\(p.numeroDelGiorno) \(p.didascaliaNumero)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(TemaCarta.Colore.matitaD)
                    .lineLimit(1)
            }
            .buttonStyle(.plain)
            #if os(iOS)
            .frame(minHeight: 44)
            #endif
            .contentShape(Rectangle())
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(TemaCarta.Colore.inchiostro2D)
            .padding(.top, 12)
        }
        .foregroundColor(TemaCarta.Colore.inchiostroD)
        .padding(EdgeInsets(top: 20, leading: 24, bottom: 18, trailing: 24))
        .frame(maxWidth: 500, alignment: .leading)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
        .opacity(statoFinale || visibile ? 1 : 0)
        .offset(y: statoFinale || visibile ? 0 : 10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("La Prima Pagina di oggi")
    }

    private func colonna(_ titolo: String, _ testo: String, penna: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(titolo.uppercased())
                .font(.system(size: 11, design: .monospaced)).tracking(1.5)
                .foregroundColor(TemaCarta.Colore.matitaD)
            Text(testo)
                .font(penna ? TemaCarta.Penna.testo : .system(size: 12))
                .foregroundColor(penna ? TemaCarta.Colore.pennaD : TemaCarta.Colore.inchiostro2D)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Senza una nota scritta, Vera ricorda la scadenza più vicina (con la data, cifre di Prisma).
    private func notaDaScadenze(_ p: PrimaPagina) -> String {
        guard let s = p.scadenze.first else { return "Niente in scadenza nei prossimi 45 giorni." }
        return "\(s.posizione) di \(s.cliente): scade il \(Formati.dataBreve.string(from: s.data))."
    }

    /// Ricompone la pagina e la fa rientrare.
    private func ristampaPagina() {
        guard !statoFinale else { ristampa += 1; return }
        withAnimation(Tema.Apple.Moto.Curva.easeIn.animazione(0.2)) { visibile = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + Tema.Apple.Moto.tempo(0.2)) {
            ristampa += 1
            withAnimation(Tema.Apple.Moto.Curva.uscita.animazione(0.5)) { visibile = true }
        }
    }
}
