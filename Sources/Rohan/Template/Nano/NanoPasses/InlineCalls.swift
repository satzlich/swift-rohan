// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import OrderedCollections

extension Nano {
  struct InlineCalls: NanoPass {
    typealias Input = [AnnotatedTemplate<TemplateNames>]
    typealias Output = [Template]

    /// template name -> template; with order
    private typealias TemplateTable = OrderedDictionary<TemplateName, Template>

    static func process(_ templates: Input) -> PassResult<Output> {
      // 1) partition templates into two groups: bad and okay
      let (bad, okay) = templates.partitioned(by: { $0.annotation.isEmpty })

      // 2) put okay into dictionary
      var templateTable = TemplateTable(
        uniqueKeysWithValues: okay.map { ($0.name, $0.template) })

      func isFreeOfApply(_ body: [Expr]) -> Bool {
        NanoUtils.countExpr(from: body, where: { $0 is ApplyExpr }) == 0
      }

      // 3) process bad
      for original in bad {
        // a) inline calls in t
        let processed = inlineTemplateCalls(in: original.template, templateTable)
        // b) check t is okay
        assert(isFreeOfApply(processed.body))
        // c) put t into okay
        assert(templateTable[processed.name] == nil)
        templateTable[processed.name] = processed
      }

      return .success(templateTable.map(\.value))
    }

    private static func inlineTemplateCalls(
      in template: Template,
      _ okayDict: TemplateTable
    ) -> Template {
      let body = InlineCallsRewriter(okayDict).rewrite(template.body, ())
      return template.with(body: body)
    }

    private final class InlineCallsRewriter: ExpressionRewriter<Void> {
      private let templateTable: TemplateTable

      init(_ templateTable: TemplateTable) {
        self.templateTable = templateTable
      }

      override func visit(apply: ApplyExpr, _ context: Void) -> R {
        precondition(templateTable[apply.templateName] != nil)
        let template = templateTable[apply.templateName]!
        assert(template.parameters.count == apply.arguments.count)
        let rewriter = EvalExprRewriter(template.parameters, apply.arguments)
        let body = rewriter.rewrite(template.body, ())
        return ContentExpr(body)
      }
    }

    /// Evaluate the expression under the given environment.
    private final class EvalExprRewriter: ExpressionRewriter<Void> {
      /** variable name -> content */
      private typealias Environment = Dictionary<Identifier, ContentExpr>
      private let environment: Environment

      init(_ parameters: [Identifier], _ values: [ContentExpr]) {
        precondition(parameters.count == values.count)
        self.environment = Environment(uniqueKeysWithValues: zip(parameters, values))
      }
      override func visit(variable: VariableExpr, _ context: Void) -> R {
        precondition(environment[variable.name] != nil)
        return environment[variable.name]!
      }
    }
  }
}
