// Copyright 2024-2025 Lie Yan

protocol CommandDeclarationProtocol: Codable {
  var command: String { get }
  static var predefinedCases: [Self] { get }
}
