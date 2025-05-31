// Copyright 2024-2025 Lie Yan

public final class DeparseContext {
  public let registry: LaTeXRegistry

  public init(_ registry: LaTeXRegistry) {
    self.registry = registry
  }

  public static var defaultValue: DeparseContext {
    DeparseContext(LaTeXRegistry.defaultValue)
  }
}
