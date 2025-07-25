import Cocoa
import Foundation
import Testing

@testable import SwiftRohan

struct NSWindowTests {
  @Test
  @MainActor
  func coverage() {
    let window = NSWindow()
    window.shake()
  }
}
