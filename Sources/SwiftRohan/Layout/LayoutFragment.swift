// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation

protocol LayoutFragment: GlyphProtocol {
  /// Origin of the fragment in the layout context.
  var glyphOrigin: CGPoint { get }

  /// Length perceived by the layout context.
  /// - Note: `layoutLength` may differ from the sum over its children.
  var layoutLength: Int { get }
}
