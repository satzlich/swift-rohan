// Copyright 2024 Lie Yan

import Foundation

enum expresso {
    static func applyVisitor<V: ExpressionVisitor<Void>>(
        _ visitor: V,
        _ content: Content
    ) -> V {
        visitor.visitContent(content, ())
        return visitor
    }

    static func applyPlugin<P0: ExpressionPlugin>(
        _ p0: P0,
        _ content: Content
    ) -> P0 {
        let player = ExpressionPluginPlayer(p0)
        player.visitContent(content, ())
        return player.plugin
    }
}
