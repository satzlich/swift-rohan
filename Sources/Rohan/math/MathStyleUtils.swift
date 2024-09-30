// Copyright 2024 Lie Yan

/**
 Utility functions for math style

 # Full Math Style

 A formula's style is paired with a boolean state, indicating whether it is **cramped**
 or **uncramped**. To fully describe the style of a formula, we use a value of type
 `(MathStyle, Bool)`. By default, a non-root formula inherits this value from its parent.

 Exceptions related to the `MathStyle` component are defined by the utility functions
 provided here, while exceptions for the `Bool` (cramped or uncramped) component are
 outlined below.

 > To be or not to be (cramped)?:
 >
 > A non-root formula inherits its cramped or uncramped state from its parent,
 > except when it occupies one of the following positions:
 > - as a subscript,
 > - the denominator of a fraction,
 > - the nucleus of an accent,
 > - the nucleus of `\overline`, or
 > - the radicand of `\sqrt`.
 >
 > In these cases, it always switches to a **cramped** style.

 */
public enum MathStyleUtils {
    // MARK: - Fraction

    /**
     Given the style of a fraction, return the style of the numerator/denominator.
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

    // MARK: - Superscript/Subscript

    /**
     Given the style of a formula with a subscript and/or a superscript, return the
     style of the subscript/superscript.
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
}
