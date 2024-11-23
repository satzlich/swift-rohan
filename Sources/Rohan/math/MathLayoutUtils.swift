// Copyright 2024 Lie Yan

import Foundation

enum MathLayoutUtils {
    /**
     ## Layout for accent

     > Accent attachment:
     The horizontal position of the attachment point for the accent mark is specified as
     the distance from the left side of the nucleus. By default, this value is half the
     width of the nucleus. However, in certain cases, it may be assigned a different value.
     When the nucleus consists of a single glyph, a math font typically provides this value.

     > Accent short fall:
     The amount by which the accent can be shorter than the base.
     This value is set to 0.5em.

     **Algorithm:**

     1. Perform a recursive layout of the nucleus with cramped = true, and denote
     the result as nucleus.
     2. Determine the math class and the accent attachment position of nucleus.
     3. Determine a proper glyph for the accent mark, taking into account
     the width of nucleus and the accent short fall.
        1. 

     */
    func layoutAccent() {
    }
}
