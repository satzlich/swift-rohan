// Copyright 2024-2025 Lie Yan

public final class TextNode: Node {
    private var string: VersionedValue<String>

    init(_ string: String, _ version: VersionId = .defaultInitial) {
        self.string = .init(string, version)
        super.init(version)
    }

    public func getString(for version: VersionId) -> String {
        string.get(version)
    }

    public func getString() -> String { getString(for: nodeVersion) }

    override public func clone(from version: VersionId) -> TextNode {
        TextNode(getString(for: version), version)
    }

    override public func localChanged(_ version: VersionId) -> Bool {
        string.isChanged(version)
    }

    override func _advanceVersion(to target: VersionId) {
        super._advanceVersion(to: target)
        string.advanceVersion(to: target)
    }

    override public func dropVersions(through target: VersionId, recursive: Bool) {
        super.dropVersions(through: target, recursive: recursive)
        string.dropVersions(through: target)
    }

    override class var type: NodeType { .text }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(text: self, context)
    }
}
