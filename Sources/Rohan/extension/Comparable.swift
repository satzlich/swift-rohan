// Copyright 2024 Lie Yan

import Foundation

extension Comparable {
    /**

     - SeeAlso: Code for Rust
     [`f64.clamp()`](https://doc.rust-lang.org/core/primitive.f64.html#method.clamp)
     */
    func clamped(_ min: Self, _ max: Self) -> Self {
        precondition(min <= max)

        if self < min {
            return min
        }
        else if self > max {
            return max
        }
        else {
            return self
        }
    }
}
