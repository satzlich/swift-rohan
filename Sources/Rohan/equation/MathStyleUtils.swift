// Copyright 2024 Lie Yan

public enum MathStyleUtils {
    // MARK: - Scripts

    /**
     Returns the script style of the given style.

     # Functionality
     Consider a sub-formula consisting of a nucleus with a subscript or a superscript
     or both. Given the style of the sub-formula, returns the style of the
     superscript/subscript.
     */
    public static func scriptStyle(of style: MathStyle) -> MathStyle {
        switch style {
        case .Display,
             .Text:
            return .Script
        case .Script:
            return .ScriptScript
        case .ScriptScript:
            return .ScriptScript
        }
    }

    public static func superscriptCramped(of cramped: Bool) -> Bool {
        cramped
    }

    public static func subscriptCramped(of cramped: Bool) -> Bool {
        true
    }

    // MARK: - Fraction

    /**
     Returns the numerator/denominator style of the given style.

     # Functionality
     Consider a fraction consisting of a numerator and a denominator.
     Given the style of the fraction, returns the style of the numerator/denominator.
     */
    public static func fractionStyle(of style: MathStyle) -> MathStyle {
        switch style {
        case .Display:
            return .Text
        case .Text:
            return .Script
        case .Script,
             .ScriptScript:
            return .ScriptScript
        }
    }

    public static func numeratorCramped(of cramped: Bool) -> Bool {
        cramped
    }

    public static func denominatorCramped(of cramped: Bool) -> Bool {
        true
    }
}
