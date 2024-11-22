// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite
struct FontSizeTests {
    @Test
    static func init_() {
        #expect(FontSize(0.5) == nil)
        #expect(FontSize(1) != nil)
        #expect(FontSize(10) != nil)
        #expect(FontSize(10.5) != nil)
        #expect(FontSize(10.8) == nil)
        #expect(FontSize(1638) != nil)
        #expect(FontSize(1639) == nil)
    }
}
