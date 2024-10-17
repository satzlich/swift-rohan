// Copyright 2024 Lie Yan

import Foundation

/**
 Construction consisting of subscript and/or superscript
 */
final class MathScripts: MathExpression {
    let `subscript`: ContentSlot?
    let superscript: ContentSlot?

    init(subscript: Content?, superscript: Content?) {
        self.subscript = `subscript`.map(ContentSlot.init)
        self.superscript = superscript.map(ContentSlot.init)
    }
}
