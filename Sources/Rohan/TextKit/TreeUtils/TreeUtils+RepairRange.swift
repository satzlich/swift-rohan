// Copyright 2024-2025 Lie Yan

import Foundation

extension TreeUtils {

  /// Repair a range if it is invalid for a tree.
  static func repairRange(
    _ range: RhTextRange, _ tree: RootNode
  ) -> RepairResult<RhTextRange> {
    let path = range.location.indices
    let endPath = range.endLocation.indices
    let minCount = min(path.count, endPath.count)

    // branchIndex ← arg min { path[i] ≠ endPath[i] | i ∈ [0, n) }
    //  where n = min(path.count, endPath.count)
    if let branchIndex = (0..<minCount).first(where: { path[$0] != endPath[$0] }) {

      guard let trace = Trace.from(range.location, tree),
        let endTrace = Trace.from(range.endLocation, tree)
      else { return .failure }

      assert(trace[branchIndex].node === endTrace[branchIndex].node)
      assert(trace[branchIndex].index != endTrace[branchIndex].index)

      let tail = trace[(branchIndex + 1)...]
      let location = repairLocation(range.location, tail: tail, isEnd: false)

      let endTail = endTrace[(branchIndex + 1)...]
      let end = repairLocation(range.endLocation, tail: endTail, isEnd: true)

      switch (location, end) {
      case (.original, .original):
        return .original(range)

      case let (.original(location), .repaired(end)),
        let (.repaired(location), .original(end)),
        let (.repaired(location), .repaired(end)):

        guard let range = RhTextRange(location, end)
        else { return .failure }
        return .repaired(range)

      case (.failure, _), (_, .failure):

        let result = findLocation(range.location, above: branchIndex)

        switch result {
        case let .original(location),
          let .repaired(location):

          let end = TextLocation(location.indices, location.offset + 1)
          guard let newRange = RhTextRange(location, end)
          else { return .failure }

          return .repaired(newRange)

        case .failure:
          return .failure
        }
      }
    }
    // ASSERT: path[0,minCount) == endPath[0,minCount)
    else if path.count != endPath.count {

      guard let trace = Trace.from(range.location, tree),
        let endTrace = Trace.from(range.endLocation, tree)
      else { return .failure }

      switch path.count < endPath.count {
      case true:
        let endTail = endTrace[(minCount + 1)...]
        let result = repairLocation(range.endLocation, tail: endTail, isEnd: true)

        switch result {
        case .failure: return .failure
        case .original: return .original(range)

        case let .repaired(end):
          guard let newRange = RhTextRange(range.location, end)
          else { return .failure }
          return .repaired(newRange)
        }

      case false:
        // ASSERT: path.count > endPath.count

        let tail = trace[(minCount + 1)...]
        let result = repairLocation(range.location, tail: tail, isEnd: false)

        switch result {
        case .failure: return .failure
        case .original: return .original(range)

        case let .repaired(location):
          guard let newRange = RhTextRange(location, range.endLocation)
          else { return .failure }
          return .repaired(newRange)
        }
      }
    }
    else {
      assert(path.count == endPath.count)
      guard let trace = Trace.from(range.location, tree)
      else { return .failure }

      // Successful trace imples valid location (indices and offset).
      // So we only need to check the offset of end location.

      return NodeUtils.validateOffset(range.endLocation.offset, trace.last!.node)
        ? .original(range)
        : .failure
    }

    // Helper

    /// Repair location using the tail of the trace.
    func repairLocation(
      _ location: TextLocation,
      tail: ArraySlice<TraceElement>,
      isEnd: Bool
    ) -> RepairResult<TextLocation> {

      // find index of first opaque node
      guard let index = tail.firstIndex(where: { $0.node.isTransparent == false })
      else { return .original(location) }

      assert(index > 0)

      // compute path
      let newPath = Array(location.indices[0..<index - 1])

      // compute offset
      guard let offset = location.indices[index - 1].index()
      else { return .failure }
      let newOffset = isEnd ? offset + 1 : offset

      return .repaired(TextLocation(newPath, newOffset))
    }

    /// Find a valid location above the given index.
    func findLocation(
      _ location: TextLocation, above index: Int
    ) -> RepairResult<TextLocation> {
      precondition(index < location.indices.count)
      let path = location.indices

      guard let i = path[0..<index].lastIndex(where: { $0.index() != nil })
      else { return .failure }
      let newPath = Array(path[0..<i])
      let newOffset = path[i].index()!

      return .repaired(TextLocation(newPath, newOffset))
    }
  }

  /// Given a range and a tree, returns true if the range is valid for selection
  /// in the tree.
  /// - Important: A _valid range for selection_ is a pair of insertion points that
  ///     don't meet any opaque nodes after branching.
  static func validateRange(_ range: RhTextRange, _ tree: RootNode) -> Bool {

    /// Returns true if the tail of the trace is transparent.
    func isTransparent(_ tail: ArraySlice<TraceElement>) -> Bool {
      return tail.allSatisfy({ $0.node.isTransparent })
    }

    let path = range.location.indices
    let endPath = range.endLocation.indices
    let minCount = min(path.count, endPath.count)

    // branchIndex ← arg min { path[i] ≠ endPath[i] | i ∈ [0, n) }
    //  where n = min(path.count, endPath.count)
    if let branchIndex = (0..<minCount).first(where: { path[$0] != endPath[$0] }) {
      // ASSERT: path[0,branchIndex) == endPath[0,branchIndex)

      // trace nodes for locations
      guard let trace = Trace.from(range.location, tree),
        let endTrace = Trace.from(range.endLocation, tree)
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
      guard let endTrace = Trace.from(range.endLocation, tree)
      else { return false }
      // check tail of end location and offset of location
      return NodeUtils.validateOffset(range.location.offset, endTrace[minCount].node)
        && isTransparent(endTrace[(minCount + 1)...])
    }
    // ASSERT: path.count >= endPath.count
    else if path.count > endPath.count {
      // trace nodes indicates location is okay
      guard let trace = Trace.from(range.location, tree) else { return false }
      // check tail of location and offset of end location
      return NodeUtils.validateOffset(range.endLocation.offset, trace[minCount].node)
        && isTransparent(trace[(minCount + 1)...])
    }
    // ASSERT: path.count == endPath.count
    else {
      // trace nodes indicates location is okay
      guard let trace = Trace.from(range.location, tree) else { return false }
      // check offset of end location
      return NodeUtils.validateOffset(range.endLocation.offset, trace.last!.node)
    }
  }
}
