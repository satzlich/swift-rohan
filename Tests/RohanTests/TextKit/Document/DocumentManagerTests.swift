// Copyright 2024-2025 Lie Yan

import Testing

@testable import SwiftRohan

final class DocumentManagerTests {
  /// Helper function to create a `DocumentManager` instance with a given content.
  private func _createDocumentManager(_ content: ElementStore) -> DocumentManager {
    let rootNode = RootNode(content)
    let documentManager = DocumentManager(rootNode, StyleSheetTests.testingStyleSheet())
    return documentManager
  }

  @Test
  func crossedObjectAt() {
    let documentManager = _createDocumentManager([])
  }
}
