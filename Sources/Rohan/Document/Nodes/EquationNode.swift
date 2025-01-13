// Copyright 2024-2025 Lie Yan

public final class EquationNode: Node {
    private var _isBlock: Bool
    private(set) var nucleus: ContentNode

    init(isBlock: Bool,
         nucleus: ContentNode,
         _ version: VersionId = .defaultInitial)
    {
        self._isBlock = isBlock
        self.nucleus = nucleus
        super.init(version)

        nucleus._parent = self
    }

    override public func clone(from version: VersionId) -> EquationNode {
        EquationNode(isBlock: _isBlock, nucleus: nucleus.clone(from: version))
    }

    public func isBlock() -> Bool { _isBlock }

    override public func selector() -> TargetSelector {
        Equation.selector(isBlock: _isBlock)
    }

    override public func getProperties(with styleSheet: StyleSheet) -> PropertyDictionary {
        if _cachedProperties == nil {
            var properties = super.getProperties(with: styleSheet)
            properties[RootProperty.layoutMode] = .layoutMode(.math)
            _cachedProperties = properties
        }
        return _cachedProperties!
    }

    override public func dropVersions(through target: VersionId,
                                      recursive: Bool = true)
    {
        if target >= subtreeVersion { return }

        super.dropVersions(through: target, recursive: recursive)
        if recursive {
            nucleus.dropVersions(through: target, recursive: true)
        }
    }

    override class var type: NodeType { .equation }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
