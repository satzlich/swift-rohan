import Cocoa
import Foundation

extension NSWindow {
  /// Shakes the window.
  func shake() {
    let duration = 0.5
    let frame = self.frame
    let shakeAnimation =
      Self.shakeAnimation(frame, numberOfShakes: 3, duration: duration, vigour: 0.01)

    // Apply the animation to the window's frame
    let animationKey = "frameOrigin"
    self.animations = [animationKey: shakeAnimation]
    self.animator().setFrameOrigin(frame.origin)

    // Reset animations after completion
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      self.animations[animationKey] = nil
    }
  }

  /// Creates a shake animation.
  /// - Parameters:
  ///   - frame: The frame of the window.
  ///   - numberOfShakes: The number of shakes.
  ///   - duration: The duration of the animation.
  ///   - vigour: How far the window moves during the shake.
  private static func shakeAnimation(
    _ frame: CGRect, numberOfShakes: Int, duration: Double, vigour: CGFloat
  ) -> CAKeyframeAnimation {
    let shakeAnimation = CAKeyframeAnimation()

    // Define the movement path (left-right shaking)
    let shakePath = CGMutablePath()
    shakePath.move(to: frame.origin)
    for _ in 0..<numberOfShakes {
      shakePath.addLine(to: frame.origin.with(xDelta: -frame.size.width * vigour))
      shakePath.addLine(to: frame.origin.with(xDelta: frame.size.width * vigour))
    }
    shakePath.closeSubpath()

    shakeAnimation.path = shakePath
    shakeAnimation.duration = duration

    return shakeAnimation
  }
}
