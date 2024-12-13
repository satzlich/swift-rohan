// Copyright 2024 Lie Yan

@testable import Rohan
import Foundation
import Testing

struct VisitorPluginTests {
    static let square = SampleTemplates.square
    static let circle = SampleTemplates.circle
    static let ellipse = SampleTemplates.ellipse

    static func isApply(_ expression: Rohan.Expression) -> Bool {
        switch expression {
        case .apply:
            return true
        default:
            return false
        }
    }

    static func isVariable(_ expression: Rohan.Expression) -> Bool {
        switch expression {
        case .variable:
            return true
        default:
            return false
        }
    }

    static func isVariable(_ expression: Rohan.Expression, _ name: Identifier) -> Bool {
        switch expression {
        case let .variable(variable):
            return variable.name == name
        default:
            return false
        }
    }

    @Test
    static func testPluginFusion() {
        let fused = Espresso.fusePlugins(
            Espresso.PredicatedCounter(isApply),
            Espresso.PredicatedCounter(isVariable),
            Espresso.PredicatedCounter { expression in isVariable(expression, Identifier("x")!) }
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

    @Test
    static func testSimplePlugin() {
        let result = Espresso.applyPlugin(Espresso.PredicatedCounter(isApply), circle.body)

        #expect(result.count == 2)
    }
}
