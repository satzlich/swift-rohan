// Copyright 2024 Lie Yan

import Foundation

/**
 Normal text
 */
extension Text: MathExpression {
}

/**
 Text mode environment inside math expression
 */
final class TextMode: MathExpression {
    let content: Content

    init(_ content: Content) {
        self.content = content
    }
}
