// Copyright 2024-2025 Lie Yan

import Foundation

extension Nano {
  struct CheckDanglingCalls: NanoPass {
    // annotation is a set of template names that are called by the template
    typealias Input = [AnnotatedTemplate<TemplateNames>]
    typealias Output = [AnnotatedTemplate<TemplateNames>]

    static func process(_ input: Input) -> PassResult<Output> {
      let declarations = Set(input.map(\.name))
      func isDangling(_ call: TemplateName) -> Bool {
        !declarations.contains(call)
      }
      func containsDangling(_ template: Input.Element) -> Bool {
        template.annotation.contains(where: isDangling)
      }
      let bad = input.contains(where: containsDangling)
      return bad ? .failure(PassError()) : .success(input)
    }
  }
}
