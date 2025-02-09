// Copyright 2024-2025 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct SelectionRangeTests {
    @Test
    static func test_validateInsertionPoint() {
        let rootNode = RootNode([
            HeadingNode(level: 1, [
                EmphasisNode([TextNode("Fibonacci")]),
                TextNode(" Sequence"),
            ]),
            ParagraphNode([
                TextNode("Fibonacci sequence is defined as follows:"),
                EquationNode(isBlock: true, [TextNode("f(n+2)=f(n+1)+f(n),")]),
                TextNode("where "),
                EquationNode(isBlock: false, [TextNode("n")]),
                TextNode(" is a positive integer."),
            ]),
        ])

        // Convenience function
        func validate(_ location: TextLocation) -> Bool {
            NodeUtils.validateTextLocation(location, rootNode)
        }

        do {
            // text
            let path: [RohanIndex] = [
                .nodeIndex(0), // heading
                .nodeIndex(0), // emphasis
                .nodeIndex(0), // text
            ]
            #expect(validate(TextLocation(path, 1)))
            #expect(validate(TextLocation(path, "Fibonacci".count)))
            #expect(validate(TextLocation(path, "Fibonacci".count + 1)) == false)
        }
        do {
            // element
            let path: [RohanIndex] = [
                .nodeIndex(1), // paragraph
                .nodeIndex(1), // equation
                .mathIndex(.nucleus), // nucleus
            ]
            #expect(validate(TextLocation(path, 0)))
            #expect(validate(TextLocation(path, 1)))
            #expect(validate(TextLocation(path, 2)) == false)
        }
        do {
            // invalid path
            let path: [RohanIndex] = [
                .nodeIndex(1), // paragraph
                .nodeIndex(1), // equation
            ]
            #expect(validate(TextLocation(path, 0)) == false)
            #expect(validate(TextLocation(path, 1)) == false)
        }
    }

    @Test
    static func test_validateSelectionRange_repairSelectionRange() {
        let rootNode = RootNode([
            HeadingNode(level: 1, [
                EmphasisNode([TextNode("Fibonacci")]),
                TextNode(" Sequence"),
            ]),
            ParagraphNode([
                TextNode("Fibonacci sequence is defined as follows:"),
                EquationNode(isBlock: true, [TextNode("f(n+2)=f(n+1)+f(n),")]),
                TextNode("where "),
                EquationNode(isBlock: false, [TextNode("n")]),
                TextNode(" is a positive integer."),
            ]),
        ])

        // Convenience function
        func validate(_ location: TextLocation, _ end: TextLocation) -> Bool {
            guard let range = RhTextRange(location: location, end: end)
            else { return false }
            return NodeUtils.validateTextRange(range, rootNode)
        }
        func repair(_ range: RhTextRange) -> (RhTextRange, modified: Bool)? {
            return NodeUtils.repairTextRange(range, rootNode)
        }
        func repair(_ location: TextLocation,
                    _ end: TextLocation) -> (RhTextRange, modified: Bool)?
        {
            guard let range = RhTextRange(location: location, end: end)
            else { return nil }
            return NodeUtils.repairTextRange(range, rootNode)
        }

        // Case a)
        do {
            // text
            let path: [RohanIndex] = [
                .nodeIndex(0), // heading
                .nodeIndex(0), // emphasis
                .nodeIndex(0), // text
            ]

            // validate
            #expect(validate(TextLocation(path, 1),
                             TextLocation(path, 3)))
            #expect(validate(TextLocation(path, 1),
                             TextLocation(path, "Fibonacci".count)))
            #expect(validate(TextLocation(path, 1),
                             TextLocation(path, "Fibonacci".count + 1)) == false)

            // repair
            guard let range = RhTextRange(location: TextLocation(path, 1),
                                          end: TextLocation(path, 3))
            else { #expect(Bool(false)); return }
            #expect(repair(range)! == (range, modified: false))

            guard let range = RhTextRange(location: TextLocation(path, 1),
                                          end: TextLocation(path, "Fibonacci".count))
            else { #expect(Bool(false)); return }
            #expect(repair(range)! == (range, modified: false))

            #expect(repair(TextLocation(path, 1),
                           TextLocation(path, "Fibonacci".count + 1)) == nil)
        }
        // Case b)
        do {
            let location = {
                let path: [RohanIndex] = [
                    .nodeIndex(0), // heading
                    .nodeIndex(2), // text
                ]
                return TextLocation(path, 1)
            }()
            let end = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(4), // text
                ]
                return TextLocation(path, 3)
            }()

            // validate
            #expect(validate(location, end) == false)

            // repair
            #expect(repair(location, end) == nil)
        }
        // Case c)
        do {
            let location = TextLocation([], 0) // heading
            let end = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(4), // text
                ]
                return TextLocation(path, 3)
            }()

            // validate
            #expect(validate(location, end))

            // repair
            let range = RhTextRange(location: location, end: end)!
            #expect(repair(range)! == (range, modified: false))
        }
        // Case d)
        do {
            let location = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(2), // text
                ]
                return TextLocation(path, 1)
            }()
            let end = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(4), // text
                ]
                return TextLocation(path, 3)
            }()
            // validate
            #expect(validate(location, end))
            // repair
            let range = RhTextRange(location: location, end: end)!
            #expect(repair(range)! == (range, modified: false))
        }
        // Case e)
        do {
            let location = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(1), // equation
                    .mathIndex(.nucleus), // nucleus
                    .nodeIndex(0), // text
                ]
                return TextLocation(path, 1)
            }()
            let end = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(3), // equation
                    .mathIndex(.nucleus), // nucleus
                    .nodeIndex(0), // text
                ]
                return TextLocation(path, 3)
            }()

            // validate
            #expect(validate(location, end) == false)

            // repair
            let fixedLocation = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                ]
                return TextLocation(path, 1)
            }()
            let fixedEnd = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                ]
                return TextLocation(path, 4)
            }()
            #expect(repair(location, end)! ==
                (RhTextRange(location: fixedLocation, end: fixedEnd)!, modified: true))
        }
        // Case f)
        do {
            let location = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(1), // equation
                    .mathIndex(.nucleus), // nucleus
                    .nodeIndex(0), // text
                ]
                return TextLocation(path, 2)
            }()
            let end = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                    .nodeIndex(4), // text
                ]
                return TextLocation(path, 3)
            }()
            // validate
            #expect(validate(location, end) == false)
            // repair
            let fixedLocation = {
                let path: [RohanIndex] = [
                    .nodeIndex(1), // paragraph
                ]
                return TextLocation(path, 1)
            }()
            #expect(repair(location, end)! ==
                (RhTextRange(location: fixedLocation, end: end)!, modified: true))
        }
    }
}
