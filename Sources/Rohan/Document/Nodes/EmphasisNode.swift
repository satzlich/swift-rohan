// Copyright 2024-2025 Lie Yan

public final class EmphasisNode: ElementNode {
    override public func clone(from version: VersionId) -> EmphasisNode {
        EmphasisNode(_cloneChildren(from: version))
    }

    override class var type: NodeType { .emphasis }

    override public func getProperties(with styleSheet: StyleSheet) -> PropertyDictionary {
        if _cachedProperties == nil {
            var properties = super.getProperties(with: styleSheet)

            // obtain effective value
            let key = TextProperty.style
            let effectiveValue = key.resolve(properties, styleSheet.defaultProperties)

            // invert font style
            assert(effectiveValue.type == .fontStyle)
            let newFontStyle = Emphasis.invert(fontStyle: effectiveValue.fontStyle()!)
            properties[key] = .fontStyle(newFontStyle)

            // update cache
            _cachedProperties = properties
        }

        return _cachedProperties!
    }

    override public func accept<R, C>(_ visitor: NodeVisitor<R, C>, _ context: C) -> R {
        visitor.visit(emphasis: self, context)
    }
}
