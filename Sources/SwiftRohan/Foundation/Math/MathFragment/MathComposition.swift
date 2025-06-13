// Copyright 2024-2025 Lie Yan

import CoreGraphics

/// Composite of math fragments
struct MathComposition {
  typealias Item = (fragment: MathFragment, position: CGPoint)
  private let items: Array<Item>

  let width: Double
  var height: Double { ascent + descent }
  let ascent: Double
  let descent: Double

  func draw(at point: CGPoint, in context: CGContext) {
    context.saveGState()
    context.translateBy(x: point.x, y: point.y)
    for (fragment, position) in items {
      fragment.draw(at: position, in: context)
    }
    context.restoreGState()
  }

  init(width: Double, ascent: Double, descent: Double, items: Array<Item>) {
    self.width = width
    self.ascent = ascent
    self.descent = descent
    self.items = items
  }

  init() {
    self.width = 0
    self.ascent = 0
    self.descent = 0
    self.items = []
  }

  /// Create natural horizontal composition
  static func createHorizontal(_ fragments: Array<MathFragment>) -> MathComposition {
    var position = CGPoint.zero
    var items: Array<Item> = []
    items.reserveCapacity(fragments.count)
    for fragment in fragments {
      items.append((fragment, position))
      position.x += fragment.width
    }
    let width = position.x

    return MathComposition(
      width: width,
      ascent: fragments.lazy.map(\.ascent).max() ?? 0,
      descent: fragments.lazy.map(\.descent).max() ?? 0,
      items: items)
  }
}
