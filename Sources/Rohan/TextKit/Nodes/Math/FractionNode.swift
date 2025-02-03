// Copyright 2024-2025 Lie Yan

import Foundation

/** Generalized fraction */
public final class FractionNode: MathNode {
    override class var nodeType: NodeType { .fraction }

    init(_ numerator: [Node], _ denominator: [Node], isBinomial: Bool = false) {
        self.isBinomial = isBinomial
        self._numerator = NumeratorNode(numerator)
        self._denominator = DenominatorNode(denominator)
        super.init()
        _numerator.parent = self
        _denominator.parent = self
    }

    init(deepCopyOf fractionNode: FractionNode) {
        self.isBinomial = fractionNode.isBinomial
        self._numerator = fractionNode._numerator.deepCopy()
        self._denominator = fractionNode._denominator.deepCopy()
        super.init()
        _numerator.parent = self
        _denominator.parent = self
    }

    // MARK: - Layout

    override var isBlock: Bool { false }
    override var isDirty: Bool { _numerator.isDirty || _denominator.isDirty }

    private var _fractionFragment: MathFractionLayoutFragment? = nil

    override func performLayout(_ context: any LayoutContext, fromScratch: Bool) {
        precondition(context is MathListLayoutContext)
        let context = context as! MathListLayoutContext

        func doLayout() {
            assert(_fractionFragment != nil)
            // numerator
            if fromScratch || numerator.isDirty {
                let numeratorStyle = _numerator
                    .resolveProperty(MathProperty.style, context.styleSheet)
                    .mathStyle()!
                let numeratorContext = MathListLayoutContext(
                    context.styleSheet,
                    context.mathContext.with(mathStyle: numeratorStyle),
                    _fractionFragment!.numerator
                )
                numeratorContext.beginEditing()
                _numerator.performLayout(numeratorContext, fromScratch: fromScratch)
                numeratorContext.endEditing()
            }
            // denominator
            if fromScratch || denominator.isDirty {
                let denominatorStyle = _denominator
                    .resolveProperty(MathProperty.style, context.styleSheet)
                    .mathStyle()!
                let denominatorContext = MathListLayoutContext(
                    context.styleSheet,
                    context.mathContext.with(mathStyle: denominatorStyle),
                    _fractionFragment!.denominator
                )
                denominatorContext.beginEditing()
                _denominator.performLayout(denominatorContext, fromScratch: fromScratch)
                denominatorContext.endEditing()
            }
            // fix layout
            _fractionFragment!.fixLayout(context.mathContext)
        }

        if fromScratch {
            let numeratorFragment = MathListLayoutFragment()
            let denominatorFragment = MathListLayoutFragment()
            _fractionFragment = MathFractionLayoutFragment(numeratorFragment,
                                                           denominatorFragment,
                                                           isBinomial)
            doLayout()
            context.insertFragment(_fractionFragment!, self)
        }
        else {
            doLayout()
            context.invalidateBackwards(layoutLength)
        }
    }

    // MARK: - Components

    public let isBinomial: Bool

    fileprivate let _numerator: NumeratorNode
    fileprivate let _denominator: DenominatorNode

    public var numerator: ContentNode { @inline(__always) get { _numerator } }
    public var denominator: ContentNode { @inline(__always) get { _denominator } }

    override func enumerateComponents() -> [MathNode.Component] {
        [
            (MathIndex.numerator, _numerator),
            (MathIndex.denominator, _denominator),
        ]
    }

    // MARK: - Clone and Visitor

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(fraction: self, context)
    }
}

private final class NumeratorNode: ContentNode {
    override func deepCopy() -> NumeratorNode { NumeratorNode(deepCopyOf: self) }

    override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
        func applyNodeRule(_ properties: inout PropertyDictionary,
                           _ styleSheet: StyleSheet)
        {
            let key = MathProperty.style
            let value = resolveProperty(key, styleSheet).mathStyle()!
            // set math style ← fraction style
            properties[key] = .mathStyle(MathUtils.fractionStyle(for: value))
        }

        if _cachedProperties == nil {
            var properties = super.getProperties(styleSheet)
            applyNodeRule(&properties, styleSheet)
            _cachedProperties = properties
        }
        return _cachedProperties!
    }
}

private final class DenominatorNode: ContentNode {
    override func deepCopy() -> DenominatorNode { DenominatorNode(deepCopyOf: self) }

    override func getProperties(_ styleSheet: StyleSheet) -> PropertyDictionary {
        func applyNodeRule(_ properties: inout PropertyDictionary,
                           _ styleSheet: StyleSheet)
        {
            let key = MathProperty.style
            let value = resolveProperty(key, styleSheet).mathStyle()!
            // set math style ← fraction style
            properties[key] = .mathStyle(MathUtils.fractionStyle(for: value))
            // set cramped ← true
            properties[MathProperty.cramped] = .bool(true)
        }

        if _cachedProperties == nil {
            var properties = super.getProperties(styleSheet)
            applyNodeRule(&properties, styleSheet)
            _cachedProperties = properties
        }
        return _cachedProperties!
    }
}
