// Technical specification. The offer sheet without the figures: no items, no totals, no VAT,
// no payment. Long form prose.
#import "/lib/model.typ": build
#import "/lib/page.typ": doc-page
#import "/lib/blocks.typ": title-block, parties-block

#let spec(
  body,
  issuer: none,      // a file name in config/issuers/, without .yaml; none takes the default
  client: none,
  seq: none,
  revision: none,
  language: none,
  date: none,
) = {
  let data = build(
    tag: "spc",
    issuer: issuer, client: client, seq: seq, revision: revision,
    language: language, date: date,
  )
  doc-page(data, {
    title-block(data)
    parties-block(data)
    body
  })
}