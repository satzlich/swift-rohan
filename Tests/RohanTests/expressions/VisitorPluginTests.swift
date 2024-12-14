// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct VisitorPluginTests {
    static let square = SampleTemplates.square
    static let circle = SampleTemplates.circle
    static let ellipse = SampleTemplates.ellipse

    @Test
    static func testPluginFusion() {
        let fused = Espresso.fusePlugins(
            Espresso.counter(predicate: { $0.isApply }),
            Espresso.counter(predicate: { $0.isVariable }),
            Espresso.counter(predicate: { expression in
                Espresso.isVariable(expression, withName: Identifier("x")!)
            })
        )

        let result = Espresso.plugAndPlay(fused, circle.body)

        let (
            nameApplyCounter,
            namedVariableCounter,
            xVariableCounter
        ) = Espresso.unfusePluginFusion(result)

        #expect(nameApplyCounter.count == 2)
        #expect(namedVariableCounter.count == 2)
        #expect(xVariableCounter.count == 1)
    }

    @Test
    static func testSimplePlugin() {
        let result =
            Espresso.plugAndPlay(Espresso.counter(predicate: { $0.isApply }),
                                 circle.body)
        #expect(result.count == 2)
    }
}
