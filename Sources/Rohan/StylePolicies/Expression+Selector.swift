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

    public static func invert(fontStyle: FontStyle) -> FontStyle {
        switch fontStyle {
        case .normal:
            return .italic
        case .italic:
            return .normal
        }
    }

    static func applyExpressionRule(_ properties: PropertyDictionary,
                                    _ styleSheet: StyleSheet) -> PropertyDictionary
    {
        let key = TextProperty.style
        let value = key.resolve(properties, styleSheet.defaultProperties)

        // invert
        let inverted = Emphasis.invert(fontStyle: value.fontStyle()!)

        var properties = properties
        properties[key] = .fontStyle(inverted)
        return properties
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

    static func applyExpressionRule(isBlock: Bool,
                                    _ properties: PropertyDictionary,
                                    _ styleSheet: StyleSheet) -> PropertyDictionary
    {
        var properties = properties
        // change layout mode
        properties[RootProperty.layoutMode] = .layoutMode(.math)

        // change math style
        let key = MathProperty.style
        if properties[key] == nil {
            properties[key] = .mathStyle(isBlock ? .display : .text)
        }
        return properties
    }
}
