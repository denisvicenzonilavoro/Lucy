#if os(macOS)
import AppKit
#endif
import SwiftUI

/// Migliorie d'uso 44: il ricordo per «Annulla la registrazione», solo in memoria. Le posizioni toccate com'erano
/// prima (`prima`) e subito dopo (`dopo`, con le nuove): «Annulla» c'è solo se quelle dell'archivio sono ancora uguali.
struct AnnullaValori {
    /// La sessione del pannello in cui si è registrato.
    let sessione: UUID?
    let prima: [Posizione]
    let dopo: [Posizione]
    /// Gli id delle posizioni nuove aggiunte con «È nuova».
    let nuove: [String]
}

/// Il pannello «Aggiorna i valori» in Posizioni (specifica 8): apertura, lettura del file o degli appunti,
/// registrazione dopo un backup e passaggio all'importazione normale. La sessione sta in `aggiornaValori`
/// (StatoShell); lo stato della vista (scelte, esclusioni, caselle della griglia) resta nella vista.
extension StatoShell {
    /// Apre il pannello sulla griglia (o sulla scheda già aperta), nel dossier sul solo cliente attivo.
    func apriAggiornaValori(scheda: AggiornaValori.Scheda = .griglia) {
        // In modo cliente il pannello non si apre: è un lavoro del consulente e mostra numeri di più clienti
        guard !inModoCliente else { return }
        posizioneInDettaglio = nil
        if aggiornaValori != nil {
            aggiornaValori?.scheda = scheda
        } else {
            aggiornaValori = AggiornaValori.Sessione(scheda: scheda, soloCliente: portafoglio ? nil : clienteAttivoId)
        }
        apri(.posizioni)
    }

    /// Dall'importazione: il pannello sull'elenco con le stesse righe (proposta = true).
    func apriAggiornaValori(da i: ImportazionePosizioni) {
        guard !inModoCliente else { return }
        guard let s = AggiornaValori.sessione(tabella: i.righe, file: i.file, dataComune: Date(), proposta: true) else {
            mostraAvviso(TestiAggiornaValori.fileSenzaValori)
            return
        }
        posizioneInDettaglio = nil
        aggiornaValori = s
        apri(.posizioni)
    }

    /// NSOpenPanel con `tipiTabelle` (come importaPosizioniDaFile) → `ImportaClienti.righe(url)` → sessione.
    @MainActor
    func scegliFileValori() {
        #if os(macOS)
        let pannello = NSOpenPanel()
        pannello.allowedContentTypes = Self.tipiTabelle
        pannello.allowsMultipleSelection = false
        pannello.message = TestiAggiornaValori.messaggioApertura
        guard pannello.runModal() == .OK, let url = pannello.url else { return }
        guard let tabella = ImportaClienti.righe(url) else {
            mostraAvviso(TestiAggiornaValori.fileSenzaValori)
            return
        }
        apriElencoValori(tabella: tabella, file: url.lastPathComponent)
        #elseif os(iOS)
        // Su iPhone e iPad il file si sceglie con `.fileImporter` (GuscioiPad), poi `valoriDaFile(_:)` sulla copia
        sceltaFileMobile = .valori
        #endif
    }

    #if os(iOS)
    /// La copia del file scelto con `.fileImporter`: come la seconda metà di `scegliFileValori` sul Mac.
    @MainActor
    func valoriDaFile(_ url: URL) {
        guard let tabella = ImportaClienti.righe(url) else {
            mostraAvviso(TestiAggiornaValori.fileSenzaValori)
            return
        }
        apriElencoValori(tabella: tabella, file: url.lastPathComponent)
    }
    #endif

    /// Appunti (come incollaDaExcel) → `ImportaClienti.righeCSV` → sessione.
    @MainActor
    func incollaValoriDaExcel() {
        guard let testo = Appunti.testo, testo.contains("\n") || testo.contains("\t") else {
            mostraAvviso(TestiAggiornaValori.appuntiVuoti)
            return
        }
        apriElencoValori(tabella: ImportaClienti.righeCSV(testo), file: "appunti")
    }

    /// Una sessione nuova sull'elenco: sostituisce la precedente (e chiude un riepilogo aperto). Migliorie d'uso 44:
    /// sul Mac, come la griglia, l'elenco con un cliente scelto mostra solo le sue righe (con il Portafoglio di tutti
    /// i clienti, tutte).
    private func apriElencoValori(tabella: [[String]], file: String) {
        guard var s = AggiornaValori.sessione(tabella: tabella, file: file, dataComune: Date()) else {
            mostraAvviso(TestiAggiornaValori.fileSenzaValori)
            return
        }
        #if os(macOS)
        s.soloCliente = portafoglio ? nil : clienteAttivoId
        #endif
        posizioneInDettaglio = nil
        annullaValori = nil
        aggiornaValori = s
        apri(.posizioni)
    }

    /// Registra gli esiti scelti, dopo un backup; il riepilogo va nella sessione aperta. `nuove`: le righe non trovate
    /// dette «È nuova» (riga → cliente), che diventano posizioni insieme ai valori (migliorie d'uso 44).
    func registraValoriInBlocco(_ esiti: [AggiornaValori.Esito], esclusi: Set<Int>, nuove: [Int: String] = [:]) {
        guard !solaLettura, AggiornaValori.daRegistrare(esiti, esclusi: esclusi) > 0 || !nuove.isEmpty else { return }
        // Un campo che rinvia la scrittura altrove nell'app va nell'archivio prima del backup
        TestiRinviati.scriviOra()
        dopoUnBackup(nota: "prima dell'aggiornamento dei valori", annullata: "Aggiornamento annullato") { [weak self] conBackup in
            guard let self else { return }
            let r = self.applicaValoriInBlocco(esiti, esclusi: esclusi, nuove: nuove)
            #if os(macOS)
            // Migliorie d'uso 44: l'avviso del template; il riepilogo dice il resto e si può annullare
            _ = r
            _ = conBackup
            self.mostraAvviso(TestiAggiornaValori.avvisoRegistrati)
            #else
            self.mostraAvviso(TestiAggiornaValori.avviso(r, backup: conBackup))
            #endif
        }
    }

    /// La parte senza backup (prove e archivio in memoria). Valori e posizioni nuove entrano con una sola assegnazione
    /// a `dati.posizioni`; prima si tiene in memoria il ricordo per «Annulla la registrazione» (migliorie d'uso 44).
    @discardableResult
    func applicaValoriInBlocco(_ esiti: [AggiornaValori.Esito], esclusi: Set<Int>,
                               nuove: [Int: String] = [:]) -> AggiornaValori.Riepilogo {
        let prima = dati.posizioni
        var tutte = prima
        var r = AggiornaValori.applica(esiti, esclusi: esclusi, a: &tutte)
        var aggiunte: [Posizione] = []
        if !nuove.isEmpty, let s = aggiornaValori {
            let lette = AggiornaValori.posizioniNuove(tabella: s.tabella, righe: nuove, clienti: dati.clienti,
                                                       posizioni: tutte, prodotti: dati.prodotti)
            for p in lette {
                var n = p
                MotoreSeguitoProposte.registraCambio(da: nil, a: &n, adesso: Posizione.oggiArrotondato)
                aggiunte.append(n)
            }
            tutte.append(contentsOf: aggiunte)
        }
        r.nuove = aggiunte.count
        let toccate = Set(r.posizioni)
        annullaValori = AnnullaValori(sessione: aggiornaValori?.id,
                                      prima: prima.filter { toccate.contains($0.id) },
                                      dopo: tutte.filter { toccate.contains($0.id) } + aggiunte,
                                      nuove: aggiunte.map(\.id))
        dati.posizioni = tutte
        aggiornaValori?.riepilogo = r
        return r
    }

    /// «Annulla la registrazione» si può usare: il ricordo è della sessione aperta, il riepilogo è ancora lì e nessuna
    /// delle posizioni toccate è cambiata altrove dopo la registrazione.
    var puoAnnullareValori: Bool {
        guard let a = annullaValori, let s = aggiornaValori, a.sessione == s.id, s.riepilogo != nil else { return false }
        let servono = Set(a.dopo.map(\.id))
        var indice: [String: Posizione] = [:]
        for p in dati.posizioni where servono.contains(p.id) && indice[p.id] == nil { indice[p.id] = p }
        return a.dopo.allSatisfy { indice[$0.id] == $0 }
    }

    /// Rimette le posizioni toccate com'erano (valori, storico e date) e toglie le nuove, con una sola assegnazione.
    /// Il backup fatto prima di registrare resta. Restituisce false se l'annullamento non vale più.
    @discardableResult
    func annullaRegistrazioneValori() -> Bool {
        guard puoAnnullareValori, let a = annullaValori else {
            annullaValori = nil
            return false
        }
        let tolte = Set(a.nuove)
        var tutte = dati.posizioni
        tutte.removeAll { tolte.contains($0.id) }
        var indice: [String: Int] = [:]
        for (i, p) in tutte.enumerated() where indice[p.id] == nil { indice[p.id] = i }
        for p in a.prima {
            if let i = indice[p.id] { tutte[i] = p }
        }
        dati.posizioni = tutte
        annullaValori = nil
        aggiornaValori?.riepilogo = nil
        mostraAvviso(TestiAggiornaValori.avvisoAnnullata)
        return true
    }

    /// Le righe del file (tutte, o solo quelle non trovate) nell'importazione normale (modulo di Posizioni).
    func importaComeNuove(soloRighe: Set<Int>? = nil) {
        guard let s = aggiornaValori, let testa = s.tabella.first else { return }
        // L'id di una riga è il suo posto nella tabella, sotto l'intestazione
        let scelte = s.tabella.indices.dropFirst().filter { soloRighe?.contains($0) ?? true }.map { s.tabella[$0] }
        let righe = [testa] + scelte
        let letto = ImportaPosizioni.daRighe(righe, clienti: clienti, posizioni: posizioni, prodotti: dati.prodotti)
        guard !letto.posizioni.isEmpty else {
            mostraAvviso(TestiAggiornaValori.nessunaPosizione)
            return
        }
        importazionePosizioni = ImportazionePosizioni(file: s.file, colonne: letto.colonne, posizioni: letto.posizioni, righe: righe)
    }
}
