// Copyright 2024-2025 Lie Yan

public final class RootNode: ElementNode {
    override class var nodeType: NodeType { .root }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(root: self, context)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override class var startPadding: Bool { false }
    override class var endPadding: Bool { false }
}

public final class ContentNode: ElementNode {
    override class var nodeType: NodeType { .content }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(content: self, context)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override class var startPadding: Bool { false }
    override class var endPadding: Bool { false }
}

public final class ParagraphNode: ElementNode {
    override class var nodeType: NodeType { .paragraph }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(paragraph: self, context)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override class var startPadding: Bool { false }
    override class var endPadding: Bool { true }
}

public final class HeadingNode: ElementNode {
    override class var nodeType: NodeType { .heading }

    public let level: Int

    public init(level: Int, _ children: [Node]) {
        precondition(Heading.validate(level: level))
        self.level = level
        super.init(children)
    }

    internal init(deepCopyOf headingNode: HeadingNode) {
        self.level = headingNode.level
        super.init(deepCopyOf: headingNode)
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(heading: self, context)
    }

    override public func selector() -> TargetSelector {
        HeadingNode.selector(level: level)
    }

    public static func selector(level: Int? = nil) -> TargetSelector {
        precondition(level == nil || Heading.validate(level: level!))

        return level != nil
            ? TargetSelector(.heading, PropertyMatcher(.level, .integer(level!)))
            : TargetSelector(.heading)
    }
}

public final class EmphasisNode: ElementNode {
    override class var nodeType: NodeType { .emphasis }

    override public func getProperties(
        with styleSheet: StyleSheet
    ) -> PropertyDictionary {
        func invert(fontStyle: FontStyle) -> FontStyle {
            switch fontStyle {
            case .normal: return .italic
            case .italic: return .normal
            }
        }

        func applyNodeRule(_ properties: inout PropertyDictionary,
                           _ styleSheet: StyleSheet)
        {
            let key = TextProperty.style
            let value = key.resolve(properties, styleSheet.defaultProperties).fontStyle()!
            // invert
            properties[key] = .fontStyle(invert(fontStyle: value))
        }

        if _cachedProperties == nil {
            var properties = super.getProperties(with: styleSheet)
            applyNodeRule(&properties, styleSheet)
            _cachedProperties = properties
        }
        return _cachedProperties!
    }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}

public final class TextModeNode: ElementNode {
    override class var nodeType: NodeType { .textMode }

    override public func deepCopy() -> Self { Self(deepCopyOf: self) }

    override func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(textMode: self, context)
    }
}
