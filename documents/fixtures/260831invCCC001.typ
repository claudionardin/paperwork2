// FIXTURE — cases 2 and 3 on one sheet, export_goods + noneu_service. Two exempt groups, two
// clauses, no VAT figure anywhere and a grand total equal to the sum of the bases.
//   .\render.ps1 documents\fixtures\260831invCCC001.typ
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",
  proforma: false,
  client: "CCC",
  seq: 1,
  revision: "",
  language: "en",
  date: "2026-08-31",
  pay-within: auto,
  deliver-within: auto,
  items: (
    (desc: "Systems integration consultancy", price: 4500.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled", price: 2400.00, qty: 2, kind: "goods"),
    (desc: "Volume discount, hardware", price: -400.00, qty: 1, kind: "goods"),
  ),
)
