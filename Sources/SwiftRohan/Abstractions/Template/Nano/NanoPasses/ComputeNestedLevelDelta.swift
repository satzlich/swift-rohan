// Copyright 2024-2025 Lie Yan

extension Nano {
  /// Compute nested level delta for each variable in the template.
  struct ComputeNestedLevelDelta: NanoPass {
    typealias Input = [Template]
    typealias Output = [Template]

    static func process(_ input: Input) -> PassResult<Output> {
      let output = input.map(computeNestedLevelDelta(_:))
      return .success(output)
    }
  }

  private static func computeNestedLevelDelta(_ template: Template) -> Template {
    preconditionFailure()
  }
}
