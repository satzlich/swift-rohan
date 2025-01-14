// Copyright 2024-2025 Lie Yan

import Foundation
import RohanMinimal
import Testing

struct RohanMinimalTests {
    @Test
    static func testInitialize() {
        let contentStorage: RhTextContentStorage = .init()
        let layoutManager: RhTextLayoutManager = .init()

        // set up text container
        layoutManager.textContainer = RhTextContainer()
        #expect(layoutManager.textContainer != nil)

        // set up layout manager
        contentStorage.setTextLayoutManager(layoutManager)
        #expect(contentStorage.textLayoutManager === layoutManager)
        #expect(layoutManager.textContentStorage === contentStorage)
    }
}
