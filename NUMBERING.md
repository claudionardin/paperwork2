# Document numbering

Document number and file name are the same string.

`YYMMDDtagCCCNNNr`

| Segment | Length | Meaning |
|---|---|---|
| `YYMMDD` | 6 | issue date |
| `tag` | 3 | document type |
| `CCC` | 3 | client code, `config/clients/<CCC>.yaml` |
| `NNN` | 3 | progressive, typed by hand |
| `r` | 0–1 | revision, lowercase letter `a`, `b`, `c`… — offer / spec / proforma only |

## Types

| Type | Tag | Revision |
|---|---|---|
| Offer | `off` | yes |
| Technical specification | `spc` | yes |
| Proforma invoice | `pin` | yes |
| Invoice | `inv` | no |
| CMR consignment note | `cmr` | no |

## Rules

1. `NNN` is progressive per (year, client), typed by hand. There is no counter.
2. `YYMMDD` is the issue date.
3. Revision starts at `a` and moves to the next letter on every version sent to the client. Internal drafts take no letter.
4. A revision never changes `NNN`.
5. An invoice number is never reused, never deleted, never reissued with different content. Corrections go through a credit note.
6. Gaps in `NNN` are allowed for offers, specs and proformas. Not for invoices.
7. A CMR exists only where goods are shipped.
8. `.typ` source and PDF share the name **and the folder** — the PDF is rendered next to its source, inside the project folder. A countersigned offer is saved by hand as `<number>_signed`.
9. The template recomputes the number from `date`, `type`, `client`, `seq`, `revision` and asserts it equals the file name. Mismatch ⇒ `panic()`.

Which number a document takes is the author's call, made when the document is written. Nothing
in this repository links one document to another or checks a relationship between them.

The number says nothing about where the file lives. Documents are filed by project —
`documents/YYMM_project/`, see `CLAUDE.md` — and the renderer finds a bare number by searching
`documents/` at any depth, so **a number must be unique across the whole tree**: two files
carrying it make the shorthand refuse.

## Open

| Point | Status |
|---|---|
| Per-client numbering vs Art. 82 ZDDV-1 | confirmed acceptable by the accountant |
| More than 999 documents per client in a year | not handled |