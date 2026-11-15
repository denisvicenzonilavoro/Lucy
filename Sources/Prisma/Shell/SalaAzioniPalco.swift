#if os(macOS)
import SwiftUI

// Migliorie d'uso 59 «Ogni esperienza ha il suo copione» (Design/uso/gruppo-10.md §59, template righe 4770-4801): nella
// testata del palco i pulsanti del consulente (`#saMie`: qui «Cosa dire»; la miglioria 60 aggiungerà «Segna come fatta»)
// e il riquadro del copione, ancorato in alto a destra del palco, sotto la testata. Non è un popover: le istantanee lo
// disegnano e resta dentro la finestra. Sta in `PalcoSala`, mai in `ContenutoPalco`: così non entra nella presentazione
// né nelle immagini mandate all'iPad. Solo sul Mac. Valori in Tema.Apple.SalaEsperienze.Copione.

extension StatoShell {
    /// I pulsanti del consulente sul palco (e il copione) si vedono solo a lui: fuori dalla modalità cliente e dalla vista
    /// pulita di «Mostra al cliente». La miglioria 58 li mostrerà anche nella vista del cliente quando il cliente guarda
    /// l'iPad sul tavolo.
    var consulenteVede: Bool { !inModoCliente && !inVistaCliente }
}

/// I pulsanti del consulente nella testata del palco. Osserva da solo `StatoSala.copioneAperto`: aprire o chiudere il
/// copione non ridisegna la testata.
struct AzioniPalco: View {
    let sala: StatoSala

    private typealias K = Tema.Apple.SalaEsperienze.Copione

    var body: some View {
        Button {
            sala.copioneAperto.toggle()
        } label: {
            HStack(spacing: K.spazioPulsante) {
                Image(systemName: "info.circle")
                    .carattereApple(K.glifoPulsante)
                Text(TestiCopione.pulsante)
            }
        }
        .buttonStyle(.apple)
        .help(TestiCopione.aiutoPulsante)
        .accessibilityAddTraits(sala.copioneAperto ? .isSelected : [])
    }
}

/// Il riquadro «Cosa dire» sopra il palco: occhiello con momento e durata, la frase d'apertura, tre passi numerati, la
/// domanda di chiusura e, sopra un filetto, «Lo vedi solo tu». Entra scendendo di 8 e crescendo da 0,98 con una molla
/// (con «Riduci movimento» solo la dissolvenza; nelle istantanee già fermo).
struct RiquadroCopione: View {
    let sala: StatoSala
    let esperienza: EsperienzaSala

    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    private typealias K = Tema.Apple.SalaEsperienze.Copione
    private typealias M = Tema.Apple.Moto.SalaEsperienze

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if sala.copioneAperto {
                scheda
                    .entrataScheda(M.copione, scala: M.scalaCopione, ancora: .topTrailing, y: M.discesaCopione)
                    .transition(.opacity)
            }
        }
        .animation(Tema.Apple.Moto.animazione(M.copione, calmo: calmo, istantanea: istantanea), value: sala.copioneAperto)
    }

    private var scheda: some View {
        let copione = esperienza.copione
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: K.spazioPasso) {
                Text(TestiCopione.titolo(esperienza))
                    .carattereApple(K.occhiello)
                    .foregroundColor(K.coloreOcchiello)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Button { sala.copioneAperto = false } label: {
                    Image(systemName: "xmark")
                        .carattereApple(K.glifoChiudi)
                }
                .buttonStyle(.appleSobrio)
                .help(TestiCopione.aiutoChiudi)
                .accessibilityLabel(Text(TestiCopione.aiutoChiudi))
            }
            etichetta(TestiCopione.apriCosi)
                .padding(.top, K.sottoOcchiello)
            frase(copione.apertura)
            etichetta(TestiCopione.mentre)
                .padding(.top, K.spazioSezione)
            ForEach(Array(copione.passi.enumerated()), id: \.offset) { i, passo in
                HStack(alignment: .top, spacing: K.spazioPasso) {
                    Text("\(i + 1)")
                        .carattereApple(K.cifra)
                        .foregroundColor(K.coloreCifra)
                        .frame(width: K.numerino, height: K.numerino)
                        .background(Circle().fill(K.fondoNumerino))
                    Text(passo)
                        .carattereApple(K.passo)
                        .foregroundColor(K.colorePasso)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minHeight: K.numerino, alignment: .leading)
                }
                .padding(.vertical, K.paddingPasso)
            }
            etichetta(TestiCopione.chiudi)
                .padding(.top, K.spazioSezione)
            frase(copione.domanda)
            Rectangle()
                .fill(K.filetto)
                .frame(height: K.spessoreFiletto)
                .padding(.top, K.spazioSezione)
            etichetta(TestiCopione.soloTu)
                .padding(.top, K.sottoFiletto)
        }
        .multilineTextAlignment(.leading)
        .padding(K.padding)
        .frame(width: K.larghezza, alignment: .leading)
        .superficieApple(K.superficie, raggio: K.raggio)
        .accessibilityElement(children: .contain)
    }

    private func etichetta(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(K.etichetta)
            .foregroundColor(K.coloreEtichetta)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func frase(_ testo: String) -> some View {
        Text(testo)
            .carattereApple(K.frase)
            .foregroundColor(K.coloreFrase)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, K.sottoEtichetta)
    }
}
#endif
