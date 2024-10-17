// Copyright 2024 Lie Yan

import Foundation

final class MathAccent: MathExpression {
    let nucleus: Content
    let accentMark: UnicodeScalar

    init(_ nucleus: Content, _ accentMark: UnicodeScalar) {
        self.nucleus = nucleus
        self.accentMark = accentMark
    }
}
