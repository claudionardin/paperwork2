// FIXTURE — case 2 again, export_goods, but from a client file that never answered whether it
// is a business. Goods return before `is_business` is read, so this compiles. Add a
// `kind: "service"` line and the engine must refuse, naming config/clients/GGG.yaml.
//   .\render.ps1 documents\fixtures\260831invGGG001.typ
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",
  proforma: false,
  client: "GGG",
  seq: 1,
  revision: "",
  language: "en",
  date: "2026-08-31",
  pay-within: auto,
  deliver-within: auto,
  items: (
    (desc: "Rack server, assembled", price: 2400.00, qty: 4, kind: "goods"),
  ),
)
