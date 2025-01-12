// Copyright 2024-2025 Lie Yan

import Foundation

public enum MathUtils {
    /// Determines if the character is one of a variety of integral signs
    public static func isIntegralChar(_ c: UnicodeScalar) -> Bool {
        switch c {
        case "∫" ... "∳", "⨋" ... "⨜":
            return true
        default:
            return false
        }
    }
}
