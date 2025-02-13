// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

final class TextSegmentTests: TextKitTestsBase {
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
            ]
          ),
        ]),
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
      ParagraphNode([TextNode("The quick brown fox jumps over the lazy dog.")]),
    ])
    let documentManager = createDocumentManager(rootNode)
    self.outputPDF("document", documentManager)

    func outputPDF(_ fileName: String, _ points: [CGRect], _ frames: [CGRect]) {
      self.outputPDF(fileName) { bounds in
        guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
        TestUtils.draw(bounds, documentManager.textLayoutManager, cgContext)

        cgContext.saveGState()

        // draw points
        cgContext.setFillColor(NSColor.red.cgColor)
        for point in points {
          cgContext.fill(point)
        }

        // draw frames
        cgContext.setFillColor(NSColor.orange.withAlphaComponent(0.3).cgColor)
        for frame in frames {
          cgContext.fill(frame)
        }
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

    let (point1, frame1): ([CGRect], [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(0),  // text
      ]
      let location = TextLocation(path, 0)
      let end = TextLocation(path, 2)
      return (getFrames(for: location), getFrames(for: location, end))
    }()

    let (point2, frame2): ([CGRect], [CGRect]) = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      let end = TextLocation(path, 3)
      return (getFrames(for: location), getFrames(for: location, end))
    }()

    let (point3, frame3): ([CGRect], [CGRect]) = {
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
      return (getFrames(for: location), getFrames(for: location, end))
    }()

    let (point4, frame4): ([CGRect], [CGRect]) = {
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
      return (getFrames(for: location), getFrames(for: location, end))
    }()

    let (point5, frame5): ([CGRect], [CGRect]) = {
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
      return (getFrames(for: location), getFrames(for: location, end))
    }()

    let points = [point1, point2, point3, point4, point5]
    let expectedPoints: [String] = [
      "[(5.0, 17.0, 0.0, 30.054)]",
      "[(75.10444444444444, 28.34, 0.0, 13.32)]",
      "[(130.13777777777779, 25.932, 0.0, 6.342)]",
      "[(75.10444444444444, 28.34, 0.0, 13.32)]",
      "[(174.79999999999998, 47.054, 0.0, 17.0)]",
    ]
    let frames = [frame1, frame2, frame3, frame4, frame5]
    let expectedFrames: [String] = [
      "[(5.0, 17.0, 18.12, 30.054)]",
      "[(75.10444444444444, 26.119999999999997, 28.58444444444444, 15.540000000000001)]",
      "[(130.13777777777779, 23.958, 23.183999999999997, 9.324000000000002)]",
      "[(75.10444444444444, 23.958, 88.61733333333333, 23.096)]",
      """
      [(174.79999999999998, 47.054, 49.65600000000006, 17.0),\
       (5.0, 64.054, 22.008, 17.0),\
       (5.0, 81.054, 169.79999999999998, 17.0)]
      """,
    ]

    for (i, point) in points.enumerated() {
      #expect(point.description == expectedPoints[i], "i=\(i)")
    }
    for (i, frame) in frames.enumerated() {
      #expect(frame.description == expectedFrames[i], "i=\(i)")
    }

    for (i, (point, frame)) in zip(points, frames).enumerated() {
      var point = point
      if point.count == 1, point[0].width == 0 {
        point[0].size.width = 1
      }
      outputPDF("document_\(i)", point, frame)
    }
  }
}
