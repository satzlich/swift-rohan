// Copyright 2024 Lie Yan

import Foundation
import UnicodeMathClass

/**
 Defines situations where limits should be applied.
 */
enum Limits: Equatable, Hashable, Codable {
    /// Never apply limits; instead, attach scripts.
    case never
    /// Apply limits only in `display` style.
    case display
    /// Always apply limits.
    case always

    /// The default limit configuration if the given character is the base.
    static func forChar(_ char: UnicodeScalar) -> Limits {
        switch mathClass(char) {
        case .Large:
            MathCharUtils.isIntegralChar(char)
                ? .never
                : .display
        case .Relation: .always
        case _: .never
        }
    }

    /// The default limit configuration for a math class.
    static func forMathClass(_ `class`: MathClass) -> Limits {
        switch `class` {
        case .Large: .display
        case .Relation: .always
        case _: .never
        }
    }

    /// Whether limits should be displayed in this context
    func isActive(_ contextStyle: MathStyle) -> Bool {
        switch self {
        case .never: false
        case .display: contextStyle == .display
        case .always: true
        }
    }
}
