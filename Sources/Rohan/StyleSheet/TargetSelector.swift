// Copyright 2024-2025 Lie Yan

import RohanMinimal

public struct TargetSelector: Equatable, Hashable, Codable {
    /** Target node type */
    public let type: NodeType

    /** Target intrinsic property to match */
    public let matcher: PropertyMatcher?

    init(_ type: NodeType, _ matcher: PropertyMatcher? = nil) {
        self.type = type
        self.matcher = matcher
    }

    public func with(matcher: PropertyMatcher?) -> TargetSelector {
        TargetSelector(type, matcher)
    }
}

// MARK: - Target Selectors

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
