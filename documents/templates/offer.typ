// STARTER — offer. Copy to documents/<YYMM_project>/<number>.typ, rename to the number.
// Tag "off", carries a revision letter. See NUMBERING.md.
#import "/doctypes/offer.typ": offer

#show: offer.with(
  language: "en", // "it" | "en"
  issuer: "axelered_si", // config/issuers/<id>.yaml
  client: "XXX", // config/clients/<id>.yaml
  seq: 0, // progressive per (year, client), typed by hand
  revision: "a", // "a" on the first version sent, then "b", "c"…
  date: "2026-01-01", // ISO, == the YYMMDD of the file name
  vies: "2026-01-01", // "YYYY-MM-DD" == date → exempt | "no" → 22% | none → panic if exempt | anything else → ERROR on the figures
  valid-until: "2026-09-30", // "YYYY-MM-DD" | none → not printed
  signature: true, // true → dual signature block on the last page | false → no block
  pay-within: none, // auto → issuer default | <n> days | 0 → already paid, no bank | none → no payment block
  deliver-within: none, // auto → issuer default, and only if the sheet carries goods | <n> days | 0 → already delivered | none → no delivery block
  deliver-to: "", // "" → client's registered office | any string → printed verbatim
  items: (
    // kind: "service" | "goods" — mandatory
    (desc: "Platform development", price: 3000.00, qty: 1, kind: "service"),
    (desc: "Rack server, assembled", price: 2400.00, qty: 2, kind: "goods"),
    (desc: "Commercial discount", price: -400.00, qty: 1, kind: "service"),
  ),
)

// Everything below is the prose of the document, and here it is nothing but a formatting
// reference: every construct available, in order, source beside result. Delete all of it.

= Formatting reference

The sheet above — parties, priced table, totals, VAT, clauses, signatures — is built by the
renderer and cannot be written by hand. Everything from here down is yours.

== Inline text

#table(
  columns: (auto, 1fr),
  table.header([You write], [You get]),
  [`*strong*`], [*strong*],
  [`_emphasis_`], [_emphasis_],
  [`*_both_*`], [*_both_*],
  [`` `raw` ``], [`raw`],
  [`#strike[struck]`], [#strike[struck]],
  [`#underline[underlined]`], [#underline[underlined]],
  [`#overline[overlined]`], [#overline[overlined]],
  [`#highlight[highlighted]`], [#highlight[highlighted]],
  [`#smallcaps[Small Caps]`], [#smallcaps[Small Caps]],
  [`#upper[shout]` / `#lower[WHISPER]`], [#upper[shout] / #lower[WHISPER]],
  [`H#sub[2]O`], [H#sub[2]O],
  [`x#super[2]`], [x#super[2]],
  [`#text(fill: rgb("#c0261c"))[coloured]`], [#text(fill: rgb("#c0261c"))[coloured]],
  [`#text(size: 13pt)[larger]`], [#text(size: 13pt)[larger]],
  [`#text(tracking: 1pt)[tracked]`], [#text(tracking: 1pt)[tracked]],
  [`#box(fill: luma(230), inset: 3pt)[boxed]`], [#box(fill: luma(230), inset: 3pt)[boxed]],
)

== Punctuation and symbols

Typst rewrites the marks a keyboard cannot type. Type the source, never paste the glyph.

#table(
  columns: (auto, 1fr),
  table.header([You write], [You get]),
  [`a -- b`], [a -- b],
  [`a --- b`], [a --- b],
  [`and so on...`], [and so on...],
  [`"quoted"`], ["quoted"],
  [`10~kg`, a non-breaking space], [10~kg],
  [`#sym.arrow.r` `#sym.euro` `#sym.section`], [#sym.arrow.r #sym.euro #sym.section],
  [`#sym.checkmark` `#sym.dagger` `#sym.copyright`], [#sym.checkmark #sym.dagger #sym.copyright],
)

== Paragraphs and breaks

A blank line starts a new paragraph. Text is justified and hyphenated in the document
language. A backslash at the end of a line \
forces a break inside the same paragraph.

`#v(6mm)` opens vertical space and `#h(2cm)` horizontal space,#h(2cm)like that.
`#pagebreak()` starts a new page; `#pagebreak(weak: true)` does nothing if the page is already
empty. Both are named rather than used here, so this reference stays continuous.

== Headings

Three levels are styled by the house sheet: `=`, `==`, `===`.

=== Third level

A fourth level prints, but nothing in a business document needs one. A heading can carry a
label — `<sec-tables>` written after it — so it can be linked from anywhere:
#link(<sec-tables>)[jump to Tables]. A reference written `@sec-tables` would print the heading
number instead, and needs `#set heading(numbering: "1.")`, which the house sheet does not use.

== Lists

Bullets open with `-` and nest by indenting two spaces:

- First item
- Second item
  - Nested item
  - Another one
    - Third level
- Third item

Numbered lists open with `+` and count themselves:

+ Provisioning
+ Deployment
+ Acceptance

Markers can be changed for one list without touching the rest of the document. The `#[…]`
around the block is what keeps the change local:

#[
  #set list(marker: ([#sym.arrow.r], [#sym.dot.c]))
  #set enum(numbering: "1.a)")
  - Custom marker
    - Second level, second marker
  + Outer
    + Inner
]

A term list puts the term in bold and its description beside it:

/ Term: The description follows the colon, and wraps under itself when it is long enough to
  need a second line.
/ Second term: Another description.

Leaving a blank line between items makes the list loose, which prints with more air:

- Loose item, with space under it.

- Second loose item.

== Tables <sec-tables>

A table declares its columns, then its cells in reading order. `1fr` takes the space left
over, `auto` fits the content, and a length such as `22mm` is fixed.

#table(
  columns: (1fr, auto, 22mm),
  align: (left, center, right),
  table.header([Deliverable], [Format], [Week]),
  [Architecture proposal], [PDF], [2],
  [Platform, staging], [URL], [6],
  [Platform, production], [URL], [9],
)

Cells span columns or rows, and carry their own alignment and fill:

#table(
  columns: (1fr, 1fr, 1fr),
  table.header(table.cell(colspan: 3, align: center)[One header across three columns]),
  table.cell(rowspan: 2)[Two rows], [b], [c],
  [e], table.cell(fill: luma(235))[filled],
  [g], [h], [i],
)

== Figures and images

A figure numbers itself and carries a caption. Labelled, it can be cited: @fig-nodes.

#figure(
  table(
    columns: 2,
    table.header([Environment], [Nodes]),
    [Staging], [1],
    [Production], [3],
  ),
  caption: [Node allocation per environment.],
) <fig-nodes>

An image is a path from the project root, sized by width or by height:

#figure(
  image("/assets/logo.svg", width: 34mm),
  caption: [An image, scaled to a width.],
)

== Quotations, code and callouts

An inline quotation reads #quote[like this]; a block quotation carries its attribution:

#quote(block: true, attribution: [ISO 9001:2015, clause 8.2])[
  The organization shall ensure that it has the ability to meet the requirements for products
  and services to be offered to customers.
]

Code is fenced with three backticks and a language name, which turns on highlighting:

```sh
curl -X POST https://api.example.com/v1/orders \
  -H "Content-Type: application/json" \
  -d '{"sku": "RS-2U", "qty": 2}'
```

```python
def total(lines):
    return sum(line.price * line.qty for line in lines)
```

A callout is a filled block, and takes any content:

#block(
  fill: rgb("#eef3f8"),
  stroke: (left: 1.6pt + rgb("#3f7ea6")),
  inset: (left: 4mm, rest: 3.6mm),
  width: 100%,
)[
  *Note.* A block takes a fill, a stroke on any side it likes, an inset and a radius. This is
  the shape the payment and delivery panels are made of.
]

== Mathematics

Inline mathematics sits between dollar signs, $x = (a + b) / 2$. Put spaces inside the dollars
and it becomes a display equation instead:

$ sum_(i = 1)^n i = (n (n + 1)) / 2 $

Equations number themselves on request, and matrices and cases have their own syntax:

#[
  #set math.equation(numbering: "(1)")
  $
    A = mat(1, 2; 3, 4), quad
    f(x) = cases(
      x^2 & "if" x >= 0,
      -x & "otherwise",
    )
  $
]

== Links, references and footnotes

A bare URL prints as #link("https://axelered.com"), and a link can carry its own text:
#link("https://axelered.com")[the company site]. An address is
#link("mailto:info@axelered.com")[info\@axelered.com].

A footnote is written inline#footnote[And prints at the foot of the page it was called on,
  numbered automatically.] and needs nothing else.

A reference prints the number of what it points at, so it works on anything numbered:
@fig-nodes. Headings carry no number in the house style, so link to those instead:
#link(<sec-tables>)[Tables].

== Layout

Two columns, for a block that reads better narrow:

#columns(2)[
  #lorem(40)
]

A horizontal rule:

#line(length: 100%, stroke: 0.5pt + luma(200))

Shapes take content and sit inline: #box(rect(width: 8mm, height: 3mm, fill: rgb("#0f2a47")))
#box(circle(radius: 1.6mm, fill: rgb("#3f7ea6"))) — a legend swatch, for instance.

A grid is a table that draws nothing. It is the tool for putting two blocks side by side:

#grid(
  columns: (1fr, 1fr),
  column-gutter: 5mm,
  [*Left.* A grid takes the same column syntax as a table and no rules of its own.],
  [*Right.* Use a grid for layout and a table for data.],
)

== Escapes and filler

A character Typst would read as markup is escaped with a backslash: \*not bold\*, \#not a
function, \_not italic\_, and `\\` for the backslash itself.

`#lorem(25)` writes filler while a section is being drafted: #lorem(25)
