// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

final class TextSegmentTests: TextKitTestsBase {
  @Test
  func test_getLayoutFrame() throws {
    let rootNode = RootNode([
      ParagraphNode([TextNode("abc")]),
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
    ])
    let documentManager = createDocumentManager(rootNode)
    self.outputPDF("document", documentManager)

    func outputPDF(_ fileName: String, _ frame: CGRect) {
      self.outputPDF(fileName) { bounds in
        guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
        TestUtils.draw(bounds, documentManager.textLayoutManager, cgContext)

        cgContext.saveGState()
        cgContext.setFillColor(NSColor.red.cgColor)
        cgContext.fill(frame)
        cgContext.restoreGState()
      }
    }

    func getFrame(for location: TextLocation) -> CGRect? {
      var frame: CGRect? = nil
      documentManager.enumerateTextSegments(in: RhTextRange(location), type: .standard) {
        (_, segmentFrame, _) in
        frame = segmentFrame
        return false
      }
      frame?.size.width = 1
      return frame
    }

    let frame1: CGRect? = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(0),  // text
      ]
      let location = TextLocation(path, 1)
      return getFrame(for: location)
    }()

    let frame2: CGRect? = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(0),  // text
      ]
      let location = TextLocation(path, 2)
      return getFrame(for: location)
    }()

    let frame3: CGRect? = {
      let path: [RohanIndex] = [
        .index(1),  // heading
        .index(1),  // equation
        .mathIndex(.nucleus),  // nucleus
        .index(1),  // fraction
        .mathIndex(.numerator),  // numerator
        .index(0),  // text
      ]
      let location = TextLocation(path, 3)
      return getFrame(for: location)
    }()

    let frames = [frame1, frame2, frame3].compacted()
    for (i, frame) in frames.enumerated() {
      outputPDF("document_\(i)", frame)
    }
  }
}
