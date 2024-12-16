// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct ExpressionActionTests {
    static let square = SampleTemplates.square
    static let circle = SampleTemplates.circle
    static let ellipse = SampleTemplates.ellipse

    @Test
    static func testActionGroup() {
        let actionGroup = Espresso.group(actions:
            Espresso.CountingAction { $0.type == .apply },
            Espresso.CountingAction { $0.type == .variable },
            Espresso.CountingAction { expression in
                expression.type == .variable &&
                    expression.unwrapVariable()!.name == Identifier("x")
            })
        let result = Espresso.play(action: actionGroup, on: circle.body)
        let (apply, variable, x) = Espresso.ungroup(result)

        #expect(apply.count == 2)
        #expect(variable.count == 2)
        #expect(x.count == 1)
    }

    @Test
    static func testCountingAction() {
        let apply = Espresso.play(
            action: Espresso.CountingAction { $0.type == .apply },
            on: circle.body
        )
        #expect(apply.count == 2)
    }

    @Test
    static func testClosureAction() {
        var count = 0
        _ = Espresso.play(
            action: Espresso.ClosureAction { expression, _ in
                if expression.type == .apply {
                    count += 1
                }
            },
            on: circle.body
        )
        #expect(count == 2)
    }
}
