// Copyright 2024-2025 Lie Yan

import Algorithms
import Foundation
import OrderedCollections

extension Nano {
  struct InlineTemplateCalls: NanoPass {
    typealias Input = [AnnotatedTemplate<TemplateCalls>]
    typealias Output = [Template]

    /// template name -> template; with order
    private typealias TemplateTable = OrderedDictionary<TemplateName, Template>

    /// variable name -> content
    private typealias Environment = Dictionary<Identifier, Content>

    /** The whole process can be statically factored out. So we put it here. */
    static func process(_ templates: [AnnotatedTemplate<TemplateCalls>]) -> PassResult<[Template]> {
      // 1) partition templates into two groups: bad and okay
      let (bad, okay) = templates.partitioned(by: { $0.annotation.isEmpty })

      // 2) put okay into dictionary
      var templateTable = TemplateTable(
        uniqueKeysWithValues: okay.map { ($0.name, $0.canonical) })

      // 3) process bad
      for t in bad {
        // a) inline calls in t
        let tt = inlineTemplateCalls(in: t.canonical, templateTable)
        // b) check t is okay
        assert(Espresso.count({ $0.type == .apply }, in: tt.body) == 0)
        // c) put t into okay
        assert(templateTable[tt.name] == nil)
        templateTable[tt.name] = tt
      }

      return .success(templateTable.map(\.value))
    }

    private static func inlineTemplateCalls(
      in template: Template,
      _ okayDict: TemplateTable
    ) -> Template {
      let body = InlineTemplateCallsRewriter(okayDict).rewrite(content: template.body, ())
      return template.with(body: body)
    }

    private final class InlineTemplateCallsRewriter: ExpressionRewriter<Void> {
      private let templateTable: TemplateTable

      init(_ templateTable: TemplateTable) {
        self.templateTable = templateTable
      }

      override func visit(apply: Apply, _ context: Void) -> R {
        precondition(templateTable[apply.templateName] != nil)

        let template = templateTable[apply.templateName]!
        assert(template.parameters.count == apply.arguments.count)

        let environment = Environment(
          uniqueKeysWithValues: zip(
            template.parameters,
            apply.arguments))
        let body = EvaluateExpressionRewriter(environment)
          .rewrite(content: template.body, ())

        return .content(body)
      }
    }

    /**
         Evaluate the expression under the given environment
         */
    private final class EvaluateExpressionRewriter: ExpressionRewriter<Void> {
      private let environment: Environment

      init(_ environment: Environment) {
        self.environment = environment
      }

      override func visit(variable: Variable, _ context: Void) -> R {
        precondition(environment[variable.name] != nil)
        return .content(environment[variable.name]!)
      }
    }
  }
}
