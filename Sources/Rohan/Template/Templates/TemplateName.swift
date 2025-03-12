// Copyright 2024-2025 Lie Yan

/**
 A template name.

 - Note: Currently it is essentially an identifier, but in the future it may be more complex.
 */
struct TemplateName: Equatable, Hashable, Codable, CustomStringConvertible, Sendable {
  let identifier: Identifier

  init(_ identifier: Identifier) {
    self.identifier = identifier
  }

  init(_ string: String) {
    self.init(Identifier(string))
  }

  var description: String {
    identifier.description
  }

  // MARK: - Codable

  init(from decoder: any Decoder) throws {
    self.identifier = try Identifier(from: decoder)
  }

  func encode(to encoder: any Encoder) throws {
    try identifier.encode(to: encoder)
  }
}
