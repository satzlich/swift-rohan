// Copyright 2024-2025 Lie Yan

/**
 A template name.

 - Note: Currently it is essentially an identifier, but in the future it may be more complex.
 */
struct TemplateName: Equatable, Hashable, CustomStringConvertible, Sendable {
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
}
