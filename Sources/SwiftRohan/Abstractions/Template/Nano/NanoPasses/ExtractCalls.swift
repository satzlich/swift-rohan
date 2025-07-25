import Algorithms
import Foundation
import HashTreeCollections

extension Nano {
  struct ExtractCalls: NanoPass {
    typealias Input = Array<Template>
    // annoation is the set of template names that the template calls
    typealias Output = Array<AnnotatedTemplate<TemplateNames>>

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map { template in
        let calls = extractTemplateCalls(in: template)
        return AnnotatedTemplate(template, annotation: calls)
      }
      return .success(output)
    }

    /// Returns the templates referenced by the template
    /// - Complexity: O(n)
    private static func extractTemplateCalls(in template: Template) -> TemplateNames {
      let walker = ExtractTemplateCallsWalker()
      walker.traverseExpressions(template.body, ())
      return walker.templateCalls
    }

    /// Analyses a template to determine which other templates it calls.
    private final class ExtractTemplateCallsWalker: ExpressionWalker<Void> {
      private(set) var templateCalls: TemplateNames = []

      override func willVisitExpression(_ expression: Expr, _ context: Void) {
        if let apply = expression as? ApplyExpr {
          templateCalls.insert(apply.templateName)
        }
      }
    }
  }
}
