import Foundation
import Testing

@testable import SwiftRohan

struct CompletionItemTests {
  @MainActor
  @Test
  func view() {
    let query = "right"
    let key = "rightarrow"
    let result = CompletionProvider.Result(
      key: key, value: CommandRecord(NamedSymbol.lookup(key)!),
      matchSpec: .prefix(caseSensitive: true, length: query.count))
    let completionItem = CompletionItem(id: UUID().uuidString, result, query)
    _ = completionItem.view
  }

  @MainActor
  @Test
  func preview() {
    do {
      let key = "frac"
      let query = "frac"
      let frac = MathGenFrac.frac
      let result = CompletionProvider.Result(
        key: key,
        value: CommandRecord(frac.command, CommandBody.fractionExpr(frac, image: "frac")),
        matchSpec: .equal(caseSensitive: true, length: query.count))
      let completionItem = CompletionItem(id: UUID().uuidString, result, query)
      _ = completionItem.view
    }
    do {
      let key = "frac"
      let query = "frac"
      let frac = MathGenFrac.frac
      let result = CompletionProvider.Result(
        key: key,
        value: CommandRecord(
          frac.command, CommandBody.fractionExpr(frac, image: "nonexistent")),
        matchSpec: .equal(caseSensitive: true, length: query.count))
      let completionItem = CompletionItem(id: UUID().uuidString, result, query)
      _ = completionItem.view
    }
  }

  @MainActor
  @Test
  func generateLabel() {
    do {
      let key = "rightarrow"
      let query = "rightw"
      let result = CompletionProvider.Result(
        key: key, value: CommandRecord(NamedSymbol.lookup(key)!),
        matchSpec: .prefixPlus(caseSensitive: true, length: query.count))
      let completionItem = CompletionItem(id: UUID().uuidString, result, query)
      _ = completionItem.view
    }
    do {
      let key = "rightarrow"
      let query = "ight"
      let result = CompletionProvider.Result(
        key: key, value: CommandRecord(NamedSymbol.lookup(key)!),
        matchSpec: .subString(location: 1, length: query.count))
      let completionItem = CompletionItem(id: UUID().uuidString, result, query)
      _ = completionItem.view
    }
    do {
      let key = "rightarrow"
      let query = "ightw"
      let result = CompletionProvider.Result(
        key: key, value: CommandRecord(NamedSymbol.lookup(key)!),
        matchSpec: .subStringPlus(location: 1, length: "ight".count))
      let completionItem = CompletionItem(id: UUID().uuidString, result, query)
      _ = completionItem.view
    }
    do {
      let key = "rightarrow"
      let query = "riro"
      let result = CompletionProvider.Result(
        key: key, value: CommandRecord(NamedSymbol.lookup(key)!),
        matchSpec: .nGram(length: query.count))
      let completionItem = CompletionItem(id: UUID().uuidString, result, query)
      _ = completionItem.view
    }
    do {
      let key = "rightarrow"
      let query = "riro"
      let result = CompletionProvider.Result(
        key: key, value: CommandRecord(NamedSymbol.lookup(key)!),
        matchSpec: .nGramPlus(length: query.count))
      let completionItem = CompletionItem(id: UUID().uuidString, result, query)
      _ = completionItem.view
    }
  }
}
