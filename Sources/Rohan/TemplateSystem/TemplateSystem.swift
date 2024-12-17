// Copyright 2024 Lie Yan

import Foundation

struct TemplateSystem {
    let canonicalTemplates: [TemplateName: Template]
    let compiledTemplates: [TemplateName: CompiledTemplate]

    init(_ templates: [Template]) {
        let result = Nano.NanoPassDriver.process(templates)

        precondition(result.isSuccess())
        let compiled = result.success()!

        self.canonicalTemplates = Dictionary(uniqueKeysWithValues: templates.map { ($0.name, $0) })
        self.compiledTemplates = Dictionary(uniqueKeysWithValues: compiled.map { ($0.name, $0) })
    }

    func getCanonicalTemplate(_ name: TemplateName) -> Template? {
        canonicalTemplates[name]
    }

    func getCompiledTemplate(_ name: TemplateName) -> CompiledTemplate? {
        compiledTemplates[name]
    }
}
