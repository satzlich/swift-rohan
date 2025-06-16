// Copyright 2024-2025 Lie Yan

import Foundation
import Testing

@testable import SwiftRohan

struct SnippetsTests {
  @Test
  func leftRight() {
    // pass string parameters
    do {
      _ = Snippets.leftRight(.pair("lvert", "rvert"))
      _ = Snippets.leftRight(.left("lvert"))
      _ = Snippets.leftRight(.right("rvert"))

      //
      _ = Snippets.leftRight(.pair("nonexistent", "rvert"))
      _ = Snippets.leftRight(.pair("lvert", "nonexistent"))
      _ = Snippets.leftRight(.left("nonexistent"))
      _ = Snippets.leftRight(.right("nonexistent"))
    }

    // pass extended char parameters, nil case only.
    do {
      // 碐 is a representative for non-existent characters.
      _ = Snippets.leftRight(.pair(.char("碐"), .char("}")))
      _ = Snippets.leftRight(.pair(.char("("), .char("碐")))
      _ = Snippets.leftRight(.left(.char("碐")))
      _ = Snippets.leftRight(.right(.char("碐")))
    }
  }
}
