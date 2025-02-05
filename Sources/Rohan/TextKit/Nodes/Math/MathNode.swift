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

    // MARK: - Layout

    override final var layoutLength: Int { 1 }

    // MARK: - Components

    @usableFromInline
    typealias Component = (index: MathIndex, content: ContentNode)

    /** Returns an __ordered list__ of the node's components. */
    @inlinable
    internal func enumerateComponents() -> [Component] {
        preconditionFailure("overriding required")
    }
}
