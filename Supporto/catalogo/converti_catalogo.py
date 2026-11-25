#!/usr/bin/env python3
"""Converte data/catalogo/catalogo_lucy.xlsx in catalogo.json (versionato) e scrive il report delle celle non convertite.

Uso in Lucy per il Mac (dalla cartella del repository, senza argomenti):
    python3 Supporto/catalogo/converti_catalogo.py [--versione N]
legge Supporto/catalogo/catalogo_lucy.xlsx, scrive Sources/Prisma/Risorse/Catalogo/catalogo.json (risorsa dell'app) e
Supporto/catalogo/report-celle-non-convertite.csv. Altrove: converti_catalogo.py <xlsx> <cartella di uscita>.
Per aggiornare il catalogo basta sostituire l'xlsx e rilanciare lo script: il codice dell'app non cambia.

Solo libreria standard (l'xlsx è uno zip di XML): nessuna dipendenza da installare.

REGOLA FERREA: nessun numero inventato. Ogni cella resta com'è nel campo `testo`; i campi strutturati si riempiono solo
quando il testo ha una forma sola e chiara (un numero, un intervallo «A - B», «19% su max 530 €»…). In ogni altro caso
il campo strutturato resta assente e la cella finisce nel report, così si controlla a mano.
"""
import datetime
import json
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
      "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships"}

# ---------------------------------------------------------------- lettura dell'xlsx

def leggi_xlsx(percorso):
    """{nome foglio: [righe di stringhe o numeri]}"""
    with zipfile.ZipFile(percorso) as z:
        condivise = []
        if "xl/sharedStrings.xml" in z.namelist():
            radice = ET.fromstring(z.read("xl/sharedStrings.xml"))
            for si in radice.findall("m:si", NS):
                condivise.append("".join(t.text or "" for t in si.iter("{%s}t" % NS["m"])))
        libro = ET.fromstring(z.read("xl/workbook.xml"))
        rel = ET.fromstring(z.read("xl/_rels/workbook.xml.rels"))
        obiettivi = {r.get("Id"): r.get("Target") for r in rel}
        fogli = {}
        for f in libro.find("m:sheets", NS):
            rid = f.get("{%s}id" % NS["r"])
            dest = obiettivi[rid].lstrip("/")
            dest = dest if dest.startswith("xl/") else "xl/" + dest
            fogli[f.get("name")] = leggi_foglio(ET.fromstring(z.read(dest)), condivise)
        return fogli


def colonna(ref):
    lettere = re.match(r"[A-Z]+", ref).group(0)
    n = 0
    for c in lettere:
        n = n * 26 + ord(c) - 64
    return n - 1


def leggi_foglio(radice, condivise):
    righe = []
    for r in radice.iter("{%s}row" % NS["m"]):
        riga = {}
        for c in r.findall("m:c", NS):
            t = c.get("t")
            v = c.find("m:v", NS)
            if t == "s" and v is not None:
                val = condivise[int(v.text)]
            elif t == "inlineStr":
                val = "".join(x.text or "" for x in c.iter("{%s}t" % NS["m"]))
            elif v is not None:
                grezzo = v.text
                try:
                    val = float(grezzo)
                    if val.is_integer() and "." not in grezzo and "E" not in grezzo.upper():
                        val = int(val)
                except ValueError:
                    val = grezzo
            else:
                val = None
            if isinstance(val, str):
                val = val.strip() or None
            riga[colonna(c.get("r"))] = val
        if riga:
            righe.append([riga.get(i) for i in range(max(riga) + 1)])
    return righe

# ---------------------------------------------------------------- numeri all'italiana

NUM = r"\d{1,3}(?:\.\d{3})+(?:,\d+)?|\d+(?:,\d+)?"


def numero_it(s):
    """«1.291,14» → 1291.14; «4,5» → 4.5; «10000» → 10000."""
    return float(s.replace(".", "").replace(",", "."))


def solo_numero(v):
    """La cella è un numero e basta (o un testo che è solo un numero, al più con «€»)."""
    if isinstance(v, (int, float)):
        return float(v)
    if isinstance(v, str) and re.fullmatch(r"\s*(%s)\s*€?\s*" % NUM, v):
        return numero_it(re.search(NUM, v).group(0))
    return None


def percentuale(v):
    """Una sola percentuale: 0.045 (numero dell'xlsx, già frazione) o «4,5%». Restituisce la frazione."""
    if isinstance(v, (int, float)):
        return float(v) if 0 <= v <= 1 else None
    if not isinstance(v, str):
        return None
    m = re.fullmatch(r"\s*(%s)\s*%%\s*" % NUM, v)
    return round(numero_it(m.group(1)) / 100, 6) if m else None


def intervallo_percentuale(v):
    """«0,01% - 0,02%» → (min, max) in frazione; «Costi correnti 1,57%» (una sola %) → (x, x)."""
    p = percentuale(v)
    if p is not None:
        return p, p
    if not isinstance(v, str):
        return None
    trovati = re.findall(r"(%s)\s*%%" % NUM, v)
    if len(trovati) == 1 and not re.search(r"\d\s*[-–]\s*\d", v):
        x = round(numero_it(trovati[0]) / 100, 6)
        return x, x
    m = re.fullmatch(r"[^\d]*?(%s)\s*%%?\s*[-–]\s*(%s)\s*%%(\s*\([^)]*\))?\s*" % (NUM, NUM), v)
    if m:
        return round(numero_it(m.group(1)) / 100, 6), round(numero_it(m.group(2)) / 100, 6)
    return None


def intervallo_interi(v, unita):
    """«18 - 85 anni» → (18, 85) se la cella comincia così; «6» → (6, 6)."""
    if isinstance(v, (int, float)):
        return int(v), int(v)
    if not isinstance(v, str):
        return None
    m = re.match(r"\s*(\d+)\s*[-–]\s*(\d+)\s*%s" % unita, v)
    if m:
        return int(m.group(1)), int(m.group(2))
    m = re.fullmatch(r"\s*(\d+)\s*%s\s*" % unita, v)
    if m:
        return int(m.group(1)), int(m.group(1))
    return None

# ---------------------------------------------------------------- estrazioni per colonna
# Ogni funzione riceve la cella e restituisce i campi certi (vuoto se niente di certo).

def e_euro(nome):
    def f(v):
        x = solo_numero(v)
        return {nome: x} if x is not None else {}
    return f


def e_percento(nome):
    def f(v):
        x = percentuale(v)
        return {nome: x} if x is not None else {}
    return f


def e_intervallo_percento(nome):
    def f(v):
        x = intervallo_percentuale(v)
        return {nome + "_min": x[0], nome + "_max": x[1]} if x else {}
    return f


def e_eta(v):
    x = intervallo_interi(v, r"anni")
    return {"eta_min": x[0], "eta_max": x[1]} if x else {}


def e_periodo(v):
    if isinstance(v, str):
        m = re.fullmatch(r"\s*(\d+)\s*(?:anni)?\s*(\([^)]*\))?\s*", v)
        return {"periodo_anni": int(m.group(1))} if m else {}
    x = intervallo_interi(v, r"")
    return {"periodo_anni": x[0]} if x else {}


def e_sri(v):
    x = intervallo_interi(v, r"")
    return {"sri_min": x[0], "sri_max": x[1]} if x and 1 <= x[0] <= 7 and 1 <= x[1] <= 7 else {}


def e_penali(v):
    """«2° anno 2,5%; 3° 2%; …; poi 0» → {anno: frazione}. Solo se ogni pezzo ha quella forma."""
    if isinstance(v, str) and re.fullmatch(r"\s*nessuna(\s+penale(\s+di\s+uscita)?)?\.?\s*", v, re.I):
        return {"penali_per_anno": {}}
    if not isinstance(v, str):
        return {}
    anni = {}
    for p in [p.strip() for p in v.split(";") if p.strip()]:
        m = re.fullmatch(r"(\d+)°\s*(?:anno)?\s*(%s)\s*%%" % NUM, p)
        if m:
            anni[str(int(m.group(1)))] = round(numero_it(m.group(2)) / 100, 6)
        elif not re.fullmatch(r"poi\s*0\s*%?|dal\s*\d+°\s*nessuna", p):
            return {}
    return {"penali_per_anno": anni} if anni else {}


def e_riscattabile(v):
    if not isinstance(v, str):
        return {}
    g = re.fullmatch(r"\s*(\d+)\s*giorni\s*", v)
    if g:
        return {"riscatto_dopo_giorni": int(g.group(1))}
    a = re.fullmatch(r"\s*(\d+)°\s*anno\s*", v)
    if a:
        return {"riscatto_dal_anno": int(a.group(1))}
    m = re.fullmatch(r"\s*(\d+)\s*(anno|anni|mese|mesi)\s*", v)
    if not m:
        return {}
    n = int(m.group(1))
    return {"riscatto_dopo_mesi": n * 12 if m.group(2).startswith("ann") else n}


def e_bollo(v):
    if isinstance(v, str):
        if re.match(r"\s*sì\b", v, re.I):
            return {"bollo": True}
        if re.match(r"\s*no\b", v, re.I):
            return {"bollo": False}
    return {}


def e_carenza(v):
    """Una sola carenza chiara («6 mesi …», «30 giorni …»); «Nessuna» → 0."""
    if not isinstance(v, str):
        return {}
    if re.fullmatch(r"\s*nessuna\.?\s*", v, re.I):
        return {"carenza_giorni": 0}
    tutte = re.findall(r"(\d+)\s*(giorni|mesi)", v)
    if len(tutte) == 1:
        n, u = int(tutte[0][0]), tutte[0][1]
        return {"carenza_giorni": n} if u == "giorni" else {"carenza_mesi": n}
    return {}


def e_franchigie(v):
    if not isinstance(v, str):
        return {}
    if re.fullmatch(r"\s*nessuna\.?\s*", v, re.I):
        return {"franchigia_euro": 0.0, "scoperto": 0.0}
    out = {}
    sc = re.findall(r"scoperto\s*(?:del\s*)?(%s)\s*%%(?:\s*(?:con\s*)?(?:minimo|min\.?)\s*(?:di\s*)?(%s)\s*€)?" % (NUM, NUM), v, re.I)
    if len(sc) == 1:
        out["scoperto"] = round(numero_it(sc[0][0]) / 100, 6)
        if sc[0][1]:
            out["scoperto_minimo_euro"] = numero_it(sc[0][1])
    fr = re.findall(r"franchigia\s*(?:fissa\s*)?(?:di\s*)?(%s)\s*€" % NUM, v, re.I)
    if len(fr) == 1:
        out["franchigia_euro"] = numero_it(fr[0])
    return out


def e_eta_ingresso(v):
    if isinstance(v, str):
        d = re.fullmatch(r"\s*da\s*(\d+)\s*anni\s*(\([^)]*\))?\s*", v, re.I)
        if d:
            return {"eta_ingresso_min": int(d.group(1))}
        f = re.fullmatch(r"\s*fino a\s*(\d+)\s*anni\s*", v, re.I)
        if f:
            return {"eta_ingresso_max": int(f.group(1))}
    x = intervallo_interi(v, r"anni")
    return {"eta_ingresso_min": x[0], "eta_ingresso_max": x[1]} if x else {}


def e_eta_massima(v):
    if isinstance(v, (int, float)):
        return {"eta_massima": int(v)}
    if isinstance(v, str):
        tutte = re.findall(r"(%s)\s*anni" % NUM, v)
        if len(tutte) == 1:
            return {"eta_massima": numero_it(tutte[0])}
    return {}


def e_capitale(v):
    """Il capitale solo se la cella ne dice uno: «fino a N €», «max N €» o un intervallo «A - B €»."""
    if isinstance(v, (int, float)):
        return {"capitale_massimo_euro": float(v)}
    if not isinstance(v, str):
        return {}
    m = re.findall(r"(?:fino a|max(?:imo)?)\s*(%s)\s*€" % NUM, v, re.I)
    r = re.findall(r"(%s)\s*[-–]\s*(%s)\s*€" % (NUM, NUM), v)
    if len(m) == 1 and not r:
        return {"capitale_massimo_euro": numero_it(m[0])}
    if len(r) == 1 and not m:
        return {"capitale_minimo_euro": numero_it(r[0][0]), "capitale_massimo_euro": numero_it(r[0][1])}
    return {}


def e_imposta(v):
    if isinstance(v, (int, float)):
        return {"imposta_premio": float(v)} if 0 <= v <= 1 else {}
    if not isinstance(v, str):
        return {}
    if re.fullmatch(r"\s*(esente|nessuna)\s*(\(?vita\)?)?\.?\s*", v, re.I):
        return {"imposta_premio": 0.0}
    m = re.fullmatch(r"\s*RCA\s*(%s)\s*%%\s*\+\s*(%s)\s*%%\s*SSN\s*" % (NUM, NUM), v, re.I)
    if m:
        return {"imposta_premio": round(numero_it(m.group(1)) / 100, 6), "contributo_ssn": round(numero_it(m.group(2)) / 100, 6)}
    tutte = re.findall(r"(%s)\s*%%" % NUM, v)
    if len(tutte) == 1 and not re.search(r"esente", v, re.I):
        return {"imposta_premio": round(numero_it(tutte[0]) / 100, 6)}
    return {}


def e_detrazione(v):
    if not isinstance(v, str):
        return {}
    m = re.findall(r"(%s)\s*%%\s*(?:su\s*max|fino a)\s*(%s)\s*€" % (NUM, NUM), v, re.I)
    if len(m) == 1:
        return {"detrazione": round(numero_it(m[0][0]) / 100, 6), "detrazione_massimale_euro": numero_it(m[0][1])}
    if re.fullmatch(r"\s*(no|non detraibile)\.?\s*", v, re.I):
        return {"detrazione": 0.0}
    return {}


def e_caricamenti(v):
    """Premio di esempio / caricamenti: solo voci con il loro nome scritto accanto."""
    if not isinstance(v, str):
        return {}
    out = {}
    m = re.findall(r"frazionamento[^0-9+;]*\+?\s*(%s)\s*%%(?:\s*/\s*\+?\s*(%s)\s*%%)?" % (NUM, NUM), v, re.I)
    if len(m) == 1:
        out["frazionamento_min"] = round(numero_it(m[0][0]) / 100, 6)
        out["frazionamento_max"] = round(numero_it(m[0][1] or m[0][0]) / 100, 6)
    m = re.findall(r"caricament[oi][^0-9;]*?(%s)\s*%%" % NUM, v, re.I)
    if len(m) == 1:
        out["caricamento"] = round(numero_it(m[0]) / 100, 6)
    m = re.findall(r"diritti[^0-9;]*?(%s)\s*€" % NUM, v, re.I)
    if len(m) == 1:
        out["diritti_euro"] = numero_it(m[0])
    m = re.findall(r"(?:intermediari[oa]|provvigion[ei])[^0-9;]*?(%s)\s*%%" % NUM, v, re.I)
    if len(m) == 1:
        out["quota_intermediario"] = round(numero_it(m[0]) / 100, 6)
    m = re.findall(r"(?:costi fissi|spese fisse)[^0-9;]*?(%s)\s*€" % NUM, v, re.I)
    if len(m) == 1:
        out["costi_fissi_euro"] = numero_it(m[0])
    m = re.findall(r"premio minimo\s*(%s)\s*€" % NUM, v, re.I)
    if len(m) == 1:
        out["premio_minimo_euro"] = numero_it(m[0])
    return out


# Colonna S: il livello di dettaglio ridotto alle cinque voci dell'app (più «Categoria» per le righe generiche)
LIVELLI = [("non trovato", "Non trovato"), ("rimando", "Base"), ("completo", "Completo"),
           ("verificato su dip", "Completo"), ("medio", "Medio"), ("solo dip", "Medio"), ("parziale", "Parziale"),
           ("solo pagina prodotto", "Parziale"), ("base", "Base"), ("solo nome prodotto", "Base"),
           ("tipico di categoria", "Categoria")]


def livello(v):
    if not isinstance(v, str):
        return None
    t = v.lower()
    for chiave, nome in LIVELLI:
        if chiave in t:
            return nome
    return None

# ---------------------------------------------------------------- schema dei fogli

FOGLI = {
    "Investimento e risparmio": {
        "chiave": "investimento",
        "colonne": ["compagnia", "prodotto", "area", "tipo", "premio_minimo", "versamenti", "costo_ingresso",
                    "costi_fissi", "costo_gestione_separata", "costo_fondi", "incidenza_primo_anno",
                    "incidenza_periodo_raccomandato", "periodo_raccomandato", "sri", "penali", "riscattabile_da",
                    "switch", "garanzie", "caso_morte", "eta", "bollo", "da_sapere", "fonte"],
        "estrai": {"premio_minimo": e_euro("premio_minimo_euro"), "costo_ingresso": e_intervallo_percento("costo_ingresso"),
                   "costi_fissi": e_euro("costi_fissi_euro"),
                   "costo_gestione_separata": e_intervallo_percento("costo_gestione_separata"),
                   "costo_fondi": e_intervallo_percento("costo_fondi"),
                   "incidenza_primo_anno": e_intervallo_percento("incidenza_primo_anno"),
                   "incidenza_periodo_raccomandato": e_intervallo_percento("incidenza_periodo"),
                   "periodo_raccomandato": e_periodo, "sri": e_sri, "penali": e_penali,
                   "riscattabile_da": e_riscattabile, "eta": e_eta, "bollo": e_bollo},
    },
    "Protezione": {
        "chiave": "protezione",
        "colonne": ["compagnia", "prodotto", "categoria", "garanzie_base", "garanzie_opzionali", "eta_ingresso",
                    "eta_massima", "capitali", "durata", "carenze", "franchigie", "esclusioni", "non_assicurabili",
                    "visita_medica", "imposta", "detraibilita", "recesso", "da_sapere", "livello_dettaglio", "fonte",
                    "premio_esempio"],
        "estrai": {"eta_ingresso": e_eta_ingresso, "eta_massima": e_eta_massima, "capitali": e_capitale,
                   "carenze": e_carenza, "franchigie": e_franchigie, "imposta": e_imposta,
                   "detraibilita": e_detrazione, "premio_esempio": e_caricamenti},
    },
    "Previdenza": {
        "chiave": "previdenza",
        "colonne": ["compagnia", "prodotto", "tipo", "comparto", "garanzia", "spese_adesione", "spese_annue",
                    "caricamento_versamenti", "costo_gestione", "isc_2", "isc_5", "isc_10", "isc_35",
                    "trasferimento", "riscatto", "anticipazione", "switch", "rita", "prestazioni_accessorie",
                    "costi_rendita", "da_sapere", "scheda_costi_dal", "fonte"],
        "estrai": {"spese_adesione": e_euro("spese_adesione_euro"), "spese_annue": e_euro("spese_annue_euro"),
                   "caricamento_versamenti": e_percento("caricamento_versamenti"),
                   "costo_gestione": e_percento("costo_gestione"), "isc_2": e_percento("isc_2"),
                   "isc_5": e_percento("isc_5"), "isc_10": e_percento("isc_10"), "isc_35": e_percento("isc_35"),
                   "trasferimento": e_euro("trasferimento_euro"), "riscatto": e_euro("riscatto_euro"),
                   "anticipazione": e_euro("anticipazione_euro")},
    },
}

CATEGORIA = re.compile(r"^\s*tutte\b", re.I)


def testo(v):
    if v is None:
        return None
    if isinstance(v, float):
        return ("%.6f" % v).rstrip("0").rstrip(".")
    return str(v)


def converti(fogli, versione, data):
    catalogo = {"versione": versione, "data": data, "fonte": "catalogo_lucy.xlsx",
                "avvertenza": "Dati indicativi ricavati dai documenti pubblici della compagnia. Fanno fede i documenti contrattuali.",
                "dato_mancante": "dato non disponibile nel catalogo"}
    report = []
    for nome, schema in FOGLI.items():
        righe = fogli.get(nome)
        if not righe:
            report.append((nome, "-", "-", "-", "foglio mancante"))
            continue
        voci = []
        for n, r in enumerate(righe[1:], start=2):
            if not any(c is not None for c in r):
                continue
            celle, campi = {}, {}
            for i, col in enumerate(schema["colonne"]):
                v = r[i] if i < len(r) else None
                celle[col] = testo(v)
                if col in schema["estrai"] and v is not None:
                    trovati = schema["estrai"][col](v)
                    campi.update(trovati)
                    if not trovati:
                        report.append((nome, n, chr(65 + i), col, testo(v)))
            compagnia = celle.get("compagnia") or ""
            voce = {"id": "%s-%d" % (schema["chiave"], n), "riga": n,
                    "scheda_categoria": bool(CATEGORIA.match(compagnia)),
                    "testo": celle, "valori": campi}
            if schema["chiave"] == "protezione":
                voce["livello"] = livello(celle.get("livello_dettaglio"))
            voci.append(voce)
        catalogo[schema["chiave"]] = voci
    # Fogli di guida: il testo così com'è
    for nome, chiave in [("Esclusioni tipiche", "esclusioni_tipiche"), ("Fiscalità", "fiscalita")]:
        righe = fogli.get(nome) or []
        if righe:
            testa = [testo(x) for x in righe[0]]
            catalogo[chiave] = [{testa[i]: (testo(r[i]) if i < len(r) else None) for i in range(len(testa))}
                                for r in righe[1:] if any(c is not None for c in r)]
    catalogo["leggimi"] = [testo(r[0]) for r in fogli.get("Leggimi", []) if r and r[0] is not None]
    return catalogo, report


def main():
    argomenti = [a for a in sys.argv[1:] if not a.startswith("--") and not a.isdigit()]
    qui = Path(__file__).resolve().parent
    if len(argomenti) >= 2:
        sorgente, uscita, rapporto = Path(argomenti[0]), Path(argomenti[1]), Path(argomenti[1])
    else:
        sorgente = qui / "catalogo_lucy.xlsx"
        uscita = qui.parent.parent / "Sources" / "Prisma" / "Risorse" / "Catalogo"
        rapporto = qui
    versione = int(sys.argv[sys.argv.index("--versione") + 1]) if "--versione" in sys.argv else 1
    fogli = leggi_xlsx(sorgente)
    data = datetime.date.today().isoformat()
    leggimi = " ".join(str(r[0]) for r in fogli.get("Leggimi", []) if r and r[0])
    m = re.search(r"Aggiornato al (\d{2})/(\d{2})/(\d{4})", leggimi)
    if m:
        data = "%s-%s-%s" % (m.group(3), m.group(2), m.group(1))
    catalogo, report = converti(fogli, versione, data)
    uscita.mkdir(parents=True, exist_ok=True)
    (uscita / "catalogo.json").write_text(json.dumps(catalogo, ensure_ascii=False, indent=1), encoding="utf-8")
    # Il report si apre in Excel (punto e virgola, UTF-8 con BOM)
    import csv
    rapporto.mkdir(parents=True, exist_ok=True)
    with open(rapporto / "report-celle-non-convertite.csv", "w", encoding="utf-8-sig", newline="") as f:
        w = csv.writer(f, delimiter=";")
        w.writerow(["Foglio", "Riga", "Colonna", "Campo", "Testo originale"])
        for r in report:
            w.writerow([str(x).replace("\n", " ") for x in r])
    conteggi = {k: len(catalogo.get(k, [])) for k in ("investimento", "protezione", "previdenza")}
    print("catalogo.json versione %d del %s: %s" % (versione, data, conteggi))
    print("celle da controllare: %d (report-celle-non-convertite.csv)" % len(report))


if __name__ == "__main__":
    main()
