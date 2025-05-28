// Copyright 2024-2025 Lie Yan

import Foundation

public protocol TokenProtocol: Sendable {
  func deparse() -> String

  /// True if the token ends with an identifier.
  var endsWithIdentifier: Bool { get }

  /// True if it is unsafe to be preceded by an identifier.
  var startsWithIdentifierUnsafe: Bool { get }
}
