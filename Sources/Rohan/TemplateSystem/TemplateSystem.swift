// Copyright 2024 Lie Yan

import Foundation
import OrderedCollections

typealias TreePath = [RohanIndex]
typealias VariablePaths = OrderedSet<TreePath>

struct TemplateSystem {
  let canonicalTemplates: [TemplateName: Template]
  let compiledTemplates: [TemplateName: CompiledTemplate]

  init(_ templates: [Template]) {
    guard let compiled = Nano.NanoPassDriver.process(templates).success() else {
      preconditionFailure()
    }
    self.canonicalTemplates = Dictionary(uniqueKeysWithValues: templates.map { ($0.name, $0) })
    self.compiledTemplates = Dictionary(uniqueKeysWithValues: compiled.map { ($0.name, $0) })
  }
}
