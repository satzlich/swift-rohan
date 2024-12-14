// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite(.tags(.propertyValues))
struct FontSizeTests {
    @Test
    static func testValidation() {
        #expect(!FontSize.validateFloatValue(0.5))
        #expect(FontSize.validateFloatValue(1))
        #expect(FontSize.validateFloatValue(10))
        #expect(FontSize.validateFloatValue(10.5))
        #expect(!FontSize.validateFloatValue(10.8))
        #expect(FontSize.validateFloatValue(1638))
        #expect(!FontSize.validateFloatValue(1639))
    }
}
