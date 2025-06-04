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
    lsub: MathListLayoutFragment?, lsup: MathListLayoutFragment?,
    sub: MathListLayoutFragment?, sup: MathListLayoutFragment?
  ) {
    self.nucleus = nuc
    self.lsub = lsub
    self.lsup = lsup
    self.sub = sub
    self.sup = sup
    self._composition = MathComposition()
    self.glyphOrigin = .zero
  }

  // MARK: - Frame

  private(set) var glyphOrigin: CGPoint

  func setGlyphOrigin(_ origin: CGPoint) {
    glyphOrigin = origin
  }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext) {
    _composition.draw(at: point, in: context)
  }

  // MARK: - Length

  var layoutLength: Int { 1 }

  // MARK: - Metrics

  var width: Double { _composition.width }
  var height: Double { _composition.height }
  var ascent: Double { _composition.ascent }
  var descent: Double { _composition.descent }
  var italicsCorrection: Double { 0 }
  var accentAttachment: Double { width / 2 }

  // MARK: - Misc

  var clazz: MathClass { nucleus.clazz }
  var limits: Limits { .never }
  var isSpaced: Bool { false }
  var isTextLike: Bool { false }

  /// Returns true if limits is active for layout of the attach components
  private(set) var isLimitsActive: Bool = false

  // MARK: - Layout

  func fixLayout(_ mathContext: MathContext) {
    isLimitsActive = nucleus.limits.isActive(in: mathContext.mathStyle)

    let fragments: [MathListLayoutFragment?] =
      isLimitsActive
      // tl, t, tr, bl, b, br
      ? [lsup, sup, nil, lsub, sub, nil]
      : [lsup, nil, sup, lsub, nil, sub]

    layoutAttach(mathContext, nucleus, fragments)
  }

  private func layoutAttach(
    _ context: MathContext,
    _ base: MathListLayoutFragment,
    _ fragments: [MathListLayoutFragment?]
  ) {
    let font = context.getFont()
    let constants = context.constants

    func metric(from mathValue: MathValueRecord) -> Double {
      font.convertToPoints(mathValue.value)
    }

    let tl = fragments[0]
    let t = fragments[1]
    let tr = fragments[2]
    let bl = fragments[3]
    let b = fragments[4]
    let br = fragments[5]

    // Calculate the distance from the base's baseline to the superscripts' and
    // subscripts' baseline.
    let (tx_shift, bx_shift) =
      tl == nil && tr == nil && bl == nil && br == nil
      ? (0.0, 0.0)
      : computeScriptShifts(context, base, tl: tl, tr: tr, bl: bl, br: br)

    // Calculate the distance from the base's baseline to the top attachment's
    // and bottom attachment's baseline.
    let (t_shift, b_shift) = MathUtils.computeLimitShift(context, base, t: t, b: b)

    // calculate the final frame height
    let ascent = max(
      base.ascent,
      tx_shift + (tr?.ascent ?? 0),
      tx_shift + (tl?.ascent ?? 0),
      t_shift + (t?.ascent ?? 0))
    let descent = max(
      base.descent,
      bx_shift + (br?.descent ?? 0),
      bx_shift + (bl?.descent ?? 0),
      b_shift + (b?.descent ?? 0))

    // Calculate the vertical position of each element in the final frame.
    let base_y = 0.0

    func tx_y(_ tx: MathLayoutFragment) -> Double { -tx_shift }
    func bx_y(_ bx: MathLayoutFragment) -> Double { bx_shift }
    func t_y(_ t: MathLayoutFragment) -> Double { -t_shift }
    func b_y(_ b: MathLayoutFragment) -> Double { b_shift }

    // Calculate the distance each limit extends to the left and right of the
    // base's width.
    let ((t_pre_width, t_post_width), (b_pre_width, b_post_width)) =
      computeLimitWidths(base, t: t, b: b)

    // `space_after_script` is extra spacing that is at the start before each
    // pre-script, and at the end after each post-script (see the MathConstants
    // table in the OpenType MATH spec).
    let space_after_script = metric(from: constants.spaceAfterScript)

    // Calculate the distance each pre-script extends to the left of the base's
    // width.
    let (tl_pre_width, bl_pre_width) =
      computePreScriptWidths(
        context, base, tl: tl, bl: bl,
        tlShift: tx_shift, blShift: bx_shift,
        spaceBeforePreScript: space_after_script)

    // Calculate the distance each post-script extends to the right of the
    // base's width. Also calculate each post-script's kerning (we need this for
    // its position later).
    let ((tr_post_width, tr_kern), (br_post_width, br_kern)) =
      computePostScriptWidths(
        context, base, tr: tr, br: br,
        trShift: tx_shift, brShift: bx_shift,
        spaceAfterPostScript: space_after_script)

    // Calculate the final frame width.
    let pre_width = max(t_pre_width, b_pre_width, tl_pre_width, bl_pre_width)
    let base_width = base.width
    let post_width = max(t_post_width, b_post_width, tr_post_width, br_post_width)
    let width = pre_width + base_width + post_width

    // Calculate the horizontal position of each element in the final frame.
    let base_x = pre_width
    let tl_x = pre_width - tl_pre_width + space_after_script
    let bl_x = pre_width - bl_pre_width + space_after_script
    let tr_x = pre_width + base_width + tr_kern
    let br_x = pre_width + base_width + br_kern
    let t_x = pre_width - t_pre_width
    let b_x = pre_width - b_pre_width

    // Create the final frame.
    var items: [MathComposition.Item] = []

    // base
    do {
      let p = CGPoint(x: base_x, y: base_y)
      base.setGlyphOrigin(p)
      items.append((base, p))
    }

    // pre-superscript
    tl.map { tl in
      let p = CGPoint(x: tl_x, y: tx_y(tl))
      tl.setGlyphOrigin(p)
      items.append((tl, p))
    }
    // pre-subscript
    bl.map { bl in
      let p = CGPoint(x: bl_x, y: bx_y(bl))
      bl.setGlyphOrigin(p)
      items.append((bl, p))
    }
    // post-superscript
    tr.map { tr in
      let p = CGPoint(x: tr_x, y: tx_y(tr))
      tr.setGlyphOrigin(p)
      items.append((tr, p))
    }
    // post-subscript
    br.map { br in
      let p = CGPoint(x: br_x, y: bx_y(br))
      br.setGlyphOrigin(p)
      items.append((br, p))
    }
    // upper limit
    t.map { t in
      let p = CGPoint(x: t_x, y: t_y(t))
      t.setGlyphOrigin(p)
      items.append((t, p))
    }
    // lower limit
    b.map { b in
      let p = CGPoint(x: b_x, y: b_y(b))
      b.setGlyphOrigin(p)
      items.append((b, p))
    }

    _composition = MathComposition(
      width: width, ascent: ascent, descent: descent, items: items)
  }

  func getMathIndex(interactingAt point: CGPoint) -> MathIndex? {
    if !self.isLimitsActive {
      let nucleus = self.nucleus

      // left scripts must be to the left of nucleus
      if point.x < nucleus.minX {
        if let lsup = self.lsup {
          // y above bottom of lsup
          if point.y <= lsup.maxY { return .lsup }
          // FALL THROUGH
        }
        if let lsub = self.lsub {
          // y below top of lsub
          if point.y >= lsub.minY { return .lsub }
        }
        return nil
      }

      if let sub = self.sub {
        // y below top of sub, x to the right of sub
        if point.y >= sub.minY && point.x >= sub.minX { return .sub }
        // FALL THROUGH
      }

      assert(point.x >= nucleus.minX)

      // x in the x-range of nucleus
      if point.x <= nucleus.maxX {
        return .nuc
      }

      if let sup = self.sup {
        // y above bottom of sup
        if point.y <= sup.maxY { return .sup }
      }
      return nil
    }
    else {
      if let sub = self.sub {
        // y below top of sub
        if point.y >= sub.minY { return .sub }
        // FALL THROUGH
      }
      if let sup = self.sup {
        // y above bottom of sup
        if point.y <= sup.maxY { return .sup }
        // FALL THROUGH
      }
      return .nuc
    }
  }

  func rayshoot(
    from point: CGPoint, _ component: MathIndex,
    in direction: TextSelectionNavigation.Direction
  ) -> RayshootResult? {
    let eps = Rohan.tolerance

    switch direction {
    case .up:
      switch component {
      case .nuc:
        let nucleus = self.nucleus

        if point.x < nucleus.midX {  // point in the left half of nucleus
          return self.lsup.map { lsup in RayshootResult(bottom(of: lsup), true) }
            ?? self.sup.map { sup in RayshootResult(bottom(of: sup), true) }
            ?? RayshootResult(point.with(y: self.minY), false)  // top of fragment
        }
        else {  // point in the right half of nucleus
          return self.sup.map { sup in RayshootResult(bottom(of: sup), true) }
            ?? self.lsup.map { lsup in RayshootResult(bottom(of: lsup), true) }
            ?? RayshootResult(point.with(y: self.minY), false)  // top of fragment
        }

      case .lsub:
        return RayshootResult(bottom(of: self.nucleus), true)

      case .sub:
        let nucleus = self.nucleus
        let x = point.x.clamped(nucleus.minX, nucleus.maxX, inset: eps)
        // bottom of nucleus above subscript
        // Since boxes of nucleus and subscript may overlap, we need to avoid
        // the overlap area.
        let y = min(nucleus.maxY, self.sub?.minY ?? nucleus.maxY)
        return RayshootResult(CGPoint(x: x, y: y), true)

      case .lsup, .sup:
        // top of fragment
        return RayshootResult(point.with(y: self.minY), false)

      default:
        assertionFailure("Unexpected component")
        return nil
      }

    case .down:
      switch component {
      case .nuc:
        let nucleus = self.nucleus

        if point.x < nucleus.midX {
          return self.lsub.map { lsub in RayshootResult(top(of: lsub), true) }
            ?? self.sub.map { sub in RayshootResult(top(of: sub), true) }
            ?? RayshootResult(point.with(y: self.maxY), false)  // bottom of fragment
        }
        else {
          return self.sub.map { sub in RayshootResult(top(of: sub), true) }
            ?? self.lsub.map { lsub in RayshootResult(top(of: lsub), true) }
            ?? RayshootResult(point.with(y: self.maxY), false)  // bottom of fragment
        }

      case .lsup, .sup:
        return RayshootResult(top(of: self.nucleus), true)

      case .lsub, .sub:
        return RayshootResult(point.with(y: self.maxY), false)  // bottom of fragment

      default:
        assertionFailure("Unexpected component")
        return nil
      }

    default:
      assertionFailure("Unsupported direction")
      return nil
    }

    // Helper
    func bottom(of fragment: MathLayoutFragment) -> CGPoint {
      let eps = Rohan.tolerance
      let x = point.x.clamped(fragment.minX, fragment.maxX, inset: eps)
      let y = fragment.maxY
      return CGPoint(x: x, y: y)
    }

    func top(of fragment: MathLayoutFragment) -> CGPoint {
      let eps = Rohan.tolerance
      let x = point.x.clamped(fragment.minX, fragment.maxX, inset: eps)
      let y = fragment.minY
      return CGPoint(x: x, y: y)
    }
  }

  func debugPrint(_ name: String?) -> Array<String> {
    let description = (name.map { "\($0): " } ?? "") + "attach \(boxDescription)"
    let children: [Array<String>]
    do {
      let lsub = self.lsub?.debugPrint("\(MathIndex.lsub)")
      let lsup = self.lsup?.debugPrint("\(MathIndex.lsup)")
      let nucleus = self.nucleus.debugPrint("\(MathIndex.nuc)")
      let sub = self.sub?.debugPrint("\(MathIndex.sub)")
      let sup = self.sup?.debugPrint("\(MathIndex.sup)")
      children = [lsub, lsup, nucleus, sub, sup].compactMap { $0 }
    }
    return PrintUtils.compose([description], children)
  }
}

/// Calculate the distance from the base's baseline to each script's baseline.
/// Returns two lengths, the first being the distance to the superscripts'
/// baseline and the second being the distance to the subscripts' baseline.
private func computeScriptShifts(
  _ context: MathContext,
  _ base: MathLayoutFragment,
  tl: MathLayoutFragment?,
  tr: MathLayoutFragment?,
  bl: MathLayoutFragment?,
  br: MathLayoutFragment?
) -> (shiftUp: Double, shiftDown: Double) {

  let font = context.getFont()
  let constants = context.constants

  func metric(from mathValue: MathValueRecord) -> Double {
    font.convertToPoints(mathValue.value)
  }

  let supShiftUp: Double =
    context.cramped
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
    let ascent = base.ascent
    shiftUp = max(
      shiftUp, supShiftUp,
      isTextLike ? 0 : ascent - supDropMax,
      supBottomMin + (tl?.descent ?? 0),
      supBottomMin + (tr?.descent ?? 0))
  }

  if bl != nil || br != nil {
    let descent = base.descent
    shiftDown = max(
      shiftDown, subShiftDown,
      isTextLike ? 0 : descent + subDropMin,
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

extension MathUtils {
  /// Calculate the distance from the base's baseline to each limit's baseline.
  /// Returns two lengths, the first being the distance to the upper-limit's
  /// baseline and the second being the distance to the lower-limit's baseline.
  internal static func computeLimitShift(
    _ context: MathContext,
    _ base: MathFragment,
    t: MathFragment?,
    b: MathFragment?
  ) -> (tShift: Double, bShift: Double) {
    let font = context.getFont()
    let constants = context.constants

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
  t: MathLayoutFragment?,
  b: MathLayoutFragment?
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

/// Calculate the distance each pre-script extends to the left of the base's
/// width. Requires the distance from the base's baseline to each pre-script's
/// baseline to obtain the correct kerning value.
/// Returns two lengths, the first being the distance the pre-superscript
/// extends left of the base's width and the second being the distance the
/// pre-subscript extends left of the base's width.
private func computePreScriptWidths(
  _ context: MathContext,
  _ base: MathLayoutFragment,
  tl: MathLayoutFragment?,
  bl: MathLayoutFragment?,
  tlShift: Double,
  blShift: Double,
  spaceBeforePreScript: Double
) -> (tlPreWidth: Double, blPreWidth: Double) {
  let tlPreWidth =
    tl.map { tl in
      let kern = mathKern(context, base, script: tl, shift: tlShift, .topLeft)
      return spaceBeforePreScript + tl.width + kern
    } ?? 0
  let blPreWidth =
    bl.map { bl in
      let kern = mathKern(context, base, script: bl, shift: blShift, .bottomLeft)
      return spaceBeforePreScript + bl.width + kern
    } ?? 0
  return (tlPreWidth, blPreWidth)
}

/// Calculate the distance each post-script extends to the right of the base's
/// width, as well as its kerning value. Requires the distance from the base's
/// baseline to each post-script's baseline to obtain the correct kerning value.
/// Returns 2 tuples of two lengths, each first containing the distance the
/// post-script extends left of the base's width and second containing the
/// post-script's kerning value. The first tuple is for the post-superscript,
/// and the second is for the post-subscript.
private func computePostScriptWidths(
  _ context: MathContext,
  _ base: MathLayoutFragment,
  tr: MathLayoutFragment?,
  br: MathLayoutFragment?,
  trShift: Double,
  brShift: Double,
  spaceAfterPostScript: Double
) -> (trValues: (Double, Double), brValues: (Double, Double)) {

  let trValues =
    tr.map { tr in
      let kern = mathKern(context, base, script: tr, shift: trShift, .topRight)
      return (spaceAfterPostScript + tr.width + kern, kern)
    } ?? (0, 0)

  // The base's bounding box already accounts for its italic correction, so we
  // need to shift the post-subscript left by the base's italic correction
  // (see the kerning algorithm as described in the OpenType MATH spec).
  let brValues =
    br.map { br in
      let kern =
        mathKern(context, base, script: br, shift: brShift, .bottomRight)
        - base.italicsCorrection
      return (spaceAfterPostScript + br.width + kern, kern)
    } ?? (0, 0)

  return (trValues, brValues)
}

/// Calculate the kerning value for a script with respect to the base. A
/// positive value means shifting the script further away from the base, whereas
/// a negative value means shifting the script closer to the base. Requires the
/// distance from the base's baseline to the script's baseline, as well as the
/// script's corner (tl, tr, bl, br).
private func mathKern(
  _ context: MathContext,
  _ base: MathLayoutFragment,
  script: MathLayoutFragment,
  shift: Double,
  _ corner: Corner
) -> Double {
  // This process is described under the MathKernInfo table in the OpenType
  // MATH spec.

  let (corr_height_top, corr_height_bot) =
    switch corner {
    // Calculate two correction heights for superscripts:
    // - The distance from the superscript's baseline to the top of the
    //   base's bounding box.
    // - The distance from the base's baseline to the bottom of the
    //   superscript's bounding box.
    case .topLeft, .topRight:
      (base.ascent - shift, shift - script.descent)

    // Calculate two correction heights for subscripts:
    // - The distance from the base's baseline to the top of the
    //   subscript's bounding box.
    // - The distance from the subscript's baseline to the bottom of the
    //   base's bounding box.
    case .bottomLeft, .bottomRight:
      (script.ascent - shift, shift - base.descent)
    }

  // Calculate the sum of kerning values for each correction height.
  func summed_kern(_ height: Double) -> Double {
    let baseKern = base.kernAtHeight(context, corner, height)
    let attachkern = script.kernAtHeight(context, corner.opposite(), height)
    return baseKern + attachkern
  }

  // Take the smaller kerning amount (and so the larger value). Note that
  // there is a bug in the spec (as of 2024-08-15): it says to take the
  // minimum of the two sums, but as the kerning value is usually negative it
  // really means the smaller kern. The current wording of the spec could
  // result in glyphs colliding.

  return max(summed_kern(corr_height_top), summed_kern(corr_height_bot))
}
