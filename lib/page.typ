#import "tokens.typ": *

// Decorative band across the very top of the sheet, edge to edge. Drawn as the page
// background so it bleeds past the margins and repeats on every page.
#let top-band() = place(top + left, dx: 0pt, dy: 0pt, block(width: 100%, height: band-height, {
  place(left, rect(width: 100%, height: band-height, fill: navy))
  place(right, rect(width: band-tail, height: band-height, fill: accent))
}))

// Header: logo left, contacts right aligned. No telephone number.
#let doc-header(data) = {
  set text(size: size-small, fill: muted)
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    {
      let logo = data.assets.at("logo", default: none)
      if logo != none { image(logo, height: 7.5mm) } else { text(size: size-h1, weight: "bold", fill: navy)[#data.issuer.legal_name] }
    },
    {
      set par(leading: 0.5em)
      let contacts = ("website", "email")
        .map(k => data.issuer.at(k, default: none))
        .filter(v => v != none)
      contacts.map(v => text(v)).join(linebreak())
    },
  )
  v(1.4mm)
  line(length: 100%, stroke: 0.5pt + rule)
}

// Footer: confidentiality notice, company legal line, page numbers.
#let doc-footer(data) = context {
  set text(size: size-footer, fill: muted)
  set par(leading: 0.45em, justify: false)
  line(length: 100%, stroke: 0.5pt + rule)
  v(1mm)
  grid(
    columns: (1fr, auto),
    align: (left, right + bottom),
    {
      text(data.footer.confidentiality) + linebreak()
      text(data.footer.legal_line)
    },
    text(data.strings.page + " " + str(here().page()) + "/" + str(counter(page).final().first())),
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
  show heading.where(level: 1): it => block(above: 1.4em, below: 0.8em, text(size: size-h1, weight: "bold", it.body))
  show heading.where(level: 2): it => block(above: 1.2em, below: 0.6em, text(size: size-h2, weight: "bold", it.body))
  show heading.where(level: 3): it => block(above: 1em, below: 0.5em, text(size: size-body, weight: "bold", it.body))
  show link: it => text(fill: ink, it)
  show figure.caption: it => text(size: size-small, fill: muted, it)
  body
}
