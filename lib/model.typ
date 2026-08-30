// The model. Reads config, computes everything a document needs, and hands the layout modules
// a finished dictionary. This is the only place that knows both the YAML files and the shape
// the layout expects, so templates stay dumb and layout stays free of business rules.
//
// It replaces the Rust renderer of the previous version, which produced the same dictionary
// as out/model.json.

#import "money.typ": to-cents, to-qty, fmt, mul-qty, vat-of
#import "vat.typ": resolve

// The issuer profile a document gets when it names none. The file name in config/issuers/
// is the id; the profile itself is loaded per document, because a second issuer brings its own
// address, its own bank and its own tax regime.
#let default-issuer = "axelered_si"

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
#let price-item(item, supplier-country, client, money) = {
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
    case: resolve(supplier-country, client, kind),
  )
}

// One group per VAT treatment, in the order the treatments first appear on the document.
// A group carries its own lines, its own taxable base, its own VAT amount and the clause that
// justifies it, so a mixed document accounts for each treatment where the reader can see it.
//
// Both pieces of wording — the name of the treatment and the article behind it — come from
// config/tax/<regime>.yaml, which is the only file that knows any tax text. Either one missing
// in the document language is an error, not a blank line.
//
//   typst compile --root . tests/groups.typ
#let vat-groups(items, tax, labels, language, money) = {
  let cases = ()
  for it in items { if it.case not in cases { cases.push(it.case) } }

  let rate = tax.rates.standard
  let groups = ()
  let total-vat = 0
  for (i, case) in cases.enumerate() {
    let members = items.filter(it => it.case == case)
    let base = members.map(it => it.cents).sum(default: 0)
    let spec = tax.cases.at(case)
    let taxable = spec.taxable

    let wording(field) = {
      let text = spec.at(field, default: none)
      let value = if text == none { none } else { text.at(language, default: none) }
      if value in (none, "") { missing("VAT " + field + " " + case + "/" + language) } else { value }
    }

    // VAT is charged on the base of the group, not line by line: one rounding for the group,
    // which is what the tax authority expects and what an accountant recomputes by hand.
    let amount = if taxable { vat-of(base, rate) } else { none }
    if taxable { total-vat += amount }

    // A taxable group prints the rate it was charged at. A group that is not taxable prints
    // the name of its treatment and no figure at all: an intra-Community supply is not
    // zero-rated and an out-of-scope service is not taxed, so a printed "0%" would invite the
    // reader to believe Slovenia taxed them at zero.
    let vat-label = if taxable { labels.vat + " " + pct(rate) + "%" } else { wording("label") }

    // Numbered only when there is more than one treatment to tell apart.
    let subtotal-label = if cases.len() == 1 { labels.subtotal } else {
      labels.subtotal + " (" + str(i + 1) + "/" + str(cases.len()) + ")"
    }

    groups.push((
      items: members,
      subtotal: money(base),
      subtotal_label: subtotal-label,
      vat_label: vat-label,
      vat_amount: if taxable { money(amount) } else { none },
      note: if taxable { none } else { wording("clause") },
    ))
  }
  (groups: groups, total: total-vat)
}

// --- clauses -----------------------------------------------------------------------------

// Filter to the clauses the document asked for, order them, and number them 1..N over what is
// actually printed, so dropping a clause never leaves a hole. Section headings come from the
// same file; the placeholders are substituted here, never stored substituted.
#let build-clauses(ids, language, co, client, strings) = {
  if ids.len() == 0 { return () }
  let source = yaml("/config/clauses/offer." + language + ".yaml")
  let section-title = (:)
  let section-weight = (:)
  for s in source.sections {
    section-title.insert(s.id, s.title)
    section-weight.insert(s.id, s.weight)
  }

  let values = (
    "supplier.legal_name": co.legal_name,
    "supplier.identification": identification(co, strings),
    "supplier.governing_law": co.legal.governing_law.at(language),
    "supplier.forum": co.legal.forum,
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
  issuer: none,
  client: none,
  seq: none,
  revision: none,
  language: none,
  date: none,
  valid-until: none,
  items: (),
  clauses: (),
  vies-checked: none,
  signature: false,
  pay-within: none,
  bank-account: none,
  deliver-to: "",
  deliver-within: none,
) = {
  // Who issues, then what it says. The issuer decides the tax regime and the house defaults;
  // the language decides every fixed sentence on the sheet. The two are independent.
  let issuer = if issuer == none { default-issuer } else { issuer }
  let co = yaml("/config/issuers/" + issuer + ".yaml")
  let tax = yaml("/config/tax/" + co.tax_regime + ".yaml")
  let language = if language == none { co.defaults.language } else { language }
  let strings = yaml("/config/strings/" + language + ".yaml")
  let labels = strings.labels
  let client-record = yaml("/config/clients/" + client + ".yaml")

  // Number. NUMBERING.md is the authority; the template asserts this equals the file name.
  let parts = date.split("-")
  if parts.len() != 3 { panic("date must be ISO, YYYY-MM-DD, got " + date) }
  // An empty revision is no revision: one template serves both the proforma, which carries a
  // letter, and the invoice, which never does, so the author blanks the field instead of
  // deleting the line.
  let revision = if revision == "" { none } else { revision }
  if revision != none and tag not in revisable {
    panic("a " + tag + " document never carries a revision letter")
  }
  let yymmdd = parts.at(0).slice(2) + parts.at(1) + parts.at(2)
  let number = yymmdd + tag + client + pad(seq, 3)
  if revision != none { number += revision }

  // The number is the file name. render.sh / render.ps1 pass the name they were given, so a
  // document renamed without updating its arguments, or the reverse, fails to compile.
  let expected = sys.inputs.at("document", default: none)
  if expected != none and expected != number {
    panic("file name is " + expected + " but the arguments compute " + number)
  }

  // lib/vat.typ takes the country flat, as tests/vat.typ defines it; the client file nests it
  // under the address. Flatten here so the rule engine never has to know the file layout. The
  // code comes from the file name, which is the only place it is written: the engine adds it
  // so a refusal can name the file the author has to fix.
  let subject = client-record + (country: client-record.address.country, code: client)

  // Every amount on the page goes through this one closure, so the language decides the
  // separators once and nothing downstream formats money on its own.
  let nf = strings.number_format
  let money = c => fmt(c, thousands: nf.thousands, decimal: nf.decimal)

  let priced = items.map(it => price-item(it, co.address.country, subject, money))

  // The intra-Community exemption of ZDDV-1 46(1) and the reverse charge of 25(1) hold only if
  // the client's VAT id was valid in VIES on the day of supply. Validity is a fact of that day
  // and not of the client file: a company registered in March can be struck off in September,
  // and a date sitting in config/clients/ would look like proof it is not. So the check is
  // recorded per document, and demanded only when a document actually claims one of the two.
  // Nothing is printed: it is evidence for an inspection, not wording on a sheet.
  //
  // It is written like `date:`, ISO, and it has to BE the issue date: a check made a week ago
  // proves nothing about today. So the field carries no information the document does not
  // already have, and that is the whole of it — it cannot be filled in without querying VIES,
  // and it cannot be left to age.
  if priced.any(it => it.case in ("b2b_eu_goods", "b2b_eu_service")) {
    if vies-checked in (none, "") {
      panic(
        "this document exempts an intra-Community supply, which holds only if "
          + client-record.vat_number + " was valid in VIES on the day of supply. Query it at "
          + "https://ec.europa.eu/taxation_customs/vies/ then write vies-checked: \""
          + date + "\"",
      )
    }
    if vies-checked != date {
      panic(
        "vies-checked is " + repr(vies-checked) + " but this document is issued on " + date
          + ". VIES has to be queried on the day of issue and the date has to say so: query "
          + client-record.vat_number + " again and write vies-checked: \"" + date + "\"",
      )
    }
  }
  let subtotal = priced.map(it => it.cents).sum(default: 0)
  let vat = vat-groups(priced, tax, labels, language, money)

  let issuer-party = party(co, labels) + (
    website: co.contacts.at("website", default: none),
    email: co.contacts.at("email", default: none),
    phone: co.contacts.at("phone", default: none),
  )

  // Payment terms. `pay-within` is a number of days: 0 means the document is already paid,
  // so nothing is due and no bank details are printed. `auto` takes the house default from
  // the issuer profile; `none` prints no payment block at all, which is what a document
  // without figures wants. The sentence is boilerplate and comes from the language file; the
  // number of days and the bank are facts of the issuer.
  let days = if pay-within == auto { co.defaults.pay_within } else { pay-within }
  let payment = if days == none { none } else {
    if type(days) != int or days < 0 {
      panic("pay-within must be a whole number of days, 0 for already paid, got " + repr(days))
    }
    let paid = days == 0
    let key = if paid { "already_paid" } else { "within" }
    let terms = strings.terms.payment.at(key, default: none)
    let accounts = co.bank_accounts
    let account = if bank-account == none {
      accounts.filter(a => a.at("default", default: false)).first()
    } else {
      accounts.filter(a => a.id == bank-account).first()
    }
    (
      sentence: if terms in (none, "") { missing("payment terms " + key + "/" + language) } else {
        fill-in(terms, (days: str(days)))
      },
      show_account: not paid,
      holder: account.holder,
      iban: account.iban,
      swift: account.swift,
    )
  }

  // Delivery. `deliver-within` is a number of days, 0 meaning already delivered. `auto` prints
  // the block only when the document actually moves something: a service has no destination.
  // `none` never prints it. An empty `deliver-to` means the client's registered office.
  let dispatch = if deliver-within != auto { deliver-within } else if items.any(it => it.kind == "goods") {
    co.defaults.deliver_within
  } else { none }
  let delivery = if dispatch == none { none } else {
    if type(dispatch) != int or dispatch < 0 {
      panic("deliver-within must be a whole number of days, 0 for already delivered, got " + repr(dispatch))
    }
    let key = if dispatch == 0 { "already_delivered" } else { "within" }
    let terms = strings.terms.delivery.at(key, default: none)
    (
      destination: if deliver-to == "" {
        (client-record.legal_name, ..address-lines(client-record.address)).join(", ")
      } else { deliver-to },
      terms: if terms in (none, "") { missing("delivery terms " + key + "/" + language) } else {
        fill-in(terms, (days: str(dispatch)))
      },
    )
  }

  // The registry line: the legal name, then whatever the issuer's own register requires. Each
  // entry carries a value and, optionally, the key of the label that introduces it, so a company
  // registered elsewhere lists different things without touching this code.
  let footer-parts = (co.legal_name,) + co.footer.registry.map(entry => {
    let value = str(entry.value)
    let key = entry.at("label", default: none)
    if key == none { value } else { labels.at(key) + " " + value }
  })

  (
    number: number,
    tag: tag,
    language: language,
    date: date,
    place_of_issue: co.place_of_issue,
    valid_until: if valid-until == none { none } else { labels.valid_until + " " + valid-until },
    currency_symbol: co.defaults.currency,

    issuer: issuer-party,
    client: party(client-record, labels),

    items: priced,
    groups: vat.groups,
    totals: (
      subtotal: money(subtotal),
      total: money(subtotal + vat.total),
      total_label: labels.total,
    ),

    clauses: build-clauses(clauses, language, co, client-record, strings),
    payment: payment,
    delivery: delivery,
    signature: if not signature { none } else {
      strings.signature + (
        supplier_role: fill-in(
          strings.signature.representative_of,
          (role: co.signatory.role.at(language), party: co.legal_name),
        ),
        supplier_place_date: co.place_of_issue + ", " + date,
        client_place_date: strings.signature.signed_on + " " + strings.signature.empty_date,
        sign_image: "/assets/sign.png",
      )
    },

    footer: (
      confidentiality: strings.footer.confidentiality,
      legal_line: footer-parts.join(" · "),
    ),
    assets: (logo: "/assets/logo.svg"),
    strings: labels + (title: strings.titles.at(tag)),
  )
}