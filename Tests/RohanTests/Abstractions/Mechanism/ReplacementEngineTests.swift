// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct ReplacementEngineTests {
  @Test
  func coverage() {
    let rules: Array<ReplacementRule> = [
      .init("", "`", CommandBody("\u{2018}", .textText)),
      .init("\u{2018}", "`", CommandBody("\u{201C}", .textText)),
      .init("", "'", CommandBody("\u{2019}", .textText)),
      .init("\u{2019}", "'", CommandBody("\u{201D}", .textText)),
    ]

    let engine = ReplacementEngine(rules)

    #expect(engine.prefixSize(for: "`") == 1)
    #expect(engine.prefixSize(for: "'") == 1)
    #expect(engine.prefixSize(for: "a") == nil)

    // "`" -> "‘"
    do {
      guard let (command, prefix) = engine.replacement(for: "`", prefix: "abc")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.insertString()?.string == "\u{2018}")
      #expect(prefix.count == 0)
    }

    // "‘" + "`" -> "“"
    do {
      guard let (command, prefix) = engine.replacement(for: "`", prefix: "abc\u{2018}")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.insertString()?.string == "\u{201C}")
      #expect(prefix.count == 1)
    }

    // "'" -> "’"
    do {
      guard let (command, prefix) = engine.replacement(for: "'", prefix: "abc")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.insertString()?.string == "\u{2019}")
      #expect(prefix.count == 0)
    }

    // "’" + "'" -> "”"
    do {
      guard let (command, prefix) = engine.replacement(for: "'", prefix: "abc\u{2019}")
      else {
        Issue.record("No replacement found")
        return
      }
      #expect(command.insertString()?.string == "\u{201D}")
      #expect(prefix.count == 1)
    }

    // "a" -> NO replacement
    do {
      let result = engine.replacement(for: "a", prefix: "")
      #expect(result == nil)
    }
  }

  @Test
  func testEmpty() {
    _ = ReplacementEngine([])
  }
}
