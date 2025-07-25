import AppKit
import Foundation

protocol LayoutFragment: GlyphProtocol {
  /// Fragment position in the enclosing frame.
  var glyphOrigin: CGPoint { get }

  /// Layout length perceived by the layout context.
  var layoutLength: Int { get }
}
