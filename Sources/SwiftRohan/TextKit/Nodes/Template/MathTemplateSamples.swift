// Copyright 2024-2025 Lie Yan

enum MathTemplateSamples {
  nonisolated(unsafe) static let newtonsLaw =
    MathTemplate(CompiledSamples.newtonsLaw, .commandCall)
  nonisolated(unsafe) static let bifun =
    MathTemplate(CompiledSamples.bifun, .commandCall)
  nonisolated(unsafe) static let complexFraction =
    MathTemplate(
      CompiledSamples.complexFraction, .commandCall)
  nonisolated(unsafe) static let philipFox =
    MathTemplate(CompiledSamples.philipFox, .commandCall)
  nonisolated(unsafe) static let doubleText =
    MathTemplate(CompiledSamples.doubleText, .commandCall)
}
