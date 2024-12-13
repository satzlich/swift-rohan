// Copyright 2024 Lie Yan

import Foundation

enum ExpressionUtils {
    static func applyPlugins(_ plugins: [ExpressionVisitorPlugin<Void>],
                             _ content: Content)
    {
        let visitor = ExpressionPluginVisitor(plugins)
        _ = Self.applyVisitor(visitor, content)
    }

    static func applyVisitor<V: ExpressionVisitor<Void>>(
        _ visitor: V,
        _ content: Content
    ) -> V {
        visitor.visitContent(content, ())
        return visitor
    }
}
