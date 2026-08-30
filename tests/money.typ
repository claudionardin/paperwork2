// A test file that compiles has passed.
//   typst compile --root . tests/money.typ
#import "/lib/money.typ": to-cents, fmt, mul-qty, vat-of

// Input: prices are plain numbers in the document, converted once.
// calc.round is mandatory here: 1234.56 * 100 is not exactly 123456 in float.
#assert.eq(to-cents(58), 5800)
#assert.eq(to-cents(58.0), 5800)
#assert.eq(to-cents(1234.56), 123456)
#assert.eq(to-cents(-100.00), -10000)

// Output: always two decimals, decimal point, no thousands separator.
#assert.eq(fmt(5800), "58.00")
#assert.eq(fmt(-10000), "-100.00")
#assert.eq(fmt(5), "0.05")

// Quantity in thousandths, so 0.5 h and 1.25 units stay exact.
// Rounding is half away from zero.
#assert.eq(mul-qty(5800, 8000), 46400)
#assert.eq(mul-qty(3333, 500), 1667) // 1666.5

// VAT rate in percent, as stored in config/tax/<regime>.yaml. Same rounding.
#assert.eq(vat-of(76400, 22.0), 16808)
#assert.eq(vat-of(10000, 9.5), 950)
#assert.eq(vat-of(1, 22.0), 0)
