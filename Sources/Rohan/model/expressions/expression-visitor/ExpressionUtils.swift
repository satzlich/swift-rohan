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
        let ps = applyPlugin(fusePlugins(p0, p1), content)
        return (ps.p0, ps.p1)
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
        let ps = applyPlugin(fusePlugins(p0, p1, p2), content)
        return (ps.p0, ps.p1.p0, ps.p1.p1)
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
        let ps = applyPlugin(fusePlugins(p0, p1, p2, p3), content)
        return (ps.p0, ps.p1.p0, ps.p1.p1.p0, ps.p1.p1.p1)
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
        let ps = applyPlugin(fusePlugins(p0, p1, p2, p3, p4), content)
        return (ps.p0, ps.p1.p0, ps.p1.p1.p0, ps.p1.p1.p1.p0, ps.p1.p1.p1.p1)
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
        let ps = applyPlugin(fusePlugins(p0, p1, p2, p3, p4, p5), content)
        return (ps.p0, ps.p1.p0, ps.p1.p1.p0, ps.p1.p1.p1.p0, ps.p1.p1.p1.p1.p0, ps.p1.p1.p1.p1.p1)
    }

    private static func fusePlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1
    ) -> FusedPlugin2<P0, P1> {
        FusedPlugin2(p0, p1)
    }

    private static func fusePlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2
    ) -> FusedPlugin3<P0, P1, P2> {
        fusePlugins(p0, fusePlugins(p1, p2))
    }

    private static func fusePlugins<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin,
        P3: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2,
        _ p3: P3
    ) -> FusedPlugin4<P0, P1, P2, P3> {
        fusePlugins(
            p0,
            fusePlugins(p1, p2, p3)
        )
    }

    private static func fusePlugins<
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
        _ p4: P4
    ) -> FusedPlugin5<P0, P1, P2, P3, P4> {
        fusePlugins(
            p0,
            fusePlugins(p1, p2, p3, p4)
        )
    }

    private static func fusePlugins<
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
        _ p5: P5
    ) -> FusedPlugin6<P0, P1, P2, P3, P4, P5> {
        fusePlugins(
            p0,
            fusePlugins(p1, p2, p3, p4, p5)
        )
    }
}
