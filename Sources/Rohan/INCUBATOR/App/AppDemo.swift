// Copyright 2024-2025 Lie Yan

import Foundation

enum AppDemo {
  func insertAndUndo(_ text: TextNode) {
    let documentManager: DocumentManager = someValue()
    let location: TextLocation = someValue()
    // insert
    try! documentManager.replaceContents(in: RhTextRange(location), with: [text])
  }

  func deleteAndUndo() {
    let documentManager: DocumentManager = someValue()
    let textRange: RhTextRange = someValue()

    // undo
    let undo: () -> Void = {
      // save deleted nodes
      var deletedContent: [Node] = []
      _ = documentManager.enumerateSubnodes(in: textRange) { subnode, subnodeRange in
        guard let subnode else { return true }
        deletedContent.append(subnode)
        return true  // continue
      }
      // construct insert range
      let insertRange = RhTextRange(textRange.location)

      return {
        try! documentManager.replaceContents(in: insertRange, with: deletedContent)
      }
    }()

    // delete
    try! documentManager.replaceContents(in: textRange, with: nil)

    // perform undo
    undo()
  }

  func reconcileSelection() throws {
    let documentManager: DocumentManager = someValue()
    let viewFrame: CGRect = someValue()

    // get text selection
    let textSelections = documentManager.textSelections
    guard textSelections.count == 1 else { fatalError() }
    let textSelection = textSelections[0]

    // produce highlight frames
    var highlightFrames: [CGRect] = []
    for textRange in textSelection.textRanges {
      try documentManager.enumerateTextSegments(
        in: textRange, type: .standard, options: .rangeNotRequired
      ) {
        (textSegment, textSegmentFrame, _) in

        let textSegmentFrame = textSegmentFrame.intersection(viewFrame)
        guard textSegmentFrame.isEmpty else { return true }
        highlightFrames.append(textSegmentFrame)
        return true  // continue
      }
    }
  }

  func reconcileInsertionPoint() throws {
    let documentManager: DocumentManager = someValue()
    let location: TextLocation = someValue()

    // get insertion point
    let textRange = RhTextRange(location)
    var insertionPointFrame: CGRect = .zero
    try documentManager.enumerateTextSegments(
      in: textRange, type: .standard, options: .rangeNotRequired
    ) {
      (textSegment, textSegmentFrame, _) in
      guard textSegment != nil else { return true }
      insertionPointFrame = textSegmentFrame
      return false
    }
    useValue(insertionPointFrame)
  }
}
