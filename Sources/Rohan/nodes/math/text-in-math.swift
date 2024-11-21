// Copyright 2024 Lie Yan

import Foundation

/**
 Text mode environment inside math expression
 */
final class TextMode: MathExpression {
    let content: Content

    init(_ content: Content) {
        self.content = content
    }
}
