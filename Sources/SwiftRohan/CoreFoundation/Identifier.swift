// Copyright 2024-2025 Lie Yan

import Foundation

struct Identifier: Equatable, Hashable, Codable, CustomStringConvertible, Sendable {
  let name: String

  init(_ name: String) {
    precondition(Identifier.validate(name: name))
    self.name = name
  }

  static func validate(name: String) -> Bool {
    // regex is guaranteed to be correct
    try! #/[a-zA-Z_][a-zA-Z0-9_]*/#.wholeMatch(in: name) != nil
  }

  var description: String { name }

  // MARK: - Codable

  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    name = try container.decode(String.self)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(name)
  }
}
