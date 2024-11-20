// Copyright 2024 Lie Yan

import Foundation

/**
 Construction consisting of subscript and/or superscript
 */
final class MathScripts: MathExpression {
    let `subscript`: Content?
    let superscript: Content?

    init(subscript: Content?, superscript: Content?) {
        self.subscript = `subscript`
        self.superscript = superscript
    }
}
