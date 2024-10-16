// Copyright 2024 Lie Yan

import Foundation

protocol MathExpression: AnyObject {
}

/*
 MathExpression - [Slot]
 Slot - [MathExpression]
 */

/*
 # Bricks

 Text

 # Modes

 TextMode
    - content

 # Scripts

 subscript
 superscript

 # Styles

 bold: ?
 italic: ?
 upright: ?

 # Variants

 serif: ?
 sans: ?
 frak: ?
 mono: ?
 bb: ?
 cal: ?

 # Structures

 MathAccent
    - accentMark: UnicodeScalar
    - nucleus

 MathFraction
    - numerator
    - denominator

 MathOverline
    - nucleus

 MathUnderline
    - nucleus

 MathOverbrace
    - nucleus
    - annotation?

 MathUnderbrace
    - nucleus
    - annotation?

 MathRadical
    - radicand
    - degree?

 MathCases
    - delimiter: UnicodeScalar
    - cases: [N]

 MathVector
    - elements: [N]

 MathMatrix
    - elements: [M][N]

 # Abstractions with overloads

 RR := bb("R")
 CC := bb("C")
 vee := bold("v")
 xbar := accent("x", "macron")

 inverse(n) := frac("1", n)

 arrow(x) := accent(x, "arrow")
 arrow := rightarrow
 rightarrow := "→"


 */
