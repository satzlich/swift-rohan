// Copyright 2024-2025 Lie Yan

import Foundation

public final class DocumentContent {
  /// Deserialize a document content from data.
  public static func from(_ data: Data) -> DocumentContent? {
    guard let node = try? NodeSerdeUtils.decodeNode(from: data),
      let rootNode = node as? RootNode
    else { return nil }
    return DocumentContent(rootNode)
  }

  /// Serialize the document content to data.
  public func data() -> Data? {
    let encoder = JSONEncoder()
    #if DEBUG
    encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
    #endif
    return try? encoder.encode(rootNode)
  }

  internal let rootNode: RootNode

  public init() {
    self.rootNode = RootNode([ParagraphNode()])
  }

  public init(_ rootNode: RootNode) {
    self.rootNode = rootNode
  }
}
