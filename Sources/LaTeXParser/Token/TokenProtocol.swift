// Copyright 2024-2025 Lie Yan

import Foundation

public protocol TokenProtocol: Sendable {
  func untokenize() -> String

  /// True if the token ends with an identifier.
  var endsWithIdentifier: Bool { get }

  /// True if the token has a prefix which spoils a preceding identifier
  /// when concatenated.
  var startsWithIdSpoiler: Bool { get }
}
