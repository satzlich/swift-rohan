// Copyright 2024-2025 Lie Yan

import AppKit

public final class EquationNode: MathNode {
    override class var nodeType: NodeType { .equation }

    public init(isBlock: Bool, _ nucleus: [Node] = []) {
        self._isBlock = isBlock
        self.nucleus = ContentNode(nucleus)
        super.init()
        self.nucleus.parent = self
    }

    internal init(deepCopyOf equationNode: EquationNode) {
        self._isBlock = equationNode._isBlock
        self.nucleus = equationNode.nucleus.deepCopy()
        super.init()
        nucleus.parent = self
    }

    // MARK: - Layout

    private let _isBlock: Bool
    override public var isBlock: Bool { _isBlock }

    override var isDirty: Bool { nucleus.isDirty }

    private var _nucleusFragment: MathListLayoutFragment? = nil

    override func performLayout(_ context: LayoutContext, fromScratch: Bool) {
        let mathContext = MathUtils.resolveMathContext(for: nucleus, context.styleSheet)

        if fromScratch {
            _nucleusFragment = MathListLayoutFragment()

            // layout for nucleus
            let nucleusContext = MathListLayoutContext(context.styleSheet,
                                                       mathContext,
                                                       _nucleusFragment!)
            nucleusContext.beginEditing()
            nucleus.performLayout(nucleusContext, fromScratch: true)
            nucleusContext.endEditing()

            // insert fragment
            context.insertFragment(nucleusContext.layoutFragment, nucleus)
        }
        else {
            assert(_nucleusFragment != nil)

            // layout for nucleus
            let nucleusContext = MathListLayoutContext(context.styleSheet,
                                                       mathContext,
                                                       _nucleusFragment!)
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

    override final func enumerateComponents() -> [MathNode.Component] {
        [(MathIndex.nucleus, nucleus)]
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(equation: self, context)
    }
}
