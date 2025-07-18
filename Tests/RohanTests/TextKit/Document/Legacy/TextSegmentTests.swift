// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

final class TextSegmentTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: true)
  }

  @Test @MainActor
  func testBasic() throws {
    let rootNode = RootNode([
      // #0 paragraph: arbitrary text
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      // #1 heading: test math nodes
      HeadingNode(
        .sectionAst,
        [
          TextNode("Alpha "),
          EquationNode(
            .inline,
            [
              TextNode("a+b+"),
              FractionNode(num: [TextNode("m+n")], denom: [TextNode("n")]),
              TextNode("+"),
              FractionNode(
                num: [TextNode("\u{200B}")], denom: [TextNode("n")]),
            ]
          ),
        ]),
      // #2 paragraph: test cross-paragraph selection together with #3
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      // #3 paragraph
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      // #4 heading: test nested math nodes
      HeadingNode(
        .sectionAst,
        [
          TextNode("Alpha "),
          EquationNode(
            .inline,
            [
              FractionNode(
                num: [
                  FractionNode(
                    num: [TextNode("a+b+c")],
                    denom: [TextNode("m+n")])
                ],
                denom: [TextNode("x+y+z")]
              )
            ]
          ),
        ]
      ),
    ])
    let documentManager = createDocumentManager(rootNode)

    var ranges: Array<RhTextRange> = [
      // heading -> text -> <offset>
      RhTextRange.parse("[↓1,↓0]:0..<[↓1,↓0]:2")!,
      // heading -> equation -> nucleus -> text -> <offset>
      RhTextRange.parse("[↓1,↓1,nuc,↓0]:1..<[↓1,↓1,nuc,↓0]:3")!,
      // heading -> equation -> nucleus -> fraction -> numerator -> text -> <offset>
      RhTextRange.parse("[↓1,↓1,nuc,↓1,num,↓0]:0..<[↓1,↓1,nuc,↓1,num,↓0]:2")!,
      // heading -> equation -> nucleus -> text -> <offset>
      // heading -> equation -> nucleus -> <offset>
      RhTextRange.parse("[↓1,↓1,nuc,↓0]:1..<[↓1,↓1,nuc]:2")!,
    ]

    do {
      let offset = "The quick brown fox jumps over".length
      let range = RhTextRange.parse("[↓2,↓0]:\(offset)..<[↓3,↓0]:\(offset)")!
      ranges.append(range)
    }

    do {
      let range = RhTextRange.parse("[↓1,↓1,nuc,↓3,num]:0..<[↓1,↓1,nuc,↓3,num]:0")!
      ranges.append(range)
    }

    do {
      // heading -> equation -> nucleus -> fraction -> numerator -> fraction ->
      // denominator -> text -> <offset>
      let path = TextLocation.parseIndices("[↓4,↓1,nuc,↓0,num,↓0,denom,↓0]")!
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)
      ranges.append(RhTextRange(location, end)!)
    }

    let pointsAndFrames: [(CGRect, Array<CGRect>)] =
      ranges.map { Self.getIndicatorAndFrames($0, documentManager) }

    let points = pointsAndFrames.map { $0.0 }
    let frames = pointsAndFrames.map { $0.1 }

    let expectedPoints: Array<String> = [
      "(5.00, 34.00, 0.00, 30.05)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(130.42, 37.84, 0.00, 14.00)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(174.80, 64.05, 0.00, 17.00)",
      "(194.65, 37.84, 0.00, 14.00)",
      "(81.57, 141.28, 0.00, 10.00)",
    ]
    let expectedFrames: Array<String> = [
      "[(5.00, 34.00, 18.12, 30.05)]",
      "[(70.66, 40.88, 24.45, 20.00), (95.11, 40.88, 8.86, 20.00)]",
      "[(130.42, 37.84, 23.18, 14.00)]",
      "[(70.66, 40.88, 24.45, 23.17), (95.11, 40.88, 33.31, 23.17), (128.42, 40.88, 35.58, 23.17)]",
      """
      [(174.80, 64.05, 49.66, 17.00),\
       (5.00, 81.05, 22.01, 17.00),\
       (5.00, 98.05, 169.80, 17.00)]
      """,
      "[(194.65, 37.84, 0.00, 14.00)]",
      "[(81.57, 141.28, 13.78, 10.00)]",
    ]

    for (i, point) in points.enumerated() {
      #expect(point.formatted(2) == expectedPoints[i], "i=\(i)")
    }

    for (i, frame) in frames.enumerated() {
      #expect(TextSegmentTests.formatFrames(frame) == expectedFrames[i], "i=\(i)")
    }

    let fileName = String(#function.dropLast(2))
    for (i, (point, frame)) in zip(points, frames).enumerated() {
      outputPDF("\(fileName)_\(i)", point, frame, documentManager)
    }
  }

  @Test @MainActor
  func testApplyNode() {
    let rootNode = RootNode([
      // #0 paragraph: arbitrary text
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      // #1 paragraph: test apply node
      ParagraphNode([
        TextNode("Newton's second law of motion: "),
        EquationNode(
          .inline,
          [
            ApplyNode(MathTemplateSamples.newtonsLaw, [])!,
            TextNode("."),
          ]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          MathTemplateSamples.philipFox,
          [
            [TextNode("Philip")],
            [TextNode("Fox")],
          ])!,
      ]),
      // #2 paragraph: test nested apply node
      ParagraphNode([
        TextNode("Sample of nested apply nodes: "),
        ApplyNode(
          MathTemplateSamples.doubleText,
          [
            [ApplyNode(MathTemplateSamples.doubleText, [[TextNode("fox")]])!]
          ])!,
      ]),
      // #3
      HeadingNode(
        .sectionAst,
        [
          EquationNode(
            .inline,
            [
              TextNode("m+"),
              ApplyNode(
                MathTemplateSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
              TextNode("+n"),
            ])
        ]),
      // #4
      ParagraphNode([
        EquationNode(
          .display,
          [
            ApplyNode(
              MathTemplateSamples.bifun,
              [
                [ApplyNode(MathTemplateSamples.bifun, [[TextNode("n+1")]])!]
              ])!
          ])
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)

    let ranges: Array<RhTextRange> = [
      RhTextRange.parse("[↓1,↓3,⇒0,↓0]:1..<[↓1,↓3,⇒0,↓0]:3")!,
      // paragraph -> apply -> #0 -> apply -> #0 -> text -> <offset>
      RhTextRange.parse("[↓2,↓1,⇒0,↓0,⇒0,↓0]:1..<[↓2,↓1,⇒0,↓0,⇒0,↓0]:3")!,
      // heading -> equation -> nucleus -> apply -> #0 -> text -> <offset>
      RhTextRange.parse("[↓3,↓0,nuc,↓1,⇒0,↓0]:0..<[↓3,↓0,nuc,↓1,⇒0,↓0]:1")!,
      // paragraph -> equation -> nucleus -> apply -> #0 -> apply -> #0
      // -> text -> <offset>
      RhTextRange.parse("[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1..<[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:3")!,
    ]

    let pointsAndFrames: [(CGRect, Array<CGRect>)] =
      ranges.map { Self.getIndicatorAndFrames($0, documentManager) }

    let points = pointsAndFrames.map { $0.0 }
    let frames = pointsAndFrames.map { $0.1 }
    let expectedPoints: Array<String> = [
      "(112.66, 52.23, 0.00, 17.00)",
      "(183.81, 86.23, 0.00, 17.00)",
      "(61.78, 130.05, 0.00, 10.00)",
      "(35.46, 159.24, 0.00, 12.00)",
    ]
    let expectedFrames: Array<String> = [
      "[(112.66, 52.23, 10.01, 17.00), (13.17, 69.23, 10.01, 17.00)]",
      """
      [(183.81, 86.23, 12.00, 17.00),\
       (226.83, 86.23, 11.70, 17.00),\
       (38.02, 103.23, 11.70, 17.00),\
       (81.00, 103.23, 12.00, 17.00)]
      """,
      "[(61.78, 130.05, 5.72, 10.00), (49.01, 140.76, 8.01, 14.00)]",
      """
      [(35.46, 159.24, 20.67, 12.00), (68.66, 159.24, 20.67, 12.00), \
      (118.16, 159.24, 20.67, 12.00), (151.37, 159.24, 20.67, 12.00)]
      """,
    ]

    for (i, point) in points.enumerated() {
      #expect(point.formatted(2) == expectedPoints[i], "i=\(i)")
    }

    for (i, frame) in frames.enumerated() {
      #expect(TextSegmentTests.formatFrames(frame) == expectedFrames[i], "i=\(i)")
    }

    let fileName = String(#function.dropLast(2))
    for (i, (point, frame)) in zip(points, frames).enumerated() {
      outputPDF("\(fileName)_\(i+1)", point, frame, documentManager)
    }
  }

  @Test @MainActor
  func testPlacerholder() {
    let rootNode = RootNode([
      HeadingNode(.sectionAst, [TextNode("H1")]),
      HeadingNode(.subsectionAst, []),
      HeadingNode(.subsubsectionAst, [TextNode("H3")]),
      HeadingNode(.subsubsectionAst, [TextNode("H4"), TextStylesNode(.emph, [])]),
      HeadingNode(.subsubsectionAst, [TextNode("H5")]),
      ParagraphNode([
        TextNode("Empty equation: "),
        EquationNode(.inline, []),
        TextNode("."),
      ]),
      ParagraphNode([
        TextNode("Empty equation: "),
        EquationNode(
          .inline,
          [
            FractionNode(num: [], denom: []),
            TextNode("+"),
            FractionNode(num: [], denom: [], genfrac: .binom),
          ]),
        TextNode("."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    let ranges: Array<RhTextRange> = [
      // heading -> <offset>
      RhTextRange.parse("[↓1]:0")!,
      // heading -> emphasis -> <offset>
      RhTextRange.parse("[↓3,↓1]:0")!,
      // paragraph -> equation -> nucleus -> <offset>
      RhTextRange.parse("[↓5,↓1,nuc]:0")!,
      // paragraph -> equation -> nucleus -> fraction -> numerator -> <offset>
      RhTextRange.parse("[↓6,↓1,nuc,↓0,num]:0")!,
      // paragraph -> equation -> nucleus -> fraction -> denominator -> <offset>
      RhTextRange.parse("[↓6,↓1,nuc,↓0,denom]:0")!,
      // paragraph -> equation -> nucleus -> binom -> numerator -> <offset>
      RhTextRange.parse("[↓6,↓1,nuc,↓2,num]:0")!,
      // paragraph -> equation -> nucleus -> binom -> denominator -> <offset>
      RhTextRange.parse("[↓6,↓1,nuc,↓2,denom]:0")!,
    ]

    let pointsAndFrames: [(CGRect, Array<CGRect>)] =
      ranges.map { Self.getIndicatorAndFrames($0, documentManager) }

    let points = pointsAndFrames.map { $0.0 }
    let frames = pointsAndFrames.map { $0.1 }
    let expectedPoints: Array<String> = [
      "(6.25, 29.00, 0.00, 27.00)",
      "(32.33, 79.00, 0.00, 23.00)",
      "(102.61, 129.33, 0.00, 12.55)",
      "(102.08, 143.49, 0.00, 8.79)",
      "(102.08, 153.37, 0.00, 8.79)",
      "(133.49, 143.49, 0.00, 8.79)",
      "(133.49, 153.37, 0.00, 8.79)",
    ]
    let expectedFrames: Array<String> = [
      "[(6.25, 29.00, 0.00, 27.00)]",
      "[(32.33, 79.00, 0.00, 23.00)]",
      "[(102.61, 129.33, 0.00, 12.55)]",
      "[(102.08, 143.49, 0.00, 8.79)]",
      "[(102.08, 153.37, 0.00, 8.79)]",
      "[(133.49, 143.49, 0.00, 8.79)]",
      "[(133.49, 153.37, 0.00, 8.79)]",
    ]

    for (i, point) in points.enumerated() {
      #expect(point.formatted(2) == expectedPoints[i], "i=\(i)")
    }

    for (i, frame) in frames.enumerated() {
      #expect(TextSegmentTests.formatFrames(frame) == expectedFrames[i], "i=\(i)")
    }

    let fileName = String(#function.dropLast(2))
    for (i, (point, frame)) in zip(points, frames).enumerated() {
      outputPDF("\(fileName)_\(i+1)", point, frame, documentManager)
    }
  }

  private func _createArrayNodeExample(_ subtype: MathArray) -> (Node, RhTextRange) {
    if subtype.requiresMatrixNode {
      let node =
        EquationNode(
          .equation,
          [
            MatrixNode(
              subtype,
              [
                MatrixNode.Row([
                  ContentNode([TextNode("a")]),
                  ContentNode([TextNode("beef")]),
                ]),
                MatrixNode.Row([
                  ContentNode([TextNode("c")]),
                  ContentNode([TextNode("d")]),
                ]),
              ])
          ])

      let range =
        RhTextRange.parse("[↓0,↓0,nuc,↓0,(0,1),↓0]:0..<[↓0,↓0,nuc,↓0,(0,1),↓0]:3")!
      return (node, range)
    }
    else {
      assert(subtype.requiresMultilineNode)
      let node = MultilineNode(
        subtype,
        [
          MultilineNode.Row([
            ContentNode([TextNode("a")]),
            ContentNode([TextNode("beef")]),
          ]),
          MultilineNode.Row([
            ContentNode([TextNode("c")]),
            ContentNode([TextNode("d")]),
          ]),
        ])
      let range =
        RhTextRange.parse("[↓0,↓0,(0,1),↓0]:0..<[↓0,↓0,(0,1),↓0]:3")!
      return (node, range)
    }
  }

  @Test("matrix and multiline", arguments: [MathArray.bmatrix, .align])
  func testArrayNode(_ subtype: MathArray) {
    let (node, range) = _createArrayNodeExample(subtype)
    let rootNode = RootNode([ParagraphNode([node])])
    let documentManager = createDocumentManager(rootNode)

    var frames: Array<CGRect> = []
    documentManager.enumerateTextSegments(in: range, type: .standard) {
      (_, segmentFrame, _) in
      frames.append(segmentFrame)
      return true  // continue
    }
    #expect(frames.count == 1)
  }

  @MainActor
  private func outputPDF(
    _ fileName: String, _ point: CGRect, _ frames: Array<CGRect>,
    _ documentManager: DocumentManager
  ) {
    var point = point
    if point.width == 0 {
      point.size.width = 1
    }

    self.outputPDF(fileName) { bounds in
      guard let cgContext = NSGraphicsContext.current?.cgContext else { return }

      cgContext.saveGState()
      // draw frames
      cgContext.setFillColor(NSColor.orange.withAlphaComponent(0.3).cgColor)
      for frame in frames {
        cgContext.fill(frame)
      }
      cgContext.restoreGState()

      TestUtils.draw(bounds, documentManager.textLayoutManager, cgContext)

      cgContext.saveGState()
      // draw point
      cgContext.setFillColor(NSColor.red.cgColor)
      cgContext.fill(point)
      cgContext.restoreGState()
    }
  }

  private static func getFrames(
    _ range: RhTextRange, _ documentManager: DocumentManager
  ) -> Array<CGRect> {
    var frames: Array<CGRect> = []
    documentManager.enumerateTextSegments(in: range, type: .standard) {
      (_, segmentFrame, _) in
      frames.append(segmentFrame)
      return true
    }
    return frames
  }

  private static func getIndicatorAndFrames(
    _ textRange: RhTextRange, _ documentManager: DocumentManager
  ) -> (CGRect, Array<CGRect>) {
    let location = RhTextRange(textRange.location)
    let indicator = Self.getFrames(location, documentManager).first!
    let frames = Self.getFrames(textRange, documentManager)
    return (indicator, frames)
  }

  private static func formatFrames(_ frames: Array<CGRect>) -> String {
    "[" + frames.map { $0.formatted(2) }.joined(separator: ", ") + "]"
  }
}
