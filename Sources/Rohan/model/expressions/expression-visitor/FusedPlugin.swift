// Copyright 2024 Lie Yan

import Foundation

struct FusedPlugin2<P0: ExpressionPlugin, P1: ExpressionPlugin>: ExpressionPlugin
where P0.Context == P1.Context {
    typealias Context = P0.Context

    private(set) var p0: P0
    private(set) var p1: P1

    init(_ p0: P0, _ p1: P1) {
        self.p0 = p0
        self.p1 = p1
    }

    mutating func visitApply(_ apply: Apply, _ context: Context) {
        p0.visitApply(apply, context)
        p1.visitApply(apply, context)
    }

    mutating func visitVariable(_ variable: Variable, _ context: Context) {
        p0.visitVariable(variable, context)
        p1.visitVariable(variable, context)
    }

    mutating func visitNamelessApply(_ namelessApply: NamelessApply, _ context: Context) {
        p0.visitNamelessApply(namelessApply, context)
        p1.visitNamelessApply(namelessApply, context)
    }

    mutating func visitNamelessVariable(_ namelessVariable: NamelessVariable, _ context: Context) {
        p0.visitNamelessVariable(namelessVariable, context)
        p1.visitNamelessVariable(namelessVariable, context)
    }

    mutating func visitText(_ text: Text, _ context: Context) {
        p0.visitText(text, context)
        p1.visitText(text, context)
    }

    mutating func visitContent(_ content: Content, _ context: Context) {
        p0.visitContent(content, context)
        p1.visitContent(content, context)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis, _ context: Context) {
        p0.visitEmphasis(emphasis, context)
        p1.visitEmphasis(emphasis, context)
    }

    mutating func visitHeading(_ heading: Heading, _ context: Context) {
        p0.visitHeading(heading, context)
        p1.visitHeading(heading, context)
    }

    mutating func visitParagraph(_ paragraph: Paragraph, _ context: Context) {
        p0.visitParagraph(paragraph, context)
        p1.visitParagraph(paragraph, context)
    }

    mutating func visitEquation(_ equation: Equation, _ context: Context) {
        p0.visitEquation(equation, context)
        p1.visitEquation(equation, context)
    }

    mutating func visitFraction(_ fraction: Fraction, _ context: Context) {
        p0.visitFraction(fraction, context)
        p1.visitFraction(fraction, context)
    }

    mutating func visitMatrix(_ matrix: Matrix, _ context: Context) {
        p0.visitMatrix(matrix, context)
        p1.visitMatrix(matrix, context)
    }

    mutating func visitScripts(_ scripts: Scripts, _ context: Context) {
        p0.visitScripts(scripts, context)
        p1.visitScripts(scripts, context)
    }
}

typealias FusedPlugin3<
    P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin
> = FusedPlugin2<P0, FusedPlugin2<P1, P2>>

typealias FusedPlugin4<
    P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin,
    P3: ExpressionPlugin
> = FusedPlugin2<P0, FusedPlugin3<P1, P2, P3>>

typealias FusedPlugin5<
    P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin,
    P3: ExpressionPlugin, P4: ExpressionPlugin
> = FusedPlugin2<P0, FusedPlugin4<P1, P2, P3, P4>>

typealias FusedPlugin6<
    P0: ExpressionPlugin, P1: ExpressionPlugin, P2: ExpressionPlugin,
    P3: ExpressionPlugin, P4: ExpressionPlugin, P5: ExpressionPlugin
> = FusedPlugin2<P0, FusedPlugin5<P1, P2, P3, P4, P5>>

enum PluginUtils {
    static func fuse<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1
    ) -> FusedPlugin2<P0, P1> {
        FusedPlugin2(p0, p1)
    }

    static func fuse<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin
    >(
        _ p0: P0,
        _ p1: P1,
        _ p2: P2
    ) -> FusedPlugin3<P0, P1, P2> {
        fuse(p0, fuse(p1, p2))
    }

    static func fuse<
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
        fuse(p0, fuse(p1, p2, p3))
    }

    static func fuse<
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
        fuse(p0, fuse(p1, p2, p3, p4))
    }

    static func fuse<
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
        fuse(p0, fuse(p1, p2, p3, p4, p5))
    }

    static func unfuse<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin
    >(
        _ fused: FusedPlugin2<P0, P1>
    ) -> (P0, P1) {
        (fused.p0, fused.p1)
    }

    static func unfuse<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin
    >(
        _ fused: FusedPlugin3<P0, P1, P2>
    ) -> (P0, P1, P2) {
        MPL.foldr(fused.p0, unfuse(fused.p1))
    }

    static func unfuse<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin,
        P3: ExpressionPlugin
    >(
        _ fused: FusedPlugin4<P0, P1, P2, P3>
    ) -> (P0, P1, P2, P3) {
        MPL.foldr(fused.p0, unfuse(fused.p1))
    }

    static func unfuse<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin,
        P3: ExpressionPlugin,
        P4: ExpressionPlugin
    >(
        _ fused: FusedPlugin5<P0, P1, P2, P3, P4>
    ) -> (P0, P1, P2, P3, P4) {
        MPL.foldr(fused.p0, unfuse(fused.p1))
    }

    static func unfuse<
        P0: ExpressionPlugin,
        P1: ExpressionPlugin,
        P2: ExpressionPlugin,
        P3: ExpressionPlugin,
        P4: ExpressionPlugin,
        P5: ExpressionPlugin
    >(
        _ fused: FusedPlugin6<P0, P1, P2, P3, P4, P5>
    ) -> (P0, P1, P2, P3, P4, P5) {
        MPL.foldr(fused.p0, unfuse(fused.p1))
    }
}
