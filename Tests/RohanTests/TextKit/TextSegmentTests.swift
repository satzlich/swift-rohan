// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import Testing

@testable import Rohan

final class TextSegmentTests: TextKitTestsBase {
  @Test
  func test_getLayoutFrame() throws {
    let rootNode = RootNode([
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
        ])
    ])
    let documentManager = createDocumentManager(rootNode)
    outputPDF("document", documentManager)

    let path: [RohanIndex] = [
      .index(0),  // heading
      .index(1),  // equation
      .mathIndex(.nucleus),  // nucleus
      .index(0), // text
      //      .index(0),  // fraction
      //      .mathIndex(.numerator),  // numerator
      //      .index(0),  // text
    ]
    let location = TextLocation(path, 1)

    var frame: CGRect? = nil
    documentManager.enumerateTextSegments(in: RhTextRange(location), type: .standard) {
      (_, segmentFrame, _) in
      frame = segmentFrame
      return false
    }
    guard var frame = frame else { return }
    print("frame: \(frame)")
    frame.size.width = 1

    outputPDF("document_1") { bounds in
      guard let cgContext = NSGraphicsContext.current?.cgContext else { return }
      TestUtils.draw(bounds, documentManager.textLayoutManager, cgContext)

      cgContext.saveGState()
      cgContext.setFillColor(NSColor.red.cgColor)
      cgContext.fill(frame)
      cgContext.restoreGState()
    }
  }
}
