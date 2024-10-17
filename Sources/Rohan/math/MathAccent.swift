// Copyright 2024 Lie Yan

import Foundation

final class MathAccent: MathExpression {
    let nucleus: MathContent
    let accentMark: UnicodeScalar

    init(_ nucleus: MathContent, _ accentMark: UnicodeScalar) {
        self.nucleus = nucleus
        self.accentMark = accentMark
    }
}
