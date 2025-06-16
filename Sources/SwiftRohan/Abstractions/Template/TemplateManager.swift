// Copyright 2024 Lie Yan

import Foundation

typealias TreePath = Array<RohanIndex>
typealias VariablePaths = Array<TreePath>

struct TemplateManager {
  let templates: Dictionary<TemplateName, Template>
  let compiledTemplates: Dictionary<TemplateName, CompiledTemplate>

  init(_ templates: Array<Template>) {
    guard let compiled = Nano.NanoPassDriver.process(templates).success()
    else { preconditionFailure("Unexpected failure") }

    self.templates = Dictionary(uniqueKeysWithValues: templates.map { ($0.name, $0) })
    self.compiledTemplates =
      Dictionary(uniqueKeysWithValues: compiled.map { ($0.name, $0) })
  }
}
