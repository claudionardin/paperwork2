# TODO

Threads deliberately not pulled. Note it here, move on.

## Documents

| Item | Note |
|---|---|
| **CMR consignment note** | Last document to build, after the other four print real documents. Nothing exists yet: no doctype, and none of the required data exists in `config/` — carrier, vehicle plates, place of loading, place of unloading, number of packages, packaging type, gross weight, volume. Needs a new data block before any layout work starts. |

## Wording to verify before anything goes to a client

| What | Who |
|---|---|
| `config/tax/vat.yaml` — six exemption clauses | the accountant |
| `config/clauses/offer.{en,it}.yaml` — 29 clauses each | holder of the original contract, then a lawyer |

## Config gaps found while rendering the first documents

| What | Note |
|---|---|
| `config/company.yaml` — `footer.confidentiality` | Single English string, printed as-is on Italian documents. Needs `en`/`it` keys like `payment_terms` already has. |
| `config/strings/it.yaml` — `labels.quantity` | Reads `Quantita`, missing the accent: `Quantità`. |
| `doctypes/cmr.typ` | Not written. See the CMR entry above. |

## Assets

| What | Note |
|---|---|
| `assets/fonts/` | Noto Sans stands in for the brand fonts |
| Brand colours | Missing. `lib/tokens.typ` uses greys |

## Open questions

| Point | Status |
|---|---|
| More than 999 documents per client in a year | Not handled, and not needed for now. `NNN` overflows silently past 999. |

## Settled

| Point | Decision |
|---|---|
| Per-client numbering vs Art. 82 ZDDV-1 | Confirmed acceptable by the accountant. |
| `Sezana` or `Sežana` on documents | `Sežana`, with the caron. Already correct in `config/company.yaml`. |
| Thousands separator above 999.99 | Per language, from `config/strings/<lang>.yaml` → `number_format`. English `1,234.56`, Italian `1.234,56`. `lib/money.typ` defaults to the bare `1234.56`, which is the form `tests/money.typ` pins. |
| Non-EU consumer VAT case | Slovenian VAT, like any other B2C sale. Case `non_eu_b2c`, asserted in `tests/vat.typ`. |
| `tests/vat.typ` fixture client code | Fixed to `XXX`. |