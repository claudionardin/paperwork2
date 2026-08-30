#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si",  // a file name in config/issuers/, without .yaml
  proforma: false,    // true → tag "pin", title "Proforma Invoice"; false → tag "inv", "Invoice"
  client: "PRL",      // a file name in config/clients/, without .yaml
  seq: 5,             // progressive per (year, client), typed by hand
  revision: "",       // an invoice never carries one, and its number is never reused
  language: "en",     // "it" or "en"
  date: "2026-08-30", // issue date, ISO. Must match the YYMMDD of the file name
  vies-checked: "2026-08-30", // ISO, and it must equal `date`. PRL is an intra-Community
                      // exemption, so the engine refuses this document without it
  valid-until: none,  // proforma only, e.g. "2026-09-30"
  pay-within: auto,   // auto → the house default in days, from the issuer profile.
                      // Or a number of days: 0 prints "already paid" and no bank details
  deliver-to: "",     // empty → the client's registered office. Anything else prints verbatim
  deliver-within: auto, // auto → the delivery box appears only when the document carries goods,
                      // with the house default in days. Or a number: 0 prints "already
                      // delivered", none never prints the box at all
  items: (
    // kind is mandatory: "service" or "goods". It decides the VAT treatment, and here it
    // splits the sheet into two groups: the services are a reverse charge, the goods are an
    // exempt intra-Community supply. Each group prints its own base, VAT line and clause.
    (desc: "Platform development",        price: 3000.00, qty: 1, kind: "service"),
    (desc: "Deployment and handover",     price: 900.00,  qty: 1, kind: "service"),
    (desc: "Rack server 2U, assembled",   price: 2400.00, qty: 2, kind: "goods"),
    (desc: "Switch 24-port, rack-mount",  price: 640.00,  qty: 1, kind: "goods"),
  ),
)

// Anything written below the arguments prints after the payment details. Usually nothing.
