// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import LatexParser

public final class DocumentContent {
  public enum OutputFormat: String {
    case latex
    case rohan
  }

  /// Deserialize a document content from data.
  public static func readFrom(_ data: Data) -> DocumentContent? {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(JSONValue.self, from: data)
    else { return nil }

    let result = RootNode.loadSelf(from: json)
    switch result {
    case .success(let node),
      .corrupted(let node):
      return DocumentContent(node)
    case .failure:
      return nil
    }
  }

  public func writeData(format: OutputFormat) -> Data? {
    switch format {
    case .latex:
      let context = DeparseContext(Rohan.latexRegistry)
      return NodeUtils.exportLatexDocument(rootNode, context: context)
        .flatMap { $0.data(using: .utf8) }

    case .rohan:
      let encoder = JSONEncoder()
      #if DEBUG
      encoder.outputFormatting = [.sortedKeys]
      #endif
      return try? encoder.encode(rootNode.store())
    }
  }

  // MARK: - State

  internal let rootNode: RootNode

  public init() {
    self.rootNode = RootNode([ParagraphNode()])
  }

  init(_ rootNode: RootNode) {
    self.rootNode = rootNode
  }
}
