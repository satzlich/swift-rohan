// Copyright 2024-2025 Lie Yan

import Foundation

extension Nano {
  struct CheckDanglingCalls: NanoPass {
    // annotation is a set of template names that are called by the template
    typealias Input = [AnnotatedTemplate<TemplateNames>]
    typealias Output = [AnnotatedTemplate<TemplateNames>]

    static func process(_ input: Input) -> PassResult<Output> {
      let templates = Set(input.map(\.canonical.name))
      func isDangling(_ calls: TemplateNames) -> Bool {
        calls.contains { !templates.contains($0) }
      }
      let dangling = input.contains { isDangling($0.annotation) }
      return dangling ? .failure(PassError()) : .success(input)
    }
  }
}
