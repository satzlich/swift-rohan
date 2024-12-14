// Copyright 2024 Lie Yan

import Foundation

extension Espresso {
    struct PluginFusion<P, Q>: VisitorPlugin
        where P: VisitorPlugin,
        Q: VisitorPlugin,
        P.Context == Q.Context
    {
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
        P1: VisitorPlugin,
        P0.Context == P1.Context

    typealias PluginFusion3<P0, P1, P2> = PluginFusion<P0, PluginFusion2<P1, P2>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context

    typealias PluginFusion4<P0, P1, P2, P3> = PluginFusion<P0, PluginFusion3<P1, P2, P3>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context

    typealias PluginFusion5<P0, P1, P2, P3, P4> = PluginFusion<P0, PluginFusion4<P1, P2, P3, P4>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context,
        P0.Context == P4.Context

    typealias PluginFusion6<P0, P1, P2, P3, P4, P5> = PluginFusion<P0, PluginFusion5<P1, P2, P3, P4, P5>>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context,
        P0.Context == P4.Context,
        P0.Context == P5.Context

    // MARK: - Utility

    static func composeFusion<P0, P1>(
        _ p0: P0, _ p1: P1
    ) -> PluginFusion2<P0, P1>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P0.Context == P1.Context
    {
        PluginFusion(p0, p1)
    }

    static func composeFusion<P0, P1, P2>(
        _ p0: P0, _ p1: P1, _ p2: P2
    ) -> PluginFusion3<P0, P1, P2>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context
    {
        PluginFusion3(p0, composeFusion(p1, p2))
    }

    static func composeFusion<P0, P1, P2, P3>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3
    ) -> PluginFusion4<P0, P1, P2, P3>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context
    {
        PluginFusion4(p0, composeFusion(p1, p2, p3))
    }

    static func composeFusion<P0, P1, P2, P3, P4>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4
    ) -> PluginFusion5<P0, P1, P2, P3, P4>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context,
        P0.Context == P4.Context
    {
        PluginFusion5(p0, composeFusion(p1, p2, p3, p4))
    }

    static func composeFusion<P0, P1, P2, P3, P4, P5>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5
    ) -> PluginFusion6<P0, P1, P2, P3, P4, P5>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context,
        P0.Context == P4.Context,
        P0.Context == P5.Context
    {
        PluginFusion6(p0, composeFusion(p1, p2, p3, p4, p5))
    }

    static func decomposeFusion<P0, P1>(
        _ fusion: PluginFusion<P0, P1>
    ) -> (P0, P1)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P0.Context == P1.Context
    {
        fusion.plugins
    }

    static func decomposeFusion<P0, P1, P2>(
        _ fusion: PluginFusion3<P0, P1, P2>
    ) -> (P0, P1, P2)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context
    {
        Meta.foldr(fusion.plugins.0, decomposeFusion(fusion.plugins.1))
    }

    static func decomposeFusion<P0, P1, P2, P3>(
        _ fusion: PluginFusion4<P0, P1, P2, P3>
    ) -> (P0, P1, P2, P3)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context
    {
        Meta.foldr(fusion.plugins.0, decomposeFusion(fusion.plugins.1))
    }

    static func decomposeFusion<P0, P1, P2, P3, P4>(
        _ fusion: PluginFusion5<P0, P1, P2, P3, P4>
    ) -> (P0, P1, P2, P3, P4)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context,
        P0.Context == P4.Context
    {
        Meta.foldr(fusion.plugins.0, decomposeFusion(fusion.plugins.1))
    }

    static func decomposeFusion<P0, P1, P2, P3, P4, P5>(
        _ fusion: PluginFusion6<P0, P1, P2, P3, P4, P5>
    ) -> (P0, P1, P2, P3, P4, P5)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin,
        P0.Context == P1.Context,
        P0.Context == P2.Context,
        P0.Context == P3.Context,
        P0.Context == P4.Context,
        P0.Context == P5.Context
    {
        Meta.foldr(fusion.plugins.0, decomposeFusion(fusion.plugins.1))
    }
}
