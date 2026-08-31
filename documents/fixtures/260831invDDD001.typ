// FIXTURE — case 2 to a consumer, export_goods. Goods only: the exemption follows the goods
// leaving, not the buyer. Add a `kind: "service"` line and the engine must refuse to compile —
// that is case 4, ZDDV-1 30.d against 25(2), and the refusal is the feature.
//   .\render.ps1 documents\fixtures\260831invDDD001.typ
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",
  proforma: false,
  client: "DDD",
  seq: 1,
  revision: "",
  language: "en",
  date: "2026-08-31",
  pay-within: auto,
  deliver-within: auto,
  items: (
    (desc: "Workstation, shipped DAP", price: 1750.00, qty: 1, kind: "goods"),
  ),
)
