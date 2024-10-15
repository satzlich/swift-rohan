// Copyright 2024 Lie Yan

import Foundation

enum FontStyle {
    case normal
    case oblique
    case italic
}

enum FontWeight {
    case regular
    case bold
}

enum FontStretch {
    case condensed
    case normal
    case expanded
}

struct FontSize: Equatable, Hashable {
    let floatValue: Double

    init?(_ floatValue: Double) {
        // We follow the practice of Microsoft Word: [1, 1638]
        guard floatValue >= 1 && floatValue <= 1638 else {
            return nil
        }

        self.floatValue = floatValue
    }
}
