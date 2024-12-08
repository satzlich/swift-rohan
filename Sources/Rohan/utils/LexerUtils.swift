// Copyright 2024 Lie Yan

import Foundation

enum LexerUtils {
    static func validateIdentifier(_ text: String) -> Bool {
        try! #/[a-zA-Z_][a-zA-Z0-9_]*/#.wholeMatch(in: text) != nil
    }
}
