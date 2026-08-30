// STARTER — invoice and proforma invoice. They are the same sheet, so they share one starter:
// `proforma` decides which one it is. Copy to documents/<year>/<number>.typ and rename to the
// number you chose. See NUMBERING.md.
#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",  // a file name in config/issuers/, without .yaml
  proforma: false,    // true → tag "pin", title "Proforma Invoice"; false → tag "inv", "Invoice"
  client: "PRL",      // a file name in config/clients/, without .yaml
  seq: 2,             // progressive per (year, client), typed by hand
  revision: "",       // a proforma always starts at "a": the client can still ask for a change,
                      // and the next version is "b", "c"… An invoice never carries one, so
                      // leave it empty. An invoice number is never reused.
  vies-checked: none, // ISO date of the VIES check. It must equal `date` below, because a
                      // check made a week ago proves nothing about today. Required only when
                      // the document exempts an intra-Community supply, and then the engine
                      // refuses without it. Query VIES again for every document
  language: "en",     // "it" or "en"
  date: "2026-08-30", // issue date, ISO. Must match the YYMMDD of the file name
  valid-until: none,  // proforma only, e.g. "2026-09-30"
  pay-within: auto,   // auto → the house default in days, from the issuer profile.
                      // Or a number of days: 0 prints "already paid" and no bank details
  deliver-to: "",     // empty → the client's registered office. Anything else prints verbatim
  deliver-within: auto, // auto → the delivery box appears only when the document carries goods,
                      // with the house default in days. Or a number: 0 prints "already
                      // delivered", none never prints the box at all
  items: (
    // kind is mandatory: "service" or "goods". It decides the VAT treatment.
    (desc: "Platform development",   price: 3000.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled", price: 2400.00, qty: 2, kind: "goods"),
  ),
)

// Anything written below the arguments prints after the payment details. Usually nothing.
