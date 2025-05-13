// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import SwiftRohan

final class TextSegmentTests: TextKitTestsBase {
  init() throws {
    try super.init(createFolder: true)
  }

  @Test
  func testBasic() throws {
    let rootNode = RootNode([
      // #0 paragraph: arbitrary text
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      // #1 heading: test math nodes
      HeadingNode(
        level: 1,
        [
          TextNode("Alpha "),
          EquationNode(
            isBlock: false,
            nuc: [
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
        level: 1,
        [
          TextNode("Alpha "),
          EquationNode(
            isBlock: false,
            nuc: [
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

    var ranges: [RhTextRange] = [
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

    let pointsAndFrames: [(CGRect, [CGRect])] =
      ranges.map { Self.getIndicatorAndFrames($0, documentManager) }

    let points = pointsAndFrames.map { $0.0 }
    let frames = pointsAndFrames.map { $0.1 }

    let expectedPoints: [String] = [
      "(5.00, 34.00, 0.00, 30.05)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(130.42, 37.84, 0.00, 14.00)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(174.80, 64.05, 0.00, 17.00)",
      "(194.65, 37.84, 0.00, 14.00)",
      "(81.57, 141.28, 0.00, 10.00)",
    ]
    let expectedFrames: [String] = [
      "[(5.00, 34.00, 18.12, 30.05)]",
      "[(70.66, 40.88, 33.31, 20.00)]",
      "[(130.42, 37.84, 23.18, 14.00)]",
      "[(70.66, 40.88, 93.34, 23.17)]",
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
      outputPDF("\(fileName)_\(i+1)", point, frame, documentManager)
    }
  }

  @Test
  func testApplyNode() {
    let rootNode = RootNode([
      // #0 paragraph: arbitrary text
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      // #1 paragraph: test apply node
      ParagraphNode([
        TextNode("Newton's second law of motion: "),
        EquationNode(
          isBlock: false,
          nuc: [
            ApplyNode(CompiledSamples.newtonsLaw, [])!,
            TextNode("."),
          ]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          CompiledSamples.philipFox,
          [
            [TextNode("Philip")],
            [TextNode("Fox")],
          ])!,
      ]),
      // #2 paragraph: test nested apply node
      ParagraphNode([
        TextNode("Sample of nested apply nodes: "),
        ApplyNode(
          CompiledSamples.doubleText,
          [
            [ApplyNode(CompiledSamples.doubleText, [[TextNode("fox")]])!]
          ])!,
      ]),
      // #3
      HeadingNode(
        level: 1,
        [
          EquationNode(
            isBlock: false,
            nuc: [
              TextNode("m+"),
              ApplyNode(
                CompiledSamples.complexFraction, [[TextNode("x")], [TextNode("y")]])!,
              TextNode("+n"),
            ])
        ]),
      // #4
      ParagraphNode([
        EquationNode(
          isBlock: true,
          nuc: [
            ApplyNode(
              CompiledSamples.bifun,
              [
                [ApplyNode(CompiledSamples.bifun, [[TextNode("n+1")]])!]
              ])!
          ])
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)

    let ranges: [RhTextRange] = [
      RhTextRange.parse("[↓1,↓3,⇒0,↓0]:1..<[↓1,↓3,⇒0,↓0]:3")!,
      // paragraph -> apply -> #0 -> apply -> #0 -> text -> <offset>
      RhTextRange.parse("[↓2,↓1,⇒0,↓0,⇒0,↓0]:1..<[↓2,↓1,⇒0,↓0,⇒0,↓0]:3")!,
      // heading -> equation -> nucleus -> apply -> #0 -> text -> <offset>
      RhTextRange.parse("[↓3,↓0,nuc,↓1,⇒0,↓0]:0..<[↓3,↓0,nuc,↓1,⇒0,↓0]:1")!,
      // paragraph -> equation -> nucleus -> apply -> #0 -> apply -> #0
      // -> text -> <offset>
      RhTextRange.parse("[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:1..<[↓4,↓0,nuc,↓0,⇒0,↓0,⇒0,↓0]:3")!,
    ]

    let pointsAndFrames: [(CGRect, [CGRect])] =
      ranges.map { Self.getIndicatorAndFrames($0, documentManager) }

    let points = pointsAndFrames.map { $0.0 }
    let frames = pointsAndFrames.map { $0.1 }
    let expectedPoints: [String] = [
      "(112.66, 52.23, 0.00, 17.00)",
      "(183.81, 86.23, 0.00, 17.00)",
      "(61.78, 130.05, 0.00, 10.00)",
      "(35.46, 159.24, 0.00, 12.00)",
    ]
    let expectedFrames: [String] = [
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

  @Test
  func testPlacerholder() {
    let rootNode = RootNode([
      HeadingNode(level: 1, [TextNode("H1")]),
      HeadingNode(level: 2, []),
      HeadingNode(level: 3, [TextNode("H3")]),
      HeadingNode(level: 4, [TextNode("H4"), EmphasisNode([])]),
      HeadingNode(level: 5, [TextNode("H5")]),
      ParagraphNode([
        TextNode("Empty equation: "),
        EquationNode(isBlock: false, nuc: []),
        TextNode("."),
      ]),
      ParagraphNode([
        TextNode("Empty equation: "),
        EquationNode(
          isBlock: false,
          nuc: [
            FractionNode(num: [], denom: []),
            TextNode("+"),
            FractionNode(num: [], denom: [], subtype: .binom),
          ]),
        TextNode("."),
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    let ranges: [RhTextRange] = [
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

    let pointsAndFrames: [(CGRect, [CGRect])] =
      ranges.map { Self.getIndicatorAndFrames($0, documentManager) }

    let points = pointsAndFrames.map { $0.0 }
    let frames = pointsAndFrames.map { $0.1 }
    let expectedPoints: [String] = [
      "(14.00, 29.00, 0.00, 27.00)",
      "(28.91, 79.00, 0.00, 20.00)",
      "(102.61, 122.33, 0.00, 12.55)",
      "(102.08, 136.49, 0.00, 8.79)",
      "(102.08, 146.37, 0.00, 8.79)",
      "(133.49, 136.49, 0.00, 8.79)",
      "(133.49, 146.37, 0.00, 8.79)",
    ]
    let expectedFrames: [String] = [
      "[(14.00, 29.00, 0.00, 27.00)]",
      "[(28.91, 79.00, 0.00, 20.00)]",
      "[(102.61, 122.33, 0.00, 12.55)]",
      "[(102.08, 136.49, 0.00, 8.79)]",
      "[(102.08, 146.37, 0.00, 8.79)]",
      "[(133.49, 136.49, 0.00, 8.79)]",
      "[(133.49, 146.37, 0.00, 8.79)]",
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

  private func outputPDF(
    _ fileName: String, _ point: CGRect, _ frames: [CGRect],
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
  ) -> [CGRect] {
    var frames: [CGRect] = []
    documentManager.enumerateTextSegments(in: range, type: .standard) {
      (_, segmentFrame, _) in
      frames.append(segmentFrame)
      return true
    }
    return frames
  }

  private static func getIndicatorAndFrames(
    _ textRange: RhTextRange, _ documentManager: DocumentManager
  ) -> (CGRect, [CGRect]) {
    let location = RhTextRange(textRange.location)
    let indicator = Self.getFrames(location, documentManager).first!
    let frames = Self.getFrames(textRange, documentManager)
    return (indicator, frames)
  }

  private static func formatFrames(_ frames: [CGRect]) -> String {
    "[" + frames.map { $0.formatted(2) }.joined(separator: ", ") + "]"
  }
}
