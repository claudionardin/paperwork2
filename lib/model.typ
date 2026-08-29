// The model. Reads config, computes everything a document needs, and hands the layout modules
// a finished dictionary. This is the only place that knows both the YAML files and the shape
// the layout expects, so templates stay dumb and layout stays free of business rules.
//
// It replaces the Rust renderer of the previous version, which produced the same dictionary
// as out/model.json.

#import "money.typ": to-cents, to-qty, fmt, mul-qty, vat-of
#import "vat.typ": resolve

#let company = yaml("/config/company.yaml")
#let tax = yaml("/config/tax/vat.yaml")

// Documents that carry a revision letter. NUMBERING.md, rule 4.
#let revisable = ("off", "spc", "pin")

// --- small helpers -----------------------------------------------------------------------

#let pad(n, width) = {
  let s = str(n)
  while s.len() < width { s = "0" + s }
  s
}

// 22.0 prints as "22", 9.5 stays "9.5".
#let pct(rate) = if calc.rem(rate, 1) == 0 { str(int(rate)) } else { str(rate) }

// Wording that has not been written yet. Refuses by default; --input draft=true renders a
// visible marker instead, so a work in progress can still be read.
#let draft-mode = sys.inputs.at("draft", default: "false") == "true"
#let missing(what) = {
  if draft-mode { "[MISSING " + upper(what) + "]" } else { panic("missing " + what) }
}

#let fill-in(template, values) = {
  let out = template
  for (key, value) in values { out = out.replace("{{" + key + "}}", value) }
  out
}

// --- parties -----------------------------------------------------------------------------

#let address-lines(a) = (
  a.street,
  a.postal_code + " " + a.city + ", " + a.country,
)

// The sentence that identifies a party inside a clause. First case the data supports wins:
// a company has a VAT number, an Italian individual only a tax code, anyone else just an address.
#let identification(party, strings) = {
  let address = address-lines(party.address).join(", ")
  let vat = party.at("vat_number", default: none)
  let tax-code = party.at("tax_code", default: none)
  if vat not in (none, "") {
    fill-in(strings.identification.with_vat, (vat_number: vat, address: address))
  } else if tax-code not in (none, "") {
    fill-in(strings.identification.with_tax_code, (tax_code: tax-code, address: address))
  } else {
    fill-in(strings.identification.address_only, (address: address))
  }
}

#let party(source, labels) = (
  legal_name: source.legal_name,
  address: address-lines(source.address),
  vat_number: source.at("vat_number", default: none),
  tax_code: source.at("tax_code", default: none),
  reg_number: source.at("reg_number", default: none),
  vat_label: labels.vat_number,
  tax_label: labels.tax_code,
  reg_label: labels.reg_number,
)

// --- items, totals, VAT ------------------------------------------------------------------

// One priced line, with its VAT case attached. `kind` is mandatory: it decides the treatment,
// and guessing it would silently change the tax on the document.
#let price-item(item, client, money) = {
  let kind = item.at("kind", default: none)
  if kind == none {
    panic("item \"" + item.desc + "\" has no kind; write kind: \"goods\" or kind: \"service\"")
  }
  let unit = to-cents(item.price)
  let qty = to-qty(item.at("qty", default: 1))
  (
    description: item.desc,
    unit_price: money(unit),
    quantity: str(item.at("qty", default: 1)),
    amount: money(mul-qty(unit, qty)),
    cents: mul-qty(unit, qty),
    case: resolve(company.address.country, client, kind),
  )
}

// One summary row per VAT treatment, in the order the treatments first appear on the document.
// A mixed document therefore shows a taxed row and an exempt row side by side.
#let vat-summary(items, labels, case-suffixes, money) = {
  let cases = ()
  for it in items { if it.case not in cases { cases.push(it.case) } }

  let rate = tax.rates.standard
  let lines = ()
  let total-vat = 0
  for case in cases {
    let base = items.filter(it => it.case == case).map(it => it.cents).sum(default: 0)
    let taxable = tax.cases.at(case).taxable
    let amount = if taxable { vat-of(base, rate) } else { 0 }
    total-vat += amount

    let suffix = case-suffixes.at(case, default: "")
    let label = labels.vat + " " + pct(if taxable { rate } else { 0.0 }) + "%"
    if suffix != "" { label += ", " + suffix }
    lines.push((label: label, amount: money(amount)))
  }
  (lines: lines, total: total-vat)
}

// The legal wording, one note per exempt treatment. The Slovenian text is printed alongside
// because it is the legally operative one. An exemption with no wording in the document
// language is an error, not a blank line.
#let vat-notes(items, language) = {
  let notes = ()
  let seen = ()
  for it in items {
    if it.case in seen { continue }
    seen.push(it.case)
    let case = tax.cases.at(it.case)
    if case.taxable { continue }
    let clause = case.at("clause", default: none)
    let primary = if clause == none { none } else { clause.at(language, default: none) }
    notes.push((
      primary: if primary in (none, "") { missing("VAT clause " + it.case + "/" + language) } else { primary },
      slovenian: if clause == none { none } else { clause.at("sl", default: none) },
    ))
  }
  notes
}

// --- clauses -----------------------------------------------------------------------------

// Filter to the clauses the document asked for, order them, and number them 1..N over what is
// actually printed, so dropping a clause never leaves a hole. Section headings come from the
// same file; the placeholders are substituted here, never stored substituted.
#let build-clauses(ids, language, issuer, client, strings) = {
  if ids.len() == 0 { return () }
  let source = yaml("/config/clauses/offer." + language + ".yaml")
  let section-title = (:)
  let section-weight = (:)
  for s in source.sections {
    section-title.insert(s.id, s.title)
    section-weight.insert(s.id, s.weight)
  }

  let values = (
    "supplier.legal_name": issuer.legal_name,
    "supplier.identification": identification(issuer, strings),
    "supplier.governing_law": company.legal.governing_law.at(language),
    "supplier.forum": company.legal.forum,
    "client.legal_name": client.legal_name,
    "client.identification": identification(client, strings),
    "client.short_name": {
      let short = client.at("short_name", default: none)
      if short in (none, "") { client.legal_name } else { short }
    },
  )

  let chosen = ()
  for id in ids {
    let found = source.clauses.filter(c => c.id == id)
    if found.len() == 0 { panic("no clause with id \"" + id + "\" in offer." + language + ".yaml") }
    chosen.push(found.first())
  }
  chosen = chosen.sorted(key: c => (section-weight.at(c.section), c.weight))

  chosen.enumerate(start: 1).map(((number, c)) => (
    number: number,
    section: section-title.at(c.section),
    title: c.title,
    body: fill-in(c.body.trim(), values),
  ))
}

// --- the document ------------------------------------------------------------------------

#let build(
  tag: none,
  client: none,
  seq: none,
  revision: none,
  language: none,
  date: none,
  valid-until: none,
  items: (),
  clauses: (),
  signature: false,
  payment-terms: none,
  bank-account: none,
) = {
  let language = if language == none { company.defaults.language } else { language }
  let strings = yaml("/config/strings/" + language + ".yaml")
  let labels = strings.labels
  let client-record = yaml("/config/clients/" + client + ".yaml")

  // Number. NUMBERING.md is the authority; the template asserts this equals the file name.
  let parts = date.split("-")
  if parts.len() != 3 { panic("date must be ISO, YYYY-MM-DD, got " + date) }
  if revision != none and tag not in revisable {
    panic("a " + tag + " document never carries a revision letter")
  }
  let number = parts.at(0).slice(2) + parts.at(1) + parts.at(2) + tag + client + pad(seq, 3)
  if revision != none { number += revision }

  // The number is the file name. render.sh / render.ps1 pass the name they were given, so a
  // document renamed without updating its arguments, or the reverse, fails to compile.
  let expected = sys.inputs.at("document", default: none)
  if expected != none and expected != number {
    panic("file name is " + expected + " but the arguments compute " + number)
  }

  // lib/vat.typ takes the country flat, as tests/vat.typ defines it; the client file nests it
  // under the address. Flatten here so the rule engine never has to know the file layout.
  let subject = client-record + (country: client-record.address.country)

  // Every amount on the page goes through this one closure, so the language decides the
  // separators once and nothing downstream formats money on its own.
  let nf = strings.number_format
  let money = c => fmt(c, thousands: nf.thousands, decimal: nf.decimal)

  let priced = items.map(it => price-item(it, subject, money))
  let subtotal = priced.map(it => it.cents).sum(default: 0)
  let vat = vat-summary(priced, labels, strings.vat_cases, money)

  let issuer = party(company, labels) + (
    website: company.contacts.at("website", default: none),
    email: company.contacts.at("email", default: none),
    phone: company.contacts.at("phone", default: none),
  )

  let payment = if payment-terms == none { none } else {
    let accounts = company.bank_accounts
    let account = if bank-account == none {
      accounts.filter(a => a.at("default", default: false)).first()
    } else {
      accounts.filter(a => a.id == bank-account).first()
    }
    let terms = company.payment_terms.at(payment-terms, default: none)
    (
      sentence: if terms == none { missing("payment terms " + payment-terms) } else { terms.at(language) },
      holder: account.holder,
      iban: account.iban,
      swift: account.swift,
    )
  }

  let footer-parts = (
    company.legal_name,
    labels.share_capital + " " + company.footer.share_capital,
    company.footer.court,
    "SRG " + company.footer.srg,
    labels.entered_on + " " + str(company.footer.enrolment_date),
  )

  (
    number: number,
    tag: tag,
    language: language,
    date: date,
    place_of_issue: company.place_of_issue,
    valid_until: if valid-until == none { none } else { labels.valid_until + " " + valid-until },
    currency_symbol: company.defaults.currency,

    issuer: issuer,
    client: party(client-record, labels),

    items: priced,
    totals: (
      subtotal: money(subtotal),
      vat_lines: vat.lines,
      total: money(subtotal + vat.total),
    ),
    vat_notes: vat-notes(priced, language),

    clauses: build-clauses(clauses, language, company, client-record, strings),
    payment: payment,
    signature: if not signature { none } else {
      strings.signature + (
        supplier_role: fill-in(
          strings.signature.representative_of,
          (role: company.signatory.role.at(language), party: company.legal_name),
        ),
        supplier_place_date: company.place_of_issue + ", " + date,
        client_place_date: strings.signature.signed_on + " " + strings.signature.empty_date,
        sign_image: "/assets/sign.png",
      )
    },

    footer: (
      confidentiality: company.footer.confidentiality,
      legal_line: footer-parts.join(" · "),
    ),
    assets: (logo: "/assets/logo.svg"),
    strings: labels + (title: strings.titles.at(tag), number_label: labels.number),
  )
}