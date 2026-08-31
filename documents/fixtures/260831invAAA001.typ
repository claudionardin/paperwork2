// FIXTURE — case 1, b2b_si. Slovenian business: 22% on one group, goods and services together.
//   .\render.ps1 documents\fixtures\260831invAAA001.typ
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",
  proforma: false,
  client: "AAA",
  seq: 1,
  revision: "",
  language: "en",
  date: "2026-08-31",
  pay-within: auto,
  deliver-within: auto,
  items: (
    (desc: "Platform development", price: 3000.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled", price: 2400.00, qty: 2, kind: "goods"),
  ),
)
