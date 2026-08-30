// Invoice, and its proforma twin. The two sheets are identical, so one doctype prints both:
// `proforma: true` switches the tag to "pin" and the title with it. An invoice never carries a
// revision letter, a proforma does. NUMBERING.md, rules 8 and 9.
#import "/lib/model.typ": build
#import "/lib/page.typ": doc-page
#import "/lib/blocks.typ": title-block, parties-block, payment-block, delivery-block
#import "/lib/tables.typ": items-table

#let invoice(
  body,
  issuer: none,      // a file name in config/issuers/, without .yaml; none takes the default
  client: none,
  seq: none,
  revision: none,
  proforma: false,
  language: none,
  date: none,
  valid-until: none,
  items: (),
  vies-checked: none, // required when the document exempts an intra-Community supply
  pay-within: auto,
  bank-account: none,
  deliver-to: "",
  deliver-within: auto,
) = {
  let data = build(
    tag: if proforma { "pin" } else { "inv" },
    issuer: issuer, client: client, seq: seq, revision: revision,
    language: language, date: date, valid-until: valid-until,
    items: items, vies-checked: vies-checked, pay-within: pay-within, bank-account: bank-account,
    deliver-to: deliver-to, deliver-within: deliver-within,
  )
  doc-page(data, {
    title-block(data)
    parties-block(data)
    items-table(data)
    payment-block(data)
    delivery-block(data)
    body
  })
}
