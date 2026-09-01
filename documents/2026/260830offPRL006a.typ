// Offer 260830offPRL006a — Project Lab Srls. Tag "off", revision "a". See NUMBERING.md.
#import "/doctypes/offer.typ": offer

#show: offer.with(
  issuer: "axelered_si",     // config/issuers/<id>.yaml
  client: "PRL",             // config/clients/<id>.yaml
  seq: 6,                    // progressive per (year, client), typed by hand
  revision: "a",             // then "b", "c"…
  vies: "no",                // "no" → 22%. TODO query IT01313650325 on the day this goes out;
                             // if VIES validates it, write "2026-08-30" here instead
  language: "en",            // "it" | "en"
  date: "2026-08-30",        // ISO, == the YYMMDD of the file name
  valid-until: "2026-09-30",
  items: (
    // kind is mandatory: "service" or "goods". It decides the VAT treatment.
    (desc: "Analisi tecnica e architettura", price: 1500.00, qty: 1, kind: "service"),
    (desc: "Implementazione", price: 4800.00, qty: 1, kind: "service"),
    // A discount is an ordinary line with a negative price.
    // (desc: "Sconto commerciale",          price: -500.00, qty: 1, kind: "service"),
  ),
)

= Introduzione

Prosa. Il resto del documento è calcolato: totali, IVA, clausole, numerazione.

= Ambito di lavoro

- Primo punto
- Secondo punto
