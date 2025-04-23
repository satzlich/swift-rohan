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
    let limits = nucleus.limits.isActive(in: mathContext.mathStyle)

    let fragments: [MathListLayoutFragment?] =
      limits
      // tl, t, tr, bl, b, br
      ? [lsup, sup, nil, lsub, sub, nil]
      : [lsup, nil, sup, lsub, nil, sub]

    layoutAttach(mathContext, nucleus, fragments)
  }

  private func layoutAttach(
    _ mathContext: MathContext,
    _ base: MathListLayoutFragment,
    _ fragments: [MathListLayoutFragment?]
  ) {
    let tl = fragments[0]
    let t = fragments[1]
    let tr = fragments[2]
    let bl = fragments[3]
    let b = fragments[4]
    let br = fragments[5]

    // Calculate the distance from the base's baseline to the superscripts' and
    // subscripts' baseline.
    let (txShift, bxShift) =
      tl == nil && tr == nil && bl == nil && br == nil
      ? (0.0, 0.0)
      : computeScriptShifts(mathContext, base, tl: tl, tr: tr, bl: bl, br: br)

    // Calculate the distance from the base's baseline to the top attachment's
    // and bottom attachment's baseline.
    let (tShift, bShift) = computeLimitShift(mathContext, base, t: t, b: b)

    // calculate the final frame height
    let ascent = max(
      base.ascent,
      txShift + (tr?.ascent ?? 0),
      txShift + (tl?.ascent ?? 0),
      tShift + (t?.ascent ?? 0))
    let descent = max(
      base.descent,
      bxShift + (br?.descent ?? 0),
      bxShift + (bl?.descent ?? 0),
      bShift + (b?.descent ?? 0))
    let height = ascent + descent

    // Calculate the vertical position of each element in the final frame.
    let baseY = ascent - base.ascent

    func txY(_ tx: MathLayoutFragment) -> Double { ascent - txShift - tx.ascent }
    func bxY(_ bx: MathLayoutFragment) -> Double { ascent + bxShift - bx.ascent }
    func tY(_ t: MathLayoutFragment) -> Double { ascent - tShift - t.ascent }
    func bY(_ b: MathLayoutFragment) -> Double { ascent + bShift - b.ascent }

    // Calculate the distance each limit extends to the left and right of the
    // base's width.

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

/// Calculate the distance from the base's baseline to each script's baseline.
/// Returns two lengths, the first being the distance to the superscripts'
/// baseline and the second being the distance to the subscripts' baseline.
private func computeScriptShifts(
  _ mathContext: MathContext,
  _ base: MathLayoutFragment,
  tl: MathLayoutFragment?,
  tr: MathLayoutFragment?,
  bl: MathLayoutFragment?,
  br: MathLayoutFragment?
) -> (shiftUp: Double, shiftDown: Double) {

  let font = mathContext.getFont()
  let constants = mathContext.constants

  func metric(from mathValue: MathValueRecord) -> Double {
    font.convertToPoints(mathValue.value)
  }

  let supShiftUp: Double =
    mathContext.cramped
    ? metric(from: constants.superscriptShiftUpCramped)
    : metric(from: constants.superscriptShiftUp)
  let supBottomMin = metric(from: constants.superscriptBottomMin)
  let supBottomMaxWithSub = metric(from: constants.superscriptBottomMaxWithSubscript)
  let supDropMax = metric(from: constants.superscriptBaselineDropMax)
  let gapMin = metric(from: constants.subSuperscriptGapMin)
  let subShiftDown = metric(from: constants.subscriptShiftDown)
  let subTopMax = metric(from: constants.subscriptTopMax)
  let subDropMin = metric(from: constants.subscriptBaselineDropMin)

  var shiftUp = 0.0
  var shiftDown = 0.0
  let isTextLike = base.isTextLike

  if tl != nil || tr != nil {
    shiftUp = max(
      shiftUp, supShiftUp,
      isTextLike ? 0 : base.ascent - supDropMax,
      supBottomMin + (tl?.descent ?? 0),
      supBottomMin + (tr?.descent ?? 0))
  }

  if bl != nil || br != nil {
    shiftDown = max(
      shiftDown, subShiftDown,
      isTextLike ? 0 : base.descent + subDropMin,
      (bl?.ascent ?? 0) - subTopMax,
      (br?.ascent ?? 0) - subTopMax)
  }

  for (sup, sub) in [(tl, bl), (tr, br)] {
    if let sup = sup, let sub = sub {
      let supBottom = shiftUp - sup.descent
      let subTop = sub.ascent - shiftDown
      let gap = supBottom - subTop
      if gap >= gapMin { continue }
      let increase = gapMin - gap
      let supOnly = (supBottomMaxWithSub - supBottom).clamped(0, increase)
      let rest = (increase - supOnly) / 2
      shiftUp += supOnly + rest
      shiftDown += rest
    }
  }

  return (shiftUp, shiftDown)
}

/// Calculate the distance from the base's baseline to each limit's baseline.
/// Returns two lengths, the first being the distance to the upper-limit's
/// baseline and the second being the distance to the lower-limit's baseline.
private func computeLimitShift(
  _ mathContext: MathContext,
  _ base: MathLayoutFragment,
  t: MathLayoutFragment?,
  b: MathLayoutFragment?
) -> (tShift: Double, bShift: Double) {
  let font = mathContext.getFont()
  let constants = mathContext.constants

  func metric(from mathValue: MathValueRecord) -> Double {
    font.convertToPoints(mathValue.value)
  }

  // `upper_gap_min` and `lower_gap_min` give gaps to the descender and
  // ascender of the limits respectively, whereas `upper_rise_min` and
  // `lower_drop_min` give gaps to each limit's baseline (see the
  // MathConstants table in the OpenType MATH spec).

  let tShift =
    t.map { t in
      let upperGapMin = metric(from: constants.upperLimitGapMin)
      let upperRiseMin = metric(from: constants.upperLimitBaselineRiseMin)
      return base.ascent + max(upperRiseMin, upperGapMin + t.descent)
    } ?? 0

  let bShift =
    b.map { b in
      let lowerGapMin = metric(from: constants.lowerLimitGapMin)
      let lowerDropMin = metric(from: constants.lowerLimitBaselineDropMin)
      return base.descent + max(lowerDropMin, lowerGapMin + b.ascent)
    } ?? 0

  return (tShift, bShift)
}

/// Calculate the distance each limit extends beyond the base's width, in each
/// direction. Can be a negative value if the limit does not extend beyond the
/// base's width, indicating how far into the base's width the limit extends.
/// Returns 2 tuples of two lengths, each first containing the distance the
/// limit extends leftward beyond the base's width and second containing the
/// distance the limit extends rightward beyond the base's width. The first
/// tuple is for the upper-limit, and the second is for the lower-limit.
private func computeLimitWidths(
  _ base: MathLayoutFragment,
  _ t: MathLayoutFragment?,
  _ b: MathLayoutFragment?
) -> (tWidths: (Double, Double), bWidths: (Double, Double)) {
  // The upper- (lower-) limit is shifted to the right (left) of the base's
  // center by half the base's italic correction.
  let delta = base.italicsCorrection / 2
  let tWidths =
    t.map { t in
      let half = (t.width - base.width) / 2
      return (half - delta, half + delta)
    } ?? (0, 0)
  let bWidths =
    b.map { b in
      let half = (b.width - base.width) / 2
      return (half + delta, half - delta)
    } ?? (0, 0)

  return (tWidths, bWidths)
}
