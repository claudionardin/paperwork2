// Every scenario the previous engine covered. A test file that compiles has passed.
//   typst compile --root . tests/vat.typ
#import "/lib/vat.typ": resolve

#let cli(country, vat: none, business: true, pa: false) = (
  code: "XXX",
  country: country,
  vat_number: vat,
  is_business: business,
  is_public_administration: pa,
)

// Domestic.
#assert.eq(resolve("SI", cli("SI", vat: "SI123"), "service"), "domestic")
#assert.eq(resolve("SI", cli("SI", vat: "SI123"), "goods"), "domestic")
#assert.eq(resolve("SI", cli("SI", pa: true), "service"), "public_administration")

// EU business with a VAT id: the kind decides.
#assert.eq(resolve("SI", cli("IT", vat: "IT01313650325"), "service"), "eu_b2b_service")
#assert.eq(resolve("SI", cli("IT", vat: "IT01313650325"), "goods"), "eu_b2b_goods")

// No VAT id means Slovenian VAT, whether or not the client calls itself a business.
#assert.eq(resolve("SI", cli("IT", business: false), "service"), "eu_b2c")
#assert.eq(resolve("SI", cli("DE"), "goods"), "eu_b2c")

// Outside the EU.
#assert.eq(resolve("SI", cli("AE"), "goods"), "export_goods")
#assert.eq(resolve("SI", cli("AE"), "service"), "non_eu_service")

// A consumer is a consumer wherever they live: every B2C sale carries Slovenian VAT.
#assert.eq(resolve("SI", cli("AE", business: false), "goods"), "non_eu_b2c")
#assert.eq(resolve("SI", cli("AE", business: false), "service"), "non_eu_b2c")

// One refusal that cannot be asserted here, because panic() aborts compilation and is not
// catchable. Verify by hand once, then leave it written down:
//
//   an exemption whose clause text is empty for the document language
//     ⇒ must panic, not print a silent blank. Only --input draft=true may render it,
//       and then it prints a visible [MISSING VAT CLAUSE] marker.