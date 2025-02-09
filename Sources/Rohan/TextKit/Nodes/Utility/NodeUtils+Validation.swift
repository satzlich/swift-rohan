// Copyright 2024-2025 Lie Yan

import Foundation

extension NodeUtils {
    enum RepairResult<T>: Equatable, Hashable where T: Equatable & Hashable {
        case original(T)
        case repaired(T)
        case unrepairable
    }

    /**
     Repair a selection range if it is invalid for a subtree.

     ## Semantics
     - If location and endLocation are both valid insertion points in the subtree,
     then the range is either valid or can be repaired to be valid. In the former case,
     return the original range with `modified: false`. In the latter case, return the
     repaired range with `modified: true`.
     - Otherwise, return `nil`.
     */
    static func repairTextRange(_ range: RhTextRange,
                                _ subtree: Node) -> RepairResult<RhTextRange>
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
                        _ isEndLocation: Bool) -> RepairResult<TextLocation>
        {
            // if the tail is opaque somewhere, it needs repair
            if let index = tail.firstIndex(where: { $0.node.isOpaque }) {
                assert(index > 0)
                let path = Array(location.path[0 ..< index - 1])
                guard var offset = location.path[index - 1].nodeIndex()
                else { return .unrepairable }
                if isEndLocation { offset += 1 }
                return .repaired(TextLocation(path, offset))
            }
            // ASSERT: tail is unmodified
            // if offset is valid
            else if validateOffset(location.offset, tail.last!.node) {
                return .original(location)
            }
            // ASSERT: offset is invalid
            else {
                return .unrepairable
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
            else { return .unrepairable }
            assert(lhs[branchIndex].node === rhs[branchIndex].node)
            assert(lhs[branchIndex].index != rhs[branchIndex].index)

            // try to repair the part after branch index
            let location = repairTail(lhs[(branchIndex + 1)...], range.location, false)
            let end = repairTail(rhs[(branchIndex + 1)...], range.endLocation, true)

            switch (location, end) {
            case (.unrepairable, _), (_, .unrepairable):
                return .unrepairable
            case (.original, .original):
                return .original(range)
            case let (.repaired(location), .repaired(end)),
                 let (.original(location), .repaired(end)),
                 let (.repaired(location), .original(end)):
                guard let range = RhTextRange(location: location, end: end)
                else { return .unrepairable }
                return .repaired(range)
            }
        }
        // ASSERT: lhs[0,minCount) == rhs[0,minCount)
        else if lhs.count != rhs.count {
            // trace nodes along path
            guard let lhs = traceNodes(along: lhs, subtree),
                  let rhs = traceNodes(along: rhs, subtree)
            else { return .unrepairable }
            // try to repair the part after minCount
            if lhs.count < rhs.count {
                guard validateOffset(range.location.offset, lhs.last!.node)
                else { return .unrepairable }

                switch repairTail(rhs[(minCount + 1)...], range.endLocation, true) {
                case .unrepairable:
                    return .unrepairable
                case .original:
                    return .original(range)
                case let .repaired(end):
                    guard let range = RhTextRange(location: range.location, end: end)
                    else { return .unrepairable }
                    return .repaired(range)
                }
            }
            // ASSERT: lhs.count > rhs.count
            else {
                guard validateOffset(range.endLocation.offset, rhs.last!.node)
                else { return .unrepairable }

                switch repairTail(lhs[(minCount + 1)...], range.location, false) {
                case .unrepairable:
                    return .unrepairable
                case .original:
                    return .original(range)
                case let .repaired(location):
                    guard let range = RhTextRange(location: location,
                                                  end: range.endLocation)
                    else { return .unrepairable }
                    return .repaired(range)
                }
            }
        }
        // ASSERT: lhs.count == rhs.count
        else {
            // trace nodes along path
            guard let traces = traceNodes(along: lhs, subtree)
            else { return .unrepairable }
            // validate the part after minCount
            if validateOffset(range.location.offset, traces.last!.node),
               validateOffset(range.endLocation.offset, traces.last!.node)
            {
                return .original(range)
            }
            else {
                return .unrepairable
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
    static func validateTextLocation(_ location: TextLocation, _ subtree: Node) -> Bool {
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
