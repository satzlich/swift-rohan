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
      ParagraphNode([TextNode("deliberate line")]),
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
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
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

    let points = [point1, point2, point3, point4, point5, point6]
    let expectedPoints: [String] = [
      "(5.00, 17.00, 0.00, 30.05)",
      "(70.66, 23.98, 0.00, 20.00)",
      "(130.14, 20.93, 0.00, 14.00)",
      "(70.66, 23.98, 0.00, 20.00)",
      "(174.80, 47.05, 0.00, 17.00)",
      "(194.37, 20.93, 0.00, 14.00)",
    ]
    let frames = [frame1, frame2, frame3, frame4, frame5, frame6]
    let expectedFrames: [String] = [
      "[(5.00, 17.00, 18.12, 30.05)]",
      "[(70.66, 23.98, 33.03, 20.00)]",
      "[(130.14, 20.93, 23.18, 14.00)]",
      "[(70.66, 23.98, 93.06, 23.17)]",
      """
      [(174.80, 47.05, 49.66, 17.00),\
       (5.00, 64.05, 22.01, 17.00),\
       (5.00, 81.05, 169.80, 17.00)]
      """,
      "[(194.37, 20.93, 0.00, 14.00)]",
    ]

    for (i, point) in points.enumerated() {
      #expect(point.formated(2) == expectedPoints[i], "i=\(i)")
    }
    
    func format(_ frames: [CGRect]) -> String {
      "[\(frames.map { $0.formated(2) }.joined(separator: ", "))]"
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
