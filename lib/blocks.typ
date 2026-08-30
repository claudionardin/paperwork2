#import "tokens.typ": *

// Title left, document number under it, place and date right.
#let title-block(data) = {
  v(4mm)
  grid(
    columns: (1fr, auto),
    align: (left, right + bottom),
    {
      text(size: size-title, weight: "bold", fill: navy)[#data.strings.title]
      linebreak()
      v(0.4mm)
      text(size: size-body, fill: muted, tracking: 0.3pt)[#data.number]
    },
    {
      text(size: size-body)[#data.place_of_issue, #data.date]
      if data.at("valid_until", default: none) != none {
        linebreak()
        text(size: size-small, fill: muted)[#data.valid_until]
      }
    },
  )
  v(5mm)
}

#let party-block(label, party) = {
  set par(leading: 0.55em, justify: false)
  text(weight: "bold", size: size-small, fill: muted)[#label]
  linebreak()
  v(0.6mm)
  text(weight: "bold")[#party.legal_name]
  linebreak()
  for l in party.address { [#l] + linebreak() }
  if party.at("vat_number", default: none) != none { [#party.vat_label #party.vat_number] + linebreak() }
  if party.at("tax_code", default: none) != none { [#party.tax_label #party.tax_code] + linebreak() }
  if party.at("reg_number", default: none) != none { [#party.reg_label #party.reg_number] }
}

#let parties-block(data) = {
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8mm,
    party-block(data.strings.supplier, data.issuer),
    party-block(data.strings.customer, data.client),
  )
  v(6mm)
}

#let payment-block(data) = {
  if data.at("payment", default: none) == none { return }
  block(breakable: false, {
    v(2mm)
    text(data.payment.sentence)
    // Nothing is due on an already paid document, so no bank details are printed.
    if not data.payment.show_account { return }
    v(2mm)
    grid(
      columns: (auto, 1fr),
      column-gutter: 4mm,
      row-gutter: 0.6em,
      text(fill: muted)[#data.strings.headed_to], text(weight: "bold")[#data.payment.holder],
      text(fill: muted)[#data.strings.iban], text(weight: "bold")[#data.payment.iban],
      text(fill: muted)[#data.strings.swift], text(weight: "bold")[#data.payment.swift],
    )
  })
}

// Where the goods go and when. Same two-column shape as the bank details above it.
#let delivery-block(data) = {
  if data.at("delivery", default: none) == none { return }
  block(breakable: false, {
    v(4mm)
    grid(
      columns: (auto, 1fr),
      column-gutter: 4mm,
      row-gutter: 0.6em,
      text(fill: muted)[#data.strings.delivery_destination], text(weight: "bold")[#data.delivery.destination],
      text(fill: muted)[#data.strings.delivery_terms], text(weight: "bold")[#data.delivery.terms],
    )
  })
}
