// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

final class MathRadicalLayoutFragment: MathLayoutFragment {

  let radicand: MathListLayoutFragment
  var index: MathListLayoutFragment?

  private var _composition: MathComposition

  init(_ radicand: MathListLayoutFragment, _ index: MathListLayoutFragment?) {
    self.radicand = radicand
    self.index = index
    self._composition = MathComposition()
    self.glyphOrigin = .zero
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    self.glyphOrigin = origin
  }

  // MARK: - Layout

  var layoutLength: Int { 1 }

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

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

  func fixLayout(_ mathContext: MathContext) {
    preconditionFailure()
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "\(NodeType.radical)"
    let description = "\(name) \(boxDescription)"

    let radicand = self.radicand.debugPrint("\(MathIndex.radicand)")
    let index = self.index?.debugPrint("\(MathIndex.index)")
    let children = [radicand, index].compactMap { $0 }

    return PrintUtils.compose([description], children)
  }
}
