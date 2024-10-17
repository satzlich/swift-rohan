// Copyright 2024 Lie Yan

import Foundation

/**
 Construction consisting of subscript and/or superscript
 */
final class MathScripts: MathExpression {
    let `subscript`: ContentSlot?
    let superscript: ContentSlot?

    init(subscript: ContentSlot?, superscript: ContentSlot?) {
        self.subscript = `subscript`
        self.superscript = superscript
    }
}
