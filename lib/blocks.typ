#import "tokens.typ": *

// Title left, document number under it, place and date right. The short accent bar under the
// title and the tinted chip around the number are the two marks that say which sheet this is
// before a word of it is read.
#let title-block(data) = {
  v(3mm)
  grid(
    columns: (1fr, auto),
    align: (left, right + bottom),
    {
      text(size: size-title, weight: "bold", fill: navy)[#data.strings.title]
      v(2.2mm, weak: true)
      block(width: 14mm, height: 2pt, fill: accent)
      v(2.6mm, weak: true)
      box(fill: panel, radius: 1mm, inset: (x: 2.4mm, y: 1.4mm))[
        #text(size: size-small, weight: "bold", fill: navy, tracking: 0.5pt)[#data.number]
      ]
    },
    {
      set par(justify: false)
      block(spacing: 0pt, text(size: size-body, weight: "bold")[#data.place_of_issue, #data.date])
      if data.at("valid_until", default: none) != none {
        v(1.6mm)
        block(spacing: 0pt, text(size: size-small, fill: muted)[#data.valid_until])
      }
    },
  )
  v(7mm)
}

// One party. The heading is a tracked micro label over an accent hairline; the field names in
// front of the tax ids are muted so the identifiers themselves carry the weight.
#let party-block(label, party) = {
  set par(leading: 0.6em, justify: false)
  // Three stacked blocks, not one paragraph: the legal name is set larger than the lines under
  // it, and a linebreak inside a paragraph would leave it sitting on top of the address.
  block(spacing: 0pt, micro(label.trim(":"), fill: accent))
  v(1.4mm)
  block(spacing: 0pt, line(length: 100%, stroke: 0.7pt + rule))
  v(2.6mm)
  block(spacing: 0pt, text(weight: "bold", size: size-h2, fill: navy)[#party.legal_name])
  v(1.8mm)
  block(spacing: 0pt, {
    let id(label, value) = text(fill: muted)[#label ] + text(fill: ink)[#value]
    let ids = (
      ("vat_number", "vat_label"),
      ("tax_code", "tax_label"),
      ("reg_number", "reg_label"),
    )
      .filter(((field, _)) => party.at(field, default: none) != none)
      .map(((field, label)) => id(party.at(label), party.at(field)))
    (party.address + ids).join(linebreak())
  })
}

#let parties-block(data) = {
  grid(
    columns: (1fr, 1fr),
    column-gutter: 10mm,
    party-block(data.strings.supplier, data.issuer),
    party-block(data.strings.client, data.client),
  )
  v(9mm)
}

// A label/value pair list, the shape both terms panels are built from. The labels are muted
// and the values bold, so a panel scans as a column of facts.
#let field-list(..pairs) = grid(
  columns: (auto, 1fr),
  column-gutter: 3.5mm,
  row-gutter: 0.75em,
  ..pairs.pos().map(((label, value)) => (text(fill: muted)[#label], text(weight: "bold")[#value])).flatten(),
)

// The heading of a terms panel: the same tracked micro label the party blocks carry, so the
// two bands of the sheet are titled the same way.
#let panel-title(label) = {
  block(spacing: 0pt, micro(label, fill: accent))
  v(2.8mm)
}

// Terms first, then the facts they need: what to pay into, or where to send the goods. One
// field-list per panel, so every label in it shares a column.
#let payment-panel(data) = soft-panel({
  set par(justify: false, leading: 0.6em)
  panel-title(data.strings.payment)
  // Nothing is due on an already paid document, so no bank details are printed.
  let account = if not data.payment.show_account { () } else {
    (
      (data.strings.headed_to, data.payment.holder),
      (data.strings.iban, data.payment.iban),
      (data.strings.swift, data.payment.swift),
    )
  }
  field-list((data.strings.terms, data.payment.sentence), ..account)
})

// When the goods go, and where. Same panel as the bank details beside it.
#let delivery-panel(data) = soft-panel({
  set par(justify: false, leading: 0.6em)
  panel-title(data.strings.delivery)
  field-list(
    (data.strings.terms, data.delivery.terms),
    (data.strings.destination, data.delivery.destination.join(linebreak())),
  )
})

// Payment and delivery, side by side when the document has both and full width when it has
// one. The two panels stretch to a common height, so the pair reads as one band closing the
// figures above it.
#let terms-block(data) = {
  let panels = ()
  if data.at("payment", default: none) != none { panels.push(payment-panel(data)) }
  if data.at("delivery", default: none) != none { panels.push(delivery-panel(data)) }
  if panels.len() == 0 { return }
  v(8mm)
  // The delivery panel gets the wider half: a destination is a whole postal address, where a
  // bank account is three short values.
  block(breakable: false, grid(
    columns: if panels.len() == 2 { (1fr, 1.25fr) } else { (1fr,) },
    column-gutter: 5mm,
    ..panels,
  ))
}
