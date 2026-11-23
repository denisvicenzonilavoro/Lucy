import SwiftUI

// Gli sfondi vivi dello stile Carta (NOVITÀ 12, template «LUCE DEL POMERIGGIO», «CRISTALLO», «CARTA MARMORIZZATA»,
// «INCHIOSTRO»): gli shader del template tradotti in Metal per `TelaShader` (Apple/TelaShader.swift), che li compila a
// runtime e li disegna fuori dal thread principale, al più a 30 fotogrammi al secondo (20 con il risparmio energetico),
// fermi con «Riduci movimento», a riposo o con la finestra nascosta. Se uno shader non si compila, la tela mostra la
// carta ferma (il ripiego), mai una schermata vuota.
// Uniformi: `u.tempo`, `u.risoluzione`, `u.parametri.x` = notte (0 o 1), `.y` = soffio (tocco: le foglie si muovono di
// più, il cristallo gira), `.z` e `.w` = punto toccato (0…1) per la carta marmorizzata e l'inchiostro.
// L'inchiostro del template è un fluido a più passaggi; qui è una sola passata di inchiostro che si allarga nell'acqua
// (rumore con il campo deformato), più leggera per il MacBook da 8 GB.

enum ShaderSfondiCarta {
    /// Le funzioni comuni (NOISE del template): hash, rumore di valore, fbm, rotazione, colore della carta.
    static let comune = """
    float h21(float2 p) { float3 p3 = fract(float3(p.xyx) * 0.1031); p3 += dot(p3, p3.yzx + 33.33); return fract((p3.x + p3.y) * p3.z); }
    float2 h22(float2 p) { float3 p3 = fract(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973)); p3 += dot(p3, p3.yzx + 33.33);
        return fract((p3.xx + p3.yz) * p3.zy); }
    float vn(float2 p) { float2 i = floor(p); float2 f = fract(p); float2 u = f * f * (3.0 - 2.0 * f);
        return mix(mix(h21(i), h21(i + float2(1.0, 0.0)), u.x), mix(h21(i + float2(0.0, 1.0)), h21(i + float2(1.0, 1.0)), u.x), u.y); }
    float fbm(float2 p) { float v = 0.0; float a = 0.5; for (int i = 0; i < 4; i++) { v += a * vn(p); p = p * 2.03 + float2(17.1, 9.3); a *= 0.5; } return v; }
    float2x2 rot(float a) { float c = cos(a); float s = sin(a); return float2x2(float2(c, s), float2(-s, c)); }
    float3 paperCol(float2 uv, float n) {
        float fib = 0.5 * vn(uv * float2(520.0, 110.0)) + 0.5 * vn(uv * float2(110.0, 520.0));
        float mott = fbm(uv * 3.2);
        float3 d = float3(0.932, 0.907, 0.860) * (0.982 + 0.036 * mott) + (fib - 0.5) * 0.016;
        float3 nn = float3(0.082, 0.083, 0.095) * (0.96 + 0.08 * mott) + (fib - 0.5) * 0.008;
        return mix(d, nn, n);
    }
    float soft(float x, float s) { return smoothstep(-s, s, x); }
    float vignetta(float2 uv) { return smoothstep(1.45, 0.35, length((uv - float2(0.8, 0.5)) * float2(0.66, 1.0))); }
    /// Le coordinate del template: origine in basso a sinistra, unità = altezza.
    float2 uvTemplate(float2 uv, float2 res) { return float2(uv.x * res.x, (1.0 - uv.y) * res.y) / max(res.y, 1.0); }

    """

    /// Luce del pomeriggio: la finestra di luce sulla carta, le foglie che si muovono, il pulviscolo; di notte la luna e
    /// la lampada.
    static let luce = comune + """
    float2 bez(float2 a, float2 b, float2 c, float t) { return mix(mix(a, b, t), mix(b, c, t), t); }
    float2 bezT(float2 a, float2 b, float2 c, float t) { return normalize(mix(b - a, c - b, t)); }
    float sdSeg(float2 p, float2 a, float2 b) { float2 pa = p - a; float2 ba = b - a; float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0); return length(pa - ba * h); }
    float leaf(float2 p, float2 c, float2 dir, float L, float Wd, float sf) {
        float2 d = p - c; float2 lp = float2(dot(d, dir), dot(d, float2(-dir.y, dir.x)));
        float x = lp.x / L - 1.0;
        float w = Wd * sqrt(max(0.0, 1.0 - x * x)) * (1.0 - 0.22 * x);
        float e = abs(lp.y) - w;
        float dd = abs(x) <= 1.0 ? e : max(e, (abs(x) - 1.0) * L);
        return 1.0 - smoothstep(-sf, sf, dd);
    }
    float branch(float2 p, float2 a, float2 b, float2 c, float t, float g, float seed, float sz) {
        float ang = (0.025 + 0.09 * g) * sin(t * 0.55 + seed * 3.0) + 0.012 * sin(t * 1.7 + seed);
        b = a + rot(ang) * (b - a); c = a + rot(ang * 1.4) * (c - a);
        float2 lo = min(min(a, b), c) - 0.09 * sz; float2 hi = max(max(a, b), c) + 0.09 * sz;
        if (p.x < lo.x || p.y < lo.y || p.x > hi.x || p.y > hi.y) { return 0.0; }
        float sh = 0.0; float2 prev = a;
        for (int i = 1; i <= 8; i++) { float tt = float(i) / 8.0; float2 q = bez(a, b, c, tt); float d = sdSeg(p, prev, q);
            sh = max(sh, 1.0 - smoothstep(0.0011 * sz * (1.7 - tt), 0.0040 * sz, d)); prev = q; }
        for (int k = 0; k < 10; k++) {
            float tt = 0.10 + 0.087 * float(k);
            float2 an = bez(a, b, c, tt); float2 tg = bezT(a, b, c, tt);
            float side = (k % 2 == 0) ? 1.0 : -1.0;
            float fl = 0.10 * sin(t * 1.3 + seed * 5.0 + float(k) * 1.7) * (0.4 + g);
            float2 dir = rot(side * (0.55 + 0.18 * sin(seed * 2.0 + float(k))) + fl) * tg;
            float L = sz * (0.031 - 0.011 * tt); float Wd = sz * (0.0078 - 0.0022 * tt);
            sh = max(sh, leaf(p, an, dir, L, Wd, 0.0020 * sz + 0.0018));
        }
        float2 tip = bez(a, b, c, 1.0); float2 tg = bezT(a, b, c, 1.0);
        sh = max(sh, leaf(p, tip - tg * 0.002, tg, sz * 0.022, sz * 0.0062, 0.0020 * sz + 0.0018));
        return sh;
    }
    float motes(float2 uv, float t, float sc, float sp, float sz, float seed) {
        float2 g = uv * sc + float2(t * sp * 0.5 + seed, -t * sp * 0.8);
        float2 id = floor(g); float2 f = fract(g); float2 r = h22(id + seed);
        float2 pos = 0.2 + 0.6 * r + 0.15 * float2(sin(t * 0.37 + r.x * 6.0), cos(t * 0.29 + r.y * 6.0));
        float d = length(f - pos);
        float tw = 0.55 + 0.45 * sin(t * (0.8 + r.y) + r.x * 30.0);
        return step(0.62, r.y) * (1.0 - smoothstep(sz * 0.25, sz, d)) * tw;
    }
    fragment float4 fs_tela(UscitaTela in [[stage_in]], constant UniformiTela &u [[buffer(0)]]) {
        float2 uv = uvTemplate(in.uv, u.risoluzione);
        float t = u.tempo; float N = u.parametri.x; float G = u.parametri.y;
        float3 paper = paperCol(uv, N);
        float2 O = float2(-0.20, 1.18) + 0.05 * float2(sin(t * 0.010), cos(t * 0.008));
        float2 q = rot(0.50) * (uv - O); q.y = -q.y; q.x -= 0.42 * q.y;
        float s = 0.010 + 0.022 * clamp(q.x, 0.0, 1.5);
        float win = soft(q.x, s) * soft(1.62 - q.x, s) * soft(q.y, s) * soft(0.78 - q.y, s);
        float mv = 1.0 - soft(0.022 - abs(q.x - 0.80), s);
        float mh = 1.0 - soft(0.016 - abs(q.y - 0.40), s);
        float lit = win * mv * mh;
        float lf = 0.0;
        lf = max(lf, branch(uv, float2(-0.06, 0.70), float2(0.12, 0.66), float2(0.36, 0.47), t, G, 1.0, 1.10));
        lf = max(lf, branch(uv, float2(-0.06, 0.50), float2(0.10, 0.40), float2(0.24, 0.22), t, G, 2.0, 0.95));
        lf = max(lf, branch(uv, float2(0.28, -0.06), float2(0.40, 0.05), float2(0.60, 0.15), t, G, 3.0, 1.00));
        lf = max(lf, branch(uv, float2(0.50, -0.07), float2(0.66, 0.02), float2(0.80, 0.17), t, G, 4.0, 0.85));
        lf = max(lf, branch(uv, float2(0.30, 1.06), float2(0.46, 1.00), float2(0.62, 0.86), t, G, 5.0, 0.90));
        lit *= 1.0 - 0.80 * lf;
        lit *= 0.80 + 0.20 * smoothstep(0.30, 0.70, vn(float2(t * 0.012, 4.7)));
        float m = motes(uv, t, 16.0, 0.010, 0.030, 1.3) + 0.7 * motes(uv, t, 26.0, 0.007, 0.040, 7.9) + 0.35 * motes(uv, t, 6.0, 0.014, 0.085, 3.3);
        float3 sun = float3(1.0, 0.94, 0.82);
        float3 day = paper * (0.875 + 0.20 * lit * sun) + float3(0.020, 0.011, 0.0) * lit + sun * m * lit * 0.16;
        float3 moon = float3(0.80, 0.86, 1.0);
        float2 lp = (uv - float2(1.38, 0.10)) * float2(0.85, 1.0);
        float lamp = exp(-dot(lp, lp) * 2.4);
        float3 lampC = float3(0.95, 0.68, 0.32);
        float mn = 0.35 * motes(uv, t, 6.0, 0.014, 0.085, 3.3) + 0.6 * motes(uv, t, 16.0, 0.010, 0.030, 1.3);
        float3 night = paper * (0.90 + 1.65 * lit * moon) + lampC * lamp * 0.13 + float3(0.95, 0.78, 0.45) * mn * (lamp * 0.7 + lit * 0.25) * 0.22;
        float3 col = mix(day, night, N);
        col *= mix(0.90, 1.0, vignetta(uv));
        return float4(col, 1.0);
    }
    """

    /// Cristallo: la luce che passa da un cristallo e trema sulla carta in una rete di riflessi.
    static let cristallo = comune + """
    float voro(float2 p, float t) {
        float2 i = floor(p); float2 f = fract(p); float d1 = 8.0; float d2 = 8.0;
        for (int y = -1; y <= 1; y++) { for (int x = -1; x <= 1; x++) {
            float2 g = float2(float(x), float(y)); float2 o = h22(i + g); o = 0.5 + 0.38 * sin(t + 6.2831 * o);
            float2 r = g + o - f; float d = dot(r, r);
            if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
        } }
        return sqrt(d2) - sqrt(d1);
    }
    float caus(float2 p, float t) {
        float2 w = float2(vn(p * 0.45 + float2(t * 0.06, 0.0)), vn(p * 0.45 + float2(7.3, -t * 0.05)));
        p += 0.9 * w;
        float c = exp(-voro(p, t * 0.30) * 7.5);
        c += 0.55 * exp(-voro(p * 1.85 + float2(3.1, 1.7), t * 0.42) * 9.0);
        return c;
    }
    float3 pool(float2 uv, float2 C, float2 R, float ang, float sc, float t, float seed) {
        float2 q = rot(ang) * (uv - C); float2 e = q / R;
        float m = 1.0 - smoothstep(0.45, 1.0, length(e));
        float core = 1.0 - smoothstep(0.0, 0.75, length(e * float2(1.0, 1.15)));
        float2 cp = q * sc; float2 dsp = float2(0.022, 0.008);
        float r = caus(cp * 1.010 + dsp + seed, t); float g = caus(cp + seed, t); float b = caus(cp * 0.990 - dsp + seed, t);
        return float3(r, g, b) * m * (0.55 + 0.65 * core);
    }
    fragment float4 fs_tela(UscitaTela in [[stage_in]], constant UniformiTela &u [[buffer(0)]]) {
        float2 uv = uvTemplate(in.uv, u.risoluzione);
        float N = u.parametri.x;
        float t = u.tempo + u.parametri.y * 6.0;
        float3 paper = paperCol(uv, N);
        float2 s1 = rot(-0.32) * (uv - float2(1.03, 0.26)); float sh1 = 1.0 - smoothstep(0.55, 1.15, length(s1 / float2(0.56, 0.29)));
        float2 s2 = rot(0.25) * (uv - float2(0.28, 0.19)); float sh2 = 1.0 - smoothstep(0.55, 1.15, length(s2 / float2(0.37, 0.19)));
        float shade = 1.0 - 0.06 * max(sh1, sh2);
        float3 L = pool(uv, float2(1.06 + 0.012 * sin(t * 0.05), 0.24), float2(0.50, 0.24), -0.32, 10.0, t, 0.0)
                 + 0.85 * pool(uv, float2(0.30 + 0.01 * cos(t * 0.04), 0.17), float2(0.32, 0.15), 0.25, 12.0, t * 1.1, 17.0)
                 + 0.55 * pool(uv, float2(0.62, 0.95), float2(0.30, 0.10), 0.05, 13.0, t * 0.9, 41.0);
        float glow = smoothstep(1.4, 0.0, length((uv - float2(0.75, 0.7)) * float2(0.55, 1.0)));
        float3 lightC = mix(float3(1.0, 0.97, 0.90), float3(1.0, 0.84, 0.56), N);
        float3 base = paper * shade * mix(mix(0.925, 0.995, glow), mix(0.92, 1.06, glow), N);
        float3 col = base + L * lightC * mix(0.20, 0.14, N);
        col += N * float3(0.035, 0.026, 0.012) * (L.g * 0.35);
        col *= mix(0.90, 1.0, vignetta(uv));
        return float4(col, 1.0);
    }
    """

    /// Carta marmorizzata: le venature d'inchiostro e d'oro che scorrono piano; il tocco lascia una goccia che si allarga.
    static let marmo = comune + """
    float fbm2(float2 p) { return 0.62 * (vn(p) * 2.0 - 1.0) + 0.3 * (vn(rot(0.6435) * p * 2.1 + float2(3.1, 7.7)) * 2.0 - 1.0); }
    float fbm3(float2 p) { float v = 0.0; float a = 0.5; for (int i = 0; i < 3; i++) { v += a * (vn(p) * 2.0 - 1.0); p = rot(0.6435) * p * 2.07 + float2(1.7, 9.2); a *= 0.5; } return v; }
    fragment float4 fs_tela(UscitaTela in [[stage_in]], constant UniformiTela &u [[buffer(0)]]) {
        float2 uv = uvTemplate(in.uv, u.risoluzione);
        float N = u.parametri.x;
        float2 p = uv;
        // La goccia del tocco: il punto in parametri.zw (0…1, in alto a sinistra), la forza in parametri.y
        float2 tocco = uvTemplate(u.parametri.zw, u.risoluzione);
        float r = 0.16 * u.parametri.y;
        float2 v = p - tocco; float dd = length(v);
        float ring = (1.0 - smoothstep(0.0008, 0.0028, abs(dd - r))) * step(0.003, r);
        if (dd > r) { p = tocco + v * sqrt(max(0.0, 1.0 - (r * r) / (dd * dd + 1e-6))); }
        float T = u.tempo * 0.022;
        float2 q = p * 0.95;
        float2 w = float2(fbm2(q * 0.75 + float2(T, -T * 0.5)), fbm2(q * 0.75 + float2(5.2 - T * 0.6, 1.3 + T * 0.3)));
        float2 pp = q + 0.85 * w;
        float f = fbm3(pp * 1.25 + float2(0.0, T * 0.4));
        float f2 = fbm3(pp * 2.7 + float2(4.3 - T * 0.3, 1.1));
        float g = fbm3(pp * 0.9 + float2(9.1 + T * 0.25, 3.7));
        float fw = 0.004; float fw2 = 0.006; float fwg = 0.004;
        float wv = 0.5 + 1.15 * smoothstep(-0.35, 0.45, fbm2(pp * 1.6 + float2(2.0, 5.0)));
        float vein = (1.0 - smoothstep(fw * 0.45 * wv, fw * 1.7 * wv, abs(f))) * mix(0.55, 1.0, wv / 1.65);
        float halo = 1.0 - smoothstep(0.0, 0.09, abs(f));
        float fine = (1.0 - smoothstep(fw2 * 0.5, fw2 * 1.7, abs(f2))) * smoothstep(0.30, 0.02, abs(f));
        float gm = smoothstep(0.08, 0.42, fbm2(q * 0.6 + float2(2.3, T * 0.5)));
        float wg = 0.5 + 1.1 * smoothstep(-0.3, 0.5, fbm2(pp * 1.9 + float2(6.0, 1.0)));
        float gold = (1.0 - smoothstep(fwg * 0.45 * wg, fwg * 1.7 * wg, abs(g))) * gm;
        float gglow = (1.0 - smoothstep(0.0, 0.05, abs(g))) * gm;
        float cloud = fbm2(pp * 0.8 + float2(7.7, 2.2));
        float rad = smoothstep(1.3, 0.0, length((uv - float2(0.8, 0.72)) * float2(0.62, 1.0)));
        float3 paperD = mix(float3(0.830, 0.790, 0.715), float3(0.940, 0.914, 0.866), rad);
        float3 paperN = mix(float3(0.043, 0.043, 0.051), float3(0.124, 0.127, 0.143), rad);
        float3 col = mix(paperD, paperN, N);
        float3 ink = mix(float3(0.150, 0.175, 0.250), float3(0.930, 0.900, 0.840), N);
        float3 au = mix(float3(0.760, 0.560, 0.080), float3(0.913, 0.725, 0.227), N);
        col = mix(col, ink, (0.5 + 0.5 * cloud) * mix(0.045, 0.035, N));
        col = mix(col, ink, halo * mix(0.05, 0.04, N));
        col = mix(col, ink, vein * mix(0.20, 0.13, N));
        col = mix(col, ink, fine * mix(0.09, 0.06, N));
        col = mix(col, au, gglow * mix(0.07, 0.09, N));
        col = mix(col, au, gold * mix(0.52, 0.46, N));
        float3 pen = mix(float3(0.165, 0.290, 0.500), float3(0.620, 0.720, 0.920), N);
        col = mix(col, pen, ring * mix(0.26, 0.30, N));
        float s = uv.x * 0.55 - uv.y * 0.3 - (u.tempo * 0.035 - 2.8 * floor(u.tempo * 0.035 / 2.8)) + 0.7;
        col += mix(float3(0.026), au * 0.035, N) * exp(-s * s * 16.0);
        col *= mix(0.92, 1.0, smoothstep(1.4, 0.3, length((uv - float2(0.8, 0.5)) * float2(0.68, 1.0))));
        return float4(col, 1.0);
    }
    """

    /// Inchiostro: nuvole d'inchiostro blu che si allargano nell'acqua sulla carta; il tocco ne aggiunge una goccia.
    static let inchiostro = comune + """
    fragment float4 fs_tela(UscitaTela in [[stage_in]], constant UniformiTela &u [[buffer(0)]]) {
        float2 uv = uvTemplate(in.uv, u.risoluzione);
        float N = u.parametri.x; float t = u.tempo * 0.05;
        float3 paper = paperCol(uv, N);
        float2 p = uv * 1.6;
        float2 w1 = float2(fbm(p + float2(t, -t * 0.7)), fbm(p + float2(5.2 - t * 0.6, 1.3 + t * 0.4)));
        float2 w2 = float2(fbm(p + 2.2 * w1 + float2(1.7, 9.2) + t * 0.3), fbm(p + 2.2 * w1 + float2(8.3, 2.8) - t * 0.2));
        float f = fbm(p + 2.6 * w2);
        float2 tocco = uvTemplate(u.parametri.zw, u.risoluzione);
        float goccia = u.parametri.y * exp(-dot(uv - tocco, uv - tocco) * 28.0);
        float densita = smoothstep(0.42, 0.78, f + 0.18 * length(w2) + goccia);
        float bordo = smoothstep(0.0, 0.08, densita) * (1.0 - smoothstep(0.08, 0.30, densita));
        float3 ink = mix(float3(0.165, 0.290, 0.500), float3(0.620, 0.720, 0.920), N);
        float3 col = mix(paper, paper * (1.0 - 0.55 * densita) + ink * 0.55 * densita, mix(0.42, 0.30, N));
        col = mix(col, ink, bordo * mix(0.10, 0.12, N));
        col *= mix(0.90, 1.0, vignetta(uv));
        return float4(col, 1.0);
    }
    """

    /// La sorgente dello sfondo scelto (nil = la carta ferma).
    static func sorgente(_ s: SfondoScrivaniaCarta) -> String? {
        switch s {
        case .luce: return luce
        case .cristallo: return cristallo
        case .marmo: return marmo
        case .inchiostro: return inchiostro
        case .fermo: return nil
        }
    }
}

/// La scrivania viva dello stile Carta: lo sfondo scelto in Impostazioni › Aspetto, con la carta ferma come ripiego (nelle
/// istantanee, senza Metal o se lo shader non si compila). Risponde al tocco: le foglie e il cristallo si muovono di
/// più, la carta marmorizzata e l'inchiostro lasciano una goccia dove si tocca.
struct SfondoVivoCarta: View {
    let sfondo: SfondoScrivaniaCarta
    var animato = true
    @Environment(\.colorScheme) private var schema
    @State private var soffio: Float = 0
    @State private var tocco = CGPoint(x: 0.5, y: 0.5)

    var body: some View {
        if let sorgente = ShaderSfondiCarta.sorgente(sfondo), animato {
            GeometryReader { geo in
                TelaShader(sorgente: sorgente,
                           parametri: SIMD4<Float>(schema == .dark ? 1 : 0, soffio, Float(tocco.x), Float(tocco.y))) {
                    SfondoCarta()
                }
                    .contentShape(Rectangle())
                    .onTapGesture(coordinateSpace: .local) { punto in
                        guard geo.size.width > 0, geo.size.height > 0 else { return }
                        tocco = CGPoint(x: punto.x / geo.size.width, y: punto.y / geo.size.height)
                        soffio = 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { soffio = 0 }
                    }
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
        } else {
            SfondoCarta()
        }
    }
}
