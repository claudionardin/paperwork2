// STARTER — invoice and proforma, one sheet: `proforma` decides which.
// Copy to documents/<YYMM_project>/<number>.typ, rename to the number. See NUMBERING.md.
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  language: "en", // "it" | "en"
  issuer: "axelered_si", // config/issuers/<id>.yaml
  client: "XXX", // config/clients/<id>.yaml
  proforma: false, // true → tag "pin" | false → tag "inv"
  seq: 0, // progressive per (year, client), typed by hand
  revision: "", // pin → "a", then "b", "c"… | inv → "" always
  date: "2026-01-01", // ISO, == the YYMMDD of the file name
  vies: "2026-01-01", // "YYYY-MM-DD" == date → exempt | "no" → 22% | none → panic if exempt | anything else → ERROR on the figures
  valid-until: none, // pin only: "YYYY-MM-DD" | none → not printed
  pay-within: auto, // auto → issuer default | <n> days | 0 → already paid, no bank | none → no payment block
  deliver-within: auto, // auto → issuer default, and only if the sheet carries goods | <n> days | 0 → already delivered | none → no delivery block
  deliver-to: "", // "" → client's registered office | any string → printed verbatim
  items: (
    // kind: "service" | "goods" — mandatory
    (desc: "Platform development", price: 3000.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled", price: 2400.00, qty: 2, kind: "goods"),
    (desc: "Commercial discount", price: -400.00, qty: 1, kind: "service"),
  ),
)

// Anything below the arguments prints after the payment details. Usually nothing.
