// Copyright 2024-2025 Lie Yan

internal struct TargetSelector: Equatable, Hashable, Codable, Sendable {
  /// Target node type
  public let type: NodeType

  /// Target intrinsic property to match
  public let matcher: PropertyMatcher?

  public init(_ type: NodeType, _ matcher: PropertyMatcher? = nil) {
    self.type = type
    self.matcher = matcher
  }
}
