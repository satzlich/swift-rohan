// Copyright 2024 Lie Yan

import Foundation

extension Espresso {
    static func applyPlugin<P>(_ plugin: P, _ content: Content) -> P
    where P: ExpressionPlugin {
        let player = ExpressionPluginPlayer(plugin)
        player.visitContent(content, ())
        return player.plugin
    }

    // MARK: - Utility

    static func fusePlugins<P0, P1>(_ p0: P0, _ p1: P1) -> PluginFusion<P0, P1>
    where P0: ExpressionPlugin, P1: ExpressionPlugin {
        PluginFusion(p0, p1)
    }

    static func fusePlugins<P0, P1, P2>(_ p0: P0, _ p1: P1, _ p2: P2) -> PluginFusion3<P0, P1, P2>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin {
        PluginFusion3(fusePlugins(p0, p1), p2)
    }

    static func fusePlugins<P0, P1, P2, P3>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3) -> PluginFusion4<P0, P1, P2, P3>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin {
        PluginFusion4(fusePlugins(p0, p1, p2), p3)
    }

    static func fusePlugins<P0, P1, P2, P3, P4>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4
    ) -> PluginFusion5<P0, P1, P2, P3, P4>
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin
    {
        PluginFusion5(fusePlugins(p0, p1, p2, p3), p4)
    }

    static func fusePlugins<P0, P1, P2, P3, P4, P5>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5
    ) -> PluginFusion6<P0, P1, P2, P3, P4, P5>
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin, P5: ExpressionPlugin
    {
        PluginFusion6(fusePlugins(p0, p1, p2, p3, p4), p5)
    }

    static func unfusePlugins<P0, P1>(_ p: PluginFusion<P0, P1>) -> (P0, P1)
    where P0: ExpressionPlugin, P1: ExpressionPlugin {
        p.plugins
    }

    static func unfusePlugins<P0, P1, P2>(_ p: PluginFusion3<P0, P1, P2>) -> (P0, P1, P2)
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin {
        MPL.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }

    static func unfusePlugins<P0, P1, P2, P3>(
        _ p: PluginFusion4<P0, P1, P2, P3>
    ) -> (P0, P1, P2, P3)
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin {
        MPL.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }

    static func unfusePlugins<P0, P1, P2, P3, P4>(
        _ p: PluginFusion5<P0, P1, P2, P3, P4>
    ) -> (P0, P1, P2, P3, P4)
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin
    {
        MPL.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }

    static func unfusePlugins<P0, P1, P2, P3, P4, P5>(
        _ p: PluginFusion6<P0, P1, P2, P3, P4, P5>
    ) -> (P0, P1, P2, P3, P4, P5)
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin, P5: ExpressionPlugin
    {
        MPL.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }
}
