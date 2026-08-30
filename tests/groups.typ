// lib/model.typ vat-groups: the function where the base, the rate, the rounding and the
// grouping meet. tests/money.typ pins the arithmetic underneath it and tests/vat.typ the
// choice of case above it; this is what sits between the two.
// A test file that compiles has passed.
//   typst compile --root . tests/groups.typ
#import "/lib/model.typ": vat-groups
#import "/lib/money.typ": fmt

// The tax config is the real file, not a fixture: a test against invented cases would pass
// while the file everyone edits drifts. What is asserted about it is the wiring, never the
// legal text. The two labels are a fixture on purpose — they are generic wording, they belong
// to config/strings/, and pinning them here would make this file fail on a translation edit.
#let tax = yaml("/config/tax/si.yaml")
#let labels = (vat: "VAT", subtotal: "Subtotal")
#let money = c => fmt(c)

// The shape lib/model.typ price-item produces. vat-groups reads `cents` and `case`; the rest
// is carried through to the table untouched, and is here so the fixture cannot drift from the
// real record.
#let line(case, cents) = (
  description: "line",
  unit_price: fmt(cents),
  quantity: "1",
  amount: fmt(cents),
  cents: cents,
  case: case,
)

#let run(items, lang: "en") = vat-groups(items, tax, labels, lang, money)

// --- one taxable treatment -------------------------------------------------------------
// 1000.00 + 500.00 at 22% = 330.00. A single group is not numbered.
#let one = run((line("b2c", 100000), line("b2c", 50000)))
#assert.eq(one.groups.len(), 1)
#assert.eq(one.groups.first().items.len(), 2)
#assert.eq(one.groups.first().subtotal, "1500.00")
#assert.eq(one.groups.first().subtotal_label, "Subtotal")
#assert.eq(one.groups.first().vat_label, "VAT 22%")
#assert.eq(one.groups.first().vat_amount, "330.00")
#assert.eq(one.groups.first().note, none)
#assert.eq(one.total, 33000)

// --- two treatments on one sheet ---------------------------------------------------------
// The only mix a real document can carry: one client, so one country and one VAT id, which
// leaves the kind of the line as the only thing that can differ. Both groups are exempt.
// Groups appear in the order the treatments first appear, not in the order of config/tax/.
#let two = run((
  line("b2b_eu_service", 300000),
  line("b2b_eu_goods", 480000),
  line("b2b_eu_service", 90000),
))
#assert.eq(two.groups.len(), 2)
#assert.eq(two.groups.at(0).items.len(), 2)
#assert.eq(two.groups.at(1).items.len(), 1)

// Each group carries its own base: 3000.00 + 900.00, and 4800.00.
#assert.eq(two.groups.at(0).subtotal, "3900.00")
#assert.eq(two.groups.at(1).subtotal, "4800.00")

// Numbered once there is more than one treatment to tell apart.
#assert.eq(two.groups.at(0).subtotal_label, "Subtotal (1/2)")
#assert.eq(two.groups.at(1).subtotal_label, "Subtotal (2/2)")

// A group that is not taxable names its treatment and carries NO figure. Never "VAT 0%":
// an intra-Community supply is not zero-rated and the reader must not be able to read it so.
#assert.eq(two.groups.at(0).vat_label, "Reverse charge")
#assert.eq(two.groups.at(1).vat_label, "Exempt, intra-Community supply")
#assert.eq(two.groups.at(0).vat_amount, none)
#assert.eq(two.groups.at(1).vat_amount, none)
#assert.eq(two.total, 0)

// The clause is the one of that case, in the document language. Compared against the config
// rather than against a copy of the sentence, so the assertion checks the wiring and does not
// rot when an accountant rewrites the wording.
#assert.eq(two.groups.at(0).note, tax.cases.b2b_eu_service.clause.en)
#assert.eq(two.groups.at(1).note, tax.cases.b2b_eu_goods.clause.en)

// --- the language decides both pieces of wording ------------------------------------------
#let it = run((line("b2b_eu_service", 300000), line("b2b_eu_goods", 480000)), lang: "it")
#assert.eq(it.groups.at(0).vat_label, "Inversione contabile")
#assert.eq(it.groups.at(1).vat_label, "Non imponibile, cessione intracomunitaria")
#assert.eq(it.groups.at(0).note, tax.cases.b2b_eu_service.clause.it)
#assert.eq(it.groups.at(1).note, tax.cases.b2b_eu_goods.clause.it)

// --- VAT is charged on the base of the group, not line by line ----------------------------
// Two lines of 0.03. Per group: 0.06 * 22% = 0.0132 → 1 cent. Line by line it would be
// 0.0066 → 1 cent twice, so 2. The assertion pins the group as the taxable unit.
#assert.eq(run((line("b2c", 3), line("b2c", 3))).total, 1)

// One rounding, half away from zero, at the group base. 0.25 * 22% = 0.055 → 6 cents.
#assert.eq(run((line("b2c", 25),)).total, 6)
#assert.eq(run((line("b2c", -25),)).total, -6)

// --- a discount is an ordinary negative line, inside its own treatment ---------------------
// It carries a `kind` like every other line, so it lands in one group and lowers that group's
// base alone. A discount meant for the whole sheet is written as one line per treatment.
#let disc = run((
  line("b2b_eu_service", 300000),
  line("b2b_eu_service", -50000),
  line("b2b_eu_goods", 480000),
))
#assert.eq(disc.groups.at(0).subtotal, "2500.00")
#assert.eq(disc.groups.at(1).subtotal, "4800.00")

// On a taxable treatment the discount reaches the VAT: 1000.00 - 200.00 = 800.00, 22% = 176.00.
#let taxed-disc = run((line("b2c", 100000), line("b2c", -20000)))
#assert.eq(taxed-disc.groups.first().subtotal, "800.00")
#assert.eq(taxed-disc.total, 17600)

// --- a taxable group beside an exempt one --------------------------------------------------
// No client can produce this today, because one client fixes both the country and the VAT id.
// It is asserted anyway: vat-groups is general, a second jurisdiction may well mix the two,
// and the total must count only what was actually charged.
#let mixed = run((line("b2c", 100000), line("export_goods", 50000)))
#assert.eq(mixed.groups.at(0).vat_amount, "220.00")
#assert.eq(mixed.groups.at(1).vat_amount, none)
#assert.eq(mixed.groups.at(1).vat_label, "Exempt, export")
#assert.eq(mixed.total, 22000)

// --- nothing to price ----------------------------------------------------------------------
// A spec carries no items. The function must return empty rather than divide anything by zero.
#assert.eq(run(()).groups.len(), 0)
#assert.eq(run(()).total, 0)

// One refusal that cannot be asserted here, because panic() aborts compilation and is not
// catchable. Verified by hand once, then written down:
//
//   a non-taxable case whose label or clause is empty for the document language
//     ⇒ must panic, not print a blank cell. Only --input draft=true renders it, and then it
//       prints a visible [MISSING VAT LABEL …] / [MISSING VAT CLAUSE …] marker.
