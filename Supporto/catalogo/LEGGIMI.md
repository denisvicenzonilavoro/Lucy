# Catalogo dei prodotti (Lucy per il Mac)

Il catalogo dei prodotti delle principali compagnie in Italia (investimento e risparmio, protezione, previdenza), preparato dall'utente in `catalogo_lucy.xlsx`. Sono dati pubblici: entrano nell'app come risorsa (`Sources/Prisma/Risorse/Catalogo/catalogo.json`) e restano sul Mac, nessun server.

Aggiornare: sostituire `catalogo_lucy.xlsx` e lanciare dalla cartella del repository

    python3 Supporto/catalogo/converti_catalogo.py --versione N

Lo script (solo libreria standard di Python) scrive `catalogo.json` con versione e data (presa dal foglio Leggimi) e `report-celle-non-convertite.csv`, le celle il cui testo non si trasforma in numero con certezza. Regola: nessun numero inventato; ogni cella resta anche come testo originale e un valore che manca resta «dato non disponibile nel catalogo».
