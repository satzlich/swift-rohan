// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct VisitorPluginTests {
    static let square = SampleTemplates.square
    static let circle = SampleTemplates.circle
    static let ellipse = SampleTemplates.ellipse

    @Test
    static func testActionGroup() {
        let fused = Espresso.group(
            actions: Espresso.counter(predicate: { $0.type == .apply }),
            Espresso.counter(predicate: { $0.type == .variable }),
            Espresso.counter(predicate: { expression in
                expression.type == .variable &&
                    expression.unwrapVariable()!.name == Identifier("x")
            })
        )

        let result = Espresso.play(action: fused, on: circle.body)

        let (
            namedApplyCounter,
            namedVariableCounter,
            xVariableCounter
        ) = Espresso.ungroup(result)

        #expect(namedApplyCounter.count == 2)
        #expect(namedVariableCounter.count == 2)
        #expect(xVariableCounter.count == 1)
    }

    @Test
    static func testSimplePlugin() {
        let counter = Espresso.play(
            action: Espresso.counter(predicate: { $0.type == .apply }),
            on: circle.body
        )
        #expect(counter.count == 2)
    }
}
