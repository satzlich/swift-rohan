// Copyright 2024-2025 Lie Yan

public final class EquationNode: MathNode {
    override class var nodeType: NodeType { .equation }

    override func _onContentChange(delta: Summary, inContentStorage: Bool) {
        // change to nsLength is not propagated further
        let delta = delta.with(nsLength: 0)
        super._onContentChange(delta: delta, inContentStorage: inContentStorage)
    }

    public init(isBlock: Bool, nucleus: ContentNode = .init()) {
        self._isBlock = isBlock
        self.nucleus = nucleus
        super.init()
        assert(nucleus.parent == nil)
        self.nucleus.parent = self
    }

    internal init(deepCopyOf equationNode: EquationNode) {
        self._isBlock = equationNode._isBlock
        self.nucleus = equationNode.nucleus.deepCopy()
        super.init()
        // assert(nucleus.parent == nil)
        nucleus.parent = self
    }

    // MARK: - Layout

    private let _isBlock: Bool
    override public var isBlock: Bool { _isBlock }

    override var isDirty: Bool { nucleus.isDirty }

    override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
        // TODO: layout
        if fromScratch {
            context.insertText(TextNode("$"))
        }
        else {
            context.skipBackwards(nsLength)
        }
        // clear is done in children
    }

    // MARK: - Styles

    override public func selector() -> TargetSelector {
        EquationNode.selector(isBlock: _isBlock)
    }

    public static func selector(isBlock: Bool? = nil) -> TargetSelector {
        return isBlock != nil
            ? TargetSelector(.equation, PropertyMatcher(.isBlock, .bool(isBlock!)))
            : TargetSelector(.equation)
    }

    override public func getProperties(with styleSheet: StyleSheet)
    -> PropertyDictionary {
        func applyNodeRule(_ properties: inout PropertyDictionary,
                           _ styleSheet: StyleSheet)
        {
            let key = MathProperty.style
            guard properties[key] == nil else { return }
            // determine math style
            properties[key] = .mathStyle(isBlock ? .display : .text)
        }

        if _cachedProperties == nil {
            var properties = super.getProperties(with: styleSheet)
            applyNodeRule(&properties, styleSheet)
            _cachedProperties = properties
        }
        return _cachedProperties!
    }

    // MARK: - Components

    public let nucleus: ContentNode

    override final func enumerateComponents() -> [Component] {
        [(MathIndex.nucleus, nucleus)]
    }

    // MARK: - Length & Location

    override final var nsLength: Int { 1 }

    override final var length: Int {
        nucleus.length + Self.startPadding.intValue + Self.endPadding.intValue
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
