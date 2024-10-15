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

 TextMode
    - text: Text

 # Scripts

 subscript
 superscript

 # Styles

 bold: ?
 italic: ?

 # Variants

 MathSerif
 MathSans
 MathFrak
 MathMono
 MathBb
 MathCal

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

 # Abstractions

 RR := bb("R")
 CC := bb("C")
 xbar := accent("x", "macron")
 arrow(x) := accent(x, "arrow")

 */
