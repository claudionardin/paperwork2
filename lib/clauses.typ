#import "tokens.typ": *

// Numbered clauses, grouped under their section headings. Numbers and placeholder
// substitution are done by lib/model.typ; a body arrives here as finished plain text.
//
// Two page-break rules, and they are the whole of the layout logic here:
//
//   1. a clause is never split across two pages
//   2. a section heading is never left at the foot of a page without its first clause
//
// Both are `breakable: false`. The longest clause on file is about twenty lines, so neither
// rule can produce a block taller than a page; a clause that ever grows past one would push
// itself to the next page whole, which is still the right answer.

#let section-head(title) = block(above: 0em, below: 0.9em, {
  text(size: size-h2, weight: "bold", fill: navy, tracking: 0.4pt, upper(title))
  v(1.6mm, weak: true)
  line(length: 100%, stroke: 0.7pt + rule)
})

#let clause(c, below: 0.8em) = block(breakable: false, below: below, {
  text(weight: "bold", fill: navy)[#c.number.] + h(1.4mm)
  text(weight: "bold")[#c.title.] + h(1.2mm)
  c.body
})

#let clauses-block(data) = {
  if data.clauses.len() == 0 { return }
  let current-section = ""
  for c in data.clauses {
    if c.section != current-section {
      current-section = c.section
      // Rule 2: the heading and the clause under it travel together. The inner clause drops
      // its own trailing space, which the outer block supplies instead.
      block(above: 1.6em, below: 0.8em, breakable: false, {
        section-head(c.section)
        clause(c, below: 0em)
      })
    } else {
      clause(c)
    }
  }
}
