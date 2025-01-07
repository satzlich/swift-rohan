// Copyright 2024-2025 Lie Yan

import Foundation

final class TextNode: Node {
    private var string: VersionedValue<String>

    init(_ string: String, _ version: VersionId = .defaultInitial) {
        self.string = .init(string, version)
        super.init(version)
    }

    override func localChanged(_ version: VersionId) -> Bool {
        string.isChanged(version)
    }

    override class var type: NodeType {
        .text
    }

    override func synopsis(_ version: VersionId) -> String {
        string.get(version)
    }
}

class ElementNode: Node {
    private(set) var children: VersionedArray<Node>

    init(_ children: [Node], _ version: VersionId = .defaultInitial) {
        self.children = VersionedArray(children, version)
        super.init(version)

        for i in 0 ..< children.count {
            children[i]._parent = self
        }
    }

    func getChild(_ i: Int) -> Node {
        children.at(i)
    }

    func insertChild(_ node: Node, at i: Int) {
        children.insert(node, at: i)
    }

    func removeChild(at i: Int) {
        children.remove(at: i)
    }

    func removeSubrange(_ range: Range<Int>) {
        children.removeSubrange(range)
    }

    override func _alterVersion(_ target: VersionId) {
        super._alterVersion(target)
        children.alterVersion(target: target)
    }

    override func dropVersions(through target: VersionId) {
        if maxVersion <= target { return }

        super.dropVersions(through: target)
        children.dropVersions(through: target)
        for i in 0 ..< children.count() {
            children.at(i).dropVersions(through: target)
        }
    }

    override func synopsis(_ version: VersionId) -> String {
        var strings: [String] = []
        for i in 0 ..< children.count(version) {
            strings.append(children.at(i, version).synopsis(version))
        }
        return strings.joined(separator: "|")
    }
}

final class ParagraphNode: ElementNode {
    override class var type: NodeType {
        .paragraph
    }
}

final class HeadingNode: ElementNode {
    private var level: Int

    init(level: Int, _ children: [Node], _ version: VersionId = .defaultInitial) {
        self.level = level
        super.init(children, version)
    }

    func getLevel() -> Int {
        level
    }

    override class var type: NodeType {
        .heading
    }
}

final class EmphasisNode: ElementNode {
    override class var type: NodeType {
        .emphasis
    }
}

final class ContentNode: ElementNode {
    override class var type: NodeType {
        .content
    }
}

final class EquationNode: Node {
    private var _isBlock: Bool
    private var nucleus: ContentNode

    init(isBlock: Bool,
         nucleus: ContentNode,
         _ version: VersionId = .defaultInitial)
    {
        self._isBlock = isBlock
        self.nucleus = nucleus
        super.init(version)

        nucleus._parent = self
    }

    func isBlock() -> Bool {
        _isBlock
    }

    override func dropVersions(through target: VersionId) {
        if maxVersion <= target { return }

        super.dropVersions(through: target)
        nucleus.dropVersions(through: target)
    }

    override class var type: NodeType {
        .equation
    }

    override func synopsis(_ version: VersionId) -> String {
        nucleus.synopsis(version)
    }
}
