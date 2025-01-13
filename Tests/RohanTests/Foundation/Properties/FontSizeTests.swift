// Copyright 2024-2025 Lie Yan

@testable import RohanMinimal
import Foundation
import Testing

struct FontSizeTests {
    @Test
    static func test_validate() {
        #expect(FontSize.validate(floatValue: 0.5) == false)
        #expect(FontSize.validate(floatValue: 1))
        #expect(FontSize.validate(floatValue: 10))
        #expect(FontSize.validate(floatValue: 10.5))
        #expect(FontSize.validate(floatValue: 10.8) == false)
        #expect(FontSize.validate(floatValue: 1638))
        #expect(FontSize.validate(floatValue: 1639) == false)
    }
}
