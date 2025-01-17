// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct NodePoplicyTests {
    @Test
    static func testText() {
        #expect(TextNode.validate(string: "ABC\r\nxyz") == false)
        #expect(TextNode.validate(string: "ABC\rxyz") == false)
        #expect(TextNode.validate(string: "ABC\nxyz") == false)
        #expect(TextNode.validate(string: "ABCxyz") == true)
    }
}
