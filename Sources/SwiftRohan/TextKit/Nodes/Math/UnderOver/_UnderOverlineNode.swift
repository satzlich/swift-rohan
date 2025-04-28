// Copyright 2024-2025 Lie Yan

import Foundation
import _RopeModule

class _UnderOverlineNode: MathNode {
  enum Subtype {
    case overline
    case underline
  }

  let subtype: Subtype
  let _nucleus: ContentNode

  var nucleus: ContentNode { _nucleus }

  init(_ subtype: Subtype, _ nucleus: ContentNode) {
    self.subtype = subtype
    self._nucleus = nucleus
    super.init()
    _setUp()
  }

  init(_ subtype: Subtype, _ nucleus: [Node]) {
    let nucleus =
      (subtype == .overline) ? CrampedNode(nucleus) : ContentNode(nucleus)
    self.subtype = subtype
    self._nucleus = nucleus
    super.init()
    _setUp()
  }

  init(deepCopyOf node: _UnderOverlineNode) {
    self.subtype = node.subtype
    self._nucleus = node._nucleus.deepCopy()
    super.init()
    _setUp()
  }

  private final func _setUp() {
    _nucleus.setParent(self)
  }

  required init(from decoder: any Decoder) throws {
    preconditionFailure("should not be called")
  }

  // MARK: - Content

  override func stringify() -> BigString {
    "underoverline"
  }

  // MARK: - Layout

  final override var isBlock: Bool { false }

  final override var isDirty: Bool { _nucleus.isDirty }

  final override var layoutFragment: (any MathLayoutFragment)? {
    preconditionFailure()
  }

  final override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
    preconditionFailure()
  }

  final override func getFragment(_ index: MathIndex) -> MathListLayoutFragment? {
    preconditionFailure()
  }

  final override func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    preconditionFailure()
  }

  final override func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    preconditionFailure()
  }

  // MARK: - Component

  final override func enumerateComponents() -> [MathNode.Component] {
    [(MathIndex.nuc, _nucleus)]
  }
}
