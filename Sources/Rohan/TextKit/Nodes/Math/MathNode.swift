// Copyright 2024-2025 Lie Yan

public class MathNode: Node {
    // MARK: - Content

    override final var extrinsicLength: Int { 1 }

    override final func contentDidChange(delta: LengthSummary, inContentStorage: Bool) {
        // change of extrinsic and layout lengths is not propagated
        let delta = delta
            .with(extrinsicLength: 0)
            .with(layoutLength: 0)

        // propagate to parent
        parent?.contentDidChange(delta: delta, inContentStorage: inContentStorage)
    }

    // MARK: - Content

    override final func getChild(_ index: RohanIndex) -> Node? {
        guard let index = index.mathIndex() else { return nil }
        return enumerateComponents().first { $0.index == index }?.content
    }

    @usableFromInline
    typealias Component = (index: MathIndex, content: ContentNode)

    /** Returns an __ordered list__ of the node's components. */
    @inlinable
    internal func enumerateComponents() -> [Component] {
        preconditionFailure("overriding required")
    }

    // MARK: - Layout

    override final var layoutLength: Int { 1 }
}
