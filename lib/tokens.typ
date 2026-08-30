// Design tokens. Every size, colour and font used by the templates lives here.
// TODO replace with the brand values once the issuer profile carries a colors block.

#let font-body = ("Noto Sans",)          // vendored in typst/assets/fonts and embedded in the binary
#let font-mono = ("Noto Sans",)

#let size-body = 9.5pt
#let size-small = 8pt
#let size-footer = 6.5pt
#let size-title = 18pt
#let size-h1 = 13pt
#let size-h2 = 11pt

#let ink = rgb("#1a1a1a")
#let muted = rgb("#6b6b6b")
#let rule = rgb("#c8c8c8")
#let navy = rgb("#0f2a47")               // the house colour: title, rules, top band
#let accent = rgb("#3f7ea6")             // the lighter half of the top band
#let band = rgb("#f2f2f2")

// Decorative full-bleed band across the very top of every page. Two weights of the same
// blue: a long navy run and a short accent tail on the right.
#let band-height = 3.2mm
#let band-tail = 34mm

#let page-margin = (top: 24mm, bottom: 24mm, left: 18mm, right: 18mm)
