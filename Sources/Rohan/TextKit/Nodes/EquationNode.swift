// Copyright 2024-2025 Lie Yan

import AppKit

public final class EquationNode: MathNode {
    override class var nodeType: NodeType { .equation }

    override func _onContentChange(delta: Summary, inContentStorage: Bool) {
        // change to layoutLength is not propagated further
        let delta = delta.with(layoutLength: 0)
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

    private var _mathListLayoutFragment: MathListLayoutFragment? = nil

    override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
        let mathContext = MathUtils.resolveMathContext(for: nucleus, context.styleSheet)

        if fromScratch {
            _mathListLayoutFragment = MathListLayoutFragment()

            // layout for nucleus
            let nucleusContext = MathListLayoutContext(context.styleSheet,
                                                       mathContext,
                                                       _mathListLayoutFragment!)
            nucleusContext.beginEditing()
            nucleus.performLayout(nucleusContext, fromScratch: true)
            nucleusContext.endEditing()

            context.insertFragment(nucleusContext.mathListLayoutFragment, nucleus)
        }
        else {
            assert(_mathListLayoutFragment != nil)

            // layout for nucleus
            let nucleusContext = MathListLayoutContext(context.styleSheet,
                                                       mathContext,
                                                       _mathListLayoutFragment!)
            nucleusContext.beginEditing()
            nucleus.performLayout(nucleusContext, fromScratch: false)
            nucleusContext.endEditing()

            // invalidate
            context.invalidateBackwards(layoutLength)
        }
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

    override public func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
        func applyNodeRule(_ properties: inout PropertyDictionary,
                           _ styleSheet: StyleSheet)
        {
            let key = MathProperty.style
            guard properties[key] == nil else { return }
            // determine math style
            properties[key] = .mathStyle(isBlock ? .display : .text)
        }

        if _cachedProperties == nil {
            var properties = super.getProperties(styleSheet)
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

    override final var length: Int {
        nucleus.length + Self.startPadding.intValue + Self.endPadding.intValue
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
