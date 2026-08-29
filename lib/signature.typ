#import "tokens.typ": *

// Dual signature block. Never splits across pages.
#let signature-block(data) = {
  let s = data.signature
  block(breakable: false, {
    v(6mm)
    text(s.intro)
    v(8mm)
    let column(party, role, place-date, sign-image) = {
      set par(leading: 0.55em, justify: false)
      text(weight: "bold")[#party.legal_name]
      linebreak()
      text(size: size-small, fill: muted)[#role]
      v(10mm)
      if sign-image != none { place(dy: -11mm, image(sign-image, height: 13mm)) }
      line(length: 100%, stroke: 0.5pt + ink)
      v(1mm)
      text(size: size-small, fill: muted)[#place-date]
    }
    grid(
      columns: (1fr, 1fr),
      column-gutter: 14mm,
      column(data.issuer, s.supplier_role, s.supplier_place_date, s.at("sign_image", default: none)),
      column(data.client, s.client_party, s.client_place_date, none),
    )
  })
}
