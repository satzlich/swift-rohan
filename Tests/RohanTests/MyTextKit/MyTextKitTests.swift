// Copyright 2024-2025 Lie Yan

import Foundation
import Rohan
import Testing

struct MyTextKitTests {
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

        // insert content
        contentStorage.replaceContents(
            in: contentStorage.documentRange,
            with: [
                ParagraphNode([
                    TextNode("The quick brown fox jumps over the lazy dog."),
                ]),
            ]
        )

        // document range
        let documentRange = contentStorage.documentRange
        let compareResult = documentRange.location.compare(documentRange.endLocation)
        #expect(compareResult == .orderedAscending)
    }
}
