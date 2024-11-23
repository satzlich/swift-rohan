// Copyright 2024 Lie Yan

import Foundation

enum MathLayoutUtils {
    /**
     ## Layout accent

     > Accent attachment:
     The horizontal position of the attachment point for the accent mark is specified as
     the distance from the left side of the nucleus. By default, this value is half the
     width of the nucleus. However, in certain cases, it may be assigned a different value.
     When the nucleus consists of a single glyph, a math font typically provides this value.

     > Accent shortfall:
     The amount by which the accent can be shorter than the base.
     This value is set to 0.5em.

     **Algorithm:**

     1. Perform a recursive layout of the nucleus with `cramped = true`, and denote the result as `nucleus`.
     2. Determine the accent attachment position of the `nucleus`.
     3. Select an appropriate glyph for the accent mark, considering the width of the `nucleus` and the accent shortfall.
     4. Position the accent mark at the specified attachment point.
     5. Compute the various layout properties of the final result.

     */
    func layoutAccent() {
    }
}
