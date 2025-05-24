// Copyright 2024-2025 Lie Yan

enum Nano {
  protocol NanoPass {
    associatedtype Input
    associatedtype Output

    static func process(_ input: Input) -> PassResult<Output>
  }

  struct PassError: Error {}
  typealias PassResult<T> = Result<T, PassError>

  typealias TemplateNames = Set<TemplateName>

  static let allNanoPasses: [any NanoPass.Type] = [
    // in order of execution
    CheckWellFormedness.self,
    ExtractCalls.self,
    CheckDanglingCalls.self,
    TSortTemplates.self,
    InlineCalls.self,
    UnnestContents.self,
    MergeNeighbours.self,
    ConvertVariables.self,
    ComputeLookupTables.self,
    EmitCompiledTemplates.self,  // final pass
  ]

  struct NanoPassDriver: NanoPass {  // NanoPassDriver is not a nano pass
    typealias Input = [Template]
    typealias Output = [CompiledTemplate]

    static func process(_ input: [Template]) -> PassResult<[CompiledTemplate]> {
      PassResult.success(input)
        .flatMap(CheckWellFormedness.process)
        .flatMap(ExtractCalls.process)
        .flatMap(CheckDanglingCalls.process)
        .flatMap(TSortTemplates.process)
        .flatMap(InlineCalls.process)
        .flatMap(UnnestContents.process)
        .flatMap(MergeNeighbours.process)
        .flatMap(ConvertVariables.process)
        .flatMap(ComputeLookupTables.process)
        .flatMap(EmitCompiledTemplates.process)
    }
  }

  /// Compile a template to a compiled template.
  static func compile(_ template: Template) -> PassResult<CompiledTemplate> {
    let templates = [template]
    return NanoPassDriver.process(templates).map { $0[0] }
  }
}
