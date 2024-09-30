// Copyright 2024 Lie Yan

/**
 By default, a non-root formula adopts the same style as its parent.
 All exceptions are defined in the utility functions provided here.

 > Cramped or uncramped: A non-root formula inherits the cramped-ness of its parent,
 > except when it occupies one of the following positions:
 > - as a subscript,
 > - the denominator of a fraction,
 > - the nucleus of an accent,
 > - the nucleus of `\overline`, or
 > - the radicand of `\sqrt`.
 >
 > In these cases, it always switches to a cramped style.

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
