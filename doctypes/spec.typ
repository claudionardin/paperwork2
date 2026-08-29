// Technical specification. The offer sheet without the figures: no items, no totals, no VAT,
// no payment. Long form prose.
#import "/lib/model.typ": build
#import "/lib/page.typ": doc-page
#import "/lib/blocks.typ": title-block, parties-block

#let spec(
  body,
  client: none,
  seq: none,
  revision: none,
  language: none,
  date: none,
) = {
  let data = build(
    tag: "spc",
    client: client, seq: seq, revision: revision,
    language: language, date: date,
  )
  doc-page(data, {
    title-block(data)
    parties-block(data)
    body
  })
}