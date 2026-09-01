#import "tokens.typ": *

// Decorative band across the very top of the sheet, edge to edge. Drawn as the page
// background so it bleeds past the margins and repeats on every page.
//
// It is one grid, not two placed rectangles: the two runs share an edge instead of being
// stacked, so no seam can appear between them. The whole thing is over-drawn by `band-bleed`
// on each side, because a shape that stops exactly on the trim leaves a white hairline in
// some PDF viewers at some zoom levels.
#let top-band() = place(
  top + left,
  dx: -band-bleed,
  dy: 0pt,
  block(width: 100% + 2 * band-bleed, height: band-height, {
    let run(colour) = rect(width: 100%, height: 100%, fill: colour, stroke: none)
    grid(
      columns: (1fr, band-tail),
      rows: (band-height,),
      run(navy),
      run(accent),
    )
  }),
)

// The logo ships with `fill="currentColor"` so it takes the house colour rather than carrying
// one of its own. Typst has no way to restyle an SVG once loaded, so the substitution happens
// on the source text and the result is decoded from memory.
#let house-logo(path, height: 7.5mm) = image(
  bytes(read(path).replace("currentColor", navy.to-hex())),
  format: "svg",
  height: height,
)

// Header: logo left, contacts right aligned. No telephone number.
#let doc-header(data) = {
  set text(size: size-small, fill: muted)
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    {
      let logo = data.assets.at("logo", default: none)
      if logo != none { house-logo(logo) } else {
        text(size: size-h1, weight: "bold", fill: navy)[#data.issuer.legal_name]
      }
    },
    {
      set par(leading: 0.5em)
      let contacts = ("website", "email")
        .map(k => data.issuer.at(k, default: none))
        .filter(v => v != none)
      contacts.map(v => text(v)).join(linebreak())
    },
  )
  v(2mm)
  tick-rule()
}

// Footer: confidentiality notice, company legal line, page numbers.
#let doc-footer(data) = context {
  set text(size: size-footer, fill: muted)
  set par(leading: 0.45em, justify: false)
  tick-rule()
  v(1.4mm)
  grid(
    columns: (1fr, auto),
    align: (left, right + bottom),
    {
      text(data.footer.confidentiality) + linebreak()
      text(data.footer.legal_line)
    },
    text(
      fill: navy,
      weight: "bold",
      data.strings.page + " " + str(here().page()) + "/" + str(counter(page).final().first()),
    ),
  )
}

#let doc-page(data, body) = {
  set document(title: data.strings.title + " " + data.number, author: data.issuer.legal_name)
  set page(
    paper: "a4",
    margin: page-margin,
    background: top-band(),
    header: doc-header(data),
    header-ascent: 6mm,
    footer: doc-footer(data),
    footer-descent: 6mm,
  )
  set text(font: font-body, size: size-body, fill: ink, lang: data.language)
  set par(justify: true, leading: 0.65em, spacing: 0.9em)
  show heading.where(level: 1): it => block(above: 1.6em, below: 0.8em, {
    text(size: size-h1, weight: "bold", fill: navy, it.body)
  })
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.6em, {
    text(size: size-h2, weight: "bold", fill: navy, it.body)
  })
  show heading.where(level: 3): it => block(above: 1em, below: 0.5em, text(size: size-body, weight: "bold", it.body))
  // Tables written in the prose of a document. The items table specifies its own `stroke` and
  // `inset`, and paints its own cells, so a set rule cannot reach it: only a bare table in the
  // body takes these. Horizontal rules alone, a heavier one under the head — the same reading
  // of depth the items table gets from its three weights of fill.
  set table(
    stroke: (x, y) => (bottom: if y == 0 { 0.8pt + navy } else { 0.4pt + rule }),
    inset: (x: 2.6mm, y: 2mm),
  )
  show table.cell.where(y: 0): set text(weight: "bold", fill: navy)

  show link: it => text(fill: accent, it)
  show figure.caption: it => text(size: size-small, fill: muted, it)
  body
}
