// Copyright 2024 Lie Yan

import Foundation

struct FontSize: Equatable, Hashable, Codable {
    let floatValue: Double

    init?(_ floatValue: Double) {
        guard FontSize.validateFloatValue(floatValue) else {
            return nil
        }

        self.floatValue = floatValue
    }

    static func validateFloatValue(_ floatValue: Double) -> Bool {
        /*
         We follow the practice of Microsoft Word:
            a) Value should be in the range of [1, 1638];
            b) Value should be a multiple of 0.5.
         */

        floatValue >= 1 && floatValue <= 1638 &&
            floatValue.truncatingRemainder(dividingBy: 0.5) == 0
    }
}
