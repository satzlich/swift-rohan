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
  func test_enumerateTextSegments() throws {
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
              FractionNode([TextNode("m+n")], [TextNode("n")]),
              TextNode("+"),
              FractionNode([], [TextNode("n")]),
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
                [
                  FractionNode(
                    [TextNode("a+b+c")],
                    [TextNode("m+n")])
                ],
                [TextNode("x+y+z")]
              )
            ]
          ),
        ]
      ),
      // #5 paragraph: test apply node
      ParagraphNode([
        TextNode("Newton's second law of motion: "),
        EquationNode(
          isBlock: false,
          [
            ApplyNode(TemplateSample.newtonsLaw, [])!,
            TextNode("."),
          ]),
        TextNode(" Here is another sample: "),
        ApplyNode(
          TemplateSample.philipFox,
          [
            [TextNode("Philip")],
            [TextNode("Fox")],
          ])!,
      ]),
    ])
    let documentManager = createDocumentManager(rootNode)

    func outputPDF(_ fileName: String, _ point: CGRect, _ frames: [CGRect]) {
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

    func getFrames(for location: TextLocation, _ end: TextLocation? = nil) -> [CGRect] {
      guard let range = RhTextRange(location, end ?? location) else { return [] }

      var frames: [CGRect] = []
      documentManager.enumerateTextSegments(in: range, type: .standard) {
        (_, segmentFrame, _) in
        frames.append(segmentFrame)
        return true
      }
      return frames
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

    let (point8, frame8): (CGRect, [CGRect]) = {
      let path: [RohanIndex] = [
        .index(5),  // paragraph
        .index(3),  // apply
        .argumentIndex(0),  // argument 0
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)
      return (getFrames(for: location)[0], getFrames(for: location, end))
    }()

    let points = [point1, point2, point3, point4, point5, point6, point7, point8]
    let expectedPoints: [String] = [
      "(5.00, 34.00, 0.00, 30.05)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(130.14, 37.84, 0.00, 14.00)",
      "(70.66, 40.88, 0.00, 20.00)",
      "(174.80, 64.05, 0.00, 17.00)",
      "(194.37, 37.84, 0.00, 14.00)",
      "(81.16, 141.28, 0.00, 10.00)",
      "(112.66, 184.41, 0.00, 17.00)",
    ]
    let frames = [frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8]
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
      """
      [(112.66, 184.41, 10.01, 17.00), (13.17, 201.41, 10.01, 17.00)]
      """,
    ]

    for (i, point) in points.enumerated() {
      #expect(point.formatted(2) == expectedPoints[i], "i=\(i)")
    }

    func format(_ frames: [CGRect]) -> String {
      "[\(frames.map { $0.formatted(2) }.joined(separator: ", "))]"
    }
    for (i, frame) in frames.enumerated() {
      #expect(format(frame) == expectedFrames[i], "i=\(i)")
    }

    for (i, (var point, frame)) in zip(points, frames).enumerated() {
      if point.width == 0 {
        point.size.width = 1
      }
      outputPDF("document_\(i+1)", point, frame)
    }
  }
}
