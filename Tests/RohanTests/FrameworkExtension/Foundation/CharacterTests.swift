// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct CharacterTests {
  @Test
  func codable() {
    let json = """
      ""
      """
    let decoder = JSONDecoder()

    #expect(throws: DecodingError.self) {
      try decoder.decode(Character.self, from: Data(json.utf8))
    }
  }

}
