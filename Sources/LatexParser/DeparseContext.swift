// Copyright 2024-2025 Lie Yan

public final class DeparseContext {
  public let registry: LatexRegistry

  public init(_ registry: LatexRegistry) {
    self.registry = registry
  }

  public static var defaultValue: DeparseContext {
    DeparseContext(LatexRegistry.defaultValue)
  }
}
