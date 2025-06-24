// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation

final class TextLineLayoutContext: CTLineLayoutContext {
  override init(_ styleSheet: StyleSheet, _ fragment: CTLineLayoutFragment) {
    super.init(styleSheet, fragment)
  }

  init(_ styleSheet: StyleSheet, _ boundsOption: BoundsOption) {
    super.init(styleSheet, .textMode, boundsOption)
  }

  override func insertText(_ text: some Collection<Character>, _ source: Node) {
    precondition(isEditing)

    guard !text.isEmpty else { return }

    // obtain style properties
    let properties: TextProperty = source.resolveAggregate(styleSheet)
    let attributes = properties.getAttributes(isFlipped: true)  // flip for CTLine
    // create attributed string
    let attrString = NSAttributedString(string: String(text), attributes: attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    renderedString.replaceCharacters(in: location, with: attrString)
    // update layout cursor
    _layoutCursor += attrString.length
  }
}
