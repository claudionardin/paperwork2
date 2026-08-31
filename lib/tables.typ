#import "tokens.typ": *

#let money(data, v) = text(v + " " + data.currency_symbol)

// Priced items, grouped by VAT treatment. Each group closes with its own taxable base, its
// own VAT line and the clause that justifies it, so a mixed document never leaves the reader
// guessing which exemption applies to which line. The grand total closes the table.
// Header repeats on every page.
#let items-table(data) = {
  if data.items.len() == 0 { return }
  set par(justify: false, leading: 0.55em)

  let head(c) = text(weight: "bold", size: size-small, fill: muted, tracking: 0.3pt, upper(c))
  let label-cell(body, bold: false) = table.cell(colspan: 3, align: right)[
    #text(weight: if bold { "bold" } else { "regular" }, fill: if bold { ink } else { muted }, body)
  ]
  let value-cell(body, bold: false) = table.cell(align: right)[
    #text(weight: if bold { "bold" } else { "regular" }, body)
  ]
  let note-cell(body) = table.cell(colspan: 4, align: right, inset: (x: 2mm, top: 0mm, bottom: 2.4mm))[
    #text(size: size-small, fill: muted, style: "italic", body)
  ]

  let rows = ()
  for (i, g) in data.groups.enumerate() {
    // Air between one treatment and the next.
    if i > 0 { rows.push(table.cell(colspan: 4, inset: (y: 1.4mm))[]) }
    for it in g.items {
      rows += (
        [#it.description],
        money(data, it.unit_price),
        [#it.quantity],
        money(data, it.amount),
      )
    }
    rows.push(table.hline(stroke: 0.4pt + rule))
    rows.push(label-cell(g.subtotal_label))
    rows.push(value-cell(money(data, g.subtotal)))
    rows.push(label-cell(g.vat_label))
    // Always a figure, zero included: a group that is not taxable charged nothing, and the
    // clause underneath says why.
    rows.push(value-cell(money(data, g.vat_amount)))
    if g.note != none { rows.push(note-cell(g.note)) }
  }
  rows.push(table.hline(stroke: 0.7pt + navy))
  rows.push(label-cell(data.totals.total_label, bold: true))
  rows.push(value-cell(money(data, data.totals.total), bold: true))
  rows.push(table.hline(stroke: 0.7pt + navy))

  table(
    columns: (1fr, 26mm, 18mm, 28mm),
    align: (left + top, right + top, right + top, right + top),
    stroke: none,
    inset: (x: 2mm, y: 2mm),
    table.header(
      repeat: true,
      ..([#data.strings.description], [#data.strings.unit_price], [#data.strings.quantity], [#data.strings.price]).map(head),
      table.hline(stroke: 0.7pt + navy),
    ),
    ..rows,
  )
}
