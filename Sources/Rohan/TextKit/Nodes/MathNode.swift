// Copyright 2024-2025 Lie Yan

public class MathNode: Node {
    // MARK: - Components

    /** Returns an ordered list of the node's components. */
    internal func enumerateComponents() -> [(index: MathIndex, content: ContentNode)] {
        preconditionFailure()
    }

    /** Returns an ordered list of the node's components. */
    @inline(__always)
    internal final func getComponents() -> [ContentNode] {
        enumerateComponents().map(\.content)
    }

    // MARK: - Layout

    @inline(__always)
    override final var isDirty: Bool { getComponents().contains(where: \.isDirty) }

    // MARK: - Location and Length

    @inline(__always)
    override final var length: Int { getComponents().reduce(0) { $0 + $1.length } }

    override final func _childIndex(
        for offset: Int,
        _ affinity: SelectionAffinity
    ) -> (index: RohanIndex, offset: Int)? {
        precondition(offset >= 0 && offset <= length)

        let components = enumerateComponents()
        func index(_ i: Int) -> RohanIndex { .mathIndex(components[i].index) }

        var s = 0
        // invariant: s = sum { length | 0 ..< i }
        for (i, (_, node)) in components.enumerated() {
            let n = s + node.length
            if n < offset { // make progress
                s = n
            }
            else if n == offset,
                    affinity == .downstream,
                    i + 1 < components.count
            { // boundary
                return (index(i + 1), 0)
            }
            else { // found
                return (index(i), offset - s)
            }
        }
        assert(s == 0)
        return nil
    }

    override final func _getChild(_ index: RohanIndex) -> Node? {
        let components = enumerateComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { return nil }
        return components[i].content
    }

    override final func _length(before index: RohanIndex) -> Int {
        let components = enumerateComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { fatalError("invalid index") }
        return components[..<i].reduce(0) { $0 + $1.content.length }
    }

    // MARK: - Padded Length

    override final class var startPadding: Bool { true }
    override final class var endPadding: Bool { true }

    override final var paddedLength: Int {
        let components = getComponents()
        assert(!components.isEmpty)
        return components.reduce(0) { $0 + $1.paddedLength } + // content
            Self.startPadding.intValue + // start padding
            Self.endPadding.intValue + // end padding
            components.count - 1 // inter padding
    }

    override func _paddedLength(before index: RohanIndex) -> Int {
        let components = enumerateComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { fatalError("invalid index") }
        return components[..<i].reduce(0) { $0 + $1.content.length + 1 } // with inter padding
    }

    override final func _locate(forPadded offset: Int,
                                _ path: inout [RohanIndex]) -> Int?
    {
        precondition(offset >= Self.startPadding.intValue &&
            offset <= paddedLength - Self.endPadding.intValue)

        let components = enumerateComponents()
        func index(_ i: Int) -> RohanIndex { .mathIndex(components[i].index) }

        // shave start padding
        let offset = offset - Self.startPadding.intValue

        var s = 0
        // invariant: s = sum { padded length | 0 ..< i } + inter padding
        for (i, (_, node)) in components.enumerated() {
            let last = (i == components.count - 1)
            let n = s + node.paddedLength + (!last ? 1 : 0) // inter padding
            if n < offset { // move on
                s = n
            }
            else if n == offset, !last { // boundary
                path.append(index(i + 1))
                return components[i + 1].content._locate(forPadded: 0, &path)
            }
            else { // (n == offset && last) || n > offset
                path.append(index(i))
                return node._locate(forPadded: offset - s, &path)
            }
        }
        assertionFailure("components should not be empty")
        return nil
    }
}
