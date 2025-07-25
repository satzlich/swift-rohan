import Foundation
import Numerics
import Testing

@testable import SwiftRohan

struct ColorTests {
  @Test
  func coverage() throws {
    let color = Color(red: 0.9, green: 0.8, blue: 0.7, alpha: 0.6)
    #expect(color.red == 0.9)
    #expect(color.green == 0.8)
    #expect(color.blue == 0.7)
    #expect(color.alpha == 0.6)

    do {
      let encoder = JSONEncoder()
      let decoder = JSONDecoder()

      let data = try encoder.encode(color)
      let decodedColor = try decoder.decode(Color.self, from: data)
      #expect(color == decodedColor)
    }
  }
}
