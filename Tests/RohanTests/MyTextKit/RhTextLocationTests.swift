// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct RhTextLocationTests {
    @Test
    static func testLocationIteration() {
        let contentStorage: RhTextContentStorage = .init()
        let nodes: [Node] = [
            HeadingNode(
                level: 1,
                [TextNode("ab"),
                 EmphasisNode([TextNode("cd😀")])]
            ),
            ParagraphNode([
                TextNode("ef"),
                EquationNode(
                    isBlock: false,
                    nucleus: ContentNode([TextNode("a+b")])
                ),
            ]),
        ]
        // insert
        contentStorage.replaceContents(in: contentStorage.documentRange, with: nodes)

        // check document range
        do {
            let documentRange = contentStorage.documentRange
            let count = contentStorage.offset(from: documentRange.location,
                                              to: documentRange.endLocation)
            #expect(count == 10)
        }

        // forward iterate
        do {
            var locations: [any RhTextLocation] = []
            var location = contentStorage.documentRange.location
            let end = contentStorage.documentRange.endLocation
            while location.compare(end) == .orderedAscending {
                locations.append(location)
                location = contentStorage.location(location, offsetBy: 1)!
            }

            #expect(locations.description ==
                """
                [[0,0]:0, \
                [0,0]:1, \
                [0,0]:2, \
                [0,1,0]:1, \
                [0,1,0]:2, \
                [0,1,0]:3, \
                [1,0]:1, \
                [1,0]:2, \
                [1,1,nucleus,0]:1, \
                [1,1,nucleus,0]:2]
                """)
        }
        // backward iterate
        do {
            var locations: [any RhTextLocation] = []
            var location = contentStorage.documentRange.endLocation
            let start = contentStorage.documentRange.location
            while location.compare(start) == .orderedDescending {
                locations.append(location)
                location = contentStorage.location(location, offsetBy: -1)!
            }

            #expect(locations.description ==
                """
                [[1,1,nucleus,0]:3, \
                [1,1,nucleus,0]:2, \
                [1,1,nucleus,0]:1, \
                [1,1,nucleus,0]:0, \
                [1,0]:1, \
                [1,0]:0, \
                [0,1,0]:2, \
                [0,1,0]:1, \
                [0,1,0]:0, \
                [0,0]:1]
                """)
        }
    }
}
