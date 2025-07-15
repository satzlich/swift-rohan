// Copyright 2024-2025 Lie Yan

enum MathTemplateSamples {
  nonisolated(unsafe) static let newtonsLaw =
    MathTemplate(CompiledSamples.newtonsLaw, subtype: .commandCall)
  nonisolated(unsafe) static let bifun =
    MathTemplate(CompiledSamples.bifun, subtype: .commandCall)
  nonisolated(unsafe) static let complexFraction =
    MathTemplate(CompiledSamples.complexFraction, subtype: .commandCall)
  nonisolated(unsafe) static let philipFox =
    MathTemplate(CompiledSamples.philipFox, subtype: .commandCall)
  nonisolated(unsafe) static let doubleText =
    MathTemplate(CompiledSamples.doubleText, subtype: .commandCall)
}
