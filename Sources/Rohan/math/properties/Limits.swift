// Copyright 2024 Lie Yan

import Foundation
import UnicodeMathClass

/**
 Describes in which situration limits should be attached.

 */
enum Limits: Equatable, Hashable, Codable {
    /// Never attach limits, that is, always attach scripts
    case never
    /// Attach limits only in `display` style
    case display
    /// Always attach limits
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
