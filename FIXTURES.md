# Fixtures

Seven invented clients, `AAA`..`GGG`, one document each in `documents/fixtures/`. Between them
they reach **every branch of the VAT cascade** of `lib/vat.typ`, refusals included, from a real
sheet — which is what `tests/vat.typ` cannot do: the tests assert the key, the fixtures print
the group, the label, the clause and the total.

**None of these is a real company.** Names, addresses, VAT ids and register numbers are made
up, and the VAT ids will never validate in VIES. They are never to be invoiced, and a fixture
is never copied into a project folder — copy a starter from `documents/templates/` instead.

| Code | Where | Status | Reaches |
|---|---|---|---|
| `AAA` | SI | VAT id | 1 `b2b_si` — 22%, goods and services in one group |
| `BBB` | SI | consumer | 7 `b2c` — 22%, the floor of the cascade at home |
| `CCC` | CH | business | 2 `export_goods` + 3 `noneu_service` — two exempt groups on one sheet |
| `DDD` | US | consumer | 2 `export_goods` — and 4, the refusal, if a service line is added |
| `EEE` | DE | VAT id | 5 `b2b_eu_goods` + 6 `b2b_eu_service` — needs `vies` |
| `FFF` | IT | no VAT id | 7 `b2c` — 22% abroad, the sheet in Italian, the only tax code |
| `GGG` | RS | `is_business` absent | 2 `export_goods` — and the refusal on a service line |

Every branch of `resolve-si` is in that table, in the order the engine evaluates them, and the
one branch that is not a case — a non-EU client whose file never said whether it is a business —
is `GGG`. What no client file can reach: the dispatch in `resolve`, which refuses an item whose
`kind` is neither `goods` nor `service`, an issuer established in the UAE until `resolve-ae` is
written, and any other country of establishment.

Rendering:

```powershell
.\render.ps1 260831invEEE001
```

The bare number resolves here like anywhere else: the renderer searches `documents/` at any
depth. The PDF lands in `documents/fixtures/`, next to its source.

## The three that must fail

Each is the point of the fixture, not an accident. Neither is committed as a document,
because a document that refuses to compile cannot live in the repository:

| Break | Expected |
|---|---|
| `DDD`, change the line to `kind: "service"` | panic — ZDDV-1 30.d against 25(2), no single treatment |
| `GGG`, add a `kind: "service"` line | panic naming `config/clients/GGG.yaml` — no `is_business` |
| `EEE`, set `vies: none` | panic — the exemption needs a check, and it has to be made on the day of issue |
| `EEE`, set `vies:` to any date other than `date:` | renders, with `ERROR` in place of the VAT figure and of the grand total |
| `EEE`, set `vies: "no"` | renders as a plain domestic sale: the exemption is dropped and the whole sheet is taxed at 22% |

## Not covered

The VAT cascade is complete. These are other axes, and no client file decides any of them:

| Axis | State |
|---|---|
| Doctype | every fixture is an invoice. No offer, so the 23 clauses and their `{{client.*}}` substitutions are not exercised here; no spec, no proforma |
| Issuer | only `axelered_si`. An AE issuer panics by design |
| Language | `en` and `it`. `sl` has no strings file |
| Payment, delivery | `auto` everywhere: `pay-within: 0`, an explicit `bank-account`, a literal `deliver-to` and `deliver-within: 0` are untried |

And the cases the engine knowingly does not implement, because nothing on a document could
decide them: domestic reverse charge (76.a), goods installed at destination in another member
state (20(3)), the distance-selling threshold (30.f). A further one has no `TODO.md` entry yet:
EU territories excluded from the VAT territory — the Canaries, Livigno, Campione, Büsingen —
which carry the country code of a member state and are treated as EU here. `TODO.md`.
