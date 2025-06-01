// Copyright 2024-2025 Lie Yan

import LatexParser

protocol CommandDeclarationProtocol: Codable {
  var command: String { get }
  var tag: CommandTag { get }
  var source: CommandSource { get }
  static var allCommands: Array<Self> { get }
}
