// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Foundation
import TTFParser
import UnicodeMathClass

final class MathAttachLayoutFragment: MathLayoutFragment {

  let nucleus: MathListLayoutFragment
  var lsub: MathListLayoutFragment?
  var lsup: MathListLayoutFragment?
  var sub: MathListLayoutFragment?
  var sup: MathListLayoutFragment?

  private var _composition: MathComposition

  init(
    nuc: MathListLayoutFragment,
    lsub: MathListLayoutFragment? = nil, lsup: MathListLayoutFragment? = nil,
    sub: MathListLayoutFragment? = nil, sup: MathListLayoutFragment? = nil
  ) {
    self.nucleus = nuc
    self.lsub = lsub
    self.lsup = lsup
    self.sub = sub
    self.sup = sup
    self._composition = MathComposition()
    self._glyphOrigin = .zero
  }

  // MARK: - Frame

  private var _glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    _glyphOrigin = origin
  }

  var glyphFrame: CGRect {
    let size = CGSize(width: width, height: height)
    return CGRect(origin: _glyphOrigin, size: size)
  }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Length

  var layoutLength: Int { 1 }

  // MARK: - Metrics

  var width: Double { @inline(__always) get { _composition.width } }
  var height: Double { @inline(__always) get { _composition.height } }
  var ascent: Double { @inline(__always) get { _composition.ascent } }
  var descent: Double { @inline(__always) get { _composition.descent } }
  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  // MARK: - Categories

  var clazz: MathClass { .Normal }
  var limits: Limits { .never }

  // MARK: - Flags

  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
    let font = mathContext.getFont()
    let constants = mathContext.constants

    func metric(from mathValue: MathValueRecord) -> Double {
      font.convertToPoints(mathValue.value)
    }

    func metric(_ text: MathValueRecord, _ display: MathValueRecord) -> Double {
      switch mathContext.mathStyle {
      case .display:
        return metric(from: display)
      default:
        return metric(from: text)
      }
    }
  }

  // MARK: - Debug Description

  func debugPrint(_ name: String?) -> Array<String> {
    let name = name ?? "\(NodeType.attach)"
    let description: String = "\(name) \(boxDescription)"

    let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
    let lsub = self.lsub?.debugPrint("\(MathIndex.lsub)")
    let lsup = self.lsup?.debugPrint("\(MathIndex.lsup)")
    let sub = self.sub?.debugPrint("\(MathIndex.sub)")
    let sup = self.sup?.debugPrint("\(MathIndex.sup)")

    let children = [nucleus, lsub, lsup, sub, sup].compactMap { $0 }

    return PrintUtils.compose([description], children)
  }
}
