// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

public protocol LayoutFragment {
  // MARK: - Frame

  /// Origin of the fragment in the layout context.
  var glyphOrigin: CGPoint { get }

  /// Size of the fragment in the layout context.
  var glyphSize: CGSize { get }

  /// The position of baseline measured from the top of fragment.
  var baselinePosition: CGFloat { get }

  /// bounds with origin at the baseline
  var bounds: CGRect { get }

  // MARK: - Length

  /// Length perceived by the layout context.
  /// - Note: `layoutLength` may differ from the sum over its children.
  var layoutLength: Int { get }

  // MARK: - Draw

  func draw(at point: CGPoint, in context: CGContext)
}
