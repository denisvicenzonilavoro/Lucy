import SwiftUI

// Migliorie d'uso 22 (Design/uso/gruppo-03.md): «Per il cliente» e «Per te» al posto di «Prospetto» e «Report».
// La versione si sceglie sopra la pagina (ProspettiApple.swift), le pagine per il consulente portano il timbro
// «SOLO PER TE» (un posto solo: `conTimbroPerTe`, chiamato in fondo a `documentoProspetto`), «Mostra al cliente» e il
// tavolo con l'iPad usano sempre la versione per il cliente, «Salva PDF» dice quale versione ha salvato.
// Solo sul Mac: iPhone e iPad restano come sono finché il loro giro non arriva.

/// I testi delle due versioni.
enum TestiVersioneProspetto {
    static let perIlCliente = "Per il cliente"
    static let perTe = "Per te"
    static let soloPerIlCliente = "Solo per il cliente"
    static let soloPerTe = "Solo per te"
    static let sottotitoloCliente = "Report · da mostrare e da consegnare"
    static let sottotitoloTe = "Prospetto di dettaglio · solo per te"
    static let timbro = "SOLO PER TE"
    static let notaUltimaPagina = "Prospetto per il consulente: non va consegnato."
    static let avvisoMostra = "Al cliente si mostra la versione per il cliente"
    static let aiutoSoloPerTe = "Questo documento è solo per te"
    static let codaPerTe = "versione per te"
    static let codaPerIlCliente = "versione per il cliente"
    /// La frase del vuoto: la differenza fra le due versioni, per chi comincia.
    static let vuoto = "La versione per te è il documento dettagliato; quella per il cliente è l'essenziale da mostrare e da lasciargli."

    /// Il sottotitolo sopra la pagina: che cosa si guarda.
    static func sottotitolo(_ v: VersioneProspetto) -> String {
        v == .perIlCliente ? sottotitoloCliente : sottotitoloTe
    }

    /// L'etichetta grigia dei documenti con una versione sola.
    static func solo(_ v: VersioneProspetto) -> String {
        v == .perIlCliente ? soloPerIlCliente : soloPerTe
    }

    /// «PDF salvato: «<nome>» · versione per te» (senza la coda per i documenti con una versione sola).
    static func pdfSalvato(_ nome: String, versione: VersioneProspetto?) -> String {
        let base = "PDF salvato: «\(nome)»"
        switch versione {
        case .perTe?: return base + " · " + codaPerTe
        case .perIlCliente?: return base + " · " + codaPerIlCliente
        case nil: return base
        }
    }
}

extension DocumentoStampabile {
    /// Lo stesso documento con il timbro «SOLO PER TE» in alto a destra della prima pagina e la frase «Prospetto per il
    /// consulente: non va consegnato.» nel margine basso dell'ultima. Le pagine e il loro numero non cambiano: il timbro
    /// sta sopra la pagina (`overlay`), misurato dal bordo, e la frase sotto il piede.
    /// `alto`: la distanza del timbro dal bordo alto (40; nel margine alto per le pagine di `PaginaCarta`).
    func conTimbroPerTe(alto: CGFloat = Misure.Carta.timbroAlto) -> DocumentoStampabile {
        let m = Misure.Carta.self
        let n = pagine.count
        let larghezza = formato.width
        let altezza = formato.height
        let nuove: [AnyView] = pagine.enumerated().map { i, pagina in
            let prima = i == 0
            let ultima = i == n - 1
            guard prima || ultima else { return pagina }
            return AnyView(
                pagina
                    .frame(width: larghezza, height: altezza)
                    .overlay(alignment: .topTrailing) {
                        if prima {
                            TimbroSoloPerTe()
                                .padding(.top, alto)
                                .padding(.trailing, m.timbroDestra)
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if ultima {
                            NotaSoloPerTe(testo: TestiVersioneProspetto.notaUltimaPagina)
                                .padding(.horizontal, m.margineLato)
                                .padding(.bottom, m.notaPerTeBasso)
                        }
                    }
            )
        }
        return DocumentoStampabile(titolo: titolo, cliente: cliente, genere: genere, formato: formato, pagine: nuove, tipo: tipo)
    }
}
