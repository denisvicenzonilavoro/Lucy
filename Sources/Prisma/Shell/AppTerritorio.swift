import SwiftUI

// Territorio · «Il tuo territorio» («Luce» giro 11, §5.1.1): una card raggio 22 che riempie l'area con la mappa e, sopra
// a sinistra, il pannello opaco largo 340 a 16 dai bordi. La mappa non rimonta al cambio di vista (niente lampo); il
// pannello sì (0,13 s). Nell'iPad stretto il pannello passa sotto la mappa. La tabella dei comuni si carica all'apertura e
// si libera alla chiusura (Mac da 8 GB, §5.4). Nessuna richiesta di rete (decisione 20), con un'unica eccezione decisa
// dall'utente il 25 novembre 2026: con «Usa Apple Mappe per il giro» acceso il giro usa Apple Mappe (GiroMappeApple.swift),
// che riceve solo le coordinate delle tappe.

struct AppTerritorio: View {
    @Environment(StatoShell.self) var stato
    @Environment(\.prismaCalmo) private var calmo
    @Environment(\.modoIstantanea) private var istantanea

    private typealias P = Tema.Apple.Territorio.Pannello

    var body: some View {
        let _ = ContaCorpi.segna()
        let t = stato.territorio
        let vista = stato.vistaTerritorio
        let oggi = stato.territorioOggi()
        let giro: GiroGiorno? = vista == .giro ? stato.giroTerritorio(stato.giornoGiroTerritorio()) : nil
        let crescita: CrescitaTerritorio? = vista == .crescita ? stato.crescitaTerritorio() : nil
        let anno: Int? = crescita.flatMap { c in t.annoCrescita ?? c.anni.last?.anno }
        GeometryReader { g in
            let stretto = g.size.width < P.larghezza + 2 * P.margine + P.mappaMinima
            if stretto {
                ScrollView {
                    VStack(spacing: P.margine) {
                        mappa(oggi, vista, anno, giro, coperto: 0)
                            .frame(height: P.altezzaMappaStretta)
                            .clipShape(RoundedRectangle(cornerRadius: P.raggio, style: .continuous))
                        pannello(vista, oggi: oggi, crescita: crescita, giro: giro)
                    }
                }
            } else {
                ZStack(alignment: .topLeading) {
                    mappa(oggi, vista, anno, giro, coperto: P.larghezza + 2 * P.margine)
                    pannello(vista, oggi: oggi, crescita: crescita, giro: giro)
                        .frame(width: P.larghezza)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(P.margine)
                }
                .clipShape(RoundedRectangle(cornerRadius: P.raggio, style: .continuous))
            }
        }
        .onAppear { stato.apriTabellaTerritorio() }
        .onDisappear {
            stato.territorio.chiudi()
            // Il percorso di Apple Mappe vive solo in memoria: si libera con il Territorio
            PercorsiApple.condiviso.svuota()
        }
        .onChange(of: vista) { _ in
            let t = stato.territorio
            t.fermaCrescita()
            t.lucePuntata = nil
            t.luceScelta = nil
            t.zoom = 1
            t.spostamento = .zero
        }
        .sheet(isPresented: Bindable(t).elencoSenzaLuogo) {
            ElencoSenzaLuogo(senzaLuogo: oggi.senzaLuogo)
                .environment(stato)
        }
        #if os(macOS)
        .onExitCommand { stato.territorio.chiudiUno() }
        // Migliorie d'uso 32: il Territorio segue il cliente della barra; un altro cliente spegne filtri e scheda
        .onChange(of: stato.clienteAttivoId) { _ in
            let t = stato.territorio
            if t.filtroZona != nil { t.filtroZona = nil }
            if t.soloDaFare { t.soloDaFare = false }
            if t.luceScelta != nil { t.luceScelta = nil }
        }
        #endif
    }

    /// La mappa: nel giro, con «Usa Apple Mappe per il giro» acceso (decisione dell'utente del 25 novembre 2026), la
    /// mappa vera di Apple con il percorso in auto (Shell/GiroMappeApple.swift, l'unico file che parla con Apple, solo con
    /// le coordinate delle tappe); altrimenti, senza rete, se Apple non risponde e nelle istantanee, la mappa disegnata
    /// di sempre con le stime in linea d'aria.
    @ViewBuilder private func mappa(_ oggi: TerritorioOggi, _ vista: VistaTerritorio, _ anno: Int?, _ giro: GiroGiorno?,
                                    coperto: CGFloat) -> some View {
        #if canImport(MapKit)
        if let giro, Self.mappeApple(giro, stato: stato, istantanea: istantanea) {
            MappaGiroApple(giro: giro, coperto: coperto)
        } else {
            MappaTerritorio(contenuto: contenuto(oggi, vista, anno, giro, coperto: coperto))
        }
        #else
        MappaTerritorio(contenuto: contenuto(oggi, vista, anno, giro, coperto: coperto))
        #endif
    }

    /// Vero quando il giro si mostra con Apple Mappe: interruttore acceso, giro con visite, fuori dalle istantanee e
    /// percorso non (ancora) dichiarato «non disponibile».
    static func mappeApple(_ giro: GiroGiorno, stato: StatoShell, istantanea: Bool) -> Bool {
        guard stato.dati.impostazioni.territorio.usaMappeApple, !istantanea, !giro.vuoto, giro.tappe.count >= 2 else { return false }
        return PercorsiApple.condiviso.esito(giro.puntiPercorso) != .nonDisponibile
    }

    /// Ciò che la mappa disegna: le luci di oggi, l'anno della crescita, il giro, i confini caricati e i nomi da scrivere
    /// (preferiti e cliente attivo, al più 8).
    private func contenuto(_ oggi: TerritorioOggi, _ vista: VistaTerritorio, _ anno: Int?, _ giro: GiroGiorno?,
                           coperto: CGFloat) -> ContenutoMappa {
        let attivo = stato.clienteAttivoId
        let conNome = Set(oggi.luci.filter { $0.cliente.preferito || $0.id == attivo }.prefix(Tema.Apple.Territorio.Luce.nomiMassimi).map(\.id))
        var c = ContenutoMappa(luci: oggi.luci, vista: vista, annoCrescita: anno, giro: giro, confini: stato.territorio.confini,
                               conNome: conNome, coperto: coperto)
        #if os(macOS)
        // Migliorie d'uso 32: nella vista Oggi, con un cliente scelto che è sulla mappa, lui e i suoi vicini
        if vista == .oggi, !stato.tuttiIClienti, oggi.luci.contains(where: { $0.id == attivo }) {
            c.clienteScelto = attivo
            c.vicini = stato.viciniTerritorio(attivo, luci: oggi.luci)
        }
        #endif
        return c
    }

    /// Il pannello della vista: rimonta (0,13 s) al cambio di vista.
    private func pannello(_ vista: VistaTerritorio, oggi: TerritorioOggi, crescita: CrescitaTerritorio?, giro: GiroGiorno?) -> some View {
        Group {
            switch vista {
            case .oggi:
                PannelloOggi(oggi: oggi, diProva: stato.territorio.tabella?.diProva ?? false)
            case .crescita:
                PannelloCrescita(crescita: crescita ?? .vuota)
            case .giro:
                if let giro {
                    PannelloGiro(giro: giro, partenza: stato.partenzaTerritorio())
                }
            }
        }
        .id(vista)
        .transition(.opacity)
        .animation(Tema.Apple.Moto.animazione(.linear(duration: Tema.Apple.Territorio.Moto.rimonta), calmo: calmo, istantanea: istantanea),
                   value: vista)
        .padding(P.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: P.raggio, style: .continuous).fill(P.fondo))
    }
}
