// Invoice. Same sheet as the proforma; the title and the tag differ, and an invoice never
// carries a revision letter. NUMBERING.md, rules 8 and 9.
#import "/lib/model.typ": build
#import "/lib/page.typ": doc-page
#import "/lib/blocks.typ": title-block, parties-block, payment-block
#import "/lib/tables.typ": items-table, totals-block, vat-notes

#let invoice(
  body,
  client: none,
  seq: none,
  language: none,
  date: none,
  items: (),
  payment-terms: "net10",
  bank-account: none,
) = {
  let data = build(
    tag: "inv",
    client: client, seq: seq,
    language: language, date: date,
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