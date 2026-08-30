// The cascade of lib/vat.typ, branch by branch, in the order it evaluates them. A test file
// that compiles has passed.
//   typst compile --root . tests/vat.typ
#import "/lib/vat.typ": resolve

// `code` is not a field of a client file: it is the file name, and lib/model.typ adds it to the
// record before calling in, so a refusal can name the file to fix. The fixture mirrors that.
#let cli(country, vat: none, business: true) = (
  code: "XXX",
  country: country,
  vat_number: vat,
  is_business: business,
)

// 1. Slovenia. Both outcomes are 22% with no clause; the id is what tells them apart.
#assert.eq(resolve("SI", cli("SI", vat: "SI12345678"), "service"), "b2b_si")
#assert.eq(resolve("SI", cli("SI", vat: "SI12345678"), "goods"), "b2b_si")
#assert.eq(resolve("SI", cli("SI", business: false), "service"), "b2c")

// 2. Goods leaving the Union are an export whoever buys them: ZDDV-1 52(1)(a) hangs the
//    exemption on the goods leaving, so this outranks the consumer test below it. The second
//    assertion is the one the old engine got wrong, charging 22% on an exempt export.
#assert.eq(resolve("SI", cli("RS", vat: "RS100000000"), "goods"), "export_goods")
#assert.eq(resolve("SI", cli("RS", business: false), "goods"), "export_goods")

// 3. Services to a business outside the Union follow the customer, ZDDV-1 25(1).
#assert.eq(resolve("SI", cli("AE"), "service"), "noneu_service")

// 4. Services to a consumer outside the Union split on ZDDV-1 30.d against 25(2) and the
//    engine refuses. Not assertable: panic() aborts compilation and is not catchable.
//      resolve("SI", cli("US", business: false), "service")  ⇒ must panic

// 5, 6. Rest of the Union with a VAT id: the kind decides.
#assert.eq(resolve("SI", cli("IT", vat: "IT01313650325"), "goods"), "b2b_eu_goods")
#assert.eq(resolve("SI", cli("IT", vat: "IT01313650325"), "service"), "b2b_eu_service")

// 7. No VAT id means Slovenian VAT, whether or not the client calls itself a business: there
//    is nothing to reverse the charge to.
#assert.eq(resolve("SI", cli("IT", business: false), "service"), "b2c")
#assert.eq(resolve("SI", cli("DE"), "goods"), "b2c")

// Two more refusals that cannot be asserted here, for the same reason. Verified by hand once,
// then written down:
//
//   resolve("SI", cli("IT", vat: "IT01313650325"), "licence")
//     ⇒ must panic: kind is "goods" or "service" and nothing else.
//
//   a non-EU client whose file has no is_business, on a service
//     ⇒ must panic. Outside the EU that field alone decides, and there is no VIES to fall
//       back on, so an absent one is an unanswered question, not a consumer.
//
//   an exemption whose clause text is empty for the document language
//     ⇒ must panic, not print a silent blank. Only --input draft=true may render it,
//       and then it prints a visible [MISSING VAT CLAUSE] marker.
