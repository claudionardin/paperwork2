#import "/doctypes/offer.typ": offer

#show: offer.with(
  client: "SPR", seq: 2, revision: "a",
  language: "it",
  date: "2026-08-25", valid-until: "2026-09-30",
  clauses: ("contract", "subject", "fixed_price", "validity", "governing_law"),
  items: (
    (desc: "Analisi tecnica e architettura", price: 1500.00, qty: 1, kind: "service"),
    (desc: "Implementazione",                price: 4800.00, qty: 1, kind: "service"),
    (desc: "Sconto commerciale",             price: -500.00, qty: 1, kind: "service"),
  ),
)

= Introduzione

Questa offerta descrive le attività di analisi, sviluppo e messa in esercizio della
piattaforma richiesta. I contenuti tecnici di dettaglio sono raccolti nella specifica
tecnica allegata.

= Ambito di lavoro

- Analisi tecnica e disegno dell'architettura
- Implementazione dei moduli applicativi
- Messa in esercizio e trasferimento di conoscenza