// Copyright 2024-2025 Lie Yan

import Foundation

extension Nano {
  struct EmitCompiledTemplates: NanoPass {
    typealias Input = [AnnotatedTemplate<VariableLocationsDict>]
    typealias Output = [CompiledTemplate]

    static func process(
      _ input: [AnnotatedTemplate<VariableLocationsDict>]
    ) -> PassResult<[CompiledTemplate]> {
      let output = input.map(emitCompiledTemplate(_:))
      return .success(output)
    }

    static func emitCompiledTemplate(
      _ template: AnnotatedTemplate<VariableLocationsDict>
    ) -> CompiledTemplate {
      CompiledTemplate(
        name: template.name,
        parameterCount: template.canonical.parameters.count,
        body: template.canonical.body,
        variableLocations: template.annotation)
    }
  }
}
