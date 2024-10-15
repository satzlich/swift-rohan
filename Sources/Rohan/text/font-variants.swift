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
        guard FontSize.validate(floatValue) else {
            return nil
        }

        self.floatValue = floatValue
    }

    private static func validate(_ floatValue: Double) -> Bool {
        floatValue >= 1 && floatValue <= 1000
    }
}
