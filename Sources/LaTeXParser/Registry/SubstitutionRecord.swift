// Copyright 2024-2025 Lie Yan

public struct SubstitutionRecord {
  public let character: Character
  public let replacement: Array<StreamletSyntax>
  public let mode: LayoutMode

  public init(
    _ character: Character, _ replacement: Array<StreamletSyntax>, mode: LayoutMode
  ) {
    precondition(mode == .textMode || mode == .mathMode)
    self.character = character
    self.replacement = replacement
    self.mode = mode
  }
}
