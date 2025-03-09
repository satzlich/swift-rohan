// Copyright 2024-2025 Lie Yan

import Foundation

enum PrintUtils {
  /**

   ## Example
   Code:
   ```swift
   let root = ["root"]
   let children = [
     ["child1"],
     ["child2",
      " └ grandchild1"],
   ]
   PrintUtils.compose(root, children).joined(separator: "\n")
   ```
   Output:
   ```
   root
    ├ child1
    └ child2
       └ grandchild1
   ```
   */
  static func compose(_ root: Array<String>, _ children: [Array<String>]) -> Array<String> {
    func convert(_ printout: Array<String>) -> Array<String> {
      guard !printout.isEmpty else { return [] }
      let first = ["├ " + printout[0]]
      let rest = printout.dropFirst().map {
        "│ " + $0
      }
      return first + rest
    }
    func convertLast(_ printout: Array<String>) -> Array<String> {
      guard !printout.isEmpty else { return [] }
      let first = ["└ " + printout[0]]
      let rest = printout.dropFirst().map {
        "  " + $0
      }
      return first + rest
    }
    guard !children.isEmpty else { return root }
    let middle = children.dropLast().flatMap(convert(_:))
    let last = convertLast(children.last!)
    return root + middle + last
  }
}
