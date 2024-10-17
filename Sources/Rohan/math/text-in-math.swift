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
    let content: TextContent

    init(_ content: TextContent) {
        self.content = content
    }
}
