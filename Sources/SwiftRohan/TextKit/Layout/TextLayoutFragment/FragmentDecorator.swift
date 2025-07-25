import AppKit
import CoreGraphics

protocol FragmentDecorator {
  func draw(at point: CGPoint, in context: CGContext, for fragment: NSTextLayoutFragment)
}
