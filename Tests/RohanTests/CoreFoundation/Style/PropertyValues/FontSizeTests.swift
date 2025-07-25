import Foundation
import Testing

@testable import SwiftRohan

struct FontSizeTests {
  @Test
  func coverage() {
    _ = FontSize(10)
    _ = FontSize(rawValue: 10.8)

    let _: FontSize = 10.5
    let _: FontSize = 10
  }

  @Test
  func validate() {
    #expect(FontSize.validate(floatValue: 0.5) == false)
    #expect(FontSize.validate(floatValue: 1))
    #expect(FontSize.validate(floatValue: 10))
    #expect(FontSize.validate(floatValue: 10.5))
    #expect(FontSize.validate(floatValue: 10.8) == false)
    #expect(FontSize.validate(floatValue: 1638))
    #expect(FontSize.validate(floatValue: 1639) == false)
  }
}
