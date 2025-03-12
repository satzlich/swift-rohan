// Copyright 2024-2025 Lie Yan

import Foundation

extension Nano {
  struct EmitCompiledTemplates: NanoPass {
    typealias Input = [AnnotatedTemplate<LookupTable>]
    typealias Output = [CompiledTemplate]

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(emitCompiledTemplate(_:))
      return .success(output)
    }

    static func emitCompiledTemplate(_ template: Input.Element) -> CompiledTemplate {
      let variablePaths = convert(template.annotation, template.parameters.count)
      return CompiledTemplate(template.name, template.body, variablePaths)
    }

    private static func convert(
      _ variableLocations: LookupTable, _ parameterCount: Int
    ) -> [VariablePaths] {
      precondition(variableLocations.keys.allSatisfy { $0 < parameterCount })
      var output = [VariablePaths](repeating: .init(), count: parameterCount)
      for (index, locations) in variableLocations {
        output[index] = locations
      }
      return output
    }
  }
}
