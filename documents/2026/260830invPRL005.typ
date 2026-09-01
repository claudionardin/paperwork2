#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  issuer: "axelered_si", // config/issuers/<id>.yaml
  proforma: false,       // true → tag "pin" | false → tag "inv"
  client: "PRL",         // config/clients/<id>.yaml
  seq: 5,                // progressive per (year, client), typed by hand
  revision: "",          // inv → "" always
  language: "en",        // "it" | "en"
  date: "2026-08-30",    // ISO, == the YYMMDD of the file name
  vies: "2026-08-30",    // == date → exempt (PRL is intra-Community, so none → panic)
  valid-until: none,     // pin only
  pay-within: auto,      // auto → issuer default
  deliver-to: "",        // "" → client's registered office
  deliver-within: auto,  // auto → issuer default, and only if the sheet carries goods
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
