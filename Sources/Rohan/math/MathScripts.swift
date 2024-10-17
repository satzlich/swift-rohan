// Copyright 2024 Lie Yan

import Foundation

/**
 Construction consisting of subscript and/or superscript
 */
final class MathScripts: MathExpression {
    let `subscript`: Slot?
    let superscript: Slot?

    init(subscript: Slot?, superscript: Slot?) {
        self.subscript = `subscript`
        self.superscript = superscript
    }
}
