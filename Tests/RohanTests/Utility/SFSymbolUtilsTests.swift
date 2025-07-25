import Cocoa
import Foundation
import Testing

@testable import SwiftRohan

struct SFSymbolUtilsTests {
  @Test
  @MainActor
  func coverage() {
    _ = SFSymbolUtils.textField(for: "note.text", 12)
  }
}
