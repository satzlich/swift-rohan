// Copyright 2024-2025 Lie Yan

public class MathNode: Node {
    override final func _onContentChange(delta: Summary, inContentStorage: Bool) {
        // change to layoutLength is not propagated further
        let delta = delta.with(layoutLength: 0)
        super._onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    // MARK: - Length & Location

    override final var layoutLength: Int { 1 }

    override final var length: Int {
        let components = enumerateComponents()
        return components.lazy.map(\.content.length).reduce(0, +) +
            startPadding.intValue + endPadding.intValue + // boundary padding
            (components.count - 1) // inter padding
    }

    override final class var startPadding: Bool { true }
    override final class var endPadding: Bool { true }

    override final func getOffset(before index: RohanIndex) -> Int {
        let components = enumerateComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { fatalError("Expect math index") }
        return startPadding.intValue
            + components[..<i].lazy.map(\.content.length).reduce(0, +)
            + i // inter padding
    }

    override final func _getLocation(_ offset: Int, _ path: inout [RohanIndex]) -> Int {
        precondition(offset >= startPadding.intValue &&
            offset <= length - endPadding.intValue)

        let components = enumerateComponents()
        assert(!components.isEmpty)

        func index(_ i: Int) -> RohanIndex { .mathIndex(components[i].index) }

        // shave start padding
        let m = offset - startPadding.intValue

        var s = 0
        // invariant:
        //  s = sum { length | 0 ..< i } + inter padding
        //  s < m
        for (i, (_, node)) in components.enumerated() {
            let last = (i == components.count - 1)
            let n = s + node.length + (!last ? 1 : 0) // inter padding
            if n < m { // move on
                s = n
            }
            else if n == m, !last { // boundary
                path.append(index(i + 1))
                return components[i + 1].content._getLocation(0, &path)
            }
            else { // (n == offset && last) || n > offset
                path.append(index(i))
                return node._getLocation(m - s, &path)
            }
        }
        assertionFailure("impossible")
        return offset
    }

    // MARK: - Components

    @usableFromInline
    typealias Component = (index: MathIndex, content: ContentNode)

    /** Returns an __ordered list__ of the node's components. */
    @inlinable
    internal func enumerateComponents() -> [Component] {
        preconditionFailure("overriding required")
    }

    override final func getChild(_ index: RohanIndex) -> Node? {
        let components = enumerateComponents()
        guard let index = index.mathIndex(),
              let i = components.firstIndex(where: { $0.index == index })
        else { return nil }
        return components[i].content
    }
}
