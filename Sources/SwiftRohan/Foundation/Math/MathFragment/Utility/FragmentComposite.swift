// Copyright 2024-2025 Lie Yan

import CoreGraphics

struct FragmentComposite {
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
}

extension FragmentComposite {
  static func createHorizontal(_ fragments: Array<MathFragment>) -> FragmentComposite {
    var x: Double = 0
    var ascent: Double = 0
    var descent: Double = 0

    var items: Array<Item> = []
    items.reserveCapacity(fragments.count)

    for fragment in fragments {
      let item = (fragment, CGPoint(x: x, y: 0))
      items.append(item)
      x += fragment.width
      ascent = max(ascent, fragment.ascent)
      descent = max(descent, fragment.descent)
    }
    let width = x
    let composite = FragmentComposite(
      width: width, ascent: ascent, descent: descent, items: items)

    return composite
  }
}
