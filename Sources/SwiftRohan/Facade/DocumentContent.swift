// Copyright 2024-2025 Lie Yan

import Foundation

public final class DocumentContent {
  /// Deserialize a document content from data.
  public static func from(_ data: Data) -> DocumentContent? {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(JSONValue.self, from: data)
    else { return nil }
    let rootNode = RootNode.loadSelf(from: json)
    switch rootNode {
    case .success(let node), .corrupted(let node):
      return DocumentContent(node)
    case .failure:
      return nil
    }
  }

  /// Serialize the document content to data.
  public func data() -> Data? {
    let encoder = JSONEncoder()
    #if DEBUG
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
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
