// FIXTURE — cases 5 and 6, b2b_eu_goods + b2b_eu_service. Two exempt groups and the only
// fixture that needs `vies-checked`; blank it or move it off `date` and the engine refuses.
// The VAT id in config/clients/EEE.yaml is invented, so this proves the wiring, not the id.
//   .\render.ps1 documents\fixtures\260831invEEE001.typ
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",
  proforma: false,
  client: "EEE",
  seq: 1,
  revision: "",
  vies-checked: "2026-08-31",
  language: "en",
  date: "2026-08-31",
  pay-within: auto,
  deliver-within: auto,
  items: (
    (desc: "Deployment engineering", price: 2600.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled", price: 2400.00, qty: 3, kind: "goods"),
  ),
)
