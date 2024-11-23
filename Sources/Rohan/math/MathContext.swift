// Copyright 2024 Lie Yan

import Foundation

final class MathContext {
    var font: Font
    var table: MathTable

    init?(_ font: Font) {
        guard let table = font.copyMathTable() else {
            return nil
        }

        self.font = font
        self.table = table
    }
}
