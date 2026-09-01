#import "tokens.typ": *

#let money(data, v) = text(v + " " + data.currency_symbol)

// What stands where a figure would, when the figure cannot be trusted. One word, the only
// warm colour on the sheet, so a stale VIES check is seen before anything else on the page.
#let error-figure = text(weight: "bold", fill: alert)[ERROR]

// Priced items, grouped by VAT treatment. Each group closes with its own taxable base, its
// own VAT line and the clause that justifies it, so a mixed document never leaves the reader
// guessing which exemption applies to which line. The grand total closes the table.
// Header repeats on every page.
//
// The table carries no borders. Three weights of fill do the whole of the structure, so the
// eye reads depth instead of counting lines:
//   navy   the head bar and the grand total bar, which frame the table top and bottom
//   panel  the two summary rows that close a group
//   zebra  alternating item rows, the lightest wash there is
#let items-table(data) = {
  if data.items.len() == 0 { return }
  set par(justify: false, leading: 0.55em)

  // Centred in the bar, not top-aligned: a label that wraps to two lines — "Prezzo unitario"
  // does, in Italian — would otherwise leave the single-line labels beside it hanging high.
  let head(c, align) = table.cell(fill: navy, align: align + horizon, inset: (x: 2.6mm, y: 2.4mm))[
    #micro(c, fill: on-navy)
  ]

  let label-cell(body, fill: panel) = table.cell(colspan: 3, fill: fill, align: right)[
    #text(fill: muted, body)
  ]
  let value-cell(body, fill: panel) = table.cell(fill: fill, align: right)[#body]

  // The grand total is a bar, not a row: same navy as the head, so the table closes the way
  // it opened.
  let total-cell(body, colspan: 1, align: right) = table.cell(
    colspan: colspan,
    fill: navy,
    align: align,
    inset: (x: 2.6mm, y: 3mm),
  )[#text(size: size-h2, weight: "bold", fill: on-navy, body)]

  let note-cell(body) = table.cell(colspan: 4, align: right, inset: (x: 2.6mm, top: 1.6mm, bottom: 2.6mm))[
    #text(size: size-small, fill: muted, style: "italic", body)
  ]

  let rows = ()
  for (i, g) in data.groups.enumerate() {
    // Air between one treatment and the next.
    if i > 0 { rows.push(table.cell(colspan: 4, inset: (y: 1.6mm))[]) }
    for (j, it) in g.items.enumerate() {
      // Alternating wash, restarted per group so every group opens on white.
      let tint = if calc.odd(j) { zebra } else { none }
      rows += (
        table.cell(fill: tint)[#it.description],
        table.cell(fill: tint)[#money(data, it.unit_price)],
        table.cell(fill: tint)[#it.quantity],
        table.cell(fill: tint)[#money(data, it.amount)],
      )
    }
    rows.push(label-cell(g.subtotal_label))
    rows.push(value-cell(money(data, g.subtotal)))
    rows.push(label-cell(g.vat_label))
    // Always a figure, zero included: a group that is not taxable charged nothing, and the
    // clause underneath says why.
    rows.push(value-cell(if g.error { error-figure } else { money(data, g.vat_amount) }))
    if g.note != none { rows.push(note-cell(g.note)) }
  }
  rows.push(table.cell(colspan: 4, inset: (y: 1.2mm))[])
  rows.push(total-cell(data.totals.total_label, colspan: 3))
  rows.push(total-cell(
    if data.totals.error { text(fill: on-navy-alert)[ERROR] } else { money(data, data.totals.total) },
  ))

  let columns = (
    (data.strings.description, 1fr, left),
    (data.strings.unit_price, 28mm, right),
    (data.strings.quantity, 18mm, right),
    (data.strings.price, 28mm, right),
  )

  table(
    columns: columns.map(((_, width, _)) => width),
    align: columns.map(((_, _, a)) => a + top),
    stroke: none,
    inset: (x: 2.6mm, y: 2.1mm),
    table.header(
      repeat: true,
      ..columns.map(((label, _, a)) => head(label, a)),
    ),
    ..rows,
  )
}
