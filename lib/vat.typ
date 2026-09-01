// VAT case resolution. Decides which case applies for one line of one document; the wording
// for each case lives in config/tax/<regime>.yaml. Rules here, never in YAML. Text there,
// never here.
//
//   typst compile --root . tests/vat.typ
//
// One rule set per issuing jurisdiction. `resolve` dispatches on the issuer country and knows
// nothing else; each jurisdiction's rules are a function of their own, so adding a second
// issuer never touches the first one's rules. Today only Slovenia is written.

// EU member states, ISO 3166-1 alpha-2. Membership is a fact the rules need, not wording,
// so it belongs to the engine. Keep in sync with reality: the UK left in 2020.
#let eu = (
  "AT", "BE", "BG", "CY", "CZ", "DE", "DK", "EE", "ES", "FI", "FR", "GR", "HR", "HU", "IE",
  "IT", "LT", "LU", "LV", "MT", "NL", "PL", "PT", "RO", "SE", "SK", "SI",
)

// --- Slovenia ------------------------------------------------------------------------------
//
// Case keys are the ones of config/tax/si.yaml, and the branches below are in the order that
// file documents. The order is the rule: destination decides first, because it has no
// exception, and only then does each destination pick its own second axis. Inside the Union
// that axis is the customer's status; outside it, it is the kind of the line. Getting those
// two the wrong way round is what makes an export to a consumer look like a domestic sale.
//
// Every branch either returns a key or panics. There is no default, because defaulting to
// taxable overcharges the client and defaulting to exempt is tax evasion.
#let resolve-si(client, kind) = {
  let country = client.country
  let has-vat-id = client.at("vat_number", default: none) not in (none, "")
  // No default. Outside the Union this field alone separates a supply that is outside
  // Slovenian VAT from one that is not, and there is no register to check it against, so a
  // client file that leaves it out has not answered the question. Read where it is used.
  let is-business = client.at("is_business", default: none)
  // Whether VIES answered yes on the day of supply. Not a field of a client file: lib/model.typ
  // resolves the document's `vies:` into this boolean and adds it to the record, false only
  // when the author wrote `vies: "no"`. Absent means the question was never in play — a client
  // fixture, or a supply no exemption depends on — so it defaults to true and the branches
  // below decide on the id alone.
  let vies-ok = client.at("vies_ok", default: true)

  // 1. Slovenia. Both branches are 22% with no clause, and they are kept apart only because
  //    the two are different documents to an accountant. Not covered: the domestic reverse
  //    charge of ZDDV-1 76.a, which would sit here and applies to construction, cleaning,
  //    supply of staff in construction and scrap. Nothing on a line says whether it is one
  //    of those, and none of it is work this company sells. See TODO.md.
  if country == "SI" {
    return if has-vat-id { "b2b_si" } else { "b2c" }
  }

  // Outside the Union. There is no common VAT system to hand the tax to and no register to
  // check a counterparty against, so the kind of the line decides before anything else.
  if country not in eu {
    // 2. Goods the seller ships out. ZDDV-1 52(1)(a) hangs the exemption on the goods
    //    leaving, not on who buys them, so this outranks every test of customer status: a
    //    consumer abroad is an export too.
    if kind == "goods" { return "export_goods" }

    // 3. Services to a business: the place of supply follows the customer, ZDDV-1 25(1).
    //    Outside the Union `is_business` is the author's assertion and nothing more, because
    //    there is no VIES to prove it against — which is exactly why it has to be written
    //    down rather than assumed.
    if is-business == none {
      panic(
        "config/clients/" + client.code + ".yaml has no is_business, and outside the EU that "
          + "field is what decides the treatment: set it to true or false",
      )
    }
    if is-business { return "noneu_service" }

    // 4. Services to a consumer split on the service itself, and a document does not carry
    //    what tells the two apart. ZDDV-1 30.d moves consultancy, engineering, data
    //    processing and the licensing of rights to the customer's country; anything outside
    //    that closed list stays Slovenian under 25(2). Both outcomes are plausible for what
    //    this company sells, so the engine refuses instead of picking a rate.
    panic(
      "a service sold to a consumer outside the EU has no single treatment: it is outside "
        + "Slovenian VAT if it falls under ZDDV-1 30.d (consultancy, engineering, data "
        + "processing, licensing) and Slovenian VAT at the standard rate under 25(2) if it "
        + "does not. Decide with the accountant, then add the case to lib/vat.typ and "
        + "config/tax/si.yaml. See TODO.md",
    )
  }

  // Rest of the Union. A VAT id is what makes it B2B, not the client calling itself a
  // business: without one there is nothing to reverse the charge to. An id VIES does not
  // recognise is no id at all — the exemption of 46(1) and the reverse charge of 25(1) both
  // rest on the counterparty being identified in another member state, so a rejected id falls
  // through to case 7 and the supply is taxed at the standard rate.
  if has-vat-id and vies-ok {
    // 5. Goods leaving Slovenia for another member state. Not covered: goods the supplier
    //    installs or assembles at destination, which under ZDDV-1 20(3) are not an
    //    intra-Community supply at all but a supply in the member state of arrival. A
    //    document does not say whether the goods are installed. See TODO.md.
    if kind == "goods" { return "b2b_eu_goods" }
    // 6. General place of supply rule, reverse charge.
    return "b2b_eu_service"
  }

  // 7. A consumer in the Union. Slovenian VAT, which is right below the distance-selling
  //    threshold of ZDDV-1 30.f: past 10,000 EUR of cross-border B2C supplies in a year the
  //    rate becomes the customer country's, declared through OSS. That is a fact of the
  //    year, not of the document, so it cannot be checked here. See TODO.md.
  "b2c"
}

// --- United Arab Emirates ------------------------------------------------------------------
//
// TODO not written. An accountant registered in the UAE has to supply the rules, and
// config/tax/ae.yaml the wording that goes with them. Expect at least: domestic 5%,
// zero-rated export of goods, export of services, designated zones, and a reverse charge for
// imports. The keys returned here must be exactly the keys of config/tax/ae.yaml, and every
// non-taxable case there needs both a `label` and a `clause`. No tax wording goes anywhere
// else: config/strings/<lang>.yaml holds none of it, so a second jurisdiction is one new file
// in config/tax/ and one new rule set here. tests/config.typ holds the two sides together.
#let resolve-ae(client, kind) = {
  panic(
    "UAE VAT rules are not written: fill in lib/vat.typ resolve-ae and config/tax/ae.yaml "
      + "before issuing from an AE profile. See TODO.md",
  )
}

// --- dispatch ------------------------------------------------------------------------------
//
//   supplier  ISO country of the issuing company, from config/issuers/<id>.yaml
//   client    the client record, from config/clients/<id>.yaml
//   kind      "goods" or "service", mandatory on every item, never inferred
#let resolve(supplier, client, kind) = {
  if kind not in ("goods", "service") {
    panic("item kind must be \"goods\" or \"service\", got " + repr(kind))
  }
  if supplier == "SI" { return resolve-si(client, kind) }
  if supplier == "AE" { return resolve-ae(client, kind) }
  panic("no VAT rules written for a supplier established in " + supplier)
}
