import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

private let DELIMITER_SHORTFALL = Em(0.1)

final class MathLeftRightLayoutFragment: MathLayoutFragment {

  private let delimiters: DelimiterPair
  let nucleus: MathListLayoutFragment

  private var _composition: MathComposition

  init(_ delimiters: DelimiterPair, _ nucleus: MathListLayoutFragment) {
    self.delimiters = delimiters
    self.nucleus = nucleus
    self._composition = MathComposition()
    self.glyphOrigin = .zero
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Metrics

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }

  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { _composition.width / 2 }

  var clazz: MathClass {
    // MathClass has no Inner kind, so use Special
    .Special
  }
  var limits: Limits { .never }

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
    let font = mathContext.getFont()
    let constants = mathContext.constants

    let axisHeight = font.convertToPoints(constants.axisHeight)
    let max_extent = max(nucleus.ascent - axisHeight, nucleus.descent + axisHeight)

    let relative_to = 2 * max_extent
    let shortfall = font.convertToPoints(DELIMITER_SHORTFALL)

    let (left, right) = LayoutUtils.layoutDelimiters(
      delimiters, relative_to, shortfall: shortfall, mathContext)

    var items: Array<MathFragment> = []
    var x = 0.0
    if let left = left {
      x += left.width
      items.append(left)
    }
    do {
      let pos = CGPoint(x: x, y: 0)
      x += nucleus.width
      // set the nucleus position
      nucleus.setGlyphOrigin(pos)
      items.append(nucleus)
    }
    if let right = right {
      x += right.width
      items.append(right)
    }

    _composition = MathComposition.createHorizontal(items)
  }

  func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    let x1 = (0 + self.nucleus.minX) / 2
    if point.x < x1 {
      return nil
    }
    let x2 = (self.width + self.nucleus.maxX) / 2
    if point.x > x2 {
      return nil
    }
    return .nuc
  }

  func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    precondition(component == .nuc)

    switch direction {
    case .up:
      return RayshootResult(point.with(y: self.minY), false)
    case .down:
      return RayshootResult(point.with(y: self.maxY), false)
    default:
      assertionFailure("Unexpected Direction")
      return nil
    }
  }

  func debugPrint(_ name: String) -> Array<String> {
    let description = "\(name): MathLeftRightLayoutFragment"
    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [nucleus])
  }
}
