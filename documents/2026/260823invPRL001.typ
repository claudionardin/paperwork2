#import "/doctypes/invoice.typ": invoice

#show: invoice.with(
  client: "PRL", seq: 1,
  language: "en",
  date: "2026-08-23",
  items: (
    (desc: "Platform development",     price: 3000.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled",   price: 2400.00, qty: 2, kind: "goods"),
  ),
)