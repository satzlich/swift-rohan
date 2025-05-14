// Copyright 2024-2025 Lie Yan

/// Symbols that works in Text body and Math list.
enum UniversalSymbols {
  static let allCases: [SymbolMnemonic] = [
    .init("P", "\u{00B6}"),  // ¶
    .init("S", "\u{00A7}"),  // §
    .init("dag", "\u{2020}"),  // †
    .init("ddag", "\u{2021}"),  // ‡
    .init("QED", "\u{220E}"),  // ∎
  ]
}
