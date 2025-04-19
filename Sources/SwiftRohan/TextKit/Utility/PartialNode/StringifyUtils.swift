// Copyright 2024-2025 Lie Yan

import _RopeModule

enum StringifyUtils {
  static func stringify<S>(_ nodes: S) -> BigString
  where S: Collection, S.Element == PartialNode {
    let newlines = NewlineArray(nodes.lazy.map(\.isBlock))
    var result: BigString = ""
    for (i, child) in nodes.enumerated() {
      result += child.stringify()
      if newlines[i] { result += "\n" }
    }
    return result
  }
}
