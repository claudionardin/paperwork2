#import "tokens.typ": *

#let money(data, v) = text(v + " " + data.currency_symbol)

// Priced items. Header repeats on every page, totals never orphan.
#let items-table(data) = {
  if data.items.len() == 0 { return }
  set par(justify: false, leading: 0.55em)
  table(
    columns: (1fr, 26mm, 18mm, 28mm),
    align: (left + top, right + top, right + top, right + top),
    stroke: none,
    inset: (x: 2mm, y: 2mm),
    table.header(
      repeat: true,
      ..([#data.strings.description], [#data.strings.unit_price], [#data.strings.quantity], [#data.strings.price])
        .map(c => text(weight: "bold", size: size-small, fill: muted, c)),
      table.hline(stroke: 0.7pt + ink),
    ),
    ..data.items.map(it => (
      [#it.description],
      money(data, it.unit_price),
      [#it.quantity],
      money(data, it.amount),
    )).flatten(),
    table.hline(stroke: 0.5pt + rule),
  )
}

#let totals-block(data) = block(breakable: false, width: 100%, {
  v(2mm)
  set par(justify: false)
  let row(label, value, bold: false) = grid(
    columns: (1fr, 30mm),
    column-gutter: 4mm,
    align: (right, right),
    text(weight: if bold { "bold" } else { "regular" }, fill: if bold { ink } else { muted })[#label],
    text(weight: if bold { "bold" } else { "regular" })[#value #data.currency_symbol],
  )
  align(right, box(width: 78mm, {
    row(data.strings.subtotal, data.totals.subtotal)
    for l in data.totals.vat_lines { row(l.label, l.amount) }
    v(1.5mm)
    line(length: 100%, stroke: 0.7pt + ink)
    v(1.5mm)
    row(data.strings.total, data.totals.total, bold: true)
  }))
})

// Legal VAT wording. The Slovenian text is printed alongside whenever it exists,
// because it is the legally operative one.
#let vat-notes(data) = {
  if data.vat_notes.len() == 0 { return }
  v(3mm)
  block(breakable: false, {
    set text(size: size-small)
    set par(leading: 0.5em, justify: false)
    for n in data.vat_notes {
      text(n.primary)
      if n.at("slovenian", default: none) != none {
        linebreak()
        text(fill: muted, style: "italic", n.slovenian)
      }
      v(1mm)
    }
  })
}
