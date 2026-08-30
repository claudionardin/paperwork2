// The seam between the rules and the configuration. lib/vat.typ returns case keys and
// config/tax/<regime>.yaml has to declare exactly those, with exactly the wording the engine
// will ask for. Nothing here checks legal text; it checks that the two halves fit.
// A test file that compiles has passed.
//   typst compile --root . tests/config.typ
#import "/lib/vat.typ": resolve

#let si = yaml("/config/tax/si.yaml")
#let languages = ("sl", "en", "it")

#let cli(country, vat: none, business: true) = (
  code: "XXX",
  country: country,
  vat_number: vat,
  is_business: business,
)

// --- every case the cascade can reach is declared, and every declared case is reachable ----
// Both directions at once: a key the engine returns without an entry crashes a document, and
// an entry no branch returns is dead wording nobody will maintain. The combinations below are
// written out rather than generated, because one of them — a service to a consumer outside the
// EU — must panic, and a loop would walk into it.
#let reached = (
  resolve("SI", cli("SI", vat: "SI12345678"), "goods"),
  resolve("SI", cli("SI", vat: "SI12345678"), "service"),
  resolve("SI", cli("SI", business: false), "goods"),
  resolve("SI", cli("IT", vat: "IT01313650325"), "goods"),
  resolve("SI", cli("IT", vat: "IT01313650325"), "service"),
  resolve("SI", cli("IT", business: false), "service"),
  resolve("SI", cli("RS", vat: "RS100000000"), "goods"),
  resolve("SI", cli("RS", vat: "RS100000000"), "service"),
  resolve("SI", cli("RS", business: false), "goods"),
).dedup().sorted()

#assert.eq(
  reached,
  si.cases.keys().sorted(),
  message: "lib/vat.typ and config/tax/si.yaml disagree on the set of cases",
)

// --- the shape of a case --------------------------------------------------------------------
// Taxable: the VAT row is generated from the rate, so the case names no treatment and cites no
// article. Not taxable: both are mandatory, in every language, because a document rendered in
// any of them must be able to say what happened and why.
#for (key, spec) in si.cases {
  assert(
    spec.at("taxable", default: none) in (true, false),
    message: key + ": taxable must be true or false",
  )
  if spec.taxable {
    assert.eq(spec.at("label", default: none), none, message: key + " is taxable and must carry no label")
    assert.eq(spec.at("clause", default: none), none, message: key + " is taxable and must carry no clause")
  } else {
    for field in ("label", "clause") {
      let text = spec.at(field, default: none)
      assert(text != none, message: key + " is not taxable and has no " + field)
      for lang in languages {
        assert(
          text.at(lang, default: none) not in (none, ""),
          message: key + "." + field + " has no " + lang + " text",
        )
      }
    }
  }
}

// --- rates ------------------------------------------------------------------------------------
// One rate, because lib/model.typ can apply exactly one: `tax.rates.standard`. Slovenia has a
// reduced and a super-reduced rate too, and they are deliberately absent — a rate declared here
// that no line could ever be charged at is a lie in a config file. Wiring a per-item rate is
// the change that lets this assertion be relaxed, and it should be relaxed in the same commit.
#assert.eq(si.rates.keys(), ("standard",), message: "config/tax/si.yaml declares a rate lib/ cannot apply")
#assert(si.rates.standard > 0)

// --- no tax wording escapes config/tax/ --------------------------------------------------------
// The label and the clause of a case live together, in the jurisdiction's own file. A language
// file holds generic labels and nothing that depends on a tax regime, so adding a second issuer
// never touches config/strings/.
#for lang in ("en", "it") {
  let strings = yaml("/config/strings/" + lang + ".yaml")
  for key in ("vat", "subtotal", "total") {
    assert(key in strings.labels, message: lang + ".yaml has no labels." + key)
  }
  assert(
    "vat_cases" not in strings,
    message: lang + ".yaml carries tax wording; it belongs in config/tax/<regime>.yaml",
  )
}

// --- every issuer points at a tax regime that exists -------------------------------------------
// yaml() panics on a missing file, so the load is the assertion. Typst cannot list a directory,
// so the issuers are named: a third profile is added here too.
#for id in ("axelered_si", "axelered_ae") {
  let co = yaml("/config/issuers/" + id + ".yaml")
  let regime = yaml("/config/tax/" + co.tax_regime + ".yaml")
  assert("rates" in regime, message: id + ": config/tax/" + co.tax_regime + ".yaml declares no rates")
  assert("cases" in regime, message: id + ": config/tax/" + co.tax_regime + ".yaml declares no cases")
}

// --- the UAE skeleton stays a skeleton on both sides --------------------------------------------
// lib/vat.typ resolve-ae panics, so config/tax/ae.yaml must still be empty. The day someone
// fills the wording in without writing the rules, this fails and says which half is missing.
#assert.eq(
  yaml("/config/tax/ae.yaml").cases.len(),
  0,
  message: "config/tax/ae.yaml has cases but lib/vat.typ resolve-ae still panics: write both or neither",
)
