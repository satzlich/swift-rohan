// Copyright 2024-2025 Lie Yan

import CoreGraphics
import Testing

@testable import SwiftRohan

final class ResolveTextLocationTests: TextKitTestsBase {

  @Test
  func resolveTextLocation_SimpleNode() throws {
    let documentManager = self.createDocumentManager(
      RootNode([
        EquationNode(
          .inline,
          [
            TextNode("a"),
            NamedSymbolNode(NamedSymbol.lookup("beta")!),
            TextNode("c"),
            ApplyNode(MathTemplate.operatorname, [[]])!,
          ])
      ]))

    guard let location0 = documentManager.resolveTextLocation(with: CGPoint(x: 13, y: 5)),
      let location1 = documentManager.resolveTextLocation(with: CGPoint(x: 15, y: 5)),
      let location2 = documentManager.resolveTextLocation(with: CGPoint(x: 37.55, y: 5))
    else {
      Issue.record("Failed to resolve text location")
      return
    }

    #expect("\(location0.value)" == "[↓0,nuc,↓0]:1")
    #expect("\(location1.value)" == "[↓0,nuc,↓2]:0")
    #expect("\(location2.value)" == "[↓0,nuc,↓3,⇒0]:0")
  }
}
