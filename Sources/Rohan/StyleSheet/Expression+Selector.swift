// Copyright 2024-2025 Lie Yan

import Foundation
import RohanCommon

extension Heading {
    public static func selector(level: Int? = nil) -> TargetSelector {
        func matcher(level: Int) -> PropertyMatcher {
            precondition(validate(level: level))
            return PropertyMatcher(.level, .integer(level))
        }

        return level != nil
            ? TargetSelector(.heading, matcher(level: level!))
            : TargetSelector(.heading)
    }
}

extension Emphasis {
    public static func selector() -> TargetSelector {
        TargetSelector(.emphasis)
    }
}

extension Equation {
    public static func selector(isBlock: Bool? = nil) -> TargetSelector {
        func matcher(isBlock: Bool) -> PropertyMatcher {
            PropertyMatcher(.isBlock, .bool(isBlock))
        }

        return isBlock != nil
            ? TargetSelector(.equation, matcher(isBlock: isBlock!))
            : TargetSelector(.equation)
    }
}
