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
        let fused = Espresso.composeFusion(
            Espresso.counter(predicate: { $0.type == .apply }),
            Espresso.counter(predicate: { $0.type == .variable }),
            Espresso.counter(predicate: { expression in
                expression.type == .variable &&
                    expression.unwrapVariable()!.name == Identifier("x")
            })
        )

        let result = Espresso.plugAndPlay(fused, circle.body)

        let (
            namedApplyCounter,
            namedVariableCounter,
            xVariableCounter
        ) = Espresso.decompose(fusion: result)

        #expect(namedApplyCounter.count == 2)
        #expect(namedVariableCounter.count == 2)
        #expect(xVariableCounter.count == 1)
    }

    @Test
    static func testSimplePlugin() {
        let counter = Espresso.plugAndPlay(
            Espresso.counter(predicate: { $0.type == .apply }),
            circle.body
        )
        #expect(counter.count == 2)
    }
}
