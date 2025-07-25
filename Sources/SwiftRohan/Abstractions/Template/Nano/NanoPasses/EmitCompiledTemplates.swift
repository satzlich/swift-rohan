import Foundation

extension Nano {
  struct EmitCompiledTemplates: NanoPass {
    typealias Input = Array<AnnotatedTemplate<LookupTable>>
    typealias Output = Array<CompiledTemplate>

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(emitCompiledTemplate(_:))
      return .success(output)
    }

    static func emitCompiledTemplate(_ template: Input.Element) -> CompiledTemplate {
      let variablePaths = convert(template.annotation, template.parameters.count)
      return CompiledTemplate(
        template.name, template.body, template.layoutType, variablePaths)
    }

    private static func convert(
      _ lookupTable: LookupTable, _ parameterCount: Int
    ) -> Array<VariablePaths> {
      precondition(lookupTable.keys.allSatisfy { $0 < parameterCount })
      var output = Array<VariablePaths>(repeating: .init(), count: parameterCount)
      for (index, locations) in lookupTable {
        output[index] = locations
      }
      return output
    }
  }
}
