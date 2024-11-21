// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import XCTest

final class NodeTests: XCTestCase {
    func testNodes() {
        _ =
            RootNode(
                [
                    TextNode("the quick brown fox"),
                ]
            )
    }
}
