// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ReplacementEngineTests {
  @Test
  func testBasic() {
    let rules: [ReplacementRule] = [
      .init("", "`", CommandBody("\u{2018}", .plaintext)),
      .init("\u{2018}", "`", CommandBody("\u{201C}", .plaintext)),
      .init("", "'", CommandBody("\u{2019}", .plaintext)),
      .init("\u{2019}", "'", CommandBody("\u{201D}", .plaintext)),
    ]

    let engine = ReplacementEngine(rules)
    #expect(engine.maxPrefixSize == 1)

    // "`" -> "‘"
    do {
      guard let (command, prefix) = engine.replacement(for: "`", prefix: "abc")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.content.plaintext() == "\u{2018}")
      #expect(prefix == 0)
    }

    // "‘" + "`" -> "“"
    do {
      guard let (command, prefix) = engine.replacement(for: "`", prefix: "abc\u{2018}")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.content.plaintext() == "\u{201C}")
      #expect(prefix == 1)
    }

    // "'" -> "’"
    do {
      guard let (command, prefix) = engine.replacement(for: "'", prefix: "abc")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.content.plaintext() == "\u{2019}")
      #expect(prefix == 0)
    }

    // "’" + "'" -> "”"
    do {
      guard let (command, prefix) = engine.replacement(for: "'", prefix: "abc\u{2019}")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.content.plaintext() == "\u{201D}")
      #expect(prefix == 1)
    }
  }
}
