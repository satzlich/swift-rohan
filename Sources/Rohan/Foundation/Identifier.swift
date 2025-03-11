// Copyright 2024-2025 Lie Yan

import Foundation

struct Identifier: Equatable, Hashable, Codable, CustomStringConvertible, Sendable {
  let name: String

  init(_ name: String) {
    precondition(Identifier.validate(name: name))
    self.name = name
  }

  static func validate(name: String) -> Bool {
    (try? #/[a-zA-Z_][a-zA-Z0-9_]*/#.wholeMatch(in: name) != nil) ?? false
  }

  var description: String {
    name
  }
}
