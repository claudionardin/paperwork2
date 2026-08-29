#import "tokens.typ": *

// Numbered clauses, grouped under their section headings. Numbers and placeholder
// substitution are done by lib/model.typ; a body arrives here as finished plain text.
#let clauses-block(data) = {
  if data.clauses.len() == 0 { return }
  let current-section = ""
  for c in data.clauses {
    if c.section != current-section {
      current-section = c.section
      block(above: 1.4em, below: 0.7em, text(size: size-h2, weight: "bold", tracking: 0.4pt, upper(c.section)))
    }
    block(below: 0.8em, {
      text(weight: "bold")[#c.number. #c.title.] + h(1.2mm)
      c.body
    })
  }
}
