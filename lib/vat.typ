// VAT case resolution. Decides which of the seven cases applies; the wording for each case
// lives in config/tax/vat.yaml. Rules here, never in YAML. Text there, never here.
//
//   typst compile --root . tests/vat.typ

// EU member states, ISO 3166-1 alpha-2. Membership is a fact the rules need, not wording,
// so it belongs to the engine. Keep in sync with reality: the UK left in 2020.
#let eu = (
  "AT", "BE", "BG", "CY", "CZ", "DE", "DK", "EE", "ES", "FI", "FR", "GR", "HR", "HU", "IE",
  "IT", "LT", "LU", "LV", "MT", "NL", "PL", "PT", "RO", "SE", "SI", "SK",
)

// Resolve the case key for one line of one document.
//   supplier  ISO country of the issuing company, from config/company.yaml
//   client    the client record, from config/clients/<CCC>.yaml
//   kind      "goods" or "service", mandatory on every item, never inferred
//
// Every branch either returns a key or panics. There is no default, because defaulting to
// taxable overcharges the client and defaulting to exempt is tax evasion.
#let resolve(supplier, client, kind) = {
  if supplier != "SI" {
    panic("VAT rules are written for a Slovenian supplier, got " + supplier)
  }
  if kind not in ("goods", "service") {
    panic("item kind must be \"goods\" or \"service\", got " + repr(kind))
  }

  let country = client.country
  let has-vat-id = client.at("vat_number", default: none) not in (none, "")
  let is-business = client.at("is_business", default: false)

  // Slovenia. Public administration is still taxable, but it is tracked separately because
  // e-invoicing through UJP is mandatory for it.
  if country == "SI" {
    if client.at("is_public_administration", default: false) { return "public_administration" }
    return "domestic"
  }

  // Rest of the EU. A VAT id is what makes it B2B, not the client calling itself a business:
  // without one there is nothing to reverse the charge to, so Slovenian VAT applies.
  if country in eu {
    if not has-vat-id { return "eu_b2c" }
    if kind == "goods" { return "eu_b2b_goods" }
    return "eu_b2b_service"
  }

  // Outside the EU. A consumer is taxed like any other consumer, in Slovenia; a business
  // takes the export or out-of-scope treatment depending on what it bought.
  if not is-business { return "non_eu_b2c" }
  if kind == "goods" { return "export_goods" }
  "non_eu_service"
}