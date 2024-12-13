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

        mutating func visitApply(_ apply: Apply, _ context: Context) {
            plugins.0.visitApply(apply, context)
            plugins.1.visitApply(apply, context)
        }

        mutating func visitVariable(_ variable: Variable, _ context: Context) {
            plugins.0.visitVariable(variable, context)
            plugins.1.visitVariable(variable, context)
        }

        mutating func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context) {
            plugins.0.visitNamelessApply(namelessApply, context)
            plugins.1.visitNamelessApply(namelessApply, context)
        }

        mutating func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context) {
            plugins.0.visitNamelessVariable(namelessVariable, context)
            plugins.1.visitNamelessVariable(namelessVariable, context)
        }

        mutating func visitText(_ text: Text, _ context: Context) {
            plugins.0.visitText(text, context)
            plugins.1.visitText(text, context)
        }

        mutating func visitContent(_ content: Content, _ context: Context) {
            plugins.0.visitContent(content, context)
            plugins.1.visitContent(content, context)
        }

        mutating func visitEmphasis(_ emphasis: Emphasis, _ context: Context) {
            plugins.0.visitEmphasis(emphasis, context)
            plugins.1.visitEmphasis(emphasis, context)
        }

        mutating func visitHeading(_ heading: Heading, _ context: Context) {
            plugins.0.visitHeading(heading, context)
            plugins.1.visitHeading(heading, context)
        }

        mutating func visitParagraph(_ paragraph: Paragraph, _ context: Context) {
            plugins.0.visitParagraph(paragraph, context)
            plugins.1.visitParagraph(paragraph, context)
        }

        mutating func visitEquation(_ equation: Equation, _ context: Context) {
            plugins.0.visitEquation(equation, context)
            plugins.1.visitEquation(equation, context)
        }

        mutating func visitFraction(_ fraction: Fraction, _ context: Context) {
            plugins.0.visitFraction(fraction, context)
            plugins.1.visitFraction(fraction, context)
        }

        mutating func visitMatrix(_ matrix: Matrix, _ context: Context) {
            plugins.0.visitMatrix(matrix, context)
            plugins.1.visitMatrix(matrix, context)
        }

        mutating func visitScripts(_ scripts: Scripts, _ context: Context) {
            plugins.0.visitScripts(scripts, context)
            plugins.1.visitScripts(scripts, context)
        }
    }

    typealias PluginFusion2<P0, P1> = PluginFusion<P0, P1>
        where P0: VisitorPlugin,
        P1: VisitorPlugin

    typealias PluginFusion3<P0, P1, P2> = PluginFusion2<PluginFusion2<P0, P1>, P2>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin

    typealias PluginFusion4<P0, P1, P2, P3> = PluginFusion2<PluginFusion3<P0, P1, P2>, P3>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin

    typealias PluginFusion5<P0, P1, P2, P3, P4> = PluginFusion2<PluginFusion4<P0, P1, P2, P3>, P4>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin

    typealias PluginFusion6<P0, P1, P2, P3, P4, P5> = PluginFusion2<PluginFusion5<P0, P1, P2, P3, P4>, P5>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin

    // MARK: - Utility

    static func fusePlugins<P0, P1>(
        _ p0: P0, _ p1: P1
    ) -> PluginFusion<P0, P1>
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
        PluginFusion3(fusePlugins(p0, p1), p2)
    }

    static func fusePlugins<P0, P1, P2, P3>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3
    ) -> PluginFusion4<P0, P1, P2, P3>
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin
    {
        PluginFusion4(fusePlugins(p0, p1, p2), p3)
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
        PluginFusion5(fusePlugins(p0, p1, p2, p3), p4)
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
        PluginFusion6(fusePlugins(p0, p1, p2, p3, p4), p5)
    }

    static func unfusePlugins<P0, P1>(
        _ p: PluginFusion<P0, P1>
    ) -> (P0, P1)
        where P0: VisitorPlugin,
        P1: VisitorPlugin
    {
        p.plugins
    }

    static func unfusePlugins<P0, P1, P2>(
        _ p: PluginFusion3<P0, P1, P2>
    ) -> (P0, P1, P2)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin
    {
        Meta.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }

    static func unfusePlugins<P0, P1, P2, P3>(
        _ p: PluginFusion4<P0, P1, P2, P3>
    ) -> (P0, P1, P2, P3)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin
    {
        Meta.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }

    static func unfusePlugins<P0, P1, P2, P3, P4>(
        _ p: PluginFusion5<P0, P1, P2, P3, P4>
    ) -> (P0, P1, P2, P3, P4)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin
    {
        Meta.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }

    static func unfusePlugins<P0, P1, P2, P3, P4, P5>(
        _ p: PluginFusion6<P0, P1, P2, P3, P4, P5>
    ) -> (P0, P1, P2, P3, P4, P5)
        where P0: VisitorPlugin,
        P1: VisitorPlugin,
        P2: VisitorPlugin,
        P3: VisitorPlugin,
        P4: VisitorPlugin,
        P5: VisitorPlugin
    {
        Meta.foldl(unfusePlugins(p.plugins.0), p.plugins.1)
    }
}
