// Money. Integer cents everywhere, EUR only.
//
// Float arithmetic is the one way this design silently produces a wrong invoice, so it is
// confined to this file: convert once on input, sum as integers, and round in exactly one
// place. No `calc` on money anywhere else.
//
//   typst compile --root . tests/money.typ

// The single rounding point. Half away from zero, like a human filling in a form:
// 1666.5 becomes 1667, -1666.5 becomes -1667.
#let round(x) = int(calc.round(x))

// A price as written in the document becomes cents, once, here.
// calc.round is mandatory: 1234.56 * 100 is 123455.99999999999 in float.
#let to-cents(amount) = round(amount * 100)

// A quantity becomes thousandths, so 0.5 h and 1.25 units stay exact.
#let to-qty(quantity) = round(quantity * 1000)

// Digits in groups of three, from the right. An empty separator groups nothing.
#let group(digits, separator) = {
  if separator == "" { return digits }
  let length = digits.len()
  let out = ""
  for (i, digit) in digits.clusters().enumerate() {
    if i > 0 and calc.rem(length - i, 3) == 0 { out += separator }
    out += digit
  }
  out
}

// Cents to the printed string. Two decimals always, including .00.
//
// The separators default to the bare form — "1234.56", no grouping — which is what
// tests/money.typ pins down. The document language overrides them through
// config/strings/<lang>.yaml, so English prints 1,234.56 and Italian 1.234,56 from the
// same cents. Slovenian stays possible to add without touching this file.
#let fmt(cents, thousands: "", decimal: ".") = {
  let sign = if cents < 0 { "-" } else { "" }
  let abs = calc.abs(cents)
  let units = str(int(abs / 100))
  let decimals = calc.rem(abs, 100)
  sign + group(units, thousands) + decimal + if decimals < 10 { "0" } else { "" } + str(decimals)
}

// Line amount: cents times a quantity in thousandths.
#let mul-qty(cents, qty) = round(cents * qty / 1000)

// VAT amount: cents times a rate in percent, as stored in config/tax/<regime>.yaml.
#let vat-of(cents, rate) = round(cents * rate / 100)