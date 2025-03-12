// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

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
            [
              TextNode("a+b+"),
              FractionNode(numerator: [TextNode("m+n")], denominator: [TextNode("n")]),
              TextNode("+"),
              FractionNode(numerator: [], denominator: [TextNode("n")]),
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
            [
              FractionNode(
                numerator: [
                  FractionNode(
                    numerator: [TextNode("a+b+c")],
                    denominator: [TextNode("m+n")])
                ],
                denominator: [TextNode("x+y+z")]
              )
            ]
          ),
        ]
      ),
    ])
    let documentManager = createDocumentManager(rootNode)

    // Convenience function
    func getFrames(for location: TextLocation, _ end: TextLocation? = nil) -> [CGRect] {
      Self.getFrames(for: location, end, documentManager: documentManager)
    }

    let (point1, frame1): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let end = TextLocation(path, 2)
      return (getFrames(for: location).getOnlyElement()!, getFrames(for: location, end))
    }()

    let (point2, frame2): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)
      return (getFrames(for: location).getOnlyElement()!, getFrames(for: location, end))
    }()

    let (point3, frame3): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // fraction
        .mathIndex(.numerator),  // numerator
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let end = TextLocation(path, 2)
      return (getFrames(for: location).getOnlyElement()!, getFrames(for: location, end))
    }()

    let (point4, frame4): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // text
      ]
      let endPath: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(endPath, 2)
      return (getFrames(for: location).getOnlyElement()!, getFrames(for: location, end))
    }()

    let (point5, frame5): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(0),  // text
      ]
      let endPath: [RohanIndex] = [
        .index(3),  // paragraph
        .index(0),  // text
      ]
      let location = TextLocation(path, "The quick brown fox jumps over".count)
      let end = TextLocation(endPath, "The quick brown fox jumps over".count)
      return (getFrames(for: location).getOnlyElement()!, getFrames(for: location, end))
    }()

    let (point6, frame6): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(3),  // fraction
        .mathIndex(.numerator),  // numerator
      ]
      let location = TextLocation(path, 0)
      let end = TextLocation(path, 0)
      return (getFrames(for: location).getOnlyElement()!, getFrames(for: location, end))
    }()

    let (point7, frame7): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(4),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // fraction
        .mathIndex(.numerator),  // numerator
        .index(0),  // fraction
        .mathIndex(.denominator),  // denominator
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)
      return (getFrames(for: location).getOnlyElement()!, getFrames(for: location, end))
    }()

    let points = [point1, point2, point3, point4, point5, point6, point7]
    let expectedPoints: [String] = [
      "(5.00, 34.00, 0.00, 30.05)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(130.14, 37.84, 0.00, 14.00)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(174.80, 64.05, 0.00, 17.00)",
      "(194.37, 37.84, 0.00, 14.00)",
      "(81.16, 141.28, 0.00, 10.00)",
    ]
    let frames = [frame1, frame2, frame3, frame4, frame5, frame6, frame7]
    let expectedFrames: [String] = [
      "[(5.00, 34.00, 18.12, 30.05)]",
      "[(70.66, 40.88, 33.03, 20.00)]",
      "[(130.14, 37.84, 23.18, 14.00)]",
      "[(70.66, 40.88, 93.06, 23.17)]",
      """
      [(174.80, 64.05, 49.66, 17.00),\
       (5.00, 81.05, 22.01, 17.00),\
       (5.00, 98.05, 169.80, 17.00)]
      """,
      "[(194.37, 37.84, 0.00, 14.00)]",
      "[(81.16, 141.28, 13.78, 10.00)]",
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
          [
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
            [
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
          [
            ApplyNode(
              CompiledSamples.bifun,
              [
                [ApplyNode(CompiledSamples.bifun, [[TextNode("n+1")]])!]
              ])!
          ])
      ]),
    ])

    let documentManager = createDocumentManager(rootNode)

    let (point1, frame1): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // paragraph
        .index(3),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)

      let point = Self.getFrames(for: location, documentManager: documentManager)[0]
      let rects = Self.getFrames(for: location, end, documentManager: documentManager)
      return (point, rects)
    }()

    let (point2, frame2): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(2),  // paragraph
        .index(1),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)

      let point = Self.getFrames(for: location, documentManager: documentManager)[0]
      let rects = Self.getFrames(for: location, end, documentManager: documentManager)
      return (point, rects)
    }()

    let (point3, frame3): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(3),  // heading
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let end = TextLocation(path, 1)

      let point = Self.getFrames(for: location, documentManager: documentManager)[0]
      let rects = Self.getFrames(for: location, end, documentManager: documentManager)
      return (point, rects)
    }()

    let (point4, frame4): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(4),  // paragraph
        .index(0),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)

      let point = Self.getFrames(for: location, documentManager: documentManager)[0]
      let rects = Self.getFrames(for: location, end, documentManager: documentManager)
      return (point, rects)
    }()

    let points = [point1, point2, point3, point4]
    let expectedPoints: [String] = [
      "(112.66, 52.23, 0.00, 17.00)",
      "(183.81, 86.23, 0.00, 17.00)",
      "(61.58, 130.05, 0.00, 10.00)",
      "(33.30, 159.24, 0.00, 12.00)",
    ]
    let frames = [frame1, frame2, frame3, frame4]
    let expectedFrames: [String] = [
      "[(112.66, 52.23, 10.01, 17.00), (13.17, 69.23, 10.01, 17.00)]",
      """
      [(183.81, 86.23, 12.00, 17.00),\
       (226.83, 86.23, 11.70, 17.00),\
       (38.02, 103.23, 11.70, 17.00),\
       (81.00, 103.23, 12.00, 17.00)]
      """,
      "[(61.58, 130.05, 5.72, 10.00), (49.01, 140.76, 8.01, 14.00)]",
      """
      [(33.30, 159.24, 20.67, 12.00),\
       (66.50, 159.24, 20.67, 12.00),\
       (114.92, 159.24, 20.67, 12.00),\
       (148.13, 159.24, 20.67, 12.00)]
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

  private func outputPDF(
    _ fileName: String, _ point: CGRect, _ frames: [CGRect], _ documentManager: DocumentManager
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
    for location: TextLocation, _ end: TextLocation? = nil, documentManager: DocumentManager
  ) -> [CGRect] {
    guard let range = RhTextRange(location, end ?? location) else { return [] }

    var frames: [CGRect] = []
    documentManager.enumerateTextSegments(in: range, type: .standard) {
      (_, segmentFrame, _) in
      frames.append(segmentFrame)
      return true
    }
    return frames
  }

  private static func formatFrames(_ frames: [CGRect]) -> String {
    "[" + frames.map { $0.formatted(2) }.joined(separator: ", ") + "]"
  }
}
