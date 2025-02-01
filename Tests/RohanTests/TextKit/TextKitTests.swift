// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct TextKitTests {
    @Test
    static func testBasic() {
        let root = RootNode([
            ParagraphNode([
                TextNode("The formula is "),
                EquationNode(
                    isBlock: true,
                    nucleus: ContentNode([
                        TextNode("f(n+2) = f(n+1) + f(n)"),
                        TextModeNode([
                            TextNode(", where "),
                        ]),
                        TextNode("n"),
                        TextModeNode([
                            TextNode(" is a natural number."),
                        ]),
                    ])
                ),
            ]),
        ])

        #expect(root.flatSynopsis() ==
            """
            The formula is ꞈf(n+2) = f(n+1) + f(n)ꞈ, where ꞈnꞈ is a natural number.
            """)
    }

    @Test
    static func testLocations() {
        let contentStorage = ContentStorage()
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
                    nucleus: ContentNode([TextNode("a+"), TextNode("b")])
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
            #expect(count == 17)
            #expect("\(documentRange.location)" == "[]:0")
            #expect("\(documentRange.endLocation)" == "[]:17")
        }

        // forward iterate
        do {
            var locations: [any TextLocation] = []
            var location = contentStorage.documentRange.location
            let end = contentStorage.documentRange.endLocation
            while true {
                locations.append(location)
                if location.compare(end) == .orderedSame { break }
                location = contentStorage.location(location, offsetBy: 1)!
            }
            #expect(locations.description ==
                """
                [[]:0, \
                [0→]:1, [0→]:2, [0→]:3, \
                [0→,3→]:1, [0→,3→]:2, [0→,3→]:3, [0→,3→]:4, \
                [0→]:8, \
                [9]:0, [9]:1, [9]:2, \
                [9,2→,nucleus]:0, [9,2→,nucleus]:1, [9,2→,nucleus]:2, [9,2→,nucleus]:3, \
                [9]:7, \
                []:17]
                """)
        }
        // backward iterate
        do {
            var locations: [any TextLocation] = []
            var location = contentStorage.documentRange.endLocation
            let start = contentStorage.documentRange.location
            while true {
                locations.append(location)
                if location.compare(start) == .orderedSame { break }
                location = contentStorage.location(location, offsetBy: -1)!
            }

            #expect(locations.description ==
                """
                [[]:17, \
                [9]:7, \
                [9,2→,nucleus]:3, [9,2→,nucleus]:2, [9,2→,nucleus]:1, [9,2→,nucleus]:0, \
                [9]:2, [9]:1, [9]:0, \
                [0→]:8, \
                [0→,3→]:4, [0→,3→]:3, [0→,3→]:2, [0→,3→]:1, \
                [0→]:3, [0→]:2, [0→]:1, \
                []:0]
                """)
        }
    }
}
