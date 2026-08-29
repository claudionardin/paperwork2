// STARTER — proforma invoice. Copy to documents/<year>/<number>.typ and rename to the number
// you chose. Tag "pin". Carries a revision letter. See NUMBERING.md.
#import "/doctypes/proforma.typ": proforma

#show: proforma.with(
  client: "PRL", // a file name in config/clients/, without .yaml
  seq: 1, // progressive per (year, client), typed by hand
  revision: "a",
  language: "it", // "it" or "en"
  date: "2026-08-27", // issue date, ISO. Must match the YYMMDD of the file name
  valid-until: "2026-09-30",
  items: (
    // kind is mandatory: "service" or "goods". It decides the VAT treatment.
    (desc: "Sviluppo piattaforma", price: 3000.00, qty: 1, kind: "service"),
  ),
)
