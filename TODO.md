# TODO

Threads deliberately not pulled. Note it here, move on.

## Documents

| Item | Note |
|---|---|
| **Axelered LLC, Dubai** | The second issuer. The structure is in place and every field is a TODO: `config/issuers/axelered_ae.yaml` needs the trade licence data, the TRN, the bank account and the registry footer entries; `config/tax/ae.yaml` needs the rates, the case keys and the clause wording from a UAE accountant; `lib/vat.typ` needs `resolve-ae`, which panics today. Two knock-on items: money is EUR-only in `lib/money.typ` if the LLC ever bills in AED, and `NUMBERING.md` does not distinguish issuers, so two companies could compute the same number. |
| **VIES check on `260830invPRL005`** | The only document in `documents/2026/` carries `vies-checked: "2026-08-30"` and nobody has actually queried VIES for `IT01313650325`. The engine demands the field and checks it against the issue date, but it cannot verify the query happened: that part is on the author, for this document and every later one. |
| **CMR consignment note** | Last document to build, after the other four print real documents. Nothing exists yet: no doctype, and none of the required data exists in `config/` — carrier, vehicle plates, place of loading, place of unloading, number of packages, packaging type, gross weight, volume. Needs a new data block before any layout work starts. Its parties are **not** the two of every other sheet: boxes 1 and 2 of the consignment note are the sender and the consignee, who need not be the supplier and the client. `labels.supplier` / `labels.client` do not apply — the doctype needs its own two keys. |

## Tax engine, known limits

| Item | Note |
|---|---|
| **Reduced VAT rates** | `lib/model.typ` applies exactly one rate, `tax.rates.standard`. Slovenia's 9.5% reduced and 5% super-reduced rates are therefore **not** in `config/tax/si.yaml`, and `tests/config.typ` asserts they stay out: a rate declared but unreachable is a lie in a config file. Wiring them means a per-item rate, and relaxing that assertion in the same commit. Nothing Axelered sells is charged at either. |
| **`cases.<key>.label` is no longer printed** | The VAT row now reads `VAT`/`IVA` and a figure on every group, zero included, so the name of the treatment — `Exempt, export`, `Inversione contabile` — is dead wording. It is kept in `config/tax/si.yaml` and still demanded in all three languages by `tests/config.typ`, because the treatment may want naming again elsewhere on the sheet. Delete both, or find it a place. |
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
| EU territories outside the VAT territory | Dir. 2006/112 6 | The Canaries, Ceuta, Melilla, Livigno, Campione, Büsingen, Helgoland, the French overseas departments and Mount Athos are EU soil but outside the VAT territory: a supply there is an export, not an intra-Community one. They carry the country code of a member state, so `country in eu` puts them on the wrong branch and a document to Livigno prints `b2b_eu_goods`. | A postal-code or territory field on the client address, then a test above the `eu` membership check |
| Distance-selling threshold | ZDDV-1 30.f | Past 10,000 EUR of cross-border B2C supplies in a calendar year the rate is the customer country's, declared through OSS. That is a fact of the year, not of the document. | A turnover figure the generator does not have. Watch it outside the tool |


## Wording to verify before anything goes to a client

| What | Who |
|---|---|
| `config/tax/si.yaml` — four exemption clauses | the accountant |
| `config/clauses/offer.en.yaml` — 23 clauses | Done: transcribed from the signed offer SDS24-01F. Not to be reworded, with one recorded exception: the issuing party's defined term reads `Supplier` where the original read `Provider`, so that one word names it in the clauses, the party heading and the signature block alike. Clause 1 defines it and nothing uses it undefined. Worth a lawyer's nod at the next review, not a blocker. |
| `config/clauses/offer.it.yaml` — 23 clauses | holder of the original contract, then a lawyer |
| English clause 22 has no forum sentence, the Italian one does | The English original stops at the governing law; the Italian text also names `{{supplier.forum}}` as the exclusive forum. The two languages therefore differ in substance. A lawyer decides which one is right, then the other follows. |
| Clause 23 no longer states the page count | The original read "This Document has 7 pages." — a hand-typed number nothing generated can keep true. Dropped on purpose. |

## Config gaps found while rendering the first documents

| What | Note |
|---|---|
| `doctypes/cmr.typ` | Not written. See the CMR entry above. |
| Country printed inside a clause | `address.country` holds the ISO code, which the VAT cascade needs, so clause 1 prints "6210 Sezana, SI" where the original read "Sezana 6210, Slovenija". A printable country name would be a second field on the address. |
| `config/issuers/axelered_si.yaml` — `signatory.role` | Reads "Legal representative" / "Legale rappresentante"; the signed offers are signed "CEO at Axelered Doo". Pick one. |
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
| How `documents/` is organised | By project, not by year: `documents/YYMM_project/`, the month the project started plus its name, holding every sheet that project produces — offer, spec, proforma, invoice, CMR — at whatever depth suits it. The PDF is rendered next to its source and committed with it, so `out/` now takes test renders only. A bare number is resolved by searching `documents/` at any depth, which makes the number unique across the tree rather than within a year. `documents/2026/` is left in place from the old scheme; nothing reads it. |