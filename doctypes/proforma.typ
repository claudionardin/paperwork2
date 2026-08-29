// Proforma invoice. Prices, totals, VAT wording, payment details. Any prose the author adds
// follows the figures.
#import "/lib/model.typ": build
#import "/lib/page.typ": doc-page
#import "/lib/blocks.typ": title-block, parties-block, payment-block
#import "/lib/tables.typ": items-table, totals-block, vat-notes

#let proforma(
  body,
  client: none,
  seq: none,
  revision: none,
  language: none,
  date: none,
  valid-until: none,
  items: (),
  payment-terms: "net10",
  bank-account: none,
) = {
  let data = build(
    tag: "pin",
    client: client, seq: seq, revision: revision,
    language: language, date: date, valid-until: valid-until,
    items: items, payment-terms: payment-terms, bank-account: bank-account,
  )
  doc-page(data, {
    title-block(data)
    parties-block(data)
    items-table(data)
    totals-block(data)
    vat-notes(data)
    payment-block(data)
    body
  })
}