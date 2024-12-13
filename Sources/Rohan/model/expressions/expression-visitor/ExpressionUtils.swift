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

    static func applyPlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ content: Content
    ) -> (P0, P1) {
        PluginUtils.unfuse(
            applyPlugin(PluginUtils.fuse(p0, p1), content)
        )
    }

    static func applyPlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ content: Content
    ) -> (P0, P1, P2) {
        PluginUtils.unfuse(
            applyPlugin(PluginUtils.fuse(p0, p1, p2), content)
        )
    }

    static func applyPlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin,
        P3: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ content: Content
    ) -> (P0, P1, P2, P3) {
        PluginUtils.unfuse(
            applyPlugin(PluginUtils.fuse(p0, p1, p2, p3), content)
        )
    }

    static func applyPlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin,
        P3: ExpressionPlugin,
        P4: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ p4: P4,
        _ content: Content
    ) -> (P0, P1, P2, P3, P4) {
        PluginUtils.unfuse(
            applyPlugin(PluginUtils.fuse(p0, p1, p2, p3, p4), content)
        )
    }

    static func applyPlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin,
        P3: ExpressionPlugin,
        P4: ExpressionPlugin,
        P5: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3,
        _ p4: P4,
        _ p5: P5,
        _ content: Content
    ) -> (P0, P1, P2, P3, P4, P5) {
        PluginUtils.unfuse(
            applyPlugin(PluginUtils.fuse(p0, p1, p2, p3, p4, p5), content)
        )
    }
}
