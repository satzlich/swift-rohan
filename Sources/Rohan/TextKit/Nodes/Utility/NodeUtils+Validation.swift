// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
    /**
     Try to repair a selection range if it is invalid for a subtree.

     - If start and end locations both point to valid insertion points in the subtree,
     then the range is either valid or can be repaired to be valid.
     - If the range is already valid, then return the original range with
     `modified: false`. Otherwise, return the repaired range with `modified: true`.
     - If the range cannot be repaired, return `nil`.

     - Note: A valid range may not be __valid for selection__. So repair is necessary.
     */
    static func repairTextRange(_ range: RhTextRange,
                                _ subtree: Node) -> (RhTextRange, modified: Bool)?
    {
        precondition(subtree.nodeType == .root)

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
        func repairTail(_ tail: ArraySlice<AnnotatedNode>,
                        _ location: TextLocation,
                        _ isEndLocation: Bool) -> (TextLocation, modified: Bool)?
        {
            // if the tail is opaque somewhere, so needs repair
            if let index = tail.firstIndex(where: { $0.node.isOpaque }) {
                assert(index > 0) // we never repair offset to the root
                let path = Array(location.path[0 ..< index - 1])
                guard var offset = location.path[index - 1].nodeIndex()
                else { return nil }
                if isEndLocation { offset += 1 }
                return (TextLocation(path, offset), modified: true)
            }
            // ASSERT: tail is unmodified
            // if offset are valid
            else if validateOffset(location.offset, tail.last!.node) {
                return (location, modified: false)
            }
            // ASSERT: offset are invalid
            else {
                return nil
            }
        }

        let lhs = range.location.path
        let rhs = range.endLocation.path
        let minCount = min(lhs.count, rhs.count)

        // arg min { lhs[i] ≠ rhs[i] | i ∈ [0, n) } where n = min(lhs.count, rhs.count)
        if let branchIndex = (0 ..< minCount).first(where: { lhs[$0] != rhs[$0] }) {
            // trace nodes along path
            guard let lhs = traceNodes(along: lhs, subtree),
                  let rhs = traceNodes(along: rhs, subtree)
            else { return nil }
            assert(lhs[branchIndex].node === rhs[branchIndex].node)
            assert(lhs[branchIndex].index != rhs[branchIndex].index)
            guard let (location, modified) = repairTail(lhs[(branchIndex + 1)...],
                                                        range.location, false),
                let (end, endModified) = repairTail(rhs[(branchIndex + 1)...],
                                                    range.endLocation, true)
            else { return nil }
            if !modified, !endModified {
                return (range, modified: false)
            }
            else if let range = RhTextRange(location: location, end: end) {
                return (range, modified: true)
            }
            else {
                return nil
            }
        }
        // ASSERT: lhs[0,minCount) == rhs[0,minCount)
        else if lhs.count != rhs.count {
            // trace nodes along path
            guard let lhs = traceNodes(along: lhs, subtree),
                  let rhs = traceNodes(along: rhs, subtree)
            else { return nil }
            // try to repair the part after minCount
            if lhs.count < rhs.count {
                guard validateOffset(range.location.offset, lhs.last!.node),
                      let (end, modified) = repairTail(rhs[(minCount + 1)...],
                                                       range.endLocation, true)
                else { return nil }
                if !modified {
                    return (range, modified: false)
                }
                else if let range = RhTextRange(location: range.location,
                                                end: end)
                {
                    return (range, modified: true)
                }
                else {
                    return nil
                }
            }
            // ASSERT: lhs.count > rhs.count
            else {
                guard validateOffset(range.endLocation.offset, rhs.last!.node),
                      let (location, modified) = repairTail(lhs[(minCount + 1)...],
                                                            range.location, false)
                else { return nil }
                if !modified {
                    return (range, modified: false)
                }
                else if let range = RhTextRange(location: location,
                                                end: range.endLocation)
                {
                    return (range, modified: true)
                }
                else {
                    return nil
                }
            }
        }
        // ASSERT: lhs.count == rhs.count
        else {
            // trace nodes along path
            guard let traces = traceNodes(along: lhs, subtree) else { return nil }
            // validate the part after minCount
            if validateOffset(range.location.offset, traces.last!.node),
               validateOffset(range.endLocation.offset, traces.last!.node)
            {
                return (range, modified: false)
            }
            else {
                return nil
            }
        }
    }

    /**
     Given a range and a subtree, returns true if the range is valid for selection
     in the subtree.

     - Important: A _valid range for selection_ is a pair of insertion points that
     don't meet any opaque nodes after branching.
     */
    static func validateTextRange(_ range: RhTextRange, _ subtree: Node) -> Bool {
        // validate path tail after branch index
        func validateTail(_ tail: ArraySlice<AnnotatedNode>, _ offset: Int) -> Bool {
            // check all nodes after branch index are non-opaque
            guard tail.allSatisfy({ !$0.node.isOpaque }) else { return false }
            // check offset are valid
            return validateOffset(offset, tail.last!.node)
        }

        let lhs = range.location.path
        let rhs = range.endLocation.path
        let minCount = min(lhs.count, rhs.count)

        // arg min { lhs[i] ≠ rhs[i] | i ∈ [0, n) } where n = min(lhs.count, rhs.count)
        if let branchIndex = (0 ..< minCount).first(where: { lhs[$0] != rhs[$0] }) {
            // ASSERT: lhs[0,branchIndex) == rhs[0,branchIndex)
            // trace nodes along path
            guard let lhs = traceNodes(along: lhs, subtree),
                  let rhs = traceNodes(along: rhs, subtree)
            else { return false }
            assert(lhs[branchIndex].node === rhs[branchIndex].node)
            assert(lhs[branchIndex].index != rhs[branchIndex].index)
            // validate the part after branch index
            return validateTail(lhs[(branchIndex + 1)...], range.location.offset) &&
                validateTail(rhs[(branchIndex + 1)...], range.endLocation.offset)
        }
        // ASSERT: lhs[0,minCount) == rhs[0,minCount)
        else if lhs.count != rhs.count {
            // trace nodes along path
            guard let lhs = traceNodes(along: lhs, subtree),
                  let rhs = traceNodes(along: rhs, subtree)
            else { return false }
            // validate the part after minCount
            if lhs.count < rhs.count {
                return validateOffset(range.location.offset, lhs.last!.node) &&
                    validateTail(rhs[(minCount + 1)...], range.endLocation.offset)
            }
            // ASSERT: lhs.count > rhs.count
            else {
                return validateTail(lhs[(minCount + 1)...], range.location.offset) &&
                    validateOffset(range.endLocation.offset, rhs.last!.node)
            }
        }
        // ASSERT: lhs.count == rhs.count
        else {
            // trace nodes along path
            guard let traces = traceNodes(along: lhs, subtree) else { return false }
            // validate the part after minCount
            return validateOffset(range.location.offset, traces.last!.node) &&
                validateOffset(range.endLocation.offset, traces.last!.node)
        }
    }

    /**
     Returns true if location is a valid insertion point for the subtree.

     - Important: A _valid insertion point_ is a location that points into a
     text node or an element node.
     */
    static func validateTextLocation(_ location: TextLocation,
                                     _ subtree: Node) -> Bool
    {
        guard let traces = NodeUtils.traceNodes(along: location.path, subtree)
        else { return false }
        return validateOffset(location.offset, traces.last!.node)
    }

    /** Returns true if the offset is valid for the node. */
    static func validateOffset(_ offset: Int, _ node: Node) -> Bool {
        switch node {
        case let textNode as TextNode:
            return (0 ... textNode.characterCount) ~= offset
        case let elementNode as ElementNode:
            return (0 ... elementNode.childCount) ~= offset
        default:
            return false
        }
    }
}
