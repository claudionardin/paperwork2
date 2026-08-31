# CLAUDE.md

## How to work on this project

These rules override default behaviour and apply to every task in this repository.

**Prime directive: finish the project. Fast.**

| Rule | Meaning |
|---|---|
| Ship over polish | A finished project that is 80% precise beats a finished project that is 90% precise if it costs twice the time. Speed wins in 95% of decisions. |
| No rabbit holes | Stop pulling a thread the moment it stops serving the deliverable. Note it in `TODO.md` and move on. |
| Precision is still mandatory | Speed never licenses approximation, guessing, or hand-waving. Wrong is not fast. |
| Think, don't argue | Spend tokens on reasoning, not on prose. Never write three paragraphs for something that takes three words. |

**Answer style**

- Considered but concise. Straight to the point. No preamble, no restating the question, no summarising what was just done at length.
- Use tables and bullet lists whenever the content has structure: comparisons, options, trade-offs, field definitions, decision matrices. Visual beats narrative.
- Hierarchies, topologies, data flows and layouts must be thought through carefully and then explained compactly and exactly — sketch the structure, don't narrate it.
- State a recommendation instead of surveying every option. Ask only when the answer changes what gets built.

## What this is

Generate Axelered business documents as PDFs — offers, technical specs, proforma invoices,
invoices, CMR notes. One `.typ` file per document, `typst compile`, done.

The whole application is four things:

1. **Layout** — Typst modules in `lib/`. The house style is written and working.
2. **VAT** — `lib/vat.typ` decides which case applies, `config/tax/<regime>.yaml` holds the wording.
3. **Data** — issuers in `config/issuers/<id>.yaml`, clients in `config/clients/<CCC>.yaml`.
4. **Language** — `en` or `it` per document, strings in `config/strings/<lang>.yaml`.

**The only dependency is the `typst` binary.** No compiler, no package manager, no build step.
If a task seems to need a second tool, it is the wrong task.

## A document

```typst
#import "/doctypes/offer.typ": offer

#show: offer.with(
  issuer: "axelered_si",
  client: "PRL", seq: 2, revision: "a",
  language: "it",
  date: "2026-08-19", valid-until: "2026-09-30",
  items: (
    (desc: "Analisi tecnica e architettura", price: 1500.00, qty: 1, kind: "service"),
    (desc: "Server rack 2U",                 price: 2200.00, qty: 2, kind: "goods"),
  ),
)

= Introduzione

Il fornitore si impegna a *consegnare*...
```

The author writes prose and items. Totals, VAT and legal clauses are computed, never typed.
The clause block is fixed: an offer prints all 23 clauses of `config/clauses/offer.<lang>.yaml`,
in order, numbered 1..23. A document neither selects nor reorders them, and the English bodies
are the originals transcribed from the signed offer SDS24-01F — they are not to be reworded.
One deviation is recorded and deliberate: the issuing party is the `Supplier`, not the
`Provider` of the original, so a single word names it in the clauses, in the party heading and
in the signature block. **The two parties are the Supplier and the Client, in both languages —
`Fornitore` and `Cliente` — and no synonym for either appears anywhere.**
`kind` is mandatory on every item, `"goods"` or `"service"`. There is no default and no
inference — a missing `kind` is an error, because it decides the VAT treatment.

## Layout

```
lib/          money.typ vat.typ page.typ tables.typ blocks.typ clauses.typ signature.typ
doctypes/     offer.typ spec.typ invoice.typ cmr.typ — one per document type
config/       issuers/, clients/, clauses/, strings/, tax/
assets/       logo.svg, sign.png, fonts/
documents/    templates/ (starters to copy), YYMM_project/ (the real work), fixtures/ (invented ones)
tests/        assert-based, a test that compiles has passed
out/          test renders only, git ignored
```

Seven directories, seven roles. `config/` and `documents/` are the author's. `lib/`, `doctypes/`
and `tests/` are the program's. `assets/` is fixed and `out/` is disposable.

**`documents/` is organised by project, not by year.** One folder per project,
`YYMM_project` — the month the project started, then its name: `2608_prl`. Inside it live all
the sheets that project produces, offer, spec, proforma, invoice and CMR together, at whatever
depth suits it. **The PDF is written next to the source it came from** and is committed with
it, so a project folder is the whole project, readable without a typst binary. Nothing in the
tree is keyed to the year: `documents/2026/` survives from the previous scheme and is left
alone, and the renderer finds a document by searching, not by computing a path.

Logic lives in `lib/`, never in `doctypes/`. A doctype is ~20 lines calling functions: it names
the blocks a document type is made of, in order, and nothing else.

An invoice and a proforma are the same sheet, so there is one doctype and one starter for the
two: `proforma: true` switches the tag to `pin` and the title with it. `revision` is a letter on
a proforma and empty on an invoice.

`doctypes/` is code and is never edited to write a document. `documents/templates/` holds the
starter files an author copies into a project folder.

## Issuer, language, and where a piece of text lives

Three independent axes, one home each. Getting this wrong is how a file turns into a mess of
half-translated facts.

| Axis | Chosen by | Home | Holds |
|---|---|---|---|
| Issuer | `issuer:` on the document | `config/issuers/<id>.yaml` | names, address, tax ids, bank accounts, registry footer, house defaults, `tax_regime` |
| Language | `language:` on the document | `config/strings/<lang>.yaml` | every fixed sentence and label printed on a sheet |
| Client | `client:` on the document | `config/clients/<CCC>.yaml` | the buyer, and the facts the VAT rules read |

An issuer file carries no boilerplate and a strings file carries no facts. A field that varies
on **both** axes — a fragment of prose naming this issuer — carries a per-language map in the
issuer file. There are exactly two: `signatory.role` and `legal.governing_law`. Anything else
bilingual in an issuer file is a bug.

Proper names — cities, courts, registries — stay in their original language and are never
translated. `Sežana`, `Okrožno sodišče v Kopru`.

`issuer:` is optional; omitted, a document takes `default-issuer` in `lib/model.typ`, which is
`axelered_si`. The starters write it out anyway, so the author sees which company is signing.

A second issuer is a second file plus its tax regime: `config/issuers/axelered_ae.yaml` and
`config/tax/ae.yaml` exist as skeletons, and `lib/vat.typ` has a `resolve-ae` that panics until
someone writes the rules. Both are all TODO — no UAE data has been supplied yet.

## Commands

```sh
.\render.ps1 260819offPRL002a            # compile, PDF next to the source
.\render.ps1 -Watch 260819offPRL002a     # live preview
./render.sh --watch 260819offPRL002a     # the POSIX twin, keep the two in step
```

A bare number is enough: the renderer searches `documents/` for `<number>.typ` at any depth,
and refuses if the number is missing or matches twice. An explicit path also works and is the
only way to render something the search cannot name. Underneath it is one call:

```sh
typst compile --font-path assets/fonts --root . --input document=260819offPRL002a \
  documents/2608_prl/260819offPRL002a.typ documents/2608_prl/260819offPRL002a.pdf
```

`typst watch` is the live preview. Validation is compilation: an unresolvable case calls
`panic()` and no PDF comes out.

## VAT

Six cases, and the **order** they are tried in is the rule. Destination decides first, because
it has no exception. Then each destination picks its own second axis, and the two are not the
same: inside the Union the customer's status comes before the kind of the line, outside it the
kind comes before the status.

| # | Condition | Treatment | Key |
|---|---|---|---|
| 1 | SI → SI, VAT ID | Slovenian VAT 22% | `b2b_si` |
| 2 | SI → non-EU, goods | Exempt, export — **B2B and B2C alike** | `export_goods` |
| 3 | SI → non-EU, service, B2B | Outside SI scope | `noneu_service` |
| 4 | SI → non-EU, service, B2C | `panic()` — ZDDV-1 30.d vs 25(2), see below | — |
| 5 | SI → EU, VAT ID, goods | Exempt, intra-Community supply | `b2b_eu_goods` |
| 6 | SI → EU, VAT ID, service | Reverse charge | `b2b_eu_service` |
| 7 | anything left | Slovenian VAT 22% | `b2c` |

Why that asymmetry: inside the Union the exemption exists only because the tax is accounted for
elsewhere in the common system, which needs an identified taxable person — so the VAT ID is
tested first. Outside the Union there is no common system: goods are exempt because they
physically leave (ZDDV-1 52(1)(a), which says nothing about who buys), services follow the
customer. **`b2c` is not a case, it is the floor of the cascade** — what is left once no rule of
territoriality and no exemption has taken the supply somewhere else.

Row 4 refuses on purpose. A service to a consumer outside the EU is outside Slovenian VAT if it
falls under the closed list of ZDDV-1 30.d (consultancy, engineering, data processing,
licensing — most of what this company sells) and Slovenian VAT if it does not, and a document
carries nothing that tells the two apart.

Cases 5 and 6 demand `vies-checked: "YYYY-MM-DD"` on the document and refuse without it. Both
hold only if the client's VAT id was valid in VIES on the day of supply, and that is a fact of
the day rather than of the client: a company registered in March can be struck off in September,
so the date is recorded per document and never in `config/clients/`. It **must equal `date:`**,
because a check made a week ago proves nothing about today: the field therefore carries no
information the document does not already have, and that is the whole of it — it cannot be
filled in without querying VIES and cannot be left to age. Evidence, not wording: never printed.

Public administration is `b2b_si`: e-invoicing through UJP is an obligation of delivery, not a
VAT treatment, and changes nothing printed on the sheet.

Seven invented clients, `AAA`..`GGG` in `config/clients/`, reach every branch of the cascade —
refusals included — from a real sheet, one document each in `documents/fixtures/`. The tests
assert the key; the fixtures print the group, the label, the clause and the total.
**`FIXTURES.md`** — which one is which, and the three that must refuse to compile. Never
invoice one and never copy one into a project folder.

Three cases are knowingly out of scope, because no data on a document could decide them. Each
is a `TODO.md` entry and a comment at the branch it would belong to: domestic reverse charge
(76.a), goods installed at destination in another member state (20(3)), and the 10,000 EUR
distance-selling threshold (30.f), which is a fact of the year rather than of the document.

- `lib/vat.typ` resolves a key, one rule set per issuing jurisdiction, dispatched on the
  issuer country. `config/tax/<regime>.yaml` turns the key into `taxable` plus two pieces of
  wording in `sl`/`en`/`it`: `clause`, the article behind the treatment, which is printed, and
  `label`, its name, which is kept in the file but no longer printed. No legal wording in
  Typst, no rules in YAML, **and no tax wording in `config/strings/`** — a jurisdiction is one
  file, so a second issuer never touches a language file. `tests/config.typ` holds the two
  halves together.
- **Every group prints the same VAT line: the word `VAT`/`IVA` and the figure charged.** A
  taxable group adds the rate — `VAT 22%` — and its amount; a group that is not taxable charged
  nothing and prints `0.00 €`. What the treatment *is* stays underneath, in the clause, which is
  where the reader looks for the reason. Only one rate exists, `rates.standard`: Slovenia's
  reduced rates are not in the file because nothing in `lib/` could reach them.
- The items table is grouped by treatment: each group closes with its own taxable base, its
  own VAT line and the clause that justifies it, then the grand total closes the table. A
  document with one treatment simply prints one group. **VAT is charged on the base of the
  group, never line by line** — one rounding per group, which is what an accountant recomputes.
  A discount is an ordinary negative line and carries a `kind` like any other, so it lands in
  one group and lowers that base alone; a discount meant for the whole sheet is written as one
  line per treatment. One client fixes the country and the VAT id, so a real document can never
  mix a taxable group with an exempt one — every mix is two exempt groups.
- The clause is printed in the document language only. Slovenian is kept in `vat.yaml` for the
  day a Slovenian document is issued, and is no longer printed alongside.
- Unresolvable ⇒ `panic()`. Never default to taxable or exempt.
- An exemption whose clause text is empty for the document language is an error too, not a
  silent blank line.

## Money

EUR only, printed as `€` after the figure, two decimals always, including `.00`. The symbol is
`defaults.currency` in the issuer profile. **Integer cents everywhere.** Float arithmetic
is the one way this design silently produces a wrong invoice, so it lives only in `lib/money.typ`:
convert once on input, sum as integers, and round in exactly one place —
`calc.round(cents * rate / 100)`. No `calc` on money anywhere else.

Discounts are ordinary lines with a negative amount.

## Numbering

`YYMMDD` + `tag` + `CCC` + `NNN` + `r` — issue date, document type, client code, progressive,
revision letter. The number *is* the file name, source and PDF alike: `260819offPRL002a`. Tags
are `off`, `spc`, `pin`, `inv`, `cmr`. The progressive is typed by hand; there is no counter,
and it is per (year, client). Offers, specs and proformas carry a revision letter, invoices and
CMR notes never do.

**`NUMBERING.md` holds the rules.** Read it before touching anything that builds or asserts a
document number. The template asserts the computed number matches the file name. A countersigned
offer is saved by hand with a `_signed` suffix — that is the only document state tracked.

## State

Built and rendering real documents: `lib/` (money, vat, model, and the six layout modules),
`doctypes/` for offer, spec and invoice (which prints the proforma too), the starters in
`documents/templates/`, and
`render.sh` / `render.ps1`. Four test files, and they are the specification:

| File | Covers |
|---|---|
| `tests/money.typ` | cents, rounding, formatting |
| `tests/vat.typ` | the cascade, branch by branch |
| `tests/groups.typ` | `vat-groups`: bases, one rounding per group, order, labels, clauses, discounts |
| `tests/config.typ` | the seam — the keys `lib/vat.typ` returns are exactly the ones `config/tax/` declares |

A test that compiles has passed. Run all four before touching anything tax-related.

Multi-issuer is wired end to end: profiles, tax regime, bank accounts and footer are all read
per document. Only Slovenia is filled in.

Left to build: `doctypes/cmr.typ`, which needs a consignment data block that does not exist in
`config/` yet, and the UAE issuer — data, VAT rules and wording. See `TODO.md`.

## Rules

- Never invent legal or contractual text. If something is missing, leave a placeholder and note
  it in `TODO.md`.
- `--input draft=true` is the only way to render with wording still missing, and it prints a
  visible `[MISSING ...]` marker.
- No literal strings in templates — they come from `config/strings/<lang>.yaml`. Slovenian must
  stay possible to add.

## Not yet verified

Renders, but nobody has checked it. Before anything goes to a client:

| What | Who |
|---|---|
| `config/tax/si.yaml` — four clauses and four treatment labels | the accountant |
| `config/clauses/offer.it.yaml` — 23 clauses | holder of the original contract, then a lawyer. The English file is the verified original |
| `assets/fonts/` — Noto Sans stands in for the brand fonts | — |
| Brand colours — missing, `lib/tokens.typ` uses greys | — |

Open: per-client numbering vs Art. 82 ZDDV-1 · `Sezana` or `Sežana` on documents · thousands
separator above 999.99 · non-EU consumer VAT case.