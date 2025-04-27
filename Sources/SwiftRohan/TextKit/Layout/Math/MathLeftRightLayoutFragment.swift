// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

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

  var clazz: MathClass { .Normal }

  var limits: Limits { .never }

  var isSpaced: Bool { false }

  var isTextLike: Bool { false }

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
    preconditionFailure()
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "leftRight"
    let description: String = "\(name) \(boxDescription)"

    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    return PrintUtils.compose([description], [nucleus])
  }
}
