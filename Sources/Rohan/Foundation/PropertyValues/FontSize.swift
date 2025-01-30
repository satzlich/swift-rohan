// Copyright 2024-2025 Lie Yan

import Foundation

public struct FontSize: Equatable, Hashable, Codable {
    public let floatValue: Double

    public init(_ floatValue: Double) {
        precondition(FontSize.validate(floatValue: floatValue))
        self.floatValue = floatValue
    }

    public static func validate(floatValue: Double) -> Bool {
        /*
         We follow the practice of Microsoft Word:
            a) Value should be in the range of [1, 1638];
            b) Value should be a multiple of 0.5.
         */

        floatValue >= 1 && floatValue <= 1638 &&
            floatValue.truncatingRemainder(dividingBy: 0.5) == 0
    }
}

extension FontSize: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension FontSize: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(Double(value))
    }
}
