// Copyright 2024 Lie Yan

import Foundation

enum ExpressionUtils {
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

    static func applyPlugins<P0: ExpressionPlugin, P1: ExpressionPlugin>(
        _ p0: P0,
        _ p1: P1,
        _ content: Content
    ) -> (P0, P1) {
        let ps = applyPlugin(composePlugins(p0, p1), content)
        return (ps.p0, ps.p1)
    }

    static func applyPlugins<P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin>(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ content: Content
    ) -> (P0, P1, P2) {
        let ps = applyPlugin(composePlugins(p0, p1, p2), content)
        return (ps.p0, ps.p1.p0, ps.p1.p1)
    }

    private static func composePlugins<P0: ExpressionPlugin, P1: ExpressionPlugin>(
        _ p0: P0,
        _ p1: P1
    ) -> ComposedPlugin<P0, P1> {
        ComposedPlugin(p0, p1)
    }

    private static func composePlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2
    ) -> ComposedPlugin<P0, ComposedPlugin<P1, P2>> {
        composePlugins(p0, composePlugins(p1, p2))
    }
}
