import Foundation

public enum PrintUtils {
  /**
   Compose a tree-like structure with the descriptions for the root and children.
  
   ## Example
   ```swift
   let root = ["root"]
   let children = [
     ["child1"],
     ["child2",
      "└ grandchild1"],
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
  public static func compose(
    _ root: Array<String>, _ children: [Array<String>]
  ) -> Array<String> {
    func convert(_ printout: Array<String>) -> Array<String> {
      guard !printout.isEmpty else { return [] }
      let first = ["├ " + printout.first!]
      let rest = printout.dropFirst().map {
        "│ " + $0
      }
      return first + rest
    }
    func convertLast(_ printout: Array<String>) -> Array<String> {
      guard !printout.isEmpty else { return [] }
      let first = ["└ " + printout.first!]
      let rest = printout.dropFirst().map { "  " + $0 }
      return first + rest
    }

    if children.isEmpty {
      return root
    }
    else {
      let middle = children.dropLast().flatMap(convert(_:))
      let last = convertLast(children.last!)
      return root + middle + last
    }
  }
}
