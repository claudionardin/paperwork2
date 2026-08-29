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
2. **VAT** — `lib/vat.typ` decides which case applies, `config/tax/vat.yaml` holds the wording.
3. **Data** — issuer in `config/company.yaml`, clients in `config/clients/<CCC>.yaml`.
4. **Language** — `en` or `it` per document, strings in `config/strings/<lang>.yaml`.

**The only dependency is the `typst` binary.** No compiler, no package manager, no build step.
If a task seems to need a second tool, it is the wrong task.

## A document

```typst
#import "/doctypes/offer.typ": offer

#show: offer.with(
  client: "PRL", seq: 2, revision: "a",
  language: "it",
  date: "2026-08-19", valid-until: "2026-09-30",
  clauses: ("contract", "validity", "ip"),
  items: (
    (desc: "Analisi tecnica e architettura", price: 1500.00, qty: 1, kind: "service"),
    (desc: "Server rack 2U",                 price: 2200.00, qty: 2, kind: "goods"),
  ),
)

= Introduzione

Il fornitore si impegna a *consegnare*...
```

The author writes prose and items. Totals, VAT and legal clauses are computed, never typed.
`kind` is mandatory on every item, `"goods"` or `"service"`. There is no default and no
inference — a missing `kind` is an error, because it decides the VAT treatment.

## Layout

```
lib/          money.typ vat.typ page.typ tables.typ blocks.typ clauses.typ signature.typ
doctypes/     offer.typ spec.typ proforma.typ invoice.typ cmr.typ — one per document type
config/       company.yaml, clients/, clauses/, strings/, tax/vat.yaml
assets/       logo.svg, sign.png, fonts/
documents/    templates/ (starters to copy) and YYYY/ (the real documents)
tests/        assert-based, a test that compiles has passed
out/          git ignored
```

Seven directories, seven roles. `config/` and `documents/` are the author's. `lib/`, `doctypes/`
and `tests/` are the program's. `assets/` is fixed and `out/` is disposable.

Logic lives in `lib/`, never in `doctypes/`. A doctype is ~20 lines calling functions: it names
the blocks a document type is made of, in order, and nothing else.

`doctypes/` is code and is never edited to write a document. `documents/templates/` holds the
starter files an author copies into `documents/YYYY/`.

## Commands

```sh
typst compile --font-path assets/fonts --root . documents/2026/260819offPRL002a.typ out/260819offPRL002a.pdf
typst watch   --font-path assets/fonts --root . documents/2026/260819offPRL002a.typ out/260819offPRL002a.pdf
```

`typst watch` is the live preview. Wrap both in `render.sh` / `render.ps1`, three lines each.
Validation is compilation: an unresolvable case calls `panic()` and no PDF comes out.

## VAT

| Case | Kind | Treatment | Key |
|---|---|---|---|
| SI → SI | any | Slovenian VAT 22% | `domestic` |
| SI → EU, VAT ID, B2B | goods | Exempt, intra-Community supply | `eu_b2b_goods` |
| SI → EU, VAT ID, B2B | service | Reverse charge | `eu_b2b_service` |
| SI → EU, no VAT ID, B2C | any | Slovenian VAT 22% | `eu_b2c` |
| SI → non-EU, B2B | goods | Exempt, export | `export_goods` |
| SI → non-EU, B2B | service | Outside SI scope | `non_eu_service` |
| SI → non-EU, B2C | any | Slovenian VAT 22% | `non_eu_b2c` |
| SI → SI public administration | any | Slovenian VAT 22% | `public_administration` |

Every B2C sale carries Slovenian VAT, wherever the buyer lives. Only a business, and only with
a VAT ID inside the EU, moves the tax off the invoice.

- `lib/vat.typ` resolves a key. `config/tax/vat.yaml` turns the key into `taxable` plus the
  clause text in `sl`/`en`/`it`. No legal wording in Typst, no rules in YAML.
- Mixed documents: one VAT summary row per treatment.
- Exemptions print the Slovenian wording alongside the document language — that text is the
  legally operative one.
- Unresolvable ⇒ `panic()`. Never default to taxable or exempt.
- An exemption whose clause text is empty for the document language is an error too, not a
  silent blank line.

## Money

EUR only, two decimals always, including `.00`. **Integer cents everywhere.** Float arithmetic
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
`doctypes/` for offer, spec, proforma and invoice, the starters in `documents/templates/`, and
`render.sh` / `render.ps1`. `tests/money.typ` and `tests/vat.typ` pass — they are the
specification, and a test that compiles has passed.

Left to build: `doctypes/cmr.typ`, which needs a consignment data block that does not exist in
`config/` yet. See `TODO.md`.

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
| `config/tax/vat.yaml` — six exemption clauses | the accountant |
| `config/clauses/offer.{en,it}.yaml` — 23 clauses each | holder of the original contract, then a lawyer |
| `assets/fonts/` — Noto Sans stands in for the brand fonts | — |
| Brand colours — missing, `lib/tokens.typ` uses greys | — |

Open: per-client numbering vs Art. 82 ZDDV-1 · `Sezana` or `Sežana` on documents · thousands
separator above 999.99 · non-EU consumer VAT case.