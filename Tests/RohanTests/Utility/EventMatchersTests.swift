import Cocoa
import Foundation
import Testing

@testable import SwiftRohan

struct EventMatchersTests {
  @Test
  func coverage() {
    let event = NSEvent.keyEvent(
      with: .keyDown, location: CGPoint(x: 10, y: 10), modifierFlags: .shift,
      timestamp: .init(), windowNumber: 1, context: nil, characters: "x",
      charactersIgnoringModifiers: "x", isARepeat: false, keyCode: 53)!

    _ = EventMatchers.isEscape(event)
    _ = EventMatchers.isCharacter("x", event)
    _ = EventMatchers.isControlSpace(event)
  }
}
