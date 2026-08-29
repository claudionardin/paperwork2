// STARTER — invoice. Copy to documents/<year>/<number>.typ and rename to the number you chose.
// Tag "inv". NEVER carries a revision letter, and its number is never reused. NUMBERING.md
// rules 5 and 6.
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  client: "PRL", // a file name in config/clients/, without .yaml
  seq: 2, // progressive per (year, client), typed by hand
  language: "en", // "it" or "en"
  date: "2026-08-27", // issue date, ISO. Must match the YYMMDD of the file name
  items: (
    // kind is mandatory: "service" or "goods". It decides the VAT treatment.
    (desc: "Platform development", price: 3000.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled", price: 2400.00, qty: 2, kind: "goods"),
  ),
)

// Anything written below the arguments prints after the payment details. Usually nothing.
