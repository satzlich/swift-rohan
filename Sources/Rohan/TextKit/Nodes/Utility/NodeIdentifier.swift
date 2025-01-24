// Copyright 2024-2025 Lie Yan

@DebugDescription
struct NodeIdentifier: Equatable, Hashable {
    @usableFromInline static var _counter: Int = 1
    @usableFromInline let _id: Int

    @inlinable
    init() {
        self._id = NodeIdentifier._counter
        NodeIdentifier._counter += 1
    }
}
