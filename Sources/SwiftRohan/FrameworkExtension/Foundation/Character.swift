// Copyright 2024-2025 Lie Yan

import Foundation

extension Character {
  @inline(__always) var length: Int { utf16.count }
}

extension Character: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    guard let character = string.first else {
      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Invalid character")
    }
    self = character
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(String(self))
  }
}
