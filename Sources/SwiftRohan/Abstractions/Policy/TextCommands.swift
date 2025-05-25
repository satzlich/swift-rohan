// Copyright 2024-2025 Lie Yan

import Foundation

/// Non-symbol text commands.
enum TextCommands {
  static let allCases: [CommandRecord] = [
    // sections
    .init("h1", Snippets.header(level: 1)),
    .init("h2", Snippets.header(level: 2)),
    .init("h3", Snippets.header(level: 3)),
    // style
    .init("emph", Snippets.emphasis),
    .init("strong", Snippets.strong),
    // math
    .init("equation*", Snippets.equation),
  ]
}
