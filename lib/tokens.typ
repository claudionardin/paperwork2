// Design tokens. Every size, colour and font used by the templates lives here.
// TODO replace with the brand values once the issuer profile carries a colors block.

#let font-body = ("Noto Sans",)          // vendored in typst/assets/fonts and embedded in the binary
#let font-mono = ("Noto Sans",)

#let size-body = 9.5pt
#let size-small = 8pt
#let size-micro = 7pt                    // uppercase tracked labels: table head, party head
#let size-footer = 6.5pt
#let size-title = 20pt
#let size-h1 = 13pt
#let size-h2 = 11pt

// Letter-spacing for the small uppercase labels. One value, so every label on the sheet is
// spaced the same.
#let track-label = 0.7pt

// --- colour ------------------------------------------------------------------------------
// One family, four steps of the same blue plus two neutrals. Nothing on a sheet uses a colour
// that is not in this list.

#let navy = rgb("#0f2a47")               // the house colour: title, top band, table bars
#let accent = rgb("#3f7ea6")             // the lighter half of the band, rules, micro labels
#let ink = rgb("#16202b")                // body text, a navy-cast near-black
#let muted = rgb("#6b7684")              // secondary text, cool grey so it sits in the family
#let rule = rgb("#dbe2ea")               // hairlines
#let zebra = rgb("#f7f9fb")              // alternating item rows, the lightest wash there is
#let panel = rgb("#eef3f8")              // group summary rows, payment and delivery panels
#let on-navy = rgb("#ffffff")            // text on a navy bar
#let alert = rgb("#c0261c")              // the only warm colour on a sheet: a figure that is wrong
#let on-navy-alert = rgb("#ff9f96")      // the same warning, on the navy total bar

// Decorative full-bleed band across the very top of every page. Two weights of the same
// blue: a long navy run and a short accent tail on the right.
#let band-height = 3mm
#let band-tail = 34mm
#let band-bleed = 1mm                    // over-draw past the trim so no viewer shows a seam

// The short navy segment that opens the hairline over the footer and under the header.
#let rule-tick = 16mm

#let page-margin = (top: 24mm, bottom: 24mm, left: 18mm, right: 18mm)

// --- shared shapes -------------------------------------------------------------------------

// A small uppercase tracked label. Table heads, party heads, anything that names a field.
#let micro(body, fill: muted) = text(
  size: size-micro,
  weight: "bold",
  fill: fill,
  tracking: track-label,
  upper(body),
)

// A hairline that opens with a short navy tick. Used above the footer and below the header,
// so the two edges of the sheet are framed the same way.
#let tick-rule() = {
  place(line(length: 100%, stroke: 0.5pt + rule))
  line(length: rule-tick, stroke: 1pt + navy)
}

// A soft panel with an accent bar down its left edge. Payment and delivery sit in these.
// It is a grid cell rather than a block on purpose: a cell takes the height of its row, so two
// panels side by side end level whatever their contents. A block cannot — `height: 100%` inside
// a cell resolves against the page, not the row, and swallows the sheet.
#let soft-panel(body) = grid.cell(
  fill: panel,
  stroke: (left: 1.6pt + accent),
  inset: (left: 4mm, rest: 3.6mm),
  body,
)
