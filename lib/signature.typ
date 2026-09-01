#import "tokens.typ": *

// Dual signature block. Never splits across pages.
//
// The two columns are one shape used twice: same fields, same labels, same order, same
// geometry — so the sheet states the same things about each party, and states them in the
// same place. The supplier's fields are printed, the client's are ruled lines for a hand.
//
// The fields follow the house label/value list of lib/blocks.typ: labels flush left and muted,
// values in ink, the same gutters. One departure, and it is the point of this block: the label
// column is not `auto` but a measured fixed width, the widest of the three labels in the
// document language. Two `auto` columns would each size to their own contents — the printed
// side carries text and the blank side carries rules, so they would resolve differently and
// the two halves would not line up. Measuring once and handing the same width to both makes
// the halves identical by construction, in any language, with no hardcoded millimetre.
#let signature-block(data) = context {
  let s = data.signature
  let label-style = l => text(size: size-small, fill: muted)[#l]
  let labels = (s.label_name, s.label_title, s.label_place_date)
  let label-width = calc.max(..labels.map(l => measure(label-style(l)).width))

  // Every value sits in the same box, printed or not: one height, one baseline, so a row is
  // the same height on both sides of the block and the two halves keep the same rhythm. A
  // value the client has to write is that box with a rule under it, running the full width of
  // the column so it ends flush with the signature rule above.
  let value-box(body) = box(
    width: 100%,
    height: 1.35em,
    inset: (bottom: 0.8mm),
    stroke: if body == none { (bottom: 0.4pt + muted) } else { none },
    align(left + bottom, if body == none { [] } else { text(size: size-small, fill: ink)[#body] }),
  )

  let fields(p) = grid(
    columns: (label-width, 1fr),
    column-gutter: 3.5mm,
    row-gutter: 0.5em,
    align: (left + bottom, left + bottom),
    ..labels.zip((p.name, p.title, p.place_date)).map(((label, value)) => (
      // the label sits on the same baseline as the value beside it
      box(height: 1.35em, inset: (bottom: 0.8mm), align(left + bottom, label-style(label))),
      value-box(value),
    )).flatten()
  )

  block(breakable: false, {
    v(6mm)
    text(s.intro)
    v(8mm)
    let column(p) = {
      set par(leading: 0.55em, justify: false)
      text(weight: "bold", fill: navy)[#p.party]
      linebreak()
      text(size: size-small, fill: muted)[#p.tag]
      v(10mm)
      if p.sign_image != none { place(dy: -11mm, image(p.sign_image, height: 13mm)) }
      line(length: 100%, stroke: 0.7pt + navy)
      v(2mm)
      fields(p)
    }
    grid(
      columns: (1fr, 1fr),
      column-gutter: 14mm,
      column(s.supplier),
      column(s.client),
    )
  })
}
