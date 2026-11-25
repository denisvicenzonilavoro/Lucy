import SwiftUI
import CryptoKit
import LocalAuthentication
import Security

// L'ingresso in Lucy con l'impronta (Touch ID) o con il PIN sul tastierino (richiesta dell'utente del 25 novembre 2026:
// «la possibilità di entrare o col pollice o con il tastierino numerico con il pin»). Finché non c'è un PIN si entra
// come prima, con «Scorri per entrare»; con il PIN impostato lo sblocco chiede prima l'impronta (se il Mac ce l'ha) e
// in alternativa il PIN. Il PIN non si salva mai in chiaro: nel Portachiavi del Mac va solo la sua impronta SHA-256 con
// un sale casuale (mai nell'archivio né nei backup); l'impronta digitale non lascia mai il Mac (la controlla il sistema).

/// Il PIN di Lucy nel Portachiavi (sale e SHA-256; in Lucy Demo un servizio a parte).
enum PortachiaviPin {
    static var servizio: String { "Prisma PIN" + EdizioneLucy.suffissoPortachiavi }
    static let conto = "PIN di sblocco"
    static let etichetta = "Lucy – PIN di sblocco"
    /// Da 4 a 8 cifre.
    static let cifreMinime = 4
    static let cifreMassime = 8

    private static var ricerca: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: servizio,
         kSecAttrAccount as String: conto]
    }

    /// «sale:impronta» in esadecimale.
    private static func leggiValore() -> String? {
        var domanda = ricerca
        domanda[kSecReturnData as String] = true
        domanda[kSecMatchLimit as String] = kSecMatchLimitOne
        var risultato: CFTypeRef?
        guard SecItemCopyMatching(domanda as CFDictionary, &risultato) == errSecSuccess,
              let dati = risultato as? Data, let testo = String(data: dati, encoding: .utf8), !testo.isEmpty else { return nil }
        return testo
    }

    static var presente: Bool { leggiValore() != nil }

    static func impronta(_ pin: String, sale: String) -> String {
        SHA256.hash(data: Data((sale + ":" + pin).utf8)).map { String(format: "%02x", $0) }.joined()
    }

    /// Salva un PIN nuovo (solo cifre, da 4 a 8). false se non è valido o il Portachiavi non l'ha accettato.
    @discardableResult
    static func salva(_ pin: String) -> Bool {
        guard valido(pin) else { return false }
        var byte = [UInt8](repeating: 0, count: 16)
        guard SecRandomCopyBytes(kSecRandomDefault, byte.count, &byte) == errSecSuccess else { return false }
        let sale = byte.map { String(format: "%02x", $0) }.joined()
        let valore = Data((sale + ":" + impronta(pin, sale: sale)).utf8)
        _ = SecItemDelete(ricerca as CFDictionary)
        var nuova = ricerca
        nuova[kSecValueData as String] = valore
        nuova[kSecAttrLabel as String] = etichetta
        return SecItemAdd(nuova as CFDictionary, nil) == errSecSuccess
    }

    /// true se il PIN è quello salvato.
    static func controlla(_ pin: String) -> Bool {
        guard let v = leggiValore() else { return false }
        let parti = v.split(separator: ":", maxSplits: 1).map(String.init)
        guard parti.count == 2 else { return false }
        return impronta(pin, sale: parti[0]) == parti[1]
    }

    static func valido(_ pin: String) -> Bool {
        pin.count >= cifreMinime && pin.count <= cifreMassime && pin.allSatisfy(\.isNumber)
    }

    static func elimina() {
        _ = SecItemDelete(ricerca as CFDictionary)
    }
}

/// L'impronta digitale (Touch ID sul Mac, Face ID o Touch ID su iPhone e iPad): la controlla il sistema.
enum ImprontaSblocco {
    static var disponibile: Bool {
        LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    /// Chiede l'impronta; `esito` sul thread principale (true = riconosciuta).
    static func chiedi(_ esito: @escaping (Bool) -> Void) {
        let c = LAContext()
        c.localizedCancelTitle = "Usa il PIN"
        c.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "entrare in Lucy") { ok, _ in
            DispatchQueue.main.async { esito(ok) }
        }
    }
}

/// Il tastierino del PIN sopra la schermata di benvenuto. `crea`: si sceglie un PIN nuovo e si ripete.
struct TastierinoSblocco: View {
    enum Modo { case entra, crea }

    let modo: Modo
    let riuscito: () -> Void
    let annulla: () -> Void

    @State private var cifre = ""
    @State private var primo: String?
    @State private var messaggio: String?

    var body: some View {
        VStack(spacing: 18) {
            Text(titolo)
                .fontCarta(20, weight: .semibold, design: .serif)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
            HStack(spacing: 12) {
                ForEach(0..<max(PortachiaviPin.cifreMinime, cifre.count), id: \.self) { i in
                    Circle()
                        .fill(i < cifre.count ? TemaCarta.Colore.inchiostroD : Color.clear)
                        .overlay(Circle().stroke(TemaCarta.Colore.inchiostro2D, lineWidth: 1.2))
                        .frame(width: 12, height: 12)
                }
            }
            .accessibilityElement()
            .accessibilityLabel("\(cifre.count) cifre scritte")
            if let messaggio {
                Text(messaggio)
                    .fontCarta(12)
                    .foregroundColor(TemaCarta.Colore.rossoD)
            }
            VStack(spacing: 10) {
                ForEach([["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]], id: \.self) { riga in
                    HStack(spacing: 14) { ForEach(riga, id: \.self) { tasto($0) } }
                }
                HStack(spacing: 14) {
                    Button(action: cancella) {
                        Image(systemName: "delete.left")
                            .frame(width: 62, height: 62)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancella")
                    tasto("0")
                    Button(action: conferma) {
                        Image(systemName: "checkmark")
                            .frame(width: 62, height: 62)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.defaultAction)
                    .disabled(cifre.count < PortachiaviPin.cifreMinime)
                    .accessibilityLabel("Conferma")
                }
                .fontCarta(18, weight: .medium)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
            }
            Button("Annulla", action: annulla)
                .buttonStyle(.plain)
                .fontCarta(13, weight: .medium)
                .foregroundColor(TemaCarta.Colore.pennaD)
                .keyboardShortcut(.cancelAction)
        }
        .padding(28)
        .vetro(.spesso, forma: .arrotondata(TemaCarta.Raggio.riquadro))
        .background {
            // Le cifre anche dalla tastiera del Mac
            #if os(macOS)
            TastiPin { c in premi(c) } cancella: { cancella() }
            #endif
        }
    }

    private var titolo: String {
        switch modo {
        case .entra: return "Scrivi il PIN"
        case .crea: return primo == nil ? "Scegli un PIN (da 4 a 8 cifre)" : "Ripeti il PIN"
        }
    }

    private func tasto(_ c: String) -> some View {
        Button { premi(c) } label: {
            Text(c)
                .fontCarta(24, weight: .regular, design: .serif)
                .foregroundColor(TemaCarta.Colore.inchiostroD)
                .frame(width: 62, height: 62)
                .background(Circle().fill(TemaCarta.Colore.schedaD))
                .overlay(Circle().stroke(TemaCarta.Colore.filoD, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(c)
    }

    private func premi(_ c: String) {
        guard cifre.count < PortachiaviPin.cifreMassime else { return }
        messaggio = nil
        cifre += c
    }

    private func cancella() {
        if !cifre.isEmpty { cifre.removeLast() }
    }

    private func conferma() {
        switch modo {
        case .entra:
            if PortachiaviPin.controlla(cifre) {
                riuscito()
            } else {
                messaggio = "PIN sbagliato: riprova."
                cifre = ""
            }
        case .crea:
            if let p = primo {
                if p == cifre, PortachiaviPin.salva(cifre) {
                    riuscito()
                } else {
                    messaggio = "I due PIN non sono uguali: ricomincia."
                    primo = nil
                    cifre = ""
                }
            } else {
                guard PortachiaviPin.valido(cifre) else {
                    messaggio = "Da 4 a 8 cifre."
                    return
                }
                primo = cifre
                cifre = ""
            }
        }
    }
}

#if os(macOS)
/// Le cifre e il tasto Cancella dalla tastiera del Mac, mentre il tastierino è aperto.
private struct TastiPin: View {
    let cifra: (String) -> Void
    let cancella: () -> Void

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { n in
                Button("") { cifra("\(n)") }
                    .keyboardShortcut(KeyEquivalent(Character("\(n)")), modifiers: [])
            }
            Button("") { cancella() }
                .keyboardShortcut(.delete, modifiers: [])
        }
        .buttonStyle(.plain)
        .frame(width: 0, height: 0)
        .opacity(0)
        .accessibilityHidden(true)
    }
}
#endif

/// Impostazioni › Archivio › «Ingresso»: il PIN (con l'impronta, se il Mac ce l'ha) per entrare in Lucy.
struct GruppoIngressoImpostazioni: View {
    @State private var pinPresente = PortachiaviPin.presente
    @State private var scegliPin = false

    var body: some View {
        GruppoImpostazioni(titolo: "Ingresso") {
            RigaImpostazione(titolo: "PIN di sblocco",
                             sottotitolo: pinPresente
                                ? (ImprontaSblocco.disponibile ? "Attivo: prima l'impronta, poi il PIN." : "Attivo: si entra con il PIN.")
                                : "Spento: si entra scorrendo.",
                             aiuto: "Il PIN resta solo nel Portachiavi di questo dispositivo, mai nell'archivio né nei backup",
                             ultima: true) {
                HStack(spacing: 8) {
                    Button(pinPresente ? "Cambia PIN" : "Scegli un PIN") { scegliPin = true }
                        .buttonStyle(StilePulsanteRigaImpostazioni())
                    if pinPresente {
                        Button("Togli") {
                            PortachiaviPin.elimina()
                            pinPresente = false
                        }
                        .buttonStyle(StilePulsanteRigaImpostazioni())
                    }
                }
            }
        }
        .sheet(isPresented: $scegliPin) {
            TastierinoSblocco(modo: .crea, riuscito: {
                pinPresente = true
                scegliPin = false
            }, annulla: { scegliPin = false })
            .padding(20)
        }
    }
}
