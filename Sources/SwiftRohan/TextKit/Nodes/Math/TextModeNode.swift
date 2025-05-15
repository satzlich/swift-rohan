// Copyright 2024-2025 Lie Yan

import CoreText
import Foundation
import _RopeModule

final class TextModeNode: MathNode {
  override class var type: NodeType { .textMode }

  let nucleus: ContentNode

  init(_ nucleus: [Node]) {
    self.nucleus = ContentNode(nucleus)
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
    nucleus = try container.decode(ContentNode.self, forKey: .nuc)
    try super.init(from: decoder)
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

  private static let uniqueTag = "text"
  override class var storageTags: [String] {
    [uniqueTag]
  }

  override func store() -> JSONValue {
    let nucleus = nucleus.store()
    let json = JSONValue.array([.string(Self.uniqueTag), nucleus])
    return json
  }

  // MARK: - Content

  override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, nucleus)]
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

  override var isDirty: Bool { nucleus.isDirty }

  private typealias _TextModeLayoutFragment = TextModeLayoutFragment

  private var _textModeFragment: _TextModeLayoutFragment? = nil

  override var layoutFragment: (any MathLayoutFragment)? { _textModeFragment }

  override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    precondition(context is MathListLayoutContext)
    let context = context as! MathListLayoutContext

    if fromScratch {
      let nucleus = TextLineLayoutFragment.from(
        nucleus, context.styleSheet, options: .typographicBounds)
      let fragment = _TextModeLayoutFragment(nucleus)
      _textModeFragment = fragment

      context.insertFragment(fragment, self)
    }
    else {
      guard let fragment = _textModeFragment
      else {
        assertionFailure("Accent fragment is nil")
        return
      }

      var needsFixLayout = false

      if isDirty {
        let oldMetrics = fragment.boxMetrics
        fragment.nucleus =
          TextLineLayoutFragment.reconcile(fragment.nucleus, nucleus, context.styleSheet)
        fragment.fixLayout(context.mathContext)

        if fragment.isNearlyEqual(to: oldMetrics) == false {
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

  override func getFragment(_ index: MathIndex) -> LayoutFragment? {
    switch index {
    case .nuc:
      return _textModeFragment?.nucleus
    default:
      return nil
    }
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
}
