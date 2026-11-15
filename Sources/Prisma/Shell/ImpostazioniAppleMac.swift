import SwiftUI

// Impostazioni nel tema Apple, sul Mac e sull'iPad (Design/template-apple-specifica.md §4.6, riferimenti PIE i01-i09):
//
//   ┌─ Panoramica ─────────┐  Aspetto
//   │ ▌Aspetto    (scelta) │  ┌──────────────────────────────────────────────────────────────┐
//   │  Archivio e backup   │  │ Aspetto                          [Chiaro | Scuro | Automatico] │
//   │  Vera                 │  │ Chiaro, scuro o automatico come il Mac.                        │
//   │  Profilo             │  └──────────────────────────────────────────────────────────────┘
//   │ IL LAVORO            │  ┌──────────────────────────────────────────────────────────────┐
//   │  Agenda e lavoro …   │  │ Riduci movimento                                        (●  ) │
//   │ PER LE PROVE         │  └──────────────────────────────────────────────────────────────┘
//   │  Strumenti           │
//   │ ● Archivio locale    │
//   └──────────────────────┘
//
// - Barra laterale 260 (`.side`): le sezioni del template (Aspetto, Archivio e backup, Vera, Profilo) dopo la
//   Panoramica, poi le altre pagine di Prisma sotto «Il lavoro» e Strumenti sotto «Per le prove». Voci `.rub`.
//   Sul Mac (migliorie d'uso 30) in cima il campo «Cerca nelle impostazioni» e i gruppi hanno tutti un nome:
//   la Panoramica da sola, poi «Prisma», «Il lavoro» e «Aiuto» (IndiceImpostazioni.gruppi); con un testo nel campo la
//   pagina a destra mostra i risultati. L'iPad resta com'era.
// - Pagina: titolo `.h2` (4 sopra, 14 sotto) e le righe come card senza ombra (`.impostazioniApple()`); cambiando
//   sezione la cascata riparte con base 0. Aspetto, Archivio e backup, Vera e Profilo come nel template; le altre
//   pagine sono quelle di sempre, nelle card del tema.
// - «Riduci movimento» e istantanee: tutto è subito fermo nello stato finale.
// Valori in DesignSystem/Apple/Tema.Apple+Impostazioni.swift.

extension AppImpostazioni {
    /// Le sezioni della barra laterale, dall'alto in basso (tutte le pagine di sempre).
    /// L'ordine del template di Orizzonte (§13.1.2): Aspetto · iPhone e iPad · Archivio e backup · Vera · Profilo.
    static let sezioniPrincipali: [SchedaImpostazioni] = [.panoramica, .aspetto, .ovunque, .archivio, .vera, .profilo]
    static let sezioniLavoro: [SchedaImpostazioni] = [.studio, .mercato, .portafogliModello, .pratiche, .sala, .moduli, .territorio, .lavoro, .promemoria, .conformita, .proposte, .rendimenti, .scorciatoie]
    static let sezioniProve: [SchedaImpostazioni] = [.strumenti]

    var corpoApple: some View {
        let d = Tema.Apple.Impostazioni.Disposizione.self
        return HStack(alignment: .top, spacing: d.spazioLaterale) {
            barraLateraleApple
                .frame(width: d.larghezzaLaterale)
                .frame(maxHeight: .infinity, alignment: .top)
            paginaApple
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .impostazioniApple()
        #if os(macOS)
        .background {
            // Migliorie d'uso 30: ⌘F porta nel campo della ricerca, solo con Impostazioni in primo piano (⌘K resta
            // «Cerca ovunque»)
            if stato.appAttiva == .impostazioni {
                Button("") { fuocoCercaImpostazioni = true }
                    .keyboardShortcut("f", modifiers: .command)
                    .opacity(0)
                    .frame(width: 0, height: 0)
                    .accessibilityHidden(true)
            }
        }
        // La ricerca resta in memoria finché Impostazioni è aperta
        .onDisappear { stato.cercaImpostazioni = "" }
        #endif
    }

    /// Migliorie d'uso 30: c'è un testo nel campo della ricerca (sul Mac): la pagina mostra i risultati e nessuna voce
    /// della colonna è evidenziata.
    private var inRicercaImpostazioni: Bool {
        #if os(macOS)
        return !stato.cercaImpostazioni.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        #else
        return false
        #endif
    }

    // MARK: Barra laterale

    private var barraLateraleApple: some View {
        let l = Tema.Apple.Impostazioni.Laterale.self
        let forma = RoundedRectangle(cornerRadius: l.raggio, style: .continuous)
        // Migliorie d'uso 31: cosa resta da sistemare, letto una volta per disegno (solo letture)
        let esito = Self.esitoColonna(stato)
        return VStack(alignment: .leading, spacing: 0) {
            #if os(macOS)
            // Migliorie d'uso 30: il campo della ricerca in cima, fuori dallo scorrimento
            CampoCercaImpostazioni(testo: Bindable(stato).cercaImpostazioni, fuoco: $fuocoCercaImpostazioni,
                                   escVuoto: { stato.chiudi(.impostazioni) })
                .padding(.top, Tema.Apple.Impostazioni.Laterale.Cerca.sopra)
                .padding(.bottom, Tema.Apple.Impostazioni.Laterale.Cerca.sotto)
            #endif
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    #if os(macOS)
                    // Migliorie d'uso 30: la Panoramica da sola, poi «Prisma», «Il lavoro» e «Aiuto»
                    ForEach(Array(IndiceImpostazioni.gruppi.enumerated()), id: \.offset) { i, g in
                        gruppoLateraleApple(g.titolo, g.pagine, primo: Self.primoDelGruppo(i), esito: esito)
                    }
                    #else
                    gruppoLateraleApple(nil, Self.sezioniPrincipali, primo: 0, esito: esito)
                    gruppoLateraleApple("Il lavoro", Self.sezioniLavoro, primo: Self.sezioniPrincipali.count, esito: esito)
                    gruppoLateraleApple("Per le prove", Self.sezioniProve,
                                        primo: Self.sezioniPrincipali.count + Self.sezioniLavoro.count + 1, esito: esito)
                    #endif
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            piedeLateraleApple
                .padding(.top, l.sopraPiede)
        }
        .padding(l.padding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .clipShape(forma)
        .superficieApple(l.superficie, raggio: l.raggio)
    }

    private func gruppoLateraleApple(_ titolo: String?, _ pagine: [SchedaImpostazioni], primo: Int,
                                     esito: EsitoDaSistemare?) -> some View {
        let l = Tema.Apple.Impostazioni.Laterale.self
        return VStack(alignment: .leading, spacing: l.fraVoci) {
            if let titolo {
                Text(titolo)
                    .carattereApple(l.etichetta)
                    .foregroundColor(l.coloreEtichetta)
                    .lineLimit(1)
                    .padding(.leading, l.rientroEtichetta)
                    .padding(.top, l.sopraGruppo)
                    .padding(.bottom, max(0, l.sottoEtichetta - l.fraVoci))
                    .entrataCascata(primo)
            }
            ForEach(Array(pagine.enumerated()), id: \.element) { i, p in
                // Il pallino di «Prisma ovunque» legge `stato.ovunque.problema`: StatoOvunque è @Observable, quindi
                // un errore della sincronizzazione in background lo accende da solo
                voceLateraleApple(p, esito: esito)
                .entrataCascata(primo + i + (titolo == nil ? 0 : 1), sfocatura: false)
            }
        }
    }

    #if os(macOS)
    /// L'indice della cascata della prima riga di un gruppo della colonna (le voci e gli occhielli prima di lui).
    static func primoDelGruppo(_ indice: Int) -> Int {
        IndiceImpostazioni.gruppi.prefix(indice).reduce(0) { $0 + $1.pagine.count + ($1.titolo == nil ? 0 : 1) }
    }
    #endif

    private func voceLateraleApple(_ p: SchedaImpostazioni, esito: EsitoDaSistemare?) -> some View {
        VoceLateraleImpostazioniApple(titolo: p.titolo, attiva: stato.schedaImpostazioni == p && !inRicercaImpostazioni,
                                      segno: segnoVoceLaterale(p, esito: esito)) {
            #if os(macOS)
            stato.cercaImpostazioni = ""
            #endif
            stato.schedaImpostazioni = p
        }
    }

    /// Migliorie d'uso 31: sul Mac l'esito di «Da sistemare» per la colonna; sull'iPad nessuno (restano i pallini).
    private static func esitoColonna(_ stato: StatoShell) -> EsitoDaSistemare? {
        #if os(macOS)
        return stato.daSistemare()
        #else
        return nil
        #endif
    }

    /// Il segno accanto alla sezione. Sul Mac (migliorie d'uso 31): accanto a «Da sistemare» il numero, o la spunta
    /// verde a zero; accanto alle altre l'etichetta della cosa più grave da sistemare in quella pagina («mai fatto»,
    /// «spenti», «da completare»…). Sull'iPad il pallino di sempre.
    private func segnoVoceLaterale(_ p: SchedaImpostazioni, esito: EsitoDaSistemare?) -> SegnoVoceImpostazioni? {
        guard let esito else { return statoVoceLaterale(p).map { SegnoVoceImpostazioni.pallino($0) } }
        // Migliorie d'uso 37: accanto a «Dimostrazione», accesa, la scritta piccola «accesa»
        if p == .strumenti && stato.inDimostrazione {
            return .etichetta(TestiDimostrazione.etichettaColonna, errore: false)
        }
        if p == .panoramica {
            return esito.conteggio == 0 ? .spunta : .etichetta("\(esito.conteggio)", errore: false)
        }
        guard let v = esito.etichetta(per: p) else { return nil }
        return .etichetta(v.etichettaColonna, errore: v.tono == .errore)
    }

    /// Un pallino accanto alla sezione solo quando c'è da guardare (backup, archivio, Vera non pronta). Sull'iPad; sul
    /// Mac le stesse condizioni sono voci di `MotoreDaSistemare`.
    private func statoVoceLaterale(_ p: SchedaImpostazioni) -> Pillola.Tono? {
        switch p {
        case .archivio:
            if stato.solaLettura || stato.dati.impostazioni.backup.ultimoErrore != nil { return .errore }
            if stato.copieNonLeggibili > 0 || stato.dati.impostazioni.backup.inRitardo { return .attenzione }
            return nil
        case .vera:
            return stato.disponibilitaLocale.pronto ? nil : .attenzione
        case .ovunque:
            guard stato.dati.impostazioni.ovunque.acceso else { return nil }
            if stato.ovunque.problema != nil { return .errore }
            return stato.dati.conflittiOvunque.isEmpty ? nil : .attenzione
        case .mercato:
            // L'ultimo scaricamento non riuscito del tutto
            return stato.dati.impostazioni.mercato.attivo && stato.dati.mercato.ultimoErrore != nil ? .attenzione : nil
        default:
            return nil
        }
    }

    /// In fondo: l'archivio locale (con il pallino verde) e la versione di Prisma.
    private var piedeLateraleApple: some View {
        let l = Tema.Apple.Impostazioni.Laterale.self
        return VStack(alignment: .leading, spacing: l.spazioPiede) {
            HStack(spacing: Tema.Apple.Impostazioni.Stato.spazio) {
                Circle()
                    .fill(l.colorePallinoPiede)
                    .frame(width: l.pallinoPiede, height: l.pallinoPiede)
                Text(Self.notaArchivio)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Text("Prisma \(Self.versioneApp)")
                .lineLimit(1)
        }
        .carattereApple(l.piede)
        .foregroundColor(l.colorePiede)
        .padding(.horizontal, l.rientroEtichetta)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Pagina

    /// La pagina a destra: i risultati della ricerca quando il campo non è vuoto (solo Mac), altrimenti la sezione.
    @ViewBuilder private var paginaApple: some View {
        #if os(macOS)
        if inRicercaImpostazioni {
            paginaRisultatiApple
        } else {
            paginaSezioneApple
        }
        #else
        paginaSezioneApple
        #endif
    }

    #if os(macOS)
    /// Migliorie d'uso 30: «3 risultati per «backup»» e una riga per voce (titolo e spiegazione come nella pagina), con
    /// a destra il nome della pagina e «Apri», che svuota la ricerca e porta alla riga. Nessun risultato: un invito a
    /// provare un'altra parola.
    private var paginaRisultatiApple: some View {
        let testo = stato.cercaImpostazioni.trimmingCharacters(in: .whitespacesAndNewlines)
        let trovate = IndiceImpostazioni.cerca(testo)
        let p = Tema.Apple.Impostazioni.Pagina.self
        let spazio = Tema.Apple.Impostazioni.Risultati.spazio
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                TitoloPaginaImpostazioni(testo: TestiImpostazioni.risultati(trovate.count, testo))
                if trovate.isEmpty {
                    NotaImpostazioni(TestiImpostazioni.provaAltraParola)
                } else {
                    GruppoImpostazioni {
                        ForEach(Array(trovate.enumerated()), id: \.offset) { i, v in
                            RigaImpostazione(titolo: v.titolo, sottotitolo: v.spiegazione, ultima: i == trovate.count - 1) {
                                HStack(spacing: spazio) {
                                    EtichettaPaginaImpostazioni(testo: v.pagina.titolo)
                                    ValoreRiga(testo: TestiImpostazioni.apri) { apriVoceIndice(v) }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: p.larghezzaMassima, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(p.margine)
        }
        .scrollIndicators(.hidden)
    }

    /// «Apri» su un risultato: svuota la ricerca, apre la pagina e scorre alla riga (`scorri`, con l'ancora).
    private func apriVoceIndice(_ v: VoceIndiceImpostazioni) {
        stato.cercaImpostazioni = ""
        fuocoCercaImpostazioni = false
        stato.ancoraImpostazioni = v.ancora
        stato.schedaImpostazioni = v.pagina
    }
    #endif

    /// La sezione scelta: titolo `.h2` e righe, in una colonna leggibile (i rendimenti prendono tutta la larghezza).
    /// Cambiando sezione si riparte dall'alto e la cascata riparte (la pagina nasce di nuovo con il suo `.id`).
    private var paginaSezioneApple: some View {
        let scelta = stato.schedaImpostazioni
        let p = Tema.Apple.Impostazioni.Pagina.self
        return ScrollViewReader { lettore in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !Self.titoloProprio(scelta) {
                        TitoloPaginaImpostazioni(testo: scelta.titolo)
                            .entrataCascata(0, base: Tema.Apple.Moto.Cascata.baseDentroApp)
                    }
                    contenutoApple(scelta)
                }
                .frame(maxWidth: scelta == .rendimenti || scelta == .ovunque ? .infinity : p.larghezzaMassima, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(p.margine)
            }
            .scrollIndicators(.hidden)
            .id(scelta)
            .onAppear { scorri(lettore) }
            .onChange(of: stato.ancoraImpostazioni) { _ in scorri(lettore) }
        }
    }

    /// Migliorie d'uso 31: «Da sistemare» (sul Mac) scrive da sé il titolo, che cambia in «Tutto a posto», e la frase.
    static func titoloProprio(_ pagina: SchedaImpostazioni) -> Bool {
        #if os(macOS)
        return pagina == .panoramica
        #else
        return false
        #endif
    }

    /// Le quattro sezioni del template hanno le righe a cascata una per una; le altre entrano tutte insieme.
    @ViewBuilder private func contenutoApple(_ pagina: SchedaImpostazioni) -> some View {
        switch pagina {
        case .aspetto, .archivio, .vera, .ovunque:
            contenuto(pagina)
        case .profilo:
            profiloApple
        case .panoramica where Self.titoloProprio(pagina):
            // Migliorie d'uso 31: «Da sistemare» ha la sua cascata, riga per riga
            contenuto(pagina)
        default:
            VStack(alignment: .leading, spacing: M.spazioGruppi) {
                contenuto(pagina)
            }
            .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp, sfocatura: false)
        }
    }

    // MARK: Profilo

    /// Come nel template (PIE i08): la card con l'avatar 64 «DV», il nome e «Consulente finanziario», poi il nome
    /// da modificare e le due righe dei canali con le loro etichette.
    private var profiloApple: some View {
        let f = Tema.Apple.Impostazioni.Profilo.self
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: f.spazio) {
                AvatarProfiloApple(iniziali: stato.inizialiUtente)
                VStack(alignment: .leading, spacing: Tema.Apple.Impostazioni.Riga.sottoTitolo) {
                    Text(stato.nomeUtente)
                        .carattereApple(f.nome)
                        .foregroundColor(f.coloreNome)
                        .lineLimit(1)
                    Text("Consulente finanziario")
                        .carattereApple(f.ruolo)
                        .foregroundColor(f.coloreRuolo)
                }
                Spacer(minLength: 0)
            }
            .padding(f.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .superficieApple(f.superficie, raggio: f.raggio)
            .padding(.bottom, f.sottoCard)
            .entrataCascata(1, base: Tema.Apple.Moto.Cascata.baseDentroApp, sfocatura: false)
            GruppoImpostazioni {
                RigaImpostazione(titolo: "Il tuo nome", sottotitolo: "Come ti accoglie la scrivania.") {
                    ValoreRiga(testo: stato.nomeUtente) { modificaNome = true }
                        .popover(isPresented: $modificaNome, arrowEdge: .leading) { campoNomeApple }
                }
                .cascataImpostazioni(2)
                #if !os(macOS)
                RigaImpostazione(titolo: "Canale Alleanza", sottotitolo: "Etichetta in vetro blu con il logo Alleanza. Solo prodotti Alleanza.") {
                    EtichettaCanaleApple(canale: .alleanza)
                }
                .cascataImpostazioni(3)
                RigaImpostazione(titolo: "Canale indipendente",
                                 sottotitolo: "«Denis Vicenzoni · Consulenza finanziaria». Investimenti, risparmio, previdenza, protezione.") {
                    EtichettaCanaleApple(canale: .indipendente)
                }
                .cascataImpostazioni(4)
                #endif
            }
            #if os(macOS)
            canaliProfiloMac
            #else
            NotaImpostazioni("Ogni posizione e ogni proposta porta l'etichetta del suo canale.")
                .padding(.top, Tema.Apple.Impostazioni.Riga.fraRighe)
                .cascataImpostazioni(5)
            #endif
        }
    }

    #if os(macOS)
    /// Migliorie d'uso 38, solo sul Mac: «I tuoi canali» con i due campi del nome (l'etichetta accanto cambia mentre si
    /// scrive, l'archivio a fine scrittura) e «Il primo avvio» con «Rivedi», che riapre le tre domande dalla prima.
    private var canaliProfiloMac: some View {
        let c = Tema.Apple.Impostazioni.ProfiloCanali.self
        let g = Tema.Apple.Impostazioni.Gruppo.self
        let nomi = stato.dati.impostazioni.nomiCanali ?? .base
        return VStack(alignment: .leading, spacing: 0) {
            Text(TestiPrimoAvvio.canali)
                .carattereApple(g.etichetta)
                .foregroundColor(g.coloreEtichetta)
                .padding(.leading, c.rientro)
                .padding(.top, c.sopraOcchiello)
                .padding(.bottom, c.sottoOcchiello)
                .cascataImpostazioni(3)
            Text(TestiPrimoAvvio.profiloCanaliNota)
                .carattereApple(c.nota)
                .foregroundColor(c.coloreNota)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, c.rientro)
                .padding(.bottom, c.sottoNota)
                .cascataImpostazioni(3)
            GruppoImpostazioni {
                RigaImpostazione(titolo: TestiPrimoAvvio.primoCanale, sottotitolo: TestiPrimoAvvio.primoCanaleSotto) {
                    CampoNomeCanale(canale: .alleanza, nome: nomi.primo) { stato.impostaNomeCanale(.alleanza, $0) }
                }
                .cascataImpostazioni(4)
                RigaImpostazione(titolo: TestiPrimoAvvio.secondoCanale, sottotitolo: TestiPrimoAvvio.secondoCanaleSotto) {
                    CampoNomeCanale(canale: .indipendente, nome: nomi.secondo) { stato.impostaNomeCanale(.indipendente, $0) }
                }
                .cascataImpostazioni(5)
            }
            .id("imp-profilo-canali")
            Text(TestiPrimoAvvio.gruppoAvvio)
                .carattereApple(g.etichetta)
                .foregroundColor(g.coloreEtichetta)
                .padding(.leading, c.rientro)
                .padding(.top, c.sopraOcchiello)
                .padding(.bottom, c.sottoOcchielloAvvio)
                .cascataImpostazioni(6)
            GruppoImpostazioni {
                RigaImpostazione(titolo: TestiPrimoAvvio.rigaAvvio, sottotitolo: TestiPrimoAvvio.rigaAvvioSotto) {
                    ValoreRiga(testo: TestiPrimoAvvio.rivedi) { stato.apriPrimoAvvio() }
                }
                .cascataImpostazioni(7)
            }
            .id("imp-profilo-avvio")
        }
    }
    #endif

    /// Il nome nel popover: entra nei documenti e passa all'archivio poco dopo l'ultimo tasto.
    private var campoNomeApple: some View {
        let f = Tema.Apple.Impostazioni.Profilo.self
        return VStack(alignment: .leading, spacing: Tema.Apple.Impostazioni.Riga.spazioControlliAffiancati) {
            Text("Il tuo nome")
                .carattereApple(Tema.Apple.Impostazioni.Riga.titolo)
                .foregroundColor(Tema.Apple.Impostazioni.Riga.coloreTitolo)
            TestoRinviato(testo: Bindable(stato.dati).impostazioni.nomeUtente, salvaOra: { stato.salvaOra() }) { bozza in
                TextField("Nome", text: bozza)
                    .campoTesto()
                    .frame(width: f.larghezzaCampo)
                    .onSubmit { modificaNome = false }
            }
        }
        .padding(f.paddingPopover)
    }
}

/// L'avatar del consulente nel profilo (`.av` 64): «DV» 22 semibold bianco sul gradiente dall'alto in basso.
private struct AvatarProfiloApple: View {
    let iniziali: String

    var body: some View {
        let f = Tema.Apple.Impostazioni.Profilo.self
        Text(iniziali)
            .carattereApple(f.iniziali)
            .foregroundColor(f.coloreIniziali)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(width: f.avatar, height: f.avatar)
            .background {
                Circle()
                    .fill(LinearGradient(colors: [f.avatarAlto, f.avatarBasso], startPoint: .top, endPoint: .bottom))
            }
            .accessibilityHidden(true)
    }
}
