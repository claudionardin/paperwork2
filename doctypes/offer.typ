// Offer. The proforma sheet, then the prose, then the numbered clauses, then the dual
// signature block. The clause block is fixed: config/clauses/offer.<lang>.yaml, all of it,
// in order. A document neither chooses nor reorders it.
#import "/lib/model.typ": build
#import "/lib/page.typ": doc-page
#import "/lib/blocks.typ": title-block, parties-block, terms-block
#import "/lib/tables.typ": items-table
#import "/lib/clauses.typ": clauses-block
#import "/lib/signature.typ": signature-block

#let offer(
  body,
  issuer: none,      // a file name in config/issuers/, without .yaml; none takes the default
  client: none,
  seq: none,
  revision: none,
  language: none,
  date: none,
  valid-until: none,
  items: (),
  vies: none, // "YYYY-MM-DD" equal to date, or "no", or none. See lib/model.typ
  signature: true,
  pay-within: auto,
  bank-account: none,
  deliver-to: "",
  deliver-within: auto,
) = {
  let data = build(
    tag: "off",
    issuer: issuer, client: client, seq: seq, revision: revision,
    language: language, date: date, valid-until: valid-until,
    items: items, vies: vies, signature: signature,
    pay-within: pay-within, bank-account: bank-account,
    deliver-to: deliver-to, deliver-within: deliver-within,
  )
  doc-page(data, {
    title-block(data)
    parties-block(data)
    items-table(data)
    terms-block(data)

    if body != none { pagebreak() + body }
    pagebreak() + clauses-block(data)
    if data.signature != none { signature-block(data) }
  })
}