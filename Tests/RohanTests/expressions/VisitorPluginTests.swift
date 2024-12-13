// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct VisitorPluginTests {
    static let square = SampleTemplates.square
    static let circle = SampleTemplates.circle
    static let ellipse = SampleTemplates.ellipse

    @Test
    static func testPlugins() {
        let fused = Espresso.fusePlugins(
            Espresso.ApplyCounter(),
            Espresso.VariableCounter(),
            Espresso.ParticularVariableCounter(Identifier("x")!)
        )

        let result = Espresso.applyPlugin(fused, circle.body)

        let (
            nameApplyCounter,
            namedVariableCounter,
            xVariableCounter
        ) = Espresso.unfusePlugins(result)

        #expect(nameApplyCounter.count == 2)
        #expect(namedVariableCounter.count == 2)
        #expect(xVariableCounter.count == 1)
    }
}
