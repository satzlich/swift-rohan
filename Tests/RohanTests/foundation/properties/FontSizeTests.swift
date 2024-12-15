// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.propertyValues))
struct FontSizeTests {
    @Test
    static func testValidation() {
        #expect(!FontSize.validate(floatValue: 0.5))
        #expect(FontSize.validate(floatValue: 1))
        #expect(FontSize.validate(floatValue: 10))
        #expect(FontSize.validate(floatValue: 10.5))
        #expect(!FontSize.validate(floatValue: 10.8))
        #expect(FontSize.validate(floatValue: 1638))
        #expect(!FontSize.validate(floatValue: 1639))
    }
}
