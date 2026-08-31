// FIXTURE — case 7 abroad, b2c. An Italian company without a VAT id is a consumer to the
// engine: 22% Slovenian VAT, same as BBB. Italian language, so the number formatting and the
// labels differ from the sheets above.
//   .\render.ps1 documents\fixtures\260831invFFF001.typ
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",
  proforma: false,
  client: "FFF",
  seq: 1,
  revision: "",
  language: "it",
  date: "2026-08-31",
  pay-within: auto,
  deliver-within: auto,
  items: (
    (desc: "Analisi tecnica e architettura", price: 1500.00, qty: 1, kind: "service"),
    (desc: "Server rack 2U", price: 2200.00, qty: 1, kind: "goods"),
  ),
)
