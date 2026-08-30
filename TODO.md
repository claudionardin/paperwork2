# TODO

Threads deliberately not pulled. Note it here, move on.

## Documents

| Item | Note |
|---|---|
| **Axelered LLC, Dubai** | The second issuer. The structure is in place and every field is a TODO: `config/issuers/axelered_ae.yaml` needs the trade licence data, the TRN, the bank account and the registry footer entries; `config/tax/ae.yaml` needs the rates, the case keys and the clause wording from a UAE accountant; `lib/vat.typ` needs `resolve-ae`, which panics today. Two knock-on items: money is EUR-only in `lib/money.typ` if the LLC ever bills in AED, and `NUMBERING.md` does not distinguish issuers, so two companies could compute the same number. |
| **VIES check on `260830invPRL005`** | The only document in `documents/2026/` carries `vies-checked: "2026-08-30"` and nobody has actually queried VIES for `IT01313650325`. The engine demands the field and checks it against the issue date, but it cannot verify the query happened: that part is on the author, for this document and every later one. |
| **CMR consignment note** | Last document to build, after the other four print real documents. Nothing exists yet: no doctype, and none of the required data exists in `config/` — carrier, vehicle plates, place of loading, place of unloading, number of packages, packaging type, gross weight, volume. Needs a new data block before any layout work starts. |

## Tax engine, known limits

| Item | Note |
|---|---|
| **Reduced VAT rates** | `lib/model.typ` applies exactly one rate, `tax.rates.standard`. Slovenia's 9.5% reduced and 5% super-reduced rates are therefore **not** in `config/tax/si.yaml`, and `tests/config.typ` asserts they stay out: a rate declared but unreachable is a lie in a config file. Wiring them means a per-item rate, and relaxing that assertion in the same commit. Nothing Axelered sells is charged at either. |
| **`labels.subtotal` in Italian** | Reads `Imponibile`, which is the taxable base. On a non-imponibile or out-of-scope group that word is at best loose. Ask the accountant whether the row should read differently when the group carries no VAT. |

## VAT cases deliberately out of scope

Each of these is real Slovenian law and each is unreachable from the data a document carries.
`lib/vat.typ` carries a comment at the branch it would belong to. None of them is work Axelered
sells today; if one becomes real, it needs a field before it needs a rule.

| Case | Law | Why it is not implemented | What it would take |
|---|---|---|---|
| Service to a consumer outside the EU | ZDDV-1 30.d vs 25(2) | Outside SI scope if in the closed list of 30.d (consultancy, engineering, data processing, licensing), Slovenian VAT if not. Both are plausible for what this company sells. **The engine panics rather than pick a rate.** | The accountant's ruling on the catalogue, then either a per-item flag or a blanket case |
| Domestic reverse charge | ZDDV-1 76.a | SI→SI construction, cleaning, supply of staff in construction, scrap. Nothing on a line says it is one of those. | A per-item classification |
| Goods installed at destination | ZDDV-1 20(3) | Hardware shipped **and installed** in another member state is not an intra-Community supply but a supply where it arrives. Today such a document silently prints `b2b_eu_goods`. | A per-item or per-document "installed at destination" flag, then the destination member state's treatment |
| Where goods physically go | ZDDV-1 46(1), 52(1) | Both exemptions turn on the destination of the goods, but the cascade reads `address.country`, which is where the client is **established**. `deliver-to` on the document is free text, so the engine cannot see the destination: a German company taking delivery in Slovenia prints `b2b_eu_goods` and should be taxable. | A structured delivery country on the document, defaulting to the client's, then a branch above case 5 |
| Distance-selling threshold | ZDDV-1 30.f | Past 10,000 EUR of cross-border B2C supplies in a calendar year the rate is the customer country's, declared through OSS. That is a fact of the year, not of the document. | A turnover figure the generator does not have. Watch it outside the tool |


## Wording to verify before anything goes to a client

| What | Who |
|---|---|
| `config/tax/si.yaml` — four exemption clauses | the accountant |
| `config/clauses/offer.{en,it}.yaml` — 29 clauses each | holder of the original contract, then a lawyer |

## Config gaps found while rendering the first documents

| What | Note |
|---|---|
| `doctypes/cmr.typ` | Not written. See the CMR entry above. |
| `config/strings/<lang>.yaml` — `footer.confidentiality` | The Italian text is a translation of the English one, not an approved wording. Have it confirmed. |
| Slovenian `config/strings/sl.yaml` | Does not exist. `config/tax/si.yaml` already carries the Slovenian VAT clauses for the day a Slovenian document is issued; the labels and boilerplate would have to follow. |

## Assets

| What | Note |
|---|---|
| `assets/fonts/` | Noto Sans stands in for the brand fonts |
| Brand colours | Not supplied. `lib/tokens.typ` uses a navy (`#0f2a47`) and an accent blue (`#3f7ea6`) for the top band, the title and the table rules. Swap them for the brand values when they exist. |

## Open questions

| Point | Status |
|---|---|
| More than 999 documents per client in a year | Not handled, and not needed for now. `NNN` overflows silently past 999. |

## Settled

| Point | Decision |
|---|---|
| Per-client numbering vs Art. 82 ZDDV-1 | Confirmed acceptable by the accountant. |
| `Sezana` or `Sežana` on documents | `Sežana`, with the caron. Already correct in `config/issuers/axelered_si.yaml`. |
| Where a piece of text lives | Issuer facts in `config/issuers/<id>.yaml`, printed sentences in `config/strings/<lang>.yaml`. Only `signatory.role` and `legal.governing_law` are bilingual in an issuer file. See CLAUDE.md. |
| `labels.quantity` in Italian | Fixed: `Quantità`, with the accent. |
| Thousands separator above 999.99 | Per language, from `config/strings/<lang>.yaml` → `number_format`. English `1,234.56`, Italian `1.234,56`. `lib/money.typ` defaults to the bare `1234.56`, which is the form `tests/money.typ` pins. |
| Non-EU consumer VAT case | Corrected. The old answer, "Slovenian VAT like any other B2C sale", was wrong: goods are an export under 52(1) whoever buys them, and a service turns on ZDDV-1 30.d. Cases `export_goods` and a refusal, asserted in `tests/vat.typ`. |
| `tests/vat.typ` fixture client code | Fixed to `XXX`. |