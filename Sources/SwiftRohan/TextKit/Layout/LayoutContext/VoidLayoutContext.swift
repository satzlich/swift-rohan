// Copyright 2024-2025 Lie Yan

import AppKit
import _RopeModule

final class VoidLayoutContext: LayoutContext {
  let styleSheet: StyleSheet
  let attributedString: NSMutableAttributedString

  private var textStorage: NSMutableAttributedString { attributedString }

  init(_ styleSheet: StyleSheet, _ attributedString: NSAttributedString) {
    self.styleSheet = styleSheet
    self.attributedString = NSMutableAttributedString(attributedString: attributedString)
    self.layoutCursor = attributedString.length
  }

  // MARK: - State

  private(set) var layoutCursor: Int

  internal func resetCursor() {
    self.layoutCursor = attributedString.length
  }

  private(set) var isEditing: Bool = false

  func beginEditing() {
    precondition(isEditing == false)
    isEditing = true
  }

  func endEditing() {
    precondition(isEditing == true)
    isEditing = false
  }

  // MARK: - Operations

  func addParagraphStyle(_ source: Node, _ range: Range<Int>) {
    precondition(isEditing)
    let properties: ParagraphProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    textStorage.addAttributes(attributes, range: NSRange(range))
  }

  func skipBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    layoutCursor -= n
  }

  func deleteBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    // find range
    let location = layoutCursor - n
    let range = NSRange(location: location, length: n)
    // update state
    textStorage.replaceCharacters(in: range, with: "")
    layoutCursor = location
  }

  func invalidateBackwards(_ n: Int) {
    precondition(isEditing && n >= 0 && layoutCursor >= n)
    // find character range
    let location = layoutCursor - n
    let range = NSRange(location: location, length: n)
    // update layout cursor no matter what
    layoutCursor = location
  }

  func insertText<S: Collection<Character>>(_ text: S, _ source: Node) {
    precondition(isEditing)
    guard !text.isEmpty else { return }
    // obtain style properties
    let properties: TextProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // create attributed string
    let attrString = NSAttributedString(string: String(text), attributes: attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  func insertNewline(_ source: Node) {
    precondition(isEditing)
    // obtain style properties
    let properties: TextProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // create attributed string
    let attrString = NSAttributedString(string: "\n", attributes: attributes)
    assert(attrString.length == 1)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  func insertFragment(_ fragment: any LayoutFragment, _ source: Node) {
    precondition(isEditing)

    // obtain style properties
    let properties: TextProperty = source.resolvePropertyAggregate(styleSheet)
    let attributes = properties.getAttributes()
    // form attributed string
    let attrString = Self.attributedString(for: fragment, attributes)
    // update state
    let location = NSRange(location: layoutCursor, length: 0)
    textStorage.replaceCharacters(in: location, with: attrString)
  }

  /// Wrap given fragment in text attachment which is further embedded in an
  /// attributed string
  private static func attributedString(
    for fragment: any LayoutFragment, _ attributes: [NSAttributedString.Key: Any]
  ) -> NSAttributedString {
    let attachment = LayoutFragmentAttachment(fragment)
    if #available(macOS 15.0, *) {
      return NSAttributedString(attachment: attachment, attributes: attributes)
    }
    else {
      // Fallback on earlier versions
      let mutableString = NSMutableAttributedString(attachment: attachment)
      let range = NSRange(location: 0, length: mutableString.length)
      mutableString.setAttributes(attributes, range: range)
      return mutableString
    }
  }

  // MARK: - Frame

  func getSegmentFrame(
    _ layoutOffset: Int, _ affinity: RhTextSelection.Affinity
  ) -> SegmentFrame? {
    precondition(isEditing == false)
    return nil
  }

  func getSegmentFrame(
    for layoutOffset: Int, _ affinity: RhTextSelection.Affinity, _ node: Node
  ) -> SegmentFrame? {
    return getSegmentFrame(layoutOffset, affinity)
  }

  func enumerateTextSegments(
    _ layoutRange: Range<Int>,
    type: DocumentManager.SegmentType,
    options: DocumentManager.SegmentOptions,
    using block: (Range<Int>?, CGRect, CGFloat) -> Bool
  ) -> Bool {
    precondition(isEditing == false)
    return false
  }

  func getLayoutRange(interactingAt point: CGPoint) -> PickingResult? {
    precondition(isEditing == false)
    return nil
  }

  func rayshoot(
    from layoutOffset: Int,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(isEditing == false)
    return nil
  }

  func lineFrame(
    from layoutOffset: Int,
    affinity: RhTextSelection.Affinity,
    direction: TextSelectionNavigation.Direction
  ) -> SegmentFrame? {
    return nil
  }
}

extension VoidLayoutContext {
  static func defaultValue() -> VoidLayoutContext {
    let styleSheet = StyleSheets.latinModern(10)
    let attributedString = NSMutableAttributedString(string: "")
    return VoidLayoutContext(styleSheet, attributedString)
  }
}
