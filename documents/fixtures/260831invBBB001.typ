// FIXTURE — case 7 at home, b2c. Slovenian consumer: 22%, one group, no clause.
//   .\render.ps1 documents\fixtures\260831invBBB001.typ
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",
  proforma: false,
  client: "BBB",
  seq: 1,
  revision: "",
  language: "en",
  date: "2026-08-31",
  pay-within: auto,
  deliver-within: auto,
  items: (
    (desc: "Website maintenance, yearly", price: 900.00, qty: 1, kind: "service"),
    (desc: "Laptop dock", price: 180.00, qty: 1, kind: "goods"),
  ),
)
