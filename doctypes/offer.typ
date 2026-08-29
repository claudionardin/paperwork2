// Offer. The proforma sheet, then the prose, then the numbered clauses, then the dual
// signature block.
#import "/lib/model.typ": build
#import "/lib/page.typ": doc-page
#import "/lib/blocks.typ": title-block, parties-block, payment-block
#import "/lib/tables.typ": items-table, totals-block, vat-notes
#import "/lib/clauses.typ": clauses-block
#import "/lib/signature.typ": signature-block

#let offer(
  body,
  client: none,
  seq: none,
  revision: none,
  language: none,
  date: none,
  valid-until: none,
  items: (),
  clauses: (),
  signature: true,
  payment-terms: "net10",
  bank-account: none,
) = {
  let data = build(
    tag: "off",
    client: client, seq: seq, revision: revision,
    language: language, date: date, valid-until: valid-until,
    items: items, clauses: clauses, signature: signature,
    payment-terms: payment-terms, bank-account: bank-account,
  )
  doc-page(data, {
    title-block(data)
    parties-block(data)
    items-table(data)
    totals-block(data)
    vat-notes(data)
    payment-block(data)

    if body != none { pagebreak() + body }
    if data.clauses.len() > 0 { pagebreak() + clauses-block(data) }
    if data.signature != none { signature-block(data) }
  })
}