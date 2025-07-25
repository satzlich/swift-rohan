import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

struct FragmentCompositeFragment: MathFragment {
  private let _composition: FragmentComposite

  init(_ fragments: Array<MathFragment>) {
    precondition(fragments.isEmpty == false)
    let last = fragments.last!

    self._composition = FragmentComposite.createHorizontal(fragments)
    self.italicsCorrection = last.italicsCorrection
    self.clazz = last.clazz
    self.limits = last.limits
  }

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }

  let italicsCorrection: Double
  var accentAttachment: Double { _composition.width / 2 }

  let clazz: MathClass
  let limits: Limits
  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }
}
