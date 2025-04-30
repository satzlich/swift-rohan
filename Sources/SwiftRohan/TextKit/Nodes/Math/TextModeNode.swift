// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import _RopeModule

final class TextModeNode: MathNode {
  override class var type: NodeType { .textMode }

  let nucleus: TextModeContentNode

  init(_ nucleus: TextModeContentNode) {
    self.nucleus = nucleus
    super.init()
    _setUp()
  }

  init(_ nucleus: [Node]) {
    self.nucleus = TextModeContentNode(nucleus)
    super.init()
    _setUp()
  }

  init(deepCopyOf node: TextModeNode) {
    self.nucleus = node.nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private func _setUp() {
    nucleus.setParent(self)
  }

  // MARK: - Codable

  private enum CodingKeys: CodingKey { case nuc }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.nucleus = try container.decode(TextModeContentNode.self, forKey: .nuc)
    super.init()
    _setUp()
  }

  override func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(nucleus, forKey: .nuc)
    try super.encode(to: encoder)
  }

  // MARK: - Clone and Visitor

  override func deepCopy() -> TextModeNode { TextModeNode(deepCopyOf: self) }

  override func accept<V, R, C>(_ visitor: V, _ context: C) -> R
  where V: NodeVisitor<R, C> {
    visitor.visit(textMode: self, context)
  }

  // MARK: - Styles

  override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
    if _cachedProperties == nil {
      var properties = super.getProperties(styleSheet)

      let mathContext = MathUtils.resolveMathContext(for: self, styleSheet)
      let fontSize = FontSize(rawValue: mathContext.getFont().size)

      properties[TextProperty.size] = .fontSize(fontSize)

      _cachedProperties = properties
    }
    return _cachedProperties!
  }

  // MARK: - Layout

  private var _textModeFragment: TextModeLayoutFragment? = nil

  override var layoutFragment: (any MathLayoutFragment)? { _textModeFragment }

  override var isBlock: Bool { false }
  override var isDirty: Bool { nucleus.isDirty }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      var textStorage = NSMutableAttributedString()
      var ctLine = CTLineCreateWithAttributedString(textStorage)
      let subContext = TextLineLayoutContext(context.styleSheet, textStorage, ctLine)

      // layout nucleus
      nucleus.performLayout(subContext, fromScratch: true)

      // set fragment
      let fragment = TextModeLayoutFragment(subContext.textStorage, subContext.ctLine)
      _textModeFragment = fragment

      context.insertFragment(fragment, self)
    }
    else {
      guard var fragment = _textModeFragment
      else {
        assertionFailure("Accent fragment is nil")
        return
      }

      var needsFixLayout = false

      if nucleus.isDirty {
        let bounds = fragment.bounds

        // layout nucleus
        let subContext =
          TextLineLayoutContext(context.styleSheet, fragment.attrString, fragment.ctLine)
        nucleus.performLayout(subContext, fromScratch: false)

        // set fragment
        fragment = TextModeLayoutFragment(subContext.textStorage, subContext.ctLine)
        _textModeFragment = fragment

        // check if the bounds has changed
        if fragment.bounds.isNearlyEqual(to: bounds) == false {
          needsFixLayout = true
        }
      }

      if needsFixLayout {
        context.invalidateBackwards(layoutLength())
      }
      else {
        context.skipBackwards(layoutLength())
      }
    }
  }

  override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    nil
  }

  override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    guard _textModeFragment != nil else { return nil }
    return .nuc
  }

  override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    guard let fragment = _textModeFragment,
      component == .nuc
    else { return nil }

    switch direction {
    case .up:
      return RayshootResult(point.with(y: fragment.minY), false)
    case .down:
      return RayshootResult(point.with(y: fragment.maxY), false)
    default:
      assertionFailure("Unexpected Direction")
      return nil
    }
  }

  // MARK: - Content

  override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, nucleus)]
  }

  override func stringify() -> BigString { "textmode" }

  typealias TextModeContentNode = ContentNode
}
