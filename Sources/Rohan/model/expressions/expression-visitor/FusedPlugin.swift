// Copyright 2024 Lie Yan

import Foundation

struct FusedPlugin2<P, Q>: ExpressionPlugin
where P: ExpressionPlugin, Q: ExpressionPlugin, P.Context == Q.Context {
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

typealias FusedPlugin3<P0, P1, P2> = FusedPlugin2<FusedPlugin2<P0, P1>, P2>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin

typealias FusedPlugin4<P0, P1, P2, P3> = FusedPlugin2<FusedPlugin3<P0, P1, P2>, P3>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin

typealias FusedPlugin5<P0, P1, P2, P3, P4> = FusedPlugin2<FusedPlugin4<P0, P1, P2, P3>, P4>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
    P4: ExpressionPlugin

typealias FusedPlugin6<P0, P1, P2, P3, P4, P5> = FusedPlugin2<FusedPlugin5<P0, P1, P2, P3, P4>, P5>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
    P4: ExpressionPlugin, P5: ExpressionPlugin

extension expresso {
    // MARK: - Utility

    static func fuse<P0, P1>(_ p0: P0, _ p1: P1) -> FusedPlugin2<P0, P1>
    where P0: ExpressionPlugin, P1: ExpressionPlugin {
        FusedPlugin2(p0, p1)
    }

    static func fuse<P0, P1, P2>(_ p0: P0, _ p1: P1, _ p2: P2) -> FusedPlugin3<P0, P1, P2>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin {
        FusedPlugin3(fuse(p0, p1), p2)
    }

    static func fuse<P0, P1, P2, P3>(_ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3) -> FusedPlugin4<P0, P1, P2, P3>
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin {
        FusedPlugin4(fuse(p0, p1, p2), p3)
    }

    static func fuse<P0, P1, P2, P3, P4>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4
    ) -> FusedPlugin5<P0, P1, P2, P3, P4>
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin
    {
        FusedPlugin5(fuse(p0, p1, p2, p3), p4)
    }

    static func fuse<P0, P1, P2, P3, P4, P5>(
        _ p0: P0, _ p1: P1, _ p2: P2, _ p3: P3, _ p4: P4, _ p5: P5
    ) -> FusedPlugin6<P0, P1, P2, P3, P4, P5>
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin, P5: ExpressionPlugin
    {
        FusedPlugin6(fuse(p0, p1, p2, p3, p4), p5)
    }

    static func unfuse<P0, P1>(_ p: FusedPlugin2<P0, P1>) -> (P0, P1)
    where P0: ExpressionPlugin, P1: ExpressionPlugin {
        p.plugins
    }

    static func unfuse<P0, P1, P2>(_ p: FusedPlugin3<P0, P1, P2>) -> (P0, P1, P2)
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin {
        MPL.foldl(unfuse(p.plugins.0), p.plugins.1)
    }

    static func unfuse<P0, P1, P2, P3>(
        _ p: FusedPlugin4<P0, P1, P2, P3>
    ) -> (P0, P1, P2, P3)
    where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin {
        MPL.foldl(unfuse(p.plugins.0), p.plugins.1)
    }

    static func unfuse<P0, P1, P2, P3, P4>(
        _ p: FusedPlugin5<P0, P1, P2, P3, P4>
    ) -> (P0, P1, P2, P3, P4)
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin
    {
        MPL.foldl(unfuse(p.plugins.0), p.plugins.1)
    }

    static func unfuse<P0, P1, P2, P3, P4, P5>(
        _ p: FusedPlugin6<P0, P1, P2, P3, P4, P5>
    ) -> (P0, P1, P2, P3, P4, P5)
        where P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin, P3: ExpressionPlugin,
        P4: ExpressionPlugin, P5: ExpressionPlugin
    {
        MPL.foldl(unfuse(p.plugins.0), p.plugins.1)
    }
}
