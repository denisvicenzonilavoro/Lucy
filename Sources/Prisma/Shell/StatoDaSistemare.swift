import Foundation

// Migliorie d'uso 31 «Si vede cosa resta da sistemare»: i fatti per `MotoreDaSistemare`, letti dallo stato di Prisma.
// Solo letture dirette (impostazioni, stato di Vera, di «Prisma ovunque» e del tagliando); i dati mancanti per le
// fatture, che scorrono parcelle e posizioni, si tengono con `ricavato` (dipendono solo dai dati dei calcoli).
// La colonna delle Impostazioni e la pagina «Da sistemare» li chiedono una volta per disegno.

extension StatoShell {
    /// Il motivo di Vera prima della prima verifica di Qwen: finché vale, «Vera non è pronta» non conta.
    static let veraNonVerificata = "Ollama non ancora verificato."
}

#if os(macOS)
extension StatoShell {
    /// I fatti di «Da sistemare», così come sono adesso.
    func fattiDaSistemare() -> FattiDaSistemare {
        let imp = dati.impostazioni
        let b = imp.backup
        var f = FattiDaSistemare()
        f.solaLettura = solaLettura
        f.copieNonLeggibili = copieNonLeggibili
        f.backupUltimo = b.ultimo
        if let e = b.ultimoErrore {
            let quando = b.ultimoTentativo.map { "Il \(Formati.dataOra.string(from: $0)): " } ?? ""
            f.backupErrore = quando + e
        }
        f.backupInRitardo = b.inRitardo
        f.backupProtetto = b.cifrato
        f.backupStessoMac = cartellaBackupPredefinita
        f.veraVerificata = disponibilitaLocale.motivo != StatoShell.veraNonVerificata
        f.veraPronta = disponibilitaLocale.pronto
        f.veraMotivo = disponibilitaLocale.motivo
        f.promemoriaAccesi = imp.promemoria.attivi
        f.promemoriaNegati = permessoPromemoria == .negati
        let fatture = ricavato("impostazioni-da-sistemare-fatture") { () -> (servono: Bool, mancanti: Int) in
            let servono = !dati.parcelle.isEmpty || dati.posizioni.contains { $0.canale == .indipendente }
            return (servono, servono ? MotoreFattura.mancantiConsulente(imp.studio.fatturazione).count : 0)
        }
        f.fattureServono = fatture.servono
        f.fattureMancanti = fatture.mancanti
        f.ovunqueAcceso = imp.ovunque.acceso
        f.ovunqueProblema = ovunque.problema.map(Self.testoProblemaOvunque)
        f.ovunqueConflitti = dati.conflittiOvunque.count
        f.ovunqueUltima = imp.ovunque.ultimoControllo ?? imp.ovunque.ultimaIstantanea
        f.mercatoAcceso = imp.mercato.attivo
        f.mercatoErrore = dati.mercato.ultimoErrore != nil
        if esitoTagliandoAttuale, let e = esitoTagliando { f.tagliandoVoci = e.voci.count }
        return f
    }

    /// Cosa resta da sistemare e cosa è a posto.
    func daSistemare() -> EsitoDaSistemare {
        MotoreDaSistemare.calcola(fattiDaSistemare())
    }

    /// La spiegazione di un problema di «Prisma ovunque», senza dettagli tecnici.
    static func testoProblemaOvunque(_ p: ProblemaOvunque) -> String {
        switch p {
        case .passphrase: return "Serve di nuovo la passphrase dello spazio cifrato."
        case .iCloud: return "iCloud Drive non è raggiungibile."
        case .cartella: return "La cartella dello spazio cifrato va scelta di nuovo."
        case .attesa: return "Qualche file è ancora in arrivo da iCloud Drive."
        case .altro(let m): return m
        }
    }
}
#endif
