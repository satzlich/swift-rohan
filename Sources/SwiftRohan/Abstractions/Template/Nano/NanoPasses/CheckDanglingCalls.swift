// Copyright 2024-2025 Lie Yan

import Foundation

extension Nano {
  /// Check for dangling calls in the template list.
  struct CheckDanglingCalls: NanoPass {
    // annotation is a set of template names that are called by the template
    typealias Input = Array<AnnotatedTemplate<TemplateNames>>
    typealias Output = Array<AnnotatedTemplate<TemplateNames>>

    static func process(_ input: Input) -> PassResult<Output> {
      let declarations = Set(input.map(\.name))

      func isDangling(_ call: TemplateName) -> Bool {
        declarations.contains(call) == false
      }
      func containsDangling(_ template: Input.Element) -> Bool {
        template.annotation.contains(where: isDangling(_:))
      }

      let bad = input.contains(where: containsDangling(_:))

      return bad ? .failure(PassError()) : .success(input)
    }
  }
}
