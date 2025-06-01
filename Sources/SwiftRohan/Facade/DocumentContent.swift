// Copyright 2024-2025 Lie Yan

import AppKit
import Foundation
import LatexParser

public final class DocumentContent {

  // MARK: - Export

  public enum ExportFormat: String {
    case latexDocument
  }

  public func exportDocument(to format: ExportFormat) -> Data? {
    switch format {
    case .latexDocument:
      let context = DeparseContext(Rohan.latexRegistry)
      return NodeUtils.exportLatexDocument(rootNode, context: context)
        .flatMap { $0.data(using: .utf8) }
    }
  }

  // MARK: - Load/Save

  /// Deserialize a document content from data.
  public static func from(_ data: Data) -> DocumentContent? {
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

  /// Serialize the document content to data.
  public func data() -> Data? {
    let encoder = JSONEncoder()
    #if DEBUG
    encoder.outputFormatting = [
      .sortedKeys
      // .prettyPrinted,
    ]
    #endif
    return try? encoder.encode(rootNode.store())
  }

  internal let rootNode: RootNode

  public init() {
    self.rootNode = RootNode([ParagraphNode()])
  }

  public init(_ rootNode: RootNode) {
    self.rootNode = rootNode
  }
}
