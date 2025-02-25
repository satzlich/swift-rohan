// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
  enum RepairResult<T>: Equatable, Hashable
  where T: Equatable & Hashable {
    case original(T)
    case repaired(T)
    case unrepairable
  }

  /**
   Repair a selection range if it is invalid for a tree.

   ## Semantics
   - If location and endLocation are both valid insertion points in the tree,
   then the range is either valid or can be repaired to be valid. In the former case,
   return the original range with `modified: false`. In the latter case, return the
   repaired range with `modified: true`.
   - Otherwise, return `nil`.
   */
  static func repairTextRange(_ range: RhTextRange, _ tree: RootNode) -> RepairResult<RhTextRange> {
    /*
     Try to repair tail and return the repaired location.

     1. If tail is valid, return the original location with `modified: false`.
     2. If tail can be repaired, return the repaired location with `modified: true`.
     3. If tail cannot be repaired, return `nil`.

     - Parameters:
       - tail: the tail of the path
       - location: the original location
       - isEndLocation: true if location is the end location
     */
    func repairTail(
      _ tail: ArraySlice<TraceElement>,
      _ location: TextLocation,
      _ isEndLocation: Bool
    ) -> RepairResult<TextLocation> {
      guard let index = tail.firstIndex(where: { $0.node.isOpaque })
      else { return .original(location) }
      // since the tail is opaque somewhere, do repair
      assert(index > 0)
      let path = Array(location.indices[0..<index - 1])
      guard var offset = location.indices[index - 1].index() else { return .unrepairable }
      if isEndLocation { offset += 1 }
      return .repaired(TextLocation(path, offset))
    }

    let path = range.location.indices
    let endPath = range.endLocation.indices
    let minCount = min(path.count, endPath.count)

    // arg min { path[i] ≠ endPath[i] | i ∈ [0, n) }
    //  where n = min(path.count, endPath.count)
    if let branchIndex = (0..<minCount).first(where: { path[$0] != endPath[$0] }) {
      // trace nodes along path
      guard let trace = traceNodes(range.location, tree),
        let endTrace = traceNodes(range.endLocation, tree)
      else { return .unrepairable }
      assert(trace[branchIndex].node === endTrace[branchIndex].node)
      assert(trace[branchIndex].index != endTrace[branchIndex].index)

      // try to repair the part after branch index
      let location = repairTail(trace[(branchIndex + 1)...], range.location, false)
      let end = repairTail(endTrace[(branchIndex + 1)...], range.endLocation, true)

      switch (location, end) {
      case (.unrepairable, _), (_, .unrepairable):
        return .unrepairable
      case (.original, .original):
        return .original(range)
      case let (.repaired(location), .repaired(end)),
        let (.original(location), .repaired(end)),
        let (.repaired(location), .original(end)):
        guard let range = RhTextRange(location, end) else { return .unrepairable }
        return .repaired(range)
      }
    }
    // ASSERT: path[0,minCount) == endPath[0,minCount)
    else if path.count != endPath.count {
      // trace nodes for locations
      guard let trace = traceNodes(range.location, tree),
        let endTrace = traceNodes(range.endLocation, tree)
      else { return .unrepairable }
      // try to repair the part after minCount
      if path.count < endPath.count {
        switch repairTail(endTrace[(minCount + 1)...], range.endLocation, true) {
        case .unrepairable:
          return .unrepairable
        case .original:
          return .original(range)
        case let .repaired(end):
          guard let range = RhTextRange(range.location, end) else { return .unrepairable }
          return .repaired(range)
        }
      }
      // ASSERT: path.count > endPath.count
      else {
        switch repairTail(trace[(minCount + 1)...], range.location, false) {
        case .unrepairable:
          return .unrepairable
        case .original:
          return .original(range)
        case let .repaired(location):
          guard let range = RhTextRange(location, range.endLocation) else { return .unrepairable }
          return .repaired(range)
        }
      }
    }
    // ASSERT: path.count == endPath.count
    else {
      guard let trace = traceNodes(range.location, tree) else { return .unrepairable }
      return validateOffset(range.endLocation.offset, trace.last!.node)
        ? .original(range)
        : .unrepairable
    }
  }

  /**
   Given a range and a tree, returns true if the range is valid for selection
   in the tree.

   - Important: A _valid range for selection_ is a pair of insertion points that
   don't meet any opaque nodes after branching.
   */
  static func validateTextRange(_ range: RhTextRange, _ tree: RootNode) -> Bool {
    func isTransparent(_ tail: ArraySlice<TraceElement>) -> Bool {
      // check all nodes after branch index are non-opaque
      return tail.allSatisfy({ !$0.node.isOpaque })
    }

    let path = range.location.indices
    let endPath = range.endLocation.indices
    let minCount = min(path.count, endPath.count)

    // arg min { path[i] ≠ endPath[i] | i ∈ [0, n) }
    //  where n = min(path.count, endPath.count)
    if let branchIndex = (0..<minCount).first(where: { path[$0] != endPath[$0] }) {
      // ASSERT: path[0,branchIndex) == endPath[0,branchIndex)

      // trace nodes for locations
      guard let trace = traceNodes(range.location, tree),
        let endTrace = traceNodes(range.endLocation, tree)
      else { return false }
      assert(trace[branchIndex].node === endTrace[branchIndex].node)
      assert(trace[branchIndex].index != endTrace[branchIndex].index)
      // check tails of location and end location
      return isTransparent(trace[(branchIndex + 1)...])
        && isTransparent(endTrace[(branchIndex + 1)...])
    }
    // ASSERT: path[0,minCount) == endPath[0,minCount)
    else if path.count < endPath.count {
      // trace nodes indicates end location is okay
      guard let endTrace = traceNodes(range.endLocation, tree) else { return false }
      // check tail of end location and offset of location
      return validateOffset(range.location.offset, endTrace[minCount].node)
        && isTransparent(endTrace[(minCount + 1)...])
    }
    // ASSERT: path.count >= endPath.count
    else if path.count > endPath.count {
      // trace nodes indicates location is okay
      guard let trace = traceNodes(range.location, tree) else { return false }
      // check tail of location and offset of end location
      return validateOffset(range.endLocation.offset, trace[minCount].node)
        && isTransparent(trace[(minCount + 1)...])
    }
    // ASSERT: path.count == endPath.count
    else {
      // trace nodes indicates location is okay
      guard let trace = traceNodes(range.location, tree) else { return false }
      // check offset of end location
      return validateOffset(range.endLocation.offset, trace.last!.node)
    }
  }

  /** Returns true if the offset is valid for the node. */
  static func validateOffset(_ offset: Int, _ node: Node) -> Bool {
    switch node {
    case let textNode as TextNode:
      return (0...textNode.stringLength) ~= offset
    case let elementNode as ElementNode:
      return (0...elementNode.childCount) ~= offset
    default:
      return false
    }
  }
}
