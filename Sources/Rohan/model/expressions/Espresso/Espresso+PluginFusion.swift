// Copyright 2024 Lie Yan

import Foundation

extension Espresso {
    struct PluginFusion<P, Q>: VisitorPlugin
    where P: VisitorPlugin, Q: VisitorPlugin, P.Context == Q.Context {
        typealias Context = P.Context

        private(set) var plugins: (P, Q)

        init(_ p: P, _ q: Q) {
            self.plugins = (p, q)
        }

        mutating func visitExpression(_ expression: Expression, _ context: Context) {
            plugins.0.visitExpression(expression, context)
            plugins.1.visitExpression(expression, context)
        }
    }

    typealias PluginFusion2<P0, P1> = PluginFusion<P0, P1>
        where P0: VisitorPlugin,
        P1: VisitorPlugin

    typealias PluginFusion3<P0, P1, P2> = PluginFusion<P0, PluginFusion2<P1, P2>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin

    typealias PluginFusion4<P0, P1, P2, P3> = PluginFusion<P0, PluginFusion3<P1, P2, P3>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin

    typealias PluginFusion5<P0, P1, P2, P3, P4> = PluginFusion<P0, PluginFusion4<P1, P2, P3, P4>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin

    typealias PluginFusion6<P0, P1, P2, P3, P4, P5> = PluginFusion<P0, PluginFusion5<P1, P2, P3, P4, P5>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin

    typealias PluginFusion7<P0, P1, P2, P3, P4, P5, P6> = PluginFusion<P0, PluginFusion6<P1, P2, P3, P4, P5, P6>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin

    typealias PluginFusion8<P0, P1, P2, P3, P4, P5, P6, P7> = PluginFusion<
        P0,
        PluginFusion7<P1, P2, P3, P4, P5, P6, P7>
    >
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin

    typealias PluginFusion9<P0, P1, P2, P3, P4, P5, P6, P7, P8> = PluginFusion<
        P0,
        PluginFusion8<P1, P2, P3, P4, P5, P6, P7, P8>
    >
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin,
        P8: VisitorPlugin

    typealias PluginFusion10<P0, P1, P2, P3, P4, P5, P6, P7, P8, P9> = PluginFusion<
        P0,
        PluginFusion9<P1, P2, P3, P4, P5, P6, P7, P8, P9>
    >
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin,
        P8: VisitorPlugin,
        P9: VisitorPlugin

    // MARK: - Utility

    static func fusePlugins<P0, P1>(
        _ p0: P0, _ p1: P1
    ) -> PluginFusion2<P0, P1>
        where P0: VisitorPlugin,
        P1: VisitorPlugin
    {
        PluginFusion(p0, p1)
    }

    static func fusePlugins<P0, P1, P2>(
        _ p0: P0, _ p1: P1, _ p2: P2
    ) -> PluginFusion3<P0, P1, P2>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin
    {
        PluginFusion3(p0, fusePlugins(p1, p2))
    }

    static func fusePlugins<P0, P1, P2, P3>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3
    ) -> PluginFusion4<P0, P1, P2, P3>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin
    {
        PluginFusion4(p0, fusePlugins(p1, p2, p3))
    }

    static func fusePlugins<P0, P1, P2, P3, P4>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4
    ) -> PluginFusion5<P0, P1, P2, P3, P4>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin
    {
        PluginFusion5(p0, fusePlugins(p1, p2, p3, p4))
    }

    static func fusePlugins<P0, P1, P2, P3, P4, P5>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5
    ) -> PluginFusion6<P0, P1, P2, P3, P4, P5>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin
    {
        PluginFusion6(p0, fusePlugins(p1, p2, p3, p4, p5))
    }

    static func fusePlugins<P0, P1, P2, P3, P4, P5, P6>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6
    ) -> PluginFusion7<P0, P1, P2, P3, P4, P5, P6>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin
    {
        PluginFusion7(p0, fusePlugins(p1, p2, p3, p4, p5, p6))
    }

    static func fusePlugins<P0, P1, P2, P3, P4, P5, P6, P7>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6, _ p7: P7
    ) -> PluginFusion8<P0, P1, P2, P3, P4, P5, P6, P7>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin
    {
        PluginFusion8(p0, fusePlugins(p1, p2, p3, p4, p5, p6, p7))
    }

    static func fusePlugins<P0, P1, P2, P3, P4, P5, P6, P7, P8>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6, _ p7: P7, _ p8: P8
    ) -> PluginFusion9<P0, P1, P2, P3, P4, P5, P6, P7, P8>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin,
        P8: VisitorPlugin
    {
        PluginFusion9(p0, fusePlugins(p1, p2, p3, p4, p5, p6, p7, p8))
    }

    static func fusePlugins<P0, P1, P2, P3, P4, P5, P6, P7, P8, P9>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5, _ p6: P6, _ p7: P7, _ p8: P8, _ p9: P9
    ) -> PluginFusion10<P0, P1, P2, P3, P4, P5, P6, P7, P8, P9>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin,
        P8: VisitorPlugin,
        P9: VisitorPlugin
    {
        PluginFusion10(p0, fusePlugins(p1, p2, p3, p4, p5, p6, p7, p8, p9))
    }

    static func unfusePlugins<P0, P1>(
        _ fusion: PluginFusion<P0, P1>
    ) -> (P0, P1)
        where P0: VisitorPlugin,
        P1: VisitorPlugin
    {
        fusion.plugins
    }

    static func unfusePlugins<P0, P1, P2>(
        _ fusion: PluginFusion3<P0, P1, P2>
    ) -> (P0, P1, P2)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }

    static func unfusePlugins<P0, P1, P2, P3>(
        _ fusion: PluginFusion4<P0, P1, P2, P3>
    ) -> (P0, P1, P2, P3)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }

    static func unfusePlugins<P0, P1, P2, P3, P4>(
        _ fusion: PluginFusion5<P0, P1, P2, P3, P4>
    ) -> (P0, P1, P2, P3, P4)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }

    static func unfusePlugins<P0, P1, P2, P3, P4, P5>(
        _ fusion: PluginFusion6<P0, P1, P2, P3, P4, P5>
    ) -> (P0, P1, P2, P3, P4, P5)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }

    static func unfusePlugins<P0, P1, P2, P3, P4, P5, P6>(
        _ fusion: PluginFusion7<P0, P1, P2, P3, P4, P5, P6>
    ) -> (P0, P1, P2, P3, P4, P5, P6)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }

    static func unfusePlugins<P0, P1, P2, P3, P4, P5, P6, P7>(
        _ fusion: PluginFusion8<P0, P1, P2, P3, P4, P5, P6, P7>
    ) -> (P0, P1, P2, P3, P4, P5, P6, P7)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }

    static func unfusePlugins<P0, P1, P2, P3, P4, P5, P6, P7, P8>(
        _ fusion: PluginFusion9<P0, P1, P2, P3, P4, P5, P6, P7, P8>
    ) -> (P0, P1, P2, P3, P4, P5, P6, P7, P8)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin,
        P8: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }

    static func unfusePlugins<P0, P1, P2, P3, P4, P5, P6, P7, P8, P9>(
        _ fusion: PluginFusion10<P0, P1, P2, P3, P4, P5, P6, P7, P8, P9>
    ) -> (P0, P1, P2, P3, P4, P5, P6, P7, P8, P9)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P6: VisitorPlugin,
        P7: VisitorPlugin,
        P8: VisitorPlugin,
        P9: VisitorPlugin
    {
        Meta.foldr(fusion.plugins.0, unfusePlugins(fusion.plugins.1))
    }
}
