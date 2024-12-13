// Copyright 2024 Lie Yan

import Foundation

enum Espresso {
    static func applyVisitor<V>(_ visitor: V, _ content: Content) -> V
    where V: ExpressionVisitor<Void> {
        visitor.visitContent(content, ())
        return visitor
    }

    static func applyPlugin<P>(_ plugin: P, _ content: Content) -> P
    where P: ExpressionPlugin {
        let player = ExpressionPluginPlayer(plugin)
        player.visitContent(content, ())
        return player.plugin
    }
}
