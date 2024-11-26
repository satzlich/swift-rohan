// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

@Suite
struct StyleAttributes_ {
    @Test func countOfAttributes() {
        #expect(StyleAttributes.allCases.count == 15)
    }
}
