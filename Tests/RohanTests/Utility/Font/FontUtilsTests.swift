import Cocoa
import CoreText
import Foundation
import Testing

@testable import SwiftRohan

struct FontUtilsTests {
  @Test
  func coverage() {
    let font = NSFont.systemFont(ofSize: 12)
    _ = FontUtils.fontWithCascade(baseFont: font, cascadeList: ["Arial", "Helvetica"])
  }
}
