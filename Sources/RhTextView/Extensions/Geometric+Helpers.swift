// Copyright 2024 Lie Yan

import AppKit
import CoreGraphics
import Foundation
import Numerics

extension CGPoint {
    func isApproximatelyEqual(to other: CGPoint) -> Bool {
        x.isApproximatelyEqual(to: other.x) &&
            y.isApproximatelyEqual(to: other.y)
    }
}

extension CGRect {
    func isApproximatelyEqual(to other: CGRect) -> Bool {
        origin.isApproximatelyEqual(to: other.origin) &&
            size.isApproximatelyEqual(to: other.size)
    }
}

extension CGSize {
    func isApproximatelyEqual(to other: CGSize) -> Bool {
        width.isApproximatelyEqual(to: other.width) &&
            height.isApproximatelyEqual(to: other.height)
    }
}
