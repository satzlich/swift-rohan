// Copyright 2024 Lie Yan

import Foundation

/**
 Construction consisting of subscript and/or superscript
 */
final class MathScripts: MathExpression {
    let `subscript`: MathContent?
    let superscript: MathContent?

    init(subscript: MathContent?, superscript: MathContent?) {
        self.subscript = `subscript`
        self.superscript = superscript
    }
}
